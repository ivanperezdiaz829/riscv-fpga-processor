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




set slow_clk    "*|altpll_component|auto_generated|pll1|clk[4]"
set instance    "HRB_inst"

set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_read]                -setup  -end 2
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_read]                -hold   -end 1
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_write]               -setup  -end 2
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_write]               -hold   -end 1
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_state*]              -setup  -end 2
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_state*]              -hold   -end 1
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_rd_txfers*]          -setup  -end 2
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_rd_txfers*]          -hold   -end 1
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_wr_txfers*]          -setup  -end 2
set_multicycle_path -from [get_clocks $slow_clk] -to [get_registers *|altera_avalon_half_rate_bridge:${instance}|avm_wr_txfers*]          -hold   -end 1
