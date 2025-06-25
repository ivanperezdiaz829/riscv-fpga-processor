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


`timescale 1ps/1ps
module cv_rx_pma #(
  parameter bonded_lanes                  = 1,
  parameter bonding_master_ch_num         = 0,
  parameter bonding_master_only           = "false",
     
  parameter mode                          = 8,
  //parameter serial_loopback               = "lpbkp_dis",
  parameter sdclk_enable                  = "true",
  parameter deser_enable_bit_slip         = "false",
  parameter channel_number                = 0,
  parameter auto_negotiation              = "false",
  parameter cdr_reference_clock_frequency = "100 Mhz",
  parameter cdr_output_clock_frequency    = "2500 Mhz",
  parameter rxpll_pd_bw_ctrl              = 300,
  parameter sd_on                         = 16
) ( 
  input   [bonded_lanes - 1: 0]   calclk,

  // Resets
  input   [bonded_lanes - 1: 0]   rstn,
  input   [bonded_lanes - 1: 0]   crurstn,

  // BUF signals
  input   [bonded_lanes - 1: 0]   datain,
  input   [bonded_lanes - 1: 0]   seriallpbkin,
  input   [bonded_lanes - 1: 0]   seriallpbken,
  input   [bonded_lanes - 1: 0]   bslip,
  //input   [bonded_lanes - 1: 0]   adaptcapture,
  //input   [bonded_lanes - 1: 0]   adcestandby,
  input   [bonded_lanes - 1: 0]   hardoccalen,
  //input   [bonded_lanes*5-1: 0]   eyemonitor,
  //output  [bonded_lanes - 1: 0]   adaptdone,
  //output  [bonded_lanes - 1: 0]   hardoccaldone,
  output  [bonded_lanes - 1: 0]   sd,

  // CDR signals
  input   [bonded_lanes - 1: 0]   cdr_ref_clk,
  input   [bonded_lanes  -1:0]   pciesw,
  input   [bonded_lanes - 1: 0]   ltr,
  input   [bonded_lanes - 1: 0]   ltd,
  input   [bonded_lanes - 1: 0]   freqlock,
  input   [bonded_lanes - 1: 0]   earlyeios,
  output  [bonded_lanes - 1: 0]   clklow,
  output  [bonded_lanes - 1: 0]   fref,
  output  [bonded_lanes - 1: 0]   rx_is_lockedtodata,
  output  [bonded_lanes - 1: 0]   rx_is_lockedtoref,

  // DESER signals
  output  [bonded_lanes - 1: 0]   clkdivrx,
  output  [bonded_lanes*20-1:0]   dout,

  // AVMM interface signals
  //input   [bonded_lanes - 1: 0]   avmmrstn,         // one for each lane
  //input   [bonded_lanes - 1: 0]   avmmclk,          // one for each lane
  //input   [bonded_lanes - 1: 0]   avmmwrite,        // one for each lane
  //input   [bonded_lanes - 1: 0]   avmmread,         // one for each lane
  //input   [bonded_lanes*2-1: 0]   avmmbyteen,       // two for each lane
  //input   [bonded_lanes*11-1:0]   avmmaddress,      // 11 for each lane
  //input   [bonded_lanes*16-1:0]   avmmwritedata,    // 16 for each lane
  //output  [bonded_lanes*16-1:0]   avmmreaddata_ser, // SER readdata
  //output  [bonded_lanes*16-1:0]   avmmreaddata_buf, // BUF readdata
  //output  [bonded_lanes*16-1:0]   avmmreaddata_cdr, // CDR readdata
  //output  [bonded_lanes*16-1:0]   avmmreaddata_mux, // CDR MUX readdata
  //output  [bonded_lanes - 1 :0]   blockselect_ser,  // SER blockselect
  //output  [bonded_lanes - 1 :0]   blockselect_buf,  // BUF blockselect
  //output  [bonded_lanes - 1 :0]   blockselect_cdr,  // CDR blockselect
  //output  [bonded_lanes - 1 :0]   blockselect_mux,  // CDR MUX blockselect
  
  output  [bonded_lanes - 1 :0]   rdlpbkp
  //output  [bonded_lanes - 1 :0]   rdlpbkn
);

  genvar i;

  generate 
  for(i = 0; i < bonded_lanes; i = i + 1) 
  begin: ch

    if((i != bonding_master_ch_num) || (bonding_master_only == "false"))
    begin: ch
      wire  wire_dataout_to_cdr;
      wire  wire_refclk_to_cdr;
      wire  wire_cdr_to_deser_clk;
      wire  wire_cdr_to_deser_clk_270;
      wire  wire_pciel;
      wire  wire_pciem;
      wire  wire_dodd;
      wire  wire_deven;
      wire  wire_clkdivrxrx;
      wire  nonuserfrompmaux;
  
      cyclonev_hssi_pma_aux #(
        .continuous_calibration ("true")
      ) rx_pma_aux (
        .calpdb       (1'b1                 ),
        .calclk       (calclk           [i] ),
        .testcntl     (/*unused*/           ),
        .refiqclk     (/*unused*/           ),
        .nonusertoio  (nonuserfrompmaux     ),
        .zrxtx50      (/*unused*/           )
      ); 

      cyclonev_hssi_pma_rx_buf #(
        .channel_number   (channel_number   ),
        //.serial_loopback  (serial_loopback  )
        .sd_on            (sd_on            )
      ) rx_pma_buf (
        .datain           (datain                 [i] ),
        .rstn             (rstn                   [i] ),
        .lpbkp            (seriallpbkin           [i] ),
        .slpbk            (seriallpbken           [i] ),
        .dataout          (wire_dataout_to_cdr        ),
        .sd               (sd                     [i] ),
        .ck0sigdet        (wire_clkdivrxrx            ), // the signal detect clock is supplied by the deserializer
        .nonuserfrompmaux (nonuserfrompmaux           ),
        //
        //.adaptcapture     (adaptcapture           [i] ),
        //.adcestandby      (adcestandby            [i] ),
        .hardoccalen      (hardoccalen            [i] ),
        //
        //.adaptdone        (adaptdone              [i] ),
        //.hardoccaldone    (hardoccaldone          [i] ),
        //.eyemonitor       (eyemonitor      [i* 5+: 5] ),

        //.avmmrstn         (avmmrstn               [i] ),
        //.avmmclk          (avmmclk                [i] ),
        //.avmmwrite        (avmmwrite              [i] ),
        //.avmmread         (avmmread               [i] ),
        //.avmmbyteen       (avmmbyteen      [i* 2+: 2] ),
        //.avmmaddress      (avmmaddress     [i*11+:11] ),
        //.avmmwritedata    (avmmwritedata   [i*16+:16] ),
        //.avmmreaddata     (avmmreaddata_buf[i*16+:16] ),
        //.blockselect      (blockselect_buf        [i] ),

        //.voplp            (/*unused*/),
        //.vonlp            (/*unused*/),
        .rdlpbkp          (rdlpbkp                [i])
        //.lpbkn            (/*unused*/),
        //.rxrefclk         (/*unused*/),
        //.rdlpbkn          (rdlpbkn                [i])
        );

      cyclonev_channel_pll #(
        .reference_clock_frequency(cdr_reference_clock_frequency),
        .pcie_freq_control        ((cdr_reference_clock_frequency=="125 MHz") ? "pcie_125mhz":"pcie_100mhz"),
        .output_clock_frequency   (cdr_output_clock_frequency   ),
        .powerdown                ("false"                      ),
        .rxpll_pd_bw_ctrl         (rxpll_pd_bw_ctrl             )
      ) rx_cdr (
        .crurstb      (crurstn                  [i] ),  //check the correct reset signal
        .ltr          (ltr                      [i] ),  // receive_pma -> m_locktorefout
        .rxp          (wire_dataout_to_cdr          ),
        .refclk       (wire_refclk_to_cdr           ),
        .ltd          (~ltd                     [i] ),  // active low
        .rstn         (rstn                     [i] ),  //check the correct reset signal
        .sd           (sd                       [i] ),  // check 
        .clk90bdes    (wire_cdr_to_deser_clk        ),
        .clk270bdes   (wire_cdr_to_deser_clk_270    ),
        .clkcdr       (/*unused*/                   ),
        .clklow       (clklow                   [i] ),
        .fref         (fref                     [i] ),
        .dodd         (wire_dodd                    ),
        .deven        (wire_deven                   ),
        .pfdmodelock  (rx_is_lockedtoref        [i] ),
        .rxplllock    (rx_is_lockedtodata       [i] ),
        .ppmlock      (freqlock                 [i] ),
        .earlyeios    (earlyeios                [i] ),

        .pciesw       (pciesw                   [i] ),
        .pciel        (wire_pciel                   ),
        //.pciem        (wire_pciem                   ),

        //.avmmrstn     (avmmrstn                 [i] ),
        //.avmmclk      (avmmclk                  [i] ),
        //.avmmwrite    (avmmwrite                [i] ),
        //.avmmread     (avmmread                 [i] ),
        //.avmmbyteen   (avmmbyteen        [i* 2+: 2] ),
        //.avmmaddress  (avmmaddress       [i*11+:11] ),
        //.avmmwritedata(avmmwritedata     [i*16+:16] ),
        //.avmmreaddata (avmmreaddata_cdr  [i*16+:16] ),
        //.blockselect  (blockselect_cdr          [i] ),

        //.clk270eye    (/*unused*/),
        //.clk270beyerm (/*unused*/),
        //.clk90eye     (/*unused*/),
        //.clk90beyerm  (/*unused*/),
        .clkindeser   (/*unused*/),
        //.deeye        (/*unused*/),
        //.deeyerm      (/*unused*/),
        //.doeye        (/*unused*/),
        //.doeyerm      (/*unused*/),
        .extclk       (/*unused*/),
        //.extfbctrla   (/*unused*/),
        //.extfbctrlb   (/*unused*/),
        //.gpblck2refb  (/*unused*/),
        .lpbkpreen    (/*unused*/),
        .occalen      (/*unused*/),
        .ck0pd        (/*unused*/),
        .ck180pd      (/*unused*/),
        .ck270pd      (/*unused*/),
        .ck90pd       (/*unused*/),
        //.clk270bcdr   (/*unused*/),
        //.clk90bcdr    (/*unused*/),
        //.decdr        (/*unused*/),
        //.docdr        (/*unused*/),
        .pdof         (/*unused*/),
        .rxlpbdp      (/*unused*/),
        .rxlpbp       (/*unused*/),
        .txpllhclk    (/*unused*/),
        .txrlpbk      (/*unused*/)
        );
      
      cyclonev_hssi_pma_rx_deser #(
        .mode             (mode             ),
        .channel_number   (channel_number   ),
        .auto_negotiation (auto_negotiation ),
        .sdclk_enable     (sdclk_enable     ),
        .enable_bit_slip  (deser_enable_bit_slip)
      ) rx_pma_deser (
        .bslip          (bslip                    [i] ),
        .clk90b         (wire_cdr_to_deser_clk        ),
        .clk270b        (wire_cdr_to_deser_clk_270    ),
        .deven          (wire_deven                   ),
        .dodd           (wire_dodd                    ),
        //.pfdmodelock    (rx_is_lockedtoref        [i] ),
        .pciesw         (pciesw                   [i] ),
        .rstn           (rstn                     [i] ),
        .clkdivrx       (clkdivrx                 [i] ),
        .clkdivrxrx     (wire_clkdivrxrx              ), // clock for signal detect
        .dout           (dout              [i*20+:20] ),
        .pciel          (wire_pciel                   )
        //.pciem          (wire_pciem                   ),

        //.avmmrstn       (avmmrstn                 [i] ),
        //.avmmclk        (avmmclk                  [i] ),
        //.avmmwrite      (avmmwrite                [i] ),
        //.avmmread       (avmmread                 [i] ),
        //.avmmbyteen     (avmmbyteen          [i*2+:2] ),
        //.avmmaddress    (avmmaddress       [i*11+:11] ),
        //.avmmwritedata  (avmmwritedata     [i*16+:16] ),
        //.avmmreaddata   (avmmreaddata_ser  [i*16+:16] ),
        //.blockselect    (blockselect_ser          [i] ),

        //.fref           (/*unused*/),
        //.clklow         (/*unused*/),
        //.clk33pcs       (/*unused*/)
        );

        // REFCLK_SELECT_MUX  
        cyclonev_hssi_pma_cdr_refclk_select_mux #(
          .refclk_select              ("REF_IQCLK0"                 ),
          .channel_number             (channel_number               ),
          .reference_clock_frequency  (cdr_reference_clock_frequency)
        ) cdr_refclk_mux0 (
          // Inputs
          .refiqclk0      (cdr_ref_clk[i]               ),
      
          // Outputs
          .clkout         (wire_refclk_to_cdr           ),

          //.avmmclk        (avmmclk                  [i] ),
          //.avmmrstn       (avmmrstn                 [i] ),
          //.avmmwrite      (avmmwrite                [i] ),
          //.avmmread       (avmmread                 [i] ),
          //.avmmbyteen     (avmmbyteen        [i* 2+: 2] ),
          //.avmmaddress    (avmmaddress       [i*11+:11] ),
          //.avmmwritedata  (avmmwritedata     [i*16+:16] ),
          //.avmmreaddata   (avmmreaddata_mux  [i*16+:16] ),
          //.blockselect    (blockselect_mux          [i] ),
          // Unused
          .calclk         (/*unused*/),
          .ffplloutbot    (/*unused*/),
          .ffpllouttop    (/*unused*/),
          .pldclk         (/*unused*/),
          .refiqclk1      (/*unused*/),
          .refiqclk10     (/*unused*/),
          .refiqclk2      (/*unused*/),
          .refiqclk3      (/*unused*/),
          .refiqclk4      (/*unused*/),
          .refiqclk5      (/*unused*/),
          .refiqclk6      (/*unused*/),
          .refiqclk7      (/*unused*/),
          .refiqclk8      (/*unused*/),
          .refiqclk9      (/*unused*/),
          .rxiqclk0       (/*unused*/),
          .rxiqclk1       (/*unused*/),
          .rxiqclk10      (/*unused*/),
          .rxiqclk2       (/*unused*/),
          .rxiqclk3       (/*unused*/),
          .rxiqclk4       (/*unused*/),
          .rxiqclk5       (/*unused*/),
          .rxiqclk6       (/*unused*/),
          .rxiqclk7       (/*unused*/),
          .rxiqclk8       (/*unused*/),
          .rxiqclk9       (/*unused*/)
        );
    end

    //Tie-off the output ports from the master-only channel index. There is
    //no Rx PMA in the master-only channel.
    if((i == bonding_master_ch_num) && (bonding_master_only == "true"))
    begin:mch 
      //assign  adaptdone               [i] = 1'b0;
      //assign  hardoccaldone           [i] = 1'b0;
      assign  sd                      [i] = 1'b0;
      assign  clkdivrx                [i] = 1'b0;
      assign  dout             [i*20+:20] = 20'b0;
      assign  sd                      [i] = 1'b0;
      assign  clklow                  [i] = 1'b0;
      assign  fref                    [i] = 1'b0;
      assign  rx_is_lockedtodata      [i] = 1'b0;
      assign  rx_is_lockedtoref       [i] = 1'b0;
      //assign  avmmreaddata_ser [i*16+:16] = 16'b0;
      //assign  avmmreaddata_buf [i*16+:16] = 16'b0;
      //assign  avmmreaddata_cdr [i*16+:16] = 16'b0;
      //assign  avmmreaddata_mux [i*16+:16] = 16'b0;
      //assign  blockselect_ser         [i] = 1'b0;
      //assign  blockselect_buf         [i] = 1'b0;
      //assign  blockselect_cdr         [i] = 1'b0;
      //assign  blockselect_mux         [i] = 1'b0;
    end
  end
  endgenerate

endmodule 
