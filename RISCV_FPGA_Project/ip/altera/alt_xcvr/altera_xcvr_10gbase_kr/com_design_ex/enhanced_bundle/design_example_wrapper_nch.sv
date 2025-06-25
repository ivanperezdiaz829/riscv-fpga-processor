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


//============================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA 
// copyright notice must be reproduced on all authorized copies.
//============================================================================
//

`timescale 1 ps / 1 ps 

//=====================================================================================
// Define Parameters (see below for more paramaters to modify for Quartus compilation)
//=====================================================================================
`define NO_CHANNEL 2             // Define number of channels. Note that this only applies to 
                                    // compilation and will not be reflected in the 
                                    // test_harness.sv file for simulation. 
`define CLK_MGMT 10000
`define CLK_1G 8000
`define CLK_10G 3103
//=====================================================================================

module design_example_wrapper_nch #(CHANNELS = `NO_CHANNEL) (
     // Instantiate IO Ports/Pins for HW mode.
     // Sim mode connects wires internally
`ifndef SIM        //hw mode
    input     wire [1:0]                 pll_ref_clk,
    input     wire                     phy_mgmt_clk,
    input     wire                     phy_mgmt_clk_reset,
    input     wire [CHANNELS-1:0]     rx_serial_data,
    output     wire [CHANNELS-1:0]     tx_serial_data
`endif
);

// *************************************************************************
// ********************* MODIFY THESE PARAMETERS ***************************
// *************************************************************************
localparam SYNTH_AN_DE              = 0;                 // Include Auto Negotiation logic in the PH
localparam SYNTH_LT_DE              = 0;                 // Include Link Training logic in the PHY 
localparam OPTIONAL_RXEQ            = 0;                 // Enable RX equalization
localparam RECONFIG_CONTROLLER_DFE  = 0;                 // Turn on Reconfig controller DFE feature
localparam RECONFIG_CONTROLLER_CTLE = 0;                 // Turn on Reconfig controller CTLE feature 
localparam USER_RECONFIG_CONTROL    = 1;		 // Expose reconfiguration interface for user control
localparam SYNTH_FEC_DE             = 0;                 // Synthesize/include the FEC logic+10GSoft PCS
localparam CAPABLE_FEC              = 0;                 // Power up value of fec_ability
localparam ENABLE_FEC               = 0;                 // Power up value of fec_request
localparam SYNTH_SEQ_DE             = 1;                 // Include Sequencer logic in the PHY 
localparam SYNTH_GIGE_DE            = 1;                 // Include GIGE logic in the PHY 
localparam SYNTH_CL37ANEG_DE        = 0;                 // Include Clause 37 logic in the PHY
localparam AN_TECH_DE               = 6'd5 ;             // Set Technology Ability Field.  6'd5 for 1G/10G, 6'd4 for 10G only. Make sure this matches SYNTH_GIGE_DE setting.
localparam SYNTH_1588_DE            = 0 ;                // This parameter enables or disables IEEE 1588 logic in the PHY.
localparam TENG_REFCLK              = "322.265625 Mhz";  // Set 10G refclk. Possible values are "322.265625 MHz" and "644.53125 MHz"
localparam PLL_TYPE_10G				= "ATX";			 // PLL type for 10G link.  ATX recommended.
localparam PLL_TYPE_1G				= "CMU";			 // PLL type for 1G link.  
// *************************************************************************
  
`ifdef SIM
    wire [CHANNELS-1:0] rx_serial_data;
    wire [CHANNELS-1:0] tx_serial_data;
`endif

   reg  [CHANNELS*1-1:0]     gmii_tx_data_en_all;
   wire [CHANNELS*1-1:0]     gmii_tx_data_err_all,gmii_rx_data_err_all;
   reg  [CHANNELS*72-1:0]    xgmii_tx_dc_all;
   wire [CHANNELS*72-1:0]    xgmii_rx_dc_all;
   reg  [CHANNELS*8-1:0]     gmii_tx_d_all;
   wire [CHANNELS*8-1:0]     gmii_rx_d_all;
   wire [CHANNELS-1:0]       gmii_tx_dv_all;
   wire [CHANNELS-1:0]       gmii_rx_dv_all;
   
   wire [7:0]                gmii_tx_d;
   wire [7:0]                gmii_rx_d;
   wire                      ch0_gmii_rx_dv,ch1_gmii_rx_dv,gmii_rx_dv;
   wire                      ch0_gmii_rx_en,ch0_gmii_rx_err ; 
   wire                      ch1_gmii_rx_en,ch1_gmii_rx_err ; 
   wire                      ch0_tx_clkout_1g,ch0_rx_clkout_1g;
   wire [71:0]               xgmii_tx_dc;
   wire [71:0]               xgmii_rx_dc;
   wire [15:0]               phy_mgmt_address;
   wire [31:0]               phy_mgmt_writedata;
   wire [31:0]               phy_mgmt_readdata;
   
   wire [1:0]                dmi_lcl_coefh = 2'd0;
   wire [1:0]                dmo_lcl_coefh;
   wire [5:0]                dmi_lcl_coefl = 6'd0;
   wire [5:0]                dmo_lcl_coefl;
   
   wire                      dmi_frame_lock = 1'b0;
   wire                      dmi_rmt_rx_ready = 1'b0;
   wire                      dmi_lcl_upd_new = 1'b0;
   wire                      dmi_rx_trained = 1'b0;
   
   wire                      tx_clkout_1g, rx_clkout_1g;
   wire [CHANNELS-1:0]       tx_clkout_1g_all, rx_clkout_1g_all;
   wire                      xgmii_rx_clk, xgmii_tx_clk,rx_ready_gmii;
   wire [CHANNELS-1:0]       pll_locked, tx_ready, rx_ready;
   wire [CHANNELS-1:0]       tx_cal_busy, rx_cal_busy;
   wire [CHANNELS-1:0]       reconfig_busy;
   wire [CHANNELS-1:0]       dmo_frame_lock,dmo_rmt_rx_ready,dmo_lcl_upd_new,dmo_rx_trained;
   wire [CHANNELS-1:0]       gmii_tx_en;
   wire [CHANNELS-1:0]       gmii_tx_err, gmii_rx_err;
   wire                      reset_rc_bundle, reset_rmt_rc_bndl;
   wire [CHANNELS-1:0]       reconfig_req, reconfig_rom1_rom0bar;
   wire                      phy_mgmt_read;
   wire                      phy_mgmt_write, phy_mgmt_waitrequest;


//===========================================================================
// create the clocks & resets
//============================================================================
`ifdef SIM
  reg     [1:0]                  pll_ref_clk;  // bit-0 is 1G, bit-1 is 10G
  reg                            phy_mgmt_clk, phy_mgmt_clk_reset;

   initial
     begin
        phy_mgmt_clk = 1'b0;
        #10ns forever #(`CLK_MGMT/2) phy_mgmt_clk = ~phy_mgmt_clk;
     end

   initial
     begin
        phy_mgmt_clk_reset = 1'b0;
        @ (posedge phy_mgmt_clk);
        phy_mgmt_clk_reset = 1'b1;
        repeat (20) @ (posedge phy_mgmt_clk);
        phy_mgmt_clk_reset = 1'b0;
     end

   // 1G ref clock
   // 125 MHz or 62.5 MHz
   initial
     begin
        pll_ref_clk[0] = 1'b0;
        #1ns   forever #(`CLK_1G/2) pll_ref_clk[0] = ~pll_ref_clk[0];
      end
   
   // 10G ref clock
   // 644 MHz or 322 MHz
   initial
     begin
        pll_ref_clk[1] = 1'b0;
        #100ns forever #(`CLK_10G/2) pll_ref_clk[1] = ~pll_ref_clk[1];
     end
`endif

wire reconfig_busy_ored = | reconfig_busy ;  

//============================================================================
// Instantiate the Testing Harness
//============================================================================
test_harness #( 
    .CLOCKS_PER_SECOND   (100_000_000),      // Used for time calculations
    .TEST_HARNESS_TIMOUT (2ms)              // program timeout
  ) test_harness_inst (
  .xgmii_rx_clk         (xgmii_rx_clk         ),
  .xgmii_tx_clk         (xgmii_tx_clk         ),
  .phy_mgmt_clk         (phy_mgmt_clk         ),
  .phy_mgmt_clk_reset   (phy_mgmt_clk_reset),
  .tx_ready             (tx_ready[0]          ),
  .rx_ready             (rx_ready[0]          ),
  .rx_ready_gmii        (rx_ready_gmii        ),
  .reset_rc_bundle      (reset_rc_bundle      ),
  .reset_rmt_rc_bndl    (reset_rmt_rc_bndl    ), 
  .reconfig_req         (reconfig_req         ),
  .reconfig_rom1_rom0bar(reconfig_rom1_rom0bar),
  .reconfig_busy        (reconfig_busy		  ),
  .tx_clkout_1g         (tx_clkout_1g_all[0]  ), 
  .rx_clkout_1g         (rx_clkout_1g_all[0]  ), 
  .gmii_tx_d            (gmii_tx_d            ), 
  .gmii_rx_d            (gmii_rx_d_all[7:0]   ), 
  .gmii_tx_en           (gmii_tx_en           ), 
  .gmii_rx_en           (gmii_rx_dv_all[0]    ), 
  .gmii_tx_err          (gmii_tx_err          ), 
  .gmii_rx_err          (gmii_rx_err          ), 
  .gmii_rx_dv           (1'b0                 ),
  .xgmii_tx_dc          (xgmii_tx_dc          ),
  .xgmii_rx_dc          (xgmii_rx_dc_all[71:0]),
  .phy_mgmt_address     (phy_mgmt_address     ),
  .phy_mgmt_read        (phy_mgmt_read        ),
  .phy_mgmt_readdata    (phy_mgmt_readdata    ),
  .phy_mgmt_waitrequest (phy_mgmt_waitrequest ),
  .phy_mgmt_write       (phy_mgmt_write       ),
  .phy_mgmt_writedata   (phy_mgmt_writedata   )
);


//============================================================================
// Make XGMII/GMII and serial data connections for 2 channel design.  
// If you want more or less channels, these connections need to change
//============================================================================

    wire lcl_en_avalon;  // enable avalon for the local instance of the PHY
    assign lcl_en_avalon = (phy_mgmt_address[15:12] == 4'd0);
    
    // Connect PHYs in loopback as shown in the figure in the user guide CH0 --> CH1  and CH2--> CH3
    /// serial data connections
    `ifdef SIM
        assign rx_serial_data[1] = tx_serial_data[0]; 
        assign rx_serial_data[0] = tx_serial_data[1]; 
    `endif
    
    // XGMII data connections
	 always @ (posedge xgmii_tx_clk) begin 
           xgmii_tx_dc_all[71:0]     <= xgmii_tx_dc;              // TestHarness -->CH0
	   xgmii_tx_dc_all[143:72]   <= xgmii_rx_dc_all[143:72];  // CH1 --> CH1- parallel loop back
	 end
    
    // GMII data connections
    always @ (posedge tx_clkout_1g_all[0]) begin
      gmii_tx_d_all[7:0]       <= gmii_tx_d ; 
      gmii_tx_data_en_all[0]   <= gmii_tx_en;
    end

    always @ (posedge tx_clkout_1g_all[1]) begin
      gmii_tx_d_all[15:8]      <= gmii_rx_d_all[15:8];     // CH1 --> CH1- parallel loop-back
      gmii_tx_data_en_all[1]   <= gmii_rx_dv_all[1];
    end

    assign gmii_tx_data_err_all   = {CHANNELS{1'b0}};


sv_rcn_wrapper # 
  (
   .CHANNELS                 (CHANNELS),
   .SYS_CLK_IN_MHZ           (100),
   .PLL_REF_CLK_IN_MHZ       (TENG_REFCLK),        // 10G reference clock. 
   .AN_TECH                  (AN_TECH_DE),         // Technology ability setting.  Passed in from above.
   .KR_PHY_SYNTH_AN          (SYNTH_AN_DE),        // Include Auto Negotiation logic in the PHY
   .KR_PHY_SYNTH_LT          (SYNTH_LT_DE),        // Include Link Training logic in the PHY
   .KR_PHY_SYNTH_FEC         (SYNTH_FEC_DE),       // Synthesize/include the FEC logic+10GSoft PCS
   .SYNTH_SEQ                (SYNTH_SEQ_DE),       // Include Sequencer logic in the PHY
   .KR_PHY_SYNTH_GIGE        (SYNTH_GIGE_DE),      // Include GIGE logic in the PHY
   .SYNTH_GMII               (SYNTH_GIGE_DE),      // Include GMII PCS in the PHY (this must always be 1 if using 1G mode is enabled)
   .SYNTH_CL37ANEG           (SYNTH_CL37ANEG_DE),  // Include Clause 37 logic in the PHY
   .SYNTH_1588_1G            (SYNTH_1588_DE),      // Include 1588 1G logic in the PHY
   .SYNTH_1588_10G           (SYNTH_1588_DE),      // Include 1588 10G logic in the PHY
   .KR_PHY_LFT_R_MSB         (6'd50),              // Link fail timers for KR.  Values passed are for a 100 MHz system clock.
   .KR_PHY_LFT_R_LSB         (10'd500),            // These values are calculated by the Megawizard
   .KR_PHY_LFT_X_MSB         (6'd4),
   .KR_PHY_LFT_X_LSB         (10'd500),
   .OPTIONAL_RXEQ            (OPTIONAL_RXEQ),
   .RECONFIG_CONTROLLER_DFE  (RECONFIG_CONTROLLER_DFE ),  
   .RECONFIG_CONTROLLER_CTLE (RECONFIG_CONTROLLER_CTLE),  
   .USER_RECONFIG_CONTROL    (USER_RECONFIG_CONTROL),
   .CAPABLE_FEC              (CAPABLE_FEC),
   .ENABLE_FEC               (ENABLE_FEC),
   .KR_PHY_BERWIDTH          (8),                   // Width of BER counter for Link Training in KR mode.  Valid range is 4-8.
   .PLL_TYPE_10G             (PLL_TYPE_10G),        // PLL Type for 10G data.  ATX is recommended.
   .PLL_TYPE_1G				 (PLL_TYPE_1G)			// PLL Type for 1G data.
   ) LOCAL_sv_rc_wrapper
   (
     .pll_ref_clk_10g         (pll_ref_clk[1]        ),
     .pll_ref_clk_1g          (pll_ref_clk[0]        ),
     .xgmii_tx_clk            (xgmii_tx_clk          ),
     .xgmii_rx_clk            (xgmii_rx_clk          ),
     .rx_recovered_clk        (                      ),
     .generic_pll_rst         (phy_mgmt_clk_reset),
     .reset_rc_bundle         (reset_rc_bundle),
     .rx_serial_data          (rx_serial_data       ),
     .tx_serial_data          (tx_serial_data       ),
     .gmii_tx_data            (gmii_tx_d_all        ), // connecting Ch0 GMII ports to Test Harness
     .gmii_rx_data            (gmii_rx_d_all        ), // connecting Ch0 GMII ports to Test Harness
     .gmii_tx_data_en         (gmii_tx_data_en_all  ), // connecting Ch0 GMII ports to Test Harness
     .gmii_tx_err             (gmii_tx_data_err_all ), // connecting Ch0 GMII ports to Test Harness
     .gmii_rx_err             (gmii_rx_data_err_all ), // connecting Ch0 GMII ports to Test Harness
     .gmii_rx_dv              (gmii_rx_dv_all       ), // connecting Ch0 GMII ports to Test Harness
     .tx_clkout_1g            (tx_clkout_1g_all     ), 
     .rx_clkout_1g            (rx_clkout_1g_all     ), 
     .xgmii_tx_dc             (xgmii_tx_dc_all      ),
     .xgmii_rx_dc             (xgmii_rx_dc_all      ),
     .tx_ready                (tx_ready             ),
     .rx_ready                (rx_ready             ),
     .pll_locked              (pll_locked           ),
     .tx_cal_busy             (tx_cal_busy          ),
     .rx_cal_busy             (rx_cal_busy          ),
     .lcl_rf                  ({CHANNELS{1'b0}}     ),
     .reconfig_req            ({CHANNELS{reconfig_req}}),  
     .reconfig_rom1_rom0bar   ({CHANNELS{reconfig_rom1_rom0bar}}), 
     .reconfig_busy           (reconfig_busy        ), 
     // avalon ports
     .phy_mgmt_address        (phy_mgmt_address[11:0]),
     .phy_mgmt_clk            (phy_mgmt_clk          ),
     .phy_mgmt_clk_reset      (phy_mgmt_clk_reset),
     .phy_mgmt_read           (phy_mgmt_read           ),
     .phy_mgmt_writedata      (phy_mgmt_writedata    ),
     .phy_mgmt_write          (phy_mgmt_write            ),
     .phy_mgmt_readdata       (phy_mgmt_readdata        ),
     .phy_mgmt_waitrequest    (phy_mgmt_waitrequest    ),

     .avmm_address            (8'b0),
     .avmm_read               (1'b0),
     .avmm_write              (1'b0),
     .avmm_writedata          (32'b0),
     .avmm_readdata           (),
     .avmm_waitrequest        ()
     );

endmodule 
