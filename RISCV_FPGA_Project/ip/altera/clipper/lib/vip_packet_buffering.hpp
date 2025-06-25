// vip_packet_buffering.hpp
// author: vshankar
//
// This code performs non-image-data packet reading/storing for the VIP cores. It can optionally record
// the width, height, and interlacing details from the last control packet before the image data. It can
// optionally send user packets into memory. It should be included inside the SC_MODULE from which
// it will be used.

// handleNonImagePackets() should be called when the next sample in the stream is the start of a
// packet (i.e. a type identifier). After return, the defined symbols for width, PACKET_BUF_HEIGHT_VAR
// and interlacing will be set to the values in the most recent control packet and the stream will be pointing
// at the first sample of image data. The type for image data will not yet have been passed on, allowing for
// updated control packets to be inserted before image processing begins.
//
// Parameterise it by setting the following #defines:
//
// PACKET_BUF_ENTRY_POINT the function name to be called to start handling packets. Default is handleNonImagePackets
//
// PACKET_BUF_ST_INPUT port name to use for input. Default is din
//
// PACKET_BUF_MM_OUTPUT port name to use for memory output. Default is write_master
//
// PACKET_BUF_BPS bits per sample
//
// PACKET_BUF_CHANNELS_IN_PAR channels in parallel
//
// PACKET_BUF_JUST_READ_VAR a variable name to store the most recently read word from input, should be declared as an
//                      sc_uint<PACKET_BPS*PACKET_CHANNELS_IN_PAR>
//
// PACKET_BUF_WIDTH_VAR a variable name to store the width.
//                   It should be declared as an sc_uint<HEADER_WORD_BITS*4> with associated _REG FU. If undefined,
//                   the width will not be stored and cheaper hardware will be produced.
//
// PACKET_BUF_HEIGHT_VAR a variable name to store the height.
//                   It should be declared as an sc_uint<HEADER_WORD_BITS*4> with associated _REG FU. If undefined,
//                   the height will not be stored and cheaper hardware will be produced.
//
// PACKET_BUF_INTERLACING_VAR a variable name to store the interlacing.
//                   It should be declared as an sc_uint<HEADER_WORD_BITS> with associated _REG FU. If undefined,
//                   the interlacing will not be stored and cheaper hardware will be produced.
//
// PACKET_BUF_HAS_CHANGED_VAR an (optional) variable name to store the boolean indicating whether any information in control packets
//                        has changed since the variable was last reset. Be sure to switch over the interlaced field type bit
//                        every field so that PACKET_BUF_HAS_CHANGED_VAR can trigger when the interlace flag is not as expected
//                        Calling code must do the initialisation and reset.
//
// PACKET_BUF_MAX_NUMBER_PACKETS the variable that specifies how many user packets can be stored in memory, 0 is an allowed value
//
// PACKET_BUF_MAX_WORDS_IN_PACKET maximum size of each packet (in number of memory words)
//
// PACKET_BUF_WORDS_IN_ALIGNED_PACKET number of words between two packets once memory alignment issues are taken into account
//
// PACKET_BUF_BURST_TARGET burst target that should be equal to the maximum burst size defined for PACKET_MM_OUTPUT
//
// PACKET_BUF_LENGTH_COUNTER a length counter with associated AU, properly sized to count the number of samples in user packets
//                            optional if packets are not stored in memory
//
// PACKET_BUF_WORD_COUNTER a word counter with associated AU, properly sized to count the number of word in user packets
//                            optional if packets are not stored in memory
// PACKET_BUF_WORD_COUNTER_WIDTH its width
//
// PACKET_BUF_TRIGGER_COUNTER a trigger counter with associated AU, to increase the number of words each time the number of samples
//                            written to memory reached the approriate threshold
// PACKET_BUF_TRIGGER_COUNTER_WIDTH its width
//
// PACKET_BUF_SAMPLES_IN_WORD number of samples per words
//
// PACKET_BUF_FIRST_PACKET when too many user packets have been written to memory, older packets are discarded first. Assuming
//                         that packets in memory are numbered from 0 to MAX_NUMBER_PACKETS depending on their relative mem address
//                         PACKET_BUF_FIRST_PACKET is usually 0 but it starts sliding when we overflow and old packets are
//                         discarded. Caller is responsible for initialisation
//
// PACKET_BUF_NEXT_TO_LAST_PACKET the id of the last packet written into memory (+1)
//                                Caller is responsible for initialisation
//
// PACKET_BUF_OVERFLOW_FLAG flag set after writing the max allowed number of packets
//                                Caller is responsible for initialisation to false
//
// PACKET_BUF_OVERFLOW_TRIGGER trigger used to reinitialise the address to write packet at the base address (used at initialization and when overflowing)
//                                Caller is responsible for initialisation to -1
//
// PACKET_BUF_CURRENT_ADDRESS the address for writing the current packet in memory.
//                            Caller may have to reinitialise it every call but it usually would remain the same if
//                            a field is drop and we want to continue the buffering packet where it was left
//
// PACKET_BUF_BASE_ADDRESS  when too many words have been written to memory, older user packets are discarded first.
//                         PACKET_MM_BASE_ADDRESS is the address of the first packet for the current buffer. PACKET_BUF_CURRENT_ADDRESS is
//                         reset to this address when we are wrapping around.
//
// PACKET_BUF_WRITE_ADDRESS write_address register used to issue write bursts
//
// PACKET_BUF_LENGTH_ARRAY storage for the lengths of all the packet (in samples)
//
// PACKET_BUF_WORD_ARRAY storage for the lengths of all the packet (in words)
//
// PACKET_BUF_ADDR_WIDTH size of address bus
//
// PACKET_BUF_WORD_BYTES number of bytes per memory words
//

#ifndef PACKET_BUF_ENTRY_POINT
#define PACKET_BUF_ENTRY_POINT handleNonImagePackets
#endif

#ifndef PACKET_BUF_ST_INPUT
#define PACKET_BUF_ST_INPUT din
#endif

#ifndef PACKET_BUF_MM_OUTPUT
#define PACKET_BUF_MM_OUTPUT write_master
#endif

#ifdef PACKET_BUF_HAS_CHANGED_VAR
    #ifndef PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE
        #define PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE defined(PACKET_BUF_WIDTH_VAR)
    #endif
    #ifndef PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE
        #define PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE defined(PACKET_BUF_HEIGHT_VAR)
    #endif
    #ifndef PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE
        #define PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE defined(PACKET_BUF_INTERLACING_VAR)
    #endif
#else
    #define PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE false
    #define PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE false
    #define PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE false
#endif

#if PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, saveWidth)
#endif
#if PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, saveHeight)
#endif
#if PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, saveInterlace)
#endif

#define PACKET_BUF_BPS_PAR (PACKET_BUF_BPS * PACKET_BUF_CHANNELS_IN_PAR)

// Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
sc_uint<PACKET_BUF_BPS> justReadQueue[PACKET_BUF_CHANNELS_IN_PAR] BIND(ALT_WIRE);

bool isNotImageData;

// void readCtrlPacket(int occurrence)
// For reading control packet data when we do not expect the previous read to have been EOP
// If an early EOP had occured, no more reads are taken from PACKET_BUF_ST_INPUT
//
// To abstract away the fact that control packets can come in parallel, this function either reads from PACKET_BUF_ST_INPUT,
// or advances the justReadQueue array. To decide which to do, it needs to know how many times it has been called. Since
// Cusp is not be able to figure out that an incrementing counter can be evaluated at compile-time, the function much be
// called with a number indicating which occurence it is being used in. It will do an actual read
// when occurrence%PACKET_BUF_CHANNELS_IN_PAR == 0
//
// @param occurrence the amount of times this function has been called in a sequence
// @pre   isNotImageData is set to true if the read should be skipped
void readCtrlPacket(int occurrence)
{
    if (occurrence % PACKET_BUF_CHANNELS_IN_PAR == 0)
    {
        bool isPreviousEndPacket BIND(ALT_WIRE) = PACKET_BUF_ST_INPUT->getEndPacket();
        PACKET_BUF_JUST_READ_VAR = MK_FNAME(PACKET_BUF_JUST_READ_VAR, REG).cLdUI(PACKET_BUF_ST_INPUT->cRead(!isPreviousEndPacket && isNotImageData), PACKET_BUF_JUST_READ_VAR, !isPreviousEndPacket && isNotImageData);

        // Should be able to use .range(), but Cusp is weak, so use a wire and shifting
        // to get to the words inside PACKET_BUF_BUF_JUST_READ_VAR
        sc_uint<PACKET_BUF_BPS_PAR> justReadAccessWire BIND(ALT_WIRE) = PACKET_BUF_JUST_READ_VAR;
        for (int i = 0; i < PACKET_BUF_CHANNELS_IN_PAR; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            justReadQueue[i] = justReadAccessWire;
            justReadAccessWire >>= PACKET_BUF_BPS;
        }
    }
    else
    {
        for (int i = 0; i < PACKET_BUF_CHANNELS_IN_PAR - 1; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            justReadQueue[i] = justReadQueue[i + 1];
        }
    }
}

void PACKET_BUF_ENTRY_POINT()
{
    #if PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE
        saveWidth = PACKET_BUF_WIDTH_VAR;
    #endif
    #if PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE
        saveHeight = PACKET_BUF_HEIGHT_VAR;
    #endif
    #if PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE
        saveInterlace = PACKET_BUF_INTERLACING_VAR;
    #endif

    do
    {
        PACKET_BUF_JUST_READ_VAR = PACKET_BUF_ST_INPUT->read();

        isNotImageData = (PACKET_BUF_JUST_READ_VAR != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));
        bool isControlPacket = (PACKET_BUF_JUST_READ_VAR == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER));

        if (isNotImageData && !isControlPacket)
        {
            // User packet, store in memory if required
            #if PACKET_BUF_MAX_NUMBER_PACKETS
            {
                // Store the packet at appropriate address and compute its length simultaneously
                HW_DEBUG_MSG("packet_buffering, storing user packet" << std::endl);

                // Prepare PACKET_BUF_CURRENT_ADDRESS for packet, wrap around if necessary
                PACKET_BUF_CURRENT_ADDRESS = MK_FNAME(PACKET_BUF_CURRENT_ADDRESS, AU).addSubSLdUI(PACKET_BUF_CURRENT_ADDRESS,
                                                                      sc_uint<PACKET_BUF_ADDR_WIDTH>(PACKET_BUF_WORDS_IN_ALIGNED_PACKET << LOG2(PACKET_BUF_WORD_BYTES)),
                                                                      PACKET_BUF_BASE_ADDRESS,
                                                                      PACKET_BUF_OVERFLOW_TRIGGER.bit(LOG2(PACKET_BUF_MAX_NUMBER_PACKETS)),
                                                                      false);

                // Init the counters
                PACKET_BUF_LENGTH_COUNTER = 0;
                PACKET_BUF_WORD_COUNTER = 0;

                // Send the header
                PACKET_BUF_MM_OUTPUT->writePartialDataUI(PACKET_BUF_JUST_READ_VAR);
                PACKET_BUF_LENGTH_COUNTER = MK_FNAME(PACKET_BUF_LENGTH_COUNTER, AU).addSubUI(PACKET_BUF_LENGTH_COUNTER, sc_uint<1>(1), false);

                // Init trigger including the initial write for the header
                PACKET_BUF_TRIGGER_COUNTER = PACKET_BUF_SAMPLES_IN_WORD - 2;

                // Set write address to address of current packet
                PACKET_BUF_WRITE_ADDRESS = PACKET_BUF_CURRENT_ADDRESS;

                while (!PACKET_BUF_ST_INPUT->getEndPacket())
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 3);
                    ALT_ATTRIB(ALT_SKIDDING, true);

                    // Did we write the last sample of a word?
                    bool word_counter_trigger_flag BIND(ALT_WIRE) = PACKET_BUF_TRIGGER_COUNTER.bit(PACKET_BUF_TRIGGER_COUNTER_WIDTH-1);

                    // Did we write the last sample before overflow last loop iteration?
                    bool overflow_flag BIND(ALT_WIRE) = ((PACKET_BUF_WORD_COUNTER == sc_uint<PACKET_BUF_WORD_COUNTER_WIDTH>(PACKET_BUF_MAX_WORDS_IN_PACKET-1)) &&
                                              word_counter_trigger_flag);

                    // Are we writting data this iteration?
                    bool active_write_flag BIND(ALT_WIRE) = !overflow_flag && !PACKET_BUF_ST_INPUT->getEndPacket();

                    // Increment word_counter by 1 each time the trigger reaches -1 (unless this is not an active write cycle)
                    // Even if the last sample was written previous iteration, word_counter may be increased once more.
                    // This is because the overflow condition can only be detected one cycle too late to avoid a data dependency
                    // loop (overflow_flag depends on word_counter so word_counter cannot depend on overflow_flag computed this iteration)
                    PACKET_BUF_WORD_COUNTER = MK_FNAME(PACKET_BUF_WORD_COUNTER, AU).cAddSubUI(PACKET_BUF_WORD_COUNTER,
                                                                 sc_uint<1>(1), PACKET_BUF_WORD_COUNTER,
                                                                 active_write_flag && word_counter_trigger_flag,
                                                                 false);
                    // Cycle word_counter_trigger and increase number of words if necessary
                    PACKET_BUF_TRIGGER_COUNTER = MK_FNAME(PACKET_BUF_TRIGGER_COUNTER, AU).cAddSubSLdSI(
                                        PACKET_BUF_TRIGGER_COUNTER, sc_int<1>(-1),                 // General case, --PACKET_BUF_TRIGGER_COUNTER
                                        PACKET_BUF_SAMPLES_IN_WORD - 2,                            // -1 reached previous iteration? reinitialise and count the write
                                        PACKET_BUF_TRIGGER_COUNTER,                                // Stay at current value if !enable
                                        active_write_flag,                                         // Enable line
                                        word_counter_trigger_flag,                                 // sLd line, reinit if word_counter_trigger == -1 (unless enable is false)
                                        false);                                                    // Always add -1


                    PACKET_BUF_JUST_READ_VAR = PACKET_BUF_ST_INPUT->cRead(!PACKET_BUF_ST_INPUT->getEndPacket());

                    // Increment length_counter if !eop (and if new sample can be written)
                    PACKET_BUF_LENGTH_COUNTER = MK_FNAME(PACKET_BUF_LENGTH_COUNTER, AU).cAddSubUI(
                                            PACKET_BUF_LENGTH_COUNTER, sc_uint<1>(1),        // General case, ++PACKET_BUF_LENGTH_COUNTER
                                            PACKET_BUF_LENGTH_COUNTER,
                                            active_write_flag,                               // Active line
                                            false);                                          // Always add -1

                    if (active_write_flag)            // Do the write if not eop and not past the last sample of the last word
                    {
                        PACKET_BUF_MM_OUTPUT->writePartialDataUI(PACKET_BUF_JUST_READ_VAR);
                    }

                    // Is it time to post a full burst?
                    // Post a new burst when writing the first sample of the last word of a burst
                    #if (PACKET_BUF_MAX_WORDS_IN_PACKET >= PACKET_BUF_BURST_TARGET)
                    {
                        bool burst_trigger = sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_WORD_COUNTER) ==
                            sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_BURST_TARGET-1) && word_counter_trigger_flag;

                        // New burst ?
                        if (active_write_flag && burst_trigger)
                        {
                            HW_DEBUG_MSG("packet_buffering, posting burst " << PACKET_BUF_BURST_TARGET << " at addr " << PACKET_BUF_WRITE_ADDRESS << std::endl);
                            PACKET_BUF_MM_OUTPUT->busPostWriteBurst(PACKET_BUF_WRITE_ADDRESS, PACKET_BUF_BURST_TARGET);
                            PACKET_BUF_WRITE_ADDRESS += (PACKET_BUF_BURST_TARGET << LOG2(PACKET_BUF_WORD_BYTES));
                        }
                    }
                    #endif
                }

                // Is there a need for a last burst?
                bool no_last_burst = (sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_WORD_COUNTER) == sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_BURST_TARGET-1));

                // Finish and count the last word
                PACKET_BUF_MM_OUTPUT->flush();
                ++PACKET_BUF_WORD_COUNTER;

                // Post the last burst (probably the first in most cases), truncate PACKET_BUF_WORD_COUNTER to get the size
                if (!no_last_burst)
                {
                    HW_DEBUG_MSG("packet_buffering, posting last burst " << sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_WORD_COUNTER) << " at addr " << PACKET_BUF_WRITE_ADDRESS << std::endl);
                    PACKET_BUF_MM_OUTPUT->busPostWriteBurst(PACKET_BUF_WRITE_ADDRESS, sc_uint<LOG2(PACKET_BUF_BURST_TARGET)>(PACKET_BUF_WORD_COUNTER));
                }

                HW_DEBUG_MSG("packet_buffering, user packet stored. " << PACKET_BUF_LENGTH_COUNTER << " * " << PACKET_BUF_CHANNELS_IN_PAR
                                     << " samples (including header), " << PACKET_BUF_WORD_COUNTER << " words, at adress "
                                     << PACKET_BUF_CURRENT_ADDRESS << std::endl);

                PACKET_BUF_OVERFLOW_TRIGGER = MK_FNAME(PACKET_BUF_OVERFLOW_TRIGGER, AU).addSubSLdSI(PACKET_BUF_OVERFLOW_TRIGGER,
                                                                                      sc_int<1>(-1),
                                                                                      sc_int<1+LOG2(PACKET_BUF_MAX_NUMBER_PACKETS)>(PACKET_BUF_MAX_NUMBER_PACKETS - 2),
                                                                                      PACKET_BUF_OVERFLOW_TRIGGER.bit(LOG2(PACKET_BUF_MAX_NUMBER_PACKETS)),
                                                                                      false);

                // Store length of packet at appropriate location
                for (unsigned int k = 0; k < PACKET_BUF_MAX_NUMBER_PACKETS; ++k)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    PACKET_BUF_LENGTH_ARRAY[k] = MK_FNAME(PACKET_BUF_LENGTH_ARRAY, REG[k]).cLdUI(PACKET_BUF_LENGTH_COUNTER,
                                        PACKET_BUF_LENGTH_ARRAY[k],
                                        PACKET_BUF_OVERFLOW_FLAG ? (PACKET_BUF_FIRST_PACKET  == sc_uint<LOG2G(PACKET_BUF_MAX_NUMBER_PACKETS)>(k)) :
                                                               (PACKET_BUF_NEXT_TO_LAST_PACKET == sc_uint<LOG2G(PACKET_BUF_MAX_NUMBER_PACKETS)>(k)));
                    PACKET_BUF_WORD_ARRAY[k] = MK_FNAME(PACKET_BUF_WORD_ARRAY, REG[k]).cLdUI(PACKET_BUF_WORD_COUNTER,
                                        PACKET_BUF_WORD_ARRAY[k],
                                        PACKET_BUF_OVERFLOW_FLAG ? (PACKET_BUF_FIRST_PACKET  == sc_uint<LOG2G(PACKET_BUF_MAX_NUMBER_PACKETS)>(k)) :
                                                               (PACKET_BUF_NEXT_TO_LAST_PACKET == sc_uint<LOG2G(PACKET_BUF_MAX_NUMBER_PACKETS)>(k)));
                }
                // Increment next_to_last_PACKET_BUF_id for next packet or maintain if overflowing
                PACKET_BUF_NEXT_TO_LAST_PACKET = MK_FNAME(PACKET_BUF_NEXT_TO_LAST_PACKET, AU).cAddSubUI(
                                            PACKET_BUF_NEXT_TO_LAST_PACKET, sc_uint<1>(1),
                                            PACKET_BUF_NEXT_TO_LAST_PACKET, !PACKET_BUF_OVERFLOW_FLAG, false);

                // Increment first_PACKET_BUF_id (if overflow), wrap around if necessary
                PACKET_BUF_FIRST_PACKET = MK_FNAME(PACKET_BUF_FIRST_PACKET, AU).cAddSubSLdUI(
                                      PACKET_BUF_FIRST_PACKET, sc_uint<1>(1),                                  // + 1
                                      sc_uint<LOG2G(PACKET_BUF_MAX_NUMBER_PACKETS)>(0),                        // Wrapping around
                                      PACKET_BUF_FIRST_PACKET,                                                 // Maintain current value
                                      PACKET_BUF_OVERFLOW_FLAG,                                                // Maintain to 0 if !overflow
                                      PACKET_BUF_OVERFLOW_TRIGGER.bit(LOG2(PACKET_BUF_MAX_NUMBER_PACKETS)),    // -> Wrap around
                                      false);                                                                  // Always an addition of +1
                // Set overflow flag to true the first time the overflow trigger is set
                PACKET_BUF_OVERFLOW_FLAG = MK_FNAME(PACKET_BUF_OVERFLOW_FLAG, REG).cLdUI(true, PACKET_BUF_OVERFLOW_FLAG,
                        PACKET_BUF_OVERFLOW_TRIGGER.bit(LOG2(PACKET_BUF_MAX_NUMBER_PACKETS)));
            }
            #else
            {
                HW_DEBUG_MSG("packet_buffering, discarding user packet" << std::endl);
            }
            #endif // Buffering of user packets
        }
        else
        {
            HW_DEBUG_MSG_COND(isNotImageData, "packet_buffering, processing control packet" << std::endl);

            #if defined(PACKET_BUF_WIDTH_VAR) || defined(PACKET_BUF_HEIGHT_VAR)
                ALT_REG<HEADER_WORD_BITS> packetDimensions_REG[4];
                sc_uint<HEADER_WORD_BITS> packetDimensions[4] BIND(packetDimensions_REG);
            #endif

            #if defined(PACKET_BUF_WIDTH_VAR) || defined(PACKET_BUF_HEIGHT_VAR) || defined(PACKET_BUF_INTERLACED_VAR)
                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    readCtrlPacket(i);
                    #ifdef PACKET_BUF_WIDTH_VAR
                        packetDimensions[i] = justReadQueue[0];
                    #endif // Width storage?
                }
            #endif

            #ifdef PACKET_BUF_WIDTH_VAR
                PACKET_BUF_WIDTH_VAR = MK_FNAME(PACKET_BUF_WIDTH_VAR, REG).cLdUI(
                             (packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                             PACKET_BUF_WIDTH_VAR, isControlPacket);
            #endif // PACKET_BUF_WIDTH_VAR

            #if defined(PACKET_BUF_HEIGHT_VAR) || defined(PACKET_BUF_INTERLACED_VAR)
                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    readCtrlPacket(4 + i);
                    #ifdef PACKET_BUF_HEIGHT_VAR
                        packetDimensions[i] = justReadQueue[0];
                    #endif // Height storage?
                }
            #endif

            #ifdef PACKET_BUF_HEIGHT_VAR
                PACKET_BUF_HEIGHT_VAR = MK_FNAME(PACKET_BUF_HEIGHT_VAR, REG).cLdUI(
                         (packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                         PACKET_BUF_HEIGHT_VAR, isControlPacket);
            #endif // PACKET_BUF_HEIGHT_VAR

            #ifdef PACKET_BUF_INTERLACING_VAR
                readCtrlPacket(8); // interlace nibble is discarded below if !PACKET_BUF_INTERLACING_VAR
                PACKET_BUF_INTERLACING_VAR = MK_FNAME(PACKET_BUF_INTERLACING_VAR, REG).cLdUI(justReadQueue[0], PACKET_BUF_INTERLACING_VAR, isControlPacket);
            #endif
            HW_DEBUG_MSG_COND(isNotImageData, "packet_buffering, control packet processed"
            #ifdef PACKET_BUF_WIDTH_VAR
                << ", width= " << PACKET_BUF_WIDTH_VAR
            #endif
            #ifdef PACKET_BUF_HEIGHT_VAR
                << ", height= " << PACKET_BUF_HEIGHT_VAR
            #endif
            #ifdef PACKET_BUF_INTERLACING_VAR
                << ", interlace flag = " << PACKET_BUF_INTERLACING_VAR.bit(3)
                                         << PACKET_BUF_INTERLACING_VAR.bit(2)
                                         << PACKET_BUF_INTERLACING_VAR.bit(1)
                                         << PACKET_BUF_INTERLACING_VAR.bit(0)
            #endif
                << std::endl);
        }
        // We discard anything remaining (be it a memory overflow or a control packet longer than expected or if we do not store user packets)
        while(isNotImageData && !PACKET_BUF_ST_INPUT->getEndPacket())
        {
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_MIN_ITER, 3);
            ALT_ATTRIB(ALT_SKIDDING, true);
            PACKET_BUF_ST_INPUT->cRead(!PACKET_BUF_ST_INPUT->getEndPacket());
        }
    } while (isNotImageData);

#if defined(PACKET_BUF_HAS_CHANGED_VAR) && PACKET_BUF_HAS_CHANGED_WIDTH_SENSITIVE
    PACKET_BUF_HAS_CHANGED_VAR = PACKET_BUF_HAS_CHANGED_VAR || (saveWidth != PACKET_BUF_WIDTH_VAR);
#endif

#if defined(PACKET_BUF_HAS_CHANGED_VAR) && PACKET_BUF_HAS_CHANGED_HEIGHT_SENSITIVE
    PACKET_BUF_HAS_CHANGED_VAR = PACKET_BUF_HAS_CHANGED_VAR || (saveHeight != PACKET_BUF_HEIGHT_VAR);
#endif

#if defined(PACKET_BUF_HAS_CHANGED_VAR) && PACKET_BUF_HAS_CHANGED_INTERLACE_SENSITIVE
    PACKET_BUF_HAS_CHANGED_VAR = PACKET_BUF_HAS_CHANGED_VAR || (PACKET_BUF_INTERLACING_VAR.bit(3) ?
            !saveInterlace.bit(3) || (sc_uint<3>(PACKET_BUF_INTERLACING_VAR) != sc_uint<3>(saveInterlace)) :
            saveInterlace.bit(3) || (PACKET_BUF_INTERLACING_VAR.bit(1) != saveInterlace.bit(1)));
#endif

    HW_DEBUG_MSG("packet_buffering, receiving image data" << std::endl);
}
