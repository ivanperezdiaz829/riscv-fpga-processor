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



`timescale 1 ps / 1 ps
module alt_e100_jtag_term_master (
	input clk,
	input arst,
	
	output [15:0] mm_addr,
	output mm_read,
	output mm_write,
	output [31:0] mm_writedata,
	
	input [31:0] mm_readdata,
	input mm_readdata_valid
);

////////////////////////////////////////////
// JTAG byte streams to and from host PC
////////////////////////////////////////////

wire [7:0] dat_from_host,dat_to_host;
wire dat_from_host_valid,dat_to_host_valid,dat_to_host_ready;
alt_e100_jtag_to_c_probe jp
(
	/*
	// Hub sign
	.raw_tck(0),	// input
	.tdi(0),		// input
	.usr1(0),	// input
	.clrn(1),	// input
	.ena(0),		// input
	.ir_in(0),	// input
	.tdo(),		// output
	.ir_out(),	// output
	.jtag_state_cdr(0),	// input
	.jtag_state_sdr(0),	// input
	.jtag_state_udr(0),	// input
	*/

	// internal sigs
	// data to and from host PC
	.core_clock(clk),
	
	.dat_from_host(dat_from_host),
	.dat_from_host_ready(1'b1),
	.dat_from_host_valid(dat_from_host_valid),
	
	.dat_to_host(dat_to_host),
	.dat_to_host_valid(dat_to_host_valid),
	.dat_to_host_ready(dat_to_host_ready)	
);
defparam jp .DAT_WIDTH = 8;
defparam jp .NODE_ID = 8'h31;

reg [15:0] bytes_from_host,bytes_to_host;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		bytes_from_host <= 0;
		bytes_to_host <= 0;		
	end
	else begin
		if (dat_from_host_valid) bytes_from_host <= bytes_from_host + 1'b1;
		if (dat_to_host_ready & dat_to_host_valid) bytes_to_host <= bytes_to_host + 1'b1;		
	end
end

////////////////////////////////////////////
// combine to 9 byte messages
////////////////////////////////////////////

reg msg_from_host_valid;
reg [71:0] msg_from_host;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		msg_from_host_valid <= 1'b0;
		msg_from_host <= 0;
	end
	else begin
		msg_from_host_valid <= 1'b0;
		if (dat_from_host_valid) begin
			msg_from_host <= (msg_from_host << 8) | dat_from_host;
			if (~|dat_from_host) msg_from_host_valid <= 1'b1;
		end
	end
end

reg [71:0] msg_to_host,next_msg_to_host;
reg [8:0] msg_to_host_valid;
reg next_msg_to_host_valid;
wire next_msg_to_host_ready = !dat_to_host_valid;
assign dat_to_host_valid = msg_to_host_valid[8];
assign dat_to_host = msg_to_host[71:64];

always @(posedge clk or posedge arst) begin
	if (arst) begin
		msg_to_host <= 0;
		msg_to_host_valid <= 0;
	end
	else begin
		if (dat_to_host_valid) begin
			if (dat_to_host_ready) begin
				msg_to_host <= (msg_to_host << 8);
				msg_to_host_valid <= (msg_to_host_valid << 1);
			end
		end
		
		if (next_msg_to_host_ready & next_msg_to_host_valid) begin
			msg_to_host <= next_msg_to_host;
			msg_to_host_valid <= 9'h1ff;		
		end
	end
end

////////////////////////////////////////////
// decode msgs from host
////////////////////////////////////////////

// look at the upper 8 bytes of the message
wire [7:0] is_hex,is_alnum;	
wire [4*8-1:0] nybble;

genvar i;
generate
	for (i=0; i<8; i=i+1) begin : cnv
		alt_e100_char_type ct (
			.char_in(msg_from_host[(i+1)*8-1+8:i*8+8]),
			.is_hex(is_hex[i]),
			.is_alnum(is_alnum[i]),
			.nybble(nybble[(i+1)*4-1:i*4])	
		);
	end
endgenerate

reg msg_soundoff, msg_read, msg_write, msg_damaged, rd_addr_ok, wr_check_ok;
reg [31:0] hex_val, last_hex_val;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		msg_soundoff <= 0;
		msg_read <= 0;
		msg_write <= 0;
		msg_damaged <= 0;
		rd_addr_ok <= 0;
		hex_val <= 0;
		last_hex_val <= 0;
		wr_check_ok <= 0;		
	end
	else begin
		msg_soundoff <= (msg_from_host[71:8] == "soundoff");
		msg_read <= (msg_from_host[71:40] == "rdrd");
		msg_write <= (msg_from_host[71:56] == "wr");		
		msg_damaged <= ~&is_alnum;
		rd_addr_ok <= &is_hex[3:0];
		hex_val <= nybble[31:0];
		last_hex_val <= hex_val;		
		wr_check_ok <= &is_hex[5:4];
	end
end

////////////////////////////////////////////
// message control
////////////////////////////////////////////

reg [3:0] state /* synthesis preserve */;

localparam ST_IDLE = 4'd0,
		ST_MSG_CHECK = 4'd1,
		ST_SOUNDOFF = 4'd2,
		ST_READ = 4'd3,
		ST_READING = 4'd4,
		ST_READ_REPLY = 4'd5,
		ST_WRITE = 4'd6,
		ST_WRITE_DATA = 4'd7,
		ST_WRITE_DATA2 = 4'd8,
		ST_WRITE_VERIFY = 4'd9,
		ST_WRITE_EXEC = 4'd10,
		ST_FINISH = 4'd11;
		
reg start_read;
reg [15:0] addr;
reg [31:0] read_value;
reg [63:0] read_value_hex;
wire read_complete;

reg write_ena;
reg [7:0] write_check;
reg [31:0] write_data;

// write integrity check
reg write_ok;
always @(posedge clk or posedge arst) begin
	if (arst) write_ok <= 1'b0;
	else begin
		write_ok <= &(write_data[31:24] ^ write_data[23:16] ^ write_data [15:8] ^ 
			write_data [7:0] ^ addr [15:8] ^ addr [7:0] ^ write_check);
	end
end

always @(posedge clk or posedge arst) begin
	if (arst) begin
		state <= ST_IDLE;
		next_msg_to_host <= 0;
		next_msg_to_host_valid <= 0;
		write_ena <= 1'b0;
		addr <= 0;
		write_check <= 0;
		write_data <= 0;
		write_ena <= 0;
		start_read <= 0;
	end
	else begin
		if (next_msg_to_host_valid & next_msg_to_host_ready) begin
			next_msg_to_host_valid <= 1'b0;
		end
		
		write_ena <= 1'b0;
		start_read <= 1'b0;
		
		case (state) 
			ST_IDLE : begin
				if (msg_from_host_valid) state <= ST_MSG_CHECK;
			end
			ST_MSG_CHECK : begin
				if (msg_damaged) state <= ST_IDLE;
				else if (msg_soundoff) state <= ST_SOUNDOFF;
				else if (msg_read & rd_addr_ok) state <= ST_READ;
				else if (msg_write & wr_check_ok) state <= ST_WRITE;
				else state <= ST_IDLE;
			end
			ST_SOUNDOFF : begin
				next_msg_to_host <= {"One Two ",8'h0};
				next_msg_to_host_valid <= 1'b1;				
				state <= ST_FINISH;
			end			
			ST_READ : begin
				addr <= last_hex_val[15:0];
				start_read <= 1'b1;
				state <= ST_READING;			
			end
			ST_READING : begin
				if (read_complete) state <= ST_READ_REPLY;
			end
			ST_READ_REPLY : begin
				next_msg_to_host <= {read_value_hex,8'h0};
				next_msg_to_host_valid <= 1'b1;				
				state <= ST_FINISH;
			end
			ST_WRITE : begin
				addr <= last_hex_val[15:0];
				write_check <= last_hex_val[23:16];
				state <= ST_WRITE_DATA;			
			end
			ST_WRITE_DATA : begin
				if (msg_from_host_valid) state <= ST_WRITE_DATA2;
			end
			ST_WRITE_DATA2 : begin
				write_data <= hex_val;				
				state <= ST_WRITE_VERIFY;
			end
			ST_WRITE_VERIFY : begin
				// let the data parity check run
				state <= ST_WRITE_EXEC;
			end
			ST_WRITE_EXEC : begin
				if (write_ok) write_ena <= 1'b1;
				state <= ST_IDLE;	
			end						
			ST_FINISH : begin
				if (!next_msg_to_host_valid) state <= ST_IDLE;
			end
			default : state <= ST_IDLE;
		endcase			
	end
end

assign mm_addr = addr;
assign mm_read = start_read;
assign mm_write = write_ena;
assign mm_writedata = write_data;
	
wire [63:0] read_value_hex_w;
alt_e100_bin_to_asc_hex bah (
	//.in(read_value),	// LEDA
	//.out(read_value_hex_w)	// LEDA
	.bin_in(read_value),
	.asc_out(read_value_hex_w)
);
defparam bah .WIDTH = 32;

reg [3:0] read_progress;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		read_value <= 0;
		read_value_hex <= 0;
		read_progress <= 1'b0;
	end
	else begin
		if (mm_readdata_valid) read_value <= mm_readdata;
		read_value_hex <= read_value_hex_w;
		read_progress <= {read_progress[2:0],mm_readdata_valid};
	end
end
assign read_complete = read_progress[3];

endmodule
