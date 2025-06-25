# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.



################################################
# Static lists for speed.
# Kept in sync with elaboration by a test.
################################################

# interfaces
proc get_peripheral_fpga_input_clocks {peripheral} {
    array set map {
	CAN0  {}
	CAN1  {}
	EMAC0 {emac0_rx_clk_in emac0_tx_clk_in}
	EMAC1 {emac1_rx_clk_in emac1_tx_clk_in}
	I2C0   i2c0_scl_in
	I2C1   i2c1_scl_in
	I2C2   i2c2_scl_in
	I2C3   i2c3_scl_in
	NAND  {}
	QSPI  {}
	SDIO   sdio_clk_in
	SPIM0 {}
	SPIM1 {}
	SPIS0  spis0_sclk_in
	SPIS1  spis1_sclk_in
	TRACE {}
	UART0 {}
	UART1 {}
	USB0   usb0_clk_in
	USB1   usb1_clk_in
    }
    return $map($peripheral)
}

# interfaces
proc get_peripheral_fpga_output_clocks {peripheral} {
    array set map {
	CAN0  {}
	CAN1  {}
	EMAC0 {emac0_md_clk emac0_gtx_clk}
	EMAC1 {emac1_md_clk emac1_gtx_clk}
	I2C0   i2c0_clk
	I2C1   i2c1_clk
	I2C2   i2c2_clk
	I2C3   i2c3_clk
	NAND  {}
	QSPI   qspi_sclk_out
	SDIO   sdio_cclk
	SPIM0  spim0_sclk_out
	SPIM1  spim1_sclk_out
	SPIS0 {}
	SPIS1 {}
	TRACE {}
	UART0 {}
	UART1 {}
	USB0  {} 
	USB1  {}
    }
    return $map($peripheral)
}

# signals
# the actual pins will be named ${peripheral}_${signal}
proc get_peripheral_soc_io_input_clocks {peripheral} {
    array set map {
	CAN0  {}
	CAN1  {}
	EMAC0  rx_clk
	EMAC1  rx_clk
	I2C0   scl
	I2C1   scl
	I2C2   scl
	I2C3   scl
	NAND  {}
	QSPI  {}
	SDIO   clk_in
	SPIM0 {}
	SPIM1 {}
	SPIS0  clk
	SPIS1  clk
	TRACE {}
	UART0 {}
	UART1 {}
	USB0   clk 
	USB1   clk
    }
    return $map($peripheral)
}

proc form_peripheral_soc_io_input_clock_frequency_parameter {peripheral port} {
    return "SOC_PERIPHERAL_INPUT_CLOCK_FREQ_[string toupper ${peripheral}_${port}]"
}

proc form_peripheral_fpga_input_clock_frequency_parameter {interface} {
    return "FPGA_PERIPHERAL_INPUT_CLOCK_FREQ_[string toupper $interface]"
}

proc form_peripheral_fpga_output_clock_frequency_parameter {interface} {
    return "FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_[string toupper $interface]"
}
