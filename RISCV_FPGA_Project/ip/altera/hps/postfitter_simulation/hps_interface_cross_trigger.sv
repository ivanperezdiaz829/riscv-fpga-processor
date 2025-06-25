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


module cti_bfm
(
   sig_trig_in,
   sig_trig_outack,
   sig_clk_en,
   sig_trig_inack,
   sig_trig_out,
   sig_asicctl,
   sig_clk
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [7 : 0] sig_trig_in;
   input [7 : 0] sig_trig_outack;
   input sig_clk_en;
   output [7 : 0] sig_trig_inack;
   output [7 : 0] sig_trig_out;
   output [7 : 0] sig_asicctl;
   input sig_clk;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [7 : 0] ROLE_trig_in_t;
   typedef logic [7 : 0] ROLE_trig_outack_t;
   typedef logic ROLE_clk_en_t;
   typedef logic [7 : 0] ROLE_trig_inack_t;
   typedef logic [7 : 0] ROLE_trig_out_t;
   typedef logic [7 : 0] ROLE_asicctl_t;
   typedef logic ROLE_clk_t;

   logic [7 : 0] trig_in_in;
   logic [7 : 0] trig_in_local;
   logic [7 : 0] trig_outack_in;
   logic [7 : 0] trig_outack_local;
   logic [0 : 0] clk_en_in;
   logic [0 : 0] clk_en_local;
   reg [7 : 0] trig_inack_temp;
   reg [7 : 0] trig_inack_out;
   reg [7 : 0] trig_out_temp;
   reg [7 : 0] trig_out_out;
   reg [7 : 0] asicctl_temp;
   reg [7 : 0] asicctl_out;
   logic [0 : 0] clk_in;
   logic [0 : 0] clk_local;

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
   
   event signal_input_trig_in_change;
   event signal_input_trig_outack_change;
   event signal_input_clk_en_change;
   event signal_input_clk_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // trig_in
   // -------------------------------------------------------
   function automatic ROLE_trig_in_t get_trig_in();
   
      // Gets the trig_in input value.
      $sformat(message, "%m: called get_trig_in");
      print(VERBOSITY_DEBUG, message);
      return trig_in_in;
      
   endfunction

   // -------------------------------------------------------
   // trig_outack
   // -------------------------------------------------------
   function automatic ROLE_trig_outack_t get_trig_outack();
   
      // Gets the trig_outack input value.
      $sformat(message, "%m: called get_trig_outack");
      print(VERBOSITY_DEBUG, message);
      return trig_outack_in;
      
   endfunction

   // -------------------------------------------------------
   // clk_en
   // -------------------------------------------------------
   function automatic ROLE_clk_en_t get_clk_en();
   
      // Gets the clk_en input value.
      $sformat(message, "%m: called get_clk_en");
      print(VERBOSITY_DEBUG, message);
      return clk_en_in;
      
   endfunction

   // -------------------------------------------------------
   // trig_inack
   // -------------------------------------------------------

   function automatic void set_trig_inack (
      ROLE_trig_inack_t new_value
   );
      // Drive the new value to trig_inack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      trig_inack_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // trig_out
   // -------------------------------------------------------

   function automatic void set_trig_out (
      ROLE_trig_out_t new_value
   );
      // Drive the new value to trig_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      trig_out_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // asicctl
   // -------------------------------------------------------

   function automatic void set_asicctl (
      ROLE_asicctl_t new_value
   );
      // Drive the new value to asicctl.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      asicctl_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // clk
   // -------------------------------------------------------
   function automatic ROLE_clk_t get_clk();
   
      // Gets the clk input value.
      $sformat(message, "%m: called get_clk");
      print(VERBOSITY_DEBUG, message);
      return clk_in;
      
   endfunction

   assign trig_in_in = sig_trig_in;
   assign trig_outack_in = sig_trig_outack;
   assign clk_en_in = sig_clk_en;
   assign sig_trig_inack = trig_inack_temp;
   assign sig_trig_out = trig_out_temp;
   assign sig_asicctl = asicctl_temp;
   assign clk_in = sig_clk;


   always @(trig_in_in) begin
      if (trig_in_local != trig_in_in)
         -> signal_input_trig_in_change;
      trig_in_local = trig_in_in;
   end
   
   always @(trig_outack_in) begin
      if (trig_outack_local != trig_outack_in)
         -> signal_input_trig_outack_change;
      trig_outack_local = trig_outack_in;
   end
   
   always @(clk_en_in) begin
      if (clk_en_local != clk_en_in)
         -> signal_input_clk_en_change;
      clk_en_local = clk_en_in;
   end
   
   always @(clk_in) begin
      if (clk_local != clk_in)
         -> signal_input_clk_change;
      clk_local = clk_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_cross_trigger (
   input  wire [7:0] trig_in,
   input  wire [7:0] trig_outack,
   input  wire       clk,
   input  wire       clk_en,
   output wire [7:0] trig_inack,
   output wire [7:0] trig_out,
   output wire [7:0] asicctl,
   output wire       fake_dout
);

   assign fake_dout = 1'b0;

   cti_bfm h2f_cti (
      .sig_clk(clk),
      .sig_trig_in(trig_in),
      .sig_trig_inack(trig_inack),
      .sig_trig_out(trig_out),
      .sig_trig_outack(trig_outack),
      .sig_asicctl(asicctl),
      .sig_clk_en(clk_en)
   );

endmodule 

module arriav_hps_interface_cross_trigger (
   input  wire [7:0] trig_in,
   input  wire [7:0] trig_outack,
   input  wire       clk,
   input  wire       clk_en,
   output wire [7:0] trig_inack,
   output wire [7:0] trig_out,
   output wire [7:0] asicctl,
   output wire       fake_dout
);

   assign fake_dout = 1'b0;

   cti_bfm h2f_cti (
      .sig_clk(clk),
      .sig_trig_in(trig_in),
      .sig_trig_inack(trig_inack),
      .sig_trig_out(trig_out),
      .sig_trig_outack(trig_outack),
      .sig_asicctl(asicctl),
      .sig_clk_en(clk_en)
   );

endmodule 