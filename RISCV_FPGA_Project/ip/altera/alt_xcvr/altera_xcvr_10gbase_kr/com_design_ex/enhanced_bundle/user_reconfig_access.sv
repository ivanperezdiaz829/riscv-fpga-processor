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


/////////////////////////////////////////////////////////////////////
//
// USER_RECONFIG_ACCESS.SV - Allows user to gain access to reconfig controller
//
//     fileset 5/29/2013
//     version 0.9
//
// User access is based on request/grant scheme:
//    - user asserts request bit through the AVMM IF and wait for grant bit to go high
//    - USER_RCFG_PRIORITY parameter controls if the grant will be gated by all channel's AN/LT state or not
//    -       if USER_RCFG_PRIORITY = 1, if user request is high, grant will be high after any pending reconfig operation is finished (can interrupt AN/LT sequence)
//    -                             = 0, grant will be given after all current AN/LT request from all channels have been serviced.
//
//
// slave address - 8-bits, data width - 32-bits
//
// slave address offset breakdown:
//          reconfig_controller address space      = 0x 00-7F  reconfig controller's AVMM interface 
//          status register address space          = 0x 80-83  status_avmm
//          status register bits                   = 0x 80  -  [31:16] 0's filled on unused upper bits, lower indicates channels in LT/AN mode 
//                                                             [15:9] = reserved ( unused), 
//                                                             [8] = Grant (RO), 
//                                                             [7:1] - reserved (unused), 
//                                                             [0] = user request (RW)
//          scratch_register                       = 0x 81  -  [31:0] = for user to read/write to (RW)
//          disable_ctle_dfe_before_an             = 0x 82  -  [31:2] = 0's. 
//                                                             [1] disable CTLE before AN start (RW)
//                                                             [0] disable DFE before AN start (RW)
//          bypass_ctle_reconfig                   = 0x 83  -  [31:1] = 0's. [0] bypass_ctle_reconfig for user settings.  (RW)
//          DFE Vref adjust values and enable bit  = 0x 84  -  [31:11] = 0's 
//                                                             [10:8] = high setting for vref (what vref will settle to before triggering)   
//                                                             [7] = 0, 
//                                                             [6:4] = low setting for vref (what it will fall to before going to vref_high) 
//                                                             [3:1] = 0's. 
//                                                             [0] dfe_ena_vref_reg (1 = turn on to enable DFE vref kick) (RW)
//          unused (reserved)                      = 0x 85-8F
//
//          v0.5 5/14/2013  - added support to disable the CTLE and DFE engine before AN and dynamic bypass of CTLE settings from the PHY
//          v0.6 5/15/2013  - added reset of bypass_ctle_reconfig register to fix simulation 'x'
//          v0.7 5/17/2013  - fixed user controlled bypass_ctle_reconfig and disable_ctle_dfe_before_an avmm readback
//          v0.8 5/24/2013  - added register for DFE Vref adjustment and value registers
//          v0.9 5/29/2013  - added capability to separately disable CTLE or DFE before AN (disable_ctle_dfe_before_an is now 2 bits per mapping above)
//
////////////////////////////////////////////////////////////////////




`timescale 1ps/1ps




module user_reconfig_access 
  #(
    parameter USER_RCFG_PRIORITY = 0,
    parameter CHANNELS = 12
			      
 ) (
   input 		  clk,
   input 		  reset,

   input 		  rc_mgmt_busy_from_reconfig_master, // uses this to gate grant for user access
//   input 	     reconfig_rc_pending_from_arbiter, // this may be used to see if there are any pending request from the arbiter

   
   output reg 		  rc_mgmt_busy_to_arbiter, // will assert this if user requests access to reconfig controller

   input [CHANNELS*6-1:0] seq_pcs_mode, // for checking if any pending LT or AN sequence is active on any phy before granting user reconfig control


   input [7:0] 		  avmm_address,
   input 		  avmm_read,
   input 		  avmm_write,
   input [31:0] 	  avmm_writedata,
   output reg [31:0] 	  avmm_readdata,
   output reg 		  avmm_waitrequest,
   

   // AVMM reconfig_master interface (Slave)
   input [6:0] 		  from_reconfig_master_avmm_address,
   input 		  from_reconfig_master_avmm_read,
   input 		  from_reconfig_master_avmm_write,
   input [31:0] 	  from_reconfig_master_avmm_writedata,
   output reg [31:0] 	  to_reconfig_master_avmm_readdata,
   output reg 		  to_reconfig_master_avmm_waitrequest, 
   
   // AVMM xcvr reconfig controller (Master)
   output reg [6:0] 	  to_reconfig_mgmt_address,
   output reg 		  to_reconfig_mgmt_read,
   output reg 		  to_reconfig_mgmt_write,
   output reg [31:0] 	  to_reconfig_mgmt_writedata,
   input reg [31:0] 	  from_reconfig_mgmt_readdata,
   input reg 		  from_reconfig_mgmt_waitrequest,

   // reconfig_mgmt_busy
   output reg 		  to_user_reconfig_reconfig_mgmt_busy,
   output reg 		  to_reconfig_master_reconfig_mgmt_busy,
   input 		  from_reconfig_mgmt_reconfig_mgmt_busy,
    
   // output control ports
   output reg [1:0]       disable_ctle_dfe_before_an, // bit 1= disable ctle before AN, bit 0= disable dfe before AN  (1 = disable before AN, 0 = don't disable before AN)
   output reg 		  bypass_ctle_reconfig,       // 1= bypass ctle (prevents PHY from changing phy settings in ctle mode, 0= normal operations, PHY changes ctle  values.
   output reg [2:0] 	  dfe_vref_low_reg,           // vref low value for the temporary setting
   output reg [2:0] 	  dfe_vref_high_reg,          // vref high value - what the operational value should be
   output reg 		  dfe_ena_vref_reg            // 1= enable DFE vref override, 0 = standard DFE settings
    
  );
 
   
   reg 		     user_request;
   wire 	     grant_user;

   reg [31:0] 	     scratch_register; // for testing out status 


   
   reg [1:0] 	     read_state;
   
   reg 		     status_avmm_waitrequest_reg;
   

   wire 	     rc_mgmt_busy_force_busy;   // 1 = high to select forced busy 1'b1 on rc_mgmt_busy signal, 0 = select busy from grant select. 

   reg [CHANNELS-1:0] pending_lt_an_req_all_ch;   // channel based LT or AN pending request indicator.

   integer 	      i;
 
   localparam [15-CHANNELS:0] ZERO = 0;
      

   
   // status interface (Slave)
   reg	[2:0]      status_avmm_address;   
   reg 	      status_avmm_read;
   reg 	      status_avmm_write;
   reg [31:0] 	      status_avmm_writedata;
   reg [31:0] 	      status_avmm_readdata;
   reg 		      status_avmm_waitrequest;
   
   // user interface (Slave)
   reg [6:0] 	      from_user_reconfig_avmm_address; // 7 bits
   reg 	      from_user_reconfig_avmm_read;
   reg 	      from_user_reconfig_avmm_write;
   reg [31:0] 	      from_user_reconfig_avmm_writedata;
   reg [31:0] 	      to_user_reconfig_avmm_readdata;
   reg 		      to_user_reconfig_avmm_waitrequest;
   

//// to split user avmm interface to status and reconfig avmm interfaces
always @ (*)
  if (avmm_address[7])   // access for status
    begin
       avmm_waitrequest = status_avmm_waitrequest;
       avmm_readdata = status_avmm_readdata;
       status_avmm_read = avmm_read;
       status_avmm_write = avmm_write;
       status_avmm_writedata = avmm_writedata;
       status_avmm_address = avmm_address[2:0];
       
       from_user_reconfig_avmm_address = 'd0;
       from_user_reconfig_avmm_read = 1'b0;
       from_user_reconfig_avmm_write = 1'b0;
       from_user_reconfig_avmm_writedata = 'd0;
    end // if (avmm_address[7])
  else
    begin
       avmm_waitrequest = to_user_reconfig_avmm_waitrequest;
       avmm_readdata = to_user_reconfig_avmm_readdata;

       from_user_reconfig_avmm_address = avmm_address[6:0];
       from_user_reconfig_avmm_writedata = avmm_writedata;
       from_user_reconfig_avmm_read = avmm_read;
       from_user_reconfig_avmm_write = avmm_write;

       status_avmm_read = 1'b0;
       status_avmm_write = 1'b0;
       status_avmm_writedata = 'd0;
       status_avmm_address = 'd0;

       
    end // else: !if(avmm_address[7])
   


   
// grant state machine
   user_avmm_if_sm  
    #(
      .CHANNELS (CHANNELS),
      .USER_RCFG_PRIORITY (USER_RCFG_PRIORITY)
						  
    ) user_avmm_if_sm_ins(
      .clk                               (clk),                                //i
      .reset                             (reset),                              //i
      .user_request                      (user_request),                       //i
      .rc_mgmt_busy_from_reconfig_master (rc_mgmt_busy_from_reconfig_master),  //i
      .rc_mgmt_busy_to_arbiter           (rc_mgmt_busy_to_arbiter),            //o
      .grant_user                        (grant_user),                         //o
      .rc_mgmt_busy_force_busy           (rc_mgmt_busy_force_busy),            //o
      .pending_lt_an_req_all_ch          (pending_lt_an_req_all_ch)
      );
 	 
// checking if pcs_mode_rc bit0 or bit1 is high (for each channel)

   always @(*)
     for (i=CHANNELS-1; i>=0; i=i-1)
        pending_lt_an_req_all_ch[i] = seq_pcs_mode[i*6] || seq_pcs_mode[(i*6)+1];

   
   // status interface write
   always @(posedge clk)
     if (reset)
       begin
	  user_request <= 1'b0;
	  scratch_register <='d0;
	  bypass_ctle_reconfig <=1'b0;
	  disable_ctle_dfe_before_an <= 2'd0;
          dfe_vref_high_reg <= 'd0;
	  dfe_vref_low_reg <= 'd0;
	  dfe_ena_vref_reg <= 'd0;
	  
	  
       end
   else if (status_avmm_write && (status_avmm_address== 'd0))     // status register
       user_request <= status_avmm_writedata[0];
     else if (status_avmm_write && (status_avmm_address == 'd1))  // scratch register
       scratch_register <= status_avmm_writedata;
     else if (status_avmm_write && (status_avmm_address == 'd2))  // disable_ctle_dfe_before_an register
       disable_ctle_dfe_before_an <= status_avmm_writedata[1:0];
     else if (status_avmm_write && (status_avmm_address == 'd3)) // disable LT reconfiguration (for user testing)
       bypass_ctle_reconfig <= status_avmm_writedata[0];
     else if (status_avmm_write && (status_avmm_address == 'd4))
       begin
          dfe_vref_high_reg <= status_avmm_writedata[10:8];    // DFE vref high value
	  dfe_vref_low_reg <= status_avmm_writedata[6:4];      // DFE vref low value
	  dfe_ena_vref_reg <= status_avmm_writedata[0];        // ena DFE vref override
       end	  
   
     else
       begin
	  user_request <= user_request;
	  scratch_register <= scratch_register;
	  bypass_ctle_reconfig <= bypass_ctle_reconfig;
	  disable_ctle_dfe_before_an <= disable_ctle_dfe_before_an;
          dfe_vref_high_reg <= dfe_vref_high_reg;
	  dfe_vref_low_reg <= dfe_vref_low_reg ;
	  dfe_ena_vref_reg <= dfe_ena_vref_reg;
       end



    
   

/*
    
// status interface read  (fixed latency read 1clk cycle)
   always @(posedge clk)
     if (reset)
       status_avmm_readdata <= 'd0;
     else if (status_avmm_read)
	   if (status_avmm_address)
	     status_avmm_readdata <= scratch_register;
	   else
	     status_avmm_readdata <={23'd0,grant_user,7'd0,user_request};  // grant_user is on bit 8 and user_request is on bit 0
     else
       status_avmm_readdata <= 32'd0;

 assign status_avmm_waitrequest = 1'b0;  // not used for fixed latency read
 */

   always @ (*)
     if ((read_state=='d0) && status_avmm_read)
       status_avmm_waitrequest = 1'b1;    //to ensure status_avmm_waitrequest is asserted as status_avmm_read = 1 in the same clk cycle
     else
       status_avmm_waitrequest = status_avmm_waitrequest_reg;
	
	
   
// read and waitrequest
   always @ (posedge clk)
     if (reset)
       begin
	  read_state <='d0;
	  status_avmm_waitrequest_reg <= 1'b0;
	  status_avmm_readdata <= 'd0;	  
       end
     else
       case (read_state)
	 0: begin   // wait on read
	    if (status_avmm_read) 
	      begin	       
	       status_avmm_waitrequest_reg <= 1'b1;
	       read_state <= 1;
	      end
	    else
	      begin
		 status_avmm_waitrequest_reg <=1'b0;
		 read_state<=read_state;
	      end // else: !if(status_avmm_read)
	    status_avmm_readdata<='d0;
	 end
	 1: begin // waitrequest high for 1 clk cycle
	    status_avmm_waitrequest_reg<=1'b1;
	    status_avmm_readdata<='d0;
	    read_state<=2;
	    end
	      
	 2:begin // deassert waitrequest and output readdata and wait for read low to go to state0
	    status_avmm_waitrequest_reg <=1'b0;
	    if (status_avmm_read == 1'b0)
	      read_state<=0;
	    else
	      read_state<=read_state;
   	   if (status_avmm_address=='d1)    // read from scratch register
	     status_avmm_readdata <= scratch_register;
	   else if (status_avmm_address =='d0)
	     status_avmm_readdata <={ZERO,pending_lt_an_req_all_ch,7'd0,grant_user,7'd0,user_request};  // grant_user is on bit 8 and user_request is on bit 0
	   else if (status_avmm_address =='d2)
	     status_avmm_readdata <= {30'd0,disable_ctle_dfe_before_an};
	   else if (status_avmm_address =='d3)
	     status_avmm_readdata <= {31'd0, bypass_ctle_reconfig};
	   else if (status_avmm_address == 'd4)
	     status_avmm_readdata <= {11'd0 ,dfe_vref_high_reg,1'b0,dfe_vref_low_reg,3'd0,dfe_ena_vref_reg};
	    
	 end // case: 2
	 default: begin
	    read_state <='d0;
	    status_avmm_readdata<='d0;
	    status_avmm_waitrequest_reg<=1'b0;
	 end
       endcase // case (read_state)
   
	   
	    
			      
 //  assign status_avmm_waitrequest = 1'b0;   // not needed
   
   
   
	   

 

 /*  // not neede as this is driven by the state machine block
// rc_mgmt_busy mux
   always @ (*)
     if (rc_mgmt_busy_force_busy)  // || grant_user)    // if user access or force busy is high, output high to stop the arbiter
       rc_mgmt_busy_to_arbiter <= 1'b1;
     else                                         // if no user access or force busy, allow reconfig_master control of busy signal.
       rc_mgmt_busy_to_arbiter <= rc_mgmt_busy_from_reconfig_master;
   
   */
       
 

// AVMM mux to reconfig controller based on grant_user	      
   always @ (*)
       if (grant_user)   // connect reconfig_master to xcvr reconfig controller
	 begin
	   to_reconfig_mgmt_address   = from_user_reconfig_avmm_address;
	   to_reconfig_mgmt_read      = from_user_reconfig_avmm_read;
	   to_reconfig_mgmt_write     = from_user_reconfig_avmm_write;
	   to_reconfig_mgmt_writedata = from_user_reconfig_avmm_writedata;
	 end
       else
         begin
	   to_reconfig_mgmt_address   = from_reconfig_master_avmm_address;
	   to_reconfig_mgmt_read      = from_reconfig_master_avmm_read;
	   to_reconfig_mgmt_write     = from_reconfig_master_avmm_write;
	   to_reconfig_mgmt_writedata = from_reconfig_master_avmm_writedata;
         end
	     
	      

  // gate reconfig_mgmt_busy
   assign to_user_reconfig_reconfig_mgmt_busy   = from_reconfig_mgmt_reconfig_mgmt_busy && grant_user;
   assign to_reconfig_master_reconfig_mgmt_busy = from_reconfig_mgmt_reconfig_mgmt_busy && !grant_user;

  // gate reconfig_mgmt_readdata 
   assign to_user_reconfig_avmm_readdata   = from_reconfig_mgmt_readdata           &  {32{grant_user}};
   assign to_reconfig_master_avmm_readdata = from_reconfig_mgmt_readdata           &  {32{!grant_user}};
   
  // gate waitrequest
   assign to_user_reconfig_avmm_waitrequest     = from_reconfig_mgmt_waitrequest        && grant_user;
   assign to_reconfig_master_avmm_waitrequest   = from_reconfig_mgmt_waitrequest        && !grant_user;


   
endmodule // user_reconfig_access

