/**
* \file vip_vfb_hwfast.hpp
*
* \author vshankar
*
* \brief Synthesisable frame buffer core.
* A frame buffer core that can be parameterised and then synthesised with CusP.
* It allows for double buffering (frames are neither dropped nor repeated) and triple buffering (frames can be dropped and/or repeated)
*/

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
    #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
    #undef VFB_NAME
    #define VFB_NAME alt_vip_vfb
#endif


SC_MODULE(VFB_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/frame_buffer.jar?com.altera.vip.entityinterfaces.helpers.VFBEntityHelper";
    }
    static const char * get_display_name(void)
    {
        return "Frame Buffer";
    }
    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }
    static const char * get_description(void)
    {
        return "The Frame Buffer provides a means to double or triple buffer video frames.";
    }
    static const char * get_product_ids(void)
    {
        return "00C3";
    }
#include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif //LEGACY_FLOW

#ifndef SYNTH_MODE
    #define VFB_BPS 20
    #define VFB_CHANNELS_IN_PAR 3
    #define VFB_MEM_PORT_WIDTH 256
    #define VFB_WRITE_MASTER_MAX_BURST 32
    #define VFB_READ_MASTER_MAX_BURST 32
    #define VFB_WRITER_CTRL_INTERFACE_WIDTH 16
    #define VFB_WRITER_CTRL_INTERFACE_DEPTH 7
    #define VFB_READER_CTRL_INTERFACE_WIDTH 16
    #define VFB_READER_CTRL_INTERFACE_DEPTH 4
#else
    // Compute useful memory sizes (in bytes) for a frame of image data
    static const unsigned int VFB_IMAGE_BUFFER_SIZE = VFB_WORDS_IN_ALIGNED_FRAME * VFB_WORD_BYTES;
    // Compute useful memory sizes (in bytes) to store user packets
    static const unsigned int VFB_PACKETS_BUFFER_SIZE = VFB_WORDS_IN_ALIGNED_PACKET * VFB_WORD_BYTES * VFB_MAX_NUMBER_PACKETS;

    static const unsigned int VFB_PACKET_ID_WIDTH = MAX(LOG2(VFB_MAX_NUMBER_PACKETS),1);

    // Compute the frame buffer size
    static const unsigned int VFB_FRAMEBUFFER_SIZE = VFB_IMAGE_BUFFER_SIZE + VFB_PACKETS_BUFFER_SIZE;

    // Bits for the interlace nibble of control packets
    static const unsigned int INTERLACE_FLAG_BIT = HEADER_WORD_BITS-1;
    static const unsigned int INTERLACE_FIELD_TYPE_BIT = HEADER_WORD_BITS-2;
    static const unsigned int INTERLACE_SYNC_UNKNOWN_BIT = HEADER_WORD_BITS-3;
    static const unsigned int INTERLACE_SYNC_FIELD_BIT = HEADER_WORD_BITS-4;

    // Address of each buffer
    static const unsigned int VFB_FRAMEBUFFER0_ADDR = VFB_FRAMEBUFFERS_BASE_ADDR;
    static const unsigned int VFB_FRAMEBUFFER1_ADDR = VFB_FRAMEBUFFER0_ADDR + VFB_FRAMEBUFFER_SIZE;
    static const unsigned int VFB_FRAMEBUFFER2_ADDR = VFB_FRAMEBUFFER1_ADDR + VFB_FRAMEBUFFER_SIZE;

    // Address of each frame within each buffer
    static const unsigned int VFB_IMAGE0_ADDR = VFB_FRAMEBUFFER0_ADDR + VFB_PACKETS_BUFFER_SIZE;
    static const unsigned int VFB_IMAGE1_ADDR = VFB_FRAMEBUFFER1_ADDR + VFB_PACKETS_BUFFER_SIZE;
    static const unsigned int VFB_IMAGE2_ADDR = VFB_FRAMEBUFFER2_ADDR + VFB_PACKETS_BUFFER_SIZE;

    // Initialisation, the token passed between threads to designate buffer ids
    static const unsigned int INITIAL_WRITE = 0;
    static const unsigned int INITIAL_STORAGE = 1;
    static const unsigned int INITIAL_UNUSED = 2;

    static const unsigned int VFB_LENGTH_COUNTER_WIDTH = LOG2G(MAX(VFB_MAX_SAMPLES_IN_FRAME, VFB_MAX_SAMPLES_IN_PACKET));
    static const unsigned int VFB_WORD_COUNTER_WIDTH = LOG2G(MAX(VFB_MAX_WORDS_IN_FRAME, VFB_MAX_WORDS_IN_PACKET));

    // Set up the max burst to be in agreement with both the XDATA_BURST_TARGETs parameters and the actual burst that are posted by the core
    // If VFB_?DATA_BURST_TARGET is bigger than the parameter it is compared too then the hardware is probably not very efficient
    static const unsigned int VFB_WRITE_MASTER_MAX_BURST = VFB_WDATA_BURST_TARGET;
    static const unsigned int VFB_MAX_WORDS_READ_BURST = ((VFB_MAX_WORDS_IN_FRAME > VFB_MAX_WORDS_IN_PACKET) ?
                                                                      VFB_MAX_WORDS_IN_FRAME : VFB_MAX_WORDS_IN_PACKET);
    static const unsigned int VFB_READ_MASTER_MAX_BURST = ((VFB_MAX_WORDS_READ_BURST > VFB_RDATA_BURST_TARGET) ?
                                                                     VFB_MAX_WORDS_READ_BURST : VFB_RDATA_BURST_TARGET);

    // Reserve enough space in the command FIFO so that we can issue enough write command to fill the FIFO, + 1 to avoid lock during pipelining
    static const unsigned int VFB_WDATA_CMD_FIFO_DEPTH = (VFB_WDATA_FIFO_DEPTH / VFB_WDATA_BURST_TARGET) + 1;

    // Static parameters for the optional runtime controllers
    static const unsigned int VFB_WRITER_CTRL_INTERFACE_WIDTH = 16;
    static const unsigned int VFB_WRITER_CTRL_INTERFACE_DEPTH = VFB_CONTROLLED_DROP_REPEAT ? 7 : 4;
    static const unsigned int VFB_READER_CTRL_INTERFACE_WIDTH = 16;
    static const unsigned int VFB_READER_CTRL_INTERFACE_DEPTH = 4;
#endif

    // Width of the Avalon-ST ports
    static const unsigned int VFB_BPS_PAR = VFB_BPS * VFB_CHANNELS_IN_PAR;

    // Size of the address port
    static const unsigned int VFB_MEM_ADDR_WIDTH = 32;

    //! Data input stream and output stream
    ALT_AVALON_ST_INPUT< sc_uint<VFB_BPS_PAR> > *din;
    ALT_AVALON_ST_OUTPUT< sc_uint<VFB_BPS_PAR> > *dout;

    //! A couple of master ports, one for reading and one for writing
    ALT_AVALON_MM_MASTER_FIFO<VFB_MEM_PORT_WIDTH, VFB_MEM_ADDR_WIDTH, VFB_READ_MASTER_MAX_BURST, VFB_BPS_PAR> *read_master ALT_BIND_SEQ_PER_RESOURCE;
    ALT_AVALON_MM_MASTER_FIFO<VFB_MEM_PORT_WIDTH, VFB_MEM_ADDR_WIDTH, VFB_WRITE_MASTER_MAX_BURST, VFB_BPS_PAR> *write_master ALT_BIND_SEQ_PER_RESOURCE;

    // Runtime control ports
    ALT_AVALON_MM_MEM_SLAVE <VFB_WRITER_CTRL_INTERFACE_WIDTH, VFB_WRITER_CTRL_INTERFACE_DEPTH> *writer_control;
    ALT_AVALON_MM_MEM_SLAVE <VFB_READER_CTRL_INTERFACE_WIDTH, VFB_READER_CTRL_INTERFACE_DEPTH> *reader_control;

#ifdef SYNTH_MODE

    #define VFB_IS_TRIPLE_BUFFER (VFB_NUMBER_BUFFERS > 2)

    //! To communicate between the two threads
    // Used by vfb_writer to flag that a new buffer is available
    bool write_to_read_buf;
    sc_event write_to_read_buf_event; // For SystemC simulation
    // Used by vfb_reader to acknowledge reception of a new buffer
    bool read_to_write_ack;
    sc_event read_to_write_ack_event; // For SystemC simulation

    // Used by vfb_reader to flag that a dirty buffer can be reused by vfb_writer
    bool read_to_write_buf;
    sc_event read_to_write_buf_event; // For SystemC simulation
    sc_uint<LOG2(VFB_NUMBER_BUFFERS)> msg_buffer_reply; // A store to return a buffer from vfb_reader
    // Used by vfb_writer to acknowledge reception of a new buffer
    bool write_to_read_ack;
    sc_event write_to_read_ack_event; // For SystemC simulation

    // Store registers if the two threads are not synchronized
    #if VFB_IS_TRIPLE_BUFFER
        // Buffer available
        sc_uint<LOG2(VFB_NUMBER_BUFFERS)> msg_buffer;
        // msg_field_width, to record the number of columns in received field
        sc_uint<4*HEADER_WORD_BITS> msg_field_width;
        // msg_field_height, to record the number of lines in received field
        sc_uint<4*HEADER_WORD_BITS> msg_field_height;
        // msg_field_interlace, to record interlace flag
        sc_uint<HEADER_WORD_BITS> msg_field_interlace;
        // msg_samples_in_row, to record the number of samples in a field
        sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)> msg_samples_in_field;
        // field_word, to record the number of words in a frame
        sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> msg_words_in_field;
        #if VFB_INTERLACED_SUPPORT
            sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)> msg_samples_in_field2; // Number of samples in second field
            sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> msg_words_in_field2; // Number of words in second field
            sc_uint<4*HEADER_WORD_BITS> msg_field_height2; // Height of second field
        #endif
        #if VFB_CONTROLLED_DROP_REPEAT
            DECLARE_VAR_WITH_REG(sc_uint<VFB_WRITER_CTRL_INTERFACE_WIDTH>, VFB_WRITER_CTRL_INTERFACE_WIDTH, vfb_writer_input_frame_rate);
            DECLARE_VAR_WITH_REG(sc_uint<VFB_WRITER_CTRL_INTERFACE_WIDTH>, VFB_WRITER_CTRL_INTERFACE_WIDTH, vfb_writer_output_frame_rate);
            // The "error", for our variant of the Bresenham's line algorithm (in the range +/- 2*rate)
            ALT_AU<VFB_WRITER_CTRL_INTERFACE_WIDTH+1> drop_error_AU;
            sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1> drop_error BIND(drop_error_AU);
            ALT_AU<VFB_WRITER_CTRL_INTERFACE_WIDTH+1> repeat_error_AU;
            sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1> repeat_error BIND(repeat_error_AU);
            DECLARE_VAR_WITH_REG(sc_uint<1>, 1, vfb_writer_controlled_drop_repeat_on);
            sc_uint<VFB_WRITER_CTRL_INTERFACE_WIDTH> vfb_writer_number_repeats;
            bool msg_controlled_drop_repeat_on;
            sc_uint<VFB_WRITER_CTRL_INTERFACE_WIDTH> msg_number_repeats;
        #endif
    #endif

    // For buffering of user packets
    #if VFB_MAX_NUMBER_PACKETS
        // The address of the first packet for the current buffer
        sc_uint<VFB_MEM_ADDR_WIDTH> vfb_writer_packet_base_address;
        // Length of the packets in samples
        DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)>, LOG2G(VFB_MAX_SAMPLES_IN_PACKET), vfb_writer_packets_sample_length, VFB_MAX_NUMBER_PACKETS);
        // Length of the packets in words
        DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(VFB_MAX_WORDS_IN_PACKET)>, LOG2G(VFB_MAX_WORDS_IN_PACKET), vfb_writer_packets_word_length, VFB_MAX_NUMBER_PACKETS);
        // Base address for each packet
        DECLARE_VAR_WITH_AU(sc_uint<VFB_MEM_ADDR_WIDTH>, VFB_MEM_ADDR_WIDTH, vfb_writer_packet_write_address);
        // The first packet to send (corresponds to an address), this counter wraps around in case of overflow
        DECLARE_VAR_WITH_AU(sc_uint<VFB_PACKET_ID_WIDTH>, VFB_PACKET_ID_WIDTH, vfb_writer_first_packet_id);
        // The last packet written, stays to MAX_NUMBER_PACKETS when overflowing
        DECLARE_VAR_WITH_AU(sc_uint<LOG2G(VFB_MAX_NUMBER_PACKETS)>, LOG2G(VFB_MAX_NUMBER_PACKETS), vfb_writer_next_to_last_packet_id);
        // Counters to detect and flag overflow condition
        DECLARE_VAR_WITH_AU(sc_int<1+VFB_PACKET_ID_WIDTH>, 1+VFB_PACKET_ID_WIDTH, vfb_writer_overflow_trigger);
        DECLARE_VAR_WITH_REG(sc_uint<1>, 1, vfb_writer_overflow_flag);
        // Registers to pass the information from vfb_writer to vfb_reader if not synchronized
        #if VFB_IS_TRIPLE_BUFFER
            DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)>, LOG2G(VFB_MAX_SAMPLES_IN_PACKET), msg_packets_sample_length, VFB_MAX_NUMBER_PACKETS);
            DECLARE_ARRAY_WITH_REG(sc_uint<LOG2G(VFB_MAX_WORDS_IN_PACKET)>, LOG2G(VFB_MAX_WORDS_IN_PACKET), msg_packets_word_length, VFB_MAX_NUMBER_PACKETS);
            sc_uint<VFB_PACKET_ID_WIDTH> msg_first_packet;
            sc_uint<LOG2G(VFB_MAX_NUMBER_PACKETS)> msg_next_to_last_packet;
        #endif
    #endif

    // Declare all variables necessary to store frames into memory
    sc_uint<LOG2(VFB_NUMBER_BUFFERS)> vfb_writer_buffer;
    // These variables are also used for buffering user packets
    DECLARE_VAR_WITH_AU(sc_uint<VFB_LENGTH_COUNTER_WIDTH>, VFB_LENGTH_COUNTER_WIDTH, vfb_writer_length_counter);
    DECLARE_VAR_WITH_AU(sc_uint<VFB_WORD_COUNTER_WIDTH>, VFB_WORD_COUNTER_WIDTH, vfb_writer_word_counter);
    // Triggers each time the SAMPLES_IN_WORDS elements have gone into a word
    DECLARE_VAR_WITH_AU(sc_int<VFB_TRIGGER_COUNTER_WIDTH>, VFB_TRIGGER_COUNTER_WIDTH, vfb_writer_word_counter_trigger);

    // Prepare inclusion of vip_packet_buffering to deal with writing packets to memory
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, vfb_writer_field_width);
    #define PACKET_BUF_WIDTH_VAR vfb_writer_field_width
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, vfb_writer_field_height);
    #define PACKET_BUF_HEIGHT_VAR vfb_writer_field_height
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, vfb_writer_field_interlace);
    #define PACKET_BUF_INTERLACING_VAR vfb_writer_field_interlace
    DECLARE_VAR_WITH_REG(bool, 1, vfb_writer_break_flow);
    #define PACKET_BUF_HAS_CHANGED_VAR vfb_writer_break_flow
    #define PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE false

    // We also need to save the number of samples and height of the first interlaced field while processing the second.
    #if VFB_INTERLACED_SUPPORT
        DECLARE_VAR_WITH_REG(sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)>, LOG2G(VFB_MAX_SAMPLES_IN_FRAME), field_samples_store);
        DECLARE_VAR_WITH_REG(sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)>, LOG2G(VFB_MAX_WORDS_IN_FRAME), field_words_store);
        DECLARE_VAR_WITH_REG(sc_uint<4*HEADER_WORD_BITS>, 4*HEADER_WORD_BITS, field_height_store);
    #endif

    #if VFB_DROP_INVALID_FIELDS
        #define VFB_SAMPLES_WIDTH ((HEADER_WORD_BITS*4) + ((VFB_CHANNELS_IN_SEQ == 1) ? 0 : ((VFB_CHANNELS_IN_SEQ == 2) ? 1 : 2)))
        sc_uint<VFB_SAMPLES_WIDTH> vfb_samples_width;
        DECLARE_VAR_WITH_AU(sc_int<VFB_SAMPLES_WIDTH+1>, VFB_SAMPLES_WIDTH+1, vfb_check_samples_width);
        DECLARE_VAR_WITH_AU(sc_int<HEADER_WORD_BITS*4+1>, HEADER_WORD_BITS*4+1, vfb_check_field_height);
    #endif


    // write_address, to track the address to write to in memory
    DECLARE_VAR_WITH_AU(sc_uint<VFB_MEM_ADDR_WIDTH>, VFB_MEM_ADDR_WIDTH, vfb_writer_write_address);

    DECLARE_VAR_WITH_REG(sc_uint<VFB_BPS_PAR>, VFB_BPS_PAR, vfb_writer_just_read);
    #define PACKET_BUF_JUST_READ_VAR vfb_writer_just_read

    #define PACKET_BUF_MAX_NUMBER_PACKETS VFB_MAX_NUMBER_PACKETS
    #if VFB_MAX_NUMBER_PACKETS
        // Following variables will be used by vip_packet_buffering.hpp if we buffer the packets to memory
        #define PACKET_BUF_MAX_WORDS_IN_PACKET VFB_MAX_WORDS_IN_PACKET
        #define PACKET_BUF_WORDS_IN_ALIGNED_PACKET VFB_WORDS_IN_ALIGNED_PACKET
        #define PACKET_BUF_BURST_TARGET VFB_WDATA_BURST_TARGET
        #define PACKET_BUF_ADDR_WIDTH VFB_MEM_ADDR_WIDTH
        #define PACKET_BUF_WORD_BYTES VFB_WORD_BYTES
        #define PACKET_BUF_LENGTH_COUNTER vfb_writer_length_counter
        #define PACKET_BUF_WORD_COUNTER vfb_writer_word_counter
        #define PACKET_BUF_WORD_COUNTER_WIDTH VFB_WORD_COUNTER_WIDTH
        #define PACKET_BUF_TRIGGER_COUNTER vfb_writer_word_counter_trigger
        #define PACKET_BUF_TRIGGER_COUNTER_WIDTH VFB_TRIGGER_COUNTER_WIDTH
        #define PACKET_BUF_SAMPLES_IN_WORD VFB_SAMPLES_IN_WORD
        #define PACKET_BUF_BASE_ADDRESS vfb_writer_packet_base_address
        #define PACKET_BUF_CURRENT_ADDRESS vfb_writer_packet_write_address
        #define PACKET_BUF_OVERFLOW_TRIGGER vfb_writer_overflow_trigger
        #define PACKET_BUF_OVERFLOW_FLAG vfb_writer_overflow_flag
        #define PACKET_BUF_WRITE_ADDRESS vfb_writer_write_address
        #define PACKET_BUF_FIRST_PACKET vfb_writer_first_packet_id
        #define PACKET_BUF_NEXT_TO_LAST_PACKET vfb_writer_next_to_last_packet_id
        #define PACKET_BUF_LENGTH_ARRAY vfb_writer_packets_sample_length
        #define PACKET_BUF_WORD_ARRAY vfb_writer_packets_word_length
    #endif

    #define PACKET_BUF_BPS VFB_BPS
    #define PACKET_BUF_CHANNELS_IN_PAR VFB_CHANNELS_IN_PAR
    #include "vip_packet_buffering.hpp"

    void vfb_writer()
    {
        HW_DEBUG_MSG("vfb_writer, initialisation" << std::endl);

        // initialised buffer to INITIAL_WRITE
        vfb_writer_buffer = sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(INITIAL_WRITE);

        write_to_read_buf = false;
        write_to_read_ack = false;

        #if VFB_WRITER_RUNTIME_CONTROL
            DECLARE_VAR_WITH_AU(sc_uint<VFB_WRITER_CTRL_INTERFACE_WIDTH>, VFB_WRITER_CTRL_INTERFACE_WIDTH,
                                        writer_control_counter);
            // set Go bit to zero, because start up state of memory mapped slaves is undefined
            writer_control->writeUI(VFB_WRITER_CTRL_Go_ADDRESS, 0);
            writer_control->writeUI(VFB_WRITER_CTRL_Count_ADDRESS, 0);
            writer_control->writeUI(VFB_WRITER_CTRL_Drop_ADDRESS, 0);
        #endif

        vfb_writer_field_width = sc_uint<4*HEADER_WORD_BITS>(VFB_MAX_WIDTH);
        vfb_writer_field_height = sc_uint<4*HEADER_WORD_BITS>(VFB_MAX_HEIGHT);
        vfb_writer_field_interlace = sc_uint<HEADER_WORD_BITS>(3); // progressive nibble

        for (;;)
        {
            #if VFB_MAX_NUMBER_PACKETS
                // Resetting packet_write_address to correct address for the new frame
                #if VFB_IS_TRIPLE_BUFFER
                    vfb_writer_packet_base_address = (vfb_writer_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ? VFB_FRAMEBUFFER0_ADDR :
                               ((vfb_writer_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(1)) ? VFB_FRAMEBUFFER1_ADDR : VFB_FRAMEBUFFER2_ADDR);
                #else
                    vfb_writer_packet_base_address = (vfb_writer_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ?
                               VFB_FRAMEBUFFER0_ADDR : VFB_FRAMEBUFFER1_ADDR;
                #endif

                vfb_writer_next_to_last_packet_id = 0;
                vfb_writer_first_packet_id = 0;
                vfb_writer_overflow_flag = false;
                vfb_writer_overflow_trigger = sc_int<1>(-1);
                for (unsigned int k = 0; k < VFB_MAX_NUMBER_PACKETS; ++k)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    vfb_writer_packets_sample_length[k] = 0;
                    vfb_writer_packets_word_length[k] = 0;
                }
            #endif
            // write_address itself is re-initialised when starting a new frame, no need to do it here

            #if VFB_DROP_FRAMES || VFB_DROP_INVALID_FIELDS
                bool drop;
            #endif

            #if VFB_INTERLACED_SUPPORT
                bool waiting_for_second_field = false;
                bool skip_image;
                bool is_first_field;
                bool is_sync_field;
            #else
                const bool waiting_for_second_field = false;
                const bool skip_image = false;
                const bool is_first_field = true;
                const bool is_sync_field = true;
            #endif
            #if VFB_CONTROLLED_DROP_REPEAT
                bool quick_drop = false;
            #else
                const bool quick_drop = false;
            #endif

            // This is a do while loop until the frame is not dropped, and we have the two fields we need
#if VFB_DROP_FRAMES || VFB_INTERLACED_SUPPORT || VFB_DROP_INVALID_FIELDS
            bool loop_repeat;
            do
            {
#endif
                // Switch interlace flag in case there is no control packet with next field
                vfb_writer_field_interlace = (vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT),
                                vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) ^ vfb_writer_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                vfb_writer_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT), vfb_writer_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT));

                /**************************************** Process the packets that precede the image data ***************************************/
                HW_DEBUG_MSG("vfb_writer, starting new frame on buffer " << vfb_writer_buffer << std::endl);
                // vfb_writer_break_flow will be set to true if a ctrl packet is received and the width has changed or the interlace flag is not as expected
                vfb_writer_break_flow = false;
                handleNonImagePackets();

                // (re)set write address to start of chosen write frame unless this is the second interlaced field of a frame
                sc_uint<VFB_MEM_ADDR_WIDTH> vfb_writer_base_write_address BIND(ALT_WIRE);
                vfb_writer_base_write_address = (vfb_writer_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ? VFB_IMAGE0_ADDR :
                            (!VFB_IS_TRIPLE_BUFFER || (vfb_writer_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(1)) ? VFB_IMAGE1_ADDR : VFB_IMAGE2_ADDR);
                #if VFB_INTERLACED_SUPPORT
                    waiting_for_second_field = waiting_for_second_field && !vfb_writer_break_flow;
                    vfb_writer_write_address = vfb_writer_write_address_AU.addSubSLdUI(vfb_writer_base_write_address, VFB_IMAGE_BUFFER_SIZE/2,
                            vfb_writer_base_write_address, !waiting_for_second_field, false);
                    // Skip the first field of an interlaced frame if the sync flag is set and equal to the field received
                    is_first_field = !vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) || !waiting_for_second_field;
                    is_sync_field = !vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) || waiting_for_second_field;
                    skip_image = !is_sync_field &&
                                      !vfb_writer_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT) &&
                                      (vfb_writer_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) == vfb_writer_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT));
                #else
                    vfb_writer_write_address = vfb_writer_base_write_address;
                #endif

                /**************************************** Process the video data ************************************************************/
                #if VFB_WRITER_RUNTIME_CONTROL
                    // Clear the status bit
                    writer_control->writeUI(VFB_WRITER_CTRL_Status_ADDRESS, 0);
                    // Wait for the GO bit to be 1
                    while (sc_uint<1>(writer_control->readUI(VFB_WRITER_CTRL_Go_ADDRESS)) != sc_uint<1>(1))
                    {
                        writer_control->waitForChange();
                    }
                    #if VFB_CONTROLLED_DROP_REPEAT
                        // parameters should not change between first and second field of a frame
                        vfb_writer_input_frame_rate = vfb_writer_input_frame_rate_REG.cLdUI(writer_control->readUI(VFB_WRITER_CTRL_InputFrameRate_ADDRESS), vfb_writer_input_frame_rate, is_first_field);
                        vfb_writer_output_frame_rate = vfb_writer_output_frame_rate_REG.cLdUI(writer_control->readUI(VFB_WRITER_CTRL_OutputFrameRate_ADDRESS), vfb_writer_output_frame_rate, is_first_field);
                        vfb_writer_controlled_drop_repeat_on = vfb_writer_controlled_drop_repeat_on_REG.cLdUI(writer_control->readUI(VFB_WRITER_CTRL_LockDropRepeat_ADDRESS), vfb_writer_controlled_drop_repeat_on, is_first_field);
                    #endif
                    // Set Status bit back to 1 while processing video data
                    writer_control->writeUI(VFB_WRITER_CTRL_Status_ADDRESS, 1);
                #endif

                #if VFB_CONTROLLED_DROP_REPEAT
                    // Decide how many times the field/frame has to be repeated or if it has to be dropped
                    bool input_rate_larger BIND(ALT_WIRE);
                    input_rate_larger = vfb_writer_output_frame_rate < vfb_writer_input_frame_rate;

                    // Reinit errors in case of break_flow
                    drop_error = drop_error_AU.cLdSI(0, drop_error, !vfb_writer_controlled_drop_repeat_on || vfb_writer_break_flow || !input_rate_larger);
                    repeat_error = repeat_error_AU.cLdSI(0, repeat_error, !vfb_writer_controlled_drop_repeat_on || vfb_writer_break_flow || input_rate_larger);

                    // Reevaluate skip_image for a controlled frame rate conversion
                    HW_DEBUG_MSG("vfb_writer, frame rate control init state: drop_error=" << drop_error << ", repeat_error=" << repeat_error << std::endl);

                    // Starting with the drop
                    bool drop_error_trigger = drop_error.bit(VFB_WRITER_CTRL_INTERFACE_WIDTH); // drop_error < 0, this usually means we should drop
                    // drop_error_trigger is maintained for the second field of an interlaced frame

                    // When support for interlaced field is on, frame rate conversion operates at the frame level and specific actions are taken on the
                    // second field
                    drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1>(vfb_writer_input_frame_rate),
                                                                drop_error, !drop_error_trigger && !skip_image && is_sync_field, true);
                    // drop_error is increased each iteration (only for the second field of an interlaced frame)
                    drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1>(vfb_writer_output_frame_rate),
                                                                                     drop_error, !skip_image && is_sync_field, false);

                    // Now for the repeat, repeat_error is decreased at each iteration when a frame goes through
                    vfb_writer_number_repeats = 0;
                    repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                   sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1>(vfb_writer_output_frame_rate),
                                   repeat_error, !skip_image && is_sync_field, true);
                    // There is always at least 1 repeat
                    do
                    {
                        // Increase repeat_error for each field going through with interlaced support, repeat_error should not be affected
                        //  by the passage of the first field of an interlaced frame and we wait for the second one
                        repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                            sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1>(vfb_writer_input_frame_rate),
                                            repeat_error, !skip_image && is_sync_field, false);
                        // repeat_error should remain >= 0 from previous iteration
                        vip_assert(is_sync_field || !repeat_error.bit(VFB_WRITER_CTRL_INTERFACE_WIDTH));
                        ++vfb_writer_number_repeats;
                    } while (repeat_error.bit(VFB_WRITER_CTRL_INTERFACE_WIDTH) && !skip_image); // while repeat_error >= 0, 1 iter only if skip_image
                    vip_assert(vfb_writer_number_repeats != 0); // vfb_writer_number_repeats >= 1
                    HW_DEBUG_MSG("vfb_writer, frame rate control end state: drop_error=" << drop_error
                                      << ", repeat_error=" << repeat_error << " (x" << vfb_writer_number_repeats << ")" << std::endl);
                    HW_DEBUG_MSG_COND(!skip_image && drop_error_trigger, "vfb_writer, field dropped by the frame rate control routine" << std::endl);
                    quick_drop = vfb_writer_controlled_drop_repeat_on && drop_error_trigger; // Dropping all fields until drop_error goes above 0
                #endif

                HW_DEBUG_MSG_COND(quick_drop, "vfb_writer, quick dropping incoming frame/field" << std::endl);
                HW_DEBUG_MSG_COND(skip_image, "vfb_writer, skipping image, unexpected interlaced field" << std::endl);
                HW_DEBUG_MSG_COND(!quick_drop && !skip_image, "vfb_writer, receiving image data in buffer " << vfb_writer_buffer << " addr " << vfb_writer_write_address << std::endl);

                // Write image data to the buffer
                vfb_writer_length_counter = 0;
                vfb_writer_word_counter = 0;
                vfb_writer_word_counter_trigger = VFB_SAMPLES_IN_WORD - 1;
                bool no_image = din->getEndPacket() || skip_image || quick_drop;
                #if VFB_DROP_INVALID_FIELDS
                    #if (VFB_CHANNELS_IN_SEQ == 1)
                        vfb_samples_width = sc_uint<VFB_SAMPLES_WIDTH>(vfb_writer_field_width);
                    #elif (VFB_CHANNELS_IN_SEQ == 2)
                        vfb_samples_width = sc_uint<VFB_SAMPLES_WIDTH>(vfb_writer_field_width) << 1;
                    #elif (VFB_CHANNELS_IN_SEQ == 3)
                        vfb_samples_width = sc_uint<VFB_SAMPLES_WIDTH>(sc_uint<VFB_SAMPLES_WIDTH>(vfb_writer_field_width) << 1) +
												sc_uint<VFB_SAMPLES_WIDTH>(vfb_writer_field_width);
                    #else //VFB_CHANNELS_IN_SEQ == 4
                        vfb_samples_width = sc_uint<VFB_SAMPLES_WIDTH>(vfb_writer_field_width) << 2;
                    #endif
                    vfb_check_samples_width = sc_int<1>(-1);
                    vfb_check_field_height = sc_int<4*HEADER_WORD_BITS+1>(vfb_writer_field_height) + sc_int<1>(-1);
                    DECLARE_VAR_WITH_REG(bool, 1, sizeMismatch);
                    sizeMismatch = false;
                #endif
                while (!din->getEndPacket())
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 3);
                    ALT_ATTRIB(ALT_SKIDDING, true);

                    // Did we write the last sample of a word?
                    bool word_counter_trigger_flag BIND(ALT_WIRE) = vfb_writer_word_counter_trigger.bit(VFB_TRIGGER_COUNTER_WIDTH-1);

                    // Did we write the last sample before overflow?
                    bool overflow_flag BIND(ALT_WIRE);
                    #if VFB_INTERLACED_SUPPORT
                        vip_assert(IS_EVEN(VFB_MAX_WORDS_IN_FRAME));
                        overflow_flag = vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                                (vfb_writer_word_counter == sc_uint<VFB_WORD_COUNTER_WIDTH>((VFB_MAX_WORDS_IN_FRAME/2) - 1)) :
                                (vfb_writer_word_counter == sc_uint<VFB_WORD_COUNTER_WIDTH>(VFB_MAX_WORDS_IN_FRAME-1));
                    #else
                        overflow_flag = (vfb_writer_word_counter == sc_uint<VFB_WORD_COUNTER_WIDTH>(VFB_MAX_WORDS_IN_FRAME-1));
                    #endif
                    overflow_flag = overflow_flag && word_counter_trigger_flag;

                    // Are we writting data this iteration?
                    bool active_write_flag BIND(ALT_WIRE) = !overflow_flag && !din->getEndPacket() && !no_image;

                    #if VFB_DROP_INVALID_FIELDS
                        // running past expected eop? set oversize to true...
                        sizeMismatch = sizeMismatch_REG.cLdUI(sizeMismatch ||
                                                (vfb_check_samples_width.bit(VFB_SAMPLES_WIDTH) && vfb_check_field_height.bit(4*HEADER_WORD_BITS)),
                                                 sizeMismatch, !din->getEndPacket());

                        // --vfb_check_samples_width; (or reset at vfb_samples_width - 2)
                        vfb_check_samples_width = vfb_check_samples_width_AU.cAddSubSLdSI(vfb_check_samples_width, sc_int<1>(-1),
                                                                                        sc_int<VFB_SAMPLES_WIDTH+1>(vfb_samples_width) + sc_int<2>(-2),
                                                                                        vfb_check_samples_width,
                                                                                        !din->getEndPacket(),
                                                                                        vfb_check_samples_width.bit(VFB_SAMPLES_WIDTH),
                                                                                        false);
                        //if (vfb_check_samples_width==-1) then --vfb_check_field_height;
                        vfb_check_field_height = vfb_check_field_height_AU.cAddSubSI(vfb_check_field_height, sc_int<1>(-1), vfb_check_field_height,
                                                         vfb_check_samples_width.bit(VFB_SAMPLES_WIDTH) && !din->getEndPacket(), false);

                    #endif

                    // Increment word_counter by 1 each time the trigger reaches -1 (unless this is not an active write cycle)
                    vfb_writer_word_counter = vfb_writer_word_counter_AU.cAddSubUI(vfb_writer_word_counter,
                                                             sc_uint<1>(1), vfb_writer_word_counter,
                                                             active_write_flag && word_counter_trigger_flag,
                                                             false);
                    // Cycle word_counter_trigger and increase number of words if necessary
                    vfb_writer_word_counter_trigger = vfb_writer_word_counter_trigger_AU.cAddSubSLdSI(
                               vfb_writer_word_counter_trigger, sc_int<1>(-1),            // General case, --word_counter_trigger
                               VFB_SAMPLES_IN_WORD - 2,                                   // -1 reached previous iteration? reinitialise and count the write
                               vfb_writer_word_counter_trigger,                           // Stay at current value if !enable
                               active_write_flag,                                         // Enable line
                               word_counter_trigger_flag,                                 // sLd line, reinit if word_counter_trigger == -1 (unless enable is false)
                                false);                                                   // Always add -1

                    vfb_writer_just_read = din->cRead(!din->getEndPacket());

                    // Increment length_counter if !eop (and if new sample can be written)
                    vfb_writer_length_counter = vfb_writer_length_counter_AU.cAddSubUI(vfb_writer_length_counter, sc_uint<1>(1),
                                                                  vfb_writer_length_counter, active_write_flag, false);

                    if (active_write_flag)
                    {
                        write_master->writePartialDataUI(vfb_writer_just_read);
                    }

                    // Time to post a full burst?
                    // Post a new burst when writing the first sample of the last word of a burst in the current iteration
                    bool burst_trigger = sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(vfb_writer_word_counter) == sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(VFB_WDATA_BURST_TARGET-1) && word_counter_trigger_flag;

                    // word_counter_trigger_flag is true if we finished a word PREVIOUS iteration,
                    // Consequently, post a new burst if we are about to write a sample for the last word of
                    // a burst
                    if (active_write_flag && burst_trigger)
                    {
                        HW_DEBUG_MSG("vfb_writer, posting burst " << VFB_WDATA_BURST_TARGET << " at addr " << vfb_writer_write_address << std::endl);
                        write_master->busPostWriteBurst(vfb_writer_write_address, VFB_WDATA_BURST_TARGET);
                        vfb_writer_write_address += (VFB_WDATA_BURST_TARGET << LOG2(VFB_WORD_BYTES));
                    }
                }

                // Check that eop was reached as expected
                #if VFB_DROP_INVALID_FIELDS
                    sizeMismatch = sizeMismatch || !(vfb_check_samples_width.bit(VFB_SAMPLES_WIDTH) && vfb_check_field_height.bit(4*HEADER_WORD_BITS));
                #endif

                // Finish and count the last word
                write_master->flush();

                // Is there a need for a last burst?
                bool no_last_burst = (sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(vfb_writer_word_counter) ==
                                       sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(VFB_WDATA_BURST_TARGET-1)) || no_image;

                if (!no_image)
                {
                    ++vfb_writer_word_counter;
                }

                // Post the last burst (probably the first in most cases), truncate word_counter to get the size
                if (!no_last_burst)
                {
                    HW_DEBUG_MSG("vfb_writer, posting last burst " << sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(vfb_writer_word_counter)
                                 << " at addr " << vfb_writer_write_address << std::endl);
                    write_master->busPostWriteBurst(vfb_writer_write_address, sc_uint<LOG2(VFB_WDATA_BURST_TARGET)>(vfb_writer_word_counter));
                }

                HW_DEBUG_MSG_COND(!no_image, "vfb_writer, image data of length " << vfb_writer_length_counter << ", "
                               << vfb_writer_word_counter << " words, received (excluding discard)" << std::endl);

                #if VFB_INTERLACED_SUPPORT
                    // Transfer vfb_writer_field_height to field_height_store (even if it is a progressive frame) unless this was the second field of a frame
                    field_height_store = field_height_store_REG.cLdUI(vfb_writer_field_height, field_height_store, !skip_image && !waiting_for_second_field);
                    #if VFB_DROP_INVALID_FIELDS
                        waiting_for_second_field = vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) && !skip_image && !sizeMismatch && !waiting_for_second_field;
                    #else
                        waiting_for_second_field = vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) && !skip_image && !waiting_for_second_field;
                    #endif
                    // Swap content of registers with content of the store,
                    // for the first field this stores the current length in samples, in words, and the height
                    // for the second field this load back the parameters of the first field in the main counters
                    // and it puts the parameters of the second field in store.
                    sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)> field_samples_wire;
                    sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> field_words_wire;
                    field_samples_wire = vfb_writer_length_counter;
                    field_words_wire = vfb_writer_word_counter;
                    vfb_writer_length_counter = vfb_writer_length_counter_AU.cLdUI(field_samples_store, vfb_writer_length_counter, vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT));
                    vfb_writer_word_counter = vfb_writer_word_counter_AU.cLdUI(field_words_store, vfb_writer_word_counter, vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT));
                    field_samples_store = field_samples_store_REG.cLdUI(field_samples_wire, field_samples_store, vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT));
                    field_words_store = field_words_store_REG.cLdUI(field_words_wire, field_words_store, vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT));
                    HW_DEBUG_MSG_COND(waiting_for_second_field, "vfb_writer, waiting for second field of interlaced frame" << std::endl);
                #endif
                #if VFB_DROP_FRAMES
                    #if VFB_DROP_INVALID_FIELDS
                        HW_DEBUG_MSG_COND(sizeMismatch, "vfb_writer, mismatch between ctrl packet size and eop detected" << std::endl);
                        HW_DEBUG_MSG_COND(!sizeMismatch, "vfb_writer, field is valid" << std::endl);
                        #if VFB_CONTROLLED_DROP_REPEAT
                            drop = sizeMismatch || (vfb_writer_controlled_drop_repeat_on ? quick_drop : (read_to_write_buf == write_to_read_ack));
                        #else
                            drop = sizeMismatch || (read_to_write_buf == write_to_read_ack);
                        #endif
                    #else
                        #if VFB_CONTROLLED_DROP_REPEAT
                            drop = vfb_writer_controlled_drop_repeat_on ? quick_drop : (read_to_write_buf == write_to_read_ack);
                        #else
                            drop = (read_to_write_buf == write_to_read_ack);
                        #endif
                    #endif
                #else
                    #if VFB_DROP_INVALID_FIELDS
                        HW_DEBUG_MSG_COND(sizeMismatch, "vfb_writer, mismatch between ctrl packet size and eop detected" << std::endl);
                        HW_DEBUG_MSG_COND(!sizeMismatch, "vfb_writer, field is valid" << std::endl);
                        drop = sizeMismatch;
                    #endif
                #endif

                #if (VFB_DROP_FRAMES || VFB_DROP_INVALID_FIELDS) && VFB_INTERLACED_SUPPORT
                {
                    #if VFB_WRITER_RUNTIME_CONTROL
                        writer_control_counter = writer_control->readUI(drop ? VFB_WRITER_CTRL_Drop_ADDRESS : VFB_WRITER_CTRL_Count_ADDRESS);
                        // Skip counter increment if this is the first field of an interlaced frame
                        writer_control_counter = writer_control_counter_AU.cAddSubUI(writer_control_counter, 1, writer_control_counter, !waiting_for_second_field, false);
                        writer_control->writeUI(drop ? VFB_WRITER_CTRL_Drop_ADDRESS : VFB_WRITER_CTRL_Count_ADDRESS, writer_control_counter);
                    #endif
                    HW_DEBUG_MSG_COND(!waiting_for_second_field && drop && !skip_image && !quick_drop, "vfb_writer, new frame dropped" << std::endl);
                    loop_repeat = waiting_for_second_field || drop || skip_image;
                }
                #elif (VFB_DROP_FRAMES || VFB_DROP_INVALID_FIELDS)
                {
                    #if VFB_WRITER_RUNTIME_CONTROL
                        writer_control_counter = writer_control->readUI(drop ? VFB_WRITER_CTRL_Drop_ADDRESS : VFB_WRITER_CTRL_Count_ADDRESS);
                        // Skip counter increment if this is the first field of an interlaced frame
                        writer_control_counter = writer_control_counter_AU.addUI(writer_control_counter, 1);
                        writer_control->writeUI(drop ? VFB_WRITER_CTRL_Drop_ADDRESS : VFB_WRITER_CTRL_Count_ADDRESS, writer_control_counter);
                    #endif
                    HW_DEBUG_MSG_COND(drop && !quick_drop, "vfb_writer, new frame dropped" << std::endl);
                    loop_repeat = drop;
                }
                #elif VFB_INTERLACED_SUPPORT
                {
                    #if VFB_WRITER_RUNTIME_CONTROL
                        writer_control_counter = writer_control->readUI(VFB_WRITER_CTRL_Count_ADDRESS);
                        // Skip counter increment if this is the first field of an interlaced frame
                        writer_control_counter = writer_control_counter_AU.cAddSubUI(writer_control_counter, 1, writer_control_counter, !waiting_for_second_field, false);
                        writer_control->writeUI(VFB_WRITER_CTRL_Count_ADDRESS, writer_control_counter);
                    #endif
                    loop_repeat = waiting_for_second_field || skip_image;
                }
                #else // !VFB_INTERLACED_SUPPORT && !VFB_DROP_FRAMES/VFB_DROP_INVALID_FIELDS
                      //  fields/frames cannot be dropped and there is no do...while loop
                {
                    #if VFB_WRITER_RUNTIME_CONTROL
                        writer_control_counter = writer_control->readUI(VFB_WRITER_CTRL_Count_ADDRESS);
                        writer_control_counter = writer_control_counter_AU.addUI(writer_control_counter, 1);
                        writer_control->writeUI(VFB_WRITER_CTRL_Count_ADDRESS, writer_control_counter);
                    #endif
                }
                #endif
#if VFB_DROP_FRAMES || VFB_INTERLACED_SUPPORT || VFB_DROP_INVALID_FIELDS
            } while (loop_repeat);
#endif

            while (write_to_read_buf != read_to_write_ack) // vfb_reader has not dealt with the last buffer yet.
            {
                wait(read_to_write_ack_event);
            }

            HW_DEBUG_MSG("vfb_writer, new frame is kept and given to vfb_reader" << std::endl);
            #if VFB_MAX_NUMBER_PACKETS
                HW_DEBUG_MSG("vfb_writer, along with " << vfb_writer_next_to_last_packet_id << " AvST user packets, "
                                 << "starting at " << vfb_writer_first_packet_id << std::endl);
            #endif

            // Transmit important data along with buffer id (if !VFB_IS_TRIPLE_BUFFER, threads are synchronized and there is no need for storage)
            #if VFB_IS_TRIPLE_BUFFER
            {
                msg_buffer = vfb_writer_buffer;
                msg_field_width = vfb_writer_field_width;
                msg_field_interlace = vfb_writer_field_interlace;
                msg_samples_in_field  = vfb_writer_length_counter;
                msg_words_in_field = vfb_writer_word_counter;
                #if VFB_INTERLACED_SUPPORT
                {
                    msg_samples_in_field2 = field_samples_store;
                    msg_words_in_field2 = field_words_store;
                    msg_field_height = field_height_store;       // field_height_store contains the height of first field (and unique field if progressive)
                    msg_field_height2 = vfb_writer_field_height; // height of the second field if there was one
                }
                #else
                    msg_field_height = vfb_writer_field_height;
                #endif
                #if VFB_MAX_NUMBER_PACKETS
                {
                    msg_first_packet = vfb_writer_first_packet_id;
                    msg_next_to_last_packet = vfb_writer_next_to_last_packet_id;
                    for (unsigned int k = 0; k < VFB_MAX_NUMBER_PACKETS; ++k)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        msg_packets_sample_length[k] = vfb_writer_packets_sample_length[k];
                        msg_packets_word_length[k] = vfb_writer_packets_word_length[k];
                    }
                }
                #endif
                #if VFB_CONTROLLED_DROP_REPEAT
                    msg_controlled_drop_repeat_on = vfb_writer_controlled_drop_repeat_on;
                    msg_number_repeats = vfb_writer_number_repeats;
                #endif
            }
            #endif

            // Sending message to reader
            write_to_read_buf = !write_to_read_buf;
            write_to_read_buf_event.notify();

            // Receive a new buffer token from the reader and write on it at the next loop iteration, wait for the buffer if not done already
            #if !VFB_DROP_FRAMES || VFB_CONTROLLED_DROP_REPEAT
            {
                while (read_to_write_buf == write_to_read_ack) // vfb_reader has not sent a new buffer yet
                {
                    wait(read_to_write_buf_event);
                }
            }
            #endif

            // Get new buffer and ack
            // msg_buffer_reply is always declared even with no triple buffering
            vfb_writer_buffer = msg_buffer_reply;
            write_to_read_ack = !write_to_read_ack;
            write_to_read_ack_event.notify();
        }
    }


    // Left-Rotate shift function
    #define VFB_LRS(var, TOTAL_SIZE, SHIFT) \
        if (TOTAL_SIZE > SHIFT) \
            var = sc_biguint<TOTAL_SIZE>((var.range(TOTAL_SIZE-SHIFT-1, 0), var.range(TOTAL_SIZE-1, TOTAL_SIZE-SHIFT)));

    // vfb_reader_field_width, to record the number of columns in received field
    sc_uint<4*HEADER_WORD_BITS> vfb_reader_field_width;
    // vfb_reader_field_height, to record the number of lines in received field
    sc_uint<4*HEADER_WORD_BITS> vfb_reader_field_height;
    // vfb_reader_field_interlace, to record the interlace nibble
    sc_uint<HEADER_WORD_BITS> vfb_reader_field_interlace;

    // Flag to indicate that vfb_reader is sending the second field of a frame
    #if VFB_INTERLACED_SUPPORT
        bool vfb_reader_sending_second_field;
        sc_uint<4*HEADER_WORD_BITS> vfb_reader_field_height2;  // Height of second field
    #endif


    // Write a correct control packet just before image data this function assumes that
    // vfb_reader_field_width, vfb_reader_field_height(2) and vfb_reader_field_interlace
    // have been set correctly
    void output_control_packet()
    {
        // Store the outputs in a shift register to abstract away
        // the fact that they could be written out in parallel or
        // sequence
        static const int N_HEADER_WORDS_TO_SEND = 9;
        ALT_REG<HEADER_WORD_BITS> output_REG[N_HEADER_WORDS_TO_SEND];
        sc_uint<HEADER_WORD_BITS> output[N_HEADER_WORDS_TO_SEND] BIND(output_REG);

        HW_DEBUG_MSG("vfb_reader, sending control packet: " <<
        #if VFB_INTERLACED_SUPPORT
               vfb_reader_field_width << "x" << (vfb_reader_sending_second_field ?
                                  vfb_reader_field_height2 : vfb_reader_field_height) << ", " <<
        #else
                vfb_reader_field_width << "x" << vfb_reader_field_height << ", " <<
        #endif
                (vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                              (vfb_reader_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) ? "F1" : "F0") :
                              "progressive") << std::endl);

        // Send the type first
        dout->writeDataAndEop(CONTROL_HEADER, false);

        // Prepare the width
        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[i] = vfb_reader_field_width.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }
        // Prepare the height
        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            #if VFB_INTERLACED_SUPPORT
                output[4 + i] = vfb_reader_sending_second_field ?
                                    vfb_reader_field_height2.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i)) :
                                    vfb_reader_field_height.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
            #else
                output[4 + i] = vfb_reader_field_height.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
            #endif
        }
        // Prepare the interlacing
        output[8] = vfb_reader_field_interlace;

        // Write out the control packet, packing into wide words for symbols in parallel. If the two
        // do not divide exactly, round up and send an extra word with whatever happens to be in the
        // right place.
        for (unsigned int i = 0; i < (N_HEADER_WORDS_TO_SEND + VFB_CHANNELS_IN_PAR - 1) / VFB_CHANNELS_IN_PAR; ++i)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            sc_uint<VFB_BPS_PAR> thisOutput BIND(ALT_WIRE);
            thisOutput = 0;
            // Pack a word to write out. If the last word doesn't full fill the word, wrap
            // around and write again from the front
            for (int j = VFB_CHANNELS_IN_PAR - 1; j >= 0; j--)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                thisOutput <<= VFB_BPS;
                thisOutput = thisOutput | output[j];
            }

            // Shift the words to write along
            for (unsigned int j = 0; j < N_HEADER_WORDS_TO_SEND - VFB_CHANNELS_IN_PAR; j++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                output[j] = output[j + VFB_CHANNELS_IN_PAR];
            }
            dout->writeDataAndEop(thisOutput, i == (N_HEADER_WORDS_TO_SEND + VFB_CHANNELS_IN_PAR - 1) / VFB_CHANNELS_IN_PAR - 1);
        }
    }

    void vfb_reader()
    {
        HW_DEBUG_MSG("vfb_reader, initialisation" << std::endl);

        // Keep track of the frame to read from
        sc_uint<LOG2(VFB_NUMBER_BUFFERS)> vfb_reader_buffer = INITIAL_STORAGE;

        // read_address and READ_ADDRESS_AU operation on address in memory
        DECLARE_VAR_WITH_AU(sc_uint<VFB_MEM_ADDR_WIDTH>, VFB_MEM_ADDR_WIDTH, vfb_reader_read_address);

        #if VFB_MAX_NUMBER_PACKETS
            DECLARE_VAR_WITH_AU(sc_uint<VFB_MEM_ADDR_WIDTH>, VFB_MEM_ADDR_WIDTH, vfb_reader_packet_read_address);
            // Keep a record of the base address so that we know where to wrap around
            sc_uint<VFB_MEM_ADDR_WIDTH> vfb_reader_packet_base_address;
            // What is the first packet to send (usually 0 but this can be different if there was packet overflow)
            DECLARE_VAR_WITH_AU(sc_uint<LOG2G(VFB_MAX_NUMBER_PACKETS)>, LOG2G(VFB_MAX_NUMBER_PACKETS), vfb_reader_current_packet_id);
            sc_uint<LOG2G(VFB_MAX_NUMBER_PACKETS)> vfb_reader_next_to_last_packet_id;
            // Length of the packets in samples, stored in one big register
            sc_biguint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)*VFB_MAX_NUMBER_PACKETS> reader_packets_sample_length;
            // Length of the packets in words, stored in one big register
            sc_biguint<LOG2G(VFB_MAX_WORDS_IN_PACKET)*VFB_MAX_NUMBER_PACKETS> reader_packets_word_length;
        #endif

        #if VFB_CONTROLLED_DROP_REPEAT
            bool vfb_reader_controlled_drop_repeat_on;
            DECLARE_VAR_WITH_AU(sc_int<VFB_WRITER_CTRL_INTERFACE_WIDTH+1>, VFB_WRITER_CTRL_INTERFACE_WIDTH+1, vfb_reader_number_repeats);
        #endif

        // vfb_reader_samples_in_field, to record the number of samples in a field
        sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)> vfb_reader_samples_in_field;
        // field_word, to record the number of words in a frame
        sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> vfb_reader_words_in_field;
        #if VFB_INTERLACED_SUPPORT
            sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_FRAME)> vfb_reader_samples_in_field2; // Number of samples in second field
            sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> vfb_reader_words_in_field2;     // Number of words in second field
        #endif

        sc_int<VFB_LENGTH_COUNTER_WIDTH+1> vfb_reader_length_cnt;  // Length counter for decreasing loops
        sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)> vfb_reader_word_cnt; // Number of words in the current field

        // Add the third buffer token in the list of available buffer if triple-buffering
        read_to_write_ack = false;
        #if VFB_IS_TRIPLE_BUFFER
        {
            msg_buffer_reply = INITIAL_UNUSED;
            read_to_write_buf = true;
            read_to_write_buf_event.notify();
        }
        #else
        {
            read_to_write_buf = false;
        }
        #endif

        #if VFB_READER_RUNTIME_CONTROL
            // An adder to increment counter in memory
            DECLARE_VAR_WITH_AU(sc_uint<VFB_READER_CTRL_INTERFACE_WIDTH>, VFB_READER_CTRL_INTERFACE_WIDTH, reader_control_counter);
            // set Go bit to zero, because start up state of memory mapped slaves is undefined
            reader_control->writeUI(VFB_READER_CTRL_Go_ADDRESS, 0);
            reader_control->writeUI(VFB_READER_CTRL_Count_ADDRESS, 0);
            reader_control->writeUI(VFB_READER_CTRL_Repeat_ADDRESS, 0);
        #endif

        for (;;)
        {
            // Wait for buffer from vfb_writer
            #if !VFB_REPEAT_FRAMES || VFB_CONTROLLED_DROP_REPEAT
                while (write_to_read_buf == read_to_write_ack) // vfb_writer has not sent a buffer yet
                {
                    wait(write_to_read_buf_event);
                }
            #endif

            while (read_to_write_buf != write_to_read_ack) // vfb_writer has not acknowledged the buffer sent previously
            {
                wait(write_to_read_ack_event);
            }

            // Prepare reply ...
            msg_buffer_reply = vfb_reader_buffer;
            // ... and get the message
            #if VFB_MAX_NUMBER_PACKETS
                sc_biguint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)*VFB_MAX_NUMBER_PACKETS>  reader_packets_sample_length_load_wire BIND(ALT_WIRE);
                sc_biguint<LOG2G(VFB_MAX_WORDS_IN_PACKET)*VFB_MAX_NUMBER_PACKETS> reader_packets_word_length_load_wire BIND(ALT_WIRE);
            #endif
            #if VFB_IS_TRIPLE_BUFFER
            {
                vfb_reader_buffer = msg_buffer;
                vfb_reader_field_width = msg_field_width;
                vfb_reader_samples_in_field = msg_samples_in_field;
                vfb_reader_field_height = msg_field_height;
                vfb_reader_words_in_field = msg_words_in_field;
                #if VFB_INTERLACED_SUPPORT
                {
                    vfb_reader_samples_in_field2 = msg_samples_in_field2;
                    vfb_reader_words_in_field2 = msg_words_in_field2;
                    vfb_reader_field_height2 = msg_field_height2;
                    // msg_field_interlace may be the interlace flag of second interlaced field, switch it over
                    vfb_reader_field_interlace = (msg_field_interlace.bit(INTERLACE_FLAG_BIT),
                            msg_field_interlace.bit(INTERLACE_FLAG_BIT) ^ msg_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                            msg_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT), msg_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT));
                }
                #else
                {
                    vfb_reader_field_interlace = msg_field_interlace;
                }
                #endif
                #if VFB_MAX_NUMBER_PACKETS
                {
                    vfb_reader_current_packet_id = msg_first_packet;
                    vfb_reader_next_to_last_packet_id = msg_next_to_last_packet;
                    for (unsigned int k = 0; k < VFB_MAX_NUMBER_PACKETS; ++k)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        reader_packets_sample_length_load_wire = (reader_packets_sample_length_load_wire << LOG2G(VFB_MAX_SAMPLES_IN_PACKET));
                        reader_packets_sample_length_load_wire |= msg_packets_sample_length[k];
                        reader_packets_word_length_load_wire = (reader_packets_word_length_load_wire << LOG2G(VFB_MAX_WORDS_IN_PACKET));
                        reader_packets_word_length_load_wire |= msg_packets_word_length[k];
                    }
                }
                #endif
                #if VFB_CONTROLLED_DROP_REPEAT
                {
                    vfb_reader_controlled_drop_repeat_on = msg_controlled_drop_repeat_on;
                    vfb_reader_number_repeats = vfb_reader_number_repeats_AU.addSubUI(msg_number_repeats, 1, true);
                    HW_DEBUG_MSG_COND(vfb_reader_controlled_drop_repeat_on, "vfb_reader, controlled rate conversion on, " << msg_number_repeats << " repeats requested" << std::endl);
                    HW_DEBUG_MSG_COND(!vfb_reader_controlled_drop_repeat_on, "vfb_reader, controlled rate conversion off, repeating as encessary" << std::endl);
                }
                #endif
            }
            #else
            {
                vfb_reader_buffer = vfb_writer_buffer;
                vfb_reader_field_width = vfb_writer_field_width;
                vfb_reader_samples_in_field = vfb_writer_length_counter;
                vfb_reader_words_in_field = vfb_writer_word_counter;
                #if VFB_INTERLACED_SUPPORT
                {
                    vfb_reader_samples_in_field2 = field_samples_store;
                    vfb_reader_words_in_field2 = field_words_store;
                    vfb_reader_field_height = field_height_store; // field_height_store contains height of the first field to send (prog or interlaced)
                    vfb_reader_field_height2 = vfb_writer_field_height; // height of the 2nd interlaced field if there is one
                    vfb_reader_field_interlace = (vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT),
                            vfb_writer_field_interlace.bit(INTERLACE_FLAG_BIT) ^ vfb_writer_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                            vfb_writer_field_interlace.bit(INTERLACE_SYNC_UNKNOWN_BIT), vfb_writer_field_interlace.bit(INTERLACE_SYNC_FIELD_BIT));
                }
                #else
                {
                    vfb_reader_field_height = vfb_writer_field_height;
                    vfb_reader_field_interlace = vfb_writer_field_interlace;
                }
                #endif
                #if VFB_MAX_NUMBER_PACKETS
                {
                    vfb_reader_current_packet_id = vfb_writer_first_packet_id;
                    vfb_reader_next_to_last_packet_id = vfb_writer_next_to_last_packet_id;
                    for (unsigned int k = 0; k < VFB_MAX_NUMBER_PACKETS; ++k)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        reader_packets_sample_length_load_wire = (reader_packets_sample_length_load_wire << LOG2G(VFB_MAX_SAMPLES_IN_PACKET));
                        reader_packets_sample_length_load_wire |= vfb_writer_packets_sample_length[k];
                        reader_packets_word_length_load_wire = (reader_packets_word_length_load_wire << LOG2G(VFB_MAX_WORDS_IN_PACKET));
                        reader_packets_word_length_load_wire |= vfb_writer_packets_word_length[k];
                    }
                }
                #endif
            }
            #endif
            #if VFB_INTERLACED_SUPPORT
                HW_DEBUG_MSG_COND(vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT),
                               "vfb_reader, starting new frame on buffer " << vfb_reader_buffer << ", dim=" << vfb_reader_field_width
                               << "x(" << vfb_reader_field_height << ',' << vfb_reader_field_height2 << ')' << std::endl);
            #endif
            HW_DEBUG_MSG_COND(!VFB_INTERLACED_SUPPORT || !vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT),
                               "vfb_reader, starting new frame on buffer " << vfb_reader_buffer << ", dim=" << vfb_reader_field_width
                               << 'x' << vfb_reader_field_height << std::endl);
            #if VFB_MAX_NUMBER_PACKETS
                HW_DEBUG_MSG(vfb_reader_next_to_last_packet_id << " user packets." << std::endl);
            #endif


            #if VFB_MAX_NUMBER_PACKETS
            {
                // Align the lsb with packet 0 (ie, left rotate shift by one element)
                VFB_LRS(reader_packets_sample_length_load_wire, LOG2G(VFB_MAX_SAMPLES_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_SAMPLES_IN_PACKET));
                VFB_LRS(reader_packets_word_length_load_wire, LOG2G(VFB_MAX_WORDS_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_WORDS_IN_PACKET));
                reader_packets_sample_length = reader_packets_sample_length_load_wire;
                reader_packets_word_length = reader_packets_word_length_load_wire;
            }
            #endif

            // Acknowledge the message and indicate that the reply (a dirty buffer) is available
            read_to_write_ack = !read_to_write_ack;
            read_to_write_ack_event.notify();
            read_to_write_buf = !read_to_write_buf;
            read_to_write_buf_event.notify();

            /* Send user packets first */
            #if VFB_MAX_NUMBER_PACKETS
            {
                #if VFB_IS_TRIPLE_BUFFER
                {
                    vfb_reader_packet_base_address = (vfb_reader_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ? VFB_FRAMEBUFFER0_ADDR :
                                                  ((vfb_reader_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(1)) ? VFB_FRAMEBUFFER1_ADDR : VFB_FRAMEBUFFER2_ADDR);
                }
                #else
                {
                    vfb_reader_packet_base_address = (vfb_reader_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ? VFB_FRAMEBUFFER0_ADDR : VFB_FRAMEBUFFER1_ADDR;
                }
                #endif
                // Prepare packet_read_address and wrap_packet_id to start with the oldest packet and prepare the "wrap around"
                // if there was overflow
                vfb_reader_packet_read_address = vfb_reader_packet_base_address;
                HW_DEBUG_MSG_COND(vfb_reader_current_packet_id != vfb_reader_next_to_last_packet_id,
                                 "vfb_reader, sending " << vfb_reader_next_to_last_packet_id << " user packet(s), starting from packet id " << vfb_reader_current_packet_id << std::endl);
                // Compute address of the first packet (a bit slow but this should do ok) when there was overflow
                // Also keep a record of where we should wrap the address around
                sc_uint<LOG2G(VFB_MAX_NUMBER_PACKETS)> wrap_packet_id = vfb_reader_next_to_last_packet_id;
                while (vfb_reader_current_packet_id != 0)
                {
                    vfb_reader_packet_read_address = vfb_reader_packet_read_address_AU.addSubSLd(
                            vfb_reader_packet_read_address,
                            sc_uint<VFB_MEM_ADDR_WIDTH>(VFB_WORDS_IN_ALIGNED_PACKET * VFB_WORD_BYTES),
                            vfb_reader_packet_base_address /* don't care */,
                            false,
                            false);
                    vfb_reader_current_packet_id = vfb_reader_current_packet_id_AU.addSubSLdUI(vfb_reader_current_packet_id, sc_uint<1>(1), vfb_reader_current_packet_id, false, true);
                    --wrap_packet_id;
                    // Left-Rotate shift by one element to align the lsb of the length registers with packet_id
                    VFB_LRS(reader_packets_sample_length, LOG2G(VFB_MAX_SAMPLES_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_SAMPLES_IN_PACKET));
                    VFB_LRS(reader_packets_word_length, LOG2G(VFB_MAX_WORDS_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_WORDS_IN_PACKET));
                }

                // Send packets
                while (vfb_reader_current_packet_id != vfb_reader_next_to_last_packet_id)
                {
                    // Get length and number of words
                    sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)> packet_length_counter BIND(ALT_WIRE);
                    packet_length_counter = reader_packets_sample_length.range(LOG2G(VFB_MAX_SAMPLES_IN_PACKET)-1,0);
                    sc_uint<LOG2G(VFB_MAX_SAMPLES_IN_PACKET)> reader_word_counter BIND(ALT_WIRE);
                    reader_word_counter = reader_packets_word_length.range(LOG2G(VFB_MAX_WORDS_IN_PACKET)-1,0);
                    HW_DEBUG_MSG("vfb_reader, sending packet (size = " << packet_length_counter << " * "
                                 << VFB_CHANNELS_IN_PAR << "), from address " << vfb_reader_packet_read_address << std::endl);
                    HW_DEBUG_MSG("vfb_reader, packet length in memory words = " << reader_word_counter << std::endl);
                    // Post the read burst and send the packet
                    read_master->busPostReadBurst(vfb_reader_packet_read_address, reader_word_counter);
                    vfb_reader_length_cnt = packet_length_counter - sc_uint<2>(2);
                    while(!vfb_reader_length_cnt.bit(VFB_LENGTH_COUNTER_WIDTH))
                    {
                        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                        ALT_ATTRIB(ALT_MOD_TARGET, 1);
                        ALT_ATTRIB(ALT_MIN_ITER, 3);
                        ALT_ATTRIB(ALT_SKIDDING, true);
                        if (!vfb_reader_length_cnt.bit(VFB_LENGTH_COUNTER_WIDTH)) // Because we may be violating MIN_ITER condition
                        {
                            dout->writeDataAndEop(read_master->collectPartialReadUI(), false);
                        }
                        --vfb_reader_length_cnt;
                    }
                    dout->writeDataAndEop(read_master->collectPartialReadUI(), true);
                    /* Discard unused data at the end of the last word */
                    read_master->discard();
                    // ++current_packet_id
                    vfb_reader_current_packet_id = vfb_reader_current_packet_id_AU.addSubSLdUI(
                            vfb_reader_current_packet_id, sc_uint<1>(1), vfb_reader_current_packet_id, false, false);
                    // Increment address for next packet or wrap around if necessary
                    vfb_reader_packet_read_address = vfb_reader_packet_read_address_AU.addSubSLd(
                                        vfb_reader_packet_read_address,
                                        sc_uint<VFB_MEM_ADDR_WIDTH>(VFB_WORDS_IN_ALIGNED_PACKET * VFB_WORD_BYTES),
                                        vfb_reader_packet_base_address,
                                        vfb_reader_current_packet_id == wrap_packet_id,
                                        false);
                    // Move to the next set of lengths
                    VFB_LRS(reader_packets_sample_length, LOG2G(VFB_MAX_SAMPLES_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_SAMPLES_IN_PACKET));
                    VFB_LRS(reader_packets_word_length, LOG2G(VFB_MAX_WORDS_IN_PACKET)*VFB_MAX_NUMBER_PACKETS, LOG2G(VFB_MAX_WORDS_IN_PACKET));
                }
            }
            #endif

            #if VFB_REPEAT_FRAMES
                bool repeat;
            #endif
            #if VFB_INTERLACED_SUPPORT
                vfb_reader_sending_second_field = false;
            #endif

#if VFB_REPEAT_FRAMES || VFB_INTERLACED_SUPPORT
            // This is a do while loop until the frame stop being repeated or its 2 fields where sent
            bool loop_repeat;
            do
            {
#endif
                // (re)set write address to start of chosen write frame unless this is the second interlaced field of a frame
                sc_uint<VFB_MEM_ADDR_WIDTH> vfb_reader_base_read_address BIND(ALT_WIRE);
                vfb_reader_base_read_address = (vfb_reader_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(0)) ? VFB_IMAGE0_ADDR :
                            (!VFB_IS_TRIPLE_BUFFER || (vfb_reader_buffer == sc_uint<LOG2(VFB_NUMBER_BUFFERS)>(1)) ? VFB_IMAGE1_ADDR : VFB_IMAGE2_ADDR);
                #if VFB_INTERLACED_SUPPORT
                    // Move to second field or reload address for new buffer
                    vfb_reader_read_address = vfb_reader_read_address_AU.addSubSLdUI(vfb_reader_base_read_address, VFB_IMAGE_BUFFER_SIZE / 2,
                                        vfb_reader_base_read_address, !vfb_reader_sending_second_field, false);
                    vfb_reader_length_cnt = vfb_reader_sending_second_field ? vfb_reader_samples_in_field2 : vfb_reader_samples_in_field;
                    vfb_reader_word_cnt = vfb_reader_sending_second_field ? vfb_reader_words_in_field2 : vfb_reader_words_in_field;
                #else
                    vfb_reader_read_address = vfb_reader_base_read_address;
                    vfb_reader_length_cnt = vfb_reader_samples_in_field;
                    vfb_reader_word_cnt = vfb_reader_words_in_field;
                #endif

                output_control_packet();

                HW_DEBUG_MSG("vfb_reader, sending image data of length " << vfb_reader_length_cnt << " from buffer "
                              << vfb_reader_buffer << " addr " << vfb_reader_read_address << std::endl);

                // Prepare length_cnt for a decreasing loop from samples_in_field - 2 to -1
                --vfb_reader_length_cnt;
                --vfb_reader_length_cnt;

                #if VFB_READER_RUNTIME_CONTROL
                    // Clear the status bit
                    reader_control->writeUI(VFB_READER_CTRL_Status_ADDRESS, 0);
                    // Wait for the GO bit to be 1
                    while (sc_uint<1>(reader_control->readUI(VFB_READER_CTRL_Go_ADDRESS)) != sc_uint<1>(1))
                        reader_control->waitForChange();
                    // Set Status bit back to 1 while processing video data
                    reader_control->writeUI(VFB_READER_CTRL_Status_ADDRESS, 1);
                #endif

                bool empty_image BIND(ALT_WIRE);
                empty_image = (vfb_reader_word_cnt == sc_uint<LOG2G(VFB_MAX_WORDS_IN_FRAME)>(0));

                // Send the image data header
                dout->writeDataAndEop(IMAGE_DATA, empty_image);

                // Send the image
                if (!empty_image)
                {
                    read_master->busPostReadBurst(vfb_reader_read_address, vfb_reader_word_cnt);
                    while (!vfb_reader_length_cnt.bit(VFB_LENGTH_COUNTER_WIDTH))
                    {
                        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                        ALT_ATTRIB(ALT_MOD_TARGET, 1);
                        ALT_ATTRIB(ALT_MIN_ITER, 3);
                        ALT_ATTRIB(ALT_SKIDDING, true);
                        if (!vfb_reader_length_cnt.bit(VFB_LENGTH_COUNTER_WIDTH)) // Because we may be violating MIN_ITER condition
                        {
                            dout->writeDataAndEop(read_master->collectPartialReadUI(), false);
                        }
                        --vfb_reader_length_cnt;
                    }
                    dout->writeDataAndEop(read_master->collectPartialReadUI(), true);
                    /* Discard unused data */
                    read_master->discard();
                }
                HW_DEBUG_MSG("vfb_reader, frame/field sent" << std::endl);


                #if VFB_INTERLACED_SUPPORT
                {
                    // Switch interlace flag if VFB_INTERLACED_SUPPORT is on because interlaced fields are sent by pair of two in this case
                    // if !VFB_INTERLACED_SUPPORT fields are repeated as single entities and interlace flag should remain the same
                    vfb_reader_field_interlace = (vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT),
                            vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                             !vfb_reader_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) : vfb_reader_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                             vfb_reader_field_interlace.range(INTERLACE_FIELD_TYPE_BIT - 1, 0));
                    // Set the sending_second_field flag to true is the second field has to be sent next iteration
                    vfb_reader_sending_second_field = vfb_reader_field_interlace.bit(INTERLACE_FLAG_BIT) && !vfb_reader_sending_second_field;
                    HW_DEBUG_MSG_COND(vfb_reader_sending_second_field, "vfb_reader, first interlaced field sent, now doing second field" << std::endl);
                }
                #endif

                #if VFB_REPEAT_FRAMES
                {
                    #if VFB_CONTROLLED_DROP_REPEAT
                    {
                        #if VFB_INTERLACED_SUPPORT
                            HW_DEBUG_MSG_COND(vfb_reader_controlled_drop_repeat_on && !vfb_reader_sending_second_field, "vfb_reader, controlled rate conversion, still "
                                    << vfb_reader_number_repeats << " frames to go" << std::endl);
                            vfb_reader_number_repeats = vfb_reader_number_repeats_AU.cAddSubSI(vfb_reader_number_repeats, 1, vfb_reader_number_repeats, !vfb_reader_sending_second_field, true);
                        #else
                            HW_DEBUG_MSG_COND(vfb_reader_controlled_drop_repeat_on, "vfb_reader, controlled rate conversion, still " << vfb_reader_number_repeats << " fields/frames to go" << std::endl);
                            vfb_reader_number_repeats = vfb_reader_number_repeats_AU.addSubSI(vfb_reader_number_repeats, 1, true);
                        #endif
                        // Stop repeating when vfb_reader_number_repeats reaches -1
                        repeat = vfb_reader_controlled_drop_repeat_on ? !vfb_reader_number_repeats.bit(VFB_WRITER_CTRL_INTERFACE_WIDTH) : (write_to_read_buf == read_to_write_ack);
                    }
                    #else
                    {
                        // When the msg and ack bits are the same there is no new message and a repeat is necessary
                        repeat = (write_to_read_buf == read_to_write_ack);
                    }
                    #endif
                }
                #endif

                #if VFB_REPEAT_FRAMES && VFB_INTERLACED_SUPPORT
                {
                    #if VFB_READER_RUNTIME_CONTROL
                        reader_control_counter = reader_control->readUI(repeat ? VFB_READER_CTRL_Repeat_ADDRESS : VFB_READER_CTRL_Count_ADDRESS);
                        reader_control_counter = reader_control_counter_AU.cAddSubUI(reader_control_counter, 1, reader_control_counter, !vfb_reader_sending_second_field, false);
                        reader_control->writeUI(repeat ? VFB_READER_CTRL_Repeat_ADDRESS : VFB_READER_CTRL_Count_ADDRESS, reader_control_counter);
                    #endif
                    loop_repeat = repeat || vfb_reader_sending_second_field;
                    HW_DEBUG_MSG_COND(repeat && !vfb_reader_sending_second_field, "vfb_reader, repeating frame" << std::endl);
                }
                #elif VFB_REPEAT_FRAMES
                {
                    #if VFB_READER_RUNTIME_CONTROL
                        reader_control_counter = reader_control->readUI(repeat ? VFB_READER_CTRL_Repeat_ADDRESS : VFB_READER_CTRL_Count_ADDRESS);
                        reader_control_counter = reader_control_counter_AU.addUI(reader_control_counter, 1);
                        reader_control->writeUI(repeat ? VFB_READER_CTRL_Repeat_ADDRESS : VFB_READER_CTRL_Count_ADDRESS, reader_control_counter);
                    #endif
                    loop_repeat = repeat;
                    HW_DEBUG_MSG_COND(repeat, "vfb_reader, repeating frame" << std::endl);
                }
                #elif VFB_INTERLACED_SUPPORT
                {
                    #if VFB_READER_RUNTIME_CONTROL
                        reader_control_counter = reader_control->readUI(VFB_READER_CTRL_Count_ADDRESS);
                        reader_control_counter = reader_control_counter_AU.cAddSubUI(reader_control_counter, 1, reader_control_counter, !vfb_reader_sending_second_field, false);
                        reader_control->writeUI(VFB_READER_CTRL_Count_ADDRESS, reader_control_counter);
                    #endif
                    loop_repeat = vfb_reader_sending_second_field;
                }
                #else // !VFB_INTERLACED_SUPPORT && !VFB_REPEAT_FRAMES, fields/frames cannot be repeated and there is no do...while loop
                {
                    #if VFB_READER_RUNTIME_CONTROL
                        reader_control_counter = reader_control->readUI(VFB_READER_CTRL_Count_ADDRESS);
                        reader_control_counter = reader_control_counter_AU.addUI(reader_control_counter, 1);
                        reader_control->writeUI(VFB_READER_CTRL_Count_ADDRESS, reader_control_counter);
                    #endif
                }
                #endif
#if VFB_REPEAT_FRAMES || VFB_INTERLACED_SUPPORT
            } while (loop_repeat);
#endif
            HW_DEBUG_MSG("vfb_reader, switching to new frame, giving back a buffer token to vfb_writer" << std::endl);
        }
    }

#endif //SYNTH_MODE

    const char* param;
    SC_HAS_PROCESS(VFB_NAME);
    VFB_NAME(sc_module_name name_,
             const char* PARAMETERISATION = "<frameBufferParams><VFB_NAME>MyFrameBuffer</VFB_NAME><VFB_MAX_WIDTH>640</VFB_MAX_WIDTH><VFB_MAX_HEIGHT>480</VFB_MAX_HEIGHT><VFB_BPS>8</VFB_BPS><VFB_CHANNELS_IN_SEQ>3</VFB_CHANNELS_IN_SEQ><VFB_CHANNELS_IN_PAR>1</VFB_CHANNELS_IN_PAR><VFB_WRITER_RUNTIME_CONTROL>0</VFB_WRITER_RUNTIME_CONTROL><VFB_DROP_FRAMES>1</VFB_DROP_FRAMES><VFB_READER_RUNTIME_CONTROL>0</VFB_READER_RUNTIME_CONTROL><VFB_REPEAT_FRAMES>1</VFB_REPEAT_FRAMES><VFB_FRAMEBUFFERS_ADDR>00000000</VFB_FRAMEBUFFERS_ADDR><VFB_MEM_PORT_WIDTH>64</VFB_MEM_PORT_WIDTH><VFB_MEM_MASTERS_USE_SEPARATE_CLOCK>0</VFB_MEM_MASTERS_USE_SEPARATE_CLOCK><VFB_RDATA_FIFO_DEPTH>64</VFB_RDATA_FIFO_DEPTH><VFB_RDATA_BURST_TARGET>32</VFB_RDATA_BURST_TARGET><VFB_WDATA_FIFO_DEPTH>64</VFB_WDATA_FIFO_DEPTH><VFB_WDATA_BURST_TARGET>32</VFB_WDATA_BURST_TARGET><VFB_MAX_NUMBER_PACKETS>0</VFB_MAX_NUMBER_PACKETS><VFB_MAX_SYMBOLS_IN_PACKET>10</VFB_MAX_SYMBOLS_IN_PACKET><VFB_INTERLACED_SUPPORT>0</VFB_INTERLACED_SUPPORT><VFB_CONTROLLED_DROP_REPEAT>0</VFB_CONTROLLED_DROP_REPEAT><VFB_BURST_ALIGNMENT>0</VFB_BURST_ALIGNMENT><VFB_DROP_INVALID_FIELDS>0</VFB_DROP_INVALID_FIELDS></frameBufferParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        //! Data input stream and output stream
        din = new ALT_AVALON_ST_INPUT< sc_uint<VFB_BPS_PAR> >();
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint<VFB_BPS_PAR> >();

        //! A couple of master ports, one for reading and one for writing
        read_master = new ALT_AVALON_MM_MASTER_FIFO<VFB_MEM_PORT_WIDTH, VFB_MEM_ADDR_WIDTH, VFB_READ_MASTER_MAX_BURST, VFB_BPS_PAR>();
        read_master->setWdataBurstSize(0);
        write_master = new ALT_AVALON_MM_MASTER_FIFO<VFB_MEM_PORT_WIDTH, VFB_MEM_ADDR_WIDTH, VFB_WRITE_MASTER_MAX_BURST, VFB_BPS_PAR>();
        write_master->setRdataBurstSize(0);

        //optional ports
        // Runtime control ports
        writer_control = NULL;
        reader_control = NULL;

#ifdef LEGACY_FLOW
#if VFB_WRITER_RUNTIME_CONTROL
        writer_control = new ALT_AVALON_MM_MEM_SLAVE <VFB_WRITER_CTRL_INTERFACE_WIDTH, VFB_WRITER_CTRL_INTERFACE_DEPTH>();
        writer_control->setUseOwnClock(false);
#endif
#if VFB_READER_RUNTIME_CONTROL
        reader_control = new ALT_AVALON_MM_MEM_SLAVE <VFB_READER_CTRL_INTERFACE_WIDTH, VFB_READER_CTRL_INTERFACE_DEPTH>();
        reader_control->setUseOwnClock(false);
#endif
        read_master->setRdataBurstSize(VFB_RDATA_BURST_TARGET);
        write_master->setWdataBurstSize(VFB_WDATA_BURST_TARGET);
        read_master->setUseOwnClock(VFB_MEM_MASTERS_USE_SEPARATE_CLOCK);
        write_master->setUseOwnClock(VFB_MEM_MASTERS_USE_SEPARATE_CLOCK);
#else
        int bps=ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_BPS", 8);
        int par=ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_CHANNELS_IN_PAR",3);
        din->setDataWidth(bps*par);
        dout->setDataWidth(bps*par);
        din->setSymbolsPerBeat(par);
        dout->setSymbolsPerBeat(par);
        din->enableEopSignals();
        dout->enableEopSignals();

        int mem_port_width = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_MEM_PORT_WIDTH", 64);
        bool mastersUseSeparateClock = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_MEM_MASTERS_USE_SEPARATE_CLOCK", 0);
        int read_burst_target = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_RDATA_BURST_TARGET", 32);
        read_master->setDataWidth(mem_port_width);
        read_master->setUseOwnClock(mastersUseSeparateClock);
        read_master->setAddressWidth(VFB_MEM_ADDR_WIDTH);
        read_master->setRdataBurstSize(read_burst_target);
        read_master->enableReadPorts();

        int write_burst_target = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_WDATA_BURST_TARGET", 32);
        write_master->setDataWidth(mem_port_width);
        write_master->setUseOwnClock(mastersUseSeparateClock);
        write_master->setAddressWidth(VFB_MEM_ADDR_WIDTH);
        write_master->setWdataBurstSize(write_burst_target);
        write_master->enableWritePorts();

        bool writer_control_enabled = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_WRITER_RUNTIME_CONTROL", false);
        bool reader_control_enabled = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_READER_RUNTIME_CONTROL", false);
        if(writer_control_enabled){
            // Width and depth parameters are static
            writer_control = new ALT_AVALON_MM_MEM_SLAVE <VFB_WRITER_CTRL_INTERFACE_WIDTH, VFB_WRITER_CTRL_INTERFACE_DEPTH>();
            bool controlledDropRepeat = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "frameBufferParams;VFB_CONTROLLED_DROP_REPEAT", false);
            writer_control->setDepth(controlledDropRepeat ? 7 : 4);
            writer_control->setUseOwnClock(false);
        }
        if(reader_control_enabled){
            // Width and depth parameters are static
            reader_control = new ALT_AVALON_MM_MEM_SLAVE <VFB_READER_CTRL_INTERFACE_WIDTH, VFB_READER_CTRL_INTERFACE_DEPTH>();
            reader_control->setUseOwnClock(false);
        }
#endif

#ifdef SYNTH_MODE
        // These parameters do not need to be set until cusp generates
        read_master->setRdataFifoDepth(VFB_RDATA_FIFO_DEPTH);
        read_master->setCmdFifoDepth(1);
        write_master->setWdataFifoDepth(VFB_WDATA_FIFO_DEPTH);
        write_master->setCmdFifoDepth(VFB_WDATA_CMD_FIFO_DEPTH);
        SC_THREAD(vfb_writer);
        SC_THREAD(vfb_reader);
#endif //SYNTH_MODE
    }
};
