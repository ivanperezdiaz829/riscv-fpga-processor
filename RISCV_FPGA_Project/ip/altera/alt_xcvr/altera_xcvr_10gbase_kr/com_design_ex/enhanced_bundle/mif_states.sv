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


///////////////////////////////////////////////////////////////////////
//
//    mif_states.sv - 10GbaseKR PHY PCS reconfiguration (AN) to switch channel configuration.
//
//     fileset 5/29/2013
//     version 0.8
//
//    takes in MIF address and sets up the reconfig controller to reconfigure the channel per MIF @ address given
//
//    v0.5 5/9/2013 - added capability to turn off CTLE and DFE before reconfiguration
//    v0.6 5/21/2013 - removed states associated to turning off CTLE as manual CTLE settings are currently supported.
//                   - added state 2 back (set status register to 0's) to match documentation
//    v0.7 5/23/2013 - added capability to set CTLE manual value to 0 prior to AN.
//    v0.8 5/29/2013 - added separate disable of CTLE and DFE before AN. Prior was a single bit, now 2 bits disabling DFE/CTLE separately)

import alt_xcvr_reconfig_h::*;
`timescale 1ps/1ps

module mif_states (

	input 		  clk,
	input 		  reset,
	
	output reg 	  av_write,
	output reg 	  av_read,
	output reg [6:0]  av_address,
	output reg [31:0] av_writedata,
	input [31:0] 	  av_readdata,
	input 		  av_waitrequest,

	input [31:0] 	  logical_channel_number,
	input [31:0] 	  mif_rom_address,

	input [1:0]	  disable_ctle_dfe_before_an,    // bit [1] disables ctle, bit [0] disables dfe
		   
	
//PIO_OUT signals

	output reg 	  PIO_OUT_BASER_LL_MIF_DONE,

	output reg 	  PIO_OUT_HDSK_RC_BUSY_WR,
	output reg 	  PIO_OUT_HDSK_RC_BUSY_RD,


//PIO_IN signals

	input 		  PIO_IN_SEQ_START_RC,
	input 		  PIO_IN_RECONFIG_MGMT_BUSY


				
	
);

   reg [31:0] 		  state;

   localparam DFE_DISABLE          = 16,
              CTLE_DISABLE         = 22;

   

// start mif
always @ (posedge clk or posedge reset)
	if (reset)
	  begin
	     state <= 'd0;
	     PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0;
	     PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0;
	     av_address <= 'd0;
	     av_writedata <= 'd0;
	     av_write  <= 1'b0;
	     av_read 	<= 1'b0;
	     PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;			
	  end
	else
	  case (state)
	    0:	begin	// initial state	
	       if ((PIO_IN_SEQ_START_RC == 1'b1) && (PIO_IN_RECONFIG_MGMT_BUSY == 1'd0 ))  //  if management busy =0 and start sequence is detected, then 
		 begin
		    PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;			// asserting read busy signal
		    PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;			// asserting write busy signal

		    if (disable_ctle_dfe_before_an[0])                     // check for need to clear DFE and CTLE before starting AN
		      state <= DFE_DISABLE;
		    else if (disable_ctle_dfe_before_an[1])
		      state <= CTLE_DISABLE;
		    else
		      state <= 1;
		 end
	       else
		 begin
		    PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0;
		    PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0;
		    state <= state;
		 end
	       av_address <= 'd0;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;						
	    end
	    1: begin // set logical channel address to logical_channel_number - f_write_reg (`LOCAL_ADDR_XR_MIF_LCH, 32'd0);
	       av_address <= ADDR_XR_MIF_LCH;
	       av_writedata <= logical_channel_number;
	       av_write <= 1'b1;
	       av_read <= 1'b0;	
					
	       state <= 2;  	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;	
	    end
	    
	    2: begin // CTRL write to mif_mode = 00b - f_write_reg (`LOCAL_ADDR_XR_MIF_STATUS, 32'd0); (don't need this state, skipping)
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 32'd0;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 3;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    
	    3: begin // Setup Offset to internal reg 0 - f_write_reg (`LOCAL_ADDR_XR_MIF_OFFSET, 32'd0);
	       av_address <= ADDR_XR_MIF_OFFSET;
	       av_writedata <= 32'd0;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 4;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    
	    4: begin //Set up Data internal reg 0,  to mif_mode = 00b - f_write_reg (`LOCAL_ADDR_XR_MIF_DATA, 32'h8000);
	       av_address <= ADDR_XR_MIF_DATA;
	       av_writedata <= mif_rom_address;
	       av_write <= 1'b1;
	       av_read <= 1'b0;									
	       
	       state <= 5;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end					
	    
	    5: begin //Ctrl write to internal reg 0,  to mif_mode = 00b - f_write_reg(LOCAL_ADDR_XR_MIF_STATUS,32'd1);
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 6;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    
	    6: begin //wait for busy  - f_wait_for_reg(LOCAL_ADDR_XR_MIF_STATUS,32'h0);
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b1;
	       if (av_waitrequest == 1'b1)
		 state <= 7;
	       else
		 state <= state;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    7: begin  // wait for status bit to self clear. 
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 'd0;				
	       av_write <= 1'b0;
	       av_read <= 1'b1;
	       if (av_waitrequest == 1'b0)
		 begin
		    if (av_readdata[8] == 1'b0)
		      state <= 8;
		    else
		      //								 
		      state <= state;  // re-read if av_readdata[8] is not cleared
		    
		 end
	       else
		 state <= state;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;		
	    end
	    
	    // setup and start MIF streamer....
	    
	    8: begin //Set up Offset to internal reg 0 - f_write_reg(LOCAL_ADDR_XR_MIF_OFFSET,32'h1);
	       av_address <= ADDR_XR_MIF_OFFSET;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 9;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end										
	    
	    9: begin //Set up Data internal reg 0 - f_write_reg(LOCAL_ADDR_XR_MIF_DATA,32'h1);
	       av_address <= ADDR_XR_MIF_DATA;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 10;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end		
	    
	    10: begin //Ctrl write to internal reg 0,  to mif_mode = 00b - f_write_reg(LOCAL_ADDR_XR_MIF_STATUS,32'd1);
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 11;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    
	    11: begin //wait for busy  - f_wait_for_reg(LOCAL_ADDR_XR_MIF_STATUS,32'h0);
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)  // wait for reconfig controller to assert busy for mif streaming
		 state<= 12;
	       else
		 state<= state;
	       
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    12: begin  // wait for status bit to self clear. 
	       av_address <= ADDR_XR_MIF_STATUS;
	       av_writedata <= 32'd1;
	       av_write <= 1'b0;
	       av_read <=1'b0;
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for reconfig controller to deassert reconfig_mgmt_busy indicating finished mif streaming
		 state <= 13;
	       else
		 state <= state;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end						
	    // MIF Stream Done ...
	    
	    // set the mif_done done bit  
	    13: begin // set mif done bits - f_write_pio_bit(`PIO_OUT_BASER_LL_MIF_DONE,1);
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b1;
	       state <= 14;
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       av_address <= 'd0;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       
	    end
	    14: begin // clear mif done bit - f_write_pio_bit(`PIO_OUT_BASER_LL_MIF_DONE,0);
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	       state <= 15;
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       av_address <= 'd0;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	    end
	    15: begin // make sure request - f_wait_for_pio_bit(`PIO_IN_SEQ_START_RC,0);
	       if (PIO_IN_SEQ_START_RC == 1'b0)
		 begin
		    // hdshk_busy 
		    PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
		    PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
		    state <= 'd0;
		 end
	       else
		 begin
		    PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
		    PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
		    state <= state;
		 end
	       av_address <= 'd0;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       PIO_OUT_BASER_LL_MIF_DONE <= 1'b0;
	    end
	    
// added to turn off DFE/CTLE before AN
	     	    
	    DFE_DISABLE: begin // start DFE disable - set logical channel address to logical_channel_number
	       av_address <= ADDR_XR_DFE_LCH;
	       av_writedata <= logical_channel_number;
	       av_write <= 1'b1;
	       av_read <= 1'b0;						
	       
	       state <= 17;  
	       $display("INFO: Turning off DFE before AN\n");
	       
	 
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	    end

      
	    17: begin // Setup Offset to 0x0 (for power on and enable the adaptation engine)
	       av_address <= ADDR_XR_DFE_OFFSET;
	       av_writedata <= 32'd0;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 18;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end
	    
	    18: begin // write 0 to data to turn off DFE 
	       av_address <= ADDR_XR_DFE_DATA;
	       av_writedata <= 32'd0;       //turn off DFE
	       av_write <= 1'b1;
	       av_read <= 1'b0;									
	       
	       state <= 19;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end					
	    
	    19: begin //Ctrl write to internal status register to 0x1 to start DFE
	       av_address <= ADDR_XR_DFE_STATUS;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 20;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end
	    
	    20: begin //wait for busy to go high for read 
	       av_address <= ADDR_XR_DFE_STATUS;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b1;
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)
		 state <= 21;
	       else
		 state<=state;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end
	    21: begin  // wait for status bit to self clear. 
	       av_address <= ADDR_XR_DFE_STATUS;
	       av_writedata <= 'd0;				
	       av_write <= 1'b0;
	       av_read <= 1'b1;
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)
		 if (disable_ctle_dfe_before_an[1])
		   state <= CTLE_DISABLE;  // proceed to clear CTLE Manual value
		 else
		   state <= 1;           // return after turning off DFE
	       
	       else								 
		 state <= state;  // re-read if av_readdata[8] is not cleared
		    
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       
	    end
	    

// start  ctle conf    

	// sets CTLE  Manual values to 0.    
	    CTLE_DISABLE: begin //set logical channel
	       av_address <= ADDR_XR_ANALOG_LCH;
	       av_writedata <= logical_channel_number;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 23;
	       $display("INFO: Turning off CTLE before AN\n");
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       
	    end										
	    23: begin //set ADCE offset to 0x0 for 1 time adaptation setting
	       av_address <= ADDR_XR_ANALOG_OFFSET;
	       av_writedata <= 32'h00000011;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 24;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	       
	    end      
	    24: begin //Set up Data to turn off ctle   
	       av_address <= ADDR_XR_ANALOG_DATA;
	       av_writedata <= 32'd0;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 25;
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end		
	    
	    25: begin //Ctrl write to internal reg 0,  to start sequence
	       av_address <= ADDR_XR_ANALOG_STATUS;
	       av_writedata <= 32'd1;
	       av_write <= 1'b1;
	       av_read <= 1'b0;
	       
	       state <= 26;
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	    end
	    
	    26: begin //wait for busy  
	       av_address <= ADDR_XR_ANALOG_STATUS;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)  // wait for reconfig controller to assert busy for CTLE
		 state<= 27;    // return to AN start
	       else
		 state<= state;
	       
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       
	    end
	    27: begin //wait for busy to go low 
	       av_address <= ADDR_XR_ANALOG_STATUS;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       
	       if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for reconfig controller to assert busy for CTLE
		 state<= 1;    // return to AN start
	       else
		 state<= state;
	       
	       
	       
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	       
	    end
	    
   	    default:	begin	// default state, should never be here.	
	       state <= 'd0;
	       av_address <= 'd0;
	       av_writedata <= 'd0;
	       av_write <= 1'b0;
	       av_read <= 1'b0;
	       PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
	       PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
	    end
	    
	  endcase
   
endmodule
