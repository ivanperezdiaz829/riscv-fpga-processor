/**
 * \file vip_common.h
 *
 * \author aharding
 *
 * \brief Common code used by the VIP library cores.
 * Includes common parts of Doxygen documentation, such as main page and module definitions.
*/

#ifndef _VIP_COMMON_H_
#define _VIP_COMMON_H_

#include "vip_constants.h"

#ifndef __CUSP__
	#include <systemc.h>
#endif // n__CUSP__

/**
 * \defgroup Macros Utility Macro Functions
 *
 * The compile-time configuration of the VIP library is handled by defines
 * and the C preprocessor. This small collection of macro functions aim to
 * help achieve this with minimal loss of readability.
@{*/

/**
 * Concatenate tokens X, Y and Z. The use of paste (##) disables prescan on
 * arguments so this does a primitive concatenation with no expansion.
 * See GNU preprocessor help at http://gcc.gnu.org/onlinedocs/cpp/Argument-Prescan.html#Argument-Prescan.
*/
#define PRIMITIVE_CONCATENATE(X, Y, Z) X##Y##Z

/**
 * Make a new function name by concatenating the two arguments with an
 * underscore in between. This macro uses PRIMITIVE_CONCATENATE rather than
 * using paste (##) directly, so arguments to MK_FNAME are expanded.
 */
#define MK_FNAME(X, Y) PRIMITIVE_CONCATENATE(X, _, Y)

/** Send the value and name of a given variable to a given C++ stream.
 *
 * e.g. \code
  INSPECT_VAR(cout, x);
\endcode
 * becomes \code
  cout << "x" << "=" << x << "; ";
\endcode
 */
#define INSPECT_VAR(STREAM,VAR) STREAM << #VAR << "=" << VAR << "; ";
#define INSPECT_VAR_NL(STREAM,VAR) STREAM << #VAR << "=" << VAR << ";\n";

/** Quick way to perform X % (2^{BPS}) */
#define WRAP_BPS(X,BPS) ((X) & ((1<<BPS)-1))

// These two are just to help make sense of all the +1s in bit widths
#define SIGN_BIT 1
#define OVERFLOW_BIT 1

//! Declare N copies of variable VAR in registers with a specified WIDTH.
//! The array is named VAR_d
#define DECLARE_N_COPIES(TYPE, VAR, WIDTH, N) \
  ALT_REG<WIDTH> VAR##_d_REGS[N]; \
  TYPE VAR##_d[N] BIND(VAR##_d_REGS);

//! Initialise an array of copies with VAL using an unrolled loop with COUNTER 
//! as the loop variable.
#define INITIALISE_N_COPIES(VAR, VAL, COUNTER, N) \
  for(COUNTER=0; COUNTER < N; COUNTER++) \
  { \
    ALT_ATTRIB(ALT_UNROLL,ALT_UNROLL_ON); \
    ALT_ATTRIB(ALT_MIN_ITER,N); ALT_ATTRIB(ALT_MAX_ITER,N); \
    VAR##_d[COUNTER] = VAL; \
  }

//! Call this after updating VAR to copy its value along the array of copies
#define UPDATE_N_COPIES(VAR, COUNTER, N) \
  VAR##_d[0] = VAR; \
  for(COUNTER=1; COUNTER < N; COUNTER++) \
  { \
    ALT_ATTRIB(ALT_UNROLL,ALT_UNROLL_ON); \
    ALT_ATTRIB(ALT_MIN_ITER,N-1); ALT_ATTRIB(ALT_MAX_ITER,N-1); \
    VAR##_d[COUNTER] = VAR##_d[COUNTER-1]; \
  }

#ifdef DISABLE_COPIES
  #define READ_COPY(VAR, INDEX) VAR
#else
  //! A way to read copies of variables where defining DISABLE copies at the
  //! top of your source will revert back to reading the originals.
  #ifdef USE_CUSP_COPIES
    #define READ_COPY(VAR, INDEX) ALT_STAGE(VAR, INDEX+1)
  #else
    #define READ_COPY(VAR, INDEX) VAR##_d[INDEX]
  #endif
#endif

#define DECLARE_VAR_WITH_AU(TYPE, WIDTH, VARNAME) \
  ALT_AU<WIDTH> MK_FNAME(VARNAME, AU); \
  TYPE VARNAME BIND(MK_FNAME(VARNAME, AU));
#define DECLARE_ARRAY_WITH_AU(TYPE, WIDTH, VARNAME, N) \
  ALT_AU<WIDTH> VARNAME##_AU[N]; \
  TYPE VARNAME[N] BIND(VARNAME##_AU);

#define DECLARE_VAR_WITH_REG(TYPE, WIDTH, VARNAME) \
  ALT_REG<WIDTH> MK_FNAME(VARNAME, REG); \
  TYPE VARNAME BIND(MK_FNAME(VARNAME, REG));
#define DECLARE_ARRAY_WITH_REG(TYPE, WIDTH, VARNAME, N) \
  ALT_REG<WIDTH> VARNAME##_REG[N]; \
  TYPE VARNAME[N] BIND(VARNAME##_REG);

#define DECLARE_VAR_WITH_MULT(TYPE, WIDTH, VARNAME) \
  ALT_MULT<WIDTH> MK_FNAME(VARNAME, MULT); \
  TYPE VARNAME BIND(MK_FNAME(VARNAME, MULT));

//! Finds log_2 of X for X in [1, 2048]
#define LOG2(X)   (X == 1 ? 0 : \
                   (X <= 1<<1 ? 1 : (X <= 1<<2 ? 2 : (X <= 1<<3 ? 3 : X <= 1<<4 ? 4 : \
                   (X <= 1<<5 ? 5 : (X <= 1<<6 ? 6 : (X <= 1<<7 ? 7 : \
                   (X <= 1<<8 ? 8 : (X <= 1<<9 ? 9 : (X <= 1<<10 ? 10 : \
                   (X <= 1<<11 ? 11 : (X <= 1<<12 ? 12 : (X <= 1<<13 ? 13 : \
                   (X <= 1<<14 ? 14 : (X <= 1<<15 ? 15 : (X <= 1<<16 ? 16 : \
                   (X <= 1<<17 ? 17 : (X <= 1<<18 ? 18 : (X <= 1<<19 ? 19 : \
                   (X <= 1<<20 ? 20 : (X <= 1<<21 ? 21 : (X <= 1<<22 ? 22 : \
                   (X <= 1<<23 ? 23 : (X <= 1<<24 ? 24 : (X <= 1<<25 ? 25 : \
                   26)))))))))))))))))))))))))

//! Finds log_2 with guard of X for X in [1, 2047]
#define LOG2G(X)   (X < 1<<1 ? 1 : (X < 1<<2 ? 2 : (X < 1<<3 ? 3 : X < 1<<4 ? 4 : \
                   (X < 1<<5 ? 5 : (X < 1<<6 ? 6 : (X < 1<<7 ? 7 : \
                   (X < 1<<8 ? 8 : (X < 1<<9 ? 9 : (X < 1<<10 ? 10 : \
                   (X < 1<<11 ? 11 : (X < 1<<12 ? 12 : (X < 1<<13 ? 13 : \
                   (X < 1<<14 ? 14 : (X < 1<<15 ? 15 : (X < 1<<16 ? 16 : \
                   (X < 1<<17 ? 17 : (X < 1<<18 ? 18 : (X < 1<<19 ? 19 : \
                   (X < 1<<20 ? 20 : (X < 1<<21 ? 21 : (X < 1<<22 ? 22 : \
                   (X < 1<<23 ? 23 : (X < 1<<24 ? 24 : (X < 1<<25 ? 25 : \
                   26))))))))))))))))))))))))

//! Finds the nearest number >= X which is a power of 2 (upto a maximum of 4096)
#define LOG2_CEIL(X) (1<<LOG2(X))

//! Evaluates its argument and makes it into a string.
#define MK_STR(S) MK_STR_INTERNAL(S)
//! Helped for MK_STR.
#define MK_STR_INTERNAL(S) #S

#define MAX(A,B) (A > B ? A : B)
#define MIN(A,B) (A > B ? B : A)

#define MAKE_EVEN(X) ((X)&(~1))

#define IS_ODD(X) (sc_uint<1>(X).bit(0))
#define IS_EVEN(X) (!IS_ODD(X))

// returns a string which is sc_time_stamp() padded with preceding spaces
// to make it 14 characters long
#ifndef __CUSP__
std::string vip_time_stamp()
{
	std::string t = sc_time_stamp().to_string();
	std::stringstream s;
	for (int i = t.length(); i < 14; i++)
	{
		s << " ";
	}
	s << t;
	return s.str();
}
#endif //n__CUSP__

#ifdef __CUSP__
#define NO_CUSP(X)
#else
#define NO_CUSP(X) X
#endif

#define HW_DEBUG_MSG_ON
#ifndef HW_DEBUG_MSG
    #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_DEBUG_MSG(X) std::cout << sc_time_stamp() << ": " << name() << ", " << X
    #else
        #define HW_DEBUG_MSG(X)
   #endif
#endif // nHW_DEBUG_MSG
#ifndef HW_DEBUG_MSG_COND
    #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_DEBUG_MSG_COND(cond, X) if (cond) std::cout << sc_time_stamp() << ": " << name() << ", " << X
    #else
        #define HW_DEBUG_MSG_COND(cond, X)
   #endif
#endif // nHW_DEBUG_MSG_COND

#ifndef vip_assert
    #if !defined(__CUSP__)
        #include <cassert>
        #define vip_assert(X) assert(X)
    #else
        #define vip_assert(X)
    #endif
#endif // nvip_assert

/*@}*/

#endif /*_VIP_COMMON_H_*/

/** \mainpage
 *
 * This is the Video/Image Processing IP library.
 * It includes hardware models in synthesisable SystemC
 * and software models the purpose of which is to define exactly the behaviour of the VIP cores.
 * This definition includes:
 * <ol>
 *  <li> The parameters needed for the VIP cores and the required ranges of these parameters.
 *  <li> The algorithms used in the cores.
 *  <li> A bit-accurate simulation of the cores for the purpose of testing.
 * </ol>
 */

/**
 * \defgroup SWCores Software Core Models
 * These software models form the golden reference specification of the behaviour and parameterisability
 * of the VIP cores. With the exception of the colour space converter (CSC) core, each core works on a single colour plane,
 * so a typical use may be as follows:
 * \dot
 * digraph example {
 * 	rankdir=LR;
 *  source [ label="Image Source" shape="box" ];
 *  m1 [ label="Median" shape="box" ];
 *  m2 [ label="Median" shape="box" ];
 *  m3 [ label="Median" shape="box" ];
 *  sink [ label="Image Sink" shape="box" ];
 *  source -> m1 [ label="Red (5 bit)"];
 *  source -> m2 [ label="Green (6 bit)"];
 *  source -> m3 [ label="Blue (5 bit)"];
 *  m1 -> sink [ label="Red (5 bit)"];
 *  m2 -> sink [ label="Green (6 bit)"];
 *  m3 -> sink [ label="Blue (5 bit)"];
 * }
 * \enddot
 * Each core is modelled by a single software function. The parameters of each core are modelled in three parts:
 * -# Compile time parameters which the user will control using IP Toolbench. These are implemented using
 *    defines. The same defines parameterise the software cores and the hardware cores that they model.
 * -# Datapath connections. Each software model reads and writes data from and to framebuffers in memory.
 *    Pointers to framebuffers are passed as arguments into  the software function. These framebuffer pointers
 *    correspond directly to the ImageStream ports provided to stream pixel data in and out of the hardware
 *    cores. The relationship between framebuffers and ImageStream streams is defined by the FrameToStream (FTS_NAME)
 *    and StreamToFrame (STF_NAME) SystemC models, which read framebuffers and write ImageStream and read ImageStream
 *    and write framebuffers, respectively.
 * -# Control path connections. Extra arguments are passed into each function which correspond to the
 *    control signals on the hardware cores. These are modelled as SystemC types passed by value.
 */

/**
 * \defgroup HWCores Synthesisable SystemC Hardware Cores
 * These hardware models can each be synthesised using CusP to make hardware which will run on Altera FPGAs.
 * The behaviour and parameterisability of each hardware core should be identical to its software
 * model.
 */

/**
 * \defgroup FrameStream Streaming Interface
 * Interfacing between software models and hardware cores.
 * The hardware cores are all designed to work on streams of pixel data. This allows multiple cores to be
 * connected together without the large memory and memory bandwidth requirements of buffering between each
 * core. A standard is required for these streams of pixel data, to define such things as the order in which the
 * pixels in a framebuffer are transmitted.
 *
 * <b>ImageStream v0.1</b>
 *
 * We've given our standard the name ImageStream. The current version is 0.1. This is a very simple standard,
 * we will extend and improve to make more optimisations possible as we work on the performance and features of the
 * cores.
 *
 * ImageStream 0.1 is defined as follows:
 * - A stream of data transferred over "Streaming Avalon" (there is currently work in the UK
 *   on selecting a subclass of Atlantic II to be used for the TI coprocessor boards which should provide performance
 *   benefits and still be SOPC builder compatible, we will move ImageStream over to this when it is ready).
 * - Stream pixels in left-to-right, top to bottom order.
 * - Only one colour plane per stream, three parallel streams to make an RGB or YCbCr image.
 * - Streams are either 8 bits or 10 bits wide, corresponding to 8 or 10 bits per sample image data.
 * - No end-of-line or end-of-packet signalling, blocks know the size of the image data they are expecting.
 *
 * All of the software models are defined to work on framebuffers stored in memory. This helps to make the
 * software models very simple to write and also improves software model execution speed a great deal. To test
 * a hardware block against its executable software specification we therefore need blocks which read framebuffers
 * and write ImageStream and vice versa. These blocks are themselves the golden reference specification for
 * the ImageStream standard.
 */

 /**
 * \page SupportedResolutions Supported Image Resolutions
 *
 * The following image resolutions are supported (WIDTH x HEIGHT):
 * 64x64, 128x128, 176x120, 176x144, 256x256, 352x240, 352x288,
 * 640x480, 704x480, 704x576, 1024x768, 1280x720, 1920x540, 1920x1080
 */
