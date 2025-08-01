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


# CORE_PARAMETERS

# MAC without FIFO
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[9]}] -to [get_registers {*altera_tse_fifoless_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|frm_length[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]

if {[expr ($ENABLE_SUP_ADDR == 1)]} {
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[16]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[17]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[18]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
}

if {[expr ($ENABLE_MAC_FLOW_CTRL == 1)]} {
   set_false_path -from [get_registers *|altera_tse_fifoless_mac_rx:*|pause_quant_val*] -to [get_registers *|altera_tse_fifoless_mac_tx:*|pause_latch*]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|pause_quant_reg*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|pause_quant_reg*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|holdoff_quant*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]

}

# Magic packet detection 
if {[expr ($ENABLE_MAGIC_DETECT == 1)]} {
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]

   if {[expr ($ENABLE_SUP_ADDR == 1)]} {
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
   }
}

# Half duplex logic
if {[expr ($ENABLE_HD_LOGIC == 1)]} {
   set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
   set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*] -to [ get_registers *]
   set_multicycle_path -setup 5 -from [ get_registers *] -to [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*]
     
   set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
   set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*] -to [ get_registers *]
   set_multicycle_path -hold 5 -from [ get_registers *] -to [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*]
}

#**************************************************************
# Set False Path for altera_tse_reset_synchronizer
#**************************************************************
set tse_aclr_counter 0
set tse_clrn_counter 0
set tse_aclr_collection [get_pins -compatibility_mode -nocase -nowarn *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|aclr]
set tse_clrn_collection [get_pins -compatibility_mode -nocase -nowarn *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn]
foreach_in_collection tse_aclr_pin $tse_aclr_collection {
    set tse_aclr_counter [expr $tse_aclr_counter + 1]
}
foreach_in_collection tse_clrn_pin $tse_clrn_collection {
    set tse_clrn_counter [expr $tse_clrn_counter + 1]
}
if {$tse_aclr_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|aclr]
}

if {$tse_clrn_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn]
}
