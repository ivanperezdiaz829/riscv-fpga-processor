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


// (C) 2001-2010 Altera Corporation. All rights reserved.
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
// PMA-direct component for TGX-style transceiver architectures
//
// $Header$
//
`timescale 1 ps / 1 ps
module  alt_pma_10gbaser_tgx
#(
   parameter
	//reserved parameter, don't change them.
	device_family="Stratix IV", 
	intended_device_variant ="GT",
	//must have parameters
	number_of_channels = 1,
	operation_mode = "DUPLEX", //TX, RX, DUPLEX
	phase_comp_fifo_mode = "EMBEDDED",//EMBEDDED, NONE 
	serialization_factor = 40,//8,10,16,20,32,40
	data_rate = "10312.5 Mbps",
	pll_input_frequency = "644.53125 MHz",
	
	//additonal system parameters
	number_pll_inclks = 1,//reconfig may need more than one reference clock
	pll_inclk_select = 0,//0-number_of_ref_clks
	pll_type = "CMU",//ATX|CMU
	bonded_mode = "FALSE",
	starting_channel_number = 0,//0,4,8,12 ...
	support_reconfig = 1,
	rx_use_cruclk = "FALSE",
	
	//analog parameters
	gx_analog_power = "AUTO",//AUTO|2.5v|3.0v|3.3v|3.9v
	
//	pll_lock_speed = "AUTO",//AUTO|LOW|MEDIUM|HIGH 
	tx_analog_power = "AUTO",//AUTO|1.4V|1.5V 
//	tx_slew_rate = "LOW",//AUTO,LOW,MEDIUM,HIGH
	tx_termination = "OCT_100_OHMS",//OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS                      
//	tx_common_mode = "0.65V",  //"0.65V"                              
	
//	rx_pll_lock_speed = "AUTO",//AUTO|LOW|MEDIUM|HIGH
	rx_common_mode = "0.82v",  //TRISTATE|0.82v|1.1v                                
//	rx_signal_detect_threshold = 2,                       
//	rx_ppmselect = 32,                                         
	rx_termination = "OCT_100_OHMS", //OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS                      
	
	tx_preemp_pretap = 0,//0-7
	tx_preemp_pretap_inv = "FALSE",//?TRUE? or ?FALSE?. Determine whether the pre-emphasis control signal for the pretap needed to be inverted or not.?true? ? Invert the pre-emphasis control signal for the pre tap.?false? ? Do not invert the pre-emphasis control signal for the pretap.
	tx_preemp_tap_1 = 5,//0-15
	tx_preemp_tap_2 = 0,//0-7
	tx_preemp_tap_2_inv = "FALSE",//?TRUE? or ?FALSE?.
	tx_vod_selection = 1,//0-7
	
	rx_eq_dc_gain = 0, //0-4                                        
	rx_eq_ctrl = 14,//0-16                                           
	
	sys_clk_in_mhz = 150, // used to calculate reset controller delays as system clock cycle counts
	reconfig_interfaces = 1,
	loopback_mode = "NONE"//NONE|SLB|PLB|PRECDR_RSLB|POSTCDR_RSLB|RPLB
)
( 

   // user data (avalon-MM slave interface) //for all the channel rst, powerdown, rx serilize loopback enable
   input   wire         rst,
   input   wire         clk,
   input   wire	[5:0]	ch_mgmt_address,
   input   wire		ch_mgmt_read,
   output  wire	[31:0]	ch_mgmt_readdata,
   input   wire		ch_mgmt_write,
   input   wire	[31:0]	ch_mgmt_writedata,
   output  wire 	ch_mgmt_waitrequest,

   // avalon-ST interface with PMA controller
   input   wire		cal_blk_clk,
   input   wire		cal_blk_pdn,
   input   wire		gx_pdn,//sync with clk
   input    wire         tx_rst_digital, // digital reset
   input    wire         rx_rst_digital, // digital reset
   output    wire        tx_pma_ready, // pma tx pll_locked
   output    wire        rx_pma_ready, // pma rx pll is locked to data
 
   input   wire 	pll_pdn, //sync with clk
   output  wire 	pll_locked, //conduit
   
    // avalon-ST interface with reconfig controller
   input   wire			reconfig_clk,
   input   wire	  [3:0]		reconfig_to_gxb, //sync with reconfig_clk
   output  wire   [17* number_of_channels -1:0]	reconfig_from_gxb, //sync with reconfig_clk. 17 bit per quad
//   input   wire	  [24 * number_of_reconfig_interface -1 : 0]		aeq_to_gxb, //sync with reconfig_clk
//   output  wire	  [8*number_of_reconfig_interface -1:0]		aeq_from_gxb,  //sync with reconfig_clk.
 

  //channel related avalon-clock interface
    input  wire	  [number_pll_inclks-1:0]	pll_ref_clk,
 
  //channel related avalon-ST interface, tx
    input   wire  [number_of_channels * serialization_factor -1:0]	tx_parallel_data,// sync with tx_clkout_clk
    output  wire  [number_of_channels-1:0]	tx_serial_data, // canduit 
    output  wire  [number_of_channels-1:0]	tx_out_clk,
	
  //channel related AVALON-st INTERFACE, rx
    input   wire  [number_of_channels-1:0]	rx_serial_data,//canduit
    output  wire  [number_of_channels * serialization_factor -1:0]	rx_parallel_data,// sync with rx_clkout_clk
    output  wire  [number_of_channels-1:0]	rx_recovered_clk,

    output  wire  [number_of_channels-1:0] tx_digital_rst,
    output  wire  [number_of_channels-1:0] rx_digital_rst,

	
    output  wire  [number_of_channels-1:0]	rx_is_lockedtodata,//conduit
    output  wire  [number_of_channels-1:0]	rx_is_lockedtoref//conduit
);



// instantiate package with common functions
import alt_pma_functions::*;

//derived parameters
localparam tx_inclk0_input_period_loc = freq2ps(pll_input_frequency) ;                         
localparam use6g= (mega2k(data_rate) > 1000000)?  "TRUE" : "FALSE";                           
localparam pma_serialization_factor = (phase_comp_fifo_mode != "EMBEDDED") ? serialization_factor :
	((serialization_factor>20)? (serialization_factor/2): 
	((serialization_factor<16)? serialization_factor : 
	((use6g == "TRUE")? serialization_factor : serialization_factor /2))); 
//localparam RX_INCLK_INPUT_PERIOD_LOC = ( RX_INCLK_INPUT_PERIOD == 0) ? freq2ps(RX_pll_input_frequency) : RX_INCLK_INPUT_PERIOD;                         
//localparam rx_inclk_input_frequency_loc = ( operation_mode == "DUPLEX") ? ((RX_INCLK_INPUT_FREQUENCY == 0) ? INCLK_INPUT_FREQUENCY : RX_INCLK_INPUT_FREQUENCY) :0;                         
localparam double_serilizetion_mode=(serialization_factor/pma_serialization_factor == 2) ? "TRUE":"FALSE";                       
localparam rx_eqa_ctrl = (device_family=="Stratix IV") ? ((rx_eq_ctrl >10)? 7 :0) : ((rx_eq_ctrl >1)? 1:0);
localparam rx_eqb_ctrl = (device_family=="Stratix IV") ? ((rx_eq_ctrl >6)? 7 :0) : ((rx_eq_ctrl >3)? 1:0);
localparam rx_eqc_ctrl = (device_family=="Stratix IV") ? ((rx_eq_ctrl >3)? 7 :0) : 0;
localparam rx_eqd_ctrl = (device_family=="Stratix IV") ? ((rx_eq_ctrl >0)? 7 :0) : 0;
localparam rx_eqv_ctrl = (device_family=="Stratix IV") ? 
	((rx_eq_ctrl==2 | rx_eq_ctrl==5 | rx_eq_ctrl==8 | rx_eq_ctrl==13)? 4 :
	((rx_eq_ctrl==3 | rx_eq_ctrl==6 | rx_eq_ctrl==10 | rx_eq_ctrl==15)? 7 : 
	((rx_eq_ctrl==9 | rx_eq_ctrl==14 )? 5 :
	(rx_eq_ctrl==12)? 3 : 0))) :
	((rx_eq_ctrl==0 | rx_eq_ctrl==2 | rx_eq_ctrl==4 )? 1 :0 );

localparam enable_lc_tx_pll_param = (pll_type == "CMU")? "FALSE" : "TRUE"; 
localparam enable_pma_direct_param = (phase_comp_fifo_mode == "EMBEDDED")? "FALSE":"TRUE"; 
localparam dwidth_factor = (use6g == "TRUE")? (double_serilizetion_mode == "TRUE" ? 4:2):(double_serilizetion_mode == "TRUE" ? 2:1); 
localparam reconfig_dprio_mode = (support_reconfig == 0)? 0 : 1;

localparam 	control_signal_width = (bonded_mode == "TRUE") ? 1: number_of_channels;
localparam pma_direct_xn = (phase_comp_fifo_mode == "NONE")? bonded_mode : "FALSE";
localparam pma_bonding = (phase_comp_fifo_mode == "EMBEDDED")? bonded_mode : "FALSE";
localparam tx_termination_atom = (tx_termination == "OCT_85_OHMS") ? "OCT 85 OHMS" : 
				((tx_termination == "OCT_100_OHMS") ? "OCT 100 OHMS":
				((tx_termination == "OCT_120_OHMS") ? "OCT 120 OHMS":"OCT 150 OHMS"));

localparam rx_termination_atom = (rx_termination == "OCT_85_OHMS") ? "OCT 85 OHMS" : 
				((rx_termination == "OCT_100_OHMS") ? "OCT 100 OHMS":
				((rx_termination == "OCT_120_OHMS") ? "OCT 120 OHMS":"OCT 150 OHMS"));
				


wire [control_signal_width-1:0] gxb_pdn_loc;
generate
genvar i;
for (i=0; i<control_signal_width; i=i+1) 
begin: gxb_pdn_bus
assign gxb_pdn_loc[i] = gx_pdn;
end 
endgenerate

wire [control_signal_width-1:0] pll_pdn_loc;
generate
genvar j;
for (j=0; j<control_signal_width; j=j+1) 
begin: pll_pdn_bus
assign pll_pdn_loc[j] = pll_pdn;
end 
endgenerate

wire [number_of_channels-1:0] rx_set_locktodata;
wire [number_of_channels-1:0] rx_set_locktoref;
 wire [number_of_channels-1:0] pll_locked_loc;

wire [number_of_channels-1:0] rx_analog_rst;   
wire [number_of_channels-1:0] rx_seriallpbken;
//wire [number_of_channels-1:0] tx_digital_rst; 
//wire [number_of_channels-1:0] rx_digital_rst;

assign pll_locked = | pll_locked_loc;

integer k;
genvar l;
generate 
	for(l = 0; l < number_of_channels; l = l + 1) 
	begin: pma_ch
	altera_pma_10g_1ch  #
	(			  .starting_channel_number (l*4 + starting_channel_number),
              .equalizer_ctrl_a_setting(rx_eqa_ctrl), 
              .equalizer_ctrl_b_setting(rx_eqb_ctrl), 
              .equalizer_ctrl_c_setting(rx_eqc_ctrl), 
              .equalizer_ctrl_d_setting(rx_eqd_ctrl), 
              .equalizer_ctrl_v_setting(rx_eqv_ctrl), 
              .equalizer_dcgain_setting(rx_eq_dc_gain), 
              .receiver_termination(rx_termination_atom), 
              .rx_common_mode(rx_common_mode), 
            //  .rx_ppmselect(rx_ppmselect), 
              .transmitter_termination(tx_termination_atom),
            //  .tx_common_mode(tx_common_mode), 
              .preemphasis_ctrl_pretap_setting(tx_preemp_pretap),
              .preemphasis_ctrl_pretap_inv_setting(tx_preemp_pretap_inv),
              .preemphasis_ctrl_1stposttap_setting(tx_preemp_tap_1),
              .preemphasis_ctrl_2ndposttap_setting(tx_preemp_tap_2),
              .preemphasis_ctrl_2ndposttap_inv_setting(tx_preemp_tap_2_inv),
              .vod_ctrl_setting(tx_vod_selection),
              .pll_type(pll_type)
  	)
	pma_direct ( 
	.cal_blk_clk(cal_blk_clk), 
	.cal_blk_powerdown(cal_blk_pdn), 
	.gxb_powerdown(gxb_pdn_loc), 
	.pll_inclk(pll_ref_clk),
	.pll_locked(pll_locked_loc[l]), 
	.pll_powerdown(pll_pdn_loc), 
	.reconfig_clk(reconfig_clk), 
	.reconfig_fromgxb(reconfig_from_gxb[17* (l+ 1) - 1:17*l]), 
	.reconfig_togxb(reconfig_to_gxb), 
	.rx_analogreset(rx_analog_rst[l]), 
	.rx_seriallpbken(rx_seriallpbken[l]),  
	.tx_digitalreset( tx_digital_rst[l] & tx_rst_digital),  
	.rx_digitalreset( rx_digital_rst[l] & rx_rst_digital),    
	.rx_clkout(rx_recovered_clk[l]), 
	.rx_datain(rx_serial_data[l]), 
	.rx_dataout(rx_parallel_data[40 * (l + 1) -1:40 * l]), 
	.rx_freqlocked(rx_is_lockedtodata[l]), 
	.rx_pll_locked(rx_is_lockedtoref[l]), 
	.tx_clkout(tx_out_clk[l]), 
	.tx_datain(tx_parallel_data[40 * (l+1) -1:40 * l]), 
	.tx_dataout(tx_serial_data[l]) 
	); 
end
endgenerate

alt_pma_ch_controller_tgx #(
	.number_of_channels(number_of_channels),
	.sys_clk_in_mhz(sys_clk_in_mhz),
	.sync_depth(2)
) channel_ctrl (
	.rst(rst),
	.tx_rst_digital(tx_rst_digital), // tx_digitalreset
	.rx_rst_digital(rx_rst_digital), // rx_digitalreset
	.tx_pma_ready(tx_pma_ready), // pma tx pll_locked
	.rx_pma_ready(rx_pma_ready), // pma rx pll is locked to data
  // .rx_oc_busy(reconfig_to_gxb[3]), // rx_ocilator busy
    .rx_cal_busy        (reconfig_to_gxb[3]),  // rx_ocilator busy
    .tx_cal_busy        (1'b0),                // tx_ocilator busy
	.pll_locked(pll_locked), // tx pll_is_locked

	.ch_mgmt_address(ch_mgmt_address),
	.ch_mgmt_read(ch_mgmt_read),
	.ch_mgmt_readdata(ch_mgmt_readdata),
	.ch_mgmt_write(ch_mgmt_write),
	.ch_mgmt_writedata(ch_mgmt_writedata),
	.clk(clk),
	.ch_mgmt_waitrequest(ch_mgmt_waitrequest),

	.rx_is_lockedtodata(rx_is_lockedtodata),
	.rx_is_lockedtoref(rx_is_lockedtoref),
	
	.rx_set_locktodata(rx_set_locktodata),
	.rx_set_locktoref(rx_set_locktoref),

	.rx_analog_rst(rx_analog_rst),   
	.rx_seriallpbken(rx_seriallpbken), 
	.tx_digital_rst(tx_digital_rst),  
	.rx_digital_rst(rx_digital_rst)    
);

endmodule



//synthesis_resources = stratixiv_hssi_calibration_block 1 stratixiv_hssi_clock_divider 1 stratixiv_hssi_cmu 1 stratixiv_hssi_pll 2 stratixiv_hssi_rx_pcs 1 stratixiv_hssi_rx_pma 1 stratixiv_hssi_tx_pcs 1 stratixiv_hssi_tx_pma 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  altera_pma_10g_1ch #(

parameter
        starting_channel_number = 0,
        equalizer_ctrl_a_setting = 0, 
        equalizer_ctrl_b_setting = 0, 
        equalizer_ctrl_c_setting = 0, 
        equalizer_ctrl_d_setting = 0, 
        equalizer_ctrl_v_setting = 0, 
        equalizer_dcgain_setting = 0, 
        preemphasis_ctrl_pretap_setting = 0,
        preemphasis_ctrl_pretap_inv_setting = 0,
        preemphasis_ctrl_1stposttap_setting = 0,
        preemphasis_ctrl_2ndposttap_setting = 0,
        preemphasis_ctrl_2ndposttap_inv_setting = 0,
        transmitter_termination = "OCT 100 OHMS",
        tx_common_mode = "0.65V", 
        vod_ctrl_setting = 4,
        receiver_termination=  "OCT 100 OHMS", 
        rx_ppmselect =32, 
        rx_common_mode = "0.82V", 
        pll_type = "CMU"
 )
	( 
	cal_blk_clk,
	cal_blk_powerdown,
	gxb_powerdown,
	pll_inclk,
	pll_locked,
	pll_powerdown,
	reconfig_clk,
	reconfig_fromgxb,
	reconfig_togxb,
	rx_analogreset,
	rx_clkout,
	rx_datain,
	rx_dataout,
	rx_digitalreset,
	rx_freqlocked,
	rx_pll_locked,
	rx_seriallpbken,
	tx_clkout,
	tx_datain,
	tx_dataout,
	tx_digitalreset) ;
	input   cal_blk_clk;
	input   cal_blk_powerdown;
	input   [0:0]  gxb_powerdown;
	input   pll_inclk;
	output   [0:0]  pll_locked;
	input   [0:0]  pll_powerdown;
	input   reconfig_clk;
	output   [16:0]  reconfig_fromgxb;
	input   [3:0]  reconfig_togxb;
	input   [0:0]  rx_analogreset;
	output   [0:0]  rx_clkout;
	input   [0:0]  rx_datain;
	output   [39:0]  rx_dataout;
	input   [0:0]  rx_digitalreset;
	output   [0:0]  rx_freqlocked;
	output   [0:0]  rx_pll_locked;
	input   [0:0]  rx_seriallpbken;
	output   [0:0]  tx_clkout;
	input   [39:0]  tx_datain;
	output   [0:0]  tx_dataout;
	input   [0:0]  tx_digitalreset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   cal_blk_clk;
	tri0   cal_blk_powerdown;
	tri0   [0:0]  gxb_powerdown;
	tri0   pll_inclk;
	tri0   [0:0]  pll_powerdown;
	tri0   reconfig_clk;
	tri0   [0:0]  rx_analogreset;
	tri0   [0:0]  rx_cruclk;
	tri0   [0:0]  rx_digitalreset;
	tri0   [0:0]  rx_seriallpbken;
	tri0   [39:0]  tx_datain;
	tri0   [0:0]  tx_digitalreset;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif



	wire  wire_cal_blk0_nonusertocmu;
	wire  wire_pll_cal_blk0_nonusertocmu;
	wire  [1:0]   wire_atx_clk_div0_analogfastrefclkout;
	wire  [1:0]   wire_atx_clk_div0_analogrefclkout;
	wire  wire_atx_clk_div0_analogrefclkpulse;
	wire  wire_atx_clk_div0_refclkout;
	wire  [1:0]   wire_ch_clk_div0_analogfastrefclkout;
	wire  [1:0]   wire_ch_clk_div0_analogrefclkout;
	wire  wire_ch_clk_div0_analogrefclkpulse;
	wire  [99:0]   wire_ch_clk_div0_dprioout;
	wire  [1:0]   wire_atx_pll_cent_unit0_clkdivpowerdn;
	wire  [1:0]   wire_atx_pll_cent_unit0_pllpowerdn;
	wire  [1:0]   wire_atx_pll_cent_unit0_pllresetout;
	wire  wire_atx_pll_cent_unit0_quadresetout;
	wire  [599:0]   wire_cent_unit0_cmudividerdprioout;
	wire  [1799:0]   wire_cent_unit0_cmuplldprioout;
	wire  wire_cent_unit0_dpriodisableout;
	wire  wire_cent_unit0_dprioout;
	wire  [1:0]   wire_cent_unit0_pllpowerdn;
	wire  [1:0]   wire_cent_unit0_pllresetout;
	wire  wire_cent_unit0_quadresetout;
	wire  [5:0]   wire_cent_unit0_rxanalogresetout;
	wire  [5:0]   wire_cent_unit0_rxcrupowerdown;
	wire  [5:0]   wire_cent_unit0_rxcruresetout;
	wire  [3:0]   wire_cent_unit0_rxdigitalresetout;
	wire  [5:0]   wire_cent_unit0_rxibpowerdown;
	wire  [1599:0]   wire_cent_unit0_rxpcsdprioout;
	wire  [1799:0]   wire_cent_unit0_rxpmadprioout;
	wire  [5:0]   wire_cent_unit0_txanalogresetout;
	wire  [3:0]   wire_cent_unit0_txctrlout;
	wire  [31:0]   wire_cent_unit0_txdataout;
	wire  [5:0]   wire_cent_unit0_txdetectrxpowerdown;
	wire  [3:0]   wire_cent_unit0_txdigitalresetout;
	wire  [5:0]   wire_cent_unit0_txobpowerdown;
	wire  [599:0]   wire_cent_unit0_txpcsdprioout;
	wire  [1799:0]   wire_cent_unit0_txpmadprioout;
	wire  [3:0]   wire_atx_pll0_clk;
	wire  wire_atx_pll0_locked;
	wire  [3:0]   wire_rx_cdr_pll0_clk;
	wire  [1:0]   wire_rx_cdr_pll0_dataout;
	wire  [299:0]   wire_rx_cdr_pll0_dprioout;
	wire  wire_rx_cdr_pll0_freqlocked;
	wire  wire_rx_cdr_pll0_locked;
	wire  wire_rx_cdr_pll0_pfdrefclkout;
	wire  [3:0]   wire_tx_pll0_clk;
	wire  [299:0]   wire_tx_pll0_dprioout;
	wire  wire_tx_pll0_locked;
	wire  wire_receive_pcs0_cdrctrllocktorefclkout;
	wire  wire_receive_pcs0_clkout;
	wire  [39:0]   wire_receive_pcs0_dataout;
	wire  [399:0]   wire_receive_pcs0_dprioout;
	wire  wire_receive_pcs0_signaldetect;
	wire  [7:0]   wire_receive_pma0_analogtestbus;
	wire  wire_receive_pma0_clockout;
	wire  wire_receive_pma0_dataout;
	wire  [299:0]   wire_receive_pma0_dprioout;
	wire  wire_receive_pma0_locktorefout;
	wire  [63:0]   wire_receive_pma0_recoverdataout;
	wire  wire_receive_pma0_signaldetect;
	wire  wire_transmit_pcs0_clkout;
	wire  [19:0]   wire_transmit_pcs0_dataout;
	wire  [149:0]   wire_transmit_pcs0_dprioout;
	wire  wire_transmit_pcs0_forceelecidleout;
	wire  wire_transmit_pcs0_txdetectrx;
	wire  wire_transmit_pma0_clockout;
	wire  wire_transmit_pma0_dataout;
	wire  [299:0]   wire_transmit_pma0_dprioout;
	wire  wire_transmit_pma0_seriallpbkout;
	wire  [1:0]  analogfastrefclkout;
	wire  [1:0]  analogrefclkout;
	wire  [0:0]  analogrefclkpulse;
	wire  [599:0]  cent_unit_cmudividerdprioout;
	wire  [1799:0]  cent_unit_cmuplldprioout;
	wire  [1:0]  cent_unit_pllpowerdn;
	wire  [1:0]  cent_unit_pllresetout;
	wire  [0:0]  cent_unit_quadresetout;
	wire  [5:0]  cent_unit_rxcrupowerdn;
	wire  [5:0]  cent_unit_rxibpowerdn;
	wire  [1599:0]  cent_unit_rxpcsdprioin;
	wire  [1599:0]  cent_unit_rxpcsdprioout;
	wire  [1799:0]  cent_unit_rxpmadprioin;
	wire  [1799:0]  cent_unit_rxpmadprioout;
	wire  [1199:0]  cent_unit_tx_dprioin;
	wire  [31:0]  cent_unit_tx_xgmdataout;
	wire  [3:0]  cent_unit_txctrlout;
	wire  [5:0]  cent_unit_txdetectrxpowerdn;
	wire  [599:0]  cent_unit_txdprioout;
	wire  [5:0]  cent_unit_txobpowerdn;
	wire  [1799:0]  cent_unit_txpmadprioin;
	wire  [1799:0]  cent_unit_txpmadprioout;
	wire  [599:0]  clk_div_cmudividerdprioin;
	wire  [3:0]  clock_divider_clk0in;
	wire  [0:0]  edge_cmu_clkdivpowerdn;
	wire  [0:0]  edge_cmu_pllpowerdn;
	wire  [0:0]  edge_cmu_pllresetout;
	wire  [0:0]  edge_cmu_quadresetout;
	wire  [1:0]  edge_pll_analogfastrefclkout;
	wire  [1:0]  edge_pll_analogrefclkout;
	wire  [0:0]  edge_pll_analogrefclkpulse;
	wire  [9:0]  edge_pll_clkin;
	wire  [3:0]  edge_pll_out;
	wire  [0:0]  edge_pllpowerdn_in;
	wire  [0:0]  edge_pllreset_in;
	wire  [5:0]  fixedclk_to_cmu;
	wire  [0:0]  nonusertocmu_out;
	wire  [0:0]  nonusertocmu_out_pll;
	wire  [9:0]  pll0_clkin;
	wire  [299:0]  pll0_dprioin;
	wire  [299:0]  pll0_dprioout;
	wire  [3:0]  pll0_out;
	wire  [1:0]  pll_ch_dataout_wire;
	wire  [299:0]  pll_ch_dprioout;
	wire  [1799:0]  pll_cmuplldprioout;
	wire  [0:0]  pll_edge_locked_out;
	wire  [0:0]  pll_inclk_wire;
	wire  [0:0]  pll_locked_out;
	wire  [1:0]  pllpowerdn_in;
	wire  [1:0]  pllreset_in;
	wire  [0:0]  reconfig_togxb_busy;
	wire  [0:0]  reconfig_togxb_disable;
	wire  [0:0]  reconfig_togxb_in;
	wire  [0:0]  reconfig_togxb_load;
	wire  [5:0]  rx_analogreset_in;
	wire  [5:0]  rx_analogreset_out;
	wire  [0:0]  rx_clkout_wire;
	wire  [0:0]  rx_coreclk_in;
	wire  [9:0]  rx_cruclk_in;
	wire  [3:0]  rx_deserclock_in;
	wire  [3:0]  rx_digitalreset_in;
	wire  [3:0]  rx_digitalreset_out;
	wire [0:0]  rx_enapatternalign;
	wire  [0:0]  rx_freqlocked_wire;
	wire [0:0]  rx_locktodata;
	wire  [0:0]  rx_locktodata_wire;
	wire [0:0]  rx_locktorefclk;
	wire  [0:0]  rx_locktorefclk_wire;
	wire  [39:0]  rx_out_wire;
	wire  [1599:0]  rx_pcsdprioin_wire;
	wire  [1599:0]  rx_pcsdprioout;
	wire [0:0]  rx_phfifordenable;
	wire [0:0]  rx_phfiforeset;
	wire [0:0]  rx_phfifowrdisable;
	wire  [0:0]  rx_pldcruclk_in;
	wire  [3:0]  rx_pll_clkout;
	wire  [0:0]  rx_pll_pfdrefclkout_wire;
	wire  [0:0]  rx_plllocked_wire;
	wire  [16:0]  rx_pma_analogtestbus;
	wire  [0:0]  rx_pma_clockout;
	wire  [0:0]  rx_pma_dataout;
	wire  [0:0]  rx_pma_locktorefout;
	wire  [19:0]  rx_pma_recoverdataout_wire;
	wire  [1799:0]  rx_pmadprioin_wire;
	wire  [1799:0]  rx_pmadprioout;
	wire [0:0]  rx_powerdown;
	wire  [5:0]  rx_powerdown_in;
	wire [0:0]  rx_prbscidenable;
	wire  [5:0]  rx_rxcruresetout;
	wire  [0:0]  rx_signaldetect_wire;
	wire  [1799:0]  rxpll_dprioin;
	wire  [5:0]  tx_analogreset_out;
	wire  [0:0]  tx_clkout_int_wire;
	wire  [0:0]  tx_core_clkout_wire;
	wire  [0:0]  tx_coreclk_in;
	wire  [39:0]  tx_datain_wire;
	wire  [19:0]  tx_dataout_pcs_to_pma;
	wire  [3:0]  tx_digitalreset_in;
	wire  [3:0]  tx_digitalreset_out;
	wire  [1199:0]  tx_dprioin_wire;
	wire [0:0]  tx_invpolarity;
	wire  [0:0]  tx_localrefclk;
	wire [0:0]  tx_phfiforeset;
	wire  [1799:0]  tx_pmadprioin_wire;
	wire  [1799:0]  tx_pmadprioout;
	wire  [0:0]  tx_serialloopbackout;
	wire  [599:0]  tx_txdprioout;
	wire  [0:0]  txdetectrxout;
	wire  [0:0]  w_cent_unit_dpriodisableout1w;

	stratixiv_hssi_calibration_block   cal_blk0
	( 
	.calibrationstatus(),
	.clk(cal_blk_clk),
	.enabletestbus(1'b1),
	.nonusertocmu(wire_cal_blk0_nonusertocmu),
	.powerdn(cal_blk_powerdown)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.testctrl(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	
generate
if (pll_type == "High speed ATX")
begin
	stratixiv_hssi_calibration_block   pll_cal_blk0
	( 
	.calibrationstatus(),
	.clk(cal_blk_clk),
	.enabletestbus(1'b1),
	.nonusertocmu(wire_pll_cal_blk0_nonusertocmu),
	.powerdn(cal_blk_powerdown)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.testctrl(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	
	stratixiv_hssi_clock_divider #(
		.divide_by (5),
		.divider_type ("ATX_REGULAR"),
		.effective_data_rate ("10312.5 Mbps"),
		.enable_dynamic_divider ("false"),
		.enable_refclk_out ("true"),
		.select_local_rate_switch_base_clock ("true"),
		.select_local_refclk ("true"),
		.use_refclk_post_divider ("false"),
		.use_vco_bypass ("false"),
		.lpm_type ("stratixiv_hssi_clock_divider")
	)   atx_clk_div0 ( 
	.analogfastrefclkout(wire_atx_clk_div0_analogfastrefclkout),
	.analogfastrefclkoutshifted(),
	.analogrefclkout(wire_atx_clk_div0_analogrefclkout),
	.analogrefclkoutshifted(),
	.analogrefclkpulse(wire_atx_clk_div0_analogrefclkpulse),
	.analogrefclkpulseshifted(),
	.clk0in(clock_divider_clk0in[3:0]),
	.coreclkout(),
	.dpriodisable(1'b1),
	.dprioout(),
	.powerdn(edge_cmu_clkdivpowerdn[0]),
	.quadreset(edge_cmu_quadresetout[0]),
	.rateswitchbaseclock(),
	.rateswitchdone(),
	.rateswitchout(),
	.refclkout(wire_atx_clk_div0_refclkout)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1in({4{1'b0}}),
	.dprioin({100{1'b0}}),
	.rateswitch(1'b0),
	.rateswitchbaseclkin({2{1'b0}}),
	.rateswitchdonein({2{1'b0}}),
	.refclkdig(1'b0),
	.refclkin({2{1'b0}}),
	.vcobypassin(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
end
endgenerate
	
	stratixiv_hssi_clock_divider #(
		.channel_num (((starting_channel_number + 0) % 4)),
		.divide_by (5),
		.divider_type ("CHANNEL_REGULAR"),
		.effective_data_rate ("10312.5 Mbps"),
		.enable_dynamic_divider ("false"),
		.enable_refclk_out ("false"),
		.inclk_select (0),
		.logical_channel_address ((starting_channel_number + 0)),
		.pre_divide_by (1),
		.select_local_rate_switch_done ("false"),
		.sim_analogfastrefclkout_phase_shift (0),
		.sim_analogrefclkout_phase_shift (0),
		.sim_coreclkout_phase_shift (0),
		.sim_refclkout_phase_shift (0),
		.use_coreclk_out_post_divider ("false"),
		.use_refclk_post_divider ("false"),
		.use_vco_bypass ("false"),
		.lpm_type ("stratixiv_hssi_clock_divider")
	)   ch_clk_div0 ( 
	.analogfastrefclkout(wire_ch_clk_div0_analogfastrefclkout),
	.analogfastrefclkoutshifted(),
	.analogrefclkout(wire_ch_clk_div0_analogrefclkout),
	.analogrefclkoutshifted(),
	.analogrefclkpulse(wire_ch_clk_div0_analogrefclkpulse),
	.analogrefclkpulseshifted(),
	.clk0in((pll_type == "High speed ATX") ? {4{1'b0}} : pll0_out[3:0]),
	.coreclkout(),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(cent_unit_cmudividerdprioout[99:0]),
	.dprioout(wire_ch_clk_div0_dprioout),
	.quadreset(cent_unit_quadresetout[0]),
	.rateswitchbaseclock(),
	.rateswitchdone(),
	.rateswitchout(),
	.refclkout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.clk1in({4{1'b0}}),
	.powerdn(1'b0),
	.rateswitch(1'b0),
	.rateswitchbaseclkin({2{1'b0}}),
	.rateswitchdonein({2{1'b0}}),
	.refclkdig(1'b0),
	.refclkin({2{1'b0}}),
	.vcobypassin(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	
generate
if (pll_type == "High speed ATX")
begin
	stratixiv_hssi_cmu #(
		.cmu_type ("atx"),
		.lpm_type ("stratixiv_hssi_cmu")
	) atx_pll_cent_unit0
	( 
	.alignstatus(),
	.autospdx4configsel(),
	.autospdx4rateswitchout(),
	.autospdx4spdchg(),
	.clkdivpowerdn(wire_atx_pll_cent_unit0_clkdivpowerdn),
	.cmudividerdprioout(),
	.cmuplldprioout(),
	.digitaltestout(),
	.dpriodisableout(),
	.dpriooe(),
	.dprioout(),
	.enabledeskew(),
	.extra10gout(),
	.fiforesetrd(),
	.lccmutestbus(),
	.nonuserfromcal(nonusertocmu_out_pll[0]),
	.phfifiox4ptrsreset(),
	.pllpowerdn(wire_atx_pll_cent_unit0_pllpowerdn),
	.pllresetout(wire_atx_pll_cent_unit0_pllresetout),
	.quadreset(pll_powerdown[0]),
	.quadresetout(wire_atx_pll_cent_unit0_quadresetout),
	.refclkdividerdprioout(),
	.rxadcepowerdown(),
	.rxadceresetout(),
	.rxanalogresetout(),
	.rxcrupowerdown(),
	.rxcruresetout(),
	.rxctrlout(),
	.rxdataout(),
	.rxdigitalresetout(),
	.rxibpowerdown(),
	.rxpcsdprioout(),
	.rxphfifox4byteselout(),
	.rxphfifox4rdenableout(),
	.rxphfifox4wrclkout(),
	.rxphfifox4wrenableout(),
	.rxpmadprioout(),
	.scanout(),
	.testout(),
	.txanalogresetout(),
	.txctrlout(),
	.txdataout(),
	.txdetectrxpowerdown(),
	.txdigitalresetout(),
	.txdividerpowerdown(),
	.txobpowerdown(),
	.txpcsdprioout(),
	.txphfifox4byteselout(),
	.txphfifox4rdclkout(),
	.txphfifox4rdenableout(),
	.txphfifox4wrenableout(),
	.txpllreset({{1{1'b0}}, pll_powerdown[0]}),
	.txpmadprioout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.adet({4{1'b0}}),
	.cmudividerdprioin({600{1'b0}}),
	.cmuplldprioin({1800{1'b0}}),
	.dpclk(1'b0),
	.dpriodisable(1'b1),
	.dprioin(1'b0),
	.dprioload(1'b0),
	.extra10gin({7{1'b0}}),
	.fixedclk({6{1'b0}}),
	.lccmurtestbussel({3{1'b0}}),
	.pmacramtest(1'b0),
	.rateswitch(1'b0),
	.rateswitchdonein(1'b0),
	.rdalign({4{1'b0}}),
	.rdenablesync(1'b1),
	.recovclk(1'b0),
	.refclkdividerdprioin({2{1'b0}}),
	.rxanalogreset({6{1'b0}}),
	.rxclk(1'b0),
	.rxcoreclk(1'b0),
	.rxctrl({4{1'b0}}),
	.rxdatain({32{1'b0}}),
	.rxdatavalid({4{1'b0}}),
	.rxdigitalreset({4{1'b0}}),
	.rxpcsdprioin({1600{1'b0}}),
	.rxphfifordenable(1'b1),
	.rxphfiforeset(1'b0),
	.rxphfifowrdisable(1'b0),
	.rxpmadprioin({1800{1'b0}}),
	.rxpowerdown({6{1'b0}}),
	.rxrunningdisp({4{1'b0}}),
	.scanclk(1'b0),
	.scanin({23{1'b0}}),
	.scanmode(1'b0),
	.scanshift(1'b0),
	.syncstatus({4{1'b0}}),
	.testin({10000{1'b0}}),
	.txclk(1'b0),
	.txcoreclk(1'b0),
	.txctrl({4{1'b0}}),
	.txdatain({32{1'b0}}),
	.txdigitalreset({4{1'b0}}),
	.txpcsdprioin({600{1'b0}}),
	.txphfiforddisable(1'b0),
	.txphfiforeset(1'b0),
	.txphfifowrenable(1'b0),
	.txpmadprioin({1800{1'b0}})
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
end
endgenerate
	
	stratixiv_hssi_cmu #(
		.auto_spd_deassert_ph_fifo_rst_count (8),
		.auto_spd_phystatus_notify_count (14),
		.bonded_quad_mode ("none"),
		.devaddr (((((starting_channel_number / 4) + 0) % 32) + 1)),
		.in_xaui_mode ("false"),
		.offset_all_errors_align ("false"),
		.pipe_auto_speed_nego_enable ("false"),
		.pipe_freq_scale_mode ("Frequency"),
		.pma_done_count (249950),
		.portaddr ((((starting_channel_number + 0) / 128) + 1)),
		.rx0_auto_spd_self_switch_enable ("false"),
		.rx0_channel_bonding ("none"),
		.rx0_clk1_mux_select ("recovered clock"),
		.rx0_clk2_mux_select ("recovered clock"),
		.rx0_ph_fifo_reg_mode ("false"),
		.rx0_rd_clk_mux_select ("core clock"),
		.rx0_recovered_clk_mux_select ("recovered clock"),
		.rx0_reset_clock_output_during_digital_reset ("false"),
		.rx0_use_double_data_mode ("true"),
		.tx0_auto_spd_self_switch_enable ("false"),
		.tx0_channel_bonding ("none"),
		.tx0_ph_fifo_reg_mode ("false"),
		.tx0_rd_clk_mux_select ("cmu_clock_divider"),
		.tx0_use_double_data_mode ("true"),
		.tx0_wr_clk_mux_select ("core_clk"),
		.use_deskew_fifo ("false"),
		.vcceh_voltage ("Auto"),
		.lpm_type ("stratixiv_hssi_cmu")
	)  cent_unit0
	( 
	.adet({4{1'b0}}),
	.alignstatus(),
	.autospdx4configsel(),
	.autospdx4rateswitchout(),
	.autospdx4spdchg(),
	.clkdivpowerdn(),
	.cmudividerdprioin((pll_type == "High speed ATX") ? {600{1'b0}} : {clk_div_cmudividerdprioin[599:0]}),
	.cmudividerdprioout(wire_cent_unit0_cmudividerdprioout),
	.cmuplldprioin(pll_cmuplldprioout[1799:0]),
	.cmuplldprioout(wire_cent_unit0_cmuplldprioout),
	.digitaltestout(),
	.dpclk(reconfig_clk),
	.dpriodisable(reconfig_togxb_disable),
	.dpriodisableout(wire_cent_unit0_dpriodisableout),
	.dprioin(reconfig_togxb_in),
	.dprioload(reconfig_togxb_load),
	.dpriooe(),
	.dprioout(wire_cent_unit0_dprioout),
	.enabledeskew(),
	.extra10gout(),
	.fiforesetrd(),
	.fixedclk({{5{1'b0}}, fixedclk_to_cmu[0]}),
	.lccmutestbus(),
	.nonuserfromcal(nonusertocmu_out[0]),
	.phfifiox4ptrsreset(),
	.pllpowerdn(wire_cent_unit0_pllpowerdn),
	.pllresetout(wire_cent_unit0_pllresetout),
	.quadreset(gxb_powerdown[0]),
	.quadresetout(wire_cent_unit0_quadresetout),
	.rdalign({4{1'b0}}),
	.rdenablesync(1'b0),
	.recovclk(1'b0),
	.refclkdividerdprioin({2{1'b0}}),
	.refclkdividerdprioout(),
	.rxadcepowerdown(),
	.rxadceresetout(),
	.rxanalogreset({{2{1'b0}}, rx_analogreset_in[3:0]}),
	.rxanalogresetout(wire_cent_unit0_rxanalogresetout),
	.rxcrupowerdown(wire_cent_unit0_rxcrupowerdown),
	.rxcruresetout(wire_cent_unit0_rxcruresetout),
	.rxctrl({4{1'b0}}),
	.rxctrlout(),
	.rxdatain({32{1'b0}}),
	.rxdataout(),
	.rxdatavalid({4{1'b0}}),
	.rxdigitalreset({rx_digitalreset_in[3:0]}),
	.rxdigitalresetout(wire_cent_unit0_rxdigitalresetout),
	.rxibpowerdown(wire_cent_unit0_rxibpowerdown),
	.rxpcsdprioin({cent_unit_rxpcsdprioin[1599:0]}),
	.rxpcsdprioout(wire_cent_unit0_rxpcsdprioout),
	.rxphfifox4byteselout(),
	.rxphfifox4rdenableout(),
	.rxphfifox4wrclkout(),
	.rxphfifox4wrenableout(),
	.rxpmadprioin({cent_unit_rxpmadprioin[1799:0]}),
	.rxpmadprioout(wire_cent_unit0_rxpmadprioout),
	.rxpowerdown({{2{1'b0}}, rx_powerdown_in[3:0]}),
	.rxrunningdisp({4{1'b0}}),
	.scanout(),
	.syncstatus({4{1'b0}}),
	.testout(),
	.txanalogresetout(wire_cent_unit0_txanalogresetout),
	.txctrl({4{1'b0}}),
	.txctrlout(wire_cent_unit0_txctrlout),
	.txdatain({32{1'b0}}),
	.txdataout(wire_cent_unit0_txdataout),
	.txdetectrxpowerdown(wire_cent_unit0_txdetectrxpowerdown),
	.txdigitalreset({tx_digitalreset_in[3:0]}),
	.txdigitalresetout(wire_cent_unit0_txdigitalresetout),
	.txdividerpowerdown(),
	.txobpowerdown(wire_cent_unit0_txobpowerdown),
	.txpcsdprioin({cent_unit_tx_dprioin[599:0]}),
	.txpcsdprioout(wire_cent_unit0_txpcsdprioout),
	.txphfifox4byteselout(),
	.txphfifox4rdclkout(),
	.txphfifox4rdenableout(),
	.txphfifox4wrenableout(),
	.txpllreset((pll_type == "High speed ATX") ? {2{1'b0}} : {{1{1'b0}}, pll_powerdown[0]}),
	.txpmadprioin({cent_unit_txpmadprioin[1799:0]}),
	.txpmadprioout(wire_cent_unit0_txpmadprioout)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.extra10gin({7{1'b0}}),
	.lccmurtestbussel({3{1'b0}}),
	.pmacramtest(1'b0),
	.rateswitch(1'b0),
	.rateswitchdonein(1'b0),
	.rxclk(1'b0),
	.rxcoreclk(1'b0),
	.rxphfifordenable(1'b1),
	.rxphfiforeset(1'b0),
	.rxphfifowrdisable(1'b0),
	.scanclk(1'b0),
	.scanin({23{1'b0}}),
	.scanmode(1'b0),
	.scanshift(1'b0),
	.testin({10000{1'b0}}),
	.txclk(1'b0),
	.txcoreclk(1'b0),
	.txphfiforddisable(1'b0),
	.txphfiforeset(1'b0),
	.txphfifowrenable(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);


	stratixiv_hssi_pll #(
		.bandwidth_type ("Auto"),
		.channel_num (((starting_channel_number + 0) % 4)),
		.dprio_config_mode (6'h00),
		.effective_data_rate ("10312.5 Mbps"),
		.enable_dynamic_divider ("false"),
		.fast_lock_control ("false"),
		.inclk0_input_period (1552),
		.input_clock_frequency ("644.53125 MHz"),
		.m (16),
		.n (2),
		.pfd_clk_select (0),
		.pll_type ("RX CDR"),
		.use_refclk_pin ("false"),
		.vco_post_scale (1),
		.lpm_type ("stratixiv_hssi_pll")
	)   rx_cdr_pll0
	( 
	.areset(rx_rxcruresetout[0]),
	.clk(wire_rx_cdr_pll0_clk),
	.datain(rx_pma_dataout[0]),
	.dataout(wire_rx_cdr_pll0_dataout),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(rxpll_dprioin[299:0]),
	.dprioout(wire_rx_cdr_pll0_dprioout),
	.freqlocked(wire_rx_cdr_pll0_freqlocked),
	.inclk({rx_cruclk_in[9:0]}),
	.locked(wire_rx_cdr_pll0_locked),
	.locktorefclk(rx_pma_locktorefout[0]),
	.pfdfbclkout(),
	.pfdrefclkout(wire_rx_cdr_pll0_pfdrefclkout),
	.powerdown(cent_unit_rxcrupowerdn[0]),
	.vcobypassout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.earlyeios(1'b0),
	.extra10gin({6{1'b0}}),
	.pfdfbclk(1'b0),
	.rateswitch(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);

generate
if (pll_type == "High speed ATX")
begin
stratixiv_hssi_pll #(
		.bandwidth_type ("Auto"),
		.channel_num (0),
		.inclk0_input_period (1552),
		.input_clock_frequency ("644.53125 MHz"),
		.logical_tx_pll_number (2),
		.m (16),
		.n (2),
		.pll_type ("High speed ATX"),
		.vco_post_scale (1),
		.lpm_type ("stratixiv_hssi_pll")
	)  atx_pll0( 
	.areset(edge_pllreset_in[0]),
	.clk(wire_atx_pll0_clk),
	.dataout(),
	.dprioout(),
	.freqlocked(),
	.inclk({edge_pll_clkin[9:0]}),
	.locked(wire_atx_pll0_locked),
	.pfdfbclkout(),
	.pfdrefclkout(),
	.powerdown(edge_pllpowerdn_in[0]),
	.vcobypassout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.datain(1'b0),
	.dpriodisable(1'b0),
	.dprioin({300{1'b0}}),
	.earlyeios(1'b0),
	.extra10gin({6{1'b0}}),
	.locktorefclk(1'b1),
	.pfdfbclk(1'b0),
	.rateswitch(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
end
else
begin
	stratixiv_hssi_pll #(
		.bandwidth_type ("Auto"),
		.channel_num (4),
		.dprio_config_mode (6'h00),
		.inclk0_input_period (1552),
		.input_clock_frequency ("644.53125 MHz"),
		.logical_tx_pll_number (0),
		.m (16),
		.n (2),
		.pfd_clk_select (0),
		.pfd_fb_select ("internal"),
		.pll_type ("CMU"),
		.use_refclk_pin ("false"),
		.vco_post_scale (1),
		.lpm_type ("stratixiv_hssi_pll")
	)   tx_pll0( 
	.areset(pllreset_in[0]),
	.clk(wire_tx_pll0_clk),
	.dataout(),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(pll0_dprioin[299:0]),
	.dprioout(wire_tx_pll0_dprioout),
	.freqlocked(),
	.inclk({pll0_clkin[9:0]}),
	.locked(wire_tx_pll0_locked),
	.pfdfbclkout(),
	.pfdrefclkout(),
	.powerdown(pllpowerdn_in[0]),
	.vcobypassout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.datain(1'b0),
	.earlyeios(1'b0),
	.extra10gin({6{1'b0}}),
	.locktorefclk(1'b1),
	.pfdfbclk(1'b0),
	.rateswitch(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
end
endgenerate


	stratixiv_hssi_rx_pcs #(
		.align_pattern ("0000000000"),
		.align_pattern_length (10),
		.align_to_deskew_pattern_pos_disp_only ("false"),
		.allow_align_polarity_inversion ("false"),
		.allow_pipe_polarity_inversion ("false"),
		.auto_spd_deassert_ph_fifo_rst_count (8),
		.auto_spd_phystatus_notify_count (14),
		.auto_spd_self_switch_enable ("false"),
		.bit_slip_enable ("true"),
		.byte_order_mode ("none"),
		.byte_order_pad_pattern ("0"),
		.byte_order_pattern ("0"),
		.byte_order_pld_ctrl_enable ("false"),
		.cdrctrl_bypass_ppm_detector_cycle (1000),
		.cdrctrl_enable ("false"),
		.cdrctrl_rxvalid_mask ("false"),
		.channel_bonding ("none"),
		.channel_number (((starting_channel_number + 0) % 4)),
		.channel_width (40),
		.clk1_mux_select ("recovered clock"),
		.clk2_mux_select ("recovered clock"),
		.core_clock_0ppm ("false"),
		.datapath_low_latency_mode ("true"),
		.datapath_protocol ("basic"),
		.dec_8b_10b_compatibility_mode ("true"),
		.dec_8b_10b_mode ("none"),
		.dec_8b_10b_polarity_inv_enable ("false"),
		.deskew_pattern ("0"),
		.disable_auto_idle_insertion ("true"),
		.disable_running_disp_in_word_align ("false"),
		.disallow_kchar_after_pattern_ordered_set ("false"),
		.dprio_config_mode (6'h01),
		.elec_idle_infer_enable ("false"),
		.elec_idle_num_com_detect (0),
		.enable_bit_reversal ("false"),
		.enable_deep_align ("true"),
		.enable_deep_align_byte_swap ("false"),
		.enable_self_test_mode ("false"),
		.enable_true_complement_match_in_word_align ("true"),
		.force_signal_detect_dig ("true"),
		.hip_enable ("false"),
		.infiniband_invalid_code (0),
		.insert_pad_on_underflow ("false"),
		.logical_channel_address ((starting_channel_number + 0)),
		.num_align_code_groups_in_ordered_set (0),
		.num_align_cons_good_data (1),
		.num_align_cons_pat (1),
		.num_align_loss_sync_error (1),
		.ph_fifo_low_latency_enable ("true"),
		.ph_fifo_reg_mode ("false"),
		.ph_fifo_xn_mapping0 ("none"),
		.ph_fifo_xn_mapping1 ("none"),
		.ph_fifo_xn_mapping2 ("none"),
		.ph_fifo_xn_select (1),
		.pipe_auto_speed_nego_enable ("false"),
		.pipe_freq_scale_mode ("Frequency"),
		.pma_done_count (249950),
		.protocol_hint ("basic"),
		.rate_match_almost_empty_threshold (11),
		.rate_match_almost_full_threshold (13),
		.rate_match_back_to_back ("true"),
		.rate_match_delete_threshold (13),
		.rate_match_empty_threshold (5),
		.rate_match_fifo_mode ("false"),
		.rate_match_full_threshold (20),
		.rate_match_insert_threshold (11),
		.rate_match_ordered_set_based ("false"),
		.rate_match_pattern1 ("0"),
		.rate_match_pattern2 ("0"),
		.rate_match_pattern_size (10),
		.rate_match_reset_enable ("false"),
		.rate_match_skip_set_based ("false"),
		.rate_match_start_threshold (7),
		.rd_clk_mux_select ("core clock"),
		.recovered_clk_mux_select ("recovered clock"),
		.run_length (40),
		.run_length_enable ("true"),
		.rx_detect_bypass ("false"),
		.rx_phfifo_wait_cnt (0),
		.rxstatus_error_report_mode (1),
		.self_test_mode ("incremental"),
		.use_alignment_state_machine ("true"),
		.use_deserializer_double_data_mode ("true"),
		.use_deskew_fifo ("false"),
		.use_double_data_mode ("true"),
		.use_parallel_loopback ("false"),
		.use_rising_edge_triggered_pattern_align ("true"),
		.lpm_type ("stratixiv_hssi_rx_pcs")
	)   receive_pcs0( 
	.a1a2size(1'b0),
	.a1a2sizeout(),
	.a1detect(),
	.a2detect(),
	.adetectdeskew(),
	.alignstatus(1'b0),
	.alignstatussync(1'b0),
	.alignstatussyncout(),
	.autospdrateswitchout(),
	.autospdspdchgout(),
	.bistdone(),
	.bisterr(),
	.bitslipboundaryselectout(),
	.byteorderalignstatus(),
	.cdrctrlearlyeios(),
	.cdrctrllocktorefcl((reconfig_togxb_busy | rx_locktorefclk[0])),
	.cdrctrllocktorefclkout(wire_receive_pcs0_cdrctrllocktorefclkout),
	.clkout(wire_receive_pcs0_clkout),
	.coreclk(rx_coreclk_in[0]),
	.coreclkout(),
	.ctrldetect(),
	.datain(rx_pma_recoverdataout_wire[19:0]),
	.dataout(wire_receive_pcs0_dataout),
	.dataoutfull(),
	.digitalreset(rx_digitalreset_out[0]),
	.digitaltestout(),
	.disablefifordin(1'b0),
	.disablefifordout(),
	.disablefifowrin(1'b0),
	.disablefifowrout(),
	.disperr(),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(rx_pcsdprioin_wire[399:0]),
	.dprioout(wire_receive_pcs0_dprioout),
	.enabledeskew(1'b0),
	.enabyteord(1'b0),
	.enapatternalign(rx_enapatternalign[0]),
	.errdetect(),
	.fifordin(1'b0),
	.fifordout(),
	.fiforesetrd(1'b0),
	.hipdataout(),
	.hipdatavalid(),
	.hipelecidle(),
	.hipphydonestatus(),
	.hipstatus(),
	.invpol(1'b0),
	.iqpphfifobyteselout(),
	.iqpphfifoptrsresetout(),
	.iqpphfifordenableout(),
	.iqpphfifowrclkout(),
	.iqpphfifowrenableout(),
	.k1detect(),
	.k2detect(),
	.localrefclk(1'b0),
	.masterclk(1'b0),
	.parallelfdbk({20{1'b0}}),
	.patterndetect(),
	.phfifobyteselout(),
	.phfifobyteserdisableout(),
	.phfifooverflow(),
	.phfifoptrsresetout(),
	.phfifordenable(rx_phfifordenable[0]),
	.phfifordenableout(),
	.phfiforeset(rx_phfiforeset[0]),
	.phfiforesetout(),
	.phfifounderflow(),
	.phfifowrclkout(),
	.phfifowrdisable(rx_phfifowrdisable[0]),
	.phfifowrdisableout(),
	.phfifowrenableout(),
	.pipebufferstat(),
	.pipedatavalid(),
	.pipeelecidle(),
	.pipephydonestatus(),
	.pipepowerdown({2{1'b0}}),
	.pipepowerstate({4{1'b0}}),
	.pipestatetransdoneout(),
	.pipestatus(),
	.prbscidenable(rx_prbscidenable[0]),
	.quadreset(cent_unit_quadresetout[0]),
	.rateswitchout(),
	.rdalign(),
	.recoveredclk(rx_pma_clockout[0]),
	.revbitorderwa(1'b0),
	.revbyteorderwa(1'b0),
	.revparallelfdbkdata(),
	.rlv(),
	.rmfifoalmostempty(),
	.rmfifoalmostfull(),
	.rmfifodatadeleted(),
	.rmfifodatainserted(),
	.rmfifoempty(),
	.rmfifofull(),
	.rmfifordena(1'b0),
	.rmfiforeset(1'b0),
	.rmfifowrena(1'b0),
	.runningdisp(),
	.rxdetectvalid(1'b0),
	.rxfound({2{1'b0}}),
	.signaldetect(wire_receive_pcs0_signaldetect),
	.signaldetected(rx_signaldetect_wire[0]),
	.syncstatus(),
	.syncstatusdeskew(),
	.xauidelcondmetout(),
	.xauififoovrout(),
	.xauiinsertincompleteout(),
	.xauilatencycompout(),
	.xgmctrldet(),
	.xgmctrlin(1'b0),
	.xgmdatain({8{1'b0}}),
	.xgmdataout(),
	.xgmdatavalid(),
	.xgmrunningdisp()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.autospdxnconfigsel({3{1'b0}}),
	.autospdxnspdchg({3{1'b0}}),
	.bitslip(1'b0),
	.elecidleinfersel({3{1'b0}}),
	.grayelecidleinferselfromtx({3{1'b0}}),
	.hip8b10binvpolarity(1'b0),
	.hipelecidleinfersel({3{1'b0}}),
	.hippowerdown({2{1'b0}}),
	.hiprateswitch(1'b0),
	.iqpautospdxnspgchg({2{1'b0}}),
	.iqpphfifoxnbytesel({2{1'b0}}),
	.iqpphfifoxnptrsreset({2{1'b0}}),
	.iqpphfifoxnrdenable({2{1'b0}}),
	.iqpphfifoxnwrclk({2{1'b0}}),
	.iqpphfifoxnwrenable({2{1'b0}}),
	.phfifox4bytesel(1'b0),
	.phfifox4rdenable(1'b0),
	.phfifox4wrclk(1'b0),
	.phfifox4wrenable(1'b0),
	.phfifox8bytesel(1'b0),
	.phfifox8rdenable(1'b0),
	.phfifox8wrclk(1'b0),
	.phfifox8wrenable(1'b0),
	.phfifoxnbytesel({3{1'b0}}),
	.phfifoxnptrsreset({3{1'b0}}),
	.phfifoxnrdenable({3{1'b0}}),
	.phfifoxnwrclk({3{1'b0}}),
	.phfifoxnwrenable({3{1'b0}}),
	.pipe8b10binvpolarity(1'b0),
	.pipeenrevparallellpbkfromtx(1'b0),
	.pmatestbusin({8{1'b0}}),
	.powerdn({2{1'b0}}),
	.ppmdetectdividedclk(1'b0),
	.ppmdetectrefclk(1'b0),
	.rateswitch(1'b0),
	.rateswitchisdone(1'b0),
	.rateswitchxndone(1'b0),
	.refclk(1'b0),
	.rxelecidlerateswitch(1'b0),
	.wareset(1'b0),
	.xauidelcondmet(1'b0),
	.xauififoovr(1'b0),
	.xauiinsertincomplete(1'b0),
	.xauilatencycomp(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);


	stratixiv_hssi_rx_pma #(
			.adaptive_equalization_mode ("none"),
		.allow_serial_loopback ("true"),
		.channel_number (((starting_channel_number + 0) % 4)),
		.channel_type ("gt"),
		.common_mode (rx_common_mode),
		.deserialization_factor (20),
		.dprio_config_mode (6'h01),
		.enable_ltd ("false"),
		.enable_ltr ("false"),
		.eq_dc_gain (equalizer_dcgain_setting),
		.eqa_ctrl (equalizer_ctrl_a_setting),
		.eqb_ctrl (equalizer_ctrl_b_setting),
		.eqc_ctrl (equalizer_ctrl_c_setting),
		.eqd_ctrl (equalizer_ctrl_d_setting),
		.eqv_ctrl (equalizer_ctrl_v_setting),
		.eyemon_bandwidth (0),
		.force_signal_detect ("true"),
		.logical_channel_address ((starting_channel_number + 0)),
		.low_speed_test_select (0),
		.offset_cancellation (1),
		.ppmselect (rx_ppmselect),
		.protocol_hint ("basic"),
		.send_direct_reverse_serial_loopback ("None"),
		.signal_detect_hysteresis (2),
		.signal_detect_hysteresis_valid_threshold (1),
		.signal_detect_loss_threshold (1),
		.termination (receiver_termination),
		.use_deser_double_data_width ("true"),
		.use_external_termination ("false"),
		.use_pma_direct ("false"),
		.lpm_type ("stratixiv_hssi_rx_pma")
		)  receive_pma0	( 
	.adaptdone(),
	.analogtestbus(wire_receive_pma0_analogtestbus),
	.clockout(wire_receive_pma0_clockout),
	.datain(rx_datain[0]),
	.dataout(wire_receive_pma0_dataout),
	.dataoutfull(),
	.deserclock(rx_deserclock_in[3:0]),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(rx_pmadprioin_wire[299:0]),
	.dprioout(wire_receive_pma0_dprioout),
	.freqlock(1'b0),
	.ignorephslck(1'b0),
	.locktodata(rx_locktodata_wire[0]),
	.locktoref(rx_locktorefclk_wire[0]),
	.locktorefout(wire_receive_pma0_locktorefout),
	.offsetcancellationen(1'b0),
	.plllocked(rx_plllocked_wire[0]),
	.powerdn(cent_unit_rxibpowerdn[0]),
	.ppmdetectclkrel(),
	.ppmdetectrefclk(rx_pll_pfdrefclkout_wire[0]),
	.recoverdatain(pll_ch_dataout_wire[1:0]),
	.recoverdataout(wire_receive_pma0_recoverdataout),
	.reverselpbkout(),
	.revserialfdbkout(),
	.rxpmareset(rx_analogreset_out[0]),
	.seriallpbken(rx_seriallpbken[0]),
	.seriallpbkin(tx_serialloopbackout[0]),
	.signaldetect(wire_receive_pma0_signaldetect),
	.testbussel(4'b0110)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.adaptcapture(1'b0),
	.adcepowerdn(1'b0),
	.adcereset(1'b0),
	.adcestandby(1'b0),
	.extra10gin({38{1'b0}}),
	.ppmdetectdividedclk(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);



	stratixiv_hssi_tx_pcs #(
			.allow_polarity_inversion ("false"),
		.auto_spd_self_switch_enable ("false"),
		.bitslip_enable ("false"),
		.channel_bonding ("none"),
		.channel_number (((starting_channel_number + 0) % 4)),
		.channel_width (40),
		.core_clock_0ppm ("false"),
		.datapath_low_latency_mode ("true"),
		.datapath_protocol ("basic"),
		.disable_ph_low_latency_mode ("false"),
		.disparity_mode ("none"),
		.dprio_config_mode (6'h01),
		.elec_idle_delay (3),
		.enable_bit_reversal ("false"),
		.enable_idle_selection ("false"),
		.enable_reverse_parallel_loopback ("false"),
		.enable_self_test_mode ("false"),
		.enable_symbol_swap ("false"),
		.enc_8b_10b_compatibility_mode ("true"),
		.enc_8b_10b_mode ("none"),
		.force_echar ("false"),
		.force_kchar ("false"),
		.hip_enable ("false"),
		.logical_channel_address ((starting_channel_number + 0)),
		.ph_fifo_reg_mode ("false"),
		.ph_fifo_xn_mapping0 ("none"),
		.ph_fifo_xn_mapping1 ("none"),
		.ph_fifo_xn_mapping2 ("none"),
		.ph_fifo_xn_select (1),
		.pipe_auto_speed_nego_enable ("false"),
		.pipe_freq_scale_mode ("Frequency"),
		.prbs_cid_pattern ("false"),
		.protocol_hint ("basic"),
		.refclk_select ("local"),
		.self_test_mode ("incremental"),
		.use_double_data_mode ("true"),
		.use_serializer_double_data_mode ("true"),
		.wr_clk_mux_select ("core_clk"),
		.lpm_type ("stratixiv_hssi_tx_pcs")
		)  transmit_pcs0( 
	.clkout(wire_transmit_pcs0_clkout),
	.coreclk(tx_coreclk_in[0]),
	.coreclkout(),
	.ctrlenable({{4{1'b0}}}),
	.datain({tx_datain_wire[39:0]}),
	.datainfull({44{1'b0}}),
	.dataout(wire_transmit_pcs0_dataout),
	.detectrxloop(1'b0),
	.digitalreset(tx_digitalreset_out[0]),
	.dispval({{4{1'b0}}}),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(tx_dprioin_wire[149:0]),
	.dprioout(wire_transmit_pcs0_dprioout),
	.enrevparallellpbk(1'b0),
	.forcedisp({{4{1'b0}}}),
	.forcedispcompliance(1'b0),
	.forceelecidleout(wire_transmit_pcs0_forceelecidleout),
	.grayelecidleinferselout(),
	.hiptxclkout(),
	.invpol(tx_invpolarity[0]),
	.iqpphfifobyteselout(),
	.iqpphfifordclkout(),
	.iqpphfifordenableout(),
	.iqpphfifowrenableout(),
	.localrefclk(tx_localrefclk[0]),
	.parallelfdbkout(),
	.phfifobyteselout(),
	.phfifooverflow(),
	.phfifordclkout(),
	.phfiforddisable(1'b0),
	.phfiforddisableout(),
	.phfifordenableout(),
	.phfiforeset(tx_phfiforeset[0]),
	.phfiforesetout(),
	.phfifounderflow(),
	.phfifowrenable(1'b1),
	.phfifowrenableout(),
	.pipeenrevparallellpbkout(),
	.pipepowerdownout(),
	.pipepowerstateout(),
	.pipestatetransdone(1'b0),
	.powerdn({2{1'b0}}),
	.quadreset(cent_unit_quadresetout[0]),
	.rateswitchout(),
	.rdenablesync(),
	.revparallelfdbk({20{1'b0}}),
	.txdetectrx(wire_transmit_pcs0_txdetectrx),
	.xgmctrl(cent_unit_txctrlout[0]),
	.xgmctrlenable(),
	.xgmdatain(cent_unit_tx_xgmdataout[7:0]),
	.xgmdataout()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.bitslipboundaryselect({5{1'b0}}),
	.elecidleinfersel({3{1'b0}}),
	.forceelecidle(1'b0),
	.freezptr(1'b0),
	.hipdatain({10{1'b0}}),
	.hipdetectrxloop(1'b0),
	.hipelecidleinfersel({3{1'b0}}),
	.hipforceelecidle(1'b0),
	.hippowerdn({2{1'b0}}),
	.hiptxdeemph(1'b0),
	.hiptxmargin({3{1'b0}}),
	.iqpphfifoxnbytesel({2{1'b0}}),
	.iqpphfifoxnrdclk({2{1'b0}}),
	.iqpphfifoxnrdenable({2{1'b0}}),
	.iqpphfifoxnwrenable({2{1'b0}}),
	.phfifobyteserdisable(1'b0),
	.phfifoptrsreset(1'b0),
	.phfifox4bytesel(1'b0),
	.phfifox4rdclk(1'b0),
	.phfifox4rdenable(1'b0),
	.phfifox4wrenable(1'b0),
	.phfifoxnbottombytesel(1'b0),
	.phfifoxnbottomrdclk(1'b0),
	.phfifoxnbottomrdenable(1'b0),
	.phfifoxnbottomwrenable(1'b0),
	.phfifoxnbytesel({3{1'b0}}),
	.phfifoxnptrsreset({3{1'b0}}),
	.phfifoxnrdclk({3{1'b0}}),
	.phfifoxnrdenable({3{1'b0}}),
	.phfifoxntopbytesel(1'b0),
	.phfifoxntoprdclk(1'b0),
	.phfifoxntoprdenable(1'b0),
	.phfifoxntopwrenable(1'b0),
	.phfifoxnwrenable({3{1'b0}}),
	.pipetxdeemph(1'b0),
	.pipetxmargin({3{1'b0}}),
	.pipetxswing(1'b0),
	.prbscidenable(1'b0),
	.rateswitch(1'b0),
	.rateswitchisdone(1'b0),
	.rateswitchxndone(1'b0),
	.refclk(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);

	stratixiv_hssi_tx_pma #(
			.analog_power ("auto"),
		.channel_number (((starting_channel_number + 0) % 4)),
		.channel_type ("gt"),
		.clkin_select (0),
		.clkmux_delay ("false"),
		.common_mode ("0.65V"),
		.dprio_config_mode (6'h01),
		.enable_reverse_serial_loopback ("false"),
		.logical_channel_address ((starting_channel_number + 0)),
		.logical_protocol_hint_0 ("basic"),
		.low_speed_test_select (0),
		.physical_clkin0_mapping ("x1"),
		.preemp_pretap (preemphasis_ctrl_pretap_setting),
		.preemp_pretap_inv (preemphasis_ctrl_pretap_inv_setting),
		.preemp_tap_1 (preemphasis_ctrl_1stposttap_setting),
		.preemp_tap_2 (preemphasis_ctrl_2ndposttap_setting),
		.preemp_tap_2_inv (preemphasis_ctrl_2ndposttap_inv_setting),
		.protocol_hint ("basic"),
		.rx_detect (0),
		.serialization_factor (20),
		.slew_rate ("off"),
		.termination (transmitter_termination),
		.use_external_termination ("false"),
		.use_pma_direct ("false"),
		.use_ser_double_data_mode ("true"),
		.vod_selection (vod_ctrl_setting),
		.lpm_type ("stratixiv_hssi_tx_pma")
		) transmit_pma0	( 
	.clockout(wire_transmit_pma0_clockout),
	.datain({{44{1'b0}}, tx_dataout_pcs_to_pma[19:0]}),
	.dataout(wire_transmit_pma0_dataout),
	.detectrxpowerdown(cent_unit_txdetectrxpowerdn[0]),
	.dftout(),
	.dpriodisable(w_cent_unit_dpriodisableout1w[0]),
	.dprioin(tx_pmadprioin_wire[299:0]),
	.dprioout(wire_transmit_pma0_dprioout),
	.fastrefclk0in((pll_type == "High speed ATX") ? edge_pll_analogfastrefclkout[1:0] : analogfastrefclkout[1:0]),
	.fastrefclk1in({2{1'b0}}),
	.fastrefclk2in({2{1'b0}}),
	.fastrefclk4in({2{1'b0}}),
	.forceelecidle(1'b0),
	.powerdn(cent_unit_txobpowerdn[0]),
	.refclk0in((pll_type == "High speed ATX") ? {edge_pll_analogrefclkout[1:0]} : {analogrefclkout[1:0]}),
	.refclk0inpulse((pll_type == "High speed ATX") ? {edge_pll_analogrefclkpulse[0]} : analogrefclkpulse[0]),
	.refclk1in({2{1'b0}}),
	.refclk1inpulse(1'b0),
	.refclk2in({2{1'b0}}),
	.refclk2inpulse(1'b0),
	.refclk4in({2{1'b0}}),
	.refclk4inpulse(1'b0),
	.revserialfdbk(1'b0),
	.rxdetecten(txdetectrxout[0]),
	.rxdetectvalidout(),
	.rxfoundout(),
	.seriallpbkout(wire_transmit_pma0_seriallpbkout),
	.txpmareset(tx_analogreset_out[0])
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.datainfull({20{1'b0}}),
	.extra10gin({11{1'b0}}),
	.fastrefclk3in({2{1'b0}}),
	.pclk({5{1'b0}}),
	.refclk3in({2{1'b0}}),
	.refclk3inpulse(1'b0),
	.rxdetectclk(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	assign
		analogfastrefclkout = {wire_ch_clk_div0_analogfastrefclkout},
		analogrefclkout = {wire_ch_clk_div0_analogrefclkout},
		analogrefclkpulse = {wire_ch_clk_div0_analogrefclkpulse},
		cent_unit_cmudividerdprioout = {wire_cent_unit0_cmudividerdprioout},
		cent_unit_cmuplldprioout = {wire_cent_unit0_cmuplldprioout},
		cent_unit_pllpowerdn = {wire_cent_unit0_pllpowerdn[1:0]},
		cent_unit_pllresetout = {wire_cent_unit0_pllresetout[1:0]},
		cent_unit_quadresetout = {wire_cent_unit0_quadresetout},
		cent_unit_rxcrupowerdn = {wire_cent_unit0_rxcrupowerdown[5:0]},
		cent_unit_rxibpowerdn = {wire_cent_unit0_rxibpowerdown[5:0]},
		cent_unit_rxpcsdprioin = {{1200{1'b0}}, rx_pcsdprioout[399:0]},
		cent_unit_rxpcsdprioout = {wire_cent_unit0_rxpcsdprioout[1599:0]},
		cent_unit_rxpmadprioin = {{1500{1'b0}}, rx_pmadprioout[299:0]},
		cent_unit_rxpmadprioout = {wire_cent_unit0_rxpmadprioout[1799:0]},
		cent_unit_tx_dprioin = {{1050{1'b0}}, tx_txdprioout[149:0]},
		cent_unit_tx_xgmdataout = {wire_cent_unit0_txdataout[31:0]},
		cent_unit_txctrlout = {wire_cent_unit0_txctrlout},
		cent_unit_txdetectrxpowerdn = {wire_cent_unit0_txdetectrxpowerdown[5:0]},
		cent_unit_txdprioout = {wire_cent_unit0_txpcsdprioout[599:0]},
		cent_unit_txobpowerdn = {wire_cent_unit0_txobpowerdown[5:0]},
		cent_unit_txpmadprioin = {{1500{1'b0}}, tx_pmadprioout[299:0]},
		cent_unit_txpmadprioout = {wire_cent_unit0_txpmadprioout[1799:0]},
		clk_div_cmudividerdprioin = {{500{1'b0}}, wire_ch_clk_div0_dprioout},
		clock_divider_clk0in = {edge_pll_out[3:0]},
		edge_cmu_clkdivpowerdn = {wire_atx_pll_cent_unit0_clkdivpowerdn[0]},
		edge_cmu_pllpowerdn = {wire_atx_pll_cent_unit0_pllpowerdn[0]},
		edge_cmu_pllresetout = {wire_atx_pll_cent_unit0_pllresetout[0]},
		edge_cmu_quadresetout = {wire_atx_pll_cent_unit0_quadresetout},
		edge_pll_analogfastrefclkout = {wire_atx_clk_div0_analogfastrefclkout},
		edge_pll_analogrefclkout = {wire_atx_clk_div0_analogrefclkout},
		edge_pll_analogrefclkpulse = {wire_atx_clk_div0_analogrefclkpulse},
		edge_pll_clkin = {{9{1'b0}}, pll_inclk_wire[0]},
		edge_pll_out = {wire_atx_pll0_clk[3:0]},
		edge_pllpowerdn_in = {edge_cmu_pllpowerdn[0]},
		edge_pllreset_in = {edge_cmu_pllresetout[0]},
		fixedclk_to_cmu = {6{reconfig_clk}},
		nonusertocmu_out = {wire_cal_blk0_nonusertocmu},
		nonusertocmu_out_pll = {wire_pll_cal_blk0_nonusertocmu},
		pll0_clkin = {{9{1'b0}}, pll_inclk_wire[0]},
		pll0_dprioin = {cent_unit_cmuplldprioout[1499:1200]},
		pll0_dprioout = {wire_tx_pll0_dprioout},
		pll0_out = {wire_tx_pll0_clk[3:0]},
		pll_ch_dataout_wire = {wire_rx_cdr_pll0_dataout},
		pll_ch_dprioout = {wire_rx_cdr_pll0_dprioout},
		pll_cmuplldprioout = (pll_type == "High speed ATX") ? {{600{1'b0}}, {900{1'b0}}, pll_ch_dprioout[299:0]} : {{300{1'b0}}, pll0_dprioout[299:0], {900{1'b0}}, pll_ch_dprioout[299:0]},
		pll_edge_locked_out = {wire_atx_pll0_locked},
		pll_inclk_wire = {pll_inclk},
		pll_locked = (pll_type == "High speed ATX") ? {pll_edge_locked_out[0]} : {pll_locked_out[0]},
		pll_locked_out = {wire_tx_pll0_locked},
		pllpowerdn_in = {1'b0, cent_unit_pllpowerdn[0]},
		pllreset_in = {1'b0, cent_unit_pllresetout[0]},
		reconfig_fromgxb = {rx_pma_analogtestbus[16:1], wire_cent_unit0_dprioout},
		reconfig_togxb_busy = reconfig_togxb[3],
		reconfig_togxb_disable = reconfig_togxb[1],
		reconfig_togxb_in = reconfig_togxb[0],
		reconfig_togxb_load = reconfig_togxb[2],
		rx_analogreset_in = {{5{1'b0}}, ((~ reconfig_togxb_busy) & rx_analogreset[0])},
		rx_analogreset_out = {wire_cent_unit0_rxanalogresetout[5:0]},
		rx_clkout = {rx_clkout_wire[0]},
		rx_clkout_wire = {wire_receive_pcs0_clkout},
		rx_coreclk_in = {rx_clkout_wire[0]},
		rx_cruclk_in = {{9{1'b0}}, rx_pldcruclk_in[0]},
		rx_dataout = {rx_out_wire[39:0]},
		rx_deserclock_in = {rx_pll_clkout[3:0]},
		rx_digitalreset_in = {{3{1'b0}}, rx_digitalreset[0]},
		rx_digitalreset_out = {wire_cent_unit0_rxdigitalresetout[3:0]},
		rx_enapatternalign = 1'b0,
		rx_freqlocked = {(rx_freqlocked_wire[0] & (~ rx_analogreset[0]))},
		rx_freqlocked_wire = {wire_rx_cdr_pll0_freqlocked},
		rx_locktodata = 1'b0,
		rx_locktodata_wire = {((~ reconfig_togxb_busy) & rx_locktodata[0])},
		rx_locktorefclk = 1'b0,
		rx_locktorefclk_wire = {wire_receive_pcs0_cdrctrllocktorefclkout},
		rx_out_wire = {wire_receive_pcs0_dataout[39:0]},
		rx_pcsdprioin_wire = {{1200{1'b0}}, cent_unit_rxpcsdprioout[399:0]},
		rx_pcsdprioout = {{1200{1'b0}}, wire_receive_pcs0_dprioout},
		rx_phfifordenable = 1'b1,
		rx_phfiforeset = 1'b0,
		rx_phfifowrdisable = 1'b0,
		rx_pldcruclk_in = {pll_inclk},
		rx_pll_clkout = {wire_rx_cdr_pll0_clk},
		rx_pll_locked = {(rx_plllocked_wire[0] & (~ rx_analogreset[0]))},
		rx_pll_pfdrefclkout_wire = {wire_rx_cdr_pll0_pfdrefclkout},
		rx_plllocked_wire = {wire_rx_cdr_pll0_locked},
		rx_pma_analogtestbus = {{12{1'b0}}, wire_receive_pma0_analogtestbus[5:2], 1'b0},
		rx_pma_clockout = {wire_receive_pma0_clockout},
		rx_pma_dataout = {wire_receive_pma0_dataout},
		rx_pma_locktorefout = {wire_receive_pma0_locktorefout},
		rx_pma_recoverdataout_wire = {wire_receive_pma0_recoverdataout[19:0]},
		rx_pmadprioin_wire = {{1500{1'b0}}, cent_unit_rxpmadprioout[299:0]},
		rx_pmadprioout = {{1500{1'b0}}, wire_receive_pma0_dprioout},
		rx_powerdown = 1'b0,
		rx_powerdown_in = {{5{1'b0}}, rx_powerdown[0]},
		rx_prbscidenable = 1'b0,
		rx_rxcruresetout = {wire_cent_unit0_rxcruresetout[5:0]},
		rx_signaldetect_wire = {wire_receive_pma0_signaldetect},
		rxpll_dprioin = {{1500{1'b0}}, cent_unit_cmuplldprioout[299:0]},
		tx_analogreset_out = {wire_cent_unit0_txanalogresetout[5:0]},
		tx_clkout = {tx_core_clkout_wire[0]},
		tx_clkout_int_wire = {wire_transmit_pcs0_clkout},
		tx_core_clkout_wire = {tx_clkout_int_wire[0]},
		tx_coreclk_in = {tx_core_clkout_wire[0]},
		tx_datain_wire = {tx_datain[39:0]},
		tx_dataout = {wire_transmit_pma0_dataout},
		tx_dataout_pcs_to_pma = {wire_transmit_pcs0_dataout},
		tx_digitalreset_in = {{3{1'b0}}, tx_digitalreset[0]},
		tx_digitalreset_out = {wire_cent_unit0_txdigitalresetout[3:0]},
		tx_dprioin_wire = {{1050{1'b0}}, cent_unit_txdprioout[149:0]},
		tx_invpolarity = 1'b0,
		tx_localrefclk = {wire_transmit_pma0_clockout},
		tx_phfiforeset = 1'b0,
		tx_pmadprioin_wire = {{1500{1'b0}}, cent_unit_txpmadprioout[299:0]},
		tx_pmadprioout = {{1500{1'b0}}, wire_transmit_pma0_dprioout},
		tx_serialloopbackout = {wire_transmit_pma0_seriallpbkout},
		tx_txdprioout = {{450{1'b0}}, wire_transmit_pcs0_dprioout},
		txdetectrxout = {wire_transmit_pcs0_txdetectrx},
		w_cent_unit_dpriodisableout1w = {wire_cent_unit0_dpriodisableout};
endmodule //test_alt4gxb
//VALID FILE

