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



`timescale 1ns/10ps

import altera_xcvr_functions::*;

module sv_xcvr_att_custom_native #(
    parameter device_family     = "Stratix V", // (Stratix V, Arria V)
    parameter data_path_type    = "ATT",
    parameter operation_mode    = "Duplex",   // (TX, RX, Duplex)
    parameter lanes             = 1,          // (1+)
    parameter data_rate         = "25000 Mbps",
    parameter att_data_path_width = 128,
    parameter bonded_group_size = 1,
    parameter ppm_det_threshold = "100",
    //PLL
    parameter pll_refclk_freq   = "625 MHz",
    parameter plls              = lanes          // (1+)
  ) ( 
  //input from reset controller
  input   wire    [lanes-1:0]     tx_analogreset,   // for tx pma
  input   wire    [plls-1:0]      pll_powerdown, 
  input   wire    [lanes-1:0]     tx_digitalreset,
  input   wire    [lanes-1:0]     rx_analogreset,   // for rx pma
  input   wire    [lanes-1:0]     rx_digitalreset,  // for rx pcs
  
  //clk signal
  input   wire    [plls-1:0]      pll_ref_clk,
  
  //data ports
  input   wire    [att_data_path_width*lanes-1:0]   tx_parallel_data,
  output  wire    [att_data_path_width*lanes-1:0]   rx_parallel_data,
  
  input   wire    [lanes-1:0]     rx_serial_data,
  output  wire    [lanes-1:0]     tx_serial_data,
  
  //clock outputs
  output  wire    [lanes-1:0]     tx_clkout,
  output  wire    [lanes-1:0]     rx_clkout,
  output  wire    [lanes-1:0]     rx_recovered_clk,
        
  //control ports
  
  input   tri0    [lanes-1:0]     rx_seriallpbken,
  input   tri0    [lanes-1:0]     rx_set_locktodata,
  input   tri0    [lanes-1:0]     rx_set_locktoref,
  input   tri0    [lanes-1:0]     rx_cdr_reset_disable,
 
  output  wire    [lanes-1:0]     rx_is_lockedtoref,
  output  wire    [lanes-1:0]     rx_signaldetect,
  output  wire    [lanes-1:0]     rx_is_lockedtodata,
  output  wire    [plls-1 :0]     pll_locked,
  
  // per-lane outputs

  input   wire  [altera_xcvr_functions::get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size, data_path_type )-1:0] reconfig_to_xcvr,
  output  wire  [altera_xcvr_functions::get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size, data_path_type )-1:0] reconfig_from_xcvr 
);

// Reconfig parameters
localparam w_bundle_to_xcvr     = W_S5_RECONFIG_BUNDLE_TO_XCVR;
localparam w_bundle_from_xcvr   = W_S5_RECONFIG_BUNDLE_FROM_XCVR;
localparam reconfig_interfaces  = altera_xcvr_functions::get_custom_reconfig_interfaces("Stratix V",operation_mode,lanes,plls,bonded_group_size, data_path_type );

// RBC checks

//tx localparam
/// TODO: this parameter should be validated against ser_base_factor. Changed the rule for now to compute it on the fly

localparam  INT_RX_ENABLE = (operation_mode == "Rx" || operation_mode == "RX" || operation_mode == "rx"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX" || operation_mode == "duplex") ? 1 : 0;
localparam  INT_TX_ENABLE = (operation_mode == "Tx" || operation_mode == "TX" || operation_mode == "tx"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX" || operation_mode == "duplex") ? 1 : 0;

// determine how many AVMM interfaces are present in the natiove interface ( seperate I/F for Rx and Tx)
localparam  NUM_AVMM_INTERFACES =(operation_mode == "Duplex" || operation_mode == "DUPLEX" || operation_mode == "duplex") ? 2 : 1;
localparam  PLLS_PER_ATT_CH     = 1;
localparam  REFCLK_PER_ATT_CH   = 1;

localparam INT_PPM_LOCK_SRC     = "pcs_ppm_lock";	//Valid values: pcs_ppm_lock|core_ppm_lock
localparam INT_PPM_THRESH       = (ppm_det_threshold == "1000") ? "ppmsel_1000" : 
                                  (ppm_det_threshold == "500")  ? "ppmsel_500"  :
                                  (ppm_det_threshold == "300")  ? "ppmsel_300"  :
                                  (ppm_det_threshold == "250")  ? "ppmsel_250"  :                  
                                  (ppm_det_threshold == "200")  ? "ppmsel_200"  :
                                  (ppm_det_threshold == "125")  ? "ppmsel_125"  :
                                  (ppm_det_threshold == "100")  ? "ppmsel_100"  :
                                  (ppm_det_threshold == "62")   ? "ppmsel_62P5" : "ppmsel_default";


//wires for RX
// used data bundle width is [rx_data_bundle_size * ser_words * lanes - 1: 0], but declare max size

//wires for TX

// Declare local merged versions of reconfig buses 
wire  [altera_xcvr_functions::get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size, data_path_type )-1:0] rcfg_to_xcvr;
wire  [altera_xcvr_functions::get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size, data_path_type )-1:0] rcfg_from_xcvr;
wire  [plls-1:0]  pll_out_clk;
wire  [plls-1:0]  pll_fb_clk;
wire  [plls-1:0]  pll_fb_sw;

wire [lanes-1:0]     rx_ppmlock = {lanes{1'b1}};


// Parameter validation
/******************************************************************
initial begin
  if(!is_in_legal_set(protocol_hint, rbc_all_protocol_hint)) begin
    $display("Critical Warning: Parameter 'protocol_hint' of instance '%m' has illegal value '%s' assigned to it. Valid parameter values are: '%s'.  Using value '%s'", protocol_hint, rbc_all_protocol_hint, fnl_protocol_hint);
  end

  if((bonded_group_size != lanes) && (bonded_group_size != 1)) begin
    $display("Error: Parameter 'bonded_group_size' of instance '%m' has illegal value '%d' assigned to it.  Valid parameter values are: '1' and '%d'.", bonded_group_size, lanes);
  end
end
*****************************************************************/
// End parameter validation

//Generate a native interface per lane
genvar ig;
generate 
for(ig=0; ig<lanes; ig = ig + 1) begin: sv_xcvr_att_native_insts

  localparam num_bonded = bonded_group_size;

//generate
  if((ig % bonded_group_size) == 0) begin

    if(INT_TX_ENABLE == 1) begin

        (* altera_attribute = "-name PLL_TYPE ATX" *)
        sv_xcvr_plls #(
          .plls                     (PLLS_PER_ATT_CH  ), // Only one PLL per channel
          .reference_clock_frequency(pll_refclk_freq  ),
          .pll_type                 ("ATX"            ), // Only LC PLLs can be used
          .att_mode                 (1                ),  
          .output_clock_frequency   (hz2str(str2hz(data_rate)/2)),
          .refclks                  (REFCLK_PER_ATT_CH)
        ) tx_plls (
          .refclk     (pll_ref_clk[ig]    ),
          .rst        (pll_powerdown[ig]  ),
          .fbclk      (pll_fb_clk[ig]     ),
          .pll_fb_sw  (pll_fb_sw[ig]      ),
          .outclk     (pll_out_clk[ig]    ),
          .locked     (pll_locked[ig]     ),
          .fboutclk   (pll_fb_clk[ig]     ),
        
          // avalon MM native reconfiguration interfaces
          .reconfig_to_xcvr   (rcfg_to_xcvr   [((NUM_AVMM_INTERFACES*lanes)+ig)*w_bundle_to_xcvr+:w_bundle_to_xcvr]     ),
          .reconfig_from_xcvr (rcfg_from_xcvr [((NUM_AVMM_INTERFACES*lanes)+ig)*w_bundle_from_xcvr+:w_bundle_from_xcvr] )
        );
      end else begin // TX disabled
        assign  pll_out_clk[ig]     = 1'b0;
        assign  pll_locked[ig]      = 1'b0;
      end

      // Create native transceiver interface 
          sv_xcvr_att_native #(
              .rx_enable                      (INT_RX_ENABLE          ),
              .tx_enable                      (INT_TX_ENABLE          ),
              .cdr_reference_clock_frequency  (pll_refclk_freq        ),
              .pma_data_rate                  (data_rate              ),
              .ppm_lock_sel                   (INT_PPM_LOCK_SRC       ),
              .ppmsel                         (INT_PPM_THRESH         ), 
              .num_lanes                      (num_bonded             ) 
          ) sv_xcvr_att_native_inst (
            // PMA ports
            // TX/RX ports
            .seriallpbken   (rx_seriallpbken[ig]    ),  // 1 = enable serial loopback
            // RX ports
            .rx_crurstn     (~rx_analogreset[ig]    ),  // TODO - investigate resets
            .rx_cdr_ref_clk (pll_ref_clk            ),  // Reference clock for CDR
            .rx_datain      (rx_serial_data[ig]     ),  // RX serial data input
            .rx_ltd         (rx_set_locktodata[ig]  ),  // Force lock-to-data stream (TODO - active low)
            .rx_ltr         (rx_set_locktoref[ig]   ),  // Force lock-to-data stream (TODO - active low)
            .rx_discdrreset (rx_cdr_reset_disable[ig]),
            .rx_clklow      ( /* unused */          ),
            .rx_fref        ( /* unused */          ),
            .rx_ppmlock     ( rx_ppmlock[ig]        ),
            .rx_clkdivrx    ( rx_clkout[ig]         ),
            .rx_is_lockedtoref(rx_is_lockedtoref[ig]    ),  
            .rx_is_lockedtodata(rx_is_lockedtodata[ig]  ),
            .rx_dataout ( rx_parallel_data[ig*att_data_path_width+:att_data_path_width]),
    
            // TX ports
            .tx_rxdetclk    ( /*UNUSED*/ ),  // Clock for detection of downstream receiver (125MHz ?)
            .tx_dataout     (tx_serial_data[ig]     ),  // TX serial data output
            .tx_rstn        (~tx_analogreset[ig]    ),  // TODO - Examine resets
            .tx_datain      (tx_parallel_data[ig*att_data_path_width+:att_data_path_width]),  // TX serial data output
            .tx_ser_clk     (pll_out_clk[ig]        ),  // High-speed serial clock from PLL
            .tx_clkdivtx    (tx_clkout[ig]          ),
            //output ports for cgb
    
            // sv_xcvr_avmm ports
            .reconfig_to_xcvr                     (rcfg_to_xcvr   [NUM_AVMM_INTERFACES*ig*w_bundle_to_xcvr +: NUM_AVMM_INTERFACES*w_bundle_to_xcvr] ),
            .reconfig_from_xcvr                   (rcfg_from_xcvr [NUM_AVMM_INTERFACES*ig*w_bundle_from_xcvr +: NUM_AVMM_INTERFACES*w_bundle_from_xcvr] ) 
          );
  
  end //if((ig % bonded_group_size) == 0) begin
end 
endgenerate


// Merge critical reconfig signals
sv_reconfig_bundle_merger #(
    .reconfig_interfaces(reconfig_interfaces)
) sv_reconfig_bundle_merger_inst (
  // Reconfig buses to/from reconfig controller
  .rcfg_reconfig_to_xcvr  (reconfig_to_xcvr   ),
  .rcfg_reconfig_from_xcvr(reconfig_from_xcvr ),

  // Reconfig buses to/from native xcvr
  .xcvr_reconfig_to_xcvr  (rcfg_to_xcvr   ),
  .xcvr_reconfig_from_xcvr(rcfg_from_xcvr )
);

`undef data_rate_int    
endmodule
