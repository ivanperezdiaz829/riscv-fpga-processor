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
//  pma_states.sv - handles VOD, pre-emphasis pre and post tap updates from the phy through settings to the reconfig controller.
//                  Also remaps the pre-tap values
//
//     fileset 5/29/2013
//     version 0.6
//
//     v0.5 - Initial version
//     v0.6 7/15/2013 - cleaned up avalon write node to have it go low after write (initially had write stay high after writing the status but until reconfig busy went high). No issues with either way as the reconfig controller only looks at the first write and subsequent writes do not cause any issues).
//     v0.7 8/1/2013 - cleaned up state definition in verify section
//
`timescale 1ps/1ps


   import alt_xcvr_reconfig_h::*;


module pma_states 
  (

   input 	     clk,
   input 	     reset,
	
   output reg 	     av_write,
   output reg 	     av_read,
   output reg [31:0] av_address,
   output reg [31:0] av_writedata,
   input [31:0]      av_readdata,
   input 	     av_waitrequest,

   // tap values info from phy after arbitration
   input [5:0] 	     main_tap_rc, //	VOD
   input [4:0] 	     post_tap_rc, //	1st post tap
   input [3:0] 	     pre_tap_rc, //	1st pre tap
	
   // logical channel number
   input [31:0]      logical_channel_number, // this is the logical channel number to pass to the reconfig controller indicating what channel to configure
	
   //PIO_OUT signals
   output wire 	     PIO_OUT_RC_PMA_RD_DONE, // unused for now, driving to 0.
   output reg 	     PIO_OUT_HDSK_RC_BUSY_WR,
   output reg 	     PIO_OUT_HDSK_RC_BUSY_RD,

   //PIO_IN signals
   input 	     PIO_IN_LT_START_RC, // for LT
   input 	     PIO_IN_RECONFIG_MGMT_BUSY,


   input [2:0] 	     tap_to_upd, // [main, post, pre]
	
   input 	     PIO_IN_VERIFY_PMA_WRITE	// for LT
				
	
);

   localparam [4:0]    VOD_STATE   = 'd1,
                        POST_STATE  = 'd7,
                        PRE_STATE   = 'd13,
                        VERIFY_STATE   = 'd19;
   

   reg        [4:0]    state, from_state;

   wire tap_to_update_main_tap;
   wire tap_to_update_post_tap;
   wire tap_to_update_pre_tap;

   assign tap_to_update_main_tap = tap_to_upd[2];  // VOD
   assign tap_to_update_post_tap = tap_to_upd[1];	// Pre-emphasis Post tap
   assign tap_to_update_pre_tap = tap_to_upd[0];	// pre-emphasis Pre tap

   assign PIO_OUT_RC_PMA_RD_DONE = 1'b0;

// PMA 
   always @ (posedge clk or posedge reset)
      if (reset)
         begin
            state <= 'd0;
            from_state <='d0;
            PIO_OUT_HDSK_RC_BUSY_RD <= 1'b0;
            PIO_OUT_HDSK_RC_BUSY_WR <= 1'b0;
            av_address <= 'd0;
            av_writedata <= 'd0;
            av_write  <= 1'b0;
            av_read 	<= 1'b0;
         end
      else
         case (state)
            0:	begin	// initial state	
	       if ((PIO_IN_LT_START_RC == 1'b1) && (PIO_IN_RECONFIG_MGMT_BUSY == 1'd0 ))  //  if management busy =0 and start sequence is detected, then 
		 begin
		    PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;			// asserting read busy signal
		    PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;			// asserting write busy signal
		    if (tap_to_update_main_tap)			   // preserve check ordering VOD (Main), then POST tap, then PRE tap			      
		      state <= VOD_STATE; 
		    else if (tap_to_update_post_tap)
		      state <= POST_STATE;
		    else if (tap_to_update_pre_tap)
		      state <= PRE_STATE;
		    else
		      state <= state;
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
//vod 1
	   VOD_STATE: begin // set logical channel address to logical_channel_number - f_write_reg(ADDR_XR_ANALOG_LCH, 0); 
	      av_address <= ADDR_XR_ANALOG_LCH;
	      av_writedata <= logical_channel_number;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 2;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   2: begin //f_write_reg(ADDR_XR_ANALOG_OFFSET, 0); // Write offset for VOD (which is 0 as offset for vod is 0) at logical_ch_register = address 3
	      av_address <= ADDR_XR_ANALOG_OFFSET;
	      av_writedata <= 32'd0;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 3;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end 
	   
	   3: begin // f_write_result_to_reg(ADDR_XR_ANALOG_DATA);  // write data 
	      av_address <= ADDR_XR_ANALOG_DATA;
	      av_writedata <= {26'd0,main_tap_rc};
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      
	      state <= 4;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   4: begin //f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd1;
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      
	      state <= 5;

	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   5: begin // wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd1;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)	// wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
		state <= 6;
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	   end	   
	   6: begin  // wait for PIO_IN_RECONFIG_MGMT_BUSY to go low
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for PIO_IN_RECONFIG_MGMT_BUSY to go low, signifying writing to PHY complete
		if (PIO_IN_VERIFY_PMA_WRITE)
		  begin
		     from_state<= VOD_STATE;
		     state<= VERIFY_STATE;
		  end   
	      
		else if (tap_to_update_post_tap)			// check to see if there is pending post tap update request
		  state <= POST_STATE; 		
		else if (tap_to_update_pre_tap)	// check to see if there is pending pre tap update request
		  state <= PRE_STATE;
		else					
		  state <= 0;				// return to initial state to check for other PMA setting actions.
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
// post 7
	   POST_STATE: begin // set logical channel address to 0 - f_write_reg(ADDR_XR_ANALOG_LCH, 0); 
	      av_address <= ADDR_XR_ANALOG_LCH;
	      av_writedata <= logical_channel_number;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 8;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   8: begin //f_write_reg(ADDR_XR_ANALOG_OFFSET, 2); // Write offset for Post (which is 2 as offset for post tap is 2) at logical_ch_register = address 3
	      av_address <= ADDR_XR_ANALOG_OFFSET;
	      av_writedata <= 32'd2;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 9;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end 
	   
	   9: begin // f_write_result_to_reg(ADDR_XR_ANALOG_DATA);  // write data 
	      av_address <= ADDR_XR_ANALOG_DATA;
	      av_writedata <= {27'd0,post_tap_rc};
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      
	      state <= 10;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   10: begin //f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd1;
	      av_write <= 1'b1;
	      av_read <= 1'b0;

		state <= 11;

	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   11: begin  // wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd1;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)	// wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
		state <= 12;
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	   end
	   
	   12: begin // Setup Offset to internal reg 0 - f_write_reg (LOCAL_ADDR_XR_MIF_OFFSET, 32'd0);
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for PIO_IN_RECONFIG_MGMT_BUSY to go low, signifying writing to PHY complete
		if (PIO_IN_VERIFY_PMA_WRITE)
		  begin
		     from_state<= POST_STATE;
		     state<= VERIFY_STATE;
		  end   
	      
		else	if (tap_to_update_pre_tap)	// check to see if there is pending pre tap update request
		  state <= PRE_STATE;
		else					
		  state <= 0;				// return to initial state to check for other PMA setting actions.
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
// pre 13
	   PRE_STATE: begin // set logical channel address to 0 - f_write_reg(ADDR_XR_ANALOG_LCH, 0); 
	      av_address <= ADDR_XR_ANALOG_LCH;
	      av_writedata <= logical_channel_number;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 14;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   14: begin //f_write_reg(ADDR_XR_ANALOG_OFFSET, 1); // Write offset for Pre (which is 1 as offset for post tap is 1) at logical_ch_register = address 3
	      av_address <= ADDR_XR_ANALOG_OFFSET;
	      av_writedata <= 32'd1;
	      av_write <= 1'b1;
	      av_read <= 1'b0;					
	      
	      state <= 15;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end 
	   
	   15: begin // f_write_result_to_reg(ADDR_XR_ANALOG_DATA);  // write data 
	      av_address <= ADDR_XR_ANALOG_DATA;
	      av_writedata <= {28'd0,enc_pre(pre_tap_rc)};
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      
	      state <= 16;
	      
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	   16: begin //f_write_reg(ADDR_XR_ANALOG_STATUS, 1); // enable wr bit in control register, start write operation by writing 1 in control register = address 2
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd1;
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      state <= 17;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end

	   17: begin // wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)	// wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
		state <= 18;
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	


	      
	   end
	   
	   
	   18: begin // Setup Offset to internal reg 0 - f_write_reg (LOCAL_ADDR_XR_MIF_OFFSET, 32'd0);
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for PIO_IN_RECONFIG_MGMT_BUSY to go low, signifying writing to PHY complete

		       if (PIO_IN_VERIFY_PMA_WRITE)
		          begin
		            from_state<= PRE_STATE;
		            state<= VERIFY_STATE;
		          end   
	         else
		          state <= 0;				// return to initial state to check for other PMA setting actions.
	      else
		       state <= state;
	         PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	         PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
			
	   
	   
//////////////////////// for PMA read verify ////////////////
	  
	   VERIFY_STATE: begin   // all other values are set and only need to set read bit in status reg
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd2;  // read;
	      av_write <= 1'b1;
	      av_read <= 1'b0;
	      state <= 20;

	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end // case: VERIFY_STATE
	   20: begin // wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd2;  // read;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b1)	// wait for PIO_IN_RECONFIG_MGMT_BUSY to indicate writing to PHY has started
		state <= 21;
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end
	   
	     
	   
	   21: begin //wait for read complete from reconfig_controller
	      av_address <= ADDR_XR_ANALOG_STATUS;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b0;
	      
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;
	      
	      if (PIO_IN_RECONFIG_MGMT_BUSY == 1'b0)  // wait for PIO_IN_RECONFIG_MGMT_BUSY to go low, signifying read compete
		state <= 22;
	      else
		state <=state;
	      
	      
	   end // case: 21
	   22: begin //  read req  from data register
	      av_address <= ADDR_XR_ANALOG_DATA;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b1;
	      if (av_waitrequest == 1'b1)	// wait for waitstate to indicate that data is ready to read on the next clock
		state <= 23;
	      else
		state <= state;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	
	   end // case: 22
	   
	  
           23: begin //  check data register

	      av_address <= ADDR_XR_ANALOG_DATA;
	      av_writedata <= 32'd0;
	      av_write <= 1'b0;
	      av_read <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_RD <= 1'b1;
	      PIO_OUT_HDSK_RC_BUSY_WR <= 1'b1;	      
	      if (from_state == VOD_STATE) // verify VOD
		begin
		   if (main_tap_rc == av_readdata)   
		     $display ("Info:  VOD main_tap_rc value is %h matches read value of %h of logical channel %d\n", main_tap_rc, av_readdata,logical_channel_number);
		   else
		   $display ("Error: VOD main_tap_rc value is %h does not matche read value of %h of logical channel %d\n", main_tap_rc, av_readdata,logical_channel_number);
		   if (tap_to_update_post_tap)			// check to see if there is pending post tap update request
		     state <= POST_STATE; 		
		   else if (tap_to_update_pre_tap)	// check to see if there is pending pre tap update request
		     state <= PRE_STATE;
		   else					
		     state <= 0;
		end 
	      else if (from_state == POST_STATE) // verify Post_tap
		begin
		   if (post_tap_rc == av_readdata)   
		     $display ("Info:  POST post_tap_rc value is %h matches read value of %h of logical channel %d\n", post_tap_rc, av_readdata,logical_channel_number);
		   else
		     $display ("Error: POST post_tap_rc value is %h does not matche read value of %h of logical channel %d\n", post_tap_rc, av_readdata,logical_channel_number);
		   
		   if (tap_to_update_pre_tap)	// check to see if there is pending pre tap update request
		     state <= PRE_STATE;
		   else					
		     state <= 0;
		end 
	      else if (from_state == PRE_STATE) // verify Pre_tap
		begin
		   if (enc_pre(pre_tap_rc) == av_readdata)   
		     $display ("Info:  PRE pre_tap_rc value is %h, the encoded pre_tap_rc value is %h matches read value of %h of logical channel %d\n", pre_tap_rc, enc_pre(pre_tap_rc), av_readdata,logical_channel_number);
		   else
		     $display ("Error: PRE pre_tap_rc value is %h, the encoded pre_tap_rc value is %h does not matche read value of %h of logical channel %d\n", pre_tap_rc, enc_pre(pre_tap_rc), av_readdata,logical_channel_number);
		   
		   state <= 0;
		end	    
	   end // case: 23
	     
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
	
	
	
	
     // need to encode the pre-tap values as the reconfig_controller un-encodes them
   // see table 16-11 in the reconfig cruontroller user guide for details
   function [3:0] enc_pre;
     input [3:0] pre_tap;
     begin
       case (pre_tap)
       4'b0000:  enc_pre = 4'b0000;
       4'b0001:  enc_pre = 4'b1111;
       4'b0010:  enc_pre = 4'b1110;
       4'b0011:  enc_pre = 4'b1101;
       4'b0100:  enc_pre = 4'b1100;
       4'b0101:  enc_pre = 4'b1011;
       4'b0110:  enc_pre = 4'b1010;
       4'b0111:  enc_pre = 4'b1001;
       4'b1000:  enc_pre = 4'b1000;
       4'b1001:  enc_pre = 4'b0111;
       4'b1010:  enc_pre = 4'b0110;
       4'b1011:  enc_pre = 4'b0101;
       4'b1100:  enc_pre = 4'b0100;
       4'b1101:  enc_pre = 4'b0011;
       4'b1110:  enc_pre = 4'b0010;
       4'b1111:  enc_pre = 4'b0001;
       default:  enc_pre = 4'b0000;
       endcase
     end
   endfunction
	
	
endmodule
