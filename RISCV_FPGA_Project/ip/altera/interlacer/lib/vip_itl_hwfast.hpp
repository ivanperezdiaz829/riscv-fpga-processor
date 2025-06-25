// Interlacer Hardware Model
//
// Author: vshankar

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
    #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
    #undef ITL_NAME
    #define ITL_NAME alt_vip_itl
#endif

SC_MODULE(ITL_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/interlacer.jar?com.altera.vip.entityinterfaces.helpers.ITLEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Interlacer";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Interlacer converts progressive video to interlaced video.";
    }

    static const char * get_product_ids(void)
    {
        return "00DC";
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
    #define ITL_BPS 20
    #define ITL_CHANNELS_IN_PAR 3
    #define ITL_MEM_PORT_WIDTH 256
    #define ITL_READ_MASTER_MAX_BURST 16
    #define ITL_WRITE_MASTER_MAX_BURST 16
    #define ITL_WDATA_FIFO_DEPTH 64
    #define ITL_RDATA_FIFO_DEPTH 64
#else
    // Parameters for the Avalon-MM interfaces (dummy values are used if there is no buffering)
    #if ITL_NO_BUFFERING
        static const unsigned int ITL_MEM_PORT_WIDTH = 64;
        static const unsigned int ITL_WRITE_MASTER_MAX_BURST = 32;
        static const unsigned int ITL_READ_MASTER_MAX_BURST = 32;
    #else
        // Set up the max burst to be in agreement with both the XDATA_BURST_TARGETs parameters and the actual burst that are posted by the core
        // If ITL_?DATA_BURST_TARGET is bigger than the parameter it is compared too then the hardware is probably not very efficient
        static const unsigned int ITL_MAX_WORDS_BURST = (ITL_MAX_WORDS_IN_ROW > ITL_MAX_WORDS_IN_PACKET) ?
                                    ITL_MAX_WORDS_IN_ROW : ITL_MAX_WORDS_IN_PACKET;
        static const unsigned int ITL_WRITE_MASTER_MAX_BURST = (ITL_MAX_WORDS_BURST > ITL_WDATA_BURST_TARGET) ?
                                    ITL_MAX_WORDS_BURST : ITL_WDATA_BURST_TARGET;
        static const unsigned int ITL_READ_MASTER_MAX_BURST = (ITL_MAX_WORDS_BURST > ITL_RDATA_BURST_TARGET) ?
                                    ITL_MAX_WORDS_BURST : ITL_RDATA_BURST_TARGET;

        // Reserve enough space in the command FIFO so that we can issue enough write command to fill the FIFO, + 1 to avoid lock during pipelining
        static const unsigned int ITL_WDATA_CMD_FIFO_DEPTH = (ITL_WDATA_FIFO_DEPTH / ITL_WDATA_BURST_TARGET) + 1;
     #endif
#endif

    static const unsigned int ITL_MEM_ADDR_WIDTH = 32; // Size of the address port

    static const unsigned int ITL_BPS_PAR = ITL_BPS * ITL_CHANNELS_IN_PAR;

    // Static parameters for the optional runtime controllers
    static const unsigned int ITL_CTRL_INTERFACE_WIDTH = 8;
    static const unsigned int ITL_CTRL_INTERFACE_DEPTH = 3;

    ALT_AVALON_ST_INPUT< sc_uint<ITL_BPS_PAR> > *din;
    ALT_AVALON_ST_OUTPUT< sc_uint<ITL_BPS_PAR> > *dout;

    ALT_AVALON_MM_MASTER_FIFO<ITL_MEM_PORT_WIDTH, ITL_MEM_ADDR_WIDTH, ITL_WRITE_MASTER_MAX_BURST, ITL_BPS_PAR> *write_master ALT_BIND_SEQ_PER_RESOURCE;
    ALT_AVALON_MM_MASTER_FIFO<ITL_MEM_PORT_WIDTH, ITL_MEM_ADDR_WIDTH, ITL_READ_MASTER_MAX_BURST, ITL_BPS_PAR> *read_master ALT_BIND_SEQ_PER_RESOURCE;

    ALT_AVALON_MM_RAW_SLAVE<ITL_CTRL_INTERFACE_WIDTH, ITL_CTRL_INTERFACE_DEPTH> *itl_control;

    static const unsigned int INTERLACE_FLAG_BIT = HEADER_WORD_BITS-1;
    static const unsigned int INTERLACE_FIELD_TYPE_BIT = HEADER_WORD_BITS-2;
    static const unsigned int INTERLACE_SYNC_UNKNOWN_BIT = HEADER_WORD_BITS-3;
    static const unsigned int INTERLACE_SYNC_FIELD_BIT = HEADER_WORD_BITS-4;
    // The interlace nibble of the first interlaced field when doing the interlacing
    static const unsigned int INTERLACED_F0_SYNC_F1_NIBBLE = 0x9;
    static const unsigned int INTERLACED_F1_SYNC_F0_NIBBLE = 0xC;

#ifdef SYNTH_MODE

    static const unsigned int INITIAL_INTERLACE_NIBBLE = (ITL_FIRST_FIELD == FIELD_F0_FIRST) ?
                        INTERLACED_F0_SYNC_F1_NIBBLE : INTERLACED_F1_SYNC_F0_NIBBLE;

    #if ITL_RUNTIME_CONTROL

        // Inter-thread communication for go/status
        DECLARE_VAR_WITH_REG(sc_uint<1>, 1, go);
        DECLARE_VAR_WITH_REG(sc_uint<1>, 1, running);
        DECLARE_VAR_WITH_REG(sc_uint<1>, 1, itl_control_progressive_passthrough);

        // When go is changed in controlMonitor via the MM_RAW_SLAVE, this event is used
        // to wake up behaviour in SystemC simulation
        sc_event goChanged;

        void control_monitor()
        {
            bool isRead;
            sc_uint<LOG2G(ITL_CTRL_INTERFACE_DEPTH)> address;
            go = 0;
            itl_control_progressive_passthrough = 0;
            for (;;)
            {
                isRead = itl_control->isReadAccess();
                address = itl_control->getAddress();
                if (isRead)
                {
                    // The only address we service for reads is address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_Status_ADDRESS)
                    // so always return running
                    itl_control->returnReadData(sc_int<ITL_CTRL_INTERFACE_WIDTH>(running));
                }
                else
                {
                    // This should be a sc_uint<CTRL_INTERFACE_WIDTH> (SPR 255400)
                    sc_uint<ITL_CTRL_INTERFACE_WIDTH> thisRead = sc_uint<ITL_CTRL_INTERFACE_WIDTH>(itl_control->getWriteData());
                    if (address == sc_uint<LOG2G(ITL_CTRL_INTERFACE_DEPTH)>(ITL_CTRL_Go_ADDRESS))
                    {
                        go = thisRead;
                        notify(goChanged);
                    }
                    if (address == sc_uint<LOG2G(ITL_CTRL_INTERFACE_DEPTH)>(ITL_CTRL_PROGRESSIVE_PASSTHROUGH_ADDRESS))
                    {
                        itl_control_progressive_passthrough = thisRead;
                    }
                }
            }
        }
    #else
        // itl_progressive_passthrough, to disable the interlacer and propagate progressive frames
        #define itl_progressive_passthrough false
    #endif

    // Discard the packet (field or control) relying on the end of packet signal
    void itl_discard_until_eop()
    {
        while(!din->getEndPacket())
        {
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 3);
            ALT_ATTRIB(ALT_SKIDDING, true);
            din->cRead(!din->getEndPacket());
        }
    }

    // Write a correct control packet just before image data whatever the method used (interlacing/passthrough, with or without buffering)
    // this function assumes that OUTPUT_FIELD_WIDTH, OUTPUT_FIELD_HEIGHT, OUTPUT_FIELD_INTERLACE (or rather whathever these hash-defines map to)
    // have been set correctly
    void write_control_packet()
    {
        #if ITL_NO_BUFFERING
            #define ITL_OUTPUT_FIELD_WIDTH itl_input_field_width
            #define ITL_OUTPUT_FIELD_HEIGHT itl_output_field_height
            #define ITL_OUTPUT_FIELD_INTERLACE itl_output_field_interlace
        #else
            #define ITL_OUTPUT_FIELD_WIDTH itl_reader_output_field_width
            #define ITL_OUTPUT_FIELD_HEIGHT itl_reader_output_field_height
            #define ITL_OUTPUT_FIELD_INTERLACE itl_reader_output_field_interlace
        #endif
        // Store the outputs in a shift register to abstract away
        // the fact that they could be written out in parallel or
        // sequence
        static const int N_HEADER_WORDS_TO_SEND = 9;
        ALT_REG<HEADER_WORD_BITS> output_REG[N_HEADER_WORDS_TO_SEND];
        sc_uint<HEADER_WORD_BITS> output[N_HEADER_WORDS_TO_SEND] BIND(output_REG);

        dout->writeDataAndEop(CONTROL_HEADER, false); // Send the type first
        // The width
        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[i] = ITL_OUTPUT_FIELD_WIDTH.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // The width
        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[4 + i] = ITL_OUTPUT_FIELD_HEIGHT.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // Interlacing
        output[8] = ITL_OUTPUT_FIELD_INTERLACE;

        // Write out the control packet, packing into wide words for symbols in parallel. If the two
        // do not divide exactly, round up and send an extra word with whatever happens to be in the
        // right place.
        for (unsigned int i = 0; i < (N_HEADER_WORDS_TO_SEND + ITL_CHANNELS_IN_PAR - 1) / ITL_CHANNELS_IN_PAR; ++i)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            sc_uint<ITL_BPS_PAR> thisOutput BIND(ALT_WIRE);
            thisOutput = 0;
            // Pack a word to write out. If the last word doesn't full fill the word, wrap
            // around and write again from the front
            for (int j = ITL_CHANNELS_IN_PAR - 1; j >= 0; --j)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                thisOutput <<= ITL_BPS;
                thisOutput = thisOutput | output[j];
            }

            // Shift the words to write along
            for (unsigned int j = 0; j < N_HEADER_WORDS_TO_SEND - ITL_CHANNELS_IN_PAR; ++j)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                output[j] = output[j + ITL_CHANNELS_IN_PAR];
            }
            dout->writeDataAndEop(thisOutput, i == (N_HEADER_WORDS_TO_SEND + ITL_CHANNELS_IN_PAR - 1) / ITL_CHANNELS_IN_PAR - 1);
        }
    }

// ITL, without buffering. A single thread is used
#if ITL_NO_BUFFERING
    // Prepare inclusion of vip_packet_parser.hpp
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, itl_input_header);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, itl_input_field_interlace);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, itl_input_field_width);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, itl_input_field_height);
    DECLARE_VAR_WITH_REG(bool, 1, itl_break_flow);
    DECLARE_VAR_WITH_REG(sc_biguint<ITL_BPS_PAR>, ITL_BPS_PAR, itl_input_just_read);
    #define PACKET_BPS ITL_BPS
    #define PACKET_CHANNELS_IN_PAR ITL_CHANNELS_IN_PAR
    #define PACKET_HEADER_TYPE_VAR itl_input_header
    #define PACKET_WIDTH_VAR itl_input_field_width
    #define PACKET_HEIGHT_VAR itl_input_field_height
    #define PACKET_INTERLACING_VAR itl_input_field_interlace
    #define PACKET_HAS_CHANGED_VAR itl_break_flow
    #define PACKET_JUST_READ_VAR itl_input_just_read
    #include "vip_packet_parser.hpp"

    // Hash-def to access the bits of itl_input_field_interlace
    #define itl_input_field_is_interlaced   itl_input_field_interlace.bit(INTERLACE_FLAG_BIT)
    #define itl_input_field_type            itl_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)

    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, itl_output_field_height);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, itl_output_field_interlace);

    void itl_no_buffering()
    {
        bool current_field = (ITL_FIRST_FIELD == FIELD_F0_FIRST); // This is reset just below
        itl_input_field_width = ITL_MAX_WIDTH;
        itl_input_field_height = ITL_MAX_HEIGHT;
        itl_input_field_interlace = sc_uint<HEADER_WORD_BITS>(3);
        current_field = (ITL_FIRST_FIELD == FIELD_F0_FIRST); // In case itl_break_flow is not triggered at the first iteration
        #if ITL_RUNTIME_CONTROL
            bool itl_progressive_passthrough = itl_control_progressive_passthrough;
        #endif
        for (;;)
        {
            // Read incoming packets
            itl_break_flow = false;
            handleNonImagePackets();

            #if !ITL_RUNTIME_CONTROL
                // Swap current_field each iteration, reset it in case of resolution or interlace change
                current_field = itl_break_flow ? (ITL_FIRST_FIELD == FIELD_F1_FIRST) : !current_field;
            #else
                // Swap current_field each iteration, reset it in case of resolution or interlace change
                // Make sure that we start with the correct field when switching from prog passthrough back to interlacing
                current_field = (itl_break_flow || itl_progressive_passthrough) ? (ITL_FIRST_FIELD == FIELD_F1_FIRST) : !current_field;

                // Write the running bit
                running = 0;
                NO_CUSP(itl_control->notifyEvent());
                NO_CUSP(wait(sc_time(0, SC_US)));

                // Check the go bit before starting to read
                while (!go)
                {
                    wait(goChanged);
                }

                // Copy in the latest control data
                itl_progressive_passthrough = itl_control_progressive_passthrough;

                // Write the running bit
                running = 1;
                NO_CUSP(itl_control->notifyEvent());
                NO_CUSP(wait(sc_time(0, SC_US)));
            #endif

            if (ITL_SYNC_SELECTION)
            {
                // INTERLACE_SYNC_UNKNOWN_BIT is set to zero when receiving a progressive field that has been deinterlaced, check the SYNC_FIELD_BIT in this case
                current_field = itl_input_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT) ? current_field : itl_input_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT);
            }


            // No ouput if the incoming field is interlaced and ITL_PROPAGATE_INTERLACED is false
            HW_DEBUG_MSG_COND(itl_input_field_is_interlaced && !ITL_PROPAGATE_INTERLACED, "itl_no_buffering, discarding interlaced input" << std::endl);
            if (ITL_PROPAGATE_INTERLACED || !itl_input_field_is_interlaced)
            {
                // Send the control packet. Whatever happens, we just send at most one field for each incoming field
                HW_DEBUG_MSG_COND(itl_input_field_is_interlaced, "itl_no_buffering, passing interlaced field through" << std::endl);
                HW_DEBUG_MSG_COND(!itl_input_field_is_interlaced && itl_progressive_passthrough, "itl_no_buffering, passing progressive field through" << std::endl);
                // passthrough mode
                bool full_propagate = (ITL_PROPAGATE_INTERLACED && itl_input_field_is_interlaced) || itl_progressive_passthrough ? true : false;

                // Compute output field height, take into account progressive frame whose height is odd (F0 taller than F1 by 1 line)
                itl_output_field_height = full_propagate ? sc_uint<HEADER_WORD_BITS*4>(itl_input_field_height) :
                        sc_uint<HEADER_WORD_BITS*4>(sc_uint<HEADER_WORD_BITS*4>(itl_input_field_height >> 1) +
                                (current_field ? sc_uint<1>(0) : sc_uint<1>(IS_ODD(itl_input_field_height))));
                itl_output_field_interlace = full_propagate ? itl_input_field_interlace : sc_uint<HEADER_WORD_BITS>((
                        sc_uint<1>(true), sc_uint<1>(current_field), sc_uint<1>(true), sc_uint<1>(true)));

                // Write control packet
                HW_DEBUG_MSG("itl_no_buffering, output correct control packet" << std::endl);
                write_control_packet();

                // F0 is dropped when current field is F1 unless full_propagate
                bool current_line_propagate = full_propagate || !current_field;
                // F1 is dropped when current field is F0 unless full_propagate
                bool next_line_propagate = full_propagate || current_field;

                sc_uint<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)> itl_samples_in_row;
                if (ITL_CHANNELS_IN_SEQ == 1)
                {
                    itl_samples_in_row = itl_input_field_width;
                }
                if (ITL_CHANNELS_IN_SEQ == 2)
                {
                    itl_samples_in_row = itl_input_field_width << 1;
                }
                if (ITL_CHANNELS_IN_SEQ == 3)
                {
                    itl_samples_in_row = sc_uint<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)>(itl_input_field_width << 1) +
                                            sc_uint<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)>(itl_input_field_width);
                }

                // The following loops is designed to hang on to the last element of a line
                itl_input_just_read = IMAGE_DATA;

                sc_int<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)+1> i_cp = sc_int<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)+1>(itl_samples_in_row) + sc_int<1>(-1);

                dout->setEndPacket(false);
                HW_DEBUG_MSG_COND(i_cp < sc_int<1>(0), "itl_no_buffering, Invalid width, discarding" << std::endl);
                while (!din->getEndPacket() && !(i_cp < sc_int<1>(0)))
                {
                    for (sc_int<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)+1> i = i_cp; (i >= sc_int<1>(0)) && !din->getEndPacket(); --i)
                    {
                        // Attributes of this loop
                        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                        ALT_ATTRIB(ALT_MOD_TARGET, 1);
                        ALT_ATTRIB(ALT_MIN_ITER, 32);
                        ALT_ATTRIB(ALT_SKIDDING, true);
                        vip_assert(i_cp == i);
                        bool active_read BIND(ALT_WIRE) = (i_cp >= sc_int<1>(0)) && !din->getEndPacket(); // check (i_cp >= 0) compulsory because of skidding
                        i_cp = i_cp + sc_int<1>(-1);
                        dout->cWrite(itl_input_just_read, active_read && current_line_propagate);
                        itl_input_just_read = itl_input_just_read_REG.cLdUI(din->cRead(active_read), itl_input_just_read, active_read && current_line_propagate);
                    }

                    // Swap current_line_propagate with next_line_propagate at the bottom of the loop
                    bool line_propagate_swap_wire BIND(ALT_WIRE);
                    line_propagate_swap_wire = current_line_propagate;
                    current_line_propagate = next_line_propagate;
                    next_line_propagate = line_propagate_swap_wire;

                    // Reset i_cp for next line iteration
                    i_cp = sc_int<LOG2G(ITL_MAX_WIDTH*ITL_CHANNELS_IN_SEQ)+1>(itl_samples_in_row)  + sc_int<1>(-1);
                }
                // Send last data sample with end of packet signal
                HW_DEBUG_MSG("itl_no_buffering, sending last data sample" << std::endl);
                dout->writeDataAndEop(itl_input_just_read, true);
            }

            // Discard invalid fields or interlaced input field if !ITL_PROPAGATE_INTERLACED
            itl_discard_until_eop();

            HW_DEBUG_MSG("itl_no_buffering, starting next field" << std::endl);

            // Toggle F0/F1 bit around if interlacing is on
            // Toggle from F0/ from F1 bit around if interlace nibble was indicating a frame from deinterlaced
            itl_input_field_interlace = sc_uint<HEADER_WORD_BITS>((itl_input_field_is_interlaced, itl_input_field_is_interlaced ^ itl_input_field_type,
                            itl_input_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT),
                            !(itl_input_field_is_interlaced || itl_input_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT)) ^ itl_input_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT)));
        }
    }
#endif  // ITL_NO_BUFFERING


// ITL, with buffering. Two threads are used (a writer and a reader)
#if !ITL_NO_BUFFERING

    #define ITL_IS_TRIPLE_BUFFER (ITL_NUMBER_BUFFERS >= 3)

    static const unsigned int ITL_MAX_FIELD_SIZE = ITL_MAX_WORDS_IN_ROW * ITL_MAX_HEIGHT * ITL_WORD_BYTES;
    // Compute useful memory sizes (in bytes) to store the control and user packets
    static const unsigned int ITL_MAX_PACKETS_SIZE        (ITL_MAX_NUMBER_PACKETS * ITL_MAX_WORDS_IN_PACKET * ITL_WORD_BYTES)

    static const unsigned int ITL_PACKET_ID_WIDTH = MAX(LOG2(ITL_MAX_NUMBER_PACKETS),1);

    // Intitialise the different addresses
    static const unsigned int ITL_FRAMEBUFFER_SIZE = ITL_MAX_FIELD_SIZE + ITL_MAX_PACKETS_SIZE;
    static const unsigned int ITL_FRAMEBUFFER0_ADDR = ITL_FRAMEBUFFERS_BASE_ADDR;
    static const unsigned int ITL_FRAMEBUFFER1_ADDR = ITL_FRAMEBUFFERS_BASE_ADDR + ITL_FRAMEBUFFER_SIZE;
    static const unsigned int ITL_FRAMEBUFFER2_ADDR = ITL_FRAMEBUFFERS_BASE_ADDR + (ITL_FRAMEBUFFER_SIZE * 2);
    static const unsigned int ITL_IMAGE0_ADDR = ITL_FRAMEBUFFER0_ADDR + ITL_MAX_PACKETS_SIZE;
    static const unsigned int ITL_IMAGE1_ADDR = ITL_FRAMEBUFFER1_ADDR + ITL_MAX_PACKETS_SIZE;
    static const unsigned int ITL_IMAGE2_ADDR = ITL_FRAMEBUFFER2_ADDR + ITL_MAX_PACKETS_SIZE;

    // Initialisation, the token passed between threads to designate buffer ids
    static const unsigned int ITL_INITIAL_WRITE = 0   // Write the first frame in frame buffer 0
    static const unsigned int ITL_INITIAL_STORAGE = 1;// The next one in frame buffer 1
    static const unsigned int ITL_INITIAL_UNUSED = 2; // If the frame buffer is a triple buffer, this is the third buffer initially unused

    // Create ITL_LENGTH_COUNTER_WIDTH and ITL_WORD_COUNTER_WIDTH for counters on number of samples/words streamed to/from memory
    static const unsigned int ITL_LENGTH_COUNTER_WIDTH = MAX(LOG2G(ITL_MAX_SAMPLES_IN_ROW), LOG2G(ITL_MAX_SAMPLES_IN_PACKET))
    static const unsigned int ITL_WORD_COUNTER_WIDTH = MAX(LOG2G(ITL_MAX_WORDS_IN_ROW), LOG2G(ITL_MAX_WORDS_IN_PACKET))

    // ITL_TRIGGER_COUNTER_WIDTH to count down samples in a word from ITL_SAMPLES_IN_WORD - 1 to -1 (using a sc_int)
    static const unsigned int ITL_TRIGGER_COUNTER_WIDTH = (samplesInWord == 1) ? 1 : (LOG2G(samplesInWord-1) + 1);

    //! To communicate between the two threads
    // Used by itl_writer to flag that a new buffer is available
    bool write_to_read_buf;
    sc_event write_to_read_buf_event; // For SystemC simulation
    // Used by itl_reader to acknowledge reception of a new buffer
    bool read_to_write_ack;
    sc_event read_to_write_ack_event; // For SystemC simulation

    // Used by itl_reader to flag that a dirty buffer can be reused by itl_writer
    bool read_to_write_buf;
    sc_event read_to_write_buf_event; // For SystemC simulation
    sc_uint<LOG2(ITL_NUMBER_BUFFERS)> msg_buffer_reply; // A store to return a buffer from itl_reader
    // Used by itl_writer to acknowledge reception of a new buffer
    bool write_to_read_ack;
    sc_event write_to_read_ack_event; // For SystemC simulation

    // Store registers if the two threads are not synchronized
    #if ITL_IS_TRIPLE_BUFFER
        // Buffer available
        sc_uint<LOG2(ITL_NUMBER_BUFFERS)> msg_buffer;
        // msg_field_width, to record the number of columns in received field
        sc_uint<4*HEADER_WORD_BITS> msg_field_width;
        // msg_field_height, to record the number of lines in received field
        sc_uint<4*HEADER_WORD_BITS> msg_field_height;
        // msg_field_interlace, to record interlace flag
        sc_uint<HEADER_WORD_BITS> msg_field_interlace;
        // msg_samples_in_row, to record the length of a line in samples (not pixels)
        sc_uint<LOG2G(ITL_MAX_SAMPLES_IN_ROW)> msg_samples_in_row;
        // field_word, to record the number of words in a row
        sc_uint<LOG2G(ITL_MAX_WORDS_IN_ROW)> msg_words_in_row;
        #if ITL_PROPAGATE_INTERLACED
            sc_uint<4*HEADER_WORD_BITS> msg_field_height2; // Height of second field
        #endif
    #endif

    // Prepare inclusion of vip_packet_buffering to deal with writing packets to memory
    #if ITL_MAX_NUMBER_PACKETS
        // The address of the first packet for the current buffer
        sc_uint<ITL_MEM_ADDR_WIDTH> itl_writer_packet_base_address;
        // Length of the packets in samples
        DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(ITL_MAX_SAMPLES_IN_PACKET)>, LOG2G(ITL_MAX_SAMPLES_IN_PACKET), itl_writer_packets_sample_length, ITL_MAX_NUMBER_PACKETS);
        // Length of the packets in words
        DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(ITL_MAX_WORDS_IN_PACKET)>, LOG2G(ITL_MAX_WORDS_IN_PACKET), itl_writer_packets_word_length, ITL_MAX_NUMBER_PACKETS);
        // Base address for each packet
        DECLARE_VAR_WITH_AU(sc_uint<ITL_MEM_ADDR_WIDTH>, ITL_MEM_ADDR_WIDTH, itl_writer_packet_write_address);
        // The first packet to send (corresponds to an address), this counter wraps around in case of overflow
        DECLARE_VAR_WITH_AU(sc_uint<ITL_PACKET_ID_WIDTH>, ITL_PACKET_ID_WIDTH, itl_writer_first_packet_id);
        // The last packet written, stays to MAX_NUMBER_PACKETS when overflowing
        DECLARE_VAR_WITH_AU(sc_uint<LOG2G(ITL_MAX_NUMBER_PACKETS)>, LOG2G(ITL_MAX_NUMBER_PACKETS), itl_writer_next_to_last_packet_id);
        // Registers to pass the information from itl_writer to itl_reader if not synchronized
        #if ITL_IS_TRIPLE_BUFFER
            DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(ITL_MAX_SAMPLES_IN_PACKET)>, LOG2G(ITL_MAX_SAMPLES_IN_PACKET), msg_packets_sample_length, ITL_MAX_NUMBER_PACKETS);
            DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(ITL_MAX_WORDS_IN_PACKET)>, LOG2G(ITL_MAX_WORDS_IN_PACKET), msg_packets_word_length, ITL_MAX_NUMBER_PACKETS);
            sc_uint<ITL_PACKET_ID_WIDTH> msg_first_packet;
            sc_uint<LOG2G(ITL_MAX_NUMBER_PACKETS)> msg_next_to_last_packet;
        #endif
    #endif

    #if ITL_PROPAGATE_INTERLACED
        // We also need to save the height of the first interlaced field while processing the second.
        DECLARE_VAR_WITH_REG(sc_uint<4*HEADER_WORD_BITS>, 4*HEADER_WORD_BITS, field_height_store);
        // Image_write_address, to track the field address in memory
        DECLARE_VAR_WITH_AU(sc_uint<ITL_MEM_ADDR_WIDTH>, ITL_MEM_ADDR_WIDTH, itl_writer_image_write_address);
    #endif

    // write_address, to track the address to write to in memory
    DECLARE_VAR_WITH_AU(sc_uint<ITL_MEM_ADDR_WIDTH>, ITL_MEM_ADDR_WIDTH, itl_writer_write_address);

    // Declare all variables necessary to store frames into memory
    sc_uint<LOG2(ITL_NUMBER_BUFFERS)> itl_writer_buffer;

    // These variables are also used for buffering user packets
    // length_counter, to track the length of incoming line (image data or other packets)
    DECLARE_VAR_WITH_AU(sc_uint<ITL_LENGTH_COUNTER_WIDTH>, ITL_LENGTH_COUNTER_WIDTH, itl_writer_length_counter);
    // writer_word_counter, to track the length (in words) of incoming packets (image data or other packets)
    DECLARE_VAR_WITH_AU(sc_uint<ITL_WORD_COUNTER_WIDTH>, ITL_WORD_COUNTER_WIDTH, itl_writer_word_counter);
    // Triggers each time the SAMPLES_IN_WORDS elements have gone into a word
    DECLARE_VAR_WITH_AU(sc_int<ITL_TRIGGER_COUNTER_WIDTH>, ITL_TRIGGER_COUNTER_WIDTH, itl_writer_word_counter_trigger);

    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, itl_writer_field_width);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, itl_writer_field_height);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, itl_writer_field_interlace);
    DECLARE_VAR_WITH_REG(bool, 1, itl_writer_break_flow);
    DECLARE_VAR_WITH_REG(sc_uint<ITL_BPS_PAR>, ITL_BPS_PAR, itl_writer_just_read);

    // ITL_READER THREAD, VARIABLES and FUNCTIONS
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, reader_output_field_width);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, reader_output_field_height);
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, reader_output_field_interlace);

    #define ITL_LRS(var, TOTAL_SIZE, SHIFT) \
        var = (var.range(TOTAL_SIZE-SHIFT-1, 0), var.range(TOTAL_SIZE-1, TOTAL_SIZE-SHIFT));

    // Hash-def to access the bits of itl_writer_field_interlace
    #define itl_input_field_type            itl_writer_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)
    #define itl_input_field_is_interlaced   itl_writer_field_interlace.bit(INTERLACE_FLAG_BIT)

    #define PACKET_BUF_BPS ITL_BPS
    #define PACKET_BUF_CHANNELS_IN_PAR ITL_CHANNELS_IN_PAR
    #define PACKET_BUF_WIDTH_VAR itl_writer_field_width
    #define PACKET_BUF_HEIGHT_VAR itl_writer_field_height
    #define PACKET_BUF_INTERLACING_VAR itl_writer_field_interlace
    #define PACKET_BUF_HAS_CHANGED_VAR itl_writer_break_flow
    #define PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE false
    #define PACKET_BUF_JUST_READ_VAR itl_writer_just_read
    #define PACKET_BUF_MAX_NUMBER_PACKETS ITL_MAX_NUMBER_PACKETS

    // Following variables will be used by vip_packet_buffering.hpp if we buffer the packets to memory
    #if ITL_MAX_NUMBER_PACKETS
        #define PACKET_BUF_MAX_WORDS_IN_PACKET ITL_MAX_WORDS_IN_PACKET
        #define PACKET_BUF_BURST_TARGET ITL_WDATA_BURST_TARGET
        #define PACKET_BUF_ADDR_WIDTH ITL_MEM_ADDR_WIDTH
        #define PACKET_BUF_WORD_BYTES ITL_WORD_BYTES
        #define PACKET_BUF_LENGTH_COUNTER itl_writer_length_counter
        #define PACKET_BUF_WORD_COUNTER itl_writer_word_counter
        #define PACKET_BUF_WORD_COUNTER_WIDTH ITL_WORD_COUNTER_WIDTH
        #define PACKET_BUF_TRIGGER_COUNTER itl_writer_word_counter_trigger
        #define PACKET_BUF_TRIGGER_COUNTER_WIDTH ITL_TRIGGER_COUNTER_WIDTH
        #define PACKET_BUF_SAMPLES_IN_WORD ITL_SAMPLES_IN_WORD
        #define PACKET_BUF_BASE_ADDRESS itl_writer_packet_base_address
        #define PACKET_BUF_CURRENT_ADDRESS itl_writer_packet_write_address
        #define PACKET_BUF_WRITE_ADDRESS itl_writer_write_address
        #define PACKET_BUF_FIRST_PACKET itl_writer_first_packet_id
        #define PACKET_BUF_NEXT_TO_LAST_PACKET itl_writer_next_to_last_packet_id
        #define PACKET_BUF_LENGTH_ARRAY itl_writer_packets_sample_length
        #define PACKET_BUF_WORD_ARRAY itl_writer_packets_word_length
    #endif
    #include "vip_packet_buffering.hpp"

    void itl_writer()
    {
        // Current buffer, initialised to buffer INITIAL_STORAGE
        sc_uint<ITL_LOG2_NUMBER_BUFFERS> write_buffer = sc_uint<ITL_LOG2_NUMBER_BUFFERS>(INITIAL_WRITE);
        writer_input_field_width = ITL_MAX_WIDTH;
        writer_input_field_height = ITL_MAX_HEIGHT;
        writer_input_field_interlace = sc_uint<HEADER_WORD_BITS>(0);

        #if ITL_RUNTIME_CONTROL
            bool progressive_passthrough;
        #endif

        for (;;)
        {
            // Resetting packet_write_address to correct address for the new frame
            sc_uint<ITL_MEM_ADDR_WIDTH> packet_base_address = (write_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(0)) ?
                                                                       ITL_FRAMEBUFFER0_ADDR : ITL_FRAMEBUFFER1_ADDR;
            packet_write_address = packet_base_address;
            next_to_last_packet_id = 0;
            first_packet_id = 0;
            for (sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> k = 0; k < sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS>(ITL_MAX_NUMBER_PACKETS); ++k)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                packets_sample_length[k] = 0;
                packets_word_length[k] = 0;
            }

            // write_address itself is always re-initialised when starting a burst, no need to do it here
#if ITL_DROP_FRAMES        // This is a do while loop until the frame is not dropped,
            bool drop;     // This gets set to true at the end of the loop if the reader did not return a new buffer to write onto yet
            do
            {
#endif
                /**************************************** Process the packets that precede the image data ***************************************/
                HW_DEBUG_MSG("itl_writer, parsing & storing packets" << std::endl);
                itl_handle_non_image_packets();

                /**************************************** Process the video data ************************************************************/
                // Saturating values going above their accepted limits when there is memory buffering
                writer_input_field_width = MIN(writer_input_field_width, sc_uint<HEADER_WORD_BITS*4>(ITL_MAX_WIDTH));
                writer_input_field_height = MIN(writer_input_field_height, sc_uint<HEADER_WORD_BITS*4>(ITL_MAX_HEIGHT));

                // Recompute samples_in_row (words_in_row is computed on the fly below).
                #if (KER_CHANNELS_IN_SEQ == 1)
                    samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(writer_input_field_width);
                #endif
                #if (KER_CHANNELS_IN_SEQ == 2)
                    samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(writer_input_field_width << 1);
                #endif
                #if (KER_CHANNELS_IN_SEQ == 3)
                    samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(writer_input_field_width << 1) + sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(writer_input_field_width);
                #endif

                HW_DEBUG_MSG("itl_writer, storing field, samples_in_row=" << samples_in_row << std::endl);
                // Write image data to the buffer
                writer_word_counter = 0;

                // A flag to compute the number of words in a row while processing the first line
                bool compute_words_in_row = true;
                words_in_row = writer_word_counter;


                // Write the field into the buffer, lines are word aligned
                for (sc_int<ITL_LOG2G_MAX_INPUT_FIELD_HEIGHT+1> j = sc_int<ITL_LOG2G_MAX_INPUT_FIELD_HEIGHT+1>(writer_input_field_height) +
                       sc_int<1>(-1); (j >= sc_int<ITL_LOG2G_MAX_INPUT_FIELD_HEIGHT+1>(0)) && !din->getEndPacket(); --j)
                {
                    // Reset the trigger after each line
                    writer_word_counter_trigger = ITL_SAMPLES_IN_WORD - 1;
                    bool empty_line = din->getEndPacket();
                    for (sc_int<ITL_LOG2G_MAX_SAMPLES_IN_ROW+1> i = sc_int<ITL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row) +
                           sc_int<1>(-1); i >= sc_int<1>(0); --i)
                    {
                        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                        ALT_ATTRIB(ALT_MOD_TARGET, 1);
                        ALT_ATTRIB(ALT_MIN_ITER, 3);

                        // Did we write the last sample of a word?
                        bool word_counter_trigger_flag BIND(ALT_WIRE) = writer_word_counter_trigger.bit(ITL_TRIGGER_COUNTER_WIDTH-1);

                        // Are we writting data this iteration?
                        bool active_write_flag BIND(ALT_WIRE) = !din->getEndPacket();

                        // Increment word_counter by 1 each time the trigger reaches -1 (unless this is not an active write cycle)
                        writer_word_counter = WORD_COUNTER_AU.cAddSubUI(word_counter,
                                                                 sc_uint<1>(1), writer_word_counter,
                                                                 active_write_flag && word_counter_trigger_flag,
                                                                 false);
                        // Cycle word_counter_trigger and increase number of words if necessary
                        writer_word_counter_trigger = WORD_COUNTER_TRIGGER_AU.cAddSubSLdSI(
                                writer_word_counter_trigger, sc_int<1>(-1),   // General case, --word_counter_trigger
                                ITL_SAMPLES_IN_WORD - 2,                      // -1 reached previous iteration? reinitialise and count the write
                                writer_word_counter_trigger,                  // Stay at current value if !enable
                                active_write_flag,                            // Enable line
                                word_counter_trigger_flag,                    // sLd line, reinit if word_counter_trigger == -1 (unless enable is false)
                                false);                                       // Always add -1

                        writer_just_read = din->cRead(!din->getEndPacket());

                        if (active_write_flag)
                        {
                            write_master->writePartialDataUI(writer_just_read);
                        }
                        // Time to post a full burst?
                        // Post a new burst when writing the first sample of the last word of a burst in the current iteration
                        bool burst_trigger BIND(ALT_WIRE);
                        burst_trigger = sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(writer_word_counter) == sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(ITL_WDATA_BURST_TARGET-1) && writer_word_counter_trigger_flag;

                        // word_counter_trigger_flag is true if we finished a word PREVIOUS iteration,
                        // Consequently, post a new burst if we are about to write a sample for the last word of
                        // a burst
                        if (active_write_flag && burst_trigger)
                        {
                            HW_DEBUG_MSG("itl_writer, posting burst " << ITL_WDATA_BURST_TARGET << " at addr " << write_address << std::endl);
                            write_master->busPostWriteBurst(write_address, ITL_WDATA_BURST_TARGET);
                            write_address += (ITL_WDATA_BURST_TARGET << LOG2(ITL_WORD_BYTES));
                        }
                    }
                    // Finish and count the last word of a line
                    write_master->flush();
                    // Is there a need for a last burst?
                    bool no_last_burst = (sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(writer_word_counter) == sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(ITL_WDATA_BURST_TARGET-1)) || empty_line;
                    if (!empty_line)
                    {
                        ++word_counter;
                    }

                    // words_in_row is saved after the first line
                    if (compute_words_in_row)
                    {
                        words_in_row = writer_word_counter;
                    }
                    compute_words_in_row = false;

                    // Post the last burst, truncate word_counter to get the size
                    if (!no_last_burst)
                    {
                        HW_DEBUG_MSG("itl_writer, posting last line burst " << sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(writer_word_counter) << " at addr " << write_address << std::endl);
                        write_master->busPostWriteBurst(write_address, sc_uint<LOG2(ITL_WDATA_BURST_TARGET)>(writer_word_counter));
                    }
                }

                // Purge input until eop in case of overflow
                HW_DEBUG_MSG_COND(!din->getEndPacket(), "itl_writer, memory overflow, discarding extra image data" << std::endl);
                itl_discard_until_eop();
                HW_DEBUG_MSG("itl_writer, image data of " << word_counter << " words, received (excluding discard)" << std::endl);

                // Switch interlace flag in case there is no control packet to confirm INTERLACE_FIELD_TYPE with the next interlaced field
                writer_input_field_interlace = (writer_input_field_interlace.bit(INTERLACE_FLAG_BIT),
                        writer_input_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                             !writer_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) : writer_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                         writer_input_field_interlace.range(INTERLACE_FIELD_TYPE_BIT - 1, 0));

#if ITL_DROP_FRAMES
                drop = (read_to_write_buf == write_to_read_ack); // When the msg and ack bits are the same there is no new message
                HW_DEBUG_MSG_COND(drop, "itl_writer, new frame dropped" << std::endl);
            } while (drop);
#endif

            while (write_to_read_buf != read_to_write_ack) // itl_reader has not dealt with the last buffer yet.
            {
                wait(read_to_write_ack_event);
            }

            HW_DEBUG_MSG("itl_writer, new frame/field is kept and given to itl_reader" << std::endl);
            HW_DEBUG_MSG("itl_writer, along with " << next_to_last_packet_id << " AvST packets, "
                         << "starting at " << first_packet_id << std::endl);

            // Transmit important data allong with buffer id
            msg_buffer = write_buffer;
            msg_words_in_row = words_in_row;
            msg_samples_in_row = samples_in_row;
            msg_field_width = writer_input_field_width;
            msg_field_height = writer_input_field_height;
            msg_first_packet = first_packet_id;
            msg_next_to_last_packet = next_to_last_packet_id;
            #if ITL_RUNTIME_CONTROL
                msg_progressive_passthrough = progressive_passthrough;
            #endif
            for (sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> k = 0; k < sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS>(ITL_MAX_NUMBER_PACKETS); ++k)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                msg_packets_sample_length[k] = writer_packets_sample_length[k];
                msg_packets_word_length[k] = writer_packets_word_length[k];
            }

            write_to_read_buf = !write_to_read_buf;
            notify(write_to_read_buf_event);

            // Receive a new buffer token from the reader and write on it at the next loop iteration,
#if !ITL_DROP_FRAMES
            while (read_to_write_buf == write_to_read_ack) // itl_reader has not sent a new buffer yet
            {
                wait(read_to_write_buf_event);
            }
#endif
            write_buffer = msg_buffer_reply;

            write_to_read_ack = !write_to_read_ack;
            notify(write_to_read_ack_event);
        }
    }


    void itl_reader()
    {
        // Current buffer
        sc_uint<ITL_LOG2_NUMBER_BUFFERS> read_buffer = sc_uint<ITL_LOG2_NUMBER_BUFFERS>(INITIAL_STORAGE);

        // read_address and READ_ADDRESS_AU operation on address in memory
        ALT_AU<ITL_MEM_ADDR_WIDTH> READ_ADDRESS_AU;
        sc_uint<ITL_MEM_ADDR_WIDTH> read_address BIND(READ_ADDRESS_AU);

        ALT_AU<ITL_MEM_ADDR_WIDTH> PACKET_READ_ADDRESS_AU;
        sc_uint<ITL_MEM_ADDR_WIDTH> packet_read_address BIND(PACKET_READ_ADDRESS_AU);
        // Keep a record of the base address so that we know where to wrap around
        sc_uint<ITL_MEM_ADDR_WIDTH> packet_base_address;
        // What is the first packet to send (usually 0 but this can be different if there was packet overflow)
        ALT_AU<ITL_LOG2G_MAX_NUMBER_PACKETS> current_packet_id_AU;
        sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> current_packet_id BIND(current_packet_id_AU);
        // What is the last packet to send
        sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> next_to_last_packet_id;

        // Length of the packets in samples, stored in one big register
        sc_biguint<ITL_LOG2G_MAX_SAMPLES_IN_PACKET*ITL_MAX_NUMBER_PACKETS> reader_packets_sample_length;
        // Length of the packets in words, stored in one big register
        sc_biguint<ITL_LOG2G_MAX_WORDS_IN_PACKET*ITL_MAX_NUMBER_PACKETS> reader_packets_word_length;

        // Recevied the number of samples and words in a row
        sc_uint<ITL_LOG2G_MAX_SAMPLES_IN_ROW> samples_in_row;
        sc_uint<ITL_LOG2G_MAX_WORDS_IN_ROW> words_in_row;

        // reader_word_counter, to track the length (in words) of packets or image lines
        sc_uint<ITL_WORD_COUNTER_WIDTH> reader_word_counter;

#if ITL_IS_TRIPLE_BUFFER
        // Send unused buffer straightaway
        msg_buffer_reply = INITIAL_UNUSED;
        read_to_write_buf = true;
        notify(read_to_write_buf_event);
#endif

        reader_input_field_interlace = INITIAL_INTERLACE_NIBBLE;

        for (;;)
        {
#if !ITL_REPEAT_FIELDS
            while (write_to_read_buf == read_to_write_ack) // itl_writer has not sent a buffer yet
            {
                wait(write_to_read_buf_event);
            }
#endif

            while (read_to_write_buf != write_to_read_ack) // itl_writer has not acknowledged the previous buffer
            {
                wait(write_to_read_ack_event);
            }

            msg_buffer_reply = read_buffer; // Prepare reply ...
            // ... and get the message
            read_buffer = msg_buffer;
            samples_in_row = msg_samples_in_row;
            reader_input_field_width = msg_field_width;
            words_in_row = msg_words_in_row;
            current_packet_id = msg_first_packet_id;
            next_to_last_packet_id = msg_next_to_last_packet_id;
            #if (ITL_RUNTIME_CONTROL && ITL_INTERLACED_PASSTHROUGH)
                bool interlacing_on = !(reader_input_field_interlace.bit(INTERLACE_FLAG_BIT) || msg_progressive_passthrough);
            #elif ITL_RUNTIME_CONTROL
                bool interlacing_on = !msg_progressive_passthrough;
            #elif ITL_INTERLACED_PASSTHROUGH
                bool interlacing_on = !reader_input_field_interlace.bit(INTERLACE_FLAG_BIT)
            #else
                static const bool interlacing_on = true;
            #endif
            // height is divided by 2 if we are doing the interlacing
            reader_input_field_height = interlacing_on ? (msg_field_height>>1) : msg_field_height;
            // interlace nibble has to change when doing the interlacing, otherwise keep the one from last control packet
            reader_input_field_interlace = interlacing_on ? INITIAL_INTERLACE_NIBBLE : msg_field_interlace;

            sc_biguint<ITL_LOG2G_MAX_SAMPLES_IN_PACKET*ITL_MAX_NUMBER_PACKETS>  reader_packets_sample_length_load_wire BIND(ALT_WIRE);
            sc_biguint<ITL_LOG2G_MAX_WORDS_IN_PACKET*ITL_MAX_NUMBER_PACKETS> reader_packets_word_length_load_wire BIND(ALT_WIRE);
            for (sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> k = 0; k < sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS>(ITL_MAX_NUMBER_PACKETS); ++k)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                reader_packets_sample_length_load_wire |= msg_packets_sample_length[k];
                reader_packets_sample_length_load_wire == reader_packets_sample_length_load_wire << ITL_LOG2G_MAX_SAMPLES_IN_PACKET;
                reader_packets_word_length_load_wire |= msg_packets_word_length[k];
                reader_packets_word_length_load_wire == reader_packets_word_length_load_wire << ITL_LOG2G_MAX_WORDS_IN_PACKET;
            }
            // Align the lsb with packet 0 (ie, left rotate shift by one element)
            ITL_LRS(reader_packets_sample_length_load_wire, ITL_LOG2G_MAX_SAMPLES_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_SAMPLES_IN_PACKET);
            ITL_LRS(reader_packets_word_length_load_wire, ITL_LOG2G_MAX_WORDS_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_WORDS_IN_PACKET);
            reader_packets_sample_length = reader_packets_sample_length_load_wire;
            reader_packets_word_length = reader_packets_word_length_load_wire;

            // Acknowledge the message and reply
            read_to_write_ack = !read_to_write_ack;
            sc_event(read_to_write_ack_event);
            read_to_write_buf = !read_to_write_buf;
            sc_event(read_to_write_buf_event);

#if ITL_IS_TRIPLE_BUFFER
            packet_base_address = (read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(0)) ? ITL_FRAMEBUFFER0_ADDR :
                                  ((read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(1)) ? ITL_FRAMEBUFFER1_ADDR : ITL_FRAMEBUFFER2_ADDR);
#else
            packet_base_address = (read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(0)) ? ITL_FRAMEBUFFER0_ADDR : ITL_FRAMEBUFFER1_ADDR;
#endif
            /* Propagate packets */
            packet_read_address = packet_base_address;
            HW_DEBUG_MSG("itl_reader, start, from packet address id " << current_packet_id << std::endl);
            // Compute address of the first packet (a bit slow but this should do ok) when there was overflow
            // Also keep a record of where we should wrap the address around
            sc_uint<ITL_LOG2G_MAX_NUMBER_PACKETS> wrap_packet_id = next_to_last_packet_id;
            while (current_packet_id != 0);
            {
                packet_read_address = PACKET_READ_ADDRESS_AU.addSubSLd(packet_read_address,
                                      sc_uint<ITL_MEM_ADDR_WIDTH>(ITL_MAX_WORDS_IN_PACKET * ITL_WORD_BYTES),
                                      packet_base_address /* don't care */,
                                      false,
                                      false);
                current_packet_id = current_packet_id_AU.addSubSLdUI(current_packet_id, sc_uint<1>(1), current_packet_id, false, true);
                --wrap_packet_id;
                // Left-Rotate shift by one element to align the lsb of the length registers with packet_id
                ITL_LRS(reader_packets_sample_length, ITL_LOG2G_MAX_SAMPLES_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_SAMPLES_IN_PACKET);
                ITL_LRS(reader_packets_word_length, ITL_LOG2G_MAX_WORDS_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_WORDS_IN_PACKET);
            }

            // Send packets
            while (current_packet_id != next_to_last_packet_id)
            {
                // Get length and number of words
                sc_uint<ITL_LOG2G_MAX_SAMPLES_IN_PACKET> packet_length_counter BIND(ALT_WIRE);
                packet_length_counter = reader_packets_sample_length.range(ITL_LOG2G_MAX_SAMPLES_IN_PACKET-1,0);
                reader_word_counter = reader_packets_word_length.range(ITL_LOG2G_MAX_WORDS_IN_PACKET-1,0);
                HW_DEBUG_MSG("itl_reader, sending packet (size = " << packet_length_counter << " * "
                             << ITL_CHANNELS_IN_PAR << "), from address " << packet_read_address << std::endl);
                HW_DEBUG_MSG("itl_reader, packet length in memory words = " << reader_word_counter << std::endl);
                // Post the read burst and send the packet
                read_master->busPostReadBurst(packet_read_address, reader_word_counter);
                sc_int<ITL_LOG2G_MAX_SAMPLES_IN_PACKET+1> length_cnt = packet_length_counter - sc_uint<2>(2);
                while(!length_cnt.bit(ITL_LOG2G_MAX_SAMPLES_IN_PACKET))
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 3);
                    ALT_ATTRIB(ALT_SKIDDING, true);
                    if (!length_cnt.bit(ITL_LOG2G_MAX_SAMPLES_IN_PACKET)) // Because we may be violating MIN_ITER condition
                    {
                        dout->writeDataAndEop(read_master->collectPartialReadUI(), false);
                    }
                    --length_cnt;
                }
                dout->writeDataAndEop(read_master->collectPartialReadUI(), true);
                /* Discard unused data at the end of the last word */
                read_master->discard();
                packet_read_address = PACKET_READ_ADDRESS_AU.addSubSLd(packet_read_address,
                                      sc_uint<ITL_MEM_ADDR_WIDTH>(ITL_MAX_WORDS_IN_PACKET * ITL_WORD_BYTES),
                                      packet_base_address,
                                      current_packet_id == wrap_packet_id,
                                      false);
                // ++current_packet_id
                current_packet_id = current_packet_id_AU.addSubSLdUI(current_packet_id, sc_uint<1>(1), current_packet_id, false, false);
                // Move to the next set of lengths
                ITL_LRS(reader_packets_sample_length, ITL_LOG2G_MAX_SAMPLES_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_SAMPLES_IN_PACKET);
                ITL_LRS(reader_packets_word_length, ITL_LOG2G_MAX_WORDS_IN_PACKET*ITL_MAX_NUMBER_PACKETS, ITL_LOG2G_MAX_WORDS_IN_PACKET);
            }


            // This is a do while loop until the fields of the frame stop being repeated,
            // repeat is set to true if the writer did not provide a new frame and decision to repeat the current one was taken
            bool repeat;
            bool second_field_needed = !interlacing_on;
            do
            {
                // Send control packet before the field.
                write_corrected_packet();

                // Set read address to start of chosen read frame
#if ITL_IS_TRIPLE_BUFFER
                read_address = (read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(0)) ? ITL_FIELD0_ADDR :
                               ((read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(1)) ? ITL_FIELD1_ADDR : ITL_FIELD2_ADDR);
#else
                read_address = (read_buffer == sc_uint<ITL_LOG2_NUMBER_BUFFERS>(0)) ? ITL_FIELD0_ADDR : ITL_FIELD1_ADDR;
#endif

                // Send the image data type
                bool empty_image BIND(ALT_WIRE);
                empty_image = (words_in_row == sc_uint<ITL_LOG2G_MAX_WORDS_IN_ROW>(0));

                dout->writeDataAndEop(IMAGE_DATA, empty_image);

                HW_DEBUG_MSG("itl_reader, sending image data from buffer " << read_buffer << " addr " << read_address << std::endl);

                // Send the image
                if (!empty_image)
                {
                    // The read burst posted to read_master are all of the size of a line
                    reader_word_counter = words_in_row;
                    // Skip the first line of the buffer when producing a F1 field, do not skip the first line for F0 field
                    bool line_skip = reader_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT);
                    // The size of the j counter should be the size of an interlaced field + 1 unless propagate
                    // progressive mode is on, ITL_MAX_FIELD_HEIGHT
                    for (sc_int<ITL_LOG2G_MAX_FIELD_HEIGHT + (ITL_RUNTIME_CONTROL ? 1 : 0)> j =
                             sc_int<ITL_LOG2G_MAX_FIELD_HEIGHT + (ITL_RUNTIME_CONTROL ? 1 : 0)>(reader_output_field_height) + sc_int<1>(-1); j >= 0; --j);
                    {
                        // Increment the read adress counter by one line unless no interlacing is going on.
                        // This instruction is also skipped for the first line of a F0 field
                        if (interlacing_on && line_skip)
                        {
                            read_address += words_in_row;
                        }
                        read_master->busPostReadBurstUI(read_address, reader_word_counter);
                        sc_int<ITL_LOG2G_MAX_SAMPLES_IN_ROW+1> i_cp = samples_in_row;
                        for (sc_int<ITL_LOG2G_MAX_SAMPLES_IN_ROW+1> i =
                                sc_int<ITL_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row) + sc_int<1>(-1); i >= 0; --i);
                        {
                            // Attributes of this loop
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            ALT_ATTRIB(ALT_MIN_ITER, 32);
                            --i_cp;
                            vip_assert(i_cp == i);
                            sc_uint<ITL_BPS_PAR> reader_just_read = read_master->collectPartialReadUI();
                            dout->writeDataAndEop(reader_just_read, (j == sc_int<1>(0)) && (i_cp == sc_int<1>(0)));
                        }
                        // Flush the final word of a line in case it was not read completely
                        read_master->flush();
                        // Increment the read adress counter by one line
                        read_address += words_in_row;
                        // In the standard case the unused line of the opposite field must be skipped at the next loop iteration
                        // but this will not happen when doing a passthrough prog->prog or interlaced->interlaced
                        line_skip = true;
                    }
                }

                // Toggle F0/F1 bit around if interlacing is on
                reader_input_field_interlace = reader_input_field_interlace_REG.cLdUI(
                        sc_uint<HEADER_WORD_BITS>(reader_input_field_interlace.bit(INTERLACE_FLAG_BIT), !reader_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                                  reader_input_field_interlace.range(INTERLACE_FIELD_TYPE_BIT-1, 0)),
                                                  reader_input_field_interlace, interlacing_on);
                HW_DEBUG_MSG_COND(interlacing_on && second_field_needed, "itl_reader, first interlaced field sent, now doing second field" << std::endl);
                HW_DEBUG_MSG_COND(interlacing_on && !second_field_needed, "itl_reader, second interlaced field sent" << std::endl);
                HW_DEBUG_MSG_COND(!second_field_needed, "itl_reader, passthrough field sent" << std::endl);

                // When the msg and ack bits are the same there is no new message and a repeat is necessary
                repeat = second_field_needed || (write_to_read_buf == read_to_write_ack);
                HW_DEBUG_MSG_COND(!second_field_needed && repeat, "itl_reader, repeating frame" << std::endl);
                second_field_needed = false;  // Make sure the loop has a chance to terminate after two fields have been sent
            } while (repeat);
            HW_DEBUG_MSG("itl_reader, switching to a new frame, giving back a buffer token to itl_writer" << std::endl);
    }
#endif // !ITL_NO_BUFFERING

#endif // SYNTH_MODE

    SC_HAS_PROCESS(ITL_NAME);
    const char* param;
    ITL_NAME(sc_module_name name_, const char* PARAMETERISATION = "<interlacerParams><ITL_NAME>my_interlacing_core</ITL_NAME><ITL_MAX_WIDTH>640</ITL_MAX_WIDTH><ITL_MAX_HEIGHT>480</ITL_MAX_HEIGHT><ITL_BPS>8</ITL_BPS><ITL_CHANNELS_IN_SEQ>3</ITL_CHANNELS_IN_SEQ><ITL_CHANNELS_IN_PAR>1</ITL_CHANNELS_IN_PAR><ITL_FIRST_FIELD>FIELD_F0_FIRST</ITL_FIRST_FIELD><ITL_NO_BUFFERING>true</ITL_NO_BUFFERING><ITL_DROP_FRAMES>false</ITL_DROP_FRAMES><ITL_REPEAT_FIELDS>false</ITL_REPEAT_FIELDS><ITL_FRAMEBUFFERS_ADDR>00</ITL_FRAMEBUFFERS_ADDR><ITL_MEM_PORT_WIDTH>64</ITL_MEM_PORT_WIDTH><ITL_MEM_MASTERS_USE_SEPARATE_CLOCK>0</ITL_MEM_MASTERS_USE_SEPARATE_CLOCK><ITL_RDATA_FIFO_DEPTH>64</ITL_RDATA_FIFO_DEPTH><ITL_RDATA_BURST_TARGET>32</ITL_RDATA_BURST_TARGET><ITL_WDATA_FIFO_DEPTH>64</ITL_WDATA_FIFO_DEPTH><ITL_WDATA_BURST_TARGET>32</ITL_WDATA_BURST_TARGET><ITL_MAX_NUMBER_PACKETS>0</ITL_MAX_NUMBER_PACKETS><ITL_MAX_SYMBOLS_IN_PACKET>1</ITL_MAX_SYMBOLS_IN_PACKET><ITL_PROPAGATE_INTERLACED>1</ITL_PROPAGATE_INTERLACED><ITL_RUNTIME_CONTROL>0</ITL_RUNTIME_CONTROL><ITL_SYNC_SELECTION>0</ITL_SYNC_SELECTION></interlacerParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        din = new ALT_AVALON_ST_INPUT< sc_uint<ITL_BPS_PAR> >();
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint<ITL_BPS_PAR> >();
        read_master = NULL;
        write_master = NULL;
        itl_control = NULL;

// if not test flow, i.e constructor defined
#ifndef LEGACY_FLOW
        // Set up input and output
        int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_BPS", 8);
        int channelsInPar = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_CHANNELS_IN_PAR", 3);

        din->setSymbolsPerBeat(channelsInPar);
        din->setDataWidth(bps*channelsInPar);
        dout->setSymbolsPerBeat(channelsInPar);
        dout->setDataWidth(bps*channelsInPar);
        din->enableEopSignals();
        dout->enableEopSignals();

        bool noBuffering = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_NO_BUFFERING", 1);

        if (!noBuffering)
        {
            int masterPortWidth = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_MEM_PORT_WIDTH", 64);
            bool mastersUseSeparateClock = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_MEM_MASTERS_USE_SEPARATE_CLOCK", 0);
            int rdataBurstTarget = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_RDATA_BURST_TARGET", 32);
            int wdataBurstTarget = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_WDATA_BURST_TARGET", 32);

            read_master->setDataWidth(masterPortWidth);
            read_master->setUseOwnClock(mastersUseSeparateClock);
            read_master->setRdataBurstSize(rdataBurstTarget);
            read_master->setWdataBurstSize(0);
            read_master->enableReadPorts();

            write_master->setDataWidth(masterPortWidth);
            write_master->setUseOwnClock(mastersUseSeparateClock);
            write_master->setWdataBurstSize(wdataBurstTarget);
            write_master->setRdataBurstSize(0);
            write_master->enableWritePorts();
        }

        bool runtime = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "interlacerParams;ITL_RUNTIME_CONTROL", 0);
        if(runtime){
            //CTRL INTEFACE WIDTH AND DEPTH are static
            itl_control = new ALT_AVALON_MM_RAW_SLAVE <ITL_CTRL_INTERFACE_WIDTH, ITL_CTRL_INTERFACE_DEPTH>();
            itl_control->setUseOwnClock(false);
            itl_control->enableWritePorts();
            itl_control->enableReadPorts();
        }

#else
    #if !ITL_NO_BUFFERING
        read_master = new ALT_AVALON_MM_MASTER_FIFO<ITL_MEM_PORT_WIDTH, ITL_MEM_ADDR_WIDTH, ITL_READ_MASTER_MAX_BURST, ITL_BPS_PAR>();
        write_master = new ALT_AVALON_MM_MASTER_FIFO<ITL_MEM_PORT_WIDTH, ITL_MEM_ADDR_WIDTH, ITL_WRITE_MASTER_MAX_BURST, ITL_BPS_PAR>();
        read_master->setUseOwnClock(ITL_MEM_MASTERS_USE_SEPARATE_CLOCK);
        read_master->setRdataBurstSize(ITL_RDATA_BURST_TARGET);
        read_master->setWdataBurstSize(0);
        write_master->setUseOwnClock(ITL_MEM_MASTERS_USE_SEPARATE_CLOCK);
        write_master->setWdataBurstSize(ITL_WDATA_BURST_TARGET);
        write_master->setRdataBurstSize(0);
    #endif
    #if ITL_RUNTIME_CONTROL
        itl_control = new ALT_AVALON_MM_RAW_SLAVE<ITL_CTRL_INTERFACE_WIDTH, ITL_CTRL_INTERFACE_DEPTH>();
        itl_control->setUseOwnClock(false);
    #endif
#endif // LEGACY_FLOW

#ifdef SYNTH_MODE
    #if ITL_NO_BUFFERING
        SC_THREAD(itl_no_buffering);
    #else
        write_master->setWdataFifoDepth(ITL_WDATA_FIFO_DEPTH);
        write_master->setCmdFifoDepth(ITL_WDATA_CMD_FIFO_DEPTH);
        read_master->setRdataFifoDepth(ITL_RDATA_FIFO_DEPTH);
        read_master->setCmdFifoDepth(2); // Reads are posted one line in advance
        SC_THREAD(itl_writer);
        SC_THREAD(itl_reader);
    #endif
    #if ITL_RUNTIME_CONTROL
        SC_THREAD(control_monitor);
    #endif
#endif //SYNTH_MODE
    }
};
