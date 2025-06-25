// Deinterlacer Hardware Model
//
// Supports a variety of deinterlacing modes, makes use of the kerneliser for
// some of these.
//
// Author: dnanceki

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

// Tell CusP it will find a way to schedule the MA loop with 3x2, 2x3 and 3x3 channels
#pragma cusp_config tryHarder = yes

#ifndef __CUSP__
    #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
    #undef DIL_NAME
    #define DIL_NAME alt_vip_dil
#endif

SC_MODULE(DIL_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/deinterlacer.jar?com.altera.vip.entityinterfaces.helpers.DILEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Deinterlacer";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Deinterlacer converts interlaced video to progressive video using \"Bob\", \"Weave\" or \"Motion Adaptive\" algorithms.";
    }

    static const char * get_product_ids(void)
    {
        return "00B6";
    }

    #include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif // LEGACY_FLOW

    // Data input and output ports
#ifndef SYNTH_MODE
    #define DIL_BPS 20
    #define DIL_CHANNELS_IN_PAR 3
    #define DIL_MOTION_WRITE_MASTER_MAX_BURST  16
    #define DIL_MOTION_READ_MASTER_MAX_BURST  16
    #define DIL_MASTER_PORT_WIDTH 256
    #define KER_MASTER_PORT_WIDTH 256
    #define KER_READ_MASTERS_MAX_BURST 16
    #define KER_WRITE_MASTER_MAX_BURST 16
    #define KER_BPS_PAR 60
    #define KER_MEM_ADDR_WIDTH 32
    #define DIL_MEM_MASTERS_USE_SEPARATE_CLOCK false
    #define DIL_WDATA_FIFO_DEPTH 64
    #define DIL_RDATA_FIFO_DEPTH 64
    ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_WRITE_MASTER_MAX_BURST, KER_BPS_PAR> *write_master;
    ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_READ_MASTERS_MAX_BURST, KER_BPS_PAR> *read_master;
    #define DIL_MA_CTRL_INTERFACE_WIDTH 16
    #define DIL_MA_CTRL_INTERFACE_DEPTH 4
    #define KER_WRITER_CTRL_INTERFACE_WIDTH 8
    #define KER_WRITER_CTRL_INTERFACE_DEPTH 4
    ALT_AVALON_MM_RAW_SLAVE<KER_WRITER_CTRL_INTERFACE_WIDTH, KER_WRITER_CTRL_INTERFACE_DEPTH> *ker_writer_control;
#else
    #ifdef DIL_MAX_MOTION_WORDS_IN_FIELD
        #define DIL_MOTION_WRITE_FIFO_DEPTH           DIL_WDATA_FIFO_DEPTH
        #define DIL_MOTION_WRITE_BURST_TARGET         DIL_WDATA_BURST_TARGET
        // Reserve enough space in the command FIFO so that we can issue enough write command to fill the FIFO, + 1 to avoid lock during pipelining
        #define DIL_MOTION_WRITE_MASTER_MAX_BURST     DIL_MOTION_WRITE_BURST_TARGET
        #define DIL_MOTION_WRITE_CMD_FIFO_DEPTH       ((DIL_WDATA_FIFO_DEPTH / DIL_WDATA_BURST_TARGET) + 1)
        #define DIL_MOTION_READ_FIFO_DEPTH            DIL_RDATA_FIFO_DEPTH
        #define DIL_MOTION_READ_BURST_TARGET          DIL_RDATA_BURST_TARGET
        #define DIL_MOTION_READ_MASTER_MAX_BURST      ((DIL_MAX_MOTION_WORDS_IN_FIELD > DIL_MOTION_READ_BURST_TARGET) ? DIL_MAX_MOTION_WORDS_IN_FIELD : DIL_MOTION_READ_BURST_TARGET)
        #define DIL_MOTION_READ_CMD_FIFO_DEPTH        1
    #else
        #define DIL_MOTION_WRITE_MASTER_MAX_BURST 32
        #define DIL_MOTION_READ_MASTER_MAX_BURST 32
    #endif
#endif


#define DIL_BPS_PAR DIL_BPS * DIL_CHANNELS_IN_PAR
#define DIL_MAX_FIELD_HEIGHT (DIL_MAX_HEIGHT / 2)

    ALT_AVALON_ST_INPUT< sc_uint<DIL_BPS_PAR> > *din;
    ALT_AVALON_ST_OUTPUT< sc_uint<DIL_BPS_PAR> > *dout;

    ALT_AVALON_MM_MASTER_FIFO< DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_WRITE_MASTER_MAX_BURST, DIL_BPS > *motion_write_master ALT_BIND_SEQ_PER_RESOURCE;
    ALT_AVALON_MM_MASTER_FIFO< DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_READ_MASTER_MAX_BURST, DIL_BPS > *motion_read_master ALT_BIND_SEQ_PER_RESOURCE;

    ALT_AVALON_MM_RAW_SLAVE<DIL_MA_CTRL_INTERFACE_WIDTH, DIL_MA_CTRL_INTERFACE_DEPTH> *ma_control;

#ifdef SYNTH_MODE

    // The runtime variables to be used by the kernelizer (going through output fifo at the moment)
    //#define KER_FIELD_WIDTH field_width;
    //#define KER_FIELD_HEIGHT field_height;

    // A Kerneliser is attached to din when there is buffering (weave mode, motion
    // adaptive mode or bob mode with double or triple buffering selected)
    #define KERNELIZER_INPUT (DIL_BUFFER_AS_THOUGH != DEINTERLACING_NO_BUFFERING)

    #if (KERNELIZER_INPUT)
        // Set up the kerneliser's input (must be an Avalon-ST input at the moment)
        #define KER_DIN din

        // Set up the kerneliser's output, one extra bit is for eop signal
        // with the motion adaptive algorithm, the kernelizer outputs 18 pixels at once.
        // This FIFO also has to be large enough to be able to ouput the width and height sent by the kernelizer
        #define KER_TO_DIL_WIDTH MAX(1 + (DIL_BPS_PAR * ((DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE) ? 18 : 1)), HEADER_WORD_BITS*4)
        ALT_FIFO < sc_biguint<KER_TO_DIL_WIDTH> , 3 > ker_to_dil;
        #define KER_DOUT ker_to_dil

        // Include the kerneliser itself - the DIL parameter helper will have
        // included and configured a ker ph component which will have written out
        // appropriate #defines to make the kerneliser do the right thing
        #define KER_WDATA_BURST_TARGET DIL_WDATA_BURST_TARGET
        #define KER_RDATA_BURST_TARGET DIL_RDATA_BURST_TARGET
        #include "vip_ker_hw_component.hpp"

        sc_biguint<KER_TO_DIL_WIDTH> just_read_in;

        bool input_field_type;
        #if (DIL_PROPAGATE_PROGRESSIVE)
            bool input_field_prog;
        #else
            #define input_field_prog 0
        #endif
        #define REPEAT_FLAG_IS_SENT ((DIL_BUFFER_AS_THOUGH == DEINTERLACING_TRIPLE_BUFFERING) || DIL_CONTROLLED_DROP_REPEAT)
        #if (DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE)
            bool break_flow;
            #if REPEAT_FLAG_IS_SENT
                bool not_a_repeat;
            #else
                // make a direct #def mapping from not_a_repeat to 1 when the kernelizer does not repeat fields
                #define not_a_repeat 1
            #endif
        #endif
    #else
        #define KER_MASTER_PORT_WIDTH 64
        #define KER_MEM_ADDR_WIDTH 32
        #define KER_READ_MASTERS_MAX_BURST 32
        #define KER_WRITE_MASTER_MAX_BURST 32
        #define KER_BPS_PAR 8
        // Declare read/write masters and kernelizer control with fake parameter and set them to NULL in the constructor
        ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_WRITE_MASTER_MAX_BURST, KER_BPS_PAR > *write_master;
        ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_READ_MASTERS_MAX_BURST, KER_BPS_PAR > *read_master;
        ALT_AVALON_MM_RAW_SLAVE<KER_WRITER_CTRL_INTERFACE_WIDTH, KER_WRITER_CTRL_INTERFACE_DEPTH> *ker_writer_control;

        sc_uint<DIL_BPS_PAR> just_read_in;

        static const unsigned int INTERLACE_FLAG_BIT = HEADER_WORD_BITS-1;
        static const unsigned int INTERLACE_FIELD_TYPE_BIT = HEADER_WORD_BITS-2;
    #endif // Kernelizer is used/unused

    // variables filled by the packet handling code (bob with no buffering) or by the code that handles the ker_to_dil output FIFO
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, input_field_width);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, input_field_height);

/*************************************** Packet related variables and functions if the kernelizer is used ****************/
#if (KERNELIZER_INPUT)
    void handle_kernelizer_packets()
    {
        sc_uint<HEADER_WORD_BITS> header_type;
        bool is_not_image_data;
        do
        {
            just_read_in = ker_to_dil.read();
            header_type = sc_uint<HEADER_WORD_BITS>(just_read_in);
            is_not_image_data = (header_type != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));

            if (is_not_image_data)
            {
                HW_DEBUG_MSG("Passing on packet of type " << header_type << " from the kernelizer" << std::endl);
                dout->writeDataAndEop(sc_uint<DIL_BPS_PAR>(just_read_in.range(DIL_BPS_PAR-1, 0)),
                                      just_read_in.bit(DIL_BPS_PAR));
                while (!just_read_in.bit(DIL_BPS_PAR))
                {
                    just_read_in = ker_to_dil.read();
                    dout->writeDataAndEop(sc_uint<DIL_BPS_PAR>(just_read_in.range(DIL_BPS_PAR-1, 0)),
                                          just_read_in.bit(DIL_BPS_PAR));
                }
            }
        } while (is_not_image_data);
        HW_DEBUG_MSG("Receiving image data from the kernelizer" << std::endl);
        //read width/ height and interlace flag form the kernelizer
        input_field_width = ker_to_dil.read();
        input_field_height = ker_to_dil.read();
        HW_DEBUG_MSG("Data based on field : " << input_field_width << 'x' << input_field_height << std::endl);

        // Read frame_info and store information in separate variables
        just_read_in = ker_to_dil.read();
        input_field_type = just_read_in.bit(REPEAT_FLAG_IS_SENT ? 2 : 1);
        #if DIL_PROPAGATE_PROGRESSIVE
            input_field_prog = !just_read_in.bit(REPEAT_FLAG_IS_SENT ? 3 : 2);
        #endif
        HW_DEBUG_MSG("Field type=" << (input_field_prog ? "prog" : (input_field_type ? "F1":"F0")) << std::endl);
        #if (DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE)
            #if REPEAT_FLAG_IS_SENT
                not_a_repeat = just_read_in.bit(1);
            #endif
            break_flow = just_read_in.bit(0);
            HW_DEBUG_MSG_COND(!not_a_repeat, "Receiving a repeat from the kernelizer" << std::endl);
            HW_DEBUG_MSG_COND(break_flow, "Receiving a break info from the kernelizer" << std::endl);
        #endif
    }
#endif

/*************************************** Packet related variables and functions if the kernelizer is not used ****************/
#if (!KERNELIZER_INPUT)
    #define PACKET_BPS DIL_BPS
    #define PACKET_CHANNELS_IN_PAR DIL_CHANNELS_IN_PAR
    sc_uint<HEADER_WORD_BITS> header_type;

    // make a direct #def mapping from input_field_type/input_field_prog to input_field_interlace when the kernelizer is not used
    #define input_field_type input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)
    #define input_field_prog !input_field_interlace.bit(INTERLACE_FLAG_BIT)

    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, input_field_interlace);

    // When reading control words in parallel, these wires keep the next data element at just_read_queue[0]
    // Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
    sc_uint<PACKET_BPS> just_read_queue[PACKET_CHANNELS_IN_PAR] BIND(ALT_WIRE);

    // void read_and_propagate(int occurrence)
    // For reading control packet data when we do not expect the previous read to have been EOP
    // If an early EOP had occured, no more reads are taken from din, and no more data
    // is sent to the output.
    // To abstract away the fact that control packets are sent with each symbol, and can come in parallel,
    // this function either reads from din, or advances the just_read_queue array. To decide which to do, it
    // needs to know how many times it has been called. Since Cusp is not be able to figure out that an
    // incrementing counter can be evaluated at compile-time, the function much be called with a number
    // indicating which occurence it is being used in. It will do an actual read when occurrence%CHANNELS_IN_PAR == 0
    //
    // @param occurrence the amount of times this function has been called in a sequence
    void read_and_propagate(int occurrence)
    {
        // Do the read and propagation every PACKET_CHANNELS_IN_PAR iteration starting at 0 and reset just_read_queue
        if (occurrence % PACKET_CHANNELS_IN_PAR == 0)
        {
            sc_uint<PACKET_CHANNELS_IN_PAR * PACKET_BPS> just_read_access_wire BIND(ALT_WIRE);
            just_read_access_wire = 0;

            if (!din->getEndPacket())
            {
                just_read_in = din->read();
                dout->writeDataAndEop(just_read_in, din->getEndPacket());
            }

            // Set up just_read_queue, should be able to use .range(), but Cusp is weak, so use a wire and shifting
            // to get to the words inside PACKET_JUST_READ_VAR
            just_read_access_wire = just_read_in;
            for (int i = 0; i < PACKET_CHANNELS_IN_PAR; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                just_read_queue[i] = just_read_access_wire;
                just_read_access_wire >>= PACKET_BPS;
            }
        }
        // In other cases just advance the elements of the just_read_queue (ALT_WIRE?) array
        else
        {
            for (int i = 0; i < PACKET_CHANNELS_IN_PAR - 1; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                just_read_queue[i] = just_read_queue[i + 1];
            }
        }
    }

    void handle_non_image_packets()
    {
        bool is_not_image_data;
        do
        {
            just_read_in = din->read();
            header_type = just_read_in;

            is_not_image_data = (header_type != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));

            HW_DEBUG_MSG_COND(!is_not_image_data, "Image header received" << std::endl);

            if (is_not_image_data)
            {
                HW_DEBUG_MSG("Processing packet of type " << header_type << std::endl);

                // Assume that all incoming packets is a control packet. If not then just skip the assignment to control
                // registers.
                bool is_control_packet = (header_type == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER));

                dout->writeDataAndEop(just_read_in, din->getEndPacket());

                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    read_and_propagate(i);
                    if (i == 0)
                    {
                        input_field_width = input_field_width_REG.cLdUI((sc_uint<HEADER_WORD_BITS>(just_read_queue[0]), input_field_width.range(HEADER_WORD_BITS * 3 - 1, 0)),
                                                                    input_field_width,
                                                                    is_control_packet);
                    }
                    else if (i == 3)
                    {
                        input_field_width = input_field_width_REG.cLdUI((input_field_width.range(HEADER_WORD_BITS * 4 - 1, HEADER_WORD_BITS * 1), sc_uint<HEADER_WORD_BITS>(just_read_queue[0])),
                                                                    input_field_width,
                                                                    is_control_packet);
                    }
                    else
                    {
                        // Want to write:
                        // input_field_width = (input_field_width.range(HEADER_WORD_BITS * 4 - 1, HEADER_WORD_BITS * (4 - i)), sc_uint<HEADER_WORD_BITS>(just_read_queue[0]), input_field_width.range(HEADER_WORD_BITS * (3 - i) - 1, 0));
                        // but Cusp won't do it, so faff around with wires to get the same effect...
                        sc_uint<HEADER_WORD_BITS*4> packingWire BIND(ALT_WIRE);

                        packingWire = input_field_width.range(HEADER_WORD_BITS * 4 - 1, HEADER_WORD_BITS * (4 - i));
                        packingWire <<= HEADER_WORD_BITS;
                        packingWire = packingWire | sc_uint<HEADER_WORD_BITS>(just_read_queue[0]);
                        packingWire <<= HEADER_WORD_BITS * (3 - i);
                        packingWire = packingWire | input_field_width.range(HEADER_WORD_BITS * (3 - i) - 1, 0);
                        input_field_width = input_field_width_REG.cLdUI(packingWire, input_field_width, is_control_packet);
                    }
                }
                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    read_and_propagate(4 + i);
                    if (i == 0)
                    {
                        input_field_height = input_field_height_REG.cLdUI((sc_uint<HEADER_WORD_BITS>(just_read_queue[0]), input_field_height.range(HEADER_WORD_BITS * 3 - 1, 0)),
                                                                  input_field_height,
                                                                  is_control_packet);
                    }
                    else if (i == 3)
                    {
                        input_field_height = input_field_height_REG.cLdUI((input_field_height.range(HEADER_WORD_BITS * 4 - 1, HEADER_WORD_BITS * 1), sc_uint<HEADER_WORD_BITS>(just_read_queue[0])),
                                                                      input_field_height,
                                                                      is_control_packet);
                    }
                    else
                    {
                        sc_uint<HEADER_WORD_BITS*4> packingWire BIND(ALT_WIRE);
                        packingWire = input_field_height.range(HEADER_WORD_BITS * 4 - 1, HEADER_WORD_BITS * (4 - i));
                        packingWire <<= HEADER_WORD_BITS;
                        packingWire = packingWire | sc_uint<HEADER_WORD_BITS>(just_read_queue[0]);
                        packingWire <<= HEADER_WORD_BITS * (3 - i);
                        packingWire = packingWire | input_field_height.range(HEADER_WORD_BITS * (3 - i) - 1, 0);
                        input_field_height = input_field_height_REG.cLdUI(packingWire, input_field_height, is_control_packet);
                    }
                }
                read_and_propagate(8);
                input_field_interlace = input_field_interlace_REG.cLdUI(just_read_queue[0], input_field_interlace, is_control_packet);

                HW_DEBUG_MSG_COND(!din->getEndPacket() && is_control_packet, "Extra data in packet passed on" << std::endl);
                while (!din->getEndPacket())
                {
                    just_read_in = din->cRead(!din->getEndPacket());
                    dout->writeDataAndEop(just_read_in, din->getEndPacket());
                }
            }
        } while (is_not_image_data);
    }

#endif //!KERNELIZER_INPUT

    // Write a correct control packet just before image data whatever the method used (with or without kernelizer)
    // this function assumes that input_field_width, input_field_height and input_field_type/input_field_prog
    // have been set correctly
    void write_corrected_packet()
    {
        // Store the outputs in a shift register to abstract away
        // the fact that they could be written out in parallel or
        // sequence
        static const int N_HEADER_WORDS_TO_SEND = 9;
        ALT_REG<HEADER_WORD_BITS> output_REG[N_HEADER_WORDS_TO_SEND];
        sc_uint<HEADER_WORD_BITS> output[N_HEADER_WORDS_TO_SEND] BIND(output_REG);
        HW_DEBUG_MSG("Sending correct control packet" << std::endl);

        dout->writeDataAndEop(CONTROL_HEADER, false); // Send the type first

        // The width
        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[i] = input_field_width.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // The height, input_field_height x 2 unless in bob mode when progressive passthrough is used
        #if (DIL_PROPAGATE_PROGRESSIVE && ((DIL_METHOD == DEINTERLACING_BOB_SCANLINE_DUPLICATION) || (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_INTERPOLATION)))
            // for bob (with OR without kernelizer), input_field_height is set to the height of the field received, ie, the total height
            // of a frame when a progressive field is received.
            DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, ctrl_field_height);
            ctrl_field_height = input_field_prog ? sc_uint<HEADER_WORD_BITS*4>(input_field_height) :
                                                     sc_uint<HEADER_WORD_BITS*4>(input_field_height << 1);
        #else
             // for weave and ma, input_field_height always matches the half-height of the progressive output.
             sc_uint<HEADER_WORD_BITS*4> ctrl_field_height BIND(ALT_WIRE);
             ctrl_field_height = input_field_height << 1;
        #endif
        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[4 + i] = ctrl_field_height.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // Interlacing
        output[8] = sc_uint<HEADER_WORD_BITS>((sc_uint<2>(0), sc_uint<1>(input_field_prog), sc_uint<1>(input_field_prog || input_field_type)));

        // Write out the control packet, packing into wide words for symbols in parallel. If the two
        // do not divide exactly, round up and send an extra word with whatever happens to be in the
        // right place.
        for (unsigned int i = 0; i < (N_HEADER_WORDS_TO_SEND + DIL_CHANNELS_IN_PAR - 1) / DIL_CHANNELS_IN_PAR; ++i)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            sc_uint<DIL_BPS_PAR> thisOutput BIND(ALT_WIRE);
            thisOutput = 0;
            // Pack a word to write out. If the last word doesn't full fill the word, wrap
            // around and write again from the front
            for (int j = DIL_CHANNELS_IN_PAR - 1; j >= 0; j--)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                thisOutput <<= DIL_BPS;
                thisOutput = thisOutput | output[j];
            }

            // Shift the words to write along
            for (int j = 0; j < N_HEADER_WORDS_TO_SEND - DIL_CHANNELS_IN_PAR; j++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                output[j] = output[j + DIL_CHANNELS_IN_PAR];
            }

            dout->writeDataAndEop(thisOutput, i == (N_HEADER_WORDS_TO_SEND + DIL_CHANNELS_IN_PAR - 1) / DIL_CHANNELS_IN_PAR - 1);
        }

        dout->setEndPacket(false);
    }


    /*****************************************************************************************************************************/
    /*                                 Bob deinterlacing thread and associated functions                                         */
    /*****************************************************************************************************************************/
#if ((DIL_METHOD == DEINTERLACING_BOB_SCANLINE_DUPLICATION) || (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_INTERPOLATION))

    // The bob algorithm is completely different whether the kernelizer is used or not since the input is either
    // the kernelizer output FIFO or an Avalon-ST input. In the first case the bob deinterlacer has to deal with
    // the extra token the kernelizer is sending with a field, in the second case the bob deinterlacer has to process
    // the control packet itself. The common code/variables appears first

    // A single line buffer (to perform duplication or interpolation)
    sc_uint<DIL_BPS_PAR> line_buffer_counter[DIL_MAX_WIDTH * DIL_CHANNELS_IN_SEQ];

    // How many samples per row?
    sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW> samples_in_row;

    // Create max input height, derived from max field height and making allowance for possible progressive frames
    #define DIL_LOG2G_MAX_INPUT_HEIGHT (DIL_PROPAGATE_PROGRESSIVE ? (DIL_LOG2G_MAX_FIELD_HEIGHT + 1) : DIL_LOG2G_MAX_FIELD_HEIGHT)

    // Loop counters
    DECLARE_VAR_WITH_AU(sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>, DIL_LOG2G_MAX_SAMPLES_IN_ROW+1, width_counter);
    DECLARE_VAR_WITH_AU(sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>, DIL_LOG2G_MAX_SAMPLES_IN_ROW+1, width_counter_cp);
    sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW> line_counter;

    DECLARE_VAR_WITH_AU(sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>, DIL_LOG2G_MAX_INPUT_HEIGHT+1, height_counter);

    #if (!KERNELIZER_INPUT)
    // Discarding unused/unexpected fields
    void bob_discard_field()
    {
        while(!din->getEndPacket())
        {
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);
            ALT_ATTRIB(ALT_SKIDDING, true);
            din->cRead(!din->getEndPacket());
        }
    }
    #endif

    // Output a row of pixels from the line buffer (do not read anything)
    // bob_eop_trigger has to be set before calling this function to trigger the eop with the last sample
    bool bob_eop_trigger;
    void bob_load_to_write()
    {
        line_counter = 0;
        width_counter_cp = samples_in_row;
        for (width_counter = samples_in_row + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
        {
            // Attributes of this loop
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

            --width_counter_cp;
            vip_assert(width_counter == width_counter_cp);
            bool last_sample = (width_counter_cp == sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(0));

            // Write from line buffer to output
            vip_assert(int(samples_in_row) - int(width_counter) - 1 == int(line_counter));
            just_read_in = line_buffer_counter[line_counter];
            dout->writeDataAndEop(just_read_in, bob_eop_trigger && last_sample);
            ++line_counter;
        }
    }

    // Read a row of pixels and both write it to the line buffer and output it.
    void bob_read_to_store_and_write()
    {
        line_counter = 0;
        for (width_counter = samples_in_row + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
        {
            // Attributes of this loop
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

            // Read pixel from current field input
            #if (KERNELIZER_INPUT)
                just_read_in = ker_to_dil.read();
            #else
                // Make sure not to go beyond the end of packet if the eop arrives early
                just_read_in = din->cRead(!din->getEndPacket());
            #endif

            // Write to both output and line buffer
            vip_assert(int(samples_in_row) - int(width_counter) - 1 == int(line_counter));
            line_buffer_counter[line_counter] = just_read_in;
            dout->writeDataAndEop(just_read_in, false);
            ++line_counter;
        }
    }

    #if (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_INTERPOLATION)
    // Read a row of pixels into the line buffer, output the unweighted
    // mean of the pixel being written into the line buffer and the pixel
    // that was there before.
    void bob_interpolate()
    {
        // Words to hold pixels read and calculated
        sc_uint<DIL_BPS_PAR> pix_in_d1, pix_lb, pix_interpolated;
        sc_uint<DIL_BPS_PAR> pix_in_wire BIND(ALT_WIRE);
        sc_uint<DIL_BPS_PAR> pix_lb_wire BIND(ALT_WIRE);
        sc_uint<DIL_BPS_PAR> pix_interpolated_wire BIND(ALT_WIRE);

        // An additional loop counter (not sure why Dom used a second counter there, it seems related to the line_buffer_counter and ALT_NOSEQUENCE ?)
        sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW> line_counter2;

        line_counter = 0;
        line_counter2 = 0;
        for (width_counter = samples_in_row + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
        {
            // Attributes of this loop
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

            // Read pixel from current field input
            #if (KERNELIZER_INPUT)
                just_read_in = ker_to_dil.read();
            #else
                // Make sure not to go beyond the end of packet if the eop arrives early
                just_read_in = din->cRead(!din->getEndPacket());
            #endif

            pix_in_d1 = just_read_in;

            // Read pixel from line buffer
            vip_assert(int(samples_in_row) - int(width_counter) - 1 == int(line_counter));
            ALT_NOSEQUENCE(pix_lb = line_buffer_counter[line_counter]);

            // Update line buffer with new pixel
            vip_assert(line_counter2 == line_counter);
            ALT_NOSEQUENCE(line_buffer_counter[line_counter2] = just_read_in);

            // Write unweighted mean of line buffer pixel and new pixel
            pix_in_wire = pix_in_d1;
            pix_lb_wire = pix_lb;
            pix_interpolated_wire = 0;
            for (unsigned int j = 0; j < DIL_CHANNELS_IN_PAR; j++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                pix_interpolated_wire >>= DIL_BPS;

                // Mean the least significant samples in pix_in and pix_lb,
                // and put into the most significant sample space in pix_interpolated
                pix_interpolated_wire |= ((sc_uint < DIL_BPS + 1 > (sc_uint<DIL_BPS>(pix_in_wire) + sc_uint<DIL_BPS>(pix_lb_wire))) >> 1)
                                         << ((DIL_CHANNELS_IN_PAR - 1) * DIL_BPS);

                pix_in_wire >>= DIL_BPS;
                pix_lb_wire >>= DIL_BPS;
            }
            pix_interpolated = pix_interpolated_wire;
            dout->writeDataAndEop(pix_interpolated, false);
            ++line_counter;
            ++line_counter2;
        }
    }
    #endif //bob_interpolate() method for DEINTERLACING_BOB_SCANLINE_INTERPOLATION only

    // The bob thread code itself
    void bob()
    {
        // Initialise input_field_X with default values, these can be overwritten by control packets (or the kernelizer)
        input_field_width = DIL_MAX_WIDTH;
        input_field_height = DIL_MAX_FIELD_HEIGHT;
        #if (!KERNELIZER_INPUT)
            // input_field_interlace is switched before it is used for the first time so start with opposite first field
            input_field_interlace = (DIL_DEFAULT_INITIAL_FIELD == FIELD_F1_FIRST) ? 0x8 : 0xC;
        #endif

        for (;;)
        {
            // Two handle_non_image_packets functions are written but only one is defined at a time, one works with the kernelizer
            // output (when doing double or triple buffering) and the other one with the Avalon-ST input
            #if (!KERNELIZER_INPUT)
            {
                // The kernelizer would get rid of unwanted field but this has to be done manually when reading from
                // din directly
                bool valid_field;
                do
                {
                    // Switch input_field_interlace in case there is no control packet with the next field,
                    // output from the kernelizer will always update input_field_type and do not use this variable
                    input_field_interlace = (input_field_interlace.bit(INTERLACE_FLAG_BIT),
                                                   !input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                                   input_field_interlace.range(INTERLACE_FIELD_TYPE_BIT-1,0));
                    handle_non_image_packets();
                    #if (!DIL_PROPAGATE_PROGRESSIVE)
                        valid_field = !input_field_prog &&
                                       ((DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH) ||
                                        ((DIL_PRODUCE_FIELDS == DEINTERLACING_F1) == input_field_type));
                    #else
                        valid_field = input_field_prog ||
                                       ((DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH) ||
                                        ((DIL_PRODUCE_FIELDS == DEINTERLACING_F1) == input_field_type));
                    #endif
                    if (!valid_field)
                    {
                        HW_DEBUG_MSG("Discarding unused field" << std::endl);
                        bob_discard_field();
                    }
                }
                while (!valid_field);
            }
            #else
            {
                handle_kernelizer_packets(); // The kernelizer handles the field selection
            }
            #endif

            // Send and extra packet with the expected field_width, field_height and marking the output as progressive
            write_corrected_packet();

            #if (!DIL_PROPAGATE_PROGRESSIVE)
                HW_DEBUG_MSG("\"Packets\" processed, expecting field_width=" << input_field_width
                                                           << ", field_height=" << input_field_height
                                                           << ", field_type=" << input_field_type << std::endl);
            #else
                HW_DEBUG_MSG("\"Packets\" processed, expecting field_width=" << input_field_width
                                                           << ", field_height=" << input_field_height
                                                           << ", field_type=" << (input_field_prog ? "progressive" : "interlaced F")
                                                           << input_field_type << std::endl);
            #endif

            bool empty_field = (input_field_width == sc_uint<HEADER_WORD_BITS*4>(0)) ||
                                    (input_field_height == sc_uint<HEADER_WORD_BITS*4>(0));
            if (empty_field) input_field_height = sc_uint<HEADER_WORD_BITS*4>(0);
            dout->writeDataAndEop(sc_uint<DIL_BPS_PAR>(IMAGE_DATA), empty_field);

            // Now we have a field we can use
            #if (DIL_CHANNELS_IN_SEQ==1)
                samples_in_row = input_field_width;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==2)
                samples_in_row = input_field_width << 1;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==3)
                samples_in_row = sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width << 1) +
                                      sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width);
            #endif

            // Propagate progressive field at this point and make sure that the actual bob algorithm for interlaced
            // fields is not run later on.
            #if (DIL_PROPAGATE_PROGRESSIVE)
            {
                if (input_field_prog)
                {
                    for (height_counter = sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(input_field_height) - sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(1);
                         height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0); --height_counter)
                    {
                        width_counter_cp = samples_in_row;
                        for (width_counter = samples_in_row + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
                        {
                            // Attributes of this loop
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

                            bool last_line BIND(ALT_WIRE);
                            last_line = (height_counter == sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0));
                            --width_counter_cp;
                            vip_assert(width_counter == width_counter_cp);
                            bool last_sample = (width_counter_cp == sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(0));
                            #if (KERNELIZER_INPUT)
                                just_read_in = ker_to_dil.read();
                            #else
                                just_read_in = din->cRead(!din->getEndPacket());
                            #endif
                            dout->writeDataAndEop(just_read_in, last_sample && last_line);
                        }
                    }
                    #if (!KERNELIZER_INPUT)
                        bob_discard_field(); // Discard extra pixels if any
                    #endif
                    empty_field = true; // mark field as empty to help skipping the bob algorithm
                }
            }
            #endif

            // BOB_SCANLINE_DUPLICATION: Scale up F0 or F1 to produce the output frame, quite easy to do and same procedure whatever the field
            #if (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_DUPLICATION)
            {
                // Loop initialisation and termination condition is dependent on the core parameters
                #if (DIL_PROPAGATE_PROGRESSIVE)
                    for (height_counter = (!input_field_prog ? sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(input_field_height) : sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0))
                                                                                                            - sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(1);
                #else
                    for (height_counter = sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(input_field_height) - sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(1);
                #endif
                #if (KERNELIZER_INPUT)
                         height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0); --height_counter)
                #else //check for possible early eop
                         (height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0)) && !din->getEndPacket(); --height_counter)
                #endif
                    {
                        // Read a row, store it and output it simultaneously
                        bob_read_to_store_and_write();
                        #if KERNELIZER_INPUT
                            bob_eop_trigger = (height_counter == sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0));
                        #else
                            bob_eop_trigger = (height_counter == sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0)) || din->getEndPacket();
                        #endif
                        // Output (repeat) the content of the line buffer
                        bob_load_to_write();
                    }
                    #if (!KERNELIZER_INPUT)
                        bob_discard_field(); // Discard extra pixels if any
                    #endif
            }
            #endif
            // Otherwise interpolation
            #if (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_INTERPOLATION)
            {
                // Read the first row of the interlaced field (be it F0 or F1), store it and output it simultaneously
                if (!empty_field)
                {
                    bob_read_to_store_and_write();
                }
                bob_eop_trigger = false;

#if (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH)
                if (input_field_type)
                {
#endif
                    // Producing a frame synchronized with F1
                    #if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F1) || (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH))
                    {
                        // Loop initialisation and termination condition is dependent on the core parameters
                        #if (DIL_PROPAGATE_PROGRESSIVE)
                            for (height_counter = (!input_field_prog ? sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(input_field_height) : sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0))
                                                                                                                + sc_int<2>(-2);
                        #else
                            for (height_counter = input_field_height + sc_int<2>(-2);
                        #endif
                        #if (KERNELIZER_INPUT)
                                 height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0); --height_counter)
                        #else
                                 (height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0)) && !din->getEndPacket(); --height_counter)
                        #endif
                            {
                                // Output the content of the line buffer
                                bob_load_to_write();
                                // Get the next line of the F1 field into the line buffer and produce the even line.
                                // Each even line (n=2,4,6,...) is a blend of n-1 and n+1
                                bob_interpolate();
                            }
                    }
                    #endif
#if (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH)
                }
                else
                {
#endif
                    // Producing a frame synchronized with F0
                    #if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F0) || (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH))
                    {
                        // Loop initialisation and termination condition is dependent on the core parameters
                        #if (DIL_PROPAGATE_PROGRESSIVE)
                            for (height_counter = (!input_field_prog ? sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(input_field_height) : sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0))
                                                                                                                + sc_int<2>(-2);
                        #else
                            for (height_counter = input_field_height + sc_int<2>(-2);
                        #endif
                        #if (KERNELIZER_INPUT)
                                 height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0); --height_counter)
                        #else
                                 (height_counter >= sc_int<DIL_LOG2G_MAX_INPUT_HEIGHT+1>(0)) && !din->getEndPacket(); --height_counter)
                        #endif
                            {
                                // Get the next line of the F0 field and produce the pair n,n+1, Each odd line
                                // (n=1,3,5,...) is a blend of n-1 and n+1
                                bob_interpolate();
                                // Output the content of the line buffer (it contains the original odd line as it was read just before
                                bob_load_to_write();
                            }
                    }
                    #endif
#if (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH)
                }
#endif
                // Output (repeat) the content of the line buffer for the last row, or when eop arrived early
                if (!empty_field)
                {
                    bob_eop_trigger = true;
                    bob_load_to_write();
                }
                #if (!KERNELIZER_INPUT)
                    bob_discard_field(); // Discard extra pixels if any
                #endif
            }
            #endif // SCANLINE_INTERPOLATION
        }
    }
#endif // Bob


    /*****************************************************************************************************************************/
    /*                           Weave deinterlacing thread and associated functions                                   */
    /*****************************************************************************************************************************/
#if (DIL_METHOD == DEINTERLACING_WEAVE)
    void weave()
    {
        sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW> samples_in_row;

        for (;;)
        {
            handle_kernelizer_packets(); // The kernelizer handles the field selection
            // Send and extra packet with the expected field_width, field_height and marking the output as progressive
            write_corrected_packet();

            HW_DEBUG_MSG("Weaving 2 fields: " << input_field_width << 'x' << input_field_height << std::endl);
            bool empty_field = !input_field_width || !input_field_height;
            dout->writeDataAndEop(sc_uint<DIL_BPS_PAR>(IMAGE_DATA), empty_field);

            // Now we have a field we can use
            #if (DIL_CHANNELS_IN_SEQ==1)
                samples_in_row = input_field_width;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==2)
                samples_in_row = input_field_width << 1;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==3)
                samples_in_row = sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width << 1) +
                                              sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width);
            #endif

            for (sc_int<DIL_LOG2G_MAX_FIELD_HEIGHT+2> height_counter = sc_int<DIL_LOG2G_MAX_FIELD_HEIGHT+2>(input_field_height << 1) + sc_int<1>(-1);
                 height_counter >= sc_int<DIL_LOG2G_MAX_FIELD_HEIGHT+2>(0); --height_counter)
            {
                sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1> samples_counter_cp = sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row);
                --samples_counter_cp;
                for (sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1> samples_counter = sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_counter_cp);
                    samples_counter >= sc_int<1>(0); --samples_counter)
                {
                    // Attributes of this loop
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);
                    vip_assert(samples_counter_cp == samples_counter);
                    --samples_counter_cp;
                    just_read_in = ker_to_dil.read();
                    dout->writeDataAndEop(just_read_in, (height_counter == sc_int<1>(0)) &&
                                                            samples_counter_cp.bit(DIL_LOG2G_MAX_SAMPLES_IN_ROW));
                }
            }
        }
    }
#endif //Weave


    /*****************************************************************************************************************************/
    /*                           Motion adaptive deinterlacing thread and associated functions                                   */
    /*****************************************************************************************************************************/
#if (DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE)

    // Thresholds for the algorithm, after the SAD is computed, DIL_MOTION_SATURATION_VALUE is the largest value allowed for the motion value:
    static const unsigned int DIL_NUMBER_CHANNELS = DIL_CHANNELS_IN_SEQ * DIL_CHANNELS_IN_PAR;
    static const unsigned int DIL_BPS_MOTION_SATURATE = DIL_BPS - 2 + ((DIL_NUMBER_CHANNELS > 2) ? 1 : 0);
    // DIL_MOTION_SATURATION_VALUE = ((1 << DIL_BPS_MOTION_SATURATE) - 1);

    // Runtime control for the dil algorithm
    #if DIL_MA_RUNTIME_CTRL
    ALT_REG<1> go_REG ALT_BIND_SEQ_SPACE("avSlaveSequenceSpace0");
    ALT_REG<1> running_REG ALT_BIND_SEQ_SPACE("avSlaveSequenceSpace1");
    sc_uint<1> go BIND(go_REG);
    sc_uint<1> running BIND(running_REG);
    sc_uint<1> manual_blend_in;
    sc_uint<DIL_MA_CTRL_INTERFACE_WIDTH> blend_coef_in;

    sc_event go_changed;

    void MA_control_monitor()
    {
        // Initialise GO to 0
        go = 0;
        // initialise control register to 0
        manual_blend_in = 0;
        blend_coef_in = 0;
        for (;;)
        {
            bool is_read = ma_control->isReadAccess();
            sc_uint<DIL_LOG2_MA_RUNTIME_CTRL_INTERFACE_DEPTH> address = ma_control->getAddress();
            if (is_read)
            {
                // The only address we service for reads is address CTRL_STATUS_ADDRESS so always return running
                ma_control->returnReadData(int(running));
            }
            else
            {
                long this_read = ma_control->getWriteData();
                if (address == sc_uint<DIL_LOG2_MA_RUNTIME_CTRL_INTERFACE_DEPTH>(DIL_MA_CTRL_GO_ADDRESS))
                {
                    go = this_read;
                    notify(go_changed);
                }
                if (address == sc_uint<DIL_LOG2_MA_RUNTIME_CTRL_INTERFACE_DEPTH>(DIL_MA_CTRL_MANUAL_BLEND_ADDRESS))
                {
                    manual_blend_in = this_read;
                }
                if (address == sc_uint<DIL_LOG2_MA_RUNTIME_CTRL_INTERFACE_DEPTH>(DIL_MA_CTRL_BLEND_COEF_ADDRESS))
                {
                    blend_coef_in = this_read;
                }
            }
        }
    }

    // As well as the interface itself, create a bunch of registers to hold the control data in the main thread.
    // Add the main thread "control routine" function here
    bool manual_blend;
    sc_uint<DIL_BPS_MOTION_SATURATE> blend_coef;
    void process_control_data()
    {
        // Write the running bit
        running = 0;
        ma_control->notifyEvent();
        NO_CUSP(wait(0, SC_NS));
        // Check the go bit before starting to read
        while (!go)
        {
            wait(go_changed);
        }

        // Copy data direct from raw slave to registers to use during the next "frame"
        manual_blend = manual_blend_in;
        #if (DIL_MA_CTRL_INTERFACE_WIDTH >= DIL_BPS_MOTION_SATURATE)
            blend_coef = blend_coef_in.range(DIL_MA_CTRL_INTERFACE_WIDTH-1, DIL_MA_CTRL_INTERFACE_WIDTH-DIL_BPS_MOTION_SATURATE);
        #else
            blend_coef = sc_uint<DIL_BPS_MOTION_SATURATE>((sc_uint<DIL_MA_CTRL_INTERFACE_WIDTH>(blend_coef_in), sc_uint<DIL_BPS_MOTION_SATURATE-DIL_MA_CTRL_INTERFACE_WIDTH>(0)));
        #endif
        // Write the running bit
        running = 1;
        ma_control->notifyEvent();
        NO_CUSP(wait(0, SC_NS));
    }
    #endif // end of runtime control for the MA algorithm

    // The MA thread
    void ma()
    {
        sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW> samples_in_row;

        #if (DIL_MOTION_BLEED)
            sc_uint<32> motion_address;
            // Count the number of motion read left for the current frame (counter starts at -1)
            ALT_AU<DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD + 1> MOTION_READ_COUNTER_AU;
            sc_int<DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD + 1> motion_read_counter BIND(MOTION_READ_COUNTER_AU);
            // Count the number of motion write done for the current frame
            sc_uint<DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD> motion_write_counter;
            // Keeping track of the number of memory word written
            ALT_AU<DIL_LOG2G_MAX_MOTION_WORDS_IN_FIELD> MOTION_WORD_COUNTER_AU;
            sc_uint<DIL_LOG2G_MAX_MOTION_WORDS_IN_FIELD> motion_word_counter BIND(MOTION_WORD_COUNTER_AU);
            // Triggers each time the SAMPLES_IN_WORDS elements have gone into a word
            ALT_AU<DIL_TRIGGER_COUNTER_WIDTH> MOTION_WORD_TRIGGER_AU;
            sc_int<DIL_TRIGGER_COUNTER_WIDTH> motion_word_trigger BIND(MOTION_WORD_TRIGGER_AU);

            // Variable used inside the main loop, declared outside because CUSP fails to modulo schedule otherwise
            sc_uint<DIL_BPS> stored_motion;
        #endif

        // Variable used inside the main loop, declared outside because CUSP fails to modulo schedule otherwise
        sc_uint<DIL_BPS_MOTION_SATURATE> bled_away_motion;

        for (;;)
        {
            HW_DEBUG_MSG("Started processing a new frame and its packets" << std::endl);

            handle_kernelizer_packets(); // The kernelizer handles the field selection

            // Between each frame read the run-time parameters and toggle/check the go/status bits
            #if DIL_MA_RUNTIME_CTRL
                process_control_data();
                HW_DEBUG_MSG_COND(manual_blend, "Starting frame with manual blending " << blend_coef << std::endl);
                HW_DEBUG_MSG_COND(!manual_blend, "Starting frame with ma blending " << std::endl);
            #endif

            // Send and extra packet with the expected field_width, field_height and marking the output as progressive
            write_corrected_packet();

            bool empty_field = !input_field_width || !input_field_height;
            dout->writeDataAndEop(sc_uint<DIL_BPS_PAR>(IMAGE_DATA), empty_field);

            // Now we have a field we can use
            #if (DIL_CHANNELS_IN_SEQ==1)
                samples_in_row = input_field_width;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==2)
                samples_in_row = input_field_width << 1;
            #endif
            #if (DIL_CHANNELS_IN_SEQ==3)
                samples_in_row = sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width << 1) +
                                        sc_uint<DIL_LOG2G_MAX_SAMPLES_IN_ROW>(input_field_width);
            #endif

            #if (DIL_MOTION_BLEED)
            {
                motion_address = DIL_MOTION_ADDR;
                // Initialise motion_read_counter to the number of write at previous frame;
                motion_read_counter = break_flow ? sc_uint<DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD>(0) : motion_write_counter;
                HW_DEBUG_MSG_COND(motion_read_counter, "motion_read, posting read burst (" << motion_read_counter << ", "
                                   << motion_word_counter << " words) for the motion field" << std::endl);
                HW_DEBUG_MSG_COND(!motion_read_counter, "motion_read, no motion read for this field" << std::endl);
                motion_read_counter = MOTION_READ_COUNTER_AU.cAddSubSI(motion_read_counter, sc_int<1>(-1),
                                                                       motion_read_counter,
                                                                       !motion_read_counter.bit(DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD),
                                                                       false);
                // We will read motion_read_counter motion values for this frame
                if (!motion_read_counter.bit(DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD))
                {
                    motion_read_master->busPostReadBurstUI(DIL_MOTION_ADDR, motion_word_counter);
                }
                // Reinit motion_write_counter and motion_word_counter to 0
                motion_write_counter = 0;
                motion_word_counter = 0;
                motion_word_trigger = DIL_MOTION_SAMPLES_IN_WORD - 1;
            }
            #endif

            sc_uint<DIL_LOG2G_MAX_FIELD_HEIGHT> j = 0;

            sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1> samples_counter;
            sc_int<DIL_LOG2G_MAX_FIELD_WIDTH+1> width_counter;
            sc_int<DIL_LOG2G_MAX_FIELD_HEIGHT+1> height_counter;

            sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1> samples_counter_cp;

            height_counter = input_field_height; // The following loop is on interlaced field height, not the full progressive height
            // Proper line and column counters for debug
            NO_CUSP(unsigned int x = 0);
            NO_CUSP(unsigned int y = 0);
            for (height_counter = height_counter + sc_int<1>(-1); height_counter >= sc_int<1>(0); --height_counter)
            {
                // Duplicate the line of a F0 field
                #if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F0) || (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH))
                {
                    if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F0) || !input_field_type)
                    {
                          NO_CUSP(x = 0);
                        for (samples_counter = samples_in_row + sc_int<1>(-1); samples_counter >= sc_int<1>(0); --samples_counter)
                        {
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

                            // Pick up all 18 pixels of interest and keep them in one huge register
                            just_read_in = ker_to_dil.read();

                            // Select the appropriate colour sample (or sampleS if transmitted in parallel)
                            // of the middle pixel and construct into an output pixel
                            sc_biguint<DIL_BPS_PAR * 18> kernels_repacking_wire BIND(ALT_WIRE) = just_read_in;
                            sc_uint<DIL_BPS_PAR> output_word BIND(ALT_WIRE) = 0;
                            for (int c = 0; c < DIL_CHANNELS_IN_PAR; c++)
                            {
                                // Shift the middle pixel of the current colour plane into the least significant sample
                                kernels_repacking_wire >>= (4 * DIL_BPS);

                                // Extract that least significant sample and push it into the output word
                                output_word >>= DIL_BPS;
                                output_word |= sc_uint<DIL_BPS_PAR>(kernels_repacking_wire << (DIL_BPS_PAR - DIL_BPS));

                                // Shift away the rest of the current colour plane, so the next loop iteration sees
                                // the next colour plane
                                kernels_repacking_wire >>= (14 * DIL_BPS);
                            }
                            dout->writeDataAndEop(output_word, false);
                            NO_CUSP(if (samples_counter%DIL_CHANNELS_IN_SEQ==DIL_CHANNELS_IN_SEQ) ++x);
                        }
                        NO_CUSP(++y);
                    }
                }
                #endif
                samples_counter_cp = sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row);
                bool last_sample;             // to identify when eop should be sent and avoid staging registers on samples_counter_cp;

                // In the following loop, we are merging SAD and EDI results into accumulators when.
                // DIL_CHANNELS_IN_SEQ == 2 or more. These accumulators have to be declared outside the loop.
            #if (DIL_CHANNELS_IN_SEQ > 1)
                ALT_AU<DIL_SAD_MERGE_WIDTH> SAD_SEQ_MERGE_ACC;
                sc_uint<DIL_SAD_MERGE_WIDTH> sad_seq_merge_acc BIND(SAD_SEQ_MERGE_ACC);
            #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                ALT_AU<DIL_EDI_MERGE_WIDTH> EDI_SEQ_MERGE_ACC_AU[3];
                sc_uint<DIL_EDI_MERGE_WIDTH> edi_seq_merge_acc[3] BIND(EDI_SEQ_MERGE_ACC_AU);
            #endif
            #endif
                    NO_CUSP(x = 0);
                for (width_counter = input_field_width + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, DIL_CHANNELS_IN_SEQ);
                    ALT_ATTRIB(ALT_MIN_ITER, 32);

                    // All variables used inside the following unrolled loop need to be declared as arrays outside the loop to prevent
                    // resource clashes (with the exception of wires).
                    // Registers to store differences
                    ALT_AU<DIL_BPS + 1> DIFFERENCES_AUS[9 * DIL_CHANNELS_IN_PAR];
                    sc_int<DIL_BPS + 1> differences[9 * DIL_CHANNELS_IN_PAR] BIND(DIFFERENCES_AUS);
                    ALT_AU<DIL_BPS> ABSOLUTE_DIFFERENCES_AUS[9 * DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS> absolute_differences[9 * DIL_CHANNELS_IN_PAR] BIND(ABSOLUTE_DIFFERENCES_AUS);
                    ALT_AU<DIL_BPS + 1> SAD_ADDERS_STAGE_ONE_AUS[4 * DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS + 1> sad_adders_stage_one[4 * DIL_CHANNELS_IN_PAR] BIND(SAD_ADDERS_STAGE_ONE_AUS);
                    ALT_AU<DIL_BPS + 2> SAD_ADDERS_STAGE_TWO_AUS[2 * DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS + 2> sad_adders_stage_two[2 * DIL_CHANNELS_IN_PAR] BIND(SAD_ADDERS_STAGE_TWO_AUS);
                    ALT_AU<DIL_BPS + 3> SAD_ADDERS_STAGE_THREE_AUS[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS + 3> sad_adders_stage_three[DIL_CHANNELS_IN_PAR] BIND(SAD_ADDERS_STAGE_THREE_AUS);
                    ALT_AU<DIL_BPS + 4> SAD_AUS[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS + 4> sad[DIL_CHANNELS_IN_PAR] BIND(SAD_AUS);

                    // Merging results for all color samples into sad_norm:
                    // a) merging results for color planes in parallel (just need more addition stages)
                #if (DIL_CHANNELS_IN_PAR > 1)
                    ALT_AU<DIL_SAD_PAR_MERGE_WIDTH> SAD_ADDERS_PAR_MERGE;
                    sc_uint<DIL_SAD_PAR_MERGE_WIDTH> sad_adders_par_merge BIND(SAD_ADDERS_PAR_MERGE);
                #endif
                    // ... one extra stage with three channels in parallel
                #if (DIL_CHANNELS_IN_PAR > 2)
                    ALT_AU<DIL_SAD_PAR_MERGE_WIDTH> SAD_ADDERS_PAR_MERGE_STAGE_TWO;
                    sc_uint<DIL_SAD_PAR_MERGE_WIDTH> sad_adders_par_merge_stage_two BIND(SAD_ADDERS_PAR_MERGE_STAGE_TWO);
                #endif
                    // A wire to the merged SAD result for the current set of channels in parallel
                    sc_uint<DIL_SAD_PAR_MERGE_WIDTH> sad_par_merge BIND(ALT_WIRE);

                    // A temporary wire to link to the SAD result (the accumulator sad_seq_merge_acc
                    // if there are 2 or more channels in sequence or a direct link to sad_par_merge)
                    sc_uint<DIL_SAD_MERGE_WIDTH> sad_merge BIND(ALT_WIRE);

                    // Keeping track of the weave pix
                    ALT_REG<DIL_BPS_PAR> WEAVE_PIX_REGS[DIL_CHANNELS_IN_SEQ];
                    sc_uint<DIL_BPS_PAR> weave_pix[DIL_CHANNELS_IN_SEQ] BIND(WEAVE_PIX_REGS);

                    // Keeping track of the bob interpolation on the vertical direction
                    ALT_REG<DIL_BPS_PAR> BOB_VERTICAL_PIX_REGS[DIL_CHANNELS_IN_SEQ];
                    sc_uint<DIL_BPS_PAR> bob_vertical_pix[DIL_CHANNELS_IN_SEQ] BIND(BOB_VERTICAL_PIX_REGS);
                #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                    // Keeping track of the bob interpolation on the two diagonal directions
                    ALT_REG<DIL_BPS_PAR> BOB_BACKSLASH_PIX_REGS[DIL_CHANNELS_IN_SEQ];
                    sc_uint<DIL_BPS_PAR> bob_backslash_pix[DIL_CHANNELS_IN_SEQ] BIND(BOB_BACKSLASH_PIX_REGS);
                    ALT_REG<DIL_BPS_PAR> bob_fwslash_pix_REGS[DIL_CHANNELS_IN_SEQ];
                    sc_uint<DIL_BPS_PAR> bob_fwslash_pix[DIL_CHANNELS_IN_SEQ] BIND(bob_fwslash_pix_REGS);
                    // Keeping track of the differences to choose the smallest one
                    ALT_AU<DIL_BPS + 1> EDI_DIFFS_AUS[3*DIL_CHANNELS_IN_PAR];  // *3 because there are three directions of interpolation \ or | or /
                    sc_int<DIL_BPS + 1> edi_diffs[3*DIL_CHANNELS_IN_PAR] BIND(EDI_DIFFS_AUS);
                    ALT_AU<DIL_BPS> EDI_ABS_DIFFS_AUS[3*DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS> edi_abs_diffs[3*DIL_CHANNELS_IN_PAR] BIND(EDI_ABS_DIFFS_AUS);

                    // Merging edi results for all color samples diff on the three directions:
                    // a) merging results for color planes in parallel (just need more addition stages)
                #if (DIL_CHANNELS_IN_PAR > 1)
                    ALT_AU<DIL_BPS+1> EDI_ADDERS_PAR_MERGE[3];
                    sc_uint<DIL_BPS+1> edi_adders_par_merge[3] BIND(EDI_ADDERS_PAR_MERGE);
                #endif
                    // one extra stage with 3 channels in parallel
                #if (DIL_CHANNELS_IN_PAR > 2)
                    ALT_AU<DIL_BPS+2> EDI_ADDERS_PAR_MERGE_STAGE_TWO[3];
                    sc_uint<DIL_BPS+2> edi_adders_par_merge_stage_two[3] BIND(EDI_ADDERS_PAR_MERGE_STAGE_TWO);
                #endif
                    // Three wires to the merged EDI results for the current set of channels in parallel
                    sc_uint<DIL_EDI_PAR_MERGE_WIDTH> edi_par_merge[3] BIND(ALT_WIRE);

                    // Three temporary wires to link to the EDI results (the accumulators edi_seq_merge_acc[]
                    // if there are 2 or more channels in sequence or a direct link to edi_par_merge)
                    sc_uint<DIL_EDI_MERGE_WIDTH> edi_merge[3] BIND(ALT_WIRE);
                #endif


                    // Get first DIL_CHANNELS_IN_SEQ inputs from the kernelizer and keep only what is necessary from them
                    // (motion values and, if enabled, edge interpolation
                    for (unsigned int k = 0; k < DIL_CHANNELS_IN_SEQ; ++k)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        // Pick up color samples for seq=k of all 18 pixels of interest and store in one huge register
                        // When channels are transmitted in parallel, the 18 values for a color sample are packed together
                        just_read_in = ker_to_dil.read();
                        // Put the input into a wire for further splitting
                        sc_biguint<DIL_BPS_PAR * 18> ker_all_samples_wire BIND(ALT_WIRE);
                        ker_all_samples_wire = just_read_in;

                        // Compute motion values for this color sample
                        // For handy reference - the 18 pixels of interest are arranged in kernels[] as follows:
                        //     older            newer
                        //  17 | 14 | 11      8 |  5 |  2
                        // ----+----+----   ----+----+----
                        //  16 | 13 | 10      7 |  4 |  1
                        // ----+----+----   ----+----+----
                        //  15 | 12 |  9      6 |  3 |  0


                        // Weave pixel and bob interpolated pixels
                        sc_uint<DIL_BPS_PAR> weave_pix_wire BIND(ALT_WIRE);
                        sc_uint<DIL_BPS_PAR> merge_vertical_wire BIND(ALT_WIRE);
                        #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                            sc_uint<DIL_BPS_PAR> merge_backslash_wire BIND(ALT_WIRE);
                            sc_uint<DIL_BPS_PAR> merge_forwardslash_wire BIND(ALT_WIRE);
                        #endif

                        for (unsigned int c = 0; c < DIL_CHANNELS_IN_PAR; ++c)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            sc_uint<DIL_BPS> ker_sample[18] BIND(ALT_WIRE);
                            for (unsigned int p = 0; p < 18; ++p)
                            {
                                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                ker_sample[p] = sc_uint<DIL_BPS>(ker_all_samples_wire);
                                ker_all_samples_wire >>= DIL_BPS;
                            }

                            // Compute the sum of absolute differences between the first 3x3 kernel and the second
                            for (unsigned int p = 0; p < 9; ++p)
                            {
                                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                differences[c*9 + p] = ker_sample[p] - ker_sample[p + 9];
                                absolute_differences[c*9 + p] = ABSOLUTE_DIFFERENCES_AUS[c*9 + p].addSubSLdSI(0, differences[c*9 + p],
                                                                              differences[c*9 + p],
                                                                              differences[c*9 + p] >= sc_int <DIL_BPS + 1> (0), // sub or sld
                                                                              1);
                            }

                            // Accumulate sum of absolute differences
                            for (unsigned int p = 0; p < 4; ++p)
                            {
                                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                sad_adders_stage_one[c*4 + p] = absolute_differences[c*9 + p] + absolute_differences[c*9 + p + 4];
                            }
                            for (unsigned int p = 0; p < 2; ++p)
                            {
                                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                sad_adders_stage_two[c*2 + p] = sad_adders_stage_one[c*4 + p] + sad_adders_stage_one[c*4 + p + 2];
                            }
                            sad_adders_stage_three[c] = sad_adders_stage_two[c * 2] + sad_adders_stage_two[c * 2 + 1];
                            sad[c] = sad_adders_stage_three[c] + absolute_differences[c*9 + 8];

                            // Building the weave_pix_wire for all c in [0..DIL_CHANNELS_IN_PAR-1]
                            weave_pix_wire <<= DIL_BPS;
                            weave_pix_wire |= ker_sample[4];

                            // Building the merge_vertical_wire for all c in [0..DIL_CHANNELS_IN_PAR-1]
                            merge_vertical_wire <<= DIL_BPS;
                            merge_vertical_wire |= ((j == sc_uint<1>(0)) && input_field_type) ? sc_int <DIL_BPS + 1>(ker_sample[3]) :
                                                   ((j == sc_uint<DIL_LOG2G_MAX_FIELD_HEIGHT>(input_field_height - sc_uint<1>(1))) && !input_field_type) ?
                                                     sc_int <DIL_BPS + 1>(ker_sample[5]) : sc_int<DIL_BPS + 1>((ker_sample[5] + ker_sample[3]) >> 1);

                            // Building the merge_???slash_wire for all c in [0..DIL_CHANNELS_IN_PAR-1]
                            #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                            {
                                 merge_backslash_wire <<= DIL_BPS;
                                 merge_backslash_wire |= ((j == sc_uint<1>(0)) && input_field_type) ? sc_int <DIL_BPS + 1>(ker_sample[3]) :
                                                          ((j == sc_uint<DIL_LOG2G_MAX_FIELD_HEIGHT>(input_field_height - sc_uint<1>(1))) && !input_field_type) ?
                                                           sc_int <DIL_BPS + 1> (ker_sample[5]) : sc_int<DIL_BPS + 1>((ker_sample[8] + ker_sample[0]) >> 1);
                                 merge_forwardslash_wire <<= DIL_BPS;
                                 merge_forwardslash_wire |= ((j == sc_uint<1>(0)) && input_field_type) ? sc_int <DIL_BPS + 1>(ker_sample[3]) :
                                                         ((j == sc_uint<DIL_LOG2G_MAX_FIELD_HEIGHT>(input_field_height - sc_uint<1>(1))) && !input_field_type) ?
                                                                                   sc_int <DIL_BPS + 1>(ker_sample[5]) : sc_int<DIL_BPS + 1>((ker_sample[2] + ker_sample[6]) >> 1);
                            }
                            #endif


                            #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                            {
                                // For each channel in parallel in the current sample, store absolute difference between top and bottom pixel for the 3 directions of interpolations
                                for (int angle = -1; angle <= 1; ++ angle)
                                {
                                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                    edi_diffs[(angle+1)*DIL_CHANNELS_IN_PAR + c] = sc_int<DIL_BPS + 1>(ker_sample[5-(3*angle)]) - sc_int<DIL_BPS + 1>(ker_sample[3+(3*angle)]);
                                    edi_abs_diffs[(angle+1)*DIL_CHANNELS_IN_PAR + c] = EDI_ABS_DIFFS_AUS[(angle+1)*DIL_CHANNELS_IN_PAR + c].addSubSLdSI(0,
                                                                        edi_diffs[(angle+1)*DIL_CHANNELS_IN_PAR + c],
                                                                        edi_diffs[(angle+1)*DIL_CHANNELS_IN_PAR + c],
                                                                        edi_diffs[(angle+1)*DIL_CHANNELS_IN_PAR + c] >= sc_int<DIL_BPS + 1> (0), // sub or sld
                                                                        1);
                                }
                            }
                            #endif
                        }

                        // Registers the wires
                        weave_pix[k] = weave_pix_wire;
                        bob_vertical_pix[k] = merge_vertical_wire;
                        #if DIL_EDGE_DEPENDENT_INTERPOLATION
                            bob_backslash_pix[k] = merge_backslash_wire;
                            bob_fwslash_pix[k] = merge_forwardslash_wire;
                        #endif

                        #if (DIL_CHANNELS_IN_PAR == 1)
                            sad_par_merge = sad[0];
                        #endif
                        #if (DIL_CHANNELS_IN_PAR == 2)
                            sad_adders_par_merge = sad[0] + sad[1];
                            sad_par_merge = sad_adders_par_merge;
                        #endif
                        #if (DIL_CHANNELS_IN_PAR == 3)
                            sad_adders_par_merge = sad[0] + sad[1];
                            sad_adders_par_merge_stage_two  = sad_adders_par_merge + sad[2];
                            sad_par_merge = sad_adders_par_merge_stage_two;
                        #endif

                        // Accumulate sum of directional differences for the EDI
                        #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                        {
                            for (unsigned int angle = 0; angle < 3; ++angle)
                            {
                                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                                #if (DIL_CHANNELS_IN_PAR == 1)
                                    edi_par_merge[angle] = edi_abs_diffs[angle];
                                #endif
                                #if (DIL_CHANNELS_IN_PAR == 2)
                                    edi_adders_par_merge[angle] = edi_abs_diffs[(2*angle)] + edi_abs_diffs[(2*angle)+1];
                                    edi_par_merge[angle] = edi_adders_par_merge[angle];
                                #endif
                                #if (DIL_CHANNELS_IN_PAR == 3)
                                    edi_adders_par_merge[angle] = edi_abs_diffs[(3*angle)] + edi_abs_diffs[(3*angle)+1];
                                    edi_adders_par_merge_stage_two[angle]  = edi_adders_par_merge[angle] + edi_abs_diffs[(3*angle)+2];
                                    edi_par_merge[angle] = edi_adders_par_merge_stage_two[angle];
                                #endif
                                #if (DIL_CHANNELS_IN_SEQ > 1)
                                     edi_seq_merge_acc[angle] = EDI_SEQ_MERGE_ACC_AU[angle].addSubSLdUI(edi_seq_merge_acc[angle], edi_par_merge[angle],
                                                                                                     edi_par_merge[angle], k == 0, 0);
                                #endif
                            }
                        }
                        #endif

                        // Accumulate SAD values
                        #if (DIL_CHANNELS_IN_SEQ > 1)
                            sad_seq_merge_acc = SAD_SEQ_MERGE_ACC.addSubSLdUI(sad_seq_merge_acc, sad_par_merge, sad_par_merge, k == 0, 0);
                        #endif

                    } // End of first loop k = 0; k < CHANNELS_IN_SEQ, to gather the data (SAD and EDI)

                    // Register sad_merge (into current_motion_norm) and edi_merge before going on the second stage of the loop
                    #if (DIL_CHANNELS_IN_SEQ > 1)
                        sc_uint<DIL_SAD_MERGE_WIDTH> sad_seq_merge_reg = sad_seq_merge_acc;
                        sad_merge = sad_seq_merge_reg;
                    #else
                        sad_merge = sad_par_merge;
                    #endif
                    #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                        for (unsigned int angle = 0; angle < 3; ++angle)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            #if (DIL_CHANNELS_IN_SEQ > 1)
                                edi_merge[angle] = edi_seq_merge_acc[angle];
                            #else
                                edi_merge[angle] = edi_par_merge[angle];
                            #endif
                        }
                    #endif

                    // Build up the motion value, convert the sum of absolute differences for all layers into something acceptable
                    // for the sum of the 9 ad values of a single color sample, the motion is linear with the sad and saturates at
                    // DIL_MOTION_SATURATION_VALUE
                    #define DIL_MOTION_SATURATION_VALUE sc_uint<DIL_BPS_MOTION_SATURATE>((1 << DIL_BPS_MOTION_SATURATE) - 1)
                    #if (DIL_MOTION_BLEED)
                    {
                        // The motion value stored in memory is in the range 0..DIL_MOTION_SATURATION_VALUE*4 THEN scaled to 0..2^BPS -1
                        // This avoid the risk to start weaving again too soon
                        const unsigned int DIL_BPS_STORAGE_SATURATE = DIL_BPS_MOTION_SATURATE + 2;
                        #define DIL_STORAGE_SATURATION_VALUE sc_uint<DIL_BPS_STORAGE_SATURATE>((1 << DIL_BPS_STORAGE_SATURATE) - 1)

                        // Read old motion value from external ram buffer (or assume full motion in case there is no motion value available)
                        bool read_motion = !motion_read_counter.bit(DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD);
                        motion_read_counter = MOTION_READ_COUNTER_AU.cAddSubSI(motion_read_counter, sc_int<1>(-1),
                                                                               motion_read_counter,
                                                                               !motion_read_counter.bit(DIL_LOG2G_MAX_MOTION_SAMPLES_IN_FIELD),
                                                                               false);
                        if (read_motion)
                        {
                            stored_motion = motion_read_master->collectPartialReadUI();
                        }

                        // Get the past motion value. Use threshold_motion rather than threshold_motion*4 if there is no old motion value
                        // (such a distinction will not change the current motion but may affect the computed motion for future frames)
                        vip_assert(DIL_BPS <= DIL_BPS_STORAGE_SATURATE);
                        sc_uint<DIL_BPS_STORAGE_SATURATE> saved_motion BIND(ALT_WIRE) = read_motion ?
                                sc_uint<DIL_BPS_STORAGE_SATURATE>(stored_motion << (DIL_BPS_STORAGE_SATURATE-DIL_BPS)) :
                                sc_uint<DIL_BPS_STORAGE_SATURATE>(DIL_MOTION_SATURATION_VALUE);

                        sc_uint<DIL_BPS_STORAGE_SATURATE> current_motion_norm BIND(ALT_WIRE) =
                            (sad_merge > DIL_STORAGE_SATURATION_VALUE) ? DIL_STORAGE_SATURATION_VALUE : sc_uint<DIL_BPS_STORAGE_SATURATE>(sad_merge);

                        // If the motion value has dropped, keep the old value
                        sc_uint<DIL_BPS_STORAGE_SATURATE> max_motion BIND(ALT_WIRE) = (current_motion_norm < saved_motion) ? saved_motion : current_motion_norm;

                        // Now write back a motion value to the motion field in memory (unless this is a progressive frame reconstruction)
                        // Interpolate between the current one and the stored one so that it doesn't drop too fast and only for the next field
                        sc_uint<DIL_BPS_STORAGE_SATURATE+1> averaged_motion BIND(ALT_WIRE) = sc_uint<DIL_BPS_STORAGE_SATURATE+1>(current_motion_norm) +                                                                                             sc_uint<DIL_BPS_STORAGE_SATURATE+1>(saved_motion);
                        sc_uint<DIL_BPS> stored_back_motion = (current_motion_norm < saved_motion) ?
                            averaged_motion.range(DIL_BPS_STORAGE_SATURATE, DIL_BPS_STORAGE_SATURATE-DIL_BPS+1) :
                            current_motion_norm.range(DIL_BPS_STORAGE_SATURATE-1, DIL_BPS_STORAGE_SATURATE-DIL_BPS);
                        if (!input_field_prog)
                        {
                            motion_write_master->writePartialDataUI(stored_back_motion);
                            ++motion_write_counter;
                        }

                        // Count words even if the motion value is not written,
                        // Set motion_word_trigger_flag to true is the last sample of a word was written PREVIOUS iteration
                        bool motion_word_trigger_flag BIND(ALT_WIRE) = motion_word_trigger.bit(DIL_TRIGGER_COUNTER_WIDTH-1);
                        // Increment motion_word_counter by 1 each time the trigger reaches -1
                        motion_word_counter = MOTION_WORD_COUNTER_AU.cAddSubUI(motion_word_counter,
                                                                 sc_uint<1>(1), motion_word_counter,
                                                                 motion_word_trigger_flag,
                                                                 false);
                        // Cycle word_counter_trigger and increase number of words if necessary
                        motion_word_trigger = MOTION_WORD_TRIGGER_AU.addSubSLdSI(
                                               motion_word_trigger, sc_int<1>(-1),  // General case, --motion_word_trigger
                                               DIL_MOTION_SAMPLES_IN_WORD - 2,      // -1 reached previous iteration? reinitialise and count the write
                                               motion_word_trigger_flag,            // sLd line, reinit if motion_word_trigger == -1 (unless enable is false)
                                               false);                              // Always add -1

                        // Post a new burst when writing the first sample of the last word of a burst
                        vip_assert(sc_uint<LOG2(DIL_MOTION_WRITE_BURST_TARGET)>(DIL_MOTION_WRITE_BURST_TARGET) == sc_uint<1>(0));
                        bool burst_trigger = (sc_uint<LOG2(DIL_MOTION_WRITE_BURST_TARGET)>(motion_word_counter) ==
                                               sc_uint<LOG2(DIL_MOTION_WRITE_BURST_TARGET)>(DIL_MOTION_WRITE_BURST_TARGET-1)) &&
                                               motion_word_trigger_flag && !input_field_prog;

                        // New burst ?
                        if (burst_trigger)
                        {
                            HW_DEBUG_MSG("motion_write, posting motion burst " << DIL_MOTION_WRITE_BURST_TARGET << " at addr " << motion_address << std::endl);
                            motion_write_master->busPostWriteBurst(motion_address, DIL_MOTION_WRITE_BURST_TARGET);
                            motion_address += (DIL_MOTION_WRITE_BURST_TARGET << DIL_LOG2_WORD_BYTES);
                        }

                        // Saturate bled_away_motion
                        bled_away_motion = (max_motion > DIL_MOTION_SATURATION_VALUE) ? DIL_MOTION_SATURATION_VALUE : sc_uint<DIL_BPS_MOTION_SATURATE>(max_motion);
                    }
                    #else
                    {
                        // Saturate bled_away_motion
                        bled_away_motion = (sad_merge > DIL_MOTION_SATURATION_VALUE) ? DIL_MOTION_SATURATION_VALUE : sc_uint<DIL_BPS_MOTION_SATURATE>(sad_merge);
                    }
                    #endif

                    sc_uint<DIL_BPS_MOTION_SATURATE> controlled_motion BIND(ALT_WIRE);
                    sc_uint<DIL_BPS_MOTION_SATURATE> final_motion BIND(ALT_WIRE);
                    // Check whether the MA runtime controller overide the motion value
                    #if DIL_MA_RUNTIME_CTRL
                        controlled_motion = manual_blend ? blend_coef : bled_away_motion;
                    #else
                        controlled_motion = bled_away_motion;
                    #endif

                    // Set motion value to 0 if a progressive frame is received
                    final_motion = input_field_prog ? sc_uint<DIL_BPS_MOTION_SATURATE>(0) : controlled_motion;

                    // Determine angle of interpolation for the EDI
                #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                    bool edi_fw_bw_wire BIND(ALT_WIRE) = sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_merge[2]) < sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_merge[0]);
                    sc_uint<DIL_EDI_MERGE_WIDTH> edi_diag_merge BIND(ALT_WIRE) = edi_fw_bw_wire ? edi_merge[2] : edi_merge[0];

                    bool edi_fw_bw = edi_fw_bw_wire;

                    bool edi_vert_only = sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_diag_merge) > sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_merge[1]);
                    bool edi_vert_mainly = sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_diag_merge) > sc_uint<DIL_EDI_MERGE_WIDTH+1>(edi_merge[1]>>1);
                    bool edi_diag_only = sc_uint<DIL_EDI_MERGE_WIDTH>(edi_diag_merge) < sc_uint<DIL_EDI_MERGE_WIDTH>(edi_merge[1]>>3);
                    bool edi_diag_mainly = sc_uint<DIL_EDI_MERGE_WIDTH>(edi_diag_merge) < sc_uint<DIL_EDI_MERGE_WIDTH>(edi_merge[1]>>2);

                    ALT_AU<DIL_BPS+1> BOB_INTERPOLATED_STAGE_1_A_AU[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS+1> bob_interpolated_stage_1_a[DIL_CHANNELS_IN_PAR] BIND(BOB_INTERPOLATED_STAGE_1_A_AU);
                    ALT_AU<DIL_BPS+1> BOB_INTERPOLATED_STAGE_1_B_AU[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS+1> bob_interpolated_stage_1_b[DIL_CHANNELS_IN_PAR] BIND(BOB_INTERPOLATED_STAGE_1_B_AU);

                    ALT_AU<DIL_BPS+2> BOB_INTERPOLATED_STAGE_2_SUM_AU[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS+2> bob_interpolated_stage_2_sum[DIL_CHANNELS_IN_PAR] BIND(BOB_INTERPOLATED_STAGE_2_SUM_AU);
                    ALT_AU<DIL_BPS+2> BOB_INTERPOLATED_STAGE_2_CHOICE_AU[DIL_CHANNELS_IN_PAR];
                    sc_uint<DIL_BPS+2> bob_interpolated_stage_2_choice[DIL_CHANNELS_IN_PAR] BIND(BOB_INTERPOLATED_STAGE_2_CHOICE_AU);

                #endif

                    sc_uint<DIL_BPS> bob_interpolated[DIL_CHANNELS_IN_PAR] BIND(ALT_WIRE);

                    ALT_AU<DIL_BPS + 1> BOB_MINUS_WEAVE_REGS[DIL_CHANNELS_IN_PAR];
                    sc_int<DIL_BPS + 1> bob_minus_weave[DIL_CHANNELS_IN_PAR] BIND(BOB_MINUS_WEAVE_REGS);
                    vip_assert(DIL_BPS_MOTION_SATURATE <= DIL_BPS);
                    ALT_MULT<DIL_BPS + 1> TIMES_MOTION_MULTS[DIL_CHANNELS_IN_PAR];
                    sc_int<DIL_BPS + DIL_BPS_MOTION_SATURATE + 1> times_motion[DIL_CHANNELS_IN_PAR] BIND(TIMES_MOTION_MULTS);
                    ALT_REG<DIL_BPS + 1> RENORM_REGS[DIL_CHANNELS_IN_PAR];
                    sc_int<DIL_BPS + 1> renorm[DIL_CHANNELS_IN_PAR] BIND(RENORM_REGS);

                    for (unsigned int k = 0; k < DIL_CHANNELS_IN_SEQ; ++k)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

                        sc_uint<DIL_BPS_PAR> bob_vertical_pix_wire BIND(ALT_WIRE) = bob_vertical_pix[k];
                        sc_uint<DIL_BPS_PAR> weave_pix_wire BIND(ALT_WIRE) = weave_pix[k];

                    #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                        sc_uint<DIL_BPS_PAR> bob_diag_pix_wire BIND(ALT_WIRE) = edi_fw_bw ? bob_fwslash_pix[k] : bob_backslash_pix[k];
                    #endif

                        sc_uint<DIL_BPS_PAR> result_wire BIND(ALT_WIRE);
                        for (unsigned int c = 0; c < DIL_CHANNELS_IN_PAR; ++c)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            sc_uint<DIL_BPS> bob_vert BIND(ALT_WIRE) = sc_uint<DIL_BPS>(bob_vertical_pix_wire);
                            bob_vertical_pix_wire >>= DIL_BPS;
                            sc_uint<DIL_BPS> weave BIND(ALT_WIRE) = sc_uint<DIL_BPS>(weave_pix_wire);
                            weave_pix_wire >>= DIL_BPS;
                            #if (DIL_EDGE_DEPENDENT_INTERPOLATION)
                                // Color channel "DIL_CHANNELS_IN_PAR - c" is on the least significant bits of the wires.
                                #if (DIL_MA_422 && (DIL_CHANNELS_IN_SEQ==2))
                                    // No diagonal interpolation for chroma sample in 422 mode.
                                    sc_uint<DIL_BPS> bob_diag BIND(ALT_WIRE) = (k==0) ? bob_vert : sc_uint<DIL_BPS>(bob_diag_pix_wire);
                                #elif (DIL_MA_422 && (DIL_CHANNELS_IN_PAR==2))
                                    // No diagonal interpolation for chroma sample in 422 mode.
                                    sc_uint<DIL_BPS> bob_diag BIND(ALT_WIRE) = (c==1) ? bob_vert : sc_uint<DIL_BPS>(bob_diag_pix_wire);
                                #else
                                    // Color channel "c" is on the least significant bits of the wires.
                                    sc_uint<DIL_BPS> bob_diag BIND(ALT_WIRE) = sc_uint<DIL_BPS>(bob_diag_pix_wire);
                                #endif
                                // Shift for the next iteration
                                bob_diag_pix_wire >>= DIL_BPS;

                                bob_interpolated_stage_1_a[c] = BOB_INTERPOLATED_STAGE_1_A_AU[c].addSubSLdUI(bob_diag, bob_vert, bob_diag<<1, edi_diag_mainly, 0);
                                bob_interpolated_stage_1_b[c] = BOB_INTERPOLATED_STAGE_1_B_AU[c].addSubSLdUI(bob_diag, bob_vert, bob_vert<<1, edi_vert_mainly, 0);

                                bob_interpolated_stage_2_sum[c] = BOB_INTERPOLATED_STAGE_2_SUM_AU[c].addSubUI(bob_interpolated_stage_1_a[c],
                                                                                                              bob_interpolated_stage_1_b[c],
                                                                                                              0);
                                bob_interpolated_stage_2_choice[c] = BOB_INTERPOLATED_STAGE_2_CHOICE_AU[c].muxLdUI(bob_interpolated_stage_1_a[c], bob_interpolated_stage_1_b[c], edi_vert_mainly);

                                bob_interpolated[c] = (edi_vert_only || edi_diag_only) ? sc_uint<DIL_BPS>(bob_interpolated_stage_2_choice[c] >> 1) :
                                                                                         sc_uint<DIL_BPS>(bob_interpolated_stage_2_sum[c] >> 2);
                            #else
                                bob_interpolated[c] = bob_vert;
                            #endif

                            // Merge bob and weave using motion
                            bob_minus_weave[c] = bob_interpolated[c] - weave;
                            times_motion[c] = bob_minus_weave[c] * sc_int<DIL_BPS_MOTION_SATURATE + 1>(final_motion);
                            renorm[c] = times_motion[c] >> DIL_BPS_MOTION_SATURATE;

                            /*
                            std::cout << "HW - motion value = " << final_motion << ",  ";
                            std::cout << "weave = " << weave << ",  ";
                            std::cout << "bob = " << bob_interpolated[c] << ",  " << bob_vert << " " << bob_diag << " " << edi_merge[0] << " " << edi_merge[1] << " " << edi_merge[2] << ",  ";
                            std::cout << "bob_interpolated_stage_1_a[c]=" << bob_interpolated_stage_1_a[c] << std::endl;
                            std::cout << "bob_interpolated_stage_1_b[c]=" << bob_interpolated_stage_1_b[c] << std::endl;
                            std::cout << "bob_interpolated_stage_2_sum[c]=" << bob_interpolated_stage_2_sum[c] << std::endl;
                            std::cout << "bob_interpolated_stage_2_choice[c]=" << bob_interpolated_stage_2_choice[c] << std::endl;
                            std::cout << "res = " << sc_uint<DIL_BPS>(weave + renorm[c]) << std::endl;
                            */
                            // Shift to free space for the next sample at the position of the first channel
                            result_wire <<= DIL_BPS;
                            result_wire |= ((final_motion == DIL_MOTION_SATURATION_VALUE) ?
                                                 sc_uint<DIL_BPS>(bob_interpolated[c]) :
                                                 sc_uint<DIL_BPS>(weave + renorm[c]));
                        }
                        --samples_counter_cp;
                        last_sample = (samples_counter_cp == sc_int<1>(0)) && (height_counter == sc_int<1>(0));

                        // Collect parallel results together and actually write to the output
                        sc_uint<DIL_BPS_PAR> result_reg = result_wire;
                        dout->writeDataAndEop(result_reg, !input_field_type && last_sample);
                    }
                    NO_CUSP(++x);
                }
                NO_CUSP(++y);

                // Duplicate the line of a F1 field
                #if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F1) || (DIL_PRODUCE_FIELDS == DEINTERLACING_BOTH))
                {
                    if ((DIL_PRODUCE_FIELDS == DEINTERLACING_F1) || input_field_type)
                    {
                        samples_counter_cp = sc_int<DIL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row); //reinitialise our copy of the couter to know when eop should be sent
                        for (samples_counter = samples_in_row + sc_int<1>(-1); samples_counter >= sc_int<1>(0); --samples_counter)
                        {
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            ALT_ATTRIB(ALT_MIN_ITER, 32*DIL_CHANNELS_IN_SEQ);

                            --samples_counter_cp;
                            vip_assert(samples_counter == samples_counter_cp);
                            last_sample = (samples_counter_cp == sc_int<1>(0)) && (height_counter == sc_int<1>(0));

                            // Pick up all 18 pixels of interest and put in one huge register
                            just_read_in = ker_to_dil.read();

                            // Select the appropriate colour sample (or sampleS if transmitted in parallel)
                            // of the middle pixel and construct into an output pixel
                            sc_biguint<DIL_BPS_PAR * 18> kernels_repacking_wire BIND(ALT_WIRE) = just_read_in;
                            sc_uint<DIL_BPS_PAR> output_word BIND(ALT_WIRE) = 0;
                            for (int c = 0; c < DIL_CHANNELS_IN_PAR; c++)
                            {
                                // Shift the middle pixel of the current colour plane into the least significant sample
                                kernels_repacking_wire >>= (4 * DIL_BPS);

                                // Extract that least significant sample and push it into the output word
                                output_word >>= DIL_BPS;
                                output_word |= sc_uint<DIL_BPS_PAR>(kernels_repacking_wire << (DIL_BPS_PAR - DIL_BPS));

                                // Shift away the rest of the current colour plane, so the next loop iteration sees the
                                // next colour plane
                                kernels_repacking_wire >>= (14 * DIL_BPS);
                            }
                            dout->writeDataAndEop(output_word, last_sample);
                            NO_CUSP(if (samples_counter%DIL_CHANNELS_IN_SEQ==DIL_CHANNELS_IN_SEQ) ++x);
                        }
                        NO_CUSP(++y);
                    }
                }
                #endif
                ++j;
            }

            // Tidying up motion bleed
            #if (DIL_MOTION_BLEED)
            {
                motion_write_master->flush();
                motion_read_master->discard();
                if (!empty_field)
                {
                    ++motion_word_counter;
                }
                // Post the last burst for remaining data
                if (sc_uint<LOG2(DIL_MOTION_WRITE_BURST_TARGET)>(motion_word_counter) && !input_field_prog)
                {
                    HW_DEBUG_MSG("motion_write, posting last burst " << sc_uint<LOG2(DIL_WDATA_BURST_TARGET)>(motion_word_counter) << " at addr " << motion_address << std::endl);
                    motion_write_master->busPostWriteBurst(motion_address, sc_uint<LOG2(DIL_WDATA_BURST_TARGET)>(motion_word_counter));
                }
            }
            #endif

            HW_DEBUG_MSG("Finished processing a frame" << std::endl);
        }
    }
#endif // Motion adaptive thread and related functions

#endif // SYNTH_MODE

    SC_HAS_PROCESS(DIL_NAME);
    const char* param;
    DIL_NAME(sc_module_name name_, int motion_masters_required = 0, int read_masters_required = 0, int write_masters_required = 0, const char* PARAMETERISATION = "<deinterlacerParams><DIL_NAME>my_deinterlacing_core</DIL_NAME><DIL_MAX_WIDTH>640</DIL_MAX_WIDTH><DIL_MAX_HEIGHT>480</DIL_MAX_HEIGHT><DIL_CHANNELS_IN_SEQ>3</DIL_CHANNELS_IN_SEQ><DIL_CHANNELS_IN_PAR>1</DIL_CHANNELS_IN_PAR><DIL_BPS>8</DIL_BPS><DIL_METHOD>DEINTERLACING_BOB_SCANLINE_DUPLICATION</DIL_METHOD><DIL_FRAMEBUFFERS_ADDR>00</DIL_FRAMEBUFFERS_ADDR><DIL_PRODUCE_FIELDS>DEINTERLACING_F0</DIL_PRODUCE_FIELDS><DIL_BUFFER_AS_THOUGH>DEINTERLACING_NO_BUFFERING</DIL_BUFFER_AS_THOUGH><DIL_DEFAULT_INITIAL_FIELD>FIELD_F0_FIRST</DIL_DEFAULT_INITIAL_FIELD><DIL_MASTER_PORT_WIDTH>64</DIL_MASTER_PORT_WIDTH><DIL_MEM_MASTERS_USE_SEPARATE_CLOCK>0</DIL_MEM_MASTERS_USE_SEPARATE_CLOCK><DIL_EDGE_DEPENDENT_INTERPOLATION>1</DIL_EDGE_DEPENDENT_INTERPOLATION><DIL_MOTION_BLEED>0</DIL_MOTION_BLEED><DIL_RDATA_FIFO_DEPTH>64</DIL_RDATA_FIFO_DEPTH><DIL_RDATA_BURST_TARGET>32</DIL_RDATA_BURST_TARGET><DIL_WDATA_FIFO_DEPTH>64</DIL_WDATA_FIFO_DEPTH><DIL_WDATA_BURST_TARGET>32</DIL_WDATA_BURST_TARGET><DIL_MAX_NUMBER_PACKETS>1</DIL_MAX_NUMBER_PACKETS><DIL_MAX_SYMBOLS_IN_PACKET>10</DIL_MAX_SYMBOLS_IN_PACKET><DIL_MA_RUNTIME_CTRL>0</DIL_MA_RUNTIME_CTRL><DIL_PROPAGATE_PROGRESSIVE>0</DIL_PROPAGATE_PROGRESSIVE><DIL_CONTROLLED_DROP_REPEAT>0</DIL_CONTROLLED_DROP_REPEAT><DIL_MA_422>0</DIL_MA_422><DIL_BURST_ALIGNMENT>0</DIL_BURST_ALIGNMENT></deinterlacerParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        din = new ALT_AVALON_ST_INPUT< sc_uint<DIL_BPS_PAR> >();
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint<DIL_BPS_PAR> >();

// if not test flow, i.e constructor defined
#ifndef LEGACY_FLOW
        // Set up input and output
        int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_BPS", 8);
        int channels_in_par = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_CHANNELS_IN_PAR", 3);
        int dil_master_port_width = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_MASTER_PORT_WIDTH", 64);
        int ker_master_port_width;
        if(dil_master_port_width!=0)
        {
            ker_master_port_width = dil_master_port_width;
        }
        else
        {
            ker_master_port_width = 64;
        }
        bool mastersUseSeparateClock = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_MEM_MASTERS_USE_SEPARATE_CLOCK", 0);

        int rdata_burst_target = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_RDATA_BURST_TARGET", 32);
        int wdata_burst_target = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_WDATA_BURST_TARGET", 32);

        din->setSymbolsPerBeat(channels_in_par);
        din->setDataWidth(bps*channels_in_par);
        dout->setSymbolsPerBeat(channels_in_par);
        dout->setDataWidth(bps*channels_in_par);
        din->enableEopSignals();
        dout->enableEopSignals();

        //set up ports in the case of buffering required
        if(read_masters_required!=0)
        {
            read_master = new ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_READ_MASTERS_MAX_BURST, KER_BPS_PAR>[read_masters_required];
            for (int i = 0; i < read_masters_required; i++)
            {
                read_master[i].setDataWidth(ker_master_port_width);
                read_master[i].setUseOwnClock(mastersUseSeparateClock);
                read_master[i].setRdataBurstSize(rdata_burst_target);
                read_master[i].setWdataBurstSize(0);
                read_master[i].enableReadPorts();
            }

            if (write_masters_required!=0)
            {
                write_master = new ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_WRITE_MASTER_MAX_BURST, KER_BPS_PAR>();
                write_master->setDataWidth(ker_master_port_width);
                write_master->setUseOwnClock(mastersUseSeparateClock);
                write_master->setWdataBurstSize(wdata_burst_target);
                write_master->setRdataBurstSize(0);
                write_master->enableWritePorts();
            }
        }
        else
        {
            read_master = NULL;
            write_master = NULL;
        }

        //setup ports for motion adaptive mode with motion bleed
        if(motion_masters_required!=0)
        {
            motion_write_master = new ALT_AVALON_MM_MASTER_FIFO<DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_WRITE_MASTER_MAX_BURST, DIL_BPS>();
            motion_read_master = new ALT_AVALON_MM_MASTER_FIFO<DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_READ_MASTER_MAX_BURST, DIL_BPS>();

            motion_read_master->setDataWidth(dil_master_port_width);
            motion_read_master->setUseOwnClock(mastersUseSeparateClock);
            motion_read_master->setRdataBurstSize(rdata_burst_target);
            motion_read_master->setWdataBurstSize(0);
            motion_read_master->enableReadPorts();

            motion_write_master->setDataWidth(dil_master_port_width);
            motion_write_master->setUseOwnClock(mastersUseSeparateClock);
            motion_write_master->setWdataBurstSize(wdata_burst_target);
            motion_write_master->setRdataBurstSize(0);
            motion_write_master->enableWritePorts();
        }
        else
        {
            motion_read_master = NULL;
            motion_write_master = NULL;
        }

        bool use_ker_writer_control = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_CONTROLLED_DROP_REPEAT", 0);
        if(use_ker_writer_control){
            ker_writer_control = new ALT_AVALON_MM_RAW_SLAVE<KER_WRITER_CTRL_INTERFACE_WIDTH, KER_WRITER_CTRL_INTERFACE_DEPTH>();
            ker_writer_control->setUseOwnClock(false);
            ker_writer_control->enableWritePorts();
            ker_writer_control->enableReadPorts();
            ker_writer_control->setDataWidth(KER_WRITER_CTRL_INTERFACE_WIDTH);
            ker_writer_control->setDepth(KER_WRITER_CTRL_INTERFACE_DEPTH);
        }
        else
        {
            ker_writer_control = NULL;
        }

        bool use_MA_control = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "deinterlacerParams;DIL_MA_RUNTIME_CTRL", 0);
        if(use_MA_control){
            ma_control = new ALT_AVALON_MM_RAW_SLAVE<DIL_MA_CTRL_INTERFACE_WIDTH, DIL_MA_CTRL_INTERFACE_DEPTH>();
            ma_control->setUseOwnClock(false);
            ma_control->enableWritePorts();
            ma_control->enableReadPorts();
            ma_control->setDataWidth(DIL_MA_CTRL_INTERFACE_WIDTH);
            ma_control->setDepth(DIL_MA_CTRL_INTERFACE_DEPTH);
        }
        else
        {
            ma_control = NULL;
        }
#else
        // Set up the read and write master(s) of the kernelizer.
        // Ideally, this code would be in a function provided by the kerneliser
        // (or would be the constructor of the kerneliser if it were in a submodule)
        #if (KERNELIZER_INPUT)
            read_master = new ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_READ_MASTERS_MAX_BURST, KER_BPS_PAR>[KER_NUM_READ_MASTERS];
            for (int i = 0; i < KER_NUM_READ_MASTERS; i++)
            {
                read_master[i].setUseOwnClock(DIL_MEM_MASTERS_USE_SEPARATE_CLOCK);
                read_master[i].setRdataBurstSize(DIL_RDATA_BURST_TARGET);
                read_master[i].setWdataBurstSize(0);
            }
            #if (KER_WRITE_MASTER_NEEDED)
            {
                write_master = new ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_WRITE_MASTER_MAX_BURST, KER_BPS_PAR>();
                write_master->setUseOwnClock(DIL_MEM_MASTERS_USE_SEPARATE_CLOCK);
                write_master->setWdataBurstSize(DIL_WDATA_BURST_TARGET);
                write_master->setRdataBurstSize(0);
            }
            #endif
            #if (KER_WRITER_RUNTIME_CTRL)
                ker_writer_control = new ALT_AVALON_MM_RAW_SLAVE<KER_WRITER_CTRL_INTERFACE_WIDTH, KER_WRITER_CTRL_INTERFACE_DEPTH>();
                ker_writer_control->setUseOwnClock(false);
            #else
                ker_writer_control = NULL;
            #endif
        #endif

        // Set up the ma ports when a motion adaptive deinterlacer is used
        #if ((DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE) && (DIL_MOTION_BLEED))
            // Set up the masters that access the motion buffers
            motion_write_master = new ALT_AVALON_MM_MASTER_FIFO<DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_WRITE_MASTER_MAX_BURST, DIL_BPS>();
            motion_write_master->setUseOwnClock(DIL_MEM_MASTERS_USE_SEPARATE_CLOCK);
            motion_write_master->setWdataBurstSize(DIL_WDATA_BURST_TARGET);
            motion_write_master->setRdataBurstSize(0);
            motion_read_master = new ALT_AVALON_MM_MASTER_FIFO<DIL_MASTER_PORT_WIDTH, 32, DIL_MOTION_READ_MASTER_MAX_BURST, DIL_BPS>();
            motion_read_master->setUseOwnClock(DIL_MEM_MASTERS_USE_SEPARATE_CLOCK);
            motion_read_master->setRdataBurstSize(DIL_RDATA_BURST_TARGET);
            motion_read_master->setWdataBurstSize(0);
        #else
            motion_write_master = NULL;
            motion_read_master = NULL;
        #endif
        #if ((DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE) && (DIL_MA_RUNTIME_CTRL))
            ma_control = new ALT_AVALON_MM_RAW_SLAVE<DIL_MA_CTRL_INTERFACE_WIDTH, DIL_MA_CTRL_INTERFACE_DEPTH>();
            ma_control->setUseOwnClock(false);
        #else
            ma_control = NULL;
        #endif
#endif //LEGACY_FLOW

#ifdef SYNTH_MODE
    #if (KERNELIZER_INPUT)
        #if (KER_WRITER_RUNTIME_CTRL)
            SC_THREAD(ker_writer_control_monitor);
        #endif
        #if (KER_WRITE_MASTER_NEEDED)
            write_master->setWdataFifoDepth(DIL_WDATA_FIFO_DEPTH);
            write_master->setCmdFifoDepth(1);
        #endif
        for (int i = 0; i < KER_NUM_READ_MASTERS; i++)
        {
            read_master[i].setRdataFifoDepth(DIL_RDATA_FIFO_DEPTH);
            read_master[i].setCmdFifoDepth(2);
        }
        #if ((DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE) && (DIL_MOTION_BLEED))
            motion_write_master->setWdataFifoDepth(DIL_MOTION_WRITE_FIFO_DEPTH);
            motion_write_master->setCmdFifoDepth(DIL_MOTION_WRITE_CMD_FIFO_DEPTH);
            motion_read_master->setRdataFifoDepth(DIL_MOTION_READ_FIFO_DEPTH);
            motion_read_master->setCmdFifoDepth(DIL_MOTION_READ_CMD_FIFO_DEPTH);
        #endif
    #endif

    // Set up the bob thread when a bob deinterlacer is used
    #if ((DIL_METHOD == DEINTERLACING_BOB_SCANLINE_DUPLICATION) || (DIL_METHOD == DEINTERLACING_BOB_SCANLINE_INTERPOLATION))
        SC_THREAD(bob);
    #endif

    #if (DIL_METHOD == DEINTERLACING_WEAVE)
        SC_THREAD(weave);
    #endif

    #if (DIL_METHOD == DEINTERLACING_MOTION_ADAPTIVE)
        SC_THREAD(ma);
        #if (DIL_MA_RUNTIME_CTRL)
            SC_THREAD(MA_control_monitor)
        #endif
    #endif

    #if (KERNELIZER_INPUT)
        SC_THREAD(ker_writer);
        SC_THREAD(ker_reader);
    #endif
#endif //SYNTH_MODE
    }
};
