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


module spim_bfm
(
   sig_rxd,
   sig_ss_in_n,
   sig_txd,
   sig_ssi_oe_n,
   sig_ss_0_n,
   sig_ss_1_n,
   sig_ss_2_n,
   sig_ss_3_n,
   sig_sclk_out
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_rxd;
   input sig_ss_in_n;
   output sig_txd;
   output sig_ssi_oe_n;
   output sig_ss_0_n;
   output sig_ss_1_n;
   output sig_ss_2_n;
   output sig_ss_3_n;
   output sig_sclk_out;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_rxd_t;
   typedef logic ROLE_ss_in_n_t;
   typedef logic ROLE_txd_t;
   typedef logic ROLE_ssi_oe_n_t;
   typedef logic ROLE_ss_0_n_t;
   typedef logic ROLE_ss_1_n_t;
   typedef logic ROLE_ss_2_n_t;
   typedef logic ROLE_ss_3_n_t;
   typedef logic ROLE_sclk_out_t;

   logic [0 : 0] rxd_in;
   logic [0 : 0] rxd_local;
   logic [0 : 0] ss_in_n_in;
   logic [0 : 0] ss_in_n_local;
   reg txd_temp;
   reg txd_out;
   reg ssi_oe_n_temp;
   reg ssi_oe_n_out;
   reg ss_0_n_temp;
   reg ss_0_n_out;
   reg ss_1_n_temp;
   reg ss_1_n_out;
   reg ss_2_n_temp;
   reg ss_2_n_out;
   reg ss_3_n_temp;
   reg ss_3_n_out;
   reg sclk_out_temp;
   reg sclk_out_out;

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

   // -------------------------------------------------------
   // ss_0_n
   // -------------------------------------------------------

   function automatic void set_ss_0_n (
      ROLE_ss_0_n_t new_value
   );
      // Drive the new value to ss_0_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ss_0_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // ss_1_n
   // -------------------------------------------------------

   function automatic void set_ss_1_n (
      ROLE_ss_1_n_t new_value
   );
      // Drive the new value to ss_1_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ss_1_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // ss_2_n
   // -------------------------------------------------------

   function automatic void set_ss_2_n (
      ROLE_ss_2_n_t new_value
   );
      // Drive the new value to ss_2_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ss_2_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // ss_3_n
   // -------------------------------------------------------

   function automatic void set_ss_3_n (
      ROLE_ss_3_n_t new_value
   );
      // Drive the new value to ss_3_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ss_3_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // sclk_out
   // -------------------------------------------------------

   function automatic void set_sclk_out (
      ROLE_sclk_out_t new_value
   );
      // Drive the new value to sclk_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      sclk_out_temp = new_value;
   endfunction

   assign rxd_in = sig_rxd;
   assign ss_in_n_in = sig_ss_in_n;
   assign sig_txd = txd_temp;
   assign sig_ssi_oe_n = ssi_oe_n_temp;
   assign sig_ss_0_n = ss_0_n_temp;
   assign sig_ss_1_n = ss_1_n_temp;
   assign sig_ss_2_n = ss_2_n_temp;
   assign sig_ss_3_n = ss_3_n_temp;
   assign sig_sclk_out = sclk_out_temp;


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
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_spi_master (
   input  wire rxd,
   input  wire ss_in_n,
   output wire txd,
   output wire ssi_oe_n,
   output wire ss_0_n,
   output wire ss_1_n,
   output wire ss_2_n,
   output wire ss_3_n,
   output wire sclk_out
);

   spim_bfm spim_inst (
      .sig_rxd(rxd),
      .sig_ss_in_n(ss_in_n),
      .sig_txd(txd),
      .sig_ssi_oe_n(ssi_oe_n),
      .sig_ss_0_n(ss_0_n),
      .sig_ss_1_n(ss_1_n),
      .sig_ss_2_n(ss_2_n),
      .sig_ss_3_n(ss_3_n),
      .sig_sclk_out(sclk_out)
   );

endmodule 

module arriav_hps_interface_peripheral_spi_master (
   input  wire rxd,
   input  wire ss_in_n,
   output wire txd,
   output wire ssi_oe_n,
   output wire ss_0_n,
   output wire ss_1_n,
   output wire ss_2_n,
   output wire ss_3_n,
   output wire sclk_out
);

   spim_bfm spim_inst (
      .sig_rxd(rxd),
      .sig_ss_in_n(ss_in_n),
      .sig_txd(txd),
      .sig_ssi_oe_n(ssi_oe_n),
      .sig_ss_0_n(ss_0_n),
      .sig_ss_1_n(ss_1_n),
      .sig_ss_2_n(ss_2_n),
      .sig_ss_3_n(ss_3_n),
      .sig_sclk_out(sclk_out)
   );

endmodule 