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

set fo_assignment_list ""
set io_assignment_list ""
set io_list ""

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
#          

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
				if {[regexp -nocase "(\\w+)\\s+((?:dq\[0-9\]+|qvld|dqs|rldm\[0-9\]?))\\s+(\\w+)\\s+(\\S+)\\s+(\\d+)\\s+(\\S+)\\s*(\\w+)\\s*(?:\-\-.*)?$" $in_line dummy user_secondary_function pin_name device_pin_name row_col_string lab_pos dq_enb_pair_string io_bank]} {
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
					lappend local_array($current_group,[string tolower $pin_name]) $device_pin_name $row_col $lab_pos $dq_enb_pair_number $x_ord_offset $y_ord_offset $dq_enb_x_ord_offset $dq_enb_y_ord_offset $io_bank
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
				if {[regexp -nocase "(max_pads_per_\\w+)\\s*(\\d*)\\s*" $in_line dummy param_name param_value]} {

					if {[info exists local_user_array([string tolower $param_name])]} {
						if {$param_value < $local_user_array([string tolower $param_name])} {
							#puts "This lcell_placement file is not suitable for this device/package combination"
						}
						set local_user_array([string tolower $param_name]) $param_value ; # swapping the value to use the one in the lcell_placement
					} else {
						puts "the parameter $param_name is missing for the device and package file"
					}
				}
				if {[regexp -nocase "(\\w+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\[-0-9\]+)\\s+(\\w+)\\s+(\\d)\\s+(?:\-\-.*)?" $in_line dummy le_name le_row_x le_row_z le_col_y le_col_x le_col_z le_pin_type le_demote_to_lab]} {
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
		    #puts  " - ERROR: Cannot read hdl path dat file file '$filename_in'"
		    #puts  " ------------------------------------\n"
		} else {
		    #puts  " - INFO: hdl path dat file file '$filename_in' does not exist"
		    #puts  " ------------------------------------\n"
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

				if {[regexp -nocase {(list|width|map_name)\s+(\w+)\s*=([ a-zA-Z0-9_\/\t\.]*)(?:\-\-.*)?} $in_line dummy param_type param_name param_value]} {
					if {[regexp {\s+[0-9]\s+} $param_value dummy param1]} {
						set local_array([string tolower $param_name]) [trim $param_value]
					} else {
						set local_array([string tolower $param_name]) [string tolower [string trim $param_value]]
					}
					
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
						} elseif {[regexp {(\S*)\s+/\s+(\S*)} $param_value dummy param1 param2]} {
							set param1 [string trim $param1]
							set param2 [string trim $param2]
							puts "$param1 $param2"
							# check if the second param is an integer
							if  {[regexp {^\d+$} $param2]} {
								set new_param_value [expr {$local_user_array([string tolower $param1])/$param2}]
							} else {
								set new_param_value [expr {$local_user_array([string tolower $param1])/$local_user_array([string tolower $param2])}]
							}
						} else {
							if {[regexp {([0-9]+)} $param_value dummy param1]} {
								set new_param_value $dummy
							} else {
								set new_param_value $local_user_array([string tolower $param_value])
							}
						}

#						if {[info exists local_user_array([string tolower $param_value])] || ([info exists local_user_array([string tolower $param1])] && [info exists local_user_array([string tolower $param2])])} {}
							# only apply if the paramter exists in the user_assignment file
							set local_array(width,[string tolower $param_name]) $new_param_value
#						{}

					}
					if {[string tolower $param_type] == "map_name"} {
						set param_value [string trim $param_value]
						set local_io_name_mapping_array([string tolower $param_name]) $param_value
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
#          check_lcell_placement
# -------------------------------------------------------------------------------------------------

proc check_lcell_placement {lab_array_name le_array_name item_to_place loc_x loc_y loc_z ddr_region pin_number demote_le_to_lab user_assignment_array_name device_family} {

	upvar $lab_array_name local_lab_array
	upvar $le_array_name local_le_array
	upvar $user_assignment_array_name local_user_array
	set returned_value 0

	set clock_name none


	# add the new item to the database. Check that no item has been placed there already.
	# Check clocks
	# first part, if we only assign to LAB instead of LE, we need to check we don't overfill the LAB
	# else, we check on an LE basis

	if {[string compare $item_to_place  "dqs_and"]} {
		lappend local_le_array($loc_x,$loc_y,in_lab) ${item_to_place}_${ddr_region}_${pin_number}
		if {[info exists local_le_array($loc_x,$loc_y,in_lab_count)]} {
			incr local_le_array($loc_x,$loc_y,in_lab_count)
		} else {
			set local_le_array($loc_x,$loc_y,in_lab_count) 1
		}
		if {$local_le_array($loc_x,$loc_y,in_lab_count) > ${local_user_array(le_per_lab)}} {
			set returned_value [expr {$returned_value + 8}]
			puts "Error, too many LEs in LAB $loc_x $loc_y ($local_le_array($loc_x,$loc_y,in_lab_count)) -- $local_le_array($loc_x,$loc_y,in_lab)"
		}
	}
	if {$demote_le_to_lab == 0} {

		if {$loc_z >= ${local_user_array(le_per_lab)}} {
			set returned_value [expr {$returned_value + 8}]
			puts "Error, Position in LAB $loc_z for ${item_to_place}_${ddr_region} exceed maximum number of LE"
		}
		if {[info exists local_le_array($loc_x,$loc_y,$loc_z)] && [string compare $item_to_place  "dqs_and"]} {
			set returned_value [expr {$returned_value + 1}]
			puts "Error -- Placement -- trying to place ${item_to_place}_${ddr_region}_${pin_number} at $loc_x $loc_y $loc_z. Already used by $local_le_array($loc_x,$loc_y,$loc_z)"
		}
		lappend local_le_array($loc_x,$loc_y,$loc_z) ${item_to_place}_${ddr_region}_${pin_number}
	}

	if {[string compare $item_to_place "dqs_mux"  		] == 0} { set clock_name system_clk 						}
	if {[string compare $item_to_place "dq_mux"  		] == 0} { set clock_name clk_write 							}
	if {[string compare $item_to_place "dm_mux"  		] == 0} { set clock_name clk_write 							}
	if {[string compare $item_to_place "dqs_bo"  		] == 0} { set clock_name system_clk 						}
	if {[string compare $item_to_place "dq_bo"  		] == 0} { set clock_name clk_write 							}
	if {[string compare $item_to_place "dm_bo"  		] == 0} { set clock_name clk_write 							}
	if {[string compare $item_to_place "dq_aoe"  		] == 0} { set clock_name clk_write							}
	if {[string compare $item_to_place "dqs_aoe"  		] == 0} { set clock_name system_clk 						}
	if {[string compare $item_to_place "dqs_boe"  		] == 0} { set clock_name system_clk_n						}
	if {[string compare $item_to_place "dq_ai"  		] == 0} { set clock_name dqs${ddr_region}_clk 				}
	if {[string compare $item_to_place "dq_bi"  		] == 0} { set clock_name dqs${ddr_region}_clk_n 			}
	if {[string compare $item_to_place "dq_ci"  		] == 0} { set clock_name dqs${ddr_region}_clk				}
	if {[string compare $item_to_place "dq_s_ai"  		] == 0} { set clock_name resynch_clk 						}
	if {[string compare $item_to_place "dq_s_bi"  		] == 0} { set clock_name resynch_clk 						}
	if {[string compare $item_to_place "dq_enable"  	] == 0} { set clock_name dqs${ddr_region}_clk_with_enable 	}
	if {[string compare $item_to_place "dq_enable_reset"] == 0} { set clock_name postamble_clk 						}

	if {$clock_name != "none" } {
		if {[info exists local_lab_array($loc_x,$loc_y,number)]} {
			if {[lsearch $local_lab_array($loc_x,$loc_y,clock_name) $clock_name ] < 0} {
				incr local_lab_array($loc_x,$loc_y,number)
				lappend local_lab_array($loc_x,$loc_y,clock_name) $clock_name
				if {$local_lab_array($loc_x,$loc_y,number) > 2} {
					set returned_value [expr {$returned_value + 2}]
					puts "Error -- Clock --  trying to place $clock_name ($item_to_place) at $loc_x $loc_y. Already used by $local_lab_array($loc_x,$loc_y,clock_name)"
				}
			}
		} else {
			set local_lab_array($loc_x,$loc_y,number) 1
			lappend local_lab_array($loc_x,$loc_y,clock_name) $clock_name
		}

	}



	# here we need a table per lab checking if we have the extra special anti glich latch
	# there is one per dq serie and 1 per dqs.
	# then it needs to be added to the lab for checking the number of LE/LAB
	# this applies to Cyclone II only

	if {[string compare $item_to_place  "dq_aoe"] == 0 || [string compare $item_to_place  "dqs_aoe"] == 0 && [string compare $device_family  "cycloneii"] == 0} {
		if {![info exists local_lab_array($loc_x,$loc_y,$item_to_place)]} {
			set local_lab_array($loc_x,$loc_y,$item_to_place) 1
			lappend local_le_array($loc_x,$loc_y,in_lab) ${item_to_place}_${ddr_region}_${pin_number}_no_glitch
			incr local_le_array($loc_x,$loc_y,in_lab_count)
			if {$local_le_array($loc_x,$loc_y,in_lab_count) > ${local_user_array(le_per_lab)}} {
				set returned_value [expr {$returned_value + 8}]
				puts "Error, too many LEs in LAB $loc_x $loc_y ($local_le_array($loc_x,$loc_y,in_lab_count)) -- $local_le_array($loc_x,$loc_y,in_lab)"
			}
		}
	}




	return $returned_value

}

# -------------------------------------------------------------------------------------------------
#          print_lcell_placement
# -------------------------------------------------------------------------------------------------

proc print_lcell_placement {le_array_name lab_array_name user_assignment_array_name lcell_dq_dqs_pins_array_name debug_filename} {

	upvar $le_array_name local_le_array
	upvar $lab_array_name local_lab_array
	upvar $user_assignment_array_name local_user_array
	upvar $lcell_dq_dqs_pins_array_name local_lcell_array

	set debug_id [open $debug_filename w]

	set temp_line0 ",,,"
	set temp_line1 ",,,"
	set temp_line2 ",,,"
	for {set i 1} {$i <= $local_user_array(max_column)} {incr i} {
		append temp_line0 "[expr {($local_user_array(max_column) - $i )/2}],"
		append temp_line1 "$i,"
		if {[info exists local_lcell_array(row_col_pad_list,${i}t)]} {
			append temp_line2 "$local_lcell_array(row_col_pad_list,${i}t),"
		} else {
			append temp_line2 ","
		}
	}
	puts $debug_id "$temp_line0,"
	puts $debug_id "$temp_line1,"
	puts $debug_id "$temp_line2,"

	for {set j $local_user_array(max_row)} {$j >= 1} {incr j -1} {
		set temp_line "[expr {$local_user_array(max_row) - $j}],$j,"
		if {[info exists local_lcell_array(row_col_pad_list,${j}l)]} {
			append temp_line "$local_lcell_array(row_col_pad_list,${j}l),"
		} else {
			append temp_line ","
		}
		for {set i 1} {$i <= $local_user_array(max_column)} {incr i} {
			if {[info exists local_le_array($i,$j,in_lab)]} {
				append temp_line "$local_le_array($i,$j,in_lab) -- $local_lab_array($i,$j,clock_name),"
			} else {
				append temp_line ","
			}
		}
		if {[info exists local_lcell_array(row_col_pad_list,${j}r)]} {
			append temp_line "$local_lcell_array(row_col_pad_list,${j}r),"
		} else {
			append temp_line ","
		}
		append temp_line "$j,[expr {$local_user_array(max_row) - $j}],"
		puts $debug_id "$temp_line"
	}
	
	set temp_line2 ",,,"
	for {set i 1} {$i <= $local_user_array(max_column)} {incr i} {
		if {[info exists local_lcell_array(row_col_pad_list,${i}b)]} {
			append temp_line2 "$local_lcell_array(row_col_pad_list,${i}b),"
		} else {
			append temp_line2 ","
		}
	}
	puts $debug_id "$temp_line2"
	puts $debug_id "$temp_line1,"
	puts $debug_id "$temp_line0,"

	close $debug_id
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
#puts "dat_path $dat_path"

if {![info exists user_assignment_file]} {
    if {$argc > 0 } {
    	set user_assignment_file [lindex $argv 0]
    	#puts "$user_assignment_file"
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
# there we know if we are in nondqs mode
#puts "CAPTURE CLOCK: ${user_assignment_array(enable_capture_clk)}"

if {[regexp -nocase "true" ${user_assignment_array(enable_capture_clk)}]} {
	set nondqs_string "nondqs_"
	if {[info exists {user_assignment_array(migratable_bytegroups)}] && [regexp -nocase "false" ${user_assignment_array(migratable_bytegroups)}]} {
		append nondqs_string "nonmig_"
	} else {
		append nondqs_string "mig_"
	}

} else {
	set nondqs_string ""
}

if {${user_assignment_array(mem_dq_per_dqs)} == 8} {
	set dq_per_dqs_extn "8"
} elseif {${user_assignment_array(mem_dq_per_dqs)} == 9} {
	set dq_per_dqs_extn "9"
} elseif {${user_assignment_array(mem_dq_per_dqs)} == 16} {
	set dq_per_dqs_extn "16"
} elseif {${user_assignment_array(mem_dq_per_dqs)} == 18} {
	set dq_per_dqs_extn "18"
}

#puts ${user_assignment_array(mem_dq_per_dqs)}
#puts $dq_per_dqs_extn

read_device_file user_assignment_array $dat_path/devices.dat

set skip_placement [read_device_package_file lcell_dq_dqs_pins_array  $dat_path/${user_assignment_array(device)}_${user_assignment_array(package)}_${nondqs_string}x${dq_per_dqs_extn}_v${device_package_file_version}.dat user_assignment_array]

if {!$skip_placement} {read_lcell_placement_file lcell_placement_array $dat_path/lcell_placement_${user_assignment_array(best_placement_constraint_file)}_v${lcell_placement_file_version}.dat user_assignment_array}

read_hdl_path_file lcell_paths_array $dat_path/hdl_path_names_v${hdl_path_file_version}.dat lcell_placement_array user_assignment_array $skip_placement 2

read_io_type_file io_path_array $dat_path/${user_assignment_array(memory_type)}_iotype.dat io_name_mapping_array user_assignment_array 2
#puts "MEM ${user_assignment_array(memory_type)}"

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
	} elseif {[regexp -nocase hc ${user_assignment_array(device)} ] == 1} {
		set device_is_stratixii 1
		set device_family_name "HardCopy II"
		set pll_family stratix
		set dqs_group_family stratixii
		set le_per_lab 10 ; # unused - cyclone only
		set device_speed_grade C4
	} else {
		puts " - ERROR: Illegal family ${user_assignment_array(device)}"
		puts " ------------------------------------------------------------------\n"
		exit 1
	}

	set prefix_name ${user_assignment_array(ddr_pin_prefix)}

	# read the io_type_file for the correct device family if it exists
	read_io_type_file io_path_array $dat_path/${user_assignment_array(memory_type)}_iotype_${dqs_group_family}.dat io_name_mapping_array user_assignment_array 0
	read_hdl_path_file lcell_paths_array $dat_path/hdl_path_names_${dqs_group_family}_v${hdl_path_file_version}.dat lcell_placement_array user_assignment_array $skip_placement 0

	# modify the clock names to match the input from the MegaWizard
	modify_clock_names user_assignment_array io_name_mapping_array

	# set the number of dm pins
	set dm_per_group 1
	
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

    puts $out_tcl_id  "#\n# Auto-generated RLDRAM II Controller Compiler Constraint Script \n#"
    puts $out_tcl_id  "# (C) COPYRIGHT 2005 ALTERA CORPORATION "
    puts $out_tcl_id  "# ALL RIGHTS RESERVED \n#"
    puts $out_tcl_id  "#------------------------------------------------------------------------"
    puts $out_tcl_id  "# This script will apply various placement, I/O standard and other       "
    puts $out_tcl_id  "# constraints to the current project. It is generated for a specific     "
    puts $out_tcl_id  "# instance of the RLDRAM II Controller. It will apply constraints        "
    puts $out_tcl_id  "# according to the settings that were chosen in the MegaWizard and can   "
    puts $out_tcl_id  "# only be used to constrain this particular instance.                    "
    puts $out_tcl_id  "#------------------------------------------------------------------------\n\n"

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

	set tab "    "
	set top_level ${user_assignment_array(toplevel_name)}
	set prefix_name ${user_assignment_array(ddr_pin_prefix)}
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
	if {[regexp -nocase "true" $user_assignment_array(manual_hierarchy_control)]} {set auto_hierarchy 0} else {set auto_hierarchy 1}
	puts $out_tcl_id "${tab}set do_analysis                        $auto_hierarchy \; # only set this to 0 if you already have run analysis on your project. It can stay set to 1."
	puts $out_tcl_id "${tab}set check_path_from_report             $auto_hierarchy \; # only set this to 0 if you already have run analysis on your project. It can stay set to 1."
	puts $out_tcl_id "${tab}###########################################################################\n"

# -------------------------------------------------------------------------------------------------
# 			Write required packages and warning messages
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  {puts "\n*********************************************************************"}
	puts $out_tcl_id  {puts "*                RLDRAM II Controller Compiler                      *"}
	puts $out_tcl_id  {puts "*   Applying the constraints for the datapath in the your MegaCore  *"}
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

	puts $out_tcl_id  {    proc check_paths {given_datapath_name do_analysis} {
		puts                    "\nNote: The add_constraints script is searching the correct path to the datapath in your MegaCore"
	    if {$do_analysis} {puts "      Analysis and Elaboration will be run and will take some time...\n"}

        set top_level ""

        if {$do_analysis} {

            set err [catch {execute_flow -analysis_and_elaboration } result]
            if {$err} {
                post_message -type error "Analysis and Elaboration failed. The constraints script will not be able to add any constraints."
                puts "ERROR: Analysis and Elaboration failed. The constraints script will not be able to add any constraints."
                error $result
            } else {
                puts "Analysis and Elaboration was successful.\n"

                # get the top level name from Quartus
                set top_level [get_name_info -info entity_name [get_top_level_entity]]
                #puts "TOP LEVEL NAME                = $top_level\n"
            }
        }

        set num_matches 0;
        set datapath_name_list ""
        array set datapath_hier_path {}


        # This get_names will return all the datapaths and their submodules - we'll extract just the datapath tops later
        set err [catch {set datapath_names [get_names -filter *auk_rldramii_datapath* -node_type hierarchy]} msg]
        if {$err} { puts "ERROR: $msg\n"}

	#puts "Datapath names: $datapath_names"
		
        foreach_in_collection found_datapath $datapath_names {

	    set item_to_test [get_name_info -info full_path $found_datapath]
	    #puts $item_to_test

            # Extract just the datapath top levels (ie not all their submodule) by looking for instance name are at the end of the string
            if {[regexp -nocase {^(.*\|)(\S+)_auk_rldramii_datapath:\w+$} $item_to_test dummy hier_path datapath_name]} {

                # ok, so we found one. Add it to the list but check that we haven't already found it
                if {[info exists datapath_hier_path($datapath_name)]} {
                    if {$datapath_hier_path($datapath_name) != $hier_path} {
                        puts "ERROR : You have instantiated the same datapath more than once in the same design. You cannot instantiate the same datapath"
                        puts "        more than once since the constraints are location specific. Please modify the design so that each datapath is unique."
                    }
                }
		if {[lsearch $datapath_name_list $datapath_name] < 0} {
		    lappend datapath_name_list $datapath_name
                    #puts "DNL $datapath_name_list"
                    set datapath_hier_path($datapath_name) $hier_path
                    incr num_matches;
                }

                #puts "Full path to datapath module  = $hier_path"
                #puts "Found datapath instance       = $datapath_name\n"
            }
        }
	
	set dqs_err [catch {set dqs_group_path_names [get_names -filter *${given_datapath_name}_auk_rldramii_dqs_group* -node_type hierarchy]} msg]
	if {$dqs_err} { puts "ERROR: $msg\n"}
	
	foreach_in_collection found_dqs_group $dqs_group_path_names {
	
	     set dqs_group_item_to_test [get_name_info -info full_path $found_dqs_group]
	     #puts $dqs_group_item_to_test
	     
	     if {[regexp -nocase {^(.*)(\S+)_dqs_group} $dqs_group_item_to_test dqs_group_hier_path]} {
		     #puts $dqs_group_hier_path
	     }
	}
	
	
	
	if {[lsearch $datapath_name_list $given_datapath_name] < 0} {
	    puts "WARNING: Name: $datapath_name_list Given:  $given_datapath_name\n";
	    set warn_str "The expected name of the datapath (${given_datapath_name}_auk_rldramii_datapath) doesn't match the names found in the project (${datapath_name_list})."
            puts "WARNING: $warn_str"; post_message -type warning $warn_str
            set warn_str "This suggest that you have renamed the entity or module containing the datapath and the constraints will therefore not be correctly applied.\n"
            puts "WARNING: $warn_str"; post_message -type warning $warn_str

            set returned_path "ERROR"
            set path_correct 0
		} else {
            set path_correct 1
			set returned_path $datapath_hier_path($given_datapath_name)
            puts "Note: found ${given_datapath_name}_auk_rldramii_datapath in $datapath_hier_path($given_datapath_name)"
		}

        if {($num_matches > 1)} {
            puts "Note: found $num_matches datapath modules in top level entity \"$top_level\"\n";
        }

        set return_list ""
        lappend return_list $path_correct $top_level $returned_path $dqs_group_hier_path

        return $return_list
    }
	}

# -------------------------------------------------------------------------------------------------
# 			sets more parameters
# -------------------------------------------------------------------------------------------------
    
    puts $out_tcl_id  	"\n###########################################################################"
    puts $out_tcl_id  	"#     Get paths and check them   "
    puts $out_tcl_id  	"###########################################################################\n"
    puts $out_tcl_id 	"${tab}if \{!\[info exists add_remove_string\]\} \{set  add_remove_string \"\"\} "
    puts $out_tcl_id 	"${tab}set wrapper_name         $user_assignment_array(wrapper_name) "
    puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "#                     Check that the device is correct        "
    puts $out_tcl_id  "###########################################################################\n"
	
    puts $out_tcl_id 	"if \{\$add_remove_string == \"\"\} \{"
    puts $out_tcl_id    "${tab}set current_project_device \[get_global_assignment -name DEVICE\]"
    puts $out_tcl_id    "${tab}if {\[regexp -nocase ${user_assignment_array(device)}${user_assignment_array(package)} \$current_project_device\] == 0} {"
    puts $out_tcl_id    "${tab}${tab}puts  \"*********************************************************************\""
    puts $out_tcl_id    "${tab}${tab}puts  \" WARNING: The device used by the MegaWizard no longer matches the    \""
    puts $out_tcl_id    "${tab}${tab}puts  \" device selected in Quartus II. Please run the MegaWizard again to   \""
    puts $out_tcl_id    "${tab}${tab}puts  \" ensure your constraints are correct for your chosen device.         \""
    puts $out_tcl_id    "${tab}${tab}puts  \"*********************************************************************\""
    puts $out_tcl_id    "${tab}${tab}error \"The device expected by the constraint script (${user_assignment_array(device)}${user_assignment_array(package)}) does not match the device currently selected in Quartus II.\""
    puts $out_tcl_id    "${tab} \}"
    puts $out_tcl_id 	"\}"



	puts $out_tcl_id {	#if {$add_remove_string == ""} {


		if {$check_path_from_report} {
			set post_analysis_variables [check_paths $wrapper_name $do_analysis]
			if {[lindex $post_analysis_variables 0] == 0} {
                puts "Error. Either Analysis & Elaboration failed or the script could not find your variation, check your Processing report panel for information. This script will now end without adding any constraints.";
                error       "Either Analysis & Elaboration failed or the script could not find your variation, check your Processing report panel for information. This script will now end without adding any constraints."
            }
			set top_level                   [lindex $post_analysis_variables 1]
			set hierarchy_path_to_instance  [lindex $post_analysis_variables 2]
			set hierarchy_path_to_dqs_group [lindex $post_analysis_variables 3]
			#set wrapper_name                [lindex $post_analysis_variables 4]
		} else {
            # don't extract path from report so use wizard entry for the path to the datapath
            if {![info exists hierarchy_path_to_instance]} {
                set hierarchy_path_to_instance         $wizard_hier_path
		set hierarchy_path_to_dqs_group        ${wizard_hier_path}${wrapper_name}_auk_rldramii_dqs_group:auk_rldramii_dqs_group

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
	#}
	}


# -------------------------------------------------------------------------------------------------
# 			Print a few messages
# -------------------------------------------------------------------------------------------------
	puts $out_tcl_id  "\n###########################################################################"
    puts $out_tcl_id  "# "
    puts $out_tcl_id  "#    Actually apply the constraints         "
    puts $out_tcl_id  "# "
	puts $out_tcl_id  "###########################################################################\n"

	puts $out_tcl_id  {if {$add_remove_string == "-remove"} {set apply_remove_string "Removing"} else {set apply_remove_string "Applying"}}
	puts $out_tcl_id  {puts "---------------------------------------------------------------------"}
    puts $out_tcl_id  {puts "-  $apply_remove_string constraints to datapath ${wrapper_name}_auk_rldramii "}
    puts $out_tcl_id  {puts "-  Path to the datapath: ${hierarchy_path_to_instance}  "}
	puts $out_tcl_id  {puts "---------------------------------------------------------------------\n"}

# -------------------------------------------------------------------------------------------------
# 			Device wide constraints
# -------------------------------------------------------------------------------------------------

set wrapper_name ${user_assignment_array(wrapper_name)}
#set number_string ""
set prot_plan_xml(pin_list) ""

############### Protocol planner pin direction assignments
if {$user_assignment_array(type) == "cio"} {
	lappend io_assignment_list "prot_plan_bidirectional_pin_list" 		"direction"	"bidir" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
} else {
	lappend io_assignment_list "prot_plan_sio_output_pin_list" 		"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
	lappend io_assignment_list "prot_plan_sio_input_pin_list"	 	"direction"	"input" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
}

if {$user_assignment_array(enable_dm_pins) == "true"} {
	lappend io_assignment_list "prot_plan_dm_output_pin_list" 		"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
}

if {$user_assignment_array(number_addr_cmd_buses) == "2"} {
	lappend io_assignment_list "prot_plan_output_2_addr_cmd_pin_list"	"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
} else {
	lappend io_assignment_list "prot_plan_output_1_addr_cmd_pin_list"	"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
}

if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
	lappend io_assignment_list "prot_plan_dqs_bidirectional_pin_list"	"direction"	"bidir" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
} else {
	lappend io_assignment_list "prot_plan_fbclk_pin_list"			"direction"	"input" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
}

lappend io_assignment_list "prot_plan_qvld_input_pin_list"			"direction"	"input" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."


if {$user_assignment_array(ddio_memory_clocks) == "true"} {
	lappend io_assignment_list "prot_plan_clk_output_pin_list"		"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
} else {
	#lappend io_assignment_list "prot_plan_diff_clk_output_pin_list"		"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
    lappend io_assignment_list "prot_plan_clk_output_pin_list"		"direction"	"output" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
}


# device wide constraints such as IO style, clock, pll and the likes
    #puts $out_tcl_id  "${tab}set dqs_group_path \$\{hierarchy_path_to_instance}auk_rldramii_datapath:rldramii_io"
    #puts $out_tcl_id   "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -name \"REMOVE_DUPLICATE_REGISTERS\" -to \"\${dqs_group_path}\" -entity \"\${top_level}\" \"Off\"	\$add_remove_string"]\]"
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string output enable groups for \${top_level}\"    "
    # CIO mode
    if {$user_assignment_array(type) == "cio"} {
	    if {$user_assignment_array(enable_dm_pins) == "true"} {
		    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${dm_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    }
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${dq_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${qvld_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    #if {$user_assignment_array(enable_capture_clk) == "false"} {
	    #	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${dqs_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    #}
	        
    } else {
	    if {$user_assignment_array(enable_dm_pins) == "true"} {
		    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${dm_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    }
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${d_pin_name}\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${q_pin_name}\" -entity \"\${top_level}\" \"2\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${qvld_pin_name}\" -entity \"\${top_level}\" \"2\" \$add_remove_string"]\]"
	    if {$user_assignment_array(enable_capture_clk) == "false"} {
		    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"OUTPUT_ENABLE_GROUP\" -to \"\${prefix_name}\${dqs_pin_name}\" -entity \"\${top_level}\" \"2\" \$add_remove_string"]\]"	    
	    }
    }	    
    
    
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string fast output registers for \${top_level}\"    "    	
    lappend fo_assignment_list "fast_output_reg_pin_list" 		"FAST_OUTPUT_REGISTER"	"ON" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
    
    if {$user_assignment_array(number_addr_cmd_buses) == "2"} {
	    lappend fo_assignment_list "fast_output_reg_1_pin_list" 		"FAST_OUTPUT_REGISTER"	"ON" 	"\\\${prefix_name}\\\${\${pin}}"	"\\\${top_level}"	"\$apply_remove_string fast output register assignments (addr/cmd) .."
    }
    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"DISABLE_DA_RULE\" -to \"\${prefix_name}\qk*\" -entity \"\${top_level}\" \"C105\" \$add_remove_string"]\]"
    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"DISABLE_DA_RULE\" -to \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"C106\" \$add_remove_string"]\]"

    if {$user_assignment_array(family) == "stratixii"} {
        puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"DISABLE_DA_RULE\" -to \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"C106\" \$add_remove_string"]\]"
    } elseif {$user_assignment_array(family) == "stratixiigx"} {
        puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"DISABLE_DA_RULE\" -to \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"C106\" \$add_remove_string"]\]"
    } elseif {$user_assignment_array(family) == "hardcopyii"} {
        puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"DISABLE_DA_RULE\" -to \"rldramii_pll_hardcopyii:g_hardcopyii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"C106\" \$add_remove_string"]\]"
    }           
           
    if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
        if {$user_assignment_array(family) == "stratixii"} {
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"${prefix_name}\qk\" -to \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"${prefix_name}\qk\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
        } elseif {$user_assignment_array(family) == "stratixiigx"} {
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"${prefix_name}\qk\" -to \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"${prefix_name}\qk\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
        } elseif {$user_assignment_array(family) == "hardcopyii"} {
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"${prefix_name}\qk\" -to \"rldramii_pll_hardcopyii:g_hardcopyii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_hardcopyii:g_hardcopyii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"${prefix_name}\qk\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
        }
    } else {
        if {$user_assignment_array(family) == "stratixii"} {
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"${prefix_name}fb_clk_in\" -to \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"rldramii_fbpll_stratixii:g_stratixii_fbpll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
	    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"${prefix_name}fb_clk_in\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
        } elseif {$user_assignment_array(family) == "stratixiigx"} {
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"${prefix_name}fb_clk_in\" -to \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
            puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"rldramii_fbpll_stratixiigx:g_stratixiigx_fbpll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
	    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"rldramii_pll_stratixiigx:g_stratixiigx_pll_rldramii_pll_inst|altpll:altpll_component|_clk0\" -to \"${prefix_name}fb_clk_in\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
        }
    }
    
    
    
    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\" -from \"reset_n_read_clk_r2\" -to \"\*\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
    #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CUT\"  -to \"\${wrapper_name}_example_driver:\${wrapper_name}_driver|local_init_done_r1\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
    
    if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
        puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${wrapper_name}_example_driver:\${wrapper_name}_driver|local_init_done_r2\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
    }    
        
    
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string remove duplicate registers to off for \${top_level}\"    "
    puts $out_tcl_id  "${tab}set dqs_group_path \$\{hierarchy_path_to_instance}auk_rldramii_datapath:rldramii_io"
    
    # Add constraints to controller
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string constraints to controller\"    "
    puts $out_tcl_id  "${tab}set controller_path \$\{wrapper_name}_wrapper:${wrapper_name}|${wrapper_name}_auk_rldramii_controller_ipfs_wrapper:rldramii_control|auk_rldramii_controller:rldramii_control|"
    #puts $out_tcl_id  "${tab}set controller_path \$\{wrapper_name}_auk_rldramii_datapath:${wrapper_name}|${wrapper_name}_auk_rldramii_controller_ipfs_wrapper:rldramii_control|auk_rldramii_controller:rldramii_control|"
    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Preserve Registers\" -to \"\${controller_path}doing_wr\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Preserve Registers\" -to \"\${controller_path}wdata_valid\" -entity \"\${top_level}\" \"ON\" \$add_remove_string"]\]"
    
    if {$user_assignment_array(addr_cmd_negedge) == "true"} {
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Maximum Fan-Out\" -to \"\${controller_path}control_we_n\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Maximum Fan-Out\" -to \"\${controller_path}control_cs_n\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Maximum Fan-Out\" -to \"\${controller_path}control_ref_n\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Maximum Fan-Out\" -to \"\${controller_path}control_ba\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	    puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"Maximum Fan-Out\" -to \"\${controller_path}control_a\" -entity \"\${top_level}\" \"1\" \$add_remove_string"]\]"
	
    }
         
    #if {![check_using_side user_assignment_array]} {
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string io standards for \${top_level}\"    "

        
       if {$user_assignment_array(memory_interface_voltage) == "1.8"} {
	       
	    if {$user_assignment_array(enable_dm_pins) == "true"} {
		    lappend assignment_list "hstl_dm_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.8-V HSTL Class I"
		    lappend io_assignment_list "hstl_dm_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.8-V HSTL Class I"
	    }
	    lappend assignment_list "hstl_pin_list" 				"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.8-V HSTL Class I"
	    lappend io_assignment_list "hstl_pin_list" 				"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.8-V HSTL Class I"
	    
	    if {$user_assignment_array(ddio_memory_clocks) == "true"} {
	    	lappend assignment_list "clk_hstl_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            lappend io_assignment_list "clk_hstl_pin_list" 			"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
	    } else {
	    	#lappend assignment_list "diff_clk_hstl_pin_list" 		"IO_STANDARD" 			"Differential 1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            #lappend io_assignment_list "diff_clk_hstl_pin_list" 	"io_standard" 			"Differential 1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            #lappend assignment_list "diff_clk_hstl_pin_list" 		"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            #lappend io_assignment_list "diff_clk_hstl_pin_list" 	"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            lappend assignment_list "clk_hstl_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
            lappend io_assignment_list "clk_hstl_pin_list" 			"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
	    }
	    
	    
	    if {$user_assignment_array(number_addr_cmd_buses) == "2"} {
		    lappend assignment_list "hstl_pin_1_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string address/command IO standard assignment for 1.8-V HSTL Class I"
		    lappend io_assignment_list "hstl_pin_1_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string address/command IO standard assignment for 1.8-V HSTL Class I"
	    }
	    
	    if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
		    lappend assignment_list "dqs_hstl_pin_list" 		"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQS IO standard assignment for 1.8-V HSTL Class I"
		    lappend io_assignment_list "dqs_hstl_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQS IO standard assignment for 1.8-V HSTL Class I"
	    } else {
		    lappend assignment_list "fb_clk_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string fedback clock IO standard assignment for 1.8-V HSTL Class I"
		    lappend io_assignment_list "fb_clk_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string fedback clock IO standard assignment for 1.8-V HSTL Class I"
            }
	       
    	    if {![check_using_side user_assignment_array]} {
		    if {$user_assignment_array(type) == "cio"} {
			lappend assignment_list "cio_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class II" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class II"
			lappend io_assignment_list "cio_pin_list" 		"io_standard" 			"1.8-V HSTL Class II" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class II"
		    } else {
			lappend assignment_list "sio_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
			lappend io_assignment_list "sio_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"			
		    }
	    } else {
		    if {$user_assignment_array(type) == "cio"} {
			lappend assignment_list "cio_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
			lappend io_assignment_list "cio_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
		    } else {
			lappend assignment_list "sio_pin_list" 			"IO_STANDARD" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
			lappend io_assignment_list "sio_pin_list" 		"io_standard" 			"1.8-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.8-V HSTL Class I"
		    }
	    }
    } else {
	    if {$user_assignment_array(enable_dm_pins) == "true"} {
		    lappend assignment_list "hstl_dm_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.5-V HSTL Class I"
		    lappend io_assignment_list "hstl_dm_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.5-V HSTL Class I"
	    }
	    lappend assignment_list "hstl_pin_list" 				"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.5-V HSTL Class I"
	    lappend io_assignment_list "hstl_pin_list" 				"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}" 	"-" 	"\$apply_remove_string IO standard assignment for 1.5-V HSTL Class I"
	    
	    if {$user_assignment_array(ddio_memory_clocks) == "true"} {
	    	lappend assignment_list "clk_hstl_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            lappend io_assignment_list "clk_hstl_pin_list" 			"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
	    } else {
	    	#lappend assignment_list "diff_clk_hstl_pin_list" 		"IO_STANDARD" 			"Differential 1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            #lappend io_assignment_list "diff_clk_hstl_pin_list"     "io_standard" 			"Differential 1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            #lappend assignment_list "diff_clk_hstl_pin_list" 		"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            #lappend io_assignment_list "diff_clk_hstl_pin_list"     "io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            lappend assignment_list "clk_hstl_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
            lappend io_assignment_list "clk_hstl_pin_list" 			"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string clock IO standard assignment for 1.5-V HSTL Class I"
	    }
	    
	    if {$user_assignment_array(number_addr_cmd_buses) == "2"} {
		    lappend assignment_list "hstl_pin_1_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string address/command IO standard assignment for 1.5-V HSTL Class I"
		    lappend io_assignment_list "hstl_pin_1_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string address/command IO standard assignment for 1.5-V HSTL Class I"
	    }
	    
	    if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
		    lappend assignment_list "dqs_hstl_pin_list" 		"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQS IO standard assignment for 1.5-V HSTL Class I"
		    lappend io_assignment_list "dqs_hstl_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQS IO standard assignment for 1.5-V HSTL Class I"
	    } else {
		    lappend assignment_list "fb_clk_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string fedback clock IO standard assignment for 1.5-V HSTL Class I"
		    lappend io_assignment_list "fb_clk_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string fedback clock IO standard assignment for 1.5-V HSTL Class I"
	    }
	    
	    if {![check_using_side user_assignment_array]} {
		    if {$user_assignment_array(type) == "cio"} {
			lappend assignment_list "cio_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class II" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQ pin IO standard assignment for 1.5-V HSTL Class II"
			lappend io_assignment_list "cio_pin_list" 		"io_standard" 			"1.5-V HSTL Class II" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQ pin IO standard assignment for 1.5-V HSTL Class II"
		    } else {
			lappend assignment_list "sio_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string D and Q pin IO standard assignment for 1.5-V HSTL Class I"
			lappend io_assignment_list "sio_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string D and Q pin IO standard assignment for 1.5-V HSTL Class I"
		    }
	    } else {
		    if {$user_assignment_array(type) == "cio"} {
			lappend assignment_list "cio_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQ IO standard assignment for 1.5-V HSTL Class I"
			lappend io_assignment_list "cio_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string DQ IO standard assignment for 1.5-V HSTL Class I"
		    } else {
			lappend assignment_list "sio_pin_list" 			"IO_STANDARD" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string D and Q IO standard assignment for 1.5-V HSTL Class I"
			lappend io_assignment_list "sio_pin_list" 		"io_standard" 			"1.5-V HSTL Class I" 	"\\\${prefix_name}\\\${\${pin}}"    "-" 	"\$apply_remove_string D and Q IO standard assignment for 1.5-V HSTL Class I"
		    }
	    }
    }

        
    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string output pin load for \${top_level}\"    "
    if {$user_assignment_array(type) == "cio"} {
	    lappend assignment_list "cio_dq_output_pin_cap_load_list" 		"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_dq)"	"\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_dq)pf load to DQ pins"
	    #lappend io_assignment_list "cio_dq_output_pin_cap_load_list"	"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_dq)"	"\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_dq)pf load to DQ pins"
    } else {
	    lappend assignment_list "sio_dq_output_pin_cap_load_list" 		"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_dq)"	"\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_dq)pf load to D pins"
	    #lappend io_assignment_list "sio_dq_output_pin_cap_load_list" 	"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_dq)"	"\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_dq)pf load to D pins"
    }
    
    lappend assignment_list "cmd_output_pin_cap_load_list" 			"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_cmd)" "\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_cmd)pf load to command pins"
    lappend io_assignment_list "cmd_output_pin_cap_load_list" 			"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_cmd)" "\\\${prefix_name}\\\${\${pin}}" 	"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_cmd)pf load to command pins"
    
    if {$user_assignment_array(ddio_memory_clocks) == "true"} {
	    lappend assignment_list "clk_output_pin_cap_load_list"      	"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
	    #lappend io_assignment_list "clk_output_pin_cap_load_list"      	"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
    } else {
	    #lappend assignment_list "diff_clk_hstl_pin_list"      		"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
	    #lappend assignment_list_dedicated "diff_neg_clk_hstl_pin_list"      "OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
        lappend assignment_list "clk_output_pin_cap_load_list"      	"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_clk)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to clocks pins"
    }	    
	    
    if {$user_assignment_array(enable_dm_pins) == "true"} {
	    lappend assignment_list "dm_output_pin_cap_load_list"      		"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_dq)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to dm pins"
	    #lappend io_assignment_list "dm_output_pin_cap_load_list"      	"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_dq)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to dm pins"
    }
    
    if {$user_assignment_array(number_addr_cmd_buses) == "2"} {
	    lappend assignment_list "cmd_output_pin_1_cap_load_list"   		"OUTPUT_PIN_LOAD" 		"\$user_assignment_array(pf_pin_load_on_cmd)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to address and command pins"
	    #lappend io_assignment_list "cmd_output_pin_1_cap_load_list"   	"output_pin_load" 		"\$user_assignment_array(pf_pin_load_on_cmd)" "\\\${prefix_name}\\\${\${pin}}" 			"-" "\$apply_remove_string $user_assignment_array(pf_pin_load_on_clk)pf load to address and command pins"
    }

    puts $out_tcl_id    "${tab}puts \"\$apply_remove_string input pad to register delay for \${top_level}\"    "
    # # only in non-dqs mode
    if {$user_assignment_array(enable_capture_clk) == "true"} {
	if {$user_assignment_array(type) == "cio"} {
		lappend assignment_list "cio_input_register_delay"		"PAD_TO_INPUT_REGISTER_DELAY"	"0"	"\\\${prefix_name}\\\${\${pin}}" "-" "\$apply_remove_string DQ input pin to register delay 0"
	} else {
		lappend assignment_list "sio_input_register_delay"		"PAD_TO_INPUT_REGISTER_DELAY"	"0"	"\\\${prefix_name}\\\${\${pin}}" "-" "\$apply_remove_string Q input pin to register delay 0"
	}
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
 
		    	 if {$io_path_array(width,$pin) > 0} {;# unroll the bus
		    		 for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
					 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
					 # set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)\[$pin_number\],$f_assign_name) [subst $f_assign_value]
					 # 
					 # if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)\[$pin_number\]] < 0} {
					 	# lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)\[$pin_number\]
					 # }
				    	 # lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)\[$pin_number\])  $f_assign_name
		    		 }
		    	 } else {
		    		 # only one assignment, either a pin, or global assignment for the bus
		    		puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\"  -to \"[subst $f_assign_to]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
		    	        # set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin),$f_assign_name) [subst $f_assign_value]
					 # 
					 # if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)] < 0} {
					 	# lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)
					 # }
				    	 # lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin))  $f_assign_name
			}
		     }
		 }
	 }
	 
	 foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $io_assignment_list {
		 if {[info exists io_path_array(list,$f_param_name)]} {
		     if {$f_assign_entity != "-"} {
	    		 set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	 } else {
	    		 set entity_parameter ""
	    	 }
		     foreach pin $io_path_array(list,$f_param_name) {
 
		    	 if {$io_path_array(width,$pin) > 0} {;# unroll the bus
		    		 for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
					 set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)\[$pin_number\],$f_assign_name) [subst $f_assign_value]
					 if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)\[$pin_number\]] < 0} {
					 	lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)\[$pin_number\]
					 }
				    	 lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin)\[$pin_number\])  $f_assign_name
		    		 }
		    	 } else {
		    		 # only one assignment, either a pin, or global assignment for the bus
		    		set prot_plan_xml(${prefix_name}$io_name_mapping_array($pin),$f_assign_name) [subst $f_assign_value]
					 
					 if {[lsearch -exact $prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)] < 0} {
					 	lappend prot_plan_xml(pin_list) ${prefix_name}$io_name_mapping_array($pin)
					 }
				    	 lappend prot_plan_xml(${prefix_name}$io_name_mapping_array($pin))  $f_assign_name
			}
		     }
		 }
	 }
	 
	 foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $fo_assignment_list {
		 if {[info exists io_path_array(list,$f_param_name)]} {
		     puts $out_tcl_id    "${tab}puts \"$f_display_string\""
		     if {$f_assign_entity != "-"} {
	    		 set entity_parameter "-entity \"[subst $f_assign_entity]\""
	    	 } else {
	    		 set entity_parameter ""
	    	 }
		     foreach pin $io_path_array(list,$f_param_name) {
 
		    	 if {$io_path_array(width,$pin) > 0} {;# unroll the bus
		    		 for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
					 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
				     }
		    	 } else {
		    		 # only one assignment, either a pin, or global assignment for the bus
		    		 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\"  -to \"[subst $f_assign_to]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
			}
		     }
		 }
	 }
	 
	 # if {$user_assignment_array(ddio_memory_clocks) == "false"} {
		 # foreach {f_param_name f_assign_name f_assign_value f_assign_to f_assign_entity f_display_string} $assignment_list_dedicated {
			 # if {[info exists io_path_array(list,$f_param_name)]} {
			     # puts $out_tcl_id    "${tab}puts \"$f_display_string\""
			     # if {$f_assign_entity != "-"} {
				 # set entity_parameter "-entity \"[subst $f_assign_entity]\""
			 # } else {
				 # set entity_parameter ""
			 # }
			     # foreach pin $io_path_array(list,$f_param_name) {
	 # 
				 # if {$io_path_array(width,$pin) > 0} {;# unroll the bus
					 # for {set pin_number 0} {$pin_number < $io_path_array(width,$pin)} {incr pin_number} {
						 # #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}\\\[\$pin_number\\\](n)]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
                         # puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\" -to \"[subst ${f_assign_to}\\\[\$pin_number\\\]]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
					 # }
				 # } else {
					 # # only one assignment, either a pin, or global assignment for the bus
					 # puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"[subst $f_assign_name]\"  -to \"[subst $f_assign_to]\" $entity_parameter \"[subst $f_assign_value]\" \$add_remove_string"]\]"
				# }
			     # }
			 # }
		 # }
	# }
	 
	 
	 #dqs mode
	 
	 puts $out_tcl_id    "${tab}puts \"\$apply_remove_string global signal for \${top_level}\"    "
	 set j 0
	 
	 if {$user_assignment_array(enable_capture_clk) == "false"} {
		 if {$user_assignment_array(memory_width) / $user_assignment_array(mem_dq_per_dqs) / $user_assignment_array(number_memory_devices) == 1} {
			for {set i 0} {$i < ($user_assignment_array(memory_width) / $user_assignment_array(mem_dq_per_dqs))} {incr i 1} {
				 #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk_undelayed\*\" -entity \"\${top_level}\" \"\Regional Clock\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk_undelayed\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
                 #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
                 #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -from \"\${hierarchy_path_to_dqs_group}_${i}|dqs\*\" -to \"\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
				 #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -from \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk\[0]\" -to \"\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*control_qvld\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*control_qvld\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
			} 
		 } else {
			for {set i 0} {$i < ($user_assignment_array(memory_width) / $user_assignment_array(mem_dq_per_dqs))} {incr i 1} {
				 if {$i == $j} {
                     set qk_index [expr $i + 1]
					 puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk_undelayed\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
                     #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk_undelayed\*\" -entity \"\${top_level}\" \"\Regional Clock\" \$add_remove_string"]\]"
                     #puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"GLOBAL_SIGNAL\" -to \"\${hierarchy_path_to_dqs_group}_${i}|dqs_clk\*\" -entity \"\${top_level}\" \"\OFF\" \$add_remove_string"]\]"
                     #####puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CLOCK_SETUP_UNCERTAINTY\" \"0.35ns\" -from \"\${prefix_name}qk\[$qk_index]\" -to \"\${prefix_name}qk\[$i]\" \$add_remove_string"]\]"
                     #####puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"CLOCK_HOLD_UNCERTAINTY\" \"0.35ns\" -from \"\${prefix_name}qk\[$qk_index]\" -to \"\${prefix_name}qk\[$i]\" \$add_remove_string"]\]"
                     
                     
                     # Different QK transfer
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.753ns\" -from \"\*dqs_group_$qk_index|dq_captured_rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.753}] ns\" -from \"\*dqs_group_$qk_index|dq_captured_rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.753ns\" -from \"\*dqs_group_$qk_index|dq_captured_falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.753}] ns\" -from \"\*dqs_group_$qk_index|dq_captured_falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                                          
                     # Same QK transfer
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*dqs_group_$i|dq_captured_rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*dqs_group_$i|dq_captured_rising\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*dqs_group_$i|dq_captured_falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*dqs_group_$i|dq_captured_falling\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"HOLD_RELATIONSHIP\" \"0.285ns\" -from \"\*control_qvld\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     puts $out_tcl_id    "${tab}eval \[concat [string map  $charmap_sq  "set_instance_assignment -tag \"${wrapper_name}\" -name \"SETUP_RELATIONSHIP\" \"[expr {(900.0/${user_assignment_array(clock_freq_in_mhz)}) - 0.285}] ns\" -from \"\*control_qvld\*\"\ -to \"\*\" -entity \"\${top_level}\" \$add_remove_string"]\]"
                     
					 set j [expr $i + 2]
					 #puts $j
				 }
			}
		 }
	}
    
    
	 
	
# -------------------------------------------------------------------------------------------------
# 			Specific constraints (group and bit dependent
# -------------------------------------------------------------------------------------------------
	if {!$skip_placement} {
        # Two loops, one per group then one per bit in each group
	set mem_dq_per_dqs ${user_assignment_array(mem_dq_per_dqs)}

	set number_of_dq_groups [expr {${user_assignment_array(memory_width)}/${mem_dq_per_dqs}}]
	
	set device_number 0
	set device_pin_index 0
	
	for {set group_number 0} {$group_number < $number_of_dq_groups} {incr group_number} {
		# -------------------------------------------------------------------------------------------------
		# 			set the group wide assignments here
		# -------------------------------------------------------------------------------------------------
		# this is not correct. We want the user list not the overall list
		set current_group_name [lindex ${user_assignment_array(byte_groups)} $group_number]

		#puts "GROUPS: $user_assignment_array(byte_groups)"
		#puts "GROUP NUMBER: $group_number"
		#puts "CURRENT GROUP: $current_group_name"
		
		# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		#           Building the list of pins to which we want to do assignments
		#
 
		set bit_list ""
		set d_bit_list ""
				
		#set list [array get lcell_dq_dqs_pins_array]
		#puts "LIST: $list"
		 
		if {$user_assignment_array(type) == "cio"} {
			for {set bit_number 0} {$bit_number < ${mem_dq_per_dqs}} {incr bit_number} {
				# check the existence of the pin
				if {![info exists lcell_dq_dqs_pins_array($current_group_name,dq${bit_number})]} {
					puts "the device and package file does not provide the information needed for the pin dq${bit_number} in group $current_group_name"
					exit 2
				}
				set overall_bit_number [expr {$bit_number + $mem_dq_per_dqs * $group_number}]
				set current_bit_name \${dq_pin_name}\[${overall_bit_number}\]
				lappend bit_list dq $bit_number $current_bit_name $overall_bit_number
			}
		} else {
			for {set bit_number 0} {$bit_number < ${mem_dq_per_dqs}} {incr bit_number} {
							
				# check the existence of the pin
				if {![info exists lcell_dq_dqs_pins_array($current_group_name,dq${bit_number})]} {
					puts "the device and package file does not provide the information needed for the pin q${bit_number} in group $current_group_name"
					exit 2
				}
				if {![info exists lcell_dq_dqs_pins_array($current_group_name,dqs)]} {
					puts "the device and package file does not provide the information needed for the pin dqs in group $current_group_name"
					exit 2
				}
				set overall_bit_number [expr {$bit_number + $mem_dq_per_dqs * $group_number}]
				set current_bit_name \${q_pin_name}\[${overall_bit_number}\]
				set d_current_bit_name \${d_pin_name}\[${overall_bit_number}\]
				lappend bit_list dq $bit_number $current_bit_name $overall_bit_number
				lappend d_bit_list dq $bit_number $d_current_bit_name $overall_bit_number
			}
		}
		
		# one dqs per group only
		# Only if in DQS mode
		if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
			if {![info exists lcell_dq_dqs_pins_array($current_group_name,dqs)]} {
				puts "the device and package file does not provide the information needed for the pin dqs in group $current_group_name"
				exit 2
			}
			#lappend bit_list dqs 0 \${dqs_pin_name}\[${group_number}\] 0
			#lappend bit_list dqs ${group_number} \${dqs_pin_name}\[${group_number}\] ${device_pin_index}
            lappend bit_list dqs ${group_number} \${dqs_pin_name}\[${group_number}\] ${group_number}
		}
		
		set number_dqs_per_device [expr {${user_assignment_array(memory_width)}/${user_assignment_array(mem_dq_per_dqs)}/${user_assignment_array(number_memory_devices)}}]
				
		#puts "GROUP #: $group_number"
		#puts "DEVICE #: $device_number"
		if {$group_number == $device_number} {
			if {$user_assignment_array(enable_dm_pins) == "true"} {
				if {![info exists lcell_dq_dqs_pins_array($current_group_name,rldm)]} {
					puts "the device and package file does not provide the information needed for the pin dm in group $current_group_name"
				} else {
					#lappend bit_list rldm 0 \${dm_pin_name}\[${device_pin_index}\] 0
					lappend bit_list rldm ${device_pin_index} \${dm_pin_name}\[${device_pin_index}\] ${device_pin_index}
				}
			}
			
			if {![info exists lcell_dq_dqs_pins_array($current_group_name,qvld)]} {
				puts "the device and package file does not provide the information needed for the pin qvld in group $current_group_name"
			} else {
				#lappend bit_list qvld 0 \${qvld_pin_name}\[${device_pin_index}\] 0
				lappend bit_list qvld ${device_pin_index} \${qvld_pin_name}\[${device_pin_index}\] ${device_pin_index}
			}
			set device_number [expr {$group_number + $number_dqs_per_device}]
			set device_pin_index [expr {$device_pin_index + 1}]
		}
		
		 

		#
		#           end of building the list of pins to which we want to do assignments
		# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		# -------------------------------------------------------------------------------------------------
		# 			Do the assignments to each bit
		# -------------------------------------------------------------------------------------------------
		foreach {bit_type bit_number current_bit_name overall_bit_number} $bit_list {
			# now the numbering we have:
			# group_number : the number of the group (starts at 0)
			# bit_number : the number of the dq bit in the group (starts at 0)
			# overall_bit_number : the number of the bit in the whole of the interface (incremented by the group size every group)
 			if {$bit_type == "dq" || ($bit_type == "rldm" && ${dm_per_group} > 1)} {
				set bit_name_in_array ${bit_type}${bit_number}
			} else {
				set bit_name_in_array ${bit_type}
			}
			
			set current_bit_info $lcell_dq_dqs_pins_array($current_group_name,$bit_name_in_array)
			
			# format of the info is :
			# device_pin_name row_col lab_pos dq_enb_pair_number
 
			# first part of the assignment, the pin name (maybe also the pin type in terms of IO standard)
			# In case of a Pin, we need to prefix Pin_ to the name, otherwise leave the name untouched (such as IOBANK_4)
			set quartus_pin_prefix "Pin_"
			puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -tag \"${wrapper_name}\" -to \"\${prefix_name}${current_bit_name}\" \"${quartus_pin_prefix}[lindex $current_bit_info 0]\" \$add_remove_string "]\]"
			
			puts "${prefix_name}${current_bit_name}\[$overall_bit_number\]    $bit_number    $bit_type       ${quartus_pin_prefix}[lindex $current_bit_info 0]"
			
			if {$bit_type == "dq"} {
				set prot_plan_xml(${prefix_name}$bit_type\[$overall_bit_number\],location) [subst ${quartus_pin_prefix}[lindex $current_bit_info 0]]
				lappend prot_plan_xml(${prefix_name}$bit_type\[$overall_bit_number\])  location
			} 
			
			if {$bit_type == "dqs"} {
				set prot_plan_xml(${prefix_name}qk\[$overall_bit_number\],location) [subst ${quartus_pin_prefix}[lindex $current_bit_info 0]]
				lappend prot_plan_xml(${prefix_name}qk\[$overall_bit_number\])  location
			} 
			
			if {$bit_type == "rldm"} {
				set prot_plan_xml(${prefix_name}dm\[$overall_bit_number\],location) [subst ${quartus_pin_prefix}[lindex $current_bit_info 0]]
				lappend prot_plan_xml(${prefix_name}dm\[$overall_bit_number\])  location
			}
			
			if {$bit_type == "qvld"} {
				set prot_plan_xml(${prefix_name}qvld\[$overall_bit_number\],location) [subst ${quartus_pin_prefix}[lindex $current_bit_info 0]]
				lappend prot_plan_xml(${prefix_name}qvld\[$overall_bit_number\])  location
			}
		}
		
			#puts $user_assignment_array(type)
		
			if {$user_assignment_array(type) == "sio"} {
				
			foreach {bit_type bit_number d_current_bit_name overall_bit_number} $d_bit_list {
				
				puts "D_LIST: $bit_type d_current_bit_name"
				
				if {$bit_type == "dq"} {
					set d_bit_name_in_array ${bit_type}${bit_number}
				}
				
				set d_current_bit_info $lcell_dq_dqs_pins_array($current_group_name,$d_bit_name_in_array)
				#puts "CBI: $d_current_bit_info"
				puts $out_tcl_id "${tab}eval \[concat [string map  $charmap_sq  "set_location_assignment -tag \"${wrapper_name}\" -to \"\${prefix_name}${d_current_bit_name}\" \"[lindex $d_current_bit_info 8]\" \$add_remove_string "]\]"
				#puts "CBN: $d_current_bit_name"
				
				#puts "${prefix_name}${current_bit_name}\[$overall_bit_number\]    $bit_number    $bit_type       ${quartus_pin_prefix}[lindex $current_bit_info 0]"
				
				 if {$bit_type == "dq"} {
					 puts "HELLO"
					 puts "PIN# $bit_type [lindex $current_bit_info 0]"
					 set prot_plan_xml(${prefix_name}q\[$overall_bit_number\],location) [subst ${quartus_pin_prefix}[lindex $d_current_bit_info 0]]
					 lappend prot_plan_xml(${prefix_name}q\[$overall_bit_number\])  location
				 }
			}
		}
	}
	}
	
	# 
# # There are three cases here. Either:
# # 1) There should be a pin file for this board, and (at add_constraints time) it is present in the file system.
# #    --> the pin file should be run
# # 2) We think there should be a pin file for this board (in this script) but at add_constraints time is it not present.
# #    --> this is an internal error
# # 3) There is no pin file for this board ($pin_file ends 'none')
# #    --> don't write anything to the add constraints script
# if { $pin_file != "" } {
	# puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	# puts $out_tcl_id "${tab}# 			source the pin placement script for the address and command pins"
	# puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
# 
	# puts $out_tcl_id "${tab} if { \[file exists \$pin_file\] } {"
	# puts $out_tcl_id "${tab}     source \$pin_file"
	# puts $out_tcl_id "${tab} } else { "
	# puts $out_tcl_id "${tab}     post_message -type critical_warning \"Internal Error: pin_file \$pin_file not found\""
	# puts $out_tcl_id "${tab} }"
# }
# 
# if {$generate_txt_placement_file && !$skip_placement} { print_lcell_placement final_placement_array final_placement_clock_array user_assignment_array lcell_dq_dqs_pins_array lab_placement.txt}
# 

puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	puts $out_tcl_id "${tab}# 			create the remove script"
	puts $out_tcl_id "${tab}# -------------------------------------------------------------------------------------------------"
	puts $out_tcl_id {	if {$add_remove_string == ""} {
		set this_script_name [file tail [info script]]
		#set output_script_name "remove_[file rootname $this_script_name]_[clock format [clock seconds] -format %Y_%m_%d___%H_%M][file extension $this_script_name]"
		#set fileid [open [info script] r]
		# set str ""
		# append str "set add_remove_string \"-remove\"\n"
		# append str "remove_all_instance_assignments -name * -tag mw_wrapper\n"
		# append str "set check_path_from_report 0\n"
		# append str "set hierarchy_path_to_instance $hierarchy_path_to_instance\n"
		# append str "set top_level $top_level\n"
		#while {[gets $fileid line] >= 0} {
		#	append str "$line\n"
		#}
		#close $fileid

		# append str "\n\nset add_remove_string \"\"\n"
		# append str "set do_analysis 1\n\n"
		# set fileid [open $output_script_name w]
		# puts $fileid $str
		set output_script_name "remove_[file rootname $this_script_name][file extension $this_script_name]"
		#if [file exists $output_script_name] {
		#	file delete $output_script_name
		#}
		set str ""
				
		append str  "puts \"----------------------------------------------------------------------------\"\n"
		append str  "puts \"- Removing the constraints for ${wrapper_name} \"\n"
		append str  "puts \"----------------------------------------------------------------------------\"\n"
		
	
	
		append str "remove_all_instance_assignments -name * -tag $wrapper_name\n"
		#append str "remove_all_instance_assignments -name * -tag mw_wrapper\n"
		#set output_script_name "remove_[file rootname $this_script_name][file extension $this_script_name]"
		set fileid [open $output_script_name w]
		puts $fileid $str
		close $fileid
	}}

#puts $out_tcl_id    "${tab}# unset some variable so they don't stick around for the next script!"
#puts $out_tcl_id    "${tab}unset hierarchy_path_to_instance"
#puts $out_tcl_id    "${tab}set hierarchy_path_to_dqs_group "" "
#puts $out_tcl_id    "${tab}unset top_level"

#puts $out_tcl_id    "${tab}puts \" - All Done\"    "

puts $out_tcl_id  "puts \"---------------------------------------------------------------------\n\""
#close $out_tcl_id
if {$placement_error_flag == 1} {
	puts " - Placement errors."
} else {
	puts " - All Done."
#	puts $out_tcl_id "${tab}set_global_assignment -name PRE_FLOW_SCRIPT_FILE quartus_sh:add_constraints_for_$user_assignment_array(wrapper_name).tcl -remove"
#	puts $out_tcl_id "${tab}export_assignments"
}
##ola export_assignments
puts $out_tcl_id  "}"
close $out_tcl_id
##ola

# Generate SDC file for project
set sdc_out_file "$wrapper_name.sdc"
set out_sdc_id [open $sdc_out_file w]
    puts $out_sdc_id " # SDC constraints file for $wrapper_name variation"
    puts $out_sdc_id " # $wrapper_name.sdc contains timing constraints required for the top-level generated project $top_level"
    puts $out_sdc_id " # $wrapper_name.sdc must be used in conjunction with DTW generated SDC constraints file"
    
    puts $out_sdc_id " # Set false path from reset_n_read_clk_r2 to DDIO"
    #puts $out_sdc_id " set_false_path -from reset_n_read_clk_r2 -to *"
    #puts $out_sdc_id " set_false_path -from \[get_keepers {reset_n_read_clk_r2\[1\] reset_n_read_clk_r2\[0\]}\] -to \[get_keepers *\]"
    puts $out_sdc_id " set_false_path -from \[get_keepers {reset_n_read_clk_r2*}\] -to \[get_keepers *\]"
    #puts $out_sdc_id " # Set false path from QK capture clock to PLL clk0"
    
    if {[regexp -nocase "false" ${user_assignment_array(enable_capture_clk)}]} {
        #puts $out_sdc_id " # Set false path from QK capture clock to PLL clk0"
        if {$user_assignment_array(family) == "stratixii"} {
           puts $out_sdc_id " # Set false path from QK capture clock to PLL clk0"
	   puts $out_sdc_id " set_false_path -from \[get_clocks {${prefix_name}qk*}] -to \[get_clocks {g_stratixii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
           puts $out_sdc_id " # Set false path from PLL clk0 to QK capture clock "
	   puts $out_sdc_id "  set_false_path -from \[get_clocks {g_stratixii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {${prefix_name}qk*}\]"
	   
        } elseif {$user_assignment_array(family) == "stratixiigx"} {
            puts $out_sdc_id " # Set false path from QK capture clock to PLL clk0"
            puts $out_sdc_id " set_false_path -from \[get_clocks {${prefix_name}qk*}] -to \[get_clocks {g_stratixiigx_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
	    puts $out_sdc_id " # Set false path from PLL clk0 to QK capture clock "
	    puts $out_sdc_id " set_false_path -from \[get_clocks {g_stratixiigx_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {${prefix_name}qk*}\]"
        } elseif {$user_assignment_array(family) == "hardcopyii"} {
            puts $out_sdc_id " # Set false path from QK capture clock to PLL clk0"
            puts $out_sdc_id " set_false_path -from \[get_clocks {${prefix_name}qk*}] -to \[get_clocks {g_hardcopyii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
	    puts $out_sdc_id " # Set false path from PLL clk0 to QK capture clock "
	    puts $out_sdc_id " set_false_path -from \[get_clocks {g_hardcopyii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {${prefix_name}qk*}\]"
        }
    } else {
        if {$user_assignment_array(family) == "stratixii"} {
            puts $out_sdc_id " set_false_path -from \[get_clocks {g_stratixii_fbpll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {g_stratixii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
	    puts $out_sdc_id " # Set false path from PLL clk0 to FB_CLK_IN capture clock "
            puts $out_sdc_id " set_false_path -from \[get_clocks {g_stratixii_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {g_stratixii_fbpll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
            
        } elseif {$user_assignment_array(family) == "stratixiigx"} {
	    puts $out_sdc_id " set_false_path -from \[get_clocks {g_stratixiigx_fbpll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {g_stratixiigx_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
	    puts $out_sdc_id " # Set false path from PLL clk0 to FB_CLK_IN capture clock "
            puts $out_sdc_id " set_false_path -from \[get_clocks {g_stratixiigx_pll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\] -to \[get_clocks {g_stratixiigx_fbpll_rldramii_pll_inst|altpll_component|pll|clk\[0\]}\]"
            
        }
    }
    
    #puts $out_sdc_id " set_false_path -from \[get_clocks {rldramii_qk*}\] -to \[get_clocks {rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0}\]"
    #puts $out_sdc_id " set_false_path -from \[get_clocks {rldramii_qk\[0\]}\] -to \[get_clocks {rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0}\]"
    #puts $out_sdc_id " set_false_path -from \[get_clocks {rldramii_pll_stratixii:g_stratixii_pll_rldramii_pll_inst|altpll:altpll_component|_clk0}\] -to \[get_clocks {rldramii_qk*}\]"
close $out_sdc_id


# set protocol_palnner_out_file "$wrapper_name.ppf"
# set out_xml_id [open $protocol_palnner_out_file w]
# puts $out_xml_id    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
# puts $out_xml_id    "<pinplan specifies=\"external_ports\">"
# puts $out_xml_id    "      <global>"
   # if {$user_assignment_array(number_memory_devices) == "1"} {
       # puts $out_xml_id "                     <pin name=\"${prefix_name}dm\[0..0\]\" direction=\"output\" />"
       # puts $out_xml_id "                     <pin name=\"${prefix_name}qvld\[0..0\]\" direction=\"input\" />"
# 
       # if {$user_assignment_array(memory_width) == "9"} {
           # puts $out_xml_id "                     <pin name=\"${prefix_name}qk\[0..0\]\" direction=\"bidir\" />"
       # }
       # 
       # if {$user_assignment_array(memory_width) == "8"} {
           # puts $out_xml_id "                     <pin name=\"${prefix_name}qk\[0..0\]\" direction=\"bidir\" />"
       # }
   # }
   # 
   # if {$user_assignment_array(num_output_clocks) == "1"} {
       # puts $out_xml_id "                     <pin name=\"${prefix_name}clk\[0..0\]\" direction=\"output\" />"
       # puts $out_xml_id "                     <pin name=\"${prefix_name}clk_n\[0..0\]\" direction=\"output\" />"
   # }
   # 
# puts $out_xml_id    "      <block name=\"$wrapper_name\">"
# 
  # foreach pp_pin $prot_plan_xml(pin_list) {
      # puts "pin_detected $pp_pin"
      # puts $out_xml_id "                     <pin name=\"$pp_pin\""
      # puts $out_xml_id "                     username=\"$pp_pin\""
      # foreach pp_param $prot_plan_xml($pp_pin) {
          # puts $out_xml_id "                     $pp_param=\"$prot_plan_xml($pp_pin,$pp_param)\""
      # }                                                         
      # puts $out_xml_id "                     scope=\"external\""
      # puts $out_xml_id "                     />"
  # }
# 
# puts $out_xml_id    "      </block>"
# puts $out_xml_id    "      </global>"
# puts $out_xml_id    "</pinplan>"
# close $out_xml_id

