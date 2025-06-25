// vip_packet_reader.hpp
// author: aharding
//
// This code performs non-image-data packet reading/propagating for the VIP cores. It can optionally record
// the width, height, and interlacing details from the last control packet before the image data. It should
// be included inside the SC_MODULE from which it will be used.

// handleNonImagePackets() should be called when the next sample in the
// stream is the start of a packet (i.e. a type identifier). After return, the defined symbols for width, PACKET_HEIGHT_VAR
// and interlacing will be set to the values in the most recent control packet and the stream will be pointing
// at the first sample of image data. The type for image data will not yet have been passed on, allowing for
// updated control packets to be inserted before image processing begins.
//
// Parameterise it by setting the following #defines:
//
// PACKET_ENTRY_POINT the function name to be called to start handling packets. Default is handleNonImagePacketsFIFO2ST
//
// PACKET_INPUT port name to use for input. Default is din
//
// PACKET_OUTPUT port name to use for output. Default is dout
//
// PACKET_BPS bits per sample
//
// PACKET_CHANNELS_IN_PAR channels in parallel
//
// PACKET_CHANELS_IN_PAR_OUTPUT channels in parallel on the output. If undefined, defaults to PACKET_CHANNELS_IN_PAR. This is a
//                 late-in-the-day hack to make the CRS work so it can only be 3->2 channels or 2->3 channels.
//
// PACKET_HEADER_TYPE_VAR a variable name to store the header type. This file will declare as an sc_uint<HEADER_WORD_BITS>
//
// PACKET_JUST_READ_VAR a variable name to store the most recently read word from input. This file will declare as an
//                  sc_uint<PACKET_BPS*PACKET_CHANNELS_IN_PAR>
//
// PACKET_HAS_CHANGED_VAR a variable name to store the boolean indicating whether any information in control packets
//                        has changed since the variable was last reset. Calling code must do the initialisation and reset.
//
// PACKET_WIDTH_VAR a variable name to store the width. This file will declare it as an sc_uint<HEADER_WORD_BITS*4>.
//           If undefined, the width will not be stored and cheaper hardware will be produced.
//
// PACKET_HEIGHT_VAR a variable name to store the PACKET_HEIGHT_VAR. This file will declare it as an sc_uint<HEADER_WORD_BITS*4>
//           If undefined, the interlacing will not be stored and cheaper hardware will be produced.
//
// PACKET_INTERLACING_VAR a variable name to store the interlacing. This file will declare it as an sc_uint<HEADER_WORD_BITS>
//           If undefined, the interlacing will not be stored and cheaper hardware will be produced.

sc_uint<HEADER_WORD_BITS> PACKET_HEADER_TYPE_VAR;
DECLARE_VAR_WITH_REG(sc_biguint<PACKET_BPS*PACKET_CHANNELS_IN_PAR+1>, PACKET_BPS*PACKET_CHANNELS_IN_PAR+1, PACKET_JUST_READ_VAR);

#ifndef PACKET_ENTRY_POINT
#define PACKET_ENTRY_POINT handleNonImagePacketsFIFO2ST
#endif

#ifndef PACKET_INPUT
#define PACKET_INPUT din
#endif

#ifndef PACKET_OUTPUT
#define PACKET_OUTPUT dout
#endif

#ifndef PACKET_CHANNELS_IN_PAR_OUTPUT
#define PACKET_CHANNELS_IN_PAR_OUTPUT PACKET_CHANNELS_IN_PAR
#endif

#ifdef PACKET_WIDTH_VAR
DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, PACKET_WIDTH_VAR);
#endif
#ifdef PACKET_HEIGHT_VAR

DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, PACKET_HEIGHT_VAR);
#endif
#ifdef PACKET_INTERLACING_VAR

DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, PACKET_INTERLACING_VAR);
#endif

#ifdef PACKET_HAS_CHANGED_VAR

DECLARE_VAR_WITH_REG(bool, 1, PACKET_HAS_CHANGED_VAR);

#endif

#define HW_DEBUG_MSG_ON
 #ifndef HW_DEBUG_MSG
 #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
 #define HW_DEBUG_MSG(X) std::cout << sc_time_stamp() << ": " << name() << ", " << X
 #else
 #define HW_DEBUG_MSG(X)
 #endif
#endif // nHW_DEBUG_MSG


bool isNotImageDataFIFO2ST;
// When reading control words in parallel, these wires keep the next
// data element at justReadQueueFIFO2ST[0]
ALT_REG<PACKET_BPS> justReadQueueFIFO2ST_REG[PACKET_CHANNELS_IN_PAR];
// Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
sc_uint<PACKET_BPS> justReadQueueFIFO2ST[PACKET_CHANNELS_IN_PAR] BIND(ALT_WIRE);

// When the input symbols in parallel are not equal to the output symbols
// in parallel, this queue is used to make the conversion
ALT_REG<PACKET_BPS> toWriteQueueFIFO2ST_REG[6];
sc_uint<PACKET_BPS> toWriteQueueFIFO2ST[6] BIND(toWriteQueueFIFO2ST_REG);

// void readAndPropagateFIFO2ST(int occurrence)
// For reading control packet data when we do not expect the previous read to have been EOP
// If an early EOP had occured, no more reads are taken from PACKET_INPUT, and no more data is sent to PACKET_OUTPUT
//
// To abstract away the fact that control packets are sent with each symbol, and can come in parallel,
// this function either reads from PACKET_INPUT, or advances the justReadQueueFIFO2ST array. To decide which to do, it
// needs to know how many times it has been called. Since Cusp is not be able to figure out that an
// incrementing counter can be evaluated at compile-time, the function much be called with a number
// indicating which occurence it is being used in. It will do an actual read when occurrence%PACKET_CHANNELS_IN_PAR == 0
//
// @param occurrence the amount of times this function has been called in a sequence
void readAndPropagateFIFO2ST(int occurrence)
{
    if (occurrence % PACKET_CHANNELS_IN_PAR == 0)
    {
        sc_uint<PACKET_CHANNELS_IN_PAR * PACKET_BPS> justReadAccessWire BIND(ALT_WIRE);
        justReadAccessWire = 0;
        DECLARE_VAR_WITH_REG(bool, 1, isPreviousEndPacket);
        DECLARE_VAR_WITH_REG(bool, 1, isEndPacket);
        
        isPreviousEndPacket = PACKET_JUST_READ_VAR.bit(PACKET_BPS*PACKET_CHANNELS_IN_PAR);

        if (!PACKET_JUST_READ_VAR.bit(PACKET_BPS*PACKET_CHANNELS_IN_PAR) && isNotImageDataFIFO2ST)
        {
            PACKET_JUST_READ_VAR = PACKET_INPUT->read();
        }
        isEndPacket = PACKET_JUST_READ_VAR.bit(PACKET_BPS*PACKET_CHANNELS_IN_PAR);

        // Should be able to use .range(), but Cusp is weak, so use a wire and shifting
        // to get to the words inside PACKET_JUST_READ_VAR
        justReadAccessWire = PACKET_JUST_READ_VAR;
        for (int i = 0; i < PACKET_CHANNELS_IN_PAR; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            justReadQueueFIFO2ST[i] = justReadAccessWire;
            justReadAccessWire >>= PACKET_BPS;
        }

        if (PACKET_CHANNELS_IN_PAR == 2 && PACKET_CHANNELS_IN_PAR_OUTPUT == 3)
        {
            if ((occurrence / PACKET_CHANNELS_IN_PAR) % 3 == 0)
            {
                toWriteQueueFIFO2ST[0] = justReadQueueFIFO2ST[0];
                toWriteQueueFIFO2ST[1] = justReadQueueFIFO2ST[1];
            }
            if ((occurrence / PACKET_CHANNELS_IN_PAR) % 3 == 1)
            {
                toWriteQueueFIFO2ST[2] = justReadQueueFIFO2ST[0];
                toWriteQueueFIFO2ST[3] = justReadQueueFIFO2ST[1];
            }
            if ((occurrence / PACKET_CHANNELS_IN_PAR) % 3 == 2)
            {
                toWriteQueueFIFO2ST[4] = justReadQueueFIFO2ST[0];
                toWriteQueueFIFO2ST[5] = justReadQueueFIFO2ST[1];
            }
            if (!isPreviousEndPacket && isNotImageDataFIFO2ST && ((occurrence / PACKET_CHANNELS_IN_PAR) % 3 == 2 || isEndPacket))
            {
                if ((occurrence / PACKET_CHANNELS_IN_PAR) % 3 == 0)
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[2], toWriteQueueFIFO2ST[1], toWriteQueueFIFO2ST[0]), isEndPacket);
                }
                else
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[2], toWriteQueueFIFO2ST[1], toWriteQueueFIFO2ST[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[5], toWriteQueueFIFO2ST[4], toWriteQueueFIFO2ST[3]), isEndPacket);
                }
            }

        }
        else if (PACKET_CHANNELS_IN_PAR == 3 && PACKET_CHANNELS_IN_PAR_OUTPUT == 2)
        {
            if ((occurrence / PACKET_CHANNELS_IN_PAR) % 2 == 0)
            {
                toWriteQueueFIFO2ST[0] = justReadQueueFIFO2ST[0];
                toWriteQueueFIFO2ST[1] = justReadQueueFIFO2ST[1];
                toWriteQueueFIFO2ST[2] = justReadQueueFIFO2ST[2];
            }
            if ((occurrence / PACKET_CHANNELS_IN_PAR) % 2 == 1)
            {
                toWriteQueueFIFO2ST[3] = justReadQueueFIFO2ST[0];
                toWriteQueueFIFO2ST[4] = justReadQueueFIFO2ST[1];
                toWriteQueueFIFO2ST[5] = justReadQueueFIFO2ST[2];
            }
            if (!isPreviousEndPacket && isNotImageDataFIFO2ST && ((occurrence / PACKET_CHANNELS_IN_PAR) % 2 == 1 || isEndPacket))
            {
                if ((occurrence / PACKET_CHANNELS_IN_PAR) % 2 == 0)
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[1], toWriteQueueFIFO2ST[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[3], toWriteQueueFIFO2ST[2]), isEndPacket);
                }
                else
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[1], toWriteQueueFIFO2ST[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[3], toWriteQueueFIFO2ST[2]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueueFIFO2ST[5], toWriteQueueFIFO2ST[4]), isEndPacket);
                }
            }
        }
        else
        {
            if (!isPreviousEndPacket && isNotImageDataFIFO2ST)
            {
                PACKET_OUTPUT->writeDataAndEop(PACKET_JUST_READ_VAR, isEndPacket);
            }
        }
    }
    else
    {
        for (int i = 0; i < PACKET_CHANNELS_IN_PAR - 1; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            justReadQueueFIFO2ST[i] = justReadQueueFIFO2ST[i + 1];
        }
    }
}

void PACKET_ENTRY_POINT()
{
    do
    {
        bool isControlPacket;

        PACKET_JUST_READ_VAR = PACKET_INPUT->read();
        PACKET_HEADER_TYPE_VAR = PACKET_JUST_READ_VAR;

        // To save having to have more branching about whether this is image data, this is
        // used to disable reads/writes in the case that this is the start of the image.
        isNotImageDataFIFO2ST = PACKET_HEADER_TYPE_VAR != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA);

        // We need to write a correct control packet before we can start the image data,
        // and that can't be done until the AVALON_MM interface has been read so the headerType
        // is only written for non-image packets
        if (isNotImageDataFIFO2ST)
        {
            PACKET_OUTPUT->writeDataAndEop(PACKET_JUST_READ_VAR, PACKET_JUST_READ_VAR.bit(PACKET_BPS*PACKET_CHANNELS_IN_PAR));
        }
        // Assume that the incoming packet is a control packet. If not, it just doesn't assign to the control
        // registers.
        isControlPacket = PACKET_HEADER_TYPE_VAR == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER);

        ALT_REG<HEADER_WORD_BITS> packetDimensions_REG[4];
        sc_uint<HEADER_WORD_BITS> packetDimensions[4] BIND(packetDimensions_REG);

        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            readAndPropagateFIFO2ST(i);

#ifdef PACKET_WIDTH_VAR

#ifdef PACKET_HAS_CHANGED_VAR

            PACKET_HAS_CHANGED_VAR = MK_FNAME(PACKET_HAS_CHANGED_VAR, REG).cLdUI(PACKET_HAS_CHANGED_VAR || sc_uint<HEADER_WORD_BITS>(justReadQueueFIFO2ST[0]) != sc_uint<HEADER_WORD_BITS>(PACKET_WIDTH_VAR.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i))), PACKET_HAS_CHANGED_VAR, isControlPacket);
#endif

	       	packetDimensions[i] = justReadQueueFIFO2ST[0];
#endif // PACKET_WIDTH_VAR

        }
#ifdef PACKET_WIDTH_VAR
        PACKET_WIDTH_VAR = MK_FNAME(PACKET_WIDTH_VAR, REG).cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]), PACKET_WIDTH_VAR, isControlPacket);
#endif // PACKET_WIDTH_VAR

        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            
            readAndPropagateFIFO2ST(4 + i);

#ifdef PACKET_HEIGHT_VAR

#ifdef PACKET_HAS_CHANGED_VAR

            PACKET_HAS_CHANGED_VAR = MK_FNAME(PACKET_HAS_CHANGED_VAR, REG).cLdUI(PACKET_HAS_CHANGED_VAR || sc_uint<HEADER_WORD_BITS>(justReadQueueFIFO2ST[0]) != sc_uint<HEADER_WORD_BITS>(PACKET_HEIGHT_VAR.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i))), PACKET_HAS_CHANGED_VAR, isControlPacket);
#endif

          	packetDimensions[i] = justReadQueueFIFO2ST[0];
#endif //PACKET_HEIGHT_VAR

        }
#ifdef PACKET_HEIGHT_VAR
        PACKET_HEIGHT_VAR = MK_FNAME(PACKET_HEIGHT_VAR, REG).cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]), PACKET_HEIGHT_VAR, isControlPacket);
#endif //PACKET_HEIGHT_VAR

        readAndPropagateFIFO2ST(8);

#ifdef PACKET_INTERLACING_VAR

#ifdef PACKET_HAS_CHANGED_VAR

        PACKET_HAS_CHANGED_VAR = MK_FNAME(PACKET_HAS_CHANGED_VAR, REG).cLdUI(PACKET_HAS_CHANGED_VAR || sc_uint<HEADER_WORD_BITS>(justReadQueueFIFO2ST[0]) != PACKET_INTERLACING_VAR, PACKET_HAS_CHANGED_VAR, isControlPacket);
#endif

        PACKET_INTERLACING_VAR = MK_FNAME(PACKET_INTERLACING_VAR, REG).cLdUI(justReadQueueFIFO2ST[0], PACKET_INTERLACING_VAR, isControlPacket);
#endif
        // Whether it was a control packet or an unknown packet, we still propagate anything remaining
        while (PACKET_HEADER_TYPE_VAR != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA) && !PACKET_JUST_READ_VAR.bit(PACKET_BPS*PACKET_CHANNELS_IN_PAR))
        {
            if (isNotImageDataFIFO2ST)
            {
            	readAndPropagateFIFO2ST(9);
            	readAndPropagateFIFO2ST(10);
            	readAndPropagateFIFO2ST(11);
            }
        }
        PACKET_OUTPUT->setEndPacket(false);
    }
    while (isNotImageDataFIFO2ST);
    //HW_DEBUG_MSG("receiving image data" << std::endl);
}
