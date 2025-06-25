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


module tpiu_bfm
(
   sig_traceclk_ctl,
   sig_trace_data
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_traceclk_ctl;
   output [31 : 0] sig_trace_data;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_traceclk_ctl_t;
   typedef logic [31 : 0] ROLE_trace_data_t;

   logic [0 : 0] traceclk_ctl_in;
   logic [0 : 0] traceclk_ctl_local;
   reg [31 : 0] trace_data_temp;
   reg [31 : 0] trace_data_out;

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
   
   event signal_input_traceclk_ctl_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // traceclk_ctl
   // -------------------------------------------------------
   function automatic ROLE_traceclk_ctl_t get_traceclk_ctl();
   
      // Gets the traceclk_ctl input value.
      $sformat(message, "%m: called get_traceclk_ctl");
      print(VERBOSITY_DEBUG, message);
      return traceclk_ctl_in;
      
   endfunction

   // -------------------------------------------------------
   // trace_data
   // -------------------------------------------------------

   function automatic void set_trace_data (
      ROLE_trace_data_t new_value
   );
      // Drive the new value to trace_data.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      trace_data_temp = new_value;
   endfunction

   assign traceclk_ctl_in = sig_traceclk_ctl;
   assign sig_trace_data = trace_data_temp;


   always @(traceclk_ctl_in) begin
      if (traceclk_ctl_local != traceclk_ctl_in)
         -> signal_input_traceclk_ctl_change;
      traceclk_ctl_local = traceclk_ctl_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_tpiu_trace (
   output wire [31:0] trace_data,
   input  wire        traceclkin,
   output wire        traceclk,
   input  wire        traceclk_ctl
);

   tpiu_bfm h2f_tpiu (
      .sig_trace_data(trace_data),
      .sig_traceclk_ctl(traceclk_ctl)
   );

endmodule 

module arriav_hps_interface_tpiu_trace (
   output wire [31:0] trace_data,
   input  wire        traceclkin,
   output wire        traceclk,
   input  wire        traceclk_ctl
);

   tpiu_bfm h2f_tpiu (
      .sig_trace_data(trace_data),
      .sig_traceclk_ctl(traceclk_ctl)
   );

endmodule 