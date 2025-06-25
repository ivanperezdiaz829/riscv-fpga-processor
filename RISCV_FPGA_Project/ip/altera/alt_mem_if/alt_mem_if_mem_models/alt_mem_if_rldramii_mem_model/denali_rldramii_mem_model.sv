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

module denali_rldramii_mem_model (
    ck,
    ckbar,
    csbar,
    webar,
    refbar,
    ba,
    a,
    dq,
    qk,
    qkbar,
    qvld,
    dm,
    dk,
    dkbar,
    tck,
    tms,
    tdi,
    tdo,
    ZQ
);

parameter MEM_BANKADDR_WIDTH   	= ""; 
parameter MEM_ADDR_WIDTH       	= ""; 
parameter MEM_DM_WIDTH         	= ""; 
parameter MEM_READ_DQS_WIDTH   	= ""; 
parameter MEM_WRITE_DQS_WIDTH  	= ""; 
parameter MEM_DQ_WIDTH            	= ""; 

parameter MEM_BURST_LENGTH        	= "";

parameter ERR_INJECT	  		  	= "";
parameter ERR_INJECT_SEED		  	= "";
parameter ERR_INJECT_READS_PER_ERR	= "";
parameter ERR_INJECT_BITS		  	= "";
parameter ERR_INJECT_OCCURRENCES  	= "";

parameter memory_spec = "mt49h16m36_18.soma";
parameter init_file   = "";
parameter sim_control = "";

input ck;
input ckbar;
input csbar;
input webar;
input refbar;
input [MEM_BANKADDR_WIDTH-1:0] ba;
input [MEM_ADDR_WIDTH-1:0] a;
inout [MEM_DQ_WIDTH-1:0] dq;
output [MEM_READ_DQS_WIDTH-1:0] qk;
output [MEM_READ_DQS_WIDTH-1:0] qkbar;
output qvld;
input dm;
input [MEM_WRITE_DQS_WIDTH-1:0] dk;
input [MEM_WRITE_DQS_WIDTH-1:0] dkbar;
input tck;
input tms;
input tdi;
output tdo;
inout ZQ;

//synthesis translate_off

`ifdef USEMMAV

reg [MEM_DQ_WIDTH-1:0] den_dq;
reg [MEM_READ_DQS_WIDTH-1:0] den_qk;
reg [MEM_READ_DQS_WIDTH-1:0] den_qkbar;
reg den_qvld;
reg den_tdo;
reg den_ZQ;

`include "ddvapi.vh"

denaliMemCallback cb ();
denaliMemTrans trans ();


assign dq = den_dq;
assign qk = den_qk;
assign qkbar = den_qkbar;
assign qvld = den_qvld;
assign ZQ = den_ZQ;
assign tdo = den_tdo;


initial
    $rldram_access(ck,ckbar,csbar,webar,refbar,ba,a,dq,den_dq,den_qk,den_qkbar,den_qvld,dm,dk,dkbar,tck,tms,tdi,den_tdo,ZQ,den_ZQ);

int success;
initial begin
	success = $mmtcleval("mmsetvar OutputTiming 0");
end

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

string error_type_string;
generate
	if (ERR_INJECT == "ON") begin
		initial begin
			#32000000;
			$sformat(error_type_string, "-seed %d -reads %d -bits %d -percent %d",ERR_INJECT_SEED,ERR_INJECT_READS_PER_ERR,ERR_INJECT_BITS,ERR_INJECT_OCCURRENCES);
			$display("%s",error_type_string);
			success = $mmerrinject(mem_inst_id,"%s",error_type_string);
		end
	end
endgenerate

always @(cb.Event) begin
	while (cb.getCallback (mem_inst_id)) begin
		trans.transGet (cb.transId);
		
		if (cb.reasonStr (cb.reason) == "Read") begin
			$display("[%0t] %m: Reading data %h from address %0h", $time, trans.data[MEM_BURST_LENGTH * MEM_DQ_WIDTH - 1 : 0], trans.address[MEM_ADDR_WIDTH + MEM_BANKADDR_WIDTH - 1 : 0]);
		end
		else if (cb.reasonStr (cb.reason) == "Write") begin
			if (trans.mask == '1)
				$display("[%0t] %m: Writing data %h to address %0h", $time, trans.data[MEM_BURST_LENGTH * MEM_DQ_WIDTH - 1 : 0], trans.address[MEM_ADDR_WIDTH + MEM_BANKADDR_WIDTH - 1 : 0]);
			else
				$display("[%0t] %m: Writing data %h (mask %h) to address %0h", $time, trans.data[MEM_BURST_LENGTH * MEM_DQ_WIDTH - 1 : 0], trans.mask, trans.address[MEM_ADDR_WIDTH + MEM_BANKADDR_WIDTH - 1 : 0]);
		end
	end
end




`endif

//synthesis translate_on

endmodule
