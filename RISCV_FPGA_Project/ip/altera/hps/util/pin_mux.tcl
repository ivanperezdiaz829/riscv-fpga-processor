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


################################################################################
# These interfaces iterate the pin multiplexing data structures for the HPS.
# To use these procs, the first argument of each needs to be the name of the
# namespace that implements the following interface:
# 
# proc get_peripherals_model {}
#   Gets the pin muxing data for the model, mapped by peripheral
#
# proc get_emac0_fpga_ini {}
#   Returns 1 if emac0 FPGA is enabled
#
# proc get_lssis_fpga_ini {}
#   Returns 1 if LSSIs are enabled
#
# proc get_all_fpga_ini {}
#   Returns 1 if the all peripherals INI is enabled
#
# proc get_peripheral_pin_muxing_selection {peripheral_name}
#   Returns the valid pin multiplexing options for a peripheral
#
# proc get_peripheral_mode_selection {peripheral_name}
#   Returns the valid mode options for a peripheral
#
# proc get_gpio_pins {}
#   Returns the GPIO pins
#
# proc get_loanio_pins {}
#   Returns the LOAN I/O pins
#
# proc get_unsupported_peripheral {peripheral_name}
#   Returns 1 if the peripheral is not supported
#
################################################################################

proc is_pin_mux_data_available {model_ns} {
    return [expr {[${model_ns}::get_peripherals_model] != ""}]
}

proc get_peripheral_parameter_valid_ranges {model_ns
					    peripheral_name
					    selected_pin_muxing_option_ref
					    pin_muxing_options_ref
					    mode_options_ref} {

    upvar 1 $selected_pin_muxing_option_ref selected_pin_muxing_option_out
    upvar 1 $pin_muxing_options_ref         pin_muxing_options_out
    upvar 1 $mode_options_ref               mode_options_out
    
    set emac0_fpga [${model_ns}::get_emac0_fpga_ini]
    set lssis_fpga [${model_ns}::get_lssis_fpga_ini]
    set all_fpga   [${model_ns}::get_all_fpga_ini]
    
    array set peripherals [${model_ns}::get_peripherals_model]
    set pin_muxing_options [list]
    set selected_pin_muxing_option [${model_ns}::get_peripheral_pin_muxing_selection $peripheral_name]
    
    # FPGA Pin Muxing Option
    set fpga_option_available 0
    if {[peripheral_connects_to_fpga $peripheral_name]} {
	if {$all_fpga} {
	    set fpga_option_available 1
	} elseif {$emac0_fpga && [string compare -nocase $peripheral_name "emac0"] == 0} {
	    set fpga_option_available 1
	} elseif {$lssis_fpga && [is_peripheral_low_speed_serial_interface $peripheral_name]} {
	    set fpga_option_available 1
	} else {
	    set fpga_option_available 1
	    #Disable fpga interface for USB, SDIO, NAND
	    if {([string compare -nocase $peripheral_name "usb0"] == 0 || [string compare -nocase $peripheral_name "usb1"] == 0 || [string compare -nocase $peripheral_name "nand"] == 0 || [string compare -nocase $peripheral_name "sdio"] == 0)} {
		set fpga_option_available 0
	    }
        }

    }
    if {[string compare -nocase $peripheral_name "emac0" ] == 0 || [string compare -nocase $peripheral_name "emac1" ] == 0} {
	set fpga_option_available 1
    }
    if $fpga_option_available {
	lappend pin_muxing_options [FPGA_MUX_VALUE]
    }
    
    # HPS I/O Pin Muxing Options
    if {[info exists peripherals($peripheral_name)]} {
	funset peripheral
	array set peripheral $peripherals($peripheral_name)
	funset pin_sets
	array set pin_sets $peripheral(pin_sets)
	foreach pin_set_name [array names pin_sets] {
	    lappend pin_muxing_options $pin_set_name
	}
    }
    
    set valid_modes [get_valid_modes $peripheral_name $selected_pin_muxing_option peripheral $fpga_option_available]
    
    set selected_pin_muxing_option_out $selected_pin_muxing_option
    set pin_muxing_options_out         $pin_muxing_options
    set mode_options_out               $valid_modes
}

proc foreach_used_peripheral_pin {model_ns 
				  peripheral_name
				  signal_ref
				  signal_elements_ref
				  pin_ref
				  location_ref
				  mux_select_ref
				  body} {

    upvar 1 $signal_ref          signal_out
    upvar 1 $signal_elements_ref signal_elements_out
    upvar 1 $pin_ref             pin_out
    upvar 1 $location_ref        location_out
    upvar 1 $mux_select_ref      mux_select_out
    
    set skip [${model_ns}::get_unsupported_peripheral $peripheral_name]
    if {$skip == 1} {	
        return 
    }
    
    array set peripherals [${model_ns}::get_peripherals_model]

    set pin_muxing_value [${model_ns}::get_peripheral_pin_muxing_selection $peripheral_name]
    
    if {[string compare $pin_muxing_value [UNUSED_MUX_VALUE]] == 0 || [string compare $pin_muxing_value [FPGA_MUX_VALUE]] == 0} {
	return
    }
    
    set mode_value [${model_ns}::get_peripheral_mode_selection $peripheral_name]
    
    if {![info exists peripherals]} {
	return
    }
    funset peripheral
    array set peripheral $peripherals($peripheral_name)
    funset pin_sets
    array set pin_sets $peripheral(pin_sets)
    array set signals_by_mode $peripheral(signals_by_mode)
    
    set pin_set_names [array names pin_sets]
    if {[lsearch [array names pin_sets] $pin_muxing_value] == -1} {
	send_message error "Peripheral '$peripheral_name' has an illegal pin-set selected."
	return
    }
    
    funset pin_set
    array set pin_set $pin_sets($pin_muxing_value)
    set valid_modes $pin_set(valid_modes)
    
    if {[lsearch $valid_modes $mode_value] == -1} {
	send_message error "Peripheral '$peripheral_name' has an illegal mode set."
	return
    }
    
    funset known_conflicts
    set signal_parts $pin_set(signal_parts)
    set signals      $pin_set(signals)
    set pins         $pin_set(pins)
    set locations    $pin_set(locations)
    set mux_selects  $pin_set(mux_selects)
    
    # filter based on mode
    funset filtered_signal_set
    foreach signal $signals_by_mode($mode_value) {
	set filtered_signal_set($signal) 1
    }
    
    foreach map $signal_parts signal_name $signals pin $pins location $locations mux_select $mux_selects {
	if {[info exists filtered_signal_set($signal_name)] == 0} {
	    continue
	}
	
	set peripheral_out      $peripheral_name
	set signal_out          $signal_name
	set signal_elements_out $map
	set pin_out             $pin
	set location_out        $location
	set mux_select_out      $mux_select
	
	uplevel 1 $body
    }
}

################################################################################
# Will not set linked_peripheral_name if none can be found
#
proc get_linked_peripheral {model_ns
			    peripheral_name
			    pin_set_name
			    linked_peripheral_name_ref
			    linked_pin_set_name_ref
			    linked_mode_name_ref
			} {
################################################################################
    upvar 1 $linked_peripheral_name_ref linked_peripheral_name
    upvar 1 $linked_pin_set_name_ref    linked_pin_set_name
    upvar 1 $linked_mode_name_ref       linked_mode_name
    
    array set peripherals [${model_ns}::get_peripherals_model]
    array set peripheral  $peripherals($peripheral_name)
    array set pin_sets    $peripheral(pin_sets)

    if {[string compare $pin_set_name [UNUSED_MUX_VALUE]] == 0 || [string compare $pin_set_name [FPGA_MUX_VALUE]] == 0} {
	set pin_set_names [array names pin_sets]
    } else {
	set pin_set_names [list $pin_set_name]
    }

    foreach pin_set_name $pin_set_names {
	if {[info exists pin_sets($pin_set_name)]} {
	    funset pin_set
	    array set pin_set          $pin_sets($pin_set_name)
	    if {[info exists pin_set(linked_peripheral)]} {
		set linked_peripheral_name $pin_set(linked_peripheral)
		set linked_pin_set_name    $pin_set(linked_peripheral_pin_set)
		set linked_mode_name       $pin_set(linked_peripheral_mode)
		break
	    }
	}
    }
}

proc foreach_gpio_entry {model_ns
			 entry_ref gpio_index_ref gpio_name_ref pin_ref gplin_used_ref gplin_select_ref
			 body} {
    upvar 1 $entry_ref        entry_out
    upvar 1 $gpio_index_ref   gpio_index_out
    upvar 1 $gpio_name_ref    gpio_name_out
    upvar 1 $pin_ref          pin_out
    upvar 1 $gplin_used_ref   gplin_used_out
    upvar 1 $gplin_select_ref gplin_select_out
    
    set entry 0
    set gpio_pins [${model_ns}::get_gpio_pins]
    set gpio_count [llength $gpio_pins]
    for {set gpio_index 0} {$gpio_index < $gpio_count} {incr gpio_index} {
	set zero ""
	if {$gpio_index < 10} {set zero "0"};# No format in tcl??

	set pins [lindex $gpio_pins $gpio_index]
	set pins [lsort -ascii -increasing $pins]
	set gplin_used [expr {[llength $pins] > 1}]
	for {set pin_index 0} {$pin_index < [llength $pins]} {incr pin_index} {
	    set entry_out        $entry
	    set gpio_index_out   $gpio_index
	    set gpio_name_out    "GPIO${zero}${gpio_index}"
	    set pin_out          [lindex $pins $pin_index]
	    set gplin_used_out   $gplin_used
	    set gplin_select_out $pin_index ;# TODO: fix this when pin_mux_db supports this value
	    uplevel 1 $body
	    incr entry
	}
    }
}

proc foreach_loan_io_entry {model_ns
			    entry_ref loanio_index_ref loanio_name_ref pin_ref gplin_used_ref gplin_select_ref
			    body} {
    upvar 1 $entry_ref        entry_out
    upvar 1 $loanio_index_ref loanio_index_out
    upvar 1 $loanio_name_ref  loanio_name_out
    upvar 1 $pin_ref        pin_out
    upvar 1 $gplin_used_ref   gplin_used_out
    upvar 1 $gplin_select_ref gplin_select_out
    
    set entry 0
    set loanio_pins [${model_ns}::get_loanio_pins]
    set loanio_count [llength $loanio_pins]
    for {set loanio_index 0} {$loanio_index < $loanio_count} {incr loanio_index} {
	set zero ""
	if {$loanio_index < 10} {set zero "0"};# No format in tcl??

	set pins [lindex $loanio_pins $loanio_index]
	set pins [lsort -ascii -increasing $pins]
	set gplin_used [expr {[llength $pins] > 1}]
	for {set pin_index 0} {$pin_index < [llength $pins]} {incr pin_index} {
	    set entry_out        $entry
	    set loanio_index_out $loanio_index
	    set loanio_name_out  "LOANIO${zero}${loanio_index}"
	    set pin_out          [lindex $pins $pin_index]
	    set gplin_used_out   $gplin_used
	    set gplin_select_out $pin_index ;# TODO: fix this when pin_mux_db supports this value
	    uplevel 1 $body
	    incr entry
	}
    }
}
