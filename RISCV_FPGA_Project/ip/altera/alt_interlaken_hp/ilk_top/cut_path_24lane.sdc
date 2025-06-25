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


# Set Cross-Clock False Paths

set_false_path -from [get_clocks {temp_sense_clock}] -to [get_clocks {mm_clk}]

set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}] -to [get_clocks {tx_usr_clk}]

set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}] -to [get_clocks {mm_clk}]

set_false_path -from  [get_clocks {mm_clk}] -to [get_clocks {*inst_sv_pcs*hssi_10g_rx_pcs*rxclkout}]

set_false_path -from [get_clocks {mm_clk}] -to [get_clocks {*inst_sv_pcs_ch*hssi_10g_tx_pcs*txclkout}]

set_false_path -from [get_clocks {rx_usr_clk}] -to [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_rx_pcs*rxclkout}]
set_false_path -from [get_clocks {*inst_sv_pcs*inst_sv_pcs_ch*hssi_10g_rx_pcs*rxclkout}] -to [get_clocks {rx_usr_clk}]
#set_false_path -from {*ilk_iw8_retrans_ptr_fifo:rtptr_fifo|stable_wrptr[*]} -to {*ilk_iw8_retrans_ptr_fifo:rtptr_fifo|stable_wrptr_rdclk[*]}
#set_false_path -from {*ilk_iw8_retrans_ptr_fifo:txctl_fifo|stable_wrptr[*]} -to {*ilk_iw8_retrans_ptr_fifo:txctl_fifo|stable_wrptr_rdclk[*]}
##### tx_empty_r #####
#set_false_path -to *ilk_pcs_assembly*tx_empty_r*

##### tx_pempty_r #####
#set_false_path -to *ilk_pcs_assembly*tx_pempty_r*

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
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_rx_pcs_rbc*hssi_10g_rx_pcs*SYNC_DATA_REG*} -to {*ilk_core*ilk_pulse_stretch_sync:ss_crc32_err|din_toggle[*]}
set_false_path -from {*ilk_pcs_assembly*sv_ilk_sixpack*sv_xcvr_native*sv_pcs*sv_pcs_ch*hssi_10g_rx_pcs_rbc*hssi_10g_rx_pcs*SYNC_DATA_REG*} -to {*ilk_core*ilk_pulse_stretch_sync:ss_crc32_err|din_r[*]}
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