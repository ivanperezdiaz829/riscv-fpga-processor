global env;
vlib work
vmap work work
file copy -force ./rio_sys/simulation/submodules/rio_sys_onchip_memory2_0.hex ./
vlog -v -reportprogress -work work $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v
vlog -v -reportprogress -work work $env(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v
vlog -v -reportprogress -work work $env(QUARTUS_ROOTDIR)/eda/sim_lib/sgate.v
vlog -v -reportprogress -work work $env(QUARTUS_ROOTDIR)/eda/sim_lib/stratixiv_hssi_atoms.v

vlog -sv -reportprogress 300 -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/verbosity_pkg.sv
vlog -sv -reportprogress 300 -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_mm_pkg.sv
vlog -sv -reportprogress 300 -work work $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification/lib/avalon_utilities_pkg.sv
vlog -reportprogress 300 -work work ./rio_sys/simulation/rio_sys.v

foreach file_name [glob -d ./rio_sys/simulation/submodules "*.sv"] {
    if {![string match "./rio_sys/simulation/submodules/verbosity_pkg.sv" $file_name] && ![string match "./rio_sys/simulation/submodules/avalon_mm_pkg.sv" $file_name] && ![string match "./rio_sys/simulation/submodules/avalon_utilities_pkg.sv" $file_name]} {
      vlog -reportprogress 300 -work work $file_name
    }
}

foreach file_name [glob -d ./rio_sys/simulation/submodules "*.v"] {
	 vlog -reportprogress 300 -work work $file_name
}


vlog -reportprogress 300 -work work ./rio_sys/simulation/submodules/*_rapidio_*.vo
vlog -sv -reportprogress 300 -work work ./rio_sys_tb.v

vsim work.rio_sys_tb
run -all
