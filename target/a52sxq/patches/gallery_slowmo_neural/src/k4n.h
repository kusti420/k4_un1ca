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
