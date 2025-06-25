/**
 * \file vip_mix_hwfast.hpp
 *
 * \author pbrookes
 *
 * \brief Synthesisable 2D MIX core.
 * A 2D Alpha blending and picture in picture (PIP) MIX core that can be parameterised and then
 * synthesised with CusP. This implementation is designed to be fast, i.e. one pixel per clock cycle
 * for high definition stream. Alpha is per-pixel and in the range is [0,1]. For n bit alpha values (RGBAn) 
 * there is a range of [0,2^n -1]. The model will interpret (2^n -1) as 1, 
 * and all other values as (An value)/2^n. For example, 8 bit alpha value 255 => 1, 254 => 254/256.
 */

// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
 #include <alt_cusp.h>
#endif // n__CUSP__

#ifndef vip_assert
    #if !defined(__CUSP__)
        #include <cassert>
        #define vip_assert(X) assert(X)
    #else
        #define vip_assert(X)
    #endif
#endif // nvip_assert

#include "vip_constants.h"
#include "vip_common.h"

#ifdef DOXYGEN
 #define MIX_NAME MIX_HW
#endif

#ifndef LEGACY_FLOW
 #undef MIX_NAME
 #define MIX_NAME alt_vip_mix
#endif

#define HW_DEBUG_MSG_ON
#ifndef HW_DEBUG_MSG
    #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_DEBUG_MSG(X) std::cout << sc_time_stamp() << ": " << name() << ", " << X
    #else
        #define HW_DEBUG_MSG(X)
    #endif
#endif //nHW_DEBUG_MSG
#ifndef HW_DEBUG_MSG_COND
    #if defined(HW_DEBUG_MSG_ON) && !defined(__CUSP__)
        #define HW_DEBUG_MSG_COND(cond, X) if (cond) std::cout << sc_time_stamp() << ": " << name() << ", " << X
    #else
        #define HW_DEBUG_MSG_COND(cond, X)
    #endif
#endif //HW_DEBUG_MSG_COND

#define MIX_SPECIAL_CASE  ((1 << MIX_ALPHA_BPS)-1)
#define CTRL_OFFSET_BITS LOG2G_CTRL_INTERFACE_DEPTH
#define MULT_BITS MAX(MIX_BPS, NORMALISED_ALPHA_BITS)
#define MULT_OUTPUT_BITS (MIX_BPS + NORMALISED_ALPHA_BITS)
#define NORMALISED_ALPHA_BITS (MIX_ALPHA_BPS + 1)
#define CHANNEL_BITS (MIX_BPS * MIX_CHANNELS_IN_PAR)

// Convenient hash-defines
#define STEPS_TO_DELAY_MIX_THIS_LAYER 5
#define N_MIX_THIS_LAYER_DELAYS (STEPS_TO_DELAY_MIX_THIS_LAYER*(MIX_NUM_LAYERS-2))
#define TO_CHANNELS_IN_PAR(X) (((X)*MIX_CHANNELS_IN_PAR)+par_cnt)
#define EXPLICIT_TO_CHANNELS_IN_PAR(X, Y) (((X)*MIX_CHANNELS_IN_PAR)+(Y))

SC_MODULE(MIX_NAME)
{

#ifndef LEGACY_FLOW
    static const char * get_entity_helper_class(void)
    {
        return "ip_toolbench/alpha_blending_mixer.jar?com.altera.vip.entityinterfaces.helpers.MIXEntityHelper";
    }

    static const char * get_display_name(void)
    {
        return "Alpha Blending Mixer";
    }

    static const char * get_certifications(void)
    {
        return "SOPC_BUILDER_READY";
    }

    static const char * get_description(void)
    {
        return "The Alpha Blending Mixer mixes together up to twelve image layers. Both picture-in-picture mixing and image blending are supported.";
    }

    static const char * get_product_ids(void)
    {
        return "00B5";
    }

#include "vip_elementclass_info.h"
#else
    static const char * get_entity_helper_class(void)
    {
        return "default";
    }
#endif //LEGACY_FLOW

#ifndef SYNTH_MODE
#define CHANNEL_BITS 64
#define MIX_ALPHA_BPS 64
#define CTRL_INTERFACE_DEPTH 47
#define CTRL_INTERFACE_WIDTH 16
#endif

    // One Avalon input for each data input (each layer)
    ALT_AVALON_ST_INPUT< sc_uint< CHANNEL_BITS > > *din;

    // One Avalon input each alpha input (each layer)
    ALT_AVALON_ST_INPUT< sc_uint< MIX_ALPHA_BPS > > *alpha_in;
    
    //  A single Avalon output to output the stream
    ALT_AVALON_ST_OUTPUT< sc_uint< CHANNEL_BITS > > *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;

    // Extra slave port for runtime control of the layers position and their status
    // active&displayed / inactive / inactive_but_consumed 
    ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH> *control ALT_CUSP_DISABLE_NUMBER_SUFFIX;

#ifdef SYNTH_MODE

    /********************* The outputter, gets data from the main thread and help when processing non-image packet ****************/

    // Communication FIFO, from behaviour to outputter (packets and or images)
    ALT_FIFO< sc_uint< CHANNEL_BITS+1 >, 3 > to_output;

    bool newControlPacketReceived; // Shared variable, set up by the outputter thread when new dims are available for the layer
    bool replyFlag;                // A synchronization flag so that the outputter can "answer" the main thread without using a reply FIFO
    sc_event replyEvent;           // For SystemC simulation
    sc_uint<MIX_X_LOCATION_DATA_BITS> backgroundPatternWidth; // to share background width (x_max[0] cannot be used)

    // Create x_min, x_max, y_min, y_max to know when the layers should be displayed
    // and associate them to AU. y_min is a simple register but y_max is y_min + image size.
    // x_min and x_max 
    ALT_AU<MIX_X_LOCATION_DATA_BITS> x_min_AU[MIX_NUM_LAYERS];
    ALT_AU<MIX_X_LOCATION_DATA_BITS> x_max_AU[MIX_NUM_LAYERS];
    ALT_REG<MIX_Y_LOCATION_DATA_BITS> Y_MIN_REG[MIX_NUM_LAYERS];
    ALT_AU<MIX_Y_LOCATION_DATA_BITS> y_max_AU[MIX_NUM_LAYERS];
    sc_uint<MIX_X_LOCATION_DATA_BITS> x_min[MIX_NUM_LAYERS] BIND(x_min_AU);
    sc_uint<MIX_X_LOCATION_DATA_BITS> x_max[MIX_NUM_LAYERS] BIND(x_max_AU);
    sc_uint<MIX_Y_LOCATION_DATA_BITS> y_min[MIX_NUM_LAYERS] BIND(Y_MIN_REG);
    sc_uint<MIX_Y_LOCATION_DATA_BITS> y_max[MIX_NUM_LAYERS] BIND(y_max_AU);


    // Variables specific to the packet processing methods (and that can be reused for each call)  
    bool isNotImageData;
    bool isControlPacket;
    bool isBackgroundLayer;
    bool propagateUserPacket;

    // When reading control words in parallel, these wires keep the next
    // data element at justReadQueue[0]
    ALT_REG<MIX_BPS> justReadQueue_REG[MIX_CHANNELS_IN_PAR];
    // Hopefully wires are ok here now. Might have to go back to regs for channels in parallel.
    sc_uint<MIX_BPS> justReadQueue[MIX_CHANNELS_IN_PAR] BIND(ALT_WIRE);
    
    ALT_REG<CHANNEL_BITS + 1> output_read_REG;
    sc_uint<CHANNEL_BITS + 1> output_read BIND(output_read_REG);

    // Width and height received from the last control packet (accessed by the main thread if newControlPacketReceived==true)
    ALT_REG<HEADER_WORD_BITS * 4> ctrl_packet_width_REG;
    ALT_REG<HEADER_WORD_BITS * 4> ctrl_packet_height_REG;
    sc_uint<HEADER_WORD_BITS * 4> ctrl_packet_width BIND(ctrl_packet_width_REG);
    sc_uint<HEADER_WORD_BITS * 4> ctrl_packet_height BIND(ctrl_packet_height_REG);

    // void readAndPropagate(int occurrence, bool isBackgroundLayer, bool propagateUserPacket)
    // For reading control packet data when we do not expect the previous read to have been EOP
    // If an early EOP had occured, no more reads are taken from the FIFO, and no more data is sent to dout
    //
    // To abstract away the fact that control packets are sent with each symbol, and can come in parallel,
    // this function either reads from the FIFO, or advances the justReadQueue array. To decide which to do, it
    // needs to know how many times it has been called. Since Cusp is not be able to figure out that an
    // incrementing counter can be evaluated at compile-time, the function much be called with a number
    // indicating which occurence it is being used in. It will do an actual read when occurrence%MIX_CHANNELS_IN_PAR == 0
    //
    // @param occurrence the amount of times this function has been called in a sequence
    void readAndPropagate(int occurrence)
    {
        if (occurrence % MIX_CHANNELS_IN_PAR == 0)
        {
            sc_uint<MIX_CHANNELS_IN_PAR * MIX_BPS> justReadAccessWire BIND(ALT_WIRE);
            justReadAccessWire = 0;
            DECLARE_VAR_WITH_REG(bool, 1, isPreviousEndPacket);

            isPreviousEndPacket = output_read.bit(CHANNEL_BITS);

            if (!isPreviousEndPacket)
            {
                output_read = to_output.read(); 
            }

            // Should be able to use .range(), but Cusp is weak, so use a wire and shifting
            // to get to the words inside just_read[inputChan]
            justReadAccessWire = output_read.range(CHANNEL_BITS-1, 0);
            for (int i = 0; i < MIX_CHANNELS_IN_PAR; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                justReadQueue[i] = justReadAccessWire;
                justReadAccessWire >>= MIX_BPS;
            }

            if (!isPreviousEndPacket && (isControlPacket ? isBackgroundLayer : propagateUserPacket))
            {
                dout->writeDataAndEop(output_read.range(CHANNEL_BITS-1,0), output_read.bit(CHANNEL_BITS));
            }
        }
        else
        {
            for (int i = 0; i < MIX_CHANNELS_IN_PAR - 1; i++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                justReadQueue[i] = justReadQueue[i + 1];
            }
        }
    }

    void handleNonImagePackets()
    {
        ALT_REG<HEADER_WORD_BITS> packetDimensions_REG[4];
        sc_uint<HEADER_WORD_BITS> packetDimensions[4] BIND(packetDimensions_REG);
        do
        {
            output_read = to_output.read();

            // To save having to have more branching about whether this is image data, this is
            // used to disable reads/writes in the case that this is the start of the image.
            isNotImageData = sc_uint<HEADER_WORD_BITS>(output_read) != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA);

            HW_DEBUG_MSG("outputter process packet of type " << output_read << std::endl);

            if (isNotImageData)
            {
                // Assume that the incoming packet is a control packet. If not, it just doesn't assign to the control
                // registers.
                isControlPacket = output_read == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER);

                // We need to write a correct control packet before we can start the image data,
                // and that can't be done until the AVALON_MM interface has been read so the headerType
                // is only written for non-image packets
                if ((isControlPacket ? isBackgroundLayer : propagateUserPacket))
                {
                    dout->writeDataAndEop(output_read.range(CHANNEL_BITS-1,0), output_read.bit(CHANNEL_BITS));
                }

                // The main thread is expecting dimensions back when a control packet was received, but it is not reading
                // anything until the image data header has been received (and read only the last one)
                newControlPacketReceived = newControlPacketReceived | isControlPacket;

                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    readAndPropagate(i);
                    packetDimensions[i] = justReadQueue[0];
                }                
                ctrl_packet_width = ctrl_packet_width_REG.cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                                                                ctrl_packet_width, isControlPacket);
                for (unsigned int i = 0; i < 4; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    readAndPropagate(4 + i);
                    packetDimensions[i] = justReadQueue[0];
                }
                ctrl_packet_height = ctrl_packet_height_REG.cLdUI((packetDimensions[0], packetDimensions[1], packetDimensions[2], packetDimensions[3]),
                                                                  ctrl_packet_height, isControlPacket);

                // Whether it was a control packet or an unknown packet, we still propagate/discard anything remaining
                while (!output_read.bit(CHANNEL_BITS))
                {
                    bool isPreviousEndPacket = output_read.bit(CHANNEL_BITS);
                    if (!isPreviousEndPacket)
                    {
                        output_read = to_output.read();
                    }
                    dout->setEndPacket(output_read.bit(CHANNEL_BITS));
                    dout->cWrite(output_read.range(CHANNEL_BITS-1,0), !isPreviousEndPacket && (isControlPacket ? isBackgroundLayer : propagateUserPacket));
                }
            }
        }
        while (isNotImageData);
        HW_DEBUG_MSG("receiving image data" << std::endl);
    }

    void outputter()
    {
        bool eop;
        sc_int<MIX_X_LOCATION_DATA_BITS + 1> width_counter;

        for (;;)
        {
            // Propagate all user packets from the layers
            propagateUserPacket = true;
            isBackgroundLayer = true;
            for (sc_int<LOG2(MIX_NUM_LAYERS) + 1> k = MIX_NUM_LAYERS-1; !k.bit(LOG2(MIX_NUM_LAYERS)); --k)
            {
                // synchronization part 1, wait for input from behaviour, set the reply flag to false and process the packets of the layer
                output_read = to_output.read();
                replyFlag = ALT_DONT_EVALUATE(output_read.bit(CHANNEL_BITS) && !output_read.bit(CHANNEL_BITS)); // set replyFlag to false AFTER the read from the to_output FIFO
                notify(replyEvent);
                
                // What follows also works with disabled layers
                newControlPacketReceived = replyFlag; // Set newControlPacketReceived to false but trick CUSP into scheduling this AFTER replyFlag has been set to false
                handleNonImagePackets();
                
                isBackgroundLayer = false;

                // synchronization part 2, set reply flag to true once packets have been processed and wait for next input from the behaviour thread
                replyFlag = ALT_DONT_EVALUATE(output_read.bit(CHANNEL_BITS) || !output_read.bit(CHANNEL_BITS)); // set replyFlag to true AFTER reading the last packet
                notify(replyEvent);
            }
            
            // Send image data header
            output_read = to_output.read();
            eop = output_read.bit(CHANNEL_BITS);
            dout->writeDataAndEop(output_read.range(CHANNEL_BITS-1, 0), eop);
            
            while (!eop)
            {
                for (width_counter = backgroundPatternWidth + sc_int<1>(-1); width_counter >= sc_int<1>(0); --width_counter)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, 32);
                    output_read = to_output.read();
                    eop = output_read.bit(CHANNEL_BITS);
                    dout->cWrite(output_read.range(CHANNEL_BITS-1, 0), !eop);
                }
                if (eop)
                {
                    // The previous loop might have stopped before sending the last element, do it now
                    dout->writeDataAndEop(output_read.range(CHANNEL_BITS-1, 0), true);
                }
            }
        }
    }
    
    
    /************************************** the behaviour thread performs the actual mixing ************************************/
    void behaviour()
    {
        // Just read, used by all
        ALT_REG<CHANNEL_BITS> just_read_REG[MIX_NUM_LAYERS];
        sc_uint<CHANNEL_BITS> just_read[MIX_NUM_LAYERS] BIND(just_read_REG);
        
        // Arrays are explicitely bound to registers in what follows (otherwise memory is used)
        // Avalon-ST 1.1 runtime changes of width and height 
        ALT_REG<MIX_X_LOCATION_DATA_BITS> widths_REG[MIX_NUM_LAYERS];
        ALT_REG<MIX_Y_LOCATION_DATA_BITS> heights_REG[MIX_NUM_LAYERS];
        sc_uint<MIX_X_LOCATION_DATA_BITS> widths[MIX_NUM_LAYERS] BIND(widths_REG);
        sc_uint<MIX_Y_LOCATION_DATA_BITS> heights[MIX_NUM_LAYERS] BIND(heights_REG);

        // A layer_active flag for each foreground layer, layer_active[0] is not used
        ALT_REG<2> LAYER_ACTIVE_REG[MIX_NUM_LAYERS];
        sc_uint<2> layer_active[MIX_NUM_LAYERS] BIND(LAYER_ACTIVE_REG);

        ALT_REG<1> mix_this_layer_REG[MIX_NUM_LAYERS];
        bool mix_this_layer[MIX_NUM_LAYERS] BIND(mix_this_layer_REG);

        // Declare pixel_sum and bind it to an ALT_AU
        ALT_AU<MULT_OUTPUT_BITS + 1> pixel_sum_AU[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR];
        sc_uint<MULT_OUTPUT_BITS + 1> pixel_sum[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR] BIND(pixel_sum_AU);
        // Declare a 0 latency wire pixel_output[] variable to make the code more readable 
        sc_uint<MIX_BPS> pixel_output[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR] BIND(ALT_WIRE);

        // Declare num_seq_counter and bind it to an ALT_AU, this counts the number of channels in sequence processed
        ALT_AU<4> NUM_SEQ_AU;
        sc_uint<4> num_seq_counter BIND(NUM_SEQ_AU);
        sc_uint<1> read_alpha;

#if MIX_ALPHA_ENABLED
        // Declare alpha_just_in and bind it to an AU (the inputs of the alpha channels is slightly modified before being used, see below)
        ALT_AU<MIX_ALPHA_BPS> alpha_just_in_AU[MIX_NUM_LAYERS];
        sc_uint<MIX_ALPHA_BPS> alpha_just_in[MIX_NUM_LAYERS] BIND(alpha_just_in_AU);

        // Declare normalised_alpha and complemented_alpha, 
        ALT_REG < NORMALISED_ALPHA_BITS > normalised_alpha_REG[MIX_NUM_LAYERS];
        sc_uint< NORMALISED_ALPHA_BITS > normalised_alpha[MIX_NUM_LAYERS] BIND(normalised_alpha_REG);
        ALT_AU< NORMALISED_ALPHA_BITS > complemented_alpha_AU[MIX_NUM_LAYERS];
        sc_uint< NORMALISED_ALPHA_BITS > complemented_alpha[MIX_NUM_LAYERS] BIND(complemented_alpha_AU);

        // A set of ALT_AUs to perform the mixing with alpha channels
       //ALT_AU< 2*(MIX_BPS + MIX_ALPHA_BPS) > OUTPUT_ADD_AU[MIX_NUM_LAYERS];

        // A set of ALT_MULTs to perform the mixing with alpha channels with associated variables lower_layers_alphaed[] and this_layer_alphaed[]
        ALT_MULT<MULT_BITS > lower_layers_alphaed_MULT[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR];
        ALT_MULT<MULT_BITS > this_layer_alphaed_MULT[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR];
        sc_uint<MULT_OUTPUT_BITS> lower_layers_alphaed[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR] BIND(lower_layers_alphaed_MULT);
        sc_uint<MULT_OUTPUT_BITS> this_layer_alphaed[MIX_NUM_LAYERS*MIX_CHANNELS_IN_PAR] BIND(this_layer_alphaed_MULT);
#endif

        // Loop counters
        sc_uint<MIX_Y_LOCATION_DATA_BITS> i; 
        sc_uint<MIX_X_LOCATION_DATA_BITS> j; 

        // a set of 0 latency variables
        DECLARE_WIRES(sc_uint<MIX_BPS>, just_read_wires);

        unsigned int k, par_cnt;
        
        // To read and write to the control 
        ALT_AU<CTRL_OFFSET_BITS> ctrl_offset_AU;
        sc_uint<CTRL_OFFSET_BITS> ctrl_offset BIND(ctrl_offset_AU);

#if MIX_ALPHA_ENABLED
        bool is_alpha_val_special_case BIND(ALT_WIRE);
        bool pixel_output_fallacy BIND(ALT_WIRE);
        ALT_REG<1> previous_alpha_tautology_REG[MIX_NUM_LAYERS];
        bool previous_alpha_tautology[MIX_NUM_LAYERS] BIND(previous_alpha_tautology_REG);
#endif

        // Set GO bit to zero, because start up state of memory mapped slaves is undefined
        control->writeUI(CTRL_GO_ADDRESS, 0);

        for (k = 0; k < MIX_NUM_LAYERS; k++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            pixel_output[k] = 0;
            widths[k] = MIX_RUNTIME_MAX_WIDTH;
            heights[k] = MIX_RUNTIME_MAX_HEIGHT;
#if MIX_ALPHA_ENABLED
            normalised_alpha[k] = 0;
            alpha_just_in[k] = 0;
#endif
        }
        
        x_min[0] = 0;
        y_min[0] = 0;
        x_max[0] = 0;
        y_max[0] = 0;

        read_alpha = 0;
        num_seq_counter = sc_uint<4>(MIX_CHANNELS_IN_SEQ - 1); // Initialise num_seq_counter to MIX_CHANNELS_IN_SEQ - 1

        for (;;)
        {
            // Write the running bit to 0
            control->writeUI(CTRL_Status_ADDRESS, 0);

            // Initialise ctrl_offset where CTRL_ACTIVE_0 would be if it existed
            ctrl_offset = ctrl_offset_AU.sLdUI(sc_uint<CTRL_OFFSET_BITS>(CTRL_TOP_LEFT_X_1_ADDRESS - 1));
            
            // Parse & propagate all non-image packets from the layers
            for (k = 0; k < MIX_NUM_LAYERS; k++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                sc_uint<HEADER_WORD_BITS> headerType;
                // Read the run-time configurable "active" parameter
                layer_active[k] = sc_uint<2>(control->readUI(ctrl_offset));
                HW_DEBUG_MSG("Layer k=" << k << ", active= " << layer_active[k] << std::endl);
                bool notDisabled = layer_active[k].bit(0) || layer_active[k].bit(1) || (k==0);
                to_output.write((din[k].getEndPacket(), just_read[k])); // write random junk, this is just used to synchronize the threads
                while (replyFlag)
                {
                    wait(replyEvent);
                }
                do
                {
                    just_read[k] = IMAGE_DATA;
                    just_read[k] = just_read_REG[k].cLdUI(din[k].cRead(notDisabled), just_read[k], notDisabled);
                    headerType = sc_uint<HEADER_WORD_BITS>(just_read[k]);
                    HW_DEBUG_MSG_COND(notDisabled, "Layer k=" << k << ", processing packet type " << headerType << std::endl);
                    while(!din[k].getEndPacket() && (headerType != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA)))
                    {
                        ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                        ALT_ATTRIB(ALT_MOD_TARGET, 1);
                        ALT_ATTRIB(ALT_MIN_ITER, 3);
                        ALT_ATTRIB(ALT_SKIDDING, true);
                        bool eop BIND(ALT_WIRE);
                        eop = din[k].getEndPacket();
                        if (!eop)
                        {
                            to_output.write((eop, just_read[k]));
                        }
                        just_read[k] = just_read_REG[k].cLdUI(din[k].cRead(!eop), just_read[k], !eop);
                    }
                    to_output.write((din[k].getEndPacket(), just_read[k])); //write final element of the packet or image data header or 0 for disabled layers)
                } while (headerType != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));
                
                while (!replyFlag)
                {
                    wait(replyEvent);
                }
                // Outputter sets newControlPacketReceived to true if there was one or more control
                // packet and dimensions have to be updated
                widths[k] = widths_REG[k].cLdUI(ctrl_packet_width, widths[k], newControlPacketReceived);
                heights[k] = heights_REG[k].cLdUI(ctrl_packet_height, heights[k], newControlPacketReceived);
                HW_DEBUG_MSG_COND(newControlPacketReceived, "Layer k=" << k << ", dimensions are back " << widths[k] << ", " << heights[k] << std::endl);
                HW_DEBUG_MSG_COND(!newControlPacketReceived, "Layer k=" << k << ", w=" << widths[k] << ", h=" << heights[k] << std::endl);
                
                // Move ctrl_offset to CTRL_ACTIVE_k+1_ADDRESS
                ctrl_offset = ctrl_offset_AU.addSubUI(ctrl_offset, 3, false);
            }

#if MIX_CHANNELS_IN_SEQ == 1
            x_max[0] = sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[0]);
#elif MIX_CHANNELS_IN_SEQ == 2
            x_max[0] = sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[0] << 1);
#elif MIX_CHANNELS_IN_SEQ == 3
            x_max[0] = sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[0] << 1) + sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[0]);
#endif
            backgroundPatternWidth = x_max[0];

            // Check the GO bit before starting to process control data
            while (sc_uint<1>(control->readUI(CTRL_GO_ADDRESS)) != sc_uint<1>(1))
                control->waitForChange();

            // Reinit ctrl_offset to "CTRL_ACTIVE_0_ADDRESS" (which does not exist)
            ctrl_offset = ctrl_offset_AU.sLdUI(sc_uint<CTRL_OFFSET_BITS>(CTRL_TOP_LEFT_X_1_ADDRESS - 1));
            // Read the run-time configurable location parameters
            for (k = 1; k < MIX_NUM_LAYERS; k++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                // Move ctrl_offset to CTRL_TOP_LEFT_X_k_ADDRESS and read y_min[k]
                ctrl_offset = ctrl_offset_AU.addSubUI(ctrl_offset, 1, false);
                x_min[k] = control->readUI(ctrl_offset);
                //++ctrl_offset and read y_min[k]
                ctrl_offset = ctrl_offset_AU.addSubUI(ctrl_offset, 1, false);
                y_min[k] = control->readUI(ctrl_offset);
                //++ctrl_offset to move to CTRL_ACTIVE_k_ADDRESS and be ready for the next iteration
                ctrl_offset = ctrl_offset_AU.addSubUI(ctrl_offset, 1, false);
                
                // Parse & propagate all non-image packets from the active foreground layers 
                if (layer_active[k])
                {
                    // Now that width and height are known, init some variables
                    y_max[k] = y_min[k] + sc_uint<MIX_Y_LOCATION_DATA_BITS>(heights[k]);

                    // The loop on x is not on a per pixel basis but on a per sample basis, update the x_min and x_max value  
#if MIX_CHANNELS_IN_SEQ == 1
                    x_max[k] = x_min[k] + sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[k]);
#elif MIX_CHANNELS_IN_SEQ == 2
                    x_min[k] = x_min[k] + x_min[k];
                    x_max[k] = x_min[k] + sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[k] << 1);
#elif MIX_CHANNELS_IN_SEQ == 3
                    x_min[k] = x_min[k] + sc_uint<MIX_X_LOCATION_DATA_BITS>(x_min[k] << 1);
                    x_max[k] = x_min[k] + sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[k]);
                    x_max[k] = x_max[k] + sc_uint<MIX_X_LOCATION_DATA_BITS>(widths[k] << 1);
#endif

                    // Debug messages to check the satus
                    HW_DEBUG_MSG("width[" << k << "] = " << widths[k] << ", height[" << k << "] = " << heights[k] << std::endl);
                    HW_DEBUG_MSG("y_min[" << k << "] = " << y_min[k] << ", y_max[" << k << "] = " << y_max[k] << std::endl);
                    HW_DEBUG_MSG("After scaling: x_min[" << k << "] = " << x_min[k] << ", x_max[" << k << "] = " << x_max[k] << std::endl);                    

                }
#ifndef __CUSP__
                else
                {
                    HW_DEBUG_MSG("Layer k = " << k << " is disabled." << std::endl);
                }
#endif
            }

#if MIX_ALPHA_ENABLED
            // Discard non image data from alpha layer (alpha_in[0] is never read)
            for (k = 1; k < MIX_NUM_LAYERS; k++)
            {
                HW_DEBUG_MSG("Alpha layer k = " << k << ", discard non-image data." << std::endl);
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                do
                {
                    alpha_just_in[k] = alpha_just_in_AU[k].muxLdUI(alpha_in[k].cRead(layer_active[k]), IMAGE_DATA, !layer_active[k]);
                    if (alpha_just_in[k] != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA))
                    {
                        HW_DEBUG_MSG("Alpha layer k = " << k << ", discarding packet type " << alpha_just_in[k] << std::endl);
                        while (!alpha_in[k].getEndPacket())
                        {
                            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                            ALT_ATTRIB(ALT_MOD_TARGET, 1);
                            ALT_ATTRIB(ALT_MIN_ITER, 3);
                            ALT_ATTRIB(ALT_SKIDDING, true);
                            alpha_in[k].cRead(!alpha_in[k].getEndPacket());
                        }
                    }
                } while (alpha_just_in[k] != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));
            }
#endif

            // Write the running bit
            control->writeUI(CTRL_Status_ADDRESS, 1);

            // Send image data header
            to_output.write((sc_uint<1>(din[0].getEndPacket()), sc_uint<CHANNEL_BITS>(IMAGE_DATA)));
            
            // Loop each pixel in background image
            for (i = 0; (i < heights[0]) && !din[0].getEndPacket(); i++)
            {
                sc_uint<MIX_X_LOCATION_DATA_BITS> j_cp1 = 0; // Cannot use the loop counter inside a modulo 1 loop
                for (sc_uint<MIX_X_LOCATION_DATA_BITS> j = 0; j < x_max[0]; j++)
                {
                    ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                    ALT_ATTRIB(ALT_MOD_TARGET, 1);
                    ALT_ATTRIB(ALT_MIN_ITER, MIX_CHANNELS_IN_SEQ*32);
                    
                    vip_assert(j == j_cp1); // Checking that the internal loop counter does not go out of sync

                    // Background frame block
                    //  mix_this_layer[0] = 1; <- not read anyway

                    // Use a 0-latency variable to store whether we are at the first channel in seq
                    bool num_seq_wrapped BIND(ALT_WIRE);
                    num_seq_wrapped = num_seq_counter == sc_uint<4>(MIX_CHANNELS_IN_SEQ - 1);
                    num_seq_counter = NUM_SEQ_AU.addSubSLdUI(
                                          num_seq_counter,                                                                // A
                                          sc_uint<4>(1),                                                                  // added value
                                          sc_uint<4>(0),                                                                  // to load
                                          num_seq_wrapped,
                                          0);
                    read_alpha = num_seq_wrapped;

                    ++j_cp1;
                    bool background_eop = ((j_cp1 == x_max[0]) && (i == sc_uint<MIX_Y_LOCATION_DATA_BITS>(heights[0] + sc_int<1>(-1))));

                    // 7 frames above the background - check image bound
                    // within_bounds_0_latency[], a temporary 0-latency variable to make the code more readable 
                    bool within_bounds_0_latency[MIX_NUM_LAYERS] BIND(ALT_WIRE);
                    for (k = 1; k < MIX_NUM_LAYERS; k++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        within_bounds_0_latency[k] = (sc_uint<MIX_X_LOCATION_DATA_BITS>(j_cp1) > sc_uint<MIX_X_LOCATION_DATA_BITS>(x_min[k])) &&
                             (sc_uint<MIX_X_LOCATION_DATA_BITS>(j_cp1) <= sc_uint<MIX_X_LOCATION_DATA_BITS>(x_max[k])) &&
                             (sc_uint<MIX_Y_LOCATION_DATA_BITS>(i) >= y_min[k]) && (sc_uint<MIX_Y_LOCATION_DATA_BITS>(i) < y_max[k]);
                        mix_this_layer[k] = (layer_active[k].bit(0) || layer_active[k].bit(1)) && within_bounds_0_latency[k];
                    }

                    // Now let's mix it
                    // Background first
                    just_read[0] = din[0].cRead(!din[0].getEndPacket()); // Do not get past the last element of the background image
                    background_eop = din[0].getEndPacket() || background_eop;
                    UPDATE_WIRES(just_read_wires, MIX_CHANNELS_IN_PAR, 0, just_read[0], 0, MIX_BPS);
                    for (par_cnt = 0; par_cnt < MIX_CHANNELS_IN_PAR; par_cnt++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        pixel_sum[TO_CHANNELS_IN_PAR(0)] = just_read_wires[par_cnt];
                        pixel_output[TO_CHANNELS_IN_PAR(0)] = pixel_sum[TO_CHANNELS_IN_PAR(0)];
                    }

                    // Other layers are mixed to the background
                    for (k = 1; k < MIX_NUM_LAYERS; k++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);

#if MIX_ALPHA_ENABLED
                        // Cusp will want to figure out the alpha for all layers straight away and then stage the alpha values
                        // Use this to delay the calculations and stage 1-bit regs for read_alpha and mix_this_layer[k] instead
                        previous_alpha_tautology[k] = ALT_DONT_EVALUATE(normalised_alpha[k - 1].bit(0) || !normalised_alpha[k - 1].bit(0));

                        // Only read the alpha once every MIX_CHANNELS_IN_SEQ (when num_seq_counter has wrapped)
                        // If this layer doesn't get mixed, then just force the alpha for it to be fully transparent
                        alpha_just_in[k] = alpha_just_in_AU[k].mCLdUI(
                                               alpha_in[k].cRead(mix_this_layer[k] && read_alpha && previous_alpha_tautology[k] && !alpha_in[k].getEndPacket()),
                                               ((1 << MIX_ALPHA_BPS) - 1),
                                               alpha_just_in[k],
                                               read_alpha && mix_this_layer[k] && layer_active[k].bit(0),
                                               read_alpha && !(mix_this_layer[k] && layer_active[k].bit(0)));

                        just_read[k] = din[k].cRead(mix_this_layer[k] && !din[k].getEndPacket() && previous_alpha_tautology[k]);
                        UPDATE_WIRES(just_read_wires, MIX_CHANNELS_IN_PAR, 0, just_read[k], 0, MIX_BPS);

                        // Check for special case if alpha = 2^BPS-1 then we want 
                        is_alpha_val_special_case = alpha_just_in[k] == sc_uint<NORMALISED_ALPHA_BITS>(MIX_SPECIAL_CASE);
                        normalised_alpha[k] = is_alpha_val_special_case ?
                                                     sc_uint < NORMALISED_ALPHA_BITS > (MIX_SPECIAL_CASE + 1) :
                                                     sc_uint < NORMALISED_ALPHA_BITS > (alpha_just_in[k]);

                        complemented_alpha[k] = complemented_alpha_AU[k].addSubSLdUI(
                                                    1 << MIX_ALPHA_BPS,
                                                    alpha_just_in[k],
                                                    0,
                                                    is_alpha_val_special_case,
                                                    1);

                        // Cusp will want to do the multiplication for this layer before doing the one from the previous layer
                        // use this fallacy to make them happen together.
                        for (par_cnt = 0; par_cnt < MIX_CHANNELS_IN_PAR; par_cnt++)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            pixel_output_fallacy = ALT_DONT_EVALUATE(pixel_output[TO_CHANNELS_IN_PAR(k - 1)].bit(0) && !pixel_output[TO_CHANNELS_IN_PAR(k - 1)].bit(0));

                            lower_layers_alphaed[TO_CHANNELS_IN_PAR(k)] = lower_layers_alphaed_MULT[TO_CHANNELS_IN_PAR(k)].multUI(normalised_alpha[k], pixel_output[TO_CHANNELS_IN_PAR(k - 1)]);
                            this_layer_alphaed[TO_CHANNELS_IN_PAR(k)] = this_layer_alphaed_MULT[TO_CHANNELS_IN_PAR(k)].multUI(complemented_alpha[k], pixel_output_fallacy | just_read_wires[par_cnt]);

                            pixel_sum[TO_CHANNELS_IN_PAR(k)] = (lower_layers_alphaed[TO_CHANNELS_IN_PAR(k)] + this_layer_alphaed[TO_CHANNELS_IN_PAR(k)]);
                            pixel_output[TO_CHANNELS_IN_PAR(k)] = pixel_sum[TO_CHANNELS_IN_PAR(k)] >> MIX_ALPHA_BPS;
                        }
#else
                        just_read[k] = din[k].cRead(mix_this_layer[k] && !din[k].getEndPacket());
                        UPDATE_WIRES(just_read_wires, MIX_CHANNELS_IN_PAR, 0, just_read[k], 0, MIX_BPS);
                        
                        for (par_cnt = 0; par_cnt < MIX_CHANNELS_IN_PAR; par_cnt++)
                        {
                            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                            pixel_sum[TO_CHANNELS_IN_PAR(k)] = pixel_sum_AU[TO_CHANNELS_IN_PAR(k)].muxLdUI(just_read_wires[par_cnt],
                                                               pixel_output[TO_CHANNELS_IN_PAR(k - 1)],
                                                               !mix_this_layer[k] || layer_active[k].bit(1));
                            pixel_output[TO_CHANNELS_IN_PAR(k)] = pixel_sum[TO_CHANNELS_IN_PAR(k)];
                        }
#endif
                    }
                    
                    // Output pixel every cycle
                    sc_uint<CHANNEL_BITS> output_word BIND(ALT_WIRE);
                    output_word = pixel_output[EXPLICIT_TO_CHANNELS_IN_PAR(MIX_NUM_LAYERS - 1, 0)] << ((MIX_CHANNELS_IN_PAR - 1) * MIX_BPS);
                    for (par_cnt = 1; par_cnt < MIX_CHANNELS_IN_PAR; par_cnt++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        output_word = (sc_uint<MIX_BPS>(pixel_output[TO_CHANNELS_IN_PAR(MIX_NUM_LAYERS - 1)]), output_word.range(MIX_BPS * MIX_CHANNELS_IN_PAR - 1, MIX_BPS));
                    }
                    
                    // Always output to the FIFO even if end of packet was received
                    to_output.write((sc_uint<1>(background_eop), output_word));
                } // Loop columns
            } // Loop rows

#ifndef __CUSP__
            if (!din[0].getEndPacket())
            {
                HW_DEBUG_MSG("background layer did not get the expected eop, discarding extra data" << std::endl); 
            }
            for (k = 1; k < MIX_NUM_LAYERS; k++)
            {
                if (!din[k].getEndPacket() && layer_active[k])
                {
                    HW_DEBUG_MSG("layer " << k << ',' << " did not get the expected eop, discarding extra data" << std::endl); 
                }
            }
#endif //n__CUSP__

            // Discard extra image data from all the layers (background included)
            bool discard_complete_wire BIND(ALT_WIRE);
            discard_complete_wire = din[0].getEndPacket();
            for (k = 1; k < MIX_NUM_LAYERS; k++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                #if MIX_ALPHA_ENABLED
                    discard_complete_wire &= layer_active[k] ? (din[k].getEndPacket() & alpha_in[k].getEndPacket()) : true;
                #else
                    discard_complete_wire &= layer_active[k] ? din[k].getEndPacket() : true;
                #endif
            }
            bool discard_complete = discard_complete_wire;
            while (!discard_complete)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);
                ALT_ATTRIB(ALT_MIN_ITER, 3);
                ALT_ATTRIB(ALT_SKIDDING, true);
                bool discard_complete_wire BIND(ALT_WIRE) = din[0].getEndPacket();
                din[0].cRead(!din[0].getEndPacket());
                for (k = 1; k < MIX_NUM_LAYERS; k++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MIX_NUM_LAYERS - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, MIX_NUM_LAYERS - 1);
                    #if MIX_ALPHA_ENABLED
                        discard_complete_wire &= (layer_active[k] ? (din[k].getEndPacket() & alpha_in[k].getEndPacket()) : true);
                        din[k].cRead(!din[k].getEndPacket() && layer_active[k]);
                        alpha_in[k].cRead(!alpha_in[k].getEndPacket() && layer_active[k]);
                    #else
                        discard_complete_wire &= layer_active[k] ? din[k].getEndPacket() : true;
                        din[k].cRead(!din[k].getEndPacket() && layer_active[k]);
                    #endif
                }
                discard_complete = discard_complete_wire;
            }
        } // Infinite for loop
    }

#endif //SYNTH_MODE

    const char* param;
    SC_HAS_PROCESS(MIX_NAME);
    MIX_NAME(sc_module_name name_, const char* PARAMETERISATION = "<mixerParams><MIX_NAME>mixer</MIX_NAME><MIX_ALPHA_ENABLED>true</MIX_ALPHA_ENABLED><MIX_ALPHA_BPS>8</MIX_ALPHA_BPS><MIX_CHANNELS_IN_SEQ>3</MIX_CHANNELS_IN_SEQ><MIX_CHANNELS_IN_PAR>1</MIX_CHANNELS_IN_PAR><MIX_BPS>8</MIX_BPS><MIX_NUM_LAYERS>2</MIX_NUM_LAYERS><MIX_RUNTIME_MAX_WIDTH>1024</MIX_RUNTIME_MAX_WIDTH><MIX_RUNTIME_MAX_HEIGHT>768</MIX_RUNTIME_MAX_HEIGHT></mixerParams>") : sc_module(name_), param(PARAMETERISATION)
    {
        dout = new ALT_AVALON_ST_OUTPUT< sc_uint< CHANNEL_BITS > > ();
        control = new ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
        control->setUseOwnClock(false);
        alpha_in = NULL;
        
#ifndef LEGACY_FLOW
        int layer_count = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "mixerParams;MIX_NUM_LAYERS", 2);
        int alpha_enabled = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "mixerParams;MIX_ALPHA_ENABLED", 0);
        int channels_in_parallel = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "mixerParams;MIX_CHANNELS_IN_PAR", 1);
        int mix_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "mixerParams;MIX_BPS", 8);
        int alpha_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "mixerParams;MIX_ALPHA_BPS", 2);

        din = new ALT_AVALON_ST_INPUT< sc_uint< CHANNEL_BITS > > [layer_count];      

        if(alpha_enabled)
        {
            alpha_in = new ALT_AVALON_ST_INPUT< sc_uint< MIX_ALPHA_BPS > > [layer_count];
        }

        for(unsigned int k = 0; k < layer_count; ++k)
        {           
            din[k].setDataWidth(mix_bps*channels_in_parallel);
            din[k].setSymbolsPerBeat(channels_in_parallel);
            din[k].enableEopSignals();
            if(alpha_enabled)
            {        
                alpha_in[k].setSymbolsPerBeat(1);
                alpha_in[k].setDataWidth(alpha_bps);
                alpha_in[k].enableEopSignals();
            }
        }

        dout->setSymbolsPerBeat(channels_in_parallel); 
        dout->setDataWidth(mix_bps*channels_in_parallel);
        dout->enableEopSignals();
#else
        din = new ALT_AVALON_ST_INPUT< sc_uint< CHANNEL_BITS > > [MIX_NUM_LAYERS];
#if MIX_ALPHA_ENABLED
        alpha_in = new ALT_AVALON_ST_INPUT< sc_uint< MIX_ALPHA_BPS > > [MIX_NUM_LAYERS];
#endif                
        for(unsigned int k = 0; k < MIX_NUM_LAYERS; ++k)
        {
            din[k].setSymbolsPerBeat(MIX_CHANNELS_IN_PAR);
#if MIX_ALPHA_ENABLED
            alpha_in[k].setSymbolsPerBeat(1);
#endif
        }
#endif
         
#ifdef SYNTH_MODE 
        SC_THREAD(behaviour);
        SC_THREAD(outputter);
#endif //SYNTH_MODE
    }
};
