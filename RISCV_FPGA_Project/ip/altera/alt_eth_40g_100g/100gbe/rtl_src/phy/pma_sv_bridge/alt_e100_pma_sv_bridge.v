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
// baeckler - 12-17-2009
// lanny    - 11-11-2011: reorganize, add parameter
// shane - 6-1-2012: modified for composed hw.tcl
module alt_e100_pma_sv_bridge #(
    parameter PHY_ADDR_PREFIX = 10'h001,    // 0x40-0x7f
    parameter RECO_ADDR_PREFIX = 9'h001,    // 0x80-0xff
    parameter FAKE_TX_SKEW = 1'b0,            // skew the TX data for simulation
    parameter VARIANT = 3,                    // 1=>RX, 2=>TX, 3=> RX_AND_TX
	parameter en_synce_support = 0
)(
    input pma_arst,
    input clk_status,
    input clk_ref,
	input tx_clk_ref, 
	input rx_clk_ref,

    // to high speed IO pins
    input [9:0] rx_datain,
    output [9:0] tx_dataout,
    
    // debug+status (async)
    output [2:0] tx_pll_lock,
    output [9:0] rx_cdr_lock,
    
    // 40 bit data words on clk_tx
    output clk_tx,
    input [1:0] err_inject,  // rising edge injects one bit error
    output out_tx_ready,
    input [399:0] tx_datain,
    
    // 40 bit data words on clk_rx
    output clk_rx,
    output out_rx_ready,
    output [399:0] rx_dataout,    
    
    // avalon_mm (on clk_status)
    input status_read,
    input status_write,
    input [15:0] status_addr,
    output [31:0] reco_readdata,
    output [31:0] phy_readdata,
    input [31:0] status_writedata,
    output reco_readdata_valid,
    output phy_readdata_valid,
    output out_busy,

    // additional ports for composed hw.tcl
    // gx
    output  clk_status_gx,
    output  pma_arst_gx,
    output    phy_mgmt_read, 
    output    phy_mgmt_write,
    output [8:0] phy_mgmt_address, //[10:0] 
    output [31:0] phy_mgmt_writedata,
    input    phy_mgmt_waitrequest,
    input  [31:0]  phy_mgmt_readdata,
    output   pll_inclk,
	output   cdr_ref_clk,
    input [9:0] rx_freqlocked,
    input [9:0] rx_is_lockedtodata,
    output [9:0] rx_coreclk,
    input [9:0] rx_clkout,
    input pll_locked,// reset and status signals 
    output [9:0] tx_coreclk,
    input [9:0] tx_clkout,
    output [399:0] tx_parallel_data,
    input [399:0] rx_parallel_data,
    output [9:0] rx_serial_data,
    input [9:0] tx_serial_data,
    input tx_ready,
    input rx_ready,
    // reco
    output clk_status_reco,
    output pma_arst_reco,
    input   reconfig_mgmt_waitrequest,
    output    reconfig_mgmt_read,
    output    reconfig_mgmt_write ,
    output [6:0] reconfig_mgmt_address , //[8:0]
    output [31:0] reconfig_mgmt_writedata,
    input   reconfig_busy,
    input   [31:0] reconfig_mgmt_readdata
);
reg    status_read_r;
reg    status_write_r;
reg [31:0] status_writedata_r;
reg [15:0] status_addr_r;



assign phy_readdata = phy_mgmt_readdata;

wire [399:0] tx_datain_r;
// bit error injection on the low 2 bits
reg [1:0] err_inject_r = 2'b00;

        
generate
if (VARIANT == 3)    // RX and TX
    begin
		reg [1:0] last_err_inject = 2'b00;
        // select master clocks
        assign clk_rx = rx_clkout[4];
        assign clk_tx = tx_clkout[4];
        assign rx_coreclk = {10{clk_rx}};
        assign tx_coreclk = {10{clk_tx}};

        assign rx_cdr_lock = rx_is_lockedtodata; // rx_freqlocked;
        assign tx_pll_lock = {3{pll_locked}};

        assign out_tx_ready = tx_ready; // gx
        assign out_rx_ready = rx_ready; // gx
        // bit error injection on the low 2 bits
        always @(posedge clk_tx) begin
            last_err_inject <= err_inject;
            err_inject_r <= (err_inject & ~last_err_inject);
        end
    end
else if (VARIANT == 1)    // RX
    begin
        // select master clocks
        assign clk_rx = rx_clkout[4];
        assign clk_tx = 1'b0;
        assign rx_coreclk = {10{clk_rx}};
        assign tx_coreclk = 10'b0;
 
        assign rx_cdr_lock = rx_is_lockedtodata; // rx_freqlocked;     
        assign tx_pll_lock = 3'b0;
    assign out_rx_ready = rx_ready; // gx
	assign out_tx_ready = 1'b0;
    end
else if (VARIANT == 2)    // TX
    begin
		reg [1:0] last_err_inject = 2'b00;
            // select master clocks
        assign clk_rx = 1'b0;
        assign clk_tx = tx_clkout[4];
        assign rx_coreclk = 10'b0;
        assign tx_coreclk = {10{clk_tx}};
        
        assign rx_cdr_lock = 10'b0;
        assign tx_pll_lock = {3{pll_locked}};

        // bit error injection on the low 2 bits
        always @(posedge clk_tx) begin
            last_err_inject <= err_inject;
            err_inject_r <= (err_inject & ~last_err_inject);
        end
    assign out_tx_ready = tx_ready; // gx
	assign out_rx_ready = 1'b0;
    end
	
	
	if (en_synce_support) begin
		// clock distribution
		assign pll_inclk   = tx_clk_ref;
		assign cdr_ref_clk = rx_clk_ref;	
	end
	else begin
		// clock distribution
		assign pll_inclk   = clk_ref;
		assign cdr_ref_clk = clk_ref;
	end
	
endgenerate

always @(posedge clk_status) begin
    if (pma_arst) begin
        status_read_r <= 0;
        status_write_r <= 0;
        status_writedata_r <= 32'b0;
        status_addr_r <= 16'b0;
    end
    else if( !reconfig_mgmt_waitrequest && !phy_mgmt_waitrequest) begin
        status_read_r <= status_read;
        status_write_r <= status_write;
        status_writedata_r <= status_writedata;
        status_addr_r <= status_addr;
    end
end

// gx
assign    reconfig_mgmt_read = status_read_r && (status_addr_r[15:7]==RECO_ADDR_PREFIX[8:0]);
assign    reconfig_mgmt_write = status_write_r && (status_addr_r[15:7]==RECO_ADDR_PREFIX[8:0]);
assign    reconfig_mgmt_address = (reconfig_mgmt_read || reconfig_mgmt_write) ? status_addr_r[6:0] : 7'b0;

assign    phy_mgmt_read = status_read_r && (status_addr_r[15:6]==PHY_ADDR_PREFIX[9:0]);
assign    phy_mgmt_write = status_write_r && (status_addr_r[15:6]==PHY_ADDR_PREFIX[9:0]);
assign    phy_mgmt_address = (phy_mgmt_read || phy_mgmt_write) ? {3'h1, status_addr_r[5:0]} : 9'b0;

assign    reco_readdata_valid = reconfig_mgmt_read && !reconfig_mgmt_waitrequest;
assign    phy_readdata_valid = phy_mgmt_read && !phy_mgmt_waitrequest;
// reco
assign clk_status_gx = clk_status;
assign pma_arst_gx = pma_arst;
assign phy_mgmt_writedata = status_writedata_r[31:0];
assign tx_parallel_data = tx_datain_r ^ err_inject_r[1:0];
assign tx_dataout = tx_serial_data;
assign rx_dataout = rx_parallel_data;
assign rx_serial_data = rx_datain;
assign out_busy = reconfig_busy;
assign reco_readdata = reconfig_mgmt_readdata;
assign reconfig_mgmt_writedata = status_writedata_r[31:0];
assign clk_status_reco = clk_status;
assign pma_arst_reco = pma_arst;

localparam SKEW = 59; // bits to skew the TX's per lane pair
genvar i;
generate
    if (VARIANT == 2 || VARIANT == 3)
    begin
        if (FAKE_TX_SKEW) begin
            // synthesis translate off
            for (i=0; i<10; i=i+1) begin : foo
                wire [39:0] tmp_in = tx_datain[(i+1)*40-1:i*40];
                reg [39+10*SKEW:0] history = 0;
                always @(posedge clk_tx) begin
                    history <= (history >> 40);
                    history[39+10*SKEW:10*SKEW] <= tmp_in;
                end
                wire [39:0] tmp_out = history[SKEW*i+39:SKEW*i];
                assign tx_datain_r[(i+1)*40-1:i*40] = tmp_out;    
            end
            // synthesis translate on
        end
        else begin
            assign tx_datain_r = tx_datain;
        end
    end
	else begin
		assign tx_datain_r = 400'b0;
	end
endgenerate


endmodule
