// (C) 2001-2011 Altera Corporation. All rights reserved.
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



(* ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_disable_timing [get_cells -compatibility_mode *pd*_det\|alt_edge_det_ff?] -to q \";disable_da_rule=\"C101,C103,C104,C106,D101\"" *)

 module alt_cal_dfe_edge_detect (
  output pd_edge,
  input reset,
  input testbus 
);

  wire pd_xor;
  wire pd_posedge;
  wire pd_negedge;
  assign pd_xor = ~(pd_posedge ^ pd_negedge);
  
  // pd_edge will be asserted when both a positive and negative edge are detected - both up and down transition has occurred, which implies toggling
  dffeas ff2 (
    .clk     (pd_xor),
    .d       (1'b1),
    .asdata  (1'b1),
    .clrn    (~reset),
    .aload   (1'b0),
    .q       (pd_edge),
    .sload   (1'b0),
    .sclr    (1'b0),
    .ena     (1'b1),
    .prn     (), 
    .devclrn (),
    .devpor  ()
  );
  
  // essentially a latch - testbus may toggle very fast (1GHz+)
  dffeas alt_edge_det_ff0 (
    .clk     (testbus),
    .d       (1'b1),
    .asdata  (1'b0),
    .clrn    (1'b1),
    .aload   (reset),
    .q       (pd_posedge),
    .sload   (1'b1),
    .sclr    (1'b1),
    .ena     (1'b1),
    .prn     (), 
    .devclrn (),
    .devpor  ()
  );
  
  // essentially a latch - testbus may toggle very fast (1GHz+)
  dffeas alt_edge_det_ff1 (
    .clk     (~testbus),
    .d       (1'b0),
    .asdata  (1'b1),
    .clrn    (1'b1),
    .aload   (reset),
    .q       (pd_negedge),
    .sload   (1'b0),
    .sclr    (1'b0),
    .ena     (1'b1),
    .prn     (), 
    .devclrn (),
    .devpor  ()
  );

endmodule
