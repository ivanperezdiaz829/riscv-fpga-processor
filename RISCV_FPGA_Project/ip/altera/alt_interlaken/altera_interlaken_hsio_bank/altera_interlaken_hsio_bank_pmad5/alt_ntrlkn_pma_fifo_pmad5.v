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
// baeckler - 04-05-2011
// phase comp FIFO for PMA direct
// wrsclr will purge the FIFO then wait for some buffer before starting to read 

module alt_ntrlkn_pma_fifo_pmad5 (
	input	  wrclk,
	input	[19:0]  data,
	input    wrsclr,
	
	input	  rdclk,
	output	[19:0]  q
);

reg wrsclr_reg = 1'b0 /* synthesis preserve */;
always @(posedge wrclk) wrsclr_reg <= wrsclr;

wire aclr = wrsclr_reg;
wire  wrreq = !wrsclr_reg;
//wire wrfull;
//wire  rdempty;
wire [4:0] rdusedw;
wire rdreq;
	
	wire  sub_wire0;
	wire [19:0] sub_wire1;
	wire  sub_wire2;
	wire [4:0] sub_wire3;
//	assign wrfull = sub_wire0;
	assign q = sub_wire1[19:0];
//	assign  rdempty = sub_wire2;
	assign rdusedw = sub_wire3[4:0];

	dcfifo	dcfifo_component (
				.rdclk (rdclk),
				.wrclk (wrclk),
				.wrreq (wrreq),
				.aclr (aclr),
				.data (data),
				.rdreq (rdreq),
				.wrfull (sub_wire0),
				.q (sub_wire1),
				.rdempty (sub_wire2),
				.rdusedw (sub_wire3),
				.rdfull (),
				.wrempty (),
				.wrusedw ());
	defparam
		dcfifo_component.intended_device_family = "Stratix IV",
		dcfifo_component.lpm_numwords = 32,
		dcfifo_component.lpm_showahead = "OFF",
		dcfifo_component.lpm_type = "dcfifo",
		dcfifo_component.lpm_width = 20,
		dcfifo_component.lpm_widthu = 5,
		dcfifo_component.overflow_checking = "ON",
		dcfifo_component.rdsync_delaypipe = 4,
		dcfifo_component.underflow_checking = "ON",
		dcfifo_component.use_eab = "ON",
		dcfifo_component.write_aclr_synch = "OFF",
		dcfifo_component.wrsync_delaypipe = 4;

reg [2:0] rdside_wrsclr = 0 /* synthesis preserve */
	/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pma_fifo*rdside_wrsclr\[0\]]\" " */;
always @(posedge rdclk) begin
	rdside_wrsclr <= {rdside_wrsclr[1:0],wrsclr_reg};
end

reg read_enable = 1'b0 /* synthesis preserve */;
always @(posedge rdclk) begin
	if (rdside_wrsclr[2]) read_enable <= 1'b0;
	else if (|rdusedw[4:2]) read_enable <= 1'b1;	
end
assign rdreq = read_enable;

endmodule

