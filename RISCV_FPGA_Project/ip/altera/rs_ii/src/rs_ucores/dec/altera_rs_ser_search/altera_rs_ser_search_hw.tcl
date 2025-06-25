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
# | module altera_rs_par_steering
# | 
set_module_property DESCRIPTION "Altera Reed Solomon Search"
set_module_property NAME altera_rs_ser_search
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "DSP/Reed Solomon II/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RS Serial Error Search"
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
add_filesets altera_rs_ser_search

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
    add_encrypted_file $type altera_rs_ser_search.sv
    add_encrypted_file $type altera_rs_ser_search.ocp
}
# | 
# +-----------------------------------

# +-----------------------------------
# | Callbacks
# | 

proc elaborate {} {

    set bits_per_symbol     [ get_parameter_value BITSPERSYMBOL ]
    set check                 [ get_parameter_value CHECK ]
    set channel             [ get_parameter_value CHANNEL ]
    set erasure                [ get_parameter_value ERASURE ]
    
    set symbols_per_beat    1  
    
    
    if {$erasure == 1} {
    set error_symbols        $check
    } else {
    set error_symbols        [expr int($check/2) ]
    }    
    
    set err_cnt_width        [ expr int(ceil(log($error_symbols+1) / log(2))) ]    
    set poly_datawidth      [ expr $symbols_per_beat*$bits_per_symbol*$error_symbols  ]
    set bm_datawidth        [ expr 2 * $poly_datawidth + $err_cnt_width]
    set sch_datawidth        [ expr $bits_per_symbol + 1 + $err_cnt_width ]    
    
    
    set max_channel         [ expr $channel - 1 ]
    if {$channel == 1} {
        set channel_width 1
    } else {
        set channel_width [ expr int(ceil(log($channel) / log(2))) ]
    }




        
    # +-----------------------------------
    # | Elaborate sink interface (bm_in)
    # +-----------------------------------
    add_interface bm_in avalon_streaming end

    set_interface_property bm_in ENABLED true
    set_interface_property bm_in associatedClock clk
    set_interface_property bm_in associatedReset rst
    set_interface_property bm_in beatsPerCycle 1
    set_interface_property bm_in dataBitsPerSymbol $bm_datawidth
    set_interface_property bm_in maxChannel 0
    set_interface_property bm_in readyLatency 0
    set_interface_property bm_in symbolsPerBeat $symbols_per_beat
    
    add_interface_port bm_in bm_in_sop startofpacket Input 1
    add_interface_port bm_in bm_in_eop endofpacket Input 1
    add_interface_port bm_in bm_in_valid valid Input 1
    add_interface_port bm_in bm_in_ready ready Output 1
    #add_interface_port bm_in bm_in_empty empty Input 0
    add_interface_port bm_in bm_in_data data Input $bm_datawidth
    

    set_port_property bm_in_data fragment_list "bm_in_error_count([expr $err_cnt_width-1]:0) \
                                                 bm_in_error_evaluator([expr $poly_datawidth-1]:0) \
                                                 bm_in_error_locator([expr $poly_datawidth-1]:0)"


  
    # +-----------------------------------
    # | Elaborate source interface (sch_out)
    # +-----------------------------------
    add_interface sch_out avalon_streaming start

    set_interface_property sch_out ENABLED true
    set_interface_property sch_out associatedClock clk
    set_interface_property sch_out associatedReset rst
    set_interface_property sch_out beatsPerCycle 1
    set_interface_property sch_out dataBitsPerSymbol $sch_datawidth
    set_interface_property sch_out maxChannel $max_channel
    set_interface_property sch_out readyLatency 0
    set_interface_property sch_out symbolsPerBeat $symbols_per_beat
    
    add_interface_port sch_out sch_out_sop startofpacket Output 1
    add_interface_port sch_out sch_out_eop endofpacket Output 1
    add_interface_port sch_out sch_out_valid valid Output 1
    add_interface_port sch_out sch_out_error error Output 1
    add_interface_port sch_out sch_out_ready ready Input 1
    add_interface_port sch_out sch_out_data data Output $sch_datawidth
    #add_interface_port sch_out sch_out_empty empty Output 0
    
    set_port_property sch_out_data fragment_list "sch_out_error_count([expr $err_cnt_width-1]:0) \
                                                  sch_out_error_magnitude([expr $bits_per_symbol-1]:0) \
                                                  sch_out_error_location"
                              

    addPort sch_out sch_out_channel channel Output $channel_width "$channel == 1" 0
    set_port_property sch_out_channel VHDL_TYPE STD_LOGIC_VECTOR
 
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



