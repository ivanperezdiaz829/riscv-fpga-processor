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
// This is the main state machine of the QDR II/II+ Memory Controller.  It
// accepts user requests from the Avalon interface and issues memory commands
// while satisfying timing requirements.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_qdr_fsm_fr_bl4 (
	clk,
	reset_n,
	init_complete,
	init_fail,
	write_req,
	read_req,
	do_write,
	do_read
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input clk;
input reset_n;

// PHY initialization and calibration status
input init_complete;
input init_fail;

// User memory requests
input write_req;
input read_req;

// State machine command outputs
output do_write;
output do_read;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// FSM states
enum int unsigned {
	INIT,
	INIT_FAIL,
	IDLE,
	WRITE,
	READ
} state;


reg do_write;
reg do_read;


always_ff @(posedge clk, negedge reset_n)
begin
	if (!reset_n)
		begin
			state <= INIT;
		end
	else
		case(state)
			INIT :
				if (init_complete == 1'b1)
					state <= IDLE;
				else if (init_fail == 1'b1)
					state <= INIT_FAIL;
				else
					state <= INIT;
			INIT_FAIL :
				state <= INIT_FAIL;
			default :
				if (do_write)
					state <= WRITE;
				else if (do_read)
					state <= READ;
				else
					state <= IDLE;
		endcase
end

always_ff @(state or write_req or read_req)
begin
	do_read <= 1'b0;
	do_write <= 1'b0;
	case(state)
		IDLE:
			if (write_req)
				do_write <= 1'b1;
			else if (read_req)
				do_read <= 1'b1;
		WRITE:
			if (read_req)
				do_read <= 1'b1;
		READ:
			if (write_req)
				do_write <= 1'b1;
		default:
			; 
	endcase
end


endmodule

