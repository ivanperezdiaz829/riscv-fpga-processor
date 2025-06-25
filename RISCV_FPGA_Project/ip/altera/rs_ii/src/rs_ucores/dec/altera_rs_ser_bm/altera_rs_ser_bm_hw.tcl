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
# | module altera_rs_ser_bm
# | 
set_module_property DESCRIPTION "Altera Reed Solomon Serial Berlekamp-Massey"
set_module_property NAME altera_rs_ser_bm
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "DSP/Reed Solomon II/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RS Serial Berlekamp-Massey"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
add_module_parametersBM
set_module_property VALIDATION_CALLBACK validateBM
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_filesets altera_rs_ser_bm

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
    add_encrypted_file $type altera_rs_ser_bm.sv
    add_encrypted_file $type altera_rs_ser_bm.ocp
}
# | 
# +-----------------------------------

# +-----------------------------------

proc elaborate {} {

    set bits_per_symbol      [ get_parameter_value BITSPERSYMBOL ]
    set check                [ get_parameter_value CHECK ]
    set erasure              [ get_parameter_value ERASURE ]
    
    set symbols_per_beat  1
    
    if {$erasure == 1} {
    set error_symbols        $check
    } else {
    set error_symbols        [expr int($check/2) ]
    }
    
    set syn_datawidth        [ expr $symbols_per_beat*$bits_per_symbol*$check ]
    set err_cnt_width        [ expr int(ceil(log($error_symbols+1) / log(2))) ]
    set era_cnt_width        [ expr int(ceil(log($check+1) / log(2))) ]
    set poly_datawidth       [ expr $symbols_per_beat*$bits_per_symbol*$error_symbols ]
    set bm_datawidth         [ expr 2 * $poly_datawidth + $err_cnt_width ]
    

    if {$erasure == 1} {
        set syn_in_datawidth    [expr  2 * $syn_datawidth + $era_cnt_width]
    } else {
        set syn_in_datawidth    $syn_datawidth
    }
    
    

    # +-----------------------------------
    # | Elaborate sink interface (syn_in)
    # +-----------------------------------
    add_interface syn_in avalon_streaming end

    set_interface_property syn_in ENABLED true
    set_interface_property syn_in associatedClock clk
    set_interface_property syn_in associatedReset rst
    set_interface_property syn_in beatsPerCycle 1
    set_interface_property syn_in dataBitsPerSymbol $syn_in_datawidth
    set_interface_property syn_in maxChannel 0
    set_interface_property syn_in readyLatency 0
    set_interface_property syn_in symbolsPerBeat $symbols_per_beat
    
    add_interface_port syn_in syn_in_sop startofpacket Input 1
    add_interface_port syn_in syn_in_eop endofpacket Input 1
    add_interface_port syn_in syn_in_valid valid Input 1
    add_interface_port syn_in syn_in_ready ready Output 1
    add_interface_port syn_in syn_in_data data Input $syn_in_datawidth

    
    if {$erasure == 1} {                                                
        set_port_property syn_in_data fragment_list "syn_in_eracnt([expr $era_cnt_width-1]:0)\
                                                syn_in_erapos([expr $syn_datawidth-1]:0) \
                                                syn_in_synd([expr $syn_datawidth-1]:0)"        
    } else {
        set_port_property syn_in_data fragment_list "syn_in_synd([expr $syn_datawidth-1]:0)"
        
        add_interface status conduit end
        set_interface_property status ENABLED true
        add_interface_port status syn_in_erapos export Input $syn_datawidth
        add_interface_port status syn_in_eracnt export Input $era_cnt_width
        set_port_property syn_in_erapos TERMINATION 1
        set_port_property syn_in_eracnt TERMINATION 1
    }

    # +-----------------------------------
    # | Elaborate source interface (bm_out)
    # +-----------------------------------
    add_interface bm_out avalon_streaming start
    set_interface_property bm_out ENABLED true
    set_interface_property bm_out associatedClock clk
    set_interface_property bm_out associatedReset rst
    set_interface_property bm_out beatsPerCycle 1
    set_interface_property bm_out dataBitsPerSymbol $bm_datawidth 
    set_interface_property bm_out maxChannel 0
    set_interface_property bm_out readyLatency 0
    set_interface_property bm_out symbolsPerBeat $symbols_per_beat
    
    add_interface_port bm_out bm_out_sop startofpacket Output 1
    add_interface_port bm_out bm_out_eop endofpacket Output 1
    add_interface_port bm_out bm_out_valid valid Output 1
    add_interface_port bm_out bm_out_ready ready Input 1
    add_interface_port bm_out bm_out_data data Output $bm_datawidth
    
    set_port_property bm_out_data fragment_list "bm_out_error_count([expr $err_cnt_width-1]:0) \
                                                 bm_out_error_evaluator([expr $poly_datawidth-1]:0) \
                                                 bm_out_error_locator([expr $poly_datawidth-1]:0)"


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

