// K4 neural frame interpolation: engine interface (k4n_engine.c) used by the MPP front HAL (k4neuralmpp.c).
#pragma once
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#define K4N_TAG "K4Neural"
#ifdef __ANDROID__
#include <android/log.h>
#define K4N_LOG(...) do { __android_log_print(ANDROID_LOG_INFO, K4N_TAG, __VA_ARGS__); if (k4n_verbose) { fprintf(stderr, __VA_ARGS__); fputc('\n', stderr); } } while (0)
#else
#define K4N_LOG(...) do { fprintf(stderr, __VA_ARGS__); fputc('\n', stderr); } while (0)
#endif
extern int k4n_verbose;

typedef struct {
    const char* libdir;     // libSNPE.so, libSnpeHtpV68Stub.so
    const char* datadir;    // k4n_v3_htp.dlc (runtime 2), k4n_v3_gpu.dlc (runtime 1/3)
    int runtime;            // SNPE runtime: 2 = Hexagon HTP, 3 = GPU FP16, 1 = GPU, 0 = CPU
} K4nConfig;

typedef struct K4nSession K4nSession;

double k4n_now_ms(void);
// Loads SNPE (once) and builds the network. 0 = ready. After a failure the next attempt is made 30 s later at the earliest.
int k4n_engine_init(const K4nConfig* cfg, char* err, size_t errlen);
int k4n_engine_ready(void);
// Frees the network (SNPE session, DSP process domain); k4n_engine_init() builds it again.
void k4n_engine_release(void);
K4nSession* k4n_session_create(int w, int h);
void k4n_session_destroy(K4nSession* s);
// picture quality mode of this session: 0 = original behaviour (default), 1 = improved, live-safe, 2 = best quality (saving)
void k4n_session_set_quality(K4nSession* s, int q);
// luma plane -> network input (960*544 floats)
void k4n_prep(const K4nSession* s, const uint8_t* y, int stride, float* net);
// flows prev<->next into the session; ms[0] = inference, ms[1] = post-processing
int k4n_infer(K4nSession* s, const float* netPrev, const float* netNext, double* ms);
// post-processing of one network output (272x480x20 floats): flow grid + reliability statistics
void k4n_flow_from_fm(K4nSession* s, const float* fm, const float* netPrev, const float* netNext);
// mean |prev-next|, mean |warp(prev)-warp(next)| (0..1 luma, network resolution), mean |flow| (network pixels)
void k4n_last_stats(const K4nSession* s, float* src, float* warp, float* flow);
// frame at time tpos (0 = prev, 1 = next) from two packed NV12 frames (stride = w)
void k4n_warp(const K4nSession* s, const uint8_t* prev, const uint8_t* next, uint8_t* out, float tpos);
// the same, written into an NV12 buffer with its own stride (oy: luma rows, ouv: chroma rows)
void k4n_warp_to(const K4nSession* s, const uint8_t* prev, const uint8_t* next, uint8_t* oy, uint8_t* ouv, int ostride, float tpos);
// scheduling of a thread that does frame work (big = keep it on the big cores); the engine's own threads call it
void k4n_thread_setup(int big);
extern int k4n_warp_scalar;     // 1: reference C warp (tests)

// ---------------------------------------------------------------------------------------------------------------
// Repeated source frames. Videos converted from 24/25/27 to 30 fps repeat a frame every few frames. Interpolating
// between a frame and its copy gives `factor` identical outputs = a freeze. The pipe holds such a frame back and
// bridges the doubled interval instead: the next frame is interpolated against the frame before the copy, in
// 2 * factor steps. Only an isolated copy is bridged; two or more in a row are a still picture and go the usual way.
// The decisions are here (plain functions, no state of their own) so that the host test runs the same code.

// mean |a - b| of two network inputs, in 8-bit levels
float k4n_net_diff(const float* a, const float* b);
// A frame is taken as a copy of the one before below this. Measured (levels): copies in a 27->30 fps re-encode
// 0.006..0.097 (74 of 742 pairs); every other pair of that clip >= 0.37; the same clip slowed down x4 by this pipe
// >= 0.24; five camera/test clips at 24/30/60 fps >= 0.95.
#define K4N_REPEAT_MAD 0.15f

typedef struct { int pend, run, pend_factor; } K4nSeq;      // pend: a frame is held back; run: copies in a row so far
enum { K4N_SEQ_PAIR, K4N_SEQ_HOLD, K4N_SEQ_BRIDGE, K4N_SEQ_UNHOLD };
// What to do with a new frame that has a predecessor. rep: it is a copy of the frame before it; last: the stream ends with it.
//   PAIR   interpolate (previous, new) as always
//   HOLD   nothing goes out for it yet
//   BRIDGE a frame was held: interpolate (frame before the held one, new) in 2 * factor steps
//   UNHOLD a frame was held and this one is a copy too (or the factor changed): (before, held) and (held, new) as always
static inline int k4n_seq_step(K4nSeq* q, int enabled, int rep, int factor, int last) {
    if (q->pend) { q->pend = 0;
        if (rep || factor != q->pend_factor) { q->run = rep ? 2 : 0; return K4N_SEQ_UNHOLD; }
        q->run = 0; return K4N_SEQ_BRIDGE; }
    if (enabled && rep && !q->run && !last) { q->pend = 1; q->pend_factor = factor; return K4N_SEQ_HOLD; }
    q->run = rep ? q->run + 1 : 0; return K4N_SEQ_PAIR;
}
// Generated frame k (1 .. n-1; n = factor, or 2 * factor for a bridge) between ts0 and ts1 (tsm: time stamp of the
// held frame in the middle of a bridge): its position between the two frames, its time stamp, and which source
// frame stands in for it when the guard refuses to interpolate (0 = the older one). Returns n.
static inline int k4n_slot(int bridge, int factor, int k, long long ts0, long long tsm, long long ts1, float* t, long long* ts, int* newer) {
    if (!bridge) { *t = (float) k / factor; *ts = ts0 + (ts1 - ts0) * k / factor; *newer = !(*t < 0.5f); return factor; }
    *t = (float) k / (2 * factor);
    if (k <= factor) { *ts = ts0 + (tsm - ts0) * k / factor; *newer = 0; }                     // k == factor: the slot of the held frame
    else { *ts = tsm + (ts1 - tsm) * (k - factor) / factor; *newer = !((float) (k - factor) / factor < 0.5f); }
    return 2 * factor;
}

// ---------------------------------------------------------------------------------------------------------------
// Offline save, "config A": per source pair FILM (Google film_net, DLC prepared for the HTP) makes the middle frame on one
// 256x256 crop around the motion, pasted with a 24 px feather into the v3 middle frame; the other positions come from
// v3 on (prev, middle) and (middle, next). The crop is chosen from v3's own flows (k4n_render_score) and smoothed over
// neighbouring pairs by the caller (K4SlowMoExport). Nothing of this runs in the live hold.
#define K4N_FILM_CS 256
#define K4N_FILM_FEATHER 24
// FILM network: <datadir>/k4n_film256_htp.dlc on cfg->runtime (needs k4n_engine_init first: same libSNPE). 0 = ready.
int k4n_film_init(const K4nConfig* cfg, char* err, size_t errlen);
void k4n_film_release(void);
typedef struct K4nRender K4nRender;
K4nRender* k4n_render_create(int w, int h);
void k4n_render_destroy(K4nRender* r);
// pass 1: v3 on (prev, next) -> best crop score, its centre (image pixels) and the mean |prev - next| of the network
// inputs in 8-bit levels (the repeated-frame test, K4N_REPEAT_MAD). 0 = ok, -1 = engine failure.
int k4n_render_score(K4nRender* r, const uint8_t* prev, const uint8_t* next, float* score, float* cx, float* cy, float* diff);
// pass 2: the frames at ts[0..n-1] (0 < t < 1) as packed NV12 into out[i]; film: FILM on the crop at (x0, y0) (even,
// inside the frame), else plain v3. ms (optional): v3 inference, FILM, warps (all summed). 0 = ok, -1 = v3 failed,
// -2 = FILM failed (the frames are then plain v3; the caller decides).
int k4n_render_pair(K4nRender* r, const uint8_t* prev, const uint8_t* next, const float* ts, int n, int x0, int y0, int film, uint8_t** out, double* ms);
// crop helpers (exposed for the host tests): NV12 (tight) <-> RGB float 0..1 NHWC, BT.601 limited range as the reference
void k4n_rgb_crop(const uint8_t* nv12, int w, int h, int x0, int y0, float* rgb);
void k4n_paste_crop(uint8_t* nv12, int w, int h, const float* rgb, int x0, int y0);
