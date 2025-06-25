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


module usb_bfm
(
   sig_dir,
   sig_nxt,
   sig_datain,
   sig_clk,
   sig_dataout,
   sig_data_out_en,
   sig_stp
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_dir;
   input sig_nxt;
   input [7 : 0] sig_datain;
   input sig_clk;
   output [7 : 0] sig_dataout;
   output [7 : 0] sig_data_out_en;
   output sig_stp;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_dir_t;
   typedef logic ROLE_nxt_t;
   typedef logic [7 : 0] ROLE_datain_t;
   typedef logic ROLE_clk_t;
   typedef logic [7 : 0] ROLE_dataout_t;
   typedef logic [7 : 0] ROLE_data_out_en_t;
   typedef logic ROLE_stp_t;

   logic [0 : 0] dir_in;
   logic [0 : 0] dir_local;
   logic [0 : 0] nxt_in;
   logic [0 : 0] nxt_local;
   logic [7 : 0] datain_in;
   logic [7 : 0] datain_local;
   logic [0 : 0] clk_in;
   logic [0 : 0] clk_local;
   reg [7 : 0] dataout_temp;
   reg [7 : 0] dataout_out;
   reg [7 : 0] data_out_en_temp;
   reg [7 : 0] data_out_en_out;
   reg stp_temp;
   reg stp_out;

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
   
   event signal_input_dir_change;
   event signal_input_nxt_change;
   event signal_input_datain_change;
   event signal_input_clk_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // dir
   // -------------------------------------------------------
   function automatic ROLE_dir_t get_dir();
   
      // Gets the dir input value.
      $sformat(message, "%m: called get_dir");
      print(VERBOSITY_DEBUG, message);
      return dir_in;
      
   endfunction

   // -------------------------------------------------------
   // nxt
   // -------------------------------------------------------
   function automatic ROLE_nxt_t get_nxt();
   
      // Gets the nxt input value.
      $sformat(message, "%m: called get_nxt");
      print(VERBOSITY_DEBUG, message);
      return nxt_in;
      
   endfunction

   // -------------------------------------------------------
   // datain
   // -------------------------------------------------------
   function automatic ROLE_datain_t get_datain();
   
      // Gets the datain input value.
      $sformat(message, "%m: called get_datain");
      print(VERBOSITY_DEBUG, message);
      return datain_in;
      
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

   // -------------------------------------------------------
   // dataout
   // -------------------------------------------------------

   function automatic void set_dataout (
      ROLE_dataout_t new_value
   );
      // Drive the new value to dataout.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      dataout_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // data_out_en
   // -------------------------------------------------------

   function automatic void set_data_out_en (
      ROLE_data_out_en_t new_value
   );
      // Drive the new value to data_out_en.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      data_out_en_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // stp
   // -------------------------------------------------------

   function automatic void set_stp (
      ROLE_stp_t new_value
   );
      // Drive the new value to stp.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      stp_temp = new_value;
   endfunction

   assign dir_in = sig_dir;
   assign nxt_in = sig_nxt;
   assign datain_in = sig_datain;
   assign clk_in = sig_clk;
   assign sig_dataout = dataout_temp;
   assign sig_data_out_en = data_out_en_temp;
   assign sig_stp = stp_temp;


   always @(dir_in) begin
      if (dir_local != dir_in)
         -> signal_input_dir_change;
      dir_local = dir_in;
   end
   
   always @(nxt_in) begin
      if (nxt_local != nxt_in)
         -> signal_input_nxt_change;
      nxt_local = nxt_in;
   end
   
   always @(datain_in) begin
      if (datain_local != datain_in)
         -> signal_input_datain_change;
      datain_local = datain_in;
   end
   
   always @(clk_in) begin
      if (clk_local != clk_in)
         -> signal_input_clk_change;
      clk_local = clk_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_usb (
   input  wire       dir,
   input  wire       nxt,
   input  wire [7:0] datain,
   input  wire       clk,
   output wire [7:0] dataout,
   output wire [7:0] data_out_en,
   output wire       stp
);

   usb_bfm usb_inst (
      .sig_dir(dir),
      .sig_nxt(nxt),
      .sig_datain(datain),
      .sig_clk(clk),
      .sig_dataout(dataout),
      .sig_data_out_en(data_out_en),
      .sig_stp(stp)
   );

endmodule 

module arriav_hps_interface_peripheral_usb (
   input  wire       dir,
   input  wire       nxt,
   input  wire [7:0] datain,
   input  wire       clk,
   output wire [7:0] dataout,
   output wire [7:0] data_out_en,
   output wire       stp
);

   usb_bfm usb_inst (
      .sig_dir(dir),
      .sig_nxt(nxt),
      .sig_datain(datain),
      .sig_clk(clk),
      .sig_dataout(dataout),
      .sig_data_out_en(data_out_en),
      .sig_stp(stp)
   );

endmodule 