# Useage: "vsim -mvchome ../../../common -do script.do"

vlib work
vlog -sv -timescale 1ns/1ns \
  ../../../common/questa_mvc_svapi.svh \
  ../../bfm/mgc_common_axi.sv \
  ../../bfm/mgc_axi_master.sv \
  ../../bfm/mgc_axi_monitor.sv \
  ../../bfm/mgc_axi_slave.sv \
  master_test_program.sv \
  monitor_test_program.sv \
  slave_test_program.sv \
  top.sv

vsim top
