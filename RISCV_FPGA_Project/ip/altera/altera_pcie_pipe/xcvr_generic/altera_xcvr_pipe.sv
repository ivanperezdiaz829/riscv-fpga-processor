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



//********************************************************************
// Altera PCI Express PIPE PHY
// Instantiates sv_xcvr_pipe_nr.sv or av_xcvr_pipe_nr.sv
//********************************************************************
`timescale 1 ns / 1 ns

import altera_xcvr_functions::*; //for get_custom_reconfig_to_width and get_custom_reconfig_from_width

module altera_xcvr_pipe #(
	parameter device_family                      = "Stratix V",   //legal value: "Stratix V", "Arria V"
	parameter lanes                              = 1,             //legal value: 1,4,8
	parameter protocol_version                   = "Gen 2",       //legal value: "Gen 1", "Gen 2" 
	parameter base_data_rate                     = "0 Mbps",      //legal values: PLL rate. Can be (data rate * 1,2,4,or 8)
                                                                      // Gen1: data rate = 2500 Mbps. 
                                                                      // Gen2: data rate = 5000 Mbps. 
	parameter pll_type                           = "AUTO",        //legal value: "CMU", "ATX" 
	parameter pll_refclk_freq                    = "100 MHz",     //legal value = "100 MHz", "125 MHz"
	parameter deser_factor                       = 16,            //legal value: 8,10
	parameter pipe_low_latency_syncronous_mode   = 0,             //legal value: 0, 1
	parameter bypass_g3pcs_scrambler_descrambler = 0,             //legal value: 0, 1
	parameter bypass_g3pcs_dcbal                 = 0,             //legal value: 0, 1
	parameter pipe_run_length_violation_checking = 160,           //legal value:[160:5:5], max (6'b0) is the default value
	parameter pipe_elec_idle_infer_enable        = "false",       //legal value: true, false
	//system clock rate
	parameter mgmt_clk_in_mhz                    = 150
) ( 
	// user data (avalon-MM slave interface)
	input  wire        phy_mgmt_clk_reset,
	input  wire        phy_mgmt_clk,
	input  wire [8:0]  phy_mgmt_address,
	input  wire        phy_mgmt_read,
	output reg  [31:0] phy_mgmt_readdata,
	output reg         phy_mgmt_waitrequest,
	input  wire        phy_mgmt_write,
	input  wire [31:0] phy_mgmt_writedata,
	
	//clk signal
	input  wire	pll_ref_clk,
	input  wire	fixedclk,
    
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
	input  wire [lanes-1 :0]	                  pipe_txdetectrx_loopback,
  input  wire	[lanes-1 :0]                    pipe_txdeemph,
  input  wire	[lanes*18-1:0]                  pipe_g3_txdeemph,
	input  wire [lanes*3-1:0]                   pipe_rxpresethint,
  input  wire [lanes*3-1:0]	                  pipe_txmargin,
	input  wire [lanes-1 :0]	                  pipe_txswing,
	input  wire [lanes*3-1:0]	                  rx_eidleinfersel,
  input  wire [lanes -1:0]                    pipe_tx_data_valid, // PIPE 3.0 spec 
  input  wire [lanes -1:0]                    pipe_tx_blk_start,  // PIPE 3.0 spec 
  input  wire [lanes*2-1:0]                   pipe_tx_sync_hdr,   // PIPE 3.0 spec 
      
  output wire [lanes -1:0]                    pipe_rx_data_valid, // PIPE 3.0 spec 
  output wire [lanes -1:0]                    pipe_rx_blk_start,  // PIPE 3.0 spec 
  output wire [lanes*2-1:0]                   pipe_rx_sync_hdr,   // PIPE 3.0 spec 

	 // This common pipe_rate signal will be broadcast to all channels. 
	input  wire [1:0]                           pipe_rate,

	input  wire [lanes*2-1 :0]                  pipe_powerdown,
	output wire [lanes-1 :0]                    pipe_phystatus,
    
	//conduit
	input  wire [lanes-1:0]	                    rx_serial_data,
	output wire [lanes-1:0]	                    tx_serial_data,
	output wire                                 tx_ready,
	output wire                                 rx_ready,
	
	output wire                                 pll_locked,
	output wire [lanes-1:0]	                    rx_is_lockedtodata,
	output wire [lanes-1:0]	                    rx_is_lockedtoref,
	output wire [(lanes*deser_factor)/8-1:0]    rx_syncstatus,
	output wire [lanes-1:0]                     rx_signaldetect,
    
	//clock outputs
	output	wire                                pipe_pclk,

        //Reconfig interfaces
        // Gen 1/Gen 2. TODO for Gen3.
        // Non-HIP x8  - 8 channels + 1 Tx PLL 
        // Non-HIP x4  - 4 channels + 1 Tx PLL  
        // Non-HIP x1  - 1 channel  + 1 Tx PLL  
        // get_custom_reconfig_to_width  (device_family,operation_mode,lanes,plls,bonded_group_size)-1:0] 
	// -device_family workaround to address lack of rtl parameter in previous versions of IP
        input   wire  [get_custom_reconfig_to_width  ((device_family == "Stratix" ? "Stratix V" : device_family),"Duplex",lanes,1,lanes)-1:0] reconfig_to_xcvr,
        output  wire  [get_custom_reconfig_from_width((device_family == "Stratix" ? "Stratix V" : device_family),"Duplex",lanes,1,lanes)-1:0] reconfig_from_xcvr 

);

	localparam STARTING_CHANNEL_NUMBER = 0; //legal value: 0+

        // Decode phy_mgmt_address[8:0] from user. MSB = 0 => CSR. MSB = 1 => Reconfig
	wire [7:0]  phy_mgmt_address_decoded;

        assign phy_mgmt_address_decoded = (phy_mgmt_address[8] == 1'b0) ? phy_mgmt_address[7:0] : 8'b0;

	localparam validated_device_family = device_family == "Stratix" ? "Stratix V" : device_family;
	
	localparam is_s5 = has_s5_style_hssi(validated_device_family);
	localparam is_a5 = has_a5_style_hssi(validated_device_family);

	generate 
	if  (is_s5) begin

sv_xcvr_pipe_nr #(
		.lanes                              (lanes                             ),
		.starting_channel_number            (STARTING_CHANNEL_NUMBER           ),
		.protocol_version                   (protocol_version                  ),
		.pll_type                           (pll_type                          ),
		.base_data_rate                     (base_data_rate                    ),
		.pll_refclk_freq                    (pll_refclk_freq                   ),
		.deser_factor                       (deser_factor                      ),
		.pipe_low_latency_syncronous_mode   (pipe_low_latency_syncronous_mode  ),
		.bypass_g3pcs_scrambler_descrambler (bypass_g3pcs_scrambler_descrambler),
		.bypass_g3pcs_dcbal                 (bypass_g3pcs_dcbal                ),
		.pipe_run_length_violation_checking (pipe_run_length_violation_checking),
		.pipe_elec_idle_infer_enable        (pipe_elec_idle_infer_enable       ),
		.mgmt_clk_in_mhz                    (mgmt_clk_in_mhz                   )
	) pipe_nr_inst (
		.pll_ref_clk                        (pll_ref_clk                       ),             
		.pipe_pclk                          (pipe_pclk                         ),               
		.fixedclk                           (fixedclk                          ),                
		.pipe_txdata                        (pipe_txdata                       ),             
		.pipe_txdatak                       (pipe_txdatak                      ),            
		.pipe_txcompliance                  (pipe_txcompliance                 ),       
		.pipe_txelecidle                    (pipe_txelecidle                   ),         
		.pipe_rxpolarity                    (pipe_rxpolarity                   ),         
		.pipe_txdetectrx_loopback           (pipe_txdetectrx_loopback          ),
		.pipe_powerdown                     (pipe_powerdown                    ),          
		.pipe_txswing                       (pipe_txswing                      ),            
		.pipe_txmargin                      (pipe_txmargin                     ),            
		.rx_eidleinfersel                   (rx_eidleinfersel                  ),        
		.pipe_rxdata                        (pipe_rxdata                       ),             
		.pipe_rxdatak                       (pipe_rxdatak                      ),            
		.pipe_rxvalid                       (pipe_rxvalid                      ),            
		.pipe_rxelecidle                    (pipe_rxelecidle                   ),         
		.pipe_rxstatus                      (pipe_rxstatus                     ),           
		.pipe_phystatus                     (pipe_phystatus                    ),          
		.rx_syncstatus                      (rx_syncstatus                     ),           
		.pll_locked                         (pll_locked                        ),              
		.rx_is_lockedtoref                  (rx_is_lockedtoref                 ),       
		.rx_is_lockedtodata                 (rx_is_lockedtodata                ),      
		.rx_signaldetect                    (rx_signaldetect                   ),         
		.rx_serial_data                     (rx_serial_data                    ),          
		.tx_serial_data                     (tx_serial_data                    ),          
		.tx_ready                           (tx_ready                          ),                
		.rx_ready                           (rx_ready                          ),                
		.phy_mgmt_clk                       (phy_mgmt_clk                      ),            
		.phy_mgmt_clk_reset                 (phy_mgmt_clk_reset                ),      
		.phy_mgmt_address                   (phy_mgmt_address_decoded          ),        
		.phy_mgmt_read                      (phy_mgmt_read                     ),           
		.phy_mgmt_readdata                  (phy_mgmt_readdata                 ),                              
		.phy_mgmt_waitrequest               (phy_mgmt_waitrequest              ),                            
		.phy_mgmt_write                     (phy_mgmt_write                    ),                                  
		.phy_mgmt_writedata                 (phy_mgmt_writedata                ),                              
		.pipe_rate                          (pipe_rate                         ),                                
		.pipe_txdeemph                      (pipe_txdeemph                     ),
		.pipe_g3_txdeemph                   (pipe_g3_txdeemph                  ),
    
    .pipe_rxpresethint                  (pipe_rxpresethint                 ),                                  
    .pipe_rx_data_valid                 (pipe_rx_data_valid                ), 
    .pipe_tx_data_valid                 (pipe_tx_data_valid                ), 
    .pipe_rx_blk_start                  (pipe_rx_blk_start                 ), 
    .pipe_tx_blk_start                  (pipe_tx_blk_start                 ),
    .pipe_rx_sync_hdr                   (pipe_rx_sync_hdr                  ), 
    .pipe_tx_sync_hdr                   (pipe_tx_sync_hdr                  ), 
    .reconfig_to_xcvr                   (reconfig_to_xcvr                  ),
		.reconfig_from_xcvr                 (reconfig_from_xcvr                )
	);

	end else if (is_a5) begin
          av_xcvr_pipe_nr #(
		.lanes                              (lanes                             ),
		.starting_channel_number            (STARTING_CHANNEL_NUMBER           ),
		.protocol_version                   (protocol_version                  ),
//		.pll_type                           (pll_type                          ),
//		.base_data_rate                     (base_data_rate                    ),
		.pll_refclk_freq                    (pll_refclk_freq                   ),
		.deser_factor                       (deser_factor                      ),
		.pipe_low_latency_syncronous_mode   (pipe_low_latency_syncronous_mode  ),
		.pipe_run_length_violation_checking (pipe_run_length_violation_checking),
		.pipe_elec_idle_infer_enable        (pipe_elec_idle_infer_enable       ),
		.mgmt_clk_in_mhz                    (mgmt_clk_in_mhz                   )
	) pipe_nr_inst (
		.pll_ref_clk                        (pll_ref_clk                       ),             
		.pipe_pclk                          (pipe_pclk                         ),               
		.fixedclk                           (fixedclk                          ),                
		.pipe_txdata                        (pipe_txdata                       ),             
		.pipe_txdatak                       (pipe_txdatak                      ),            
		.pipe_txcompliance                  (pipe_txcompliance                 ),       
		.pipe_txelecidle                    (pipe_txelecidle                   ),         
		.pipe_rxpolarity                    (pipe_rxpolarity                   ),         
		.pipe_txdetectrx_loopback           (pipe_txdetectrx_loopback          ),
		.pipe_powerdown                     (pipe_powerdown                    ),          
		.pipe_txswing                       (pipe_txswing                      ),            
		.pipe_txmargin                      (pipe_txmargin                     ),            
		.rx_eidleinfersel                   (rx_eidleinfersel                  ),        
		.pipe_rxdata                        (pipe_rxdata                       ),             
		.pipe_rxdatak                       (pipe_rxdatak                      ),            
		.pipe_rxvalid                       (pipe_rxvalid                      ),            
		.pipe_rxelecidle                    (pipe_rxelecidle                   ),         
		.pipe_rxstatus                      (pipe_rxstatus                     ),           
		.pipe_phystatus                     (pipe_phystatus                    ),          
		.rx_syncstatus                      (rx_syncstatus                     ),           
		.pll_locked                         (pll_locked                        ),              
		.rx_is_lockedtoref                  (rx_is_lockedtoref                 ),       
		.rx_is_lockedtodata                 (rx_is_lockedtodata                ),      
		.rx_signaldetect                    (rx_signaldetect                   ),         
		.rx_serial_data                     (rx_serial_data                    ),          
		.tx_serial_data                     (tx_serial_data                    ),          
		.tx_ready                           (tx_ready                          ),                
		.rx_ready                           (rx_ready                          ),                
		.phy_mgmt_clk                       (phy_mgmt_clk                      ),            
		.phy_mgmt_clk_reset                 (phy_mgmt_clk_reset                ),      
		.phy_mgmt_address                   (phy_mgmt_address_decoded          ),        
		.phy_mgmt_read                      (phy_mgmt_read                     ),           
		.phy_mgmt_readdata                  (phy_mgmt_readdata                 ),                              
		.phy_mgmt_waitrequest               (phy_mgmt_waitrequest              ),                            
		.phy_mgmt_write                     (phy_mgmt_write                    ),                                  
		.phy_mgmt_writedata                 (phy_mgmt_writedata                ),                              
		.pipe_rate                          (pipe_rate[0]                      ), 
		.pipe_txdeemph                      (pipe_txdeemph                     ),
                .pipe_rxpresethint                  (pipe_rxpresethint                 ),                                  
//                .pipe_rx_data_valid                 (pipe_rx_data_valid                ), 
//                .pipe_tx_data_valid                 (pipe_tx_data_valid                ), 
//                .pipe_rx_blk_start                  (pipe_rx_blk_start                 ), 
//                .pipe_tx_blk_start                  (pipe_tx_blk_start                 ),
//                .pipe_rx_sync_hdr                   (pipe_rx_sync_hdr                  ), 
//                .pipe_tx_sync_hdr                   (pipe_tx_sync_hdr                  ), 
                .reconfig_to_xcvr                   (reconfig_to_xcvr                  ),
		.reconfig_from_xcvr                 (reconfig_from_xcvr                )
	);
        assign pipe_rx_data_valid = {lanes{1'b0}};
        assign pipe_rx_blk_start  = {lanes{1'b0}};
        assign pipe_rx_sync_hdr   = {2*lanes{1'b0}};
	end
endgenerate

endmodule

