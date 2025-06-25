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


//////////////////////////////////////////////////////////////////////////////////////////////
//     dfe_states.sv  -  setup DFE modes in the PHY through the reconfig controller
//     fileset 5/24/2013
//     version 0.8
//
//    v0.4  5/9/2013 - fixed bug in one-time trigger
//    v0.5  5/14/2013 - one-time trigger switched from using busy bit in status register to reconfig busy from reconfig controller (PIO_IN_RECONFIG_MGMT_BUSY)
//    v0.6  5/15/2013 - added verify of dfe register after write (dfe_mode==2'b1 currently not supported for verification)
//    v0.7  5/23/2013 - added DFE Vref override function - sets vref to dfe_vref_low_reg, triggers dfe, then sets vref to dfe_vref_high_reg, trigger dfe again.
//    v0.8  5/29/2013 - fixed lockup issue in normal mode, optimized states.

// note: for DFE vref override function:
// If enabled, the DFE states, for 1 time trigger (dfe_mode = 2’b01) will…

// Read data from dfe offset 0x6   (state19 "DFE_VREF")
// Modify lower 3 bits of data with vref low val (4) (state25)
// Write modified data back to offset 0x6. (state26)
// Trigger DFE 1 time   (state8)

// Modify data lower 3 bits with vref high val (6)  (state25)
// Write modified data back to offset 0x6      (state26)
// Trigger DFE 1 time   (state8)
// Finish (state 13)


import alt_xcvr_reconfig_h::*;
`timescale 1ps/1ps

module dfe_states 
   (

    input 	      clk,
    input 	      reset,
	
    output reg 	      av_write,
    output reg 	      av_read,
    output reg [6:0]  av_address,
    output reg [31:0] av_writedata,
    input [31:0]      av_readdata,
    input 	      av_waitrequest,

    input [31:0]      logical_channel_number,
	
//PIO_OUT signals

    output reg 	      PIO_OUT_HDSK_RC_BUSY_WR,
    output reg 	      PIO_OUT_HDSK_RC_BUSY_RD,


//PIO_IN signals

    input 	      dfe_start_rc,
    input [1:0]       dfe_mode, // 00=disable, 01=1 time, 10=continuous, 11=reserved
    
    input 	      PIO_IN_RECONFIG_MGMT_BUSY,

    input 	      PIO_IN_VERIFY_PMA_WRITE,

    input [2:0]  dfe_vref_low_reg,
    input [2:0]  dfe_vref_high_reg,
    input        dfe_ena_vref_reg
				
	
);

   reg [31:0] 	      read_mod_write_reg;  // for storing data in reg 0x6. 
   
   
   reg [4:0] 	      state;     // 5 bits 32 states
   reg  	      from_vref_state;   // stores value from state.
   reg 		      done_vref_low;  // indicates that vref low setting was done and to do vref high.

   
    
//   reg 		      vref_done;  // indicate if dfe vref loop is done in this round.
   
                      
   localparam         OFF_CONTINUOUS = 3,
                      ONE_TIME = 8,
                      VERIFY = 14,
                      DFE_VREF = 19;
 
   
   
   
// start dfe
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
       from_vref_state <=1'b0;
       done_vref_low <= 1'b0;
       read_mod_write_reg <= 'd0;

       
       
    end
  else
    case (state)
      0:	begin	// initial state	
	 if ((dfe_start_rc  == 1'b1) && (PIO_IN_RECONFIG_MGMT_BUSY == 1'd0 ))  //  if management busy =0 and start sequence is detected, then 
	   begin
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;			// asserting read busy signal
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;			// asserting write busy signal
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
	 from_vref_state <= 1'b0;
	 
	 done_vref_low <=1'b0;
	 
      end
      1: begin // set logical channel address to logical_channel_number
	 av_address <= ADDR_XR_DFE_LCH;
	 av_writedata <= logical_channel_number;
	 av_write <= 1'b1;
	 av_read <= 1'b0;						

	 if (dfe_ena_vref_reg && (dfe_mode != 'd0))  // run through dfe vref loop one time per DFE request
	   state <= DFE_VREF;
	 else 
	   begin
	      from_vref_state <= 1'b0;  // indicates that calling state is not from VREF state for ONE_TIME	      
	      if (dfe_mode == 2'b01)
		   state<= ONE_TIME;    // for 1 time DFE trigger
	      else
		state <= OFF_CONTINUOUS;   // skipping state2, for turning DFE off or continuous  (dfe_mode 00 for off, 10 for continuous)   
	      if (dfe_mode == 'd0)
		$display("Info: Turning off DFE dfe_mode %h for logical channel %d\n", dfe_mode, logical_channel_number);
	      else   
		$display("INFO: Starting DFE calibration with dfe_mode %h for logical channel %d\n", dfe_mode,logical_channel_number);
	
	 
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	   end
      end 
      
     
      OFF_CONTINUOUS: begin // Setup Offset to 0x0 (for power on and enable the adaptation engine)
	 av_address <= ADDR_XR_DFE_OFFSET;
	 av_writedata <= 32'd0;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 4;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      4: begin // dfe_mode 00=disable write 0x0, 01=1 time write 0x2, 10=continuous write 0x3, 11=reserved; 
	 av_address <= ADDR_XR_DFE_DATA;
	 if (dfe_mode == 2'b00)          
	   av_writedata <= 32'd0;       //turn off DFE
	 else if (dfe_mode == 2'b01)
	   av_writedata <= 32'h00000002; // turn on DFE  (for 1 time trigger)
	 else 
	   av_writedata <= 32'h00000003; // turn on and enable DFE  (for continuous)
	 
	 av_write <= 1'b1;
	 av_read <= 1'b0;									
	 
	 state <= 5;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end					
      
      5: begin //Ctrl write to internal status register to 0x1 to start DFE
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 6;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      6: begin //wait for busy to go high for read 
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b1;
	 if (av_waitrequest == 1'b1)
	   state <= 7;
	 else
	   state<=state;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      7: begin  // wait for status bit to self clear. 
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd0;				
	 av_write <= 1'b0;
	 av_read <= 1'b1;
	 if (av_waitrequest == 1'b0)
	   begin
	      if (av_readdata[8] == 1'b0)
//		if (dfe_mode== 2'b01)  // go to one time setup.
//		  state <= 8;  // proceed to 1 time adaptation setting
//		else // for all other modes.
		  state <= 11;  // if not 1 time, finish and go to done state. (assuming continuous adaptation setting) 
	      
	      else
		//								 
		state <= state;  // re-read if av_readdata[8] is not cleared
	      
	   end
	 else
	   state <= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
		
      end
 // end set logical channel and turn on DFE + adaptation engine
 
// start      
      
      ONE_TIME: begin //set DFE offset to 0xB for 1 time adaptation setting
	 av_address <= ADDR_XR_DFE_OFFSET;
	 av_writedata <= 32'h0000000b;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 9;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;

      end										
      
      9: begin //Set up Data internal for one time adaptation writing 0x1 to enable one time DFE  
	 av_address <= ADDR_XR_DFE_DATA;
	 av_writedata <= 32'd1;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 10;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end		
      
      10: begin //Ctrl write to internal reg 0 to 1 to start, 
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 11;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      11: begin //wait for busy  
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)  // wait for reconfig controller to assert busy for DFE
	   state<= 12;
	 else
	   state<= state;
	 
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	

      end
      12: begin  
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b0;
	 av_read <=1'b0;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for reconfig controller to deassert reconfig_mgmt_busy
	   if (from_vref_state)
	     if (done_vref_low)                  // if done_vref_low, the this would be the 2nd time around.
	       state<=13;                        // done  
	     else
	       begin
		  done_vref_low <= 1'b1;    // flag after 
		  state <= 25;    // go to state 25 to write in vref high value (skip readback)		  
//	          state <= DFE_VREF_DONE;
	       end
           else if (PIO_IN_VERIFY_PMA_WRITE)           	 
        
	     state <= VERIFY;                   // if PIO_IN_VERIFY_PMA_WRITE = 1, verify the mode register
	   else
	     state <= 13;                      // not going through vref, end.
	 else
	   state <= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;

      end						
      // DFE Done ...
        
      13: begin // make sure request is low;
	 if (dfe_start_rc == 1'b0)
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

	 done_vref_low <= 1'b0;      // clear dfe vref state registers
	 from_vref_state <= 1'b0;    // clear dfe vref state registers
	

      end

      VERIFY: begin  // verification of write  (reconfig busy should be low when entering this state, logical channel and offset address should still be valid)
	 
	 av_address <= ADDR_XR_DFE_OFFSET;
	 av_writedata <='d0;    // for check on power on and continuous.

	 av_write <= 1'b1;	 
	 av_read <= 1'b0;
	 
	 state<=15;
 	 
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end
      15: begin
	    
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd2;              // read request to phy register
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)    // wait for reconfig busy before moving on
	   state<= 16;
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end
      16: begin   // wait for busy to go low
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd2;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)    // wait for reconfig busy before moving on
	   state<= 17;
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end	    
      17: begin   //read value from data register
	 av_address <= ADDR_XR_DFE_DATA;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b1;
	 
	 if (av_waitrequest == 1'b1)    // wait for avalon waitrequest is high before moving on
	   state<= 18;
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end	    
      18: begin   //read value from data register
	 av_address <= ADDR_XR_DFE_DATA;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b1;
	 
	 if (av_waitrequest == 1'b0)    // wait for avalon waitrequest is high before moving on
	   begin	      
	      state<= 13;    // go back to finishing state
	      if (((av_readdata == 'd3) && (dfe_mode=='d2)) || (dfe_mode == av_readdata))
		$display("Info: DFE readdata %h is correct for dfe_mode %h for logical channel %d\n", av_readdata,dfe_mode,logical_channel_number);
	      else
		if (dfe_mode == 'd0)
		  $display("Error: DFE readdata %h is NOT correct for dfe_mode %h for logical channel %d\n", av_readdata, dfe_mode,logical_channel_number);
		else
	      	  $display("Info:  DFE dfe_mode 0x01 not supported for verification for logical channel %d\n",logical_channel_number);
	
	   end
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end // case: 18


      DFE_VREF: begin   // start vref sequence	 
	 av_address <= ADDR_XR_DFE_OFFSET;     // set offset to 0x6 for VREF value
	 av_writedata <= 32'h00000006;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 state <= 20;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end

      20: begin  // read value from offset 0x6
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd2;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 state <= 21;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end
      21: begin // wait for busy to go high
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd2;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)
	   state <= 22;
	 else
	   state <= state;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;	 
      end
      22: begin // wait for busy to go low
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)
	   state <= 23;
	 else
	   state <= state;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;	 
      end
      23: begin // initiate read from data for 0x6 register
	 av_address <= ADDR_XR_DFE_DATA;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;

	 state <= 24;

      end // case: 23
      24: begin // capture read
	 av_address <= ADDR_XR_DFE_DATA;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 
	 if (!av_waitrequest)
	   begin
	      read_mod_write_reg <= av_readdata; // should only care about [6:3]    
	      state <= 25;
	   end
	 else
	   state <= state;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end 
      25: begin  // setup offset to 0x6                      // landing point for 2nd loop (write vref high)
	 av_address <= ADDR_XR_DFE_OFFSET;
	 av_writedata <= 32'h00000006;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 state <= 26;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;

	 $display("Info: DFE VREF Override.  done_vref_low = %h, read_mod_write_reg = %h\n", done_vref_low, read_mod_write_reg );
      end   
      26: begin  // setup data for offset 0x6 
	 av_address <= ADDR_XR_DFE_DATA;
	 if (done_vref_low)	       
	   av_writedata <= {read_mod_write_reg[31:3],dfe_vref_high_reg};
	 else
	   av_writedata <= {read_mod_write_reg[31:3],dfe_vref_low_reg};

	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 state <= 27;
		 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end
      27: begin // kick off write
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd1;              // read request to phy register
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)    // wait for reconfig busy before moving on
	   state<= 28;
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
      end	 
      28: begin   // wait for busy to go low   
	 av_address <= ADDR_XR_DFE_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)    // wait for reconfig busy before moving on

	   begin
	      from_vref_state <=1'b1;
	      state<= ONE_TIME;
	   end
	 
	 else
	   state<= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	   end // if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)
   
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
