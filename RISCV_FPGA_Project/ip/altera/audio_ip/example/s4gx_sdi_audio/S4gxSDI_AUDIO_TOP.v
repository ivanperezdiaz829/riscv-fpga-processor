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
// File          : $RCSfile: S4gxSDI_AUDIO_TOP.v $
// Last modified : $Date: 2010/08/20 09:19:39 $
// Export tag    : $Name: Boon Hong Oh $
//--------------------------------------------------------------------------------------------------

module S4gxSDI_AUDIO_TOP (   
	//CLK-Inputs---------------------------//
	input           clkin_50,          		//	2.5V 50.000 MHz osc
   //input         clk_148_p,				// On board 148.5MHz
	
	//User-IO------------------------------
   input  [7:0]   user_dipsw,   				//2.5V     // (TR=0)
   output [15:0]  user_led,    				//2.5V
   input          cpu_resetn,  				//2.5V     // (TR=0)

	//HIGH-SPEED-MEZZANINE-CARD------------//
	//Port A -->   single samtec conn  		//107 pins  
   output [1:0]   hsma_tx_p,    	 			//1.4V PCML
   input  [0:0]	hsma_rx_p,    	 			//1.4V PCML 
	
	//Enable below for CMOS HSMC     
   //inout  [79:0]  hsma_d,           		//2.5V
	//Enable below for LVDS HSMC
   output [16:0]	hsma_tx_d_p,    			//2.5V
   output [16:0]	hsma_tx_d_n,				//2.5V
   input  [16:0]	hsma_rx_d_p,      		//2.5V
   input  [16:0]	hsma_rx_d_n,				//2.5V
   inout  [3:0] 	hsma_d,            		//2.5V
	// input   		hsma_clk_in0,       		//2.5V
	// output 		hsma_clk_out0,      		//2.5V
	// input   		hsma_clk_in_p1,     		//LVDS
	// output  		hsma_clk_out_p1,    		//LVDS
    input   		hsma_clk_in_p2,     		//LVDS
    output  		hsma_clk_out_p2    		//2.5V
	// inout   		hsma_sda,           		//2.5V     // (TR=0)
	// output  		hsma_scl,           		//2.5V     // (TR=0)
	// output  		hsma_tx_led,        		//2.5V
	// output  		hsma_rx_led,        		//2.5V
	// input   		hsma_prsntn        		//2.5V     // (TR=0)
);      
                               
//
////////////////////////////////////////////////////////////////
// signals
reg			u_reset_r1, u_reset_r2, reset ;
reg	[7:0]	u_dipsw_r1, u_dipsw_r2, dipsw ;
reg	[1:0]	tx_std ;
wire			gp_clk ;

////////////////////////////////////////////////////////////////
// debounce and set correct polarity of user signals
// cpu_resetn
// user_dipsw[7:0]
////////////////////
reg	[19:0]	db_count ;				//debounce counter
assign 			gp_clk = clkin_50 ;	//general purpose clock
reg 	[31:0]  	src_vid_std ;

always @ ( posedge gp_clk ) begin
	// this should create a pulse that is one clock long every
	// 524288 clocks (1/2 Meg)
	if ( db_count[19] )
		db_count <= #1 0 ;
	else
		db_count <= #1 db_count + 20'd1 ;
	
	// debounce and double register.
	if ( db_count[19] ) begin	// use db_count[19] as an enable
		u_reset_r1	<= #1 ~cpu_resetn ;
		u_reset_r2	<= #1 u_reset_r1 ;
		///////////////////////////////
		u_dipsw_r1	<= #1 user_dipsw ;
		u_dipsw_r2	<= #1 u_dipsw_r1 ;

		////////////////////////////////
		if ( u_reset_r2 == u_reset_r1 ) 
			reset	<= #1 u_reset_r2 ;	
		else
			reset	<= #1 1'b1 ; //keep in reset
	
		//////////////////////////////////////////////
		// if u_dipsw stable then allow dipsw to change
		begin : for_i_loop
		integer i ;
		for( i=0; i<8; i=i+1 ) begin 
		  if ( u_dipsw_r2[i] == u_dipsw_r1[i] ) 
			dipsw[i]	<= #1 u_dipsw_r2[i] ;
		  end
		end
		
		////////////////////////////////////////////////
		// set up the TX standard for color bar
		// pattern generator
		// not used for loop back since standard is 
		// the same as the RX channel
		if ( dipsw[1:0] == 2'b00 ) begin			//sd
			tx_std	<= #1 2'b00 ;
			// NTSC
			//src_vid_std <= #1 {8'b10000001, 8'b00000110, 8'b00000000, 8'b00000000};
			// PAL
			src_vid_std <= #1 {8'b10000001, 8'b00000101, 8'b00000000, 8'b00000000};
		end
		else if ( dipsw[1:0] == 2'b01 ) begin 	//hd
			tx_std	<= #1 2'b01 ;
			src_vid_std <= #1 {8'b10000101, 8'b00000110, 8'b10000000, 8'b00000000};
		end
		else if ( dipsw[1:0] == 2'b10 ) begin 	//3GB
			tx_std	<= #1 2'b10 ;
			src_vid_std <= #1 {8'b10001010 , 8'b00000110 , 8'b10000001 , 8'b00000000};
		end 
		else if ( dipsw[1:0] == 2'b11 ) begin 	//3GA
			tx_std	<= #1 2'b11 ;
			src_vid_std <= #1 {8'b10001001, 8'b11001011, 8'b10000000, 8'b00000000};
		end
		else begin 									  	//default 3GA
			tx_std	<= #1 2'b11 ;
			src_vid_std <= #1 {8'b10001001, 8'b11001011, 8'b10000000, 8'b00000000};
		end
	end
end

/////////////////////////////////////////////////////////////////////////////////
// Display the status on LED
wire [7:0] 	extract_error_status, extract_audio_presence;
wire 			sdi_rx_clk_heartbeat;
wire [1:0]  rx_std ;
wire [10:0] rx_status ;
   
assign      user_led[15] = ~tx_std[1] ;						// Transmit Standard for both TX P0 and TX P1 bit 1
assign      user_led[14] = ~tx_std[0] ;						// Transmit Standard for both TX P0 and TX P1 bit 0
assign      user_led[13] = ~rx_std[1] ;               	// SDI RX: Receive Standard bit 1
assign      user_led[12] = ~rx_std[0] ;						// SDI RX: Receive Standard bit 0

assign      user_led[11] = ~extract_error_status[7] ; 	// Audio Extract: Audio Packet ECRC Fail
assign      user_led[10] = ~extract_error_status[6] ; 	// Audio Extract: Channel Status CRC Fail
assign      user_led[9]  = ~extract_error_status[5] ; 	// Audio Extract: Ancillary Parity Fail
assign      user_led[8]  = ~extract_error_status[4] ; 	// Audio Extract: Ancillary CS Fail
  
assign      user_led[7] = sdi_rx_clk_heartbeat ; 			// SDI RX: Heartbeat of Recovered Clock      
assign      user_led[6] = ~rx_status[4] ; 					// SDI RX: Frame locked 
assign      user_led[5] = ~rx_status[3] ; 					// SDI RX: TRS locked         
assign      user_led[4] = ~rx_status[2] ; 					// SDI RX: Alignment locked       

assign      user_led[3] = ~extract_audio_presence[3] ; 	// Audio Extract: audio group 4 present
assign      user_led[2] = ~extract_audio_presence[2] ; 	// Audio Extract: audio group 3 present
assign      user_led[1] = ~extract_audio_presence[1] ; 	// Audio Extract: audio group 2 present  
assign      user_led[0] = ~extract_audio_presence[0] ; 	// Audio Extract: audio group 1 present 



///////////////////////////////////////////////////////////////////////////////////////
// HSMC SDI Instances and AES Audio IO Interface
wire			gxb_refclk ;
wire			sdi_hsmc_clk ;		
wire	[1:0]	eq_bypass ;	
wire	[1:0]	sdi_rate_sel ;
wire			sdi_clk_sel ;
wire			sdi_xtal_sel ;	
wire	[1:0]	sdi_clk_bp ;	
wire			sdi_clk_oe ;
wire	[1:0]	sdi_clk_n ;
wire	[3:0]	sdi_clk_v ;
wire			sdi_clk_mltf ;
wire			sdi_clk_rst ;
wire			sdi_fb_clk ;
wire	[1:0]	sdi_led_tx_r ;
wire	[1:0]	sdi_led_tx_g ;
wire	[1:0]	sdi_led_rx_r ;
wire	[1:0]	sdi_led_rx_g ;
wire 	[1:0] aesa_out;
wire 			aesa_vcxo_up;
wire			aesa_vcxo_dn;
wire			aesa_vcxo_pdtsn;
wire [2:0]	aesa_vcxo_s;

assign	gxb_refclk			= hsma_clk_in_p2 ; // ICS clock output 148.5MHz on HSMC A
assign 	hsma_clk_out_p2 	= sdi_hsmc_clk ;

assign	hsma_tx_d_p[0]		= ~sdi_led_tx_g[0] ;
assign	hsma_tx_d_n[0]		= ~sdi_led_tx_g[1] ;
assign	hsma_tx_d_p[1]		= ~sdi_led_rx_r[1] ;
assign	hsma_tx_d_n[1]		= ~sdi_led_rx_g[1] ;
assign	hsma_tx_d_p[2]		= ~sdi_led_rx_r[0] ;
assign	hsma_tx_d_n[2]		= ~sdi_led_rx_g[0] ;
assign	hsma_tx_d_p[4]		= sdi_rate_sel[0] ;
assign	hsma_tx_d_n[4]		= sdi_rate_sel[1] ;
assign	hsma_tx_d_p[5]		= eq_bypass[0]	;
assign	hsma_tx_d_n[5]		= eq_bypass[1]	;

assign	hsma_tx_d_p[6]		= aesa_vcxo_s[0] ;
assign	hsma_tx_d_n[6]		= aesa_vcxo_s[1] ;
assign	hsma_tx_d_p[7]		= aesa_vcxo_s[2] ;
assign	hsma_tx_d_n[7]		= aesa_vcxo_pdtsn ;
assign	hsma_tx_d_p[8]		= aesa_out[0] ;
assign	hsma_tx_d_n[8]		= aesa_out[1] ;
assign	hsma_tx_d_p[9]		= aesa_vcxo_up ;
assign	hsma_tx_d_n[9]		= aesa_vcxo_dn ;

assign	hsma_tx_d_p[10]	= sdi_clk_sel	;
assign	hsma_tx_d_n[10]	= sdi_xtal_sel	;	
assign	hsma_tx_d_p[11]	= sdi_clk_bp[0] ;	
assign	hsma_tx_d_n[11]	= sdi_clk_bp[1] ;
assign	hsma_tx_d_n[12]	= sdi_clk_n[0]	;
assign	hsma_tx_d_p[13]	= sdi_clk_n[1]	;
assign	hsma_tx_d_n[13]	= sdi_clk_v[0]	;
assign	hsma_tx_d_p[14]	= sdi_clk_v[1]	;
assign	hsma_tx_d_n[14]	= sdi_clk_v[2]	;
assign	hsma_tx_d_p[15]	= sdi_clk_v[3]	;
assign	hsma_tx_d_n[15]	= sdi_clk_mltf	;
assign	hsma_tx_d_p[16]	= sdi_clk_rst	;
assign	hsma_tx_d_n[16] 	= sdi_clk_oe ;

assign	hsma_d[0]			= ~sdi_led_tx_r[0] ;
assign	hsma_d[2]			= ~sdi_led_tx_r[1] ;

wire [1:0] aesa_in;
assign aesa_in[0] = hsma_rx_d_p[8];
assign aesa_in[1] = hsma_rx_d_n[8];

hsmc_sdi_audio u0_hsmc_sdi_audio(
	//inputs
	.reset 						( reset ) ,
	.gp_clk 						( gp_clk ) , 
	.gxb_refclk 				( gxb_refclk ) ,			// ICS clock output 148.5MHz
	//.clk_148_p				( clk_148_p ),				// Fixed on board clock 148.5MHz
	.sdi_rx_p 					( hsma_rx_p[0:0] ) ,
	.dipsw 						( dipsw[7:0] ) ,
	.bar_75_100n				( dipsw[2] ) ,
	.patho						( dipsw[3] ) ,
	.tx_std						( tx_std ) ,
	.src_vid_std      		( src_vid_std ) ,
	.aesa_in						( aesa_in ),
	
	//outputs
	.sdi_tx_p 					( hsma_tx_p[1:0] ) ,
	.sdi_fb_clk_o				( sdi_hsmc_clk ) , 		// clock input to ICS on the HSMC A

	.eq_bypass_o 				( eq_bypass ) ,	
	.sdi_rate_sel_o 			( sdi_rate_sel ) ,
	.sdi_clk_sel_o 			( sdi_clk_sel ) ,
	.sdi_xtal_sel_o 			( sdi_xtal_sel ) ,	
	.sdi_clk_bp_o 				( sdi_clk_bp ) ,			// PLL Active / Bypass
	.sdi_clk_oe_o 				( sdi_clk_oe ) ,			// 1 bit out
	.sdi_clk_n_o 				( sdi_clk_n ) ,			// 2 bits out
	.sdi_clk_v_o 				( sdi_clk_v ) ,			// 4 bits out
	.sdi_clk_mltf_o 			( sdi_clk_mltf ) ,
	.sdi_clk_rst_o 			( sdi_clk_rst ) ,
	
	.rx_std_o					( rx_std ) ,				// 2 bits out
	.rx_status_o				( rx_status ) ,			// 11 bits out

	.sdi_led_tx_r_o 			( sdi_led_tx_r ) ,		// 2 bits out
	.sdi_led_tx_g_o 			( sdi_led_tx_g ) ,		// 2 bits out
	.sdi_led_rx_r_o 			( sdi_led_rx_r ) ,		// 2 bits out
	.sdi_led_rx_g_o 			( sdi_led_rx_g ) ,		// 2 bits out
	
	.aesa_out					( aesa_out ),
	.aesa_vcxo_up     		( aesa_vcxo_up ),
	.aesa_vcxo_dn     		( aesa_vcxo_dn ),
	.aesa_vcxo_pdtsn  		( aesa_vcxo_pdtsn ),
	.aesa_vcxo_s      		( aesa_vcxo_s ),
	
	.extract_audio_presence ( extract_audio_presence ),
	.extract_error_status	( extract_error_status ),
	.sdi_rx_clk_heartbeat   ( sdi_rx_clk_heartbeat )
	);

endmodule
