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

create_clock -period 6.4 -name {ref_clk} [get_ports ref_clk]
create_clock -period 20.0 -name {clk_50Mhz} [get_ports clk_50Mhz]

#cut timing between clocks of MM and ST interfaces (for SIV hard xaui)
set_clock_groups -asynchronous -group { *|use_device_family_siv_sv.hxaui_alt4gxb|hxaui_alt4gxb_alt4gxb_dksa_component|central_clk_div0|coreclkout} -group { clk_50Mhz } -group {ref_clk~input~INSERTED_REFCLK_DIVIDER|clkout} 
set_clock_groups -asynchronous -group {*|use_device_family_siv_sv.hxaui_alt4gxb|hxaui_alt4gxb_alt4gxb_dksa_component|central_clk_div0|coreclkout} -group {*|use_device_family_siv_sv.hxaui_alt4gxb|hxaui_alt4gxb_alt4gxb_dksa_component|transmit_pcs0|clkout}

#cut timing between clocks of MM and ST interfaces (for SIV Soft xaui)
set_clock_groups -asynchronous -group {*alt_pma_0|pma_direct|auto_generated|receive_pma*|deserclock*} -group {clk_50Mhz}
set_clock_groups -asynchronous -group {*alt_pma_0|pma_direct|auto_generated|receive_pma0|deserclock*} -group {*alt_pma_0|pma_direct|auto_generated|receive_pma1|deserclock*} 
set_clock_groups -asynchronous -group {*alt_pma_0|pma_direct|auto_generated|receive_pma0|deserclock*} -group {*alt_pma_0|pma_direct|auto_generated|receive_pma2|deserclock*}
set_clock_groups -asynchronous -group {*alt_pma_0|pma_direct|auto_generated|receive_pma0|deserclock*} -group {*alt_pma_0|pma_direct|auto_generated|receive_pma3|deserclock*}
set_clock_groups -asynchronous -group {*alt_pma_0|pma_direct|auto_generated|central_clk_div0|refclkout} -group {*alt_pma_0|pma_direct|auto_generated|receive_pma*|deserclock*}

#cut timing between clocks of MM and ST (cyclone IV GX)
set_clock_groups -asynchronous -group {*|use_device_family_civ.hxaui_alt_c3gxb|hxaui_alt_c3gxb_alt_c3gxb_component|cent_unit0|coreclkout} -group { clk_50Mhz } 

#cut timing between clock for SV
set_clock_groups -asynchronous -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[0].duplex_pcs|ch[0].rx_pcs|clocktopld} -group {clk_50Mhz}
set_clock_groups -asynchronous -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[1].duplex_pcs|ch[0].rx_pcs|clocktopld} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[2].duplex_pcs|ch[0].rx_pcs|clocktopld} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[3].duplex_pcs|ch[0].rx_pcs|clocktopld} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[0].duplex_pcs|ch[0].tx_pcs|clkout} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[0].duplex_pcs|ch[0].rx_pcs|clocktopld} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[1].duplex_pcs|ch[0].tx_pcs|clkout} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[2].duplex_pcs|ch[0].tx_pcs|clkout} -group {*alt_pma_0|alt_pma_sv_inst|sv_xcvr_generic_inst|channel_tx[3].duplex_pcs|ch[0].tx_pcs|clkout}

set_clock_groups -asynchronous -group {*|alt_pma_sv_inst|sv_xcvr_custom_inst|sv_xcvr_native_insts[0].sv_xcvr_native_inst|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_stratixv_hssi_8g_tx_pcs|wys|clkout} -group {*|alt_pma_sv_inst|sv_xcvr_custom_inst|sv_xcvr_native_insts[1].sv_xcvr_native_inst|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_stratixv_hssi_8g_tx_pcs|wys|clkout} -group {|alt_pma_sv_inst|sv_xcvr_custom_inst|sv_xcvr_native_insts[2].sv_xcvr_native_inst|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_stratixv_hssi_8g_tx_pcs|wys|clkout} -group {|alt_pma_sv_inst|sv_xcvr_custom_inst|sv_xcvr_native_insts[3].sv_xcvr_native_inst|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_stratixv_hssi_8g_tx_pcs|wys|clkout}

#cut timing between clocks of MM interfaces and reference clock
set_clock_groups -asynchronous -group {ref_clk} -group {clk_50Mhz}

# Cut timing for SV
set_clock_groups -asynchronous -group {*|alt_xaui_phy|alt_pma_0|sv_xcvr_custom_inst|gen.sv_xcvr_native_insts[0].gen_bonded_group.sv_xcvr_native_inst|inst_sv_pcs|ch[2].inst_sv_pcs_ch|inst_stratixv_hssi_8g_rx_pcs|wys|clocktopld} -group {clk_50Mhz} -group {*|alt_xaui_phy|alt_pma_0|sv_xcvr_custom_inst|gen.sv_xcvr_native_insts[0].gen_bonded_group.sv_xcvr_native_inst|inst_sv_pcs|ch[3].inst_sv_pcs_ch|inst_stratixv_hssi_8g_rx_pcs|wys|clocktopld} -group {*|alt_xaui_phy|alt_pma_0|sv_xcvr_custom_inst|gen.sv_xcvr_native_insts[0].gen_bonded_group.sv_xcvr_native_inst|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_stratixv_hssi_8g_rx_pcs|wys|clocktopld} -group {SUT|eth_10g_design_example_0|xaui|alt_xaui_phy|alt_pma_0|sv_xcvr_custom_inst|gen.sv_xcvr_native_insts[0].gen_bonded_group.sv_xcvr_native_inst|inst_sv_pcs|ch[1].inst_sv_pcs_ch|inst_stratixv_hssi_8g_rx_pcs|wys|clocktopld}
set_clock_groups -asynchronous -group {sv_reconfig_pma_testbus_clk} -group {clk_50Mhz}

# Cut timing for AV/CV
set_clock_groups -asynchronous -group {clk_50Mhz} -group {*inst_av_hssi_8g_tx_pcs|wys|txpmalocalclk} -group {*inst_av_hssi_8g_rx_pcs|wys|rcvdclkpma}
