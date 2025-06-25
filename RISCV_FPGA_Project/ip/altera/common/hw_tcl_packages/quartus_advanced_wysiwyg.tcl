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


# package: quartus::advanced_wysiwyg
#
# Provides a wrapper around the Quartus advanced_wysiwyg functions.
package provide quartus::advanced_wysiwyg 1.0

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################
package require altera_hwtcl_qtcl


################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::quartus::advanced_wysiwyg:: {
    # Package Exports
    
    # Namespace variables
    
    # Import functions into namespace
    
}


################################################################################
###                      EXPORTED WRAPPERS                                   ###
################################################################################

proc ::quartus::advanced_wysiwyg::get_param_list {args} {
    return [lindex [run_quartus_tcl_command "advanced_wysiwyg:get_param_list $args"] 0]
}

proc ::quartus::advanced_wysiwyg::get_port_list {args} {
    return [lindex [run_quartus_tcl_command "advanced_wysiwyg:get_port_list $args"] 0]
}

proc ::quartus::advanced_wysiwyg::get_wysiwyg_list {args} {
    return [lindex [run_quartus_tcl_command "advanced_wysiwyg:get_wysiwyg_list $args"] 0]
}


################################################################################
###                       PUBLIC FUNCTIONS                                   ###
################################################################################


################################################################################
###                       PRIVATE FUNCTIONS                                  ###
################################################################################

# proc: _init
#
# Private function to initialize the package
# file
#
# parameters:
#
# returns:
#
proc ::quartus::advanced_wysiwyg::_init {} {
    
    return 1
}


################################################################################
###                   AUTO RUN CODE AT STARTUP                               ###
################################################################################
# Run the initialization
::quartus::advanced_wysiwyg::_init
