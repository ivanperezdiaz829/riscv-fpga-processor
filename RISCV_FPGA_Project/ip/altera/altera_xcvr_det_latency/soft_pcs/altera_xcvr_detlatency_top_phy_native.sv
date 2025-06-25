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

import altera_xcvr_functions::*;  // for get_custom_reconfig_width functions

`define BOUNDARY_WIDTH 7
`define FIFO_PH_MEASURE_ACC 32
`define FIFO_SAMPLE_SIZE_WIDTH 8

module altera_xcvr_detlatency_top_phy_native #(
    parameter operation_mode    = "Duplex",                 //legal value: TX,RX,Duplex
    parameter lanes             = 1,                        //legal value: 1+
    parameter ser_base_factor   = 8,                        //legal value: 8,10
    parameter ser_words         = 4,                        //legal value 1,2,4
    parameter ser_words_pma_size  = 3,                      // the value should be ceil of log2 ser_words on PMA side
    parameter pcs_pma_width     = 80,                       // 8G - 8|10|16|20|32|40, PMA_DIR-8|10|16|20|32|40|64|80
    parameter data_width_pma_size = 7,                      // the value should be log2 of pcs_pma_width
    parameter data_rate         = "9830.4 Mbps",            // user entered data rate always in mbps
    parameter base_data_rate    = "0 Mbps",                 // (PLL Rate) - must be (data_rate * 1,2,4,or8) in mbps
    parameter tx_pma_clk_div    = 1,                        // (1,2,4,8) CGB clock divider value
    parameter pll_feedback_path = "no_compensation",        //legal: no_compensation, tx_clkout
    parameter word_aligner_mode = "deterministic_latency",  //legal value: deterministic_latency or manual
    
    //PLL
    parameter pll_refclk_cnt    = 1,             // Number of reference clocks
    parameter pll_refclk_freq   = "122.88 MHz",  // Frequency of each reference clock
    parameter pll_refclk_select = "0",           // Selects the initial reference clock for each TX PLL
    parameter plls              = 1,             // (1+)
    parameter pll_type          = "AUTO",        // PLL type for each PLL
    parameter pll_select        = 0,             // Selects the initial PLL
    parameter pll_reconfig      = 0,             // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
    parameter cdr_refclk_cnt    = 1,             // Number of RX CDR reference clocks
    parameter cdr_refclk_freq   = "122.88 MHz",  // RX CDR reference clock frequency, this will go to TX PLL and CDR PLL
    parameter cdr_refclk_select = 0,             // Selects the initial reference clock for all RX CDR PLLs
    parameter cdr_reconfig      = 0,             // (0,1) 0-Disable CDR reconfig, 1-Enable CDR reconfig
    
    parameter tx_fifo_depth     = 4,             // The depth of the tx phase measuring FIFO. The value is the log2 of the FIFO buffer depth. E.g. it is set to four, specifying a 16 depth
    parameter rx_fifo_depth     = 4,             // The depth of the tx phase measuring FIFO. The value is the log2 of the FIFO buffer depth. E.g. it is set to four, specifying a 16 depth
    
    parameter channel_interface = 0,             //legal value: (0,1) 1-Enable channel reconfiguration
    parameter ref_design        = 1              //legal value: (0,1) 1-Instantiate the native phy and reset controller thru UI
) (
    //input from reset controller
    input   wire    [lanes-1:0]     tx_analogreset,     // for tx pma
    input   wire    [plls -1:0]     pll_powerdown, 
    input   wire    [lanes-1:0]     tx_digitalreset,
    input   wire    [lanes-1:0]     rx_analogreset,     // for rx pma
    input   wire    [lanes-1:0]     rx_digitalreset,    // for rx pcs
    input   wire    [lanes-1:0]     tx_fiforeset,       // for tx pcs FIFO
    input   wire    [lanes-1:0]     rx_fiforeset,   // for rx pcs FIFO
    input      wire    [lanes-1:0]     tx_fifocalreset,
    input      wire    [lanes-1:0]     rx_fifocalreset,
    
    // Calibration busy signals
    output  wire    [lanes-1:0]     tx_cal_busy,
    output  wire    [lanes-1:0]     rx_cal_busy,
    
    //clk signal
    input   wire    [pll_refclk_cnt-1:0] pll_ref_clk,
    input   wire    [cdr_refclk_cnt-1:0] cdr_ref_clk,
    input   wire    usr_pma_clk,
    input   wire    usr_clk,
    input   wire    fifo_calc_clk,
    
    input [lanes*data_width_pma_size-1:0] data_width_pma,
    
    //data ports
    input  wire [(channel_interface? 44: ser_base_factor*ser_words)*lanes-1:0] tx_parallel_data,
    output wire [(channel_interface? 64: ser_base_factor*ser_words)*lanes-1:0] rx_parallel_data,
    input  wire [ser_words*lanes-1:0] tx_datak,
    output wire [ser_words*lanes-1:0] rx_datak,
    input  wire [lanes-1:0] rx_serial_data,
    output wire [lanes-1:0] tx_serial_data,
    
    //clock outputs
    output wire [lanes-1:0] tx_clkout,
    output wire [lanes-1:0] rx_clkout,
        
    //control ports
    input wire [lanes*`BOUNDARY_WIDTH-1:0] tx_bitslipboundaryselect,
    input wire [lanes-1:0] rx_seriallpbken,
    input wire [lanes-1:0] rx_set_locktodata,
    input wire [lanes-1:0] rx_set_locktoref,
    input wire [lanes-1:0] rx_enapatternalign,
    
    //status ports
    //output  wire                     [lanes-1:0] rx_rlv,
    output  wire [ser_words*lanes-1:0] rx_patterndetect,
    output  wire [ser_words*lanes-1:0] rx_syncstatus,
    output  wire [lanes*`BOUNDARY_WIDTH-1:0] rx_bitslipboundaryselectout,
    output  wire [ser_words*lanes-1:0] rx_errdetect,
    output  wire [ser_words*lanes-1:0] rx_disperr,
    output  wire [ser_words*lanes-1:0] rx_runningdisp,
    
    output  wire [lanes-1:0] rx_is_lockedtoref,
    output  wire [lanes-1:0] rx_is_lockedtodata,
    output  wire [plls -1:0] pll_locked,

    input  wire [`FIFO_SAMPLE_SIZE_WIDTH-1:0] tx_fifo_sample_size,
    input  wire [`FIFO_SAMPLE_SIZE_WIDTH-1:0] rx_fifo_sample_size,
    output wire [lanes*`FIFO_PH_MEASURE_ACC-1:0] tx_phase_measure_acc,
    output wire [lanes*`FIFO_PH_MEASURE_ACC-1:0] rx_phase_measure_acc,
    output wire [lanes*(tx_fifo_depth+1)-1:0] tx_fifo_latency,
    output wire [lanes*(rx_fifo_depth+1)-1:0] rx_fifo_latency,
    output wire [lanes-1:0] tx_ph_acc_valid,
    output wire [lanes-1:0] rx_ph_acc_valid,
    output wire [lanes-1:0] tx_wr_full,
    output wire [lanes-1:0] rx_wr_full,
    output wire [lanes-1:0] tx_rd_empty,
    output wire [lanes-1:0] rx_rd_empty,
    output wire [lanes-1:0] error,

    input   wire  [altera_xcvr_functions::get_custom_reconfig_to_width  ("Arria V",operation_mode,lanes,plls,1)-1:0] reconfig_to_xcvr,
    output  wire  [altera_xcvr_functions::get_custom_reconfig_from_width("Arria V",operation_mode,lanes,plls,1)-1:0] reconfig_from_xcvr 
);
   
    wire [lanes*pcs_pma_width-1:0] rx_pcsdata, tx_pcsdata;
    wire [lanes-1:0] boundary_slip;
    wire [lanes*plls-1:0] pll_locked_ch;
    wire [lanes-1:0] pll_locked_tmp [plls-1:0];
   
    // multiple txpll will be supported in 12.1. temporary created logic for pll_locked and pll_powerdown. 
    // need to revisit later in 12.1
    genvar ipll;
    genvar ilane;
    generate  for(ilane=0;ilane<lanes;ilane=ilane+1) 
    begin: ilane_loop
        for (ipll=0;ipll<plls;ipll=ipll+1) 
        begin: ipll_locked
            assign pll_locked_tmp[ipll][ilane] = pll_locked_ch[ilane*plls+ipll];
        end
    end
    endgenerate
    
    generate  for (ipll=0;ipll<plls;ipll=ipll+1) 
    begin: ipll_locked_loop
            assign pll_locked[ipll] = &pll_locked_tmp[ipll];
    end
    endgenerate
   
    //soft PCS
    altera_xcvr_detlatency_top_pcs #(
        .operation_mode      (operation_mode           ),
        .lanes               (lanes                    ),
        .wa_mode             (word_aligner_mode        ),
        .ser_base_factor     (ser_base_factor          ),
        .ser_words           (ser_words                ),
        .ser_words_pma_size  (ser_words_pma_size       ),
        .full_data_width_pma (pcs_pma_width            ),
        .data_width_pma_size (data_width_pma_size      ),
        .pattern_detect      (10'h17C                  ),
        .pattern_detect_size (10                       ),
        .parallel_loopback   (1'b0                     ),
        .tx_fifo_depth       (tx_fifo_depth            ),
        .rx_fifo_depth       (rx_fifo_depth            )
    )top_pcs_inst (
        .rx_pma_clk(rx_clkout),
        .tx_pma_clk(tx_clkout),
        .usr_pma_clk(usr_pma_clk),
        .usr_clk(usr_clk),
        .fifo_calc_clk(fifo_calc_clk),
        .tx_rst(tx_digitalreset),
        .rx_rst(rx_digitalreset),
        .tx_fifo_rst(tx_fiforeset),
        .rx_fifo_rst(rx_fiforeset),
        .tx_fifo_cal_rst(tx_fifocalreset),
        .rx_fifo_cal_rst(rx_fifocalreset),
        .data_width_pma(data_width_pma),
        .datain_pld2pcs(tx_parallel_data),
        .datakin_pld2pcs(tx_datak),
        .datain_pma2pcs(rx_pcsdata),
        .encdt(rx_enapatternalign),
        .tx_boundary_sel(tx_bitslipboundaryselect),
        .dataout_pcs2pld(rx_parallel_data),
        .datakout_pcs2pld(rx_datak),
        .dataout_pcs2pma(tx_pcsdata),
        .tx_fifo_sample_size(tx_fifo_sample_size),
        .rx_fifo_sample_size(rx_fifo_sample_size),
        .tx_phase_measure_acc(tx_phase_measure_acc),
        .rx_phase_measure_acc(rx_phase_measure_acc),
        .tx_fifo_latency(tx_fifo_latency),
        .rx_fifo_latency(rx_fifo_latency),
        .tx_ph_acc_valid(tx_ph_acc_valid),
        .rx_ph_acc_valid(rx_ph_acc_valid),
        .tx_wr_full(tx_wr_full),
        .rx_wr_full(rx_wr_full),
        .tx_rd_empty(tx_rd_empty),
        .rx_rd_empty(rx_rd_empty),
        .boundary_slip(boundary_slip),
        .rx_boundary_sel(rx_bitslipboundaryselectout),
        .rx_syncstatus(rx_syncstatus),
        .rx_patterndetect(rx_patterndetect),
        .rx_disperr(rx_disperr),
        .rx_errdetect(rx_errdetect),
        .rx_runningdisp(rx_runningdisp),
        .error(error)
    );

    //This is Arria V Transceiver Native PHY IP
    //You can open up the Megawizard to modify the parameters for this IP.
    //This is just an example for 9.8G single channel, duplex
    //User will need to run the Megawizard to regenerate all the files required by this IP
    generate begin : phy
        if (!ref_design) begin
            localparam RX_CLKSLIP = (word_aligner_mode=="deterministic_latency")? 1:0;
            localparam TX_ENABLE = (operation_mode != "Rx" && operation_mode != "RX");
            localparam RX_ENABLE = (operation_mode != "Tx" && operation_mode != "TX");
            localparam PLL_FB     = (pll_feedback_path=="no_compensation")? "internal":"external";
            
            altera_xcvr_native_av #(
                .channels                           (lanes            ),
                .tx_enable                          (TX_ENABLE        ),
                .rx_enable                          (RX_ENABLE        ),
                .data_path_select                   ("pma_direct"     ),
                .bonded_mode                        ("non_bonded"     ),
                .data_rate                          (data_rate        ),
                .pma_width                          (pcs_pma_width    ),
                .tx_pma_clk_div                     (tx_pma_clk_div   ),
                .pll_reconfig_enable                (pll_reconfig     ),
                .pll_data_rate                      (base_data_rate   ),
                .pll_type                           (pll_type         ),
                .plls                               (plls             ),
                .pll_select                         (pll_select       ),
                .pll_refclk_cnt                     (pll_refclk_cnt   ),
                .pll_refclk_select                  (pll_refclk_select),
                .pll_refclk_freq                    (pll_refclk_freq  ),
                .pll_feedback_path                  (PLL_FB           ),
                .cdr_reconfig_enable                (cdr_reconfig     ),
                .cdr_refclk_cnt                     (cdr_refclk_cnt   ),
                .cdr_refclk_select                  (cdr_refclk_select),
                .cdr_refclk_freq                    (cdr_refclk_freq  ),
                .rx_ppm_detect_threshold            ("1000"           ),
                .rx_clkslip_enable                  (RX_CLKSLIP       ),
                .enable_std                         (0                )
            ) native_phy_inst (
                .pll_powerdown             ({lanes{pll_powerdown}}),                                    //        pll_powerdown.pll_powerdown
                .tx_analogreset            (tx_analogreset),                                   //       tx_analogreset.tx_analogreset
                .tx_digitalreset           (),                                  //      tx_digitalreset.tx_digitalreset
                .tx_pll_refclk             (pll_ref_clk),                                    //        tx_pll_refclk.tx_pll_refclk
                .tx_pma_clkout             (tx_clkout),                                    //        tx_pma_clkout.tx_pma_clkout
                .tx_serial_data            (tx_serial_data),                                   //       tx_serial_data.tx_serial_data
                .tx_pma_parallel_data      (tx_pcsdata),                             // tx_pma_parallel_data.tx_pma_parallel_data
                .ext_pll_clk               ('0),
                .pll_locked                (pll_locked_ch),                                       //           pll_locked.pll_locked
                .rx_analogreset            (rx_analogreset),                                   //       rx_analogreset.rx_analogreset
                .rx_digitalreset           (),                                  //      rx_digitalreset.rx_digitalreset
                .rx_cdr_refclk             (cdr_ref_clk),                                    //        rx_cdr_refclk.rx_cdr_refclk
                .rx_pma_clkout             (rx_clkout),                                    //        rx_pma_clkout.rx_pma_clkout
                .rx_serial_data            (rx_serial_data),                                   //       rx_serial_data.rx_serial_data
                .rx_seriallpbken           (rx_seriallpbken),                                  //      rx_seriallpbken.rx_seriallpbken
                .rx_pma_parallel_data      (rx_pcsdata),                             // rx_pma_parallel_data.rx_pma_parallel_data
                .rx_clkslip                (boundary_slip),                                       //           rx_clkslip.rx_clkslip
                .rx_set_locktodata         (rx_set_locktodata),                                //    rx_set_locktodata.rx_set_locktodata
                .rx_set_locktoref          (rx_set_locktoref),                                 //     rx_set_locktoref.rx_set_locktoref
                .rx_is_lockedtoref         (rx_is_lockedtoref),                                //    rx_is_lockedtoref.rx_is_lockedtoref
                .rx_is_lockedtodata        (rx_is_lockedtodata),                               //   rx_is_lockedtodata.rx_is_lockedtodata
                .rx_signaldetect           (),
                .tx_cal_busy               (tx_cal_busy),                                      //          tx_cal_busy.tx_cal_busy
                .rx_cal_busy               (rx_cal_busy),                                      //          rx_cal_busy.rx_cal_busy
                .reconfig_to_xcvr          (reconfig_to_xcvr),                                 //     reconfig_to_xcvr.reconfig_to_xcvr
                .reconfig_from_xcvr        (reconfig_from_xcvr),                               //   reconfig_from_xcvr.reconfig_from_xcvr
                .rx_clklow                 (),                                                 //          (terminated)
                .rx_fref                   (),                                                 //          (terminated)
                .tx_parallel_data          (44'b00000000000000000000000000000000000000000000), //          (terminated)
                .rx_parallel_data          (),                                                 //          (terminated)
                .tx_std_coreclkin          ('0),                                             //          (terminated)
                .rx_std_coreclkin          ('0),                                             //          (terminated)
                .tx_std_clkout             (),                                                 //          (terminated)
                .rx_std_clkout             (),                                                 //          (terminated)
                .tx_std_elecidle           ('0),                                             //          (terminated)
                .tx_std_pcfifo_full        (),                                                 //          (terminated)
                .tx_std_pcfifo_empty       (),                                                 //          (terminated)
                .rx_std_pcfifo_full        (),                                                 //          (terminated)
                .rx_std_pcfifo_empty       (),                                                 //          (terminated)
                .rx_std_byteorder_ena      ('0),                                             //          (terminated)
                .rx_std_byteorder_flag     (),                                                 //          (terminated)
                .rx_std_bitrev_ena         ('0),                                             //          (terminated)
                .rx_std_byterev_ena        ('0),                                             //          (terminated)
                .tx_std_polinv             ('0),                                             //          (terminated)
                .rx_std_polinv             ('0),                                             //          (terminated)
                .tx_std_bitslipboundarysel (5'b00000),                                         //          (terminated)
                .rx_std_bitslipboundarysel (),                                                 //          (terminated)
                .rx_std_bitslip            ('0),                                             //          (terminated)
                .rx_std_wa_patternalign    ('0),                                             //          (terminated)
                .rx_std_wa_a1a2size        ('0),                                             //          (terminated)
                .rx_std_rmfifo_full        (),                                                 //          (terminated)
                .rx_std_rmfifo_empty       (),                                                 //          (terminated)
                .rx_std_runlength_err      (),
                .rx_std_signaldetect       ()                                                  //          (terminated)
            );
        end    
        else begin
          if (operation_mode=="DUPLEX" || operation_mode=="duplex" || operation_mode=="Duplex")
              if (word_aligner_mode=="deterministic_latency")
                    native_phy native_phy_inst (
                    .pll_powerdown({lanes{pll_powerdown}}), 
                    .tx_analogreset(tx_analogreset), // for tx pma
                    .tx_digitalreset(), // for TX PCS
                    .tx_pll_refclk(pll_ref_clk),
                    .tx_pma_clkout(tx_clkout),   // TX Parallel clock output from PMA
                    .tx_serial_data(tx_serial_data),
                    .tx_pma_parallel_data(tx_pcsdata),
                    .pll_locked(pll_locked_ch),
                    .rx_analogreset(rx_analogreset), // for rx pma
                    .rx_digitalreset(), //for rx pcs
                    .rx_cdr_refclk(cdr_ref_clk),
                    .rx_pma_clkout(rx_clkout),   // RX Parallel clock output from PMA
                    .rx_serial_data(rx_serial_data),
                    .rx_seriallpbken(rx_seriallpbken),
                    .rx_pma_parallel_data(rx_pcsdata),
                    .rx_clkslip(boundary_slip),
                    .rx_set_locktodata(rx_set_locktodata),
                    .rx_set_locktoref(rx_set_locktoref),
                    .rx_is_lockedtoref(rx_is_lockedtoref),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .tx_cal_busy(tx_cal_busy),  
                    .rx_cal_busy(rx_cal_busy),
                    .reconfig_to_xcvr(reconfig_to_xcvr),
                    .reconfig_from_xcvr(reconfig_from_xcvr)
                    );
                else //manual mode
                    native_phy native_phy_inst (
                    .pll_powerdown({lanes{pll_powerdown}}), 
                    .tx_analogreset(tx_analogreset), // for tx pma
                    .tx_digitalreset(), // for TX PCS
                    .tx_pll_refclk(pll_ref_clk),
                    .tx_pma_clkout(tx_clkout),   // TX Parallel clock output from PMA
                    .tx_serial_data(tx_serial_data),
                    .tx_pma_parallel_data(tx_pcsdata),
                    .pll_locked(pll_locked_ch),
                    .rx_analogreset(rx_analogreset), // for rx pma
                    .rx_digitalreset(), //for rx pcs
                    .rx_cdr_refclk(cdr_ref_clk),
                    .rx_pma_clkout(rx_clkout),   // RX Parallel clock output from PMA
                    .rx_serial_data(rx_serial_data),
                    .rx_seriallpbken(rx_seriallpbken),
                    .rx_pma_parallel_data(rx_pcsdata),
                    .rx_set_locktodata(rx_set_locktodata),
                    .rx_set_locktoref(rx_set_locktoref),
                    .rx_is_lockedtoref(rx_is_lockedtoref),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .tx_cal_busy(tx_cal_busy),  
                    .rx_cal_busy(rx_cal_busy),
                    .reconfig_to_xcvr(reconfig_to_xcvr),
                    .reconfig_from_xcvr(reconfig_from_xcvr)
                    );
                
          else if (operation_mode=="TX" || operation_mode=="tx" || operation_mode=="Tx")
          begin
                native_phy_tx native_phy_tx_inst (
                .pll_powerdown({lanes{pll_powerdown}}), 
                .tx_analogreset(tx_analogreset), // for tx pma
                .tx_digitalreset(), // for TX PCS
                .tx_pll_refclk(pll_ref_clk),
                .tx_pma_clkout(tx_clkout),   // TX Parallel clock output from PMA
                .tx_serial_data(tx_serial_data),
                .tx_pma_parallel_data(tx_pcsdata),
                .pll_locked(pll_locked_ch),
                .tx_cal_busy(tx_cal_busy),  
                .reconfig_to_xcvr(reconfig_to_xcvr),
                .reconfig_from_xcvr(reconfig_from_xcvr)
                );
                
                assign rx_cal_busy = '0;
                assign rx_is_lockedtoref = '0;
                assign rx_is_lockedtodata = '0;
                assign boundary_slip = '0;
                assign rx_clkout = '0;
                assign rx_pcsdata = '0;
            end 
          else if (operation_mode=="RX" || operation_mode=="rx" || operation_mode=="Rx")
          begin
              if (word_aligner_mode=="deterministic_latency")
                    native_phy_rx native_phy_rx_inst (
                    .rx_analogreset(rx_analogreset), // for rx pma
                    .rx_digitalreset(), //for rx pcs
                    .rx_cdr_refclk(cdr_ref_clk),
                    .rx_pma_clkout(rx_clkout),   // RX Parallel clock output from PMA
                    .rx_serial_data(rx_serial_data),
                    .rx_pma_parallel_data(rx_pcsdata),
                    .rx_clkslip(boundary_slip),
                    .rx_set_locktodata(rx_set_locktodata),
                    .rx_set_locktoref(rx_set_locktoref),
                    .rx_is_lockedtoref(rx_is_lockedtoref),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .rx_cal_busy(rx_cal_busy),
                    .reconfig_to_xcvr(reconfig_to_xcvr),
                    .reconfig_from_xcvr(reconfig_from_xcvr)
                    );
                else //manual mode
                    native_phy_rx native_phy_rx_inst (
                    .rx_analogreset(rx_analogreset), // for rx pma
                    .rx_digitalreset(), //for rx pcs
                    .rx_cdr_refclk(cdr_ref_clk),
                    .rx_pma_clkout(rx_clkout),   // RX Parallel clock output from PMA
                    .rx_serial_data(rx_serial_data),
                    .rx_pma_parallel_data(rx_pcsdata),
                    .rx_set_locktodata(rx_set_locktodata),
                    .rx_set_locktoref(rx_set_locktoref),
                    .rx_is_lockedtoref(rx_is_lockedtoref),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .rx_cal_busy(rx_cal_busy),
                    .reconfig_to_xcvr(reconfig_to_xcvr),
                    .reconfig_from_xcvr(reconfig_from_xcvr)
                    );

                assign tx_cal_busy = '0;
                assign pll_locked_ch = '0;
                assign tx_serial_data = '0;
                assign tx_clkout = '0;
            end
            else
                initial $display("Error: Native phy is not instantiated due to invalid operation mode=%s.",operation_mode);
        end
    end        
    endgenerate
    
endmodule