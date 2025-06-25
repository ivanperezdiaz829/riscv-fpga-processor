//! \file vip_crs_hwfast.hpp
//!
//! \author aharding
//!
//! \brief Synthesisable Chroma Resampler core.

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes 
// These workaround SPR 242851: ArrayIndexOutOfBoundsException for loop index reversal
#pragma cusp_config loopBoundsDetection = no
#pragma cusp_config loopIndexReversal = no
#pragma cusp_config optimiseConstantVariables = yes
#pragma cusp_config registerToExtendLifetime = no

#ifndef __CUSP__
 #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
 #undef CRS_NAME
 #define CRS_NAME alt_vip_crs
#endif

// Maps an array that would be x[sequence][parallel][n] to a 1d array.
// Assumes that sequence_cnt and parallel_cnt are visible counters
#define FLAT_CHANNELS_IN_SEQ_PAR(X) (((X)*H_IN_CHANNELS_IN_SEQ+sequence_cnt)*H_IN_CHANNELS_IN_PAR+parallel_cnt) 
// Consistent was of counting channels used in some parallel/sequential configuration
#define SEQ_PAR_TO_CHANNEL ((sequence_cnt*H_IN_CHANNELS_IN_PAR)+parallel_cnt) 
// Like FLAT_CHANNELS_IN_SEQ_PAR, but takes the counters explicitly
#define EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(X, SEQUENCE_CNT, PARALLEL_CNT) (((X)*H_IN_CHANNELS_IN_SEQ+(SEQUENCE_CNT))*H_IN_CHANNELS_IN_PAR+PARALLEL_CNT)

// Like above, except for vertical resampling, which may have a different
// number of channels in parallel/sequence
#define V_FLAT_CHANNELS_IN_SEQ(X) ((X)*V_CHANNELS_IN_SEQ+sequence_cnt)
#define V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(X, SEQUENCE_CNT) ((X)*V_CHANNELS_IN_SEQ+(SEQUENCE_CNT))

//! Perform Chroma Resampling on frame.
SC_MODULE(CRS_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/chroma_resampler.jar?com.altera.vip.entityinterfaces.helpers.CRSEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Chroma Resampler";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Chroma Resampler resamples video data to and from common sampling formats including, 4:4:4, 4:2:2 and 4:2:0";
    }

    static const char * get_product_ids(void)
    {
        return "00B1";
    }

#include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif //LEGACY_FLOW

#ifndef SYNTH_MODE
#define CRS_BPS 20
#define CRS_IN_CHANNELS_IN_PAR 3
#define CRS_OUT_CHANNELS_IN_PAR 3
#endif
    
    //! Input ports
    ALT_AVALON_ST_INPUT< sc_uint<CRS_BPS*CRS_IN_CHANNELS_IN_PAR> > *din  ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    //! Output ports
    ALT_AVALON_ST_OUTPUT< sc_uint<CRS_BPS*CRS_OUT_CHANNELS_IN_PAR > > *dout  ALT_CUSP_DISABLE_NUMBER_SUFFIX;    
    
#ifdef SYNTH_MODE

    static const int I_BITS = LOG2G_WIDTH;
    static const int J_BITS = LOG2G_HEIGHT;
    static const int I_J_BITS = LOG2G_WIDTH_HEIGHT - 1;
    static const unsigned int LOTS_OF_BITS = 64;
    static const unsigned int H_INPUT_BITS = H_IN_CHANNELS_IN_PAR * CRS_BPS;
    static const unsigned int V_INPUT_BITS = V_IN_CHANNELS_IN_PAR * CRS_BPS;

    // Dimensions used for runtime mode
    sc_uint<I_BITS> width;
    sc_uint<I_BITS> v_width;

#define H_RESAMPLING (CRS_RESAMPLING_FORMAT_IN == 444 || CRS_RESAMPLING_FORMAT_OUT == 444)
#define V_RESAMPLING (CRS_RESAMPLING_FORMAT_IN == 420 || CRS_RESAMPLING_FORMAT_OUT == 420)
#define H_AND_V_RESAMPLING (H_RESAMPLING && V_RESAMPLING)
#define H_OWNS_DIN (CRS_RESAMPLING_FORMAT_IN == 444 || (CRS_RESAMPLING_FORMAT_IN == 422 && CRS_RESAMPLING_FORMAT_OUT == 444))
#define H_OWNS_DOUT (CRS_RESAMPLING_FORMAT_OUT == 444 || (CRS_RESAMPLING_FORMAT_IN == 444 && CRS_RESAMPLING_FORMAT_OUT == 422))
#define V_OWNS_DIN (!H_OWNS_DIN)
#define V_OWNS_DOUT (!H_OWNS_DOUT)

    // For passing data between horizontal/vertical resampling threads
    ALT_FIFO<sc_uint<CRS_BPS * FIFO_CHANNELS_IN_PAR + 1>, 3> *inter_thread_fifo;

#if H_AND_V_RESAMPLING

// Setup communication for the v thread
#define PACKET_ENTRY_POINT v_handleNonImagePackets
#define PACKET_HEADER_TYPE_VAR v_headerType
#define PACKET_JUST_READ_VAR v_justRead
#define PACKET_WIDTH_VAR v_widthFromControlPacket
#define PACKET_HEIGHT_VAR v_height

#if H_OWNS_DIN

#define PACKET_BPS CRS_BPS
#define PACKET_CHANNELS_IN_PAR FIFO_CHANNELS_IN_PAR
#define PACKET_CHANNELS_IN_PAR_OUTPUT CRS_OUT_CHANNELS_IN_PAR
#define PACKET_INPUT inter_thread_fifo
#define PACKET_OUTPUT dout
#include "vip_packet_reader_fifo_to_st.hpp"

#else

#define PACKET_BPS CRS_BPS
#define PACKET_CHANNELS_IN_PAR CRS_IN_CHANNELS_IN_PAR
#define PACKET_CHANNELS_IN_PAR_OUTPUT FIFO_CHANNELS_IN_PAR
#define PACKET_INPUT din
#define PACKET_OUTPUT inter_thread_fifo
#include "vip_packet_reader_st_to_fifo.hpp"

#endif // H_OWNS_DIN

#undef PACKET_INPUT
#undef PACKET_OUTPUT
#undef PACKET_ENTRY_POINT
#undef PACKET_BPS
#undef PACKET_CHANNELS_IN_PAR 
#undef PACKET_CHANNELS_IN_PAR_OUTPUT 
#undef PACKET_HEADER_TYPE_VAR 
#undef PACKET_JUST_READ_VAR 
#undef PACKET_WIDTH_VAR 
#undef PACKET_HEIGHT_VAR 


// Setup communication for the h thread
#define PACKET_ENTRY_POINT handleNonImagePackets
#define PACKET_HEADER_TYPE_VAR headerType
#define PACKET_JUST_READ_VAR justRead
#define PACKET_WIDTH_VAR widthFromControlPacket
#define PACKET_HEIGHT_VAR height

#if H_OWNS_DIN

#define PACKET_BPS CRS_BPS
#define PACKET_CHANNELS_IN_PAR CRS_IN_CHANNELS_IN_PAR
#define PACKET_CHANNELS_IN_PAR_OUTPUT FIFO_CHANNELS_IN_PAR
#define PACKET_INPUT din
#define PACKET_OUTPUT inter_thread_fifo
#include "vip_packet_reader_st_to_fifo.hpp"

#else

#define PACKET_BPS CRS_BPS
#define PACKET_CHANNELS_IN_PAR FIFO_CHANNELS_IN_PAR
#define PACKET_CHANNELS_IN_PAR_OUTPUT CRS_OUT_CHANNELS_IN_PAR
#define PACKET_INPUT inter_thread_fifo
#define PACKET_OUTPUT dout
#include "vip_packet_reader_fifo_to_st.hpp"

#endif // H_OWNS_DIN

#undef PACKET_INPUT
#undef PACKET_OUTPUT
#undef PACKET_ENTRY_POINT
#undef PACKET_BPS
#undef PACKET_CHANNELS_IN_PAR 
#undef PACKET_CHANNELS_IN_PAR_OUTPUT 
#undef PACKET_HEADER_TYPE_VAR 
#undef PACKET_JUST_READ_VAR 
#undef PACKET_WIDTH_VAR 
#undef PACKET_HEIGHT_VAR 

#else // H_AND_V_RESAMPLING
#define PACKET_HEADER_TYPE_VAR headerType
#define PACKET_JUST_READ_VAR justRead

#if H_OWNS_DIN
#define PACKET_ENTRY_POINT handleNonImagePackets
#define PACKET_WIDTH_VAR widthFromControlPacket
#define PACKET_HEIGHT_VAR height
#else
#define PACKET_ENTRY_POINT v_handleNonImagePackets
#define PACKET_WIDTH_VAR v_widthFromControlPacket
#define PACKET_HEIGHT_VAR v_height
#endif

#define PACKET_BPS CRS_BPS
#define PACKET_CHANNELS_IN_PAR CRS_IN_CHANNELS_IN_PAR
#define PACKET_CHANNELS_IN_PAR_OUTPUT CRS_OUT_CHANNELS_IN_PAR
#include "vip_packet_reader.hpp"
#endif // H_AND_V_RESAMPLING

    // Top-level thread for horizontal resampling
    void h_resampling()
    {
#if H_RESAMPLING
        for (;;)
        {
            handleNonImagePackets();

            width = widthFromControlPacket >> 1;

            // The type for the image data that follows
            H_OUTPUT->write(IMAGE_DATA);

            // Process a frame
            h_resample_frame();

        }
#endif // H_RESAMPLING
    }

    // Top-level thread for vertical resampling
    void v_resampling()
    {
#if V_RESAMPLING
        for (;;)
        {

            v_handleNonImagePackets();

            v_width = v_widthFromControlPacket >> 1;

            // The type for the image data that follows
            V_OUTPUT->write(IMAGE_DATA);

            // Process a frame
            v_resample_frame();

        }
#endif // V_RESAMPLING
    }

#if H_RESAMPLING
#if CRS_ALGORITHM_H_NAME == INTERPOLATION_1D_NEAREST_NEIGHBOUR

    void h_process_sample()
    {
#if CRS_PARALLEL_MODE

        sc_uint<H_INPUT_BITS> fat_input1, fat_input2;
        DECLARE_WIRES(sc_uint<CRS_BPS>, inputs);
#else

        ALT_REG<CRS_BPS> inputs_REG[6];
        sc_uint<CRS_BPS> inputs[6] BIND(inputs_REG);
#endif

#if (CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT)

        {
#if (CRS_PARALLEL_MODE)

            {

#if H_OWNS_DIN
                fat_input1 = H_INPUT->readWithinPacket(false);
                fat_input2 = H_INPUT->readWithinPacket(false);
#else
                fat_input1 = H_INPUT->read();
                fat_input2 = H_INPUT->read();
#endif
                // Until SPR 198060 is fixed, this puts sections of fat_inputs into
                // input[n]
                UPDATE_WIRES(inputs, 2, 0, fat_input1, 0, CRS_BPS);
                UPDATE_WIRES(inputs, 2, 2, fat_input2, 0, CRS_BPS);
                H_OUTPUT->write((inputs[1], inputs[2], inputs[0]));
#if H_OWNS_DOUT
                H_OUTPUT->writeDataAndEop((inputs[3], inputs[2], inputs[0]), eop);
#else
                H_OUTPUT->write((inputs[3], inputs[2], inputs[0]));
#endif
            }

#else // CRS_PARALLEL_MODE
            {
#if H_OWNS_DIN
                inputs[0] = H_INPUT->readWithinPacket(false);
                inputs[1] = H_INPUT->readWithinPacket(false);
                inputs[2] = H_INPUT->readWithinPacket(false);
                inputs[3] = H_INPUT->readWithinPacket(false);
#else
                inputs[0] = H_INPUT->read(); // Cb
                inputs[1] = H_INPUT->read(); // Y
                inputs[2] = H_INPUT->read(); // Cr
                inputs[3] = H_INPUT->read(); // Y
#endif
                H_OUTPUT->write(inputs[0]);
                H_OUTPUT->write(inputs[2]);
                H_OUTPUT->write(inputs[1]);
                H_OUTPUT->write(inputs[0]);
                H_OUTPUT->write(inputs[2]);
#if H_OWNS_DOUT
                H_OUTPUT->writeDataAndEop(inputs[3], eop);
#else
                H_OUTPUT->write(inputs[3]);
#endif
            }
#endif // CRS_PARALLEL_MODE

        }
#else // (CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT)

        {
#if (CRS_PARALLEL_MODE)

            {
#if H_OWNS_DIN
                fat_input1 = H_INPUT->readWithinPacket(false);
                fat_input2 = H_INPUT->readWithinPacket(false);
#else
                fat_input1 = H_INPUT->read();
                fat_input2 = H_INPUT->read();
#endif

                UPDATE_WIRES(inputs, 3, 0, fat_input1, 0, CRS_BPS);
                UPDATE_WIRES(inputs, 3, 3, fat_input2, 0, CRS_BPS);
                H_OUTPUT->write((inputs[2], inputs[0]));
#if H_OWNS_DOUT
                H_OUTPUT->writeDataAndEop((inputs[5], inputs[1]), eop);
#else
                H_OUTPUT->write((inputs[5], inputs[1]));
#endif

            }
#else // CRS_PARALLEL_MODE
            {
#if H_OWNS_DIN
                inputs[0] = H_INPUT->readWithinPacket(false);
                inputs[1] = H_INPUT->readWithinPacket(false);
                inputs[2] = H_INPUT->readWithinPacket(false);
                inputs[3] = H_INPUT->readWithinPacket(false);
                inputs[4] = H_INPUT->readWithinPacket(false);
                inputs[5] = H_INPUT->readWithinPacket(false);
#else
                inputs[0] = H_INPUT->read();
                inputs[1] = H_INPUT->read();
                inputs[2] = H_INPUT->read();
                inputs[3] = H_INPUT->read();
                inputs[4] = H_INPUT->read();
                inputs[5] = H_INPUT->read();
#endif
                H_OUTPUT->write(inputs[0]);
                H_OUTPUT->write(inputs[2]);
                H_OUTPUT->write(inputs[1]);
#if H_OWNS_DOUT
                H_OUTPUT->writeDataAndEop(inputs[5], eop);
#else
                H_OUTPUT->write(inputs[5]);
#endif

            }
#endif // CRS_PARALLEL_MODE

        }
#endif // (CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT)

    }
    bool eop;

    void h_resample_frame()
    {
        unsigned int step_cnt;
        sc_uint<I_BITS> i;
        sc_uint<J_BITS> j;
        bool is_last_row = false;
        for (j = 0; !is_last_row; j++)
        {
            is_last_row = j == sc_uint<J_BITS>(height - sc_uint<J_BITS>(1));
            bool is_last_col = false;
            sc_uint<I_BITS> i_cpy = 0;
            for (i = 0; i < sc_uint<I_BITS>(width >> (STEP_ITER / 2)); i++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MIN_ITERATIONS_PER_ROW);
                ALT_ATTRIB(ALT_MOD_TARGET, MOD_TARGET);

                assert(i == i_cpy);
                is_last_col = i_cpy == sc_uint<I_BITS>(sc_uint<I_BITS>(width >> (STEP_ITER / 2)) - sc_uint<I_BITS>(1));

                for (step_cnt = 0;
                        step_cnt < STEP_ITER;
                        step_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON)
                    ;
                    ALT_ATTRIB(ALT_MIN_ITER, STEP_ITER);
                    ALT_ATTRIB(ALT_MAX_ITER, STEP_ITER);
                    eop = !(STEP_ITER == 2 && IS_ODD(width))
                          && step_cnt == STEP_ITER - 1
                          && is_last_row
                          && is_last_col;
                    h_process_sample();
                }
                i_cpy++;
            }
            if (STEP_ITER == 2 && IS_ODD(width)
               )
            {
                    eop = is_last_row;
                h_process_sample();
            }
        }
#if H_OWNS_DIN
        if (!H_INPUT->getEndPacket())
        {
            HW_DEBUG_MSG("did not get the expected eop, discarding extra data" << std::endl);
        }
        // Discard the data from the final read because it will be left on the input
        H_INPUT->read();
        // Discard any extra data after we had expected EOP
        while (!H_INPUT->getEndPacket())
        {
        	ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        	ALT_ATTRIB(ALT_MOD_TARGET, 1);
        	ALT_ATTRIB(ALT_MIN_ITER, 32);
        	ALT_ATTRIB(ALT_SKIDDING, true);
            H_INPUT->cRead(!H_INPUT->getEndPacket());
        }
#endif
#if H_OWNS_DOUT
        // Finally, switch off endPacket, ready for the next packet out
        H_OUTPUT->setEndPacket(false);
#endif

    }
#elif CRS_ALGORITHM_H_NAME == INTERPOLATION_1D_FULL_FILTERING
    // Full filtering modes share the kernel movement code. Upsampling and downsampling
    // have their own code for actually applying filters and writing out.
#if CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT

    static const int PIX_LEFT_THIS_ROW_BITS = LOG2G_WIDTH + SIGN_BIT;
    static const int N_TAPS = 7;
#else

    static const int PIX_LEFT_THIS_ROW_BITS = LOG2G_WIDTH;
    static const int N_TAPS = 4;
#endif

    static const int TOTAL_CHANNELS = H_IN_CHANNELS_IN_SEQ * H_IN_CHANNELS_IN_PAR;
    static const int KERNEL_CENTRE = (N_TAPS - 1) / 2;
    static const int MIRROR_BUF_SIZE = (N_TAPS - 2 - KERNEL_CENTRE);
    static const int KERNEL_SIZE_DIFF = N_TAPS - MIRROR_BUF_SIZE;

    sc_uint<I_BITS> i;
    sc_uint<J_BITS> j;

    sc_uint<H_INPUT_BITS> just_read;
    DECLARE_WIRES(sc_uint<CRS_BPS>, just_read_wires);

    // Data for the taps
    ALT_AU<CRS_BPS> kernel_AU[N_TAPS*TOTAL_CHANNELS];
    sc_uint<CRS_BPS> kernel[N_TAPS*TOTAL_CHANNELS] BIND(kernel_AU);
    // For handling mirroring on the right edge of a frame
    ALT_AU<CRS_BPS> mirror_kernel_AU[MIRROR_BUF_SIZE*TOTAL_CHANNELS];
    sc_uint<CRS_BPS> mirror_kernel[MIRROR_BUF_SIZE*TOTAL_CHANNELS] BIND(mirror_kernel_AU);

    ALT_AU<PIX_LEFT_THIS_ROW_BITS> pix_left_this_row_AU;
    sc_int<PIX_LEFT_THIS_ROW_BITS> pix_left_this_row BIND(pix_left_this_row_AU);
    bool run_out_of_pixels_this_row;
    DECLARE_VAR_WITH_AU(bool, 1, only_just_run_out_of_pix_this_row);

    // At the start of the row, load up the right-hand side kernel
    void pre_fill_kernel1()
    {
        int tap_cnt, sequence_cnt, parallel_cnt;
        static const int FILL_CNT_BITS = LOG2(N_TAPS - 1 - KERNEL_CENTRE) + 1;
        sc_uint<FILL_CNT_BITS> fill_cnt;
        bool just_read_tautology BIND(ALT_WIRE);

        run_out_of_pixels_this_row = 0;
        only_just_run_out_of_pix_this_row = 0;

        for (fill_cnt = 0; fill_cnt < sc_uint<FILL_CNT_BITS>(N_TAPS - 1 - KERNEL_CENTRE); fill_cnt++)
        {
            for (sequence_cnt = 0; sequence_cnt < H_IN_CHANNELS_IN_SEQ; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_SEQ);
                ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_SEQ);
#if H_OWNS_DIN

                just_read = H_INPUT->readWithinPacket(false);
#else

                just_read = H_INPUT->read();
#endif

                just_read_tautology = ALT_DONT_EVALUATE(just_read.bit(0) || !just_read.bit(0));

                UPDATE_WIRES(just_read_wires, H_IN_CHANNELS_IN_PAR, 0, just_read, 0, CRS_BPS);

                for (parallel_cnt = 0; parallel_cnt < H_IN_CHANNELS_IN_PAR; parallel_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_PAR);
                    ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_PAR);
                    // Written like advance_kernel to avoid muxing on the inputs to kernel[]
                    for (tap_cnt = 0; tap_cnt < N_TAPS - 1; tap_cnt++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, N_TAPS - 1);
                        ALT_ATTRIB(ALT_MAX_ITER, N_TAPS - 1);
                        kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].cLdUI(
                                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt + 1)],
                                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)],
                                    ALT_DONT_EVALUATE(just_read_tautology));
                    }

                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(N_TAPS - 1)] = just_read_wires[parallel_cnt];
                }
            }
        }
    }
    // At the start of the row, mirror up the left-hand side of the kernel. The
    // arguments allow for the luma channel which does not get mirrored because
    // it doesn't get filtered.
    // Due to SPR 240778, this cannot be one function with pre_fill_kernel1
    void pre_fill_kernel2(int unmirrored_channel1, int unmirrored_channel2)
    {
        int tap_cnt, sequence_cnt, parallel_cnt;
        for (tap_cnt = 0; tap_cnt < KERNEL_CENTRE; tap_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, KERNEL_CENTRE);
            ALT_ATTRIB(ALT_MAX_ITER, KERNEL_CENTRE);

            for (sequence_cnt = 0; sequence_cnt < H_IN_CHANNELS_IN_SEQ; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_SEQ);
                ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_SEQ);
                for (parallel_cnt = 0; parallel_cnt < H_IN_CHANNELS_IN_PAR; parallel_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_PAR);
                    ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_PAR);

                    if (SEQ_PAR_TO_CHANNEL != unmirrored_channel1 && SEQ_PAR_TO_CHANNEL != unmirrored_channel2)
                    {
                        kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt + 1)] = kernel[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE + (KERNEL_CENTRE - tap_cnt))];
                    }
                }
            }
        }
    }
    // During a row, advance the kernel. When called near the end of a row,
    // feeds the contents of mirror_kernel back in to perform mirror edge handling
    // The arguments allow for the luma channel which does not get mirrored because
    // it doesn't get filtered.
    void advance_kernel(int unmirrored_channel1, int unmirrored_channel2)
    {
        int sequence_cnt, tap_cnt, parallel_cnt;
        sc_uint<CRS_BPS> mirror_kernel_srcs[N_TAPS*TOTAL_CHANNELS] BIND(ALT_WIRE);
        bool run_out_of_pixels_this_row_0_latency BIND(ALT_WIRE);
        bool run_out_of_pixels_this_row_switch BIND(ALT_WIRE);
        bool only_just_run_out_of_pix_this_row_switch BIND(ALT_WIRE);
        bool just_read_tautology BIND(ALT_WIRE);

        run_out_of_pixels_this_row_0_latency = !(pix_left_this_row >= sc_int<PIX_LEFT_THIS_ROW_BITS>(0));
        only_just_run_out_of_pix_this_row = run_out_of_pixels_this_row_0_latency && !run_out_of_pixels_this_row;
        run_out_of_pixels_this_row = run_out_of_pixels_this_row_0_latency;
        pix_left_this_row--;

        for (sequence_cnt = 0; sequence_cnt < H_IN_CHANNELS_IN_SEQ; sequence_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_SEQ);
            ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_SEQ);

            // The very first read can be scheduled early by using the value straight from the comparator,
            // later ones read from the register
            if (sequence_cnt == 0 && !(CRS_PARALLEL_MODE && CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT))
            {
                if (!run_out_of_pixels_this_row_0_latency)
                {
#if H_OWNS_DIN
                    just_read = H_INPUT->readWithinPacket(false);
#else

                    just_read = H_INPUT->read();
#endif

                }
            }
            else
            {
                if (!run_out_of_pixels_this_row)
                {
#if H_OWNS_DIN
                    just_read = H_INPUT->readWithinPacket(false);
#else

                    just_read = H_INPUT->read();
#endif

                }
            }

#if H_IN_CHANNELS_IN_PAR == 1
            UPDATE_WIRES(just_read_wires, 1, 0, just_read, 0, CRS_BPS);
#else

            UPDATE_WIRES(just_read_wires, 2, 0, just_read, 0, CRS_BPS);
#endif
#if H_IN_CHANNELS_IN_PAR == 3

            UPDATE_WIRES(just_read_wires, 1, 2, just_read, CRS_BPS*2, CRS_BPS);
#endif

            for (parallel_cnt = 0; parallel_cnt < H_IN_CHANNELS_IN_PAR; parallel_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_PAR);
                ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_PAR);

                if (CRS_PARALLEL_MODE)
                {
                    if (CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT || sequence_cnt > 0)
                    {
                        run_out_of_pixels_this_row_switch = ALT_STAGE(run_out_of_pixels_this_row, 2);
                        only_just_run_out_of_pix_this_row_switch = ALT_STAGE(only_just_run_out_of_pix_this_row, 2);
                    }
                    else
                    {
                        run_out_of_pixels_this_row_switch = ALT_STAGE(run_out_of_pixels_this_row, 1);
                        only_just_run_out_of_pix_this_row_switch = ALT_STAGE(only_just_run_out_of_pix_this_row, 1);
                    }
                }
                else
                {
                    // The final kernel movements cannot read from run_out_of_pixels_this_row, because
                    // the next kernel advance needs to write to it
                    if (sequence_cnt >= 1)
                    {
                        run_out_of_pixels_this_row_switch = ALT_STAGE(run_out_of_pixels_this_row, 2);
                        only_just_run_out_of_pix_this_row_switch = ALT_STAGE(only_just_run_out_of_pix_this_row, 2);
                    }
                    else
                    {
                        run_out_of_pixels_this_row_switch = run_out_of_pixels_this_row;
                        only_just_run_out_of_pix_this_row_switch = only_just_run_out_of_pix_this_row;
                    }
                }

                just_read_tautology = ALT_DONT_EVALUATE(just_read_wires[parallel_cnt].bit(0) || !just_read_wires[parallel_cnt].bit(0));

                // Copy the old kernel values to wires so that they can be mirrored
                for (tap_cnt = 1; tap_cnt < N_TAPS; tap_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, N_TAPS - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, N_TAPS - 1);
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    mirror_kernel_srcs[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt - 1)];
                }

                // Most of the kernel advances by 1. Use just_read_tautology
                // to make it happen at the same time as the leading edge
                for (tap_cnt = 0; tap_cnt < N_TAPS - 1; tap_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, N_TAPS - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, N_TAPS - 1);
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].cLdUI(
                                kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt + 1)],
                                kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)],
                                ALT_DONT_EVALUATE(just_read_tautology));
                }

                // If this channel is not mirrored, it comes from din, until
                // the end of the row, when it becomes irrelevant (it will never
                // reach the centre)
                // If the channel is mirrored, the leading edge of the kernel
                // comes from either:
                // - din during a row
                // - its old value on the end of a row
                // - the mirror_kernel as is passes further off the end
                if (SEQ_PAR_TO_CHANNEL != unmirrored_channel1 && SEQ_PAR_TO_CHANNEL != unmirrored_channel2)
                {
                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(N_TAPS - 1)] = kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(N_TAPS - 1)].mCLdUI(
                                just_read_wires[parallel_cnt],
                                mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR( MIRROR_BUF_SIZE - 1)],
                                kernel[FLAT_CHANNELS_IN_SEQ_PAR(N_TAPS - 1)],
                                !run_out_of_pixels_this_row_switch && !only_just_run_out_of_pix_this_row_switch,
                                run_out_of_pixels_this_row_switch && !only_just_run_out_of_pix_this_row_switch);
                }
                else
                {
                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(N_TAPS - 1)] = just_read_wires[parallel_cnt];
                }

                // Until we have run out of pixels, the mirror kernel shifts does the same thing as the main kernel.
                // After that, it runs backwards.
                for (tap_cnt = MIRROR_BUF_SIZE - 1; tap_cnt >= 0; tap_cnt--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MIRROR_BUF_SIZE);
                    ALT_ATTRIB(ALT_MAX_ITER, MIRROR_BUF_SIZE);
                    if (tap_cnt > 0)
                    {
                        mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = mirror_kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].muxLdUI(
                                    mirror_kernel_srcs[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_SIZE_DIFF + tap_cnt)],
                                    mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt - 1)],
                                    run_out_of_pixels_this_row_switch && ALT_DONT_EVALUATE(just_read_tautology) && !only_just_run_out_of_pix_this_row_switch);
                    }
                    else
                    {
                        mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = mirror_kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].cLdUI(
                                    mirror_kernel_srcs[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_SIZE_DIFF + tap_cnt)],
                                    mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)],
                                    ALT_DONT_EVALUATE(just_read_tautology));
                    }
                }
            }
        }
    }
    void pointless_initialisation()
    {
        int tap_cnt, sequence_cnt, parallel_cnt;
        for (sequence_cnt = 0; sequence_cnt < H_IN_CHANNELS_IN_SEQ; sequence_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_SEQ);
            ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_SEQ);
            for (parallel_cnt = 0; parallel_cnt < H_IN_CHANNELS_IN_PAR; parallel_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, H_IN_CHANNELS_IN_PAR);
                ALT_ATTRIB(ALT_MAX_ITER, H_IN_CHANNELS_IN_PAR);
                for (tap_cnt = MIRROR_BUF_SIZE - 1; tap_cnt >= 0; tap_cnt--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MIRROR_BUF_SIZE);
                    ALT_ATTRIB(ALT_MAX_ITER, MIRROR_BUF_SIZE);
                    mirror_kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = mirror_kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].sClrUI();
                }
                for (tap_cnt = 0; tap_cnt < N_TAPS; tap_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, N_TAPS);
                    ALT_ATTRIB(ALT_MAX_ITER, N_TAPS);
                    kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)] = kernel_AU[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)].sClrUI();
                }
            }
        }

    }
#ifndef __CUSP_SYNTHESIS__
    // Apply the filter C-style for debugging purposes
    int filter_kernel_debug(int sequence_cnt, int parallel_cnt, int phase = 0)
    {
#if CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT
        static const int coeffs[1][N_TAPS] =
            {
                {
                    -1, 0, 9, 16, 9, 0, -1
                }
            };
#else

        static const int coeffs[5][N_TAPS] =
            {
                {
                    8, 28, -4, 0
                }
                , { 0, 32, 0, 0 } , { -3, 28, 8, -1}, { -2, 18, 18, -2}, { -1, 8, 28, -3}
            };
#endif

        long long result = 0;
        for (int tap_cnt = 0; tap_cnt < N_TAPS; tap_cnt++)
        {
            result += coeffs[phase][tap_cnt] * (long long)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(tap_cnt)]);
        }
        return result;

    }
#endif //n__CUSP_SYNTHESIS__

#if CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT

    DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, filter_result);

    // Multiply the kernel by {-1, 0, 9, 16, 9, 0, -1}, explicitly balancing
    // the arithmetic tree and reducing strength of operations.
    void filter_kernel(int sequence_cnt, int parallel_cnt)
    {
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, add_negated); // Add up the *-1s
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, add_multipled_16); // Add 16 for rounding, multiply by 16
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, add_upper); // Add the two above
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, mult_by_9_vals); // Add up the *9s
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, add_multipled_9s); // For actually multiplying by 9
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, final_add);
        sc_int<LOTS_OF_BITS> divided BIND(ALT_WIRE);

        long long debug_result = 0;
#ifndef __CUSP_SYNTHESIS__

        debug_result = filter_kernel_debug(sequence_cnt, parallel_cnt);
#endif

        // In parallel mode, this needs to be fully pipelined, so stage the inputs.
        if (CRS_PARALLEL_MODE)
        {
            add_negated = ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1) + ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(6)], 1);
            add_multipled_9s = ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1) + ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(4)], 1);
            add_multipled_16 = sc_uint<LOTS_OF_BITS>(16) + sc_uint<LOTS_OF_BITS>(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)], 1) << 4);
        }
        else
        {
            add_negated = kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)] + kernel[FLAT_CHANNELS_IN_SEQ_PAR(6)];
            add_multipled_9s = kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)] + kernel[FLAT_CHANNELS_IN_SEQ_PAR(4)];
            add_multipled_16 = sc_uint<LOTS_OF_BITS>(16) + sc_uint<LOTS_OF_BITS>(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)] << 4);
        }

        add_upper = add_multipled_16 - add_negated;

        mult_by_9_vals = sc_int<LOTS_OF_BITS>(add_multipled_9s << 3) + add_multipled_9s;

        final_add = add_upper + mult_by_9_vals;

        divided = final_add >> 5;

        debug_result = (debug_result + 16) >> 5;

#ifndef __CUSP_SYNTHESIS__

        assert((long long)divided == debug_result);
#endif
        // Saturate underflow and overflow
        filter_result = filter_result_AU.addSubSLdSClrSI(
                            divided,
                            0,
                            (1 << CRS_BPS) - 1,
                            (divided >> CRS_BPS) > 0,
                            divided < sc_int<LOTS_OF_BITS>(0),
                            0);

        debug_result = debug_result > 0 ? debug_result : 0;
        debug_result = debug_result < (1 << CRS_BPS) - 1 ? debug_result : (1 << CRS_BPS) - 1;
#ifndef __CUSP_SYNTHESIS__

        assert((long long)filter_result == debug_result);
#endif

    }
    void h_process_sample()
    {
        // Advance, but don't mirror channel 2 (luma)
        advance_kernel(2, -1);

        if (!CRS_PARALLEL_MODE)
        {
            // Filter, then write a Cb
            filter_kernel(0, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result));
            //Write a Y
            H_OUTPUT->write(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 2, 0)]);
            // Filter, then write a Cr
            filter_kernel(1, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result));
            // Read in the next Y and write it out
            advance_kernel(2, -1);
#if H_OWNS_DOUT
            H_OUTPUT->writeDataAndEop(ALT_STAGE(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 2, 0)], 2), eop);
#else
            H_OUTPUT->write(ALT_STAGE(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 2, 0)], 2));
#endif
        }
        else
        {
            // Filter a Cb
            filter_kernel(0, 0);
            // Write a Cb:Y
            H_OUTPUT->write((ALT_STAGE(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 0, 2)], 3), sc_uint<CRS_BPS>(filter_result)));
            // Filter a Cr
            filter_kernel(0, 1);
            // Write a Cr:Y
            advance_kernel(2, -1);
#if H_OWNS_DOUT
            H_OUTPUT->writeDataAndEop((ALT_STAGE(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 0, 2)], 3), sc_uint<CRS_BPS>(filter_result)), eop);
#else
            H_OUTPUT->write((ALT_STAGE(kernel[EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE, 0, 2)], 3), sc_uint<CRS_BPS>(filter_result)));
#endif
        }
    }
    bool eop;
    void h_resample_frame()
    {
        unsigned int step_cnt;
        bool is_last_row = false;

        pointless_initialisation();

        for (j = 1; !is_last_row; j++)
        {
            bool is_last_col = false;
            is_last_row = j == sc_uint<J_BITS>(height);

            pix_left_this_row = pix_left_this_row_AU.subSI(sc_int<PIX_LEFT_THIS_ROW_BITS>(width << 1), 1 + (N_TAPS - 1 - KERNEL_CENTRE));
            pre_fill_kernel1();
            pre_fill_kernel2(2, -1);
            sc_uint<I_BITS> i_cpy = 1;
            for (i = 0; i < sc_uint<I_BITS>(width >> (STEP_ITER / 2)); i++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MIN_ITERATIONS_PER_ROW);
                ALT_ATTRIB(ALT_MOD_TARGET, MOD_TARGET);

                is_last_col = i_cpy == sc_uint<I_BITS>(sc_uint<I_BITS>(width >> (STEP_ITER / 2)));

                for (step_cnt = 0;
                        step_cnt < STEP_ITER;
                        step_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON)
                    ;
                    ALT_ATTRIB(ALT_MIN_ITER, STEP_ITER);
                    ALT_ATTRIB(ALT_MAX_ITER, STEP_ITER);

                    eop = !(STEP_ITER == 2 && IS_ODD(width))
                          && step_cnt == STEP_ITER - 1
                          && is_last_row
                          && is_last_col;

                    h_process_sample();
                }
                i_cpy++;

            }
            if (STEP_ITER == 2 && IS_ODD(width))
            {
                eop = is_last_row;
                h_process_sample()
                ;
            }
        }
#if H_OWNS_DIN
        if (!H_INPUT->getEndPacket())
        {
            HW_DEBUG_MSG("did not get the expected eop, discarding extra data" << std::endl);
        }
        // Discard the data from the final read because it will be left on the input
        H_INPUT->read();
        // Discard any extra data after we had expected EOP
        while (!H_INPUT->getEndPacket())
        {
        	ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        	ALT_ATTRIB(ALT_MOD_TARGET, 1);
        	ALT_ATTRIB(ALT_MIN_ITER, 32);
        	ALT_ATTRIB(ALT_SKIDDING, true);
            H_INPUT->cRead(!H_INPUT->getEndPacket());
        }
#endif
#if H_OWNS_DOUT
        // Finally, switch off endPacket, ready for the next packet out
        H_OUTPUT->setEndPacket(false);
#endif
    }
#else // CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT
    // Phase "1" is actually a Lanczos-2 with no phase-offset; phase 0 is shifted
    // back by 1/4, phase 2, 3, 4 are shifted forward by 1/4, 2/4, 3/4

    // In non-luma adaptive mode, calculate phase 1 and phase 3, then output them to
    // make 2 pixels from 1.

    // In luma adaptive, calculate all phases and use the luma to decide whether
    // to shift up/down from 1, 3. The output is then muxed from 0 to 2 and 2 to 4.

    long long phase_0_result BIND(ALT_WIRE);
    // Phase 1 is pass-through
    long long phase_2_result BIND(ALT_WIRE);
    long long phase_3_result BIND(ALT_WIRE);
    long long phase_4_result BIND(ALT_WIRE);

    // Phase 2 is used for both the first and second output pixel, so it needs to be
    // stored
#if CRS_PARALLEL_MODE

    sc_int<LOTS_OF_BITS> phase_2_for_later[TOTAL_CHANNELS] BIND(ALT_WIRE);
#else

    ALT_REG<LOTS_OF_BITS> phase_2_for_later_REG[TOTAL_CHANNELS];
    sc_int<LOTS_OF_BITS> phase_2_for_later[TOTAL_CHANNELS] BIND(phase_2_for_later_REG);
#endif

    // The results from filtering for the first and second output pixel
    DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, filter_result);
    DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, filter_result_2);

    // Apply {8, 28, -4, 0}, and divide by 32. Do this by reducing it to
    // {2, 7, -1, 0}, and dividing by 8
    void calculate_phase_0(int sequence_cnt, int parallel_cnt)
    {
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, times_7);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_2);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_2_rounded);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, phase_0_final_sum);

        if (CRS_PARALLEL_MODE)
        {
            if (parallel_cnt == 1)
            {
                negate_and_2 = (sc_int<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1) << 1) - ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1);
                times_7 = times_7_AU.subUI(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 2) << 3,
                                           ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 2));
            }
            else
            {
                negate_and_2 = (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)] << 1) - kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)];
                times_7 = times_7_AU.subUI(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 1) << 3,
                                           ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 1));
            }
        }
        else
        {
            negate_and_2 = (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)] << 1) - kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)];
            times_7 = times_7_AU.subUI(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)] << 3, kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)]);
        }

        negate_and_2_rounded = negate_and_2 + sc_int<LOTS_OF_BITS>(4);
        phase_0_final_sum = negate_and_2_rounded + times_7;

        phase_0_result = phase_0_final_sum >> 3;
    }

    // Apply { -3, 28, 8, -1}, and divide by 32.
    void calculate_phase_2(int sequence_cnt, int parallel_cnt)
    {
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, times_28);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, times_3);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_8);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_8_rounded);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, lower_sum);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, phase_2_final_sum);

        if (CRS_PARALLEL_MODE && parallel_cnt == 1)
        {
            negate_and_8 = (sc_int<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1) << 3) - (sc_int<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)], 1));
            times_28 = (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 1) << 3) - (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 1));
            times_3 = (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1) << 1) + (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1));
        }
        else
        {
            negate_and_8 = (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)] << 3) - (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)]);
            times_28 = (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)] << 3) - (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)]);
            times_3 = (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)] << 1) + (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)]);
        }
        negate_and_8_rounded = negate_and_8 + sc_int<LOTS_OF_BITS>(16);
        lower_sum = (sc_int<LOTS_OF_BITS>)(times_28 << 2) - times_3;
        phase_2_final_sum = negate_and_8_rounded + lower_sum;

        phase_2_result = phase_2_final_sum >> 5;
    }

    // Apply { -2, 18, 18, -2}, and divide by 32. Do this by reducing it to
    // {-1, 9, 9, -1}, and dividing by 16
    void calculate_phase_3(int sequence_cnt, int parallel_cnt)
    {
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, sum_outer);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, sum_mult9s);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, mult9);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, sum_out_w_rounding);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, phase_3_final_sum);

        if (CRS_PARALLEL_MODE && parallel_cnt == 1)
        {
            sum_outer = ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1) + ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)], 1);
            sum_mult9s = ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)] , 1) + ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1);
        }
        else
        {
            sum_outer = kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)] + kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)];
            sum_mult9s = kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)] + kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)];
        }
        sum_out_w_rounding = sum_outer - sc_int<LOTS_OF_BITS>(8);
        mult9 = (sc_int<LOTS_OF_BITS>)(sum_mult9s << 3) + sum_mult9s;
        phase_3_final_sum = mult9 - sum_out_w_rounding;

        phase_3_result = phase_3_final_sum >> 4;

    }

    // Apply { -1, 8, 28, -3}, and divide by 32. Do this by reducing it to
    void calculate_phase_4(int sequence_cnt, int parallel_cnt)
    {
    	DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, times_28);
    	DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, times_3);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_8);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, negate_and_8_rounded);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, lower_sum);
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, phase_4_final_sum);

        if (CRS_PARALLEL_MODE && parallel_cnt == 1)
        {
            negate_and_8 = (sc_int<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)], 1) << 3) - (sc_int<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)], 1));
            times_28 = (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1) << 3) - (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)], 1));
            times_3 = (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)], 1) << 1) + (sc_uint<LOTS_OF_BITS>)(ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)], 1));
        }
        else
        {
            negate_and_8 = (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(1)] << 3) - (sc_int<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(0)]);
            times_28 = (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)] << 3) - (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(2)]);
            times_3 = (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)] << 1) + (sc_uint<LOTS_OF_BITS>)(kernel[FLAT_CHANNELS_IN_SEQ_PAR(3)]);
        }
        negate_and_8_rounded = negate_and_8 + sc_int<LOTS_OF_BITS>(16);
        lower_sum = (sc_int<LOTS_OF_BITS>)(times_28 << 2) - (sc_int<LOTS_OF_BITS>)(times_3);
        phase_4_final_sum = negate_and_8_rounded + lower_sum;

        phase_4_result = phase_4_final_sum >> 5;
    }

    // Filtering for the first output pixel.
    void filter_kernel_1(int sequence_cnt, int parallel_cnt)
    {
        long long debug_result = 0;
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, pre_filter_result);
        ALT_AU<LOTS_OF_BITS, 0> inner_mux;

#ifndef __CUSP_SYNTHESIS__

        int phase = 1;
        if (phase_shift_down_from_1)
        {
            phase--;
        }
        if (phase_shift_up_from_1)
        {
            phase++;
        }
        debug_result = filter_kernel_debug(sequence_cnt, parallel_cnt, phase);
#endif

        debug_result = (debug_result + 16) >> 5;
        debug_result = debug_result > 0 ? debug_result : 0;
        debug_result = debug_result < (1 << CRS_BPS) - 1 ? debug_result : (1 << CRS_BPS) - 1;

        calculate_phase_0(sequence_cnt, parallel_cnt);
        calculate_phase_2(sequence_cnt, parallel_cnt);

        // Store phase 2 in case the second pixel needs it
        phase_2_for_later[sequence_cnt] = phase_2_result;

        // Pick the appropriate result depending on phase_shift_up_from_1 and
        // phase_shift_down_from_1 (from luma values)
        if (CRS_PARALLEL_MODE)
        {
            if (sequence_cnt == 1)
            {
                pre_filter_result = pre_filter_result_AU.muxLdSI(inner_mux.muxLdSI(phase_2_result, (long long)ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE)], 4), !ALT_STAGE(phase_shift_up_from_1, 1) || ALT_STAGE(phase_shift_down_from_1, 1)),
                                    phase_0_result,
                                    ALT_STAGE(phase_shift_down_from_1, 1) && !ALT_STAGE(phase_shift_up_from_1, 1));
            }
            else
            {
                pre_filter_result = pre_filter_result_AU.muxLdSI(inner_mux.muxLdSI(phase_2_result, (long long)ALT_STAGE(kernel[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE)], 4), !phase_shift_up_from_1 || phase_shift_down_from_1),
                                    phase_0_result,
                                    phase_shift_down_from_1 && !phase_shift_up_from_1);
            }
        }
        else
        {
            pre_filter_result = pre_filter_result_AU.muxLdSI(inner_mux.muxLdSI(phase_2_result, (long long)kernel[FLAT_CHANNELS_IN_SEQ_PAR(KERNEL_CENTRE)], !phase_shift_up_from_1 || phase_shift_down_from_1),
                                phase_0_result,
                                phase_shift_down_from_1 && !phase_shift_up_from_1);
        }
#if CRS_ALGORITHM_H_LUMA_ADAPTIVE

        // Saturate overflow and underflow
        filter_result = filter_result_AU.addSubSLdSClrSI(
                            pre_filter_result,
                            0,
                            (1 << CRS_BPS) - 1,
                            sc_int<LOTS_OF_BITS>(pre_filter_result >> CRS_BPS) > sc_int<LOTS_OF_BITS>(0),
                            pre_filter_result < sc_int<LOTS_OF_BITS>(0),
                            0);
#ifndef __CUSP_SYNTHESIS__
        assert((long long)filter_result == debug_result);
#endif
#endif

    }

    // Filtering for the second output pixel.
    void filter_kernel_2(int sequence_cnt, int parallel_cnt)
    {
        DECLARE_VAR_WITH_AU(sc_int<LOTS_OF_BITS>, LOTS_OF_BITS, pre_filter_result);
        ALT_AU<LOTS_OF_BITS, 0> inner_mux;

        long long debug_result = 0;
#ifndef __CUSP_SYNTHESIS__

        int phase = 3;
        if (phase_shift_down_from_3)
        {
            phase--;
        }
        if (phase_shift_up_from_3)
        {
            phase++;
        }

        debug_result = filter_kernel_debug(sequence_cnt, parallel_cnt, phase);
#endif

        debug_result = (debug_result + 16) >> 5;
        debug_result = debug_result > 0 ? debug_result : 0;
        debug_result = debug_result < (1 << CRS_BPS) - 1 ? debug_result : (1 << CRS_BPS) - 1;

        calculate_phase_3(sequence_cnt, parallel_cnt);
        calculate_phase_4(sequence_cnt, parallel_cnt);

#if CRS_ALGORITHM_H_LUMA_ADAPTIVE

        // Pick the appropriate result depending on phase_shift_up_from_3 and
        // phase_shift_down_from_3 (from luma values)
        if (CRS_PARALLEL_MODE && sequence_cnt == 1)
        {
            pre_filter_result = pre_filter_result_AU.muxLdSI(inner_mux.muxLdSI(phase_3_result, phase_2_for_later[sequence_cnt], !ALT_STAGE(phase_shift_up_from_3, 1) && ALT_STAGE(phase_shift_down_from_3, 1)),
                                phase_4_result,
                                ALT_STAGE(phase_shift_up_from_3, 1) && !ALT_STAGE(phase_shift_down_from_3, 1));
        }
        else
        {
            pre_filter_result = pre_filter_result_AU.muxLdSI(inner_mux.muxLdSI(phase_3_result, phase_2_for_later[sequence_cnt], phase_shift_down_from_3 && !phase_shift_up_from_3),
                                phase_4_result,
                                phase_shift_up_from_3 && !phase_shift_down_from_3);
        }

        // Saturate overflow and underflow
        filter_result_2 = filter_result_2_AU.addSubSLdSClrSI(
                              pre_filter_result,
                              0,
                              (1 << CRS_BPS) - 1,
                              sc_int<LOTS_OF_BITS>(pre_filter_result >> CRS_BPS) > sc_int<LOTS_OF_BITS>(0),
                              pre_filter_result < sc_int<LOTS_OF_BITS>(0),
                              0);
#ifndef __CUSP_SYNTHESIS__
        assert((long long)filter_result_2 == debug_result);
#endif
#else
        // Saturate overflow and underflow
        filter_result_2 = filter_result_2_AU.addSubSLdSClrSI(
                              phase_3_result,
                              0,
                              (1 << CRS_BPS) - 1,
                              (phase_3_result >> CRS_BPS) > 0,
                              phase_3_result < 0,
                              0);
#endif

    }
#if CRS_PARALLEL_MODE
#define Y1_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 0, 1)
#define Y2_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 1, 1)
#define CB_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 0, 0)
#define CR_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 1, 0)
#else
#define Y1_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 1, 0)
#define Y2_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 3, 0)
#define CB_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 0, 0)
#define CR_LOCATION(X) EXPLICIT_FLAT_CHANNELS_IN_SEQ_PAR((X), 2, 0)
#endif
    bool phase_shift_down_from_1, phase_shift_up_from_1, phase_shift_down_from_3;
    bool phase_shift_up_from_3 BIND(ALT_WIRE);
    sc_uint<CRS_BPS*3> out_word1 BIND(ALT_WIRE);
    sc_uint<CRS_BPS*3> out_word2 BIND(ALT_WIRE);
    void h_process_sample()
    {
        static const int LUMA_DIFF_BITS = CRS_BPS + SIGN_BIT;
        static const int LUMA_DIFF_COARSENESS = CRS_BPS - 2;

        DECLARE_VAR_WITH_AU(sc_int < LUMA_DIFF_BITS > , LUMA_DIFF_BITS, luma_diff_1);
        DECLARE_VAR_WITH_AU(sc_int < LUMA_DIFF_BITS > , LUMA_DIFF_BITS, luma_diff_2);
        sc_uint<CRS_BPS> to_out1, to_out2;

        //////////////////////////

        // No mirroring for channels 1, 3 i.e. the Ys in CbYCrY
        advance_kernel(1, 3);

        //////////////////////////

        // Check the Y values (one forward, one backward) to see if we should do a phase-shift
        // Using subSI instead of - due to SPR 243285
        if (CRS_PARALLEL_MODE)
        {
            luma_diff_1 = luma_diff_1_AU.subSI(sc_int < LUMA_DIFF_BITS > (kernel[Y1_LOCATION(KERNEL_CENTRE)]), sc_int < LUMA_DIFF_BITS > (kernel[Y2_LOCATION(KERNEL_CENTRE - 1)]));
            phase_shift_up_from_1 = luma_diff_1 >> (LUMA_DIFF_COARSENESS) > 0 || luma_diff_1 >> (LUMA_DIFF_COARSENESS) < -1;

            luma_diff_1 = luma_diff_1_AU.subSI(sc_int < LUMA_DIFF_BITS > (ALT_STAGE(kernel[Y1_LOCATION(KERNEL_CENTRE)], 1)), sc_int < LUMA_DIFF_BITS > (kernel[Y2_LOCATION(KERNEL_CENTRE)]));
        }
        else
        {
            luma_diff_2 = luma_diff_2_AU.subSI(sc_int < LUMA_DIFF_BITS > (kernel[Y1_LOCATION(KERNEL_CENTRE)]), sc_int < LUMA_DIFF_BITS > (kernel[Y2_LOCATION(KERNEL_CENTRE - 1)]));
            phase_shift_up_from_1 = luma_diff_2 >> (LUMA_DIFF_COARSENESS) > 0 || luma_diff_2 >> (LUMA_DIFF_COARSENESS) < -1;

            luma_diff_1 = luma_diff_1_AU.subSI(sc_int < LUMA_DIFF_BITS > (kernel[Y1_LOCATION(KERNEL_CENTRE)]), sc_int < LUMA_DIFF_BITS > (kernel[Y2_LOCATION(KERNEL_CENTRE)]));
        }

        phase_shift_down_from_1 = luma_diff_1 >> (LUMA_DIFF_COARSENESS) > 0 || luma_diff_1 >> (LUMA_DIFF_COARSENESS) < -1;

        //////////////////////////
        // Filter and output

#if CRS_ALGORITHM_H_LUMA_ADAPTIVE

        if (CRS_PARALLEL_MODE)
        {
            filter_kernel_1(0,0);
            to_out1 = filter_result;
            filter_kernel_1(1, 0);
            out_word1 = (ALT_STAGE(kernel[Y1_LOCATION(KERNEL_CENTRE)], 7), sc_uint<CRS_BPS>(filter_result), sc_uint<CRS_BPS>(to_out1));
            H_OUTPUT->write(out_word1);
        }
        else
        {
            filter_kernel_1(0, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result));
            filter_kernel_1(2, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result));
            H_OUTPUT->write(ALT_STAGE(kernel[Y1_LOCATION(KERNEL_CENTRE)], 4));
        }

#else
        if (CRS_PARALLEL_MODE)
        {
            H_OUTPUT->write((ALT_STAGE(kernel[Y1_LOCATION(KERNEL_CENTRE)], 3), ALT_STAGE(kernel[CR_LOCATION(KERNEL_CENTRE)], 3), ALT_STAGE(kernel[CB_LOCATION(KERNEL_CENTRE)],3)));
        }
        else
        {
            H_OUTPUT->write(kernel[CB_LOCATION(KERNEL_CENTRE)]);
            H_OUTPUT->write(kernel[CR_LOCATION(KERNEL_CENTRE)]);
            H_OUTPUT->write(kernel[Y1_LOCATION(KERNEL_CENTRE)]);
        }
#endif


        //////////////////////////
        // Check the Y values (one pixel later, now) to see if we should do a phase-shift

        phase_shift_up_from_3 = phase_shift_down_from_1;

        luma_diff_2 = luma_diff_2_AU.subSI(sc_int < LUMA_DIFF_BITS > (kernel[Y2_LOCATION(KERNEL_CENTRE)]), sc_int < LUMA_DIFF_BITS > (kernel[Y1_LOCATION(KERNEL_CENTRE + 1)]));

        phase_shift_down_from_3 = luma_diff_2 >> (LUMA_DIFF_COARSENESS) > 0 || luma_diff_2 >> (LUMA_DIFF_COARSENESS) < -1;

        //////////////////////////
        // Filter and output

        if (CRS_PARALLEL_MODE)
        {
            filter_kernel_2(0, 0);
            to_out2 = filter_result_2;
            filter_kernel_2(1, 0);
#if CRS_ALGORITHM_H_LUMA_ADAPTIVE
            out_word2 = (ALT_STAGE(kernel[Y2_LOCATION(KERNEL_CENTRE)], 7), sc_uint<CRS_BPS>(ALT_STAGE(filter_result_2, 1)), sc_uint<CRS_BPS>(ALT_STAGE(to_out2, 1)));
#else
            out_word2 = (ALT_STAGE(kernel[Y2_LOCATION(KERNEL_CENTRE)], 4), sc_uint<CRS_BPS>(filter_result_2), sc_uint<CRS_BPS>(to_out2));
#endif
#if H_OWNS_DOUT
            H_OUTPUT->writeDataAndEop(out_word2, eop);
#else
            H_OUTPUT->write(out_word2);
#endif
        }
        else
        {
            filter_kernel_2(0, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result_2));
            filter_kernel_2(2, 0);
            H_OUTPUT->write(sc_uint<CRS_BPS>(filter_result_2));
#if H_OWNS_DOUT
            H_OUTPUT->writeDataAndEop(kernel[Y2_LOCATION(KERNEL_CENTRE)], eop);
#else
            H_OUTPUT->write(kernel[Y2_LOCATION(KERNEL_CENTRE)]);
#endif
        }

    }
    bool eop;
    void h_resample_frame()
    {
        int step_cnt;
        bool is_last_row = false;
        pointless_initialisation();

        for (j = 1; !is_last_row; j++)
        {
            bool is_last_col = false;
            is_last_row = j == sc_uint<J_BITS>(height);
            pix_left_this_row = pix_left_this_row_AU.subSI(sc_int<PIX_LEFT_THIS_ROW_BITS>(width), sc_int<I_BITS>(1 + (N_TAPS - 1 - KERNEL_CENTRE)));
            pre_fill_kernel1();
            // No mirroring for channels 1, 3 i.e. the Ys in CbYCrY
            pre_fill_kernel2(1, 3);

            // To do luma-adaption, we need to look backwards on the Y channel. This is spread into
            // channels 1 and 3, so the mirroring has to be done as a special case.

            kernel[Y2_LOCATION(KERNEL_CENTRE)] = kernel[Y1_LOCATION(KERNEL_CENTRE + 1)];
            
            sc_uint<I_BITS> i_cpy = 1;

            for (i = 0; i < sc_uint<I_BITS>(width >> (STEP_ITER / 2)); i++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MIN_ITERATIONS_PER_ROW);
                ALT_ATTRIB(ALT_MOD_TARGET, MOD_TARGET);

                is_last_col = i_cpy == sc_uint<I_BITS>(sc_uint<I_BITS>(width >> (STEP_ITER / 2)));

                for (step_cnt = 0; step_cnt < STEP_ITER; step_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, STEP_ITER);
                    ALT_ATTRIB(ALT_MAX_ITER, STEP_ITER);

                    eop = !(STEP_ITER == 2 && IS_ODD(width))
                          && step_cnt == STEP_ITER - 1
                          && is_last_row
                          && is_last_col;

                    h_process_sample();
                }
                i_cpy++;
            }
            if (STEP_ITER == 2 && IS_ODD(width)
               )
            {
            	  eop = is_last_row;
                h_process_sample();
            }
        }
#if H_OWNS_DIN
        if (!H_INPUT->getEndPacket())
        {
            HW_DEBUG_MSG("did not get the expected eop, discarding extra data" << std::endl);
        }
        // Discard the data from the final read because it will be left on the input
        H_INPUT->read();
        // Discard any extra data after we had expected EOP
        while (!H_INPUT->getEndPacket())
        {
        	ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        	ALT_ATTRIB(ALT_MOD_TARGET, 1);
        	ALT_ATTRIB(ALT_MIN_ITER, 32);
        	ALT_ATTRIB(ALT_SKIDDING, true);
            H_INPUT->cRead(!H_INPUT->getEndPacket());
        }
#endif
#if H_OWNS_DOUT
        // Finally, switch off endPacket, ready for the next packet out
        H_OUTPUT->setEndPacket(false);
#endif        
    }
#endif // CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT
#endif // CRS_ALGORITHM_H_NAME == INTERPOLATION_1D_NEAREST_NEIGHBOUR
#endif // H_RESAMPLING
    // Until Cusp SPR 241860 is fixed, we need to hide the v_resampling thread if it is unused
#if CRS_RESAMPLING_FORMAT_IN != 420 && CRS_RESAMPLING_FORMAT_OUT != 420
    void v_resample_frame()
    {}
#else

    static const int COL_COUNT_BITS = I_BITS;

    sc_uint<V_INPUT_BITS> v_just_read;
    DECLARE_WIRES(sc_uint<CRS_BPS>, v_just_read_wires);
    DECLARE_VAR_WITH_AU(sc_uint<COL_COUNT_BITS>, COL_COUNT_BITS, v_col_count);
    DECLARE_VAR_WITH_AU(sc_uint<COL_COUNT_BITS>, COL_COUNT_BITS, v_col_count_cpy);

#if CRS_ALGORITHM_V_NAME == INTERPOLATION_1D_NEAREST_NEIGHBOUR

#if CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT

    sc_uint<CRS_BPS> y_buffer1[CRS_WIDTH / 2];
    sc_uint<CRS_BPS> y_buffer2[CRS_WIDTH / 2];
    sc_uint<CRS_BPS> cb_buffer[CRS_WIDTH / 2];
    sc_uint<CRS_BPS> cr_buffer[CRS_WIDTH / 2];

    sc_uint<CRS_BPS> v_cb_out;
    DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, v_cr_out);

    void write_cb_y_cr_y()
    {
        if (CRS_PARALLEL_MODE)
        {
            sc_uint<CRS_BPS> y_buf2_d;

            y_buf2_d = ALT_PORTB(y_buffer2[v_col_count]);

            if (write_enable)
            {
                V_OUTPUT->write((ALT_PORTB(y_buffer1[v_col_count]), v_cb_out));
#if CRS_RESAMPLING_FORMAT_OUT == 422

                V_OUTPUT->writeDataAndEop((y_buf2_d, v_cr_out), v_eop);
#else

                V_OUTPUT->write((y_buf2_d, v_cr_out));
#endif

            }

        }
        else
        {
            if (write_enable)
            {
                V_OUTPUT->write(v_cb_out);
                V_OUTPUT->write(ALT_PORTB(y_buffer1[v_col_count]));
                V_OUTPUT->write(v_cr_out);
#if CRS_RESAMPLING_FORMAT_OUT == 422

                V_OUTPUT->writeDataAndEop(ALT_PORTB(y_buffer2[v_col_count]), v_eop);
#else

                V_OUTPUT->write(ALT_PORTB(y_buffer2[v_col_count]));
#endif

            }
        }
    }
    sc_uint<CRS_BPS> y_in1, y_in2, cb_cr_in;
    void v_process_sample()
    {
        DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, cb_in);
        if (CRS_PARALLEL_MODE)
        {
            if(!is_last_row)
            {
        	     v_just_read = V_INPUT->readWithinPacket(false);
            }
            UPDATE_WIRES(v_just_read_wires, V_IN_CHANNELS_IN_PAR, 0, v_just_read, 0, CRS_BPS);

            y_in1 = v_just_read_wires[0];

            ALT_NOSEQUENCE(v_cb_out = ALT_PORTB(cb_buffer[v_col_count]));

            ALT_NOSEQUENCE(cb_in = cb_in_AU.muxLdUI(
                                       ALT_PORTB(cb_buffer[v_col_count]),
                                       v_just_read_wires[1],
                                       is_even_row && !is_last_row));

            ALT_NOSEQUENCE(v_cr_out = v_cr_out_AU.muxLdUI(
                                          ALT_PORTB(cr_buffer[v_col_count]),
                                          v_just_read_wires[1],
                                          !is_even_row && !is_last_row));

            y_in2 = v_just_read_wires[2];

            write_cb_y_cr_y();
            ALT_PORTA(y_buffer1[v_col_count_cpy] = y_in1);
            ALT_PORTA(y_buffer2[v_col_count_cpy] = y_in2);
            ALT_PORTA(cb_buffer[v_col_count_cpy] = cb_in);
            ALT_PORTA(cr_buffer[v_col_count_cpy] = v_cr_out);

        }
        else
        {
            if(!is_last_row)
            {
        	    y_in1 = V_INPUT->readWithinPacket(false);
        	    cb_cr_in = V_INPUT->readWithinPacket(false);
        	    y_in2 = V_INPUT->readWithinPacket(false);
            }

            v_cb_out = ALT_PORTB(cb_buffer[v_col_count]);
            
            cb_in = cb_in_AU.muxLdUI(
                        ALT_PORTB(cb_buffer[v_col_count]),
                        cb_cr_in,
                        is_even_row && !is_last_row);

            v_cr_out = v_cr_out_AU.muxLdUI(
                           ALT_PORTB(cr_buffer[v_col_count]),
                           cb_cr_in,
                           !is_even_row && !is_last_row);

            write_cb_y_cr_y();
            ALT_PORTA(y_buffer1[v_col_count] = y_in1);
            ALT_PORTA(y_buffer2[v_col_count] = y_in2);
            ALT_PORTA(cb_buffer[v_col_count] = cb_in);
            ALT_PORTA(cr_buffer[v_col_count] = v_cr_out);

        }

        v_col_count++;
        v_col_count_cpy++;
    }
    // Don't write during the first row
    bool write_enable;
    // Even row refers to input rows
    bool is_even_row;
    bool is_last_row;
    bool v_eop;
    void v_resample_frame()
    {
        unsigned int step_cnt;
        sc_uint<I_BITS> i;
        sc_uint<J_BITS> j;

        is_even_row = 0;
        write_enable = false;
        is_last_row = false;

        for (j = 0;!is_last_row; j++)
        {
            bool is_last_col = false;

            is_even_row = !is_even_row;
            v_col_count = 0;
            v_col_count_cpy = 0;

            is_last_row = j == sc_uint<J_BITS>(v_height);
            
            sc_uint<I_BITS> i_cpy = 1;
            for (i = 0; i < sc_uint<I_BITS>(v_width >> (V_STEP_ITER / 2)); i++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MIN_ITERATIONS_PER_ROW);
                ALT_ATTRIB(ALT_MOD_TARGET, V_MOD_TARGET);
                
                is_last_col = i_cpy == sc_uint<I_BITS>(sc_uint<I_BITS>(v_width >> (V_STEP_ITER / 2)));

                for (step_cnt = 0;
                        step_cnt < V_STEP_ITER;
                        step_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON)
                    ;
                    ALT_ATTRIB(ALT_MIN_ITER, V_STEP_ITER);
                    ALT_ATTRIB(ALT_MAX_ITER, V_STEP_ITER);

                    v_eop = !(V_STEP_ITER == 2 && IS_ODD(v_width))
                            && step_cnt == STEP_ITER - 1
                            && is_last_row
                            && is_last_col;

                    v_process_sample();
                }
                i_cpy++;
            }
            if (V_STEP_ITER == 2 && IS_ODD(v_width)
               )
            {
                v_eop = is_last_row;
                v_process_sample();
            }

            write_enable = true;
        }
#if V_OWNS_DIN
        if (!V_INPUT->getEndPacket())
        {
            HW_DEBUG_MSG("did not get the expected eop, discarding extra data" << std::endl);
        }
        // Discard the data from the final read because it will be left on the input
        V_INPUT->read();
        // Discard any extra data after we had expected EOP
        while (!V_INPUT->getEndPacket())
        {
        	ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        	ALT_ATTRIB(ALT_MOD_TARGET, 1);
        	ALT_ATTRIB(ALT_MIN_ITER, 32);
        	ALT_ATTRIB(ALT_SKIDDING, true);
            V_INPUT->cRead(!V_INPUT->getEndPacket());
        }
#endif
#if V_OWNS_DOUT
        // Finally, switch off endPacket, ready for the next packet out
        V_OUTPUT->setEndPacket(false);
#endif
    }
#else //CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT
    sc_uint<CRS_BPS> cr_buffer[CRS_WIDTH / 2];
    bool is_even_row;
    bool v_eop;

    void v_process_sample()
    {
        sc_uint<CRS_BPS> y1, cr, y2, cb_or_cr_read;
        DECLARE_VAR_WITH_AU(sc_uint<CRS_BPS>, CRS_BPS, cb_or_cr)
        sc_uint<CRS_BPS> mem_read BIND(ALT_WIRE);

        if (CRS_PARALLEL_MODE)
        {
#if V_OWNS_DIN
            v_just_read = V_INPUT->readWithinPacket(false);
#else

            v_just_read = V_INPUT->read();
#endif

            UPDATE_WIRES(v_just_read_wires, V_IN_CHANNELS_IN_PAR, 0, v_just_read, 0, CRS_BPS);
            y1 = v_just_read_wires[1];

            ALT_NOSEQUENCE(mem_read = cr_buffer[v_col_count]);

            cb_or_cr = cb_or_cr_AU.muxLdUI(
                           v_just_read_wires[0],
                           mem_read,
                           !is_even_row);
#if V_OWNS_DIN
            v_just_read = V_INPUT->readWithinPacket(false);
#else

            v_just_read = V_INPUT->read();
#endif
            UPDATE_WIRES(v_just_read_wires, V_IN_CHANNELS_IN_PAR, 0, v_just_read, 0, CRS_BPS);
            y2 = v_just_read_wires[1];
            cr = v_just_read_wires[0];

            cr_buffer[ALT_STAGE(v_col_count, 2)] = cr;

            V_OUTPUT->writeDataAndEop((y2, cb_or_cr, y1), v_eop);
        }
        else
        {
            ALT_NOSEQUENCE(mem_read = cr_buffer[v_col_count]);

#if V_OWNS_DIN
            
            cb_or_cr = cb_or_cr_AU.muxLdUI(V_INPUT->readWithinPacket(false),
                                           mem_read,
                                           !is_even_row);
#else
            cb_or_cr = cb_or_cr_AU.muxLdUI(V_INPUT->read(),
                                           mem_read,
                                           !is_even_row);
#endif

#if V_OWNS_DIN
            y1 = V_INPUT->readWithinPacket(false);
            cr = V_INPUT->readWithinPacket(false);
            y2 = V_INPUT->readWithinPacket(false);
#else

            y1 = V_INPUT->read();
            cr = V_INPUT->read();
            y2 = V_INPUT->read();
#endif

            cr_buffer[v_col_count] = cr;
            V_OUTPUT->write(y1);
            V_OUTPUT->write(cb_or_cr);
            V_OUTPUT->writeDataAndEop(y2, v_eop);
        }

        v_col_count++;
    }
    void v_resample_frame()
    {
        sc_uint<I_BITS> i;
        sc_uint<J_BITS> j;
        unsigned int step_cnt;

        bool is_last_row = false;


        is_even_row = 0;

        for (j = 1; !is_last_row; j++)
        {
            bool is_last_col = false;
            is_last_row = j == sc_uint<J_BITS>(v_height);

            v_col_count = 0;
            is_even_row = !is_even_row;
            sc_uint<I_BITS> i_cpy = 1;
            for (i = 0; i < sc_uint<I_BITS>(v_width >> (V_STEP_ITER / 2)); i++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MIN_ITERATIONS_PER_ROW);
                ALT_ATTRIB(ALT_MOD_TARGET, V_MOD_TARGET);
                
                is_last_col = i_cpy == sc_uint<I_BITS>(sc_uint<I_BITS>(v_width >> (V_STEP_ITER / 2)));

                for (step_cnt = 0;
                        step_cnt < V_STEP_ITER;
                        step_cnt++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON)
                    ;
                    ALT_ATTRIB(ALT_MIN_ITER, V_STEP_ITER);
                    ALT_ATTRIB(ALT_MAX_ITER, V_STEP_ITER);

                    v_eop = !(V_STEP_ITER == 2 && IS_ODD(v_width))
                            && step_cnt == STEP_ITER - 1
                            && is_last_row
                            && is_last_col;

                    v_process_sample();

                }
                i_cpy++;

            }
            if (V_STEP_ITER == 2 && IS_ODD(v_width)
               )
            {
                v_eop = is_last_row;
                v_process_sample();
            }
        }
#if V_OWNS_DIN
        if (!V_INPUT->getEndPacket())
        {
            HW_DEBUG_MSG("did not get the expected eop, discarding extra data" << std::endl);
        }
        // Discard the data from the final read because it will be left on the input
        V_INPUT->read();
        // Discard any extra data after we had expected EOP
        while (!V_INPUT->getEndPacket())
        {
        	ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        	ALT_ATTRIB(ALT_MOD_TARGET, 1);
        	ALT_ATTRIB(ALT_MIN_ITER, 32);
        	ALT_ATTRIB(ALT_SKIDDING, true);
            V_INPUT->cRead(!V_INPUT->getEndPacket());
        }
#endif
#if V_OWNS_DOUT
        // Finally, switch off endPacket, ready for the next packet out
        V_OUTPUT->setEndPacket(false);
#endif

    }
#endif //CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT
#else //CRS_ALGORITHM_V_NAME == INTERPOLATION_1D_NEAREST_NEIGHBOUR
#if CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT
    static const int V_CHANNELS = 4;
    static const int V_TAPS = 7;

#endif

    static const int PIX_TO_PRE_BUFFER = (V_TAPS - 1) / 2;
    static const int V_KERNEL_CENTRE = (V_TAPS - 1) / 2;

    ALT_REGISTER_FILE < CRS_BPS, 2, 1, CRS_WIDTH / 2 > line_buf_REG_FILE[V_CHANNELS*V_TAPS];
    sc_uint<CRS_BPS> line_buf[V_CHANNELS*V_TAPS][CRS_WIDTH / 2] BIND(line_buf_REG_FILE);
    sc_uint<I_BITS> i_v;
    sc_uint<J_BITS> j_v;
    bool read_enable;

    void pre_fill_line_bufs()
    {
        int sequence_cnt, tap_cnt;
        for (j_v = 0; j_v < sc_uint<J_BITS>(PIX_TO_PRE_BUFFER); j_v++)
        {
            for (i_v = 0; i_v < sc_uint<I_BITS>(CRS_WIDTH / 2); i_v++)
            {
                for (sequence_cnt = 0; sequence_cnt < V_CHANNELS; sequence_cnt++)
                {
                    // Most of the kernel advances by 1
                    for (tap_cnt = 0; tap_cnt < V_TAPS - 1; tap_cnt++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, N_TAPS - 1);
                        ALT_ATTRIB(ALT_MAX_ITER, N_TAPS - 1);
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        line_buf[V_FLAT_CHANNELS_IN_SEQ(tap_cnt)][i_v] = line_buf[V_FLAT_CHANNELS_IN_SEQ(tap_cnt + 1)][i_v];
                    }
                    line_buf[V_FLAT_CHANNELS_IN_SEQ(V_TAPS - 1)][i_v] = V_INPUT->read();
                    if ((long)i_v == 0 && sequence_cnt == 1)
                    {
                        INSPECT_VAR(cerr, line_buf[V_FLAT_CHANNELS_IN_SEQ(V_TAPS - 1)][i_v]);
                        cerr << endl;
                    }
                }
            }
        }
    }
    void v_advance_kernel()
    {
        int sequence_cnt, tap_cnt;

        for (sequence_cnt = 0; sequence_cnt < V_CHANNELS; sequence_cnt++)
        {
            // Most of the kernel advances by 1
            for (tap_cnt = 0; tap_cnt < V_TAPS - 1; tap_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, N_TAPS - 1);
                ALT_ATTRIB(ALT_MAX_ITER, N_TAPS - 1);
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                line_buf[V_FLAT_CHANNELS_IN_SEQ(tap_cnt)][i_v] = line_buf[V_FLAT_CHANNELS_IN_SEQ(tap_cnt + 1)][i_v];
            }

            if (read_enable)
            {
                line_buf[V_FLAT_CHANNELS_IN_SEQ(V_TAPS - 1)][i_v] = V_INPUT->read();
            }
        }
    }
    void v_resample_frame()
    {
        bool is_even_row;
        read_enable = true;
        is_even_row = true;
        pre_fill_line_bufs();
        for (j_v = 0; j_v < sc_uint<J_BITS>(CRS_HEIGHT - PIX_TO_PRE_BUFFER); j_v++)
        {
            for (i_v = 0; i_v < sc_uint<I_BITS>(CRS_WIDTH / 2); i_v++)
            {
                v_advance_kernel();
                V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 0)][i_v]);
                if (is_even_row)
                {
                    V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 1)][i_v]);
                }
                else
                {
                    V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE - 1, 3)][i_v]);
                }
                V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 2)][i_v]);
            }
            is_even_row = !is_even_row;
        }
        read_enable = false;
        for (j_v = 0; j_v < sc_uint<J_BITS>(PIX_TO_PRE_BUFFER); j_v++)
        {
            for (i_v = 0; i_v < sc_uint<I_BITS>(CRS_WIDTH / 2); i_v++)
            {
                v_advance_kernel();
                V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 0)][i_v]);
                if (is_even_row)
                {
                    V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 1)][i_v]);
                }
                else
                {
                    V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE - 1, 3)][i_v]);
                }
                V_OUTPUT->write(line_buf[V_EXPLICIT_FLAT_CHANNELS_IN_SEQ(KERNEL_CENTRE, 2)][i_v]);
            }
            is_even_row = !is_even_row;
        }
    }

#endif //CRS_ALGORITHM_V_NAME == INTERPOLATION_1D_NEAREST_NEIGHBOUR
 #endif //CRS_RESAMPLING_FORMAT_IN != 420 && CRS_RESAMPLING_FORMAT_OUT != 420
#endif // SYNTH_MODE

    SC_HAS_PROCESS(CRS_NAME);

    CRS_NAME(sc_module_name name_, int in_channels_in_par=1, int out_channels_in_par=1, const char* PARAMETERISATION = "<chromaResamplerParams><CRS_NAME>chroma_resampler</CRS_NAME><CRS_BPS>8</CRS_BPS><CRS_WIDTH>256</CRS_WIDTH><CRS_HEIGHT>256</CRS_HEIGHT><CRS_PARALLEL_MODE>false</CRS_PARALLEL_MODE><CRS_RESAMPLING><FORMAT><IN>422</IN><OUT>444</OUT></FORMAT><COSITING><V>true</V><H>true</H></COSITING></CRS_RESAMPLING><CRS_ALGORITHM><V><NAME>INTERPOLATION_1D_NEAREST_NEIGHBOUR</NAME><LUMA_ADAPTIVE>false</LUMA_ADAPTIVE></V><H><NAME>INTERPOLATION_1D_FULL_FILTERING</NAME><LUMA_ADAPTIVE>true</LUMA_ADAPTIVE></H></CRS_ALGORITHM></chromaResamplerParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        //! Input ports
        din = new ALT_AVALON_ST_INPUT< sc_uint<CRS_BPS*CRS_IN_CHANNELS_IN_PAR> >();
        //! Output ports
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint<CRS_BPS*CRS_OUT_CHANNELS_IN_PAR > >();
        
#ifndef LEGACY_FLOW
        int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "chromaResamplerParams;CRS_BPS", 8);
        din->setDataWidth(in_channels_in_par*bps);
        dout->setDataWidth(out_channels_in_par*bps);
        din->setSymbolsPerBeat(in_channels_in_par);
        dout->setSymbolsPerBeat(out_channels_in_par);
        din->enableEopSignals();
        dout->enableEopSignals();
#endif

#ifdef SYNTH_MODE
        inter_thread_fifo = new ALT_FIFO<sc_uint<CRS_BPS * FIFO_CHANNELS_IN_PAR + 1>, 3>();
#if (CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT && CRS_RESAMPLING_FORMAT_IN == 444) || (CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT && CRS_RESAMPLING_FORMAT_OUT == 444)

        SC_THREAD(h_resampling);
#endif

#if (CRS_RESAMPLING_FORMAT_IN > CRS_RESAMPLING_FORMAT_OUT && CRS_RESAMPLING_FORMAT_OUT == 420) || (CRS_RESAMPLING_FORMAT_IN < CRS_RESAMPLING_FORMAT_OUT && CRS_RESAMPLING_FORMAT_IN == 420)

        SC_THREAD(v_resampling);
#endif
#endif //SYNTH_MODE

    }

    const char* param;
};
