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
// Control & status registers for the KR PHY IP top-level
// should start at address 0xA0 = ADDR_KRTOP_BASE
//****************************************************************************
`timescale 1 ps / 1 ps

module csr_krtop 
  #(
  parameter SYNTH_FEC = 0,
  parameter AN_FEC    = 0,
  parameter ERR_INDICATION = 0
  ) ( 
  // user data (avalon-MM formatted) 
  input  wire        clk,
  input  wire        reset,
  input  wire [7:0]  address,
  input  wire        read,
  output reg  [31:0] readdata,
  input  wire        write,
  input  wire [31:0] writedata,
  //status inputs to this CSR
  input  wire        seq_link_rdy,
  input  wire        seq_an_timeout,
  input  wire        seq_lt_timeout,
  input  wire [5:0]  pcs_mode_rc,
  // read/write control outputs
  output reg        csr_reset_seq,
  output reg        dis_an_timer,
  output reg        dis_lf_timer,
  output reg  [2:0] force_mode,
  output reg        fec_enable,
  output reg        fec_request,
  output reg        fec_err_ind,
  output reg        fail_lt_if_ber
);
  import csr_krtop_h::*;


//****************************************************************************
// Instantiate the transceiver sync module to sync the LH and LL status bits
//  \p4\ip\altera_xcvr_generic\ctrl\alt_xcvr_resync.sv
//****************************************************************************
  wire an_timout_sync;          // sync the an_timeout to mgmt clock
  reg  an_timout_lh;            // latch high until read
  reg  clr_status_lh;           // clear the Latch High or Latch Low bits
  wire lt_timout_sync;          // sync the lt_timeout to mgmt clock
  reg  lt_timout_lh;            // latch high until read

  alt_xcvr_resync #(
      .WIDTH       (2)  // Number of bits to resync
  ) resync_topstat (
    .clk    (clk),
    .reset  (reset),
    .d      ({seq_an_timeout, seq_lt_timeout}),
    .q      ({an_timout_sync, lt_timout_sync})
  );

  // latch high logic for an_timout bit
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      an_timout_lh  <= 1'b0;
      lt_timout_lh  <= 1'b0;
    end  // if reset
    else begin
      an_timout_lh  <=  an_timout_sync                   | // set
                       (an_timout_lh & ~clr_status_lh);    // hold
      lt_timout_lh  <=  lt_timout_sync                   | // set
                       (lt_timout_lh & ~clr_status_lh);    // hold
    end  // else
  end  // always

//****************************************************************************
// Logic to create register map, write data, and read mux
//****************************************************************************
  reg  [18:0] reg_top_base;  // base register for KR TOP
  
  reg  [1:0] clr_base_sc_bit;    // clear the self_clear bit in the base reg

  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      reg_top_base[15:0]  <= 16'h0002;   // Disable AN timer
      reg_top_base[16]    <= AN_FEC[0];
      reg_top_base[18]    <= AN_FEC[1];
      reg_top_base[17]    <= ERR_INDICATION[0];
      clr_base_sc_bit     <= 'd0;
      clr_status_lh       <= 'd0;
      readdata            <= 32'd0;
    end // if reset
    else begin
      readdata        <= 32'd0;
      clr_base_sc_bit <= {1'b0, clr_base_sc_bit[1]};
      clr_status_lh   <= 1'b0;
      // clear the self_clear register bits
      if (clr_base_sc_bit[0]) reg_top_base[0] <= 1'b0;
      // decode read & write for each supported address
      case (address)
      ADDR_KRTOP_BASE: begin
        readdata[18:0] <= reg_top_base;
        if (write) begin
          reg_top_base    <= writedata[18:0];
          clr_base_sc_bit <= {writedata[0],1'b0};
        end  // if write
      end  // base
      ADDR_KRTOP_STATUS: begin
        readdata[0]  <= seq_link_rdy;
        readdata[1]  <= an_timout_lh;
        readdata[2]  <= lt_timout_lh;
        readdata[13:8]  <= pcs_mode_rc;
        readdata[16] <= SYNTH_FEC[0];
        readdata[17] <= SYNTH_FEC[0]; // err in ability always 1 if SYTNH_FEC=1
        if (read) clr_status_lh <= 1'b1;
      end  // status
      endcase
    end // else
  end // always

//****************************************************************************
// Drive the outputs
//****************************************************************************
  assign csr_reset_seq = reg_top_base[0];
  assign dis_an_timer  = reg_top_base[1];
  assign dis_lf_timer  = reg_top_base[2];
  assign fail_lt_if_ber= reg_top_base[3];
  assign force_mode    = reg_top_base[6:4];
  assign fec_enable    = reg_top_base[16];
  assign fec_request   = reg_top_base[18];
  assign fec_err_ind   = reg_top_base[17];


endmodule // csr_krtop
