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



`timescale 1 ps / 1 ps
module top_hw (
                input  wire         hip_serial_rx_in0,         //           .rx_in0
                input  wire         hip_serial_rx_in1,         //           .rx_in1
                input  wire         hip_serial_rx_in2,         //           .rx_in2
                input  wire         hip_serial_rx_in3,         //           .rx_in3
                input  wire         hip_serial_rx_in4,         //           .rx_in0
                input  wire         hip_serial_rx_in5,         //           .rx_in1
                input  wire         hip_serial_rx_in6,         //           .rx_in2
                input  wire         hip_serial_rx_in7,         //           .rx_in3
                output wire         hip_serial_tx_out0,        //           .tx_out0
                output wire         hip_serial_tx_out1,        //           .tx_out1
                output wire         hip_serial_tx_out2,        //           .tx_out3
                output wire         hip_serial_tx_out3,        // hip_serial.tx_out2
                output wire         hip_serial_tx_out4,        //           .tx_out0
                output wire         hip_serial_tx_out5,        //           .tx_out1
                output wire         hip_serial_tx_out6,        //           .tx_out3
                output wire         hip_serial_tx_out7,        // hip_serial.tx_out2
                input  wire         refclk_clk,                //     refclk.clk
                input  wire         reconfig_xcvr_clk,                //     refclk.clk
                input  wire         local_rstn,
                output  wire        hsma_clk_out_p2,
                output  reg [3:0]   lane_active_led,
                output  reg        L0_led,
                output  reg        alive_led,
                output  reg        comp_led,
                output  reg        gen2_led,
//                output  reg [3:0]        lane_active_led,
                input  wire         perstn             //  pcie_rstn.npor
        );

wire [31:0]  hip_ctrl_test_in;          //           .test_in
wire         fbout_reconfigclk;
wire [52:0]  tl_cfg_tl_cfg_sts;
wire [31:0] tl_cfg_tl_cfg_ctl;            //            tl_cfg.tl_cfg_ctl
wire [3:0]  tl_cfg_tl_cfg_add;            //                  .tl_cfg_add
wire        status_hip_rx_par_err;        //        status_hip.rx_par_err
wire [3:0]  status_hip_int_status;        //                  .int_status
wire        status_hip_derr_cor_ext_rcv;  //                  .derr_cor_ext_rcv
wire        status_hip_dlup_exit;         //                  .dlup_exit
wire [11:0] status_hip_ko_cpl_spc_data;   //                  .ko_cpl_spc_data
wire        status_hip_l2_exit;           //                  .l2_exit
wire        status_hip_cfg_par_err;       //                  .cfg_par_err
wire        status_hip_dlup;              //                  .dlup
wire [1:0]  status_hip_tx_par_err;        //                  .tx_par_err
wire        status_hip_ev1us;             //                  .ev1us
wire        status_hip_derr_rpl;          //                  .derr_rpl
wire [4:0]  status_hip_ltssmstate;        //                  .ltssmstate
wire [3:0]  status_hip_lane_act;          //                  .lane_act
wire        status_hip_ev128ns;           //                  .ev128ns
//wire [1:0]  status_hip_currentspeed;      //                  .currentspeed
wire        status_hip_hotrst_exit;       //                  .hotrst_exit
wire        status_hip_derr_cor_ext_rpl;  //                  .derr_cor_ext_rpl
wire [7:0]  status_hip_ko_cpl_spc_header;//                  .ko_cpl_spc_header


  reg     [ 24: 0] alive_cnt;
  wire             any_rstn;
  reg              any_rstn_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
  reg              any_rstn_rr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R102"  */;
  wire             gen2_speed;
  wire [5:0]       ltssm;

// Undriven signals for Config-Bypass
//
  assign tl_cfg_tl_cfg_sts = 36'h0;

assign any_rstn = local_rstn;
assign hsma_clk_out_p2 = reconfig_xcvr_clk;
assign gen2_speed  = tl_cfg_tl_cfg_sts[32];


reg    cbb_btn_r;
reg    [2:0] cbb_cnt;

localparam WID = 8;
wire [WID-1:0] cbb_btn=0;

//lpm_constant    cbb
//  (
//   .result (cbb_btn)
//   );
//defparam
//         cbb.lpm_cvalue = 0,
//         cbb.lpm_hint = "ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=CBB2",
//         cbb.lpm_type = "LPM_CONSTANT",
//         cbb.lpm_width = WID;


assign hip_ctrl_test_in[4:0]  =  5'b01000;
assign hip_ctrl_test_in[5] =  1'b1;
assign hip_ctrl_test_in[31:6] =  26'h2;


  //CBB push button
  always @(posedge reconfig_xcvr_clk or negedge any_rstn)
    begin
      if (any_rstn == 0)
        begin
        cbb_cnt <= 0;
        cbb_btn_r <= 0;
        end
      else
        begin
        cbb_btn_r <= cbb_btn[0];

        if (cbb_btn_r != cbb_btn[0])
          cbb_cnt <= 3'h7;
        else if (cbb_cnt == 0)
          cbb_cnt <= 0;
        else
          cbb_cnt <= cbb_cnt - 1;

        end
    end




  //reset Synchronizer
  always @(posedge reconfig_xcvr_clk or negedge any_rstn)
    begin
      if (any_rstn == 0)
        begin
          any_rstn_r <= 0;
          any_rstn_rr <= 0;
        end
      else
        begin
          any_rstn_r <= 1;
          any_rstn_rr <= any_rstn_r;
        end
    end



  //LED logic
  always @(posedge reconfig_xcvr_clk or negedge any_rstn_rr)
    begin
      if (any_rstn_rr == 0)
        begin
          alive_cnt <= 0;
          alive_led <= 0;
          comp_led <= 0;
          L0_led <= 0;
          gen2_led <= 0;
          lane_active_led[3:2] <= 0;
          lane_active_led[0] <= 0;
        end
      else
        begin
          alive_cnt <= alive_cnt +1;
          alive_led <= alive_cnt[24];
          comp_led <= ~(ltssm[4 : 0] == 5'b00011);
          L0_led <= ~(ltssm[4 : 0] == 5'b01111);
          gen2_led <= ~gen2_speed;
          if (tl_cfg_tl_cfg_sts[35])
            lane_active_led <= ~(4'b0001);
          else if (tl_cfg_tl_cfg_sts[36])
            lane_active_led <= ~(4'b0011);
          else if (tl_cfg_tl_cfg_sts[37])
            lane_active_led <= ~(4'b1111);
          else if (tl_cfg_tl_cfg_sts[38])
            lane_active_led <= alive_cnt[24] ? ~(4'b1111) : ~(4'b0111);
        end
    end

top top (
		.refclk_clk			         ( refclk_clk         ),                
		.hip_ctrl_test_in			   ( hip_ctrl_test_in   ),          
		.hip_ctrl_simu_mode_pipe	( 1'b0               ),   
		.hip_serial_rx_in0			( hip_serial_rx_in0  ),         
		.hip_serial_rx_in1			( hip_serial_rx_in1  ),         
		.hip_serial_rx_in2			( hip_serial_rx_in2  ),         
		.hip_serial_rx_in3			( hip_serial_rx_in3  ),         
		.hip_serial_rx_in4			( hip_serial_rx_in4  ),         
		.hip_serial_rx_in5			( hip_serial_rx_in5  ),         
		.hip_serial_rx_in6			( hip_serial_rx_in6  ),         
		.hip_serial_rx_in7			( hip_serial_rx_in7  ),         
		.hip_serial_tx_out0			( hip_serial_tx_out0 ),        
		.hip_serial_tx_out1			( hip_serial_tx_out1 ),        
		.hip_serial_tx_out2			( hip_serial_tx_out2 ),        
		.hip_serial_tx_out3			( hip_serial_tx_out3 ),        
		.hip_serial_tx_out4			( hip_serial_tx_out4 ),        
		.hip_serial_tx_out5			( hip_serial_tx_out5 ),        
		.hip_serial_tx_out6			( hip_serial_tx_out6 ),        
		.hip_serial_tx_out7			( hip_serial_tx_out7 ),        
		.hip_pipe_sim_pipe_pclk_in	( 1'b0               ), 
		.hip_pipe_sim_pipe_rate		( ),   
		.hip_pipe_sim_ltssmstate	( ltssm              ),   
		.hip_pipe_eidleinfersel0	( ),   
		.hip_pipe_eidleinfersel1	( ),   
		.hip_pipe_eidleinfersel2	( ),   
		.hip_pipe_eidleinfersel3	( ),   
		.hip_pipe_eidleinfersel4	( ),   
		.hip_pipe_eidleinfersel5	( ),   
		.hip_pipe_eidleinfersel6	( ),   
		.hip_pipe_eidleinfersel7	( ),   
		.hip_pipe_powerdown0			( ),       
		.hip_pipe_powerdown1			( ),       
		.hip_pipe_powerdown2			( ),       
		.hip_pipe_powerdown3			( ),       
		.hip_pipe_powerdown4			( ),       
		.hip_pipe_powerdown5			( ),       
		.hip_pipe_powerdown6			( ),       
		.hip_pipe_powerdown7			( ),       
		.hip_pipe_rxpolarity0		( ),      
		.hip_pipe_rxpolarity1		( ),      
		.hip_pipe_rxpolarity2		( ),      
		.hip_pipe_rxpolarity3		( ),      
		.hip_pipe_rxpolarity4		( ),      
		.hip_pipe_rxpolarity5		( ),      
		.hip_pipe_rxpolarity6		( ),      
		.hip_pipe_rxpolarity7		( ),      
		.hip_pipe_txcompl0			( ),         
		.hip_pipe_txcompl1			( ),         
		.hip_pipe_txcompl2			( ),         
		.hip_pipe_txcompl3			( ),         
		.hip_pipe_txcompl4			( ),         
		.hip_pipe_txcompl5			( ),         
		.hip_pipe_txcompl6			( ),         
		.hip_pipe_txcompl7			( ),         
		.hip_pipe_txdata0			   ( ),          
		.hip_pipe_txdata1			   ( ),          
		.hip_pipe_txdata2			   ( ),          
		.hip_pipe_txdata3			   ( ),          
		.hip_pipe_txdata4			   ( ),          
		.hip_pipe_txdata5			   ( ),          
		.hip_pipe_txdata6			   ( ),          
		.hip_pipe_txdata7			   ( ),          
		.hip_pipe_txdatak0			( ),         
		.hip_pipe_txdatak1			( ),         
		.hip_pipe_txdatak2			( ),         
		.hip_pipe_txdatak3			( ),         
		.hip_pipe_txdatak4			( ),         
		.hip_pipe_txdatak5			( ),         
		.hip_pipe_txdatak6			( ),         
		.hip_pipe_txdatak7			( ),         
		.hip_pipe_txdetectrx0		( ),      
		.hip_pipe_txdetectrx1		( ),      
		.hip_pipe_txdetectrx2		( ),      
		.hip_pipe_txdetectrx3		( ),      
		.hip_pipe_txdetectrx4		( ),      
		.hip_pipe_txdetectrx5		( ),      
		.hip_pipe_txdetectrx6		( ),      
		.hip_pipe_txdetectrx7		( ),      
		.hip_pipe_txelecidle0		( ),      
		.hip_pipe_txelecidle1		( ),      
		.hip_pipe_txelecidle2		( ),      
		.hip_pipe_txelecidle3		( ),      
		.hip_pipe_txelecidle4		( ),      
		.hip_pipe_txelecidle5		( ),      
		.hip_pipe_txelecidle6		( ),      
		.hip_pipe_txelecidle7		( ),      
		.hip_pipe_txdeemph0			( ),        
		.hip_pipe_txdeemph1			( ),        
		.hip_pipe_txdeemph2			( ),        
		.hip_pipe_txdeemph3			( ),        
		.hip_pipe_txdeemph4			( ),        
		.hip_pipe_txdeemph5			( ),        
		.hip_pipe_txdeemph6			( ),        
		.hip_pipe_txdeemph7			( ),        
		.hip_pipe_txmargin0			( ),        
		.hip_pipe_txmargin1			( ),        
		.hip_pipe_txmargin2			( ),        
		.hip_pipe_txmargin3			( ),        
		.hip_pipe_txmargin4			( ),        
		.hip_pipe_txmargin5			( ),        
		.hip_pipe_txmargin6			( ),        
		.hip_pipe_txmargin7			( ),        
		.hip_pipe_txswing0			( ),         
		.hip_pipe_txswing1			( ),         
		.hip_pipe_txswing2			( ),         
		.hip_pipe_txswing3			( ),         
		.hip_pipe_txswing4			( ),         
		.hip_pipe_txswing5			( ),         
		.hip_pipe_txswing6			( ),         
		.hip_pipe_txswing7			( ),         
		.hip_pipe_phystatus0			( 1'b0 ),       
		.hip_pipe_phystatus1			( 1'b0 ),       
		.hip_pipe_phystatus2			( 1'b0 ),       
		.hip_pipe_phystatus3			( 1'b0 ),       
		.hip_pipe_phystatus4			( 1'b0 ),       
		.hip_pipe_phystatus5			( 1'b0 ),       
		.hip_pipe_phystatus6			( 1'b0 ),       
		.hip_pipe_phystatus7			( 1'b0 ),       
		.hip_pipe_rxdata0			   ( 8'h0 ),          
		.hip_pipe_rxdata1			   ( 8'h0 ),          
		.hip_pipe_rxdata2				( 8'h0 ),          
		.hip_pipe_rxdata3			   ( 8'h0 ),          
		.hip_pipe_rxdata4			   ( 8'h0 ),          
		.hip_pipe_rxdata5			   ( 8'h0 ),          
		.hip_pipe_rxdata6				( 8'h0 ),          
		.hip_pipe_rxdata7			   ( 8'h0 ),          
		.hip_pipe_rxdatak0			( 1'b0 ),         
		.hip_pipe_rxdatak1			( 1'b0 ),         
		.hip_pipe_rxdatak2			( 1'b0 ),         
		.hip_pipe_rxdatak3			( 1'b0 ),         
		.hip_pipe_rxdatak4			( 1'b0 ),         
		.hip_pipe_rxdatak5			( 1'b0 ),         
		.hip_pipe_rxdatak6			( 1'b0 ),         
		.hip_pipe_rxdatak7			( 1'b0 ),         
		.hip_pipe_rxelecidle0		( 1'b0 ),      
		.hip_pipe_rxelecidle1		( 1'b0 ),      
		.hip_pipe_rxelecidle2		( 1'b0 ),      
		.hip_pipe_rxelecidle3		( 1'b0 ),      
		.hip_pipe_rxelecidle4		( 1'b0 ),      
		.hip_pipe_rxelecidle5		( 1'b0 ),      
		.hip_pipe_rxelecidle6		( 1'b0 ),      
		.hip_pipe_rxelecidle7		( 1'b0 ),      
		.hip_pipe_rxstatus0			( 3'h0 ),        
		.hip_pipe_rxstatus1			( 3'h0 ),        
		.hip_pipe_rxstatus2			( 3'h0 ),        
		.hip_pipe_rxstatus3			( 3'h0 ),        
		.hip_pipe_rxstatus4			( 3'h0 ),        
		.hip_pipe_rxstatus5			( 3'h0 ),        
		.hip_pipe_rxstatus6			( 3'h0 ),        
		.hip_pipe_rxstatus7			( 3'h0 ),        
		.hip_pipe_rxvalid0			( 1'b0 ),         
		.hip_pipe_rxvalid1			( 1'b0 ),         
		.hip_pipe_rxvalid2			( 1'b0 ),         
		.hip_pipe_rxvalid3			( 1'b0 ),         
		.hip_pipe_rxvalid4			( 1'b0 ),         
		.hip_pipe_rxvalid5			( 1'b0 ),         
		.hip_pipe_rxvalid6			( 1'b0 ),         
		.hip_pipe_rxvalid7			( 1'b0 ),         
      .reset_reset_n             ((local_rstn==1'b0)?1'b0:(perstn==1'b0)?1'b0:1'b1), // reconfig_xcvr_rst.reconfig_xcvr_rst
      //.pcie_rstn_npor            ( any_rstn_rr),             
      .pcie_rstn_npor            ( perstn     ),             
      .pcie_rstn_pin_perst       ( perstn     ),            
		.clk_clk                   ( reconfig_xcvr_clk )     
	);


endmodule

