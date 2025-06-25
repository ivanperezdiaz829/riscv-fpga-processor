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


derive_pll_clocks
derive_clock_uncertainty

create_clock -period 1.552 -name {ref_clk} [get_ports ref_clk]
create_clock -period 20.0 -name {clk_50Mhz} [get_ports clk_50Mhz]

# Set Clock Groups
set_clock_groups -exclusive -group [get_clocks {*|altera_10gbaser|siv_xcvr_with_pma_ctrl|pcs_pma_inst|siv_alt_pma|siv_alt_pma|pma_direct|auto_generated|receive_pcs0|clkout}] -group clk_50Mhz -group {*|altera_10gbaser|siv_xcvr_with_pma_ctrl|pcs_pma_inst|pll_siv_xgmii_clk|altpll_component|auto_generated|pll1|clk[0]} -group {*|altera_10gbaser|siv_xcvr_with_pma_ctrl|pcs_pma_inst|siv_alt_pma|siv_alt_pma|pma_direct|auto_generated|transmit_pcs0|clkout}

# Set Clock Groups for SV
set_clock_groups -exclusive -group {clk_50Mhz} -group [get_clocks {*|ch[0].sv_10gbaser_ch_inst|tx_pll|altera_pll_1~PLL_OUTPUT_COUNTER|divclk}]
set_clock_groups -exclusive -group {clk_50Mhz} -group {*|ch[0].sv_xcvr_10gbaser_native_inst|native_inst|inst_sv_pma|sv_rx_pma|ch[0].ch.rx_pma_deser|clkdivrx}
set_clock_groups -exclusive -group {clk_50Mhz} -group {*|altera_10gbaser|xv_xcvr_10gbaser_nr_inst|ch[0].sv_xcvr_10gbaser_native_inst|native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clkdivrx}
set_clock_groups -exclusive -group {clk_50Mhz} -group {*|altera_10gbaser|xv_xcvr_10gbaser_nr_inst|ch[0].sv_xcvr_10gbaser_native_inst|tx_pll|altera_pll_156M~PLL_OUTPUT_COUNTER|divclk}

set_clock_groups -exclusive -group {clk_50Mhz} -group {*|altera_10gbaser|xv_xcvr_10gbaser_nr_inst|ch[0].sv_xcvr_10gbaser_native_inst|g_fpll.altera_pll_156M~PLL_OUTPUT_COUNTER|divclk}
set_clock_groups -exclusive -group {clk_50Mhz} -group {sv_reconfig_pma_testbus_clk}

#cut timing between clocks of alt_jtagavalon module (Jtag clk to Avalon clock)
