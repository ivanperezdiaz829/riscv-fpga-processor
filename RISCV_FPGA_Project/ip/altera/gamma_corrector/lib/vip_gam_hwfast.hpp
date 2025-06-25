//! \file vip_gam_hwfast.hpp
//!
//! \author aharding
//!
//! \brief Synthesisable Gamma Corrector core.

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
  #define GAM_NAME GAM_HW
#endif

#ifndef LEGACY_FLOW
	#undef GAM_NAME
	#define GAM_NAME alt_vip_gam
#endif

//! Perform Gamma Correction on a complete frame.
//!
//! <b>Compile Time Configuration in IP Toolbench</b>
//!
//! These are the same as the IP user parameters defined by the
//! \link ::GAM_SW(sc_uint<GAM_BPS>*,sc_uint<GAM_BPS>*,sc_uint<GAM_BPS>*) software model \endlink.
//! \ingroup HWCores
SC_MODULE(GAM_NAME)
{

#ifndef LEGACY_FLOW
	static const char * get_entity_helper_class(void) { 
		return "ip_toolbench/gamma_corrector.jar?com.altera.vip.entityinterfaces.helpers.GAMEntityHelper"; 
	}
	
	static const char * get_display_name(void) { 
		return "Gamma Corrector"; 
	}
	
	static const char * get_certifications(void) { 
		return "SOPC_BUILDER_READY"; 
	}
	
	static const char * get_description(void) {
		return "The Gamma Corrector allows video streams to be corrected for the non-linear color response of display devices.";
	}
	
	static const char * get_product_ids(void) { 
		return "00B2"; 
	}	
	
	#include "vip_elementclass_info.h"
#else
	static const char * get_entity_helper_class(void) { 
		return "default"; 
	}
#endif //LEGACY_FLOW
	
#ifndef SYNTH_MODE
#define GAM_BPS 20
#define GAM_CHANNELS_IN_PAR 3
#endif
	
 	//! Input port
   	ALT_AVALON_ST_INPUT< sc_uint<GAM_BPS * GAM_CHANNELS_IN_PAR> >  *din ALT_CUSP_DISABLE_NUMBER_SUFFIX;
  	//! Output port
   	ALT_AVALON_ST_OUTPUT< sc_uint<GAM_BPS * GAM_CHANNELS_IN_PAR > > *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;
  	//! The gamma look-up-table	
  	ALT_AVALON_MM_MEM_SLAVE <GAM_BPS, 2 + (1 << GAM_BPS)> *gamma_lut;

#ifdef SYNTH_MODE  	
  	
#define USE_VIP_PACKET_READER 1
#ifdef USE_VIP_PACKET_READER  	
    #define PACKET_BPS GAM_BPS
	#define PACKET_CHANNELS_IN_PAR GAM_CHANNELS_IN_PAR
	#define PACKET_HEADER_TYPE_VAR headerType    
    #define PACKET_JUST_READ_VAR justReadNonImg    
	#include "vip_packet_reader.hpp"
#endif  	
  	
  	
	void behaviour()
	{
		// set GO bit to zero, because start up state of memory mapped slaves is undefined
#ifndef GAMMA_COMPILE_TIME_VALUES   		
		gamma_lut[0].writeUI(0, 0);
#endif
		
		for(;;)
		{
#ifdef USE_VIP_PACKET_READER		
			handleNonImagePackets();
#else
			handle_non_image_packets();
#endif
#ifndef GAMMA_COMPILE_TIME_VALUES			
			do_ctrl();
#endif			
			do_gam();
		}	
	}

#ifndef USE_VIP_PACKET_READER
    sc_uint<GAM_BPS> just_read_non_img;

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
#endif //ndef USE_VIP_PACKET_READER

#ifndef GAMMA_COMPILE_TIME_VALUES		
	void do_ctrl()
	{
		gamma_lut[0].writeUI(1, 0);
		while(!gamma_lut[0].readUI(0))
		{
			gamma_lut[0].waitForChange();
		}
		// Write the running bit, squashing the value of the GO bit which is probably 1 anyway
		gamma_lut[0].writeUI(1, 1);
	}
#endif

    void do_gam()
    {
		sc_uint<GAM_BPS+1> look_up_val;
		sc_uint<GAM_BPS+1> look_up_val1;
		sc_uint<GAM_BPS+1> look_up_val2;

#ifdef GAMMA_COMPILE_TIME_VALUES		
	    const sc_uint<GAM_BPS> gamma_lut2[GAM_2_POW_BPS]={GAMMA_COMPILE_TIME_VALUES};
	    const sc_uint<GAM_BPS> gamma_lut1[GAM_2_POW_BPS]={GAMMA_COMPILE_TIME_VALUES};
	    const sc_uint<GAM_BPS> gamma_lut0[GAM_2_POW_BPS]={GAMMA_COMPILE_TIME_VALUES};
#endif	    
	    
		
#ifdef USE_VIP_PACKET_READER
		dout->write(sc_uint<GAM_BPS>(IMAGE_DATA));
#endif
		
		sc_uint<GAM_BPS * GAM_CHANNELS_IN_PAR> just_read ;
		ALT_REG<GAM_BPS> results_reg[3]; //hard set to 3 on purpose
		sc_uint<GAM_BPS> results[3] BIND(results_reg);
		
		for(;!din->getEndPacket();)
		{
			ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
			ALT_ATTRIB(ALT_MIN_ITER, 32);
			ALT_ATTRIB(ALT_MOD_TARGET, 1);
			ALT_ATTRIB(ALT_SKIDDING, true);
			
			just_read = din->readWithinPacket(false);

#ifndef GAMMA_COMPILE_TIME_VALUES			
			for(int a = 0 ; a < GAM_CHANNELS_IN_PAR ; a++)
			{
				ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
				results[a] = gamma_lut[a].readUI(just_read.range(GAM_BPS*(a+1)-1,GAM_BPS*a) + sc_uint<GAM_BPS+1>(2));				
			}
#else
			results[0] = gamma_lut0[just_read.range(GAM_BPS*(0+1)-1,GAM_BPS*0)];
#if GAM_CHANNELS_IN_PAR > 1			
			results[1] = gamma_lut1[just_read.range(GAM_BPS*(1+1)-1,GAM_BPS*1)];
#if GAM_CHANNELS_IN_PAR > 2			
			results[2] = gamma_lut2[just_read.range(GAM_BPS*(2+1)-1,GAM_BPS*2)];
#endif
#endif			
#endif				

			dout->cWrite((results[2],results[1],results[0]),!din->getEndPacket());
		}
		
		//write last bit of data and eop 
		dout->writeDataAndEop((results[2],results[1],results[0]), true);
		dout->setEndPacket(false);
		
		
		//TODO: Find out why i need this... Cusp compile reasons
		while(!din->getEndPacket())
		{
			din->readWithinPacket(false);	
		}
		
		//pop last read from din
		din->read();
    }
#endif //SYNTH_MODE

	SC_HAS_PROCESS(GAM_NAME);

	GAM_NAME(sc_module_name name_, const char* PARAMETERISATION="<gammaParams><GAM_NAME>MyGammaCorrector</GAM_NAME><GAM_CHANNEL_COUNT>3</GAM_CHANNEL_COUNT><GAM_CHANNELS_ARE_IN_PAR>false</GAM_CHANNELS_ARE_IN_PAR><GAM_BPS>8</GAM_BPS><GAM_COMPILE_TIME>false</GAM_COMPILE_TIME><GAM_LUT></GAM_LUT></gammaParams>") : sc_module(name_), param(PARAMETERISATION)
    {
	 	//! Input port
		din = new ALT_AVALON_ST_INPUT< sc_uint<GAM_BPS * GAM_CHANNELS_IN_PAR > >() ;
	  	//! Output port
	   	dout = new ALT_AVALON_ST_OUTPUT< sc_uint<GAM_BPS * GAM_CHANNELS_IN_PAR> >();
	   	gamma_lut = NULL;
   	
	   	
		#ifndef LEGACY_FLOW
		int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "gammaParams;GAM_BPS", 8);
        int channels = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "gammaParams;GAM_CHANNEL_COUNT", 3);
        bool in_par = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "gammaParams;GAM_CHANNELS_ARE_IN_PAR", 0);
        int channels_in_par = in_par ? channels : 1;
        
		din->setDataWidth(bps * channels_in_par);
		dout->setDataWidth(bps * channels_in_par);
		din->setSymbolsPerBeat(channels_in_par);
		dout->setSymbolsPerBeat(channels_in_par);
        din->enableEopSignals();
        dout->enableEopSignals();
        
	  	//! The gamma look-up-table
        bool using_control_port = !((bool)ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "gammaParams;GAM_COMPILE_TIME", 0));
        if(using_control_port)
        {
		   	gamma_lut = new ALT_AVALON_MM_MEM_SLAVE <GAM_BPS, 2 + (1 << GAM_BPS)> [channels_in_par];
	        
			//this pre assignment and use of depth is on purpose
			//avoids a cusp issue where the return type of a lshift can't be calced.
			int depth = 1;
			depth = 2 + (depth << bps);
		   	for(int a = 0 ; a< channels_in_par ; a++)
		   	{
		   		gamma_lut[a].setUseOwnClock(false);
		   		gamma_lut[a].setDataWidth(bps);
				gamma_lut[a].setDepth(depth);
		   	}
        }   	
		
		#else // LEGACY_MODE
	  	//! The gamma look-up-table
#ifndef GAMMA_COMPILE_TIME_VALUES	   	
	   	gamma_lut = new ALT_AVALON_MM_MEM_SLAVE <GAM_BPS, 2 + (1 << GAM_BPS)> [GAM_CHANNELS_IN_PAR];
	   	for(int a = 0 ; a< GAM_CHANNELS_IN_PAR ; a++)
	   	{
	   		gamma_lut[a].setUseOwnClock(false);
	   	}	
#endif
		#endif
	   	
#ifdef SYNTH_MODE	     
        SC_THREAD(behaviour);
#endif //SYNTH_MODE
    }
    
    const char* param;

};
