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


derive_pll_clocks -create_base_clock
derive_clock_uncertainty
create_clock -name rx_usr_clk -period 3.3 [get_ports {rx_usr_clk}]
create_clock -name tx_usr_clk -period 3.3 [get_ports {tx_usr_clk}]
create_clock -name mm_clk -period 10.0 [get_ports mm_clk]

set_false_path -hold -from *sv_ilk_sixpack* -to *pcs_assembly*mm_rdata[*]
set_max_delay 6.6 -from *sv_ilk_sixpack* -to *pcs_assembly*mm_rdata[*]

# DCFIFO clr is cut to read side
set_false_path -from *tx_buffer_fifo_ram_loose*aclr* -to *rdptr_*
set_false_path -from *tx_buffer_fifo_ram*local_aclr -to *rs_dgwp*
set_false_path -from *tx_buffer_fifo_ram*local_aclr -to *rdemp_eq_comp*
set_false_path -from *tx_buffer_fifo_ram*local_aclr -to *portb_address_*
set_false_path -from *tx_buffer_fifo_ram*local_aclr -to *PORT_B_ADDRESS_*
set_false_path -from *tx_buffer_fifo_ram*local_aclr -to *fifo_ram*q_b[*]


# DCFIFO clr is cut to read side
# set_false_path -from *smoothed_domain*arst_n[2] -to *rdptr_*
# set_false_path -from *smoothed_domain*arst_n[2] -to *rs_dgwp*
# set_false_path -from *smoothed_domain*arst_n[2] -to *rdemp_eq_comp*
# set_false_path -from *smoothed_domain*arst_n[2] -to *portb_address_*
# set_false_path -from *smoothed_domain*arst_n[2] -to *PORT_B_ADDRESS_*
# set_false_path -from *smoothed_domain*arst_n[2] -to *fifo_ram*q_b[*]
# set_false_path -from *smoothed_domain*arst_n[2] -to *rs_brp*
# set_false_path -from *smoothed_domain*arst_n[2] -to *rs_bwp*


# DCFIFO clr is cut to read side
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*rdptr_*
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*rs_dgwp*
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*rdemp_eq_comp*
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*portb_address_*
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*PORT_B_ADDRESS_*
set_false_path -from *rst_ctrl|tx_arst_filter[2] -to *trs*fifo_ram*q_b[*]


# DCFIFO clr is cut to read side
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*rdptr_*
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*rs_dgwp*
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*rdemp_eq_comp*
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*portb_address_*
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*PORT_B_ADDRESS_*
# set_false_path -from *ilk_rst_ctrl*cntr[19] -to *rg0|rx_regroup*fifo_ram*q_b[*]


#  this should be routed as tight as possible, but no hard requirement
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_sta"} {
  set_false_path -from *rx_fifo_clr -to *pcs*
}
# Set Cross-Clock False Paths
# Set False Path

#read_sdc "cut_path.sdc"

# Set Cross-Clock False Paths


set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}] -to [get_clocks {tx_usr_clk}]

set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}] -to [get_clocks {mm_clk}]

set_false_path -from  [get_clocks {mm_clk}] -to [get_clocks {*inst_sv_pcs*hssi_10g_rx_pcs*rxclkout}]

set_false_path -from [get_clocks {mm_clk}] -to [get_clocks {*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}]

set_false_path -from [get_clocks {rx_usr_clk}] -to [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_rx_pcs*rxclkout}]
set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_rx_pcs*rxclkout}] -to [get_clocks {rx_usr_clk}]

##### tx_empty_r #####
# set_false_path -to *ilk_pcs_assembly*tx_empty_rr*

##### rx_any_pfull #####
 set_false_path -to *ilk_pcs_assembly*rx_any_pfull*
##### tx_from_fifo ##### 
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
} else {
set_false_path -from {*ilk_pcs_assembly*tx_from_fifo} -to {*ilk_pcs_assembly*sv_ilk_sixpack*gxlp[*]*sv_xcvr_native*sdlp[*]*sv_pcs_ch*hssi_10g_tx_pcs_rbc*wys~SYNC_DATA_REG*}
}
#####   db_iport_pcs10gtxframe	#####
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
} else {
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_tx_pcs_rbc*hssi_10g_tx_pcs*SYNC_DATA_REG*} -to {*ilk_pcs_assembly*any_tx_frame}
}
##### db_iport_pcs10grxcrc32err	#####
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
} else {
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_rx_pcs_rbc*hssi_10g_rx_pcs*SYNC_DATA_REG*} -to {*ilk_pcs_assembly*hah*ecnt[*]*local_cnt[*]}
}
##### db_iport_pcs10grxframelock #####
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
} else {
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_rx_pcs_rbc*hssi_10g_rx_pcs*SYNC_DATA_REG*} -to {*ilk_pcs_assembly*hah*any_loss_of_meta}
}
##### db_iport_pcs10grxsherr  #####
if {$::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
} else {
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_rx_pcs_rbc*hssi_10g_rx_pcs*SYNC_DATA_REG*} -to {*ilk_pcs_assembly*hah*sticky_sherr[*]}
}

###

set_false_path -from {*ilk_core*ilk_pcs_assembly*ilk_frequency_monitor*scaled_toggle*} -to {*ilk_core*ilk_pcs_assembly*ilk_frequency_monitor*capture[*]}