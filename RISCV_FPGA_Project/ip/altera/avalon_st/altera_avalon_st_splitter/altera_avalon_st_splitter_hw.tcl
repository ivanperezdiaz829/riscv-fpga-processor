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


# $File: //acds/main/ip/avalon_st/altera_avalon_st_splitter/altera_avalon_st_splitter_hw.tcl $
# $Revision: #13 $
# $Date: 2012/01/18 $
# $Author: pscheidt $
#------------------------------------------------------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_st_splitter
# | 
set_module_property NAME altera_avalon_st_splitter
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property DISPLAY_NAME "Avalon-ST Splitter"
set_module_property DESCRIPTION "Avalon-ST Splitter"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_st_splitter.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_st_splitter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_st_splitter.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUMBER_OF_OUTPUTS INTEGER 2
set_parameter_property NUMBER_OF_OUTPUTS AFFECTS_ELABORATION true
set_parameter_property NUMBER_OF_OUTPUTS HDL_PARAMETER true
set_parameter_property NUMBER_OF_OUTPUTS ALLOWED_RANGES 1:16

add_parameter QUALIFY_VALID_OUT INTEGER 1
set_parameter_property QUALIFY_VALID_OUT AFFECTS_ELABORATION true
set_parameter_property QUALIFY_VALID_OUT HDL_PARAMETER true
set_parameter_property QUALIFY_VALID_OUT ALLOWED_RANGES 0:1
set_parameter_property QUALIFY_VALID_OUT DISPLAY_HINT boolean

add_parameter USE_READY INTEGER 1
set_parameter_property USE_READY AFFECTS_ELABORATION true
set_parameter_property USE_READY DISPLAY_HINT boolean
set_parameter_property USE_READY ALLOWED_RANGES 0:1

add_parameter USE_VALID INTEGER 1
set_parameter_property USE_VALID AFFECTS_ELABORATION true
set_parameter_property USE_VALID ALLOWED_RANGES 0:1
set_parameter_property USE_VALID DISPLAY_HINT boolean

add_parameter USE_PACKETS INTEGER 0
set_parameter_property USE_PACKETS AFFECTS_ELABORATION true
set_parameter_property USE_PACKETS HDL_PARAMETER true
set_parameter_property USE_PACKETS ALLOWED_RANGES 0:1
set_parameter_property USE_PACKETS DISPLAY_HINT boolean

add_parameter USE_CHANNEL INTEGER 0
set_parameter_property USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property USE_CHANNEL ALLOWED_RANGES 0:1
set_parameter_property USE_CHANNEL DISPLAY_HINT boolean

add_parameter USE_ERROR INTEGER 0
set_parameter_property USE_ERROR AFFECTS_ELABORATION true
set_parameter_property USE_ERROR ALLOWED_RANGES 0:1
set_parameter_property USE_ERROR DISPLAY_HINT boolean

add_parameter USE_DATA INTEGER 1
set_parameter_property USE_DATA AFFECTS_ELABORATION true
set_parameter_property USE_DATA ALLOWED_RANGES 0:1
set_parameter_property USE_DATA DISPLAY_HINT boolean

add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH HDL_PARAMETER true
set_parameter_property DATA_WIDTH ALLOWED_RANGES 1:32000

add_parameter CHANNEL_WIDTH INTEGER 1
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES 1:32000

add_parameter ERROR_WIDTH INTEGER 1
set_parameter_property ERROR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ERROR_WIDTH HDL_PARAMETER true
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32000

add_parameter BITS_PER_SYMBOL INTEGER 8
set_parameter_property BITS_PER_SYMBOL AFFECTS_ELABORATION true
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES 1:32000

add_parameter MAX_CHANNELS INTEGER 1
set_parameter_property MAX_CHANNELS AFFECTS_ELABORATION true

add_parameter READY_LATENCY INTEGER 0
set_parameter_property READY_LATENCY AFFECTS_ELABORATION true

add_parameter ERROR_DESCRIPTOR STRING_LIST ""
set_parameter_property ERROR_DESCRIPTOR AFFECTS_ELABORATION true

add_parameter EMPTY_WIDTH INTEGER 1
set_parameter_property EMPTY_WIDTH DERIVED true
set_parameter_property EMPTY_WIDTH HDL_PARAMETER true
set_parameter_property EMPTY_WIDTH VISIBLE false
# | 
# +-----------------------------------



#-----------------------------------
# connection point: clk
#
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1
#-----------------------------------

#-----------------------------------
# connection point: reset
#
add_interface reset reset end
set_interface_property reset ENABLED true
set_interface_property reset associatedClock clk
add_interface_port reset reset reset Input 1
#-----------------------------------


proc elaborate {} {
    set use_ready        [ get_parameter_value USE_READY ]
    set use_valid        [ get_parameter_value USE_VALID ]
    set ready_latency    [ get_parameter_value READY_LATENCY ]

    set use_packets      [ get_parameter_value USE_PACKETS ]

    set use_channel      [ get_parameter_value USE_CHANNEL ]
    set channel_width    [ get_parameter_value CHANNEL_WIDTH ]
    
    if { $use_channel == 1 } {
	set max_channel  [ get_parameter_value MAX_CHANNELS ]
	set_parameter_property MAX_CHANNELS ENABLED true
    } else {
	set max_channel 0
	set_parameter_property MAX_CHANNELS ENABLED false
    }

    
    set use_error        [ get_parameter_value USE_ERROR ]

    if { $use_error == 1 } {
	set error_descriptor [ get_parameter_value ERROR_DESCRIPTOR ]
	set_parameter_property ERROR_DESCRIPTOR ENABLED true
    } else {
	set error_descriptor ""
	set_parameter_property ERROR_DESCRIPTOR ENABLED false
    }

    set error_width      [ get_parameter_value ERROR_WIDTH ]
    
    set use_data         [ get_parameter_value USE_DATA ]
    set data_width       [ get_parameter_value DATA_WIDTH ]
    set bits_per_symbol  [ get_parameter_value BITS_PER_SYMBOL ]
    set num_outputs      [ get_parameter_value NUMBER_OF_OUTPUTS ]

    set symbols_per_beat [ expr $data_width / $bits_per_symbol ]
    set empty_width [ log2ceiling $symbols_per_beat ]
	
    set_parameter_value EMPTY_WIDTH $empty_width

    #-------------------------
    # Elaborate Sink Interface
    #-------------------------

    add_interface in avalon_streaming end

    set_interface_property in errorDescriptor    $error_descriptor
    set_interface_property in readyLatency       $ready_latency
    set_interface_property in associatedClock    clk
    set_interface_property in associatedReset    reset
    set_interface_property in maxChannel         $max_channel
    set_interface_property in symbolsPerBeat     $symbols_per_beat
    set_interface_property in dataBitsPerSymbol  $bits_per_symbol

    #Ready Port
    addPort in in0_ready ready Output 1 "$use_ready == 0" 1

    #Valid Port
    addPort in in0_valid valid Input 1 "$use_valid == 0" 1

    #SOP
    addPort in in0_startofpacket startofpacket Input 1 "$use_packets == 0" 0

    #EOP
    addPort in in0_endofpacket endofpacket Input 1 "$use_packets == 0" 0

    #Empty Port
    addPort in in0_empty empty Input $empty_width "$use_packets == 0" 0

    #Channel Port
    addPort in in0_channel channel Input $channel_width "$use_channel == 0" 0

    #Error Port
    addPort in in0_error error Input $error_width "$use_error == 0" 0

    #Data Port
    addPort in in0_data data Input $data_width "$use_data == 0" 0

    
    #----------------------------
    # Elaborate Source Interfaces
    #----------------------------

    for {set i 0} {$i < 16} {incr i} {

	set disabledInterface [ expr $i >= $num_outputs ]

	set name "out$i"

	add_interface $name avalon_streaming start

	set_interface_property $name errorDescriptor    $error_descriptor
	set_interface_property $name readyLatency       $ready_latency
	set_interface_property $name associatedClock    clk
	set_interface_property $name associatedReset    reset
	set_interface_property $name maxChannel         $max_channel
	set_interface_property $name symbolsPerBeat     $symbols_per_beat
	set_interface_property $name dataBitsPerSymbol  $bits_per_symbol
	
	#Ready Port
	addPort $name ${name}_ready ready Input 1 "$disabledInterface || $use_ready == 0" 1

	#Valid Port
	addPort $name ${name}_valid valid Output 1 "$disabledInterface || $use_valid == 0" 1

	#SOP Port
	addPort $name ${name}_startofpacket startofpacket Output 1 "$disabledInterface || $use_packets == 0" 0
	
	#EOP Port
	addPort $name ${name}_endofpacket endofpacket Output 1 "$disabledInterface || $use_packets == 0" 0
	
	#Empty Port
	addPort $name ${name}_empty empty Output $empty_width "$disabledInterface || $use_packets == 0" 0

	#Channel Port
        addPort $name ${name}_channel channel Output $channel_width "$disabledInterface || $use_channel == 0" 0

	#Error Port
	addPort $name ${name}_error error Output $error_width "$disabledInterface || $use_error == 0" 0
	
	#Data Port
	addPort $name ${name}_data data Output $data_width "$disabledInterface || $use_data == 0" 0

	if { $disabledInterface } { 
	    set_interface_property $name enabled false
	}
    }
}


proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i < $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

    if { $val == 0 } {
	set val 1
    }

    return $val;
 }

proc addPort { iface pName pRole pDir pWidth termComparison termValue } {

    if { $pWidth != 0 } {
	add_interface_port $iface $pName $pRole $pDir $pWidth

	if { [ expr $termComparison ] == 1 } {
	    set_port_property $pName termination true
	    set_port_property $pName termination_value $termValue
	}
    }
}
