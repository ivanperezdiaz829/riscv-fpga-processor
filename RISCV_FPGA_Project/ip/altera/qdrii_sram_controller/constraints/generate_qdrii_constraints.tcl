# -------------------------------------------------------------------------
#  This file was developed by Altera Corporation.  Any persons using this
#  file for any purpose do so at their own risk, and are responsible for
#  the results of such use.  Altera Corporation does not guarantee that
#  this file is complete, correct, or fit for any particular purpose.
#  NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
#  accompany any copy of this file.
# ------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# Revision     : $Revision: #1 $
# Date         : $Date: 2013/08/11 $

# Description  : This script is called from the MegaWizard and will generate a TCL script that will
#                apply placement, I/O standard and various other constraints to the project.
#
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
#
# 			GLOBAL ARRAYS
#
# -------------------------------------------------------------------------------------------------

array set user_assignment_array {name user_assignment_array}
array set lcell_placement_array {name lcell_placement_array}
array set lcell_paths_array {name lcell_paths_array}
array set lcell_dq_dqs_pins_array {name lcell_dq_dqs_pins_array}
array set io_path_array {}
array set io_name_mapping_array {}
array set final_placement_array {name final_placement_array}
array set final_placement_clock_array {name final_placement_clock_array}

set lcell_placement_file_version 02
set hdl_path_file_version 03
set device_package_file_version 02

set generate_txt_placement_file 0

if { [info exists argv] } {
	set this_file $argv0
}

set charmap_sq  {{\\} {\\\\} {[} {\\\[} {]} {\\\]} {"} {\"} }

# -------------------------------------------------------------------------------------------------
#
# 			PROCEDURES
#
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
#          read_user_assignment_file
# -------------------------------------------------------------------------------------------------

proc read_user_assignment_file  {array_name filename_in} {

#	global array user_assignment_array
	upvar $array_name local_array

	# open file
	# read each line
		# search for comments or empty lines
		# check validity for other lines and ignore comments at the end

	# building a list of items that we do not want to lowercase
	set no_lowercase_list ""
	lappend no_lowercase_list toplevel_name
	lappend no_lowercase_list variation_path
	lappend no_lowercase_list wrapper_name
	lappend no_lowercase_list clock_neg_pin_name
	lappend no_lowercase_list clock_pos_pin_name


	if  {[ catch { open $filename_in  r }   user_id  ]} {
	    puts  " - ERROR: Cannot read User Specification file '$filename_in'"
	    puts  " ------------------------------------\n"
	    exit 1
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number

			set in_line [string trimleft $in_line]
			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line] && ![regexp "^(?:\/\/.*)+$" $in_line]} { ;# this is not a comment or empty line

				# parse the line. The format is <name> = <value(s)>. Trailing comments will be removed
				if {[regexp {(\w+)\s*=([ a-zA-Z0-9_\.\-\/\t|:]*)(?:\-\-.*)?} $in_line dummy param_name param_value]} {
					if {$param_value == ""} {set param_value \"\"}
					# check if we want to keep the case or lowercase the paramter
					if {[lsearch $no_lowercase_list [string tolower [string trim $param_name]]] >= 0 } {
						set local_array([string tolower $param_name]) [string trim $param_value]
					} else {
						set local_array([string tolower $param_name]) [string tolower [string trim $param_value]]
					}
				} else {
					puts "line $line_number invalid parameter format: $in_line"
				}
			}

	 	}
	}
	return 0

}

# -------------------------------------------------------------------------------------------------
#          read_device_file
# -------------------------------------------------------------------------------------------------

proc read_device_file {array_name filename_in} {

#	global array user_assignment_array
	upvar $array_name local_array

	# open file
	# read each line
		# search for comments or empty lines
		# check validity for other lines and ignore comments at the end

	set found_package 0
	set found_size 0

	if  {[ catch { open $filename_in  r }   user_id  ]} {
	    puts  " - ERROR: Cannot read Device dat file '$filename_in'"
	    puts  " ------------------------------------\n"
	    exit 1
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number
			set in_line [string trimleft $in_line]
			# parse the line. The format is either:
			#    pkg <device_name> <pkg list>
			#	 size <device_name> <max_row> <max_column>
			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line]} { ;# this is not a comment or empty line
				if {[regexp -nocase "pkg\\s*$local_array(device)\\s+.*$local_array(package)" $in_line dummy param_name param_value]} {
					set found_package 1
				}
				if {[regexp -nocase "size\\s*$local_array(device)\\s+(\\d*)\\s+(\\d*)" $in_line dummy max_row max_column]} {
					set found_size 1
					set local_array(max_row) $max_row
					set local_array(max_column) $max_column
				}
			}
	 	}
	}
	if {$found_size == 1 && $found_package == 1} {
		return 0
	} else {
		return 1
	}

}


# -------------------------------------------------------------------------------------------------
#          read_device_package_file
# -------------------------------------------------------------------------------------------------

proc read_device_package_file {array_name filename_in user_assignment_array_name} {

	upvar $array_name local_array
	upvar $user_assignment_array_name local_user_array

	# open file
	# read each line
		# search for comments or empty lines
		# check validity for other lines and ignore comments at the end

	if  {[ catch { open $filename_in  r }   user_id  ]} {
	    puts  " - ERROR: Cannot read device dat file file '$filename_in'"
	    puts  " ------------------------------------\n"
	    return 1
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		set current_group none
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number
			set in_line [string trimleft $in_line]
			# this file has 2 sections.
			# first section has general information such as:
			#	- max_pads_per_row
			#	- max_pads_per_column
			#	- best_placement_constraint_file
			# second section has groups and pad names
			#	- group <group name>
			#	- <pin_name> <device pin name> <row/column> <position in lab> <dq_enable_pair>
			#	-

			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line]} { ;# this is not a comment or empty line
				if {[regexp -nocase "(max_pads_per_(?:row|column))\\s*(\\d+)\\s*(?:\-\-.*)?$" $in_line dummy param_name param_value]} {
					set local_user_array([string tolower $param_name]) $param_value
				}
				if {[regexp -nocase "(best_placement_constraint_file)\\s*(\\w+)\\s*(?:\-\-.*)?$" $in_line dummy param_name param_value]} {
					set local_user_array([string tolower $param_name]) $param_value
				}
				if {[regexp -nocase "group\\s*(\\w+)\\s*(?:\-\-.*)?$" $in_line dummy param_value]} {
					set current_group [string tolower $param_value]
					lappend local_array(group_list) [string tolower $param_value]
				}
				if {[regexp -nocase "(\\w+)\\s+((?:dq\[0-9\]+|cq|cqn|qvld))\\s+(\\w+)\\s+(\\S+)\\s+(\\d+)\\s+(\\S+)\\s*(\[0-9A-Za-z_\]+)?\\s*(?:\-\-.*)?$" $in_line dummy user_secondary_function pin_name device_pin_name row_col_string lab_pos dq_enb_pair_string]} {
					lappend local_array($current_group,pin_list) [string tolower $pin_name]
					if {[regexp -nocase "dq\[0-9\]+" $pin_name]} { ; #this is a dq pin
						lappend local_array($current_group,dq_pin_list) [string tolower $pin_name]
					}
					regexp -nocase {([tlrb])} $current_group dummy side_loc

					# at this point, we need to split the $dq_enb_pair_number into 2. In fact, the number can be a simple number e.g. 0
					# or a number and a shift for the placement (not used often)
					# the way it works is <number><direction><number of steps>, where number is typically 0 or 1, direction is
					# u (up), d (down), l (left) or r (right). The step number is typically small (like 1 or 2)
					set x_ord_offset 0
					set y_ord_offset 0
					if {[regexp -nocase {(\d+)([udlr])(\d+)} $row_col_string dummy row_col row_col_shift_dir row_col_shift_value]} {
	       				if {[string compare $row_col_shift_dir "u"] == 0} {
	       				 	set y_ord_offset $row_col_shift_value
	       				} elseif {[string compare $row_col_shift_dir "d"] == 0} {
	       					set y_ord_offset -$row_col_shift_value
	       				} elseif {[string compare $row_col_shift_dir "l"] == 0} {
	       				 	set x_ord_offset -$row_col_shift_value
	       				} elseif {[string compare $row_col_shift_dir "r"] == 0} {
	       					set x_ord_offset $row_col_shift_value
	       				}
	       			} else {
	       				set row_col $row_col_string
	       			}

					lappend local_array(row_col_pad_list,${row_col}${side_loc}) ${pin_name}_${current_group}

					set dq_enb_x_ord_offset 0
					set dq_enb_y_ord_offset 0
					if {[regexp -nocase {(\d+)([udlr])(\d+)} $dq_enb_pair_string dummy dq_enb_pair_number dq_enb_pair_shift_dir dq_enb_pair_shift_value]} {
	       				if {[string compare $dq_enb_pair_shift_dir "u"] == 0} {
	       				 	set dq_enb_y_ord_offset $dq_enb_pair_shift_value
	       				} elseif {[string compare $dq_enb_pair_shift_dir "d"] == 0} {
	       					set dq_enb_y_ord_offset -$dq_enb_pair_shift_value
	       				} elseif {[string compare $dq_enb_pair_shift_dir "l"] == 0} {
	       				 	set dq_enb_x_ord_offset -$dq_enb_pair_shift_value
	       				} elseif {[string compare $dq_enb_pair_shift_dir "r"] == 0} {
	       					set dq_enb_x_ord_offset $dq_enb_pair_shift_value
	       				}



	       			} else {
	       				set dq_enb_pair_number $dq_enb_pair_string
	       			}
					lappend local_array($current_group,[string tolower $pin_name]) $device_pin_name $row_col $lab_pos $dq_enb_pair_number $x_ord_offset $y_ord_offset $dq_enb_x_ord_offset $dq_enb_y_ord_offset


				}
				if {[regexp -nocase "(?:ll)\\s+(?:ll)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+\\S+\\s*(?:\-\-.*)?$" $in_line dummy ll_origin ll_width ll_depth]} {
					lappend local_array($current_group,ll_region) $ll_origin $ll_width $ll_depth
				}

			}
	 	}
	}
	return 0
}



# -------------------------------------------------------------------------------------------------
#          read_lcell_placement_file
# -------------------------------------------------------------------------------------------------

proc read_lcell_placement_file {array_name filename_in user_assignment_array_name} {

#	global array user_assignment_array
	upvar $array_name local_array
	upvar $user_assignment_array_name local_user_array

	# open file
	# read each line
		# search for comments or empty lines
		# check validity for other lines and ignore comments at the end
    set local_array(le_name_list) ""

	if  {[ catch { open $filename_in  r }   user_id  ]} {
	    puts  " - ERROR: Cannot read lcell placement dat file file '$filename_in'"
	    puts  " ------------------------------------\n"
	    exit 1
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number
			set in_line [string trimleft $in_line]
			# the file has 2 different data type:
			#    - some general info which mostly relates to max_number of pads per row/column
			#    - specific pin placement

			# for the pin placement, we will use the following format:
			# pin_type_list <list of available pins>
			# pin_type {Row_X Row_Z Column_Y Column_X Column_Z Pin_Type}

			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line]} { ;# this is not a comment or empty line
			puts "$in_line"
				if {[regexp -nocase "(max_pads_per_\\w+)\\s*(\\d*)\\s*" $in_line dummy param_name param_value]} {

					if {[info exists local_user_array([string tolower $param_name])]} {
						if {$param_value < $local_user_array([string tolower $param_name])} {
							puts "This lcell_placement file is not suitable for this device/package combination - $param_value < $local_user_array([string tolower $param_name])"
						}
						set local_user_array([string tolower $param_name]) $param_value ; # swapping the value to use the one in the lcell_placement
					} else {
						puts "the parameter $param_name is missing for the device and package file"
					}
				}
				if {[regexp -nocase "(\\w+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\\w+)\\s+(\\d)\\s*(?:\-\-.*)?" $in_line dummy le_name le_row_x le_row_z le_col_y le_col_x le_col_z le_pin_type le_demote_to_lab]} {
				puts "$le_name"
					lappend local_array(le_name_list) [string tolower $le_name]
					lappend local_array([string tolower $le_pin_type]) [string tolower $le_name]
					set local_array([string tolower  $le_name]) [list $le_row_x $le_row_z $le_col_y $le_col_x $le_col_z [string tolower $le_pin_type] $le_demote_to_lab]
				}
			}
	 	}
	}
	return 0
}

# -------------------------------------------------------------------------------------------------
#          read_hdl_path_file
# -------------------------------------------------------------------------------------------------

# %1 : byte group
# %2 : dq index
# %3 : family name

# instance_name_1 comes from the user_assignment file
# instance_name 2 is the first line in the hdl_path_name after changes to the %3 tag
# instance_name_3 is also given in that file and is dependent on the pin type

proc read_hdl_path_file {array_name filename_in lcell_array_name user_assignment_array_name skip_placement message_error_level} {

	upvar $array_name local_array
	upvar $lcell_array_name local_lcell_array
	upvar $user_assignment_array_name local_user_array

	set quartus_version $local_user_array(quartus_version)

set charmap_sq2  {{\\} {\\\\} {[} {\[} {]} {\]} {"} {\"} }

	if  {[ catch { open $filename_in  r }   user_id  ]} {
		if {$message_error_level >= 2} {
		    puts  " - ERROR: Cannot read hdl path dat file file '$filename_in'"
		    puts  " ------------------------------------\n"
		} else {
		    puts  " - INFO: hdl path dat file file '$filename_in' does not exist"
		    puts  " ------------------------------------\n"
	    }
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number
			set in_line [string trimleft $in_line]

			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line]} { ;# this is not a comment or empty line
				if {[regexp -nocase "general_path\\s*(\[\\d.\]+)\\s*(\\S*)$" $in_line dummy for_quar_ver param_value]} {
					# we are checking for the latest version that matches the
					set set_values 0
					if {![info exists local_array(general_path)]} {
						set set_values 1
					} elseif {[expr {$quartus_version - $local_array(general_path,quartus_version)}] >= [expr {$quartus_version - $for_quar_ver}] && [expr {$quartus_version - $for_quar_ver}] >= 0  } {
						set set_values 1
					}

					if {$set_values} {
						set local_array(general_path) $param_value
						set local_array(general_path,quartus_version) $for_quar_ver
					}
				}
				if {[regexp -nocase "resynch_path\\s*(\[\\d.\]+)\\s*(\\S*)$" $in_line dummy for_quar_ver param_value]} {
					# we are checking for the latest version that matches the
					set set_values 0
					if {![info exists local_array(resynch_path)]} {
						set set_values 1
					} elseif {[expr {$quartus_version - $local_array(resynch_path,quartus_version)}] >= [expr {$quartus_version - $for_quar_ver}] && [expr {$quartus_version - $for_quar_ver}] >= 0  } {
						set set_values 1
					}

					if {$set_values} {
						set local_array(resynch_path) $param_value
						set local_array(resynch_path,quartus_version) $for_quar_ver
					}
				}

# >>>> HERE <<<
				if {[regexp -nocase "(d\[qm\]\[s\]?)_altddio_path\\s*(\[\\d.\]+)\\s*(\\S*)$" $in_line dummy param_name for_quar_ver param_value]} {
					set set_values 0
					if {![info exists local_array([string tolower $param_name]_path)]} {
						set set_values 1
					} elseif {[expr {$quartus_version - $local_array([string tolower $param_name]_path,quartus_version)}] >= [expr {$quartus_version - $for_quar_ver}] && [expr {$quartus_version - $for_quar_ver}] >= 0  } {
						set set_values 1
					}

					if {$set_values} {
						set local_array([string tolower $param_name]_path) $param_value
						set local_array([string tolower $param_name]_path,quartus_version) $for_quar_ver
					}
				}
				if {!$skip_placement && [regexp -nocase "(\\w+)\\s+(\[\\d.\]+)\\s+(\\S+)\\s+(\\w+)\\s+(\\S+)\\s+(\\d+)\\s*(?:\-\-.*)?$" $in_line dummy cell_name for_quar_ver hdl_name hierarchy_name number_items specific_placement] } {
					# building the path
					# checking which pins it applies to: (will need to check it exists first)
					if {[expr {[lsearch $local_lcell_array(le_name_list) [string tolower $cell_name]] < 0}]} { ; # item not found
						#puts "missing item in lcell placement $cell_name"

					} else {
						# get the pin type. This is the last entry of the field
						set pin_type [lindex $local_lcell_array([string tolower $cell_name]) 5]
						set set_values 0
						set first_time_set 0
						set le_demote_to_lab [lindex $local_lcell_array([string tolower $cell_name]) 6]
						if {![info exists local_array([string tolower $cell_name],path)]} {
							set set_values 1
							set first_time_set 1
						} elseif {[expr {$quartus_version - $local_array([string tolower $cell_name],quartus_version)}] >= [expr {$quartus_version - $for_quar_ver}] && [expr {$quartus_version - $for_quar_ver}] >= 0  } {
							set set_values 1
						}
						if {$set_values} {

							# Now we need to check the number of items to set. In most cases it is only one, but for some
							# buffers it can be several. What we need to do is to check that:
							# - we have either more than one or it is dependent on a variable.
							# - do as many assignments as required
							# If more than one are required, then we need to replace the %6 parameter by the correct value

							# check how many we have.
							# first check if we have a natural value or a parameter name on $number_items
							if {[regexp -nocase {^\d+$} $number_items]} {
								# item is a numerical value
								set number_items $number_items
							} elseif { [info exists local_user_array($number_items)]} {
								set number_items $local_user_array($number_items)
							} else {
								puts "Error, there is no variable $number_items in the user settings file. The script cannot place the item $cell_name"
								set number_items 0
							}
							for {set item_number_loop 0} {$item_number_loop < $number_items} {incr item_number_loop} {

								if {[regexp %6 $hdl_name]} {
									set cell_name_suffix "_$item_number_loop"
									set local_array([string tolower $cell_name],path) ""
									set amended_hdl_name [regsub -all "(%6)" $hdl_name $item_number_loop]
								} else {
									set cell_name_suffix ""
									set amended_hdl_name $hdl_name
								}
								if {$first_time_set} {
									lappend local_array($pin_type) [string tolower ${cell_name}${cell_name_suffix}]
								}

								set local_array([string tolower ${cell_name}${cell_name_suffix}],le_demote_to_lab) $le_demote_to_lab
								set local_array([string tolower ${cell_name}${cell_name_suffix}],specific_place) $specific_placement
								set local_array([string tolower ${cell_name}${cell_name_suffix}],path) ""
								set local_array([string tolower ${cell_name}${cell_name_suffix}],quartus_version) $for_quar_ver
								if {[regexp -nocase "altddio" $hierarchy_name]} {
									append local_array([string tolower ${cell_name}${cell_name_suffix}],path) \\\${hierarchy_path_to_instance} \$lcell_paths_array(general_path) \$lcell_paths_array(${pin_type}_path) [string map  $charmap_sq2 $amended_hdl_name]
								} elseif {[regexp -nocase "resynch" $hierarchy_name]} {
									append local_array([string tolower ${cell_name}${cell_name_suffix}],path) \\\${hierarchy_path_to_instance} \$lcell_paths_array(general_path) \$lcell_paths_array(resynch_path) [string map  $charmap_sq2 $amended_hdl_name]
								} else {
									append local_array([string tolower ${cell_name}${cell_name_suffix}],path) \\\${hierarchy_path_to_instance} \$lcell_paths_array(general_path) [string map  $charmap_sq2 $amended_hdl_name]
								}
							}
						}
					}

				}
			}
	 	}
	}
	return 0
}


# -------------------------------------------------------------------------------------------------
#          read_io_type_file
# -------------------------------------------------------------------------------------------------

proc read_io_type_file {array_name filename_in io_name_mapping_array_name user_assignment_array_name error_level} {

#	global array user_assignment_array
	upvar $array_name local_array
	upvar $io_name_mapping_array_name local_io_name_mapping_array
	upvar $user_assignment_array_name local_user_array

	# open file
	# read each line
		# search for comments or empty lines
		# check validity for other lines and ignore comments at the end

	if  {[ catch { open $filename_in  r }   user_id  ]} {
		if {$error_level >= 2} {
		    puts  " - ERROR: Cannot read IO dat file '$filename_in' "
		    puts  " ------------------------------------\n"
		    return 1
		} else {
		    puts  " - INFO: IO dat file '$filename_in' was not found. It may not exists for this device family"
		    puts  " ------------------------------------\n"
		    return 0
		}
	} else {
	    puts  " -        Reading file:      $filename_in.."
		set line_number 0
		while { [gets $user_id  in_line   ] >= 0 }  {
			incr line_number
			if {![regexp "^(?:\-\-.*)+$" $in_line] && ![regexp "^\s*$" $in_line]} { ;# this is not a comment or empty line
				set in_line [string trimleft $in_line]

				if {[regexp -nocase {(list|width|map_name|numb_if|pin_dir)\s+(\w+)\s*=([ a-zA-Z0-9_\%\/\t\.]*)(?:\-\-.*)?} $in_line dummy param_type param_name param_value]} {
					set local_array([string tolower $param_name]) [string tolower [string trim $param_value]]
					# format of lines:
					# list <list name> = <list>
					# width <bus_name> = <width_parameter_name>

					if {[string tolower $param_type] == "list"} {
						lappend local_array(list,type_list) $param_name
						set param_value [string trim $param_value]
						set line_list [split $param_value]
						for {set i 0} {$i < [llength $line_list]} {incr i} {
							lappend local_array(list,[string tolower $param_name]) [lindex $line_list $i]
							# add a width if it does not exist already. If it is single bit, set to 0.
							if {![info exists local_array(width,[lindex $line_list $i])]} {
								set local_array(width,[lindex $line_list $i]) 0
							}
							if {![info exists local_array(chip_wide,[lindex $line_list $i])]} {
								set local_array(chip_wide,[lindex $line_list $i]) -1
							}
							if {![info exists local_array(chip_deep,[lindex $line_list $i])]} {
								set local_array(chip_deep,[lindex $line_list $i]) -1
							}

						}
					}
					if {[string tolower $param_type] == "pin_dir"} {
						lappend local_array(list,type_list) $param_name
						set param_value [string trim $param_value]
						set line_list [split $param_value]
						for {set i 0} {$i < [llength $line_list]} {incr i} {
							lappend local_array(pin_dir,[string tolower $param_name]) [lindex $line_list $i]
							if {![info exists [string tolower $param_name]]} {lappend local_array(pin_dir,) [string tolower $param_name]}
							
						}
					}

					if {[string tolower $param_type] == "width"} {
						set param_value [string trim $param_value]
						set param1 unused_param
						set param2 unused_param
						# what we do here is check if there is there is an operator (divider only). If so, this means we have 2 parameters to check for
						if {[regexp {(\S*)\s+/\s+(\S*)} $param_value dummy param1 param2]} {
							set param1 [string trim $param1]
							set param2 [string trim $param2]
							# check if the second param is an integer
							if  {[regexp {^\d+$} $param2]} {
								set new_param_value [expr {$local_user_array([string tolower $param1])/$param2}]
							} else {
								set new_param_value [expr {$local_user_array([string tolower $param1])/$local_user_array([string tolower $param2])}]
							}
						} else {
							if  {[regexp {^\d+$} $param_value]} {
								set new_param_value $param_value
							} else {
								set new_param_value $local_user_array([string tolower $param_value])
							}
						}
puts "param $param_name - param value $new_param_value"
#						if {[info exists local_user_array([string tolower $param_value])] || ([info exists local_user_array([string tolower $param1])] && [info exists local_user_array([string tolower $param2])])} {}
							# only apply if the paramter exists in the user_assignment file
							set local_array(width,[string tolower $param_name]) $new_param_value
#						{}
					}
					if {[string tolower $param_type] == "map_name"} {
						set param_value [string trim $param_value]
						set local_io_name_mapping_array([string tolower $param_name]) $param_value
					}

					if {[string tolower $param_type] == "numb_if"} {
						set param_value [string trim $param_value]
						set param1 unused_param
						set param2 unused_param
						# what we do here is check if there is there is an operator (divider only). If so, this means we have 2 parameters to check for
puts "param_value $param_value"
						if {[regexp {(\S*)\s+(\S*)} $param_value dummy param1 param2]} {

							set param1 [string trim $param1]
							set param2 [string trim $param2]
							# check if the second param is an integer
							set local_array(chip_wide,[string tolower $param_name]) $local_user_array([string tolower $param1])
							set local_array(chip_deep,[string tolower $param_name]) $local_user_array([string tolower $param2])
						} else {
							set local_array(chip_wide,[string tolower $param_name]) $local_user_array([string tolower $param_value])
							set local_array(chip_deep,[string tolower $param_name]) -1
						}

					}

					if {[string tolower $param_type] == "pin_dir"} {
						lappend local_array(list,type_list) $param_name
						set param_value [string trim $param_value]
						set line_list [split $param_value]
						for {set i 0} {$i < [llength $line_list]} {incr i} {
							lappend local_array(pin_dir,[string tolower $param_name]) [lindex $line_list $i]
							if {![info exists [string tolower $param_name]]} {lappend local_array(pin_dir,) [string tolower $param_name]}
							
						}
					}




				} else {
					puts "line $line_number invalid parameter format: $in_line"
				}


			}
	 	}
	}
	return 0

}



# -------------------------------------------------------------------------------------------------
#          modify_clock_names
# -------------------------------------------------------------------------------------------------

# In this procedure, we will remap some names that should be remapped by the MegaWizard.
# In case no remapping was done in the MegaWizard, then we will skip the remapping
# The usual clock names to be remapped are called  clock_pos_pin_name and clock_neg_pin_name

proc modify_clock_names { user_assignment_array_name io_name_mapping_array_name} {
	upvar $io_name_mapping_array_name local_io_name_mapping_array
	upvar $user_assignment_array_name local_user_array

	# The value coming from the user_assignment file will probably have [0] or another value at the end.
	# We need to strip that one out

	if {[info exists local_user_array(clock_pos_pin_name)]} {

		set local_io_name_mapping_array(clock_pos_pin_name) [lindex [split $local_user_array(clock_pos_pin_name) \[] 0]
	}

	if {[info exists local_user_array(clock_neg_pin_name)]} {
		set local_io_name_mapping_array(clock_neg_pin_name) [lindex [split $local_user_array(clock_neg_pin_name) \[] 0]
	}

	if {[info exists local_user_array(clockfeedback_in_pin_name)]} {
		set local_io_name_mapping_array(clockfeedback_in_pin_name) [lindex [split $local_user_array(clockfeedback_in_pin_name) \[] 0]
	}


	return 0

}


# -------------------------------------------------------------------------------------------------
#          check_using_side
# -------------------------------------------------------------------------------------------------

proc check_using_side {user_assignment_array_name } {
	upvar $user_assignment_array_name local_user_array


	foreach i ${local_user_array(byte_groups)} {
		if {[regexp -nocase {[lr]} $i]} {
			return 1
		}
	}
	return 0
}

# -------------------------------------------------------------------------------------------------
#
# 			MAIN
#
# -------------------------------------------------------------------------------------------------
puts "script running in [pwd]"

# This needs to be passed in from the script
#set constraints_path "D:/MegaCore/ddr_sdram-v2.2.0/constraints/"
#set constraints_path [file dirname $this_file]

#set constraints_path [file dirname $this_file]
if {[info exists generate_constraint_path ]} {
	set constraints_path $generate_constraint_path
}
if {![info exists constraints_path]} {
	set constraints_path [file dirname $this_file]
}

set dat_path         [file join $constraints_path       dat]
puts "dat_path $dat_path"

if {![info exists user_assignment_file]} {
    if {$argc > 0 } {
    	set user_assignment_file [lindex $argv 0]
    	puts "$user_assignment_file"
    } else {
    	puts "selecting default assignment file : user_assignments.txt"
    	set user_assignment_file user_assignments.txt
    }
}

if {![info exists constraints_out_file]} {
    if {$argc > 1 } {
    	set constraints_out_file [lindex $argv 1]
    	puts "$constraints_out_file"
    } else {
    	puts "selecting default assignment file : add_constraints.tcl"
    	set constraints_out_file add_constraints.tcl
    }
}

read_user_assignment_file user_assignment_array $user_assignment_file
# there we know if we are in nondws mode
if {[info exists {user_assignment_array(use_dqs_for_read)}] && [regexp -nocase "false" ${user_assignment_array(use_dqs_for_read)}]} {
	set nondqs_string "nondqs_"
	if {[info exists {user_assignment_array(migratable_bytegroups)}] && [regexp -nocase "true" ${user_assignment_array(migratable_bytegroups)}] } {
		append nondqs_string "mig_"
	} else {
		append nondqs_string "nonmig_"
	}

} else {
	set nondqs_string ""
}

read_device_file user_assignment_array $dat_path/devices.dat

set skip_placement [read_device_package_file lcell_dq_dqs_pins_array  $dat_path/${user_assignment_array(device)}_${user_assignment_array(package)}_${nondqs_string}x${user_assignment_array(mem_dq_per_cq)}_v${device_package_file_version}.dat user_assignment_array]

if {!$skip_placement} {read_lcell_placement_file lcell_placement_array $dat_path/lcell_placement_${user_assignment_array(best_placement_constraint_file)}_v${lcell_placement_file_version}.dat user_assignment_array}

read_hdl_path_file lcell_paths_array $dat_path/${user_assignment_array(mem_type)}_hdl_path_names_v${hdl_path_file_version}.dat lcell_placement_array user_assignment_array $skip_placement 2

read_io_type_file io_path_array $dat_path/${user_assignment_array(mem_type)}_iotype.dat io_name_mapping_array user_assignment_array 2
# will need to do some kind of checking on the validity of the tables


# now the actual constraint part
# -------------------------------------------------------------------------------------------------
# 			Set up some widely used variables
# -------------------------------------------------------------------------------------------------
	set device_is_cyclone 0
	set device_is_cycloneii 0
	set device_is_stratix 0
	set device_is_stratixii 0
	if {[regexp -nocase ep1c ${user_assignment_array(device)} ] == 1} { ; # we have a cyclone device
		set device_is_cyclone 1
		set device_family_name "Cyclone"
		set pll_family cyclone
		set dqs_group_family cyclone
		set le_per_lab 10 ; # cyclone only
		set device_speed_grade C6
	} elseif {[regexp -nocase ep1s ${user_assignment_array(device)} ] == 1} {
		set device_is_stratix 1
		set device_family_name "Stratix"
		set pll_family stratix
		set dqs_group_family stratix
		set le_per_lab 10 ; # unused - cyclone only
		set device_speed_grade C5
	} elseif {[regexp -nocase ep2s ${user_assignment_array(device)} ] == 1} {
		set device_is_stratixii 1
		set device_family_name "Stratix II"
		set pll_family stratixii
		set dqs_group_family stratixii
		set le_per_lab 10 ; # unused - cyclone only
		set device_speed_grade C4
	} elseif {[regexp -nocase hc2 ${user_assignment_array(device)} ] == 1} {
		set device_is_stratixii 1
		set device_family_name "Stratix II"
		set pll_family stratix
		set dqs_group_family stratixii
		set le_per_lab 10 ; # unused - cyclone only
		set device_speed_grade C4
	} elseif {[regexp -nocase ep2c ${user_assignment_array(device)} ] == 1} {
		set device_is_cycloneii 1
		set device_family_name "Cyclone II"
		set pll_family cyclone
		set dqs_group_family cycloneii
		set le_per_lab 16 ; # cyclone only
		set device_speed_grade C4
	} else {
		puts " - ERROR: Illegal family ${user_assignment_array(device)}"
		puts " ------------------------------------------------------------------\n"
		exit 1
	}

	set prefix_name ${user_assignment_array(qdrii_pin_prefix)}

	# read the io_type_file for the coorect device familie if it exists
	read_io_type_file io_path_array $dat_path/${user_assignment_array(mem_type)}_iotype_${dqs_group_family}.dat io_name_mapping_array user_assignment_array 0
	read_hdl_path_file lcell_paths_array $dat_path/hdl_path_names_${dqs_group_family}_v${hdl_path_file_version}.dat lcell_placement_array user_assignment_array $skip_placement 0

	# modify the clock names to match the input from the MegaWizard
#	modify_clock_names user_assignment_array io_name_mapping_array

	# set the number of dm pins
	if {${user_assignment_array(mem_type)} == "ddr_sdram" || ${user_assignment_array(mem_type)} == "ddr2_sdram"} {
			set dm_per_group [expr {${user_assignment_array(mem_dq_per_cq)}/8}]
	} else {
		set dm_per_group 0
	}


	# the lab_size sould be set somewhere else with different values for different families
	set lab_size 10

	if {!$skip_placement} {
		set vertical_in_lab_offset [expr {$lab_size / ${user_assignment_array(max_pads_per_column)}}]
		set horizontal_in_lab_offset [expr {$lab_size / ${user_assignment_array(max_pads_per_row)}}]
		if {$horizontal_in_lab_offset < $vertical_in_lab_offset} {
			set in_lab_offset $horizontal_in_lab_offset
		} else {
			set in_lab_offset $vertical_in_lab_offset
		}
		if {${user_assignment_array(max_pads_per_column)} < ${user_assignment_array(max_pads_per_row)}} {
			set max_number_pattern_in_lab ${user_assignment_array(max_pads_per_row)}
		} else {
			set max_number_pattern_in_lab ${user_assignment_array(max_pads_per_column)}
		}

		set user_assignment_array(le_per_lab) $le_per_lab ; # used to check that we do not overallocate in a lab
	}

	set placement_error_flag 0

	set out_tcl_id [open $constraints_out_file w]



# -------------------------------------------------------------------------------------------------
# 			Generic part of the script
# -------------------------------------------------------------------------------------------------
# put the global part here, such as open project, set project and the likes

    puts $out_tcl_id  "#\n# Auto-generated DDR & DDR2 SDRAM Controller Compiler Constraint Script \n#"
    puts $out_tcl_id  "# (C) COPYRIGHT 2005 ALTERA CORPORATION "
    puts $out_tcl_id  "# ALL RIGHTS RESERVED \n#"
    puts $out_tcl_id  "#------------------------------------------------------------------------"
    puts $out_tcl_id  "# This script will apply various placement, I/O standard and other       "
    puts $out_tcl_id  "# constraints to the current project. It is generated for a specific     "
    puts $out_tcl_id  "# project that was created with the MegaWizard and will apply the        "
    puts $out_tcl_id  "# constraints. It is generated for a specific project that was created   "
    puts $out_tcl_id  "# with the MegaWizard and will apply the constraints according to the    "
    puts $out_tcl_id  "# settings that were used in the MegaWizard.                             "
    puts $out_tcl_id  "#------------------------------------------------------------------------\n\n"

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

	set tab "    "
	set top_level ${user_assignment_array(toplevel_name)}
	set prefix_name ${user_assignment_array(qdrii_pin_prefix)}
	set pin_file ${user_assignment_array(tcl_pin_file)}

    if { $pin_file == "\"\"" } {
        set pin_file ""
    }
# -------------------------------------------------------------------------------------------------
# 			Map pins to their name
# -------------------------------------------------------------------------------------------------

	puts $out_tcl_id "\n${tab}############################################################################"
	puts $out_tcl_id "${tab}#  In this section you can set all the pin names, hierarchy and top level  #"
	puts $out_tcl_id "${tab}############################################################################"
	puts $out_tcl_id "${tab}set wizard_top_level                   ${top_level}; # this should be extracted automatically. If it fails use this setting"
	puts $out_tcl_id "${tab}set wizard_hier_path                   \"$user_assignment_array(variation_path)\" ; # REMEMBER TO FINISH THE PATH WITH A | (ie a vertical bar)"
	puts $out_tcl_id ""
	puts $out_tcl_id "${tab}set prefix_name                        ${prefix_name}"
	if { $pin_file != "" } {
		puts $out_tcl_id "${tab}set pin_file                           ${pin_file}"
	}

	puts $out_tcl_id ""
	foreach name [array names io_name_mapping_array] {
		# try to align all the variable by inserting the correct number of spaces
		set space_length [expr {35 - [string length $name]}]
		if {$space_length < 0} {set space_length 2}
		set space_string ""
		for {set space_count 0} {$space_count < $space_length} {incr space_count} {
			append space_string " "
		}
		puts $out_tcl_id "${tab}set ${name}${space_string}$io_name_mapping_array($name)"
	}
	if {[regexp -nocase "true" $user_assignment_array(variation_path)]} {set auto_hierarchy 0} else {set auto_hierarchy 1}
	puts $out_tcl_id "${tab}set do_analysis                        $auto_hierarchy \; # only set this to 0 if you already have run analysis on your project. It can stay set to 1."
	puts $out_tcl_id "${tab}set check_path_from_report             $auto_hierarchy \; # only set this to 0 if you already have run analysis on your project. It can stay set to 1."
	puts $out_tcl_id "${tab}###########################################################################\n"

# -------------------------------------------------------------------------------------------------
# 			Write required packages and warning messages
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  {puts "\n*********************************************************************"}
    puts $out_tcl_id  {puts "*         QDRII SRAM Controller Compiler                       *"}
    puts $out_tcl_id  {puts "*      setting up the constraints for your MegaCore                 *"}
	puts $out_tcl_id  {puts "*********************************************************************\n"}

	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "#                      Loading the required TCL packages        "
	puts $out_tcl_id  "###########################################################################\n"

	puts $out_tcl_id    "${tab}package require ::quartus::project"
	puts $out_tcl_id    "${tab}package require ::quartus::flow"
	puts $out_tcl_id    "${tab}package require ::quartus::report"

##ola
	#puts "\ntrying to write Ola's changes !!!!\n"
        puts $out_tcl_id  "\n###########################################################################"
	puts $out_tcl_id  "#        Checking if a remove_add_constrints script exist                 #"
	puts $out_tcl_id  "#        if so run it else run the add_constrints script                  #"
	puts $out_tcl_id  "###########################################################################\n"
	puts $out_tcl_id  "${tab}set run_var 0"
	puts $out_tcl_id  "${tab}set remove_file \"remove_add_constraints_for_$user_assignment_array(wrapper_name).tcl\""
#	puts $out_tcl_id  "${tab}set workDir \[pwd\]"

#	puts $out_tcl_id  "${tab}set settings \[open \"$user_assignment_array(wrapper_name)_ddr_settings.txt\" r\]"
#	puts $out_tcl_id  "${tab}while {\[gets \$settings line\] >= 0} {"
#	puts $out_tcl_id  "${tab}${tab}if { \[string compare \[lindex \[split \$line =\] 0\] \"quartus_project_name\"\] == 0 } {"
#	puts $out_tcl_id  "${tab}${tab}${tab}set project_name \[lindex \[split \$line =\] 1\]"
#	puts $out_tcl_id  "${tab}${tab}${tab}set flag \"found\""
#	puts $out_tcl_id  "${tab}${tab}${tab}set current_revision \[get_current_revision \$project_name\]"
#	puts $out_tcl_id  "${tab}${tab}${tab}project_open -revision \$current_revision \$project_name"
	puts $out_tcl_id  "${tab}${tab}${tab}if {!\[file exists \$remove_file\]} {"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}set run_var 1"
	puts $out_tcl_id  "${tab}${tab}${tab}} else {"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}if {!\[info exists add_remove_string\]} { "
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}${tab}source \$remove_file"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}${tab}set run_var 1"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}} else {"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}${tab}set run_var 1"
	puts $out_tcl_id  "${tab}${tab}${tab}${tab}}"
	puts $out_tcl_id  "${tab}${tab}${tab}}"
#	puts $out_tcl_id  "${tab}${tab}}"
#	puts $out_tcl_id  "${tab}}"
#	puts $out_tcl_id  "\n"
#	puts $out_tcl_id  "${tab}if { \[string compare \$flag \"found\"\] != 0 } {"
#	puts $out_tcl_id  "${tab}${tab}puts \"Can't read the quartus project name from the settings file\""
#	puts $out_tcl_id  "${tab}}"
	# puts $out_tcl_id  "${tab}close \$settings"
##ola
	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "#                     Check that the device is correct        "
	puts $out_tcl_id  "###########################################################################\n"
##ola
	puts $out_tcl_id  "if { \$run_var != 0 } {"
##ola

# -------------------------------------------------------------------------------------------------
# 			Create a funtion to check the paths
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "#    Procedure check_paths\(\) will analyse the project and check        "
    puts $out_tcl_id  "#    that the paths match the ones that the user may have changed "
    puts $out_tcl_id  "#    in the file or MegaWizard                                             "
	puts $out_tcl_id  "###########################################################################\n"

  puts $out_tcl_id  "  proc check_paths \{given_datapath_name do_analysis\} \{"
  puts $out_tcl_id  "\t\tset mem_type $user_assignment_array(mem_type)"
	puts $out_tcl_id  {	
			puts                    "\nNote: The add_constraints script is searching the correct path to the datapath in your MegaCore"
	    if {$do_analysis} {puts "      Analysis and Elaboration will be run and will take some time...\n"}

        set top_level ""

        if {$do_analysis} {

            set err [catch {execute_flow -analysis_and_elaboration } result]
            if {$err} {
                post_message -type error "Analysis and Elaboration failed. The constraints script will not be able to add any constraints."
                puts "ERROR: Analysis and Elaboration failed. The constraints script will not be able to add any constraints."
            } else {
                puts "Analysis and Elaboration was successful.\n"

                # get the top level name from Quartus
                set top_level [get_name_info -info entity_name [get_top_level_entity]]
                #puts "Top level name                = $top_level\n"
            }
        }

        set num_matches 0;
        set datapath_name_list ""
        array set datapath_hier_path {}

}
        # This get_names will return all the datapaths and their submodules - we'll extract just the datapath tops later
puts $out_tcl_id  "        set err \[catch \{set datapath_names \[get_names -filter *auk_${user_assignment_array(mem_type)}_datapath* -node_type hierarchy\]\} msg\]"
puts $out_tcl_id  {       if {$err} { puts "ERROR: $msg\n"}

        foreach_in_collection found_datapath $datapath_names {

            set item_to_test [get_name_info -info full_path $found_datapath]

            # Extract just the datapath top levels (ie not all their submodule) by looking for instance name are at the end of the string
            if {[regexp -nocase "^(.*\\\|)(\\\S+)_auk_${mem_type}_datapath:\\\w+\$" $item_to_test dummy hier_path datapath_name]} {

                # ok, so we found one. Add it to the list but check that we haven't already found it
                if {[info exists datapath_hier_path($datapath_name)]} {
                    if {$datapath_hier_path($datapath_name) != $hier_path} {
                        puts "ERROR : You have instantiated the same datapath more than once in the same design. You cannot instantiate the same datapath"
                        puts "        more than once since the constraints are location specific. Please modify the design so that each datapath is unique."
                    }
                }
                if {[lsearch $datapath_name_list $datapath_name] < 0} {
                    lappend datapath_name_list $datapath_name
                    #puts $datapath_name_list
                    set datapath_hier_path($datapath_name) $hier_path
                    incr num_matches;
                }

                #puts "Full path to datapath module  = $hier_path"
                #puts "Found datapath instance       = $datapath_name\n"
            }
        }


		if {[lsearch $datapath_name_list $given_datapath_name] < 0} {
            set warn_str "The expected name of the datapath (${given_datapath_name}_auk_${mem_type}_datapath) doesn't match the names found in the project (${datapath_name_list}) so this script will not add any constraints."
            puts "CRITICAL WARNING: $warn_str"; post_message -type critical_warning $warn_str
            set warn_str "This may be caused by redundant entries in the auto_add_ddr_constraints.tcl script or you may have renamed the entity or module containing the datapath."
            puts "CRITICAL WARNING: $warn_str"; post_message -type critical_warning $warn_str

            set returned_path "ERROR"
            set path_correct 0
		} else {
            set path_correct 1
			set returned_path $datapath_hier_path($given_datapath_name)
            puts "Note: found ${given_datapath_name}_auk_${mem_type}datapath in $datapath_hier_path($given_datapath_name)"
		}

        if {($num_matches > 1)} {
            puts "Note: found $num_matches datapath modules in top level entity \"$top_level\"\n";
        }

        set return_list ""
        lappend return_list $path_correct $top_level $returned_path

        return $return_list
    
    }
    
puts $out_tcl_id  "  	\}"

# -------------------------------------------------------------------------------------------------
# 			sets more parameters
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "#                     set parameters        "
	puts $out_tcl_id  "###########################################################################\n"
	puts $out_tcl_id "${tab}if \{!\[info exists add_remove_string\]\} \{set  add_remove_string \"\"\} "

	puts $out_tcl_id "${tab}set wrapper_name         $user_assignment_array(wrapper_name) "
	puts $out_tcl_id 	"if \{\$add_remove_string == \"\"\} \{"

	puts $out_tcl_id    "${tab}set current_project_device \[string tolower \[get_global_assignment -name DEVICE\]\]"
#	puts $out_tcl_id    "${tab}if {\[regexp -nocase ${user_assignment_array(device)}${user_assignment_array(package)} \$current_project_device\] == 0} {"
	puts $out_tcl_id    "${tab}if {\[regexp -nocase ${user_assignment_array(device)}${user_assignment_array(package)} \$current_project_device\] == 0 && \[regexp -nocase ${user_assignment_array(mig_device)}${user_assignment_array(mig_package)} \$current_project_device\] == 0} {"
    puts $out_tcl_id    "${tab}${tab}puts  \"*********************************************************************\""
    puts $out_tcl_id    "${tab}${tab}puts  \" ERROR: The device used by the MegaWizard no longer matches the      \""
    puts $out_tcl_id    "${tab}${tab}puts  \" device selected in Quartus II. Please run the MegaWizard again to   \""
    puts $out_tcl_id    "${tab}${tab}puts  \" ensure your constraints are correct for your chosen device.         \""
    puts $out_tcl_id    "${tab}${tab}puts  \"*********************************************************************\""
    puts $out_tcl_id    "${tab}${tab}post_message -type error \"The device expected by the constraint script (${user_assignment_array(device)}${user_assignment_array(package)}) does not match the device currently selected in Quartus II.\""
    puts $out_tcl_id    "${tab} \}"
	puts $out_tcl_id 	"\}"
	puts $out_tcl_id {	if {$add_remove_string == ""} {
		if {$check_path_from_report} {
			set post_analysis_variables [check_paths $wrapper_name $do_analysis]
			if {[lindex $post_analysis_variables 0] == 0} {
				set datapath_not_found 1
                puts "Error. Either Analysis & Elaboration failed or the script could not find your variation, check your Processing report panel for information. This script will now end without adding any constraints.";
                #post_message -type error " Either Analysis & Elaboration failed or the script could not find your variation, check your Processing report panel for information. This script will now end without adding any constraints.";
            }
			set top_level                  [lindex $post_analysis_variables 1]
			set hierarchy_path_to_instance [lindex $post_analysis_variables 2]
		} else {
            # don't extract path from report so use wizard entry for the path to the datapath
            if {![info exists hierarchy_path_to_instance]} {
                set hierarchy_path_to_instance         $wizard_hier_path

                set warn_str "The constraints script did not extract the path automatically. The entry you entered in the MegaWizard will be used ($hierarchy_path_to_instance)."
                puts "WARNING: $warn_str"; post_message -type warning $warn_str
            }

            # don't extract path from report so use wizard entry for the top level
            if {![info exists top_level]} {
                set top_level                          $wizard_top_level

                set warn_str "The constraints script did not extract the top level automatically. The entry detected by the MegaWizard will be used ($top_level)."
                puts "WARNING: $warn_str"; post_message -type warning $warn_str
            }
        }
	}}


# -------------------------------------------------------------------------------------------------
# 			Print a few messages
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "# "
    puts $out_tcl_id  "#    Main part of the constraints application        "
    puts $out_tcl_id  "# "
	puts $out_tcl_id  "###########################################################################\n"
	
	puts $out_tcl_id  "if \{!\[info exists datapath_not_found\]\} \{"
	puts $out_tcl_id  {	 if {$add_remove_string == "-remove"} {set apply_remove_string "Removing"} else {set apply_remove_string "Applying"}}
	puts $out_tcl_id  {	 puts "---------------------------------------------------------------------"}
    puts $out_tcl_id  {	 puts "-  $apply_remove_string constraints to datapath ${wrapper_name}_auk_ddr_sdram "}
    puts $out_tcl_id  {	 puts "-  Path to the datapath: ${hierarchy_path_to_instance}  "}
	puts $out_tcl_id  {	 puts "---------------------------------------------------------------------\n"}

	# the top level is two levels above the core. The hierarchy finishes with a |
	
	puts $out_tcl_id {set  example_top_hierarchy_list [split ${hierarchy_path_to_instance} |]}
	puts $out_tcl_id {set example_top_hierarchy ""}
	puts $out_tcl_id {for {set hier_i 0} {$hier_i < [expr {[llength $example_top_hierarchy_list] - 3}]} {incr hier_i} {append example_top_hierarchy [lindex $example_top_hierarchy_list $hier_i]}}
	puts $out_tcl_id { if {[llength $example_top_hierarchy_list] > 3} {append example_top_hierarchy "|"}}
	
# -------------------------------------------------------------------------------------------------
# 			Device wide constraints
# -------------------------------------------------------------------------------------------------
# device wide constraints such as IO style, clock, pll and the likes

    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string CQ pins as clocks for \${top_level}\"    "

	if {$device_is_cyclone || $device_is_cycloneii} {
		# temporary fix. If the timing script does not return a number, we will fix the value to some number such as 1875ps
		set timing_comment ""
		if {${user_assignment_array(dqs_delay_cyclone)} == "" } {set user_assignment_array(dqs_delay_cyclone) 1875; set timing_comment ";# This value is NOT the one returned by the timing script but a default value"}
		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"DQS_DELAY\" -to \"\${prefix_name}\${cq_pin_name}\" -entity \"\${top_level}\" \"${user_assignment_array(dqs_delay_cyclone)}ps\" \$add_remove_string $timing_comment"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"DQS_FREQUENCY\" -to \"\${prefix_name}\${cq_pin_name}\" -entity \"\${top_level}\" \"${user_assignment_array(clock_freq_in_mhz)} MHz\" \$add_remove_string"]\]"
	} elseif {$device_is_stratix} {
	}

# removing the output_enable_group for cq and cqn has it could have adverse effects.
#	puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${cqn_pin_name}\*\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
#	puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${cq_pin_name}\*\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${d_pin_name}\*\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"


    puts $out_tcl_id    "${tab}puts \"Turning off netlist optimisation for the DDR Datapath logic \"    "


    # Stratix/Cyclone

	if {$device_is_cyclone || $device_is_cycloneii} {
		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"STRATIX_DECREASE_INPUT_DELAY_TO_INTERNAL_CELLS\" -to \"\${prefix_name}\${q_pin_name}\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"

        # Add clock output Tco constraints to place logic sensibly next to the pin
		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name TCO_REQUIREMENT 6ns -to \"\${prefix_name}\${clock_pos_pin_name}\" \$add_remove_string"]\]"
		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name TCO_REQUIREMENT 6ns -to \"\${prefix_name}\${clock_neg_pin_name}\" \$add_remove_string"]\]"

	}

    # For generating performance figures more easily only (this is only use in regression tests)
    if {[info exists user_assignment_array(put_pins_at_edge_top)]} {
        if {${user_assignment_array(put_pins_at_edge_top)} == "1" } {
              puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment EDGE_TOP -to ${prefix_name}* \$add_remove_string"]\]"
        }
    }

	# In this section we want to apply constraints that are specified in the io_files. They are dependent on device and
	# memory type, but overall they are similar.
	# A list of parameters is created. The format of the list is:
	# <assignment parameter name> <Assignment name> <assignment value> <to> <entity> <message to display>


	set assignment_list ""

 ##check here if we are using Cyclone II and the side banks. If so, we need to move the SSTL type from type II to type I
	if {$device_is_stratixii && [check_using_side user_assignment_array]} {
	    if {${user_assignment_array(memory_voltage)} == "18" } {
    		lappend assignment_list "hstl_18_pin_list" 				"IO_STANDARD" 					"1.8-V HSTL CLASS I" 													"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 1.8-V HSTL CLASS I"
    	} else {
    		lappend assignment_list "hstl_15_pin_list" 				"IO_STANDARD" 					"1.5-V HSTL CLASS I" 													"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 1.5-V HSTL CLASS I"
    	}
	} else {
	    if {${user_assignment_array(memory_voltage)} == "18" } {
    		lappend assignment_list "hstl_18_pin_list" 				"IO_STANDARD" 					"1.8-V HSTL CLASS I" 												"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 1.8-V HSTL CLASS I"
    	} else {
    		lappend assignment_list "hstl_15_pin_list" 				"IO_STANDARD" 					"1.5-V HSTL CLASS I" 												"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 1.5-V HSTL CLASS I"
    	}
	}



	lappend assignment_list "fast_output_reg_pin_list" 			"FAST_OUTPUT_REGISTER"	"ON" 																					"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"		"\$apply_remove_string Fast output register assignments (addr/cmd) .."
	lappend assignment_list "min_strength_pin_list" 				"CURRENT_STRENGTH" 			"Min Strength" 																"\\\${prefix_name}\\\${\${pin}}" 	"\\\${top_level}" 	"\$apply_remove_string Min Strength assignment"
	lappend assignment_list "sstl_2_pin_list" 							"IO_STANDARD" 					"SSTL-2 CLASS I" 														"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string IO standard assignment for SSTL-2 CLASS I"
#	lappend assignment_list "hstl_2_pin_list" 							"IO_STANDARD" 					"HSTL-2 CLASS I" 														"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string IO standard assignment for SSTL-2 CLASS I"
	lappend assignment_list "clk_min_strength_pin_list" 		"CURRENT_STRENGTH" 			"Min Strength" 																"\\\${prefix_name}\\\${\${pin}}" 	"\\\${top_level}" 	"\$apply_remove_string Min Strength assignment"
	lappend assignment_list "clk_sstl_2_pin_list" 					"IO_STANDARD" 					"SSTL-2 CLASS I" 														"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string clock IO standard assignment for SSTL-2 CLASS I"
#	lappend assignment_list "clk_hstl_2_pin_list" 					"IO_STANDARD" 					"HSTL-2 CLASS I" 														"\\\${\${pin}}" 					"-" 												"\$apply_remove_string clock IO standard assignment for HSTL-2 CLASS I"
	lappend assignment_list "dq_output_pin_cap_load_list" 	"OUTPUT_PIN_LOAD" 			"\$user_assignment_array(pf_pin_load_on_dq)"	"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string $user_assignment_array(pf_pin_load_on_dq)pf load to DQ, CQ and CQN pins"
	lappend assignment_list "cmd_output_pin_cap_load_list" 	"OUTPUT_PIN_LOAD" 			"\$user_assignment_array(pf_pin_load_on_cmd)" "\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string $user_assignment_array(pf_pin_load_on_cmd)pf load to command pins"
#	lappend assignment_list "clk_output_pin_cap_load_list"  "OUTPUT_PIN_LOAD" 			"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
	lappend assignment_list "two_point_five_pin_list" 			"IO_STANDARD" 					"2.5-V" 																			"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	lappend assignment_list "one_point_eight_pin_list" 			"IO_STANDARD" 					"1.8-V" 																			"\\\${prefix_name}\\\${\${pin}}" 	"-" 								"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."

# only in non-dqs mode
	if {[regexp -nocase "false" ${user_assignment_array(use_dqs_for_read)}]} {
		lappend assignment_list "input_register_delay" 		"PAD_TO_INPUT_REGISTER_DELAY" 			"0" 									"\\\${prefix_name}\\\${\${pin}}" 					"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	}


	set prot_plan_xml(pin_list) ""

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
	    	if {$f_assign_entity != "-"} {
	    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	} else {
	    		set entity_parameter ""
	    	}
		    foreach pin $io_path_array(list,$f_param_name) {

				#set temp_path [regsub -all "(%1)" $temp_path $group_number]
				# regexp the param name and if there is a % then need a for loop
				# then need to know if there is one or more item as well
				set loop_width 1
				set loop_depth 1
				set add_numbers_width 0
				set add_numbers_depth 0
#				io_path_array chip_deep
				if {($io_path_array(chip_wide,$pin) > 1 || $io_path_array(chip_deep,$pin) > 1)} {
					set loop_width $io_path_array(chip_wide,$pin)
					set add_numbers_width 1
				}
				if {($io_path_array(chip_deep,$pin) > 1) || ($io_path_array(chip_wide,$pin) > 1 && $io_path_array(chip_deep,$pin) > 0) } {
					set loop_depth $io_path_array(chip_deep,$pin)
					set add_numbers_depth 1
				}

				puts "loop_width $loop_width - loop_depth $loop_depth - $pin - number of pins  $io_path_array(width,$pin)"
				for {set temp_width 0} {$temp_width < $loop_width} {incr temp_width} {
					for {set temp_depth 0} {$temp_depth < $loop_depth} {incr temp_depth} {
						if {$add_numbers_width} {
							set number_string _${temp_width}
							if {$add_numbers_depth} {
								append number_string _${temp_depth}
							}
						} else {
							set number_string ""
						}
		    			if {$io_path_array(width,$pin) > 0} {;# unroll the bus
				    		for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
				    			puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}${number_string}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
				    			set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\],$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]] < 0} {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\])  $f_assign_name
				    		}
				    	} else {
				    		# only one assignment, either a pin, or global assignment for the bus
				    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\"  -to \"[subst ${f_assign_to}${number_string}]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	        set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string},$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}] < 0}  {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string})  $f_assign_name
				    	}
				    }
				}
		    }
		}
	}


# This section only does protocol planner information about pin direction.
	set assignment_list ""
	lappend assignment_list "input_pin" 		"direction" 			"input" 										"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	lappend assignment_list "inout_pin" 		"direction" 			"bidir" 										"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	lappend assignment_list "output_pin" 		"direction" 			"output" 										"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."



	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
		foreach pin $io_path_array(list,$f_param_name) {
				#set temp_path [regsub -all "(%1)" $temp_path $group_number]
				# regexp the param name and if there is a % then need a for loop
				# then need to know if there is one or more item as well
				set loop_width 1
				set loop_depth 1
				set add_numbers_width 0
				set add_numbers_depth 0
#				io_path_array chip_deep
				if {($io_path_array(chip_wide,$pin) > 1 || $io_path_array(chip_deep,$pin) > 1)} {
					set loop_width $io_path_array(chip_wide,$pin)
					set add_numbers_width 1
				}
				if {($io_path_array(chip_deep,$pin) > 1) || ($io_path_array(chip_wide,$pin) > 1 && $io_path_array(chip_deep,$pin) > 0) } {
					set loop_depth $io_path_array(chip_deep,$pin)
					set add_numbers_depth 1
				}

				puts "param $f_param_name -- loop_width $loop_width - loop_depth $loop_depth - $pin - number of pins  $io_path_array(width,$pin)"
				for {set temp_width 0} {$temp_width < $loop_width} {incr temp_width} {
					for {set temp_depth 0} {$temp_depth < $loop_depth} {incr temp_depth} {
						if {$add_numbers_width} {
							set number_string _${temp_width}
							if {$add_numbers_depth} {
								append number_string _${temp_depth}
							}
						} else {
							set number_string ""
						}
		    			if {$io_path_array(width,$pin) > 0} {;# unroll the bus
				    		for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
#				    			puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}${number_string}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
				    			set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\],$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]] < 0} {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\])  $f_assign_name
				    		}
				    	} else {
				    		# only one assignment, either a pin, or global assignment for the bus
#				    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\"  -to \"[subst ${f_assign_to}${number_string}]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	        set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string},$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}] < 0}  {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string})  $f_assign_name
				    	}
				    }
				}
		}
	}


# if ddio
	set number_string ""
	if {$user_assignment_array(ddio_memory_clocks) == "true"} {
		set assignment_list ""
		lappend assignment_list "clk_output_pin_cap_load_list"  "OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
		if {$device_is_stratixii && [check_using_side user_assignment_array]} {
		    if {${user_assignment_array(memory_voltage)} == "18" } {
	    		lappend assignment_list "clk_hstl_18_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL CLASS I"
	    	} else {
	    		lappend assignment_list "clk_hstl_15_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL CLASS I"
	    	}
		} else {
		    if {${user_assignment_array(memory_voltage)} == "18" } {
	    		lappend assignment_list "clk_hstl_18_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL CLASS I"
	    	} else {
	    		lappend assignment_list "clk_hstl_15_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL CLASS I"
	    	}
		}

		# the width of the clock is the number of clocks
	
	} else {	; # using dedicated pll output
		set assignment_list ""
		lappend assignment_list "diff_clk_output_pin_cap_load_list"  "OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
		if {$device_is_stratixii && [check_using_side user_assignment_array]} {
		    if {${user_assignment_array(memory_voltage)} == "18" } {
	    		lappend assignment_list "diff_clk_hstl_18_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL CLASS I"
	    	} else {
	    		lappend assignment_list "diff_clk_hstl_15_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL CLASS I"
	    	}
		} else {
		    if {${user_assignment_array(memory_voltage)} == "18" } {
	    		lappend assignment_list "diff_clk_hstl_18_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL CLASS I"
	    	} else {
	    		lappend assignment_list "diff_clk_hstl_15_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL CLASS I" 								"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL CLASS I"
	    	}
		}
		# the width of the clock has a maximum of 3
	}


# may have a need to limit the number of clock pins out for the dedicated pll output

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
	    	if {$f_assign_entity != "-"} {
	    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	} else {
	    		set entity_parameter ""
	    	}
		    foreach pin $io_path_array(list,$f_param_name) {

				set max_pin_number $io_path_array(width,$pin)
				if {($max_pin_number > 3) && ($user_assignment_array(ddio_memory_clocks) == "false")} {set max_pin_number 3}

				#set temp_path [regsub -all "(%1)" $temp_path $group_number]
				# regexp the param name and if there is a % then need a for loop
				# then need to know if there is one or more item as well
				set loop_width 1
				set loop_depth 1

		    			if {$io_path_array(width,$pin) > 0} {;# unroll the bus
				    		for {set pin_number 0} {$pin_number < $max_pin_number} {incr pin_number} {
				    			puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
				    			set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\],$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]] < 0} {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\])  $f_assign_name

				    		}
				    	} else {
				    		# only one assignment, either a pin, or global assignment for the bus
				    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\"  -to \"[subst ${f_assign_to}]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	        set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string},$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}] < 0}  {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string})  $f_assign_name
				    	}
		    }
		}
	}

 # this section is only for the ppf file, not the constraints file
	set assignment_list ""
	if {$user_assignment_array(ddio_memory_clocks) == "true"} {
		lappend assignment_list "clock_output_pin" 		"direction" 			"output" 				"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	} else {
		lappend assignment_list "diff_clock_output_pin" 		"direction" 			"output" 				"\\\${prefix_name}\\\${\${pin}}" 	"-" 				"\$apply_remove_string IO standard assignment for 2.5V clock inputs.."
	}
	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
	    	if {$f_assign_entity != "-"} {
	    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	} else {
	    		set entity_parameter ""
	    	}
		    foreach pin $io_path_array(list,$f_param_name) {

				set max_pin_number $io_path_array(width,$pin)
				if {($max_pin_number > 3) && ($user_assignment_array(ddio_memory_clocks) == "false")} {set max_pin_number 3}
				
				#set temp_path [regsub -all "(%1)" $temp_path $group_number]
				# regexp the param name and if there is a % then need a for loop
				# then need to know if there is one or more item as well
				set loop_width 1
				set loop_depth 1

		    			if {$io_path_array(width,$pin) > 0} {;# unroll the bus
				    		for {set pin_number 0} {$pin_number < $max_pin_number} {incr pin_number} {
				    			set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\],$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]] < 0} {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\]}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string}\[$pin_number\])  $f_assign_name

				    		}
				    	} else {
				    		# only one assignment, either a pin, or global assignment for the bus
		    	        set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string},$f_assign_name) [subst $f_assign_value]
			    		    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}] < 0}  {lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)${number_string}}
			    		    lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)${number_string})  $f_assign_name
				    	}
		    }
		}
	}


	# <assignment parameter name> <Assignment name> <assignment value> <from> <to> <entity> <message to display>
#	set assignment_list ""
#	lappend assignment_list "cut_timing_path" 	"CUT" 	"ON" "\\\${prefix_name}\\\${\${pin}}\*"	"\*" 	"-" "\$apply_remove_string CUT TIMING PATH assignment for CQ pins"
#
#	foreach {f_param_name f_assign_name f_assign_value f_assign_from f_assign_to f_assign_entity f_display_string} $assignment_list {
#		if {[info exists io_path_array(list,$f_param_name)]} {
#		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
#	    	if {$f_assign_entity != "-"} {                         
#	    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
#	    	} else {
#	    		set entity_parameter ""
#	    	}
#		    foreach pin $io_path_array(list,$f_param_name) {
#		    	if {$io_path_array(width,$pin) > 0} {;# unroll the bus
#		    		for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
#		    			puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -from \"[subst ${f_assign_from}\\\[\$pin_number\\\]]\" -to [subst ${f_assign_to}] $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
#		    		}
#		    	} else {
#		    		# only one assignment, either a pin, or global assignment for the bus
#		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to [subst $f_assign_to] $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
#		    	}
#		    }
#		}
#	}

# apply the GLOBAL SIGNAL OFF to the CQ pin signals so that the routing to the memory is local (otherwise it will get hold timing violation)
# Only applicable in non-dqs mode on stratix II (not applicable on stratix
	set assignment_list ""

    if {${user_assignment_array(use_dqs_for_read)} == "true"} {
#	    lappend assignment_list "global_signal_off" 	"GLOBAL_SIGNAL" 	"OFF" "local_cq\[0\]"	"-" "\$apply_remove_string Put internal CQ clocks on local signals"
	    lappend assignment_list "global_signal_off" 	"GLOBAL_SIGNAL" 	"ON" "local_cq\\\[0\\\]"	"-" "\$apply_remove_string Apply Global signal for the capture clock"
	}                                                                                 
	

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
	    	if {$f_assign_entity != "-"} {
	    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	} else {
	    		set entity_parameter ""
	    	}
		    foreach pin $io_path_array(list,$f_param_name) {
		    	if {${user_assignment_array(num_chips_wide)} > 1} {;# unroll the bus
		    		for {set pin_number 0} {$pin_number < ${user_assignment_array(num_chips_wide)}} {incr pin_number} {
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_cq_cqn_group:auk_${user_assignment_array(mem_type)}_cq_cqn_group_${pin_number}|[subst $f_assign_to]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    		}
		    	} else {
		    		# only one assignment, either a pin, or global assignment for the bus
            # here we need to know if there are more than one or not
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_cq_cqn_group:auk_${user_assignment_array(mem_type)}_cq_cqn_group|[subst $f_assign_to]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	}
		    }
		}
	}

	set assignment_list ""

    if {${user_assignment_array(use_dqs_for_read)} == "true"} {
	    lappend assignment_list "setup_relationship" 	"SETUP_RELATIONSHIP" 	"-0.15 ns" "io_recaptured_data*"	"*" "\$apply_remove_string Apply setup time for recapture registers"
	    lappend assignment_list "hold_relationship" 	"HOLD_RELATIONSHIP" 	"[expr {(-450.0/${user_assignment_array(clock_freq_in_mhz)}) + 0.15}] ns" "io_recaptured_data*"	"*" "\$apply_remove_string Apply hold time for recapture registers"
	
	}                                                                                 
	

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_from f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""

		    foreach pin $io_path_array(list,$f_param_name) {
		    	if {${user_assignment_array(num_chips_wide)} > 1} {;# unroll the bus
		    		for {set pin_number 0} {$pin_number < ${user_assignment_array(num_chips_wide)}} {incr pin_number} {
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|[subst $f_assign_to]\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    		}
		    	} else {
		    		# only one assignment, either a pin, or global assignment for the bus
            # here we need to know if there are more than one or not
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"[subst $f_assign_name]\" -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|[subst $f_assign_to]\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	}
		    }
		}
	}

	set assignment_list ""

    if {${user_assignment_array(use_dqs_for_read)} == "true"} {
	    lappend assignment_list "optimize_hold" 	"OPTIMIZE_HOLD_TIMING" 	"ALL PATHS" ""	"-" "\$apply_remove_string Apply optimise hold timing for all paths"
	    lappend assignment_list "remove_warning" 	"INI_VARS" 	"skip_complementary_clock_usage_warning=on" ""	"-" "\$apply_remove_string Remove warning messages releated to the use of QDRII capture IO"
	    lappend assignment_list "remove_fitter_warning" 	"FIT_INI_VARS" 	"skip_complementary_clock_usage_warning=on" ""	"-" "\$apply_remove_string Remove warning messages releated to the use of QDRII capture IO"
            
	}                                                                                 
	        

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list {
	    puts $out_tcl_id    "${tab}puts \"$f_display_string\""
    	if {$f_assign_entity != "-"} {
    		set entity_parameter "-entity \"[subst $f_assign_entity]\""
    	} else {
    		set entity_parameter ""
    	}
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_global_assignment -name \"[subst $f_assign_name]\" \"[subst $f_assign_value]\" "]\]"
	}

### Need to add two things here:
# For the new reset scheme we need to cut the path in two places:
# - at the system_reset level where we have the external reset impacting the internal reset but should be cut
# - at the FIFO level where the right pointer reset is generated from the read side and has anti-metastability registers which should be cut
#set_instance_assignment -name CUT ON -from soft_reset_n -to soft_reset_reg_n
#set_instance_assignment -name CUT ON -from "qdrii_pll_stratixii:g_stratixiipll_qdrii_pll_inst|altpll:altpll_component|_clk0" -to qdrii_cq*

puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name CUT ON -from \${example_top_hierarchy}soft_reset_n -to  \${example_top_hierarchy}soft_reset_reg_n"]\]"
puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name CUT ON -from \${example_top_hierarchy}qdrii_pll_stratixii:g_stratixiipll_qdrii_pll_inst|altpll:altpll_component|_clk0 -to  \${prefix_name}cq*"]\]"

# Needed are for each block a cut path on the reset of the cq_clocks (in the training block somewhere)
#  - cut to all the write I/O (data, address and command)

# for the blocks, should follow this:
# from soft_reset_n to
#|new_top|myqdrii:auk_qdrii_mw_wrapper|myqdrii_auk_qdrii_sram:myqdrii_auk_qdrii_sram_inst|myqdrii_auk_qdrii_sram_pipe_resynch_wrapper:auk_qdrii_sram_pipe_resynch_wrapper|   myqdrii_auk_qdrii_sram_resynch_reg:auk_qdrii_sram_resynch_reg_1 --- meta_cq_reset_n <= reset_read_and_fifo_n


# note : need a new assignment name
	set assignment_list ""
  lappend assignment_list "setup_relationship" 	"CUT ON" 	"" "q_captured_falling"	"\\\${example_top_hierarchy}soft_reset_n" "\$apply_remove_string Cut path for reset on cq clock domain"
  lappend assignment_list "setup_relationship" 	"CUT ON" 	"" "q_captured_rising"	"\\\${example_top_hierarchy}soft_reset_n" "\$apply_remove_string Cut path for reset on cq clock domain"
  lappend assignment_list "setup_relationship" 	"CUT ON" 	"" "q_capture_reg"	"\\\${example_top_hierarchy}soft_reset_n" "\$apply_remove_string Cut path for reset on cq clock domain"
# also soft reset_n should be related to the new hierarchy top thing

	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_from f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""

		    foreach pin $io_path_array(list,$f_param_name) {
		    	if {${user_assignment_array(num_chips_wide)} > 1} {;# unroll the bus
		    		for {set pin_number 0} {$pin_number < ${user_assignment_array(num_chips_wide)}} {incr pin_number} {
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_read_group:auk_${user_assignment_array(mem_type)}_read_group_${pin_number}|[subst $f_assign_to]*\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]" 
						}
		    	} else {
		    		# only one assignment, either a pin, or global assignment for the bus
            # here we need to know if there are more than one or not
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_capture_group_wrapper:auk_${user_assignment_array(mem_type)}_capture_group_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_read_group:auk_${user_assignment_array(mem_type)}_read_group|[subst $f_assign_to]*\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]" 
		    	}
		    }
		}
	}

# missing: all the ddio out 
                                                                                                                                                            #myqdrii:auk_qdrii_mw_wrapper|myqdrii_auk_qdrii_sram:myqdrii_auk_qdrii_sram_inst|myqdrii_auk_qdrii_sram_datapath:auk_qdrii_sram_datapath|myqdrii_auk_qdrii_sram_addr_cmd_reg:qdrii_addr_cmd_output_1_0|altddio_out:rpsn_pin|ddio_out_9df:auto_generated|ddio_outa[0]~ddio_data_in_reg	  
	set assignment_list ""
  lappend assignment_list "setup_relationship" 	"CUT ON" 	"" "ddio_outa"	"soft_reset_n" "\$apply_remove_string Cut path for reset on cq clock domain"
	
	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_from f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""

		    foreach pin $io_path_array(list,$f_param_name) {
		    	if {${user_assignment_array(num_chips_wide)} > 1} {;# unroll the bus
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_addr_cmd_reg:*|[subst $f_assign_to]*\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	} else {
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_datapath:auk_${user_assignment_array(mem_type)}_datapath|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_addr_cmd_reg:*|[subst $f_assign_to]*\" -from [subst $f_assign_from] \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	}
		    }
		}
	}
	
	set assignment_list ""
  lappend assignment_list "setup_relationship" 	"CUT ON" 	"" "meta_cq_reset_n"	"reset_read_and_fifo_n" "\$apply_remove_string Cut path for reset on cq clock domain"
	
	foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_from f_display_string} $assignment_list {
		if {[info exists io_path_array(list,$f_param_name)]} {
		    puts $out_tcl_id    "${tab}puts \"$f_display_string\""

		    foreach pin $io_path_array(list,$f_param_name) {
		    	if {${user_assignment_array(num_chips_wide)} > 1} {;# unroll the bus
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper:auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_resynch_reg:auk_${user_assignment_array(mem_type)}_resynch_reg|[subst $f_assign_to]\" -from \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper:auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_train_wrapper:auk_${user_assignment_array(mem_type)}_train_wrapper|[subst $f_assign_from]\" \"[subst $f_assign_value]\" \$add_remove_string"]\]"															      																																																															       
			} else {
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name [subst $f_assign_name] -to \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper:auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_resynch_reg:auk_${user_assignment_array(mem_type)}_resynch_reg|[subst $f_assign_to]\" -from \"\${hierarchy_path_to_instance}${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper:auk_${user_assignment_array(mem_type)}_pipe_resynch_wrapper|${user_assignment_array(wrapper_name)}_auk_${user_assignment_array(mem_type)}_train_wrapper:auk_${user_assignment_array(mem_type)}_train_wrapper|[subst $f_assign_from]\" \"[subst $f_assign_value]\" \$add_remove_string"]\]"
			}
		    }
		}
	}

# for the other pins,

# -------------------------------------------------------------------------------------------------
# 			Specific constraints (group and bit dependent
# -------------------------------------------------------------------------------------------------
# Two loops, one per group then one per bit in each group
	set mem_dq_per_cq ${user_assignment_array(mem_dq_per_cq)}

	set number_of_dq_groups [expr {${user_assignment_array(memory_data_width)}/${mem_dq_per_cq}}]
	for {set group_number 0} {$group_number < $number_of_dq_groups} {incr group_number} {
		# -------------------------------------------------------------------------------------------------
		# 			set the group wide assignments here
		# -------------------------------------------------------------------------------------------------
# this is not correct. We want the user list not the overall list
		set current_group_name [lindex ${user_assignment_array(byte_groups)} $group_number]

		# --------- Misc assignments ----------------------------------------------------------------------
        set temp_path ""
		append temp_path \${hierarchy_path_to_instance} $lcell_paths_array(general_path)
		set temp_path [regsub -all "(%1)" $temp_path $group_number]
		set temp_path [regsub -all "(%4)" $temp_path ${user_assignment_array(wrapper_name)}]
		set abs_le_path_without_io [regsub -all "(%3)" $temp_path $dqs_group_family]
		# chop the trailing non word item if it a \|: type
		regexp "(.*)(?:\\W)+$" $abs_le_path_without_io dummy abs_le_path_without_io
#		puts $out_tcl_id   "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"ADV_NETLIST_OPT_ALLOWED\" -to \"$abs_le_path_without_io\" -entity \"\${top_level}\" \"Never Allow\"	\$add_remove_string"]\]"
#		puts $out_tcl_id   "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"REMOVE_DUPLICATE_REGISTERS\" -to \"$abs_le_path_without_io\" -entity \"\${top_level}\" \"Off\"	\$add_remove_string"]\]"




			if {$skip_placement} {
				continue
			}

		# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		#           Building the list of pins to which we want to do assignments
		#

		# In case of Stratix II you can have DQ0 to DQ8 and only want DQ0 to DQ7. DQ8 will be treated as DM
		set bit_list ""
		# list of dq pins

		for {set bit_number 0} {$bit_number < ${mem_dq_per_cq}} {incr bit_number} {
			# check the existence of the pin
			if {![info exists lcell_dq_dqs_pins_array($current_group_name,dq${bit_number})]} {
				puts "the device and package file does not provide the information needed for the pin dq${bit_number} in group $current_group_name"
				puts $out_tcl_id "    puts \"the device and package file does not provide the information needed for the pin dq${bit_number} in group $current_group_name\""
				puts $out_tcl_id "    post_message -type warning \"the device and package file does not provide the information needed for the pin dq${bit_number} in group $current_group_name\""
				continue
			}
#			set overall_bit_number [expr {$bit_number + $mem_dq_per_cq * $group_number}]
			set overall_bit_number $bit_number
		if   {$user_assignment_array(num_chips_wide) > 1}   {
			    set current_bit_name \${q_pin_name}_${group_number}\[${overall_bit_number}\]
			} else {
			    set current_bit_name \${q_pin_name}\[${overall_bit_number}\]
			}

			lappend bit_list dq $bit_number $current_bit_name $overall_bit_number
		}
		# one cq per group only
		if {![info exists lcell_dq_dqs_pins_array($current_group_name,cq)]} {
			puts "the device and package file does not provide the information needed for the pin cq in group $current_group_name"
#			exit 2
		} else {
    		if   {$user_assignment_array(num_chips_wide) > 1}   {
    			    lappend bit_list cq 0 \${cq_pin_name}_${group_number}\[0] 0
    			} else {
        			lappend bit_list cq 0 \${cq_pin_name}\[0] 0
        		}
		}
		if {![info exists lcell_dq_dqs_pins_array($current_group_name,cqn)]} {
			puts "the device and package file does not provide the information needed for the pin cqn in group $current_group_name"
#			exit 2
		} else {
    		if   {$user_assignment_array(num_chips_wide) > 1}   {
    			    lappend bit_list cqn 0 \${cqn_pin_name}_${group_number}\[0] 0
    			} else {
        			lappend bit_list cqn 0 \${cqn_pin_name}\[0] 0
        		}
		}
        
        if {[regexp -nocase "qdriiplus" $user_assignment_array(mem_type)]} {
#    		if {![info exists lcell_dq_dqs_pins_array($current_group_name,qvld)]} {
#    			puts "the device and package file does not provide the information needed for the pin cqn in group $current_group_name"
#    		} else {
#        		if   {$user_assignment_array(num_chips_wide) > 1}   {
#        			    lappend bit_list qvld 0 \${qvld_pin_name}_${group_number}\[0] 0
#        			} else {
#            			lappend bit_list qvld 0 \${qvld_pin_name}\[0] 0
#            		}
#    		}
        }


		#
		#           end of building the list of pins to which we want to do assignments
		# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		# -------------------------------------------------------------------------------------------------
		# 			Do the assignments to each bit
		# -------------------------------------------------------------------------------------------------
		foreach {bit_type bit_number current_bit_name overall_bit_number} $bit_list {


			# if in non dqs_mode then there is no point trying to assign anything on Stratix
			if {($device_is_stratix) && $user_assignment_array(use_dqs_for_read) == "false"} {
				continue
			}

			# now the numbering we have:
			# group_number : the number of the group (starts at 0)
			# bit_number : the number of the dq bit in the group (starts at 0)
			# overall_bit_number : the number of the bit in the whole of the interface (incremented by the group size every group)

			if {$bit_type == "dq"} {
				set bit_name_in_array ${bit_type}${bit_number}
			} else {
				set bit_name_in_array ${bit_type}
			}
			set current_bit_info $lcell_dq_dqs_pins_array($current_group_name,$bit_name_in_array)
			# format of the info is :
			# device_pin_name row_col lab_pos dq_enb_pair_number

			# first part of the assignment, the pin name (maybe also the pin type in terms of IO standard)
			# In case of a Pin, we need to prefix Pin_ to the name, otherwise leave the name untouched (such as IOBANK_4)
			if {[regexp -nocase "IOBANK" [lindex $current_bit_info 0]]} {; # specific to DM on Stratix
				set quartus_pin_prefix ""
			} else {
				set quartus_pin_prefix "Pin_"
			}
			puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -to \"\${prefix_name}${current_bit_name}\" \"${quartus_pin_prefix}[lindex $current_bit_info 0]\" \$add_remove_string "]\]"
			puts "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -to \"\${prefix_name}${current_bit_name}\" \"${quartus_pin_prefix}[lindex $current_bit_info 0]\" \$add_remove_string "]\]"
puts "current_bit_info -- $current_bit_info ----- $bit_type $bit_number $current_bit_name $overall_bit_number"

			# removing any trailing [] and adding it again (just for fun)
			if {[regexp {\$\{([a-z_A-Z0-9]*)\}(_[0-9]*)?(\[[0-9]*\])} $current_bit_name dummy part1 part2 part3]} {
					puts "current_bit_name $current_bit_name -- part1 $part1 -- part2 $part2 -- part3 $part3"
					set replaced_bit_name "$io_name_mapping_array($part1)${part2}${part3}"
			}
				


      set prot_plan_xml(${prefix_name}$replaced_bit_name,location) ${quartus_pin_prefix}[lindex $current_bit_info 0]
      puts "set prot_plan_xml(${prefix_name}$replaced_bit_name,location) ${quartus_pin_prefix}[lindex $current_bit_info 0]"
	    if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}${replaced_bit_name}] < 0}  {lappend prot_plan_xml(pin_list) ${prefix_name}$replaced_bit_name}
	    lappend prot_plan_xml(${prefix_name}$replaced_bit_name)  location

			if {![info exists lcell_paths_array($bit_type)]} { set lcell_paths_array($bit_type) ""}
			foreach item_to_set $lcell_paths_array($bit_type) {
				# Either absolute or LL placement. If LL put in LL region, otherwise do the clever assignments
				# replace %<value> in the path
				# items to replace:
				# %1 by group_number
				# %2+ by bit_number in the group shifted by the size of the group (so 0 would be 8 in x8)
				# %2 by the bit_number
				# %3 by family name dqs_group_family (this one should disappear by v2.2.0)
				# %4 by wrapper_name
				# %5 by qdrii_pin_prefix  (not used yet)
				set temp_path [subst $lcell_paths_array($item_to_set,path)]
#puts "\$lcell_paths_array($item_to_set,path) [subst $lcell_paths_array($item_to_set,path)]"
#puts "  \$lcell_paths_array($item_to_set,path) [set temp_var $lcell_paths_array($item_to_set,path)]"
#puts "    $temp_var"
#puts ">>>> $lcell_paths_array(general_path) >>>> $lcell_paths_array(dq_path)"
#exit 3
				set place_this_item 0
				set le_position_in_lab_is_relative 1
				set le_demote_to_lab $lcell_paths_array($item_to_set,le_demote_to_lab)

				set x_ord_offset 0
				set y_ord_offset 0
				if {$lcell_paths_array($item_to_set,specific_place) == 1} {
					# need to check if we want to put it or not
					if {[regexp "dq_enable(?:_reset)?" $item_to_set] && [lindex $current_bit_info 3] >= 0 } {
						set temp_path [regsub -all "(%1)" $temp_path $group_number]
						set temp_path [regsub -all "(%2\\+)" $temp_path $bit_number]
						set temp_path [regsub -all "(%2)" $temp_path [lindex $current_bit_info 3]]
						set temp_path [regsub -all "(%3)" $temp_path $dqs_group_family]
						set temp_path [regsub -all "(%4)" $temp_path ${user_assignment_array(wrapper_name)}]
						set temp_path [regsub -all "(%5)" $temp_path ${user_assignment_array(qdrii_pin_prefix)}]



						set place_this_item 1
						set le_position_in_lab_is_relative 0
						# need to fetch the offset here
						set x_ord_offset [lindex $current_bit_info 6]
						set y_ord_offset [lindex $current_bit_info 7]
					}
				} else {
					set temp_path [regsub -all "(%1)" $temp_path $group_number]
					set temp_path [regsub -all "(%2\\+)" $temp_path [expr {$bit_number +  ${user_assignment_array(mem_dq_per_cq)}}]]
					set temp_path [regsub -all "(%2)" $temp_path $bit_number]
					set temp_path [regsub -all "(%3)" $temp_path $dqs_group_family]
					set temp_path [regsub -all "(%4)" $temp_path ${user_assignment_array(wrapper_name)}]
					set temp_path [regsub -all "(%5)" $temp_path ${user_assignment_array(qdrii_pin_prefix)}]

					set place_this_item 1
					set x_ord_offset [lindex $current_bit_info 4]
					set y_ord_offset [lindex $current_bit_info 5]
				}


				if {$place_this_item} {
					if {${le_demote_to_lab} == 2} {
						if {[regexp "dq_enable(?:_reset)?" $item_to_set]} {
							puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"LL_MEMBER_OF\" -to \"$temp_path\" -entity \"\${top_level}\" -section_id \"${ll_region_name}_dqenable\" \"${ll_region_name}_dqenable\" \$add_remove_string"]\]"
						} else {
							puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"LL_MEMBER_OF\" -to \"$temp_path\" -entity \"\${top_level}\" -section_id \"${ll_region_name}\" \"${ll_region_name}\" \$add_remove_string"]\]"
						}

					} else {
						# here we go.
						# in_lab_offset
						# $lcell_placement_array($item_to_set) format:
						# $le_row_x $le_row_z $le_col_y $le_col_x $le_col_z
						# left
						set x_ord -1
						set y_ord -1
						set z_ord -1
						if {[regexp -nocase "\\d+L" $current_group_name]} {
							set x_ord [expr {[lindex $lcell_placement_array($item_to_set) 0] + $x_ord_offset }]
							set y_ord [expr {[lindex $current_bit_info 1] + $y_ord_offset }]
							set z_ord [expr {[lindex $lcell_placement_array($item_to_set) 1] + ($max_number_pattern_in_lab - [lindex $current_bit_info 2] -1 ) * $in_lab_offset * $le_position_in_lab_is_relative}]
						}
						# right
						if {[regexp -nocase "\\d+R" $current_group_name]} {
							set x_ord [expr { $user_assignment_array(max_column) - [lindex $lcell_placement_array($item_to_set) 0] + 1 + $x_ord_offset}]
							set y_ord [expr {[lindex $current_bit_info 1] + $y_ord_offset }]
							set z_ord [expr {[lindex $lcell_placement_array($item_to_set) 1] + ($max_number_pattern_in_lab - [lindex $current_bit_info 2] -1) * $in_lab_offset * $le_position_in_lab_is_relative}]
						}
						#top
						if {[regexp -nocase "\\d+T" $current_group_name]} {
							# should only apply for cyclone I and II
							if {([lindex $current_bit_info 1] <= $user_assignment_array(max_column) /2) || ($device_is_stratixii || $device_is_stratixii)} {
								set x_ord [expr {[lindex $current_bit_info 1] + [lindex $lcell_placement_array($item_to_set) 3] + + $x_ord_offset}]
							} else {
								set x_ord [expr {[lindex $current_bit_info 1] - [lindex $lcell_placement_array($item_to_set) 3] -1 + + $x_ord_offset}]
							}
							set y_ord [expr { ${user_assignment_array(max_row)} - [lindex $lcell_placement_array($item_to_set) 2] + 1 + $y_ord_offset}]
							set z_ord [expr {[lindex $lcell_placement_array($item_to_set) 4] + [lindex $current_bit_info 2] * $in_lab_offset * $le_position_in_lab_is_relative}]
						}
						#bottom
						if {[regexp -nocase "\\d+B" $current_group_name]} {
							# should only apply for cyclone I and II
							if {([lindex $current_bit_info 1] <= $user_assignment_array(max_column) /2) ||($device_is_stratixii || $device_is_stratix)} {
								set x_ord [expr {[lindex $current_bit_info 1] + [lindex $lcell_placement_array($item_to_set) 3] + $x_ord_offset}]
							} else {
								set x_ord [expr {[lindex $current_bit_info 1] - [lindex $lcell_placement_array($item_to_set) 3] -1 + $x_ord_offset}]
							}
							set y_ord [expr {[lindex $lcell_placement_array($item_to_set) 2] + $y_ord_offset}]
							set z_ord [expr {[lindex $lcell_placement_array($item_to_set) 4] + [lindex $current_bit_info 2] * $in_lab_offset * $le_position_in_lab_is_relative}]
						}

						if {${le_demote_to_lab} == 1} {
							puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -to \"$temp_path\" \"LAB_X${x_ord}_Y${y_ord}\" \$add_remove_string"]\]"
						} else {
							puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -to \"$temp_path\" \"LC_X${x_ord}_Y${y_ord}_N${z_ord}\" \$add_remove_string"]\]"
						}

						# Check placement is correct and do not overlap


					}
				}
			}

		}


}

if { $pin_file != "" } {
	puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	puts $out_tcl_id "${tab}# 			source the pin placement script for the address and command pins"
	puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"

	puts $out_tcl_id "${tab} if { \[file exists \$pin_file\] } {"
	puts $out_tcl_id "${tab}     source \$pin_file"
	puts $out_tcl_id "${tab} } else { "
	puts $out_tcl_id "${tab}     post_message -type critical_warning \"Internal Error: pin_file \$pin_file not found\""
	puts $out_tcl_id "${tab} }"
}

	puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	puts $out_tcl_id "${tab}# 			create the remove script"
	puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	puts $out_tcl_id {	if {$add_remove_string == ""} {
		set this_script_name [file tail [info script]]
		set output_script_name "remove_[file rootname $this_script_name]_[clock format [clock seconds] -format %Y_%m_%d___%H_%M][file extension $this_script_name]"
		set fileid [open [info script] r]
		set str ""
		append str "set add_remove_string \"-remove\"\n"
		append str "set do_analysis 0\n"
		append str "set check_path_from_report 0\n"
		append str "set hierarchy_path_to_instance $hierarchy_path_to_instance\n"
		append str "set top_level $top_level\n"
		while {[gets $fileid line] >= 0} {
			append str "$line\n"
		}
		close $fileid

		append str "\n\nset add_remove_string \"\"\n"
		append str "set do_analysis 1\n\n"
		set fileid [open $output_script_name w]
		puts $fileid $str
		set output_script_name "remove_[file rootname $this_script_name][file extension $this_script_name]"
		set fileid [open $output_script_name w]
		puts $fileid $str
		close $fileid
	}}

puts $out_tcl_id    "${tab}puts \" - All Done\"    "

#puts $out_tcl_id  "puts \"---------------------------------------------------------------------\n\""
puts $out_tcl_id  "${tab}puts \"---------------------------------------------------------------------\""
#close $out_tcl_id
if {$placement_error_flag == 1} {
	puts " - Placement errors."
} else {
	puts " - All Done."
}
puts $out_tcl_id  "${tab}}"
puts $out_tcl_id  "}"
close $out_tcl_id


set protocol_palnner_out_file "${user_assignment_array(wrapper_name)}.ppf"
set out_xml_id [open $protocol_palnner_out_file w]
puts $out_xml_id    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
puts $out_xml_id    "<pinplan specifies=\"external_ports\">"
puts $out_xml_id    "      <global>"
puts $out_xml_id    "      <block name=\"${user_assignment_array(wrapper_name)}\">"

  foreach pp_pin $prot_plan_xml(pin_list) {
      puts "pin_detected $pp_pin"
      puts $out_xml_id "                     <pin name=\"${user_assignment_array(wrapper_name)}_$pp_pin\""
      puts $out_xml_id "                     username=\"${user_assignment_array(wrapper_name)}_$pp_pin\""
      foreach pp_param $prot_plan_xml($pp_pin) {
          puts $out_xml_id "                     [string tolower $pp_param]=\"$prot_plan_xml($pp_pin,$pp_param)\""
      }                                                         
      puts $out_xml_id "                     scope=\"external\""
      puts $out_xml_id "                     />"
  }

puts $out_xml_id    "      </block>"
puts $out_xml_id    "      </global>"
puts $out_xml_id    "</pinplan>"
close $out_xml_id




