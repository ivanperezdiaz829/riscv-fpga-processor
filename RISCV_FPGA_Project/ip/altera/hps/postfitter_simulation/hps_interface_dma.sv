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


module cyclonev_hps_interface_dma (
	input  wire	channel0_req,
	input  wire	channel0_single,
	output wire	channel0_xx_ack,
	input  wire	channel1_req,
	input  wire	channel1_single,
	output wire	channel1_xx_ack,
	input  wire	channel2_req,
	input  wire	channel2_single,
	output wire	channel2_xx_ack,	
	input  wire	channel3_req,
	input  wire	channel3_single,
	output wire	channel3_xx_ack,	
	input  wire	channel4_req,
	input  wire	channel4_single,
	output wire	channel4_xx_ack,
	input  wire	channel5_req,
	input  wire	channel5_single,
	output wire	channel5_xx_ack,
	input  wire	channel6_req,
	input  wire	channel6_single,
	output wire	channel6_xx_ack,
	input  wire	channel7_req,
	input  wire	channel7_single,
	output wire	channel7_xx_ack
);

	dma_channel0_bfm f2h_dma_req0 (
		.sig_channel0_req(channel0_req),
		.sig_channel0_single(channel0_single),
		.sig_channel0_xx_ack(channel0_xx_ack)
	);
	
	dma_channel1_bfm f2h_dma_req1 (
		.sig_channel1_req(channel1_req),
		.sig_channel1_single(channel1_single),
		.sig_channel1_xx_ack(channel1_xx_ack)
	);
	
	dma_channel2_bfm f2h_dma_req2 (
		.sig_channel2_req(channel2_req),
		.sig_channel2_single(channel2_single),
		.sig_channel2_xx_ack(channel2_xx_ack)
	);
	
	dma_channel3_bfm f2h_dma_req3 (
		.sig_channel3_req(channel3_req),
		.sig_channel3_single(channel3_single),
		.sig_channel3_xx_ack(channel3_xx_ack)
	);
	
	dma_channel4_bfm f2h_dma_req4 (
		.sig_channel4_req(channel4_req),
		.sig_channel4_single(channel4_single),
		.sig_channel4_xx_ack(channel4_xx_ack)
	);
	
	dma_channel5_bfm f2h_dma_req5 (
		.sig_channel5_req(channel5_req),
		.sig_channel5_single(channel5_single),
		.sig_channel5_xx_ack(channel5_xx_ack)
	);
	
	dma_channel6_bfm f2h_dma_req6 (
		.sig_channel6_req(channel6_req),
		.sig_channel6_single(channel6_single),
		.sig_channel6_xx_ack(channel6_xx_ack)
	);
	
	dma_channel7_bfm f2h_dma_req7 (
		.sig_channel7_req(channel7_req),
		.sig_channel7_single(channel7_single),
		.sig_channel7_xx_ack(channel7_xx_ack)
	);
	
endmodule 

module arriav_hps_interface_dma (
	input  wire	channel0_req,
	input  wire	channel0_single,
	output wire	channel0_xx_ack,
	input  wire	channel1_req,
	input  wire	channel1_single,
	output wire	channel1_xx_ack,
	input  wire	channel2_req,
	input  wire	channel2_single,
	output wire	channel2_xx_ack,	
	input  wire	channel3_req,
	input  wire	channel3_single,
	output wire	channel3_xx_ack,	
	input  wire	channel4_req,
	input  wire	channel4_single,
	output wire	channel4_xx_ack,
	input  wire	channel5_req,
	input  wire	channel5_single,
	output wire	channel5_xx_ack,
	input  wire	channel6_req,
	input  wire	channel6_single,
	output wire	channel6_xx_ack,
	input  wire	channel7_req,
	input  wire	channel7_single,
	output wire	channel7_xx_ack
);

	dma_channel0_bfm f2h_dma_req0 (
		.sig_channel0_req(channel0_req),
		.sig_channel0_single(channel0_single),
		.sig_channel0_xx_ack(channel0_xx_ack)
	);
	
	dma_channel1_bfm f2h_dma_req1 (
		.sig_channel1_req(channel1_req),
		.sig_channel1_single(channel1_single),
		.sig_channel1_xx_ack(channel1_xx_ack)
	);
	
	dma_channel2_bfm f2h_dma_req2 (
		.sig_channel2_req(channel2_req),
		.sig_channel2_single(channel2_single),
		.sig_channel2_xx_ack(channel2_xx_ack)
	);
	
	dma_channel3_bfm f2h_dma_req3 (
		.sig_channel3_req(channel3_req),
		.sig_channel3_single(channel3_single),
		.sig_channel3_xx_ack(channel3_xx_ack)
	);
	
	dma_channel4_bfm f2h_dma_req4 (
		.sig_channel4_req(channel4_req),
		.sig_channel4_single(channel4_single),
		.sig_channel4_xx_ack(channel4_xx_ack)
	);
	
	dma_channel5_bfm f2h_dma_req5 (
		.sig_channel5_req(channel5_req),
		.sig_channel5_single(channel5_single),
		.sig_channel5_xx_ack(channel5_xx_ack)
	);
	
	dma_channel6_bfm f2h_dma_req6 (
		.sig_channel6_req(channel6_req),
		.sig_channel6_single(channel6_single),
		.sig_channel6_xx_ack(channel6_xx_ack)
	);
	
	dma_channel7_bfm f2h_dma_req7 (
		.sig_channel7_req(channel7_req),
		.sig_channel7_single(channel7_single),
		.sig_channel7_xx_ack(channel7_xx_ack)
	);
	
endmodule 
