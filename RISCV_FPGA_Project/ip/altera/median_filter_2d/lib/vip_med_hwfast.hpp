/**
 * \file vip_med_hwfast.hpp
 *
 * \author dnanceki
 *
 * \brief Synthesisable 2D median filter core.
 * A 2D median core that can be parameterised and then synthesised with CusP.
 * This implementation is designed to be fast, i.e. high definition capable.
*/

// causes CusP 6.1 to bind arrays of register files backwards the way CusP 6.0 did
#pragma cusp_config bindFuToInnermost = yes
// Prevents CusP 7.1 from sequencing IO on separate ports i.e. behave as it used to
#pragma cusp_config createSeparateSeqSpaceForEachIOFU = yes

#pragma cusp_config maximumArraySizeForAnalysis = 3500

#ifndef __CUSP__
	#include <alt_cusp.h>
	
#endif // n__CUSP__

//#include <alt_cusp_synth.h>
#include "vip_constants.h"
#include "vip_common.h"

#ifdef DOXYGEN
  #define MED_NAME MED_HW
#endif

#ifndef LEGACY_FLOW
	#undef MED_NAME
	#define MED_NAME alt_vip_med
#endif

/*#define MED_KERNEL_WIDTH 3
#define MED_KERNEL_HEIGHT 3
#define MED_KERNEL_X_LOFFSET 1
#define MED_KERNEL_X_ROFFSET 1
#define MED_KERNEL_Y_TOFFSET 1
#define MED_KERNEL_Y_BOFFSET 1
#define MED_KERNEL_SIZE 9
#define MED_WIDTH_IN_SAMPLES MED_WIDTH_IN_SAMPLES*/

// generally useful constants
#define MED_IMAGE_PIXELS            (MED_WIDTH_IN_SAMPLES * MED_HEIGHT)
#define MED_LOG2_WIDTH              LOG2(MED_WIDTH_IN_SAMPLES)
// handy for accessing the array
#define MED_DEL                     1
#define MED_CMP                     2
#define MED_CMP_OR_DEL(X)   cmp_net_desc[X * 6]
#define MED_CMP_NUM(X)      cmp_net_desc[X * 6 + 1]
#define MED_CMP_SRC_1(X)    cmp_net_desc[X * 6 + 2]
#define MED_CMP_SRC_2(X)    cmp_net_desc[X * 6 + 3]
#define MED_CMP_DEST_LT(X)  cmp_net_desc[X * 6 + 4]
#define MED_CMP_DEST_GE(X)  cmp_net_desc[X * 6 + 5]
#define MED_DEL_FROM(X)     cmp_net_desc[X * 6 + 2]
#define MED_DEL_TO(X)       cmp_net_desc[X * 6 + 4]
//! Perform a Median filter on an intensity array.
//!
//! IP user parameters:
//!
//! These are the same as the IP user parameters defined by the
//! \link ::MED_NAME(sc_uint<MED_BPS>*, sc_uint<MED_BPS>*) software model \endlink.
//!
//! \ingroup HWCores
SC_MODULE(MED_NAME)
{

#ifndef LEGACY_FLOW
	static const char * get_entity_helper_class(void) { 
		return "ip_toolbench/median_filter_2d.jar?com.altera.vip.entityinterfaces.helpers.MEDEntityHelper"; 
	}
	
	static const char * get_display_name(void) { 
		return "Median Filter 2D"; 
	}
	
	static const char * get_certifications(void) { 
		return "SOPC_BUILDER_READY"; 
	}
	
	static const char * get_description(void) {
		return "The 2D Median Filter provides a means to apply 3x3, 5x5 or 7x7 pixel median filters to video images.";
	}

	static const char * get_product_ids(void) { 
		return "00B4"; 
	}	
	
	#include "vip_elementclass_info.h"
#else
	static const char * get_entity_helper_class(void) { 
		return "default"; 
	}
#endif //LEGACY_FLOW
	
#ifndef SYNTH_MODE
#define MED_BPS 20
#endif
    //! One each of data input and output streams
     ALT_AVALON_ST_INPUT< sc_uint<MED_BPS> >    *din ALT_CUSP_DISABLE_NUMBER_SUFFIX;
     ALT_AVALON_ST_OUTPUT< sc_uint<MED_BPS> >  *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;
#ifdef SYNTH_MODE
    // LINE BUFFERS (intended to be replaced by video memory compiler-invoking functional unit)
    ALT_REGISTER_FILE<MED_BPS, 2, 1, MED_WIDTH_IN_SAMPLES> LB_REG_FILE[MED_KERNEL_HEIGHT - 1];
    sc_uint<MED_BPS> line_buffers[MED_WIDTH_IN_SAMPLES][MED_KERNEL_HEIGHT - 1] BIND(LB_REG_FILE);
    ALT_REG<MED_BPS> LB_OUTPUTS_REGS[MED_KERNEL_HEIGHT - 1];
    sc_uint<MED_BPS> lb_outputs[MED_KERNEL_HEIGHT - 1] BIND(LB_OUTPUTS_REGS);
    ALT_AU<MED_LOG2_WIDTH> LB_NEXT_WRITE_AU;
    sc_uint<MED_LOG2_WIDTH> lb_next_write BIND(LB_NEXT_WRITE_AU);
    ALT_REG<MED_BPS> LB_LAST_CHANCE_REGS[MED_KERNEL_X_ROFFSET];
    sc_uint<MED_BPS> lb_last_chance[MED_KERNEL_X_ROFFSET] BIND(LB_LAST_CHANCE_REGS);

    // KERNELS, flattened array, elements 0 to MED_FILTER_SIZE_SQ - 1 are the kernel of input data
    // other elements are nodes from the stages of the sorting network
    ALT_AU<MED_BPS> KERNELS_AUS[MED_NUM_NODES];
    sc_uint<MED_BPS> kernels[MED_NUM_NODES] BIND(KERNELS_AUS);
    
    // COMPARATORS for the comparison network
    ALT_CMP<MED_BPS> COMPARATORS[MED_NUM_COMPARATORS];
    sc_uint<1> cmps[MED_NUM_COMPARATORS] BIND(ALT_WIRE);

    // to avoid reading a pixel more than once, need a register to store it
    ALT_AU<MED_BPS> THIS_JUST_IN_AU;
    sc_uint<MED_BPS> this_just_in BIND(THIS_JUST_IN_AU);

    // Need to keep track of centre of kernel, to know whether or not it's in the image
    // at all and for edge handling
    int kernel_centre_x;
    int kernel_centre_x_loop;
    int prebuffer_pix;
    int prebuffer_pix2;
    int prebuffer_pix_new;
    int prebuffer_line;
    int kernel_centre_y;
    int temp;

    // need to count pixels read, so we know when to stop blocking on reads
    sc_int<32> pixels_read;
    bool read_whole_frame;
    bool at_rh_edge;
    
//#define USE_VIP_PACKET_READER 1
#ifdef USE_VIP_PACKET_READER  	
    #define PACKET_BPS MED_BPS    
	#define PACKET_CHANNELS_IN_PAR 1    
	#define PACKET_HEADER_TYPE_VAR headerType    
    #define PACKET_JUST_READ_VAR justReadNonImg    
	#include "vip_packet_reader.hpp"
#endif  

#ifndef USE_VIP_PACKET_READER
    sc_uint<MED_BPS> just_read_non_img;

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

    void init()
    {
    	int i;
    	
    	// CUSP needs lb_last_chance to be initialised because the dataflow is
        // a bit too complex for it
        for (i = 0; i < MED_KERNEL_X_ROFFSET; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_X_ROFFSET);
            ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_X_ROFFSET);
            
            lb_last_chance[i] = sc_uint<MED_BPS>(0);
        }
    }
    
    void med()
    {
        // loop counters and such for unrolled loops, these should
        // all optimise away in the hardware implementation
        int i, j, which_lb;
        
        // this array of constants holds the description of the comparison network
        // to use, as specified by the defines
        const int cmp_net_desc[(MED_NUM_COMPARATORS + MED_NUM_DELAYS) * 6] = MED_COMPARISON_NETWORK;

#ifdef USE_VIP_PACKET_READER
		dout->write(sc_uint<MED_BPS>(IMAGE_DATA));
#endif

        // prebuffering at start of frame
        // start by filling the last MED_KERNEL_Y_BOFFSET line buffers
        // with the first MED_KERNEL_Y_BOFFSET lines of image data
        // note that line buffer zero is the last line buffer, it always
        // holds the most recent image data
        // fill the rest of the line buffers with zeros to cope with top
        // edge zeroing
        for (temp = 0; temp < MED_KERNEL_Y_BOFFSET; temp++)
        {
            prebuffer_pix = 0;
            prebuffer_pix2 = 0;
            for (prebuffer_pix_new = 0; prebuffer_pix_new < MED_WIDTH_IN_SAMPLES; prebuffer_pix_new++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MED_WIDTH_IN_SAMPLES);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);

                for (prebuffer_line = MED_KERNEL_HEIGHT - 2; prebuffer_line >= 0; prebuffer_line--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT - 1);

                	if (prebuffer_line >= MED_KERNEL_Y_BOFFSET)
                	{
						line_buffers[prebuffer_pix][ALT_EVALUATE(prebuffer_line)] = sc_uint<MED_BPS>(0);
					}
					else if (prebuffer_line > 0)
                    {
                        ALT_NOSEQUENCE(line_buffers[prebuffer_pix2][ALT_EVALUATE(prebuffer_line)] =
                            line_buffers[prebuffer_pix2][ALT_EVALUATE(prebuffer_line - 1)]);
                    }
                    else
                    {
                        line_buffers[prebuffer_pix2][ALT_EVALUATE(prebuffer_line)] = din->readWithinPacket(false);
                    }
                }
                prebuffer_pix++;
                prebuffer_pix2++;
            }
        }
        // move KERNEL_X_ROFFSET pixels across the first row, filling the section of kernel  ..*
        // between the output pixel and the right hand edge with data from the line buffers  .@*
        // after this process the stars are valid data (@ indicates output pixel)            ...
        for (prebuffer_line = MED_KERNEL_HEIGHT - 2; prebuffer_line >= 0; prebuffer_line--)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT - 1);
            ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT - 1);
            
            for (prebuffer_pix_new = 0; prebuffer_pix_new < MED_KERNEL_X_ROFFSET; prebuffer_pix_new++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_X_ROFFSET);
                ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_X_ROFFSET);
                
                // fill kernel from line pix
                kernels[(prebuffer_pix_new + MED_KERNEL_X_LOFFSET + 1) * MED_KERNEL_HEIGHT + (MED_KERNEL_HEIGHT - 2 - prebuffer_line)] =
                    line_buffers[ALT_EVALUATE(prebuffer_pix_new)][prebuffer_line];
                        
                // replace line pix from previous line or fresh input in case of last line
                if (ALT_EVALUATE(prebuffer_line != 0))
                {
                    line_buffers[ALT_EVALUATE(prebuffer_pix_new)][prebuffer_line] = line_buffers[ALT_EVALUATE(prebuffer_pix_new)][prebuffer_line - 1];
                }
                else
                {
                    line_buffers[ALT_EVALUATE(prebuffer_pix_new)][prebuffer_line] = din->readWithinPacket(false);
                }
            }
        }
        // the loop above filled each row from the line buffer below it and put new data into  ..*
        // those line buffers this loop fills in the rhs of the last row with new data which   .@*
        // has just been put into the last line buffer                                         ..* <-- new
        for (prebuffer_pix = 0; prebuffer_pix < MED_KERNEL_X_ROFFSET; prebuffer_pix++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_X_ROFFSET);
            ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_X_ROFFSET);
                
            kernels[(prebuffer_pix + MED_KERNEL_X_LOFFSET + 1) * MED_KERNEL_HEIGHT + (MED_KERNEL_HEIGHT - 1)] =
                line_buffers[ALT_EVALUATE(prebuffer_pix)][0];
        }
        // zero the left hand part of the kernel
        // this includes zeroing the column containing the output pixel            00*
        // best way to think of this is that now, as we prepare to enter a line,   0@*
        // the output pixel is located one pixel to the left of the active data    00*
        for (prebuffer_line = 0; prebuffer_line < MED_KERNEL_HEIGHT; prebuffer_line++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT);
            ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT);
            
            for (prebuffer_pix = 0; prebuffer_pix < MED_KERNEL_WIDTH; prebuffer_pix++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_WIDTH);
                ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_WIDTH);
                
                if (ALT_EVALUATE(prebuffer_pix <= MED_KERNEL_X_LOFFSET))
                {
                    kernels[prebuffer_pix * MED_KERNEL_HEIGHT + prebuffer_line] = sc_uint<MED_BPS>(0);
                }
            }
        }

        lb_next_write = MED_KERNEL_X_ROFFSET;
        pixels_read = MED_KERNEL_Y_BOFFSET * MED_WIDTH_IN_SAMPLES + MED_KERNEL_X_ROFFSET;
        read_whole_frame = false;
        
        // rows loop
        for (kernel_centre_y = 0; kernel_centre_y < MED_HEIGHT; kernel_centre_y++)
        {
            // zero the left side of the kernel so that the tight loop need
            // not worry about any processing for handling of the left edge
            if (kernel_centre_y != 0)
            {
                for (prebuffer_line = 0; prebuffer_line < MED_KERNEL_HEIGHT; prebuffer_line++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT);
                    
                    for (prebuffer_pix = 0; prebuffer_pix < MED_KERNEL_WIDTH; prebuffer_pix++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_WIDTH);
                        ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_WIDTH);
                        
                        if (ALT_EVALUATE(prebuffer_pix <= MED_KERNEL_X_LOFFSET))
                        {
                            kernels[prebuffer_pix * MED_KERNEL_HEIGHT + prebuffer_line] = sc_uint<MED_BPS>(0);
                        }
                        else
                        {
                            if (ALT_EVALUATE(prebuffer_line == 0))
                            {
                                kernels[prebuffer_pix * MED_KERNEL_HEIGHT + prebuffer_line] =
                                    lb_last_chance[prebuffer_pix - (MED_KERNEL_X_LOFFSET + 1)];
                            }
                            else
                            {
                                kernels[prebuffer_pix * MED_KERNEL_HEIGHT + prebuffer_line] =
                                    line_buffers[ALT_EVALUATE(prebuffer_pix - (MED_KERNEL_X_LOFFSET + 1))][MED_KERNEL_HEIGHT - 1 - prebuffer_line];
                            }
                        }
                    }
                }
            }
                
            // pixels in a row loop
            // tight loop, modulo scheduled, so need a separate variable to use inside
            kernel_centre_x = 0;
            for (kernel_centre_x_loop = 0;
                 kernel_centre_x_loop < MED_WIDTH_IN_SAMPLES;
                 kernel_centre_x_loop++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, MED_WIDTH_IN_SAMPLES);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);

                // grab a pixel from the input stream and put it somewhere where it can be shared
                read_whole_frame = pixels_read < sc_int<32>(MED_IMAGE_PIXELS);
                this_just_in = THIS_JUST_IN_AU.muxLdUI(sc_uint<MED_BPS>(0),
                                                       din->readWithinPacket(false),
                                                       ALT_STAGE(read_whole_frame, 1));
                // update pixels_read
                pixels_read++;
        
                // LINE BUFFERS (intended to be replaced by video memory compiler-invoking functional unit)
                for (i = 0; i < MED_KERNEL_HEIGHT - 1; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT - 1);
        
                    // grab the pix which is about to be overwritten from each line buffer
                    ALT_NOSEQUENCE(lb_outputs[i] = line_buffers[lb_next_write][i]);
        
                    // push new pix into line buffers
                    if (ALT_EVALUATE(i == 0))
                    {
                        // first line buffer fed from input stream
                        ALT_NOSEQUENCE(line_buffers[ALT_STAGE(lb_next_write, 3)][i] = this_just_in);
                    }
                    else
                    {
                        // all other line buffers fed from out of previous line buffer
                        ALT_NOSEQUENCE(line_buffers[ALT_STAGE(lb_next_write, 3)][i] = lb_outputs[i - 1]);
                    }
                }
                // grab the pix which is about to be overwritten from the last line buffer
                for (i = 0; i < MED_KERNEL_X_ROFFSET; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_X_ROFFSET);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_X_ROFFSET);
                    
                    if (ALT_EVALUATE(i != MED_KERNEL_X_ROFFSET - 1))
                    {
                        if (ALT_EVALUATE(i == 0))
                        {
                            ALT_DELAY(lb_last_chance[i] = lb_last_chance[i + 1], 3);
                        }
                        else
                        {
                            lb_last_chance[i] = lb_last_chance[i + 1];
                        }
                    }
                    else
                    {
                        lb_last_chance[i] = lb_outputs[MED_KERNEL_HEIGHT - 2];
                    }
                }
                lb_next_write = LB_NEXT_WRITE_AU.addSubSLdUI(lb_next_write,
                                                             sc_uint<MED_LOG2_WIDTH>(1),
                                                             sc_uint<MED_LOG2_WIDTH>(0),
                                                             lb_next_write == sc_uint<MED_LOG2_WIDTH>(MED_WIDTH_IN_SAMPLES - 1),
                                                             0);
    
                at_rh_edge = kernel_centre_x >= MED_WIDTH_IN_SAMPLES - MED_KERNEL_X_ROFFSET;
                
                // KERNEL
                // new pixels come into the kernel from the right as it moves left-to-right across the image
                // so shuffle all pixels across one place to the left
                for (j = 0; j < MED_KERNEL_HEIGHT; j++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT);
                    
                    // process the leftmost column first, with an ALT_DELAY
                    // to prevent shifting from happening before new stuff
                    // coming in at the right is ready
                    ALT_DELAY(kernels[j] = kernels[MED_KERNEL_HEIGHT + j], 3);
                }
                for (j = 0; j < MED_KERNEL_HEIGHT; j++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT);
        
                    // process all remaining columns without any delay
                    // since they are delayed by the effect of the ALT_DELAY
                    // above, and further delays would be added on top of this
                    for (i = 1; i < MED_KERNEL_WIDTH - 1; i++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_WIDTH - 2);
                        ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_WIDTH - 2);
        
                        kernels[i * MED_KERNEL_HEIGHT + j] = kernels[(i + 1) * MED_KERNEL_HEIGHT + j];
                    }
                }
                // bottom right of kernel is the pixel just in
                kernels[(MED_KERNEL_WIDTH - 1) * MED_KERNEL_HEIGHT + MED_KERNEL_HEIGHT - 1] = (at_rh_edge) ? sc_uint<MED_BPS>(0) : this_just_in;
                // rest of the right hand edge of the kernel comes from the line buffer outputs
                which_lb = 0;
                for (i = MED_KERNEL_HEIGHT - 2; i >= 0; i--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_KERNEL_HEIGHT - 1);
        
                    kernels[(MED_KERNEL_WIDTH - 1) * MED_KERNEL_HEIGHT + i] = (at_rh_edge) ? sc_uint<MED_BPS>(0) : lb_outputs[which_lb++];
                }
        
                // MEDIAN FILTER
                // apply sorting array structure as described in defines
                for (i = 0; i < MED_NUM_COMPARATORS + MED_NUM_DELAYS; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, MED_NUM_COMPARATORS + MED_NUM_DELAYS);
                    ALT_ATTRIB(ALT_MAX_ITER, MED_NUM_COMPARATORS + MED_NUM_DELAYS);
        
                    if (ALT_EVALUATE(MED_CMP_OR_DEL(i) == MED_DEL))
                    {
                        // create a simple delay element
                        kernels[MED_DEL_TO(i)] = kernels[MED_DEL_FROM(i)];
                    }
                    else
                    {
                        assert(MED_CMP_OR_DEL(i) == MED_CMP);
                        
                        // use given comparator to compare two elements as specified by the
                        // sorting network description
                        cmps[MED_CMP_NUM(i)] =
                            COMPARATORS[MED_CMP_NUM(i)].ltUI(kernels[MED_CMP_SRC_1(i)],
                                                             kernels[MED_CMP_SRC_2(i)]);
                    
                        // set the first element specified in the sorting network description
                        // to the value of the lesser of the two
                        kernels[MED_CMP_DEST_LT(i)] =
                            KERNELS_AUS[MED_CMP_DEST_LT(i)].muxLdUI(kernels[MED_CMP_SRC_2(i)],
                                                                    kernels[MED_CMP_SRC_1(i)],
                                                                    cmps[MED_CMP_NUM(i)]);
                    
                        // and set the second to the greater
                        kernels[MED_CMP_DEST_GE(i)] =
                            KERNELS_AUS[MED_CMP_DEST_GE(i)].muxLdUI(kernels[MED_CMP_SRC_1(i)],
                                                                    kernels[MED_CMP_SRC_2(i)],
                                                                    cmps[MED_CMP_NUM(i)]);
                    }
                }
                bool last_sample = ((kernel_centre_x_loop == MED_WIDTH_IN_SAMPLES-1) && (kernel_centre_y == MED_HEIGHT-1));											
                dout->writeDataAndEop(kernels[MED_COMPARISON_RESULT],last_sample);
                
                // need to update kernel_centre_x to match the loop count variable
                assert(kernel_centre_x == kernel_centre_x_loop);
                kernel_centre_x++;
            }
        }
        
        dout->setEndPacket(false);
		
		//empty
		if(!din->getEndPacket())//(throw interrupt if !eop here)
		{
			while(!din->getEndPacket())
			{
				din->readWithinPacket(false);	
			}	
		}
		
		din->read();
    }
    
    void behaviour(){
		init();
		for(;;)
		{
#ifdef USE_VIP_PACKET_READER		
			handleNonImagePackets();
#else
			handle_non_image_packets();
#endif
			med();	
		}	
	}

#endif //SYNTH_MODE

	SC_HAS_PROCESS(MED_NAME);

	MED_NAME(sc_module_name name_, const char* PARAMETERISATION="<medParams><MED_NAME>my_mFilter</MED_NAME><MED_WIDTH>640</MED_WIDTH><MED_HEIGHT>480</MED_HEIGHT><MED_FILTER_SIZE>3</MED_FILTER_SIZE><MED_BPS>8</MED_BPS><MED_CHANNELS_IN_SEQ>3</MED_CHANNELS_IN_SEQ></medParams>") : sc_module(name_), param(PARAMETERISATION)
    {
		din = new ALT_AVALON_ST_INPUT< sc_uint <MED_BPS> >();
		dout = new ALT_AVALON_ST_OUTPUT< sc_uint <MED_BPS> >();

#ifndef LEGACY_FLOW
		int bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "medParams;MED_BPS", 8);
		din->setDataWidth(bps);
		dout->setDataWidth(bps);
        din->enableEopSignals();
        dout->enableEopSignals();
#endif
		
#ifdef SYNTH_MODE	 
        SC_THREAD(behaviour);
#endif //SYNTH_MODE
    }
    
    const char* param;
};
