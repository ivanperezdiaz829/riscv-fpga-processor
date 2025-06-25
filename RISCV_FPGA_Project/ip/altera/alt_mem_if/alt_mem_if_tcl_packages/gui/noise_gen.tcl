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


package provide alt_mem_if::gui::noise_gen 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::noise_gen:: {

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::noise_gen::add_noise_generator {pll_ref_clk global_reset_n} {
	
	_dprint 1 "Preparing to add the noise generator"
	
	set NOISE_GEN ng0
	
	add_instance ${NOISE_GEN} altera_core_noise_generator
	set_instance_parameter ${NOISE_GEN} NG_NUM_BLOCKS [get_parameter_value NG_NUM_BLOCKS]
	set_instance_parameter ${NOISE_GEN} REF_CLK_FREQ [get_parameter_value REF_CLK_FREQ]
	set_instance_parameter ${NOISE_GEN} SPEED_GRADE [get_parameter_value SPEED_GRADE]
	
	add_connection "${pll_ref_clk}/${NOISE_GEN}.pll_ref_clk"
	add_connection "${global_reset_n}/${NOISE_GEN}.global_reset_n"

	return 1
}

proc ::alt_mem_if::gui::noise_gen::create_example_design_parameters {} {
	
	_dprint 1 "Preparing to create example design parameters for noise_gen"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ADD_NOISE_GEN boolean false
	set_parameter_property ADD_NOISE_GEN DISPLAY_NAME "Use the noise generator in the example design"
	set_parameter_property ADD_NOISE_GEN VISIBLE false

	
	create_parameters

	return 1
}

proc ::alt_mem_if::gui::noise_gen::create_parameters {} {
	
	_dprint 1 "Preparing tocreate parameters for noise_gen"
	
	
	_create_derived_parameters
	
	_create_general_parameters

	return 1
}


proc ::alt_mem_if::gui::noise_gen::create_gui {} {

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_show_noise_gen] == 1} {
		set_parameter_property ADD_NOISE_GEN VISIBLE true
		set_parameter_property NG_NUM_BLOCKS VISIBLE true


	add_display_item "Diagnostics" "Noise Generator Settings Settings" GROUP
        add_display_item "Noise Generator Settings Settings" bs12 TEXT "<html>The Noise Generator is used to add noise into the device.<br>"
	add_display_item "Noise Generator Settings Settings" ADD_NOISE_GEN PARAMETER
	add_display_item "Noise Generator Settings Settings" NG_NUM_BLOCKS PARAMETER
	} else {
		set_parameter_property ADD_NOISE_GEN VISIBLE false
		set_parameter_property NG_NUM_BLOCKS VISIBLE false
	}
	
	return 1
}


proc ::alt_mem_if::gui::noise_gen::validate_component {} {

	_derive_parameters

	set validation_pass 1

	
	return $validation_pass

}

proc ::alt_mem_if::gui::noise_gen::elaborate_component {} {


	return 1
}


proc ::alt_mem_if::gui::noise_gen::_init {} {
	

}

proc ::alt_mem_if::gui::noise_gen::_create_derived_parameters {} {
		
	_dprint 1 "Preparing to create derived parameters in noise_gen"

	
}

proc ::alt_mem_if::gui::noise_gen::_create_general_parameters {} {
		
	set CSR_TYPE_EXPORT "EXPORT"
	set CSR_TYPE_SHARED "SHARED"
	set CSR_TYPE_INTERNAL_JTAG "INTERNAL_JTAG"

	_dprint 1 "Preparing to create general parameters in noise_gen"


	add_parameter NG_NUM_BLOCKS INTEGER 200 ""
	set_parameter_property NG_NUM_BLOCKS DEFAULT_VALUE 10
	set_parameter_property NG_NUM_BLOCKS DISPLAY_NAME "Number of noise generator blocks"
	set_parameter_property NG_NUM_BLOCKS TYPE INTEGER
	set_parameter_property NG_NUM_BLOCKS UNITS None
	set_parameter_property NG_NUM_BLOCKS ALLOWED_RANGES 1:10000
	set_parameter_property NG_NUM_BLOCKS DESCRIPTION "Specifies number of noise generator blocks to instantiate. Each block is approximately equal to 1000 ALUTs"
	
	add_parameter NG_CSR_CONNECTION STRING ""
	set_parameter_property NG_CSR_CONNECTION Description "Specifies the connection type to CSR port. The port can be exported, internally connected to a JTAG Avalon Master, or both"
	set_parameter_property NG_CSR_CONNECTION Display_Name "CSR port host interface"
	set_parameter_property NG_CSR_CONNECTION UNITS None
	set_parameter_property NG_CSR_CONNECTION DEFAULT_VALUE $CSR_TYPE_INTERNAL_JTAG
	set_parameter_property NG_CSR_CONNECTION ALLOWED_RANGES [concat [list $CSR_TYPE_EXPORT $CSR_TYPE_SHARED $CSR_TYPE_INTERNAL_JTAG]]

	return 1
}



proc ::alt_mem_if::gui::noise_gen::_create_noisegen_parameters {} {
		
	_dprint 1 "Preparing to create general parameters in noise_gen"
	

}


proc ::alt_mem_if::gui::noise_gen::_create_general_gui {} {
	
	_dprint 1 "Preparing to create the general GUI in noise_gen"
	
}



proc ::alt_mem_if::gui::noise_gen::_derive_parameters {} {

	_dprint 1 "Preparing to derive parameters in noise_gen"

}

::alt_mem_if::gui::noise_gen::_init
