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


`timescale 1ps/1ps

module ilk_core_50g #(
  // Configuration parameters which can be edited by the user
  // --------------------------------------------------------

  // For data rate = 6.375, one of 159.375, 199.21875, 255, 265.625, 318.75, 398.4375, 510, 531.25, 637.5
  // For data rate = 6.25,  one of 156.25, 195.3125, 250, 312.5, 390.625, 500, 625
  // For data rate = 3.125, one of 156.25, 195.3125, 250, 312.5, 390.625, 500, 625
  parameter PLL_REFCLK_FREQ    = "312.5 MHz",
  // Management clock range is restricted to 100 to 125 MHz by hard logic.
  parameter MM_CLK_KHZ         = 20'd100000,
  // 16 bits per page; Legal settings are 1, 2, 4, 8, or 16.
  parameter CALENDAR_PAGES     = 16,
  // Recommend 64 for fast simulation, 2048 otherwise.
  parameter METALEN            = 2048,
  // If instantiating more than one ilk_core, this value needs to be unique.
  parameter SCRAM_CONST        = 58'hdeadbeef123,
  // For internal reset. Recommend 6 for fast simulation, 20 otherwise.
  parameter CNTR_BITS          = 20,
  // Address width of RX Reassembly FIFO.
  parameter RXFIFO_ADDR_WIDTH  = 11,
  // 1 = enable internal temperature sensing diode. 0 = disabled.
  parameter INCLUDE_TEMP_SENSE = 1'b0,
  // 1 = receiver expects traffic from link partner is packet based
  // 0 = traffic from link partner can be burst interleaved between multiple channels
  parameter RX_PKTMOD_ONLY     = 0,
  // 1 = itx_sob/itx_eob will be ignored and core will use internal enhanced burst scheduling.
  // 0 = User is responsible to provide itx_sob/itx_eob for scheduling bursts.
  parameter TX_PKTMOD_ONLY     = 0,
  // For "Stratix V" and "Arria V GZ" only.
  // Specifies which transceivers are used for Interlaken, 1 bit per lane.
  parameter LANE_PROFILE        = 24'b000000_000000_101101_101101,
  // For "Stratix V" and "Arria V GZ" only.
  // CAREFUL!! : this is MHz, not MBPS, typically 1/2 data rate
  parameter PLL_OUT_FREQ        = "3125.0 MHz",
  // For "Stratix V" and "Arria V GZ" only.
  // 1 = use ATX PLLs. 0 = use CMU PLLs.
  parameter USE_ATX             = 0,
  // For "Stratix V" and "Arria V GZ" only.
  // CGB TX clock divider, typically 1
  parameter INT_TX_CLK_DIV      = 1,
  // 1 = data is striped from lane 0 to lane M
  // 0 = data is striped from lane M to lane 0
  parameter SWAP_TX_LANES       = 1,
  // 1 = data is striped from lane 0 to lane M
  // 0 = data is striped from lane M to lane 0
  parameter SWAP_RX_LANES       = 1,
  // 1 = bypass input register in channel filter and packet_annotate for latency improvement
  // 0 = don't bypass input register
  parameter BYPASS_INPUT_REG    = 1,
  // 1 = don't wait for RX lanes to align before enabling TX path
  parameter TX_ONLY_MODE        = 1'b0,


  // Fixed parameters. Do not modify without consulting Altera.
  // ----------------------------------------------------------
  // Can be "Stratix V" (includes GX or GT); or "Arria V GZ"; or "Arria 10";
  parameter FAMILY              = "Stratix V",
  // Number of bi-directional Interlaken lanes.
  parameter NUM_LANES           = 8,
  // Specifies the link bandwidth, per lane.
  parameter DATA_RATE           = "6250.0 Mbps",
  // Width of user data bus, in 8-byte words.
  parameter INTERNAL_WORDS      = 4,
  // Can be set to 1 in designs which share MAC and PCS clock.
  parameter BYPASS_LOOSEFIFO    = 0,
  // Bit width of each logical reconfiguration input interface.
  parameter W_BUNDLE_TO_XCVR    = 70,
  // Bit width of each logical reconfiguration output interface.
  parameter W_BUNDLE_FROM_XCVR  = 46,
  // Number of bits to express INTERNAL_WORDS
  parameter LOG_INTERNAL_WORDS  = ( INTERNAL_WORDS == 4 ) ? 3 : 4,
  // Number of bits to express CALENDAR_PAGES
  parameter LOG_CALENDAR_PAGES  = ( CALENDAR_PAGES == 16 ) ? 4 : (
                                  ( CALENDAR_PAGES == 8 )  ? 3 : (
                                  ( CALENDAR_PAGES == 4 )  ? 2 : 1 ) ),
  parameter MM_CLK_MHZ          = MM_CLK_KHZ * 1000,
  parameter NUM_SIXPACKS        = count_sixpacks( LANE_PROFILE ),
  parameter DIAG_ON               = 1,
  parameter NUM_PLLS            = NUM_SIXPACKS
)(
  input                                tx_usr_clk, // the 300MHz clock
  input                                rx_usr_clk, // the 300MHz clock
  input                                reset_n,
  input                                pll_ref_clk,

  input       [NUM_LANES-1:0]          rx_pin,
  output wire [NUM_LANES-1:0]          tx_pin,
  output wire [NUM_LANES-1:0]          sync_locked,      //
  output wire [NUM_LANES-1:0]          word_locked,      //
  output wire                          tx_lanes_aligned,
  output wire                          rx_lanes_aligned,

  input       [64*INTERNAL_WORDS-1:0]  itx_din_words,
  input       [LOG_INTERNAL_WORDS-1:0] itx_num_valid,
  input       [7:0]                    itx_chan,
  input                                itx_sop,
  input       [3:0]                    itx_eopbits,
  input                                itx_sob, // new
  input                                itx_eob, // new
  input       [16*CALENDAR_PAGES-1:0]  itx_calendar,

  input       [3:0]                    burst_max_in,   //Static input. In multiple of 64 byte. 2: 128 byte, 4: 256 byte.
  input       [3:0]                    burst_short_in, //Static input. In multiple of 32 byte. 1: 32  byte, 2: 64 byte.
  input       [3:0]                    burst_min_in,   //Static input. In multiple of 32 byte. 1: 32  byte, 2: 64 byte.

  output reg                           itx_ready,
  output wire                          itx_hungry,
  output wire                          itx_overflow,   // .overflow
  output wire                          itx_underflow,  // .underflow
  output wire                          crc24_err,      // .crc24_err
  output wire [NUM_LANES-1:0]          crc32_err,
  output                               clk_tx_common,
  output                               srst_tx_common,
  output                               clk_rx_common,
  output                               srst_rx_common,
  output                               tx_mac_srst,    //When this is low, it indicates TX Mac logic is out of reset.
  output                               rx_mac_srst,    //When this is low, it indicates RX Mac logic is out of reset.
  output                               tx_usr_srst,    //When this is low, it indicates TX user logic is out of reset.
  output                               rx_usr_srst,    //When this is low, it indicates RX user logic is out of reset.

  output wire [64*INTERNAL_WORDS-1:0]  irx_dout_words, //
  output wire [LOG_INTERNAL_WORDS-1:0] irx_num_valid,  //
  output wire                          irx_sop,        //
  output wire                          irx_sob,        //
  output wire                          irx_eob,        //
  output wire [3:0]                    irx_eopbits,    //
  output wire                          irx_err,
  output wire [7:0]                    irx_chan,       //
  output wire [16*CALENDAR_PAGES-1:0]  irx_calendar,
  output wire                          irx_overflow,
  output wire                          rdc_overflow,
  output wire                          rg_overflow,    // rx_status_mac.rx_overflow
  output wire [RXFIFO_ADDR_WIDTH-1:0]  rxfifo_fill_level,

  // Signals to increment debug counters, indicate errors
  output                               sop_cntr_inc,
  output                               eop_cntr_inc,
  output                               nad_cntr_inc,

  // config and status port and related signals
  input                                mm_clk,        // 100 MHz
  input                                mm_clk_locked, // loss of lock restarts GX / CPU reset sequence
  input                                mm_read,
  input                                mm_write,
  input       [15:0]                   mm_addr,
  output      [31:0]                   mm_rdata,
  output                               mm_rdata_valid,
  input       [31:0]                   mm_wdata,

  input  [W_BUNDLE_TO_XCVR*(NUM_LANES+NUM_PLLS)-1:0]   reconfig_to_xcvr,
  output [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_PLLS)-1:0] reconfig_from_xcvr,

  // For Arria 10
  output      [NUM_PLLS-1:0]           tx_pll_powerdown,
  input       [NUM_PLLS-1:0]           tx_pll_locked,
  input       [NUM_LANES-1:0]          tx_serial_clk,
  output                               mm_waitrequest
);

/*
// =======================
// OOB modules
// ======================
ilk_oob_flow_rx #(
  .CAL_BITS  (16),
  .NUM_LANES (NUM_LANES)
) alt_ilk_oob_rx (
   .sys_clk         (rx_oob_in_sys_clk),          //  rx_oob_in.export
   .sys_arst        (rx_oob_in_sys_arst),         //           .export
   .fc_clk          (rx_oob_in_fc_clk),           //           .export
   .fc_data         (rx_oob_in_fc_data),          //           .export
   .fc_sync         (rx_oob_in_fc_sync),          //           .export
   .lane_status     (rx_oob_out_lane_status),     // rx_oob_out.export
   .link_status     (rx_oob_out_link_status),     //           .export
   .status_update   (rx_oob_out_status_update),   //           .export
   .status_error    (rx_oob_out_status_error),    //           .export
   .calendar        (rx_oob_out_calendar),        //           .export
   .calendar_update (rx_oob_out_calendar_update), //           .export
   .calendar_error  (rx_oob_out_calendar_error)   //           .export
);

ilk_oob_flow_tx #(
  .CAL_BITS  (16),
  .NUM_LANES (NUM_LANES)
) alt_ilk_oob_tx (
  .double_fc_clk  (tx_oob_in_double_fc_clk),  //  tx_oob_in.export
  .double_fc_arst (tx_oob_in_double_fc_arst), //           .export
  .calendar       (tx_oob_in_calendar),       //           .export
  .lane_status    (tx_oob_in_lane_status),    //           .export
  .link_status    (tx_oob_in_link_status),    //           .export
  .ena_status     (tx_oob_in_ena_status),     //           .export
  .fc_clk         (tx_oob_out_clk),           // tx_oob_out.export
  .fc_data        (tx_oob_out_data),          //           .export
  .fc_sync        (tx_oob_out_sync)           //           .export
);
*/

//For Arria 10
wire mm_waitrequest_a10;
wire [NUM_PLLS-1:0] tx_pll_powerdown_a10;
wire [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr_tmp;
   generate
     if (FAMILY == "Arria 10") begin
         assign mm_waitrequest = mm_waitrequest_a10;
         assign tx_pll_powerdown = tx_pll_powerdown_a10;
         assign reconfig_from_xcvr =  {W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS){1'b0}};
     end
     else  begin
       assign mm_waitrequest = 1'b0;
       assign tx_pll_powerdown = {NUM_PLLS{1'b0}};
       assign reconfig_from_xcvr = reconfig_from_xcvr_tmp;
     end
   endgenerate 

localparam USE_HARD_PCS = ( ( FAMILY == "Stratix V" ) || ( FAMILY == "Arria V GZ" ) || ( FAMILY == "Arria 10" ) );
genvar i;

//////////////////////////////////////////////
// PCS
//////////////////////////////////////////////

wire [64*NUM_LANES-1:0]      lane_rxd;
reg  [64*NUM_LANES-1:0]      lane_txd = 0;
reg  [NUM_LANES-1:0]         lane_txd_valid = 0;
reg  [NUM_LANES-1:0]         cap_rxd_valid;

wire                         tx_valid_notbf;
reg                          tx_valid;
wire [NUM_LANES-1:0]         rx_valid;
wire                         tx_cadence;
wire                         tx_pcs_hungry;
reg                          tx_cadence_r;
wire [NUM_LANES-1:0]         rx_control;
reg  [NUM_LANES-1:0]         tx_control = 0;

wire                         rx_lanes_aligned_pcsclk;
wire                         tx_lanes_aligned_pcsclk;
wire [NUM_LANES-1:0]         sync_locked_pcsclk;
wire [NUM_LANES-1:0]         word_locked_pcsclk;
wire [NUM_LANES-1:0]         crc32_err_pcsclk;

wire                         itx_hungry_macclk;
wire                         itx_underflow_macclk;
wire                         crc24_err_macclk;
wire [CALENDAR_PAGES*16-1:0] irx_calendar_macclk;
wire                         irx_overflow_macclk;
wire                         rdc_overflow_pcsclk;
wire                         rg_overflow_macclk;
wire [RXFIFO_ADDR_WIDTH-1:0] rxfifo_fill_level_macclk;

// Currently not used
wire [NUM_LANES-1:0]    sh_err;

//////////////////////////////////////////////
// RX error handler wires
//////////////////////////////////////////////

wire [64*INTERNAL_WORDS-1:0]  core_irx_dout_words; //
wire [LOG_INTERNAL_WORDS-1:0] core_irx_num_valid;  //
wire                          core_irx_sop;        //
wire                          core_irx_sob;        //
wire                          core_irx_eob;        //
wire [7:0]                    core_irx_chan;       //
wire [3:0]                    core_irx_eopbits;    //
wire                          core_irx_crc24_err;

wire [3:0]                    dummy_irx_num_valid_lsb;
wire                          dummy_irx_num_valid_msb;
wire                          dummy_irx_sop;
wire                          dummy_irx_sob;

//////////////////////////////////////////////////////////////////
//Sync all the status signal from the rx side to rx_usr_clk.
//////////////////////////////////////////////////////////////////

generate
  if ( USE_HARD_PCS == 1 ) begin : rlsync
    ilk_status_sync ss_sync_locked (.clk(rx_usr_clk),.din(sync_locked_pcsclk),.dout(sync_locked));
    defparam ss_sync_locked .WIDTH = NUM_LANES;

    ilk_status_sync ss_word_locked (.clk(rx_usr_clk),.din(word_locked_pcsclk),.dout(word_locked));
    defparam ss_word_locked .WIDTH = NUM_LANES;

    ilk_status_sync ss_rx_all_locked (.clk(rx_usr_clk),.din(rx_lanes_aligned_pcsclk),.dout(rx_lanes_aligned));
    defparam ss_rx_all_locked .WIDTH = 1;

    ilk_status_sync ss_crc32_err (.clk(rx_usr_clk),.din(crc32_err_pcsclk),.dout(crc32_err));
    defparam ss_crc32_err .WIDTH = NUM_LANES;

    ilk_status_sync ss_rdc_overflow (.clk(rx_usr_clk),.din(rdc_overflow_pcsclk),.dout(rdc_overflow));
    defparam ss_rdc_overflow .WIDTH = 1;
  end else begin : rlsyncb
    // soft PCS output is already in usr clock domain
    assign sync_locked      = sync_locked_pcsclk;
    assign word_locked      = word_locked_pcsclk;
    assign rx_lanes_aligned = rx_lanes_aligned_pcsclk;
    assign crc32_err        = crc32_err_pcsclk;
    assign rdc_overflow     = rdc_overflow_pcsclk;
  end
endgenerate

//ilk_status_sync ss_crc24_err (.clk(rx_usr_clk),.din(crc24_err_macclk),.dout(crc24_err));
//defparam ss_crc24_err .WIDTH = 1;

//ilk_status_sync ss_irx_calendar (.clk(rx_usr_clk),.din(irx_calendar_macclk),.dout(irx_calendar));
//defparam ss_irx_calendar .WIDTH = CALENDAR_PAGES*16;

//ilk_status_sync ss_irx_overflow (.clk(rx_usr_clk),.din(irx_overflow_macclk),.dout(irx_overflow));
//defparam ss_irx_overflow .WIDTH = 1;

//ilk_status_sync ss_rg_overflow (.clk(rx_usr_clk),.din(rg_overflow_macclk),.dout(rg_overflow));
//defparam ss_rg_overflow .WIDTH = 1;

//ilk_status_sync ss_rxfifo_fill_level (.clk(rx_usr_clk),.din(rxfifo_fill_level_macclk),.dout(rxfifo_fill_level));
//defparam ss_rxfifo_fill_level .WIDTH = RXFIFO_ADDR_WIDTH;

//////////////////////////////////////////////////////////////////
//Sync all the status signal from the tx side to tx_usr_clk.
//////////////////////////////////////////////////////////////////

generate
  if ( USE_HARD_PCS == 1 ) begin : tlsync
    ilk_status_sync ss_tx_all_locked (.clk(tx_usr_clk),.din(tx_lanes_aligned_pcsclk),.dout(tx_lanes_aligned));
    defparam ss_tx_all_locked .WIDTH = 1;
  end else begin : tlsyncb
    // soft PCS output is already in usr clock domain
    assign tx_lanes_aligned = tx_lanes_aligned_pcsclk;
  end
endgenerate

//ilk_status_sync ss_itx_hungry (.clk(tx_usr_clk),.din(itx_hungry_macclk),.dout(itx_hungry));
//defparam ss_itx_hungry .WIDTH = 1;

//ilk_status_sync ss_itx_underflow (.clk(tx_usr_clk),.din(itx_underflow_macclk),.dout(itx_underflow));
//defparam ss_itx_underflow .WIDTH = 1;

//////////////////////////////////////////////////////////////////
// PCS instanciation
//////////////////////////////////////////////////////////////////
generate
  if ( FAMILY == "Arria 10" ) begin
    ilk_hard_pcs_assembly_a10 #(
    //.USE_ATX            (USE_ATX),
      .DATA_RATE          (DATA_RATE),
    //.PLL_OUT_FREQ       (PLL_OUT_FREQ),
      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
    //.INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
    //.LANE_PROFILE       (LANE_PROFILE),
      .NUM_LANES          (NUM_LANES),
    //.NUM_SIXPACKS       (NUM_SIXPACKS),
    //.CNTR_BITS          (CNTR_BITS),
      .METALEN            (METALEN),
      .BYPASS_LOOSEFIFO (BYPASS_LOOSEFIFO), 
      .SCRAM_CONST        (SCRAM_CONST),
      .INCLUDE_TEMP_SENSE (INCLUDE_TEMP_SENSE),
      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
      .MM_CLK_KHZ         (MM_CLK_KHZ),
      .MM_CLK_MHZ         (MM_CLK_MHZ)
    ) hah (
      .pll_ref_clk        (pll_ref_clk),

      // config and status port
      .mm_clk             (mm_clk),
      .mm_clk_locked      (reset_n & mm_clk_locked),   // fires whole analog reset sequence + CPU
      .mm_read            (mm_read),
      .mm_write           (mm_write),
      .mm_addr            (mm_addr),
      .mm_rdata           (mm_rdata),
      .mm_rdata_valid     (mm_rdata_valid),
      .mm_wdata           (mm_wdata),

      // chip HSIO pins
      .rx_pin             (rx_pin),
      .tx_pin             (tx_pin),

      // data streams, msb first on the wire
      .clk_tx_common      (clk_tx_common),
      .srst_tx_common     (srst_tx_common),
      .tx_control         (tx_control),
      .tx_din             (lane_txd),
      .tx_valid           (tx_valid),
      .tx_cadence         (tx_cadence),

      .clk_rx_common      (clk_rx_common),
      .srst_rx_common     (srst_rx_common),
      .tx_pcsfifo_pfull   (tx_pcsfifo_pfull),
      .tx_lanes_aligned   (tx_lanes_aligned_pcsclk),
      .rx_lanes_aligned   (rx_lanes_aligned_pcsclk),
      .rx_dout            (lane_rxd),
      .rx_control         (rx_control),
      .rx_wordlock        (word_locked_pcsclk),
      .rx_metalock        (sync_locked_pcsclk),
      .rx_crc32err        (crc32_err_pcsclk),
      .rx_valid           (rx_valid),  // expected to be the same   across lanes

      // for Arria 10
      .tx_pll_locked      (tx_pll_locked),
      .tx_serial_clk      (tx_serial_clk),

      .pll_powerdown      (tx_pll_powerdown_a10),
      .mm_waitrequest     (mm_waitrequest_a10)

    // Transceiver reconfiguration
    //.reconfig_to_xcvr   (reconfig_to_xcvr),
    //.reconfig_from_xcvr (reconfig_from_xcvr)
    );
  end else if ( ( FAMILY == "Stratix V" ) || ( FAMILY == "Arria V GZ" ) ) begin : hard_pcs
    ilk_pcs_assembly #(
      .USE_ATX            (USE_ATX),
      .DATA_RATE          (DATA_RATE),
      .PLL_OUT_FREQ       (PLL_OUT_FREQ),
      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
      .INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
      .LANE_PROFILE       (LANE_PROFILE),
      .NUM_LANES          (NUM_LANES),
      .NUM_SIXPACKS       (NUM_SIXPACKS),
      .CNTR_BITS          (CNTR_BITS),
      .METALEN            (METALEN),
      .SCRAM_CONST        (SCRAM_CONST),
      .INCLUDE_TEMP_SENSE (INCLUDE_TEMP_SENSE),
      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
      .MM_CLK_KHZ         (MM_CLK_KHZ),
      .DIAG_ON            (DIAG_ON),
      .MM_CLK_MHZ         (MM_CLK_MHZ)
    ) hah (
      .pll_ref_clk        (pll_ref_clk),

      // config and status port
      .mm_clk             (mm_clk),
      .mm_clk_locked      (reset_n & mm_clk_locked),
      .mm_read            (mm_read),
      .mm_write           (mm_write),
      .mm_addr            (mm_addr),
      .mm_rdata           (mm_rdata),
      .mm_rdata_valid     (mm_rdata_valid),
      .mm_wdata           (mm_wdata),

      // chip HSIO pins
      .rx_pin             (rx_pin),
      .tx_pin             (tx_pin),

      // data streams, msb first on the wire
      .clk_tx_common      (clk_tx_common),
      .srst_tx_common     (srst_tx_common),
      .tx_control         (tx_control),
      .tx_din             (lane_txd),
      .tx_valid           (tx_valid),
      .tx_cadence         (tx_cadence),

      .clk_rx_common      (clk_rx_common),
      .srst_rx_common     (srst_rx_common),

      .tx_lanes_aligned   (tx_lanes_aligned_pcsclk), //
      .rx_lanes_aligned   (rx_lanes_aligned_pcsclk), //
      .rx_dout            (lane_rxd),
      .rx_control         (rx_control),
      .rx_wordlock        (word_locked_pcsclk),      //
      .rx_metalock        (sync_locked_pcsclk),      //
      .rx_crc32err        (crc32_err_pcsclk),        //
      .rx_sh_err          (sh_err),
      .rx_valid           (rx_valid),  // expected to be the same across lanes
      .reconfig_to_xcvr   (reconfig_to_xcvr),
      .reconfig_from_xcvr (reconfig_from_xcvr_tmp)
    );
  end
endgenerate

//////////////////////////////////////////////
// Ilk TX MAC
//////////////////////////////////////////////
// If the transmit data pipeline is low the hungry signal will activate
// when hungry it is important to either send no data, which will cause
// idle insertion, or to send valid data faster than the lane bandwidth
// in order to catch up.  AUTO mode will force idles

always @(posedge clk_tx_common or posedge srst_tx_common) begin
  if (srst_tx_common) begin
    tx_cadence_r <= 1'b0;
  end else begin
    tx_cadence_r <= tx_cadence;
  end
end

always @* begin
  if ((USE_HARD_PCS == 1)) begin
    tx_valid = tx_cadence_r;
  end else begin
    tx_valid = tx_valid_notbf;
  end
end

wire                         itx_ack, enhance_ack;
wire                         rx_lanes_aligned_tx_usr_clk;
wire [65*NUM_LANES-1:0]      itx_lanewords;
reg  [16*CALENDAR_PAGES-1:0] itx_calendar_r;

//////////////////////////////////////////////
//reset delay process
//////////////////////////////////////////////
ilk_rst_ctrl rst_ctrl (
  .srst_tx_common (srst_tx_common),
  .srst_rx_common (srst_rx_common),
  .tx_mac_clk     (clk_tx_common),
  .rx_mac_clk     (clk_rx_common),
  .reset_n        (reset_n),
  .tx_usr_clk     (tx_usr_clk),
  .rx_usr_clk     (rx_usr_clk),

  .tx_mac_srst    (tx_mac_srst),
  .rx_mac_srst    (rx_mac_srst),
  .tx_usr_srst    (tx_usr_srst),
  .rx_usr_srst    (rx_usr_srst)
);
defparam rst_ctrl .CNTR_BITS = CNTR_BITS;

ilk_status_sync ss0 (.clk(tx_usr_clk),.din(rx_lanes_aligned_pcsclk|TX_ONLY_MODE),.dout(rx_lanes_aligned_tx_usr_clk));
defparam ss0 .WIDTH = 1;

always @(posedge tx_usr_clk or posedge tx_usr_srst)
  if (tx_usr_srst) begin
    itx_calendar_r <= 0;
    itx_ready      <= 0;
  end else begin
    if (rx_lanes_aligned_tx_usr_clk) itx_calendar_r <= itx_calendar;
    itx_ready <= rx_lanes_aligned_tx_usr_clk & enhance_ack & tx_lanes_aligned;
  end

//assign itx_ready = rx_lanes_aligned_tx_usr_clk & itx_ack & tx_lanes_aligned;

wire [64*INTERNAL_WORDS-1:0]  itx_din_words_buf;
wire [LOG_INTERNAL_WORDS-1:0] itx_num_valid_buf;
wire [7:0]                    itx_chan_buf;
wire                          itx_sop_buf;
wire [3:0]                    itx_eopbits_buf;
wire                          itx_sob_buf;
wire                          itx_eob_buf;

//////////////////////////////////////////////
// instanciation of ilk_iw4_enhance_scheduler
//////////////////////////////////////////////
ilk_iw4_iw2_enhance_scheduler # (
  .TX_PKTMOD_ONLY     (TX_PKTMOD_ONLY),
  .INTERNAL_WORDS     (INTERNAL_WORDS),
  .LOG_INTERNAL_WORDS (LOG_INTERNAL_WORDS),
  .FAMILY             (FAMILY)
) esr (
  .clk               (tx_usr_clk),
  .aclr              (tx_usr_srst),
  .itx_din_words     (itx_din_words),
  .itx_num_valid     (itx_num_valid),
  .itx_chan          (itx_chan),
  .itx_sop           (itx_sop),
  .itx_sob           (itx_sob),
  .itx_eob           (itx_eob),
  .itx_eopbits       (itx_eopbits),
  .burst_max_in      (burst_max_in),
  .burst_min_in      (burst_min_in),
  .itx_ack           (itx_ack),

  .enhance_ack       (enhance_ack),
  .itx_din_words_buf (itx_din_words_buf),
  .itx_num_valid_buf (itx_num_valid_buf),
  .itx_chan_buf      (itx_chan_buf),
  .itx_sop_buf       (itx_sop_buf),
  .itx_eopbits_buf   (itx_eopbits_buf),
  .itx_sob_buf       (itx_sob_buf),
  .itx_eob_buf       (itx_eob_buf)
);

//////////////////////////////////////////////
// instanciation of ilk_iw4_tx_datapath
//////////////////////////////////////////////
ilk_iw4_iw2_tx_datapath #(
  .NUM_LANES          (NUM_LANES),
  .CALENDAR_PAGES     (CALENDAR_PAGES),
  .LOG_CALENDAR_PAGES (LOG_CALENDAR_PAGES),
  .INTERNAL_WORDS     (INTERNAL_WORDS),
  .LOG_INTERNAL_WORDS (LOG_INTERNAL_WORDS),
  .FAMILY             (FAMILY)
) tdp (
  .clk                 (tx_usr_clk), // tx_mac_clk
  .arst                (tx_usr_srst), // tx_mac_srst
  .lane_clk            (clk_tx_common),
  .lane_arst           (srst_tx_common),
  .tx_lanes_aligned    (tx_lanes_aligned),
  .tx_pcsfifo_pfull    (1'b0),

  .din_words           (itx_din_words_buf),
  .num_valid_din_words (itx_num_valid_buf),
  .chan                (itx_chan_buf),
  .sop                 (itx_sop_buf), // SOP and EOP both refer to the current data in
  .sob                 (itx_sob_buf), // new
  .eob                 (itx_eob_buf), // new
  .eopbits             (itx_eopbits_buf),
  .calendar            (itx_calendar_r), // bit 0 ~ chan 0
//.burst_max_in        (burst_max_in),
//.burst_short_in      (burst_short_in),
//.burst_min_in        (burst_min_in),
  .ack                 (itx_ack), // output

  .lanewords           (itx_lanewords),
  .lanewords_valid     (tx_valid_notbf),
  .lanewords_ack       ({NUM_LANES{(USE_HARD_PCS == 0) ? tx_cadence : tx_cadence_r}}),
  .hungry              (itx_hungry),
  .underflow           (itx_underflow),
  .overflow            (itx_overflow)
);

// MAC -> PCS
generate
  if ( USE_HARD_PCS == 1 ) begin
    for (i=0; i<NUM_LANES; i=i+1) begin : ltl
      always @(posedge clk_tx_common or posedge srst_tx_common) begin
        if (srst_tx_common) begin
          lane_txd[(i+1)*64-1:i*64] <= 64'h0;
          lane_txd_valid[i]         <= 1'b0;
          tx_control[i]             <= 1'b0;
        end else begin
          lane_txd_valid[i]         <= tx_valid;
          if (tx_valid) begin
            if (SWAP_TX_LANES)
              {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords[(NUM_LANES-1-i+1)*65-1:(NUM_LANES-1-i)*65];
            else
              {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords[(i+1)*65-1:i*65];
          end
        end
      end
    end
  end else begin
    for (i=0; i<NUM_LANES; i=i+1) begin : ltl
      always @(posedge tx_usr_clk or posedge tx_usr_srst) begin
        if (tx_usr_srst) begin
          lane_txd[(i+1)*64-1:i*64] <= 64'h0;
          tx_control[i]             <= 1'b0;
        end else begin
          if (tx_valid) begin
            if (SWAP_TX_LANES)
              {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords[(NUM_LANES-1-i+1)*65-1:(NUM_LANES-1-i)*65];
            else
              {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords[(i+1)*65-1:i*65];
          end
        end
      end
    end
  end
endgenerate

//////////////////////////////////////////////
// Ilk RX MAC
//////////////////////////////////////////////

// each outword is a 8-byte word plus 1 bit (MSB) indicating if it's a burst/idle control word.
reg  [65*NUM_LANES-1:0]      irx_lanewords;
reg                          irx_lanewords_valid = 1'b0;

wire [65*NUM_LANES-1:0]      lanewords_buf;
wire                         lanewords_buf_valid;

wire [65*INTERNAL_WORDS-1:0] irx_outwords;
wire                         irx_outwords_valid;

wire [NUM_LANES-1:0]         rx_framing_tmp;

// PCS -> MAC
generate
  if ( USE_HARD_PCS == 1 ) begin : rdc0

    for (i=0; i<NUM_LANES; i=i+1) begin : lrl
      assign rx_framing_tmp [i] = rx_control[i] && !lane_rxd[i*64+63];

      always @(posedge clk_rx_common or posedge srst_rx_common) begin
        if (srst_rx_common) begin
          irx_lanewords[(i+1)*65-1:i*65] <= 65'h0;
        end else begin
          if (rx_valid[i]) begin
            if (SWAP_RX_LANES)
              irx_lanewords[(i+1)*65-1:i*65] <= {rx_control[NUM_LANES-1-i], lane_rxd[(NUM_LANES-i)*64-1:(NUM_LANES-1-i)*64]};
            else
              irx_lanewords[(i+1)*65-1:i*65] <= {rx_control[i], lane_rxd[(i+1)*64-1:i*64]};
          end
        end
      end
    end

    // call 2 out of 3 lanes showing framing a drop
    wire rx_framing_decision = (rx_framing_tmp[0] & rx_framing_tmp[1]) |
                               (rx_framing_tmp[0] & rx_framing_tmp[2]) |
                               (rx_framing_tmp[1] & rx_framing_tmp[2]);

    always @(posedge clk_rx_common or posedge srst_rx_common) begin
      if (srst_rx_common) irx_lanewords_valid <= 1'b0;
      else                irx_lanewords_valid <= rx_valid[0] && !rx_framing_decision;
    end

    // switch from PCS clock domain to system domain
    ilk_iw4_iw2_smoothed_domain_change rdc (
      .wrclk       (clk_rx_common),
      .wdata       (irx_lanewords),
      .wdata_valid (irx_lanewords_valid),
      .overflow    (rdc_overflow_pcsclk),

      .rdclk       (rx_usr_clk),
      .rdata       (lanewords_buf),
      .rdata_valid (lanewords_buf_valid)
    );
    defparam rdc .WIDTH = 65*NUM_LANES;
    defparam rdc .FAMILY = FAMILY;

  end else begin : rdc1

    // PCS clock domain is same like system domain
    for (i=0; i<NUM_LANES; i=i+1) begin : lrl
      if (SWAP_RX_LANES)
        assign lanewords_buf[(i+1)*65-1:i*65] = {rx_control[NUM_LANES-1-i], lane_rxd[(NUM_LANES-i)*64-1:(NUM_LANES-1-i)*64]};
      else
        assign lanewords_buf[(i+1)*65-1:i*65] = {rx_control[i], lane_rxd[(i+1)*64-1:i*64]};
    end

    assign lanewords_buf_valid = rx_valid[0];
    assign rdc_overflow_pcsclk = 1'b0;
  end
endgenerate

// synthesis translate_off
wire [64:0] lane_word_buf0,  lane_word_buf1,  lane_word_buf2,  lane_word_buf3;
wire [64:0] lane_word_buf4,  lane_word_buf5,  lane_word_buf6,  lane_word_buf7;

assign {lane_word_buf0,  lane_word_buf1,  lane_word_buf2,  lane_word_buf3,
        lane_word_buf4,  lane_word_buf5,  lane_word_buf6,  lane_word_buf7} = lanewords_buf;

// break up words for simulation visibility
wire [64:0] outwords_0, outwords_1, outwords_2, outwords_3;
assign {outwords_0, outwords_1, outwords_2, outwords_3} = irx_outwords;
// synthesis translate_on

wire [INTERNAL_WORDS-1:0] crc24_word_err;   //This will be aligned with eopbits and sent to user receiver side.
wire                      rx_fifo_full;

// Ilk rx mac guts
ilk_iw4_iw2_rx_datapath #(
  .CALENDAR_PAGES     (CALENDAR_PAGES),
  .NUM_LANES          (NUM_LANES),
  .INTERNAL_WORDS     (INTERNAL_WORDS),
  .FAMILY             (FAMILY)
) rdp (
  .clk             (rx_usr_clk), // rx_mac_clk
  .arst            (rx_usr_srst),
  .lanewords       (lanewords_buf),
  .lanewords_valid (lanewords_buf_valid),
  .outwords        (irx_outwords),
  .outwords_valid  (irx_outwords_valid),
  .crc24_word_err  (crc24_word_err),
  .crc24_err       (crc24_err),
  .overflow        (irx_overflow),
  .calendar        (irx_calendar),
  .rx_fifo_full    (rx_fifo_full)
);

//defparam dut.INTERNAL_WORDS = INTERNAL_WORDS;

// break up the interlaken words to read
// irx_outwords, say 259 ... 0 for 4 word case
//	data0, data1, data2, data3, each 8-byte-wide plus 1 MSB bit to indicate BurstControl word
// irx_outwords_sop/eop 3...0
//	one-hot, identify which of the above 4 positions has BC (ie bit[3] is for data0)
//	these are extracted from from the ControlWords
// irx_outwords_ibc
//	1 = identifies Idle/Burst CW from the framing CWs.
// irx_outwords_bc
//	1 = identifies Burst CW from the Idle CWs.
wire [INTERNAL_WORDS-1:0] irx_outwords_ibc;
wire [INTERNAL_WORDS-1:0] irx_outwords_bc;
wire [INTERNAL_WORDS-1:0] irx_outwords_sop;
wire [INTERNAL_WORDS-1:0] irx_outwords_eop;
wire [INTERNAL_WORDS-1:0] irx_outwords_data;
wire [INTERNAL_WORDS-1:0] irx_outwords_hibits;


// extract info from ControlWord / IdleWord
reg  [3:0] cw_eopbits;

generate
  for (i=0; i<INTERNAL_WORDS; i=i+1) begin : splt
    assign irx_outwords_ibc[i]    = irx_outwords_valid  &&  irx_outwords[i*65+64] && irx_outwords[i*65+63];
    assign irx_outwords_bc[i]     = irx_outwords_ibc[i] &&  irx_outwords[i*65+62];
    assign irx_outwords_sop[i]    = irx_outwords_bc[i]  &&  irx_outwords[i*65+61];
    assign irx_outwords_eop[i]    = irx_outwords_ibc[i] &&  irx_outwords[i*65+60];
    assign irx_outwords_data[i]   = irx_outwords_valid  && !irx_outwords[i*65+64];
    assign irx_outwords_hibits[i] = irx_outwords[i*65+7] | irx_outwords[i*65+15] |
                                    irx_outwords[i*65+23] | irx_outwords[i*65+31] |
                                    irx_outwords[i*65+39] | irx_outwords[i*65+47] |
                                    irx_outwords[i*65+55] | irx_outwords[i*65+63] ;
  end
endgenerate

// Create increment signals for the debug counters
assign sop_cntr_inc = |irx_outwords_sop;
assign eop_cntr_inc = |irx_outwords_eop;
assign nad_cntr_inc = |(irx_outwords_data & irx_outwords_hibits);

// ====================================================================
// THE SECTION BELOW ADDS THE CHANNEL FILTER AND REGROUP LOGIC
// These modules break out the raw databus, separates them into each logic channel
// and drops the control/idle words.  Then convert the output interface to Avalon-ST.
// ====================================================================

/////////////////////////////////////////
// Regroup RX datastream into TX format
/////////////////////////////////////////

ilk_iw4_iw2_rx_packet_regroup rg0 (
  .clk            (rx_usr_clk), // rx_macl_clk
  .arst           (rx_usr_srst),
  .rx_usr_clk     (rx_usr_clk),
  .rx_usr_arst    (rx_usr_srst),
  .datwords       (irx_outwords),
  .datwords_valid (irx_outwords_valid),
  .crc24_word_err (crc24_word_err),

  .dout           (core_irx_dout_words),
  .dout_num_valid (core_irx_num_valid),
  .dout_sop       (core_irx_sop),
  .dout_sob       (core_irx_sob),
  .dout_eob       (core_irx_eob),
  .dout_eopbits   (core_irx_eopbits),
  .dout_channel   (core_irx_chan),
  .dout_crc24_err (core_irx_crc24_err),
  .holding        (rxfifo_fill_level),
  .overflow       (rg_overflow)
);
defparam rg0.RX_PKTMOD_ONLY    = RX_PKTMOD_ONLY;
defparam rg0.BYPASS_INPUT_REG  = BYPASS_INPUT_REG;
defparam rg0.RXFIFO_ADDR_WIDTH = RXFIFO_ADDR_WIDTH;
defparam rg0.WORDS             = INTERNAL_WORDS;
defparam rg0.LOG_WORDS         = LOG_INTERNAL_WORDS;
defparam rg0.FAMILY            = FAMILY;


function [31:0] count_sixpacks;
input [23:0] lane_profile;
integer i, j;
reg sixpack_is_used;
integer total_sixpacks;
begin
    total_sixpacks = 0;
    for( i = 0; i < 4; i = i +1 ) begin
        sixpack_is_used = 1'b0;
        for( j = 0; j < 6; j = j + 1 ) begin
            if( lane_profile[i*6+j] ) sixpack_is_used = 1'b1;
        end
        if( sixpack_is_used ) total_sixpacks = total_sixpacks + 1;
    end

    count_sixpacks = total_sixpacks;
end
endfunction

// ====================================================================
// THE SECTION BELOW ADDS THE ERROR HANDLER FOR RX USER INTERFACE
// This module detect SOP/EOP burst error and CRC24 error and mark
// all the open channel packets as errored and flag it at each EOP cycle
// ====================================================================

/////////////////////////////////////////
// RX error hander
/////////////////////////////////////////

ilk_err_handler #(
  .INTERNAL_WORDS       (INTERNAL_WORDS)
) eh0 (
  .rx_usr_clk           (rx_usr_clk),
  .rx_usr_srst          (rx_usr_srst),

  .irx_dout_words       (irx_dout_words),
  .irx_num_valid        ({dummy_irx_num_valid_msb, irx_num_valid, dummy_irx_num_valid_lsb}),
  .irx_sop              ({irx_sop, dummy_irx_sop}),
  .irx_sob              ({irx_sob, dummy_irx_sob}),
  .irx_eob              (irx_eob),
  .irx_chan             (irx_chan),
  .irx_eopbits          (irx_eopbits),
  .irx_err              (irx_err),

  .core_irx_dout_words  (core_irx_dout_words),
  .core_irx_num_valid   ({1'b0, core_irx_num_valid, 4'h0}),
  .core_irx_sop         ({core_irx_sop, 1'b0}),
  .core_irx_sob         ({core_irx_sob, 1'b0}),
  .core_irx_eob         (core_irx_eob),
  .core_irx_chan        (core_irx_chan),
  .core_irx_eopbits     (core_irx_eopbits),
  .core_irx_crc24_err   (core_irx_crc24_err)
);

endmodule
