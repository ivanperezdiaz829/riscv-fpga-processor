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


module spis_bfm
(
   sig_rxd,
   sig_ss_in_n,
   sig_sclk_in,
   sig_txd,
   sig_ssi_oe_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_rxd;
   input sig_ss_in_n;
   input sig_sclk_in;
   output sig_txd;
   output sig_ssi_oe_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_rxd_t;
   typedef logic ROLE_ss_in_n_t;
   typedef logic ROLE_sclk_in_t;
   typedef logic ROLE_txd_t;
   typedef logic ROLE_ssi_oe_n_t;

   logic [0 : 0] rxd_in;
   logic [0 : 0] rxd_local;
   logic [0 : 0] ss_in_n_in;
   logic [0 : 0] ss_in_n_local;
   logic [0 : 0] sclk_in_in;
   logic [0 : 0] sclk_in_local;
   reg txd_temp;
   reg txd_out;
   reg ssi_oe_n_temp;
   reg ssi_oe_n_out;

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
   
   event signal_input_rxd_change;
   event signal_input_ss_in_n_change;
   event signal_input_sclk_in_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
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
   // ss_in_n
   // -------------------------------------------------------
   function automatic ROLE_ss_in_n_t get_ss_in_n();
   
      // Gets the ss_in_n input value.
      $sformat(message, "%m: called get_ss_in_n");
      print(VERBOSITY_DEBUG, message);
      return ss_in_n_in;
      
   endfunction

   // -------------------------------------------------------
   // sclk_in
   // -------------------------------------------------------
   function automatic ROLE_sclk_in_t get_sclk_in();
   
      // Gets the sclk_in input value.
      $sformat(message, "%m: called get_sclk_in");
      print(VERBOSITY_DEBUG, message);
      return sclk_in_in;
      
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

   // -------------------------------------------------------
   // ssi_oe_n
   // -------------------------------------------------------

   function automatic void set_ssi_oe_n (
      ROLE_ssi_oe_n_t new_value
   );
      // Drive the new value to ssi_oe_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ssi_oe_n_temp = new_value;
   endfunction

   assign rxd_in = sig_rxd;
   assign ss_in_n_in = sig_ss_in_n;
   assign sclk_in_in = sig_sclk_in;
   assign sig_txd = txd_temp;
   assign sig_ssi_oe_n = ssi_oe_n_temp;


   always @(rxd_in) begin
      if (rxd_local != rxd_in)
         -> signal_input_rxd_change;
      rxd_local = rxd_in;
   end
   
   always @(ss_in_n_in) begin
      if (ss_in_n_local != ss_in_n_in)
         -> signal_input_ss_in_n_change;
      ss_in_n_local = ss_in_n_in;
   end
   
   always @(sclk_in_in) begin
      if (sclk_in_local != sclk_in_in)
         -> signal_input_sclk_in_change;
      sclk_in_local = sclk_in_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_spi_slave (
   input  wire rxd,
   input  wire ss_in_n,
   input  wire sclk_in,
   output wire txd,
   output wire ssi_oe_n
);

   spis_bfm spis_inst (
      .sig_rxd(rxd),
      .sig_ss_in_n(ss_in_n),
      .sig_sclk_in(sclk_in),
      .sig_txd(txd),
      .sig_ssi_oe_n(ssi_oe_n)
   );

endmodule 

module arriav_hps_interface_peripheral_spi_slave (
   input  wire rxd,
   input  wire ss_in_n,
   input  wire sclk_in,
   output wire txd,
   output wire ssi_oe_n
);

   spis_bfm spis_inst (
      .sig_rxd(rxd),
      .sig_ss_in_n(ss_in_n),
      .sig_sclk_in(sclk_in),
      .sig_txd(txd),
      .sig_ssi_oe_n(ssi_oe_n)
   );

endmodule 