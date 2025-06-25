// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


////////////////////////////////////////////////////////////
// reconfig_master.sv  - sets the mif address based on parameters and seq_pcs_mode, muxes the correct _states to the reconfig controller's AVMM interface
//
//     fileset 5/29/2013
//     version 0.8
//
//     v0.5 5/14/2013 - added support for switching off DFE, CTLE engines before AN and CTLE bypass to allow user dynamic settings without being overwritten
//     v0.6 5/15/2013 - added readback request to DFE and CTLE states.
//     v0.7 5/23/2013 - added DFE Vref override before trigger.
//     v0.8 5/29/2013 - added separate DFE/CTLE disables before AN (disable_ctle_dfe_before_an is now 2 bits)

`timescale 1ps/1ps

module reconfig_master 
   (

    input 	      clk,
    input 	      reset,
	
    output reg 	      av_write,
    output reg 	      av_read,
    output reg [6:0]  av_address, //7 bits?
    output reg [31:0] av_writedata,
    input [31:0]      av_readdata,
    input 	      av_waitrequest,

	//add PIO ports
	
    input [31:0]      logical_channel_number, //logical channel number to be worked on
    input [31:0]      rom_mif_address, // used for seq. tells the reconfig block what address the mif is at
    input [2:0]       tap_to_upd, // for PMA states, selects vod, post, pre taps to update.

    input [1:0]	      disable_ctle_dfe_before_an, 
    input 	      bypass_ctle_reconfig,

    input [2:0]       dfe_vref_low_reg,
    input [2:0]       dfe_vref_high_reg,
    input 	      dfe_ena_vref_reg,
    
	//input 		[31:0]		mif_rom_address,
	
    input [5:0]       main_tap_rc, // setting for VOD tap
    input [4:0]       post_tap_rc, // setting for 1st post tap
    input [3:0]       pre_tap_rc, // setting for pre tap
	

    input 	      PIO_IN_LT_START_RC,
    input 	      PIO_IN_SEQ_START_RC,
    input 	      PIO_IN_RECONFIG_MGMT_BUSY, // ties to the reconfig_busy of the recontroller
    output wire       PIO_OUT_BASER_LL_MIF_DONE,
		
		
    output wire       PIO_OUT_HDSK_RC_BUSY_WR, // write busy output (OR'd of all handshake busy signal)
    output wire       PIO_OUT_HDSK_RC_BUSY_RD, // read busy output (OR'd of all handshake busy signal)


	// following is not currently used as read function is not implemented
    output 	      PIO_OUT_RC_PMA_RD_DONE,
    input 	      PIO_IN_VERIFY_PMA_WRITE,

// following is for DFE and CTLE support
    input [3:0]       ctle_rc,
    input [1:0]       ctle_mode,
    input 	      ctle_start_rc,
 
    input [1:0]       dfe_mode,
    input 	      dfe_start_rc
      

);
	
   wire 				     pma_av_write;
   wire 				     pma_av_read;
   wire [6:0] 				     pma_av_address;
   wire [31:0] 				     pma_av_writedata;
   //	wire 			[31:0] 		pma_av_readdata;
   
   wire 				     seq_av_write;
   wire 				     seq_av_read;
   wire [6:0] 				     seq_av_address;
   wire [31:0] 				     seq_av_writedata;
   //	wire 			[31:0] 		seq_av_readdata;
   
   wire 				     dfe_av_write;
   wire 				     dfe_av_read;
   wire [6:0] 				     dfe_av_address;
   wire [31:0] 				     dfe_av_writedata;
   //	wire 			[31:0] 		dfe_av_readdata;   
   
   wire 				     ctle_av_write;
   wire 				     ctle_av_read;
   wire [6:0] 				     ctle_av_address;
   wire [31:0] 				     ctle_av_writedata;
   //	wire 			[31:0] 		ctle_av_readdata;

   wire 				     SEQ_PIO_OUT_HDSK_RC_BUSY_WR;
   wire 				     SEQ_PIO_OUT_HDSK_RC_BUSY_RD;
   wire 				     PMA_PIO_OUT_HDSK_RC_BUSY_WR;
   wire 				     PMA_PIO_OUT_HDSK_RC_BUSY_RD;
   wire 				     DFE_PIO_OUT_HDSK_RC_BUSY_WR;
   wire 				     DFE_PIO_OUT_HDSK_RC_BUSY_RD;
   wire 				     CTLE_PIO_OUT_HDSK_RC_BUSY_WR;
   wire 				     CTLE_PIO_OUT_HDSK_RC_BUSY_RD;
   
   
   //	wire 							pma_busy, seq_busy;   // not used.

// combining busy signals of each state blocks
   assign PIO_OUT_HDSK_RC_BUSY_WR = SEQ_PIO_OUT_HDSK_RC_BUSY_WR || PMA_PIO_OUT_HDSK_RC_BUSY_WR || CTLE_PIO_OUT_HDSK_RC_BUSY_WR || DFE_PIO_OUT_HDSK_RC_BUSY_WR;
   assign PIO_OUT_HDSK_RC_BUSY_RD = SEQ_PIO_OUT_HDSK_RC_BUSY_RD || PMA_PIO_OUT_HDSK_RC_BUSY_RD || CTLE_PIO_OUT_HDSK_RC_BUSY_RD || DFE_PIO_OUT_HDSK_RC_BUSY_RD;

   //assign pma_busy = PMA_PIO_OUT_HDSK_RC_BUSY_RD || PMA_PIO_OUT_HDSK_RC_BUSY_WR;
   //assign seq_busy = SEQ_PIO_OUT_HDSK_RC_BUSY_RD || SEQ_PIO_OUT_HDSK_RC_BUSY_WR;

// following mux is for the avalon MM interface.  This can be registered to help timing.
   always @ (*)
     if (PMA_PIO_OUT_HDSK_RC_BUSY_WR)         //PMA
       begin
	  av_write      =      pma_av_write;  				//o
	  av_read       =      pma_av_read;				//o
	  av_address    =      pma_av_address;  			//o32
	  av_writedata  =      pma_av_writedata; 			//o23
			
       end
     else if (DFE_PIO_OUT_HDSK_RC_BUSY_WR)    //DFE
       begin
	  av_write      =      dfe_av_write;  				//o
	  av_read       =      dfe_av_read;				//o
	  av_address    =      dfe_av_address;  			//o32
	  av_writedata  =      dfe_av_writedata; 			//o23
			
       end
     else if (CTLE_PIO_OUT_HDSK_RC_BUSY_WR)   //CTLE 
       begin
	  av_write      =      ctle_av_write;  				//o
	  av_read       =      ctle_av_read;				//o
	  av_address    =      ctle_av_address;  			//o32
	  av_writedata  =      ctle_av_writedata; 			//o23
			
       end
     else  // SEQ
       begin
	  av_write      =      seq_av_write;  				//o
	  av_read       =      seq_av_read; 				//o
	  av_address    =      seq_av_address;  			//o32
	  av_writedata  =      seq_av_writedata; 			//o23
       end


mif_states mif_states_inst
   (
    .clk                        (clk),   						//i
    .reset                      (reset),							//i
			   
		//avalon mm interface		
    .av_write                   (seq_av_write),  				//o
    .av_read                    (seq_av_read), 				//o
    .av_address                 (seq_av_address),  			//o32
    .av_writedata               (seq_av_writedata), 			//o23
    .av_readdata                (av_readdata), 				//i32
    .av_waitrequest             (av_waitrequest),				//i

    .logical_channel_number     (logical_channel_number),	//i32
    .mif_rom_address            (rom_mif_address),		//i32

    .disable_ctle_dfe_before_an (disable_ctle_dfe_before_an),
    
    
    .PIO_OUT_BASER_LL_MIF_DONE  (PIO_OUT_BASER_LL_MIF_DONE), //o

    .PIO_OUT_HDSK_RC_BUSY_WR    (SEQ_PIO_OUT_HDSK_RC_BUSY_WR),	//o
    .PIO_OUT_HDSK_RC_BUSY_RD    (SEQ_PIO_OUT_HDSK_RC_BUSY_RD),	//o

    .PIO_IN_SEQ_START_RC        (PIO_IN_SEQ_START_RC),			//i
    .PIO_IN_RECONFIG_MGMT_BUSY  (PIO_IN_RECONFIG_MGMT_BUSY)	//i
    );



pma_states pma_states_inst
   (
    .clk                         (clk),						//i
    .reset                       (reset),					//i
    
    //avalon mm interface
    .av_write                    (pma_av_write),				//o
    .av_read                     (pma_av_read),					//o
    .av_address                  (pma_av_address),				//o32
    .av_writedata                (pma_av_writedata),			//o32
    .av_readdata                 (av_readdata),			//i32
    .av_waitrequest              (av_waitrequest),		//i

			
    // tap values info from phy after arbitration
    .main_tap_rc                 (main_tap_rc),  			//i6	//	VOD
    .post_tap_rc                 (post_tap_rc),			//i5	//	1st post tap
    .pre_tap_rc                  (pre_tap_rc),				//i4	//	1st pre tap
			
    // logical channel number
    .logical_channel_number      (logical_channel_number), //i32 // this is the logical channel number to pass to the reconfig controller indicating what channel to configure

    .tap_to_upd                  (tap_to_upd), 					//i3 // [main, post, pre]		
    // 	
    
    .PIO_OUT_HDSK_RC_BUSY_WR     (PMA_PIO_OUT_HDSK_RC_BUSY_WR),	//o
    .PIO_OUT_HDSK_RC_BUSY_RD     (PMA_PIO_OUT_HDSK_RC_BUSY_RD),	//o
    
    .PIO_IN_LT_START_RC          (PIO_IN_LT_START_RC), 			//i // for LT
    .PIO_IN_RECONFIG_MGMT_BUSY   (PIO_IN_RECONFIG_MGMT_BUSY),	//i


    // for read function
    .PIO_OUT_RC_PMA_RD_DONE      (PIO_OUT_RC_PMA_RD_DONE),	//o		
    .PIO_IN_VERIFY_PMA_WRITE     (PIO_IN_VERIFY_PMA_WRITE)		//i // for LT	
    );


dfe_states dfe_states_inst
   (
    .clk                        (clk),   						//i
    .reset                      (reset),							//i
			   
		//avalon mm interface		
    .av_write                   (dfe_av_write),  				//o
    .av_read                    (dfe_av_read), 				//o
    .av_address                 (dfe_av_address),  			//o32
    .av_writedata               (dfe_av_writedata), 			//o23
    .av_readdata                (av_readdata), 				//i32
    .av_waitrequest             (av_waitrequest),				//i

    .logical_channel_number     (logical_channel_number),	//i32
    .dfe_mode                   (dfe_mode),		

    .PIO_OUT_HDSK_RC_BUSY_WR    (DFE_PIO_OUT_HDSK_RC_BUSY_WR),	//o
    .PIO_OUT_HDSK_RC_BUSY_RD    (DFE_PIO_OUT_HDSK_RC_BUSY_RD),	//o

    .dfe_start_rc               (dfe_start_rc),			//i
    .PIO_IN_RECONFIG_MGMT_BUSY  (PIO_IN_RECONFIG_MGMT_BUSY),	//i
    .PIO_IN_VERIFY_PMA_WRITE    (PIO_IN_VERIFY_PMA_WRITE),      //i

    .dfe_vref_low_reg           (dfe_vref_low_reg),             //i3
    .dfe_vref_high_reg          (dfe_vref_high_reg),            //i3
    .dfe_ena_vref_reg           (dfe_ena_vref_reg)              //i
    );


ctle_states ctle_states_inst
   (
    .clk                        (clk),   						//i
    .reset                      (reset),							//i

    .bypass_ctle_reconfig      (bypass_ctle_reconfig),
		//avalon mm interface		
    .av_write                   (ctle_av_write),  				//o
    .av_read                    (ctle_av_read), 				//o
    .av_address                 (ctle_av_address),  			//o32
    .av_writedata               (ctle_av_writedata), 			//o23
    .av_readdata                (av_readdata), 				//i32
    .av_waitrequest             (av_waitrequest),				//i

    .logical_channel_number     (logical_channel_number),	//i32
    .ctle_mode                  (ctle_mode),		
    .ctle_rc                    (ctle_rc),
    .PIO_OUT_HDSK_RC_BUSY_WR    (CTLE_PIO_OUT_HDSK_RC_BUSY_WR),	//o
    .PIO_OUT_HDSK_RC_BUSY_RD    (CTLE_PIO_OUT_HDSK_RC_BUSY_RD),	//o

    .ctle_start_rc               (ctle_start_rc),			//i
    .PIO_IN_RECONFIG_MGMT_BUSY  (PIO_IN_RECONFIG_MGMT_BUSY),	//i
    .PIO_IN_VERIFY_PMA_WRITE     (PIO_IN_VERIFY_PMA_WRITE)  
    );




   
   
endmodule
