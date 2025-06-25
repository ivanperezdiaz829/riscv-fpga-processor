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


# $Id: //acds/rel/13.1/ip/common/hw_tcl_packages/altera_terp.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# ----------------------------------------------------
# Terp
#
# Proprietary TCL-based templating scheme. Only for
# Merlin component usage; backwards compatibility is
# unlikely. Use at your own peril.
# ----------------------------------------------------

# ----------------------------------------------------
# Replaces all instances of $parameters in the template
# with their actual value.
#
# Also executes each line preceded with @@ as a tcl 
# command.
#
# Do NOT, under any circumstances, use the variable
# terp_out in the template.
#
# Arguments:
# template      : template string 
# parameters    : hash of parameter name-value pairs
#
# Return: string
# ----------------------------------------------------

package provide altera_terp 1.0

# altera_terp_write
# a convience function to write to the file in a procedural way
proc altera_terp_write { hdl } {
    global terp_out
    ${hdl}
}

proc altera_terp { template parameters } {
        global terp_out
        set terp_out ""

	set r "";

	append r "global terp_out"
        upvar $parameters param;
        append r "\nupvar 2 $parameters param";
	foreach name [array names param] {
	    append r "\nset $name " {$param(} "$name" {)}
	}
	
	set lines [split $template "\n"]
	foreach line $lines {
	
		set tclcmd ""
		set all ""
		set is_tcl_cmd [regexp {@@(.*)} $line all tclcmd]

		if {$is_tcl_cmd} {
		    append r "\n$tclcmd";
		} else {
            # ----------------------------------------
            # This is not a tcl command, but we still want variable
            # substitution.
        	# Escape '[', ']', and '"' so that TCL doesn't use them.
            # ----------------------------------------
			regsub -all {\[} $line {\\[} line
			regsub -all {\]} $line {\\]} line
			regsub -all {\"} $line {\\"} line
			
			append r "\nappend terp_out \"${line}\\n\""
		}
	}
        proc doGeneration { } "$r"
        if { [ catch { doGeneration } result ] == 1 } {
          puts stderr "proc doGeneration { } {"
          puts stderr "$r"
	  puts stderr "}"
        }
        set terp_out ""
        doGeneration
	return $terp_out
}
