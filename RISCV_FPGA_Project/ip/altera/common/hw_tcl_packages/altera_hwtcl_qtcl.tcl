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


# +----------------------------------------------------------
# | 
# | Name: 		 altera_hwtcl_qtcl.tcl
# |
# | Description: This packages allows Quartus II Tcl commands 
# |				 to be run from a _hw.tcl script. The helper
# |				 takes care of loading the proper executables
# |				 as well as the Quartus II Tcl package 
# |				 specified in the command.
# |			
# | Version:	1.0
# |
# | Author:  	Razmik Ahanessians  
# |
# +----------------------------------------------------------
package provide altera_hwtcl_qtcl 1.0

set qrd $env(QUARTUS_ROOTDIR)
set_module_property helper_jar $qrd/sopc_builder/model/lib/com.altera.sopcmodel.components.hwtclvalidator.jar


# ---------------------------------------------------------------------------------
# |  
# |  run_quartus_tcl_command
# |
# |  The format of the Tcl command is "{<Package name>:<Tcl command string>}"
# |  The braces are needed to prevent the _hw.tcl script loal Tcl interpreter 
# |  to perform any unintended substitutions in the Tcl command
# | 
# ---------------------------------------------------------------------------------
proc run_quartus_tcl_command {package_command_tcl_str} {

	# Perform appropriate encoding of spaces so that the "Helper Jar" 
	# Java code will not break the string prematurely 
	set arg_encoded_form [string map {{ } #} $package_command_tcl_str]
	set package_delimiter_index [string first ":" $arg_encoded_form]
	if {$package_delimiter_index != -1} {
	    set arg_encoded_form [string replace $arg_encoded_form $package_delimiter_index $package_delimiter_index "@"]
	}
	# Invoke the method on the helper jar to execute the Tcl command
	set run_result [call_helper runQuartusTclCommand $arg_encoded_form ]
	return $run_result
}
