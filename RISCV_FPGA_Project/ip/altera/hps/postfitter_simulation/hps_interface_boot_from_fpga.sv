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


module boot_from_fpga_bfm
(
   sig_boot_from_fpga_ready,
   sig_boot_from_fpga_on_failure,
   sig_bsel,
   sig_bsel_en,
   sig_csel,
   sig_csel_en
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_boot_from_fpga_ready;
   input sig_boot_from_fpga_on_failure;
   input [2 : 0] sig_bsel;
   input sig_bsel_en;
   input [1 : 0] sig_csel;
   input sig_csel_en;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_boot_from_fpga_ready_t;
   typedef logic ROLE_boot_from_fpga_on_failure_t;
   typedef logic [2 : 0] ROLE_bsel_t;
   typedef logic ROLE_bsel_en_t;
   typedef logic [1 : 0] ROLE_csel_t;
   typedef logic ROLE_csel_en_t;

   logic [0 : 0] boot_from_fpga_ready_in;
   logic [0 : 0] boot_from_fpga_ready_local;
   logic [0 : 0] boot_from_fpga_on_failure_in;
   logic [0 : 0] boot_from_fpga_on_failure_local;
   logic [2 : 0] bsel_in;
   logic [2 : 0] bsel_local;
   logic [0 : 0] bsel_en_in;
   logic [0 : 0] bsel_en_local;
   logic [1 : 0] csel_in;
   logic [1 : 0] csel_local;
   logic [0 : 0] csel_en_in;
   logic [0 : 0] csel_en_local;

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
   
   event signal_input_boot_from_fpga_ready_change;
   event signal_input_boot_from_fpga_on_failure_change;
   event signal_input_bsel_change;
   event signal_input_bsel_en_change;
   event signal_input_csel_change;
   event signal_input_csel_en_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // boot_from_fpga_ready
   // -------------------------------------------------------
   function automatic ROLE_boot_from_fpga_ready_t get_boot_from_fpga_ready();
   
      // Gets the boot_from_fpga_ready input value.
      $sformat(message, "%m: called get_boot_from_fpga_ready");
      print(VERBOSITY_DEBUG, message);
      return boot_from_fpga_ready_in;
      
   endfunction

   // -------------------------------------------------------
   // boot_from_fpga_on_failure
   // -------------------------------------------------------
   function automatic ROLE_boot_from_fpga_on_failure_t get_boot_from_fpga_on_failure();
   
      // Gets the boot_from_fpga_on_failure input value.
      $sformat(message, "%m: called get_boot_from_fpga_on_failure");
      print(VERBOSITY_DEBUG, message);
      return boot_from_fpga_on_failure_in;
      
   endfunction

   // -------------------------------------------------------
   // bsel
   // -------------------------------------------------------
   function automatic ROLE_bsel_t get_bsel();
   
      // Gets the bsel input value.
      $sformat(message, "%m: called get_bsel");
      print(VERBOSITY_DEBUG, message);
      return bsel_in;
      
   endfunction

   // -------------------------------------------------------
   // bsel_en
   // -------------------------------------------------------
   function automatic ROLE_bsel_en_t get_bsel_en();
   
      // Gets the bsel_en input value.
      $sformat(message, "%m: called get_bsel_en");
      print(VERBOSITY_DEBUG, message);
      return bsel_en_in;
      
   endfunction

   // -------------------------------------------------------
   // csel
   // -------------------------------------------------------
   function automatic ROLE_csel_t get_csel();
   
      // Gets the csel input value.
      $sformat(message, "%m: called get_csel");
      print(VERBOSITY_DEBUG, message);
      return csel_in;
      
   endfunction

   // -------------------------------------------------------
   // csel_en
   // -------------------------------------------------------
   function automatic ROLE_csel_en_t get_csel_en();
   
      // Gets the csel_en input value.
      $sformat(message, "%m: called get_csel_en");
      print(VERBOSITY_DEBUG, message);
      return csel_en_in;
      
   endfunction

   assign boot_from_fpga_ready_in = sig_boot_from_fpga_ready;
   assign boot_from_fpga_on_failure_in = sig_boot_from_fpga_on_failure;
   assign bsel_in = sig_bsel;
   assign bsel_en_in = sig_bsel_en;
   assign csel_in = sig_csel;
   assign csel_en_in = sig_csel_en;


   always @(boot_from_fpga_ready_in) begin
      if (boot_from_fpga_ready_local != boot_from_fpga_ready_in)
         -> signal_input_boot_from_fpga_ready_change;
      boot_from_fpga_ready_local = boot_from_fpga_ready_in;
   end
   
   always @(boot_from_fpga_on_failure_in) begin
      if (boot_from_fpga_on_failure_local != boot_from_fpga_on_failure_in)
         -> signal_input_boot_from_fpga_on_failure_change;
      boot_from_fpga_on_failure_local = boot_from_fpga_on_failure_in;
   end
   
   always @(bsel_in) begin
      if (bsel_local != bsel_in)
         -> signal_input_bsel_change;
      bsel_local = bsel_in;
   end
   
   always @(bsel_en_in) begin
      if (bsel_en_local != bsel_en_in)
         -> signal_input_bsel_en_change;
      bsel_en_local = bsel_en_in;
   end
   
   always @(csel_in) begin
      if (csel_local != csel_in)
         -> signal_input_csel_change;
      csel_local = csel_in;
   end
   
   always @(csel_en_in) begin
      if (csel_en_local != csel_en_in)
         -> signal_input_csel_en_change;
      csel_en_local = csel_en_in;
   end
   


// synthesis translate_on

endmodule 

module cyclonev_hps_interface_boot_from_fpga (
   input  wire       boot_from_fpga_ready,
   input  wire       boot_from_fpga_on_failure,
   input  wire       bsel_en,
   input  wire       csel_en,
   input  wire [1:0] csel,
   input  wire [2:0] bsel,
   output wire       fake_dout
);
   assign fake_dout = 1'b0;
   
   boot_from_fpga_bfm f2h_boot_from_fpga (
      .sig_boot_from_fpga_ready(boot_from_fpga_ready),
      .sig_boot_from_fpga_on_failure(boot_from_fpga_on_failure),
      .sig_bsel_en(bsel_en),
      .sig_csel_en(csel_en),
      .sig_csel(csel),
      .sig_bsel(bsel)
   );

endmodule 

module arriav_hps_interface_boot_from_fpga (
   input  wire       boot_from_fpga_ready,
   input  wire       boot_from_fpga_on_failure,
   input  wire       bsel_en,
   input  wire       csel_en,
   input  wire [1:0] csel,
   input  wire [2:0] bsel,
   output wire       fake_dout
);
   assign fake_dout = 1'b0;
   
   boot_from_fpga_bfm f2h_boot_from_fpga (
      .sig_boot_from_fpga_ready(boot_from_fpga_ready),
      .sig_boot_from_fpga_on_failure(boot_from_fpga_on_failure),
      .sig_bsel_en(bsel_en),
      .sig_csel_en(csel_en),
      .sig_csel(csel),
      .sig_bsel(bsel)
   );

endmodule 
