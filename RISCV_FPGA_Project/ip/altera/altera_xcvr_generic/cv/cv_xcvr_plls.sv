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


//
// Multiple PLL block, with a single output clock
// 
// Clock switching must use the exported reconfiguration ports
//
// $Header$
//

`timescale 1 ns / 1 ns

import altera_xcvr_functions::*;

module cv_xcvr_plls #(
  parameter plls                                  = 1,        // number of PLLs
  parameter pll_type                              = "AUTO",   // "AUTO","CMU","ATX","fPLL"
  parameter refclks                               = 1,        // number of refclks per PLL
  parameter reference_clock_frequency             = "0 ps",   // refclk frequencies (comma separated list)
  parameter reference_clock_select                = "0",      // refclk_sel per pll (comma separated list)
  parameter output_clock_datarate                 = "0 Mbps", // outclk data rate (frequency*2)(comma separated list), Not used if left at "0 Mbps"
  parameter output_clock_frequency                = "0 ps",   // outclk frequency (comma separated list), Only used if output_clock_datarate unused.
  parameter sim_additional_refclk_cycles_to_lock  = 0,        // 
  parameter duty_cycle                            = 50,       // duty cycle (comma separated list)
  parameter phase_shift                           = "0 ps",   // phase shift (comma separated list)
  parameter enable_avmm                           = 0         // 1=include AVMM blocks

) (
  input   wire  [refclks -1:0]  refclk,
  input   wire  [plls    -1:0]  rst,
  input   wire  [plls    -1:0]  fbclk,
  
  output  wire  [plls    -1:0]  outclk,
  output  wire  [plls    -1:0]  locked,
  output  wire  [plls    -1:0]  fboutclk

  // 
  //input   wire  [plls*W_S5_RECONFIG_BUNDLE_TO_XCVR  -1 :0] reconfig_to_xcvr,
  //output  wire  [plls*W_S5_RECONFIG_BUNDLE_FROM_XCVR-1 :0] reconfig_from_xcvr
);

localparam  w_bundle_to_xcvr  = W_S5_RECONFIG_BUNDLE_TO_XCVR;
localparam  w_bundle_from_xcvr= W_S5_RECONFIG_BUNDLE_FROM_XCVR;

genvar ig;      // Iterator for generated loops
generate
  for(ig=0; ig<plls; ig = ig + 1) begin: pll
      // Determine initial reference clock frequency
      localparam  [MAX_CHARS*8-1:0] refclk_sel_sel  = get_value_at_index(ig,reference_clock_select);
      localparam  [MAX_CHARS*8-1:0] refclk_sel_fnl  = str2int(refclk_sel_sel); 
      localparam  [MAX_CHARS*8-1:0] refclk_freq_fnl = get_value_at_index(refclk_sel_fnl,reference_clock_frequency);
      // Determine initial output clock frequency
      localparam  [MAX_CHARS*8-1:0] outclk_rate_sel = get_value_at_index(ig,output_clock_datarate);
      localparam  [MAX_CHARS*8-1:0] outclk_freq_sel = get_value_at_index(ig,output_clock_frequency);
      localparam  [MAX_CHARS*8-1:0] outclk_freq_fnl = (outclk_rate_sel == "NA" || outclk_rate_sel == "0 Mbps") ? outclk_freq_sel :
                                                      hz2str(str2hz(outclk_rate_sel) / 2);

      // Determine PLL type
      localparam  [MAX_CHARS*8-1:0] pll_type_sel  = get_value_at_index(ig,pll_type);
      localparam  [MAX_CHARS*8-1:0] pll_type_fnl  = (pll_type_sel == "ATX")   ? "-name PLL_TYPE ATX"  : 
                                                    (pll_type_sel == "fPLL")  ? "-name PLL_TYPE fPLL" :
                                                    (pll_type_sel == "CMU")   ? "-name PLL_TYPE CMU"  :
                                                    (pll_type_sel == "AUTO")  ? "-name PLL_TYPE CMU"  :
                                                    "";
      
      //assign  reconfig_from_xcvr= {(plls*w_bundle_from_xcvr){1'b0}};
      // Create generic TX pll
      //(* altera_attribute = pll_type_fnl *)
      generic_pll #(  
          .reference_clock_frequency(refclk_freq_fnl),
          .output_clock_frequency   (outclk_freq_fnl)
      ) tx_pll (
        .fbclk              (fbclk    [ig]  ),
        .fboutclk           (fboutclk [ig]  ),
        .refclk             (refclk   [refclk_sel_fnl]  ),
        .rst                (rst      [ig]  ),
        .outclk             (outclk   [ig]  ),
        .locked             (locked   [ig]  ),

        // Inputs from Generic PLL Adapter
        .writerefclkdata    (/*unused*/     ),
        .writeoutclkdata    (/*unused*/     ),
        .writephaseshiftdata(/*unused*/     ),
        .writedutycycledata (/*unused*/     ),
        // Outputs to Generic PLL Adapter
        .readrefclkdata     (/*unused*/     ),
        .readoutclkdata     (/*unused*/     ),
        .readphaseshiftdata (/*unused*/     ),
        .readdutycycledata  (/*unused*/     )
      );
  end
endgenerate

endmodule
