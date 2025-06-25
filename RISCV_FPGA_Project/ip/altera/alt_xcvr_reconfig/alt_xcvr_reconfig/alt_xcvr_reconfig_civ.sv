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


// Transceiver Reconfiguration Module for Cyclone IV architectures
//
// Includes the following function-specific sub-modules
//  - offset cancellation (alt_xcvr_reconfig_offset_cancellation)
//  

// $Header$

//`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_civ #(
	parameter number_of_reconfig_interfaces = 1
) (
	input  wire        reconfig_mgmt_clk_clk,                  //        mgmt_clk.clk
	input  wire        reconfig_mgmt_rst_reset,                //        mgmt_rst.reset

	// user reconfiguration management interface
	input  wire [6:0]  reconfig_mgmt_address,         //        reconfig_mgmt.address
	output reg         reconfig_mgmt_waitrequest = 0, //        .waitrequest
	input  wire        reconfig_mgmt_read,            //        .read
	output reg  [31:0] reconfig_mgmt_readdata = ~0,   //        .readdata
	input  wire        reconfig_mgmt_write,           //        .write
	input  wire [31:0] reconfig_mgmt_writedata,       //        .writedata
	output wire        reconfig_done,                 //        reconfig_done.export

	output wire [3:0]  reconfig_togxb,                //  reconfig_togxb_data.data
        input  wire [number_of_reconfig_interfaces*17 - 1 : 0] reconfig_fromgxb // dprioout, testbus from altgx : (17+4 bits/quad)
);

	// master interface to basic reconfiguration block that interfaces to the transceiver channel
	wire [4:0]  basic_address;     //   basic.address    // master interface must include 2 lower addr bits
	wire        basic_waitrequest; //        .waitrequest
	wire        basic_irq;         //        .irq
	wire        basic_read;        //        .read
	wire [31:0] basic_readdata;    //        .readdata
	wire        basic_write;       //        .write
	wire [31:0] basic_writedata;   //        .writedata
	
	// native testbus input
	wire [15:0] testbus_data;

	// Offset cancellation output ports, mgmt facing
	wire [31:0] sc_offset_readdata;
	wire  	    sc_offset_waitrequest;
        wire [number_of_reconfig_interfaces*17 - 1 : 0] l_reconfig_fromgxb; // local reconfig_fromgxb for re-mapping

	localparam l_dev_family = "Cyclone IV";
	localparam width_bwa    = 3;	// word address width of interface to basic reconfig block
	localparam arb_count    = 1;	// count of the total number of sub-components that can act
					// as slaves to the mgmt interface, and masters to the 'basic' block
	localparam arb_offset   = 0;

        ///////////////////////////////////////////////////////////////////////////////////
        // Remapping of reconfig_fromgxb from Cyclone IV GX style to Stratix IV GX style
        // - Note that CIVGX reconfig shares the same basic module as Stratix IV GX.  This
        //   requires us to remap the reconfig_fromgxb port, since it is only 5 bits per
        //   interface in Cyclone IV, but 18 bits per interface in Stratix IV.
        //   Here, we mux the appropriate values to emulative SIVGX connectivity.
        ///////////////////////////////////////////////////////////////////////////////////
        genvar i;
        generate
                for (i=0; i<number_of_reconfig_interfaces; i=i+1) begin : mux_reconfig_fromgxb
                        assign l_reconfig_fromgxb[17*i + 16:17*i] = {3'b0, reconfig_fromgxb[5*i + 4], 3'b0, reconfig_fromgxb[5*i + 3], 3'b0, reconfig_fromgxb[5*i + 2], 3'b0, reconfig_fromgxb[5*i + 1], reconfig_fromgxb[5*i]};
                end
        endgenerate


	///////////////////////////////////////////////////////////////////////
	// Decoder for multiple slaves of reconfig_mgmt interface
	///////////////////////////////////////////////////////////////////////
	wire [arb_count-1:0] r_decode;
	assign r_decode = 
		  (reconfig_mgmt_address[6:width_bwa] == arb_offset) ? (({arb_count-arb_offset{1'b0}} | 1'b1) << arb_offset)
		  : {arb_count{1'b0}};

	// reconfig_mgmt output generation is muxing of decoded slave output
	always @(*) begin
		case (reconfig_mgmt_address[6:width_bwa])
		arb_offset: begin
			reconfig_mgmt_readdata = sc_offset_readdata;
			reconfig_mgmt_waitrequest = sc_offset_waitrequest;
			end
		default: begin
			reconfig_mgmt_readdata = -1;
			reconfig_mgmt_waitrequest = 1'b0;
			end
		endcase
	end

	///////////////////////////////////////////
	// Sub-component: offset cancellation
	// word address offset: +8 (0x20 in bytes)
	///////////////////////////////////////////

	// Offset cancellation output ports:
	wire  offset_cancellation_done;

	alt_xcvr_reconfig_offset_cancellation_civ #(
		.number_of_reconfig_interfaces(number_of_reconfig_interfaces),
		.device_family(l_dev_family)
	) sc_offset (
		.reconfig_clk(reconfig_mgmt_clk_clk),
		.reset(reconfig_mgmt_rst_reset),
		// external mgmt interface facing
		.offset_cancellation_address			(reconfig_mgmt_address[0]),	// From Avalon slave uses a single address bit
		.offset_cancellation_writedata			(reconfig_mgmt_writedata),	// From Avalon to oc
		.offset_cancellation_write			(reconfig_mgmt_write & r_decode[arb_offset]), //From Avalon to oc
		.offset_cancellation_read			(reconfig_mgmt_read  & r_decode[arb_offset]), //From Avalon to oc
		.offset_cancellation_readdata			(sc_offset_readdata),			      //To Avalon from oc
		.offset_cancellation_waitrequest		(sc_offset_waitrequest),		      //To Avalon from oc
		// master-to-slave fabric facing, to basic reconfig
		.offset_cancellation_irq_from_base		(basic_irq),			//From basic_reconfig to oc				
		.offset_cancellation_waitrequest_from_base	(basic_waitrequest),	 	//From basic_reconfig to oc	
		.offset_cancellation_readdata_base		(basic_readdata),		//From basic_reconfig to oc
		.testbus_data					(testbus_data),			//From basic_reconfig to oc
		.offset_cancellation_done			(offset_cancellation_done),  	//To avalon from oc 
		.offset_cancellation_address_base		(basic_address),		//From oc to basic_reconfig
		.offset_cancellation_writedata_base		(basic_writedata),		//From oc to basic_reconfig
		.offset_cancellation_write_base			(basic_write),			//From oc to basic_reconfig
		.offset_cancellation_read_base			(basic_read)			//From oc to basic_reconfig
	);

	wire	[number_of_reconfig_interfaces*8 - 1 : 0]  aeq_fromgxb_data=0;	
	wire	[number_of_reconfig_interfaces*24 - 1 : 0] aeq_togxb_data;

	///////////////////////////////////////////
	// reconfig basic block
	// 
	///////////////////////////////////////////
	alt_xcvr_reconfig_basic_tgx  sc_basic (
		.reconfig_clk			(reconfig_mgmt_clk_clk),
		.reset				(reconfig_mgmt_rst_reset),
		.basic_reconfig_write	 	(basic_write),
		.basic_reconfig_read	 	(basic_read),
		.basic_reconfig_writedata	(basic_writedata),
		.basic_reconfig_address	 	(basic_address[4:2]), // drop the lower two address bits
		.basic_reconfig_fromgxb_data	(l_reconfig_fromgxb),
		.aeq_fromgxb_data		(aeq_fromgxb_data),
		.basic_reconfig_readdata	(basic_readdata),
		.basic_reconfig_waitrequest	(basic_waitrequest),
		.basic_reconfig_togxb_data	(reconfig_togxb),
		.aeq_togxb_data			(aeq_togxb_data),
		.testbus_data			(testbus_data),
		.basic_reconfig_irq		(basic_irq)
	);

	///////////////////////////////////////////
	// Status to external mgmt interface
	///////////////////////////////////////////
	assign reconfig_done = offset_cancellation_done ;

endmodule
