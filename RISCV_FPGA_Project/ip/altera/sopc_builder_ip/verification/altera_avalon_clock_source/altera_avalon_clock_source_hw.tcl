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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_clock_source/altera_avalon_clock_source_hw.tcl $
# $Author: swbranch $
# $Revision: #1 $
# $Date: 2013/08/11 $
# ------------------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                           altera_avalon_clock_source
set_module_property AUTHOR                         "Altera Corporation"
set_module_property VERSION                        13.1
set_module_property GROUP        		            "Avalon Verification Suite"
set_module_property DESCRIPTION    		            "Altera Clock Source BFM"
set_module_property DISPLAY_NAME 		            "Altera Clock Source BFM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL 			               false
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property VALIDATION_CALLBACK            validate
set_module_property ANALYZE_HDL                    false
set_module_property HIDE_FROM_SOPC                 true


# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
set CLOCK_RATE "CLOCK_RATE"
set CLOCK_UNIT "CLOCK_UNIT"

add_parameter $CLOCK_RATE Positive 10
set_parameter_property $CLOCK_RATE DISPLAY_NAME "Clock rate"
set_parameter_property $CLOCK_RATE DESCRIPTION "Clock rate"
set_parameter_property $CLOCK_RATE HDL_PARAMETER true
set_parameter_property $CLOCK_RATE GROUP "Clock"

add_parameter $CLOCK_UNIT Positive 1000000
set_parameter_property $CLOCK_UNIT DISPLAY_NAME "Clock rate unit"
set_parameter_property $CLOCK_UNIT DESCRIPTION "Clock rate unit"
set_parameter_property $CLOCK_UNIT HDL_PARAMETER true
set_parameter_property $CLOCK_UNIT GROUP "Clock"
set_parameter_property $CLOCK_UNIT ALLOWED_RANGES {"1:Hz" "1000:kHz" "1000000:MHz"}

# ------------------------------------------------------------------------------
# Generation file set
# ------------------------------------------------------------------------------
# Define file set
add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_clock_source

add_fileset sim_verilog SIM_VERILOG simverilog_proc
set_fileset_property sim_verilog top_level altera_avalon_clock_source

add_fileset sim_vhdl SIM_VHDL simvhdl_proc
set_fileset_property sim_vhdl top_level altera_avalon_clock_source

# SIM_VERILOG generation callback procedure
proc simverilog_proc {NAME} {
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "../lib/verbosity_pkg.sv"
   add_fileset_file altera_avalon_clock_source.sv SYSTEM_VERILOG path altera_avalon_clock_source.sv
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
}

proc quartus_synth_proc {NAME} {
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "../lib/verbosity_pkg.sv"
   add_fileset_file altera_avalon_clock_source.sv SYSTEM_VERILOG path altera_avalon_clock_source.sv
}

# SIM_VHDL generation callback procedure
proc simvhdl_proc {NAME} {
   add_fileset_file altera_avalon_clock_source.vhd VHDL path altera_avalon_clock_source.vhd
}


# ------------------------------------------------------------------------------
proc validate {} {
    global CLOCK_RATE

    if {[get_parameter $CLOCK_RATE] < 0} {
	send_message error "CLOCK_RATE must be equal or greater than 0."
    }
}
# ------------------------------------------------------------------------------
proc elaborate {} {
   global CLOCK_RATE
   global CLOCK_UNIT

   send_message Info {Elaborate: altera_clock_source}
   send_message Info {           $Revision: #1 $}
   send_message Info {           $Date: 2013/08/11 $}

   set CLOCK_RATE_VALUE    [get_parameter_value $CLOCK_RATE]
   set CLOCK_UNIT_VALUE    [get_parameter_value $CLOCK_UNIT]

   #---------------------------------------------------------------------
   # Clock source connection point
   #---------------------------------------------------------------------
   set CLOCK_SOURCE  "clk"
   add_interface $CLOCK_SOURCE clock source
   add_interface_port $CLOCK_SOURCE clk clk output 1
   set_interface_property $CLOCK_SOURCE clockRate [expr $CLOCK_RATE_VALUE * $CLOCK_UNIT_VALUE]
}

