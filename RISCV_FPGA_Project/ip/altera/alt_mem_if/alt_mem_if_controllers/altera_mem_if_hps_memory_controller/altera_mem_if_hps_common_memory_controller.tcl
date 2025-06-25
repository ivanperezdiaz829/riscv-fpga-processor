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


# +-----------------------------------
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
# +-----------------------------------

# +-----------------------------------
# |
# | Altera HPS Memory Controller
# |
# |
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 12.0
# |
package require -exact qsys 12.0

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini
package require alt_mem_if::util::iptclgen


# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# |
# +-----------------------------------

# +-----------------------------------
# |
set_module_property DESCRIPTION "Altera HPS ${UC_PROTOCOL} Memory Controller"
set_module_property NAME altera_mem_if_hps_${LC_PROTOCOL}_memory_controller
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_controller_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera HPS ${UC_PROTOCOL} Memory Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# |
# +-----------------------------------

# Hide the block diagram
add_display_item "" "Block Diagram" GROUP


# +-----------------------------------
# | Fileset Callbacks
# |
add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth

proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	# Add the toplevel
	set top_file "altera_mem_if_hps_memory_controller_top.sv"
	add_fileset_file [file join mentor $top_file] SYSTEM_VERILOG_ENCRYPT PATH [file join .. altera_mem_if_hps_memory_controller mentor $top_file] {MENTOR_SPECIFIC}
	add_fileset_file $top_file SYSTEM_VERILOG PATH [file join .. altera_mem_if_hps_memory_controller $top_file] $non_encryp_simulators
	
	set qdir $::env(QUARTUS_ROOTDIR)
	set windows_nios2_cmd_shell "$qdir/../nios2eds/Nios II Command Shell.bat"
	set linux_nios2_cmd_shell "$qdir/../nios2eds/nios2_command_shell.sh"
	set OS_WIN 0

	if {[file exists $windows_nios2_cmd_shell]} {
			set OS_WIN 1
	}

	set files [list hps_hmctl.v]
	if {$OS_WIN == 1} {
		set simulators [list mentor aldec]
	} else {
		set simulators [list mentor synopsys cadence aldec]
	}


	foreach f $files {
		foreach simulator $simulators {
			add_fileset_file hps_hmctl.v SYSTEM_VERILOG_ENCRYPT PATH [file join $simulator $f] [string toupper $simulator]_SPECIFIC
		}
	}
}

proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate Verilog simulation fileset for $name"

	# Add the toplevel
	set top_file "altera_mem_if_hps_memory_controller_top.sv"
	add_fileset_file $top_file SYSTEM_VERILOG PATH $top_file

	set qdir $::env(QUARTUS_ROOTDIR)
	set windows_nios2_cmd_shell "$qdir/../nios2eds/Nios II Command Shell.bat"
	set linux_nios2_cmd_shell "$qdir/../nios2eds/nios2_command_shell.sh"
	set OS_WIN 0

	if {[file exists $windows_nios2_cmd_shell]} {
			set OS_WIN 1
	}

	set files [list hps_hmctl.v]
	if {$OS_WIN == 1} {
		set simulators [list mentor aldec]
	} else {
		set simulators [list mentor synopsys cadence aldec]
	}

	foreach f $files {
		foreach simulator $simulators {
			add_fileset_file [file join $simulator $f] VERILOG_ENCRYPT PATH [file join $simulator $f] [string toupper $simulator]_SPECIFIC
		}
	}
}

proc generate_synth {name} {
	# not supported
	_dprint 1 "Preparing to generate synthesis fileset for $name"
}

# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter MAX_PENDING_READ_TRANSACTION INTEGER 16
set_parameter_property MAX_PENDING_READ_TRANSACTION UNITS None
set_parameter_property MAX_PENDING_READ_TRANSACTION ALLOWED_RANGES 0:1024
set_parameter_property MAX_PENDING_READ_TRANSACTION DERIVED True

# |
# +-----------------------------------

# +-----------------------------------
# | Helper functions
# |
proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for controller"

}
# |
# +------

# +-----------------------------------
# | Build the GUI
# |
alt_mem_if::gui::afi::set_protocol "$UC_PROTOCOL"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "$UC_PROTOCOL"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "$UC_PROTOCOL"
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

create_hdl_parameters

alt_mem_if::gui::ddrx_controller::create_gui 1
alt_mem_if::gui::common_ddr_mem_model::create_gui

# |
# +-----------------------------------

# +-----------------------------------
# | Elaboration/validation callbacks
# |
if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

	# Validation order matters. It must be system_info, memory model, AFI, then controller/phy
	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component
}

proc ip_elaborate {} {

	_dprint 1 "Running IP Elaboration"

	# Validation order matters. It must be system_info, memory model, AFI, then controller/phy
	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::ddrx_controller::elaborate_component

	# KALEN: This is a magic setting
	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		set_parameter_value MAX_PENDING_READ_TRANSACTION 48
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		set_parameter_value MAX_PENDING_READ_TRANSACTION 32
	} elseif {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		# MW TODO: derive an appropriate value for QR. This is just a stand-in for now.
		set_parameter_value MAX_PENDING_READ_TRANSACTION 32
	}

	# # +-----------------------------------
	# # | connection point afi_clk
	# # |
	# add_interface afi_clk clock end
	# set_interface_property afi_clk clockRate 0

	# set_interface_property afi_clk ENABLED true

	# add_interface_port afi_clk afi_clk clk Input 1
	# # |
	# # +-----------------------------------

	# # +-----------------------------------
	# # | connection point afi_reset_n
	# # |
	# add_interface afi_reset reset end
	# set_interface_property afi_reset synchronousEdges NONE

	# set_interface_property afi_reset ENABLED true

	# add_interface_port afi_reset afi_reset_n reset_n Input 1
	# # |
	# # +-----------------------------------

	# +-----------------------------------
	# | connection point ctl_reset_n
	# |
	add_interface ctl_reset reset end
	set_interface_property ctl_reset synchronousEdges NONE

	set_interface_property ctl_reset ENABLED true

	add_interface_port ctl_reset ctl_reset_n reset_n Input 1
	# |
	# +-----------------------------------

	# # +-----------------------------------
	# # | connection point afi_half_clk
	# # | 
	# add_interface afi_half_clk clock end
	# set_interface_property afi_half_clk clockRate 0
	
	# set_interface_property afi_half_clk ENABLED true
	
	# add_interface_port afi_half_clk afi_half_clk clk Input 1
	# # | 
	# # +-----------------------------------
	
	# +-----------------------------------
	# | connection point ctl_clk
	# |
	add_interface ctl_clk clock end
	set_interface_property ctl_clk clockRate 0

	set_interface_property ctl_clk ENABLED true

	add_interface_port ctl_clk ctl_clk clk Input 1
	# |
	# +-----------------------------------

	# +-----------------------------------
	# | connection point csr clk and reset
	# |
	add_interface csr_clk clock end
	set_interface_property csr_clk clockRate 0

	set_interface_property csr_clk ENABLED true

	add_interface_port csr_clk csr_clk clk Input 1

	add_interface csr_reset_n reset end
	set_interface_property csr_reset_n associatedClock csr_clk
	set_interface_property csr_reset_n synchronousEdges DEASSERT

	set_interface_property csr_reset_n ENABLED true

	add_interface_port csr_reset_n csr_reset_n reset_n Input 1

	# |
	# +-----------------------------------

	# +-----------------------------------
	# | conduit for HPS MPFE ports
	# |

	::alt_mem_if::gen::uniphy_interfaces::hps_controller_f2sdram "hps"
	
	# |
	# +-----------------------------------

	# Create the other signals interface
	# add_interface status conduit end
	# set_interface_property status ENABLED true

	# add_interface_port status local_init_done local_init_done Output 1
	# add_interface_port status local_cal_success local_cal_success Output 1
	# add_interface_port status local_cal_fail local_cal_fail Output 1

	# Add CSR slave interface
	# HPS has a 32-bit MMR data port
	set_parameter_value CSR_DATA_WIDTH 32
	set_parameter_value CSR_ADDR_WIDTH 8
	::alt_mem_if::gen::uniphy_interfaces::csr_slave "controller"

	# Add AFI interface
	::alt_mem_if::gen::uniphy_interfaces::afi "HARD" "controller" "afi" 1 1 1

	::alt_mem_if::gen::uniphy_interfaces::hard_phy_cfg "controller"

	# Create various sideband interfaces
	# ::alt_mem_if::gen::uniphy_interfaces::ddrx_nextgen_sideband_signals


	# Set the toplevel fileset name for all filesets. This must be done
	# in the elaboration callback
	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL "altera_mem_if_hps_memory_controller_top"
	}

}
