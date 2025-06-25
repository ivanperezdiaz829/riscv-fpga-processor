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
# | 
package require -exact qsys 12.0

# Require alt_mem_if TCL packages
package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils

# Function Imports
namespace import ::alt_mem_if::util::messaging::*

# | 
# +-----------------------------------

# +-----------------------------------
# | 
set_module_property DESCRIPTION "UniPHY HPS EMIF Clock/Reset Source"
set_module_property NAME altera_mem_if_clk_rst_source
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "UniPHY HPS EMIF Clock/Reset Source"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true 
# | 
# +-----------------------------------

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Generation file set
# ------------------------------------------------------------------------------
# Define file set
add_fileset quartus_synth QUARTUS_SYNTH simverilog_proc
add_fileset sim_verilog SIM_VERILOG simverilog_proc
add_fileset sim_vhdl SIM_VHDL simvhdl_proc

# SIM_VERILOG generation callback procedure
proc simverilog_proc {NAME} {
}

# SIM_VHDL generation callback procedure
proc simvhdl_proc {NAME} {
}


# ------------------------------------------------------------------------------

set_module_property elaboration_Callback elaborate

proc elaborate {} {

    set CLOCK_SOURCE         "clk"
    set GLOBAL_RESET_SOURCE  "global_reset"    
    set SOFT_RESET_SOURCE    "soft_reset"    
    
    #---------------------------------------------------------------------
    # Clock source connection point
    #---------------------------------------------------------------------

    add_interface $CLOCK_SOURCE clock source
    add_interface_port $CLOCK_SOURCE clk clk output 1
    set_port_property clk DRIVEN_BY 1
    
    add_interface      	   $GLOBAL_RESET_SOURCE reset source
    add_interface_port 	   $GLOBAL_RESET_SOURCE global_reset_n reset_n output 1
    set_interface_property $GLOBAL_RESET_SOURCE ENABLED true
    set_interface_property $GLOBAL_RESET_SOURCE ASSOCIATED_CLOCK $CLOCK_SOURCE
    set_port_property global_reset_n DRIVEN_BY 0
    
    add_interface      	   $SOFT_RESET_SOURCE reset source
    add_interface_port 	   $SOFT_RESET_SOURCE soft_reset_n reset_n output 1
    set_interface_property $SOFT_RESET_SOURCE ENABLED true
    set_interface_property $SOFT_RESET_SOURCE ASSOCIATED_CLOCK $CLOCK_SOURCE
    set_port_property soft_reset_n DRIVEN_BY 0
    
}

