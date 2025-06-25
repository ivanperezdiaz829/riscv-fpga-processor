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


# package: quartus::device
#
# Provides a wrapper around the Quartus device functions
#
package provide quartus::device 1.0

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################
package require altera_hwtcl_qtcl

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::quartus::device:: {
	# Package Exports
	
	# Namespace variables
	
	# Import functions into namespace
	
}

################################################################################
###                      EXPORTED WRAPPERS                                   ###
################################################################################

proc ::quartus::device::get_part_info {args} {
	return [run_quartus_tcl_command "device:get_part_info $args"]
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
proc ::quartus::device::_init {} {

	return 1
}


################################################################################
###                   AUTO RUN CODE AT STARTUP                               ###
################################################################################
# Run the initialization
::quartus::device::_init
