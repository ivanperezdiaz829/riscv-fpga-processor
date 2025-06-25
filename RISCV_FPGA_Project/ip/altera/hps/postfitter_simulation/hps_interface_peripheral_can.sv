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


module can_bfm
(
   sig_rxd,
   sig_txd
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_rxd;
   output sig_txd;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_rxd_t;
   typedef logic ROLE_txd_t;

   logic [0 : 0] rxd_in;
   logic [0 : 0] rxd_local;
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
   
   event signal_input_rxd_change;
   
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

   assign rxd_in = sig_rxd;
   assign sig_txd = txd_temp;


   always @(rxd_in) begin
      if (rxd_local != rxd_in)
         -> signal_input_rxd_change;
      rxd_local = rxd_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_can (
   input  wire rxd,
   output wire txd
);

   can_bfm can_inst (
      .sig_rxd(rxd),
      .sig_txd(txd)
   );

endmodule 

module arriav_hps_interface_peripheral_can (
   input  wire rxd,
   output wire txd
);

   can_bfm can_inst (
      .sig_rxd(rxd),
      .sig_txd(txd)
   );

endmodule 