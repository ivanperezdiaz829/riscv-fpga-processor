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


//###########################################################################
// sv_xcvr_interlaken_nr module Instantiates
// sv_xcvr_interlaken_native, reset controller and CSR
// $Header$
//###########################################################################
`timescale 1 ns / 1 ps

import altera_xcvr_functions::*;

module sv_xcvr_interlaken_nr 
  #(
    parameter CH_INDEX = 1,
    parameter PLEX = "DUPLEX",
    parameter LINKWIDTH = 1,
    parameter METALEN = 2048,
    parameter EXTRA_SIGS = 1,
    // PLL
    parameter PLL_REFCLK_CNT = 1,         // number of reference clocks
    parameter PLL_REF_FREQ = "312.5 MHz", // frequency of each refernce clock
    parameter PLL_REFCLK_SELECT = "0",    // selects the initial reference clock for each TX PLL
    parameter PLLS = 1,    
    parameter PLL_TYPE = "AUTO" ,         // PLL type pf each pll
    parameter PLL_SELECT = 0,              // selects the initial PLL
    // Data Rate    
    parameter DATA_RATE = "6250 Mbps",
    parameter BASE_DATA_RATE = "0 Mbps",  // (PLL Rate) - must be (data_rate * 1,2,4,or8)

    parameter TX_USE_CORECLK = 1,
    parameter RX_USE_CORECLK = 1,
    parameter sys_clk_in_mhz = 150,
    parameter     ECC_ENABLE        = 0,
    parameter BONDED_GROUP_SIZE = 1
    ) (
    input pll_ref_clk,
  
    output [LINKWIDTH-1:0] tx_serial_data,
    output 		   tx_user_clock,
    input [(LINKWIDTH*64)-1:0] tx_datain,
    input [LINKWIDTH-1:0]      tx_ctrlin,
    input [LINKWIDTH-1:0]      tx_crcerr,
       //  wr_en of TX_FIFO   
    input [LINKWIDTH-1:0]      tx_datavalid,
      // Full and pfull flags of TX FIFO
    output [LINKWIDTH-1:0] 	tx_fifofull,
    output [LINKWIDTH-1:0] 	tx_fifopfull,   


    output [LINKWIDTH-1:0]     tx_dataready,
    output 		       tx_pcs_ready,
//    output [LINKWIDTH-1:0]     pll_locked,
    output                       pll_locked,
  
    input [LINKWIDTH-1:0]      rx_serial_data,
    output 		       rx_user_clock,
    input [LINKWIDTH-1:0]      rx_fifoclr,
    output [(LINKWIDTH*64)-1:0] rx_dataout,
    output [LINKWIDTH-1:0] 	rx_datavalid,
    input [LINKWIDTH-1:0] 	rx_dataready,
    output 			rx_pcs_ready,
    output [LINKWIDTH-1:0] 	rx_fifofull,
    output [LINKWIDTH-1:0] 	rx_fifopfull,
    output [LINKWIDTH-1:0] 	rx_fifopempty,

       //   
    output [LINKWIDTH-1:0] 	rx_ctrlout,

       // renaming 
       // rx_syncout=> rx_block_frame_lock
       //  rx_wordlock => rx_align_val
       //  rx_synclock => rx_frame_lock           
    output [LINKWIDTH-1:0] 	rx_block_frame_lock,
    output [LINKWIDTH-1:0] 	rx_align_val,
    output [LINKWIDTH-1:0] 	rx_frame_lock,      

       
    output [LINKWIDTH-1:0] 	rx_crc32err,
  
       // PMA and PCS management signals : 
       // PMA Address space will be till 1FFh Bye address  and PCS address space from 0X200H Byte address (0x80 H word address) 
    input 			mgmt_clk,
    input 			mgmt_rst /* synthesis altera_attribute="disable_da_rule=r102" */ ,   
    input 			mgmt_write,
    input 			mgmt_read,
    output 			mgmt_waitrequest,
    input [7:0] 		mgmt_address,
    input [31:0] 		mgmt_datain,
    output [31:0] 		mgmt_dataout,
       // Adding following for Deskew functionality   
    input 			rx_coreclkin,
    input 			tx_coreclkin,
    output [LINKWIDTH-1:0] 	rx_clkout,
    output [LINKWIDTH-1:0] 	tx_clkout,

       // For PCS Bonding soft solution IP
    output 			tx_sync_done,
  
       // Reconfig interfaces
    input   wire [get_interlaken_reconfig_to_width  ("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_to_xcvr     /* synthesis altera_attribute="disable_da_rule=r102" */  ,
    output  wire [get_interlaken_reconfig_from_width("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_from_xcvr 
  
       );

   localparam  TX_ENABLE = (PLEX != "Rx" && PLEX != "RX");
   localparam  RX_ENABLE = (PLEX != "Tx" && PLEX != "TX");
   
   localparam reconfig_interfaces  = get_interlaken_reconfig_interfaces("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH);
   
   localparam sync_depth = 2;

   // Determine the total slices and total number of PLLS depending
   // on the BONDED_GROUP_SIZE
   // For 11.1 onwards BONDED_GROUP_SIZE is always 1
   localparam xslices = LINKWIDTH/BONDED_GROUP_SIZE;
   localparam  xremain = LINKWIDTH % BONDED_GROUP_SIZE;
   localparam total_plls = (xremain >0)? xslices +1 : xslices;
   

   
   wire [31:0] pma_mgmt_dataout;
   wire [31:0] pcs_mgmt_dataout;   
   
   wire [total_plls-1:0] tx_pll_locked;   
   wire 		 enable_pcs;
   
   // 'top' channel CSR ports, mgmt facing
   wire [31:0] 		 sc_topcsr_readdata;
   wire 		 sc_topcsr_waitrequest;
   wire [ 7:0] 		 sc_topcsr_address;
   wire 		 sc_topcsr_read;
   wire 		 sc_topcsr_write;
   
   wire 		 reconfig_busy; // Reconfig busy signal for external reconfig
   
   wire [LINKWIDTH-1:0]  temp_pcs_dataout0;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout1;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout2;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout3;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout4;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout5;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout6;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout7;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout8;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout9;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout10;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout11;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout12;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout13;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout14;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout15;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout16;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout17;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout18;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout19;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout20;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout21;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout22;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout23;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout24;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout25;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout26;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout27;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout28;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout29;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout30;
   wire [LINKWIDTH-1:0]  temp_pcs_dataout31;
   
   
   
   wire [LINKWIDTH-1:0] rx_framing_error;
   wire [LINKWIDTH-1:0] rx_scrambler_mismatch;
   wire [LINKWIDTH-1:0] rx_missing_sync;
   
   wire 		csr_pll_powerdown;   
   wire [LINKWIDTH-1:0] csr_tx_digitalreset;
   wire [LINKWIDTH-1:0] csr_rx_analogreset;
   wire [LINKWIDTH-1:0] csr_rx_digitalreset;
   wire [LINKWIDTH-1:0] csr_phy_loopback_serial;
   wire [LINKWIDTH-1:0] csr_rx_set_locktodata;
   wire [LINKWIDTH-1:0] csr_rx_set_locktoref;   
   wire [LINKWIDTH-1:0] rx_lockedtodata;
   wire [LINKWIDTH-1:0] rx_lockedtoref;   
   
   wire [LINKWIDTH-1:0] rx_is_lockedtodata;
   wire [LINKWIDTH-1:0] rx_is_lockedtoref;   

   wire 		csr_reset_all;
   wire 		csr_reset_rx_digital;
   wire 		csr_reset_tx_digital;
   
   wire 		reset_controller_pll_powerdown;
   wire [LINKWIDTH-1:0] reset_controller_tx_digitalreset;
   wire [LINKWIDTH-1:0] reset_controller_rx_analogreset;         
   wire [LINKWIDTH-1:0] reset_controller_rx_digitalreset;
   wire [LINKWIDTH-1:0] 	reset_controller_tx_ready;
   wire [LINKWIDTH-1:0] 	reset_controller_rx_ready;
   
   wire 		rx_oc_busy;
   
   wire [LINKWIDTH-1:0] rx_framelock_int;   
   wire [LINKWIDTH-1:0] rx_alignval_int;
   
   wire [LINKWIDTH-1:0] rx_crc32err_int;
   wire [LINKWIDTH-1:0] rx_framing_error_int;
   wire [LINKWIDTH-1:0] rx_scrambler_mismatch_int;
   wire [LINKWIDTH-1:0] rx_missing_sync_int;
   
   wire [LINKWIDTH-1:0] pcs_write;
   wire [(LINKWIDTH*32)-1:0] pcs_datain;
   wire [(LINKWIDTH*32)-1:0] pcs_dataout;

   wire [LINKWIDTH-1:0]      enables;
   localparam log_width = log2(LINKWIDTH);
   reg [log_width:0] 	     indir_addr;


   // Start PCS bonding Solution IP logic
   wire [LINKWIDTH-1:0]      tx_burst_en;
   wire [LINKWIDTH-1:0]      tx_fifo_full;
   wire [LINKWIDTH-1:0]      tx_fifo_pfull;
   wire [LINKWIDTH-1:0]      tx_fifo_empty;   
   wire [LINKWIDTH-1:0]      tx_frame;
   wire [LINKWIDTH-1:0]      tx_frame_sync;   

// Calibration busy signals
   wire [LINKWIDTH-1:0]      tx_cal_busy;
   wire [LINKWIDTH-1:0] rx_cal_busy;
   
   
   
   wire r_soft_pbip_rst;	     
   wire tx_force_fill;

assign tx_fifofull = tx_fifo_full;
assign tx_fifopfull = tx_fifo_pfull;

 /////////////////////////////
  // Synchronize tx_digitalreset
  /////////////////////////////
  alt_xcvr_resync #(
    .INIT_VALUE (1)
  ) inst_reconfig_reset_sync (
    .clk    (tx_coreclkin       ),
    .reset  (!reset_controller_tx_ready[0]), // tx_digitalreset from reset controller is just fanout from 1 -> many thats why just connecting one bit is enough
    .d      (1'b0               ),
    .q      (r_soft_pbip_rst   )
  );


   generate
      if (LINKWIDTH > 1)
	begin
	   alt_xcvr_interlaken_soft_pbip
	     #(
	       .LINKWIDTH(LINKWIDTH)
	       ) soft_ip_inst (
			       .clk(tx_coreclkin),
			       .reset(r_soft_pbip_rst),
			       .tx_fifo_full(tx_fifo_full),
			       .tx_fifo_empty(tx_fifo_empty),			       
			       .tx_frame(tx_frame_sync),
			       .tx_burst_en(tx_burst_en),
			       .tx_sync_done(tx_sync_done),
			       .tx_force_fill(tx_force_fill)
			       );
	end // if (LINKWIDTH > 1)
      else
	begin
	   assign tx_sync_done = 1'b1;
	   assign tx_burst_en = 1'b1;
	   assign tx_force_fill = 1'b0;	   
	end
   endgenerate
   
		       
// End PCS bonding soft solution ip logic       
	   
   assign pll_locked = &tx_pll_locked;
   
   

   sv_xcvr_interlaken_native 
     #(
       .CH_INDEX(CH_INDEX),
       .PLEX(PLEX),
       .LINKWIDTH(LINKWIDTH),
       .METALEN (METALEN),     
       .PLL_REFCLK_CNT(PLL_REFCLK_CNT),
       .PLL_REF_FREQ(PLL_REF_FREQ),
       .PLL_REFCLK_SELECT(PLL_REFCLK_SELECT),       
       .PLLS(1),
       .PLL_TYPE(PLL_TYPE),
       .PLL_SELECT(PLL_SELECT),
       .NUM_PLLS(total_plls),
       .DATA_RATE (DATA_RATE),
       .BASE_DATA_RATE(BASE_DATA_RATE),              
       .TX_USE_CORECLK(TX_USE_CORECLK),
       .RX_USE_CORECLK(RX_USE_CORECLK),       
       .ECC_ENABLE        (ECC_ENABLE),
       .MASTER_LANE(0),
       .BONDED_GROUP_SIZE(BONDED_GROUP_SIZE)
       ) bonded_lane_inst
       (
	
	.rx_serial_data(rx_serial_data),
	.pll_ref_clk(pll_ref_clk),
	.tx_datain(tx_datain),
	.tx_ctrlin(tx_ctrlin),
	.tx_crcerr(tx_crcerr),
	.tx_datavalid(tx_datavalid | {LINKWIDTH{tx_force_fill}}),  //wr_en to TX FIFO
	.tx_dataready(tx_dataready),  //~partialfull of TX FIFO
	.pll_locked(tx_pll_locked),
	.rx_is_lockedtodata(rx_lockedtodata),
	.rx_is_lockedtoref(rx_lockedtoref),		
	.tx_serial_data(tx_serial_data),
	.rx_dataout(rx_dataout),
	.rx_datavalid(rx_datavalid),  //rx_datavalid_out from RX FIFO
	.rx_fifopempty(rx_fifopempty),
	.rx_fifofull(rx_fifofull),		       
	.rx_fifopfull(rx_fifopfull),		       
	.rx_dataready(rx_dataready),  // rd_en input to RX FIFO
	.rx_fifoclr(rx_fifoclr),  // fifoclr signal for Rx deskew FIFO
	.rx_ctrlout(rx_ctrlout),
	// renaming 
	// rx_syncout=> rx_block_frame_lock
	//  rx_wordlock => rx_align_val
	//  rx_synclock => rx_frame_lock           	
	.rx_block_frame_lock(rx_block_frame_lock),
	.rx_align_val(rx_align_val),
	.rx_frame_lock(rx_frame_lock),	
	.rx_crc32err(rx_crc32err),
	.rx_framing_error(rx_framing_error),
	.rx_scrambler_mismatch(rx_scrambler_mismatch),
	.rx_missing_sync(rx_missing_sync),		
	.tx_clkout(tx_clkout),
	.rx_clkout(rx_clkout),
	.tx_user_clock(tx_user_clock),		
	.rx_user_clock(rx_user_clock),	
	// Reset and loopback IOs
	.csr_pll_powerdown(csr_pll_powerdown),
	.csr_tx_digitalreset(csr_tx_digitalreset),
	.csr_rx_analogreset(csr_rx_analogreset),
	.csr_rx_digitalreset(csr_rx_digitalreset),
	.csr_phy_loopback_serial(csr_phy_loopback_serial),
	.csr_rx_set_locktodata(csr_rx_set_locktodata),
	.csr_rx_set_locktoref(csr_rx_set_locktoref),		
	.tx_cal_busy(tx_cal_busy),
	.rx_cal_busy(rx_cal_busy),		
        .reconfig_to_xcvr(reconfig_to_xcvr),
        .reconfig_from_xcvr(reconfig_from_xcvr),
	.rx_coreclkin(rx_coreclkin),
	.tx_coreclkin(tx_coreclkin),
	// Expose tx_burst_en, tx_fifo_pfull and tx_frame for PCS Bonding solution IP
	.tx_burst_en(tx_burst_en), // burst_en is input to frema generator and controle the read of the TX FIFO
	.tx_fifo_pfull(tx_fifo_pfull), // fifo partialfull flag
	.tx_fifo_full(tx_fifo_full), // fifo full flag
	.tx_fifo_empty(tx_fifo_empty), // fifo empty flag	
	.tx_frame(tx_frame)        // o/p from the frame generator, "1" at the start of the metaframe
	);


   
   
   function integer log2;
      input integer val;
      begin
	 log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
	    log2 = log2 + 1;
	 end
      end
   endfunction

   /* I am removing this as this code calculates the indir address only when last 2 mgmt_address bits [1:0] are valid and checks that all upper address bits [logwidth:2] is 0, but now we ar chnaging addresing scheme, PCS address will start from 0x200H (byte address eq WORd address will be 0x80 (1000 0000)) so need to check that mgmt_address[7:2] = 100000, no need for logwidth and all
    always @(posedge mgmt_clk) begin
    if (mgmt_address[1+log_width:2] == {log_width{1'b0}} && mgmt_write == 1'b1) begin
    indir_addr <= mgmt_datain[log_width:0];
	end
end
    */

   always @(posedge mgmt_clk) begin
      if (mgmt_address[7:2]== 6'b100000 && mgmt_write == 1'b1) 
	begin
	   indir_addr <= mgmt_datain[log_width:0];
	end
   end   
   
   lpm_decode #(
		.lpm_decodes(LINKWIDTH),
		.lpm_type("LPM_DECODE"),
		.lpm_width(log_width+1)
		) lpm_decode_indirect (
				       .data (indir_addr),
				       .eq (enables)
				       // synopsys translate_off
				       ,.aclr (),.clken (),.clock (),.enable ()
				       // synopsys translate_on
				       );
   

   assign rx_is_lockedtodata = rx_lockedtodata;
   assign rx_is_lockedtoref = rx_lockedtoref;   
   
   
   assign enable_pcs = mgmt_address[7]; //0x200 byte address which is 0x80 word address
   
   assign mgmt_dataout = (!enable_pcs) ? pma_mgmt_dataout: pcs_mgmt_dataout;
   
   
   
   assign pcs_mgmt_dataout = {|temp_pcs_dataout31, |temp_pcs_dataout30, |temp_pcs_dataout29, |temp_pcs_dataout28, 
			      |temp_pcs_dataout27, |temp_pcs_dataout26, |temp_pcs_dataout25, |temp_pcs_dataout24, 
			      |temp_pcs_dataout23, |temp_pcs_dataout22, |temp_pcs_dataout21, |temp_pcs_dataout20, 
			      |temp_pcs_dataout19, |temp_pcs_dataout18, |temp_pcs_dataout17, |temp_pcs_dataout16, 
			      |temp_pcs_dataout15, |temp_pcs_dataout14, |temp_pcs_dataout13, |temp_pcs_dataout12, 
			      |temp_pcs_dataout11, |temp_pcs_dataout10, |temp_pcs_dataout9, |temp_pcs_dataout8, 
			      |temp_pcs_dataout7, |temp_pcs_dataout6, |temp_pcs_dataout5, |temp_pcs_dataout4, 
			      |temp_pcs_dataout3, |temp_pcs_dataout2, |temp_pcs_dataout1, |temp_pcs_dataout0 };

   genvar 		i, j;
   generate
      for (i = 0; i < LINKWIDTH; i = i + 1) begin: pcs_lanes_dataout
	 assign pcs_write[i] = enables[i] & mgmt_write;
	 assign pcs_datain[(i*32)+31:(i*32)] = mgmt_datain;
	 assign temp_pcs_dataout0[i] = pcs_dataout[(i*32)+0] & enables[i];
	 assign temp_pcs_dataout1[i] = pcs_dataout[(i*32)+1] & enables[i];
	 assign temp_pcs_dataout2[i] = pcs_dataout[(i*32)+2] & enables[i];
	 assign temp_pcs_dataout3[i] = pcs_dataout[(i*32)+3] & enables[i];
	 assign temp_pcs_dataout4[i] = pcs_dataout[(i*32)+4] & enables[i];
	 assign temp_pcs_dataout5[i] = pcs_dataout[(i*32)+5] & enables[i];
	 assign temp_pcs_dataout6[i] = pcs_dataout[(i*32)+6] & enables[i];
	 assign temp_pcs_dataout7[i] = pcs_dataout[(i*32)+7] & enables[i];
	 assign temp_pcs_dataout8[i] = pcs_dataout[(i*32)+8] & enables[i];
	 assign temp_pcs_dataout9[i] = pcs_dataout[(i*32)+9] & enables[i];
	 assign temp_pcs_dataout10[i] = pcs_dataout[(i*32)+10] & enables[i];
	 assign temp_pcs_dataout11[i] = pcs_dataout[(i*32)+11] & enables[i];
	 assign temp_pcs_dataout12[i] = pcs_dataout[(i*32)+12] & enables[i];
	 assign temp_pcs_dataout13[i] = pcs_dataout[(i*32)+13] & enables[i];
	 assign temp_pcs_dataout14[i] = pcs_dataout[(i*32)+14] & enables[i];
	 assign temp_pcs_dataout15[i] = pcs_dataout[(i*32)+15] & enables[i];
	 assign temp_pcs_dataout16[i] = pcs_dataout[(i*32)+16] & enables[i];
	 assign temp_pcs_dataout17[i] = pcs_dataout[(i*32)+17] & enables[i];
	 assign temp_pcs_dataout18[i] = pcs_dataout[(i*32)+18] & enables[i];
	 assign temp_pcs_dataout19[i] = pcs_dataout[(i*32)+19] & enables[i];
	 assign temp_pcs_dataout20[i] = pcs_dataout[(i*32)+20] & enables[i];
	 assign temp_pcs_dataout21[i] = pcs_dataout[(i*32)+21] & enables[i];
	 assign temp_pcs_dataout22[i] = pcs_dataout[(i*32)+22] & enables[i];
	 assign temp_pcs_dataout23[i] = pcs_dataout[(i*32)+23] & enables[i];
	 assign temp_pcs_dataout24[i] = pcs_dataout[(i*32)+24] & enables[i];
	 assign temp_pcs_dataout25[i] = pcs_dataout[(i*32)+25] & enables[i];
	 assign temp_pcs_dataout26[i] = pcs_dataout[(i*32)+26] & enables[i];
	 assign temp_pcs_dataout27[i] = pcs_dataout[(i*32)+27] & enables[i];
	 assign temp_pcs_dataout28[i] = pcs_dataout[(i*32)+28] & enables[i];
	 assign temp_pcs_dataout29[i] = pcs_dataout[(i*32)+29] & enables[i];
	 assign temp_pcs_dataout30[i] = pcs_dataout[(i*32)+30] & enables[i];
	 assign temp_pcs_dataout31[i] = pcs_dataout[(i*32)+31] & enables[i];
      end
   endgenerate

   assign  tx_pcs_ready  = &reset_controller_tx_ready;
   assign  rx_pcs_ready  = &reset_controller_rx_ready;
   localparam  RX_PER_CHANNEL = (BONDED_GROUP_SIZE > 1);
   
    altera_xcvr_reset_control
    #(
        .CHANNELS               (LINKWIDTH          ),  // Number of lanes
        .SYNCHRONIZE_RESET      (0              ),  // (0,1) Synchronize the reset input
        .SYNCHRONIZE_PLL_RESET  (0              ),  // (0,1) Use synchronized reset input for PLL powerdown
                                                    // !NOTE! Will prevent PLL merging across reset controllers
                                                    // !NOTE! Requires SYNCHRONIZE_RESET == 1
        // Reset timings
        .SYS_CLK_IN_MHZ         (sys_clk_in_mhz),  // Clock frequency in MHz. Required for reset timers
        .REDUCED_SIM_TIME       (1              ),  // (0,1) 1=Reduced reset timings for simulation
        // PLL options
        .TX_PLL_ENABLE          (TX_ENABLE      ),  // (0,1) Enable TX PLL reset
        .PLLS                   (1              ),  // Number of TX PLLs
        .T_PLL_POWERDOWN        (1000           ),  // pll_powerdown period in ns
        // TX options
        .TX_ENABLE              (TX_ENABLE      ),  // (0,1) Enable TX resets
        .TX_PER_CHANNEL         (0              ),  // (0,1) 1=separate TX reset per channel
        .T_TX_DIGITALRESET      (20             ),  // tx_digitalreset period (after pll_powerdown)
        .T_PLL_LOCK_HYST        (1000              ),  // Amount of hysteresis to add to pll_locked status signal
        // RX options
        .RX_ENABLE              (RX_ENABLE      ),  // (0,1) Enable RX resets
        .RX_PER_CHANNEL         (RX_PER_CHANNEL ),  // (0,1) 1=separate RX reset per channel
        .T_RX_ANALOGRESET       (40             ),  // rx_analogreset period
        .T_RX_DIGITALRESET      (4000           )   // rx_digitalreset period (after rx_is_lockedtodata)
    ) reset_controller (
      // User inputs and outputs
      .clock            (mgmt_clk       ),  // System clock
      .reset            (mgmt_rst ),  // Asynchronous reset
      // Reset signals
      .pll_powerdown    (reset_controller_pll_powerdown   ),  // reset TX PLL
      .tx_analogreset   (/*unused*/                       ),  // reset TX PMA
      .tx_digitalreset  (reset_controller_tx_digitalreset ),  // reset TX PCS
      .rx_analogreset   (reset_controller_rx_analogreset  ),  // reset RX PMA
      .rx_digitalreset  (reset_controller_rx_digitalreset ),  // reset RX PCS
      // Status output
      .tx_ready         (reset_controller_tx_ready        ),  // TX is not in reset
      .rx_ready         (reset_controller_rx_ready        ),  // RX is not in reset
      // Digital reset override inputs (must by synchronous with clock)
      .tx_digitalreset_or({LINKWIDTH{csr_reset_tx_digital}} ), // reset request for tx_digitalreset
      .rx_digitalreset_or({LINKWIDTH{csr_reset_rx_digital}} ), // reset request for rx_digitalreset
      // TX control inputs
      .pll_locked         (pll_locked),  // TX PLL is locked status
      .pll_select         (1'b0                   ),  // Select TX PLL locked signal 
      .tx_cal_busy        (tx_cal_busy            ),  // TX channel calibration status
      .tx_manual          ({LINKWIDTH{1'b1}}          ),  // 1=Manual TX reset mode
      // RX control inputs
      .rx_is_lockedtodata (rx_is_lockedtodata     ),  // RX CDR PLL is locked to data status
      .rx_cal_busy        (rx_cal_busy            ),  // RX channel calibration status
      .rx_manual          ({LINKWIDTH{1'b0}}         ) // 1=Manual RX reset mode
    );

   

   // PMA CSR (Control and status registers) for resets and loopback control
   

   alt_xcvr_csr_common #(
			 .lanes (LINKWIDTH),
			 .plls (total_plls),
			 .rpc (1)
			 )generic_csr
     (
      // user data (avalon-MM formatted) 
      .clk(mgmt_clk),
      .reset(mgmt_rst),
      .address(mgmt_address),
      .read(mgmt_read),
      .readdata (pma_mgmt_dataout),
      .write(mgmt_write),
      .writedata(mgmt_datain),

      // transceiver status inputs to this CSR
      .pll_locked(tx_pll_locked),
      .rx_is_lockedtoref(rx_is_lockedtoref),
      .rx_is_lockedtodata(rx_is_lockedtodata),
      .rx_signaldetect({LINKWIDTH{1'b0}}),
      
      // reset controller outputs
      .reset_controller_tx_ready(tx_pcs_ready),
      .reset_controller_rx_ready(rx_pcs_ready),
      .reset_controller_pll_powerdown(reset_controller_pll_powerdown),
      .reset_controller_tx_digitalreset(reset_controller_tx_digitalreset),
      .reset_controller_rx_analogreset(reset_controller_rx_analogreset),
      .reset_controller_rx_digitalreset(reset_controller_rx_digitalreset),

      // read/write control registers
      // to reset controller
      .csr_reset_tx_digital(csr_reset_tx_digital),
      .csr_reset_rx_digital(csr_reset_rx_digital),
      .csr_reset_all (csr_reset_all),		// power-up to 1 to trigger auto-init sequence
      // to PMA and PCS reset inputs
      .csr_pll_powerdown(csr_pll_powerdown),  	// reset controller or manual
      .csr_tx_digitalreset(csr_tx_digitalreset),	// reset controller or manual
      .csr_rx_analogreset(csr_rx_analogreset), 	// reset controller or manual
      .csr_rx_digitalreset(csr_rx_digitalreset),	// reset controller or manual
      .csr_phy_loopback_serial(csr_phy_loopback_serial),
      .csr_rx_set_locktodata(csr_rx_set_locktodata),
      .csr_rx_set_locktoref(csr_rx_set_locktoref)      
      
      );
   
   
   genvar lanenum;
   generate

      for (lanenum = 0; lanenum < LINKWIDTH; lanenum = lanenum + 1) begin: pcs_lanes


	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_wordlock ( 
							.clk(mgmt_clk),
							.din(rx_align_val[lanenum]),
							.dout(rx_alignval_int[lanenum]),
							.reset_n(!mgmt_rst)
							);
         

	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_synclock ( 
							.clk(mgmt_clk),
							.din(rx_frame_lock[lanenum]),
							.dout(rx_framelock_int[lanenum]),
							.reset_n(!mgmt_rst)
							);


	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_crc32err ( 
							.clk(mgmt_clk),
							.din(rx_crc32err[lanenum]),
							.dout(rx_crc32err_int[lanenum]),
							.reset_n(!mgmt_rst)
							);

	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_framingerr ( 
							  .clk(mgmt_clk),
							  .din(rx_framing_error[lanenum]),
							  .dout(rx_framing_error_int[lanenum]),
							  .reset_n(!mgmt_rst)
							  );	 	 

	 
	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_scrmmismatch ( 
							    .clk(mgmt_clk),
							    .din(rx_scrambler_mismatch[lanenum]),
							    .dout(rx_scrambler_mismatch_int[lanenum]),
							    .reset_n(!mgmt_rst)
							    );


	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_missingsync ( 
							   .clk(mgmt_clk),
							   .din(rx_missing_sync[lanenum]),
							   .dout(rx_missing_sync_int[lanenum]),
							   .reset_n(!mgmt_rst)
							   );	 


							   

	 // synchronizer for tx_frame
	 altera_std_synchronizer #(
				   .depth (sync_depth)
				   ) stdsync_txframe ( 
							.clk(tx_coreclkin),
							.din(tx_frame[lanenum]),
							.dout(tx_frame_sync[lanenum]),
							.reset_n(!r_soft_pbip_rst)
							);


	 
	 
	 wire [95:0] mgmt_signals_in;
	 wire [0:95] mgmt_signals_out;
	 assign mgmt_signals_out = 96'd0;

	 assign mgmt_signals_in[95:0] = {
					 32'b0,
					 2'b00,
					 rx_missing_sync_int[lanenum],
					 rx_scrambler_mismatch_int[lanenum],
					 rx_crc32err_int[lanenum],
					 rx_framing_error_int[lanenum],
					 rx_framelock_int[lanenum],					 
					 rx_alignval_int[lanenum],
					 24'b0,		
					 32'b0
					 };

	 

	 
	 alt_xcvr_interlaken_amm_slave #(3,2,32) mgmt_slave (
							     .clk (mgmt_clk),
							     .reset (mgmt_rst),
							     .write (pcs_write[lanenum]),
							     .address (mgmt_address[1:0]),
							     .datain (pcs_datain[(32*lanenum)+31:(32*lanenum)]),
							     .dataout (pcs_dataout[(32*lanenum)+31:(32*lanenum)]),
							     .busin (mgmt_signals_in),
							     .busout (mgmt_signals_out)
							     );
      end // block: pcs_lanes
   endgenerate


   
   // generate waitrequest for 'top' channel
   altera_wait_generate top_wait (
				  .rst(mgmt_rst),
				  .clk(mgmt_clk),
				  .launch_signal(mgmt_read),
				  .wait_req(mgmt_waitrequest)
				  );
   



   
endmodule // alt_interlaken_pcs_sv


