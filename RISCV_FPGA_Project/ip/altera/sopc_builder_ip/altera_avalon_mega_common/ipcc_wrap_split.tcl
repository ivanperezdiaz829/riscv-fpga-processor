# +-----------------------------------
# | 
# | ipcc bus split/concat wrapper generator common code
# |
# | $Header: //acds/rel/13.1/ip/sopc/components/altera_avalon_mega_common/ipcc_wrap_split.tcl#1 $
# | 
# +-----------------------------------

set ipcc_l_mapped_ports [list]
set ipcc_module {top}
array set ipcc_port_termination_value {}

# +-----------------------------------
# | 
# | Add mapped ports to a real interface.  They are virtual because hw.tcl
# | does not yet support splitting and concatenation of HDL ports to
# | hw.tcl interfaces
# |
# | arguments are:
# | add_interface_mapped_port <interface_name> <hdl_port_name> <interface_port_role> <input|output> <final_width>
# |
# | commonly used interface roles include {clk, address, readdata, writedata, read, write, ST: data}
# | 
# +-----------------------------------
proc ipcc_add_interface_mapped_port {if_name hdl_portname if_role port_direction final_width} {
	global ipcc_l_mapped_ports
	lappend ipcc_l_mapped_ports [ list $if_name $hdl_portname $if_role $port_direction $final_width ]
	#send_message info "add_interface_mapped_port{}: $ipcc_l_mapped_ports"
}

# turn the mapping data into elaboration-callback interface port declarations
proc ipcc_elaboration_declarations {} {
	ipcc_port_mappings elaboration
}

# +-----------------------------------
# | 
# | Turn the mapping data into interface port declarations
# |
# | During elaboration, defines the interface ports from the collected data.
# | During generation, returns array data with HDL to interface port mappings as follows:
# |
# |   - HDL slice to interface data port: {h split}
# |   array("HDL_port_name") <- [list "0/4@ifportname" "1/4@ifportname" "3:2/4@ifportname"]
# |
# |   - HDL port to interface data slice: {h concat}
# |   array("HDL_port_name") <- [list "ifportname[2:0]"]
# |
# |   - HDL port to interface data, no slice: {h replication?}
# |   array("HDL_port_name") <- [list "ifportname"]
# |
# +-----------------------------------
proc ipcc_port_mappings {flag} {
	global ipcc_l_mapped_ports
	array set hdl_ports {}	;# used for cases of splitting HDL ports into multiple interfaces
	array set if_ports {}	;# used for cases of combining HDL ports into a single interface
	
	foreach l $ipcc_l_mapped_ports {
		#send_message info "ipcc_port_mappings{mapped_port}: $l"
		foreach {if_name hdl_portname if_role port_direction final_width} $l {
			set role [split $if_role @]	;# a slice of a role port will be represented as role@<n> or role@<n>:<m>
			set hdlport [split $hdl_portname @]
			
			# Is this an assignment to a slice of an interface role port?
			if { [llength $role] > 1 } {
				# slice of an interface role port assigned to an HDL port
				set real_role [lindex $role 0]
				set ifportname "${if_name}_${real_role}"
				#send_message info "ipcc_port_mappings{h concat}: $hdl_portname <-> $if_name:$if_role"
				
				# declare interface port if it hasn't already been declared
				if {$flag == "elaboration"} {
					if {! [info exists if_ports($ifportname)] } {
						# declare interface port, mark as declared
						set if_ports($ifportname) "[lindex $role 1]/${final_width}@${hdl_portname}"
						set cmd "add_interface_port $if_name $ifportname ${real_role} $port_direction $final_width"
						#send_message info "ipcc_port_mappings{h concat}: $cmd"
						eval $cmd
					}
				} else {
					# Verilog connection equivalent for generation, HDL port to interface data slice
					set hdl_ports($hdl_portname) "${ifportname}\[[lindex $role 1]\]"
				}
			} elseif { [llength $hdlport] > 1 } {
				# slice of an HDL port assigned to an interface role
				set ifportname [string map {@ _ : _} $hdl_portname]
				if {$flag == "elaboration"} {
					set slice_width 1	;# start by assuming single-bit slice
					set hdlport_indices [split [lindex $hdlport 1] ':']
					if {[llength $hdlport_indices] > 1 } {
						# get width of multi-bit slice
						set slice_width [expr 1 + [lindex $hdlport_indices 0] - [lindex $hdlport_indices 1]]
					}
					set cmd "add_interface_port $if_name $ifportname $if_role $port_direction $slice_width"
					#send_message info "ipcc_port_mappings{h split}: $cmd"
					eval $cmd
				} else {
					lappend hdl_ports([lindex $hdlport 0]) "[lindex $hdlport 1]/$final_width@$ifportname"
					#send_message info "ipcc_port_mappings{h split}: lappend hdl_ports([lindex $hdlport 0]) with '[lindex $hdlport 1]/$final_width@$ifportname'"
				}
			} else {
				# no mapping was needed, just turn into declaration as-is
				if {$flag == "elaboration"} {
					set cmd "add_interface_port $if_name $hdl_portname $if_role $port_direction $final_width"
					#send_message info "ipcc_port_mappings{else}: $cmd"
					eval $cmd
				} else {
					lappend hdl_ports($hdl_portname) $ifportname	;# might be replicated output
				}
			}
		}
	}
	return [array get hdl_ports]
}

# +-----------------------------------
# | 
# | initialize the mappings data to an empty set
# | 
# +-----------------------------------
proc ipcc_init_mappings { flag } {
	global ipcc_l_mapped_ports
	global ipcc_port_termination_value
	#if { $flag == "elaboration" }
	set ipcc_l_mapped_ports [list]
	#send_message info "ipcc_port_termination_value array size: [array size ipcc_port_termination_value]"
	if { [array size ipcc_port_termination_value] > 0 } {
		array unset ipcc_port_termination_value ;# array set ipcc_port_termination_value {}
	}
}

# +-----------------------------------
# | 
# | set the top-level module for the generation callback HDL writer
# | 
# +-----------------------------------
proc ipcc_set_module { top_module } {
	global ipcc_module	;# top-level module name
	set ipcc_module $top_module
}

# +-----------------------------------
# | 
# | Generate an HDL wrapper from static ports and parameter, and from the mapping data
# | 
# +-----------------------------------
proc ipcc_generate_hdl_wrapper {} {
	global ipcc_l_mapped_ports	;# raw port mapping data
	global ipcc_module	;# top-level module name
	
	set hdl_params [ipcc_get_hdl_params]
	set path_name [get_generation_property OUTPUT_DIRECTORY] 
	set output_name [get_generation_property OUTPUT_NAME] 
	set hdl_file "$path_name${output_name}.v"	;# Verilog only for wrapper
	
	if [ catch {open $hdl_file w} fid ] {
		send_message error "ipcc_generate_hdl_wrapper{}: Couldn't open file '$hdl_file' for writing: $fid"
	} else {
		#send_message info "ipcc_generate_hdl_wrapper{}: writing '$hdl_file'"
		puts $fid "`timescale 1ns/10ps"
		puts $fid "module  ${output_name}("

		set line_cnt 0
		
		# generate the wrapper module declaration, grouped by interface
		foreach interface [get_interfaces] {
			set if_comment "\n\t// interface '$interface'"	;# save interface name for HDL
			foreach port [get_interface_ports $interface] {
				if {$line_cnt > 0} {
					puts -nonewline $fid ",\n"	;# add ',' at end of previous port name declaration
				}
				incr line_cnt
				if {[string length $if_comment] > 0} {
					puts $fid "$if_comment"
					set if_comment ""
				}

				# generate HDL port declaration
				set port_direction [string tolower [get_port_property $port DIRECTION]]
				set port_width [expr [get_port_property $port WIDTH] - 1]
				if {$port_direction == "bidir"} {
					set port_direction "inout"
                }
				if {$port_width == 0} {
					puts -nonewline $fid "\t$port_direction wire $port"
				} else {
					puts -nonewline $fid "\t$port_direction wire \[${port_width}:0\] $port"
				}
			}
		}
		puts $fid "\n);\n"

		# generate sub-module instantiation, parameters first
		set line_cnt 0
		puts $fid "\t$ipcc_module #("
		foreach param [ipcc_get_hdl_params] {
			if {$line_cnt > 0} {
				puts -nonewline $fid ",\n"
			}
			incr line_cnt
			set p_value [get_parameter_value $param]
			set p_type [get_parameter_property $param TYPE]
			if {[regexp -nocase {^(string|boolean)} $p_type ] } {
				puts -nonewline $fid "\t\t.$param\(\"${p_value}\"\)"
			} else {
				puts -nonewline $fid "\t\t.$param\(${p_value}\)"
			}
		}
		puts -nonewline $fid "\n\t)"

		set line_cnt 0
		puts $fid " ${ipcc_module}_i ("
		array set mapped_vlg_ports [ipcc_get_hdl_ports]
		#send_message info "hdl write{indices}: [array names mapped_vlg_ports]"
		foreach port [array names mapped_vlg_ports] {
			#send_message info "hdl write: $port <-> $mapped_vlg_ports($port)"
			if {$line_cnt > 0} {
				puts -nonewline $fid ",\n"
			}
			incr line_cnt
			puts -nonewline $fid "\t\t.$port\t"
			puts -nonewline $fid "($mapped_vlg_ports($port))"
		}
		puts $fid "\n\t);"
		puts $fid "endmodule\n"
		close $fid
	}
	return $hdl_file
}

# +-----------------------------------
# |  
# | get real HDL parameters
# |
# ----------------------------------------------------
proc ipcc_get_hdl_params {} {
	global ipcc_module	;# top-level module name
	set hdl_params [list]
	set parameter_set [get_parameters]	;# Get parameter set
	
	# Remove parameters that are not valid HDL parameters
	foreach param $parameter_set {
		if {[get_parameter_property $param AFFECTS_GENERATION] } {
			if {! [regexp {^gui_} $param ] } {
                #Adding this code for altera_pll megawizard
                if {$ipcc_module == "altera_pll" && [get_parameter_property $param ENABLED] } {
                    lappend hdl_params $param
                    continue
                } else {
                    continue
                }
				lappend hdl_params $param
			}
		} 
	}
	return $hdl_params
}

# +-----------------------------------
# |  
# | get real HDL ports
# |
# ----------------------------------------------------
proc ipcc_get_hdl_ports {} {
	global ipcc_port_termination_value
	set hdl_ports [list]
	array set mapped_hdl_ports [ipcc_port_mappings generation]
	array set mapped_vlg_ports {}
	array set mapped_interface_ports {}	;# mark interface ports that have complex HDL mapping
	
	# simplify port mapping list into a valid Verilog declaration
	foreach hdl_port [array names mapped_hdl_ports] {
		#send_message info "ipcc_get_hdl_ports{}: $hdl_port = $mapped_hdl_ports($hdl_port)"
		set current_hdl_port_mapping_list $mapped_hdl_ports($hdl_port)

		# check if HDL port has slice assignments '0/4@ifportname'
		if { [regexp {[@]} $current_hdl_port_mapping_list] } {
			#   - HDL slice to interface data port: {h split}
			#   array("HDL_port_name") <- [list "0/4@ifportname" "1/4@ifportname" "3:2/4@ifportname"]

			# get the sub-assignments for this HDL port
			array set port_index_array {}
			set port_index_max -1
			foreach hp $current_hdl_port_mapping_list {
				set hport [split $hp ':/@']
				set pindex [lindex $hport 0]
				set pwidth [lindex $hport end-1]
				set interface_port [lindex $hport end]
				set mapped_interface_ports($interface_port) $hdl_port	;# mark this interface port as mapped
				if {$pindex > $port_index_max} {
					set port_index_max $pindex
				}
				set port_index_array($pindex) $interface_port
				#send_message info "ipcc_get_hdl_ports{}: port_index_array($pindex) $interface_port"
			}
			
			# are all indices in HDL port represented?
			# Check for special case of high indices missing
			set hdl_concat [list]
			if {$port_index_max < [expr $pwidth - 1]} {
				lappend hdl_concat "[expr $pwidth - 1 - $port_index_max]'bz"	;# 'bz means undriven in Verilog
			}
			foreach pindex [lsort -integer -decreasing [array names port_index_array]] {
				lappend hdl_concat $port_index_array($pindex)
			}
			# convert to Verilog syntax
			set port_map "{[join $hdl_concat ", "]}"
			#send_message info "mapped_vlg_ports($hdl_port) iscat $port_map"
			set mapped_vlg_ports($hdl_port) $port_map
			array unset port_index_array
		} else {
			# assignment does not slice HDL port.  Just use mapping as-is:
			#
			#   - HDL port to interface data slice: {h concat}
			#   array("HDL_port_name") <- [list "ifportname[2:0]"]
			#
			#   - HDL port to interface data, no slice: {h replication?}
			#   array("HDL_port_name") <- [list "ifportname"]
			set mapped_vlg_ports($hdl_port) "[lindex $current_hdl_port_mapping_list 0]"
			#send_message info "mapped_vlg_ports($hdl_port) issimp $mapped_vlg_ports($hdl_port)"
			#send_message info "hdl_ports{issimp}: mapped_vlg_ports, indices: [array names mapped_vlg_ports]"

			# get real interface port name, mark it as mapped
			set ifportname [split $mapped_vlg_ports($hdl_port) "\[\]"]
			set interface_port [lindex $ifportname 0]
			#send_message info "hdl_ports: mapped_interface_ports($interface_port) = $hdl_port"
			set mapped_interface_ports($interface_port) $hdl_port	;# mark this interface port as mapped
		}
	}
	
	# add pruned list of interface ports as HDL ports
	foreach interface_port [get_module_ports] {
		if {! [info exists mapped_interface_ports($interface_port)] } {
			if { [info exists ipcc_port_termination_value($interface_port)] } {
				# port is declared as terminated with a constant or null connection
				# but also declared as an interface port -> can't be both
				send_message error "ipcc_generate_hdl{}: terminated port can't be visible"
			} else {
				# interface port is not mapped or terminated, so do direct connect
				set mapped_vlg_ports($interface_port) $interface_port
			}
			#send_message info "mapped_vlg_ports($interface_port) isdirect $interface_port"
		}
	}
	
	# add internally terminated HDL ports
	foreach terminated_port [array names ipcc_port_termination_value] {
		set mapped_vlg_ports($terminated_port) $ipcc_port_termination_value($terminated_port)
	}

	#send_message info "hdl_ports{exit}: mapped_vlg_ports, indices: [array names mapped_vlg_ports]"
	return [array get mapped_vlg_ports]
}


# +-----------------------------------
# | 
# | Set termination state for ipcc-generated wrappers
# |
# |  - <direction> legal values are "input", "output", and "remove"
# |  - termination value is ignored if <direction> is false
# |  - "false" maps to 0
# |  - "true" maps to 1
# |
# ----------------------------------------------------
array set ipcc_termination_map {
   true  1
   false 0
   null  " "
}
proc ipcc_set_port_termination {port_name termination_value direction} {
	global ipcc_port_termination_value
	global ipcc_termination_map
	if { $direction == "remove" } {
		if { [info exists ipcc_port_termination_value($port_name)] } {
			unset ipcc_port_termination_value($port_name)
			#send_message info "ipcc_port_termination(): removing termination from $port_name"
		}
	} elseif { $direction == "output" } {
		# ignore constant for outputs - just use null declaration
		set ipcc_port_termination_value($port_name) " "
	} elseif { $direction == "input" || $direction == "bidir" } {
		set ipcc_port_termination_value($port_name) $termination_value
		#send_message info "ipcc_port_termination(): $port_name = '$termination_value'"
	}
}
