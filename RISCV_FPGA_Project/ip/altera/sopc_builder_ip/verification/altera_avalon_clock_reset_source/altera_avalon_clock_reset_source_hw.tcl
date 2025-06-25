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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_clock_reset_source/altera_avalon_clock_reset_source_hw.tcl $
# $Author: swbranch $
# $Revision: #1 $
# $Date: 2013/08/11 $
#------------------------------------------------------------------------------
package require -exact sopc 9.1

set_module_property NAME                         altera_avalon_clock_reset_source
set_module_property VERSION          	 	 13.1
set_module_property AUTHOR 			 "Altera Corporation"
set_module_property GROUP        		 "Avalon Verification Suite"
set_module_property DISPLAY_NAME 		 "Altera Avalon Clock and Reset Source"
set_module_property TOP_LEVEL_HDL_FILE           altera_avalon_clock_reset_source.sv
set_module_property TOP_LEVEL_HDL_MODULE         altera_avalon_clock_reset_source
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     false
set_module_property INTERNAL 			 true
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property VALIDATION_CALLBACK          validate
set_module_property ANALYZE_HDL                  false

# Files
#---------------------------------------------------------------------
set HDL_LIB_DIR "../lib"

add_file $HDL_LIB_DIR/verbosity_pkg.sv       {SIMULATION}
add_file altera_avalon_clock_reset_source.sv {SIMULATION}

# Parameters
#---------------------------------------------------------------------
set ASSERT_HIGH_RESET         "ASSERT_HIGH_RESET"
set CLOCK_PERIOD              "CLOCK_PERIOD"
set RESET_DEASSERT_CYCLES     "RESET_DEASSERT_CYCLES"

add_parameter $ASSERT_HIGH_RESET Integer 1
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_NAME "Assert reset high"
set_parameter_property $ASSERT_HIGH_RESET DESCRIPTION "Reset is active high when this value is set to 1"
set_parameter_property $ASSERT_HIGH_RESET DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_RESET AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_RESET GROUP "Reset"

add_parameter $RESET_DEASSERT_CYCLES Integer 20
set_parameter_property $RESET_DEASSERT_CYCLES DISPLAY_NAME "Reset assertion time (cycles)"
set_parameter_property $RESET_DEASSERT_CYCLES DESCRIPTION "Deassert reset after this many clock cycles"
set_parameter_property $RESET_DEASSERT_CYCLES HDL_PARAMETER true
set_parameter_property $RESET_DEASSERT_CYCLES GROUP "Reset"

add_parameter $CLOCK_PERIOD Positive 10
set_parameter_property $CLOCK_PERIOD DISPLAY_NAME "Clock period"
set_parameter_property $CLOCK_PERIOD DESCRIPTION "Clock period in nanoseconds"
set_parameter_property $CLOCK_PERIOD HDL_PARAMETER true
set_parameter_property $CLOCK_PERIOD GROUP "Clock"

#------------------------------------------------------------------------------
proc validate {} {
    global RESET_DEASSERT_CYCLES

    if {[get_parameter $RESET_DEASSERT_CYCLES] < 0} {
	send_message error "RESET_DEASSERT_CYCLES must be equal or greater than  0."
    }
}
#------------------------------------------------------------------------------
proc elaborate {} {
    global ASSERT_HIGH_RESET  
    global CLOCK_PERIOD         
    global RESET_DEASSERT_CYCLES
    
    set CLOCK_PERIOD_VALUE           [get_parameter $CLOCK_PERIOD]
    set RESET_DEASSERT_CYCLES_VALUE  [get_parameter $RESET_DEASSERT_CYCLES]

    set CLOCK_INTERFACE  "clk"
    set DUMMY_SRC        "dummy_src"
    set DUMMY_SNK        "dummy_snk"

    #---------------------------------------------------------------------
    # Clock-Reset connection point
    #---------------------------------------------------------------------
    add_interface $CLOCK_INTERFACE clock source
    add_interface_port $CLOCK_INTERFACE clk clk output 1

    if {[get_parameter $ASSERT_HIGH_RESET] > 0} {
	add_interface_port $CLOCK_INTERFACE reset reset output 1
	send_message Info "Reset is positively asserted."
    } else {
	add_interface_port $CLOCK_INTERFACE reset reset_n output 1
	send_message Info "Reset is negatively asserted."
    }

    #---------------------------------------------------------------------
    # Dummy source and sink connection points to force SOPC to Generate
    #---------------------------------------------------------------------
    add_interface $DUMMY_SRC avalon_streaming source
    add_interface_port $DUMMY_SRC dummy_src data Output 1
    set_interface_property $DUMMY_SRC ENABLED true
    set_interface_property $DUMMY_SRC ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $DUMMY_SRC dataBitsPerSymbol 1
    set_interface_property $DUMMY_SRC symbolsPerBeat 1
    set_interface_property $DUMMY_SRC errorDescriptor ""
    set_interface_property $DUMMY_SRC maxChannel 0
    set_interface_property $DUMMY_SRC readyLatency 0

    add_interface $DUMMY_SNK avalon_streaming sink
    add_interface_port $DUMMY_SNK dummy_snk data Input 1
    set_interface_property $DUMMY_SNK ENABLED true
    set_interface_property $DUMMY_SNK ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $DUMMY_SNK dataBitsPerSymbol 1
    set_interface_property $DUMMY_SNK symbolsPerBeat 1
    set_interface_property $DUMMY_SNK errorDescriptor ""
    set_interface_property $DUMMY_SNK maxChannel 0
    set_interface_property $DUMMY_SNK readyLatency 0
}

