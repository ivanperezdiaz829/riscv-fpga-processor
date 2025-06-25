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


//////////////////////////////////////////////////////////////
//     user_avmm_if_sm.sv  - governs user request of the reconfig controller's AVMM interface
//
//     fileset 5/29/2013
//     version 0.5
//

`timescale 1ps/1ps

/*
 pseudo code:
 idle, wait for user request
 if user request, check if rc_mgmt_busy = 1  from reconfig controller
  - hold busy and wait for rc_mgmt_busy to go low and then give user control
 else if rc_mgmt_busy = 0
  - assert busy to arbiter, wait for (x clks to see if there is a pending action by monitoring rc_mgmt_busy for (3 clks?).
    if 3 clks pass, then grant user control
    else go back to idle.
 
 user control:
   - keep rc_mgmt_busy high, monitor if user de-asserts user request.
      if user request is de-asserted, wait for reconfig_controller to be low (may be for x numbers of clocks) then go to idle (this is for if user doesn't want to wait for reconfig controller to finish.)
      else, stay in this state as user may not be finished.
 
*/
module user_avmm_if_sm 
 #(
    parameter CHANNELS = 12,
    parameter USER_RCFG_PRIORITY = 1,
    parameter MAX_BUSY_CNT = 2, // value to wait for rc_mgmt_busy_from_reconfig_master to go high after user request.
    parameter MAX_RECONFIG_CNT = 9  // value to wait for user dassert of request to check if reconfig controller is busy.			 
  )(
   input 		  clk,
   input 		  reset,
   input 		  user_request, 
   input 		  rc_mgmt_busy_from_reconfig_master,
   output reg 		  rc_mgmt_busy_to_arbiter,
   output reg 		  grant_user,
   output reg 		  rc_mgmt_busy_force_busy,

   input [CHANNELS-1:0] pending_lt_an_req_all_ch



   , output  wire 	      pending_lt_an_req_all_ch_wire,
   output wire 	      go_to_chk_pending_wire
   
   );

   reg [3:0]          state;
   reg [2:0]          busy_counter;
   reg [3:0]          reconfig_wait_counter;
     
   //states
   localparam    INITIAL                  = 0,
		 CHK_PENDING_SEQ_PCS_MODE = 1,
		 CHK_PENDING_REQ          = 2,
                 WAIT_FOR_NOT_BUSY        = 3,
		 GRNT_USER_CTRL           = 4,
		 CHK_PENDING_ACT          = 5;
   

   
   
   assign pending_lt_an_req_all_ch_wire = (|(pending_lt_an_req_all_ch));
   assign go_to_chk_pending_wire =  (!(!USER_RCFG_PRIORITY && (|(pending_lt_an_req_all_ch))));
   
   

// state machine - governs when to grant user access to reconfig controller AVMM IF.
   always @ (posedge clk)
     if (reset) 
       begin
	  grant_user <= 1'b0;
	  rc_mgmt_busy_to_arbiter <= rc_mgmt_busy_from_reconfig_master; 
       end
     else
       case (state)
	 INITIAL: begin                // wait for user_request and then check if busy from reconfig_master.
	    if (user_request)
	      state <= CHK_PENDING_SEQ_PCS_MODE;
	    else   	     
	      state <=state;
	    
	    rc_mgmt_busy_force_busy <= 1'b0;
	    rc_mgmt_busy_to_arbiter <= rc_mgmt_busy_from_reconfig_master;
	   
	    grant_user <= 1'b0;	

            busy_counter <= 'd0;
	    reconfig_wait_counter <= 'd0;	                   
	 end // case: INITIAL

	 CHK_PENDING_SEQ_PCS_MODE: begin
	    if (!(!USER_RCFG_PRIORITY && (|(pending_lt_an_req_all_ch))))  // if PHY priority and  there is no pending LT/AN request on any channel or if USER has priority, then go through the regular checks and grant user after checking for existing action.	      
	      if (!rc_mgmt_busy_from_reconfig_master)  // ensure busy or pending requests(if USER_RCFG_PRIORITY=1) are not present
		begin
		   state <= CHK_PENDING_REQ;// state 1 waits for WAIT_FOR_RECONFIG_MASTER_BUSY clks
		   rc_mgmt_busy_force_busy <= 1'b1;		 // hold the busy signal to wait for possible pending request from reconfig_master, no grant yet.
		   rc_mgmt_busy_to_arbiter <= 1'b1;
		   $display ("Info: User reconfig access requested, checking mgmt_busy\n");
		   
		end 
	      else
		begin
		   state <= WAIT_FOR_NOT_BUSY ;// state 2 waits for rc_mgmt_busy_from_reconfig_master to go low while keeping rc_mgmt_busy_force_busy high so when the reconfig_master finishes, grant can be asserted.
		   rc_mgmt_busy_force_busy<= 1'b1;   // rc_mgmt_busy_from_reconfig_master is high at this point anyways.
		   rc_mgmt_busy_to_arbiter <= 1'b1;
		   $display ("Info: User reconfig access requested, Mgmt is busy, waiting for not busy\n");		   
		end // else: !if(!rc_mgmt_busy_from_reconfig_master)
	    else   // if there are pending LT/AN requests and USER_RCFG_PRIORITY is low (phy has priority) don't give control to user.
	      begin
		 state<= state;
		 rc_mgmt_busy_force_busy <= 1'b0;
		 rc_mgmt_busy_to_arbiter <= rc_mgmt_busy_from_reconfig_master;
	      end
	 end
	 
	 
	 CHK_PENDING_REQ: begin              // user requested control, reconfig_master not busy, checking for pending arbiter requests.
	    if (busy_counter == MAX_BUSY_CNT)  // finished waiting
	      if (rc_mgmt_busy_from_reconfig_master == 1'b1)  // if reconfig master is busy, go to state 2 to wait for not busy.
		   state <= WAIT_FOR_NOT_BUSY;  // go to wait for not busy
	      else
		   state <= GRNT_USER_CTRL;  // go to grant user access
	    else
	      begin
		 busy_counter <= busy_counter +1;
		 state <= state;
	      end
	    rc_mgmt_busy_force_busy <= 1'b1;
            grant_user <=1'b0;
	    rc_mgmt_busy_to_arbiter <= 1'b1;	    
	 end
	 WAIT_FOR_NOT_BUSY: begin        // user requested control, wait for reconfig_master not busy.
	    if (rc_mgmt_busy_from_reconfig_master == 1'b0)
	      begin
		 state <= GRNT_USER_CTRL;
		 $display("Info: Grant  user reconfig access request\n");
	      end		 
	    else
	      state <= state;
	    rc_mgmt_busy_force_busy <= 1'b1;
	    grant_user <= 1'b0;
	    	  
	 end
	 
	 GRNT_USER_CTRL: begin  // grant user control, wait for user request to go low and make sure 
	    if (user_request == 1'b0)
	      begin
		 state <= CHK_PENDING_ACT;  // need to check if reconfig controller is still busy to catch pre-mature user deassertion of user_request
		 $display("Info: User deasserted request, checking pending action before releasing grant\n");
		 
	      end
	    
	    else
	      state <= state;
	    rc_mgmt_busy_force_busy <= 1'b1;
	    rc_mgmt_busy_to_arbiter <= 1'b1;
	    grant_user <= 1'b1;

	    
	 end // case: GRNT_USER_CTRL
	 
	 CHK_PENDING_ACT: begin // wait 10 clk cycles to see if reconfig controller is busy
	      if (reconfig_wait_counter >= MAX_RECONFIG_CNT)
		begin
		   reconfig_wait_counter <= reconfig_wait_counter;
		   
		   if (rc_mgmt_busy_from_reconfig_master)
		     state <= state;
		   else
		     state <= INITIAL;
                
                end
	      else
		begin
		   reconfig_wait_counter <= reconfig_wait_counter +1;
		   state <= state;
		end
	    grant_user <= 1'b1;
	    rc_mgmt_busy_force_busy <= 1'b1;
	    rc_mgmt_busy_to_arbiter <= 1'b1;	    
	 end // case: CHK_PENDING_ACT
	 
	 default: begin
	    state <= INITIAL;
	    grant_user <= 1'b0;
	    rc_mgmt_busy_force_busy <= 1'b0;
 	    rc_mgmt_busy_to_arbiter <= 1'b0;  
          end
	 
       endcase // case (state)

endmodule // user_avmm_if_sm
