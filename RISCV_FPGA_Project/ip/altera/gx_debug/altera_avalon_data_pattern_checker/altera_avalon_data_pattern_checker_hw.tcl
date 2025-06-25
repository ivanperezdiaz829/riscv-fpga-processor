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


#+-----------------------------------
# | request TCL package from ACDS 10.1
# | 
#package require -exact sopc 10.1
package require -exact qsys 11.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_data_pattern_checker
# | 
set_module_property DESCRIPTION "Altera Avalon Data Pattern Checker"
set_module_property NAME altera_avalon_data_pattern_checker
set_module_property VERSION 13.1 
set_module_property GROUP "Peripherals/Debug and Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera Avalon Data Pattern Checker"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_embedded_ip.pdf
set_module_property HIDE_FROM_SOPC false
set_module_property INTERNAL false 
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSITION_CALLBACK composition

# +-----------------------------------
# | parameters 
# +-----------------------------------
add_parameter ST_DATA_W INTEGER 40
set_parameter_property ST_DATA_W ALLOWED_RANGES {32 40 50 64 66 80 128}
set_parameter_property ST_DATA_W DISPLAY_NAME ST_DATA_W
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W DISPLAY_HINT ""
set_parameter_property ST_DATA_W AFFECTS_GENERATION true
set_parameter_property ST_DATA_W IS_HDL_PARAMETER true

add_parameter NUM_CYCLES_FOR_LOCK INTEGER 40
set_parameter_property NUM_CYCLES_FOR_LOCK ALLOWED_RANGES 1:255 
set_parameter_property NUM_CYCLES_FOR_LOCK DISPLAY_NAME NUM_CYCLES_FOR_LOCK
set_parameter_property NUM_CYCLES_FOR_LOCK UNITS None
set_parameter_property NUM_CYCLES_FOR_LOCK VISIBLE false
set_parameter_property NUM_CYCLES_FOR_LOCK DISPLAY_HINT ""
set_parameter_property NUM_CYCLES_FOR_LOCK AFFECTS_GENERATION true 
set_parameter_property NUM_CYCLES_FOR_LOCK IS_HDL_PARAMETER true

add_parameter BYPASS_ENABLED boolean 1
set_parameter_property BYPASS_ENABLED DEFAULT_VALUE 0
set_parameter_property BYPASS_ENABLED DISPLAY_NAME "Enable Bypass Interface"
set_parameter_property BYPASS_ENABLED UNITS None
set_parameter_property BYPASS_ENABLED DISPLAY_HINT "Select to add bypass interface"
set_parameter_property BYPASS_ENABLED AFFECTS_GENERATION true
set_parameter_property BYPASS_ENABLED IS_HDL_PARAMETER true 

add_parameter AVALON_ENABLED boolean 1 
set_parameter_property AVALON_ENABLED DEFAULT_VALUE 1
set_parameter_property AVALON_ENABLED DISPLAY_NAME "Enable Avalon Interface"
set_parameter_property AVALON_ENABLED UNITS None
set_parameter_property AVALON_ENABLED DISPLAY_HINT "Select to enable Avalon interface"
set_parameter_property AVALON_ENABLED AFFECTS_GENERATION true
set_parameter_property AVALON_ENABLED IS_HDL_PARAMETER true 

add_parameter FREQ_CNTER_ENABLED boolean 1
set_parameter_property FREQ_CNTER_ENABLED DEFAULT_VALUE 0
set_parameter_property FREQ_CNTER_ENABLED DISPLAY_NAME "Enable Frequency Counter"
set_parameter_property FREQ_CNTER_ENABLED UNITS None
set_parameter_property FREQ_CNTER_ENABLED DISPLAY_HINT "Select to add frequency counter"
set_parameter_property FREQ_CNTER_ENABLED AFFECTS_GENERATION true
set_parameter_property FREQ_CNTER_ENABLED IS_HDL_PARAMETER true 

add_parameter CROSS_CLK_SYNC_DEPTH INTEGER 2 
set_parameter_property CROSS_CLK_SYNC_DEPTH ALLOWED_RANGES 2:20 
set_parameter_property CROSS_CLK_SYNC_DEPTH DISPLAY_NAME CROSS_CLK_SYNC_DEPTH
set_parameter_property CROSS_CLK_SYNC_DEPTH UNITS None
set_parameter_property CROSS_CLK_SYNC_DEPTH DISPLAY_HINT ""
set_parameter_property CROSS_CLK_SYNC_DEPTH AFFECTS_GENERATION true 
set_parameter_property CROSS_CLK_SYNC_DEPTH IS_HDL_PARAMETER true

# +-----------------------------------
# Checker instance 
# +-----------------------------------
add_instance "data_pattern_checker" altera_avalon_data_pattern_checker_core
add_interface csr_clk clock end
set_interface_property csr_clk ENABLED true

add_interface reset reset end
set_interface_property reset ENABLED true

add_interface csr_slave avalon end
set_interface_property csr_slave ENABLED true

# +-----------------------------------
# Composition call back
# +-----------------------------------
proc composition { } {
    set checker_parameters {
        "ST_DATA_W" 
        "NUM_CYCLES_FOR_LOCK" 
       "BYPASS_ENABLED" 
        "AVALON_ENABLED"
        "FREQ_CNTER_ENABLED" }

    foreach param $checker_parameters {
        set_instance_parameter_value data_pattern_checker $param [get_parameter_value $param]
    }
    
    set bypass [get_parameter_value BYPASS_ENABLED]
    set avalon [get_parameter_value AVALON_ENABLED]
    set cnter  [get_parameter_value FREQ_CNTER_ENABLED]
     
    if { $bypass == "true" } {
        if { $avalon == "true" } {
            set output_avalon "true"
            set output_conduit "false" 
        } else {
            set output_avalon "false"
            set output_conduit "true"
        }
    } else { 
            set output_avalon "false"
            set output_conduit "false"
    }

    if { $avalon == "true" } {
        set conduit false
    } else {
        set conduit true
    }

    if { $avalon == "true" } {
        add_interface pattern_in_clk clock end
        set_interface_property pattern_in_clk ENABLED $avalon 

        add_interface pattern_in avalon_streaming sink 
        set_interface_property pattern_in ENABLED $avalon 
        set_interface_property pattern_in export_of data_pattern_checker.pattern_in
        set_interface_property pattern_in PORT_NAME_MAP {asi_data asi_data asi_valid asi_valid asi_ready asi_ready}
    } else {
        add_interface conduit_pattern_in_clk conduit end
        set_interface_property conduit_pattern_in_clk ENABLED $conduit

        add_interface conduit_pattern_in conduit end
        set_interface_property conduit_pattern_in ENABLED $conduit
        set_interface_property conduit_pattern_in export_of data_pattern_checker.conduit_pattern_in
        set_interface_property conduit_pattern_in PORT_NAME_MAP {asi_data asi_data}
    }

    if { $output_avalon == "true" } { 
        add_interface pattern_out_clk clock source
        set_interface_property pattern_out_clk ENABLED $output_avalon 
        set_interface_property pattern_out_clk export_of data_pattern_checker.pattern_out_clk

        add_interface pattern_out avalon_streaming source 
        set_interface_property pattern_out ENABLED $output_avalon 
        set_interface_property pattern_out export_of data_pattern_checker.pattern_out
        set_interface_property pattern_out PORT_NAME_MAP {aso_data aso_data aso_valid aso_valid aso_ready aso_ready}
     } 
     if { $output_conduit == "true" } {
        add_interface conduit_pattern_out_clk conduit end
        set_interface_property conduit_pattern_out_clk ENABLED $output_conduit 
        set_interface_property conduit_pattern_out_clk export_of data_pattern_checker.conduit_pattern_out_clk
        set_interface_assignment conduit_pattern_out_clk ui.blockdiagram.direction output

        add_interface conduit_pattern_out conduit end
        set_interface_property conduit_pattern_out ENABLED $output_conduit 
        set_interface_property conduit_pattern_out export_of data_pattern_checker.conduit_pattern_out
        set_interface_property conduit_pattern_out PORT_NAME_MAP {aso_data aso_data}
        set_interface_assignment conduit_pattern_out ui.blockdiagram.direction output
      }

     if { $cnter == "true" } { 
        
        set_parameter_property CROSS_CLK_SYNC_DEPTH VISIBLE $cnter 

        set sync_depth [get_parameter_value CROSS_CLK_SYNC_DEPTH] 
        
        #add frequency cnter instance and set parameters
        add_instance "frequency_cnter" frequency_counter 
        set_instance_parameter_value frequency_cnter CROSS_CLK_SYNC_DEPTH $sync_depth
        
        add_instance "mm_bridge" altera_avalon_mm_bridge
        set_interface_property csr_slave export_of mm_bridge.s0
        set_instance_parameter_value mm_bridge ADDRESS_WIDTH 6 

        add_connection mm_bridge.m0 frequency_cnter.csr_slave
        add_connection mm_bridge.m0 data_pattern_checker.csr_slave
        set_connection_parameter_value mm_bridge.m0/data_pattern_checker.csr_slave baseAddress 0x00
        set_connection_parameter_value mm_bridge.m0/frequency_cnter.csr_slave baseAddress 0x20
        
        add_instance "mm_clk_source" clock_source
        set_instance_parameter_value mm_clk_source clockFrequencyKnown false
        set_interface_property  csr_clk export_of mm_clk_source.clk_in
        set_interface_property  reset         export_of mm_clk_source.clk_in_reset            
        
        add_connection  mm_clk_source.clk       frequency_cnter.csr_clk
        add_connection  mm_clk_source.clk       frequency_cnter.avalon_ref_clk
        add_connection  mm_clk_source.clk       data_pattern_checker.csr_clk
        add_connection  mm_clk_source.clk       mm_bridge.clk    

        add_connection  mm_clk_source.clk_reset data_pattern_checker.csr_clk_reset
        add_connection  mm_clk_source.clk_reset frequency_cnter.csr_clk_reset
        add_connection  mm_clk_source.clk_reset mm_bridge.reset

        set_instance_parameter_value frequency_cnter DES_CLK_AVALON_ENABLED $avalon
        #connect the clocks 
        if { $avalon == "true" } {
            #if we are in avalon mode
            #Declare a new clock source to connect to two sinks
            add_instance "pattern_in_clk_source" clock_source
            set_instance_parameter_value pattern_in_clk_source clockFrequencyKnown false
            set_interface_property pattern_in_clk export_of pattern_in_clk_source.clk_in

            add_connection mm_clk_source.clk_reset      pattern_in_clk_source.clk_in_reset 
            add_connection pattern_in_clk_source.clk    data_pattern_checker.pattern_in_clk
            add_connection pattern_in_clk_source.clk    frequency_cnter.avalon_des_clk
         } else {
            add_instance "pattern_in_clk_splitter" conduit_splitter
            set_instance_parameter_value pattern_in_clk_splitter OUTPUT_NUM 2

            set_interface_property conduit_pattern_in_clk export_of pattern_in_clk_splitter.conduit_input
            add_connection pattern_in_clk_splitter.conduit_output_0 data_pattern_checker.conduit_pattern_in_clk
            add_connection pattern_in_clk_splitter.conduit_output_1 frequency_cnter.conduit_des_clk 
         }
    } else {
        # if no frequency cnter is enabled, directly export the interfaces
        set_interface_property csr_slave        export_of   data_pattern_checker.csr_slave
        set_interface_property csr_clk          export_of   data_pattern_checker.csr_clk
        set_interface_property reset            export_of   data_pattern_checker.csr_clk_reset
        if { $avalon == "true" } {
            set_interface_property pattern_in_clk   export_of   data_pattern_checker.pattern_in_clk
        } else {
            set_interface_property conduit_pattern_in_clk export_of data_pattern_checker.conduit_pattern_in_clk
        } 
    }
}
