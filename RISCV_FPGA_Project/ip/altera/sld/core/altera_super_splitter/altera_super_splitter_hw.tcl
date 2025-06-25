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


# $Id: //acds/rel/13.1/ip/sld/core/altera_super_splitter/altera_super_splitter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact qsys 12.1
package require altera_terp 1.0

#  -----------------------------------
# | altera_debug_config_rom
#  -----------------------------------
set_module_property name altera_super_splitter
set_module_property version 13.1
set_module_property group "Verification/Debug & Performance"
set_module_property display_name "Splitter for debug fabric"
set_module_property editable false
set_module_property internal true
set_module_property elaboration_callback elaborate

set_module_assignment debug.isTransparent true

add_fileset synth quartus_synth generate "Quartus Synthesis"

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter COUNT integer 1 "Number of nodes"
add_parameter MAX_WIDTH integer 4 "Maximum width of any node"
add_parameter FRAGMENTS string "" "Which ports are on each node"

#  -----------------------------------
# | interfaces
#  -----------------------------------
add_interface nodes conduit end
add_interface_port nodes send send Input COUNT*MAX_WIDTH
add_interface_port nodes receive receive Output COUNT*MAX_WIDTH

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
	set count [get_parameter_value COUNT]
	set max_width [get_parameter_value MAX_WIDTH]
	set fragments [get_parameter_value FRAGMENTS]

	for {set i 0} {$i < $count} {incr i} {
		set frags ""
		catch {
			set frags [lindex $fragments $i]
		}
		foreach frag $frags {
			array set f {clock "" reset "" properties "" assign "" moduleassign ""}
			array set f $frag
			set name  $f(name)
			set type  $f(type)
			if {$name=="" || $type==""} {
				continue
			}

			set idir  $f(dir)
			set ports $f(ports)

			#send_message {info text} "add_interface ${name}_$i $type $idir"
			add_interface ${name}_$i $type $idir

			foreach port $ports {
				set pname [lindex $port 0]
				set role  [lindex $port 1]
				set dir   [lindex $port 2]
				set width [lindex $port 3]
				set base  [lindex $port 4]
		
				if {$dir=="out"} {
					set pdir Output
				} else {
					set pdir Input
				}
		
				add_interface_port ${name}_$i ${pname}_$i $role $pdir $width
			}

			set props $f(properties)
			foreach prop $props {
				set key   [lindex $prop 0]
				set value [lindex $prop 1]
				#send_message info "set_interface_property ${name}_$i $key $value"
				set_interface_property ${name}_$i $key $value
			}
		
			if {$f(clock) != ""} {
				set clock $f(clock)
				# Only decorate clock if it does not have a number
				if {[regexp {[[:<:]][[:alpha:]]+[[:>:]]} $clock]} {
					set clock ${clock}_$i
				}
				#send_message info "set_interface_property ${name}_$i associatedClock $clock"
				set_interface_property ${name}_$i associatedClock $clock
			}
			if {$f(reset) != ""} {
				set_interface_property ${name}_$i associatedReset $f(reset)_$i
			}
			set ia $f(assign)
			for {set j 0} {$j + 1 < [llength $ia]} {incr j} {
				set n [lindex $ia $j]
				incr j
				set v [lindex $ia $j]
				set_interface_assignment ${name}_$i $n $v
			}
			set ma $f(moduleassign)
			for {set j 0} {$j + 1 < [llength $ma]} {incr j} {
				set n [lindex $ma $j]
				incr j
				set v [lindex $ma $j]
				set_module_assignment $n $v
			}
		}
	}
}

#  -----------------------------------
# | Generation callback
#  -----------------------------------
proc generate output_name {
    set this_dir      [get_module_property MODULE_DIRECTORY]
    set template_file [file join $this_dir "altera_super_splitter.sv.terp"]

    set template    [read [ open $template_file r ] ]

	set count [get_parameter_value COUNT]
	set max_width [get_parameter_value MAX_WIDTH]
	set fragments [get_parameter_value FRAGMENTS]
	
	set ports ""
	set assigns ""
	
	set max [expr {$count * $max_width}]
	for {set j 0} {$j < $max} {incr j} {
		array set unused [list $j 1]
	}
	
	for {set i 0} {$i < $count} {incr i} {
		set frags ""
		catch {
			set frags [lindex $fragments $i]
		}
		foreach frag $frags {
			array set f {clock "" reset "" assign ""}
			array set f $frag
			set name  $f(name)
			set type  $f(type)
			if {$name=="" || $type==""} {
				continue
			}

			set pp $f(ports)

			#send_message {info text} "add_interface ${name}_$i $type"

			foreach port $pp {
				set pname [lindex $port 0]
				set dir   [lindex $port 2]
				set width [lindex $port 3]
				set base  [lindex $port 4]
		
				set j [expr {$base + $i * $max_width}]

				if {$width==1} {
					set bus "     "
					set slice "\[$j\]"
				} else {
					set msb [expr {$width - 1}]
					set bus "\[$msb:0\]"
					set slice "\[$j+:$width\]"
				}

				if {$dir=="out"} {
					lappend ports "output $bus ${pname}_$i"
					lappend assigns "${pname}_$i = send$slice"
				} else {
					lappend ports "input  $bus ${pname}_$i"
					lappend assigns "receive$slice = ${pname}_$i"
				
					for {set k 0} {$k < $width} {incr k} {
						array unset unused $j
						incr j
					}
				}
			}
		}
	}

	# Put 0 into unused bits	
	while {[array size unused] > 0} {
		set bits [lsort -integer [array names unused] ]
		set start [lindex $bits 0]
		
		for {set j 0; set k $start} {$j < [llength $bits] && [lindex $bits $j] == $k} {incr j; incr k} {
			array unset unused $k  		
		} 
		
		lappend assigns "receive\[$start+:$j\] = $j'b0"
	}

    # Collect parameter values for Terp
    set params(output_name) $output_name
	set params(count) $count
	set params(max_width) $max_width
	set params(ports) $ports
	set params(assigns) $assigns
	
	set result [altera_terp $template params]

    add_fileset_file ${output_name}.sv system_verilog text $result top_level_file
}
