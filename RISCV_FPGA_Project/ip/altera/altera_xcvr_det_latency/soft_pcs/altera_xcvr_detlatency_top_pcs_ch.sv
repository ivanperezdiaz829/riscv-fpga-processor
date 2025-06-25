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
`define FIFO_SAMPLE_SIZE_WIDTH 8
`define FIFO_PH_MEASURE_ACC 32

module altera_xcvr_detlatency_top_pcs_ch #(
    parameter operation_mode      = "Duplex", //legal value: TX,RX,Duplex
    parameter wa_mode             = "deterministic_latency", //"manual", "deterministic_latency"
    parameter ser_words           = 4,
    parameter ser_words_pma_size  = 3,
    parameter ser_base_factor     = 8,
    parameter full_data_width_pma = 80,
    parameter data_width_pma_size = 7,
    parameter pattern_detect      = 10'h17C,
    parameter pattern_detect_size = 10,
    parameter parallel_loopback   = 1'b0,
    parameter tx_fifo_depth       = 4,
    parameter rx_fifo_depth       = 4
) (
    
    input   rx_pma_clk,
    input   tx_pma_clk,
    input   usr_pma_clk,
    input   usr_clk,
    input   fifo_calc_clk,
    input   tx_rst,
    input   rx_rst,
    input   tx_fifo_rst,
    input   rx_fifo_rst,
    input   tx_fifo_cal_rst,
    input   rx_fifo_cal_rst,
    input   [data_width_pma_size-1:0]                   data_width_pma,
    input   [ser_words*ser_base_factor-1:0]             datain_pld2pcs,
    input   [ser_words-1:0]                             datakin_pld2pcs,
    input   [full_data_width_pma-1:0]                   datain_pma2pcs,
    input                                               encdt,
    input   [`BOUNDARY_WIDTH-1:0]                       tx_boundary_sel,
    output logic    [ser_words*ser_base_factor-1:0]     dataout_pcs2pld,
    output logic    [ser_words-1:0]                     datakout_pcs2pld,
    output logic    [full_data_width_pma-1:0]           dataout_pcs2pma,
    input  wire     [`FIFO_SAMPLE_SIZE_WIDTH-1:0]       tx_fifo_sample_size,
    input  wire     [`FIFO_SAMPLE_SIZE_WIDTH-1:0]       rx_fifo_sample_size,
    output logic    [`FIFO_PH_MEASURE_ACC-1:0]          tx_phase_measure_acc,
    output logic    [`FIFO_PH_MEASURE_ACC-1:0]          rx_phase_measure_acc,
    output logic    [tx_fifo_depth:0]                   tx_fifo_latency,
    output logic    [rx_fifo_depth:0]                   rx_fifo_latency,
    output logic                                        tx_ph_acc_valid,
    output logic                                        rx_ph_acc_valid,
    output logic                                        tx_wr_full,
    output logic                                        rx_wr_full,
    output logic                                        tx_rd_empty,
    output logic                                        rx_rd_empty,
    output logic                                        boundary_slip,
    output logic    [`BOUNDARY_WIDTH-1:0]               rx_boundary_sel,
    output logic    [ser_words-1:0]                     rx_syncstatus,
    output logic    [ser_words-1:0]                     rx_patterndetect,
    output logic    [ser_words-1:0]                     rx_disperr,
    output logic    [ser_words-1:0]                     rx_errdetect,
    output logic    [ser_words-1:0]                     rx_runningdisp,
    output error
);

    localparam WIDTH_8B10B = ((ser_words*ser_base_factor)%10==1'b0)? full_data_width_pma : full_data_width_pma/10*8;
    localparam FULL_SER_WORDS = ((full_data_width_pma)%10==1'b0)? full_data_width_pma/10 : full_data_width_pma/8;
    localparam DATA_PCSWIDTH_SIZE_SER_DESER = data_width_pma_size-1; //for 32 bit PCS-PLD width, ser-deser PCS side data width only up to 32 max, else 40
    localparam SER_WORDS_PCSWIDTH_SIZE = ser_words_pma_size-1;
    
    wire [5:0] data_width_pcs_max;
    wire [DATA_PCSWIDTH_SIZE_SER_DESER-1:0] data_width_pcs;
    wire [2:0] ser_words_pcs_max;
    wire [SER_WORDS_PCSWIDTH_SIZE-1:0] ser_words_pcs;
    wire [3:0] ser_words_pma_max;
    wire [ser_words_pma_size-1:0] ser_words_pma;
    wire [6:0] data_width_ser_deser_max;
    wire [data_width_pma_size-1:0] data_width_ser_deser;
    wire error_rx_dwidth_adapter;
    wire error_tx_dwidth_adapter;
    
    
    assign data_width_pcs_max = ((ser_words*ser_base_factor)%10==1'b0)? ((data_width_pma == 'd10)? 6'd10 : 6'd40) : ((data_width_pma == 'd10)? 6'd8 : 6'd32);
    assign data_width_pcs = data_width_pcs_max[DATA_PCSWIDTH_SIZE_SER_DESER-1:0];
    assign ser_words_pcs_max = ((data_width_pma == 'd8) || (data_width_pma == 'd10))? 3'd1 : 3'd4;
    assign ser_words_pcs = ser_words_pcs_max[SER_WORDS_PCSWIDTH_SIZE-1:0];
    assign ser_words_pma_max = ((data_width_pma == 'd8) || (data_width_pma == 'd10))? 4'd1 : ((data_width_pma == 'd16) || (data_width_pma == 'd20))? 4'd2 : 4'd8;
    assign ser_words_pma = ser_words_pma_max[ser_words_pma_size-1:0];
    assign data_width_ser_deser_max = ((ser_words*ser_base_factor)%10==1'b0)? data_width_pma : ((data_width_pma=='d80)? 7'd64 : ((data_width_pma=='d20)? 7'd16 : ((data_width_pma=='d10)? 7'd8 : data_width_pma)));
    assign data_width_ser_deser = data_width_ser_deser_max[data_width_pma_size-1:0];
    assign error = error_tx_dwidth_adapter | error_rx_dwidth_adapter;
    
  //TX:
generate
if (operation_mode=="Duplex" ||operation_mode=="TX")
begin
  
    wire rst_tx_usr_clk, rst_tx_pma_clk, rst_tx_usr_pma_clk, rst_tx_fifo_usr_pma_clk, rst_tx_fifo_tx_pma_clk, rst_tx_fifo_calc_clk;
    wire           [`BOUNDARY_WIDTH-1:0] sync_tx_boundary_sel;
    wire            [full_data_width_pma-1:0] dataout_8b10benc, dataout_bitslip;
    wire               [WIDTH_8B10B-1:0] dataout_tx_ser_deser;
    wire         [full_data_width_pma/10-1:0] datakout_tx_ser_deser;
    reg  [ser_words*ser_base_factor-1:0] sync_datain_pld2pcs;
    reg                  [ser_words-1:0] sync_datakin_pld2pcs;
    
    altera_xcvr_detlatency_tx_ctrl # (
        .ser_base_factor(ser_base_factor),
        .ser_words      (ser_words)
    )tx_ctrl_inst(
        .pma_clk(tx_pma_clk),
        .usr_pma_clk(usr_pma_clk),
        .usr_clk(usr_clk),
        .fifo_calc_clk(fifo_calc_clk),
        .rst(tx_rst),
        .fifo_rst(tx_fifo_rst),
        .fifo_cal_rst(tx_fifo_cal_rst),
        .datain_pld2pcs(datain_pld2pcs),
        .datakin_pld2pcs(datakin_pld2pcs),
        .tx_boundary_sel(tx_boundary_sel),
        .rst_usr_clk(rst_tx_usr_clk),
        .rst_pma_clk(rst_tx_pma_clk),
        .rst_usr_pma_clk(rst_tx_usr_pma_clk),
        .rst_fifo_usr_pma_clk(rst_tx_fifo_usr_pma_clk),
        .rst_fifo_tx_pma_clk(rst_tx_fifo_tx_pma_clk),
        .rst_fifo_calc_clk(rst_tx_fifo_calc_clk),
        .sync_datain_pld2pcs(sync_datain_pld2pcs),
        .sync_datakin_pld2pcs(sync_datakin_pld2pcs),
        .sync_tx_boundary_sel(sync_tx_boundary_sel)
    );
    
    altera_xcvr_detlatency_tx_dwidth_adapter #(
        .full_idwidth(ser_words*ser_base_factor),
        .full_odwidth(WIDTH_8B10B),
        .idwidth_size(DATA_PCSWIDTH_SIZE_SER_DESER),
        .odwidth_size(data_width_pma_size),
        .full_ser_words_in(ser_words),
        .full_ser_words_out(FULL_SER_WORDS),
        .ser_words_in_size(SER_WORDS_PCSWIDTH_SIZE),
        .ser_words_out_size(ser_words_pma_size)
    )tx_dw_adapter_inst(
        .datain_clk(usr_clk), 
        .dataout_clk(usr_pma_clk),
        .rst_inclk(rst_tx_usr_clk),
        .rst_outclk(rst_tx_usr_pma_clk),
        .idwidth(data_width_pcs),
        .odwidth(data_width_ser_deser),
        .ser_words_in(ser_words_pcs),
        .ser_words_out(ser_words_pma),
        .datain(sync_datain_pld2pcs),
        .dataout(dataout_tx_ser_deser),
        .datakin(sync_datakin_pld2pcs),
        .datakout(datakout_tx_ser_deser),
        .error(error_tx_dwidth_adapter) // indicator for invalid ser_words_pcs:ser_words_pma ratio and data_width_pcs:data_width_pma
    );
    

    if ((ser_words*ser_base_factor)%10!=1'b0)
    begin
        altera_xcvr_detlatency_xn_8b10benc #(
            .data_width (WIDTH_8B10B),
            .ser_words_size(ser_words_pma_size)
        )xn_encoder_8b10b_inst(
            .clk(usr_pma_clk),
            .rst(rst_tx_usr_pma_clk),
            .ser_words(ser_words_pma),
            .kin_ena(datakout_tx_ser_deser),      // Data in is a special code, not all are legal.      
            .ein_dat(dataout_tx_ser_deser),       // 8b data in
            .eout_dat(dataout_8b10benc)          // data out
        );
    end
    else
    begin
        assign dataout_8b10benc = dataout_tx_ser_deser;
    end

    altera_xcvr_detlatency_txbitslip #(
        .full_data_width    (full_data_width_pma),
        .sel_width          (`BOUNDARY_WIDTH),
        .dwidth_size        (data_width_pma_size)
    )txbitslip_inst(
        .clk(usr_pma_clk),
        .rst(rst_tx_usr_pma_clk),
        .data_width(data_width_pma),
        .datain(dataout_8b10benc),
        .tx_boundary_sel(sync_tx_boundary_sel),
        .dataout(dataout_bitslip)
    );
   
    altera_xcvr_detlatency_ph_measure_fifo # (
      .data_width  ( full_data_width_pma ),
      .fifo_depth  ( tx_fifo_depth  )
    ) tx_ph_measure_fifo_inst (
      .rd_clk(tx_pma_clk),
      .wr_clk(usr_pma_clk),
      .calc_clk(fifo_calc_clk),
      .rst_wr(rst_tx_fifo_usr_pma_clk),
      .rst_rd(rst_tx_fifo_tx_pma_clk),
      .rst_calc(rst_tx_fifo_calc_clk),
      .wr_data(dataout_bitslip),
      .rd_data(dataout_pcs2pma),
      .fifo_sample_size(tx_fifo_sample_size),
      .phase_measure_acc(tx_phase_measure_acc),
      .fifo_wr_latency(tx_fifo_latency),
      .fifo_rd_latency(/*not_used*/),
      .ph_acc_valid(tx_ph_acc_valid),
      .wr_full(tx_wr_full),
      .rd_empty(tx_rd_empty)
    );
end
else
begin
    assign dataout_pcs2pma      = '0;
    assign tx_phase_measure_acc = '0;
    assign tx_fifo_latency      = '0;
    assign tx_ph_acc_valid      = '0;
    assign tx_wr_full           = '0;
    assign tx_rd_empty          = '0;
end
endgenerate

    //RX:
generate
if (operation_mode=="Duplex" ||operation_mode=="RX")
begin

    wire rst_rx_usr_clk, rst_rx_pma_clk, rst_rx_usr_pma_clk, rst_rx_fifo_rx_pma_clk, rst_rx_fifo_usr_pma_clk, rst_rx_fifo_calc_clk;
    wire sync_encdt;
    wire sync_status, sync_status_fifo;
    wire [ser_words*ser_base_factor-1:0] dataout_rx_adapter;
    wire [ser_words-1:0] datakout_rx_adapter;
    wire [full_data_width_pma-1:0] dataout_rx_ph_measure_fifo, dataout_wa;
    wire [(full_data_width_pma/10)-1:0] pattern_detect_w, pattern_detect_fifo;
    reg [(full_data_width_pma/10)-1:0] pattern_detect_dec;
    wire [WIDTH_8B10B-1:0] dataout_8b10bdec;
    wire [full_data_width_pma/10-1:0] datakout_8b10bdec;
    wire [full_data_width_pma/10-1:0] errdetect_dec, disperr_dec, runningdisp_dec;
    wire [ser_words-1:0] errdetect_adpt, disperr_adpt, runningdisp_adpt, syncs_status_adpt;
    wire [ser_words-1:0] pattern_detect_adpt;    
    reg [full_data_width_pma-1:0] sync_datain_pma2pcs;
    
    altera_xcvr_detlatency_rx_ctrl # (
        .ser_base_factor(ser_base_factor),
        .ser_words      (ser_words),
        .data_width_pma(full_data_width_pma)
    )rx_ctrl_inst(
        .pma_clk(rx_pma_clk),
        .usr_pma_clk(usr_pma_clk),
        .usr_clk(usr_clk),
        .fifo_calc_clk(fifo_calc_clk),
        .rst(rx_rst),
        .fifo_cal_rst(rx_fifo_cal_rst),
        .fifo_rst(rx_fifo_rst),
        .datain_pma2pcs(datain_pma2pcs),
        .encdt(encdt),
        .rst_usr_clk(rst_rx_usr_clk),
        .rst_pma_clk(rst_rx_pma_clk),
        .rst_usr_pma_clk(rst_rx_usr_pma_clk),
        .rst_fifo_rx_pma_clk(rst_rx_fifo_rx_pma_clk),
        .rst_fifo_usr_pma_clk(rst_rx_fifo_usr_pma_clk),
        .rst_fifo_calc_clk(rst_rx_fifo_calc_clk),
        .sync_datain_pma2pcs(sync_datain_pma2pcs),
        .sync_encdt(sync_encdt),
        .dataout_in(dataout_rx_adapter),
        .datakout_in(datakout_rx_adapter),
        .pattern_detect_in(pattern_detect_adpt),
        .sync_status_in(syncs_status_adpt),
        .errdetect_in(errdetect_adpt),
        .disperr_in(disperr_adpt),
        .runningdisp_in(runningdisp_adpt),
        .dataout_pcs2pld(dataout_pcs2pld),
        .datakout_pcs2pld(datakout_pcs2pld),
        .rx_patterndetect(rx_patterndetect),
        .rx_syncstatus(rx_syncstatus),
        .rx_errdetect(rx_errdetect),
        .rx_disperr(rx_disperr),
        .rx_runningdisp(rx_runningdisp)
    );
    
    altera_xcvr_detlatency_wordalign #(
        .wa_mode            (wa_mode),
        .full_data_width    (full_data_width_pma),
        .dwidth_size        (data_width_pma_size),
        .boundary_width     (`BOUNDARY_WIDTH),
        .pattern_detect     (pattern_detect),
        .pattern_detect_size (pattern_detect_size)
    )wordalign_inst(
        .clk(rx_pma_clk),
        .rst(rst_rx_pma_clk),
        .data_width(data_width_pma),
        .datain((parallel_loopback==1'b1)? dataout_pcs2pma:sync_datain_pma2pcs),
        .encdt(sync_encdt),
        .rx_boundary_sel(rx_boundary_sel),
        .boundary_slip(boundary_slip),
        .dataout(dataout_wa),
        .sync_status(sync_status),
        .pat_detect(pattern_detect_w)
    );
    
    altera_xcvr_detlatency_ph_measure_fifo # (
        .data_width    ( full_data_width_pma+(full_data_width_pma/10)+1 ),
        .fifo_depth    ( rx_fifo_depth                        )
    )rx_ph_measure_fifo_inst(
        .wr_clk(rx_pma_clk),
        .rd_clk(usr_pma_clk),
        .calc_clk(fifo_calc_clk),
        .rst_wr(rst_rx_fifo_rx_pma_clk),
        .rst_rd(rst_rx_fifo_usr_pma_clk),
        .rst_calc(rst_rx_fifo_calc_clk),
        .wr_data({sync_status,pattern_detect_w,dataout_wa}),
        .rd_data({sync_status_fifo,pattern_detect_fifo,dataout_rx_ph_measure_fifo}),
        .fifo_sample_size(rx_fifo_sample_size),
        .phase_measure_acc(rx_phase_measure_acc),
        .fifo_wr_latency(/*not_used*/),
        .fifo_rd_latency(rx_fifo_latency),
        .ph_acc_valid(rx_ph_acc_valid),
        .wr_full(rx_wr_full),
        .rd_empty(rx_rd_empty)
    );
    
    always @ (posedge usr_pma_clk)
        begin
            pattern_detect_dec <= pattern_detect_fifo;
        end
    
    if ((ser_words*ser_base_factor)%10!=1'b0)
    begin
        altera_xcvr_detlatency_xn_8b10bdec #(
            .data_width(WIDTH_8B10B),  //refer to data width from core
            .ser_words_size(ser_words_pma_size)
        )xn_decoder_8b10b_inst(
            .clk(usr_pma_clk),
            .rst(rst_rx_usr_pma_clk),
            .ser_words(ser_words_pma),
            .din_dat(dataout_rx_ph_measure_fifo),
            .dout_dat(dataout_8b10bdec),
            .dout_k(datakout_8b10bdec),
            .dout_kerr(errdetect_dec),
            .dout_rderr(disperr_dec),
            .dout_rdcomb(),
            .dout_rdreg(runningdisp_dec)       // running disparity output (reg)
        );
        
    end
    else
    begin
        assign dataout_8b10bdec     = dataout_rx_ph_measure_fifo;
        assign datakout_8b10bdec    = '0;
        assign errdetect_dec        = '0;
        assign disperr_dec          = '0;
        assign runningdisp_dec      = '0;
    end
    
    altera_xcvr_detlatency_rx_dwidth_adapter # (
        .full_idwidth(WIDTH_8B10B),
        .full_odwidth(ser_words*ser_base_factor),
        .idwidth_size(data_width_pma_size),
        .odwidth_size(DATA_PCSWIDTH_SIZE_SER_DESER),
        .full_ser_words_in(FULL_SER_WORDS),
        .full_ser_words_out(ser_words),
        .ser_words_in_size(ser_words_pma_size),
        .ser_words_out_size(SER_WORDS_PCSWIDTH_SIZE)
    )rx_dw_adapter_inst(
        .rst_inclk(rst_rx_usr_pma_clk),
        .rst_outclk(rst_rx_usr_clk),
        .datain_clk(usr_pma_clk), 
        .dataout_clk(usr_clk),
        .idwidth(data_width_ser_deser),
        .odwidth(data_width_pcs),
        .ser_words_in(ser_words_pma),
        .ser_words_out(ser_words_pcs),
        .datain(dataout_8b10bdec),
        .dataout(dataout_rx_adapter),
        .datakin(datakout_8b10bdec),
        .datakout(datakout_rx_adapter),
        .patdetin(pattern_detect_dec),
        .patdetout(pattern_detect_adpt),
        .errdetectin(errdetect_dec),
        .errdetectout(errdetect_adpt),
        .disperrin(disperr_dec),
        .disperrout(disperr_adpt),
        .runningdispin(runningdisp_dec),
        .runningdispout(runningdisp_adpt),
        .syncdatain(sync_status_fifo),
        .syncdataout(syncs_status_adpt),
        .error(error_rx_dwidth_adapter)
    );

end
else
begin
    assign dataout_pcs2pld      = '0;
    assign datakout_pcs2pld     = '0;
    assign rx_phase_measure_acc = '0;
    assign rx_fifo_latency      = '0;
    assign boundary_slip        = '0;
    assign rx_boundary_sel      = '0;
    assign rx_syncstatus        = '0;
    assign rx_patterndetect     = '0;
    assign rx_disperr           = '0;
    assign rx_errdetect         = '0;
    assign rx_runningdisp       = '0;
    assign rx_ph_acc_valid      = '0;
    assign rx_wr_full           = '0;
    assign rx_rd_empty          = '0;
end
endgenerate

endmodule