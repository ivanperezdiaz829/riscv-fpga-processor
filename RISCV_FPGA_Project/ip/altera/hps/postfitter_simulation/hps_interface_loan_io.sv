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


module loanio_bfm
(
   sig_loanio_out,
   sig_loanio_oe,
   sig_loanio_in
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [70 : 0] sig_loanio_out;
   input [70 : 0] sig_loanio_oe;
   output [70 : 0] sig_loanio_in;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [70 : 0] ROLE_loanio_out_t;
   typedef logic [70 : 0] ROLE_loanio_oe_t;
   typedef logic [70 : 0] ROLE_loanio_in_t;

   logic [70 : 0] loanio_out_in;
   logic [70 : 0] loanio_out_local;
   logic [70 : 0] loanio_oe_in;
   logic [70 : 0] loanio_oe_local;
   reg [70 : 0] loanio_in_temp;
   reg [70 : 0] loanio_in_out;

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
   
   event signal_input_loanio_out_change;
   event signal_input_loanio_oe_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // loanio_out
   // -------------------------------------------------------
   function automatic ROLE_loanio_out_t get_loanio_out();
   
      // Gets the loanio_out input value.
      $sformat(message, "%m: called get_loanio_out");
      print(VERBOSITY_DEBUG, message);
      return loanio_out_in;
      
   endfunction

   // -------------------------------------------------------
   // loanio_oe
   // -------------------------------------------------------
   function automatic ROLE_loanio_oe_t get_loanio_oe();
   
      // Gets the loanio_oe input value.
      $sformat(message, "%m: called get_loanio_oe");
      print(VERBOSITY_DEBUG, message);
      return loanio_oe_in;
      
   endfunction

   // -------------------------------------------------------
   // loanio_in
   // -------------------------------------------------------

   function automatic void set_loanio_in (
      ROLE_loanio_in_t new_value
   );
      // Drive the new value to loanio_in.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      loanio_in_temp = new_value;
   endfunction

   assign loanio_out_in = sig_loanio_out;
   assign loanio_oe_in = sig_loanio_oe;
   assign sig_loanio_in = loanio_in_temp;


   always @(loanio_out_in) begin
      if (loanio_out_local != loanio_out_in)
         -> signal_input_loanio_out_change;
      loanio_out_local = loanio_out_in;
   end
   
   always @(loanio_oe_in) begin
      if (loanio_oe_local != loanio_oe_in)
         -> signal_input_loanio_oe_change;
      loanio_oe_local = loanio_oe_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_loan_io (
   input  wire [70:0] loanio_out,
   input  wire [70:0] loanio_oe,
   output wire [70:0] loanio_in,
   output wire [13:0] input_only,
   output wire        fake_dout,
   input  wire [70:0] gpio_in,
   output wire [70:0] gpio_oe,
   output wire [70:0] gpio_out
);
   
   assign input_only = 14'b0;
   assign fake_dout = 1'b0;
   assign gpio_oe = 71'b0;
   assign gpio_out = 71'b0;
   
   loanio_bfm loanio_inst (
      .sig_loanio_out(loanio_out),
      .sig_loanio_oe(loanio_oe),
      .sig_loanio_in(loanio_in)
   );

endmodule 

module arriav_hps_interface_loan_io (
   input  wire [70:0] loanio_out,
   input  wire [70:0] loanio_oe,
   output wire [70:0] loanio_in,
   output wire [13:0] input_only,
   output wire        fake_dout,
   input  wire [70:0] gpio_in,
   output wire [70:0] gpio_oe,
   output wire [70:0] gpio_out
);
   
   assign input_only = 14'b0;
   assign fake_dout = 1'b0;
   assign gpio_oe = 71'b0;
   assign gpio_out = 71'b0;
   
   loanio_bfm loanio_inst (
      .sig_loanio_out(loanio_out),
      .sig_loanio_oe(loanio_oe),
      .sig_loanio_in(loanio_in)
   );

endmodule 
