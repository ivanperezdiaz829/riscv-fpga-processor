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


# (C) 2001-2011 Altera Corporation. All rights reserved.
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


# (C) 2001-2011 Altera Corporation. All rights reserved.
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


# (C) 2001-2009 Altera Corporation. All rights reserved.
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


#------------------------------------------------------------------------------
# tcl helper procedures:
#
#    proc add_export_if                  { name type dir net } {
#    proc add_streaming_interface        { name dir width clock } {
#    proc add_clock_interface            { name dir width } {
#    proc add_conduit_interface          { name dir width } {
#    proc add_param_int                  { name defaul_val range tab } {
#    proc add_param_str                  { name defaul_val range tab } {
#    proc add_param_str_no_range_hdl     { name tab } {
#    proc add_param_bool                 { name defaul_val tab } {
#    proc add_param_int_not_hdl          { name defaul_val range tab } {
#    proc add_param_str_no_range_not_hdl { name defaul_val tab } {
#    proc get_set_parameter              { name parameter } {
#    proc ac                             { net_x net_y }
#    proc ac_1parameter                  { net_x net_y param1 } {
#    proc ac_2parameter                  { net_x net_y param1 param2 } {
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------

# add_export_if
proc add_export_if { name type dir net } {
    if { $type == "st" } {
        set type avalon_streaming
    }

    add_interface          $name $type $dir
    set_interface_property $name export_of $net
	set_interface_property $name ENABLED true
#   send_message info "add_export_if $net"
}

proc add_export_if_clk { name type dir net clock } {
    if { $type == "st" } {
        set type avalon_streaming
    }

    add_interface          $name $type $dir
    set_interface_property $name export_of $net
	set_interface_property $name ENABLED true
    set_interface_property $name ASSOCIATED_CLOCK $clock
#   send_message info "add_export_if $net"
}

# add_streaming_interface
proc add_streaming_interface { name dir width clock } {
    if { $dir == "end" || $dir == "input" || $dir == "sink" } {
        set dir_if   end
        set dir_port Input
    } elseif { $dir == "start" || $dir == "output" || $dir == "source" } {
        set dir_if   start
        set dir_port Output
    } else {
        set dir_if   unknown
        set dir_port unknown
    }

    add_interface          $name avalon_streaming $dir_if
    set_interface_property $name dataBitsPerSymbol $width
    set_interface_property $name errorDescriptor ""
    set_interface_property $name maxChannel 0
    set_interface_property $name readyLatency 0
    set_interface_property $name symbolsPerBeat 1
    set_interface_property $name ASSOCIATED_CLOCK $clock
    set_interface_property $name ENABLED true
    add_interface_port     $name $name data $dir_port $width
}

# add_clock_interface
proc add_clock_interface { name dir width } {
    if { $dir == "end" || $dir == "input" || $dir == "sink" } {
        set dir_if   end
        set dir_port Input
    } elseif { $dir == "start" || $dir == "output" || $dir == "source" } {
        set dir_if   start
        set dir_port Output
    } else {
        set dir_if   unknown
        set dir_port unknown
    }

    add_interface          $name   clock $dir_if
    set_interface_property $name   ENABLED true
    add_interface_port     $name   $name clk $dir_port $width
}

proc add_conduit_interface { name dir width } {
    if { $dir == "end" || $dir == "input" || $dir == "sink" } {
        set dir_if   end
        set dir_port Input
    } elseif { $dir == "start" || $dir == "output" || $dir == "source" } {
        set dir_if   start
        set dir_port Output
    } else {
        set dir_if   unknown
        set dir_port unknown
    }
    
    add_interface          $name conduit $dir_if
    set_interface_property $name ENABLED true
    add_interface_port     $name $name export  $dir_port $width
}

#------------------------------------------------------------------------------
proc add_param_int { name defaul_val range tab } {
    add_parameter          $name INTEGER            $defaul_val
    set_parameter_property $name DEFAULT_VALUE      $defaul_val
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      true 
    set_parameter_property $name ALLOWED_RANGES     $range
    add_display_item $tab  $name parameter
}

proc add_param_str { name defaul_val range tab } {
    add_parameter          $name STRING             $defaul_val
    set_parameter_property $name DEFAULT_VALUE      $defaul_val
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      true 
    set_parameter_property $name ALLOWED_RANGES     $range
    add_display_item  $tab $name parameter
}

proc add_param_str_no_range_hdl { name tab } {
    add_parameter          $name STRING             
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      true 
    add_display_item  $tab $name parameter
}

proc add_param_bool { name defaul_val tab } {
    add_parameter          $name BOOLEAN            $defaul_val
    set_parameter_property $name DEFAULT_VALUE      $defaul_val
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      true 
    add_display_item  $tab $name parameter
}

proc add_param_int_not_hdl { name defaul_val range tab } {
    add_parameter          $name INTEGER            $defaul_val
    set_parameter_property $name DEFAULT_VALUE      $defaul_val
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      false
    set_parameter_property $name ALLOWED_RANGES     $range
    add_display_item $tab  $name parameter
}

proc add_param_str_no_range_not_hdl { name defaul_val tab } {
    add_parameter          $name STRING             $defaul_val
    set_parameter_property $name DEFAULT_VALUE      $defaul_val
    set_parameter_property $name DISPLAY_NAME       $name
    set_parameter_property $name UNITS              None
    set_parameter_property $name DISPLAY_HINT       ""
    set_parameter_property $name AFFECTS_GENERATION true
    set_parameter_property $name HDL_PARAMETER      false
    add_display_item  $tab $name parameter
}

#------------------------------------------------------------------------------
proc get_set_parameter { name parameter } {
    set_instance_parameter $name $parameter [get_parameter_value $parameter]
}
#------------------------------------------------------------------------------

proc ac { net_x net_y } {
    add_connection ${net_x}/${net_y}
}

proc ac_1parameter { net_x net_y p1 } {
    add_connection           ${net_x}/${net_y}
    set_connection_parameter ${net_x}/${net_y} [lindex $p1 0] [lindex $p1 1]
}

proc ac_2parameter { net_x net_y p1 p2 } {
    add_connection           ${net_x}/${net_y}
    set_connection_parameter ${net_x}/${net_y} [lindex $p1 0] [lindex $p1 1]
    set_connection_parameter ${net_x}/${net_y} [lindex $p2 0] [lindex $p2 1]
}
#------------------------------------------------------------------------------
