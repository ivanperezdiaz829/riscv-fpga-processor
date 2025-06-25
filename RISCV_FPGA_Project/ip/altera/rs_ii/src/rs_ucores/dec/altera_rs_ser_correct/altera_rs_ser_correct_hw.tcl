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

source "../../../lib/altera_rs_utilities.tcl"
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_rs_ser_syn
# | 
set_module_property DESCRIPTION "Altera Reed Solomon Serial Corrector"
set_module_property NAME altera_rs_ser_correct
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "DSP/Reed Solomon II/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RS Serial Corrector"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
add_module_parametersCORRECT
add_module_parametersSTATUS
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validateCORRECT
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_filesets altera_rs_ser_correct

proc get_simulator_list {} {
    return { \
             {mentor   1   } \
             {aldec    1    } \
             {synopsys 0 } \
             {cadence  0  } \
           }
}

proc generate {type} {
    add_rs_package $type "../../.."
    add_encrypted_file $type altera_rs_ser_correct.sv
    add_encrypted_file $type altera_rs_ser_correct.ocp
}
# | 
# +-----------------------------------

# | 
# +-----------------------------------
# | Callbacks
# | 

proc elaborate {} {

    
    set bits_per_symbol   [ get_parameter_value BITSPERSYMBOL ]    
    set channel           [ get_parameter_value CHANNEL ]
    set check             [ get_parameter_value CHECK ]
    set symbols_per_beat  1
    set max_channel       [ expr $channel - 1 ]
    set erasure           [ get_parameter_value ERASURE ]
    set bitcounttype        [ get_parameter_value BITCOUNTTYPE ]
    set errorsymbol         [ get_parameter_value ERRORSYMB ]
    set errorsymbcount      [ get_parameter_value ERRORSYMBCOUNT ]
    set errorbitcount       [ get_parameter_value ERRORBITCOUNT ]
    
    
    if {$channel == 1} {
        set channel_width 1
    } else {
        set channel_width [ expr int(ceil(log($channel) / log(2))) ]
    }

    set data_width              [ expr $symbols_per_beat*$bits_per_symbol ]
    set error_symbols           [ expr int($check/2) ]
    
    
    if {$erasure == 1} {
    set error_width             [ expr int(ceil(log($check+1) / log(2))) ]
    set error_bits_width        [ expr int(ceil(log($check*$bits_per_symbol+1) / log(2))) ]
    } else {
    set error_width             [ expr int(ceil(log($error_symbols+1) / log(2))) ]
    set error_bits_width        [ expr int(ceil(log($error_symbols*$bits_per_symbol+1) / log(2))) ]
    }
    
    set sch_datawidth           [ expr $bits_per_symbol + 1 + $error_width ]
    

    # +-----------------------------------
    # | Elaborate sink interface (cw_in)
    # +-----------------------------------

    add_interface cw_in avalon_streaming end

    set_interface_property cw_in ENABLED true
    set_interface_property cw_in associatedClock clk
    set_interface_property cw_in associatedReset rst
    set_interface_property cw_in beatsPerCycle 1
    set_interface_property cw_in dataBitsPerSymbol $bits_per_symbol
    set_interface_property cw_in maxChannel $max_channel
    set_interface_property cw_in readyLatency 0
    set_interface_property cw_in symbolsPerBeat $symbols_per_beat
    
    add_interface_port cw_in cw_in_sop startofpacket Input 1
    add_interface_port cw_in cw_in_eop endofpacket Input 1
    add_interface_port cw_in cw_in_valid valid Input 1
    add_interface_port cw_in cw_in_channel channel Input 1
    add_interface_port cw_in cw_in_ready ready Output 1
    add_interface_port cw_in cw_in_data data Input $bits_per_symbol 
    add_interface_port cw_in cw_in_error error Input 1
    if {$erasure == 0} {set_port_property cw_in_error TERMINATION 1}
	


    addPort cw_in cw_in_channel channel Input $channel_width "$channel == 1" 0
	set_port_property cw_in_channel VHDL_TYPE STD_LOGIC_VECTOR

    # +-----------------------------------
    # | Elaborate sink interface (sch_in)
    # +-----------------------------------
    
    add_interface sch_in avalon_streaming end

    set_interface_property sch_in ENABLED true
    set_interface_property sch_in associatedClock clk
    set_interface_property sch_in associatedReset rst
    set_interface_property sch_in beatsPerCycle 1
    set_interface_property sch_in dataBitsPerSymbol $sch_datawidth
    set_interface_property sch_in maxChannel $max_channel
    set_interface_property sch_in readyLatency 0
    set_interface_property sch_in symbolsPerBeat 1
    
    add_interface_port sch_in sch_in_sop startofpacket Input 1
    add_interface_port sch_in sch_in_eop endofpacket Input 1
    add_interface_port sch_in sch_in_valid valid Input 1
    add_interface_port sch_in sch_in_error error Input 1
    add_interface_port sch_in sch_in_ready ready Output 1
    add_interface_port sch_in sch_in_data data Input $sch_datawidth 

    set_port_property sch_in_data fragment_list "sch_in_error_count([expr $error_width-1]:0) \
                                                 sch_in_error_magnitude([expr $bits_per_symbol-1]:0) \
                                                 sch_in_error_location"

    addPort sch_in sch_in_channel channel Input $channel_width "$channel == 1" 0
	set_port_property sch_in_channel VHDL_TYPE STD_LOGIC_VECTOR
    # +-----------------------------------
    # | Elaborate sink interface (cw_out)
    # +-----------------------------------
    
    add_interface cw_out avalon_streaming start
    set_interface_property cw_out ENABLED true
    set_interface_property cw_out associatedClock clk
    set_interface_property cw_out associatedReset rst
    set_interface_property cw_out beatsPerCycle 1
    set_interface_property cw_out dataBitsPerSymbol $bits_per_symbol
    set_interface_property cw_out maxChannel $max_channel
    set_interface_property cw_out readyLatency 0
    set_interface_property cw_out symbolsPerBeat $symbols_per_beat
    
    add_interface_port cw_out cw_out_sop startofpacket Output 1
    add_interface_port cw_out cw_out_eop endofpacket Output 1
    add_interface_port cw_out cw_out_error error Output 1
    add_interface_port cw_out cw_out_valid valid Output 1
    add_interface_port cw_out cw_out_ready ready Input 1
    add_interface_port cw_out cw_out_data data Output $data_width

    addPort cw_out cw_out_channel channel Output $channel_width "$channel == 1" 0
	set_port_property cw_out_channel VHDL_TYPE STD_LOGIC_VECTOR
    # +-----------------------------------
    # | Elaborate conduit interface (status)
    # +-----------------------------------
    
    add_interface status conduit end
    set_interface_property status ENABLED true
    #set_interface_property status associatedClock clk

    add_interface_port status num_error_symbol export Output $error_width
    add_interface_port status error_value export Output $bits_per_symbol
    add_interface_port status num_error_bit1 export Output $error_bits_width
    add_interface_port status num_error_bit0 export Output $error_bits_width
    add_interface_port status num_error_bit export Output $error_bits_width 
        
    # +-----------------------------------
    # | conduit interface Port Termination
    # +-----------------------------------
    
    if {!($errorsymbol)} {    
        set_port_property error_value TERMINATION 1
    }
    
    if {!($errorsymbcount)} {    
        set_port_property num_error_symbol TERMINATION 1
    }
    
    if {!($errorbitcount)} {    
        set_port_property num_error_bit TERMINATION 1
        set_port_property num_error_bit1 TERMINATION 1
        set_port_property num_error_bit0 TERMINATION 1 
    } else {
        if ([string equal $bitcounttype "Full"]) { 
            set_port_property num_error_bit0 TERMINATION 1
            set_port_property num_error_bit1 TERMINATION 1
        } else {
            set_port_property num_error_bit TERMINATION 1
        }
    }  
    
    
    
    
    
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



proc addPort { iface pName pRole pDir pWidth termComparison termValue } {

    if { $pWidth != 0 } {
        add_interface_port $iface $pName $pRole $pDir $pWidth

        if { [ expr $termComparison ] == 1 } {
            set_port_property $pName termination true
            set_port_property $pName termination_value $termValue
        }
    }
}



