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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_reset_source/altera_avalon_reset_source_hw.tcl $
# $Author: swbranch $
# $Revision: #1 $
# $Date: 2013/08/11 $
#------------------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                           altera_avalon_reset_source
set_module_property VERSION                        13.1
set_module_property DESCRIPTION                    "Altera Reset Source BFM"
set_module_property GROUP                          "Avalon Verification Suite"
set_module_property AUTHOR                         "Altera Corporation"
set_module_property DISPLAY_NAME                   "Altera Reset Source BFM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL                       false
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property VALIDATION_CALLBACK            validate
set_module_property ANALYZE_HDL                    false
set_module_property HIDE_FROM_SOPC                 true

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
set ASSERT_HIGH_RESET            "ASSERT_HIGH_RESET"
set INITIAL_RESET_CYCLES         "INITIAL_RESET_CYCLES"

add_parameter $ASSERT_HIGH_RESET Integer 1
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_NAME "Assert reset high"
set_parameter_property $ASSERT_HIGH_RESET DESCRIPTION "Reset is active high when this value is set to 1"
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_RESET AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_RESET HDL_PARAMETER true
set_parameter_property $ASSERT_HIGH_RESET GROUP "Reset"

add_parameter $INITIAL_RESET_CYCLES Integer 0
set_parameter_property $INITIAL_RESET_CYCLES DISPLAY_NAME "Cycles of initial reset"
set_parameter_property $INITIAL_RESET_CYCLES DESCRIPTION "Automatically reset for specified number of cycles at the initial of simulation"
set_parameter_property $INITIAL_RESET_CYCLES DISPLAY_HINT integer
set_parameter_property $INITIAL_RESET_CYCLES AFFECTS_ELABORATION true
set_parameter_property $INITIAL_RESET_CYCLES HDL_PARAMETER true
set_parameter_property $INITIAL_RESET_CYCLES GROUP "Reset"

# ------------------------------------------------------------------------------
# Generation file set
# ------------------------------------------------------------------------------
# Define file set
add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_reset_source

add_fileset sim_verilog SIM_VERILOG simverilog_proc
set_fileset_property sim_verilog top_level altera_avalon_reset_source

add_fileset sim_vhdl SIM_VHDL simvhdl_proc
set_fileset_property sim_vhdl top_level altera_avalon_reset_source

# SIM_VERILOG generation callback procedure
proc simverilog_proc {NAME} {
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "../lib/verbosity_pkg.sv"
   add_fileset_file altera_avalon_reset_source.sv SYSTEM_VERILOG path altera_avalon_reset_source.sv
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
}

proc quartus_synth_proc {NAME} {
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "../lib/verbosity_pkg.sv"
   add_fileset_file altera_avalon_reset_source.sv SYSTEM_VERILOG path altera_avalon_reset_source.sv
}

# SIM_VHDL generation callback procedure
proc simvhdl_proc {NAME} {
   add_fileset_file altera_avalon_reset_source.vhd VHDL path altera_avalon_reset_source.vhd
}

# ------------------------------------------------------------------------------
proc validate {} {

}
# ------------------------------------------------------------------------------
proc elaborate {} {
    global ASSERT_HIGH_RESET  

    send_message Info {Elaborate: altera_reset_source}
    send_message Info {           $Revision: #1 $}
    send_message Info {           $Date: 2013/08/11 $}

    set RESET_SOURCE "reset"    
    set CLOCK_SINK  "clk"

    #---------------------------------------------------------------------
    # Reset Source connection point
    #---------------------------------------------------------------------

    add_interface      	   $RESET_SOURCE reset source
    add_interface_port 	   $RESET_SOURCE reset reset output 1
    set_interface_property $RESET_SOURCE ENABLED true
    set_interface_property $RESET_SOURCE ASSOCIATED_CLOCK $CLOCK_SINK

    if {[get_parameter $ASSERT_HIGH_RESET] > 0} {
	add_interface_port $RESET_SOURCE reset reset   Output 1
	send_message Info "Reset is positively asserted."
    } else {
	add_interface_port $RESET_SOURCE reset reset_n Output 1
	send_message Info "Reset is negatively asserted."
    }
    #---------------------------------------------------------------------
    # Clock Sink connection point
    #---------------------------------------------------------------------
    add_interface      	   $CLOCK_SINK clock   sink
    add_interface_port 	   $CLOCK_SINK clk clk Input 1
    set_interface_property $CLOCK_SINK ENABLED true

}

