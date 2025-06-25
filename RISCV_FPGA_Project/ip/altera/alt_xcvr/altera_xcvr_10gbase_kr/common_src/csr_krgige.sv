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
// Control & status registers for the KR PHY IP legacy Gige
// should start at address 0x90 = ADDR_KRGIGE_BASE
//****************************************************************************
`timescale 1 ps / 1 ps

module csr_krgige (
  // user data (avalon-MM formatted) 
  input  wire        clk,
  input  wire        reset,
  input  wire [7:0]  address,
  input  wire        read,
  output reg  [31:0] readdata,
  input  wire        write,
  input  wire [31:0] writedata,
  //status inputs to this CSR
  input  wire        rx_sync_status,
  input  wire        rx_pattern_det,
  input  wire        rx_rlv,
  input  wire        rx_rmfifo_inserted,
  input  wire        rx_rmfifo_deleted,
  input  wire        rx_disperr,
  input  wire        rx_errdetect,
  // read/write control outputs
  output reg        tx_invpolarity,
  output reg        rx_invpolarity,
  output reg        rx_bitreversal,
  output reg        rx_bytereversal,
  output reg        force_elec_idle
);
  import csr_krtop_h::*;

//****************************************************************************
// Logic to create register map, write data, and read mux
//****************************************************************************
  reg  [4:0] reg_gige_base;  // base register for KR legacy gige
  
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      reg_gige_base <= 'd0;
      readdata      <= 32'd0;
    end  // if reset
    else begin
      readdata <= 32'd0;
      // decode read & write for each supported address
      case (address)
      ADDR_KRGIGE_BASE: begin
        readdata[4:0] <= reg_gige_base;
        if (write) reg_gige_base <= writedata[4:0];
      end // base
      ADDR_KRGIGE_STATUS: begin
        readdata[0]  <= rx_sync_status;
        readdata[1]  <= rx_pattern_det;
        readdata[2]  <= rx_rlv;
        readdata[3]  <= rx_rmfifo_inserted;
        readdata[4]  <= rx_rmfifo_deleted;
        readdata[5]  <= rx_disperr;
        readdata[6]  <= rx_errdetect;
      end  // status
      endcase
    end // else
  end // always

//****************************************************************************
// Drive the outputs
//****************************************************************************
  assign tx_invpolarity  = reg_gige_base[0];
  assign rx_invpolarity  = reg_gige_base[1];
  assign rx_bitreversal  = reg_gige_base[2];
  assign rx_bytereversal = reg_gige_base[3];
  assign force_elec_idle = reg_gige_base[4];

endmodule // csr_krgige
