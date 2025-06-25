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

module altera_xcvr_detlatency_ph_dcfifo # (
  parameter dat_width  = 8,
  parameter addr_width = 8, // ram address width, internal width is 1 bit more
  parameter ptr_gap    = 6,
  parameter simulation = 1'b0
)(
	rst_wr,
	rst_rd,
	rd_dat,
	rd_clk,
	rd_req,
	rd_empty,
	rd_used,
	gray_rd_ptr,

	wr_dat,
	wr_clk,
	wr_req,
	wr_full,
	wr_used,
	gray_wr_ptr
);


input rst_wr,rst_rd;

output [dat_width-1:0] rd_dat;
input rd_clk, rd_req;
output rd_empty;
output [addr_width:0] rd_used;
output reg [addr_width:0] gray_rd_ptr;

input [dat_width-1:0] wr_dat;
input wr_clk,wr_req;
output wr_full;
output [addr_width:0] wr_used;
output reg [addr_width:0] gray_wr_ptr;


function [addr_width:0] gray_to_bin;
	input [addr_width:0] gray;
	integer i;
	begin
		gray_to_bin[addr_width] = gray[addr_width];
		for (i=addr_width-1; i>=0; i=i-1)
		begin: gry_to_bin
			gray_to_bin[i] = gray_to_bin[i+1] ^ gray[i];
		end
	end
endfunction

  localparam sync_stages   = 2;
  localparam sync_stages_str  = "2";  // number of sync stages specified as string (for timing constraints)
  localparam SYNC_WR_PTR_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_dcfifo*sync_gray_wr_ptr[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SYNC_RD_PTR_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_dcfifo*sync_gray_rd_ptr[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SYNC_WREN_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_dcfifo*sync_wren_a[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SDC_CONSTRAINTS = {SYNC_WR_PTR_CONSTRAINT,";",SYNC_RD_PTR_CONSTRAINT,";",SYNC_WREN_CONSTRAINT};
  localparam reg_stages = sync_stages+3;

reg [addr_width:0] rd_ptr, wr_side_gray_rd_ptr, wr_side_rd_ptr;
reg [addr_width:0] wr_ptr, rd_side_gray_wr_ptr, rd_side_wr_ptr;

  // Apply false path timing constraints to synchronization registers. (It does not matter as to which node these are applied).
  (* altera_attribute = SDC_CONSTRAINTS *)
reg [addr_width:0] sync_gray_wr_ptr [sync_stages:1];
reg [addr_width:0] sync_gray_rd_ptr [sync_stages:1];
reg [2:1] sync_wren_a;

reg [addr_width:0] rd_ptr_reg [reg_stages:1];
reg [addr_width:0] wr_ptr_reg [reg_stages:1];

wire rd_ok, wr_ok;
wire wren_a;

reg [ptr_gap-1:0] rd_req_int;
//create the gap between wr and rd ptr
integer i;
always @(posedge rd_clk or posedge rst_rd)
begin 
	if (rst_rd)
		rd_req_int <= '0;
	else
	begin
		rd_req_int[2:0] <= {3{sync_wren_a[1]}};
		for (i=ptr_gap-1; i>2;i=i-1)
			rd_req_int[i] <= rd_req_int[i-1];
	end
end

always @(posedge rd_clk or posedge rst_rd)
begin 
	if (rst_rd)
		sync_wren_a <= '0;
	else
		sync_wren_a <= {wren_a, sync_wren_a[2]};
end

	integer stage;
	always @ (posedge wr_clk)
	begin
		sync_gray_rd_ptr [sync_stages] <= gray_rd_ptr;
		
		for (stage=sync_stages;stage>1;stage=stage-1)
		begin
  		sync_gray_rd_ptr [stage-1] <= sync_gray_rd_ptr [stage];
  	end
	end

	always @ (posedge rd_clk)
	begin
		sync_gray_wr_ptr [sync_stages] <= gray_wr_ptr;
		
		for (stage=sync_stages;stage>1;stage=stage-1)
		begin
  		sync_gray_wr_ptr [stage-1] <= sync_gray_wr_ptr [stage];
  	end
	end
	
	always @ (posedge wr_clk)
	begin
		wr_ptr_reg [reg_stages] <= wr_ptr;
		
		for (stage=reg_stages;stage>1;stage=stage-1)
		begin
  		wr_ptr_reg [stage-1] <= wr_ptr_reg [stage];
  	end
	end

	always @ (posedge rd_clk)
	begin
		rd_ptr_reg [reg_stages] <= rd_ptr;
		
		for (stage=reg_stages;stage>1;stage=stage-1)
		begin
  		rd_ptr_reg [stage-1] <= rd_ptr_reg [stage];
  	end
	end
			
// read address pointer - bin and gray
always @(posedge rd_clk) begin
	if (rst_rd) begin
		rd_ptr <= 0;
		gray_rd_ptr <= 0;
	end
	else begin
		gray_rd_ptr <= rd_ptr ^ (rd_ptr >> 1'b1);
		if (rd_req & rd_req_int[ptr_gap-1] & rd_ok) rd_ptr <= rd_ptr + 1'b1;
	end
end

// write address pointer - bin and gray
always @(posedge wr_clk) begin
	if (rst_wr) begin
		wr_ptr <= 0;
		gray_wr_ptr <= 0;
	end
	else begin
		gray_wr_ptr <= wr_ptr ^ (wr_ptr >> 1'b1);
		if (wr_req & wr_ok) wr_ptr <= wr_ptr + 1'b1;
	end
end

// read pointer crossing to write side
always @(posedge wr_clk) begin
	if (rst_wr) begin
		wr_side_gray_rd_ptr <= 0;
		wr_side_rd_ptr <= 0;
	end
	else begin
		wr_side_gray_rd_ptr <= sync_gray_rd_ptr[1];	
		wr_side_rd_ptr <= gray_to_bin (wr_side_gray_rd_ptr);
	end
end

// write pointer crossing to read side
always @(posedge rd_clk) begin
	if (rst_rd) begin
		rd_side_gray_wr_ptr <= 0;
		rd_side_wr_ptr <= 0;
	end
	else begin
		rd_side_gray_wr_ptr <= sync_gray_wr_ptr[1];	
		rd_side_wr_ptr <= gray_to_bin (rd_side_gray_wr_ptr);
	end
end

// Full / Empty / Overflow controls
// note used words can be 1 bit wider than address
reg [addr_width:0] rd_used, wr_used;

assign rd_ok = rd_side_wr_ptr != rd_ptr;

always @(posedge rd_clk) begin
	if (rst_rd) begin
		rd_used <= 0;
	end
	else begin
		rd_used <= rd_side_wr_ptr - rd_ptr_reg[1];
	end
end

assign wr_ok = ((wr_side_rd_ptr[addr_width-1:0] != wr_ptr[addr_width-1:0]) ||
			(wr_side_rd_ptr[addr_width] == wr_ptr[addr_width]))
			& !rst_wr;

always @(posedge wr_clk) begin
	if (rst_wr) begin
		wr_used <= 0;
	end
	else begin
		wr_used <= wr_ptr_reg[1] - wr_side_rd_ptr;
	end
end
assign wren_a =wr_req & wr_ok;
assign wr_full = !wr_ok;
assign rd_empty = !rd_ok; 

// RAM storage
wire wr_ena = 1'b1;
wire rd_ena = (rd_req & rd_req_int[ptr_gap-1] & rd_ok) | rst_rd;
generate
	if (!simulation) begin
		wire [dat_width-1:0] unreg_rd_dat;
		altsyncram	#(
			.address_reg_b("CLOCK1"),
			.clock_enable_input_a("NORMAL"),
			.clock_enable_input_b("NORMAL"),
			.clock_enable_output_a("BYPASS"),
			.clock_enable_output_b("BYPASS"),
			.intended_device_family("Arria V"),
			.lpm_type("altsyncram"),
			.numwords_a(1'b1 << addr_width),
			.numwords_b(1'b1 << addr_width),
			.operation_mode("DUAL_PORT"),
			.outdata_aclr_b("NONE"),
			.outdata_reg_b("UNREGISTERED"),
			.power_up_uninitialized("FALSE"),
			.read_during_write_mode_mixed_ports("DONT_CARE"),
			.widthad_a(addr_width),
			.widthad_b(addr_width),
			.width_a(dat_width),
			.width_b(dat_width),
			.width_byteena_a(1)
		) altsyncram_component (
			.wren_a (wren_a),
			.clock0 (wr_clk),
			.clock1 (rd_clk),
			.address_a (wr_ptr[addr_width-1:0]),
			.address_b (rd_ptr[addr_width-1:0] + (rst_rd ? 1'b0 : 1'b1)),
			.data_a (wr_dat),
			.q_b (unreg_rd_dat),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.addressstall_a (1'b0),
			.addressstall_b (!rd_ena),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clocken0 (wr_ena),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_b ({dat_width{1'b1}}),
			.eccstatus (),
			.q_a (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_b (1'b0)
		);
		
		// Note : The actual memory read occurs shortly
		// after the read address registers are loaded.  It
		// is latched internally and NOT refreshed.
		// Therefore read from X, wait, write to X, wait, finish read
		// yields the OLD value of X.   This is using external
		// output registers and address stall to get at the refreshed 
		// data.   

		reg [dat_width-1:0] q;
		always @(posedge rd_clk) begin
			if (rd_ena) begin
				q <= unreg_rd_dat;
			end
		end
		assign rd_dat = q;	

	end
	else begin
		// simulation RAM model
		reg  [dat_width-1:0] store [0:(1<<addr_width)-1];
		reg [addr_width-1:0] rdaddr,wraddr;
		reg [dat_width-1:0] q,wrdata;
		reg wr;

		initial begin
			rdaddr <= 0;
			wraddr <= 0;
			q <= 0;
			wr <= 0;
		end
		
		always @(posedge wr_clk) begin
			wraddr <= wr_ptr[addr_width-1:0];
			wrdata <= wr_dat;
			if (wr_req & wr_ok) begin
				wr <= 1'b1;
			end	
			else wr <= 1'b0;	
		end
		
		always @(negedge wr_clk) begin
			if (wr) begin
				store[wraddr] <= wrdata; 
			end
		end

		always @(posedge rd_clk) begin
			if (rd_ena) begin
				rdaddr <= rd_ptr[addr_width-1:0] + (rst_rd ? 1'b0 : 1'b1);
				q <= store [rdaddr];
			end
		end				

		assign rd_dat = q;
	end
endgenerate

endmodule

