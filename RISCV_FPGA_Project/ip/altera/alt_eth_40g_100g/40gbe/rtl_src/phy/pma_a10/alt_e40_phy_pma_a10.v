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


// Copyright 2010 Altera Corporation. All rights reserved.  
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
module alt_e40_phy_pma_a10 #(
    parameter FAKE_TX_SKEW = 1'b0,            // skew the TX data for simulation
    parameter VARIANT = 3                    // 1=>RX, 2=>TX, 3=> RX_AND_TX
)(
    input pma_arst,
    input clk_status,
    input clk_ref,
	input  pll_locked,
	input [3:0] tx_serial_clk,

    // to high speed IO pins
    input [3:0] rx_datain,
    output [3:0] tx_dataout,
    
    // debug+status (async)
    output [3:0] rx_cdr_lock,
    
    // 40 bit data words on clk_tx
    output clk_tx,
    input [1:0] err_inject,  // rising edge injects one bit error
    output tx_ready,
    input [159:0] tx_datain,
    
    // 40 bit data words on clk_rx
    output clk_rx,
    output rx_ready,
    output [159:0] rx_dataout,
	output gx_busy,
    
    // avalon_mm (on clk_status)
	input  wire [0:0]    a10_reconfig_write,       //      reconfig_avmm.write
	input  wire [0:0]    a10_reconfig_read,        //                   .read
	input  wire [11:0]   a10_reconfig_address,     //                   .address
	input  wire [31:0]   a10_reconfig_writedata,   //                   .writedata
	output wire [31:0]   a10_reconfig_readdata,    //                   .readdata
	output wire [0:0]    a10_reconfig_waitrequest  //                   .waitrequest
	
	
	
);


// clock distribution
wire [3:0] rx_coreclk;
wire [3:0] rx_clkout /* synthesis keep */;
wire [3:0] tx_coreclk;
wire [3:0] tx_clkout /* synthesis keep */;

// reset and status signals
wire [3:0] rx_is_lockedtodata;

wire [159:0] tx_datain_r;



wire [3:0] tx_analogreset;
wire [3:0] tx_digitalreset;
wire [3:0] rx_digitalreset;
wire [3:0] rx_analogreset;
wire [3:0] tx_cal_busy;
wire [3:0] rx_cal_busy;
wire [3:0] tx_ready_out;
wire [3:0] rx_ready_out;

assign gx_busy = |{tx_cal_busy,rx_cal_busy};







// select master clocks
assign clk_rx = rx_clkout[3];
assign clk_tx = tx_clkout[3];

assign rx_cdr_lock = rx_is_lockedtodata; // rx_freqlocked;






reg [1:0] err_inject_r = 2'b00;
reg [1:0] last_err_inject = 2'b00;
wire [511:0] tx_parallel_data;
wire [511:0] rx_parallel_data;

generate begin
genvar ig;
	for(ig=0;ig<4;ig=ig+1) begin  : assign_phy_port
		if (VARIANT == 2 || VARIANT == 3) begin
			assign tx_parallel_data[((128*(ig+1))-1)-:128] = {{88{1'bZ}},tx_datain_r[ig*40+:40]};
		end
		assign rx_dataout[ig*40+:40] = rx_parallel_data[ig*128+:40];
	end
end
if (VARIANT == 2 || VARIANT == 3) begin
	always @(posedge clk_tx) begin
		last_err_inject <= err_inject;
		err_inject_r <= (err_inject & ~last_err_inject);
	end
end

endgenerate	


//instantiate low latency phy
generate
if (VARIANT == 1)
begin

	alt_e40_rx_e4x10_reset gx_rx_rst (
		.clock(clk_status),              //              clock.clk
		.reset(pma_arst),              //              reset.reset
		.rx_analogreset(rx_analogreset),     //     rx_analogreset.rx_analogreset
		.rx_digitalreset(rx_digitalreset),    //    rx_digitalreset.rx_digitalreset
		.rx_ready(rx_ready_out),           //           rx_ready.rx_ready
		.rx_is_lockedtodata(rx_is_lockedtodata), // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy(rx_cal_busy)         //        rx_cal_busy.rx_cal_busy
	);
	
	alt_e40_rx_e4x10 gx_rx (
		.rx_analogreset(rx_analogreset), //input  wire [9:0]    rx_analogreset,       //     rx_analogreset.rx_analogreset
		.rx_digitalreset(rx_digitalreset), //input  wire [9:0]    rx_digitalreset,      //    rx_digitalreset.rx_digitalreset
		.rx_cal_busy(rx_cal_busy), //output wire [9:0]    rx_cal_busy,          //        rx_cal_busy.rx_cal_busy	
		.rx_cdr_refclk0(clk_ref), //input  wire          rx_cdr_refclk0,       //     rx_cdr_refclk0.clk
		.rx_serial_data(rx_datain),//rx_serial_data_t1), //input  wire [9:0]    rx_serial_data,       //     rx_serial_data.rx_serial_data
		.rx_is_lockedtoref(), //output wire [9:0]    rx_is_lockedtoref,    //  rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata(rx_is_lockedtodata), //output wire [9:0]    rx_is_lockedtodata,   // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_coreclkin(rx_coreclk),//tx_coreclkin_t1), //input  wire [9:0]    rx_coreclkin,         //       rx_coreclkin.clk		
		.rx_clkout(rx_clkout), //output wire [9:0]    rx_clkout,            //          rx_clkout.clk
		.rx_parallel_data(rx_parallel_data), //output wire [1279:0] rx_parallel_data,     //   rx_parallel_data.rx_parallel_data
		.rx_control(), //output wire [199:0]  rx_control,           //         rx_control.rx_control
		.reconfig_clk(clk_status), //input  wire [9:0]    reconfig_clk,         //       reconfig_clk.clk
		.reconfig_reset(pma_arst), //input  wire [9:0]    reconfig_reset,       //     reconfig_reset.reset
		.reconfig_write(a10_reconfig_write), //input  wire [9:0]    reconfig_write,       //      reconfig_avmm.write
		.reconfig_read(a10_reconfig_read), //input  wire [9:0]    reconfig_read,        //                   .read
		.reconfig_address(a10_reconfig_address), //input  wire [89:0]   reconfig_address,     //                   .address
		.reconfig_writedata(a10_reconfig_writedata),//input  wire [319:0]  reconfig_writedata,   //                   .writedata
		.reconfig_readdata(a10_reconfig_readdata), //output wire [319:0]  reconfig_readdata,    //                   .readdata
		.reconfig_waitrequest(a10_reconfig_waitrequest)//output wire [9:0]    reconfig_waitrequest  //                   .waitrequest
	);
	
	assign tx_ready = 1'b0;
	assign rx_ready = &rx_ready_out;
	
	assign rx_coreclk = {4{clk_rx}};
	assign tx_dataout = 4'b0;
	assign tx_cal_busy = 4'b0;
	assign tx_clkout = 4'b0;
end
else if (VARIANT == 2)
begin

alt_e40_tx_e4x10_reset gx_tx_rst (
		.clock(clk_status),              //              clock.clk
		.reset(pma_arst),              //              reset.reset
		.tx_analogreset(tx_analogreset),     //     tx_analogreset.tx_analogreset
		.tx_digitalreset(tx_digitalreset),    //    tx_digitalreset.tx_digitalreset
		.tx_ready(tx_ready_out),           //           tx_ready.tx_ready
		.pll_locked(pll_locked),         //         pll_locked.pll_locked
		.pll_select(1'b0),         //         pll_select.pll_select
		.tx_cal_busy(tx_cal_busy)        //        tx_cal_busy.tx_cal_busy
	);

alt_e40_tx_e4x10 gx_tx (
		.tx_analogreset(tx_analogreset),//input  wire [9:0]    tx_analogreset,       //     tx_analogreset.tx_analogreset
		.tx_digitalreset(tx_digitalreset),//input  wire [9:0]    tx_digitalreset,      //    tx_digitalreset.tx_digitalreset
		.tx_cal_busy(tx_cal_busy), //output wire [9:0]    tx_cal_busy,          //        tx_cal_busy.tx_cal_busy
		.tx_serial_clk0(tx_serial_clk), //input  wire [9:0]    tx_serial_clk0,       //     tx_serial_clk0.clk
		.tx_serial_data(tx_dataout), //output wire [9:0]    tx_serial_data,       //     tx_serial_data.tx_serial_data
		.tx_coreclkin(tx_coreclk),//tx_coreclkin_t1), //input  wire [9:0]    tx_coreclkin,         //       tx_coreclkin.clk
		.tx_clkout(tx_clkout), //output wire [9:0]    tx_clkout,            //          tx_clkout.clk
		.tx_parallel_data(tx_parallel_data), //input  wire [1279:0] tx_parallel_data,     //   tx_parallel_data.tx_parallel_data
		.tx_control(72'b0), //input  wire [179:0]  tx_control,           //         tx_control.tx_control
		.tx_enh_data_valid(4'b1111), //input  wire [9:0]    tx_enh_data_valid,    //  tx_enh_data_valid.tx_enh_data_valid
		.reconfig_clk(clk_status), //input  wire [9:0]    reconfig_clk,         //       reconfig_clk.clk
		.reconfig_reset(pma_arst), //input  wire [9:0]    reconfig_reset,       //     reconfig_reset.reset
		.reconfig_write(a10_reconfig_write), //input  wire [9:0]    reconfig_write,       //      reconfig_avmm.write
		.reconfig_read(a10_reconfig_read), //input  wire [9:0]    reconfig_read,        //                   .read
		.reconfig_address(a10_reconfig_address), //input  wire [89:0]   reconfig_address,     //                   .address
		.reconfig_writedata(a10_reconfig_writedata),//input  wire [319:0]  reconfig_writedata,   //                   .writedata
		.reconfig_readdata(a10_reconfig_readdata), //output wire [319:0]  reconfig_readdata,    //                   .readdata
		.reconfig_waitrequest(a10_reconfig_waitrequest)//output wire [9:0]    reconfig_waitrequest  //                   .waitrequest
	);	
	
	assign tx_ready = &tx_ready_out;
    assign tx_coreclk = {4{clk_tx}};
    assign rx_ready = 1'b0;
	assign rx_cal_busy        = 4'b0;
	assign rx_is_lockedtodata = 4'b0;
	assign rx_clkout          = 4'b0;
	assign rx_parallel_data   = 512'b0;
end
else if (VARIANT == 3)
begin

alt_e40_e4x10_reset gx_rst (
		.clock(clk_status),              //              clock.clk
		.reset(pma_arst),              //              reset.reset
		.tx_analogreset(tx_analogreset),     //     tx_analogreset.tx_analogreset
		.tx_digitalreset(tx_digitalreset),    //    tx_digitalreset.tx_digitalreset
		.tx_ready(tx_ready_out),           //           tx_ready.tx_ready
		.pll_locked(pll_locked),         //         pll_locked.pll_locked
		.pll_select(1'b0),         //         pll_select.pll_select
		.tx_cal_busy(tx_cal_busy),        //        tx_cal_busy.tx_cal_busy
		.rx_analogreset(rx_analogreset),     //     rx_analogreset.rx_analogreset
		.rx_digitalreset(rx_digitalreset),    //    rx_digitalreset.rx_digitalreset
		.rx_ready(rx_ready_out),           //           rx_ready.rx_ready
		.rx_is_lockedtodata(rx_is_lockedtodata), // rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy(rx_cal_busy)         //        rx_cal_busy.rx_cal_busy
	);

alt_e40_e4x10 gx (
		.tx_analogreset(tx_analogreset),//input  wire [9:0]    tx_analogreset,       //     tx_analogreset.tx_analogreset
		.tx_digitalreset(tx_digitalreset),//input  wire [9:0]    tx_digitalreset,      //    tx_digitalreset.tx_digitalreset
		.rx_analogreset(rx_analogreset), //input  wire [9:0]    rx_analogreset,       //     rx_analogreset.rx_analogreset
		.rx_digitalreset(rx_digitalreset), //input  wire [9:0]    rx_digitalreset,      //    rx_digitalreset.rx_digitalreset
		.tx_cal_busy(tx_cal_busy), //output wire [9:0]    tx_cal_busy,          //        tx_cal_busy.tx_cal_busy
		.rx_cal_busy(rx_cal_busy), //output wire [9:0]    rx_cal_busy,          //        rx_cal_busy.rx_cal_busy	
		.tx_serial_clk0(tx_serial_clk), //input  wire [9:0]    tx_serial_clk0,       //     tx_serial_clk0.clk
		.rx_cdr_refclk0(clk_ref), //input  wire          rx_cdr_refclk0,       //     rx_cdr_refclk0.clk
		.tx_serial_data(tx_dataout), //output wire [9:0]    tx_serial_data,       //     tx_serial_data.tx_serial_data
		.rx_serial_data(rx_datain),//rx_serial_data_t1), //input  wire [9:0]    rx_serial_data,       //     rx_serial_data.rx_serial_data
		.rx_seriallpbken(4'b0), //input  wire [9:0]    rx_seriallpbken,      //    rx_seriallpbken.rx_seriallpbken
		.rx_is_lockedtoref(), //output wire [9:0]    rx_is_lockedtoref,    //  rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata(rx_is_lockedtodata), //output wire [9:0]    rx_is_lockedtodata,   // rx_is_lockedtodata.rx_is_lockedtodata
		.tx_coreclkin(tx_coreclk),//tx_coreclkin_t1), //input  wire [9:0]    tx_coreclkin,         //       tx_coreclkin.clk
		.rx_coreclkin(rx_coreclk),//tx_coreclkin_t1), //input  wire [9:0]    rx_coreclkin,         //       rx_coreclkin.clk
		.tx_clkout(tx_clkout), //output wire [9:0]    tx_clkout,            //          tx_clkout.clk
		.rx_clkout(rx_clkout), //output wire [9:0]    rx_clkout,            //          rx_clkout.clk
		.tx_parallel_data(tx_parallel_data), //input  wire [1279:0] tx_parallel_data,     //   tx_parallel_data.tx_parallel_data
		.rx_parallel_data(rx_parallel_data), //output wire [1279:0] rx_parallel_data,     //   rx_parallel_data.rx_parallel_data
		.tx_control(72'b0), //input  wire [179:0]  tx_control,           //         tx_control.tx_control
		.rx_control(), //output wire [199:0]  rx_control,           //         rx_control.rx_control
		.tx_enh_data_valid(4'b1111), //input  wire [9:0]    tx_enh_data_valid,    //  tx_enh_data_valid.tx_enh_data_valid
		.reconfig_clk(clk_status), //input  wire [9:0]    reconfig_clk,         //       reconfig_clk.clk
		.reconfig_reset(pma_arst), //input  wire [9:0]    reconfig_reset,       //     reconfig_reset.reset
		.reconfig_write(a10_reconfig_write), //input  wire [9:0]    reconfig_write,       //      reconfig_avmm.write
		.reconfig_read(a10_reconfig_read), //input  wire [9:0]    reconfig_read,        //                   .read
		.reconfig_address(a10_reconfig_address), //input  wire [89:0]   reconfig_address,     //                   .address
		.reconfig_writedata(a10_reconfig_writedata),//input  wire [319:0]  reconfig_writedata,   //                   .writedata
		.reconfig_readdata(a10_reconfig_readdata), //output wire [319:0]  reconfig_readdata,    //                   .readdata
		.reconfig_waitrequest(a10_reconfig_waitrequest)//output wire [9:0]    reconfig_waitrequest  //                   .waitrequest
	);
	
	assign tx_ready = &tx_ready_out;
	assign rx_ready = &rx_ready_out;
	assign rx_coreclk = {4{clk_rx}};
    assign tx_coreclk = {4{clk_tx}};

end
endgenerate

localparam SKEW = 59; // bits to skew the TX's per lane pair
genvar i;
generate
	if (FAKE_TX_SKEW) begin
		// synthesis translate off
		for (i=0; i<4; i=i+1) begin : foo
			wire [39:0] tmp_in = tx_datain[(i+1)*40-1:i*40];
			reg [39+10*SKEW:0] history = 0;
			always @(posedge clk_tx) begin
				history <= (history >> 40);
				history[39+10*SKEW:10*SKEW] <= tmp_in;
			end
			wire [39:0] tmp_out = history[SKEW*i+39:SKEW*i];
			assign tx_datain_r[(i+1)*40-1:i*40] = tmp_out  ^ err_inject_r[1:0];    
		end
		// synthesis translate on
	end
	else begin
		if (VARIANT == 2 || VARIANT == 3) begin
			assign tx_datain_r = tx_datain  ^ err_inject_r[1:0];
		end
	end
endgenerate
endmodule
