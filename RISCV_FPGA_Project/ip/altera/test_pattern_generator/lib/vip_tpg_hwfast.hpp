/**
* \file vip_tpg_hwfast.hpp
*
* \author aharding
*
* \brief A test pattern generator.
*/

#ifndef __CUSP__
    #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
    #undef TPG_NAME
    #define TPG_NAME alt_vip_tpg
#endif

#define HW_DEBUG_MSG_ON
#ifndef HW_DEBUG_MSG
    #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_DEBUG_MSG(X) std::cout << sc_time_stamp() << ": " << name() << ", " << X
    #else
        #define HW_DEBUG_MSG(X)
    #endif
#endif // nHW_DEBUG_MSG

#ifndef vip_assert
    #if !defined(__CUSP__)
        #include <cassert>
        #define vip_assert(X) assert(X)
    #else
        #define vip_assert(X)
    #endif
#endif // nvip_assert

#ifndef LEGACY_FLOW
    #undef TPG_NAME
    #define TPG_NAME alt_vip_tpg
#endif

#ifndef SYNTH_MODE
#define TPG_BPS 20
#define TPG_CHANNELS_IN_PAR 3
#define TPG_DOUT_WIDTH 60
#else
#define TPG_DOUT_WIDTH (TPG_BPS * TPG_CHANNELS_IN_PAR)
#endif

// Even if it is synth mode these parameters may not be set and need a default
#ifndef TPG_CTRL_INTERFACE_WIDTH
#define TPG_CTRL_INTERFACE_WIDTH 16
#define TPG_CTRL_INTERFACE_DEPTH 10
#endif

// Different patterns allowed for TPG_PATTERN
#define TPG_PATTERN_COLORBARS 0
#define TPG_PATTERN_UNIFORM   1
#define TPG_PATTERN_GRADIENT   2

// Set TPG_IMAGE_WIDTH, TPG_IMAGE_HEIGHT and mores to registers or to constants
#if TPG_RUNTIME_CONTROL
    #define TPG_IMAGE_WIDTH width
    #if TPG_FORMAT == SAMPLE_444
        #define TPG_PATTERN_WIDTH width
    #else
        #define TPG_PATTERN_WIDTH sc_uint<TPG_LOG2G_MAX_WIDTH>(width >> 1)
    #endif
    #define TPG_PATTERN_WIDTH_WITHOUT_BORDER TPG_PATTERN_WIDTH - sc_uint<TPG_LOG2G_MAX_WIDTH>(2)
    #define TPG_IMAGE_HEIGHT height
    #if TPG_INTERLACE == PROGRESSIVE_FRAMES
        #if TPG_FORMAT == SAMPLE_420
            // TPG_IMAGE_HEIGHT - 4 rows of color bar in this case
            #define FIELD_PATTERN_HEIGHT (TPG_IMAGE_HEIGHT - sc_uint<TPG_LOG2G_MAX_HEIGHT>(4))
        #else
            // TPG_IMAGE_HEIGHT - 2 rows of color bar in all the other progressive cases
            #define FIELD_PATTERN_HEIGHT (TPG_IMAGE_HEIGHT - sc_uint<TPG_LOG2G_MAX_HEIGHT>(2))
        #endif
    #else
        // (TPG_IMAGE_HEIGHT - 2) / 2 rows of color bar per field in the interlaced case
        #define FIELD_PATTERN_HEIGHT ((TPG_IMAGE_HEIGHT - sc_uint<TPG_LOG2G_MAX_HEIGHT>(2)) >> 1)
    #endif
#else
    #define TPG_IMAGE_WIDTH TPG_MAX_WIDTH
    #if TPG_FORMAT == SAMPLE_444
        #define TPG_PATTERN_WIDTH TPG_MAX_WIDTH
    #else
        #define TPG_PATTERN_WIDTH (TPG_MAX_WIDTH / 2)
    #endif
    #define TPG_PATTERN_WIDTH_WITHOUT_BORDER TPG_PATTERN_WIDTH - 2
    #define TPG_IMAGE_HEIGHT TPG_MAX_HEIGHT
    #if TPG_INTERLACE == PROGRESSIVE_FRAMES
         #if TPG_FORMAT == SAMPLE_420
              // TPG_IMAGE_HEIGHT - 4 rows of color bar in this case
             #define FIELD_PATTERN_HEIGHT (TPG_IMAGE_HEIGHT - 4)
         #else
             // TPG_IMAGE_HEIGHT - 2 rows of color bar in all the other progressive cases
             #define FIELD_PATTERN_HEIGHT (TPG_IMAGE_HEIGHT - 2)
         #endif
    #else
         // (TPG_IMAGE_HEIGHT - 2) / 2 rows of color bar per field in the interlaced case
         #define FIELD_PATTERN_HEIGHT ((TPG_IMAGE_HEIGHT - 2) / 2)
    #endif
#endif

#if TPG_PARALLEL_MODE
    #if TPG_FORMAT == SAMPLE_422
        #define TPG_CHANNELS_IN_PAR 2
    #else
        #define TPG_CHANNELS_IN_PAR 3
    #endif
#else
    #define TPG_CHANNELS_IN_PAR 1
#endif

#if TPG_FORMAT == SAMPLE_444
    #if TPG_PARALLEL_MODE
        #define TPG_MOD_TARGET_PER_PATTERN 1
        #if TPG_COLORSPACE == COLORSPACE_RGB
            #define write_pattern(c1, c2, c3, eop)                                                                   \
            {                                                                                                        \
                dout->writeDataAndEop((sc_uint<TPG_BPS>(c1), sc_uint<TPG_BPS>(c2), sc_uint<TPG_BPS>(c3)), eop);      \
            }
        #else
            #define write_pattern(c1, c2, c3, eop)                                                                   \
            {                                                                                                        \
                dout->writeDataAndEop((sc_uint<TPG_BPS>(c1), sc_uint<TPG_BPS>(c3), sc_uint<TPG_BPS>(c2)), eop);      \
            }
        #endif
    #else
        #define TPG_MOD_TARGET_PER_PATTERN 3
        #if TPG_COLORSPACE == COLORSPACE_RGB
            #define write_pattern(c1, c2, c3, eop)                                                                   \
            {                                                                                                        \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c3), false);                                                  \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c2), false);                                                  \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), eop);                                                    \
            }
        #else
            #define write_pattern(c1, c2, c3, eop)                                                                   \
            {                                                                                                        \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c2), false);                                                  \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c3), false);                                                  \
                dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), eop);                                                    \
            }
        #endif
    #endif
#endif

#if TPG_FORMAT == SAMPLE_422
    #if TPG_PARALLEL_MODE
        #define TPG_MOD_TARGET_PER_PATTERN 2
        #define write_pattern(c1, c2, c3, eop)                                                                   \
        {                                                                                                        \
            dout->writeDataAndEop((sc_uint<TPG_BPS>(c1), sc_uint<TPG_BPS>(c2)), false);                          \
            dout->writeDataAndEop((sc_uint<TPG_BPS>(c1), sc_uint<TPG_BPS>(c3)), eop);                            \
        }
    #else
        #define TPG_MOD_TARGET_PER_PATTERN 4
        #define write_pattern(c1, c2, c3, eop)                                                                   \
        {                                                                                                        \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c2), false);                                                   \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), false);                                                   \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c3), false);                                                   \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), eop);                                                     \
        }
    #endif
#endif

#if TPG_FORMAT == SAMPLE_420
    #if TPG_PARALLEL_MODE
        #define TPG_MOD_TARGET_PER_PATTERN 1
        #define write_pattern(c1, c2, c3, eop)                                                                   \
        {                                                                                                        \
            vip_assert(c2 == c3);                                                                                \
            dout->writeDataAndEop((sc_uint<TPG_BPS>(c1), sc_uint<TPG_BPS>(c2), sc_uint<TPG_BPS>(c1)), eop);       \
        }
    #else
        #define TPG_MOD_TARGET_PER_PATTERN 3
        #define write_pattern(c1, c2, c3, eop)                                                                   \
        {                                                                                                        \
            vip_assert(c2 == c3);                                                                                \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), false);                                                   \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c2), false);                                                   \
            dout->writeDataAndEop(sc_uint<TPG_BPS>(c1), eop);                                                     \
        }
    #endif
    #define write_pattern_sample_420(c1, c2, eop) write_pattern(c1, c2, c2, eop)
#endif

#if TPG_INTERLACE != PROGRESSIVE_FRAMES
    // Define F0 and F1 flags from first_field_flag (defined later on)
    #if TPG_INTERLACE == INTERLACED_SYNC_F1
        #define F0_flag first_field_flag
        #define F1_flag !first_field_flag
    #else
        #define F0_flag !first_field_flag
        #define F1_flag first_field_flag
    #endif
#else
    #define F0_flag false
    #define F1_flag false
#endif


#if TPG_FORMAT != SAMPLE_420
    #define write_row(c1, c2, c3)                                                                                    \
    {                                                                                                                \
        for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(TPG_PATTERN_WIDTH, 1);                             \
            line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)               \
        {                                                                                                            \
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);                                                             \
            ALT_ATTRIB(ALT_MIN_ITER, 16); /* width in pattern should be at least 16 */                               \
            ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);                                                  \
            write_pattern(c1, c2, c3, false);                                                                        \
        }                                                                                                            \
    }
    #define write_row_with_final_eop(c1, c2, c3)                                                                     \
    {                                                                                                                \
        for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(TPG_PATTERN_WIDTH, 2);                             \
             line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)              \
        {                                                                                                            \
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);                                                             \
            ALT_ATTRIB(ALT_MIN_ITER, 15); /* width in pattern should be at least 16 */                               \
            ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);                                                  \
            write_pattern(c1, c2, c3, false);                                                                        \
        }                                                                                                            \
        write_pattern(c1, c2, c3, true);                                                                             \
    }
#else
    #define write_two_rows(c1, c2, c3)                                                                               \
    {                                                                                                                \
        for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(TPG_IMAGE_WIDTH, 1);                               \
            line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)               \
        {                                                                                                            \
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);                                                             \
            ALT_ATTRIB(ALT_MIN_ITER, 16); /* width in pattern should be at least 16 */                               \
            ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);                                                  \
            write_pattern(c1, c2, c3, false);                                                                        \
        }                                                                                                            \
    }
    #define write_two_rows_with_final_eop(c1, c2, c3)                                                                \
    {                                                                                                                \
        for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(TPG_IMAGE_WIDTH, 2);                               \
             line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)              \
        {                                                                                                            \
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);                                                             \
            ALT_ATTRIB(ALT_MIN_ITER, 15); /* width in pattern should be at least 16 */                               \
            ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);                                                  \
            write_pattern(c1, c2, c3, false);                                                                        \
        }                                                                                                            \
        write_pattern(c1, c2, c3, true);                                                                             \
    }
#endif

// For writing control packet data abstracting away the fact that control packets are sent with each symbol,
// and can come in parallel. To decide which to do, it needs to know how many times it has been called. It will
// do an actual write when occurrence % CHANNELS_IN_PAR == CHANNELS_IN_PAR-1
// @param occurrence the amount of times this function has been called in a sequence
#define write_nibble(occurrence, data, eop)                                                                            \
{                                                                                                                      \
    if ((occurrence%TPG_CHANNELS_IN_PAR) == 0)                                                                         \
    {                                                                                                                  \
        write_wire = sc_uint<TPG_BPS>(data);                                                                           \
    }                                                                                                                  \
    else                                                                                                               \
    {                                                                                                                  \
        sc_uint<TPG_BPS> data_wire BIND(ALT_WIRE);                                                                     \
        data_wire = 0;                                                                                                 \
        data_wire = data;                                                                                              \
        write_wire = (data_wire, sc_uint<TPG_BPS*(occurrence%TPG_CHANNELS_IN_PAR)>(write_wire));                       \
    }                                                                                                                  \
    if (((occurrence%TPG_CHANNELS_IN_PAR) == (TPG_CHANNELS_IN_PAR-1)) || eop)                                          \
    {                                                                                                                  \
        dout->writeDataAndEop(write_wire, eop);                                                                        \
    }                                                                                                                  \
}

SC_MODULE(TPG_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/test_pattern_generator.jar?com.altera.vip.entityinterfaces.helpers.TPGEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Test Pattern Generator";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Test Pattern Generator is a core that generates video fields with color bars according to the specifications of the Avalon-ST Video protocol.";
    }

    static const char * get_product_ids(void)
    {
        return "00CA";
    }
    #include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif // LEGACY_FLOW

    // Output port
    ALT_AVALON_ST_OUTPUT< sc_uint<TPG_DOUT_WIDTH> > *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;

    // Control interface
    ALT_AVALON_MM_MEM_SLAVE<TPG_CTRL_INTERFACE_WIDTH, TPG_CTRL_INTERFACE_DEPTH> *control ALT_CUSP_DISABLE_NUMBER_SUFFIX;

#ifdef SYNTH_MODE

    #if TPG_RUNTIME_CONTROL
        // Latched parameters
        sc_uint<TPG_LOG2G_MAX_WIDTH> width;
        sc_uint<TPG_LOG2G_MAX_HEIGHT> height;
    #endif

        // Loop counters and associated AUs
        // Associate an AU with the line_pattern counter so that it is used each time write_black_pixel_row is called
        // 1 more bits is used to count with a sc_int down to -1
    #if TPG_FORMAT != SAMPLE_420
        #define TPG_LINE_PATTERN_COUNTER_WIDTH TPG_LOG2G_MAX_PATTERN_WIDTH + 1
        ALT_AU<TPG_LINE_PATTERN_COUNTER_WIDTH> LINE_PATTERN_COUNTER_AU;
        sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH> line_pattern_counter BIND(LINE_PATTERN_COUNTER_AU);
    #else // 1 extra bits is used with write_two_rows
        #define TPG_LINE_PATTERN_COUNTER_WIDTH TPG_LOG2G_MAX_PATTERN_WIDTH + 2
        ALT_AU<TPG_LINE_PATTERN_COUNTER_WIDTH> LINE_PATTERN_COUNTER_AU;
        sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH> line_pattern_counter BIND(LINE_PATTERN_COUNTER_AU);
    #endif
    sc_uint<TPG_LOG2G_MAX_HEIGHT> height_counter;

    #if TPG_INTERLACE != PROGRESSIVE_FRAMES
        // A boolean flag to track the current field in INTERLACED model, true if this is the first field of a frame
        // The first field is a F0 if TPG_INTERLACE == INTERLACED_SYNC_F1 and a F1 if TPG_INTERLACE == INTERLACED_SYNC_F0
        bool first_field_flag;
    #endif

    #if TPG_PATTERN == TPG_PATTERN_COLORBARS
    void output_colorbars()
    {
        // Width of the image in pattern (excluding black borders) = pattern_width - 2
        sc_uint<TPG_LOG2G_MAX_PATTERN_WIDTH> pattern_width_without_border;
        sc_uint<TPG_LOG2G_MAX_BARWIDTH> bar_pattern_width;        // Width of a color bar (in pattern not pixel)
        sc_uint<TPG_LOG2G_MAX_BARWIDTH> bar_pattern_counter_init; // For the counters from bar_pattern_width - 1 to 0 (included)

        // Counter on the width of a color bar
        ALT_AU<TPG_LOG2G_MAX_BARWIDTH> BAR_PATTERN_WIDTH_COUNTER_AU;
        sc_uint<TPG_LOG2G_MAX_BARWIDTH> bar_pattern_width_counter BIND(BAR_PATTERN_WIDTH_COUNTER_AU);
        // Current color bar (from 0 to 7)
        ALT_AU<TPG_LOG2G_BAR_ID> BAR_COUNTER_AU;
        sc_uint<TPG_LOG2G_BAR_ID> bar_counter BIND(BAR_COUNTER_AU);

        // Color bar values (as defined in the ParameterHelper)
        sc_uint<TPG_BPS> values_c1[TPG_NUMBER_BARS] = TPG_COLORBARS_VALUES_C1;
        sc_uint<TPG_BPS> values_c2[TPG_NUMBER_BARS] = TPG_COLORBARS_VALUES_C2;
        sc_uint<TPG_BPS> values_c3[TPG_NUMBER_BARS] = TPG_COLORBARS_VALUES_C3;

        pattern_width_without_border = TPG_PATTERN_WIDTH_WITHOUT_BORDER;
        vip_assert(TPG_NUMBER_BARS == 8); //To be sure that the next line makes sense
        bar_pattern_width = pattern_width_without_border >> 3;
        // bar_pattern_width_counter is going from bar_pattern_width - 1 downto 0 (included)
        bar_pattern_counter_init = bar_pattern_width - sc_uint<TPG_LOG2G_MAX_BARWIDTH>(1);

        HW_DEBUG_MSG("width in pattern repetition (and without black border)=" << pattern_width_without_border << std::endl);
        HW_DEBUG_MSG("width of a color bar in pattern repetition=" << bar_pattern_width << std::endl);

        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                // Start with an initial black pixels row,
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // Special case for YCbCr 420 (always progressive), the up/down borders are 2 pixels high
                write_two_rows(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT != SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            if (F0_flag)
            {
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3); // Cannot be 420
            }
        #endif // TPG_INTERLACE != PROGRESSIVE_FRAMES

        for (height_counter = FIELD_PATTERN_HEIGHT; height_counter != sc_uint<TPG_LOG2G_MAX_HEIGHT>(0); height_counter--)
        {
            bar_counter = 0; // Initialise bar_counter to 0
            // set bar_pattern_width_counter to bar_pattern_counter_init (first initialisation is done later on)
            bar_pattern_width_counter = bar_pattern_counter_init;
            // Start a row with the black border (1 or 2 pixels depending on the subsampling)
            write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(pattern_width_without_border, 1);
                 line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 14);    // pattern_width_without_border should be at least 14
                ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);
                #if TPG_FORMAT != SAMPLE_420
                    write_pattern(values_c1[bar_counter], values_c2[bar_counter], values_c3[bar_counter], false);
                #else // TPG_FORMAT == SAMPLE_420
                    // height_counter starts at value TPG_IMAGE_HEIGHT - 4 which is an even value
                    write_pattern_sample_420(values_c1[bar_counter], (height_counter.bit(0) ? values_c3[bar_counter] : values_c2[bar_counter]), false);
                #endif // TPG_FORMAT == SAMPLE_420
                // Create a wire to put the comparison of bar_pattern_width_counter to 0 (it is used twice)
                bool bar_pattern_width_counter_equal_zero BIND(ALT_WIRE) = (bar_pattern_width_counter == sc_uint<TPG_LOG2G_MAX_BARWIDTH>(0));
                // Switch to the next bar if bar_pattern_width_counter reached 0 (unless it is already the last bar)
                bar_counter = BAR_COUNTER_AU.cAddSubUI(bar_counter, 1, bar_counter,
                                                       bar_pattern_width_counter_equal_zero &&
                                                       (bar_counter != sc_uint<TPG_LOG2G_BAR_ID>(TPG_NUMBER_BARS - 1)),
                                                       false);
                // Reinitialise bar_pattern_width_counter to bar_pattern_width-1 if 0 was reached
                bar_pattern_width_counter = BAR_PATTERN_WIDTH_COUNTER_AU.addSubSLdUI(
                                                bar_pattern_width_counter, 1,                                              // -1 in general case
                                                bar_pattern_counter_init,
                                                bar_pattern_width_counter_equal_zero,                                      // But reload at 0
                                                true);
            }
            // Finish a row with the black border (1 or 2 pixels depending on the subsampling)
            #if TPG_INTERLACE == PROGRESSIVE_FRAMES
                write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            #else
                // Send the end of packet if this is the last line of a F0 field (because there is no black line to conclude)
                write_pattern(values_c1[bar_counter], values_c2[bar_counter], values_c3[bar_counter],
                              F0_flag && (height_counter == sc_uint<TPG_LOG2G_MAX_HEIGHT>(1)));
            #endif
        }

        // Conclude with a last black pixels row (and its eop)
        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // There are 2 black rows when the 420 subsampling is used
                write_two_rows_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT == SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            // In the interlaced case the black line is only on F1
            if (F1_flag)
            {
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            }
        #endif
    }
    #endif //TPG_PATTERN == TPG_PATTERN_COLORBARS

    #if TPG_PATTERN == TPG_PATTERN_UNIFORM

    #if TPG_RUNTIME_CONTROL
    // Uniform background using colors set by slave interface
    sc_uint<TPG_BPS> val_c1;
    sc_uint<TPG_BPS> val_c2;
    sc_uint<TPG_BPS> val_c3;
    #endif
    void output_uniform()
    {

        // Uniform background using constant colors (Cusp cannot handle const)
        #if !TPG_RUNTIME_CONTROL
            #define val_c1 sc_uint<TPG_BPS>(TPG_UNIFORM_VAL_C1)
            #define val_c2 sc_uint<TPG_BPS>(TPG_UNIFORM_VAL_C2)
            #define val_c3 sc_uint<TPG_BPS>(TPG_UNIFORM_VAL_C3)
        #endif

        sc_uint<TPG_LOG2G_MAX_PATTERN_WIDTH> pattern_width_without_border = TPG_PATTERN_WIDTH_WITHOUT_BORDER;

        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                // Start with an initial black pixels row,
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // Special case for YCbCr 420 (always progressive), the up/down borders are 2 pixels high
                write_two_rows(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT != SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            if (F0_flag)
            {
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3); // Cannot be 420
            }
        #endif // TPG_INTERLACE != PROGRESSIVE_FRAMES

        for (height_counter = FIELD_PATTERN_HEIGHT; height_counter != sc_uint<TPG_LOG2G_MAX_HEIGHT>(0); height_counter--)
        {
            // Start a row with the black border (1 or 2 pixels depending on the subsampling)
            write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(pattern_width_without_border, 1);
                 line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 14);    // pattern_width_without_border should be at least 14
                ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);
                #if TPG_FORMAT != SAMPLE_420
                    write_pattern(val_c1, val_c2, val_c3, false);
                #else // TPG_FORMAT == SAMPLE_420
                    // height_counter starts at value TPG_IMAGE_HEIGHT - 4 which is an even value
                    write_pattern_sample_420(val_c1, (height_counter.bit(0) ? val_c3 : val_c2), false);
                #endif // TPG_FORMAT == SAMPLE_420
            }
            // Finish a row with the black border (1 or 2 pixels depending on the subsampling)
            #if TPG_INTERLACE == PROGRESSIVE_FRAMES
                write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            #else
                // Send the end of packet if this is the last line of a F0 field (because there is no black line to conclude)
                write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3,
                              F0_flag && (height_counter == sc_uint<TPG_LOG2G_MAX_HEIGHT>(1)));
            #endif
        }

        // Conclude with a last black pixels row (and its eop)
        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // There are 2 black rows when the 420 subsampling is used
                write_two_rows_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT == SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            // In the interlaced case the black line is only on F1
            if (F1_flag)
            {
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            }
        #endif
    }
    #endif //TPG_PATTERN == TPG_PATTERN_UNIFORM


    #if TPG_PATTERN == TPG_PATTERN_GRADIENT
    // Uniform background using colors set by slave interface
    sc_uint<TPG_BPS> val_c1;
    sc_uint<TPG_BPS> val_c2;
    sc_uint<TPG_BPS> val_c3;
    sc_uint<TPG_BPS> val_c1_e;
    sc_uint<TPG_BPS> val_c2_e;
    sc_uint<TPG_BPS> val_c3_e;

    void output_gradient()
    {
        DECLARE_VAR_WITH_AU(sc_uint<TPG_BPS>, TPG_BPS, c1);
        DECLARE_VAR_WITH_AU(sc_uint<TPG_BPS>, TPG_BPS, c2);
        DECLARE_VAR_WITH_AU(sc_uint<TPG_BPS>, TPG_BPS, c3);
        sc_uint<TPG_LOG2G_MAX_PATTERN_WIDTH> pattern_width_without_border = TPG_PATTERN_WIDTH_WITHOUT_BORDER;

        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                // Start with an initial black pixels row,
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // Special case for YCbCr 420 (always progressive), the up/down borders are 2 pixels high
                write_two_rows(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT != SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            if (F0_flag)
            {
                write_row(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3); // Cannot be 420
            }
        #endif // TPG_INTERLACE != PROGRESSIVE_FRAMES

        for (height_counter = FIELD_PATTERN_HEIGHT; height_counter != sc_uint<TPG_LOG2G_MAX_HEIGHT>(0); height_counter--)
        {
            // Start a row with the black border (1 or 2 pixels depending on the subsampling)
            write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            c1 = val_c1;
            c2 = val_c2;
            c3 = val_c3;
            for (line_pattern_counter = LINE_PATTERN_COUNTER_AU.subUI(pattern_width_without_border, 1);
                 line_pattern_counter >= sc_int<TPG_LINE_PATTERN_COUNTER_WIDTH>(0); line_pattern_counter--)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 14);    // pattern_width_without_border should be at least 14
                ALT_ATTRIB(ALT_MOD_TARGET, TPG_MOD_TARGET_PER_PATTERN);
                #if TPG_FORMAT != SAMPLE_420
                    write_pattern(c1, c2, c3, false);
                #else // TPG_FORMAT == SAMPLE_420
                    // height_counter starts at value TPG_IMAGE_HEIGHT - 4 which is an even value
                    write_pattern_sample_420(c1, (height_counter.bit(0) ? c3 : c2), false);
                #endif // TPG_FORMAT == SAMPLE_420
                bool c1_equal_c1e BIND(ALT_WIRE) = (c1 == val_c1_e);
                bool c2_equal_c2e BIND(ALT_WIRE) = (c2 == val_c2_e);
                bool c3_equal_c3e BIND(ALT_WIRE) = (c3 == val_c3_e);
                bool all_equal BIND(ALT_WIRE) = c1_equal_c1e && c2_equal_c2e && c3_equal_c3e;
                c1 = c1_AU.cAddSubSLdUI(c1, sc_uint<1>(1), val_c1, c1, all_equal || !c1_equal_c1e, all_equal, (val_c1 > val_c1_e));
                c2 = c2_AU.cAddSubSLdUI(c2, sc_uint<1>(1), val_c2, c2, all_equal || !c2_equal_c2e, all_equal, (val_c2 > val_c2_e));
                c3 = c3_AU.cAddSubSLdUI(c3, sc_uint<1>(1), val_c3, c3, all_equal || !c3_equal_c3e, all_equal, (val_c3 > val_c3_e));
            }
            // Finish a row with the black border (1 or 2 pixels depending on the subsampling)
            #if TPG_INTERLACE == PROGRESSIVE_FRAMES
                write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3, false);
            #else
                // Send the end of packet if this is the last line of a F0 field (because there is no black line to conclude)
                write_pattern(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3,
                              F0_flag && (height_counter == sc_uint<TPG_LOG2G_MAX_HEIGHT>(1)));
            #endif
        }

        // Conclude with a last black pixels row (and its eop)
        #if TPG_INTERLACE == PROGRESSIVE_FRAMES
            #if TPG_FORMAT != SAMPLE_420
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #else
                // There are 2 black rows when the 420 subsampling is used
                write_two_rows_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            #endif // TPG_FORMAT == SAMPLE_420
        #else // TPG_INTERLACE != PROGRESSIVE_FRAMES
            // In the interlaced case the black line is only on F1
            if (F1_flag)
            {
                write_row_with_final_eop(TPG_BLACK_C1, TPG_BLACK_C2, TPG_BLACK_C3);
            }
        #endif
    }
    #endif //TPG_PATTERN == TPG_PATTERN_GRADIENT

    void behaviour()
    {
        #if TPG_RUNTIME_CONTROL
            // Set to stop on new frame at initialisation
            control->writeUI(CTRL_GO_ADDRESS, 0);
        #endif

        for (;;)
        {
            // Check width and height every new frame if there is a runtime control
            #if TPG_RUNTIME_CONTROL
#if TPG_INTERLACE != PROGRESSIVE_FRAMES
                // In case of interlaced video, check the runtime parameters and deal with interrupt every frame, not every field
                if (first_field_flag)
                {
#endif // TPG_INTERLACE != PROGRESSIVE_FRAMES
                    control->writeUI(CTRL_Status_ADDRESS, 0);
                    // Check the GO bit before starting to process control data
                    while (sc_uint<1>(control->readUI(CTRL_GO_ADDRESS)) != sc_uint<1>(1))
                        control->waitForChange();
                    height = control->readUI(CTRL_HEIGHT_ADDRESS);
                    width = control->readUI(CTRL_WIDTH_ADDRESS);
                    #if (TPG_PATTERN == TPG_PATTERN_UNIFORM) || (TPG_PATTERN == TPG_PATTERN_GRADIENT)
                        val_c1 = control->readUI(CTRL_C1_ADDRESS);
                        val_c2 = control->readUI(CTRL_C2_ADDRESS);
                        val_c3 = control->readUI(CTRL_C3_ADDRESS);
                        #if (TPG_PATTERN == TPG_PATTERN_GRADIENT)
                            val_c1_e = control->readUI(CTRL_C1E_ADDRESS);
                            val_c2_e = control->readUI(CTRL_C2E_ADDRESS);
                            val_c3_e = control->readUI(CTRL_C3E_ADDRESS);
                        #endif
                    #endif
                    control->writeUI(CTRL_Status_ADDRESS, 1);

#if TPG_INTERLACE != PROGRESSIVE_FRAMES
                }
#endif // TPG_INTERLACE != PROGRESSIVE_FRAMES
            #endif // TPG_RUNTIME_CONTROL

            HW_DEBUG_MSG("Producing pattern, field width=" << TPG_IMAGE_WIDTH << ", field height="
                         << ((TPG_INTERLACE == PROGRESSIVE_FRAMES) ? int(TPG_IMAGE_HEIGHT) : int(TPG_IMAGE_HEIGHT >> 1))
                         << ", subsampling=" << TPG_FORMAT << ", interlace flag=" << TPG_INTERLACE << std::endl);
            // Write the flag to identify the next packet as a control packet
            dout->writeDataAndEop(CONTROL_HEADER, false);

            sc_uint<TPG_DOUT_WIDTH> write_wire BIND(ALT_WIRE);
            write_nibble(0, sc_uint<HEADER_WORD_BITS>(
                             (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_WIDTH)).range((4*HEADER_WORD_BITS) - 1, 3*HEADER_WORD_BITS)), false);
            write_nibble(1, sc_uint<HEADER_WORD_BITS>(
                             (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_WIDTH)).range((3*HEADER_WORD_BITS) - 1, 2*HEADER_WORD_BITS)), false);
            write_nibble(2, sc_uint<HEADER_WORD_BITS>(
                             (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_WIDTH)).range((2*HEADER_WORD_BITS) - 1, 1*HEADER_WORD_BITS)), false);
            write_nibble(3, sc_uint<HEADER_WORD_BITS>(
                             (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_WIDTH)).range((1*HEADER_WORD_BITS) - 1, 0*HEADER_WORD_BITS)), false);
            #if TPG_INTERLACE == PROGRESSIVE_FRAMES
                write_nibble(4, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((4*HEADER_WORD_BITS) - 1, 3*HEADER_WORD_BITS)), false);
                write_nibble(5, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((3*HEADER_WORD_BITS) - 1, 2*HEADER_WORD_BITS)), false);
                write_nibble(6, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((2*HEADER_WORD_BITS) - 1, 1*HEADER_WORD_BITS)), false);
                write_nibble(7, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((1*HEADER_WORD_BITS) - 1, 0*HEADER_WORD_BITS)), false);
            #else
                // Interlaced frames need field height, not frame height
                write_nibble(4, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((4*HEADER_WORD_BITS) - 1, 3*HEADER_WORD_BITS + 1)), false);
                write_nibble(5, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((3*HEADER_WORD_BITS), 2*HEADER_WORD_BITS + 1)), false);
                write_nibble(6, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((2*HEADER_WORD_BITS), HEADER_WORD_BITS + 1)), false);
                write_nibble(7, sc_uint<HEADER_WORD_BITS>(
                        (sc_uint<4*HEADER_WORD_BITS>(TPG_IMAGE_HEIGHT)).range((1*HEADER_WORD_BITS), 1)), false);
            #endif

            // The two synchronization bits are either 10 (progressive frame) or sync unknown (interlaced fields)
            // It was decided in 9.1 that:
            // 1) the TPG will not use 1x00 and 1x01 since this clearly flags PsF content and may be handled differently by other cores
            // 2) the TPG will use 0010 for progressive output
            sc_uint<HEADER_WORD_BITS> interlace_nibble;
            interlace_nibble = (sc_uint<1>(TPG_INTERLACE != PROGRESSIVE_FRAMES), sc_uint<1>(F1_flag),
                                   sc_uint<1>(1), sc_uint<1>(0));
            write_nibble(8, interlace_nibble, true);

            // Write the flag to identify the next packet as IMAGE_DATA
            dout->writeDataAndEop(IMAGE_DATA, false);

            #if TPG_PATTERN == TPG_PATTERN_COLORBARS
                output_colorbars();
            #endif
            #if TPG_PATTERN == TPG_PATTERN_UNIFORM
                output_uniform();
            #endif
            #if TPG_PATTERN == TPG_PATTERN_GRADIENT
                output_gradient();
            #endif

            #if TPG_INTERLACE != PROGRESSIVE_FRAMES
                first_field_flag = !first_field_flag; // Switch first field flag for next field
            #endif // TPG_INTERLACE != PROGRESSIVE_FRAMES
        } // End of forever loop
    } // End of behaviour thread
#endif //SYNTH_MODE

    const char* param;
    SC_HAS_PROCESS(TPG_NAME);
    TPG_NAME(sc_module_name name_, int channels_in_par = 1, int ctrl_interface_depth = 10,
             const char* PARAMETERISATION = "<testPatternGeneratorParams><TPG_NAME>MyPatternGenerator</TPG_NAME><TPG_RUNTIME_CONTROL>0</TPG_RUNTIME_CONTROL><TPG_BPS>8</TPG_BPS><TPG_MAX_WIDTH>640</TPG_MAX_WIDTH><TPG_MAX_HEIGHT>480</TPG_MAX_HEIGHT><TPG_COLORSPACE>COLORSPACE_RGB</TPG_COLORSPACE><TPG_FORMAT>SAMPLE_444</TPG_FORMAT><TPG_INTERLACE>PROGRESSIVE_FRAMES</TPG_INTERLACE><TPG_PARALLEL_MODE>0</TPG_PARALLEL_MODE></testPatternGeneratorParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint<TPG_DOUT_WIDTH> >();
        control = NULL;

#ifdef LEGACY_FLOW
        #if TPG_RUNTIME_CONTROL
            control = new ALT_AVALON_MM_MEM_SLAVE <TPG_CTRL_INTERFACE_WIDTH, TPG_CTRL_INTERFACE_DEPTH>();
            control->setUseOwnClock(false);
        #endif
        dout->setSymbolsPerBeat(TPG_CHANNELS_IN_PAR);
#else
        int bps=ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "testPatternGeneratorParams;TPG_BPS", 8);
        dout->setDataWidth(bps*channels_in_par);
        dout->setSymbolsPerBeat(channels_in_par);
        dout->enableEopSignals();
        bool control_enabled = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "testPatternGeneratorParams;TPG_RUNTIME_CONTROL", false);
        if(control_enabled) {
            // Width and depth parameters are static
            control = new ALT_AVALON_MM_MEM_SLAVE <TPG_CTRL_INTERFACE_WIDTH, TPG_CTRL_INTERFACE_DEPTH>();
            control->setDepth(ctrl_interface_depth);
            control->setUseOwnClock(false);
        }
#endif

#ifdef SYNTH_MODE
        #if TPG_INTERLACE != PROGRESSIVE_FRAMES
            first_field_flag = true;
        #endif // TPG_INTERLACE != PROGRESSIVE_FRAMES
        SC_THREAD(behaviour);
#endif // SYNTH_MODE
    }
};
