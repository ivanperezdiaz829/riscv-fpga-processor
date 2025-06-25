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
# | Name: 		altera_hwtcl_xml_validator.tcl
# |
# | Description: 	Common tcl code for accessing the SWIP 
# |			internal, C++-based 'Validator' module. 
# |
# | 			This validator uses the rules files written 
# |			in XML by an IP componenet developer to both 
# |			validate (go/no go) a provided set of parameters 
# | 			as well as provide a 'solver' functionality, 
# |			i.e. to provide a valid set of parameters 
# | 			given a partial/incomplete input parameter set.
# |
# | Version:	1.0
# |
# | Author:  	Razmik Ahanessians  
# |
# +----------------------------------------------------------
package provide altera_hwtcl_xml_validator 1.0

package require sopc

set qrd $env(QUARTUS_ROOTDIR)
set_module_property helper_jar $qrd/sopc_builder/model/lib/com.altera.sopcmodel.components.hwtclvalidator.jar


# ----------------------------------------------------
# |  
# |  validate
# |
# | 
# | 
# ----------------------------------------------------
proc validate {input_name_value_list} {
	set result [join $input_name_value_list | ]
	set result [join $result ^ ]
	set validation_result [call_helper doValidation $result ]
}

# ----------------------------------------------------
# |  
# | validate with RBC rule
# | 
# ----------------------------------------------------

proc get_legal_values {var_list} {
	set result $var_list
	set validation_result [call_helper getLegalValues $result ]
}

proc get_advanced_pll_legality_legal_values {var_list} {
	set flow_pkg [list "MEGAWIZARD" "advanced_pll_legality"]
	set result [concat $flow_pkg $var_list]
	set validation_result [call_helper getLegalValues $result ]
}

proc get_advanced_hssi_legality_legal_values {var_list} {
	set flow_pkg [list "MEGAWIZARD" "advanced_hssi_legality"]
	set result [concat $flow_pkg $var_list]
	set validation_result [call_helper getLegalValues $result ]
}