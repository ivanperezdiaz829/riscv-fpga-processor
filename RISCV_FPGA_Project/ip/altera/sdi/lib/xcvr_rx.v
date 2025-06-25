// megafunction wizard: %Custom PHY v11.1%
// GENERATION: XML
// xcvr_rx.v

// 

`timescale 1 ps / 1 ps
module xcvr_rx (
        input  wire         phy_mgmt_clk,         //       phy_mgmt_clk.clk
        input  wire         phy_mgmt_clk_reset,   // phy_mgmt_clk_reset.reset
        input  wire [8:0]   phy_mgmt_address,     //           phy_mgmt.address
        input  wire         phy_mgmt_read,        //                   .read
        output wire [31:0]  phy_mgmt_readdata,    //                   .readdata
        output wire         phy_mgmt_waitrequest, //                   .waitrequest
        input  wire         phy_mgmt_write,       //                   .write
        input  wire [31:0]  phy_mgmt_writedata,   //                   .writedata
        input  wire         pll_ref_clk,          //        pll_ref_clk.clk
        input  wire         rx_serial_data,       //     rx_serial_data.export
        output wire         rx_is_lockedtoref,    //  rx_is_lockedtoref.export
        output wire         rx_is_lockedtodata,   // rx_is_lockedtodata.export
        output wire         rx_signaldetect,      //    rx_signaldetect.export
        input  wire         rx_bitslip,           //         rx_bitslip.export
        output wire         rx_clkout,            //          rx_clkout.export
        output wire [19:0]  rx_parallel_data,      //   rx_parallel_data.export

        input wire      rx_set_locktodata,
        input wire      rx_set_locktoref,
        //input from reset controller
        input   wire        pll_powerdown,
	input  wire        rx_digitalreset,      //    rx_digitalreset.export
	input  wire        rx_analogreset,       //     rx_analogreset.export
	output wire        rx_cal_busy,          //        rx_cal_busy.export
	output wire [45:0] reconfig_from_xcvr,   // reconfig_from_xcvr.reconfig_from_xcvr
	input  wire [69:0] reconfig_to_xcvr      //   reconfig_to_xcvr.reconfig_to_xcvr
    );

        parameter SELECT_FAMILY     = "Stratix V";
        parameter pll_refclk_freq   = "148.5 MHz";
        parameter data_rate         = "2970 Mbps";
        parameter manual_reset      = "false";
        parameter operation_mode    = "RX"; //legal value: TX, RX, Duplex
        parameter lanes             = 1;
        parameter plls              = 1;
        parameter ser_words         = 2;
        parameter mgmt_clk_in_mhz   = 250;
        parameter ser_base_factor   = 10;
	parameter reconfig_pll      = 0;

        wire [lanes-1:0]            rx_rlv_wire;
        wire [ser_words*lanes-1:0]  rx_patterndetect_wire;
        wire [ser_words*lanes-1:0]  rx_syncstatus_wire;
        wire [lanes-1:0]            rx_rmfifofull_wire;
        wire [lanes-1:0]            rx_rmfifoempty_wire;
        wire [ser_words*lanes-1:0]  rx_rmfifodatainserted_wire;
        wire [ser_words*lanes-1:0]  rx_rmfifodatadeleted_wire;
        wire [lanes-1:0]            rx_is_lockedtoref_wire;
        wire [lanes-1:0]            rx_is_lockedtodata_wire;
        wire [ plls-1:0]            pll_locked_wire;
        wire [ plls-1:0]            pll_locked_wire_fake; // mimic pll_locked for RX only case, for reset controller to function
        wire [lanes-1:0]            rx_phase_comp_fifo_error_wire;
        wire [lanes-1:0]            tx_phase_comp_fifo_error_wire;

        //////////////////////////////////
        // Control & status register map (CSR) outputs
        //////////////////////////////////
        wire                csr_reset_tx_digital;         //to reset controller
        wire                csr_reset_rx_digital;         //to reset controller
        wire                csr_reset_all;                //to reset controller
        wire                csr_pll_powerdown;            //to xcvr instance
        wire [lanes-1:0]    csr_tx_digitalreset;          //to xcvr instance
        wire [lanes-1:0]    csr_rx_analogreset;           //to xcvr instance
        wire [lanes-1:0]    csr_rx_digitalreset;          //to xcvr instance
        wire [lanes-1:0]    csr_phy_loopback_serial;      //to xcvr instance
        wire [lanes-1:0]    csr_tx_invpolarity;           //to xcvr instance
        wire [lanes-1:0]    csr_rx_invpolarity;           //to xcvr instance
        wire [lanes-1:0]    csr_rx_set_locktoref;         //to xcvr instance
        wire [lanes-1:0]    csr_rx_set_locktodata;        //to xcvr instance
        wire [lanes-1:0]    csr_rx_enapatternalign;       //to xcvr instance
        wire [lanes-1:0]    csr_rx_bitreversalenable;     //to xcvr instance
        wire [lanes-1:0]    csr_rx_bytereversalenable;    //to xcvr instance
        wire [lanes-1:0]    csr_rx_a1a2size;              //to xcvr instance
        wire [lanes*5-1:0]  csr_tx_bitslipboundaryselect; //to xcvr instance

        // readdata output from both CSR blocks
        wire [31:0]     phy_mgmt_readdata_common;
        wire [31:0]     phy_mgmt_readdata_pcs;


        //////////////////////////////////
        //reset controller outputs
        //////////////////////////////////
        wire        reset_controller_tx_ready;
        wire        reset_controller_rx_ready;
        wire        reset_controller_pll_powerdown;
        wire        reset_controller_tx_digitalreset;
        wire        reset_controller_rx_analogreset;
        wire        reset_controller_rx_digitalreset;
        wire        reset_controller_manual_mode;

  		//wire        rx_cal_busy;  // Reconfig_busy signal from external reconfig


        //////////////////////////////////
        // XCVR inputs
        //////////////////////////////////
        wire                                            tx_analogreset          = 0;
        wire    [lanes-1:0]                             tx_digitalreset         = 0;
        wire    [ser_words*ser_base_factor*lanes-1:0]   tx_parallel_data        = 0;
        tri0    [lanes-1:0]                             tx_forceelecidle        = 0;

        //////////////////////////////////
        // XCVR outputs
        //////////////////////////////////
        wire    [ser_words*lanes-1:0]                   rx_datak                        ;
        wire    [lanes-1:0]                             tx_serial_data                  ;
        wire    [lanes-1:0]                             rx_recovered_clk                ;
        wire    [lanes*5-1:0]                           rx_bitslipboundaryselectout     ;
        wire    [ser_words*lanes-1:0]                   rx_errdetect                    ;
        wire    [ser_words*lanes-1:0]                   rx_disperr                      ;
        wire    [ser_words*lanes-1:0]                   rx_runningdisp                  ;
        wire    [lanes-1:0]                             rx_byteordflag                  ;
        wire    [ser_words*lanes-1:0]                   rx_a1a2sizeout                  ;

  generate
  begin : gen_xcvr_custom_native
      if (SELECT_FAMILY == "Arria V")
      begin
          av_xcvr_custom_native #(
                        .protocol_hint                         ("basic"),
                        .operation_mode                        (operation_mode),
			.pcs_pma_width                         (20),
                        .lanes                                 (lanes),
                        .bonded_group_size                     (1),
                        .ser_base_factor                       (ser_base_factor),
                        .ser_words                             (ser_words),
                        .data_rate                             (data_rate),
			.base_data_rate                        (data_rate),
                        .pll_refclk_freq                       (pll_refclk_freq),
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
                     //   .use_double_data_mode                  ("false"),
                        .coreclk_0ppm_enable                   ("false"),
                        .pll_refclk_cnt                        (1),
                        .plls                                  (plls),
    			.pll_feedback_path                    ("no_compensation"            )
          ) transceiver_core (
                    .tx_analogreset             (tx_analogreset                 ),
                    .pll_powerdown              (1'b0                           ),
                    .tx_digitalreset            (tx_digitalreset                ),
                    .rx_analogreset             (rx_analogreset                 ),
                    .rx_digitalreset            (rx_digitalreset                ),
                    .pll_ref_clk                (pll_ref_clk                    ),
                    .tx_coreclkin               (1'b0                           ),
                    .rx_coreclkin               (1'b0                           ),
                    .tx_parallel_data           (tx_parallel_data               ),
                    .rx_parallel_data           (rx_parallel_data               ),
                    .tx_datak                   (2'b00                          ),
                    .rx_datak                   (                       ),
                    .tx_forcedisp               (2'b00                          ),
                    .tx_dispval                 (2'b00                          ),
                    .rx_runningdisp             (rx_runningdisp                 ),
                    .rx_serial_data             (rx_serial_data                 ),
                    .tx_serial_data             (tx_serial_data                 ),
                    .tx_clkout                  (tx_clkout                      ),
                    .rx_clkout                  (rx_clkout                      ),
                    .rx_recovered_clk           (               ),
                    .rx_enabyteord              (1'b0                           ),
                    .rx_bitslip                 (rx_bitslip                     ),
                    //MM ports
                    .tx_forceelecidle           (tx_forceelecidle               ),
                    .tx_invpolarity             (csr_tx_invpolarity             ),
                    .tx_bitslipboundaryselect   (1'b0                           ),
                    .rx_invpolarity             (csr_rx_invpolarity             ),
                    .rx_seriallpbken            (csr_phy_loopback_serial        ),
                    .rx_set_locktodata          (rx_set_locktodata              ),
                    .rx_set_locktoref           (rx_set_locktoref               ),
                    .rx_enapatternalign         (csr_rx_enapatternalign         ),
                    .rx_bitreversalenable       (csr_rx_bitreversalenable       ),
                    .rx_bytereversalenable      (csr_rx_bytereversalenable      ),
                    .rx_a1a2size                (csr_rx_a1a2size                ),
                    .rx_rlv                     (rx_rlv_wire                    ),
                    .rx_patterndetect           (rx_patterndetect_wire          ),
                    .rx_syncstatus              (rx_syncstatus_wire             ),
                    .rx_signaldetect            (rx_signaldetect                ),
                    .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout    ),
                    .rx_errdetect               (rx_errdetect                   ),
                    .rx_disperr                 (rx_disperr                     ),
                    .rx_rmfifofull              (             ),
                    .rx_rmfifoempty             (            ),
                    .rx_rmfifodatainserted      (     ),
                    .rx_rmfifodatadeleted       (      ),
                    .rx_a1a2sizeout             (rx_a1a2sizeout                 ),
                    .rx_byteordflag             (                 ),
                    .rx_is_lockedtoref          (rx_is_lockedtoref_wire         ),
                    .rx_is_lockedtodata         (rx_is_lockedtodata_wire        ),
                    .pll_locked                 (pll_locked_wire                ),
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
                .operation_mode                        ("RX"),
		.pcs_pma_width                         (20),
		.lanes                                 (1),
                .bonded_group_size                     (1),
		.bonded_mode                           ("xN"),
		.ser_base_factor                       (10),
		.ser_words                             (2),
                .data_rate                             (data_rate),
 		.base_data_rate                        (data_rate),
                .pll_refclk_freq                       (pll_refclk_freq),
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
			.pll_refclk_select                     ("0"),
			.cdr_refclk_select                     (0),
			.plls                                  (1),
			.pll_type                              ("CMU"),
			.pll_select                            (0),
			.pll_reconfig						   (reconfig_pll),
			.channel_interface                     (0)
          ) transceiver_core (
                    .tx_analogreset             (tx_analogreset                 ),
                    .pll_powerdown              (1'b0                           ),
                    .tx_digitalreset            (tx_digitalreset                ),
                    .rx_analogreset             (rx_analogreset                 ),
                    .rx_digitalreset            (rx_digitalreset                ),
		    .rx_cal_busy                (rx_cal_busy                    ),
                    .pll_ref_clk                (pll_ref_clk                    ),
                    .tx_coreclkin               (1'b0                           ),
                    .rx_coreclkin               (1'b0                           ),
                    .tx_parallel_data           (tx_parallel_data               ),
                    .rx_parallel_data           (rx_parallel_data               ),
                    .tx_datak                   (2'b00                          ),
                    .rx_datak                   (                       ),
                    .tx_forcedisp               (2'b00                          ),
                    .tx_dispval                 (2'b00                          ),
                    .rx_runningdisp             (rx_runningdisp                 ),
                    .rx_serial_data             (rx_serial_data                 ),
                    .tx_serial_data             (tx_serial_data                 ),
                    .tx_clkout                  (tx_clkout                      ),
                    .rx_clkout                  (rx_clkout                      ),
                    .rx_recovered_clk           (               ),
                    .rx_enabyteord              (1'b0                           ),
                    .rx_bitslip                 (rx_bitslip                     ),
                    //MM ports
                    .tx_forceelecidle           (tx_forceelecidle               ),
                    .tx_invpolarity             (csr_tx_invpolarity             ),
                    .tx_bitslipboundaryselect   (1'b0                           ),
                    .rx_invpolarity             (csr_rx_invpolarity             ),
                    .rx_seriallpbken            (csr_phy_loopback_serial        ),
                    .rx_set_locktodata          (rx_set_locktodata              ),
                    .rx_set_locktoref           (rx_set_locktoref               ),
                    .rx_enapatternalign         (csr_rx_enapatternalign         ),
                    .rx_bitreversalenable       (csr_rx_bitreversalenable       ),
                    .rx_bytereversalenable      (csr_rx_bytereversalenable      ),
                    .rx_a1a2size                (csr_rx_a1a2size                ),
                    .rx_rlv                     (rx_rlv_wire                    ),
                    .rx_patterndetect           (rx_patterndetect_wire          ),
                    .rx_syncstatus              (rx_syncstatus_wire             ),
                    .rx_signaldetect            (rx_signaldetect                ),
                    .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout    ),
                    .rx_errdetect               (rx_errdetect                   ),
                    .rx_disperr                 (rx_disperr                     ),
                    .rx_rmfifofull              (             ),
                    .rx_rmfifoempty             (            ),
                    .rx_rmfifodatainserted      (     ),
                    .rx_rmfifodatadeleted       (      ),
                    .rx_a1a2sizeout             (rx_a1a2sizeout                 ),
                    .rx_byteordflag             (                 ),
                    .rx_is_lockedtoref          (rx_is_lockedtoref_wire         ),
                    .rx_is_lockedtodata         (rx_is_lockedtodata_wire        ),
                    .pll_locked                 (pll_locked_wire                ),
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
            .clk                              (phy_mgmt_clk                     ),
            .reset                            (phy_mgmt_clk_reset               ),
            .address                          (phy_mgmt_address                 ),
            .read                             (phy_mgmt_read                    ),
            .write                            (phy_mgmt_write                   ),
            .writedata                        (phy_mgmt_writedata               ),
            .pll_locked                       (pll_locked_wire                  ),
            .rx_is_lockedtoref                (rx_is_lockedtoref_wire           ),
            .rx_is_lockedtodata               (rx_is_lockedtodata_wire          ),
            .rx_signaldetect                  (rx_signaldetect                  ),
            .reset_controller_tx_ready        (reset_controller_tx_ready        ),
            .reset_controller_rx_ready        (reset_controller_rx_ready        ),
            .reset_controller_pll_powerdown   (reset_controller_pll_powerdown   ),
            .reset_controller_tx_digitalreset (reset_controller_tx_digitalreset ),
            .reset_controller_rx_analogreset  (reset_controller_rx_analogreset  ),
            .reset_controller_rx_digitalreset (reset_controller_rx_digitalreset ),
            .readdata                         (phy_mgmt_readdata_common         ),
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
            .clk                          (phy_mgmt_clk                 ),
            .reset                        (phy_mgmt_clk_reset           ),
            .address                      (phy_mgmt_address             ),
            .read                         (phy_mgmt_read                ),
            .write                        (phy_mgmt_write               ),
            .writedata                    (phy_mgmt_writedata           ),
            .readdata                     (phy_mgmt_readdata_pcs        ),
            .rx_clk                       (rx_clkout                    ),
            .tx_clk                       (tx_clkout                    ),
            .rx_patterndetect             (rx_patterndetect_wire        ),
        .rx_syncstatus                (rx_syncstatus_wire           ),
        .rlv                          (rx_rlv_wire                  ),
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

  // Mimic pll_locked for RX-only case
  assign pll_locked_wire_fake = ((operation_mode == "Rx") || (operation_mode =="RX"))? 1'b1 : pll_locked_wire;

//  sv_reconfig_bundle_to_ip  #(
//      		.native_ifs         (2)
//  ) sv_reconfig_bundle_to_ip_inst (
//		.reconfig_to_xcvr (reconfig_to_xcvr ), // all inputs from reconfig block to native xcvr reconfig ports
//		.reconfig_busy    (reconfig_busy    )
//  );

  //using TGX reset lego for now
  // Put reset controller into manual mode either when the manual reset parameter is "true"
  // or when we are not in auto lock mode
  assign  reset_controller_manual_mode = (manual_reset == "true") ? 1'b1
                                        : (csr_rx_set_locktoref || csr_rx_set_locktodata);
  alt_reset_ctrl_tgx_cdrauto #(
        .sys_clk_in_mhz (mgmt_clk_in_mhz)
  ) reset_controller (
    		//input
		.clock              (phy_mgmt_clk                     ),
		.reset_all          (csr_reset_all                    ),
		.reset_tx_digital   (csr_reset_tx_digital             ),
		.reset_rx_digital   (csr_reset_rx_digital             ),
		.powerdown_all      (phy_mgmt_clk_reset               ),
		.pll_is_locked      (pll_locked_wire_fake             ),
		.tx_cal_busy	(tx_cal_busy			),
		.rx_cal_busy         (rx_cal_busy                    ),
		.rx_is_lockedtodata (& rx_is_lockedtodata             ),
		.manual_mode        (reset_controller_manual_mode     ),

            //output
        .tx_ready           (reset_controller_tx_ready        ),
        .rx_ready           (reset_controller_rx_ready        ),
        .pll_powerdown      (reset_controller_pll_powerdown   ),
        .tx_digitalreset    (reset_controller_tx_digitalreset ),
        .rx_analogreset     (reset_controller_rx_analogreset  ),
        .rx_digitalreset    (reset_controller_rx_digitalreset ),
        .gxb_powerdown      (/*TODO*/                         )
  );
  
  //conduit status output
  assign pll_locked         = pll_locked_wire;
  assign rx_is_lockedtodata = rx_is_lockedtodata_wire;
  assign rx_is_lockedtoref  = rx_is_lockedtoref_wire;
  assign rx_ready           = reset_controller_rx_ready;
  assign tx_ready           = reset_controller_tx_ready;

 
endmodule
