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




create_clock -period 8 -name ref_clk [ get_ports  {ref_clk} ]
create_clock -period 20 -name clk_50_clk [get_ports {clk_50_clk}]
create_clock -period 12.5 -name pcs_phase_measure_clk_clk [get_ports {pcs_phase_measure_clk_clk}]

set_clock_groups -asynchronous -group [get_clocks ref_clk]
set_clock_groups -asynchronous -group [get_clocks clk_50_clk]
set_clock_groups -asynchronous -group [get_clocks pcs_phase_measure_clk_clk]

derive_pll_clocks
derive_clock_uncertainty

#set multicycle path
set_multicycle_path -from {*altera_eth_1588_tod:tod|altera_avalon_st_clock_crosser:time_transfer1|altera_avalon_st_pipeline_base:output_stage|data1*} -to {*altera_eth_1588_tod:tod|nsec_cntr_64b*} -setup -end 2
set_multicycle_path -from {*altera_eth_1588_tod:tod|altera_avalon_st_clock_crosser:time_transfer1|altera_avalon_st_pipeline_base:output_stage|data1*} -to {*altera_eth_1588_tod:tod|nsec_cntr_64b*} -hold -end 2