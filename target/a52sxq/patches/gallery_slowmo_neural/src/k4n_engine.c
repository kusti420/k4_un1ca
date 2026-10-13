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
#ifdef __aarch64__
#include <arm_neon.h>
#endif
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
// threads: the work comes in short bursts (a few ms every 33 ms), so where the threads run decides the tail of the
// frame times. Workers are kept on the big cores (when the cpuset allows it) and may ask for a utilisation floor.
#include <sched.h>
#include <sys/syscall.h>
static cpu_set_t g_big; static int g_nbig = -1;
static pthread_once_t g_big_once = PTHREAD_ONCE_INIT;
static void big_init(void) {
    long cap[CPU_SETSIZE > 64 ? 64 : CPU_SETSIZE]; long mx = 0, mn = 0; int n = 0; cpu_set_t allowed;
    const char* e = getenv("K4N_BIG"); g_nbig = 0; CPU_ZERO(&g_big);
    if (e && !atoi(e)) return;
    if (sched_getaffinity(0, sizeof allowed, &allowed)) return;
    for (int c = 0; c < 64; c++) { char path[96]; cap[c] = 0;
        snprintf(path, sizeof path, "/sys/devices/system/cpu/cpu%d/cpu_capacity", c); FILE* f = fopen(path, "r");
        if (!f) { snprintf(path, sizeof path, "/sys/devices/system/cpu/cpu%d/cpufreq/cpuinfo_max_freq", c); f = fopen(path, "r"); }
        if (!f) continue;
        if (fscanf(f, "%ld", &cap[c]) != 1) cap[c] = 0;
        fclose(f);
        if (cap[c] > 0) { if (cap[c] > mx) mx = cap[c]; if (!n || cap[c] < mn) mn = cap[c]; n++; } }
    if (!n || mx == mn) return;
    for (int c = 0; c < 64; c++) if (cap[c] * 2 > mx + mn && CPU_ISSET(c, &allowed)) { CPU_SET(c, &g_big); g_nbig++; }
    if (g_nbig < 2) { g_nbig = 0; CPU_ZERO(&g_big); }
}
struct k4n_sched_attr { uint32_t size, policy; uint64_t flags; int32_t nice; uint32_t prio; uint64_t rt, dl, period; uint32_t util_min, util_max; };
// called by every thread that does frame work: big = keep it on the big cores
void k4n_thread_setup(int big) {
    pthread_once(&g_big_once, big_init);
    if (big && g_nbig) sched_setaffinity(0, sizeof g_big, &g_big);
    const char* e = getenv("K4N_UCLAMP"); int u = e ? atoi(e) : 0;
    if (u > 0) { struct k4n_sched_attr a = { .size = sizeof a, .flags = 0x08 | 0x10 | 0x20 /* keep policy + params, set util min */, .util_min = (uint32_t) (u > 1024 ? 1024 : u) };
        static int said; long r = syscall(SYS_sched_setattr, 0, &a, 0);
        if (!said) { said = 1; K4N_LOG("threads: %d big cores, utilisation floor %d: %s", g_nbig, u, r ? "refused" : "ok"); } }
}

// worker pool: jobs are cut into more parts than there are threads (a slow core takes fewer of them), the calling
// thread works too, and two callers (the two pipeline stages) can run jobs at the same time.
#define MAXT 8
#define MAXJ 4
typedef void (*JobFn)(void* ctx, int part, int parts);
typedef struct { JobFn fn; void* ctx; int parts, taken, pending, live; } Job;
static struct { pthread_t th[MAXT]; int n; pthread_mutex_t mu; pthread_cond_t cv, done; Job job[MAXJ]; } P = {
    .mu = PTHREAD_MUTEX_INITIALIZER, .cv = PTHREAD_COND_INITIALIZER, .done = PTHREAD_COND_INITIALIZER };
static void pool_work(Job* j) {     // P.mu held: one part of j
    int part = j->taken++, parts = j->parts; JobFn fn = j->fn; void* ctx = j->ctx;
    pthread_mutex_unlock(&P.mu);
    fn(ctx, part, parts);
    pthread_mutex_lock(&P.mu);
    if (--j->pending == 0) pthread_cond_broadcast(&P.done);
}
static void* pool_main(void* a) {
    k4n_thread_setup(a != NULL);
    pthread_mutex_lock(&P.mu);
    for (;;) {
        Job* j = NULL;
        for (int i = 0; i < MAXJ; i++) if (P.job[i].live && P.job[i].taken < P.job[i].parts) { j = &P.job[i]; break; }
        if (j) pool_work(j); else pthread_cond_wait(&P.cv, &P.mu);
    }
    return NULL;
}
static void pool_run(JobFn fn, void* ctx) {
    pthread_mutex_lock(&P.mu);
    if (!P.n) {
        pthread_once(&g_big_once, big_init);
        int n = (int) sysconf(_SC_NPROCESSORS_ONLN); n = n > 6 ? 6 : (n < 1 ? 1 : n);
        const char* e = getenv("K4N_THREADS"); if (e && atoi(e) > 0 && atoi(e) <= MAXT) n = atoi(e);
        // one worker per big core stays on the big cores, the others go wherever the scheduler finds room
        for (int i = 0; i < n; i++) pthread_create(&P.th[i], NULL, pool_main, i < g_nbig ? (void*) &P : NULL);
        P.n = n;
    }
    Job* j = NULL;
    for (;;) { for (int i = 0; i < MAXJ && !j; i++) if (!P.job[i].live) j = &P.job[i]; if (j) break; pthread_cond_wait(&P.done, &P.mu); }
    j->fn = fn; j->ctx = ctx; j->parts = (P.n + 1) * 4; j->pending = j->parts; j->taken = 0; j->live = 1;
    pthread_cond_broadcast(&P.cv);
    while (j->taken < j->parts) pool_work(j);
    while (j->pending) pthread_cond_wait(&P.done, &P.mu);
    j->live = 0; pthread_cond_broadcast(&P.done);
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
    int half;                           // 1: every second pixel column is a grid column (s = 2 exactly)
    int prep_half;                      // 1: a network input pixel is the mean of 2x2 image pixels (rows permitting)
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
    s->prep_half = !s->portrait && lw >= 2 * NW; for (int u = 0; u < NW && s->prep_half; u++) if (s->xi[u] != 2 * u || s->xw[u] != 64) s->prep_half = 0;
    s->half = 1; for (int x = 0; x < w && s->half; x++) if (s->ci[x] != x >> 1 || (s->cw[x] != (x & 1) * 128 && !(s->ci[x] == s->gw - 1 && !s->cw[x]))) s->half = 0;
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

int k4n_warp_scalar;        // 1: reference C code only, no NEON paths (tests)
// luma -> network input (float 0..1, 960x544), bilinear at the tabulated positions (exact 2x2 mean at 1080p)
typedef struct { const K4nSession* s; const uint8_t* y; int stride; float* out; } PrepJob;
static void prep_part(void* c, int part, int parts) {
    PrepJob* j = c; const K4nSession* s = j->s;
    int v0 = NH * part / parts, v1 = NH * (part + 1) / parts;
    for (int v = v0; v < v1; v++) {
        float* o = j->out + (size_t) v * NW; int wy = s->yw[v], iy = s->yi[v];
        if (!s->portrait) {
            const uint8_t* r0 = j->y + (size_t) iy * j->stride; const uint8_t* r1 = r0 + j->stride; int u = 0;
#ifdef __aarch64__
            // exact 2x2 mean (1080p): all four weights are 64, the sum of the four pixels times 4096 is the same integer
            if (s->prep_half && wy == 64 && !k4n_warp_scalar) for (; u < NW; u += 8) {
                uint16x8_t q = vaddq_u16(vpaddlq_u8(vld1q_u8(r0 + 2 * u)), vpaddlq_u8(vld1q_u8(r1 + 2 * u)));
                const float32x4_t c = vdupq_n_f32(1.0f / (255.0f * 16384.0f));
                vst1q_f32(o + u, vmulq_f32(vcvtq_f32_u32(vshll_n_u16(vget_low_u16(q), 12)), c));
                vst1q_f32(o + u + 4, vmulq_f32(vcvtq_f32_u32(vshll_high_n_u16(q, 12)), c)); }
#endif
            for (; u < NW; u++) { int ix = s->xi[u], wx = s->xw[u];
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
    for (int v = v0; v < v1; v++) { int u = 0;
#ifdef __aarch64__
        // landscape: the two values of a cell that belong to this row are neighbours in memory; two cells = four grid points
        if (!s->portrait && !k4n_warp_scalar) { const float* row = j->fm + (size_t) (v >> 1) * (NW / 2) * FMC + (v & 1) * 2; size_t o = (size_t) v * NW;
            const float32x4_t vk = vdupq_n_f32(k), hi = vdupq_n_f32(32000), lo = vdupq_n_f32(-32000);
            for (; u < NW; u += 4) { const float* p = row + (size_t) (u >> 1) * FMC;
                for (int q = 0; q < 4; q++) { float32x4_t x = vmulq_f32(vcombine_f32(vld1_f32(p + q * 4), vld1_f32(p + FMC + q * 4)), vk);
                    x = vbslq_f32(vcgtq_f32(x, hi), hi, x); x = vbslq_f32(vcltq_f32(x, lo), lo, x);
                    vst1_s16(s->F[q] + o + u, vmovn_s32(vcvtnq_s32_f32(x))); }
                float32x4_t m = vmulq_n_f32(vaddq_f32(vcombine_f32(vld1_f32(p + 16), vld1_f32(p + FMC + 16)), vdupq_n_f32(16.0f)), SIG_N / 32.0f);
                uint32x4_t z = vcleq_f32(m, vdupq_n_f32(0)), t = vcgeq_f32(m, vdupq_n_f32(SIG_N - 1));
                int32x4_t mi = vcvtq_s32_f32(vaddq_f32(m, vdupq_n_f32(0.5f)));
                mi = vbslq_s32(t, vdupq_n_s32(SIG_N - 1), mi); mi = vbslq_s32(z, vdupq_n_s32(0), mi);
                int32_t ix[4]; vst1q_s32(ix, mi); uint8_t* a = s->A + o + u; a[0] = g_sig[ix[0]]; a[1] = g_sig[ix[1]]; a[2] = g_sig[ix[2]]; a[3] = g_sig[ix[3]]; } }
#endif
      for (; u < NW; u++) {
        const float* p = j->fm + ((size_t) (v >> 1) * (NW / 2) + (u >> 1)) * FMC + (v & 1) * 2 + (u & 1);
        size_t o = s->portrait ? (size_t) u * NH + v : (size_t) v * NW + u;
        float f[4] = { p[0], p[4], p[8], p[12] };
        for (int q = 0; q < 4; q++) { float x = f[q] * k; if (x > 32000) x = 32000; if (x < -32000) x = -32000;
            s->F[s->portrait ? (q ^ 1) : q][o] = (int16_t) lrintf(x); }
        float m = (p[16] + 16.0f) * (SIG_N / 32.0f); int mi = m <= 0 ? 0 : (m >= SIG_N - 1 ? SIG_N - 1 : (int) (m + 0.5f)); s->A[o] = g_sig[mi];
      }
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
// warp both neighbours to time t (0..1 between prev and next) and blend. NV12; the inputs are tightly packed
// (stride = w), the output has its own stride (it is written straight into the output buffer).
typedef struct { const K4nSession* s; const uint8_t *py, *puv, *ny, *nuv; uint8_t *oy, *ouv; int ostride; int m0, m1; uint16_t lut[256]; } WarpJob;

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
// per-thread scratch memory (the pool threads live as long as the process)
static pthread_key_t g_scr_key; static pthread_once_t g_scr_once = PTHREAD_ONCE_INIT;
static void scr_init(void) { pthread_key_create(&g_scr_key, free); }
static int32_t* scratch(size_t n) {     // n is the same for every call of a session; freed when the thread ends
    pthread_once(&g_scr_once, scr_init);
    size_t* b = pthread_getspecific(g_scr_key);
    if (!b || b[0] < n) { free(b); b = malloc(sizeof(size_t) * 2 + sizeof(int32_t) * n); b[0] = n; pthread_setspecific(g_scr_key, b); }
    return (int32_t*) (b + 2);
}

// the five fields (dx0, dy0, dx1, dy1 in Q4 pixels scaled by the time position, alpha Q8) of image row y:
// t = at the grid columns (gw + 1 values each, the last one repeated), d = at the w pixel columns
static void warp_fields(const WarpJob* j, int y, int32_t* restrict t, int32_t* restrict d, int ds) {
    const K4nSession* s = j->s; const int w = s->w, gw = s->gw, gh = s->gh, gs = gw + 1;
    float g = y / s->s; int iv = (int) g; if (iv > gh - 1) iv = gh - 1; int wv = (int) lrintf((g - iv) * 256); int iv1 = iv + 1; if (iv1 > gh - 1) { iv1 = gh - 1; wv = 0; }
    for (int k = 0; k < 4; k++) { const int16_t* restrict a = s->F[k] + (size_t) iv * gw; const int16_t* restrict b = s->F[k] + (size_t) iv1 * gw; int m = k < 2 ? j->m0 : j->m1; int32_t* restrict o = t + k * gs;
        for (int x = 0; x < gw; x++) o[x] = (((a[x] * (256 - wv) + b[x] * wv) >> 8) * m) >> 8;
        o[gw] = o[gw - 1]; }
    { const uint8_t* restrict a = s->A + (size_t) iv * gw; const uint8_t* restrict b = s->A + (size_t) iv1 * gw; int32_t* restrict o = t + 4 * gs;
        for (int x = 0; x < gw; x++) o[x] = (j->lut[a[x]] * (256 - wv) + j->lut[b[x]] * wv) >> 8;
        o[gw] = o[gw - 1]; }
    for (int k = 0; k < 5; k++) { const int32_t* restrict tk = t + k * gs; int32_t* restrict o = d + k * ds; int x = 0;
#ifdef __aarch64__
        if (s->half) for (; x + 8 <= w; x += 8) {       // grid = every second pixel: value, mean with the next value, ...
            int32x4_t a = vld1q_s32(tk + (x >> 1)), b = vld1q_s32(tk + (x >> 1) + 1);
            int32x4x2_t z = { { a, vaddq_s32(a, vshrq_n_s32(vsubq_s32(b, a), 1)) } }; vst2q_s32(o + x, z); }
#endif
        for (; x < w; x++) { int i = s->ci[x]; o[x] = tk[i] + (((tk[i + 1] - tk[i]) * s->cw[x]) >> 8); } }
}
static inline uint8_t blend8(int pv, int nv, int al) { int o = (pv * al + nv * (256 - al) + 32768) >> 16; return (uint8_t) (o < 0 ? 0 : (o > 255 ? 255 : o)); }
static void luma_c(const WarpJob* j, const int32_t* d, int ds, int y, int x0, uint8_t* oy) {
    const int w = j->s->w, h = j->s->h;
    for (int x = x0; x < w; x++) oy[x] = blend8(bil(j->py, w, w, h, x * 16 + d[x], y * 16 + d[ds + x]), bil(j->ny, w, w, h, x * 16 + d[2 * ds + x], y * 16 + d[3 * ds + x]), d[4 * ds + x]);
}
static void chroma_c(const WarpJob* j, const int32_t* d, int ds, int cy, int cx0, uint8_t* ouv) {
    const int cw = j->s->w / 2, ch = j->s->h / 2;
    for (int cx = cx0; cx < cw; cx++) { int x = cx * 2, al = d[4 * ds + x];
        int sx0 = cx * 16 + d[x] / 2, sy0 = cy * 16 + d[ds + x] / 2, sx1 = cx * 16 + d[2 * ds + x] / 2, sy1 = cy * 16 + d[3 * ds + x] / 2;
        for (int q = 0; q < 2; q++) ouv[cx * 2 + q] = blend8(bil2(j->puv, cw, ch, sx0, sy0, q), bil2(j->nuv, cw, ch, sx1, sy1, q), al); }
}
#ifdef __aarch64__
// The same arithmetic as bil()/bil2()/blend8(), eight luma (four chroma) pixels at a time. a*16 + (b-a)*f is computed
// as a*(16-f) + b*f, and alpha stays within 0..256, so nothing can leave 16/32 bits: bit-exact with the C code.
typedef struct { int32x4_t lim1, lim2; } Lim;
static inline int32x4_t q4_split(int32x4_t sv, Lim l, int32x4_t* f) {     // Q4 position -> clamped integer part, fraction 0..16
    sv = vmaxq_s32(sv, vdupq_n_s32(0));
    int32x4_t i = vshrq_n_s32(sv, 4); uint32x4_t m = vcgeq_s32(i, l.lim1);
    *f = vbslq_s32(m, vdupq_n_s32(16), vandq_s32(sv, vdupq_n_s32(15)));
    return vbslq_s32(m, l.lim2, i);
}
static inline uint64_t g16(const uint8_t* p, const int32_t* o) {          // two neighbouring bytes at four positions
    uint16_t a, b, c, e; memcpy(&a, p + o[0], 2); memcpy(&b, p + o[1], 2); memcpy(&c, p + o[2], 2); memcpy(&e, p + o[3], 2);
    return (uint64_t) a | ((uint64_t) b << 16) | ((uint64_t) c << 32) | ((uint64_t) e << 48);
}
static inline uint64_t g32(const uint8_t* p, const int32_t* o) {          // four bytes (U V U V) at two positions
    uint32_t a, b; memcpy(&a, p + o[0], 4); memcpy(&b, p + o[1], 4); return (uint64_t) a | ((uint64_t) b << 32);
}
// one image, eight luma pixels: Q8 samples (16 bit) at the positions x*16 + dx, y*16 + dy
static inline uint16x8_t luma8(const uint8_t* img, int w, Lim lx, Lim ly, int32x4_t xs, int32x4_t ys, const int32_t* dx, const int32_t* dy) {
    int32_t off[8]; int32x4_t fx0, fx1, fy0, fy1; const int32x4_t vw = vdupq_n_s32(w);
    int32x4_t ix0 = q4_split(vaddq_s32(xs, vld1q_s32(dx)), lx, &fx0), ix1 = q4_split(vaddq_s32(vaddq_s32(xs, vdupq_n_s32(64)), vld1q_s32(dx + 4)), lx, &fx1);
    int32x4_t iy0 = q4_split(vaddq_s32(ys, vld1q_s32(dy)), ly, &fy0), iy1 = q4_split(vaddq_s32(ys, vld1q_s32(dy + 4)), ly, &fy1);
    int32x4_t o0 = vmlaq_s32(ix0, iy0, vw), o1 = vmlaq_s32(ix1, iy1, vw);
    uint16x8_t fx = vcombine_u16(vmovn_u32(vreinterpretq_u32_s32(fx0)), vmovn_u32(vreinterpretq_u32_s32(fx1)));
    uint16x8_t fy = vcombine_u16(vmovn_u32(vreinterpretq_u32_s32(fy0)), vmovn_u32(vreinterpretq_u32_s32(fy1)));
    uint8x16_t wx = vreinterpretq_u8_u16(vorrq_u16(vsubq_u16(vdupq_n_u16(16), fx), vshlq_n_u16(fx, 8)));      // bytes: 16-fx, fx
    uint8x16_t r0, r1; const int32x4_t r03 = { 0, 1, 2, 3 }, r47 = { 4, 5, 6, 7 }, first = vdupq_laneq_s32(o0, 0);
    if (vminvq_u32(vandq_u32(vceqq_s32(vsubq_s32(o0, r03), first), vceqq_s32(vsubq_s32(o1, r47), first)))) {
        // the eight positions are neighbours (still or evenly moving area): the same bytes with two loads per row
        const uint8_t* p = img + vgetq_lane_s32(o0, 0);
        uint8x8_t a = vld1_u8(p), b = vld1_u8(p + 1), c = vld1_u8(p + w), e = vld1_u8(p + w + 1);
        r0 = vcombine_u8(vzip1_u8(a, b), vzip2_u8(a, b)); r1 = vcombine_u8(vzip1_u8(c, e), vzip2_u8(c, e));
    } else {
        vst1q_s32(off, o0); vst1q_s32(off + 4, o1);
        r0 = vcombine_u8(vcreate_u8(g16(img, off)), vcreate_u8(g16(img, off + 4)));
        r1 = vcombine_u8(vcreate_u8(g16(img + w, off)), vcreate_u8(g16(img + w, off + 4)));
    }
    uint16x8_t a = vpaddq_u16(vmull_u8(vget_low_u8(r0), vget_low_u8(wx)), vmull_high_u8(r0, wx));
    uint16x8_t b = vpaddq_u16(vmull_u8(vget_low_u8(r1), vget_low_u8(wx)), vmull_high_u8(r1, wx));
    return vmlaq_u16(vmulq_u16(a, vsubq_u16(vdupq_n_u16(16), fy)), b, fy);
}
static inline uint8x8_t blend_n(uint16x8_t pv, uint16x8_t nv, uint16x8_t al) {
    uint16x8_t na = vsubq_u16(vdupq_n_u16(256), al);
    uint32x4_t lo = vmlal_u16(vmull_u16(vget_low_u16(pv), vget_low_u16(al)), vget_low_u16(nv), vget_low_u16(na));
    uint32x4_t hi = vmlal_high_u16(vmull_high_u16(pv, al), nv, na);
    return vmovn_u16(vcombine_u16(vrshrn_n_u32(lo, 16), vrshrn_n_u32(hi, 16)));
}
static int luma_neon(const WarpJob* j, const int32_t* d, int ds, int y, uint8_t* oy) {
    const int w = j->s->w, h = j->s->h; int x = 0;
    const Lim lx = { vdupq_n_s32(w - 1), vdupq_n_s32(w - 2) }, ly = { vdupq_n_s32(h - 1), vdupq_n_s32(h - 2) };
    const int32x4_t ramp = { 0, 16, 32, 48 }, ys = vdupq_n_s32(y * 16);
    for (; x + 8 <= w; x += 8) {
        int32x4_t xs = vaddq_s32(vdupq_n_s32(x * 16), ramp);
        uint16x8_t pv = luma8(j->py, w, lx, ly, xs, ys, d + x, d + ds + x), nv = luma8(j->ny, w, lx, ly, xs, ys, d + 2 * ds + x, d + 3 * ds + x);
        uint16x8_t al = vcombine_u16(vmovn_u32(vreinterpretq_u32_s32(vld1q_s32(d + 4 * ds + x))), vmovn_u32(vreinterpretq_u32_s32(vld1q_s32(d + 4 * ds + x + 4))));
        vst1_u8(oy + x, blend_n(pv, nv, al));
    }
    return x;
}
static inline int32x4_t even_half(const int32_t* p) {       // elements 0, 2, 4, 6, each divided by two towards zero
    int32x4_t v = vuzp1q_s32(vld1q_s32(p), vld1q_s32(p + 4)); return vshrq_n_s32(vsubq_s32(v, vshrq_n_s32(v, 31)), 1);
}
// one image, four chroma pixels: Q8 samples U, V, U, V, ...
static inline uint16x8_t chroma4(const uint8_t* img, int cw, Lim lx, Lim ly, int32x4_t xs, int32x4_t ys, const int32_t* dx, const int32_t* dy) {
    int32_t off[4]; int32x4_t fx, fy;
    int32x4_t ix = q4_split(vaddq_s32(xs, even_half(dx)), lx, &fx), iy = q4_split(vaddq_s32(ys, even_half(dy)), ly, &fy);
    int32x4_t o = vshlq_n_s32(vmlaq_s32(ix, iy, vdupq_n_s32(cw)), 1);
    uint32x4_t ufx = vreinterpretq_u32_s32(fx), ufy = vreinterpretq_u32_s32(fy);
    uint8x16_t wx = vreinterpretq_u8_u32(vaddq_u32(vmulq_n_u32(vsubq_u32(vdupq_n_u32(16), ufx), 0x0101), vmulq_n_u32(ufx, 0x01010000)));   // bytes: 16-fx, 16-fx, fx, fx
    uint16x8_t wy = vreinterpretq_u16_u32(vmulq_n_u32(ufy, 0x00010001));
    uint8x16_t r0, r1; const int32x4_t r06 = { 0, 2, 4, 6 };
    if (vminvq_u32(vceqq_s32(vsubq_s32(o, r06), vdupq_laneq_s32(o, 0)))) {     // neighbours: U V U V ... of this pixel and the next one
        const uint8_t* p = img + vgetq_lane_s32(o, 0);
        uint16x4_t a = vreinterpret_u16_u8(vld1_u8(p)), b = vreinterpret_u16_u8(vld1_u8(p + 2)), c = vreinterpret_u16_u8(vld1_u8(p + 2 * cw)), e = vreinterpret_u16_u8(vld1_u8(p + 2 * cw + 2));
        r0 = vreinterpretq_u8_u16(vcombine_u16(vzip1_u16(a, b), vzip2_u16(a, b))); r1 = vreinterpretq_u8_u16(vcombine_u16(vzip1_u16(c, e), vzip2_u16(c, e)));
    } else {
        vst1q_s32(off, o);
        r0 = vcombine_u8(vcreate_u8(g32(img, off)), vcreate_u8(g32(img, off + 2)));
        r1 = vcombine_u8(vcreate_u8(g32(img + 2 * cw, off)), vcreate_u8(g32(img + 2 * cw, off + 2)));
    }
    uint16x8_t a = vreinterpretq_u16_u32(vpaddq_u32(vreinterpretq_u32_u16(vmull_u8(vget_low_u8(r0), vget_low_u8(wx))), vreinterpretq_u32_u16(vmull_high_u8(r0, wx))));
    uint16x8_t b = vreinterpretq_u16_u32(vpaddq_u32(vreinterpretq_u32_u16(vmull_u8(vget_low_u8(r1), vget_low_u8(wx))), vreinterpretq_u32_u16(vmull_high_u8(r1, wx))));
    return vmlaq_u16(vmulq_u16(a, vsubq_u16(vdupq_n_u16(16), wy)), b, wy);
}
static int chroma_neon(const WarpJob* j, const int32_t* d, int ds, int cy, uint8_t* ouv) {
    const int cw = j->s->w / 2, ch = j->s->h / 2; int cx = 0;
    const Lim lx = { vdupq_n_s32(cw - 1), vdupq_n_s32(cw - 2) }, ly = { vdupq_n_s32(ch - 1), vdupq_n_s32(ch - 2) };
    const int32x4_t ramp = { 0, 16, 32, 48 }, ys = vdupq_n_s32(cy * 16);
    for (; cx + 4 <= cw; cx += 4) {
        int x = cx * 2; int32x4_t xs = vaddq_s32(vdupq_n_s32(cx * 16), ramp);
        uint16x8_t pv = chroma4(j->puv, cw, lx, ly, xs, ys, d + x, d + ds + x), nv = chroma4(j->nuv, cw, lx, ly, xs, ys, d + 2 * ds + x, d + 3 * ds + x);
        int32x4_t a4 = vuzp1q_s32(vld1q_s32(d + 4 * ds + x), vld1q_s32(d + 4 * ds + x + 4));
        vst1_u8(ouv + cx * 2, blend_n(pv, nv, vreinterpretq_u16_u32(vmulq_n_u32(vreinterpretq_u32_s32(a4), 0x00010001))));
    }
    return cx;
}
#endif
static void warp_part(void* c, int part, int parts) {
    WarpJob* j = c; const K4nSession* s = j->s; const int w = s->w, h = s->h, gs = s->gw + 1, ds = w + 8, ch = h / 2;
    int y0 = (h * part / parts) & ~1, y1 = part == parts - 1 ? h : ((h * (part + 1) / parts) & ~1);
    int32_t* t = scratch((size_t) 5 * gs + (size_t) 5 * ds); int32_t* d = t + 5 * gs;
    for (int y = y0; y < y1; y++) {
        warp_fields(j, y, t, d, ds);
        uint8_t* oy = j->oy + (size_t) y * j->ostride; int x = 0;
#ifdef __aarch64__
        if (!k4n_warp_scalar) x = luma_neon(j, d, ds, y, oy);
#endif
        luma_c(j, d, ds, y, x, oy);
        if (!(y & 1) && (y >> 1) < ch) {
            int cy = y >> 1, cx = 0; uint8_t* ouv = j->ouv + (size_t) cy * j->ostride;
#ifdef __aarch64__
            if (!k4n_warp_scalar) cx = chroma_neon(j, d, ds, cy, ouv);
#endif
            chroma_c(j, d, ds, cy, cx, ouv);
        }
    }
}
void k4n_warp_to(const K4nSession* s, const uint8_t* prev, const uint8_t* next, uint8_t* oy, uint8_t* ouv, int ostride, float tpos) {
    WarpJob j; j.s = s; size_t ys = (size_t) s->w * s->h;
    j.py = prev; j.puv = prev + ys; j.ny = next; j.nuv = next + ys; j.oy = oy; j.ouv = ouv; j.ostride = ostride;
    j.m0 = (int) lrintf(tpos * 512); j.m1 = (int) lrintf((1 - tpos) * 512);
    for (int a = 0; a < 256; a++) { float al = a / 255.0f, num = (1 - tpos) * al, den = num + tpos * (1 - al); j.lut[a] = (uint16_t) lrintf(256.0f * (den > 1e-6f ? num / den : 0.5f)); }
    pool_run(warp_part, &j);
}
void k4n_warp(const K4nSession* s, const uint8_t* prev, const uint8_t* next, uint8_t* out, float tpos) {
    k4n_warp_to(s, prev, next, out, out + (size_t) s->w * s->h, s->w, tpos);
}
