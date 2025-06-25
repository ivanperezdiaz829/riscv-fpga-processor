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


# $Id: //acds/rel/13.1/ip/common/hw_tcl_packages/altera_exec.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# ----------------------------------------------------
# altera_exec
#
# Implements thin wrappers around exec calls to aid in
# error catching and debugging.
# 
# For calling Quartus CDB/SH please see the shared library
# file 
#   altera_hwtcl_qtcl.tcl
#     and
#   quartus_advanced_pll_legality.tcl
#
# ----------------------------------------------------


package provide altera_exec 1.0


namespace eval altera_exec {

    namespace export altera_shell   
    proc altera_shell { command {displayErrorOnFail 1} } {
	send_message debug "Executing Shell Command: ${command}"
	
	set cmd "exec -- ${command}"
	
	if { [ catch ${cmd} std_out ] } {
	    if { $displayErrorOnFail == 1 } {
		send_message error "Failed to Execute External Command: ${command}"
	    } else {
		send_message debug "Failed to Execute External Command: ${command}"
	    }
	} else {
	    send_message debug "Finished Execution of Command: ${command}"
	}
	
	return  ${std_out}
    }    
}
