// megafunction wizard: %Custom PHY v11.1%
// GENERATION: XML
// xcvr_duplex.v

// 

`timescale 1 ns / 1 ps

module xcvr_duplex #(
        	parameter SELECT_FAMILY     	= "Stratix V",
		parameter pll_refclk_freq 	= "148.5 MHz",
		parameter data_rate 		= "2970 Mbps",
		parameter manual_reset  	= "false",
		parameter operation_mode 	= "Duplex",   //legal value: TX, RX, Duplex
		parameter lanes			= 1,
		parameter plls 			= 1,
		parameter ser_words		= 2,
		parameter pcs_pma_width 	= 20,
		parameter embedded_reset        = 0,
		parameter mgmt_clk_in_mhz	= 150,
		parameter reconfig_pll		= 0
		) (
		input  wire         phy_mgmt_clk,         //       phy_mgmt_clk.clk
		input  wire         phy_mgmt_clk_reset,   // phy_mgmt_clk_reset.reset
		input  wire [8:0]   phy_mgmt_address,     //           phy_mgmt.address
		input  wire         phy_mgmt_read,        //                   .read
		output wire [31:0]  phy_mgmt_readdata,    //                   .readdata
		output wire         phy_mgmt_waitrequest, //                   .waitrequest
		input  wire         phy_mgmt_write,       //                   .write
		input  wire [31:0]  phy_mgmt_writedata,   //                   .writedata
		output wire         tx_cal_busy,          //           tx_ready.export
		output wire         rx_cal_busy,          //           rx_ready.export
		input  wire         pll_ref_clk,          //        pll_ref_clk.clk
		output wire         tx_serial_data,       //     tx_serial_data.export
		input  wire         tx_forceelecidle,     //   tx_forceelecidle.export
		output wire         pll_locked,           //         pll_locked.export
		input  wire         rx_serial_data,       //     rx_serial_data.export
		output wire         rx_is_lockedtoref,    //  rx_is_lockedtoref.export
		output wire         rx_is_lockedtodata,   // rx_is_lockedtodata.export
		output wire         rx_signaldetect,      //    rx_signaldetect.export
		input  wire         rx_bitslip,           //         rx_bitslip.export
		output wire [91:0] reconfig_from_xcvr,    //  reconfig_from_gxb.export
		input  wire [139:0] reconfig_to_xcvr,     //    reconfig_to_gxb.export
		output wire         tx_clkout,            //          tx_clkout.export
		output wire         rx_clkout,            //          rx_clkout.export
		input  wire [19:0]  tx_parallel_data,     //   tx_parallel_data.export
		output wire [19:0]  rx_parallel_data,     //   rx_parallel_data.export
		input wire 	    rx_set_locktodata,
		input wire 	    rx_set_locktoref,
  		//input from reset controller
  		input   wire        tx_analogreset,   // for tx pma
  		input   wire        tx_digitalreset,
  		input   wire        rx_analogreset,   // for rx pma
  		input   wire        rx_digitalreset   // for rx pcs
	);
	
  assign  pll_powerdown = tx_analogreset&&rx_analogreset;
  assign  pll_powerdown_fnl   = pll_powerdown;
  assign  tx_analogreset_fnl  = tx_analogreset;
  assign  tx_digitalreset_fnl = tx_digitalreset;
  assign  rx_analogreset_fnl  = rx_analogreset ;
  assign  rx_digitalreset_fnl = rx_digitalreset;
 
  generate
  begin : gen_xcvr_custom_native
      if (SELECT_FAMILY == "Arria V")
      begin
      av_xcvr_custom_native #(
	.protocol_hint                         ("basic"),
	.operation_mode                        ("Duplex"),
	.pcs_pma_width                         (20),
	.lanes                                 (1),
	.bonded_group_size                     (1),
	.ser_base_factor                       (10),
	.ser_words                             (2),
	.data_rate                             (data_rate),
	.base_data_rate                        (data_rate),
	.tx_bitslip_enable                     ("false"),
	.rx_use_coreclk                        ("false"),
	.tx_use_coreclk                        ("false"),
	.use_8b10b                             ("false"),
	.use_8b10b_manual_control              ("false"),
	.word_aligner_mode                     ("bitslip"),
	.word_aligner_state_machine_datacnt    (1),
	.word_aligner_state_machine_errcnt     (1),
	.word_aligner_state_machine_patterncnt (10),
	.word_aligner_pattern_length           (16),
	.word_align_pattern                    ("1111100111111111"),
	.run_length_violation_checking         (40),
	.use_rate_match_fifo                   (0),
	.rate_match_pattern1                   ("11010000111010000011"),
	.rate_match_pattern2                   ("00101111000101111100"),
	.byte_order_mode                       ("none"),
	.byte_order_pattern                    ("111111011"),
	.byte_order_pad_pattern                ("000000000"),
	.coreclk_0ppm_enable                   ("false"),
	.pll_refclk_cnt                        (1),
	.pll_refclk_freq                       (pll_refclk_freq),
//	.pll_refclk_select                     ("0"),
//	.cdr_refclk_select                     (0),
	.plls                                  (1),
//	.pll_type                              ("CMU"),
//	.pll_select                            (0),
    	.pll_feedback_path                    ("no_compensation"            )
  ) transceiver_core (
    .tx_analogreset             (tx_analogreset_fnl             ),
    .pll_powerdown              (pll_powerdown_fnl              ), 
    .tx_digitalreset            (tx_digitalreset_fnl            ),
    .rx_analogreset             (rx_analogreset_fnl             ),
    .rx_digitalreset            (rx_digitalreset_fnl            ),
    //.tx_cal_busy              (tx_cal_busy                    ),
    //.rx_cal_busy              (rx_cal_busy                    ),
    .pll_ref_clk                (pll_ref_clk                    ),
    .tx_coreclkin               (1'b0                           ),
    .rx_coreclkin               (1'b0                           ),
    .tx_parallel_data           (tx_parallel_data               ),
    .rx_parallel_data           (rx_parallel_data               ),
    .tx_datak                   (2'b00                          ),
    .rx_datak                   (                               ),
    .tx_forcedisp               (2'b00                          ),
    .tx_dispval                 (2'b00                          ),
    .rx_runningdisp             (                               ),
    .rx_serial_data             (rx_serial_data                 ),
    .tx_serial_data             (tx_serial_data                 ),
    .tx_clkout                  (tx_clkout                      ),
    .rx_clkout                  (rx_clkout                      ),
    .rx_recovered_clk           (                               ),
    .rx_enabyteord              (1'b0                           ),
    .rx_bitslip                 (rx_bitslip                     ),
    //MM ports
    .tx_forceelecidle           (tx_forceelecidle               ),
    .tx_invpolarity             (csr_tx_invpolarity             ),
    .tx_bitslipboundaryselect   (1'b0 ),
    .rx_invpolarity             (csr_rx_invpolarity             ),
    .rx_seriallpbken            (csr_phy_loopback_serial        ),
    .rx_set_locktodata          (csr_rx_set_locktodata          ),
    .rx_set_locktoref           (csr_rx_set_locktoref           ),
    .rx_enapatternalign         (csr_rx_enapatternalign         ),
    .rx_bitreversalenable       (csr_rx_bitreversalenable       ),
    .rx_bytereversalenable      (csr_rx_bytereversalenable      ),
    .rx_a1a2size                (csr_rx_a1a2size                ),
    .rx_rlv                     (rx_rlv                         ),
    .rx_patterndetect           (rx_patterndetect               ),
    .rx_syncstatus              (rx_syncstatus                  ),
    .rx_signaldetect            (rx_signaldetect                ),
    .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout    ),
    .rx_errdetect               (rx_errdetect                   ),
    .rx_disperr                 (rx_disperr                     ),
    .rx_rmfifofull              (            ),
    .rx_rmfifoempty             (            ),
    .rx_rmfifodatainserted      (          ),
    .rx_rmfifodatadeleted       (           ),
    .rx_a1a2sizeout             (rx_a1a2sizeout                 ),
    .rx_byteordflag             (                 ),
    .rx_is_lockedtoref          (rx_is_lockedtoref              ),
    .rx_is_lockedtodata         (rx_is_lockedtodata             ),
    .pll_locked                 (pll_locked                     ),
    .rx_phase_comp_fifo_error   (rx_phase_comp_fifo_error_wire  ),
    .tx_phase_comp_fifo_error   (tx_phase_comp_fifo_error_wire  ),
    .reconfig_to_xcvr           (reconfig_to_xcvr               ),
    .reconfig_from_xcvr         (reconfig_from_xcvr             )
  );	  	  
      end
      else
      begin
          // Defaults to "Stratix V"	   
sv_xcvr_custom_native #(
	.device_family                         ("Stratix V"),
	.protocol_hint                         ("basic"),
	.operation_mode                        ("Duplex"),
	.pcs_pma_width                         (20),
	.lanes                                 (1),
	.bonded_group_size                     (1),
	.ser_base_factor                       (10),
	.ser_words                             (2),
	.data_rate                             (data_rate),
	.base_data_rate                        (data_rate),
	.tx_bitslip_enable                     ("false"),
	.rx_use_coreclk                        ("false"),
	.tx_use_coreclk                        ("false"),
	.use_8b10b                             ("false"),
	.use_8b10b_manual_control              ("false"),
	.word_aligner_mode                     ("bitslip"),
	.word_aligner_state_machine_datacnt    (1),
	.word_aligner_state_machine_errcnt     (1),
	.word_aligner_state_machine_patterncnt (10),
	.word_aligner_pattern_length           (16),
	.word_align_pattern                    ("1111100111111111"),
	.run_length_violation_checking         (40),
	.use_rate_match_fifo                   (0),
	.rate_match_pattern1                   ("11010000111010000011"),
	.rate_match_pattern2                   ("00101111000101111100"),
	.byte_order_mode                       ("none"),
	.byte_order_pattern                    ("111111011"),
	.byte_order_pad_pattern                ("000000000"),
	.coreclk_0ppm_enable                   ("false"),
	.pll_refclk_cnt                        (1),
	.pll_refclk_freq                       (pll_refclk_freq),
	.pll_refclk_select                     ("0"),
	.cdr_refclk_select                     (0),
	.plls                                  (1),
	.pll_type                              ("CMU"),
	.pll_select                            (0),
	.pll_reconfig                          (reconfig_pll),
	.channel_interface                     (0),
  //	.tx_ready	(),
  //	.rx_ready	(),	
  .pll_feedback_path                    ("no_compensation"            )
  
  ) transceiver_core (
    .tx_analogreset             (tx_analogreset_fnl             ),
    .pll_powerdown              (pll_powerdown_fnl              ), 
    .tx_digitalreset            (tx_digitalreset_fnl            ),
    .rx_analogreset             (rx_analogreset_fnl             ),
    .rx_digitalreset            (rx_digitalreset_fnl            ),
    .tx_cal_busy                (tx_cal_busy                    ),
    .rx_cal_busy                (rx_cal_busy                    ),
    .pll_ref_clk                (pll_ref_clk                    ),
    .tx_coreclkin               (1'b0                           ),
    .rx_coreclkin               (1'b0                           ),
    .tx_parallel_data           (tx_parallel_data               ),
    .rx_parallel_data           (rx_parallel_data               ),
    .tx_datak                   (2'b00                          ),
    .rx_datak                   (                               ),
    .tx_forcedisp               (2'b00                          ),
    .tx_dispval                 (2'b00                          ),
    .rx_runningdisp             (rx_runningdisp                 ),
    .rx_serial_data             (rx_serial_data                 ),
    .tx_serial_data             (tx_serial_data                 ),
    .tx_clkout                  (tx_clkout                      ),
    .rx_clkout                  (rx_clkout                      ),
    .rx_recovered_clk           (                               ),
    .rx_enabyteord              (1'b0                           ),
    .rx_bitslip                 (rx_bitslip                     ),
    //MM ports
    .tx_forceelecidle           (tx_forceelecidle               ),
    .tx_invpolarity             (csr_tx_invpolarity             ),
    .tx_bitslipboundaryselect   (1'b0 ),
    .rx_invpolarity             (csr_rx_invpolarity             ),
    .rx_seriallpbken            (csr_phy_loopback_serial        ),
    .rx_set_locktodata          (csr_rx_set_locktodata          ),
    .rx_set_locktoref           (csr_rx_set_locktoref           ),
    .rx_enapatternalign         (csr_rx_enapatternalign         ),
    .rx_bitreversalenable       (csr_rx_bitreversalenable       ),
    .rx_bytereversalenable      (csr_rx_bytereversalenable      ),
    .rx_a1a2size                (csr_rx_a1a2size                ),
    .rx_rlv                     (rx_rlv                         ),
    .rx_patterndetect           (rx_patterndetect               ),
    .rx_syncstatus              (rx_syncstatus                  ),
    .rx_signaldetect            (rx_signaldetect                ),
    .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout    ),
    .rx_errdetect               (rx_errdetect                   ),
    .rx_disperr                 (rx_disperr                     ),
    .rx_rmfifofull              (                               ),
    .rx_rmfifoempty             (                               ),
    .rx_rmfifodatainserted      (                               ),
    .rx_rmfifodatadeleted       (                               ),
    .rx_a1a2sizeout             (rx_a1a2sizeout                 ),
    .rx_byteordflag             (                               ),
    .rx_is_lockedtoref          (rx_is_lockedtoref              ),
    .rx_is_lockedtodata         (rx_is_lockedtodata             ),
    .pll_locked                 (pll_locked                     ),
    .rx_phase_comp_fifo_error   (rx_phase_comp_fifo_error_wire  ),
    .tx_phase_comp_fifo_error   (tx_phase_comp_fifo_error_wire  ),
    .reconfig_to_xcvr           (reconfig_to_xcvr               ),
    .reconfig_from_xcvr         (reconfig_from_xcvr             )
  );
      end
  end
  endgenerate

  // Instantiate memory map logic for given number of lanes & PLL's
  // Includes all except PCS
  alt_xcvr_csr_common #(
    .lanes  (lanes),
    .plls   (plls )
  ) csr (
    .clk                              (phy_mgmt_clk                         ),
    .reset                            (phy_mgmt_clk_reset                   ),
    .address                          (phy_mgmt_address                     ),
    .read                             (phy_mgmt_read                        ),
    .write                            (phy_mgmt_write                       ),
    .writedata                        (phy_mgmt_writedata                   ),
    .pll_locked                       (pll_locked                       ),
    .rx_is_lockedtoref                (rx_is_lockedtoref                ),
    .rx_is_lockedtodata               (rx_is_lockedtodata               ),
    .rx_signaldetect                  (rx_signaldetect                  ),
    .reset_controller_tx_ready        (                         ),
    .reset_controller_rx_ready        (                         ),
    .reset_controller_pll_powerdown   (1'b0), // unused
    .reset_controller_tx_digitalreset (1'b0), // unused
    .reset_controller_rx_analogreset  (1'b0), // unused
    .reset_controller_rx_digitalreset (1'b0), // unused
    .readdata                         (phy_mgmt_readdata_common             ),
    .csr_reset_tx_digital             (csr_reset_tx_digital             ),
    .csr_reset_rx_digital             (csr_reset_rx_digital             ),
    .csr_reset_all                    (csr_reset_all                    ),
    .csr_pll_powerdown                (csr_pll_powerdown                ),
    .csr_tx_digitalreset              (csr_tx_digitalreset              ),
    .csr_rx_analogreset               (csr_rx_analogreset               ),
    .csr_rx_digitalreset              (csr_rx_digitalreset              ),
    .csr_phy_loopback_serial          (csr_phy_loopback_serial          ),
    .csr_rx_set_locktoref             (csr_rx_set_locktoref             ),
    .csr_rx_set_locktodata            (csr_rx_set_locktodata            )
  );

  
  // generate waitrequest for 'top' channel
  altera_wait_generate top_wait (
    .rst            (phy_mgmt_clk_reset   ),
    .clk            (phy_mgmt_clk         ),
    .launch_signal  (phy_mgmt_read        ),
    .wait_req       (phy_mgmt_waitrequest )
  );

  // Instantiate PCS memory map logic for given number of lanes
  alt_xcvr_csr_pcs8g #(
    .lanes  (lanes    ),
    .words  (ser_words)
  ) csr_pcs (
    .clk                          (phy_mgmt_clk                     ),
    .reset                        (phy_mgmt_clk_reset               ),
    .address                      (phy_mgmt_address                 ),
    .read                         (phy_mgmt_read                    ),
    .write                        (phy_mgmt_write                   ),
    .writedata                    (phy_mgmt_writedata               ),
    .readdata                     (phy_mgmt_readdata_pcs            ),
    .rx_clk                       (rx_clkout                	),
    .tx_clk                       (tx_clkout               	),
    .rx_patterndetect             (rx_patterndetect             ),
    .rx_syncstatus                (rx_syncstatus                ),
    .rlv                          (rx_rlv                       ),
    .rx_phase_comp_fifo_error     (rx_phase_comp_fifo_error_wire),
    .tx_phase_comp_fifo_error     (tx_phase_comp_fifo_error_wire),
    .rx_errdetect                 (rx_errdetect                 ),
    .rx_disperr                   (rx_disperr                   ),
    .rx_bitslipboundaryselectout  (rx_bitslipboundaryselectout  ),
    .rx_a1a2sizeout               (rx_a1a2sizeout               ),
    .csr_tx_invpolarity           (csr_tx_invpolarity           ),
    .csr_rx_invpolarity           (csr_rx_invpolarity           ),
    .csr_rx_bitreversalenable     (csr_rx_bitreversalenable     ),
    .csr_rx_bitslip               (/*unused*/                   ),
    .csr_rx_enapatternalign       (csr_rx_enapatternalign       ),
    .csr_rx_bytereversalenable    (csr_rx_bytereversalenable    ),
    .csr_rx_a1a2size              (csr_rx_a1a2size              ),
    .csr_tx_bitslipboundaryselect (csr_tx_bitslipboundaryselect )
  );

  // combine readdata output from both CSR blocks
  // each decodes non-overlapping addresses, and outputs "11..111" for undecoded addresses,
  // so an AND is sufficient
  assign phy_mgmt_readdata = phy_mgmt_readdata_common & phy_mgmt_readdata_pcs;
    assign  reset_controller_pll_powerdown    = 1'b0;
    assign  reset_controller_tx_digitalreset  = 1'b0;
    assign  reset_controller_rx_analogreset   = 1'b0;
    assign  reset_controller_rx_digitalreset  = 1'b0;
    assign  tx_ready = 1'b0;
    assign  rx_ready = 1'b0;

endmodule
