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



module siv_xcvr_generic
  #(    
	parameter device_family = "Stratix IV",
	parameter device_type = "GX",
	parameter lanes = 2,
	//parameter deser_factor = 8, //legal value: 8,10,16,20,32,40
	parameter ser_base_factor = 8, //legal value: 8,10
	parameter ser_words = 1, //legal value: 1,2,4
	parameter data_rate = "1250 Mbps",
	parameter plls = 1,
	parameter pll_refclk_freq = "100MHz",
	parameter operation_mode = "Duplex",
	parameter starting_channel_number = 0, //legal value: 0+
	parameter bonded_group_size = 1, //legal value: 1+
	parameter use_8b10b = "false", //legal value: "false", "true"
	parameter use_8b10b_manual_control = "false",
//	parameter seriallpbken = "slb", //none or slb
	parameter reconfig_interfaces = 1,
	
	//optional coreclk	
	 parameter tx_use_coreclk = "false",
	parameter rx_use_coreclk = "false",
	
	// tx bitslip
	parameter tx_bitslip_enable = "false",
	
	//Word Aligner
	parameter word_aligner_mode = "bitslip", //legal value: bitslip, sync state machine, manual
	parameter word_aligner_state_machine_datacnt = 0, //legal value: 0 - 256
	parameter word_aligner_state_machine_errcnt = 0, //legal value: 0 - 256
	parameter word_aligner_state_machine_patterncnt = 0, //legal value: 0 - 256
	parameter run_length_violation_checking = 0, //legal value: 0,1+
	parameter word_align_pattern = "00000000",
	parameter word_aligner_pattern_length = 10,
	
	//RM FIFO
	parameter rate_match_fifo_mode = 0, //legal value: 0,1
	parameter rate_match_pattern1 = "00000000000000000000",
	parameter rate_match_pattern2 = "00000000000000000000",
	
	//Byte Ordering Block
	parameter byte_order_mode = 0, //legal value: None,8,9,10,16,18 and 20
	parameter byte_order_pattern = "0", //legal value: 8,9, or 10 bit binary string
	parameter byte_order_pad_pattern = "000000000", //legal value: 10 bit binary string
	
	//Analog Parameters
	parameter rx_termination = "OCT_100_OHMS", //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
	parameter rx_use_external_termination = "false", //legal value:true,false
	parameter rx_common_mode = "0.82V", //legal value: "0.65V"
	parameter rx_ppmselect = 32,
	parameter rx_signal_detect_threshold = 9,
	parameter rx_use_cruclk = "TRUE",
	parameter tx_termination = "OCT_100_OHMS", //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
	parameter tx_use_external_termination = "false", //legal value:true,false
	parameter tx_analog_power = "AUTO",//legal value: AUTO,1.4V,1.5V
	parameter tx_common_mode = "0.65V",//legal value: 0.65V
	parameter gxb_analog_power = "AUTO",//legal value: AUTO,2.5V,3.0V,3.3V,3.9V
	parameter pll_lock_speed = "AUTO",
	parameter tx_slew_rate = "OFF",
	parameter rx_pll_lock_speed = "AUTO",
	parameter rx_eq_ctrl = 3, //legal value: 0-16
	parameter rx_eq_dc_gain = 0, //legal value 0-4
	parameter tx_preemp_pretap = 0, //legal value: 0-7
	parameter tx_preemp_pretap_inv = "FALSE", //copy from alt_pma
	parameter tx_preemp_tap_1 = 0, //0-15
	parameter tx_preemp_tap_2 = 0, //0-7
	parameter tx_preemp_tap_2_inv = "FALSE",
	parameter tx_vod_selection = 4 //0-7

	) (
	   
	   //input from reset controller
	   
	   input tri0 [reconfig_interfaces-1:0]  gxb_powerdowng, //check whether this should exist
	   input tri0 [plls-1:0]   pll_powerdown, //check for suitable formula
	   input tri0 [lanes-1:0] tx_digitalreset,
	   input tri0 [lanes-1:0] rx_analogreset,  //for rx pma
	   input tri0 [lanes-1:0] rx_digitalreset, //for rx pcs
	   
	   //clk signal
	   input  wire  [plls-1:0]   pll_ref_clk,
	   input  tri0  [lanes-1:0]  tx_coreclkin,
	   input  tri0  [lanes-1:0]  rx_coreclkin,
	   
	   //data ports
	   input   wire  [ser_words*ser_base_factor*lanes-1:0]      tx_parallel_data,
	   output  wire  [ser_words*ser_base_factor*lanes-1:0]      rx_parallel_data,
	   input   wire  [lanes-1:0]                     rx_parallel_data_read,
	   input   wire  [(ser_words*lanes)-1:0]   tx_datak,   
	   output  wire  [(ser_words*lanes)-1:0]   rx_datak,
	   input   wire  [(ser_words*lanes)-1:0]   tx_forcedisp,
	   input   wire  [(ser_words*lanes)-1:0]   tx_dispval,
	   input   wire  [(ser_words*lanes)-1:0]   rx_runningdisp,
	   input   wire  [lanes-1:0]                     rx_enabyteord,

	   input   wire  [lanes-1:0]    rx_serial_data,
	   output  wire  [lanes-1:0]    tx_serial_data,
	   
	   //clock outputs
	   
	   output  wire  [lanes-1:0]    tx_clkout,
	   output  wire  [lanes-1:0]    rx_clkout,
	   output  wire  [(lanes/bonded_group_size)-1:0] coreclkout,
	  
	   
	   //control ports
	   
	   input   tri0  [lanes-1:0]    tx_forceelecidle,
	   input   tri0  [lanes-1:0]    tx_invpolarity,
	   input   tri0  [lanes*5-1:0]  tx_bitslipboundaryselect,
	   
	   input   tri0  [lanes-1:0]    rx_invpolarity,
	   input   tri0  [lanes-1:0]    rx_seriallpbken,
	   input   tri0  [lanes-1:0]    rx_set_locktodata,
	   input   tri0  [lanes-1:0]    rx_set_locktoref,
	   input   tri0  [lanes-1:0]    rx_enapatternalign,
	   input   tri0  [lanes-1:0]    rx_bitslip,
	   input   tri0  [lanes-1:0]    rx_bitreversalenable,
	   input   tri0  [lanes-1:0]    rx_bytereversalenable,
	   input   tri0  [lanes-1:0]    rx_a1a2size,
	   
	   input   wire                 reconfig_clk,
	   output   wire  [(17*reconfig_interfaces)-1:0] reconfig_fromgxb,
	   input    wire  [3:0]          reconfig_togxb,

	   //adding aeq

	  // input wire [reconfig_interfaces*4*6-1:0] aeq_togxb,
	   //output wire [reconfig_interfaces*4*2-1:0] aeq_fromgxb,
	   
	   output   wire  [lanes-1:0]                          rx_rlv,
	   output   wire  [(ser_words*lanes)-1:0]        rx_patterndetect,
	   output   wire  [(ser_words*lanes)-1:0]        rx_syncstatus,
	   output   wire  [(lanes * 5)-1:0]                    rx_bitslipboundaryselectout,
	   output   wire  [(ser_words*lanes)-1:0]        rx_errdetect,
	   output   wire  [(ser_words*lanes)-1:0]        rx_disperr,
	   output   wire  [lanes-1:0]                          rx_rmfifofull,
	   output   wire  [lanes-1:0]                          rx_rmfifoempty,
	   output   wire  [(ser_words*lanes)-1:0]        rx_rmfifodatainserted,
	   output   wire  [(ser_words*lanes)-1:0]        rx_rmfifodatadeleted,
	   output   wire  [ser_words*lanes-1:0]          rx_a1a2sizeout,
	   
	   output  wire  [lanes-1:0]                          rx_is_lockedtoref,
	   output  wire  [lanes-1:0]                          rx_signaldetect,
	   output  wire  [lanes-1:0]                          rx_is_lockedtodata,
	   output  wire  [plls-1:0]                           pll_locked, //check for suitable formula
	   
	   output  wire  [lanes-1:0]                          rx_phase_comp_fifo_error,
	   output  wire  [lanes-1:0]                          tx_phase_comp_fifo_error,
	   
	   input   tri0   cal_blk_clk,
	   input   tri0   cal_blk_powerdown,
	   input   wire   [lanes-1:0]									rx_cdr_ref_clk
	   
	   
	   );

      
      genvar 	   num_tx;	
      genvar 	   num_rx;
      genvar 	   num_pll;
      
      //derived parameters


      localparam   deser_factor = ser_words*ser_base_factor;
      localparam   bonded_mode = (bonded_group_size == 4)?"x4":(bonded_group_size == 8)?"x8":"x1";
        localparam   single_or_double_width = (deser_factor <= 10)?"single":"double";
      
      
      localparam   INT_RX_PMA_RECOVERDATAOUT_WIDTH = 20;
    //  localparam   DWIDTH_FACTOR=(deser_factor % 8 == 0)? (deser_factor/8) : (deser_factor/10);

      localparam   DWIDTH_FACTOR = (deser_factor == 8)?(deser_factor/8):(deser_factor == 16)?(deser_factor/8):(deser_factor == 32)?(deser_factor/8):(deser_factor/10);
      
      localparam   number_of_quads = (lanes%4 == 0)? (lanes/4): ((lanes/4)+1);
      
      //instantiate package with common functions  
      
      //derived parameters (from alt_pma)  
      
      localparam   use6g = (single_or_double_width == "double")? "TRUE":"FALSE";
      localparam   pma_serialization_factor = (deser_factor > 20)?(deser_factor/2):(deser_factor < 16)?deser_factor:(use6g == "TRUE") ? deser_factor:(deser_factor/2);
      localparam   tx_inclk0_input_period_loc = freq2ps(pll_refclk_freq); //check with Marcel and Kai Lin
      localparam   double_serialization_mode = (deser_factor/pma_serialization_factor == 2)?"TRUE":"FALSE";
      
      localparam   rx_eqa_ctrl = (device_family == "Stratix IV")? ((rx_eq_ctrl > 10) ? 7 : 0):((rx_eq_ctrl > 1)? 1 : 0); // rx_eq_ctrl should be added as parameter
      localparam   rx_eqb_ctrl = (device_family == "Stratix IV")? ((rx_eq_ctrl > 6) ? 7 : 0):((rx_eq_ctrl > 3)? 1 : 0);
      localparam   rx_eqc_ctrl = (device_family == "Stratix IV")? ((rx_eq_ctrl > 3) ? 7 : 0):0;
      localparam   rx_eqd_ctrl = (device_family == "Stratix IV")? ((rx_eq_ctrl > 0) ? 7 : 0):0;
      localparam   rx_eqv_ctrl = (device_family == "Stratix IV")?
		   ((rx_eq_ctrl == 2 | rx_eq_ctrl == 5 | rx_eq_ctrl == 8 | rx_eq_ctrl == 13)?4 :
		    ((rx_eq_ctrl == 3 | rx_eq_ctrl == 6 | rx_eq_ctrl == 10 | rx_eq_ctrl == 15)?7 :
		     ((rx_eq_ctrl == 9 | rx_eq_ctrl == 14) ? 5:
		      (rx_eq_ctrl == 12) ? 3:0))):
		   ((rx_eq_ctrl == 0 | rx_eq_ctrl == 2 | rx_eq_ctrl == 4)? 1 : 0);
      localparam   number_of_ctrl_bus = (bonded_mode == "x4"|"x8")? number_of_quads:1;   
      localparam   control_signal_width = (bonded_mode == "x4"|"x8")?1:lanes;
      
      //parameters for 8b10b
   //   localparam   xcvr_8b_10b_mode_loc = (use_8b10b == "TRUE")? (((DWIDTH_FACTOR == 1)? "normal":(DWIDTH_FACTOR == 2 & single_or_double_width == "single")? "normal":"cascaded"):(DWIDTH_FACTOR == 4)?"cascaded":"none")):"none";

     // localparam   xcvr_8b_10b_mode_loc = (use_8b10b == "TRUE")?((DWIDTH_FACTOR == 1)? "normal":(DWIDTH_FACTOR == 4)? "cascaded":((DWIDTH_FACTOR == 2) & (single_or_double_width == "double")): "cascaded":"normal"):(use_8b10b == "false"):"none":"none";

     // localparam   xcvr_8b_10b_mode_loc = (use_8b10b == 0)?"none":(single_or_double_width == "double")?"cascaded":"normal";

   localparam 	   xcvr_8b_10b_mode_loc = (use_8b10b == "false")?"none":(single_or_double_width == "double")?"cascaded":"normal";
   
 
      
      localparam   rate_match_fifo_mode_loc = (rate_match_fifo_mode == 1)? "normal":"none";
      
      //word aligner params
     // localparam   word_aligner_pattern_length_loc = 10;
      localparam   rx_bitslip_enable_loc = (word_aligner_mode == "bitslip")? "TRUE":"FALSE";
      
      
      
      localparam   channel_bonding_loc = (bonded_mode == "x1")?"indv":(bonded_mode == "x4")? "x4":"x8";   
      localparam   tx_pll_m_divider_loc = 0;
      localparam   rx_cru_m_divider_loc = 0;
    //  localparam   word_aligner_pattern_length = 32;
    
     // localparam   single_or_double_width = "single";
      
    //  localparam   rx_use_align_state_machine_loc = ((word_aligner_mode == "bitslip") & (deser_factor <= 10))? "FALSE":"TRUE";
	localparam rx_use_align_state_machine_loc = ((word_aligner_mode == "manual") & (single_or_double_width == "single"))? "FALSE": ((word_aligner_mode == "bitslip") & (single_or_double_width == "single"))? "FALSE":"TRUE";
      localparam   pll_ctrl_width_loc = (bonded_mode == "x4")?(lanes/4):(bonded_mode == "x8")?(lanes/8):number_of_quads;
      localparam   tx_digitalreset_width_loc = (bonded_mode == "x4")?(lanes/4):(bonded_mode == "x8")?(lanes/8):lanes;
      

   wire [pll_ctrl_width_loc-1:0] pll_locked_from_gxb_wire;
   
      
  
      //altgx instance   
      
      alt4gxb
	#(

	  .coreclkout_control_width((bonded_mode == "x1")? number_of_quads: (lanes/bonded_group_size)),
	  .device_family(device_family),
	  .device_type(device_type),
	  .effective_data_rate(data_rate),
	  .enable_lc_tx_pll("false"), //can be removed
	  .enable_pll_inclk_drive_rx_cru((rx_use_cruclk == "FALSE")?"TRUE":"FALSE"),
	  .equalizer_ctrl_a_setting(rx_eqa_ctrl),
	  .equalizer_ctrl_b_setting(rx_eqb_ctrl),
	  .equalizer_ctrl_c_setting(rx_eqc_ctrl),
	  .equalizer_ctrl_d_setting(rx_eqd_ctrl),
	  .equalizer_ctrl_v_setting(rx_eqv_ctrl),
	  .equalizer_dcgain_setting(rx_eq_dc_gain),
	  .gen_reconfig_pll("false"),
	  .gx_channel_type("auto"),
	  .gxb_analog_power(gxb_analog_power),
	  .gxb_powerdown_width(number_of_quads),
	  .input_clock_frequency(pll_refclk_freq),
	 // .intended_device_speed_grade("2"),
	 // .intended_device_variant("GX"),
	  .loopback_mode((operation_mode == "Duplex") ? "slb" : "none"),
	  .number_of_channels(lanes),
	  .number_of_quads(number_of_quads),
	  .operation_mode(operation_mode),
	  .pll_control_width(pll_ctrl_width_loc), //check later
	  .pll_pfd_fb_mode("internal"), //can be removed later
	  .preemphasis_ctrl_1stposttap_setting(tx_preemp_tap_1),
	  .preemphasis_ctrl_2ndposttap_inv_setting(tx_preemp_tap_2_inv),
	  .preemphasis_ctrl_2ndposttap_setting(tx_preemp_tap_2),
	  .preemphasis_ctrl_pretap_inv_setting(tx_preemp_pretap_inv),
	  .preemphasis_ctrl_pretap_setting(tx_preemp_pretap),
	  .protocol("basic"),
	  .receiver_termination(rx_termination),
	  .rx_use_external_termination(rx_use_external_termination),
	  .reconfig_calibration("true"),
	  .reconfig_dprio_mode(0),
	  .reconfig_fromgxb_port_width(17*number_of_quads),
	 // .reconfig_pll_inclk_width(1),
	 // .reconfig_protcol("basic"),
	  .reconfig_togxb_port_width(4),
	  .rx_8b_10b_mode(xcvr_8b_10b_mode_loc), //removed local param
	  .rx_align_pattern(word_align_pattern), 
	  .rx_align_pattern_length(word_aligner_pattern_length), //removed local param
	  .rx_allow_align_polarity_inversion("true"),  //check later - set to false for bitslip
	  .rx_bitslip_enable(rx_bitslip_enable_loc), //change to use param value
	  .rx_byte_order_pad_pattern(byte_order_pad_pattern),
	  .rx_byte_order_pattern(byte_order_pattern),
	  .rx_byte_ordering_mode(byte_order_mode), //change to use param value
	  .rx_channel_bonding("indv"),
	  .rx_channel_width(deser_factor),
	  .rx_common_mode(rx_common_mode),
	//  .rx_cru_bandwidth_type("auto"),
	//  .rx_cru_inclock0_period(tx_inclk0_input_period_loc),
	//  .rx_cru_m_divider(10),
	//  .rx_cru_n_divider(1),
	  .rx_data_rate(data_rate),
	  .rx_datapath_protocol("basic"),
	  .rx_digitalreset_port_width(lanes),
	  .rx_dwidth_factor(DWIDTH_FACTOR),
	  .rx_enable_bit_reversal("false"),
	  .rx_enable_lock_to_data_sig("true"),
	  .rx_enable_lock_to_refclk_sig("true"),
	  .rx_force_signal_detect("true"),
	  .rx_ppmselect(rx_ppmselect),
	  .rx_rate_match_fifo_mode(rate_match_fifo_mode_loc), //removed rate_match_fifo_mode_loc
	  .rx_rate_match_pattern1(rate_match_pattern1),
	  .rx_rate_match_pattern2(rate_match_pattern2),
	  //.rx_reconfig_clk_scheme("indv_clk_source"),
	  .rx_run_length(run_length_violation_checking),
	  .rx_run_lenth_enable((run_length_violation_checking > 0)? "TRUE":"FALSE"),
	  .rx_use_align_state_machine(rx_use_align_state_machine_loc),
	  .rx_use_clkout("true"),
	  .rx_use_coreclk(rx_use_coreclk),
	  .rx_use_cruclk(rx_use_cruclk),
	  .rx_use_deserializer_double_data_mode(use6g),
	  .rx_use_deskew_fifo("false"),
	  .rx_use_double_data_mode(double_serialization_mode),  // changed from double_serialization_mode
	  .rx_use_rising_edge_triggered_pattern_align("true"), //newly added for manual alignment
	  .rx_word_aligner_num_byte(2), //newly added
	  .starting_channel_number(starting_channel_number),
	  .transmitter_termination(tx_termination),
	  .tx_use_external_termination(tx_use_external_termination),
	  .tx_8b_10b_mode(xcvr_8b_10b_mode_loc),
	  .tx_allow_polarity_inversion("true"),  //set to false for bitslip
	  .tx_analog_power(tx_analog_power),
	  .tx_bitslip_enable(tx_bitslip_enable), 
	  .tx_channel_bonding(channel_bonding_loc),
	  .tx_channel_width(deser_factor),
	  .tx_clkout_width(lanes),
	  .tx_common_mode(tx_common_mode),
	  .tx_digitalreset_port_width(tx_digitalreset_width_loc), //add new local param
	  .tx_dwidth_factor(DWIDTH_FACTOR),
	  .tx_enable_bit_reversal("false"),
	  .tx_force_disparity_mode((use_8b10b_manual_control == 1)? "true":"false"),
	//  .tx_pll_inclk0_period(tx_inclk0_input_period_loc),
	 // .tx_pll_m_divider(10),
	 // .tx_pll_n_divider(1),
	  .tx_transmit_protocol("basic"),
	  .tx_use_coreclk(tx_use_coreclk),
	  .tx_use_double_data_mode(double_serialization_mode), //changed from double_serialization_mode
	  .tx_use_serializer_double_data_mode(use6g),
	  .use_calibration_block("true"),
	  .vod_ctrl_setting(tx_vod_selection)
	  
	  //newly added
	 // .rx_use_align_state_machine("false")
	
		
	  
	  ) basic (
		   
		   .cal_blk_clk(cal_blk_clk),
		   .cal_blk_powerdown(cal_blk_powerdown),
		  // .gxb_powerdown(gxb_powerdown),
		   .pll_inclk(pll_ref_clk),
		   .rx_cruclk((rx_use_cruclk == "TRUE")? rx_cdr_ref_clk[lanes-1:0]:{lanes{1'b0}}),
		   .pll_locked(pll_locked_from_gxb_wire),
		   .pll_powerdown({pll_ctrl_width_loc{pll_powerdown}}),
		   .reconfig_clk(reconfig_clk),
		   .reconfig_fromgxb(reconfig_fromgxb),
		   .reconfig_togxb(reconfig_togxb),
		   .rx_analogreset((operation_mode == "TX")? 1'b0 : rx_analogreset),
		   .rx_seriallpbken(rx_seriallpbken),
		   .rx_signaldetect(rx_signaldetect),
		   .tx_digitalreset(tx_digitalreset),
		   .rx_digitalreset(rx_digitalreset[lanes-1:0]),
		   .rx_clkout(rx_clkout),
		   
			.rx_ctrldetect(rx_datak),
		   .rx_datain(rx_serial_data[lanes-1:0]),
		   .rx_dataout(rx_parallel_data[deser_factor*lanes-1:0]),		
		  .rx_enapatternalign(rx_enapatternalign),		
		   .rx_syncstatus((operation_mode == "TX") ? 1'b0 : rx_syncstatus),
		   .rx_patterndetect((operation_mode == "TX")? 1'b0 : rx_patterndetect),
			.rx_bitslip(rx_bitslip),
			.rx_a1a2size(rx_a1a2size),
		   .rx_bitslipboundaryselectout((tx_bitslip_enable == "true")? rx_bitslipboundaryselectout : {lanes*5-1 {1'b0}}),
		   .rx_runningdisp(rx_runningdisp),
		   .rx_rlv((operation_mode == "TX")? 1'b0: rx_rlv),
		   .rx_errdetect(rx_errdetect),
		   .rx_disperr(rx_disperr),				
		   .rx_locktodata(rx_set_locktodata[lanes-1:0]),
		   .rx_locktorefclk(rx_set_locktoref[lanes-1:0]),
		   .rx_pll_locked((operation_mode == "TX") ? {lanes{1'b0}} : rx_is_lockedtoref[lanes-1:0]),
		   .rx_freqlocked((operation_mode == "TX")? 1'b0 : rx_is_lockedtodata[lanes-1:0]),
		   .rx_invpolarity(rx_invpolarity),
 		   .tx_invpolarity(tx_invpolarity),
		   .tx_bitslipboundaryselect(tx_bitslipboundaryselect),
		   .tx_clkout(tx_clkout),
		   .coreclkout(coreclkout),
		  .tx_forceelecidle(tx_forceelecidle),
		  .tx_ctrlenable(tx_datak),
		   .tx_datain(tx_parallel_data[deser_factor*lanes-1:0]),
		   .tx_dataout(tx_serial_data[lanes-1:0]),
		   .tx_dispval(tx_dispval),
		   .tx_forcedisp(tx_forcedisp),
		   .rx_phase_comp_fifo_error((operation_mode == "TX")? 1'b0: rx_phase_comp_fifo_error),
		   .tx_phase_comp_fifo_error((operation_mode == "RX")? 1'b0 : tx_phase_comp_fifo_error),
		   .rx_rmfifofull(rx_rmfifofull),
		   .rx_rmfifoempty(rx_rmfifoempty),
		   .rx_rmfifodatainserted(rx_rmfifodatainserted),
		   .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
		   .rx_a1a2sizeout(rx_a1a2sizeout),
			.tx_coreclk((tx_use_coreclk != "false")?tx_coreclkin:{lanes{1'b0}}),
			.rx_coreclk((rx_use_coreclk != "false")?rx_coreclkin:{lanes{1'b0}})
		 //  .aeq_fromgxb(aeq_fromgxb),
		  // .aeq_togxb(aeq_togxb)
		   );

   assign 			 pll_locked = &pll_locked_from_gxb_wire;
   
      
      
      function integer freq2ps; 
	  input [8*16:1] s;
	  
	  integer 	   in_freq_khz;
	  integer 	   period_ps;
	  
	  in_freq_khz =  mega2k(s);      
	  freq2ps = 1000000000/(in_freq_khz);
      endfunction
      
      
      // convert "xx.xxx MHz" string to integer with hz as unit
      function integer mega2k; 
	  input [8*16:1] s;
      
	  reg [8*16:1]     reg_s;
	  reg [8:1] 	   digit;
	  reg [8:1] 	   tmp;
	  integer 	   m;
	  integer          magnitude;
	  integer 	   final_mag;
	  integer 	   unit_mag;
	  integer 	   point_pos;
	  
	  begin
		magnitude = 0;
		reg_s = s;
		unit_mag = 1000000;
		point_pos = 0;
		for (m=1; m<=16; m=m+1)
		  begin
			tmp = reg_s[128:121];
			digit = tmp & 8'b00001111;
			reg_s = reg_s << 8;
			// Accumulate ascii digits 0-9 only.
			if (tmp == 77)
			  unit_mag = 1000;  // Found a 'M' character, Mhz
			if (tmp == 46)
			  point_pos = 1;  // Found a '.' character, point
			if ((tmp>=48) && (tmp<=57)) begin 
			      magnitude = (magnitude * 10) + digit;
			      point_pos = point_pos *10;
			end
		  end
		if(point_pos > 0)
		  mega2k = magnitude*unit_mag/point_pos;
		else
		  mega2k = magnitude*unit_mag;
	  end
      endfunction
      
endmodule // siv_xcvr_generic

		     
		     
		

       
	      
	      
	      
	     
	     
	      
	      
	      
	      
	      
       
       

	     
	     
   

   

 
   
   
   
   
   
   
   
    
   
    
    
    
   
   
   
   
   
   
                    

   

    
    
    
    

			    
