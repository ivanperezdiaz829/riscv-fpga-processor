set TOP_LEVEL_NAME top
set QSYS_SIMDIR    simulation

source $QSYS_SIMDIR/mentor/msim_setup.tcl

if {![info exists env(MENTOR_VIP_AE)]} {
  set env(MENTOR_VIP_AE) $env(QUARTUS_ROOTDIR)/../ip/altera/mentor_vip_ae
}

  ensure_lib libraries
  ensure_lib libraries/work
  vmap work  libraries/work

  vlog -work work -sv \
    $env(MENTOR_VIP_AE)/common/questa_mvc_svapi.svh \
    $env(MENTOR_VIP_AE)/axi4/bfm/mgc_common_axi4.sv \
    $env(MENTOR_VIP_AE)/axi4/bfm/mgc_axi4_monitor.sv \
    $env(MENTOR_VIP_AE)/axi4/bfm/mgc_axi4_inline_monitor.sv \
    $env(MENTOR_VIP_AE)/axi4/bfm/mgc_axi4_master.sv \
    $env(MENTOR_VIP_AE)/axi4/bfm/mgc_axi4_slave.sv

# Compile
dev_com

# Compile
com

# Compile
vlog -timescale 1ps/1ps master_test_program.sv
vlog -timescale 1ps/1ps slave_test_program.sv
vlog -timescale 1ps/1ps monitor_test_program.sv

# Compile
vlog -timescale 1ps/1ps top.sv

# Simulate
elab

