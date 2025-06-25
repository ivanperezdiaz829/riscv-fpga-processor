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


// synthesis translate_off
`timescale 1ps / 1ps
// synthesis translate_on

module altpcietb_bfm_rp_gen3_x8 (
                        reconfig_xcvr_clk_clk,
                        refclk_clk,
                        hip_ctrl_test_in,
                        hip_ctrl_simu_mode_pipe,
                        hip_serial_rx_in0,
                        hip_serial_rx_in1,
                        hip_serial_rx_in2,
                        hip_serial_rx_in3,
                        hip_serial_rx_in4,
                        hip_serial_rx_in5,
                        hip_serial_rx_in6,
                        hip_serial_rx_in7,
                        hip_serial_tx_out0,
                        hip_serial_tx_out1,
                        hip_serial_tx_out2,
                        hip_serial_tx_out3,
                        hip_serial_tx_out4,
                        hip_serial_tx_out5,
                        hip_serial_tx_out6,
                        hip_serial_tx_out7,
                        hip_pipe_sim_pipe_pclk_in,
                        hip_pipe_sim_pipe_rate,
                        hip_pipe_sim_ltssmstate,
                        hip_pipe_eidleinfersel0,
                        hip_pipe_eidleinfersel1,
                        hip_pipe_eidleinfersel2,
                        hip_pipe_eidleinfersel3,
                        hip_pipe_eidleinfersel4,
                        hip_pipe_eidleinfersel5,
                        hip_pipe_eidleinfersel6,
                        hip_pipe_eidleinfersel7,
                        hip_pipe_powerdown0,
                        hip_pipe_powerdown1,
                        hip_pipe_powerdown2,
                        hip_pipe_powerdown3,
                        hip_pipe_powerdown4,
                        hip_pipe_powerdown5,
                        hip_pipe_powerdown6,
                        hip_pipe_powerdown7,
                        hip_pipe_rxpolarity0,
                        hip_pipe_rxpolarity1,
                        hip_pipe_rxpolarity2,
                        hip_pipe_rxpolarity3,
                        hip_pipe_rxpolarity4,
                        hip_pipe_rxpolarity5,
                        hip_pipe_rxpolarity6,
                        hip_pipe_rxpolarity7,
                        hip_pipe_txcompl0,
                        hip_pipe_txcompl1,
                        hip_pipe_txcompl2,
                        hip_pipe_txcompl3,
                        hip_pipe_txcompl4,
                        hip_pipe_txcompl5,
                        hip_pipe_txcompl6,
                        hip_pipe_txcompl7,
                        hip_pipe_txdata0,
                        hip_pipe_txdata1,
                        hip_pipe_txdata2,
                        hip_pipe_txdata3,
                        hip_pipe_txdata4,
                        hip_pipe_txdata5,
                        hip_pipe_txdata6,
                        hip_pipe_txdata7,
                        hip_pipe_txdatak0,
                        hip_pipe_txdatak1,
                        hip_pipe_txdatak2,
                        hip_pipe_txdatak3,
                        hip_pipe_txdatak4,
                        hip_pipe_txdatak5,
                        hip_pipe_txdatak6,
                        hip_pipe_txdatak7,
                        hip_pipe_txdetectrx0,
                        hip_pipe_txdetectrx1,
                        hip_pipe_txdetectrx2,
                        hip_pipe_txdetectrx3,
                        hip_pipe_txdetectrx4,
                        hip_pipe_txdetectrx5,
                        hip_pipe_txdetectrx6,
                        hip_pipe_txdetectrx7,
                        hip_pipe_txelecidle0,
                        hip_pipe_txelecidle1,
                        hip_pipe_txelecidle2,
                        hip_pipe_txelecidle3,
                        hip_pipe_txelecidle4,
                        hip_pipe_txelecidle5,
                        hip_pipe_txelecidle6,
                        hip_pipe_txelecidle7,
                        hip_pipe_txdeemph0,
                        hip_pipe_txdeemph1,
                        hip_pipe_txdeemph2,
                        hip_pipe_txdeemph3,
                        hip_pipe_txdeemph4,
                        hip_pipe_txdeemph5,
                        hip_pipe_txdeemph6,
                        hip_pipe_txdeemph7,
                        hip_pipe_phystatus0,
                        hip_pipe_phystatus1,
                        hip_pipe_phystatus2,
                        hip_pipe_phystatus3,
                        hip_pipe_phystatus4,
                        hip_pipe_phystatus5,
                        hip_pipe_phystatus6,
                        hip_pipe_phystatus7,
                        hip_pipe_rxdata0,
                        hip_pipe_rxdata1,
                        hip_pipe_rxdata2,
                        hip_pipe_rxdata3,
                        hip_pipe_rxdata4,
                        hip_pipe_rxdata5,
                        hip_pipe_rxdata6,
                        hip_pipe_rxdata7,
                        hip_pipe_rxdatak0,
                        hip_pipe_rxdatak1,
                        hip_pipe_rxdatak2,
                        hip_pipe_rxdatak3,
                        hip_pipe_rxdatak4,
                        hip_pipe_rxdatak5,
                        hip_pipe_rxdatak6,
                        hip_pipe_rxdatak7,
                        hip_pipe_rxelecidle0,
                        hip_pipe_rxelecidle1,
                        hip_pipe_rxelecidle2,
                        hip_pipe_rxelecidle3,
                        hip_pipe_rxelecidle4,
                        hip_pipe_rxelecidle5,
                        hip_pipe_rxelecidle6,
                        hip_pipe_rxelecidle7,
                        hip_pipe_rxstatus0,
                        hip_pipe_rxstatus1,
                        hip_pipe_rxstatus2,
                        hip_pipe_rxstatus3,
                        hip_pipe_rxstatus4,
                        hip_pipe_rxstatus5,
                        hip_pipe_rxstatus6,
                        hip_pipe_rxstatus7,
                        hip_pipe_rxvalid0,
                        hip_pipe_rxvalid1,
                        hip_pipe_rxvalid2,
                        hip_pipe_rxvalid3,
                        hip_pipe_rxvalid4,
                        hip_pipe_rxvalid5,
                        hip_pipe_rxvalid6,
                        hip_pipe_rxvalid7,
                        pcie_rstn_npor,
                        pcie_rstn_pin_perst
        );



        input  wire        reconfig_xcvr_clk_clk;     // reconfig_xcvr_clk.clk
        input  wire        refclk_clk;                //            refclk.clk
        input  wire [31:0] hip_ctrl_test_in;          //          hip_ctrl.test_in
        input  wire        hip_ctrl_simu_mode_pipe;   //                  .simu_mode_pipe
        input  wire        hip_serial_rx_in0;         //                  .rx_in0
        input  wire        hip_serial_rx_in1;         //                  .rx_in1
        input  wire        hip_serial_rx_in2;         //                  .rx_in2
        input  wire        hip_serial_rx_in3;         //                  .rx_in3
        input  wire        hip_serial_rx_in4;         //                  .rx_in4
        input  wire        hip_serial_rx_in5;         //                  .rx_in5
        input  wire        hip_serial_rx_in6;         //                  .rx_in6
        input  wire        hip_serial_rx_in7;         //                  .rx_in7
        output wire        hip_serial_tx_out0;        //                  .tx_out0
        output wire        hip_serial_tx_out1;        //                  .tx_out1
        output wire        hip_serial_tx_out2;        //                  .tx_out2
        output wire        hip_serial_tx_out3;        //                  .tx_out3
        output wire        hip_serial_tx_out4;        //                  .tx_out4
        output wire        hip_serial_tx_out5;        //                  .tx_out5
        output wire        hip_serial_tx_out6;        //                  .tx_out6
        output wire        hip_serial_tx_out7;        //                  .tx_out7
        input  wire        hip_pipe_sim_pipe_pclk_in; //                  .sim_pipe_pclk_in
        output wire [1:0]  hip_pipe_sim_pipe_rate;    //                  .sim_pipe_rate
        output wire [4:0]  hip_pipe_sim_ltssmstate;   //                  .sim_ltssmstate
        output wire [2:0]  hip_pipe_eidleinfersel0;   //                  .eidleinfersel0
        output wire [2:0]  hip_pipe_eidleinfersel1;   //                  .eidleinfersel1
        output wire [2:0]  hip_pipe_eidleinfersel2;   //                  .eidleinfersel2
        output wire [2:0]  hip_pipe_eidleinfersel3;   //                  .eidleinfersel3
        output wire [2:0]  hip_pipe_eidleinfersel4;   //                  .eidleinfersel4
        output wire [2:0]  hip_pipe_eidleinfersel5;   //                  .eidleinfersel5
        output wire [2:0]  hip_pipe_eidleinfersel6;   //                  .eidleinfersel6
        output wire [2:0]  hip_pipe_eidleinfersel7;   //                  .eidleinfersel7
        output wire [1:0]  hip_pipe_powerdown0;       //                  .powerdown0
        output wire [1:0]  hip_pipe_powerdown1;       //                  .powerdown1
        output wire [1:0]  hip_pipe_powerdown2;       //                  .powerdown2
        output wire [1:0]  hip_pipe_powerdown3;       //                  .powerdown3
        output wire [1:0]  hip_pipe_powerdown4;       //                  .powerdown4
        output wire [1:0]  hip_pipe_powerdown5;       //                  .powerdown5
        output wire [1:0]  hip_pipe_powerdown6;       //                  .powerdown6
        output wire [1:0]  hip_pipe_powerdown7;       //                  .powerdown7
        output wire        hip_pipe_rxpolarity0;      //                  .rxpolarity0
        output wire        hip_pipe_rxpolarity1;      //                  .rxpolarity1
        output wire        hip_pipe_rxpolarity2;      //                  .rxpolarity2
        output wire        hip_pipe_rxpolarity3;      //                  .rxpolarity3
        output wire        hip_pipe_rxpolarity4;      //                  .rxpolarity4
        output wire        hip_pipe_rxpolarity5;      //                  .rxpolarity5
        output wire        hip_pipe_rxpolarity6;      //                  .rxpolarity6
        output wire        hip_pipe_rxpolarity7;      //                  .rxpolarity7
        output wire        hip_pipe_txcompl0;         //                  .txcompl0
        output wire        hip_pipe_txcompl1;         //                  .txcompl1
        output wire        hip_pipe_txcompl2;         //                  .txcompl2
        output wire        hip_pipe_txcompl3;         //                  .txcompl3
        output wire        hip_pipe_txcompl4;         //                  .txcompl4
        output wire        hip_pipe_txcompl5;         //                  .txcompl5
        output wire        hip_pipe_txcompl6;         //                  .txcompl6
        output wire        hip_pipe_txcompl7;         //                  .txcompl7
        output wire [7:0]  hip_pipe_txdata0;          //                  .txdata0
        output wire [7:0]  hip_pipe_txdata1;          //                  .txdata1
        output wire [7:0]  hip_pipe_txdata2;          //                  .txdata2
        output wire [7:0]  hip_pipe_txdata3;          //                  .txdata3
        output wire [7:0]  hip_pipe_txdata4;          //                  .txdata4
        output wire [7:0]  hip_pipe_txdata5;          //                  .txdata5
        output wire [7:0]  hip_pipe_txdata6;          //                  .txdata6
        output wire [7:0]  hip_pipe_txdata7;          //                  .txdata7
        output wire        hip_pipe_txdatak0;         //                  .txdatak0
        output wire        hip_pipe_txdatak1;         //                  .txdatak1
        output wire        hip_pipe_txdatak2;         //                  .txdatak2
        output wire        hip_pipe_txdatak3;         //                  .txdatak3
        output wire        hip_pipe_txdatak4;         //                  .txdatak4
        output wire        hip_pipe_txdatak5;         //                  .txdatak5
        output wire        hip_pipe_txdatak6;         //                  .txdatak6
        output wire        hip_pipe_txdatak7;         //                  .txdatak7
        output wire        hip_pipe_txdetectrx0;      //                  .txdetectrx0
        output wire        hip_pipe_txdetectrx1;      //                  .txdetectrx1
        output wire        hip_pipe_txdetectrx2;      //                  .txdetectrx2
        output wire        hip_pipe_txdetectrx3;      //                  .txdetectrx3
        output wire        hip_pipe_txdetectrx4;      //                  .txdetectrx4
        output wire        hip_pipe_txdetectrx5;      //                  .txdetectrx5
        output wire        hip_pipe_txdetectrx6;      //                  .txdetectrx6
        output wire        hip_pipe_txdetectrx7;      //                  .txdetectrx7
        output wire        hip_pipe_txelecidle0;      //                  .txelecidle0
        output wire        hip_pipe_txelecidle1;      //                  .txelecidle1
        output wire        hip_pipe_txelecidle2;      //                  .txelecidle2
        output wire        hip_pipe_txelecidle3;      //                  .txelecidle3
        output wire        hip_pipe_txelecidle4;      //                  .txelecidle4
        output wire        hip_pipe_txelecidle5;      //                  .txelecidle5
        output wire        hip_pipe_txelecidle6;      //                  .txelecidle6
        output wire        hip_pipe_txelecidle7;      //                  .txelecidle7
        output wire        hip_pipe_txdeemph0;        //                  .txdeemph0
        output wire        hip_pipe_txdeemph1;        //                  .txdeemph1
        output wire        hip_pipe_txdeemph2;        //                  .txdeemph2
        output wire        hip_pipe_txdeemph3;        //                  .txdeemph3
        output wire        hip_pipe_txdeemph4;        //                  .txdeemph4
        output wire        hip_pipe_txdeemph5;        //                  .txdeemph5
        output wire        hip_pipe_txdeemph6;        //                  .txdeemph6
        output wire        hip_pipe_txdeemph7;        //                  .txdeemph7
        input  wire        hip_pipe_phystatus0;       //                  .phystatus0
        input  wire        hip_pipe_phystatus1;       //                  .phystatus1
        input  wire        hip_pipe_phystatus2;       //                  .phystatus2
        input  wire        hip_pipe_phystatus3;       //                  .phystatus3
        input  wire        hip_pipe_phystatus4;       //                  .phystatus4
        input  wire        hip_pipe_phystatus5;       //                  .phystatus5
        input  wire        hip_pipe_phystatus6;       //                  .phystatus6
        input  wire        hip_pipe_phystatus7;       //                  .phystatus7
        input  wire [7:0]  hip_pipe_rxdata0;          //                  .rxdata0
        input  wire [7:0]  hip_pipe_rxdata1;          //                  .rxdata1
        input  wire [7:0]  hip_pipe_rxdata2;          //                  .rxdata2
        input  wire [7:0]  hip_pipe_rxdata3;          //                  .rxdata3
        input  wire [7:0]  hip_pipe_rxdata4;          //                  .rxdata4
        input  wire [7:0]  hip_pipe_rxdata5;          //                  .rxdata5
        input  wire [7:0]  hip_pipe_rxdata6;          //                  .rxdata6
        input  wire [7:0]  hip_pipe_rxdata7;          //                  .rxdata7
        input  wire        hip_pipe_rxdatak0;         //                  .rxdatak0
        input  wire        hip_pipe_rxdatak1;         //                  .rxdatak1
        input  wire        hip_pipe_rxdatak2;         //                  .rxdatak2
        input  wire        hip_pipe_rxdatak3;         //                  .rxdatak3
        input  wire        hip_pipe_rxdatak4;         //                  .rxdatak4
        input  wire        hip_pipe_rxdatak5;         //                  .rxdatak5
        input  wire        hip_pipe_rxdatak6;         //                  .rxdatak6
        input  wire        hip_pipe_rxdatak7;         //                  .rxdatak7
        input  wire        hip_pipe_rxelecidle0;      //                  .rxelecidle0
        input  wire        hip_pipe_rxelecidle1;      //                  .rxelecidle1
        input  wire        hip_pipe_rxelecidle2;      //                  .rxelecidle2
        input  wire        hip_pipe_rxelecidle3;      //                  .rxelecidle3
        input  wire        hip_pipe_rxelecidle4;      //                  .rxelecidle4
        input  wire        hip_pipe_rxelecidle5;      //                  .rxelecidle5
        input  wire        hip_pipe_rxelecidle6;      //                  .rxelecidle6
        input  wire        hip_pipe_rxelecidle7;      //                  .rxelecidle7
        input  wire [2:0]  hip_pipe_rxstatus0;        //                  .rxstatus0
        input  wire [2:0]  hip_pipe_rxstatus1;        //                  .rxstatus1
        input  wire [2:0]  hip_pipe_rxstatus2;        //                  .rxstatus2
        input  wire [2:0]  hip_pipe_rxstatus3;        //                  .rxstatus3
        input  wire [2:0]  hip_pipe_rxstatus4;        //                  .rxstatus4
        input  wire [2:0]  hip_pipe_rxstatus5;        //                  .rxstatus5
        input  wire [2:0]  hip_pipe_rxstatus6;        //                  .rxstatus6
        input  wire [2:0]  hip_pipe_rxstatus7;        //                  .rxstatus7
        input  wire        hip_pipe_rxvalid0;         //                  .rxvalid0
        input  wire        hip_pipe_rxvalid1;         //                  .rxvalid1
        input  wire        hip_pipe_rxvalid2;         //                  .rxvalid2
        input  wire        hip_pipe_rxvalid3;         //                  .rxvalid3
        input  wire        hip_pipe_rxvalid4;         //                  .rxvalid4
        input  wire        hip_pipe_rxvalid5;         //                  .rxvalid5
        input  wire        hip_pipe_rxvalid6;         //                  .rxvalid6
        input  wire        hip_pipe_rxvalid7;         //                  .rxvalid7
        input  wire        pcie_rstn_npor;            //         pcie_rstn.npor
        input  wire        pcie_rstn_pin_perst;       //                  .pin_perst


      parameter apps_type_hwtcl = 2;

       rp_gen3_x8_ast256 # (
                 .apps_type_hwtcl(apps_type_hwtcl)
                 ) inst (
                 .reconfig_xcvr_clk_clk (reconfig_xcvr_clk_clk),
                 .refclk_clk (refclk_clk),
                 .hip_ctrl_test_in (hip_ctrl_test_in),
                 .hip_ctrl_simu_mode_pipe (hip_ctrl_simu_mode_pipe),
                 .hip_serial_rx_in0 (hip_serial_rx_in0),
                 .hip_serial_rx_in1 (hip_serial_rx_in1),
                 .hip_serial_rx_in2 (hip_serial_rx_in2),
                 .hip_serial_rx_in3 (hip_serial_rx_in3),
                 .hip_serial_rx_in4 (hip_serial_rx_in4),
                 .hip_serial_rx_in5 (hip_serial_rx_in5),
                 .hip_serial_rx_in6 (hip_serial_rx_in6),
                 .hip_serial_rx_in7 (hip_serial_rx_in7),
                 .hip_serial_tx_out0 (hip_serial_tx_out0),
                 .hip_serial_tx_out1 (hip_serial_tx_out1),
                 .hip_serial_tx_out2 (hip_serial_tx_out2),
                 .hip_serial_tx_out3 (hip_serial_tx_out3),
                 .hip_serial_tx_out4 (hip_serial_tx_out4),
                 .hip_serial_tx_out5 (hip_serial_tx_out5),
                 .hip_serial_tx_out6 (hip_serial_tx_out6),
                 .hip_serial_tx_out7 (hip_serial_tx_out7),
                 .hip_pipe_sim_pipe_pclk_in (hip_pipe_sim_pipe_pclk_in),
                 .hip_pipe_sim_pipe_rate (hip_pipe_sim_pipe_rate),
                 .hip_pipe_sim_ltssmstate (hip_pipe_sim_ltssmstate),
                 .hip_pipe_eidleinfersel0 (hip_pipe_eidleinfersel0),
                 .hip_pipe_eidleinfersel1 (hip_pipe_eidleinfersel1),
                 .hip_pipe_eidleinfersel2 (hip_pipe_eidleinfersel2),
                 .hip_pipe_eidleinfersel3 (hip_pipe_eidleinfersel3),
                 .hip_pipe_eidleinfersel4 (hip_pipe_eidleinfersel4),
                 .hip_pipe_eidleinfersel5 (hip_pipe_eidleinfersel5),
                 .hip_pipe_eidleinfersel6 (hip_pipe_eidleinfersel6),
                 .hip_pipe_eidleinfersel7 (hip_pipe_eidleinfersel7),
                 .hip_pipe_powerdown0 (hip_pipe_powerdown0),
                 .hip_pipe_powerdown1 (hip_pipe_powerdown1),
                 .hip_pipe_powerdown2 (hip_pipe_powerdown2),
                 .hip_pipe_powerdown3 (hip_pipe_powerdown3),
                 .hip_pipe_powerdown4 (hip_pipe_powerdown4),
                 .hip_pipe_powerdown5 (hip_pipe_powerdown5),
                 .hip_pipe_powerdown6 (hip_pipe_powerdown6),
                 .hip_pipe_powerdown7 (hip_pipe_powerdown7),
                 .hip_pipe_rxpolarity0 (hip_pipe_rxpolarity0),
                 .hip_pipe_rxpolarity1 (hip_pipe_rxpolarity1),
                 .hip_pipe_rxpolarity2 (hip_pipe_rxpolarity2),
                 .hip_pipe_rxpolarity3 (hip_pipe_rxpolarity3),
                 .hip_pipe_rxpolarity4 (hip_pipe_rxpolarity4),
                 .hip_pipe_rxpolarity5 (hip_pipe_rxpolarity5),
                 .hip_pipe_rxpolarity6 (hip_pipe_rxpolarity6),
                 .hip_pipe_rxpolarity7 (hip_pipe_rxpolarity7),
                 .hip_pipe_txcompl0 (hip_pipe_txcompl0),
                 .hip_pipe_txcompl1 (hip_pipe_txcompl1),
                 .hip_pipe_txcompl2 (hip_pipe_txcompl2),
                 .hip_pipe_txcompl3 (hip_pipe_txcompl3),
                 .hip_pipe_txcompl4 (hip_pipe_txcompl4),
                 .hip_pipe_txcompl5 (hip_pipe_txcompl5),
                 .hip_pipe_txcompl6 (hip_pipe_txcompl6),
                 .hip_pipe_txcompl7 (hip_pipe_txcompl7),
                 .hip_pipe_txdata0 (hip_pipe_txdata0),
                 .hip_pipe_txdata1 (hip_pipe_txdata1),
                 .hip_pipe_txdata2 (hip_pipe_txdata2),
                 .hip_pipe_txdata3 (hip_pipe_txdata3),
                 .hip_pipe_txdata4 (hip_pipe_txdata4),
                 .hip_pipe_txdata5 (hip_pipe_txdata5),
                 .hip_pipe_txdata6 (hip_pipe_txdata6),
                 .hip_pipe_txdata7 (hip_pipe_txdata7),
                 .hip_pipe_txdatak0 (hip_pipe_txdatak0),
                 .hip_pipe_txdatak1 (hip_pipe_txdatak1),
                 .hip_pipe_txdatak2 (hip_pipe_txdatak2),
                 .hip_pipe_txdatak3 (hip_pipe_txdatak3),
                 .hip_pipe_txdatak4 (hip_pipe_txdatak4),
                 .hip_pipe_txdatak5 (hip_pipe_txdatak5),
                 .hip_pipe_txdatak6 (hip_pipe_txdatak6),
                 .hip_pipe_txdatak7 (hip_pipe_txdatak7),
                 .hip_pipe_txdetectrx0 (hip_pipe_txdetectrx0),
                 .hip_pipe_txdetectrx1 (hip_pipe_txdetectrx1),
                 .hip_pipe_txdetectrx2 (hip_pipe_txdetectrx2),
                 .hip_pipe_txdetectrx3 (hip_pipe_txdetectrx3),
                 .hip_pipe_txdetectrx4 (hip_pipe_txdetectrx4),
                 .hip_pipe_txdetectrx5 (hip_pipe_txdetectrx5),
                 .hip_pipe_txdetectrx6 (hip_pipe_txdetectrx6),
                 .hip_pipe_txdetectrx7 (hip_pipe_txdetectrx7),
                 .hip_pipe_txelecidle0 (hip_pipe_txelecidle0),
                 .hip_pipe_txelecidle1 (hip_pipe_txelecidle1),
                 .hip_pipe_txelecidle2 (hip_pipe_txelecidle2),
                 .hip_pipe_txelecidle3 (hip_pipe_txelecidle3),
                 .hip_pipe_txelecidle4 (hip_pipe_txelecidle4),
                 .hip_pipe_txelecidle5 (hip_pipe_txelecidle5),
                 .hip_pipe_txelecidle6 (hip_pipe_txelecidle6),
                 .hip_pipe_txelecidle7 (hip_pipe_txelecidle7),
                 .hip_pipe_txdeemph0 (hip_pipe_txdeemph0),
                 .hip_pipe_txdeemph1 (hip_pipe_txdeemph1),
                 .hip_pipe_txdeemph2 (hip_pipe_txdeemph2),
                 .hip_pipe_txdeemph3 (hip_pipe_txdeemph3),
                 .hip_pipe_txdeemph4 (hip_pipe_txdeemph4),
                 .hip_pipe_txdeemph5 (hip_pipe_txdeemph5),
                 .hip_pipe_txdeemph6 (hip_pipe_txdeemph6),
                 .hip_pipe_txdeemph7 (hip_pipe_txdeemph7),
                 .hip_pipe_phystatus0 (hip_pipe_phystatus0),
                 .hip_pipe_phystatus1 (hip_pipe_phystatus1),
                 .hip_pipe_phystatus2 (hip_pipe_phystatus2),
                 .hip_pipe_phystatus3 (hip_pipe_phystatus3),
                 .hip_pipe_phystatus4 (hip_pipe_phystatus4),
                 .hip_pipe_phystatus5 (hip_pipe_phystatus5),
                 .hip_pipe_phystatus6 (hip_pipe_phystatus6),
                 .hip_pipe_phystatus7 (hip_pipe_phystatus7),
                 .hip_pipe_rxdata0 (hip_pipe_rxdata0),
                 .hip_pipe_rxdata1 (hip_pipe_rxdata1),
                 .hip_pipe_rxdata2 (hip_pipe_rxdata2),
                 .hip_pipe_rxdata3 (hip_pipe_rxdata3),
                 .hip_pipe_rxdata4 (hip_pipe_rxdata4),
                 .hip_pipe_rxdata5 (hip_pipe_rxdata5),
                 .hip_pipe_rxdata6 (hip_pipe_rxdata6),
                 .hip_pipe_rxdata7 (hip_pipe_rxdata7),
                 .hip_pipe_rxdatak0 (hip_pipe_rxdatak0),
                 .hip_pipe_rxdatak1 (hip_pipe_rxdatak1),
                 .hip_pipe_rxdatak2 (hip_pipe_rxdatak2),
                 .hip_pipe_rxdatak3 (hip_pipe_rxdatak3),
                 .hip_pipe_rxdatak4 (hip_pipe_rxdatak4),
                 .hip_pipe_rxdatak5 (hip_pipe_rxdatak5),
                 .hip_pipe_rxdatak6 (hip_pipe_rxdatak6),
                 .hip_pipe_rxdatak7 (hip_pipe_rxdatak7),
                 .hip_pipe_rxelecidle0 (hip_pipe_rxelecidle0),
                 .hip_pipe_rxelecidle1 (hip_pipe_rxelecidle1),
                 .hip_pipe_rxelecidle2 (hip_pipe_rxelecidle2),
                 .hip_pipe_rxelecidle3 (hip_pipe_rxelecidle3),
                 .hip_pipe_rxelecidle4 (hip_pipe_rxelecidle4),
                 .hip_pipe_rxelecidle5 (hip_pipe_rxelecidle5),
                 .hip_pipe_rxelecidle6 (hip_pipe_rxelecidle6),
                 .hip_pipe_rxelecidle7 (hip_pipe_rxelecidle7),
                 .hip_pipe_rxstatus0 (hip_pipe_rxstatus0),
                 .hip_pipe_rxstatus1 (hip_pipe_rxstatus1),
                 .hip_pipe_rxstatus2 (hip_pipe_rxstatus2),
                 .hip_pipe_rxstatus3 (hip_pipe_rxstatus3),
                 .hip_pipe_rxstatus4 (hip_pipe_rxstatus4),
                 .hip_pipe_rxstatus5 (hip_pipe_rxstatus5),
                 .hip_pipe_rxstatus6 (hip_pipe_rxstatus6),
                 .hip_pipe_rxstatus7 (hip_pipe_rxstatus7),
                 .hip_pipe_rxvalid0 (hip_pipe_rxvalid0),
                 .hip_pipe_rxvalid1 (hip_pipe_rxvalid1),
                 .hip_pipe_rxvalid2 (hip_pipe_rxvalid2),
                 .hip_pipe_rxvalid3 (hip_pipe_rxvalid3),
                 .hip_pipe_rxvalid4 (hip_pipe_rxvalid4),
                 .hip_pipe_rxvalid5 (hip_pipe_rxvalid5),
                 .hip_pipe_rxvalid6 (hip_pipe_rxvalid6),
                 .hip_pipe_rxvalid7 (hip_pipe_rxvalid7),
                 .pcie_rstn_npor (pcie_rstn_npor),
                 .pcie_rstn_pin_perst (pcie_rstn_pin_perst) );

endmodule


// Generated using ACDS version 12.0 170 at 2012.04.17.18:35:33

`timescale 1 ps / 1 ps
module rp_gen3_x8_ast256 (
                input  wire        reconfig_xcvr_clk_clk,     // reconfig_xcvr_clk.clk
                input  wire        refclk_clk,                //            refclk.clk
                input  wire [31:0] hip_ctrl_test_in,          //          hip_ctrl.test_in
                input  wire        hip_ctrl_simu_mode_pipe,   //                  .simu_mode_pipe
                input  wire        hip_serial_rx_in0,         //        hip_serial.rx_in0
                input  wire        hip_serial_rx_in1,         //                  .rx_in1
                input  wire        hip_serial_rx_in2,         //                  .rx_in2
                input  wire        hip_serial_rx_in3,         //                  .rx_in3
                input  wire        hip_serial_rx_in4,         //                  .rx_in4
                input  wire        hip_serial_rx_in5,         //                  .rx_in5
                input  wire        hip_serial_rx_in6,         //                  .rx_in6
                input  wire        hip_serial_rx_in7,         //                  .rx_in7
                output wire        hip_serial_tx_out0,        //                  .tx_out0
                output wire        hip_serial_tx_out1,        //                  .tx_out1
                output wire        hip_serial_tx_out2,        //                  .tx_out2
                output wire        hip_serial_tx_out3,        //                  .tx_out3
                output wire        hip_serial_tx_out4,        //                  .tx_out4
                output wire        hip_serial_tx_out5,        //                  .tx_out5
                output wire        hip_serial_tx_out6,        //                  .tx_out6
                output wire        hip_serial_tx_out7,        //                  .tx_out7
                input  wire        hip_pipe_sim_pipe_pclk_in, //          hip_pipe.sim_pipe_pclk_in
                output wire [1:0]  hip_pipe_sim_pipe_rate,    //                  .sim_pipe_rate
                output wire [4:0]  hip_pipe_sim_ltssmstate,   //                  .sim_ltssmstate
                output wire [2:0]  hip_pipe_eidleinfersel0,   //                  .eidleinfersel0
                output wire [2:0]  hip_pipe_eidleinfersel1,   //                  .eidleinfersel1
                output wire [2:0]  hip_pipe_eidleinfersel2,   //                  .eidleinfersel2
                output wire [2:0]  hip_pipe_eidleinfersel3,   //                  .eidleinfersel3
                output wire [2:0]  hip_pipe_eidleinfersel4,   //                  .eidleinfersel4
                output wire [2:0]  hip_pipe_eidleinfersel5,   //                  .eidleinfersel5
                output wire [2:0]  hip_pipe_eidleinfersel6,   //                  .eidleinfersel6
                output wire [2:0]  hip_pipe_eidleinfersel7,   //                  .eidleinfersel7
                output wire [1:0]  hip_pipe_powerdown0,       //                  .powerdown0
                output wire [1:0]  hip_pipe_powerdown1,       //                  .powerdown1
                output wire [1:0]  hip_pipe_powerdown2,       //                  .powerdown2
                output wire [1:0]  hip_pipe_powerdown3,       //                  .powerdown3
                output wire [1:0]  hip_pipe_powerdown4,       //                  .powerdown4
                output wire [1:0]  hip_pipe_powerdown5,       //                  .powerdown5
                output wire [1:0]  hip_pipe_powerdown6,       //                  .powerdown6
                output wire [1:0]  hip_pipe_powerdown7,       //                  .powerdown7
                output wire        hip_pipe_rxpolarity0,      //                  .rxpolarity0
                output wire        hip_pipe_rxpolarity1,      //                  .rxpolarity1
                output wire        hip_pipe_rxpolarity2,      //                  .rxpolarity2
                output wire        hip_pipe_rxpolarity3,      //                  .rxpolarity3
                output wire        hip_pipe_rxpolarity4,      //                  .rxpolarity4
                output wire        hip_pipe_rxpolarity5,      //                  .rxpolarity5
                output wire        hip_pipe_rxpolarity6,      //                  .rxpolarity6
                output wire        hip_pipe_rxpolarity7,      //                  .rxpolarity7
                output wire        hip_pipe_txcompl0,         //                  .txcompl0
                output wire        hip_pipe_txcompl1,         //                  .txcompl1
                output wire        hip_pipe_txcompl2,         //                  .txcompl2
                output wire        hip_pipe_txcompl3,         //                  .txcompl3
                output wire        hip_pipe_txcompl4,         //                  .txcompl4
                output wire        hip_pipe_txcompl5,         //                  .txcompl5
                output wire        hip_pipe_txcompl6,         //                  .txcompl6
                output wire        hip_pipe_txcompl7,         //                  .txcompl7
                output wire [7:0]  hip_pipe_txdata0,          //                  .txdata0
                output wire [7:0]  hip_pipe_txdata1,          //                  .txdata1
                output wire [7:0]  hip_pipe_txdata2,          //                  .txdata2
                output wire [7:0]  hip_pipe_txdata3,          //                  .txdata3
                output wire [7:0]  hip_pipe_txdata4,          //                  .txdata4
                output wire [7:0]  hip_pipe_txdata5,          //                  .txdata5
                output wire [7:0]  hip_pipe_txdata6,          //                  .txdata6
                output wire [7:0]  hip_pipe_txdata7,          //                  .txdata7
                output wire        hip_pipe_txdatak0,         //                  .txdatak0
                output wire        hip_pipe_txdatak1,         //                  .txdatak1
                output wire        hip_pipe_txdatak2,         //                  .txdatak2
                output wire        hip_pipe_txdatak3,         //                  .txdatak3
                output wire        hip_pipe_txdatak4,         //                  .txdatak4
                output wire        hip_pipe_txdatak5,         //                  .txdatak5
                output wire        hip_pipe_txdatak6,         //                  .txdatak6
                output wire        hip_pipe_txdatak7,         //                  .txdatak7
                output wire        hip_pipe_txdetectrx0,      //                  .txdetectrx0
                output wire        hip_pipe_txdetectrx1,      //                  .txdetectrx1
                output wire        hip_pipe_txdetectrx2,      //                  .txdetectrx2
                output wire        hip_pipe_txdetectrx3,      //                  .txdetectrx3
                output wire        hip_pipe_txdetectrx4,      //                  .txdetectrx4
                output wire        hip_pipe_txdetectrx5,      //                  .txdetectrx5
                output wire        hip_pipe_txdetectrx6,      //                  .txdetectrx6
                output wire        hip_pipe_txdetectrx7,      //                  .txdetectrx7
                output wire        hip_pipe_txelecidle0,      //                  .txelecidle0
                output wire        hip_pipe_txelecidle1,      //                  .txelecidle1
                output wire        hip_pipe_txelecidle2,      //                  .txelecidle2
                output wire        hip_pipe_txelecidle3,      //                  .txelecidle3
                output wire        hip_pipe_txelecidle4,      //                  .txelecidle4
                output wire        hip_pipe_txelecidle5,      //                  .txelecidle5
                output wire        hip_pipe_txelecidle6,      //                  .txelecidle6
                output wire        hip_pipe_txelecidle7,      //                  .txelecidle7
                output wire        hip_pipe_txdeemph0,        //                  .txdeemph0
                output wire        hip_pipe_txdeemph1,        //                  .txdeemph1
                output wire        hip_pipe_txdeemph2,        //                  .txdeemph2
                output wire        hip_pipe_txdeemph3,        //                  .txdeemph3
                output wire        hip_pipe_txdeemph4,        //                  .txdeemph4
                output wire        hip_pipe_txdeemph5,        //                  .txdeemph5
                output wire        hip_pipe_txdeemph6,        //                  .txdeemph6
                output wire        hip_pipe_txdeemph7,        //                  .txdeemph7
                output wire [2:0]  hip_pipe_txmargin0,        //                  .txmargin0
                output wire [2:0]  hip_pipe_txmargin1,        //                  .txmargin1
                output wire [2:0]  hip_pipe_txmargin2,        //                  .txmargin2
                output wire [2:0]  hip_pipe_txmargin3,        //                  .txmargin3
                output wire [2:0]  hip_pipe_txmargin4,        //                  .txmargin4
                output wire [2:0]  hip_pipe_txmargin5,        //                  .txmargin5
                output wire [2:0]  hip_pipe_txmargin6,        //                  .txmargin6
                output wire [2:0]  hip_pipe_txmargin7,        //                  .txmargin7
                output wire        hip_pipe_txswing0,         //                  .txswing0
                output wire        hip_pipe_txswing1,         //                  .txswing1
                output wire        hip_pipe_txswing2,         //                  .txswing2
                output wire        hip_pipe_txswing3,         //                  .txswing3
                output wire        hip_pipe_txswing4,         //                  .txswing4
                output wire        hip_pipe_txswing5,         //                  .txswing5
                output wire        hip_pipe_txswing6,         //                  .txswing6
                output wire        hip_pipe_txswing7,         //                  .txswing7
                input  wire        hip_pipe_phystatus0,       //                  .phystatus0
                input  wire        hip_pipe_phystatus1,       //                  .phystatus1
                input  wire        hip_pipe_phystatus2,       //                  .phystatus2
                input  wire        hip_pipe_phystatus3,       //                  .phystatus3
                input  wire        hip_pipe_phystatus4,       //                  .phystatus4
                input  wire        hip_pipe_phystatus5,       //                  .phystatus5
                input  wire        hip_pipe_phystatus6,       //                  .phystatus6
                input  wire        hip_pipe_phystatus7,       //                  .phystatus7
                input  wire [7:0]  hip_pipe_rxdata0,          //                  .rxdata0
                input  wire [7:0]  hip_pipe_rxdata1,          //                  .rxdata1
                input  wire [7:0]  hip_pipe_rxdata2,          //                  .rxdata2
                input  wire [7:0]  hip_pipe_rxdata3,          //                  .rxdata3
                input  wire [7:0]  hip_pipe_rxdata4,          //                  .rxdata4
                input  wire [7:0]  hip_pipe_rxdata5,          //                  .rxdata5
                input  wire [7:0]  hip_pipe_rxdata6,          //                  .rxdata6
                input  wire [7:0]  hip_pipe_rxdata7,          //                  .rxdata7
                input  wire        hip_pipe_rxdatak0,         //                  .rxdatak0
                input  wire        hip_pipe_rxdatak1,         //                  .rxdatak1
                input  wire        hip_pipe_rxdatak2,         //                  .rxdatak2
                input  wire        hip_pipe_rxdatak3,         //                  .rxdatak3
                input  wire        hip_pipe_rxdatak4,         //                  .rxdatak4
                input  wire        hip_pipe_rxdatak5,         //                  .rxdatak5
                input  wire        hip_pipe_rxdatak6,         //                  .rxdatak6
                input  wire        hip_pipe_rxdatak7,         //                  .rxdatak7
                input  wire        hip_pipe_rxelecidle0,      //                  .rxelecidle0
                input  wire        hip_pipe_rxelecidle1,      //                  .rxelecidle1
                input  wire        hip_pipe_rxelecidle2,      //                  .rxelecidle2
                input  wire        hip_pipe_rxelecidle3,      //                  .rxelecidle3
                input  wire        hip_pipe_rxelecidle4,      //                  .rxelecidle4
                input  wire        hip_pipe_rxelecidle5,      //                  .rxelecidle5
                input  wire        hip_pipe_rxelecidle6,      //                  .rxelecidle6
                input  wire        hip_pipe_rxelecidle7,      //                  .rxelecidle7
                input  wire [2:0]  hip_pipe_rxstatus0,        //                  .rxstatus0
                input  wire [2:0]  hip_pipe_rxstatus1,        //                  .rxstatus1
                input  wire [2:0]  hip_pipe_rxstatus2,        //                  .rxstatus2
                input  wire [2:0]  hip_pipe_rxstatus3,        //                  .rxstatus3
                input  wire [2:0]  hip_pipe_rxstatus4,        //                  .rxstatus4
                input  wire [2:0]  hip_pipe_rxstatus5,        //                  .rxstatus5
                input  wire [2:0]  hip_pipe_rxstatus6,        //                  .rxstatus6
                input  wire [2:0]  hip_pipe_rxstatus7,        //                  .rxstatus7
                input  wire        hip_pipe_rxvalid0,         //                  .rxvalid0
                input  wire        hip_pipe_rxvalid1,         //                  .rxvalid1
                input  wire        hip_pipe_rxvalid2,         //                  .rxvalid2
                input  wire        hip_pipe_rxvalid3,         //                  .rxvalid3
                input  wire        hip_pipe_rxvalid4,         //                  .rxvalid4
                input  wire        hip_pipe_rxvalid5,         //                  .rxvalid5
                input  wire        hip_pipe_rxvalid6,         //                  .rxvalid6
                input  wire        hip_pipe_rxvalid7,         //                  .rxvalid7
                input  wire        pcie_rstn_npor,            //         pcie_rstn.npor
                input  wire        pcie_rstn_pin_perst        //                  .pin_perst
        );

        wire          dut_int_msi_serr_out;                      // DUT:serr_out -> APPS:serr_out
        wire          dut_hip_rst_serdes_pll_locked;             // DUT:serdes_pll_locked -> APPS:serdes_pll_locked
        wire          apps_hip_rst_pld_core_ready;               // APPS:pld_core_ready -> DUT:pld_core_ready
        wire          dut_hip_rst_pld_clk_inuse;                 // DUT:pld_clk_inuse -> APPS:pld_clk_inuse
        wire          dut_hip_rst_reset_status;                  // DUT:reset_status -> APPS:reset_status
        wire          dut_hip_rst_sim_pipe_pclk_out;             // DUT:sim_pipe_pclk_out -> APPS:sim_pipe_pclk_out
        wire          dut_hip_rst_testin_zero;                   // DUT:testin_zero -> APPS:testin_zero
        wire          apps_config_tl_cpl_pending;                // APPS:cpl_pending -> DUT:cpl_pending
        wire   [52:0] dut_config_tl_tl_cfg_sts;                  // DUT:tl_cfg_sts -> APPS:tl_cfg_sts
        wire   [31:0] dut_config_tl_tl_cfg_ctl;                  // DUT:tl_cfg_ctl -> APPS:tl_cfg_ctl
        wire    [3:0] dut_config_tl_tl_cfg_add;                  // DUT:tl_cfg_add -> APPS:tl_cfg_add
        wire    [4:0] apps_config_tl_hpg_ctrler;                 // APPS:hpg_ctrler -> DUT:hpg_ctrler
        wire    [6:0] apps_config_tl_cpl_err;                    // APPS:cpl_err -> DUT:cpl_err
        wire          dut_power_mngt_pme_to_sr;                  // DUT:pme_to_sr -> APPS:pme_to_sr
        wire          apps_power_mngt_pm_auxpwr;                 // APPS:pm_auxpwr -> DUT:pm_auxpwr
        wire    [9:0] apps_power_mngt_pm_data;                   // APPS:pm_data -> DUT:pm_data
        wire          apps_power_mngt_pme_to_cr;                 // APPS:pme_to_cr -> DUT:pme_to_cr
        wire          apps_power_mngt_pm_event;                  // APPS:pm_event -> DUT:pm_event
        wire          dut_hip_status_ev128ns;                    // DUT:ev128ns -> APPS:ev128ns
        wire    [3:0] dut_hip_status_int_status;                 // DUT:int_status -> APPS:int_status
        wire          dut_hip_status_ev1us;                      // DUT:ev1us -> APPS:ev1us
        wire          dut_hip_status_derr_cor_ext_rcv;           // DUT:derr_cor_ext_rcv -> APPS:derr_cor_ext_rcv
        wire    [4:0] dut_hip_status_ltssmstate;                 // DUT:ltssmstate -> APPS:ltssmstate
        wire          dut_hip_status_rx_par_err;                 // DUT:rx_par_err -> APPS:rx_par_err
        wire          dut_hip_status_derr_rpl;                   // DUT:derr_rpl -> APPS:derr_rpl
        wire          dut_hip_status_l2_exit;                    // DUT:l2_exit -> APPS:l2_exit
        wire          dut_hip_status_cfg_par_err;                // DUT:cfg_par_err -> APPS:cfg_par_err
        wire    [3:0] dut_hip_status_lane_act;                   // DUT:lane_act -> APPS:lane_act
        wire          dut_hip_status_dlup_exit;                  // DUT:dlup_exit -> APPS:dlup_exit
        wire    [7:0] dut_hip_status_ko_cpl_spc_header;          // DUT:ko_cpl_spc_header -> APPS:ko_cpl_spc_header
        wire          dut_hip_status_hotrst_exit;                // DUT:hotrst_exit -> APPS:hotrst_exit
        wire   [11:0] dut_hip_status_ko_cpl_spc_data;            // DUT:ko_cpl_spc_data -> APPS:ko_cpl_spc_data
        wire    [1:0] dut_hip_status_currentspeed;               // DUT:currentspeed -> APPS:currentspeed
        wire    [1:0] dut_hip_status_tx_par_err;                 // DUT:tx_par_err -> APPS:tx_par_err
        wire          dut_hip_status_dlup;                       // DUT:dlup -> APPS:dlup
        wire          dut_hip_status_derr_cor_ext_rpl;           // DUT:derr_cor_ext_rpl -> APPS:derr_cor_ext_rpl
        wire   [11:0] dut_tx_cred_tx_cred_datafccp;              // DUT:tx_cred_datafccp -> APPS:tx_cred_datafccp
        wire    [7:0] dut_tx_cred_tx_cred_hdrfcnp;               // DUT:tx_cred_hdrfcnp -> APPS:tx_cred_hdrfcnp
        wire    [7:0] dut_tx_cred_tx_cred_hdrfccp;               // DUT:tx_cred_hdrfccp -> APPS:tx_cred_hdrfccp
        wire    [5:0] dut_tx_cred_tx_cred_fchipcons;             // DUT:tx_cred_fchipcons -> APPS:tx_cred_fchipcons
        wire    [7:0] dut_tx_cred_tx_cred_hdrfcp;                // DUT:tx_cred_hdrfcp -> APPS:tx_cred_hdrfcp
        wire   [11:0] dut_tx_cred_tx_cred_datafcp;               // DUT:tx_cred_datafcp -> APPS:tx_cred_datafcp
        wire    [5:0] dut_tx_cred_tx_cred_fcinfinite;            // DUT:tx_cred_fcinfinite -> APPS:tx_cred_fcinfinite
        wire   [11:0] dut_tx_cred_tx_cred_datafcnp;              // DUT:tx_cred_datafcnp -> APPS:tx_cred_datafcnp
        wire          apps_rx_bar_be_rx_st_mask;                 // APPS:rx_st_mask -> DUT:rx_st_mask
        wire   [31:0] dut_rx_bar_be_rx_st_be;                    // DUT:rx_st_be -> APPS:rx_st_be
        wire    [7:0] dut_rx_bar_be_rx_st_bar;                   // DUT:rx_st_bar -> APPS:rx_st_bar
        wire    [1:0] apps_tx_st_endofpacket;                    // APPS:tx_st_eop -> DUT:tx_st_eop
        wire          apps_tx_st_valid;                          // APPS:tx_st_valid -> DUT:tx_st_valid
        wire    [1:0] apps_tx_st_startofpacket;                  // APPS:tx_st_sop -> DUT:tx_st_sop
        wire          apps_tx_st_error;                          // APPS:tx_st_err -> DUT:tx_st_err
        wire  [255:0] apps_tx_st_data;                           // APPS:tx_st_data -> DUT:tx_st_data
        wire    [1:0] apps_tx_st_empty;                          // APPS:tx_st_empty -> DUT:tx_st_empty
        wire          apps_tx_st_ready;                          // DUT:tx_st_ready -> APPS:tx_st_ready
        wire   [31:0] dut_lmi_lmi_dout;                          // DUT:lmi_dout -> APPS:lmi_dout
        wire          apps_lmi_lmi_wren;                         // APPS:lmi_wren -> DUT:lmi_wren
        wire   [31:0] apps_lmi_lmi_din;                          // APPS:lmi_din -> DUT:lmi_din
        wire          apps_lmi_lmi_rden;                         // APPS:lmi_rden -> DUT:lmi_rden
        wire   [11:0] apps_lmi_lmi_addr;                         // APPS:lmi_addr -> DUT:lmi_addr
        wire          dut_lmi_lmi_ack;                           // DUT:lmi_ack -> APPS:lmi_ack
        wire   [1:0]  dut_rx_st_endofpacket;                     // DUT:rx_st_eop -> APPS:rx_st_eop
        wire          rx_st_valid;                           // DUT:rx_st_valid -> APPS:rx_st_valid
        wire   [1:0]  dut_rx_st_startofpacket;                   // DUT:rx_st_sop -> APPS:rx_st_sop
        wire          dut_rx_st_error;                           // DUT:rx_st_err -> APPS:rx_st_err
        wire  [255:0] dut_rx_st_data;                            // DUT:rx_st_data -> APPS:rx_st_data
        wire    [1:0] dut_rx_st_empty;                           // DUT:rx_st_empty -> APPS:rx_st_empty
        wire          dut_rx_st_ready;                           // APPS:rx_st_ready -> DUT:rx_st_ready
        wire  [505:0] dut_reconfig_from_xcvr_reconfig_from_xcvr; // DUT:reconfig_from_xcvr -> APPS:reconfig_from_xcvr
        wire          apps_reconfig_to_xcvr_busy_xcvr_reconfig;  // APPS:busy_xcvr_reconfig -> DUT:busy_xcvr_reconfig
        wire  [769:0] apps_reconfig_to_xcvr_reconfig_to_xcvr;    // APPS:reconfig_to_xcvr -> DUT:reconfig_to_xcvr
        wire          apps_pld_clk_hip_clk;                      // APPS:pld_clk_hip -> DUT:pld_clk
        wire          dut_coreclkout_hip_clk;                    // DUT:coreclkout_hip -> APPS:coreclkout_hip

        parameter apps_type_hwtcl = 2;

        altpcie_sv_hip_ast_hwtcl #(
                .lane_mask_hwtcl                          ("x8"),
                .gen123_lane_rate_mode_hwtcl              ("Gen3 (8.0 Gbps)"),
                .port_type_hwtcl                          ("Root port"),
                .pcie_spec_version_hwtcl                  ("3.0"),
                .ast_width_hwtcl                          ("Avalon-ST 256-bit"),
                .pll_refclk_freq_hwtcl                    ("100 MHz"),
                .set_pld_clk_x1_625MHz_hwtcl              (0),
                .use_ast_parity                           (0),
                .multiple_packets_per_cycle_hwtcl         (1),
                .in_cvp_mode_hwtcl                        (0),
                .hip_reconfig_hwtcl                       (0),
                .enable_tl_only_sim_hwtcl                 (0),
                .use_atx_pll_hwtcl                        (0),
                .bar0_size_mask_hwtcl                     (0),
                .bar0_io_space_hwtcl                      ("Disabled"),
                .bar0_64bit_mem_space_hwtcl               ("Disabled"),
                .bar0_prefetchable_hwtcl                  ("Disabled"),
                .bar1_size_mask_hwtcl                     (0),
                .bar1_io_space_hwtcl                      ("Disabled"),
                .bar1_prefetchable_hwtcl                  ("Disabled"),
                .bar2_size_mask_hwtcl                     (0),
                .bar2_io_space_hwtcl                      ("Disabled"),
                .bar2_64bit_mem_space_hwtcl               ("Disabled"),
                .bar2_prefetchable_hwtcl                  ("Disabled"),
                .bar3_size_mask_hwtcl                     (0),
                .bar3_io_space_hwtcl                      ("Disabled"),
                .bar3_prefetchable_hwtcl                  ("Disabled"),
                .bar4_size_mask_hwtcl                     (0),
                .bar4_io_space_hwtcl                      ("Disabled"),
                .bar4_64bit_mem_space_hwtcl               ("Disabled"),
                .bar4_prefetchable_hwtcl                  ("Disabled"),
                .bar5_size_mask_hwtcl                     (0),
                .bar5_io_space_hwtcl                      ("Disabled"),
                .bar5_prefetchable_hwtcl                  ("Disabled"),
                .expansion_base_address_register_hwtcl    (0),
                .io_window_addr_width_hwtcl               (0),
                .prefetchable_mem_window_addr_width_hwtcl (0),
                .vendor_id_hwtcl                          (4466),
                .device_id_hwtcl                          (57345),
                .revision_id_hwtcl                        (1),
                .class_code_hwtcl                         (16711680),
                .subsystem_vendor_id_hwtcl                (4466),
                .subsystem_device_id_hwtcl                (57345),
             //   .max_payload_size_hwtcl                   (1024),
                .max_payload_size_hwtcl                   (256),
                .extend_tag_field_hwtcl                   ("32"),
                .completion_timeout_hwtcl                 ("ABCD"),
                .enable_completion_timeout_disable_hwtcl  (1),
                .use_aer_hwtcl                            (0),
                .ecrc_check_capable_hwtcl                 (0),
                .ecrc_gen_capable_hwtcl                   (0),
                .use_crc_forwarding_hwtcl                 (0),
                .port_link_number_hwtcl                   (1),
                .dll_active_report_support_hwtcl          (0),
                .surprise_down_error_support_hwtcl        (0),
                .slotclkcfg_hwtcl                         (1),
                .msi_multi_message_capable_hwtcl          ("4"),
                .msi_64bit_addressing_capable_hwtcl       ("true"),
                .msi_masking_capable_hwtcl                ("false"),
                .msi_support_hwtcl                        ("true"),
                .enable_function_msix_support_hwtcl       (0),
                .msix_table_size_hwtcl                    (0),
                .msix_table_offset_hwtcl                  ("0"),
                .msix_table_bir_hwtcl                     (0),
                .msix_pba_offset_hwtcl                    ("0"),
                .msix_pba_bir_hwtcl                       (0),
                .enable_slot_register_hwtcl               (0),
                .slot_power_scale_hwtcl                   (0),
                .slot_power_limit_hwtcl                   (0),
                .slot_number_hwtcl                        (0),
                .rx_ei_l0s_hwtcl                          (0),
                .endpoint_l0_latency_hwtcl                (0),
                .endpoint_l1_latency_hwtcl                (0),
                .vsec_id_hwtcl                            (40960),
                .vsec_rev_hwtcl                           (0),
                .reconfig_to_xcvr_width                   (770),
                .hip_hard_reset_hwtcl                     (0),
                .reconfig_from_xcvr_width                 (506),
                .bypass_cdc_hwtcl                         ("false"),
                .enable_rx_buffer_checking_hwtcl          ("false"),
                .single_rx_detect_hwtcl                   (0),
                .disable_link_x2_support_hwtcl            ("false"),
                .wrong_device_id_hwtcl                    ("disable"),
                .data_pack_rx_hwtcl                       ("disable"),
                .ltssm_1ms_timeout_hwtcl                  ("disable"),
                .ltssm_freqlocked_check_hwtcl             ("disable"),
                .gen3_rxfreqlock_counter_hwtcl            (0),
                .deskew_comma_hwtcl                       ("skp_eieos_deskw"),
                .device_number_hwtcl                      (0),
                .bypass_clk_switch_hwtcl                  ("TRUE"),
                .pipex1_debug_sel_hwtcl                   ("disable"),
                .pclk_out_sel_hwtcl                       ("pclk"),
                .no_soft_reset_hwtcl                      ("false"),
                .maximum_current_hwtcl                    (0),
                .d1_support_hwtcl                         ("false"),
                .d2_support_hwtcl                         ("false"),
                .d0_pme_hwtcl                             ("false"),
                .d1_pme_hwtcl                             ("false"),
                .d2_pme_hwtcl                             ("false"),
                .d3_hot_pme_hwtcl                         ("false"),
                .d3_cold_pme_hwtcl                        ("false"),
                .low_priority_vc_hwtcl                    ("single_vc"),
                .disable_snoop_packet_hwtcl               ("false"),
                .indicator_hwtcl                          (0),
                .enable_l1_aspm_hwtcl                     ("false"),
                .enable_l0s_aspm_hwtcl                    ("true"),
                .l1_exit_latency_sameclock_hwtcl          (0),
                .l1_exit_latency_diffclock_hwtcl          (0),
                .hot_plug_support_hwtcl                   (0),
                .diffclock_nfts_count_hwtcl               (128),
                .sameclock_nfts_count_hwtcl               (128),
                .extended_tag_reset_hwtcl                 ("false"),
                .no_command_completed_hwtcl               ("true"),
                .interrupt_pin_hwtcl                      ("inta"),
                .bridge_port_vga_enable_hwtcl             ("false"),
                .bridge_port_ssid_support_hwtcl           ("false"),
                .ssvid_hwtcl                              (0),
                .ssid_hwtcl                               (0),
                .eie_before_nfts_count_hwtcl              (4),
                .gen2_diffclock_nfts_count_hwtcl          (255),
                .gen2_sameclock_nfts_count_hwtcl          (255),
                .deemphasis_enable_hwtcl                  ("false"),
                .l0_exit_latency_sameclock_hwtcl          (6),
                .l0_exit_latency_diffclock_hwtcl          (6),
                .l2_async_logic_hwtcl                     ("disable"),
                .aspm_config_management_hwtcl             ("true"),
                .atomic_op_routing_hwtcl                  ("false"),
                .atomic_op_completer_32bit_hwtcl          ("false"),
                .atomic_op_completer_64bit_hwtcl          ("false"),
                .cas_completer_128bit_hwtcl               ("false"),
                .ltr_mechanism_hwtcl                      ("false"),
                .tph_completer_hwtcl                      ("false"),
                .extended_format_field_hwtcl              ("true"),
                .atomic_malformed_hwtcl                   ("false"),
                .flr_capability_hwtcl                     ("true"),
                .enable_adapter_half_rate_mode_hwtcl      ("false"),
                .vc0_clk_enable_hwtcl                     ("true"),
                .register_pipe_signals_hwtcl              ("false"),
                .skp_os_gen3_count_hwtcl                  (0),
                .tx_cdc_almost_empty_hwtcl                (5),
                .rx_cdc_almost_full_hwtcl                 (12),
                .tx_cdc_almost_full_hwtcl                 (11),
                .rx_l0s_count_idl_hwtcl                   (0),
                .cdc_dummy_insert_limit_hwtcl             (11),
                .ei_delay_powerdown_count_hwtcl           (10),
                .millisecond_cycle_count_hwtcl            (248500),
                .skp_os_schedule_count_hwtcl              (0),
                .fc_init_timer_hwtcl                      (1024),
                .l01_entry_latency_hwtcl                  (31),
                .flow_control_update_count_hwtcl          (30),
                .flow_control_timeout_count_hwtcl         (200),
                .credit_buffer_allocation_aux_hwtcl       ("absolute"),
                .vc0_rx_flow_ctrl_posted_header_hwtcl     (50),
                .vc0_rx_flow_ctrl_posted_data_hwtcl       (358),
                .vc0_rx_flow_ctrl_nonposted_header_hwtcl  (56),
                .vc0_rx_flow_ctrl_nonposted_data_hwtcl    (0),
                .vc0_rx_flow_ctrl_compl_header_hwtcl      (0),
                .vc0_rx_flow_ctrl_compl_data_hwtcl        (0),
                .cpl_spc_header_hwtcl                     (112),
                .cpl_spc_data_hwtcl                       (448),
                .retry_buffer_last_active_address_hwtcl   (2047),
                .port_width_be_hwtcl                      (32),
                .port_width_data_hwtcl                    (256),
                .gen3_skip_ph2_ph3_hwtcl                  (1),
                .gen3_dcbal_en_hwtcl                      (1),
                .g3_bypass_equlz_hwtcl                    (0),
                .g3_dis_rx_use_prst_hwtcl                 ("false"),
                .g3_dis_rx_use_prst_ep_hwtcl              ("false"),
                .cvp_rate_sel_hwtcl                       ("full_rate"),
                .cvp_data_compressed_hwtcl                ("false"),
                .cvp_data_encrypted_hwtcl                 ("false"),
                .cvp_mode_reset_hwtcl                     ("false"),
                .cvp_clk_reset_hwtcl                      ("false"),
                .cseb_cpl_status_during_cvp_hwtcl         ("config_retry_status"),
                .core_clk_sel_hwtcl                       ("pld_clk"),
                .enable_pipe32_sim_hwtcl                  (0),
                .reserved_debug_hwtcl                     (0),
                .fixed_preset_on                          (0),
                .full_swing_hwtcl                         (35)
        ) dut (
                .npor                   (pcie_rstn_npor),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //               npor.npor
                .pin_perst              (pcie_rstn_pin_perst),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .pin_perst
                .lmi_addr               (apps_lmi_lmi_addr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                lmi.lmi_addr
                .lmi_din                (apps_lmi_lmi_din),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .lmi_din
                .lmi_rden               (apps_lmi_lmi_rden),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .lmi_rden
                .lmi_wren               (apps_lmi_lmi_wren),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .lmi_wren
                .lmi_ack                (dut_lmi_lmi_ack),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .lmi_ack
                .lmi_dout               (dut_lmi_lmi_dout),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .lmi_dout
                .hpg_ctrler             (apps_config_tl_hpg_ctrler),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //          config_tl.hpg_ctrler
                .tl_cfg_add             (dut_config_tl_tl_cfg_add),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .tl_cfg_add
                .tl_cfg_ctl             (dut_config_tl_tl_cfg_ctl),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .tl_cfg_ctl
                .tl_cfg_sts             (dut_config_tl_tl_cfg_sts),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .tl_cfg_sts
                .cpl_err                (apps_config_tl_cpl_err),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .cpl_err
                .cpl_pending            (apps_config_tl_cpl_pending),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                   .cpl_pending
                .pm_auxpwr              (apps_power_mngt_pm_auxpwr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //         power_mngt.pm_auxpwr
                .pm_data                (apps_power_mngt_pm_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .pm_data
                .pme_to_cr              (apps_power_mngt_pme_to_cr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .pme_to_cr
                .pm_event               (apps_power_mngt_pm_event),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .pm_event
                .pme_to_sr              (dut_power_mngt_pme_to_sr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .pme_to_sr
                .currentspeed           (dut_hip_status_currentspeed),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //         hip_status.currentspeed
                .derr_cor_ext_rcv       (dut_hip_status_derr_cor_ext_rcv),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .derr_cor_ext_rcv
                .derr_cor_ext_rpl       (dut_hip_status_derr_cor_ext_rpl),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .derr_cor_ext_rpl
                .derr_rpl               (dut_hip_status_derr_rpl),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .derr_rpl
                .dlup                   (dut_hip_status_dlup),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .dlup
                .dlup_exit              (dut_hip_status_dlup_exit),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .dlup_exit
                .ev128ns                (dut_hip_status_ev128ns),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .ev128ns
                .ev1us                  (dut_hip_status_ev1us),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .ev1us
                .hotrst_exit            (dut_hip_status_hotrst_exit),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                   .hotrst_exit
                .int_status             (dut_hip_status_int_status),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .int_status
                .l2_exit                (dut_hip_status_l2_exit),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .l2_exit
                .lane_act               (dut_hip_status_lane_act),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .lane_act
                .ltssmstate             (dut_hip_status_ltssmstate),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .ltssmstate
                .rx_par_err             (dut_hip_status_rx_par_err),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .rx_par_err
                .tx_par_err             (dut_hip_status_tx_par_err),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .tx_par_err
                .cfg_par_err            (dut_hip_status_cfg_par_err),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                   .cfg_par_err
                .ko_cpl_spc_header      (dut_hip_status_ko_cpl_spc_header),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .ko_cpl_spc_header
                .ko_cpl_spc_data        (dut_hip_status_ko_cpl_spc_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //                   .ko_cpl_spc_data
                .rx_st_valid            (dut_rx_st_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //              rx_st.valid
                .rx_st_sop              (dut_rx_st_startofpacket),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .startofpacket
                .rx_st_eop              (dut_rx_st_endofpacket),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //                   .endofpacket
                .rx_st_empty            (dut_rx_st_empty),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .empty
                .rx_st_ready            (dut_rx_st_ready),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .ready
                .rx_st_err              (dut_rx_st_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .error
                .rx_st_data             (dut_rx_st_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //                   .data
                .rx_st_bar              (dut_rx_bar_be_rx_st_bar),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //          rx_bar_be.rx_st_bar
                .rx_st_be               (dut_rx_bar_be_rx_st_be),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .rx_st_be
                .rx_st_mask             (apps_rx_bar_be_rx_st_mask),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .rx_st_mask
                .tx_st_valid            (apps_tx_st_valid),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //              tx_st.valid
                .tx_st_sop              (apps_tx_st_startofpacket),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .startofpacket
                .tx_st_eop              (apps_tx_st_endofpacket),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .endofpacket
                .tx_st_empty            (apps_tx_st_empty),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .empty
                .tx_st_ready            (apps_tx_st_ready),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .ready
                .tx_st_err              (apps_tx_st_error),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .error
                .tx_st_data             (apps_tx_st_data),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //                   .data
                .tx_cred_datafccp       (dut_tx_cred_tx_cred_datafccp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //            tx_cred.tx_cred_datafccp
                .tx_cred_datafcnp       (dut_tx_cred_tx_cred_datafcnp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    //                   .tx_cred_datafcnp
                .tx_cred_datafcp        (dut_tx_cred_tx_cred_datafcp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //                   .tx_cred_datafcp
                .tx_cred_fchipcons      (dut_tx_cred_tx_cred_fchipcons),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                   .tx_cred_fchipcons
                .tx_cred_fcinfinite     (dut_tx_cred_tx_cred_fcinfinite),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //                   .tx_cred_fcinfinite
                .tx_cred_hdrfccp        (dut_tx_cred_tx_cred_hdrfccp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //                   .tx_cred_hdrfccp
                .tx_cred_hdrfcnp        (dut_tx_cred_tx_cred_hdrfcnp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //                   .tx_cred_hdrfcnp
                .tx_cred_hdrfcp         (dut_tx_cred_tx_cred_hdrfcp),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //                   .tx_cred_hdrfcp
                .pld_clk                (apps_pld_clk_hip_clk),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //            pld_clk.clk
                .coreclkout_hip         (dut_coreclkout_hip_clk),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //     coreclkout_hip.clk
                .refclk                 (refclk_clk),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //             refclk.clk
                .reset_status           (dut_hip_rst_reset_status),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //            hip_rst.reset_status
                .serdes_pll_locked      (dut_hip_rst_serdes_pll_locked),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                   .serdes_pll_locked
                .pld_clk_inuse          (dut_hip_rst_pld_clk_inuse),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //                   .pld_clk_inuse
                .pld_core_ready         (apps_hip_rst_pld_core_ready),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //                   .pld_core_ready
                .testin_zero            (dut_hip_rst_testin_zero),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .testin_zero
                .sim_pipe_pclk_out      (dut_hip_rst_sim_pipe_pclk_out),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   //                   .sim_pipe_pclk_out
                .reconfig_to_xcvr       (apps_reconfig_to_xcvr_reconfig_to_xcvr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //   reconfig_to_xcvr.reconfig_to_xcvr
              //  .busy_xcvr_reconfig     (apps_reconfig_to_xcvr_busy_xcvr_reconfig),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //                   .busy_xcvr_reconfig
                .reconfig_from_xcvr     (dut_reconfig_from_xcvr_reconfig_from_xcvr),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       // reconfig_from_xcvr.reconfig_from_xcvr
                .rx_in0                 (hip_serial_rx_in0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //         hip_serial.rx_in0
                .rx_in1                 (hip_serial_rx_in1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in1
                .rx_in2                 (hip_serial_rx_in2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in2
                .rx_in3                 (hip_serial_rx_in3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in3
                .rx_in4                 (hip_serial_rx_in4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in4
                .rx_in5                 (hip_serial_rx_in5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in5
                .rx_in6                 (hip_serial_rx_in6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in6
                .rx_in7                 (hip_serial_rx_in7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rx_in7
                .tx_out0                (hip_serial_tx_out0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out0
                .tx_out1                (hip_serial_tx_out1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out1
                .tx_out2                (hip_serial_tx_out2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out2
                .tx_out3                (hip_serial_tx_out3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out3
                .tx_out4                (hip_serial_tx_out4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out4
                .tx_out5                (hip_serial_tx_out5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out5
                .tx_out6                (hip_serial_tx_out6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out6
                .tx_out7                (hip_serial_tx_out7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .tx_out7
                .sim_pipe_pclk_in       (hip_pipe_sim_pipe_pclk_in),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       //           hip_pipe.sim_pipe_pclk_in
                .sim_pipe_rate          (hip_pipe_sim_pipe_rate),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //                   .sim_pipe_rate
                .sim_ltssmstate         (hip_pipe_sim_ltssmstate),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .sim_ltssmstate
                .eidleinfersel0         (hip_pipe_eidleinfersel0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel0
                .eidleinfersel1         (hip_pipe_eidleinfersel1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel1
                .eidleinfersel2         (hip_pipe_eidleinfersel2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel2
                .eidleinfersel3         (hip_pipe_eidleinfersel3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel3
                .eidleinfersel4         (hip_pipe_eidleinfersel4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel4
                .eidleinfersel5         (hip_pipe_eidleinfersel5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel5
                .eidleinfersel6         (hip_pipe_eidleinfersel6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel6
                .eidleinfersel7         (hip_pipe_eidleinfersel7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .eidleinfersel7
                .powerdown0             (hip_pipe_powerdown0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown0
                .powerdown1             (hip_pipe_powerdown1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown1
                .powerdown2             (hip_pipe_powerdown2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown2
                .powerdown3             (hip_pipe_powerdown3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown3
                .powerdown4             (hip_pipe_powerdown4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown4
                .powerdown5             (hip_pipe_powerdown5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown5
                .powerdown6             (hip_pipe_powerdown6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown6
                .powerdown7             (hip_pipe_powerdown7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .powerdown7
                .rxpolarity0            (hip_pipe_rxpolarity0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity0
                .rxpolarity1            (hip_pipe_rxpolarity1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity1
                .rxpolarity2            (hip_pipe_rxpolarity2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity2
                .rxpolarity3            (hip_pipe_rxpolarity3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity3
                .rxpolarity4            (hip_pipe_rxpolarity4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity4
                .rxpolarity5            (hip_pipe_rxpolarity5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity5
                .rxpolarity6            (hip_pipe_rxpolarity6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity6
                .rxpolarity7            (hip_pipe_rxpolarity7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxpolarity7
                .txcompl0               (hip_pipe_txcompl0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl0
                .txcompl1               (hip_pipe_txcompl1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl1
                .txcompl2               (hip_pipe_txcompl2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl2
                .txcompl3               (hip_pipe_txcompl3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl3
                .txcompl4               (hip_pipe_txcompl4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl4
                .txcompl5               (hip_pipe_txcompl5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl5
                .txcompl6               (hip_pipe_txcompl6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl6
                .txcompl7               (hip_pipe_txcompl7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txcompl7
                .txdata0                (hip_pipe_txdata0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata0
                .txdata1                (hip_pipe_txdata1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata1
                .txdata2                (hip_pipe_txdata2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata2
                .txdata3                (hip_pipe_txdata3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata3
                .txdata4                (hip_pipe_txdata4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata4
                .txdata5                (hip_pipe_txdata5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata5
                .txdata6                (hip_pipe_txdata6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata6
                .txdata7                (hip_pipe_txdata7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .txdata7
                .txdatak0               (hip_pipe_txdatak0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak0
                .txdatak1               (hip_pipe_txdatak1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak1
                .txdatak2               (hip_pipe_txdatak2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak2
                .txdatak3               (hip_pipe_txdatak3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak3
                .txdatak4               (hip_pipe_txdatak4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak4
                .txdatak5               (hip_pipe_txdatak5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak5
                .txdatak6               (hip_pipe_txdatak6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak6
                .txdatak7               (hip_pipe_txdatak7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txdatak7
                .txdetectrx0            (hip_pipe_txdetectrx0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx0
                .txdetectrx1            (hip_pipe_txdetectrx1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx1
                .txdetectrx2            (hip_pipe_txdetectrx2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx2
                .txdetectrx3            (hip_pipe_txdetectrx3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx3
                .txdetectrx4            (hip_pipe_txdetectrx4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx4
                .txdetectrx5            (hip_pipe_txdetectrx5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx5
                .txdetectrx6            (hip_pipe_txdetectrx6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx6
                .txdetectrx7            (hip_pipe_txdetectrx7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txdetectrx7
                .txelecidle0            (hip_pipe_txelecidle0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle0
                .txelecidle1            (hip_pipe_txelecidle1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle1
                .txelecidle2            (hip_pipe_txelecidle2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle2
                .txelecidle3            (hip_pipe_txelecidle3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle3
                .txelecidle4            (hip_pipe_txelecidle4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle4
                .txelecidle5            (hip_pipe_txelecidle5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle5
                .txelecidle6            (hip_pipe_txelecidle6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle6
                .txelecidle7            (hip_pipe_txelecidle7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .txelecidle7
                .txdeemph0              (hip_pipe_txdeemph0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph0
                .txdeemph1              (hip_pipe_txdeemph1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph1
                .txdeemph2              (hip_pipe_txdeemph2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph2
                .txdeemph3              (hip_pipe_txdeemph3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph3
                .txdeemph4              (hip_pipe_txdeemph4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph4
                .txdeemph5              (hip_pipe_txdeemph5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph5
                .txdeemph6              (hip_pipe_txdeemph6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph6
                .txdeemph7              (hip_pipe_txdeemph7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txdeemph7
                .txmargin0              (hip_pipe_txmargin0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin0
                .txmargin1              (hip_pipe_txmargin1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin1
                .txmargin2              (hip_pipe_txmargin2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin2
                .txmargin3              (hip_pipe_txmargin3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin3
                .txmargin4              (hip_pipe_txmargin4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin4
                .txmargin5              (hip_pipe_txmargin5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin5
                .txmargin6              (hip_pipe_txmargin6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin6
                .txmargin7              (hip_pipe_txmargin7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .txmargin7
                .txswing0               (hip_pipe_txswing0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing0
                .txswing1               (hip_pipe_txswing1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing1
                .txswing2               (hip_pipe_txswing2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing2
                .txswing3               (hip_pipe_txswing3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing3
                .txswing4               (hip_pipe_txswing4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing4
                .txswing5               (hip_pipe_txswing5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing5
                .txswing6               (hip_pipe_txswing6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing6
                .txswing7               (hip_pipe_txswing7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .txswing7
                .phystatus0             (hip_pipe_phystatus0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus0
                .phystatus1             (hip_pipe_phystatus1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus1
                .phystatus2             (hip_pipe_phystatus2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus2
                .phystatus3             (hip_pipe_phystatus3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus3
                .phystatus4             (hip_pipe_phystatus4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus4
                .phystatus5             (hip_pipe_phystatus5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus5
                .phystatus6             (hip_pipe_phystatus6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus6
                .phystatus7             (hip_pipe_phystatus7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //                   .phystatus7
                .rxdata0                (hip_pipe_rxdata0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata0
                .rxdata1                (hip_pipe_rxdata1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata1
                .rxdata2                (hip_pipe_rxdata2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata2
                .rxdata3                (hip_pipe_rxdata3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata3
                .rxdata4                (hip_pipe_rxdata4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata4
                .rxdata5                (hip_pipe_rxdata5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata5
                .rxdata6                (hip_pipe_rxdata6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata6
                .rxdata7                (hip_pipe_rxdata7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //                   .rxdata7
                .rxdatak0               (hip_pipe_rxdatak0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak0
                .rxdatak1               (hip_pipe_rxdatak1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak1
                .rxdatak2               (hip_pipe_rxdatak2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak2
                .rxdatak3               (hip_pipe_rxdatak3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak3
                .rxdatak4               (hip_pipe_rxdatak4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak4
                .rxdatak5               (hip_pipe_rxdatak5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak5
                .rxdatak6               (hip_pipe_rxdatak6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak6
                .rxdatak7               (hip_pipe_rxdatak7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxdatak7
                .rxelecidle0            (hip_pipe_rxelecidle0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle0
                .rxelecidle1            (hip_pipe_rxelecidle1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle1
                .rxelecidle2            (hip_pipe_rxelecidle2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle2
                .rxelecidle3            (hip_pipe_rxelecidle3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle3
                .rxelecidle4            (hip_pipe_rxelecidle4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle4
                .rxelecidle5            (hip_pipe_rxelecidle5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle5
                .rxelecidle6            (hip_pipe_rxelecidle6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle6
                .rxelecidle7            (hip_pipe_rxelecidle7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //                   .rxelecidle7
                .rxstatus0              (hip_pipe_rxstatus0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus0
                .rxstatus1              (hip_pipe_rxstatus1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus1
                .rxstatus2              (hip_pipe_rxstatus2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus2
                .rxstatus3              (hip_pipe_rxstatus3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus3
                .rxstatus4              (hip_pipe_rxstatus4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus4
                .rxstatus5              (hip_pipe_rxstatus5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus5
                .rxstatus6              (hip_pipe_rxstatus6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus6
                .rxstatus7              (hip_pipe_rxstatus7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              //                   .rxstatus7
                .rxvalid0               (hip_pipe_rxvalid0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid0
                .rxvalid1               (hip_pipe_rxvalid1),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid1
                .rxvalid2               (hip_pipe_rxvalid2),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid2
                .rxvalid3               (hip_pipe_rxvalid3),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid3
                .rxvalid4               (hip_pipe_rxvalid4),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid4
                .rxvalid5               (hip_pipe_rxvalid5),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid5
                .rxvalid6               (hip_pipe_rxvalid6),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid6
                .rxvalid7               (hip_pipe_rxvalid7),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //                   .rxvalid7
                .serr_out               (dut_int_msi_serr_out),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //            int_msi.serr_out
                .test_in                (hip_ctrl_test_in),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //           hip_ctrl.test_in
                .simu_mode_pipe         (hip_ctrl_simu_mode_pipe),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //                   .simu_mode_pipe
                .rx_st_parity           (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .tx_st_parity           (32'b00000000000000000000000000000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip0            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip1            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip2            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip3            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip4            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip5            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip6            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxdataskip7            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst0               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst1               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst2               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst3               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst4               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst5               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst6               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxblkst7               (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxsynchd0              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd1              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd2              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd3              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd4              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd5              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd6              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxsynchd7              (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .rxfreqlocked0          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked1          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked2          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked3          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked4          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked5          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked6          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .rxfreqlocked7          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .currentcoeff0          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff1          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff2          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff3          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff4          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff5          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff6          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentcoeff7          (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset0       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset1       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset2       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset3       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset4       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset5       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset6       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .currentrxpreset7       (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd0              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd1              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd2              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd3              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd4              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd5              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd6              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txsynchd7              (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst0               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst1               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst2               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst3               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst4               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst5               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst6               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .txblkst7               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .aer_msi_num            (5'b00000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //        (terminated)
                .pex_msi_num            (5'b00000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //        (terminated)
                .app_int_sts            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .app_msi_num            (5'b00000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //        (terminated)
                .app_msi_req            (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .app_msi_tc             (3'b000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //        (terminated)
                .app_int_ack            (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .app_msi_ack            (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .hip_reconfig_clk       (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .hip_reconfig_rst_n     (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .hip_reconfig_address   (10'b0000000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //        (terminated)
                .hip_reconfig_read      (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .hip_reconfig_write     (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .hip_reconfig_writedata (16'b0000000000000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .hip_reconfig_byte_en   (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .ser_shift_load         (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .interface_sel          (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_link2csr         (13'b0000000000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               //        (terminated)
                .cfgbp_comclk_reg       (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_extsy_reg        (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_max_pload        (3'b000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //        (terminated)
                .cfgbp_tx_ecrcgen       (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_rx_ecrchk        (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_secbus           (8'b00000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //        (terminated)
                .cfgbp_linkcsr_bit0     (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_tx_req_pm        (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_tx_typ_pm        (3'b000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          //        (terminated)
                .cfgbp_req_phypm        (4'b0000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //        (terminated)
                .cfgbp_req_phycfg       (4'b0000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //        (terminated)
                .cfgbp_vc0_tcmap_pld    (7'b0000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      //        (terminated)
                .cfgbp_inh_dllp         (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_inh_tx_tlp       (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_req_wake         (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cfgbp_link3_ctl        (2'b00),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           //        (terminated)
                .cseb_rddata            (32'b00000000000000000000000000000000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cseb_rdresponse        (5'b00000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //        (terminated)
                .cseb_waitrequest       (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cseb_wrresponse        (5'b00000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        //        (terminated)
                .cseb_wrresp_valid      (1'b0),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            //        (terminated)
                .cseb_rddata_parity     (4'b0000),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         //        (terminated)
                .tlbfm_in               (),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                //        (terminated)
                .tlbfm_out              (1001'b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)  //        (terminated)
        );

        altpcied_sv_hwtcl #(
                .device_family_hwtcl           ("Stratix V"),
                .lane_mask_hwtcl               ("x8"),
                .gen123_lane_rate_mode_hwtcl   ("Gen3 (8.0 Gbps)"),
                .pld_clockrate_hwtcl           (250000000),
                .port_type_hwtcl               ("Root port"),
                .ast_width_hwtcl               ("Avalon-ST 256-bit"),
                .extend_tag_field_hwtcl        (32),
                .max_payload_size_hwtcl        (256),
                .num_of_func_hwtcl             (1),
             //   .reconfig_to_xcvr_width        (770),
             //   .reconfig_from_xcvr_width      (506),
            //    .number_of_reconfig_interfaces (11),
                .port_width_be_hwtcl           (32),
                .port_width_data_hwtcl         (256),
                .avalon_waddr_hwltcl           (12),
                .check_bus_master_ena_hwtcl    (1),
                .check_rx_buffer_cpl_hwtcl     (1),
                .use_crc_forwarding_hwtcl      (0),
                .apps_type_hwtcl               (apps_type_hwtcl),
                .multiple_packets_per_cycle_hwtcl(1)
           //     .bypass_xcvrreconfig           (1)
        ) apps (
                .coreclkout_hip      (dut_coreclkout_hip_clk),                    //     coreclkout_hip.clk
                .pld_clk_hip         (apps_pld_clk_hip_clk),                      //        pld_clk_hip.clk
                .rx_st_valid         (dut_rx_st_valid),                           //              rx_st.valid
                .rx_st_sop           (dut_rx_st_startofpacket),                   //                   .startofpacket
                .rx_st_eop           (dut_rx_st_endofpacket),                     //                   .endofpacket
                .rx_st_empty         (dut_rx_st_empty),                           //                   .empty
                .rx_st_ready         (dut_rx_st_ready),                           //                   .ready
                .rx_st_err           (dut_rx_st_error),                           //                   .error
                .rx_st_data          (dut_rx_st_data),                            //                   .data
                .rx_st_bar           (dut_rx_bar_be_rx_st_bar),                   //          rx_bar_be.rx_st_bar
                .rx_st_be            (dut_rx_bar_be_rx_st_be),                    //                   .rx_st_be
                .rx_st_mask          (apps_rx_bar_be_rx_st_mask),                 //                   .rx_st_mask
                .tx_st_valid         (apps_tx_st_valid),                          //              tx_st.valid
                .tx_st_sop           (apps_tx_st_startofpacket),                  //                   .startofpacket
                .tx_st_eop           (apps_tx_st_endofpacket),                    //                   .endofpacket
                .tx_st_empty         (apps_tx_st_empty),                          //                   .empty
                .tx_st_ready         (apps_tx_st_ready),                          //                   .ready
                .tx_st_err           (apps_tx_st_error),                          //                   .error
                .tx_st_data          (apps_tx_st_data),                           //                   .data
                .tx_cred_datafccp    (dut_tx_cred_tx_cred_datafccp),              //            tx_cred.tx_cred_datafccp
                .tx_cred_datafcnp    (dut_tx_cred_tx_cred_datafcnp),              //                   .tx_cred_datafcnp
                .tx_cred_datafcp     (dut_tx_cred_tx_cred_datafcp),               //                   .tx_cred_datafcp
                .tx_cred_fchipcons   (dut_tx_cred_tx_cred_fchipcons),             //                   .tx_cred_fchipcons
                .tx_cred_fcinfinite  (dut_tx_cred_tx_cred_fcinfinite),            //                   .tx_cred_fcinfinite
                .tx_cred_hdrfccp     (dut_tx_cred_tx_cred_hdrfccp),               //                   .tx_cred_hdrfccp
                .tx_cred_hdrfcnp     (dut_tx_cred_tx_cred_hdrfcnp),               //                   .tx_cred_hdrfcnp
                .tx_cred_hdrfcp      (dut_tx_cred_tx_cred_hdrfcp),                //                   .tx_cred_hdrfcp
                .reset_status        (dut_hip_rst_reset_status),                  //            hip_rst.reset_status
                .serdes_pll_locked   (dut_hip_rst_serdes_pll_locked),             //                   .serdes_pll_locked
                .pld_clk_inuse       (dut_hip_rst_pld_clk_inuse),                 //                   .pld_clk_inuse
                .pld_core_ready      (apps_hip_rst_pld_core_ready),               //                   .pld_core_ready
                .testin_zero         (dut_hip_rst_testin_zero),                   //                   .testin_zero
                .sim_pipe_pclk_out   (dut_hip_rst_sim_pipe_pclk_out),             //                   .sim_pipe_pclk_out
              //  .reconfig_to_xcvr    (apps_reconfig_to_xcvr_reconfig_to_xcvr),    //   reconfig_to_xcvr.reconfig_to_xcvr
              //  .busy_xcvr_reconfig  (apps_reconfig_to_xcvr_busy_xcvr_reconfig),  //                   .busy_xcvr_reconfig
              //  .reconfig_from_xcvr  (dut_reconfig_from_xcvr_reconfig_from_xcvr), // reconfig_from_xcvr.reconfig_from_xcvr
              //  .reconfig_xcvr_clk   (reconfig_xcvr_clk_clk),                     //  reconfig_xcvr_clk.clk
                .serr_out            (dut_int_msi_serr_out),                      //            int_msi.serr_out
              //  .currentspeed        (dut_hip_status_currentspeed),               //         hip_status.currentspeed
                .derr_cor_ext_rcv    (dut_hip_status_derr_cor_ext_rcv),           //                   .derr_cor_ext_rcv
                .derr_cor_ext_rpl    (dut_hip_status_derr_cor_ext_rpl),           //                   .derr_cor_ext_rpl
                .derr_rpl            (dut_hip_status_derr_rpl),                   //                   .derr_rpl
                .dlup_exit           (dut_hip_status_dlup_exit),                  //                   .dlup_exit
                .ev128ns             (dut_hip_status_ev128ns),                    //                   .ev128ns
                .ev1us               (dut_hip_status_ev1us),                      //                   .ev1us
                .hotrst_exit         (dut_hip_status_hotrst_exit),                //                   .hotrst_exit
                .int_status          (dut_hip_status_int_status),                 //                   .int_status
                .l2_exit             (dut_hip_status_l2_exit),                    //                   .l2_exit
                .lane_act            (dut_hip_status_lane_act),                   //                   .lane_act
                .ltssmstate          (dut_hip_status_ltssmstate),                 //                   .ltssmstate
                .dlup                (dut_hip_status_dlup),                       //                   .dlup
                .rx_par_err          (dut_hip_status_rx_par_err),                 //                   .rx_par_err
                .tx_par_err          (dut_hip_status_tx_par_err),                 //                   .tx_par_err
                .cfg_par_err         (dut_hip_status_cfg_par_err),                //                   .cfg_par_err
                .ko_cpl_spc_header   (dut_hip_status_ko_cpl_spc_header),          //                   .ko_cpl_spc_header
                .ko_cpl_spc_data     (dut_hip_status_ko_cpl_spc_data),            //                   .ko_cpl_spc_data
                .hpg_ctrler          (apps_config_tl_hpg_ctrler),                 //          config_tl.hpg_ctrler
                .tl_cfg_ctl          (dut_config_tl_tl_cfg_ctl),                  //                   .tl_cfg_ctl
                .cpl_err             (apps_config_tl_cpl_err),                    //                   .cpl_err
                .tl_cfg_add          (dut_config_tl_tl_cfg_add),                  //                   .tl_cfg_add
                .tl_cfg_sts          (dut_config_tl_tl_cfg_sts),                  //                   .tl_cfg_sts
                .cpl_pending         (apps_config_tl_cpl_pending),                //                   .cpl_pending
                .lmi_addr            (apps_lmi_lmi_addr),                         //                lmi.lmi_addr
                .lmi_din             (apps_lmi_lmi_din),                          //                   .lmi_din
                .lmi_rden            (apps_lmi_lmi_rden),                         //                   .lmi_rden
                .lmi_wren            (apps_lmi_lmi_wren),                         //                   .lmi_wren
                .lmi_ack             (dut_lmi_lmi_ack),                           //                   .lmi_ack
                .lmi_dout            (dut_lmi_lmi_dout),                          //                   .lmi_dout
                .pm_auxpwr           (apps_power_mngt_pm_auxpwr),                 //         power_mngt.pm_auxpwr
                .pm_data             (apps_power_mngt_pm_data),                   //                   .pm_data
                .pme_to_cr           (apps_power_mngt_pme_to_cr),                 //                   .pme_to_cr
                .pm_event            (apps_power_mngt_pm_event),                  //                   .pm_event
                .pme_to_sr           (dut_power_mngt_pme_to_sr),                  //                   .pme_to_sr
                .rx_st_parity        (32'b00000000000000000000000000000000),      //        (terminated)
                .rx_bar_dec_func_num (3'b000),                                    //        (terminated)
                .tx_st_parity        (),                                          //        (terminated)
                .tx_fifo_empty       (1'b1),                                      //        (terminated)
                .tl_cfg_ctl_wr       (1'b0),                                      //        (terminated)
                .tl_cfg_sts_wr       (1'b0),                                      //        (terminated)
                .cpl_err_func        (),                                          //        (terminated)
                .pm_event_func       ()                                           //        (terminated)
        );

endmodule


// synthesis translate_off
`timescale 1ps / 1ps
// synthesis translate_on

module altpcietb_rst_clk # ( parameter REFCLK_HALF_PERIOD = 5000) (
   output reg ref_clk_out,
   output reg pcie_rstn,
   output reg rp_rstn
);

  always
    #REFCLK_HALF_PERIOD  ref_clk_out <= ~ref_clk_out;

  initial
    begin
      pcie_rstn         = 1'b1;
      rp_rstn           = 1'b1;
      ref_clk_out       = 1'b0;
      #1000
      pcie_rstn         = 1'b0;
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #1000
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #200000 pcie_rstn = 1'b1;
      #100000 rp_rstn   = 1'b1;
    end

endmodule






// /**
//  * This Verilog HDL file is used for simulation in
//  * the chained DMA design example.
//  */
`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port Driver for the chained DMA
//                 design example
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_driver.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description : This module is driver for the Root Port BFM for the chained DMA
//               design example.
//     The main process (begin : main) operates in two stages:
//        - EP configuration using the task ebfm_cfg_rp_ep
//        - Run a chained DMA transfer with the task chained_dma_test
//
//    Chained DMA operation:
//       The chained DMA consist of a DMA Write and a DMA Read sub-module
//       Each DMA use a separate descriptor table mapped in the share memeory
//       The descriptor table contains a header with 3 DWORDs (DW0, DW1, DW2)
//
//       |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16|15 .................0
//   ----|---------------------------------------------------------------------
//       | R|        |         |              |  | E|M| D |
//   DW0 | E| MSI    |         |              |  | P|S| I |
//       | S|TRAFFIC |         |              |  | L|I| R |
//       | E|CLASS   | RESERVED|  MSI         |1 | A| | E |      SIZE:Number
//       | R|        |         |  NUMBER      |  | S| | C |   of DMA descriptor
//       | V|        |         |              |  | T| | T |
//       | E|        |         |              |  |  | | I |
//       | D|        |         |              |  |  | | O |
//       |  |        |         |              |  |  | | N |
//   ----|---------------------------------------------------------------------
//   DW1 |                                       BDT_MSB
//   ----|---------------------------------------------------------------------
//   DW2 |                                       BDT_LSB
//   ----|---------------------------------------------------------------------
//
// RC memory map Overview - Descriptor section
//
//   RC memory  : 2Mbyte 0h -> 200000h
//   BRC+00000h : Descriptor table write
//   BRC+00100h : Descriptor table read
//   BRC+01000h : Data for write
//   BRC+05000h : Data for read
//
//-----------------------------------------------------------------------------
//
// Abreviation:
//     EP      : End Point
//     RC      : Root complex
//     DT      : Descriptor Table
//     MWr     : Memory write
//     MRd     : Memory read
//     CPLD    : Completion with data
//     MSI     : PCIe Message Signaled Interrupt
//     BDT     : Base address of the descriptor header table in RC memory
//     BDT_LSB : Base address of the descriptor header table in RC memory
//     BDT_MSB : Base address of the descriptor header table in RC memory
//     BRC     : [BDT_MSB:BDT_LSB]
//     DW0     : First DWORD of the descriptor table header
//     DW1     : Second DWORD of the descriptor table header
//     DW2     : Third DWORD of the descriptor table header
//     RCLAST  : RC MWr RCLAST in EP memeory to reflects the number
//               of DMA transfers ready to start
//     EPLAST  : EP MWr EPLAST in shared memeory to reflects the number
//               of completed DMA transfers
//
//-----------------------------------------------------------------------------
// Copyright � 2006 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
`define STR_SEP "---------"

module altpcietb_bfm_driver_rp (input clk_in,
                             input INTA,
                             input INTB,
                             input INTC,
                             input INTD,
                             input rstn,
                             output dummy_out);

   // TEST_LEVEL is a parameter passed in from the top level test bench that
   // could control the amount of testing done. It is not currently used.

   // Global parameter
   parameter  TEST_LEVEL            = 1;
   parameter  TL_BFM_MODE           = 1'b0;
   parameter  TL_BFM_RP_CAP_REG     = 32'h42;    // In TL BFM mode, pass PCIE Capabilities reg thru parameter (- there is no RP config space).
                                                 // {specify:  port type, cap version}
   parameter  TL_BFM_RP_DEV_CAP_REG = 32'h05;    // In TL BFM mode, pass Device Capabilities reg thru parameter (- there is no RP config space)..
                                                 // {specify:  maxpayld size}

   parameter RUN_TGT_MEM_TST = 1;
   parameter RUN_DMA_MEM_TST = 1;
   parameter AVALON_MM_LITE = 0;
   parameter DMA_BASE   = 32'h0000_4000;
   parameter CRA_BASE   = 32'h0000_0000;
   parameter MEM_OFFSET = 32'h0020_0000;


   parameter  APPS_TYPE_HWTCL       = 2;
   localparam DISPLAY_ALL           = 0;
   localparam NUMBER_OF_DESCRIPTORS = 4;
   localparam SCR_MEM               = 4096;// Share memory base address used by DMA
   localparam SCR_MEMSLAVE          = 64;// Share memory base address used by RC Slave module
   localparam TIMEOUT_POLLING       = 1024;// number of clock' for timout
   localparam USE_CDMA              = 1;   // When set enable EP upstream MRd/MWr
                                           // using the chaining DMA module
   localparam RCSLAVE_MAXLEN = 10;  // maximum number of read/write
   localparam SCR_MEM_DOWNSTREAM_WR = SCR_MEMSLAVE;
   localparam SCR_MEM_DOWNSTREAM_RD = SCR_MEMSLAVE+2048;


   // Descriptor Table Parameters
   localparam DT_EPLAST = 4'hc;
   localparam MEM_DESCR_LENGTH_INC = 2;
   localparam DMA_CONTINOUS_LOOP = 0;

   // Write DMA DESCRIPTOR TABLE Content
   localparam integer WR_DIRECTION        = 1;
   localparam integer WR_DESCRIPTOR_DEPTH = 4; // 4 DWORDS
   localparam integer WR_BDT_LSB          = SCR_MEM;
   localparam integer WR_BDT_MSB          = 0;
   localparam integer WR_FIRST_DESCRIPTOR = WR_BDT_LSB+WR_BDT_MSB+16;

   localparam integer WR_DESC0_LENGTH     = 82;
   localparam integer WR_DESC0_EPADDR     = 12;
   localparam integer WR_DESC0_RCADDR_MSB = 0;
   localparam integer WR_DESC0_RCADDR_LSB = WR_BDT_LSB+4096;
   localparam integer WR_DESC0_INIT_BFM_MEM = 64'h0000_0000_1515_0001;

   localparam integer WR_DESC1_LENGTH     = 1024;
   localparam integer WR_DESC1_EPADDR     = 0;
   localparam integer WR_DESC1_RCADDR_MSB = 0;
   localparam integer WR_DESC1_RCADDR_LSB = WR_BDT_LSB+8192;
   localparam integer WR_DESC1_INIT_BFM_MEM = 64'h0000_0000_2525_0001;

   localparam integer WR_DESC2_LENGTH     = 644;
   localparam integer WR_DESC2_EPADDR     = 0;
   localparam integer WR_DESC2_RCADDR_MSB = 0;
   localparam integer WR_DESC2_RCADDR_LSB = WR_BDT_LSB+20384;
   localparam integer WR_DESC2_INIT_BFM_MEM = 64'h0000_0000_3535_0001;

   // READ DMA DESCRIPTOR TABLE Content
   localparam integer RD_DIRECTION        = 0;
   localparam integer RD_DESCRIPTOR_DEPTH = 4;
   localparam integer RD_BDT_LSB          = SCR_MEM+512;
   localparam integer RD_BDT_MSB          = 0;
   localparam integer RD_FIRST_DESCRIPTOR = RD_BDT_LSB+RD_BDT_MSB+16;

   localparam integer RD_DESC0_LENGTH     = 82;
   localparam integer RD_DESC0_EPADDR     = 12;
   localparam integer RD_DESC0_RCADDR_MSB = 0;
   localparam integer RD_DESC0_RCADDR_LSB = RD_BDT_LSB+34032;
   localparam integer RD_DESC0_INIT_BFM_MEM = 64'h0000_0000_AAAA_0001;

   localparam integer RD_DESC1_LENGTH     = 1024;
   localparam integer RD_DESC1_EPADDR     = 0;
   localparam integer RD_DESC1_RCADDR_MSB = 0;
   localparam integer RD_DESC1_RCADDR_LSB = RD_BDT_LSB+65536;
   localparam integer RD_DESC1_INIT_BFM_MEM = 64'h0000_0000_BBBB_0001;

   localparam integer RD_DESC2_LENGTH     = 644;
   localparam integer RD_DESC2_EPADDR     = 0;
   localparam integer RD_DESC2_RCADDR_MSB = 0;
   localparam integer RD_DESC2_RCADDR_LSB = RD_BDT_LSB+132592;
   localparam integer RD_DESC2_INIT_BFM_MEM = 64'h0000_0000_CCCC_0001;

   localparam DEBUG_PRG = 0;

   `include "altpcietb_g3bfm_constants.v"
   `include "altpcietb_g3bfm_log.v"
   `include "altpcietb_g3bfm_shmem.v"
   `include "altpcietb_g3bfm_rdwr.v"
   `include "altpcietb_g3bfm_configure.v"




   // The clk_in and rstn signals are provided for possible use in controlling
   // the transactions issued, they are not currently used.

// ebfm_display_verb
// overload ebfm_display by turning on/off verbose when DISPLAY_ALL>0
function ebfm_display_verb(
   input integer msg_type,
   input [EBFM_MSG_MAX_LEN*8:1] message);
   reg unused_result ;
   begin
      if (DISPLAY_ALL==1)
         unused_result = ebfm_display(msg_type, message);
      ebfm_display_verb = 1'b0 ;
   end
endfunction

/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_set_msi:
//
// Setup native PCIe MSI for DMA read and DMA write.
// Retrieve MSI capabilities of EP, program EP MSI cfg register
// with msi_address and msi_data
//
// input argument:
//        bar_table    : Pointer to the BAR sizing and
//        setup_bar    : BAR to be used for setting up
//        bus_num      : default 1
//        dev_num      : default 0
//        fnc_num      : default 0
//        dt_direction : Read or write
//        msi_address  : RC Mem MSI address
//        msi_data     : MSI cgf data
//
// returns:
//       msi_number (default : 1 for write , 0 for read)
//       msi_traffic_class MSI traffic class (default 0)
//       msi_expected Expected data written by MSI to RC Host memory
//
task dma_set_msi (
   input integer bar_table    ,
   input integer setup_bar    ,
   input integer bus_num      ,
   input integer dev_num      ,
   input integer fnc_num      ,
   input integer dt_direction ,
   input integer msi_address  ,
   input integer msi_data     ,

   output reg [4:0] msi_number       ,
   output reg [2:0] msi_traffic_class,
   output reg [2:0] multi_message_enable,
   output integer msi_expected
   );

   localparam msi_capabilities  = 32'h50;
   // The Root Complex BFM has 2MB of address space
   localparam msi_upper_address = 32'h0000_0000;

   reg [15:0] msi_control_register;
   reg        msi_64b_capable;
   reg [2:0]  multi_message_capable;
   reg        msi_enable;
   reg [2:0]  compl_status;
   reg unused_result ;

   begin

      // MSI
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      if (dt_direction==RD_DIRECTION)
         unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_msi READ");
      else
         unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_msi WRITE");

      unused_result = ebfm_display_verb(EBFM_MSG_INFO,
                        " Message Signaled Interrupt Configuration");
      // Read the contents of the MSI Control register
      msi_traffic_class = 0; //TODO make it an input argument

      unused_result = ebfm_display(EBFM_MSG_INFO, {"  msi_address (RC memory)= 0x",
                                                    himage4(msi_address)});

      // RC Reading MSI capabilities of the EP
      // to get msi_control_register
      ebfm_cfgrd_wait(bus_num, dev_num, fnc_num,
                      msi_capabilities, 4,
                      msi_address,
                      compl_status);
      msi_control_register  = shmem_read(msi_address+2, 2);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  msi_control_register = 0x",
                                             himage4(msi_control_register)});

      // Program the MSI Message Control register for testing
      msi_64b_capable       = msi_control_register[7];
      // Enable the MSI with Maximum Number of Supported Messages
      multi_message_capable = msi_control_register[3:1];
      multi_message_enable  = multi_message_capable;
      msi_enable            = 1'b1;
      ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                          msi_capabilities, 4,
                          {8'h00, msi_64b_capable,
                          multi_message_enable,
                          multi_message_capable,
                          msi_enable, 16'h0000},
                          compl_status);

      msi_number[4:0]= (1==dt_direction)?5'h1:5'h0;

      // Retrieve msi_expected
      if (multi_message_enable==3'b000)
         begin
            unused_result = ebfm_display(EBFM_MSG_WARNING,
                "The chained DMA example design required at least 2 MSI ");
            unused_result = ebfm_log_stop_sim(1);
         end
      else
         begin
            case (multi_message_enable)
               3'b000:  msi_expected =  msi_data[15:0];
               3'b001:  msi_expected = {msi_data[15:1], msi_number[0]  };
               3'b010:  msi_expected = {msi_data[15:2], msi_number[1:0]};
               3'b011:  msi_expected = {msi_data[15:3], msi_number[2:0]};
               3'b100:  msi_expected = {msi_data[15:4], msi_number[3:0]};
               3'b101:  msi_expected = {msi_data[15:5], msi_number[4:0]};
               default: unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL,
             "Illegal multi_message_enable value detected. MSI test fails.");
            endcase
         end

      // Write the rest of the MSI Capabilities Structure:
      //            Address and Data Fields
     if (msi_64b_capable) // 64-bit Addressing
         begin
            // Specify the RC lower Address where the MSI need to be written
            // when EP issues MSI (msi_address= dt_bdt_lsb-16)
            // 4 DWORD bellow the descriptor table
            ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                                msi_capabilities + 4'h4, 4,
                                msi_address,
                                compl_status);
            // Specify the RC Upper Address where the MSI need to be written
            // when EP issues MSI
            ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                                msi_capabilities + 4'h8, 4,
                                msi_upper_address,
                                compl_status);
            // Specify the data to be written in the RC Memeoryr MSI location
            // when EP issues MSI
            // (msi_data = 16'hb0fe)
            ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                                msi_capabilities + 4'hC, 4,
                                msi_data,
                                compl_status);
         end
      else // 32-bit Addressing
         begin
            // Specify the RC lower Address where the MSI need to be written
            // when EP issues MSI (msi_address= dt_bdt_lsb-16)
            // 4 DWORD bellow the descriptor table
            ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                                msi_capabilities + 4'h4, 4,
                                msi_address, compl_status);
            // Specify the data to be written in the RC Memeoryr MSI location
            // when EP issues MSI
            // (msi_data = 16'hb0fe)
            ebfm_cfgwr_imm_wait(bus_num, dev_num, fnc_num,
                                msi_capabilities + 4'h8, 4,
                                msi_data, compl_status);
         end

   // Clear RC memory MSI Location
   shmem_write(msi_address,  32'h1111_FADE,4);

   unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  msi_expected = 0x",
                                          himage4(msi_expected)});

   unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  msi_capabilities address = 0x",
                                          himage4(msi_capabilities)});

   unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  multi_message_enable = 0x",
                                          himage4(multi_message_enable)});

   unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  msi_number = ",
                                          dimage4(msi_number)});

   unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"  msi_traffic_class = ",
                                          dimage4(msi_traffic_class)});

end


endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_set_header :
//
// RC issues MWr to write Descriptor table header DW0, DW1, DW2
// RC initializaed RC shared memory with MSI_DATA, DW0, DW1, DW2
//
// Descriptor header table in EP shared memory :
//
//  |----------------------------------------------
//  | DMA Write
//  |----------------------------------------------
//  | 0h     | DW0
//  |--------|-------------------------------------
//  | 04h    | DW1
//  |--------|-------------------------------------
//  | 08h    | DW2
//  |--------|-------------------------------------
//  | 0ch    | RCLast
//  |        | RC MWr RCLast : Available DMA number
//  |----------------------------------------------
//  | DMA Read
//  |----------------------------------------------
//  |10h     | DW0
//  |--------|-------------------------------------
//  |14h     | DW1
//  |--------|-------------------------------------
//  |18h     | DW2
//  |--------|-------------------------------------
//  |1ch     | RCLast
//  |        | RC MWr RCLast : Available DMA number
//  |----------------------------------------------
//
// Descriptor header table in RC shared memory :
//
//  |--------|----------------------------------------------
//  | -10h   | MSI_DATA
//  |        | EP MWr MSI at the end of DMA transfer
//  |--------|----------------------------------------------
//  |BDT LSB | DW0
//  |--------|----------------------------------------------
//  |+04h    | DW1
//  |--------|----------------------------------------------
//  |+08h    | DW2
//  |--------|----------------------------------------------
//  |+0ch    | EPLAST
//  |        | EP MWr EPLAST to reflects DMA transfer number
//  |-------------------------------------------------------
//
task dma_set_header (
   input integer bar_table    , // Pointer to the BAR sizing and
   input integer setup_bar    , // BAR to be used for setting up
   input integer dt_size      , // number of descriptor in the descriptor
   input integer dt_direction , // Read or write
   input integer dt_msi       , // status bit for DMA MSI
   input integer dt_eplast    , // status bit to write back ep_counter info
   input integer dt_bdt_msb   , // RC upper 32 bits base address of the dt
   input integer dt_bdt_lsb   ,  // RC lower 32 bits base address of the dt

   input [4:0] msi_number       ,   // MSI
   input [2:0] msi_traffic_class,   // MSI
   input [2:0] multi_message_enable, // MSI
   input stop_dma_loop
   );

   reg [31:0] dt_dw0;
   integer dt_dw1,dt_dw2 ;
   integer ep_offset ;
   reg unused_result ;

   begin

      // Constructing header dsecriptor table DWORDS DW0
      dt_dw0[15:0]  = dt_size;
      dt_dw0[16]    = (dt_direction==RD_DIRECTION)?1'b0:1'b1;
      dt_dw0[17]    = (dt_msi      ==0)?1'b0:1'b1;
      dt_dw0[18]    = (dt_eplast   ==0)?1'b0:1'b1;
      dt_dw0[19]    = ((multi_message_enable==3'b000)&& (dt_msi==1))?1'b1:1'b0;
      dt_dw0[24:20] = (dt_msi==1)?msi_number[4:0]:0;
      dt_dw0[27:25] = 3'b000;
      dt_dw0[30:28] = (dt_msi==1)?msi_traffic_class:0;
      dt_dw0[31]    = ((DMA_CONTINOUS_LOOP>0)&&(stop_dma_loop==1'b0))?1'b1:1'b0;

      // Constructing header dsecriptor table DWORDS DW1
      dt_dw1 = dt_bdt_msb;

      // Constructing header dsecriptor table DWORDS DW2
      dt_dw2 = dt_bdt_lsb;

      // DMA Write ep_offset /BAR = 0;
      // DMA Read ep_offset  /BAR = 16 (4 DWORDs);
      ep_offset = (WR_DIRECTION==dt_direction)?0:16;

      // display section
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      if (dt_direction==RD_DIRECTION)
         unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_header READ");
      else
         unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_header WRITE");

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Writing Descriptor header");

      // RC writes EP DMA register (for module altpcie_dma_prg_reg)
      if (DEBUG_PRG==0) begin
         ebfm_barwr_imm(bar_table, setup_bar, 0+ep_offset, dt_dw0, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, 4+ep_offset, dt_dw1, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, 8+ep_offset, dt_dw2, 4, 0);
      end
      else begin
         ebfm_barwr_imm(bar_table, setup_bar, 0+ep_offset, 32'hC1FE_FADE, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, 4+ep_offset, 32'hC2FE_FADE, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, 8+ep_offset, 32'hC3FE_FADE, 4, 0);
      end
      // RC writes RC Memory
      shmem_write(dt_bdt_lsb  , dt_dw0,4);
      shmem_write(dt_bdt_lsb+4, dt_dw1,4);
      shmem_write(dt_bdt_lsb+8, dt_dw2,4);
      shmem_write(dt_bdt_lsb+12, 32'hCAFE_FADE,4);

      shmem_fill(dt_bdt_lsb+12,SHMEM_FILL_DWORD_INC,4,32'hCAFE_FADE);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "data content of the DT header");
      if (DISPLAY_ALL==1)
         unused_result =shmem_display(dt_bdt_lsb,4*4,4,dt_bdt_lsb+(4*4),EBFM_MSG_INFO);
   end

endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_set_rclast :
//    RC issues MWr RCLast to EP at address C on the EP site
//    RCLast is a WORD which represent the number of the DMA descriptor
//    ready for transfer.
//    Writing RCLast to EP trigger the start of the DMA transfer
//
// input argument
//    bar_table    : Pointer to the BAR sizing and
//    setup_bar    : BAR to be used for setting up
//    dt_direction : Read (0) or Write (1)
//    dt_rclast    : status bit to write back ep_counter info
//
task dma_set_rclast (
   input integer bar_table    ,
   input integer setup_bar    ,
   input integer dt_direction ,
   input integer dt_rclast
   );

   reg [31:0] dt_dw4 ;
   integer ep_offset ;
   reg unused_result ;

   begin

      // DMA Write ep_offset /BAR = 0;
      // DMA Read ep_offset  /BAR = 16 (4 DWORDs);
      ep_offset = (WR_DIRECTION==dt_direction)?0:16;
      dt_dw4[15:0]    = dt_rclast;
      dt_dw4[31:16]   = 1;

      // display section
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_rclast");

      if (dt_direction==RD_DIRECTION)
         unused_result = ebfm_display_verb(EBFM_MSG_INFO,
                      {"   Start READ DMA : RC issues MWr (RCLast=",
                      dimage4(dt_rclast), ")"});
      else
         unused_result = ebfm_display_verb(EBFM_MSG_INFO,
                      {"   Start WRITE DMA : RC issues MWr (RCLast=",
                      dimage4(dt_rclast), ")"});

      // RC writes EP DMA register
      ebfm_barwr_imm(bar_table, setup_bar, 12+ep_offset, dt_dw4, 4, 0);
   end
endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK: dma_set_wr_desc_data :
//
//  write 'write descriptor table in the RC Memory
//
/////////////////////////////////////////////////////
//           |-------------------------------------
//           | header write
//           |-------------------------------------
// BRC+0h    | DW0: number of descriptor
// BRC+4h    | DW1: BDT MSB
// BRC+8h    | DW2: BDT LSB
// BRC+ch    | DW3: EP Last
//           |-------------------------------------
//           | desc0 write
//           |-------------------------------------
// BRC+10h   | DW0: length        : 256 DWORDS
// BRC+14h   | DW1: EP ADDR       : 0h
// BRC+18h   | DW2: RC ADDR MSB   : BDT_MSB
// BRC+1ch   | DW3: RC ADDR LSB   : BRC+01000h
//           |-------------------------------------
//           | desc1 write
//           |-------------------------------------
// BRC+20h   | DW0: length        : 512 DWORDS
// BRC+24h   | DW1: EP ADDR       : 0h
// BRC+28h   | DW2: RC ADDR MSB   : BDT_MSB
// BRC+2ch   | DW3: RC ADDR LSB   : BRC+02000h
//           |-------------------------------------
//           | desc2 write
//           |-------------------------------------
// BRC+30h   | DW0: length        : 1024 DWORDS
// BRC+34h   | DW1: EP ADDR       : 0h
// BRC+38h   | DW2: RC ADDR MSB   : BDT_MSB
// BRC+3ch   | DW3: RC ADDR LSB   : BRC+03000h
//           |-------------------------------------
//
// input arguments
//   bar_table : Pointer to the BAR sizing and
//   setup_bar : BAR to be used for setting up
//
task dma_set_wr_desc_data (
   input integer bar_table    ,
   input integer setup_bar
   );

   reg unused_result ;
   integer descriptor_addr,i;

   integer loop_DW0;
   integer loop_DW1;
   integer loop_DW2;
   integer loop_DW3;

   begin

      //program BFM share memeory
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_wr_desc_data");
      // First Descriptor
      descriptor_addr = WR_FIRST_DESCRIPTOR;
      shmem_write(descriptor_addr  ,  WR_DESC0_LENGTH     ,4);
      shmem_write(descriptor_addr+4,  WR_DESC0_EPADDR     ,4);
      shmem_write(descriptor_addr+8,  WR_DESC0_RCADDR_MSB ,4);
      shmem_write(descriptor_addr+12, WR_DESC0_RCADDR_LSB ,4);
      shmem_fill(WR_DESC0_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 WR_DESC0_LENGTH*4,WR_DESC0_INIT_BFM_MEM);
      // Display descriptor table of DMA Write
      if (NUMBER_OF_DESCRIPTORS>3)
      begin
         for (i=1;i<NUMBER_OF_DESCRIPTORS-1;i=i+1)
         begin
            descriptor_addr = WR_FIRST_DESCRIPTOR + 16*i;
            loop_DW0        = WR_DESC1_LENGTH + i*MEM_DESCR_LENGTH_INC;
            loop_DW1        = WR_DESC1_EPADDR ;
            loop_DW2        = WR_DESC1_RCADDR_MSB;
            loop_DW3        = WR_DESC1_RCADDR_LSB;
            shmem_write(descriptor_addr  ,  loop_DW0 ,4);
            shmem_write(descriptor_addr+4,  loop_DW1 ,4);
            shmem_write(descriptor_addr+8,  loop_DW2 ,4);
            shmem_write(descriptor_addr+12, loop_DW3 ,4);
            if (i==1)
               shmem_fill(WR_DESC1_RCADDR_LSB,SHMEM_FILL_DWORD_INC, loop_DW0*4,
                       WR_DESC1_INIT_BFM_MEM);
         end
         i = NUMBER_OF_DESCRIPTORS-2;
      end
      else
      begin
         i = 1;
         // Descriptor 1
         descriptor_addr = WR_FIRST_DESCRIPTOR+16;
         shmem_write(descriptor_addr  ,  WR_DESC1_LENGTH     ,4);
         shmem_write(descriptor_addr+4,  WR_DESC1_EPADDR     ,4);
         shmem_write(descriptor_addr+8,  WR_DESC1_RCADDR_MSB ,4);
         shmem_write(descriptor_addr+12, WR_DESC1_RCADDR_LSB ,4);
         shmem_fill(WR_DESC1_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 WR_DESC1_LENGTH*4,WR_DESC1_INIT_BFM_MEM);
      end

      // Last Descriptor
      descriptor_addr = WR_FIRST_DESCRIPTOR+16*(i+1);
      shmem_write(descriptor_addr  ,  WR_DESC2_LENGTH     ,4);
      shmem_write(descriptor_addr+4,  WR_DESC2_EPADDR     ,4);
      shmem_write(descriptor_addr+8,  WR_DESC2_RCADDR_MSB ,4);
      shmem_write(descriptor_addr+12, WR_DESC2_RCADDR_LSB ,4);
      shmem_fill(WR_DESC2_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 WR_DESC2_LENGTH*4,WR_DESC2_INIT_BFM_MEM);
   end
endtask


/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_set_rd_desc_data : write 'read descriptor table in the RC Memory
//
//           |-------------------------------------
//           | header read
//           |-------------------------------------
// BRC+100h  | DW0: number of descriptor
// BRC+104h  | DW1: BDT MSB
// BRC+108h  | DW2: BDT LSB
// BRC+10ch  | DW3: EP Last
//           |-------------------------------------
//           | desc0 read
//           |-------------------------------------
// BRC+110h  | DW0: length
// BRC+114h  | DW1: EP ADDR       : 0h
// BRC+118h  | DW2: RC ADDR MSB   : BDT_MSB
// BRC+11ch  | DW3: RC ADDR LSB   : BRC+05000h
//           |-------------------------------------
//           | desc1 read
//           |-------------------------------------
// BRC+120h  | DW0: length
// BRC+124h  | DW1: EP ADDR       : 0h
// BRC+128h  | DW2: RC ADDR MSB   : BDT_MSB
// BRC+12ch  | DW3: RC ADDR LSB   :
//           |-------------------------------------
//           | desc2 read
//           |-------------------------------------
// BRC+130h  | DW0: length
// BRC+134h  | DW1: EP ADDR       : 0h
// BRC+138h  | DW2: RC ADDR MSB   : BDT_MSB
// BRC+13ch  | DW3: RC ADDR LSB   :
//           |-------------------------------------
//
// input arguments
//   bar_table : Pointer to the BAR sizing and
//   setup_bar : BAR to be used for setting up
//
task dma_set_rd_desc_data
   (
   input integer bar_table,
   input integer setup_bar
   );
   // HEADER PARAMETERS

   reg unused_result ;
   integer descriptor_addr,i;

   integer loop_DW0;
   integer loop_DW1;
   integer loop_DW2;
   integer loop_DW3;

   begin

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_rd_desc_data");

      //program BFM share memory :

      // First Descriptor
      descriptor_addr = RD_FIRST_DESCRIPTOR;
      shmem_write(descriptor_addr  ,  RD_DESC0_LENGTH     ,4);
      shmem_write(descriptor_addr+4,  RD_DESC0_EPADDR     ,4);
      shmem_write(descriptor_addr+8,  RD_DESC0_RCADDR_MSB ,4);
      shmem_write(descriptor_addr+12, RD_DESC0_RCADDR_LSB ,4);
      shmem_fill(RD_DESC0_RCADDR_LSB,SHMEM_FILL_DWORD_INC,RD_DESC0_LENGTH*4,
                 RD_DESC0_INIT_BFM_MEM);

      if (NUMBER_OF_DESCRIPTORS>3)
      begin
         for (i=1;i<NUMBER_OF_DESCRIPTORS-1;i=i+1)
         begin
            descriptor_addr = RD_FIRST_DESCRIPTOR + 16*i;
            loop_DW0        = RD_DESC1_LENGTH + i*MEM_DESCR_LENGTH_INC;
            loop_DW1        = RD_DESC1_EPADDR ;
            loop_DW2        = RD_DESC1_RCADDR_MSB;
            loop_DW3        = RD_DESC1_RCADDR_LSB;
            shmem_write(descriptor_addr  ,  loop_DW0 ,4);
            shmem_write(descriptor_addr+4,  loop_DW1 ,4);
            shmem_write(descriptor_addr+8,  loop_DW2 ,4);
            shmem_write(descriptor_addr+12, loop_DW3 ,4);
            if (i==1)
               shmem_fill(RD_DESC1_RCADDR_LSB,SHMEM_FILL_DWORD_INC, loop_DW0*4,
                              RD_DESC1_INIT_BFM_MEM);
         end
         i = NUMBER_OF_DESCRIPTORS-2;
      end
      else
      begin
         // Descriptor 1
         i = 1;
         descriptor_addr = RD_FIRST_DESCRIPTOR+16;
         shmem_write(descriptor_addr  ,  RD_DESC1_LENGTH     ,4);
         shmem_write(descriptor_addr+4,  RD_DESC1_EPADDR     ,4);
         shmem_write(descriptor_addr+8,  RD_DESC1_RCADDR_MSB ,4);
         shmem_write(descriptor_addr+12, RD_DESC1_RCADDR_LSB ,4);
         shmem_fill(RD_DESC1_RCADDR_LSB, SHMEM_FILL_DWORD_INC,
                 RD_DESC1_LENGTH*4,RD_DESC1_INIT_BFM_MEM);
      end

      // Last Descriptor
      descriptor_addr = RD_FIRST_DESCRIPTOR+16*(i+1);
      shmem_write(descriptor_addr  ,  RD_DESC2_LENGTH     ,4);
      shmem_write(descriptor_addr+4,  RD_DESC2_EPADDR     ,4);
      shmem_write(descriptor_addr+8,  RD_DESC2_RCADDR_MSB ,4);
      shmem_write(descriptor_addr+12, RD_DESC2_RCADDR_LSB ,4);
      shmem_fill(RD_DESC2_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 RD_DESC2_LENGTH*4,RD_DESC2_INIT_BFM_MEM);
   end
endtask


/////////////////////////////////////////////////////////////////////////
//
// TASK:msi_poll
//   Polling process to track in shared memeory received MSI from EP
//
// input argument
//    max_number_of_msi  : Total Number of MSI to track
//    msi_address        : MSI Address in shared memeory
//    msi_expected_dmawr : Expected MSI when dma_write is set
//    msi_expected_dmard : Expected MSI when dma_read is set
//    dma_write          : Set dma_write
//    dma_read           : set dma_read
task msi_poll(
   input integer max_number_of_msi,
   input integer msi_address,
   input integer msi_expected_dmawr,
   input integer msi_expected_dmard,
   input integer dma_write,
   input integer dma_read
   );

   reg unused_result ;
   integer msi_received;
   integer msi_count;
   reg pol_ip;

   begin
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK: msi_poll");
      for (msi_count=0; msi_count < max_number_of_msi;msi_count=msi_count+1)
      begin
         pol_ip=0;
         fork
         // Set timeout failure if expected MSI is not received
         begin:timeout_msi
            repeat (100000) @(posedge clk_in);
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL,
                     "MSI timeout occured, MSI never received, Test Fails");
            disable wait_for_msi;
         end
         // Polling memory for expected MSI data value
         // at the assigned MSI address location
         begin:wait_for_msi
            forever
               begin
                  repeat (50) @(posedge clk_in);
                  msi_received = shmem_read (msi_address, 2);
                  if (pol_ip==0)
                     unused_result = ebfm_display(EBFM_MSG_INFO,{
                                       "   Polling MSI Address:",
                                       himage4(msi_address),
                                       "---> Data:",
                                       himage4(msi_received),
                                       "......"});

                  pol_ip=1;
                  if ((msi_received == msi_expected_dmawr) && (dma_write==1))
                     begin
                        unused_result = ebfm_display(EBFM_MSG_INFO,
                                    {"    Received Expected DMA Write MSI(",
                                   dimage4(msi_count),
                                   ") : ",
                                   himage4(msi_received)});
                        shmem_write( msi_address , 32'h1111_FADE, 4);
                        disable timeout_msi;
                        disable wait_for_msi;

                     end

                  if ((msi_received == msi_expected_dmard) && (dma_read==1))
                     begin
                        unused_result = ebfm_display(EBFM_MSG_INFO,
                                    {"    Received Expected DMA Read MSI(",
                                   dimage4(msi_count),
                                   ") : ",
                                   himage4(msi_received)});
                        shmem_write( msi_address , 32'h1111_FADE, 4);

                        if (DISPLAY_ALL==1)
                        unused_result = shmem_display(SCR_MEM+256,
                                             4*4,
                                             4,
                                             SCR_MEM+256+(4*4),
                                             EBFM_MSG_INFO);

                        disable timeout_msi;
                        disable wait_for_msi;
                     end
               end
         end
         join
      end
   end
endtask

/////////////////////////////////////////////////////////////////////////
//
// rcmem_poll
//
// Polling routine waiting for rc_data at location rc_addr
//
task rcmem_poll(
   input integer rc_addr,
   input integer rc_data,
   input integer rc_data_mask);

   reg unused_result ;
   integer rc_current;
   integer rc_last;
   reg [31:0] timout_limit;
   reg pol_ip;

   begin

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:rcmem_poll");
      pol_ip=0;
      timout_limit[31:0]=0;

      fork

      begin:wait_for_rcmem
         forever
            begin
               repeat (50) @(posedge clk_in);
               rc_current = (shmem_read (rc_addr, 4) & (rc_data_mask));
               if (pol_ip==0) begin
                  `ifdef IPD_DEBUG
                     ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT20031");
                  `endif
                  timout_limit[31:0]=0;
                  rc_last    = rc_current;
                  unused_result = ebfm_display_verb(EBFM_MSG_INFO,
                        {"   Polling RC Address:"   ,himage8(rc_addr),
                         "   current data (" ,himage8(rc_current),
                         ")  expected data (",himage8(rc_data),")"});
               end
               if (rc_current != rc_last ) begin
                  `ifdef IPD_DEBUG
                     ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT20032");
                  `endif
                  unused_result = ebfm_display(EBFM_MSG_INFO,
                        {"   Polling RC Address:"   ,himage8(rc_addr),
                         "   current data (" ,himage8(rc_current),
                         ")  expected data (",himage8(rc_data),")"});
                  timout_limit[31:0]=0;
               end
               else
                  timout_limit[31:0]=timout_limit[31:0]+1;

               rc_last    = rc_current;
               pol_ip=1;

               if (timout_limit[31:0]>TIMEOUT_POLLING) begin
                  unused_result = ebfm_display(EBFM_MSG_INFO,
                            "   ---> TASK:rcmem_poll timeout occured");
                  unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL,
                           {"   ---> Test Fails: RC Address:",
                           himage8(rc_addr)," contains ", himage8(rc_current)});
                  disable wait_for_rcmem;
               end
               if (rc_current == rc_data)
                  begin
                     unused_result = ebfm_display(EBFM_MSG_INFO,
                     {"   ---> Received Expected Data (",himage8(rc_current),")"});
                     disable wait_for_rcmem;
                  end
            end
      end
      join
   end
endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_rd_test
//
// Run the chained DMA read
//
// Input argument
//     bar_table :  Pointer to the BAR sizing and
//     setup_bar :  BAR to be used for setting up
//                  4 Write then Read
//     use_msi   :  When set, use msi
//     use_eplast:  When set, poll for ep last
//
task dma_rd_test(
   input integer bar_table,
   input integer setup_bar,
   input integer use_msi,
   input integer use_eplast);

   localparam integer MSI_ADDRESS     = SCR_MEM-16;
   localparam integer MSI_DATA        = 16'hb0fe;

   reg unused_result ;
   integer RCLast;

   reg [4:0] msi_number          ;
   reg [2:0] msi_traffic_class   ;
   reg [2:0] multi_message_enable;
   integer   msi_address         ;

   integer   msi_expected_dmawr ;
   integer   msi_expected_dmard ;

   integer msi_received ;
   integer msi_count    ;
   integer max_count    ;
   integer i;
   reg [31:0] track_rclast_loop;

   begin

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_rd_test");

      // Read descriptor table in the RC Memory
      dma_set_rd_desc_data(bar_table, setup_bar);

      `ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT2001");
      `endif


      // Set MSI for DMA Read
      if (use_msi==1)
         dma_set_msi(bar_table,  // Pointer to the BAR sizing and
                        setup_bar,  // BAR to be used for setting up
                        1,          // bus_num
                        0,          // dev_num
                        0,          // fnc_num
                        RD_DIRECTION,          // Direction
                        MSI_ADDRESS,// MSI RC memeory address
                        MSI_DATA,   // MSI Cfg data value
                        msi_number,        // msi_number
                        msi_traffic_class, //msi traffic class
                        multi_message_enable,// number of msi
                        msi_expected_dmard // expexted MSI data value
                     );

         `ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT2002");
      `endif

      // Read Descriptor header in EP memory PRG
      dma_set_header( bar_table,       // Pointer to the BAR sizing and
                     setup_bar,       // BAR to be used for setting up
                     NUMBER_OF_DESCRIPTORS, // number of descriptor
                     RD_DIRECTION,            // Direction read
                     use_msi   ,   // status bit for DMA MSI
                     use_eplast,   // status bit to write back ep_last
                     RD_BDT_MSB,      // RC upper 32 bits of bdt
                     RD_BDT_LSB,      // RC lower 32 bits of bdt
                     msi_number,
                     msi_traffic_class,
                     multi_message_enable,
                     0);

      `ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT20021");
      `endif


      //Program RP RCLast
      RCLast = NUMBER_OF_DESCRIPTORS-1; // 3 descriptor, written 0,1,2

      // Start read DMA
      dma_set_rclast(bar_table, setup_bar, RD_DIRECTION, RCLast);

      // Polling EP Last
      if (use_eplast==1) begin
         if (DMA_CONTINOUS_LOOP==0) begin
            `ifdef IPD_DEBUG
               ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT2003");
            `endif
            rcmem_poll(RD_BDT_LSB+DT_EPLAST, RCLast,32'h0000FFFF);
            `ifdef IPD_DEBUG
               ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT2004");
            `endif
         end
         else begin
            for (i=0;i<DMA_CONTINOUS_LOOP;i=i+1) begin
               unused_result = ebfm_display(EBFM_MSG_INFO, { "   Running DMA loop ", dimage4(i), " : "});
               shmem_write(RD_BDT_LSB+DT_EPLAST, 32'hCAFE_FADE,4);
               rcmem_poll(RD_BDT_LSB+DT_EPLAST, RCLast,32'h0000FFFF);
            end
            shmem_write(RD_BDT_LSB+DT_EPLAST, 32'hCAFE_FADE,4);
            dma_set_header( bar_table,       // Pointer to the BAR sizing and
                     setup_bar,       // BAR to be used for setting up
                     NUMBER_OF_DESCRIPTORS, // number of descriptor
                     RD_DIRECTION,            // Direction read
                     use_msi   ,   // status bit for DMA MSI
                     use_eplast,   // status bit to write back ep_last
                     RD_BDT_MSB,      // RC upper 32 bits of bdt
                     RD_BDT_LSB,      // RC lower 32 bits of bdt
                     msi_number,
                     msi_traffic_class,
                     multi_message_enable,
                     1); // stop_loop
             track_rclast_loop[15:0] = RCLast;
             track_rclast_loop[31:16] = 1 ;
             unused_result = ebfm_display(EBFM_MSG_INFO, "   Flushing DMA loop");
             rcmem_poll(RD_BDT_LSB+DT_EPLAST, track_rclast_loop,32'h0001ffff);
         end
      end

     // Monitor MSI - Polling MSI
      if (use_msi==1)
         msi_poll(RCLast+1,MSI_ADDRESS,0, msi_expected_dmard,0,1);

      ebfm_barwr_imm(bar_table, setup_bar, 16, 32'h0000_FFFF, 4, 0);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Completed DMA Read");


   end

endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:dma_wr_test
//
// Run the chained DMA write
//
// Input argument
//     bar_table :  Pointer to the BAR sizing and
//     setup_bar :  BAR to be used for setting up
//                  4 Write then Read
//     use_msi   :  When set, use msi
//     use_eplast:  When set, poll for ep last
//
task dma_wr_test(
   input integer bar_table,
   input integer setup_bar,
   input integer use_msi,
   input integer use_eplast);

   localparam integer MSI_ADDRESS = SCR_MEM-16;
   localparam integer MSI_DATA    = 16'hb0fe;

   reg unused_result ;
   integer RCLast;

   reg [4:0] msi_number          ;
   reg [2:0] msi_traffic_class   ;
   reg [2:0] multi_message_enable;
   integer   msi_address         ;

   integer   msi_expected_dmawr ;
   integer   msi_expected_dmard ;

   integer msi_received ;
   integer msi_count    ;
   integer max_count    ;
   integer i    ;
   reg [31:0] track_rclast_loop;
   begin

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_wr_test");
      unused_result = ebfm_display_verb(EBFM_MSG_INFO,"   DMA: Write");

      // write 'write descriptor table in the RC Memory
      dma_set_wr_desc_data(bar_table, setup_bar);

      // Set MSI for DMA Writew
      if (use_msi==1)
         dma_set_msi( bar_table,  // Pointer to the BAR sizing and
                             setup_bar,  // BAR to be used for setting up
                             1,          // bus_num
                             0,          // dev_num
                             0,          // fnc_num
                             WR_DIRECTION,          // Direction
                             MSI_ADDRESS,// MSI RC memeory address
                             MSI_DATA,   // MSI Cfg data value
                             msi_number, // msi_number
                             msi_traffic_class, //msi traffic class
                             multi_message_enable,// number of msi
                             msi_expected_dmawr // expexted MSI data value
                             );

      // Write Descriptor header in EP memory PRG
      dma_set_header( bar_table,      // Pointer to the BAR sizing and
                     setup_bar,       // BAR to be used for setting up
                     NUMBER_OF_DESCRIPTORS, // number of descriptor
                     WR_DIRECTION,    // Direction = Write
                     use_msi,         // status bit for DMA MSI
                     use_eplast,      // status bit to write back ep_last
                     WR_BDT_MSB,      // RC upper 32 bits of bdt
                     WR_BDT_LSB,      // RC lower 32 bits of bdt
                     msi_number,
                     msi_traffic_class,
                     multi_message_enable,
                     0);

      //Program RP RCLast
      RCLast = NUMBER_OF_DESCRIPTORS-1; // 3 descriptor, written 0,1,2

      // Start write DMA
      dma_set_rclast(bar_table, setup_bar, WR_DIRECTION, RCLast);

      if (use_eplast==1) begin
         if (DMA_CONTINOUS_LOOP==0)
            rcmem_poll(WR_BDT_LSB+DT_EPLAST, RCLast,32'h0000ffff);
         else begin
            for (i=0;i<DMA_CONTINOUS_LOOP;i=i+1) begin
               unused_result = ebfm_display(EBFM_MSG_INFO, { "   Running DMA loop ", dimage4(i), " : "});
               shmem_write(WR_BDT_LSB+DT_EPLAST, 32'hCAFE_FADE,4);
               rcmem_poll(WR_BDT_LSB+DT_EPLAST, RCLast,32'h0000ffff);
            end
            shmem_write(WR_BDT_LSB+DT_EPLAST, 32'hCAFE_FADE,4);
            dma_set_header( bar_table,      // Pointer to the BAR sizing and
                     setup_bar,       // BAR to be used for setting up
                     NUMBER_OF_DESCRIPTORS, // number of descriptor
                     WR_DIRECTION,    // Direction = Write
                     use_msi,         // status bit for DMA MSI
                     use_eplast,      // status bit to write back ep_last
                     WR_BDT_MSB,      // RC upper 32 bits of bdt
                     WR_BDT_LSB,      // RC lower 32 bits of bdt
                     msi_number,
                     msi_traffic_class,
                     multi_message_enable,
                     1);
             track_rclast_loop[15:0] = RCLast;
             track_rclast_loop[31:16] = 1 ;
             unused_result = ebfm_display(EBFM_MSG_INFO, "   Flushing DMA loop");
             rcmem_poll(WR_BDT_LSB+DT_EPLAST, track_rclast_loop,32'h0001ffff);
         end
      end
     // Monitor MSI - Polling MSI
      if (use_msi==1)
         msi_poll( RCLast+1, MSI_ADDRESS, msi_expected_dmawr,0,1,0);

      ebfm_barwr_imm(bar_table, setup_bar, 0, 32'h0000_FFFF, 4, 0);

      unused_result = ebfm_display_verb(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Completed DMA Write");

  end

endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:chained_dma_test
//
//    Main task to run the chained DMA read/Write
//
// Input argument
//     bar_table :  Pointer to the BAR sizing and
//     setup_bar :  BAR to be used for setting up
//     direction :  0 read,
//                  1 write,
//                  2 read and write simulataneous
//                  3 Read then Write
//                  4 Write then Read
//
task chained_dma_test(
    input integer bar_table ,
    input integer setup_bar ,
    input integer direction ,
    input integer use_msi   ,
    input integer use_eplast
   );

   reg unused_result ;

   begin

      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);
      unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:chained_dma_test");
      case (direction)
         0: begin
               unused_result = ebfm_display(EBFM_MSG_INFO,"   DMA: Read");
               dma_rd_test(bar_table, setup_bar, use_msi, use_eplast);
            end
         1: begin
               unused_result = ebfm_display(EBFM_MSG_INFO,"   DMA: Write");
               dma_wr_test(bar_table, setup_bar, use_msi, use_eplast);
            end
          default: unused_result = ebfm_display(EBFM_MSG_INFO,"   Incorrect direction");

      endcase
  end
endtask


// purpose: Examine the DUT's BAR setup and pick a reasonable BAR to use
task find_mem_bar;
   input bar_table;
   integer bar_table;
   input[5:0] allowed_bars;
   input min_log2_size;
   integer min_log2_size;
   output sel_bar;
   integer sel_bar;

   integer cur_bar;
   reg[31:0] bar32;
   integer log2_size;
   reg is_mem;
   reg is_pref;
   reg is_64b;

   begin
      // find_mem_bar
      cur_bar = 0;
      begin : sel_bar_loop
         while (cur_bar < 6)
         begin
            ebfm_cfg_decode_bar(bar_table, cur_bar,
                                log2_size, is_mem, is_pref, is_64b);
            if ((is_mem == 1'b1) &
                (log2_size >= min_log2_size) &
                ((allowed_bars[cur_bar]) == 1'b1))
            begin
               sel_bar = cur_bar;
               disable sel_bar_loop ;
            end
            if (is_64b == 1'b1)
            begin
               cur_bar = cur_bar + 2;
            end
            else
            begin
               cur_bar = cur_bar + 1;
            end
         end
         sel_bar = 7 ; // Invalid BAR if we get this far...
      end
   end
endtask

task scr_memory_compare(
   input integer byte_length,     // downstream wr/rd length in byte
   input integer scr_memorya,     //
   input integer scr_memoryb);     //
   integer i;
   reg [7:0] bytea;
   reg [7:0] byteb;
   reg [31:0] addra;
   reg [31:0] addrb;
   reg unused_result ;

   begin

      //unused_result = ebfm_display_verb(EBFM_MSG_INFO, "TASK:scr_memory_compare");
      addra = scr_memorya;
      addrb = scr_memoryb;

      for (i=0;i<byte_length;i=i+1) begin
         bytea=shmem_read(addra,1);
         byteb=shmem_read(addrb,1);
         addra=addra+1;
         addrb=addrb+1;
         if (bytea!=byteb) begin

            unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Content of the RC memory A");
            unused_result =shmem_display(scr_memorya,byte_length,4,scr_memorya+byte_length,EBFM_MSG_INFO);
            unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Content of the RC memory B");
            unused_result =shmem_display(scr_memoryb,byte_length,4,scr_memoryb+byte_length,EBFM_MSG_INFO);

            unused_result = ebfm_display(EBFM_MSG_INFO,
                              {" A: 0x", himage8(addra), ": ",himage8(bytea)});
            unused_result = ebfm_display(EBFM_MSG_INFO,
                              {" B: 0x", himage8(addrb), ": ",himage8(byteb)});
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, {"Different memory content for ",
                                                dimage4(byte_length), " bytes test"});
         end
     end
//    unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Content of the RC memory A");
//    unused_result =shmem_display(scr_memorya,byte_length,4,scr_memorya+byte_length,EBFM_MSG_INFO);
//    unused_result = ebfm_display_verb(EBFM_MSG_INFO, "Content of the RC memory B");
//    unused_result =shmem_display(scr_memoryb,byte_length,4,scr_memoryb+byte_length,EBFM_MSG_INFO);
//
//
//   //  unused_result = ebfm_display_verb(EBFM_MSG_INFO, {"Passed: ",dimage4(byte_length),
//                 //           " same bytes in BFM mem addr 0x", himage8(scr_memorya),
//                 //           " and 0x", himage8(scr_memoryb)});
         unused_result = ebfm_display(EBFM_MSG_INFO, {"Passed: ",dimage4(byte_length),
                                     " same bytes in BFM mem addr 0x", himage8(scr_memorya),
                                     " and 0x", himage8(scr_memoryb)});



   end
endtask
/////////////////////////////////////////////////////////////////////////
//
// TASK:downstream_write
// Prior to run DMA test, this task clears the performance counters
//
task downstream_write(
   input integer bar_table,          // Pointer to the BAR sizing and
   input integer setup_bar,          // Pointer to the BAR sizing and
   input integer address,            // Downstream EP memeory address in byte
   input [63:0] data,
   input integer byte_length);      // BAR to be used for setting up
   reg unused_result;
   reg ret_nill;

   begin
      // Write a data
      shmem_fill(SCR_MEM_DOWNSTREAM_WR,SHMEM_FILL_QWORD_INC,byte_length,data);
      ebfm_barwr(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_WR,byte_length,0);
   end

endtask

/////////////////////////////////////////////////////////////////////////
//
// TASK:downstream_read
// Prior to run DMA test, this task clears the performance counters
//
task downstream_read(
   input integer bar_table,          // Pointer to the BAR sizing and
   input integer setup_bar,          // Pointer to the BAR sizing and
   input integer address,            // Downstream EP memeory address in byte
   input integer byte_length);      // BAR to be used for setting up
   reg unused_result;
   reg ret_nill;
   begin
      // read a data
      shmem_fill(SCR_MEM_DOWNSTREAM_RD,SHMEM_FILL_QWORD_INC,byte_length,64'hFADE_FADE_FADE_FADE);
      ebfm_barrd_wait(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_RD,byte_length,0);
   end
endtask


task downstream_loop(
   input integer bar_table,       // Pointer to the BAR sizing and
   input integer setup_bar,       // Pointer to the BAR sizing and
   input  integer loop,           // Number of Write/read iteration
   input integer byte_length,     // downstream wr/rd length in byte
   input integer epmem_address,   // Downstream EP memory address in byte
   input  [63:0] start_val);      // Starting write data value

   reg ret_nill;
   reg [63:0] Istart_val;
   reg [31:0] Iepmem_address;
   integer i;
   reg [31:0] Ibyte_length;

   reg [31:0] cfg_reg ;
   reg [31:0] cfg_maxpload_byte ;
   reg [7:0] avalon_waddr ;
   reg [31:0] avalon_waddr_qw_max;
   reg [31:0] avalon_waddr_qw_min;
   reg [31:0] cfg_dw1 ;
   reg unused_result;


   begin

      unused_result = ebfm_display(EBFM_MSG_INFO, `STR_SEP);

      unused_result = ebfm_display(EBFM_MSG_INFO, "TASK:downstream_loop ");

      cfg_maxpload_byte = 0;
      // Retrieve Device cfg from RC Slave
      // Set EP MWr mode

      cfg_reg = 32'h0;

      case (cfg_reg[7:5])
         3'b000 :cfg_maxpload_byte[12:7 ] = 6'b000001;// 128B
         3'b001 :cfg_maxpload_byte[12:7 ] = 6'b000010;// 256B
         3'b010 :cfg_maxpload_byte[12:7 ] = 6'b000100;// 512B
         3'b011 :cfg_maxpload_byte[12:7 ] = 6'b001000;// 1024B
         3'b100 :cfg_maxpload_byte[12:7 ] = 6'b010000;// 2048B
         default:cfg_maxpload_byte[12:7 ] = 6'b100000;// 4096B
      endcase

      Ibyte_length = ((byte_length>cfg_maxpload_byte)||
                                     (byte_length<4))?4:byte_length;
      Istart_val   = start_val;

      for (i=0;i<loop;i=i+1) begin
         //TODO extend to more than 1 DW
         //
         Ibyte_length=4;
         downstream_write( bar_table,
                           setup_bar,
                           epmem_address,
                           Istart_val,
                           Ibyte_length);
         downstream_read ( bar_table,
                           setup_bar,
                           epmem_address,
                           Ibyte_length);
         scr_memory_compare(Ibyte_length,
                            SCR_MEM_DOWNSTREAM_WR,
                            SCR_MEM_DOWNSTREAM_RD);
         Istart_val   = Istart_val+cfg_maxpload_byte;
         Ibyte_length = ((Ibyte_length>cfg_maxpload_byte-4)||
                                     (Ibyte_length<4))?4:Ibyte_length+4;
      end
   end
endtask

task target_mem_test_lite;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input tgt_bar;        // BAR to use to access the target
      integer tgt_bar;      // memory
      input start_offset;   // Starting offset in the target
      integer start_offset; // memory to use
      input tgt_data_len;   // Length of data to test
      integer tgt_data_len;

      parameter TGT_WR_DATA_ADDR = 1 * (2 ** 16);
      integer tgt_rd_data_addr;
      integer err_addr;

      reg unused_result ;

      begin  // target_mem_test_lite (single DW)
         unused_result = ebfm_display(EBFM_MSG_INFO, "Starting Target Write/Read Test.");
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Target BAR = ", dimage1(tgt_bar)});
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(tgt_data_len), ", Start Offset = ", dimage6(start_offset)});
         // Setup some data to write to the Target
         shmem_fill(TGT_WR_DATA_ADDR, SHMEM_FILL_DWORD_INC, 32, {64{1'b0}});  /// 32 bytes
         // Setup an address for the data to read back from the Target
         tgt_rd_data_addr = TGT_WR_DATA_ADDR + (2 * 32);              // 32-bytes
         // Clear the target data area
         shmem_fill(tgt_rd_data_addr, SHMEM_FILL_ZERO, 32, {64{1'b0}});
         //
         // Now write the data to the target with this BFM call
         //
         ebfm_barwr(bar_table, tgt_bar, start_offset, TGT_WR_DATA_ADDR, 4, 0);
         //
         // Read the data back from the target in one burst, wait for the read to
         // be complete
         //
         ebfm_barrd_wait(bar_table, tgt_bar, start_offset, tgt_rd_data_addr, 4, 0);
         // Check the data
         if (shmem_chk_ok(tgt_rd_data_addr, SHMEM_FILL_DWORD_INC, 4, {64{1'b0}}, 1'b1))
         begin
            unused_result = ebfm_display(EBFM_MSG_INFO, "  Target Write and Read compared okay!");
         end
         else
         begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare");
         end
      end
endtask

// purpose: Use Reads and Writes to test the target memory
   //          The starting offset in the target memory and the
   //          length can be specified
   task target_mem_test;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input tgt_bar;        // BAR to use to access the target
      integer tgt_bar;      // memory
      input start_offset;   // Starting offset in the target
      integer start_offset; // memory to use
      input tgt_data_len;   // Length of data to test
      integer tgt_data_len;

      parameter TGT_WR_DATA_ADDR = 1 * (2 ** 16);
      integer tgt_rd_data_addr;
      integer err_addr;

      reg unused_result ;

      begin  // target_mem_test
         unused_result = ebfm_display(EBFM_MSG_INFO, "Starting Target Write/Read Test.");
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Target BAR = ", dimage1(tgt_bar)});
         unused_result = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(tgt_data_len), ", Start Offset = ", dimage6(start_offset)});
         // Setup some data to write to the Target
         shmem_fill(TGT_WR_DATA_ADDR, SHMEM_FILL_DWORD_INC, tgt_data_len, {64{1'b0}});
         // Setup an address for the data to read back from the Target
         tgt_rd_data_addr = TGT_WR_DATA_ADDR + (2 * tgt_data_len);
         // Clear the target data area
         shmem_fill(tgt_rd_data_addr, SHMEM_FILL_ZERO, tgt_data_len, {64{1'b0}});
         //
         // Now write the data to the target with this BFM call
         //
         ebfm_barwr(bar_table, tgt_bar, start_offset, TGT_WR_DATA_ADDR, tgt_data_len, 0);
         //
         // Read the data back from the target in one burst, wait for the read to
         // be complete
         //
         ebfm_barrd_wait(bar_table, tgt_bar, start_offset, tgt_rd_data_addr, tgt_data_len, 0);
         // Check the data
         if (shmem_chk_ok(tgt_rd_data_addr, SHMEM_FILL_DWORD_INC, tgt_data_len, {64{1'b0}}, 1'b1))
         begin
            unused_result = ebfm_display(EBFM_MSG_INFO, "  Target Write and Read compared okay!");
         end
         else
         begin
            unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare");
         end
      end
   endtask

// purpose: Use the reference design's DMA engine to move data from the BFM's
   // shared memory to the reference design's master memory and then back
    task dma_mem_test;
      input bar_table;      // Pointer to the BAR sizing and
      integer bar_table;    // address information set up by
                            // the configuration routine
      input setup_bar;      // BAR to be used for setting up
      integer setup_bar;    // the DMA operation and checking
                            // the status
      input start_offset;   // Starting offset in the master
      integer start_offset; // memory
      input dma_data_len;   // Length of DMA operations
      integer dma_data_len;

      parameter SCR_MEM = (2 ** 17) - 4;
      integer dma_rd_data_addr;
      integer dma_wr_data_addr;
      integer err_addr;
      reg [2:0] compl_status;
      reg [2:0]  multi_message_enable;
      reg        msi_enable;
      reg [31:0] msi_capabilities ;
      reg [15:0] msi_data;
      reg [31:0] msi_address;
integer passthru_msk;

      reg dummy ;

      begin
      dummy = ebfm_display(EBFM_MSG_INFO, "Starting DMA Read/Write Test.");
         dummy = ebfm_display(EBFM_MSG_INFO, {"  Setup BAR = ", dimage1(setup_bar)});
         dummy = ebfm_display(EBFM_MSG_INFO, {"  Length = ", dimage6(dma_data_len),
                                      ", Start Offset = ", dimage6(start_offset)});
         dma_rd_data_addr = SCR_MEM + 4 + start_offset;
         // Setup some data for the DMA to read
         shmem_fill(dma_rd_data_addr, SHMEM_FILL_DWORD_INC, dma_data_len, {64{1'b0}});


         // MSI capabilities
          msi_capabilities = 32'h50;
          msi_address = SCR_MEM;
          msi_data = 16'habcd;
          msi_enable = 1'b0;
          multi_message_enable = 3'b000;

         // Program the DMA to Read Data from Shared Memory

      // check the # of passthru bits
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1000,  32'hffffffff, 4, 0);
         ebfm_barrd_wait(bar_table, setup_bar,CRA_BASE+16'h1000, SCR_MEM, 4, 0); /// read the status reg
       passthru_msk = shmem_read(SCR_MEM,4) & 32'hffff_fffc;

      // Set PCI Express Interrupt enable (bit 0) in the PCIe-Avalon-MM bridge at address Avalon_Base_Address + 0x50
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h0050,  32'h00000001, 4, 0);


      // To program DMA and translation, take the portion of the DMA address that
      // is below passthru bits and program them to DMA. The remaining portion goes
      // to address translation table

      // program address translation table
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1000,  dma_rd_data_addr & passthru_msk, 4, 0);
         ebfm_barwr_imm(bar_table, setup_bar, CRA_BASE+16'h1004,  32'h00000000, 4, 0);

         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0004,  dma_rd_data_addr & ~passthru_msk, 4, 0);  // reg 1 (read address)
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0008, MEM_OFFSET, 4, 0);  // reg 2 (write address)
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h000C, dma_data_len, 4, 0);  // reg 3 (dma length)

         if (APPS_TYPE_HWTCL==4) begin    // avmm-64bit
             ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000498, 4, 0); //  reg 6 (control)
         end
         else begin   // avmm-128bit
             ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000898, 4, 0); //  reg 6 (control)
         end

          #10
         wait(INTA);
         // check for INTA deassertion

         dummy = ebfm_display(EBFM_MSG_INFO, "Clear Interrupt INTA ");
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0000,  32'h00000000, 4, 0);  // clear done bit in status reg

         #10
         wait(!INTA);

         //enable MSI enable
         msi_enable = 1'b1;
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities, 4, {8'h00, 1'b0, multi_message_enable, 3'b000, msi_enable, 16'h0000}, compl_status);
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities + 4'h4, 4, msi_address, compl_status);
         ebfm_cfgwr_imm_wait(1, 0, 0, msi_capabilities + 4'hC, 4, msi_data,    compl_status);

         // Setup an area for DMA to write back to
         // Currently DMA Engine Uses lower address bits for it's MRAM and PCIE
         // Addresses. So use the same address we started with
         dma_wr_data_addr = dma_rd_data_addr;
         shmem_fill(dma_wr_data_addr, SHMEM_FILL_ZERO, dma_data_len, {64{1'b0}});

         // Program the DMA to Write Data Back to Shared Memory
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0004, MEM_OFFSET , 4, 0);  // reg 1 (read address)
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0008, dma_wr_data_addr & ~passthru_msk, 4, 0);  // reg 2 (write address)
         ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h000c, dma_data_len, 4, 0);  // reg 3 (dma length)

         if (APPS_TYPE_HWTCL==4) begin    // avmm-64bit
             ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000498, 4, 0); //  reg 6 (control)
         end
         else begin   // avmm-128bit
             ebfm_barwr_imm(bar_table, setup_bar, DMA_BASE+16'h0018, 32'h00000898, 4, 0); //  reg 6 (control)
         end

          // Wait Until the DMA is done via MSI
         dma_wait_done(bar_table, setup_bar, SCR_MEM);

         // Check the data
         if (shmem_chk_ok(dma_rd_data_addr, SHMEM_FILL_DWORD_INC, dma_data_len, {64{1'b0}}, 1'b1))
         begin
            dummy = ebfm_display(EBFM_MSG_INFO, "  DMA Read and Write compared okay!");
         end
         else
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL, "  Stopping simulation due to miscompare");
         end

      end
endtask

 // purpose: This procedure polls the DMA engine until it is done
  task dma_wait_done;
      input bar_table;
      integer bar_table;
      input setup_bar;
      integer setup_bar;
      input msi_mem;
      integer msi_mem;


      reg [31:0] dma_sts ;
      reg unused_result;
      begin
         // dma_wait_done
         shmem_fill(msi_mem, SHMEM_FILL_ZERO, 4, {64{1'b0}});
         dma_sts = 32'h00000000 ;
         while (dma_sts != 32'h0000abcd)
         begin
            #10
            dma_sts = shmem_read(msi_mem,4) ;
         end

         unused_result = ebfm_display(EBFM_MSG_INFO, "MSI recieved!");
        // ebfm_barwr_imm(bar_table, setup_bar, 16'h1000,  32'h00000000, 4, 0);  // clear done bit in status reg
        // unused_result = ebfm_display(EBFM_MSG_INFO, "  Clear interrupt !");


      end

   endtask


task avmmdma_rdwr_test;
    input bar_table;
    integer bar_table;

    integer i, wr_descriptor_addr, rd_descriptor_addr;
    integer src_mem_addr, dest_mem_addr, loop, byte_length, cntlr_base_addr;
    reg unused_result;
    reg [31:0] dma_sts;

    begin
    loop=2048+512;
    src_mem_addr=5120;
    byte_length=4;
    cntlr_base_addr=16384;


        ///////////////////////////
        //// Target Read/Write ////
        ///////////////////////////

//       unused_result = ebfm_display(EBFM_MSG_INFO, "Starting Target Single DWord Writes Using RX Master");
//
//       downstream_write( bar_table, 0, 0, 32'h0123_4567, 4);
//       downstream_read( bar_table, 0, 0, 4);
//       unused_result =shmem_display(SCR_MEM_DOWNSTREAM_RD,4,4,SCR_MEM_DOWNSTREAM_RD+4,EBFM_MSG_INFO);

        ///////////////////
        //// DMA Write ////
        ///////////////////
    unused_result = ebfm_display(EBFM_MSG_INFO, "Initializing 10K of RP Memory....");

    for (i=0;i<loop;i=i+1) begin
       shmem_write(src_mem_addr+ i*byte_length,   32'hCAFE_FADE,        byte_length);
    end

    unused_result = ebfm_display(EBFM_MSG_INFO, "RP Memory Initialization Done!");

    unused_result = ebfm_display(EBFM_MSG_INFO, "Starting DMA Read....");

    wr_descriptor_addr = WR_FIRST_DESCRIPTOR;       //0x1010
    rd_descriptor_addr = RD_FIRST_DESCRIPTOR;       //0x1210


    // DMA Rd Desc. Table
    // HEADER
    shmem_write(rd_descriptor_addr,      32'h0000_00FF      ,4);
    shmem_write(rd_descriptor_addr+4,    32'h0              ,4);
    shmem_write(rd_descriptor_addr+8,    32'h0              ,4);
    shmem_write(rd_descriptor_addr+12,   32'h0              ,4);
    shmem_write(rd_descriptor_addr+16,   32'h0              ,4);
    shmem_write(rd_descriptor_addr+20,   32'h0              ,4);
    shmem_write(rd_descriptor_addr+24,   32'h0              ,4);
    shmem_write(rd_descriptor_addr+28,   32'h0              ,4);

    // DESCRIPTOR 0
    shmem_write(rd_descriptor_addr+32,  32'h0000_1400       ,4); // RC address lower dword
    shmem_write(rd_descriptor_addr+36,  32'h0000_0000       ,4); // RC address upper dword
    shmem_write(rd_descriptor_addr+40,  32'h0000_0000       ,4); // EP address lower dword
    shmem_write(rd_descriptor_addr+44,  32'h0000_0000       ,4); // EP address upper dword
    shmem_write(rd_descriptor_addr+48,  32'h0000_0400       ,4); // Control field, DMA length
    // DESCRIPTOR 1
    shmem_write(rd_descriptor_addr+64,  32'h0000_2400       ,4); // RC address lower dword
    shmem_write(rd_descriptor_addr+68,  32'h0000_0000       ,4); // RC address upper dword
    shmem_write(rd_descriptor_addr+72,  32'h0000_1000       ,4); // EP address lower dword
    shmem_write(rd_descriptor_addr+76,  32'h0000_0000       ,4); // EP address upper dword
    shmem_write(rd_descriptor_addr+80,  32'h0004_0400       ,4); // Control field, DMA length


    // DMA Wr Desc. Table
    shmem_write(wr_descriptor_addr,     32'h0000_00FF      ,4);
    shmem_write(wr_descriptor_addr+4,   32'h0              ,4);
    shmem_write(wr_descriptor_addr+8,   32'h0              ,4);
    shmem_write(wr_descriptor_addr+12,  32'h0              ,4);
    shmem_write(wr_descriptor_addr+16,  32'h0              ,4);
    shmem_write(wr_descriptor_addr+20,  32'h0              ,4);
    shmem_write(wr_descriptor_addr+24,  32'h0              ,4);
    shmem_write(wr_descriptor_addr+28,  32'h0              ,4);
    // DESCRIPTOR 0
    shmem_write(wr_descriptor_addr+32,  32'h0000_0000       ,4); // EP address lower dword
    shmem_write(wr_descriptor_addr+36,  32'h0000_0000       ,4); // EP address upper dword
    shmem_write(wr_descriptor_addr+40,  32'h0000_4000       ,4); // RC address lower dword
    shmem_write(wr_descriptor_addr+44,  32'h0000_0000       ,4); // RC address upper dword
    shmem_write(wr_descriptor_addr+48,  32'h0000_0400       ,4); // Control field, DMA length
    // DESCRIPTOR 1
    shmem_write(wr_descriptor_addr+64,  32'h0000_1000       ,4); // EP address lower dword
    shmem_write(wr_descriptor_addr+68,  32'h0000_0000       ,4); // EP address upper dword
    shmem_write(wr_descriptor_addr+72,  32'h0000_5000       ,4); // RC address lower dword
    shmem_write(wr_descriptor_addr+76,  32'h0000_0000       ,4); // RC address upper dword
    shmem_write(wr_descriptor_addr+80,  32'h0004_0400       ,4); // Control field, DMA length


    // DMA Read Registers
    downstream_write(bar_table, 0, cntlr_base_addr+256+8 , rd_descriptor_addr, 4); // RC Read Descriptor Base (Low)
    downstream_write(bar_table, 0, cntlr_base_addr+256+12, 32'h0000_0000, 4); // RC Read Descriptor Base (High)
    downstream_write(bar_table, 0, cntlr_base_addr+256+16, 32'h0000_0001, 4); // Last descriptor ID
    downstream_write(bar_table, 0, cntlr_base_addr+256+20, 32'h0000_3000, 4); // EP Read Descriptor Base (Low)
    downstream_write(bar_table, 0, cntlr_base_addr+256+24, 32'h0000_0000, 4); // EP Read Descriptor Base (High)
    // GO!
    downstream_write(bar_table, 0, cntlr_base_addr+256   , 32'h0000_0502, 4); // Read DMA Control

    dma_sts = 32'hFFFF_FFFF;
    while (dma_sts != 32'h0000_0000)
    begin
       #10
       dma_sts = shmem_read(rd_descriptor_addr,4);
    end
    unused_result = ebfm_display(EBFM_MSG_INFO, "DMA Read: Got EPLAST for Desc '0'");
    while (dma_sts != 32'h0000_0001)
    begin
       #10
       dma_sts = shmem_read(rd_descriptor_addr,4);
    end
    unused_result = ebfm_display(EBFM_MSG_INFO, "DMA Read: Got EPLAST for Desc '1'");

    unused_result = ebfm_display(EBFM_MSG_INFO, "Starting DMA Write....");

    // DMA Write Register
    downstream_write(bar_table, 0, cntlr_base_addr+8 , wr_descriptor_addr   , 4); // RC Write Descriptor Base (Low)
    downstream_write(bar_table, 0, cntlr_base_addr+12, 32'h0000_0000        , 4); // RC Write Descriptor Base (High)
    downstream_write(bar_table, 0, cntlr_base_addr+16, 32'h0000_0001        , 1); // Last descriptor ID
    downstream_write(bar_table, 0, cntlr_base_addr+20, 32'h0000_3800        , 4); // EP Write Descriptor Base (Low)
    downstream_write(bar_table, 0, cntlr_base_addr+24, 32'h0000_0000        , 4); // EP Write Descriptor Base (High)
    //GO!
    downstream_write(bar_table, 0, cntlr_base_addr   , 32'h0000_0502        , 4); // Write DMA Control

    dma_sts = 32'hFFFF_FFFF;
    while (dma_sts != 32'h0000_0000)
    begin
       #10
       dma_sts = shmem_read(wr_descriptor_addr,4);
    end
    unused_result = ebfm_display(EBFM_MSG_INFO, "DMA Write: Got EPLAST for Desc '0'");
    while (dma_sts != 32'h0000_0001)
    begin
       #10
       dma_sts = shmem_read(wr_descriptor_addr,4);
    end
    unused_result = ebfm_display(EBFM_MSG_INFO, "DMA Write: Got EPLAST for Desc '1'");

    dest_mem_addr=16384;
    for (i=0;i<8;i=i+1) begin                     // 8K memory comparison
       scr_memory_compare(1024, src_mem_addr+1024*i, dest_mem_addr+1024*i);
    end
end
endtask

///////////////////////////////////////////////////////////////////////////////
//
//
// Main Program
//
// Start of the test bench driver altpcietb_bfm_driver
//
   reg activity_toggle;
   reg timer_toggle ;
   time time_stamp ;
   localparam TIMEOUT = 2000000000;

   initial
     begin
        time_stamp = $time ;
        activity_toggle = 1'b0;
        timer_toggle    = 1'b0;
   end

   // behavioral
   always
   begin : main
   // If you want to relocate the bar_table, modify the BAR_TABLE_POINTER in altpcietb_bfm_shmem.
      // Directly modifying the bar_table at this location may disable overwrite protection for the bar_table
      // If the bar_table is overwritten incorrectly, this will break the testbench functionality.
      parameter bar_table = BAR_TABLE_POINTER; // Default BAR_TABLE_SIZE is 64 bytes
      integer tgt_bar;
      integer dma_bar, rc_slave_bar;
      reg     addr_map_4GB_limit;
      reg     unused_result ;
      reg [15:0] msi_control_register;
      integer i;


      // This constant defines where we save the sizes and programmed addresses
      // of the Endpoint Device Under Test BARs
      // tgt_bar indicates which bar to use for testing the target memory of the
      // reference design.

      // Setup the Root Port and Endpoint Configuration Spaces
      addr_map_4GB_limit = 1'b0;
`ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT1");
`endif
      unused_result = ebfm_display_verb(EBFM_MSG_WARNING,
           "----> Starting ebfm_cfg_rp_ep_rootport task 0");
`ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT2");
`endif
if (APPS_TYPE_HWTCL==6) begin
      ebfm_cfg_rp_ep_rootport(
                     bar_table,         // BAR Size/Address info for Endpoint
                     1,                 // Bus Number for Endpoint Under Test
                     1,                 // Device Number for Endpoint Under Test
                     128,               // Maximum Read Request Size for Root Port
                     0,                 // Display EP Config Space after setup
                     1,                 // Display RP Config Space after setup
                     addr_map_4GB_limit // Limit the BAR assignments to 4GB address map
                     );
   end
 else
   begin
      ebfm_cfg_rp_ep_rootport(
                     bar_table,         // BAR Size/Address info for Endpoint
                     1,                 // Bus Number for Endpoint Under Test
                     1,                 // Device Number for Endpoint Under Test
                     512,               // Maximum Read Request Size for Root Port
                     0,                 // Display EP Config Space after setup
                     1,                 // Display RP Config Space after setup
                     addr_map_4GB_limit // Limit the BAR assignments to 4GB address map
                     );

   end

`ifdef IPD_DEBUG
      ebfm_display(EBFM_MSG_INFO, "-->CHECKPOINT200");
`endif


      activity_toggle <= ~activity_toggle ;

      if (APPS_TYPE_HWTCL==3) begin

       //Downstream
       find_mem_bar(bar_table, 6'b111111, 8, rc_slave_bar);

       downstream_loop(
         bar_table,               // Pointer to the BAR sizing and
         rc_slave_bar,            // Pointer to the BAR sizing and
         RCSLAVE_MAXLEN,          // Number of Write/read iteration
         4,                       // downstream wr/rd length in byte
         0,                       // Downstream EP memory address in byte
                                  // (need to be qword aligned)
         64'hBABA_0000_BEBE_0000);// Starting write data value

       unused_result = ebfm_log_stop_sim(1);

       forever #100000;
       end

      else if ((APPS_TYPE_HWTCL==4) || (APPS_TYPE_HWTCL==5))  begin
      // Avalon-MM Driver

           // Find a memory BAR to use to test the target memory
           // The reference design implements the target memory on BARs 0,1, 4 or 5
           // We need one at least 4 KB big
           if(AVALON_MM_LITE == 0)
               find_mem_bar(bar_table, 6'b110011, 12, tgt_bar);
           else
               find_mem_bar(bar_table, 6'b110011, 4, tgt_bar);
           // Test the reference design's target memory

          if(AVALON_MM_LITE == 0)
          begin
            if (RUN_TGT_MEM_TST == 0)
            begin
              unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping target test.");
            end
            else if (tgt_bar < 6)
            begin

                  target_mem_test(
                         bar_table, // BAR Size/Address info for Endpoint
                         tgt_bar,   // BAR to access target memory with
                         32'h0000,         // Starting offset from BAR
                         512       // Length of memory to test
                         );
            end
            else
            begin
               unused_result = ebfm_display(EBFM_MSG_WARNING, "Unable to find a 4 KB BAR to test Target Memory, skipping target test.");
            end
          end

          else  // is avalon lite
          begin
            if (RUN_TGT_MEM_TST == 0)
            begin
               unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping target test.");
            end
            else
            begin
               for(i=0; i < 4 ; i=i+1)
               begin
                  target_mem_test_lite(
                         bar_table, // BAR Size/Address info for Endpoint
                         tgt_bar,   // BAR to access target memory with
                         i*4,         // Starting offset from BAR
                         4       // Length of memory to test
                         );
               end
            end
          end

        activity_toggle <= ~activity_toggle ;
         // Find a memory BAR to use to setup the DMA channel
         // The reference design implements the DMA channel registers on BAR 2 or 3
         // We need one at least 0x7FFF (CRA 0x4000 + DMA 0x8)
         find_mem_bar(bar_table, 6'b001100, 15, dma_bar);
         // Test the reference design's DMA channel and master memory
         if (RUN_DMA_MEM_TST == 0)
         begin
            unused_result = ebfm_display(EBFM_MSG_WARNING, "Skipping DMA test.");
         end
         else if (dma_bar < 6)
         begin
            dma_mem_test(
                      bar_table, // BAR Size/Address info for Endpoint
                      dma_bar,   // BAR to access DMA control registers
                      0,         // Starting offset of DMA memory
                      512       // Length of memory to test
                      );

         end
         else
         begin
            unused_result = ebfm_display(EBFM_MSG_WARNING, "Unable to find a 128B BAR to test setup DMA channel, skipping DMA test.");
         end

         // Stop the simulator and indicate successful completion
         unused_result = ebfm_log_stop_sim(1);
         forever #100000;
      end
      else if (APPS_TYPE_HWTCL==6)  begin

        avmmdma_rdwr_test(bar_table);

        unused_result = ebfm_log_stop_sim(1);
        forever #100000;
      end
      else begin

      //Chaining DMA
      // Find a memory BAR to use to setup the DMA channel
      // The reference design implements the DMA channel registers on BAR 2 or 3
      // We need one at least 128 B big
      find_mem_bar(bar_table, 6'b001100, 8, dma_bar);

      // Test the chained DMA example design
      if ((dma_bar < 6) && (USE_CDMA>0)) begin
         chained_dma_test(bar_table, dma_bar,0,0,1);  // Read  DMA EPLAST
         time_stamp = $time ;
         chained_dma_test(bar_table, dma_bar,1,0,1);  // Write DMA EPLAST
         time_stamp = $time ;
         chained_dma_test(bar_table, dma_bar,0,1,0);  // Read  DMA EPLAST
         time_stamp = $time ;
         chained_dma_test(bar_table, dma_bar,1,1,0);  // Write DMA EPLAST
      end
      else if (USE_CDMA>0)
         unused_result = ebfm_display_verb(EBFM_MSG_WARNING,
      "Unable to find a 256B BAR to setup the chaining DMA DUT; skipping test.");
      // Stop the simulator and indicate successful completion


      unused_result = ebfm_log_stop_sim(1);
      forever #100000;
      end

   end

   always
     begin
        #(TIMEOUT)
          timer_toggle <= ! timer_toggle ;
     end

   // purpose: this is a watchdog timer, if it sees no activity on the activity
   // toggle signal for 200 us it ends the simulation
   always @(activity_toggle or timer_toggle)
     begin : watchdog
        reg unused_result ;

        if ( ($time - time_stamp) >= TIMEOUT)
          begin
             unused_result = ebfm_display(EBFM_MSG_ERROR_FATAL, "Simulation stopped due to inactivity!");
          end
        time_stamp <= $time ;
     end

endmodule


`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM with Avalon-ST Root Port
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf_ast.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity is the entire PCI Ecpress Root Port BFM
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------

module altpcietb_bfm_vc_intf_ast (clk_in, rstn,
                                  rx_mask,  rx_st_be,  rx_st_sop, rx_st_eop, rx_st_empty, rx_st_data, rx_st_valid, rx_st_ready,
                                  tx_cred, tx_st_ready, tx_st_sop, tx_st_eop, tx_st_empty, tx_st_valid, tx_st_data, tx_fifo_empty,
                                  cfg_io_bas, cfg_np_bas, cfg_pr_bas);


   parameter VC_NUM = 0;
   parameter AVALON_ST_256 = 0;
   parameter AVALON_ST_128 = 0;
   parameter ECRC_FORWARD_CHECK = 1;
   parameter ECRC_FORWARD_GENER = 1;

   input            clk_in;
   input            rstn;
   output           rx_mask;
   input[35:0]      tx_cred;
   input[19:0]      cfg_io_bas;
   input[11:0]      cfg_np_bas;
   input[43:0]      cfg_pr_bas;
   input [1:0]      rx_st_sop;
   input            rx_st_valid;
   output           rx_st_ready;
   input [1:0]      rx_st_eop;
   input [1:0]      rx_st_empty;
   input [255:0]    rx_st_data;
   input [15:0]      rx_st_be;
   input            tx_st_ready;
   output [1:0]     tx_st_sop;
   output [1:0]     tx_st_eop;
   output [1:0]     tx_st_empty;
   output           tx_st_valid;
   output [255:0]   tx_st_data;
   input            tx_fifo_empty;

   wire    [ 81: 0] rx_stream_data_0;
   wire    [ 81: 0] rx_stream_data_1;

   // RX
   wire [1:0]       rx_st_sop_int;
   wire [1:0]       rx_st_eop_int;
   wire [1:0]       rx_st_empty_int;
   wire [255:0]     rx_st_data_int;
   wire [15:0]      rx_st_be_int;
   wire             rx_st_ready_int;
   wire             rx_valid_int;
   wire [7:0]       rx_st_bardec;  assign rx_st_bardec = 8'h0;
   wire             empty;
   wire             almost_full;
   wire [19:0]      unused_st;

   wire             tx_st_ready_int;
   wire [255:0]     tx_st_data_int;
   wire [1:0]       tx_st_sop_int;
   wire [1:0]       tx_st_eop_int;
   wire [1:0]       tx_st_empty_int;
   wire             tx_st_valid_int;

   wire    [ 81: 0] rx_stream_data_0_int;
   wire    [ 81: 0] rx_stream_data_1_int;
   wire    [ 129:0] rx_stream_data_2_int;
   wire             rx_st_valid_int;

   wire             rx_ecrc_check_valid;
   wire [15:0]      ecrc_bad_cnt;
   reg              ecrc_err;

   always @ (posedge clk_in or negedge rstn) begin
       if (rstn==1'b0)
           ecrc_err <= 1'b0;
       else begin
           if (ecrc_bad_cnt > 0)
               ecrc_err <= 1'b1;    // assert and hold when ecrc error is detected
       end

   end



  //////////////////////////////////////////////////////////////
  // RECEIVE RX AVALON-ST INPUT
  // If ECRC Forwarding is enabled, then first route thru the
  // ECRC checker to remove ECRC from data stream.
  //////////////////////////////////////////////////////////////

   generate begin: rx_ecrc_genblk

       wire    [ 81: 0] rx_stream_data_0_ecrc;
       wire    [ 81: 0] rx_stream_data_1_ecrc;
       wire             rx_st_valid_ecrc;
       wire             rx_st_ready_ecrc;
       wire[15:0]       rx_st_be_ecrc;
       wire[7:0]        rx_st_bardec_ecrc;
       wire             rx_st_sop_ecrc;
       wire             rx_st_eop_ecrc;
       wire             rx_st_empty_ecrc;
       wire [139:0]     rx_st_data_ecrc;

       ///////////////////////////////////////////////
       // RX ECRC CHECKING
       // ECRC is checked and removed from the data
       ///////////////////////////////////////////////
       if (ECRC_FORWARD_CHECK==1) begin: rx_ecrc

           altpcierd_cdma_ecrc_check #(.AVALON_ST_128(AVALON_ST_128)) cdma_ecrc_check(
                // Input Avalon-ST prior to check ECRC
                .rxdata                ({rx_st_sop, 1'b0, rx_st_empty, rx_st_eop, rx_st_bardec, rx_st_data}),
                .rxdata_be             (rx_st_be),
                .rx_stream_ready0      (~almost_full),
                .rx_stream_valid0      (rx_st_valid),

                // Output Avalon-ST after checking ECRC
                .rxdata_ecrc           (rx_st_data_ecrc),
                .rxdata_be_ecrc        (rx_st_be_ecrc),
                .rx_stream_ready0_ecrc (rx_st_ready_ecrc),
                .rx_stream_valid0_ecrc (rx_st_valid_ecrc),

                .rx_ecrc_check_valid   (rx_ecrc_check_valid),
                .ecrc_bad_cnt          (ecrc_bad_cnt),
                .clk_in                (clk_in),
                .srst                  (~rstn)
               );

 /*
          // Simulation Monitor
           initial begin
               wait (rstn==1);
               wait (ecrc_bad_cnt==0);
               wait (ecrc_bad_cnt>0);
               $display (" >>>>  RP:  BAD ECRC RECEIVED <<<<");
           end
*/
           ///////////////////////////////////////////////
           // ECRC sources data to VCINTF (via RX FIFO)

           assign rx_st_bardec_ecrc = rx_st_data_ecrc[135:128];
           assign rx_st_sop_ecrc    = rx_st_data_ecrc[139];
           assign rx_st_eop_ecrc    = rx_st_data_ecrc[136];
           assign rx_st_empty_ecrc  = rx_st_data_ecrc[137];

           assign rx_stream_data_0_int =  {rx_st_be_ecrc[7:0], rx_st_sop_ecrc, rx_st_eop_ecrc, rx_st_bardec_ecrc, rx_st_data_ecrc[63:0]};
           assign rx_stream_data_1_int =  {rx_st_be_ecrc[15:8], 1'b0, rx_st_empty_ecrc, 8'h0, rx_st_data_ecrc[127:64]};
           assign rx_st_valid_int      =  rx_st_valid_ecrc;
           assign rx_st_ready          =  rx_st_ready_ecrc;

       end

       ///////////////////////////
       //  NO ECRC FORWARDING
       ///////////////////////////
       else begin
           /////////////////////////////////////////////////////////////
           // Avalon-ST IO sources data to VCINTF (via RX FIFO)

           assign rx_stream_data_0_int =  {rx_st_be[7:0], rx_st_sop[0], rx_st_eop[0], rx_st_bardec, rx_st_data[63:0]};
           assign rx_stream_data_1_int =  {rx_st_be[15:8], rx_st_empty, 8'h0, rx_st_data[127:64]};
           assign rx_stream_data_2_int =  {rx_st_data[255:128], rx_st_sop[1], rx_st_eop[1]};
           assign rx_st_valid_int      =  rx_st_valid;
           assign rx_st_ready          =  ~almost_full;
         //  assign rx_st_ready = rx_st_ready_int;
           assign rx_ecrc_check_valid  = 0;
           assign ecrc_bad_cnt         = 0;
       end
       end
   endgenerate


   //////////////////////////////////////////////////////////////////////
   // RX FIFO
   // Avalon-ST data is held in a FIFO until RP (VC INTF) can process it
   //////////////////////////////////////////////////////////////////////


   // FIFO parameters
   parameter  RXFIFO_DEPTH = 32;
   parameter  RXFIFO_WIDTH = 294;
   parameter  RXFIFO_WIDTHU = 5;

   scfifo # (
             .add_ram_output_register ("OFF")          ,
             .intended_device_family  ("Stratix II GX"),
             .lpm_numwords            (RXFIFO_DEPTH),
             .lpm_showahead           ("ON")          ,
             .lpm_type                ("scfifo")       ,
             .lpm_width               (RXFIFO_WIDTH) ,
             .lpm_widthu              (RXFIFO_WIDTHU),
             .overflow_checking       ("OFF")           ,
             .underflow_checking      ("OFF")           ,
             .almost_full_value       (RXFIFO_DEPTH/2) ,
             .use_eab                 ("OFF")

             ) rx_data_fifo (
            .clock ( clk_in),
            .sclr  (~rstn ),

            .data  ({rx_stream_data_2_int, rx_stream_data_1_int, rx_stream_data_0_int}),
            .wrreq (rx_st_valid_int),

            .rdreq (rx_st_ready_int & ~empty),
            .q     ({  rx_st_data_int[255:128], rx_st_sop_int[1], rx_st_eop_int[1],
                       rx_st_be_int[15:8], rx_st_empty_int, unused_st[15:8], rx_st_data_int[127:64],
                       rx_st_be_int[7:0], rx_st_sop_int[0], rx_st_eop_int[0], unused_st[7:0], rx_st_data_int[63:0]
                    }),

            .empty (empty),
            .full  ( ),
            .usedw ()
            // synopsys translate_off
            ,
            .aclr (1'b0),
            .almost_empty (),
            .almost_full (almost_full)
            // synopsys translate_on
            );



   ////////////////////////////////////////////////////////////////////////
   // VC INTERFACE MODULE
   // Receives, Generates, and Processes RP traffic.
   //
   // Instantiate 128-bit Avalon-ST version, or 64-bit Avalon-ST version.
   /////////////////////////////////////////////////////////////////////////


     assign rx_valid_int = rx_st_ready_int & ~empty;

     generate begin: vc_intf_genblk

     if (AVALON_ST_256==1) begin: vc_intf_256_genblk
         altpcietb_bfm_vc_intf_256 #(.VC_NUM (VC_NUM)) vc_intf_256(
           .clk_in        (clk_in),
           .rstn          (rstn),
           .rx_mask       (rx_mask),
           .rx_be         (rx_st_be_int),
           .tx_cred       (tx_cred),
           .tx_st_ready   (tx_st_ready_int),
           .rx_st_sop     (rx_st_sop_int),
           .rx_st_eop     (rx_st_eop_int),
           .rx_st_empty   (rx_st_empty_int),
           .rx_st_data    (rx_st_data_int),
           .rx_st_valid   (rx_valid_int),
           .rx_st_ready   (rx_st_ready_int),
           .tx_st_sop     (tx_st_sop_int),
           .tx_st_eop     (tx_st_eop_int),
           .tx_st_empty   (tx_st_empty_int),
           .tx_st_data    (tx_st_data_int),
           .tx_st_valid   (tx_st_valid_int),
           .tx_fifo_empty (tx_fifo_empty)
        );
     end
     else if (AVALON_ST_128==1) begin: vc_intf_128_genblk

         altpcietb_bfm_vc_intf_128 #(.VC_NUM (VC_NUM)) vc_intf_128(
           .clk_in        (clk_in),
           .rstn          (rstn),
           .rx_mask       (rx_mask),
           .rx_be         (rx_st_be_int),
           .rx_ecrc_err   (ecrc_err),
           .tx_cred       (tx_cred),
           .tx_st_ready   (tx_st_ready_int),
           .cfg_io_bas    (cfg_io_bas),
           .cfg_np_bas    (cfg_np_bas),
           .cfg_pr_bas    (cfg_pr_bas),
           .rx_st_sop     (rx_st_sop_int),
           .rx_st_eop     (rx_st_eop_int),
           .rx_st_empty   (rx_st_empty_int),
           .rx_st_data    (rx_st_data_int[127:0]),
           .rx_st_valid   (rx_valid_int),
           .rx_st_ready   (rx_st_ready_int),
           .tx_st_sop     (tx_st_sop_int),
           .tx_st_eop     (tx_st_eop_int),
           .tx_st_empty   (tx_st_empty_int),
           .tx_st_data    (tx_st_data_int),
           .tx_st_valid   (tx_st_valid_int),
           .tx_fifo_empty (tx_fifo_empty)
        );

     end
     else begin: vc_intf_64_genblk

        altpcietb_bfm_vc_intf_64 #(.VC_NUM (VC_NUM)) vc_intf_64(
           .clk_in        (clk_in),
           .rstn          (rstn),
           .rx_mask       (rx_mask),
           .rx_be         (rx_st_be_int),
           .rx_ecrc_err   (ecrc_err),
           .tx_cred       (tx_cred),
           .cfg_io_bas    (cfg_io_bas),
           .cfg_np_bas    (cfg_np_bas),
           .cfg_pr_bas    (cfg_pr_bas),
           .rx_st_sop     (rx_st_sop_int),
           .rx_st_eop     (rx_st_eop_int),
           .rx_st_empty   (rx_st_empty_int),
           .rx_st_data    (rx_st_data_int[63:0]),
           .rx_st_valid   (rx_valid_int),
           .rx_st_ready   (rx_st_ready_int),
           .tx_st_sop     (tx_st_sop_int),
           .tx_st_eop     (tx_st_eop_int),
           .tx_st_empty   (tx_st_empty_int),
           .tx_st_data    (tx_st_data_int[63:0]),
           .tx_st_valid   (tx_st_valid_int),
           .tx_st_ready   ((tx_st_ready_int)),
           .tx_fifo_empty (tx_fifo_empty)
        );

     end
    end
  endgenerate



  ////////////////////////////////////////////////////////////////
  // DRIVE AVALON-ST TX OUTPUT
  // If ECRC FORWARDING is enabled, then calculate and append
  // the ECRC to the Avalon-ST output.
  ///////////////////////////////////////////////////////////////

   generate begin: tx_ecrc_genblk
      ////////////////////////////////////////////////////////////
      // ECRC FORWARDING
      // ECRC is calculated and appended to the VC INTF traffic
      // if ECRC forwarding is enabled.

      if (ECRC_FORWARD_GENER==1) begin: tx_ecrc
          // ECRC output side
          wire[127:0] tx_st_data_ecrc;
          wire        tx_st_sop_ecrc;
          wire        tx_st_eop_ecrc;
          wire        tx_st_empty_ecrc;
          wire[73:0]  tx_st_data_ecrc0;
          wire[73:0]  tx_st_data_ecrc1;
          wire        tx_st_ready_ecrc;
          wire        tx_st_valid_ecrc;

          // ECRC input side
          reg[127:0]  user_data_reg;
          reg         user_valid_reg;
          reg         user_sop_reg;
          reg         user_eop_reg;
          reg         user_empty_reg;

          wire[127:0] user_data_ecrc;
          wire        user_valid_ecrc;
          wire        user_sop_ecrc;
          wire        user_eop_ecrc;
          wire        user_empty_ecrc;
          reg         tx_st_ready_ecrc_reg;

          ///////////////////////////////////////////////////////////////
          // Glue logic to hold the vc_intf signals until it is 'acked'
          // by the ecrc module  (via tx_st_ready_ecrc).
          /*
                   ECRC Interface:
                                        ________     ________________
                       tx_st_ready_ecrc (ack)   |___|
                                             ________________________
                       user_valid_ecrc  ____|
                                        ______________________________
                       user_data_ecrc   ____|_0_|_1_____|_2_|_3_|_4_|_
          */

          always @ (posedge clk_in or negedge rstn) begin
              if (rstn==1'b0) begin
                      user_data_reg  <= 0;
                      user_valid_reg <= 0;
                      user_sop_reg  <= 0;
                      user_eop_reg  <= 0;
                      user_empty_reg  <= 0;
                      tx_st_ready_ecrc_reg <= 0;
              end
              else begin
                  if ((tx_st_ready_ecrc==1'b0) & (tx_st_ready_ecrc_reg==1'b1)) begin
                      user_data_reg  <= {tx_st_data_int[31:0],tx_st_data_int[63:32], tx_st_data_int[95:64],tx_st_data_int[127:96]};
                      user_valid_reg <= tx_st_valid_int;
                      user_sop_reg   <= tx_st_sop_int;
                      user_eop_reg   <= tx_st_eop_int;
                      user_empty_reg <= tx_st_empty_int;
                  end
                  tx_st_ready_ecrc_reg <= tx_st_ready_ecrc;
              end
          end

          assign user_data_ecrc  = ((tx_st_ready_ecrc_reg==0) & (tx_st_ready_ecrc==1'b1)) ? user_data_reg :
                                   {tx_st_data_int[31:0],tx_st_data_int[63:32], tx_st_data_int[95:64],tx_st_data_int[127:96]} ;

          assign user_valid_ecrc = ((tx_st_ready_ecrc_reg==0) & (tx_st_ready_ecrc==1'b1)) ?  user_valid_reg :  tx_st_valid_int;

          assign user_sop_ecrc   = ((tx_st_ready_ecrc_reg==0) & (tx_st_ready_ecrc==1'b1)) ?  user_sop_reg :  tx_st_sop_int;

          assign user_eop_ecrc   = ((tx_st_ready_ecrc_reg==0) & (tx_st_ready_ecrc==1'b1)) ? user_eop_reg  : tx_st_eop_int;
          assign user_empty_ecrc = ((tx_st_ready_ecrc_reg==0) & (tx_st_ready_ecrc==1'b1)) ? user_empty_reg  : tx_st_empty_int;


          /////////////////////////////
          // TX ECRC MODULE
          // ecrc generate and append

          altpcierd_cdma_ecrc_gen  #(.AVALON_ST_128(AVALON_ST_128))
             cdma_ecrc_gen (
               .clk               (clk_in),
               .rstn              (rstn),
               .user_rd_req       (tx_st_ready_ecrc),
               .user_sop          (user_sop_ecrc),
               .user_eop          ({user_eop_ecrc, user_empty_ecrc}),
               .user_data         (user_data_ecrc),
               .user_valid        (user_valid_ecrc),
               .tx_stream_ready0  (tx_st_ready),
               .tx_stream_data0_0 (tx_st_data_ecrc0),
               .tx_stream_data0_1 (tx_st_data_ecrc1),
               .tx_stream_valid0  (tx_st_valid_ecrc));

           ///////////////////////////
           // Drive Avalon-ST output

           assign tx_st_data[63:0]   = {tx_st_data_ecrc0[31:0], tx_st_data_ecrc0[63:32]};
           assign tx_st_empty        = tx_st_data_ecrc0[73];
           assign tx_st_sop          = tx_st_data_ecrc0[72];
          // assign tx_st_data[132]  = 1'b0;
           assign tx_st_eop          = tx_st_data_ecrc1[73];
          // assign tx_st_data[129]  = tx_st_data_ecrc1[72];
           assign tx_st_data[127:64] = {tx_st_data_ecrc1[31:0], tx_st_data_ecrc1[63:32]};
           assign tx_st_ready_int    = tx_st_ready_ecrc;
           assign tx_st_valid        = tx_st_valid_ecrc;
      end

      ////////////////////////////////////////////////////
      // NO ECRC FORWARDING
      // Wire directly from vc_intf

      else begin
           assign tx_st_data      =  tx_st_data_int;
           assign tx_st_eop       =  tx_st_eop_int;
           assign tx_st_sop       =  tx_st_sop_int;
           assign tx_st_empty     =  tx_st_empty_int;
           assign tx_st_ready_int =  tx_st_ready;
           assign tx_st_valid     =  tx_st_valid_int;
      end
   end
   endgenerate

endmodule

module altpcietb_bfm_vc_intf_256 (clk_in, rstn, rx_mask,  rx_be,  rx_st_sop, rx_st_eop, rx_st_empty, rx_st_data, rx_st_valid, rx_st_ready, tx_cred,  tx_err,
                                  tx_st_ready, tx_st_sop, tx_st_eop, tx_st_empty, tx_st_valid, tx_st_data, tx_fifo_empty);

   parameter VC_NUM  = 0;

   input clk_in;
   input rstn;
   output rx_mask;
   input [15:0]rx_be;
   input [35:0] tx_cred;
   output reg tx_err;
   input [1:0] rx_st_sop;
   input       rx_st_valid;
   output reg rx_st_ready;
   input [1:0] rx_st_eop;
   input [1:0] rx_st_empty;
   input [255:0] rx_st_data;
   input tx_st_ready;
   output reg [1:0] tx_st_sop;
   output reg  [1:0] tx_st_eop;
   output reg  [1:0] tx_st_empty;
   output reg  tx_st_valid;
   output reg [255:0] tx_st_data;
   input tx_fifo_empty;

   wire clk_500, clk250_delayed;
   wire rx_st_sop_128;
   wire rx_st_valid_128;
   wire rx_st_eop_128;
   wire rx_st_empty_128;
   wire [127:0] rx_st_data_128;

   wire tx_ready_int, tx_st_sop_int, tx_st_eop_int, tx_st_empty_int;
   wire [127:0] tx_st_data_int;
   wire tx_valid_int;
   wire [130:0] tx_stream_data_0_int;
   wire full, empty, almost_full;
   wire rx_st_ready_128;
   reg  rx_st_ready_256_int;

   wire         tx_st_sop_128;
   wire         tx_st_eop_128;
   wire         tx_st_valid_128;
   wire         tx_st_empty_128;
   wire [127:0] tx_st_data_128;
   reg          tx_st_sop_int2;
   reg          tx_st_eop_int2;
   reg          tx_valid_int2;
   reg          tx_st_empty_int2;
   reg  [127:0] tx_st_data_int2;

   reg clk250_phase;
   reg phase_tx_avst128;
   reg clk_avst128, clk_avst128_r;

   //Generation of clock of double the frequency
   assign #1000 clk250_delayed = clk_in;
   assign clk_500 = clk_in ^ clk250_delayed;                       //500Mhz clock

   always @(posedge clk_500, negedge rstn) begin
      if (!rstn) begin
         clk250_phase <= 1'b0;
         clk_avst128  <= 1'b0;
      end
      else begin
         clk250_phase <= clk250_phase + 1'b1;
         clk_avst128 <= clk_in;
      end
   end

   //RX
   assign rx_st_data_128  = (rx_st_valid==0)?128'b0:(clk250_phase==0)?rx_st_data[127:0]:rx_st_data[255:128];
   assign rx_st_sop_128   = (rx_st_valid==0)?1'b0  :(clk250_phase==0)?rx_st_sop[0]     :rx_st_sop[1];
   assign rx_st_eop_128   = (rx_st_valid==0)?1'b0  :(clk250_phase==0)?rx_st_eop[0]     :rx_st_eop[1];
   assign rx_st_empty_128 = (rx_st_valid==0)?1'b0  :(clk250_phase==0)?rx_st_empty[0]   :rx_st_empty[1];
   assign rx_st_valid_128 = (rx_st_valid==0)?1'b0  :(clk250_phase==0)?!rx_st_sop[1] | rx_st_eop[0]  :!rx_st_eop[0] | rx_st_sop[1];


   //TX

   always @(posedge clk_500, negedge rstn) begin
      if (!rstn) begin
         tx_st_sop_int2    <= 1'b0;
         tx_st_eop_int2    <= 1'b0;
         tx_valid_int2     <= 1'b0;
         tx_st_empty_int2  <= 1'b0;
         tx_st_data_int2   <= 128'h0;
         tx_st_sop         <= 2'b0;
         tx_st_eop         <= 2'b0;
         tx_st_empty       <= 2'b0;
         tx_st_valid       <= 1'b0;
         tx_st_data        <= 256'b0;
         phase_tx_avst128  <= 1'b0;
         clk_avst128_r     <= 1'b0;
      end
      else begin
         clk_avst128_r <= clk_avst128;

         if (!clk_avst128 & !clk_avst128_r) begin
            phase_tx_avst128 <= 1'b1;
         end
         else begin
            phase_tx_avst128 <= phase_tx_avst128 +1'b1;
         end

         rx_st_ready_256_int <= rx_st_ready_128;
         tx_valid_int2 <= tx_valid_int;

         if(phase_tx_avst128==1) begin
            tx_st_sop_int2        <= (tx_valid_int==1)?tx_st_sop_int:1'b0;
            tx_st_eop_int2        <= (tx_valid_int==1)?tx_st_eop_int:1'b0;
            tx_st_empty_int2      <= (tx_valid_int==1)?tx_st_empty_int:1'b0;
            tx_st_data_int2       <= (tx_valid_int==1)?tx_st_data_int:128'h0;
         end
         else begin
            tx_st_sop   <= (tx_valid_int==1)?{tx_st_sop_int, tx_st_sop_int2}:{1'b0, tx_st_sop_int2};
            tx_st_eop   <= (tx_valid_int==1)?{tx_st_eop_int, tx_st_eop_int2}:{1'b0, tx_st_eop_int2};
            tx_st_empty <= (tx_valid_int==1)?{tx_st_empty_int, tx_st_empty_int2}:{1'b0, tx_st_empty_int2};
            tx_st_valid <=  tx_valid_int | tx_valid_int2;
            tx_st_data  <= (tx_valid_int==1)?{tx_st_data_int, tx_st_data_int2}:{128'h0, tx_st_data_int2};
            rx_st_ready <= rx_st_ready_256_int & rx_st_ready_128;
         end
      end
   end

   //////////////////////////////////////////////////////////////////////
   // TX FIFO
   // Avalon-ST data is held in a FIFO until gearbox can process it
   //////////////////////////////////////////////////////////////////////


   //FIFO parameters
   parameter  TXFIFO_DEPTH = 20;
   parameter  TXFIFO_WIDTH = 131;
   parameter  TXFIFO_WIDTHU = 5;

   //FIFO control/data
   assign tx_stream_data_0_int =  {tx_st_sop_128, tx_st_eop_128, tx_st_empty_128, tx_st_data_128};
   assign tx_valid_int = tx_st_ready & ~empty;
   assign tx_ready_int = ~almost_full;

   scfifo # (
             .add_ram_output_register ("OFF"),
             .intended_device_family  ("Stratix II GX"),
             .lpm_numwords            (TXFIFO_DEPTH),
             .lpm_showahead           ("ON"),
             .lpm_type                ("scfifo"),
             .lpm_width               (TXFIFO_WIDTH),
             .lpm_widthu              (TXFIFO_WIDTHU),
             .overflow_checking       ("OFF"),
             .underflow_checking      ("OFF"),
             .almost_full_value       (TXFIFO_DEPTH/2),
             .use_eab                 ("OFF")
             )  tx_data_fifo (
            .clock ( clk_500),
            .sclr  (~rstn ),
            .data  (tx_stream_data_0_int),
            .wrreq (tx_st_valid_128),
            .rdreq (tx_st_ready & ~empty),
            .q     ({tx_st_sop_int, tx_st_eop_int, tx_st_empty_int, tx_st_data_int[127:0]}),
            .empty (empty),
            .full  (full),
            .usedw (),
            .almost_full (almost_full)
            );

   //VC INTF running at 500MHz
   //
   altpcietb_bfm_vc_intf_128 #(.VC_NUM (VC_NUM)) vc_intf_128(
           .clk_in        (clk_500),
           .rstn          (rstn),
           .rx_mask       (rx_mask),
           .rx_be         (rx_st_be_int),
           .tx_cred       (tx_cred),
           .tx_st_ready   (tx_ready_int),
           .rx_st_sop     (rx_st_sop_128),
           .rx_st_eop     (rx_st_eop_128),
           .rx_st_empty   (rx_st_empty_128),
           .rx_st_data    (rx_st_data_128),
           .rx_st_valid   (rx_st_valid_128),
           .rx_st_ready   (rx_st_ready_128),
           .tx_st_sop     (tx_st_sop_128),
           .tx_st_eop     (tx_st_eop_128),
           .tx_st_empty   (tx_st_empty_128),
           .tx_st_data    (tx_st_data_128),
           .tx_st_valid   (tx_st_valid_128),
           .tx_fifo_empty (tx_fifo_empty)
        );

endmodule

`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port Avalon-ST128 VC Interface
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf_128.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity interfaces between the root port transaction list processor
// and the root port module single VC interface. It handles the following basic
// functions:
// * Formating Tx Descriptors
// * Retrieving Tx Data as needed from the shared memory
// * Decoding Rx Descriptors
// * Storing Rx Data as needed to the shared memory
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_bfm_vc_intf_128 (clk_in, rstn, rx_mask,  rx_be,  rx_st_sop, rx_st_eop, rx_st_empty, rx_st_data, rx_st_valid, rx_st_ready, rx_ecrc_err,
                                  tx_cred,  tx_err,
                                  tx_st_ready, tx_st_sop, tx_st_eop, tx_st_empty, tx_st_valid, tx_st_data, tx_fifo_empty, cfg_io_bas, cfg_np_bas, cfg_pr_bas);

   parameter VC_NUM  = 0;
   parameter DISABLE_RX_BE_CHECK  = 1;
   `include "altpcietb_g3bfm_constants.v"
   `include "altpcietb_g3bfm_log.v"
   `include "altpcietb_g3bfm_shmem.v"
   `include "altpcietb_g3bfm_req_intf.v"

   input clk_in;
   input rstn;
   output rx_mask;
   reg rx_mask;
   input[15:0] rx_be;
   input[35:0] tx_cred;
   output tx_err;
   reg tx_err;
   input[19:0] cfg_io_bas;
   input[11:0] cfg_np_bas;
   input[43:0] cfg_pr_bas;
   input rx_st_sop;
   input rx_st_valid;
   output rx_st_ready;
   reg rx_st_ready;
   input rx_st_eop;
   input rx_st_empty;
   input[127:0] rx_st_data;
   input rx_ecrc_err;
   input tx_st_ready;
   output tx_st_sop;
   reg tx_st_sop;
   output tx_st_eop;
   reg tx_st_eop;
   output tx_st_empty;
   reg tx_st_empty;
   output tx_st_valid;
   reg tx_st_valid;
   output[127:0] tx_st_data;
   reg[127:0] tx_st_data;
   input tx_fifo_empty;

   parameter[2:0] RXST_IDLE = 0;
   parameter[2:0] RXST_DESC_ACK = 1;
   parameter[2:0] RXST_DATA_WRITE = 2;
   parameter[2:0] RXST_DATA_NONP_WRITE = 3;
   parameter[2:0] RXST_DATA_COMPL = 4;
   parameter[2:0] RXST_NONP_REQ = 5;
   parameter[1:0] TXST_IDLE = 0;
   parameter[1:0] TXST_DESC = 1;
   parameter[1:0] TXST_DATA = 2;
   reg[2:0] rx_state;
   reg[1:0] tx_state;




   // Communication signals between main Tx State Machine and main Rx State Machine
   // to indicate when completions are expected
   integer exp_compl_tag;
   integer exp_compl_bcount;

   // Communication signals between Rx State Machine and Tx State Machine
   // for requesting completions
   reg rx_tx_req;
   reg[127:0] rx_tx_desc;
   integer rx_tx_shmem_addr;
   integer rx_tx_bcount;
   reg[7:0] rx_tx_byte_enb;
   reg tx_rx_ack;


   // Communication Signals for PErf Monitoring
   reg[10:0] tx_payld_length;
   reg[10:0] rx_payld_length;
   reg       rx_update_pkt_count;
   reg       tx_update_pkt_count;

   // support for streaming interface
   reg[135:0] rx_desc_int;
   wire[135:0] rx_desc_int_v;
   wire[127:0] rx_st_data_128;



   ///////////////////////////////////////////////////
   // Common functions and tasks used in this module

   `include "altpcietb_g3bfm_vc_intf_ast_common.v"



   ///////////////////////////////////////////////////
   // RX and TX processing

   assign rx_st_data_128 = rx_st_data;  // H3H2H1H0, D3D2D1D0.
   assign rx_desc_int_v = ((rx_st_sop==1'b1) & (rx_st_valid==1'b1)) ?  {rx_st_data_128[31:0], rx_st_data_128[63:32], rx_st_data_128[95:64], rx_st_data_128[127:96]} : rx_desc_int;


   // behavioral
   always @(clk_in)
   begin : main_rx_state
      integer compl_received_v[0:EBFM_NUM_TAG - 1];
      integer compl_expected_v[0:EBFM_NUM_TAG - 1];
      reg[2:0] rx_state_v;
      reg rx_st_ready_v;// pops data from RX FIFO (lookahead)
      integer shmem_addr_v;
      integer rx_compl_tag_v;
      reg[SHMEM_ADDR_WIDTH - 1:0] rx_compl_baddr_v;
      reg[2:0] rx_compl_sts_v;
      reg[7:0] byte_enb_v;
      reg[15:0] byte_enb_128_v;
      integer bcount_v;
      reg rx_tx_req_v;
      reg[127:0] rx_tx_desc_v;
      integer rx_tx_shmem_addr_v;
      integer rx_tx_bcount_v;
      reg[7:0] rx_tx_byte_enb_v;
      reg rx_update_pkt_count_v;
      reg[10:0]   rx_payld_length_v;
      reg      dummy ;
      reg     rx_ecrc_err_reg;

      integer  shmem_addr0_debug;
      reg[15:0] byte_en_debug;
      reg[127:0] data_debug;

      integer      i ;
      if (clk_in == 1'b1)
      begin
         if (rstn != 1'b1)
         begin
            rx_state_v = RXST_IDLE;
            rx_compl_tag_v = -1;
            rx_compl_sts_v = {3{1'b1}};
            rx_tx_req_v = 1'b0;
            rx_tx_desc_v = {128{1'b0}};
            rx_tx_shmem_addr_v = 0;
            rx_tx_bcount_v = 0;
            rx_tx_bcount_v = 0;
            rx_payld_length_v = 11'h0;
            rx_update_pkt_count_v = 11'b0;
            rx_ecrc_err_reg = 1'b0;
            for (i = 0 ; i < EBFM_NUM_TAG ; i = i + 1)
              begin
                 compl_expected_v[i] = -1;
                 compl_received_v[i] = -1;
              end
         end
         else
         begin
            // See if the Transmit side is transmitting a Non-Posted Request
            // that we need to expect a completion for and if so record it
            if (exp_compl_tag > -1)
            begin
               compl_expected_v[exp_compl_tag] = exp_compl_bcount;
               compl_received_v[exp_compl_tag] = 0;
            end
            rx_state_v = rx_state;
            rx_tx_req_v = 1'b0;

            // for performance monitor
            rx_update_pkt_count_v = (rx_st_eop == 1'b1) & (rx_st_valid == 1'b1);
            if (rx_desc_int_v[126]==1'b1) begin
                if (rx_desc_int_v[105:96]==10'h0)
                    rx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    rx_payld_length_v <= {1'b0, rx_desc_int_v[105:96]};
            end

            rx_ecrc_err_reg <= rx_ecrc_err;
            if ((rx_ecrc_err_reg == 0) & (rx_ecrc_err==1)) begin
               dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         {"Root Port VC", dimage1(VC_NUM),
                          " Detected ECRC Error " });
            end

            case (rx_state)
               RXST_IDLE, RXST_DESC_ACK, RXST_DATA_COMPL, RXST_DATA_WRITE, RXST_DATA_NONP_WRITE :
                        begin
                           rx_st_ready_v = 1'b1;

                           if ((rx_state == RXST_IDLE) && (rx_st_sop == 1'b1) && (rx_st_valid==1'b1))
                           begin
                              if (is_request(rx_desc_int_v))
                              begin
                                 // All of these states are handled together since they can all
                                 // involve data transfer and we need to share that code.
                                 //
                                 // If this is the cycle where the descriptor is being ack'ed we
                                 // need to complete the descriptor decode first so that we can
                                 // be prepared for the Data Transfer that might happen in the same
                                 // cycle.
                                 if (is_non_posted(rx_desc_int_v))
                                 begin
                                    // Non-Posted Request
                                    rx_nonp_req_setup_compl(rx_desc_int_v, rx_tx_desc_v, rx_tx_shmem_addr_v, rx_tx_byte_enb_v, rx_tx_bcount_v);
                                    // Request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Non-Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_state_v = RXST_DATA_NONP_WRITE;
                                       rx_st_ready_v = 1'b1;
                                       if (is_3dw_nonaligned(rx_desc_int_v))
                                           byte_enb_128_v = {byte_enb_v, 8'h0};
                                       else
                                           byte_enb_128_v = {8'hff, byte_enb_v};
                                    end
                                    else
                                    begin
                                       // Non-Posted Read Request
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                 end
                                 else
                                 begin
                                    // Posted Request
                                    rx_tx_desc_v = {128{1'b0}};
                                    rx_tx_shmem_addr_v = 0;
                                    rx_tx_byte_enb_v = {8{1'b0}};
                                    rx_tx_bcount_v = 0;
                                    // Begin Lengthy decode and checking of the Rx Descriptor
                                    // First Determine if it is a completion or a request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_DATA_WRITE;
                                       if (is_3dw_nonaligned(rx_desc_int_v))
                                           byte_enb_128_v = {byte_enb_v, 8'h0};
                                       else
                                           byte_enb_128_v = {8'hff, byte_enb_v};
                                    end
                                    else
                                    begin
                                       // Posted Message without Data
                                       // Not currently supported.
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_IDLE;
                                    end
                                 end
                              end
                              else // is_request == 0
                              begin
                                 // Completion
                                 rx_compl_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v,
                                                rx_compl_tag_v, rx_compl_sts_v);
                                 if (compl_expected_v[rx_compl_tag_v] < 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Recevied unexpected completion TLP, Fmt/Type: ",
                                                  himage2(rx_desc_int[127:120]),
                                                  " Tag: ", himage2(rx_desc_int[47:40])});
                                 end
                                 if (has_data(rx_desc_int_v))
                                 begin
                                    rx_st_ready_v = 1'b1;
                                    rx_state_v = RXST_DATA_COMPL;
                                    // Increment for already received data phases
                                    shmem_addr_v = shmem_addr_v + compl_received_v[rx_compl_tag_v];
                                    if (is_3dw_nonaligned(rx_desc_int_v))
                                        byte_enb_128_v = {byte_enb_v, 8'h0};
                                    else
                                        byte_enb_128_v = {8'hff, byte_enb_v};
                                 end
                                 else
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    rx_st_ready_v = 1'b1;
                                    if ((compl_received_v[rx_compl_tag_v] < compl_expected_v[rx_compl_tag_v]) &
                                        (rx_compl_sts_v == 3'b000))
                                    begin
                                       dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                                                    {"Root Port VC", dimage1(VC_NUM),
                                                     " Did not receive all expected completion data. Expected: ",
                                                     dimage4(compl_expected_v[rx_compl_tag_v]),
                                                     " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                    end
                                    // Report that it is complete to the Driver
                                    vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                    // Clear out that we expect anymore
                                    compl_received_v[rx_compl_tag_v] = -1;
                                    compl_expected_v[rx_compl_tag_v] = -1;
                                    rx_compl_tag_v = -1;
                                 end
                              end
                           end
                           // Collect Payload when
                           //    - in any state after the Descriptor phase or
                           //    - during descriptor phase, but only if it is a 3DW Header, Non-QWord aligned packet
                           if ((rx_st_valid == 1'b1) && (rx_desc_int_v[126]==1'b1) &&
                                     (    (rx_state!=RXST_IDLE) ||
                                          ((rx_state == RXST_IDLE) && (rx_st_sop == 1'b1) && (is_3dw_nonaligned(rx_desc_int_v))) ))
                           begin

                              begin : xhdl_3
                                 integer i;
                                 for(i = 0; i <= 15; i = i + 1)               // process 128 bytes
                                 begin

                                    if (i==0)
                                       shmem_addr0_debug = shmem_addr_v;

                                    byte_en_debug[i] = byte_enb_128_v[i];
                                    data_debug[(i * 8)+:8] = rx_st_data_128[(i * 8)+:8];

                                    if (((byte_enb_128_v[i]) == 1'b1) & (bcount_v > 0))
                                    begin
                                       shmem_write(shmem_addr_v, rx_st_data_128[(i * 8)+:8], 1);
                                       shmem_addr_v = shmem_addr_v + 1;
                                       bcount_v = bcount_v - 1;
                                       // Byte Enables only valid on first data phase, bcount_v covers
                                       // the last data phase
                                       if ((bcount_v == 0) & (i < 15))        // mask out all bytes after last byte
                                       begin
                                          begin : xhdl_4
                                             integer j;
                                             for(j = i + 1; j <= 15; j = j + 1)
                                             begin
                                                byte_enb_128_v[j] = 1'b0;
                                             end
                                          end // j
                                       end
                                       // Now Handle the case if we are receiving data in this cycle
                                       if (rx_state_v == RXST_DATA_COMPL)
                                       begin
                                          compl_received_v[rx_compl_tag_v] = compl_received_v[rx_compl_tag_v] + 1;
                                       end
                                       if (((rx_be[i]) != 1'b1) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                    else
                                    begin
                                       if (((rx_be[i]) != 1'b0) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                 end
                              end // i
                              // Enable all bytes in subsequent data phases
                              byte_enb_128_v = {16{1'b1}};  // 128 bit mode
                              // Last Packet phase
                              if ((rx_st_eop == 1'b1) && (rx_st_valid==1'b1))
                              begin
                                 if (bcount_v > 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count did not go to zero in last data phase. Remaining Bytes: ",
                                                  dimage4(bcount_v)});
                                 end
                                 if (rx_state_v == RXST_DATA_COMPL)
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    rx_st_ready_v = 1'b1;
                                    // If we have received all of the data (or more)
                                    if (compl_received_v[rx_compl_tag_v] >= compl_expected_v[rx_compl_tag_v])
                                    begin
                                       // Error if more than expected
                                       if (compl_received_v[rx_compl_tag_v] > compl_expected_v[rx_compl_tag_v])
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " Received more completion data than expected. Expected: ",
                                                        dimage4(compl_expected_v[rx_compl_tag_v]),
                                                        " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                       end
                                       // Report that it is complete to the Driver
                                       vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                       // Clear out that we expect anymore
                                       compl_received_v[rx_compl_tag_v] = -1;
                                       compl_expected_v[rx_compl_tag_v] = -1;
                                       rx_compl_tag_v = -1;
                                    end
                                    else
                                    begin
                                       // Have not received all of the data yet, but if the
                                       // completion status is not Successful Completion then we
                                       // need to treat as done
                                       if (rx_compl_sts_v != 3'b000)
                                       begin
                                          // Report that it is complete to the Driver
                                          vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                          // Clear out that we expect anymore
                                          compl_received_v[rx_compl_tag_v] = -1;
                                          compl_expected_v[rx_compl_tag_v] = -1;
                                          rx_compl_tag_v = -1;
                                       end
                                    end
                                    // Otherwise keep going and wait for more data in another completion
                                 end
                                 else
                                 begin
                                    if (rx_state_v == RXST_DATA_NONP_WRITE)
                                    begin
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                    else
                                    begin
                                       rx_state_v = RXST_IDLE;
                                       rx_st_ready_v = 1'b1;
                                    end
                                 end
                              end
                              else
                              begin
                                 if (bcount_v == 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count went to zero before last data phase."});
                                 end
                              end
                           end
                        end
               RXST_NONP_REQ :
                        begin
                           if (tx_rx_ack == 1'b1)
                           begin
                              rx_state_v = RXST_IDLE;
                              rx_tx_req_v = 1'b0;
                              rx_st_ready_v = 1'b1;
                           end
                           else
                           begin
                              rx_tx_req_v = 1'b1;
                              rx_state_v = RXST_NONP_REQ;
                              rx_st_ready_v = 1'b0;
                           end
                        end
               default :
                        begin
                        end
            endcase
         end
         rx_state         <= rx_state_v ;
         rx_tx_req        <= rx_tx_req_v ;
         rx_tx_desc       <= rx_tx_desc_v ;
         rx_tx_shmem_addr <= rx_tx_shmem_addr_v ;
         rx_tx_bcount     <= rx_tx_bcount_v ;
         rx_tx_byte_enb   <= rx_tx_byte_enb_v ;
         rx_desc_int      <= rx_desc_int_v;
         rx_st_ready      <= rx_st_ready_v;
         rx_update_pkt_count <= rx_update_pkt_count_v;
         rx_payld_length     <= rx_payld_length_v;
      end
   end

   always @(clk_in)
     begin : main_tx_state
      reg[32767:0] data_pkt_v;
      integer dphases_v;
      integer dptr_v;
      reg[1:0] tx_state_v;
      reg rx_mask_v;
      reg[127:0] tx_desc_v;
      reg[127:0] tx_desc;
      reg[127:0] tx_st_data_v;
      reg tx_err_v;
      reg tx_rx_ack_v;
      integer lcladdr_v;
      reg req_ack_cleared_v;
      reg[127:0] req_desc_v;
      reg req_valid_v;
      reg[31:0] imm_data_v;
      reg imm_valid_v;
      integer exp_compl_tag_v;
      integer exp_compl_bcount_v;
      reg tx_st_sop_v;
      reg tx_st_eop_v;
      reg tx_st_valid_v;
      reg last_req_was_cfg0;
      reg[4:0] time_from_last_sop;
      reg okay_to_transmit;
      reg [9:0] tx_payld_length_v;
      reg[127:0] data_pkt_v_128;
      reg tx_st_empty_v;
      reg[11:0] tx_update_pkt_count_v;

      if (clk_in == 1'b1)
      begin
         // rising clock edge
         exp_compl_tag_v = -1;
         exp_compl_bcount_v = 0;
         if (rstn == 1'b0)
         begin
            // synchronous reset (active low)
            tx_state_v = TXST_IDLE;
            rx_mask_v = 1'b1;
            tx_desc_v = {128{1'b0}};
            tx_st_data_v = {128{1'b0}};
            tx_err_v = 1'b0;
            tx_rx_ack_v = 1'b0;
            req_ack_cleared_v = 1'b1;
            tx_st_sop_v = 1'b0;
            tx_st_eop_v = 1'b0;
            tx_st_valid_v = 1'b0;
            last_req_was_cfg0 = 1'b0;
            time_from_last_sop = 5'h0;
            okay_to_transmit = 1'b0;
            tx_payld_length_v = 11'h0;
            tx_update_pkt_count_v = 1'b0;
         end
         else
         begin
            // for performance monitor
            tx_update_pkt_count_v = (tx_st_eop == 1'b1) & (tx_st_valid == 1'b1);
            if (tx_desc_v[126]==1'b1) begin
                if (tx_desc_v[105:96]==10'h0)
                    tx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    tx_payld_length_v <= {1'b0, tx_desc_v[105:96]};
            end

            // Clear any previous acknowledgement if needed
            if (req_ack_cleared_v == 1'b0)
            begin
               req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
            end

          //  rx_mask_v = 1'b1; // This is on in most states
            rx_mask_v = 1'b0;
            tx_rx_ack_v = 1'b0;
            tx_st_valid_v = 1'b0;

            // keep track of the number of clk cycles
            // from the time an sop was transmitted.

            if ((tx_st_sop==1'b1) & (tx_st_valid==1'b1))
                time_from_last_sop = 5'h0;
            else if (time_from_last_sop==5'h1F)
                time_from_last_sop = time_from_last_sop;
            else
                time_from_last_sop = time_from_last_sop + 1;

            // after a CFG0 is transmitted, wait some time for
            // the tx_fifo_empty flag to respond.
            okay_to_transmit=((last_req_was_cfg0==1'b0) | ((tx_fifo_empty==1'b1)& (time_from_last_sop > 5'd20)));


            case (tx_state_v)
               TXST_IDLE :
                        begin
                           if (tx_st_ready == 1'b1)
                           begin
                              tx_st_sop_v = 1'b0;
                              tx_st_eop_v = 1'b0;
                              tx_st_empty_v = 1'b0;
                              if  ((rx_tx_req == 1'b1) & (okay_to_transmit==1'b1) )
                              begin
                                 rx_mask_v = 1'b0;
                                 tx_state_v = TXST_DESC;
                                 tx_desc_v = rx_tx_desc;
                                 tx_rx_ack_v = 1'b1;
                                 // Assumes we are getting infinite credits!!!!!
                                 if (rx_tx_bcount > 0)
                                 begin
                                    tx_setup_data(rx_tx_shmem_addr, rx_tx_bcount, rx_tx_byte_enb, data_pkt_v,
                                                  dphases_v, 1'b0, 32'h00000000);
                                    dptr_v = 0;
                                 end
                                 else
                                 begin
                                    dphases_v = 0;
                                 end
                              end
                              else begin
                                 vc_intf_get_req(VC_NUM, req_valid_v, req_desc_v, lcladdr_v, imm_valid_v, imm_data_v);
                                 // wait for enough credits for all requests.
                                 // if the last request was a CFG0, then also wait for the tx_fifo to empty
                                 // before sending the next request.
                                 if ((tx_fc_check(req_desc_v, tx_cred)) & (req_valid_v == 1'b1) & (req_ack_cleared_v == 1'b1) &
                                     (okay_to_transmit==1'b1) )
                                 begin
                                    last_req_was_cfg0 = (req_desc_v[124:120]==5'b00100);
                                    vc_intf_set_ack(VC_NUM);
                                    req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
                                    tx_setup_req(req_desc_v, lcladdr_v, imm_valid_v, imm_data_v, data_pkt_v, dphases_v);
                                    tx_state_v = TXST_DESC;
                                    tx_desc_v = req_desc_v;
                                    if (dphases_v > 0)
                                       dptr_v = 0;

                                    if (is_non_posted(req_desc_v))
                                    begin
                                       exp_compl_tag_v = req_desc_v[79:72];
                                       if (has_data(req_desc_v))
                                       begin
                                          exp_compl_bcount_v = 0;
                                       end
                                       else
                                       begin
                                          exp_compl_bcount_v = calc_byte_count(req_desc_v);
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    tx_state_v = TXST_IDLE;
                                    rx_mask_v = 1'b0;
                                 end
                              end
                           end
                        end
               TXST_DESC: begin
                        if (tx_st_ready == 1'b1) begin
                             tx_st_sop_v = 1'b1;
                             tx_st_valid_v = 1'b1;
                             // Payload with 3DW header, NonQW aligned address,
                             // pack the first cycle of data with the 2nd
                             // descriptor cycle
                             if ((dphases_v > 0) & (is_3dw_nonaligned(tx_desc_v))) begin
                                 tx_st_data_v = {data_pkt_v[63:32], tx_desc_v[63:32], tx_desc_v[95:64], tx_desc_v[127:96]};
                                 if (dphases_v > 1) begin
                                     tx_state_v = TXST_DATA;
                                 end
                                 else begin
                                     tx_state_v = TXST_IDLE;
                                     tx_st_eop_v = 1'b1;
                                 end
                                 dphases_v = dphases_v - 1;
                                 dptr_v    = 0;
                                 data_pkt_v = {64'h0, data_pkt_v[32767:64]};
                             end
                             // Payload with 4DW header, or QW aligned address,
                             // no desc/data packing
                             else if (dphases_v > 0) begin
                                 tx_st_data_v  = {tx_desc_v[31:0], tx_desc_v[63:32], tx_desc_v[95:64], tx_desc_v[127:96]};
                                 tx_state_v = TXST_DATA;
                             end
                             // No payload
                             else begin
                                 tx_st_data_v   = {tx_desc_v[31:0], tx_desc_v[63:32], tx_desc_v[95:64], tx_desc_v[127:96]};
                                 tx_state_v  = TXST_IDLE;
                                 tx_st_eop_v = 1'b1;
                             end
                        end
               end
               TXST_DATA :
                        begin
                           tx_st_sop_v = 1'b0;
                           // Handle the Tx Data Signals
                           if (dphases_v > 0)
                           begin
                              data_pkt_v_128 = data_pkt_v[(dptr_v*128)+:128];
                              tx_st_data_v  = data_pkt_v_128;
                              tx_state_v    = TXST_DATA;
                              tx_st_eop_v   = (dphases_v<3) ? 1'b1 : 1'b0;
                              tx_st_valid_v = (tx_st_ready == 1'b1) ? 1'b1 : 1'b0;
                              tx_st_empty_v = (dphases_v==1) ? 1'b1 : 1'b0;
                           end
                           else
                           begin
                              tx_st_data_v  = {128{1'b0}};
                              tx_state_v = TXST_IDLE;
                              tx_st_eop_v = 1'b0;
                              tx_st_valid_v = 1'b0;
                              tx_st_empty_v = 1'b0;
                           end

                           if (tx_st_ready == 1'b1) begin
                               dphases_v     = (dphases_v<2) ? 0 : dphases_v - 2;
                               dptr_v        = dptr_v + 1;
                           end


                       end
               default :
                        begin
                        end
            endcase
         end
         tx_state <= tx_state_v ;
         rx_mask <= rx_mask_v ;
         tx_desc <= tx_desc_v ;
         tx_err <= tx_err_v ;
         tx_rx_ack <= tx_rx_ack_v ;
         exp_compl_tag <= exp_compl_tag_v ;
         exp_compl_bcount <= exp_compl_bcount_v ;
         tx_st_eop <= tx_st_eop_v;
         tx_st_sop <= tx_st_sop_v;
         tx_st_empty <= tx_st_empty_v;
         tx_st_valid <= tx_st_valid_v;
         tx_st_data <= tx_st_data_v;
         tx_payld_length <= tx_payld_length_v;
         tx_update_pkt_count <= tx_update_pkt_count_v;
      end
   end

endmodule



`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Root Port Avalon-ST64 VC Interface
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_vc_intf_64.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This entity interfaces between the root port transaction list processor
// and the root port module single VC interface. It handles the following basic
// functions:
// * Formating Tx Descriptors
// * Retrieving Tx Data as needed from the shared memory
// * Decoding Rx Descriptors
// * Storing Rx Data as needed to the shared memory
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_bfm_vc_intf_64 (clk_in, rstn, rx_mask,  rx_be,  rx_st_sop, rx_st_eop, rx_st_empty, rx_st_data, rx_st_valid, rx_st_ready, rx_ecrc_err,
                                 tx_cred,  tx_err,
                                 tx_st_ready, tx_st_sop, tx_st_eop, tx_st_empty, tx_st_valid, tx_st_data, tx_fifo_empty, cfg_io_bas, cfg_np_bas, cfg_pr_bas);

   parameter VC_NUM  = 0;
   parameter DISABLE_RX_BE_CHECK  = 1;
   `include "altpcietb_g3bfm_constants.v"
   `include "altpcietb_g3bfm_log.v"
   `include "altpcietb_g3bfm_shmem.v"
   `include "altpcietb_g3bfm_req_intf.v"

   input clk_in;
   input rstn;
   output rx_mask;
   reg rx_mask;
   input[7:0] rx_be;
   input[35:0] tx_cred;
   output tx_err;
   reg tx_err;
   input[19:0] cfg_io_bas;
   input[11:0] cfg_np_bas;
   input[43:0] cfg_pr_bas;
   input rx_st_sop;
   input rx_st_valid;
   output rx_st_ready;
   reg rx_st_ready;
   input rx_st_eop;
   input rx_st_empty;
   input[63:0] rx_st_data;
   input rx_ecrc_err;
   input tx_st_ready;
   output tx_st_sop;
   reg tx_st_sop;
   output tx_st_eop;
   reg tx_st_eop;
   output tx_st_empty;
   reg tx_st_empty;
   output tx_st_valid;
   reg tx_st_valid;
   output[63:0] tx_st_data;
   reg[63:0] tx_st_data;
   input tx_fifo_empty;

   parameter[2:0] RXST_IDLE = 0;
   parameter[2:0] RXST_DESC_ACK = 1;
   parameter[2:0] RXST_DATA_WRITE = 2;
   parameter[2:0] RXST_DATA_NONP_WRITE = 3;
   parameter[2:0] RXST_DATA_COMPL = 4;
   parameter[2:0] RXST_NONP_REQ = 5;
   parameter[1:0] TXST_IDLE = 0;
   parameter[1:0] TXST_DESC = 1;
   parameter[1:0] TXST_DATA = 2;
   reg[2:0] rx_state;
   reg[1:0] tx_state;
   // Communication signals between main Tx State Machine and main Rx State Machine
   // to indicate when completions are expected
   integer exp_compl_tag;
   integer exp_compl_bcount;
   // Communication signals between Rx State Machine and Tx State Machine
   // for requesting completions
   reg rx_tx_req;
   reg[127:0] rx_tx_desc;
   integer rx_tx_shmem_addr;
   integer rx_tx_bcount;
   reg[7:0] rx_tx_byte_enb;
   reg tx_rx_ack;

   // Communication Signals for PErf Monitoring
   reg[10:0] tx_payld_length;
   reg[10:0] rx_payld_length;
   reg       rx_update_pkt_count;
   reg       tx_update_pkt_count;

   // support for streaming interface
   reg[135:0] rx_desc_int;
   wire[135:0] rx_desc_int_v;
   reg         rx_st_sop_last;
   wire[63:0] rx_st_data_64;



   ///////////////////////////////////////////////////
   // Common functions and tasks used in this module

   `include "altpcietb_g3bfm_vc_intf_ast_common.v"


   ///////////////////////////////////////////////////
   // RX and TX processing

   assign rx_st_data_64 = rx_st_data;
   assign rx_desc_int_v[127:64] = ((rx_st_sop==1'b1) & (rx_st_valid==1'b1)) ?  {rx_st_data_64[31:0], rx_st_data_64[63:32]} : rx_desc_int[127:64];
   assign rx_desc_int_v[63:0]   = ((rx_st_sop_last==1'b1) & (rx_st_valid==1'b1)) ?  {rx_st_data_64[31:0], rx_st_data_64[63:32]} : rx_desc_int[63:0];

   // behavioral
   always @(clk_in)
   begin : main_rx_state
      integer compl_received_v[0:EBFM_NUM_TAG - 1];
      integer compl_expected_v[0:EBFM_NUM_TAG - 1];
      reg[2:0] rx_state_v;
      reg rx_st_ready_v;// pops data from RX FIFO (lookahead)
      integer shmem_addr_v;
      integer rx_compl_tag_v;
      reg[SHMEM_ADDR_WIDTH - 1:0] rx_compl_baddr_v;
      reg[2:0] rx_compl_sts_v;
      reg[7:0] byte_enb_v;
      integer bcount_v;
      reg rx_tx_req_v;
      reg[127:0] rx_tx_desc_v;
      integer rx_tx_shmem_addr_v;
      integer rx_tx_bcount_v;
      reg[7:0] rx_tx_byte_enb_v;
      reg[10:0]   rx_payld_length_v;
      reg         rx_update_pkt_count_v;
      reg      dummy ;
      reg     rx_ecrc_err_reg;
      integer  shmem_addr0_debug;
      reg[7:0] byte_en_debug;
      reg[63:0] data_debug;

      integer      i ;
      if (clk_in == 1'b1)
      begin
         if (rstn != 1'b1)
         begin
            rx_state_v = RXST_IDLE;
            rx_compl_tag_v = -1;
            rx_compl_sts_v = {3{1'b1}};
            rx_tx_req_v = 1'b0;
            rx_tx_desc_v = {128{1'b0}};
            rx_tx_shmem_addr_v = 0;
            rx_tx_bcount_v = 0;
            rx_tx_bcount_v = 0;
            rx_payld_length_v = 11'h0;
            rx_ecrc_err_reg = 1'b0;
            for (i = 0 ; i < EBFM_NUM_TAG ; i = i + 1)
              begin
                 compl_expected_v[i] = -1;
                 compl_received_v[i] = -1;
              end
         end
         else
         begin
            // See if the Transmit side is transmitting a Non-Posted Request
            // that we need to expect a completion for and if so record it
            if (exp_compl_tag > -1)
            begin
               compl_expected_v[exp_compl_tag] = exp_compl_bcount;
               compl_received_v[exp_compl_tag] = 0;
            end
            rx_state_v = rx_state;
            rx_tx_req_v = 1'b0;

            // for performance monitor
            rx_update_pkt_count_v = (rx_st_eop == 1'b1) & (rx_st_valid == 1'b1);
            if (rx_desc_int_v[126]==1'b1) begin
                if (rx_desc_int_v[105:96]==10'h0)
                    rx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    rx_payld_length_v <= {1'b0, rx_desc_int_v[105:96]};
            end
            rx_ecrc_err_reg <= rx_ecrc_err;
            if ((rx_ecrc_err_reg == 0) & (rx_ecrc_err==1)) begin
               dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         {"Root Port VC", dimage1(VC_NUM),
                          " Detected ECRC Error  " });
            end

            case (rx_state)
               RXST_IDLE :
                        begin
                           rx_st_ready_v = 1'b1;
                           // Note rx_mask will be controlled by tx_process
                           // process main_rx_state
                           if ((rx_st_sop == 1'b1) && (rx_st_valid==1'b1))
                           begin
                              rx_st_ready_v = 1'b1;
                              rx_state_v = RXST_DESC_ACK;
                           end
                           else
                           begin
                              rx_state_v = RXST_IDLE;
                           end
                        end
               RXST_DESC_ACK, RXST_DATA_COMPL, RXST_DATA_WRITE, RXST_DATA_NONP_WRITE :
                        begin
                           if (rx_state == RXST_DESC_ACK)
                           begin
                              if (is_request(rx_desc_int_v))
                              begin
                                 // All of these states are handled together since they can all
                                 // involve data transfer and we need to share that code.
                                 //
                                 // If this is the cycle where the descriptor is being ack'ed we
                                 // need to complete the descriptor decode first so that we can
                                 // be prepared for the Data Transfer that might happen in the same
                                 // cycle.
                                 if (is_non_posted(rx_desc_int_v))
                                 begin
                                    // Non-Posted Request
                                    rx_nonp_req_setup_compl(rx_desc_int_v, rx_tx_desc_v, rx_tx_shmem_addr_v, rx_tx_byte_enb_v, rx_tx_bcount_v);
                                    // Request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Non-Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_state_v = RXST_DATA_NONP_WRITE;
                                       rx_st_ready_v = 1'b1;
                                    end
                                    else
                                    begin
                                       // Non-Posted Read Request
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                 end
                                 else
                                 begin
                                    // Posted Request
                                    rx_tx_desc_v = {128{1'b0}};
                                    rx_tx_shmem_addr_v = 0;
                                    rx_tx_byte_enb_v = {8{1'b0}};
                                    rx_tx_bcount_v = 0;
                                    // Begin Lengthy decode and checking of the Rx Descriptor
                                    // First Determine if it is a completion or a request
                                    if (has_data(rx_desc_int_v))
                                    begin
                                       // Posted Write Request
                                       rx_write_req_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v);
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_DATA_WRITE;
                                    end
                                    else
                                    begin
                                       // Posted Message without Data
                                       // Not currently supported.
                                       rx_st_ready_v = 1'b1;
                                       rx_state_v = RXST_IDLE;
                                    end
                                 end
                              end
                              else // is_request == 0
                              begin
                                 // Completion
                                 rx_compl_setup(rx_desc_int_v, shmem_addr_v, byte_enb_v, bcount_v,
                                                rx_compl_tag_v, rx_compl_sts_v);
                                 if (compl_expected_v[rx_compl_tag_v] < 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Recevied unexpected completion TLP, Fmt/Type: ",
                                                  himage2(rx_desc_int[127:120]),
                                                  " Tag: ", himage2(rx_desc_int[47:40])});
                                 end
                                 if (has_data(rx_desc_int_v))
                                 begin
                                    rx_st_ready_v = 1'b1;
                                    rx_state_v = RXST_DATA_COMPL;
                                    // Increment for already received data phases
                                    shmem_addr_v = shmem_addr_v + compl_received_v[rx_compl_tag_v];
                                 end
                                 else
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    rx_st_ready_v = 1'b1;
                                    if ((compl_received_v[rx_compl_tag_v] < compl_expected_v[rx_compl_tag_v]) &
                                        (rx_compl_sts_v == 3'b000))
                                    begin
                                       dummy = ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                                                    {"Root Port VC", dimage1(VC_NUM),
                                                     " Did not receive all expected completion data. Expected: ",
                                                     dimage4(compl_expected_v[rx_compl_tag_v]),
                                                     " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                    end
                                    // Report that it is complete to the Driver
                                    vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                    // Clear out that we expect anymore
                                    compl_received_v[rx_compl_tag_v] = -1;
                                    compl_expected_v[rx_compl_tag_v] = -1;
                                    rx_compl_tag_v = -1;
                                 end
                              end
                           end
                           // Collect Payload when
                           //    - in any state after the Descriptor phase or
                           //    - during descriptor phase, but only if it is a 3DW Header, Non-QWord aligned packet
                           if ((rx_st_valid == 1'b1) && (rx_desc_int_v[126]==1'b1) && ((rx_state!=RXST_DESC_ACK) || is_3dw_nonaligned(rx_desc_int_v) ) )
                           begin
                              begin : xhdl_3
                                 integer i;
                                 for(i = 0; i <= 7; i = i + 1)
                                 begin
                                    if (i==0) shmem_addr0_debug = shmem_addr_v;
                                    byte_en_debug[i] = byte_enb_v[i];
                                    data_debug[(i * 8)+:8] = rx_st_data_64[(i * 8)+:8];

                                    if (((byte_enb_v[i]) == 1'b1) & (bcount_v > 0))
                                    begin
                                       shmem_write(shmem_addr_v, rx_st_data_64[(i * 8)+:8], 1);
                                       shmem_addr_v = shmem_addr_v + 1;
                                       bcount_v = bcount_v - 1;
                                       // Byte Enables only valid on first data phase, bcount_v covers
                                       // the last data phase
                                       if ((bcount_v == 0) & (i < 7))
                                       begin
                                          begin : xhdl_4
                                             integer j;
                                             for(j = i + 1; j <= 7; j = j + 1)
                                             begin
                                                byte_enb_v[j] = 1'b0;
                                             end
                                          end // j
                                       end
                                       // Now Handle the case if we are receiving data in this cycle
                                       if (rx_state_v == RXST_DATA_COMPL)
                                       begin
                                          compl_received_v[rx_compl_tag_v] = compl_received_v[rx_compl_tag_v] + 1;
                                       end
                                       if (((rx_be[i]) != 1'b1) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                    else
                                    begin
                                       if (((rx_be[i]) != 1'b0) & (DISABLE_RX_BE_CHECK == 0))
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " rx_be field: ", himage2(rx_be),
                                                        " Mismatch. Expected: ", himage2(byte_enb_v)});
                                       end
                                    end
                                 end
                              end // i
                              // Enable all bytes in subsequent data phases
                              byte_enb_v = {8{1'b1}};
                              // Last Packet phase
                              if ((rx_st_eop == 1'b1) && (rx_st_valid==1'b1))
                              begin
                                 if (bcount_v > 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count did not go to zero in last data phase. Remaining Bytes: ",
                                                  dimage4(bcount_v)});
                                 end
                                 if (rx_state_v == RXST_DATA_COMPL)
                                 begin
                                    rx_state_v = RXST_IDLE;
                                    rx_st_ready_v = 1'b1;
                                    // If we have received all of the data (or more)
                                    if (compl_received_v[rx_compl_tag_v] >= compl_expected_v[rx_compl_tag_v])
                                    begin
                                       // Error if more than expected
                                       if (compl_received_v[rx_compl_tag_v] > compl_expected_v[rx_compl_tag_v])
                                       begin
                                          dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                       {"Root Port VC", dimage1(VC_NUM),
                                                        " Received more completion data than expected. Expected: ",
                                                        dimage4(compl_expected_v[rx_compl_tag_v]),
                                                        " Received: ", dimage4(compl_received_v[rx_compl_tag_v])});
                                       end
                                       // Report that it is complete to the Driver
                                       vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                       // Clear out that we expect anymore
                                       compl_received_v[rx_compl_tag_v] = -1;
                                       compl_expected_v[rx_compl_tag_v] = -1;
                                       rx_compl_tag_v = -1;
                                    end
                                    else
                                    begin
                                       // Have not received all of the data yet, but if the
                                       // completion status is not Successful Completion then we
                                       // need to treat as done
                                       if (rx_compl_sts_v != 3'b000)
                                       begin
                                          // Report that it is complete to the Driver
                                          vc_intf_rpt_compl(rx_compl_tag_v, rx_compl_sts_v);
                                          // Clear out that we expect anymore
                                          compl_received_v[rx_compl_tag_v] = -1;
                                          compl_expected_v[rx_compl_tag_v] = -1;
                                          rx_compl_tag_v = -1;
                                       end
                                    end
                                    // Otherwise keep going and wait for more data in another completion
                                 end
                                 else
                                 begin
                                    if (rx_state_v == RXST_DATA_NONP_WRITE)
                                    begin
                                       rx_st_ready_v = 1'b0;
                                       rx_state_v = RXST_NONP_REQ;
                                    end
                                    else
                                    begin
                                       rx_state_v = RXST_IDLE;
                                       rx_st_ready_v = 1'b1;
                                    end
                                 end
                              end
                              else
                              begin
                                 if (bcount_v == 0)
                                 begin
                                    dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                                                 {"Root Port VC", dimage1(VC_NUM),
                                                  " Rx Byte Count went to zero before last data phase."});
                                 end
                              end
                           end
                        end
               RXST_NONP_REQ :
                        begin
                           if (tx_rx_ack == 1'b1)
                           begin
                              rx_state_v = RXST_IDLE;
                              rx_tx_req_v = 1'b0;
                              rx_st_ready_v = 1'b1;
                           end
                           else
                           begin
                              rx_tx_req_v = 1'b1;
                              rx_state_v = RXST_NONP_REQ;
                              rx_st_ready_v = 1'b0;
                           end
                        end
               default :
                        begin
                        end
            endcase
         end
         rx_state         <= rx_state_v ;
         rx_tx_req        <= rx_tx_req_v ;
         rx_tx_desc       <= rx_tx_desc_v ;
         rx_tx_shmem_addr <= rx_tx_shmem_addr_v ;
         rx_tx_bcount     <= rx_tx_bcount_v ;
         rx_tx_byte_enb   <= rx_tx_byte_enb_v ;
         rx_desc_int      <= rx_desc_int_v;
         rx_st_ready      <= rx_st_ready_v;
         rx_payld_length  <= rx_payld_length_v;
         rx_st_sop_last   <= rx_st_sop;
         rx_update_pkt_count <= rx_update_pkt_count_v;
         rx_payld_length     <= rx_payld_length_v;
      end
   end

   always @(clk_in)
     begin : main_tx_state
      reg[32767:0] data_pkt_v;
      integer dphases_v;
      integer dptr_v;
      reg[1:0] tx_state_v;
      reg rx_mask_v;
      reg[127:0] tx_desc_v;
      reg[127:0] tx_desc;
      reg[63:0] tx_st_data_v;
      reg tx_err_v;
      reg tx_rx_ack_v;
      integer lcladdr_v;
      reg req_ack_cleared_v;
      reg[127:0] req_desc_v;
      reg req_valid_v;
      reg[31:0] imm_data_v;
      reg imm_valid_v;
      integer exp_compl_tag_v;
      integer exp_compl_bcount_v;
      reg tx_st_sop_v;
      reg tx_st_eop_v;
      reg tx_st_valid_v;
      reg last_req_was_cfg0;
      reg[4:0] time_from_last_sop;
      reg okay_to_transmit;
      reg [9:0] tx_payld_length_v;
      reg[11:0] tx_update_pkt_count_v;

      if (clk_in == 1'b1)
      begin
         // rising clock edge
         exp_compl_tag_v = -1;
         exp_compl_bcount_v = 0;
         if (rstn == 1'b0)
         begin
            // synchronous reset (active low)
            tx_state_v = TXST_IDLE;
            rx_mask_v = 1'b1;
            tx_desc_v = {128{1'b0}};
            tx_st_data_v = {64{1'b0}};
            tx_err_v = 1'b0;
            tx_rx_ack_v = 1'b0;
            req_ack_cleared_v = 1'b1;
            tx_st_sop_v = 1'b0;
            tx_st_eop_v = 1'b0;
            tx_st_valid_v = 1'b0;
            last_req_was_cfg0 = 1'b0;
            time_from_last_sop = 5'h0;
            okay_to_transmit = 1'b0;
            tx_payld_length_v = 11'h0;
            tx_update_pkt_count_v = 1'b0;
         end
         else
         begin
            // for performance monitor
            tx_update_pkt_count_v = (tx_st_eop == 1'b1) & (tx_st_valid == 1'b1);
            if (tx_desc_v[126]==1'b1) begin
                if (tx_desc_v[105:96]==10'h0)
                    tx_payld_length_v <= 11'h400;   // 1024 DWs
                else
                    tx_payld_length_v <= {1'b0, tx_desc_v[105:96]};
            end

            // Clear any previous acknowledgement if needed
            if (req_ack_cleared_v == 1'b0)
            begin
               req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
            end

            rx_mask_v = 1'b1; // This is on in most states
            tx_rx_ack_v = 1'b0;
            tx_st_valid_v = 1'b0;

            // keep track of the number of clk cycles
            // from the time an sop was transmitted.

            if ((tx_st_sop==1'b1) & (tx_st_valid==1'b1))
                time_from_last_sop = 5'h0;
            else if (time_from_last_sop==5'h1F)
                time_from_last_sop = time_from_last_sop;
            else
                time_from_last_sop = time_from_last_sop + 1;

            // after a CFG0 is transmitted, wait some time for
            // the tx_fifo_empty flag to respond.
            okay_to_transmit=((last_req_was_cfg0==1'b0) | ((tx_fifo_empty==1'b1)& (time_from_last_sop > 5'd20)));

            case (tx_state_v)
               TXST_IDLE :
                        begin
                           if (tx_st_ready == 1'b1)
                           begin
                              tx_st_eop_v = 1'b0;
                              if  ((rx_tx_req == 1'b1) & (okay_to_transmit==1'b1) )
                              begin
                                 rx_mask_v = 1'b0;
                                 tx_state_v = TXST_DESC;
                                 tx_desc_v = rx_tx_desc;
                                 tx_st_sop_v   = 1'b1;
                                 tx_st_valid_v = 1'b1;
                                 tx_rx_ack_v = 1'b1;
                                 // Assumes we are getting infinite credits!!!!!
                                 if (rx_tx_bcount > 0)
                                 begin
                                    tx_setup_data(rx_tx_shmem_addr, rx_tx_bcount, rx_tx_byte_enb, data_pkt_v,
                                                  dphases_v, 1'b0, 32'h00000000);
                                    dptr_v = 0;
                                    tx_st_data_v = {rx_tx_desc[95:64], rx_tx_desc[127:96]};
                                 end
                                 else
                                 begin
                                    dphases_v = 0;
                                 end
                              end
                              else begin
                                 vc_intf_get_req(VC_NUM, req_valid_v, req_desc_v, lcladdr_v, imm_valid_v, imm_data_v);
                                 // wait for enough credits for all requests.
                                 // if the last request was a CFG0, then also wait for the tx_fifo to empty
                                 // before sending the next request.
                                 if ((tx_fc_check(req_desc_v, tx_cred)) & (req_valid_v == 1'b1) & (req_ack_cleared_v == 1'b1) &
                                     (okay_to_transmit==1'b1) )
                                 begin
                                    last_req_was_cfg0 = (req_desc_v[124:120]==5'b00100);
                                    vc_intf_set_ack(VC_NUM);
                                    req_ack_cleared_v = vc_intf_clr_ack(VC_NUM);
                                    tx_setup_req(req_desc_v, lcladdr_v, imm_valid_v, imm_data_v, data_pkt_v, dphases_v);
                                    tx_state_v = TXST_DESC;
                                    tx_desc_v = req_desc_v;
                                    tx_st_data_v = {req_desc_v[95:64], req_desc_v[127:96]};
                                    tx_st_sop_v = 1'b1;
                                    tx_st_valid_v = 1'b1;
                                    if (dphases_v > 0)
                                       dptr_v = 0;

                                    if (is_non_posted(req_desc_v))
                                    begin
                                       exp_compl_tag_v = req_desc_v[79:72];
                                       if (has_data(req_desc_v))
                                       begin
                                          exp_compl_bcount_v = 0;
                                       end
                                       else
                                       begin
                                          exp_compl_bcount_v = calc_byte_count(req_desc_v);
                                       end
                                    end
                                 end
                                 else
                                 begin
                                    tx_state_v = TXST_IDLE;
                                    rx_mask_v = 1'b0;
                                 end
                              end
                           end
                        end
               TXST_DESC: begin
                        if (tx_st_ready == 1'b1) begin
                             tx_st_sop_v = 1'b0;
                             tx_st_valid_v = 1'b1;
                             // Payload with 3DW header, NonQW aligned address,
                             // pack the first cycle of data with the 2nd
                             // descriptor cycle
                             if ((dphases_v > 0) & (is_3dw_nonaligned(tx_desc_v))) begin
                                 tx_st_data_v = {data_pkt_v[63:32], tx_desc_v[63:32]};
                                 if (dphases_v > 1) begin
                                     tx_state_v = TXST_DATA;
                                 end
                                 else begin
                                     tx_state_v = TXST_IDLE;
                                     tx_st_eop_v = 1'b1;
                                 end
                                 dphases_v = dphases_v - 1;
                                 dptr_v    = dptr_v + 1;
                             end
                             // Payload with 4DW header, or QW aligned address,
                             // no desc/data packing
                             else if (dphases_v > 0) begin
                                 tx_st_data_v  = {tx_desc[31:0], tx_desc[63:32]};
                                 tx_state_v = TXST_DATA;
                             end
                             // No payload
                             else begin
                                 tx_st_data_v   = {tx_desc[31:0], tx_desc[63:32]};
                                 tx_state_v  = TXST_IDLE;
                                 tx_st_eop_v = 1'b1;
                             end
                        end
               end
               TXST_DATA :
                        begin

                           // Handle the Tx Data Signals
                           if (dphases_v > 0)
                           begin
                              tx_st_data_v   = data_pkt_v[(dptr_v*64)+:64];
                              tx_state_v  = TXST_DATA;
                              tx_st_eop_v = (dphases_v==1) ? 1'b1 : 1'b0;
                              tx_st_valid_v = (tx_st_ready == 1'b1) ? 1'b1 : 1'b0;
                           end
                           else
                           begin
                              tx_st_data_v  = {64{1'b0}};
                              tx_state_v = TXST_IDLE;
                              tx_st_eop_v = 1'b0;
                              tx_st_valid_v = 1'b0;
                           end

                           if (tx_st_ready == 1'b1) begin
                               dphases_v = dphases_v - 1;
                               dptr_v = dptr_v + 1;
                           end


                       end
               default :
                        begin
                        end
            endcase
         end
         tx_state <= tx_state_v ;
         rx_mask <= rx_mask_v ;
         tx_desc <= tx_desc_v ;
         tx_err <= tx_err_v ;
         tx_rx_ack <= tx_rx_ack_v ;
         exp_compl_tag <= exp_compl_tag_v ;
         exp_compl_bcount <= exp_compl_bcount_v ;
         tx_st_eop <= tx_st_eop_v;
         tx_st_sop <= tx_st_sop_v;
         tx_st_valid <= tx_st_valid_v;
         tx_st_data <= tx_st_data_v;
         tx_st_empty <= 1'b0;
         tx_payld_length <= tx_payld_length_v;
         tx_update_pkt_count <= tx_update_pkt_count_v;
      end
   end

endmodule


`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Message Logging Common Variable File
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_log_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module is not intended to be instantiated by rather referenced by an
// absolute path from the altpcietb_bfm_log.v include file. This allows all
// users of altpcietb_bfm_log.v to see a common set of values.
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------

module altpcietb_bfm_log_common(dummy_out) ;
output dummy_out;

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

   // purpose: sets the suppressed_msg_mask
   task ebfm_log_set_suppressed_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_suppressed_msg_mask
         bfm_log_common.suppressed_msg_mask = msg_mask;
      end
   endtask

   // purpose: sets the stop_on_msg_mask
   task ebfm_log_set_stop_on_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_stop_on_msg_mask
         bfm_log_common.stop_on_msg_mask = msg_mask;
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_open;
      input [200*8:1] fn; // Log File Name

      begin
         bfm_log_common.log_file = $fopen(fn);
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_close;

      begin
         // ebfm_log_close
         $fclose(bfm_log_common.log_file);
         bfm_log_common.log_file = 0;
      end
   endtask

   // purpose: stops the simulation, with flag to indicate success or not
   function ebfm_log_stop_sim;
      input success;
      integer success;

      begin
         if (success == 1)
         begin
            $display("SUCCESS: Simulation stopped due to successful completion!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         else
         begin
            $display("FAILURE: Simulation stopped due to error!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         ebfm_log_stop_sim = 1'b0 ;
      end
   endfunction

   // purpose: This displays a message of the specified type
   function ebfm_display;
      input msg_type;
      integer msg_type;
      input [EBFM_MSG_MAX_LEN*8:1] message;

      reg [9*8:1]  prefix ;
      reg [80*8:1] amsg;
      reg sup;
      reg stp;
      reg dummy ;
      integer i ;
      time ctime ;
      integer itime ;

      begin
         for (i = 0 ; i < EBFM_MSG_MAX_LEN ; i = i + 1)
           begin : msg_shift
              if (message[(EBFM_MSG_MAX_LEN*8)-:8] != 8'h00)
                begin
                   disable msg_shift ;
                end
              message = message << 8 ;
           end
         if (msg_type > EBFM_MSG_ERROR_CONTINUE)
           begin
              sup = 1'b0;
              stp = 1'b1;
              case (msg_type)
                EBFM_MSG_ERROR_FATAL :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to Fatal error!" ;
                     prefix = "FATAL:   ";
                  end
                EBFM_MSG_ERROR_FATAL_TB_ERR :
                  begin
                     amsg   = "FAILURE: Simulation stopped due error in Testbench/BFM design!";
                     prefix = "FATAL:   ";
                  end
                default :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to unknown message type!";
                     prefix = "FATAL:   ";
                  end
              endcase
           end
         else
           begin
              sup = bfm_log_common.suppressed_msg_mask[msg_type];
              stp = bfm_log_common.stop_on_msg_mask[msg_type];
              if (stp == 1'b1)
                begin
                   amsg   = "FAILURE: Simulation stopped due to enabled error!";
                end
              if (msg_type < EBFM_MSG_INFO)
                begin
                     prefix = "DEBUG:   ";
                end
              else
                begin
                   if (msg_type < EBFM_MSG_WARNING)
                     begin
                        prefix = "INFO:    ";
                     end
                   else
                     begin
                        if (msg_type > EBFM_MSG_WARNING)
                          begin
                             prefix = "ERROR:   ";
                          end
                        else
                          begin
                             prefix = "WARNING: ";
                          end
                     end
                end
           end // else: !if(msg_type > EBFM_MSG_ERROR_CONTINUE)
         itime = ($time/1000) ;
         // Display the message if not suppressed
         if (sup != 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file,"%s %d %s %s",prefix,itime,"ns",message);
                end
              $display("%s %d %s %s",prefix,itime,"ns",message);
           end
         // Stop if requested
         if (stp == 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file, "%s", amsg);
                end
              $display("%s",amsg);
              dummy = ebfm_log_stop_sim(0);
           end
         // Dummy function return so we can call from other functions
         ebfm_display = 1'b0 ;
      end
   endfunction

   // purpose: produce 1-digit hexadecimal string from a vector
   function [8:1] himage1;
      input [3:0] vec;

      begin
         case (vec)
           4'h0 : himage1 = "0" ;
           4'h1 : himage1 = "1" ;
           4'h2 : himage1 = "2" ;
           4'h3 : himage1 = "3" ;
           4'h4 : himage1 = "4" ;
           4'h5 : himage1 = "5" ;
           4'h6 : himage1 = "6" ;
           4'h7 : himage1 = "7" ;
           4'h8 : himage1 = "8" ;
           4'h9 : himage1 = "9" ;
           4'hA : himage1 = "A" ;
           4'hB : himage1 = "B" ;
           4'hC : himage1 = "C" ;
           4'hD : himage1 = "D" ;
           4'hE : himage1 = "E" ;
           4'hF : himage1 = "F" ;
           4'bzzzz : himage1 = "Z" ;
           default : himage1 = "X" ;
         endcase
      end
   endfunction // himage1

   // purpose: produce 2-digit hexadecimal string from a vector
   function [16:1] himage2 ;
      input [7:0] vec;
      begin
         himage2 = {himage1(vec[7:4]),himage1(vec[3:0])} ;
      end
   endfunction // himage2

   // purpose: produce 4-digit hexadecimal string from a vector
   function [32:1] himage4 ;
      input [15:0] vec;
      begin
         himage4 = {himage2(vec[15:8]),himage2(vec[7:0])} ;
      end
   endfunction // himage4

   // purpose: produce 8-digit hexadecimal string from a vector
   function [64:1] himage8 ;
      input [31:0] vec;
      begin
         himage8 = {himage4(vec[31:16]),himage4(vec[15:0])} ;
      end
   endfunction // himage8

   // purpose: produce 16-digit hexadecimal string from a vector
   function [128:1] himage16 ;
      input [63:0] vec;
      begin
         himage16 = {himage8(vec[63:32]),himage8(vec[31:0])} ;
      end
   endfunction // himage16

   // purpose: produce 1-digit decimal string from an integer
   function [8:1] dimage1 ;
      input [31:0] num ;
      begin
         case (num)
           0 : dimage1 = "0" ;
           1 : dimage1 = "1" ;
           2 : dimage1 = "2" ;
           3 : dimage1 = "3" ;
           4 : dimage1 = "4" ;
           5 : dimage1 = "5" ;
           6 : dimage1 = "6" ;
           7 : dimage1 = "7" ;
           8 : dimage1 = "8" ;
           9 : dimage1 = "9" ;
           default : dimage1 = "U" ;
         endcase // case(num)
      end
   endfunction // dimage1

   // purpose: produce 2-digit decimal string from an integer
   function [16:1] dimage2 ;
      input [31:0] num ;
      begin
         dimage2 = {dimage1(num/10),dimage1(num % 10)} ;
      end
   endfunction // dimage2

   // purpose: produce 3-digit decimal string from an integer
   function [24:1] dimage3 ;
      input [31:0] num ;
      begin
         dimage3 = {dimage1(num/100),dimage2(num % 100)} ;
      end
   endfunction // dimage3

   // purpose: produce 4-digit decimal string from an integer
   function [32:1] dimage4 ;
      input [31:0] num ;
      begin
         dimage4 = {dimage1(num/1000),dimage3(num % 1000)} ;
      end
   endfunction // dimage4

   // purpose: produce 5-digit decimal string from an integer
   function [40:1] dimage5 ;
      input [31:0] num ;
      begin
         dimage5 = {dimage1(num/10000),dimage4(num % 10000)} ;
      end
   endfunction // dimage5

   // purpose: produce 6-digit decimal string from an integer
   function [48:1] dimage6 ;
      input [31:0] num ;
      begin
         dimage6 = {dimage1(num/100000),dimage5(num % 100000)} ;
      end
   endfunction // dimage6

   // purpose: produce 7-digit decimal string from an integer
   function [56:1] dimage7 ;
      input [31:0] num ;
      begin
         dimage7 = {dimage1(num/1000000),dimage6(num % 1000000)} ;
      end
   endfunction // dimage7

  // purpose: select the correct dimage call for ascii conversion
  function  [800:1] image ;
     input  [800:1] msg ;
     input  [32:1]  num ;
     begin
        if (num <= 10)
        begin
           image = {msg, dimage1(num)};
        end
        else if (num <= 100)
        begin
           image = {msg, dimage2(num)};
        end
        else if (num <= 1000)
        begin
           image = {msg, dimage3(num)};
        end
        else if (num <= 10000)
        begin
           image = {msg, dimage4(num)};
        end
        else if (num <= 100000)
        begin
           image = {msg, dimage5(num)};
        end
        else if (num <= 1000000)
        begin
           image = {msg, dimage6(num)};
        end
        else image = {msg, dimage7(num)};
     end
   endfunction


   integer log_file ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] suppressed_msg_mask ;

   reg [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] stop_on_msg_mask ;

   initial
     begin
        suppressed_msg_mask = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
        suppressed_msg_mask[EBFM_MSG_DEBUG] = 1'b1 ;
        stop_on_msg_mask    = {EBFM_MSG_ERROR_CONTINUE-EBFM_MSG_DEBUG+1{1'b0}} ;
     end
endmodule // altpcietb_bfm_log_common


`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Request Interface Common Variables
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_req_intf_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module provides the common variables for passing the requests between the
// Read/Write Request package and ultimately the user's driver and the VC
// Interface Entitites
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------

module altpcietb_bfm_req_intf_common(dummy_out) ;

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

   // purpose: sets the suppressed_msg_mask
   task ebfm_log_set_suppressed_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_suppressed_msg_mask
         bfm_log_common.suppressed_msg_mask = msg_mask;
      end
   endtask

   // purpose: sets the stop_on_msg_mask
   task ebfm_log_set_stop_on_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_stop_on_msg_mask
         bfm_log_common.stop_on_msg_mask = msg_mask;
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_open;
      input [200*8:1] fn; // Log File Name

      begin
         bfm_log_common.log_file = $fopen(fn);
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_close;

      begin
         // ebfm_log_close
         $fclose(bfm_log_common.log_file);
         bfm_log_common.log_file = 0;
      end
   endtask

   // purpose: stops the simulation, with flag to indicate success or not
   function ebfm_log_stop_sim;
      input success;
      integer success;

      begin
         if (success == 1)
         begin
            $display("SUCCESS: Simulation stopped due to successful completion!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         else
         begin
            $display("FAILURE: Simulation stopped due to error!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         ebfm_log_stop_sim = 1'b0 ;
      end
   endfunction

   // purpose: This displays a message of the specified type
   function ebfm_display;
      input msg_type;
      integer msg_type;
      input [EBFM_MSG_MAX_LEN*8:1] message;

      reg [9*8:1]  prefix ;
      reg [80*8:1] amsg;
      reg sup;
      reg stp;
      reg dummy ;
      integer i ;
      time ctime ;
      integer itime ;

      begin
         for (i = 0 ; i < EBFM_MSG_MAX_LEN ; i = i + 1)
           begin : msg_shift
              if (message[(EBFM_MSG_MAX_LEN*8)-:8] != 8'h00)
                begin
                   disable msg_shift ;
                end
              message = message << 8 ;
           end
         if (msg_type > EBFM_MSG_ERROR_CONTINUE)
           begin
              sup = 1'b0;
              stp = 1'b1;
              case (msg_type)
                EBFM_MSG_ERROR_FATAL :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to Fatal error!" ;
                     prefix = "FATAL:   ";
                  end
                EBFM_MSG_ERROR_FATAL_TB_ERR :
                  begin
                     amsg   = "FAILURE: Simulation stopped due error in Testbench/BFM design!";
                     prefix = "FATAL:   ";
                  end
                default :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to unknown message type!";
                     prefix = "FATAL:   ";
                  end
              endcase
           end
         else
           begin
              sup = bfm_log_common.suppressed_msg_mask[msg_type];
              stp = bfm_log_common.stop_on_msg_mask[msg_type];
              if (stp == 1'b1)
                begin
                   amsg   = "FAILURE: Simulation stopped due to enabled error!";
                end
              if (msg_type < EBFM_MSG_INFO)
                begin
                     prefix = "DEBUG:   ";
                end
              else
                begin
                   if (msg_type < EBFM_MSG_WARNING)
                     begin
                        prefix = "INFO:    ";
                     end
                   else
                     begin
                        if (msg_type > EBFM_MSG_WARNING)
                          begin
                             prefix = "ERROR:   ";
                          end
                        else
                          begin
                             prefix = "WARNING: ";
                          end
                     end
                end
           end // else: !if(msg_type > EBFM_MSG_ERROR_CONTINUE)
         itime = ($time/1000) ;
         // Display the message if not suppressed
         if (sup != 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file,"%s %d %s %s",prefix,itime,"ns",message);
                end
              $display("%s %d %s %s",prefix,itime,"ns",message);
           end
         // Stop if requested
         if (stp == 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file, "%s", amsg);
                end
              $display("%s",amsg);
              dummy = ebfm_log_stop_sim(0);
           end
         // Dummy function return so we can call from other functions
         ebfm_display = 1'b0 ;
      end
   endfunction

   // purpose: produce 1-digit hexadecimal string from a vector
   function [8:1] himage1;
      input [3:0] vec;

      begin
         case (vec)
           4'h0 : himage1 = "0" ;
           4'h1 : himage1 = "1" ;
           4'h2 : himage1 = "2" ;
           4'h3 : himage1 = "3" ;
           4'h4 : himage1 = "4" ;
           4'h5 : himage1 = "5" ;
           4'h6 : himage1 = "6" ;
           4'h7 : himage1 = "7" ;
           4'h8 : himage1 = "8" ;
           4'h9 : himage1 = "9" ;
           4'hA : himage1 = "A" ;
           4'hB : himage1 = "B" ;
           4'hC : himage1 = "C" ;
           4'hD : himage1 = "D" ;
           4'hE : himage1 = "E" ;
           4'hF : himage1 = "F" ;
           4'bzzzz : himage1 = "Z" ;
           default : himage1 = "X" ;
         endcase
      end
   endfunction // himage1

   // purpose: produce 2-digit hexadecimal string from a vector
   function [16:1] himage2 ;
      input [7:0] vec;
      begin
         himage2 = {himage1(vec[7:4]),himage1(vec[3:0])} ;
      end
   endfunction // himage2

   // purpose: produce 4-digit hexadecimal string from a vector
   function [32:1] himage4 ;
      input [15:0] vec;
      begin
         himage4 = {himage2(vec[15:8]),himage2(vec[7:0])} ;
      end
   endfunction // himage4

   // purpose: produce 8-digit hexadecimal string from a vector
   function [64:1] himage8 ;
      input [31:0] vec;
      begin
         himage8 = {himage4(vec[31:16]),himage4(vec[15:0])} ;
      end
   endfunction // himage8

   // purpose: produce 16-digit hexadecimal string from a vector
   function [128:1] himage16 ;
      input [63:0] vec;
      begin
         himage16 = {himage8(vec[63:32]),himage8(vec[31:0])} ;
      end
   endfunction // himage16

   // purpose: produce 1-digit decimal string from an integer
   function [8:1] dimage1 ;
      input [31:0] num ;
      begin
         case (num)
           0 : dimage1 = "0" ;
           1 : dimage1 = "1" ;
           2 : dimage1 = "2" ;
           3 : dimage1 = "3" ;
           4 : dimage1 = "4" ;
           5 : dimage1 = "5" ;
           6 : dimage1 = "6" ;
           7 : dimage1 = "7" ;
           8 : dimage1 = "8" ;
           9 : dimage1 = "9" ;
           default : dimage1 = "U" ;
         endcase // case(num)
      end
   endfunction // dimage1

   // purpose: produce 2-digit decimal string from an integer
   function [16:1] dimage2 ;
      input [31:0] num ;
      begin
         dimage2 = {dimage1(num/10),dimage1(num % 10)} ;
      end
   endfunction // dimage2

   // purpose: produce 3-digit decimal string from an integer
   function [24:1] dimage3 ;
      input [31:0] num ;
      begin
         dimage3 = {dimage1(num/100),dimage2(num % 100)} ;
      end
   endfunction // dimage3

   // purpose: produce 4-digit decimal string from an integer
   function [32:1] dimage4 ;
      input [31:0] num ;
      begin
         dimage4 = {dimage1(num/1000),dimage3(num % 1000)} ;
      end
   endfunction // dimage4

   // purpose: produce 5-digit decimal string from an integer
   function [40:1] dimage5 ;
      input [31:0] num ;
      begin
         dimage5 = {dimage1(num/10000),dimage4(num % 10000)} ;
      end
   endfunction // dimage5

   // purpose: produce 6-digit decimal string from an integer
   function [48:1] dimage6 ;
      input [31:0] num ;
      begin
         dimage6 = {dimage1(num/100000),dimage5(num % 100000)} ;
      end
   endfunction // dimage6

   // purpose: produce 7-digit decimal string from an integer
   function [56:1] dimage7 ;
      input [31:0] num ;
      begin
         dimage7 = {dimage1(num/1000000),dimage6(num % 1000000)} ;
      end
   endfunction // dimage7

  // purpose: select the correct dimage call for ascii conversion
  function  [800:1] image ;
     input  [800:1] msg ;
     input  [32:1]  num ;
     begin
        if (num <= 10)
        begin
           image = {msg, dimage1(num)};
        end
        else if (num <= 100)
        begin
           image = {msg, dimage2(num)};
        end
        else if (num <= 1000)
        begin
           image = {msg, dimage3(num)};
        end
        else if (num <= 10000)
        begin
           image = {msg, dimage4(num)};
        end
        else if (num <= 100000)
        begin
           image = {msg, dimage5(num)};
        end
        else if (num <= 1000000)
        begin
           image = {msg, dimage6(num)};
        end
        else image = {msg, dimage7(num)};
     end
   endfunction

   // This constant defines how long to wait whenever waiting for some external event...
   localparam NUM_PS_TO_WAIT = 8000 ;

   // purpose: Sets the Max Payload size variables
   task req_intf_set_max_payload;
      input max_payload_size;
      integer max_payload_size;
      input ep_max_rd_req; // 0 means use max_payload_size
      integer ep_max_rd_req;
      input rp_max_rd_req;
      integer rp_max_rd_req;

      begin
         // 0 means use max_payload_size
         // set_max_payload
         bfm_req_intf_common.bfm_max_payload_size = max_payload_size;
         if (ep_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = ep_max_rd_req;
         end
         else
         begin
            bfm_req_intf_common.bfm_ep_max_rd_req = max_payload_size;
         end
         if (rp_max_rd_req > 0)
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = rp_max_rd_req;
         end
         else
         begin
            bfm_req_intf_common.bfm_rp_max_rd_req = max_payload_size;
         end
      end
   endtask

   // purpose: Returns the stored max payload size
   function integer req_intf_max_payload_size;
   input dummy;
      begin
         req_intf_max_payload_size = bfm_req_intf_common.bfm_max_payload_size;
      end
   endfunction

   // purpose: Returns the stored end point max read request size
   function integer req_intf_ep_max_rd_req_size;
   input dummy;
      begin
         req_intf_ep_max_rd_req_size = bfm_req_intf_common.bfm_ep_max_rd_req;
      end
   endfunction

   // purpose: Returns the stored root port max read request size
   function integer req_intf_rp_max_rd_req_size;
   input dummy;
      begin
         req_intf_rp_max_rd_req_size = bfm_req_intf_common.bfm_rp_max_rd_req;
      end
   endfunction

   // purpose: procedure to wait until the root port is done being reset
   task req_intf_wait_reset_end;

      begin
         while (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            #NUM_PS_TO_WAIT;
         end
      end
   endtask

   // purpose: procedure to get a free tag from the pool. Waits for one
   // to be free if none available initially
   task req_intf_get_tag;
      output tag;
      integer tag;
      input need_handle;
      input lcl_addr;
      integer lcl_addr;

      integer tag_v;

      begin
         tag_v = EBFM_NUM_TAG ;
         while ((tag_v > EBFM_NUM_TAG - 1) & (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin : main_tloop
            // req_intf_get_tag
            // Find a tag to use
            begin : xhdl_0
               integer i;
               for(i = 0; i <= EBFM_NUM_TAG - 1; i = i + 1)
               begin : sub_tloop
                  if (((bfm_req_intf_common.tag_busy[i]) == 1'b0) &
                      ((bfm_req_intf_common.hnd_busy[i]) == 1'b0))
                  begin
                     bfm_req_intf_common.tag_busy[i] = 1'b1;
                     bfm_req_intf_common.hnd_busy[i] = need_handle;
                     bfm_req_intf_common.tag_lcl_addr[i] = lcl_addr;
                     tag_v = i;
                     disable main_tloop;
                  end
               end
            end // i
            #(NUM_PS_TO_WAIT);
         end
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
         begin
            tag = EBFM_NUM_TAG;
         end
         else
         begin
            tag = tag_v;
         end
      end
   endtask

   // purpose: makes a request pending for the appropriate VC interface
   task req_intf_vc_req;
      input[192:0] info_v;

      integer vcnum;

      reg dummy ;

      begin
         // Get the Virtual Channel Number from the Traffic Class Number
         vcnum = bfm_req_intf_common.tc2vc_map[info_v[118:116]];
         if (vcnum >= EBFM_NUM_VC)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to transmit Packet with TC mapped to unsupported VC.",
                          "TC: ", dimage1(info_v[118:116]),
                          ", VC: ", dimage1(vcnum)});
         end
         // Make sure the ACK from any previous requests are cleared
         while (((bfm_req_intf_common.req_info_ack[vcnum]) == 1'b1) &
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT);
         end
         if (bfm_req_intf_common.reset_in_progress == 1'b1)
           begin
              // Exit
              disable req_intf_vc_req ;
           end
         // Make the Request
         bfm_req_intf_common.req_info[vcnum] = info_v;
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b1;
         // Now wait for it to be acknowledged
         while ((bfm_req_intf_common.req_info_ack[vcnum] == 1'b0) &
                (bfm_req_intf_common.reset_in_progress == 1'b0))
         begin
            #(NUM_PS_TO_WAIT);
         end
         // Clear the request
         bfm_req_intf_common.req_info[vcnum] = {193{1'b0}};
         bfm_req_intf_common.req_info_valid[vcnum] = 1'b0;
      end
   endtask

   // purpose: Releases a reserved handle
   task req_intf_release_handle;
      input handle;
      integer handle;

      reg dummy ;

      begin
         // req_intf_release_handle
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to release Handle ",
                          dimage4(handle),
                          " that is not reserved."});
         end
         bfm_req_intf_common.hnd_busy[handle] = 1'b0;
      end
   endtask

   // purpose: Wait for completion on the specified handle
   task req_intf_wait_compl;
      input handle;
      integer handle;
      output[2:0] compl_status;
      input keep_handle;

      reg dummy ;

      begin
         if ((bfm_req_intf_common.hnd_busy[handle]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Attempt to wait for completion on Handle ",
                          dimage4(handle),
                          " that is not reserved."});
         end
         while ((bfm_req_intf_common.reset_in_progress == 1'b0) &
                (bfm_req_intf_common.tag_busy[handle] == 1'b1))
         begin
            #(NUM_PS_TO_WAIT);
         end
         if ((bfm_req_intf_common.tag_busy[handle]) == 1'b0)
         begin
            compl_status = bfm_req_intf_common.tag_status[handle];
         end
         else
         begin
            compl_status = "UUU";
         end
         if (keep_handle != 1'b1)
         begin
            req_intf_release_handle(handle);
         end
      end
   endtask

   // purpose: This gets the pending request (if any) for the specified VC
   task vc_intf_get_req;
      input vc_num;
      integer vc_num;
      output req_valid;
      output[127:0] req_desc;
      output lcladdr;
      integer lcladdr;
      output imm_valid;
      output[31:0] imm_data;

      begin
         // vc_intf_get_req
         req_desc  = bfm_req_intf_common.req_info[vc_num][127:0];
         lcladdr   = bfm_req_intf_common.req_info[vc_num][159:128];
         imm_data  = bfm_req_intf_common.req_info[vc_num][191:160];
         imm_valid = bfm_req_intf_common.req_info[vc_num][192];
         req_valid = bfm_req_intf_common.req_info_valid[vc_num];
      end
   endtask

   // purpose: This sets the acknowledgement for a pending request
   task vc_intf_set_ack;
      input vc_num;
      integer vc_num;

      reg dummy ;

      begin
         if (bfm_req_intf_common.req_info_valid[vc_num] != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"VC Interface ",
                          dimage1(vc_num),
                          " tried to ACK a request that is not there."});
         end
         if (bfm_req_intf_common.req_info_ack[vc_num] != 1'b0)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"VC Interface ",
                          dimage1(vc_num),
                          " tried to ACK a request second time."});
         end
         bfm_req_intf_common.req_info_ack[vc_num] = 1'b1;
      end
   endtask

   // purpose: This conditionally clears the acknowledgement for a pending request
   //          It only clears the ack if the req valid has been cleared.
   //          Returns '1' if the Ack was cleared, else returns '0'.
   function [0:0] vc_intf_clr_ack;
      input vc_num;
      integer vc_num;

      begin
         if ((bfm_req_intf_common.req_info_valid[vc_num]) == 1'b0)
         begin
            bfm_req_intf_common.req_info_ack[vc_num] = 1'b0;
            vc_intf_clr_ack = 1'b1;
         end
         else
         begin
            vc_intf_clr_ack = 1'b0;
         end
      end
   endfunction

   // purpose: This routine is to record the completion of a previous non-posted request
   task vc_intf_rpt_compl;
      input tag;
      integer tag;
      input[2:0] status;

      reg dummy ;

      begin
         // vc_intf_rpt_compl
         bfm_req_intf_common.tag_status[tag] = status;
         if ((bfm_req_intf_common.tag_busy[tag]) != 1'b1)
         begin
            dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,
                         {"Tried to clear a tag that was not busy. Tag: ",
                          dimage4(tag)});
         end
         bfm_req_intf_common.tag_busy[tag] = 1'b0;
      end
   endtask

   task vc_intf_reset_flag;
      input rstn;

      begin
         bfm_req_intf_common.reset_in_progress = ~rstn;
      end
   endtask

   function integer vc_intf_get_lcl_addr;
      input tag;
      integer tag;

      begin
         // vc_intf_get_lcl_addr
         if ((bfm_req_intf_common.tag_lcl_addr[tag] != -1) &
             ((bfm_req_intf_common.tag_busy[tag] == 1'b1) |
              (bfm_req_intf_common.hnd_busy[tag] == 1'b1)))
         begin
            vc_intf_get_lcl_addr = bfm_req_intf_common.tag_lcl_addr[tag];
         end
         else
         begin
            vc_intf_get_lcl_addr = -1 ;
         end
      end
   endfunction

   function integer vc_intf_sample_perf;
      input vc_num;
      integer vc_num;
      begin
         vc_intf_sample_perf = bfm_req_intf_common.perf_req[vc_num];
      end
   endfunction

  task vc_intf_set_perf;
  input [31:0] vc_num;
  input [31:0] tx_pkts;
  input [31:0] tx_qwords;
  input [31:0] rx_pkts;
  input [31:0] rx_qwords;
  begin
     bfm_req_intf_common.perf_tx_pkts[vc_num]   = tx_pkts ;
     bfm_req_intf_common.perf_tx_qwords[vc_num] = tx_qwords ;
     bfm_req_intf_common.perf_rx_pkts[vc_num]   = rx_pkts ;
     bfm_req_intf_common.perf_rx_qwords[vc_num] = rx_qwords ;
     bfm_req_intf_common.perf_ack[vc_num]       = 1'b1 ;
  end
  endtask

   task vc_intf_clr_perf;
      input vc_num;
      integer vc_num;
      begin
         bfm_req_intf_common.perf_ack[vc_num] = 1'b0;
      end
   endtask

   task req_intf_start_perf_sample;
   integer i;
   begin
      bfm_req_intf_common.perf_req = {EBFM_NUM_VC{1'b1}};
      bfm_req_intf_common.last_perf_timestamp = $time;
      while (bfm_req_intf_common.perf_req != {EBFM_NUM_VC{1'b0}})
      begin
         #NUM_PS_TO_WAIT;
         for (i = 1'b0 ; i < EBFM_NUM_VC ; i = i +1)
         begin
            if (bfm_req_intf_common.perf_ack[i] == 1'b1)
            begin
               bfm_req_intf_common.perf_req[i] = 1'b0;
            end
         end
      end
   end
   endtask

   task req_intf_disp_perf_sample;
   integer total_tx_qwords;
   integer total_tx_pkts;
   integer total_rx_qwords;
   integer total_rx_pkts;
   integer tx_mbyte_ps;
   integer rx_mbyte_ps;
   output  tx_mbit_ps;
   integer tx_mbit_ps;
   output  rx_mbit_ps;
   integer rx_mbit_ps;
   integer delta_time;
   integer delta_ns;
   output  bytes_transmitted;
   integer bytes_transmitted;
   reg   [EBFM_MSG_MAX_LEN*8:1] message;
   integer i;
   integer dummy;
   begin
      total_tx_qwords = 0;
      total_tx_pkts   = 0;
      total_rx_qwords = 0;
      total_rx_pkts   = 0;
      delta_time = $time - bfm_req_intf_common.last_perf_timestamp;
      delta_ns = delta_time / 1000;
      req_intf_start_perf_sample ;
      for (i = 0; i < EBFM_NUM_VC; i = i + 1)
      begin
         total_tx_qwords = total_tx_qwords + bfm_req_intf_common.perf_tx_qwords[i] ;
         total_tx_pkts   = total_tx_pkts   + bfm_req_intf_common.perf_tx_pkts[i];
         total_rx_qwords = total_rx_qwords + bfm_req_intf_common.perf_rx_qwords[i];
         total_rx_pkts   = total_rx_pkts   + bfm_req_intf_common.perf_rx_pkts[i];
      end
      tx_mbyte_ps = (total_tx_qwords * 8) / (delta_ns / 1000);
      rx_mbyte_ps = (total_rx_qwords * 8) / (delta_ns / 1000);
      tx_mbit_ps  = tx_mbyte_ps * 8;
      rx_mbit_ps  = rx_mbyte_ps * 8;
      bytes_transmitted = total_tx_qwords*8;

      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF: Sample Duration: ", delta_ns)," ns"});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Tx Packets: ", total_tx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Tx Bytes: ", total_tx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Tx MByte/sec: ", tx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Tx Mbit/sec: ", tx_mbit_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:      Rx Packets: ", total_rx_pkts)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:        Rx Bytes: ", total_rx_qwords*8)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:    Rx MByte/sec: ", rx_mbyte_ps)});
      dummy = ebfm_display(EBFM_MSG_INFO, {image("PERF:     Rx Mbit/sec: ", rx_mbit_ps)});
   end
   endtask

//`endif

   output      dummy_out;

// Contains the performance measurement information
   reg         [0:EBFM_NUM_VC-1] perf_req;
   reg         [0:EBFM_NUM_VC-1] perf_ack;
   integer     perf_tx_pkts[0:EBFM_NUM_VC-1];
   integer     perf_tx_qwords[0:EBFM_NUM_VC-1];
   integer     perf_rx_pkts[0:EBFM_NUM_VC-1];
   integer     perf_rx_qwords[0:EBFM_NUM_VC-1];
   integer     last_perf_timestamp;

   reg [192:0] req_info[0:EBFM_NUM_VC-1] ;
   reg         req_info_valid[0:EBFM_NUM_VC-1] ;
   reg         req_info_ack[0:EBFM_NUM_VC-1] ;

   reg         tag_busy[0:EBFM_NUM_TAG-1] ;
   reg [2:0]   tag_status[0:EBFM_NUM_TAG-1] ;
   reg         hnd_busy[0:EBFM_NUM_TAG-1] ;
   integer     tag_lcl_addr[0:EBFM_NUM_TAG-1] ;

   reg reset_in_progress ;
   integer bfm_max_payload_size ;
   integer bfm_ep_max_rd_req ;
   integer bfm_rp_max_rd_req ;
   // This variable holds the TC to VC mapping
   reg [23:0] tc2vc_map;

   integer    i ;

   initial
     begin
        for (i = 0; i < EBFM_NUM_VC; i = i + 1 )
          begin
             req_info[i]       = {193{1'b0}} ;
             req_info_valid[i] = 1'b0 ;
             req_info_ack[i]   = 1'b0 ;
             perf_req[i]       = 1'b0 ;
             perf_ack[i]       = 1'b0 ;
             perf_tx_pkts[i]   = 0 ;
             perf_tx_qwords[i] = 0 ;
             perf_rx_pkts[i]   = 0 ;
             perf_rx_qwords[i] = 0 ;
             last_perf_timestamp[i] = 0 ;
          end
        for (i = 0; i < EBFM_NUM_TAG; i = i + 1)
          begin
             tag_busy[i]     = 1'b0 ;
             tag_status[i]   = 3'b000 ;
             hnd_busy[i]     = 1'b0 ;
             tag_lcl_addr[i] = 0 ;
          end
        reset_in_progress    = 1'b0 ;
        bfm_max_payload_size = 128 ;
        bfm_ep_max_rd_req    = 128 ;
        bfm_rp_max_rd_req    = 128 ;
        tc2vc_map            = 24'h000000 ;
     end
endmodule // altpcietb_bfm_req_intf_common



`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express BFM Shmem Module
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_bfm_shmem_common.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// Implements the common shared memory array
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcietb_bfm_shmem_common(dummy_out) ;

   // Root Port Primary Side Bus Number and Device Number
   localparam [7:0] RP_PRI_BUS_NUM = 8'h00 ;
   localparam [4:0] RP_PRI_DEV_NUM = 5'b00000 ;
   // Root Port Requester ID
   localparam[15:0] RP_REQ_ID = {RP_PRI_BUS_NUM, RP_PRI_DEV_NUM , 3'b000}; // used in the Requests sent out
   // 2MB of memory
   localparam SHMEM_ADDR_WIDTH = 21;
   // The first section of the PCI Express I/O Space will be reserved for
   // addressing the Root Port's Shared Memory. PCI Express I/O Initiators
   // would use an I/O address in this range to access the shared memory.
   // Likewise the first section of the PCI Express Memory Space will be
   // reserved for accessing the Root Port's Shared Memory. PCI Express
   // Memory Initiators will use this range to access this memory.
   // These values here set the range that can be used to assign the
   // EP BARs to.
   localparam[31:0] EBFM_BAR_IO_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_IO_MAX = {32{1'b1}};
   localparam[31:0] EBFM_BAR_M32_MIN = 32'b1 << SHMEM_ADDR_WIDTH ;
   localparam[31:0] EBFM_BAR_M32_MAX = {32{1'b1}};
   localparam[63:0] EBFM_BAR_M64_MIN = 64'h0000000100000000 ;
   localparam[63:0] EBFM_BAR_M64_MAX = {64{1'b1}};
   localparam EBFM_NUM_VC = 4; // Number of VC's implemented in the Root Port BFM
   localparam EBFM_NUM_TAG = 32; // Number of TAG's used by Root Port BFM

   // Constants for the logging package
   localparam EBFM_MSG_DEBUG = 0;
   localparam EBFM_MSG_INFO = 1;
   localparam EBFM_MSG_WARNING = 2;
   localparam EBFM_MSG_ERROR_INFO = 3; // Preliminary Error Info Message
   localparam EBFM_MSG_ERROR_CONTINUE = 4;
   // Fatal Error Messages always stop the simulation
   localparam EBFM_MSG_ERROR_FATAL = 101;
   localparam EBFM_MSG_ERROR_FATAL_TB_ERR = 102;

   // Maximum Message Length in characters
   localparam EBFM_MSG_MAX_LEN = 100 ;

   // purpose: sets the suppressed_msg_mask
   task ebfm_log_set_suppressed_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_suppressed_msg_mask
         bfm_log_common.suppressed_msg_mask = msg_mask;
      end
   endtask

   // purpose: sets the stop_on_msg_mask
   task ebfm_log_set_stop_on_msg_mask;
      input [EBFM_MSG_ERROR_CONTINUE:EBFM_MSG_DEBUG] msg_mask;

      begin
         // ebfm_log_set_stop_on_msg_mask
         bfm_log_common.stop_on_msg_mask = msg_mask;
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_open;
      input [200*8:1] fn; // Log File Name

      begin
         bfm_log_common.log_file = $fopen(fn);
      end
   endtask

   // purpose: Opens the Log File with the specified name
   task ebfm_log_close;

      begin
         // ebfm_log_close
         $fclose(bfm_log_common.log_file);
         bfm_log_common.log_file = 0;
      end
   endtask

   // purpose: stops the simulation, with flag to indicate success or not
   function ebfm_log_stop_sim;
      input success;
      integer success;

      begin
         if (success == 1)
         begin
            $display("SUCCESS: Simulation stopped due to successful completion!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         else
         begin
            $display("FAILURE: Simulation stopped due to error!");
            `ifdef VCS
            $finish;
            `else
            $stop ;
            `endif
         end
         ebfm_log_stop_sim = 1'b0 ;
      end
   endfunction

   // purpose: This displays a message of the specified type
   function ebfm_display;
      input msg_type;
      integer msg_type;
      input [EBFM_MSG_MAX_LEN*8:1] message;

      reg [9*8:1]  prefix ;
      reg [80*8:1] amsg;
      reg sup;
      reg stp;
      reg dummy ;
      integer i ;
      time ctime ;
      integer itime ;

      begin
         for (i = 0 ; i < EBFM_MSG_MAX_LEN ; i = i + 1)
           begin : msg_shift
              if (message[(EBFM_MSG_MAX_LEN*8)-:8] != 8'h00)
                begin
                   disable msg_shift ;
                end
              message = message << 8 ;
           end
         if (msg_type > EBFM_MSG_ERROR_CONTINUE)
           begin
              sup = 1'b0;
              stp = 1'b1;
              case (msg_type)
                EBFM_MSG_ERROR_FATAL :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to Fatal error!" ;
                     prefix = "FATAL:   ";
                  end
                EBFM_MSG_ERROR_FATAL_TB_ERR :
                  begin
                     amsg   = "FAILURE: Simulation stopped due error in Testbench/BFM design!";
                     prefix = "FATAL:   ";
                  end
                default :
                  begin
                     amsg   = "FAILURE: Simulation stopped due to unknown message type!";
                     prefix = "FATAL:   ";
                  end
              endcase
           end
         else
           begin
              sup = bfm_log_common.suppressed_msg_mask[msg_type];
              stp = bfm_log_common.stop_on_msg_mask[msg_type];
              if (stp == 1'b1)
                begin
                   amsg   = "FAILURE: Simulation stopped due to enabled error!";
                end
              if (msg_type < EBFM_MSG_INFO)
                begin
                     prefix = "DEBUG:   ";
                end
              else
                begin
                   if (msg_type < EBFM_MSG_WARNING)
                     begin
                        prefix = "INFO:    ";
                     end
                   else
                     begin
                        if (msg_type > EBFM_MSG_WARNING)
                          begin
                             prefix = "ERROR:   ";
                          end
                        else
                          begin
                             prefix = "WARNING: ";
                          end
                     end
                end
           end // else: !if(msg_type > EBFM_MSG_ERROR_CONTINUE)
         itime = ($time/1000) ;
         // Display the message if not suppressed
         if (sup != 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file,"%s %d %s %s",prefix,itime,"ns",message);
                end
              $display("%s %d %s %s",prefix,itime,"ns",message);
           end
         // Stop if requested
         if (stp == 1'b1)
           begin
              if (bfm_log_common.log_file != 0)
                begin
                   $fdisplay(bfm_log_common.log_file, "%s", amsg);
                end
              $display("%s",amsg);
              dummy = ebfm_log_stop_sim(0);
           end
         // Dummy function return so we can call from other functions
         ebfm_display = 1'b0 ;
      end
   endfunction

   // purpose: produce 1-digit hexadecimal string from a vector
   function [8:1] himage1;
      input [3:0] vec;

      begin
         case (vec)
           4'h0 : himage1 = "0" ;
           4'h1 : himage1 = "1" ;
           4'h2 : himage1 = "2" ;
           4'h3 : himage1 = "3" ;
           4'h4 : himage1 = "4" ;
           4'h5 : himage1 = "5" ;
           4'h6 : himage1 = "6" ;
           4'h7 : himage1 = "7" ;
           4'h8 : himage1 = "8" ;
           4'h9 : himage1 = "9" ;
           4'hA : himage1 = "A" ;
           4'hB : himage1 = "B" ;
           4'hC : himage1 = "C" ;
           4'hD : himage1 = "D" ;
           4'hE : himage1 = "E" ;
           4'hF : himage1 = "F" ;
           4'bzzzz : himage1 = "Z" ;
           default : himage1 = "X" ;
         endcase
      end
   endfunction // himage1

   // purpose: produce 2-digit hexadecimal string from a vector
   function [16:1] himage2 ;
      input [7:0] vec;
      begin
         himage2 = {himage1(vec[7:4]),himage1(vec[3:0])} ;
      end
   endfunction // himage2

   // purpose: produce 4-digit hexadecimal string from a vector
   function [32:1] himage4 ;
      input [15:0] vec;
      begin
         himage4 = {himage2(vec[15:8]),himage2(vec[7:0])} ;
      end
   endfunction // himage4

   // purpose: produce 8-digit hexadecimal string from a vector
   function [64:1] himage8 ;
      input [31:0] vec;
      begin
         himage8 = {himage4(vec[31:16]),himage4(vec[15:0])} ;
      end
   endfunction // himage8

   // purpose: produce 16-digit hexadecimal string from a vector
   function [128:1] himage16 ;
      input [63:0] vec;
      begin
         himage16 = {himage8(vec[63:32]),himage8(vec[31:0])} ;
      end
   endfunction // himage16

   // purpose: produce 1-digit decimal string from an integer
   function [8:1] dimage1 ;
      input [31:0] num ;
      begin
         case (num)
           0 : dimage1 = "0" ;
           1 : dimage1 = "1" ;
           2 : dimage1 = "2" ;
           3 : dimage1 = "3" ;
           4 : dimage1 = "4" ;
           5 : dimage1 = "5" ;
           6 : dimage1 = "6" ;
           7 : dimage1 = "7" ;
           8 : dimage1 = "8" ;
           9 : dimage1 = "9" ;
           default : dimage1 = "U" ;
         endcase // case(num)
      end
   endfunction // dimage1

   // purpose: produce 2-digit decimal string from an integer
   function [16:1] dimage2 ;
      input [31:0] num ;
      begin
         dimage2 = {dimage1(num/10),dimage1(num % 10)} ;
      end
   endfunction // dimage2

   // purpose: produce 3-digit decimal string from an integer
   function [24:1] dimage3 ;
      input [31:0] num ;
      begin
         dimage3 = {dimage1(num/100),dimage2(num % 100)} ;
      end
   endfunction // dimage3

   // purpose: produce 4-digit decimal string from an integer
   function [32:1] dimage4 ;
      input [31:0] num ;
      begin
         dimage4 = {dimage1(num/1000),dimage3(num % 1000)} ;
      end
   endfunction // dimage4

   // purpose: produce 5-digit decimal string from an integer
   function [40:1] dimage5 ;
      input [31:0] num ;
      begin
         dimage5 = {dimage1(num/10000),dimage4(num % 10000)} ;
      end
   endfunction // dimage5

   // purpose: produce 6-digit decimal string from an integer
   function [48:1] dimage6 ;
      input [31:0] num ;
      begin
         dimage6 = {dimage1(num/100000),dimage5(num % 100000)} ;
      end
   endfunction // dimage6

   // purpose: produce 7-digit decimal string from an integer
   function [56:1] dimage7 ;
      input [31:0] num ;
      begin
         dimage7 = {dimage1(num/1000000),dimage6(num % 1000000)} ;
      end
   endfunction // dimage7

  // purpose: select the correct dimage call for ascii conversion
  function  [800:1] image ;
     input  [800:1] msg ;
     input  [32:1]  num ;
     begin
        if (num <= 10)
        begin
           image = {msg, dimage1(num)};
        end
        else if (num <= 100)
        begin
           image = {msg, dimage2(num)};
        end
        else if (num <= 1000)
        begin
           image = {msg, dimage3(num)};
        end
        else if (num <= 10000)
        begin
           image = {msg, dimage4(num)};
        end
        else if (num <= 100000)
        begin
           image = {msg, dimage5(num)};
        end
        else if (num <= 1000000)
        begin
           image = {msg, dimage6(num)};
        end
        else image = {msg, dimage7(num)};
     end
   endfunction


   parameter SHMEM_FILL_ZERO = 0;
   parameter SHMEM_FILL_BYTE_INC = 1;
   parameter SHMEM_FILL_WORD_INC = 2;
   parameter SHMEM_FILL_DWORD_INC = 4;
   parameter SHMEM_FILL_QWORD_INC = 8;
   parameter SHMEM_FILL_ONE = 15;
   parameter SHMEM_SIZE = 2 ** SHMEM_ADDR_WIDTH;
   parameter BAR_TABLE_SIZE = 64;
   parameter BAR_TABLE_POINTER = SHMEM_SIZE - BAR_TABLE_SIZE;
   parameter SCR_SIZE = 64;
   parameter CFG_SCRATCH_SPACE = SHMEM_SIZE - BAR_TABLE_SIZE - SCR_SIZE;

   task shmem_write;
      input addr;
      integer addr;
      input [63:0] data;
      input leng;
      integer leng;

      integer rleng;
      integer i ;

      reg dummy ;

      begin
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_WRITE only accepts write lengths up to 8") ;
              rleng = 8 ;
           end
         else if ( addr < BAR_TABLE_POINTER + BAR_TABLE_SIZE & addr >= CFG_SCRATCH_SPACE & bfm_shmem_common.protect_bfm_shmem )
            begin
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Task SHMEM_WRITE attempted to overwrite the write protected area of the shared memory") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"This protected area contains the following data critical to the operation of the BFM:") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BFM internal memory area, 64B located at ", himage8(CFG_SCRATCH_SPACE)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"The BAR Table, 64B located at ", himage8(BAR_TABLE_POINTER)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,{"All other locations in the shared memory are available from 0 to ", himage8(CFG_SCRATCH_SPACE - 1)}) ;
              dummy = ebfm_display(EBFM_MSG_ERROR_INFO,"Please change your SHMEM_WRITE call to a different memory location") ;
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Halting Simulation") ;
            end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              bfm_shmem_common.shmem[addr + i] = data[(i*8)+:8];
           end
      end
   endtask

   function [63:0] shmem_read;
      input addr;
      integer addr;
      input leng;
      integer leng;

      reg[63:0] rdata;
      integer rleng ;
      integer i ;

      reg dummy ;

      begin
         rdata = {64{1'b0}} ;
         if (leng > 8)
           begin
              dummy = ebfm_display(EBFM_MSG_ERROR_FATAL,"Task SHMEM_READ only accepts read lengths up to 8") ;
              rleng = 8 ;
           end
         else
           begin
              rleng = leng ;
           end
         for(i = 0; i <= (rleng - 1); i = i + 1)
           begin
              rdata[(i * 8)+:8] = bfm_shmem_common.shmem[addr + i];
           end
         shmem_read = rdata;
      end
   endfunction

   // purpose: display shared memory data
   function shmem_display;
      input addr;
      integer addr;
      input leng;
      integer leng;
      input word_size;
      integer word_size;
      input flag_addr;
      integer flag_addr;
      input msg_type;
      integer msg_type;

      integer iaddr;
      reg [60*8:1] oneline ;
      reg [128:1] data_str[0:15] ;
      reg [8*5:1] flag ;
      integer i ;

      reg dummy ;

      begin
         // shmem_display
         iaddr = addr ;
         // Backup address to beginning of word if needed
         if (iaddr % word_size > 0)
           begin
              iaddr = iaddr - (iaddr % word_size);
           end
         dummy = ebfm_display(msg_type, "");
         dummy = ebfm_display(msg_type, "Shared Memory Data Display:");
         dummy = ebfm_display(msg_type, "Address  Data");
         dummy = ebfm_display(msg_type, "-------  ----");
         while (iaddr < (addr + leng))
           begin
              for (i = 0; i < 16 ; i = i + word_size)
                begin : one_line
                   if ( (iaddr + i) > (addr + leng) )
                     begin
                        data_str[i] = "        " ;
                     end
                   else
                     begin
                        case (word_size)
                          8       : data_str[i] = himage16(shmem_read(iaddr + i,8)) ;
                          4       : data_str[i] = {"            ",himage8(shmem_read(iaddr + i,4))} ;
                          2       : data_str[i] = {"                ",himage4(shmem_read(iaddr + i,2))} ;
                          default : data_str[i] = {"                  ",himage2(shmem_read(iaddr + i,1))} ;
                        endcase // case(word_size)
                     end
                end // block: one_line
              if ((flag_addr >= iaddr) & (flag_addr < (iaddr + 16)))
                begin
                   flag = " <===" ;
                end
              else
                begin
                   flag = "     " ;
                end
              // Now compile the whole line
              oneline = {480{1'b0}} ;
              case (word_size)
                8 : oneline = {himage8(iaddr),
                               " ",data_str[0]," ",data_str[8],flag} ;
                4 : oneline = {himage8(iaddr),
                               " ",data_str[0][64:1]," ",data_str[4][64:1],
                               " ",data_str[8][64:1]," ",data_str[12][64:1],
                               flag} ;
                2 : oneline = {himage8(iaddr),
                               " ",data_str[0][32:1]," ",data_str[2][32:1],
                               " ",data_str[4][32:1]," ",data_str[6][32:1],
                               " ",data_str[8][32:1]," ",data_str[10][32:1],
                               " ",data_str[12][32:1]," ",data_str[14][32:1],
                               flag} ;
                default : oneline = {himage8(iaddr),
                               " ",data_str[0][16:1]," ",data_str[1][16:1],
                               " ",data_str[2][16:1]," ",data_str[3][16:1],
                               " ",data_str[4][16:1]," ",data_str[5][16:1],
                               " ",data_str[6][16:1]," ",data_str[7][16:1],
                               " ",data_str[8][16:1]," ",data_str[9][16:1],
                               " ",data_str[10][16:1]," ",data_str[11][16:1],
                               " ",data_str[12][16:1]," ",data_str[13][16:1],
                               " ",data_str[14][16:1]," ",data_str[15][16:1],
                               flag} ;
              endcase
              dummy = ebfm_display(msg_type, oneline);
              iaddr = iaddr + 16;
           end // while (iaddr < (addr + leng))
         // Dummy return so we can call from other functions
         shmem_display = 1'b0 ;
      end
   endfunction

   task shmem_fill;
      input addr;
      integer addr;
      input mode;
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init;

      integer rembytes;
      reg[63:0] data;
      integer uaddr;
      parameter[7:0] ZDATA = {8{1'b0}};
      parameter[7:0] ODATA = {8{1'b1}};

      begin
         rembytes = leng ;
         data = init ;
         uaddr = addr ;
         while (rembytes > 0)
         begin
            case (mode)
               SHMEM_FILL_ZERO :
                        begin
                           shmem_write(uaddr, ZDATA,1);
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               SHMEM_FILL_BYTE_INC :
                        begin
                           shmem_write(uaddr, data, 1);
                           data[7:0] = data[7:0] + 1;
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               SHMEM_FILL_WORD_INC :
                        begin
                           begin : xhdl_3
                              integer i;
                              for(i = 0; i <= 1; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[15:0] = data[15:0] + 1;
                        end
               SHMEM_FILL_DWORD_INC :
                        begin
                           begin : xhdl_4
                              integer i;
                              for(i = 0; i <= 3; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[31:0] = data[31:0] + 1 ;
                        end
               SHMEM_FILL_QWORD_INC :
                        begin
                           begin : xhdl_5
                              integer i;
                              for(i = 0; i <= 7; i = i + 1)
                              begin
                                 if (rembytes > 0)
                                 begin
                                    shmem_write(uaddr, data[(i*8)+:8], 1);
                                    rembytes = rembytes - 1;
                                    uaddr = uaddr + 1;
                                 end
                              end
                           end // i
                           data[63:0] = data[63:0] + 1;
                        end
               SHMEM_FILL_ONE :
                        begin
                           shmem_write(uaddr, ODATA, 1);
                           rembytes = rembytes - 1;
                           uaddr = uaddr + 1;
                        end
               default :
                        begin
                        end
            endcase
         end
      end
   endtask

   // Returns 1 if okay
   function [0:0] shmem_chk_ok;
      input addr;
      integer addr;
      input mode;
      integer mode;
      input leng; // Length to fill in bytes
      integer leng;
      input[63:0] init;
      input display_error;
      integer display_error;

      reg dummy ;

      integer rembytes;
      reg[63:0] data;
      reg[63:0] actual;
      integer uaddr;
      integer daddr;
      integer dlen;
      integer incr_count;
      parameter[7:0] ZDATA = {8{1'b0}};
      parameter[7:0] ODATA = {8{1'b1}};
      reg [36*8:1] actline;
      reg [36*8:1] expline;
      integer word_size;

      begin
         rembytes = leng ;
         uaddr = addr ;
         data = init ;
         actual = init ;
         incr_count = 0 ;
         case (mode)
            SHMEM_FILL_WORD_INC :
                     begin
                        word_size = 2;
                     end
            SHMEM_FILL_DWORD_INC :
                     begin
                        word_size = 4;
                     end
            SHMEM_FILL_QWORD_INC :
                     begin
                        word_size = 8;
                     end
            default :
                     begin
                        word_size = 1;
                     end
         endcase // case(mode)
         begin : compare_loop
         while (rembytes > 0)
         begin
            case (mode)
               SHMEM_FILL_ZERO :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != ZDATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ZDATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_BYTE_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[7:0])
                      begin
                         expline = {"    Expected Data: ", himage2(data[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    data[7:0] = data[7:0] + 1;
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_WORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 1)
                      begin
                         data[15:0] = data[15:0] + 1 ;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_DWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 3)
                      begin
                         data[31:0] = data[31:0] + 1;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_QWORD_INC :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != data[(incr_count * 8)+:8])
                      begin
                         expline = {"    Expected Data: ", himage2(data[(incr_count * 8)+:8]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    if (incr_count == 7)
                      begin
                         data[63:0] = data[63:0] + 1;
                         incr_count = 0;
                      end
                    else
                      begin
                         incr_count = incr_count + 1;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               SHMEM_FILL_ONE :
                 begin
                    actual[7:0] = shmem_read(uaddr, 1);
                    if (actual[7:0] != ODATA)
                      begin
                         expline = {"    Expected Data: ", himage2(ODATA[7:0]), "              "};
                         actline = {"      Actual Data: ", himage2(actual[7:0]), "              "};
                         disable compare_loop;
                      end
                    rembytes = rembytes - 1;
                    uaddr = uaddr + 1;
                 end
               default :
                 begin
                 end
            endcase
         end
         end // block: compare_loop
         if (rembytes > 0)
         begin
            if (display_error == 1)
            begin
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, "");
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, {"Shared memory data miscompare at address: ", himage8(uaddr)});
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, expline);
               dummy = ebfm_display(EBFM_MSG_ERROR_INFO, actline);
               // Backup and display a little before the miscompare
               // Figure amount to backup
               daddr = uaddr % 32; // Back up no more than 32 bytes
               // There was a miscompare, display an error message
               if (daddr < 16)
               begin
                  // But at least 16
                  daddr = daddr + 16;
               end
               // Backed up display address
               daddr = uaddr - daddr;
               // Don't backup more than start of compare
               if (daddr < addr)
               begin
                  daddr = addr;
               end
               // Try to display 64 bytes
               dlen = 64;
               // But don't display beyond the end of the compare
               if (daddr + dlen > addr + leng)
               begin
                  dlen = (addr + leng) - daddr;
               end
               dummy = shmem_display(daddr, dlen, word_size, uaddr, EBFM_MSG_ERROR_INFO);
            end
            shmem_chk_ok = 0;
         end
         else
         begin
            shmem_chk_ok = 1;
         end
      end
   endfunction
//`endif
output dummy_out;
   reg [7:0] shmem[0:SHMEM_SIZE-1] ;

   // Protection Bit for the Shared Memory
   // This bit protects critical data in Shared Memory from being overwritten.
   // Critical data includes things like the BAR table that maps BAR numbers to addresses.
   // Deassert this bit to REMOVE protection of the CRITICAL data.
   reg protect_bfm_shmem;

   initial
     begin
        shmem_fill(0,SHMEM_FILL_ZERO,SHMEM_SIZE,{64{1'b0}}) ;
        protect_bfm_shmem = 1'b1;
     end

endmodule // altpcietb_bfm_shmem_common

