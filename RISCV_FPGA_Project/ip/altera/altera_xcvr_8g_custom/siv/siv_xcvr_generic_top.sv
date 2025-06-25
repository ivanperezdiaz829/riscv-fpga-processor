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

module siv_xcvr_generic_top
  #(
    
    parameter device_family = "Stratix IV",
    parameter device_type = "GX",
    parameter lanes = 4, //legal value: 1+
    parameter ser_base_factor = 8, //legal value: 8,10
    parameter ser_words = 1, //legal value 1,2,4
    parameter reconfig_fromgxb_port_width = 17,
    parameter reconfig_togxb_port_width = 4,
    parameter reconfig_interfaces = 1,

    
    parameter mgmt_clk_in_mhz = 50, //needed for reset controller timed delays
    parameter data_rate = "2500 Mbps", //remove this later
    parameter plls = 1, //legal value: 1+
    parameter pll_refclk_freq = "125.0 MHz",
    parameter operation_mode = "Duplex", //legal value: TX,RX,Duplex
    parameter starting_channel_number = 0, //legal value: 0+em
    parameter bonded_group_size = 1, //legalvalue:x1,x4,x8
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
    parameter tx_use_external_termination = "false", //true, false
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
       
       //   input   wire            rst,
       //        input   wire            clk,
       //        input   wire   [7:0]    address,
       //        input   wire            read,
       //        output  wire   [31:0]   readdata,
       //        input   wire            write,
       //        input   wire   [31:0]   writedata,
       
       input wire mgmt_clk,
       input tri0 mgmt_clk_reset,
       input wire [7:0] mgmt_address,
       input tri0 mgmt_read,
       output wire [31:0] mgmt_readdata,
       input tri0 mgmt_write,
       input wire [31:0] mgmt_writedata,
       
       
       //clk signal
       
       input   wire    [plls-1:0]     pll_ref_clk,
       input   wire    [lanes-1:0]    tx_coreclkin,
       input   wire    [lanes-1:0]    rx_coreclkin,
       output  wire    [(lanes/bonded_group_size)-1:0]                    tx_clkout,
       output  wire    [lanes-1:0]                    rx_clkout,
       
       //misc
       // input wire cal_blk_clk,
       // input wire cal_blk_powerdown,
       

       //data ports - Avalon ST interface


       input  wire    [lanes-1:0] rx_serial_data,
       output wire    [ser_base_factor*ser_words*lanes-1:0] rx_parallel_data,
       input  wire    [ser_base_factor*ser_words*lanes-1:0] tx_parallel_data,
       output wire    [lanes-1:0] tx_serial_data,
       

       //more optional data
       input wire [lanes*ser_words-1:0] tx_datak,
       output wire [lanes*ser_words-1:0] rx_datak,

       input  wire [lanes*ser_words-1:0] tx_dispval,
       input  wire [lanes*ser_words-1:0] tx_forcedisp,
       output wire [lanes*ser_words-1:0] rx_disperr,
       output wire [lanes*ser_words-1:0] rx_errdetect,
       output wire [lanes*ser_words-1:0] rx_runningdisp,
       output wire [lanes*ser_words-1:0] rx_patterndetect,
       output wire [ser_words*lanes-1:0] rx_a1a2sizeout,
       output wire [lanes*5-1:0] rx_bitslipboundaryselectout,
       
       input wire	[lanes-1:0] tx_forceelecidle,
       input wire	[lanes-1:0]	rx_enabyteord,
       input wire	[lanes-1:0]	rx_bitslip,
       input wire	[lanes*5-1:0]	tx_bitslipboundaryselect,

       //reconfiguration

       
       input   wire                                   reconfig_clk,
       input   wire    [3:0]                          reconfig_togxb,
       output  wire    [(17*reconfig_interfaces)-1:0]            reconfig_fromgxb,
       //output  wire    [reconfig_interfaces*4*2-1:0]             aeq_fromgxb,
       //input   wire    [reconfig_interfaces*4*6-1:0]             aeq_togxb,
       input   wire    rx_oc_busy, // offset cancellation status from reconfig controller
       
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
      
      //------------------------
      // Reset controller outputs
      //------------------------
  
      wire 				 reset_controller_tx_ready;
      wire 				 reset_controller_rx_ready;
      wire 				 reset_controller_pll_powerdown;
      wire 				 reset_controller_tx_digitalreset;
      wire 				 reset_controller_rx_analogreset;
      wire 				 reset_controller_rx_digitalreset;
      
      //-------------------------------
      // Control & status register map (CSR) outputs
      //--------------------------------

      wire 				 csr_reset_tx_digital; //to reset controller
      wire 				 csr_reset_rx_digital; //to reset controller
      wire 				 csr_reset_all; //to reset controller
      wire 				 csr_pll_powerdown; //to xcvr instance
      wire [lanes-1:0] 			 csr_tx_digitalreset; //to xcvr instance
      wire [lanes-1:0] 			 csr_rx_analogreset; //to xcvr instance
      wire [lanes-1:0] 			 csr_rx_digitalreset; //to xcvr instance
      wire [lanes-1:0] 			 csr_phy_loopback_serial; //to xcvr instance
      wire [lanes-1:0] 			 csr_tx_invpolarity; //to xcvr instance
      wire [lanes-1:0] 			 csr_rx_invpolarity; //to xcvr instance
      wire [lanes-1:0] 			 csr_rx_set_locktoref; //to xcvr instance
      wire [lanes-1:0] 			 csr_rx_set_locktodata; //to xcvr instance
      wire [lanes-1 : 0]		 csr_rx_a1a2size; //to xcvr instance


      //readdata output from both CSR blocks
      wire [31:0] 			 mgmt_readdata_common;
      wire [31:0] 			 mgmt_readdata_pcs;
      

      
      
      //-----------------------------------------------
      // Unconnected I/Os
      //-----------------------------------------------
      
      //Word Alignment
      wire [lanes-1:0] 			 csr_rx_enapatternalign;
      wire [lanes-1:0] 			 csr_rx_rlv;
      wire [lanes*ser_words-1:0] 	 csr_rx_patterndetect;
      wire [lanes-1:0] 			 csr_rx_bitreversalenable;
      wire [lanes-1:0] 			 csr_rx_bytereversalenable;
      
      //PCS rate-match and phase-compensation FIFO
      wire [lanes*ser_words-1:0] 	 rx_rmfifodatadeleted;
      wire [lanes*ser_words-1:0] 	 rx_rmfifodatainserted;
      wire [lanes-1:0] 			 rx_rmfifoempty;
      wire [lanes-1:0] 			 rx_rmfifofull;
      wire [lanes-1:0] 			 rx_phase_comp_fifo_error;
      wire [lanes-1:0] 			 tx_phase_comp_fifo_error;
      
      //////////////////////////
      
      //cal_blk
      
      wire 				 cal_blk_clk_wire;
      wire 				 cal_blk_powerdown_wire;
      
      
      //other stuff
      //  wire [lanes-1:0] tx_forceelecidle_wire;
      //    wire [lanes-1:0] tx_invpolarity_wire;
      //    wire [lanes*5 -1:0] tx_bitslipboundaryselect_wire;
      //    wire [lanes-1:0]    rx_invpolarity_wire;
      //    wire [lanes-1:0]    rx_seriallpbken_wire;
      //    wire [lanes-1:0]    rx_set_locktodata_wire;
      //    wire [lanes-1:0]    rx_set_locktoref_wire;
      //    wire [lanes-1:0]    rx_enapatternalign_wire;
      //    wire [lanes-1:0]    rx_bitslip_wire;
      //    wire [lanes-1:0]    rx_bitreversalenable_wire;
      //    wire [lanes-1:0]    rx_bytereversalenable_wire;
      //    wire [lanes-1:0]    rx_rlv_wire;
      //    wire [(ser_words*lanes)-1:0] rx_patterndetect_wire;
      //    wire [(ser_words*lanes)-1:0] rx_syncstatus_wire;
      //    wire [lanes * 5 -1:0] 	rx_bitslipboundaryselectout_wire;
      //    wire [(ser_words*lanes)-1:0] rx_errdetect_wire;
      //    wire [(ser_words*lanes)-1:0] rx_disperr_wire;
      //    wire [lanes-1:0] 		rx_rmfifofull_wire;
      //    wire [lanes-1:0] 		rx_rmfifoempty_wire;
      //    wire [(ser_words*lanes)-1:0] rx_rmfifodatainserted_wire;
      //    wire [(ser_words*lanes)-1:0] rx_rmfifodatadeleted_wire;
      //    wire [lanes-1:0] 		rx_is_lockedtoref_wire;
      //    wire [lanes-1:0] 		rx_is_lockedtodata_wire;
			wire [plls-1:0] 		pll_locked_wire; //check for suitable formula
      //    wire [lanes-1:0] 		rx_phase_comp_fifo_error_wire;
      //    wire [lanes-1:0] 		tx_phase_comp_fifo_error_wire;
      
      
      // wire [num_quad-1:0] 		gxb_powerdown;
      // wire [plls-1:0] 		pll_powerdown; //check for suitable formula
      //  wire [lanes-1:0] 		tx_digitalreset;
      //  wire 			rx_analogreset;
      //  wire 			rx_digitalreset;
      //   wire 			cal_blk_powerdown;
      
      wire	[(lanes/bonded_group_size)-1 : 0] coreclkout_wire;
      wire	[lanes-1 : 0] tx_clkout_wire;
      
      
      localparam 	 INT_RX_RATE_MATCH_FIFO_MODE = (use_rate_match_fifo == 0)?"none":"normal"; //need to find the exact formula
      localparam 	 num_plls = lanes;
      localparam deser_factor = (ser_words*ser_base_factor);
      
      localparam 	 DWIDTH_FACTOR = (deser_factor % 8 == 0)? (deser_factor/8):(deser_factor/10);
      localparam 	 num_quad = (lanes % 4 == 0)? (lanes/4):((lanes/4)+1);

      localparam seriallpbken = "slb"; //legal value: "none", slb
      
      
     // localparam 	 pll_ctrl_width = (bonded_group_size == "x4")?(lanes/4):(bonded_group_size == "x8")?(lanes/8):num_quad;
     // localparam         tx_digitalreset_width = (bonded_group_size == "x4")?(lanes/4):(bonded_group_size == "x8")?(lanes/8):lanes;


   wire 	 rx_seriallpbken_wire;
      assign rx_seriallpbken_wire = (seriallpbken == "none")?1'b0:{lanes{1'b1}};
       


   // Instantiate memory map logic for given number of lanes & PLL's

   alt_xcvr_csr_common
     #(
       .lanes(lanes),
       .plls(plls)
       )
       csr
	 (
	  .clk(mgmt_clk),
	  .reset(mgmt_clk_reset),
	  .address(mgmt_address),
	  .read(mgmt_read),
	  .write(mgmt_write),
	  .writedata(mgmt_writedata),
	  .pll_locked(pll_locked_wire),
	  .rx_is_lockedtoref(rx_is_lockedtoref),
	  .rx_is_lockedtodata(rx_is_lockedtodata),
	  .rx_signaldetect(rx_signaldetect),
	  .reset_controller_tx_ready(reset_controller_tx_ready),
	  .reset_controller_rx_ready(reset_controller_rx_ready),
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
	//  .csr_tx_invpolarity(csr_tx_invpolarity),
	//  .csr_rx_invpolarity(csr_rx_invpolarity),
	  .csr_rx_set_locktoref(csr_rx_set_locktoref),
	  .csr_rx_set_locktodata(csr_rx_set_locktodata)
	  );

	alt_xcvr_csr_pcs8g #(
		.lanes(lanes),
		.words(ser_words)
	) csr_pcs (
		.clk(mgmt_clk),
		.reset(mgmt_clk_reset),
		.address(mgmt_address),
		.read(mgmt_read),
		.write(mgmt_write),
		.writedata(mgmt_writedata),
		.readdata(mgmt_readdata_pcs),
		.rx_clk(rx_clkout[0]),
		.tx_clk(tx_clkout[0]),
		.rx_patterndetect(csr_rx_patterndetect),
		.rx_syncstatus(rx_syncstatus),
		.rlv(csr_rx_rlv),
		.rx_phase_comp_fifo_error(rx_phase_comp_fifo_error),
		.tx_phase_comp_fifo_error(tx_phase_comp_fifo_error),
		.csr_tx_invpolarity(csr_tx_invpolarity),
		.csr_rx_invpolarity(csr_rx_invpolarity),
		.csr_rx_bitreversalenable(csr_rx_bitreversalenable),
		.csr_rx_enapatternalign(csr_rx_enapatternalign),
		.csr_rx_bytereversalenable(csr_rx_bytereversalenable),
		.csr_rx_a1a2size(csr_rx_a1a2size),
		// not connected in Stratix IV
		.rx_errdetect(),
		.rx_disperr(),
		.rx_bitslipboundaryselectout(),
		.rx_a1a2sizeout(),
		.csr_tx_bitslipboundaryselect()
	);

      assign mgmt_readdata = mgmt_readdata_common & mgmt_readdata_pcs;
      
      

   //Instantiate reset controller for generic xcvr
   alt_reset_ctrl_tgx_cdrauto
     #(
       .sys_clk_in_mhz(mgmt_clk_in_mhz)
       )
       reset_controller
	 (
	  .clock(mgmt_clk),
	  .reset_all(csr_reset_all),
	  .reset_tx_digital(csr_reset_tx_digital),
	  .reset_rx_digital(csr_reset_rx_digital),
	  .powerdown_all(mgmt_clk_reset),
	  .pll_is_locked(pll_locked_wire),
	  .rx_cal_busy(rx_oc_busy),
	  .tx_cal_busy(1'b0),
	  .rx_is_lockedtodata(& rx_is_lockedtodata),
	  .tx_ready(reset_controller_tx_ready),
	  .rx_ready(reset_controller_rx_ready),
	  .pll_powerdown(reset_controller_pll_powerdown),
	  .tx_digitalreset(reset_controller_tx_digitalreset),
	  .rx_analogreset(reset_controller_rx_analogreset),
	  .rx_digitalreset(reset_controller_rx_digitalreset),
	  .gxb_powerdown()
	  );
	  
   
      
   siv_xcvr_generic transceiver_core					    
	(

	 
	 .gxb_powerdown(),
	 .pll_powerdown(csr_pll_powerdown),
	 .tx_digitalreset(csr_tx_digitalreset),
	 .rx_analogreset((operation_mode == "TX")? 1'b0: csr_rx_analogreset),
	 .rx_digitalreset(csr_rx_digitalreset),
	 .reconfig_clk(reconfig_clk),
	 .reconfig_fromgxb(reconfig_fromgxb),
	 .reconfig_togxb(reconfig_togxb),
	// .aeq_togxb(aeq_togxb),
	// .aeq_fromgxb(aeq_fromgxb),
	 .pll_ref_clk(pll_ref_clk),
	 .tx_coreclkin(tx_coreclkin),
	 .rx_coreclkin(rx_coreclkin),
	 .tx_parallel_data(tx_parallel_data),
	 .rx_parallel_data(rx_parallel_data),
	 .rx_parallel_data_read(),	// no connect
	 .tx_datak(tx_datak),
	 .rx_datak(rx_datak),
	 .tx_forcedisp(tx_forcedisp),
	 .tx_dispval(tx_dispval),
	 .rx_runningdisp(rx_runningdisp),
	 .rx_serial_data(rx_serial_data),
	 .tx_serial_data(tx_serial_data),
	 .tx_clkout(tx_clkout_wire),
	 .coreclkout(coreclkout_wire),
	 .rx_clkout(rx_clkout),
	 .rx_enabyteord(rx_enabyteord),
	 .rx_bitslip(rx_bitslip),
	 .rx_a1a2sizeout(rx_a1a2sizeout),
	 
	 //MM Ports
	 .tx_forceelecidle(tx_forceelecidle),
	 .tx_invpolarity(csr_tx_invpolarity),
	 .tx_bitslipboundaryselect((tx_bitslip_enable == "true") ? tx_bitslipboundaryselect: 1'bz),
	 .rx_invpolarity(csr_rx_invpolarity),
	 .rx_seriallpbken(csr_phy_loopback_serial), //change to csr_rx_seriallpbken
	 .rx_set_locktodata(csr_rx_set_locktodata),
	 .rx_set_locktoref(csr_rx_set_locktoref),
	 .rx_enapatternalign(csr_rx_enapatternalign),
	 .rx_bitreversalenable(csr_rx_bitreversalenable),
	 .rx_bytereversalenable(csr_rx_bytereversalenable),
	 .rx_a1a2size(csr_rx_a1a2size),
	 .rx_rlv(csr_rx_rlv),
	 .rx_patterndetect(csr_rx_patterndetect),
	 .rx_syncstatus(rx_syncstatus),
	 .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout),
	 .rx_errdetect(rx_errdetect),
	 .rx_disperr(rx_disperr),
	 .rx_rmfifofull(rx_rmfifofull),
	 .rx_rmfifoempty(rx_rmfifoempty),
	 .rx_rmfifodatainserted(rx_rmfifodatainserted),
	 .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
	 .rx_is_lockedtoref(rx_is_lockedtoref),
	 .rx_is_lockedtodata(rx_is_lockedtodata),
	 .pll_locked(pll_locked_wire),
	 .rx_phase_comp_fifo_error(rx_phase_comp_fifo_error),
	 .tx_phase_comp_fifo_error(tx_phase_comp_fifo_error),
	 .cal_blk_clk(mgmt_clk),
	 .cal_blk_powerdown(),	// no connect
	 .rx_signaldetect(rx_signaldetect),
	 .rx_cdr_ref_clk()	// no connect
	);

   defparam     transceiver_core.device_family = device_family;
   defparam     transceiver_core.device_type =  device_type;
   defparam 	transceiver_core.lanes = lanes; //legal value: 1+
   //defparam 	     transceiver_core.deser_factor = deser_factor; //legal value: 8,10,16,20,32,40
   defparam 	transceiver_core.ser_base_factor = ser_base_factor;
   defparam 	transceiver_core.ser_words = ser_words;   
   defparam 	transceiver_core.data_rate = data_rate;
	defparam transceiver_core.bonded_group_size = bonded_group_size;
   defparam 	transceiver_core.pll_refclk_freq = pll_refclk_freq;
   defparam 	transceiver_core.operation_mode = operation_mode; //legal value: Duplex, RX, TX
   defparam 	transceiver_core.use_8b10b = use_8b10b; //legal value: 0,1
   defparam     transceiver_core.use_8b10b_manual_control = use_8b10b_manual_control;
   defparam 	transceiver_core.tx_use_coreclk = tx_use_coreclk;
   defparam 	transceiver_core.rx_use_coreclk = rx_use_coreclk;
   defparam 	transceiver_core.tx_bitslip_enable = tx_bitslip_enable;
   defparam 	transceiver_core.word_aligner_mode = word_aligner_mode; //legal value: bitslip, sync state machine, manual
   defparam 	transceiver_core.word_aligner_state_machine_datacnt = word_aligner_state_machine_datacnt; //legal value: 0-256
   defparam 	transceiver_core.word_aligner_state_machine_errcnt = word_aligner_state_machine_errcnt; //legal value: 0-256
   defparam 	transceiver_core.word_aligner_state_machine_patterncnt = word_aligner_state_machine_patterncnt; //legal value: 0-256
   defparam 	transceiver_core.run_length_violation_checking = run_length_violation_checking; //legal value: 0, 1+
   defparam 	transceiver_core.word_align_pattern = word_align_pattern;
   defparam 	transceiver_core.word_aligner_pattern_length = word_aligner_pattern_length;	     
   defparam 	transceiver_core.rate_match_fifo_mode = INT_RX_RATE_MATCH_FIFO_MODE; //legal value: 0,1
   defparam 	transceiver_core.rate_match_pattern1 = rate_match_pattern1;
   defparam 	transceiver_core.rate_match_pattern2 = rate_match_pattern2;
   defparam 	transceiver_core.byte_order_mode = byte_order_mode; //legal value: None, sync state machine, PLD Control
   defparam 	transceiver_core.byte_order_pattern = byte_order_pattern;
   defparam 	transceiver_core.byte_order_pad_pattern = byte_order_pad_pattern;
   defparam 	transceiver_core.rx_termination = rx_termination; //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
   defparam 	transceiver_core.rx_use_external_termination = rx_use_external_termination; //legal value: true, false
   defparam 	transceiver_core.rx_common_mode = rx_common_mode; //legal value: "0.65V"
   defparam 	transceiver_core.rx_ppmselect = rx_ppmselect;
   defparam 	transceiver_core.rx_signal_detect_threshold = 2;
   defparam 	transceiver_core.rx_use_cruclk = rx_use_cruclk;
   defparam 	transceiver_core.tx_termination = tx_termination; //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
   defparam 	transceiver_core.tx_use_external_termination = tx_use_external_termination;
   defparam 	transceiver_core.tx_analog_power = tx_analog_power; //legal value: AUTO, 1.4V, 1.5V
   defparam 	transceiver_core.tx_common_mode = tx_common_mode; //legal value: 0.65V
   defparam 	transceiver_core.gxb_analog_power = gxb_analog_power; //legal value: AUTO,2.5V,3.0V,3.3V,3.9V
   defparam     transceiver_core.tx_preemp_pretap = tx_preemp_pretap;
   defparam     transceiver_core.tx_preemp_pretap_inv = tx_preemp_pretap_inv;
   defparam     transceiver_core.tx_preemp_tap_1 = tx_preemp_tap_1;
   defparam     transceiver_core.tx_preemp_tap_2 = tx_preemp_tap_2;
   defparam     transceiver_core.tx_preemp_tap_2_inv = tx_preemp_tap_2_inv;
   defparam     transceiver_core.tx_vod_selection = tx_vod_selection;
   defparam     transceiver_core.rx_eq_dc_gain = rx_eq_dc_gain;
   defparam     transceiver_core.rx_eq_ctrl = rx_eq_ctrl;
   defparam 	transceiver_core.pll_lock_speed = pll_lock_speed;
   defparam 	transceiver_core.tx_slew_rate = tx_slew_rate;
   defparam 	transceiver_core.rx_pll_lock_speed = rx_pll_lock_speed;
//   defparam     transceiver_core.seriallpbken = seriallpbken;
   defparam     transceiver_core.reconfig_interfaces = reconfig_interfaces;
   
    //conduit status output  
    assign pll_locked = pll_locked_wire;  
    assign tx_ready = reset_controller_tx_ready;
    assign rx_ready = reset_controller_rx_ready;
   
    //tx_clkout assignment base on bonding 
    assign tx_clkout = (bonded_group_size != 1)? {{(lanes - (lanes/bonded_group_size)){1'b0}},coreclkout_wire} : tx_clkout_wire;
    
    //optional ports
    assign rx_patterndetect = csr_rx_patterndetect;
   
endmodule // siv_xcvr_generic_top

   
      
      
      
      

   
   
   
   
   
   
   

   
   
   
   
   
   
   
   
   
   
   
   
   

   
   
   
   
					      
   

   
   
   
   

   
   
   
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
				      
     
      
					  
   
   

   
   
   

       
       
       

       

       
       
       
       
       
    

    
    

    
    

    
    
