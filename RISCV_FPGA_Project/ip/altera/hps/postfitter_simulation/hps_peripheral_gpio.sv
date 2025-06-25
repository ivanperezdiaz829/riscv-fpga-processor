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


module cyclonev_hps_peripheral_gpio 
#(
   parameter dummy_param = 0
)(
   input  wire [28:0] gpio0_porta_i,
   output wire [28:0] gpio0_porta_o,
   output wire [28:0] gpio0_porta_oe,
   input  wire [28:0] gpio1_porta_i,
   output wire [28:0] gpio1_porta_o,
   output wire [28:0] gpio1_porta_oe,
   input  wire [26:0] gpio2_porta_i,
   output wire [12:0] gpio2_porta_o,
   output wire [12:0] gpio2_porta_oe,
   input  wire [28:0] loanio0_o,
   input  wire [28:0] loanio0_oe,
   input  wire [28:0] loanio1_o,
   input  wire [28:0] loanio1_oe,
   input  wire [28:0] loanio2_o,
   input  wire [28:0] loanio2_oe,
   output wire [28:0] loanio0_i,
   output wire [28:0] loanio1_i,
   output wire [26:0] loanio2_i
);

   assign gpio0_porta_o = 29'b0;
   assign gpio0_porta_oe = 29'b0;
   assign gpio1_porta_o = 29'b0;
   assign gpio1_porta_oe = 29'b0;
   assign gpio2_porta_o = 13'b0;
   assign gpio2_porta_oe = 13'b0;
   assign loanio0_o = 29'b0;
   assign loanio0_oe = 29'b0;
   assign loanio1_o = 29'b0;
   assign loanio1_oe = 29'b0;
   assign loanio2_o = 29'b0;
   assign loanio2_oe = 29'b0;

endmodule 

module arriav_hps_peripheral_gpio 
#(
   parameter dummy_param = 0
)(
   input  wire [28:0] gpio0_porta_i,
   output wire [28:0] gpio0_porta_o,
   output wire [28:0] gpio0_porta_oe,
   input  wire [28:0] gpio1_porta_i,
   output wire [28:0] gpio1_porta_o,
   output wire [28:0] gpio1_porta_oe,
   input  wire [13:0] gpio2_porta_i,
   output wire [13:0] gpio2_porta_o,
   output wire [13:0] gpio2_porta_oe,
   input  wire [28:0] loanio0_o,
   input  wire [28:0] loanio0_oe,
   input  wire [28:0] loanio1_o,
   input  wire [28:0] loanio1_oe,
   input  wire [28:0] loanio2_o,
   input  wire [28:0] loanio2_oe,
   output wire [28:0] loanio0_i,
   output wire [28:0] loanio1_i,
   output wire [28:0] loanio2_i
);

   assign gpio0_porta_o = 29'b0;
   assign gpio0_porta_oe = 29'b0;
   assign gpio1_porta_o = 29'b0;
   assign gpio1_porta_oe = 29'b0;
   assign gpio2_porta_o = 13'b0;
   assign gpio2_porta_oe = 13'b0;
   assign loanio0_o = 29'b0;
   assign loanio0_oe = 29'b0;
   assign loanio1_o = 29'b0;
   assign loanio1_oe = 29'b0;
   assign loanio2_o = 29'b0;
   assign loanio2_oe = 29'b0;

endmodule 
