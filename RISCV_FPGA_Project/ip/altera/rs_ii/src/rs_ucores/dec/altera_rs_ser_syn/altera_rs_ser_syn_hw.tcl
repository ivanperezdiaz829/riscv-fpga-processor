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
set_module_property DESCRIPTION "Altera Reed Solomon Serial Syndrome Generator"
set_module_property NAME altera_rs_ser_syn
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "DSP/Reed Solomon II/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RS Serial Syndrome Generator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
add_module_parametersDEC
set_module_property VALIDATION_CALLBACK validateDEC
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_filesets altera_rs_ser_syn

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
    add_encrypted_file $type altera_rs_ser_syn.sv
    add_encrypted_file $type altera_rs_ser_syn.ocp
}
# | 
# +-----------------------------------

proc _get_empty_width { symbolsPerBeat } {
    set empty_width [ expr int(ceil(log($symbolsPerBeat) / log(2))) ]
    return $empty_width
}

# +-----------------------------------
# | Callbacks
# | 


proc elaborate {} {
    
    set bits_per_symbol     [ get_parameter_value BITSPERSYMBOL ]
    set check               [ get_parameter_value CHECK ]
    set channel             [ get_parameter_value CHANNEL ]
    set erasure             [ get_parameter_value ERASURE ]

    
    set symbols_per_beat    1
    
    set cw_datawidth        [ expr $symbols_per_beat*$bits_per_symbol ]
    set syn_datawidth       [ expr $symbols_per_beat*$bits_per_symbol*$check ] 
    set eracnt_datawidth    [ expr int(ceil(log($check+1)/log(2))) ]
    set max_channel         [ expr $channel - 1 ]
    
    

    if {$channel == 1} {
        set channel_width 1
    } else {
        set channel_width [ expr int(ceil(log($channel) / log(2))) ]
    }
    
    
    
    if {$erasure == 1} {
        set syn_out_datawidth  [expr 2*$syn_datawidth+$eracnt_datawidth]
    } else {
        set syn_out_datawidth  $syn_datawidth
    }


    
    
    
    
    # +-----------------------------------
    # | Elaborate sink interface (cw_in)
    # +-----------------------------------
    
    add_interface cw_in avalon_streaming end

    set_interface_property cw_in ENABLED true
    set_interface_property cw_in associatedClock clk
    set_interface_property cw_in associatedReset rst
    set_interface_property cw_in beatsPerCycle 1
    set_interface_property cw_in dataBitsPerSymbol $cw_datawidth
    set_interface_property cw_in maxChannel $max_channel
    set_interface_property cw_in readyLatency 0
    set_interface_property cw_in symbolsPerBeat $symbols_per_beat
    
    add_interface_port cw_in cw_in_sop startofpacket Input 1
    add_interface_port cw_in cw_in_eop endofpacket Input 1
    add_interface_port cw_in cw_in_valid valid Input 1
    add_interface_port cw_in cw_in_ready ready Output 1
    add_interface_port cw_in cw_in_data data Input $cw_datawidth

    addPort cw_in cw_in_channel channel Input $channel_width "$channel == 1" 0
    set_port_property cw_in_channel VHDL_TYPE STD_LOGIC_VECTOR

    
    # +-----------------------------------
    # | Elaborate source interface (syn_out)
    # +-----------------------------------

    add_interface syn_out avalon_streaming start
 
    set_interface_property syn_out ENABLED true
    set_interface_property syn_out associatedClock clk
    set_interface_property syn_out associatedReset rst
    set_interface_property syn_out beatsPerCycle 1
    set_interface_property syn_out dataBitsPerSymbol $syn_out_datawidth
    set_interface_property syn_out maxChannel 0
    set_interface_property syn_out readyLatency 0
    set_interface_property syn_out symbolsPerBeat 1

    
    add_interface_port syn_out syn_out_sop startofpacket Output 1
    add_interface_port syn_out syn_out_eop endofpacket Output 1
    add_interface_port syn_out syn_out_valid valid Output 1
    add_interface_port syn_out syn_out_ready ready Input 1
    add_interface_port syn_out syn_out_data data Output $syn_out_datawidth

    
    if {$erasure==1} {
        add_interface_port cw_in cw_in_erasure error Input 1
                                                
        set_port_property syn_out_data fragment_list "syn_out_eracnt([expr $eracnt_datawidth-1]:0)\
                                                syn_out_erapos([expr $syn_datawidth-1]:0) \
                                                syn_out_synd([expr $syn_datawidth-1]:0)"                                                                                                
    } else {
        set_port_property syn_out_data fragment_list "syn_out_synd([expr $syn_datawidth-1]:0)"    
        
        add_interface status conduit end
        set_interface_property status ENABLED true
        add_interface_port status cw_in_erasure  export  Input 1
        add_interface_port status syn_out_erapos export Output $syn_datawidth
        add_interface_port status syn_out_eracnt export Output $eracnt_datawidth
        set_port_property syn_out_erapos TERMINATION 1
        set_port_property syn_out_eracnt TERMINATION 1      
        set_port_property cw_in_erasure TERMINATION 1        
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


