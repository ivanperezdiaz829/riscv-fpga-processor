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
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils


namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "Altera DDR2 Nextgen Memory Controller"
set_module_property NAME altera_mem_if_nextgen_ddr2_controller
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_controller_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR2 Nextgen Memory Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


alt_mem_if::gui::afi::set_protocol "DDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "DDR2"
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters

alt_mem_if::gui::ddrx_controller::create_gui 1
alt_mem_if::gui::common_ddr_mem_model::create_gui

if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
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
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component

	if {[string compare -nocase [get_parameter_value NEXTGEN] "false"] == 0} {
		_eprint "Parameter NEXTGEN must be true for the Nextgen controller!"
	}

}

proc ip_compose {} {

	_dprint 1 "Running IP Compose for [get_module_property NAME]"

	set CONTROLLER_CORE ng0
	add_instance $CONTROLLER_CORE altera_mem_if_nextgen_ddr2_controller_core

	set ADAPTER a0

	foreach param_name [get_instance_parameters $CONTROLLER_CORE] {
		set_instance_parameter $CONTROLLER_CORE $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $CONTROLLER_CORE
	
	set_instance_parameter $CONTROLLER_CORE DISABLE_CHILD_MESSAGING true

	add_interface afi_reset reset sink
	add_instance afi_reset altera_reset_bridge
    set_interface_property afi_reset export_of afi_reset.in_reset
    set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
    set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
	set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n in_reset_n }

	add_interface afi_clk clock end
	add_instance afi_clk altera_clock_bridge
	set_interface_property afi_clk export_of afi_clk.in_clk
	set_interface_property afi_clk PORT_NAME_MAP { afi_clk in_clk }

	add_interface afi_half_clk clock end
	add_instance afi_half_clk altera_clock_bridge
	set_interface_property afi_half_clk export_of afi_half_clk.in_clk
	set_interface_property afi_half_clk PORT_NAME_MAP { afi_half_clk in_clk }

	add_interface status conduit end
	set_interface_property status export_of "${CONTROLLER_CORE}.status"
	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE status status
	
	if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
		add_interface csr avalon end
		set_interface_property csr export_of "${CONTROLLER_CORE}.csr"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE csr csr
	}

	add_interface afi conduit end
	set_interface_property afi export_of "${CONTROLLER_CORE}.afi"
	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE afi afi

	if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
		add_interface user_refresh conduit end
		set_interface_property user_refresh export_of "${CONTROLLER_CORE}.user_refresh"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE user_refresh user_refresh
	}

	if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
		add_interface self_refresh conduit end
		set_interface_property self_refresh export_of "${CONTROLLER_CORE}.self_refresh"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE self_refresh self_refresh
	}
	
	if {[string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
		add_interface deep_powerdn conduit end
		set_interface_property deep_powerdn export_of "${CONTROLLER_CORE}.deep_powerdn"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE deep_powerdn deep_powerdn
	}

	if {[string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "true"] == 0} {
		add_interface local_powerdown conduit end
		set_interface_property local_powerdown export_of "${CONTROLLER_CORE}.local_powerdown"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE local_powerdown local_powerdown
	}

	if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
		add_interface ecc_interrupt conduit end
		set_interface_property ecc_interrupt export_of "${CONTROLLER_CORE}.ecc_interrupt"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE ecc_interrupt ecc_interrupt
	}

	add_connection "afi_clk.out_clk/${CONTROLLER_CORE}.afi_clk"
	add_connection "afi_half_clk.out_clk/${CONTROLLER_CORE}.afi_half_clk"
	add_connection "afi_reset.out_reset/${CONTROLLER_CORE}.afi_reset"

	if {[string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "true"] == 0} {
		add_instance $ADAPTER alt_mem_ddrx_mm_st_converter
		set_instance_parameter $ADAPTER AVL_SIZE_WIDTH [get_parameter_value AVL_SIZE_WIDTH]
		set_instance_parameter $ADAPTER AVL_ADDR_WIDTH [get_parameter_value AVL_ADDR_WIDTH]
		set_instance_parameter $ADAPTER AVL_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]
		set_instance_parameter $ADAPTER LOCAL_ID_WIDTH [get_parameter_value LOCAL_ID_WIDTH]
		set_instance_parameter $ADAPTER CFG_DWIDTH_RATIO [get_parameter_value DWIDTH_RATIO]
		set_instance_parameter $ADAPTER AVL_SYMBOL_WIDTH [get_parameter_value AVL_SYMBOL_WIDTH]
		set_instance_parameter $ADAPTER CTL_AUTOPCH_EN [get_parameter_value CTL_AUTOPCH_EN]
		set_instance_parameter $ADAPTER MULTICAST_EN [get_parameter_value MULTICAST_EN]
		set_instance_parameter $ADAPTER ENABLE_CTRL_AVALON_INTERFACE [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]
		set_instance_parameter $ADAPTER AVL_BYTE_ENABLE [get_parameter_value BYTE_ENABLE]
                set_instance_parameter $ADAPTER CTL_ECC_ENABLED [get_parameter_value CTL_ECC_ENABLED]

		if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
			set_instance_parameter $ADAPTER MAX_PENDING_READ_TRANSACTION 48
		} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
			set_instance_parameter $ADAPTER MAX_PENDING_READ_TRANSACTION 32
		} elseif {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			set_instance_parameter $ADAPTER MAX_PENDING_READ_TRANSACTION 32
		}

		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl avalon end
		} else {
			add_interface avl conduit end
		}
		set_interface_property avl export_of "${ADAPTER}.avl"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $ADAPTER avl avl


		if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
			add_interface avl_multicast_write conduit end
			set_interface_property avl_multicast_write export_of "${ADAPTER}.avl_multicast_write"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $ADAPTER avl_multicast_write avl_multicast_write
		}
	
		if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
			add_interface autoprecharge_req conduit end
			set_interface_property autoprecharge_req export_of "${ADAPTER}.autoprecharge_req"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $ADAPTER autoprecharge_req autoprecharge_req
		}

	        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
	        	add_interface avl_rdata_error conduit end
	        	set_interface_property avl_rdata_error export_of "${ADAPTER}.avl_rdata_error"
	        	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $ADAPTER avl_rdata_error avl_rdata_error
	        }

		add_connection "${ADAPTER}.native_st/${CONTROLLER_CORE}.native_st"


		add_connection "afi_clk.out_clk/${ADAPTER}.afi_clk"
		add_connection "afi_half_clk.out_clk/${ADAPTER}.afi_half_clk"
		add_connection "afi_reset.out_reset/${ADAPTER}.afi_reset"
		add_connection "afi_reset.out_reset/${ADAPTER}.afi_half_reset"

	} else {
		add_interface native_st conduit end
		set_interface_property native_st export_of "${CONTROLLER_CORE}.native_st"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER_CORE native_st native_st
	}



}

