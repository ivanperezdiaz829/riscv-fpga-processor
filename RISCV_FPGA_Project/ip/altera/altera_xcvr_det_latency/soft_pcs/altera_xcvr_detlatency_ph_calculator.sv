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

`define FIFO_SAMPLE_SIZE_WIDTH 8
`define FIFO_PH_MEASURE_ACC 32

module altera_xcvr_detlatency_ph_calculator # (
  parameter data_width  = 80,
  parameter addr_width  = 4
) (
  input                         rd_clk,
  input                         wr_clk,
  input                         calc_clk,
  input                         rst,
  input          [addr_width:0] rd_ptr,
  input          [addr_width:0] wr_ptr,
  input      [`FIFO_SAMPLE_SIZE_WIDTH-1:0] fifo_sample_size, //63 or 127
  output logic  [`FIFO_PH_MEASURE_ACC-1:0] phase_measure_acc,
  output logic                  ph_acc_valid               
);
   
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
  localparam SYNC_WR_PTR_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_calculator*sync_wr_ptr[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SYNC_RD_PTR_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_calculator*sync_rd_ptr[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SYNC_SAMPLE_SIZE_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *top_pcs_ch_inst*altera_xcvr_detlatency_ph_calculator*sync_sample_size[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SDC_CONSTRAINTS = {SYNC_WR_PTR_CONSTRAINT,";",SYNC_RD_PTR_CONSTRAINT,";",SYNC_SAMPLE_SIZE_CONSTRAINT};
	
	reg                [addr_width:0] sub;
	reg            [addr_width+8-1:0] accum;
	reg [`FIFO_SAMPLE_SIZE_WIDTH-1:0] cnt;

  // Apply false path timing constraints
  (* altera_attribute = SDC_CONSTRAINTS *)
	reg                [addr_width:0] sync_wr_ptr [sync_stages:1];
	reg                [addr_width:0] sync_rd_ptr [sync_stages:1];
	reg [`FIFO_SAMPLE_SIZE_WIDTH-1:0] sync_sample_size [sync_stages:1];
	
	integer stage;
	always @ (posedge calc_clk)
	begin
		sync_wr_ptr [sync_stages] <= wr_ptr;
		sync_rd_ptr [sync_stages] <= rd_ptr;
		sync_sample_size [sync_stages] <= fifo_sample_size;
		
		for (stage=sync_stages;stage>1;stage=stage-1)
		begin
  		sync_wr_ptr [stage-1] <= sync_wr_ptr [stage];
  		sync_rd_ptr [stage-1] <= sync_rd_ptr [stage];
  		sync_sample_size [stage-1] <= sync_sample_size [stage];
  	end
	end
	
  always @ (posedge calc_clk)
	begin
  	sub     <= gray_to_bin(sync_wr_ptr[1])-gray_to_bin(sync_rd_ptr[1]);
	end
	
  always @ (posedge calc_clk or posedge rst)
	begin
	  if (rst)
	  begin
	    cnt     <= '0;
	    accum   <= '0;
	    phase_measure_acc   <= '0;
	    ph_acc_valid <= '0;
	  end
	  else
	  begin
	    if (cnt == sync_sample_size[1]) // after taking cnt+1 samples
	    begin
	      cnt   <= 'd1;
	      accum <= sub;
	      phase_measure_acc <= accum;
		    ph_acc_valid <= '1;
	    end
	    else
	    begin
	      cnt   <= cnt+1'b1;
	      accum <= accum+sub;
	      phase_measure_acc <= phase_measure_acc;
		    ph_acc_valid <= '0;
	    end
	  end
	end
endmodule