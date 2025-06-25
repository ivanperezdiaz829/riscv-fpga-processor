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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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


///////////////////////////////////////////////////////////////////////////////
//
//
// Description: Hard xaui control and status registers
//
// Authors:     ishimony    12-Jun-2009
//
//              Copyright (c) Altera Corporation 1997 - 2009
//              All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////

//
// TBD: unless synthesis is smart enough all synchronization flops will have
//      to be manually instantiated (altera_std_synchronizer)
//

`timescale 1 ps / 1 ps

module hxaui_csr(
    clk, reset, address, byteenable, read, readdata, write, writedata, 
    rx_patterndetect, rx_syncstatus, rx_runningdisp, rx_errdetect, 
    rx_disperr, rx_phase_comp_fifo_error, rx_rlv, rx_rmfifodatadeleted, 
    rx_rmfifodatainserted, rx_rmfifoempty, rx_rmfifofull, 
    tx_phase_comp_fifo_error, r_rx_invpolarity, r_tx_invpolarity,
    r_rx_digitalreset, r_tx_digitalreset, simulation_flag
); // module hxaui_csr
import hxaui_csr_h::*;

// ports -------------------------------------------------------------------

// Avalon MM slave
input         clk;
input         reset;

input [4:0]   address;
input [3:0]   byteenable;

input         read;
output [31:0] readdata;

input         write;
input [31:0]  writedata;

// hard xaui control/status
input   [7:0] rx_patterndetect;
input   [7:0] rx_syncstatus;
input   [7:0] rx_runningdisp;                   // nc

input   [7:0] rx_errdetect;
input   [7:0] rx_disperr;

input   [3:0] rx_phase_comp_fifo_error;
input   [3:0] rx_rlv;

input   [7:0] rx_rmfifodatadeleted;
input   [7:0] rx_rmfifodatainserted;
input   [3:0] rx_rmfifoempty;
input   [3:0] rx_rmfifofull;

input   [3:0] tx_phase_comp_fifo_error;

output  [3:0] r_rx_invpolarity;
output  [3:0] r_tx_invpolarity;
output        r_rx_digitalreset;
output        r_tx_digitalreset;

output        simulation_flag;     // '1' shortens reset and loss_timer length

// ports -------------------------------------------------------------------
wire          clk;
wire          reset;
wire    [4:0] address;
wire    [6:0] addr;
wire    [3:0] byteenable;
wire          read;
reg    [31:0] readdata;
wire          write;
wire   [31:0] writedata;
wire    [3:0] rx_phase_comp_fifo_error;
wire    [3:0] rx_rlv;
wire    [3:0] rx_rmfifoempty;
wire    [3:0] rx_rmfifofull;
wire    [3:0] tx_phase_comp_fifo_error;
wire    [7:0] rx_disperr;
wire    [7:0] rx_errdetect;
wire    [7:0] rx_patterndetect;
wire    [7:0] rx_rmfifodatadeleted;
wire    [7:0] rx_rmfifodatainserted;
wire    [7:0] rx_runningdisp;
wire    [7:0] rx_syncstatus;
wire    [3:0] r_rx_invpolarity;
wire    [3:0] r_tx_invpolarity;
wire          r_rx_digitalreset;
wire          r_tx_digitalreset;
wire          simulation_flag;

// locals ------------------------------------------------------------------
reg     [1:0] hxaui_csr_reset, hxaui_csr_reset0q;
reg     [3:0] hxaui_csr_rx_cntrl, hxaui_csr_rx_cntrl0q;
reg     [3:0] hxaui_csr_tx_cntrl, hxaui_csr_tx_cntrl0q;
wire   [31:0] hxaui_csr_rx_status_0;
wire   [31:0] hxaui_csr_rx_status_1;
wire   [31:0] hxaui_csr_rx_status_2;
wire   [31:0] hxaui_csr_rx_status_3;
wire   [31:0] hxaui_csr_rx_status_4;
wire   [31:0] hxaui_csr_tx_status_0;
reg           hxaui_csr_simulation_flag, hxaui_csr_simulation_flag0q;


reg     [7:0] rx_patterndetect_c;  // rx_patterndetect synced to clk
reg     [7:0] rx_syncstatus_c;     // rx_syncstatus    synced to clk
reg     [7:0] rx_patterndetect_sr; // rx_patterndetect sr ff
reg     [7:0] rx_syncstatus_sr;    // rx_syncstatus    sr ff
wire          read_rx_status_0;

reg     [7:0] rx_errdetect_c;      // rx_errdetect synced to clk
reg     [7:0] rx_disperr_c;        // rx_disperr   synced to clk
reg     [7:0] rx_errdetect_sr;     // rx_errdetect sr ff
reg     [7:0] rx_disperr_sr;       // rx_disperr   sr ff
wire          read_rx_status_1;

reg     [3:0] rx_phase_comp_fifo_error_c;  // rx_phase_comp_fifo_error synced
reg     [3:0] rx_rlv_c;                    // rx_rlv synced to clk
reg     [3:0] rx_phase_comp_fifo_error_sr; // rx_phase_comp_fifo_error sr ff
reg     [3:0] rx_rlv_sr;                   // rx_rlv sr ff
wire          read_rx_status_2;

reg     [7:0] rx_rmfifodatainserted_c; // rx_rmfifodatainserted synced to clk
reg     [7:0] rx_rmfifodatadeleted_c;   // rx_rmfifodatadeleted   synced to clk
reg     [7:0] rx_rmfifodatainserted_sr;// rx_rmfifodatainserted sr ff
reg     [7:0] rx_rmfifodatadeleted_sr;  // rx_rmfifodatadeleted   sr ff
wire          read_rx_status_3;

reg     [3:0] rx_rmfifofull_c;   // rx_rmfifo_full synced
reg     [3:0] rx_rmfifoempty_c;  // rx_rmfifoempty synced to clk
reg     [3:0] rx_rmfifofull_sr;  // rx_rmfifo_full sr ff
reg     [3:0] rx_rmfifoempty_sr; // rx_rmfifoempty sr ff
wire          read_rx_status_4;

wire          read_rx_status_5;

reg     [3:0] tx_phase_comp_fifo_error_c;  // tx_phase_comp_fifo_error synced
reg     [3:0] tx_phase_comp_fifo_error_sr; // tx_phase_comp_fifo_error sr ff
wire          read_tx_status_0;

// body --------------------------------------------------------------------

//--- readdata output latch ---
// For easier address debug shift back 2 bits
assign addr = {address[4:0], 2'b00};

always @(*) begin
  case (addr)
    HXAUI_CSR_RESET_ADDR:     
      readdata <= hxaui_csr_reset0q;
    HXAUI_CSR_RX_CNTRL_ADDR:
      readdata <= hxaui_csr_rx_cntrl0q;
    HXAUI_CSR_TX_CNTRL_ADDR:
      readdata <= hxaui_csr_tx_cntrl0q;
    HXAUI_CSR_RX_STATUS_0_ADDR:
      readdata <= hxaui_csr_rx_status_0;
    HXAUI_CSR_RX_STATUS_1_ADDR:
      readdata <= hxaui_csr_rx_status_1;
    HXAUI_CSR_RX_STATUS_2_ADDR:
      readdata <= hxaui_csr_rx_status_2;
    HXAUI_CSR_RX_STATUS_3_ADDR:
      readdata <= hxaui_csr_rx_status_3;
    HXAUI_CSR_RX_STATUS_4_ADDR:
      readdata <= hxaui_csr_rx_status_4;
    HXAUI_CSR_TX_STATUS_0_ADDR:
      readdata <= hxaui_csr_tx_status_0;
    HXAUI_CSR_SIMULATION_FLAG_ADDR:
      readdata <= hxaui_csr_simulation_flag0q;
    default: 
      readdata <= 32'h0;
  endcase // case (addr)
end

always @ (posedge clk or posedge reset) begin
  if (reset) begin
    hxaui_csr_reset0q           <= 2'b0;
    hxaui_csr_rx_cntrl0q        <= 4'b0;
    hxaui_csr_tx_cntrl0q        <= 4'b0;
    hxaui_csr_simulation_flag0q <= 1'b0;
  end else begin
    hxaui_csr_reset0q           <= hxaui_csr_reset;
    hxaui_csr_rx_cntrl0q        <= hxaui_csr_rx_cntrl;
    hxaui_csr_tx_cntrl0q        <= hxaui_csr_tx_cntrl;
    hxaui_csr_simulation_flag0q <= hxaui_csr_simulation_flag;
  end
end


always @ (*) begin
  hxaui_csr_reset           = hxaui_csr_reset0q;
  hxaui_csr_rx_cntrl        = hxaui_csr_rx_cntrl0q;
  hxaui_csr_tx_cntrl        = hxaui_csr_tx_cntrl0q;
  hxaui_csr_simulation_flag = hxaui_csr_simulation_flag0q;
  if (write) begin
    case (addr)
      HXAUI_CSR_RESET_ADDR:
        hxaui_csr_reset = writedata[1:0];
      HXAUI_CSR_RX_CNTRL_ADDR:
        hxaui_csr_rx_cntrl = writedata[3:0];
      HXAUI_CSR_TX_CNTRL_ADDR:
        hxaui_csr_tx_cntrl = writedata[3:0];
      HXAUI_CSR_SIMULATION_FLAG_ADDR:
        hxaui_csr_simulation_flag = writedata[0];
      default:;
    endcase // case (addr)
  end
end

assign {r_rx_digitalreset, r_tx_digitalreset} = hxaui_csr_reset0q[1:0];
assign r_rx_invpolarity[3:0] = hxaui_csr_rx_cntrl0q[3:0];
assign r_tx_invpolarity[3:0] = hxaui_csr_tx_cntrl0q[3:0];
assign simulation_flag       = hxaui_csr_simulation_flag0q;

//--- rx_status_0 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
//always @ (posedge clk) begin
//    rx_patterndetect_c <= rx_patterndetect;
//    rx_syncstatus_c    <= rx_syncstatus;
//end

// Replace above single re-sync flop with standard alt_xcvr_resync module
      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (8),
          .INIT_VALUE (0)
      ) resync_rx_syncstatus (
        .clk    (clk              ),
        .reset  (reset            ),
        .d      (rx_syncstatus),
        .q      (rx_syncstatus_c)
      );

      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (8),
          .INIT_VALUE (0)
      ) resync_rx_patterndetect (
        .clk    (clk              ),
        .reset  (reset            ),
        .d      (rx_patterndetect),
        .q      (rx_patterndetect_c)
      );


assign read_rx_status_0 = read && (addr == HXAUI_CSR_RX_STATUS_0_ADDR);

// sticky bits implementation -
//   set:   status signal
//   reset: read from register
// Set has precedence over reset
//
//  s r q   nq
// ------------
//  0 0 x   q
//  0 1 x   0
//  1 x x   1
//
//  nq <= s + qr'
//

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_patterndetect_sr <= 8'h0;
        rx_syncstatus_sr    <= 8'h0;
    end else begin
        rx_patterndetect_sr <= rx_patterndetect_c |
                               (rx_patterndetect_sr & {8{read_rx_status_0}});
        rx_syncstatus_sr    <= rx_syncstatus_c |
                               (rx_syncstatus_sr    & {8{read_rx_status_0}});
    end
end

assign hxaui_csr_rx_status_0 = {rx_patterndetect_sr, rx_syncstatus_sr};

//--- rx_status_1 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
//always @ (posedge clk) begin
//    rx_errdetect_c <= rx_errdetect;
//    rx_disperr_c    <= rx_disperr;
//end
// Replace above single re-sync flop with standard alt_xcvr_resync module
      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (8),
          .INIT_VALUE (0)
      ) resync_rx_disperr  (
        .clk    (clk              ),
        .reset  (reset            ),
        .d      (rx_disperr),
        .q      (rx_disperr_c)
      );

      alt_xcvr_resync #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (8),
          .INIT_VALUE (0)
      ) resync_rx_errdetect  (
        .clk    (clk              ),
        .reset  (reset            ),
        .d      (rx_errdetect),
        .q      (rx_errdetect_c)
      );

assign read_rx_status_1 = read && (addr == HXAUI_CSR_RX_STATUS_1_ADDR);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_errdetect_sr <= 8'h0;
        rx_disperr_sr   <= 8'h0;
    end else begin
        rx_errdetect_sr <= rx_errdetect_c |
                           (rx_errdetect_sr & {8{read_rx_status_1}});
        rx_disperr_sr   <= rx_disperr_c |
                           (rx_disperr_sr   & {8{read_rx_status_1}});
    end
end

assign hxaui_csr_rx_status_1 = {rx_errdetect_sr, rx_disperr_sr};

//--- rx_status_2 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
always @ (posedge clk) begin
    rx_phase_comp_fifo_error_c <= rx_phase_comp_fifo_error;
    rx_rlv_c                   <= rx_rlv;
end

assign read_rx_status_2 = read && (addr == HXAUI_CSR_RX_STATUS_2_ADDR);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_phase_comp_fifo_error_sr <= 4'h0;
        rx_rlv_sr                   <= 4'h0;
    end else begin
        rx_phase_comp_fifo_error_sr <= rx_phase_comp_fifo_error_c |
            (rx_phase_comp_fifo_error_sr & {4{read_rx_status_2}});
        rx_rlv_sr   <= rx_rlv_c | 
            (rx_rlv_sr & {4{read_rx_status_2}});
    end
end

assign hxaui_csr_rx_status_2 = {rx_phase_comp_fifo_error_sr, rx_rlv_sr};

//--- rx_status_3 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
always @ (posedge clk) begin
    rx_rmfifodatainserted_c <= rx_rmfifodatainserted;
    rx_rmfifodatadeleted_c  <= rx_rmfifodatadeleted;
end

assign read_rx_status_3 = read && (addr == HXAUI_CSR_RX_STATUS_3_ADDR);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_rmfifodatainserted_sr  <= 8'h0;
        rx_rmfifodatadeleted_sr   <= 8'h0;
    end else begin
        rx_rmfifodatainserted_sr <= rx_rmfifodatainserted_c |
                           (rx_rmfifodatainserted_sr & {8{read_rx_status_3}});
        rx_rmfifodatadeleted_sr   <= rx_rmfifodatadeleted_c |
                           (rx_rmfifodatadeleted_sr   & {8{read_rx_status_3}});
    end
end

assign hxaui_csr_rx_status_3 = {rx_rmfifodatainserted_sr, 
                                    rx_rmfifodatadeleted_sr};

//--- rx_status_4 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
always @ (posedge clk) begin
    rx_rmfifoempty_c <= rx_rmfifoempty;
    rx_rmfifofull_c  <= rx_rmfifofull;
end

assign read_rx_status_4 = read && (addr == HXAUI_CSR_RX_STATUS_4_ADDR);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_rmfifoempty_sr <= 4'h0;
        rx_rmfifofull_sr  <= 4'h0;
    end else begin
        rx_rmfifoempty_sr <= rx_rmfifoempty_c |
            (rx_rmfifoempty_sr & {4{read_rx_status_4}});
        rx_rmfifofull_sr  <= rx_rmfifofull_c | 
                             (rx_rmfifofull_sr & {4{read_rx_status_4}});
    end
end

assign hxaui_csr_rx_status_4 = {rx_rmfifoempty_sr, rx_rmfifofull_sr};

//--- tx_status_0 register: sticky - set by status, clear by read  ---
// The events latched are asynchronous to the Avalon clk, hence the user should
// not assume that all the bits are set at the same time.

// synchronize status signal to 'clk'
always @ (posedge clk) begin
    tx_phase_comp_fifo_error_c <= tx_phase_comp_fifo_error;
end

assign read_tx_status_0 = read && (addr == HXAUI_CSR_TX_STATUS_0_ADDR);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        tx_phase_comp_fifo_error_sr <= 4'h0;
    end else begin
        tx_phase_comp_fifo_error_sr <= tx_phase_comp_fifo_error_c |
            (tx_phase_comp_fifo_error_sr & {4{read_tx_status_0}});
    end
end

assign hxaui_csr_tx_status_0 = tx_phase_comp_fifo_error_sr;


endmodule // hxaui_csr

