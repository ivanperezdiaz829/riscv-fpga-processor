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


module h2f_warm_reset_handshake_bfm
(
   sig_h2f_pending_rst_req_n,
   sig_f2h_pending_rst_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   output sig_h2f_pending_rst_req_n;
   input sig_f2h_pending_rst_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_h2f_pending_rst_req_n_t;
   typedef logic ROLE_f2h_pending_rst_ack_t;

   reg h2f_pending_rst_req_n_temp;
   reg h2f_pending_rst_req_n_out;
   logic [0 : 0] f2h_pending_rst_ack_in;
   logic [0 : 0] f2h_pending_rst_ack_local;

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
   
   event signal_input_f2h_pending_rst_ack_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // h2f_pending_rst_req_n
   // -------------------------------------------------------

   function automatic void set_h2f_pending_rst_req_n (
      ROLE_h2f_pending_rst_req_n_t new_value
   );
      // Drive the new value to h2f_pending_rst_req_n.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      h2f_pending_rst_req_n_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // f2h_pending_rst_ack
   // -------------------------------------------------------
   function automatic ROLE_f2h_pending_rst_ack_t get_f2h_pending_rst_ack();
   
      // Gets the f2h_pending_rst_ack input value.
      $sformat(message, "%m: called get_f2h_pending_rst_ack");
      print(VERBOSITY_DEBUG, message);
      return f2h_pending_rst_ack_in;
      
   endfunction

   assign sig_h2f_pending_rst_req_n = h2f_pending_rst_req_n_temp;
   assign f2h_pending_rst_ack_in = sig_f2h_pending_rst_ack;


   always @(f2h_pending_rst_ack_in) begin
      if (f2h_pending_rst_ack_local != f2h_pending_rst_ack_in)
         -> signal_input_f2h_pending_rst_ack_change;
      f2h_pending_rst_ack_local = f2h_pending_rst_ack_in;
   end
   


// synthesis translate_on

endmodule 

module f2h_cold_reset_req_bfm
(
   sig_f2h_cold_rst_req_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_f2h_cold_rst_req_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_f2h_cold_rst_req_n_t;

   logic [0 : 0] f2h_cold_rst_req_n_in;
   logic [0 : 0] f2h_cold_rst_req_n_local;

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
   
   event signal_input_f2h_cold_rst_req_n_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // f2h_cold_rst_req_n
   // -------------------------------------------------------
   function automatic ROLE_f2h_cold_rst_req_n_t get_f2h_cold_rst_req_n();
   
      // Gets the f2h_cold_rst_req_n input value.
      $sformat(message, "%m: called get_f2h_cold_rst_req_n");
      print(VERBOSITY_DEBUG, message);
      return f2h_cold_rst_req_n_in;
      
   endfunction

   assign f2h_cold_rst_req_n_in = sig_f2h_cold_rst_req_n;


   always @(f2h_cold_rst_req_n_in) begin
      if (f2h_cold_rst_req_n_local != f2h_cold_rst_req_n_in)
         -> signal_input_f2h_cold_rst_req_n_change;
      f2h_cold_rst_req_n_local = f2h_cold_rst_req_n_in;
   end
   


// synthesis translate_on

endmodule 

module f2h_debug_reset_req_bfm
(
   sig_f2h_dbg_rst_req_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_f2h_dbg_rst_req_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_f2h_dbg_rst_req_n_t;

   logic [0 : 0] f2h_dbg_rst_req_n_in;
   logic [0 : 0] f2h_dbg_rst_req_n_local;

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
   
   event signal_input_f2h_dbg_rst_req_n_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // f2h_dbg_rst_req_n
   // -------------------------------------------------------
   function automatic ROLE_f2h_dbg_rst_req_n_t get_f2h_dbg_rst_req_n();
   
      // Gets the f2h_dbg_rst_req_n input value.
      $sformat(message, "%m: called get_f2h_dbg_rst_req_n");
      print(VERBOSITY_DEBUG, message);
      return f2h_dbg_rst_req_n_in;
      
   endfunction

   assign f2h_dbg_rst_req_n_in = sig_f2h_dbg_rst_req_n;


   always @(f2h_dbg_rst_req_n_in) begin
      if (f2h_dbg_rst_req_n_local != f2h_dbg_rst_req_n_in)
         -> signal_input_f2h_dbg_rst_req_n_change;
      f2h_dbg_rst_req_n_local = f2h_dbg_rst_req_n_in;
   end
   


// synthesis translate_on

endmodule

module f2h_warm_reset_req_bfm
(
   sig_f2h_warm_rst_req_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_f2h_warm_rst_req_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_f2h_warm_rst_req_n_t;

   logic [0 : 0] f2h_warm_rst_req_n_in;
   logic [0 : 0] f2h_warm_rst_req_n_local;

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
   
   event signal_input_f2h_warm_rst_req_n_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // f2h_warm_rst_req_n
   // -------------------------------------------------------
   function automatic ROLE_f2h_warm_rst_req_n_t get_f2h_warm_rst_req_n();
   
      // Gets the f2h_warm_rst_req_n input value.
      $sformat(message, "%m: called get_f2h_warm_rst_req_n");
      print(VERBOSITY_DEBUG, message);
      return f2h_warm_rst_req_n_in;
      
   endfunction

   assign f2h_warm_rst_req_n_in = sig_f2h_warm_rst_req_n;


   always @(f2h_warm_rst_req_n_in) begin
      if (f2h_warm_rst_req_n_local != f2h_warm_rst_req_n_in)
         -> signal_input_f2h_warm_rst_req_n_change;
      f2h_warm_rst_req_n_local = f2h_warm_rst_req_n_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel0_bfm
(
   sig_channel0_req,
   sig_channel0_single,
   sig_channel0_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel0_req;
   input sig_channel0_single;
   output sig_channel0_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel0_req_t;
   typedef logic ROLE_channel0_single_t;
   typedef logic ROLE_channel0_xx_ack_t;

   logic [0 : 0] channel0_req_in;
   logic [0 : 0] channel0_req_local;
   logic [0 : 0] channel0_single_in;
   logic [0 : 0] channel0_single_local;
   reg channel0_xx_ack_temp;
   reg channel0_xx_ack_out;

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
   
   event signal_input_channel0_req_change;
   event signal_input_channel0_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel0_req
   // -------------------------------------------------------
   function automatic ROLE_channel0_req_t get_channel0_req();
   
      // Gets the channel0_req input value.
      $sformat(message, "%m: called get_channel0_req");
      print(VERBOSITY_DEBUG, message);
      return channel0_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel0_single
   // -------------------------------------------------------
   function automatic ROLE_channel0_single_t get_channel0_single();
   
      // Gets the channel0_single input value.
      $sformat(message, "%m: called get_channel0_single");
      print(VERBOSITY_DEBUG, message);
      return channel0_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel0_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel0_xx_ack (
      ROLE_channel0_xx_ack_t new_value
   );
      // Drive the new value to channel0_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel0_xx_ack_temp = new_value;
   endfunction

   assign channel0_req_in = sig_channel0_req;
   assign channel0_single_in = sig_channel0_single;
   assign sig_channel0_xx_ack = channel0_xx_ack_temp;


   always @(channel0_req_in) begin
      if (channel0_req_local != channel0_req_in)
         -> signal_input_channel0_req_change;
      channel0_req_local = channel0_req_in;
   end
   
   always @(channel0_single_in) begin
      if (channel0_single_local != channel0_single_in)
         -> signal_input_channel0_single_change;
      channel0_single_local = channel0_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel1_bfm
(
   sig_channel1_req,
   sig_channel1_single,
   sig_channel1_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel1_req;
   input sig_channel1_single;
   output sig_channel1_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel1_req_t;
   typedef logic ROLE_channel1_single_t;
   typedef logic ROLE_channel1_xx_ack_t;

   logic [0 : 0] channel1_req_in;
   logic [0 : 0] channel1_req_local;
   logic [0 : 0] channel1_single_in;
   logic [0 : 0] channel1_single_local;
   reg channel1_xx_ack_temp;
   reg channel1_xx_ack_out;

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
   
   event signal_input_channel1_req_change;
   event signal_input_channel1_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel1_req
   // -------------------------------------------------------
   function automatic ROLE_channel1_req_t get_channel1_req();
   
      // Gets the channel1_req input value.
      $sformat(message, "%m: called get_channel1_req");
      print(VERBOSITY_DEBUG, message);
      return channel1_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel1_single
   // -------------------------------------------------------
   function automatic ROLE_channel1_single_t get_channel1_single();
   
      // Gets the channel1_single input value.
      $sformat(message, "%m: called get_channel1_single");
      print(VERBOSITY_DEBUG, message);
      return channel1_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel1_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel1_xx_ack (
      ROLE_channel1_xx_ack_t new_value
   );
      // Drive the new value to channel1_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel1_xx_ack_temp = new_value;
   endfunction

   assign channel1_req_in = sig_channel1_req;
   assign channel1_single_in = sig_channel1_single;
   assign sig_channel1_xx_ack = channel1_xx_ack_temp;


   always @(channel1_req_in) begin
      if (channel1_req_local != channel1_req_in)
         -> signal_input_channel1_req_change;
      channel1_req_local = channel1_req_in;
   end
   
   always @(channel1_single_in) begin
      if (channel1_single_local != channel1_single_in)
         -> signal_input_channel1_single_change;
      channel1_single_local = channel1_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel2_bfm
(
   sig_channel2_req,
   sig_channel2_single,
   sig_channel2_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel2_req;
   input sig_channel2_single;
   output sig_channel2_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel2_req_t;
   typedef logic ROLE_channel2_single_t;
   typedef logic ROLE_channel2_xx_ack_t;

   logic [0 : 0] channel2_req_in;
   logic [0 : 0] channel2_req_local;
   logic [0 : 0] channel2_single_in;
   logic [0 : 0] channel2_single_local;
   reg channel2_xx_ack_temp;
   reg channel2_xx_ack_out;

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
   
   event signal_input_channel2_req_change;
   event signal_input_channel2_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel2_req
   // -------------------------------------------------------
   function automatic ROLE_channel2_req_t get_channel2_req();
   
      // Gets the channel2_req input value.
      $sformat(message, "%m: called get_channel2_req");
      print(VERBOSITY_DEBUG, message);
      return channel2_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel2_single
   // -------------------------------------------------------
   function automatic ROLE_channel2_single_t get_channel2_single();
   
      // Gets the channel2_single input value.
      $sformat(message, "%m: called get_channel2_single");
      print(VERBOSITY_DEBUG, message);
      return channel2_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel2_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel2_xx_ack (
      ROLE_channel2_xx_ack_t new_value
   );
      // Drive the new value to channel2_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel2_xx_ack_temp = new_value;
   endfunction

   assign channel2_req_in = sig_channel2_req;
   assign channel2_single_in = sig_channel2_single;
   assign sig_channel2_xx_ack = channel2_xx_ack_temp;


   always @(channel2_req_in) begin
      if (channel2_req_local != channel2_req_in)
         -> signal_input_channel2_req_change;
      channel2_req_local = channel2_req_in;
   end
   
   always @(channel2_single_in) begin
      if (channel2_single_local != channel2_single_in)
         -> signal_input_channel2_single_change;
      channel2_single_local = channel2_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel3_bfm
(
   sig_channel3_req,
   sig_channel3_single,
   sig_channel3_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel3_req;
   input sig_channel3_single;
   output sig_channel3_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel3_req_t;
   typedef logic ROLE_channel3_single_t;
   typedef logic ROLE_channel3_xx_ack_t;

   logic [0 : 0] channel3_req_in;
   logic [0 : 0] channel3_req_local;
   logic [0 : 0] channel3_single_in;
   logic [0 : 0] channel3_single_local;
   reg channel3_xx_ack_temp;
   reg channel3_xx_ack_out;

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
   
   event signal_input_channel3_req_change;
   event signal_input_channel3_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel3_req
   // -------------------------------------------------------
   function automatic ROLE_channel3_req_t get_channel3_req();
   
      // Gets the channel3_req input value.
      $sformat(message, "%m: called get_channel3_req");
      print(VERBOSITY_DEBUG, message);
      return channel3_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel3_single
   // -------------------------------------------------------
   function automatic ROLE_channel3_single_t get_channel3_single();
   
      // Gets the channel3_single input value.
      $sformat(message, "%m: called get_channel3_single");
      print(VERBOSITY_DEBUG, message);
      return channel3_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel3_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel3_xx_ack (
      ROLE_channel3_xx_ack_t new_value
   );
      // Drive the new value to channel3_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel3_xx_ack_temp = new_value;
   endfunction

   assign channel3_req_in = sig_channel3_req;
   assign channel3_single_in = sig_channel3_single;
   assign sig_channel3_xx_ack = channel3_xx_ack_temp;


   always @(channel3_req_in) begin
      if (channel3_req_local != channel3_req_in)
         -> signal_input_channel3_req_change;
      channel3_req_local = channel3_req_in;
   end
   
   always @(channel3_single_in) begin
      if (channel3_single_local != channel3_single_in)
         -> signal_input_channel3_single_change;
      channel3_single_local = channel3_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel4_bfm
(
   sig_channel4_req,
   sig_channel4_single,
   sig_channel4_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel4_req;
   input sig_channel4_single;
   output sig_channel4_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel4_req_t;
   typedef logic ROLE_channel4_single_t;
   typedef logic ROLE_channel4_xx_ack_t;

   logic [0 : 0] channel4_req_in;
   logic [0 : 0] channel4_req_local;
   logic [0 : 0] channel4_single_in;
   logic [0 : 0] channel4_single_local;
   reg channel4_xx_ack_temp;
   reg channel4_xx_ack_out;

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
   
   event signal_input_channel4_req_change;
   event signal_input_channel4_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel4_req
   // -------------------------------------------------------
   function automatic ROLE_channel4_req_t get_channel4_req();
   
      // Gets the channel4_req input value.
      $sformat(message, "%m: called get_channel4_req");
      print(VERBOSITY_DEBUG, message);
      return channel4_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel4_single
   // -------------------------------------------------------
   function automatic ROLE_channel4_single_t get_channel4_single();
   
      // Gets the channel4_single input value.
      $sformat(message, "%m: called get_channel4_single");
      print(VERBOSITY_DEBUG, message);
      return channel4_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel4_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel4_xx_ack (
      ROLE_channel4_xx_ack_t new_value
   );
      // Drive the new value to channel4_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel4_xx_ack_temp = new_value;
   endfunction

   assign channel4_req_in = sig_channel4_req;
   assign channel4_single_in = sig_channel4_single;
   assign sig_channel4_xx_ack = channel4_xx_ack_temp;


   always @(channel4_req_in) begin
      if (channel4_req_local != channel4_req_in)
         -> signal_input_channel4_req_change;
      channel4_req_local = channel4_req_in;
   end
   
   always @(channel4_single_in) begin
      if (channel4_single_local != channel4_single_in)
         -> signal_input_channel4_single_change;
      channel4_single_local = channel4_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel5_bfm
(
   sig_channel5_req,
   sig_channel5_single,
   sig_channel5_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel5_req;
   input sig_channel5_single;
   output sig_channel5_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel5_req_t;
   typedef logic ROLE_channel5_single_t;
   typedef logic ROLE_channel5_xx_ack_t;

   logic [0 : 0] channel5_req_in;
   logic [0 : 0] channel5_req_local;
   logic [0 : 0] channel5_single_in;
   logic [0 : 0] channel5_single_local;
   reg channel5_xx_ack_temp;
   reg channel5_xx_ack_out;

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
   
   event signal_input_channel5_req_change;
   event signal_input_channel5_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel5_req
   // -------------------------------------------------------
   function automatic ROLE_channel5_req_t get_channel5_req();
   
      // Gets the channel5_req input value.
      $sformat(message, "%m: called get_channel5_req");
      print(VERBOSITY_DEBUG, message);
      return channel5_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel5_single
   // -------------------------------------------------------
   function automatic ROLE_channel5_single_t get_channel5_single();
   
      // Gets the channel5_single input value.
      $sformat(message, "%m: called get_channel5_single");
      print(VERBOSITY_DEBUG, message);
      return channel5_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel5_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel5_xx_ack (
      ROLE_channel5_xx_ack_t new_value
   );
      // Drive the new value to channel5_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel5_xx_ack_temp = new_value;
   endfunction

   assign channel5_req_in = sig_channel5_req;
   assign channel5_single_in = sig_channel5_single;
   assign sig_channel5_xx_ack = channel5_xx_ack_temp;


   always @(channel5_req_in) begin
      if (channel5_req_local != channel5_req_in)
         -> signal_input_channel5_req_change;
      channel5_req_local = channel5_req_in;
   end
   
   always @(channel5_single_in) begin
      if (channel5_single_local != channel5_single_in)
         -> signal_input_channel5_single_change;
      channel5_single_local = channel5_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel6_bfm
(
   sig_channel6_req,
   sig_channel6_single,
   sig_channel6_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel6_req;
   input sig_channel6_single;
   output sig_channel6_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel6_req_t;
   typedef logic ROLE_channel6_single_t;
   typedef logic ROLE_channel6_xx_ack_t;

   logic [0 : 0] channel6_req_in;
   logic [0 : 0] channel6_req_local;
   logic [0 : 0] channel6_single_in;
   logic [0 : 0] channel6_single_local;
   reg channel6_xx_ack_temp;
   reg channel6_xx_ack_out;

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
   
   event signal_input_channel6_req_change;
   event signal_input_channel6_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel6_req
   // -------------------------------------------------------
   function automatic ROLE_channel6_req_t get_channel6_req();
   
      // Gets the channel6_req input value.
      $sformat(message, "%m: called get_channel6_req");
      print(VERBOSITY_DEBUG, message);
      return channel6_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel6_single
   // -------------------------------------------------------
   function automatic ROLE_channel6_single_t get_channel6_single();
   
      // Gets the channel6_single input value.
      $sformat(message, "%m: called get_channel6_single");
      print(VERBOSITY_DEBUG, message);
      return channel6_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel6_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel6_xx_ack (
      ROLE_channel6_xx_ack_t new_value
   );
      // Drive the new value to channel6_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel6_xx_ack_temp = new_value;
   endfunction

   assign channel6_req_in = sig_channel6_req;
   assign channel6_single_in = sig_channel6_single;
   assign sig_channel6_xx_ack = channel6_xx_ack_temp;


   always @(channel6_req_in) begin
      if (channel6_req_local != channel6_req_in)
         -> signal_input_channel6_req_change;
      channel6_req_local = channel6_req_in;
   end
   
   always @(channel6_single_in) begin
      if (channel6_single_local != channel6_single_in)
         -> signal_input_channel6_single_change;
      channel6_single_local = channel6_single_in;
   end
   


// synthesis translate_on

endmodule

module dma_channel7_bfm
(
   sig_channel7_req,
   sig_channel7_single,
   sig_channel7_xx_ack
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_channel7_req;
   input sig_channel7_single;
   output sig_channel7_xx_ack;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_channel7_req_t;
   typedef logic ROLE_channel7_single_t;
   typedef logic ROLE_channel7_xx_ack_t;

   logic [0 : 0] channel7_req_in;
   logic [0 : 0] channel7_req_local;
   logic [0 : 0] channel7_single_in;
   logic [0 : 0] channel7_single_local;
   reg channel7_xx_ack_temp;
   reg channel7_xx_ack_out;

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
   
   event signal_input_channel7_req_change;
   event signal_input_channel7_single_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // channel7_req
   // -------------------------------------------------------
   function automatic ROLE_channel7_req_t get_channel7_req();
   
      // Gets the channel7_req input value.
      $sformat(message, "%m: called get_channel7_req");
      print(VERBOSITY_DEBUG, message);
      return channel7_req_in;
      
   endfunction

   // -------------------------------------------------------
   // channel7_single
   // -------------------------------------------------------
   function automatic ROLE_channel7_single_t get_channel7_single();
   
      // Gets the channel7_single input value.
      $sformat(message, "%m: called get_channel7_single");
      print(VERBOSITY_DEBUG, message);
      return channel7_single_in;
      
   endfunction

   // -------------------------------------------------------
   // channel7_xx_ack
   // -------------------------------------------------------

   function automatic void set_channel7_xx_ack (
      ROLE_channel7_xx_ack_t new_value
   );
      // Drive the new value to channel7_xx_ack.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      channel7_xx_ack_temp = new_value;
   endfunction

   assign channel7_req_in = sig_channel7_req;
   assign channel7_single_in = sig_channel7_single;
   assign sig_channel7_xx_ack = channel7_xx_ack_temp;


   always @(channel7_req_in) begin
      if (channel7_req_local != channel7_req_in)
         -> signal_input_channel7_req_change;
      channel7_req_local = channel7_req_in;
   end
   
   always @(channel7_single_in) begin
      if (channel7_single_local != channel7_single_in)
         -> signal_input_channel7_single_change;
      channel7_single_local = channel7_single_in;
   end
   


// synthesis translate_on

endmodule

