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



# Quartus installation directory, set by Quartus .../acds/quartus
set QROOT "$env(QUARTUS_ROOTDIR)"

# simulation files dir for qmegawiz set-up and compile
set MW_RECONFIG_SIM "./reconfig/reconfig_sim"       
set MW_RESET_SIM    "./rst_ctrl/rst_ctrl_sim"
set MW_NATIVE_SIM   "./native_phy/native_phy_sim"
set MW_BASEKR_SIM   "./base_kr_top/base_kr_top_sim"

# debug mode global variable.  Set to 0 to turn-off Info messages
set DEBUG 1
# setting this to 1 will always generate the IP even if they are present
set FORCE_MW_REGEN 1
#########################################################

proc my_info_puts {s} {
    global DEBUG
    if {$DEBUG == 1} {
    puts $s
    }
}

proc system_cmd {cmd} {
    global DEBUG

    if {$DEBUG == 1} {
			puts "Executing: $cmd"
    }
    if { [catch { catch [eval exec $cmd] msg1} msg2] } {
			puts "Error: $cmd failed: $msg2"
			echo "Error: $cmd failed: $msg2"
			return 0
    }
    return 1
}

proc frc_copy {src dst} {
    system_cmd "cp -r -f $src $dst"
}

proc rm_old_folders {} {

	 my_info_puts "Info: Deleting old folders before regeneration"
	 set currdir [pwd]
	 my_info_puts "current dir is $currdir"
	 system_cmd "rm -rf base_kr_top"
    system_cmd "rm -rf rst_ctrl"
	 system_cmd "rm -rf work_rst_ctrl"
    system_cmd "rm -rf reconfig"
	 system_cmd "rm -rf work_reconfig"
	 system_cmd "rm -rf work"
	 system_cmd "rm -rf libraries"
	 my_info_puts "Info: Done deleting old folders"
}

# creates megawizard ip to stay current
proc create_ip {ip_sim} {
       
    global FORCE_MW_REGEN

    if {$FORCE_MW_REGEN == 0 && [file exists $ip_sim]} {
	return;
    }
	
    set bstr [split $ip_sim "/"]
    set ip_base_name [lindex $bstr 1]
    set ip_name "${ip_base_name}/${ip_base_name}.v"
    
    if {[file exists $ip_name] == 0} {
			puts "Error: cannot find ip file : $ip_name"
			echo "Error: cannot find ip file : $ip_name"
			return 0
    }

    puts "Info: Generating IP: $ip_name"

    if { [catch {exec qmegawiz -silent $ip_name} msg] } {
			puts $msg
			puts "Error: qmegawiz -silent $ip_name failed"
			echo "Error: qmegawiz -silent $ip_name failed"
    }
    return 1
}

# compiles atom from quartus installation in atoms workspace
proc compile_atoms {} {
    global QROOT

    my_info_puts "Info: begin compiling quartus atoms"

    vlib work_atoms
    vmap work_atoms work_atoms

    vlog -work work_atoms $QROOT/eda/sim_lib/altera_primitives.v
    vlog -work work_atoms $QROOT/eda/sim_lib/220model.v
    vlog -work work_atoms $QROOT/eda/sim_lib/sgate.v
    vlog -work work_atoms $QROOT/eda/sim_lib/altera_mf.v
    vlog -work work_atoms -sv $QROOT/eda/sim_lib/altera_lnsim.sv
    vlog -work work_atoms $QROOT/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v
    vlog -work work_atoms $QROOT/eda/sim_lib/stratixv_atoms.v
    vlog -work work_atoms $QROOT/eda/sim_lib/stratixv_hssi_atoms.v
    vlog -work work_atoms $QROOT/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v

    my_info_puts "Info: end compiling quartus atoms"
}

# set-up the reconfig controller dir and compile files with qmegawiz
proc setup_reconfig_ctrl {} {
    global MW_RECONFIG_SIM

    my_info_puts "Info: begin set-up of reconfig controller"
    set ip   "reconfig/reconfig.v"

    if { [file exists "reconfig"] == 0 } {
			# create dir
			system_cmd "mkdir reconfig"
    }
	 
	 frc_copy "./reconfig.v" $ip
	 system_cmd "chmod 644 $ip"

    # create ip
    if {[create_ip $MW_RECONFIG_SIM] == 0} {
    return 0
    }

    my_info_puts "Info: end setup reconfig controller"
    return 1
}

# compiles reconfig controller files from generated sim reconfig workspace
proc compile_reconfig_ctrl {} {
    global MW_RECONFIG_SIM

    if { [file exists "reconfig"] == 0 } {
			# create ip
			setup_reconfig_ctrl
    }

    my_info_puts "Info: begin compiling reconfig"
    vlib work_reconfig
    vmap work_reconfig work_reconfig

	 vlog -sv -work work_reconfig $MW_RECONFIG_SIM/alt_xcvr_reconfig/altera_xcvr_functions.sv
    vlog -sv -work work_reconfig $MW_RECONFIG_SIM/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
    vlog -sv -work work_reconfig $MW_RECONFIG_SIM/alt_xcvr_reconfig/sv_xcvr_h.sv
    vlog -sv -work work_reconfig $MW_RECONFIG_SIM/alt_xcvr_reconfig/sv_xcvr_dfe_cal_sweep_h.sv

    foreach rcf [glob $MW_RECONFIG_SIM/alt_xcvr_reconfig/*.v] {
      vlog -work work_reconfig $rcf 
    }
    foreach rcsf [glob $MW_RECONFIG_SIM/alt_xcvr_reconfig/*.sv] {
      vlog -sv -work work_reconfig $rcsf 
    }

    my_info_puts "Info: end compiling reconfig"
}

# set-up the reset controller dir and compile files with qmegawiz
proc setup_reset_controller {} {
    global MW_RESET_SIM

    my_info_puts "Info: begin set-up of reset controller"
    set ip   "rst_ctrl/rst_ctrl.v"

    if { [file exists "rst_ctrl"] == 0 } {
			# create dir
			system_cmd "mkdir rst_ctrl"
    }
	 
    frc_copy "./rst_ctrl.v" $ip
    system_cmd "chmod 644 $ip"

    # create ip
    if {[create_ip $MW_RESET_SIM] == 0} {
    return 0
    }

    my_info_puts "Info: end setup reset controller"
    return 1
}

# compiles reset controller files from generated sim workspace
proc compile_rst_ctrl {} {
    global MW_RESET_SIM

    if { [file exists "rst_ctrl"] == 0 } {
			# create ip
			setup_reset_controller
    }

    my_info_puts "Info: begin compile reset controller"
    vlib work_rst_ctrl
    vmap work_rst_ctrl work_rst_ctrl

    vlog -sv  -work work_rst_ctrl $MW_RESET_SIM/altera_xcvr_reset_control/altera_xcvr_functions.sv
    vlog -sv  -work work_rst_ctrl $MW_RESET_SIM/altera_xcvr_reset_control/alt_xcvr_resync.sv
    vlog -sv  -work work_rst_ctrl $MW_RESET_SIM/altera_xcvr_reset_control/alt_xcvr_reset_counter.sv
    vlog -sv  -work work_rst_ctrl $MW_RESET_SIM/altera_xcvr_reset_control/altera_xcvr_reset_control.sv

    my_info_puts "Info: end compile reset controller"
}

# set-up the KR PHY dir and compile files with qmegawiz
proc setup_base_kr_top   {} {
    global MW_BASEKR_SIM

    my_info_puts "Info: begin set-up of Base-KR PHY"
    set ip   "base_kr_top/base_kr_top.v"

    if { [file exists "base_kr_top"] == 0 } {
			# create dir
			system_cmd "mkdir base_kr_top"
    }
	 
    frc_copy "./base_kr_top.v" $ip
    system_cmd "chmod 644 $ip"

    # create ip
    if {[create_ip $MW_BASEKR_SIM] == 0} {
    return 0
    }

    my_info_puts "Info: end setup Base-KR PHY"
    return 1
}

# compiles Base KR IP files from generated sim workspace
proc compile_base_kr_top {} {
    global MW_BASEKR_SIM

    if { [file exists "base_kr_top"] == 0 } {
			# create ip
			setup_base_kr_top
    }

    my_info_puts "Info: begin compile Base-KR PHY"
    
    set QSYS_SIMDIR $MW_BASEKR_SIM 
	 #vlib work
	 vmap work work
    source $MW_BASEKR_SIM/mentor/msim_setup.tcl
    dev_com
    com
    my_info_puts "Info: end compile Base KR PHY"
}





# compile the mgmt_master design for the test harness
proc compile_mgmt_master_work {} {
    global MW_RECONFIG_SIM
    global ELAB_1G_10G

    my_info_puts "Info: begin compiling mgmt_master_work"
    #vlib work
    vmap work work

    vlog -sv ./mgmt_commands_h.sv
    vlog -sv ./mgmt_functions_h.sv
    vlog -sv $MW_RECONFIG_SIM/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv
    vlog -sv ./mgmt_memory_map.sv
    vlog -sv ./mgmt_cpu.sv
    vlog -sv ./th_mgmt_prog_n.sv
    vlog -sv ./th_mgmt_master.sv

    my_info_puts "Info: end compiling mgmt_master_work"
}





# compile the reconfig bundle
proc compile_reconfig_bundle {} {
    global EN_ATX_1G

    my_info_puts "Info: begin compiling reconfig_bundle"

    # the reconfig_bundle needs the reconfig controller and mgmt master
    compile_reconfig_ctrl
    
    vlib work_reconfig
    vmap work_reconfig work_reconfig

    vlog -sv -work work_reconfig ./rom_all_modes.v

    vlog -sv -work work_reconfig ./arbiter.v
    vlog -sv -work work_reconfig ./channel_sel.sv
    vlog -sv -work work_reconfig ./ctle_states.sv
    vlog -sv -work work_reconfig ./dfe_states.sv
    vlog -sv -work work_reconfig ./mif_states.sv
    vlog -sv -work work_reconfig ./pma_states.sv
    vlog -sv -work work_reconfig ./user_avmm_if_sm.sv
    vlog -sv -work work_reconfig ./user_reconfig_access.sv
    vlog -sv -work work_reconfig ./reconfig_master.sv
    vlog -sv -work work_reconfig ./sv_rcn_bundle.sv

    my_info_puts "Info: end compiling reconfig_bundle"
}

# compile the test_harness
proc compile_test_harness {} {
    
    my_info_puts "Info: begin compiling test_harness"
    #vlib work
    vmap work work
    
    vlog     ./checker_fifo.v
    vlog -sv ./xgmii_src.sv
    vlog     ./xgmii_sink.v
    vlog     ./prbs_poly.v
    vlog     ./prbs_generator.v
    vlog     ./prbs_checker.v

    # the test harness needs the mgmt master
    compile_mgmt_master_work
    
    vlog -sv ./gige_generator.sv
    vlog -sv ./gige_checker.sv
    vlog -sv ./gige_sync_fsm.sv
    vlog -sv ./test_harness.sv

    my_info_puts "Info: end compiling test_harness"
}

# compile the reconfig wrapper
proc compile_reconfig_wrapper {} {
    global MW_BASEKR_SIM
    global ELAB_1G_10G

    my_info_puts "Info: begin compiling reconfig wrapper"

    # components of the design
    compile_rst_ctrl
    compile_reconfig_bundle
    compile_base_kr_top
    #vlib work 
    vmap work ./work
    # compile altera_xcvr_functions needed for sv_rc_wrapper
    vlog -sv $MW_BASEKR_SIM/altera_xcvr_10gbase_kr/altera_xcvr_functions.sv
    vlog -sv $MW_BASEKR_SIM/altera_xcvr_10gbase_kr/mentor/altera_xcvr_functions.sv  
    # compile the rcn wrapper
    vlog -sv  ./sv_rcn_wrapper.sv 
    my_info_puts "Info: end compiling reconfig wrapper"
}

proc compile_de_wrapper {} {





    vlog -sv ./design_example_wrapper_nch.sv +define+SIM
}



proc compile_de {} {

	 # Remove old files
	 rm_old_folders

	vlib work
    # components of the design
    compile_reconfig_wrapper
    compile_test_harness
    compile_de_wrapper
  
}



#########################################################
# elaborate the design
proc elab_sim {} {
    vsim -novopt -t ps -L work -L work_lib -L base_kr_top -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver -L work_reconfig -L work_rst_ctrl design_example_wrapper_nch
}

# Main


proc run_sim {} {
    # Compile design
     compile_de
    # Elaborate design
     elab_sim
    # Run simulation
     run -all
}








