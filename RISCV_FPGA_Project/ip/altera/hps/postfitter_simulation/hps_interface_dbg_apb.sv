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


module debug_apb_bfm
(
   sig_PADDR,
   sig_PADDR31,
   sig_PENABLE,
   sig_PRDATA,
   sig_PREADY,
   sig_PSEL,
   sig_PSLVERR,
   sig_PWDATA,
   sig_PWRITE
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   output [17 : 0] sig_PADDR;
   output sig_PADDR31;
   output sig_PENABLE;
   input [31 : 0] sig_PRDATA;
   input sig_PREADY;
   output sig_PSEL;
   input sig_PSLVERR;
   output [31 : 0] sig_PWDATA;
   output sig_PWRITE;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [17 : 0] ROLE_PADDR_t;
   typedef logic ROLE_PADDR31_t;
   typedef logic ROLE_PENABLE_t;
   typedef logic [31 : 0] ROLE_PRDATA_t;
   typedef logic ROLE_PREADY_t;
   typedef logic ROLE_PSEL_t;
   typedef logic ROLE_PSLVERR_t;
   typedef logic [31 : 0] ROLE_PWDATA_t;
   typedef logic ROLE_PWRITE_t;

   reg [17 : 0] _PADDR_temp;
   reg [17 : 0] _PADDR_out;
   reg _PADDR31_temp;
   reg _PADDR31_out;
   reg _PENABLE_temp;
   reg _PENABLE_out;
   logic [31 : 0] _PRDATA_in;
   logic [31 : 0] _PRDATA_local;
   logic [0 : 0] _PREADY_in;
   logic [0 : 0] _PREADY_local;
   reg _PSEL_temp;
   reg _PSEL_out;
   logic [0 : 0] _PSLVERR_in;
   logic [0 : 0] _PSLVERR_local;
   reg [31 : 0] _PWDATA_temp;
   reg [31 : 0] _PWDATA_out;
   reg _PWRITE_temp;
   reg _PWRITE_out;

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
   
   event signal_input_PRDATA_change;
   event signal_input_PREADY_change;
   event signal_input_PSLVERR_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // _PADDR
   // -------------------------------------------------------

   function automatic void set_PADDR (
      ROLE_PADDR_t new_value
   );
      // Drive the new value to _PADDR.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PADDR_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // _PADDR31
   // -------------------------------------------------------

   function automatic void set_PADDR31 (
      ROLE_PADDR31_t new_value
   );
      // Drive the new value to _PADDR31.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PADDR31_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // _PENABLE
   // -------------------------------------------------------

   function automatic void set_PENABLE (
      ROLE_PENABLE_t new_value
   );
      // Drive the new value to _PENABLE.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PENABLE_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // _PRDATA
   // -------------------------------------------------------
   function automatic ROLE_PRDATA_t get_PRDATA();
   
      // Gets the _PRDATA input value.
      $sformat(message, "%m: called get_PRDATA");
      print(VERBOSITY_DEBUG, message);
      return _PRDATA_in;
      
   endfunction

   // -------------------------------------------------------
   // _PREADY
   // -------------------------------------------------------
   function automatic ROLE_PREADY_t get_PREADY();
   
      // Gets the _PREADY input value.
      $sformat(message, "%m: called get_PREADY");
      print(VERBOSITY_DEBUG, message);
      return _PREADY_in;
      
   endfunction

   // -------------------------------------------------------
   // _PSEL
   // -------------------------------------------------------

   function automatic void set_PSEL (
      ROLE_PSEL_t new_value
   );
      // Drive the new value to _PSEL.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PSEL_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // _PSLVERR
   // -------------------------------------------------------
   function automatic ROLE_PSLVERR_t get_PSLVERR();
   
      // Gets the _PSLVERR input value.
      $sformat(message, "%m: called get_PSLVERR");
      print(VERBOSITY_DEBUG, message);
      return _PSLVERR_in;
      
   endfunction

   // -------------------------------------------------------
   // _PWDATA
   // -------------------------------------------------------

   function automatic void set_PWDATA (
      ROLE_PWDATA_t new_value
   );
      // Drive the new value to _PWDATA.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PWDATA_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // _PWRITE
   // -------------------------------------------------------

   function automatic void set_PWRITE (
      ROLE_PWRITE_t new_value
   );
      // Drive the new value to _PWRITE.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      _PWRITE_temp = new_value;
   endfunction

   assign sig_PADDR = _PADDR_temp;
   assign sig_PADDR31 = _PADDR31_temp;
   assign sig_PENABLE = _PENABLE_temp;
   assign _PRDATA_in = sig_PRDATA;
   assign _PREADY_in = sig_PREADY;
   assign sig_PSEL = _PSEL_temp;
   assign _PSLVERR_in = sig_PSLVERR;
   assign sig_PWDATA = _PWDATA_temp;
   assign sig_PWRITE = _PWRITE_temp;


   always @(_PRDATA_in) begin
      if (_PRDATA_local != _PRDATA_in)
         -> signal_input_PRDATA_change;
      _PRDATA_local = _PRDATA_in;
   end
   
   always @(_PREADY_in) begin
      if (_PREADY_local != _PREADY_in)
         -> signal_input_PREADY_change;
      _PREADY_local = _PREADY_in;
   end
   
   always @(_PSLVERR_in) begin
      if (_PSLVERR_local != _PSLVERR_in)
         -> signal_input_PSLVERR_change;
      _PSLVERR_local = _PSLVERR_in;
   end
   


// synthesis translate_on

endmodule 

module debug_apb_sideband_bfm
(
   sig_PCLKEN,
   sig_DBG_APB_DISABLE
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_PCLKEN;
   input sig_DBG_APB_DISABLE;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_PCLKEN_t;
   typedef logic ROLE_DBG_APB_DISABLE_t;

   logic [0 : 0] _PCLKEN_in;
   logic [0 : 0] _PCLKEN_local;
   logic [0 : 0] _DBG_APB_DISABLE_in;
   logic [0 : 0] _DBG_APB_DISABLE_local;

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
   
   event signal_input_PCLKEN_change;
   event signal_input_DBG_APB_DISABLE_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // _PCLKEN
   // -------------------------------------------------------
   function automatic ROLE_PCLKEN_t get_PCLKEN();
   
      // Gets the _PCLKEN input value.
      $sformat(message, "%m: called get_PCLKEN");
      print(VERBOSITY_DEBUG, message);
      return _PCLKEN_in;
      
   endfunction

   // -------------------------------------------------------
   // _DBG_APB_DISABLE
   // -------------------------------------------------------
   function automatic ROLE_DBG_APB_DISABLE_t get_DBG_APB_DISABLE();
   
      // Gets the _DBG_APB_DISABLE input value.
      $sformat(message, "%m: called get_DBG_APB_DISABLE");
      print(VERBOSITY_DEBUG, message);
      return _DBG_APB_DISABLE_in;
      
   endfunction

   assign _PCLKEN_in = sig_PCLKEN;
   assign _DBG_APB_DISABLE_in = sig_DBG_APB_DISABLE;


   always @(_PCLKEN_in) begin
      if (_PCLKEN_local != _PCLKEN_in)
         -> signal_input_PCLKEN_change;
      _PCLKEN_local = _PCLKEN_in;
   end
   
   always @(_DBG_APB_DISABLE_in) begin
      if (_DBG_APB_DISABLE_local != _DBG_APB_DISABLE_in)
         -> signal_input_DBG_APB_DISABLE_change;
      _DBG_APB_DISABLE_local = _DBG_APB_DISABLE_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_dbg_apb 
#(
   dummy_param    = 0
)(
   output wire [17:0] p_addr,
   output wire        p_addr_31,
   output wire        p_enable,
   input  wire [31:0] p_rdata,
   input  wire        p_ready,
   output wire        p_sel,
   input  wire        p_slv_err,
   output wire [31:0] p_wdata,
   output wire        p_write,
   input  wire        p_clk_en,
   input  wire        dbg_apb_disable,
   output wire        p_reset_n,
   input  wire        p_clk
);

   debug_apb_bfm h2f_debug_apb (
      .sig_PADDR(p_addr),
      .sig_PADDR31(p_addr_31),
      .sig_PENABLE(p_enable),
      .sig_PRDATA(p_rdata),
      .sig_PREADY(p_ready),
      .sig_PSEL(p_sel),
      .sig_PSLVERR(p_slv_err),
      .sig_PWDATA(p_wdata),
      .sig_PWRITE(p_write)
   );
   
   debug_apb_sideband_bfm h2f_debug_apb_sideband (
      .sig_PCLKEN(p_clk_en),
      .sig_DBG_APB_DISABLE(dbg_apb_disable)
   );

endmodule 

module arriav_hps_interface_dbg_apb 
#(
   dummy_param    = 0
)(
   output wire [17:0] p_addr,
   output wire        p_addr_31,
   output wire        p_enable,
   input  wire [31:0] p_rdata,
   input  wire        p_ready,
   output wire        p_sel,
   input  wire        p_slv_err,
   output wire [31:0] p_wdata,
   output wire        p_write,
   input  wire        p_clk_en,
   input  wire        dbg_apb_disable,
   output wire        p_reset_n,
   input  wire        p_clk
);

   debug_apb_bfm h2f_debug_apb (
      .sig_PADDR(p_addr),
      .sig_PADDR31(p_addr_31),
      .sig_PENABLE(p_enable),
      .sig_PRDATA(p_rdata),
      .sig_PREADY(p_ready),
      .sig_PSEL(p_sel),
      .sig_PSLVERR(p_slv_err),
      .sig_PWDATA(p_wdata),
      .sig_PWRITE(p_write)
   );
   
   debug_apb_sideband_bfm h2f_debug_apb_sideband (
      .sig_PCLKEN(p_clk_en),
      .sig_DBG_APB_DISABLE(dbg_apb_disable)
   );

endmodule 