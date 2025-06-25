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

`define BOUNDARY_WIDTH 7
`define FIFO_PH_MEASURE_ACC 32
`define FIFO_SAMPLE_SIZE_WIDTH 8

module altera_xcvr_detlatency_top_pcs #(
    parameter operation_mode      = "Duplex", //legal value: TX,RX,Duplex
    parameter lanes               = 1,
    parameter wa_mode             = "deterministic_latency", //"manual", "deterministic_latency"
    parameter full_data_width_pma = 80,
    parameter data_width_pma_size = 7,
    parameter ser_words           = 4,
    parameter ser_words_pma_size  = 3,
    parameter ser_base_factor     = 8,
    parameter pattern_detect      = 10'h17C,
    parameter pattern_detect_size = 10,
    parameter parallel_loopback   = 1'b0,
    parameter tx_fifo_depth       = 4,
    parameter rx_fifo_depth       = 4
) (
    input   [lanes-1:0]                                 rx_pma_clk,
    input   [lanes-1:0]                                 tx_pma_clk,
    input                                               usr_pma_clk,
    input                                               usr_clk,
    input                                               fifo_calc_clk,
    input   [lanes-1:0]                                 tx_rst,
    input   [lanes-1:0]                                 rx_rst,
    input   [lanes-1:0]                                 tx_fifo_rst,
    input   [lanes-1:0]                                 rx_fifo_rst,
    input   [lanes-1:0]                                 tx_fifo_cal_rst,
    input   [lanes-1:0]                                 rx_fifo_cal_rst,
    input   [lanes*data_width_pma_size-1:0]             data_width_pma,
    input   [lanes*ser_words*ser_base_factor-1:0]       datain_pld2pcs,
    input   [lanes*ser_words-1:0]                       datakin_pld2pcs,
    input   [lanes*full_data_width_pma-1:0]             datain_pma2pcs,
    input   [lanes-1:0]                                 encdt,
    input   [lanes*`BOUNDARY_WIDTH-1:0]                  tx_boundary_sel,
    output wire [lanes*ser_words*ser_base_factor-1:0]   dataout_pcs2pld,
    output wire [lanes*ser_words-1:0]                   datakout_pcs2pld,
    output wire [lanes*full_data_width_pma-1:0]         dataout_pcs2pma,
    input  wire [`FIFO_SAMPLE_SIZE_WIDTH-1:0]           tx_fifo_sample_size,
    input  wire [`FIFO_SAMPLE_SIZE_WIDTH-1:0]           rx_fifo_sample_size,
    output wire [lanes*`FIFO_PH_MEASURE_ACC-1:0]        tx_phase_measure_acc,
    output wire [lanes*`FIFO_PH_MEASURE_ACC-1:0]        rx_phase_measure_acc,
    output wire [lanes*(tx_fifo_depth+1)-1:0]           tx_fifo_latency,
    output wire [lanes*(rx_fifo_depth+1)-1:0]           rx_fifo_latency,
    output wire [lanes-1:0]                             tx_ph_acc_valid,
    output wire [lanes-1:0]                             rx_ph_acc_valid,
    output wire [lanes-1:0]                             tx_wr_full,
    output wire [lanes-1:0]                             rx_wr_full,
    output wire [lanes-1:0]                             tx_rd_empty,
    output wire [lanes-1:0]                             rx_rd_empty,
    output wire [lanes-1:0]                             boundary_slip,
    output wire [lanes*`BOUNDARY_WIDTH-1:0]             rx_boundary_sel,
    output wire [lanes*ser_words-1:0]                   rx_syncstatus,
    output wire [lanes*ser_words-1:0]                   rx_patterndetect,
    output wire [lanes*ser_words-1:0]                   rx_disperr,
    output wire [lanes*ser_words-1:0]                   rx_errdetect,
    output wire [lanes*ser_words-1:0]                   rx_runningdisp,
    output wire [lanes-1:0]                             error
);


  genvar i;
  generate
    for (i=0;i<lanes;i=i+1)
    begin: lane    
            altera_xcvr_detlatency_top_pcs_ch #(
                .operation_mode       (operation_mode),
                .wa_mode              (wa_mode),
                .ser_words            (ser_words),
                .ser_words_pma_size   (ser_words_pma_size),
                .ser_base_factor      (ser_base_factor),
                .full_data_width_pma  (full_data_width_pma),
                .data_width_pma_size  (data_width_pma_size),
                .pattern_detect       (pattern_detect),
                .pattern_detect_size  (pattern_detect_size),
                .parallel_loopback    (parallel_loopback),
                .tx_fifo_depth        (tx_fifo_depth),
                .rx_fifo_depth        (rx_fifo_depth)
            )top_pcs_ch_inst (
                .rx_pma_clk           ((parallel_loopback==1'b1)? usr_pma_clk:rx_pma_clk[i]),
                .tx_pma_clk           ((parallel_loopback==1'b1)? usr_pma_clk:tx_pma_clk[i] ),
                .usr_pma_clk          (usr_pma_clk),
                .usr_clk              (usr_clk ),
                .fifo_calc_clk        (fifo_calc_clk ),
                .rx_rst               (rx_rst[i] ),
                .tx_rst               (tx_rst[i] ),
                .tx_fifo_rst          (tx_fifo_rst[i]),
                .rx_fifo_rst          (rx_fifo_rst[i]),
                .tx_fifo_cal_rst      (tx_fifo_cal_rst[i]),
                .rx_fifo_cal_rst      (rx_fifo_cal_rst[i]),
                .data_width_pma       (data_width_pma[data_width_pma_size*i+:data_width_pma_size]),
                .datain_pld2pcs       (datain_pld2pcs[ser_words*ser_base_factor*i+:ser_words*ser_base_factor] ),
                .datakin_pld2pcs      (datakin_pld2pcs[ser_words*i+:ser_words] ),
                .datain_pma2pcs       (datain_pma2pcs[full_data_width_pma*i+:full_data_width_pma] ),
                .encdt                (encdt[i] ),
                .tx_boundary_sel      (tx_boundary_sel[`BOUNDARY_WIDTH*i+:`BOUNDARY_WIDTH] ),
                .dataout_pcs2pld      (dataout_pcs2pld[ser_words*ser_base_factor*i+:ser_words*ser_base_factor] ),
                .datakout_pcs2pld     (datakout_pcs2pld[ser_words*i+:ser_words] ),
                .dataout_pcs2pma      (dataout_pcs2pma[full_data_width_pma*i+:full_data_width_pma] ),
                .tx_fifo_sample_size  (tx_fifo_sample_size),
                .rx_fifo_sample_size  (rx_fifo_sample_size),
                .tx_phase_measure_acc (tx_phase_measure_acc[`FIFO_PH_MEASURE_ACC*i+:`FIFO_PH_MEASURE_ACC] ),
                .rx_phase_measure_acc (rx_phase_measure_acc[`FIFO_PH_MEASURE_ACC*i+:`FIFO_PH_MEASURE_ACC] ),
                .tx_fifo_latency      (tx_fifo_latency[(tx_fifo_depth+1)*i+:(tx_fifo_depth+1)]),
                .rx_fifo_latency      (rx_fifo_latency[(rx_fifo_depth+1)*i+:(rx_fifo_depth+1)]),
                .tx_ph_acc_valid      (tx_ph_acc_valid[i]),
                .rx_ph_acc_valid      (rx_ph_acc_valid[i]),
                .tx_wr_full           (tx_wr_full[i]),
                .rx_wr_full           (rx_wr_full[i]),
                .tx_rd_empty          (tx_rd_empty[i]),
                .rx_rd_empty          (rx_rd_empty[i]),
                .boundary_slip        (boundary_slip[i] ),
                .rx_boundary_sel      (rx_boundary_sel[`BOUNDARY_WIDTH*i+:`BOUNDARY_WIDTH] ),
                .rx_syncstatus        (rx_syncstatus[ser_words*i+:ser_words] ),
                .rx_patterndetect     (rx_patterndetect[ser_words*i+:ser_words] ),
                .rx_disperr           (rx_disperr[ser_words*i+:ser_words] ),
                .rx_errdetect         (rx_errdetect[ser_words*i+:ser_words] ),
                .rx_runningdisp       (rx_runningdisp[ser_words*i+:ser_words] ),
                .error                (error[i])
            );
        end
    endgenerate
    
    
endmodule