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

module altera_xcvr_detlatency_top_phy #(
  
    parameter device_family = "Arria V",
    parameter operation_mode    = "Duplex",                   //legal value: TX,RX,Duplex
    parameter lanes             = 1,                          //legal value: 1+
    parameter ser_base_factor   = 8,                          //legal value: 8,10
    parameter ser_words         = 4,                          //legal value 1,2,4
    parameter ser_words_pma_size  = 4,                        // the value should be ceil of log2 ser_words on PMA side
    parameter pcs_pma_width     = 80,                         // 8G - 8|10|16|20|32|40, PMA_DIR-8|10|16|20|32|40|64|80
    parameter data_width_pma_size = 7,                        // the value should be log2 of pcs_pma_width
    parameter data_rate         = "9830.4 Mbps",              // user entered data rate always in mbps
    parameter base_data_rate    = "0 Mbps",                   // (PLL Rate) - must be (data_rate * 1,2,4,or8) in mbps
    parameter tx_pma_clk_div    = 1,                          // (1,2,4,8) CGB clock divider value
    parameter pll_feedback_path = "no_compensation",          //legal: no_compensation, tx_clkout
    parameter word_aligner_mode = "deterministic_latency",    //legal value: deterministic_latency or manual
    
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
    parameter embedded_reset    = 1,             // (0,1) 1-Enable embedded reset controller
    parameter channel_interface = 0,             //legal value: (0,1) 1-Enable channel reconfiguration
    parameter mgmt_clk_in_mhz   = 150,           //needed for reset controller timed delays
    parameter ref_design        = 1              //legal value: (0,1) 1-Instantiate the native phy and reset controller thru UI

) (
    input  wire phy_mgmt_clk,
    input  wire phy_mgmt_clk_reset,
    input  wire phy_mgmt_read,
    input  wire phy_mgmt_write,
    input  wire [8:0] phy_mgmt_address,
    input  wire [31:0] phy_mgmt_writedata,
    output wire [31:0] phy_mgmt_readdata,
    output wire phy_mgmt_waitrequest,
    // Reset inputs
    input  wire [plls -1:0] pll_powerdown, 
    input  wire [lanes-1:0] tx_analogreset,
    input  wire [lanes-1:0] tx_digitalreset,
    input  wire [lanes-1:0] rx_analogreset,
    input  wire [lanes-1:0] rx_digitalreset,
    input  wire [lanes-1:0] tx_fiforeset,
    input  wire [lanes-1:0] rx_fiforeset,
    input     wire [lanes-1:0] tx_fifocalreset,
    input     wire [lanes-1:0] rx_fifocalreset,
    // Calibration busy signals
    output wire [lanes-1:0] tx_cal_busy,
    output wire [lanes-1:0] rx_cal_busy,
    //clk signal
    input  wire [pll_refclk_cnt-1:0] pll_ref_clk,
    input  wire [cdr_refclk_cnt-1:0] cdr_ref_clk,
    input  wire usr_pma_clk,
    input  wire usr_clk,
    input  wire fifo_calc_clk,
    
    input wire [lanes*data_width_pma_size-1:0] data_width_pma,
    
    output wire [lanes-1:0] tx_clkout,
    output wire [lanes-1:0] rx_clkout,
    //data ports - Avalon ST interface
    input  wire [lanes-1:0] rx_serial_data,
    output wire [(channel_interface? 64: ser_base_factor*ser_words)*lanes-1:0] rx_parallel_data,
    input  wire [(channel_interface? 44: ser_base_factor*ser_words)*lanes-1:0] tx_parallel_data,
    output wire [lanes-1:0] tx_serial_data,
    //more optional data
    input  wire [lanes*ser_words-1:0] tx_datak,
    output wire [lanes*ser_words-1:0] rx_datak,
    input  wire [lanes*`BOUNDARY_WIDTH-1:0] tx_bitslipboundaryselect,
    output wire [lanes*`BOUNDARY_WIDTH-1:0] rx_bitslipboundaryselectout,
    output wire [lanes*ser_words-1:0] rx_disperr,
    output wire [lanes*ser_words-1:0] rx_errdetect,
    output wire [lanes*ser_words-1:0] rx_runningdisp,
    output wire [lanes*ser_words-1:0] rx_patterndetect,
    
    //PMA block control and status
    output wire [plls-1:0] pll_locked,  // conduit or ST
    output wire [lanes-1:0] rx_is_lockedtoref,  //conduit or ST
    output wire [lanes-1:0] rx_is_lockedtodata, //conduit or ST
    
    //word alignment
    output wire [lanes*ser_words-1:0] rx_syncstatus,  //conduit or ST
    //reset controller
    output wire tx_ready, //conduit
    output wire rx_ready, //conduit
    
    input  wire    [`FIFO_SAMPLE_SIZE_WIDTH-1:0] tx_fifo_sample_size,
    input  wire    [`FIFO_SAMPLE_SIZE_WIDTH-1:0] rx_fifo_sample_size,
    output wire [lanes*`FIFO_PH_MEASURE_ACC-1:0] tx_phase_measure_acc,
    output wire    [lanes*`FIFO_PH_MEASURE_ACC-1:0] rx_phase_measure_acc,
    output wire    [lanes*(tx_fifo_depth+1)-1:0] tx_fifo_latency,
    output wire    [lanes*(rx_fifo_depth+1)-1:0] rx_fifo_latency,
    output wire                      [lanes-1:0] tx_ph_acc_valid,
    output wire                      [lanes-1:0] rx_ph_acc_valid,
    output wire                      [lanes-1:0] tx_wr_full,
    output wire                      [lanes-1:0] rx_wr_full,
    output wire                      [lanes-1:0] tx_rd_empty,
    output wire                      [lanes-1:0] rx_rd_empty,     
    output wire [lanes-1:0] error,
    //reconfig
    input   wire  [altera_xcvr_functions::get_custom_reconfig_to_width  (device_family,operation_mode,lanes,plls,1)-1:0] reconfig_to_xcvr,
    output  wire  [altera_xcvr_functions::get_custom_reconfig_from_width(device_family,operation_mode,lanes,plls,1)-1:0] reconfig_from_xcvr 
);

// Parameter validation
initial begin
  if(device_family!="Arria V") begin
    $display("Critical Warning: Parameter 'device_family' of instance '%m' has illegal value '%s' assigned to it.", device_family);
  end

  if(pll_feedback_path!="no_compensation" && pll_feedback_path!="tx_clkout") begin
    $display("Critical Warning: Parameter 'pll_feedback_path' of instance '%m' has illegal value '%s' assigned to it.", pll_feedback_path);
  end

  if(word_aligner_mode!="deterministic_latency" && word_aligner_mode!="manual") begin
    $display("Critical Warning: Parameter 'word_aligner_mode' of instance '%m' has illegal value '%s' assigned to it.", word_aligner_mode);
  end
end
// End parameter validation

//////////////////////////////////
// Control & status register map (CSR) outputs
//////////////////////////////////
wire                csr_reset_tx_digital;         //to reset controller
wire                csr_reset_rx_digital;         //to reset controller
wire                csr_reset_all;                //to reset controller
wire                csr_pll_powerdown;            //to xcvr instance
wire [lanes-1:0]    csr_tx_digitalreset;          //to xcvr instance
wire [lanes-1:0]    csr_rx_analogreset;           //to xcvr instance
wire [lanes-1:0]    csr_rx_digitalreset;          //to xcvr instance
wire [lanes-1:0]    csr_phy_loopback_serial;      //to xcvr instance
wire [lanes-1:0]    csr_rx_set_locktoref;         //to xcvr instance
wire [lanes-1:0]    csr_rx_set_locktodata;        //to xcvr instance
wire [lanes-1:0]    csr_rx_enapatternalign;       //to xcvr instance
wire [lanes*`BOUNDARY_WIDTH-1:0]  csr_tx_bitslipboundaryselect; //to xcvr instance

// readdata output from both CSR blocks
wire [31:0]     mgmt_readdata_common;
wire [31:0]     mgmt_readdata_pcs;


//////////////////////////////////
//reset controller outputs
//////////////////////////////////
wire              reset_controller_pll_powerdown;
wire  [lanes-1:0] reset_controller_tx_digitalreset;
wire  [lanes-1:0] reset_controller_rx_analogreset;
wire  [lanes-1:0] reset_controller_rx_digitalreset;
wire  [lanes-1:0] reset_controller_tx_ready;
wire  [lanes-1:0] reset_controller_rx_ready;

// Final reset signals
wire  [plls-1:0]  pll_powerdown_fnl;
wire  [lanes-1:0] tx_analogreset_fnl;
wire  [lanes-1:0] tx_digitalreset_fnl;
wire  [lanes-1:0] rx_analogreset_fnl;
wire  [lanes-1:0] rx_digitalreset_fnl;

    assign  pll_powerdown_fnl   = (embedded_reset)  ? {plls {csr_pll_powerdown}} : pll_powerdown;
    assign  tx_analogreset_fnl  = (embedded_reset)  ? {lanes{csr_pll_powerdown}} : tx_analogreset;
    assign  tx_digitalreset_fnl = csr_tx_digitalreset | (embedded_reset ? {lanes{1'b0}} : tx_digitalreset);
    assign  rx_analogreset_fnl  = csr_rx_analogreset  | (embedded_reset ? {lanes{1'b0}} : rx_analogreset );
    assign  rx_digitalreset_fnl = csr_rx_digitalreset | (embedded_reset ? {lanes{1'b0}} : rx_digitalreset);
     
    altera_xcvr_detlatency_top_phy_native #(
      .operation_mode(operation_mode),
      .lanes(lanes),
      .ser_base_factor(ser_base_factor),
      .ser_words(ser_words),
      .ser_words_pma_size(ser_words_pma_size),
      .pcs_pma_width(pcs_pma_width),
      .data_width_pma_size(data_width_pma_size),
      .data_rate(data_rate),
      .base_data_rate(base_data_rate),
      .tx_pma_clk_div(tx_pma_clk_div),
      .pll_feedback_path(pll_feedback_path),
      .word_aligner_mode(word_aligner_mode),
    
      //PLL
      .pll_refclk_cnt   (pll_refclk_cnt),
      .pll_refclk_freq  (pll_refclk_freq),
      .pll_refclk_select(pll_refclk_select),
      .plls             (plls),
      .pll_type         (pll_type),
      .pll_select       (pll_select),
      .pll_reconfig     (pll_reconfig),
      .cdr_refclk_cnt   (cdr_refclk_cnt),
      .cdr_refclk_freq  (cdr_refclk_freq),
      .cdr_refclk_select(cdr_refclk_select),
      .cdr_reconfig     (cdr_reconfig),
    
        .tx_fifo_depth    (tx_fifo_depth),
        .rx_fifo_depth    (rx_fifo_depth),
        .channel_interface(channel_interface),
        .ref_design       (ref_design)
  
    ) top_phy_native (
        .tx_analogreset(tx_analogreset_fnl),
        .pll_powerdown(pll_powerdown_fnl),
        .tx_digitalreset(tx_digitalreset_fnl),
        .rx_analogreset(rx_analogreset_fnl),
        .rx_digitalreset(rx_digitalreset_fnl),
        .tx_fiforeset(tx_fiforeset),
        .rx_fiforeset(rx_fiforeset),
        .tx_fifocalreset(tx_fifocalreset),
        .rx_fifocalreset(rx_fifocalreset),
        .tx_cal_busy(tx_cal_busy),
        .rx_cal_busy(rx_cal_busy),
        .pll_ref_clk(pll_ref_clk),
        .cdr_ref_clk(cdr_ref_clk),
        .usr_pma_clk(usr_pma_clk),
        .usr_clk(usr_clk),
        .fifo_calc_clk(fifo_calc_clk),
        .data_width_pma(data_width_pma),
        .tx_clkout(tx_clkout),
        .rx_clkout(rx_clkout),
        .tx_parallel_data(tx_parallel_data),
        .rx_parallel_data(rx_parallel_data),
        .tx_datak(tx_datak),
        .rx_datak(rx_datak),
        .tx_serial_data(tx_serial_data),
        .rx_serial_data(rx_serial_data),
        .tx_bitslipboundaryselect(tx_bitslipboundaryselect | csr_tx_bitslipboundaryselect), //what is the csr_tx_bitslipboundaryselect??
        .rx_seriallpbken(csr_phy_loopback_serial),
        .rx_set_locktodata(csr_rx_set_locktodata),
        .rx_set_locktoref(csr_rx_set_locktoref),
        .rx_enapatternalign(csr_rx_enapatternalign),
        .rx_patterndetect(rx_patterndetect),
        .rx_syncstatus(rx_syncstatus),
        .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout),
        .rx_errdetect(rx_errdetect),
        .rx_disperr(rx_disperr),
        .rx_runningdisp(rx_runningdisp),
        .pll_locked(pll_locked),
        .rx_is_lockedtoref(rx_is_lockedtoref),
        .rx_is_lockedtodata(rx_is_lockedtodata),
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
        .error(error),
        .reconfig_from_xcvr(reconfig_from_xcvr),
        .reconfig_to_xcvr(reconfig_to_xcvr)
    ); // module altera_xcvr_detlatency_top_phy_native

    // Instantiate memory map logic for given number of lanes & PLL's
    // Includes all except PCS
    alt_xcvr_csr_common #(
        .lanes  (lanes),
        .plls   (plls ),
        .rpc    (1    )
    ) csr (
        .clk                              (phy_mgmt_clk                     ),
        .reset                            (phy_mgmt_clk_reset               ),
        .address                          (phy_mgmt_address[7:0]            ),
        .read                             (phy_mgmt_read                    ),
        .write                            (phy_mgmt_write                   ),
        .writedata                        (phy_mgmt_writedata               ),
        .pll_locked                       (pll_locked                       ),
        .rx_is_lockedtoref                (rx_is_lockedtoref                ),
        .rx_is_lockedtodata               (rx_is_lockedtodata               ),
        .rx_signaldetect                  (                                 ),
        .reset_controller_tx_ready        (tx_ready                         ),
        .reset_controller_rx_ready        (rx_ready                         ),
        .reset_controller_pll_powerdown   (reset_controller_pll_powerdown   ),
        .reset_controller_tx_digitalreset (reset_controller_tx_digitalreset ),
        .reset_controller_rx_analogreset  (reset_controller_rx_analogreset  ),
        .reset_controller_rx_digitalreset (reset_controller_rx_digitalreset ),
        .readdata                         (mgmt_readdata_common             ),
        .csr_reset_tx_digital             (csr_reset_tx_digital             ),
        .csr_reset_rx_digital             (csr_reset_rx_digital             ),
        .csr_reset_all                    (csr_reset_all                    ),
        .csr_pll_powerdown                (csr_pll_powerdown                ),
        .csr_tx_digitalreset              (csr_tx_digitalreset              ),
        .csr_rx_analogreset               (csr_rx_analogreset               ),
        .csr_rx_digitalreset              (csr_rx_digitalreset              ),
        .csr_phy_loopback_serial          (csr_phy_loopback_serial          ),
        .csr_rx_set_locktoref             (csr_rx_set_locktoref             ),
        .csr_rx_set_locktodata            (csr_rx_set_locktodata            )
    );

    // generate waitrequest for 'top' channel
    altera_wait_generate top_wait (
        .rst            (phy_mgmt_clk_reset   ),
        .clk            (phy_mgmt_clk         ),
        .launch_signal  (phy_mgmt_read        ),
        .wait_req       (phy_mgmt_waitrequest )
    );
    
    
    // Instantiate PCS memory map logic for given number of lanes
    alt_xcvr_csr_pcs8g #(
        .lanes  (lanes    ),
        .words  (ser_words),
        .boundary_width (`BOUNDARY_WIDTH)
    ) csr_pcs (
        .clk                          (phy_mgmt_clk                 ),
        .reset                        (phy_mgmt_clk_reset           ),
        .address                      (phy_mgmt_address[7:0]        ),
        .read                         (phy_mgmt_read                ),
        .write                        (phy_mgmt_write               ),
        .writedata                    (phy_mgmt_writedata           ),
        .readdata                     (mgmt_readdata_pcs            ),
        .rx_clk                       (rx_clkout[0]                 ),
        .tx_clk                       (tx_clkout[0]                 ),
        .rx_patterndetect             (rx_patterndetect             ),
        .rx_syncstatus                (rx_syncstatus                ),
        .rlv                          ('0                           ),
        .rx_phase_comp_fifo_error     ('0                           ),
        .tx_phase_comp_fifo_error     ('0                           ),
        .rx_errdetect                 (rx_errdetect                 ),
        .rx_disperr                   (rx_disperr                   ),
        .rx_bitslipboundaryselectout  (rx_bitslipboundaryselectout  ),
        .rx_a1a2sizeout               ('0                           ),
        .csr_tx_invpolarity           (/*unused*/                   ),
        .csr_rx_invpolarity           (/*unused*/                   ),
        .csr_rx_bitreversalenable     (/*unused*/                   ),
        .csr_rx_bitslip               (/*unused*/                   ),
        .csr_rx_enapatternalign       (csr_rx_enapatternalign       ),
        .csr_rx_bytereversalenable    (/*unused*/                   ),
        .csr_rx_a1a2size              (/*unused*/                   ),
        .csr_tx_bitslipboundaryselect (csr_tx_bitslipboundaryselect )
    );

    // combine readdata output from both CSR blocks
    // each decodes non-overlapping addresses, and outputs "11..111" for undecoded addresses,
    // so an AND is sufficient
    assign phy_mgmt_readdata = mgmt_readdata_common & mgmt_readdata_pcs;

// Reset Controller
generate if (embedded_reset) begin : gen_embedded_reset
// We have a single tx_ready, rx_ready output per IP instance
assign  tx_ready  = &reset_controller_tx_ready;
assign  rx_ready  = &reset_controller_rx_ready;

    //This is Transceiver Phy Reset Controller IP
    //You can open up the Megawizard to modify the parameters for this IP.
    //This is just an example that using the default settings from the IP
    //User will need to run the Megawizard to regenerate all the files required by this IP
    if (!ref_design) begin
        wire  [lanes-1:0]   rx_manual_mode;
        // Put reset controller into manual mode when we are not in auto lock mode
        assign  rx_manual_mode = (csr_rx_set_locktoref | csr_rx_set_locktodata);
        
        localparam TX_ENABLE = (operation_mode != "Rx" && operation_mode != "RX");
        localparam RX_ENABLE = (operation_mode != "Tx" && operation_mode != "TX");
    altera_xcvr_reset_control #(
        .CHANNELS              (lanes),
        .PLLS                  (1),                 //multiple TXPLL will require external reset controller
        .SYS_CLK_IN_MHZ        (mgmt_clk_in_mhz),
        .SYNCHRONIZE_RESET     (0),
        .REDUCED_SIM_TIME      (0),
        .TX_PLL_ENABLE         (TX_ENABLE),
        .T_PLL_POWERDOWN       (1000),
        .SYNCHRONIZE_PLL_RESET (0),
        .TX_ENABLE             (TX_ENABLE),
        .TX_PER_CHANNEL        (0),
        .T_TX_DIGITALRESET     (20),
        .T_PLL_LOCK_HYST       (0),
        .RX_ENABLE             (RX_ENABLE),
        .RX_PER_CHANNEL        (1),   
        .T_RX_ANALOGRESET      (40),
        .T_RX_DIGITALRESET     (4000)
    ) rst_ctrl_inst (
        .clock            (phy_mgmt_clk       ),  // System clock
        .reset            (phy_mgmt_clk_reset ),  // Asynchronous reset
        // Reset signals
        .pll_powerdown    (reset_controller_pll_powerdown   ),  // reset TX PLL
        .tx_analogreset   (/*unused*/                       ),  // reset TX PMA
        .tx_digitalreset  (reset_controller_tx_digitalreset ),  // reset TX PCS
        .rx_analogreset   (reset_controller_rx_analogreset  ),  // reset RX PMA
        .rx_digitalreset  (reset_controller_rx_digitalreset ),  // reset RX PCS
        // Status output
        .tx_ready         (reset_controller_tx_ready        ),  // TX is not in reset
        .rx_ready         (reset_controller_rx_ready        ),  // RX is not in reset
        // Digital reset override inputs (must by synchronous with clock)
        .tx_digitalreset_or({lanes{csr_reset_tx_digital}} ), // reset request for tx_digitalreset
        .rx_digitalreset_or({lanes{csr_reset_rx_digital}} ), // reset request for rx_digitalreset
        // TX control inputs
        .pll_locked         (pll_locked[pll_select] ),  // TX PLL is locked status
        .pll_select         (1'b0                   ),  // Select TX PLL locked signal 
        .tx_cal_busy        (tx_cal_busy            ),  // TX channel calibration status
        .tx_manual          ({lanes{1'b1}}          ),  // 1=Manual TX reset mode
        // RX control inputs
        .rx_is_lockedtodata (rx_is_lockedtodata     ),  // RX CDR PLL is locked to data status
        .rx_cal_busy        (rx_cal_busy            ),  // RX channel calibration status
        .rx_manual          (rx_manual_mode         ) // 1=Manual RX reset mode
    );
        end
        else begin
          if (operation_mode=="DUPLEX" || operation_mode=="duplex" || operation_mode=="Duplex")
                rst_controller rst_ctrl_inst (
                    .clock(phy_mgmt_clk),
                    .reset(phy_mgmt_clk_reset),
                    .pll_powerdown(reset_controller_pll_powerdown),
                    .tx_analogreset(/*unused*/  ),
                    .tx_digitalreset(reset_controller_tx_digitalreset),
                    .tx_ready(reset_controller_tx_ready),
                    .pll_locked({plls{pll_locked[pll_select]}}),
                    .pll_select(1'b0),
                    .tx_cal_busy(tx_cal_busy),
                    .rx_analogreset(reset_controller_rx_analogreset),
                    .rx_digitalreset(reset_controller_rx_digitalreset),
                    .rx_ready(reset_controller_rx_ready),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .rx_cal_busy(rx_cal_busy)
                );
          else if (operation_mode=="TX" || operation_mode=="tx" || operation_mode=="Tx")
          begin
                rst_controller_tx rst_ctrl_inst (
                    .clock(phy_mgmt_clk),
                    .reset(phy_mgmt_clk_reset),
                    .pll_powerdown(reset_controller_pll_powerdown),
                    .tx_analogreset(/*unused*/  ),
                    .tx_digitalreset(reset_controller_tx_digitalreset),
                    .tx_ready(reset_controller_tx_ready),
                    .pll_locked({plls{pll_locked[pll_select]}}),
                    .pll_select(1'b0),
                    .tx_cal_busy(tx_cal_busy)
                );
                assign reset_controller_rx_ready = '0;
            end
          else if (operation_mode=="RX" || operation_mode=="rx" || operation_mode=="Rx")
          begin
                rst_controller_rx rst_ctrl_inst (
                    .clock(phy_mgmt_clk),
                    .reset(phy_mgmt_clk_reset),
                    .rx_analogreset(reset_controller_rx_analogreset),
                    .rx_digitalreset(reset_controller_rx_digitalreset),
                    .rx_ready(reset_controller_rx_ready),
                    .rx_is_lockedtodata(rx_is_lockedtodata),
                    .rx_cal_busy(rx_cal_busy)
                );
                assign reset_controller_tx_ready = '0;
            end
            else
                initial $display("Error: Reset controller phy is not instantiated due to invalid operation mode=%s.",operation_mode);
        end   
      end else begin:gen_no_embedded_reset
        assign  reset_controller_pll_powerdown    = 1'b0;
        assign  reset_controller_tx_digitalreset  = {lanes{1'b0}};
        assign  reset_controller_rx_analogreset   = {lanes{1'b0}};
        assign  reset_controller_rx_digitalreset  = {lanes{1'b0}};
        assign  tx_ready = 1'b0;
        assign  rx_ready = 1'b0;
    end
  endgenerate
  
endmodule
