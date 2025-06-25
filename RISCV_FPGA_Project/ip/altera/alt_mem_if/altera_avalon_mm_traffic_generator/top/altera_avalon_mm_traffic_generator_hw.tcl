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
package require alt_mem_if::gui::avalon_mm_traffic_gen
package require alt_mem_if::gui::system_info
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Avalon-MM Traffic Generator and BIST Engine"
set_module_property NAME altera_avalon_mm_traffic_generator
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_pattern_gen_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-MM Traffic Generator and BIST Engine"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property DATASHEET_URL "http://www.altera.com/literature/lit-external-memory-interface.jsp"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::avalon_mm_traffic_gen::create_parameters

alt_mem_if::gui::avalon_mm_traffic_gen::create_gui
set_parameter_property SPEED_GRADE VISIBLE false
set_parameter_property HARD_EMIF VISIBLE false



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

	_dprint 1 "Running IP Validation"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::avalon_mm_traffic_gen::validate_component

	if {([::alt_mem_if::util::qini::cfg_is_on alt_mem_if_lite_driver] || [string compare -nocase [get_parameter_value TG_USE_LITE_DRIVER] "true"] == 0) && 
            ([::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]) } {
		_eprint "Both Lite driver and POF driver are selected. Only 1 type of driver can be use for a design"
	}
}

proc ip_compose {} {

	_dprint 1 "Running IP Compose for [get_module_property NAME]"
	
	set TRAFFIC_GEN traffic_generator_0
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_lite_driver] || [string compare -nocase [get_parameter_value TG_USE_LITE_DRIVER] "true"] == 0} {
		add_instance $TRAFFIC_GEN simple_1mm_traffic_gen_core
	} elseif {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {
		add_instance $TRAFFIC_GEN pof_avalon_mm_traffic_generator_core
	} else {
		add_instance $TRAFFIC_GEN altera_avalon_mm_traffic_generator_core
	}
	foreach param_name [get_instance_parameters $TRAFFIC_GEN] {
		set_instance_parameter $TRAFFIC_GEN $param_name [get_parameter_value $param_name]
	}

	

	add_interface avl_clock clock end
	add_instance avl_clock altera_clock_bridge
	set_interface_property avl_clock export_of avl_clock.in_clk 
	set_interface_property avl_clock PORT_NAME_MAP { clk in_clk }
 
    add_interface avl_reset reset end
	add_instance avl_reset altera_reset_bridge
    set_interface_property avl_reset export_of avl_reset.in_reset
	if {[string compare -nocase [get_parameter_value TG_SOPC_COMPAT_RESET] "true"] == 0} {
		set_instance_parameter avl_reset SYNCHRONOUS_EDGES deassert
		add_connection "avl_clock.out_clk/avl_reset.clk"
	} else {
		set_instance_parameter avl_reset SYNCHRONOUS_EDGES none
	}
    set_instance_parameter avl_reset ACTIVE_LOW_RESET 1
	set_interface_property avl_reset PORT_NAME_MAP { reset_n in_reset_n }

        if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {
	        add_interface unique_done conduit end
	        set_interface_property unique_done export_of "${TRAFFIC_GEN}.unique_done"
	        alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN unique_done unique_done
                
	        add_interface unique_ready conduit end
	        set_interface_property unique_ready export_of "${TRAFFIC_GEN}.unique_ready"
	        alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN unique_ready unique_ready
                
	        add_interface coordinator_ready conduit end
	        set_interface_property coordinator_ready export_of "${TRAFFIC_GEN}.coordinator_ready"
	        alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN coordinator_ready coordinator_ready
        }

	add_interface status conduit end
	set_interface_property status export_of "${TRAFFIC_GEN}.status"
	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN status status
	
	if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "true"] == 0} {
		add_interface pnf conduit end
		set_interface_property pnf export_of "${TRAFFIC_GEN}.pnf"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN pnf pnf
	}

	if {[string compare -nocase [get_parameter_value TG_TWO_AVL_INTERFACES] "false"] == 0} {
		
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl avalon start
		} else {
			add_interface avl conduit end
		}

		set_interface_property avl export_of "${TRAFFIC_GEN}.avl"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN avl avl

	} else {
		
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl_w avalon start
			add_interface avl_r avalon start
		} else {
			add_interface avl_w conduit end
			add_interface avl_r conduit end
		}

		set_interface_property avl_w export_of "${TRAFFIC_GEN}.avl_w"
		set_interface_property avl_r export_of "${TRAFFIC_GEN}.avl_r"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN avl_w avl_w
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $TRAFFIC_GEN avl_r avl_r
	}
	
	
	
	add_connection "avl_clock.out_clk/${TRAFFIC_GEN}.avl_clock"
	add_connection "avl_reset.out_reset/${TRAFFIC_GEN}.avl_reset"


	if {[string compare -nocase [get_parameter_value TG_ENABLE_DRIVER_CSR_MASTER] "true"] == 0} {
	
		set CSR_BRIDGE csr_bridge
		add_instance ${CSR_BRIDGE} altera_avalon_mm_bridge

		set_instance_parameter ${CSR_BRIDGE} DATA_WIDTH 32
		set_instance_parameter ${CSR_BRIDGE} SYMBOL_WIDTH 8
		set_instance_parameter ${CSR_BRIDGE} ADDRESS_WIDTH 32

		add_connection "avl_clock.out_clk/${CSR_BRIDGE}.clk"
		add_connection "avl_reset.out_reset/${CSR_BRIDGE}.reset"

		add_connection "${CSR_BRIDGE}.m0/${TRAFFIC_GEN}.csr"
		set_connection_parameter_value "${CSR_BRIDGE}.m0/${TRAFFIC_GEN}.csr" baseAddress 0


		set CSR_MASTER "drv_csr_master"
		if {[string compare -nocase [get_parameter_value ENABLE_EMIT_BFM_MASTER] "true"] == 0} {
			add_instance $CSR_MASTER altera_avalon_mm_master_bfm
			
			set_instance_parameter $CSR_MASTER AV_ADDRESS_W 32
			set_instance_parameter $CSR_MASTER AV_SYMBOL_W 8
			set_instance_parameter $CSR_MASTER AV_NUMSYMBOLS 4
			set_instance_parameter $CSR_MASTER AV_BURSTCOUNT_W 1

			add_connection "avl_clock.out_clk/${CSR_MASTER}.clk"
			add_connection "avl_reset.out_reset/${CSR_MASTER}.clk_reset"
		
			add_connection "${CSR_MASTER}.master/${CSR_BRIDGE}.s0"
			set_connection_parameter_value "${CSR_MASTER}.master/${CSR_BRIDGE}.s0" baseAddress 0
		} else {
			add_instance ${CSR_MASTER} altera_jtag_avalon_master 
		
			set_instance_parameter ${CSR_MASTER} USE_PLI "0"
			set_instance_parameter ${CSR_MASTER} PLI_PORT "50000"
		
			add_connection "avl_clock.out_clk/${CSR_MASTER}.clk"
			add_connection "avl_reset.out_reset/${CSR_MASTER}.clk_reset"
		
			add_connection "${CSR_MASTER}.master/${CSR_BRIDGE}.s0"
			set_connection_parameter_value "${CSR_MASTER}.master/${CSR_BRIDGE}.s0" baseAddress 0
		}
	}
	
}


