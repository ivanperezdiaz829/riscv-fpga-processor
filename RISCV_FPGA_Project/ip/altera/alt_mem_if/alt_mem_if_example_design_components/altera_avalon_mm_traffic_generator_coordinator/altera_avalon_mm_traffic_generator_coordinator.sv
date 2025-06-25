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


//////////////////////////////////////////////////////////////////////////////
// The coordinator control the traffic of individual traffic generator that 
// connect to it. It will assert the coordinator_ready only when the port reach
// their turn and when the other port with similar turn no is ready (in sync mode)
//////////////////////////////////////////////////////////////////////////////

module altera_avalon_mm_traffic_generator_coordinator(
    clk,
    reset_n,
    unique_done,
    unique_done_1,
    unique_done_2,
    unique_done_3,
    unique_done_4,
    unique_done_5,
    unique_done_6,
    unique_done_7,
    unique_done_8,
    unique_done_9,
    unique_done_10,
    unique_done_11,
    unique_ready,
    unique_ready_1,
    unique_ready_2,
    unique_ready_3,
    unique_ready_4,
    unique_ready_5,
    unique_ready_6,
    unique_ready_7,
    unique_ready_8,
    unique_ready_9,
    unique_ready_10,
    unique_ready_11,
	coordinator_ready,
    coordinator_ready_1,
    coordinator_ready_2,
    coordinator_ready_3,
    coordinator_ready_4,
    coordinator_ready_5,
    coordinator_ready_6,
    coordinator_ready_7,
    coordinator_ready_8,
    coordinator_ready_9,
    coordinator_ready_10,
    coordinator_ready_11
);

input                           clk;
input                           reset_n;

input                           unique_done;
input                           unique_done_1;
input                           unique_done_2;
input                           unique_done_3;
input                           unique_done_4;
input                           unique_done_5;
input                           unique_done_6;
input                           unique_done_7;
input                           unique_done_8;
input                           unique_done_9;
input                           unique_done_10;
input                           unique_done_11;

input                           unique_ready;
input                           unique_ready_1;
input                           unique_ready_2;
input                           unique_ready_3;
input                           unique_ready_4;
input                           unique_ready_5;
input                           unique_ready_6;
input                           unique_ready_7;
input                           unique_ready_8;
input                           unique_ready_9;
input                           unique_ready_10;
input                           unique_ready_11;

output                          coordinator_ready;
output                          coordinator_ready_1;
output                          coordinator_ready_2;
output                          coordinator_ready_3;
output                          coordinator_ready_4;
output                          coordinator_ready_5;
output                          coordinator_ready_6;
output                          coordinator_ready_7;
output                          coordinator_ready_8;
output                          coordinator_ready_9;
output                          coordinator_ready_10;
output                          coordinator_ready_11;

parameter TGC_TURN_PORT_0 = 0;
parameter TGC_TURN_PORT_1 = 0;
parameter TGC_TURN_PORT_2 = 1;
parameter TGC_TURN_PORT_3 = 2;
parameter TGC_TURN_PORT_4 = 0;
parameter TGC_TURN_PORT_5 = 0;
parameter TGC_TURN_PORT_6 = 0;
parameter TGC_TURN_PORT_7 = 0;
parameter TGC_TURN_PORT_8 = 0;
parameter TGC_TURN_PORT_9 = 0;
parameter TGC_TURN_PORT_10 = 0;
parameter TGC_TURN_PORT_11 = 0;

parameter TGC_USE_SYNC_READY_0  = 0;
parameter TGC_USE_SYNC_READY_1  = 0; 
parameter TGC_USE_SYNC_READY_2  = 0;
parameter TGC_USE_SYNC_READY_3  = 0;
parameter TGC_USE_SYNC_READY_4  = 0;
parameter TGC_USE_SYNC_READY_5  = 0;
parameter TGC_USE_SYNC_READY_6  = 0;
parameter TGC_USE_SYNC_READY_7  = 0;
parameter TGC_USE_SYNC_READY_8  = 0;
parameter TGC_USE_SYNC_READY_9  = 0;
parameter TGC_USE_SYNC_READY_10 = 0;
parameter TGC_USE_SYNC_READY_11 = 0;

wire                           sync_ready;
wire                           sync_ready_1;
wire                           sync_ready_2;
wire                           sync_ready_3;
wire                           sync_ready_4;
wire                           sync_ready_5;
wire                           sync_ready_6;
wire                           sync_ready_7;
wire                           sync_ready_8;
wire                           sync_ready_9;
wire                           sync_ready_10;
wire                           sync_ready_11;

reg [12 - 1 : 0] tracker;
reg [ 4 - 1 : 0] turn_no;

// The bit of tracker will be high only when all unique_done with same turn no asserted
generate
genvar turn_id;
	for (turn_id = 0; turn_id < 12; turn_id = turn_id + 1)
	begin : tracker_for_unique_done 
        assign tracker[turn_id] =   ((TGC_TURN_PORT_0  == turn_id) ? unique_done    : 1'b1 ) && 
                                    ((TGC_TURN_PORT_1  == turn_id) ? unique_done_1  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_2  == turn_id) ? unique_done_2  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_3  == turn_id) ? unique_done_3  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_4  == turn_id) ? unique_done_4  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_5  == turn_id) ? unique_done_5  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_6  == turn_id) ? unique_done_6  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_7  == turn_id) ? unique_done_7  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_8  == turn_id) ? unique_done_8  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_9  == turn_id) ? unique_done_9  : 1'b1 ) &&
                                    ((TGC_TURN_PORT_10 == turn_id) ? unique_done_10 : 1'b1 ) &&
                                    ((TGC_TURN_PORT_11 == turn_id) ? unique_done_11 : 1'b1 );
    end
endgenerate

// The turn no will change base on tracker (indirectly based on the test done with same turn no)
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		turn_no <= 4'b0000;
    else
        if (tracker[turn_no] == 1'b1)
            turn_no <= turn_no + 1'b1;
end

// The coordinator will only give ready to the port when its turn match with turn no
// If the port use sync ready, then it also has to wait for other port to be ready
assign coordinator_ready    = (turn_no == TGC_TURN_PORT_0)  ? ((TGC_USE_SYNC_READY_0  == 1) ? sync_ready    : unique_ready   ) : 1'b0 ;
assign coordinator_ready_1  = (turn_no == TGC_TURN_PORT_1)  ? ((TGC_USE_SYNC_READY_1  == 1) ? sync_ready_1  : unique_ready_1 ) : 1'b0 ;
assign coordinator_ready_2  = (turn_no == TGC_TURN_PORT_2)  ? ((TGC_USE_SYNC_READY_2  == 1) ? sync_ready_2  : unique_ready_2 ) : 1'b0 ;
assign coordinator_ready_3  = (turn_no == TGC_TURN_PORT_3)  ? ((TGC_USE_SYNC_READY_3  == 1) ? sync_ready_3  : unique_ready_3 ) : 1'b0 ;
assign coordinator_ready_4  = (turn_no == TGC_TURN_PORT_4)  ? ((TGC_USE_SYNC_READY_4  == 1) ? sync_ready_4  : unique_ready_4 ) : 1'b0 ;
assign coordinator_ready_5  = (turn_no == TGC_TURN_PORT_5)  ? ((TGC_USE_SYNC_READY_5  == 1) ? sync_ready_5  : unique_ready_5 ) : 1'b0 ;
assign coordinator_ready_6  = (turn_no == TGC_TURN_PORT_6)  ? ((TGC_USE_SYNC_READY_6  == 1) ? sync_ready_6  : unique_ready_6 ) : 1'b0 ;
assign coordinator_ready_7  = (turn_no == TGC_TURN_PORT_7)  ? ((TGC_USE_SYNC_READY_7  == 1) ? sync_ready_7  : unique_ready_7 ) : 1'b0 ;
assign coordinator_ready_8  = (turn_no == TGC_TURN_PORT_8)  ? ((TGC_USE_SYNC_READY_8  == 1) ? sync_ready_8  : unique_ready_8 ) : 1'b0 ;
assign coordinator_ready_9  = (turn_no == TGC_TURN_PORT_9)  ? ((TGC_USE_SYNC_READY_9  == 1) ? sync_ready_9  : unique_ready_9 ) : 1'b0 ;
assign coordinator_ready_10 = (turn_no == TGC_TURN_PORT_10) ? ((TGC_USE_SYNC_READY_10 == 1) ? sync_ready_10 : unique_ready_10) : 1'b0 ;
assign coordinator_ready_11 = (turn_no == TGC_TURN_PORT_11) ? ((TGC_USE_SYNC_READY_11 == 1) ? sync_ready_11 : unique_ready_11) : 1'b0 ;

// The sync ready will only be asserted when all port with same turn no is ready
assign sync_ready   =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_0) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_1 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_1) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_2 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_2) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_3 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_3) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_4 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_4) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_5 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_5) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_6 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_6) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_7 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_7) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_8 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_8) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_9 =   (((TGC_TURN_PORT_0  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_9) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_10 =  (((TGC_TURN_PORT_0  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_10) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );

assign sync_ready_11 =  (((TGC_TURN_PORT_0  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_0  == 1)) ? unique_ready    : 1'b1 ) &&
                        (((TGC_TURN_PORT_1  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_1  == 1)) ? unique_ready_1  : 1'b1 ) &&
                        (((TGC_TURN_PORT_2  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_2  == 1)) ? unique_ready_2  : 1'b1 ) &&
                        (((TGC_TURN_PORT_3  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_3  == 1)) ? unique_ready_3  : 1'b1 ) &&
                        (((TGC_TURN_PORT_4  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_4  == 1)) ? unique_ready_4  : 1'b1 ) &&
                        (((TGC_TURN_PORT_5  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_5  == 1)) ? unique_ready_5  : 1'b1 ) &&
                        (((TGC_TURN_PORT_6  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_6  == 1)) ? unique_ready_6  : 1'b1 ) &&
                        (((TGC_TURN_PORT_7  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_7  == 1)) ? unique_ready_7  : 1'b1 ) &&
                        (((TGC_TURN_PORT_8  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_8  == 1)) ? unique_ready_8  : 1'b1 ) &&
                        (((TGC_TURN_PORT_9  == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_9  == 1)) ? unique_ready_9  : 1'b1 ) &&
                        (((TGC_TURN_PORT_10 == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_10 == 1)) ? unique_ready_10 : 1'b1 ) &&
                        (((TGC_TURN_PORT_11 == TGC_TURN_PORT_11) && (TGC_USE_SYNC_READY_11 == 1)) ? unique_ready_11 : 1'b1 );
endmodule
