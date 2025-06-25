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


/////////////////////////////////////////////////////////////////////////////////////////
//
//               ctle_states - configures CTLE PHY settings  through the reconfig controller
//
//     fileset 5/29/2013
//     version 0.7
//
//     v0.6 5/15/2013 - changed status register busy check to reconfig controller busy as the status register deasserts the busy bit during readback
//               - added verify write states for simulation
//     v0.7 5/22/2013 - removed 1 time ctle and continuous support. simplified states


import alt_xcvr_reconfig_h::*;
`timescale 1ps/1ps

module ctle_states 
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

    input             bypass_ctle_reconfig,
	
//PIO_OUT signals

    output reg 	      PIO_OUT_HDSK_RC_BUSY_WR,
    output reg 	      PIO_OUT_HDSK_RC_BUSY_RD,


//PIO_IN signals

    input 	      ctle_start_rc,
    input [1:0]       ctle_mode,
    input [3:0]       ctle_rc,
    
    input 	      PIO_IN_RECONFIG_MGMT_BUSY,
    input             PIO_IN_VERIFY_PMA_WRITE


				
	
);

   reg [4:0] 	      state;
   reg   	      from_process;
   
// state alias
   localparam  INITIAL         = 0, 
               MANUAL_CTLE_VAL = 1,
	       CTLE_CONF       = 8,
	       CTLE_DONE       = 14,
               VERIFY          = 15;
   

// for from_process
   localparam MANUAL    = 1'b0,
              OFF_ONETIME = 1'b1;
   

   
// start CTLE
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
       from_process <= 'd0;  // will preset MANUAL due to value
       
    end
  else
    case (state)
      INITIAL:	begin	// initial state	
	 if ((ctle_start_rc  == 1'b1) && (PIO_IN_RECONFIG_MGMT_BUSY == 1'd0 ))  //  if management busy =0 and start sequence is detected, then 
	   begin
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;			// asserting read busy signal
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;			// asserting write busy signal
	      if (bypass_ctle_reconfig)
		begin
		   state<= 14 ;                                    // bypass CTLE reconfig if bypass_ctle_reconfig bit is set
	           $display("Info: Bypassing CTLE reconfig for logical channel %d\n",logical_channel_number);		   
		end
	      
	      else if (ctle_mode == 2'b00) // check for manual equalization mode
		state <= MANUAL_CTLE_VAL;   //configures manual CTLE value
	      else
		begin
		   //		state <= CTLE_CONF;        //configures AEQ
		   state <= 14;   // bypass AEQ configuration
		   $display("Info: Bypassing CTLE reconfig ctle_mode = %h for logical channel %d\n", ctle_mode, logical_channel_number);
		   
		end
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
      end
      MANUAL_CTLE_VAL: begin // set logical channel address to logical_channel_number for PMA
	 av_address <= ADDR_XR_ANALOG_LCH;
	 av_writedata <= logical_channel_number;
	 av_write <= 1'b1;
	 av_read <= 1'b0;						

	 state <= 3;  // skipping state 2
	 $display ("Info: Manual CTLE started with ctle_rc value of %h for logical channel %d\n",ctle_rc,logical_channel_number);
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
      end
 // don't need to write status bits, skipping this state
/* 
     2: begin // CTRL write to ANALOG status    
	 av_address <= ADDR_XR_ANALOG_STATUS;
	 av_writedata <= 32'd0;
	 av_write <= 1'b1;
	 av_read <= 1'b0;

	 state <=3;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	

      end
*/      
      3: begin // Setup Offset to 0x11 (to write the value of the manual CTLE setting first)
	 av_address <= ADDR_XR_ANALOG_OFFSET;
	 av_writedata <= 32'h00000011;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 4;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      4: begin //Set up Data internal register ctle_mode
	 av_address <= ADDR_XR_ANALOG_DATA;
	 av_writedata <= {28'd0,ctle_rc};
	 av_write <= 1'b1;
	 av_read <= 1'b0;									
	 
	 state <= 5;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end					
      
      5: begin //Ctrl write to internal status register to 0x1 to start write of manual CTLE value
	 av_address <= ADDR_XR_ANALOG_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b1;
	 av_read <= 1'b0;

	 
	 state <= 6;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      6: begin //wait for busy to go high for read 
	 av_address <= ADDR_XR_ANALOG_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)   // using reconfig busy instead of status busy register
	   state <= 7;
	 else
	   state<=state;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      7: begin  // wait for status bit to self clear. 
	 av_address <= ADDR_XR_ANALOG_STATUS;
	 av_writedata <= 'd0;				
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 from_process <= MANUAL;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)
           if (PIO_IN_VERIFY_PMA_WRITE)
	     state<=VERIFY;
	   else
//	     state <= CTLE_CONF;  // proceed to 1 time adaptation setting
	 state <= CTLE_DONE;
	 
	 else
	   state <= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
		
      end
 // end write manual mode values
 
// start  ctle conf    
/*      
      CTLE_CONF: begin //set logical channel
	 av_address <= ADDR_XR_ADCE_LCH;
	 av_writedata <= logical_channel_number;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 9;
	 $display("Info: ctle_conf state ctle_mode = %h for logical channel %d\n",ctle_mode,logical_channel_number);
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;

      end										
      9: begin //set ADCE offset to 0x0 for 1 time adaptation setting
	 av_address <= ADDR_XR_ADCE_OFFSET;
	 av_writedata <= 32'd0;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 10;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;

      end      
      10: begin //Set up Data internal for ctle_mode   
	 av_address <= ADDR_XR_ADCE_DATA;
	 av_writedata <= {30'd0,ctle_mode};
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 11;
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end		
*/
      11: begin //Ctrl write to internal reg 0,  to start sequence
	 av_address <= ADDR_XR_ADCE_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b1;
	 av_read <= 1'b0;
	 
	 state <= 12;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
      end
      
      12: begin //wait for busy  
	 av_address <= ADDR_XR_ADCE_STATUS;
	 av_writedata <= 'd0;
	 av_write <= 1'b0;
	 av_read <= 1'b0;
	 
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)  // wait for reconfig controller to assert busy for CTLE
	   state<= 13;
	 else
	   state<= state;
	 
	 
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	

      end
      13: begin  // wait for status bit to self clear. 
	 av_address <= ADDR_XR_ADCE_STATUS;
	 av_writedata <= 32'd1;
	 av_write <= 1'b0;
	 av_read <=1'b0;
	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for reconfig controller to deassert reconfig_mgmt_busy
	   if (PIO_IN_VERIFY_PMA_WRITE)
	     state <= VERIFY;
	   else
	     state <= 14;
	 else
	   state <= state;

	 from_process <= OFF_ONETIME;
	 
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;

      end						
      // CTLE Done ...
        
 
      CTLE_DONE: begin // make sure ctle_start_rc is deasserted from phy before finishing
	 if (ctle_start_rc == 1'b0)
	   begin
	      // hdshk_busy 
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_WR,0);
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0; //f_write_pio_bit(`PIO_OUT_HDSK_RC_BUSY_RD,0);
	      state <= INITIAL;
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

      end // case: 14

      
//////////////////////////////////
// verification states are to verify that the values are written to correctly by reading it out and comparing it\
// comparison is reported by $display for simulation.  There are no synthesizable outputs and the logic should minimize away in synthesis
// If you require HW validation of read, you can put in code to direct the comparison to ports if needed, or the av_readvalue with the expected results
/////////////////////////////////////////////
      
      VERIFY: begin
	 if (from_process == MANUAL)
	   av_address <= ADDR_XR_ANALOG_STATUS;
	 else   // assume from_process == OFF_ONETIME
	   av_address <= ADDR_XR_ADCE_STATUS;
	 
	 av_writedata <= 'd2;   // for read
	 av_write <= 1'b1;
	 av_read <= 1'b0;

	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)      // wait for reconfig busy to go high
	   state <= 16;
	 else
	   state <= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1; 
      end
      16: begin // start readout
	  
	 av_address <= 'd0;
	 av_writedata <= 'd0;  
	 av_write <= 1'b0;
	 av_read <= 1'b0;

	 if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)      // wait for reconfig busy to go low
	   state <= 17;
	 else
	   state <= state;
	 
	 PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	 PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1; 
           	 
      end // case: 16

      17: begin // start read of data
	 if (from_process == MANUAL)
	   av_address <= ADDR_XR_ANALOG_DATA;
	 else   // assume from_process == OFF_ONETIME
	   av_address <= ADDR_XR_ADCE_DATA;
	 
	 av_writedata <= 'd0;  
	 av_write <= 1'b0;
	 av_read <= 1'b1;

	 if (av_waitrequest == 1'b1)
	   state <= 18;                      // read will take 1 clk after waitrequest is high
	 else
	   state <= state;	 
      end // case: 17
      18: begin // get data and compare
	 if (from_process == MANUAL)
	   if (av_readdata == ctle_rc)
	     $display ("Info: VERIFY Manual CTLE ctle_rc value %h matches readdata value %h for logical channel %d\n", ctle_rc, av_readdata,logical_channel_number);
	   else
	     $display ("Error: VERIFY Manual CTLE ctle_rc value %h does not match readdata value %h for logical channel %d\n", ctle_rc, av_readdata,logical_channel_number);
	 else   // assuming from_process == OFF_CTLE
	   if (av_readdata == ctle_mode)
 	     $display ("Info: VERIFY CTLE ctle_mode value %h matches readdata value %h for logical channel %d\n", ctle_mode, av_readdata,logical_channel_number);
	   else
	     $display ("Error: VERIFY CTLE ctle_mode value %h does not match readdata value %h for logical channel %d\n", ctle_mode, av_readdata,logical_channel_number);

	 state<= CTLE_DONE;   // both path should be finished so going to finish state
      end // case: 18
      
	  
	 
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
