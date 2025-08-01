
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
extern long long int GetLLIresult();
extern void StoreLLIresult(const unsigned int* data);
typedef struct VeriC_Descriptor *vc_handle;

#ifndef SV_3_COMPATIBILITY
#define SV_STRING const char*
#else
#define SV_STRING char*
#endif

#endif /* _VC_TYPES_ */


 extern unsigned char seq_done(long long sim_time);

 extern void seq_start(long long sim_time);

 extern void seq_get_request(long long sim_time, unsigned char blocking, /* OUTPUT */unsigned char *request_ready, /* OUTPUT */unsigned char *is_write, /* OUTPUT */svBitVecVal *addr, /* OUTPUT */svBitVecVal *data);

 extern void seq_send_response(long long sim_time, unsigned char is_write, const svBitVecVal *addr, const svBitVecVal *data);
void Wterminate();

#ifdef __cplusplus
}
#endif

