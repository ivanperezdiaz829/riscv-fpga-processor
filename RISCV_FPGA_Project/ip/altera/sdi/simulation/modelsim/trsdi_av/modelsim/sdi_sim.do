set quartus_rootdir "$env(QUARTUS_ROOTDIR)"

vlib work

# Quartus libraries
vlog $quartus_rootdir/libraries/megafunctions/alt_cal_av.v
vlog -sv +define+GENERIC_PLL_TIMESCALE_100_FS=1 $quartus_rootdir/eda/sim_lib/altera_lnsim.sv
vlog $quartus_rootdir/eda/sim_lib/altera_primitives.v
vlog $quartus_rootdir/eda/sim_lib/220model.v
vlog $quartus_rootdir/eda/sim_lib/sgate.v
vlog $quartus_rootdir/eda/sim_lib/altera_mf.v
vlog $quartus_rootdir/eda/sim_lib/arriav_hssi_atoms.v
vlog $quartus_rootdir/eda/sim_lib/mentor/arriav_hssi_atoms_ncrypt.v

# Custom PHY files
vlog ../testbench/xcvr/alt_xcvr_csr_common_h.sv
vlog ../testbench/xcvr/*_h.sv
vlog ../testbench/xcvr/altera_xcvr_functions.sv
vlog ../testbench/xcvr/*.sv
vlog ../testbench/xcvr/*.v

# Reconfig and pattern gen files
vlog ../testbench/reconfig/alt_xcvr_reconfig_h.sv
vlog ../testbench/reconfig/*.sv
vlog ../testbench/reconfig/*.v
vlog ../testbench/pattern_gen/*.v

# SDI simulation model
vlog ../testbench/sdi_mc_build/*.vo

# Testbench
vlog ../testbench/tb_sdi_megacore_top.v

vsim -novopt work.tb_sdi_megacore_top -L work
do wave.do
set StdArithNoWarnings 1
run -all

