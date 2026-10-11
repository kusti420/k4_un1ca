// K4 neural frame interpolation engine: the recovered Samsung AIFRC v3 flow network (SNPE, Hexagon HTP in an
// unsigned PD) + warp/blend of the two neighbour frames on the CPU. Plain C, no SDK headers (prototypes are the
// public SNPE C API). See NOTES.md in this directory for the maths (PixelShuffle + Fusion4 of libaifrc.quram.so).
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <dlfcn.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>
#include "k4n.h"

#define NW 960
#define NH 544
#define FMC 20

double k4n_now_ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000.0 + t.tv_nsec / 1e6; }

// ---------------------------------------------------------------------------------------------------------------
// SNPE
typedef void* H;
static struct {
    void* lib;
    H container, snpe, in0, in1, inmap;
    float *p0, *p1;
    int runtime;
    H (*TensorMap_Create)(void); int (*TensorMap_Delete)(H); int (*TensorMap_Add)(H, const char*, H);
    H (*TensorMap_GetTensor_Ref)(H, const char*);
    void* (*ITensor_GetData)(H); size_t (*ITensor_GetSize)(H); int (*ITensor_Delete)(H);
    int (*SNPE_ExecuteITensors)(H, H, H); int (*SNPE_Delete)(H); int (*DlContainer_Delete)(H);
    const char* (*LastError)(void);
} S;
static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;
static int g_state;            // 0 = not built, 1 = ready, -1 = failed (retried after K4N_RETRY_MS)
static double g_failed_at;
#define K4N_RETRY_MS 30000.0
static char g_err[256];

#define SYM(ret, var, name, args) ret (*var) args = (ret (*) args) dlsym(S.lib, name); \
    if (!var) { snprintf(g_err, sizeof g_err, "libSNPE: missing %s", name); return -1; }

static int snpe_build(const char* dir, int runtime) {
    char path[512];
    SYM(H, DlContainer_Open, "Snpe_DlContainer_Open", (const char*))
    SYM(H, Builder_Create, "Snpe_SNPEBuilder_Create", (H))
    SYM(int, Builder_Delete, "Snpe_SNPEBuilder_Delete", (H))
    SYM(H, RuntimeList_Create, "Snpe_RuntimeList_Create", (void))
    SYM(int, RuntimeList_Add, "Snpe_RuntimeList_Add", (H, int))
    SYM(int, RuntimeList_Delete, "Snpe_RuntimeList_Delete", (H))
    SYM(int, SetRuntimeOrder, "Snpe_SNPEBuilder_SetRuntimeProcessorOrder", (H, H))
    SYM(int, SetPerf, "Snpe_SNPEBuilder_SetPerformanceProfile", (H, int))
    SYM(int, SetUB, "Snpe_SNPEBuilder_SetUseUserSuppliedBuffers", (H, int))
    SYM(H, Build, "Snpe_SNPEBuilder_Build", (H))
    SYM(H, GetInputDimensions, "Snpe_SNPE_GetInputDimensions", (H, const char*))
    SYM(int, TensorShape_Delete, "Snpe_TensorShape_Delete", (H))
    SYM(H, CreateITensor, "Snpe_Util_CreateITensor", (H))
    SYM(int, IsRuntimeAvailable, "Snpe_Util_IsRuntimeAvailable", (int))
    S.TensorMap_Create = (H (*)(void)) dlsym(S.lib, "Snpe_TensorMap_Create");
    S.TensorMap_Delete = (int (*)(H)) dlsym(S.lib, "Snpe_TensorMap_Delete");
    S.TensorMap_Add = (int (*)(H, const char*, H)) dlsym(S.lib, "Snpe_TensorMap_Add");
    S.TensorMap_GetTensor_Ref = (H (*)(H, const char*)) dlsym(S.lib, "Snpe_TensorMap_GetTensor_Ref");
    S.ITensor_GetData = (void* (*)(H)) dlsym(S.lib, "Snpe_ITensor_GetData");
    S.ITensor_GetSize = (size_t (*)(H)) dlsym(S.lib, "Snpe_ITensor_GetSize");
    S.ITensor_Delete = (int (*)(H)) dlsym(S.lib, "Snpe_ITensor_Delete");
    S.SNPE_ExecuteITensors = (int (*)(H, H, H)) dlsym(S.lib, "Snpe_SNPE_ExecuteITensors");
    S.SNPE_Delete = (int (*)(H)) dlsym(S.lib, "Snpe_SNPE_Delete");
    S.DlContainer_Delete = (int (*)(H)) dlsym(S.lib, "Snpe_DlContainer_Delete");
    S.LastError = (const char* (*)(void)) dlsym(S.lib, "Snpe_ErrorCode_GetLastErrorString");
    if (!S.TensorMap_Create || !S.TensorMap_Delete || !S.TensorMap_Add || !S.TensorMap_GetTensor_Ref || !S.ITensor_GetData ||
        !S.ITensor_GetSize || !S.SNPE_ExecuteITensors || !S.LastError) { snprintf(g_err, sizeof g_err, "libSNPE: missing symbols"); return -1; }
    if (!IsRuntimeAvailable(runtime)) { snprintf(g_err, sizeof g_err, "SNPE runtime %d is not available", runtime); return -1; }
    snprintf(path, sizeof path, "%s/%s", dir, runtime == 2 ? "k4n_v3_htp.dlc" : "k4n_v3_gpu.dlc");
    S.container = DlContainer_Open(path);
    if (!S.container) { snprintf(g_err, sizeof g_err, "cannot open %s: %.120s", path, S.LastError()); return -1; }
    H b = Builder_Create(S.container), rl = RuntimeList_Create();
    RuntimeList_Add(rl, runtime); SetRuntimeOrder(b, rl); SetPerf(b, 5 /* burst */); SetUB(b, 0);
    S.snpe = Build(b);
    RuntimeList_Delete(rl); Builder_Delete(b);
    if (!S.snpe) { snprintf(g_err, sizeof g_err, "SNPE build failed (runtime %d): %.160s", runtime, S.LastError()); return -1; }
    S.inmap = S.TensorMap_Create();
    for (int i = 0; i < 2; i++) {
        const char* nm = i ? "INPUT_1" : "INPUT_0";
        H sh = GetInputDimensions(S.snpe, nm);
        if (!sh) { snprintf(g_err, sizeof g_err, "model has no input %s", nm); return -1; }
        H t = CreateITensor(sh); TensorShape_Delete(sh);
        if (!t || S.ITensor_GetSize(t) != (size_t) NW * NH) { snprintf(g_err, sizeof g_err, "unexpected size of %s", nm); return -1; }
        S.TensorMap_Add(S.inmap, nm, t);
        if (i) { S.in1 = t; S.p1 = (float*) S.ITensor_GetData(t); } else { S.in0 = t; S.p0 = (float*) S.ITensor_GetData(t); }
    }
    S.runtime = runtime;
    return 0;
}

static void snpe_drop(void) {       // caller holds g_lock
    if (S.snpe && S.SNPE_Delete) S.SNPE_Delete(S.snpe);
    if (S.inmap) S.TensorMap_Delete(S.inmap);
    if (S.in0 && S.ITensor_Delete) S.ITensor_Delete(S.in0);
    if (S.in1 && S.ITensor_Delete) S.ITensor_Delete(S.in1);
    if (S.container && S.DlContainer_Delete) S.DlContainer_Delete(S.container);
    S.snpe = S.inmap = S.in0 = S.in1 = S.container = NULL; S.p0 = S.p1 = NULL;
}
int k4n_engine_init(const K4nConfig* cfg, char* err, size_t errlen) {
    pthread_mutex_lock(&g_lock);
    if (g_state == 0 || (g_state == -1 && k4n_now_ms() - g_failed_at > K4N_RETRY_MS)) {
        double t0 = k4n_now_ms();
        char path[512];
        g_state = -1;
        if (!S.lib) {
            // the HTP stub is found by libSNPE through dlopen("libSnpeHtpV68Stub.so"): load it by path first
            snprintf(path, sizeof path, "%s/libSnpeHtpV68Stub.so", cfg->libdir);
            void* stub = dlopen(path, RTLD_NOW | RTLD_GLOBAL);
            if (!stub && cfg->runtime == 2) snprintf(g_err, sizeof g_err, "dlopen libSnpeHtpV68Stub.so: %.160s", dlerror());
            else { snprintf(path, sizeof path, "%s/libSNPE.so", cfg->libdir); S.lib = dlopen(path, RTLD_NOW | RTLD_GLOBAL);
                   if (!S.lib) snprintf(g_err, sizeof g_err, "dlopen %s: %.160s", path, dlerror()); }
        }
        if (S.lib) { if (snpe_build(cfg->datadir, cfg->runtime) == 0) g_state = 1; else snpe_drop(); }
        if (g_state != 1) g_failed_at = k4n_now_ms();
        K4N_LOG("engine init %s in %.0f ms (runtime %d)%s%s", g_state == 1 ? "ok" : "FAILED", k4n_now_ms() - t0, cfg->runtime,
                g_state == 1 ? "" : ": ", g_state == 1 ? "" : g_err);
    }
    int r = g_state == 1 ? 0 : -1;
    if (r && err) snprintf(err, errlen, "%s", g_err);
    pthread_mutex_unlock(&g_lock);
    return r;
}
int k4n_engine_ready(void) { pthread_mutex_lock(&g_lock); int r = g_state == 1; pthread_mutex_unlock(&g_lock); return r; }
void k4n_engine_release(void) {
    pthread_mutex_lock(&g_lock);
    if (g_state == 1) { snpe_drop(); g_state = 0; K4N_LOG("engine released (idle)"); }
    pthread_mutex_unlock(&g_lock);
}

// ---------------------------------------------------------------------------------------------------------------
// worker pool
#define MAXT 8
typedef void (*JobFn)(void* ctx, int part, int parts);
static struct { pthread_t th[MAXT]; int n; pthread_mutex_t mu; pthread_cond_t cv, done; JobFn fn; void* ctx; int gen, pending, parts; int taken; } P = {
    .mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER, .done = PTHREAD_COND_INITIALIZER };
static void* pool_main(void* a) {
    (void) a; int seen = 0;
    pthread_mutex_lock(&P.mu);
    for (;;) {
        while (P.gen == seen || P.taken >= P.parts) { if (P.gen != seen && P.taken >= P.parts) seen = P.gen; pthread_cond_wait(&P.cv, &P.mu); }
        int part = P.taken++; JobFn fn = P.fn; void* ctx = P.ctx; int parts = P.parts;
        pthread_mutex_unlock(&P.mu);
        fn(ctx, part, parts);
        pthread_mutex_lock(&P.mu);
        if (--P.pending == 0) pthread_cond_signal(&P.done);
    }
    return NULL;
}
static void pool_run(JobFn fn, void* ctx) {
    pthread_mutex_lock(&P.mu);
    if (!P.n) { int n = (int) sysconf(_SC_NPROCESSORS_ONLN); n = n > 6 ? 6 : (n < 1 ? 1 : n); for (int i = 0; i < n; i++) pthread_create(&P.th[i], NULL, pool_main, NULL); P.n = n; }
    // more parts than threads: the big cores take more of them than the little ones
    P.fn = fn; P.ctx = ctx; P.parts = P.n * 4; P.pending = P.parts; P.taken = 0; P.gen++;
    pthread_cond_broadcast(&P.cv);
    while (P.pending) pthread_cond_wait(&P.done, &P.mu);
    pthread_mutex_unlock(&P.mu);
}

// ---------------------------------------------------------------------------------------------------------------
// geometry: the network always sees a 960x544 landscape luma image; portrait frames are fed transposed.
struct K4nSession {
    int w, h, portrait, gw, gh;        // gw x gh: flow grid in image orientation (960x544 or 544x960)
    float s;                            // image pixels per grid cell
    int *xi, *yi; uint8_t *xw, *yw;     // net input sampling tables (along the long/short image side)
    int *ci; uint16_t *cw;              // output column -> grid column index / weight (Q8)
    int16_t* F[4];                      // dx0, dy0, dx1, dy1 at grid points, image orientation, Q4 image pixels
    uint8_t* A;                         // sigmoid(mask) at grid points, Q8 (0..255)
    float last_src, last_warp, last_flow;
};

K4nSession* k4n_session_create(int w, int h) {
    K4nSession* s = calloc(1, sizeof *s);
    s->w = w; s->h = h; s->portrait = h > w;
    int lw = s->portrait ? h : w, lh = s->portrait ? w : h;
    float sx = lw / (float) NW, sy = lh / (float) NH;
    s->s = sx > sy ? sx : sy;
    s->gw = s->portrait ? NH : NW; s->gh = s->portrait ? NW : NH;
    s->xi = malloc(sizeof(int) * NW); s->xw = malloc(NW); s->yi = malloc(sizeof(int) * NH); s->yw = malloc(NH);
    for (int u = 0; u < NW; u++) { float X = (u + 0.5f) * s->s - 0.5f; if (X < 0) X = 0; if (X > lw - 1) X = lw - 1; int i = (int) X; if (i > lw - 2) i = lw - 2; s->xi[u] = i; s->xw[u] = (uint8_t) lrintf((X - i) * 128); }
    for (int v = 0; v < NH; v++) { float Y = (v + 0.5f) * s->s - 0.5f; if (Y < 0) Y = 0; if (Y > lh - 1) Y = lh - 1; int i = (int) Y; if (i > lh - 2) i = lh - 2; s->yi[v] = i; s->yw[v] = (uint8_t) lrintf((Y - i) * 128); }
    s->ci = malloc(sizeof(int) * w); s->cw = malloc(sizeof(uint16_t) * w);
    for (int x = 0; x < w; x++) { float g = x / s->s; int i = (int) g; if (i > s->gw - 1) i = s->gw - 1; s->ci[x] = i; s->cw[x] = (uint16_t) lrintf((g - i) * 256); if (i >= s->gw - 1) s->cw[x] = 0; }
    for (int k = 0; k < 4; k++) s->F[k] = malloc(sizeof(int16_t) * NW * NH);
    s->A = malloc(NW * NH);
    return s;
}
void k4n_session_destroy(K4nSession* s) {
    if (!s) return;
    free(s->xi); free(s->xw); free(s->yi); free(s->yw); free(s->ci); free(s->cw);
    for (int k = 0; k < 4; k++) free(s->F[k]);
    free(s->A); free(s);
}

// luma -> network input (float 0..1, 960x544), bilinear at the tabulated positions (exact 2x2 mean at 1080p)
typedef struct { const K4nSession* s; const uint8_t* y; int stride; float* out; } PrepJob;
static void prep_part(void* c, int part, int parts) {
    PrepJob* j = c; const K4nSession* s = j->s;
    int v0 = NH * part / parts, v1 = NH * (part + 1) / parts;
    for (int v = v0; v < v1; v++) {
        float* o = j->out + (size_t) v * NW; int wy = s->yw[v], iy = s->yi[v];
        if (!s->portrait) {
            const uint8_t* r0 = j->y + (size_t) iy * j->stride; const uint8_t* r1 = r0 + j->stride;
            for (int u = 0; u < NW; u++) { int ix = s->xi[u], wx = s->xw[u];
                int a = r0[ix] * (128 - wx) + r0[ix + 1] * wx, b = r1[ix] * (128 - wx) + r1[ix + 1] * wx;
                o[u] = (a * (128 - wy) + b * wy) * (1.0f / (255.0f * 16384.0f)); }
        } else {    // transposed: net (u, v) = image (y, x)
            for (int u = 0; u < NW; u++) { int ix = s->xi[u], wx = s->xw[u];      // ix: image row, iy: image column
                const uint8_t* r0 = j->y + (size_t) ix * j->stride + iy; const uint8_t* r1 = r0 + j->stride;
                int a = r0[0] * (128 - wx) + r1[0] * wx, b = r0[1] * (128 - wx) + r1[1] * wx;
                o[u] = (a * (128 - wy) + b * wy) * (1.0f / (255.0f * 16384.0f)); }
        }
    }
}
void k4n_prep(const K4nSession* s, const uint8_t* y, int stride, float* net) {
    PrepJob j = { s, y, stride, net }; pool_run(prep_part, &j);
}

// one inference: prev/next network inputs -> flow grid of this session. Returns 0, or -1 when the engine failed.
#define SIG_N 2048                  // sigmoid over [-16, 16), 255 * value
static uint8_t g_sig[SIG_N]; static pthread_once_t g_sig_once = PTHREAD_ONCE_INIT;
static void sig_init(void) { for (int i = 0; i < SIG_N; i++) g_sig[i] = (uint8_t) lrintf(255.0f / (1.0f + expf(-(i * (32.0f / SIG_N) - 16.0f)))); }
typedef struct { K4nSession* s; const float* fm; } FlowJob;
static void flow_part(void* c, int part, int parts) {
    FlowJob* j = c; K4nSession* s = j->s; const float k = s->s * 16.0f;
    int v0 = NH * part / parts, v1 = NH * (part + 1) / parts;
    for (int v = v0; v < v1; v++) for (int u = 0; u < NW; u++) {
        const float* p = j->fm + ((size_t) (v >> 1) * (NW / 2) + (u >> 1)) * FMC + (v & 1) * 2 + (u & 1);
        size_t o = s->portrait ? (size_t) u * NH + v : (size_t) v * NW + u;
        float f[4] = { p[0], p[4], p[8], p[12] };
        for (int q = 0; q < 4; q++) { float x = f[q] * k; if (x > 32000) x = 32000; if (x < -32000) x = -32000;
            s->F[s->portrait ? (q ^ 1) : q][o] = (int16_t) lrintf(x); }
        float m = (p[16] + 16.0f) * (SIG_N / 32.0f); int mi = m <= 0 ? 0 : (m >= SIG_N - 1 ? SIG_N - 1 : (int) (m + 0.5f)); s->A[o] = g_sig[mi];
    }
}
void k4n_flow_from_fm(K4nSession* s, const float* fm, const float* netPrev, const float* netNext) {
    pthread_once(&g_sig_once, sig_init);
    FlowJob j = { s, fm }; pool_run(flow_part, &j);
    // reliability: does warping by the predicted flows explain the difference between the two frames? (grid step 4)
    double src = 0, wrp = 0, mag = 0; int n = 0;
    for (int v = 2; v < NH; v += 4) for (int u = 2; u < NW; u += 4) {
        const float* p = fm + ((size_t) (v >> 1) * (NW / 2) + (u >> 1)) * FMC + (v & 1) * 2 + (u & 1);
        int u0 = u + (int) lrintf(p[0]), v0 = v + (int) lrintf(p[4]), u1 = u + (int) lrintf(p[8]), w1 = v + (int) lrintf(p[12]);
        u0 = u0 < 0 ? 0 : (u0 > NW - 1 ? NW - 1 : u0); v0 = v0 < 0 ? 0 : (v0 > NH - 1 ? NH - 1 : v0);
        u1 = u1 < 0 ? 0 : (u1 > NW - 1 ? NW - 1 : u1); w1 = w1 < 0 ? 0 : (w1 > NH - 1 ? NH - 1 : w1);
        src += fabsf(netPrev[(size_t) v * NW + u] - netNext[(size_t) v * NW + u]);
        wrp += fabsf(netPrev[(size_t) v0 * NW + u0] - netNext[(size_t) w1 * NW + u1]);
        mag += fabsf(p[0]) + fabsf(p[4]) + fabsf(p[8]) + fabsf(p[12]); n++;
    }
    s->last_src = (float) (src / n); s->last_warp = (float) (wrp / n); s->last_flow = (float) (mag / n / 4);
}
int k4n_infer(K4nSession* s, const float* netPrev, const float* netNext, double* ms) {
    double t0 = k4n_now_ms();
    pthread_mutex_lock(&g_lock);
    if (g_state != 1) { pthread_mutex_unlock(&g_lock); return -1; }
    memcpy(S.p0, netPrev, sizeof(float) * NW * NH); memcpy(S.p1, netNext, sizeof(float) * NW * NH);
    H om = S.TensorMap_Create();
    int e = S.SNPE_ExecuteITensors(S.snpe, S.inmap, om);
    H t = e ? NULL : S.TensorMap_GetTensor_Ref(om, "FM");
    if (e || !t || S.ITensor_GetSize(t) != (size_t) (NW / 2) * (NH / 2) * FMC) {
        K4N_LOG("inference failed (%d): %.160s", e, S.LastError());
        S.TensorMap_Delete(om); snpe_drop(); g_state = -1; g_failed_at = k4n_now_ms(); snprintf(g_err, sizeof g_err, "inference failed");
        pthread_mutex_unlock(&g_lock); return -1;
    }
    const float* fm = (const float*) S.ITensor_GetData(t);
    double t1 = k4n_now_ms();
    k4n_flow_from_fm(s, fm, netPrev, netNext);
    S.TensorMap_Delete(om);
    pthread_mutex_unlock(&g_lock);
    if (ms) { ms[0] = t1 - t0; ms[1] = k4n_now_ms() - t1; }
    return 0;
}
void k4n_last_stats(const K4nSession* s, float* src, float* warp, float* flow) { *src = s->last_src; *warp = s->last_warp; *flow = s->last_flow; }

// ---------------------------------------------------------------------------------------------------------------
// warp both neighbours to time t (0..1 between prev and next) and blend. NV12, tightly packed (stride = w).
typedef struct { const K4nSession* s; const uint8_t *py, *puv, *ny, *nuv; uint8_t *oy, *ouv; int m0, m1; uint16_t lut[256]; } WarpJob;

static inline int bil(const uint8_t* img, int stride, int w, int h, int sx, int sy) {   // sx, sy: Q4, returns Q8
    if (sx < 0) sx = 0; if (sy < 0) sy = 0;
    int ix = sx >> 4, fx = sx & 15, iy = sy >> 4, fy = sy & 15;
    if (ix >= w - 1) { ix = w - 2; fx = 16; } if (iy >= h - 1) { iy = h - 2; fy = 16; }
    const uint8_t* p = img + (size_t) iy * stride + ix;
    int a = p[0] * 16 + (p[1] - p[0]) * fx, b = p[stride] * 16 + (p[stride + 1] - p[stride]) * fx;
    return a * 16 + (b - a) * fy;
}
static inline int bil2(const uint8_t* img, int cw, int ch, int sx, int sy, int c) {      // interleaved UV plane
    if (sx < 0) sx = 0; if (sy < 0) sy = 0;
    int ix = sx >> 4, fx = sx & 15, iy = sy >> 4, fy = sy & 15;
    if (ix >= cw - 1) { ix = cw - 2; fx = 16; } if (iy >= ch - 1) { iy = ch - 2; fy = 16; }
    const uint8_t* p = img + ((size_t) iy * cw + ix) * 2 + c; int st = cw * 2;
    int a = p[0] * 16 + (p[2] - p[0]) * fx, b = p[st] * 16 + (p[st + 2] - p[st]) * fx;
    return a * 16 + (b - a) * fy;
}
static void warp_part(void* c, int part, int parts) {
    WarpJob* j = c; const K4nSession* s = j->s; const int w = s->w, h = s->h, gw = s->gw, gh = s->gh, cw = w / 2, ch = h / 2;
    int y0 = (h * part / parts) & ~1, y1 = part == parts - 1 ? h : ((h * (part + 1) / parts) & ~1);
    int32_t* t = malloc(sizeof(int32_t) * 5 * gw);
    for (int y = y0; y < y1; y++) {
        float g = y / s->s; int iv = (int) g; if (iv > gh - 1) iv = gh - 1; int wv = (int) lrintf((g - iv) * 256); int iv1 = iv + 1; if (iv1 > gh - 1) { iv1 = gh - 1; wv = 0; }
        for (int k = 0; k < 4; k++) { const int16_t* a = s->F[k] + (size_t) iv * gw; const int16_t* b = s->F[k] + (size_t) iv1 * gw; int m = k < 2 ? j->m0 : j->m1; int32_t* o = t + k * gw;
            for (int x = 0; x < gw; x++) o[x] = (((a[x] * (256 - wv) + b[x] * wv) >> 8) * m) >> 8; }
        { const uint8_t* a = s->A + (size_t) iv * gw; const uint8_t* b = s->A + (size_t) iv1 * gw; int32_t* o = t + 4 * gw;
            for (int x = 0; x < gw; x++) o[x] = (j->lut[a[x]] * (256 - wv) + j->lut[b[x]] * wv) >> 8; }
        uint8_t* oy = j->oy + (size_t) y * w;
        for (int x = 0; x < w; x++) {
            int i = s->ci[x], f = s->cw[x], i1 = f ? i + 1 : i;
            int dx0 = t[i] + (((t[i1] - t[i]) * f) >> 8), dy0 = t[gw + i] + (((t[gw + i1] - t[gw + i]) * f) >> 8);
            int dx1 = t[2 * gw + i] + (((t[2 * gw + i1] - t[2 * gw + i]) * f) >> 8), dy1 = t[3 * gw + i] + (((t[3 * gw + i1] - t[3 * gw + i]) * f) >> 8);
            int al = t[4 * gw + i] + (((t[4 * gw + i1] - t[4 * gw + i]) * f) >> 8);
            int pv = bil(j->py, w, w, h, x * 16 + dx0, y * 16 + dy0), nv = bil(j->ny, w, w, h, x * 16 + dx1, y * 16 + dy1);
            int o = (pv * al + nv * (256 - al) + 32768) >> 16;
            oy[x] = (uint8_t) (o < 0 ? 0 : (o > 255 ? 255 : o));
        }
        if (!(y & 1) && (y >> 1) < ch) {
            int cy = y >> 1; uint8_t* ouv = j->ouv + (size_t) cy * cw * 2;
            for (int cx = 0; cx < cw; cx++) {
                int x = cx * 2, i = s->ci[x], f = s->cw[x], i1 = f ? i + 1 : i;
                int dx0 = t[i] + (((t[i1] - t[i]) * f) >> 8), dy0 = t[gw + i] + (((t[gw + i1] - t[gw + i]) * f) >> 8);
                int dx1 = t[2 * gw + i] + (((t[2 * gw + i1] - t[2 * gw + i]) * f) >> 8), dy1 = t[3 * gw + i] + (((t[3 * gw + i1] - t[3 * gw + i]) * f) >> 8);
                int al = t[4 * gw + i] + (((t[4 * gw + i1] - t[4 * gw + i]) * f) >> 8);
                int sx0 = cx * 16 + dx0 / 2, sy0 = cy * 16 + dy0 / 2, sx1 = cx * 16 + dx1 / 2, sy1 = cy * 16 + dy1 / 2;
                for (int q = 0; q < 2; q++) {
                    int pv = bil2(j->puv, cw, ch, sx0, sy0, q), nv = bil2(j->nuv, cw, ch, sx1, sy1, q);
                    int o = (pv * al + nv * (256 - al) + 32768) >> 16;
                    ouv[cx * 2 + q] = (uint8_t) (o < 0 ? 0 : (o > 255 ? 255 : o));
                }
            }
        }
    }
    free(t);
}
void k4n_warp(const K4nSession* s, const uint8_t* prev, const uint8_t* next, uint8_t* out, float tpos) {
    WarpJob j; j.s = s; size_t ys = (size_t) s->w * s->h;
    j.py = prev; j.puv = prev + ys; j.ny = next; j.nuv = next + ys; j.oy = out; j.ouv = out + ys;
    j.m0 = (int) lrintf(tpos * 512); j.m1 = (int) lrintf((1 - tpos) * 512);
    for (int a = 0; a < 256; a++) { float al = a / 255.0f, num = (1 - tpos) * al, den = num + tpos * (1 - al); j.lut[a] = (uint16_t) lrintf(256.0f * (den > 1e-6f ? num / den : 0.5f)); }
    pool_run(warp_part, &j);
}
