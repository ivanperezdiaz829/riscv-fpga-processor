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


#--------------------------------------------------------------------------------------
# procedures.tcl
#
# Description: procedures shared amongst IP under HPS.
#
# Dependencies: hps/util/constants.tcl
#               altera_hps_hw.tcl (::fpga_intefaces)
#--------------------------------------------------------------------------------------


proc clear_array { name } {
    if { [uplevel array exists $name ] == 1 } { 
	uplevel array unset $name
    }
}

# Force Unset
proc funset {var_name} {
    upvar 1 $var_name var
    if {[info exists var]} {
	unset var
    }
}

# TODO: support newlines within quoted cells
proc csv_foreach_row {file cells_var_name loop_body} {
    set fp [open $file r]
    set filedata [read $fp]
    close $fp
    set data [split $filedata "\n"]
    
    foreach line $data {
	if {[regexp {^[ \t\n,]*$} $line]} continue ;# Skip empty lines
	
	set line [string trim $line]
	upvar 1 $cells_var_name cells
	set cells [list]
	
	set POST_COMMA                   0
	set STRING                       1
	set STRING_IN_QUOTES             2
	set STRING_IN_QUOTES_FIRST_QUOTE 3
	set WAITING_FOR_COMMA            4
	set mode $POST_COMMA

	set space_buffer ""
	set cell_buffer  ""
	set line_length [string length $line]
	for {set col 0} {$col < $line_length} {incr col} {
	    set ch [string index $line $col]
	    
	    if {$mode == $POST_COMMA} {
		if {[string is space $ch]} {
		    # do nothing
		} elseif {[string compare $ch ","] == 0} {
		    lappend cells ""
		} elseif {[string compare $ch "\""] == 0} {
		    set mode $STRING_IN_QUOTES
		    set cell_buffer ""
		} else {
		    set mode $STRING
		    set cell_buffer $ch
		    set space_buffer ""
		}
	    } elseif {$mode == $STRING} {
		if {[string compare $ch ","] == 0} {
		    lappend cells $cell_buffer
		    set mode $POST_COMMA
		} elseif {[string is space $ch]} {
		    set space_buffer "${space_buffer}${ch}"
		} else {
		    set cell_buffer  "${cell_buffer}${space_buffer}${ch}"
		    set space_buffer ""
		}
	    } elseif {$mode == $STRING_IN_QUOTES} {
		if {[string compare $ch "\""] == 0} {
		    set mode $STRING_IN_QUOTES_FIRST_QUOTE
		} else {
		    set cell_buffer "${cell_buffer}${ch}"
		}
	    } elseif {$mode == $STRING_IN_QUOTES_FIRST_QUOTE} {
		if {[string compare $ch "\""] == 0} {
		    set cell_buffer "${cell_buffer}${ch}"
		    set mode $STRING_IN_QUOTES
		} else {
		    lappend cells $cell_buffer
		    
		    if {[string compare $ch ","] == 0} {
			set mode $POST_COMMA
		    } else {
			set mode $WAITING_FOR_COMMA
		    }
		}
	    } elseif {$mode == $WAITING_FOR_COMMA} {
		if {[string compare $ch ","] == 0} {
		    set mode $POST_COMMA
		}
	    } else {
		send_message error "CSV Scanning of file ${file} failed"
		return
	    }
	}
	if {$mode == $POST_COMMA} {
	    lappend cells ""
	} elseif {$mode == $STRING} {
	    lappend cells $cell_buffer
	} elseif {$mode == $STRING_IN_QUOTES} {
	    lappend cells $cell_buffer
	} elseif {$mode == $STRING_IN_QUOTES_FIRST_QUOTE} {
	    lappend cells $cell_buffer
	} elseif {$mode == $WAITING_FOR_COMMA} {
	    # do nothing
	}
	
	uplevel 1 $loop_body
    }
}

proc sanitize_direction {dir} {
   set dir [string tolower $dir]
   if {[string compare $dir "bidir"] == 0} {
      set dir "inout"
   }
   return $dir
}

proc create_pin_set_name {option} {
    set result ""
    set option_length [string length $option]
    for {set i $option_length} {$i >= 0} {incr i -1} {
	set ch [string index $option $i]
	if {[string compare $ch "_"] == 0} {
	    break
	}
	set result "${ch}${result}"
    }
    return "HPS I/O Set ${result}"
}

proc load_pin_to_atom_mapping {peripheral_to_pins_ref peripheral_pin_to_signals_ref} {
    upvar 1 $peripheral_to_pins_ref        peripheral_to_pins
    upvar 1 $peripheral_pin_to_signals_ref peripheral_pin_to_signals
    
    set csv_file [file join $::env(QUARTUS_ROOTDIR) .. ip altera hps altera_hps "pin_to_atom_mapping.csv"]
    set count 0
    csv_foreach_row $csv_file cols {  ;# peripheral atom and location table
	incr count
	if {$count == 1} continue

	set peripheral_name      [string trim [lindex $cols 0]]
	set pin_name             [string trim [lindex $cols 1]]
	set input_signal         [string trim [lindex $cols 2]]
	set input_idx            [string trim [lindex $cols 3]]
	set output_signal        [string trim [lindex $cols 4]]
	set output_idx           [string trim [lindex $cols 5]]
	set oe_signal            [string trim [lindex $cols 6]]
	set oe_idx               [string trim [lindex $cols 7]]
	
	foreach name {input output oe} {
	    upvar 0 ${name}_signal tempsignal
	    upvar 0 ${name}_idx    tempidx
	    if {$tempsignal != ""} {
		set index 0
		if {$tempidx != ""} {
		    set index $tempidx
		}
		set tempsignal "${tempsignal}(${index}:${index})"
	    }
	}

	if {[info exists peripheral_to_pins($peripheral_name)] == 0} {
	    set peripheral_to_pins($peripheral_name) [list]
	}
	lappend peripheral_to_pins($peripheral_name) $pin_name
	
	set key "${peripheral_name}.${pin_name}"
	set peripheral_pin_to_signals($key) [list $input_signal $output_signal $oe_signal]
	
	funset peripheral
	if {[info exists peripherals($peripheral_name)]} {
	    array set peripheral $peripherals($peripheral_name)
	} else {
	    # Assume that if a peripheral hasn't be recognized until now, we won't be using it
	    continue
	}
	set peripheral(atom_name)           $atom_name
	set peripheral(location_assignment) $location_assignment
	set peripherals($peripheral_name)   [array get peripheral]
    }
    return [list [array get peripheral_to_pins] [array get peripheral_pin_to_signals]]
}

# TODO: 12.1 add support for variable widths and optional signals
proc load_modes {modes_by_peripheral_ref pins_by_peripheral_mode_ref} {
    upvar 1 $modes_by_peripheral_ref      modes_by_peripheral
    upvar 1 $pins_by_peripheral_mode_ref  pins_by_peripheral_mode
    
    set csv_file [file join $::env(QUARTUS_ROOTDIR) .. ip altera hps altera_hps "modes.csv"]
    csv_foreach_row $csv_file cols {
	set peripheral [string trim [lindex $cols 0]]
	set mode       [string trim [lindex $cols 1]]
	set signal     [string toupper [string trim [lindex $cols 2]]]
	set width      [string trim [lindex $cols 3]]
	set optional   [string trim [lindex $cols 4]]

	if {[string compare [string index $peripheral 0] "\#"] == 0} {
	    continue
	}

	# Add mode
	set key "${peripheral}${mode}"
	if {[info exists mode_set($key)] == 0} {
	    set mode_set($key) 1
	    if {[info exists modes_by_peripheral($peripheral)] == 0} {
		set modes_by_peripheral($peripheral) [list]
	    }
	    lappend modes_by_peripheral($peripheral) $mode
	}
	
	# Add pin to mode
	set final_signals [list $signal]
	if {$width != ""} {
	    set valid_widths [list]
	    
	    # support range of widths (hyphen) and list of widths (commas)
	    set parts [split $width ","]
	    foreach part $parts {
		set part [string trim $part]
		if {[string is integer $part]} {
		    lappend valid_widths $part
		} else {
		    # if not an integer, it is probably a range
		    set range [split $part "-"]
		    set legal_range [expr {[llength range] != 2}]
		    if {$legal_range} {
			set lo [lindex $range 0]
			set hi [lindex $range 1]
		    }
		    if {$legal_range == 0 || $lo > $hi} {
			send_message error "Illegal signal width for signal ${signal} of mode ${mode} on peripheral type ${peripheral}"
		    }
		    for {set i $lo} {$i <= $hi} {incr i} {
			lappend valid_widths $i
		    }
		}
	    }
	    # For 12.0, use greatest width
	    set valid_widths [lsort -integer -decreasing $valid_widths]
	    if {[llength $valid_widths] > 0} {
		set final_width [lindex $valid_widths 0]
		
		if {$final_width < 1} {
		    send_message error "Illegal signal width for signal ${signal} of mode ${mode} on peripheral type ${peripheral}"
		}
		
		set final_signals [list]
		for {set i 0} {$i < $final_width} {incr i} {
		    lappend final_signals "${signal}${i}"
		}
	    }
	}
	
	set key "${peripheral}.${mode}"
	if {[info exists pins_by_peripheral_mode($key)] == 0} {
	    set pins_by_peripheral_mode($key) [list]
	}
	foreach final_signal $final_signals {
	    lappend pins_by_peripheral_mode($key) $final_signal
	}
    }
}

# find association between EMACs and I2Cs.. then modify the data structure
# then alter pin_mux.tcl to traverse the new data structure
proc load_peripherals_pin_muxing_model {pin_muxing_peripherals_ref} {
    upvar 1 $pin_muxing_peripherals_ref pin_muxing_peripherals

    load_pin_to_atom_mapping peripheral_to_pins peripheral_pin_to_signals

    load_modes modes_by_peripheral pins_by_peripheral_mode
    funset pin_muxing_peripherals
    foreach peripheral_name [list_peripheral_names] {
	# peripheral to peripheral type
	set peripheral_type [peripheral_to_type $peripheral_name]
	
	funset signals_by_mode
	foreach mode $modes_by_peripheral($peripheral_type) {
	    set key "${peripheral_type}.${mode}"
	    set signals_by_mode($mode) $pins_by_peripheral_mode($key)
	}
	
	funset pin_sets

	# foreach pin muxing option
	foreach option_name [pin_mux_db::get_option_names $peripheral_name] {
	    set signals [pin_mux_db::get_option_signals $peripheral_name $option_name]
	    set pins [pin_mux_db::get_option_pins $peripheral_name $option_name]
	    set mux_selects [pin_mux_db::get_option_mux_selects $peripheral_name $option_name]
	    set locations [pin_mux_db::get_option_locations $peripheral_name $option_name]
	    
	    funset signal_set
	    
	    set signal_parts [list]
	    set signals_uppercase [list]
	    foreach signal $signals {
		set signal [string toupper $signal]
		lappend signals_uppercase $signal
		set key "${peripheral_type}.$signal"
		set map $peripheral_pin_to_signals($key)
		lappend signal_parts $map
		set signal_set($signal) 1
	    }
	    set signals $signals_uppercase
	    
	    # discover valid modes
	    set valid_modes [list]
	    foreach mode [array names signals_by_mode] {
		set success 1
		foreach signal $signals_by_mode($mode) {
		    if {[info exists signal_set($signal)] == 0} {
			set success 0
			break
		    }
		}
		if {$success} {
		    lappend valid_modes $mode
		}
	    }
	    
	    set pin_set(valid_modes)  $valid_modes
	    set pin_set(signals)      $signals
	    set pin_set(pins)         $pins
	    set pin_set(signal_parts) $signal_parts
	    set pin_set(locations)    $locations
	    set pin_set(mux_selects)  $mux_selects

	    set pin_set_name [create_pin_set_name $option_name]
	    set pin_sets($pin_set_name) [array get pin_set]
	}
	funset peripheral_array
	set peripheral_array(pin_sets)     [array get pin_sets]
	set peripheral_array(signals_by_mode) [array get signals_by_mode]

	set pin_muxing_peripherals($peripheral_name) [array get peripheral_array]
    }

    adjust_pin_muxing_with_exceptions pin_muxing_peripherals
}

proc adjust_pin_muxing_with_exceptions {pin_muxing_peripherals_ref} {
    upvar 1 $pin_muxing_peripherals_ref pin_muxing_peripherals
    
    set exception_callbacks {
	adjust_pin_muxing_with_emac_i2c_exception
    }
    
    foreach callback $exception_callbacks {
	$callback pin_muxing_peripherals
    }
}

################################################################################
# Looks for situations where EMAC can use I2C instead of MDIO
# -Adds modes to EMAC for using the I2C
#   -These modes do not include the MDIO/MDC pins
# -Adds modes to I2C when EMAC is using it
# 
proc adjust_pin_muxing_with_emac_i2c_exception {pin_muxing_peripherals_ref} {
################################################################################
    upvar 1 $pin_muxing_peripherals_ref pin_muxing_peripherals

    array set emac_signals_of_interest {"MDIO" 1 "MDC" 1}
    array set i2c_signals_of_interest  {"SDA"  1 "SCL" 1}

    # array set i2c_set  {}
    # array set emac_set {}
    foreach peripheral_name [list_peripheral_names] {
	if {[string match *I2C* $peripheral_name]} {
	    set i2c_set($peripheral_name) 1
	} elseif {[string match *EMAC* $peripheral_name]} {
	    set emac_set($peripheral_name) 1
	}
    }

    # Find all unique pin sets that use I2C
    select_signals pin_muxing_peripherals i2c_signals_of_interest\
	[array names i2c_set] i2c_pin_keys i2c_name_by_pin_key i2c_pinset_by_pin_key {}
    
    # find pins where I2C can replace MDIO in EMACs
    foreach emac_name [array names emac_set] {
	funset emac
	array set emac $pin_muxing_peripherals($emac_name)
	funset pin_sets
	array set pin_sets $emac(pin_sets)
	funset signals_by_mode
	array set signals_by_mode $emac(signals_by_mode)
	
	funset emac_pin_keys
	funset emac_name_by_pin_key
	funset emac_pinset_by_pin_key
	funset emac_modes_by_pin_key
	select_signals pin_muxing_peripherals emac_signals_of_interest\
	    [list $emac_name] emac_pin_keys emac_name_by_pin_key emac_pinset_by_pin_key emac_modes_by_pin_key
	
	foreach pin_key [array names emac_pin_keys] {
	    # find an i2c that uses compatible pins
	    if {![info exists i2c_pin_keys($pin_key)]} {
		continue
	    }
	    
	    set i2c_name $i2c_name_by_pin_key($pin_key)

	    funset pin_set
	    set pin_set_name $emac_pinset_by_pin_key($pin_key)
	    array set pin_set $pin_sets($pin_set_name)

	    # create derivative modes
	    foreach mode $emac_modes_by_pin_key($pin_key) {
		#		if {[info exists affected_modes($mode)]} {}
		set new_mode "${mode} with ${i2c_name}"
		
		set new_mode_signals [list]
		foreach signal $signals_by_mode($mode) {
		    if {![info exists emac_signals_of_interest($signal)]} {
			lappend new_mode_signals $signal
		    }
		}
		
		lappend pin_set(valid_modes) $new_mode
		set signals_by_mode($new_mode) $new_mode_signals
	    }

	    # add new mode to i2c, for a specific pinset
	    set i2c_pin_set_name $i2c_pinset_by_pin_key($pin_key)
	    set new_mode "Used by ${emac_name}"
	    funset i2c
	    array set i2c $pin_muxing_peripherals($i2c_name)
	    funset i2c_pin_sets
	    array set i2c_pin_sets $i2c(pin_sets)
	    funset i2c_pin_set
	    array set i2c_pin_set $i2c_pin_sets($i2c_pin_set_name)
	    lappend   i2c_pin_set(valid_modes) $new_mode
	    set i2c_pin_sets($i2c_pin_set_name) [array get i2c_pin_set]
	    set i2c(pin_sets) [array get i2c_pin_sets]
	    funset    i2c_signals_by_mode
	    array set i2c_signals_by_mode $i2c(signals_by_mode)
	    set template $i2c_signals_by_mode(I2C)
	    set i2c_signals_by_mode($new_mode) $template
	    set i2c(signals_by_mode) [array get i2c_signals_by_mode]
	    set pin_muxing_peripherals($i2c_name) [array get i2c]
	    
	    set pin_set(linked_peripheral)         $i2c_name
	    set pin_set(linked_peripheral_pin_set) $i2c_pin_set_name
	    set pin_set(linked_peripheral_mode)    $new_mode
	    
	    set pin_sets($pin_set_name) [array get pin_set]
	}
	
	# update modes in data structure
	set emac(signals_by_mode) [array get signals_by_mode]
	set emac(pin_sets)        [array get pin_sets]
	set pin_muxing_peripherals($emac_name) [array get emac]
    }
}

proc select_signals {pin_muxing_peripherals_ref
		     signals_of_interest_set_ref
		     peripheral_names
		     pin_keys_out_ref
		     peripheral_by_pin_key_out_ref
		     pin_set_by_pin_key_out_ref
		     modes_by_pin_key_out_ref
		 } {
    upvar 1 $pin_muxing_peripherals_ref    pin_muxing_peripherals
    upvar 1 $signals_of_interest_set_ref   signals_of_interest_set
    upvar 1 $pin_keys_out_ref              pin_keys_out
    upvar 1 $peripheral_by_pin_key_out_ref peripheral_by_pin_key_out
    upvar 1 $pin_set_by_pin_key_out_ref    pin_set_by_pin_key_out
    if {$modes_by_pin_key_out_ref != ""} {
	upvar 1 $modes_by_pin_key_out_ref  modes_by_pin_key_out
    }
    
    foreach peripheral_name $peripheral_names {
	array set peripheral $pin_muxing_peripherals($peripheral_name)
	
	funset modes_of_interest_set
	funset found_signals_of_interest_set
	foreach {mode signals} $peripheral(signals_by_mode) {
	    foreach signal $signals {
		if {[info exist signals_of_interest_set($signal)]} {
		    set found_signals_of_interest_set($signal) 1
		}
	    }
	    if {[array size found_signals_of_interest_set] ==
		[array size signals_of_interest_set]} {
		
		set modes_of_interest_set($mode) 1
	    }
	}
	
	funset pin_sets
	array set pin_sets $peripheral(pin_sets)
	
	foreach pin_set_name [array names pin_sets] {
	    funset pin_set
	    array set pin_set $pin_sets($pin_set_name)
	    
	    # does it have the signals we care about?
	    set interesting 0
	    set matched_modes [list]
	    foreach mode $pin_set(valid_modes) {
		if {[info exists modes_of_interest_set($mode)]} {
		    lappend matched_modes $mode
		}
	    }
	    if {[llength $matched_modes] == 0} {
		continue
	    }
	    
	    # make a key
	    set unsorted_pins [list]
	    foreach signal $pin_set(signals) pin $pin_set(pins) {
		if {[info exists signals_of_interest_set($signal)]} {
		    lappend unsorted_pins $pin
		}
	    }
	    set sorted_pins [lsort -increasing -ascii $unsorted_pins]
	    set pin_key [join $sorted_pins ","]
	    
	    set pin_keys_out($pin_key)              1
	    set peripheral_by_pin_key_out($pin_key) $peripheral_name
	    set pin_set_by_pin_key_out($pin_key)    $pin_set_name
	    set modes_by_pin_key_out($pin_key)      $matched_modes
	}
    }
}

proc add_files_to_simulation_fileset {allInterfaceInfos} {
   # function: add hdl files to be included into simulation fileset
   # input:    requires the top level value to the 'interfaces' key from the tcl data structure
   
   clear_array interfaces
   array set interfaces $allInterfaceInfos
   set interfaceNames $interfaces(@orderednames)
   
   # check the bfm to include
   set include_axi_bfm 0
   foreach interfaceName $interfaceNames {
      clear_array interfaceInfos
      array set interfaceInfos $interfaces($interfaceName)

      set type $interfaceInfos(type)
      if {[string equal $type "axi"]} {
         set include_axi_bfm 1
      }
   }
   
   set HDL_LIB_DIR      "$::env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification"
   set MENTOR_VIP_DIR   "$::env(QUARTUS_ROOTDIR)/../ip/altera/mentor_vip_ae"
   
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/lib/verbosity_pkg.sv
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/lib/avalon_utilities_pkg.sv
   add_fileset_file avalon_mm_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/lib/avalon_mm_pkg.sv
   add_fileset_file altera_avalon_mm_slave_bfm.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/altera_avalon_mm_slave_bfm/altera_avalon_mm_slave_bfm.sv

   set_fileset_file_attribute verbosity_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_mm_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_mm_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
   
   if {$include_axi_bfm} {
      add_fileset_file questa_mvc_svapi.svh SYSTEM_VERILOG PATH $MENTOR_VIP_DIR/common/questa_mvc_svapi.svh
      add_fileset_file mgc_common_axi.sv SYSTEM_VERILOG PATH $MENTOR_VIP_DIR/axi3/bfm/mgc_common_axi.sv
      add_fileset_file mgc_axi_master.sv SYSTEM_VERILOG PATH $MENTOR_VIP_DIR/axi3/bfm/mgc_axi_master.sv
      add_fileset_file mgc_axi_slave.sv SYSTEM_VERILOG PATH $MENTOR_VIP_DIR/axi3/bfm/mgc_axi_slave.sv   
   }
   
   add_fileset_file altera_avalon_interrupt_sink.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/altera_avalon_interrupt_sink/altera_avalon_interrupt_sink.sv
   add_fileset_file altera_avalon_clock_source.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/altera_avalon_clock_source/altera_avalon_clock_source.sv
   add_fileset_file altera_avalon_reset_source.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/altera_avalon_reset_source/altera_avalon_reset_source.sv
}

proc create_conduit_bfms {allInterfaceInfos outputName} {
   # function: to terp one conduit bfm per conduit or reset input interface
   # input:    requires the top level value to the 'interfaces' key from the tcl data structure
   #           and the component's dynamic module name
   
   clear_array interfaces
   array set interfaces $allInterfaceInfos
   set interfaceNames $interfaces(@orderednames) 
   
   foreach interfaceName $interfaceNames {
      clear_array interfaceInfos
      array set interfaceInfos $interfaces($interfaceName)

      set type $interfaceInfos(type)
      set direction $interfaceInfos(direction)
            
      # generate in a procedure
      if {[is_to_be_connected_to_conduit_bfm $type $direction]} {
         set clocked_conduit [is_clocked_conduit interfaceInfos]
         
         clear_array signals
         array set signals $interfaceInfos(signals)
         set signalNames $signals(@orderednames)
         set signalRoleWidthDir ""
         foreach signalName $signalNames {
            clear_array signalInfos
            array set signalInfos  $signals($signalName)
            
            set signalRole   $signalName
            set signalDir    $signalInfos(direction)
            set signalWidth  $signalInfos(width)
            
            if {[string equal $signalRoleWidthDir ""]} {
               set signalRoleWidthDir "${signalRole}:${signalWidth}:${signalDir}"
            } else {
               set signalRoleWidthDir "${signalRoleWidthDir},${signalRole}:${signalWidth}:${signalDir}"
            }
         }
         
         # setting up variables to do terp         
         set HDL_LIB_DIR "$::env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/verification"
         set templateFile [read [open "${HDL_LIB_DIR}/altera_conduit_bfm/altera_conduit_bfm.v.terp" r]]
         
         set params(output_name) ${outputName}_${interfaceName}
         set params(rolemap)     $signalRoleWidthDir
         set params(clocked)     $clocked_conduit
         
         do_terp $templateFile params
      }
   }
}

proc get_bfm {interfaceType interfaceDirection} {
   # function: to determine which bfm class to be use for the interface in the HPS simulation model
   # input:    need to provide qsys's interface type and direction. 
   #           these information can be found in each of the interfaces key
   #           in the tcl data structure
   # returns:  the bfm component class
   
   set interfaceType       [string tolower $interfaceType]
   set interfaceDirection  [string tolower $interfaceDirection]

   set bfmList       [list axi_master mgc_axi_master]
   lappend bfmList   axi_slave mgc_axi_slave
   lappend bfmList   avalon_slave altera_avalon_mm_slave_bfm
   lappend bfmList   interrupt_receiver altera_avalon_interrupt_sink
   lappend bfmList   clock_output altera_avalon_clock_source
   lappend bfmList   reset_output altera_avalon_reset_source
   
   array set bfmTable $bfmList
   set key ${interfaceType}_${interfaceDirection}
   if {[info exists bfmTable($key)]} {
      return $bfmTable($key)
   } else {
      return -code continue
   }
}

proc get_bfm_ports {bfm} {
   # function: to get list of port names and port roles of a bfm class
   # input:    bfm component class
   # returns:  nested list of the bfm class's port role and port name
   
   set bfmTypePortsList       [list mgc_axi_master {clk ACLK reset_n ARESETn bready BREADY arready ARREADY arid ARID awprot AWPROT \
         wdata WDATA arburst ARBURST arcache ARCACHE awaddr AWADDR awvalid AWVALID arlock ARLOCK rready RREADY arsize ARSIZE bresp BRESP \
         awuser AWUSER bid BID arlen ARLEN wvalid WVALID awlen AWLEN arprot ARPROT rid RID rdata RDATA awid AWID wlast WLAST araddr ARADDR \
         bvalid BVALID awready AWREADY arvalid ARVALID aruser ARUSER wstrb WSTRB awburst AWBURST awcache AWCACHE wready WREADY rvalid RVALID \
         awlock AWLOCK rlast RLAST wid WID awsize AWSIZE rresp RRESP}]
   lappend bfmTypePortsList   mgc_axi_slave {clk ACLK reset_n ARESETn bready BREADY arready ARREADY arid ARID awprot AWPROT wdata \
      WDATA arburst ARBURST arcache ARCACHE awaddr AWADDR awvalid AWVALID arlock ARLOCK rready RREADY arsize ARSIZE bresp BRESP awuser AWUSER \
      bid BID arlen ARLEN wvalid WVALID awlen AWLEN arprot ARPROT rid RID rdata RDATA awid AWID wlast WLAST araddr ARADDR bvalid BVALID \
      awready AWREADY arvalid ARVALID aruser ARUSER wstrb WSTRB awburst AWBURST awcache AWCACHE wready WREADY rvalid RVALID awlock AWLOCK \
      rlast RLAST wid WID awsize AWSIZE rresp RRESP}
   lappend bfmTypePortsList   altera_avalon_mm_slave_bfm {clk clk reset reset waitrequest avs_waitrequest readdatavalid avs_readdatavalid \
      readdata avs_readdata write avs_write read avs_read address avs_address byteenable avs_byteenable burstcount avs_burstcount \
      beginbursttransfer avs_beginbursttransfer begintransfer avs_begintransfer writedata avs_writedata arbiterlock avs_arbiterlock \
      lock avs_lock debugaccess avs_debugaccess transactionid avs_transactionid readresponse avs_readresponse readid avs_readid \
      writeresponserequest avs_writeresponserequest writeresponsevalid avs_writeresponsevalid writeresponse avs_writeresponse \
      writeid avs_writeid clken avs_clken}
   lappend bfmTypePortsList   altera_avalon_interrupt_sink {clk clk reset reset irq irq}
   lappend bfmTypePortsList   altera_avalon_clock_source {clk clk}
   lappend bfmTypePortsList   altera_avalon_reset_source {clk clk reset_n reset}
   
   array set bfmPortsTable $bfmTypePortsList
   return $bfmPortsTable($bfm)
}

proc get_bfm_port_direction {bfm portName} {
   # function: get bfm's individual port direction
   # input:    bfm component class, bfm port name
   # returns:  bfm port direction
   
   set mgc_axi_master [list ACLK input ARESETn input \
         AWVALID output AWADDR output AWLEN output AWSIZE output AWBURST output AWLOCK output \
         AWCACHE output AWPROT output AWID output AWREADY input AWUSER output \
         ARVALID output ARADDR output ARLEN output ARSIZE output ARBURST output ARLOCK output \
         ARCACHE output  ARPROT output ARID output ARREADY input ARUSER output \
         RVALID input RLAST input RDATA input RRESP input RID input RREADY output \
         WVALID output WLAST output WDATA output WSTRB output WID output WREADY input \
         BVALID input BRESP input BID input BREADY output]
         
   set mgc_axi_slave [list ACLK input ARESETn input \
         AWVALID input AWADDR input AWLEN input AWSIZE input AWBURST input AWLOCK input \
         AWCACHE input AWPROT input AWID input AWREADY output AWUSER input \
         ARVALID input ARADDR input ARLEN input ARSIZE input ARBURST input ARLOCK input \
         ARCACHE input  ARPROT input ARID input ARREADY output ARUSER input \
         RVALID output RLAST output RDATA output RRESP output RID output RREADY input \
         WVALID input WLAST input WDATA input WSTRB input WID input WREADY output \
         BVALID output BRESP output BID output BREADY input]
         
   set altera_avalon_mm_slave_bfm [list clk input reset input avs_waitrequest output avs_readdatavalid output \
         avs_readdata output avs_write input avs_read input avs_address input avs_byteenable input \
         avs_burstcount input avs_beginbursttransfer input avs_begintransfer input avs_writedata input \
         avs_arbiterlock input avs_lock input avs_debugaccess input avs_transactionid input \
         avs_readresponse output avs_readid output avs_writeresponserequest input \
         avs_writeresponsevalid output avs_writeresponse output avs_writeid output avs_clken input]

   set altera_avalon_interrupt_sink [list clk input reset input irq input]
   set altera_avalon_clock_source [list clk output]
   set altera_avalon_reset_source [list clk input reset output]

   switch $bfm {
      mgc_axi_master                {set bfmPort $mgc_axi_master}
      mgc_axi_slave                 {set bfmPort $mgc_axi_slave}
      altera_avalon_mm_slave_bfm    {set bfmPort $altera_avalon_mm_slave_bfm}
      altera_avalon_interrupt_sink  {set bfmPort $altera_avalon_interrupt_sink}
      altera_avalon_clock_source    {set bfmPort $altera_avalon_clock_source}
      altera_avalon_reset_source    {set bfmPort $altera_avalon_reset_source}      
   }
   
   array set bfmPortDirection $bfmPort
   return $bfmPortDirection($portName)   
}

proc get_bfm_parameters {bfm} {
   # function: to get list of parameters of a bfm class
   # input:    bfm component class
   # returns:  nested list of the bfm class's parameter, parameter tag and parameter default value
   
   set bfmTypeParamsList       [list mgc_axi_master {{AXI_ID_WIDTH "id_width" 8} {AXI_ADDRESS_WIDTH "addr_width" 32} {AXI_WDATA_WIDTH data_width 32} {AXI_RDATA_WIDTH data_width 32}}]
   lappend bfmTypeParamsList   mgc_axi_slave {{AXI_ID_WIDTH "id_width" 8} {AXI_ADDRESS_WIDTH "addr_width" 32} {AXI_WDATA_WIDTH data_width 32} {AXI_RDATA_WIDTH data_width 32}}
   lappend bfmTypeParamsList   altera_avalon_mm_slave_bfm {{AV_ADDRESS_W "addr_width" 30} {AV_SYMBOL_W "" 8} {AV_NUMSYMBOLS data_width 4} \
      {AV_BURSTCOUNT_W "" 8} {AV_READRESPONSE_W "" 8} {AV_WRITERESPONSE_W "" 8} {USE_READ "" 1} {USE_WRITE "" 1} {USE_ADDRESS "" 1} \
      {USE_BYTE_ENABLE "" 1} {USE_BURSTCOUNT "" 1} {USE_READ_DATA "" 1} {USE_READ_DATA_VALID "" 1} {USE_WRITE_DATA "" 1} \
      {USE_BEGIN_TRANSFER "" 0} {USE_BEGIN_BURST_TRANSFER "" 0} {USE_WAIT_REQUEST "" 1} {USE_ARBITERLOCK "" 0} {USE_LOCK "" 0} \
      {USE_DEBUGACCESS "" 0} {USE_TRANSACTIONID "" 0} {USE_WRITERESPONSE "" 0} {USE_READRESPONSE "" 0} {USE_CLKEN "" 0} \
      {AV_MAX_PENDING_READS "" 50} {AV_FIX_READ_LATENCY "" 0} {AV_BURST_LINEWRAP  "" 0} {AV_BURST_BNDR_ONLY "" 0} \
      {AV_READ_WAIT_TIME "" 0} {AV_WRITE_WAIT_TIME "" 0} {REGISTER_WAITREQUEST "" 0} {AV_REGISTERINCOMINGSIGNALS "" 0}}
   lappend bfmTypeParamsList   altera_avalon_interrupt_sink {{ASSERT_HIGH_IRQ "" 1} {AV_IRQ_W "" 32} {ASYNCHRONOUS_INTERRUPT "" 1}}
   lappend bfmTypeParamsList   altera_avalon_clock_source {{CLOCK_RATE "clock_rate" 100}}
   lappend bfmTypeParamsList   altera_avalon_reset_source {{ASSERT_HIGH_RESET "reset_polarity" 0} {INITIAL_RESET_CYCLES "" 0}}
    
   array set bfmParamsTable $bfmTypeParamsList
   return $bfmParamsTable($bfm)
}

proc expose_border {instance_name interfaces_str} {
    array set interfaces $interfaces_str
    foreach name $interfaces([ORDERED_NAMES]) {
	funset interface
	array set interface $interfaces($name)
	if { [info exists interface([HDL_ONLY])] == 0 } {
	    if { [info exists interface([NO_EXPORT])] == 0 || $interface([NO_EXPORT]) == 0} {
		set type $interface(type)
		set direction $interface(direction)
		
		# only elaborate interfaces w/ at least one non-terminated port	
		set interface_exists 0
		set port_map [list]
		funset signals
		array set signals $interface(signals)
		foreach signal_name $signals([ORDERED_NAMES]) {
		    funset signal
		    array set signal $signals($signal_name)
		    if {[is_port_terminated signal] == 0} {
			lappend port_map $signal_name $signal_name
			set interface_exists 1
		    }
		}
		
		if {$interface_exists} {
		    add_interface          $name $type $direction
		    set_interface_property $name export_of "${instance_name}.${name}"
		    
		    # Expose port names as if we are not composed
		    set_interface_property $name port_name_map $port_map
		}
	    }
	}
    }
}

######################################
# Each interface elaborated by an instance is exported
# and given the assignment to auto-export to the top of
# the top-level system.
# Note: this will not work until http://fogbugz/default.asp?36266
#       is fixed.
#
proc expose_border_to_the_top {instance_name} {
######################################
    set interfaces [get_instance_interfaces $instance_name]
    foreach interface $interfaces {
	set type      [get_instance_interface_property $instance_name $interface type]
	set direction [get_instance_interface_property $instance_name $interface direction]

	set interface_exists 0
	set port_map [list]
	set ports     [get_instance_interface_ports    $instance_name $interface]
	foreach port $ports {
	    lappend port_map $port $port
	    set interface_exists 1
	}
	if {$interface_exists} {
	    add_interface          $interface $type $direction
	    set_interface_property $interface  export_of "${instance_name}.${interface}"
	    
	    # Expose port names as if we are not composed
	    set_interface_property $name port_name_map $port_map
	    
	    # and make it float to the top
	    set_interface_assignment $interface "qsys.ui.export_name" $interface
	}
    }
}

proc is_port_terminated {var_name} {
    upvar 1 $var_name signal
    array set properties $signal(properties)

    if {[info exists properties([TERMINATION])]} {
	if {[string compare $properties([TERMINATION]) [TRUE]] == 0} {
	    return 1
	}
    }
    return 0
}

proc is_to_be_connected_to_conduit_bfm { interfaceType interfaceDirection } {
   set interfaceType      [string tolower $interfaceType]
   set interfaceDirection [string tolower $interfaceDirection]
   
   return [expr [string equal $interfaceType "conduit"]\
      || [string equal ${interfaceType}_${interfaceDirection} "reset_input"]]
}

proc do_terp {templateFile paramsArrayName} {
   upvar 1 $paramsArrayName params

   set result [ altera_terp ${templateFile} params ]
   add_fileset_file $params(output_name).sv SYSTEM_VERILOG TEXT ${result}
}

proc is_clocked_conduit {interfaceArrayName} {
   upvar 1 $interfaceArrayName interfaceInfos
   
   array set propertiesArray $interfaceInfos(properties)
   if {[info exist propertiesArray(associatedClock)]} {
      return 1
   } else {
      return 0   
   }
}

proc get_port_role {signalInfo} {
   return [lindex [lindex [lindex $signalInfo 2] 0] 0]
}

proc get_port_name {signalInfo} {
   return [lindex [lindex [lindex $signalInfo 2] 0] 1]
}

proc get_clock_rate {allInterfacesArrayName interfaceName} {
   # provide the name of array that contains all interfaces information and the interface name
   # returns clock frequency in MHz
   upvar 1 $allInterfacesArrayName allInterfacesArray
   
   clear_array interfaceInfo
   array set interfaceInfo $allInterfacesArray($interfaceName)
   
   clear_array interfaceProperty
   array set interfaceProperty $interfaceInfo(properties)

   set clockRate ""
   if {[info exist interfaceProperty(clockRate)]} {
      set clockRate $interfaceProperty(clockRate)
      set clockRate [expr $clockRate/1000000]
   }   
   return $clockRate
}

# http://wiki.tcl.tk/12276
# Note: jacl doesn't seem to support -command on this one when there is more than one element
proc lsort-indices args {
    set unsortedList [lindex $args end]
    set switches [lrange $args 0 end-1]
    set pairs {}
    set i -1
    foreach el $unsortedList {
	lappend pairs [list [incr i] $el]
    }
    set result {}
    foreach el [eval lsort $switches [list -index 1 $pairs]] {
	lappend result [lindex $el 0]
    }
    set result
}

# TODO: remove when using ctcl
proc lreverse {l} {
    set result [list]
    foreach element $l {
	set result [linsert $result 0 $element]
    }
    return $result
}

# TODO: remove when using ctcl
proc lassign {l args} {
    set length [llength $args]
    for {set i 0} {$i < $length} {incr i} {
	set ref [lindex $args $i]
	upvar 1 $ref var
	set var [lindex $l $i]
    }
}

# TODO: remove when using ctcl
proc lassign_trimmed {l args} {
    uplevel 1 "lassign \[list $l\] $args"
    foreach arg $args {
	upvar 1 $arg my_arg
	set my_arg [string trim $my_arg]
    }
}

######################################
# Alias a namespac var with an available local name.
# Useful for aliasing arrays where the namespace-qualified path contains variables.
# e.g. { namespace_alias ::a::$var_name var
#        set str $var(key)
#      }
# instead of 
#      { variable ::a::$var_name
#        set str $$var_name(key)   ;# This doesn't work!
#      }
proc namespace_alias {qual_name alias} {
######################################
    uplevel upvar 0 $qual_name $alias
}

######################################
# Converts from Hz to period in ns.
# Does not check for a frequency of 0.
#
proc frequency_to_period {freq} {
######################################
    return [expr {1.0 / $freq * 1000000000}]
}

################################################################
# Adds a clock to the sdc file if the frequency is valid. 
#
proc add_clock_constraint_if_valid {freq pin_pattern} {
################################################################
    if {$freq != 0} {
	fpga_interfaces::add_raw_sdc_constraint [format [SDC_CREATE_CLOCK] [frequency_to_period $freq] $pin_pattern]
    }
}

################################################################
# Returns 1 if peripheral is indexed
#
proc is_peripheral_one_of_many {peripheral_name} {
################################################################
    set length [string length $peripheral_name]
    set last_char [string index $peripheral_name [expr {$length - 1}]]
    return [string is integer $last_char]
}

################################################################
# Returns the peripheral index
#
proc get_peripheral_index {peripheral_name} {
################################################################
    set index_string ""
    set length [string length $peripheral_name]
    set last_char_index [expr {$length - 1}]
    for {set i $last_char_index} {$i >= 0} {incr i -1} {
	set char [string index $peripheral_name $i]
	if {[string is integer $char]} {
	    set index_string "${char}${index_string}"
	} else {
	    break
	}
    }
    return $index_string
}

#####################################################################
#
# Returns true if peripheral is available to FPGA.
# Parameters: * peripheral: name of a VALID peripheral
#
proc peripheral_connects_to_fpga {peripheral} {
#####################################################################
    if {[string compare -nocase $peripheral "trace"] == 0} {
	return 0
    }
    return 1
}

################################################################
# Returns the generic atom name for a given HPS peripheral.
#
proc hps_io_peripheral_to_generic_atom_name {peripheral} {
################################################################
    array set hps_io_peri_to_atom {
	EMAC0  hps_peripheral_emac
	EMAC1  hps_peripheral_emac
	NAND   hps_peripheral_nand
	QSPI   hps_peripheral_qspi
	SDIO   hps_peripheral_sdmmc
	USB0   hps_peripheral_usb
	USB1   hps_peripheral_usb
	SPIM0  hps_peripheral_spi_master
	SPIM1  hps_peripheral_spi_master
	SPIS0  hps_peripheral_spi_slave
	SPIS1  hps_peripheral_spi_slave
	UART0  hps_peripheral_uart
	UART1  hps_peripheral_uart
	I2C0   hps_peripheral_i2c
	I2C1   hps_peripheral_i2c
	I2C2   hps_peripheral_i2c
	I2C3   hps_peripheral_i2c
	CAN0   hps_peripheral_can
	CAN1   hps_peripheral_can
	TRACE  hps_peripheral_tpiu_trace
	GPIO   hps_peripheral_gpio
	LOANIO hps_interface_loan_io
    }
    set generic_atom_name $hps_io_peri_to_atom($peripheral)
    return $generic_atom_name
}


# ----------------------------------------------------------------
#
namespace eval ::f2sdram {
#
# Description: class for F2SDRAM routines.
#
# ----------------------------------------------------------------


    proc init_registers {} {
	uplevel 1 {
	    # map of registers to the number of entries
	    set registers_map {
		width_reg        6
		cmd_to_write_reg 6
		cmd_to_read_reg  6
		read_to_cmd_reg  4
		write_to_cmd_reg 4
		direction_reg    6
		fabric_reg       6
		cmd_bitmap       1
		read_bitmap      1
		write_bitmap     1
	    }

	    set registers [list]
	    foreach {register len} $registers_map {
		set $register [list]
		for {set i 0} {$i < $len} {incr i} {
		    lappend $register 0
		}
		lappend registers $register
	    }
	}
    }
    
    proc plumb_registers {registers_var} {
	uplevel 1 "upvar 1 $registers_var registers"
	uplevel 1 {
	    upvar 1 [lindex $registers 0] width_reg 
	    upvar 1 [lindex $registers 1] cmd_to_write_reg
	    upvar 1 [lindex $registers 2] cmd_to_read_reg
	    upvar 1 [lindex $registers 3] read_to_cmd_reg
	    upvar 1 [lindex $registers 4] write_to_cmd_reg
	    upvar 1 [lindex $registers 5] direction_reg
	    upvar 1 [lindex $registers 6] fabric_reg
	    upvar 1 [lindex $registers 7] cmd_bitmap
	    upvar 1 [lindex $registers 8] read_bitmap
	    upvar 1 [lindex $registers 9] write_bitmap
	}
    }

    # TODO: move into another namespace later!
    # Adds an interface which has the sole purpose to render RTL for signals but not expose them in Qsys
    # Parameters: shadow_name:    unique interface name
    #             instance_name:  name of the instance the signals come from
    #             shadow_signals: list of implied 4-element tuples that contain
    #               (exported signal name, signal name on atom, width of signal, direction of signal)
    proc add_shadow_interface {shadow_name instance_name shadow_signals} {
	fpga_interfaces::add_interface       $shadow_name conduit slave
	fpga_interfaces::set_interface_meta_property $shadow_name [HDL_ONLY] 1
	foreach {export_signal_name atom_signal_name width direction} $shadow_signals {
	    fpga_interfaces::add_interface_port  $shadow_name $export_signal_name $export_signal_name $direction $width $instance_name $atom_signal_name
	}
    }
    
    # TODO: remove when Qsys supports Quartus Tcl for hw.tcl
    proc lset {list_var index value} {
	upvar 1 $list_var thelist
	set thelist [lreplace $thelist $index $index $value]
    }


    # ----------------------------------------------------------------
    #
    proc add_port {registers_var index type_id width instance_name {sim_is_synth 0} {bon_out_sig 0}} {
    #
    # Description: Adds a command port.
    #
    # Parameters:  registers_var
    #                list of F2SDRAM registers
    #              type_id
    #                0 if axi, 1 if avalon-mm bidir,
    #                2 if avalon-mm write only, 3 if avalon-mm read-only
    #              width
    #                data width
    #              instance_name
    #                instance name of the F2SDRAM atom
    #              bon_out_sig 
    #                1 if BONDING_OUT_SIGNAL Enabled, 0 if Disable 
    #
    # Returns: nothing
    # ----------------------------------------------------------------
	plumb_registers $registers_var
	
	set name_prefix "f2h_sdram${index}"
	
	set data_name "${name_prefix}_data"
	
	# Port name prefix
	set z "f2h_sdram${index}_"

	set raw_assign_style ""
	if $sim_is_synth {
	    set raw_assign_style "SYNTHESIS"
	}

	set atom_clk_wires [list] ;# collection of wires that connect to the current clock

	# AXI
	if {$type_id == 0} {
	    set cmd_ports    [add_cmd_port cmd_bitmap 1]
	    if {[llength $cmd_ports] == 0} {
		send_message error "No command ports available to allocate AXI Interface ${name_prefix}"
		return
	    }
	    set read_ports  [add_data_port read_bitmap $width]
	    if {[llength $read_ports] == 0} {
		send_message error "No read ports available to allocate AXI Interface ${name_prefix}"
		return
	    }
	    set write_ports [add_data_port write_bitmap $width]
	    if {[llength $write_ports] == 0} {
		send_message error "No write ports available to allocate AXI Interface ${name_prefix}"
		return
	    }

	    update_registers registers $cmd_ports $read_ports $write_ports $width 1
	    
	    fpga_interfaces::add_interface                      $data_name axi slave
	    if $sim_is_synth {
		fpga_interfaces::set_interface_simulation_rendering $data_name SYNTHESIS
	    }
	    set strb_width [expr $width / 8]

	    set cmd_signal "cmd_data_[lindex $cmd_ports 0]"
	    set cmd_signal_b "cmd_data_[lindex $cmd_ports 1]"
	    
	    fpga_interfaces::set_instance_port_termination $instance_name $cmd_signal_b 60 0
	    foreach write_port $write_ports {
		set signal_name "wr_data_${write_port}"
		fpga_interfaces::set_instance_port_termination $instance_name $signal_name 90 0
	    }
	    
	    set termination_ports [list]
	    
	    # read command port
	    lappend termination_ports 0:0 1 ;# ARVALID
	    lappend termination_ports 1:1 0 ;# AWVALID
	    # TODO: axi4? if so, don't terminate priority signal
	    lappend termination_ports 2:2 0 ;# PRIORITY
	    fpga_interfaces::add_interface_port $data_name "${z}ARADDR"   araddr   Input  32
	    fpga_interfaces::set_port_fragments $data_name "${z}ARADDR"   "${instance_name}:${cmd_signal}(34:3)"
	    # TODO: if axi4, modify this width
	    fpga_interfaces::add_interface_port $data_name "${z}ARLEN"    arlen    Input  4
	    fpga_interfaces::set_port_fragments $data_name "${z}ARLEN"    "${instance_name}:${cmd_signal}(38:35)"
	    lappend termination_ports 42:39 0 ;# ARLEN padding
	    fpga_interfaces::add_interface_port $data_name "${z}ARID"     arid     Input  8
	    fpga_interfaces::set_port_fragments $data_name "${z}ARID"     "${instance_name}:${cmd_signal}(50:43)"
	    fpga_interfaces::add_interface_port $data_name "${z}ARSIZE"   arsize   Input  3
	    fpga_interfaces::set_port_fragments $data_name "${z}ARSIZE"   "${instance_name}:${cmd_signal}(53:51)"
	    fpga_interfaces::add_interface_port $data_name "${z}ARBURST"  arburst  Input  2
	    fpga_interfaces::set_port_fragments $data_name "${z}ARBURST"  "${instance_name}:${cmd_signal}(55:54)"
	    fpga_interfaces::add_interface_port $data_name "${z}ARLOCK"   arlock Input  2
	    fpga_interfaces::set_port_fragments $data_name "${z}ARLOCK"   "${instance_name}:${cmd_signal}(57:56)"
	    fpga_interfaces::add_interface_port $data_name "${z}ARPROT"   arprot Input  3
	    fpga_interfaces::set_port_fragments $data_name "${z}ARPROT"   0 "${instance_name}:${cmd_signal}(59:58)"
	    eval fpga_interfaces::set_instance_port_termination $instance_name $cmd_signal 60 0 $termination_ports

	    fpga_interfaces::add_interface_port $data_name "${z}ARVALID"  arvalid  Input  1
	    fpga_interfaces::set_port_fragments $data_name "${z}ARVALID"  "${instance_name}:cmd_valid_[lindex $cmd_ports 0](0:0)"

	    # arcache is a dead port not represented in the hard F2SDRAM IP
	    fpga_interfaces::add_interface_port $data_name "${z}ARCACHE"  arcache  Input  4
	    fpga_interfaces::set_port_fragments $data_name "${z}ARCACHE"  0 0 0 0
	    
	    set termination_ports [list]
	    # write command port
	    lappend termination_ports 0:0 0 ;# ARVALID
	    lappend termination_ports 1:1 1 ;# AWVALID
	    # TODO: axi4? if so, don't terminate priority signal
	    lappend termination_ports 2:2 0 ;# PRIORITY
	    fpga_interfaces::add_interface_port $data_name "${z}AWADDR"   awaddr   Input  32
	    fpga_interfaces::set_port_fragments $data_name "${z}AWADDR"   "${instance_name}:${cmd_signal_b}(34:3)"
	    # TODO: if axi4, modify width
	    fpga_interfaces::add_interface_port $data_name "${z}AWLEN"    awlen    Input  4
	    fpga_interfaces::set_port_fragments $data_name "${z}AWLEN"    "${instance_name}:${cmd_signal_b}(38:35)"
	    lappend termination_ports 42:39 0 ;# AWLEN padding
	    fpga_interfaces::add_interface_port $data_name "${z}AWID"     awid     Input  8
	    fpga_interfaces::set_port_fragments $data_name "${z}AWID"     "${instance_name}:${cmd_signal_b}(50:43)"
	    fpga_interfaces::add_interface_port $data_name "${z}AWSIZE"   awsize   Input  3
	    fpga_interfaces::set_port_fragments $data_name "${z}AWSIZE"   "${instance_name}:${cmd_signal_b}(53:51)"
	    fpga_interfaces::add_interface_port $data_name "${z}AWBURST"  awburst  Input  2
	    fpga_interfaces::set_port_fragments $data_name "${z}AWBURST"  "${instance_name}:${cmd_signal_b}(55:54)"
	    fpga_interfaces::add_interface_port $data_name "${z}AWLOCK"   awlock Input  2
	    fpga_interfaces::set_port_fragments $data_name "${z}AWLOCK"   "${instance_name}:${cmd_signal_b}(57:56)"
	    fpga_interfaces::add_interface_port $data_name "${z}AWPROT"   awprot Input  3
	    fpga_interfaces::set_port_fragments $data_name "${z}AWPROT"   0 "${instance_name}:${cmd_signal_b}(59:58)"
	    eval fpga_interfaces::set_instance_port_termination $instance_name $cmd_signal_b 60 0 $termination_ports

	    fpga_interfaces::add_interface_port $data_name "${z}AWVALID"  awvalid  Input  1
	    fpga_interfaces::set_port_fragments $data_name "${z}AWVALID"  "${instance_name}:cmd_valid_[lindex $cmd_ports 1](0:0)"

	    # awcache is a dead port not represented in the hard F2SDRAM IP
	    fpga_interfaces::add_interface_port $data_name "${z}AWCACHE"  awcache  Input  4
	    fpga_interfaces::set_port_fragments $data_name "${z}AWCACHE"  0 0 0 0
	    
	    # write acknowledge
	    fpga_interfaces::add_interface_port $data_name "${z}BRESP"   bresp Output 2
	    fpga_interfaces::set_port_fragments $data_name "${z}BRESP"   "${instance_name}:wrack_data_[lindex $cmd_ports 1](1:0)"
	    fpga_interfaces::add_interface_port $data_name "${z}BID"     bid   Output 8
	    fpga_interfaces::set_port_fragments $data_name "${z}BID"     "${instance_name}:wrack_data_[lindex $cmd_ports 1](9:2)"
	    fpga_interfaces::add_interface_port $data_name "${z}BVALID"  bvalid Output 1
	    fpga_interfaces::set_port_fragments $data_name "${z}BVALID"  "${instance_name}:wrack_valid_[lindex $cmd_ports 1](0:0)"
	    fpga_interfaces::add_interface_port $data_name "${z}BREADY"  bready   Input 1
	    fpga_interfaces::set_port_fragments $data_name "${z}BREADY"  "${instance_name}:wrack_ready_[lindex $cmd_ports 1](0:0)"
	    fpga_interfaces::add_interface_port $data_name "${z}ARREADY" arready Output 1
	    fpga_interfaces::set_port_fragments $data_name "${z}ARREADY" "${instance_name}:cmd_ready_[lindex $cmd_ports 0](0:0)"
	    fpga_interfaces::add_interface_port $data_name "${z}AWREADY" awready Output 1
	    fpga_interfaces::set_port_fragments $data_name "${z}AWREADY" "${instance_name}:cmd_ready_[lindex $cmd_ports 1](0:0)"
	    

	    # read ports
	    fpga_interfaces::add_interface_port $data_name "${z}RREADY" rready  Input  1
	    set rready_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $rready_wire SYNTHESIS
	    }
	    fpga_interfaces::set_port_fragments $data_name "${z}RREADY"  [fpga_interfaces::wire_tofragment $rready_wire]
	    set read_port ""
	    if {$width <= 32} {
		set read_port_number [lindex $read_ports 0]
		set read_port "rd_data_${read_port_number}"
		fpga_interfaces::add_interface_port $data_name "${z}RDATA"  rdata  Output  $width
		set upper [expr $width - 1]
		fpga_interfaces::set_port_fragments $data_name "${z}RDATA"  "${instance_name}:${read_port}($upper:0)"

		set port_wire [fpga_interfaces::allocate_wire]
		if $sim_is_synth {
		    fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		}
		fpga_interfaces::hookup_wires $port_wire $rready_wire
		fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_ready_${read_port_number}(0:0)"
		
		# clock
		set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_clk_${read_port_number}(0:0)"
		lappend atom_clk_wires $port_wire
	    } else {
		fpga_interfaces::add_interface_port $data_name "${z}RDATA"  rdata  Output  $width
		set fragment_list ""
		foreach read_port_number $read_ports {
		    set read_port "rd_data_${read_port_number}"
		    set fragment_list "${instance_name}:${read_port}(63:0) ${fragment_list}"
		    set port_wire [fpga_interfaces::allocate_wire]
		    if $sim_is_synth {
			fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		    }
		    fpga_interfaces::hookup_wires $port_wire $rready_wire
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_ready_${read_port_number}(0:0)"

		    # clock
		    set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_clk_${read_port_number}(0:0)"
		    lappend atom_clk_wires $port_wire
		}
		eval fpga_interfaces::set_port_fragments $data_name "${z}RDATA" $fragment_list
	    }
	    # read_port should now be the highest read port
	    fpga_interfaces::add_interface_port $data_name "${z}RRESP"  rresp  Output  2
	    fpga_interfaces::set_port_fragments $data_name "${z}RRESP"  "${instance_name}:${read_port}(65:64)"
	    fpga_interfaces::add_interface_port $data_name "${z}RLAST"  rlast  Output  1
	    fpga_interfaces::set_port_fragments $data_name "${z}RLAST"  "${instance_name}:${read_port}(66:66)"
	    fpga_interfaces::add_interface_port $data_name "${z}RID"    rid    Output  8
	    fpga_interfaces::set_port_fragments $data_name "${z}RID"    "${instance_name}:${read_port}(74:67)"
	    fpga_interfaces::add_interface_port $data_name "${z}RVALID" rvalid Output  1 ;# first port, not last
	    fpga_interfaces::set_port_fragments $data_name "${z}RVALID" "${instance_name}:rd_valid_[lindex $read_ports 0](0:0)"

	    # write ports
	    fpga_interfaces::add_interface_port $data_name "${z}WLAST"  wlast  Input  1
	    set wlast_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $wlast_wire SYNTHESIS
	    }
	    fpga_interfaces::set_port_fragments $data_name "${z}WLAST"  [fpga_interfaces::wire_tofragment $wlast_wire]
	    fpga_interfaces::add_interface_port $data_name "${z}WVALID" wvalid  Input  1
	    set wvalid_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $wvalid_wire SYNTHESIS
	    }
	    fpga_interfaces::set_port_fragments $data_name "${z}WVALID"  [fpga_interfaces::wire_tofragment $wvalid_wire]
	    
	    set write_port ""
	    if {$width <= 32} {
		set write_port_number [lindex $write_ports 0]
		set write_port "wr_data_${write_port_number}"
		fpga_interfaces::add_interface_port $data_name "${z}WDATA"  wdata  Input  $width
		set upper [expr $width - 1]
		fpga_interfaces::set_port_fragments $data_name "${z}WDATA"  "${instance_name}:${write_port}($upper:0)"
		
		set strb_width [expr $width / 8]
		fpga_interfaces::add_interface_port $data_name "${z}WSTRB"  wstrb  Input  $strb_width
		set upper [expr 64 + $strb_width - 1]
		fpga_interfaces::set_port_fragments $data_name "${z}WSTRB"  "${instance_name}:${write_port}($upper:64)"
		fpga_interfaces::set_instance_port_termination $instance_name $write_port 90 0
		
		set port_wire [fpga_interfaces::allocate_wire]
		if $sim_is_synth {
		    fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		}
		fpga_interfaces::hookup_wires $port_wire $wlast_wire
		fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:${write_port}(72:72)"
		set port_wire [fpga_interfaces::allocate_wire]
		if $sim_is_synth {
		    fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		}
		fpga_interfaces::hookup_wires $port_wire $wvalid_wire
		fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_valid_${write_port_number}(0:0)"

		# clock
		set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_clk_${write_port_number}(0:0)"
		lappend atom_clk_wires $port_wire
	    } else {
		set strb_width [expr $width / 8]
		fpga_interfaces::add_interface_port $data_name "${z}WDATA"  wdata  Input  $width
		fpga_interfaces::add_interface_port $data_name "${z}WSTRB"  wstrb  Input  $strb_width
		set wdata_fragment_list ""
		set wstrb_fragment_list ""
		foreach write_port_number $write_ports {
		    set write_port "wr_data_${write_port_number}"
		    set wdata_fragment_list "${instance_name}:${write_port}(63:0) ${wdata_fragment_list}"
		    set wstrb_fragment_list "${instance_name}:${write_port}(71:64) ${wstrb_fragment_list}"
		    fpga_interfaces::set_instance_port_termination $instance_name $write_port 90 0
		    
		    set port_wire [fpga_interfaces::allocate_wire]
		    if $sim_is_synth {
			fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		    }
		    fpga_interfaces::hookup_wires $port_wire $wlast_wire
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:${write_port}(72:72)"
		    set port_wire [fpga_interfaces::allocate_wire]
		    if $sim_is_synth {
			fpga_interfaces::set_wire_simulation_rendering $port_wire SYNTHESIS
		    }
		    fpga_interfaces::hookup_wires $port_wire $wvalid_wire
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_valid_${write_port_number}(0:0)"

		    # clock
		    set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_clk_${write_port_number}(0:0)"
		    lappend atom_clk_wires $port_wire
		}
		eval fpga_interfaces::set_port_fragments $data_name "${z}WDATA"  $wdata_fragment_list
		eval fpga_interfaces::set_port_fragments $data_name "${z}WSTRB"  $wstrb_fragment_list
	    }
	    # write_port should now be the highest read port
	    fpga_interfaces::add_interface_port $data_name "${z}WREADY"  wready  Output  1 ;# first, not last
	    fpga_interfaces::set_port_fragments $data_name "${z}WREADY"  "${instance_name}:wr_ready_[lindex $write_ports 0](0:0)"
	    fpga_interfaces::add_interface_port $data_name "${z}WID"  wid  Input 8
	    fpga_interfaces::set_port_fragments $data_name "${z}WID"  0
	    
	    fpga_interfaces::set_interface_meta_property $data_name data_width $width
	    fpga_interfaces::set_interface_meta_property $data_name address_width 32
	    fpga_interfaces::set_interface_meta_property $data_name bfm_type   f2sdram

	    fpga_interfaces::set_interface_property $data_name  maximumOutstandingReads 14 
	    fpga_interfaces::set_interface_property $data_name  maximumOutstandingWrites 14 
	    fpga_interfaces::set_interface_property $data_name  maximumOutstandingTransactions 14 

	    fpga_interfaces::set_interface_property $data_name  readAcceptanceCapability 14 
	    fpga_interfaces::set_interface_property $data_name  writeAcceptanceCapability 14 
	    fpga_interfaces::set_interface_property $data_name  combinedAcceptanceCapability  14 
		
	    
	} else { # Avalon-MM
	    set cmd_ports   [add_cmd_port cmd_bitmap 0]
	    if {[llength $cmd_ports] == 0} {
		send_message error "No command ports available to allocate Avalon-MM Interface ${name_prefix}"
		return
	    }
	    if {$type_id == 1 || $type_id == 3} {
		set read_ports  [add_data_port read_bitmap $width]
		if {[llength $read_ports] == 0} {
		    send_message error "No read ports available to allocate Avalon-MM Interface ${name_prefix}"
		    return
		}
	    } else {
		set read_ports [list]
	    }
	    if {$type_id == 1 || $type_id == 2} {
		set write_ports [add_data_port write_bitmap $width]
		if {[llength $write_ports] == 0} {
		    send_message error "No write ports available to allocate Avalon-MM Interface ${name_prefix}"
		    return
		}
	    } else {
		set write_ports [list]
	    }

	    update_registers registers $cmd_ports $read_ports $write_ports $width 0
	    
	    fpga_interfaces::add_interface                      $data_name avalon slave
	    if $sim_is_synth {
		fpga_interfaces::set_interface_simulation_rendering $data_name SYNTHESIS
	    }
	    set strb_width [expr $width / 8]

	    set cmd_signal "cmd_data_[lindex $cmd_ports 0]"

	    
	    # command port
	    set symbols_log_2 [expr { int(ceil( log($width/8)/log(2) )) }]
	    set address_width [expr {32 - $symbols_log_2}]
	    fpga_interfaces::add_interface_port $data_name "${z}ADDRESS"  address  Input  $address_width
	    set address_range_high [expr {1 + $address_width}]
	    fpga_interfaces::set_port_fragments $data_name "${z}ADDRESS"  "${instance_name}:${cmd_signal}(${address_range_high}:2)"
	    fpga_interfaces::add_interface_port $data_name "${z}BURSTCOUNT"  burstcount  Input 8
	    fpga_interfaces::set_port_fragments $data_name "${z}BURSTCOUNT"  "${instance_name}:${cmd_signal}(41:34)"

	    set waitrequest_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $waitrequest_wire SYNTHESIS
	    }
	    set inverted_waitrequest_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $inverted_waitrequest_wire SYNTHESIS
	    }
	    fpga_interfaces::add_interface_port $data_name "${z}WAITREQUEST"  waitrequest  Output 1
	    fpga_interfaces::set_port_fragments $data_name "${z}WAITREQUEST"  [fpga_interfaces::wire_tofragment $waitrequest_wire] ;# waitrequest = waitrequest_wire
	    fpga_interfaces::set_wire_port_fragments $inverted_waitrequest_wire driven_by "${instance_name}:cmd_ready_[lindex $cmd_ports 0](0:0)" ;# inverted_waitrequest_wire = cmd_ready_x[0]
	    fpga_interfaces::add_raw_assign [fpga_interfaces::wire_tortl $waitrequest_wire] "~[fpga_interfaces::wire_tortl $inverted_waitrequest_wire]" $raw_assign_style;# waitrequest_wire = ~inverted_waitrequest_wire
	    fpga_interfaces::set_instance_port_termination $instance_name $cmd_signal 60 0
	    
	    # TODO: cmd_id, valid, ready?
	    set valid_wire_drivers [list]

	    # read ports
	    if {[llength $read_ports] > 0} {
		set read_port ""
		if {$width <= 32} {
		    set read_port_number [lindex $read_ports 0]
		    set read_port "rd_data_${read_port_number}"
		    fpga_interfaces::add_interface_port $data_name "${z}READDATA"  readdata  Output  $width
		    set upper [expr $width - 1]
		    fpga_interfaces::set_port_fragments $data_name "${z}READDATA"  "${instance_name}:${read_port}($upper:0)"

		    fpga_interfaces::set_instance_port_termination $instance_name rd_ready_[lindex $read_ports 0] 1 1 0:0 1

		    # clock
		    set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_clk_${read_port_number}(0:0)"
		    lappend atom_clk_wires $port_wire
		} else {
		    fpga_interfaces::add_interface_port $data_name "${z}READDATA"  readdata  Output  $width
		    set fragment_list ""
		    foreach read_port_number $read_ports {
			set read_port "rd_data_${read_port_number}"
			set fragment_list "${instance_name}:${read_port}(63:0) ${fragment_list}"

			fpga_interfaces::set_instance_port_termination $instance_name rd_ready_${read_port_number} 1 1 0:0 1

			# clock
			set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
			fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:rd_clk_${read_port_number}(0:0)"
			lappend atom_clk_wires $port_wire
		    }
		    eval fpga_interfaces::set_port_fragments  $data_name "${z}READDATA"  $fragment_list
		}
		# read_port should now be the highest read port
		fpga_interfaces::add_interface_port $data_name "${z}READDATAVALID"  readdatavalid  Output  1
		set rvalid_signal "rd_valid_${read_port_number}"
		fpga_interfaces::set_port_fragments $data_name "${z}READDATAVALID"  "${instance_name}:${rvalid_signal}(0:0)"
		fpga_interfaces::set_interface_property $data_name maximumPendingReadTransactions 14 ;# 5 per port, 8 shared, 1 in flight

		set read_wire [fpga_interfaces::allocate_wire]
		if $sim_is_synth {		
		    fpga_interfaces::set_wire_simulation_rendering $read_wire SYNTHESIS
		}
		fpga_interfaces::add_interface_port $data_name "${z}READ"  read Input 1
		fpga_interfaces::set_port_fragments $data_name "${z}READ"  [fpga_interfaces::wire_tofragment $read_wire]
		fpga_interfaces::set_wire_port_fragments $read_wire drives "${instance_name}:${cmd_signal}(0:0)"
		lappend valid_wire_drivers [fpga_interfaces::wire_tortl $read_wire]
	    }

	    # write ports
	    if {[llength $write_ports] > 0} {
		fpga_interfaces::set_instance_port_termination $instance_name wrack_ready_[lindex $cmd_ports 0] 1 1 0:0 1

		set read_port ""
		set be_width [expr $width / 8]
		if {$width <= 32} {
		    set write_port_number [lindex $write_ports 0]
		    set write_port "wr_data_${write_port_number}"
		    fpga_interfaces::add_interface_port $data_name "${z}WRITEDATA"  writedata  Input  $width
		    set upper [expr $width - 1]
		    fpga_interfaces::set_port_fragments $data_name "${z}WRITEDATA"  "${instance_name}:${write_port}($upper:0)"
		    
		    fpga_interfaces::add_interface_port $data_name "${z}BYTEENABLE" byteenable  Input  $be_width
		    set upper [expr 80 + $be_width - 1]
		    fpga_interfaces::set_port_fragments $data_name "${z}BYTEENABLE" "${instance_name}:${write_port}($upper:80)"
		    fpga_interfaces::set_instance_port_termination $instance_name $write_port 90 0

		    # clock
		    set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
		    fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_clk_${write_port_number}(0:0)"
		    lappend atom_clk_wires $port_wire
		} else {

		    fpga_interfaces::add_interface_port $data_name "${z}WRITEDATA"  writedata  Input  $width
		    fpga_interfaces::add_interface_port $data_name "${z}BYTEENABLE"  byteenable Input  $be_width
		    set wd_fragment_list ""
		    set be_fragment_list ""
		    foreach write_port_number $write_ports {
			set write_port "wr_data_${write_port_number}"
			set wd_fragment_list "${instance_name}:${write_port}(63:0) ${wd_fragment_list}"
			set be_fragment_list "${instance_name}:${write_port}(87:80) ${be_fragment_list}"
			fpga_interfaces::set_instance_port_termination $instance_name $write_port 90 0

			# clock
			set port_wire [fpga_interfaces::allocate_wire] ;# set wire simulation rendering later
			fpga_interfaces::set_wire_port_fragments $port_wire drives "${instance_name}:wr_clk_${write_port_number}(0:0)"
			lappend atom_clk_wires $port_wire
		    }
		    eval fpga_interfaces::set_port_fragments $data_name "${z}WRITEDATA"  $wd_fragment_list
		    eval fpga_interfaces::set_port_fragments $data_name "${z}BYTEENABLE" $be_fragment_list
		}
		# write_port is now highest write port
		set write_wire [fpga_interfaces::allocate_wire]
		if $sim_is_synth {
		    fpga_interfaces::set_wire_simulation_rendering $write_wire SYNTHESIS
		}
		fpga_interfaces::add_interface_port $data_name "${z}WRITE" write Input 1
		fpga_interfaces::set_port_fragments $data_name "${z}WRITE" [fpga_interfaces::wire_tofragment $write_wire]
		fpga_interfaces::set_wire_port_fragments $write_wire drives "${instance_name}:${cmd_signal}(1:1)"
		lappend valid_wire_drivers [fpga_interfaces::wire_tortl $write_wire]
	    }

	    set valid_wire [fpga_interfaces::allocate_wire]
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $valid_wire SYNTHESIS
	    }
	    # TODO: remove this line when this OR logic has been tested
	    fpga_interfaces::add_raw_assign [fpga_interfaces::wire_tortl $valid_wire] [join $valid_wire_drivers "|"] $raw_assign_style
	    fpga_interfaces::set_wire_port_fragments $valid_wire drives "${instance_name}:cmd_valid_[lindex $cmd_ports 0](0:0)"
	    
	    fpga_interfaces::set_interface_meta_property $data_name data_width $width
	    fpga_interfaces::set_interface_meta_property $data_name address_width $address_width

	}

	# Add bonding_out signals
	if $bon_out_sig {
	    fpga_interfaces::add_interface	f2h_sdram_bon_out conduit Output 	
 	    fpga_interfaces::add_interface_port f2h_sdram_bon_out  f2h_sdram_BONOUT_1  f2h_sdram_BONOUT_1    Output  4  	${instance_name}	bonding_out_1
   	    fpga_interfaces::add_interface_port f2h_sdram_bon_out  f2h_sdram_BONOUT_2  f2h_sdram_BONOUT_2    Output  4  	${instance_name}	bonding_out_2 	
#	    fpga_interfaces::set_interface_property f2h_sdram_bon_out associatedClock f2h_sdram_bon_out
    	}

	set clock_name "${name_prefix}_clock"
	set frequency [get_parameter_value [string toupper $clock_name]_FREQ]
	fpga_interfaces::add_interface                      $clock_name clock input
	if $sim_is_synth {
	    fpga_interfaces::set_interface_simulation_rendering $clock_name SYNTHESIS
	}
	fpga_interfaces::add_interface_port                 $clock_name "${z}clk" clk Input 1
	set clk_wire [fpga_interfaces::allocate_wire]
	if $sim_is_synth {
	    fpga_interfaces::set_wire_simulation_rendering $clk_wire SYNTHESIS
	}
	fpga_interfaces::set_port_fragments $clock_name "${z}clk"  [fpga_interfaces::wire_tofragment $clk_wire]

	foreach cmd_port $cmd_ports { ;# Source each cmd port clock with the interface clock
	    set atom_cmd_clk_wire [fpga_interfaces::allocate_wire]
	    set atom_cmd_clk "cmd_port_clk_${cmd_port}"
	    fpga_interfaces::set_wire_port_fragments $atom_cmd_clk_wire drives "${instance_name}:${atom_cmd_clk}(0:0)"
	    lappend atom_clk_wires $atom_cmd_clk_wire
	}
	foreach atom_clk_wire $atom_clk_wires {
	    if $sim_is_synth {
		fpga_interfaces::set_wire_simulation_rendering $atom_clk_wire SYNTHESIS
	    }
	    fpga_interfaces::hookup_wires $atom_clk_wire $clk_wire
	}

	
	set reset_name h2f_reset
	fpga_interfaces::set_interface_property $data_name associatedClock $clock_name
	fpga_interfaces::set_interface_property $data_name associatedReset $reset_name
    }
    
    proc render_registers {registers_var instance_name} {
	plumb_registers $registers_var

	render_register $instance_name "cfg_port_width"      $width_reg        2 12
	render_register $instance_name "cfg_cport_wfifo_map" $cmd_to_write_reg 3 18
	render_register $instance_name "cfg_cport_rfifo_map" $cmd_to_read_reg  3 18
	render_register $instance_name "cfg_rfifo_cport_map" $read_to_cmd_reg  4 16
	render_register $instance_name "cfg_wfifo_cport_map" $write_to_cmd_reg 4 16
	render_register $instance_name "cfg_cport_type"      $direction_reg    2 12
	render_register $instance_name "cfg_axi_mm_select"   $fabric_reg       1  6
    }
    
    proc render_register {instance_name port_name register bits_per_value width} {
	set packed [pack_register $register $bits_per_value]
	set range "[expr {$width - 1}]:0"
	fpga_interfaces::set_instance_port_termination ${instance_name} ${port_name} $width 0   $range $packed
    }

    # ----------------------------------------------------------------
    #
    proc add_cmd_port {cmd_bitmap_var_name is_axi} {
    #
    # Description: Adds a command port.
    #
    # Parameters:  cmd_bitmap_var_name
    #                variable name for the port bitmap
    #              is_axi
    #                1 if port is axi, 0 if avalon-mm
    #
    # Returns: a list of indexes of ports that were added. Throws an
    #          error if there is insufficient room for the port.
    # ----------------------------------------------------------------
	upvar 1 $cmd_bitmap_var_name cmd_bitmap
	
	set MAX_CMD_PORTS 6
	
	set result [list]
	set mask 0
	if {$is_axi} {
	    set no_match 1
	    for {set i 0} {$i < ($MAX_CMD_PORTS / 2)} {incr i} {
		set mask [expr 3 << ($i * 2)]
		if {($cmd_bitmap & $mask) == 0} {
		    set no_match 0
		    break
		}
	    }
	    if $no_match {
		return {}
	    }
	    set cmd_bitmap [expr $cmd_bitmap | $mask]
	    set result [list [expr $i * 2] [expr $i * 2 + 1]]
	} else {
	    set no_match 1
	    for {set i 0} {$i < $MAX_CMD_PORTS} {incr i} {
		set mask [expr 1 << $i]
		if {($cmd_bitmap & $mask) == 0} {
		    set no_match 0
		    break
		}
	    }
	    if $no_match {
		return {}
	    }
	    set cmd_bitmap [expr $cmd_bitmap | $mask]
	    set result [list $i]
	}
	return $result
    }

    # ----------------------------------------------------------------
    #
    proc add_data_port {data_bitmap_var_name width} {
    #
    # Description: Adds a data (read or write) port.
    #
    # Parameters:  data_bitmap_var_name
    #                variable name for the port bitmap
    #              width
    #                width of the data port as an integer
    #
    # Returns: a list of indexes of ports that were added. Throws an
    #          error if there is insufficient room for the port.
    # ----------------------------------------------------------------
	upvar 1 $data_bitmap_var_name data_bitmap
	
	set MAX_DATA_PORTS 4
	
	set num_ports 1
	set mask_base 1
	if {$width == 128} {
	    set num_ports 2
	    set mask_base 3
	} elseif {$width == 256} {
	    set num_ports 4
	    set mask_base 15
	}
	set no_match 1
	for {set startport 0} {$startport + $num_ports <= $MAX_DATA_PORTS} {incr startport $num_ports} {
	    set mask [expr $mask_base << $startport]
	    if {($data_bitmap & $mask) == 0} {
		set no_match 0
		break
	    }
	}
	if $no_match {
	    return {}
	}

	set data_bitmap [expr $data_bitmap | $mask]
	set result [list]
	for {set port $startport} {$port < ($startport + $num_ports)} {incr port} {
	    lappend result $port
	}
	return $result
    }

    # ----------------------------------------------------------------
    #
    proc update_registers {registers_var cmd_ports read_ports
			   write_ports width is_axi} {
    #
    # Description: Updates the F2SDRAM registers for an added interface.
    #
    # Parameters:  registers_var
    #                variable name for the register list
    #              cmd_ports
    #                list of command port indexes
    #              read_ports
    #                list of read port indexes
    #              write_ports
    #                list of write port indexes
    #              width
    #                data width of the interface
    #              is_axi
    #                1 if interface is axi, 0 if avalon-mm
    #
    # Returns: nothing
    # ----------------------------------------------------------------
	plumb_registers $registers_var
	
	set WRITE 1
	set READ  2
	
	# get width register value
	set reg_value_for_width 0
	if {$width == 64} {
	    set reg_value_for_width 1
	} elseif {$width == 128} {
	    set reg_value_for_width 2
	} elseif {$width == 256} {
	    set reg_value_for_width 3
	}
	
	# get direction register value for avalon ports
	set avalon_rw_value 0
	if {[llength $read_ports] > 0} {
	    set avalon_rw_value $READ
	}
	if {[llength $write_ports] > 0} {
	    set avalon_rw_value [expr $avalon_rw_value | $WRITE]
	}
	
	foreach cmd_port $cmd_ports {
	    lset width_reg $cmd_port $reg_value_for_width
	    if {[llength $write_ports] > 0} {
		# use the lowest port #
		lset cmd_to_write_reg $cmd_port [lindex $write_ports 0]
	    }
	    if {[llength $read_ports] > 0} {
		lset cmd_to_read_reg $cmd_port [lindex $read_ports 0]
	    }
	    if {$is_axi == 0} {
		lset direction_reg $cmd_port $avalon_rw_value
	    }
	    lset fabric_reg $cmd_port $is_axi
	}
	if {$is_axi} { # axi always has two command ports, read always comes first
	    lset direction_reg [lindex $cmd_ports 0] $READ
	    lset direction_reg [lindex $cmd_ports 1] $WRITE
	}
	
	foreach read_port $read_ports {
	    lset read_to_cmd_reg $read_port [lindex $cmd_ports 0]
	}
	set index_of_cmd_port_for_write 0
	if {$is_axi} { # write port is always the second cmd port in axi
	    set index_of_cmd_port_for_write 1
	}
	foreach write_port $write_ports {
	    lset write_to_cmd_reg $write_port [lindex $cmd_ports $index_of_cmd_port_for_write]
	}
    }
    
    proc pack_register {register bits_per_piece} {
	set packed 0
	set register_len [llength $register]
	for {set i 0} {$i < $register_len} {incr i} {
	    set mask [expr (1 << $bits_per_piece) - 1]
	    set piece [lindex $register $i]
	    set shifted_and_masked_piece [expr ($piece & $mask) << ($i * $bits_per_piece)]

	    set packed [expr $packed | $shifted_and_masked_piece]
	}
	return $packed
    }
}
