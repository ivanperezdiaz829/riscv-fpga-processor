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


module uart_bfm
(
   sig_cts,
   sig_dsr,
   sig_dcd,
   sig_ri,
   sig_rxd,
   sig_dtr,
   sig_rts,
   sig_out1_n,
   sig_out2_n,
   sig_txd
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_cts;
   input sig_dsr;
   input sig_dcd;
   input sig_ri;
   input sig_rxd;
   output sig_dtr;
   output sig_rts;
   output sig_out1_n;
   output sig_out2_n;
   output sig_txd;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_cts_t;
   typedef logic ROLE_dsr_t;
   typedef logic ROLE_dcd_t;
   typedef logic ROLE_ri_t;
   typedef logic ROLE_rxd_t;
   typedef logic ROLE_dtr_t;
   typedef logic ROLE_rts_t;
   typedef logic ROLE_out1_n_t;
   typedef logic ROLE_out2_n_t;
   typedef logic ROLE_txd_t;

   logic [0 : 0] cts_in;
   logic [0 : 0] cts_local;
   logic [0 : 0] dsr_in;
   logic [0 : 0] dsr_local;
   logic [0 : 0] dcd_in;
   logic [0 : 0] dcd_local;
   logic [0 : 0] ri_in;
   logic [0 : 0] ri_local;
   logic [0 : 0] rxd_in;
   logic [0 : 0] rxd_local;
   reg dtr_temp;
   reg dtr_out;
   reg rts_temp;
   reg rts_out;
   reg out1_n_temp;
   reg out1_n_out;
   reg out2_n_temp;
   reg out2_n_out;
   reg txd_temp;
   reg txd_out;

   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). The application program interface provides methods for 
   // a testbench which instantiates, controls and queries state in this BFM 
   // component. Test programs must only use these public access methods and 
   // events to communicate with this BFM component. The API and module pins
   // are the only interfaces of this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------
   
   event signal_input_cts_change;
   event signal_input_dsr_change;
   event signal_input_dcd_change;
   event signal_input_ri_change;
   event signal_input_rxd_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // cts
   // -------------------------------------------------------
   function automatic ROLE_cts_t get_cts();
   
      // Gets the cts input value.
      $sformat(message, "%m: called get_cts");
      print(VERBOSITY_DEBUG, message);
      return cts_in;
      
   endfunction

   // -------------------------------------------------------
   // dsr
   // -------------------------------------------------------
   function automatic ROLE_dsr_t get_dsr();
   
      // Gets the dsr input value.
      $sformat(message, "%m: called get_dsr");
      print(VERBOSITY_DEBUG, message);
      return dsr_in;
      
   endfunction

   // -------------------------------------------------------
   // dcd
   // -------------------------------------------------------
   function automatic ROLE_dcd_t get_dcd();
   
      // Gets the dcd input value.
      $sformat(message, "%m: called get_dcd");
      print(VERBOSITY_DEBUG, message);
      return dcd_in;
      
   endfunction

   // -------------------------------------------------------
   // ri
   // -------------------------------------------------------
   function automatic ROLE_ri_t get_ri();
   
      // Gets the ri input value.
      $sformat(message, "%m: called get_ri");
      print(VERBOSITY_DEBUG, message);
      return ri_in;
      
   endfunction

   // -------------------------------------------------------
   // rxd
   // -------------------------------------------------------
   function automatic ROLE_rxd_t get_rxd();
   
      // Gets the rxd input value.
      $sformat(message, "%m: called get_rxd");
      print(VERBOSITY_DEBUG, message);
      return rxd_in;
      
   endfunction

   // -------------------------------------------------------
   // dtr
   // -------------------------------------------------------

   function automatic void set_dtr (
      ROLE_dtr_t new_value
   );
      // Drive the new value to dtr.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      dtr_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // rts
   // -------------------------------------------------------

   function automatic void set_rts (
      ROLE_rts_t new_value
   );
      // Drive the new value to rts.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      rts_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // out1_n
   // -------------------------------------------------------

   function automatic void set_out1_n (
      ROLE_out1_n_t new_value
   );
      // Drive the new value to out1_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      out1_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // out2_n
   // -------------------------------------------------------

   function automatic void set_out2_n (
      ROLE_out2_n_t new_value
   );
      // Drive the new value to out2_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      out2_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // txd
   // -------------------------------------------------------

   function automatic void set_txd (
      ROLE_txd_t new_value
   );
      // Drive the new value to txd.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      txd_temp = new_value;
   endfunction

   assign cts_in = sig_cts;
   assign dsr_in = sig_dsr;
   assign dcd_in = sig_dcd;
   assign ri_in = sig_ri;
   assign rxd_in = sig_rxd;
   assign sig_dtr = dtr_temp;
   assign sig_rts = rts_temp;
   assign sig_out1_n = out1_n_temp;
   assign sig_out2_n = out2_n_temp;
   assign sig_txd = txd_temp;


   always @(cts_in) begin
      if (cts_local != cts_in)
         -> signal_input_cts_change;
      cts_local = cts_in;
   end
   
   always @(dsr_in) begin
      if (dsr_local != dsr_in)
         -> signal_input_dsr_change;
      dsr_local = dsr_in;
   end
   
   always @(dcd_in) begin
      if (dcd_local != dcd_in)
         -> signal_input_dcd_change;
      dcd_local = dcd_in;
   end
   
   always @(ri_in) begin
      if (ri_local != ri_in)
         -> signal_input_ri_change;
      ri_local = ri_in;
   end
   
   always @(rxd_in) begin
      if (rxd_local != rxd_in)
         -> signal_input_rxd_change;
      rxd_local = rxd_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_uart (
   input  wire cts,
   input  wire dsr,
   input  wire dcd,
   input  wire ri,
   input  wire rxd,
   output wire dtr,
   output wire rts,
   output wire out1_n,
   output wire out2_n,
   output wire txd
);

   uart_bfm uart_inst (
      .sig_cts(cts),
      .sig_dsr(dsr),
      .sig_dcd(dcd),
      .sig_ri(ri),
      .sig_rxd(rxd),
      .sig_dtr(dtr),
      .sig_rts(rts),
      .sig_out1_n(out1_n),
      .sig_out2_n(out2_n),
      .sig_txd(txd)
   );

endmodule 

module arriav_hps_interface_peripheral_uart (
   input  wire cts,
   input  wire dsr,
   input  wire dcd,
   input  wire ri,
   input  wire rxd,
   output wire dtr,
   output wire rts,
   output wire out1_n,
   output wire out2_n,
   output wire txd
);

   uart_bfm uart_inst (
      .sig_cts(cts),
      .sig_dsr(dsr),
      .sig_dcd(dcd),
      .sig_ri(ri),
      .sig_rxd(rxd),
      .sig_dtr(dtr),
      .sig_rts(rts),
      .sig_out1_n(out1_n),
      .sig_out2_n(out2_n),
      .sig_txd(txd)
   );

endmodule 