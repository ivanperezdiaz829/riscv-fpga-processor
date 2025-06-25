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


//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: hsmc_sdi_audio.v $
// Last modified : $Date: 2010/08/20 08:45:39 $
// Export tag    : $Name: Boon Hong Oh $
//--------------------------------------------------------------------------------------------------

module hsmc_sdi_audio(
	input				reset ,			// module reset
	input				gp_clk ,			// 50MHz clock
	input				gxb_refclk , 	// SERDES reference clock
	//input			clk_148_p ,		
	
	///////////////////////////////////
	// DIP Switch to control TX standard and reset
	input	[7:0]		dipsw ,		
	
	///////////////////////
	// color bars
	// 1 = 75% 
	// 0 = 100% 
	input				bar_75_100n, 	
	///////////////////////////////////
	// 1 = pathological pattern output
	// 0 = color bars (see 75 / 100%)
	input				patho, 		
	///////////////////////////////////
	// SDI TX standard
	// 	00 = SD 
	// 	01 = HD 
	// 	10 = 3GB
	//    11 = 3GA
	input	[1:0]		tx_std,	

	///////////////////////////////////
	// Video Test Pattern Standard
   input [31:0]   src_vid_std ,	

	output [1:0]	sdi_tx_p ,			// SERDES high speed data output
	input	 [0:0]	sdi_rx_p ,			// SERDES high speed data input
	output [1:0]	sdi_rate_sel_o ,	// 1 = sd, 0 = hd (no use)
	////////////////////////////////////////////////////////////////
	// pin for ICS810001-22 - video clock generator at daughter card
	output 			sdi_clk_sel_o ,	// 0 = sdi_fb_clk_o, 1 = extclk_in
	output			sdi_xtal_sel_o ,	// 0 = 27MHz, 1 = 26.973MHz
	output [1:0]	sdi_clk_bp_o ,		// PLL Active / Bypass
	output			sdi_clk_oe_o ,		// 1 = drive, 0 = tristate
	output [1:0]	sdi_clk_n_o ,		// see datasheet
	output [3:0]	sdi_clk_v_o ,		// see datasheet
	output			sdi_clk_mltf_o ,	// see datasheet
	output			sdi_clk_rst_o ,	// HSMC A ICS reset
	output [1:0]	eq_bypass_o ,		// 1 = bypass RX eq, 0 = use eq.
	output			sdi_fb_clk_o ,		// to pll on daughter card
	
	/////////////////////////////////////
	// SDI RX standard
	// 	00 = sd
	// 	01 = hd	
	// 	11 = 3GA
   // 	10 = 3GB	
	output [1:0]	rx_std_o ,
	///////////////////////// 
	// SDI RX status bits
	// 0 : SERDES PLL locked
	// 1 : RX in reset
	// 2 : alignment locked
	// 3 : trs locked
	// 4 : frame locked		
	output [10:0]	rx_status_o,
	
	/////////////////////////////////////
	// Audio Extract Status Bits
	output [7:0]   extract_audio_presence,
	output [7:0] 	extract_error_status,
	/////////////////////////////////////
	// HSMC LED status indicators 
	// red 		: SD (270 Mbps)
	// orange 	: HD (1.485Gbps)
	// green	   : 3G (2.970Gbps)
	output [1:0]	sdi_led_tx_r_o ,
	output [1:0]	sdi_led_tx_g_o ,
	output [1:0]	sdi_led_rx_r_o ,
	output [1:0]	sdi_led_rx_g_o ,
	
	////////////////////////////////////
	// AES Audio IO Interface
	input	 [1:0]	aesa_in,
	output [1:0] 	aesa_out,
	output 			aesa_vcxo_up,
	output			aesa_vcxo_dn,
	output			aesa_vcxo_pdtsn,
	output [2:0]	aesa_vcxo_s,
	
	////////////////////////////////////
	// SDI RX recovered clock heartbeart
	output 			sdi_rx_clk_heartbeat
);

//reg [3:0]	sdi_clk_v ;							// ICS810001-22 VCXO PLL divider selection pins
//reg		sdi_fb_clk;							// clk source 0 for ICS810001-22
reg [1:0]	sdi_led_tx_g, sdi_led_tx_r ; 	// red and green led for the SDI transmitters
reg [1:0]	sdi_led_rx_g, sdi_led_rx_r ;	// red and green led for the SDI receivers

///////////////////////////////////////////////////////////////////////////
// Set ICS810001-22 (video clock generator at daughter card) for 148.5 MHz.
assign	sdi_clk_sel_o	= 1'b0 ;				// 0 = sdi_fb_clk_o, 1 = extclk_in
assign	sdi_xtal_sel_o	= 1'b0 ;				// 0 = 27MHz, 1 = 26.973MHz
//assign sdi_clk_v_o	= sdi_clk_v ;
assign 	sdi_clk_v_o	= 1'b0 ;
assign	sdi_clk_bp_o	= 2'b11 ;			// PLL Bypass(00)/Active(01=bypass FemtoClock Frq Mul,10,11)
assign	sdi_clk_oe_o	= 1'b1 ;				// 1 = drive, 0 = tristate
assign	sdi_clk_n_o		= 2'b00 ;			// PLL output divider 00=4,01=8,10=12,11=18
assign	sdi_clk_mltf_o	= 1'b0 ;				// PLL FemtoClock Frq Multiplier 0=x22 , 1=x24
assign	sdi_clk_rst_o	= 1'b0 ;				// hsmc sdi pll reset
assign	eq_bypass_o		= 2'b00 ;			// 1 = bypass RX eq, 0 = use eq.
//assign sdi_fb_clk_o	= sdi_fb_clk ; 	//to pll on the card
assign	sdi_fb_clk_o	= 1'b0 ;
 	
/////////////////////////////////////////
// HSMC LED status indicators
assign	sdi_led_tx_g_o	= sdi_led_tx_g ;
assign	sdi_led_tx_r_o	= sdi_led_tx_r ;
assign	sdi_led_rx_g_o	= sdi_led_rx_g ;
assign	sdi_led_rx_r_o	= sdi_led_rx_r ;
assign	sdi_rate_sel_o	= 2'b00 ;			// unused

////////////////////////////////////////
// System reset
wire sys_reset;
assign sys_reset = dipsw[7] | reset;

////////////////////////////////////////
// SDI RX status and standard
wire rx_clk;
wire [10:0] rx_status;
wire [1:0] rx_std;
assign rx_status_o 	= rx_status;
assign rx_std_o 		= rx_std;

///////////////////////////////////////////////////////
// double registered on pclk due to clk domain crossing
// tx_std : SD(00), HD(01), 3GA(11), 3GB(10)
wire tx_p0_pclk ;
wire tx_p1_pclk ;
   
reg	[1:0]	tx_p0_std_r1, tx_p0_std_r2, tx_p0_std_r3 ;
reg	[1:0]	tx_p1_std_r1, tx_p1_std_r2, tx_p1_std_r3 ;
reg	[1:0]	tx_std_gp_r1 ;

always@(posedge tx_p0_pclk) begin 		
	tx_p0_std_r1 	<= #1 tx_std ;
	tx_p0_std_r2 	<= #1 tx_p0_std_r1 ;
	tx_p0_std_r3	<= #1 tx_p0_std_r2 ;
end

always@(posedge tx_p1_pclk) begin 		
	tx_p1_std_r1 	<= #1 tx_std ;
	tx_p1_std_r2 	<= #1 tx_p1_std_r1 ;
	tx_p1_std_r3	<= #1 tx_p1_std_r2 ;
end

always@(posedge gp_clk) begin 		
	tx_std_gp_r1 	<= #1 tx_std ;
	//tx_std_gp_r2 	<= #1 tx_std_gp_r1 ;
	//tx_std_gp_r3	<= #1 tx_std_gp_r2 ;
end

////////////////////////////////////////////////////////////////////////////////////////////
// generate proper clocks 
///////////////////////////////////////////////////////////////////////////////
// PLL used to generate parallel domain clocks from incoming 148.5MHz clock.
// Alternatively, logic could be used to generate these /2 and /11 clocks.

wire	pclk_27;
wire	pclk_74;
wire  clk_200;

pll_tx_pclks u6_pll_pclks (
   .areset    (1'b0),
   .inclk0    (gxb_refclk),
   .c0        (pclk_27),
   .c1        (pclk_74)
);

//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
master_pll	u_master_pll (
	.areset 	( 1'b0 ),
	.inclk0 	( gp_clk ),		// 50MHz input
	.c0      ( clk_200 ),	// 200MHz output
	.locked 	(  )
);
////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
// if transmit video standard changes, reset colorbar transmitter
reg       	tx_p0_rst;
reg [3:0]   tx_rstcount;

always @ (posedge tx_p0_pclk or posedge sys_reset) begin
	if ( sys_reset ) begin
		tx_p0_rst 		<= #1 1'b1;
		tx_rstcount		<= #1 0;
	end
	else begin
		/////////////////////////////////////////////
		//check to see if the tx standard has changed
		//if it has then set the reset bit for the 
		//pattern generator
		if (tx_p0_std_r3 != tx_p0_std_r1)  begin
			tx_rstcount	<= #1 0 ;
			tx_p0_rst	<= #1 1'b1 ;
		end
	
		//////////////////////////////////
		//use msb as the terminal count
		//and to unset the reset bit
		if ( tx_rstcount[3] )  
			tx_p0_rst <= #1 1'b0 ;
		else  
			tx_rstcount	<= #1 tx_rstcount + 4'd1 ;
	end 
end

reg tx_p1_rst_r, tx_p1_rst_r2, tx_p1_rst_r3;
always @ (posedge tx_p1_pclk)
begin
	tx_p1_rst_r 	<= tx_p0_rst;
	tx_p1_rst_r2 	<= tx_p1_rst_r;
	tx_p1_rst_r3 	<= tx_p1_rst_r2;
end

////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////
// Reconfig instance, used for all rx ports in design
// Triple rate SDI rx cores require reconfiguration using DPRIO.  
// The code below handles the reconfiguration for multiple SDI cores using a single controller.

wire 	[1:0]		sdi_start_reconfig;
wire 	[3:0]		sdi_reconfig_togxb;
wire 	[50:0] 	rc_fromgxb;		//17 x 3 = 51
wire 	[3:0]		multi_reconfig_done;
wire				sdi_reconfig_clk;

assign sdi_reconfig_clk = gp_clk ;   

sdi_tr_reconfig_multi_siv u0_sdi_reconfig_multi (
	//inputs
   .rst                 ( sys_reset ),
   .write_ctrl          ( {2'b00, sdi_start_reconfig[1], 1'b0} ),
   .rx_std_ch0          ( 2'b00 ),		
   .rx_std_ch1          ( rx_std ),	// logical ch 4
   .rx_std_ch2          ( 2'b00 ),
   .rx_std_ch3          ( 2'b00 ),
   .reconfig_fromgxb    ( {17'd0, rc_fromgxb[50:17], 17'd0} ),      
   //outputs
   .reconfig_clk        ( sdi_reconfig_clk ),
   .sdi_reconfig_done   ( multi_reconfig_done ),
   .reconfig_togxb      ( sdi_reconfig_togxb )
);

////////////////////////////////////////////////////////////////
// Generate video pattern for TX P0
wire [19:0] vid_data_p0;
wire        vid_datavalid_smpte_p0;
wire [19:0] vid_data_smpte_p0;
wire        aud_embed_clk48;
wire        aud_source_de, aud_source_ws, aud_source_data;
frb_timing_top u_frb_timing_top_p0(
	.trn_clk					( gp_clk ), 		// 50MHz
	.trn_reset				( tx_p0_rst | sys_reset ),
	.vid_clk					( tx_p0_pclk ),
	.vid_reset				( sys_reset ),
	.timing_std				( src_vid_std ),
	.timing_lut_addr		( 10'd0 ),
	.timing_lut_we			( 1'b0 ),
	.timing_lut_data_in	( 32'd0 ),
	.timing_lut_data_out	( ),
	.interrupt_req_frame	( ),
	.timing_trs				( ),
	.timing_data			( vid_data_p0 )
);

////////////////////////////////////////////////////
// Insert ancillary data in the generated video
insert_smpte352m u_insert_smpte352m_p0(
	.vid_clk					( tx_p0_pclk ),
	.vid_reset				( tx_p0_rst | sys_reset ),
	.enable_anc				( 1'b1 ),
	.vid_std					( src_vid_std ),
	.vid_en					( 1'b1 ),
	.vid_data				( vid_data_p0 ),
	.vid_out_en				( vid_datavalid_smpte_p0 ),
	.vid_out_data			( vid_data_smpte_p0 )
);

////////////////////////////////////////////////////
// Generate AES audio test data
audio_test_source u_audio_test_source(
	.aud_reset 				( sys_reset ),
	.aud_clk					( gp_clk ),
	.aud_clk48				( aud_embed_clk48 ),
	.aud_de					( aud_source_de ),
	.aud_ws					( aud_source_ws ),
	.aud_data				( aud_source_data )
);

/////////////////////////////////////////////////////
// Eight pairs of AES audio will be generated in this
// example design
parameter [2:0] C_AUDEMB_NUM_GROUPS = 4;
genvar i;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_clk_p0;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_de_p0;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_ws_p0;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_data_p0;
generate
	for (i = 0; i <= 2 * C_AUDEMB_NUM_GROUPS - 1; i = i + 1) begin: u_audio_source
		assign aud_embed_clk_p0[(i)] 	= gp_clk;
		assign aud_embed_de_p0[(i)]	= aud_source_de;
		assign aud_embed_ws_p0[(i)] 	= aud_source_ws;
		assign aud_embed_data_p0[(i)] = aud_source_data;
	end
endgenerate

////////////////////////////////////////////////////////////////////////////
// Enable the embedding of each audio group
// If tx_std = 00 (SD), enable the embedding of audio group 1
// If tx_std = 01 (HD), enable the embedding of audio group 1 & 2
// If tx_std = 11 (3GA), enable the embedding of audio group 1 & 2 & 3
// If tx_std = 10 (3GB), enable the embedding of audio group 1 & 2 & 3 & 4
wire [7:0] audio_control;
assign audio_control = (tx_std_gp_r1 == 2'b00) ? {4'b0000, 4'b0001} : 
								((tx_std_gp_r1 == 2'b01) ? {4'b0000, 4'b0011} :
								((tx_std_gp_r1 == 2'b11) ? {4'b0000, 4'b0111} :
								{4'b0000, 4'b1111} ));

////////////////////////////////////////////////////////////////////////////
// The channel status data will be replaced with 
// default values
wire [7:0] cs_control;
assign cs_control = 8'h55;
   
////////////////////////////////////////////////////
// Embed the generated AES audio test data in the 
// SDI stream for TX P0
wire [19:0] vid_embed_out_p0;
wire [10:0]	vid_embed_out_ln_p0 ;
wire        vid_embed_out_trs_p0 ;
wire        vid_embed_out_datavalid_p0 ;

audio_embed_top u_audio_embed_p0 (
	.fix_clk                 ( gp_clk ), // 50MHz
   .reg_clk                 ( gp_clk ), // 50MHz
   .reg_reset               ( sys_reset ),

   //Video input interface
   .reset                   ( tx_p0_rst | sys_reset ),
   .vid_clk                 ( tx_p0_pclk ),
   .vid_std                 ( tx_p0_std_r3 ),
   .vid_datavalid           ( vid_datavalid_smpte_p0 ),
   .vid_data                ( vid_data_smpte_p0 ),

   .vid_std_rate            ( 1'b0 ),
   
	.vid_clk48               ( aud_embed_clk48 ),
   
	//Audio input interface
   .aud_clk                 ( aud_embed_clk_p0 ),
   .aud_de                  ( aud_embed_de_p0 ),
   .aud_ws                  ( aud_embed_ws_p0 ),
   .aud_data                ( aud_embed_data_p0 ),

   //Video output interface
   .vid_out_datavalid       ( vid_embed_out_datavalid_p0 ),
   .vid_out_trs             ( vid_embed_out_trs_p0 ),
   .vid_out_ln              ( vid_embed_out_ln_p0 ),
   .vid_out_data            ( vid_embed_out_p0 ),
	
	// Control and Status interface
	.audio_control     		 ( audio_control ),
	.extended_control	 		 ( ),
	.video_status		 		 ( ),
	.audio_status		 		 ( ),
	.cs_control			 		 ( cs_control ),
	.sine_freq_ch1		 		 ( ),
	.sine_freq_ch2		 		 ( ),
	.sine_freq_ch3     		 ( ),
	.sine_freq_ch4		 		 ( ),
	.csram_addr			 		 ( ),
	.csram_we          		 ( ),
	.csram_data        		 ( )
);

////////////////////////////////////////////////////////////////////////////
// Adjust transmit parallel clock depending on the standard. 
// If 3GA and 3GB use 148M clock, 
// If HD use 74M clock,
// If SD use 27M clock
////////////////////////////////////////////////////////////////////////////
// clock mux for p1
wire tx_p1_clkout;

assign tx_p1_pclk = tx_p1_std_r2[1] ? tx_p1_clkout : (tx_p1_std_r1[0] ? pclk_74 : pclk_27);

//////////////////////////////////////////////////////////////////////////////
// clock mux for p0
wire tx_p0_clkout;
   
assign tx_p0_pclk = tx_p0_std_r2[1] ? tx_p0_clkout : (tx_p0_std_r1[0] ? pclk_74 : pclk_27);

//////////////////////////////////////////////////////////////////////////////
// S4GX SDI TX only MegaCore Instance (P0)
wire	[19:0] rx_data ;
wire 	[1:0]	 rx_data_valid ;
wire 			 tx_p0_stat;

S4gxSDI3G_tx u_S4gxSDI3G_tx_p0 (
	// common
	.rst_tx						( sys_reset | tx_p0_rst ),				//input 	
	.gxb4_cal_clk				( gp_clk ), 								//input
	.sdi_gxb_powerdown		( 1'b0 ), 									//input
	
	// core config settings
	.enable_ln	        		( 1'b1 ), 									//input [0:0]
	.enable_crc					( 1'b1 ), 									//input [0:0]
	
	// tx inputs
	.tx_pclk						( tx_p0_pclk ),							//input 	
	.tx_serial_refclk 		( gxb_refclk ), 							//input - from HSMC A ICS
	.txdata						( vid_embed_out_p0 ), 					//input [19:0]
	.tx_trs						( vid_embed_out_trs_p0 ), 				//input [0:0]  
	.tx_ln						( { 11'b0, vid_embed_out_ln_p0 } ),	//input [21:0] 	
	.tx_std						( tx_p0_std_r3 ),							//input	[1:0]
	
	// tx outputs
	.sdi_tx						( sdi_tx_p[1] ), 							//output [0:0]
	.tx_status					( tx_p0_stat ), 							//output [0:0]	
	.gxb_tx_clkout				( tx_p0_clkout ), 						//output [0:0]
	
	// reconfig inputs
	.sdi_reconfig_clk			( sdi_reconfig_clk ), 					//input 	
	.sdi_reconfig_togxb		( sdi_reconfig_togxb ), 				//input [3:0]	
		
	// reconfig outputs
	.sdi_reconfig_fromgxb	( rc_fromgxb[50:34] ) 					//output [16:0]	
);


/////////////////////////////////////////////////////
// Generate video for SDI TX P1
wire [19:0] vid_data_p1;
frb_timing_top u_frb_timing_top_p1(
	.trn_clk					( gp_clk ), 							// 50MHz
	.trn_reset				( tx_p1_rst_r3 | sys_reset ),
	.vid_clk					( tx_p1_pclk ),   
	.vid_reset				( tx_p1_rst_r3 | sys_reset ),
	.timing_std				( src_vid_std ),
	.timing_lut_addr		( 10'd0 ),
	.timing_lut_we			( 1'b0 ),
	.timing_lut_data_in	( 32'd0 ),
	.timing_lut_data_out	( ),
	.interrupt_req_frame	( ),
	.timing_trs				( ),
	.timing_data			( vid_data_p1 )
);

wire        vid_datavalid_smpte_p1;
wire [19:0] vid_data_smpte_p1;
insert_smpte352m u_insert_smpte352m_p1(
	.vid_clk					( tx_p1_pclk ),  
	.vid_reset				( tx_p1_rst_r3 | sys_reset ),
	.enable_anc				( 1'b1 ),
	.vid_std					( src_vid_std ),
	.vid_en					( 1'b1 ),
	.vid_data				( vid_data_p1 ),
	.vid_out_en				( vid_datavalid_smpte_p1 ),
	.vid_out_data			( vid_data_smpte_p1 )
);

///////////////////////////////////////////////////////////////
// Generate the AES Audio data for SDI TX P1 
// It is using the received audio from the AES Input interface
genvar k;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_clk_p1;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_de_p1;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_ws_p1;
wire [2*C_AUDEMB_NUM_GROUPS-1:0] aud_embed_data_p1;
wire [1:0] aud_in_de;
wire [1:0] aud_in_ws;
wire [1:0] aud_in_data;
   
generate
	for (k = 0; k <= 2 * C_AUDEMB_NUM_GROUPS - 1; k = k + 1) begin: u_audio_aes_in
		assign aud_embed_clk_p1[(k)] 	= gp_clk;
		assign aud_embed_de_p1[(k)]	= aud_in_de[0];
		assign aud_embed_ws_p1[(k)] 	= aud_in_ws[0];
		assign aud_embed_data_p1[(k)] = aud_in_data[0];
	end
endgenerate

////////////////////////////////////////////////////////////////////
// Embed the received AES audio in the SDI stream for TX P1
wire [19:0] vid_embed_out_p1 ;
wire [10:0]	vid_embed_out_ln_p1 ;
wire        vid_embed_out_trs_p1 ;
wire        vid_embed_out_datavalid_p1 ;
audio_embed_top u_audio_embed_p1 (
	.fix_clk                 ( gp_clk ), 							// 50MHz
   .reg_clk                 ( gp_clk ), 							// 50MHz
	.reg_reset               ( sys_reset ),
	
	.reset                   ( tx_p1_rst_r3 | sys_reset ),
   .vid_clk                 ( tx_p1_pclk ),
   .vid_std                 ( tx_p1_std_r3 ),
   .vid_datavalid           ( vid_datavalid_smpte_p1 ),
   .vid_data                ( vid_data_smpte_p1 ),

   .vid_std_rate            ( 1'b0 ),
   
	.vid_clk48               ( ),
   
	// Audio input interface - from AES Input port which is extracted 
	// from audio extract component
   .aud_clk                 ( aud_embed_clk_p1 ),				
   .aud_de                  ( aud_embed_de_p1 ),
   .aud_ws                  ( aud_embed_ws_p1 ),
   .aud_data                ( aud_embed_data_p1 ),				

   //Video output interface
   .vid_out_datavalid       ( vid_embed_out_datavalid_p1 ),
   .vid_out_trs             ( vid_embed_out_trs_p1 ),
   .vid_out_ln              ( vid_embed_out_ln_p1 ),
   .vid_out_data            ( vid_embed_out_p1 ),
	
	// Control and Status Interface
	.audio_control     		 ( audio_control ),
	.extended_control	 		 ( ),
	.video_status		 		 ( ),
	.audio_status		 		 ( ),
	.cs_control			 		 ( cs_control ),
	.sine_freq_ch1		 		 ( ),
	.sine_freq_ch2		       ( ),
	.sine_freq_ch3     		 ( ),
	.sine_freq_ch4		 		 ( ),
	.csram_addr			 		 ( ),
	.csram_we          	 	 ( ),
	.csram_data        		 ( )
);

////////////////////////////////////////////////////////////////////////////
// S4GX SDI Duplex(TX P1 & RX) MegaCore Instance
wire 			tx_p1_stat;
wire [21:0] rx_ln;
S4gxSDI3G_ch4 u_S4gxSDI3G_tx_p1_rx_p0 (
	// common
	.rst_rx						( sys_reset ), 							//input 	
	.rst_tx						( tx_p1_rst_r3 | sys_reset ), 	
	.sdi_gxb_powerdown		( 1'b0 ), 									//input 
	.gxb4_cal_clk				( gp_clk ), 								//input 	
	
	// core config settings
	.enable_ln					( 1'b1 ), 									//input [0:0]	
	.enable_crc					( 1'b1 ), 									//input [0:0]	
	.en_sync_switch			( 1'b0 ), 									//input		 	
	.enable_hd_search			( 1'b1 ), 									//input 	
	.enable_sd_search			( 1'b1 ), 									//input 	
	.enable_3g_search			( 1'b1 ), 									//input 
	
	// tx inputs
	.tx_pclk						( tx_p1_pclk  ), 							//input
	.tx_serial_refclk			( gxb_refclk ), 							//input	
	.txdata						( vid_embed_out_p1 ), 					//input [19:0]	                
	.tx_trs						( vid_embed_out_trs_p1 ), 				//input [0:0] 
	.tx_ln						( {11'd0, vid_embed_out_ln_p1} ),	//input [21:0]
	.tx_std_select_hd_sdn	( ), 											//input 	
	.tx_std						( tx_p1_std_r3 ), 
	
	// tx outputs
	.sdi_tx    					( sdi_tx_p[0] ), 							//output [0:0]
	.gxb_tx_clkout  			( tx_p1_clkout ), 						//output [0:0]	
	.tx_status 					( tx_p1_stat ), 							//output [0:0]
	
	// rx inputs
	.rx_serial_refclk			( gxb_refclk ), 							//input	
	.sdi_rx						( sdi_rx_p[0] ), 							//input [0:0] 	

	// rx outputs
	.rxdata    					( rx_data ), 								//output [19:0]	
	.rx_data_valid_out  		( rx_data_valid ), 						//output [1:0]	
	.rx_clk    					( rx_clk ), 								//output [0:0]	
	.rx_status 					( rx_status ), 							//output [10:0]	
	.rx_ln     					( rx_ln ), 									//output [21:0]	  
	.rx_std       				( rx_std ), 								//output [1:0]		
	
	// not used	
	.rx_anc_data     			(  ), 										//output [19:0]	
	.rx_anc_valid    			(  ), 										//output [3:0]	
	.rx_anc_error    			(  ), 										//output [3:0]	
	.rx_std_flag_hd_sdn		(  ), 										//output [0:0]	
	.rx_F      					(  ), 										//output [1:0]	
	.rx_V      					(  ), 										//output [1:0]	
	.rx_H      					(  ), 										//output [1:0]	
	.rx_AP     					(  ), 										//output [1:0]	
	
	// reconfig inputs
	.sdi_reconfig_clk			( sdi_reconfig_clk ), 					//input 	
	.sdi_reconfig_togxb		( sdi_reconfig_togxb ), 				//input [3:0]	
	.sdi_reconfig_done		( multi_reconfig_done[1] ), 			//input 

	// reconfig outputs 
	.sdi_reconfig_fromgxb	( rc_fromgxb[33:17] ), 					//output 16 bits
	.sdi_start_reconfig  	( sdi_start_reconfig[1] )  			//output 	
	);
	
/////////////////////////////////////////////////////////////////////
// Extract the AES audio out from the SDI stream
wire aud_extract_clk;
wire aud_extract_data;
wire aud_extract_de;
wire aud_extract_ws;

wire [7:0] 	audio_presence;
wire [7:0] 	error_status;
wire [7:0] 	error_reset;
wire 			fifo_reset;
assign error_reset = dipsw[6] ? 8'hFF : 8'h00;
assign fifo_reset = dipsw[6] ? 1'b1 : 1'b0;

audio_extract_top u_audio_extract(
   .reg_clk                 ( gp_clk ), 						// 50MHz
   .reg_reset               ( sys_reset ),
 
   // Video input interface
   .reset                   ( sys_reset | rx_status[1] ),
   .vid_clk                 ( rx_clk ),
   .vid_std                 ( rx_std ),
   .vid_datavalid           ( rx_data_valid[0] ),
   .vid_data                ( rx_data ),
   .vid_locked              ( rx_status[4] ),

	// Audio clocks output interface
  .fix_clk                 ( clk_200 ), 						// 200MHz
  .aud_clk_out             ( aud_extract_clk ),
  .aud_clk48_out           ( ),

  // Audio output interface
  .aud_clk                 ( aud_extract_clk ),
  .aud_ws_in               ( 1'b0 ),
  .aud_de                  ( aud_extract_de ),
  .aud_ws                  ( aud_extract_ws ),
  .aud_data                ( aud_extract_data ),
 
  // Control and Status interface
  .audio_control     		  ( 8'h01 ),
  .audio_presence	 		  ( audio_presence ),
  .audio_status		 		  ( ),
  .error_status		 		  ( error_status ),
  .error_reset		 		  ( error_reset ),
  .fifo_status		        ( ),
  .fifo_reset			     ( fifo_reset ),
  .clock_status            ( ),
  .csram_addr              ( ),
  .csram_data              ( )
);
	
/////////////////////////////////////////////////////////
// Display the extract status on LED
assign extract_audio_presence = audio_presence;
assign extract_error_status = error_status;
	
/////////////////////////////////////////////////////////
// Generate the heartbeart on the SDI RX recovered clock
reg [25:0] sdi_duplex_heartbeat;
always @ (posedge rx_clk)	sdi_duplex_heartbeat <= sdi_duplex_heartbeat + 26'd1;
assign sdi_rx_clk_heartbeat = sdi_duplex_heartbeat[25];

/////////////////////////////////////////////////////////
// Audio AES Output Interface
wire [1:0] aes_out_data;
aes_output u_aes_output0(
  .aud_clk                 (aud_extract_clk),
  .aud_ws                  (aud_extract_ws),
  .aud_data                (aud_extract_data),

  .aes_data                (aes_out_data[0]));

aes_output u_aes_output1(
  .aud_clk                 (aud_extract_clk),
  .aud_ws                  (aud_extract_ws),
  .aud_data                (aud_extract_data),

  .aes_data                (aes_out_data[1]));

assign aesa_out = aes_out_data;
assign aesa_vcxo_up = 1'b0;
assign aesa_vcxo_dn = 1'b0;
assign aesa_vcxo_pdtsn = 1'b1;
assign aesa_vcxo_s = {3{1'b0}};	
 
//////////////////////////////////////////////////////////
// Audio AES Input Interface

aes_input u_aes_input0(
  .aes_data                (aesa_in[0]),

  .aud_clk                 (gp_clk),
  .aud_de                  (aud_in_de[0]),
  .aud_ws                  (aud_in_ws[0]),
  .aud_data                (aud_in_data[0]));

aes_input u_aes_input1(
  .aes_data                (aesa_in[1]),

  .aud_clk                 (gp_clk),
  .aud_de                  (aud_in_de[1]),
  .aud_ws                  (aud_in_ws[1]),
  .aud_data                (aud_in_data[1])); 

////////////////////////////////////////////////////////////////////////////////////////////
// Set led 'sdi_led_tx_r, sdi_led_tx_g, sdi_led_rx_r, sdi_led_rx_g'
// Received & transmit video standard. 00 = SD, 01 = HD, 11 = 3GA, 10 = 3GB

always @ ( tx_p0_std_r1[1] or tx_p0_std_r1[0] )
	begin 
		case ( tx_p0_std_r1[1:0] )
		2'b00	: begin	// red only for 270 Mbps
				sdi_led_tx_r[0] = 1'b1 ;
				sdi_led_tx_g[0] = 1'b0 ;
			  end
		2'b01	: begin	// red and green for 1.48Gbps
				sdi_led_tx_r[0] = 1'b1 ;
				sdi_led_tx_g[0] = 1'b1 ;
			  end
			  
		2'b10	: begin	// green only for 3 Gbps
				sdi_led_tx_r[0] = 1'b0 ;
				sdi_led_tx_g[0] = 1'b1 ;
			  end
			  
		2'b11	: begin	// green only for 3 Gbps
				sdi_led_tx_r[0] = 1'b0 ;
				sdi_led_tx_g[0] = 1'b1 ;
			  end
		default : begin	// red only for 270 Mbps
				sdi_led_tx_r[0] = 1'b1 ;
				sdi_led_tx_g[0] = 1'b0 ;
			  end
		endcase
	end

///////////////////////////////////////////////////////////
always @ ( tx_p1_std_r1[1] or tx_p1_std_r1[0]  )
	begin 
		case ( tx_p1_std_r1[1:0] )
		2'b00	: begin	// red only for 270 Mbps
				sdi_led_tx_r[1] = 1'b1 ;
				sdi_led_tx_g[1] = 1'b0 ;
			  end
		2'b01	: begin	// red and green for 1.48Gbps
				sdi_led_tx_r[1] = 1'b1 ;
				sdi_led_tx_g[1] = 1'b1 ;
			  end
			  
		2'b10	: begin	// green only for 3 Gbps
				sdi_led_tx_r[1] = 1'b0 ;
				sdi_led_tx_g[1] = 1'b1 ;
			  end
		2'b11	: begin	// green only for 3 Gbps
				sdi_led_tx_r[1] = 1'b0 ;
				sdi_led_tx_g[1] = 1'b1 ;
			  end
		default : begin	// red only for 270 Mbps
				sdi_led_tx_r[1] = 1'b1 ;
				sdi_led_tx_g[1] = 1'b0 ;
			  end
		endcase
	end

///////////////////////////////////////////////////////////
always @ ( rx_std )
	begin 
	        sdi_led_rx_r[0] = 1'b0 ;
		sdi_led_rx_g[0] = 1'b0 ;
		case ( rx_std )
		2'b00	: begin	// red only for 270 Mbps
				sdi_led_rx_r[1] = 1'b1 ;
				sdi_led_rx_g[1] = 1'b0 ;
			  end
		2'b01	: begin	// red and green for 1.48Gbps
				sdi_led_rx_r[1] = 1'b1 ;
				sdi_led_rx_g[1] = 1'b1 ;
			  end
			  
		2'b10	: begin	// green only for 3 Gbps
				sdi_led_rx_r[1] = 1'b0 ;
				sdi_led_rx_g[1] = 1'b1 ;
			  end
		2'b11	: begin	// green only for 3 Gbps
				sdi_led_rx_r[1] = 1'b0 ;
				sdi_led_rx_g[1] = 1'b1 ;
			  end
		default : begin	// red only for 270 Mbps
				sdi_led_rx_r[1] = 1'b1 ;
				sdi_led_rx_g[1] = 1'b0 ;
			  end
		endcase
	end
endmodule




