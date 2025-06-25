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



`timescale 1 ns / 1 ps

module siv_xcvr_custom_phy #(
	
	parameter device_family = "Stratix IV",
	parameter lanes = 4, //legal value: 1+
	parameter ser_base_factor = 8, //legal value: 8,10
	parameter ser_words = 1, //legal value 1,2,4
	
	parameter mgmt_clk_in_mhz = 50, //needed for reset controller timed delays
	parameter data_rate = "2500 Mbps", //remove this later
	parameter plls = 1, //legal value: 1+
	parameter pll_refclk_freq = "125.0 MHz",
	parameter operation_mode = "Duplex", //legal value: TX,RX,Duplex
	parameter starting_channel_number = 0, //legal value: 0+em
	parameter bonded_group_size = 1, //legal value: integer from 1 .. lanes
	parameter use_8b10b = "false", //legal value: "false","true"
	parameter use_8b10b_manual_control = "false",
	
	//optional coreclks
	parameter tx_use_coreclk = "false",
	parameter rx_use_coreclk = "false",

    // tx bitslip
    parameter tx_bitslip_enable = "false",
	
	//Word Aligner
	parameter word_aligner_mode = "manual", //legal value: bitslip, sync_state_machine, manual
	parameter word_aligner_state_machine_datacnt = 0, //legal value: 0-256
	parameter word_aligner_state_machine_errcnt = 0, //legal value: 0-256
	parameter word_aligner_state_machine_patterncnt = 0, //legal value: 0-256
	parameter run_length_violation_checking = 40, //legal value: 0,1+
	parameter word_align_pattern = "1111100",
	parameter word_aligner_pattern_length = 7,
	
	//RM FIFO
	parameter use_rate_match_fifo = 0, //legal value: 0,1
	parameter rate_match_pattern1 = "11010000111010000011",
	parameter rate_match_pattern2 = "00101111000101111100",
	
	//Byte Ordering Block
	parameter byte_order_mode = "none",//legal value: None, sync_state_machine, PLD control
	parameter byte_order_pattern = "000000000",
	parameter byte_order_pad_pattern = "111111011",
	
	//Analog Parameters
	parameter rx_termination = "OCT_100_OHMS", //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
	parameter rx_use_external_termination = "false", //legal value: true, false
	parameter rx_common_mode = "0.82V", //legal value: "0.65V"
	parameter rx_ppmselect = 32,
	parameter rx_signal_detect_threshold = 2,
	parameter rx_use_cruclk = "FALSE",
	parameter tx_termination = "OCT_100_OHMS", //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
	parameter tx_use_external_termination = "false", // legal value: true, false
	parameter tx_analog_power = "AUTO", //legal value: AUTO,1.4V,1.5V
	parameter tx_common_mode = "0.65V", //legal value: 0.65V
	parameter gxb_analog_power = "AUTO", //legal value: AUTO,2.5V,3.0V,3.3V,3.9V
	parameter tx_preemp_pretap = 0,
	parameter tx_preemp_pretap_inv = "FALSE",
	parameter tx_preemp_tap_1 = 0,
	parameter tx_preemp_tap_2 = 0,
	parameter tx_preemp_tap_2_inv = "FALSE",
	parameter tx_vod_selection = 4,
	parameter rx_eq_dc_gain = 0,
	parameter rx_eq_ctrl = 3,
	parameter pll_lock_speed = "AUTO",
	parameter rx_pll_lock_speed = "AUTO",
	parameter tx_slew_rate = "OFF"
) (
	//user data (avalon-MM slave interface) for all the channel rst, powerdown, rx_serialize loopback enable
	input  wire phy_mgmt_clk,
	input  tri0 phy_mgmt_clk_reset,
	input  tri0 phy_mgmt_read,
	input  tri0 phy_mgmt_write,
	input  wire [8:0]  phy_mgmt_address,
	input  wire [31:0] phy_mgmt_writedata,
	output wire [31:0] phy_mgmt_readdata,
	output wire phy_mgmt_waitrequest,
	
	
	//clk signal
	
	input   wire    [plls-1:0]  pll_ref_clk,
	input   wire    [lanes-1:0] tx_coreclkin,
	input   wire    [lanes-1:0] rx_coreclkin,
	output  wire    [(lanes/bonded_group_size)-1:0] tx_clkout,
	output  wire    [lanes-1:0] rx_clkout,
	
	//misc
	// input wire cal_blk_clk,
	// input wire cal_blk_powerdown,

	
	//data ports - Avalon ST interface
	input  wire    [lanes-1:0] rx_serial_data,
	output wire    [ser_base_factor*ser_words*lanes-1:0] rx_parallel_data,
	input  wire    [ser_base_factor*ser_words*lanes-1:0] tx_parallel_data,
	output wire    [lanes-1:0] tx_serial_data,
	
	
	//more optional data
	input  wire [lanes*ser_words-1:0] tx_datak,
	output wire [lanes*ser_words-1:0] rx_datak,
	
	input  wire [lanes*ser_words-1:0] tx_dispval,
	input  wire [lanes*ser_words-1:0] tx_forcedisp,
	output wire [lanes*ser_words-1:0] rx_disperr,
	output wire [lanes*ser_words-1:0] rx_errdetect,
	output wire [lanes*ser_words-1:0] rx_runningdisp,
	output wire [lanes*ser_words-1:0] rx_patterndetect,
	
	input  wire [lanes-1:0] tx_forceelecidle,
	input  wire [lanes-1:0] rx_enabyteord,
	input  wire [lanes-1:0] rx_bitslip,
	
	input  wire [lanes*5-1:0] tx_bitslipboundaryselect,
	output  wire [lanes*5-1:0] rx_bitslipboundaryselectout,
	
	//PMA block control and status
	output wire [plls-1:0] pll_locked, // conduit or ST
	output wire [lanes-1:0] rx_is_lockedtoref, //conduit or ST
	output wire [lanes-1:0] rx_is_lockedtodata, //conduit or ST
	output wire [lanes-1:0] rx_signaldetect,
	
	
	//word alignment
	output wire [lanes*ser_words-1:0] rx_syncstatus, //conduit or ST
	
	//reset controller
	output wire tx_ready, //conduit
	output wire rx_ready  //conduit
);
	// parameter conversions to match S5 interface
	localparam bonded_group_size_string = (bonded_group_size == 1) ? "x1" :
											(bonded_group_size == 4) ? "x4" :
												(bonded_group_size == 8) ? "x8" : "invalid";

	//reconfiguration
	localparam reconfig_fromgxb_port_width = 17;
	localparam reconfig_togxb_port_width = 4;
	localparam reconfig_interfaces = (lanes % 4) == 0 ? lanes/4 : lanes/4 + 1;

	// 'top' PIPE channel includes basic reconfiguration interface for dyn reconfiguration controller
	wire [3:0]                          reconfig_togxb;
	wire [(17*reconfig_interfaces)-1:0] reconfig_fromgxb;
	//output  wire    [reconfig_interfaces*4*2-1:0]             aeq_fromgxb,
	//input   wire    [reconfig_interfaces*4*6-1:0]             aeq_togxb,
	wire reconfig_done;	// for reset controller in 'top', really offset cancellation status

	// 'top' channel CSR ports, phy_mgmt facing
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

	initial begin
		if (bonded_group_size_string == "invalid") begin
			$display("Critical Warning: bonded_group_size value, '%d', not in legal set: '1,4,8'", bonded_group_size);
		end
	end

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
		.mgmt_waitrequest(phy_mgmt_waitrequest),

		// internal interface to 'top' csr block
		.topcsr_readdata(sc_topcsr_readdata),
		.topcsr_waitrequest(sc_topcsr_waitrequest),
		.topcsr_address(sc_topcsr_address),
		.topcsr_read(sc_topcsr_read),
		.topcsr_write(sc_topcsr_write),

		// internal interface to 'top' csr block
		.reconf_readdata(sc_reconf_readdata),
		.reconf_waitrequest(sc_reconf_waitrequest),
		.reconf_address(sc_reconf_address),
		.reconf_read(sc_reconf_read),
		.reconf_write(sc_reconf_write)
	);

	// 'top' is main transceiver channel with PMA + PCS control and status, and reset controller
	siv_xcvr_generic_top #(
		.device_family(device_family),
		.lanes(lanes),
		.ser_base_factor(ser_base_factor),
		.ser_words(ser_words),
		.reconfig_fromgxb_port_width(reconfig_fromgxb_port_width),
		.reconfig_togxb_port_width(reconfig_togxb_port_width),
		.reconfig_interfaces(reconfig_interfaces),
		.mgmt_clk_in_mhz(mgmt_clk_in_mhz),
		.data_rate(data_rate),
		.plls(plls),
		.pll_refclk_freq(pll_refclk_freq),
		.operation_mode(operation_mode),
		.starting_channel_number(starting_channel_number),
		.bonded_group_size(bonded_group_size),
		.use_8b10b(use_8b10b),
		.use_8b10b_manual_control(use_8b10b_manual_control),
		.tx_use_coreclk(tx_use_coreclk),
		.rx_use_coreclk(rx_use_coreclk),
		.word_aligner_mode(word_aligner_mode),
		.word_aligner_state_machine_datacnt(word_aligner_state_machine_datacnt),
		.word_aligner_state_machine_errcnt(word_aligner_state_machine_errcnt),
		.word_aligner_state_machine_patterncnt(word_aligner_state_machine_patterncnt),
		.run_length_violation_checking(run_length_violation_checking),
		.word_align_pattern(word_align_pattern),
		.word_aligner_pattern_length(word_aligner_pattern_length),
		.use_rate_match_fifo(use_rate_match_fifo),
		.rate_match_pattern1(rate_match_pattern1),
		.rate_match_pattern2(rate_match_pattern2),
		.byte_order_mode(byte_order_mode),
		.byte_order_pattern(byte_order_pattern),
		.byte_order_pad_pattern(byte_order_pad_pattern),
		.rx_termination(rx_termination),
		.rx_use_external_termination(rx_use_external_termination),
		.rx_common_mode(rx_common_mode),
		.rx_ppmselect(rx_ppmselect),
		.rx_signal_detect_threshold(rx_signal_detect_threshold),
		.rx_use_cruclk(rx_use_cruclk),
		.tx_termination(tx_termination),
		.tx_use_external_termination(tx_use_external_termination),
		.tx_analog_power(tx_analog_power),
		.tx_common_mode(tx_common_mode),
		.gxb_analog_power(gxb_analog_power),
		.tx_preemp_pretap(tx_preemp_pretap),
		.tx_preemp_pretap_inv(tx_preemp_pretap_inv),
		.tx_preemp_tap_1(tx_preemp_tap_1),
		.tx_preemp_tap_2(tx_preemp_tap_2),
		.tx_preemp_tap_2_inv(tx_preemp_tap_2_inv),
		.tx_vod_selection(tx_vod_selection),
		.rx_eq_dc_gain(rx_eq_dc_gain),
		.rx_eq_ctrl(rx_eq_ctrl),
		.pll_lock_speed(pll_lock_speed),
		.rx_pll_lock_speed(rx_pll_lock_speed),
		.tx_slew_rate(tx_slew_rate)
	) xcvr (
		.mgmt_clk(phy_mgmt_clk),
		.mgmt_clk_reset(phy_mgmt_clk_reset),
		.mgmt_address(sc_topcsr_address),	// top.csr uses 2 128-word blocks
		.mgmt_read(sc_topcsr_read),
		.mgmt_write(sc_topcsr_write),
		.mgmt_writedata(phy_mgmt_writedata),
		.mgmt_readdata(sc_topcsr_readdata),
		.pll_ref_clk(pll_ref_clk),
		.tx_coreclkin(tx_coreclkin),
		.rx_coreclkin(rx_coreclkin),
		.rx_serial_data(rx_serial_data),
		.tx_parallel_data(tx_parallel_data),
		.tx_datak(tx_datak),
		.tx_dispval(tx_dispval),
		.tx_forcedisp(tx_forcedisp),
		.tx_forceelecidle(tx_forceelecidle),
		.rx_enabyteord(rx_enabyteord),
		.rx_bitslip(rx_bitslip),
		.rx_oc_busy(reconfig_togxb[3]),
		.tx_clkout(tx_clkout),
		.rx_clkout(rx_clkout),
		.rx_parallel_data(rx_parallel_data),
		.tx_serial_data(tx_serial_data),
		.rx_datak(rx_datak),
		.rx_disperr(rx_disperr),
		.rx_errdetect(rx_errdetect),
		.rx_runningdisp(rx_runningdisp),
		.rx_patterndetect(rx_patterndetect),
		.pll_locked(pll_locked),
		.rx_is_lockedtoref(rx_is_lockedtoref),
		.rx_is_lockedtodata(rx_is_lockedtodata),
		.rx_signaldetect(rx_signaldetect),
		.rx_syncstatus(rx_syncstatus),
		.tx_ready(tx_ready),
		.rx_ready(rx_ready),
		.tx_bitslipboundaryselect(tx_bitslipboundaryselect),
		.rx_a1a2sizeout(),
		.rx_bitslipboundaryselectout(rx_bitslipboundaryselectout),
		// reconfig
		.reconfig_clk(phy_mgmt_clk),
		.reconfig_togxb(reconfig_togxb),
		.reconfig_fromgxb(reconfig_fromgxb)
	);

	// generate waitrequest for 'top' channel
	altera_wait_generate top_wait (
		.rst(phy_mgmt_clk_reset),
		.clk(phy_mgmt_clk),
		.launch_signal(sc_topcsr_read),
		.wait_req(sc_topcsr_waitrequest)
	);


	// Dynamic reconfiguration controller
	alt_xcvr_reconfig_siv #(
	    .number_of_reconfig_interfaces(reconfig_interfaces) 
	) reconfig (
		.mgmt_clk_clk(phy_mgmt_clk),
		.mgmt_rst_reset(phy_mgmt_clk_reset),
		.reconfig_mgmt_address(sc_reconf_address),
		.reconfig_mgmt_read(sc_reconf_read),
		.reconfig_mgmt_write(sc_reconf_write),
		.reconfig_mgmt_writedata(phy_mgmt_writedata),
		.reconfig_mgmt_waitrequest(sc_reconf_waitrequest),
		.reconfig_mgmt_readdata(sc_reconf_readdata),
		// native reconfig interfaces + status
		.reconfig_done(reconfig_done),
		.reconfig_togxb(reconfig_togxb),  //  reconfig_togxb_data.data
		.reconfig_fromgxb(reconfig_fromgxb) // dprioout, testbus from altgx : (17+4 bits/quad)
		//.testbus_data()	// native testbus input, from 'top' channel
	);

endmodule
