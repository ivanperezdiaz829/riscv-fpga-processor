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


module emac_bfm
(
   sig_phy_col_i,
   sig_phy_rxd_i,
   sig_ptp_aux_ts_trig_i,
   sig_phy_crs_i,
   sig_gmii_mdi_i,
   sig_clk_rx_i,
   sig_phy_rxer_i,
   sig_phy_rxdv_i,
   sig_clk_tx_i,
   sig_gmii_mdc_o,
   sig_phy_txclk_o,
   sig_phy_txd_o,
   sig_gmii_mdo_o_e,
   sig_ptp_pps_o,
   sig_rst_clk_rx_n_o,
   sig_phy_txen_o,
   sig_gmii_mdo_o,
   sig_rst_clk_tx_n_o,
   sig_phy_txer_o
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_phy_col_i;
   input [7 : 0] sig_phy_rxd_i;
   input sig_ptp_aux_ts_trig_i;
   input sig_phy_crs_i;
   input sig_gmii_mdi_i;
   input sig_clk_rx_i;
   input sig_phy_rxer_i;
   input sig_phy_rxdv_i;
   input sig_clk_tx_i;
   output sig_gmii_mdc_o;
   output sig_phy_txclk_o;
   output [7 : 0] sig_phy_txd_o;
   output sig_gmii_mdo_o_e;
   output sig_ptp_pps_o;
   output sig_rst_clk_rx_n_o;
   output sig_phy_txen_o;
   output sig_gmii_mdo_o;
   output sig_rst_clk_tx_n_o;
   output sig_phy_txer_o;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_phy_col_i_t;
   typedef logic [7 : 0] ROLE_phy_rxd_i_t;
   typedef logic ROLE_ptp_aux_ts_trig_i_t;
   typedef logic ROLE_phy_crs_i_t;
   typedef logic ROLE_gmii_mdi_i_t;
   typedef logic ROLE_clk_rx_i_t;
   typedef logic ROLE_phy_rxer_i_t;
   typedef logic ROLE_phy_rxdv_i_t;
   typedef logic ROLE_clk_tx_i_t;
   typedef logic ROLE_gmii_mdc_o_t;
   typedef logic ROLE_phy_txclk_o_t;
   typedef logic [7 : 0] ROLE_phy_txd_o_t;
   typedef logic ROLE_gmii_mdo_o_e_t;
   typedef logic ROLE_ptp_pps_o_t;
   typedef logic ROLE_rst_clk_rx_n_o_t;
   typedef logic ROLE_phy_txen_o_t;
   typedef logic ROLE_gmii_mdo_o_t;
   typedef logic ROLE_rst_clk_tx_n_o_t;
   typedef logic ROLE_phy_txer_o_t;

   logic [0 : 0] phy_col_i_in;
   logic [0 : 0] phy_col_i_local;
   logic [7 : 0] phy_rxd_i_in;
   logic [7 : 0] phy_rxd_i_local;
   logic [0 : 0] ptp_aux_ts_trig_i_in;
   logic [0 : 0] ptp_aux_ts_trig_i_local;
   logic [0 : 0] phy_crs_i_in;
   logic [0 : 0] phy_crs_i_local;
   logic [0 : 0] gmii_mdi_i_in;
   logic [0 : 0] gmii_mdi_i_local;
   logic [0 : 0] clk_rx_i_in;
   logic [0 : 0] clk_rx_i_local;
   logic [0 : 0] phy_rxer_i_in;
   logic [0 : 0] phy_rxer_i_local;
   logic [0 : 0] phy_rxdv_i_in;
   logic [0 : 0] phy_rxdv_i_local;
   logic [0 : 0] clk_tx_i_in;
   logic [0 : 0] clk_tx_i_local;
   reg gmii_mdc_o_temp;
   reg gmii_mdc_o_out;
   reg phy_txclk_o_temp;
   reg phy_txclk_o_out;
   reg [7 : 0] phy_txd_o_temp;
   reg [7 : 0] phy_txd_o_out;
   reg gmii_mdo_o_e_temp;
   reg gmii_mdo_o_e_out;
   reg ptp_pps_o_temp;
   reg ptp_pps_o_out;
   reg rst_clk_rx_n_o_temp;
   reg rst_clk_rx_n_o_out;
   reg phy_txen_o_temp;
   reg phy_txen_o_out;
   reg gmii_mdo_o_temp;
   reg gmii_mdo_o_out;
   reg rst_clk_tx_n_o_temp;
   reg rst_clk_tx_n_o_out;
   reg phy_txer_o_temp;
   reg phy_txer_o_out;

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
   
   event signal_input_phy_col_i_change;
   event signal_input_phy_rxd_i_change;
   event signal_input_ptp_aux_ts_trig_i_change;
   event signal_input_phy_crs_i_change;
   event signal_input_gmii_mdi_i_change;
   event signal_input_clk_rx_i_change;
   event signal_input_phy_rxer_i_change;
   event signal_input_phy_rxdv_i_change;
   event signal_input_clk_tx_i_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "12.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // phy_col_i
   // -------------------------------------------------------
   function automatic ROLE_phy_col_i_t get_phy_col_i();
   
      // Gets the phy_col_i input value.
      $sformat(message, "%m: called get_phy_col_i");
      print(VERBOSITY_DEBUG, message);
      return phy_col_i_in;
      
   endfunction

   // -------------------------------------------------------
   // phy_rxd_i
   // -------------------------------------------------------
   function automatic ROLE_phy_rxd_i_t get_phy_rxd_i();
   
      // Gets the phy_rxd_i input value.
      $sformat(message, "%m: called get_phy_rxd_i");
      print(VERBOSITY_DEBUG, message);
      return phy_rxd_i_in;
      
   endfunction

   // -------------------------------------------------------
   // ptp_aux_ts_trig_i
   // -------------------------------------------------------
   function automatic ROLE_ptp_aux_ts_trig_i_t get_ptp_aux_ts_trig_i();
   
      // Gets the ptp_aux_ts_trig_i input value.
      $sformat(message, "%m: called get_ptp_aux_ts_trig_i");
      print(VERBOSITY_DEBUG, message);
      return ptp_aux_ts_trig_i_in;
      
   endfunction

   // -------------------------------------------------------
   // phy_crs_i
   // -------------------------------------------------------
   function automatic ROLE_phy_crs_i_t get_phy_crs_i();
   
      // Gets the phy_crs_i input value.
      $sformat(message, "%m: called get_phy_crs_i");
      print(VERBOSITY_DEBUG, message);
      return phy_crs_i_in;
      
   endfunction

   // -------------------------------------------------------
   // gmii_mdi_i
   // -------------------------------------------------------
   function automatic ROLE_gmii_mdi_i_t get_gmii_mdi_i();
   
      // Gets the gmii_mdi_i input value.
      $sformat(message, "%m: called get_gmii_mdi_i");
      print(VERBOSITY_DEBUG, message);
      return gmii_mdi_i_in;
      
   endfunction

   // -------------------------------------------------------
   // clk_rx_i
   // -------------------------------------------------------
   function automatic ROLE_clk_rx_i_t get_clk_rx_i();
   
      // Gets the clk_rx_i input value.
      $sformat(message, "%m: called get_clk_rx_i");
      print(VERBOSITY_DEBUG, message);
      return clk_rx_i_in;
      
   endfunction

   // -------------------------------------------------------
   // phy_rxer_i
   // -------------------------------------------------------
   function automatic ROLE_phy_rxer_i_t get_phy_rxer_i();
   
      // Gets the phy_rxer_i input value.
      $sformat(message, "%m: called get_phy_rxer_i");
      print(VERBOSITY_DEBUG, message);
      return phy_rxer_i_in;
      
   endfunction

   // -------------------------------------------------------
   // phy_rxdv_i
   // -------------------------------------------------------
   function automatic ROLE_phy_rxdv_i_t get_phy_rxdv_i();
   
      // Gets the phy_rxdv_i input value.
      $sformat(message, "%m: called get_phy_rxdv_i");
      print(VERBOSITY_DEBUG, message);
      return phy_rxdv_i_in;
      
   endfunction

   // -------------------------------------------------------
   // clk_tx_i
   // -------------------------------------------------------
   function automatic ROLE_clk_tx_i_t get_clk_tx_i();
   
      // Gets the clk_tx_i input value.
      $sformat(message, "%m: called get_clk_tx_i");
      print(VERBOSITY_DEBUG, message);
      return clk_tx_i_in;
      
   endfunction

   // -------------------------------------------------------
   // gmii_mdc_o
   // -------------------------------------------------------

   function automatic void set_gmii_mdc_o (
      ROLE_gmii_mdc_o_t new_value
   );
      // Drive the new value to gmii_mdc_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      gmii_mdc_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // phy_txclk_o
   // -------------------------------------------------------

   function automatic void set_phy_txclk_o (
      ROLE_phy_txclk_o_t new_value
   );
      // Drive the new value to phy_txclk_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      phy_txclk_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // phy_txd_o
   // -------------------------------------------------------

   function automatic void set_phy_txd_o (
      ROLE_phy_txd_o_t new_value
   );
      // Drive the new value to phy_txd_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      phy_txd_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // gmii_mdo_o_e
   // -------------------------------------------------------

   function automatic void set_gmii_mdo_o_e (
      ROLE_gmii_mdo_o_e_t new_value
   );
      // Drive the new value to gmii_mdo_o_e.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      gmii_mdo_o_e_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // ptp_pps_o
   // -------------------------------------------------------

   function automatic void set_ptp_pps_o (
      ROLE_ptp_pps_o_t new_value
   );
      // Drive the new value to ptp_pps_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      ptp_pps_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // rst_clk_rx_n_o
   // -------------------------------------------------------

   function automatic void set_rst_clk_rx_n_o (
      ROLE_rst_clk_rx_n_o_t new_value
   );
      // Drive the new value to rst_clk_rx_n_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      rst_clk_rx_n_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // phy_txen_o
   // -------------------------------------------------------

   function automatic void set_phy_txen_o (
      ROLE_phy_txen_o_t new_value
   );
      // Drive the new value to phy_txen_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      phy_txen_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // gmii_mdo_o
   // -------------------------------------------------------

   function automatic void set_gmii_mdo_o (
      ROLE_gmii_mdo_o_t new_value
   );
      // Drive the new value to gmii_mdo_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      gmii_mdo_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // rst_clk_tx_n_o
   // -------------------------------------------------------

   function automatic void set_rst_clk_tx_n_o (
      ROLE_rst_clk_tx_n_o_t new_value
   );
      // Drive the new value to rst_clk_tx_n_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      rst_clk_tx_n_o_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // phy_txer_o
   // -------------------------------------------------------

   function automatic void set_phy_txer_o (
      ROLE_phy_txer_o_t new_value
   );
      // Drive the new value to phy_txer_o.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      phy_txer_o_temp = new_value;
   endfunction

   assign phy_col_i_in = sig_phy_col_i;
   assign phy_rxd_i_in = sig_phy_rxd_i;
   assign ptp_aux_ts_trig_i_in = sig_ptp_aux_ts_trig_i;
   assign phy_crs_i_in = sig_phy_crs_i;
   assign gmii_mdi_i_in = sig_gmii_mdi_i;
   assign clk_rx_i_in = sig_clk_rx_i;
   assign phy_rxer_i_in = sig_phy_rxer_i;
   assign phy_rxdv_i_in = sig_phy_rxdv_i;
   assign clk_tx_i_in = sig_clk_tx_i;
   assign sig_gmii_mdc_o = gmii_mdc_o_temp;
   assign sig_phy_txclk_o = phy_txclk_o_temp;
   assign sig_phy_txd_o = phy_txd_o_temp;
   assign sig_gmii_mdo_o_e = gmii_mdo_o_e_temp;
   assign sig_ptp_pps_o = ptp_pps_o_temp;
   assign sig_rst_clk_rx_n_o = rst_clk_rx_n_o_temp;
   assign sig_phy_txen_o = phy_txen_o_temp;
   assign sig_gmii_mdo_o = gmii_mdo_o_temp;
   assign sig_rst_clk_tx_n_o = rst_clk_tx_n_o_temp;
   assign sig_phy_txer_o = phy_txer_o_temp;


   always @(phy_col_i_in) begin
      if (phy_col_i_local != phy_col_i_in)
         -> signal_input_phy_col_i_change;
      phy_col_i_local = phy_col_i_in;
   end
   
   always @(phy_rxd_i_in) begin
      if (phy_rxd_i_local != phy_rxd_i_in)
         -> signal_input_phy_rxd_i_change;
      phy_rxd_i_local = phy_rxd_i_in;
   end
   
   always @(ptp_aux_ts_trig_i_in) begin
      if (ptp_aux_ts_trig_i_local != ptp_aux_ts_trig_i_in)
         -> signal_input_ptp_aux_ts_trig_i_change;
      ptp_aux_ts_trig_i_local = ptp_aux_ts_trig_i_in;
   end
   
   always @(phy_crs_i_in) begin
      if (phy_crs_i_local != phy_crs_i_in)
         -> signal_input_phy_crs_i_change;
      phy_crs_i_local = phy_crs_i_in;
   end
   
   always @(gmii_mdi_i_in) begin
      if (gmii_mdi_i_local != gmii_mdi_i_in)
         -> signal_input_gmii_mdi_i_change;
      gmii_mdi_i_local = gmii_mdi_i_in;
   end
   
   always @(clk_rx_i_in) begin
      if (clk_rx_i_local != clk_rx_i_in)
         -> signal_input_clk_rx_i_change;
      clk_rx_i_local = clk_rx_i_in;
   end
   
   always @(phy_rxer_i_in) begin
      if (phy_rxer_i_local != phy_rxer_i_in)
         -> signal_input_phy_rxer_i_change;
      phy_rxer_i_local = phy_rxer_i_in;
   end
   
   always @(phy_rxdv_i_in) begin
      if (phy_rxdv_i_local != phy_rxdv_i_in)
         -> signal_input_phy_rxdv_i_change;
      phy_rxdv_i_local = phy_rxdv_i_in;
   end
   
   always @(clk_tx_i_in) begin
      if (clk_tx_i_local != clk_tx_i_in)
         -> signal_input_clk_tx_i_change;
      clk_tx_i_local = clk_tx_i_in;
   end
   


// synthesis translate_on

endmodule

module cyclonev_hps_interface_peripheral_emac (
   input  wire       phy_col_i,
   input  wire [7:0] phy_rxd_i,
   input  wire       ptp_aux_ts_trig_i,
   input  wire       phy_crs_i,
   input  wire       gmii_mdi_i,
   input  wire       clk_rx_i,
   input  wire       phy_rxer_i,
   input  wire       phy_rxdv_i,
   input  wire       clk_tx_i,
   output wire       gmii_mdc_o,
   output wire       phy_txclk_o,
   output wire [7:0] phy_txd_o,
   output wire       gmii_mdo_o_e,
   output wire       ptp_pps_o,
   output wire       rst_clk_rx_n_o,
   output wire       phy_txen_o,
   output wire       gmii_mdo_o,
   output wire       rst_clk_tx_n_o,
   output wire       phy_txer_o
);

   emac_bfm emac_inst (
      .sig_phy_col_i(phy_col_i),
      .sig_phy_rxd_i(phy_rxd_i),
      .sig_ptp_aux_ts_trig_i(ptp_aux_ts_trig_i),
      .sig_phy_crs_i(phy_crs_i),
      .sig_gmii_mdi_i(gmii_mdi_i),
      .sig_clk_rx_i(clk_rx_i),
      .sig_phy_rxer_i(phy_rxer_i),
      .sig_phy_rxdv_i(phy_rxdv_i),
      .sig_clk_tx_i(clk_tx_i),
      .sig_gmii_mdc_o(gmii_mdc_o),
      .sig_phy_txclk_o(phy_txclk_o),
      .sig_phy_txd_o(phy_txd_o),
      .sig_gmii_mdo_o_e(gmii_mdo_o_e),
      .sig_ptp_pps_o(ptp_pps_o),
      .sig_rst_clk_rx_n_o(rst_clk_rx_n_o),
      .sig_phy_txen_o(phy_txen_o),
      .sig_gmii_mdo_o(gmii_mdo_o),
      .sig_rst_clk_tx_n_o(rst_clk_tx_n_o),
      .sig_phy_txer_o(phy_txer_o)
   );
   
endmodule 

module arriav_hps_interface_peripheral_emac (
   input  wire       phy_col_i,
   input  wire [7:0] phy_rxd_i,
   input  wire       ptp_aux_ts_trig_i,
   input  wire       phy_crs_i,
   input  wire       gmii_mdi_i,
   input  wire       clk_rx_i,
   input  wire       phy_rxer_i,
   input  wire       phy_rxdv_i,
   input  wire       clk_tx_i,
   output wire       gmii_mdc_o,
   output wire       phy_txclk_o,
   output wire [7:0] phy_txd_o,
   output wire       gmii_mdo_o_e,
   output wire       ptp_pps_o,
   output wire       rst_clk_rx_n_o,
   output wire       phy_txen_o,
   output wire       gmii_mdo_o,
   output wire       rst_clk_tx_n_o,
   output wire       phy_txer_o
);

   emac_bfm emac_inst (
      .sig_phy_col_i(phy_col_i),
      .sig_phy_rxd_i(phy_rxd_i),
      .sig_ptp_aux_ts_trig_i(ptp_aux_ts_trig_i),
      .sig_phy_crs_i(phy_crs_i),
      .sig_gmii_mdi_i(gmii_mdi_i),
      .sig_clk_rx_i(clk_rx_i),
      .sig_phy_rxer_i(phy_rxer_i),
      .sig_phy_rxdv_i(phy_rxdv_i),
      .sig_clk_tx_i(clk_tx_i),
      .sig_gmii_mdc_o(gmii_mdc_o),
      .sig_phy_txclk_o(phy_txclk_o),
      .sig_phy_txd_o(phy_txd_o),
      .sig_gmii_mdo_o_e(gmii_mdo_o_e),
      .sig_ptp_pps_o(ptp_pps_o),
      .sig_rst_clk_rx_n_o(rst_clk_rx_n_o),
      .sig_phy_txen_o(phy_txen_o),
      .sig_gmii_mdo_o(gmii_mdo_o),
      .sig_rst_clk_tx_n_o(rst_clk_tx_n_o),
      .sig_phy_txer_o(phy_txer_o)
   );
   
endmodule 