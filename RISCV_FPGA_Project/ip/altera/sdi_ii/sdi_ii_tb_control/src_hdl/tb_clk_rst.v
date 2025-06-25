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

module tb_clk_rst
# (
    // module parameter port list
   parameter VIDEO_STANDARD = "tr",
   parameter DIRECTION      = "rx",
   parameter RX_EN_A2B_CONV = 0,
   parameter RX_EN_B2A_CONV = 0,
   parameter TX_HD_2X_OVERSAMPLING = 0,
   parameter HD_FREQ = "148.5",
   parameter TEST_RXSAMPLE_CHK = 0,
   parameter TEST_TXPLL_RECONFIG = 0   
)
(
    // port list
    tx_pll_sel     ,
    tx_ref_clk     ,
    tx_ref_clk_alt ,
    rx_ref_clk     ,
    ref_clk_smpte372 ,
    p_clk       ,
    reconfig_clk,
    clk_fpga    ,

    tx_std
);

    //--------------------------------------------------------------------------
    // local parameter declarations
    //--------------------------------------------------------------------------

    localparam CLK148_PERIOD         = 67340;
    localparam CLK148_35_PERIOD      = 67400;    //to create 148.35MHz clock for txpll sel
    localparam CLK148_49_PERIOD      = 67344;    //to create 148.49 MHz clock for rx_sample test
    localparam CLK75_PERIOD          = 134680;
    localparam CLK67_PERIOD          = 148148;      
    localparam CLK27_PERIOD          = 370370;
    localparam CLK100_PERIOD         = 100000;
    localparam TX_STD_WIDTH          = 2;

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------
    input                                           tx_pll_sel              ;
    output                                          tx_ref_clk              ;
    output                                          tx_ref_clk_alt          ; //148.35
    output                                          rx_ref_clk              ;
    output                                          ref_clk_smpte372        ;
    output                                          p_clk                   ;
    output                                          reconfig_clk            ;
    output                                          clk_fpga                ;

    input   [(TX_STD_WIDTH-1)       :0]             tx_std                  ;
    


    //--------------------------------------------------------------------------
    // port type declaration
    //--------------------------------------------------------------------------

    wire        tx_ref_clk  ;
    wire        tx_ref_clk_alt;
    wire        rx_ref_clk  ;
    wire        p_clk       ;
    wire        reconfig_clk;
    wire        clk_fpga    ;


    //--------------------------------------------------------------------------
    // signal declaration
    //--------------------------------------------------------------------------

    reg         clk_148     ;
    reg         clk_148_35  ;
    reg         clk_75      ;
    reg         clk_67      ;
    reg         clk_27      ;
    reg         clk_100     ;
    reg         clk_mux_out ;
    reg         clk_148_49  ;


    //--------------------------------------------------------------------------
    //
    // module definition
    //
    //--------------------------------------------------------------------------



    //--------------------------------------------------------------------------
    // [START] comment
    //--------------------------------------------------------------------------

    initial begin
        clk_148 = 0;
        forever #(CLK148_PERIOD/2) clk_148 = ~clk_148;
    end
    initial begin
        clk_148_49 = 0;
        forever #(CLK148_49_PERIOD/2) clk_148_49 = ~clk_148_49;
    end
    initial begin
        clk_75 = 0;
        forever #(CLK75_PERIOD/2) clk_75 = ~clk_75;
    end
    initial begin
        clk_67 = 0;
        forever #(CLK67_PERIOD/2) clk_67 = ~clk_67;
    end
    initial begin
        clk_27 = 0;
        forever #(CLK27_PERIOD/2) clk_27 = ~clk_27;
    end
    initial begin
        clk_100 = 0;
        forever #(CLK100_PERIOD/2) clk_100 = ~clk_100;
    end
	initial begin
        clk_148_35 = 0;
        forever #(CLK148_35_PERIOD/2) clk_148_35 = ~clk_148_35;   //148.35
    end
    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    // [START] comment
    //--------------------------------------------------------------------------

    always @ (*) 
    begin
        if (tx_std[1])
        begin
            // 3G
           if (TEST_TXPLL_RECONFIG == 1'b1) clk_mux_out = clk_148_35;
           else clk_mux_out = clk_148;
        end
        else if (tx_std[0])
        begin
            // HD
            clk_mux_out = clk_75;  	    
        end
        else
        begin
            // SD
            clk_mux_out = clk_27;
        end
    end

    assign tx_ref_clk       = (HD_FREQ == "74.25") ? clk_75 : ((TEST_RXSAMPLE_CHK == 1'b1) ? clk_148_49 : ((TEST_TXPLL_RECONFIG == 1'b1) ? clk_148_35 : clk_148));
    assign rx_ref_clk       = (HD_FREQ == "74.25") ? clk_75 : ((TEST_TXPLL_RECONFIG == 1'b1) ? clk_148_35 : clk_148);
    //assign ref_clk_smpte372 = (DIRECTION == "rx" & VIDEO_STANDARD == "dl" & RX_EN_A2B_CONV == 1'b1) ? clk_148 : 
    //                          ((DIRECTION == "rx" & (VIDEO_STANDARD == "tr" | VIDEO_STANDARD == "threeg") & RX_EN_B2A_CONV == 1'b1) ? clk_75 : clk_148);
    assign ref_clk_smpte372 = clk_148 ;
    assign p_clk            = clk_mux_out;
    assign reconfig_clk     = clk_100;
    assign clk_fpga         = clk_mux_out;
    assign tx_ref_clk_alt   = (HD_FREQ == "74.25") ? clk_75 : ((TEST_RXSAMPLE_CHK == 1'b1) ? clk_148_49 : ((TEST_TXPLL_RECONFIG == 1'b1) ? clk_148_35 : clk_148));

    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------


endmodule
