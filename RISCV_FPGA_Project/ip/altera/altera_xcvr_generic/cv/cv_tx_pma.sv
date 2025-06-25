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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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

// This block instantiates a single channel or a number of bonded
// channels. The channel numbers are assigned sequentially starting from
// the channel_number specifical as a parameter
// 
// Key parameters:
// 
// bonded_lanes = specifies the number of lanes to produce. If bonded_lanes == 1,
//                only a single chann is produced of type "SINGLE_CHANNEL". 
//                If bonded_lanes > 1, then look at the value of the bonding_master_lane
//                and bonding_master_only parameters
//
//
// bonding_master_ch_number = uint, must be in the range [channel_number : channel_number + bonded_lanes - 1]
//                 Indicates that channel number that must be the master channel.
//                 All other lanes, with the exception of the master will be of SLAVE_CHANNEL type
//                 There are two scenarious possible:
//                 (1) If the bonding_master_only parameter is set to "true"; A master lane
//                     of type "MASTER_ONLY" will be instantiated.
//
//                 (2) If the bonding_master_only parameter is set to "false"; A master lane
//                     of type "MASTER_SINGLE_CHANNEL" will be instantiated.
//
// bonding_master_only = "true","false", Indicates the lane indicated by bonding_master_ch_number
//                  should by of type "MASTER_ONLY" ("true"), or of type "MASTER_SINGLE_CHANNEL" ("false").
//
// channel_number = uint, starting channel number. This module will instantiate channels and will label them
//                  consequitively from (channel_number) to (channnel_number + bonded_lanes - 1)
//


`timescale 1ps/1ps
module cv_tx_pma #(
  parameter bonded_lanes = 1,
  parameter bonding_master_ch_num = 0,
  parameter bonding_master_only = "false",

  parameter data_rate = "0 ps",

  parameter mode = 8,
  parameter channel_number = 0,
  parameter ser_loopback = "false",
  parameter auto_negotiation = "false",
  parameter plls = 1,
  parameter pll_sel = 0,
  parameter pclksel = "local_pclk",
  parameter ht_delay_sel = "false",
  parameter rx_det_pdb = "true",
  parameter tx_clk_div        = 1,                // (1,2,4,8)
  parameter pcie_rst          = "NORMAL_RESET",
  parameter fref_vco_bypass   = "NORMAL_OPERATION"
) ( 
  //input port for aux
  input [bonded_lanes - 1 : 0]      calclk,
  //input port for buf
  input [bonded_lanes * 20 - 1 : 0] datain,
  input [bonded_lanes - 1 : 0]      txelecidl,
  input                             rxdetclk,
  input [bonded_lanes - 1 : 0]      txdetrx,
  
  //output port for buf
  output  [bonded_lanes - 1 : 0]    dataout,
  output  [bonded_lanes - 1 : 0]    rxdetectvalid,
  output  [bonded_lanes - 1 : 0]    rxfound,
  
  //input ports for ser
  input                             rstn,
  input   [bonded_lanes - 1 : 0]    seriallpbken,
  
  //output ports for ser
  output  [bonded_lanes - 1 : 0]    clkdivtx,  
  output  [bonded_lanes - 1 : 0]    seriallpbkout,

  //input ports for cgb
  input   [plls - 1 : 0]            clk,              // High-speed serial clocks from PLLs
  input                             pciesw,           // to the master channel
  input                             pcsrstn,
  input                             fref,

  //output ports for cgb
  output  [bonded_lanes-1 : 0]  pcieswdone,       // from the master channel

  //input   [bonded_lanes-1:0 ]       avmmrstn,         // one for each lane
  //input   [bonded_lanes-1:0 ]       avmmclk,          // one for each lane
  //input   [bonded_lanes-1:0 ]       avmmwrite,        // one for each lane
  //input   [bonded_lanes-1:0 ]       avmmread,         // one for each lane
  //input   [(bonded_lanes*2)-1:0 ]   avmmbyteen,       // two for each lane
  //input   [(bonded_lanes*11)-1:0 ]  avmmaddress,      // 11 for each lane
  //input   [(bonded_lanes*16)-1:0 ]  avmmwritedata,    // 16 for each lane
  //output  [(bonded_lanes*16)-1:0 ]  avmmreaddata_cgb, // CGB readdata
  //output  [(bonded_lanes*16)-1:0 ]  avmmreaddata_ser, // SER readdata
  //output  [(bonded_lanes*16)-1:0 ]  avmmreaddata_buf, // BUF readdata
  //output  [bonded_lanes-1:0 ]       blockselect_cgb,  // CGB blockselect
  //output  [bonded_lanes-1:0 ]       blockselect_ser,  // SER blockselect
  //output  [bonded_lanes-1:0 ]       blockselect_buf,  // BUF blockselect
  
  input   [bonded_lanes-1:0 ]       vrlpbkp,
  input   [bonded_lanes-1:0 ]       vrlpbkn
);

  genvar i;                                


  wire        cpulse_from_cgb;
  wire        hclk_from_cgb;
  wire        lfclk_from_cgb;
  wire  [2:0] pclk_from_cgb;
  wire        dataout_from_ser;

  wire        wire_hfclkp;
  wire        wire_lfclkp;
  wire        wire_cpulse;
  wire  [2:0] wire_pclk;
  wire  [bonded_lanes*80-1:0]      dadtain_padded;
  
  generate 
  if (bonded_lanes > 1)
  begin
    for(i = 0; i < bonded_lanes; i = i + 1) 
    begin: ch
    
      assign dadtain_padded[(i+1)*80 - 1 : i*80] = {60'b0 , datain[(i+1)*20 - 1 : i*20]};
      /// ######### MASTER ONLY CHANNEL
      if (i == bonding_master_ch_num && bonding_master_only == "true")
      begin: ma

        cv_tx_pma_ch #(
            .mode(mode),
            .channel_number(bonding_master_ch_num),
            .auto_negotiation(auto_negotiation),
            .plls(plls),
            .pll_sel(pll_sel),
            .ser_loopback(ser_loopback),
            .ht_delay_sel(ht_delay_sel),
            .tx_pma_type("MASTER_ONLY"),
            .data_rate(data_rate),
            .rx_det_pdb(rx_det_pdb),
            .tx_clk_div(tx_clk_div),
            .pcie_rst(pcie_rst),
            .fref_vco_bypass(fref_vco_bypass)
          ) mc ( 
          //input port for aux
          .calclk(calclk[i]),
          //input port for buf
          .datain(80'b0),
          .txelecidl(1'b0),
          .rxdetclk(1'b0),
          .txdetrx(1'b0),
        
          //output port for buf
          .dataout(),
          .rxdetectvalid(),
          .rxfound(),
        
          //input ports for ser
          .rstn(rstn),
          .seriallpbken(seriallpbken[i]),
        
          //output ports for ser
          .clkdivtx(clkdivtx[i]),
          .seriallpbkout(),
        
          //input ports for cgb
          .clk(clk),
          .pciesw(pciesw),
          .pcsrstn(pcsrstn),
          .fref(fref),

          // bonding clock inputs from master CGB
          .cpulsein(1'b0),
          .hfclkpin(1'b0),
          .lfclkpin(1'b0),
          .pclkin(3'b0),
        
          //output ports for cgb
          .pcieswdone(pcieswdone[i]),

          //
          .hfclkpout(wire_hfclkp),
          .lfclkpout(wire_lfclkp),
          .cpulseout(wire_cpulse),
          .pclkout(wire_pclk),
          // Avalon-MM interface
          //.avmmrstn         (avmmrstn     [i]           ),
          //.avmmclk          (avmmclk      [i]           ),
          //.avmmwrite        (avmmwrite    [i]           ),
          //.avmmread         (avmmread     [i]           ),
          //.avmmbyteen       (avmmbyteen   [i*2+:2]      ),
          //.avmmaddress      (avmmaddress  [i*11+:11]    ),
          //.avmmwritedata    (avmmwritedata[i*16+:16]    ),
          //.avmmreaddata_cgb (avmmreaddata_cgb[i*16+:16] ),  // CGB readdata
          //.avmmreaddata_ser (avmmreaddata_ser[i*16+:16] ),  // SER readdata
          //.avmmreaddata_buf (avmmreaddata_buf[i*16+:16] ),  // BUF readdata
          //.blockselect_cgb  (blockselect_cgb[i]         ),  // CGB blockselect
          //.blockselect_ser  (blockselect_ser[i]         ),  // SER blockselect
          //.blockselect_buf  (blockselect_buf[i]         ),  // BUF blockselect
          
          .vrlpbkp(vrlpbkp[i]),
          .vrlpbkn(vrlpbkn[i])
          );
      end // if (i == bonding_master_ch_num && bonding_master_only == "true")
      /// ######### MASTER CHANNEL
      else if(i == bonding_master_ch_num)
      begin: ma_ch

        cv_tx_pma_ch #(
            .mode(mode),
            .channel_number(channel_number + i),
            .auto_negotiation(auto_negotiation),
            .plls(plls),
            .pll_sel(pll_sel),
            .ser_loopback(ser_loopback),
            .ht_delay_sel(ht_delay_sel),
            .tx_pma_type("MASTER_SINGLE_CHANNEL"),
            .data_rate(data_rate),
            .rx_det_pdb(rx_det_pdb),
            .tx_clk_div(tx_clk_div),
            .pcie_rst(pcie_rst),
            .fref_vco_bypass(fref_vco_bypass)
          ) mc ( 
            //input port for aux
            .calclk(calclk[i]),
            //input port for buf
            .datain(dadtain_padded[(i+1)*80 - 1 : i*80]),
            .txelecidl(txelecidl[i]),
            .rxdetclk(rxdetclk),
            .txdetrx(txdetrx[i]),
  
            //output port for buf
            .dataout(dataout[i]),
            .rxdetectvalid(rxdetectvalid[i]),
            .rxfound(rxfound[i]),
  
            //input ports for ser
            .rstn(rstn),
            .seriallpbken(seriallpbken[i]),
  
            //output ports for ser
            .clkdivtx(clkdivtx[i]),
            .seriallpbkout(seriallpbkout[i]),
  
            //input ports for cgb
            .clk(clk),
            .pciesw(pciesw),
            .pcsrstn(pcsrstn),
            .fref(fref),

            // bonding clock inputs from master CGB
            .cpulsein(1'b0),
            .hfclkpin(1'b0),
            .lfclkpin(1'b0),
            .pclkin(3'b0),
  
            //output ports for cgb
            .pcieswdone(pcieswdone[i]),

            //
            .hfclkpout(wire_hfclkp),
            .lfclkpout(wire_lfclkp),
            .cpulseout(wire_cpulse),
            .pclkout(wire_pclk),

            //.avmmrstn         (avmmrstn     [i]           ),
            //.avmmclk          (avmmclk      [i]           ),
            //.avmmwrite        (avmmwrite    [i]           ),
            //.avmmread         (avmmread     [i]           ),
            //.avmmbyteen       (avmmbyteen   [i*2+:2]      ),
            //.avmmaddress      (avmmaddress  [i*11+:11]    ),
            //.avmmwritedata    (avmmwritedata[i*16+:16]    ),
            //.avmmreaddata_cgb (avmmreaddata_cgb[i*16+:16] ),  // CGB readdata
            //.avmmreaddata_ser (avmmreaddata_ser[i*16+:16] ),  // SER readdata
            //.avmmreaddata_buf (avmmreaddata_buf[i*16+:16] ),  // BUF readdata
            //.blockselect_cgb  (blockselect_cgb[i]         ),  // CGB blockselect
            //.blockselect_ser  (blockselect_ser[i]         ),  // SER blockselect
            //.blockselect_buf  (blockselect_buf[i]         ),  // BUF blockselect
            
            .vrlpbkp(vrlpbkp[i]),
            .vrlpbkn(vrlpbkn[i])
          );

      end // if(i == bonding_master_ch_num)
      else  //######### SLAVE CHANNEL
      begin: ch

        cv_tx_pma_ch #(
            .mode(mode),
            .channel_number(channel_number + i),
            .auto_negotiation("false"),
            .plls(plls),
            .pll_sel(pll_sel),
            .ser_loopback(ser_loopback),
            .ht_delay_sel(ht_delay_sel),
            .tx_pma_type("SLAVE_CHANNEL"),
            .data_rate(data_rate),
            .rx_det_pdb(rx_det_pdb),
            .tx_clk_div(tx_clk_div),
            .pcie_rst(pcie_rst),
            .fref_vco_bypass(fref_vco_bypass)
          ) c ( 
          //input port for aux
          .calclk(calclk[i]),
          //input port for buf
          .datain(dadtain_padded[(i+1)*80 - 1 : i*80]),
          .txelecidl(txelecidl[i]),
          .rxdetclk(rxdetclk),
          .txdetrx(txdetrx[i]),
  
          //output port for buf
          .dataout(dataout[i]),
          .rxdetectvalid(rxdetectvalid[i]),
          .rxfound(rxfound[i]),
  
          //input ports for ser
          .rstn(rstn),
          .seriallpbken(seriallpbken[i]),
  
          //output ports for ser
          .clkdivtx(clkdivtx[i]),
          .seriallpbkout(seriallpbkout[i]),
  
          //input ports for cgb
          .clk(clk),
          .pciesw(1'b0),
          .pcsrstn(pcsrstn),
          .fref(fref),

          // bonding clock inputs from master CGB
          .cpulsein(wire_cpulse),
          .hfclkpin(wire_hfclkp),
          .lfclkpin(wire_lfclkp),
          .pclkin(wire_pclk),
  
          //output ports for cgb
          .pcieswdone(pcieswdone[i]),

          //
          .hfclkpout(),
          .lfclkpout(),
          .cpulseout(),
          .pclkout(),

          //.avmmrstn         (avmmrstn     [i]           ),
          //.avmmclk          (avmmclk      [i]           ),
          //.avmmwrite        (avmmwrite    [i]           ),
          //.avmmread         (avmmread     [i]           ),
          //.avmmbyteen       (avmmbyteen   [i*2+:2]      ),
          //.avmmaddress      (avmmaddress  [i*11+:11]    ),
          //.avmmwritedata    (avmmwritedata[i*16+:16]    ),
          //.avmmreaddata_cgb (avmmreaddata_cgb[i*16+:16] ),  // CGB readdata
          //.avmmreaddata_ser (avmmreaddata_ser[i*16+:16] ),  // SER readdata
          //.avmmreaddata_buf (avmmreaddata_buf[i*16+:16] ),  // BUF readdata
          //.blockselect_cgb  (blockselect_cgb[i]         ),  // CGB blockselect
          //.blockselect_ser  (blockselect_ser[i]         ),  // SER blockselect
          //.blockselect_buf  (blockselect_buf[i]         ),   // BUF blockselect
          .vrlpbkp(vrlpbkp[i]),
          .vrlpbkn(vrlpbkn[i])
        );
      end // Slave channel only instantiation
    end // for (i)
  end // if (bonded_lanes > 1)
  else  //######### PRODUCE ONLY A SINGLE LANE
  begin
    assign dadtain_padded = {60'b0 , datain};
    cv_tx_pma_ch #(
        .mode(mode),
        .channel_number(channel_number),
        .auto_negotiation(auto_negotiation),
        .plls(plls),
        .pll_sel(pll_sel),
        .ser_loopback(ser_loopback),
        .ht_delay_sel(ht_delay_sel),
        .tx_pma_type("SINGLE_CHANNEL"),
        .data_rate(data_rate),
        .rx_det_pdb(rx_det_pdb),
        .tx_clk_div(tx_clk_div),
        .pcie_rst(pcie_rst),
        .fref_vco_bypass(fref_vco_bypass)
      ) sc ( 
      //input port for aux
      .calclk(calclk[0]),
      //input port for buf
      .datain(dadtain_padded[80 - 1 : 0]),
      .txelecidl(txelecidl[0]),
      .rxdetclk(rxdetclk),
      .txdetrx(txdetrx[0]),
    
      //output port for buf
      .dataout(dataout[0]),
      .rxdetectvalid(rxdetectvalid[0]),
      .rxfound(rxfound[0]),
    
      //input ports for ser
      .rstn(rstn),
      .seriallpbken(seriallpbken[0]),
    
      //output ports for ser
      .clkdivtx(clkdivtx[0]),
      .seriallpbkout(seriallpbkout[0]),
    
      //input ports for cgb
      .clk(clk),
      .pciesw(pciesw),
      .pcsrstn(pcsrstn),
      .fref(fref),

      // bonding clock inputs from master CGB
      .cpulsein(1'b0),
      .hfclkpin(1'b0),
      .lfclkpin(1'b0),
      .pclkin(3'b0),
    
      //output ports for cgb
      .pcieswdone(pcieswdone),

      //
      .hfclkpout(wire_hfclkp),
      .lfclkpout(wire_lfclkp),
      .cpulseout(wire_cpulse),
      .pclkout(wire_pclk),

      //.avmmrstn         (avmmrstn         ),
      //.avmmclk          (avmmclk          ),
      //.avmmwrite        (avmmwrite        ),
      //.avmmread         (avmmread         ),
      //.avmmbyteen       (avmmbyteen       ),
      //.avmmaddress      (avmmaddress      ),
      //.avmmwritedata    (avmmwritedata    ),
      //.avmmreaddata_cgb (avmmreaddata_cgb ),  // CGB readdata
      //.avmmreaddata_ser (avmmreaddata_ser ),  // SER readdata
      //.avmmreaddata_buf (avmmreaddata_buf ),  // BUF readdata
      //.blockselect_cgb  (blockselect_cgb  ),  // CGB blockselect
      //.blockselect_ser  (blockselect_ser  ),  // SER blockselect
      //.blockselect_buf  (blockselect_buf  ),  // BUF blockselect
      
      .vrlpbkp(vrlpbkp[0]),
      .vrlpbkn(vrlpbkn[0])
      );

  end // if (bonded_lanes == 1)
endgenerate
endmodule

    
