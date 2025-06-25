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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}

package require -exact qsys 12.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::system_info
package require alt_mem_if::gui::noise_gen

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera Uncorrelated Core Noise Generator"
set_module_property NAME altera_core_noise_generator
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_perf_monitors_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Core Noise Generator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false


set ::NOISE_GEN_ADDR_WIDTH 8
set ::NOISE_GEN_DAT_WIDTH 32

set ::CSR_TYPE_EXPORT "EXPORT"
set ::CSR_TYPE_SHARED "SHARED"
set ::CSR_TYPE_INTERNAL_JTAG "INTERNAL_JTAG"






::alt_mem_if::gui::noise_gen::create_parameters

::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ float 125
set_parameter_property REF_CLK_FREQ DISPLAY_NAME "PLL reference clock frequency"
set_parameter_property REF_CLK_FREQ UNITS Megahertz
set_parameter_property REF_CLK_FREQ DESCRIPTION "The frequency of the input clock that feeds the PLL.  Up to 4 decimal places of precision can be used."
set_parameter_property REF_CLK_FREQ DISPLAY_HINT columns:10

alt_mem_if::gui::system_info::create_generic_parameters


add_display_item "" "General Settings" GROUP ""
add_display_item "General Settings" NUM_BLOCKS PARAMETER ""
add_display_item "General Settings" NG_CSR_CONNECTION PARAMETER ""



if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property VALIDATION_CALLBACK ip_validate
	set_module_property COMPOSITION_CALLBACK ip_compose
} else {
	set_module_property COMPOSITION_CALLBACK combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_compose
}

proc ip_validate {} {
    set csr_type [get_parameter_value NG_CSR_CONNECTION]
	
	alt_mem_if::gui::system_info::validate_generic_component	

	if {[string compare -nocase $csr_type $::CSR_TYPE_EXPORT] == 0} {
		send_message warning "Noise generator can only be connected to debug GUI when using a CSR port connection with an internally connected JTAG Avalon Master"
	}

}



proc ip_compose {} {

    set num_core_noise_blocks [get_parameter_value NG_NUM_BLOCKS]
    set csr_type [get_parameter_value NG_CSR_CONNECTION]

	add_interface pll_ref_clk clock end
	add_instance pll_ref_clk altera_clock_bridge
	set_interface_property pll_ref_clk export_of pll_ref_clk.in_clk 
	set_interface_property pll_ref_clk PORT_NAME_MAP { pll_ref_clk pll_ref_clk }

    add_interface global_reset_n reset end
	add_instance global_reset_n altera_reset_bridge
    set_interface_property global_reset_n export_of global_reset_n.in_reset
	set_instance_parameter global_reset_n SYNCHRONOUS_EDGES none
    set_instance_parameter global_reset_n ACTIVE_LOW_RESET 1
	set_interface_property global_reset_n PORT_NAME_MAP { global_reset_n in_reset_n }

	set PLL pll0
	add_instance $PLL altera_mem_if_single_clock_pll
	set_instance_parameter $PLL REQ_CLK_FREQ 271
	set_instance_parameter $PLL REF_CLK_FREQ [get_parameter_value REF_CLK_FREQ]
	set_instance_parameter $PLL SPEED_GRADE [get_parameter_value SPEED_GRADE]

	set NOISE_GEN ngc0
	add_instance ${NOISE_GEN} altera_core_noise_generator_core
	set_instance_parameter ${NOISE_GEN} NUM_BLOCKS $num_core_noise_blocks
	set_instance_parameter ${NOISE_GEN} AVL_ADDR_WIDTH $::NOISE_GEN_ADDR_WIDTH
	set_instance_parameter ${NOISE_GEN} AVL_DATA_WIDTH $::NOISE_GEN_DAT_WIDTH
	set_instance_parameter ${NOISE_GEN} AVL_NUM_SYMBOLS [expr {$::NOISE_GEN_DAT_WIDTH / 8}]
	set_instance_parameter ${NOISE_GEN} AVL_SYMBOL_WIDTH 8


	add_connection "pll_ref_clk.out_clk/${PLL}.pll_ref_clk"
	add_connection "${PLL}.pll_clk/${NOISE_GEN}.pll_clk"
	add_connection "${PLL}.pll_locked/${NOISE_GEN}.pll_locked"

	add_connection "global_reset_n.out_reset/${PLL}.global_reset_n"
	add_connection "global_reset_n.out_reset/${NOISE_GEN}.global_reset_n"

	set use_bridge 0
	set use_jtag_master 0
	if {[string compare -nocase $csr_type $::CSR_TYPE_EXPORT] == 0} {
		set use_bridge 1
	} elseif {[string compare -nocase $csr_type $::CSR_TYPE_SHARED] == 0} {
		set use_bridge 1
		set use_jtag_master 1
	} elseif {[string compare -nocase $csr_type $::CSR_TYPE_INTERNAL_JTAG] == 0} {
		set use_jtag_master 1
	} else {
		send_message error "Unknown CSR port type $csr_type"
	}
	


	if {$use_jtag_master} {
		set JTAG_MASTER dmaster
		
		add_instance $JTAG_MASTER altera_jtag_avalon_master 

		set_instance_parameter $JTAG_MASTER USE_PLI "0"
		set_instance_parameter $JTAG_MASTER PLI_PORT "50000"

		add_connection "$JTAG_MASTER.master/${NOISE_GEN}.csr"
		add_connection "$JTAG_MASTER.master_reset/${NOISE_GEN}.soft_reset_n"
		add_connection "${NOISE_GEN}.csr_clk/${JTAG_MASTER}.clk"
		add_connection "global_reset_n.out_reset/${JTAG_MASTER}.clk_reset"

		set_connection_parameter_value "${JTAG_MASTER}.master/${NOISE_GEN}.csr" arbitrationPriority "1"
		set_connection_parameter_value "${JTAG_MASTER}.master/${NOISE_GEN}.csr" baseAddress "0x0000"

	} else {
		set_instance_parameter $NOISE_GEN EXPORT_SOFT_RESET false
	}

	if {$use_bridge} {
		add_instance clock_crossing_0 altera_avalon_mm_clock_crossing_bridge 

		set_instance_parameter clock_crossing_0 DATA_WIDTH $::NOISE_GEN_DAT_WIDTH
		set_instance_parameter clock_crossing_0 SYMBOL_WIDTH 8
		set_instance_parameter clock_crossing_0 ADDRESS_WIDTH [expr {$::NOISE_GEN_ADDR_WIDTH + 2}]

		add_connection clock_crossing_0.m0/${NOISE_GEN}.csr
		add_connection ${NOISE_GEN}.csr_clk/clock_crossing_0.m0_clk
		add_connection ${NOISE_GEN}.csr_reset/clock_crossing_0.m0_reset

		set_connection_parameter_value clock_crossing_0.m0/${NOISE_GEN}.csr arbitrationPriority "1"
		set_connection_parameter_value clock_crossing_0.m0/${NOISE_GEN}.csr baseAddress "0x0000"
		
		add_interface ng_csr avalon end
		set_interface_property ng_csr export_of clock_crossing_0.s0

		add_interface ng_csr_clk clock end
		add_instance ng_csr_clk altera_clock_bridge
		set_interface_property ng_csr_clk export_of ng_csr_clk.in_clk
		add_connection ng_csr_clk.out_clk/clock_crossing_0.s0_clk

		add_interface ng_csr_bridge_reset reset sync
		add_instance ng_csr_bridge_reset altera_reset_bridge
		set_interface_property ng_csr_bridge_reset export_of ng_csr_bridge_reset.in_reset
		add_connection ng_csr_bridge_reset.out_reset/clock_crossing_0.s0_reset
		add_connection ng_csr_clk.out_clk/ng_csr_bridge_reset.clk


	}
	
}

