// vip_packet_parser.hpp
// author: aharding, vshankar
//
// This code performs non-image-data packet reading/propagating for the VIP cores. It can optionally record
// the width, height, and interlacing details from the last control packet before the image data. It should
// be included inside the SC_MODULE from which it will be used. Control packets are not propagated

// handleNonImagePackets() should be called when the next sample in the
// stream is the start of a packet (i.e. a type identifier). After return, the defined symbols for width, height
// and interlacing will be set to the values in the most recent control packet and the stream will be pointing
// at the first sample of image data. The type for image data will not yet have been passed on, allowing for
// an updated control packet to be inserted before image processing begins.
//
// Parameterise it by setting the following #defines:
//
// PACKET_ENTRY_POINT the function name to be called to start handling packets. Default is handleNonImagePackets
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


#ifndef PACKET_ENTRY_POINT
#define PACKET_ENTRY_POINT handleNonImagePackets
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

#ifndef PACKET_CTRL_PROPAGATE
#define PACKET_CTRL_PROPAGATE false
#endif

#ifdef PACKET_HAS_CHANGED_VAR
    #ifndef PACKET_HAS_CHANGED_WIDTH_SENSITIVE
        #define PACKET_HAS_CHANGED_WIDTH_SENSITIVE defined(PACKET_WIDTH_VAR)
    #endif
    #ifndef PACKET_HAS_CHANGED_HEIGHT_SENSITIVE
        #define PACKET_HAS_CHANGED_HEIGHT_SENSITIVE defined(PACKET_HEIGHT_VAR)
    #endif
    #ifndef PACKET_HAS_CHANGED_INTERLACE_SENSITIVE
        #define PACKET_HAS_CHANGED_INTERLACE_SENSITIVE defined(PACKET_INTERLACING_VAR)
    #endif
#else
    #define PACKET_HAS_CHANGED_WIDTH_SENSITIVE false
    #define PACKET_HAS_CHANGED_HEIGHT_SENSITIVE false
    #define PACKET_HAS_CHANGED_INTERLACE_SENSITIVE false
#endif

#if PACKET_HAS_CHANGED_WIDTH_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, saveWidth)
#endif
#if PACKET_HAS_CHANGED_HEIGHT_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS*4>, HEADER_WORD_BITS*4, saveHeight)
#endif
#if PACKET_HAS_CHANGED_INTERLACE_SENSITIVE
    DECLARE_VAR_WITH_REG(sc_uint<HEADER_WORD_BITS>, HEADER_WORD_BITS, saveInterlace)
#endif

bool isNotImageData;

#if PACKET_CTRL_PROPAGATE
    #define isPropagatedData isNotImageData
#else
    bool isPropagatedData;
#endif

// Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
sc_uint<PACKET_BPS> justReadQueue[PACKET_CHANNELS_IN_PAR] BIND(ALT_WIRE);

// When the input symbols in parallel are not equal to the output symbols
// in parallel, this queue is used to make the conversion
ALT_REG<PACKET_BPS> toWriteQueue_REG[6];
sc_uint<PACKET_BPS> toWriteQueue[6] BIND(toWriteQueue_REG);

// void readAndPropagate(int occurrence)
// For reading control packet data when we do not expect the previous read to have been EOP
// If an early EOP had occured, no more reads are taken from PACKET_INPUT, and no more data is sent to PACKET_OUTPUT
//
// To abstract away the fact that control packets are sent with each symbol, and can come in parallel,
// this function either reads from PACKET_INPUT, or advances the justReadQueue array. To decide which to do, it
// needs to know how many times it has been called. Since Cusp is not be able to figure out that an
// incrementing counter can be evaluated at compile-time, the function much be called with a number
// indicating which occurence it is being used in. It will do an actual read when occurrence%PACKET_CHANNELS_IN_PAR == 0
//
// @param occurrence the amount of times this function has been called in a sequence
void readAndPropagate(int occurrence)
{
    if (occurrence % PACKET_CHANNELS_IN_PAR == 0)
    {
        sc_uint<PACKET_CHANNELS_IN_PAR * PACKET_BPS> justReadAccessWire BIND(ALT_WIRE);
        justReadAccessWire = 0;
        DECLARE_VAR_WITH_REG(bool, 1, isPreviousEndPacket);
        DECLARE_VAR_WITH_REG(bool, 1, isEndPacket);

        isPreviousEndPacket = PACKET_INPUT->getEndPacket();

        PACKET_JUST_READ_VAR = MK_FNAME(PACKET_JUST_READ_VAR, REG).cLdUI(PACKET_INPUT->cRead(!PACKET_INPUT->getEndPacket() && isNotImageData), PACKET_JUST_READ_VAR, !isPreviousEndPacket && isNotImageData);
        isEndPacket = PACKET_INPUT->getEndPacket();

        // Should be able to use .range(), but Cusp is weak, so use a wire and shifting
        // to get to the words inside PACKET_JUST_READ_VAR
        justReadAccessWire = PACKET_JUST_READ_VAR;
        for (int i = 0; i < PACKET_CHANNELS_IN_PAR; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            justReadQueue[i] = justReadAccessWire;
            justReadAccessWire >>= PACKET_BPS;
        }

        if (PACKET_CHANNELS_IN_PAR == 2 && PACKET_CHANNELS_IN_PAR_OUTPUT == 3)
        {
            if ((occurrence/PACKET_CHANNELS_IN_PAR) % 3 == 0)
            {
                toWriteQueue[0] = justReadQueue[0];
                toWriteQueue[1] = justReadQueue[1];
            }
            if ((occurrence/PACKET_CHANNELS_IN_PAR) % 3 == 1)
            {
                toWriteQueue[2] = justReadQueue[0];
                toWriteQueue[3] = justReadQueue[1];
            }
            if ((occurrence/PACKET_CHANNELS_IN_PAR) % 3 == 2)
            {
                toWriteQueue[4] = justReadQueue[0];
                toWriteQueue[5] = justReadQueue[1];
            }
            if (!isPreviousEndPacket && isPropagatedData && ((occurrence/PACKET_CHANNELS_IN_PAR) % 3 == 2 || isEndPacket))
            {
                if ((occurrence/PACKET_CHANNELS_IN_PAR) % 3 == 0)
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[2], toWriteQueue[1], toWriteQueue[0]), isEndPacket);
                }
                else
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[2], toWriteQueue[1], toWriteQueue[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[5], toWriteQueue[4], toWriteQueue[3]), isEndPacket);
                }
            }

        }
        else if (PACKET_CHANNELS_IN_PAR == 3 && PACKET_CHANNELS_IN_PAR_OUTPUT == 2)
        {
            if ((occurrence/PACKET_CHANNELS_IN_PAR) % 2 == 0)
            {
                toWriteQueue[0] = justReadQueue[0];
                toWriteQueue[1] = justReadQueue[1];
                toWriteQueue[2] = justReadQueue[2];
            }
            if ((occurrence/PACKET_CHANNELS_IN_PAR) % 2 == 1)
            {
                toWriteQueue[3] = justReadQueue[0];
                toWriteQueue[4] = justReadQueue[1];
                toWriteQueue[5] = justReadQueue[2];
            }
            if (!isPreviousEndPacket && isPropagatedData && ((occurrence/PACKET_CHANNELS_IN_PAR) % 2 == 1 || isEndPacket))
            {
                if ((occurrence/PACKET_CHANNELS_IN_PAR) % 2 == 0)
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[1], toWriteQueue[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[3], toWriteQueue[2]), isEndPacket);
                }
                else
                {
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[1], toWriteQueue[0]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[3], toWriteQueue[2]), false);
                    PACKET_OUTPUT->writeDataAndEop((toWriteQueue[5], toWriteQueue[4]), isEndPacket);
                }
            }
        }
        else
        {
            if (!isPreviousEndPacket && isPropagatedData)
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
            justReadQueue[i] = justReadQueue[i + 1];
        }
    }
}

void PACKET_ENTRY_POINT()
{
    #if PACKET_HAS_CHANGED_WIDTH_SENSITIVE
        saveWidth = PACKET_WIDTH_VAR;
    #endif
    #if PACKET_HAS_CHANGED_HEIGHT_SENSITIVE
        saveHeight = PACKET_HEIGHT_VAR;
    #endif
    #if PACKET_HAS_CHANGED_INTERLACE_SENSITIVE
        saveInterlace = PACKET_INTERLACING_VAR;
    #endif
    do
    {

        bool isControlPacket;

        PACKET_JUST_READ_VAR = PACKET_INPUT->read();
        PACKET_HEADER_TYPE_VAR = PACKET_JUST_READ_VAR;

        // To save having to have more branching about whether this is image data, this is
        // used to disable reads/writes in the case that this is the start of the image.
        isNotImageData = PACKET_HEADER_TYPE_VAR != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA);

        // Assume that the incoming packet is a control packet. If not, it just doesn't assign to the control
        // registers.
        isControlPacket = PACKET_HEADER_TYPE_VAR == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER);

        #if !PACKET_CTRL_PROPAGATE
            isPropagatedData = isNotImageData && !isControlPacket;
        #endif

        // We need to write a correct control packet before we can start the image data,
        // and that can't be done until the AVALON_MM slave interface has been read so the headerType
        // is only written for non-image packets
        if (isPropagatedData)
        {
            PACKET_OUTPUT->writeDataAndEop(PACKET_JUST_READ_VAR, PACKET_INPUT->getEndPacket());
        }

        ALT_REG<HEADER_WORD_BITS> packetDimensions_REG[4];
        sc_uint<HEADER_WORD_BITS> packetDimensions[4] BIND(packetDimensions_REG);

        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            readAndPropagate(i);
            #ifdef PACKET_WIDTH_VAR
                packetDimensions[i] = justReadQueue[0];
            #endif // PACKET_WIDTH_VAR
        }
        #ifdef PACKET_WIDTH_VAR
        PACKET_WIDTH_VAR = MK_FNAME(PACKET_WIDTH_VAR, REG).cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]), PACKET_WIDTH_VAR, isControlPacket);
        #endif // PACKET_WIDTH_VAR

        for (unsigned int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            readAndPropagate(4 + i);
            #ifdef PACKET_HEIGHT_VAR
                packetDimensions[i] = justReadQueue[0];
            #endif //PACKET_HEIGHT_VAR
        }
        #ifdef PACKET_HEIGHT_VAR
        PACKET_HEIGHT_VAR = MK_FNAME(PACKET_HEIGHT_VAR, REG).cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]), PACKET_HEIGHT_VAR, isControlPacket);
        #endif //PACKET_HEIGHT_VAR

        readAndPropagate(8);
        #ifdef PACKET_INTERLACING_VAR
        PACKET_INTERLACING_VAR = MK_FNAME(PACKET_INTERLACING_VAR, REG).cLdUI(justReadQueue[0], PACKET_INTERLACING_VAR, isControlPacket);
        #endif
        // Whether it was a control packet or an unknown packet, we still propagate anything remaining
        while (PACKET_HEADER_TYPE_VAR != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA) && !PACKET_INPUT->getEndPacket())
        {
            if (isNotImageData)
            {
            	readAndPropagate(9);
            	readAndPropagate(10);
            	readAndPropagate(11);
            }
        }
        PACKET_OUTPUT->setEndPacket(false);

        HW_DEBUG_MSG_COND(!isControlPacket && isNotImageData, "packet_parser, user packet propagated" << std::endl);
        HW_DEBUG_MSG_COND(isControlPacket, "packet_parser, control packet processed"
        #ifdef PACKET_WIDTH_VAR
            << ", width= " << PACKET_WIDTH_VAR
        #endif
        #ifdef PACKET_HEIGHT_VAR
            << ", height= " << PACKET_HEIGHT_VAR
        #endif
        #ifdef PACKET_INTERLACING_VAR
            << ", interlace flag = " << PACKET_INTERLACING_VAR.bit(3)
                                     << PACKET_INTERLACING_VAR.bit(2)
                                     << PACKET_INTERLACING_VAR.bit(1)
                                     << PACKET_INTERLACING_VAR.bit(0)
        #endif
            << std::endl);
    }
    while (isNotImageData);

    #if defined(PACKET_HAS_CHANGED_VAR) && PACKET_HAS_CHANGED_WIDTH_SENSITIVE
        PACKET_HAS_CHANGED_VAR = PACKET_HAS_CHANGED_VAR || (saveWidth != PACKET_WIDTH_VAR);
    #endif

    #if defined(PACKET_HAS_CHANGED_VAR) && PACKET_HAS_CHANGED_HEIGHT_SENSITIVE
        PACKET_HAS_CHANGED_VAR = PACKET_HAS_CHANGED_VAR || (saveHeight != PACKET_HEIGHT_VAR);
    #endif

    #if defined(PACKET_HAS_CHANGED_VAR) && PACKET_HAS_CHANGED_INTERLACE_SENSITIVE
        PACKET_HAS_CHANGED_VAR = PACKET_HAS_CHANGED_VAR || (PACKET_INTERLACING_VAR.bit(3) ?
                !saveInterlace.bit(3) || (sc_uint<3>(PACKET_INTERLACING_VAR) != sc_uint<3>(saveInterlace)) :
                saveInterlace.bit(3) || (PACKET_INTERLACING_VAR.bit(1) != saveInterlace.bit(1)));
    #endif

    //HW_DEBUG_MSG("receiving image data" << std::endl);
}
