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


// $Id: //acds/rel/13.1/ip/sld/st/altera_streaming_sld_hub_controller/altera_streaming_sld_hub_controller_sld_node.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
`default_nettype none

module altera_streaming_sld_hub_controller_sld_node #(
    parameter ENABLE_JTAG_IO_SELECTION = 0
  )
  (
    input wire  tck,
    input wire  tms,
    input wire  tdi,
    input wire  select_me,
    output wire tdo
  );

// synthesis read_comments_as_HDL on
//   altera_soft_core_jtag_io #(
//     .ENABLE_JTAG_IO_SELECTION (ENABLE_JTAG_IO_SELECTION),
//     .HINTS ("ALTERA_SLD_HUB_CONTROLLER_INTERNAL=1,")
//   ) jtag_access (
//     .tck (tck),
//     .tms (tms),
//     .tdi (tdi),
//     .select_this (select_me),
//     .tdo (tdo)
//   );
// synthesis read_comments_as_HDL off

endmodule

`default_nettype wire

