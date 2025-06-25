// Kerneliser Hardware Model component
//
// Two threads (ker_writer and ker_reader) plus some top level stuff including possibly some
// master ports. Not terribly well namespaced at the moment so use with care. Reads from
// KER_DIN (must be an Avalon-ST Input) and writes to KER_DOUT (must be a FIFO with one extra bit
// space for the end of packet signal and at least 16 bits wide for sending width/height info).
// Assumes that "#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes" and
// "#pragma cusp_config allowLoopSkid = yes" have been set.
// Requires alt_cusp.h, vip_constants.h and vip_common.h to have been included.
// The Kerneliser does a part of the packet processing and some global variables are used for that.
// Should be included within a SystemC module.
//
// Author: dnanceki

#define HW_KER_DEBUG_MSG_ON
#ifndef HW_KER_DEBUG_MSG
    #if defined(HW_KER_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_KER_DEBUG_MSG(X) std::cout << sc_time_stamp() << ": ker_" << name() << ", " << X
    #else
        #define HW_KER_DEBUG_MSG(X)
    #endif
#endif //HW_KER_DEBUG_MSG
#ifndef HW_KER_DEBUG_MSG_COND
    #if defined(HW_KER_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_KER_DEBUG_MSG_COND(cond, X) if (cond) std::cout << sc_time_stamp() << ": ker_" << name() << ", " << X
    #else
        #define HW_KER_DEBUG_MSG_COND(cond, X)
    #endif
#endif //HW_KER_DEBUG_MSG_COND

#ifndef vip_assert
    #if !defined(__CUSP__)
        #include <cassert>
        #define vip_assert(X) assert(X)
    #else
        #define vip_assert(X)
    #endif
#endif // nvip_assert


// Size of memory the address port
#define KER_MEM_ADDR_WIDTH 32

// As far as the kerneliser is concerned, there is not much difference between, for example,
// 20 bit sample data and two 10 bit channels in parallel (except when parsing control packets)
#define KER_BPS_PAR (KER_BPS * KER_CHANNELS_IN_PAR)

#if KER_WRITE_MASTER_NEEDED
    #define KER_MAX_INPUT_FIELD_WIDTH KER_MAX_WIDTH
    #define KER_MAX_INPUT_FIELD_HEIGHT (KER_INPUT_IS_INTERLACED ? (KER_MAX_HEIGHT/2) : KER_MAX_HEIGHT)
    #define KER_LOG2G_MAX_INPUT_FIELD_HEIGHT ((KER_INPUT_IS_INTERLACED && !KER_PROPAGATE_PROGRESSIVE)? (KER_LOG2G_MAX_HEIGHT-1) : KER_LOG2G_MAX_HEIGHT)
    #define KER_MAX_OUTPUT_FIELD_WIDTH KER_MAX_WIDTH
    #define KER_LOG2G_MAX_OUTPUT_FIELD_WIDTH KER_LOG2G_MAX_WIDTH
    #define KER_MAX_OUTPUT_FIELD_HEIGHT (KER_OUTPUT_IS_INTERLACED ? (KER_MAX_HEIGHT/2) : KER_MAX_HEIGHT)
    #define KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT ((KER_OUTPUT_IS_INTERLACED && !KER_PROPAGATE_PROGRESSIVE) ? (KER_LOG2G_MAX_HEIGHT-1) : KER_LOG2G_MAX_HEIGHT)
#else
    #define 2_POWER_16 65536
    #define 2_POWER_15 32768
    #define KER_MAX_INPUT_FIELD_WIDTH  2_POWER_16 - 1
    #define KER_MAX_INPUT_FIELD_HEIGHT (KER_INPUT_IS_INTERLACED ? (2_POWER_15 - 1) : (2_POWER_16 - 1))
    #define KER_LOG2G_MAX_INPUT_FIELD_HEIGHT (KER_INPUT_IS_INTERLACED ? ((HEADER_WORD_BITS * 4) - 1)  : (HEADER_WORD_BITS * 4))
    #define KER_MAX_OUTPUT_FIELD_WIDTH  2_POWER_16 - 1
    #define KER_LOG2G_MAX_OUTPUT_FIELD_WIDTH 16
    #define KER_MAX_OUTPUT_FIELD_HEIGHT (KER_OUTPUT_IS_INTERLACED ? (2_POWER_15 - 1) : (2_POWER_16 - 1))
    #define KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT ((KER_OUTPUT_IS_INTERLACED && !KER_PROPAGATE_PROGRESSIVE) ? ((HEADER_WORD_BITS * 4) - 1)  : (HEADER_WORD_BITS * 4))
#endif




// A tapped delay for each reader to do vertical kernelisation - note that currently this is limiting all
// kernels to be of the same height
// this is a limitation which might be removed in future versions of the kerneliser, when the ALT_TAPPED_DELAY
// function unit becomes more sophisticated
#if (KER_ALL_READERS_KERNEL_HEIGHT > 1)
ALT_TAPPED_DELAY<KER_BPS_PAR, KER_MAX_WIDTH * KER_CHANNELS_IN_SEQ, KER_ALL_READERS_KERNEL_HEIGHT - 1> line_buffers[KER_NUM_READERS];
#endif

// A second tapped delay for each reader to do horizontal kernelisation - same restrictions as vertical
#if (KER_ALL_READERS_KERNEL_WIDTH > 1)
ALT_TAPPED_DELAY<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT, KER_CHANNELS_IN_SEQ, KER_ALL_READERS_KERNEL_WIDTH - 1> hoz_buffers[KER_NUM_READERS];
#endif

#if KER_WRITE_MASTER_NEEDED

    #define KER_MAX_WORDS_BURST         ((KER_MAX_WORDS_IN_ROW > KER_MAX_WORDS_IN_PACKET) ? KER_MAX_WORDS_IN_ROW : KER_MAX_WORDS_IN_PACKET)
    #define KER_WRITE_MASTER_MAX_BURST  ((KER_MAX_WORDS_BURST > KER_WDATA_BURST_TARGET) ? KER_MAX_WORDS_BURST : KER_WDATA_BURST_TARGET)
    #define KER_READ_MASTERS_MAX_BURST  ((KER_MAX_WORDS_BURST > KER_RDATA_BURST_TARGET) ? KER_MAX_WORDS_BURST : KER_RDATA_BURST_TARGET)

    // One write master
    ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_WRITE_MASTER_MAX_BURST, KER_BPS_PAR> *write_master;

    // As many read masters as are required
    ALT_AVALON_MM_MASTER_FIFO<KER_MASTER_PORT_WIDTH, KER_MEM_ADDR_WIDTH, KER_READ_MASTERS_MAX_BURST, KER_BPS_PAR> *read_master;

    // A runtime control (optional)
    ALT_AVALON_MM_RAW_SLAVE<KER_WRITER_CTRL_INTERFACE_WIDTH, KER_WRITER_CTRL_INTERFACE_DEPTH> *ker_writer_control;

    // To write into memory, address counter is incremented as needed
    DECLARE_VAR_WITH_AU(sc_uint<KER_MEM_ADDR_WIDTH>, KER_MEM_ADDR_WIDTH, address);

    #if KER_INPUT_IS_INTERLACED
        #if KER_PROPAGATE_PROGRESSIVE
            #define FIELD_INFO_WIDTH (LOG2(KER_NUM_BUFFERS)+3) //Size for a buffer element [is_progressive, field_type, broken_flow, buffer_id]
        #else
            #define FIELD_INFO_WIDTH (LOG2(KER_NUM_BUFFERS)+2) //Size for a buffer element [field_type, broken_flow, buffer_id]
        #endif
    #else
        #define FIELD_INFO_WIDTH (LOG2(KER_NUM_BUFFERS)+1) //Size for a buffer element [broken_flow, buffer_id]
    #endif

    /* Small FIFOs for interthread communication when a master is used */
    #if !KER_PASS_THROUGH_NEEDED
        // Write to read FIFO to send buffer token of the frames stored.
        // If there is no passthrough more stuff goes down there: the runtime resolution change flag (break_flow),
        // the field type (F0 or F1), the number of words per row, and width/height information
        // buffers_write_to_read transmission protocol: 1:[field_type (opt, 1 or 2 bits), break_flow, buffer_token ], 2:width, 3:height, 4:word_per_row, 5:colour_samples_per_row
        // WRITE_TO_READ should also be large enough to pass on
        #define WRITE_TO_READ_FIFO_WIDTH   MAX(MAX(FIELD_INFO_WIDTH, HEADER_WORD_BITS*4), KER_LOG2G_MAX_SAMPLES_IN_ROW)
        // Give enough space to contain info for one field (or for a pair of fields)
        // Twice that amount is necessary if triple-buffering if requested
        // Add one extra element because systemc model is buggy
        #define WRITE_TO_READ_FIFO_SIZE    (KER_NUM_BUFFERS - KER_OLDEST_BUFFER_READ) * (5 + (KER_CONTROLLED_DROP_REPEAT ? 1 : 0)) + 1
    #else
        // Otherwise the passthrough takes care of the number of words per row, the runtime resolution change flag (break_flow),
        // the field type (F0 or F1) and width/height so one just needs to send the buffer token
        // buffers_write_to_read transmission protocol (with passthrough): 1:buffer_token
        // Add one extra element because systemc model is buggy
        #define WRITE_TO_READ_FIFO_WIDTH   LOG2(KER_NUM_BUFFERS)
        #define WRITE_TO_READ_FIFO_SIZE    (KER_NUM_BUFFERS - KER_OLDEST_BUFFER_READ) + 1
    #endif

    ALT_FIFO<sc_uint<WRITE_TO_READ_FIFO_WIDTH>, WRITE_TO_READ_FIFO_SIZE> buffers_write_to_read;

    // Read to write FIFO to pass back the buffer tokens
    // buffers_read_to_write transmission protocol: 1:buffer_token
    #define READ_TO_WRITE_FIFO_WIDTH   LOG2(KER_NUM_BUFFERS)
    // Give enough space to contain one field (or a pair of fields) or twice that amount if triple-buffering if requested
    // Add one extra element because systemc model is buggy
    #define READ_TO_WRITE_FIFO_SIZE    (KER_NUM_BUFFERS - KER_OLDEST_BUFFER_READ) + 1
    ALT_FIFO<sc_uint<READ_TO_WRITE_FIFO_WIDTH>, READ_TO_WRITE_FIFO_SIZE> buffers_read_to_write;

    // When the passthrough is not used, packets also have to be stored in memory
    #if (!KER_PASS_THROUGH_NEEDED)
        // Write to read FIFO to send packet tokens that go with the frame in buffers_read_to_write
        // The user packets FIFO contains at most KER_MAX_NUMBER_PACKETS*2+ 2 elements per field,
        // 1 extra space is added at the start to indicate which packet has to be sent first (base_packet_id)
        // 1 extra space is added at the end for a 0 marker to delimit field boundaries
        // the *2 comes from the fact that we send both the length in samples and the length in words for each packet
        // Add one extra element because systemc model is buggy
        #define KER_PACKETS_FIFO_WIDTH         KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES
        #define KER_PACKETS_FIFO_SIZE          ((KER_MAX_NUMBER_PACKETS*2) + 2) * (KER_NUM_BUFFERS - KER_OLDEST_BUFFER_READ) + 1
        // packets_write_to_read transmission protocol: 1:base_packet_id, [2:length_in_samples, 3:length in_words]*number_packets, ... 0 to terminate the field
        ALT_FIFO< sc_uint<KER_PACKETS_FIFO_WIDTH>, KER_PACKETS_FIFO_SIZE > packets_write_to_read;

        // To remember where the next packet should be written when frames get dropped
        DECLARE_VAR_WITH_AU(sc_uint<KER_MEM_ADDR_WIDTH>, KER_MEM_ADDR_WIDTH, packet_write_address);
        sc_uint<KER_MEM_ADDR_WIDTH> packet_write_base_address;
        DECLARE_VAR_WITH_AU(sc_uint<KER_MEM_ADDR_WIDTH>, KER_MEM_ADDR_WIDTH, packet_read_address);
        sc_uint<KER_MEM_ADDR_WIDTH> packet_read_base_address;

        // To write the input fields line by line
        DECLARE_VAR_WITH_AU(sc_uint<KER_MEM_ADDR_WIDTH>, KER_MEM_ADDR_WIDTH, write_address);
        sc_uint<KER_MEM_ADDR_WIDTH> write_base_address;
        #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED))
            // An address storage space to switch between 2 buffers when storing a progressive field as 2 interlaced fields
            sc_uint<KER_MEM_ADDR_WIDTH> write_address_swap;
        #endif


        // Arrays to store the lenght (in words and samples) of the incoming packets and transmit the information
        // to the reader
        ALT_AU<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES> packets_sample_length_AU[KER_MAX_NUMBER_PACKETS];
        sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES> packets_sample_length[KER_MAX_NUMBER_PACKETS] BIND(packets_sample_length_AU);

        // Length of the packets in words
        ALT_AU<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES> packets_word_length_AU[KER_MAX_NUMBER_PACKETS];
        sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES> packets_word_length[KER_MAX_NUMBER_PACKETS] BIND(packets_word_length_AU);

        // The first packet to send (corresponds to an address), this counter wraps around in case of overflow
        DECLARE_VAR_WITH_AU(sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>, KER_LOG2_MAX_NUMBER_PACKETS, first_packet_id);
        DECLARE_VAR_WITH_AU(sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>, KER_LOG2G_MAX_NUMBER_PACKETS, next_to_last_packet_id);

        // Counters to count number of words and length of incoming packets
        DECLARE_VAR_WITH_AU(sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES>, KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES, length_counter);
        DECLARE_VAR_WITH_AU(sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_WORDS>, KER_LOG2G_MAX_PACKET_LENGTH_IN_WORDS, word_counter);
        DECLARE_VAR_WITH_AU(sc_int<KER_TRIGGER_COUNTER_WIDTH>, KER_TRIGGER_COUNTER_WIDTH, word_counter_trigger);
    #endif
#endif //write and read masters are used

// A fifo to permit data to be passed through directly from the writer to the reader, without
// going via external ram. An extra bit is added for the eop signal, the FIFO has to be large enough
// transmit width and height information contained in the last control packet.
// The pass_through FIFO also sends the runtime resolution change flag (break_flow) and the field type.
// Optionaly, it send the number of words in a row if master and readers are used
#if KER_PASS_THROUGH_NEEDED
    #if KER_WRITE_MASTER_NEEDED
        // pass_through transmission protocol: packet stream, IMAGE_DATA_HEADER, [field_type (opt, 1 or 2 bits), break_flow], width, height, words_in row, samples_in_row, image stream, ...
        #define KER_PASS_THROUGH_FIFO_SIZE 5
        #define KER_PASS_THROUGH_FIFO_WIDTH MAX(MAX(KER_BPS_PAR+1,HEADER_WORD_BITS*4), KER_LOG2G_MAX_SAMPLES_IN_ROW)
    #else
        // Spacial kerneliser, using only the passthrough mode
        // pass_through transmission protocol: packet stream, IMAGE_DATA_HEADER, [field_type (opt, 1 or 2 bits), break_flow], width, height, image stream, ...
        #define KER_PASS_THROUGH_FIFO_SIZE 5
        #define KER_PASS_THROUGH_FIFO_WIDTH MAX(KER_BPS_PAR+1,HEADER_WORD_BITS*4)
    #endif
    ALT_FIFO<sc_uint<KER_PASS_THROUGH_FIFO_WIDTH>, KER_PASS_THROUGH_FIFO_SIZE> pass_through;
#endif


#ifndef __CUSP__
// Print the state of read_buffers to stdout, along with a timestamp
void dbg_report_read_buffers(sc_uint<LOG2(KER_NUM_BUFFERS)> rbs[KER_OLDEST_BUFFER_READ])
{
    HW_KER_DEBUG_MSG("Reader: reporting state of read_buffers[]" << std::endl);
    for (int i = 0; i < KER_OLDEST_BUFFER_READ; i++)
    {
        HW_KER_DEBUG_MSG("Reader: read_buffers[" << i << "] = " << rbs[i] << std::endl);
    }
    HW_KER_DEBUG_MSG("Reader: finished reporting state of read_buffers[]" << std::endl);
}
#endif


#define FIFO_WRITE_DATA_AND_EOP(fifo, data, data_width, eop)              \
        fifo.write((sc_uint<1>(eop), sc_biguint<data_width>(data)));

#define FIFO_WRITE_BIG_DATA_AND_EOP(fifo, data, data_width, eop)          \
        fifo.write((sc_uint<1>(eop), sc_biguint<data_width>(data)));

#define CUSP_SWAP(a, b, width)                  \
{                                               \
        sc_uint<width> temp_var BIND(ALT_WIRE); \
        temp_var = a;                           \
        a = b;                                  \
        b = temp_var;                           \
}

// A flag to indicate that the expected input is interlaced and that the reader needs both the F0 and F1 fields to build the output
#define EXPECTING_STRICT_F0_F1_SUCCESSION ((KER_INPUT_IS_INTERLACED) && (KER_REGULAR_FIELD_DROP == KERNELISER_NO_REGULAR_FIELD_DROP))

// A flag to indicate that the reader builds the output from a strict F0->F1->F0->... sequence but that the pointer moves
// by increment of two and buffers are swapped by pair between the thread
#define SYNC_ON_SPECIFIC_INTERLACED_FIELD (EXPECTING_STRICT_F0_F1_SUCCESSION &&                                               \
                                                 ((KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F0) ||    \
                                                  (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1)))
// When SYNC_ON_SPECIFIC_INTERLACED_FIELD is true, what is the type of the oldest field to build the output?
// Consider the sequence: F0->F1->F0->F1->F0(passthrough)  if syncing in F0 (the type of the passhtrough) then the
// oldest buffer is also an F0 if we are using an even number of buffer
#define SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1 ((KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F0) == \
                                                                   (IS_ODD(KER_OLDEST_BUFFER_READ)))


/*************************************** Packet related variables and functions ********************************************/
#define PACKET_BPS KER_BPS
#define PACKET_CHANNELS_IN_PAR KER_CHANNELS_IN_PAR
sc_uint<PACKET_BPS*KER_CHANNELS_IN_PAR> ker_just_read;
sc_uint<HEADER_WORD_BITS> ker_header_type;
DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, ker_input_field_width);
DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, ker_input_field_height);
DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, ker_input_field_interlace);

// When reading control words in parallel, these wires keep the next data element at ker_just_read_queue[0]
// Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
sc_uint<PACKET_BPS> ker_just_read_queue[PACKET_CHANNELS_IN_PAR] BIND(ALT_WIRE);

static const unsigned int INTERLACE_FLAG_BIT = HEADER_WORD_BITS-1;
static const unsigned int INTERLACE_FIELD_TYPE_BIT = HEADER_WORD_BITS-2;

// void read_and_propagate(int occurrence, bool where_to_store)
// For reading control packet data when we do not expect the previous read to have been EOP
// If an early EOP had occured, no more reads are taken from din, and either no more data
// is sent to the output or the memory is filled with undetermined values
// To abstract away the fact that control packets are sent with each symbol, and can come in parallel,
// this function either reads from din, or advances the ker_just_read_queue array. To decide which to do, it
// needs to know how many times it has been called. Since Cusp is not be able to figure out that an
// incrementing counter can be evaluated at compile-time, the function much be called with a number
// indicating which occurence it is being used in. It will do an actual read when occurrence%CHANNELS_IN_PAR == 0
//
// @param occurrence the amount of times this function has been called in a sequence

// Cannot make store_in_memory a proper compile time function parameter because write_master/pass_through
// are not there if they are not used
#define store_in_memory !KER_PASS_THROUGH_NEEDED

void read_and_propagate(int occurrence)
{
    // Do the read and propagation every PACKET_CHANNELS_IN_PAR iteration starting at 0 and reset ker_just_read_queue
    if (occurrence % PACKET_CHANNELS_IN_PAR == 0)
    {
        sc_uint<PACKET_CHANNELS_IN_PAR * PACKET_BPS> ker_just_read_access_wire BIND(ALT_WIRE);
        ker_just_read_access_wire = 0;

        #if (store_in_memory)
        {
            // Increment counter by 1 unless we reached the end of packet
            length_counter = length_counter_AU.cAddSubUI(length_counter, sc_uint<1>(1), length_counter, !KER_DIN->getEndPacket(), false);
            // Increment word counter by 1 each time the trigger reaches -1 (unless we reached the end of packet)
            word_counter = word_counter_AU.cAddSubUI(word_counter,
                                                     sc_uint<1>(1), word_counter,
                                                     !KER_DIN->getEndPacket() && word_counter_trigger.bit(KER_TRIGGER_COUNTER_WIDTH-1),
                                                     false);
            word_counter_trigger = word_counter_trigger_AU.cAddSubSLdSI(
                                               word_counter_trigger, sc_int<1>(-1),                     // General case, --word_counter_trigger
                                               KER_SAMPLES_IN_WORD - 2,                                 // -1 reached previous iteration? reinitialise
                                               word_counter_trigger,                                    // Stay at current value if !enable
                                               !KER_DIN->getEndPacket(),                                 // Enable line
                                               word_counter_trigger.bit(KER_TRIGGER_COUNTER_WIDTH-1),   // sLd line, reinit if word_counter_trigger == -1
                                               false);                                                  // Always add -1
            ker_just_read = KER_DIN->cRead(!KER_DIN->getEndPacket());
            write_master->writePartialDataUI(ker_just_read);
        }
        #else
        {
            if (!KER_DIN->getEndPacket())
            {
                ker_just_read = KER_DIN->read();
                FIFO_WRITE_DATA_AND_EOP(pass_through, ker_just_read, KER_BPS_PAR, KER_DIN->getEndPacket());
            }
        }
        #endif
        // Set up ker_just_read_queue, should be able to use .range(), but Cusp is weak, so use a wire and shifting
        // to get to the words inside PACKET_JUST_READ_VAR
        ker_just_read_access_wire = ker_just_read;
        for (int i = 0; i < PACKET_CHANNELS_IN_PAR; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ker_just_read_queue[i] = ker_just_read_access_wire;
            ker_just_read_access_wire >>= PACKET_BPS;
        }
    }
    // In other cases just advance the elements of the ker_just_read_queue (ALT_WIRE?) array
    else
    {
        for (int i = 0; i < PACKET_CHANNELS_IN_PAR - 1; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ker_just_read_queue[i] = ker_just_read_queue[i + 1];
        }
    }
}

void handle_non_image_packets()
{
    bool is_not_image_data;
    do
    {
        ker_just_read = KER_DIN->read();
        ker_header_type = ker_just_read;

        is_not_image_data = (ker_header_type != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));

        if (is_not_image_data)
        {
            HW_KER_DEBUG_MSG("Processing packet of type " << ker_header_type << std::endl);

            // Assume that all incoming packets is a control packet. If not then just skip the assignment to control
            // registers.
            bool is_control_packet = (ker_header_type == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER));

            #if (store_in_memory)
            {
                // Init the counters
                length_counter = 1;
                word_counter = 1;
                word_counter_trigger = KER_SAMPLES_IN_WORD - 2;
                write_master->busPostWriteBurst(packet_write_address, KER_MAX_WORDS_IN_PACKET);
                write_master->writePartialDataUI(ker_just_read);        // Writing header into memory
            }
            #else
            {
                FIFO_WRITE_DATA_AND_EOP(pass_through, ker_just_read, KER_BPS_PAR, KER_DIN->getEndPacket())
            }
            #endif

            ALT_REG<HEADER_WORD_BITS> packetDimensions_REG[4];
            sc_uint<HEADER_WORD_BITS> packetDimensions[4] BIND(packetDimensions_REG);

            for (unsigned int i = 0; i < 4; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                read_and_propagate(i);

                packetDimensions[i] = ker_just_read_queue[0];
            }
            ker_input_field_width = ker_input_field_width_REG.cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                ker_input_field_width,
                is_control_packet);

            for (unsigned int i = 0; i < 4; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                read_and_propagate(4 + i);

                packetDimensions[i] = ker_just_read_queue[0];
            }
            ker_input_field_height = ker_input_field_height_REG.cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                ker_input_field_height,
                is_control_packet);

            read_and_propagate(8);
            ker_input_field_interlace = ker_input_field_interlace_REG.cLdUI(ker_just_read_queue[0], ker_input_field_interlace, is_control_packet);


            HW_KER_DEBUG_MSG_COND(!(ker_input_field_interlace & 0x8), "Writer: control packet processed "
                       << ker_input_field_width << "x" << ker_input_field_height << ", progressive field" << std::endl);
            HW_KER_DEBUG_MSG_COND(ker_input_field_interlace & 0x8, "Writer: control packet processed "
                       << ker_input_field_width << "x" << ker_input_field_height << ", interlaced field F" <<
                                       ((ker_input_field_interlace & 0x4) ? '1' : '0') << std::endl);

            // Whether it was a control packet or an unknown packet, we still propagate/store anything remaining
            #if (store_in_memory)
            {
                // max_samplesPar_remaining = (KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 10 if KER_CHANNELS_IN_PAR = 1
                // max_samplesPar_remaining = (KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 6 if KER_CHANNELS_IN_PAR = 2
                // max_samplesPar_remaining = (KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 4 if KER_CHANNELS_IN_PAR = 3
                for (unsigned int partialData = 0;
                     partialData < (KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 2 - (1 << (4-KER_CHANNELS_IN_PAR));
                     ++partialData)
                {
#if ((KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 2 - (1 << (4-KER_CHANNELS_IN_PAR)) >= 3)
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, (KER_SAMPLES_IN_WORD * KER_MAX_WORDS_IN_PACKET) - 2 - (1 << (4-KER_CHANNELS_IN_PAR)));
#endif
                    // Increment counter by 1 unless we reached the end of packet
                    length_counter = length_counter_AU.cAddSubUI(length_counter, sc_uint<1>(1), length_counter, !KER_DIN->getEndPacket(), false);
                    // Increment word counter by 1 each time the trigger reaches -1 (unless we reached the end of packet)
                    word_counter = word_counter_AU.cAddSubUI(word_counter,
                                                             sc_uint<1>(1), word_counter,
                                                             !KER_DIN->getEndPacket() && word_counter_trigger.bit(KER_TRIGGER_COUNTER_WIDTH-1),
                                                             false);
                    word_counter_trigger = word_counter_trigger_AU.cAddSubSLdSI(
                                                 word_counter_trigger, sc_int<1>(-1),                     // General case, --word_counter_trigger
                                                 KER_SAMPLES_IN_WORD - 2,                                 // -1 reached previous iteration? reinitialise
                                                 word_counter_trigger,                                    // Stay at current value if !enable
                                                 !KER_DIN->getEndPacket(),                                 // Enable line
                                                 word_counter_trigger.bit(KER_TRIGGER_COUNTER_WIDTH-1),   // sLd line, reinit if word_counter_trigger == -1
                                                 false);                                                  // Always add -1
                    ker_just_read = KER_DIN->cRead(!din->getEndPacket());
                    write_master->writePartialDataUI(ker_just_read);
                }
                write_master->flush(); // Finish a partial word (should be useless)

                // Discard extra data that does not fit
                HW_KER_DEBUG_MSG_COND(!KER_DIN->getEndPacket(), "Writer: Discarding packet data that do not fit into memory" << std::endl);
                while (!KER_DIN->getEndPacket())
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 3);
                    ALT_ATTRIB(ALT_SKIDDING, true);
                    ker_just_read = KER_DIN->cRead(!KER_DIN->getEndPacket());
                }


                // Build a wire to indicate overflow condition
                bool overflow_wire BIND(ALT_WIRE);
                overflow_wire = (next_to_last_packet_id == sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS));
                // Store length of packet at appropriate location, and simultaneously switch all lengths if overflowing
                for (sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS> k = 0;
                             k < sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS - 1); ++k)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    packets_sample_length[k] = packets_sample_length_AU[k].mCLdUI(length_counter,
                                                   packets_sample_length[k + sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(1)],
                                                   packets_sample_length[k],
                                                   next_to_last_packet_id == k,
                                                   overflow_wire);
                    packets_word_length[k] = packets_word_length_AU[k].mCLdUI(word_counter,
                                                   packets_word_length[k + sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(1)],
                                                   packets_word_length[k],
                                                   next_to_last_packet_id == k,
                                                   overflow_wire);
                }
                // Increment first_packet_id (if overflow), wrap around if necessary
                first_packet_id = first_packet_id_AU.cAddSubSLdUI(
                                       first_packet_id, sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>(1),      // + 1
                                       sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>(0),                       // Wrapping around
                                       first_packet_id,                                               // Maintain current value
                                       overflow_wire,                                                 // Maintain to 0 if !overflow
                                       first_packet_id ==
                                           sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS - 1),      // -> Wrap around
                                       false);                                                        // Always an addition of +1
                // Increment next_to_last_packet_id for next packet or maintain if overflowing
                next_to_last_packet_id = next_to_last_packet_id_AU.cAddSubUI(next_to_last_packet_id,
                                                 sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(1),
                                                 next_to_last_packet_id, !overflow_wire, false);

                // Update overflow_wire now that next_to_last_packet_id has been incremented
                overflow_wire = (next_to_last_packet_id == sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS));
                // Write length on the last register if relevant (it was not done in the loop above)
                packets_sample_length[KER_MAX_NUMBER_PACKETS - 1] =
                       packets_sample_length_AU[KER_MAX_NUMBER_PACKETS - 1].cLdUI(length_counter,
                                                                         packets_sample_length[KER_MAX_NUMBER_PACKETS - 1],
                                                                         overflow_wire);
                packets_word_length[KER_MAX_NUMBER_PACKETS - 1] =
                       packets_word_length_AU[KER_MAX_NUMBER_PACKETS - 1].cLdUI(word_counter,
                                                                         packets_word_length[KER_MAX_NUMBER_PACKETS - 1],
                                                                         overflow_wire);
                // Increment packet_write_address for next packet, wrap around if necessary
                packet_write_address = packet_write_address_AU.addSubSLdUI(packet_write_address,
                                               sc_uint<KER_MEM_ADDR_WIDTH>(KER_WORDS_IN_ALIGNED_PACKET * KER_WORD_BYTES),
                                               packet_write_base_address,
                                               (first_packet_id == sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>(0))
                                               && overflow_wire,
                                               false);
            }
            #else
            {
                HW_KER_DEBUG_MSG_COND(!KER_DIN->getEndPacket() && is_control_packet, "Writer: Extra data in control packet passed on");
                while (!KER_DIN->getEndPacket())
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    if (!KER_DIN->getEndPacket())
                    {
                        ker_just_read = KER_DIN->read();
                        FIFO_WRITE_DATA_AND_EOP(pass_through, ker_just_read, KER_BPS_PAR, KER_DIN->getEndPacket());
                    }
                }
            }
            #endif
        }
    } while (is_not_image_data);
    HW_KER_DEBUG_MSG("Image data header received" << std::endl);
}

// Discard a field from the input (relying on the end of packet signal)
void ker_discard_field()
{
    while(!KER_DIN->getEndPacket())
    {
        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
        ALT_ATTRIB(ALT_MOD_TARGET, 1);
        ALT_ATTRIB(ALT_MIN_ITER, 3);
        ALT_ATTRIB(ALT_SKIDDING, true);
        KER_DIN->cRead(!KER_DIN->getEndPacket());
    }
}



/*******************************************************************************************************************************************************
 *  The Writer thread which reads the input ports and either buffer or passthrough (or both) the incoming data depending on the
 * parameterization
 *******************************************************************************************************************************************************/

// Runtime control for the ker writer algorithm
#if KER_WRITER_RUNTIME_CTRL

    ALT_REG<1> ker_writer_go_REG ALT_BIND_SEQ_SPACE("avSlaveSequenceSpace0");
    ALT_REG<1> ker_writer_running_REG ALT_BIND_SEQ_SPACE("avSlaveSequenceSpace1");
    sc_uint<1> ker_writer_go BIND(ker_writer_go_REG);
    sc_uint<1> ker_writer_running BIND(ker_writer_running_REG);

    #if KER_CONTROLLED_DROP_REPEAT
        sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH> ker_writer_input_frame_rate_in;
        sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH> ker_writer_output_frame_rate_in;
    #endif

    sc_event ker_writer_go_changed;

    void ker_writer_control_monitor()
    {
        // Initialise GO to 0
        ker_writer_go = 0;
        #if KER_CONTROLLED_DROP_REPEAT
            // Initialise frame rate conversion ratio to 1:1
            ker_writer_input_frame_rate_in = sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH>(1);
            ker_writer_output_frame_rate_in = sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH>(1);
        #endif
        for (;;)
        {
            bool is_read = ker_writer_control->isReadAccess();
            sc_uint<KER_LOG2_WRITER_CTRL_INTERFACE_DEPTH> address = ker_writer_control->getAddress();
            if (is_read)
            {
                // The only address we service for reads is address CTRL_STATUS_ADDRESS so always return running
                ker_writer_control->returnReadData(int(ker_writer_running));
            }
            else
            {
                long this_read = ker_writer_control->getWriteData();
                if (address == sc_uint<KER_LOG2_WRITER_CTRL_INTERFACE_DEPTH>(KER_WRITER_CTRL_GO_ADDRESS))
                {
                    ker_writer_go = this_read;
                    notify(ker_writer_go_changed);
                }
                #if KER_CONTROLLED_DROP_REPEAT
                    if (address == sc_uint<KER_LOG2_WRITER_CTRL_INTERFACE_DEPTH>(KER_WRITER_CTRL_INPUT_RATE_ADDRESS))
                    {
                        ker_writer_input_frame_rate_in = this_read;
                    }
                    if (address == sc_uint<KER_LOG2_WRITER_CTRL_INTERFACE_DEPTH>(KER_WRITER_CTRL_OUTPUT_RATE_ADDRESS))
                    {
                        ker_writer_output_frame_rate_in = this_read;
                    }
                #endif
            }
        }
    }

    // As well as the interface itself, create a bunch of registers to hold the control data in the writer thread.
    // The main thread "control routine" function is also addded here
    #if KER_CONTROLLED_DROP_REPEAT
        #define KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH (KER_WRITER_CTRL_INTERFACE_WIDTH + ((KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH) ? 1 : 0))
        sc_uint<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH> ker_writer_input_frame_rate;
        sc_uint<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH> ker_writer_output_frame_rate;
    #endif
    void ker_writer_process_control_data()
    {
        // Write the running bit
        ker_writer_running = 0;
        ker_writer_control->notifyEvent();
        NO_CUSP(wait(0, SC_NS));
        // Check the go bit before starting to read
        while (!ker_writer_go)
        {
            wait(ker_writer_go_changed);
        }
        // Copy data direct from raw slave to registers to use during the next "frame"
        #if KER_CONTROLLED_DROP_REPEAT
            ker_writer_input_frame_rate = ker_writer_input_frame_rate_in;
            ker_writer_output_frame_rate = ker_writer_output_frame_rate_in;
            HW_KER_DEBUG_MSG("Writer: rate control input/output rate registered, in_rate="
                                    << ker_writer_input_frame_rate_in << ", out_rate="
                                    << ker_writer_output_frame_rate_in << std::endl);
        #endif
        // Write the running bit
        ker_writer_running = 1;
        ker_writer_control->notifyEvent();
        NO_CUSP(wait(0, SC_NS));
    }
#endif


void ker_writer()
{
    #if KER_WRITE_MASTER_NEEDED
        // This array of constants is filled in for us by parameter helper with the
        // base address of each (frame or field) buffer
        /*
        unsigned int initial_buffer_addresses[KER_NUM_BUFFERS] = KER_BUFFER_ADDRESSES;
        ALT_REGISTER_FILE<-1, 2, 1, -1, 1, 1, 0, ALT_MEM_MODE_LE> buffer_addresses_MEM;
        unsigned int buffer_addresses[KER_NUM_BUFFERS] BIND(buffer_addresses_MEM);
        for (unsigned int i=0; i < KER_NUM_BUFFERS; i++)
        {
             ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
             buffer_addresses[i] = initial_buffer_addresses[i];
        }
        */
        unsigned int buffer_addresses[KER_NUM_BUFFERS] = KER_BUFFER_ADDRESSES;

        #if !KER_PASS_THROUGH_NEEDED
        // Without passthrough, packets go through memory
            /*
            unsigned int initial_packet_addresses[KER_NUM_BUFFERS] = KER_PACKET_ADDRESSES;
            ALT_REGISTER_FILE<-1, 2, 1, -1, 1, 1, 0, ALT_MEM_MODE_LE> packet_addresses_MEM;
            unsigned int packet_addresses[KER_NUM_BUFFERS] BIND(packet_addresses_MEM);
            for (unsigned int i=0; i < KER_NUM_BUFFERS; i++)
            {
                 ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                 packet_addresses[i] = initial_packet_addresses[i];
            }
            */
            unsigned int packet_addresses[KER_NUM_BUFFERS] = KER_PACKET_ADDRESSES;
        #endif

        // Start up writing to buffer zero
        sc_uint<LOG2(KER_NUM_BUFFERS)> write_buffer = 0;
    #endif

    // A flag to indicate a runtime resolution change to the reader, break_flow has to stay the same from one loop iter to the next in case of drop
    bool break_flow = true;
    sc_uint<HEADER_WORD_BITS * 4> previous_field_width = 0;
    sc_uint<HEADER_WORD_BITS * 4> previous_field_height = 0;

    #if KER_WRITE_MASTER_NEEDED
        sc_uint<KER_LOG2G_MAX_WORDS_IN_ROW> words_in_row;
        sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW> samples_in_row;
    #endif

    // Initialise input_field_X with default values, these can be overwritten by control packets
    ker_input_field_width = KER_MAX_INPUT_FIELD_WIDTH;
    ker_input_field_height = KER_MAX_INPUT_FIELD_HEIGHT;
    #if (KER_INPUT_IS_INTERLACED)
        // Initialise input field interlace properly in case there is no control packet with the first field
        ker_input_field_interlace = (KER_DEFAULT_INITIAL_FIELD == FIELD_F1_FIRST ) ? 0xC : 0x8;
        // There is no need to store the complete nibble, just keep track of whether this is a F0 or F1 field (and progressive if not discarded)
        // current_field_type/current_field_interlace is also used to make sure that new fields are of the opposite type of the previous one in
        // the EXPECTING_STRICT_F0_F1_SUCCESSION case, but since this is ignored if there is a runtime change so no need
        // to worry about the initialisation of these registers for the first frame
        #if KER_PROPAGATE_PROGRESSIVE
            sc_uint<2> current_field_type = 0; // bit 1 is for progressive/interlaced status, but 0 is for F0/F1
        #else
            bool current_field_interlace = 0;
        #endif
    #else
        ker_input_field_interlace = 0;
    #endif

    #if (((KER_ALLOW_DROPPING) && (SYNC_ON_SPECIFIC_INTERLACED_FIELD)) || (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED)))
        // Prepare an extra claimed buffer for progressive passthrough with woven output or when buffer should go in pair (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
        sc_uint<LOG2(KER_NUM_BUFFERS)> claimed_buffer;
        #if (KER_ALLOW_DROPPING || KER_CONTROLLED_DROP_REPEAT)
            bool have_claimed_buffer;
        #endif
    #endif

    #if KER_CONTROLLED_DROP_REPEAT
        // The "error", for our variant of the Bresenham's line algorithm (in the range +/- 2*rate)
        ALT_AU<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1> drop_error_AU;
        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1> drop_error BIND(drop_error_AU);
        ALT_AU<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1> repeat_error_AU;
        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1> repeat_error BIND(repeat_error_AU);
        // The writer thread tells the reader how many times a field/pair of fields/frames should be repeated
        sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH> repeat_factor;
    #endif

    for (;;)
    {
        #if (((KER_ALLOW_DROPPING) && (SYNC_ON_SPECIFIC_INTERLACED_FIELD)) || (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED)))
            #if (KER_ALLOW_DROPPING || KER_CONTROLLED_DROP_REPEAT)
                have_claimed_buffer = false; // Reset have_claimed_buffer since the previous field was sent ok
            #endif
        #endif

        #if (!KER_PASS_THROUGH_USED)
        {
            packet_write_base_address = packet_addresses[write_buffer];

            // Reinitialise packet_write_address to the base address
            packet_write_address = packet_write_base_address;
            // Reinitialise the pointers on the packet_samples_length and packet_words_length arrays
            next_to_last_packet_id = 0;
            first_packet_id = 0;
        }
        #endif


#if KER_ALLOW_DROPPING
        bool dropping = false;
        do { // Repeat while the field processed is dropped
#endif
            // If passthrough is used then packets are piled up directly into the FIFO, there can be no drop/repeat
            // when the passthrough is used so the reader thread is well synchronized and should be reading simultaneously
            // on the other side of the FIFO (even when the REGULAR_FIELD_DROP optimization is used)
            // Note that if we drop all F1 with the REGULAR_FIELD_DROP optimization then their packets is
            // associated with the next F0 field which is ok
            bool quick_drop;
            do
            {
                /**************************************** Process the packets that precede the image data ***************************************/
                HW_KER_DEBUG_MSG("Writer: parsing & storing/propagating packets" << std::endl);
                handle_non_image_packets();

                #if KER_WRITER_RUNTIME_CTRL
                    // Between each frame read the run-time parameters and toggle/check the go/status bits
                    ker_writer_process_control_data();
                #endif


                #if (KER_INPUT_IS_INTERLACED)
                {
                    // Decide whether a quick drop (no transit to memory) should be done
                    // We drop:
                    // 1) Progressive fields in they are not wanted
                    // 2) Repeated F0 or F1 fields unless :
                    //                  a) there is a runtime resolution change,
                    //                  b) we are using only the F0s or F1s (REGULAR_FIELD_DROP)

                    #if (KER_REGULAR_FIELD_DROP == KERNELISER_NO_REGULAR_FIELD_DROP)
                    {
                        // EXPECTING_STRICT_F0_F1_SUCCESSION is true and all fields are discarded until receiving a field of the opposite type
                        // of the previous one, however, consecutives F0 or F1 are ok if the resolution is changing and the pipe needs to be flushed

                        // If the resolution is as before and we are not in broken_flow situation
                        // then drop a duplicate F0/F1 (even if KER_ALLOW_DROPPING is false).
                        // Always drop a progressive field unless KER_PROPAGATE_PROGRESSIVE
                        #if (KER_PROPAGATE_PROGRESSIVE)
                        {
                            // Check for runtime resolution change (or interlaced<->progressive switch), maintain break_flow value from last
                            // frame in case it was dropped and not transmitted
                            break_flow = break_flow || ((previous_field_width != ker_input_field_width) || (previous_field_height != ker_input_field_height)) || (current_field_type.bit(1) != ker_input_field_interlace.bit(INTERLACE_FLAG_BIT));
                            #if (KER_OUTPUT_IS_INTERLACED)
                            {
                                // Output is interlaced, progressive frames are not weaved into memory and buffers should be big enough
                                // to accommodate a full frame. Drop only repeated interlaced fields.
                                quick_drop = ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) && !break_flow &&
                                      (current_field_type.bit(0) == ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT));
                            }
                            #else
                            {
                                // Output is woven with two fields. Two buffers are needed to store the progressive input as separate fields F0/F1.
                                // Check if we already claimed a second buffer (SYNC_ON_SPECIFIC_FIELD case) or if one can/must be claimed.
                                #if (KER_ALLOW_DROPPING)
                                {
                                    // Get the second buffer if possible (and necessary)
                                    if (!ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) && !have_claimed_buffer && buffers_read_to_write.hasDataAvail())
                                    {
                                        have_claimed_buffer = true;
                                        claimed_buffer = buffers_read_to_write.read();
                                    }
                                    // Do quick drop for repeated F0/F1 or no room for the progressive
                                    quick_drop = ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                                        (!break_flow && (current_field_type.bit(0) == ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT))) :
                                        !have_claimed_buffer;
                                }
                                #else
                                {
                                    // Get the second buffer for the progressive frame, wait for it (although this should not be necessary)
                                    if (!ker_input_field_interlace.bit(INTERLACE_FLAG_BIT))
                                    {
                                        HW_KER_DEBUG_MSG("Writer: Waiting for second buffer to pass progressive frame on" << std::endl);
                                        #if (KER_CONTROLLED_DROP_REPEAT)
                                            if (!have_claimed_buffer)
                                            {
                                                have_claimed_buffer = true;
                                                claimed_buffer = buffers_read_to_write.read(); // Force a stall if no second buffer is available
                                            }
                                        #else
                                            claimed_buffer = buffers_read_to_write.read(); // Force a stall if no second buffer is available
                                        #endif
                                        HW_KER_DEBUG_MSG("Writer: Second buffer received" << std::endl);
                                    }
                                    // Do quick drop for repeated F0/F1,  progressive frame is never dropped
                                    quick_drop = ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                                        (!break_flow && (current_field_type.bit(0) == ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT))) :
                                        false;
                                }
                                #endif
                            }
                            #endif
                        }
                        #else // Progressive frames are always discarded
                        {
                            // Check for runtime resolution change
                            break_flow = break_flow || ((previous_field_width != ker_input_field_width) || (previous_field_height != ker_input_field_height));
                            // Drop progressive fields or repeated F0/F1 with same resolution
                            quick_drop = !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) ||
                                (!break_flow && (current_field_interlace == ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)));
                        }
                        #endif
                        HW_KER_DEBUG_MSG_COND(quick_drop && !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT),
                                      "Writer: Immediate dropping of progressive field" << std::endl);
                        HW_KER_DEBUG_MSG_COND(quick_drop && ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) && ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                      "Writer: Immediate dropping of duplicate F1 field (or previous F0 might have been dropped)" << std::endl);
                        HW_KER_DEBUG_MSG_COND(quick_drop && ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) && !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                      "Writer: Immediate dropping of duplicate F0 field (or previous F1 might have been dropped)" << std::endl);
                    }
                    #else  //(KER_REGULAR_FIELD_DROP != KERNELISER_NO_REGULAR_FIELD_DROP)
                    {
                        // Regular field drop optimizations, interlaced fields that are not used are dropped directly and are not sent to memory
                        // the actual sequence of fields (F0->F1->F0->..) is not important here
                        // Drop all F0s or all F1s depending on KER_REGULAR_FIELD_DROP. Drop a progressive field if requested.
                        #if (KER_PROPAGATE_PROGRESSIVE)
                        {
                            // Check for runtime resolution change
                            break_flow = break_flow || ((previous_field_width != ker_input_field_width) || (previous_field_height != ker_input_field_height)) || (current_field_type.bit(1) != ker_input_field_interlace.bit(INTERLACE_FLAG_BIT));
                            quick_drop = ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) &&
                                (ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) == (KER_REGULAR_FIELD_DROP == KERNELISER_REGULAR_FIELD_DROP_F1));
                        }
                        #else
                        {
                            // Check for runtime resolution change
                            break_flow = break_flow || ((previous_field_width != ker_input_field_width) || (previous_field_height != ker_input_field_height));
                            quick_drop = !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) ||
                                (ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) == (KER_REGULAR_FIELD_DROP == KERNELISER_REGULAR_FIELD_DROP_F1));
                        }
                        #endif
                        HW_KER_DEBUG_MSG_COND(quick_drop, "Writer: Performing a \"regular\" immediate field drop" << endl);
                    }
                    #endif
                }
                #else // Progressive input (as expected). WARNING, this probably was never tested
                {
                    // Check for runtime resolution change
                    break_flow = break_flow || ((previous_field_width != ker_input_field_width) || (previous_field_height != ker_input_field_height));
                    // Interlaced fields are discarded on the spot
                    quick_drop = ker_input_field_interlace.bit(INTERLACE_FLAG_BIT);
                    HW_KER_DEBUG_MSG(quick_drop, "Writer: Immediate dropping of the unexpected non-progressive field" << std::endl);
                }
                #endif

                #if KER_CONTROLLED_DROP_REPEAT
                {
                    // Decide how many times the field/frame has to be repeated or if it has to be dropped
                    bool input_rate_larger BIND(ALT_WIRE);
                    input_rate_larger = (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH) ?
                            sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH+1>(ker_writer_output_frame_rate) <
                                              sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH+1>(ker_writer_input_frame_rate << 1) :
                            ker_writer_output_frame_rate < ker_writer_input_frame_rate;
                    #if (KER_REGULAR_FIELD_DROP == KERNELISER_NO_REGULAR_FIELD_DROP)
                    {
                        // Reinit errors in case of quick drop or break_flow
                        drop_error = drop_error_AU.cLdSI(0, drop_error, break_flow || !input_rate_larger);
                        repeat_error = repeat_error_AU.cLdSI(0, repeat_error,  break_flow || input_rate_larger);
                    }
                    #else
                    {
                        drop_error = drop_error_AU.cLdSI(0, drop_error,
                                break_flow || (!KER_PROPAGATE_PROGRESSIVE && !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT)) || !input_rate_larger);
                        repeat_error = repeat_error_AU.cLdSI(0, repeat_error,
                                break_flow || (!KER_PROPAGATE_PROGRESSIVE && !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT)) || input_rate_larger);
                    }
                    #endif
                    // Reevaluate quick_drop for a controlled frame rate conversion
                    HW_KER_DEBUG_MSG("Writer: Frame rate control init state: drop_error=" << drop_error << ", repeat_error=" << repeat_error << std::endl);

                    // When synching on a specific field (excluding regular field drop case) then the frame rate conversion operates at the frame level
                    // and action are taken on the field we do not sync too
                    #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                        bool is_sync_field;
                        #if KER_PROPAGATE_PROGRESSIVE
                            //is_sync field is also true when a progressive frame is passed through
                            is_sync_field = !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) || (ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)
                                    == (KER_INTERLACED_BEHAVIOUR ==
                                      (KER_PASS_THROUGH_NEEDED ? KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1: KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F0)));
                        #else
                            // KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_?? syncs on what is or what would be the passthrough if it was used.
                            // transform that into is_sync_field that says whether the received field is the field we sync to.
                            is_sync_field = ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)
                                    == (KER_INTERLACED_BEHAVIOUR ==
                                      (KER_PASS_THROUGH_NEEDED ? KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1: KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F0));
                       #endif
                    #endif

                    // Starting with the drop
                    bool drop_error_trigger = drop_error.bit(KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH); // drop_error < 0, this usually means we should drop

                    // Adjusting drop_error when one of the field is allowed to pass
                    #if (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH)
                        // Synching on both means that input is interlaced and each field is able to produce a frame
                        // This could be considered equivalent to doubling the input frame rate
                        drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate << 1),
                                                             drop_error, !drop_error_trigger && !quick_drop, true);
                    #else
                        #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD) // SYNC_ON_SPECIFIC_INTERLACED_FIELD case
                            // If synchronizing on FX (from passthrough or first buffer) then change drop_error only when the FX field goes through,
                            // (or when a progressive frame pass through)
                            drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                                                     drop_error, !drop_error_trigger && !quick_drop && is_sync_field, true);
                        #else // REGULAR_FIELD_DROP case or progressive case
                            // If progressive inputs or if one field is regularly dropped, drop_error is updated only for fields that are not quickdropped
                            // no special case needed in the KER_PROPAGATE_PROGRESSIVE case
                            drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                                                 drop_error, !drop_error_trigger && !quick_drop, true);
                        #endif
                    #endif

                    // drop_error is increased at each "frame" iteration.
                    #if (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH)
                        // Increase drop_error for each field going through
                        drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                                                 drop_error, !quick_drop, false);
                        // When syncing on both fields, a drop triggers a second drop (the second field of a pair) that will not be counted
                        // because it will have the quickdrop status. Moreover, a progressive frame coming in should also be counted as two fields
                        #if KER_PROPAGATE_PROGRESSIVE
                            drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                                                     drop_error, !quick_drop && (drop_error_trigger || !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT)), false);
                        #else
                            drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                                                     drop_error, !quick_drop && drop_error_trigger, false);
                        #endif
                    #else
                        #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD) // SYNC_ON_SPECIFIC_INTERLACED_FIELD case
                            // When synching on a specific interlaced field, trigger the add on the field we DO NOT sync too. Whatever happens to the error,
                            // the field we sync too, coming next iteration, will have the same fate has this field depending on the value of quick_drop
                            // special case when a progressive frame is passed on.
                            #if KER_PROPAGATE_PROGRESSIVE
                                drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                        drop_error, !quick_drop && (!is_sync_field || !ker_input_field_interlace.bit(INTERLACE_FLAG_BIT)), false);
                            #else
                                drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                        drop_error, !quick_drop && !is_sync_field, false);
                            #endif
                        #else
                            // If progressive inputs or if one field is regularly dropped, drop_error is updated only for fields that are not quickdropped
                            // no special case needed in the KER_PROPAGATE_PROGRESSIVE case
                            drop_error = drop_error_AU.cAddSubSI(drop_error, sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                                                 drop_error, !quick_drop, false);
                        #endif
                    #endif

                    // Now for the repeat
                    // repeat_error is decreased at each iteration when a field goes through
                    repeat_factor = 0;
                    #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                        repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                   sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                   repeat_error, !quick_drop && is_sync_field, true);
                    #else
                        // If progressive inputs or if one field is regularly dropped, or sync_both, repeat_error is updated only for
                        // fields that are not quickdropped.
                        repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                   sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_output_frame_rate),
                                   repeat_error, !quick_drop, true);
                    #endif
                    // There is always at least 1 repeat
                    do
                    {
                        // Increase repeat_error for each field going through
                        #if (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_BOTH)
                            // When syncing on both fields, a progressive frame coming in should also be counted as two fields
                            #if !KER_PROPAGATE_PROGRESSIVE
                                // Only interlaced fields can go through and they all count for one output frame
                                repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate << 1),
                                        repeat_error, !quick_drop, false);
                            #else
                                repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                        repeat_error, !quick_drop, false);
                                // Interlaced fields count twice
                                repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                        repeat_error, !quick_drop && ker_input_field_interlace.bit(INTERLACE_FLAG_BIT),
                                        false);
                            #endif
                        #else
                            #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                                // When synching on either F0 or F1, repeat_factor is irrelevant for the field we do not sync too
                                // and repeat_error should not be affected
                                repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                        repeat_error, !quick_drop && is_sync_field, false);
                            #else
                                // For the REGULAR_FIELD_DROP case, unused F0/F1 fields are quick_dropped so this works well.
                                repeat_error = repeat_error_AU.cAddSubSI(repeat_error,
                                        sc_int<KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH+1>(ker_writer_input_frame_rate),
                                        repeat_error, !quick_drop, false);
                            #endif
                        #endif
                        ++repeat_factor;
                    } while (repeat_error.bit(KER_CONTROLLED_DROP_REPEAT_BIT_WIDTH) && !quick_drop); // while repeat_error >= 0, 1 iter only if quickdrop
                    vip_assert(repeat_factor != 0); //repeat_factor >= 1
                    HW_KER_DEBUG_MSG("Writer: Frame rate control end state: drop_error=" << drop_error
                                      << ", repeat_error=" << repeat_error << " (x" << repeat_factor << ")" << std::endl);
                    HW_KER_DEBUG_MSG_COND(!quick_drop && drop_error_trigger, "Writer: Field dropped by the frame rate control routine" << std::endl);
                    quick_drop = quick_drop || drop_error_trigger; //dropping all fields until drop_error goes above 0

                }
                #endif

                // Switch the ker_input_field_interlace nibble in case there is no control packet with the next field
                #if (KER_INPUT_IS_INTERLACED)
                {
                    // No need to perform the operation when expecting only progressive inputs.
                    // Moreover, switching the interlace bit around has no effect even for progressive passthrough frame so keep it simple
                    ker_input_field_interlace = (ker_input_field_interlace.bit(INTERLACE_FLAG_BIT),
                                             !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT),
                                             ker_input_field_interlace.range(INTERLACE_FIELD_TYPE_BIT-1,0));
                }
                #endif

                if (quick_drop)
                {
                    ker_discard_field();
                }
            } while(quick_drop);


            #if (KER_INPUT_IS_INTERLACED)
            {
                // Update current_field_type/current_field_interlace now
                #if (KER_PROPAGATE_PROGRESSIVE)
                {
                    // For progressive fields coming in, set up the field type bit of current_field_type using the user requested
                    // synchronization, if syncing on F0 (ie, buffer of second field is synced on F1) then we start by sending the F0
                    // made from from the progressive frame. Note that ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) has already
                    // been switched around so the current field is of type !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT)
                    #if (!KER_INTERLACED_OUTPUT)
                    {
                        current_field_type = sc_uint<2>((sc_uint<1>(ker_input_field_interlace.bit(INTERLACE_FLAG_BIT)),
                                                         sc_uint<1>(ker_input_field_interlace.bit(INTERLACE_FLAG_BIT) ?
                                                         !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) :
                                                         SYNC_ON_SPECIFIC_INTERLACED_FIELD && (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1))));
                    }
                    #else
                    {
                        // If the kernelizer is not weaving for its output then bit 0 is irrelevant when progressive frames are coming in
                        current_field_type = (ker_input_field_interlace.bit(INTERLACE_FLAG_BIT), !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT));
                    }
                    #endif
                    HW_KER_DEBUG_MSG_COND(!current_field_type.bit(1), "Writer: About to store a progressive field" << std::endl);
                    HW_KER_DEBUG_MSG_COND(current_field_type.bit(1) && !current_field_type.bit(0), "Writer: About to store a F0 field" << std::endl);
                    HW_KER_DEBUG_MSG_COND(current_field_type.bit(1) && current_field_type.bit(0), "Writer: About to store a F1 field" << std::endl);
                }
                #else
                {
                    current_field_interlace = !ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT);
                    HW_KER_DEBUG_MSG_COND(!current_field_interlace, "Writer: About to store a F0 field" << std::endl);
                    HW_KER_DEBUG_MSG_COND(current_field_interlace, "Writer: About to store a F1 field" << std::endl);
                }
                #endif
            }
            #else
            {
                HW_KER_DEBUG_MSG_COND(current_field_interlace, "Writer: About to pass on a progressive field" << std::endl);
            }
            #endif

            HW_KER_DEBUG_MSG_COND(break_flow, "Writer: runtime res change detected, flushing and starting with the new field" << std::endl);

            #if (KER_WRITE_MASTER_NEEDED)
            {
                // Saturating values going above their accepted limits when there is memory buffering
                ker_input_field_width = MIN(ker_input_field_width, sc_uint<HEADER_WORD_BITS*4>(KER_MAX_WIDTH));
                #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED))
                {
                    // Allowance for twice the field size when receiving and propagating a progressive input
                    ker_input_field_height = current_field_type.bit(1) ?
                             MIN(ker_input_field_height, sc_uint<HEADER_WORD_BITS*4>(KER_BUFFER_MAX_HEIGHT)) :
                             MIN(ker_input_field_height, sc_uint<HEADER_WORD_BITS*4>(KER_BUFFER_MAX_HEIGHT << 1));
                }
                #else
                {
                    ker_input_field_height = MIN(ker_input_field_height, sc_uint<HEADER_WORD_BITS*4>(KER_BUFFER_MAX_HEIGHT));
                }
                #endif

                if (break_flow)
                {
                    // Recompute samples_in_row and words_in_row.
                    #if (KER_CHANNELS_IN_SEQ == 1)
                        samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(ker_input_field_width);
                    #endif
                    #if (KER_CHANNELS_IN_SEQ == 2)
                        samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(ker_input_field_width << 1);
                    #endif
                    #if (KER_CHANNELS_IN_SEQ == 3)
                        samples_in_row = sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(ker_input_field_width << 1) + sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(ker_input_field_width);
                    #endif

                    HW_KER_DEBUG_MSG("Writer: new samples_in_row value " << samples_in_row << std::endl);

                    // AU and registers used by the divisor
                    ALT_AU<KER_LOG2G_MAX_SAMPLES_IN_ROW> DIVIDEND_AU;
                    sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW> dividend BIND(DIVIDEND_AU);
                    sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW + 1> divisor;
                    ALT_AU<KER_LOG2G_MAX_WORDS_IN_ROW> QUOTIENT_AU;
                    sc_uint<KER_LOG2G_MAX_WORDS_IN_ROW> quotient BIND(QUOTIENT_AU);
                    ALT_AU<KER_LOG2G_LOG2G_MAX_SAMPLES_IN_ROW> DIV_COUNTER_AU;
                    sc_uint<KER_LOG2G_LOG2G_MAX_SAMPLES_IN_ROW> div_counter BIND(DIV_COUNTER_AU);
                    ALT_CMP<KER_LOG2G_MAX_SAMPLES_IN_ROW + 1> DIV_CMP_AU;

                    dividend = samples_in_row;
                    divisor = KER_SAMPLES_IN_WORD;
                    div_counter = 0;
                    quotient = 0;
                    while (DIV_CMP_AU.gte(dividend, divisor))
                    {
                        divisor = divisor << 1;
                        div_counter = DIV_COUNTER_AU.addSubUI(div_counter, 1, false); //++div_counter
                    }
                    while (div_counter != 0)
                    {
                        divisor = divisor >> 1;
                        div_counter = DIV_COUNTER_AU.addSubUI(div_counter, 1, true); //--div_counter
                        quotient = quotient << 1; // quotient *= 2
                        // If (dividend >= divisor)
                        if (DIV_CMP_AU.gte(dividend,divisor))
                        {
                            // dividend -= divisor ...
                            dividend = DIVIDEND_AU.addSubUI(dividend, divisor, true);
                            // ... and word_counter += 1
                            quotient = QUOTIENT_AU.addSubUI(quotient, 1, false);
                        }
                    }
                    // word_counter += 1 if the div is not exact and there is a rest
                    quotient = QUOTIENT_AU.cAddSubUI(quotient, 1, quotient,
                                                  dividend != sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(0), false);
                    words_in_row = quotient;

                    HW_KER_DEBUG_MSG("Writer: new words_in_row value " << words_in_row << std::endl);
                }
            }
            #endif

            #if KER_WRITE_MASTER_NEEDED
            {
                #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED))
                {
                    // Set up write_address_swap to the address of the claimed buffer (even if it is not used)
                    // this will come in handy if a progressive field as to be stored into memory as two separate fields
                    write_address = buffer_addresses[claimed_buffer];
                    write_address_swap = write_address;
                }
                #endif

                // Set write address to start of chosen write buffer before posting the burst
                write_address = buffer_addresses[write_buffer];

                #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED)) && \
                    SYNC_ON_SPECIFIC_INTERLACED_FIELD && (KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_SYNC_ON_F1)
                {
                    // Since claimed buffer will be the "second field" sent as in "field the deinterlacer sync to", then swap adresses
                    // around to put the "progressive F0" into claimed_buffer rather than write_buffer if necessary
                    if (!current_field_type.bit(1))
                    {
                        CUSP_SWAP(write_address, write_address_swap, KER_MEM_ADDR_WIDTH);
                    }
                }
                #endif
            }
            #endif

            #if KER_PASS_THROUGH_NEEDED
            {
                // pass_through transmission protocol:
                // packet stream, IMAGE_DATA_HEADER, [field_type (opt), break_flow], width, height, (words_in_row optionnal), (samples_in_row optionnal), image stream, ...
                // With the passthrough we need to write the image data header to mark the end of the stream of packets
                FIFO_WRITE_DATA_AND_EOP(pass_through, ker_just_read, KER_BPS_PAR, KER_DIN->getEndPacket());
                // Also send the information about the field (new resolution, current type (0 for F0 and 1 for F1))
                // Once again note that ker_input_field_interlace.bit(INTERLACE_FIELD_TYPE_BIT) is ready for the next field and is opposite
                // to the type of the current field, hence the '!'
                #if KER_INPUT_IS_INTERLACED
                {
                    #if (KER_PROPAGATE_PROGRESSIVE)
                    {
                        pass_through.write((sc_uint<2>(current_field_type), sc_uint<1>(break_flow)));
                    }
                    #else
                    {
                        pass_through.write((sc_uint<1>(current_field_interlace), sc_uint<1>(break_flow)));
                    }
                    #endif
                }
                #else
                {
                    pass_through.write(sc_uint<1>(break_flow));
                }
                #endif
                pass_through.write(ker_input_field_width);
                pass_through.write(ker_input_field_height);
                #if (KER_WRITE_MASTER_NEEDED)
                {
                    pass_through.write(words_in_row);
                    pass_through.write(samples_in_row);
                }
                #endif
            }
            #endif

            HW_KER_DEBUG_MSG("Writer: writing the buffer into RAM and/or the passthrough" << std::endl);

            // Write the field (interlaced or progressive) into the buffer
            for (sc_int<KER_LOG2G_MAX_INPUT_FIELD_HEIGHT+1> j = sc_int<KER_LOG2G_MAX_INPUT_FIELD_HEIGHT+1>(ker_input_field_height) +
                   sc_int<1>(-1); (j >= sc_int<KER_LOG2G_MAX_INPUT_FIELD_HEIGHT+1>(0)) && !KER_DIN->getEndPacket(); --j)
            {
                #if KER_WRITE_MASTER_NEEDED
                {
                    if (words_in_row) write_master->busPostWriteBurst(write_address, words_in_row);
                }
                #endif
                for (sc_int<KER_LOG2G_MAX_SAMPLES_IN_ROW+1> i = sc_int<KER_LOG2G_MAX_SAMPLES_IN_ROW+1>(samples_in_row) +
                       sc_int<1>(-1); i >= sc_int<1>(0); --i)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    #if (KER_PASS_THROUGH_NEEDED)
                    {
                        if (!KER_DIN->getEndPacket())
                        {
                            ker_just_read = KER_DIN->read();
                            FIFO_WRITE_DATA_AND_EOP(pass_through, ker_just_read, KER_BPS_PAR, KER_DIN->getEndPacket());
                        }
                        #if KER_WRITE_MASTER_NEEDED
                        {
                            write_master->writePartialDataUI(ker_just_read); // The master expects data and the transfer cannot be interrupted
                        }
                        #endif
                    }
                    #else  //no passthrough, just a master
                    {
                        write_master->writePartialDataUI(KER_DIN->cRead(!KER_DIN->getEndPacket()));
                    }
                    #endif
                } // End of row
                // Finish off any partial word at the end of a line with zeros
                #if (KER_WRITE_MASTER_NEEDED)
                {
                    write_master->flush();
                    write_address = write_address_AU.addUI(write_address, KER_WORDS_IN_ALIGNED_ROW * KER_WORD_BYTES);
                    // if storing  a progressive frame as two interlaced fields then switch the buffer
                    #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED))
                    {
                        if (!current_field_type.bit(1))
                        {
                            CUSP_SWAP(write_address_swap, write_address, KER_MEM_ADDR_WIDTH);
                        }
                    }
                    #endif
                }
                #endif
            } // End of field
            // Discarding extra data
            HW_KER_DEBUG_MSG_COND(!KER_DIN->getEndPacket(), "Writer: field longer than expected, discarding extra data" << std::endl);
            while (!KER_DIN->getEndPacket())
            {
                KER_DIN->cRead(!KER_DIN->getEndPacket());
            }
            previous_field_width = ker_input_field_width;
            previous_field_height = ker_input_field_height;

#if KER_ALLOW_DROPPING
            // Take a decision about whether this field should be dropped
            #if SYNC_ON_SPECIFIC_INTERLACED_FIELD
                dropping = !buffers_read_to_write.hasDataAvail();
                // When synching on a specific interlaced field on might need to check that there are 2 buffers available:
                // one for the second field of the pair and one for the next frame
                // Fields are always returned by pair so it does not matter if we try to claim a buffer when we are already
                // at the second field since it will always be available
                if (!dropping && !have_claimed_buffer)
                {
                    have_claimed_buffer = true;
                    claimed_buffer = buffers_read_to_write.read();
                    dropping = !buffers_read_to_write.hasDataAvail();
                }
            #else
                // Special case for weave/ma mode synchronizing on both fields, make sure the claimed buffer for progressive frames gets reused
                #if (KER_PROPAGATE_PROGRESSIVE && (!KER_OUTPUT_IS_INTERLACED))
                    // Drop if there is nothing waiting but the claimed buffer can be used for interlaced fields
                    dropping = !buffers_read_to_write.hasDataAvail() && !(have_claimed_buffer && current_field_type.bit(1));
                #else
                    dropping = !buffers_read_to_write.hasDataAvail(); // Simple general case, drop if there is no buffer waiting
                #endif
            #endif
            HW_KER_DEBUG_MSG_COND(dropping, "Writer: no field from Reader, decided to drop" << std::endl);
            #if (EXPECTING_STRICT_F0_F1_SUCCESSION)
            {
                if (dropping)
                {
                    // We are dropping a F0 (or F1) field, this means the next F1 (or next F0) has to be dropped too
                    // A simple way of triggering that behaviour at next iteration is modifying the current_field_type variable
                    // It means that if the next field is again a F0 or a F1 then the field received at this iteration will
                    // be overwritten but this behaviour seems fine.
                    #if KER_PROPAGATE_PROGRESSIVE
                        current_field_type = (current_field_type.bit(1), !current_field_type.bit(0));
                    #else
                        current_field_interlace = !current_field_interlace;
                    #endif
                }
            }
            #endif
        } while (dropping);
#endif

        #if (!KER_PASS_THROUGH_NEEDED)
        {
            HW_KER_DEBUG_MSG("Writer: decided to pass the field to Reader" << std::endl);
            HW_KER_DEBUG_MSG("Writer: field is passed on with " << next_to_last_packet_id << " AvST packets, "
                                  "starting at packet position " << first_packet_id << std::endl);
            // Start by passing the address of the first packet (the reader thread will match packet_id to address)
            packets_write_to_read.write(first_packet_id);
            // With or without overflow, write the lengths of the packets from the arrays starting at 0 until next_to_last_packet_id (excluded)
            for (sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS> k = 0; k < sc_uint<KER_LOG2G_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS); ++k)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                if (k < next_to_last_packet_id)
                {
                    packets_write_to_read.write(packets_sample_length[k]);
                    packets_write_to_read.write(packets_word_length[k]);
                }
            }
            // Add a 0 to the packets_write_to_read queue to mark the end of the list of packets
            packets_write_to_read.write(0);
        }
        #endif

        // Send a message to the reader to say that there is a spare field with fresh data in it and give the buffer token.
        // If there is no passthrough fifo then the reader will need more information.
        #if (!KER_PASS_THROUGH_NEEDED)
        {
            // buffers_write_to_read transmission protocol:
            // 1: [field_type (opt, 1 or 2 bits), break_flow, buffer_token]
            // 2: width
            // 3: height
            // 4: word_per_row
            // 5: samples_per_row
            // 6: repeat_factor (for controlled drop repeat only)
            #if (KER_INPUT_IS_INTERLACED)
            {
                #if (KER_PROPAGATE_PROGRESSIVE)
                {
                    #if (!KER_OUTPUT_IS_INTERLACED)
                        sc_uint<KER_LOG2G_MAX_INPUT_FIELD_HEIGHT> field_height = previous_field_height;
                        // Two fields are sent when a progressive frame is split in two
                        if (!current_field_type.bit(1))
                        {
                            field_height = field_height >> 1;
                            HW_KER_DEBUG_MSG("Writer: passing buffer token " << write_buffer << " to Reader " << std::endl);
                            HW_KER_DEBUG_MSG("Writer: first field of a progressive frame" << std::endl);
                            buffers_write_to_read.write((sc_uint<2>(current_field_type), sc_uint<1>(break_flow), sc_uint<LOG2(KER_NUM_BUFFERS)>(write_buffer)));
                            current_field_type = (current_field_type.bit(1), !current_field_type.bit(0));
                            break_flow = false;
                            buffers_write_to_read.write(previous_field_width);
                            buffers_write_to_read.write(field_height);
                            buffers_write_to_read.write(words_in_row);
                            buffers_write_to_read.write(samples_in_row);
                            #if (KER_CONTROLLED_DROP_REPEAT)
                                buffers_write_to_read.write(repeat_factor);
                            #endif
                            // There is no packet to go with the "second field"
                            packets_write_to_read.write(0);
                            packets_write_to_read.write(0);
                            write_buffer = claimed_buffer;
                            #if (KER_ALLOW_DROPPING || KER_CONTROLLED_DROP_REPEAT)
                                have_claimed_buffer = false;
                            #endif
                        }
                    #else
                        sc_uint<KER_LOG2G_MAX_INPUT_FIELD_HEIGHT> field_height BIND(ALT_WIRE);
                        field_height = previous_field_height;
                    #endif
                    HW_KER_DEBUG_MSG("Writer: passing buffer token " <<  write_buffer << " to Reader " << std::endl);
                    HW_KER_DEBUG_MSG_COND(current_field_type.bit(1), "Writer: field type = " << current_field_type.bit(0) << std::endl);
                    HW_KER_DEBUG_MSG_COND(!current_field_type.bit(1) && !KER_OUTPUT_IS_INTERLACED, "Writer: second field of a progressive frame" << std::endl);
                    HW_KER_DEBUG_MSG_COND(!current_field_type.bit(1) && KER_OUTPUT_IS_INTERLACED, "Writer: progressive frame stored in a single buffer" << std::endl);
                    buffers_write_to_read.write((sc_uint<2>(current_field_type), sc_uint<1>(break_flow), sc_uint<LOG2(KER_NUM_BUFFERS)>(write_buffer)));
                    buffers_write_to_read.write(previous_field_width);
                    buffers_write_to_read.write(field_height);
                }
                #else
                {
                    HW_KER_DEBUG_MSG("Writer: passing buffer token " << write_buffer << " to Reader " << std::endl);
                    buffers_write_to_read.write((sc_uint<1>(current_field_interlace), sc_uint<1>(break_flow), sc_uint<LOG2(KER_NUM_BUFFERS)>(write_buffer)));
                    buffers_write_to_read.write(previous_field_width);
                    buffers_write_to_read.write(previous_field_height);
                }
                #endif
            }
            #else
            {
                buffers_write_to_read.write(sc_uint<1>(break_flow), sc_uint<LOG2(KER_NUM_BUFFERS)>(write_buffer)));
                buffers_write_to_read.write(previous_field_width);
                buffers_write_to_read.write(previous_field_height);
            }
            #endif

            // Common to all cases (for the only buffer or the second buffer)
            buffers_write_to_read.write(words_in_row);
            buffers_write_to_read.write(samples_in_row);
            #if (KER_CONTROLLED_DROP_REPEAT)
                buffers_write_to_read.write(repeat_factor);
            #endif
        }
        #else
        {
            // If there is a passthrough FIFO then everything was sent through it but the buffer token
            buffers_write_to_read.write(write_buffer);
        }
        #endif

        // Reset break_flow
        break_flow = false;

        // Receive a new buffer token from the reader (or use the claimed one) and write on it at the next loop iteration,
        #if ( (((KER_ALLOW_DROPPING) && (SYNC_ON_SPECIFIC_INTERLACED_FIELD)) || ((KER_PROPAGATE_PROGRESSIVE) && (!KER_OUTPUT_IS_INTERLACED))) \
              && ((KER_ALLOW_DROPPING) || (KER_CONTROLLED_DROP_REPEAT)) )
                write_buffer = claimed_buffer;
                if (!have_claimed_buffer)
                    write_buffer = buffers_read_to_write.read();
                // have_claimed buffer is reset to false at the beginning of the next loop iteration
        #else
            // This call may block with double buffering
            // ALT_DELAY to prevent CUSP from scheduling read and write on the same cycle which would cause a deadlock
            ALT_DELAY(write_buffer = buffers_read_to_write.read(), 1);
        #endif
        HW_KER_DEBUG_MSG("Writer: received buffer token " << write_buffer << " from Reader " << std::endl);
    }
}


/*******************************************************************************************************************************************************
 * The Reader thread which reads from the different buffers/passthrough and creates kernel to build the output
 *******************************************************************************************************************************************************/

#if KER_PASS_THROUGH_NEEDED
    #define NUMBER_OF_FIELDS_NEEDED (KER_OLDEST_BUFFER_READ + 1)
#else
    #define NUMBER_OF_FIELDS_NEEDED KER_OLDEST_BUFFER_READ
#endif

// A small macro which contains code to perform a rotating buffer swap on the output
// hopefully soon CusP will be able to handle inlined functions with reference arguments,
// and then this can become a proper function
#define READER_SWAP_BUFFERS(FRESH_BUFFER)                                                        \
{                                                                                                \
    /* Report state of read_buffers[] before the swap */                                         \
    HW_KER_DEBUG_MSG("Reader: READER_SWAP_BUFFERS called with " << #FRESH_BUFFER << std::endl);  \
    NO_CUSP(dbg_report_read_buffers(read_buffers));                                              \
                                                                                                 \
    /* Send oldest buffer back to writer */                                                      \
    HW_KER_DEBUG_MSG("Reader: sending buffer token " <<                                          \
           read_buffers[KER_OLDEST_BUFFER_READ - 1] << " to Writer" << std::endl);               \
    buffers_read_to_write.write(read_buffers[KER_OLDEST_BUFFER_READ - 1]);                       \
                                                                                                 \
    /* Shift all the buffers around one */                                                       \
    for (int i = KER_OLDEST_BUFFER_READ - 1; i > 0; i--)                                         \
    {                                                                                            \
        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);                                                   \
        read_buffers[i] = read_buffers[i - 1];                                                   \
    }                                                                                            \
                                                                                                 \
    /* buffer[0] is the newest, that gets the fresh buffer */                                    \
    read_buffers[0] = FRESH_BUFFER;                                                              \
                                                                                                 \
    /* Report the final state before finishing */                                                \
    HW_KER_DEBUG_MSG("Reader: end of READER_SWAP_BUFFERS" << std::endl);                         \
    NO_CUSP(dbg_report_read_buffers(read_buffers));                                              \
}

// A small macro which contains code to work out what source number to use for
// the given reader at the given row, and assigns it into the passed variable
// hopefully soon CusP will let us make this into a real function too.
// Two cases depending on whether reader_b_sources is used for even lines.
#if EXPECTING_STRICT_F0_F1_SUCCESSION
#define GET_SOURCE_FOR_READER(reader_id, row, result)                                  \
{                                                                                      \
        result = ((reader_b_sources[reader_id] == -1)                                  \
               || (pass_through_is_odd == IS_ODD(row))) ? reader_a_sources[reader_id]  \
                                                        : reader_b_sources[reader_id]; \
}
#else
#define GET_SOURCE_FOR_READER(reader_id, row, result)                                  \
{                                                                                      \
        result = reader_a_sources[reader_id];                                          \
}
#endif

// Resize and 0 the line buffers (if they are used)
#if (KER_ALL_READERS_KERNEL_HEIGHT > 1)
#define RESIZE_LINE_BUFFERS  \
    for (unsigned int r = 0; r < KER_NUM_READERS; ++r)                                                          \
    {                                                                                                           \
        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);                                                                  \
        line_buffers[r].setTapLength(MAX(sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>(3),current_samples_in_row));                                                   \
    }                                                                                                           \
    /* The number of lines that need to be zeroed depends on the position of the center pixel */                \
    for (unsigned int i = 0; i < KER_MAX_WIDTH * KER_CHANNELS_IN_SEQ * KER_ALL_READERS_OUTPUT_PIXEL_Y; i++)     \
    {                                                                                                           \
        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);                                                            \
        ALT_ATTRIB(ALT_MOD_TARGET, 1);                                                                          \
        ALT_ATTRIB(ALT_MIN_ITER, KER_MAX_WIDTH * KER_CHANNELS_IN_SEQ * KER_ALL_READERS_OUTPUT_PIXEL_Y);         \
        for (unsigned int r = 0; r < KER_NUM_READERS; ++r)                                                      \
        {                                                                                                       \
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);                                                              \
            line_buffers[r].write(sc_uint<KER_BPS_PAR>(0));                                                     \
        }                                                                                                       \
    }
#else
#define RESIZE_LINE_BUFFERS
#endif

// The Reader thread responsible for reading from buffers and creating kernels for output
void ker_reader()
{

    sc_uint<HEADER_WORD_BITS*4> current_field_width;
    sc_uint<HEADER_WORD_BITS*4> current_field_height;

    sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_WORDS> read_word_counter;

    sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT> output_field_height;

    // Status of the passthrough field (whether it is used or not)
    #if KER_INPUT_IS_INTERLACED
        bool pass_through_is_odd = (KER_REGULAR_FIELD_DROP == KERNELISER_REGULAR_FIELD_DROP_F0);
        #if KER_PROPAGATE_PROGRESSIVE
            bool progressive_frame_flag = false;
        #endif
    #endif

    // This array of constants is filled in for us by parameter helper with the
    // base address of each (frame or field) buffer. Use LEs rather than memory
    #if KER_WRITE_MASTER_NEEDED

    /*
    unsigned int initial_buffer_addresses[KER_NUM_BUFFERS] = KER_BUFFER_ADDRESSES;
    ALT_REGISTER_FILE<-1, 2, 1, -1, 1, 1, 0, ALT_MEM_MODE_LE> buffer_addresses_MEM;
    unsigned int buffer_addresses[KER_NUM_BUFFERS] BIND(buffer_addresses_MEM);
    for (unsigned int i = 0; i < KER_NUM_BUFFERS; i++)
    {
         ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
         buffer_addresses[i] = initial_buffer_addresses[i];
    }
    */
    unsigned int buffer_addresses[KER_NUM_BUFFERS] = KER_BUFFER_ADDRESSES;

    #if (!KER_PASS_THROUGH_NEEDED)
        /*
        unsigned int initial_packet_addresses[KER_NUM_BUFFERS] = KER_PACKET_ADDRESSES;
        ALT_REGISTER_FILE<-1, 2, 1, -1, 1, 1, 0, ALT_MEM_MODE_LE> packet_addresses_MEM;
        unsigned int packet_addresses[KER_NUM_BUFFERS] BIND(packet_addresses_MEM);
        for (unsigned int i = 0; i < KER_NUM_BUFFERS; i++)
        {
             ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
             packet_addresses[i] = initial_packet_addresses[i];
        }
        */
        unsigned int packet_addresses[KER_NUM_BUFFERS] = KER_PACKET_ADDRESSES;
        sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES> read_length_counter;
    #endif

    // This array of constants is filled in for us by parameter helper with the
    // correct master number to be used by each reader (there will be -1s for
    // readers which don't use masters). Use LEs rather than memory.
    /*
    unsigned int initial_master_for_reader[KER_NUM_READERS] = KER_MASTER_FOR_READER;
    ALT_REGISTER_FILE<-1, 2, 1, -1, 1, 1, 0, ALT_MEM_MODE_LE> master_for_reader_MEM;
    unsigned int master_for_reader[KER_NUM_READERS] BIND(master_for_reader_MEM);
    for (unsigned int i = 0; i < KER_NUM_READERS; i++)
    {
         ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
         master_for_reader[i] = initial_master_for_reader[i];
    }
    */
    const unsigned int master_for_reader[KER_NUM_READERS] = KER_MASTER_FOR_READER;

    const unsigned int reader_a_sources[KER_NUM_READERS] = KER_READER_A_SOURCES;
    #if (EXPECTING_STRICT_F0_F1_SUCCESSION)
        const unsigned int reader_b_sources[KER_NUM_READERS] = KER_READER_B_SOURCES;
    #endif

    // The number of lines to buffer before one can starts outputting, this depends on the
    // position of the center pixel in the kernel.
    const int rows_to_skip_at_start = (KER_ALL_READERS_KERNEL_HEIGHT - 1) - KER_ALL_READERS_OUTPUT_PIXEL_Y;

    #if (KER_ALLOW_REPEATING)
        bool repeat;
        #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
            // Used in the sync on F1 or sync on F0 case. claimed_field and have_claimed_field allow the reader to claim a
            // buffer without necessarily doing a swap. This is required because the reader need two buffers in this case
            // and the fifo FU can't tell how many data elements are available.
            sc_uint<LOG2(KER_NUM_BUFFERS)> claimed_field = 0;
            bool have_claimed_field = false;
            // Sometimes the first buffer of a pair triggers a flush and we must not wait for the second one
            bool claimed_field_is_breaking_flow = false;
            bool claimed_field_is_odd = false;
        #endif
    #endif
    #if (KER_CONTROLLED_DROP_REPEAT)
            // The writer thread tells the reader how many times a field/pair of fields/frames should be repeated
            // this is stored in repeat_factor
            sc_uint<KER_WRITER_CTRL_INTERFACE_WIDTH> repeat_factor;
    #endif

    sc_uint<FIELD_INFO_WIDTH> from_writer;

    DECLARE_VAR_WITH_REG(sc_uint<KER_LOG2G_MAX_WORDS_IN_ROW>, KER_LOG2G_MAX_WORDS_IN_ROW, current_words_in_row);
    DECLARE_VAR_WITH_REG(sc_uint<KER_LOG2G_MAX_SAMPLES_IN_ROW>, KER_LOG2G_MAX_SAMPLES_IN_ROW, current_samples_in_row);
#endif


    HW_KER_DEBUG_MSG("Reader: Initialising" << std::endl);

    // Start up with ownership from buffers one onwards
    sc_uint<LOG2(KER_NUM_BUFFERS)> read_buffers[KER_OLDEST_BUFFER_READ];
    for (unsigned int i = 0; i < KER_OLDEST_BUFFER_READ; i++)
    {
        read_buffers[i] = i + 1;
    }
    // All other spare buffers (if any) should start queued up to be written to, so
    // put them into the writer's message fifo
    for (unsigned int i = KER_OLDEST_BUFFER_READ + 1; i < KER_NUM_BUFFERS; i++)
    {
        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
        buffers_read_to_write.write(i);
    }

    HW_KER_DEBUG_MSG("Reader: Starting main loop" << std::endl);
    for (;;)
    {
        // How many buffers should be extracted? 2 or 1? have_claimed_field should be true most of the time
        // but the first iteration. The break_flow flag is expected from the writer with the first iteration
        // and this shoulod trigger a complete refresh of the read buffers
        #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
            sc_int<LOG2(KER_NUM_BUFFERS)+1> swaps_to_perform = 1; // Two swaps are necessary
        #else
            sc_int<LOG2(KER_NUM_BUFFERS)+1> swaps_to_perform = 0;
        #endif

        bool break_flow = false; // Keep a flag to inform the output that a flush has occured

        while (swaps_to_perform >= sc_int<LOG2(KER_NUM_BUFFERS)+1>(0))
        {
            HW_KER_DEBUG_MSG("Reader: Processing packets and status from the current field (buffered or passthrough)" << std::endl);
            #if (KER_WRITE_MASTER_NEEDED)
            {
                #if (!KER_PASS_THROUGH_NEEDED) // Deal with the packets and the extra tokens in the FIFO
                {
                    //KER_ALLOW_REPEATING_CASE, the first buffer might have been claimed already and should be used for the first swap
#if (KER_ALLOW_REPEATING && SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                    if (have_claimed_field)
                    {
                        READER_SWAP_BUFFERS(claimed_field);
                        packet_read_base_address = packet_addresses[claimed_field];
                        have_claimed_field = false;                // Do not forget to put that one back to 0
                        // If runtime res change flag went up all the buffers are to be discarded and replaced
                        if (claimed_field_is_breaking_flow)
                        {
                            // If synching on a specific field there is the possibility that the field received is not useful,
                            // it depends on what is the type we need for the oldest buffer when building the output
                            swaps_to_perform = (claimed_field_is_odd == SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1) ?
                                                            NUMBER_OF_FIELDS_NEEDED - 1 : NUMBER_OF_FIELDS_NEEDED;
                            RESIZE_LINE_BUFFERS;
                            break_flow = true;
                            HW_KER_DEBUG_MSG("Reader: Field claimed previously has break_flow flag, flushing for " << swaps_to_perform << " new buffer." << std::endl);
                            HW_KER_DEBUG_MSG_COND((claimed_field_is_odd == SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1), "Reader: Claimed field is kept." << std::endl);
                            HW_KER_DEBUG_MSG_COND((claimed_field_is_odd != SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1), "Reader: Claimed field cannot be used." << std::endl);
                        }
                        claimed_field_is_breaking_flow = false;    // Do not forget to put that one back to 0 too
                    }
                    else
                    {
#endif
                        from_writer = buffers_write_to_read.read();
                        current_field_width = buffers_write_to_read.read();
                        current_field_height = buffers_write_to_read.read();
                        current_words_in_row = buffers_write_to_read.read();
                        current_samples_in_row = buffers_write_to_read.read();
                        #if (KER_CONTROLLED_DROP_REPEAT)
                            repeat_factor = buffers_write_to_read.read();
                        #endif
                        // For reference: buffers_write_to_read transmission protocol: 1:[field_type, break_flow, buffer_token], 2:width, 3:height, 4:word_per_row, 5:samples per row
                        #if KER_INPUT_IS_INTERLACED
                            pass_through_is_odd = !from_writer.bit(LOG2(KER_NUM_BUFFERS)+1); // Passthrough is of opposite type of the field in the buffer
                            #if KER_PROPAGATE_PROGRESSIVE
                                progressive_frame_flag = !from_writer.bit(LOG2(KER_NUM_BUFFERS)+2);
                            #endif
                        #endif
                        READER_SWAP_BUFFERS(from_writer.range(LOG2(KER_NUM_BUFFERS)-1,0));
                        packet_read_base_address = packet_addresses[from_writer.range(LOG2(KER_NUM_BUFFERS)-1,0)];
                        if (from_writer.bit(LOG2(KER_NUM_BUFFERS)))  //break_flow is on ?
                        {
                            //in the SYNC_ON_SPECIFIC_INTERLACED_FIELD case, two swaps are needed and previously claimed buffer might be in use
                            #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                            {
                                swaps_to_perform = (pass_through_is_odd != SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1) ?
                                                        NUMBER_OF_FIELDS_NEEDED - 1 : NUMBER_OF_FIELDS_NEEDED;
                            }
                            #else
                            {
                                swaps_to_perform = NUMBER_OF_FIELDS_NEEDED - 1; // The field in the buffer is ok and can still be used
                            }
                            #endif
                            RESIZE_LINE_BUFFERS;
                            break_flow = true;
                            HW_KER_DEBUG_MSG("Reader: Field received has break_flow flag, flushing for " << swaps_to_perform << " new buffer." << std::endl);
                            HW_KER_DEBUG_MSG_COND(SYNC_ON_SPECIFIC_INTERLACED_FIELD && (pass_through_is_odd != SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1), "Reader: Field received is kept." << std::endl);
                            HW_KER_DEBUG_MSG_COND(SYNC_ON_SPECIFIC_INTERLACED_FIELD && (pass_through_is_odd == SYNC_ON_SPECIFIC_INTERLACED_FIELD_OLDEST_IS_F1), "Reader: Field received cannot be used." << std::endl);
                            HW_KER_DEBUG_MSG_COND(!SYNC_ON_SPECIFIC_INTERLACED_FIELD, "Reader: Field received is kept." << std::endl);
                        }
#if (KER_ALLOW_REPEATING && SYNC_ON_SPECIFIC_INTERLACED_FIELD)
                    }
#endif
                    // In the general case do --swaps_to_perform as expected
                    #if !(KER_INPUT_IS_INTERLACED && !SYNC_ON_SPECIFIC_INTERLACED_FIELD && KER_PROPAGATE_PROGRESSIVE && !KER_OUTPUT_IS_INTERLACED)
                    {
                        --swaps_to_perform;
                    }
                    #else
                    {
                        // But there is a special case when processing a progressive frame, and when !SYNC_ON_SPECIFIC_INTERLACED_FIELD.
                        // One needs to get the second field of the frame immediately and make sure not to mix 2 progressive frames together
                        bool first_field_of_prog_frame BIND(ALT_WIRE);
                        first_field_of_prog_frame = (swaps_to_perform == sc_int<LOG2(KER_NUM_BUFFERS)+1>(0)) && progressive_frame_flag && pass_through_is_odd;
                        HW_KER_DEBUG_MSG_COND(first_field_of_prog_frame, "Reader: First field of a progressive frame, requesting second field immediately" << std::endl);
                        if (!first_field_of_prog_frame)
                        {
                            --swaps_to_perform;
                        }
                    }
                    #endif
                    /* Propagate packets (until the 0 marker is found) */
                    vip_assert(packets_write_to_read.hasDataAvail());
                    packet_read_address = packet_read_base_address;
                    sc_uint<KER_LOG2_MAX_NUMBER_PACKETS> current_packet_id = packets_write_to_read.read();
                    HW_KER_DEBUG_MSG("Reader: Processing packets starting from packet_id " << current_packet_id << std::endl);
                    // Compute address of the first packet (a bit slow but this should do ok)
                    sc_int<KER_LOG2_MAX_NUMBER_PACKETS + 1> packet_id = sc_int<KER_LOG2_MAX_NUMBER_PACKETS + 1>(current_packet_id);
                    for (packet_id = packet_id + sc_int<1>(-1); packet_id >= sc_int<1>(0); --packet_id)
                    {
                        packet_read_address = packet_read_address_AU.addSubSLd(packet_read_address,
                                          sc_uint<KER_MEM_ADDR_WIDTH>(KER_WORDS_IN_ALIGNED_PACKET * KER_WORD_BYTES),
                                          packet_read_base_address /* don't care */,
                                          false,
                                          false);
                    }
                    // Get length of next packet and send until 0 is found
                    read_length_counter = packets_write_to_read.read();
                    while (read_length_counter != sc_uint<KER_LOG2G_MAX_PACKET_LENGTH_IN_SAMPLES>(0))
                    {
                        HW_KER_DEBUG_MSG("read_output_from_memory, sending packet (size = " << read_length_counter << " * "
                                     << KER_CHANNELS_IN_PAR << "), from address " << packet_read_address << std::endl);
                        // Get read_word_counter from the queue
                        read_word_counter = packets_write_to_read.read();
                        HW_KER_DEBUG_MSG("read_output_from_memory, packet length in memory words = " << read_word_counter << std::endl);
                        // Discard unused data from a previous read
                        read_master[0].discard();
                        // Send the Avalon ST packet
                        read_master[0].busPostReadBurst(packet_read_address, read_word_counter);
                        for (int length_cnt = read_length_counter - sc_uint<2>(2); length_cnt >= 0; --length_cnt)
                        {
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            FIFO_WRITE_DATA_AND_EOP(KER_DOUT, read_master[0].collectPartialReadUI(), KER_BPS_PAR, false);
                        }
                        FIFO_WRITE_DATA_AND_EOP(KER_DOUT, read_master[0].collectPartialReadUI(), KER_BPS_PAR, true);
                        packet_read_address = packet_read_address_AU.addSubSLd(packet_read_address,
                                              sc_uint<KER_MEM_ADDR_WIDTH>(KER_WORDS_IN_ALIGNED_PACKET * KER_WORD_BYTES),
                                              packet_read_base_address,
                                              current_packet_id == sc_uint<KER_LOG2_MAX_NUMBER_PACKETS>(KER_MAX_NUMBER_PACKETS - 1),
                                              false);
                        ++current_packet_id; // No need to reset this counter even if going over its limit
                        read_length_counter = packets_write_to_read.read();
                    }
                }
                #else
                {
                    //TODO: behave differently here when there is a passthrough...
                }
                #endif
            }
            #else
                //TODO: behave differently here when there is no master?
            #endif
        }

        // Install a do .. while loop structure for the two cases that can trigger frame repeating (controlled and uncontrolled)
#if ((KER_ALLOW_REPEATING) || (KER_CONTROLLED_DROP_REPEAT))
        bool not_a_repeat = true;
        do
        {
#endif
            HW_KER_DEBUG_MSG("Reader: Trying to produce an output" << std::endl);
            FIFO_WRITE_BIG_DATA_AND_EOP(KER_DOUT, IMAGE_DATA, HEADER_WORD_BITS, false);
            FIFO_WRITE_BIG_DATA_AND_EOP(KER_DOUT, current_field_width, HEADER_WORD_BITS*4, false);
            FIFO_WRITE_BIG_DATA_AND_EOP(KER_DOUT, current_field_height, HEADER_WORD_BITS*4, false);
            #define FRAME_INFO_WIDTH (KER_INPUT_IS_INTERLACED ? 1 : 0) + (KER_PROPAGATE_PROGRESSIVE ? 1 : 0 ) + ((KER_ALLOW_REPEATING || KER_CONTROLLED_DROP_REPEAT) ? 1 : 0) + 1
            sc_uint<FRAME_INFO_WIDTH> frame_info BIND(ALT_WIRE);
            #if KER_INPUT_IS_INTERLACED
                #if KER_PROPAGATE_PROGRESSIVE
                    frame_info |= sc_uint<1>(!progressive_frame_flag);
                    frame_info <<= 1;
                #endif
                frame_info |= sc_uint<1>(KER_PASS_THROUGH_NEEDED ? pass_through_is_odd : !pass_through_is_odd);
                frame_info <<= 1;
            #endif
            #if (KER_ALLOW_REPEATING || KER_CONTROLLED_DROP_REPEAT)
                frame_info |= sc_uint<1>(not_a_repeat);
                frame_info <<= 1;
                not_a_repeat = false; //next ouput will be a repeat if we do not exit the do ... while loop
            #endif
            frame_info |= sc_uint<1>(break_flow);
            FIFO_WRITE_BIG_DATA_AND_EOP(KER_DOUT, frame_info, FRAME_INFO_WIDTH, false);

            unsigned int row_offset = 0;

            bool last_sample = false; // To know when the eop should be sent

            output_field_height =
                        KER_INPUT_IS_INTERLACED ? (KER_OUTPUT_IS_INTERLACED ?
                                                       sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT>(current_field_height) :
                                                       sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT>(current_field_height << 1)) :
                                                  (KER_OUTPUT_IS_INTERLACED ?
                                                       sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT>(current_field_height >> 1) :
                                                       sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT>(current_field_height));

            sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT+1> j_delta = -sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT+1>(output_field_height); // j_delta = j - output_field_height in the loop that follows
            for (sc_uint<KER_READER_HEIGHT_COUNTER_WIDTH> j = 0;
                 j < sc_uint<KER_READER_HEIGHT_COUNTER_WIDTH>(output_field_height + sc_uint<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT>(KER_ALL_READERS_KERNEL_HEIGHT - 1));
                 j++)
            {
                // All actions which pull data from sources (this includes posting burst reads) are predicated
                // on this not being one of the finish-off lines at the end of a frame
                vip_assert(sc_int<KER_READER_HEIGHT_COUNTER_WIDTH+1>(j) ==
                           sc_int<KER_READER_HEIGHT_COUNTER_WIDTH+1>(sc_int<KER_READER_HEIGHT_COUNTER_WIDTH+1>(j_delta) +
                                                                     sc_int<KER_READER_HEIGHT_COUNTER_WIDTH+1>(output_field_height)));
                // Writing any output is predicated on this being one of the block of KER_HEIGHT lines to output
                bool is_finish_off_row = (j_delta >= sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT+1>(0));
                //last_sample gets set when (j_delta reaches rows_to_skip_at_start)
                bool should_output_row = (j >= sc_uint<KER_READER_HEIGHT_COUNTER_WIDTH>(rows_to_skip_at_start)) && !last_sample;

                // If this is not a finish_off line then post the reads
                if (!is_finish_off_row)
                {
                    // Registers to store the source that is to be used for each reader (see GET_SOURCE_FOR_READER macro)
                    ALT_REG<8> SOURCE_REGS[KER_NUM_READERS];
                    unsigned char source[KER_NUM_READERS] BIND(SOURCE_REGS);

                    // Reads are posted one row in advance to prevent stalling in case of bus contention.
                    for (unsigned int r = 0; r < KER_NUM_READERS; r++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        GET_SOURCE_FOR_READER(r, j, source[r]);
                        if (source[r] != 0)
                        {
                            read_master[master_for_reader[r]].discard();

                            // Post the initial read for the first row now
                            if (j == sc_uint<KER_READER_HEIGHT_COUNTER_WIDTH>(0))
                            {
                                unsigned int read_address = buffer_addresses[read_buffers[source[r] - 1]];
                                #if KER_PROPAGATE_PROGRESSIVE_IGNORE_EXTRA_FIELDS
                                    if ((r<2) || !progressive_frame_flag)
                                    {
                                        read_master[master_for_reader[r]].busPostReadBurstUI(read_address, current_words_in_row);
                                    }
                                #else
                                    read_master[master_for_reader[r]].busPostReadBurstUI(read_address, current_words_in_row);
                                #endif

                            }
                        }
                    }
                    // Prepare the offset for the next read (but do not advance yet if deinterlacing is in effect)
                    #if !KER_OUTPUT_IS_INTERLACED
                        if ((KER_INTERLACED_BEHAVIOUR == KERNELISER_INTERLACED_BEHAVIOUR_OFF) || IS_ODD(j))
                        {
                            row_offset += KER_WORDS_IN_ALIGNED_ROW * KER_WORD_BYTES;
                        }
                    #else
                        row_offset += KER_WORDS_IN_ALIGNED_ROW * KER_WORD_BYTES;
                    #endif

                    // Post the read for the next line (j+1) now
                    if (j_delta != - 1) // j != output_field_height - 1
                    {
                        for (unsigned int r = 0; r < KER_NUM_READERS; r++)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            // Look up the source for this reader on this row (woven sources alternate)
                            GET_SOURCE_FOR_READER(r, j + sc_uint<KER_READER_HEIGHT_COUNTER_WIDTH>(1), source[r]);
                            // If the source isn't pass-through then post a burst read on the right master
                            // for this reader
                            if (source[r] != 0)
                            {
                                unsigned int read_address = buffer_addresses[read_buffers[source[r] - 1]];
                                #if KER_PROPAGATE_PROGRESSIVE_IGNORE_EXTRA_FIELDS
                                    if ((r<2) || !progressive_frame_flag)
                                    {
                                        read_master[master_for_reader[r]].busPostReadBurstUI(read_address + row_offset, current_words_in_row);
                                    }
                                #else
                                    read_master[master_for_reader[r]].busPostReadBurstUI(read_address + row_offset, current_words_in_row);
                                #endif
                            }
                        }
                    }
                } // end of "if (!is_not_finish_off_row)"

                ++j_delta; //increment the copy of j-output_field_height

                // Some notes on tricks used to help cusp produce good modulo scheduled hardware for the
                // iterating-over-pix-in-a-row loop below
                // 1. most of the unusual looking code is here to help out with if-conversion. there are some
                //    situations where what we'd like to do is just assign one of a few different possibilities
                //    to a variable and the natural way to do this would be nested if-else statements. instead, to
                //    help cusp what we do is assign the different possibilites into different variables and then
                //    use ?: to select between them. ifs are used minimally, just to make sure that operations
                //    with side effects like reading from a master don't happen when they shouldn't.
                // 2. mod target 1 has to be on in order to get mod 1, because the auto staging optimisation is
                //    needed to handle the boolean variables is_finish_off_pix and should_output_pix.
                // 3. the strange way ifs have been written (see 1) makes it difficult for compilers to see that
                //    all of the variables are initialised before they are used. cusp requires this, so some
                //    variables have initialisations to zero that are not strictly required. if the variables are
                //    registers then that means that they have to be declared outside the loop even if only used
                //    in the loop so that the initialisation to zero operation doesn't interfere with the schedule.
                // 4. ALT_WIREs have been used to collapse a lot of shifting and orring into what is in hardware
                //    just a concatenation.
                // 5. A lot of things have to be arrays with a separate instance used for each element of the unrolled
                //    readers loop, this is because cusp won't realise that since they are assigned to before being
                //    read in each instance of the loop, each use is entirely separate.

                // Either contains samples pulled fresh from read masters, or is undefined if it's not actually
                // going to be used
                ALT_REG<KER_BPS_PAR> SAMPLES_FROM_MASTER_SOURCES_REGS[KER_NUM_READERS];
                sc_uint<KER_BPS_PAR> samples_from_master_sources[KER_NUM_READERS] BIND(SAMPLES_FROM_MASTER_SOURCES_REGS);

                // Either contains samples pulled fresh from the pass through or is undefined if it's not actually
                // going to be used
                ALT_REG<KER_BPS_PAR> SAMPLES_FROM_PASS_THROUGH_SOURCES_REGS[KER_NUM_READERS];
                sc_uint<KER_BPS_PAR> samples_from_pass_through_sources[KER_NUM_READERS] BIND(SAMPLES_FROM_PASS_THROUGH_SOURCES_REGS);

                // If the bottom right of the kernel is in the image, then this is a mux of samples from master sources
                // and samples from pass through sources, otherwise it is zero
                ALT_REG<KER_BPS_PAR> SAMPLES_FROM_SOURCES_POST_ZEROING_REGS[KER_NUM_READERS];
                sc_uint<KER_BPS_PAR> samples_from_sources_post_zeroing[KER_NUM_READERS] BIND(SAMPLES_FROM_SOURCES_POST_ZEROING_REGS);

                // Zero a few registers before starting to satisfy the compiler
                for (int r = 0; r < KER_NUM_READERS; r++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    samples_from_master_sources[r] = 0;
                    samples_from_pass_through_sources[r] = 0;
                    samples_from_sources_post_zeroing[r] = 0;
                }

                // Run along the pixels of a row, reading from all of the readers and constructing
                // an output word
                sc_int<KER_READER_WIDTH_COUNTER_WIDTH+1> i_delta = -sc_int<KER_READER_WIDTH_COUNTER_WIDTH+1>(current_samples_in_row);
                bool last_sample_in_row = false;
                for (sc_uint<KER_READER_WIDTH_COUNTER_WIDTH> i = 0; i <
                              sc_uint<KER_READER_WIDTH_COUNTER_WIDTH>(current_samples_in_row +
                                    sc_uint<KER_READER_WIDTH_COUNTER_WIDTH>((KER_ALL_READERS_KERNEL_WIDTH - 1) * KER_CHANNELS_IN_SEQ)); i++)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 32*KER_CHANNELS_IN_SEQ);

                    // All actions which pull data from sources (reading from the pass through fifo or one of the master
                    // fifos) are predicated on this not being one of the finish-off pixels at the end of a row
                    bool is_finish_off_pix = (i_delta >= sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_WIDTH+1>(0));
                    // Actually writing any output is predicated on this being one of the block of KER_WIDTH pixels
                    // which should be output
                    const int pix_to_skip_at_start = ((KER_ALL_READERS_KERNEL_WIDTH - 1) - KER_ALL_READERS_OUTPUT_PIXEL_X);
                    bool should_output_pix = (i_delta >= sc_int<KER_READER_WIDTH_COUNTER_WIDTH+1>
                                                            (sc_int<KER_READER_WIDTH_COUNTER_WIDTH+1>(pix_to_skip_at_start * KER_CHANNELS_IN_SEQ) -
                                                             sc_int<KER_READER_WIDTH_COUNTER_WIDTH+1>(current_samples_in_row))) && !last_sample_in_row;
                    last_sample_in_row = last_sample_in_row ||
                                   (i_delta == sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_WIDTH+1>((pix_to_skip_at_start*KER_CHANNELS_IN_SEQ)-1));

                    ++i_delta; // increment the copy of i-current_samples_in_row

                    last_sample = ((j_delta == sc_int<KER_LOG2G_MAX_OUTPUT_FIELD_HEIGHT+1>(rows_to_skip_at_start)) &&
                                                  last_sample_in_row);

                    // This is the concatenation of all of the requested pixels
                    sc_biguint<KER_BPS_PAR * KER_NUM_PIX_REQ> output_word BIND(ALT_WIRE);

                    // This is the concatenation of all of the pixels in the rightmost column of the requested kernel
                    // if the rightmost column of the kernel is not off the edge of the source image - undefined otherwise
                    sc_biguint<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT> output_rcol[KER_NUM_READERS] BIND(ALT_WIRE);
                    // The same as output_rcol if output_rcol is defined, zero otherwise
                    sc_biguint<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT> output_rcol_post_zeroing[KER_NUM_READERS] BIND(ALT_WIRE);
                    // Zero a few ALT_WIREs to satisfy the compiler
                    output_word = 0;
                    for (int r = 0; r < KER_NUM_READERS; r++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        output_rcol[r] = 0;
                    }
                    // The source for each reader
                    // in many cases this should optimise to a constant and disappear
                    ALT_REG<8> SOURCE_REGS[KER_NUM_READERS];
                    unsigned char source[KER_NUM_READERS] BIND(SOURCE_REGS);

                    // For storing the output of the line buffers into a register, a bit inefficient but it
                    // avoids ALT_WIRE issues
                    #if (KER_ALL_READERS_KERNEL_HEIGHT > 1)
                        ALT_REG<KER_BPS_PAR * (KER_ALL_READERS_KERNEL_HEIGHT - 1)> LINE_BUFFER_SAMPLES_REGS[KER_NUM_READERS];
                        sc_biguint<KER_BPS_PAR * (KER_ALL_READERS_KERNEL_HEIGHT - 1)> line_buffer_samples[KER_NUM_READERS] BIND(LINE_BUFFER_SAMPLES_REGS);
                    #endif

                    // For storing the output of the horizontal buffers into a register, a bit inefficient but it
                    // avoids ALT_WIRE issues
                    #if (KER_ALL_READERS_KERNEL_WIDTH > 1)
                        ALT_REG<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT * (KER_ALL_READERS_KERNEL_WIDTH - 1)> HOZ_BUFFER_SAMPLES_REGS[KER_NUM_READERS];
                        sc_biguint<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT * (KER_ALL_READERS_KERNEL_WIDTH - 1)> hoz_buffer_samples[KER_NUM_READERS] BIND(HOZ_BUFFER_SAMPLES_REGS);
                    #endif

                    for (int r = KER_NUM_READERS - 1; r >= 0; r--)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

                        // Look up the source for this reader on this row (woven sources alternate)
                        GET_SOURCE_FOR_READER(r, j, source[r]);

                        // If the source is non-zero, get the data from the appropriate master, otherwise
                        // get it from the pass-through
                        #if (KER_WRITE_MASTER_NEEDED)
                        {
                            #if KER_PROPAGATE_PROGRESSIVE_IGNORE_EXTRA_FIELDS
                            {
                                if ((source[r] != 0) && !is_finish_off_row && !is_finish_off_pix &&
                                    ((r<2) || !progressive_frame_flag))
                                {
                                    samples_from_master_sources[r] = read_master[master_for_reader[r]].collectPartialReadUI();
                                }
                            }
                            #else
                            {
                                if ((source[r] != 0) && !is_finish_off_row && !is_finish_off_pix)
                                {
                                    samples_from_master_sources[r] = read_master[master_for_reader[r]].collectPartialReadUI();
                                }
                            }
                            #endif
                        }
                        #endif
                        #if (KER_PASS_THROUGH_NEEDED)
                        {
                            #if KER_PROPAGATE_PROGRESSIVE_IGNORE_EXTRA_FIELDS
                            {
                                if ((source[r] != 0) && !is_finish_off_row && !is_finish_off_pix &&
                                    ((r<2) || !progressive_frame_flag))
                                {
                                    samples_from_pass_through_sources[r] = pass_through.read();
                                }
                            }
                            #else
                            {
                                if ((source[r] != 0) && !is_finish_off_row && !is_finish_off_pix)
                                {
                                    samples_from_pass_through_sources[r] = pass_through.read();
                                }
                            }
                            #endif
                        }
                        #endif
                        #if KER_PROPAGATE_PROGRESSIVE_IGNORE_EXTRA_FIELDS
                            samples_from_sources_post_zeroing[r] = (!is_finish_off_row && !is_finish_off_pix && ((r<2) || !progressive_frame_flag)) ?
                                                                    ((source[r] != 0) ? samples_from_master_sources[r] : samples_from_pass_through_sources[r]) :
                                                                    sc_uint<KER_BPS_PAR>(0);
                        #else
                            samples_from_sources_post_zeroing[r] = (!is_finish_off_row && !is_finish_off_pix) ?
                                                                    ((source[r] != 0) ? samples_from_master_sources[r] : samples_from_pass_through_sources[r]) :
                                                                    sc_uint<KER_BPS_PAR>(0);
                        #endif
                        // If vertical kernelisation is happening, push the data from the source into the line buffers
                        // for this reader, pull the output from the line buffers and add that to the rightmost column too
                        #if (KER_ALL_READERS_KERNEL_HEIGHT > 1)
                        {
                            line_buffer_samples[r] = line_buffers[r].read();
                            output_rcol[r] = (output_rcol[r] << (KER_BPS_PAR * (KER_ALL_READERS_KERNEL_HEIGHT - 1))) | line_buffer_samples[r];
                            // All of this is producing a junk rightmost column if the kernel overlaps the rightmost edge
                            // that doesn't matter because it will be replaced with zeros, but it is important that the line buffers
                            // are not affected
                            if (!is_finish_off_pix)
                            {
                                line_buffers[r].write(samples_from_sources_post_zeroing[r]);
                            }
                        }
                        #endif

                        // Add the data from the source to the rightmost column
                        output_rcol[r] = (output_rcol[r] << KER_BPS_PAR) | samples_from_sources_post_zeroing[r];

                        // The code above will produce a junk rightmost column if the kernel overlaps the right edge of the
                        // image, so replace with zeros
                        output_rcol_post_zeroing[r] = (!is_finish_off_pix) ? output_rcol[r] : sc_biguint<KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT>(0);

                        // If horizontal kernelisation is happening, push the data from the right column into the horizontal
                        // buffers for this reader, pull the output and add that to the output word too
                        #if (KER_ALL_READERS_KERNEL_WIDTH > 1)
                        {
                            hoz_buffer_samples[r] = hoz_buffers[r].read();
                            output_word = (output_word << (KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT * (KER_ALL_READERS_KERNEL_WIDTH - 1))) | hoz_buffer_samples[r];
                            hoz_buffers[r].write(output_rcol_post_zeroing[r]);
                        }
                        #endif

                       // Add the data from the rightmost column to the output word
                        output_word = (output_word << (KER_BPS_PAR * KER_ALL_READERS_KERNEL_HEIGHT)) | output_rcol_post_zeroing[r];
                    }

                    // If channels in parallel are in use, then at this stage output word will contain all requested pixels
                    // of all requested colours, in pixel major order, e.g. R1G1B1 R2G2B2 etc.
                    // the spec says that the kerneliser outputs in channel major order (R1R2 G1G2 B1B2 in the above example)
                    // so we need a few wires to do a little rearrangement
                    sc_biguint<KER_BPS_PAR * KER_NUM_PIX_REQ> rearrange_out_wire BIND(ALT_WIRE) = output_word;
                    for (int c = 0; c < KER_CHANNELS_IN_PAR; c++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

                        sc_biguint<KER_BPS_PAR * KER_NUM_PIX_REQ> rearrange_in_wire BIND(ALT_WIRE) = output_word;

                        // First shift the in word down so that the samples for colour c are in the
                        // least significant part of each pixel
                        rearrange_in_wire >>= (KER_BPS * c);

                        // Now loop over pixels required, pushing into the output
                        for (int p = 0; p < KER_NUM_PIX_REQ; p++)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

                            rearrange_out_wire >>= KER_BPS;
                            rearrange_out_wire |= rearrange_in_wire << (KER_BPS * (KER_CHANNELS_IN_PAR * KER_NUM_PIX_REQ - 1));
                            rearrange_in_wire >>= (KER_BPS * KER_CHANNELS_IN_PAR);
                        }
                    }
                    sc_biguint<KER_BPS_PAR * KER_NUM_PIX_REQ> rearrange_out = rearrange_out_wire;
                    if (should_output_row && should_output_pix)
                    {
                        FIFO_WRITE_BIG_DATA_AND_EOP(KER_DOUT, rearrange_out, KER_BPS_PAR * KER_NUM_PIX_REQ, last_sample);
                    }
                }
            }
            HW_KER_DEBUG_MSG("Reader: Produced an output frame/field" << std::endl);

// Close the do ... while loop structure when repeating a frame is trigered by the storage space still being dirty (triple buffering)
#if (KER_ALLOW_REPEATING)
            // Take a decision now about whether we should repeat the output
            repeat = !buffers_write_to_read.hasDataAvail();

            // If we are same rate deinterlacing, we need to swap two buffers
            // (buffers are fields in this case) or none at all
    #if (SYNC_ON_SPECIFIC_INTERLACED_FIELD)
            // If we already claimed a buffer during a previous iteration but could not get the second one then it would be ok to do the swap now
            // Otherwise check whether there is a second element waiting in the FIFO
            if (!repeat && !have_claimed_field)
            {
                from_writer = buffers_write_to_read.read();
                claimed_field = from_writer.range(LOG2(KER_NUM_BUFFERS)-1,0);
                claimed_field_is_breaking_flow = from_writer.bit(LOG2(KER_NUM_BUFFERS));
                claimed_field_is_odd = from_writer.bit(LOG2(KER_NUM_BUFFERS) + 1);
                // We load the other values as well, they are not supposed to change unless
                // claimed_field_is_breaking_flow (in which case we will exit the loop)
                current_field_width = buffers_write_to_read.read();
                current_field_height = buffers_write_to_read.read();
                // KER_ALLOW_REPEATING implies the usage of masters (the FIFO contains words_in_rows and samples_in_row)
                current_words_in_row = buffers_write_to_read.read();
                current_samples_in_row = buffers_write_to_read.read();
                have_claimed_field = true;
                repeat = !buffers_write_to_read.hasDataAvail(); // Update repeat depending on wheteher the second field is already there
            }
            HW_KER_DEBUG_MSG_COND(repeat && !claimed_field_is_breaking_flow, "Reader: decision to repeat taken" << std::endl);
            HW_KER_DEBUG_MSG_COND(repeat && claimed_field_is_breaking_flow, "Reader: claimed field breaking flow, repeat skipped" << std::endl);
            HW_KER_DEBUG_MSG_COND(!repeat, "Reader: Moving to next field/frame" << std::endl);
        } while (repeat && !claimed_field_is_breaking_flow);
    #else
            HW_KER_DEBUG_MSG_COND(repeat, "Reader: decision to repeat taken" << std::endl);
            HW_KER_DEBUG_MSG_COND(!repeat, "Reader: Moving to next field/frame" << std::endl);
        } while (repeat);
    #endif
#endif
// Close the do ... while loop structure when repeating a frame is trigered by the deterministic frame rate conversion algorithm
#if (KER_CONTROLLED_DROP_REPEAT)
            --repeat_factor;
        } while (repeat_factor != 0);
#endif
    }
}
