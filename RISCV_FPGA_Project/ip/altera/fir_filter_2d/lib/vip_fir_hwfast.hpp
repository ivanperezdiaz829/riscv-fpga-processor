//! \file   vip_fir_hwsmall.hpp
//!
//! \author nculver
//!
//! \brief  Synthesisable 2D FIR core.
//!         A 2D FIR core that can be parameterised and then synthesised with CusP.
//!         This implementation is designed to be fast, i.e. one clock cycle per pixel.

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
  #define FIR_NAME FIR_HW
#endif

#ifndef LEGACY_FLOW
	#undef FIR_NAME
	#define FIR_NAME alt_vip_fir
#endif

#if FIR_CALCULATION_TYPE==DATA_TYPE_SIGNED
	#define FIR_CALCULATION_SYSC_TYPE sc_int
#else
	#define FIR_CALCULATION_SYSC_TYPE sc_uint
#endif

#if IODT_INPUT_DATA_TYPE==DATA_TYPE_SIGNED
	#define FIR_INPUT_DATA_SYSC_TYPE sc_int
#else
	#define FIR_INPUT_DATA_SYSC_TYPE sc_uint
#endif

#if CPC_COEFFS_TYPE==DATA_TYPE_SIGNED
	#define FIR_COEFFS_SYSC_TYPE sc_int
#else
	#define FIR_COEFFS_SYSC_TYPE sc_uint
#endif

// addition tree array is a list of 4-tuples stored sequentially in a one
// dimensional array (because CusP can't handle 2D arrays yet)
// each tuple is either:
// (FIR_DEL, DEL_FROM (node number), RESERVED, DEL_TO (node number))
// (FIR_ADD, ADD_SRC_1 (node_number), ADD_SRC_2 (node_number), ADD_RESULT (node number))
// (FIR_MUL, MUL_SRC (node number), MUL_COEFF (index in coeffs array), MUL_RESULT (node_number))
// NB. Multiplier will be named by CusP using its destination node number
//     Adder likewise

// generally useful constants
#define FIR_LOG2_WIDTH              LOG2(FIR_WIDTH_IN_SAMPLES)
// handy for accessing the addition tree array
#define FIR_DEL                     1
#define FIR_ADD                     2
#define FIR_MUL                     3
#define FIR_OP_TYPE(X)              fir_tree_desc[X * 4]
#define FIR_ADD_SRC_1(X)            fir_tree_desc[X * 4 + 1]
#define FIR_ADD_SRC_2(X)            fir_tree_desc[X * 4 + 2]
#define FIR_ADD_DEST(X)             fir_tree_desc[X * 4 + 3]
#define FIR_DEL_FROM(X)             fir_tree_desc[X * 4 + 1]
#define FIR_DEL_TO(X)               fir_tree_desc[X * 4 + 3]
#define FIR_MUL_SRC(X)              fir_tree_desc[X * 4 + 1]
#define FIR_MUL_COEFF(X)            fir_tree_desc[X * 4 + 2]
#define FIR_MUL_DEST(X)             fir_tree_desc[X * 4 + 3]
//! Perform a 2D FIR filter on an intensity array.
//!
//! IP user parameters:
//!
//! These are the same as the IP user parameters defined by the
//! \link ::FIR_NAME(sc_uint<FIR_BPS>*, sc_uint<FIR_BPS>*) software model \endlink.
//!
//! \ingroup HWCores
SC_MODULE(FIR_NAME)
{
#ifndef LEGACY_FLOW
	static const char * get_entity_helper_class(void) { 
		return "ip_toolbench/fir_filter_2d.jar?com.altera.vip.entityinterfaces.helpers.FIREntityHelper"; 
	}
	
	static const char * get_display_name(void) { 
		return "FIR Filter 2D"; 
	}
	
	static const char * get_certifications(void) { 
		return "SOPC_BUILDER_READY"; 
	}
	
	static const char * get_description(void) {
		return "The 2D FIR Filter performs 2D convolution of images using matrices of 3x3, 5x5, or 7x7 coefficients.";
	}
	
	static const char * get_product_ids(void) { 
		return "00B3"; 
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
#define CTRL_INTERFACE_WIDTH 32
#define CTRL_INTERFACE_DEPTH 52
#endif
    //! One each of data input and output streams
    // Important, must be sc_unint, regardless of actual data type
     ALT_AVALON_ST_INPUT< sc_uint<IODT_INPUT_BPS > >  *din ALT_CUSP_DISABLE_NUMBER_SUFFIX;
     ALT_AVALON_ST_OUTPUT< sc_uint<IODT_OUTPUT_BPS > >  *dout ALT_CUSP_DISABLE_NUMBER_SUFFIX;
     ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>* control  ALT_CUSP_DISABLE_NUMBER_SUFFIX;	

	
#ifdef SYNTH_MODE

	#define ODTC_FNAME output_type_conversion	
	#include "vip_output_conversion.h"
	
    // LINE BUFFERS (intended to be replaced by video memory compiler-invoking functional unit)
    ALT_REGISTER_FILE<IODT_INPUT_BPS, 2, 1, FIR_WIDTH_IN_SAMPLES> LB_REG_FILE[FIR_KERNEL_HEIGHT - 1];
    FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS> line_buffers[FIR_WIDTH_IN_SAMPLES][FIR_KERNEL_HEIGHT - 1] BIND(LB_REG_FILE);
    ALT_REG<IODT_INPUT_BPS> LB_OUTPUTS_REGS[FIR_KERNEL_HEIGHT - 1];
    FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS> lb_outputs[FIR_KERNEL_HEIGHT - 1] BIND(LB_OUTPUTS_REGS);
    ALT_AU<FIR_LOG2_WIDTH> LB_NEXT_WRITE_AU;
    sc_uint<FIR_LOG2_WIDTH> lb_next_write BIND(LB_NEXT_WRITE_AU);
    ALT_REG<IODT_INPUT_BPS> LB_LAST_CHANCE_REGS[FIR_KERNEL_X_ROFFSET];
    FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS> lb_last_chance[FIR_KERNEL_X_ROFFSET] BIND(LB_LAST_CHANCE_REGS);

    // KERNELS, flattened array, elements are the kernel of input data
    ALT_AU<IODT_INPUT_BPS> KERNELS_AUS[FIR_KERNEL_SIZE];
    FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS> kernels[FIR_KERNEL_SIZE] BIND(KERNELS_AUS);
    
    // FIR_TREE, a bunch of AUs to use in a the FIR addition and multiplication tree
    ALT_AU<FIR_ADDER_WIDTH> FIR_TREE_AUS[FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS + FIR_KERNEL_SIZE];
    FIR_CALCULATION_SYSC_TYPE<FIR_ADDER_WIDTH> fir_tree[FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS + FIR_KERNEL_SIZE] BIND(FIR_TREE_AUS);  
    // there is a wire for every element in the FIR tree
    // when a value in the tree is written to, it's corresponding wire is written to also
    // this allows some flexibility in skipping out the register itself and just writing to the wire
    // to allow a few unnecessary registers to optimise away (significant saving in logic area)
    FIR_CALCULATION_SYSC_TYPE<FIR_ADDER_WIDTH> fir_tree_wires[FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS + FIR_KERNEL_SIZE] BIND(ALT_WIRE);
    // necessary to explicitly instantiate the multipliers or CusP makes ones which are one bit too wide
    ALT_MULT<FIR_MULT_WIDTH> MULTIPLIERS[FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS + FIR_KERNEL_SIZE];
    

    // to avoid reading a pixel more than once, need a register to store it
    ALT_AU<IODT_INPUT_BPS> THIS_JUST_IN_AU;
    FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS> this_just_in BIND(THIS_JUST_IN_AU);

    #define USE_VIP_PACKET_READER 1
    #ifdef USE_VIP_PACKET_READER  	
        #define PACKET_BPS IODT_INPUT_BPS    
    	#define PACKET_CHANNELS_IN_PAR 1    
    	#define PACKET_HEADER_TYPE_VAR headerType    
        #define PACKET_JUST_READ_VAR justReadNonImg  
		#define PACKET_WIDTH_VAR width
    	#include "vip_packet_reader.hpp"
    #endif  
    
    
    // the coefficients need to be written into an array
    // adding 1 as these coeffs could be unsigned, so they will need a sign bit
	ALT_REG<CPC_QUANTISED_INTEGER_COEFF_WIDTH+1> coefficients_reg[FIR_COEFFS_NUMBER];
    FIR_CALCULATION_SYSC_TYPE<CPC_QUANTISED_INTEGER_COEFF_WIDTH+1> coefficients[FIR_COEFFS_NUMBER] BIND(coefficients_reg);   
    
    void reset_ctrl_and_coeffs()
    {
    	#if FIR_CONTROL_PORT
    			// set GO bit to zero, because start up state of memory mapped slaves is undefined
    			control->writeUI(0, 0);
    	#endif	
    	
    	FIR_CALCULATION_SYSC_TYPE<CPC_QUANTISED_INTEGER_COEFF_WIDTH+1> coefficients_init[FIR_COEFFS_NUMBER] = CPC_QUANTISED_INTEGER_COEFFS; 		
    	
    	for(int a =0 ;a<FIR_COEFFS_NUMBER;a++){
    		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
    		coefficients[a]=coefficients_init[a];   	
    	}    				
    }
    
    void read_ctrl()
    {
    	#if FIR_CONTROL_PORT
    	
    	// Write the running bit
    	control->writeUI(CTRL_Status_ADDRESS, 0);
    	
    	// Between each frame read the run-time configurable location parameters
    	// Check the done bit before starting to read
    	while (!control->readUI(CTRL_Go_ADDRESS).bit(0))
    		control->waitForChange();
    	
    	int cnt=0;
    	for(int a = CTRL_COEFF_0_ADDRESS; a<FIR_COEFFS_NUMBER+CTRL_COEFF_0_ADDRESS;a++ ){
    		ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
    		coefficients[cnt++] = FIR_CALCULATION_SYSC_TYPE<CPC_QUANTISED_INTEGER_COEFF_WIDTH+1>(control->readSI(a));    		
    	}			
    	
    	// Write the running bit
    	control->writeUI(CTRL_Status_ADDRESS, 1);
    	
    	#endif		
    }

    
    void init(){
    	// CUSP needs lb_last_chance to be initialised because the dataflow is
        // a bit too complex for it
        int i;
        for (i = 0; i < FIR_KERNEL_X_ROFFSET; i++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_X_ROFFSET);
            ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_X_ROFFSET);
            
            lb_last_chance[i] = FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0);
        }
    }

    void fir()
    {
        // loop counters and such for unrolled loops, these should
        // all optimise away in the hardware implementation
        int i, j, which_lb;
               
        // this array of constants holds the description of the addition tree
        // to use, as specified by the defines
        const int fir_tree_desc[(FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS) * 4] = FIR_TREE;
        
#ifdef USE_VIP_PACKET_READER
		dout->write(sc_uint<IODT_OUTPUT_BPS>(IMAGE_DATA));
#endif
	
	    // need to count pixels read, so we know when to stop blocking on reads
	    
	    bool at_rh_edge;

#if FIR_CHANNELS_IN_SEQ == 1
		sc_uint<14> width_in_samples = width;
#elif FIR_CHANNELS_IN_SEQ >= 2
		sc_uint<14> width_in_samples = width << 1;
	#if FIR_CHANNELS_IN_SEQ == 3		
		width_in_samples+=width;
	#endif
#endif		

		sc_uint<14> width_in_samples_dec = width_in_samples-sc_uint<1>(1);
		sc_uint<14> width_in_samples_dec2 = width_in_samples-sc_uint<2>(2);		
		sc_uint<14> width_neg_x_roffset = width_in_samples - sc_uint<14>(FIR_KERNEL_X_ROFFSET);

        // prebuffering at start of frame
        // start by filling the last FIR_KERNEL_Y_BOFFSET line buffers
        // with the first FIR_KERNEL_Y_BOFFSET lines of image data
        // note that line buffer zero is the last line buffer, it always
        // holds the most recent image data
        // fill the rest of the line buffers with zeros to cope with top
        // edge zeroing
        int prebuffer_pix;
	    int prebuffer_pix2;
        for (int temp = 0; temp < FIR_KERNEL_Y_BOFFSET; temp++)
        {
            prebuffer_pix = 0;
            prebuffer_pix2 = 0;
            for (sc_uint<14> prebuffer_pix_new = sc_uint<14>(0); prebuffer_pix_new < width_in_samples; prebuffer_pix_new++)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 32);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);

                for (int prebuffer_line = FIR_KERNEL_HEIGHT - 2; prebuffer_line >= 0; prebuffer_line--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT - 1);

                	if (prebuffer_line >= FIR_KERNEL_Y_BOFFSET)
                	{
						line_buffers[prebuffer_pix][prebuffer_line] = FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0);
					}
					else if (prebuffer_line > 0)
                    {
                        ALT_NOSEQUENCE(line_buffers[prebuffer_pix2][prebuffer_line] =
                            line_buffers[prebuffer_pix2][prebuffer_line - 1]);
                    }
                    else
                    {
                        line_buffers[prebuffer_pix2][prebuffer_line] = (FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>)din->readWithinPacket(false);
                    }
                }
                prebuffer_pix++;
                prebuffer_pix2++;
            }
        }
        // move KERNEL_X_ROFFSET pixels across the first row, filling the section of kernel  ..*
        // between the output pixel and the right hand edge with data from the line buffers  .@*
        // after this process the stars are valid data (@ indicates output pixel)            ...
        for (int prebuffer_line = FIR_KERNEL_HEIGHT - 2; prebuffer_line >= 0; prebuffer_line--)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT - 1);
            ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT - 1);
            
            for (sc_uint<14> prebuffer_pix_new = sc_uint<14>(0); prebuffer_pix_new < sc_uint<14>(FIR_KERNEL_X_ROFFSET); prebuffer_pix_new++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_X_ROFFSET);
                ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_X_ROFFSET);
                
                // fill kernel from line pix
                kernels[(prebuffer_pix_new + sc_uint<14>(FIR_KERNEL_X_LOFFSET + 1)) * FIR_KERNEL_HEIGHT + (FIR_KERNEL_HEIGHT - 2 - prebuffer_line)] =
                    line_buffers[prebuffer_pix_new][prebuffer_line];
                        
                // replace line pix from previous line or fresh input in case of last line
                if (prebuffer_line != 0)
                {
                    line_buffers[prebuffer_pix_new][prebuffer_line] =
                        line_buffers[prebuffer_pix_new][prebuffer_line - 1];
                }
                else
                {
                    line_buffers[prebuffer_pix_new][prebuffer_line] = (FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>)din->readWithinPacket(false);
                }
            }
        }
        // the loop above filled each row from the line buffer below it and put new data into  ..*
        // those line buffers this loop fills in the rhs of the last row with new data which   .@*
        // has just been put into the last line buffer                                         ..* <-- new
        for (prebuffer_pix = 0; prebuffer_pix < FIR_KERNEL_X_ROFFSET; prebuffer_pix++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_X_ROFFSET);
            ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_X_ROFFSET);
                
            kernels[(prebuffer_pix + FIR_KERNEL_X_LOFFSET + 1) * FIR_KERNEL_HEIGHT + (FIR_KERNEL_HEIGHT - 1)] =
                line_buffers[prebuffer_pix][0];
        }
        // zero the left hand part of the kernel
        // this includes zeroing the column containing the output pixel            00*
        // best way to think of this is that now, as we prepare to enter a line,   0@*
        // the output pixel is located one pixel to the left of the active data    00*
        for (int prebuffer_line = 0; prebuffer_line < FIR_KERNEL_HEIGHT; prebuffer_line++)
        {
            ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
            ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT);
            ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT);
            
            for (prebuffer_pix = 0; prebuffer_pix < FIR_KERNEL_WIDTH; prebuffer_pix++)
            {
                ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_WIDTH);
                ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_WIDTH);
                
                if (prebuffer_pix <= FIR_KERNEL_X_LOFFSET)
                {
                    kernels[prebuffer_pix * FIR_KERNEL_HEIGHT + prebuffer_line] = FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0);
                }
            }
        }

        lb_next_write = FIR_KERNEL_X_ROFFSET;
              
        bool first_row = true;
        sc_uint<3> row_overrun = sc_uint<3>(0);
        // rows loop
        for (; row_overrun <= sc_uint<3>(FIR_KERNEL_Y_BOFFSET);)
        {
            // zero the left side of the kernel so that the tight loop need
            // not worry about any processing for handling of the left edge
            if (!first_row)
            {
                for (int prebuffer_line = 0; prebuffer_line < FIR_KERNEL_HEIGHT; prebuffer_line++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT);
                    
                    for (prebuffer_pix = 0; prebuffer_pix < FIR_KERNEL_WIDTH; prebuffer_pix++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_WIDTH);
                        ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_WIDTH);
                        
                        if (prebuffer_pix <= FIR_KERNEL_X_LOFFSET)
                        {
                            kernels[prebuffer_pix * FIR_KERNEL_HEIGHT + prebuffer_line] = FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0);
                        }
                        else
                        {
                            if (prebuffer_line == 0)
                            {
                                kernels[prebuffer_pix * FIR_KERNEL_HEIGHT + prebuffer_line] =
                                    lb_last_chance[prebuffer_pix - (FIR_KERNEL_X_LOFFSET + 1)];
                            }
                            else
                            {
                                kernels[prebuffer_pix * FIR_KERNEL_HEIGHT + prebuffer_line] =
                                    line_buffers[prebuffer_pix - (FIR_KERNEL_X_LOFFSET + 1)][FIR_KERNEL_HEIGHT - 1 - prebuffer_line];
                            }
                        }
                    }
                }
            }
                
          
            first_row =false;
          
          
          
          
          
          
          
          
          
            // pixels in a row loop
            // tight loop, modulo scheduled, so need a separate variable to use inside
            sc_uint<14> kernel_centre_x;
            sc_int<15> kernel_centre_x_loop2 = sc_int<15>(width_in_samples_dec2);
            for (sc_int<15> kernel_centre_x_loop = sc_int<15>(width_in_samples_dec); kernel_centre_x_loop >= sc_int<15>(0); kernel_centre_x_loop--)
            {
                ALT_ATTRIB(ALT_MOD_SCHED, ALT_MOD_SCHED_ON);
                ALT_ATTRIB(ALT_MIN_ITER, 32);
                ALT_ATTRIB(ALT_MOD_TARGET, 1);                                

                // grab a pixel from the input stream and put it somewhere where it can be shared
                // written across multiple lines otherwise it cusp doesnt schedule it in a way that works.
                bool not_eop =  !din->getEndPacket();
                FIR_INPUT_DATA_SYSC_TYPE <IODT_INPUT_BPS> pre_read;
                pre_read = (FIR_INPUT_DATA_SYSC_TYPE <IODT_INPUT_BPS>)din->readWithinPacket(false);                
                this_just_in = not_eop ? pre_read : FIR_INPUT_DATA_SYSC_TYPE <IODT_INPUT_BPS>(0);                
        
                // LINE BUFFERS (intended to be replaced by video memory compiler-invoking functional unit)
                for (i = 0; i < FIR_KERNEL_HEIGHT - 1; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT - 1);
        
                    // grab the pix which is about to be overwritten from each line buffer
                    ALT_NOSEQUENCE(lb_outputs[i] = line_buffers[lb_next_write][i]);
        
                    // push new pix into line buffers
                    if (i == 0)
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
                for (i = 0; i < FIR_KERNEL_X_ROFFSET; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_X_ROFFSET);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_X_ROFFSET);
                    
                    if (i != FIR_KERNEL_X_ROFFSET - 1)
                    {
                        if (i == 0)
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
                        lb_last_chance[i] = lb_outputs[FIR_KERNEL_HEIGHT - 2];
                    }
                }
                lb_next_write = LB_NEXT_WRITE_AU.addSubSLdUI(lb_next_write,
                                                             sc_uint<FIR_LOG2_WIDTH>(1),
                                                             sc_uint<FIR_LOG2_WIDTH>(0),
                                                             lb_next_write == sc_uint<FIR_LOG2_WIDTH>(width_in_samples_dec),
                                                             0);    			
                at_rh_edge = kernel_centre_x >= width_neg_x_roffset;
                
                // KERNEL
                // new pixels come into the kernel from the right as it moves left-to-right across the image
                // so shuffle all pixels across one place to the left
                for (j = 0; j < FIR_KERNEL_HEIGHT; j++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT);
                    
                    // process the leftmost column first, with an ALT_DELAY
                    // to prevent shifting from happening before new stuff
                    // coming in at the right is ready
                    ALT_DELAY(kernels[j] = kernels[FIR_KERNEL_HEIGHT + j], 3);
                }
                for (j = 0; j < FIR_KERNEL_HEIGHT; j++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT);
        
                    // process all remaining columns without any delay
                    // since they are delayed by the effect of the ALT_DELAY
                    // above, and further delays would be added on top of this
                    for (i = 1; i < FIR_KERNEL_WIDTH - 1; i++)
                    {
                        ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                        ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_WIDTH - 2);
                        ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_WIDTH - 2);
        
                        kernels[i * FIR_KERNEL_HEIGHT + j] = kernels[(i + 1) * FIR_KERNEL_HEIGHT + j];
                    }
                }
                // bottom right of kernel is the pixel just in
                kernels[(FIR_KERNEL_WIDTH - 1) * FIR_KERNEL_HEIGHT + FIR_KERNEL_HEIGHT - 1] = (at_rh_edge) ? FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0) : this_just_in;
                // rest of the right hand edge of the kernel comes from the line buffer outputs
                which_lb = 0;
                for (i = FIR_KERNEL_HEIGHT - 2; i >= 0; i--)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_HEIGHT - 1);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_HEIGHT - 1);
        
                    kernels[(FIR_KERNEL_WIDTH - 1) * FIR_KERNEL_HEIGHT + i] = (at_rh_edge) ? FIR_INPUT_DATA_SYSC_TYPE<IODT_INPUT_BPS>(0) : lb_outputs[which_lb++];
                }
        
                // FIR filter
                // copy kernel values into fir_tree, using wires to avoid u delay
                for (i = 0; i < FIR_KERNEL_SIZE; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_KERNEL_SIZE);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_KERNEL_SIZE);
                    //cast from sc_uint to input data actual type, then resize to AU type, padding with 1 or 0 depending on input data type
                    fir_tree_wires[i] = (FIR_INPUT_DATA_SYSC_TYPE<FIR_ADDER_WIDTH>)kernels[i];
	    		}
                // multiply and add as specified by FIR_TREE
                for (i = 0; i < FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS; i++)
                {
                    ALT_ATTRIB(ALT_UNROLL, ALT_UNROLL_ON);
                    ALT_ATTRIB(ALT_MIN_ITER, FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS);
                    ALT_ATTRIB(ALT_MAX_ITER, FIR_NUM_ADDERS + FIR_NUM_DELAYS + FIR_NUM_MULTS);
        
                    if (FIR_OP_TYPE(i) == FIR_DEL)
                    {
                        // create a simple delay element
                        fir_tree[FIR_DEL_TO(i)] = fir_tree_wires[FIR_DEL_FROM(i)];
                        fir_tree_wires[FIR_DEL_TO(i)] = fir_tree[FIR_DEL_TO(i)];
                    }
                    else if (FIR_OP_TYPE(i) == FIR_ADD)
                    {
                        // add two elements as specified by the addition tree description
                        fir_tree[FIR_ADD_DEST(i)] = fir_tree_wires[FIR_ADD_SRC_1(i)] + fir_tree_wires[FIR_ADD_SRC_2(i)];
                        fir_tree_wires[FIR_ADD_DEST(i)] = fir_tree[FIR_ADD_DEST(i)];
                        
                    }
                    else
                    {
                        assert(FIR_OP_TYPE(i) == FIR_MUL);                                                                                
                        // multiply an element by a coefficient
                        fir_tree_wires[FIR_MUL_DEST(i)] = MULTIPLIERS[FIR_MUL_DEST(i)].mult(fir_tree_wires[FIR_MUL_SRC(i)],coefficients[FIR_MUL_COEFF(i) % FIR_COEFFS_NUMBER]);
                     
                    }
                }
                
                //cusp doesnt like function returns that arent used immediately
				sc_uint<IODT_OUTPUT_BPS> output = sc_uint<IODT_OUTPUT_BPS>(
													MK_FNAME(ODTC_FNAME,output_type_conversion)(sc_int<64>(fir_tree[FIR_RESULT]))
													.range(IODT_OUTPUT_BPS-1,0)
													);

				bool last_sample = ((kernel_centre_x_loop2 < sc_int<15>(0)) && (row_overrun == sc_uint<3>(FIR_KERNEL_Y_BOFFSET)));											
			 	dout->writeDataAndEop(output, last_sample);
			 										
				// need to update kernel_centre_x to match the loop count variable
				//assert(kernel_centre_x == kernel_centre_x_loop);
				kernel_centre_x++;	
				kernel_centre_x_loop2--;						
            } 
			row_overrun += sc_uint<3>(din->getEndPacket());
		}
		
		dout->setEndPacket(false);
		

		while(!din->getEndPacket())
		{
			din->readWithinPacket(false);	
		}	

		
		//pop the last data
		din->readWithinPacket(true);
		
	}
	
	void behaviour(){
		init();
		reset_ctrl_and_coeffs();
		for(;;)
		{
#ifdef USE_VIP_PACKET_READER		
			handleNonImagePackets();
#else
			handle_non_image_packets();
#endif
			read_ctrl();
			fir();	
		}	
	}
#endif // SYNTH_MODE
	
	SC_HAS_PROCESS(FIR_NAME);

	FIR_NAME(sc_module_name name_, const char* PARAMETERISATION="<firParams><FIR_NAME>finite_impulse_response</FIR_NAME><FIR_WIDTH>640</FIR_WIDTH><FIR_CHANNELS_IN_SEQ>3</FIR_CHANNELS_IN_SEQ><FIR_INPUT_OUTPUT_DATATYPES><IODT_INPUT_BPS>8</IODT_INPUT_BPS><IODT_OUTPUT_BPS>8</IODT_OUTPUT_BPS><IODT_INPUT_DATA_TYPE>DATA_TYPE_UNSIGNED</IODT_INPUT_DATA_TYPE><IODT_OUTPUT_DATA_TYPE>DATA_TYPE_UNSIGNED</IODT_OUTPUT_DATA_TYPE><IODT_USE_INPUT_GUARD_BANDS>false</IODT_USE_INPUT_GUARD_BANDS><IODT_INPUT_GUARD_MIN>0</IODT_INPUT_GUARD_MIN><IODT_INPUT_GUARD_MAX>255</IODT_INPUT_GUARD_MAX><IODT_USE_OUTPUT_GUARD_BANDS>false</IODT_USE_OUTPUT_GUARD_BANDS><IODT_OUTPUT_GUARD_MIN>0</IODT_OUTPUT_GUARD_MIN><IODT_OUTPUT_GUARD_MAX>255</IODT_OUTPUT_GUARD_MAX></FIR_INPUT_OUTPUT_DATATYPES><FIR_FILTER_SIZE>3</FIR_FILTER_SIZE><FIR_SYMMETRIC_MODE>true</FIR_SYMMETRIC_MODE><FIR_COEFFS_MODEL>SIMPLE_SMOOTHING</FIR_COEFFS_MODEL><FIR_COEFFS><kRow> <k>-0.25</k><k>-0.25</k><k>-0.25</k> </kRow><kRow> <k>-0.25</k><k>2.0</k><k>-0.25</k> </kRow><kRow> <k>-0.25</k><k>-0.25</k><k>-0.25</k> </kRow></FIR_COEFFS><FIR_COEFFS_PRECISION><CPC_INTEGER_BITS>0</CPC_INTEGER_BITS><CPC_FRACTION_BITS>6</CPC_FRACTION_BITS><CPC_COEFFS_SIGNED>false</CPC_COEFFS_SIGNED></FIR_COEFFS_PRECISION><FIR_OUTPUT_CONVERSION><ODTC_SCALE>0</ODTC_SCALE><ODTC_FIXEDPOINT_TO_INTEGER>FRACTION_BITS_ROUND_HALF_UP</ODTC_FIXEDPOINT_TO_INTEGER><ODTC_CONVERT_SIGNED_TO_UNSIGNED>CONVERT_TO_UNSIGNED_SATURATE</ODTC_CONVERT_SIGNED_TO_UNSIGNED></FIR_OUTPUT_CONVERSION><FIR_CONTROL_PORT>false</FIR_CONTROL_PORT></firParams>") : sc_module(name_), param(PARAMETERISATION)
    {
		din = new ALT_AVALON_ST_INPUT< sc_uint <IODT_INPUT_BPS> >();
		dout = new ALT_AVALON_ST_OUTPUT< sc_uint <IODT_OUTPUT_BPS> >();		

		#ifndef LEGACY_FLOW
		int input_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "firParams;FIR_INPUT_OUTPUT_DATATYPES;IODT_INPUT_BPS", 8);
		int output_bps = ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "firParams;FIR_INPUT_OUTPUT_DATATYPES;IODT_OUTPUT_BPS", 8);
		din->setDataWidth(input_bps);
		dout->setDataWidth(output_bps);
        din->enableEopSignals();
        dout->enableEopSignals();
        bool use_control = (bool)ALT_CUSP_SYNTH::extract_from_xml(PARAMETERISATION, "firParams;FIR_CONTROL_PORT", 0);
        if(use_control)
        {
        	control = new ALT_AVALON_MM_MEM_SLAVE <CTRL_INTERFACE_WIDTH, CTRL_INTERFACE_DEPTH>();
        	control->setUseOwnClock(false);
        }
		#else
			#if FIR_CONTROL_PORT
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
