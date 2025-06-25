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
//
module alt_e40_phy_pma_siv #(
    parameter SIM_FAST_RESET = 1'b0,        // accelerate reset schedule for simulation
    parameter FAKE_TX_SKEW = 1'b0,          // skew the TX data for simulation
    parameter VARIANT = 2,                   // 1=>RX, 2=>TX, 3=> RX_AND_TX
	parameter en_synce_support = 0
)(
    input pma_arst,
    input clk_status,
    input clk_ref,
	input rx_clk_ref,
	input tx_clk_ref,

    // to high speed IO pins
    input [3:0] rx_datain,
    output [3:0] tx_dataout,
    
    // debug+status (async) 
    input loopback,  // TX to RX serial loopback
    output tx_pll_lock,
    output [3:0] rx_cdr_lock,
            
    // phase comp FIFO errors (on clk_status)
    output tx_phase_err,
    output rx_phase_err,
    
    // 40 bit data words on clk_tx
    output clk_tx,
    input [1:0] err_inject,  // rising edge injects one bit error
    output tx_ready,
    input [40*4-1:0] tx_datain,
    
    // 40 bit data words on clk_rx
    output clk_rx,
    output rx_ready,
    output [40*4-1:0] rx_dataout,    
    
    // analog reconfig (on clk_status)
    input [1:0] logical_channel_address,
    input read,
    input write_all,
    output busy,
    output data_valid,
    input [24:0] analog_params_in,
    output [24:0] analog_params_out
);

localparam NUM_PHYS_LANES = 4;

// clock distribution
wire cal_blk_clk = clk_status;
wire pll_inclk;
wire reconfig_clk = clk_status;
wire [NUM_PHYS_LANES-1:0] rx_cruclk;
wire [NUM_PHYS_LANES-1:0] rx_coreclk;
wire [NUM_PHYS_LANES-1:0] tx_coreclk;
wire [NUM_PHYS_LANES-1:0] rx_clkout /* synthesis keep */;
wire [NUM_PHYS_LANES-1:0] tx_clkout /* synthesis keep */;

// debug serial loopback
wire [NUM_PHYS_LANES-1:0] rx_seriallpbken;
wire [NUM_PHYS_LANES-1:0] rx_seriallpbkin;
wire [NUM_PHYS_LANES-1:0] tx_seriallpbkout;

// reset and status signals
wire pll_powerdown;
wire [NUM_PHYS_LANES-1:0]  rx_analogreset;
wire [NUM_PHYS_LANES-1:0]  rx_digitalreset;
wire [NUM_PHYS_LANES-1:0]  tx_digitalreset;
wire pll_locked;
wire [NUM_PHYS_LANES-1:0]  rx_freqlocked;
wire rd0_ready;
wire rd1_ready;
wire rd2_ready;
wire rd3_ready;
wire rd4_ready;

wire [NUM_PHYS_LANES*40-1:0] tx_datain_r;



// FIFO phase comp monitoring
reg phase_err_ack = 1'b0;

// bit error injection on the low 2 bits
reg [1:0] err_inject_r = 2'b00;
reg [1:0] last_err_inject = 2'b00;
reg rx_phase_err_r = 1'b1 /* synthesis preserve */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *pma*rx_phase_err_r] -to [get_keepers *pma*rx_phase_err_r]\" " */;
reg tx_phase_err_r = 1'b1 /* synthesis preserve */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_fanins -async *pma*tx_phase_err_r] -to [get_keepers *pma*tx_phase_err_r]\" " */;

reg ack_wait = 1'b0;

generate
if (VARIANT == 3)    // RX and TX
    begin

		
		wire [NUM_PHYS_LANES-1:0] rx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
		wire rx_phase_err_a = |rx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;

        // clock distribution
        assign rx_coreclk = {NUM_PHYS_LANES{clk_rx}};
        assign tx_coreclk = {NUM_PHYS_LANES{clk_tx}};
        // select master clocks
        assign clk_rx = rx_clkout[2];
        assign clk_tx = tx_clkout[2];
		
		assign pll_powerdown = rd0_ready ^ 1'b1;
		wire [NUM_PHYS_LANES-1:0] tx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
		wire tx_phase_err_a = |tx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
		

		if (en_synce_support) begin
			assign pll_inclk = tx_clk_ref;
			assign rx_cruclk = {NUM_PHYS_LANES{rx_clk_ref}};		
		end
		else begin
			assign pll_inclk = clk_ref;
			assign rx_cruclk = {NUM_PHYS_LANES{clk_ref}};
		end
        assign tx_digitalreset = {NUM_PHYS_LANES{rd2_ready ^ 1'b1}};
        // debug serial loopback
        assign rx_seriallpbken = {NUM_PHYS_LANES{loopback}};
        assign rx_analogreset = {NUM_PHYS_LANES{rd3_ready ^ 1'b1}};
        assign rx_cdr_lock = rx_freqlocked;
        assign tx_pll_lock = pll_locked;
        assign rx_digitalreset = {NUM_PHYS_LANES{rd4_ready ^ 1'b1}};
        always @(posedge clk_status or posedge rx_phase_err_a) begin
            if (rx_phase_err_a) rx_phase_err_r <= 1'b1;
            else begin
                if (phase_err_ack) rx_phase_err_r <= 1'b0;
            end
        end
        assign rx_phase_err = rx_phase_err_r;

        always @(posedge clk_status or posedge tx_phase_err_a) begin
            if (tx_phase_err_a) tx_phase_err_r <= 1'b1;
            else begin
                if (phase_err_ack) tx_phase_err_r <= 1'b0;
            end
        end
        assign tx_phase_err = tx_phase_err_r;

        // stretch the pulse slightly then acknowledge
        always @(posedge clk_status) begin
            ack_wait <= (tx_phase_err_r | rx_phase_err_r);
            phase_err_ack <= ack_wait;
        end
        
        // bit error injection on the low 2 bits
        always @(posedge clk_tx) begin
            last_err_inject <= err_inject;
            err_inject_r <= (err_inject & ~last_err_inject);
        end
    end
else if (VARIANT == 1)    // RX
    begin
		wire [NUM_PHYS_LANES-1:0] rx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
		wire rx_phase_err_a = |rx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
        // clock distribution
        assign rx_cruclk = {NUM_PHYS_LANES{clk_ref}};
        assign rx_coreclk = {NUM_PHYS_LANES{clk_rx}};
        // select master clocks
        assign clk_rx = rx_clkout[2];
        assign clk_tx = 1'b0;
		assign tx_dataout = 4'b0;
		assign tx_phase_err = 1'b0;
        assign rx_analogreset = {NUM_PHYS_LANES{rd3_ready ^ 1'b1}};        
        assign rx_cdr_lock = rx_freqlocked;
        assign tx_pll_lock = 1'b0;
        assign pll_locked = 1'b1;	// otherwise rx_analog_reset will stuck @ 1 in RX_ONLY variant
        assign rx_digitalreset = {NUM_PHYS_LANES{rd4_ready ^ 1'b1}};		  
        always @(posedge clk_status or posedge rx_phase_err_a) begin
            if (rx_phase_err_a) rx_phase_err_r <= 1'b1;
            else begin
                if (phase_err_ack) rx_phase_err_r <= 1'b0;
            end
        end
        assign rx_phase_err = rx_phase_err_r;

        // stretch the pulse slightly then acknowledge
        always @(posedge clk_status) begin
            ack_wait <= rx_phase_err_r;
            phase_err_ack <= ack_wait;
        end
    end
else if (VARIANT == 2)    // TX
    begin
		wire [NUM_PHYS_LANES-1:0] tx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
		wire tx_phase_err_a = |tx_phase_comp_fifo_error /* synthesis keep altera_attribute="disable_da_rule=r101" */;
        // clock distribution
        assign tx_coreclk = {NUM_PHYS_LANES{clk_tx}};
        // select master clocks
        assign clk_rx = 1'b0;
        assign clk_tx = tx_clkout[2];
        assign pll_powerdown = rd0_ready ^ 1'b1;        
        assign rx_cdr_lock = 4'b0;
        assign tx_pll_lock = pll_locked;
		assign tx_digitalreset = {NUM_PHYS_LANES{rd2_ready ^ 1'b1}};
		assign pll_inclk = clk_ref;
		assign rx_dataout = 160'b0;
		assign rx_phase_err = 1'b0;
        
        always @(posedge clk_status or posedge tx_phase_err_a) begin
            if (tx_phase_err_a) tx_phase_err_r <= 1'b1;
            else begin
                if (phase_err_ack) tx_phase_err_r <= 1'b0;
            end
        end
        assign tx_phase_err = tx_phase_err_r;

        // stretch the pulse slightly then acknowledge
        always @(posedge clk_status) begin
            ack_wait <= tx_phase_err_r;
            phase_err_ack <= ack_wait;
        end
        
        // bit error injection on the low 2 bits
        always @(posedge clk_tx) begin
            last_err_inject <= err_inject;
            err_inject_r <= (err_inject & ~last_err_inject);
        end
    end
endgenerate


// reco signals
wire [3:0]  reconfig_togxb;
wire [16:0]  reconfig_fromgxb;

generate
if (VARIANT == 1)
begin
    alt_e40_rx_e4x10 gx_rx (
        .cal_blk_clk(cal_blk_clk),
        .reconfig_clk(reconfig_clk),
        .reconfig_togxb(reconfig_togxb),
        .rx_analogreset(rx_analogreset),
        .rx_coreclk(rx_coreclk),
        .rx_cruclk(rx_cruclk),
        .rx_datain(rx_datain),
        .rx_digitalreset(rx_digitalreset),
        .reconfig_fromgxb(reconfig_fromgxb),
        .rx_clkout(rx_clkout),
        .rx_dataout(rx_dataout),
        .rx_freqlocked(rx_freqlocked),
        .rx_phase_comp_fifo_error(rx_phase_comp_fifo_error)
    );
end
else if (VARIANT == 2)
begin
    alt_e40_tx_e4x10 gx_tx (
        .cal_blk_clk(cal_blk_clk),
        .pll_inclk(pll_inclk),
        .pll_powerdown(pll_powerdown),
        .reconfig_clk(reconfig_clk),
        .reconfig_togxb(reconfig_togxb),
        .tx_coreclk(tx_coreclk),
        .tx_datain(tx_datain_r ^ err_inject_r),
        .tx_digitalreset(tx_digitalreset),
        .pll_locked(pll_locked),
        .reconfig_fromgxb(reconfig_fromgxb),
        .tx_clkout(tx_clkout),
        .tx_dataout(tx_dataout),
        .tx_phase_comp_fifo_error(tx_phase_comp_fifo_error)
    );
end
else if (VARIANT == 3)
begin
    alt_e40_e4x10 gx (
        .cal_blk_clk(cal_blk_clk),
        .pll_inclk(pll_inclk),
        .pll_powerdown(pll_powerdown),
        .reconfig_clk(reconfig_clk),
        .reconfig_togxb(reconfig_togxb),
        .rx_analogreset(rx_analogreset),
        .rx_coreclk(rx_coreclk),
        .rx_cruclk(rx_cruclk),
        .rx_datain(rx_datain),
        .rx_digitalreset(rx_digitalreset),
        .rx_seriallpbken(rx_seriallpbken),
        .tx_coreclk(tx_coreclk),
        .tx_datain(tx_datain_r ^ err_inject_r),
        .tx_digitalreset(tx_digitalreset),
        .pll_locked(pll_locked),
        .reconfig_fromgxb(reconfig_fromgxb),
        .rx_clkout(rx_clkout),
        .rx_dataout(rx_dataout),
        .rx_freqlocked(rx_freqlocked),
        .tx_clkout(tx_clkout),
        .tx_dataout(tx_dataout),
        .rx_phase_comp_fifo_error(rx_phase_comp_fifo_error),
        .tx_phase_comp_fifo_error(tx_phase_comp_fifo_error)    
    );
end
endgenerate

wire [3:0] rx_eqctrl;
wire [2:0] rx_eqdcgain;
wire [4:0] tx_preemp_0t;
wire [4:0] tx_preemp_1t;
wire [4:0] tx_preemp_2t;
wire [2:0] tx_vodctrl;
assign {rx_eqctrl, rx_eqdcgain, 
        tx_preemp_0t, tx_preemp_1t, tx_preemp_2t,
        tx_vodctrl} = analog_params_in;

wire [3:0]  rx_eqctrl_out;
wire [2:0]  rx_eqdcgain_out;
wire [4:0]  tx_preemp_0t_out;
wire [4:0]  tx_preemp_1t_out;
wire [4:0]  tx_preemp_2t_out;
wire [2:0]  tx_vodctrl_out;
assign analog_params_out = {rx_eqctrl_out, rx_eqdcgain_out, 
            tx_preemp_0t_out, tx_preemp_1t_out, tx_preemp_2t_out,
            tx_vodctrl_out};

alt_e40_e_reco rc (
    .logical_channel_address(logical_channel_address),
    .read(read),
    .reconfig_clk(reconfig_clk),
    .reconfig_fromgxb(reconfig_fromgxb),
    .rx_eqctrl(rx_eqctrl),
    .rx_eqdcgain(rx_eqdcgain),
    .tx_preemp_0t(tx_preemp_0t),
    .tx_preemp_1t(tx_preemp_1t),
    .tx_preemp_2t(tx_preemp_2t),
    .tx_vodctrl(tx_vodctrl),
    .write_all(write_all),
    .busy(busy),
    .data_valid(data_valid),
    .reconfig_togxb(reconfig_togxb),
    .rx_eqctrl_out(rx_eqctrl_out),
    .rx_eqdcgain_out(rx_eqdcgain_out),
    .tx_preemp_0t_out(tx_preemp_0t_out),
    .tx_preemp_1t_out(tx_preemp_1t_out),
    .tx_preemp_2t_out(tx_preemp_2t_out),
    .tx_vodctrl_out(tx_vodctrl_out)
);

// regulate the delay between reset activities.
// 2 ^ N
localparam CNTR_BITS = SIM_FAST_RESET ? 6 : 20;

// start with PLL powerdown

alt_e40_reset_delay rd0 (
    .clk(clk_status),
    .ready_in(~pma_arst),
    .ready_out(rd0_ready)
);
defparam rd0 .CNTR_BITS = CNTR_BITS;


// Waitfor pll_locked

alt_e40_reset_delay rd1 (
    .clk(clk_status),
    .ready_in(rd0_ready & (&pll_locked)),
    .ready_out(rd1_ready)
);
defparam rd1 .CNTR_BITS = CNTR_BITS;

// release TX digital reset

alt_e40_reset_delay rd2 (
    .clk(clk_status),
    .ready_in(rd1_ready),
    .ready_out(rd2_ready)
);
defparam rd2 .CNTR_BITS = CNTR_BITS;


// TX is ready now - move to tx domain
reg [3:0] tx_sync = 0 /* synthesis preserve */
    /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pma*tx_sync\[0\]]\" " */;

assign tx_ready = tx_sync[3];
always @(posedge clk_tx) begin
    tx_sync <= {tx_sync[2:0],rd2_ready};
end

//  waitfor RX calibration not busy - release RX analog reset

alt_e40_reset_delay rd3 (
    .clk(clk_status),
    .ready_in(rd2_ready & !busy),
    .ready_out(rd3_ready)
);
defparam rd3 .CNTR_BITS = CNTR_BITS;


// waitfor RX freq locks - release RX digital reset

alt_e40_reset_delay rd4 (
    .clk(clk_status),
    .ready_in(rd3_ready & (&rx_cdr_lock)),
    .ready_out(rd4_ready)
);
defparam rd4 .CNTR_BITS = CNTR_BITS;


// RX is ready now - move to rx domain
reg [3:0] rx_sync = 0 /* synthesis preserve */
    /* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -to [get_keepers *pma*rx_sync\[0\]]\" " */;

assign rx_ready = rx_sync[3];
always @(posedge clk_rx) begin
    rx_sync <= {rx_sync[2:0],rd4_ready};
end

localparam SKEW = 59; // bits to skew the TX's per lane pair
genvar i;
generate
    if (VARIANT == 2 || VARIANT == 3)
    begin
        if (FAKE_TX_SKEW) begin
            // synthesis translate off
            for (i=0; i<NUM_PHYS_LANES; i=i+1) begin : foo
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
endgenerate


endmodule
