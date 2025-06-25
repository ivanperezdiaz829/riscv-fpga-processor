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


// Arbiter.v - Arbitrates between 10GBaseKR PHY channels to the reconfig_master 
//
//     fileset 5/29/2013
//     version 0.5
//
// 
//    v0.5 4/30/2013 - DFE and CTLE arbitration additionsadded version number for new bundle file tracking

`timescale 1ps/ 1ps

module arbiter  #(
    parameter CHANNELS  = 12,
    parameter CWIDTH    = clogb2(CHANNELS-1),
    parameter PRI_RR    = 0 // use round-robin priority
) (
  input 		  clk,
  input 		  reset,
  // Inputs from PHY
  input [CHANNELS-1:0] 	  lt_start_rc, // 1 per channel, synchronous with clk
  input [CHANNELS-1:0] 	  seq_start_rc, // 1 per channel, synchronous with clk
  input [CHANNELS*6-1:0]  seq_pcs_mode, // 1 per channel, synchronous with clk
  // Output to PHY
  output [CHANNELS-1:0]   hdsk_rc_busy, // 1 per channel, synchronous with clk

  // Inputs from reconfig
  input 		  rcfg_busy, // reconfig_busy from controller
  output reg 		  rcfg_lt_start_rc, // pma reconfig request to mgmt_master
  output reg 		  rcfg_seq_start_rc, // pcs reconfig request to mgmt_master
  output reg [CWIDTH-1:0] rcfg_chan_select, // pcs reconfig request to mgmt_master

// the following is for DFE and CTLE additions
  input [CHANNELS-1:0] 	  dfe_start_rc, // 1 per channel, synchronous with clk
  output reg 		  rcfg_dfe_start_rc, // DFE reconfig request to reconfig_master

  input [CHANNELS-1:0] 	  ctle_start_rc, // 1 per channel, synchronous with clk
  output reg 		  rcfg_ctle_start_rc //CTLE reconfig request to reconfig_master
);

//localparam CWIDTH    = clogb2(CHANNELS-1);
localparam  [CWIDTH-1:0]  ZERO  = 0;
localparam  [CWIDTH-1:0]  ONE   = 1;

integer i;
reg   [CWIDTH-1:0]  next_rcfg_chan_select;  // combinatorial result for next channel select
wire                advance_chan_select;    // flag to advance channel select
wire                advance_chan_select_pulse;

reg   [3:0] pcs_wait_cnt;
reg         pcs_hold,prev_lt_req_served,advance_chan_select_reg,prev_lt_req_served_reg,cnt_set;
wire        prev_lt_req_served_pulse,cnt_cmp;
reg         busy_gate;
reg         lt_req_served; 
//***************************************************************************

reg next_rcfg_lt_start_rc;
reg next_rcfg_dfe_start_rc; 
reg next_rcfg_ctle_start_rc;

//LT
always @(*)
begin	
  if (rcfg_busy)
  next_rcfg_lt_start_rc = 1'b0 ;
  else
  next_rcfg_lt_start_rc  = lt_start_rc[rcfg_chan_select];  // PMA request for current channel
end
always @(posedge clk or posedge reset)
begin	
  if (reset)
  rcfg_lt_start_rc <= 1'b0 ;
  else
  rcfg_lt_start_rc <= next_rcfg_lt_start_rc ;
end

 
// added for DFE,  treating it the same as lt_start_rc for now  -stam added

always @(*)
begin	
  if (rcfg_busy)
  next_rcfg_dfe_start_rc = 1'b0 ;
  else
  next_rcfg_dfe_start_rc  = dfe_start_rc[rcfg_chan_select];  // PMA request for current channel
end

always @ (posedge clk or posedge reset)
  begin
     if (reset)
       rcfg_dfe_start_rc <= 1'b0;
     else
       rcfg_dfe_start_rc <= next_rcfg_dfe_start_rc; // DFE quest for current channel.  
  end
// end added for DFE


   
// added for CTLE, treating it the same as lt_start_rc for now -stam added


always @(*)
begin	
  if (rcfg_busy)
  next_rcfg_ctle_start_rc = 1'b0 ;
  else
  next_rcfg_ctle_start_rc  = ctle_start_rc[rcfg_chan_select];  // PMA request for current channel
end

always @ (posedge clk or posedge reset)
  begin
     if (reset)
       rcfg_ctle_start_rc <= 1'b0;
     else
       rcfg_ctle_start_rc <= next_rcfg_ctle_start_rc; // CTLE quest for current channel.  
  end
// end added for CTLE





// dfe_start_rc, ctle_start_rc do not gate rcfg_seq_start_rc for this version.
// Only request PCS if no PMA requests, and not waiting for pcs counter --masking PCS req
// But do not mask once its asserted--hence & with "!rcfg_seq_start_rc"
reg next_rcfg_seq_start_rc; 
always  @(*)
begin	
  if (rcfg_busy)
  next_rcfg_seq_start_rc = 1'b0 ;
  else if (prev_lt_req_served)
  next_rcfg_seq_start_rc  = seq_start_rc[rcfg_chan_select] & (!lt_start_rc | rcfg_seq_start_rc) & cnt_set; 
  else	  
  next_rcfg_seq_start_rc  = seq_start_rc[rcfg_chan_select] & (!lt_start_rc | rcfg_seq_start_rc) ; 
end
always @(posedge clk or posedge reset)
begin
  if (reset)
  rcfg_seq_start_rc <= 1'b0 ;
  else
  rcfg_seq_start_rc <= next_rcfg_seq_start_rc;
end
assign cnt_cmp = (pcs_wait_cnt==4'b0001)? 1'b1 : 1'b0 ;
//set ff with cnt_cmp and reset with reconfig busy service req
always @ (posedge clk or posedge reset)
 if (reset)
 cnt_set <= 1'b0;
 else if (cnt_cmp)
 cnt_set <= 1'b1;
 else if (rcfg_busy)
 cnt_set <= 1'b0;

	
// Hold PCS req until rcfg_busy feedback and if previous PCS service was for LT
always @(posedge clk or posedge reset)
  if(reset)                         pcs_hold  <= 1'b0;
  else if(pcs_hold)                 pcs_hold  <= 1'b0;
  else if(prev_lt_req_served_pulse) pcs_hold  <= 1'b1;

// Wait 10 clocks after PCS reconfiguration before proceeding
always @(posedge clk or posedge reset)
  if(reset)                                pcs_wait_cnt  <= 4'd0;
  else if(pcs_hold)                        pcs_wait_cnt  <= 4'd10;
  else if(pcs_wait_cnt==4'b0000)           pcs_wait_cnt  <= 4'd0; 
  else if(prev_lt_req_served)              pcs_wait_cnt  <= pcs_wait_cnt + 4'b1111;
//else if(!rcfg_busy & prev_lt_req_served & !rcfg_seq_start_rc) pcs_wait_cnt  <= pcs_wait_cnt + 4'b1111;


// We advance to the next channel if the current channel is not requesting
// and reconfiguration controller is not busy.
//assign  advance_chan_select = !{rcfg_busy,next_rcfg_lt_start_rc,next_rcfg_seq_start_rc,pcs_wait_cnt};
assign  advance_chan_select = !{rcfg_busy,next_rcfg_lt_start_rc,next_rcfg_seq_start_rc,next_rcfg_dfe_start_rc,next_rcfg_ctle_start_rc,pcs_wait_cnt}; //added dfe, ctle

always @(*) begin
      next_rcfg_chan_select = rcfg_chan_select;
  for(i=CHANNELS-1;i>=0;i=i-1) begin
//    if(lt_start_rc[i] || (seq_start_rc[i] && !lt_start_rc))   // old version w/o DFE/CTLE
     if (lt_start_rc[i] || dfe_start_rc[i] || ctle_start_rc[i] || (seq_start_rc[i] && !lt_start_rc)) //added dfe, ctle
      next_rcfg_chan_select = i[CWIDTH-1:0];
  end
  if(PRI_RR) begin
    for(i=CHANNELS-1;i>=0;i=i-1) begin // give higher priority to increasing the selected channel for round-robin
//      if( (i > rcfg_chan_select) && (lt_start_rc[i] || (seq_start_rc[i] && !lt_start_rc)) )
  if( (i > rcfg_chan_select) && (lt_start_rc[i] || (dfe_start_rc[i]) || (ctle_start_rc[i]) || (seq_start_rc[i] && !lt_start_rc)) )  // added dfe, ctle
      
        next_rcfg_chan_select = i[CWIDTH-1:0];
    end
  end
end

// rcfg_chan_select registers
always @(posedge clk or posedge reset)
  if(reset)                     rcfg_chan_select  <= ZERO;
  else if(advance_chan_select)  rcfg_chan_select  <= next_rcfg_chan_select;

// check if current req being served is lt_req
//assign lt_req_served = (seq_pcs_mode [rcfg_chan_select*6+:6] == 2 )? 1'b1 : 1'b0  ;
always @ (posedge clk or posedge reset)
if (reset)	
lt_req_served <= 1'b0;
else if (rcfg_seq_start_rc)
 lt_req_served <= (seq_pcs_mode [rcfg_chan_select*6+:6] == 2 );	
else if (rcfg_lt_start_rc)
lt_req_served <= 1'b0;

// create pulse of advance ch select to latch lt_req_served .. this is required as  advance ch select
// might be more than single clk signal and cause to loose expected value of prev_lt_req_served in next cycle
always @ (posedge clk or posedge reset)
 if (reset) begin
 advance_chan_select_reg <= 1'b0;
 prev_lt_req_served_reg  <= 1'b0;
 end
 else  begin
 advance_chan_select_reg <= advance_chan_select ;
 prev_lt_req_served_reg  <= prev_lt_req_served & !advance_chan_select_pulse; 
 end 

assign advance_chan_select_pulse = advance_chan_select & !advance_chan_select_reg ;
assign prev_lt_req_served_pulse  = prev_lt_req_served  & !prev_lt_req_served_reg;


// check if prev service was for lt_req
always @(posedge clk or posedge reset)
  if(reset)                           prev_lt_req_served <= 1'b0;
  else if(advance_chan_select_pulse)  prev_lt_req_served <= lt_req_served;

// hdsk busy should be asserted only when req from aribter is being served 
// it should not be asserted to any other RC operations e.g. power up rc_busy might default hdsk_rc_busy to 1
// generate signal upon receipt of REQ and deassert on busy low - use this to gate hdsk_busy 
always @ (posedge clk or posedge reset)
if (reset)
busy_gate <= 1'b0;
//else if (!rcfg_busy & ((|lt_start_rc) | (|seq_start_rc)))
else if (!rcfg_busy & ((|lt_start_rc) | (|seq_start_rc) | (|dfe_start_rc) | (|ctle_start_rc))) // adding dfe_start_rc and ctle_start_rc to the mix 
busy_gate <= 1'b1;
else if (busy_gate & !rcfg_busy) 
busy_gate <= 1'b0;

// Assign the busy signal to each channel
assign  hdsk_rc_busy  = (ZERO | (rcfg_busy & busy_gate)) << rcfg_chan_select;
//assign  hdsk_rc_busy  = ZERO; // | rcfg_busy) << rcfg_chan_select;

// Log base 2 function for calculating bus widths
function integer clogb2;
  input [31:0] value;
  for (clogb2=0; value>0; clogb2=clogb2+1)
    value = value>>1;
endfunction

endmodule

