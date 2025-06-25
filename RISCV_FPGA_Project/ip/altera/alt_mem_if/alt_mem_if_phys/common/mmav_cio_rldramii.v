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

module mmav_cio_rldramii (
    ck,
    ckbar,
    csbar,
    webar,
    refbar,
    ba,
    a,
    dq,
    qk,
    qkbar,
    qvld,
    dm,
    dk,
    dkbar,
    tck,
    tms,
    tdi,
    tdo,
    ZQ
);
    parameter memory_spec = "mt49h16m36_18.soma";
    parameter init_file   = "";
    parameter sim_control = "";

    parameter BANK_WIDTH = 3;
    parameter ADDRESS_WIDTH = 20;
    parameter DATA_WIDTH = 36;
    parameter DQS_GROUPS = 2;
    
    input ck;
    input ckbar;
    input csbar;
    input webar;
    input refbar;
    input [BANK_WIDTH-1:0] ba;
    input [ADDRESS_WIDTH-1:0] a;
    inout [DATA_WIDTH-1:0] dq;
      reg [DATA_WIDTH-1:0] den_dq;
      assign dq = den_dq;
    output [DQS_GROUPS-1:0] qk;
      reg [DQS_GROUPS-1:0] den_qk;
      assign qk = den_qk;
    output [DQS_GROUPS-1:0] qkbar;
      reg [DQS_GROUPS-1:0] den_qkbar;
      assign qkbar = den_qkbar;
    output qvld;
      reg den_qvld;
      assign qvld = den_qvld;
    input dm;
    input [DQS_GROUPS-1:0] dk;
    input [DQS_GROUPS-1:0] dkbar;
    input tck;
    input tms;
    input tdi;
    output tdo;
      reg den_tdo;
      assign tdo = den_tdo;
    inout ZQ;
      reg den_ZQ;
      assign ZQ = den_ZQ;
initial
    $rldram_access(ck,ckbar,csbar,webar,refbar,ba,a,dq,den_dq,den_qk,den_qkbar,den_qvld,dm,dk,dkbar,tck,tms,tdi,den_tdo,ZQ,den_ZQ);
endmodule

