//! \file vip_csc_hwfast.hpp
//!
//! \author nculver
//!
//! \brief Synthesisable Colour Space Converter core.
//! A Colour Space Converter core that
//! can be parameterised and then synthesised with CusP.
//! CAUTION this is not in a particularly readable state, cusp functions are not returning hence "output_conversion_results"

// causes CusP 6.1 to bind arrays of register files backwards the way CusP 6.0 did
#pragma cusp_config bindFuToInnermost = yes 
// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
 #include <alt_cusp.h>
#endif // n__CUSP__

#include "vip_constants.h"
#include "vip_common.h"

#ifdef DOXYGEN
 #define CSC_NAME CSC_HW
#endif

#ifndef LEGACY_FLOW
	#undef CSC_NAME
	#define CSC_NAME alt_vip_csc
#endif

#if CSC_ADDER_DATA_TYPE==DATA_TYPE_SIGNED
 #define CSC_ADDER_DATA_TYPE_SYSC sc_int
#else
 #define CSC_ADDER_DATA_TYPE_SYSC sc_uint
#endif

#if CSC_COEFF_PRECISION_CPC_COEFFS_TYPE==DATA_TYPE_SIGNED
 #define COEFF_SYSC_TYPE sc_int
 #define COEFF_SET_OPERATION setSI
#else
 #define COEFF_SYSC_TYPE sc_uint
 #define COEFF_SET_OPERATION setUI
#endif

#if CSC_SUMM_PRECISION_CPC_COEFFS_TYPE==DATA_TYPE_SIGNED
 #define SUMM_SYSC_TYPE sc_int
 #define CONST_SET_OPERATION setSI
#else
 #define SUMM_SYSC_TYPE sc_uint
 #define CONST_SET_OPERATION setUI
#endif

#if IODT_INPUT_DATA_TYPE==DATA_TYPE_SIGNED
 #define INPUT_TYPE_SYSC sc_int
 #define CONDITIONAL_LOAD_OPERATION cLdSI
#else
 #define INPUT_TYPE_SYSC sc_uint
 #define CONDITIONAL_LOAD_OPERATION cLdUI
#endif

#if CSC_MULTIPLIER_DATA_TYPE==DATA_TYPE_SIGNED
 #define MULTIPLIER_SYSC_TYPE sc_int
 #define MULTIPLY_OPERATION multSI
#else
 #define MULTIPLIER_SYSC_TYPE sc_uint
 #define MULTIPLY_OPERATION multUI
#endif

//! Perform Colour Space Conversion on frame.
//!
//! <b>Compile Time Configuration in IP Toolbench</b>
//!
//! These are the same as the IP user parameters defined by the
//! \link ::CSC_SW(sc_uint<CSC_BPS>*,sc_uint<CSC_BPS>*,sc_uint<CSC_BPS>*,sc_uint<CSC_BPS>*,sc_uint<CSC_BPS>*,sc_uint<CSC_BPS>*,CSC_FP_TYPE*) software model \endlink.
//! \ingroup HWCores
SC_MODULE(CSC_NAME)
{
	
#ifndef LEGACY_FLOW
	static const char * get_entity_helper_class(void) { 
		return "ip_toolbench/csc.jar?com.altera.vip.entityinterfaces.helpers.CSCEntityHelper"; 
	}
	
	static const char * get_display_name(void) { 
		return "CSC"; 
	}
	
	static const char * get_certifications(void) { 
		return "SOPC_BUILDER_READY"; 
	}
	
	static const char * get_product_ids(void) { 
		return "0003"; 
	}
	
	static const char * get_description(void) {
		return "The Color Space Converter transforms video data between color spaces.";
	}
	
	#include "vip_elementclass_info.h"
#else
	static const char * get_entity_helper_class(void) { 
		return "default"; 
	}
#endif //LEGACY_FLOW
	
#ifndef SYNTH_MODE
#define IODT_INPUT_BPS 20
#define IODT_OUTPUT_BPS 20
#define CSC_CHANNELS_IN_PAR 3
#define CTRL_INTERFACE_WIDTH 32
#define CTRL_INTERFACE_DEPTH 14
#endif
	
    //! Input ports
    ALT_AVALON_ST_INPUT< sc_uint<IODT_INPUT_BPS*CSC_CHANNELS_IN_PAR > >* din  ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    //! Output ports
    ALT_AVALON_ST_OUTPUT< sc_uint<IODT_OUTPUT_BPS*CSC_CHANNELS_IN_PAR > >* dout  ALT_CUSP_DISABLE_NUMBER_SUFFIX;	
    
    ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>* control  ALT_CUSP_DISABLE_NUMBER_SUFFIX;	
	
#ifdef SYNTH_MODE

	#define ODTC_CHAN_A output_type_conversion_chan_a
	#define ODTC_CHAN_B output_type_conversion_chan_b
	#define ODTC_CHAN_C output_type_conversion_chan_c
	#define ODTC_FNAME ODTC_CHAN_A
	#include "vip_output_conversion.h"
	#undef ODTC_FNAME
	#define ODTC_FNAME ODTC_CHAN_B
	#include "vip_output_conversion.h"
	#undef ODTC_FNAME
	#define ODTC_FNAME ODTC_CHAN_C
	#include "vip_output_conversion.h"

    unsigned j;

	ALT_REG<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> coeff_data_regs[9]; 
	COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>coeff_data[9] BIND(coeff_data_regs);	
	ALT_REG<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> const_data_regs[3];
	SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>const_data[3] BIND(const_data_regs);


void reset_ctrl_and_coeffs()
{
	#if CSC_RUNTIME_COEFFICIENTS
			// set GO bit to zero, because start up state of memory mapped slaves is undefined
			control->writeUI(0, 0);
	#else	

	
    const COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>coeff_data_init[9] = CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFFS;
    const SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>const_data_init[3] = CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFFS;
	for(int a=0;a<9;a++){
		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		coeff_data[a]=coeff_data_init[a];
	}
	
	for(int a=0;a<3;a++){
		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		const_data[a]=const_data_init[a];
	}
	
    #endif
			
}

void read_ctrl()
{
#if CSC_RUNTIME_COEFFICIENTS
	// Write the running bit
	control->writeUI(CTRL_Status_ADDRESS, 0);
	
	// Between each frame read the run-time configurable location parameters
	// Check the done bit before starting to read
	while (!control->readUI(CTRL_Go_ADDRESS).bit(0))
		control->waitForChange();
	
	coeff_data[0] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_0_ADDRESS));
	coeff_data[1] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_1_ADDRESS));
	coeff_data[2] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_2_ADDRESS));
	coeff_data[3] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_3_ADDRESS));
	coeff_data[4] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_4_ADDRESS));
	coeff_data[5] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_5_ADDRESS));
	coeff_data[6] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_6_ADDRESS));
	coeff_data[7] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_7_ADDRESS));
	coeff_data[8] = COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_COEFF_8_ADDRESS));		
	const_data[0] = SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_SUMM_0_ADDRESS));
	const_data[1] = SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_SUMM_1_ADDRESS));
	const_data[2] = SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH>(control->readSI(CTRL_SUMM_2_ADDRESS));							
	
	// Write the running bit
	control->writeUI(CTRL_Status_ADDRESS, 1);
#endif
}
    

#if CSC_CHANNELS_IN_PAR == 3
//parallel mode, simple function
#define I_WIDTH 32
    
    void behaviour()
    {	
    	reset_ctrl_and_coeffs();
        
        for (;;)
        {
        	handle_non_image_packets();
        	read_ctrl();
            do_csc();
        }
    }
    
	#define PARALLEL_BPS_PAD IODT_OUTPUT_BPS-IODT_INPUT_BPS
    
    sc_uint<IODT_INPUT_BPS*CSC_CHANNELS_IN_PAR> just_read_non_img;

	sc_uint<IODT_OUTPUT_BPS*3> parallel_input_packet_data_to_output_type(sc_uint<IODT_INPUT_BPS*3> just_read_non_img)
	{
		sc_uint<IODT_OUTPUT_BPS*3> output;
		#if PARALLEL_BPS_PAD > 0
		{	
			output =(	sc_uint<PARALLEL_BPS_PAD>(0),
		    			just_read_non_img.range((IODT_INPUT_BPS*3)-1,IODT_INPUT_BPS*2),
		    			sc_uint<PARALLEL_BPS_PAD>(0),
		    			just_read_non_img.range((IODT_INPUT_BPS*2)-1,IODT_INPUT_BPS*1), 
		    			sc_uint<PARALLEL_BPS_PAD>(0),
						just_read_non_img.range((IODT_INPUT_BPS*1)-1,IODT_INPUT_BPS*0));
		}
		#else
		{
			output =(	just_read_non_img.range((IODT_INPUT_BPS*2)+IODT_OUTPUT_BPS-1,IODT_INPUT_BPS*2),
		    			just_read_non_img.range((IODT_INPUT_BPS*1)+IODT_OUTPUT_BPS-1,IODT_INPUT_BPS*1), 
						just_read_non_img.range((IODT_INPUT_BPS*0)+IODT_OUTPUT_BPS-1,IODT_INPUT_BPS*0));
		}
		#endif
		return output;
			
	}

    void propagate_until_eop()
    {
        while (!din->getEndPacket())
        {
            just_read_non_img = din->read();
            dout->writeDataAndEop(parallel_input_packet_data_to_output_type(just_read_non_img), din->getEndPacket());
        }
        dout->setEndPacket(false);

    }

    void handle_non_image_packets()
    {
        sc_uint<HEADER_WORD_BITS> header_type;
        do
        {
        	//in parallel mode this ok as header type is bits 0-3 everything else unused
            just_read_non_img = din->read();
            header_type = just_read_non_img;
            dout->write(just_read_non_img);
            if(header_type != IMAGE_DATA)
            {
            	propagate_until_eop();
            }
        }
        while (header_type != IMAGE_DATA);

    }
   
    void do_csc()
    {	
        ALT_MULT<CSC_MULTIPLIER_SIZE> multipliers[9];
        sc_uint<I_WIDTH> i;
		
        sc_uint<IODT_INPUT_BPS*CSC_CHANNELS_IN_PAR> just_read = sc_uint<IODT_INPUT_BPS*CSC_CHANNELS_IN_PAR>(0);
        sc_uint<IODT_OUTPUT_BPS*CSC_CHANNELS_IN_PAR> output = sc_uint<IODT_OUTPUT_BPS*CSC_CHANNELS_IN_PAR>(0);

        ALT_AU<CSC_ADDER_SIZE> coeff_intermediates_AUS[6];
        CSC_ADDER_DATA_TYPE_SYSC<CSC_ADDER_SIZE> coeff_intermediates[6] BIND(coeff_intermediates_AUS);
        
		for(; !din->getEndPacket() ; )
        {
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MIN_ITER, 32);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_SKIDDING, true);
            
            just_read = (sc_uint<IODT_INPUT_BPS * CSC_CHANNELS_IN_PAR>)din->readWithinPacket(false);

            for (j = 0; j < CSC_CHANNELS_IN_PAR; j++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 3);
                ALT_ATTRIB(ALT_MAX_ITER, 3);

                coeff_intermediates[j*2 + 0] = multipliers[j * 3 + 0].MULTIPLY_OPERATION( 
                								MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(coeff_data[j * 3 + 0]),
                								MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>((INPUT_TYPE_SYSC<IODT_INPUT_BPS>)just_read.range(IODT_INPUT_BPS - 1, 0)))
                                               	+ 
                                               	multipliers[j * 3 + 1].MULTIPLY_OPERATION(
                                               	MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(coeff_data[j * 3 + 1]),
                                               	MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>((INPUT_TYPE_SYSC<IODT_INPUT_BPS>)just_read.range(IODT_INPUT_BPS * 2 - 1, IODT_INPUT_BPS)));
                                               	
                coeff_intermediates[j*2 + 1] = multipliers[j * 3 + 2].MULTIPLY_OPERATION(
                								MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(coeff_data[j * 3 + 2]),
                								MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>((INPUT_TYPE_SYSC<IODT_INPUT_BPS>)just_read.range(IODT_INPUT_BPS * 3 - 1, IODT_INPUT_BPS * 2)))
                                               	+ const_data[j];
            }

			sc_int<64> result_channel_a = sc_int<64>(coeff_intermediates[2*2 + 0] + coeff_intermediates[2*2 + 1]);
			sc_int<64> result_channel_b = sc_int<64>(coeff_intermediates[1*2 + 0] + coeff_intermediates[1*2 + 1]);
			sc_int<64> result_channel_c = sc_int<64>(coeff_intermediates[0*2 + 0] + coeff_intermediates[0*2 + 1]);
			

            //convert results to correct data type for output            
			sc_uint<IODT_OUTPUT_BPS> output_chan_a = 	sc_uint<IODT_OUTPUT_BPS>(
															MK_FNAME(ODTC_CHAN_A,output_type_conversion)(result_channel_a)
																	.range(IODT_OUTPUT_BPS-1,0)
														);
			sc_uint<IODT_OUTPUT_BPS> output_chan_b = 	sc_uint<IODT_OUTPUT_BPS>(
															MK_FNAME(ODTC_CHAN_B,output_type_conversion)(result_channel_b)
																	.range(IODT_OUTPUT_BPS-1,0)
														);
			sc_uint<IODT_OUTPUT_BPS> output_chan_c = 	sc_uint<IODT_OUTPUT_BPS>(
															MK_FNAME(ODTC_CHAN_C,output_type_conversion)(result_channel_c)
																	.range(IODT_OUTPUT_BPS-1,0)
														);			
			//output results
	        output = ( output_chan_a , output_chan_b, output_chan_c);	
		 	dout->cWrite(output, !din->getEndPacket());
		}
		
		//write last bit of data and eop 
		dout->writeDataAndEop(output, true);
		dout->setEndPacket(false);
		
		//TODO: REMOVE THIS WHILE LOOP!! SERVES NO PURPOSE OTHER THAN TO ALLOW CUSP COMPILE
		while(!din->getEndPacket())
		{
		}	
		
		//pop last read from din
		din->read();
    }
    
  

    
    

#elif CSC_CHANNELS_IN_SEQ == 3
//sequence mode, less simple
 #define SEQ_WIDTH LOG2_SEQ
 
    //#define USE_VIP_PACKET_READER 1
    #ifdef USE_VIP_PACKET_READER  	
        #define PACKET_BPS IODT_INPUT_BPS    
    	#define PACKET_CHANNELS_IN_PAR 1    
    	#define PACKET_HEADER_TYPE_VAR headerType    
        #define PACKET_JUST_READ_VAR justReadNonImg    
    	#include "vip_packet_reader.hpp"
    #endif  
    
    void behaviour()
    {
    	reset_ctrl_and_coeffs();
    	
        for (;;)
        {
#ifdef USE_VIP_PACKET_READER		
			handleNonImagePackets();
#else
			handle_non_image_packets();
#endif
#if CSC_RUNTIME_COEFFICIENTS			
			read_ctrl();
#endif
            do_csc();
        }
    }
   
#ifndef USE_VIP_PACKET_READER
    sc_uint<IODT_INPUT_BPS> just_read_non_img;

    void propagate_until_eop()
    {
        while (!din->getEndPacket())
        {
            just_read_non_img = din->read();
            dout->writeDataAndEop(just_read_non_img, din->getEndPacket());
        }
        dout->setEndPacket(false);
    }

    void handle_non_image_packets()
    {
        sc_uint<HEADER_WORD_BITS> header_type;
        do
        {
            just_read_non_img = din->read();
            header_type = just_read_non_img;
            
            dout->write(just_read_non_img);

            if (header_type != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA))
            {
                propagate_until_eop();
            }

        }
        while (header_type != IMAGE_DATA);
    }
#endif //USE_VIP_PACKET_READER

    void do_csc()
    {   	
        ALT_MULT<CSC_MULTIPLIER_SIZE> multipliers[3];

        ALT_CMP<SEQ_WIDTH> pix_in_enable_CMP[CSC_CHANNELS_IN_SEQ];
        ALT_CMP<SEQ_WIDTH> pix_use_enable_CMP;

        sc_uint<SEQ_WIDTH> sequence_d;

        // We need access to different segments of the coefficients depending on
        // which colour plane we are outputing, so they are stored in shift
        // registers where 0..3 are the active coefficients and they are rotated
        // in the main loop
        ALT_REG<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_coeff_data_REG[9];
        ALT_REG<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_const_data_REG[3];
        COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_coeff_data[9] BIND(registered_coeff_data_REG);
        SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_const_data[3] BIND(registered_const_data_REG);
        // Some wires for the rotation
        COEFF_SYSC_TYPE<CSC_COEFF_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_coeff_data_old[3] BIND(ALT_WIRE);
        SUMM_SYSC_TYPE<CSC_SUMM_PRECISION_CPC_QUANTISED_INTEGER_COEFF_WIDTH> registered_const_data_old[1] BIND(ALT_WIRE);

        // Registers the input from din
        INPUT_TYPE_SYSC<IODT_INPUT_BPS> just_read;

        // The colours just read as they come in
        ALT_REG<IODT_INPUT_BPS> pix_in_REG[3];
        INPUT_TYPE_SYSC<IODT_INPUT_BPS> pix_in[3] BIND(pix_in_REG);

        // The colours being used to calculate the output values. When pix_in are
        // all valid, they get copied here
        ALT_REG<IODT_INPUT_BPS> pix_use_REG[3];
        INPUT_TYPE_SYSC<IODT_INPUT_BPS> pix_use[3] BIND(pix_use_REG);

        // Intermediate values in the logic tree to cacluate an output value
        ALT_AU<CSC_ADDER_SIZE> coeff_intermediates_AUS[3];
        CSC_ADDER_DATA_TYPE_SYSC<CSC_ADDER_SIZE> coeff_intermediates[3] BIND(coeff_intermediates_AUS);

        // The which colour plane the next read from the input will be from
        DECLARE_VAR_WITH_AU(sc_uint<SEQ_WIDTH>, SEQ_WIDTH, sequence);

        // Used in unrolled loops
        unsigned sequence_cnt;
        
#ifdef USE_VIP_PACKET_READER
		dout->write(sc_uint<IODT_OUTPUT_BPS>(IMAGE_DATA));
#endif

        // Load up the coefficients in the order [8..11][0..3][4..7] so that the
        // first rotation will put [0..3] at the head
        for (sequence_cnt = 0; sequence_cnt < 6; sequence_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, 6);
            ALT_ATTRIB(ALT_MAX_ITER, 6);

            registered_coeff_data[sequence_cnt + 3] = coeff_data[sequence_cnt];
        }
        registered_const_data[1] = const_data[0];
        registered_const_data[2] = const_data[1];

        for (sequence_cnt = 0; sequence_cnt < 3; sequence_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, 3);
            ALT_ATTRIB(ALT_MAX_ITER, 3);
            registered_coeff_data[sequence_cnt] = coeff_data[6 + sequence_cnt];
        }
        registered_const_data[0] = const_data[2];

        // Load two pixel values so that the first read will result in a complete
        // set in pix_in
        for (sequence_cnt = 0; sequence_cnt < CSC_CHANNELS_IN_SEQ - 1; sequence_cnt++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, CSC_CHANNELS_IN_SEQ - 1);
            ALT_ATTRIB(ALT_MAX_ITER, CSC_CHANNELS_IN_SEQ - 1);
            pix_in[sequence_cnt] = (INPUT_TYPE_SYSC<IODT_INPUT_BPS>)din->readWithinPacket(false);
            pix_use[sequence_cnt] = 0;
        }
        pix_in[CSC_CHANNELS_IN_SEQ - 1] = 0;
        pix_use[CSC_CHANNELS_IN_SEQ - 1] = 0;
        
        sequence = CSC_CHANNELS_IN_SEQ - 2;
        sequence_d = sequence; 

        sc_uint<IODT_OUTPUT_BPS> output;		
	
		sc_uint<5> run_on = sc_uint<5>(0);
 
		for(; run_on<sc_uint<5>(3) ;)
        {
            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
            ALT_ATTRIB(ALT_MIN_ITER, 32);
            ALT_ATTRIB(ALT_MOD_TARGET, 1);
            ALT_ATTRIB(ALT_SKIDDING, true);
            
            // Update the channels in sequence count (cycles in range 0..CSC_CHANNELS_IN_SEQ-1)
            sequence = sequence_AU.addSubSLdUI(
                           sequence,
                           1,
                           0,
                           sequence >= sc_uint<SEQ_WIDTH>(CSC_CHANNELS_IN_SEQ - 1),
                           0);
            sequence_d = sequence;
            // Rotate the coefficient data in 3 parts:
            // Part 1. Copy the head to some wires
            for (sequence_cnt = 0; sequence_cnt < 3; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 3);
                ALT_ATTRIB(ALT_MAX_ITER, 3);
                registered_coeff_data_old[sequence_cnt] = registered_coeff_data[sequence_cnt];
            }
            registered_const_data_old[0] = registered_const_data[0];
            // Part 2. Shift the first 8 values
            for (sequence_cnt = 0; sequence_cnt < 6; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 6);
                ALT_ATTRIB(ALT_MAX_ITER, 6);
                registered_coeff_data[sequence_cnt] = registered_coeff_data[sequence_cnt + 3];
            }
            registered_const_data[0] = registered_const_data[1];
            registered_const_data[1] = registered_const_data[2];
            // Part 3. Take the old head from the wires and put it at the tail
            for (sequence_cnt = 0; sequence_cnt < 3; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 3);
                ALT_ATTRIB(ALT_MAX_ITER, 3);
                registered_coeff_data[6 + sequence_cnt] = registered_coeff_data_old[sequence_cnt];
            }
            registered_const_data[2] = registered_const_data_old[0];

			just_read = din->readWithinPacket(false);
			
            // Put the just read data into the appropriate _in pixel depending where
            // we are in the sequence
            for (sequence_cnt = 0; sequence_cnt < CSC_CHANNELS_IN_SEQ; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, CSC_CHANNELS_IN_SEQ);
                ALT_ATTRIB(ALT_MAX_ITER, CSC_CHANNELS_IN_SEQ);



                pix_in[sequence_cnt] = pix_in_REG[sequence_cnt].CONDITIONAL_LOAD_OPERATION(
                                           just_read,
                                           pix_in[sequence_cnt],
                                           pix_in_enable_CMP[sequence_cnt].eUI(sequence, ALT_EVALUATE(sc_uint<SEQ_WIDTH>(sequence_cnt))));
            }

            // When we are starting a new sequence, copy the loading data to the using data
            for (sequence_cnt = 0; sequence_cnt < CSC_CHANNELS_IN_SEQ; sequence_cnt++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, CSC_CHANNELS_IN_SEQ);
                ALT_ATTRIB(ALT_MAX_ITER, CSC_CHANNELS_IN_SEQ);
                pix_use[sequence_cnt] = pix_use_REG[sequence_cnt].CONDITIONAL_LOAD_OPERATION(
                                            pix_in[sequence_cnt],
                                            pix_use[sequence_cnt],
                                            pix_use_enable_CMP.eUI(sequence_d, CSC_CHANNELS_IN_SEQ - 1));
            }

            // The actual calculation of output values

            //need to do some casting here
            //if any input is signed then the operation here will be a signed multiply therefore
            //need to be a little careful in casting positives to too small negatives
            //most eff way to do it is to cast in the registered_const/coeff_datas and in the pix use array

            coeff_intermediates[0] = multipliers[0].MULTIPLY_OPERATION(MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(registered_coeff_data[0]), MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(pix_use[0]))
                                     + multipliers[1].MULTIPLY_OPERATION(MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(registered_coeff_data[1]), MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(pix_use[1]));
            coeff_intermediates[1] = multipliers[2].MULTIPLY_OPERATION(MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(registered_coeff_data[2]), MULTIPLIER_SYSC_TYPE<CSC_MULTIPLIER_SIZE>(pix_use[2]))
                                     + registered_const_data[0];

            coeff_intermediates[2] = coeff_intermediates[0] + coeff_intermediates[1];

			//send results through the output conversion          
			output = run_on<sc_uint<5>(3) ?	sc_uint<IODT_OUTPUT_BPS>(
													MK_FNAME(ODTC_CHAN_A,output_type_conversion)
														(sc_int<64>(coeff_intermediates[2]))
															.range(IODT_OUTPUT_BPS-1,0)
												) : output;
						
		 	dout->cWrite(output, run_on<sc_uint<10>(2));
		 	run_on+=sc_uint<5>(din->getEndPacket());

		}

        
		//write last bit of data and eop 
		dout->writeDataAndEop(output, true);
		dout->setEndPacket(false);
		
		//empty

			while(!din->getEndPacket())
			{
				din->readWithinPacket(false);	
			}	

		
		//pop last read from din
		din->read();
        
    }
#else
 #error There must be either 1 channel in sequence, 3 parallel or 3 in sequence, 1 parallel
#endif

#endif // SYNTH_MODE
	
	SC_HAS_PROCESS(CSC_NAME);

	CSC_NAME(sc_module_name name_, const char* PARAMETERISATION="<cscParams> <CSC_NAME>a_csc</CSC_NAME> <CSC_CHANNELS_IN_SEQ>3</CSC_CHANNELS_IN_SEQ>  <CSC_CHANNELS_IN_PAR>1</CSC_CHANNELS_IN_PAR>  <CSC_INPUT_OUTPUT_DATATYPES>   <IODT_INPUT_BPS>8</IODT_INPUT_BPS>   <IODT_OUTPUT_BPS>8</IODT_OUTPUT_BPS>   <IODT_INPUT_DATA_TYPE>DATA_TYPE_UNSIGNED</IODT_INPUT_DATA_TYPE>   <IODT_OUTPUT_DATA_TYPE>DATA_TYPE_UNSIGNED</IODT_OUTPUT_DATA_TYPE>   <IODT_USE_INPUT_GUARD_BANDS>false</IODT_USE_INPUT_GUARD_BANDS>   <IODT_INPUT_GUARD_MIN>0</IODT_INPUT_GUARD_MIN>   <IODT_INPUT_GUARD_MAX>255</IODT_INPUT_GUARD_MAX>   <IODT_USE_OUTPUT_GUARD_BANDS>false</IODT_USE_OUTPUT_GUARD_BANDS>   <IODT_OUTPUT_GUARD_MIN>0</IODT_OUTPUT_GUARD_MIN>   <IODT_OUTPUT_GUARD_MAX>255</IODT_OUTPUT_GUARD_MAX>  </CSC_INPUT_OUTPUT_DATATYPES>  <CSC_PREDEFINED_CONVERSION>SDTV_CRGB_TO_YCBCR</CSC_PREDEFINED_CONVERSION>  <CSC_COEFFICIENTS>   <row>    <mult>0.66</mult>    <mult>0.66</mult>    <mult>0.66</mult>    <add>-128</add>   </row>   <row>    <mult>0.66</mult>    <mult>0.66</mult>    <mult>0.66</mult>    <add>-128</add>   </row>   <row>    <mult>0.66</mult>    <mult>0.66</mult>    <mult>0.66</mult>    <add>-128</add>   </row>  </CSC_COEFFICIENTS>  <CSC_COEFF_PRECISION>   <CPC_INTEGER_BITS>0</CPC_INTEGER_BITS>   <CPC_FRACTION_BITS>8</CPC_FRACTION_BITS>   <CPC_COEFFS_SIGNED>true</CPC_COEFFS_SIGNED>  </CSC_COEFF_PRECISION>  <CSC_SUMM_PRECISION>   <CPC_INTEGER_BITS>8</CPC_INTEGER_BITS>   <CPC_FRACTION_BITS>8</CPC_FRACTION_BITS>   <CPC_COEFFS_SIGNED>false</CPC_COEFFS_SIGNED>  </CSC_SUMM_PRECISION>  <CSC_OUTPUT_CONVERSION>   <ODTC_SCALE>0</ODTC_SCALE>   <ODTC_FIXEDPOINT_TO_INTEGER>FRACTION_BITS_ROUND_HALF_UP</ODTC_FIXEDPOINT_TO_INTEGER>   <ODTC_CONVERT_SIGNED_TO_UNSIGNED>CONVERT_TO_UNSIGNED_SATURATE</ODTC_CONVERT_SIGNED_TO_UNSIGNED>  </CSC_OUTPUT_CONVERSION> <CSC_RUNTIME_COEFFICIENTS>false</CSC_RUNTIME_COEFFICIENTS> </cscParams>") : sc_module(name_), param(PARAMETERISATION)
    {
	    din = new ALT_AVALON_ST_INPUT< sc_uint<IODT_INPUT_BPS*CSC_CHANNELS_IN_PAR > >();
	    dout = new ALT_AVALON_ST_OUTPUT< sc_uint<IODT_OUTPUT_BPS*CSC_CHANNELS_IN_PAR > >();	

#ifndef LEGACY_FLOW
	    int input_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "cscParams;CSC_INPUT_OUTPUT_DATATYPES;IODT_INPUT_BPS", 8);
	    int output_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "cscParams;CSC_INPUT_OUTPUT_DATATYPES;IODT_OUTPUT_BPS", 8);	    
	    int channels_in_par = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "cscParams;CSC_CHANNELS_IN_PAR", 3);
	    din->setDataWidth(input_bps*channels_in_par);
	    dout->setDataWidth(output_bps*channels_in_par);
		din->setSymbolsPerBeat(channels_in_par);
		dout->setSymbolsPerBeat(channels_in_par);
        din->enableEopSignals();
        dout->enableEopSignals();
        bool runtime_coeffs = (bool)ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "cscParams;CSC_RUNTIME_COEFFICIENTS", 0);
        if(runtime_coeffs){
        	control = new ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
        	control->setUseOwnClock(false);
        }
#else 
	#if CSC_RUNTIME_COEFFICIENTS
        control = new ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
        control->setUseOwnClock(false);
    #endif
#endif
		    
#ifdef SYNTH_MODE
        SC_THREAD(behaviour);
#endif //SYNTH_MODE        
    }
    
    const char* param;
};
