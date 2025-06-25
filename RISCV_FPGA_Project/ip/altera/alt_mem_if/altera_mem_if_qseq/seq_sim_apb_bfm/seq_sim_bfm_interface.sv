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




`define MSTR_BFM tb.dut.e0.if0.apb_bfm

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

	reg [SEQ_SIM_ADDRESS_W-1:0] command_addr;
	reg [SEQ_SIM_DATA_W-1:0] command_data;
	reg is_write;
	reg is_ready;
	reg system_ready = 0;
	reg seq_done_flag = 0;

	dut_tb tb();

	initial
	begin
		$display("[%0t] SEQ [initial]: seq_sim_apb_interface started", $time);
		$display("[%0t] SEQ [initial]: seq_sim_apb_interface waiting for BFM reset to de-assert", $time);
		wait(`MSTR_BFM.sp_reset_n == 1'b1);
		repeat (5) @(posedge `MSTR_BFM.pclk);
		$display("[%0t] SEQ [initial]: seq_sim_apb_interface starting sequencer simulator", $time);
		seq_start($time);
		$display("[%0t] SEQ [initial]: seq_sim_apb_interface sequencer simulator started", $time);
		system_ready = 1;
	end
    
	always @(posedge `MSTR_BFM.pclk && ! seq_done_flag)
	begin
		$display("[%0t] SEQ: Check for request", $time);

		if (system_ready)
		begin
			seq_get_request($time, 1, is_ready, is_write, command_addr, command_data);
		end 
		else
		begin
			is_ready = 0;
		end

		$display("[%0t] SEQ: Got request: is_ready=%s is_write=%s", 
			 $time, is_ready ? "Yes" : "No", is_write ? "Yes" : "No");

		if (is_ready)
		begin
			if (is_write) begin
				$display("[%0t] SEQ: Got write request: addr=%0h data=%0h", 
					 $time, command_addr, command_data);
				`MSTR_BFM.APB_write(command_addr, command_data);
				$display("[%0t] SEQ: write done", $time);
			end else begin
				$display("[%0t] SEQ: Got read request: addr=%0h", $time, command_addr);
				`MSTR_BFM.APB_read(command_addr, command_data);
				$display("[%0t] SEQ: read done: data=%0h", $time, command_data);
			end
			$display("[%0t] SEQ: Sending response to sequencer", $time);
			seq_send_response($time, is_write, command_addr, command_data);
			$display("[%0t] SEQ: Sending response to sequencer done", $time);
		end

		if (seq_done($time))
		begin
			$display("[%0t] SEQ: All done", $time);
			seq_done_flag = 1;
		end
	end

endmodule
