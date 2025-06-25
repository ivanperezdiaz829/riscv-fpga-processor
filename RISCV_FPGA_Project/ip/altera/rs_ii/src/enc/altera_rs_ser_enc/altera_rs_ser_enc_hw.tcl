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


package require -exact qsys 13.1


source "../../lib/altera_rs_utilities.tcl"
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_rs_ser_enc
# | 
set_module_property DESCRIPTION "Altera Reed Solomon II Serial Encoder"
set_module_property NAME altera_rs_ser_enc
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "DSP/Reed Solomon II"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RS II Serial Encoder"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
add_module_parametersENC
set_module_property VALIDATION_CALLBACK validateENC
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false




# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_filesets altera_rs_ser_enc

proc get_simulator_list {} {
    return { \
             {mentor   1   } \
             {aldec    1    } \
             {synopsys 0 } \
             {cadence  0  } \
           }
}

proc generate {type} {
    add_rs_package $type "../.."
    add_encrypted_file $type altera_rs_ser_enc.sv
    add_encrypted_file $type altera_rs_ser_enc.ocp
}
# | 
# +-----------------------------------

# +-----------------------------------
# Add Port Function
# |
# |
proc addPort { iface pName pRole pDir pWidth termComparison termValue } {

    if { $pWidth != 0 } {
        add_interface_port $iface $pName $pRole $pDir $pWidth

        if { [ expr $termComparison ] == 1 } {
            set_port_property $pName termination true
            set_port_property $pName termination_value $termValue
        }
    }
}
# | 
# +-----------------------------------
# | Callbacks
# | 
proc elaborate {} {

    set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
    set channel         [ get_parameter_value CHANNEL ]
    set max_channel     [ expr $channel - 1 ]

    if { $channel==1 } {
        set channel_width 1
    } else {
        set channel_width [ expr int(ceil(log($channel) / log(2))) ]
    }
    
# | 
# +-----------------------------------
# | connection point in (avalon_streaming_sink)
# | 
add_interface in avalon_streaming end
set_interface_property in ENABLED true
set_interface_property in associatedClock clk
set_interface_property in associatedReset rst
set_interface_property in beatsPerCycle 1
set_interface_property in dataBitsPerSymbol $bits_per_symbol
set_interface_property in maxChannel $max_channel
set_interface_property in readyLatency 0
set_interface_property in symbolsPerBeat 1

add_interface_port in in_startofpacket startofpacket Input 1
add_interface_port in in_endofpacket endofpacket Input 1
add_interface_port in in_valid valid Input 1
add_interface_port in in_ready ready Output 1
add_interface_port in in_data data Input $bits_per_symbol

addPort in in_channel channel Input $channel_width "$channel == 1" 0
set_port_property in_channel VHDL_TYPE STD_LOGIC_VECTOR
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point out (avalon_streaming_source)
# | 
add_interface out avalon_streaming start
set_interface_property out ENABLED true
set_interface_property out associatedClock clk
set_interface_property out associatedReset rst
set_interface_property out beatsPerCycle 1
set_interface_property out dataBitsPerSymbol $bits_per_symbol
set_interface_property out maxChannel $max_channel
set_interface_property out readyLatency 0
set_interface_property out symbolsPerBeat 1

add_interface_port out out_startofpacket startofpacket Output 1
add_interface_port out out_endofpacket endofpacket Output 1
add_interface_port out out_valid valid Output 1
add_interface_port out out_ready ready Input 1
add_interface_port out out_data data Output $bits_per_symbol

addPort out out_channel channel Output $channel_width "$channel == 1" 0
set_port_property out_channel VHDL_TYPE STD_LOGIC_VECTOR
# | 
# +-----------------------------------
}


# +-----------------------------------
# | connection point clock
# | 
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface rst reset end
set_interface_property rst ENABLED true
set_interface_property rst associatedClock clk
add_interface_port rst rst reset Input 1
# | 
# +-----------------------------------
