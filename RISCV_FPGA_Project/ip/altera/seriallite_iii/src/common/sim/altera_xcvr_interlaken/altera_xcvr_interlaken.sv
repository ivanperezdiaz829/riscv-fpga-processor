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

import altera_xcvr_functions::*;  // for get_interlaken_reconfig_width functions


module altera_xcvr_interlaken 
#(
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
  parameter BONDED_GROUP_SIZE = 1,  
  parameter     ECC_ENABLE        = 0
  ) (
     // PMA and PCS management signals : 
     // PMA Address space will be till 1FFh Bye address  and PCS address space from 0X200H Byte address (0x80 H word address)     
    input  wire        phy_mgmt_clk,            //         mgmt_clk.clk
    input  wire        phy_mgmt_clk_reset,    //     mgmt_clk_rst.reset_n
    input  wire        phy_mgmt_read,           //         phy_mgmt.read
    input  wire        phy_mgmt_write,          //                 .write
    input  wire [8:0]  phy_mgmt_address,        //                 .address
    input  wire [31:0] phy_mgmt_writedata,      //                 .writedata
    output wire [31:0] phy_mgmt_readdata,       //                 .readdata
    output wire        phy_mgmt_waitrequest,    //                 .waitrequest

    input 	       pll_ref_clk,
    output [LINKWIDTH-1:0] tx_serial_data,
    output 		   tx_user_clkout,
    input [(LINKWIDTH*64)-1:0] tx_parallel_data,
    input [LINKWIDTH-1:0]      tx_ctrlin,
    input [LINKWIDTH-1:0]      tx_crcerr,
    //  wr_en of TX_FIFO   
    input [LINKWIDTH-1:0]      tx_datavalid,
      // Full and pfull flags of TX FIFO
    output [LINKWIDTH-1:0] 	tx_fifofull,
    output [LINKWIDTH-1:0] 	tx_fifopfull,   

    output [LINKWIDTH-1:0]     tx_datain_bp,
    output 		       tx_ready,
    output                     pll_locked,     
//    output [LINKWIDTH-1:0]     pll_locked,     
    
    input [LINKWIDTH-1:0]      rx_serial_data,
    output 		       rx_user_clkout,

    // clear signal for RX FIFO to flush the fifo
    input [LINKWIDTH-1:0]      rx_fifo_clr,
    output [(LINKWIDTH*64)-1:0] rx_parallel_data,
    output [LINKWIDTH-1:0] 	rx_datavalid,
    input [LINKWIDTH-1:0] 	rx_dataout_bp,
    output 			rx_ready,
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
    
    // Adding following for Deskew functionality   
    input 			rx_coreclkin,
    input 			tx_coreclkin,
    output [LINKWIDTH-1:0] 	rx_clkout,
    output [LINKWIDTH-1:0] 	tx_clkout,
    
    // For PCS Bonding solution IP
    output tx_sync_done,	

    //Reconfig 
    input   wire [get_interlaken_reconfig_to_width  ("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_to_xcvr,
    output  wire [get_interlaken_reconfig_from_width("Stratix V",PLEX,BONDED_GROUP_SIZE,LINKWIDTH)-1:0] reconfig_from_xcvr 

     );


   localparam CH_INDEX = 1;
   // Decode phy_mgmt_address[8:0] from user. MSB = 0 => CSR. MSB = 1 => Reconfig
   wire [7:0]  phy_mgmt_address_decoded;

   assign phy_mgmt_address_decoded = (phy_mgmt_address[8] == 1'b0) ? phy_mgmt_address[7:0] : 8'b0;
   
   
   
   sv_xcvr_interlaken_nr #(
			   .CH_INDEX(CH_INDEX),
			   .PLEX(PLEX),
			   .LINKWIDTH(LINKWIDTH),
			   .METALEN(METALEN),
			   .EXTRA_SIGS(EXTRA_SIGS),
			   .PLL_REFCLK_CNT(PLL_REFCLK_CNT),
			   .PLL_REF_FREQ(PLL_REF_FREQ),
			   .PLL_REFCLK_SELECT(PLL_REFCLK_SELECT),       
			   .PLLS(1),
			   .PLL_TYPE(PLL_TYPE),
			   .PLL_SELECT(PLL_SELECT),
			   .DATA_RATE (DATA_RATE),
			   .BASE_DATA_RATE(BASE_DATA_RATE),              
			   .sys_clk_in_mhz(sys_clk_in_mhz),
			   .TX_USE_CORECLK(TX_USE_CORECLK),
			   .RX_USE_CORECLK(RX_USE_CORECLK),
			   .BONDED_GROUP_SIZE(BONDED_GROUP_SIZE),
                           .ECC_ENABLE        (ECC_ENABLE)

			   ) sv_ilk_inst
     (
      .mgmt_clk(phy_mgmt_clk),
      .mgmt_rst(phy_mgmt_clk_reset),
      .mgmt_read	 (phy_mgmt_read),          	 //         phy_mgmt.read
      .mgmt_write	(phy_mgmt_write),         	 //                 .write
      .mgmt_address	(phy_mgmt_address_decoded),       	 //                 .address
      .mgmt_datain	(phy_mgmt_writedata),     	 //                 .writedata
      .mgmt_dataout	(phy_mgmt_readdata),      	 //                 .readdata
      .mgmt_waitrequest  (phy_mgmt_waitrequest),   	 //                 .waitrequest
      
      .pll_ref_clk(pll_ref_clk),
      .tx_coreclkin(tx_coreclkin),
      .rx_coreclkin(rx_coreclkin),

      .tx_serial_data(tx_serial_data), // output - tx_dataout
      .tx_user_clock(tx_user_clkout), // output : provide this clock if user is not selecting tx_coreclk input
      .tx_datain(tx_parallel_data),   // input -tx_datain
      .tx_ctrlin(tx_ctrlin),         // input 
      .tx_crcerr(tx_crcerr),         // input 
      .tx_datavalid(tx_datavalid),   // input : wr_en of TX FIFO
      .tx_fifofull(tx_fifofull),
      .tx_fifopfull(tx_fifopfull),
      .tx_dataready(tx_datain_bp),   //output from TX FIFO,back pressure signal (connected to ~partailfull of TX FIFO), this signal tells MAC that TX PCS is ready and start sending data
      .tx_pcs_ready(tx_ready),      // When tx PCS is ready (out of reset)
      .pll_locked(pll_locked),      // when all lane tx_plls are locked
      .tx_clkout(tx_clkout),

      .rx_serial_data (rx_serial_data), // input - rx_datain
      .rx_user_clock(rx_user_clkout),  // output - provide this clock if user is not selecting rx_coreclk input
      .rx_fifoclr(rx_fifo_clr),       // input - RX FIFO clear signal
      .rx_dataout(rx_parallel_data), // output - rx_dataout
      .rx_datavalid(rx_datavalid),  // Output : rx_datavalid_out from RX FIFO
      .rx_dataready(rx_dataout_bp), // input - RX back pressure signal rd_en of RX FIFO
      .rx_pcs_ready(rx_ready),  // output - rx_ready when RX is out of reset
      .rx_fifofull(rx_fifofull), //output RX FIFO full flag
      .rx_fifopfull(rx_fifopfull), //output RX FIFO pfull flag
      .rx_fifopempty(rx_fifopempty), // output : RX FIFO partialempty flag
      .rx_ctrlout(rx_ctrlout), // output - indicates control or data
      // renaming 
      // rx_syncout=> rx_block_frame_lock
      //  rx_wordlock => rx_align_val
      //  rx_synclock => rx_frame_lock                 
      .rx_block_frame_lock(rx_block_frame_lock), // output
      .rx_align_val(rx_align_val), // output - "1" when first alignmnet pattern is found, connected to rd_align_val of RX FIFO
      .rx_frame_lock(rx_frame_lock), // output - RX Frame lock from frame synchronizer, when 4 sync words are found

      .rx_crc32err(rx_crc32err), // output - CRC32 error from CRC checker
      .rx_clkout(rx_clkout),
      .reconfig_to_xcvr(reconfig_to_xcvr),
      .reconfig_from_xcvr(reconfig_from_xcvr),
      
      // Following port for PCS Bonding solution IP
      // This port to indicate MAC that TX side bonding is done
      .tx_sync_done(tx_sync_done)
      
      
      );
   

endmodule // altera_xcvr_interlaken

