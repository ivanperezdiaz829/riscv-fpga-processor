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


module mpu_events_bfm
(
   sig_eventi,
   sig_evento,
   sig_standbywfe,
   sig_standbywfi
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_eventi;
   output sig_evento;
   output [1 : 0] sig_standbywfe;
   output [1 : 0] sig_standbywfi;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_eventi_t;
   typedef logic ROLE_evento_t;
   typedef logic [1 : 0] ROLE_standbywfe_t;
   typedef logic [1 : 0] ROLE_standbywfi_t;

   logic [0 : 0] eventi_in;
   logic [0 : 0] eventi_local;
   reg evento_temp;
   reg evento_out;
   reg [1 : 0] standbywfe_temp;
   reg [1 : 0] standbywfe_out;
   reg [1 : 0] standbywfi_temp;
   reg [1 : 0] standbywfi_out;

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
   
   event signal_input_eventi_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // eventi
   // -------------------------------------------------------
   function automatic ROLE_eventi_t get_eventi();
   
      // Gets the eventi input value.
      $sformat(message, "%m: called get_eventi");
      print(VERBOSITY_DEBUG, message);
      return eventi_in;
      
   endfunction

   // -------------------------------------------------------
   // evento
   // -------------------------------------------------------

   function automatic void set_evento (
      ROLE_evento_t new_value
   );
      // Drive the new value to evento.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      evento_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // standbywfe
   // -------------------------------------------------------

   function automatic void set_standbywfe (
      ROLE_standbywfe_t new_value
   );
      // Drive the new value to standbywfe.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      standbywfe_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // standbywfi
   // -------------------------------------------------------

   function automatic void set_standbywfi (
      ROLE_standbywfi_t new_value
   );
      // Drive the new value to standbywfi.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      standbywfi_temp = new_value;
   endfunction

   assign eventi_in = sig_eventi;
   assign sig_evento = evento_temp;
   assign sig_standbywfe = standbywfe_temp;
   assign sig_standbywfi = standbywfi_temp;


   always @(eventi_in) begin
      if (eventi_local != eventi_in)
         -> signal_input_eventi_change;
      eventi_local = eventi_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_mpu_event_standby (
	input wire			eventi,
	output wire			evento,
	output wire [1:0]	standbywfe,
	output wire [1:0] standbywfi
);

	mpu_events_bfm h2f_mpu_events (
		.sig_eventi(eventi),
      .sig_standbywfi(standbywfi),
      .sig_evento(evento),
      .sig_standbywfe(standbywfe)
	);

endmodule 

module arriav_hps_interface_mpu_event_standby (
	input wire			eventi,
	output wire			evento,
	output wire [1:0]	standbywfe,
	output wire [1:0] standbywfi
);

	mpu_events_bfm h2f_mpu_events (
		.sig_eventi(eventi),
      .sig_standbywfi(standbywfi),
      .sig_evento(evento),
      .sig_standbywfe(standbywfe)
	);

endmodule 
