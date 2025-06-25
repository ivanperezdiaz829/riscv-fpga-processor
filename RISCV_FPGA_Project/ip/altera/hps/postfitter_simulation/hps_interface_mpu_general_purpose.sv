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


module mpu_gp_bfm
(
   sig_gp_in,
   sig_gp_out
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [31 : 0] sig_gp_in;
   output [31 : 0] sig_gp_out;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [31 : 0] ROLE_gp_in_t;
   typedef logic [31 : 0] ROLE_gp_out_t;

   logic [31 : 0] gp_in_in;
   logic [31 : 0] gp_in_local;
   reg [31 : 0] gp_out_temp;
   reg [31 : 0] gp_out_out;

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
   
   event signal_input_gp_in_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // gp_in
   // -------------------------------------------------------
   function automatic ROLE_gp_in_t get_gp_in();
   
      // Gets the gp_in input value.
      $sformat(message, "%m: called get_gp_in");
      print(VERBOSITY_DEBUG, message);
      return gp_in_in;
      
   endfunction

   // -------------------------------------------------------
   // gp_out
   // -------------------------------------------------------

   function automatic void set_gp_out (
      ROLE_gp_out_t new_value
   );
      // Drive the new value to gp_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      gp_out_temp = new_value;
   endfunction

   assign gp_in_in = sig_gp_in;
   assign sig_gp_out = gp_out_temp;


   always @(gp_in_in) begin
      if (gp_in_local != gp_in_in)
         -> signal_input_gp_in_change;
      gp_in_local = gp_in_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_mpu_general_purpose (
	input  wire  [31:0]	gp_in,
	output wire  [31:0]	gp_out,
	output wire          fake_dout
);
   
   assign fake_dout = 1'b0;
   
	mpu_gp_bfm h2f_mpu_gp (
		.sig_gp_in(gp_in),
      .sig_gp_out(gp_out)
	);

endmodule 

module arriav_hps_interface_mpu_general_purpose (
	input  wire  [31:0]	gp_in,
	output wire  [31:0]	gp_out,
	output wire          fake_dout
);
   
   assign fake_dout = 1'b0;
   
	mpu_gp_bfm h2f_mpu_gp (
		.sig_gp_in(gp_in),
      .sig_gp_out(gp_out)
	);

endmodule 
