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
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "UniPHY LPDDR2 AFI Splitter"
set_module_property NAME altera_mem_if_lpddr2_afi_splitter
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_afi_mux_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY LPDDR2 AFI Splitter"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::afi::set_protocol "LPDDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "LPDDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters


alt_mem_if::gui::common_ddr_mem_model::create_gui



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
	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"


	add_interface afi conduit end
	set_interface_property afi ENABLED true
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0} {
		add_interface_port afi afi_addr afi_addr input [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port afi afi_cke afi_cke input [get_parameter_value AFI_CS_WIDTH]
		add_interface_port afi afi_cs_n afi_cs_n input [get_parameter_value AFI_CS_WIDTH]
		add_interface_port afi afi_dqs_burst afi_dqs_burst input [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port afi afi_wdata_valid afi_wdata_valid input [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port afi afi_wdata afi_wdata input [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port afi afi_dm afi_dm input [get_parameter_value AFI_DM_WIDTH]
		add_interface_port afi afi_rdata afi_rdata output [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port afi afi_rdata_en afi_rdata_en input [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi afi_rdata_en_full afi_rdata_en_full input [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi afi_rdata_valid afi_rdata_valid output [get_parameter_value AFI_RATE_RATIO]
		add_interface_port afi afi_mem_clk_disable afi_mem_clk_disable input [get_parameter_value AFI_CLK_PAIR_COUNT]
		add_interface_port afi afi_init_req afi_init_req input 1
		add_interface_port afi afi_cal_req afi_cal_req input 1
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
			add_interface_port afi afi_seq_busy afi_seq_busy output [get_parameter_value MEM_IF_CS_WIDTH]
			add_interface_port afi afi_ctl_refresh_done afi_ctl_refresh_done input [get_parameter_value MEM_IF_CS_WIDTH]
			add_interface_port afi afi_ctl_long_idle afi_ctl_long_idle input [get_parameter_value MEM_IF_CS_WIDTH]
		}
		add_interface_port afi afi_wlat afi_wlat output [get_parameter_value AFI_WLAT_WIDTH]
		add_interface_port afi afi_rlat afi_rlat output [get_parameter_value AFI_RLAT_WIDTH]
		add_interface_port afi afi_cal_success afi_cal_success output 1
		add_interface_port afi afi_cal_fail afi_cal_fail output 1
	} else {
		add_interface_port afi afi_addr afi_addr input 20
		add_interface_port afi afi_ba afi_ba input 3
		add_interface_port afi afi_cke afi_cke input 2
		add_interface_port afi afi_cs_n afi_cs_n input 2
		add_interface_port afi afi_ras_n afi_ras_n input 1
		add_interface_port afi afi_we_n afi_we_n input 1
		add_interface_port afi afi_cas_n afi_cas_n input 1
		add_interface_port afi afi_rst_n afi_rst_n input 1
		add_interface_port afi afi_odt afi_odt input 2
		add_interface_port afi afi_mem_clk_disable afi_mem_clk_disable input 1
		add_interface_port afi afi_init_req afi_init_req input 1
		add_interface_port afi afi_cal_req afi_cal_req input 1
    	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
	    	add_interface_port afi afi_seq_busy afi_seq_busy output [get_parameter_value MEM_IF_CS_WIDTH]
			add_interface_port afi afi_ctl_refresh_done afi_ctl_refresh_done input [get_parameter_value MEM_IF_CS_WIDTH]
    		add_interface_port afi afi_ctl_long_idle afi_ctl_long_idle input [get_parameter_value MEM_IF_CS_WIDTH]
		}
		add_interface_port afi afi_dqs_burst afi_dqs_burst input 5
		add_interface_port afi afi_wdata_valid afi_wdata_valid input 5
		add_interface_port afi afi_wdata afi_wdata input 80
		add_interface_port afi afi_dm afi_dm input 10
		add_interface_port afi afi_rdata afi_rdata output 80
		add_interface_port afi afi_rdata_en afi_rdata_en input 5
		add_interface_port afi afi_rdata_en_full afi_rdata_en_full input 5
		add_interface_port afi afi_rdata_valid afi_rdata_valid output 1
		add_interface_port afi afi_wlat afi_wlat output 4
		add_interface_port afi afi_rlat afi_rlat output 5
		add_interface_port afi afi_cal_success afi_cal_success output 1
		add_interface_port afi afi_cal_fail afi_cal_fail output 1
	}

	set controller_afi_port_list [get_interface_ports afi]

	foreach port $controller_afi_port_list {
		if {[regexp -nocase "afi_cal_success|afi_cal_fail|afi_init_req|afi_cal_req" $port match] == 0} {
			set_port_property $port VHDL_TYPE STD_LOGIC_VECTOR
		}
	}


	if {[string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::afi "LPDDR2" "controller" "mux_afi" 1 1
	} else {
		::alt_mem_if::gen::uniphy_interfaces::afi "HARD" "controller" "mux_afi" 1 1
	}

	set split_ports [list \
			afi_mem_clk_disable \
			afi_init_req \
			afi_cal_req \
			afi_seq_busy \
			afi_ctl_refresh_done \
			afi_ctl_long_idle \
		]

	foreach port $controller_afi_port_list {
		set terminated [get_port_property $port TERMINATION]
		if {([lsearch $split_ports $port] == -1) && ($terminated == 0)} {
			regsub {^afi_} $port {mux_afi_} phy_port
			if {[string compare -nocase [get_port_property $port DIRECTION] "output"]} {
				set_port_property $phy_port DRIVEN_BY $port
			} elseif {[string compare -nocase [get_port_property $port DIRECTION] "input"]} {
				set_port_property $port DRIVEN_BY $phy_port
			}
		}
	}

    add_interface afi_mem_clk_disable conduit end
	set_interface_property afi_mem_clk_disable ENABLED true
	add_interface_port afi_mem_clk_disable phy_afi_mem_clk_disable afi_mem_clk_disable Output [get_parameter_value AFI_CLK_PAIR_COUNT]
	set_port_property afi_mem_clk_disable VHDL_TYPE STD_LOGIC_VECTOR

	set_port_property phy_afi_mem_clk_disable DRIVEN_BY afi_mem_clk_disable


	add_interface afi_init_cal_req conduit end
	set_interface_property afi_init_cal_req ENABLED true
	add_interface_port afi_init_cal_req seq_afi_init_req afi_init_req Output 1
	add_interface_port afi_init_cal_req seq_afi_cal_req afi_cal_req Output 1

	set_port_property seq_afi_init_req DRIVEN_BY afi_init_req
	set_port_property seq_afi_cal_req DRIVEN_BY afi_cal_req

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		add_interface tracking conduit end
	    set_interface_property tracking ENABLED true
	    add_interface_port tracking seq_afi_seq_busy afi_seq_busy Input [get_parameter_value MEM_IF_CS_WIDTH]
	    set_port_property seq_afi_seq_busy VHDL_TYPE STD_LOGIC_VECTOR
	    add_interface_port tracking seq_afi_ctl_refresh_done afi_ctl_refresh_done Output [get_parameter_value MEM_IF_CS_WIDTH]
	    set_port_property seq_afi_ctl_refresh_done VHDL_TYPE STD_LOGIC_VECTOR
	    add_interface_port tracking seq_afi_ctl_long_idle afi_ctl_long_idle Output [get_parameter_value MEM_IF_CS_WIDTH]
	    set_port_property seq_afi_ctl_long_idle VHDL_TYPE STD_LOGIC_VECTOR

		set_port_property afi_seq_busy DRIVEN_BY seq_afi_seq_busy
		set_port_property seq_afi_ctl_refresh_done DRIVEN_BY afi_ctl_refresh_done
		set_port_property seq_afi_ctl_long_idle DRIVEN_BY afi_ctl_long_idle
	}
}
