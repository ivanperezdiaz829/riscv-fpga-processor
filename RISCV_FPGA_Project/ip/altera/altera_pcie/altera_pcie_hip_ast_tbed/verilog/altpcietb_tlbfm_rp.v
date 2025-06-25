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


`timescale 1 ns / 1 ps
//-----------------------------------------------------------------------------
// Project       : PCI Express MegaCore TL BFM
//-----------------------------------------------------------------------------
// File          : altpcietb_tlbfm_rp.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description : Transaction Layer Root Port BFM top level
//-----------------------------------------------------------------------------

module altpcietb_tlbfm_rp # (
    parameter pll_refclk_freq_hwtcl = "100 MHz",          // ref clk for DUT
    parameter pld_clk_MHz           = 625,                // pld clock frequency x 10
    parameter serial_sim_hwtcl      = 1,
    parameter pcie_rate             = "Gen1 (2.5 Gbps)",
    parameter pcie_number_of_lanes  = "x8",
    parameter deemphasis_enable     = "false",
    parameter millisecond_cycle_count_hwtcl = 20'd248500, // Same as DUT setting
    parameter use_crc_forwarding_hwtcl = 0,
    parameter ecrc_check_capable_hwtcl = 0,
    parameter ecrc_gen_capable_hwtcl   = 0,
    parameter bfm_pcie_delay           = 32'd200,         // Delay (in ns) to add to the BFM's fc/datapaths
    parameter apps_type_hwtcl          = 2                // "1:Link training and configuration", "2:Link training, configuration and chaining DMA","3:Link training, configuration and target", 4: avmm 64bit example design, 5: avmm 128bit example design
) (

   input  [1000:0]  tlbfm_in,
   output [1000:0]  tlbfm_out,
   output  [31:0]   dut_test_in,
   output           dut_pin_perst,
   output           dut_npor,
   output           dut_refclk,
   output           simu_mode_pipe
   );



 //  localparam  NUMCLKS_128ns = millisecond_cycle_count_hwtcl * 128/994 * 1/1000;
 //  localparam  NUMCLKS_1us   = millisecond_cycle_count_hwtcl/994;
   localparam  PLD_CLK_PS = 10000000/pld_clk_MHz;              // integer
   localparam  NUMCLKS_128ns = (pld_clk_MHz==625) ? 32'd8 :
                               (pld_clk_MHz==1250) ? 32'd16 : 32'd32;    // number of dut clks in 128ns
   localparam  NUMCLKS_1us   = (pld_clk_MHz==625) ? 32'd62 :
                               (pld_clk_MHz==1250) ? 32'd125 : 32'd250;  // number of dut clks in 1us

   // ECRC
   localparam ECRC_RX_ENA = (ecrc_gen_capable_hwtcl==1) ? 1'b1 : 1'b0;
   localparam ECRC_TX_ENA = ((use_crc_forwarding_hwtcl==1) & (ecrc_check_capable_hwtcl)) ? 1'b1 : 1'b0;
   localparam ECRC_TX_FORWARD = (use_crc_forwarding_hwtcl==1) ? 1'b1 : 1'b0;



   wire           vcintf64_rx_st_ready;
   wire           vcintf64_rx_st_sop;
   wire           vcintf64_rx_st_valid;
   wire           vcintf64_rx_st_eop;
   wire           vcintf64_rx_st_empty;
   wire [63:0]    vcintf64_rx_st_data;
   wire [7:0]     vcintf64_rxbuf_st_be;
   wire           vcintf64_tx_st_sop;
   wire           vcintf64_tx_st_valid;
   wire           vcintf64_tx_st_eop;
   wire           vcintf64_tx_st_empty;
   wire [63:0]    vcintf64_tx_st_data;
   wire [35:0]    vcintf64_tx_st_cred;

   reg            vcintf_rst;
   wire           vcintf_ena;

   wire          dut_clk;
   wire          dut_rstn;

   // pll wires
   wire          avst64_clk_locked;
   wire          avst64_clk;
   wire          bfm_reset_n;
   reg           avst64_rstn;
   reg           avst64_rstn_meta;
   wire [4:0]    pll_unused_vec;

   wire[3:0]     int_status;


   /***********************************************
      DUT top level pins: refclk, rstn, test_in
   ************************************************/
  assign simu_mode_pipe   =  (serial_sim_hwtcl==1)?1'b0:1'b1;

   // refclk
   //--------
   altpcietb_rst_clk #(
         .REFCLK_HALF_PERIOD((pll_refclk_freq_hwtcl== "100 MHz")?5000:4000)
        ) rst_clk_gen (
       .pcie_rstn          (dut_npor),
       .ref_clk_out        (dut_refclk),
       .rp_rstn            ( )
       );

   // reset
   //-------
   assign dut_pin_perst = dut_npor;     //TBD

   // test_in
   //----------
   assign dut_test_in[31 : 10] = 22'h0;
   assign dut_test_in[9]       = 1'b1;
   assign dut_test_in[8 : 4]   = 5'h0;
   assign dut_test_in[3]       = 1'b0;
   assign dut_test_in[2 : 1]   = 2'h0;
   //Bit 0: Speed up the simulation but making counters faster than normal
   assign dut_test_in[0]       = 1'b1;

   // reset for BFM
   //-----------------
   assign bfm_reset_n = dut_rstn & avst64_clk_locked;

   always @ (posedge avst64_clk or negedge bfm_reset_n) begin
      if (~bfm_reset_n) begin
          avst64_rstn_meta <= 1'b0;
          avst64_rstn      <= 1'b0;
      end
      else begin
          avst64_rstn_meta <= 1'b1;
          avst64_rstn      <= avst64_rstn_meta;
      end
   end

 /*****************************************
   PLL - generates DUTx4 clock for TLBFM
 ******************************************/

   altpll # ( .clk0_multiply_by(4), .clk0_divide_by(1), .clk0_duty_cycle(50),
              .bandwidth_type("CUSTOM"), .inclk0_input_frequency(PLD_CLK_PS),
              .clk0_phase_shift(0), .compensate_clock("CLK0"),
              .intended_device_family ("Stratix GX"), .invalid_lock_multiplier(5),
              .lpm_type ("altpll"), .operation_mode("NORMAL"), .pll_type("ENHANCED"),
              .spread_frequency(0), .valid_lock_multiplier(1)
      ) pll_bfmclk ( .inclk({1'b0, dut_clk}), .clk({pll_unused_vec[4:0], avst64_clk}), .locked(avst64_clk_locked),  .areset(1'b0),
                     .clkena(6'h1), .extclkena(4'h0),
                     // unused ports
                     .configupdate(1'b0), .scanclkena(1'b0), .icdrclk(),
                     .phasecounterselect(4'h0), .phaseupdown(1'b0), .phasestep(1'b0),
                     .fbmimicbidir(), .phasedone(), .vcooverrange(), .vcounderrange(),
                     .fbout(), .fref(),
                     .scanclk (), .pllena (), .sclkout1 (), .sclkout0 (),
                     .fbin (), .scandone (), .clkloss (), .extclk (),
                     .clkswitch (), .pfdena (), .scanaclr (), .clkbad (),
                     .scandata (), .enable1 (), .scandataout (), .enable0 (),
                     .scanwrite (), .activeclock (), .scanread () );


  /**********************************************
    BFM Reset
      - allow BFM to operate after
        DL is up, and link is at target speed
  ***********************************************/
    initial begin
      vcintf_rst = 1'b1;
      wait (dut_npor == 1'b1);
      wait (vcintf_ena == 1'b0);
      wait (vcintf_ena == 1'b1);
      #1000;
      vcintf_rst = 1'b0;
    end



   /*********************************************
       S5 Gasket - converts S5 signal format
                   to VC intf format
   **********************************************/
   altpcietb_tlbfm_intf # (
       .pll_refclk_freq_hwtcl (pll_refclk_freq_hwtcl),   // ref clk for DUT
       .pcie_rate             (pcie_rate),
       .pcie_number_of_lanes  (pcie_number_of_lanes),
       .deemphasis_enable     (deemphasis_enable),
       .bfm_pcie_delay        (bfm_pcie_delay),
       .NUMCLKS_1us           (NUMCLKS_1us),
       .NUMCLKS_128ns         (NUMCLKS_128ns)            // # of DUT clocks in 128ns
   ) dut_bfm_intf (
     .avst64_clk               (avst64_clk             ),
     .avst64_rstn              (avst64_rstn            ),
     .dut_clk                  (dut_clk                ),
     .dut_rstn                 (dut_rstn               ),
     .tlbfm_in                 (tlbfm_in               ),
     .tlbfm_out                (tlbfm_out              ),
     .vcintf_ena               (vcintf_ena             ),
     .vcintf64_rx_st_ready     (vcintf64_rx_st_ready    ),
     .vcintf64_rx_st_sop       (vcintf64_rx_st_sop      ),
     .vcintf64_rx_st_valid     (vcintf64_rx_st_valid    ),
     .vcintf64_rx_st_eop       (vcintf64_rx_st_eop      ),
     .vcintf64_rx_st_empty     (vcintf64_rx_st_empty    ),
     .vcintf64_rx_st_data      (vcintf64_rx_st_data     ),
     .vcintf64_rxbuf_st_be     (vcintf64_rxbuf_st_be    ),
     .vcintf64_tx_st_sop       (vcintf64_tx_st_sop      ),
     .vcintf64_tx_st_valid     (vcintf64_tx_st_valid    ),
     .vcintf64_tx_st_eop       (vcintf64_tx_st_eop      ),
     .vcintf64_tx_st_empty     (vcintf64_tx_st_empty    ),
     .vcintf64_tx_st_data      (vcintf64_tx_st_data     ),
     .vcintf64_tx_st_cred      (vcintf64_tx_st_cred     )
  );


  /******************************************************************************
      VC Interface:  Signalling interface for single virtual channel.
                     Transfers data between signal interface and system memory.
  *******************************************************************************/
   altpcietb_bfm_vc_intf_64 #(
       .VC_NUM              (0),
       .ECRC_RX_ENA         (ECRC_RX_ENA),
       .ECRC_TX_ENA         (ECRC_TX_ENA),
       .ECRC_TX_FORWARD     (ECRC_TX_FORWARD),
       .ENA_AVST_ADDR_ALIGN (1'b0),  // must be 0 for TL BFM mode
       .TL_BFM_MODE         (1'b1)

   ) vc_intf (
       .clk_in        (avst64_clk),
       .rstn          (~vcintf_rst),
       .rx_mask       ( ),
       .rx_be         (vcintf64_rxbuf_st_be),
       .rx_ecrc_err   (1'b0),
       .tx_cred       (vcintf64_tx_st_cred),
       .cfg_io_bas    (20'h0),
       .cfg_np_bas    (12'h0),
       .cfg_pr_bas    (44'h0),
       .rx_st_sop     (vcintf64_rx_st_sop),
       .rx_st_eop     (vcintf64_rx_st_eop),
       .rx_st_empty   (vcintf64_rx_st_empty),
       .rx_st_data    (vcintf64_rx_st_data),
       .rx_st_valid   (vcintf64_rx_st_valid),
       .rx_st_ready   (vcintf64_rx_st_ready),
       .tx_st_sop     (vcintf64_tx_st_sop),
       .tx_st_eop     (vcintf64_tx_st_eop),
       .tx_st_empty   (vcintf64_tx_st_empty),
       .tx_st_data    (vcintf64_tx_st_data),
       .tx_st_valid   (vcintf64_tx_st_valid),
       .tx_st_ready   (1'b1),
       .tx_fifo_empty (1'b1),
       .tx_err        (),
       .int_status    (int_status)
   );


   /*******************************************************************
     Memory blocks used to transfer info between driver & vcintf
   ********************************************************************/
   altpcietb_bfm_log_common       bfm_log_common      (.dummy_out (bfm_log_common_dummy_out));
   altpcietb_bfm_req_intf_common  bfm_req_intf_common (.dummy_out (bfm_req_intf_common_dummy_out));
   altpcietb_bfm_shmem_common     bfm_shmem_common    (.dummy_out (bfm_shmem_common_dummy_out));

   /***************
       Driver
   ***************/
   generate
       if (apps_type_hwtcl==3) begin: g_bfm_downstream_driver
           altpcietb_bfm_driver_downstream # (
                .TEST_LEVEL            (1),
                .TL_BFM_MODE           (1'b1),
                .TL_BFM_RP_CAP_REG     (32'h42),  // rp, cap ver 2
                .TL_BFM_RP_DEV_CAP_REG (32'h05)   // support max payld size
           )
              bfm_driver_downstream(
                 .clk_in    (avst64_clk),
                 .INTA      (int_status[0]),
                 .INTB      (int_status[1]),
                 .INTC      (int_status[2]),
                 .INTD      (int_status[3]),
                 .rstn      (~vcintf_rst),   // wait for DUT DL/PL emulation to finish
                 .dummy_out ()
            );
       end
       else if ((apps_type_hwtcl==4) | (apps_type_hwtcl==5)) begin: g_bfm_avmm_driver
           altpcietb_bfm_driver_avmm # (
                .TEST_LEVEL            (1),
                .TL_BFM_MODE           (1'b1),
                .TL_BFM_RP_CAP_REG     (32'h42),  // rp, cap ver 2
                .TL_BFM_RP_DEV_CAP_REG (32'h05),   // support max payld size
                .APPS_TYPE_HWTCL       (apps_type_hwtcl)   // 4=avmm64, 5=avmm-128
           )
              bfm_driver_avmm(
                 .clk_in    (avst64_clk),
                 .INTA      (int_status[0]),
                 .INTB      (int_status[1]),
                 .INTC      (int_status[2]),
                 .INTD      (int_status[3]),
                 .rstn      (~vcintf_rst),   // wait for DUT DL/PL emulation to finish
                 .dummy_out ()
           );
       end
       else if (apps_type_hwtcl==11) begin: g_bfm_avmm_driver
           altpcietb_bfm_driver_simple_ep_downstream # (
                .TL_BFM_MODE           (1'b1),
                .TL_BFM_RP_CAP_REG     (32'h42),  // rp, cap ver 2
                .TL_BFM_RP_DEV_CAP_REG (32'h05)   // support max payld size
           ) altpcietb_bfm_driver_simple_ep_downstream (
                 .clk_in    (avst64_clk),
                 .INTA      (int_status[0]),
                 .INTB      (int_status[1]),
                 .INTC      (int_status[2]),
                 .INTD      (int_status[3]),
                 .rstn      (~vcintf_rst),   // wait for DUT DL/PL emulation to finish
                 .dummy_out ()
           );
       end
       else begin: g_bfm_cdma_driver
           altpcietb_bfm_driver_chaining # (
                .TEST_LEVEL            (1),
                .USE_CDMA              ((apps_type_hwtcl == 2)?1:0),
                .USE_TARGET            ((apps_type_hwtcl == 2)?1:0),
                .TL_BFM_MODE           (1'b1),
                .TL_BFM_RP_CAP_REG     (32'h42),  // rp, cap ver 2
                .TL_BFM_RP_DEV_CAP_REG (32'h05)   // support max payld size
           )
              bfm_driver_chaining(
                 .clk_in    (avst64_clk),
                 .INTA      (int_status[0]),
                 .INTB      (int_status[1]),
                 .INTC      (int_status[2]),
                 .INTD      (int_status[3]),
                 .rstn      (~vcintf_rst),   // wait for DUT DL/PL emulation to finish
                 .dummy_out ()
            );
       end

    endgenerate


endmodule




