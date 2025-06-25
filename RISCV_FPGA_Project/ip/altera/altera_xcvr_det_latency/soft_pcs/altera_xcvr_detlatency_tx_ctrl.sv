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

module altera_xcvr_detlatency_tx_ctrl #(
    parameter ser_base_factor     = 8,
    parameter ser_words           = 4
) (
    input pma_clk,
    input usr_pma_clk,
    input usr_clk,
    input fifo_calc_clk,
    input rst,
    input fifo_rst,
    input fifo_cal_rst,
    input [ser_words*ser_base_factor-1:0] datain_pld2pcs,
    input [ser_words-1:0] datakin_pld2pcs,
    input wire [`BOUNDARY_WIDTH-1:0] tx_boundary_sel,
    output wire rst_usr_clk,
    output wire rst_pma_clk,
    output wire rst_usr_pma_clk,
    output wire rst_fifo_usr_pma_clk,
    output wire rst_fifo_tx_pma_clk,
    output wire rst_fifo_calc_clk,
    output reg [ser_words*ser_base_factor-1:0] sync_datain_pld2pcs,
    output reg [ser_words-1:0] sync_datakin_pld2pcs,
    output wire [`BOUNDARY_WIDTH-1:0] sync_tx_boundary_sel
);

    wire rstn_usr_clk, rstn_pma_clk, rstn_usr_pma_clk, rstn_fifo_usr_pma_clk, rstn_fifo_tx_pma_clk, rstn_fifo_calc_clk;
        
    assign rst_usr_clk            = ~rstn_usr_clk;
    assign rst_pma_clk            = ~rstn_pma_clk;
    assign rst_usr_pma_clk        = ~rstn_usr_pma_clk;
    assign rst_fifo_usr_pma_clk   = ~rstn_fifo_usr_pma_clk;
    assign rst_fifo_tx_pma_clk    = ~rstn_fifo_tx_pma_clk;
    assign rst_fifo_calc_clk      = ~rstn_fifo_calc_clk;
        
    altera_xcvr_detlatency_reset_control usr_clk_rst_inst(
        .external_rstn(~rst),
        .clk(usr_clk),
        .rstn(rstn_usr_clk)    
    );  
    
    altera_xcvr_detlatency_reset_control pma_clk_rst_inst(
        .external_rstn(~rst),
        .clk(pma_clk),
        .rstn(rstn_pma_clk)    
    );  
    
    altera_xcvr_detlatency_reset_control usr_pma_clk_rst_inst(
        .external_rstn(~rst),
        .clk(usr_pma_clk),
        .rstn(rstn_usr_pma_clk)    
    );      
    
    altera_xcvr_detlatency_reset_control #(
        .num_external_resets(2)
    ) fifo_usr_pma_clk_rst_inst(
        .external_rstn({~rst,~fifo_rst}),
        .clk(usr_pma_clk),
        .rstn(rstn_fifo_usr_pma_clk)    
    );      
    
    altera_xcvr_detlatency_reset_control #(
        .num_external_resets(2)
    ) fifo_tx_pma_clk_rst_inst(
        .external_rstn({~rst,~fifo_rst}),
        .clk(pma_clk),
        .rstn(rstn_fifo_tx_pma_clk)    
    );      
    
    altera_xcvr_detlatency_reset_control #(
        .num_external_resets(3)
    ) fifo_calc_clk_inst(
        .external_rstn({~rst,~fifo_rst,~fifo_cal_rst}),
        .clk(fifo_calc_clk),
        .rstn(rstn_fifo_calc_clk)    
    ); 
    
    always @(posedge usr_clk or posedge rst_usr_clk) begin
        if (rst_usr_clk)
        begin
            sync_datain_pld2pcs <= {ser_words*ser_base_factor{1'b0}};
        end
        else
        begin
            sync_datain_pld2pcs <= datain_pld2pcs;
        end
    end    
    
    always @(posedge usr_clk or posedge rst_usr_clk) begin
        if (rst_usr_clk)
        begin
            sync_datakin_pld2pcs <= {ser_words{1'b0}};
        end
        else
        begin
            sync_datakin_pld2pcs <= datakin_pld2pcs;
        end
    end    
    
    altera_xcvr_detlatency_synchronizer #(
        .width (`BOUNDARY_WIDTH),
        .stages(2)
    )sync_tx_boundary_sel_inst(
        .clk (usr_pma_clk),
        .rst (rst_usr_pma_clk),
        .dat_in (tx_boundary_sel),
        .dat_out (sync_tx_boundary_sel)
    );


endmodule