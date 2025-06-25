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


package require -exact qsys 13.0

source "../src/lib/altera_rs_utilities.tcl"

# |
# +-----------------------------------

# +-----------------------------------
# | module altera_rs_ii
# |
set_module_property NAME altera_rs_ii
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Digital Signal Processing/Error Detection_Correction"
set_module_property DISPLAY_NAME "Reed Solomon II"
set_module_property DESCRIPTION "Altera Reed Solomon II"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_rsii.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
add_module_parametersTOP 
set_module_property VALIDATION_CALLBACK validateTOP
set_module_property COMPOSITION_CALLBACK compose
set_module_property ANALYZE_HDL false



# +-----------------------------------
# | Callbacks
# | 
proc compose {} {
    #    send_message info "current bps=$bits_per_symbol"
    set rs                 [ get_parameter_value RS ]
    set bits_per_symbol    [ get_parameter_value BITSPERSYMBOL ]   
    set check              [ get_parameter_value CHECK ]
    set irrpol             [ get_parameter_value IRRPOL ]
    set i0                 [ get_parameter_value GENSTART ]
    set rootspace          [ get_parameter_value ROOTSPACE ]
    set channel            [ get_parameter_value CHANNEL ]
    set n                  [ get_parameter_value N ]
    set genpoltype         [ get_parameter_value GENPOLTYPE] 
    set erasure            [ get_parameter_value ERASURE ]
    set bitcounttype       [ get_parameter_value BITCOUNTTYPE ]
    set errorsymbol         [ get_parameter_value ERRORSYMB ]
    set errorsymbcount      [ get_parameter_value ERRORSYMBCOUNT ]
    set errorbitcount       [ get_parameter_value ERRORBITCOUNT ]
    


    # Clock Source
    add_instance clk_rst clock_source
    add_interface clk clock end
    set_interface_property clk export_of clk_rst.clk_in
    set_instance_parameter clk_rst resetSynchronousEdges DEASSERT
    set_instance_parameter clk_rst clockFrequencyKnown "false"

    # Reset
    add_interface reset reset end
    set_interface_property reset export_of clk_rst.clk_in_reset
    
    
    
        # 
    if ([string equal $genpoltype "CCSDS-like"]) {
        set genstart        [expr $i0*$rootspace%[expr 2**$bits_per_symbol-1]]
    } else {
        set genstart        [expr $i0]
    }

    #send_message warning "GENPOLTYPE is $genpoltype, so GENSTART is $genstart and ROOTSPACE is $rootspace, N is $n, CHECK is $check, IRRPOL is $irrpol and BITSPERSYMBOL is $bits_per_symbol, CHANNEL is $channel"


    
    
    if ([string equal $rs "Encoder"]) {
        add_instance rs_encoder altera_rs_ser_enc
        set_instance_parameter rs_encoder BITSPERSYMBOL $bits_per_symbol
        set_instance_parameter rs_encoder CHECK $check
        set_instance_parameter rs_encoder IRRPOL $irrpol
        set_instance_parameter rs_encoder GENSTART $genstart
        set_instance_parameter rs_encoder ROOTSPACE $rootspace
        set_instance_parameter rs_encoder CHANNEL $channel
    } else {
        add_instance rs_decoder altera_rs_ser_dec
        set_instance_parameter rs_decoder BITSPERSYMBOL $bits_per_symbol
        set_instance_parameter rs_decoder CHECK $check
        set_instance_parameter rs_decoder IRRPOL $irrpol
        set_instance_parameter rs_decoder GENSTART $genstart
        set_instance_parameter rs_decoder ROOTSPACE $rootspace
        set_instance_parameter rs_decoder CHANNEL $channel
        set_instance_parameter rs_decoder N $n
        # Decoder status and options
        set_instance_parameter rs_decoder ERASURE $erasure
        set_instance_parameter rs_decoder ERRORSYMB $errorsymbol
        set_instance_parameter rs_decoder ERRORSYMBCOUNT $errorsymbcount
        set_instance_parameter rs_decoder ERRORBITCOUNT $errorbitcount
        set_instance_parameter rs_decoder BITCOUNTTYPE $bitcounttype
    }

    if ([string equal $rs "Encoder"]) {
        # Export In
        add_interface in avalon_streaming end
        set_interface_property in export_of rs_encoder.in
        
        # Export Out
        add_interface out avalon_streaming start
        set_interface_property out export_of rs_encoder.out

        # Add connection

        add_connection clk_rst.clk/rs_encoder.clk
        add_connection clk_rst.clk_reset/rs_encoder.rst
    } else {
        # Export In
        add_interface in avalon_streaming end
        set_interface_property in export_of rs_decoder.in
        
        # Export Out
        add_interface out avalon_streaming start
        set_interface_property out export_of rs_decoder.out
        if {$errorsymbol | $errorsymbcount | $errorbitcount} {
            add_interface status conduit end
            set_interface_property status export_of rs_decoder.status
        }
        # Add connection

        add_connection clk_rst.clk/rs_decoder.clk
        add_connection clk_rst.clk_reset/rs_decoder.rst
    }

}

        










