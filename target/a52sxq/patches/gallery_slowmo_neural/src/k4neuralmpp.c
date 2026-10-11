// k4neuralmpp: MPP store (AIDL V1 ISehMppStore, raw NDK binder) whose FRC pipe interpolates with the recovered
// AIFRC v3 network (k4n_engine.c). Everything else is forwarded to the classic store it is pointed at.
//
//   k4neuralmpp --serve <service name to register> --stock <service name of the classic store> [options]
//
// It never touches another process's registration: it registers exactly the name given with --serve.
// Protocol = server side of probe/mppprobe.c:
//   store: create=1 getAvailableTypes=2 getCapabilityByType=3
//   mpp:   init=1 setBuffer=2 setParameter=3 emptyBuffer=4 fillBuffer=5 flush=6 reset=7 getBufferCount=8
//          getBufferFormat=9 getBufferSize=10;  callback (oneway): onEmptyBufferDone=1 onFillBufferDone=2 onFlushDone=3 onError=4
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <errno.h>
#include <dlfcn.h>
#include <pthread.h>
#include <signal.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <linux/dma-buf.h>
#include <sys/system_properties.h>
#include <android/binder_ibinder.h>
#include <android/binder_parcel.h>
#include <android/binder_status.h>
#include "k4n.h"

int k4n_verbose;
#define STORE "vendor.samsung.hardware.media.mpp.ISehMppStore"
#define MPP   "vendor.samsung.hardware.media.mpp.ISehMpp"
#define CB    "vendor.samsung.hardware.media.mpp.ISehMppCallback"
#define TX_VERSION 16777215
#define TX_HASH    16777214
#define TX_K4_WARMUP 0x4B3401   // k4neuralmpp only (oneway, no arguments): build the network now
#define TYPE_FRC 3
#define CF_NV12 2
#define FMT_NV12 0x109
#define N_IN 2
#define N_OUT 16
#define MAXBUF 64
// SehBufferFlag: MppClient::onFillBufferDone only announces outputs with bit 0 (frame) or bit 1 (end of stream)
#define FLAG_FRAME 1
#define FLAG_EOS 2
#define GRALLOC_MAGIC 0x676D736D   /* 'gmsm' */
#define GRALLOC_SIZE_INT 13

// platform symbols of libbinder_ndk that the API 30 NDK stub does not declare
static AIBinder* (*sm_waitForService)(const char*);
static binder_exception_t (*sm_addService)(AIBinder*, const char*);
static void (*markVintf)(AIBinder*);
static binder_status_t (*parcel_appendFrom)(const AParcel* from, AParcel* to, int32_t start, int32_t size);
static int32_t (*parcel_getDataSize)(const AParcel*);
static bool (*pool_setMax)(uint32_t);
static void (*pool_start)(void);
static void (*pool_join)(void);

static AIBinder_Class *cStore, *cMpp, *cCb;
static AIBinder* g_stock; static const char* g_stock_name; static pthread_mutex_t g_stock_mu = PTHREAD_MUTEX_INITIALIZER;
static AIBinder* stock_get(void);
static K4nConfig g_cfg = { "/vendor/lib64/k4neural", "/vendor/etc/k4neural", 2 };
static int g_vintf = 1;
// engine life time: built on warm-up/create, released after K4N_IDLE_S seconds without a pipe
static pthread_mutex_t g_use_mu = PTHREAD_MUTEX_INITIALIZER; static int g_live_pipes; static double g_last_use;
static void engine_touch(int dpipes) { pthread_mutex_lock(&g_use_mu); g_live_pipes += dpipes; g_last_use = k4n_now_ms(); pthread_mutex_unlock(&g_use_mu); }
static char g_hash[128]; static int g_version = 1;

static int prop_int(const char* name, int def) { char v[PROP_VALUE_MAX] = ""; return __system_property_get(name, v) > 0 ? atoi(v) : def; }
static int neural_mode(void) { const char* e = getenv("K4N_MODE"); return e ? atoi(e) : prop_int("persist.sys.k4.slowmo_neural", 1); }

// ---------------------------------------------------------------------------------------------------------------
typedef struct { int fd; uint8_t* p; size_t size; int valid, stride, scan, dmabuf; } Buf;
typedef struct { int id; long long ts; int flag; } InItem;
typedef struct Pipe {
    pthread_mutex_t mu; pthread_cond_t cv; pthread_t th; int th_started, quit, flushing, busy;
    AIBinder* cb;
    int w, h, stride, elev, factor, range_factor;
    Buf in[MAXBUF], out[MAXBUF]; int out_free[MAXBUF];
    InItem q[MAXBUF]; int qn;
    K4nSession* ses;
    uint8_t *prev, *cur; float *nprev, *ncur; int have_prev; long long prev_ts;
    // statistics of this hold
    int n_in, n_out, n_gen, n_repeat; double ms_inf, ms_warp, ms_prep, t_first_in, t_first_out, t_init, t_last; float max_flow;
} Pipe;

static void write_ok(AParcel* out) { AStatus* s = AStatus_newOk(); AParcel_writeStatusHeader(out, s); AStatus_delete(s); }
static binder_status_t write_err(AParcel* out, int e) { AStatus* s = AStatus_fromServiceSpecificError(e); AParcel_writeStatusHeader(out, s); AStatus_delete(s); return STATUS_OK; }

static void cb_send(Pipe* p, int code, int nargs, int id, long long ts, int flag) {
    if (!p->cb) return;
    AParcel *in = NULL, *out = NULL;
    if (AIBinder_prepareTransaction(p->cb, &in) != STATUS_OK) return;
    if (nargs >= 1) AParcel_writeInt32(in, id);
    if (nargs >= 3) { AParcel_writeInt64(in, ts); AParcel_writeInt32(in, flag); }
    AIBinder_transact(p->cb, code, &in, &out, FLAG_ONEWAY);
    if (out) AParcel_delete(out);
    if (in) AParcel_delete(in);
}

// wait for a free output buffer; -1 when the pipe is flushing/quitting
static int take_out(Pipe* p) {
    int id = -1;
    pthread_mutex_lock(&p->mu);
    for (;;) {
        if (p->quit || p->flushing) break;
        for (int i = 0; i < MAXBUF; i++) if (p->out_free[i] && p->out[i].valid) { id = i; p->out_free[i] = 0; break; }
        if (id >= 0) break;
        pthread_cond_wait(&p->cv, &p->mu);
    }
    pthread_mutex_unlock(&p->mu);
    return id;
}
static void dmabuf_sync(int fd, int end) {     // CPU access bracket for gralloc (ION/dma-buf) memory
    struct dma_buf_sync sy = { DMA_BUF_SYNC_WRITE | (end ? DMA_BUF_SYNC_END : DMA_BUF_SYNC_START) };
    ioctl(fd, DMA_BUF_IOCTL_SYNC, &sy);
}
static void store_nv12(const Pipe* p, const uint8_t* packed, const Buf* o) {   // packed (stride = w) -> buffer layout
    int stride = o->stride, scan = o->scan; uint8_t* dst = o->p;
    if (o->dmabuf) dmabuf_sync(o->fd, 0);
    if (stride == p->w) { memcpy(dst, packed, (size_t) p->w * p->h); memcpy(dst + (size_t) stride * scan, packed + (size_t) p->w * p->h, (size_t) p->w * (p->h / 2)); }
    else {
        for (int y = 0; y < p->h; y++) memcpy(dst + (size_t) y * stride, packed + (size_t) y * p->w, p->w);
        const uint8_t* uv = packed + (size_t) p->w * p->h; uint8_t* d = dst + (size_t) stride * scan;
        for (int y = 0; y < p->h / 2; y++) memcpy(d + (size_t) y * stride, uv + (size_t) y * p->w, p->w);
    }
    if (o->dmabuf) dmabuf_sync(o->fd, 1);
}
static void load_nv12(const Pipe* p, const uint8_t* src, uint8_t* packed) {
    for (int y = 0; y < p->h; y++) memcpy(packed + (size_t) y * p->w, src + (size_t) y * p->stride, p->w);
    const uint8_t* s = src + (size_t) p->stride * p->elev; uint8_t* uv = packed + (size_t) p->w * p->h;
    for (int y = 0; y < p->h / 2; y++) memcpy(uv + (size_t) y * p->w, s + (size_t) y * p->stride, p->w);
}
static int emit(Pipe* p, const uint8_t* packed, long long ts, int flag) {
    int id = take_out(p);
    if (id < 0) return -1;
    if (packed) store_nv12(p, packed, &p->out[id]);
    if (!p->n_out) p->t_first_out = k4n_now_ms();
    p->n_out++; p->t_last = k4n_now_ms();
    cb_send(p, 2, 3, id, ts, flag);
    return 0;
}

static void log_summary(Pipe* p, const char* why) {
    if (!p->n_in) return;
    double span = p->t_last - p->t_first_out;
    K4N_LOG("pipe summary (%s): neural, last factor x%d, %dx%d, %d in -> %d out (%d generated, %d repeated by the guard), %.1f fps out, "
            "first frame after %.0f ms (engine init %.0f ms), per pair: prep %.1f + inference %.1f ms, warp %.1f ms/frame, max mean flow %.1f px",
            why, p->factor, p->w, p->h, p->n_in, p->n_out, p->n_gen, p->n_repeat, span > 0 ? (p->n_out - 1) * 1000.0 / span : 0.0,
            p->t_first_out - p->t_first_in, p->t_init, p->n_in > 1 ? p->ms_prep / p->n_in : 0.0, p->n_in > 1 ? p->ms_inf / (p->n_in - 1) : 0.0,
            p->n_gen ? p->ms_warp / p->n_gen : 0.0, p->max_flow);
    p->n_in = p->n_out = p->n_gen = p->n_repeat = 0; p->ms_inf = p->ms_warp = p->ms_prep = 0; p->max_flow = 0;
}

static void* pipe_main(void* arg) {
    Pipe* p = arg; size_t fsz = (size_t) p->w * p->h * 3 / 2;
    uint8_t* gen = malloc(fsz);
    for (;;) {
        InItem it;
        pthread_mutex_lock(&p->mu);
        p->busy = 0; pthread_cond_broadcast(&p->cv);
        while (!p->quit && (p->qn == 0 || p->flushing)) pthread_cond_wait(&p->cv, &p->mu);
        if (p->quit) { pthread_mutex_unlock(&p->mu); break; }
        it = p->q[0]; memmove(p->q, p->q + 1, sizeof(InItem) * --p->qn); p->busy = 1;
        pthread_mutex_unlock(&p->mu);
        if (!p->n_in) p->t_first_in = k4n_now_ms();
        int marker_only = (it.flag & FLAG_EOS) && p->have_prev && it.ts <= p->prev_ts;    // end marker that repeats the last time stamp
        int bad = it.id < 0 || it.id >= MAXBUF || !p->in[it.id].valid;
        if (!marker_only && !bad) {
            double t0 = k4n_now_ms();
            load_nv12(p, p->in[it.id].p, p->cur);
            k4n_prep(p->ses, p->cur, p->w, p->ncur);
            p->ms_prep += k4n_now_ms() - t0;
        }
        cb_send(p, 1, 1, it.id, 0, 0);                                              // input buffer is free again
        if (bad) continue;
        p->n_in++;
        int failed = 0;
        if (!marker_only) {
            pthread_mutex_lock(&p->mu); int factor = p->factor; pthread_mutex_unlock(&p->mu);
            if (p->have_prev && factor > 1) {
                double ms[2] = { 0, 0 }; float src = 0, wrp = 0, flow = 0;
                int ok = k4n_infer(p->ses, p->nprev, p->ncur, ms) == 0;
                if (ok) { p->ms_inf += ms[0] + ms[1]; k4n_last_stats(p->ses, &src, &wrp, &flow); if (flow > p->max_flow) p->max_flow = flow; }
                // guard: scene cut or flows that do not explain the change -> repeat the nearer source frame
                // (PC calibration, 1080p: 22 good pairs src <= 0.066, warp/src 0.18..0.91; 8 scene cuts src >= 0.156, warp/src >= 0.94)
                int repeat = !ok || (src > 0.10f && wrp > 0.85f * src);
                if (k4n_verbose > 1) K4N_LOG("pair ts %lld..%lld: |src| %.4f |warp| %.4f flow %.2f px, inference %.1f+%.1f ms%s", p->prev_ts, it.ts, src, wrp, flow, ms[0], ms[1], repeat ? " -> REPEAT" : "");
                for (int k = 1; k < factor && !failed; k++) {
                    float t = (float) k / factor; long long ts = p->prev_ts + (it.ts - p->prev_ts) * k / factor;
                    if (repeat) { p->n_repeat++; failed = emit(p, t < 0.5f ? p->prev : p->cur, ts, FLAG_FRAME) < 0; }
                    else { double t0 = k4n_now_ms(); k4n_warp(p->ses, p->prev, p->cur, gen, t); p->ms_warp += k4n_now_ms() - t0; p->n_gen++; failed = emit(p, gen, ts, FLAG_FRAME) < 0; }
                }
            }
            if (!failed) failed = emit(p, p->cur, it.ts, FLAG_FRAME) < 0;
            uint8_t* t8 = p->prev; p->prev = p->cur; p->cur = t8; float* tf = p->nprev; p->nprev = p->ncur; p->ncur = tf;
            p->have_prev = 1; p->prev_ts = it.ts;
        }
        if ((it.flag & FLAG_EOS) && !failed) { emit(p, p->have_prev ? p->prev : NULL, it.ts, FLAG_EOS); log_summary(p, "end of stream"); }
    }
    free(gen);
    return NULL;
}

static void pipe_stop(Pipe* p) {
    pthread_mutex_lock(&p->mu); p->quit = 1; pthread_cond_broadcast(&p->cv); pthread_mutex_unlock(&p->mu);
    if (p->th_started) { pthread_join(p->th, NULL); p->th_started = 0; }
}
static void pipe_free_bufs(Pipe* p) {
    for (int i = 0; i < MAXBUF; i++) {
        if (p->in[i].valid) { munmap(p->in[i].p, p->in[i].size); close(p->in[i].fd); p->in[i].valid = 0; }
        if (p->out[i].valid) { munmap(p->out[i].p, p->out[i].size); close(p->out[i].fd); p->out[i].valid = 0; }
        p->out_free[i] = 0;
    }
}
static void pipe_destroy(void* ud) {
    Pipe* p = ud; if (!p) return;
    pipe_stop(p); log_summary(p, "pipe released"); engine_touch(-1);
    pipe_free_bufs(p);
    if (p->cb) AIBinder_decStrong(p->cb);
    k4n_session_destroy(p->ses); free(p->prev); free(p->cur); free(p->nprev); free(p->ncur);
    pthread_mutex_destroy(&p->mu); pthread_cond_destroy(&p->cv); free(p);
}

// SehBuffer { id, type, NativeHandle { fds[], ints[] }, size } as written by the V1/V5 clients.
// type 1: ashmem region (fd 0, size); type 2: gralloc buffer of the client's output window (Qualcomm private_handle_t:
// fd 0 = pixel memory, fd 1 = metadata; ints = magic, flags, aligned width, aligned height, width, height, format,
// buffer type, layers, id (2), usage (2), size, ...). Only linear NV12 is taken; it is mapped directly (the same memory the classic pipe locks through gralloc).
static int read_buffer(const AParcel* in, Buf* b, int* id, int* gstride, int* gscan) {
    int32_t nn = 0, size = 0, type = 0, hn = 0, hsize = 0, nfds = 0, nints = 0, bsize = 0, ints[40] = { 0 };
    AParcel_readInt32(in, &nn); if (!nn) return -1;
    int32_t start = AParcel_getDataPosition(in);
    AParcel_readInt32(in, &size); AParcel_readInt32(in, id); AParcel_readInt32(in, &type);
    AParcel_readInt32(in, &hn);
    int fd = -1;
    if (hn) {
        int32_t hstart = AParcel_getDataPosition(in);
        AParcel_readInt32(in, &hsize); AParcel_readInt32(in, &nfds);
        for (int i = 0; i < nfds; i++) { int f = -1; AParcel_readParcelFileDescriptor(in, &f); if (i == 0) fd = f; else if (f >= 0) close(f); }
        AParcel_readInt32(in, &nints);
        for (int i = 0; i < nints && i < 40; i++) AParcel_readInt32(in, &ints[i]);
        AParcel_setDataPosition(in, hstart + hsize);
    }
    AParcel_readInt32(in, &bsize);
    AParcel_setDataPosition(in, start + size);
    b->fd = fd; b->size = (size_t) bsize; b->valid = 0; *gstride = *gscan = 0;
    if (k4n_verbose > 1) {
        char t[512]; int n = 0; for (int i = 0; i < nints && i < 24; i++) n += snprintf(t + n, sizeof t - n, " %d", ints[i]);
        K4N_LOG("  buffer id %d type %d fds %d size %d ints(%d):%s", *id, type, nfds, bsize, nints, t);
    }
    if (type == 2 && fd >= 0 && nfds == 2 && nints >= 15 && ints[0] == GRALLOC_MAGIC) {
        int aw = ints[2], ah = ints[3], fmt = ints[6]; unsigned gsize = (unsigned) ints[GRALLOC_SIZE_INT];
        if (fmt == FMT_NV12 && aw > 0 && ah > 0 && gsize >= (unsigned) aw * ah * 3 / 2 && gsize < (64u << 20)) { b->size = gsize; *gstride = aw; *gscan = ah; return 0; }
        K4N_LOG("unsupported gralloc buffer: format 0x%x %dx%d size %u", fmt, aw, ah, gsize);
    }
    if (type != 1 || fd < 0 || bsize <= 0) { if (fd >= 0) close(fd); K4N_LOG("unsupported buffer (type %d, fds %d, ints %d, size %d)", type, nfds, nints, bsize); return -1; }
    return 0;
}

static binder_status_t mpp_tx(AIBinder* b, transaction_code_t code, const AParcel* in, AParcel* out) {
    Pipe* p = AIBinder_getUserData(b);
    int32_t a = 0, c = 0, d = 0; int64_t ts = 0;
    switch (code) {
    case 1: {   // init(SehMetadataInfo, SehRequestOutputInfo, ISehMppCallback) -> SehMetadataInfo
        int32_t nn = 0, size = 0, m[7] = { 0 }, r[3] = { 0 };
        AParcel_readInt32(in, &nn); int32_t st = AParcel_getDataPosition(in); AParcel_readInt32(in, &size);
        for (int i = 0; i < 7; i++) AParcel_readInt32(in, &m[i]);
        AParcel_setDataPosition(in, st + size);
        AParcel_readInt32(in, &nn); st = AParcel_getDataPosition(in); AParcel_readInt32(in, &size);
        for (int i = 0; i < 3 && i * 4 + 4 < size; i++) AParcel_readInt32(in, &r[i]);
        AParcel_setDataPosition(in, st + size);
        AIBinder* cb = NULL; AParcel_readStrongBinder(in, &cb);
        K4N_LOG("init: %dx%d stride %d elevation %d [4]=%d size %d colour format %d; requested %d %d format %d", m[0], m[1], m[2], m[3], m[4], m[5], m[6], r[0], r[1], r[2]);
        int w = m[0], h = m[1], stride = m[2] ? m[2] : m[0], elev = m[3] ? m[3] : m[1];
        const char* why = NULL; char err[256] = "";
        if (p->th_started) why = "already initialised";
        else if (m[6] != CF_NV12 || r[2] != CF_NV12) why = "colour format is not NV12";
        else if (w < 320 || h < 240 || (w > h ? w : h) > 1920 || (w > h ? h : w) > 1088 || (w & 1) || (h & 1) || stride < w || elev < h) why = "size not supported";
        else if (!cb || !AIBinder_associateClass(cb, cCb)) why = "no callback";
        else if (k4n_engine_init(&g_cfg, err, sizeof err)) why = err;
        if (why) { K4N_LOG("init refused: %s", why); if (cb) AIBinder_decStrong(cb); return write_err(out, -22); }
        p->cb = cb; p->w = w; p->h = h; p->stride = stride; p->elev = elev;
        p->factor = p->range_factor ? p->range_factor : 4;      // clients without range infos (probe): x4
        if (getenv("K4N_FACTOR")) p->factor = atoi(getenv("K4N_FACTOR"));
        size_t fsz = (size_t) w * h * 3 / 2;
        p->ses = k4n_session_create(w, h); p->prev = malloc(fsz); p->cur = malloc(fsz);
        p->nprev = malloc(sizeof(float) * 960 * 544); p->ncur = malloc(sizeof(float) * 960 * 544);
        pthread_create(&p->th, NULL, pipe_main, p); p->th_started = 1;
        write_ok(out); AParcel_writeInt32(out, 1); AParcel_writeInt32(out, 4 + 7 * 4);
        int32_t om[7] = { w, h, stride, elev, m[4], (int32_t) ((size_t) stride * elev * 3 / 2), CF_NV12 };
        for (int i = 0; i < 7; i++) AParcel_writeInt32(out, om[i]);
        return STATUS_OK; }
    case 2: {   // setBuffer(SehBufferType, SehBuffer[])
        int32_t type = 0, n = 0; AParcel_readInt32(in, &type); AParcel_readInt32(in, &n);
        if (!p->th_started) return write_err(out, -19);
        K4N_LOG("setBuffer: type %d, %d buffers", type, n);
        for (int i = 0; i < n; i++) {
            Buf nb; int id = -1, gs = 0, gh = 0;
            if (read_buffer(in, &nb, &id, &gs, &gh) || id < 0 || id >= MAXBUF) { K4N_LOG("setBuffer: buffer %d rejected", i); return write_err(out, -22); }
            nb.stride = gs ? gs : p->stride; nb.scan = gs ? gh : p->elev; nb.dmabuf = gs != 0;
            if ((gs && type == 0) || nb.stride < p->w || nb.scan < p->h || nb.size < (size_t) nb.stride * nb.scan + (size_t) nb.stride * (p->h / 2)) {
                K4N_LOG("setBuffer: buffer %d rejected (id %d size %zu stride %d scanlines %d)", i, id, nb.size, nb.stride, nb.scan); close(nb.fd); return write_err(out, -22); }
            nb.p = mmap(NULL, nb.size, PROT_READ | PROT_WRITE, MAP_SHARED, nb.fd, 0);
            if (nb.p == MAP_FAILED) { K4N_LOG("setBuffer: mmap failed: %s", strerror(errno)); close(nb.fd); return write_err(out, -12); }
            nb.valid = 1;
            pthread_mutex_lock(&p->mu);
            Buf* slot = type == 0 ? &p->in[id] : &p->out[id];
            if (slot->valid) { munmap(slot->p, slot->size); close(slot->fd); }
            *slot = nb;
            pthread_mutex_unlock(&p->mu);
        }
        write_ok(out); return STATUS_OK; }
    case 3:     // setParameter(key, value)
        AParcel_readInt32(in, &a); AParcel_readInt32(in, &c);
        K4N_LOG("setParameter(%d, %d)", a, c);
        write_ok(out); return STATUS_OK;
    case 4:     // emptyBuffer(id, timeUs, flag)
        AParcel_readInt32(in, &a); AParcel_readInt64(in, &ts); AParcel_readInt32(in, &c);
        if (!p->th_started) return write_err(out, -19);
        if (k4n_verbose > 1) K4N_LOG("emptyBuffer id %d ts %lld flag %d", a, (long long) ts, c);
        pthread_mutex_lock(&p->mu);
        if (p->qn < MAXBUF) { p->q[p->qn++] = (InItem) { a, ts, c }; d = 1; }
        pthread_cond_broadcast(&p->cv); pthread_mutex_unlock(&p->mu);
        if (!d) return write_err(out, -12);
        write_ok(out); return STATUS_OK;
    case 5:     // fillBuffer(id)
        AParcel_readInt32(in, &a);
        if (!p->th_started || a < 0 || a >= MAXBUF) return write_err(out, -22);
        pthread_mutex_lock(&p->mu); p->out_free[a] = 1; pthread_cond_broadcast(&p->cv); pthread_mutex_unlock(&p->mu);
        write_ok(out); return STATUS_OK;
    case 6: case 7: {   // flush / reset
        K4N_LOG(code == 6 ? "flush" : "reset");
        if (p->th_started) {
            // the worker gives up waiting for output buffers while flushing; wait until it is idle, then drop the queue
            InItem q[MAXBUF]; int n;
            pthread_mutex_lock(&p->mu);
            p->flushing = 1; pthread_cond_broadcast(&p->cv);
            while (p->busy) pthread_cond_wait(&p->cv, &p->mu);
            n = p->qn; memcpy(q, p->q, sizeof(InItem) * n); p->qn = 0;
            pthread_mutex_unlock(&p->mu);
            for (int i = 0; i < n; i++) cb_send(p, 1, 1, q[i].id, 0, 0);
            if (code == 7) {    // back to the state before init()
                pipe_stop(p); log_summary(p, "reset"); pipe_free_bufs(p);
                k4n_session_destroy(p->ses); p->ses = NULL; free(p->prev); free(p->cur); free(p->nprev); free(p->ncur); p->prev = p->cur = NULL; p->nprev = p->ncur = NULL;
                if (p->cb) { AIBinder_decStrong(p->cb); p->cb = NULL; }
                p->quit = 0;
            }
            pthread_mutex_lock(&p->mu); p->have_prev = 0; p->flushing = 0; pthread_cond_broadcast(&p->cv); pthread_mutex_unlock(&p->mu);
        }
        write_ok(out);
        if (code == 6) cb_send(p, 3, 0, 0, 0, 0);
        return STATUS_OK; }
    case 8:     // getBufferCount(SehBufferType)
        AParcel_readInt32(in, &a); write_ok(out); AParcel_writeInt32(out, a == 0 ? N_IN : N_OUT); return STATUS_OK;
    case 9:     // getBufferFormat(SehColorFormat)
        AParcel_readInt32(in, &a); if (a != CF_NV12) return write_err(out, -22);
        write_ok(out); AParcel_writeInt32(out, FMT_NV12); return STATUS_OK;
    case 10:    // getBufferSize(SehColorFormat, w, h)
        AParcel_readInt32(in, &a); AParcel_readInt32(in, &c); AParcel_readInt32(in, &d); if (a != CF_NV12) return write_err(out, -22);
        write_ok(out); AParcel_writeInt32(out, c * d * 3 / 2); return STATUS_OK;
    case TX_VERSION: write_ok(out); AParcel_writeInt32(out, g_version); return STATUS_OK;
    case TX_HASH: write_ok(out); AParcel_writeString(out, g_hash, (int32_t) strlen(g_hash)); return STATUS_OK;
    }
    {   // V5-only calls of the S26 client. The V1 answer stays "unknown transaction" (as from the classic pipe), but
        // 12 = setRangeInfos is used: it carries what SemMediaPlayer.setVideoFrc() asked for, as one range
        // { int64 start = 0, int64 end = max, int32 mode } with mode 7000 = no interpolation (hold released),
        // 7001 = x2, 7002 = x4. It comes before init() and again, followed by flush(), whenever the request changes.
        int32_t pos = AParcel_getDataPosition(in), size = parcel_getDataSize(in), v[24] = { 0 }; char t[400]; int n = 0;
        for (int i = 0; i < 24 && pos + i * 4 < size; i++) { AParcel_readInt32(in, &v[i]); n += snprintf(t + n, sizeof t - n, " %x", v[i]); }
        if (code == 12 && size - pos >= 32 && v[0] >= 1 && v[2] >= 0x18 && v[7] >= 7000 && v[7] <= 7002) {
            int f = v[7] == 7002 ? 4 : v[7] == 7001 ? 2 : 1;
            pthread_mutex_lock(&p->mu); p->range_factor = f; if (p->th_started && !getenv("K4N_FACTOR")) p->factor = f; pthread_mutex_unlock(&p->mu);
            K4N_LOG("range info: mode %d -> %s", v[7], f == 4 ? "x4 (0.25x)" : f == 2 ? "x2 (0.5x)" : "pass-through");
        } else if (k4n_verbose) K4N_LOG("pipe: unknown transaction %u, %d bytes:%s", code, size - pos, n ? t : "");
    }
    return STATUS_UNKNOWN_TRANSACTION;
}

// ---------------------------------------------------------------------------------------------------------------
// Diagnostic "spy" pipe (K4N_MODE=-1): a transparent proxy in front of a classic pipe that logs every transaction and
// every callback with a time stamp. Used to compare the classic pipe's behaviour with ours.
typedef struct { AIBinder* target; AIBinder* client_cb; AIBinder* my_cb; double t0; int nfill, nout, nin; } Spy;
static AIBinder_Class *cSpy, *cSpyCb;
static void peek(const AParcel* p, int32_t pos, int32_t* v, int n) { int32_t save = AParcel_getDataPosition(p); AParcel_setDataPosition(p, pos); for (int i = 0; i < n; i++) { v[i] = 0; AParcel_readInt32(p, &v[i]); } AParcel_setDataPosition(p, save); }
static binder_status_t spycb_tx(AIBinder* b, transaction_code_t code, const AParcel* in, AParcel* out) {
    (void) out; Spy* s = AIBinder_getUserData(b); int32_t v[4] = { 0 }; int32_t pos = AParcel_getDataPosition(in), size = parcel_getDataSize(in);
    peek(in, pos, v, 4);
    if (code == 2) { long long ts = ((long long) (uint32_t) v[1]) | ((long long) v[2] << 32); K4N_LOG("SPY %8.1f cb onFillBufferDone #%d id %d ts %lld flag %d", k4n_now_ms() - s->t0, s->nout++, v[0], ts, v[3]); }
    else K4N_LOG("SPY %8.1f cb %s(%d) [%d bytes]", k4n_now_ms() - s->t0, code == 1 ? "onEmptyBufferDone" : code == 3 ? "onFlushDone" : code == 4 ? "onError" : "?", v[0], size - pos);
    AParcel *fin = NULL, *fout = NULL;
    if (s->client_cb && AIBinder_prepareTransaction(s->client_cb, &fin) == STATUS_OK) { if (size > pos) parcel_appendFrom(in, fin, pos, size - pos); AIBinder_transact(s->client_cb, code, &fin, &fout, FLAG_ONEWAY); }
    if (fin) AParcel_delete(fin);
    if (fout) AParcel_delete(fout);
    return STATUS_OK;
}
static binder_status_t spy_tx(AIBinder* b, transaction_code_t code, const AParcel* in, AParcel* out) {
    Spy* s = AIBinder_getUserData(b); int32_t v[6] = { 0 }; int32_t pos = AParcel_getDataPosition(in), size = parcel_getDataSize(in);
    static const char* names[] = { "?", "init", "setBuffer", "setParameter", "emptyBuffer", "fillBuffer", "flush", "reset", "getBufferCount", "getBufferFormat", "getBufferSize" };
    peek(in, pos, v, 6);
    AParcel *fin = NULL, *fout = NULL; binder_status_t st = AIBinder_prepareTransaction(s->target, &fin);
    if (st != STATUS_OK) return st;
    if (code == 1) {    // init: swap the callback for ours
        int32_t nn = 0, sz = 0; AParcel_readInt32(in, &nn); int32_t p0 = AParcel_getDataPosition(in); AParcel_readInt32(in, &sz); AParcel_setDataPosition(in, p0 + sz);
        AParcel_readInt32(in, &nn); p0 = AParcel_getDataPosition(in); AParcel_readInt32(in, &sz); AParcel_setDataPosition(in, p0 + sz);
        int32_t cbpos = AParcel_getDataPosition(in);
        AParcel_readStrongBinder(in, &s->client_cb); if (s->client_cb) AIBinder_associateClass(s->client_cb, cCb);
        s->my_cb = AIBinder_new(cSpyCb, s); markVintf(s->my_cb);
        parcel_appendFrom(in, fin, pos, cbpos - pos); AParcel_writeStrongBinder(fin, s->my_cb);
    } else if (size > pos) parcel_appendFrom(in, fin, pos, size - pos);
    double t = k4n_now_ms();
    st = AIBinder_transact(s->target, code, &fin, &fout, 0);
    int32_t r[3] = { -1, -1, -1 }; int32_t rsize = 0;
    if (st == STATUS_OK && fout) { rsize = parcel_getDataSize(fout); peek(fout, 0, r, 3); if (rsize > 0) parcel_appendFrom(fout, out, 0, rsize); }
    if (code == 4) { long long ts = ((long long) (uint32_t) v[1]) | ((long long) v[2] << 32); K4N_LOG("SPY %8.1f emptyBuffer #%d id %d ts %lld flag %d -> st %d ex %d (%.1f ms)", t - s->t0, s->nin++, v[0], ts, v[3], st, r[0], k4n_now_ms() - t); }
    else if (code == 5) { K4N_LOG("SPY %8.1f fillBuffer #%d id %d -> st %d ex %d", t - s->t0, s->nfill++, v[0], st, r[0]); }
    else K4N_LOG("SPY %8.1f %s(%u) args %d %d %d %d [%d bytes] -> st %d, reply [%d bytes] %d %d %d (%.1f ms)", t - s->t0, code <= 10 ? names[code] : "tx", code, v[0], v[1], v[2], v[3], size - pos, st, rsize, r[0], r[1], r[2], k4n_now_ms() - t);
    if (fin) AParcel_delete(fin);
    if (fout) AParcel_delete(fout);
    return st;
}
static void spy_destroy(void* ud) { Spy* s = ud; if (!s) return; K4N_LOG("SPY pipe released: %d in, %d fill, %d out", s->nin, s->nfill, s->nout); if (s->target) AIBinder_decStrong(s->target); if (s->client_cb) AIBinder_decStrong(s->client_cb); free(s); }
static int spy_create(int32_t type, AParcel* out) {
    AParcel *fin = NULL, *fout = NULL; AStatus* st = NULL; AIBinder* target = NULL; int ok = 0;
    AIBinder* stock = stock_get(); if (!stock) return 0;
    if (AIBinder_prepareTransaction(stock, &fin) == STATUS_OK) { AParcel_writeInt32(fin, type);
        if (AIBinder_transact(stock, 1, &fin, &fout, 0) == STATUS_OK && fout && AParcel_readStatusHeader(fout, &st) == STATUS_OK && AStatus_isOk(st)) AParcel_readStrongBinder(fout, &target); }
    if (st) AStatus_delete(st);
    if (fin) AParcel_delete(fin);
    if (fout) AParcel_delete(fout);
    AIBinder_decStrong(stock);
    if (target && AIBinder_associateClass(target, cMpp)) {
        Spy* s = calloc(1, sizeof *s); s->target = target; s->t0 = k4n_now_ms();
        AIBinder* mb = AIBinder_new(cSpy, s); if (g_vintf) markVintf(mb);
        write_ok(out); AParcel_writeStrongBinder(out, mb); AIBinder_decStrong(mb); ok = 1;
        K4N_LOG("SPY create(type %d): proxy in front of the classic pipe", type);
    } else if (target) AIBinder_decStrong(target);
    return ok;
}

// ---------------------------------------------------------------------------------------------------------------
static binder_status_t forward(transaction_code_t code, const AParcel* in, AParcel* out) {
    AIBinder* stock = stock_get();
    if (!stock) return STATUS_DEAD_OBJECT;
    AParcel *fin = NULL, *fout = NULL; int stage = 0;
    binder_status_t st = AIBinder_prepareTransaction(stock, &fin);
    if (st == STATUS_OK) { stage = 1; int32_t pos = AParcel_getDataPosition(in), size = parcel_getDataSize(in); if (size > pos) st = parcel_appendFrom(in, fin, pos, size - pos); }
    if (st == STATUS_OK) { stage = 2; st = AIBinder_transact(stock, code, &fin, &fout, 0); }
    if (st == STATUS_OK && fout) { stage = 3; int32_t size = parcel_getDataSize(fout); if (size > 0) st = parcel_appendFrom(fout, out, 0, size); }
    if (st != STATUS_OK) K4N_LOG("forward(%u) failed at stage %d: %d", code, stage, st);
    if (fin) AParcel_delete(fin);
    if (fout) AParcel_delete(fout);
    AIBinder_decStrong(stock);
    return st;
}
static void* warm_main(void* a) { (void) a; if (neural_mode() > 0) { engine_touch(0); k4n_engine_init(&g_cfg, NULL, 0); engine_touch(0); } return NULL; }
static void* idle_main(void* a) {
    (void) a; double idle_ms = (getenv("K4N_IDLE_S") ? atof(getenv("K4N_IDLE_S")) : 120.0) * 1000.0;
    for (;;) {
        sleep(5);
        pthread_mutex_lock(&g_use_mu);
        if (g_live_pipes == 0 && k4n_now_ms() - g_last_use > idle_ms) k4n_engine_release();     // no-op when it is not built
        pthread_mutex_unlock(&g_use_mu);
    }
    return NULL;
}
static binder_status_t store_tx(AIBinder* b, transaction_code_t code, const AParcel* in, AParcel* out) {
    (void) b;
    if (code == 3 && neural_mode() > 0 && !k4n_engine_ready()) {     // getCapabilityByType(FRC): a player is getting ready to interpolate
        int32_t pos = AParcel_getDataPosition(in), type = 0; AParcel_readInt32(in, &type); AParcel_setDataPosition(in, pos);
        if (type == TYPE_FRC) { pthread_t t; pthread_attr_t at; pthread_attr_init(&at); pthread_attr_setdetachstate(&at, PTHREAD_CREATE_DETACHED); pthread_create(&t, &at, warm_main, NULL); }
    }
    if (code == TX_K4_WARMUP) { pthread_t t; pthread_attr_t at; pthread_attr_init(&at); pthread_attr_setdetachstate(&at, PTHREAD_CREATE_DETACHED); pthread_create(&t, &at, warm_main, NULL); return STATUS_OK; }
    if (code == 1) {
        int32_t pos = AParcel_getDataPosition(in), type = 0; AParcel_readInt32(in, &type); AParcel_setDataPosition(in, pos);
        int mode = neural_mode(); char err[256] = "";
        if (mode == -1 && type == TYPE_FRC && spy_create(type, out)) return STATUS_OK;
        if (type == TYPE_FRC && mode > 0) {
            pthread_mutex_lock(&g_use_mu); g_live_pipes++; g_last_use = k4n_now_ms(); pthread_mutex_unlock(&g_use_mu);     // keeps the idle release away
            double t0 = k4n_now_ms(); int warm = k4n_engine_ready();
            if (k4n_engine_init(&g_cfg, err, sizeof err) == 0) {
                Pipe* p = calloc(1, sizeof *p); pthread_mutex_init(&p->mu, NULL); pthread_cond_init(&p->cv, NULL); p->t_init = k4n_now_ms() - t0;
                AIBinder* mb = AIBinder_new(cMpp, p); if (g_vintf) markVintf(mb);
                write_ok(out); AParcel_writeStrongBinder(out, mb); AIBinder_decStrong(mb);
                K4N_LOG("hold: neural pipe (persist.sys.k4.slowmo_neural=%d, engine %s)", mode, warm ? "was warm" : "built now");
                return STATUS_OK;
            }
            engine_touch(-1);
            K4N_LOG("hold: classic pipe (neural engine not available: %s)", err);
        } else if (type == TYPE_FRC) K4N_LOG("hold: classic pipe (persist.sys.k4.slowmo_neural is off)");
    }
    return forward(code, in, out);
}
static void* cls_create(void* a) { return a; }
static void cls_destroy_none(void* a) { (void) a; }
static binder_status_t tx_none(AIBinder* b, transaction_code_t c, const AParcel* i, AParcel* o) { (void) b; (void) c; (void) i; (void) o; return STATUS_UNKNOWN_TRANSACTION; }

static bool hash_alloc(void* data, int32_t length, char** buffer) { if (length <= 0 || length > (int32_t) sizeof g_hash) return false; *buffer = data; return true; }
static void query_stock_meta(AIBinder* stock) {
    for (int k = 0; k < 2; k++) {
        AParcel *in = NULL, *out = NULL; AStatus* st = NULL;
        if (AIBinder_prepareTransaction(stock, &in) == STATUS_OK && AIBinder_transact(stock, k ? TX_HASH : TX_VERSION, &in, &out, 0) == STATUS_OK && out &&
            AParcel_readStatusHeader(out, &st) == STATUS_OK && AStatus_isOk(st)) {
            if (!k) AParcel_readInt32(out, &g_version);
            else AParcel_readString(out, g_hash, hash_alloc);
        }
        if (st) AStatus_delete(st);
        if (in) AParcel_delete(in);
        if (out) AParcel_delete(out);
    }
    K4N_LOG("classic store %s: interface version %d, hash %s", g_stock_name, g_version, g_hash[0] ? g_hash : "(none)");
}
// The classic store, looked up when first needed and again after it died. NULL = not reachable right now.
static void stock_died(void* cookie) { (void) cookie; pthread_mutex_lock(&g_stock_mu); if (g_stock) { AIBinder_decStrong(g_stock); g_stock = NULL; } pthread_mutex_unlock(&g_stock_mu); K4N_LOG("classic store died"); }
static AIBinder* stock_get(void) {
    static AIBinder_DeathRecipient* dr;
    pthread_mutex_lock(&g_stock_mu);
    if (!g_stock) {
        AIBinder* s = sm_waitForService(g_stock_name);
        if (s && AIBinder_associateClass(s, cStore)) {
            g_stock = s; if (!dr) dr = AIBinder_DeathRecipient_new(stock_died);
            AIBinder_linkToDeath(s, dr, NULL); query_stock_meta(s);
        } else { K4N_LOG("classic store %s is not usable", g_stock_name); if (s) AIBinder_decStrong(s); }
    }
    AIBinder* r = g_stock; if (r) AIBinder_incStrong(r);
    pthread_mutex_unlock(&g_stock_mu);
    return r;
}

int main(int argc, char** argv) {
    const char *serve = NULL, *stock = NULL;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-v")) k4n_verbose++;
        else if (!strcmp(argv[i], "--serve") && i + 1 < argc) serve = argv[++i];
        else if (!strcmp(argv[i], "--stock") && i + 1 < argc) stock = argv[++i];
        else if (!strcmp(argv[i], "--libdir") && i + 1 < argc) g_cfg.libdir = argv[++i];
        else if (!strcmp(argv[i], "--datadir") && i + 1 < argc) g_cfg.datadir = argv[++i];
        else if (!strcmp(argv[i], "--runtime") && i + 1 < argc) g_cfg.runtime = atoi(argv[++i]);
        else serve = NULL, i = argc;
    }
    if (!serve || !stock || !strcmp(serve, stock)) { fprintf(stderr, "usage: %s --serve NAME --stock NAME [-v] [--libdir D] [--datadir D] [--runtime 2|3|1|0]\n", argv[0]); return 1; }
    signal(SIGPIPE, SIG_IGN);
    void* nb = dlopen("libbinder_ndk.so", RTLD_NOW);
#define NB(var, name) var = dlsym(nb, name); if (!var) { K4N_LOG("libbinder_ndk: no %s", name); return 2; }
    NB(sm_waitForService, "AServiceManager_waitForService") NB(sm_addService, "AServiceManager_addService")
    NB(markVintf, "AIBinder_markVintfStability") NB(parcel_appendFrom, "AParcel_appendFrom") NB(parcel_getDataSize, "AParcel_getDataSize")
    NB(pool_setMax, "ABinderProcess_setThreadPoolMaxThreadCount") NB(pool_start, "ABinderProcess_startThreadPool") NB(pool_join, "ABinderProcess_joinThreadPool")
    cStore = AIBinder_Class_define(STORE, cls_create, cls_destroy_none, store_tx);
    cMpp = AIBinder_Class_define(MPP, cls_create, pipe_destroy, mpp_tx);
    cCb = AIBinder_Class_define(CB, cls_create, cls_destroy_none, tx_none);
    cSpy = AIBinder_Class_define(MPP, cls_create, spy_destroy, spy_tx); cSpyCb = AIBinder_Class_define(CB, cls_create, cls_destroy_none, spycb_tx);
    pool_setMax(4); pool_start();
    // Register first and never exit afterwards: the system MPP client blocks in waitForService() for a declared
    // instance, so this process has to be there even when the classic store or the neural engine is not.
    g_stock_name = stock;
    g_vintf = !getenv("K4N_NO_VINTF");      // test registrations under a name that is not in the VINTF manifest
    AIBinder* self = AIBinder_new(cStore, NULL); if (g_vintf) markVintf(self);
    binder_exception_t e = sm_addService(self, serve);
    K4N_LOG("k4neuralmpp: serving %s (%d), classic store %s; neural FRC mode %d; libs %s, model %s, runtime %d", serve, e, stock,
            neural_mode(), g_cfg.libdir, g_cfg.datadir, g_cfg.runtime);
    for (int i = 0; e && i < 60; i++) { sleep(2); e = sm_addService(self, serve); if (!e) K4N_LOG("k4neuralmpp: registered %s after %d retries", serve, i + 1); }
    if (e) K4N_LOG("k4neuralmpp: could not register %s (%d); staying up without a registration", serve, e);
    { pthread_t t; pthread_create(&t, NULL, idle_main, NULL); }
    pool_join();
    return 0;
}
