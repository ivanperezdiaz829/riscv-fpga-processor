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


`timescale 100 fs / 100 fs

module sdi_ii_tb_control
# (
   // module parameter port list
   parameter
      VIDEO_STANDARD          = "Triple_Standard"     ,
      TX_HD_2X_OVERSAMPLING   = 0                     ,
      RX_INC_ERR_TOLERANCE    = 0                     ,
      RX_CRC_ERROR_OUTPUT     = 0                     ,
      RX_EN_A2B_CONV          = 0                     ,
      RX_EN_B2A_CONV          = 0                     ,
      XCVR_TX_PLL_SEL         = 0                     ,
      DIRECTION               = "du"                  ,
      HD_FREQ                 = "148.5"               , 
      TEST_LN_OUTPUT          = 1                     ,
      TEST_SYNC_OUTPUT        = 0                     ,
      TEST_RECONFIG_SEQ       = "full"                ,
      TEST_DISTURB_SERIAL     = 0                     ,
      TEST_DL_SYNC            = 0                     ,
      TEST_TRS_LOCKED         = 0                     ,
      TEST_FRAME_LOCKED       = 0                     ,
      TEST_VPID_OVERWRITE     = 1                     ,
      TEST_MULTI_RECON        = 0                     ,
      TEST_SERIAL_DELAY       = 0                     ,
      TEST_RESET_SEQ          = 0                     ,
      TEST_RESET_RECON        = 0                     ,
      TEST_RST_PRE_OW         = 0                     ,
      TEST_TXPLL_RECONFIG     = 0                     ,
      TEST_RXSAMPLE_CHK       = 0                                          
      
)
(

   tx_pll_locked             ,
   tx_pll_locked_alt         ,
   tx_status                 ,
   
   //Connected to Tx ports
   tx_xcvr_refclk            ,
   tx_xcvr_refclk_alt        , 
   tx_sdi_start_reconfig     , 
   tx_sdi_pll_sel            ,
   //tx_xcvr_refclk_sel        ,   
   tx_coreclk                ,
   tx_xcvr_refclk_smpte372   ,
   tx_coreclk_smpte372       ,
   tx_rst                    ,
   tx_rst_ch0                ,
   tx_phy_mgmt_clk_rst       ,
   tx_rst_smpte372           ,
   tx_enable_ln              ,   
   tx_enable_crc             ,
   // tx_enable_vpid_c          ,
   tx_vpid_overwrite         ,
   tx_std                    ,
   tx_sdi_serial             ,
   tx_sdi_serial_b           ,
   tx_dout                   ,
   tx_dout_b                 ,
   tx_dvalid                 ,
   tx_dvalid_b               ,
   tx_trs                    ,
   tx_trs_b                  ,

   //Connected to Rx ports
   rx_rst_proto              ,
   rx_reconfig_busy          ,
   rx_sdi_start_reconfig     ,
   rx_xcvr_refclk            ,
   rx_coreclk                ,
   rx_xcvr_refclk_smpte372   ,
   rx_coreclk_smpte372       ,
   rx_rst                    ,
   rx_rst_smpte372           ,
   rx_rst_ch0                ,
   rx_phy_mgmt_clk_rst       ,
   // rx_enable_3g_search       ,
   // rx_enable_hd_search       ,
   // rx_enable_sd_search       ,
   rx_sdi_serial             ,
   rx_sdi_serial_b           ,
   rx_sdi_serial_ch0         ,

   //General ports
   reconfig_clk              ,
   reconfig_rst              ,
   phy_mgmt_clk              ,   //Used in Custom PHY
   phy_mgmt_clk_smpte372     ,   //Used in Custom PHY
   clk_fpga                  ,   //Used in ALT4GXB only
   sdi_gxb_powerdown         ,   //Used in ALT4GXB only

   //Connected to Pattgen ports
   pattgen_bar_100_75n       ,
   //pattgen_enable            ,
   pattgen_patho             ,
   pattgen_blank             ,
   pattgen_no_color          ,
   pattgen_sgmt_frame        ,
   pattgen_dl_mapping        ,   //Connected to Rx_checker as well
   pattgen_tx_std            ,
   pattgen_tx_format         ,   //Connected to Rx_checker as well
   pattgen_dout              ,
   pattgen_dout_b            ,
   pattgen_dvalid            ,
   pattgen_dvalid_b          ,
   pattgen_trs               ,
   pattgen_trs_b             ,
   pattgen_ntsc_paln         ,

   //Connected to Tx checker ports
   tx_chk_refclk             ,
   tx_chk_tx_std             ,
   tx_chk_start_chk          ,
   tx_clkout_match           ,

   //Connected to Rx checker ports
   rx_chk_refclk             ,
   rx_chk_rst                ,
   rx_chk_tx_format          ,
   rx_chk_dl_mapping         ,
   rx_chk_start_chk          ,
   rx_chk_start_chk_ch0      ,
   rx_chk_done               ,
   rx_chk_done_ch0           ,
   rx_check_posedge          ,   

   rx_chk_completed          ,
   rx_chk_completed_ch0

    //ref_rst         ,   
    //p_rst           ,   
    //reconfig_rst    ,    
    //hd_sdn          ,
    //rx_status,
);

   //--------------------------------------------------------------------------
   // local parameter declarations
   //--------------------------------------------------------------------------

   //localparam         num_chs = (VIDEO_STANDARD == "Dual_Link") ? 2 : 1;

   localparam   CLK148_PERIOD    =   67340;
   localparam   CLK75_PERIO      =   134680;   
   localparam   CLK27_PERIOD     =   370370;
   localparam   REFCLK_PERIOD    =   CLK148_PERIOD;
   localparam   SERIAL_PERIOD    =   REFCLK_PERIOD/20;

   localparam   err_tolerance    =   RX_INC_ERR_TOLERANCE ? 15 : 4;
   localparam   disturb_serial   =   (TEST_DISTURB_SERIAL == 1'b1);
   localparam   mode_sd          =   (VIDEO_STANDARD == "sd");
   localparam   mode_hd          =   (VIDEO_STANDARD == "hd");
   localparam   mode_dl          =   (VIDEO_STANDARD == "dl");
   localparam   mode_3g          =   (VIDEO_STANDARD == "threeg");
   localparam   mode_ds          =   (VIDEO_STANDARD == "ds");   
   localparam   mode_tr          =   (VIDEO_STANDARD == "tr");
   localparam   dl_sync          =   (VIDEO_STANDARD == "dl" && TEST_DL_SYNC == 1'b1);
   localparam   trs_test         =   (TEST_TRS_LOCKED == 1'b1);
   localparam   frame_test       =   (TEST_FRAME_LOCKED == 1'b1);
   localparam   multi_recon      =   (TEST_MULTI_RECON == 1'b1);
   localparam   serial_dly       =   (TEST_SERIAL_DELAY == 1'b1);
   localparam   reset_test       =   (TEST_RESET_SEQ == 1'b1);
   localparam   rst_recon_test   =   (TEST_RESET_RECON == 1'b1);
   localparam   rst_recon_pre_ow =   (TEST_RST_PRE_OW == 1'b1);   // 1: reset before overwrtting M-Counter, 0: reset after overwrtting M-Counter
   localparam   txpll_test       =   (TEST_TXPLL_RECONFIG == 1'b1) ? 1'b0 : (XCVR_TX_PLL_SEL == 1'b1);
   localparam   txpll_recon_test =   (TEST_TXPLL_RECONFIG == 1'b1); //tx_pll adv test
   
   //--------------------------------------------------------------------------
   // port declaration
   //--------------------------------------------------------------------------
   
   // Tx
   //input           sdi_tx_status                 ;
   input           tx_sdi_serial             ;
   input           tx_sdi_serial_b           ;
   
   input           tx_pll_locked             ;
   input           tx_pll_locked_alt         ;
   output          tx_status                 ;

   output          tx_xcvr_refclk            ;
   output          tx_xcvr_refclk_alt        ; 
   output          tx_sdi_start_reconfig     ; 
   output          tx_sdi_pll_sel            ;
   //output          tx_xcvr_refclk_sel        ;   
   output          tx_coreclk                ;
   output          tx_xcvr_refclk_smpte372   ;
   output          tx_coreclk_smpte372       ;
   output          tx_rst                    ;
   output          tx_rst_ch0                ;
   output          tx_rst_smpte372           ;
   output          tx_phy_mgmt_clk_rst       ;
   output          tx_enable_ln              ;   
   output          tx_enable_crc             ;
   // output          tx_enable_vpid_c          ;
   output          tx_vpid_overwrite         ;
   output  [1:0]   tx_std                    ;
   output [19:0]   tx_dout                   ;
   output [19:0]   tx_dout_b                 ;
   output          tx_dvalid                 ;
   output          tx_dvalid_b               ;
   output          tx_trs                    ;
   output          tx_trs_b                  ;

   // Rx
   input           rx_rst_proto              ;
   input           rx_reconfig_busy          ;
   input           rx_sdi_start_reconfig     ;

   output          rx_xcvr_refclk            ;
   output          rx_coreclk                ;
   output          rx_xcvr_refclk_smpte372   ;
   output          rx_coreclk_smpte372       ;
   output          rx_rst                    ;
   output          rx_rst_ch0                ;
   output          rx_rst_smpte372           ;
   output          rx_phy_mgmt_clk_rst       ;
   // output          rx_enable_3g_search       ;   
   // output          rx_enable_hd_search       ;   
   // output          rx_enable_sd_search       ; 
   output          rx_sdi_serial             ;
   output          rx_sdi_serial_b           ;
   output          rx_sdi_serial_ch0         ;
   
   // General ports
   output          reconfig_clk              ;
   output          reconfig_rst              ;  
   output          phy_mgmt_clk              ;
   output          phy_mgmt_clk_smpte372     ;
   output          clk_fpga                  ;
   output          sdi_gxb_powerdown         ;
   
   // Pattgen
   input [19:0]    pattgen_dout              ;
   input [19:0]    pattgen_dout_b            ;
   input           pattgen_dvalid            ;
   input           pattgen_dvalid_b          ;
   input           pattgen_trs               ;
   input           pattgen_trs_b             ;

   output          pattgen_bar_100_75n       ;
   //output          pattgen_enable            ;
   output          pattgen_patho             ;
   output          pattgen_blank             ;
   output          pattgen_no_color          ;
   output          pattgen_sgmt_frame        ;
   output          pattgen_dl_mapping        ;
   output  [1:0]   pattgen_tx_std            ;
   output  [3:0]   pattgen_tx_format         ;
   output          pattgen_ntsc_paln         ;

   // Tx checker
   output          tx_chk_refclk             ;   
   output  [1:0]   tx_chk_tx_std             ;
   output  [1:0]   tx_chk_start_chk          ;
   input           tx_clkout_match           ;

   // Rx checker
   input   [1:0]   rx_chk_done               ;
   input   [1:0]   rx_chk_done_ch0           ;
   input           rx_check_posedge          ;

   output          rx_chk_refclk             ;
   output          rx_chk_rst                ;
   output  [3:0]   rx_chk_tx_format          ;
   output          rx_chk_dl_mapping         ;
   output  [1:0]   rx_chk_start_chk          ;
   output  [1:0]   rx_chk_start_chk_ch0      ;
   
   input           rx_chk_completed          ;
   input           rx_chk_completed_ch0      ;

    //output       ref_rst          ;   
    //output       p_rst            ;   
    //output       reconfig_rst     ;    
    //output       hd_sdn           ;

   //--------------------------------------------------------------------------
   // port type declaration
   //--------------------------------------------------------------------------
   wire            tx_ref_clk                ;
   wire            tx_ref_clk_alt            ;
   wire            tx_sdi_pll_sel            ;
   //wire            tx_xcvr_refclk_sel        ;
   wire            rx_ref_clk                ;
   wire            ref_clk_smpte372          ;
   wire            tx_rst_ch0                ;
   wire            rx_rst_ch0                ;
   wire            tx_rst_smpte372           ;
   wire            tx_chk_refclk             ;
   wire            rx_chk_refclk             ;   
   wire            reconfig_clk              ;   
   wire            clk_fpga                  ;
   wire            pattgen_bar_100_75n       ;
   //wire            pattgen_enable            ;
   wire            pattgen_patho             ;
   wire            pattgen_blank             ;
   wire            pattgen_no_color          ;
   wire            pattgen_sgmt_frame        ;
   wire            pattgen_dl_mapping        ;
   wire            pattgen_ntsc_paln         ;
   wire    [3:0]   pattgen_tx_format         ;
   wire            tx_enable_ln              ;   
   wire            tx_enable_crc             ;
   // wire            tx_enable_vpid_c          ;
   // wire            rx_enable_3g_search       ;   
   // wire            rx_enable_hd_search       ;   
   // wire            rx_enable_sd_search       ;  
   wire            sdi_gxb_powerdown         ;
   wire    [1:0]   tx_chk_tx_std             ;
   wire            rx_chk_dl_mapping         ;
   wire    [3:0]   rx_chk_tx_format          ;
   wire            sdi_tx_status             ;

   reg             t_recon_rst               ;
   reg             tx_rst                    ;
   reg             tx_phy_mgmt_clk_rst       ;
   reg             rx_rst                    ;
   reg             rx_chk_rst                ;
   reg             rx_rst_smpte372           ;
   reg             rx_phy_mgmt_clk_rst       ;
   reg     [1:0]   tx_std                    ;
   reg             dl_mapping                ;
   reg     [1:0]   tx_chk_start_chk          ;
   reg     [1:0]   rx_chk_start_chk          ;
   reg     [1:0]   rx_chk_start_chk_ch0      ;
   reg     [3*8:0] test_string               ;
   // reg             enable_3gb                ;
   reg             t_disturb_after_sav       ;
   reg             t_disturb_after_eav       ;
   reg             disturb_eav               ;
   reg             disturb_sav               ;
   reg             disturb_bit               ;
   reg             disturb_v                 ;
   reg             enable_dly                ;
   reg             enable_dly_b              ;
   reg             dead_data                 ;
   reg             dead_data_b               ;
   reg     [1:0]   dly_cycle                 ;
   reg             sav_detected              ;
   reg     [3:0]   tx_format                 ;
   reg             tx_pll_sel_task           ;  
   reg             tx_start_reconfig_task    ;  
   reg             gate_tx_refclk            ;   
   reg             gate_tx_refclk_alt        ;
   reg             gate_rx_refclk            ;   
   
   wire            pre_mcounter_ow;
   wire            post_mcounter_ow;
   reg             is_first_recon;

   integer         eavword_count             ;
   integer         savword_count             ;
   //--------------------------------------------------------------------------
   //
   // module definition
   //
   //--------------------------------------------------------------------------
   `include "tb_tasks.v"


   //--------------------------------------------------------------------------
   // Clocks & reset
   //--------------------------------------------------------------------------
   assign phy_mgmt_clk              =   reconfig_clk             ;
   assign phy_mgmt_clk_smpte372     =   reconfig_clk             ;
   assign tx_xcvr_refclk            =  (gate_tx_refclk)     ? 1'bZ : tx_ref_clk     ;
   assign tx_xcvr_refclk_alt        =  (gate_tx_refclk_alt) ? 1'bZ : tx_ref_clk_alt ;
   assign tx_coreclk                =   tx_ref_clk;
   assign rx_xcvr_refclk            =  (gate_rx_refclk) ? 1'bZ : rx_ref_clk     ;
   assign rx_coreclk                =   rx_ref_clk               ;
   assign rx_chk_refclk             =   rx_ref_clk               ;
   assign tx_xcvr_refclk_smpte372   =   ref_clk_smpte372         ;
   assign tx_coreclk_smpte372       =   ref_clk_smpte372         ;   
   assign rx_xcvr_refclk_smpte372   =   ref_clk_smpte372         ;
   assign rx_coreclk_smpte372       =   ref_clk_smpte372         ;
   assign tx_rst_smpte372           =   tx_rst || rx_rst_proto   ;
   assign tx_rst_ch0                =   (multi_recon == 1'b1) ? tx_rst : 1'b1; 
   assign rx_rst_ch0                =   (multi_recon == 1'b1) ? rx_rst : 1'b1;
   assign reconfig_rst              =   (rst_recon_test) ? t_recon_rst : rx_rst;
   
   wire  [1:0]   tx_std_int = (RX_EN_A2B_CONV == 1'b1) ? 2'b10 : ((RX_EN_B2A_CONV == 1'b1) ? 2'b01 : tx_std);
   
   generate 
   begin: GEN_TX_STATUS
   if (txpll_test || txpll_recon_test)
      assign sdi_tx_status = (tx_sdi_pll_sel == 1'd0)? tx_pll_locked : tx_pll_locked_alt;
   else
      assign sdi_tx_status = tx_pll_locked;
   end
   endgenerate
   
   assign tx_status = sdi_tx_status;

   tb_clk_rst u_tb_clk_rst
   (
    .tx_pll_sel         (tx_sdi_pll_sel)     ,
    .tx_ref_clk         (tx_ref_clk)         ,
    .tx_ref_clk_alt     (tx_ref_clk_alt)     ,
    .rx_ref_clk         (rx_ref_clk)         ,
    .ref_clk_smpte372   (ref_clk_smpte372)   ,
    .p_clk              (tx_chk_refclk)      ,
    .reconfig_clk       (reconfig_clk)       ,
    .clk_fpga           (clk_fpga)           ,
    .tx_std             (tx_std_int)
   );
   defparam u_tb_clk_rst.VIDEO_STANDARD = VIDEO_STANDARD;
   defparam u_tb_clk_rst.RX_EN_A2B_CONV = RX_EN_A2B_CONV;
   defparam u_tb_clk_rst.RX_EN_B2A_CONV = RX_EN_B2A_CONV;
   defparam u_tb_clk_rst.TX_HD_2X_OVERSAMPLING = TX_HD_2X_OVERSAMPLING;
   defparam u_tb_clk_rst.HD_FREQ = HD_FREQ;
   defparam u_tb_clk_rst.TEST_RXSAMPLE_CHK = TEST_RXSAMPLE_CHK; 
   defparam u_tb_clk_rst.TEST_TXPLL_RECONFIG = TEST_TXPLL_RECONFIG;
   //defparam u_tb_clk_rst.DIRECTION = DIRECTION;

   //--------------------------------------------------------------------------
   // Rx reset synchronizer
   //--------------------------------------------------------------------------
   //reg [3:0] rst_sync;

   //always @ (posedge rx_ref_clk) 
   //begin
   //rst_sync <= 0;
   //rst_sync[3:0] <= {rst_sync[2:0], rx_rst};
   //end

   //--------------------------------------------------------------------------
   // Control signals - basic
   //--------------------------------------------------------------------------
   assign tx_chk_tx_std         =   tx_std_int                   ;
   assign pattgen_tx_std        =   tx_std                       ;
   assign pattgen_tx_format     =   tx_format                    ;
   assign pattgen_dl_mapping    =   dl_mapping                   ;
   assign pattgen_bar_100_75n   =   1'b1                         ;
   // assign pattgen_enable        =   ~rst_sync[3]                 ;
   assign pattgen_patho         =   1'b0                         ;
   assign pattgen_blank         =   1'b0                         ;
   assign pattgen_no_color      =   1'b0                         ;
   assign pattgen_sgmt_frame    =   1'b0                         ;
   assign pattgen_ntsc_paln     =   1'b0                         ;
   assign tx_enable_ln          =   (TEST_LN_OUTPUT == 1'b1)     ;
   assign tx_enable_crc         =   (RX_CRC_ERROR_OUTPUT == 1'b1);
   // assign tx_enable_vpid_c      =   1'b0                         ;
   assign tx_vpid_overwrite     =   (TEST_VPID_OVERWRITE == 1'b1);
   assign rx_chk_tx_format      =   tx_format                    ;
   assign rx_chk_dl_mapping     =   dl_mapping                   ;
   assign sdi_gxb_powerdown     =   1'b0                         ;

   //assign hd_sdn = tx_std_int[1] ? 1'b1 : tx_std_int[0];

   //--------------------------------------------------------------------------
   // Video Transmit Sequence
   //--------------------------------------------------------------------------

   //----------------------------------------
   // Triple rate
   //----------------------------------------
   if (mode_tr & RX_EN_B2A_CONV == 0) begin
      // assign rx_enable_3g_search = 1'b1;
      // assign rx_enable_hd_search = 1'b1;
      // assign rx_enable_sd_search = 1'b1;

      initial begin
         initialize();

         if (TEST_RECONFIG_SEQ == "full" && ~txpll_test) begin
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GB", "DL");
            reset_tx();
            transmit_SD(4'b0001);
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_SD(4'b0001);
            reset_tx();
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end
		 
         if (TEST_RECONFIG_SEQ == "full" && txpll_test) begin
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GB", "DL");
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "3GA") begin
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "3GB") begin
            transmit_3G(4'b1101, "3GB", "DL");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "HD") begin
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "SD") begin
            transmit_SD(4'b0001);
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "3GAHD") begin
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end
    
         if (TEST_RECONFIG_SEQ == "3GBHD") begin
            transmit_3G(4'b1101, "3GB", "DL");
            reset_tx();
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GB", "DL");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "3GASD") begin
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_SD(4'b0001);
            reset_tx();
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end
    
         if (TEST_RECONFIG_SEQ == "3GBSD") begin
            transmit_3G(4'b1101, "3GB", "DL");
            reset_tx();
            transmit_SD(4'b0001);
            reset_tx();
            transmit_3G(4'b1101, "3GB", "DL");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "HD3G") begin
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "HDSD") begin
            transmit_HD(4'b0101, "--");
            reset_tx(); 
            transmit_SD(4'b0001);
            reset_tx(); 
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "SD3G") begin
            transmit_SD(4'b0001);
            reset_tx(); 
            transmit_3G(4'b1101, "3GA", "--");
            reset_tx();
            transmit_SD(4'b0001);
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "SDHD") begin
            transmit_SD(4'b0001);
            reset_tx(); 
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_SD(4'b0001);
            printresult();
            complete_sim();
         end
      end
   end
   // B to A conversion is enabled
   else if (mode_tr & RX_EN_B2A_CONV == 1'b1) begin
      // assign rx_enable_3g_search = 1'b1;
      // assign rx_enable_hd_search = 1'b1;
      // assign rx_enable_sd_search = 1'b1;

      initial begin
         initialize();
         transmit_3G(4'b1101, "3GB", "DL");
         printresult();
         complete_sim();
      end
   end 

   //----------------------
   // Dual standard
   //----------------------
   else if (mode_ds) begin
      // assign rx_enable_3g_search = 1'b1;
      // assign rx_enable_hd_search = 1'b1;
      // assign rx_enable_sd_search = 1'b1;

      initial begin
         initialize();

         if (TEST_RECONFIG_SEQ == "HD") begin
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "SD") begin
            transmit_SD(4'b0001);
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "HDSD" && !txpll_test) begin
            transmit_HD(4'b0101, "--");
            reset_tx(); 
            transmit_SD(4'b0001);
            reset_tx(); 
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end
         
         if (TEST_RECONFIG_SEQ == "HDSD" && txpll_test) begin
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "SDHD" && !txpll_test) begin
            transmit_SD(4'b0001);
            reset_tx(); 
            transmit_HD(4'b0101, "--");
            reset_tx();
            transmit_SD(4'b0001);
            printresult();
            complete_sim();
         end
         
         if (TEST_RECONFIG_SEQ == "SDHD" && txpll_test) begin
            transmit_HD(4'b0101, "--");
            printresult();
            complete_sim();
         end

      end
   end

   //----------------------
   // Dual-link
   //----------------------
   else if (mode_dl) begin
      // the following enable* are required for rx_smpte372 instance
      // for A2B conversion demo
      // assign rx_enable_3g_search = 1'b1;
      // assign rx_enable_hd_search = 1'b0;
      // assign rx_enable_sd_search = 1'b0;

      initial begin
         initialize();
         transmit_HD(4'b1100, "DL");
         printresult();
         complete_sim();
      end
   end

   //----------------------
   // 3G single rate
   //----------------------
   else if (mode_3g) begin
      initial begin
         initialize();

         if (TEST_RECONFIG_SEQ == "3GA") begin
            transmit_3G(4'b1101, "3GA", "--");
            printresult();
            complete_sim();
         end

         if (TEST_RECONFIG_SEQ == "3GB") begin
            transmit_3G(4'b1101, "3GB", "DL");
            printresult();
            complete_sim();
         end
      end
   end

   //----------------------
   // HD single rate
   //----------------------
   else if (mode_hd) begin
      initial begin
         initialize();
         transmit_HD(4'b0101, "--");
         printresult();
         complete_sim();
      end
   end

   //----------------------
   // SD single rate
   //----------------------
   else if (mode_sd) begin
      initial begin
         initialize();
         transmit_SD(4'b0001);
         printresult();
         complete_sim();
      end
   end
         
   //--------------------------------------------------------------------------
   // Test timeout
   //--------------------------------------------------------------------------
   always @ (posedge rx_chk_done[0])
   begin
     tx_chk_start_chk = 2'b01;
     #(1);
     tx_chk_start_chk = 2'b10;
     #(1);
     $stop(0);
   end

   //--------------------------------------
   // Reset RX-core during reconfig test
   //--------------------------------------
   generate 
   if (rst_recon_test) begin: rst_reconfig   
   
    reg  [2:0] cnt_reconfig_busy;
    
    initial begin
      @(posedge sdi_tx_status);
      is_first_recon = 1'b1;
      @(negedge rx_sdi_start_reconfig);
      is_first_recon = 1'b0;
    end

   
    always @ (negedge rx_reconfig_busy or posedge rx_rst or negedge rx_sdi_start_reconfig)
    begin
      if (rx_rst) begin
        cnt_reconfig_busy  <= 0;
      end else if (~rx_sdi_start_reconfig)begin 
        cnt_reconfig_busy  <= 0;
      end else begin
        cnt_reconfig_busy <= cnt_reconfig_busy + 1;
      end
    end
   
    assign pre_mcounter_ow = (cnt_reconfig_busy == 1);
    assign post_mcounter_ow = (cnt_reconfig_busy == 2);                                            
   end
   endgenerate 

   //--------------------------------------------------------------------------
   // SDI serial bit delay block
   //--------------------------------------------------------------------------   

   wire   rx_sdi_serial_dly;
   wire   rx_sdi_serial_dly_b;
   wire   tx_sclk;
   assign rx_sdi_serial_ch0 = (serial_dly) ? rx_sdi_serial_dly : rx_sdi_serial;
   
   generate
    if (serial_dly || dl_sync || trs_test | frame_test) begin: serial_delay
      tb_serial_delay u_ser_dly
      (
        .sdi_serial      (tx_sdi_serial),
        .serial_delayed  (rx_sdi_serial_dly)  
      );
      defparam u_ser_dly.dl_synctest = dl_sync;
      defparam u_ser_dly.serial_dlytest = serial_dly;
	  
      tb_serial_delay u_ser_dly_b
      (
        .sdi_serial      (tx_sdi_serial_b),
        .serial_delayed  (rx_sdi_serial_dly_b)      
      );
      defparam u_ser_dly_b.dl_synctest = dl_sync;
      defparam u_ser_dly_b.serial_dlytest = serial_dly;
    end
    endgenerate 
    
   //--------------------------------------------------------------------------
   // Disturb serial
   //--------------------------------------------------------------------------
   assign rx_sdi_serial = (dead_data) ? 1'bz : 
                             (disturb_bit) ? ~tx_sdi_serial : 
                                (enable_dly) ? rx_sdi_serial_dly : tx_sdi_serial;
   assign rx_sdi_serial_b = (dead_data_b) ? 1'bz : 
                               (disturb_bit) ? ~tx_sdi_serial_b : 
                                  (enable_dly_b) ? rx_sdi_serial_dly_b : tx_sdi_serial_b;

   generate
   if (disturb_serial | trs_test | frame_test) begin: data_disturb
      wire    descrambled;
      wire    tx_sclk;
      wire    trs_spotted;
      tb_serial_descrambler u_descr
      (
       .ref_clk       (tx_chk_refclk)    ,
       .sdi_serial    (tx_sdi_serial)    ,
       .tx_std        (tx_std)           ,
       .tx_status     (sdi_tx_status)    ,
       .tx_sclk       (tx_sclk)          ,
       .descrambled   (descrambled)      ,
       .trs_spotted   (trs_spotted)
      );

      //--------------------------------------------------------------------------
      // Deliberate corruption of tx stream data to see if CRCs errors are produced.
      //--------------------------------------------------------------------------
      integer    word_tick_count;
      integer    bit_count = 0;

      always @ (negedge tx_sclk)
      begin
         //if (tx_sclk) begin
            disturb_bit = 1'b0;
            bit_count = bit_count + 1;

            if (trs_spotted) begin
               bit_count = 0;
               word_tick_count = 0;
            end

            if (bit_count == 7) begin
               if (descrambled == 0) sav_detected = 1'b1;
               else sav_detected = 1'b0;
            end else if (bit_count >= 10) begin
               word_tick_count = word_tick_count + 1;
            end

            // if ((word_tick_count >= eavword_count - 1) && (word_tick_count <= eavword_count + 1)) begin
            if (word_tick_count == eavword_count ) begin
               if (disturb_eav && sav_detected) disturb_bit = 1'b1;
            // end else if ((word_tick_count >= savword_count - 1) && (word_tick_count <= savword_count + 1)) begin
            end else if (word_tick_count == savword_count ) begin
               if (disturb_sav && ~sav_detected) disturb_bit = 1'b1;
            end

            if (word_tick_count == 300 || word_tick_count == 350) begin
               if (sav_detected & t_disturb_after_sav) begin
                  disturb_bit = 1'b1;
               end
               else if (~sav_detected & t_disturb_after_eav) begin
                  disturb_bit = 1'b1;
               end
            end
         //end
      end
   end
   endgenerate
   
    //--------------------------------------------------------------------------
   // TX PLL Selection
   //--------------------------------------------------------------------------
   assign tx_sdi_pll_sel = (tx_pll_sel_task) ? 1'b1 : 1'b0;  
   //assign tx_xcvr_refclk_sel = (tx_pll_sel_task) ? 1'b1 : 1'b0;
   assign tx_sdi_start_reconfig = (tx_start_reconfig_task) ? 1'b1 : 1'b0;  

   //--------------------------------------------------------------------------
   // Delay data from pattgen and pass to tx_protocol
   //--------------------------------------------------------------------------
   wire [19:0]    tx_dout, tx_dout_b;
   wire           tx_dvalid, tx_dvalid_b;
   wire [19:0]    dataout, dataout_b;
   wire           dvalid_out, dvalid_out_b;
   wire           trsout, trsout_b;

   assign tx_dout       = pattgen_dout;
   assign tx_dout_b     = pattgen_dout_b;
   assign tx_dvalid     = pattgen_dvalid;
   assign tx_dvalid_b   = pattgen_dvalid_b;
   assign tx_trs        = pattgen_trs;
   assign tx_trs_b      = pattgen_trs_b;

   // assign tx_dout       = (enable_dly) ? dataout: pattgen_dout;
   // assign tx_dout_b     = (enable_dly_b) ? dataout_b: pattgen_dout_b;
   // assign tx_dvalid     = (enable_dly) ? dvalid_out: pattgen_dvalid;
   // assign tx_dvalid_b   = (enable_dly_b) ? dvalid_out_b : pattgen_dvalid_b;
   // assign tx_trs        = (enable_dly) ? trsout : pattgen_trs;
   // assign tx_trs_b      = (enable_dly_b) ? trsout_b : pattgen_trs_b;

   generate
   if (dl_sync || trs_test | frame_test) begin : data_dly
      tb_data_delay u_delay
      (
       .clk            (tx_ref_clk),
       .rst            (tx_rst),
       .dly_cycle      (dly_cycle),
       .data_in        (pattgen_dout),
       .data_in_b      (pattgen_dout_b),
       .dvalid_in      (pattgen_dvalid),
       .dvalid_in_b    (pattgen_dvalid_b),
       .trs_in         (pattgen_trs),
       .trs_in_b       (pattgen_trs_b),
       .data_out       (dataout),
       .data_out_b     (dataout_b),
       .dvalid_out     (dvalid_out),
       .dvalid_out_b   (dvalid_out_b),
       .trs_out        (trsout),
       .trs_out_b      (trsout_b)
      );
   end
   endgenerate
endmodule



