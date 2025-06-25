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


module c4gx_gen1x4_qsys_top (
   refclk,
   free_50MHz,
   pcie_rstn,

   rx_in3, 
   rx_in2, 
   rx_in1, 
   rx_in0, 

   tx_out3 ,
   tx_out2 ,
   tx_out1 ,
   tx_out0 

// Debug signals
);

  input  refclk;
  input  free_50MHz;
  input  pcie_rstn;

  input   rx_in3; 
  input   rx_in2; 
  input   rx_in1; 
  input   rx_in0; 

  output  tx_out3 ;
  output  tx_out2 ;
  output  tx_out1 ;
  output  tx_out0 ;

// Internal signals

wire        fixedclk;              
wire        rxpolarity0_ext;           
wire [2:0]  rxstatus1_ext;             
wire        pipe_mode;                 
wire        rxvalid0_ext;              
wire [2:0]  rxstatus2_ext;             
wire        rxvalid1_ext;              
wire        rxelecidle0_ext;           
wire        txelecidle0_ext;           
wire        rxelecidle2_ext;           
wire        txcompl0_ext;              
wire [1:0]  powerdown_ext;             
wire        rxelecidle1_ext;           
wire [7:0]  rxdata2_ext;               
wire [7:0]  txdata0_ext;               
wire [7:0]  rxdata1_ext;               
wire        txdetectrx_ext;            
wire [7:0]  txdata2_ext;               
wire        rxelecidle3_ext;           
wire        txcompl3_ext;              
wire        rxdatak2_ext;              
wire        txelecidle3_ext;           
wire        pll_powerdown;             
wire        txdatak3_ext;              
wire        txdatak1_ext;              
wire        txelecidle2_ext;           
wire        txcompl1_ext;              
wire [7:0]  txdata3_ext;               
wire        txdatak2_ext;              
wire        gxb_powerdown;             
wire        rxpolarity1_ext;           
wire        rxpolarity3_ext;           
wire        rxpolarity2_ext;           
wire        rxdatak3_ext;              
wire [7:0]  txdata1_ext;               
wire        rxvalid3_ext;              
wire [7:0]  rxdata0_ext;               
wire        rxdatak1_ext;              
wire [2:0]  rxstatus0_ext;             
wire        rate_ext;                  
wire        txcompl2_ext;              
wire        txelecidle1_ext;           
wire        phystatus_ext;             
wire [7:0]  rxdata3_ext;               
wire        rxvalid2_ext;              
wire        rxdatak0_ext;              
wire        txdatak0_ext;              
wire [2:0]  rxstatus3_ext;             
wire [3:0]  reconfig_togxb_data;       
wire        pcie_rstn_export;          
wire        busy_altgxb_reconfig;      
wire [63:0] test_out;                  
wire [4:0]  reconfig_fromgxb_0_data;   
wire        reconfig_gxbclk_clk;       
wire        tx_out3;                
wire        tx_out2;                
wire        tx_out1;                
wire        tx_out0;                
wire        clocks_sim_clk500;         
wire        clocks_sim_clk250;         
wire        clocks_sim_clk125;         
wire [39:0] test_in;                   

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

hip_c4gx_gen1x4_qsys pcie_qsys_i(
		.pcie_hard_ip_0_fixedclk_clk              (fixedclk            ),                        
		.pcie_hard_ip_0_pipe_ext_rxpolarity0_ext  (rxpolarity0_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxstatus1_ext    (rxstatus1_ext       ),              
		.pcie_hard_ip_0_pipe_ext_pipe_mode        (pipe_mode           ),                  
		.pcie_hard_ip_0_pipe_ext_rxvalid0_ext     (rxvalid0_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxstatus2_ext    (rxstatus2_ext       ),              
		.pcie_hard_ip_0_pipe_ext_rxvalid1_ext     (rxvalid1_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxelecidle0_ext  (rxelecidle0_ext     ),            
		.pcie_hard_ip_0_pipe_ext_txelecidle0_ext  (txelecidle0_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxelecidle2_ext  (rxelecidle2_ext     ),            
		.pcie_hard_ip_0_pipe_ext_txcompl0_ext     (txcompl0_ext        ),               
		.pcie_hard_ip_0_pipe_ext_powerdown_ext    (powerdown_ext       ),              
		.pcie_hard_ip_0_pipe_ext_rxelecidle1_ext  (rxelecidle1_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxdata2_ext      (rxdata2_ext         ),                
		.pcie_hard_ip_0_pipe_ext_txdata0_ext      (txdata0_ext         ),                
		.pcie_hard_ip_0_pipe_ext_rxdata1_ext      (rxdata1_ext         ),                
		.pcie_hard_ip_0_pipe_ext_txdetectrx_ext   (txdetectrx_ext      ),             
		.pcie_hard_ip_0_pipe_ext_txdata2_ext      (txdata2_ext         ),                
		.pcie_hard_ip_0_pipe_ext_rxelecidle3_ext  (rxelecidle3_ext     ),            
		.pcie_hard_ip_0_pipe_ext_txcompl3_ext     (txcompl3_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxdatak2_ext     (rxdatak2_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txelecidle3_ext  (txelecidle3_ext     ),            
		.pcie_hard_ip_0_pipe_ext_txdatak3_ext     (txdatak3_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txdatak1_ext     (txdatak1_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txelecidle2_ext  (txelecidle2_ext     ),            
		.pcie_hard_ip_0_pipe_ext_txcompl1_ext     (txcompl1_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txdata3_ext      (txdata3_ext         ),                
		.pcie_hard_ip_0_pipe_ext_txdatak2_ext     (txdatak2_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxpolarity1_ext  (rxpolarity1_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxpolarity3_ext  (rxpolarity3_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxpolarity2_ext  (rxpolarity2_ext     ),            
		.pcie_hard_ip_0_pipe_ext_rxdatak3_ext     (rxdatak3_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txdata1_ext      (txdata1_ext         ),                
		.pcie_hard_ip_0_pipe_ext_rxvalid3_ext     (rxvalid3_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxdata0_ext      (rxdata0_ext         ),                
		.pcie_hard_ip_0_pipe_ext_rxdatak1_ext     (rxdatak1_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxstatus0_ext    (rxstatus0_ext       ),              
		.pcie_hard_ip_0_pipe_ext_rate_ext         (rate_ext            ),                   
		.pcie_hard_ip_0_pipe_ext_txcompl2_ext     (txcompl2_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txelecidle1_ext  (txelecidle1_ext     ),            
		.pcie_hard_ip_0_pipe_ext_phystatus_ext    (phystatus_ext       ),              
		.pcie_hard_ip_0_pipe_ext_rxdata3_ext      (rxdata3_ext         ),                
		.pcie_hard_ip_0_pipe_ext_rxvalid2_ext     (rxvalid2_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxdatak0_ext     (rxdatak0_ext        ),               
		.pcie_hard_ip_0_pipe_ext_txdatak0_ext     (txdatak0_ext        ),               
		.pcie_hard_ip_0_pipe_ext_rxstatus3_ext    (rxstatus3_ext       ),              
		.pcie_hard_ip_0_cal_blk_clk_clk           (reconfig_gxbclk_clk ),                     
		.pcie_hard_ip_0_reconfig_togxb_data       (reconfig_togxb_data ),                 
		.pcie_hard_ip_0_pcie_rstn_export          (pcie_rstn_export    ),                    
		.pcie_hard_ip_0_reconfig_busy_busy_altgxb_reconfig(busy_altgxb_reconfig),  
		.pcie_hard_ip_0_test_out_test_out         (test_out               ),                   
		.pcie_hard_ip_0_rx_in_rx_datain_3         (rx_in3                ),                   
		.pcie_hard_ip_0_rx_in_rx_datain_2         (rx_in2                ),                   
		.pcie_hard_ip_0_rx_in_rx_datain_1         (rx_in1                ),                   
		.pcie_hard_ip_0_rx_in_rx_datain_0         (rx_in0                ),                   
		.pcie_hard_ip_0_reconfig_fromgxb_0_data   (reconfig_fromgxb_0_data),             
		.pcie_hard_ip_0_reconfig_gxbclk_clk       (reconfig_gxbclk_clk    ),                 
		.pcie_hard_ip_0_tx_out_tx_dataout_3       (tx_out3               ),                 
		.pcie_hard_ip_0_tx_out_tx_dataout_2       (tx_out2               ),                 
		.pcie_hard_ip_0_tx_out_tx_dataout_1       (tx_out1               ),                 
		.pcie_hard_ip_0_tx_out_tx_dataout_0       (tx_out0               ),                 
		.pcie_hard_ip_0_clocks_sim_clk500_export  (clocks_sim_clk250      ),            
		.pcie_hard_ip_0_clocks_sim_clk250_export  (clocks_sim_clk500      ),            
		.pcie_hard_ip_0_clocks_sim_clk125_export  (clocks_sim_clk125      ),            
		.pcie_hard_ip_0_test_in_test_in           (test_in                ),                     
		.pcie_hard_ip_0_refclk_export             (refclk                 )                    
	);

//==================================
// New modules manually instantiated 
//==================================
wire pll_locked;

gpll gpll_i (
	.areset     (!pcie_rstn),
	.inclk0     (free_50MHz),
	.c0         (reconfig_gxbclk_clk),
	.c1         (fixedclk),
	.locked     (pll_locked)
);

altgxb_reconfig altgxb_reconfig_i (
	.offset_cancellation_reset    (!pll_locked            ),
	.reconfig_clk                 (reconfig_gxbclk_clk    ),
	.reconfig_fromgxb             (reconfig_fromgxb_0_data),
	.busy                         (busy_altgxb_reconfig   ),
	.reconfig_togxb               (reconfig_togxb_data    )
);


endmodule
