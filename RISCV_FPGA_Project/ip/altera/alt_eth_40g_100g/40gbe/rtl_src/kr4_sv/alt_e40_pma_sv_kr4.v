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

// force clocks for timing closure, cut paths between unrelated clocks
(* ALTERA_ATTRIBUTE = "disable_da_rule=\"d101,d103\"; -name MESSAGE_DISABLE 332056; -name SDC_STATEMENT \"create_clock -period {156.25 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|altera_pll_156M*|divclk}]\"; -name SDC_STATEMENT \"create_clock -period {156.25 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[0]*|*rx_pma_deser|clk33pcs}]\"; -name SDC_STATEMENT \"create_clock -period {156.25 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[1]*|*rx_pma_deser|clk33pcs}]\"; -name SDC_STATEMENT \"create_clock -period {156.25 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[2]*|*rx_pma_deser|clk33pcs}]\"; -name SDC_STATEMENT \"create_clock -period {156.25 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[3]*|*rx_pma_deser|clk33pcs}]\"; -name SDC_STATEMENT \"create_clock -period {161.132813 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*rx_pma_deser|clk90b}]\"; -name SDC_STATEMENT \"create_clock -period {161.132813 MHz} [get_pins -compatibility_mode {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*tx_pma_ch.tx_cgb|pclk[1]}]\"; -name SDC_STATEMENT \"set_clock_groups -exclusive -group {*GEN_KR4_SV.pma|altera_pll_156M*|divclk} -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*tx_pma_ch.tx_cgb|pclk[1]}\"; -name SDC_STATEMENT \"set_clock_groups -exclusive -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[0]*|*rx_pma_deser|clk33pcs} -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[1]*|*rx_pma_deser|clk33pcs} -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[2]*|*rx_pma_deser|clk33pcs} -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*xcvr_native_insts[3]*|*rx_pma_deser|clk33pcs} -group {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*rx_pma_deser|clk90b}\"; -name SDC_STATEMENT \"set_clock_groups -asynchronous -group {*GEN_KR4_SV.pma|altera_pll_156M*|divclk  *GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*rx_pma_deser|clk33pcs *GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*rx_pma_deser|clk90b *GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*tx_pma_ch.tx_cgb|pclk[1]}\"; -name SDC_STATEMENT \"set_false_path -from [get_keepers {*GEN_KR4_SV.pma|*alt_e40_kr4_lane*|*lt_top*}] -to [get_clocks {*GEN_KR4_SV.pma|alt_e40_native_e4x10_inst|*rx_pma_deser|clk90b}]\"" *)
module alt_e40_pma_sv_kr4 #(
    parameter PHY_ADDR_PREFIX = 10'h001,    // 0x40-0x7f
    parameter FAKE_TX_SKEW  = 1'b0,          // skew the TX data for simulation
    parameter SYNTH_AN      = 1,            // Synthesize/include the AN logic
    parameter SYNTH_LT      = 1,            // Synthesize/include the LT logic
    parameter SYNTH_SEQ     = 1,            // Synthesize/include Sequencer logic
    parameter SYNTH_FEC     = 1,            // Synthesize/include FEC blocks
    // Sequencer parameters not used in the AN block
    parameter LINK_TIMER_KR = 504,          // Link Fail Timer for BASE-R PCS in ms
    // LT parameters
    parameter BERWIDTH      = 12,           // Width (>4) of the Bit Error counter
    parameter TRNWTWIDTH    = 7,            // Width (7,8) of Training Wait counter
    parameter MAINTAPWIDTH  = 6,            // Width of the Main Tap control
    parameter POSTTAPWIDTH  = 5,            // Width of the Post Tap control
    parameter PRETAPWIDTH   = 4,            // Width of the Pre Tap control
    parameter VMAXRULE      = 6'd60,        // VOD+Post+Pre <= Device Vmax 1200mv
    parameter VMINRULE      = 6'd9,         // VOD-Post-Pre >= Device VMin 165mv
    parameter VODMINRULE    = 6'd24,        // VOD >= IEEE VOD Vmin of 440mV
    parameter VPOSTRULE     = 5'd31,        // Post_tap <= VPOST
    parameter VPRERULE      = 4'd15,        // Pre_tap <= VPRE
    parameter PREMAINVAL    = 6'd60,        // Preset Main tap value
    parameter PREPOSTVAL    = 5'd0,         // Preset Post tap value
    parameter PREPREVAL     = 4'd0,         // Preset Pre tap value
    parameter INITMAINVAL   = 6'd52,        // Initialize Main tap value
    parameter INITPOSTVAL   = 5'd30,        // Initialize Post tap value
    parameter INITPREVAL    = 4'd5,         // Initialize Pre tap value
    // AN parameters
    parameter AN_CHAN       = 4'b0001,      // "master" channel to run AN on (one-hot)
    parameter AN_PAUSE      = 3'b011,       // Initial setting for Pause ability, depends upon MAC  
    parameter AN_TECH       = 6'b00_1000,   // Tech ability, only 40G-KR4 valid
                                            // bit-0 = GigE, bit-1 = XAUI
                                            // bit-2 = 10G , bit-3 = 40G BP
                                            // bit 4 = 40G-CR4, bit 5 = 100G-CR10
    parameter AN_FEC        = 2'b11,        // Initial setting for FEC, bit1=request, bit0=ability 
    parameter AN_SELECTOR   = 5'b0_0001,    // AN selector field 802.3 = 5'd1
    parameter ERR_INDICATION = 0,           // Default state for FEC error indication enable on/off
    // PHY parameters
    parameter REF_CLK_FREQ_10G  = "644.53125 MHz", // speed for clk_ref
    parameter MGMT_CLK_IN_MHZ    = 100,     // clk_status rate in Mhz
    parameter PLL_TYPE_10G      = "ATX",    // transmit PLL (ATX or CMU)
    parameter LANES             = 4,        // for convenience; don't change
    parameter FEC_USE_M20K  = 0,            // Optimize FEC memory for M20K
    parameter OPTIONAL_RXEQ = 0,            //  Enable RX Equalization through link training
    parameter en_synce_support = 0
)(
    input pma_arst,   // asynchronous reset for native PHY reset controllers & CSRs
    input usr_an_lt_reset,
    input usr_seq_reset,
    input usr_fec_reset,
    input clk_status, // management/csr clock (for status_ bus)
    input clk_ref,    // high-speed serial reference clock 
    input rx_clk_ref, // synce support
    input tx_clk_ref,
	
    // to high speed IO pins
    input  [LANES-1:0] rx_serial,
    output [LANES-1:0] tx_serial,

    // 66 bit data words on clk_tx
    output              clk_tx,      // tx parallel data clock
    output              tx_ready,    // tx clocks stable
    output              tx_pll_lock, // plls locked (async signal)
    input  [66*LANES-1:0] tx_datain,
    input  [1:0]        err_inject,  // rising edge injects one bit error on tx data (before fec if enabled)
    output [LANES-1:0]  din_ack,     // tx data accept
    input  [LANES-1:0]  din_valid,   // tx data valid
    
    // 66 bit data words on clk_rx
    output              clk_rx,      // rx parallel data clock
    output              rx_ready,    // rx clocks stable
    output [LANES-1:0]  rx_cdr_lock, // cdr locked (async signal)
    output [66*LANES-1:0] rx_dataout,
    output [LANES-1:0]  dout_valid,  // rx data valid
    input  [LANES-1:0]  rx_bitslip,  // slip to frame for word lock
    input               lanes_deskewed, // indicates RX lock in 40G data mode

    // prbs TX
    input        prbs_tx_enable,
    input        prbs_tx_9_31n,
    input [LANES-1:0] prbs_error_inject,

    //PRBS RX
    input              prbs_rx_enable,
    input              prbs_rx_9_31n,
    output [LANES-1:0] prbs_error,
    
    // avalon_mm (on clk_status)
    input         status_read,
    input         status_write,
    input  [15:0] status_addr,
    output [31:0] status_readdata,
    input  [31:0] status_writedata,
    output        status_readdata_valid,
    
    // interface to reconfiguration bundle
    output [(LANES*92)-1:0]    reconfig_from_xcvr,
    input  [(LANES*140)-1:0]   reconfig_to_xcvr,
    
    input  [LANES-1:0]       rc_busy,    // reconfig is busy servicing request
                                         // for lane [3:0] 
    output [LANES-1:0]     lt_start_rc,    // start the TX EQ reconfig for lane 3-0
    output [(LANES*MAINTAPWIDTH)-1:0] main_rc, // main tap value for reconfig
    output [(LANES*POSTTAPWIDTH)-1:0] post_rc, // post tap value for reconfig
    output [(LANES*PRETAPWIDTH)-1:0]  pre_rc,  // pre tap value for reconfig
    output [(LANES*3)-1:0]   tap_to_upd,     // specific TX EQ tap to update
                                           // bit-2 = main, bit-1 = post, ...
    output [LANES-1:0]     en_lcl_rxeq,    // Enable local RX Equalization
    input  [LANES-1:0]     rxeq_done,      // Local RX Equalization is finished
    output [LANES-1:0]     seq_start_rc,   // start the PCS reconfig for lane 3-0
    output [LANES-1:0]     dfe_start_rc,   // start DFE reconfig for lane 3-0
    output [(LANES*2)-1:0] dfe_mode,       // DFE mode 00=disabled, 01=triggered, 10=continuous
    output [LANES-1:0]     ctle_start_rc,  // start CTLE reconfig for lane 3-0
    output [(LANES*4)-1:0] ctle_rc,        // CTLE manual setting for lane 3-0
    output [(LANES*2)-1:0] ctle_mode,      // CTLE mode 00=manual, 01=one-time, 10=continuous
    output [5:0]           pcs_mode_rc,    // PCS mode for reconfig - 1 hot
                                           // bit 0 = AN mode = low_lat, PLL LTR, 66:40
                                           // bit 1 = LT mode = low_lat, PLL LTD, 66:40
                                           // bit 2 = (N/A) 10G data mode = 10GBASE-R, 66:40
                                           // bit 3 = (N/A) GigE data mode = 8G PCS
                                           // bit 4 = (N/A) XAUI data mode = future?
                                           // bit 5 = 10G-FEC/40G data mode = low lat, 64:64
    input                   reco_mif_done,  // PMA reconfiguration done (resets the PHYs)
    
       // Daisy Chain Mode input for local TX update/status
    input [LANES-1:0] dmi_mode_en,        // Enable Daisy Chain mode
    input [LANES-1:0] dmi_frame_lock,     // SM has lock to training frames
    input [LANES-1:0] dmi_rmt_rx_ready,   // remote RX ready = status[15]
    input [LANES*6-1:0] dmi_lcl_coefl,      // local update low bits[5:0]
    input [LANES*2-1:0] dmi_lcl_coefh,      // local update high bits[13:12]
    input [LANES-1:0] dmi_lcl_upd_new,    // local update has changed
    input [LANES-1:0] dmi_rx_trained,     // SM is finished local training
       // Daisy Chain Mode outputs of remote update/status
    output [LANES-1:0] dmo_frame_lock,     // SM has lock to training frames
    output [LANES-1:0] dmo_rmt_rx_ready,   // remote RX ready = status[15]
    output [LANES*6-1:0] dmo_lcl_coefl,      // local update low bits[5:0]
    output [LANES*2-1:0] dmo_lcl_coefh,      // local update high bits[13:12]
    output [LANES-1:0] dmo_lcl_upd_new,    // local update has changed
    output [LANES-1:0] dmo_rx_trained,     // SM is finished local training
      // uP Mode inputs for remote EQ Optimization
    input [LANES-1:0] upi_mode_en,    // Enable uP mode
    input [LANES*2-1:0] upi_adj,        // select the active tap
    input [LANES-1:0] upi_inc,        // send the increment command 
    input [LANES-1:0] upi_dec,        // send the decrement command 
    input [LANES-1:0] upi_pre,        // send the preset command 
    input [LANES-1:0] upi_init,       // send the initialize command
    input [LANES-1:0] upi_st_bert,    // start the BER timer
    input [LANES-1:0] upi_train_err,  // Training Error indication
    input [LANES-1:0] upi_lock_err,   // Training frame lock Error
    input [LANES-1:0] upi_rx_trained, // local RX is Trained
      // uP Mode outputs for remote EQ Optimization
    output [LANES-1:0] upo_enable,     // Enable uP = ~re_start & en
    output [LANES-1:0] upo_frame_lock, // Receiver has Training frame lock
    output [LANES-1:0] upo_cm_done,    // Master SM done with handshake 
    output [LANES-1:0] upo_bert_done,  // BER Timer at max count 
    output [LANES*BERWIDTH-1:0] upo_ber_cnt, // BER counter value 
    output [LANES-1:0] upo_ber_max,    // BER counter roll-over
    output [LANES-1:0] upo_coef_max    // Remote Coefficients at max/min

);

    //****************************************************************************
    // Define Parameters 
    //****************************************************************************

    localparam LFT_CALC = LINK_TIMER_KR*MGMT_CLK_IN_MHZ;
    localparam LFT_R_MSB     = LFT_CALC/1000;              // Link Fail Timer MSB for BASE-R PCS
    localparam LFT_R_LSB     = LFT_CALC - LFT_R_MSB*1000;  // Link Fail Timer lsb for BASE-R PCS
        
    //****************************************************************************
    // Define Wires and Variables
    //****************************************************************************
    // for SEQ
    wire         seq_restart_an;        // sequencer reset of the AN
    wire         seq_restart_lt;        // sequencer reset of the LT
    wire [65:0]  an_data;               // raw data from AN.  bit-0 first
    wire [LANES-1:0]   rx_10g_bitslip;  // sig the PMA to slip the datastream
    wire [2:0]   par_det;
    wire         load_pdet;
    wire [1:0]   data_mux_sel;          // select data input to native PHY
                                        // 00 = AN, 01 = LT, 10 = data
    wire         fec_enable;
    wire         fec_request;
    wire         fec_err_ind;
    wire         force_fec;
    wire [LANES-1:0] fec_block_lock;
    wire         csr_seq_restart;   // re-start the sequencer
    wire [2:0]   force_mode;        // Force the Hard PHY into a mode
                                    // 000 = no force,  001 = GigE mode
                                    // 010 = XAUI mode, 100 = 10G-R mode
                                    // 101 = kr, 40G, 100G
    wire         dis_lf_timer;      // disable the link_fail_inhibit_timer
    wire         dis_an_timer;      // disable AN timeout.  can get stuck
                                    // stuck in ABILITY_DETECT - if rmt not AN
                                    // stuck in ACKNOWLEDGE_DETECT - if loopback
    wire         dis_max_wait_tmr;  // disable the LT max_wait_timer
    wire [LANES-1:0] training;      // Link Training in progress
    wire         link_ready;        // link is ready
    wire         seq_an_timeout;    // AN timed-out in Sequencer SM
    wire         seq_lt_timeout;    // LT timed-out in Sequencer SM
    wire         lt_enable;         // Enable LT
    wire         en_usr_np;         // Enable user next pages
    wire         pcs_link_sts;      // PCS link status from Hard PHY
    wire         lanes_deskew_sync; // lanes_deskewed synched to clk_status domain
    wire [LANES-1:0] ber_zero;      // LT reports ber_zero from last measurement
    wire         fail_lt_if_ber;    // if last LT measurement is non-zero, treat as a failed run
  
    // for PHY
    wire [LANES-1:0]   plls_locked;
    wire [LANES-1:0]   rx_set_locktodata;
    wire [LANES-1:0]   rx_set_locktoref;
    wire [LANES-1:0]   rx_is_lockedtoref;
    wire [LANES-1:0]   rx_is_lockedtodata;
    wire [(LANES*64)-1:0] tx_parallel_data;
    wire [(LANES*64)-1:0] rx_parallel_data;
    wire               tx_10g_coreclkin;
    wire [LANES-1:0]   rx_10g_coreclkin;
    wire [LANES-1:0]   tx_10g_clkout;
    wire [LANES-1:0]   rx_10g_clkout;
    wire [LANES-1:0]   rx_10g_clk33out;
    wire [(LANES*9)-1:0]  tx_10g_control;
    wire [(LANES*10)-1:0]  rx_10g_control;
    wire [LANES-1:0]   tx_cal_busy;
    wire [LANES-1:0]   rx_cal_busy;
    
    // for AN
    wire [LANES-1:0] an_chan_sel;    // AN channel selection 0-3 (one-hot)
    wire         link_good;          // AN completed
    wire         an_rx_idle;         // RX SM in idle state - from RX_CLK
    wire         enable_fec;         // Enable FEC for the channel
    wire         in_ability_det;     // ARB SM in the ABILITY_DETECT state
    wire         an_enable;          // enable AN
    wire [24:0]  lp_tech;            // LP Technology ability = D45:21
    wire [1:0]   lp_fec;             // LP FEC ability = D47:46  output reg
    wire [31:0]  an_mgmt_readdata;   // read data from the AN CSR module
    wire [31:0]  lt_mgmt_readdata;   // read data from the LT CSR module
    wire [(LANES*32)-1:0] fec_mgmt_readdata; // read data from FEC CSR modules
    wire [5:0]   fnl_an_tech;        // final AN_TECH parameter
    wire [1:0]   fnl_an_fec;         // final the AN_FEC parameter
    wire [2:0]   fnl_an_pause;       // final the AN_PAUSE parameter
    
       // signals between LT and CSRs
    wire [LANES-1:0] lt_restart;    // re-start the LT process
    wire [(LANES*10)-1:0] sim_ber_t;// Time(frames) to cnt when ber_time=0
    wire [(LANES*10)-1:0] ber_time; // Time(K-frames) to count BER Errors
    wire [(LANES*10)-1:0] ber_ext;  // Extend(M-frames) Time to count BER
    wire         quick_mode;        // Only look at init & preset EQ state
    wire         pass_one;          // look beyond first min in BER count
    wire [3:0]   main_step_cnt;     // Number of EQ steps per main update
    wire [3:0]   prpo_step_cnt;     // EQ steps for pre/post tap update
    wire [2:0]   equal_cnt;         // Number to make BER counts Equal
    wire [LANES-1:0] training_fail; // Training timed-out
    wire [LANES-1:0] training_error;// Training Error (ber_max)
    wire [LANES-1:0] train_lock_err;// Training Frame Lock Error
    wire [LANES-1:0] rx_trained_sts;// rx_trained status to CSR
    wire [(LANES*8)-1:0] lcl_txi_update;// Local coef update bits to TX
    wire [LANES-1:0] lcl_tx_upd_new;    // Local coef update new
    wire [(LANES*7)-1:0] lcl_txi_status;// Local status bits to transmit
    wire [LANES-1:0] lcl_tx_stat_new;   // Local coef status new
    wire [(LANES*8)-1:0] lp_rxi_update; // Override coef update bits to CSR
    wire [LANES-1:0] lp_rx_upd_new;     // Remote coef update new
    wire [(LANES*7)-1:0] lp_rxi_status; // Remote/LP status bits to CSR
    wire         ovrd_lp_coef;      // Override LP TX update enable
    wire [(LANES*8)-1:0] lp_txo_update; // Override LP TX update bits  
    wire [LANES-1:0] lp_tx_upd_new; // Override LP TX update new   
    wire         ovrd_coef_rx;      // Override lcl coef update enable
    wire [(LANES*8)-1:0] lcl_rxo_update;// Override lcl coef update bits from CSR
    wire [LANES-1:0] ovrd_rx_new;   // Override lcl coef update new
    wire [4*(2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+4)-1:0]  param_ovrd;
    wire         dis_init_pma;      // disable initialize PMA on timeout
    wire         lt_tm_enable;      // LT test mode enable
    wire [3:0]   lt_inj_err;        // inject errors into the LT TX data
    wire [3:0]   lt_tm_err_mode;
    wire [3:0]   lt_tm_err_trig;
    wire [7:0]   lt_tm_err_time;
    wire [7:0]   lt_tm_err_cnt;
    wire [2:0]   rx_ctle_mode;
    wire [2:0]   rx_dfe_mode;
    wire         max_mode;
    wire         fixed_mode;
    wire [2:0]   max_post_step;
    wire [1:0]   ctle_depth;
    wire [1:0]   dfe_extra;
    wire         only_inc_main;
    wire [2:0]   ctle_bias;
    wire         dec_post;
    wire         dec_post_more;
    wire         ctle_pass_ber;
    wire         use_full_time;
    wire [LANES-1:0] nolock_rxeq;
    wire [LANES-1:0] fail_ctle;
    wire [(LANES*2)-1:0] last_dfe_mode;
    wire [(LANES*4)-1:0] last_ctle_rc;
    wire [(LANES*2)-1:0] last_ctle_mode;
    
    
    reg    status_read_r;
    reg    status_write_r;
    reg [31:0] status_writedata_r;
    reg [7:0]  status_addr_r;

    wire tx_10g_clk33out;
    
    wire csr_reset_all;        // to reset controller
    wire fecgb_reset_tx, fecgb_reset_rx;
    
    wire [(LANES*66)-1:0] tx_parallel_data_66, tx_parallel_data_66_postnav, tx_parallel_data_66_r, 
                          tx_lane_parallel_data_66, rx_parallel_data_66, rx_parallel_data_66_prenav;

    wire rx_ready_prefec;
    wire [LANES-1:0] rx_ready_postfec;
    
    wire seq_rc_busy;

    genvar i;

    //****************************************************************************
    // Instantiate the Sequencer module
    //****************************************************************************
    generate
        if (SYNTH_SEQ) begin: SEQ_GEN
            wire seq_reset;
            wire seq_start_rc_i;

            
            alt_e40_seq_sm  #(
                .LFT_R_MSB    (LFT_R_MSB),
                .LFT_R_LSB    (LFT_R_LSB)
            ) SEQUENCER (
                .rstn       (~seq_reset),
                .clk        (clk_status),
                .restart    (csr_seq_restart),
                .an_enable  (an_enable),
                .lt_enable  (lt_enable),
                .frce_mode  (force_mode),
                .dis_max_wait_tmr (dis_max_wait_tmr),
                .dis_lf_timer  (dis_lf_timer),
                .dis_an_timer  (dis_an_timer),
                .en_usr_np     (en_usr_np), 
                .pcs_link_sts  (pcs_link_sts),
                .ber_zero      (&ber_zero),
                .fail_lt_if_ber(fail_lt_if_ber),
                .link_ready    (link_ready),
                .seq_an_timeout(seq_an_timeout),
                .seq_lt_timeout(seq_lt_timeout),
                .enable_fec    (enable_fec),
                .data_mux_sel  (data_mux_sel),
                // to/from Auto-Negotiation
                .lcl_tech       (fnl_an_tech),
                .lcl_fec        (fnl_an_fec),
                .link_good      (link_good),
                .in_ability_det (in_ability_det),
                .an_rx_idle     (an_rx_idle),
                .lp_tech     (lp_tech[5:0] | {{4{force_fec}}, 2'b0}),
                .lp_fec      (lp_fec | {2{force_fec}}),
                .load_pdet   (load_pdet),
                .par_det     (par_det),
                .restart_an  (seq_restart_an),
                // to/from Link Training
                .training    (|training),
                .restart_lt  (seq_restart_lt),
                // to/from reconfig
                .rc_busy     (seq_rc_busy),
                .start_rc    (seq_start_rc_i),
                .pcs_mode_rc (pcs_mode_rc)
            );
            
            // distribute sequencer reco requests across n lanes
            alt_e40_seq_reco_n #(
                .LANES(LANES)
            ) seq_reco_n (
                .clk(clk_status),
                .rst(seq_reset),
                // SEQ interface
                .seq_start_rc(seq_start_rc_i),
                .seq_rc_busy(seq_rc_busy), 
                // reco interface
                .reco_start_rc(seq_start_rc),
                .reco_rc_busy(rc_busy)
            );
            
            alt_xcvr_resync #(
                .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
                .WIDTH            (1),  // Number of bits to resync
                .INIT_VALUE       (1)
            ) mgmt_resync_reset (
                .clk    (clk_status),
                .reset  (usr_seq_reset | csr_reset_all),
                .d      (1'b0),
                .q      (seq_reset)
            );
        end  // if synth_seq
        else begin: NO_SEQ_GEN  // need to drive outputs if no SEQ module
            assign pcs_mode_rc   = SYNTH_AN ? 6'b000001 : // AN mode
                                   SYNTH_LT ? 6'b000010 : // LT mode
                                   6'b100000; // 40G data mode
            assign seq_start_rc  = 4'b0;
            assign seq_restart_lt = 1'b0;
            assign seq_restart_an = 1'b0;
            assign data_mux_sel   = SYNTH_AN ? 2'b00 : // AN mode
                                    SYNTH_LT ? 2'b01 : // LT mode
                                    2'b10;  // data mode
            assign enable_fec     = &fnl_an_fec;
            assign seq_an_timeout = 1'b0;
            assign seq_lt_timeout = 1'b0;
            assign link_ready     = lanes_deskew_sync;
            assign seq_rc_busy    = 1'b0;
        end // else synth_seq
    endgenerate
    
    alt_e40_status_sync #(
        .WIDTH(1)
    ) sync_deskew (
        .clk(clk_status),
        .din(lanes_deskewed),
        .dout(lanes_deskew_sync)
    );
    
    wire  [LANES-1:0] reset_controller_tx_ready;
    wire  [LANES-1:0] reset_controller_rx_ready;

    //****************************************************************************
    // Instantiate the AN module
    // also have the AN CSRs and test logic
    //****************************************************************************
    generate
        if (SYNTH_AN) begin: AN_GEN
            wire tx_an_reset, rx_an_reset;
            wire rx_an_clk;
            wire [65:0] rx_parallel_data_an;
            // signals between AN and CSRs
            wire         an_restart;         // re-start the AN process
            wire         restart_txsm;       // re-start the TXSM/ARB only
            wire         csr_lcl_rf;         // local device Remote Fault = D13
            wire         lcl_rf_sent;        // local device sent RF
            wire         en_usr_bp;          // Enable user base pages
            wire [48:16] usr_base_pgh;       // User base page hi bits
            wire [14:1]  usr_base_pgl;       // User base page low bits
            wire [48:16] usr_next_pgh;       // User next page hi bits
            wire [14:1]  usr_next_pgl;       // User next page low bits
            wire         lp_an_able;         // link partner is able to AN
            wire         an_pg_received;     // ARB SM has rcvd 3 codewords w/ ACK
            wire [48:1]  lp_base_pg;         // Link Partner base page data
            wire [48:1]  lp_next_pg;         // Link Partner next page data
            wire [2:0]   lp_pause;           // LP pause capability = D12:10
            wire         lp_rf;              // link partner Remote Fault = D13
            wire         usr_new_np;  // New next page, hand shake with usr_np_sent
            wire         usr_np_sent; // next page sent, hand shake with usr_new_np
            wire         csr_hold_nonce;     // Mode for UNH testing to hold TX_nonce
            wire         an_tm_enable;       // AN test mode enable
            wire [3:0]   an_inj_err;        // inject errors into the AN TX data
            wire [3:0]   an_tm_err_mode;
            wire [3:0]   an_tm_err_trig;
            wire [7:0]   an_tm_err_time;
            wire [7:0]   an_tm_err_cnt;
            wire         en_an_param_ovrd;   // Enable AN parameter override
            wire [5:0]   ovrd_an_tech;       // override the AN_TECH parameter
            wire [1:0]   ovrd_an_fec;        // override the AN_FEC parameter
            wire [2:0]   ovrd_an_pause;      // override the AN_PAUSE parameter
            wire         an_chan_ovrd;
            wire [LANES-1:0] an_chan_ovrd_sel;

            // Apply embedded false path timing constraints for AN
            (* altera_attribute =  "-name SDC_STATEMENT \"set_false_path -from [get_registers {*AUTO_NEG|*an_rx_sm:RX_SM|rx_lnk_cdwd[*]}] -to [get_registers {*AUTO_NEG|*an_arb_sm:ARB|*}]\"" *)
            alt_e40_an_top #(
                .PCNTWIDTH    (4),
                .AN_SELECTOR  (AN_SELECTOR)
            ) AUTO_NEG (
                .AN_PAUSE     (fnl_an_pause),
                .AN_TECH      (fnl_an_tech),
                .AN_FEC       (fnl_an_fec),
                .tx_rstn      (~tx_an_reset), 
                .tx_clk       (tx_10g_clk33out), 
                .rx_rstn      (~rx_an_reset), 
                .rx_clk       (rx_an_clk), 
                .an_enable    (an_enable), 
                .an_restart   (an_restart | seq_restart_an),
                .restart_txsm (restart_txsm),
                .lcl_rf       (csr_lcl_rf),
                .en_usr_bp    (en_usr_bp), 
                .en_usr_np    (en_usr_np), 
                .usr_base_pgh (usr_base_pgh), 
                .usr_base_pgl (usr_base_pgl), 
                .usr_next_pgh (usr_next_pgh), 
                .usr_next_pgl (usr_next_pgl), 
                .usr_new_np   (usr_new_np),
                .hold_nonce   (csr_hold_nonce),
                 // outputs
                .lp_an_able      (lp_an_able), 
                .link_good       (link_good), 
                .in_ability_det  (in_ability_det), 
                .an_rx_idle      (an_rx_idle), 
                .lcl_rf_sent     (lcl_rf_sent),
                .lp_pause        (lp_pause),
                .lp_rf           (lp_rf),
                .lp_tech         (lp_tech),
                .lp_fec          (lp_fec),
                .an_pg_received  (an_pg_received),
                .lp_base_pg      (lp_base_pg),
                .lp_next_pg      (lp_next_pg),
                .usr_np_sent     (usr_np_sent), // TODO unused?
                .load_pdet       (load_pdet), 
                .par_det         (par_det),
                 // data
                .dme_in       (rx_parallel_data_an),
                .inj_err      (an_inj_err), 
                .dme_out      (an_data)
            );

            // instantiate the AN registers at address 0xC0 - 0xCF
            alt_e40_csr_kran  csr_kran_inst (
                .clk        (clk_status        ),
                .reset      (pma_arst          ),
                .address    (status_addr_r     ),
                .read       (status_read_r     ),
                .readdata   (an_mgmt_readdata  ),
                .write      (status_write_r    ),
                .writedata  (status_writedata_r),
                //status inputs to this CSR
                .an_pg_received   (an_pg_received),
                .an_completed     (link_good),
                .lcl_dvce_rf_sent (lcl_rf_sent),
                .an_rx_idle       (an_rx_idle),
                .an_ability       (1'b1),       // if have AN, then should read 1
                .an_status        (link_good),  // latch low version
                .lp_an_able       (lp_an_able),
                .lp_fec_neg       (enable_fec),
                .an_failure       (seq_an_timeout),
                .an_link_ready    ({2'd0,pcs_mode_rc[5]&link_ready,3'b0}),
                .lp_base_pg   (lp_base_pg),
                .lp_next_pg   (lp_next_pg),
                .lp_tech      (lp_tech),
                .lp_fec       (lp_fec),
                .lp_rf        (lp_rf),
                .lp_pause     (lp_pause),
                // read/write control outputs
                .csr_an_enable    (an_enable),
                .usr_base_page_en (en_usr_bp),
                .usr_nxt_page_en  (en_usr_np),
                .usr_lcl_dvce_rf  (csr_lcl_rf),
                .csr_reset_an     (an_restart),
                .csr_restart_txsm (restart_txsm),
                .new_np_ready     (usr_new_np),
                .usr_base_pg_lo   (usr_base_pgl),
                .usr_base_pg_hi   (usr_base_pgh),
                .usr_next_pg_lo   (usr_next_pgl),
                .usr_next_pg_hi   (usr_next_pgh),
                .csr_hold_nonce   (csr_hold_nonce),
                .en_an_param_ovrd (en_an_param_ovrd),
                .ovrd_an_tech     (ovrd_an_tech),
                .ovrd_an_fec      (ovrd_an_fec),
                .ovrd_an_pause    (ovrd_an_pause),
                .an_tm_enable     (an_tm_enable),   // unused
                .an_tm_err_mode   (an_tm_err_mode), // unused
                .an_tm_err_trig   (an_tm_err_trig), // unused
                .an_tm_err_time   (an_tm_err_time), // unused
                .an_tm_err_cnt    (an_tm_err_cnt),  // unused
                .an_chan_ovrd     (an_chan_ovrd),
                .an_chan_ovrd_sel (an_chan_ovrd_sel)
            );

               // Override the AN Parameters
            assign fnl_an_tech  = en_an_param_ovrd ? ovrd_an_tech  : AN_TECH[5:0];
            assign fnl_an_fec   = en_an_param_ovrd ? ovrd_an_fec   : {fec_request, fec_enable};
            assign fnl_an_pause = en_an_param_ovrd ? ovrd_an_pause : AN_PAUSE[2:0];

               // instantiate the AN Test mode logic here
            //assign tm_out_trigger[3:2] = 2'd0;
            assign an_inj_err          = 4'd0;

            alt_xcvr_resync #(
                .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
                .WIDTH            (1),  // Number of bits to resync
                .INIT_VALUE       (1)
            ) tx_ansync_reset (
                .clk    (tx_10g_clk33out),
                .reset  (usr_an_lt_reset | csr_reset_all |
                         an_chan_sel[0] & !(reset_controller_tx_ready[0] & pcs_mode_rc[0]) |
                         an_chan_sel[1] & !(reset_controller_tx_ready[1] & pcs_mode_rc[0]) |
                         an_chan_sel[2] & !(reset_controller_tx_ready[2] & pcs_mode_rc[0]) |
                         an_chan_sel[3] & !(reset_controller_tx_ready[3] & pcs_mode_rc[0]) ),
                .d      (1'b0),
                .q      (tx_an_reset)
            );
            
            alt_xcvr_resync #(
                .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
                .WIDTH            (1),  // Number of bits to resync
                .INIT_VALUE       (1)
            ) rx_ansync_reset (
                .clk    (rx_an_clk),
                .reset  (usr_an_lt_reset | csr_reset_all |
                         an_chan_sel[0] & !(reset_controller_rx_ready[0] & pcs_mode_rc[0]) |
                         an_chan_sel[1] & !(reset_controller_rx_ready[1] & pcs_mode_rc[0]) |
                         an_chan_sel[2] & !(reset_controller_rx_ready[2] & pcs_mode_rc[0]) |
                         an_chan_sel[3] & !(reset_controller_rx_ready[3] & pcs_mode_rc[0]) ),
                .d      (1'b0),
                .q      (rx_an_reset)
            );
            
            alt_e40_gf_clock_mux #(
                .num_clocks(4)
            ) rx_an_clk_mux (
                .clk         (rx_10g_clk33out),
                .clk_select  (an_chan_sel),
                .clk_out     (rx_an_clk)
            );
            
            assign rx_parallel_data_an = (an_chan_sel[3] ? rx_parallel_data_66[66*3 +: 66] : 66'b0) |
                                         (an_chan_sel[2] ? rx_parallel_data_66[66*2 +: 66] : 66'b0) |
                                         (an_chan_sel[1] ? rx_parallel_data_66[66*1 +: 66] : 66'b0) |
                                         (an_chan_sel[0] ? rx_parallel_data_66[66*0 +: 66] : 66'b0);

            assign an_chan_sel    = an_chan_ovrd ? an_chan_ovrd_sel : AN_CHAN[3:0];

        end  // if synth_an
        else begin: NO_AN_GEN  // need to drive outputs if no AN module
            assign an_chan_sel    = AN_CHAN[3:0];
            assign link_good      = 1'b0;
            assign in_ability_det = 1'b0;
            assign an_rx_idle     = 1'b1;
            assign an_enable      = 1'b0;
            assign en_usr_np      = 1'b0;
            assign load_pdet      = 1'b0;
            //assign tm_out_trigger[3:2] = 2'd0;
            assign par_det = 3'd0;
            assign lp_tech = AN_TECH[5:0];
            assign lp_fec  = fnl_an_fec;
            assign an_data = 66'd0;
            assign an_mgmt_readdata = 32'd0;
            assign fnl_an_tech  = AN_TECH[5:0];
            assign fnl_an_fec   = {fec_request, fec_enable};
            assign fnl_an_pause = AN_PAUSE[2:0];
        end  // else synth_an
    endgenerate
    
    //****************************************************************************
    // Instantiate the LT module
    // also have the LT CSRs and test logic
    //****************************************************************************
    generate
        if (SYNTH_LT) begin: LT_GEN
        
            // instantiate the LT registers at address 0xD0 - 0xDF
            alt_e40_csr_krlt #(
                .MAINTAPWIDTH (MAINTAPWIDTH),
                .POSTTAPWIDTH (POSTTAPWIDTH),
                .PRETAPWIDTH  (PRETAPWIDTH)
            ) csr_krlt_inst (
                .clk        (clk_status        ),
                .reset      (pma_arst          ),
                .address    (status_addr_r     ),
                .read       (status_read_r     ),
                .readdata   (lt_mgmt_readdata  ),
                .write      (status_write_r    ),
                .writedata  (status_writedata_r),
                //status inputs to this CSR
                .rx_trained    (rx_trained_sts),
                .lt_frame_lock (dmo_frame_lock),
                .training      (training), 
                .training_fail (training_fail), 
                .training_error(training_error),
                .train_lock_err  (train_lock_err),
                .lcl_txi_update  (lcl_txi_update),
                .lcl_tx_upd_new  (lcl_tx_upd_new),
                .lcl_txi_status  (lcl_txi_status),
                .lcl_tx_stat_new (lcl_tx_stat_new),
                .lp_rxi_update   (lp_rxi_update),
                .lp_rx_upd_new   (lp_rx_upd_new),
                .lp_rxi_status   (lp_rxi_status),
                .lp_rx_stat_new  (dmo_lcl_upd_new),
                .nolock_rxeq     (nolock_rxeq),
                .fail_ctle       (fail_ctle),
                .last_dfe_mode   (last_dfe_mode),
                .last_ctle_rc    (last_ctle_rc),
                .last_ctle_mode  (last_ctle_mode),
                .main_rc     (main_rc),
                .post_rc     (post_rc),
                .pre_rc      (pre_rc),
                // read/write control outputs
                .csr_lt_enable    (lt_enable),
                .dis_max_wait_tmr (dis_max_wait_tmr),
                .dis_init_pma     (dis_init_pma),
                .quick_mode       (quick_mode),
                .pass_one         (pass_one),      
                .main_step_cnt    (main_step_cnt),  
                .prpo_step_cnt    (prpo_step_cnt),  
                .equal_cnt        (equal_cnt),
                .ovrd_lp_coef (ovrd_lp_coef),
                .ovrd_coef_rx (ovrd_coef_rx),
                .rx_ctle_mode  (rx_ctle_mode),
                .rx_dfe_mode   (rx_dfe_mode),
                .max_mode      (max_mode),
                .fixed_mode    (fixed_mode),
                .max_post_step (max_post_step),
                .ctle_depth    (ctle_depth),
                .dfe_extra     (dfe_extra),
                .only_inc_main (only_inc_main),
                .ctle_bias     (ctle_bias),
                .dec_post      (dec_post),
                .dec_post_more (dec_post_more),
                .ctle_pass_ber (ctle_pass_ber),
                .use_full_time (use_full_time),
                .csr_reset_lt (lt_restart),
                .ber_time     (sim_ber_t), 
                .ber_k_time   (ber_time), 
                .ber_m_time   (ber_ext), 
                .lcl_txo_update (lp_txo_update),
                .lp_tx_upd_new  (lp_tx_upd_new),
                .lcl_rxo_update (lcl_rxo_update),
                .ovrd_rx_new    (ovrd_rx_new),
                .param_ovrd     (param_ovrd),
                .lt_tm_enable   (lt_tm_enable),   // unused
                .lt_tm_err_mode (lt_tm_err_mode), // unused
                .lt_tm_err_trig (lt_tm_err_trig), // unused
                .lt_tm_err_time (lt_tm_err_time), // unused
                .lt_tm_err_cnt  (lt_tm_err_cnt)   // unused
            );

            // instantiate the LT Test mode logic here
            //assign tm_out_trigger[1:0] = 2'd0;
            assign lt_inj_err          = 4'd0;


        end  // if synth_lt
        else begin: NO_LT_GEN   // need to drive outputs if no LT module
            assign lt_enable        = 1'b0;
            assign dis_max_wait_tmr = 1'b0;
            assign dis_init_pma     = 1'b0;
            assign quick_mode       = 1'b0;
            assign pass_one         = 1'b0;
            assign main_step_cnt    = 4'b0;
            assign prpo_step_cnt    = 4'b0;
            assign equal_cnt        = 2'b0;
            assign ovrd_lp_coef     = 1'b0;
            assign ovrd_coef_rx     = 1'b0;
            assign rx_ctle_mode     = 3'b0;
            assign rx_dfe_mode      = 3'b0;
            assign max_mode         = 1'b0;
            assign fixed_mode       = 1'b0;
            assign max_post_step    = 3'b0;
            assign ctle_depth       = 2'b0;
            assign dfe_extra        = 2'b0;
            assign only_inc_main    = 1'b0;
            assign ctle_bias        = 3'b0;
            assign dec_post         = 1'b0;
            assign dec_post_more    = 1'b0;
            assign ctle_pass_ber    = 1'b0;
            assign use_full_time    = 1'b0;
            assign lt_restart       = 3'b0;
            assign sim_ber_t        = 40'b0;
            assign ber_time         = 40'b0;
            assign ber_ext          = 40'b0;
            assign lp_txo_update    = 32'b0;
            assign lp_tx_upd_new    = 4'b0;
            assign lcl_rxo_update   = 32'b0;
            assign ovrd_rx_new      = 4'b0;
            assign param_ovrd       = 0;
            assign lt_tm_enable     = 1'b0;
            assign lt_tm_err_mode   = 4'b0;
            assign lt_tm_err_trig   = 4'b0;
            assign lt_tm_err_time   = 8'b0;
            assign lt_tm_err_cnt    = 8'b0;
            //assign tm_out_trigger[1:0] = 2'd0;
            assign lt_inj_err       = 4'd0;
            assign lt_mgmt_readdata = 32'd0;
        end  // else synth_lt
    endgenerate

                              
    //****************************************************************************
    // Instantiate KR4 Lanes (data/LT)
    //****************************************************************************
    
    generate
        for (i=0; i<LANES; i=i+1) 
        begin : lane_gen
            alt_e40_kr4_lane #( 
                .SYNTH_LT (SYNTH_LT),
                .SYNTH_FEC (SYNTH_FEC),
                .BERWIDTH   (BERWIDTH),
                .TRNWTWIDTH (TRNWTWIDTH),
                .MAINTAPWIDTH (MAINTAPWIDTH),
                .POSTTAPWIDTH (POSTTAPWIDTH),
                .PRETAPWIDTH  (PRETAPWIDTH),
                .VMAXRULE (VMAXRULE),
                .VMINRULE (VMINRULE),
                .VODMINRULE (VODMINRULE),
                .VPOSTRULE  (VPOSTRULE),
                .VPRERULE   (VPRERULE),
                .PREMAINVAL (PREMAINVAL),
                .PREPOSTVAL (PREPOSTVAL),
                .PREPREVAL  (PREPREVAL),
                .INITMAINVAL (INITMAINVAL),
                .INITPOSTVAL (INITPOSTVAL),
                .INITPREVAL  (INITPREVAL),
                .PRBS_SEED(1<<i),
                .LT_SEED(11'h2be ^ (11'h7ff >> (i*3))),
                .REG_OFFS(i*3),
                .FEC_USE_M20K(FEC_USE_M20K),
                .OPTIONAL_RXEQ (OPTIONAL_RXEQ)
            ) kr4_lane (
                .lt_reset_tx(usr_an_lt_reset | csr_reset_all | 
                             !(reset_controller_tx_ready[i] & pcs_mode_rc[1]) ), 
                .lt_reset_rx(usr_an_lt_reset | csr_reset_all | 
                             !(reset_controller_rx_ready[i] & pcs_mode_rc[1]) ),
                .fecgb_reset_tx(fecgb_reset_tx), 
                .fecgb_reset_rx(fecgb_reset_rx),
                .rx_ready(rx_ready_prefec),
                .rx_ready_out(rx_ready_postfec[i]),
                
                .fec_block_lock(fec_block_lock[i]),
                
                .feccsr_clk(clk_status),
                .feccsr_reset(pma_arst),
                .feccsr_address(status_addr_r),
                .feccsr_read(status_read_r),
                .feccsr_readdata(fec_mgmt_readdata[i*32 +: 32]),
                .feccsr_write(status_write_r),
                .feccsr_writedata(status_writedata_r),
                
                .r_rx_err_mark(fec_err_ind),
                
                .clk_tx(clk_tx),
                .tx_datain(tx_datain[i*66 +: 66]),
                .tx_dataout(tx_lane_parallel_data_66[i*66 +: 66]),
                .err_inject(i==0 ? err_inject : 2'b0),
                .din_ack(din_ack[i]),
                .din_valid(din_valid[i]),

                .clk_rx(clk_rx),
                .rx_datain(rx_parallel_data_66[i*66 +: 66]), 
                .rx_dataout(rx_dataout[i*66 +: 66]),
                .dout_valid(dout_valid[i]),
                .rx_bitslip(rx_bitslip[i]),
                
                .prbs_tx_enable(prbs_tx_enable),
                .prbs_tx_9_31n(prbs_tx_9_31n),
                .prbs_error_inject(prbs_error_inject[i]),

                .prbs_rx_enable(prbs_rx_enable),
                .prbs_rx_9_31n(prbs_rx_9_31n),
                .prbs_error(prbs_error[i]),
    
                .clk33_tx(tx_10g_clk33out),
                .clk33_rx(rx_10g_clk33out[i]),
                .data_mux_sel(data_mux_sel[1]),
                .enable_fec(enable_fec),
                .lt_enable(lt_enable),
                .lt_restart(lt_restart[i] | seq_restart_lt),
                .pma_rx_bitslip(rx_10g_bitslip[i]),
                
                .training(training[i]),
                .training_fail(training_fail[i]),
                .training_error(training_error[i]),
                .train_lock_err(train_lock_err[i]),
                .rx_trained_sts(rx_trained_sts[i]),
                .lcl_txi_update(lcl_txi_update[i*8 +: 8]),
                .lcl_tx_upd_new(lcl_tx_upd_new[i]),
                .lcl_txi_status(lcl_txi_status[i*7 +: 7]),
                .lcl_tx_stat_new(lcl_tx_stat_new[i]),
                .lp_rxi_update(lp_rxi_update[i*8 +: 8]),
                .lp_rx_upd_new(lp_rx_upd_new[i]),
                .lp_rxi_status(lp_rxi_status[i*7 +: 7]),
                .nolock_rxeq     (nolock_rxeq[i]),
                .fail_ctle       (fail_ctle[i]),
                .last_dfe_mode   (last_dfe_mode[i*2 +: 2]),
                .last_ctle_rc    (last_ctle_rc[i*4 +: 4]),
                .last_ctle_mode  (last_ctle_mode[i*2 +: 2]),
                .ber_zero        (ber_zero[i]),
                
                .sim_ber_t(sim_ber_t[i*10 +: 10]),
                .ber_time(ber_time[i*10 +: 10]),
                .ber_ext(ber_ext[i*10 +: 10]),
                .dis_max_wait_tmr(dis_max_wait_tmr),
                .dis_init_pma(dis_init_pma),
                .quick_mode(quick_mode),
                .pass_one(pass_one),
                .main_step_cnt(main_step_cnt),
                .prpo_step_cnt(prpo_step_cnt),
                .equal_cnt(equal_cnt),
                .ovrd_lp_coef(ovrd_lp_coef),
                .lp_txo_update(lp_txo_update[i*8 +: 8]),
                .lp_tx_upd_new(lp_tx_upd_new[i]),
                .param_ovrd(param_ovrd[(2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+4)*i
                                      +:2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+4]),
                .ovrd_coef_rx(ovrd_coef_rx),
                .lcl_rxo_update(lcl_rxo_update[i*8 +: 8]),
                .ovrd_rx_new(ovrd_rx_new[i]),
                .lt_inj_err(lt_inj_err),
                .rx_ctle_mode   (rx_ctle_mode),
                .rx_dfe_mode    (rx_dfe_mode),
                .max_mode       (max_mode),
                .fixed_mode     (fixed_mode),
                .max_post_step  (max_post_step),
                .ctle_depth     (ctle_depth),
                .dfe_extra      (dfe_extra),
                .only_inc_main  (only_inc_main),
                .ctle_bias      (ctle_bias),
                .dec_post       (dec_post),
                .dec_post_more  (dec_post_more),
                .ctle_pass_ber  (ctle_pass_ber),
                .use_full_time  (use_full_time),
                
                .rc_busy(rc_busy[i]),
                .lt_start_rc(lt_start_rc[i]),
                .dfe_start_rc(dfe_start_rc[i]),
                .dfe_mode    (dfe_mode[i*2 +: 2]),
                .ctle_start_rc(ctle_start_rc[i]),
                .ctle_rc     (ctle_rc[i*4 +: 4]),
                .ctle_mode   (ctle_mode[i*2 +: 2]),
                .main_rc(main_rc[i*MAINTAPWIDTH +: MAINTAPWIDTH]),
                .post_rc(post_rc[i*POSTTAPWIDTH +: POSTTAPWIDTH]),
                .pre_rc(pre_rc[i*PRETAPWIDTH +: PRETAPWIDTH]),
                .tap_to_upd(tap_to_upd[i*3 +: 3]),
                .rxeq_done(rxeq_done[i]),
                
                .dmi_mode_en(dmi_mode_en[i]),
                .dmi_frame_lock(dmi_frame_lock[i]),
                .dmi_rmt_rx_ready(dmi_rmt_rx_ready[i]),
                .dmi_lcl_coefl(dmi_lcl_coefl[i*6 +: 6]),
                .dmi_lcl_coefh(dmi_lcl_coefh[i*2 +: 2]),
                .dmi_lcl_upd_new(dmi_lcl_upd_new[i]),
                .dmi_rx_trained(dmi_rx_trained[i]),
                
                .dmo_frame_lock(dmo_frame_lock[i]),
                .dmo_rmt_rx_ready(dmo_rmt_rx_ready[i]),
                .dmo_lcl_coefl(dmo_lcl_coefl[i*6 +: 6]),
                .dmo_lcl_coefh(dmo_lcl_coefh[i*2 +: 2]),
                .dmo_lcl_upd_new(dmo_lcl_upd_new[i]),
                .dmo_rx_trained(dmo_rx_trained[i]),
                
                .upi_mode_en(upi_mode_en[i]),
                .upi_adj(upi_adj[i*2 +: 2]),
                .upi_inc(upi_inc[i]),
                .upi_dec(upi_dec[i]),
                .upi_pre(upi_pre[i]),
                .upi_init(upi_init[i]),
                .upi_st_bert(upi_st_bert[i]),
                .upi_train_err(upi_train_err[i]),
                .upi_lock_err(upi_lock_err[i]),
                .upi_rx_trained(upi_rx_trained[i]),
                
                .upo_enable(upo_enable[i]),
                .upo_frame_lock(upo_frame_lock[i]),
                .upo_cm_done(upo_cm_done[i]),
                .upo_bert_done(upo_bert_done[i]),
                .upo_ber_cnt(upo_ber_cnt[i*BERWIDTH +: BERWIDTH]),
                .upo_ber_max(upo_ber_max[i]),
                .upo_coef_max(upo_coef_max[i])

            );
        end
    endgenerate
    
    // Drive the status output
    assign en_lcl_rxeq = rx_trained_sts;
    
    //****************************************************************************
    // Instantiate Native PHY, Reset controller, fPLL
    //****************************************************************************

    //////////////////////////////////
    //reset controller outputs
    //////////////////////////////////
    wire              reset_controller_pll_powerdown;
    wire  [LANES-1:0] reset_controller_tx_digitalreset;
    wire  [LANES-1:0] reset_controller_rx_analogreset;
    wire  [LANES-1:0] reset_controller_rx_digitalreset;

    // Control & status register map (CSR) outputs
    wire  csr_reset_tx_digital;    // to reset controller
    wire  csr_reset_rx_digital;    // to reset controller
    wire  csr_pll_powerdown;
    wire [LANES - 1 : 0] csr_tx_digitalreset;        // to xcvr instance
    wire [LANES - 1 : 0] csr_rx_analogreset;        // to xcvr instance
    wire [LANES - 1 : 0] csr_rx_digitalreset;        // to xcvr instance
    wire [LANES - 1 : 0] csr_phy_loopback_serial;    // to xcvr instance
    wire [LANES - 1 : 0] csr_rx_set_locktoref;        // to xcvr instance
    wire [LANES - 1 : 0] csr_rx_set_locktodata;        // to xcvr instance

    // Final reset signals
    wire  pll_powerdown_fnl;
    wire  [LANES-1:0] tx_analogreset_fnl;
    wire  [LANES-1:0] tx_digitalreset_fnl;
    wire  [LANES-1:0] rx_analogreset_fnl;
    wire  [LANES-1:0] rx_digitalreset_fnl;
    
    wire fboutclk1;
    wire pll156M_locked;
    
    wire tx_pma_ready, rx_pma_ready;

    assign  pll_powerdown_fnl   = csr_pll_powerdown;
    assign  tx_analogreset_fnl  = {LANES{csr_pll_powerdown}};
    assign  tx_digitalreset_fnl = csr_tx_digitalreset;
    assign  rx_analogreset_fnl  = csr_rx_analogreset;
    assign  rx_digitalreset_fnl = csr_rx_digitalreset;
   
    wire  [LANES-1:0]   rx_manual_mode;

    // Put reset controller into manual mode when we are not in auto lock mode
    assign  rx_manual_mode = (rx_set_locktoref | rx_set_locktodata);
    // We have a single tx_ready, rx_ready output per IP instance
    assign  tx_pma_ready  = &reset_controller_tx_ready & ~seq_rc_busy;
    assign  rx_pma_ready  = &reset_controller_rx_ready & ~seq_rc_busy;

    assign tx_pll_lock = &plls_locked & pll156M_locked;
    assign rx_cdr_lock = rx_is_lockedtodata; 
    
    wire pll_inclk, cdr_ref_clk;

    generate
      if (en_synce_support) begin
        // clock distribution
        assign pll_inclk   = tx_clk_ref;
        assign cdr_ref_clk = rx_clk_ref;		
      end
      else begin
        // clock distribution
        assign pll_inclk   = clk_ref;
        assign cdr_ref_clk = clk_ref;
      end
    endgenerate
	
    
    altera_xcvr_reset_control #( 
        .CHANNELS(LANES),
        .PLLS(1),
        .SYNCHRONIZE_RESET(1),
        .SYNCHRONIZE_PLL_RESET(1),
        .TX_PLL_ENABLE(1),
        .TX_ENABLE(1),
        .RX_ENABLE(1),
        .RX_PER_CHANNEL(1),
        .SYS_CLK_IN_MHZ(MGMT_CLK_IN_MHZ)
    ) reset_controller (
        .clock               (clk_status),
        .reset               (pma_arst || reco_mif_done),
        .pll_powerdown       (reset_controller_pll_powerdown),
        .tx_analogreset      (/*unused*/),
        .tx_digitalreset     (reset_controller_tx_digitalreset),
        .rx_analogreset      (reset_controller_rx_analogreset),
        .rx_digitalreset     (reset_controller_rx_digitalreset),
        .tx_ready            (reset_controller_tx_ready),
        .rx_ready            (reset_controller_rx_ready),
        .tx_digitalreset_or  ({LANES{csr_reset_tx_digital}}),  // reset request for tx_digitalreset
        .rx_digitalreset_or  ({LANES{csr_reset_rx_digital}}),  // reset request for rx_digitalreset
        .pll_locked          (tx_pll_lock),
        .pll_select          (1'b0),
        .tx_cal_busy         (tx_cal_busy),
        .rx_cal_busy         (rx_cal_busy),
        .rx_is_lockedtodata  (rx_is_lockedtodata), 
        .rx_manual       (rx_manual_mode),  // TODO: kr example des sets this to 1 all the time
                                          // but low latency phy sets it to csr_rx_set_locktoref | csr_rx_set_locktodata
                                          // who is right? Should reset ctrl be in auto mode when in LT/data?
                                  // 0 = Automatically restart rx_digitalreset
                                  // when rx_is_lockedtodata deasserts
                                  // 1 = Do nothing on rx_is_lockedtodata deassert
        .tx_manual       ({LANES{1'b1}})   // 0 = Automatically restart tx_digitalreset
                                  // when pll_locked deasserts.
                                  // 1 = Do nothing when pll_locked deasserts
    );
      
    // TODO, does the 644MHz clock need to be div2? (can't find this in the documentation)
    generic_pll  #(
        .reference_clock_frequency (REF_CLK_FREQ_10G),    // need refclk divider for FFPLL
        .output_clock_frequency    ("156.25 MHz")
    ) altera_pll_156M  (
        .outclk           (tx_10g_clk33out),
        .fboutclk         (fboutclk1),
        .rst              (pma_arst),
        .refclk           (pll_inclk),
        .fbclk            (fboutclk1),
        .locked           (pll156M_locked ),

        .writerefclkdata     (/*unused*/  ),
        .writeoutclkdata     (/*unused*/  ),
        .writephaseshiftdata (/*unused*/  ),
        .writedutycycledata  (/*unused*/  ),
        .readrefclkdata      (/*unused*/  ),
        .readoutclkdata      (/*unused*/  ),
        .readphaseshiftdata  (/*unused*/  ),
        .readdutycycledata   (/*unused*/  )
    );

    alt_xcvr_resync #(
        .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
        .WIDTH            (1),  // Number of bits to resync
        .INIT_VALUE       (1)
    ) tx_fecsync_reset (
        .clk    (clk_tx),
        .reset  (usr_fec_reset | csr_reset_all | !tx_ready),
        .d      (1'b0),
        .q      (fecgb_reset_tx)
    );
    
    alt_xcvr_resync #(
        .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
        .WIDTH            (1),  // Number of bits to resync
        .INIT_VALUE       (1)
    ) rx_fecsync_reset (
        .clk    (clk_rx),
        .reset  (usr_fec_reset | csr_reset_all | !rx_ready_prefec),
        .d      (1'b0),
        .q      (fecgb_reset_rx)
    );
    
    //****************************************************************************
    // Muxes/logic for the AN data and status
    // Selection is made by the Sequencer
    // 00 = AN, 01 = LT, 1x = data
    //****************************************************************************

    generate
        for (i=0; i<LANES; i=i+1) 
        begin : tx_ansel
            assign tx_parallel_data_66[66*i +: 66] = 
                (data_mux_sel == 2'b00) ? (an_chan_sel[i] ? an_data : 66'b0)
                                        : tx_lane_parallel_data_66[66*i +: 66];
        end
    
        for (i=0; i<LANES; i=i+1) 
        begin : tx_pardat
            assign tx_10g_control[9*i+1] = tx_parallel_data_66_r[66*i+0];
            assign tx_10g_control[9*i+0] = tx_parallel_data_66_r[66*i+1];
            assign tx_10g_control[(9*i+2) +: 7] = 7'b0;
            assign tx_parallel_data[(64*i) +: 64] = tx_parallel_data_66_r[(66*i+2) +: 64];
        end
        for (i=0; i<LANES; i=i+1) 
        begin : rx_pardat
            assign rx_parallel_data_66_prenav[66*i+0] = rx_10g_control[10*i+1];
            assign rx_parallel_data_66_prenav[66*i+1] = rx_10g_control[10*i+0];
            assign rx_parallel_data_66_prenav[(66*i+2) +: 64] = rx_parallel_data[(64*i) +: 64];
        end
    endgenerate
    
    // Mux the link status depending upon which datapath is active
    assign pcs_link_sts = pcs_mode_rc[5] ? lanes_deskew_sync // 40G data mode (with or without FEC)
                        : 1'b0;
                        
    assign tx_ready = tx_pma_ready & pcs_mode_rc[5];
    assign rx_ready_prefec = rx_pma_ready & pcs_mode_rc[5];
    assign rx_ready = &rx_ready_postfec;
    
    // override lock_to signals depending uppn datapath mode
    assign rx_set_locktoref = pcs_mode_rc[0] ? 4'hF : // AN mode - force LTR
                             pcs_mode_rc[1] ? 4'h0 : // LT mode - Auto LTD
                             csr_rx_set_locktoref;
    assign rx_set_locktodata = pcs_mode_rc[0] ? 4'h0 : // AN mode - force LTR
                              pcs_mode_rc[1] ? 4'h0 : // LT mode - Auto LTD
                              csr_rx_set_locktodata;

    // clock muxing / distribution
    wire [LANES-1:0] rx_coreclk;
    wire [LANES-1:0] tx_coreclk;
    
    // select master clocks
    assign clk_rx = rx_10g_clkout[2];
    assign clk_tx = tx_10g_clkout[2];

    generate 
        if (SYNTH_AN || SYNTH_LT ) 
        begin
            for (i=0; i<LANES; i=i+1) 
            begin : clock_mux
                // use glitch-free clock_mux with 1-hot enabling as LUTs may glitch
                alt_e40_gf_clock_mux #(
                   .num_clocks(2)
                ) rx_clk_mux (
                   .clk         ({rx_10g_clkout[2], rx_10g_clk33out[i]}),
                   .clk_select  ({data_mux_sel[1], ~data_mux_sel[1]}),
                   .clk_out     (rx_10g_coreclkin[i])
                );
            end
            // use glitch-free clock_mux with 1-hot enabling as LUTs may glitch
            alt_e40_gf_clock_mux #(
               .num_clocks(2)
            ) tx_clk_mux (
               .clk         ({tx_10g_clkout[2], tx_10g_clk33out}),
               .clk_select  ({data_mux_sel[1], ~data_mux_sel[1]}),
               .clk_out     (tx_10g_coreclkin)
            );
        end else begin
            assign rx_10g_coreclkin = {LANES{rx_10g_clkout[2]}};
            assign tx_10g_coreclkin = tx_10g_clkout[2];
        end
    endgenerate    
    
    //****************************************************************************
    // Instantiate the CSR modules and the memory map logic
    // no syncronizer on reset input
    //****************************************************************************
    wire  waitrequest;  
    wire  common_status_write, common_status_read;
    wire  [7:0] common_status_addr;
    wire  [31:0] common_mgmt_readdata;   // read data from the common CSR 
    wire  [31:0] top_mgmt_readdata;      // read data from the SEQ/TOP CSR
        
    // KR SEQ and top-level registers 0xB0 - 0xBF
    alt_e40_csr_krtop #(
        .AN_FEC(AN_FEC),
        .SYNTH_FEC(SYNTH_FEC),
        .ERR_INDICATION(ERR_INDICATION)
    ) csr_krtop_inst (
        .clk        (clk_status        ),
        .reset      (pma_arst          ),
        .address    (status_addr_r     ),
        .read       (status_read_r     ),
        .readdata   (top_mgmt_readdata ),
        .write      (status_write_r    ),
        .writedata  (status_writedata_r),
        //status inputs to this CSR
        .seq_link_rdy    (link_ready),
        .seq_an_timeout  (seq_an_timeout),
        .seq_lt_timeout  (seq_lt_timeout),
        .pcs_mode_rc     (pcs_mode_rc),
        .fec_block_lock  (fec_block_lock),
        // read/write control outputs
        .csr_reset_seq  (csr_seq_restart),
        .dis_an_timer   (dis_an_timer),
        .dis_lf_timer   (dis_lf_timer),
        .force_mode     (force_mode),
        .fec_enable     (fec_enable),
        .fec_request    (fec_request),
        .fec_err_ind    (fec_err_ind),
        .force_fec      (force_fec),
        .fail_lt_if_ber (fail_lt_if_ber)
    );

    
    // generate waitrequest
    altera_wait_generate wait_gen (
        .rst            (pma_arst),
        .clk            (clk_status),
        .launch_signal  (status_read_r),
        .wait_req       (waitrequest)
    );
    
    // TODO
    // hack around waitrequest for now (current 40/100 avalon-mm is not standard compliant
    // in this respect. It will be updated to be so in the future, but this release
    // is going to follow the current behavior).
    
    always @(posedge clk_status or posedge pma_arst) begin
        if (pma_arst) begin
            status_read_r <= 0;
            status_write_r <= 0;
            status_writedata_r <= 32'b0;
            status_addr_r <= 8'b0;
        end
        else if(!waitrequest) begin
            status_read_r <= status_read;
            status_write_r <= status_write && (status_addr[15:8]==PHY_ADDR_PREFIX[9:2]);
            status_writedata_r <= status_writedata;
            status_addr_r <= status_addr[7:0];
        end
    end

    // block PHY addresses below 0x40 to make room for 40G PCS legacy memory map
    assign common_status_read = status_read_r && (status_addr_r[7:6]==PHY_ADDR_PREFIX[1:0]);
    assign common_status_write = status_write_r && (status_addr_r[7:6]==PHY_ADDR_PREFIX[1:0]);
    assign common_status_addr = (common_status_read || common_status_write) ? {2'h1, status_addr_r[5:0]} : 8'b0;
    
    // mux CSR reads together, create readdata_valid signals (again, slightly out of spec, see above)   
    assign status_readdata = 
      (status_addr_r >= 8'h80) && (status_addr_r <= 8'h8F) ? 32'b0 : //pcs_mgmt_readdata :
      (status_addr_r >= 8'h90) && (status_addr_r <= 8'hA7) ? 32'b0 : //{16'b0,gige_pcs_readdata}:
      (status_addr_r >= 8'hA8) && (status_addr_r <= 8'hAF) ? 32'b0 : //gige_pma_readdata :
      (status_addr_r >= 8'hB0) && (status_addr_r <= 8'hB1) ? top_mgmt_readdata :
      (status_addr_r >= 8'hB2) && (status_addr_r <= 8'hB4) ? fec_mgmt_readdata[31:0] :
      (status_addr_r >= 8'hB5) && (status_addr_r <= 8'hB7) ? fec_mgmt_readdata[63:32] :
      (status_addr_r >= 8'hB8) && (status_addr_r <= 8'hBA) ? fec_mgmt_readdata[95:64] :
      (status_addr_r >= 8'hBB) && (status_addr_r <= 8'hBD) ? fec_mgmt_readdata[127:96] :
      (status_addr_r >= 8'hBE) && (status_addr_r <= 8'hBF) ? 32'b0 :
      (status_addr_r >= 8'hC0) && (status_addr_r <= 8'hCF) ? an_mgmt_readdata  :
      (status_addr_r >= 8'hD0) && (status_addr_r <= 8'hEB) ? lt_mgmt_readdata  :
                                                         common_mgmt_readdata;
                                                         
    assign status_readdata_valid = ( (status_addr_r >= 8'h80) && (status_addr_r <= 8'hEB)
                                     || common_status_read ) 
                                   && status_read_r && !waitrequest;


    // Common PMA registers 0x40 - 0x7F
    alt_xcvr_csr_common #(
        .lanes  (LANES),
        .plls   (1),
        .rpc    (1)
    ) csr_com (
        .clk                              (clk_status),
        .reset                            (pma_arst),
        .address                          (common_status_addr),
        .read                             (common_status_read),
        .readdata                         (common_mgmt_readdata),
        .write                            (common_status_write),
        .writedata                        (status_writedata_r),
        // Transceiver status inputs to CSR
        .pll_locked                       (tx_pll_lock),
        .rx_is_lockedtoref                (rx_is_lockedtoref),
        .rx_is_lockedtodata               (rx_is_lockedtodata),
        .rx_signaldetect                  ({LANES{1'b0}}),
        // from reset controller
        .reset_controller_tx_ready        (tx_pma_ready),
        .reset_controller_rx_ready        (rx_pma_ready),
        .reset_controller_pll_powerdown   (reset_controller_pll_powerdown),
        .reset_controller_tx_digitalreset (reset_controller_tx_digitalreset),
        .reset_controller_rx_analogreset  (reset_controller_rx_analogreset),
        .reset_controller_rx_digitalreset (reset_controller_rx_digitalreset),
        // Read/write control registers
        .csr_reset_tx_digital             (csr_reset_tx_digital),
        .csr_reset_rx_digital             (csr_reset_rx_digital),
        .csr_reset_all                    (csr_reset_all), // TODO: where should this go? ll phy it goes nowhere. kr it or's in with syncs and fnls
        .csr_pll_powerdown                (csr_pll_powerdown),
        .csr_tx_digitalreset              (csr_tx_digitalreset),
        .csr_rx_analogreset               (csr_rx_analogreset),
        .csr_rx_digitalreset              (csr_rx_digitalreset),
        .csr_phy_loopback_serial          (csr_phy_loopback_serial),
        .csr_rx_set_locktoref             (csr_rx_set_locktoref),
        .csr_rx_set_locktodata            (csr_rx_set_locktodata)
    );
    
    
    // Instantiate native phy
    // Default mode is low latency/data mode in case sequencer is disabled
    // Other modes are accessed via reconfig
    (* altera_attribute  = "disable_da_rule=c101" *)
    altera_xcvr_native_sv #(
        .tx_enable                       (1),
        .rx_enable                       (1),
        .enable_std                      (0),
        .enable_teng                     (1),
        .data_path_select                ("10G"),
        .channels                        (LANES),
        .bonded_mode                     ("non_bonded"),
        .data_rate                       ("10312.5 Mbps"),
        .pma_width                       (SYNTH_SEQ || SYNTH_AN || SYNTH_LT ? 40 : 64),   // 64 for data mode, 40 for AN/LT
        .tx_pma_clk_div                  (1),
        .tx_pma_txdetectrx_ctrl          (0),
        .pll_reconfig_enable             (0),
        .pll_external_enable             (0),
        .pll_data_rate                   ("10312.5 Mbps"),
        .pll_type                        (PLL_TYPE_10G),
        .pll_network_select              ("x1"),
        .plls                            (1),
        .pll_select                      (0),
        .pll_refclk_cnt                  (1),
        .pll_refclk_select               ("0"),
        .pll_refclk_freq                 (REF_CLK_FREQ_10G),
        .pll_feedback_path               ("internal"),
        .cdr_reconfig_enable             (0),
        .cdr_refclk_cnt                  (1),
        .cdr_refclk_select               (0),
        .cdr_refclk_freq                 (REF_CLK_FREQ_10G),
        .rx_ppm_detect_threshold         ("1000"),
        .rx_clkslip_enable               (0),
        .teng_protocol_hint              ("basic"),
        .teng_pcs_pma_width              (SYNTH_SEQ || SYNTH_AN || SYNTH_LT ? 40 : 64),   // 64 for data mode, 40 for AN/LT
        .teng_pld_pcs_width              (SYNTH_SEQ || SYNTH_AN || SYNTH_LT ? 66 : 64),   // 64 for data mode, 66 for AN/LT
        .teng_txfifo_mode                ("phase_comp"),
        .teng_txfifo_pempty              (2),
        .teng_rxfifo_mode                ("phase_comp"),
        .teng_rxfifo_pempty              (2),
        .teng_rxfifo_align_del           (0),
        .teng_rxfifo_control_del         (0),
        .teng_tx_frmgen_enable           (0),
        .teng_tx_sh_err                  (0),
        .teng_tx_crcgen_enable           (0),
        .teng_rx_crcchk_enable           (0),
        .teng_tx_64b66b_enable           (0),
        .teng_rx_64b66b_enable           (0),
        .teng_tx_scram_enable            (0),
        .teng_rx_descram_enable          (0),
        .teng_tx_dispgen_enable          (0),
        .teng_rx_dispchk_enable          (0),
        .teng_rx_blksync_enable          (0),
        .teng_tx_polinv_enable           (0),
        .teng_tx_bitslip_enable          (0),
        .teng_rx_polinv_enable           (0),
        .teng_rx_bitslip_enable          (SYNTH_SEQ || SYNTH_AN || SYNTH_LT)  // disabled in data mode, enabled for LT
    ) alt_e40_native_e4x10_inst (
        .pll_powerdown             ({LANES{pll_powerdown_fnl}}),
        .tx_analogreset            (tx_analogreset_fnl),
        .tx_digitalreset           (tx_digitalreset_fnl),
        .tx_pll_refclk             (pll_inclk),
        .tx_serial_data            (tx_serial),
        .pll_locked                (plls_locked),
        .rx_analogreset            (rx_analogreset_fnl),
        .rx_digitalreset           (rx_digitalreset_fnl),
        .rx_cdr_refclk             (cdr_ref_clk),
        .rx_serial_data            (rx_serial),
        .rx_set_locktodata         (rx_set_locktodata),
        .rx_set_locktoref          (rx_set_locktoref),
        .rx_is_lockedtoref         (rx_is_lockedtoref),
        .rx_is_lockedtodata        (rx_is_lockedtodata),
        .rx_seriallpbken           (csr_phy_loopback_serial),
        .tx_parallel_data          (tx_parallel_data),
        .rx_parallel_data          (rx_parallel_data),
        .tx_10g_coreclkin          ({LANES{tx_10g_coreclkin}}),
        .rx_10g_coreclkin          (rx_10g_coreclkin),
        .tx_10g_clkout             (tx_10g_clkout),
        .rx_10g_clkout             (rx_10g_clkout),
        .rx_10g_clk33out           (rx_10g_clk33out),
        .tx_10g_control            (tx_10g_control),
        .rx_10g_control            (rx_10g_control),
        .tx_10g_data_valid         ({LANES{1'b1}}),
        .rx_10g_bitslip            (rx_10g_bitslip),
        .tx_cal_busy               (tx_cal_busy),
        .rx_cal_busy               (rx_cal_busy),
        .reconfig_to_xcvr          (reconfig_to_xcvr),
        .reconfig_from_xcvr        (reconfig_from_xcvr),
        
        // UNUSED/ TIED OFF PORTS    
        .tx_pma_clkout             (),
        .tx_pma_pclk               (),
        .tx_pma_parallel_data      (320'b0),
        .ext_pll_clk               (4'b0),
        .rx_pma_clkout             (),
        .rx_pma_pclk               (),
        .rx_pma_parallel_data      (),
        .rx_clkslip                (4'b0),
        .rx_clklow                 (),
        .rx_fref                   (),
        .rx_signaldetect           (),
        .rx_pma_qpipulldn          (4'b0),
        .tx_pma_qpipullup          (4'b0),
        .tx_pma_qpipulldn          (4'b0),
        .tx_pma_txdetectrx         (4'b0),
        .tx_pma_rxfound            (),
        .tx_std_coreclkin          (4'b0),
        .rx_std_coreclkin          (4'b0),
        .tx_std_clkout             (),
        .rx_std_clkout             (),
        .tx_std_pcfifo_full        (),
        .tx_std_pcfifo_empty       (),
        .rx_std_pcfifo_full        (),
        .rx_std_pcfifo_empty       (),
        .rx_std_byteorder_ena      (4'b0),
        .rx_std_byteorder_flag     (),
        .rx_std_rmfifo_full        (),
        .rx_std_rmfifo_empty       (),
        .rx_std_wa_patternalign    (4'b0),
        .rx_std_wa_a1a2size        (4'b0),
        .tx_std_bitslipboundarysel (20'b0),
        .rx_std_bitslipboundarysel (),
        .rx_std_bitslip            (4'b0),
        .rx_std_runlength_err      (),
        .rx_std_bitrev_ena         (4'b0),
        .rx_std_byterev_ena        (4'b0),
        .tx_std_polinv             (4'b0),
        .rx_std_polinv             (4'b0),
        .tx_std_elecidle           (4'b0),
        .rx_std_signaldetect       (),
        .rx_std_prbs_err           (),
        .rx_std_prbs_done          (),
        .tx_10g_fifo_full          (),
        .tx_10g_fifo_pfull         (),
        .tx_10g_fifo_empty         (),
        .tx_10g_fifo_pempty        (),
        .tx_10g_fifo_del           (),
        .tx_10g_fifo_insert        (),
        .rx_10g_fifo_rd_en         (4'b0),
        .rx_10g_data_valid         (),
        .rx_10g_fifo_full          (),
        .rx_10g_fifo_pfull         (),
        .rx_10g_fifo_empty         (),
        .rx_10g_fifo_pempty        (),
        .rx_10g_fifo_del           (),
        .rx_10g_fifo_insert        (),
        .rx_10g_fifo_align_val     (),
        .rx_10g_fifo_align_clr     (4'b0),
        .rx_10g_fifo_align_en      (4'b0),
        .tx_10g_frame              (),
        .tx_10g_frame_diag_status  (8'b0),
        .tx_10g_frame_burst_en     (4'b0),
        .rx_10g_frame              (),
        .rx_10g_frame_lock         (),
        .rx_10g_frame_mfrm_err     (),
        .rx_10g_frame_sync_err     (),
        .rx_10g_frame_skip_ins     (),
        .rx_10g_frame_pyld_ins     (),
        .rx_10g_frame_skip_err     (),
        .rx_10g_frame_diag_err     (),
        .rx_10g_frame_diag_status  (),
        .rx_10g_crc32_err          (),
        .rx_10g_descram_err        (),
        .rx_10g_blk_lock           (),
        .rx_10g_blk_sh_err         (),
        .tx_10g_bitslip            (28'b0),
        .rx_10g_highber            (),
        .rx_10g_highber_clr_cnt    (4'b0),
        .rx_10g_clr_errblk_count   (4'b0),
        .rx_10g_prbs_err           (),
        .rx_10g_prbs_done          (),
        .rx_10g_prbs_err_clr       (4'b0)
    );
    
    assign tx_parallel_data_66_postnav = tx_parallel_data_66;
    
    assign rx_parallel_data_66 = rx_parallel_data_66_prenav;
    
    
    localparam SKEW = 59; // bits to skew the TX's per lane pair
    generate
        if (FAKE_TX_SKEW) begin
            // synthesis translate off
            for (i=0; i<LANES; i=i+1) begin : foo
                wire [65:0] tmp_in = tx_parallel_data_66_postnav[(i+1)*66-1:i*66];
                reg [65+LANES*SKEW:0] history = 0;
                always @(posedge tx_10g_coreclkin) begin
                    history <= pcs_mode_rc[5] ? (history >> 64) : (history >> 66);
                    if(pcs_mode_rc[5]) begin
                        history[65+LANES*SKEW:2+LANES*SKEW] <= tmp_in[65:2];
                    end else begin
                        history[65+LANES*SKEW:LANES*SKEW] <= tmp_in;
                    end
                end
                wire [65:0] tmp_out = history[SKEW*i+65:SKEW*i];
                assign tx_parallel_data_66_r[(i+1)*66-1:i*66] = tmp_out;    
            end
            // synthesis translate on
        end
        else begin
            assign tx_parallel_data_66_r = tx_parallel_data_66_postnav;
        end
    endgenerate


endmodule  //alt_e40_pma_sv_kr4


//****************************************************************************
//****************************************************************************
// Glitch-Free Clock Mux module
// from Chapter 11 of Recommended HDL Coding Styles document
//  http://www.altera.com/literature/hb/qts/qts_qii51007.pdf
// See Figure 11-3 for circuit diagram
// code taken directly from Example 11-48
//****************************************************************************

  // Apply embedded false path timing constraint to first flop
  (* altera_attribute  = "-name SDC_STATEMENT \"set_false_path -to [get_registers {*gf_clock_mux*ena_r0*}]\"" *)
module alt_e40_gf_clock_mux (clk, clk_select, clk_out);
  parameter num_clocks = 2;

  input [num_clocks-1:0] clk;
  input [num_clocks-1:0] clk_select; // one hot
  (* altera_attribute  = "disable_da_rule=c101" *)
  output clk_out;

  genvar i;
  reg  [num_clocks-1:0] ena_r0;
  reg  [num_clocks-1:0] ena_r1;
  reg  [num_clocks-1:0] ena_r2;
  wire [num_clocks-1:0] qualified_sel;

  // A look-up-table (LUT) can glitch when multiple inputs
  // change simultaneously. Use the keep attribute to
  // insert a hard logic cell buffer and prevent
  // the unrelated clocks from appearing on the same LUT.

  wire [num_clocks-1:0] gated_clks /* synthesis keep */;

initial begin
  ena_r0 = 0;
  ena_r1 = 0;
  ena_r2 = 0;
end

  generate
    for (i=0; i<num_clocks; i=i+1) begin : lp0
      wire [num_clocks-1:0] tmp_mask;

      //assign tmp_mask = {num_clocks{1'b1}} ^ (1 << i);
      assign tmp_mask = {num_clocks{1'b1}} ^ ({{(num_clocks-1){1'b0}},1'b1} << i);
      assign qualified_sel[i] = clk_select[i] & (~|(ena_r2 & tmp_mask));

      always @(posedge clk[i]) begin
        ena_r0[i] <= qualified_sel[i];
        ena_r1[i] <= ena_r0[i];
      end // always

      always @(negedge clk[i]) ena_r2[i] <= ena_r1[i];

      assign gated_clks[i] = clk[i] & ena_r2[i];
    end // for i=
  endgenerate

// These will not exhibit simultaneous toggle by construction
  assign clk_out = |gated_clks;
endmodule  // alt_e40_gf_clock_mux
