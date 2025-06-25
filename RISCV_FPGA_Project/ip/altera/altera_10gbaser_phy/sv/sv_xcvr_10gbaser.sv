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


module sv_xcvr_10gbaser #(
    parameter num_channels = 4,   // define the channel numbers
    parameter operation_mode = "duplex", //SV parameter only
    parameter ref_clk_freq = "322.265625 MHz", // support both 322.265625 MHz, 644.53125 MHz
    parameter starting_channel_number = 0, //physical start channel number, useful in SIV
    parameter mgmt_clk_in_mhz = 50, //system clock for the avalone interface. It is limited by reconfig speed. This parameter will affact the reset hold time.
    parameter starting_ch = 0, //reconfig interfaces, need at port definition
		parameter sync_depth = 2

)(
	input  wire        phy_mgmt_clk,            //         mgmt_clk.clk
	input  wire        phy_mgmt_clk_reset,    //     mgmt_clk_rst.reset_n
	input  wire        phy_mgmt_read,           //         phy_mgmt.read
	input  wire        phy_mgmt_write,          //                 .write
	input  wire [8:0]  phy_mgmt_address,        //                 .address
	input  wire [31:0] phy_mgmt_writedata,      //                 .writedata
	output wire [31:0] phy_mgmt_readdata,       //                 .readdata
	output wire        phy_mgmt_waitrequest,    //                 .waitrequest
	input  wire        xgmii_tx_clk,        //     xgmii_tx_clk.clk
	input  wire        pll_ref_clk,         //      pll_ref_clk.clk
	output wire        xgmii_rx_clk,        //     xgmii_rx_clk.clk
	output wire        rx_recovered_clk,
	input  tri0        rx_oc_busy,			// RX channel offset cancellation status
	output wire        tx_ready,           //         tx_ready.data
	output wire        rx_ready,          //        rx_ready0.data
	output wire        [num_channels -1 : 0]rx_block_lock,		
	output wire        [num_channels -1 : 0]rx_hi_ber,		
	input  wire [72*num_channels -1 : 0] xgmii_tx_dc,      //    xgmii_tx_dc_0.data
	output wire [72*num_channels -1 : 0] xgmii_rx_dc,      //    xgmii_rx_dc_0.data
	output wire [num_channels -1 : 0] tx_serial_data, // tx_serial_data_0.export
	input  wire [num_channels -1 : 0] rx_serial_data  // rx_serial_data_0.export

);

	// 'top' channel CSR ports, mgmt facing
	wire [31:0] sc_topcsr_readdata;
	wire        sc_topcsr_waitrequest;
	wire [ 7:0] sc_topcsr_address;
	wire        sc_topcsr_read;
	wire        sc_topcsr_write;

	// dynamic reconfig ports, mgmt facing
	wire [31:0] sc_reconf_readdata;
	wire        sc_reconf_waitrequest;
	wire [ 7:0] sc_reconf_address;
	wire        sc_reconf_read;
	wire        sc_reconf_write;
	
	///////////////////////////////////////////////////////////////////////
	// Decoder for multiple slaves of reconfig_mgmt interface
	///////////////////////////////////////////////////////////////////////
	alt_xcvr_mgmt2dec mgmtdec (
		.mgmt_clk_reset(phy_mgmt_clk_reset),
		.mgmt_clk(phy_mgmt_clk),

		.mgmt_address(phy_mgmt_address),
		.mgmt_read(phy_mgmt_read),
		.mgmt_write(phy_mgmt_write),
		.mgmt_readdata(phy_mgmt_readdata),
		.mgmt_waitrequest(),

		// internal interface to 'top' csr block
		.topcsr_readdata(sc_topcsr_readdata),
		.topcsr_waitrequest(1'b0),
		.topcsr_address(sc_topcsr_address),
		.topcsr_read(sc_topcsr_read),
		.topcsr_write(sc_topcsr_write),

		// internal interface to 'top' csr block
		.reconf_readdata(sc_reconf_readdata),
		.reconf_waitrequest(1'b0),
		.reconf_address(sc_reconf_address),
		.reconf_read(sc_reconf_read),
		.reconf_write(sc_reconf_write)
	);

	///////////////////////////////////////////////////////////////////////
	// instantiate 10gbaser phy
	///////////////////////////////////////////////////////////////////////
  sv_xcvr_10gbaser_nr  #(
    .num_channels   (num_channels   ),
    .sys_clk_in_mhz (mgmt_clk_in_mhz),
    .ref_clk_freq   (ref_clk_freq   ),
    .operation_mode (operation_mode )
  ) sv_xcvr_nr_inst (
    .mgmt_clk	      (phy_mgmt_clk),        
    .mgmt_clk_rstn  (!phy_mgmt_clk_reset), 
    .mgmt_read      (sc_topcsr_read),      
    .mgmt_write     (sc_topcsr_write),     
    .mgmt_address   (sc_topcsr_address),   
    .mgmt_writedata (phy_mgmt_writedata),  
    .mgmt_readdata  (sc_topcsr_readdata),  
    .mgmt_waitrequest(phy_mgmt_waitrequest),
    .xgmii_tx_clk	  (xgmii_tx_clk),       	
    .pll_ref_clk	  (pll_ref_clk),        	
    .xgmii_rx_clk	  (xgmii_rx_clk),       	
    .rx_recovered_clk(rx_recovered_clk),
    .rx_oc_busy	    (rx_oc_busy),	// RX channel offset cancellation status
    .tx_ready	      (tx_ready),       
    .rx_ready	      (rx_ready),       
    .block_lock	    (rx_block_lock),		
    .hi_ber		      (rx_hi_ber),		
    .xgmii_tx_dc	  (xgmii_tx_dc),    
    .xgmii_rx_dc	  (xgmii_rx_dc),    
    .tx_serial_data	(tx_serial_data), 
    .rx_serial_data	(rx_serial_data)	
  );


	// 'top' PIPE channel includes basic reconfiguration interface for dyn reconfiguration controller
	wire basic_waitrequest;
	wire basic_irq;
	wire basic_readdata;
	wire basic_address;
	wire basic_read;
	wire basic_write;
	wire basic_writedata;
	wire reconfig_done;	// for reset controller in 'top'

  // Dynamic reconfiguration controller
  alt_xcvr_reconfig_sv  reconfig (
    .mgmt_clk_clk(phy_mgmt_clk),
    .mgmt_rst_reset(phy_mgmt_clk_reset),
    .reconfig_mgmt_address(sc_reconf_address),
    .reconfig_mgmt_read(sc_reconf_read),
    .reconfig_mgmt_write(sc_reconf_write),
    .reconfig_mgmt_writedata(phy_mgmt_writedata),
    .reconfig_mgmt_waitrequest(sc_reconf_waitrequest),
    .reconfig_mgmt_readdata(sc_reconf_readdata),
    .reconfig_done(reconfig_done),
    .basic_waitrequest(basic_waitrequest),
    .basic_irq(basic_irq),
    .basic_readdata(basic_readdata),
    .basic_address(basic_address),
    .basic_read(basic_read),
    .basic_write(basic_write),
    .basic_writedata(basic_writedata),
    .testbus_data()	// native testbus input, from 'top' channel
  );
    

endmodule
