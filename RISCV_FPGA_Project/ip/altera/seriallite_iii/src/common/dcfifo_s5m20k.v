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

// baeckler - 03-08-2012

`timescale 1ps/1ps

module dcfifo_s5m20k #(
	parameter WIDTH = 96, // multiple of 32
	parameter NUM_RAMS = WIDTH / 32,
	parameter PREVENT_OVERFLOW = 1'b1,	// ignore requests that would cause overflow
	parameter PREVENT_UNDERFLOW = 1'b1,	// ignore requests that would cause underflow
	parameter FLAG_DUPES = 1, // if > 1 replicate full / empty flags for fanout balancing
	parameter ADDR_WIDTH = 5, // 4 or 5
	parameter SYNC_STAGES = 2, // meta hardening - min 2 (1 capture 1 harden)
	parameter DISABLE_WUSED = 1'b0,
	parameter DISABLE_RUSED = 1'b0	
)(
	input aclr, // no domain
	
	input wclk,
	input [WIDTH-1:0] wdata,
	input wreq,
	output [FLAG_DUPES-1:0] wfull,	// optional duplicates for loading
	output [ADDR_WIDTH-1:0] wused,
	
	input rclk,
	output [WIDTH-1:0] rdata,
	input rreq,
	output [FLAG_DUPES-1:0] rempty,	// optional duplicates for loading
	output [ADDR_WIDTH-1:0] rused,
        output [1:0] ecc_status,
	input sclr_err,
	output sticky_err	
);

localparam TARGET_CHIP = 2;

//             __    __    __    __    __    __    __
// rclk       |  |  |  |  |  |  |  |  |  |  |  |  |  |
//         ___|  |__|  |__|  |__|  |__|  |__|  |__|  |__
//                _____
// rreq          |     |
//         ______|     |________________________________
//                            _____
// rdata                     |     |
//         __________________|     |____________________

////////////////////////////////////
// resync aclr
////////////////////////////////////

wire waclr, raclr;

aclr_filter afr (
	.aclr(aclr), // no domain
	.clk(rclk),
	.aclr_sync(raclr));

aclr_filter afw (
	.aclr(aclr), // no domain
	.clk(wclk),
	.aclr_sync(waclr));

////////////////////////////////////
// addr pointers 
////////////////////////////////////

wire winc,rinc;

wire [ADDR_WIDTH-1:0] rptr;
wire [ADDR_WIDTH-1:0] wptr;
wire [ADDR_WIDTH-1:0] waddr_g;
wire [ADDR_WIDTH-1:0] raddr_g;
assign wptr = waddr_g;

generate
	if (ADDR_WIDTH == 4) begin : a4
		// gray write pointer
		gray_cntr_4_sl wcntr (
			.clk(wclk),
			.ena(winc),
			.sld(waclr),
			.cntr(waddr_g)
		);
		defparam wcntr .SLD_VAL = 4'h1;
		
		// gray read pointer
		gray_cntr_4_sl rcntr (
			.clk(rclk),
			.ena(rinc),
			.sld(raclr),
			.cntr(raddr_g)
		);
		defparam rcntr .SLD_VAL = 4'h1;
		
	end
	else begin : a5
		// gray write pointer
		gray_cntr_5_sl wcntr (
			.clk(wclk),
			.ena(winc),
			.sld(waclr),
			.cntr(waddr_g)
		);
		defparam wcntr .SLD_VAL = 5'h1;

		// gray read pointer
		gray_cntr_5_sl rcntr (
			.clk(rclk),
			.ena(rinc),
			.sld(raclr),
			.cntr(raddr_g)
		);
		defparam rcntr .SLD_VAL = 5'h1;		
	end		
endgenerate

assign rptr = raddr_g;

//////////////////////////////////////////////////
// adjust pointers for RAM latency
//////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] raddr_g_completed = {ADDR_WIDTH{1'b0}};

always @(posedge rclk or posedge raclr) begin
	if (raclr) begin
		raddr_g_completed <= {ADDR_WIDTH{1'b0}};
	end
	else begin
		if (rinc) raddr_g_completed <= rptr[ADDR_WIDTH-1:0];		
	end
end

reg [ADDR_WIDTH-1:0] waddr_g_d = {ADDR_WIDTH{1'b0}};
reg [ADDR_WIDTH-1:0] waddr_g_completed = {ADDR_WIDTH{1'b0}};

wire [ADDR_WIDTH-1:0] waddr_g_d_w = winc ? waddr_g : waddr_g_d /* synthesis keep */;

always @(posedge wclk or posedge waclr) begin
	if (waclr) begin
		waddr_g_d <= {ADDR_WIDTH{1'b0}};
		waddr_g_completed <= {ADDR_WIDTH{1'b0}};		
	end
	else begin
		waddr_g_d <= waddr_g_d_w;			
		waddr_g_completed <= waddr_g_d;
	end
end

//////////////////////////////////////////////////
// cross clock domains
//////////////////////////////////////////////////

wire [ADDR_WIDTH-1:0] rside_waddr_g_completed;
sync_regs_aclr_m2 sr0 (
	.clk(rclk),
	.aclr(raclr),
	.din(waddr_g_completed/* synthesis altera_attribute="disable_da_rule=d102" */),
	.dout(rside_waddr_g_completed)
);
defparam sr0 .WIDTH = ADDR_WIDTH;
defparam sr0 .DEPTH = SYNC_STAGES;

wire [ADDR_WIDTH-1:0] wside_raddr_g_completed;
sync_regs_aclr_m2 sr1 (
	.clk(wclk),
	.aclr(waclr),
	.din(raddr_g_completed/* synthesis altera_attribute="disable_da_rule=d102" */),
	.dout(wside_raddr_g_completed)
);
defparam sr1 .WIDTH = ADDR_WIDTH;
defparam sr1 .DEPTH = SYNC_STAGES;

//////////////////////////////////////////////////
// compare pointers
//////////////////////////////////////////////////

genvar i;
generate
	for (i=0; i<FLAG_DUPES; i=i+1) begin : fg
		//assign wfull[i] = ~|(wside_raddr_g_completed ^ waddr_g); 
		//assign rempty[i] = ~|(raddr_g_completed ^ rside_waddr_g_completed);
		
		eq_5_ena eq0 (
			.da(5'h0 | wside_raddr_g_completed),
			.db(5'h0 | waddr_g),
			.ena(1'b1),
			.eq(wfull[i])
		);
		defparam eq0 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
		
		eq_5_ena eq1 (
			.da(5'h0 | raddr_g_completed),
			.db(5'h0 | rside_waddr_g_completed),
			.ena(1'b1),
			.eq(rempty[i])
		);
		defparam eq1 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5		
	end
endgenerate

//////////////////////////////////////////////////
// storage array 
//////////////////////////////////////////////////

// aggregate the ECC flags
wire [NUM_RAMS-1:0] sticky_err_local;
reg sclr_err_local = 1'b0 /* synthesis preserve */;
reg any_err = 1'b0 /* synthesis preserve */;
always @(posedge rclk) begin
	any_err <= |sticky_err_local;
	sclr_err_local <= sclr_err;
end
assign sticky_err = any_err;

wire [NUM_RAMS-1:0] err, uncor;
assign ecc_status[0] = |err;
assign ecc_status[1] = |uncor;


generate
	for (i=0; i<NUM_RAMS; i=i+1) begin : rlp
		s5m20k_ecc_1r1w rm (
			.wclk(wclk),
			.wena(1'b1),
			.waddr(wptr),
			.wdata(wdata[(i+1)*32-1:i*32]),
			
			.rclk(rclk),
			.raddr(rptr),
			.rdata(rdata[(i+1)*32-1:i*32]),
			.sticky_err(sticky_err_local[i]),
			.sclr_err(sclr_err_local),
                        .ecc_status({err[i],uncor[i]})
		);
		defparam rm .ADDR_WIDTH = ADDR_WIDTH;
		defparam rm .DATA_WIDTH = 32;
	end
endgenerate


//////////////////////////////////////////////////
// write used words
//////////////////////////////////////////////////

generate
	if (DISABLE_WUSED) begin : nwu
		assign wused = {ADDR_WIDTH{1'b0}};
	end
	else begin : wu
	
		wire [ADDR_WIDTH-1:0] wside_raddr_b_completed_w, waddr_b_w;

		if (ADDR_WIDTH == 4) begin : wu4
			gray_to_bin_4 gtb0 (
				.gray (wside_raddr_g_completed),
				.bin (wside_raddr_b_completed_w)
			);

			gray_to_bin_4 gtb1 (
				.gray (waddr_g_d),
				.bin (waddr_b_w)
			);
		end else begin : wu5
			gray_to_bin_5 gtb0 (
				.gray (wside_raddr_g_completed),
				.bin (wside_raddr_b_completed_w)
			);

			gray_to_bin_5 gtb1 (
				.gray (waddr_g_d),
				.bin (waddr_b_w)
			);	
		end
		
		reg [ADDR_WIDTH-1:0] wside_raddr_b_completed = {ADDR_WIDTH{1'b0}};
		reg [ADDR_WIDTH-1:0] waddr_b = {ADDR_WIDTH{1'b0}};
		reg [ADDR_WIDTH-1:0] wused_r = {ADDR_WIDTH{1'b0}};

		always @(posedge wclk or posedge waclr) begin
			if (waclr) begin
				wused_r <= {ADDR_WIDTH{1'b0}};
				wside_raddr_b_completed <= {ADDR_WIDTH{1'b0}};
				waddr_b <= {ADDR_WIDTH{1'b0}};
			end
			else begin
				wused_r <= waddr_b - wside_raddr_b_completed;
				wside_raddr_b_completed <= wside_raddr_b_completed_w;
				waddr_b <= waddr_b_w;
			end
		end

		assign wused = wused_r;
	end
endgenerate

//////////////////////////////////////////////////
// read used words
//////////////////////////////////////////////////

generate
	if (DISABLE_RUSED) begin : nru
		assign rused = {ADDR_WIDTH{1'b0}};
	end
	else begin : ru
		wire [ADDR_WIDTH-1:0] rside_waddr_b_completed_w, raddr_b_completed_w;

		if (ADDR_WIDTH == 4) begin : ru4
			gray_to_bin_4 gtb2 (
				.gray (rside_waddr_g_completed),
				.bin (rside_waddr_b_completed_w)
			);

			gray_to_bin_4 gtb3 (
				.gray (raddr_g_completed),
				.bin (raddr_b_completed_w)
			);
		end else begin : ru5
			gray_to_bin_5 gtb2 (
				.gray (rside_waddr_g_completed),
				.bin (rside_waddr_b_completed_w)
			);

			gray_to_bin_5 gtb3 (
				.gray (raddr_g_completed),
				.bin (raddr_b_completed_w)
			);
		end	

		reg [ADDR_WIDTH-1:0] rside_waddr_b_completed = {ADDR_WIDTH{1'b0}};
		reg [ADDR_WIDTH-1:0] raddr_b_completed = {ADDR_WIDTH{1'b0}};
		reg [ADDR_WIDTH-1:0] rused_r = {ADDR_WIDTH{1'b0}};

		always @(posedge rclk or posedge raclr) begin
			if (raclr) begin
				rused_r <= {ADDR_WIDTH{1'b0}};
				rside_waddr_b_completed <= {ADDR_WIDTH{1'b0}};
				raddr_b_completed <= {ADDR_WIDTH{1'b0}};
			end
			else begin
				rused_r <= rside_waddr_b_completed - raddr_b_completed;
				rside_waddr_b_completed <= rside_waddr_b_completed_w;
				raddr_b_completed <= raddr_b_completed_w;
			end
		end

		assign rused = rused_r;
	end
endgenerate

////////////////////////////////////
// qualified requests
////////////////////////////////////

//assign wfull[i] = ~|(wside_raddr_g_completed ^ waddr_g); 
//assign rempty[i] = ~|(raddr_g_completed ^ rside_waddr_g_completed);
//wire winc = wreq & (~wfull[0] | ~PREVENT_OVERFLOW);
//wire rinc = rreq & (~rempty[0] | ~PREVENT_UNDERFLOW);

generate
	if (PREVENT_OVERFLOW) begin
		neq_5_ena eq2 (
			.da(5'h0 | wside_raddr_g_completed),
			.db(5'h0 | waddr_g),
			.ena(wreq),
			.eq(winc)
		);
		defparam eq2 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
	end
	else assign winc = wreq;
endgenerate
	
generate 
	if (PREVENT_UNDERFLOW) begin
		neq_5_ena eq3 (
			.da(5'h0 | raddr_g_completed),
			.db(5'h0 | rside_waddr_g_completed),
			.ena(rreq),
			.eq(rinc)
		);
		defparam eq3 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5		
	end
	else assign rinc = rreq;
endgenerate


endmodule



// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 86
// BENCHMARK INFO :  Total pins : 211
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 3,072
// BENCHMARK INFO :  Comb ALUTs :                         ; 60                  ;       ;
// BENCHMARK INFO :  ALMs : 42 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.493 ns, From gray_cntr_5_sl:a5.wcntr|rl[3].df, To gray_cntr_5_sl:a5.wcntr|rl[1].df}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.744 ns, From raddr_g_completed[0], To gray_cntr_5_sl:a5.rcntr|rl[2].df}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.727 ns, From sync_regs_aclr_m2:sr0|sync_sr[0], To gray_cntr_5_sl:a5.rcntr|rl[2].df}
