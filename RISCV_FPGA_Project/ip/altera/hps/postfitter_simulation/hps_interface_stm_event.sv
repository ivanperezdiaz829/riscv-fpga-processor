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


module stm_events_bfm
(
   sig_stm_events
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [27 : 0] sig_stm_events;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [27 : 0] ROLE_stm_events_t;

   logic [27 : 0] stm_events_in;
   logic [27 : 0] stm_events_local;

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
   
   event signal_input_stm_events_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // stm_events
   // -------------------------------------------------------
   function automatic ROLE_stm_events_t get_stm_events();
   
      // Gets the stm_events input value.
      $sformat(message, "%m: called get_stm_events");
      print(VERBOSITY_DEBUG, message);
      return stm_events_in;
      
   endfunction

   assign stm_events_in = sig_stm_events;


   always @(stm_events_in) begin
      if (stm_events_local != stm_events_in)
         -> signal_input_stm_events_change;
      stm_events_local = stm_events_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_stm_event (
   input  wire [27:0] stm_event,
   output wire        fake_dout
);

   assign fake_dout = 1'b0;
   
   stm_events_bfm f2h_stm_hw_events (
      .sig_stm_events(stm_event)
   );
   
endmodule 

module arriav_hps_interface_stm_event (
   input  wire [27:0] stm_event,
   output wire        fake_dout
);

   assign fake_dout = 1'b0;
   
   stm_events_bfm f2h_stm_hw_events (
      .sig_stm_events(stm_event)
   );
   
endmodule 