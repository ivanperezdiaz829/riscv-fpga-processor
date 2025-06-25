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


onerror quit
onbreak resume
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
vlib work

vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v
vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v
vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v
vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv
vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_atoms.v
vlog      -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_mf.v
vlog +acc -novopt -sv $QUARTUS_ROOTDIR/eda/sim_lib/220model.v

vlog +acc -novopt ../mentor/components/*.v
vlog +acc -novopt ../mentor/ilk_striper/ilk_50g_striper/*.sv
vlog +acc -novopt ../mentor/ilk_50g_mac/*.v
vlog +acc -novopt -sv ../pcs_lib/alt_xcvr_csr_common_h.sv
vlog +acc -novopt -sv ../pcs_lib/alt_xcvr_csr_pcs8g_h.sv
vlog +acc -novopt -sv ../pcs_lib/sv_xcvr_h.sv
vlog +acc -novopt -sv ../pcs_lib/altera_xcvr_functions.sv

vlog +acc -novopt -sv ../pcs_lib/*.v
vlog +acc -novopt -sv ../pcs_lib/*.sv

vlog +acc -novopt -sv ../ilk_pcs/*.sv

vlog +acc -novopt ../mentor/ilk_50g_regroup/*.v
vlog +acc -novopt ../ilk_core_50g.sv
vlog +acc -novopt -sv ./ilk_pkt_gen.sv
vlog +acc -novopt -sv ./ilk_pkt_checker.sv
vlog +acc -novopt -sv ./example_design.sv
vlog +acc -novopt -sv ./top_tb.sv
vsim -t 1ps top_tb
add wave dut/*
run -all
quit
