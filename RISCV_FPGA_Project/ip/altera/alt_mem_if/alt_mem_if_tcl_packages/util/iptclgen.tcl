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


package provide alt_mem_if::util::iptclgen 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array


namespace eval ::alt_mem_if::util::iptclgen:: {

	namespace import ::alt_mem_if::util::messaging::*
	
}



proc ::alt_mem_if::util::iptclgen::parse_hdl {module core_params indir outdir inhdl_files module_list supported_params} {

	set ifdef_list [split $core_params ",\" "]
	set supported_ifdef_list [split $supported_params ",\" "]
	set infile_list [split $inhdl_files ",\""]
	set unique_list [split $module_list ",\" "]
	
	return [parse_hdl_list $module $ifdef_list $indir $outdir $infile_list $unique_list $supported_ifdef_list]
}

proc ::alt_mem_if::util::iptclgen::parse_hdl_list {module ifdef_list indir outdir infile_list unique_list supported_ifdef_list} {

	
	_dprint 1 "Preparing to run parse_hdl() on $infile_list"
	_dprint 1 "   indir = $indir"
	_dprint 1 "   outdir = $outdir"
	_dprint 1 "   module = $module"
	_dprint 1 "   unique_list = $unique_list"
	_dprint 1 "   ifdef_list = $ifdef_list"
	_dprint 1 "   supported_ifdef_list = $supported_ifdef_list"

	set debug 0

	set outfile_list [list]

	foreach infile_list_element $infile_list {

		set outfile_name ""

		set infull_name [file join $indir $infile_list_element]
		set infile_path [file dirname $infull_name]
		set infile_name [file tail $infull_name]
		set infile_base [file rootname $infile_name]

		if {[lsearch $unique_list $infile_base] != -1} {
			_dprint 1 "found basename $infile_base"
			append outfile_name $module "_" $infile_name
		} else {
			append outfile_name $infile_name
		}

		set outfile_list [concat $outfile_list $outfile_name]

		set full_outfile_name [file join $outdir $outfile_name]

		_dprint 1 "full output filename is $full_outfile_name"

		parse_hdl_file $infull_name $full_outfile_name $module $ifdef_list $unique_list $supported_ifdef_list

	}

	if {$debug} {
		puts "output files were(taf):"
		foreach outfile $outfile_list {
			puts $outfile
		}
	}
		

	return $outfile_list
}


proc ::alt_mem_if::util::iptclgen::parse_hdl_file {infull_name full_outfile_name module ifdef_list unique_list supported_ifdef_list} {

	catch {set inhdl [open "$infull_name" r]} tempresult
	_dprint 1 "opening $infull_name for read: $tempresult"
	
	catch {set outhdl [open "$full_outfile_name" w]} tempresult
	_dprint 1 "opening $full_outfile_name for write: $tempresult"

	set skip_to_end 0
	set ifdef_stack [list]

	set spaces "\[ \t\n\]"
	set notspaces "\[^ \t\n\]"

	while {[gets $inhdl line] != -1} {
		set out_line 1	
		_dprint 2 "INLINE: $line"

		if {[regexp -- "${spaces}*`(ifn?def)${spaces}+(${notspaces}+)${spaces}*" $line matchvar type ifdef] } {

			if {[lsearch $supported_ifdef_list $ifdef ] == -1} {
				_dprint 2 "    Found $type $ifdef, but is not supported. Leave it in the code."
				set ifdef_stack [lappend ifdef_stack 0]
			} else {

				_dprint 2 "    Found the supported $type $ifdef"

				set out_line 0
				set ifdef_stack [lappend ifdef_stack 1]

				if { $skip_to_end == 0 } {
					if { ($type == "ifdef" &&  [lsearch $ifdef_list $ifdef ] != -1) ||
						 ($type == "ifndef" && [lsearch $ifdef_list $ifdef ] == -1) } {
					} else {
						incr skip_to_end
					}		
				} else {
					incr skip_to_end
				}
			}
		}

		if {[regexp -- "${spaces}*`endif${spaces}*" $line matchvar] } {
			_dprint 2 "before stack $ifdef_stack"
			if {[lindex $ifdef_stack [expr {[llength $ifdef_stack] - 1}]] == 1} {
				set out_line 0							
					
				if {$skip_to_end > 0} {	
					incr skip_to_end -1 
				}
			}

			set ifdef_stack [lrange $ifdef_stack 0 [expr {[llength $ifdef_stack] - 2}]]
			_dprint 2 "$skip_to_end $out_line after stack $ifdef_stack"
		}

		if {[regexp -- "${spaces}*`else${spaces}*" $line matchvar] } {
			_dprint 2 "found an else"

			if {[lindex $ifdef_stack [expr {[llength $ifdef_stack] - 1}]] == 1} {						
				set out_line 0
				if {$skip_to_end == 1} {	
					incr skip_to_end -1 
				} else {
					if {$skip_to_end ==0} {
						incr skip_to_end
					}
				}		
			}
		}

		if {$out_line == 1 && $skip_to_end == 0} {		

			set line [alt_mem_if::util::iptclgen::uniquify_names $module $line $unique_list]
			puts $outhdl $line
			_dprint 2 "OUTLINE: $line"
		}
	
	}

	close $inhdl
	close $outhdl		

	return 1

}


proc ::alt_mem_if::util::iptclgen::parse_hdl_params {module indir outdir infile_list unique_list ifdef_array} {
	upvar $ifdef_array ifdef_db_array
	_dprint 1 "Preparing to run parse_hdl() on $infile_list"
	_dprint 1 "   indir = $indir"
	_dprint 1 "   outdir = $outdir"
	_dprint 1 "   module = $module"
	_dprint 1 "   unique_list = $unique_list"

	set outfile_list [list]
	
	foreach infile_list_element $infile_list {

		set outfile_name ""

		set infull_name [file join $indir $infile_list_element]
		set infile_path [file dirname $infull_name]
		set infile_name [file tail $infull_name]
		set infile_base [file rootname $infile_name]

		if {[lsearch $unique_list $infile_base] != -1} {
			_dprint 1 "found basename $infile_base"
			append outfile_name $module "_" $infile_name
		} else {
			append outfile_name $infile_name
		}

		set outfile_list [concat $outfile_list $outfile_name]

		set full_outfile_name [file join $outdir $outfile_name]

		_dprint 1 "full output filename is $full_outfile_name"

		parse_hdl_file_params $infull_name $full_outfile_name $module $unique_list ifdef_db_array

	}

	return $outfile_list
}


proc ::alt_mem_if::util::iptclgen::parse_hdl_file_params {infull_name full_outfile_name module unique_list ifdef_param_list} {
	upvar $ifdef_param_list ifdef_db_array
	set inhdl [open "$infull_name" r]
	set outhdl [open "$full_outfile_name" w]
	
	set skip_to_end 0
	set ifdef_stack [list]

	set spaces "\[ \t\n\]"
	set notspaces "\[^ \t\n\]"
		
	while {[gets $inhdl line] != -1} {
		set out_line 1	
		_dprint 2 "INLINE: $line"
		_dprint 2 "  Before ifdef test : out_line $out_line skip_to_end $skip_to_end ifdef_stack $ifdef_stack"
		
		if {[regexp -- "${spaces}*`(ifn?def)${spaces}+(${notspaces}+)${spaces}*" $line matchvar type ifdef] } {

			set ifdef_param "IFDEF_${ifdef}"
			if {[info exists ifdef_db_array($ifdef_param)] == 0} {
				_dprint 2 "    Found $type $ifdef, but is not supported. Leave it in the code."
				set ifdef_stack [lappend ifdef_stack 0]
			} else {
				
				set out_line 0
				set ifdef_stack [lappend ifdef_stack 1]
				
				set ifdef_param_val $ifdef_db_array($ifdef_param)
				
				_dprint 2 "    Found the supported $type $ifdef; its value is $ifdef_param_val"

				if { $skip_to_end == 0 } {
					if { ($type == "ifdef" &&  [string compare -nocase $ifdef_param_val "true"] == 0) ||
						 ($type == "ifndef" && [string compare -nocase $ifdef_param_val "false"] ==0) } {
					} else {
						incr skip_to_end
					}		
				} else {
					incr skip_to_end
				}
			}
		}
		
		_dprint 2 "  Before endif test : out_line $out_line skip_to_end $skip_to_end ifdef_stack $ifdef_stack"

		if {[regexp -- "${spaces}*`endif${spaces}*" $line matchvar] } {
			_dprint 2 "    Found an endif"
			_dprint 2 "    Before stack $ifdef_stack"
			
			if {[lindex $ifdef_stack end] == 1} {
				set out_line 0							
				
				if {$skip_to_end > 0} {	
					incr skip_to_end -1 
				}
			}

			set ifdef_stack [lrange $ifdef_stack 0 end-1]
		}
		
		_dprint 2 "  Before else test : out_line $out_line skip_to_end $skip_to_end ifdef_stack $ifdef_stack"

		if {[regexp -- "${spaces}*`else${spaces}*" $line matchvar] } {
			_dprint 2 "    Found an else"

			if {[lindex $ifdef_stack [expr {[llength $ifdef_stack] - 1}]] == 1} {						
				set out_line 0
				if {$skip_to_end == 1} {	
					incr skip_to_end -1 
				} else {
					if {$skip_to_end ==0} {
						incr skip_to_end
					}
				}		
			}
		}

		if {$out_line == 1 && $skip_to_end == 0} {		

			set line [alt_mem_if::util::iptclgen::uniquify_names $module $line $unique_list]
			puts $outhdl $line
			_dprint 2 "OUTLINE: $line"
		}
	
	}

	close $inhdl
	close $outhdl		

	return 1

}


proc ::alt_mem_if::util::iptclgen::uniquify_names {module line unique_list} {
	
	set newline $line

	set found_match 0

	set spaces "\[ \t\n\]"
	set notspaces "\[^ \t\n\]"
	set namechars "\[a-zA-Z0-9_\$\]"
	set manychars "\[a-zA-Z0-9_\$#\]"
	
	if {[regexp -- "(///*${spaces}*)(${namechars}+)(${spaces}*\\(.*)" $line matchvar preamble entity postamble] } {
		_dprint 2 "|${preamble}|${entity}|${postamble}|"
		set unique_index [lsearch $unique_list $entity]
		if {$unique_index != -1} {
			set found_match 1
			_dprint 2 "found match"
		}
	}		
	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*module${spaces}+)(${namechars}+)(.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}
	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*entity${spaces}+)(${notspaces}+${notspaces})(.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*end${spaces}+)(${notspaces}+${notspaces})(;.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*architecture${spaces}+${notspaces}+${spaces}+of${spaces}+)(${notspaces}+)(${spaces}+is.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*package${spaces}+)(${notspaces}+)(${spaces}*;.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}	
	if {$found_match == 0} {
		if {[regexp -- "(${spaces}*import${spaces}+)(${notspaces}+)(\\:\\:.*)" $line matchvar preamble entity postamble] } {
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
			} else {
			}
		}
	}	
	
	if {$found_match == 0} {
		if {[regexp -- "^(${spaces}*)(${namechars}+)(${spaces}*${manychars}+${spaces}*\\(?.*)\$" $line matchvar preamble entity postamble] } {
			_dprint 2 "|${preamble}|${entity}|${postamble}|"
			set unique_index [lsearch $unique_list $entity]
			if {$unique_index != -1} {
				set found_match 1
				_dprint 2 "found match"
			} else {
			
			}
		}
	}
	
	if {$found_match == 1} {
		set new_entity $module
		append new_entity "_" [lindex $unique_list $unique_index]
		set newline "${preamble}${new_entity}${postamble}"
	}
	
	return $newline
}


proc ::alt_mem_if::util::iptclgen::parse_tcl {module indir outdir intcl_files {core_params {} } {core_sub_params {} } } {

	if {[ info exists core_params ]} {
		set ifcheck_list [split $core_params ",\" "]
	}

	if {[ info exists core_sub_params ]} {
		upvar 1 $core_sub_params local_core_sub_params
	}

	set infile_list [split $intcl_files ",\" "]

		
		
	foreach infile_name $infile_list {

		_dprint 1 "Preparing to run parse_tcl on $infile_name"

		set outfile_name [ string map "memphy $module" $infile_name ]

		set outfile_name "$outdir/$outfile_name"

		set outtcl [open "$outfile_name" w]

		set infull_name $indir
		append infull_name "/" $infile_name


		set intcl [open "$infull_name" r]

		set skip_to_end 0
		set ifdef_level 0

		set spaces "\[ \t\n\]"
		set notspaces "\[^ \t\n\]"

		while {[gets $intcl line] != -1} {
			set out_line 1	

			_dprint 2 "LINE: $line"

			if {![regexp "^${spaces}*#.*" $line matchvar]} {

				if {[regexp -- "${spaces}*`ifdef${spaces}+(${notspaces}+)${spaces}*" $line matchvar ifdef] } {

					set out_line 0
					incr ifdef_level

					if { $skip_to_end == 0 } {
						if {[lsearch $ifcheck_list $ifdef ] == -1} {
							incr skip_to_end
						}		
					} else {
						incr skip_to_end
					}
				}

				if {[regexp -- "${spaces}*`endif${spaces}*" $line matchvar] } {
					set out_line 0							
						
					if {$skip_to_end > 0} {	
						incr skip_to_end -1 
					}

					incr ifdef_level -1
				}

				if {[regexp -- "${spaces}*`else${spaces}*" $line matchvar] } {

					set out_line 0
					if {$skip_to_end == 1} {
						incr skip_to_end -1
					} else {
						if {$skip_to_end ==0} {
							incr skip_to_end
						}
					}
				}
			}

			_dprint 2 "skip_to_end: $skip_to_end"

			if {$out_line == 1 && $skip_to_end == 0} {
				set modified_line $line
				if {[regexp "memphy_${notspaces}*\.tcl" $line] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp "memphy${notspaces}*\.sdc" $line] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp "^proc${spaces}+memphy_" $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_get_ddr_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_initialize_ddr_db} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_verify_ddr_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_get_all_instances_dqs_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_dump_all_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_dump_static_pin_map} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_sdc_cache} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_ddr_db} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_sort_proc} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				}

				if {[regexp {memphy_pll} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}

				if {[regexp {memphy_clkbuf} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}
					
				if {[regexp {memphy_leveling_clock} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}

			 	if {[regexp {::GLOBAL_} $line matchvar ] } {
					set modified_line [ string map "::GLOBAL_ ::GLOBAL_${module}_" $line ]
					set line $modified_line
				} 

				if {[regexp "^${spaces}*set${spaces}+${notspaces}+${spaces}+\\$(IPTCL_${notspaces}+)" $line matchvar setvar] } {
					if { ! [ info exists local_core_sub_params ] } {
						puts "ERROR: found set-IPTCL expression but no core_sub_params is defined"
	
						exit 1
					}

					_dprint 2 "IVAN: setvar = $setvar"
	
					if { ! [ info exists local_core_sub_params($setvar) ] } {
						puts "ERROR: Unknown IPTCL variable: $setvar"
	
						exit 1
					}

					set value $local_core_sub_params($setvar)
					set modified_line [ string map "\$$setvar $value" $line ]
				}
			}

			if {$out_line == 1 && $skip_to_end == 0} {
				puts $outtcl $modified_line
			}
		}

		if { $ifdef_level != 0 } {
			puts "ERROR: non-zero ifdef_level processing $infull_name!!!"

			exit 1
		}

		close $intcl
		close $outtcl

	}

}

proc ::alt_mem_if::util::iptclgen::parse_tcl_params {module indir outdir infile_list {core_params_list [list] } } {

	set known_params [get_parameters]
	
	set generated_files [list]
	
	foreach infile_name $infile_list {

		set infull_name [file join $indir $infile_name]

		_dprint 1 "Preparing to run parse_tcl_params on $infile_name"
		_dprint 1 "Source Dir = $indir"
		_dprint 1 "Dest Dir = $outdir"
		_dprint 1 "IFDEF list = $core_params_list"

		set outfile_name [ string map "memphy $module" $infile_name ]

		set outfile_name [file join $outdir $outfile_name]
		set outfile_name_tmp "${outfile_name}.tmp"
		
		lappend generated_files $outfile_name

		set outtcl [open "$outfile_name_tmp" w]

		_dprint 1 "Preparing to create $outfile_name"

		set intcl [open "$infull_name" r]

		set skip_to_end 0
		set ifdef_level 0

		set spaces "\[ \t\n\]"
		set notspaces "\[^ \t\n\]"

		while {[gets $intcl line] != -1} {
			set out_line 1	

			_dprint 2 "LINE: $line"

			if {![regexp "^${spaces}*#.*" $line matchvar]} {

				if {[regexp -- "${spaces}*`ifdef${spaces}+(${notspaces}+)${spaces}*" $line matchvar ifdef] } {

					set out_line 0
					incr ifdef_level

					if { $skip_to_end == 0 } {
						if {[lsearch $core_params_list $ifdef ] == -1} {
							incr skip_to_end
						}		
					} else {
						incr skip_to_end
					}
				}

				if {[regexp -- "${spaces}*`endif${spaces}*" $line matchvar] } {
					set out_line 0							
						
					if {$skip_to_end > 0} {	
						incr skip_to_end -1 
					}

					incr ifdef_level -1
				}

				if {[regexp -- "${spaces}*`else${spaces}*" $line matchvar] } {

					set out_line 0
					if {$skip_to_end == 1} {
						incr skip_to_end -1
					} else {
						if {$skip_to_end ==0} {
							incr skip_to_end
						}
					}
				}
			}

			_dprint 2 "skip_to_end: $skip_to_end"

			if {$out_line == 1 && $skip_to_end == 0} {
				set modified_line $line
				if {[regexp "memphy_${notspaces}*\.tcl" $line] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp "memphy${notspaces}*\.sdc" $line] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp "^proc${spaces}+memphy_" $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_get_ddr_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_initialize_ddr_db} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_verify_ddr_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_get_all_instances_dqs_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_dump_all_pins} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_dump_static_pin_map} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_sdc_cache} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_ddr_db} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {memphy_sort_proc} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
				} elseif {[regexp {(\smemphy_\w+\s])|([memphy_\w+])} $line] } {
                    set modified_line [ string map "memphy_ ${module}_" $line ] 
                    set line $modified_line
                }

				if {[regexp {memphy_pll} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}

				if {[regexp {memphy_clkbuf} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}
					
				if {[regexp {memphy_leveling_clock} $line matchvar ] } {
					set modified_line [ string map "memphy $module" $line ]
					set line $modified_line
				}

			 	if {[regexp {::GLOBAL_} $line matchvar ] } {
					set modified_line [ string map "::GLOBAL_ ::GLOBAL_${module}_" $line ]
					set line $modified_line
				} 

				if {[regexp "^${spaces}*set${spaces}+${notspaces}+${spaces}+IPTCL_(${notspaces}+)" $line matchvar setvar] } {
					if { [lsearch -exact $known_params $setvar] == -1 } {
						_error "found set-IPTCL expression but no known parameter is defined for $setvar"
					}

					_dprint 2 "setvar = $setvar"
	
					set value [get_parameter_value $setvar]
					set modified_line [ string map "\$$setvar $value" $line ]
				}
			}

			if {$out_line == 1 && $skip_to_end == 0} {
				puts $outtcl $modified_line
			}
		}

		if { $ifdef_level != 0 } {
			_error "non-zero ifdef_level processing $infull_name!!!"
		}

		close $intcl
		close $outtcl
		
		file rename -force $outfile_name_tmp $outfile_name

	}

	return $generated_files
}

proc ::alt_mem_if::util::iptclgen::compute_temp_ver_code {family} {

	set randNum [expr { 1+ int(2147483647 * rand()) }]
	set key_mod [expr {$randNum % 97}]
	set key $randNum
		
	if {[string compare -nocase $family arriaiigz] == 0} {
		set key [expr {$randNum - $key_mod + 13}]
	} else {
		if {$key_mod == 13} {
			set newrand [expr {1+ int(95 * rand())}]
			set key [expr {$randNum + $newrand}]
		}
	}

	return $key

}


proc alt_mem_if::util::iptclgen::sub_strings {src_file_name dest_file_name string_list} {

	set global_prefix IPTCL

	set kvp_list [split $string_list ","]
	array set kvp_array [list]

	foreach kvp $kvp_list {
		set kv_pair_list [split $kvp "="]

		set key_string [string trim [lindex $kv_pair_list 0]]
		set val_string [string trim [lindex $kv_pair_list 1]]

		if {[string compare $val_string ""] != 0} {
			set key_string "${global_prefix}_${key_string}"
			array set kvp_array [list $key_string $val_string]
		}
	}

	set temp_dest_file_name "${dest_file_name}.tmp"
	set dest_file [open "$temp_dest_file_name" w]
	set src_file [open "$src_file_name" r]

	while {[gets $src_file line] != -1} {
		set line [string map [array get kvp_array] $line]
		puts $dest_file $line
	}

	close $dest_file
	close $src_file

	catch {file delete -- $src_file_name} temp_result
	catch {file delete -- $dest_file_name} temp_result
	catch {file rename -force -- $temp_dest_file_name $dest_file_name} temp_result
}

proc alt_mem_if::util::iptclgen::sub_strings_params {src_file_name dest_file_name {extra_params_list -1} {ignore_missing 0}} {

	::alt_mem_if::util::list_array::array_clean extra_params_array
	if {$extra_params_list != -1} {
		for {set i 0} {$i < [llength $extra_params_list]} {incr i 2} {
			set key_name [lindex $extra_params_list $i]
			set value [lindex $extra_params_list [expr {$i + 1}]]
			_dprint 1 "Initializing extra param data $key_name = $value"
			set extra_params_array($key_name) $value
		}
	}
	
	set global_prefix IPTCL

	set spaces "\[ \t\n\]"
	set notspaces "\[^ \t\n^;^\"\]"
	
	set known_params [list]
	if {[llength [info commands get_parameters]] == 1} {
		set known_params [get_parameters]
	}

	_dprint 1 "Preparing to read $src_file_name"
	_dprint 1 "Output file $dest_file_name"

	set temp_dest_file_name "${dest_file_name}.tmp"

	_dprint 1 "Creating temporary file $temp_dest_file_name"
	set dest_file [open "$temp_dest_file_name" w]
	set src_file [open "$src_file_name" r]


	while {[gets $src_file line] != -1} {
		_dprint 2 "Inline: $line"
		while { [regexp -- "${global_prefix}_(${notspaces}+)" $line match param_name] == 1 } {
			if { [lsearch $known_params $param_name] != -1 } {
				_dprint 2 "Found $global_prefix for param $param_name"
				
				set value [get_parameter_value $param_name]
			} elseif {[info exists extra_params_array($param_name)] == 1} {
				_dprint 2 "Using extra params array entry for $param_name"
				
				set value $extra_params_array($param_name)
			} else {
				if {$ignore_missing != 1} {
					_error "Found parameter $param_name in $src_file_name but parameter is not defined!"
				} else {
					set value "${global_prefix}_${param_name}"
					break
				}
			}
			
			set line [string map [list "${global_prefix}_${param_name}" $value] $line]
		}
		_dprint 2 "Outline: $line"
		puts $dest_file $line
	}

	close $dest_file
	close $src_file

	catch {file delete -- $src_file_name} temp_result
	catch {file rename -force -- $temp_dest_file_name $dest_file_name} temp_result
}

proc alt_mem_if::util::iptclgen::generate_vhdl_simgen_model {files temp_dir family top_level_name result_dir blackbox} {
	set blackbox_list [split $blackbox ","]
	set file_list [split $files ",\" "]
	
	return [alt_mem_if::util::iptclgen::generate_simgen_model $file_list $temp_dir $family $top_level_name $blackbox_list]

}

proc alt_mem_if::util::iptclgen::generate_simgen_model {file_list temp_dir family top_level_name blackbox_list} {

    set qbindir [get_quartus_bindir]
	set qmap_path [file join $qbindir quartus_map]
	
	set qmap_qini "--ini=disable_check_quartus_compatibility_qsys_only=on"

	_iprint "Generating VHDL simgen model"


	set curdir [pwd]
	cd $temp_dir

	set script_name [file join $temp_dir "proj.tcl"]
	set FH [open $script_name w]

	puts $FH "project_new $top_level_name -overwrite"

	puts $FH "set_global_assignment -name COMPILER_SETTINGS $top_level_name"
                                                                             
	puts $FH "set_global_assignment -name FAMILY $family"
	puts $FH "set_global_assignment -name DEVICE AUTO"
	puts $FH "set_global_assignment -name FITTER_EFFORT \"STANDARD FIT\""
	puts $FH "set_global_assignment -name RESERVE_ALL_UNUSED_PINS \"AS INPUT TRI-STATED\""

	puts $FH "set_global_assignment -name VERILOG_MACRO \"SIMGEN=1\""
	puts $FH "set_global_assignment -name VERILOG_MACRO \"SYNTH_FOR_SIM=1\""

	if {[llength $blackbox_list] == 0} {
		set bb_arg ""
		set init_arg ""
	} else {
		set bb_arg {--simgen_arbitrary_blackbox=+}
		append bb_arg [join $blackbox_list ";+"]
		set simgen_init [file join $temp_dir simgen_init.txt]
		set init_arg "SIMGEN_INITIALIZATION_FILE=$simgen_init,"
		set fd [open $simgen_init "w"]
		foreach bb $blackbox_list {
      		puts $fd "DECLARE_VHDL_COMPONENT=$bb"
		}
		close $fd
	}

	
	foreach fname $file_list {
		if {[regexp -nocase "\\.vh?\[ \t\]*$" $fname] } {
			puts $FH "set_global_assignment -name VERILOG_FILE ${fname}"
		} elseif {[regexp -nocase "\\.vh\[do\]\[ \t\]*$" $fname] } { 
			puts $FH "set_global_assignment -name VHDL_FILE ${fname}"
		} elseif {[regexp -nocase "\\.sv\[ \t\]*$" $fname] } {          
			puts $FH "set_global_assignment -name SYSTEMVERILOG_FILE ${fname}"
		} else {
			_iprint "Ignoring file $fname for simgen"
		}
	}

	close $FH
	alt_mem_if::util::iptclgen::run_quartus_tcl_script $script_name

	
	set cmd [list $qmap_path "${top_level_name}.qpf" "--simgen" "$qmap_qini" "--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=VHDL"]
	if {[string compare $bb_arg ""] != 0} {
		lappend cmd "$bb_arg"
	}
	_dprint 1 "Command: $cmd"

	set fh [open "run_simgen_cmd.tcl" w]
	if {[string compare $bb_arg ""] == 0} {
		puts $fh "catch \{ eval \[list exec \"$qmap_path\" \"${top_level_name}.qpf\" \"--simgen\" \"$qmap_qini\" \{--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=VHDL\} \]\} temp"
	} else {
		puts $fh "catch \{ eval \[list exec \"$qmap_path\" \"${top_level_name}.qpf\" \"--simgen\" \"$qmap_qini\" \{--simgen_parameter=${init_arg}CBX_HDL_LANGUAGE=VHDL\} \{$bb_arg\} \]\} temp"
	}
	puts $fh "puts \$temp"
	close $fh

	set resultout [alt_mem_if::util::iptclgen::run_quartus_tcl_script "run_simgen_cmd.tcl"]
	
	_iprint $resultout

	if {[regexp -nocase {Quartus II.*Analysis \& Synthesis was successful} $resultout junk] == 0} {
		_eprint "Simgen failed" 1
	} else {
		_iprint "Simgen was successful"
	}
}



proc alt_mem_if::util::iptclgen::compute_pll {family speed_grade pll_type input_freq output_freqs output_phases temp_dir} {

	set output_freq_list [split $output_freqs ",\" "]
	set output_phase_list [split $output_phases ",\" "]
	
	return [compute_pll_params $family $speed_grade $pll_type $input_freq $output_freq_list $output_phase_list $temp_dir]
}

proc alt_mem_if::util::iptclgen::compute_pll_params {family speed_grade pll_type input_freq output_freq_list output_phase_list temp_dir {hcx_compat_mode 0} {prepend_str ""}} {

	_dprint 1 "Computing PLL parameters"
	_dprint 1 "Using Family $family"
	_dprint 1 "Using SpeedGrade $speed_grade"

	if {[string compare -nocase $family stratixv] == 0 || [string compare -nocase $family arriavgz] == 0} {
		set tap 0

		foreach output_freq $output_freq_list {
		
			set mult_param [lindex [split [expr [expr $output_freq * 1000000] / $input_freq] "."] 0]
			set div_param 1000000
			set phase_param [expr [expr 1000000 / $output_freq] * [lindex $output_phase_list $tap] / 360]

			_dprint 1 "making fake pll:  $mult_param $div_param $phase_param"

			set real_params [list $mult_param $div_param $phase_param]
			set real_params_list [lappend real_params_list $real_params]
			incr tap	
		}
	} else {
		set temp_rand_num [expr {int(100000 * rand())}]
		set temp_file_name "temp_${temp_rand_num}.pp"
		set temp_full_name [file join $temp_dir $temp_file_name]
		
		
		catch {file delete -force -- $temp_full_name}

		set out_pp [open $temp_full_name w]

		_dprint 1 "synthesize [llength $output_freq_list] period [expr {1000000 / $input_freq}]"
		puts $out_pp "synthesize [llength $output_freq_list] period [expr {1000000 / $input_freq}]"

		set tap 0
		foreach output_freq $output_freq_list {
			
			set mult_param [lindex [split [expr [expr $output_freq * 1000] / $input_freq] "."] 0]
			set div_param 1000
			set phase_param [lindex $output_phase_list $tap]
				
			set phase_relative_to_input_freq [expr {$phase_param * 1.0 * $input_freq / $output_freq}]
			set phase_relative_to_input_freq [format %.3f $phase_relative_to_input_freq]
				
			_dprint 1 "tap $tap mult $mult_param div $div_param duty 50 phase $phase_relative_to_input_freq"
			puts $out_pp "tap $tap mult $mult_param div $div_param duty 50 phase $phase_relative_to_input_freq"

			incr tap		
		}

		puts $out_pp ""
		close $out_pp
			
		_dprint 1 "pwd is [pwd]"
		_dprint 1 "tempdir is $temp_dir"
        set qbindir [get_quartus_bindir]
		
		
		set formatted_family $family
		regsub -all {[\}\{]+} $formatted_family "" formatted_family
			
		_dprint 1 "Using formatted family $formatted_family"

		set cmd_line [join [list ${qbindir}/pll_cmd "-use_pll_manager" "-family" $formatted_family "-speed_grade" $speed_grade "-type" $pll_type -enforce_user_phase_shift $temp_full_name]]
		_dprint 1 "Preparing to run $cmd_line"
		
		if {$hcx_compat_mode} {
			set temp_full_name_mif [file join $temp_dir $prepend_str]
			set status [catch {exec -- ${qbindir}/pll_cmd "-generate_mif_file" $temp_full_name_mif "MIF" "-use_pll_manager" "-family" $formatted_family "-speed_grade" $speed_grade "-type" $pll_type -enforce_user_phase_shift $temp_full_name} resultout]
		} else {
			set status [catch {exec -- ${qbindir}/pll_cmd "-use_pll_manager" "-family" $formatted_family "-speed_grade" $speed_grade "-type" $pll_type -enforce_user_phase_shift $temp_full_name} resultout]
		}

		catch {file delete -force -- $temp_full_name}

		set output_lines [split $resultout "\n"]

		set real_params_list [list]
		set found_real 0
		set found_fail 0
		set tap 0
		_dprint 1 "Preparing to read output of pll_cmd()"
		foreach outline $output_lines {
			_dprint 1 "$outline"
			if {[regexp {.*Real User Properties.*} $outline matchvar] } {
				set found_real 1
				_dprint 1 "Successfully created PLL with the following clocks:"
			}

			if {$found_real == 1} {
				set spaces " \t"
				set notspaces "a-zA-Z0-9_"
				set digits "0-9"
				if {[regexp ".*tap\[${spaces}\]+\[${digits}\]+\[${spaces}\]+mult\[${spaces}\]+(\[${digits}\]+)\[${spaces}\]+div\[${spaces}\]+(\[${digits}\]+)\[${spaces}\]+duty\[${spaces}\]+\[${digits}\]+\[${spaces}\]+phase\[${spaces}\]+(\[-\]?\[${digits}\]+(\\.\[${digits}\]+)?).*" $outline matchvar mult_real div_real phase_real] } {
						
					set freq [format %.4f [expr {1.0 * ($input_freq * $mult_real) / $div_real}]]
						
					set phase_relative_to_output_freq [expr {$phase_real * 1.0 * $freq / $input_freq}]
					set phase_ps [format %.0f [expr {$phase_relative_to_output_freq / 360.0 * 1000000.0 / $freq} ]]

					if {int(abs($phase_relative_to_output_freq - [lindex $output_phase_list $tap])) % 360 > 15} {
						_dprint 1 "Clock $tap could not be generated with the requested phase of [lindex $output_phase_list $tap] degrees"
					}
						
					_dprint 1 "$freq MHz with $phase_relative_to_output_freq degrees ($phase_ps ps) of phase shift"
					_dprint 1 "computed $mult_real $div_real $phase_relative_to_output_freq $phase_ps"
					set real_params [list $mult_real $div_real $phase_ps $freq]
					set real_params_list [lappend real_params_list $real_params]

					incr tap
				}
			}
		}

		if {$found_real!=1} {
			_eprint "PLL could not be generated with requested input and output clocks"
		}
	}

	_dprint 1 "PLL parameters: $real_params_list"

	return $real_params_list
}


proc alt_mem_if::util::iptclgen::advertize_file {valid_filesets filename src_fulldir dest_subdir fileset args} {

	set postfix ""
	set force_type ""
	
	if { [llength $args] == 2} {
		set postfix [lindex $args 0]
		set force_type [lindex $args 1]
	}

	if {[lsearch -exact [split $valid_filesets ","] "QUARTUS_SYNTH"] != -1 ||
	    [lsearch -exact [split $valid_filesets ","] "SIM_VHDL"] != -1} {
		if {[regexp ".*\\.((v)|(sv)|(vh)|(vhd)|(vho))\[ \t\]*$" $filename] } {
			lappend ::simgen_list [file join $src_fulldir $filename]
		}
	}

	if {[lsearch -exact [split $valid_filesets ","] $fileset] != -1} {

		if {[regexp {.*\.vh[do]} $filename] } {
			set file_type "VHDL"
		} elseif {[regexp {.*\.vh?} $filename] } {
			set file_type "VERILOG"
		} elseif {[regexp {.*\.hex} $filename]} {
			set file_type "HEX"
		} elseif {[regexp {.*\.sdc} $filename]} {
			set file_type "SDC"
		} elseif {[regexp {.*\.sv} $filename]} {
			set file_type "SYSTEM_VERILOG"
		} else {
			set file_type "OTHER"
		}

		if {[string compare -nocase $fileset "EXAMPLE_DESIGN"] == 0 && [string compare -nocase $valid_filesets "EXAMPLE_DESIGN"] == 1} {
			if {[regexp {.*\.vh[do]} $filename] } {
				set file_type_qip "VHDL_FILE"
			} elseif {[regexp {.*\.vh?} $filename] } {
				set file_type_qip "VERILOG_FILE"
			} elseif {[regexp {.*\.sdc} $filename]} {
				set file_type_qip "SDC_FILE"
			} elseif {[regexp {.*\.tcl} $filename]} {
				set file_type_qip "TCL_FILE"
			} elseif {[regexp {.*\.sv} $filename]} {
				set file_type_qip "SYSTEMVERILOG_FILE"
			} else {
				set file_type_qip "SOURCE_FILE"
			}

			if {[string length $force_type] != 0} {
				regsub {\.} $filename "$postfix." qip_dest_filename
			} else {
				set qip_dest_filename $filename
			}
			if {[string length $force_type] != 0} {
				set file_type_qip $force_type
			} 


			append ::example_design_memif_qipfile_contents "set_global_assignment -name $file_type_qip \[file join \$::quartus(qip_path) [file join $dest_subdir $qip_dest_filename]\] -library lib_${::mod_name}\n"
		}

		if {[string length $force_type] != 0} {
			regsub {\.} $filename "$postfix." dest_filename
		} else {
			set dest_filename $filename
		}
		if {[string length $force_type] != 0} {
			set file_type $force_type
		}
		
		add_fileset_file [file join $dest_subdir $dest_filename] $file_type PATH [file join $src_fulldir $filename]
	}
}


proc alt_mem_if::util::iptclgen::advertize_directory {valid_filesets dirname src_fulldir dest_subdir fileset args} {
	foreach filename_full [glob -nocomplain [file join $src_fulldir $dirname "*"]] {
		set filename [file tail $filename_full]
		if {[file isdirectory $filename_full] && [string compare $filename "."] != 0 && [string compare $filename ".."] != 0} {
			advertize_directory $valid_filesets [file join $dirname $filename] $src_fulldir $dest_subdir $fileset [lindex $args 0] [lindex $args 1]
		} elseif {[file isfile $filename_full]} {
			advertize_file $valid_filesets $filename [file join $src_fulldir $dirname] [file join $dest_subdir $dirname] $fileset [lindex $args 0] [lindex $args 1]
		}
	}
}

proc alt_mem_if::util::iptclgen::get_filenames_in_directory {dir_name dir_base_name} {
	set file_list [list]
	foreach filename_full [glob -nocomplain -- [file join $dir_base_name $dir_name "*"]] {
		set filename [file tail $filename_full]
		if {[file isdirectory $filename_full] && [string compare $filename "."] != 0 && [string compare $filename ".."] != 0} {
			set file_list [concat $file_list [alt_mem_if::util::iptclgen::get_filenames_in_directory $filename_full $filename]]
		} elseif {[file isfile $filename_full]} {
			lappend file_list $filename_full
		}
	}
	return $file_list
}


proc alt_mem_if::util::iptclgen::get_quartus_bindir {} {

    set QUARTUS_ROOTDIR $::env(QUARTUS_ROOTDIR)

    set PLATFORM $::tcl_platform(platform)
    if { $PLATFORM == "java" } {
        set PLATFORM $::tcl_platform(host_platform)
    }

    if { [catch {set QUARTUS_BINDIR $::quartus(binpath)} errmsg] } {
        if { $PLATFORM == "windows" } {
            set BINDIRNAME "bin"
        } else {
            set BINDIRNAME "linux"
        }

        if { [catch {set WORDSIZE $::tcl_platform(wordSize)} errmsg] } {
            if {[string match "*64" $::tcl_platform(machine)]} {
                set WORDSIZE 8
            } else {
                set WORDSIZE 4
            }
        }
        if { $WORDSIZE == 8 } {
            set BINDIRNAME "${BINDIRNAME}64"
        }

        set QUARTUS_BINDIR "$QUARTUS_ROOTDIR/$BINDIRNAME"
    }

	return $QUARTUS_BINDIR
}

proc alt_mem_if::util::iptclgen::run_tclsh_script {filename} {
    set qbindir [get_quartus_bindir]
	set cmd [concat [list exec "${qbindir}/tclsh" $filename]]
	_dprint 1 "Running the command: $cmd"
	set cmd_fail [catch { eval $cmd } tempresult]

	set lines [split $tempresult "\n"]
	set num_errors 0
	foreach line $lines {
		_dprint 1 "Returned: $line"
		if {[regexp -nocase -- {[ ]+error[ ]*:[ ]*(.*)[ ]*$} $line match error_msg]} {
			_eprint "Error during execution of script $filename: $error_msg" 1
			incr num_errors
		} elseif {[regexp -nocase -- {^[ ]*couldn.*execute.*$} $line match]} {
			_eprint "Error during execution of script $filename: $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {child process exited abnormally} $line match]} {
			_eprint "Error during execution of script $filename: $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {Quartus II.*Shell was unsuccessful} $line match]} {
			incr num_errors
		}
	}

	if {$num_errors > 0 || $cmd_fail} {
		_eprint "Execution of script $filename failed" 1
		foreach line $lines {
			_eprint "$line" 1
		}
	} else {
		_dprint 1 "Execution of script $filename was a success"
	}

	return $tempresult
}


proc alt_mem_if::util::iptclgen::run_quartus_tcl_script {filename} {
    set qbindir [get_quartus_bindir]
	set cmd [concat [list exec "${qbindir}/quartus_sh" "-t" $filename]]
	_dprint 1 "Running the command: $cmd"
	set cmd_fail [catch { eval $cmd } tempresult]

	set lines [split $tempresult "\n"]
	set num_errors 0
	foreach line $lines {
		_dprint 1 "Returned: $line"
		if {[regexp -nocase -- {[ ]+error[ ]*:[ ]*(.*)[ ]*$} $line match error_msg]} {
			_eprint "Error during execution of script $filename: $error_msg" 1
			incr num_errors
		} elseif {[regexp -nocase -- {^[ ]*couldn.*execute.*$} $line match]} {
			_eprint "Error during execution of script $filename: $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {child process exited abnormally} $line match]} {
			_eprint "Error during execution of script $filename: $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {Quartus II.*Shell was unsuccessful} $line match]} {
			incr num_errors
		}
	}

	if {$num_errors > 0 || $cmd_fail} {
		_eprint "Execution of script $filename failed" 1
		foreach line $lines {
			_eprint "$line" 1
		}
	} else {
		_dprint 1 "Execution of script $filename was a success"
	}

	return $tempresult
}


proc alt_mem_if::util::iptclgen::generate_ip_clearbox {name param_list} {
    set qbindir [get_quartus_bindir]
	set cmd [concat [list exec "${qbindir}/clearbox" $name] $param_list]
	_dprint 1 "Running the command: $cmd"
	catch { eval $cmd } tempresult
	_dprint 1 "Returned: $tempresult"
}


proc alt_mem_if::util::iptclgen::generate_ip {name param_list} {
	set qdir $::env(QUARTUS_ROOTDIR)
	set cmd [concat [list exec "${qdir}/sopc_builder/bin/ip-generate" "--component-name=$name"] $param_list]
	_dprint 1 "Running command: $cmd"
	catch { eval $cmd } tempresult
	_dprint 1 "Returned: $tempresult"
	return $tempresult
}


proc alt_mem_if::util::iptclgen::exec_cmd {cmd} {
	_dprint 1 "Executing external command: $cmd"
	catch {eval [concat [list exec "--"] $cmd]} tempresult

	set lines [split $tempresult "\n"]
	set num_errors 0
	foreach line $lines {
		_dprint 1 "Returned: $line"
		if {[regexp -nocase -- {[ ]+error[ ]*:[ ]*(.*)[ ]*$} $line match error_msg]} {
			_eprint "Error during execution of \"$cmd\": $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {^[ ]*couldn.*execute.*$} $line match]} {
			_eprint "Error during execution of \"$cmd\": $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {child process exited abnormally} $line match]} {
			_eprint "Error during execution of \"$cmd\": $match" 1
			incr num_errors
		} elseif {[regexp -nocase -- {Quartus II.*Shell was unsuccessful} $line match]} {
			incr num_errors
		}
	}

	if {$num_errors > 0} {
		_eprint "Execution of command \"$cmd\" failed" 1
		foreach line $lines {
			_eprint "$line" 1
		}
	} else {
		_dprint 1 "Execution of command \"$cmd\" was a success"
	}

	return $tempresult
}


proc alt_mem_if::util::iptclgen::generate_outfile_name {infile ifdef_list {no_ext 0}} {
	
	set infile_dirname [file dirname $infile]
	set infile_name [file tail $infile]
	set infile_basename [file rootname $infile_name]
	set infile_ext [file extension $infile_name]
	
	set core_params $ifdef_list
	if {[llength $core_params] == 0} {
		lappend core_params "NO_IFDEF_PARAMS"
	}
	
	
	set params_text [string tolower [join [lsort $core_params] "_"]]
	
	set outfile ""
	if {$no_ext} {
		set outfile "${infile_basename}_${params_text}"
	} else {
		set outfile_name "${infile_basename}_${params_text}${infile_ext}"
		set outfile [file join $infile_dirname $outfile_name]
	}
	
	return $outfile
}


proc alt_mem_if::util::iptclgen::get_synthesis_language {} {
	set forced_language [get_parameter_value FORCE_SYNTHESIS_LANGUAGE]
	if {[string compare -nocase $forced_language "vhdl"] == 0 || [string compare -nocase $forced_language "verilog"] == 0} {
		return $forced_language
	} else {
		return {VERILOG}
	}
}


proc alt_mem_if::util::iptclgen::make_temporary_directory { {is_sopc {0}} } {
	if { $is_sopc == 1 } {
		set tmpdir [get_generation_property OUTPUT_DIRECTORY]
	} else {
		set tmpdir [add_fileset_file {} OTHER TEMP {}]
	}
	_iprint "Temporary directory is $tmpdir"
	return $tmpdir
}


proc alt_mem_if::util::iptclgen::generate_ppf_from_interface_data {external_interface_list variation_name ip_name} {

	set xml_pin_name_format "      <pin name=\"%s\" direction=\"%s\" scope=\"%s\" />\n"
	append result "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
	append result "<pinplan variation_name=\"$variation_name\" megafunction_name=\"$ip_name\" specifies=\"all_ports\">\n"
	append result "   <global>\n"
	
	set all_interfaces [get_interfaces]
	
	foreach interface $all_interfaces {
		if {[lsearch $external_interface_list $interface] >= 0} then {
			set scope "external"
		} else {
			set scope "internal"
		}

		set interface_ports [get_interface_ports $interface]
		foreach port $interface_ports {
			set port_direction [get_port_property $port DIRECTION]
			set width [get_port_property $port WIDTH_EXPR]
			set vhdl_type [get_port_property $port VHDL_TYPE]
				switch $port_direction {
				"Input" { set direction "input"}
				"Output" { set direction "output"}
				"Bidir" { set direction "bidir"}
				default {
					_eprint "Unknown direction property \[$port_direction\] on port \[$port\]"
				}
			}
  
			if {($width == 1) && ($vhdl_type != "STD_LOGIC_VECTOR")} then {
				append result [format $xml_pin_name_format $port $direction $scope]
			} else {
				set name [format "%s\[%d..0\]" $port [expr {$width - 1}]]
				append result [format $xml_pin_name_format $name $direction $scope]
				
				for { set i 0 } { $i < $width } { incr i } {
					set name [format "%s\[%d\]" $port $i]
					append result [format $xml_pin_name_format $name $direction $scope]
				}
			}
		}
	}
	
	append result "   </global>\n"
	append result "</pinplan>\n"
	return $result
}


proc alt_mem_if::util::iptclgen::emulate_add_fileset_file_text {output_name file_type source_text tmpdir} {
	set file_name "$tmpdir/$output_name"
	set FH [open "$file_name" w]
	puts $FH $source_text
	close $FH

	add_file $file_name $file_type
}

