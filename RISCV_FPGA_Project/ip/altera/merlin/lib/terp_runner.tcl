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


# $Id: //acds/rel/13.1/ip/merlin/lib/terp_runner.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# ----------------------------------------------
# Terp Runner
#
# For those who prefer to run terp from the command line
# instead of sourcing terp.tcl and calling the functions
# directly.
# ----------------------------------------------

proc get_ip_rootdir {} {
	global env
	return $env(IP_ROOTDIR)
}

proc help {} {
	puts "usage:  terp <filename> \[--<param>=<val>\]"
	puts "  if the 'showparams' parameter is set to 1, will"
	puts "  display a list of parameters instead of generating."
}

# ----------------------------------------------
# Main Program
# ----------------------------------------------

set ip_rootdir [ get_ip_rootdir ]
set terp_source "$ip_rootdir/altera/common/hw_tcl_packages/altera_terp.tcl"
source $terp_source

# Process the command line arguments

set param(showparams) 0

set filename ""
set commandLineSuccess 1
set numargs [ llength $argv ]
for { set i 0 } { $i < $numargs } { incr i } {
    set arg [lindex $argv $i]
	if {[regexp ^--(.*)=(.*) $arg match name val]} {
	    set param($name) ${val}
	} else {
		if {$filename != ""} {
			set commandLineSuccess 0
			break
		}
		set filename $arg
	}
}

if {$filename == ""} {
	set commandLineSuccess 0
}

# ----------------------------------------------
# Call Terp, or print help
# ----------------------------------------------
if {$commandLineSuccess == 1} {

    # ----------------------------------------------
	# Show the parameters if the special parameter "showparams" is set to 1.
    # ----------------------------------------------
	if { $param(showparams) == 1 } {
		puts stderr "<filename> : $filename"
		foreach {name value} [array get param] {
			puts stderr "$name : $value"
		}
	} else {
		set terpbuf [read [open $filename r]]
		set result [altera_terp $terpbuf param];
		puts $result
		
	}
} else {
	help
}


