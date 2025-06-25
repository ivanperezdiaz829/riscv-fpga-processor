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


//// GIGE Synchronization FSM
//// Starts when start signal goes high 
//// sends out 3 synchronization ordered sets
//// synchronization ordered sets consists of {/K28.5/,/Dx.y/,/Dx.y/,/Dx.y/}
//// {/K28.5/,/F0/,/F0/,/F0/}
//// According to IEEE specs it should be {/K28.5/,/Dx.y/,/Dx.y/,/Dx.y/}.. 
//// But altera transceiver can handle any odd number of data groups

`define   K28_5 9'h1BC
`define   Dxy   9'h0F0
`timescale 1 ps/1 ps


module gige_sync_fsm (

input  wire 	       gmii_tx_clk,      /// 1g-tx clk from PHY
input  wire 	       phy_mgmt_clk_reset,   //  master reset
input  wire 	       gige_sync_start,  // start signal for FSM
output wire 	       sync_aquired,    //  done signal indicating 3 synchronization sets have been sent 
output wire [7:0]      sync_d,          // gige data 
output wire            sync_k           // gige control
);

localparam GIGE_IDLE        = 7'b000_0001 ;    
localparam GIGE_WAIT        = 7'b000_0010 ; 
localparam GIGE_K28_5       = 7'b000_0100 ; 
localparam GIGE_DXY_0       = 7'b000_1000 ; 
localparam GIGE_DXY_1       = 7'b001_0000 ; 
localparam GIGE_DXY_2       = 7'b010_0000 ; 
localparam GIGE_SYNC        = 7'b100_0000 ; 

reg [6:0]    state_gige_fsm,nxt_state_gige_fsm;
reg          done,cnt_en,cnt_rst;
reg [2:0]    cnt_sync;
reg [7:0]    gmii_d;
reg          gmii_k;

always_ff @  (posedge phy_mgmt_clk_reset or posedge gmii_tx_clk) begin

if (phy_mgmt_clk_reset)
state_gige_fsm <= GIGE_IDLE ;
else 
state_gige_fsm <= nxt_state_gige_fsm ;
end


always_comb 
begin

case(state_gige_fsm)
GIGE_IDLE  :   nxt_state_gige_fsm = GIGE_WAIT ;
GIGE_WAIT  :   if (gige_sync_start) nxt_state_gige_fsm = GIGE_K28_5 ; else nxt_state_gige_fsm = GIGE_WAIT ;
GIGE_K28_5 :   nxt_state_gige_fsm = GIGE_DXY_0 ;
GIGE_DXY_0 :   nxt_state_gige_fsm = GIGE_DXY_1 ;
GIGE_DXY_1 :   nxt_state_gige_fsm = GIGE_DXY_2 ;
GIGE_DXY_2 :   if (cnt_sync == 4 ) nxt_state_gige_fsm = GIGE_SYNC ; else nxt_state_gige_fsm = GIGE_K28_5 ;
GIGE_SYNC  :   if (gige_sync_start) nxt_state_gige_fsm = GIGE_K28_5; else nxt_state_gige_fsm = GIGE_SYNC ;
default    :   nxt_state_gige_fsm = GIGE_IDLE ;
endcase

end

always_comb 
begin
done=0;
cnt_en=0;
gmii_d= 8'hBC;
gmii_k=0;
cnt_rst=0;

case (state_gige_fsm)
GIGE_WAIT  :   begin cnt_rst=1; gmii_k=1'b1; end
GIGE_K28_5 :   gmii_k=1'b1;
GIGE_DXY_0 :   begin gmii_d=8'hF0;cnt_en=1;  end
GIGE_DXY_1 :   gmii_d=8'hF0;
GIGE_DXY_2 :   gmii_d=8'hF0;
GIGE_SYNC  :   done=1;
default    :   begin 
               done=0;
               cnt_en=0;
               gmii_d=8'hBC;
               gmii_k=0;
               cnt_rst=0;
               end 
endcase

end

//// counter -- increments after every synchronization set is send 
always_ff @  (posedge phy_mgmt_clk_reset or posedge gmii_tx_clk) begin
if (phy_mgmt_clk_reset)
cnt_sync <= 0;
else if (cnt_rst)
cnt_sync <= 0;
else if (cnt_en)
cnt_sync <= cnt_sync+1;
end

assign sync_d = gmii_d ;
assign sync_k = gmii_k ;
assign sync_aquired = done ;

endmodule
