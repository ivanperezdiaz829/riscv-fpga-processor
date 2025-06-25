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


// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
// baeckler - 03-08-2012

module s5m20k_ecc_1r1w #(
	parameter ADDR_WIDTH = 9,  // natural 9 
	parameter DATA_WIDTH = 32  // Caution : this interacts with the ECC May be unchangable?
)(
	input wclk,
	input wena,
	input [ADDR_WIDTH-1:0] waddr,
	input [DATA_WIDTH-1:0] wdata,
	
	input rclk,
	input [ADDR_WIDTH-1:0] raddr,
	output [DATA_WIDTH-1:0] rdata,
        output [1:0] ecc_status,
	output sticky_err,
	input sclr_err			
);

wire err,uncor;
assign ecc_status = {err,uncor};

altsyncram    altsyncram_component (
            .address_a (waddr),
            .clock0 (wclk),
            .data_a (wdata),
            .wren_a (wena),
            .address_b (raddr),
            .clock1 (rclk),
            .eccstatus ({err,uncor}),
            .q_b (rdata),
            .aclr0 (1'b0),
            .aclr1 (1'b0),
            .addressstall_a (1'b0),
            .addressstall_b (1'b0),
            .byteena_a (1'b1),
            .byteena_b (1'b1),
            .clocken0 (1'b1),
            .clocken1 (1'b1),
            .clocken2 (1'b1),
            .clocken3 (1'b1),
            .data_b ({32{1'b1}}),
            .q_a (),
            .rden_a (1'b1),
            .rden_b (1'b1),
            .wren_b (1'b0));
defparam
    altsyncram_component.address_aclr_b = "NONE",
    altsyncram_component.address_reg_b = "CLOCK1",
    altsyncram_component.clock_enable_input_a = "BYPASS",
    altsyncram_component.clock_enable_input_b = "BYPASS",
    altsyncram_component.clock_enable_output_b = "BYPASS",
    
    // this really is required for respectable Q speed with ECC
    altsyncram_component.ecc_pipeline_stage_enabled = "TRUE",
    
    altsyncram_component.enable_ecc = "TRUE",
    altsyncram_component.intended_device_family = "Stratix V",
    altsyncram_component.lpm_type = "altsyncram",
    altsyncram_component.numwords_a = 1 << ADDR_WIDTH,
    altsyncram_component.numwords_b = 1 << ADDR_WIDTH,
    altsyncram_component.operation_mode = "DUAL_PORT",
    altsyncram_component.outdata_aclr_b = "NONE",
    altsyncram_component.outdata_reg_b = "CLOCK1",
    altsyncram_component.power_up_uninitialized = "FALSE",
    altsyncram_component.ram_block_type = "M20K",
    altsyncram_component.widthad_a = ADDR_WIDTH,
    altsyncram_component.widthad_b = ADDR_WIDTH,
    altsyncram_component.width_a = DATA_WIDTH,
    altsyncram_component.width_b = DATA_WIDTH,
    altsyncram_component.width_byteena_a = 1,
    altsyncram_component.width_eccstatus = 2;
   
reg sticky_err_r = 1'b0 /* synthesis preserve */;
always @(posedge rclk) begin
	if (sclr_err) sticky_err_r <= 1'b0;
	else if (err || uncor) sticky_err_r <= 1'b1;
end	
assign sticky_err = sticky_err_r;

endmodule
    
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 1
// BENCHMARK INFO :  Total pins : 87
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 16,384
// BENCHMARK INFO :  Comb ALUTs :                         ; 2                   ;       ;
// BENCHMARK INFO :  ALMs : 1 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.479 ns, From altsyncram:altsyncram_component|altsyncram_aj72:auto_generated|eccstatus[1], To sticky_err_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.470 ns, From altsyncram:altsyncram_component|altsyncram_aj72:auto_generated|eccstatus[1], To sticky_err_r}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.469 ns, From altsyncram:altsyncram_component|altsyncram_aj72:auto_generated|eccstatus[1], To sticky_err_r}
