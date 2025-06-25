/*
 * Imagestream channel rearranger
 */
 
// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#ifndef __CUSP__
	#include <alt_cusp.h>
#endif

//commmon includes
#include "vip_constants.h"
#include "vip_common.h"

#ifndef LEGACY_FLOW
	#undef CPR_NAME
	#define CPR_NAME alt_vip_cpr
#endif


SC_MODULE(CPR_NAME)
{

//in entity interfaces flow we set up the core infomation here
//legacy flow is a flag set always on by AbstractParameterHelper, but filtered out 
//through VIPEntityHelper:makeHashDefines
#ifndef LEGACY_FLOW
	
	//sets up the entity helper, core name should be the same as vip/projects/<core_name>
	static const char * get_entity_helper_class(void) { 
		return "ip_toolbench/color_plane_sequencer.jar?com.altera.vip.entityinterfaces.helpers.CPREntityHelper"; 
	}
	
	static const char * get_display_name(void) { 
		return "Color Plane Sequencer"; 
	}
	
	static const char * get_certifications(void) { 
		return "SOPC_BUILDER_READY"; 
	}
	
	static const char * get_description(void) {
		return "The Color Plane Sequencer rearranges the position/order of the channels in an Avalon-ST Video connection.";
	}
	
	static const char * get_product_ids(void) { 
		return "00C9"; 
	}	
	
	//standard info affecting all cores
	#include "vip_elementclass_info.h"

//in legacy mode we must specify default helper for licensing reasons
#else
	static const char * get_entity_helper_class(void) { 
		return "default"; 
	}
#endif //LEGACY_FLOW

    //Declare ports here
    //! Input ports
       
#ifndef SYNTH_MODE
#define CPR_BPS 20
#define DIN0_CHANNELS_IN_PAR 3
#define DOUT0_CHANNELS_IN_PAR 3
#endif

#ifndef DIN1_CHANNELS_IN_PAR
	#define DIN1_CHANNELS_IN_PAR 3
#endif
#ifndef	DOUT1_CHANNELS_IN_PAR
	#define DOUT1_CHANNELS_IN_PAR 3
#endif
	
    ALT_AVALON_ST_INPUT< sc_uint < CPR_BPS*DIN0_CHANNELS_IN_PAR > >* din0  ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    ALT_AVALON_ST_OUTPUT< sc_uint < CPR_BPS*DOUT0_CHANNELS_IN_PAR > >* dout0  ALT_CUSP_DISABLE_NUMBER_SUFFIX;   
    ALT_AVALON_ST_INPUT< sc_uint < CPR_BPS*DIN1_CHANNELS_IN_PAR > >* din1  ALT_CUSP_DISABLE_NUMBER_SUFFIX;
    ALT_AVALON_ST_OUTPUT< sc_uint < CPR_BPS*DOUT1_CHANNELS_IN_PAR > >* dout1  ALT_CUSP_DISABLE_NUMBER_SUFFIX;
	
//synth mode prevents cusps analysis stage from analysing a file with no #defines set
//it is turned on by parameter helper when it gives hash defines
#ifdef SYNTH_MODE

#if DIN0_CHANNELS_IN_PAR==4 || DIN1_CHANNELS_IN_PAR==4 || DOUT0_CHANNELS_IN_PAR==4 || DOUT1_CHANNELS_IN_PAR==4 
	#define NON_IMG_BUFF_SIZE 12
#else
	#define NON_IMG_BUFF_SIZE 6
#endif
    
    void behaviour()
    {
		for (;;)
        {
			handle_non_image_packets();
			do_cpr();
    	}
	}
      
    static const int RESOLUTION_BITS = HEADER_WORD_BITS * 4;
	static const int WIDTH_HEIGHT_SEQ_BITS = (RESOLUTION_BITS * 2) + 2;
  
    static const int AVSTV_PACKET_BITS = 4;
    static const int AVST_PACKET_PAD = CPR_BPS-AVSTV_PACKET_BITS;
    
    sc_int<16> width;
    //sc_int<16> height;
    
    
    void handle_non_image_packets()
    {
    	
		#ifdef DIN1ENABLED
		sc_uint<HEADER_WORD_BITS> header_type_1;
		sc_uint<CPR_BPS*DIN1_CHANNELS_IN_PAR> just_read_din1;
		ALT_REG<CPR_BPS> din1_non_img_buffer_regs[NON_IMG_BUFF_SIZE]; 
		sc_uint<CPR_BPS> din1_non_img_buffer[NON_IMG_BUFF_SIZE] BIND(din1_non_img_buffer_regs);
		//read and write the header bit
		do{
		    header_type_1 = din1->read(); 
		    
		    //check it was not image data
		    if (header_type_1 != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA))
		    {
		
		    	#ifdef DOUT0_COPY_DIN1_PACKETS
				dout0->write(header_type_1);
				#endif
				
				#ifdef DOUT1ENABLED 
				#ifdef DOUT1_COPY_DIN1_PACKETS
				dout1->write(header_type_1);
				#endif
				#endif
		
		    	//if it wasnt image data then we want to proporgate it to the chosen outputs
				sc_uint<2> ctrl_cnt = sc_uint<2>(0) ;
		    	do 
		    	{
		        	for(int read_cnt=0;read_cnt<NON_IMG_BUFF_SIZE/DIN1_CHANNELS_IN_PAR;read_cnt++)
		        	{
		        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        		
		        		just_read_din1 = din1->readWithinPacket(false);
		        		for(int parallel_read=0;parallel_read<DIN1_CHANNELS_IN_PAR;parallel_read++)
		        		{
		            		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        			din1_non_img_buffer[parallel_read+(DIN1_CHANNELS_IN_PAR*read_cnt)] = sc_uint<CPR_BPS>(just_read_din1.range(CPR_BPS*parallel_read + CPR_BPS-1,CPR_BPS*parallel_read));
		        		}		        		
		        	}
		        	
					#ifdef DOUT0_COPY_DIN1_PACKETS
					#ifdef DOUT0_HALVE_WIDTH
		    		if(header_type_1 == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER) && ctrl_cnt==sc_uint<2>(0))
		    		{
		    			din1_non_img_buffer[3] = (0,din1_non_img_buffer[2].bit(0),din1_non_img_buffer[3].range(AVSTV_PACKET_BITS-1,1));
		    			din1_non_img_buffer[2] = (0,din1_non_img_buffer[1].bit(0),din1_non_img_buffer[2].range(AVSTV_PACKET_BITS-1,1));
		    			din1_non_img_buffer[1] = (0,din1_non_img_buffer[0].bit(0),din1_non_img_buffer[1].range(AVSTV_PACKET_BITS-1,1));
		    			din1_non_img_buffer[0] = (0,din1_non_img_buffer[0].range(AVSTV_PACKET_BITS-1,1));
		    		}
					#endif
					#endif
		        	
					#ifdef DOUT0_COPY_DIN1_PACKETS
				  	for(int write_cnt=0;write_cnt<NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR;write_cnt++)
		        	{
				  		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
				  		if(DOUT0_CHANNELS_IN_PAR==4)
		        		{
		        			dout0->writeDataAndEop((din1_non_img_buffer[3+(4*write_cnt)],din1_non_img_buffer[2+(4*write_cnt)],din1_non_img_buffer[1+(4*write_cnt)],din1_non_img_buffer[0+(4*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
						if(DOUT0_CHANNELS_IN_PAR==3)
		        		{
		        			dout0->writeDataAndEop((din1_non_img_buffer[2+(3*write_cnt)],din1_non_img_buffer[1+(3*write_cnt)],din1_non_img_buffer[0+(3*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT0_CHANNELS_IN_PAR==2)
		        		{
		    				dout0->writeDataAndEop((din1_non_img_buffer[1+(2*write_cnt)],din1_non_img_buffer[0+(2*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT0_CHANNELS_IN_PAR==1)
		        		{
		        			dout0->writeDataAndEop(din1_non_img_buffer[write_cnt], din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}			    
		        	}
					#endif
					#ifdef DOUT1ENABLED
					#ifdef DOUT1_COPY_DIN1_PACKETS					
		        	for(int write_cnt=0;write_cnt<NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR;write_cnt++)
		        	{
		        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
						if(DOUT1_CHANNELS_IN_PAR==4)
		        		{
		        			dout1->writeDataAndEop((din1_non_img_buffer[3+(4*write_cnt)],din1_non_img_buffer[2+(4*write_cnt)],din1_non_img_buffer[1+(4*write_cnt)],din1_non_img_buffer[0+(4*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
						if(DOUT1_CHANNELS_IN_PAR==3)
		        		{
		        			dout1->writeDataAndEop((din1_non_img_buffer[2+(3*write_cnt)],din1_non_img_buffer[1+(3*write_cnt)],din1_non_img_buffer[0+(3*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT1_CHANNELS_IN_PAR==2)
		        		{
		    				dout1->writeDataAndEop((din1_non_img_buffer[1+(2*write_cnt)],din1_non_img_buffer[0+(2*write_cnt)]), din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT1_CHANNELS_IN_PAR==1)
		        		{
		        			dout1->writeDataAndEop(din1_non_img_buffer[write_cnt], din1->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        	}
					#endif
					#endif
		        	ctrl_cnt++;
		    	} while(!din1->getEndPacket());
				#ifdef DOUT1ENABLED
					dout1->setEndPacket(false);
				#endif
		    	dout0->setEndPacket(false);
		    	din1->read();
		    } 
		    
		}while(header_type_1 != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));
	
		#endif //DIN1_ENABLED
    	 	
        sc_uint<HEADER_WORD_BITS> header_type_0;
        sc_uint<CPR_BPS*DIN0_CHANNELS_IN_PAR> just_read_din0;       
        ALT_REG<CPR_BPS> din0_non_img_buffer_regs[NON_IMG_BUFF_SIZE]; 
        sc_uint<CPR_BPS> din0_non_img_buffer[NON_IMG_BUFF_SIZE] BIND(din0_non_img_buffer_regs);       
        
        //read and write the header bit
        do{
	        header_type_0 = din0->read(); 
			 
	        //check it was not image data
	        if (header_type_0 != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA))
	        {
				#ifdef DOUT0_COPY_DIN0_PACKETS
				dout0->write(header_type_0);
				#endif
				
				#ifdef DOUT1ENABLED
					#ifdef DOUT1_COPY_DIN0_PACKETS
				dout1->write(header_type_0);
					#endif
				#endif
				
				sc_uint<2> ctrl_cnt = sc_uint<2>(0) ;

	        	//if it wasnt image data then we want to proporgate it to the chosen outputs
	        	do 
	        	{
		        	for(int read_cnt=0;read_cnt<NON_IMG_BUFF_SIZE/DIN0_CHANNELS_IN_PAR;read_cnt++)
		        	{
		        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        		
		        		just_read_din0 = din0->readWithinPacket(false);
		        		for(int parallel_read=0;parallel_read<DIN0_CHANNELS_IN_PAR;parallel_read++)
		        		{
		            		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        			din0_non_img_buffer[parallel_read+(DIN0_CHANNELS_IN_PAR*read_cnt)] = sc_uint<CPR_BPS>(just_read_din0.range(CPR_BPS*parallel_read + CPR_BPS-1,CPR_BPS*parallel_read));
		        		}
		        	}
		        	
	        		if(header_type_0 == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER) && ctrl_cnt==sc_uint<2>(0))
	        		{
	        			width = ((din0_non_img_buffer[0].range(3,0),din0_non_img_buffer[1].range(3,0),din0_non_img_buffer[2].range(3,0),din0_non_img_buffer[3].range(3,0)));
						#ifdef CPR_INPUT_2_PIXELS	        			
	        				width >>= 1;
						#endif
	        			
						#ifdef DOUT1ENABLED 
						#ifdef DOUT1_COPY_DIN0_PACKETS
						#ifdef DOUT1_HALVE_WIDTH	
		    			din0_non_img_buffer[3] = (0,din0_non_img_buffer[2].bit(0),din0_non_img_buffer[3].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[2] = (0,din0_non_img_buffer[1].bit(0),din0_non_img_buffer[2].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[1] = (0,din0_non_img_buffer[0].bit(0),din0_non_img_buffer[1].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[0] = (0,din0_non_img_buffer[0].range(AVSTV_PACKET_BITS-1,1));
						#endif
						#endif
						#endif
        			}
	        			
		        	
					#ifdef DOUT1ENABLED 
		        	#ifdef DOUT1_COPY_DIN0_PACKETS					
		        	for(int write_cnt=0;write_cnt<NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR;write_cnt++)
		        	{
		        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        		if(DOUT1_CHANNELS_IN_PAR==4)
		        		{
		        			dout1->writeDataAndEop((din0_non_img_buffer[3+(4*write_cnt)],din0_non_img_buffer[2+(4*write_cnt)],din0_non_img_buffer[1+(4*write_cnt)],din0_non_img_buffer[0+(4*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
						if(DOUT1_CHANNELS_IN_PAR==3)
		        		{
		        			dout1->writeDataAndEop((din0_non_img_buffer[2+(3*write_cnt)],din0_non_img_buffer[1+(3*write_cnt)],din0_non_img_buffer[0+(3*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT1_CHANNELS_IN_PAR==2)
		        		{
	        				dout1->writeDataAndEop((din0_non_img_buffer[1+(2*write_cnt)],din0_non_img_buffer[0+(2*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT1_CHANNELS_IN_PAR==1)
		        		{
		        			dout1->writeDataAndEop(din0_non_img_buffer[write_cnt], din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT1_CHANNELS_IN_PAR)-1);
		        		}
		        	}
					#endif //DOUT1ENABLED 
					#endif //DOUT1_COPY_DIN0_PACKETS
		        	
					#ifdef DOUT0_COPY_DIN0_PACKETS
					#ifdef DOUT0_HALVE_WIDTH
					#ifndef DOUT1_HALVE_WIDTH
					if(header_type_0 == sc_uint<HEADER_WORD_BITS>(CONTROL_HEADER) && ctrl_cnt==sc_uint<2>(0))
					{
		    			din0_non_img_buffer[3] = (0,din0_non_img_buffer[2].bit(0),din0_non_img_buffer[3].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[2] = (0,din0_non_img_buffer[1].bit(0),din0_non_img_buffer[2].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[1] = (0,din0_non_img_buffer[0].bit(0),din0_non_img_buffer[1].range(AVSTV_PACKET_BITS-1,1));
		    			din0_non_img_buffer[0] = (0,din0_non_img_buffer[0].range(AVSTV_PACKET_BITS-1,1));
					}
					#endif
					#endif
		        	
		        	for(int write_cnt=0;write_cnt<NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR;write_cnt++)
		        	{
		        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
		        		if(DOUT0_CHANNELS_IN_PAR==4)
		        		{
		        			dout0->writeDataAndEop((din0_non_img_buffer[3+(4*write_cnt)],din0_non_img_buffer[2+(4*write_cnt)],din0_non_img_buffer[1+(4*write_cnt)],din0_non_img_buffer[0+(4*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
						if(DOUT0_CHANNELS_IN_PAR==3)
		        		{
		        			dout0->writeDataAndEop((din0_non_img_buffer[2+(3*write_cnt)],din0_non_img_buffer[1+(3*write_cnt)],din0_non_img_buffer[0+(3*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT0_CHANNELS_IN_PAR==2)
		        		{
	        				dout0->writeDataAndEop((din0_non_img_buffer[1+(2*write_cnt)],din0_non_img_buffer[0+(2*write_cnt)]), din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
		        		if(DOUT0_CHANNELS_IN_PAR==1)
		        		{
		        			dout0->writeDataAndEop(din0_non_img_buffer[write_cnt], din0->getEndPacket() && write_cnt == (NON_IMG_BUFF_SIZE/DOUT0_CHANNELS_IN_PAR)-1);
		        		}
		        	}
					#endif //DOUT0_COPY_DIN0_PACKETS
					
		        	ctrl_cnt++;
	        	} while(!din0->getEndPacket());
	        	
				#ifdef DOUT1ENABLED
	        		dout1->setEndPacket(false);
				#endif
	        	
	        	dout0->setEndPacket(false);
	        	din0->read();
	        } 
        }while(header_type_0 != sc_uint<HEADER_WORD_BITS>(IMAGE_DATA));
    }
    
    void do_cpr()
    {
    	ALT_REG<CPR_BPS> plane_regs[PLANES]; 
    	sc_uint<CPR_BPS> planes[PLANES] BIND(plane_regs);
    	    
    	int init_array;
    	for(init_array=0;init_array<PLANES;init_array++){
    		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
    		ALT_ATTRIB(ALT_MIN_ITER, PLANES);
    		ALT_ATTRIB(ALT_MAX_ITER, PLANES);
    		planes[init_array]=sc_uint<CPR_BPS>(0);
    	}

        
        sc_uint<CPR_BPS*DIN0_CHANNELS_IN_PAR> din0_justread;
        
        #ifdef DIN1ENABLED
        sc_uint<CPR_BPS*DIN1_CHANNELS_IN_PAR> din1_justread;
        int din1_read_par;
        int din1_read_seq;
		#endif        
          
        int din0_read_seq; 
       	int din0_read_par;
       	
		#ifdef DOUT1ENABLED
       		dout1->write(sc_uint<AVSTV_PACKET_BITS>(IMAGE_DATA));
		#endif
       		dout0->write(sc_uint<AVSTV_PACKET_BITS>(IMAGE_DATA));
       	        
       	sc_int<16> x_cnt_orig=width;    	
       	sc_int<16> x_cnt;
       	x_cnt_orig--;

       	
       	for(;!din0->getEndPacket();)
       	{
	       	for(x_cnt = x_cnt_orig ;x_cnt>=sc_int<16>(0);x_cnt--)        	
	        {
	            ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
	            ALT_ATTRIB(ALT_MIN_ITER, 32);
	            ALT_ATTRIB(ALT_MOD_TARGET, MAX_CHANNELS_IN_SEQ);                     	        
	        	/*
	        	 * Din0 reading loops, din's need turning into arrays then sticking in a bigger loop. Example mixer.
	        	 */
	        	for (din0_read_seq = 0; din0_read_seq < DIN0_CHANNELS_IN_SEQ; din0_read_seq++)
	        	{
	        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
	            	ALT_ATTRIB(ALT_MIN_ITER, DIN0_CHANNELS_IN_SEQ);
	            	ALT_ATTRIB(ALT_MAX_ITER, DIN0_CHANNELS_IN_SEQ);
	            	
	            	din0_justread = (sc_uint<CPR_BPS*DIN0_CHANNELS_IN_PAR>)din0->readWithinPacket(false);
	            	
	              	for (din0_read_par = 0; din0_read_par < DIN0_CHANNELS_IN_PAR; din0_read_par++)
	        		{
	            		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
	            		ALT_ATTRIB(ALT_MIN_ITER, DIN0_CHANNELS_IN_PAR);
	            		ALT_ATTRIB(ALT_MAX_ITER, DIN0_CHANNELS_IN_PAR);
	            		planes[(din0_read_seq * DIN0_CHANNELS_IN_PAR)+din0_read_par] = din0_justread.range((din0_read_par*CPR_BPS)+(CPR_BPS-1),din0_read_par*CPR_BPS);
	        		}
	        	}
	
	        	//see comment above, to be stuck in a bigger loop as an array of dins
	        	#ifdef DIN1ENABLED
	            for (din1_read_seq = 0; din1_read_seq < DIN1_CHANNELS_IN_SEQ; din1_read_seq++)
	        	{
	        		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
	            	ALT_ATTRIB(ALT_MIN_ITER, DIN1_CHANNELS_IN_SEQ);
	            	ALT_ATTRIB(ALT_MAX_ITER, DIN1_CHANNELS_IN_SEQ);
	            	
	            	din1_justread = (sc_uint<CPR_BPS*DIN1_CHANNELS_IN_PAR>)din1->readWithinPacket(false);
	            	
	              	for (din1_read_par = 0; din1_read_par < DIN1_CHANNELS_IN_PAR; din1_read_par++)
	        		{
	            		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
	            		ALT_ATTRIB(ALT_MIN_ITER, DIN1_CHANNELS_IN_PAR);
	            		ALT_ATTRIB(ALT_MAX_ITER, DIN1_CHANNELS_IN_PAR);
	            		planes[ (DIN0_CHANNELS_IN_SEQ*DIN0_CHANNELS_IN_PAR) + (din1_read_seq * DIN1_CHANNELS_IN_PAR)+din1_read_par] = din1_justread.range((din1_read_par*CPR_BPS)+(CPR_BPS-1),din1_read_par*CPR_BPS);
	        		}
	        	}
	        	#endif
	        	
	        	//this is "sub-optimal" use of defines need to investigate cusp support of variables as array indexes and get this loopified.
	            DOUT0_SEQUENCE_CONDITIONAL
	      		
	      		#ifdef DOUT1ENABLED
	            DOUT1_SEQUENCE_CONDITIONAL
				#endif
	        }
       	}
       	
        DOUT0_SEQUENCE_EOP
        dout0->setEndPacket(false);
  		
  		#ifdef DOUT1ENABLED
        DOUT1_SEQUENCE_EOP
        dout1->setEndPacket(false);
		#endif
        
		
        #ifdef DIN1ENABLED
        while(!din1->getEndPacket())
		{
        	din1->readWithinPacket(false);   
		}	
		#endif		
        
		//pop last read from din
		din0->read();
		#ifdef DIN1ENABLED
		din1->read();
		#endif
    }
    


#endif //SYNTH_MODE

	//constructor
    const char* param;
	SC_HAS_PROCESS(CPR_NAME);
	CPR_NAME(sc_module_name name_, int din0_symbols_per_beat = 3 , int din1_symbols_per_beat = 3 , int dout0_symbols_per_beat = 1 , int dout1_symbols_per_beat = 3, int din1_enabled = 0 , int dout1_enabled = 0  , const char* PARAMETERISATION="<colourPatternRearrangerParams><CPR_NAME>Color Plane Sequencer</CPR_NAME><CPR_BPS>8</CPR_BPS><CPR_PORTS><INPUT_PORT><NAME>din0</NAME><STREAMING_DESCRIPTOR>[Y:Cb:Cr]</STREAMING_DESCRIPTOR><ENABLED>true</ENABLED></INPUT_PORT><INPUT_PORT><NAME>din1</NAME><STREAMING_DESCRIPTOR>[Channel]</STREAMING_DESCRIPTOR><ENABLED>false</ENABLED></INPUT_PORT><OUTPUT_PORT><NAME>dout0</NAME><STREAMING_DESCRIPTOR>[Y,Cb,Cr]</STREAMING_DESCRIPTOR><ENABLED>true</ENABLED><NON_IMAGE_PACKET_SOURCE>din0</NON_IMAGE_PACKET_SOURCE><HALVE_WIDTH>false</HALVE_WIDTH></OUTPUT_PORT><OUTPUT_PORT><NAME>dout1</NAME><STREAMING_DESCRIPTOR>[Channel]</STREAMING_DESCRIPTOR><ENABLED>false</ENABLED><NON_IMAGE_PACKET_SOURCE>din0</NON_IMAGE_PACKET_SOURCE><HALVE_WIDTH>false</HALVE_WIDTH></OUTPUT_PORT></CPR_PORTS><CPR_INPUT_2_PIXELS>false</CPR_INPUT_2_PIXELS></colourPatternRearrangerParams>") : sc_module(name_), param(PARAMETERISATION)
    {
		din0 = new ALT_AVALON_ST_INPUT< sc_uint < CPR_BPS*DIN0_CHANNELS_IN_PAR > >();
		dout0 = new ALT_AVALON_ST_OUTPUT< sc_uint < CPR_BPS*DOUT0_CHANNELS_IN_PAR > >();    
		din1 = NULL;
		dout1 = NULL;
		
#ifdef LEGACY_FLOW
#ifdef DIN1ENABLED 
		din1 = new ALT_AVALON_ST_INPUT< sc_uint < CPR_BPS*DIN1_CHANNELS_IN_PAR > >();
#endif
#ifdef DOUT1ENABLED 
		dout1 = new ALT_AVALON_ST_OUTPUT< sc_uint < CPR_BPS*DOUT1_CHANNELS_IN_PAR > >();
#endif

#else //nLEGACY_FLOW
		int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "colourPatternRearrangerParams;CPR_BPS", 8);
		if(din1_enabled)
		{
			din1 = new ALT_AVALON_ST_INPUT< sc_uint < CPR_BPS*DIN1_CHANNELS_IN_PAR > >();
			din1->setDataWidth(bps*din1_symbols_per_beat);
			din1->setSymbolsPerBeat(din1_symbols_per_beat);
	        din1->enableEopSignals();
		}		
		if(dout1_enabled)
		{
			dout1 = new ALT_AVALON_ST_OUTPUT< sc_uint < CPR_BPS*DOUT1_CHANNELS_IN_PAR > >();
			dout1->setDataWidth(bps*dout1_symbols_per_beat);
			dout1->setSymbolsPerBeat(dout1_symbols_per_beat);
	        dout1->enableEopSignals();
		}	
		din0->setDataWidth(bps*din0_symbols_per_beat);
		din0->setSymbolsPerBeat(din0_symbols_per_beat);
		dout0->setDataWidth(bps*dout0_symbols_per_beat);
		dout0->setSymbolsPerBeat(dout0_symbols_per_beat);
        din0->enableEopSignals();
        dout0->enableEopSignals();
#endif //LEGACY_MODE
		
#ifdef SYNTH_MODE
        SC_THREAD(behaviour);
#endif //SYNTH_MODE
    }
};
