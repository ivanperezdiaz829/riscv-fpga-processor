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



package require -exact sopc 10.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::util::qini

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "MMR Driver for POF Verification"
set_module_property NAME pof_avalon_mm_mmr_driver
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "MMR Driver for POF Verification"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim

add_fileset synth QUARTUS_SYNTH generate_synth

proc generate_vhdl_sim {name} {

        set simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
        add_fileset_file pof_avalon_mm_mmr_driver.sv SYSTEM_VERILOG PATH pof_avalon_mm_mmr_driver.sv $simulators
        add_fileset_file [file join mentor pof_avalon_mm_mmr_driver.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor pof_avalon_mm_mmr_driver.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
        add_fileset_file pof_avalon_mm_mmr_driver.sv SYSTEM_VERILOG PATH pof_avalon_mm_mmr_driver.sv
}

proc generate_synth {name} {
        add_fileset_file pof_avalon_mm_mmr_driver.sv SYSTEM_VERILOG PATH pof_avalon_mm_mmr_driver.sv
}



add_parameter MMRD_AVL_DATA_WIDTH INTEGER 32
set_parameter_property MMRD_AVL_DATA_WIDTH VISIBLE true
set_parameter_property MMRD_AVL_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property MMRD_AVL_DATA_WIDTH HDL_PARAMETER true

add_parameter MMRD_AVL_ADDR_WIDTH INTEGER 16
set_parameter_property MMRD_AVL_ADDR_WIDTH VISIBLE true
set_parameter_property MMRD_AVL_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property MMRD_AVL_ADDR_WIDTH HDL_PARAMETER true

add_parameter MMRD_AVL_BE_WIDTH INTEGER 4
set_parameter_property MMRD_AVL_BE_WIDTH VISIBLE true
set_parameter_property MMRD_AVL_BE_WIDTH AFFECTS_ELABORATION true
set_parameter_property MMRD_AVL_BE_WIDTH HDL_PARAMETER true


set_module_property elaboration_Callback ip_elaborate



proc ip_elaborate {} {

	set toplevel_name "pof_avalon_mm_mmr_driver"

	set_fileset_property sim_vhdl TOP_LEVEL $toplevel_name
	set_fileset_property sim_verilog TOP_LEVEL $toplevel_name
	set_fileset_property synth TOP_LEVEL $toplevel_name

	
	add_interface mmr_clk clock end
	set_interface_property mmr_clk ENABLED true
	add_interface_port mmr_clk clk clk Input 1
	
	add_interface mmr_reset reset end
	set_interface_property mmr_reset synchronousEdges NONE
	set_interface_property mmr_reset ENABLED true
	add_interface_port mmr_reset reset_n reset_n Input 1

	add_interface mmr avalon master
	set_interface_property mmr addressUnits WORDS
	set_interface_property mmr associatedClock mmr_clk
	set_interface_property mmr associatedReset mmr_reset
	set_interface_property mmr bitsPerSymbol 8
	set_interface_property mmr burstOnBurstBoundariesOnly false
	set_interface_property mmr burstcountUnits WORDS
	set_interface_property mmr constantBurstBehavior true
	set_interface_property mmr ENABLED true

	add_interface_port mmr mmr_waitrequest waitrequest Input 1
	add_interface_port mmr mmr_write_req write Output 1
	add_interface_port mmr mmr_read_req read Output 1
	add_interface_port mmr mmr_addr address Output [get_parameter_value MMRD_AVL_ADDR_WIDTH]
	add_interface_port mmr mmr_be byteenable Output  [get_parameter_value MMRD_AVL_BE_WIDTH]
	add_interface_port mmr mmr_wdata writedata Output [get_parameter_value MMRD_AVL_DATA_WIDTH]
        add_interface_port mmr mmr_rdata_valid readdatavalid Input 1
	add_interface_port mmr mmr_rdata readdata Input [get_parameter_value MMRD_AVL_DATA_WIDTH]

        add_interface unique_ready conduit start
        set_interface_property unique_ready ENABLED true
        add_interface_port unique_ready unique_ready unique_ready Output 1
        
        add_interface coordinator_ready conduit end
        set_interface_property coordinator_ready ENABLED true
        add_interface_port coordinator_ready coordinator_ready coordinator_ready Input 1

        add_interface unique_done conduit start
        set_interface_property unique_done ENABLED true
        add_interface_port unique_done unique_done unique_done Output 1

        add_interface unique_ready_1 conduit start
        set_interface_property unique_ready_1 ENABLED true
        add_interface_port unique_ready_1 unique_ready_1 unique_ready Output 1
        
        add_interface coordinator_ready_1 conduit end
        set_interface_property coordinator_ready_1 ENABLED true
        add_interface_port coordinator_ready_1 coordinator_ready_1 coordinator_ready Input 1

        add_interface unique_done_1 conduit start
        set_interface_property unique_done_1 ENABLED true
        add_interface_port unique_done_1 unique_done_1 unique_done Output 1

	add_interface emif_status conduit end
	set_interface_property emif_status ENABLED true
	
	add_interface_port emif_status local_init_done local_init_done Input 1
	add_interface_port emif_status local_cal_success local_cal_success Input 1
	add_interface_port emif_status local_cal_fail local_cal_fail Input 1


	add_interface mmrd_status conduit end
	set_interface_property mmrd_status ENABLED true
	
	add_interface_port mmrd_status pass local_init_done Output 1
	add_interface_port mmrd_status fail local_cal_success Output 1
	add_interface_port mmrd_status test_complete test_complete Output 1

}
