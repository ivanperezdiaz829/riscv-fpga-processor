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


module i2c_bfm
(
   sig_scl,
   sig_sda,
   sig_out_data,
   sig_out_clk
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_scl;
   input sig_sda;
   output sig_out_data;
   output sig_out_clk;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_scl_t;
   typedef logic ROLE_sda_t;
   typedef logic ROLE_out_data_t;
   typedef logic ROLE_out_clk_t;

   logic [0 : 0] scl_in;
   logic [0 : 0] scl_local;
   logic [0 : 0] sda_in;
   logic [0 : 0] sda_local;
   reg out_data_temp;
   reg out_data_out;
   reg out_clk_temp;
   reg out_clk_out;

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
   
   event signal_input_scl_change;
   event signal_input_sda_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // scl
   // -------------------------------------------------------
   function automatic ROLE_scl_t get_scl();
   
      // Gets the scl input value.
      $sformat(message, "%m: called get_scl");
      print(VERBOSITY_DEBUG, message);
      return scl_in;
      
   endfunction

   // -------------------------------------------------------
   // sda
   // -------------------------------------------------------
   function automatic ROLE_sda_t get_sda();
   
      // Gets the sda input value.
      $sformat(message, "%m: called get_sda");
      print(VERBOSITY_DEBUG, message);
      return sda_in;
      
   endfunction

   // -------------------------------------------------------
   // out_data
   // -------------------------------------------------------

   function automatic void set_out_data (
      ROLE_out_data_t new_value
   );
      // Drive the new value to out_data.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      out_data_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // out_clk
   // -------------------------------------------------------

   function automatic void set_out_clk (
      ROLE_out_clk_t new_value
   );
      // Drive the new value to out_clk.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      out_clk_temp = new_value;
   endfunction

   assign scl_in = sig_scl;
   assign sda_in = sig_sda;
   assign sig_out_data = out_data_temp;
   assign sig_out_clk = out_clk_temp;


   always @(scl_in) begin
      if (scl_local != scl_in)
         -> signal_input_scl_change;
      scl_local = scl_in;
   end
   
   always @(sda_in) begin
      if (sda_local != sda_in)
         -> signal_input_sda_change;
      sda_local = sda_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_i2c (
   input  wire scl,
   input  wire sda,
   output wire out_data,
   output wire out_clk
);

   i2c_bfm i2c_inst (
      .sig_scl(scl),
      .sig_sda(sda),
      .sig_out_data(out_data),
      .sig_out_clk(out_clk)
   );

endmodule 

module arriav_hps_interface_peripheral_i2c (
   input  wire scl,
   input  wire sda,
   output wire out_data,
   output wire out_clk
);

   i2c_bfm i2c_inst (
      .sig_scl(scl),
      .sig_sda(sda),
      .sig_out_data(out_data),
      .sig_out_clk(out_clk)
   );

endmodule 