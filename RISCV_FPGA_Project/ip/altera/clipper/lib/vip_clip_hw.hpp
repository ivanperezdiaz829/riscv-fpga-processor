//! \file vip_clip_hwfast.hpp
//!
//! \author aharding
//!
//! \brief Synthesisable Clipper core.

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
    #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
 #undef CLIP_NAME
 #define CLIP_NAME alt_vip_clip
#endif

SC_MODULE(CLIP_NAME)
{
#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/clipper.jar?com.altera.vip.entityinterfaces.helpers.CLIPEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Clipper";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Clipper selects a portion of a video frame to clip out and discards the remainder.";
    }

    static const char * get_product_ids(void)
    {
        return "00C8";
    }

#include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif //LEGACY_FLOW

#ifndef SYNTH_MODE
#define CLIP_BPS 20
#define CLIP_CHANNELS_IN_PAR 3
#define CTRL_INTERFACE_WIDTH 16
#define CTRL_INTERFACE_DEPTH 6
#endif

    // Data in
    ALT_AVALON_ST_INPUT< sc_uint<CLIP_BPS*CLIP_CHANNELS_IN_PAR> > *din ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    // Data out
    ALT_AVALON_ST_OUTPUT< sc_uint<CLIP_BPS*CLIP_CHANNELS_IN_PAR > > *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    // Control interface
    ALT_AVALON_MM_RAW_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH> *control ALT_CUSP_DISABLE_NUMBER_SUFFIX;

#ifdef SYNTH_MODE

    // Bit widths for horizontal and vertical counters
    static const int I_BITS = LOG2G_WIDTH_SEQ;
    static const int J_BITS = LOG2G_HEIGHT;

    static const int CONTROL_ADDRESS_BITS = 4;

    static const unsigned int INTERLACE_FLAG_BIT = HEADER_WORD_BITS-1;
    static const unsigned int INTERLACE_FIELD_TYPE_BIT = HEADER_WORD_BITS-2;

    //static const int N_INTERRUPTS = N_SYSTEM_INTERRUPT_BITS + 1;
    //static const unsigned int INTERRUPT_ON_RESOLUTION_CHANGE_BIT = N_SYSTEM_INTERRUPT_BITS;

#if CLIP_RUNTIME_CONTROL
    // Inter-thread communication for go/status
    ALT_REG<1> go_REG ALT_BIND_SEQ_SPACE("go_REG");
    ALT_REG<1> running_REG ALT_BIND_SEQ_SPACE("running_REG");
    sc_uint<1> go BIND(go_REG);
    sc_uint<1> running BIND(running_REG);

    // The clipping window params are double-buffered and updated once per frame. The offsets
    // are relative to their named sides e.g. bottomOffset is relative to the bottom of the
    // frame, not an origin in the top-left.
    // These regs hold the values direct from the control interface
    ALT_REG<I_BITS> controlLeftOffset_REG ALT_BIND_SEQ_SPACE("controlLeftOffset_REG");
    ALT_REG<I_BITS> controlRightOffset_REG ALT_BIND_SEQ_SPACE("controlRightOffset_REG");
    ALT_REG<J_BITS> controlTopOffset_REG ALT_BIND_SEQ_SPACE("controlTopOffset_REG");
    ALT_REG<J_BITS> controlBottomOffset_REG ALT_BIND_SEQ_SPACE("controlBottomOffset_REG");
    sc_uint<I_BITS> controlLeftOffset BIND(controlLeftOffset_REG);
    sc_uint<I_BITS> controlRightOffset BIND(controlRightOffset_REG);
    sc_uint<J_BITS> controlTopOffset BIND(controlTopOffset_REG);
    sc_uint<J_BITS> controlBottomOffset BIND(controlBottomOffset_REG);

    // When go is changed in controlMonitor via the MM_RAW_SLAVE, this event is used
    // to wake up behaviour
    sc_event goChanged;

    void controlMonitor()
    {
        bool isRead;
        sc_uint<CONTROL_ADDRESS_BITS> address;

        // Initialise GO to 0
        go = 0;
        for (;;)
        {
            isRead = control->isReadAccess();
            address = control->getAddress();
            if (isRead)
            {
                // The only address we service for reads is address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_Status_ADDRESS)
                // so always return running
                control->returnReadData(sc_int<CTRL_INTERFACE_WIDTH>(running));
            }
            else
            {
                sc_uint<CTRL_INTERFACE_WIDTH> thisRead = sc_uint<CTRL_INTERFACE_WIDTH>(control->getWriteData());
                if (address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_Go_ADDRESS))
                {
                    go = thisRead;

                    notify(goChanged);
                }
                if (address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_LEFT_OFFSET_ADDRESS))
                {
                    controlLeftOffset = thisRead;
                }
                if (address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_RIGHT_OFFSET_ADDRESS))
                {
                    controlRightOffset = thisRead;
                }
                if (address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_TOP_OFFSET_ADDRESS))
                {
                    controlTopOffset = thisRead;
                }
                if (address == sc_uint<CONTROL_ADDRESS_BITS>(CTRL_BOTTOM_OFFSET_ADDRESS))
                {
                    controlBottomOffset = thisRead;
                }
            }
        }
    }
#endif // CLIP_RUNTIME_CONTROL

#define PACKET_BPS CLIP_BPS
#define PACKET_CHANNELS_IN_PAR CLIP_CHANNELS_IN_PAR
#define PACKET_HEADER_TYPE_VAR headerType
#define PACKET_JUST_READ_VAR justRead
#define PACKET_WIDTH_VAR widthFromControlPacket
#define PACKET_HEIGHT_VAR height
#define PACKET_INTERLACING_VAR interlacingFlag
#include "vip_packet_reader.hpp"

    void write_corrected_control_packet()
    {
        // Store the outputs in a shift register to abstract away
        // the fact that they could be written out in parallel or
        // sequence
        ALT_REG < HEADER_WORD_BITS > output_REG[9];
        sc_uint < HEADER_WORD_BITS > output[9] BIND(output_REG);
        sc_uint < HEADER_WORD_BITS * 4 > widthOrHeight;
        static const int N_HEADER_WORDS_TO_SEND = 9;
        HW_DEBUG_MSG("Sending corrected control packet" << std::endl);

        // The type
        dout->write(CONTROL_HEADER);

        // The width
        widthOrHeight = rightEdge - leftEdge;
        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[i] = widthOrHeight.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // The height
        widthOrHeight = bottomEdge - topEdge;

        for (int i = 0; i < 4; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            output[4 + i] = widthOrHeight.range(HEADER_WORD_BITS * (4 - i) - 1, HEADER_WORD_BITS * (3 - i));
        }

        // Interlacing
        output[8] = interlacingFlag;

        // Write out the control packet, packing into wide words for symbols in parallel. If the two
        // do not divide exactly, round up and send an extra word with whatever happens to be in the
        // right place.
        for (int i = 0; i < (N_HEADER_WORDS_TO_SEND + CLIP_CHANNELS_IN_PAR - 1) / CLIP_CHANNELS_IN_PAR; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

            sc_uint< CLIP_BPS*CLIP_CHANNELS_IN_PAR> thisOutput BIND(ALT_WIRE);
            thisOutput = 0;
            // Pack a word to write out. If the last word doesn't full fill the word, wrap
            // around and write again from the front
            for (int j = CLIP_CHANNELS_IN_PAR - 1; j >= 0; j--)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                thisOutput <<= CLIP_BPS;
                thisOutput = thisOutput | output[j];
            }

            // Shift the words to write along
            for (int j = 0; j < N_HEADER_WORDS_TO_SEND - CLIP_CHANNELS_IN_PAR; j++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                output[j] = output[j + CLIP_CHANNELS_IN_PAR];
            }

            dout->writeDataAndEop(thisOutput, i == (N_HEADER_WORDS_TO_SEND + CLIP_CHANNELS_IN_PAR - 1) / CLIP_CHANNELS_IN_PAR - 1);
        }

        dout->setEndPacket(false);

    }

    // The edges of the clipping window, relative to the top-left
    sc_uint<I_BITS> leftEdge, rightEdge;
    sc_uint<J_BITS> topEdge, bottomEdge;

    void behaviour()
    {
        for (;;)
        {
            sc_uint<I_BITS> i, width;
            sc_uint<J_BITS> j;

            handleNonImagePackets();

            // The width is going to get multiplied up by CLIP_CHANNELS_IN_SEQ, so store it separately to avoid it
            // getting over-written for the next frame.
            width = widthFromControlPacket;

#if CLIP_RUNTIME_CONTROL

            // Write the running bit
            running = 0;

#ifndef __CUSP_SYNTHESIS__

            control->notifyEvent();
            wait(sc_time(0, SC_US));
#endif

            // Check the go bit before starting to read
            while (!go)
                wait(goChanged);

            // Copy in the latest control data
            if (CLIP_OFFSETS_NOT_RECTANGLE)
            {
                leftEdge = controlLeftOffset;
                rightEdge = width - controlRightOffset;
                topEdge = controlTopOffset;
                bottomEdge = height - controlBottomOffset;
            }
            else
            {
                leftEdge = controlLeftOffset;
                rightEdge = controlLeftOffset + controlRightOffset;
                topEdge = controlTopOffset;
                bottomEdge = controlTopOffset + controlBottomOffset;
            }

            // Write the running bit
            running = 1;
#ifndef __CUSP_SYNTHESIS__

            control->notifyEvent();
            wait(sc_time(0, SC_US));
#endif

#else // !CLIP_RUNTIME_CONTROL

            // The width is going to get multiplied up by CLIP_CHANNELS_IN_SEQ, so store it separately to avoid it
            // getting over-written for the next frame.
            width = widthFromControlPacket;

            if (CLIP_OFFSETS_NOT_RECTANGLE)
            {
                leftEdge = CLIP_LEFT_OFFSET;
                rightEdge = width - sc_uint<I_BITS>(CLIP_RIGHT_OFFSET);
                topEdge = CLIP_TOP_OFFSET;
                bottomEdge = height - sc_uint<J_BITS>(CLIP_BOTTOM_OFFSET);
            }
            else
            {
                leftEdge = CLIP_LEFT_OFFSET;
                rightEdge = CLIP_LEFT_OFFSET + CLIP_RIGHT_OFFSET;
                topEdge = CLIP_TOP_OFFSET;
                bottomEdge = CLIP_TOP_OFFSET + CLIP_BOTTOM_OFFSET;
            }
#endif // CLIP_RUNTIME_CONTROL

            write_corrected_control_packet();

            // Deal with channels in sequence by just treating the lines as if they are 2 times or 3 times as long.
            if (CLIP_CHANNELS_IN_SEQ == 2)
            {
                leftEdge <<= 1;
                rightEdge <<= 1;
                width <<= 1;
            }
            if (CLIP_CHANNELS_IN_SEQ == 3)
            {
                leftEdge += (leftEdge << 1);
                rightEdge += (rightEdge << 1);
                width += (width << 1);
            }
            if (CLIP_CHANNELS_IN_SEQ == 4)
            {
                leftEdge <<= 2;
                rightEdge <<= 2;
                width <<= 2;
            }

            // The type for the image data that follows
            dout->write(IMAGE_DATA);

            // If the EOP comes before the end of the clipping window, we won't have written it
            // If it comes between the end of the clipping window and the input frame, we shouldn't
            // write another EOP
            bool isLastWriteDone = false;
            for (j = 0; (j < height) && !din->getEndPacket(); ++j)
            {
                bool writeEnableJ = j >= topEdge && j < bottomEdge;
                bool isLastOutputRow = j == sc_uint<J_BITS>(bottomEdge - sc_uint<J_BITS>(1));

                sc_uint<I_BITS> i_cpy = 0;

                for (i = 0; (i < width) && !din->getEndPacket(); ++i)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 32);
                    ALT_ATTRIB(ALT_SKIDDING, true);

                    assert(i == i_cpy);

                    bool writeEnableI = (i_cpy >= leftEdge) && (i_cpy < rightEdge);
                    bool isLastOutputCol = i_cpy == sc_uint<I_BITS>(rightEdge - sc_uint<I_BITS>(1));
                    justRead = din->cRead((i_cpy < width) && !din->getEndPacket()); // i_cpy < width compulsory because of skidding
                    ++i_cpy;

                    if (writeEnableI && writeEnableJ)
                    {
                        // just_read might be undefined in HW if skidding past the eop but this does not matter
                        dout->writeDataAndEop(justRead, (isLastOutputCol && isLastOutputRow));
                        isLastWriteDone = isLastWriteDone || (isLastOutputCol && isLastOutputRow);
                    }
                }
            }
            HW_DEBUG_MSG_COND(!din->getEndPacket(), "did not get the expected eop, discarding extra data" << std::endl);

            // If necessary, do a last write to close the image
            dout->setEndPacket(!isLastWriteDone);
            dout->cWrite(justRead, !isLastWriteDone);
            isLastWriteDone = true;

            // Discard any extra data if eop did not come as expected
            while (!din->getEndPacket())
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);
                ALT_ATTRIB(ALT_MIN_ITER, 3);
                ALT_ATTRIB(ALT_SKIDDING, true);
                din->cRead(!din->getEndPacket());
            }
            // Finally, switch off endPacket, ready for the next packet out
            dout->setEndPacket(!isLastWriteDone);

            // Switch interlace flag in case there is no control packet to confirm INTERLACE_FIELD_TYPE with the next interlaced field
            interlacingFlag = (interlacingFlag.bit(INTERLACE_FLAG_BIT),
                               interlacingFlag.bit(INTERLACE_FLAG_BIT) ? !interlacingFlag.bit(INTERLACE_FIELD_TYPE_BIT) : interlacingFlag.bit(INTERLACE_FIELD_TYPE_BIT),
                               interlacingFlag.range(INTERLACE_FIELD_TYPE_BIT - 1, 0));
        }
    }

#endif // SYNTH_MODE

    const char* param;
    SC_HAS_PROCESS(CLIP_NAME);
    CLIP_NAME(sc_module_name name_, const char* PARAMETERISATION = "<clipperParams><CLIP_NAME>clipper</CLIP_NAME><CLIP_BPS>8</CLIP_BPS><CLIP_CHANNELS_IN_SEQ>3</CLIP_CHANNELS_IN_SEQ><CLIP_CHANNELS_IN_PAR>1</CLIP_CHANNELS_IN_PAR><CLIP_WIDTH>640</CLIP_WIDTH><CLIP_HEIGHT>480</CLIP_HEIGHT><CLIP_RUNTIME_CONTROL>false</CLIP_RUNTIME_CONTROL><CLIP_OFFSETS_NOT_RECTANGLE>true</CLIP_OFFSETS_NOT_RECTANGLE><CLIP_LEFT_OFFSET>10</CLIP_LEFT_OFFSET><CLIP_RIGHT_OFFSET>10</CLIP_RIGHT_OFFSET><CLIP_TOP_OFFSET>10</CLIP_TOP_OFFSET><CLIP_BOTTOM_OFFSET>10</CLIP_BOTTOM_OFFSET></clipperParams>") : sc_module(name_), param(PARAMETERISATION)
    {
    	din = new ALT_AVALON_ST_INPUT< sc_uint<CLIP_BPS*CLIP_CHANNELS_IN_PAR> > ();
    	dout = new ALT_AVALON_ST_OUTPUT< sc_uint<CLIP_BPS*CLIP_CHANNELS_IN_PAR> > ();
    	control = NULL;
#ifdef LEGACY_FLOW
#if CLIP_RUNTIME_CONTROL
    	control = new ALT_AVALON_MM_RAW_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
    	control->setUseOwnClock(false);
#endif
#else
    	int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "clipperParams;CLIP_BPS", 8);
    	int channels_in_par = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "clipperParams;CLIP_CHANNELS_IN_PAR", 3);
    	int runtime = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "clipperParams;CLIP_RUNTIME_CONTROL", 0);
    	if(runtime){
    		//CTRL INTEFACE WIDTH AND DEPTH are static
    		control = new ALT_AVALON_MM_RAW_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
    		control->setUseOwnClock(false);
        	control->enableWritePorts();
        	control->enableReadPorts();
    	}

    	din->setDataWidth(bps*channels_in_par);
    	dout->setDataWidth(bps*channels_in_par);
    	din->setSymbolsPerBeat(channels_in_par);
    	dout->setSymbolsPerBeat(channels_in_par);
        din->enableEopSignals();
        dout->enableEopSignals();

#endif

#ifdef SYNTH_MODE
#if CLIP_RUNTIME_CONTROL
        controlLeftOffset = CLIP_LEFT_OFFSET;
        controlRightOffset = CLIP_RIGHT_OFFSET;
        controlTopOffset = CLIP_TOP_OFFSET;
        controlBottomOffset = CLIP_BOTTOM_OFFSET;
        SC_THREAD(controlMonitor);
#endif
        widthFromControlPacket = CLIP_WIDTH;
        height = CLIP_HEIGHT;
        interlacingFlag = 3;
        SC_THREAD(behaviour);
#endif //SYNTH_MODE

    }
};
