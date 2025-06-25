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
// Control & status registers for the KR PHY IP Auto-Negotiation
// should start at address 0xB0 = ADDR_KRAN_BASE
//****************************************************************************
`timescale 1 ps / 1 ps

module alt_e40_csr_kran (
  // user data (avalon-MM formatted) 
  input  wire        clk,
  input  wire        reset,
  input  wire [7:0]  address,
  input  wire        read,
  output reg  [31:0] readdata,
  input  wire        write,
  input  wire [31:0] writedata,
  //status inputs to this CSR
  input  wire        an_pg_received,
  input  wire        an_completed,
  input  wire        lcl_dvce_rf_sent,
  input  wire        an_rx_idle,
  input  wire        an_ability,
  input  wire        an_status,   // same as link_good, just has Latch Low
  input  wire        lp_an_able,
  input  wire        lp_fec_neg,  // seq_fec_enable
  input  wire        an_failure,
  input  wire [5:0]  an_link_ready,
  input  wire [48:1] lp_base_pg,
  input  wire [48:1] lp_next_pg,
  input  wire [24:0] lp_tech,
  input  wire [1:0]  lp_fec,
  input  wire        lp_rf,
  input  wire [2:0]  lp_pause,
  // read/write control outputs
  output reg        csr_an_enable,
  output reg        usr_base_page_en,
  output reg        usr_nxt_page_en,
  output reg        usr_lcl_dvce_rf,
  output reg        csr_reset_an,
  output reg        csr_restart_txsm,
  output reg        new_np_ready,
  output reg [14:1]  usr_base_pg_lo,
  output reg [48:16] usr_base_pg_hi,
  output reg [14:1]  usr_next_pg_lo,
  output reg [48:16] usr_next_pg_hi,
  output reg         csr_hold_nonce,
  output reg         en_an_param_ovrd,
  output reg [5:0]  ovrd_an_tech,
  output reg [1:0]  ovrd_an_fec,
  output reg [2:0]  ovrd_an_pause,
  output reg        an_tm_enable,
  output reg [3:0]  an_tm_err_mode,
  output reg [3:0]  an_tm_err_trig,
  output reg [7:0]  an_tm_err_time,
  output reg [7:0]  an_tm_err_cnt,
  output reg        an_chan_ovrd,
  output reg [3:0]  an_chan_ovrd_sel
);
  import alt_e40_csr_krtop_h::*;

//****************************************************************************
// Instantiate the transceiver sync module to sync the LH and LL status bits
//  \p4\ip\altera_xcvr_generic\ctrl\alt_xcvr_resync.sv
//**************************************************************************** 
  wire pg_rx_sync;          // sync the an_pg_received to mgmt clock
  reg  pg_rx_dly;           // delay for rising edge detect
  reg  pg_rx_lh;            // latch the rising edge until read
  reg  clr_status_lh;         // clear the Latch High or Latch Low bits
  
  wire lcl_rf_sync;          // sync the lcl_dvce_rf_sent to mgmt clock
  reg  lcl_rf_dly;           // delay for rising edge detect
  reg  lcl_rf_lh;            // latch the rising edge until read

  wire lnk_up_sync;          // sync the an_status to mgmt clock
  reg  lnk_up_dly;           // delay for falling edge detect
  reg  lnk_up_ll;            // latch the falling edge until read

  alt_xcvr_resync #(
      .WIDTH       (3)  // Number of bits to resync
  ) resync_topstat (
    .clk    (clk),
    .reset  (reset),
    .d      ({an_pg_received, lcl_dvce_rf_sent, an_status}),
    .q      ({pg_rx_sync    , lcl_rf_sync     , lnk_up_sync})
  );

  // latch high/low logic for status bits
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      pg_rx_dly <= 1'b0;
      pg_rx_lh  <= 1'b0;
      lcl_rf_dly <= 1'b0;
      lcl_rf_lh  <= 1'b0;
      lnk_up_dly <= 1'b0;
      lnk_up_ll  <= 1'b0;
    end  // if reset
    else begin
      pg_rx_dly   <= pg_rx_sync;
      pg_rx_lh    <= (pg_rx_sync & ~pg_rx_dly) |      // set
                     (pg_rx_lh & ~clr_status_lh);     // hold
      lcl_rf_dly  <= lcl_rf_sync;
      lcl_rf_lh   <= (lcl_rf_sync & ~lcl_rf_dly) |    // set
                     (lcl_rf_lh & ~clr_status_lh);    // hold
      lnk_up_dly  <= lnk_up_sync;
      // Latch low sets/sample when read and hold until falling edge if set
      lnk_up_ll   <= (lnk_up_sync & clr_status_lh)             |  // sample
                     (lnk_up_ll & ~(~lnk_up_sync & lnk_up_dly));  // hold
    end  // else
  end  // always

//****************************************************************************
// Logic to create register map, write data, and read mux
//****************************************************************************
  reg  [6:0]  reg_kran_base;    // base register
  reg  [8:0]  reg_kran_reset;   // reset register
  reg  [31:0] reg_kran_ublo;    // user base page lo register
  reg  [31:0] reg_kran_ubhi;    // user base page hi register
  reg  [15:0] reg_kran_nxtlo;   // user next page lo register
  reg  [31:0] reg_kran_nxthi;   // user next page hi register
  reg  [31:0] reg_kran_tmode;   // test mode register
  
  reg  [1:0] clr_rst_sc_bit;    // clear the self_clear bits in reset reg

  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      reg_kran_base  <= 7'h1;  // default to Enable AN
      reg_kran_reset <= 'd0;
      reg_kran_ublo  <= 'd0;
      reg_kran_ubhi  <= 'd0;
      reg_kran_nxtlo <= 'd0;
      reg_kran_nxthi <= 'd0;
      reg_kran_tmode <= 'd0;
      clr_rst_sc_bit <= 'd0;
      clr_status_lh  <= 'd0;
	  an_chan_ovrd_sel <= 'd0;
      readdata       <= 32'd0;
    end // if reset
    else begin
      readdata       <= 32'd0;
      clr_rst_sc_bit <= {1'b0, clr_rst_sc_bit[1]};
      clr_status_lh  <= 1'b0;
      // clear the self_clear register bits
      if (clr_rst_sc_bit[0]) 
          {reg_kran_reset[8],reg_kran_reset[4],reg_kran_reset[0]} <= 3'b000;
      // decode read & write for each supported address
      case (address)
      ADDR_KRAN_BASE: begin
        readdata[6:0] <= reg_kran_base;
        if (write) reg_kran_base <= writedata[6:0];
      end // base
      ADDR_KRAN_RESET: begin
        readdata[8:0] <= reg_kran_reset;
        if (write) begin
          reg_kran_reset <= writedata[8:0];
          clr_rst_sc_bit <= {writedata[8]|writedata[4]|writedata[0],1'b0};
        end  // if write
      end  // reset
      ADDR_KRAN_STATUS: begin
        readdata[1] <= pg_rx_lh;
        readdata[2] <= an_completed;
        readdata[3] <= lcl_rf_lh;
        readdata[4] <= an_rx_idle;
        readdata[5] <= an_ability;
        readdata[6] <= lnk_up_ll;
        readdata[7] <= lp_an_able;
        readdata[8] <= lp_fec_neg;
        readdata[9] <= an_failure;
        readdata[17:12] <= an_link_ready;
        if (read) clr_status_lh <= 1'b1;
      end  // status
      ADDR_KRAN_UBPLO: begin
        readdata[31:0] <= reg_kran_ublo;
        if (write) reg_kran_ublo <= writedata[31:0];
      end // base page low
      ADDR_KRAN_UBPHI: begin
        readdata <= reg_kran_ubhi;
        if (write) reg_kran_ubhi <= writedata;
      end // base page hi
      ADDR_KRAN_UNXTLO: begin
        readdata[15:0] <= reg_kran_nxtlo;
        if (write) reg_kran_nxtlo <= writedata[15:0];
      end // next page low
      ADDR_KRAN_UNXTHI: begin
        readdata <= reg_kran_nxthi;
        if (write) reg_kran_nxthi <= writedata;
      end // next page hi
      ADDR_KRAN_LPBPLO: readdata[15:0] <= lp_base_pg[16:1];
      ADDR_KRAN_LPBPHI: readdata       <= lp_base_pg[48:17];
      ADDR_KRAN_LPNXLO: readdata[15:0] <= lp_next_pg[16:1];
      ADDR_KRAN_LPNXHI: readdata       <= lp_next_pg[48:17];
      ADDR_KRAN_LPADV : readdata[30:0] <= 
         {lp_pause, lp_rf, lp_fec, lp_tech};
	  ADDR_KRAN_OVRCH : begin
        readdata[3:0]  <= an_chan_ovrd_sel;
        if (write) an_chan_ovrd_sel <= writedata[3:0];
      end // channel override register
      ADDR_KRAN_TM: begin
        readdata <= reg_kran_tmode;
        if (write) reg_kran_tmode <= writedata;
      end // test mode
      endcase
    end // else
  end // always

//****************************************************************************
// Drive the outputs
//****************************************************************************
  assign csr_an_enable    = reg_kran_base[0];
  assign usr_base_page_en = reg_kran_base[1];
  assign usr_nxt_page_en  = reg_kran_base[2];
  assign usr_lcl_dvce_rf  = reg_kran_base[3];
  assign csr_hold_nonce   = reg_kran_base[4];
  assign en_an_param_ovrd = reg_kran_base[5];
  assign an_chan_ovrd     = reg_kran_base[6];

  assign csr_reset_an     = reg_kran_reset[0];
  assign csr_restart_txsm = reg_kran_reset[4];
  assign new_np_ready     = reg_kran_reset[8];

  assign ovrd_an_pause  =  reg_kran_ublo[30:28];
  assign ovrd_an_fec    =  reg_kran_ublo[25:24];
  assign ovrd_an_tech   =  reg_kran_ublo[21:16];
  assign usr_base_pg_lo =  reg_kran_ublo[13:0];
  assign usr_base_pg_hi = {reg_kran_ubhi,  reg_kran_ublo[15]};
  assign usr_next_pg_lo =  reg_kran_nxtlo[13:0];
  assign usr_next_pg_hi = {reg_kran_nxthi, reg_kran_nxtlo[15]};

  assign an_tm_enable     = reg_kran_tmode[0];
  assign an_tm_err_mode   = reg_kran_tmode[7:4];
  assign an_tm_err_trig   = reg_kran_tmode[15:12];
  assign an_tm_err_time   = reg_kran_tmode[23:16];
  assign an_tm_err_cnt    = reg_kran_tmode[31:24];

endmodule // alt_e40_csr_kran
