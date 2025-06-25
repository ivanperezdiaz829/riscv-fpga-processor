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
#   $Header: //acds/rel/13.1/ip/hps/util/pin_mux_db.tcl#1 $
#
#	Description: hw.tcl API for accessing HPS pin muxing data.
#                    Uses the Quartus Tcl bridge and, in a single transaction,
#                    gathers all the data on a single HPS part and caches it
#                    for later retrieval.
#
#	Author: Michael Tozaki
#	Date:   2012.02.02
#
###############################################################################

# TODO: move to ip/common/hw_tcl_packages and provide as package

package require altera_hwtcl_qtcl

namespace eval ::pin_mux_db {
    # TODO: put procedures in a package and package require it
    source "$::env(QUARTUS_ROOTDIR)/../ip/altera/hps/util/procedures.tcl"
    
    variable peripheral_to_option_names
    variable option_signals
    variable option_pins
    variable option_mux_selects
    variable location_by_pin
    variable gpio_pins
    variable loanio_pins
    variable customer_pin_names
    
    proc verify_soc_device {device} {
	set quartus_script_path "$::env(QUARTUS_ROOTDIR)/../ip/altera/hps/util/quartus_pin_mux_db_part_query.tcl"
        set result [lindex [run_quartus_tcl_command "advanced_device:source ${quartus_script_path};get_cpu_core_info $device"] 0]
        if {$result > 0} { ;# if there is at least one a9 core, it is an SoC device
            return 1
        } else {
            return 0
        }
    }

    # get GPLINMUX select
    proc get_gplinmux_select {device pin_name} {
	set quartus_script_path "$::env(QUARTUS_ROOTDIR)/../ip/altera/hps/util/quartus_pin_mux_db_part_query.tcl"
        set result [lindex [run_quartus_tcl_command "advanced_device:source ${quartus_script_path};get_hh470_gplinmux_sel $device $pin_name"] 0]
        return $result
    }
    
    proc load {part} {
	set PASSED_LIST_SIZE 10
	set quartus_script_path "$::env(QUARTUS_ROOTDIR)/../ip/altera/hps/util/quartus_pin_mux_db_part_query.tcl"

	set db [lindex [run_quartus_tcl_command "advanced_device:source ${quartus_script_path};get_part_collection $part"] 0]

	variable peripheral_to_option_names
	funset peripheral_to_option_names
	variable option_signals
	funset option_signals
	variable option_pins
	funset option_pins
	variable option_mux_selects
	funset option_mux_selects
	variable location_by_pin
	funset location_by_pin
	variable gpio_pins
	funset gpio_pins
	variable loanio_pins
	funset loanio_pins
        variable customer_pin_names
	funset customer_pin_names
	variable hlgpi_pins
	funset hlgpi_pins
	
       	if {[llength $db] != $PASSED_LIST_SIZE} {
	    return 0
	}
	set check_string                     [lindex $db 0]
	if {$check_string != "success"} {
	    return 0
	}
	array set peripheral_to_option_names [lindex $db 1]
	array set option_signals             [lindex $db 2]
	array set option_pins                [lindex $db 3]
	array set option_mux_selects         [lindex $db 4]
	array set location_by_pin            [lindex $db 5]
	set gpio_pins                        [lindex $db 6]
	set loanio_pins                      [lindex $db 7]
	set customer_pin_names               [lindex $db 8]	
	set hlgpi_pins                       [lindex $db 9]	
	return 1
    }
    
    proc get_option_names {peripheral_name} {
	variable peripheral_to_option_names
	return $peripheral_to_option_names($peripheral_name)
    }

    proc get_option_signals {peripheral_name option_name} {
	variable option_signals
	set key "${peripheral_name}.${option_name}"
	return $option_signals($key)
    }

    proc get_option_pins {peripheral_name option_name} {
	variable option_pins
	set key "${peripheral_name}.${option_name}"
	return $option_pins($key)
    }
    
    proc get_option_mux_selects {peripheral_name option_name} {
	variable option_mux_selects
	set key "${peripheral_name}.${option_name}"
	return $option_mux_selects($key)
    }
    
    proc get_option_locations {peripheral_name option_name} {
	set result [list]
	set pins [get_option_pins $peripheral_name $option_name]
	foreach pin $pins {
	    set location [get_location_of_pin $pin]
	    lappend result $location
	}
	return $result
    }

    proc get_location_of_pin {pin} {
	variable location_by_pin
	return $location_by_pin($pin)
    }

    proc get_gpio_pins {} {
	variable gpio_pins
	return $gpio_pins
    }

    proc get_loan_io_pins {} {
	variable loanio_pins
	return $loanio_pins
    }
    
    proc get_customer_pin_names {} {
	variable customer_pin_names
	return $customer_pin_names
    }
    
    proc get_hlgpi_pins {} {
	variable hlgpi_pins
	return $hlgpi_pins
    }
}
