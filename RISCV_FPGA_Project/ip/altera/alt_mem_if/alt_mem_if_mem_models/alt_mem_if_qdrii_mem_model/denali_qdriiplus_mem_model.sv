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


`timescale 1ps/1ps


module denali_qdriiplus_mem_model (
    a,
    d,
    wpsbar,
    bwsbar,
    k,
    kbar,
    q,
    rpsbar,
    cq,
    cqbar,
    doffbar,
    qvld

);

parameter MEM_ADDR_WIDTH       = ""; 
parameter MEM_DM_WIDTH         = ""; 
parameter MEM_READ_DQS_WIDTH   = ""; 
parameter MEM_WRITE_DQS_WIDTH  = ""; 
parameter MEM_DQ_WIDTH            = ""; 
parameter MEM_BURST_LENGTH        = "";
parameter MEM_CONTROL_WIDTH       = "";

parameter memory_spec = "mt49h16m36_18.soma";
parameter init_file   = "";
parameter sim_control = "";

input [MEM_ADDR_WIDTH-1:0] a;
input [MEM_DQ_WIDTH-1:0] d;
input wpsbar;
input [MEM_DM_WIDTH-1:0] bwsbar;
input [MEM_WRITE_DQS_WIDTH-1:0] k;
input [MEM_WRITE_DQS_WIDTH-1:0] kbar;
output [MEM_DQ_WIDTH-1:0] q;
input rpsbar;
output [MEM_READ_DQS_WIDTH-1:0] cq;
output [MEM_READ_DQS_WIDTH-1:0] cqbar;
output [MEM_READ_DQS_WIDTH-1:0] qvld;
input [MEM_CONTROL_WIDTH-1:0] doffbar;

//synthesis translate_off
`ifdef USEMMAV

reg [MEM_DQ_WIDTH-1:0] den_q;
reg den_cq;
reg den_cqbar;
reg [MEM_READ_DQS_WIDTH-1:0] den_qvld;

assign q = den_q;
assign cq = {MEM_READ_DQS_WIDTH{den_cq}};
assign cqbar = {MEM_READ_DQS_WIDTH{den_cqbar}};
assign qvld = den_qvld;

`include "ddvapi.vh"

denaliMemCallback cb ();
denaliMemTrans trans ();



initial
    $qdr_ssram_access(a,d,wpsbar,bwsbar,k,kbar,den_q,rpsbar,den_cq,den_cqbar,doffbar,den_qvld);

integer mem_inst_id, cb_counter;
string instance_name;

initial
begin
	$sformat(instance_name, "%m");
	mem_inst_id = $mminstanceid (instance_name);
	$display("[%0t] %m: Denali instance ID = %d", $time, mem_inst_id);

	for (cb_counter = 0; cb_counter < DENALI_CB_TOTAL; cb_counter++)
		cb.enableReason [cb_counter] = cb_counter;
	
	cb.setCallback (mem_inst_id);
	
	#10000000000000000000000;
	$finish;
end

always @(cb.Event) begin
	while (cb.getCallback (mem_inst_id)) begin
		trans.transGet (cb.transId);
		
		if (cb.reasonStr (cb.reason) == "Read") begin
			$display("[%0t] %m: Reading data %h from address %0h", $time, trans.data[MEM_BURST_LENGTH * MEM_DQ_WIDTH - 1 : 0], trans.address[MEM_ADDR_WIDTH - 1 : 0]);
		end
		else if (cb.reasonStr (cb.reason) == "Write") begin
			$display("[%0t] %m: Writing data %h to address %0h", $time, trans.data[MEM_BURST_LENGTH * MEM_DQ_WIDTH - 1 : 0], trans.address[MEM_ADDR_WIDTH - 1 : 0]);
		end
	end
end

`endif
//synthesis translate_on

endmodule
