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


module sdmmc_bfm
(
   sig_cmd_i,
   sig_wp_i,
   sig_cdn_i,
   sig_card_intn_i,
   sig_data_i,
   sig_clk_in,
   sig_cclk_out,
   sig_vs_o,
   sig_pwr_ena_o,
   sig_cmd_o,
   sig_cmd_en,
   sig_data_o,
   sig_data_en,
   sig_rstn_o
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_cmd_i;
   input sig_wp_i;
   input sig_cdn_i;
   input sig_card_intn_i;
   input [7 : 0] sig_data_i;
   input sig_clk_in;
   output sig_cclk_out;
   output sig_vs_o;
   output sig_pwr_ena_o;
   output sig_cmd_o;
   output sig_cmd_en;
   output [7 : 0] sig_data_o;
   output [7 : 0] sig_data_en;
   output sig_rstn_o;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_cmd_i_t;
   typedef logic ROLE_wp_i_t;
   typedef logic ROLE_cdn_i_t;
   typedef logic ROLE_card_intn_i_t;
   typedef logic [7 : 0] ROLE_data_i_t;
   typedef logic ROLE_clk_in_t;
   typedef logic ROLE_cclk_out_t;
   typedef logic ROLE_vs_o_t;
   typedef logic ROLE_pwr_ena_o_t;
   typedef logic ROLE_cmd_o_t;
   typedef logic ROLE_cmd_en_t;
   typedef logic [7 : 0] ROLE_data_o_t;
   typedef logic [7 : 0] ROLE_data_en_t;
   typedef logic ROLE_rstn_o_t;

   logic [0 : 0] cmd_i_in;
   logic [0 : 0] cmd_i_local;
   logic [0 : 0] wp_i_in;
   logic [0 : 0] wp_i_local;
   logic [0 : 0] cdn_i_in;
   logic [0 : 0] cdn_i_local;
   logic [0 : 0] card_intn_i_in;
   logic [0 : 0] card_intn_i_local;
   logic [7 : 0] data_i_in;
   logic [7 : 0] data_i_local;
   logic [0 : 0] clk_in_in;
   logic [0 : 0] clk_in_local;
   reg cclk_out_temp;
   reg cclk_out_out;
   reg vs_o_temp;
   reg vs_o_out;
   reg pwr_ena_o_temp;
   reg pwr_ena_o_out;
   reg cmd_o_temp;
   reg cmd_o_out;
   reg cmd_en_temp;
   reg cmd_en_out;
   reg [7 : 0] data_o_temp;
   reg [7 : 0] data_o_out;
   reg [7 : 0] data_en_temp;
   reg [7 : 0] data_en_out;
   reg rstn_o_temp;
   reg rstn_o_out;

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
   
   event signal_input_cmd_i_change;
   event signal_input_wp_i_change;
   event signal_input_cdn_i_change;
   event signal_input_card_intn_i_change;
   event signal_input_data_i_change;
   event signal_input_clk_in_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // cmd_i
   // -------------------------------------------------------
   function automatic ROLE_cmd_i_t get_cmd_i();
   
      // Gets the cmd_i input value.
      $sformat(message, "%m: called get_cmd_i");
      print(VERBOSITY_DEBUG, message);
      return cmd_i_in;
      
   endfunction

   // -------------------------------------------------------
   // wp_i
   // -------------------------------------------------------
   function automatic ROLE_wp_i_t get_wp_i();
   
      // Gets the wp_i input value.
      $sformat(message, "%m: called get_wp_i");
      print(VERBOSITY_DEBUG, message);
      return wp_i_in;
      
   endfunction

   // -------------------------------------------------------
   // cdn_i
   // -------------------------------------------------------
   function automatic ROLE_cdn_i_t get_cdn_i();
   
      // Gets the cdn_i input value.
      $sformat(message, "%m: called get_cdn_i");
      print(VERBOSITY_DEBUG, message);
      return cdn_i_in;
      
   endfunction

   // -------------------------------------------------------
   // card_intn_i
   // -------------------------------------------------------
   function automatic ROLE_card_intn_i_t get_card_intn_i();
   
      // Gets the card_intn_i input value.
      $sformat(message, "%m: called get_card_intn_i");
      print(VERBOSITY_DEBUG, message);
      return card_intn_i_in;
      
   endfunction

   // -------------------------------------------------------
   // data_i
   // -------------------------------------------------------
   function automatic ROLE_data_i_t get_data_i();
   
      // Gets the data_i input value.
      $sformat(message, "%m: called get_data_i");
      print(VERBOSITY_DEBUG, message);
      return data_i_in;
      
   endfunction

   // -------------------------------------------------------
   // clk_in
   // -------------------------------------------------------
   function automatic ROLE_clk_in_t get_clk_in();
   
      // Gets the clk_in input value.
      $sformat(message, "%m: called get_clk_in");
      print(VERBOSITY_DEBUG, message);
      return clk_in_in;
      
   endfunction

   // -------------------------------------------------------
   // cclk_out
   // -------------------------------------------------------

   function automatic void set_cclk_out (
      ROLE_cclk_out_t new_value
   );
      // Drive the new value to cclk_out.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      cclk_out_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // vs_o
   // -------------------------------------------------------

   function automatic void set_vs_o (
      ROLE_vs_o_t new_value
   );
      // Drive the new value to vs_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      vs_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // pwr_ena_o
   // -------------------------------------------------------

   function automatic void set_pwr_ena_o (
      ROLE_pwr_ena_o_t new_value
   );
      // Drive the new value to pwr_ena_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      pwr_ena_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // cmd_o
   // -------------------------------------------------------

   function automatic void set_cmd_o (
      ROLE_cmd_o_t new_value
   );
      // Drive the new value to cmd_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      cmd_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // cmd_en
   // -------------------------------------------------------

   function automatic void set_cmd_en (
      ROLE_cmd_en_t new_value
   );
      // Drive the new value to cmd_en.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      cmd_en_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // data_o
   // -------------------------------------------------------

   function automatic void set_data_o (
      ROLE_data_o_t new_value
   );
      // Drive the new value to data_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      data_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // data_en
   // -------------------------------------------------------

   function automatic void set_data_en (
      ROLE_data_en_t new_value
   );
      // Drive the new value to data_en.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      data_en_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // rstn_o
   // -------------------------------------------------------

   function automatic void set_rstn_o (
      ROLE_rstn_o_t new_value
   );
      // Drive the new value to rstn_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      rstn_o_temp = new_value;
   endfunction

   assign cmd_i_in = sig_cmd_i;
   assign wp_i_in = sig_wp_i;
   assign cdn_i_in = sig_cdn_i;
   assign card_intn_i_in = sig_card_intn_i;
   assign data_i_in = sig_data_i;
   assign clk_in_in = sig_clk_in;
   assign sig_cclk_out = cclk_out_temp;
   assign sig_vs_o = vs_o_temp;
   assign sig_pwr_ena_o = pwr_ena_o_temp;
   assign sig_cmd_o = cmd_o_temp;
   assign sig_cmd_en = cmd_en_temp;
   assign sig_data_o = data_o_temp;
   assign sig_data_en = data_en_temp;
   assign sig_rstn_o = rstn_o_temp;


   always @(cmd_i_in) begin
      if (cmd_i_local != cmd_i_in)
         -> signal_input_cmd_i_change;
      cmd_i_local = cmd_i_in;
   end
   
   always @(wp_i_in) begin
      if (wp_i_local != wp_i_in)
         -> signal_input_wp_i_change;
      wp_i_local = wp_i_in;
   end
   
   always @(cdn_i_in) begin
      if (cdn_i_local != cdn_i_in)
         -> signal_input_cdn_i_change;
      cdn_i_local = cdn_i_in;
   end
   
   always @(card_intn_i_in) begin
      if (card_intn_i_local != card_intn_i_in)
         -> signal_input_card_intn_i_change;
      card_intn_i_local = card_intn_i_in;
   end
   
   always @(data_i_in) begin
      if (data_i_local != data_i_in)
         -> signal_input_data_i_change;
      data_i_local = data_i_in;
   end
   
   always @(clk_in_in) begin
      if (clk_in_local != clk_in_in)
         -> signal_input_clk_in_change;
      clk_in_local = clk_in_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_sdmmc (
   input  wire       cmd_i,
   input  wire       wp_i,
   input  wire       cdn_i,
   input  wire       card_intn_i,
   input  wire [7:0] data_i,
   input  wire       clk_in,
   output wire       cclk_out,
   output wire       vs_o,
   output wire       pwr_ena_o,
   output wire       cmd_o,
   output wire       cmd_en,
   output wire [7:0] data_o,
   output wire [7:0] data_en,
   output wire       rstn_o
);

   sdmmc_bfm sdmmc_inst (
      .sig_cmd_i(cmd_i),
      .sig_wp_i(wp_i),
      .sig_cdn_i(cdn_i),
      .sig_card_intn_i(card_intn_i),
      .sig_data_i(data_i),
      .sig_clk_in(clk_in),
      .sig_cclk_out(cclk_out),
      .sig_vs_o(vs_o),
      .sig_pwr_ena_o(pwr_ena_o),
      .sig_cmd_o(cmd_o),
      .sig_cmd_en(cmd_en),
      .sig_data_o(data_o),
      .sig_data_en(data_en),
      .sig_rstn_o(rstn_o)
   );

endmodule 

module arriav_hps_interface_peripheral_sdmmc (
   input  wire       cmd_i,
   input  wire       wp_i,
   input  wire       cdn_i,
   input  wire       card_intn_i,
   input  wire [7:0] data_i,
   input  wire       clk_in,
   output wire       cclk_out,
   output wire       vs_o,
   output wire       pwr_ena_o,
   output wire       cmd_o,
   output wire       cmd_en,
   output wire [7:0] data_o,
   output wire [7:0] data_en,
   output wire       rstn_o
);

   sdmmc_bfm sdmmc_inst (
      .sig_cmd_i(cmd_i),
      .sig_wp_i(wp_i),
      .sig_cdn_i(cdn_i),
      .sig_card_intn_i(card_intn_i),
      .sig_data_i(data_i),
      .sig_clk_in(clk_in),
      .sig_cclk_out(cclk_out),
      .sig_vs_o(vs_o),
      .sig_pwr_ena_o(pwr_ena_o),
      .sig_cmd_o(cmd_o),
      .sig_cmd_en(cmd_en),
      .sig_data_o(data_o),
      .sig_data_en(data_en),
      .sig_rstn_o(rstn_o)
   );

endmodule 