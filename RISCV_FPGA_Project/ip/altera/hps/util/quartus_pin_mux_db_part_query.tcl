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
#   $Header: //acds/rel/13.1/ip/hps/util/quartus_pin_mux_db_part_query.tcl#1 $
#
#	Description: Quartus Tcl API that provides all the HPS pin muxing data
#                    in a single data structure. Data structure format is
#                    implied knowledge shared between this Quartus Tcl API
#                    and the hw.tcl API "pin_mux_db".
#
#	Author: Michael Tozaki
#	Date:   2012.02.02
#
###############################################################################

# TODO: move to ip/common/hw_tcl_packages

namespace eval :: {
    source [file join $quartus(tclpath) internal dev_pin_muxing_db.tcl]
}

# Maps peripheral names from the Quartus device database to
# the names used by the HPS IP Component
# TODO: is this library the best place to put this?
proc quartus_to_ip_peripheral_name_map {peripheral} {
    array set map {
	RGMII0 EMAC0
	RGMII1 EMAC1
	SDMMC  SDIO
    }
    
    if {[info exists map($peripheral)]} {
	set peripheral $map($peripheral)
    }
    return $peripheral    
}

proc get_cpu_core_info {device} {
    return [get_part_info -resource CPU_CORE $device] 
}

proc get_hh470_gplinmux_sel { part pin_name } {
    ::pin_mux_db::unload_db
    ::pin_mux_db::load_db $part	
    return [::pin_mux_db::get_pin_muxing_gplinmux_select $part $pin_name] 
}

# Returns a data structure pertaining to an HPS part
# Data list: index 0: array of peripheral names to lists of option names
#                  1: array of (peripheral name, option name) to signals
#                  2: array of (peripheral name, option name) to pins
proc get_part_collection {part} {
    ::pin_mux_db::unload_db
    ::pin_mux_db::load_db $part
    
    # Case:111219 - To fix AV NAND and EMAC1 option pins conflict issue, provide another interface which sorted option pins by mux select
    # Get family-specific get option pin API if any
    set device_family [get_dstr_string -family [lindex [get_part_info -family $part] 0] -debug]
    
    if { [string compare -nocase $device_family "arriav"] == 0 } {
    	set get_pin_muxing_option_pin_func "get_pin_muxing_option_pin_sorted_by_mux_select"
    	set get_pin_muxing_option_signal_select_func "get_pin_muxing_option_signal_select_sorted_by_mux_select"
    } else {
    	set get_pin_muxing_option_pin_func "get_pin_muxing_option_pin"
    	set get_pin_muxing_option_signal_select_func "get_pin_muxing_option_signal_select"
    }
    
    # TODO: use shared hps constant for lists
    set peripherals {
	RGMII0 RGMII1
	NAND
	QSPI
	SDMMC
	USB0 USB1
	SPIM0 SPIM1 SPIS0 SPIS1
	UART0 UART1
	I2C0 I2C1 I2C2 I2C3
	CAN0 CAN1
	TRACE
    }
    
    set peripheral_to_option_names [list]
    set option_signals             [list]
    set option_pins                [list]
    set option_mux_selects         [list]
    set location_by_pin            [list]
    
    foreach peripheral $peripherals {
	set options [::pin_mux_db::get_pin_muxing_option_names $part $peripheral]
	set ip_peripheral_name [quartus_to_ip_peripheral_name_map $peripheral]
	
	lappend peripheral_to_option_names $ip_peripheral_name $options

	foreach option $options {
	    set signals_key "${ip_peripheral_name}.${option}"
	    set signals [::pin_mux_db::get_pin_muxing_option_signals $part $peripheral $option]
	    lappend option_signals $signals_key $signals
	    
	    set pins        [list]
	    set mux_selects [list]
	    foreach signal $signals {
		set pin [::pin_mux_db::$get_pin_muxing_option_pin_func $part $peripheral $option $signal]
		lappend pins $pin
		set mux_select [::pin_mux_db::$get_pin_muxing_option_signal_select_func $part $peripheral $option $signal]
		lappend mux_selects $mux_select
		
		set set_of_pins($pin) 1
	    }
	    set pins_key $signals_key
	    lappend option_pins $pins_key $pins
	    set mux_selects_key $signals_key
	    lappend option_mux_selects $mux_selects_key $mux_selects
	}
    }
    
    set gpio_pins [list]
    # Case:115932 - After fixes in Case:71501 (skip unbonded pads), the HPS IO index may become incontinuous in small package.
    # get the last element index as the total count to avoid skip unbonded pads 
    set ordered_gpio_indices [list]
    ::pin_mux_db::get_pin_muxing_available_ordered_gpio_indices $part ordered_gpio_indices
    set max_gpio_index [lindex $ordered_gpio_indices end]
    for {set i 0} {$i <= $max_gpio_index} {incr i} {
	set pins [::pin_mux_db::get_pin_muxing_gpio_pin $part $i]
	lappend gpio_pins $pins
	set set_of_pins($pin) 1
    }

    set loanio_pins [list]
    # Case:115932 - After fixes in Case:71501 (skip unbonded pads), the HPS IO index may become incontinuous in small package.
    # get the last element index as the total count to avoid skip unbonded pads 
    set ordered_loanio_indices [list]
    ::pin_mux_db::get_pin_muxing_available_ordered_loanio_indices $part ordered_loanio_indices
    set max_loanio_index [lindex $ordered_loanio_indices end]
    for {set i 0} {$i <= $max_loanio_index} {incr i} {
	set pins [::pin_mux_db::get_pin_muxing_loanio_pin $part $i]
	lappend loanio_pins $pins
	set set_of_pins($pin) 1
    }
    
    set customer_pin_names [list]    
    for {set list_index 0} {$list_index < [llength $gpio_pins]} {incr list_index} { 
        set pin_name [lindex $gpio_pins $list_index]
	set pin_name [lsort -ascii -increasing $pin_name]
	for {set pin_index 0} {$pin_index < [llength $pin_name]} {incr pin_index} { 
	    set pin_out [lindex $pin_name $pin_index] 
	    set pins [::pin_mux_db::get_pin_muxing_customer_pin_name $part $pin_out]
	    lappend customer_pin_names $pins
	    set set_of_pins($pin) 1
	}        
    }
    
    set hlgpi_pins [list] 
    set hlgpi_count [::pin_mux_db::get_pin_muxing_hlgpi_count $part]
    for {set hlgpi_index 0} {$hlgpi_index < $hlgpi_count} {incr hlgpi_index} { 
        set hlgpi_pin [::pin_mux_db::get_pin_muxing_hlgpi_pin $part $hlgpi_index]
    	lappend hlgpi_pins $hlgpi_pin
        set set_of_pins($hlgpi_pin) 1        
    }
    
    foreach pin [array names set_of_pins] {
	set location [::pin_mux_db::get_pin_location $part $pin]
	lappend location_by_pin $pin $location
    }

    set result [list]
    lappend result "success"                   ;#0
    lappend result $peripheral_to_option_names ;#1
    lappend result $option_signals             ;#2
    lappend result $option_pins                ;#3
    lappend result $option_mux_selects         ;#4
    lappend result $location_by_pin            ;#5
    lappend result $gpio_pins                  ;#6
    lappend result $loanio_pins                ;#7
    lappend result $customer_pin_names         ;#8
    lappend result $hlgpi_pins                 ;#9
    return $result
}
