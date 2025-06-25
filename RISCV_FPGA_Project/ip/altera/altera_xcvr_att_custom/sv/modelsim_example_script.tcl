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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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


#############################################################################################
#
# This is an example file for compilation/simulation of Custom PHY instance in Modelsim 
#
# You can modify this script and use it to compile/simulate your design depending on  
# the following Modelsim license options:
# (1) Mixed language license 
#    - Top-level PHY IP variant can be in Verilog or VHDL
#    - Underlying PHY IP files are in plaintext Verilog 
#    - Testbench can be in Verilog or VHDL
#      
# (2) Non-mixed language license   
#     (a) Verilog Only:
#        - Top-level PHY IP variant should be in Verilog
#        - Underlying PHY IP files are in plaintext Verilog
#        - Testbench should be in Verilog
#
#     (b) VHDL Only:
#        - Top-level PHY IP variant should be in VHDL
#        - Underlying PHY IP files are in encrypted Verilog
#        - Testbench should be in VHDL
# 
# Please use the appropriate sections of this script that suits your Modelsim license.
#
##############################################################################################

set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)

#################################################################################
##
## Set your language, simulator and top level design name here
## e.g. vsim -c -do "do ./test_sim/altera_xcvr_custom_phy/modelsim_example_script.tcl verilog stratixv modelsim test test_tst"
## 
#################################################################################
# language = verilog (verilog variant of the PHY IP) or vhdl (vhdl variant of the PHY IP)
# defaulted to verilog
set language $1
if {$language != "verilog" && $language != "vhdl"} {
	echo "invalid setting for language: $language. valid settings are verilog and vhdl"
	exit
}

# simulator = modelsim or VCS
# defaulted to modelsim
# This file not support VCS yet, you can use this file as reference for VCS
set simulator $2
if {$simulator != "modelsim"} {
	echo "invalid setting for simulator: $simulator. valid settings are modelsim"
	exit
}

## Set your top level design name here
##set dut_name <top level design name as generted in Quartus or Qsys>
set dut_name $3
if {$dut_name == ""} {
	echo "Missing top level design name: $dut_name"
}

## Set your test bench name here
##set tb_name <test bench>
set tb_name $4
if {$tb_name == ""} {
	echo "Missing test bench name: $tb_name"
}

puts " simulator=$simulator"
puts " language=$language"

#################################################################################
## Set directory path according to simulator
## unenc_file_dir for Quartus unecrypted files
## enc_file_dir is for Quartus ecrypted files
## This file only support modelsim simulation. You can use the following path
## as reference of other simulator
#################################################################################
## Modelsim Verilog/Modelsim VHDL with Mixed language license 
if { $simulator == "modelsim" } {
	set enc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy/mentor  
	if {$language == "verilog"} {
    		set unenc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy 
	} else {
		## Modelsim-AE / Models
		set unenc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy/mentor
	}
	
} elseif { $simulator == "VCS" } {
		set unenc_file_dir $dut_name_sim/altera_xcvr_custom_phy 
		set enc_file_dir $dut_name_sim/altera_xcvr_custom_phy/synopsys   

} elseif { $simulator == "Aldec" } {
		set unenc_file_dir $dut_name_sim/altera_xcvr_custom_phy 
		set enc_file_dir $dut_name_sim/altera_xcvr_custom_phy/Aldec   
		
} elseif { $simulator == "VCS" } {
		set unenc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy 
		set enc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy/synopsys   

} elseif { $simulator == "NCSIM" } {
		set unenc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy 
		set enc_file_dir ./${dut_name}_sim/altera_xcvr_custom_phy/cadence
		 
}

exec rm -rf work
vlib work
puts " unenc_file_dir=$unenc_file_dir"
puts " enc_file_dir=$enc_file_dir"

if {$language == "verilog"} {
#################################################################################
## 
## Compilation in Modelsim  
##
## Use this section for (1) Mixed language license or (2a) Verilog only license
##
#################################################################################

	###########################################
	# Stratix V library files 
	###########################################
	vlog -sv $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim.sv
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_atoms.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/stratixv_hssi_atoms.v
	
	###########################################
	# Custom PHY IP files - plain Verilog
	###########################################
	vlog -sv ./test/altera_wait_generate.v
	vlog -sv ./test/altera_xcvr_functions.sv
	vlog -sv ./test/alt_xcvr_csr_common_h.sv
	vlog -sv ./test/alt_reset_ctrl_lego.sv
	vlog -sv ./test/alt_xcvr_resync.sv
	vlog -sv ./test/alt_reset_ctrl_tgx_cdrauto.sv
	vlog -sv ./test/alt_xcvr_csr_common.sv
	vlog -sv ./test/alt_xcvr_csr_selector.sv
	vlog -sv ./test/alt_xcvr_mgmt2dec.sv
	vlog -sv ./test/altera_xcvr_custom.sv
	vlog -sv ./test/stratixv_hssi_pipe_gen1_2_rbc.sv
	vlog -sv ./test/stratixv_hssi_pipe_gen3_rbc.sv
	vlog -sv ./test/sv_reconfig_bundle_merger.sv
	vlog -sv ./test/sv_reconfig_bundle_to_xcvr.sv
	vlog -sv ./test/sv_reconfig_bundle_to_ip.sv
	vlog -sv ./test/sv_pma_att.sv
	vlog -sv ./test/sv_rx_pma_att.sv
	vlog -sv ./test/sv_tx_pma_att.sv
	vlog -sv ./test/sv_xcvr_avmm.sv
	vlog -sv ./test/sv_xcvr_att_custom_native.sv
	vlog -sv ./test/sv_xcvr_data_adapter.sv
	vlog -sv ./test/sv_xcvr_att_native.sv
	vlog -sv ./test/sv_xcvr_plls.sv
		
	################################################
	# Top-level Verilog variant created by Qmegawiz
	################################################
	vlog $dut_name.v
} else {
	###################################################################################
	## This section is used for (2b) VHDL only license
	###################################################################################
	###################################################
	# Stratix V library files 
	##################################################
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_atoms_for_vhdl.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v
	vlog $QUARTUS_ROOTDIR/eda/sim_lib/mentor/stratixv_hssi_atoms_for_vhdl.v
	
	##################################################
	# Custom PHY IP files - mentor tagged 
	##################################################
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/altera_wait_generate.v
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/altera_xcvr_functions.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_xcvr_csr_common_h.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_reset_ctrl_lego.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_xcvr_resync.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_reset_ctrl_tgx_cdrauto.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_xcvr_csr_common.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_xcvr_csr_selector.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/alt_xcvr_mgmt2dec.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/altera_xcvr_custom.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/stratixv_hssi_pipe_gen1_2_rbc.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/stratixv_hssi_pipe_gen3_rbc.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_reconfig_bundle_merger.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_reconfig_bundle_to_xcvr.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_reconfig_bundle_to_ip.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_pma_att.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_rx_pma_att.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_tx_pma_att.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_xcvr_avmm.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_xcvr_att_custom_native.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_xcvr_data_adapter.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_xcvr_att_native.sv
	vlog -sv ./test_sim/altera_xcvr_custom_phy/mentor/sv_xcvr_plls.sv
	
	# Top-level VHDL variant created by Qmegawiz
	vcom -93 $dut_name.vhd
}

###########################################
# Add your custom library compilation here
###########################################
set custom_compilation custom_lib.tcl
if {[file exists $custom_compilation]} {
	source $custom_compilation
}

###########################################
## Top-level testbench 
###########################################
# Verilog testbench if Modelsim license is Verilog Only
vlog $tb_name.v
# VHDL testbench if Modelsim license is mixed language or VHDL Only
#vcom -93 ./$tb_name.vhd

#################################################################################
## 
## Simulation (common to all license types)
##
#################################################################################

###########################################
# Invoke simulator 
###########################################
vsim -c -novopt -t 1ps $tb_name 

###########################################
# Run and Quit your simulation
###########################################
run -all
quit -sim
exit
