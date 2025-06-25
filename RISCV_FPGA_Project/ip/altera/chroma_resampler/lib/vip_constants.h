/**
 * \file vip_constants.h
 *
 * \author aharding
 *
 * \brief Constants used (often as enumerations) in the Video/Image Processing cores.
*/
#ifndef _VIP_CONSTANTS_H_
#define _VIP_CONSTANTS_H_

/**
 * \defgroup EdgeBehaviour Image Edge Handling Methods
 @{*/
/** Type for edge behaviour function parameters. */
typedef int edge_behaviour;
/** Behave as if the image is surrounded by 0 values. */
#define EDGE_PAD_ZEROS 1
/** Behave as if the image values are mirrored beyond the edges */
#define EDGE_MIRROR 2
/*@}*/

// Scaling algorithms
#define NEAREST_NEIGHBOUR 1
#define BILINEAR 2
// BICUBIC is both an algorithm and a filter function class
#define BICUBIC 3 
#define POLYPHASE 4

// Scaling filter funtion
#define LANCZOS 1
#define CUSTOM 2

// Dithering methods
#define FLOYD_STEINBERG 1
#define BURKES 2
#define SIERRA_2 3
#define SIERRA_2_4A 4
#define NO_DITHERING 5


/**
 * \defgroup DeinterlacingMethods Deinterlacing Methods
 *
 * These constants are used to select which deinterlacing method the deinterlacing core uses.
 * Currently only the two most basic methods, Bob and Weave, are available. Bob is supported
 * in two variants - nearest neighbour and linear interpolation.
 *
 @{*/
/**
 * Scale up each field vertically by a factor of two using simple
 * line duplication.
*/
#define DEINTERLACING_BOB_SCANLINE_DUPLICATION 1
/**
 * Scale up each field vertically by a factor of two, interpolating between available
 * scanlines to fill in the missing scanlines.
*/
#define DEINTERLACING_BOB_SCANLINE_INTERPOLATION 2
/** Stich together scanlines from the current field and the previous field to make up a frame.
*/
#define DEINTERLACING_WEAVE 3
#define DEINTERLACING_MOTION_ADAPTIVE 4

// deinterlacing - choice of which fields to produce
#define DEINTERLACING_BOTH 0
#define DEINTERLACING_F0   1
#define DEINTERLACING_F1   2

// deinterlacing - choice of buffering styles
#define DEINTERLACING_NO_BUFFERING     0
#define DEINTERLACING_DOUBLE_BUFFERING 1
#define DEINTERLACING_TRIPLE_BUFFERING 2
/*@}*/

// Interlaced and deinterlaced modes
#define PROGRESSIVE_FRAMES             0
#define INTERLACED_SYNC_F0             1
#define INTERLACED_SYNC_F1             2

/**
 * \defgroup OverflowHandling Overflow Handling Methods
 *
 * When it is possible for a core to calculate values which exceed the upper range of the output
 * value, these parameters can be given to deal control how this is dealt with.
 * 
 * Overflow handling adds one guard bit to calculations, so results which
 * fall outside this range are undefined e.g. with 8 bit data results greater
 * than 511 are undefined.
 * 
 @{*/
/** No checking */
#define OVERFLOW_IGNORE 1
/** Saturate */
#define OVERFLOW_SATURATE 2
/*@}*/

/**
 * \defgroup UnderflowHandling Underflow Handling Methods
 *
 * When it is possible for a core to calculate values which fall under the lower range of the output
 * value, these parameters can be given to deal control how this is dealt with.
 * 
 * Underflow handling adds one guard bit to calculations, so results which
 * fall outside this range are undefined e.g. with 8 bit data results less
 * than -255 are undefined.
 *
 @{*/
/** No checking */
#define UNDERFLOW_IGNORE 1
/** Saturate */
#define UNDERFLOW_SATURATE 2
/** Absolute value */
#define UNDERFLOW_ABSOLUTE 3
/*@}*/

/**
 * \defgroup NamedResamplingFormats Image Sampling Formats
 *
 * TODO: Write more here!
 * 
 @{*/
///** The Bayer mask.  <TABLE BORDER="BORDER">
//<TR>
//<TD BGCOLOR="#00FF00">  G </TD>
//<TD BGCOLOR="#0000FF">  B </TD></TR>
//<TR>
//<TD BGCOLOR="#ff0000">  R </TD>
//<TD BGCOLOR="#00ff00">  G </TD></TR></TABLE>
// *  */
//#define SAMPLE_BAYER 1
///** Full resolution in 1st plane, half width and height in planes 2, 3 */
#define SAMPLE_420 420
/** Full resolution in 1st plane, half width in planes 2, 3 */
#define SAMPLE_422 422
/** Full resolution in planes 1, 2, 3 */
#define SAMPLE_444 444
/*@}*/

// The colorspaces
#define COLORSPACE_RGB   1
#define COLORSPACE_YCbCr 2

/**
 * \defgroup Interpolation1D 1D Interpolation Methods.
 *
 * Given a series of equally spaced data points
 * \f$x_{i-1}, x_i, x_{i+1}\f$ where \f$x_{i-1}\f$ and \f$x_{i+1}\f$ are known
 * but \f$x_i\f$ is not, these methods find \f$x_i\f$.
 @{*/
/** \f$x_i = x_{i-1}\f$ */
#define INTERPOLATION_1D_NEAREST_NEIGHBOUR 1
/** \f$x_i = (x_{i-1} + x_{i+1})/2\f$ */
#define INTERPOLATION_1D_LINEAR 2
#define INTERPOLATION_1D_CUBIC 3
#define INTERPOLATION_1D_FULL_FILTERING 4
/*@}*/

#define CONFIGURE_NONE 1
#define CONFIGURE_COMPILE_TIME 2
#define CONFIGURE_RUN_TIME 3

/**
 * \defgroup SymmetricMode Symmetric Mode
 *
 * When multiplying a kernel of pixels by coefficients as in a FIR, if the
 * coefficients are symmetric then they can be applied in separate
 * horizontal and vertical passes, which is much more efficient.
 *
 @{*/
/** Not symmetric */
#define SYMMETRIC_MODE_OFF 1
/** Symmetric */
#define SYMMETRIC_MODE_ON  2
/*@}*/


/**
 * \defgroup ConstrainToRange Constrain To Range
 *
 * Given a data range with a minimum and maximum, such as in the FIR
 * the data at various points must be contrained to the range.
 * This group defines ways of constraining to the range.
 *
 @{*/
/** No Constraining */
#define CONSTRAIN_TO_RANGE_IGNORE 1
/** Saturate to Limits */
#define CONSTRAIN_TO_RANGE_SATURATE  2
/*@}*/

/**
 * \defgroup ConvertToUnsigned Convert To Unsigned
 *
 * When a signed negative number is converted to an unsigned number 
 * the result will not be negative. This group defines how the non negative
 * result is derived
 *
 @{*/
/** Ignore */
#define CONVERT_TO_UNSIGNED_IGNORE 1
/** Saturate to 0 */
#define CONVERT_TO_UNSIGNED_SATURATE 2
/** Use positive value of negative */
#define CONVERT_TO_UNSIGNED_ABSOLUTE 3
/*@}*/

/**
 * \defgroup DiscardFraction Discard Fraction
 *
 * In the FIR, calculations take place with fraction parts
 * When outputting this value, the fraction part must be removed
 * This group defines the methos for removign the fraction parts
 *
 @{*/
/** Truncate Fraction Bits */
#define FRACTION_BITS_TRUNCATE 1
/** Round Up Fraction Bits */
#define FRACTION_BITS_ROUND_HALF_UP 2
/** Round Even Fraction Bits */
#define FRACTION_BITS_ROUND_HALF_EVEN 3
/*@}*/

/**
 * \defgroup DataType Data Type
 *
 * In the FIR, calculations take place with signed or unsigned data
 * The group defines the data type.
 *
 @{*/
/** Unsigned Data */
#define DATA_TYPE_UNSIGNED 1
/** Signed Data */
#define DATA_TYPE_SIGNED  2
/*@}*/

//! A default FIFO depth, reasonably sensible in hardware
#define FIFO_DEPTH 500

// for controlling the kerneliser
#define KERNELISER_INTERLACED_BEHAVIOUR_OFF 0
#define KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F0 1
#define KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1 2
#define KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH 3
#define KERNELISER_NO_REGULAR_FIELD_DROP 0
#define KERNELISER_REGULAR_FIELD_DROP_F0 1 
#define KERNELISER_REGULAR_FIELD_DROP_F1 2
#define FIELD_F0_FIRST 0
#define FIELD_F1_FIRST 1

// Operations on adder trees
#define TREE_ADD 2
#define TREE_ADD_DEST(TREE, X) TREE[X * 4 + 3]
#define TREE_ADD_SRC_1(TREE, X) TREE[X * 4 + 1]
#define TREE_ADD_SRC_2(TREE, X) TREE[X * 4 + 2]
#define TREE_DEL 1
#define TREE_DEL_FROM(TREE, X) TREE[X * 4 + 1]
#define TREE_DEL_TO(TREE, X) TREE[X * 4 + 3]
#define TREE_MUL 3
#define TREE_MUL_COEFF(TREE, X) TREE[X * 4 + 2]
#define TREE_MUL_DEST(TREE, X) TREE[X * 4 + 3]
#define TREE_MUL_SRC(TREE, X) TREE[X * 4 + 1]
#define TREE_OP_TYPE(TREE, X) TREE[X * 4]

// Size of a Nibble in Avalon_ST Video 1.? control packets
#define HEADER_WORD_BITS 4
// The nibble that identifies Avalon_ST Video 1.? control packets
#define CONTROL_HEADER 15
// The nibble that identifies Avalon_ST Video 1.? image data packets
#define IMAGE_DATA 0

// We standardize the layout of the first few entries in control interfaces:
// Enable interrupts
static const unsigned int INTERRUPT_MASK_ADDR = 0;
// Read/clear the status of interrupts
static const unsigned int INTERRUPT_FLAGS_ADDR = 1;
// Make the core stop when it raises an interrupt
static const unsigned int STOP_ON_INTERRUPTS_ADDR = 2;

// The first interrupt is for stopping after having read the image data
// type, but before reading latching control information or doing any processing
static const unsigned int INTERRUPT_ON_NEW_FRAMES_BIT = 0;
// The second interrupt is after latching control data but before doing any
// processing
static const unsigned int INTERRUPT_ON_LATCHED_CONTROL_BIT = 1;
// So that cores know where to start their own interrup bits
static const unsigned int N_SYSTEM_INTERRUPT_BITS = 2;

#endif /*_VIP_CONSTANTS_H_*/
