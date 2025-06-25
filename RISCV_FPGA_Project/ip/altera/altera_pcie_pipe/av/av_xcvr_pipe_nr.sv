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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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


`timescale 1ps/1ps

import altera_xcvr_functions::*; //for get_custom_reconfig_to_width and get_custom_reconfig_from_width

//**************************************************************************************
// Protocol native + Reset Controller + CSR for StratixV
//**************************************************************************************

module av_xcvr_pipe_nr #(
  parameter lanes = 1,                                //legal value: 1+
  parameter starting_channel_number = 0,              //legal value: 0+
  parameter protocol_version = "Gen 2",               //legal value: "Gen 1", "Gen 2" -- must be consistent with hw.tcl
         parameter pll_type  = "AUTO",                       //legal value: "CMU", "ATX" 
  parameter base_data_rate = "0 Mbps",             //legal values: PLL rate. Can be (data rate * 1,2,4,or 8)
                                                               // Gen1: data rate = 2500 Mbps. 
                                                               // Gen2: data rate = 5000 Mbps. 
  parameter pll_refclk_freq = "100 MHz",              //legal value = "100 MHz", "125 MHz"
  parameter deser_factor = 16,                        //legal value: 8,10
  parameter pipe_low_latency_syncronous_mode = 0,     //legal value: 0, 1
  parameter pipe_run_length_violation_checking = 160, //legal value:[160:5:5], max (6'b0) is the default value
  parameter pipe_elec_idle_infer_enable = "false",    //legal value: true, false
  //system clock rate
  parameter mgmt_clk_in_mhz=150
) ( 

  // user data (avalon-MM slave interface) //for all the channel rst, powerdown, rx serilize loopback enable
  input   wire    phy_mgmt_clk_reset,
  input   wire    phy_mgmt_clk,
  input   wire [7:0]  phy_mgmt_address,
  input   wire    phy_mgmt_read,
  output  wire [31:0]  phy_mgmt_readdata,
  input   wire    phy_mgmt_write,
  input   wire [31:0]  phy_mgmt_writedata,
  output  wire    phy_mgmt_waitrequest,
  
  //clk signal
  input  wire  pll_ref_clk,
  input  wire  fixedclk,
    
  //data ports - Avalon ST interface
  //pipe interface ports
  input  wire [lanes*deser_factor - 1:0]      pipe_txdata,
  input  wire [(lanes*deser_factor)/8 -1:0]   pipe_txdatak,
  input  wire [lanes - 1:0]                   pipe_txcompliance,
  input  wire [lanes - 1:0]                   pipe_txelecidle,
  input  wire [lanes - 1:0]                   pipe_rxpolarity,
  output wire [lanes*deser_factor -1:0]       pipe_rxdata,
  output wire [(lanes*deser_factor)/8 -1:0]   pipe_rxdatak,
  output wire [lanes - 1:0]                   pipe_rxvalid,
  output wire [lanes - 1:0]                   pipe_rxelecidle,
  output wire [lanes*3-1:0]                   pipe_rxstatus,
  input  wire [lanes-1 :0]                    pipe_txdetectrx_loopback,  
  input  wire  [lanes-1 :0]                    pipe_txdeemph,
  input  wire [lanes*3-1:0]                   pipe_rxpresethint,
  input  wire [lanes*3-1:0]                   pipe_txmargin,
  input  wire [lanes-1 :0]                    pipe_txswing,
  input  wire [lanes*3-1:0]                   rx_eidleinfersel,
  
   // since this block is instantiated only by non-HIP mode, this
   // common pipe_rate signal will be broadcast to all channels. 
  input   wire               pipe_rate,

  input  wire  [lanes*2-1 :0]  pipe_powerdown,
  output wire  [lanes-1 :0]  pipe_phystatus,
    
  //conduit
  input  wire  [lanes-1:0]  rx_serial_data,
  output wire  [lanes-1:0]  tx_serial_data,
  output wire                  tx_ready,
  output wire                  rx_ready,
  
  output wire                                  pll_locked,
  output wire  [lanes-1:0]                  rx_is_lockedtodata,
  output wire  [lanes-1:0]                  rx_is_lockedtoref,
  output wire  [(lanes*deser_factor)/8-1:0]  rx_syncstatus,
  output wire  [lanes-1:0]                     rx_signaldetect,
    
  //clock outputs
  output wire  pipe_pclk,
 
        //Reconfig interface
        // Gen 1/Gen 2. TODO for Gen3.
        // Non-HIP x8  - 8 channels + 1 Tx PLL 
        // Non-HIP x4  - 4 channels + 1 Tx PLL  
        // Non-HIP x1  - 1 channel  + 1 Tx PLL  
        // get_custom_reconfig_to_width  (device_family,operation_mode,lanes,plls,bonded_group_size)-1:0] 
  input  wire  [get_custom_reconfig_to_width  ("Arria V","Duplex",lanes,1,lanes)-1:0] reconfig_to_xcvr,
  output wire  [get_custom_reconfig_from_width("Arria V","Duplex",lanes,1,lanes)-1:0] reconfig_from_xcvr 
);

  localparam reconfig_interfaces  = get_custom_reconfig_interfaces("Arria V","Duplex",lanes,1,lanes);
  
  wire [lanes - 1 : 0]               tx_forceelecidle_wire;
  wire [lanes - 1 : 0]               rx_seriallpbken_wire;
  wire [lanes - 1 : 0]               rx_rlv_wire;
  wire [(lanes*deser_factor)/8-1:0]  rx_patterndetect_wire;
  
  wire [(lanes*deser_factor)/8-1:0]  rx_syncstatus_wire;
  wire [(lanes*deser_factor)/8-1:0]  rx_errdetect_wire;
  wire [(lanes*deser_factor)/8-1:0]  rx_disperr_wire;
  wire [lanes*5 - 1 : 0]             rx_bitslipboundaryselectout_wire;
  wire [lanes - 1 : 0]               rx_is_lockedtoref_wire;
  wire [lanes - 1 : 0]               rx_is_lockedtodata_wire;
  wire [lanes - 1 : 0]               rx_signaldetect_wire;
  wire                               pll_locked_wire;
  wire [lanes - 1 : 0]               rx_phase_comp_fifo_error_wire;
  wire [lanes - 1 : 0]               tx_phase_comp_fifo_error_wire;
  
  //////////////////////////////////
  // Control & status register map (CSR) outputs
  //////////////////////////////////

  wire                    csr_reset_tx_digital;         //to reset controller
  wire                    csr_reset_rx_digital;         //to reset controller
  wire                    csr_reset_all;                //to reset controller
  wire                    csr_pll_powerdown;            //to xcvr instance
  wire [lanes-1:0]        csr_tx_digitalreset;          //to xcvr instance
  wire [lanes-1:0]        csr_rx_analogreset;           //to xcvr instance
  wire [lanes-1:0]        csr_rx_digitalreset;          //to xcvr instance
  wire [lanes-1:0]        csr_phy_loopback_serial;      //to xcvr instance
  wire [lanes-1:0]        csr_tx_invpolarity;           //to xcvr instance
  wire [lanes-1:0]        csr_rx_invpolarity;           //to xcvr instance
  wire [lanes-1:0]        csr_rx_set_locktoref;         //to xcvr instance
  wire [lanes-1:0]        csr_rx_set_locktodata;        //to xcvr instance
  wire [lanes*5 - 1 : 0]  csr_tx_bitslipboundaryselect; //to xcvr instance
  wire [lanes - 1 : 0]    csr_rx_enapatternalign;       //to xcvr instance
  wire [lanes - 1 : 0]    csr_rx_bitreversalenable;     //to xcvr instance
  wire [lanes - 1 : 0]    csr_rx_bytereversalenable;    //to xcvr instance
  wire [lanes - 1 : 0]    csr_rx_bitslip;               //to xcvr instance
   
     // readdata output from both CSR blocks
  wire [31:0]  mgmt_readdata_common;
  wire [31:0]  mgmt_readdata_pcs;


  //////////////////////////////////
  //reset controller outputs
  //////////////////////////////////
  wire  [lanes-1:0]     reset_controller_tx_ready;
  wire  [lanes-1:0]     reset_controller_rx_ready;
  wire                  reset_controller_pll_powerdown;
  wire  [lanes-1:0]     reset_controller_tx_digitalreset;
  wire  [lanes-1:0]     reset_controller_rx_analogreset;
  wire  [lanes-1:0]     reset_controller_rx_digitalreset;

  // wire        reconfig_busy;  // Reconfig_busy signal from external reconfig

  // Calibration busy signals
  wire  [lanes-1:0] tx_cal_busy;
  wire  [lanes-1:0] rx_cal_busy;
  
  
  av_xcvr_pipe_native #(
    .lanes                              (lanes                             ),
    .pll_refclk_freq                    (pll_refclk_freq                   ),
    .starting_channel_number            (starting_channel_number           ),
    .pipe_run_length_violation_checking (pipe_run_length_violation_checking),
    .pipe_elec_idle_infer_enable        (pipe_elec_idle_infer_enable       ),
    .hip_enable                         ("false"                           ),
    .hip_hard_reset                     ("disable"                         ),
    .pipe_low_latency_syncronous_mode   (pipe_low_latency_syncronous_mode  ),
    .protocol_version                   (protocol_version                  ),
    .deser_factor                       (deser_factor                      )
    ) transceiver_core (
    .pll_powerdown                      (csr_pll_powerdown                 ), 
    .tx_analogreset                     (csr_pll_powerdown                 ), 
    .tx_digitalreset                    (csr_tx_digitalreset               ),
    .rx_analogreset                     (csr_rx_analogreset                ),
    .rx_digitalreset                    (csr_rx_digitalreset               ),
    .pll_ref_clk                        (pll_ref_clk                       ),
    .fixedclk                           (fixedclk                          ),
    .pipe_txdata                        (pipe_txdata                       ),
    .pipe_rxdata                        (pipe_rxdata                       ),
    .pipe_txdatak                       (pipe_txdatak                      ),
    .pipe_rxdatak                       (pipe_rxdatak                      ),
    .pipe_txcompliance                  (pipe_txcompliance                 ),
    .pipe_txelecidle                    (pipe_txelecidle                   ),
    .pipe_rxpolarity                    (pipe_rxpolarity                   ),
    .pipe_rxvalid                       (pipe_rxvalid                      ),
    .pipe_rxelecidle                    (pipe_rxelecidle                   ),
    .pipe_rxstatus                      (pipe_rxstatus                     ),
    .pipe_txdetectrx_loopback           (pipe_txdetectrx_loopback          ),
    .pipe_txdeemph                      (pipe_txdeemph                     ),
    .pipe_txmargin                      (pipe_txmargin                     ),
    .pipe_txswing                       (pipe_txswing                      ),
    .pipe_rate                          ({lanes{pipe_rate}}                ),
    .pipe_powerdown                     (pipe_powerdown                    ),
    .pipe_phystatus                     (pipe_phystatus                    ),
    .rx_eidleinfersel                   (rx_eidleinfersel                  ),
    .rx_serial_data                     (rx_serial_data                    ),
    .tx_serial_data                     (tx_serial_data                    ),
    .pipe_pclk                          (pipe_pclk                         ),
    //MM ports
    .tx_invpolarity                     (csr_tx_invpolarity                ),
    .rx_set_locktodata                  (csr_rx_set_locktodata             ),
    .rx_set_locktoref                   (csr_rx_set_locktoref              ),
    .rx_rlv                             (rx_rlv_wire                       ),
    .rx_patterndetect                   (rx_patterndetect_wire             ),
    .rx_syncstatus                      (rx_syncstatus_wire                ),
    .rx_errdetect                       (rx_errdetect_wire                 ),
    .rx_disperr                         (rx_disperr_wire                   ),
    .rx_bitslipboundaryselectout        (rx_bitslipboundaryselectout_wire  ),
    .tx_cal_busy                        (tx_cal_busy                       ),
    .rx_cal_busy                        (rx_cal_busy                       ),
    .rx_is_lockedtoref                  (rx_is_lockedtoref_wire            ),
    .rx_is_lockedtodata                 (rx_is_lockedtodata_wire           ),
    .pll_locked                         (pll_locked_wire                   ),
    .rx_phase_comp_fifo_error           (rx_phase_comp_fifo_error_wire     ),
    .tx_phase_comp_fifo_error           (tx_phase_comp_fifo_error_wire     ),
    .rx_signaldetect                    (rx_signaldetect_wire              ),
    .rx_seriallpbken                    (csr_phy_loopback_serial           ),
    
    .reconfig_to_xcvr                   (reconfig_to_xcvr                  ),
    .reconfig_from_xcvr                 (reconfig_from_xcvr                )
  );

  // Instantiate memory map logic for given number of lanes & PLL's
  // Includes all except PCS
  alt_xcvr_csr_common #(
    .lanes(lanes),
    .plls(1),
    .rpc(1)
  ) csr(
    .clk(phy_mgmt_clk),
    .reset(phy_mgmt_clk_reset),
    .address(phy_mgmt_address),
    .read(phy_mgmt_read),
    .write(phy_mgmt_write),
    .writedata(phy_mgmt_writedata),
    .pll_locked(pll_locked_wire),
    .rx_is_lockedtoref(rx_is_lockedtoref_wire),
    .rx_is_lockedtodata(rx_is_lockedtodata_wire),
    .rx_signaldetect(rx_signaldetect_wire),
    .reset_controller_tx_ready(&reset_controller_tx_ready), // 'AND' all bits together - all channels must be ready in a multi-channel design
    .reset_controller_rx_ready(&reset_controller_rx_ready), // 'AND' all bits together - all channels must be ready in a multi-channel design
    .reset_controller_pll_powerdown(reset_controller_pll_powerdown),
    .reset_controller_tx_digitalreset(reset_controller_tx_digitalreset),
    .reset_controller_rx_analogreset(reset_controller_rx_analogreset),
    .reset_controller_rx_digitalreset(reset_controller_rx_digitalreset),
    .readdata(mgmt_readdata_common),
    .csr_reset_tx_digital(csr_reset_tx_digital),
    .csr_reset_rx_digital(csr_reset_rx_digital),
    .csr_reset_all(csr_reset_all),
    .csr_pll_powerdown(csr_pll_powerdown),
    .csr_tx_digitalreset(csr_tx_digitalreset),
    .csr_rx_analogreset(csr_rx_analogreset),
    .csr_rx_digitalreset(csr_rx_digitalreset),
    .csr_phy_loopback_serial(csr_phy_loopback_serial),
    .csr_rx_set_locktoref(csr_rx_set_locktoref),
    .csr_rx_set_locktodata(csr_rx_set_locktodata)
  );
  
  // Instantiate PCS memory map logic for given number of lanes
  alt_xcvr_csr_pcs8g #(
    .lanes(lanes)
  ) csr_pcs (
    .clk(phy_mgmt_clk),
    .reset(phy_mgmt_clk_reset),
    .address(phy_mgmt_address),
    .read(phy_mgmt_read),
    .write(phy_mgmt_write),
    .writedata(phy_mgmt_writedata),
    .readdata(mgmt_readdata_pcs),
    .rx_clk(pipe_pclk), 
    .tx_clk(pipe_pclk), 
    .rx_errdetect({{(lanes*(deser_factor == 32 ? 4: 2)-lanes*deser_factor/8){1'b0}}, rx_errdetect_wire}),
    .rx_disperr({{(lanes*(deser_factor == 32 ? 4: 2)-lanes*deser_factor/8){1'b0}}, rx_disperr_wire}),
    .rx_patterndetect({{(lanes*(deser_factor == 32 ? 4: 2)-lanes*deser_factor/8){1'b0}}, rx_patterndetect_wire}),
    .rx_syncstatus({{(lanes*(deser_factor == 32 ? 4: 2)-lanes*deser_factor/8){1'b0}}, rx_syncstatus_wire}),
    .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout_wire),
    .rlv(rx_rlv_wire),
    .rx_a1a2sizeout({lanes*2{1'b0}}), //Not used for PCIe
    .rx_phase_comp_fifo_error(rx_phase_comp_fifo_error_wire),
    .tx_phase_comp_fifo_error(tx_phase_comp_fifo_error_wire),
    .csr_tx_invpolarity(csr_tx_invpolarity),
    .csr_rx_invpolarity(),
    .csr_tx_bitslipboundaryselect(),
    .csr_rx_bitreversalenable(),
    .csr_rx_enapatternalign(),
    .csr_rx_bytereversalenable(),
    .csr_rx_bitslip(),
    .csr_rx_a1a2size()
    );
  
  // combine readdata output from both CSR blocks
  // each decodes non-overlapping addresses, and outputs "11..111" for undecoded addresses,
  // so an AND is sufficient
  assign phy_mgmt_readdata = mgmt_readdata_common & mgmt_readdata_pcs;
  
  // Reset Controller 
  altera_xcvr_reset_control
  #(
    .CHANNELS             (lanes                  ),  // number of channels 
    .SYNCHRONIZE_RESET    (0                      ),  // 0 = NOT using synchronized reset  
    .SYNCHRONIZE_PLL_RESET(0                      ),  // 0 = NOT using synchronized reset input for PLL powerdown
    //Reset timings 
    .SYS_CLK_IN_MHZ       (mgmt_clk_in_mhz        ),  // clock frequency in MHz
    .REDUCED_SIM_TIME     (1                      ),  // 1 = use reduced sim time 
    // PLL Options 
    .TX_PLL_ENABLE        (1                      ),  // 1 = enable TX PLL reset  
    .PLLS                 (1                      ),  // number of TX PLLs
    .T_PLL_POWERDOWN      (1000                   ),  // pll_powerdown in ns
    // TX Options  
    .TX_ENABLE            (1                      ),  // 1 = enable TX resets
    .TX_PER_CHANNEL       (0                      ),  // 0 = shared TX reset for all channels
    .T_TX_DIGITALRESET    (20                     ),  // tx_digitalreset period (after pll_powerdown)
    .T_PLL_LOCK_HYST      (0                      ),  // amount of hysteresis to add to pll_locked
    // RX Options 
    .RX_ENABLE            (1                      ),  // 1 = enable RX resets
    .RX_PER_CHANNEL       (0                      ),  // 0 = shared RX reset for all channels
    .T_RX_ANALOGRESET     (40                     ),  // rx_analogreset period
    .T_RX_DIGITALRESET    (4000                   )   // rx_digitalreset period 
    ) reset_controller (
    // user inputs and outputs 
    .clock                (phy_mgmt_clk           ),  // system clock
    .reset                (phy_mgmt_clk_reset     ),  // asynchronous reset
    // Reset signals 
    .pll_powerdown        (reset_controller_pll_powerdown), // reset TX PLL
    .tx_analogreset       (/* unused */           ),        // reset TX PMA
    .tx_digitalreset      (reset_controller_tx_digitalreset), // reset TX PCS
    .rx_analogreset       (reset_controller_rx_analogreset),// reset RX PMA 
    .rx_digitalreset      (reset_controller_rx_digitalreset), // reset RX PCS
    // Status Outputs 
    .tx_ready             (reset_controller_tx_ready),  // TX is not ready
    .rx_ready             (reset_controller_rx_ready),  // RX is not ready
    // Digital reset override inputs (must be synchronous with clock)
    .tx_digitalreset_or   ({lanes{csr_reset_tx_digital}}), // reset request for tx_digitalreset
    .rx_digitalreset_or   ({lanes{csr_reset_rx_digital}}), // reset request for rx_digitalreset
    // TX Control inputs 
    .pll_locked           (pll_locked_wire        ), // TX PLL is locked status
    .pll_select           (1'b0                   ), // select TX PLL locked signal
    .tx_cal_busy          (tx_cal_busy            ), // TX channel calibration status
    .tx_manual            ({lanes{1'b1}}          ), // 1 = Manual TX reset mode
    // RX Control inputs 
    .rx_is_lockedtodata   (rx_is_lockedtoref_wire ), // RX CDR PLL is locked to ref 
    .rx_cal_busy          (rx_cal_busy            ), // RX channel calibration status
    .rx_manual            ({lanes{1'b1}}          )  // 1 = Manual RX reset mode
    );
    
  //conduit status outputs
  assign pll_locked         = pll_locked_wire;
  assign rx_is_lockedtodata = rx_is_lockedtodata_wire;
  assign rx_is_lockedtoref  = rx_is_lockedtoref_wire;
  assign rx_signaldetect    = rx_signaldetect_wire;
  assign rx_syncstatus      = rx_syncstatus_wire;
  assign tx_ready           = &reset_controller_tx_ready; // 'AND' all bits together - all channels must be ready in a multi-channel design
  assign rx_ready           = &reset_controller_rx_ready; // 'AND' all bits together - all channels must be ready in a multi-channel design

   // generate waitrequest for top channel slave 
   altera_wait_generate top_wait (
          .rst           (phy_mgmt_clk_reset   ),
          .clk           (phy_mgmt_clk         ),
          .launch_signal (phy_mgmt_read        ),
          .wait_req      (phy_mgmt_waitrequest )
          );

endmodule
