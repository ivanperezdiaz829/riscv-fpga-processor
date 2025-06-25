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


module nand_bfm
(
   sig_adq_in,
   sig_rdy_busy,
   sig_wpbar,
   sig_adq_out,
   sig_ale,
   sig_adq_oe,
   sig_rebar,
   sig_cle,
   sig_cebar,
   sig_webar
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [7 : 0] sig_adq_in;
   input [3 : 0] sig_rdy_busy;
   output sig_wpbar;
   output [7 : 0] sig_adq_out;
   output sig_ale;
   output sig_adq_oe;
   output sig_rebar;
   output sig_cle;
   output [3 : 0] sig_cebar;
   output sig_webar;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [7 : 0] ROLE_adq_in_t;
   typedef logic [3 : 0] ROLE_rdy_busy_t;
   typedef logic ROLE_wpbar_t;
   typedef logic [7 : 0] ROLE_adq_out_t;
   typedef logic ROLE_ale_t;
   typedef logic ROLE_adq_oe_t;
   typedef logic ROLE_rebar_t;
   typedef logic ROLE_cle_t;
   typedef logic [3 : 0] ROLE_cebar_t;
   typedef logic ROLE_webar_t;

   logic [7 : 0] adq_in_in;
   logic [7 : 0] adq_in_local;
   logic [3 : 0] rdy_busy_in;
   logic [3 : 0] rdy_busy_local;
   reg wpbar_temp;
   reg wpbar_out;
   reg [7 : 0] adq_out_temp;
   reg [7 : 0] adq_out_out;
   reg ale_temp;
   reg ale_out;
   reg adq_oe_temp;
   reg adq_oe_out;
   reg rebar_temp;
   reg rebar_out;
   reg cle_temp;
   reg cle_out;
   reg [3 : 0] cebar_temp;
   reg [3 : 0] cebar_out;
   reg webar_temp;
   reg webar_out;

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
   
   event signal_input_adq_in_change;
   event signal_input_rdy_busy_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // adq_in
   // -------------------------------------------------------
   function automatic ROLE_adq_in_t get_adq_in();
   
      // Gets the adq_in input value.
      $sformat(message, "%m: called get_adq_in");
      print(VERBOSITY_DEBUG, message);
      return adq_in_in;
      
   endfunction

   // -------------------------------------------------------
   // rdy_busy
   // -------------------------------------------------------
   function automatic ROLE_rdy_busy_t get_rdy_busy();
   
      // Gets the rdy_busy input value.
      $sformat(message, "%m: called get_rdy_busy");
      print(VERBOSITY_DEBUG, message);
      return rdy_busy_in;
      
   endfunction

   // -------------------------------------------------------
   // wpbar
   // -------------------------------------------------------

   function automatic void set_wpbar (
      ROLE_wpbar_t new_value
   );
      // Drive the new value to wpbar.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      wpbar_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // adq_out
   // -------------------------------------------------------

   function automatic void set_adq_out (
      ROLE_adq_out_t new_value
   );
      // Drive the new value to adq_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      adq_out_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // ale
   // -------------------------------------------------------

   function automatic void set_ale (
      ROLE_ale_t new_value
   );
      // Drive the new value to ale.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ale_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // adq_oe
   // -------------------------------------------------------

   function automatic void set_adq_oe (
      ROLE_adq_oe_t new_value
   );
      // Drive the new value to adq_oe.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      adq_oe_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // rebar
   // -------------------------------------------------------

   function automatic void set_rebar (
      ROLE_rebar_t new_value
   );
      // Drive the new value to rebar.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      rebar_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // cle
   // -------------------------------------------------------

   function automatic void set_cle (
      ROLE_cle_t new_value
   );
      // Drive the new value to cle.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      cle_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // cebar
   // -------------------------------------------------------

   function automatic void set_cebar (
      ROLE_cebar_t new_value
   );
      // Drive the new value to cebar.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      cebar_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // webar
   // -------------------------------------------------------

   function automatic void set_webar (
      ROLE_webar_t new_value
   );
      // Drive the new value to webar.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      webar_temp = new_value;
   endfunction

   assign adq_in_in = sig_adq_in;
   assign rdy_busy_in = sig_rdy_busy;
   assign sig_wpbar = wpbar_temp;
   assign sig_adq_out = adq_out_temp;
   assign sig_ale = ale_temp;
   assign sig_adq_oe = adq_oe_temp;
   assign sig_rebar = rebar_temp;
   assign sig_cle = cle_temp;
   assign sig_cebar = cebar_temp;
   assign sig_webar = webar_temp;


   always @(adq_in_in) begin
      if (adq_in_local != adq_in_in)
         -> signal_input_adq_in_change;
      adq_in_local = adq_in_in;
   end
   
   always @(rdy_busy_in) begin
      if (rdy_busy_local != rdy_busy_in)
         -> signal_input_rdy_busy_change;
      rdy_busy_local = rdy_busy_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_nand (
   input  wire [7:0] adq_in,
   input  wire [3:0] rdy_busy,
   output wire       wpbar,
   output wire [7:0] adq_out,
   output wire       ale,
   output wire       adq_oe,
   output wire       rebar,
   output wire       cle,
   output wire [3:0] cebar,
   output wire       webar
);

   nand_bfm nand_inst (
      .sig_adq_in(adq_in),
      .sig_rdy_busy(rdy_busy),
      .sig_wpbar(wpbar),
      .sig_adq_out(adq_out),
      .sig_ale(ale),
      .sig_adq_oe(adq_oe),
      .sig_rebar(rebar),
      .sig_cle(cle),
      .sig_cebar(cebar),
      .sig_webar(webar)
   );

endmodule 

module arriav_hps_interface_peripheral_nand (
   input  wire [7:0] adq_in,
   input  wire [3:0] rdy_busy,
   output wire       wpbar,
   output wire [7:0] adq_out,
   output wire       ale,
   output wire       adq_oe,
   output wire       rebar,
   output wire       cle,
   output wire [3:0] cebar,
   output wire       webar
);

   nand_bfm nand_inst (
      .sig_adq_in(adq_in),
      .sig_rdy_busy(rdy_busy),
      .sig_wpbar(wpbar),
      .sig_adq_out(adq_out),
      .sig_ale(ale),
      .sig_adq_oe(adq_oe),
      .sig_rebar(rebar),
      .sig_cle(cle),
      .sig_cebar(cebar),
      .sig_webar(webar)
   );

endmodule 