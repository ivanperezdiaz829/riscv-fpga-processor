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

module alt_e40_kr4_lane #(
    parameter SYNTH_LT      = 1,            // Synthesize/include the LT logic
    parameter SYNTH_FEC     = 1,            // Synthesize/include FEC blocks
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
    parameter PRBS_SEED     = 31'h1,        // PRBS 31/9 pattern seed
    parameter LT_SEED       = 11'h2be,      // PRBS11 seed for training pattern
    parameter REG_OFFS      = 0,            // register address offset for feccsr
    parameter FEC_USE_M20K  = 0,            // Optimize FEC memory for M20K
    parameter OPTIONAL_RXEQ = 0             //  Enable RX Equalization through link training
)(
    input lt_reset_tx, 
    input lt_reset_rx,
    input fecgb_reset_tx,
    input fecgb_reset_rx,
    
    input rx_ready,
    output rx_ready_out,
    output fec_block_lock,
    
    // krfec csr interface
    input feccsr_clk,
    input feccsr_reset,
    input [7:0] feccsr_address,
    input feccsr_read,
    output [31:0] feccsr_readdata,
    input feccsr_write,
    input[31:0] feccsr_writedata,
    
    input r_rx_err_mark,

    // 66 bit data words on clk_tx (output 64 in data mode)
    input               clk_tx,      // tx parallel data clock
    input  [65:0]       tx_datain,
    output  [65:0]      tx_dataout,
    input  [1:0]        err_inject,  // rising edge injects one bit error on tx data (before fec if enabled)
    output              din_ack,     // tx data accept
    input               din_valid,   // tx data valid
    
    // 66 bit data words on clk_rx (input 64 in data mode)
    input               clk_rx,      // rx parallel data clock
    input  [65:0]       rx_datain, 
    output [65:0]       rx_dataout,
    output              dout_valid,  // rx data valid
    input               rx_bitslip,  // slip to frame for word lock
    
    // prbs TX
    input        prbs_tx_enable,
    input        prbs_tx_9_31n,
    input        prbs_error_inject,

    //PRBS RX
    input              prbs_rx_enable,
    input              prbs_rx_9_31n,
    output reg         prbs_error,
    
    // LT interface
    input             clk33_tx,
    input             clk33_rx,
    input             data_mux_sel,    // 1=data, 0=LT/AN
    input             enable_fec,      
    input             lt_enable,       // enable LT
    input             lt_restart,      // re-start the LT process
    output            pma_rx_bitslip,      // sig the PMA to slip the datastream
    // outputs to CSR for status
    output            training,        // Training in progress
    output            training_fail,   // Training timed-out
    output            training_error,  // Training Error (ber_max)
    output            train_lock_err,  // Frame Lock Error
    output            rx_trained_sts,  // rx_trained status to CSR
    output [7:0]      lcl_txi_update,  // Local coef update bits to TX
    output            lcl_tx_upd_new,  // Local coef update new
    output [6:0]      lcl_txi_status,  // Local status bits to transmit
    output            lcl_tx_stat_new, // Local coef status new
    output [7:0]      lp_rxi_update,   // Remote coef update bits
    output            lp_rx_upd_new,   // Remote coef update new
    output [6:0]      lp_rxi_status,   // Remote/LP status bits
    output            nolock_rxeq,     // no-frame-lock detected during RXEQ
    output            fail_ctle,       // CTLE fine-tuning failure occurred
    output [1:0]      last_dfe_mode,   // Last dfe_mode setting sent to reconfig bundle
    output [3:0]      last_ctle_rc,    // Last ctle_rc setting sent to reconfig bundle
    output [1:0]      last_ctle_mode,  // Last ctle_mode setting sent to reconfig bundle
    output            ber_zero,        // BER count is zero
     // register bits for setting of operating mode
    input [9:0]       sim_ber_t,       // Time(frames) cnt when ber_time=0
    input [9:0]       ber_time,        // Time(K-frames) to cnt BER Errors
    input [9:0]       ber_ext,         // Extend(M-frames) Time to cnt BER
    input             dis_max_wait_tmr,// disable the max_wait_timer
    input             dis_init_pma,    // disable initialize PMA on timeout
    input             quick_mode,     // Only chk at init & preset EQ state
    input             pass_one,       // look beyond first min in BER count
    input [3:0]       main_step_cnt,  // Number of EQ steps per main update
    input [3:0]       prpo_step_cnt,  // EQ steps for pre/post tap update
    input [2:0]       equal_cnt,      // Number to make BER counts Equal
    input             ovrd_lp_coef,   // Override LP TX update enable
    input [7:0]       lp_txo_update,  // Override LP TX update bits
    input             lp_tx_upd_new,  // Override LP TX update new
    input [2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+3:0]  param_ovrd,
    input             ovrd_coef_rx,   // Override local RX update enable
    input [7:0]       lcl_rxo_update, // Override local RX update bits
    input             ovrd_rx_new,    // Override local RX update new
    input [3:0]       lt_inj_err,     // inject errors into the TX data
    input [2:0]       rx_ctle_mode,   // CTLE Training mode
    input [2:0]       rx_dfe_mode,    // DFE Training mode
    input             max_mode,       // Enable max_mode tx training
    input             fixed_mode,     // Always set taps as if max_mode & ber max
    input [2:0]       max_post_step,  // Max # steps for Post tap in max_mode
    input [1:0]       ctle_depth,     // Adjust "best" result from fine-grained tuning
    input [1:0]       dfe_extra,      // Number of extra dfe trainings to try at end
    input             only_inc_main,  // Search upwards from main init
    input [2:0]       ctle_bias,      // Amount to bias fine-grained CTLE up
    input             dec_post,       // sets post at minimum in case of a tie (except maxber)
    input             dec_post_more,  // Continue decrementing post tap past errors to bermax
    input             ctle_pass_ber,  // Continue incrementing CTLE past bermax
    input             use_full_time,  // Use the entire LT time instead of ending when local is finished.
     // for the reconfig Interface
    input              rc_busy,       // reconfig is busy
    output             lt_start_rc,   // start the TX EQ reconfig
    output             dfe_start_rc,  // start DFE reconfig
    output [1:0]       dfe_mode,      // DFE mode 00=disabled, 01=triggered, 10=continuous
    output             ctle_start_rc, // start CTLE reconfig
    output [3:0]       ctle_rc,       // CTLE manual setting
    output [1:0]       ctle_mode,     // CTLE mode 00=manual, 01=one-time, 10=continuous
    output [MAINTAPWIDTH-1:0] main_rc, // main tap value for reconfig
    output [POSTTAPWIDTH-1:0] post_rc, // post tap value for reconfig
    output [PRETAPWIDTH-1:0]  pre_rc,  // pre tap value for reconfig
    output [2:0]       tap_to_upd,     // specific TX EQ tap to update
                                         // bit-2 = main, bit-1 = post, ...
    input             rxeq_done,      // Local RX Equalization is finished
       // Daisy Chain Mode input for local TX update/status
    input          dmi_mode_en,        // Enable Daisy Chain mode
    input          dmi_frame_lock,     // SM has lock to training frames
    input          dmi_rmt_rx_ready,   // remote RX ready = status[15]
    input [5:0]    dmi_lcl_coefl,      // local update low bits[5:0]
    input [1:0]    dmi_lcl_coefh,      // local update high bits[13:12]
    input          dmi_lcl_upd_new,    // local update has changed
    input          dmi_rx_trained,     // SM is finished local training
       // Daisy Chain Mode outputs of remote update/status
    output          dmo_frame_lock,     // SM has lock to training frames
    output          dmo_rmt_rx_ready,   // remote RX ready = status[15]
    output [5:0]    dmo_lcl_coefl,      // local update low bits[5:0]
    output [1:0]    dmo_lcl_coefh,      // local update high bits[13:12]
    output          dmo_lcl_upd_new,    // local update has changed
    output          dmo_rx_trained,     // SM is finished local training
      // uP Mode inputs for remote EQ Optimization
    input             upi_mode_en,    // Enable uP mode
    input [1:0]       upi_adj,        // select the active tap
    input             upi_inc,        // send the increment command 
    input             upi_dec,        // send the decrement command 
    input             upi_pre,        // send the preset command 
    input             upi_init,       // send the initialize command
    input             upi_st_bert,    // start the BER timer
    input             upi_train_err,  // Training Error indication
    input             upi_lock_err,   // Training frame lock Error
    input             upi_rx_trained, // local RX is Trained
      // uP Mode outputs for remote EQ Optimization
    output            upo_enable,     // Enable uP = ~re_start & en & lock 
    output            upo_frame_lock, // Receiver has Training frame lock
    output            upo_cm_done,    // Master SM done with handshake 
    output            upo_bert_done,  // BER Timer at max count 
    output [BERWIDTH-1:0] upo_ber_cnt, // BER counter value 
    output            upo_ber_max,    // BER counter roll-over
    output            upo_coef_max    // Remote Coefficients at max/min

);

    localparam  SYNC_LTRX_CONSTRAINT = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|*lt_rx_data:RX_DATAPATH|lcl_coef*}] -to [get_registers {*LINK_TRAIN|*lt_lcl_coef:LCL_COEF|*}]\""};
    localparam  SYNC_LTTX_CONSTRAINT = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|*lt_rmt_txeq:RMT_TX_EQ|rmt_cmd*}]   -to [get_registers {*LINK_TRAIN|*lt_tx_data:TX_DATAPATH|*}]\""};
    localparam  SYNC_LT_CONSTRAINT   = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|*lt_rmt_txeq:RMT_TX_EQ|*lt_coef_mstr:COEFF_MASTER|*cf_mstr_sm.CMSTR_HOLD}] -to [get_registers {*LINK_TRAIN|*lt_tx_data:TX_DATAPATH|*}]\""};

    localparam  SDC_LT_CONSTRAINTS = {SYNC_LTRX_CONSTRAINT,";",SYNC_LTTX_CONSTRAINT,";",SYNC_LT_CONSTRAINT};

    wire [63:0] tx_dataout64, tx_dataout64_prbs;

    // the prbs logic is copied from the 40g rx_nav_region
    reg prbs_rst_rx = 1'b0;
    reg prbs_9_31n_rx = 1'b0 /* synthesis preserve */;
    wire prbs_lane_error;

    always @(posedge clk_rx) begin
        prbs_rst_rx <= ~prbs_rx_enable;
        prbs_9_31n_rx <= prbs_rx_9_31n;
    end

    alt_e40_prbs_rx #(
        .WIDTH(64)
    ) prbs_rx (
        .arst(prbs_rst_rx),
        .clk_serial(clk_rx),
        .prbs_9_31n(prbs_9_31n_rx),
        .prbs_din(rx_datain[65:2]),
        .prbs_error(prbs_lane_error)
    ); 

    always @(posedge clk_rx or posedge prbs_rst_rx) begin
        if (prbs_rst_rx) begin
            prbs_error <= 0;
        end else begin
            prbs_error <= prbs_rx_enable & prbs_lane_error;
        end
    end

    reg prbs_rst_tx = 1'b0;
    reg prbs_9_31n_tx = 1'b0 /* synthesis preserve */;
    wire [63:0] prbs_dout;

    always @(posedge clk_tx) begin
        prbs_rst_tx <= ~prbs_tx_enable;
        prbs_9_31n_tx <= prbs_tx_9_31n;
    end

    alt_e40_prbs_tx #(
        .prbs_default_seed(PRBS_SEED),
        .WIDTH(64)
    ) prbs_tx (
        .arst(prbs_rst_tx), 
        .clk_serial(clk_tx), 
        .prbs_9_31n(prbs_9_31n_tx), 
        .prbs_error_inject(prbs_error_inject), 
        .prbs_dout(prbs_dout)
    );

    // bit error injection on the low 2 bits
    reg [1:0] err_inject_r = 2'b00;
    reg [1:0] last_err_inject = 2'b00;

    always @(posedge clk_tx) begin
        last_err_inject <= err_inject;
        err_inject_r <= (err_inject & ~last_err_inject);
    end

    assign tx_dataout64_prbs = (prbs_tx_enable ? prbs_dout : tx_dataout64) ^ err_inject_r[1:0];

    wire [65:0] rx_dataout_gb;
    wire [63:0] tx_dataout64_gb;
    wire dout_valid_gb, din_ack_gb;

    // non-FEC gearboxes
    alt_e40_gearbox_64_66 gb_rx (
        .arst(fecgb_reset_rx),
        .clk(clk_rx),
        .slip_to_frame(rx_bitslip), 
        .din(rx_datain[65:2]),
        .dout(rx_dataout_gb),
        .dout_valid(dout_valid_gb)
    );

    alt_e40_gearbox_66_64 gb_tx (
        .arst(fecgb_reset_tx),
        .clk(clk_tx),
        .sclr(!din_valid),
        .din(tx_datain),     // lsbit first
        .din_ack(din_ack_gb),  // 3 cycles early
        .dout(tx_dataout64_gb)
    );
    
    //****************************************************************************
    // Instantiate the FEC module
    //****************************************************************************
    generate
        if (SYNTH_FEC) begin: FEC_GEN
        
            wire [63:0] rx_data_out_fec;
            wire [63:0] tx_dataout64_fec;
            wire [9:0] rx_control_out_fec;
            wire dout_valid_fec, din_ack_fec, tx_data_valid_in;
            wire fec_err_ins,fec_err_ins_sync;
            wire rx_ready_fec;
            
            wire [10*8-1:0] avmm_user_dataout;
            wire [31:0] blkcnt_corr, blkcnt_uncorr;
            //wire [5:0] wd_alignment;
            
            wire r_rx_sigok_en;//  -- normally 1'b1 unless LPBK_EN
            wire r_rx_blksync_cor_en;// can only be CORRECT(1'b1) if BASIC_MODE and ENGINEERING_MODE
            wire r_rx_fast_search_en;// can only be SINGLE(1'b0) if ENGINEERING_MODE
            wire r_rx_dv_start;// normally WITH_BLKLOCK (1'b1)
            wire [1:0] r_rx_clr_ctrl;//[UNCORR,CORR]
            wire [3:0] r_tx_burst_err_len;//default BURST_ERR_LEN1(4'd0)
            wire r_tx_burst_err;// default BURST_ERR_DIS(1'b0)
            wire r_tx_trans_err;// TRANS_ERR_DIS(1'b0) unless ENGINEERING_MODE
            wire r_tx_enc_query;// ENC_QUERY_DIS(1'b0) unless 1588 mode 
            
            wire [9:0] write_en, write_en_ack;
            
            alt_e40_csr_krfec #(
                .REG_OFFS(REG_OFFS)
            ) csr_krfec_inst (
                // user data (avalon-MM formatted) 
                .clk(feccsr_clk),
                .reset(feccsr_reset),
                .address(feccsr_address),
                .read(feccsr_read),
                .readdata(feccsr_readdata),
                .write(feccsr_write),
                .writedata(feccsr_writedata),
                // FEC status sync
                .write_en(write_en),
                .write_en_ack(write_en_ack),
                // FEC input/outputs
                .fec_tx_trans_err(r_tx_trans_err),
                .fec_tx_burst_err(r_tx_burst_err),
                .fec_tx_burst_err_len(r_tx_burst_err_len),
                .fec_tx_enc_query(r_tx_enc_query),
                .fec_rx_signok_en(r_rx_sigok_en),
                .fec_rx_fast_search_en(r_rx_fast_search_en),
                .fec_rx_blksync_cor_en(r_rx_blksync_cor_en),
                .fec_rx_dv_start(r_rx_dv_start),
                .fec_err_ins(fec_err_ins),
                .fec_corr_blks(blkcnt_corr),
                .fec_uncr_blks(blkcnt_uncorr),
                // read/write control outputs
                .clr_corr_blks(r_rx_clr_ctrl[0]),
                .clr_uncr_blks(r_rx_clr_ctrl[1])
            );
            
            alt_e40_krfec_top_wrapper #(
                .USE_M20K  (FEC_USE_M20K)
            ) fec (      
                // Reset
                .rx_fec_reset(fecgb_reset_rx),
                .tx_fec_reset(fecgb_reset_tx),
               //   RX
                .rx_krfec_clk(clk_rx),
                .rx_data_in(rx_datain[65:2]),
                .clear_counters(|r_rx_clr_ctrl),
                .rx_signal_ok_in(rx_ready & enable_fec),
                .rx_data_valid_out(dout_valid_fec),
                .rx_data_out(rx_data_out_fec),
                .rx_control_out(rx_control_out_fec),
                .rx_signal_ok_out(rx_ready_fec),
                .rx_block_lock(),
               //   TX
                .tx_data_valid_in(tx_data_valid_in & enable_fec),
                .tx_krfec_clk(clk_tx),
                .tx_data_in(tx_datain[65:2]),
                .tx_control_in(tx_datain[1:0]),
                .tx_data_out(tx_dataout64_fec),
               //   DPRIO INPUTS
                .fec_rx_signok_en(r_rx_sigok_en),
                .fec_err_ind(r_rx_err_mark),
                .fec_rx_fast_search_en(r_rx_fast_search_en),
                .fec_rx_blksync_cor_en(r_rx_blksync_cor_en),
                .fec_rx_dv_start(r_rx_dv_start),
                .clr_corr_blks(r_rx_clr_ctrl[0]),
                .clr_uncr_blks(r_rx_clr_ctrl[1]),
                .fec_tx_burst_err_len(r_tx_burst_err_len),
                .fec_tx_trans_err(r_tx_trans_err),
                .fec_tx_burst_err(r_tx_burst_err),
                .fec_tx_enc_query(r_tx_enc_query),
                .fec_tx_err_ins(fec_err_ins),
               //   DPRIO OUTPUTS
                .fec_corr_blks(blkcnt_corr),
                .fec_uncr_blks(blkcnt_uncorr),
                //   STATUS
                .write_en(write_en),
                .write_en_ack(write_en_ack)
            );
                    
            assign fec_block_lock = rx_control_out_fec[9];
            
            assign rx_ready_out = enable_fec ? rx_ready_fec : rx_ready;
            assign rx_dataout = enable_fec ? {rx_data_out_fec, rx_control_out_fec[1:0]} : rx_dataout_gb;
            assign dout_valid = enable_fec ? dout_valid_fec : dout_valid_gb;
            assign din_ack = enable_fec ? din_ack_fec : din_ack_gb;
            assign tx_dataout64 = enable_fec ? tx_dataout64_fec : tx_dataout64_gb;
            
            alt_e40_fec_valid_gen fec_valid_gen (
                .arst(fecgb_reset_tx),
                .clk(clk_tx),
                .sclr(!din_valid || !enable_fec),
                .tx_data_valid_in(tx_data_valid_in),
                .din_ack(din_ack_fec)  // 3 cycles early
            );
           
        end  // if synth_fec
        else begin: NO_FEC_GEN
            assign rx_ready_out = rx_ready;
            assign rx_dataout = rx_dataout_gb;
            assign dout_valid = dout_valid_gb;
            assign din_ack = din_ack_gb;
            assign tx_dataout64 = tx_dataout64_gb;
            assign fec_block_lock = 1'b0;
            
            assign feccsr_readdata = 32'b0;
        end  // else synth_fec
    endgenerate


    //****************************************************************************
    // Instantiate the LT module
    //****************************************************************************
    generate
        if (SYNTH_LT) begin: LT_GEN
            wire tx_lt_reset;
            wire rx_lt_reset;
            wire [65:0] lt_tx_data;
            
            // Apply embedded false path timing constraints for LT
            (* altera_attribute = SDC_LT_CONSTRAINTS *)
            alt_e40_lt_top #(
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
                .PRBS_SEED (LT_SEED),
                .OPTIONAL_RXEQ (OPTIONAL_RXEQ)
            ) LINK_TRAIN (
                .tx_rstn      (~tx_lt_reset),
                .tx_clk       (clk33_tx),
                .rx_rstn      (~rx_lt_reset),
                .rx_clk       (clk33_rx),
                .lt_enable    (lt_enable & (data_mux_sel == 1'b0)),
                .lt_restart   (lt_restart),
                // data ports
                .rx_data_in  (rx_datain),
                .tx_data_out (lt_tx_data),
                .rx_bitslip  (pma_rx_bitslip),
                // outputs to CSR for status
                .training        (training),
                .training_fail   (training_fail),
                .training_error  (training_error),
                .train_lock_err  (train_lock_err),
                .rx_trained_sts  (rx_trained_sts),
                .lcl_txi_update  (lcl_txi_update),
                .lcl_tx_upd_new  (lcl_tx_upd_new),
                .lcl_txi_status  (lcl_txi_status),
                .lcl_tx_stat_new (lcl_tx_stat_new),
                .lp_rxi_update   (lp_rxi_update),
                .lp_rx_upd_new   (lp_rx_upd_new),
                .lp_rxi_status   (lp_rxi_status),
                .nolock_rxeq     (nolock_rxeq),
                .fail_ctle       (fail_ctle),
                .last_dfe_mode   (last_dfe_mode),
                .last_ctle_rc    (last_ctle_rc),
                .last_ctle_mode  (last_ctle_mode),
                .ber_zero        (ber_zero),
                // register bits for setting of operating mode
                .sim_ber_t      (sim_ber_t),
                .ber_time       (ber_time),
                .ber_ext        (ber_ext),
                .dis_max_wait_tmr (dis_max_wait_tmr),
                .dis_init_pma   (dis_init_pma),
                .quick_mode     (quick_mode),
                .pass_one       (pass_one),
                .main_step_cnt  (main_step_cnt),
                .prpo_step_cnt  (prpo_step_cnt),
                .equal_cnt      (equal_cnt),
                .ovrd_coef_rx   (ovrd_coef_rx),
                .param_ovrd     (param_ovrd),
                .lcl_rxo_update (lcl_rxo_update),
                .ovrd_rx_new    (ovrd_rx_new),
                .ovrd_lp_coef   (ovrd_lp_coef),
                .lp_txo_update  (lp_txo_update),
                .lp_tx_upd_new  (lp_tx_upd_new),
                .inj_err        (lt_inj_err),
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
                // for the reconfig Interface
                .rc_busy     (rc_busy),
                .start_rc    (lt_start_rc),
                .dfe_start_rc(dfe_start_rc),
                .dfe_mode    (dfe_mode),
                .ctle_start_rc(ctle_start_rc),
                .ctle_rc     (ctle_rc),
                .ctle_mode   (ctle_mode),
                .main_rc     (main_rc),
                .post_rc     (post_rc),
                .pre_rc      (pre_rc),
                .tap_to_upd  (tap_to_upd),
                .rxeq_done   (rxeq_done),
                // Daisy Chain Mode input for local TX update/status
                .dmi_mode_en      (dmi_mode_en),
                .dmi_frame_lock   (dmi_frame_lock),
                .dmi_rmt_rx_ready (dmi_rmt_rx_ready),
                .dmi_lcl_coefl    (dmi_lcl_coefl),
                .dmi_lcl_coefh    (dmi_lcl_coefh),
                .dmi_lcl_upd_new  (dmi_lcl_upd_new),
                .dmi_rx_trained   (dmi_rx_trained),
                // Daisy Chain Mode outputs of remote update/status
                .dmo_frame_lock   (dmo_frame_lock),
                .dmo_rmt_rx_ready (dmo_rmt_rx_ready),
                .dmo_lcl_coefl    (dmo_lcl_coefl),
                .dmo_lcl_coefh    (dmo_lcl_coefh),
                .dmo_lcl_upd_new  (dmo_lcl_upd_new),
                .dmo_rx_trained   (dmo_rx_trained),
                // uP Mode inputs for remote EQ Optimization
                .upi_mode_en     (upi_mode_en),
                .upi_adj         (upi_adj),
                .upi_inc         (upi_inc),
                .upi_dec         (upi_dec),
                .upi_pre         (upi_pre),
                .upi_init        (upi_init),
                .upi_st_bert     (upi_st_bert),
                .upi_train_err   (upi_train_err),
                .upi_lock_err    (upi_lock_err), 
                .upi_rx_trained  (upi_rx_trained),
                // uP Mode outputs for remote EQ Optimization
                .upo_enable     (upo_enable),
                .upo_frame_lock (upo_frame_lock),
                .upo_cm_done    (upo_cm_done),
                .upo_bert_done  (upo_bert_done),
                .upo_ber_cnt    (upo_ber_cnt),
                .upo_ber_max    (upo_ber_max),
                .upo_coef_max   (upo_coef_max)
            );
           
            alt_xcvr_resync #(
                .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
                .WIDTH            (1),  // Number of bits to resync
                .INIT_VALUE       (1)
            ) tx_resync_reset (
                .clk    (clk33_tx),
                .reset  (lt_reset_tx),
                .d      (1'b0),
                .q      (tx_lt_reset)
            );

            alt_xcvr_resync #(
                .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
                .WIDTH            (1),  // Number of bits to resync
                .INIT_VALUE       (1)
            ) rx_resync_reset (
                .clk    (clk33_rx),
                .reset  (lt_reset_rx),
                .d      (1'b0),
                .q      (rx_lt_reset)
            );
            
            assign tx_dataout = data_mux_sel ? {tx_dataout64_prbs, 2'b0} :
                                               lt_tx_data;
           
        end  // if synth_lt
        else begin: NO_LT_GEN   // need to drive outputs if no LT module
            assign pma_rx_bitslip   = 1'b0;
            assign training         = 1'b0;
            assign training_fail    = 1'b0;
            assign training_error   = 1'b0;
            assign train_lock_err   = 1'b0;
            assign rx_trained_sts   = 1'b0;
            assign lcl_txi_update   = 8'd0;
            assign lcl_tx_upd_new   = 1'b0;
            assign lcl_txi_status   = 7'd0;
            assign lcl_tx_stat_new  = 1'b0;
            assign lp_rxi_update    = 8'd0;
            assign lp_rx_upd_new    = 1'b0;
            assign lp_rxi_status    = 7'd0;
            assign lt_start_rc      = 1'b0;
            assign main_rc          = {MAINTAPWIDTH{1'b0}};
            assign post_rc          = {POSTTAPWIDTH{1'b0}};
            assign pre_rc           = {PRETAPWIDTH{1'b0}};
            assign tap_to_upd       = 3'd0;
            assign dmo_frame_lock   = 1'b0;
            assign dmo_rmt_rx_ready = 1'b0;
            assign dmo_lcl_coefl    = 6'b0;
            assign dmo_lcl_coefh    = 2'b0;
            assign dmo_lcl_upd_new  = 1'b0;
            assign dmo_rx_trained   = 1'b0;
            assign upo_enable     = 1'b0;
            assign upo_frame_lock = 1'b0;
            assign upo_cm_done    = 1'b0;
            assign upo_bert_done  = 1'b0;
            assign upo_ber_cnt    = {BERWIDTH{1'b0}};
            assign upo_ber_max    = 1'b0;
            assign upo_coef_max   = 1'b0;
            assign dfe_start_rc   = 1'b0;
            assign dfe_mode       = 2'b0;
            assign ctle_start_rc  = 1'b0;
            assign ctle_rc        = 4'b0;
            assign ctle_mode      = 2'b0;
            assign ber_zero       = 1'b1;
            assign tx_dataout = {tx_dataout64_prbs, 2'b0};
        end  // else synth_lt
    endgenerate


endmodule  //alt_e40_kr4_lane
