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


#####################################################################
#
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file specifies the timing properties of the memory device and
# of the memory interface


package require ::quartus::ddr_timing_model

###################
#                 #
# TIMING SETTINGS #
#                 #
###################

# Interface Clock Period
set t(CK) IPTCL_MEM_CLK_NS

# Reference Clock Period
set t(refCK) IPTCL_REF_CLK_NS

# Minimum Clock Period
set t(min_CK) IPTCL_MEM_CLK_MAX_NS

##########################
# Memory timing parameters
##########################

# A/C Setup/Hold
set t(IS) IPTCL_TIMING_BOARD_TIS_APPLIED
set t(IH) IPTCL_TIMING_BOARD_TIH_APPLIED

# Data Setup/Hold
set t(DS) IPTCL_TIMING_BOARD_TDS_APPLIED
set t(DH) IPTCL_TIMING_BOARD_TDH_APPLIED

# DQS clock edge to DQ data edge (in same group)
set t(DQSQ) [expr { IPTCL_TIMING_TDQSQ / 1000.0 }]
set t(QHS) [expr { IPTCL_TIMING_TQHS / 1000.0 }]

# Convert QH into time unit so that it's consistent with DQSQ
set t(QH_time) [expr 0.5 * $t(CK) - $t(QHS) ]

# DQS to CK input timing
set t(DSS) IPTCL_TIMING_TDSS
set t(DSH) IPTCL_TIMING_TDSH
set t(DQSS) IPTCL_TIMING_TDQSS
set t(DSS) [expr $t(DSS)*$t(min_CK)/$t(CK)]
set t(DSH) [expr $t(DSH)*$t(min_CK)/$t(CK)]
set t(DQSS) [expr 0.5 - ($t(DQSS)-1.0)*$t(min_CK)/$t(CK)]

# DQS Timing
set t(DQSH) IPTCL_TIMING_TDQSH

# Write Levelling parameters
set t(WLS) [ expr 0.13 * $t(min_CK) ]
set t(WLH) [ expr 0.13 * $t(min_CK) ]

# DQS to CK timing on reads
set t(DQSCK) [expr { IPTCL_TIMING_TDQSCK / 1000.0 }]
set t(DQSCKDS) [expr { IPTCL_TIMING_TDQSCKDS / 1000.0 }]
set t(DQSCKDM) [expr { IPTCL_TIMING_TDQSCKDM / 1000.0 }]
set t(DQSCKDL) [expr { IPTCL_TIMING_TDQSCKDL / 1000.0 }]

# FPGA Duty Cycle Distortion
set t(DCD) 0.0

#######################
# Controller parameters
#######################

set t(RL) IPTCL_MEM_TCL
set t(WL) IPTCL_MEM_WTCL_INT
set t(DWIDTH_RATIO) [expr { IPTCL_AFI_RATE_RATIO * IPTCL_DATA_RATE_RATIO }]
set t(rd_to_wr_turnaround_oct) IPTCL_MEM_IF_RD_TO_WR_TURNAROUND_OCT

#####################
# FPGA specifications
#####################

# Sequencer VCALIB width. Determins multicycle length
set vcalib_count_width IPTCL_VCALIB_COUNT_WIDTH

set fpga(tPLL_PSERR) 0.0
set fpga(tPLL_JITTER) 0.0

# Systematic DCD in the Write Levelling delay chains
set t(WL_DCD) [expr [get_micro_node_delay -micro WL_DCD -parameters {IO VPAD} -in_fitter]/1000.0]
# Non-systematic DC jitter in the Write Levelling delay chains
set t(WL_DCJ) [expr [get_micro_node_delay -micro WL_DC_JITTER -parameters {IO VPAD} -in_fitter]/1000.0]
# Phase shift error in the Write Levelling delay chains between DQ and DQS
set t(WL_PSE) 0.0
# Jitter in the Write Levelling delay chains
set t(WL_JITTER) [expr [get_micro_node_delay -micro WL_JITTER -parameters {IO PHY_SHORT} -in_fitter]/1000.0]
set t(WL_JITTER_DIVISION) [expr [get_micro_node_delay -micro WL_JITTER_DIVISION -parameters {IO PHY_SHORT} -in_fitter]/100.0]


###############
# SSN Info
###############

set SSN(pushout_o) [expr [get_micro_node_delay -micro SSO -parameters [list IO DQDQSABSOLUTE NONLEVELED MAX] -in_fitter]/1000.0]
set SSN(pullin_o)  [expr [get_micro_node_delay -micro SSO -parameters [list IO DQDQSABSOLUTE NONLEVELED MIN] -in_fitter]/-1000.0]
set SSN(pushout_i) [expr [get_micro_node_delay -micro SSI -parameters [list IO DQDQSABSOLUTE NONLEVELED MAX] -in_fitter]/1000.0]
set SSN(pullin_i)  [expr [get_micro_node_delay -micro SSI -parameters [list IO DQDQSABSOLUTE NONLEVELED MIN] -in_fitter]/-1000.0]
set SSN(rel_pushout_o) [expr [get_micro_node_delay -micro SSO -parameters [list IO DQDQSRELATIVE NONLEVELED MAX] -in_fitter]/1000.0]
set SSN(rel_pullin_o)  [expr [get_micro_node_delay -micro SSO -parameters [list IO DQDQSRELATIVE NONLEVELED MIN] -in_fitter]/-1000.0]
set SSN(rel_pushout_i) [expr [get_micro_node_delay -micro SSI -parameters [list IO DQDQSRELATIVE NONLEVELED MAX] -in_fitter]/1000.0]
set SSN(rel_pullin_i)  [expr [get_micro_node_delay -micro SSI -parameters [list IO DQDQSRELATIVE NONLEVELED MIN] -in_fitter]/-1000.0]

###############
# Board Effects
###############

# Intersymbol Interference
set ISI(addresscmd_setup) IPTCL_TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED
set ISI(addresscmd_hold) IPTCL_TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED
set ISI(DQ) IPTCL_TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED
set ISI(DQS) IPTCL_TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED
set ISI(READ_DQ) IPTCL_TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED
set ISI(READ_DQS) IPTCL_TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED


# Board skews
set board(abs_max_CK_delay) IPTCL_TIMING_BOARD_MAX_CK_DELAY
set board(abs_max_DQS_delay) IPTCL_TIMING_BOARD_MAX_DQS_DELAY
set board(minCK_DQS_skew) IPTCL_TIMING_BOARD_SKEW_CKDQS_DIMM_MIN_APPLIED
set board(maxCK_DQS_skew) IPTCL_TIMING_BOARD_SKEW_CKDQS_DIMM_MAX_APPLIED
set board(tpd_inter_DIMM) IPTCL_TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED
set board(intra_DQS_group_skew) IPTCL_TIMING_BOARD_SKEW_WITHIN_DQS
set board(inter_DQS_group_skew) IPTCL_TIMING_BOARD_SKEW_BETWEEN_DQS
set board(DQ_DQS_skew) IPTCL_TIMING_BOARD_DQ_TO_DQS_SKEW
set board(intra_addr_ctrl_skew) IPTCL_TIMING_BOARD_AC_SKEW
set board(addresscmd_CK_skew) IPTCL_TIMING_BOARD_AC_TO_CK_SKEW

