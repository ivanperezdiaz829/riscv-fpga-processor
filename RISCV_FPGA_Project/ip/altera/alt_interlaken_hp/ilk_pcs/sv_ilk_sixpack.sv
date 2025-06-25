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


// baeckler - 06-07-2011
// Interlaken hard PCS six-pack

`timescale 1 ps/1 ps

module sv_ilk_sixpack #(
   parameter NUM_PLLS           = 1,
   parameter NUM_LANES          = 1,             // number of lanes used
   parameter LANE_PROFILE       = 6'b000001,
   parameter DATA_RATE          = "10312.5 Mbps",
   parameter PLL_OUT_FREQ       = "5156.25 MHz", // CAREFUL!! : this is MHz, not MBPS, typically 1/2 data rate
   parameter PLL_REFCLK_FREQ    =  "412.50 MHz",
   parameter INT_TX_CLK_DIV     = 1,             // CGB TX clock divider, typically 1
   parameter USE_ATX            = 1,

   parameter METALEN            = 128,
   parameter SCRAM_CONST        = 58'hdeadbeef123,

   // no override
   // parameter serialization_factor = 64,
   parameter WORD_SIZE          = 64,
    // parameter plls = 1,
   parameter REV_BITS           =  0,            // bit reversal in the data words
   parameter MAX_NUM_LANES      =  6,
   parameter NUM_BONDED         =  1,
   parameter W_BUNDLE_TO_XCVR   = 70,
   parameter W_BUNDLE_FROM_XCVR = 46
)(
   input                                         pll_pdn,
    // input pll_pdn_b,
   input                                         rst_txa,
   input                                         rst_txd,
   input                                         rst_rxa,
   input                                         rst_rxd,

   input                                         ref_clk,
   input                         [NUM_LANES-1:0] tx_coreclk,
   input                         [NUM_LANES-1:0] rx_coreclk,

   //data ports
   input                                         tx_burst_en,
   input               [WORD_SIZE*NUM_LANES-1:0] tx_parallel_data,
   output              [WORD_SIZE*NUM_LANES-1:0] rx_parallel_data,
   input                         [NUM_LANES-1:0] tx_control,
   output                        [NUM_LANES-1:0] rx_control,

   input                         [NUM_LANES-1:0] rx_serial_data,
   output                        [NUM_LANES-1:0] tx_serial_data,

   input                         [NUM_LANES-1:0] rx_seriallpbken,
   input                                         rx_set_locktodata,
   input                                         rx_set_locktoref,

   //clock outputs
   output                        [NUM_LANES-1:0] tx_clkout,
   output                        [NUM_LANES-1:0] rx_clkout,

   //control ports
   output                        [NUM_LANES-1:0] rx_is_lockedtodata,
   output                         [NUM_PLLS-1:0] pll_locked,

   output                        [NUM_LANES-1:0] tx_empty,
   output                        [NUM_LANES-1:0] tx_full,
   output                        [NUM_LANES-1:0] tx_pempty,
   output                        [NUM_LANES-1:0] tx_pfull,
   output                        [NUM_LANES-1:0] rx_empty,
   output                        [NUM_LANES-1:0] rx_full,
   output                        [NUM_LANES-1:0] rx_pempty,
   output                        [NUM_LANES-1:0] rx_pfull,
   output                        [NUM_LANES-1:0] rx_prbs_done,
   output                        [NUM_LANES-1:0] rx_prbs_err,
   input                         [NUM_LANES-1:0] rx_prbs_err_clr,

   // Interlaken PCS specific
   input                                         rx_fifo_clr,
   output                        [NUM_LANES-1:0] rx_wordlock,
   output                        [NUM_LANES-1:0] rx_metalock,
   output                        [NUM_LANES-1:0] rx_crc32err,
   output                        [NUM_LANES-1:0] rx_sh_err,
   output                        [NUM_LANES-1:0] rx_valid,
   input                         [NUM_LANES-1:0] rx_ready,
   input                         [NUM_LANES-1:0] tx_valid,
   output                        [NUM_LANES-1:0] tx_frame,
   input                         [NUM_LANES-1:0] tx_crc32err_inject,

   output                 [20*MAX_NUM_LANES-1:0] pcs_testbus,
   input    [W_BUNDLE_TO_XCVR*(NUM_LANES+1)-1:0] reconfig_to_xcvr,
   output [W_BUNDLE_FROM_XCVR*(NUM_LANES+1)-1:0] reconfig_from_xcvr   
// output [46*(MAX_NUM_LANES+1)-1:0] reconfig_from_xcvr,
// input [70*(MAX_NUM_LANES+1)-1:0] reconfig_to_xcvr
);

   //--------------------------------------------
   // helper
   //--------------------------------------------
   function integer count_ones;
      input integer val;
      begin
         count_ones = 0;
         while (val > 0) begin
            count_ones = count_ones + val[0];
            val = val >> 1;
         end
      end
   endfunction

   // sanity check the parameters
   // synthesis translate off
   initial begin
      if (count_ones(LANE_PROFILE) != NUM_LANES) begin
         $display ("ERROR: The number of lanes and lane pattern are not consistent");
         $stop();
      end
   end
   // synthesis translate on

   // e.g. the position of the 1st one in 4'b1001 is zero, 2nd is 3
   function integer position_of_nth_one;
      input integer val;
      input integer posn;
      integer p;
      integer c;
      begin
         position_of_nth_one = 0;
         p = 0;
         c = 0;
         while (val > 0 && c < posn) begin
            if (val[0])
               c = c + 1'b1;
            val = val >> 1;
            if (c == posn)
               position_of_nth_one = p;
            p = p + 1'b1;
         end
      end
   endfunction

   genvar ig;                                  // Iterator for generated loops

   localparam pll_refclk_cnt = 1;              // Number of reference clocks (per PLL)
   //localparam operation_mode = "DUPLEX";       // legal values: TX, RX, DUPLEX

   // Reconfig parameters
   localparam PLL_TYPE                 = (USE_ATX == 1) ? "ATX" : "CMU";
   localparam RECONFIG_INTERFACES      = NUM_PLLS+NUM_LANES;
   //localparam reconfig_interfaces  = MAX_NUM_LANES +1;
   
   //localparam w_bundle_to_xcvr     = 70;
   //localparam w_bundle_from_xcvr   = 46;

   localparam PCS_DATA_MAX_WIDTH       = 64;
   localparam PCS_RX_CONTROL_MAX_WIDTH = 10;
   localparam PCS_TX_CONTROL_MAX_WIDTH =  9;
   localparam PCS_CONTROL_USED_WIDTH   = (WORD_SIZE == 66)? 2 : 0;

   localparam PMA_PCS_WIDTH            = 40;

   localparam PROT_MODE                = "interlaken_mode";

   localparam TX_IDWIDTH               = "width_67";
   localparam TX_ODWIDTH               = "width_40";
   localparam RX_IDWIDTH               = "width_40";
   localparam RX_ODWIDTH               = "width_67";

   //wires for TX
   //PLD-PCS wires
   wire       [PCS_DATA_MAX_WIDTH*NUM_LANES-1:0] tx_datain_from_pld;
   wire [PCS_TX_CONTROL_MAX_WIDTH*NUM_LANES-1:0] tx_control_from_pld;

   wire [NUM_LANES-1:0] tx_coreclk_in;
   wire [NUM_LANES-1:0] rx_coreclk_in;

   //wire for RX
   wire       [PCS_DATA_MAX_WIDTH*NUM_LANES-1:0] rx_dataout_to_pld;
   wire [PCS_RX_CONTROL_MAX_WIDTH*NUM_LANES-1:0] rx_control_to_pld;
   wire [11*NUM_LANES-1:0] out_pld_reserved_out;

   // Declare local merged versions of reconfig buses
   wire   [W_BUNDLE_TO_XCVR*(NUM_LANES+1)-1:0] local_rcfg_to;
   wire [W_BUNDLE_FROM_XCVR*(NUM_LANES+1)-1:0] local_rcfg_from;

   //---------------------------------------------
   // bit reverse the data - msb first on the wire
   wire [NUM_LANES*WORD_SIZE-1:0] rx_parallel_data_rev;
   wire [NUM_LANES*WORD_SIZE-1:0] tx_parallel_data_rev;

   genvar i, j;

   generate
      for (i=0; i<NUM_LANES; i=i+1) begin : lp0
         for (j=0; j<WORD_SIZE; j=j+1) begin : lp1
            assign tx_parallel_data_rev[i*WORD_SIZE + j] = REV_BITS ?
                      tx_parallel_data[i*WORD_SIZE + (WORD_SIZE-1-j)] :
                      tx_parallel_data[i*WORD_SIZE + j];

            assign rx_parallel_data[i*WORD_SIZE + j] = REV_BITS ?
                      rx_parallel_data_rev[i*WORD_SIZE + (WORD_SIZE-1-j)] :
                      rx_parallel_data_rev[i*WORD_SIZE + j];
         end
      end
   endgenerate

///////////////////////////
// common TX PLL
   wire [NUM_PLLS-1:0] pll_out_clk;
   wire [NUM_PLLS-1:0] pll_fb_clk;

   sv_xcvr_plls #(
      .plls                                 (NUM_PLLS),        // number of PLLs
      .pll_type                             (PLL_TYPE),        // "AUTO","CMU","ATX","fPLL" (List i.e. "CMU,ATX,CMU,...")
      .pll_reconfig                         (0),               // 0-PLL reconfig not enabled. 1-PLL reconfig enabled
      .refclks                              (1),               // number of refclks per PLL
      .reference_clock_frequency            (PLL_REFCLK_FREQ), // refclk frequencies (List i.e. "100 MHz,150 MHz,156.25 MHz,...")
      .reference_clock_select               ("0"),             // refclk_sel per pll (List i.e. "0,3,1,2,...")
      .output_clock_datarate                ("0 Mbps"),        // outclk data rate (frequency*2)(List i.e. "5000 Mbps,2.5 Gbps,...") Not used if left at "0 Mbps"
      .output_clock_frequency               (PLL_OUT_FREQ),    // outclk frequency (List i.e. "5000 MHz, 1000 MHz,..."), Only used if output_clock_datarate unused.
      .feedback_clk                         ("internal"),      // feedback clock select per pll (List i.e. "internal,external,external,...")
      // Unused parameters
      .sim_additional_refclk_cycles_to_lock (0),               //
      .duty_cycle                           (50),              // duty cycle (List i.e. "50,40,55,...")
      .phase_shift                          ("0 ps"),          // phase shift (List i.e. "0 ps, 180 ps, ...")
      // Config options
      .enable_hclk                          ("0"),             // "1", "0", "1,0"
      //.enable_avmm                          (1),               // 1 = Include AVMM blocks
      .enable_avmm                          (0),               // 1 = Include AVMM blocks
      .use_generic_pll                      (0),               // 1 = Use generic PLL atoms, 0 = Use LC/CDR/FPLL atoms
      .att_mode                             (0),               // 1 = Use LC PLL 14G buffer output, 0 = Use 8G
      .enable_mux                           (1)                // 1 = Enable refclk mux, 0 = Disable
   ) sv_xcvr_plls (
      .refclk             (ref_clk),
      .rst                ({NUM_PLLS{pll_pdn}}),
      .fbclk              (pll_fb_clk),

      .pll_fb_sw          ({NUM_PLLS{1'b0}}),

      .outclk             (pll_out_clk),
      .locked             (pll_locked),
      .fboutclk           (pll_fb_clk),
      .hclk               (),

      .reconfig_to_xcvr   (local_rcfg_to   [NUM_LANES*W_BUNDLE_TO_XCVR   +: NUM_PLLS*W_BUNDLE_TO_XCVR]),
      .reconfig_from_xcvr (local_rcfg_from [NUM_LANES*W_BUNDLE_FROM_XCVR +: NUM_PLLS*W_BUNDLE_FROM_XCVR])
   );

   //-------------------------------
   // serdes lanes
   generate
      for (ig=0; ig<NUM_LANES; ig=ig+1) begin : sdlp

	// bonding size for bonded channel instantiations
	localparam PHYS_IDX = position_of_nth_one (LANE_PROFILE, ig+1);
		
	sv_xcvr_native 	#(
		// Common parameters
		.tx_clk_div          (INT_TX_CLK_DIV),

            // PMA Parameters
            .rx_enable                              (1),
            .tx_enable                              (1),
            .enable_10g_rx                          ("true"),
            .enable_10g_tx                          ("true"),
            .enable_8g_rx                           ("false"),
            .enable_8g_tx                           ("false"),
            .enable_dyn_reconfig                    ("false"),
            .enable_gen12_pipe                      ("false"),
            .enable_gen3_pipe                       ("false"),
            .enable_gen3_rx                         ("false"),
            .enable_gen3_tx                         ("false"),

            // Interface specific parameters
            .rx_pcs_pma_if_selectpcs                ("ten_g_pcs"),
            .rx_pld_pcs_if_selectpcs                ("ten_g_pcs"),
            .tx_pcs_pma_if_selectpcs                ("ten_g_pcs"),
            .rx_pcs_pma_if_prot_mode                ("other_protocols"),
            .com_pcs_pma_if_func_mode               ("teng_only"),
            .com_pcs_pma_if_prot_mode               ("other_protocols"),
            .com_pcs_pma_if_sup_mode                ("user_mode"),
            .com_pcs_pma_if_force_freqdet           ("force_freqdet_dis"),
            .com_pcs_pma_if_ppmsel                  ("ppmsel_1000"),

            .pcs10g_tx_tx_polarity_inv              ("invert_disable"),

            .bonded_lanes                           (NUM_BONDED),
            .pma_mode                               (PMA_PCS_WIDTH),
            .pma_data_rate                          (DATA_RATE),
            .auto_negotiation                       ("false"),

             // TX PCS parameters
            .pcs10g_tx_gb_tx_idwidth                (TX_IDWIDTH),
            .pcs10g_tx_gb_tx_odwidth                (TX_ODWIDTH),
            .pcs10g_tx_prot_mode                    (PROT_MODE),
            .pcs10g_tx_txfifo_mode                  ("interlaken_generic"),
            .pcs10g_tx_txfifo_pempty                (8),
            .pcs10g_tx_txfifo_pfull                 (23),
            .pcs10g_tx_sup_mode                     ("user_mode"),
         `ifdef ALTERA_RESERVED_QIS_ES
            .pcs10g_tx_frmgen_mfrm_length           ("frmgen_mfrm_length_user_setting"), //modified from frmsync_mfrm_length_user_setting
         `endif
            .pcs10g_tx_frmgen_mfrm_length_user      (METALEN),
            .pcs10g_tx_enc_64b66b_txsm_bypass       ("enc_64b66b_txsm_bypass_en"),
            .pcs10g_tx_tx_sm_bypass                 ("tx_sm_bypass_en"),
            .pcs10g_tx_scrm_seed                    ("scram_seed_user_setting"),
            .pcs10g_tx_scrm_seed_user               (SCRAM_CONST + 58'h123456789abcde + (24'h826a73 * ig)),
            .pcs10g_tx_test_mode                    ("test_off"),
            .pcs10g_tx_pseudo_random                ("all_0"),
            .pcs10g_tx_sq_wave                      ("sq_wave_4"),
            .pcs10g_tx_bit_reverse                  ("bit_reverse_en"),
            .pcs10g_tx_bitslip_en                   ("bitslip_dis"),
            .pcs10g_tx_tx_testbus_sel               ("crc32_gen_testbus1"),
            .pcs10g_tx_pmagate_en                   ("pmagate_dis"),
            .pcs10g_tx_sh_err                       ("sh_err_dis"),
            .pcs10g_tx_frmgen_burst                 ("frmgen_burst_en"),

            // RX PMA Parameters
            .cdr_reference_clock_frequency          (PLL_REFCLK_FREQ),

            // RX PCS Parameters
            .pcs10g_rx_gb_rx_idwidth                (RX_IDWIDTH),
            .pcs10g_rx_gb_rx_odwidth                (RX_ODWIDTH),
            .pcs10g_rx_prot_mode                    (PROT_MODE),

            .pcs10g_rx_gb_sel_mode                  ("internal"),
            .pcs10g_rx_blksync_bypass               ("blksync_bypass_dis"),
            .pcs10g_rx_blksync_knum_sh_cnt_prelock  ("knum_sh_cnt_prelock_10g"),
            .pcs10g_rx_blksync_knum_sh_cnt_postlock ("knum_sh_cnt_postlock_10g"),
            .pcs10g_rx_blksync_enum_invalid_sh_cnt  ("enum_invalid_sh_cnt_10g"),
         `ifdef ALTERA_RESERVED_QIS_ES
            .pcs10g_rx_frmsync_mfrm_length          ("frmsync_mfrm_length_user_setting"), //modified from frmsync_mfrm_length_user_setting
         `endif
            .pcs10g_rx_frmsync_mfrm_length_user     (METALEN),
            .pcs10g_rx_dis_signal_ok                ("dis_signal_ok_en"),
            .pcs10g_rx_bit_reverse                  ("bit_reverse_en"),
            .pcs10g_rx_bitslip_mode                 ("bitslip_dis"),
            .pcs10g_rx_rx_testbus_sel               ("crc32_chk_testbus1"),
            .pcs10g_rx_rx_polarity_inv              ("invert_disable"),
            .pcs10g_rx_rx_sm_hiber                  ("rx_sm_hiber_en"),
            .pcs10g_rx_rxfifo_mode                  ("generic_interlaken"),
            .pcs10g_rx_rxfifo_pempty                (5),
            .pcs10g_rx_rxfifo_pfull                 (23),
            .pcs10g_rx_sup_mode                     ("user_mode"),

            .pcs10g_rx_align_del                    ("align_del_dis"),
            .pcs10g_rx_control_del                  ("control_del_none"),

            .pcs10g_rx_test_mode                    ("test_off"),
            //.pcs10g_tx_tx_sh_location               ("msb"),
            //.pcs10g_rx_rx_sh_location               ("msb"),

            .rx_pld_pcs_if_is_10g_0ppm              ("true"),
            .tx_pld_pcs_if_is_10g_0ppm              ("true")
         ) sxn (
            // TX/RX ports
            .seriallpbken                          ({NUM_BONDED{rx_seriallpbken[ig]}}),    // 1 = enable serial loopback

            // RX Ports
            .rx_crurstn                            (~{NUM_BONDED{rst_rxa}}),
            .rx_datain                             (rx_serial_data[ig +: NUM_BONDED]),     // RX serial data input
            .rx_cdr_ref_clk                        ({NUM_BONDED{ref_clk}}),                // Reference clock for CDR
            .rx_ltd                                ({NUM_BONDED{rx_set_locktodata}}),      // Force lock-to-data stream
            .rxqpipulldn                           ({NUM_BONDED{1'b0}}), //to fix lint error
            .rx_clkdivrx                           (),
            .rx_is_lockedtoref                     (),                                     // Indicates lock to reference clock
            .rx_sd                                 (),  //to fix lint error

            // TX Ports
            .tx_rxdetclk                           (reconfig_to_xcvr[0]),                  // Clock for detection of downstream receiver
            .txqpipulldn                           ({NUM_BONDED{1'b0}}), // to fix lint error
            .txqpipullup                           ({NUM_BONDED{1'b0}}), // to fix lint error
            .in_pld_txdetectrx                     ({NUM_BONDED{1'b0}}), // to fix lint error
            .tx_rxfound                            (),  //to fix lint error
            .tx_dataout                            (tx_serial_data[ig +: NUM_BONDED]),     // TX serial data output
            .tx_rstn                               (~{NUM_BONDED{rst_txa}}),
            .pcs_rst_n                             ({NUM_BONDED{1'b0}}), // to fix lint error
            .tx_clkdivtx                           (), //to fix lint error
            .tx_ser_clk                            (pll_out_clk),                          // High-speed serial clock from PLL
            .tx_pcie_fb_clk                        (), //to fix lint error
            .tx_pll_fb_sw                          (), //to fix lint error

            // PCS Ports
            .in_agg_align_status                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_align_status_sync_0            ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_align_status_sync_0_top_or_bot ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_align_status_top_or_bot        ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_cg_comp_rd_d_all               ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_cg_comp_rd_d_all_top_or_bot    ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_cg_comp_wr_all                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_cg_comp_wr_all_top_or_bot      ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_del_cond_met_0                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_del_cond_met_0_top_or_bot      ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_en_dskw_qd                     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_en_dskw_qd_top_or_bot          ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_en_dskw_rd_ptrs                ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_en_dskw_rd_ptrs_top_or_bot     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_ovr_0                     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_ovr_0_top_or_bot          ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_rd_in_comp_0              ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_rd_in_comp_0_top_or_bot   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_rst_rd_qd                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_fifo_rst_rd_qd_top_or_bot      ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_insert_incomplete_0            ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_insert_incomplete_0_top_or_bot ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_latency_comp_0                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_latency_comp_0_top_or_bot      ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_rcvd_clk_agg                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_rcvd_clk_agg_top_or_bot        ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_rx_control_rs                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_rx_control_rs_top_or_bot       ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_rx_data_rs                     ({(NUM_BONDED*8){1'b0}}), // to fix lint error
            .in_agg_rx_data_rs_top_or_bot          ({(NUM_BONDED*8){1'b0}}), // to fix lint error
            .in_agg_test_so_to_pld_in              ({(NUM_BONDED){1'b0}}), // to fix lint error
            .in_agg_testbus                        ({(NUM_BONDED*16){1'b0}}), // to fix lint error
            .in_agg_tx_ctl_ts                      ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_tx_ctl_ts_top_or_bot           ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_agg_tx_data_ts                     ({(NUM_BONDED*8){1'b0}}), // to fix lint error
            .in_agg_tx_data_ts_top_or_bot          ({(NUM_BONDED*8){1'b0}}), // to fix lint error
            .in_emsip_com_in                       ({(NUM_BONDED*38){1'b0}}), //to fix lint error
            .in_emsip_com_special_in               ({(NUM_BONDED*20){1'b0}}), //to fix lint error
            .in_emsip_rx_clk_in                    ({(NUM_BONDED*3 ){1'b0}}), //to fix lint error
            .in_emsip_rx_in                        ({(NUM_BONDED*20){1'b0}}), //to fix lint error
            .in_emsip_rx_special_in                ({(NUM_BONDED*13){1'b0}}), //to fix lint error
            .in_emsip_tx_clk_in                    ({(NUM_BONDED*3 ){1'b0}}), //to fix lint error
            .in_emsip_tx_in                        ({(NUM_BONDED*104){1'b0}}), //to fix lint error
            .in_emsip_tx_special_in                ({(NUM_BONDED*13){1'b0}}), //to fix lint error

            .in_pld_10g_refclk_dig                 ({NUM_BONDED{1'b0}}),
            .in_pld_10g_rx_align_clr               ({NUM_BONDED{rx_fifo_clr}}),
            .in_pld_10g_rx_align_en                ({NUM_BONDED{1'b1}}),
            .in_pld_10g_rx_bitslip                 ({NUM_BONDED{1'b0}}),
            .in_pld_10g_rx_clr_ber_count           ({NUM_BONDED{1'b0}}),
            .in_pld_10g_rx_clr_errblk_cnt          ({NUM_BONDED{1'b0}}),
            .in_pld_10g_rx_disp_clr                ({NUM_BONDED{1'b0}}),
            .in_pld_10g_rx_pld_clk                 (rx_coreclk_in[ig +: NUM_BONDED]),
            .in_pld_10g_rx_prbs_err_clr            (rx_prbs_err_clr[ig +: NUM_BONDED]),

            .in_pld_10g_rx_rd_en                   (rx_ready[ig +: NUM_BONDED]),

            .in_pld_10g_rx_rst_n                   (~{NUM_BONDED{rst_rxd}}),

            .in_pld_tx_data                        (tx_datain_from_pld[PCS_DATA_MAX_WIDTH*ig +: NUM_BONDED*PCS_DATA_MAX_WIDTH]),
            .in_pld_10g_tx_bitslip                 ({(NUM_BONDED*7){1'b0}}),
            .in_pld_10g_tx_burst_en                ({NUM_BONDED{tx_burst_en}}),
            .in_pld_10g_tx_control                 (tx_control_from_pld[PCS_TX_CONTROL_MAX_WIDTH*ig +: NUM_BONDED*PCS_TX_CONTROL_MAX_WIDTH]),

            .in_pld_10g_tx_data_valid              (tx_valid[ig +: NUM_BONDED]),

            .in_pld_10g_tx_diag_status             ({NUM_BONDED{2'b11}}),
            .in_pld_10g_tx_pld_clk                 (tx_coreclk_in[ig +: NUM_BONDED]),
            .in_pld_10g_tx_rst_n                   (~{NUM_BONDED{rst_txd}}),
            .in_pld_10g_tx_wordslip                ({NUM_BONDED{1'b0}}),

            .in_pld_8g_a1a2_size                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_bitloc_rev_en               ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_bitslip                     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_byte_rev_en                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_bytordpld                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_cmpfifourst_n               ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_encdt                       ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_phfifourst_rx_n             ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_phfifourst_tx_n             ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_pld_rx_clk                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_pld_tx_clk                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_polinv_rx                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_polinv_tx                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_powerdown                   ({(NUM_BONDED*2){1'b0}}), // to fix lint error
            .in_pld_8g_prbs_cid_en                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rddisable_tx                ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rdenable_rmf                ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rdenable_rx                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_refclk_dig                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_refclk_dig2                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rev_loopbk                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rxpolarity                  ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_rxurstpcs_n                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_tx_blk_start                ({(NUM_BONDED*4){1'b0}}),
            .in_pld_8g_tx_boundary_sel             ({(NUM_BONDED*5){1'b0}}), // to fix lint error
            .in_pld_8g_tx_data_valid               ({(NUM_BONDED*4){1'b0}}), // to fix lint error
            .in_pld_8g_tx_sync_hdr                 ({(NUM_BONDED*2){1'b0}}), // to fix lint error
            .in_pld_8g_txdeemph                    ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_txdetectrxloopback          ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_txelecidle                  ({NUM_BONDED{1'b0}}),

            .in_pld_8g_txmargin                    ({(NUM_BONDED*3){1'b0}}), // to fix lint error
            .in_pld_8g_txswing                     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_txurstpcs_n                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_wrdisable_rx                ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_wrenable_rmf                ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_8g_wrenable_tx                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_agg_refclk_dig                 ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_eidleinfersel                  ({(NUM_BONDED*3){1'b0}}), // to fix lint error
            .in_pld_gen3_current_coeff             ({(NUM_BONDED*18){1'b0}}), // to fix lint error
            .in_pld_gen3_current_rxpreset          ({(NUM_BONDED*3){1'b0}}), // to fix lint error
            .in_pld_gen3_rx_rstn                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_gen3_tx_rstn                   ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_ltr                            ({NUM_BONDED{rx_set_locktoref}}),
            .in_pld_partial_reconfig_in            ({NUM_BONDED{1'b1}}),
            .in_pld_pcs_pma_if_refclk_dig          ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_rate                           ({(NUM_BONDED*2){1'b0}}), // to fix lint error
            .in_pld_reserved_in                    ({(NUM_BONDED*12){1'b0}}), // to fix lint error
            .in_pld_rx_clk_slip_in                 ({NUM_BONDED{1'b0}}),
            .in_pld_rxpma_rstb_in                  (~{NUM_BONDED{rst_rxa}}),
            .in_pld_scan_mode_n                    ({NUM_BONDED{1'b1}}),
            .in_pld_scan_shift_n                   ({NUM_BONDED{1'b1}}),
            .in_pld_sync_sm_en                     ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pld_tx_pma_data                    ({(NUM_BONDED*80){1'b0}}), // to fix lint error
            .in_pma_clkdiv33_lc_in                 ({NUM_BONDED{1'b0}}),
            .in_pma_eye_monitor_in                 ({(NUM_BONDED*2){1'b0}}), // to fix lint error
            .in_pma_hclk                           ({(NUM_BONDED*1){1'b0}}), // to fix lint error
            .in_pma_reserved_in                    ({(NUM_BONDED*5){1'b0}}), // to fix lint error
            .in_pma_rx_freq_tx_cmu_pll_lock_in     ({NUM_BONDED{1'b0}}),
            .in_pma_tx_lc_pll_lock_in              ({NUM_BONDED{1'b0}}),

            .out_agg_align_det_sync                (),
            .out_agg_align_status_sync             (),
            .out_agg_cg_comp_rd_d_out              (),
            .out_agg_cg_comp_wr_out                (),
            .out_agg_dec_ctl                       (),
            .out_agg_dec_data                      (),
            .out_agg_dec_data_valid                (),
            .out_agg_del_cond_met_out              (),
            .out_agg_fifo_ovr_out                  (),
            .out_agg_fifo_rd_out_comp              (),
            .out_agg_insert_incomplete_out         (),
            .out_agg_latency_comp_out              (),
            .out_agg_rd_align                      (),
            .out_agg_rd_enable_sync                (),
            .out_agg_refclk_dig                    (),
            .out_agg_running_disp                  (),
            .out_agg_rxpcs_rst                     (),
            .out_agg_scan_mode_n                   (),
            .out_agg_scan_shift_n                  (),
            .out_agg_sync_status                   (),
            .out_agg_tx_ctl_tc                     (),
            .out_agg_tx_data_tc                    (),
            .out_agg_txpcs_rst                     (),
            .out_emsip_com_clk_out                 (),
            .out_emsip_com_out                     (),
            .out_emsip_com_special_out             (),
            .out_emsip_rx_clk_out                  (),
            .out_emsip_rx_out                      (),
            .out_emsip_rx_special_out              (),
            .out_emsip_tx_clk_out                  (),
            .out_emsip_tx_out                      (),
            .out_emsip_tx_special_out              (),

            .out_pld_rx_data                       (rx_dataout_to_pld[PCS_DATA_MAX_WIDTH*ig +: NUM_BONDED*PCS_DATA_MAX_WIDTH]),
            .out_pld_10g_rx_align_val              (),
            .out_pld_10g_rx_blk_lock               (rx_wordlock[ig +: NUM_BONDED]),
            .out_pld_10g_rx_clk_out                (rx_clkout[ig +: NUM_BONDED]),
            .out_pld_10g_rx_control                (rx_control_to_pld[PCS_RX_CONTROL_MAX_WIDTH*ig +: NUM_BONDED*PCS_RX_CONTROL_MAX_WIDTH]),
            .out_pld_10g_rx_crc32_err              (rx_crc32err[ig +: NUM_BONDED]),
            .out_pld_10g_rx_data_valid             (rx_valid[ig +: NUM_BONDED]),
            .out_pld_10g_rx_diag_err               (),
            .out_pld_10g_rx_diag_status            (),
            .out_pld_10g_rx_empty                  (rx_empty[ig +: NUM_BONDED]),
            .out_pld_10g_rx_fifo_del               (),
            .out_pld_10g_rx_fifo_insert            (),
            .out_pld_10g_rx_frame_lock             (rx_metalock[ig +: NUM_BONDED]),
            .out_pld_10g_rx_hi_ber                 (),
            .out_pld_10g_rx_mfrm_err               (),
            .out_pld_10g_rx_oflw_err               (rx_full[ig +: NUM_BONDED]),
            .out_pld_10g_rx_pempty                 (rx_pempty[ig +: NUM_BONDED]),
            .out_pld_10g_rx_pfull                  (rx_pfull[ig +: NUM_BONDED]),
            .out_pld_10g_rx_prbs_err               (rx_prbs_err[ig +: NUM_BONDED]),
            .out_pld_10g_rx_pyld_ins               (),
            .out_pld_10g_rx_rdneg_sts              (),
            .out_pld_10g_rx_rdpos_sts              (),
            .out_pld_10g_rx_rx_frame               (),
            .out_pld_10g_rx_scrm_err               (),
            .out_pld_10g_rx_sh_err                 (rx_sh_err[ig +: NUM_BONDED]),
            .out_pld_10g_rx_skip_err               (),
            .out_pld_10g_rx_skip_ins               (),
            .out_pld_10g_rx_sync_err               (),

            .out_pld_10g_tx_burst_en_exe           (),
            .out_pld_10g_tx_clk_out                (tx_clkout[ig +: NUM_BONDED]),
            .out_pld_10g_tx_empty                  (tx_empty[ig +: NUM_BONDED]),
            .out_pld_10g_tx_fifo_del               (),
            .out_pld_10g_tx_fifo_insert            (),
            .out_pld_10g_tx_frame                  (tx_frame[ig +: NUM_BONDED]),
            .out_pld_10g_tx_full                   (tx_full[ig +: NUM_BONDED]),
            .out_pld_10g_tx_pempty                 (tx_pempty[ig +: NUM_BONDED]),
            .out_pld_10g_tx_pfull                  (tx_pfull[ig +: NUM_BONDED]),
            .out_pld_10g_tx_wordslip_exe           (),

            .out_pld_8g_a1a2_k1k2_flag             (),
            .out_pld_8g_align_status               (),
            .out_pld_8g_bistdone                   (),
            .out_pld_8g_bisterr                    (),
            .out_pld_8g_byteord_flag               (),
            .out_pld_8g_empty_rmf                  (),
            .out_pld_8g_empty_rx                   (),
            .out_pld_8g_empty_tx                   (),
            .out_pld_8g_full_rmf                   (),
            .out_pld_8g_full_rx                    (),
            .out_pld_8g_full_tx                    (),
            .out_pld_8g_phystatus                  (),
            .out_pld_8g_rlv_lt                     (),
            .out_pld_8g_rx_blk_start               (),
            .out_pld_8g_rx_clk_out                 (),
            .out_pld_8g_rx_data_valid              (),
            .out_pld_8g_rx_sync_hdr                (),
            .out_pld_8g_rxelecidle                 (),
            .out_pld_8g_rxstatus                   (),
            .out_pld_8g_rxvalid                    (),
            .out_pld_8g_signal_detect_out          (),
            .out_pld_8g_tx_clk_out                 (),
            .out_pld_8g_wa_boundary                (),

            .out_pld_clkdiv33_lc                   (),
            .out_pld_clkdiv33_txorrx               (),
            .out_pld_clklow                        (),
            .out_pld_fref                          (),
            .out_pld_gen3_mask_tx_pll              (),
            .out_pld_gen3_rx_eq_ctrl               (),
            .out_pld_gen3_rxdeemph                 (),
            .out_pld_reserved_out                  (out_pld_reserved_out[11*ig +: NUM_BONDED*11]),
            .out_pld_rx_pma_data                   (),  //to fix lint error
            .out_pld_test_data                     (pcs_testbus[PHYS_IDX*20 +: 20]),
            .out_pld_test_si_to_agg_out            (),
            //.out_pma_current_coeff               (),
            .out_pma_current_rxpreset              (),
            .out_pma_eye_monitor_out               (),
            .out_pma_lc_cmu_rstb                   (),
            .out_pma_nfrzdrv                       (),
            .out_pma_partial_reconfig              (),
            .out_pma_reserved_out                  (),
            .out_pma_rx_clk_out                    (),
            //.out_pma_rxpma_rstb                  (),
            .out_pma_tx_clk_out                    (),
            .out_pma_tx_pma_syncp_fbkp             (),

            .rx_is_lockedtodata                    (rx_is_lockedtodata[ig +: NUM_BONDED]),

            // sv_xcvr_avmm ports
            .reconfig_to_xcvr                      (local_rcfg_to  [ig*W_BUNDLE_TO_XCVR   +: NUM_BONDED*W_BUNDLE_TO_XCVR]),
            .reconfig_from_xcvr                    (local_rcfg_from[ig*W_BUNDLE_FROM_XCVR +: NUM_BONDED*W_BUNDLE_FROM_XCVR]),
            .tx_cal_busy                           (),
            .rx_cal_busy                           ()
		//.reconfig_to_xcvr           (local_rcfg_to   [PHYS_IDX*w_bundle_to_xcvr+:num_bonded*w_bundle_to_xcvr]    ),
		//.reconfig_from_xcvr         (local_rcfg_from [PHYS_IDX*w_bundle_from_xcvr+:num_bonded*w_bundle_from_xcvr])
	);
	   

         assign tx_coreclk_in[ig] = tx_coreclk[ig];
         assign rx_coreclk_in[ig] = rx_coreclk[ig];

         //*********************** parallel input/output rewiring ************************
         assign tx_datain_from_pld[ig*PCS_DATA_MAX_WIDTH +: WORD_SIZE]
                = tx_parallel_data_rev[ig*WORD_SIZE +: WORD_SIZE];

         assign rx_parallel_data_rev[ig*WORD_SIZE +: WORD_SIZE]
                = rx_dataout_to_pld[ig*PCS_DATA_MAX_WIDTH +: WORD_SIZE];

         // call all inbound data non-control
         assign tx_control_from_pld[PCS_TX_CONTROL_MAX_WIDTH*ig +: NUM_BONDED*PCS_TX_CONTROL_MAX_WIDTH]
                = {NUM_BONDED{tx_crc32err_inject[ig],6'b0,tx_control[ig],tx_control[ig] ^ 1'b1}};

         assign rx_control[ig] = !rx_control_to_pld[PCS_RX_CONTROL_MAX_WIDTH*ig + 0];

         assign rx_prbs_done[ig] = out_pld_reserved_out[11*ig + 0];

      end // ig
   endgenerate

   // zero out unused PCS testbus ports
   generate
      for(ig=0; ig<MAX_NUM_LANES; ig=ig+1) begin : pct
         if (LANE_PROFILE[ig] == 1'b0) begin
            assign pcs_testbus[ig*20 +: 20] = 20'b0;
         end
      end
   endgenerate

   ///////////////////////////
   // this bridges the reco clk/rst/etx

   // Merge critical reconfig signals
   ilk_reconfig_bundle_merger #(
      .RECONFIG_INTERFACES(RECONFIG_INTERFACES)
   ) rbm (
     // Reconfig buses to/from reconfig controller
     .rcfg_reconfig_to_xcvr   (reconfig_to_xcvr),
     .rcfg_reconfig_from_xcvr (reconfig_from_xcvr),

     // Reconfig buses to/from native xcvr
     .xcvr_reconfig_to_xcvr   (local_rcfg_to),
     .xcvr_reconfig_from_xcvr (local_rcfg_from)
   );

endmodule
