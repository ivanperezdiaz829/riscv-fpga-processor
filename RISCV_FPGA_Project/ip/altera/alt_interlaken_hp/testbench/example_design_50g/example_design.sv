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


// top level file for example design

`timescale 1ps/1ps

module example_design #(
  parameter PLL_REFCLK_FREQ = "312.5 MHz",
  parameter TX_PKTMOD_ONLY     =    1,   //This value need to be consistant with core.
  parameter NUM_LANES          =    8,
  parameter CNTR_BITS          =    6,   // regulate reset delay, 6 for sim, 20 for hardware
  parameter NUM_CHAN           = 8'h1,
  parameter CALENDAR_PAGES     =    1,
  parameter LOG_CALENDAR_PAGES =    1,
  parameter METALEN            =  128,    
  parameter USE_ATX            =    1, 
  parameter PLL_OUT_FREQ       = "3125.0 MHz",
  parameter DATA_RATE          = "6250.0 MHz",
  parameter INT_TX_CLK_DIV     =    1,
  parameter RX_PKTMOD_ONLY     =    1,
  parameter SIM_FAKE_JTAG      = 1'b1 // emulate PC host a little bit

)(
  input                  clk50,
  input                  pll_ref_clk,

  input  [NUM_LANES-1:0] rx_pin,
  output [NUM_LANES-1:0] tx_pin
);

  localparam NUM_SIXPACKS       = (NUM_LANES == 8) ? 2 : 4; // example only; user can change it
  localparam INCLUDE_TEMP_SENSE = 1'b1;
  localparam RXFIFO_ADDR_WIDTH  = 11;

  localparam INTERNAL_WORDS     = 4;
  localparam LOG_INTE_WORDS     = 3;
  localparam W_BUNDLE_TO_XCVR   = 70;
  localparam W_BUNDLE_FROM_XCVR = 46;


  wire                         rx_lanes_aligned;
  wire                         rx_lanes_aligned_s;
  wire [NUM_LANES-1:0]         sync_locked;
  wire                         all_sync_locked;
  wire [NUM_LANES-1:0]         word_locked;
  wire                         all_word_locked;
  wire                         send_data;

  reg  [CALENDAR_PAGES*16-1:0] itx_calendar;
  wire                         itx_ready;
  wire [64*INTERNAL_WORDS-1:0] irx_dout_words;
  wire [LOG_INTE_WORDS-1:0]    irx_num_valid;
  wire                         irx_sop;
  wire                         irx_sob;
  wire                         irx_eob;
  wire [7:0]                   irx_chan;
  wire [3:0]                   irx_eopbits;

  wire                         clk100;
  wire                         clk250;
  wire                         clk_mac;
  wire                         clk_sys_ready;

  reg                          sys_pll_rst = 1'b0;

  wire                         tx_cal_busy;
  wire                         rx_cal_busy;
  wire                         reconfig_busy;

  reg                                                    reconfig_reset /* synthesis keep */;
  wire [W_BUNDLE_TO_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0]   reconfig_to_xcvr;
  wire [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr;

  // Signals to increment debug counters, indicate errors
  wire                         clk_tx_common;
  wire                         srst_tx_common;
  wire                         clk_rx_common;
  wire                         srst_rx_common;
  wire                         sop_cntr_inc;
  wire [31:0]                  sop_cntr;
  wire [31:0]                  eop_cntr;
  wire [NUM_LANES-1:0]         crc32_err;
  wire                         crc24_err;
  wire [NUM_LANES*8-1:0]       crc32_err_cnt;
  wire [15:0]                  crc24_err_cnt;
  wire [3:0]                   checker_errors;
  wire [31:0]                  err_cnt;
  wire                         eop_cntr_inc;
  wire                         itx_overflow;
  wire                         itx_underflow;
  wire                         irx_overflow;
  wire                         rdc_overflow;
  wire                         rg_overflow;
  wire [RXFIFO_ADDR_WIDTH-1:0] rxfifo_fill_level;
  wire                         irx_err;
  wire                         tx_lanes_aligned;
  wire                         tx_mac_srst;
  wire                         rx_mac_srst;

  reg                          run_directed_test;
  reg                          start_ch_wr;
  reg                          err_read;
  reg  [7:0]                   start_channel;
  reg  [7:0]                   num_channels;
  wire [7:0]                   ch_cnt_id;
  wire [31:0]                  ch_cnt;

  reg  [13:0]                  cpu_pkt_size_min;
  reg  [13:0]                  cpu_pkt_size_step;
  reg  [13:0]                  cpu_pkt_size_max;
  reg  [1:0]                   cpu_run_mode;
  reg  [15:0]                  cpu_pkts_to_run;
  reg  [9:0]                   cpu_int_burst_size;

  wire                         sys_pll_locked;
  wire [65*INTERNAL_WORDS-1:0] irx_outwords;
  wire                         irx_outwords_valid;
  wire [CALENDAR_PAGES*16-1:0] irx_calendar;
  wire                         itx_hungry;
  wire                         tx_usr_srst, rx_usr_srst;

  wire                         clk_srv;
  wire                         pll_srv_locked;
  wire                         clk_srv_ready;
  reg                          pll_srv_rst;

  wire [64*INTERNAL_WORDS-1:0] itx_din_words;
  wire [LOG_INTE_WORDS-1:0]    itx_num_valid;
  wire [7:0]                   itx_chan;
  wire                         itx_sop;
  wire                         itx_sob;
  wire                         itx_eob;
  wire [3:0]                   itx_eopbits;
  wire [31:0]                  tx_sop_cnt;
  wire [31:0]                  tx_eop_cnt;

  wire                         itx_overflow_sticky;
  wire                         itx_underflow_sticky;
  wire                         irx_overflow_sticky;
  wire                         rdc_overflow_sticky;

  reg                          gaps_en;
  wire                         start_latency_cnt;
  wire                         get_latency;
  wire [7:0]                   latency_cnt_id;
  wire                         latency_ready;
  wire [31:0]                  latency_cnt;
  wire [31:0]                  perf_pkt_cnt;
  wire [31:0]                  perf_byte_cnt;

  wire [15:0]                  core_addr;
  wire                         core_read;
  wire                         core_write;
  wire                         core_rdata_vld;
  wire                         core_rdata_valid;
  wire [31:0]                  core_rdata;
  wire [31:0]                  core_wdata;

  //An example to show user how to provide clocks used by interlaken.
  //User can modify it their way.
  assign itx_calendar = 256'h0101_0202_0303_0404_0505_0606_0707_0808_1011_2223_3435_4647_5859_6a6b_7c7d_8e8f;

  // System clock PLL
  altera_pll #(
    .reference_clock_frequency ("50.0 MHz"),
    .operation_mode            ("direct"),
    .number_of_clocks          (2),

    .output_clock_frequency0   ("100.0 MHz"),
    .phase_shift0              ("0 ps"),
    .duty_cycle0               (50),

    .output_clock_frequency1   ("250.0 MHz"),
    .phase_shift1              ("0 ps"),
    .duty_cycle1               (50)
  ) sys_pll (
    .outclk   ({clk250, clk100}),
    .locked   (sys_pll_locked),
    .fboutclk (),
    .fbclk    (1'b0),
    .rst      (sys_pll_rst),
    .refclk   (clk50)
  );

  // Service PLL; allows to reset system PLL to imitate clock cut
  altera_pll #(
    .reference_clock_frequency ("50.0 MHz"),
    .operation_mode            ("direct"),
    .number_of_clocks          (1),

    .output_clock_frequency0   ("100.0 MHz"),
    .phase_shift0              ("0 ps"),
    .duty_cycle0               (50)
  ) serv_pll (
    .outclk   ({clk_srv}),
    .locked   (pll_srv_locked),
    .fboutclk (),
    .fbclk    (1'b0),
    .rst      (pll_srv_rst),
    .refclk   (clk50)
  );

  // System Reset generator
  ilk_reset_delay #(
    .CNTR_BITS (CNTR_BITS)
  ) rdy_sys (
    .clk       (clk250),
    .ready_in  (sys_pll_locked),
    .ready_out (clk_sys_ready)
  );


  wire ilk_core_reset_srv, ilk_core_reset;
  reg  reconfig_busy_r1;
  reg  reconfig_done;
  wire reconfig_done_d;

   assign reconfig_done_d    = clk_sys_ready;
   assign ilk_core_reset_srv = (sys_pll_locked && !clk_sys_ready);

  // Safely cross to ilk core clock domain
  ilk_status_sync #(.WIDTH (1)) ss_ilk_rst (.clk(clk250), .din(ilk_core_reset_srv), .dout(ilk_core_reset));

   ilk_core_50g #(
	      .RXFIFO_ADDR_WIDTH  (RXFIFO_ADDR_WIDTH),
	      .CNTR_BITS          (CNTR_BITS),
	      .NUM_LANES          (NUM_LANES),
	      .CALENDAR_PAGES     (CALENDAR_PAGES),
	      .LOG_CALENDAR_PAGES (LOG_CALENDAR_PAGES),
	      .METALEN            (METALEN),
	      .INTERNAL_WORDS     (INTERNAL_WORDS),
	      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
	      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
	      .USE_ATX            (USE_ATX),
	      .DATA_RATE          (DATA_RATE),
	      .PLL_OUT_FREQ       (PLL_OUT_FREQ),
	      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
	      .INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
	      .NUM_SIXPACKS       (NUM_SIXPACKS),
	      .RX_PKTMOD_ONLY     (RX_PKTMOD_ONLY),
	      .TX_PKTMOD_ONLY     (TX_PKTMOD_ONLY)
	      ) core_inst (
    .tx_usr_clk         (clk250),
    .rx_usr_clk         (clk250),
    .pll_ref_clk        (pll_ref_clk),
    .reset_n            (!ilk_core_reset),
    .rx_pin             (rx_pin),
    .tx_pin             (tx_pin),
    .sync_locked        (sync_locked),
    .word_locked        (word_locked),
    .tx_lanes_aligned   (tx_lanes_aligned),
    .rx_lanes_aligned   (rx_lanes_aligned),
    .itx_din_words      (itx_din_words),
    .itx_num_valid      (itx_num_valid),
    .itx_chan           (itx_chan),
    .itx_sop            (itx_sop),
    .itx_eopbits        (itx_eopbits),
    .itx_sob            (itx_sob),
    .itx_eob            (itx_eob),
    .itx_calendar       (itx_calendar),

    .burst_max_in       (4'h4),
    .burst_short_in     (4'h2),
    .burst_min_in       (4'h2),

    .itx_ready          (itx_ready),
    .itx_hungry         (itx_hungry),
    .itx_overflow       (itx_overflow),
    .itx_underflow      (itx_underflow),
    .crc24_err          (crc24_err),
    .crc32_err          (crc32_err),

    .clk_tx_common      (clk_tx_common),
    .srst_tx_common     (srst_tx_common),
    .clk_rx_common      (clk_rx_common),
    .srst_rx_common     (srst_rx_common),
    .tx_mac_srst        (tx_mac_srst),
    .rx_mac_srst        (rx_mac_srst),
    .tx_usr_srst        (tx_usr_srst),
    .rx_usr_srst        (rx_usr_srst),

    .irx_dout_words     (irx_dout_words),
    .irx_num_valid      (irx_num_valid),
    .irx_sop            (irx_sop),
    .irx_sob            (irx_sob),
    .irx_eob            (irx_eob),
    .irx_eopbits        (irx_eopbits),
    .irx_chan           (irx_chan),
    .irx_err            (irx_err),
    .irx_calendar       (irx_calendar),
    .irx_overflow       (irx_overflow),
    .rdc_overflow       (rdc_overflow),
    .rg_overflow        (rg_overflow),
    .rxfifo_fill_level  (rxfifo_fill_level),

    .sop_cntr_inc       (sop_cntr_inc),
    .eop_cntr_inc       (eop_cntr_inc),
    .nad_cntr_inc       (            ),

    .mm_clk             (clk100),
    .mm_clk_locked      (clk_sys_ready),
    .mm_read            (core_read),
    .mm_write           (core_write),
    .mm_addr            (core_addr),
    .mm_rdata           (core_rdata),
    .mm_rdata_valid     (core_rdata_vld),
    .mm_wdata           (core_wdata),
    .reconfig_to_xcvr   (reconfig_to_xcvr),
    .reconfig_from_xcvr (reconfig_from_xcvr)
  );

  // ====================================================================
  // merge the MM ports
  // ====================================================================
  wire [31:0] jtag_master_address;
  wire        jtag_master_write;
  wire [31:0] jtag_master_writedata;
  reg         jtag_master_waitrequest;
  wire        jtag_master_read;
  reg  [31:0] jtag_master_readdata;
  reg         jtag_master_readdatavalid;

  wire [15:0] hw_test_addr;
  wire        hw_test_write;
  wire [31:0] hw_test_wdata;
  wire        hw_test_read;
  reg  [31:0] hw_test_rdata;
  reg         hw_test_rdata_vld, hw_test_rdata_valid;

  wire        hw_test_sel;
  wire        core_sel;
  wire        reconfig_sel;

  wire        perf_meas_rdone;
  wire        perf_meas_ready;

  wire        mm_read, mm_write;

  reg         faux_read      =  1'b0;
  reg         faux_write     =  1'b0;
  reg  [31:0] faux_writedata = 32'h0;
  reg  [17:0] faux_addr      = 16'h0;

  reg  [31:0] read_data_reg;
  wire [1:0]  pm_state;

  assign hw_test_sel  =  faux_addr[15]&~faux_addr[14];
  assign core_sel     = ~faux_addr[15]& faux_addr[14];
  assign reconfig_sel = ~faux_addr[15]&~faux_addr[14];

  assign mm_read       = faux_read;
  assign mm_write      = faux_write;

  assign hw_test_addr  = faux_addr[17:2];
  assign hw_test_read  = hw_test_sel && mm_read;
  assign hw_test_write = hw_test_sel && mm_write;
  assign hw_test_wdata = faux_writedata;

  assign core_addr     = faux_addr[17:2];
  assign core_read     = core_sel && mm_read;
  assign core_write    = core_sel && mm_write;
  assign core_wdata    = faux_writedata;

  ilk_status_sync #(.WIDTH (1)) ss_hw_test_vld (.clk (clk_srv), .din (hw_test_rdata_vld), .dout (hw_test_rdata_valid));

  // Cross clock domain safely and delay data valid indication to sample data correctly
  ilk_status_sync #(.WIDTH (1)) ss_core_vld (.clk (clk_srv), .din (core_rdata_vld), .dout (core_rdata_valid));

  always @(*) begin
    if (hw_test_sel) begin
      jtag_master_readdata      <= hw_test_rdata;
      jtag_master_waitrequest   <= 1'b0;
      jtag_master_readdatavalid <= hw_test_rdata_valid;
    end else if (core_sel) begin
      jtag_master_readdata      <= core_rdata;
      jtag_master_waitrequest   <= 1'b0;
      jtag_master_readdatavalid <= core_rdata_valid;
    end else begin

        jtag_master_readdata      <= 32'h0;
        jtag_master_waitrequest   <= 1'b0;
        jtag_master_readdatavalid <= 1'b0;
  //  end
    end
  end

  //////////////////////////////////////////////
  // ILK TX MAC PACKETS GENERATOR
  //////////////////////////////////////////////
  ilk_pkt_gen #(
    .INTERNAL_WORDS (INTERNAL_WORDS),
    .LOG_INTE_WORDS (LOG_INTE_WORDS),
	.TX_PKTMOD_ONLY (TX_PKTMOD_ONLY),
    .CALENDAR_PAGES (CALENDAR_PAGES)
  ) ilk_pkt_gen_inst (
    .clk                (clk250),
    .rx_lanes_aligned   (rx_lanes_aligned),
    .itx_ready          (itx_ready),
    .send_data          (send_data),
    .reconfig_done      (reconfig_done_d),
    .rx_usr_srst        (rx_usr_srst),
    .tx_usr_srst        (tx_usr_srst),
    .srst_rx_common     (srst_rx_common),
    .srst_tx_common     (srst_tx_common),

    .run_directed_test  (run_directed_test),
    .start_ch_wr        (start_ch_wr),
    .start_channel      (start_channel),
    .num_channels       (num_channels),

    .gaps_en            (gaps_en),
    .cpu_pkt_size_min   (cpu_pkt_size_min),
    .cpu_pkt_size_step  (cpu_pkt_size_step),
    .cpu_pkt_size_max   (cpu_pkt_size_max),
    .cpu_run_mode       (cpu_run_mode),
    .cpu_pkts_to_run    (cpu_pkts_to_run),
    .cpu_int_burst_size (cpu_int_burst_size),

    .itx_din_words      (itx_din_words),
    .itx_num_valid      (itx_num_valid),
    .itx_chan           (itx_chan),
    .itx_sop            (itx_sop),
    .itx_sob            (itx_sob),
    .itx_eob            (itx_eob),
    .itx_eopbits        (itx_eopbits),

    .tx_sop_cnt         (tx_sop_cnt),
    .tx_eop_cnt         (tx_eop_cnt),
    .get_latency        (get_latency),
    .start_latency_cnt  (start_latency_cnt),
    .latency_cnt_id     (latency_cnt_id)
  );

  //////////////////////////////////////////////
  // ILK RX MAC PACKETS CHECKER
  //////////////////////////////////////////////
  ilk_pkt_checker #(
    .SIM_FAKE_JTAG  (SIM_FAKE_JTAG),
    .INTERNAL_WORDS (INTERNAL_WORDS),
    .LOG_INTE_WORDS (LOG_INTE_WORDS),
	.TX_PKTMOD_ONLY (TX_PKTMOD_ONLY),
    .NUM_LANES      (NUM_LANES)
  ) ilk_pkt_checker_inst (
    .clk                  (clk250),
    .clk_rx_common        (clk_rx_common),
    .clk_tx_common        (clk_tx_common),

    .srst_rx_common       (srst_rx_common),
    .srst_tx_common       (srst_tx_common),
    .tx_usr_srst          (tx_usr_srst),
    .rx_usr_srst          (rx_usr_srst),

    .rx_lanes_aligned     (rx_lanes_aligned),
    .irx_dout_words       (irx_dout_words),
    .irx_num_valid        (irx_num_valid),
    .irx_sop              (irx_sop),
    .irx_sob              (irx_sob),
    .irx_chan             (irx_chan),
    .irx_eopbits          (irx_eopbits),

    .crc32_err            (crc32_err),
    .crc24_err            (crc24_err),

    .sop_cntr_inc         (sop_cntr_inc),
    .eop_cntr_inc         (eop_cntr_inc),

    .itx_overflow         (itx_overflow),
    .itx_underflow        (itx_underflow),
    .irx_overflow         (irx_overflow),
    .rdc_overflow         (rdc_overflow),

    .sop_cntr             (sop_cntr),
    .eop_cntr             (eop_cntr),
    .crc32_err_cnt        (crc32_err_cnt),
    .crc24_err_cnt        (crc24_err_cnt),
    .checker_errors       (checker_errors),
    .err_cnt              (err_cnt),
    .err_read             (err_read),
    .itx_overflow_sticky  (itx_overflow_sticky),
    .itx_underflow_sticky (itx_underflow_sticky),
    .irx_overflow_sticky  (irx_overflow_sticky),
    .rdc_overflow_sticky  (rdc_overflow_sticky),

    .run_directed_test    (run_directed_test),
    .start_ch_wr          (start_ch_wr),
    .start_channel        (start_channel),
    .num_channels         (num_channels),
    .ch_cnt_id            (ch_cnt_id),
    .ch_cnt               (ch_cnt),
    .cpu_int_burst_size   (cpu_int_burst_size),
    .start_latency_cnt    (start_latency_cnt),
    .latency_cnt_id       (latency_cnt_id),
    .latency_ready        (latency_ready),
    .latency_cnt          (latency_cnt),
    .perf_meas_ready      (perf_meas_ready),
    .perf_meas_rdone      (perf_meas_rdone),
    .pm_state             (pm_state),
    .perf_pkt_cnt         (perf_pkt_cnt),
    .perf_byte_cnt        (perf_byte_cnt)
  );

  wire [NUM_LANES*8-1:0] crc32_err_cnt_s;
  wire [NUM_LANES-1:0]   word_locked_s;
  wire [NUM_LANES-1:0]   sync_locked_s;
  wire [15:0]            crc24_err_cnt_s;
  wire [31:0]            sop_cntr_s;
  wire [31:0]            eop_cntr_s;
  wire [31:0]            err_cnt_s;
  reg  [3:0]             checker_errors_s;

  reg                    send_data_clk_srv = 0;
  wire                   latency_ready_s;
  wire                   perf_meas_ready_s;
  reg                    get_latency_s;
  reg                    perf_meas_rdone_s;
  wire [1:0]             pm_state_s;
  reg                    start_ch_wr_s;
  reg                    err_read_s;
  reg  [7:0]             ch_cnt_id_s;
  reg  [31:0]            ch_cnt_s;
  reg  [7:0]             start_channel_s;
  reg  [7:0]             num_channels_s;
  reg                    tx_force_crc24_err_s;

  ilk_status_sync #(.WIDTH(NUM_LANES*8))  ss1 (.clk(clk_srv), .din(crc32_err_cnt),        .dout(crc32_err_cnt_s)   );
  ilk_status_sync #(.WIDTH(NUM_LANES)  )  ss2 (.clk(clk_srv), .din(word_locked),          .dout(word_locked_s)     );
  ilk_status_sync #(.WIDTH(NUM_LANES)  )  ss3 (.clk(clk_srv), .din(sync_locked),          .dout(sync_locked_s)     );
  ilk_status_sync #(.WIDTH(16)         )  ss4 (.clk(clk_srv), .din(crc24_err_cnt),        .dout(crc24_err_cnt_s)   );
  ilk_status_sync #(.WIDTH(32)         )  ss5 (.clk(clk_srv), .din(sop_cntr),             .dout(sop_cntr_s)        );
  ilk_status_sync #(.WIDTH(32)         )  ss6 (.clk(clk_srv), .din(eop_cntr),             .dout(eop_cntr_s)        );
  ilk_status_sync #(.WIDTH(32)         )  ss7 (.clk(clk_srv), .din(err_cnt),              .dout(err_cnt_s)         );
  ilk_status_sync #(.WIDTH(4)          )  ss8 (.clk(clk_srv), .din(checker_errors),       .dout(checker_errors_s)  );
  ilk_status_sync #(.WIDTH(1)          )  ss9 (.clk(clk_srv), .din(rx_lanes_aligned),     .dout(rx_lanes_aligned_s));
  ilk_status_sync #(.WIDTH(1)          ) ss10 (.clk(clk_srv), .din(latency_ready),        .dout(latency_ready_s)   );
  ilk_status_sync #(.WIDTH(1)          ) ss11 (.clk(clk_srv), .din(perf_meas_ready),      .dout(perf_meas_ready_s) );
  ilk_status_sync #(.WIDTH(2)          ) ss12 (.clk(clk_srv), .din(pm_state),             .dout(pm_state_s)        );
  ilk_status_sync #(.WIDTH(32)         ) ss13 (.clk(clk_srv), .din(ch_cnt),               .dout(ch_cnt_s)          );

  ilk_status_sync #(.WIDTH(1)          ) ss21 (.clk(clk250),  .din(send_data_clk_srv),    .dout(send_data)         );
  ilk_status_sync #(.WIDTH(1)          ) ss22 (.clk(clk250),  .din(get_latency_s),        .dout(get_latency)       );
  ilk_status_sync #(.WIDTH(1)          ) ss23 (.clk(clk250),  .din(perf_meas_rdone_s),    .dout(perf_meas_rdone)   );
  ilk_status_sync #(.WIDTH(1)          ) ss24 (.clk(clk250),  .din(start_ch_wr_s),        .dout(start_ch_wr)       );
  ilk_status_sync #(.WIDTH(8)          ) ss25 (.clk(clk250),  .din(ch_cnt_id_s),          .dout(ch_cnt_id)         );
  ilk_status_sync #(.WIDTH(8)          ) ss26 (.clk(clk250),  .din(start_channel_s),      .dout(start_channel)     );
  ilk_status_sync #(.WIDTH(8)          ) ss27 (.clk(clk250),  .din(num_channels_s),       .dout(num_channels)      );
  ilk_status_sync #(.WIDTH(1)          ) ss28 (.clk(clk250),  .din(tx_force_crc24_err_s), .dout(tx_force_crc24_err));
  ilk_status_sync #(.WIDTH(1)          ) ss29 (.clk(clk250),  .din(err_read_s),           .dout(err_read)          );

  reg       sys_pll_rst_en  = 1'b0;
  reg       sys_pll_rst_req = 1'b0;
  reg [5:0] pll_rst_cnt     = 6'b0;

  // Testbench Registers
  always @(posedge clk_srv) begin
    hw_test_rdata_vld <= 1'b0;
    if (hw_test_read) begin
      hw_test_rdata     <= 32'h0;
      hw_test_rdata_vld <= 1'b1;
      case (hw_test_addr[7:0])
        8'h0    : hw_test_rdata <= 32'h12345678;
        8'h2    : hw_test_rdata <= 32'h0 | {gaps_en, sys_pll_rst_en, sys_pll_rst_req};

        8'h3    : hw_test_rdata <= 32'h0 | rx_lanes_aligned_s;
        8'h4    : hw_test_rdata <= 32'h0 | word_locked_s;
        8'h5    : hw_test_rdata <= 32'h0 | sync_locked_s;

        8'h6    : hw_test_rdata <= 32'h0 | crc32_err_cnt_s[31:0];
        8'h7    : hw_test_rdata <= 32'h0 | crc32_err_cnt_s[63:32];
        8'h8    : hw_test_rdata <= 32'h0 ;

        8'ha    : hw_test_rdata <= 32'h0 | crc24_err_cnt_s;
        8'hb    : hw_test_rdata <= 32'h0 | {rdc_overflow_sticky,
                                            irx_overflow_sticky,
                                            itx_overflow_sticky,
                                            itx_underflow_sticky};
        8'hc    : hw_test_rdata <= 32'h0 | sop_cntr_s;
        8'hd    : hw_test_rdata <= 32'h0 | eop_cntr_s;

        8'he    : hw_test_rdata <= 32'h0 | err_cnt_s;  // Actual data error counter
        8'hf    : hw_test_rdata <= 32'h0 | send_data_clk_srv;

        8'h10   : hw_test_rdata <= 32'h0 | checker_errors_s;
        8'h11   : hw_test_rdata <= 32'h0 | sys_pll_locked;
        8'h13   : hw_test_rdata <= 32'h0 | latency_cnt;

        8'h20   : hw_test_rdata <= 32'h0 | perf_byte_cnt;
        8'h21   : hw_test_rdata <= 32'h0 | perf_pkt_cnt;
        8'h22   : hw_test_rdata <= 32'h0 | perf_meas_ready_s;

        8'h24   : hw_test_rdata <= 32'h0 | latency_ready_s;

        8'h30   : hw_test_rdata <= 32'h0 | run_directed_test;
        8'h31   : hw_test_rdata <= 32'h0 | cpu_pkt_size_min;
        8'h32   : hw_test_rdata <= 32'h0 | cpu_pkt_size_step;
        8'h33   : hw_test_rdata <= 32'h0 | cpu_pkt_size_max;
        8'h34   : hw_test_rdata <= 32'h0 | cpu_run_mode;
        8'h35   : hw_test_rdata <= 32'h0 | cpu_pkts_to_run;
        8'h36   : hw_test_rdata <= 32'h0 | cpu_int_burst_size;
        8'h37   : hw_test_rdata <= 32'h0 | start_channel_s;
        8'h38   : hw_test_rdata <= 32'h0 | num_channels_s;
        8'h39   : hw_test_rdata <= 32'h0 | tx_force_crc24_err_s;

        8'h40   : hw_test_rdata <= 32'h0 | ch_cnt_id_s;
        8'h41   : hw_test_rdata <= 32'h0 | ch_cnt_s;

        default : hw_test_rdata <= 32'hDEAD_BEEF;
      endcase
    end
  end

  initial begin
    pll_srv_rst          = 1'b0;
    sys_pll_rst_en       = 1'b0;
    sys_pll_rst_req      = 1'b0;
    gaps_en              = 1'b0;
    send_data_clk_srv    = 1'b0;
    get_latency_s        = 1'b0;
    perf_meas_rdone_s    = 1'b0;
    run_directed_test    = 1'b0;
    start_channel_s      = 8'h0;
    num_channels_s       = NUM_CHAN;//8'h04;//8'hFF;
    tx_force_crc24_err_s = 1'b0;
    ch_cnt_id_s          = 8'h0;
    cpu_pkt_size_min     = {16{1'b0}};
    cpu_pkt_size_step    = {4{1'b0}};
    cpu_pkt_size_max     = {16{1'b0}};
    cpu_run_mode         = {2{1'b0}};
    cpu_pkts_to_run      = {16{1'b0}};
    cpu_int_burst_size   = 10'd256;
  end

  always @(posedge clk_srv or negedge pll_srv_locked) begin
    if (!pll_srv_locked) begin
      pll_srv_rst          <= 1'b0;
      sys_pll_rst_en       <= 1'b0;
      sys_pll_rst_req      <= 1'b0;
      gaps_en              <= 1'b0;
      send_data_clk_srv    <= 1'b0;
      get_latency_s        <= 1'b0;
      perf_meas_rdone_s    <= 1'b0;
      run_directed_test    <= 1'b0;
      start_channel_s      <= 8'h0;
      num_channels_s       <= NUM_CHAN; //8'h04;//8'hFF;
      tx_force_crc24_err_s <= 1'b0;
      ch_cnt_id_s          <= 8'h0;
      cpu_pkt_size_min     <= {16{1'b0}};
      cpu_pkt_size_step    <= {4{1'b0}};
      cpu_pkt_size_max     <= {16{1'b0}};
      cpu_run_mode         <= {2{1'b0}};
      cpu_pkts_to_run      <= {16{1'b0}};
      cpu_int_burst_size   <= 10'd256;
    end else if (hw_test_write) begin
      case (hw_test_addr[7:0])
        8'h1  : pll_srv_rst          <= hw_test_wdata[0];
        8'h2  : sys_pll_rst_req      <= hw_test_wdata[0];
        8'h3  : sys_pll_rst_en       <= hw_test_wdata[0];
        8'h4  : gaps_en              <= hw_test_wdata[0];
        8'hf  : send_data_clk_srv    <= hw_test_wdata[0];
        8'h23 : get_latency_s        <= hw_test_wdata[0];
        8'h25 : perf_meas_rdone_s    <= hw_test_wdata[0];
        8'h30 : run_directed_test    <= hw_test_wdata[0];
        8'h31 : cpu_pkt_size_min     <= hw_test_wdata[15:0];
        8'h32 : cpu_pkt_size_step    <= hw_test_wdata[3:0];
        8'h33 : cpu_pkt_size_max     <= hw_test_wdata[15:0];
        8'h34 : cpu_run_mode         <= hw_test_wdata[1:0];
        8'h35 : cpu_pkts_to_run      <= hw_test_wdata[15:0];
        8'h36 : cpu_int_burst_size   <= hw_test_wdata[9:0];  // burst size in bytes
        8'h37 : start_channel_s      <= hw_test_wdata[7:0];
        8'h38 : num_channels_s       <= hw_test_wdata[7:0];
        8'h39 : tx_force_crc24_err_s <= hw_test_wdata[0];
        8'h40 : ch_cnt_id_s          <= hw_test_wdata[7:0];
      endcase
    end
  end

  always @(posedge clk_srv) begin
    if (hw_test_write && hw_test_addr[7:0] == 6'h37) begin
      start_ch_wr_s <= 1'b1;
    end else begin
      start_ch_wr_s <= 1'b0;
    end
  end

  always @(posedge clk_srv) begin
    if (hw_test_rdata_vld && hw_test_addr[7:0] == 6'h10) begin
      err_read_s <= 1'b1;
    end else begin
      err_read_s <= 1'b0;
    end
  end

  always @(posedge clk_srv) begin
    if (sys_pll_rst_en == 1'b1) begin
      if (&pll_rst_cnt == 1'b1) begin
        sys_pll_rst <= 1'b0;
        if (sys_pll_rst_req == 1'b0) begin
          pll_rst_cnt <= 0;
        end else begin
          pll_rst_cnt <= pll_rst_cnt;
        end
      end else begin
        if (sys_pll_rst_req == 1'b1 || sys_pll_rst == 1'b1) begin
          sys_pll_rst <= 1'b1;
          pll_rst_cnt <= pll_rst_cnt + 1'b1;
        end
      end
    end else begin
      sys_pll_rst <= 1'b0;
      pll_rst_cnt <= 6'h0;
    end
  end

  //////////////////////////////////////////////
  // debug monitor
  //////////////////////////////////////////////
  // synthesis translate_off
  task write_mm_task;
    input [15:0] address;
    input [31:0] write_data;
    begin
      @(posedge clk_srv);
      #5;
      faux_addr[17:2] = address;
      faux_writedata = write_data;
      faux_write = 1'b1;
      @(posedge clk_srv);
      $display("WRITE_MM: address %x gets %x", address, write_data);
      @(posedge clk_srv);
      faux_write = 1'b0;
    end
  endtask

  task read_mm_task;
    input  [15:0] address;
    output [31:0] read_data;
    begin
      @(posedge clk_srv);
      #5;
      faux_addr[17:2] = address;
      faux_read = 1'b1;
      @(posedge clk_srv);
      @(posedge jtag_master_readdatavalid);
      read_data = jtag_master_readdata;
      $display("READ_MM: address %x =  %x", address, read_data);
      @(posedge clk_srv);
      faux_read = 1'b0;
      @(negedge jtag_master_readdatavalid);
    end
  endtask

  reg fail = 0;
  integer startup_errors_crc24 = 0, startup_errors_crc32 = 0;
  wire all_word_lock = &word_locked;

  integer j, k, l;

  always @(posedge all_word_lock) begin
    $display("Word lock acquired at time %d",$time);
  end

  wire all_sync_lock = &sync_locked;

  always @(posedge all_sync_lock) begin
    $display("Meta lock acquired at time %d",$time);
    $display("CRC24 error count %d", crc24_err_cnt);
    $display("CRC32 error count %d", crc32_err_cnt);
  end

  always @(negedge all_word_lock) begin
    if ($time > 100) $display("Word lock lost at time %d",$time);
  end

  always @(negedge all_sync_lock) begin
    if ($time > 100) $display("Meta lock lost at time %d",$time);
  end

  always @(posedge itx_underflow) begin
    if (all_sync_lock) $display("%m: at time %t: UNDERFLOW", $time);
  end

  always @(crc24_err_cnt) begin
    if (crc24_err_cnt > startup_errors_crc24) fail = 1'b1;
    $display("time: %d CRC24 error count %d", $time, crc24_err_cnt);
  end

  // Testcase example
  initial begin
    @(posedge reconfig_done_d);
    $display("Searching for lane alignment...");
    @(posedge all_sync_lock);
    $display("all_sync_locked...");

    #1000
    startup_errors_crc24 = crc24_err_cnt;
    startup_errors_crc32 = crc32_err_cnt;

    @(posedge rx_lanes_aligned)
    $display("rx_lanes_aligned...");

    #1000
    write_mm_task(16'h2037, 8'd0);       // set start channel ID
    write_mm_task(16'h2038, NUM_CHAN);     // set number of channels to use //8'd255
    write_mm_task(16'h2004, 1'b0);       // Enable gaps in TX traffic
    //$display("Enable gaps in TX traffic.");

    #200000
  //if (SIM_FAKE_JTAG) begin
      // Read PCS registers
      $display("PCS register reads...");
      read_mm_task(16'h1000, read_data_reg);
      read_mm_task(16'h1001, read_data_reg);
      read_mm_task(16'h1002, read_data_reg);
      read_mm_task(16'h1003, read_data_reg);
      read_mm_task(16'h1004, read_data_reg);
      read_mm_task(16'h1005, read_data_reg);
      read_mm_task(16'h1006, read_data_reg);
      read_mm_task(16'h1007, read_data_reg);
      read_mm_task(16'h1008, read_data_reg);
      read_mm_task(16'h1009, read_data_reg);
      read_mm_task(16'h100a, read_data_reg);
      read_mm_task(16'h100b, read_data_reg);
      read_mm_task(16'h100c, read_data_reg);
      read_mm_task(16'h100d, read_data_reg);
      read_mm_task(16'h100e, read_data_reg);
      read_mm_task(16'h100f, read_data_reg);
      read_mm_task(16'h1010, read_data_reg);
      read_mm_task(16'h1011, read_data_reg);
      read_mm_task(16'h1012, read_data_reg);
      read_mm_task(16'h1013, read_data_reg);
      read_mm_task(16'h1021, read_data_reg);
      read_mm_task(16'h1022, read_data_reg);

      // Read local testbench registers
      $display("Local register reads...");
      read_mm_task(16'h2000, read_data_reg);
      read_mm_task(16'h2002, read_data_reg);
      read_mm_task(16'h2003, read_data_reg);
      read_mm_task(16'h2004, read_data_reg);
      read_mm_task(16'h2005, read_data_reg);
      read_mm_task(16'h2006, read_data_reg);
      read_mm_task(16'h2007, read_data_reg);
      read_mm_task(16'h200a, read_data_reg);
      read_mm_task(16'h200b, read_data_reg);
      read_mm_task(16'h200c, read_data_reg);
      read_mm_task(16'h200d, read_data_reg);
      read_mm_task(16'h200e, read_data_reg);

      write_mm_task(16'h2036, 10'd256);    // Set burst size for burst interleaved mode

      // settings for run_mode 0
      write_mm_task(16'h2031, 16'd512);  // cpu_pkt_size_min
      write_mm_task(16'h2032, 4'd0);     // cpu_pkt_size_step
      write_mm_task(16'h2033, 16'd512);  // cpu_pkt_size_max
      write_mm_task(16'h2034, 2'd3);     // cpu_run_mode
      write_mm_task(16'h2035, 16'd1);    // cpu_pkts_to_run
      write_mm_task(16'h2030, 1'b1);     // 1 = run_directed_test; 0 = random_test

      $display("Start data transfers...");

      #200000
      write_mm_task(16'h200f, 1'b0);
      $display("Stop data transfers...");

      // Read performance measurement value
      read_mm_task(16'h2021, read_data_reg);
      write_mm_task(16'h2025, 1'b1);
      write_mm_task(16'h2025, 1'b0);

      // Write test on PCS loopback register

      $display("Read/Write test on PCS loopback register");
      read_mm_task (16'h1012, read_data_reg);
      write_mm_task(16'h1012, {NUM_LANES{1'b1}});
      read_mm_task (16'h1012, read_data_reg);
      write_mm_task(16'h1012, {NUM_LANES{1'b0}});
      read_mm_task (16'h1012, read_data_reg);

      #1300000
      read_mm_task (16'h2010, read_data_reg);  // read HW test detected errors
      $display("%10d CRC24 errors reported", crc24_err_cnt-startup_errors_crc24);
      $display("%10d SOPs transmitted", tx_sop_cnt);
      $display("%10d EOPs transmitted", tx_eop_cnt);
      $display("%10d SOPs received", sop_cntr_s);
      $display("%10d EOPs received", eop_cntr_s);

      // Read performance measurement value
      read_mm_task (16'h2021, read_data_reg);
      write_mm_task(16'h2025, 1'b1);
      write_mm_task(16'h2025, 1'b0);

      read_mm_task (16'h2041, read_data_reg);  // Read channel counter

      // System reset (cut system clock)
      #450000;
      write_mm_task(16'h2003, 32'h1);
      write_mm_task(16'h2002, 32'h1);
      $display("Assert System Reset");

      write_mm_task(16'h200f, 1'b0);
      @(negedge tx_usr_srst);
      write_mm_task(16'h2002, 32'h0);
      //write_mm_task(16'h2037, 8'd0);       // set start channel ID
      //write_mm_task(16'h2038, 8'd10);      // set number of channels to use

      // Read performance measurement value
      read_mm_task(16'h2021, read_data_reg);
      write_mm_task(16'h2025, 1'b1);
      write_mm_task(16'h2025, 1'b0);

      #3000000;
      write_mm_task(16'h1013, 32'h4);      // SW reset

      // Read performance measurement value
      read_mm_task(16'h2021, read_data_reg);
      write_mm_task(16'h2025, 1'b1);
      write_mm_task(16'h2025, 1'b0);

      $display("Read/Write ATX pll reset");
      //NOTE: Doing the below will reset the counters!
      read_mm_task(16'h1013, read_data_reg);

      read_mm_task(16'h1013, read_data_reg);
      //#2000000
      write_mm_task(16'h1013, 32'h0);
      read_mm_task(16'h1013, read_data_reg);

      //$display("Start data transfers...");
      write_mm_task(16'h200f, 1'b0);

      #2000000;
      write_mm_task(16'h200f, 1'b1);

      // System reset (cut system clock)
      for (j=0; j<1; j=j+1) begin // for (j=0; j<5; j=j+1) begin
        @(posedge rx_lanes_aligned_s);
        #200000;
        $display("Start data transfers...");
        write_mm_task(16'h2040, 8'd1);
        write_mm_task(16'h200f, 1'b1);

        for (l=0; l<1; l=l+1) begin  // for (l=0; l<5; l=l+1) begin
          #5000000;
          read_mm_task (16'h2010, read_data_reg);  // read HW test detected errors
          write_mm_task(16'h200f, 1'b0);           // Stop traffic
          #2000000;
          write_mm_task(16'h200f, 1'b1);           // Start traffic
          #10000000;

          // Read latency value
          $display("Reading Latency");
          write_mm_task(16'h2023, 1'b1);
          read_mm_task(16'h2024, read_data_reg);

          while (!read_data_reg[0]) begin
            read_mm_task(16'h2024, read_data_reg);
          end

          read_mm_task(16'h2013, read_data_reg);
          write_mm_task(16'h2023, 1'b0);

          // Read performance measurement value
          read_mm_task(16'h2021, read_data_reg);
          write_mm_task(16'h2025, 1'b1);
          write_mm_task(16'h2025, 1'b0);
        end

        #8000000;
        write_mm_task(16'h200f, 1'b0);
        #2500000;
        $display("%10d CRC24 errors reported", crc24_err_cnt-startup_errors_crc24);
        $display("%10d SOPs transmitted", tx_sop_cnt);
        $display("%10d EOPs transmitted", tx_eop_cnt);
        $display("%10d SOPs received", sop_cntr_s);
        $display("%10d EOPs received", eop_cntr_s);

        read_mm_task(16'h2041, read_data_reg);
        write_mm_task(16'h2002, 32'h1);
        $display("Asserting System Reset");
        @(negedge tx_usr_srst);
        write_mm_task(16'h2002, 32'h0);
    //end

      #200000;
      $display("Start data transfers...");
      write_mm_task(16'h200f, 1'b1);

      // Read performance measurement value
      read_mm_task(16'h2021, read_data_reg);
      write_mm_task(16'h2025, 1'b1);
      write_mm_task(16'h2025, 1'b0);

      write_mm_task(16'h2002, 32'h2);
      $display("Disable System Reset assertion");
    end

    startup_errors_crc24 = crc24_err_cnt;
    startup_errors_crc32 = crc32_err_cnt;

    #20000000
    read_mm_task(16'h2013, read_data_reg);
    write_mm_task(16'h200f, 1'b0);
    $display("Packet Generator Disabled");

    #10000000
    $display("%10d CRC24 errors reported", crc24_err_cnt-startup_errors_crc24);
    $display("%10d SOPs transmitted", tx_sop_cnt);
    $display("%10d EOPs transmitted", tx_eop_cnt);
    $display("%10d SOPs received", sop_cntr_s);
    $display("%10d EOPs received", eop_cntr_s);

    #1
    if (fail) $display("FAIL");
    else      $display("PASS");

    $finish;
  end
 // synthesis translate_on

endmodule
