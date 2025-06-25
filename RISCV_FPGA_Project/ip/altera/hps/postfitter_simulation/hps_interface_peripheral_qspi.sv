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


module qspi_bfm
(
   sig_mi0,
   sig_mi1,
   sig_mi2,
   sig_mi3,
   sig_mo0,
   sig_mo1,
   sig_mo2_wpn,
   sig_mo3_hold,
   sig_n_mo_en,
   sig_n_ss_out,
   sig_sclk_out
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_mi0;
   input sig_mi1;
   input sig_mi2;
   input sig_mi3;
   output sig_mo0;
   output sig_mo1;
   output sig_mo2_wpn;
   output sig_mo3_hold;
   output [3 : 0] sig_n_mo_en;
   output [3 : 0] sig_n_ss_out;
   output sig_sclk_out;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_mi0_t;
   typedef logic ROLE_mi1_t;
   typedef logic ROLE_mi2_t;
   typedef logic ROLE_mi3_t;
   typedef logic ROLE_mo0_t;
   typedef logic ROLE_mo1_t;
   typedef logic ROLE_mo2_wpn_t;
   typedef logic ROLE_mo3_hold_t;
   typedef logic [3 : 0] ROLE_n_mo_en_t;
   typedef logic [3 : 0] ROLE_n_ss_out_t;
   typedef logic ROLE_sclk_out_t;

   logic [0 : 0] mi0_in;
   logic [0 : 0] mi0_local;
   logic [0 : 0] mi1_in;
   logic [0 : 0] mi1_local;
   logic [0 : 0] mi2_in;
   logic [0 : 0] mi2_local;
   logic [0 : 0] mi3_in;
   logic [0 : 0] mi3_local;
   reg mo0_temp;
   reg mo0_out;
   reg mo1_temp;
   reg mo1_out;
   reg mo2_wpn_temp;
   reg mo2_wpn_out;
   reg mo3_hold_temp;
   reg mo3_hold_out;
   reg [3 : 0] n_mo_en_temp;
   reg [3 : 0] n_mo_en_out;
   reg [3 : 0] n_ss_out_temp;
   reg [3 : 0] n_ss_out_out;
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
   
   event signal_input_mi0_change;
   event signal_input_mi1_change;
   event signal_input_mi2_change;
   event signal_input_mi3_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // mi0
   // -------------------------------------------------------
   function automatic ROLE_mi0_t get_mi0();
   
      // Gets the mi0 input value.
      $sformat(message, "%m: called get_mi0");
      print(VERBOSITY_DEBUG, message);
      return mi0_in;
      
   endfunction

   // -------------------------------------------------------
   // mi1
   // -------------------------------------------------------
   function automatic ROLE_mi1_t get_mi1();
   
      // Gets the mi1 input value.
      $sformat(message, "%m: called get_mi1");
      print(VERBOSITY_DEBUG, message);
      return mi1_in;
      
   endfunction

   // -------------------------------------------------------
   // mi2
   // -------------------------------------------------------
   function automatic ROLE_mi2_t get_mi2();
   
      // Gets the mi2 input value.
      $sformat(message, "%m: called get_mi2");
      print(VERBOSITY_DEBUG, message);
      return mi2_in;
      
   endfunction

   // -------------------------------------------------------
   // mi3
   // -------------------------------------------------------
   function automatic ROLE_mi3_t get_mi3();
   
      // Gets the mi3 input value.
      $sformat(message, "%m: called get_mi3");
      print(VERBOSITY_DEBUG, message);
      return mi3_in;
      
   endfunction

   // -------------------------------------------------------
   // mo0
   // -------------------------------------------------------

   function automatic void set_mo0 (
      ROLE_mo0_t new_value
   );
      // Drive the new value to mo0.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      mo0_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // mo1
   // -------------------------------------------------------

   function automatic void set_mo1 (
      ROLE_mo1_t new_value
   );
      // Drive the new value to mo1.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      mo1_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // mo2_wpn
   // -------------------------------------------------------

   function automatic void set_mo2_wpn (
      ROLE_mo2_wpn_t new_value
   );
      // Drive the new value to mo2_wpn.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      mo2_wpn_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // mo3_hold
   // -------------------------------------------------------

   function automatic void set_mo3_hold (
      ROLE_mo3_hold_t new_value
   );
      // Drive the new value to mo3_hold.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      mo3_hold_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // n_mo_en
   // -------------------------------------------------------

   function automatic void set_n_mo_en (
      ROLE_n_mo_en_t new_value
   );
      // Drive the new value to n_mo_en.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      n_mo_en_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // n_ss_out
   // -------------------------------------------------------

   function automatic void set_n_ss_out (
      ROLE_n_ss_out_t new_value
   );
      // Drive the new value to n_ss_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      n_ss_out_temp = new_value;
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

   assign mi0_in = sig_mi0;
   assign mi1_in = sig_mi1;
   assign mi2_in = sig_mi2;
   assign mi3_in = sig_mi3;
   assign sig_mo0 = mo0_temp;
   assign sig_mo1 = mo1_temp;
   assign sig_mo2_wpn = mo2_wpn_temp;
   assign sig_mo3_hold = mo3_hold_temp;
   assign sig_n_mo_en = n_mo_en_temp;
   assign sig_n_ss_out = n_ss_out_temp;
   assign sig_sclk_out = sclk_out_temp;


   always @(mi0_in) begin
      if (mi0_local != mi0_in)
         -> signal_input_mi0_change;
      mi0_local = mi0_in;
   end
   
   always @(mi1_in) begin
      if (mi1_local != mi1_in)
         -> signal_input_mi1_change;
      mi1_local = mi1_in;
   end
   
   always @(mi2_in) begin
      if (mi2_local != mi2_in)
         -> signal_input_mi2_change;
      mi2_local = mi2_in;
   end
   
   always @(mi3_in) begin
      if (mi3_local != mi3_in)
         -> signal_input_mi3_change;
      mi3_local = mi3_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_qspi (
   input  wire       mi0,
   input  wire       mi1,
   input  wire       mi2,
   input  wire       mi3,
   output wire       mo0,
   output wire       mo1,
   output wire       mo2_wpn,
   output wire       mo3_hold,
   output wire [3:0] n_mo_en,
   output wire [3:0] n_ss_out,
   output wire       sclk_out
);

   qspi_bfm qspi_inst (
      .sig_mi0(mi0),
      .sig_mi1(mi1),
      .sig_mi2(mi2),
      .sig_mi3(mi3),
      .sig_mo0(mo0),
      .sig_mo1(mo1),
      .sig_mo2_wpn(mo2_wpn),
      .sig_mo3_hold(mo3_hold),
      .sig_n_mo_en(n_mo_en),
      .sig_n_ss_out(n_ss_out),
      .sig_sclk_out(sclk_out)
   );

endmodule 

module arriav_hps_interface_peripheral_qspi (
   input  wire       mi0,
   input  wire       mi1,
   input  wire       mi2,
   input  wire       mi3,
   output wire       mo0,
   output wire       mo1,
   output wire       mo2_wpn,
   output wire       mo3_hold,
   output wire [3:0] n_mo_en,
   output wire [3:0] n_ss_out,
   output wire       sclk_out
);

   qspi_bfm qspi_inst (
      .sig_mi0(mi0),
      .sig_mi1(mi1),
      .sig_mi2(mi2),
      .sig_mi3(mi3),
      .sig_mo0(mo0),
      .sig_mo1(mo1),
      .sig_mo2_wpn(mo2_wpn),
      .sig_mo3_hold(mo3_hold),
      .sig_n_mo_en(n_mo_en),
      .sig_n_ss_out(n_ss_out),
      .sig_sclk_out(sclk_out)
   );

endmodule 
