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

module altera_xcvr_detlatency_rx_ctrl #(
    parameter    ser_base_factor     =    8,
    parameter    ser_words           =    10,
    parameter    data_width_pma      =    80
) (
    input   pma_clk,
    input   usr_pma_clk,
    input   usr_clk,
    input   fifo_calc_clk,
    input   rst,
    input   fifo_rst,
    input   fifo_cal_rst,
    input [data_width_pma-1:0] datain_pma2pcs,
    input encdt,
    input [ser_base_factor*ser_words-1:0] dataout_in,
    input [ser_words-1:0] datakout_in,
    input [ser_words-1:0] pattern_detect_in,
    input [ser_words-1:0] sync_status_in,
    input [ser_words-1:0] errdetect_in,
    input [ser_words-1:0] disperr_in,
    input [ser_words-1:0] runningdisp_in,
    output reg [ser_base_factor*ser_words-1:0] dataout_pcs2pld,
    output reg [ser_words-1:0] datakout_pcs2pld,
    output reg [ser_words-1:0] rx_patterndetect,
    output reg [ser_words-1:0] rx_syncstatus,
    output reg [ser_words-1:0] rx_errdetect,
    output reg [ser_words-1:0] rx_disperr,
    output reg [ser_words-1:0] rx_runningdisp,
    output wire rst_usr_clk,
    output wire rst_pma_clk,
    output wire rst_usr_pma_clk,
    output wire rst_fifo_rx_pma_clk,
    output wire rst_fifo_usr_pma_clk,
    output wire rst_fifo_calc_clk,
    (* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)
    output reg [data_width_pma-1:0] sync_datain_pma2pcs,
    output wire sync_encdt
    );

    wire rstn_usr_clk, rstn_pma_clk, rstn_usr_pma_clk, rstn_fifo_rx_pma_clk, rstn_fifo_usr_pma_clk, rstn_fifo_calc_clk;
    
    assign rst_usr_clk            = ~rstn_usr_clk;
    assign rst_pma_clk            = ~rstn_pma_clk;
    assign rst_usr_pma_clk        = ~rstn_usr_pma_clk;
    assign rst_fifo_rx_pma_clk    = ~rstn_fifo_rx_pma_clk;
    assign rst_fifo_usr_pma_clk   = ~rstn_fifo_usr_pma_clk;
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
    ) fifo_rx_pma_clk_rst_inst(
        .external_rstn({~rst,~fifo_rst}),
        .clk(pma_clk),
        .rstn(rstn_fifo_rx_pma_clk)    
    );      
    
    altera_xcvr_detlatency_reset_control #(
        .num_external_resets(2)
    ) fifo_usr_pma_clk_rst_inst(
        .external_rstn({~rst,~fifo_rst}),
        .clk(usr_pma_clk),
        .rstn(rstn_fifo_usr_pma_clk)    
    );      
    
    altera_xcvr_detlatency_reset_control #(
        .num_external_resets(3)
    ) fifo_calc_clk_inst(
        .external_rstn({~rst,~fifo_rst,~fifo_cal_rst}),
        .clk(fifo_calc_clk),
        .rstn(rstn_fifo_calc_clk)    
    ); 
        
        
    always @(posedge pma_clk or posedge rst_pma_clk) begin
        if (rst_pma_clk)
        begin
            sync_datain_pma2pcs <= {data_width_pma{1'b0}};
        end
        else
        begin
            sync_datain_pma2pcs <= datain_pma2pcs;
        end
    end

    altera_xcvr_detlatency_synchronizer #(
        .width (1),
        .stages(2)
    )sync_encdt_inst(
        .clk (pma_clk),
        .rst (rst_pma_clk),
        .dat_in (encdt),
        .dat_out (sync_encdt)
    );    

    always @(posedge usr_clk or posedge rst_usr_clk) begin
        if (rst_usr_clk)
        begin
            dataout_pcs2pld     <= {ser_words*ser_base_factor{1'b0}};
            datakout_pcs2pld    <= {ser_words{1'b0}};
            rx_patterndetect    <= {ser_words{1'b0}};
            rx_syncstatus       <= {ser_words{1'b0}};
            rx_errdetect        <= {ser_words{1'b0}};
            rx_disperr          <= {ser_words{1'b0}};
            rx_runningdisp      <= {ser_words{1'b0}};
        end
        else
        begin
            dataout_pcs2pld     <= dataout_in;
            datakout_pcs2pld    <= datakout_in;
            rx_patterndetect    <= pattern_detect_in;
            rx_syncstatus       <= sync_status_in;
            rx_errdetect        <= errdetect_in;
            rx_disperr          <= disperr_in;
            rx_runningdisp      <= runningdisp_in;
        end
    end    
endmodule