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


module s4gx_gen1x8_qsys_top (
   refclk,
   free_100MHz,
   pcie_rstn,

   rx_in7, 
   rx_in6, 
   rx_in5, 
   rx_in4, 
   rx_in3, 
   rx_in2, 
   rx_in1, 
   rx_in0, 

   tx_out7 , 
   tx_out6 ,
   tx_out5 ,
   tx_out4 ,
   tx_out3 ,
   tx_out2 ,
   tx_out1 ,
   tx_out0 

// Debug signals
);

  input  refclk;
  input  free_100MHz;
  input  pcie_rstn;

  input   rx_in7; 
  input   rx_in6; 
  input   rx_in5; 
  input   rx_in4; 
  input   rx_in3; 
  input   rx_in2; 
  input   rx_in1; 
  input   rx_in0; 

  output  tx_out7 ; 
  output  tx_out6 ;
  output  tx_out5 ;
  output  tx_out4 ;
  output  tx_out3 ;
  output  tx_out2 ;
  output  tx_out1 ;
  output  tx_out0 ;

// Internal signals

		 wire        txelecidle0_ext;           
		 wire        txdatak0_ext;              
		 wire        txcompl5_ext;              
		 wire [7:0]  rxdata1_ext;               
		 wire        txcompl4_ext;              
		 wire [2:0]  rxstatus1_ext;             
		 wire [7:0]  txdata3_ext;               
		 wire        rxdatak6_ext;              
		 wire        txelecidle2_ext;           
		 wire [7:0]  txdata5_ext;               
		 wire        txcompl0_ext;              
		 wire [7:0]  rxdata4_ext;               
		 wire        rxpolarity0_ext;           
		 wire        txcompl2_ext;              
		 wire [7:0]  txdata0_ext;               
		 wire        rxpolarity1_ext;           
		 wire [1:0]  powerdown_ext;             
		 wire        txcompl1_ext;              
		 wire        txdatak2_ext;              
		 wire        txcompl7_ext;              
		 wire        txcompl3_ext;              
		 wire        phystatus_ext;             
		 wire        rxelecidle7_ext;           
		 wire        txelecidle4_ext;           
		 wire        rxdatak1_ext;              
		 wire [2:0]  rxstatus5_ext;             
		 wire        rxelecidle1_ext;           
		 wire        txdatak4_ext;              
		 wire [7:0]  txdata1_ext;               
		 wire        rxelecidle5_ext;           
		 wire        rxvalid4_ext;              
		 wire [7:0]  rxdata5_ext;               
		 wire        txelecidle1_ext;           
		 wire        txcompl6_ext;              
		 wire        rxpolarity3_ext;           
		 wire [7:0]  txdata4_ext;               
		 wire [7:0]  txdata7_ext;               
		 wire [2:0]  rxstatus0_ext;             
		 wire        txdatak7_ext;              
		 wire        rxelecidle0_ext;           
		 wire        rxdatak0_ext;              
		 wire        rxelecidle6_ext;           
		 wire [7:0]  txdata2_ext;               
		 wire [2:0]  rxstatus3_ext;             
		 wire [2:0]  rxstatus6_ext;             
		 wire [7:0]  rxdata6_ext;               
		 wire        rxpolarity6_ext;           
		 wire        rxpolarity5_ext;           
		 wire        rxvalid0_ext;              
		 wire [2:0]  rxstatus7_ext;             
		 wire        rxdatak2_ext;              
		 wire        rxelecidle2_ext;           
		 wire        rxelecidle4_ext;           
		 wire        rxelecidle3_ext;           
		 wire        rxdatak3_ext;              
		 wire        rxvalid5_ext;              
		 wire        rxpolarity2_ext;           
		 wire [2:0]  rxstatus4_ext;             
		 wire [7:0]  rxdata3_ext;               
		 wire        txdatak6_ext;              
		 wire        txdetectrx_ext;            
		 wire        rxpolarity4_ext;           
		 wire        pipe_mode;                 
		 wire        txelecidle3_ext;           
		 wire        rxdatak5_ext;              
		 wire        rxvalid2_ext;              
		 wire        txdatak5_ext;              
		 wire        txdatak3_ext;              
		 wire [2:0]  rxstatus2_ext;             
		 wire        gxb_powerdown;             
		 wire        pll_powerdown;             
		 wire        rxvalid3_ext;              
		 wire [7:0]  txdata6_ext;               
		 wire [7:0]  rxdata7_ext;               
		 wire        rxpolarity7_ext;           
		 wire        txelecidle7_ext;           
		 wire        rxdatak4_ext;              
		 wire        rate_ext;                  
		 wire        rxdatak7_ext;              
		 wire        rxvalid6_ext;              
		 wire        txdatak1_ext;              
		 wire        txelecidle5_ext;           
		 wire [7:0]  rxdata2_ext;               
		 wire        rxvalid1_ext;              
		 wire [7:0]  rxdata0_ext;               
		 wire        txelecidle6_ext;           
		 wire        rxvalid7_ext;              
		 //wire        cal_blk_clk;             
		 wire [3:0]  reconfig_togxb_data;       
		 wire        busy_altgxb_reconfig;      
		 wire [63:0] test_out;                  
		 wire [16:0] reconfig_fromgxb_1_data;   
		 wire [16:0] reconfig_fromgxb_0_data;   
		 wire        reconfig_gxbclk_clk;       
		 wire        tx_out7;                   
		 wire        tx_out5;                   
		 wire        tx_out3;                   
		 wire        tx_out4;                   
		 wire        tx_out6;                   
		 wire        tx_out2;                   
		 wire        tx_out1;                   
		 wire        tx_out0;                   
		 wire        clocks_sim_clk250;         
		 wire        clocks_sim_clk500;         
		 wire        clocks_sim_clk125;         
		 wire [39:0] test_in;                   
		 wire        fixedclk;              

//==========================
// Set input values
//==========================
  assign pipe_mode = 1'b0;

//========================================
// Set test_in
//[11: 8] = Test_out select
//[7]     = Disable Power Management
//[5]     = Disable Compliance
//[3]     = FPGA mode 
//[0]     = Speed up serial simulation
//========================================
  assign test_in[39 : 12] = 0;
  assign test_in[11 :  8] = 3;        // Default PIPE interface    
  assign test_in[ 7 :  6] = 2'b10 ;
  assign test_in[5]       = 1;        // Disable Compliance testing
  assign test_in[4 : 0]   = 5'b01001; // Set FPGA mode, Speed-up serial simulation 
 
hip_s4gx_gen1x8_qsys  pcie_qsys_i  (
		.pcie_hard_ip_0_fixedclk_clk              (fixedclk               ),                       
		.pcie_hard_ip_0_pipe_ext_txelecidle0_ext  (txelecidle0_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txdatak0_ext     (txdatak0_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txcompl5_ext     (txcompl5_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxdata1_ext      (rxdata1_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txcompl4_ext     (txcompl4_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxstatus1_ext    (rxstatus1_ext          ),             
		.pcie_hard_ip_0_pipe_ext_txdata3_ext      (txdata3_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxdatak6_ext     (rxdatak6_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txelecidle2_ext  (txelecidle2_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txdata5_ext      (txdata5_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txcompl0_ext     (txcompl0_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxdata4_ext      (rxdata4_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxpolarity0_ext  (rxpolarity0_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txcompl2_ext     (txcompl2_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdata0_ext      (txdata0_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxpolarity1_ext  (rxpolarity1_ext        ),           
		.pcie_hard_ip_0_pipe_ext_powerdown_ext    (powerdown_ext          ),             
		.pcie_hard_ip_0_pipe_ext_txcompl1_ext     (txcompl1_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdatak2_ext     (txdatak2_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txcompl7_ext     (txcompl7_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txcompl3_ext     (txcompl3_ext           ),              
		.pcie_hard_ip_0_pipe_ext_phystatus_ext    (phystatus_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxelecidle7_ext  (rxelecidle7_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txelecidle4_ext  (txelecidle4_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdatak1_ext     (rxdatak1_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxstatus5_ext    (rxstatus5_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxelecidle1_ext  (rxelecidle1_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txdatak4_ext     (txdatak4_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdata1_ext      (txdata1_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxelecidle5_ext  (rxelecidle5_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxvalid4_ext     (rxvalid4_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxdata5_ext      (rxdata5_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txelecidle1_ext  (txelecidle1_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txcompl6_ext     (txcompl6_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxpolarity3_ext  (rxpolarity3_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txdata4_ext      (txdata4_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txdata7_ext      (txdata7_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxstatus0_ext    (rxstatus0_ext          ),             
		.pcie_hard_ip_0_pipe_ext_txdatak7_ext     (txdatak7_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxelecidle0_ext  (rxelecidle0_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdatak0_ext     (rxdatak0_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxelecidle6_ext  (rxelecidle6_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txdata2_ext      (txdata2_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxstatus3_ext    (rxstatus3_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxstatus6_ext    (rxstatus6_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxdata6_ext      (rxdata6_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxpolarity6_ext  (rxpolarity6_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxpolarity5_ext  (rxpolarity5_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxvalid0_ext     (rxvalid0_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxstatus7_ext    (rxstatus7_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxdatak2_ext     (rxdatak2_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxelecidle2_ext  (rxelecidle2_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxelecidle4_ext  (rxelecidle4_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxelecidle3_ext  (rxelecidle3_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdatak3_ext     (rxdatak3_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxvalid5_ext     (rxvalid5_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxpolarity2_ext  (rxpolarity2_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxstatus4_ext    (rxstatus4_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxdata3_ext      (rxdata3_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txdatak6_ext     (txdatak6_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdetectrx_ext   (txdetectrx_ext         ),            
		.pcie_hard_ip_0_pipe_ext_rxpolarity4_ext  (rxpolarity4_ext        ),           
		.pcie_hard_ip_0_pipe_ext_pipe_mode        (pipe_mode              ),                 
		.pcie_hard_ip_0_pipe_ext_txelecidle3_ext  (txelecidle3_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdatak5_ext     (rxdatak5_ext           ), 
		.pcie_hard_ip_0_pipe_ext_rxvalid2_ext     (rxvalid2_ext           ),          
		.pcie_hard_ip_0_pipe_ext_txdatak5_ext     (txdatak5_ext           ),          
		.pcie_hard_ip_0_pipe_ext_txdatak3_ext     (txdatak3_ext           ),          
		.pcie_hard_ip_0_pipe_ext_rxstatus2_ext    (rxstatus2_ext          ),             
		.pcie_hard_ip_0_pipe_ext_rxvalid3_ext     (rxvalid3_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdata6_ext      (txdata6_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxdata7_ext      (rxdata7_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxpolarity7_ext  (rxpolarity7_ext        ),           
		.pcie_hard_ip_0_pipe_ext_txelecidle7_ext  (txelecidle7_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdatak4_ext     (rxdatak4_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rate_ext         (rate_ext               ),                  
		.pcie_hard_ip_0_pipe_ext_rxdatak7_ext     (rxdatak7_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxvalid6_ext     (rxvalid6_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txdatak1_ext     (txdatak1_ext           ),              
		.pcie_hard_ip_0_pipe_ext_txelecidle5_ext  (txelecidle5_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxdata2_ext      (rxdata2_ext            ),               
		.pcie_hard_ip_0_pipe_ext_rxvalid1_ext     (rxvalid1_ext           ),              
		.pcie_hard_ip_0_pipe_ext_rxdata0_ext      (rxdata0_ext            ),               
		.pcie_hard_ip_0_pipe_ext_txelecidle6_ext  (txelecidle6_ext        ),           
		.pcie_hard_ip_0_pipe_ext_rxvalid7_ext     (rxvalid7_ext           ),              
		.pcie_hard_ip_0_cal_blk_clk_clk           (reconfig_gxbclk_clk    ),                    
		.pcie_hard_ip_0_reconfig_togxb_data       (reconfig_togxb_data    ),                
		.pcie_hard_ip_0_pcie_rstn_export          (pcie_rstn              ),                   
		.pcie_hard_ip_0_reconfig_busy_busy_altgxb_reconfig(busy_altgxb_reconfig)   , 
		.pcie_hard_ip_0_test_out_test_out         (test_out               ),                  
		.pcie_hard_ip_0_rx_in_rx_datain_7         (rx_in7                ), 
		.pcie_hard_ip_0_rx_in_rx_datain_6         (rx_in6                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_5         (rx_in5                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_4         (rx_in4                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_3         (rx_in3                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_2         (rx_in2                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_1         (rx_in1                ),        
		.pcie_hard_ip_0_rx_in_rx_datain_0         (rx_in0                ),        
		.pcie_hard_ip_0_reconfig_fromgxb_1_data   (reconfig_fromgxb_1_data),            
		.pcie_hard_ip_0_reconfig_fromgxb_0_data   (reconfig_fromgxb_0_data),            
		.pcie_hard_ip_0_reconfig_gxbclk_clk       (reconfig_gxbclk_clk    ),                
		.pcie_hard_ip_0_tx_out_tx_dataout_7       (tx_out7               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_6       (tx_out6               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_5       (tx_out5               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_4       (tx_out4               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_3       (tx_out3               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_2       (tx_out2               ), 
		.pcie_hard_ip_0_tx_out_tx_dataout_1       (tx_out1               ),         
		.pcie_hard_ip_0_tx_out_tx_dataout_0       (tx_out0               ),         
		.pcie_hard_ip_0_clocks_sim_clk250_export  (clocks_sim_clk250      ), 
		.pcie_hard_ip_0_clocks_sim_clk500_export  (clocks_sim_clk500      ),         
		.pcie_hard_ip_0_clocks_sim_clk125_export  (clocks_sim_clk125      ),         
		.pcie_hard_ip_0_test_in_test_in           (test_in                ),                    
		.pcie_hard_ip_0_refclk_export             (refclk                 )                                   
	);


//==================================
// New modules manually instantiated 
//==================================
wire pll_locked;

gpll gpll_i(
	.areset     (!pcie_rstn),
	.inclk0     (free_100MHz),
	.c0         (reconfig_gxbclk_clk),
	.c1         (fixedclk  ),
	.locked     (pll_locked)
);

altgxb_reconfig altgxb_reconfig_i (
	.offset_cancellation_reset    (!pll_locked            ),
	.reconfig_clk                 (reconfig_gxbclk_clk    ),
	.reconfig_fromgxb             ({reconfig_fromgxb_1_data, reconfig_fromgxb_0_data}),
	.busy                         (busy_altgxb_reconfig   ),
	.reconfig_togxb               (reconfig_togxb_data    )
);


endmodule
