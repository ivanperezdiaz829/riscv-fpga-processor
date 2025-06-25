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


#-----------------------------------------------------------------------------
#
# Description: SDC file for design_example_wrapper_nch.sv
#				This is a generic SDC file which may need to be modified
#				depending on your implementation.
#
#              Copyright (c) Altera Corporation 1997 - 2013
#              All rights reserved.
#
#
#-----change following as required--------------------------------------------
set num_channels 2 
set period_10g   3.103
set period_8g    8
set period_mgmt  10

set reg_check    [get_keepers *kr_gige_pcs_top*]
set length       [string length [query_collection $reg_check]]
if {$length==0} {  set SYNTH_GIGE  0 
} else          {  set SYNTH_GIGE  1 }

set reg_check    [get_keepers *an_top*]
set length       [string length [query_collection $reg_check]]
if {$length==0} {  set SYNTH_AN    0 
} else          {  set SYNTH_AN    1 }

set reg_check    [get_keepers *lt_top*]
set length       [string length [query_collection $reg_check]]
if {$length==0} {  set SYNTH_LT    0 
} else          {  set SYNTH_LT    1 }

set reg_check    [get_keepers *soft10Gfifo*]
set length       [string length [query_collection $reg_check]]
if {$length==0} {  set SYNTH_1588  0 
} else          {  set SYNTH_1588  1 }

set reg_check    [get_keepers *FEC_SOFT10G*]
set length       [string length [query_collection $reg_check]]
if {$length==0} {  set SYNTH_FEC    0 
} else          {  set SYNTH_FEC    1 }


#project hierarchy as below
set path_project "LOCAL_sv_rc_wrapper|INST_PHY" 

set_time_format -unit ns -decimal_places 3
derive_pll_clocks
derive_clock_uncertainty

# input clocks
create_clock -name {pll_ref_clk[0]} -period $period_8g   [get_ports {pll_ref_clk[0]}]
create_clock -name {pll_ref_clk[1]} -period $period_10g  [get_ports {pll_ref_clk[1]}]
create_clock -name {phy_mgmt_clk}   -period $period_mgmt [get_ports {phy_mgmt_clk}]

set path_native "SV_NATIVE.altera_xcvr_native_sv_inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst"
set path_kr     "kr_phy_ch_inst|$path_native"
set path_clk90  "$path_kr|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b"
set path_clk33  "$path_kr|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk33pcs"
#***************************************************************
# Create generated clock for each channel - Gige clk
#***************************************************************

if {$SYNTH_GIGE} {
  puts "Creating generated clocks for Gige"
  remove_clock "*${path_native}*ch[0].inst_sv_pcs_ch|inst_sv_hssi_8g_tx_pcs*cl*k*"
  for {set inst 0} {$inst<$num_channels} {incr inst} {
      set clock_name "clk_8g_ch$inst"
      set clock_node "$path_project[$inst].$path_clk90"
      create_generated_clock -name $clock_name -source [get_ports {pll_ref_clk[0]}]  [get_pins $clock_node] -add

      set clock_name "tx_clkout_8g_ch$inst"
      set clock_node "$path_project[$inst]\.$path_kr*_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_8g_tx_pcs|clkout" 
      create_clock  -name $clock_name -period $period_8g [get_nets $clock_node] 
  }
}

#***************************************************************
# Create generated clock for each channel - FEC clk
#***************************************************************
if {$SYNTH_FEC} {
  puts "Creating generated clocks for FEC"
  for {set inst 0} {$inst<$num_channels} {incr inst} {
    set clock_name    "rx_clkout_fec_$inst"
    set clock_node    "$path_project[$inst].$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs|rxclkout"
    set master_clock  "$path_project[$inst].$path_clk90"
    set clock_source  "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs|wys|rxpmaclk"
    create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_source -divide_by 16 -multiply_by 10 [get_nets $clock_node] -add

    set clock_name   "tx_clkout_fec_$inst"
    set clock_node   "$path_project[$inst].$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs|*txclkout"
    set clock_source "$path_project[$inst].$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs|wys|txpmaclk"
    set master_clock "$path_project[$inst]\.$path_kr|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]"
    create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_source -divide_by 16 -multiply_by 10 [get_nets $clock_node] -add

    set clock_name   "fec_pclk1_$inst"
    set clock_node   "$path_project[$inst].$path_kr|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]"
    set clock_source "$path_project[$inst].$path_kr|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|clklcb"
    create_generated_clock -name $clock_name -source $clock_source -divide_by 32 -multiply_by 1 $clock_node -add
  }
}

#***************************************************************
# Create generated clock for each channel - clk33pcs and rxclkout
# Constrain below has to be after abset clock_name   "$path_project[$inst].$path_clk33"above create_generated_clocks
#***************************************************************
for {set inst 0} {$inst<$num_channels} {incr inst} {
      set clock_name   "$path_project[$inst].$path_clk33"
      set master_clock "$path_project[$inst].$path_clk90"
      set clock_source "$path_project[$inst].$path_clk90"
      set clock_node   "$path_project[$inst].$path_clk33"
      create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_source -divide_by 66 -multiply_by 40 $clock_node
      
      set clock_name   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs|wys|rxclkout"
      set master_clock "$path_project[$inst].$path_clk90"
      set clock_source "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs|wys|rxpmaclk"
      set clock_node   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs|wys|rxclkout"
      create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_source $clock_node 
      
      set clock_name   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_8g_rx_pcs|wys|clocktopld"
      set master_clock "clk_8g_ch$inst" 
      set clock_source "clk_8g_ch$inst" 
      set clock_node   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_8g_rx_pcs|wys|clocktopld"
      create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_node

      set clock_name   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs|wys|txclkout"
      set master_clock "$path_project[$inst]\.$path_kr|inst_sv_pma|tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]"
      set clock_source "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs|wys|txpmaclk"
      set clock_node   "$path_project[$inst]\.$path_kr|inst_sv_pcs|ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs|wys|txclkout"
      create_generated_clock -name $clock_name -master_clock $master_clock -source $clock_source $clock_node
}

set clock_90b   "*$path_native*|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk90b"
set pcs_8g      "*sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_*"
set pcs_10g     "*SV_NATIVE.altera_xcvr_native_sv_inst*inst_sv_pcs_ch|sv_hssi_10g*"
set pclk_1      "*$path_native*tx_pma.sv_tx_pma_inst|tx_pma_insts[0].sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]*"
set clk_rx_10g  "*$path_native*ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_rx_pcs*rxclkout*"
set clk_tx_10g  "*$path_native*ch[0].inst_sv_pcs_ch|inst_sv_hssi_10g_tx_pcs*txcl*k*"
set clk_33      "*native_inst|inst_sv_pma|rx_pma.sv_rx_pma_inst|rx_pmas[0].rx_pma.rx_pma_deser|clk33pcs"
#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks phy_mgmt_clk]
set_clock_groups -asynchronous -group [get_clocks $clk_33]
set_clock_groups -asynchronous -group [get_clocks {LOCAL_sv_rc_wrapper|altera_pll_156M~PLL_OUTPUT_COUNTER|divclk}]
set_clock_groups -asynchronous -group [get_clocks $clk_rx_10g]
set_clock_groups -asynchronous -group [get_clocks $clk_tx_10g]
# FEC
if {$SYNTH_FEC} {
set_clock_groups -asynchronous -group [get_clocks {*tx_clkout_fec_*}]
set_clock_groups -asynchronous -group [get_clocks {*rx_clkout_fec_*}]
set_clock_groups -asynchronous -group [get_clocks {*fec_pclk1_*}]
}
# GIGE
if {$SYNTH_GIGE} {
set_clock_groups -asynchronous -group clk_8g_ch* -group [get_clocks $clock_90b]
}


#**************************************************************
# Set False Paths
#**************************************************************
#GIGE
if {$SYNTH_GIGE} {
set_false_path -from [get_clocks {pll_ref_clk[1]}] -to [get_registers {*kr_gige_pcs_top*}]
set_false_path -from [get_clocks $clock_90b] -to clk_8g_ch*
set_false_path -from clk_8g_ch* -to [get_clocks $clock_90b] 
set_false_path -from clk_8g_ch* -to [get_clocks $clk_33] 
set_false_path -from [get_clocks $clock_90b] -to tx_clkout_8g_ch*
set_false_path -from tx_clkout_8g_ch* -to [get_clocks $clock_90b] 

set_false_path -from [get_clocks $clock_90b] -to [get_registers {*kr_gige_pcs_top*}]
set_false_path -from [get_registers {*kr_gige_pcs_top*}] -to  [get_registers $pcs_10g]
set_false_path -from [get_registers $pcs_10g ] -to  [get_registers {*kr_gige_pcs_top*}]
set_false_path -from  [get_clocks -nowarn $clk_33] -to  [get_registers -nowarn {*kr_gige_pcs_top*}]

set_false_path -from [get_clocks {*sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]*}] -to   [get_registers {*kr_gige_pcs_top*}]
set_false_path -to   [get_clocks {*sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]*}] -from [get_registers {*kr_gige_pcs_top*}]
}
# AN
if {$SYNTH_AN} {
set_false_path -from  [get_registers $pcs_8g] -to  [get_registers -nowarn {*an_top*}]
set_false_path -from  [get_registers -nowarn {*an_top*}] -to  [get_registers $pcs_8g]
set_false_path -from  [get_clocks -nowarn {*clk90b*}] -to    [get_registers -nowarn {*an_top*}]
}
# LT 
if {$SYNTH_LT} {
set_false_path -from  [get_registers $pcs_8g] -to  [get_registers {*lt_top*}]
set_false_path -from  [get_registers -nowarn {*lt_top*}] -to  [get_registers $pcs_8g]
set_false_path -from  [get_clocks -nowarn {*clk90b*}] -to    [get_registers -nowarn {*lt_top*}]
}
# 1588
if {$SYNTH_1588} {
set_false_path -from {*soft10Gfifos*} -to $pcs_8g
set_false_path -from $pcs_8g -to {*soft10Gfifos*}
set_false_path -from  [get_clocks -nowarn $clk_33] -to  [get_registers -nowarn {*soft10Gfifos*}]
}
# FEC
if {$SYNTH_FEC} {
set_false_path -from [get_clocks $clk_rx_10g] -to *FEC_SOFT10G.sv_10gbaser_soft_pcs_inst*
set_false_path -from [get_clocks $clk_rx_10g] -to *FEC_SOFT10G.hd_krfec*
set_false_path -from {*FEC_SOFT10G.hd_krfec*} -to [get_clocks $clk_rx_10g]
set_false_path -from [get_clocks $clk_rx_10g] -to *SOFT10G_RESET*
set_false_path -from *SOFT10G_RESET*  -to [get_clocks $clk_rx_10g]

set_false_path -from [get_clocks $clk_tx_10g] -to *FEC_SOFT10G.sv_10gbaser_soft_pcs_inst*
set_false_path -from [get_clocks $clk_tx_10g] -to *FEC_SOFT10G.hd_krfec*
set_false_path -from {*FEC_SOFT10G.hd_krfec*} -to [get_clocks $clk_tx_10g]
set_false_path -from [get_clocks $clk_tx_10g] -to *SOFT10G_RESET*
set_false_path -from *SOFT10G_RESET*  -to [get_clocks $clk_tx_10g]

set_false_path -from {*FEC_SOFT10G.hd_krfec*} -to [get_clocks *sv_tx_pma_ch_inst|tx_pma_ch.tx_cgb|pclk[1]*]
set_false_path -from [get_clocks {*clk90b*}]  -to {*FEC_SOFT10G.hd_krfec*}

set_false_path -from {*FEC_SOFT10G.hd_krfec*} -to   $pcs_8g
set_false_path -to   {*FEC_SOFT10G.hd_krfec*} -from $pcs_8g
}
# False path from XXXXclk90 to to 8G PCS
set_false_path -from  [get_clocks $clock_90b] -to [get_registers $pcs_8g]
# False path from clk_8g to to 10G PCS
set_false_path -from clk_8g_ch* -to [get_registers $pcs_10g]

############
set_false_path -to    [get_clocks -nowarn {*clk90b*}] -from  [get_registers -nowarn $pcs_8g]
set_false_path -from  [get_clocks -nowarn $clk_33] -to  [get_registers -nowarn $pcs_8g]
set_false_path -from  [get_clocks -nowarn {*clk_8g_ch*}] -to  [get_registers -nowarn $pcs_10g]
set_false_path -from  [get_clocks -nowarn {*clk_8g_ch*}] -to  [get_registers -nowarn {*an_top*}]
set_false_path -from  [get_clocks -nowarn {*clk_8g_ch*}] -to  [get_registers -nowarn {*lt_top*}]


# This is embedded in the top file but it is not being picked up
set_false_path -to [get_registers {*gf_clock_mux*ena_r0*}]
set sv_xcvr_nat "altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|"
set wys_ff3 "sv_hssi_rx_pld_pcs_interface_rbc:inst_sv_hssi_rx_pld_pcs_interface|wys~FMAX_CAP_FF3"
set wys_ff4 "sv_hssi_rx_pld_pcs_interface_rbc:inst_sv_hssi_rx_pld_pcs_interface|wys~FMAX_CAP_FF4"
set_false_path -from "*$sv_xcvr_nat$wys_ff3" -to "*$sv_xcvr_nat$wys_ff4"

# False paths for CSR
set_false_path -from [get_keepers $pcs_8g] -to [get_keepers {*csr_krtop:csr_krtop_inst|readdata[*]}]

set_false_path -from [get_keepers {*csr_pcs10gbaser:csr_10gpcs|reg_rclr_errblk_cnt[*]}] -to [get_keepers {*csr_pcs10gbaser:csr_10gpcs|sync_rclr_errblk_cnt[*][*]}]
set_false_path -from [get_keepers {*csr_pcs10gbaser:csr_10gpcs|reg_rclr_ber_cnt[*]}] -to [get_keepers {*csr_pcs10gbaser:csr_10gpcs|sync_rclr_ber_cnt[*][*]}]

set_false_path -from [get_keepers {*csr_pcs10gbaser:csr_10gpcs|sync_rclr_ber_cnt[1][0]}] -to [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|wys~SYNC_DATA_REG3"]
set_false_path -from [get_keepers {*csr_pcs10gbaser:csr_10gpcs|sync_rclr_errblk_cnt[1][0]}] -to [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|wys~SYNC_DATA_REG4"]
set_false_path -from [get_keepers "*$path_native*inst_sv_xcvr_avmm|sv_xcvr_avmm_csr:avmm_interface_insts[0].sv_xcvr_avmm_csr_inst|gen_prbs_reg.r_prbs_err_clr"] \
               -to   [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|wys~SYNC_DATA_REG7"]

set_false_path -from [get_keepers {*csr_krgige:GIGE_ENABLE.csr_krgige_inst|reg_gige_base[3]}] -to [get_keepers "*$path_native*sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs|wys~SYNC_DATA_REG4"]

set_false_path -from [get_keepers "*$path_native*sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs|wys~SYNC_DATA_REG21"] -to [get_keepers {*csr_krgige:GIGE_ENABLE.csr_krgige_inst|readdata[*]}]
set_false_path -from [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|syncdatain"] -to [get_keepers {*csr_krgige:GIGE_ENABLE.csr_krgige_inst|readdata[*]}]
set_false_path -from [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|syncdatain"] -to [get_keepers {*csr_krtop:csr_krtop_inst|readdata[*]}]
set_false_path -from [get_keepers "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|wys~SYNC_DATA_REG*"] -to [get_keepers {*csr_krtop:csr_krtop_inst|readdata[*]}]

set_false_path -from "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|syncdatain" -to "*$path_native*sv_hssi_8g_tx_pcs_rbc:inst_sv_hssi_8g_tx_pcs|syncdatain"
set_false_path -from "*$path_native*sv_hssi_8g_tx_pcs_rbc:inst_sv_hssi_8g_tx_pcs|syncdatain"   -to "*$path_native*sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs|syncdatain"

set_false_path -from {clk_8g_ch*} -to $pclk_1
set_false_path -from $pclk_1 -to {clk_8g_ch*}


# data paths to/from hard phy on muxed clock
set_false_path -from [get_clocks $clk_33]  -to [get_keepers {test_harness:test_harness_inst|xgmii_src:tx_generator|*}]
set_false_path -from [get_clocks {LOCAL_sv_rc_wrapper|altera_pll_156M~PLL_OUTPUT_COUNTER|divclk}] -to [get_keepers $pcs_8g]

