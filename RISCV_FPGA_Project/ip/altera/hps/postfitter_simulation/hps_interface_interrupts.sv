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


module cyclonev_hps_interface_interrupts (
   input  wire [63:0] irq,
   output wire fake_dout,
   output wire h2f_can0_irq,
   output wire h2f_can1_irq,
   output wire h2f_clkmgr_irq,
   output wire h2f_cti_irq0_n,
   output wire h2f_cti_irq1_n,
   output wire h2f_dma_abort_irq,
   output wire h2f_dma_irq0,
   output wire h2f_dma_irq1,
   output wire h2f_dma_irq2,
   output wire h2f_dma_irq3,
   output wire h2f_dma_irq4,
   output wire h2f_dma_irq5,
   output wire h2f_dma_irq6,
   output wire h2f_dma_irq7,
   output wire h2f_emac0_irq,
   output wire h2f_emac1_irq,
   output wire h2f_fpga_man_irq,
   output wire h2f_gpio0_irq,
   output wire h2f_gpio1_irq,
   output wire h2f_gpio2_irq,
   output wire h2f_i2c0_irq,
   output wire h2f_i2c1_irq,
   output wire h2f_i2c_emac0_irq,
   output wire h2f_i2c_emac1_irq,
   output wire h2f_l4sp0_irq,
   output wire h2f_l4sp1_irq,
   output wire h2f_mpuwakeup_irq,
   output wire h2f_nand_irq,
   output wire h2f_osc0_irq,
   output wire h2f_osc1_irq,
   output wire h2f_qspi_irq,
   output wire h2f_sdmmc_irq,
   output wire h2f_spi0_irq,
   output wire h2f_spi1_irq,
   output wire h2f_spi2_irq,
   output wire h2f_spi3_irq,
   output wire h2f_uart0_irq,
   output wire h2f_uart1_irq,
   output wire h2f_usb0_irq,
   output wire h2f_usb1_irq,
   output wire h2f_wdog0_irq,
   output wire h2f_wdog1_irq
);
   assign fake_dout = 1'b0;
   
   altera_avalon_interrupt_sink #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(32),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) f2h_irq0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(irq[31:0])
   );
   
   altera_avalon_interrupt_sink #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(32),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) f2h_irq1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(irq[63:32])
   );
   
   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_can0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_can0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_can1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_can1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_clkmgr_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_clkmgr_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_cti_interrupt0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_cti_irq0_n)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_cti_interrupt1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_cti_irq1_n)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_abort_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_abort_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq0)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq1)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt2 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq2)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt3 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq3)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt4 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq4)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt5 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq5)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt6 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq6)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt7 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq7)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_emac0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_emac0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_emac1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_emac1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_fpga_man_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_fpga_man_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio2_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio2_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c_emac0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c_emac0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c_emac1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c_emac1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_l4sp0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_l4sp0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_l4sp1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_l4sp1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_mpuwakeup_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_mpuwakeup_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_nand_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_nand_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_osc0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_osc0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_osc1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_osc1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_qspi_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_qspi_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_sdmmc_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_sdmmc_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi2_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi2_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi3_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi3_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_uart0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_uart0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_uart1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_uart1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_usb0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_usb0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_usb1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_usb1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_wdog0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_wdog0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_wdog1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_wdog1_irq)
   );
   
endmodule 

module arriav_hps_interface_interrupts (
   input  wire [63:0] irq,
   output wire fake_dout,
   output wire h2f_can0_irq,
   output wire h2f_can1_irq,
   output wire h2f_clkmgr_irq,
   output wire h2f_cti_irq0_n,
   output wire h2f_cti_irq1_n,
   output wire h2f_dma_abort_irq,
   output wire h2f_dma_irq0,
   output wire h2f_dma_irq1,
   output wire h2f_dma_irq2,
   output wire h2f_dma_irq3,
   output wire h2f_dma_irq4,
   output wire h2f_dma_irq5,
   output wire h2f_dma_irq6,
   output wire h2f_dma_irq7,
   output wire h2f_emac0_irq,
   output wire h2f_emac1_irq,
   output wire h2f_fpga_man_irq,
   output wire h2f_gpio0_irq,
   output wire h2f_gpio1_irq,
   output wire h2f_gpio2_irq,
   output wire h2f_i2c0_irq,
   output wire h2f_i2c1_irq,
   output wire h2f_i2c_emac0_irq,
   output wire h2f_i2c_emac1_irq,
   output wire h2f_l4sp0_irq,
   output wire h2f_l4sp1_irq,
   output wire h2f_mpuwakeup_irq,
   output wire h2f_nand_irq,
   output wire h2f_osc0_irq,
   output wire h2f_osc1_irq,
   output wire h2f_qspi_irq,
   output wire h2f_sdmmc_irq,
   output wire h2f_spi0_irq,
   output wire h2f_spi1_irq,
   output wire h2f_spi2_irq,
   output wire h2f_spi3_irq,
   output wire h2f_uart0_irq,
   output wire h2f_uart1_irq,
   output wire h2f_usb0_irq,
   output wire h2f_usb1_irq,
   output wire h2f_wdog0_irq,
   output wire h2f_wdog1_irq
);
   assign fake_dout = 1'b0;
   
   altera_avalon_interrupt_sink #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(32),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) f2h_irq0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(irq[31:0])
   );
   
   altera_avalon_interrupt_sink #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(32),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) f2h_irq1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(irq[63:32])
   );
   
   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_can0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_can0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_can1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_can1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_clkmgr_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_clkmgr_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_cti_interrupt0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_cti_irq0_n)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_cti_interrupt1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_cti_irq1_n)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_abort_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_abort_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt0 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq0)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt1 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq1)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt2 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq2)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt3 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq3)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt4 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq4)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt5 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq5)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt6 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq6)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_dma_interrupt7 (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_dma_irq7)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_emac0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_emac0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_emac1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_emac1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_fpga_man_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_fpga_man_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_gpio2_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_gpio2_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c_emac0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c_emac0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_i2c_emac1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_i2c_emac1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_l4sp0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_l4sp0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_l4sp1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_l4sp1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_mpuwakeup_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_mpuwakeup_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_nand_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_nand_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_osc0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_osc0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_osc1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_osc1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_qspi_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_qspi_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_sdmmc_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_sdmmc_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi2_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi2_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_spi3_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_spi3_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_uart0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_uart0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_uart1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_uart1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_usb0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_usb0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_usb1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_usb1_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_wdog0_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_wdog0_irq)
   );

   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(1),
      .AV_IRQ_W(1),
      .ASYNCHRONOUS_INTERRUPT(1)
   ) h2f_wdog1_interrupt (
      .clk(1'b0),
      .reset(1'b0),
      .irq(h2f_wdog1_irq)
   );

endmodule 

