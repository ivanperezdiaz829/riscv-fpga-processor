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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


//****************************************************************************
// Control & status registers for the KR PHY IP Link Training
// should start at address 0xC0 = ADDR_KRLT_BASE
//****************************************************************************
`timescale 1 ps / 1 ps

module csr_krlt #(
  parameter MAINTAPWIDTH  = 6,  // Width of Main Tap.  If set >7, need RTL fix
  parameter POSTTAPWIDTH  = 5,  // Width of the Post Tap control
  parameter PRETAPWIDTH   = 4   // Width of the Pre Tap control
  )(
  // user data (avalon-MM formatted) 
  input  wire        clk,
  input  wire        reset,
  input  wire [7:0]  address,
  input  wire        read,
  output reg  [31:0] readdata,
  input  wire        write,
  input  wire [31:0] writedata,
  //status inputs to this CSR
  input  wire        rx_trained,
  input  wire        lt_frame_lock,
  input  wire        training,
  input  wire        training_fail,
  input  wire        training_error,
  input  wire        train_lock_err,
  input  wire [7:0]  lcl_txi_update,
  input  wire        lcl_tx_upd_new,
  input  wire [6:0]  lcl_txi_status,
  input  wire        lcl_tx_stat_new,
  input  wire [7:0]  lp_rxi_update,
  input  wire        lp_rx_upd_new,
  input  wire [6:0]  lp_rxi_status,
  input  wire        lp_rx_stat_new,
  input  wire        nolock_rxeq,
  input  wire        fail_ctle,
  input  wire [1:0]  last_dfe_mode,
  input  wire [3:0]  last_ctle_rc,
  input  wire [1:0]  last_ctle_mode,
  input  wire [MAINTAPWIDTH-1:0] main_rc, // main tap value for reconfig
  input  wire [POSTTAPWIDTH-1:0] post_rc, // post tap value for reconfig
  input  wire [PRETAPWIDTH-1:0]  pre_rc,  // pre tap value for reconfig
  // read/write control outputs
  output reg        csr_lt_enable,
  output reg        dis_max_wait_tmr,
  output reg        dis_init_pma,
  output reg        quick_mode,
  output reg        pass_one,
  output reg [3:0]  main_step_cnt,
  output reg [3:0]  prpo_step_cnt,
  output reg [2:0]  equal_cnt,
  output reg        ovrd_lp_coef,
  output reg        ovrd_coef_rx,
  output wire [2:0] rx_ctle_mode,
  output wire [2:0] rx_dfe_mode,
  output wire       max_mode,
  output wire       fixed_mode,
  output wire [2:0] max_post_step,
  output wire [1:0] ctle_depth,
  output wire [1:0] dfe_extra,
  output wire       only_inc_main,
  output wire [2:0] ctle_bias,
  output wire       dec_post,
  output wire       dec_post_more,
  output wire       ctle_pass_ber,
  output wire       use_full_time,
  output reg        csr_reset_lt,
  output reg [9:0]  ber_time,
  output reg [9:0]  ber_k_time,
  output reg [9:0]  ber_m_time,
  output reg [7:0]  lcl_txo_update,
  output reg        lp_tx_upd_new,
  output reg [7:0]  lcl_rxo_update,
  output reg        ovrd_rx_new,
  output reg [2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+3:0]  param_ovrd,
  output reg        lt_tm_enable,
  output reg [3:0]  lt_tm_err_mode,
  output reg [3:0]  lt_tm_err_trig,
  output reg [7:0]  lt_tm_err_time,
  output reg [7:0]  lt_tm_err_cnt
);
  import csr_krtop_h::*;
//****************************************************************************
// Define Parameters 
//****************************************************************************
`ifdef ALTERA_RESERVED_QIS
  // Enable full-length timers for synthesis.
  // Usually have short timers for sim performance
  `define ALTERA_RESERVED_XCVR_FULL_KR_TIMERS
`endif // QIS 

`ifdef ALTERA_RESERVED_XCVR_FULL_KR_TIMERS
  localparam BER_TIME_DEFAULT = 30'h000_03_C00;     // HW mode, 15 K frames
  localparam TAP_OVRD_DEFAULT = 29'h00_00_00_00;    // HW mode, no tap override
`else // not FULL_KR_TIMERS
  localparam BER_TIME_DEFAULT = 30'h000_00_003;     // sim mode, 3 frames
  localparam TAP_OVRD_DEFAULT = 29'h18_00_6D_77;    // sim mode, Vmax = 55, 
`endif // FULL_KR_TIMERS                            // Vmin=45, Vpre=8

//****************************************************************************
// Instantiate the transceiver sync module to sync the LH and LL status bits
//  \p4\ip\altera_xcvr_generic\ctrl\alt_xcvr_resync.sv
//**************************************************************************** 
  wire lcl_upd_sync;          // sync the lcl_tx_upd_new to mgmt clock
  reg  lcl_upd_dly;           // delay for rising edge detect
  reg [7:0] lcl_upd_ltch;     // latch/sample the local update when valid

  wire lcl_stat_sync;         // sync the lcl_tx_stat_new to mgmt clock
  reg  lcl_stat_dly;          // delay for rising edge detect
  reg [6:0] lcl_stat_ltch;    // latch/sample the local status when valid

  wire rx_upd_sync;           // sync the lcl_tx_upd_new to mgmt clock
  reg  rx_upd_dly;            // delay for rising edge detect
  reg [7:0] lp_upd_ltch;      // latch/sample the LP RX Update when valid
  
  wire rx_stat_sync;          // sync the lp_rx_stat_new to mgmt clock
  reg  rx_stat_dly;           // delay for rising edge detect
  reg [6:0] lp_stat_ltch;     // latch/sample the LP status when valid


  alt_xcvr_resync #(
      .WIDTH       (4)  // Number of bits to resync
  ) resync_topstat (
    .clk   (clk),
    .reset (reset),
    .d     ({lcl_tx_upd_new, lcl_tx_stat_new, lp_rx_upd_new, lp_rx_stat_new}),
    .q     ({lcl_upd_sync  , lcl_stat_sync  , rx_upd_sync  , rx_stat_sync  })
  );

  // latch high/low logic for status bits
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      lcl_upd_dly  <= 1'b0;
      lcl_stat_dly <= 1'b0;
      rx_upd_dly   <= 1'b0;
      rx_stat_dly  <= 1'b0;
      lcl_upd_ltch  <= 'd0;
      lcl_stat_ltch <= 'd0;
      lp_upd_ltch   <= 'd0;
      lp_stat_ltch  <= 'd0;
    end  // if reset
    else begin
      lcl_upd_dly  <=  lcl_upd_sync;
      lcl_stat_dly <=  lcl_stat_sync;
      rx_upd_dly   <=  rx_upd_sync;
      rx_stat_dly  <=  rx_stat_sync;
      if (lcl_upd_sync  & ~lcl_upd_dly ) lcl_upd_ltch  <= lcl_txi_update;
      if (lcl_stat_sync & ~lcl_stat_dly) lcl_stat_ltch <= lcl_txi_status;
      if (rx_upd_sync   & ~rx_upd_dly)   lp_upd_ltch   <= lp_rxi_update;
      if (rx_stat_sync  & ~rx_stat_dly)  lp_stat_ltch  <= lp_rxi_status;
    end  // else
  end  // always

//****************************************************************************
// Logic to create register map, write data, and read mux
//****************************************************************************
  reg  [31:0] reg_krlt_base;    // base register
  reg  [24:0] reg_krlt_reset;   // reset register+debug bits
  reg  [29:0] reg_krlt_btime;   // BER Time register
  reg  [23:0] reg_krlt_ucoef;   // user Coefficient register  
  reg  [PRETAPWIDTH+24:0] reg_krlt_ovrdrule;  // override of device params
  reg  [31:0] reg_krlt_tmode;   // test mode register
  
  reg  [1:0] clr_rst_sc_bit;    // clear the self_clear bits in reset reg

  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      reg_krlt_base   <= 32'h8008_5111;  //Enable LT, step=1/1 eq=5 (8), ctle depth=10, ctle=000, dfe=000, max_post_step = 100
      reg_krlt_reset  <= 25'h50_0000; // ctle bias = 5
      reg_krlt_btime  <= BER_TIME_DEFAULT;
      reg_krlt_ucoef  <= 'd0;      
      reg_krlt_ovrdrule  <= TAP_OVRD_DEFAULT;
      reg_krlt_tmode  <= 'd0;
      clr_rst_sc_bit  <= 'd0;
      readdata        <= 32'd0;
    end // if reset
    else begin
      readdata       <= 32'd0;
      clr_rst_sc_bit <= {1'b0, clr_rst_sc_bit[1]};
      // clear the self_clear register bits
      if (clr_rst_sc_bit[0]) 
          {reg_krlt_reset[8],reg_krlt_reset[4],reg_krlt_reset[0]} <= 3'b000;
      // decode read & write for each supported address
      case (address)
      ADDR_KRLT_BASE: begin
        readdata[31:0] <= reg_krlt_base;
        if (write) reg_krlt_base <= writedata[31:0];
      end // base
      ADDR_KRLT_RESET: begin
        readdata[24:0] <= reg_krlt_reset;
        if (write) begin
          reg_krlt_reset <= writedata[24:0];
          clr_rst_sc_bit <= {writedata[8]|writedata[4]|writedata[0],1'b0};
        end  // if write
      end  // reset
      ADDR_KRLT_STATUS: begin
        readdata[0] <= rx_trained;
        readdata[1] <= lt_frame_lock;
        readdata[2] <= training;
        readdata[3] <= training_fail;
        readdata[4] <= training_error;
        readdata[5] <= train_lock_err;
        readdata[6] <= nolock_rxeq;
        readdata[7] <= fail_ctle;
      end  // status
      ADDR_KRLT_BERTIM: begin
        readdata[29:0] <= reg_krlt_btime;
        if (write) reg_krlt_btime <= writedata[29:0];
      end // BER time
      ADDR_KRLT_UCOEFF: begin
        readdata[7:0]   <= lcl_upd_ltch;
        readdata[14:8]  <= lcl_stat_ltch;
        readdata[23:16] <= lp_upd_ltch;
        readdata[30:24] <= lp_stat_ltch;
        if (write) reg_krlt_ucoef <= writedata[23:0];
      end // user coef
      ADDR_KRLT_TAPVAL: begin
        readdata[MAINTAPWIDTH-1:0]     <= main_rc;
        readdata[POSTTAPWIDTH-1+8:8]   <= post_rc;
        readdata[PRETAPWIDTH-1+16:16]  <= pre_rc;
        readdata[23:20] <= last_ctle_rc;
        readdata[25:24] <= last_ctle_mode;
        readdata[27:26] <= last_dfe_mode;
      end  // Tap values
      ADDR_KRLT_OVRDRULE: begin
        readdata <= reg_krlt_ovrdrule;
        if (write) reg_krlt_ovrdrule <= writedata[PRETAPWIDTH+24:0];
      end // parameter rules override
      ADDR_KRLT_TM: begin
        readdata <= reg_krlt_tmode;
        if (write) reg_krlt_tmode <= writedata;
      end // test mode
      endcase
    end // else
  end // always

//****************************************************************************
// Drive the outputs
//****************************************************************************
  assign csr_lt_enable    = reg_krlt_base[0];
  assign dis_max_wait_tmr = reg_krlt_base[1];
  assign quick_mode       = reg_krlt_base[2];
  assign pass_one         = reg_krlt_base[3];
  assign main_step_cnt    = reg_krlt_base[7:4];
  assign prpo_step_cnt    = reg_krlt_base[11:8];
  assign equal_cnt        = reg_krlt_base[14:12];
  assign dis_init_pma     = reg_krlt_base[15];
  assign ovrd_lp_coef     = reg_krlt_base[16];
  assign ovrd_coef_rx     = reg_krlt_base[17];
  assign ctle_depth       = reg_krlt_base[19:18];
  assign rx_ctle_mode     = reg_krlt_base[22:20];
  assign only_inc_main    = reg_krlt_base[23];
  assign rx_dfe_mode      = reg_krlt_base[26:24];
  assign fixed_mode       = reg_krlt_base[27];
  assign max_mode         = reg_krlt_base[28];
  assign max_post_step    = reg_krlt_base[31:29];

  assign csr_reset_lt  = reg_krlt_reset[0];
  assign lp_tx_upd_new = reg_krlt_reset[4];
  assign ovrd_rx_new   = reg_krlt_reset[8];
  
  assign dfe_extra  = reg_krlt_reset[17:16];
  assign dec_post_more = reg_krlt_reset[18];
  assign ctle_pass_ber = reg_krlt_reset[19];
  assign ctle_bias  = reg_krlt_reset[22:20];
  assign dec_post   = reg_krlt_reset[23];
  assign use_full_time   = reg_krlt_reset[24];

  assign ber_time   = reg_krlt_btime[9:0];
  assign ber_k_time = reg_krlt_btime[19:10];
  assign ber_m_time = reg_krlt_btime[29:20];

  
  assign lcl_txo_update = reg_krlt_ucoef[7:0];
  assign lcl_rxo_update = reg_krlt_ucoef[23:16];

  assign param_ovrd[MAINTAPWIDTH:0] = reg_krlt_ovrdrule[MAINTAPWIDTH:0];
  assign param_ovrd[2*MAINTAPWIDTH+1:MAINTAPWIDTH+1] = reg_krlt_ovrdrule[MAINTAPWIDTH+8:8];
  assign param_ovrd[2*MAINTAPWIDTH+POSTTAPWIDTH+2:2*MAINTAPWIDTH+2] = reg_krlt_ovrdrule[POSTTAPWIDTH+16:16];
  assign param_ovrd[2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+3:2*MAINTAPWIDTH+POSTTAPWIDTH+3] = reg_krlt_ovrdrule[PRETAPWIDTH+24:24];

  assign lt_tm_enable   = reg_krlt_tmode[0];
  assign lt_tm_err_mode = reg_krlt_tmode[7:4];
  assign lt_tm_err_trig = reg_krlt_tmode[15:12];
  assign lt_tm_err_time = reg_krlt_tmode[23:16];
  assign lt_tm_err_cnt  = reg_krlt_tmode[31:24];

endmodule // csr_krlt
