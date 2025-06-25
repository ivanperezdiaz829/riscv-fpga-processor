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


###############################################################################
#
#   $Header: //acds/rel/13.1/ip/hps/util/locations.tcl#1 $
#
#	Description: hw.tcl API for accessing HPS atom locations.
#                    Uses the Quartus Tcl bridge to query information
#                    and caches it in variables.
#
#	Author: Michael Tozaki
#	Date:   2012.07.31
#
###############################################################################

package require altera_hwtcl_qtcl

namespace eval locations {
    source [file join $::env(QUARTUS_ROOTDIR) .. ip altera hps util procedures.tcl]

    variable part
    variable hps_io
    variable fpga

    proc load {part_value} {
	variable part $part_value
	variable hps_io
	funset   hps_io
	variable fpga
	funset   fpga
    }

    proc query_quartus_for_location {part atom_name peripheral_index} {
	set quartus_script_path [file join $::env(QUARTUS_ROOTDIR) .. ip altera hps util quartus_locations_query.tcl]
	set cmd "advanced_device:source ${quartus_script_path};get_peripheral_location $part $atom_name $peripheral_index"
	set location [lindex [run_quartus_tcl_command $cmd] 0]
	return $location
    }

    proc get_hps_io_peripheral_location {peripheral_name} {
	set cached 0
	variable hps_io
	if {[info exists hps_io($peripheral_name)]} {
	    set location $hps_io($peripheral_name)
	    set cached 1
	}

	if {!$cached} {
	    variable part
	    set atom_name [hps_io_peripheral_to_generic_atom_name $peripheral_name]
	    
	    set peripheral_index 0
	    if {[is_peripheral_one_of_many $peripheral_name]} {
		set peripheral_index [get_peripheral_index $peripheral_name]
	    }
	    
	    set location [query_quartus_for_location $part $atom_name $peripheral_index]
	    
	    # cache result
	    set hps_io($peripheral_name) $location
	}
	return $location
    }

################################################################################
# Finds the location for an fpga peripheral
# If a part has not been set, will return empty string
#
    proc get_fpga_location {peripheral_name atom_name} {
################################################################################
	set cached 0
	variable fpga
	if {[info exists fpga($peripheral_name)]} {
	    set location $fpga($peripheral_name)
	    set cached 1
	}

	if {!$cached} {
	    variable part
	    if {![info exists part]} {
		return ""
	    }

	    set peripheral_index 0
	    if {[is_peripheral_one_of_many $peripheral_name]} {
		set peripheral_index [get_peripheral_index $peripheral_name]
	    }
	    
	    set location [query_quartus_for_location $part $atom_name $peripheral_index]

	    # cache result
	    set fpga($peripheral_name) $location
	}
	return $location
    }
}
