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




`define MSTR_BFM tb.dut.e0.if0.s0.cpu_inst

parameter SEQ_SIM_ADDRESS_W = 32;
parameter SEQ_SIM_DATA_W = 32;

parameter SEQ_SIM_IDLE = 0;
parameter SEQ_SIM_INIT_LATENCY = 0;
parameter SEQ_SIM_BFM_TIMEOUT = 10000;

// synthesis translate_off
import "DPI-C" function void seq_start(input longint sim_time);
import "DPI-C" function void seq_get_request(input longint sim_time,
			    input bit blocking,
			    output bit request_ready,
			    output bit is_write, 
			    output bit [SEQ_SIM_ADDRESS_W-1:0] addr,
			    output bit [SEQ_SIM_DATA_W-1:0] data);
import "DPI-C" function void seq_send_response(input longint sim_time,
			    input bit is_write,
			    input bit [SEQ_SIM_ADDRESS_W-1:0] addr,
			    input bit [SEQ_SIM_DATA_W-1:0] data);
import "DPI-C" function bit seq_done(input longint sim_time);
// synthesis translate_on


module seq_sim_bfm_interface();
	import avalon_mm_pkg::*;


	Request_t command_request, response_request;
	reg [SEQ_SIM_ADDRESS_W-1:0] command_addr, response_addr;
	reg [SEQ_SIM_DATA_W-1:0] command_data, response_data;
	reg is_write;
	reg is_ready;
	reg expecting_request = 0; 
	reg seq_done_flag = 0;
	Request_t req;

	dut_tb tb();

	initial
	begin
		$display("SEQ: seq_sim_bfm_interface started");
		`MSTR_BFM.init();
		`MSTR_BFM.set_command_timeout(SEQ_SIM_BFM_TIMEOUT);
		`MSTR_BFM.set_response_timeout(SEQ_SIM_BFM_TIMEOUT);
		$display("SEQ: seq_sim_bfm_interface waiting for BFM reset to de-assert");
		wait(`MSTR_BFM.reset == 0);
		$display("SEQ: seq_sim_bfm_interface starting sequencer simulator");
		seq_start($time);
		$display("SEQ: seq_sim_bfm_interface sequencer simulator started");
		expecting_request = 1;
	end
    
	always @(posedge `MSTR_BFM.clk && ! seq_done_flag)
	begin
		while (`MSTR_BFM.get_response_queue_size() > 0)
		begin
			master_pop_and_get_response(response_request, response_addr, response_data);
			seq_send_response($time, response_request == REQ_WRITE, response_addr, response_data);
			expecting_request = 1; 
		end

		if (expecting_request)
		begin

			seq_get_request($time, expecting_request, is_ready, is_write, command_addr, command_data);

			if (is_ready)
			begin

				expecting_request = 0;
				
				if (is_write)
					req = REQ_WRITE;
				else
					req = REQ_READ;
				master_set_and_push_command(req, command_addr, command_data, SEQ_SIM_IDLE, SEQ_SIM_INIT_LATENCY);
			end
		end

		if (seq_done($time))
		begin
			$display("[%0t] SEQ: All done", $time);
			seq_done_flag = 1;
		end
	end


	task master_set_and_push_command;
		input Request_t request;
		input [SEQ_SIM_ADDRESS_W-1:0] addr;
		input [SEQ_SIM_DATA_W-1:0] data;
		input [SEQ_SIM_DATA_W-1:0] idle;
		input [31:0] init_latency;
		
		begin
			`MSTR_BFM.set_command_request(request);
			`MSTR_BFM.set_command_address(addr);    
			`MSTR_BFM.set_command_idle(idle, 0); 
			`MSTR_BFM.set_command_init_latency(init_latency);
			
			if (request == REQ_WRITE)
			begin
				`MSTR_BFM.set_command_data(data, 0); 
			end
			
			`MSTR_BFM.push_command();
		end
	endtask
  
	task master_pop_and_get_response;
		output Request_t request;
		output [SEQ_SIM_ADDRESS_W-1:0] addr;
		output [SEQ_SIM_DATA_W-1:0] data;
		
		begin
			`MSTR_BFM.pop_response();
			request = Request_t' (`MSTR_BFM.get_response_request());
			addr = `MSTR_BFM.get_response_address();
			data = `MSTR_BFM.get_response_data(0); 
		end
	endtask

endmodule
