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


#  -----------------------------------
# | altera_fanout
#  -----------------------------------
set_module_property NAME altera_fanout
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Merlin Fanout"
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
#set_module_property GENERATION_CALLBACK generate
#set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property HIDE_FROM_SOPC true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
# set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter NUM_FANOUT INTEGER 2  "Number of fanout interfaces"
set_parameter_property NUM_FANOUT DISPLAY_NAME {Number of fanout}
set_parameter_property NUM_FANOUT ALLOWED_RANGES 1:64
set_parameter_property NUM_FANOUT DESCRIPTION  {Number of fanout interfaces}

add_parameter TYPE_FANOUT STRING "conduit"  "Fanout interface type - conduit, interrupt"
set_parameter_property TYPE_FANOUT DISPLAY_NAME {Fanout interface type}
set_parameter_property TYPE_FANOUT DESCRIPTION  {Fanout interface type}

add_parameter WIDTH INTEGER 1 "Data Width"
set_parameter_property WIDTH DISPLAY_NAME {Data Width}
set_parameter_property WIDTH ALLOWED_RANGES 1:20
set_parameter_property WIDTH DESCRIPTION  {Interfaces width}

add_parameter SPECIFY_SIGNAL_TYPE integer 0
set_parameter_property SPECIFY_SIGNAL_TYPE DISPLAY_NAME {Specify a specific signal type}
set_parameter_property SPECIFY_SIGNAL_TYPE ALLOWED_RANGES {0:1}
set_parameter_property SPECIFY_SIGNAL_TYPE DESCRIPTION  {Specify a signal type which can be set in TYPE_FANOUT}

add_parameter SIGNAL_TYPE STRING "export"  "Fanout signal type - export by default"
set_parameter_property SIGNAL_TYPE DISPLAY_NAME {Fanout signal type}
set_parameter_property SIGNAL_TYPE DESCRIPTION  {Fanout signal type}

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
    
    # Collect parameter values into local variables
    foreach var [ get_parameters ] {
        set $var [ get_parameter_value $var ]
    }

    #TEMP # Clock interface
    #TEMP add_interface clk clock end
    #TEMP add_interface_port clk clk clk Input 1
    #TEMP add_interface_port clk reset reset Input 1

    if { $TYPE_FANOUT == "clock" } {
      set interface_port clk
    } elseif { $SPECIFY_SIGNAL_TYPE } {
      set interface_port $SIGNAL_TYPE
    } else {
      set interface_port export
    }

    # Input Interface
    add_interface "sig_input" $TYPE_FANOUT input
    add_interface_port "sig_input" "sig_input" $interface_port Input $WIDTH

    # Output fanout Interfaces
    for { set s 0 } { $s < $NUM_FANOUT } { incr s } {
        add_interface "sig_fanout$s" $TYPE_FANOUT output
        add_interface_port "sig_fanout${s}" "sig_fanout${s}" $interface_port Output $WIDTH
        set_port_property "sig_fanout${s}" DRIVEN_BY "sig_input"
    }
}

