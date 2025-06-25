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


package provide alt_mem_if::gen::uniphy_pll 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::list_array
package require alt_mem_if::util::iptclgen
package require quartus::advanced_pll_legality
namespace eval ::alt_mem_if::gen::uniphy_pll:: {
	
}



proc ::alt_mem_if::gen::uniphy_pll::get_pll_reference_clock_bounds {} {

	if {[string compare -nocase [get_parameter_value REF_CLK_FREQ_CACHE_VALID] "true"] == 0} {
		_dprint 1 "Using cache for REF_CLK_FREQ"
	
	} elseif {[string compare -nocase [get_parameter_value REF_CLK_FREQ_PARAM_VALID] "true"] == 0} {
		_dprint 1 "Using parameter value for REF_CLK_FREQ"

		set_parameter_value REF_CLK_FREQ_MIN_CACHE [get_parameter_value REF_CLK_FREQ_MIN_PARAM]
		set_parameter_value REF_CLK_FREQ_MAX_CACHE [get_parameter_value REF_CLK_FREQ_MAX_PARAM]
		set_parameter_value REF_CLK_FREQ_CACHE_VALID true

	} else {
		_dprint 1 "Solving value for REF_CLK_FREQ"
		set ref_clock_min_max [solve_pll_reference_clock_range]
		
		set_parameter_value REF_CLK_FREQ_MIN_CACHE [lindex $ref_clock_min_max 0]
		set_parameter_value REF_CLK_FREQ_MAX_CACHE [lindex $ref_clock_min_max 1]
		set_parameter_value REF_CLK_FREQ_CACHE_VALID true
	}
	

	return [list [get_parameter_value REF_CLK_FREQ_MIN_CACHE] [get_parameter_value REF_CLK_FREQ_MAX_CACHE]]

}

proc ::alt_mem_if::gen::uniphy_pll::solve_pll_reference_clock_range {} {
	
	set REF_CLK_FREQ_MIN 10
	set REF_CLK_FREQ_MAX 500

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_skip_pll_legality] == 0} {
	
			set pll_part [::alt_mem_if::gen::uniphy_pll::get_pll_part_name [::alt_mem_if::gui::system_info::get_device_family] [get_parameter_value SPEED_GRADE]]
			set ref_clock_min_max [::quartus::advanced_pll_legality::get_advanced_pll_legality_solved_ref_clock_freq $pll_part]
			
			set REF_CLK_FREQ_MIN [lindex $ref_clock_min_max 0]
			set REF_CLK_FREQ_MAX [lindex $ref_clock_min_max 1]
		}
	}
		
	return [list $REF_CLK_FREQ_MIN $REF_CLK_FREQ_MAX]
}


proc ::alt_mem_if::gen::uniphy_pll::validate_pll_reference_clock_range {} {
	
	set validation_pass 1
	
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
	} else {
		set validation_pass [validate_pll_reference_clock_range_for_pll]
	}
	
	return $validation_pass
}

proc ::alt_mem_if::gen::uniphy_pll::validate_pll_reference_clock_range_for_pll {} {
	
	set validation_pass 1
	
	set ref_clock_min_max [get_pll_reference_clock_bounds]
	set ref_clk_freq_min [lindex $ref_clock_min_max 0]
	set ref_clk_freq_max [lindex $ref_clock_min_max 1]

	if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value REF_CLK_FREQ]] == 1} {

		if {[get_parameter_value REF_CLK_FREQ] < $ref_clk_freq_min || [get_parameter_value REF_CLK_FREQ] > $ref_clk_freq_max} {
			_eprint "PLL reference clock frequency must be between $ref_clk_freq_min MHz and $ref_clk_freq_max MHz"
			set validation_pass 0
		}
	} else {
		_eprint "PLL reference clock frequency must be between $ref_clk_freq_min MHz and $ref_clk_freq_max MHz"
		set validation_pass 0
	}
	
	return $validation_pass
}

proc ::alt_mem_if::gen::uniphy_pll::cache_pll_parameters {child_instance} {

	set_instance_parameter $child_instance REF_CLK_FREQ_PARAM_VALID [get_parameter_value REF_CLK_FREQ_CACHE_VALID]
	set_instance_parameter $child_instance REF_CLK_FREQ_MIN_PARAM [get_parameter_value REF_CLK_FREQ_MIN_CACHE]
	set_instance_parameter $child_instance REF_CLK_FREQ_MAX_PARAM [get_parameter_value REF_CLK_FREQ_MAX_CACHE]

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list]

	set_instance_parameter $child_instance PLL_CLK_PARAM_VALID [get_parameter_value PLL_CLK_CACHE_VALID]
	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_ps_sim_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"

		set_instance_parameter $child_instance "${freq_param_name}_PARAM" [get_parameter_value "${freq_param_name}_CACHE"]
		set_instance_parameter $child_instance "${freq_sim_str_param_name}_PARAM" [get_parameter_value "${freq_sim_str_param_name}_CACHE"]
		set_instance_parameter $child_instance "${phase_ps_param_name}_PARAM" [get_parameter_value "${phase_ps_param_name}_CACHE"]
		set_instance_parameter $child_instance "${phase_ps_sim_str_param_name}_PARAM" [get_parameter_value "${phase_ps_sim_str_param_name}_CACHE"]
		set_instance_parameter $child_instance "${mult_param_name}_PARAM" [get_parameter_value "${mult_param_name}_CACHE"]
		set_instance_parameter $child_instance "${div_param_name}_PARAM" [get_parameter_value "${div_param_name}_CACHE"]
	}


}

proc ::alt_mem_if::gen::uniphy_pll::create_pll_cache_parameters {} {

	_create_pll_ref_cache_parameters
	_create_pll_clock_cache_parameters

	::alt_mem_if::util::hwtcl_utils::_add_parameter SPEED_GRADE_CACHE STRING ""
	set_parameter_property SPEED_GRADE_CACHE DERIVED true
	set_parameter_property SPEED_GRADE_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter IS_ES_DEVICE_CACHE boolean false
	set_parameter_property IS_ES_DEVICE_CACHE DERIVED true
	set_parameter_property IS_ES_DEVICE_CACHE VISIBLE false
		
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ_CACHE float 0
	set_parameter_property MEM_CLK_FREQ_CACHE DERIVED true
	set_parameter_property MEM_CLK_FREQ_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_CACHE float 0
	set_parameter_property REF_CLK_FREQ_CACHE DERIVED true
	set_parameter_property REF_CLK_FREQ_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter RATE_CACHE STRING "Unknown" 
	set_parameter_property RATE_CACHE DERIVED true
	set_parameter_property RATE_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HCX_COMPAT_MODE_CACHE boolean false
	set_parameter_property HCX_COMPAT_MODE_CACHE DERIVED true
	set_parameter_property HCX_COMPAT_MODE_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter PARSE_FRIENDLY_DEVICE_FAMILY_CACHE STRING "Unknown" 
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_CACHE DERIVED true
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter COMMAND_PHASE_CACHE float 0.0
	set_parameter_property COMMAND_PHASE_CACHE DERIVED true
	set_parameter_property COMMAND_PHASE_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CK_PHASE_CACHE float 0.0
	set_parameter_property MEM_CK_PHASE_CACHE DERIVED true
	set_parameter_property MEM_CK_PHASE_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter P2C_READ_CLOCK_ADD_PHASE_CACHE float 0.0
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE_CACHE DERIVED true
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter C2P_WRITE_CLOCK_ADD_PHASE_CACHE float 0.0
	set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE_CACHE DERIVED true
	set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ACV_PHY_CLK_ADD_FR_PHASE_CACHE float 0.0
	set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE_CACHE DERIVED true
	set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SEQUENCER_TYPE_CACHE STRING "Unknown"
	set_parameter_property SEQUENCER_TYPE_CACHE DERIVED true
	set_parameter_property SEQUENCER_TYPE_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_MEM_CLK_FREQ_CACHE boolean false
	set_parameter_property USE_MEM_CLK_FREQ_CACHE DERIVED true
	set_parameter_property USE_MEM_CLK_FREQ_CACHE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_CLK_CACHE_VALID boolean false
	set_parameter_property PLL_CLK_CACHE_VALID DERIVED true
	set_parameter_property PLL_CLK_CACHE_VALID VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_CLK_PARAM_VALID boolean false
	set_parameter_property PLL_CLK_PARAM_VALID VISIBLE false

}

proc ::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list { {gen_all 0} } {

	set pll_clock_names [list \
		PLL_AFI_CLK \
		PLL_MEM_CLK \
		PLL_WRITE_CLK \
		PLL_ADDR_CMD_CLK \
		PLL_AFI_HALF_CLK]

	if {$gen_all} {
		lappend pll_clock_names PLL_NIOS_CLK
		lappend pll_clock_names PLL_CONFIG_CLK
		lappend pll_clock_names PLL_P2C_READ_CLK
		lappend pll_clock_names PLL_C2P_WRITE_CLK
		lappend pll_clock_names PLL_HR_CLK
		lappend pll_clock_names PLL_DR_CLK
		lappend pll_clock_names PLL_AFI_PHY_CLK
	} elseif {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_DR_CLK] "true"] == 0} {
			lappend pll_clock_names PLL_DR_CLK
		}
	} else {
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "MAX10FPGA"] != 0} {
			lappend pll_clock_names PLL_NIOS_CLK
			lappend pll_clock_names PLL_CONFIG_CLK
		}
		if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			lappend pll_clock_names PLL_HR_CLK
		}
		if {[string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
			lappend pll_clock_names PLL_P2C_READ_CLK
			lappend pll_clock_names PLL_C2P_WRITE_CLK
		}
		if {[string compare -nocase [get_parameter_value USE_DR_CLK] "true"] == 0} {
			lappend pll_clock_names PLL_DR_CLK
		}
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			lappend pll_clock_names PLL_AFI_PHY_CLK
		}
	}
	return $pll_clock_names
}


proc ::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list { {gen_all 0} } {

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list $gen_all]
	
	set ordered_clocks [list PLL_MEM_CLK]
	
	set has_dr_clk 0
	foreach clk_name $pll_clock_names {
		if {[string compare -nocase PLL_MEM_CLK $clk_name] == 0} {
		} elseif {[string compare -nocase PLL_DR_CLK $clk_name] == 0} {
			set has_dr_clk 1
		} else {
			lappend ordered_clocks $clk_name
		}
	}
	if {$has_dr_clk} {
		set ordered_clocks [linsert $ordered_clocks 0 PLL_DR_CLK]
	}
	return $ordered_clocks
}


proc ::alt_mem_if::gen::uniphy_pll::create_pll_clock_parameters_on_list {pll_clock_names} {

	_dprint 1 "Creating PLL reference clock parameters"
	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ float 125
	set_parameter_property REF_CLK_FREQ DISPLAY_NAME "PLL reference clock frequency"
	set_parameter_property REF_CLK_FREQ UNITS Megahertz
	set_parameter_property REF_CLK_FREQ DESCRIPTION "The frequency of the input clock that feeds the PLL.  Up to 4 decimal places of precision can be used."
	set_parameter_property REF_CLK_FREQ DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_STR string ""
	set_parameter_property REF_CLK_FREQ_STR DERIVED true
	set_parameter_property REF_CLK_FREQ_STR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_NS float 0
	set_parameter_property REF_CLK_NS VISIBLE FALSE
	set_parameter_property REF_CLK_NS DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_PS float 0
	set_parameter_property REF_CLK_PS VISIBLE FALSE
	set_parameter_property REF_CLK_PS DERIVED TRUE


	foreach clk_name $pll_clock_names {
		_dprint 1 "Creating parameters for clock $clk_name"
		
		set freq_param_name "${clk_name}_FREQ"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
		
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		
		set phase_ps_sim_param_name "${clk_name}_PHASE_PS_SIM"
		set phase_ps_sim_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
		set phase_deg_sim_param_name "${clk_name}_PHASE_DEG_SIM"
		
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_param_name float 0
		set_parameter_property $freq_param_name VISIBLE false
		set_parameter_property $freq_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_str_param_name string ""
		set_parameter_property $freq_str_param_name VISIBLE false
		set_parameter_property $freq_str_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_sim_str_param_name string ""
		set_parameter_property $freq_sim_str_param_name VISIBLE false
		set_parameter_property $freq_sim_str_param_name DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_param_name integer 0
		set_parameter_property $phase_ps_param_name VISIBLE false
		set_parameter_property $phase_ps_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_str_param_name string ""
		set_parameter_property $phase_ps_str_param_name VISIBLE false
		set_parameter_property $phase_ps_str_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_deg_param_name float 0.0
		set_parameter_property $phase_deg_param_name VISIBLE false
		set_parameter_property $phase_deg_param_name DERIVED true
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_sim_param_name integer 0
		set_parameter_property $phase_ps_sim_param_name VISIBLE false
		set_parameter_property $phase_ps_sim_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_sim_str_param_name string ""
		set_parameter_property $phase_ps_sim_str_param_name VISIBLE false
		set_parameter_property $phase_ps_sim_str_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_deg_sim_param_name float 0.0
		set_parameter_property $phase_deg_sim_param_name VISIBLE false
		set_parameter_property $phase_deg_sim_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $mult_param_name integer 0
		set_parameter_property $mult_param_name VISIBLE false
		set_parameter_property $mult_param_name DERIVED true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter $div_param_name integer 0
		set_parameter_property $div_param_name VISIBLE false
		set_parameter_property $div_param_name DERIVED true
	}
}

proc ::alt_mem_if::gen::uniphy_pll::create_pll_clock_parameters {} {

	_dprint 1 "Preparing to create clock parameters in uniphy_phy"

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]


	create_pll_clock_parameters_on_list $pll_clock_names


	set_parameter_property PLL_MEM_CLK_FREQ VISIBLE true
	set_parameter_property PLL_MEM_CLK_FREQ DISPLAY_NAME "Achieved memory clock frequency"
	set_parameter_property PLL_MEM_CLK_FREQ UNITS Megahertz
	set_parameter_property PLL_MEM_CLK_FREQ DISPLAY_HINT columns:10
	set_parameter_property PLL_MEM_CLK_FREQ DESCRIPTION "The actual frequency the PLL will generate to drive the external memory interface (memory clock)"

	set_parameter_property PLL_AFI_CLK_FREQ VISIBLE true
	set_parameter_property PLL_AFI_CLK_FREQ DISPLAY_NAME "Achieved local clock frequency"
	set_parameter_property PLL_AFI_CLK_FREQ UNITS Megahertz
	set_parameter_property PLL_AFI_CLK_FREQ DISPLAY_HINT columns:10
	set_parameter_property PLL_AFI_CLK_FREQ DESCRIPTION "The actual frequency the PLL will generate to drive the local interface for the memory controller (AFI clock)"

}


proc ::alt_mem_if::gen::uniphy_pll::update_derived_clock_parameters_from_list {pll_clock_names} {

	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"

		set clock_period_ps 0
		set clock_phase_deg 0
		if {[get_parameter_value $freq_param_name] > 0} {
			set clock_period_ps [ expr {1000000.0 / [get_parameter_value $freq_param_name]} ]
			set clock_phase_deg [ expr {round([get_parameter_value $phase_ps_param_name] * 360.0 / $clock_period_ps)} ]
			
			set orig_clock_phase_deg [get_parameter_value $phase_deg_param_name]
			if {$orig_clock_phase_deg  < 0 && $clock_phase_deg > 0} {
				while {$clock_phase_deg > 0} {
					set clock_phase_deg [expr $clock_phase_deg - 360.0]
				}
			}			
		}
	
		set_parameter_value $freq_str_param_name "[get_parameter_value $freq_param_name] MHz"
		set_parameter_value $phase_deg_param_name $clock_phase_deg
		set_parameter_value $phase_ps_str_param_name "[get_parameter_value $phase_ps_param_name] ps"
	}
}

proc ::alt_mem_if::gen::uniphy_pll::derive_pll {protocol} {

	_derive_pll_cache_param

	set_parameter_value REF_CLK_FREQ_STR "[get_parameter_value REF_CLK_FREQ] MHz"
	
	_derive_pll_freq $protocol
	_derive_pll_phase $protocol

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list]

	set family_name [::alt_mem_if::gui::system_info::get_device_family]



	if {[string compare -nocase [get_parameter_value PLL_CLK_CACHE_VALID] "true"] == 0} {
		_dprint 1 "Using cache for PLL Clocks"

		foreach clk_name $pll_clock_names {
			set freq_param_name "${clk_name}_FREQ"
			set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
			set phase_ps_param_name "${clk_name}_PHASE_PS"
			set phase_ps_sim_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
			set mult_param_name "${clk_name}_MULT"
			set div_param_name "${clk_name}_DIV"

			set_parameter_value ${freq_param_name} [get_parameter_value "${freq_param_name}_CACHE"]
			set_parameter_value ${freq_sim_str_param_name} [get_parameter_value "${freq_sim_str_param_name}_CACHE"]
			set_parameter_value ${phase_ps_param_name} [get_parameter_value "${phase_ps_param_name}_CACHE"]
			set_parameter_value ${phase_ps_sim_str_param_name} [get_parameter_value "${phase_ps_sim_str_param_name}_CACHE"]
			set_parameter_value ${mult_param_name} [get_parameter_value "${mult_param_name}_CACHE"]
			set_parameter_value ${div_param_name} [get_parameter_value "${div_param_name}_CACHE"]
		}

		if {([string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0) &&
		    ([string compare -nocase $family_name "stratixv"] == 0 ||
			[string compare -nocase $family_name "arriav"] == 0 ||
				[string compare -nocase $family_name "cyclonev"] == 0 ||
				[string compare -nocase $family_name "arriavgz"] == 0 ||
				[string compare -nocase $family_name "max10fpga"] == 0)} {
			::alt_mem_if::gen::uniphy_pll::get_pll_part_name [::alt_mem_if::gui::system_info::get_device_family] [get_parameter_value SPEED_GRADE]
		}

	} elseif {[string compare -nocase [get_parameter_value PLL_CLK_PARAM_VALID] "true"] == 0} {
		_dprint 1 "Using parameter value for PLL Clocks"

		foreach clk_name $pll_clock_names {
			set freq_param_name "${clk_name}_FREQ"
			set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
			set phase_ps_param_name "${clk_name}_PHASE_PS"
			set phase_ps_sim_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
			set mult_param_name "${clk_name}_MULT"
			set div_param_name "${clk_name}_DIV"

			set_parameter_value "${freq_param_name}_CACHE" [get_parameter_value "${freq_param_name}_PARAM"]
			set_parameter_value "${freq_sim_str_param_name}_CACHE" [get_parameter_value "${freq_sim_str_param_name}_PARAM"]
			set_parameter_value "${phase_ps_param_name}_CACHE" [get_parameter_value "${phase_ps_param_name}_PARAM"]
			set_parameter_value "${phase_ps_sim_str_param_name}_CACHE" [get_parameter_value "${phase_ps_sim_str_param_name}_PARAM"]
			set_parameter_value "${mult_param_name}_CACHE" [get_parameter_value "${mult_param_name}_PARAM"]
			set_parameter_value "${div_param_name}_CACHE" [get_parameter_value "${div_param_name}_PARAM"]
			
			set_parameter_value ${freq_param_name} [get_parameter_value "${freq_param_name}_CACHE"]
			set_parameter_value ${freq_sim_str_param_name} [get_parameter_value "${freq_sim_str_param_name}_CACHE"]
			set_parameter_value ${phase_ps_param_name} [get_parameter_value "${phase_ps_param_name}_CACHE"]
			set_parameter_value ${phase_ps_sim_str_param_name} [get_parameter_value "${phase_ps_sim_str_param_name}_CACHE"]
			set_parameter_value ${mult_param_name} [get_parameter_value "${mult_param_name}_CACHE"]
			set_parameter_value ${div_param_name} [get_parameter_value "${div_param_name}_CACHE"]
		}

		set_parameter_value PLL_CLK_CACHE_VALID true

		if {([string compare -nocase [get_parameter_value HHP_HPS] "true"] != 0) &&
		    ([string compare -nocase $family_name "stratixv"] == 0 ||
			[string compare -nocase $family_name "arriav"] == 0 ||
				[string compare -nocase $family_name "cyclonev"] == 0 || 
				[string compare -nocase $family_name "arriavgz"] == 0 ||
				[string compare -nocase $family_name "max10fpga"] == 0) } {
			::alt_mem_if::gen::uniphy_pll::get_pll_part_name [::alt_mem_if::gui::system_info::get_device_family] [get_parameter_value SPEED_GRADE]
		}

	} else {
		_dprint 1 "Solving value for PLL Clocks"

		
		if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
			_update_hps_pll_parameters
		} elseif {[string compare -nocase [get_parameter_value GENERIC_PLL] "true"] == 0} {
			_update_pll_parameters_from_pll_legality
		} else {
			_update_pll_parameters_from_computepll
		}
		
		foreach clk_name $pll_clock_names {
			set freq_param_name "${clk_name}_FREQ"
			set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
			set phase_ps_param_name "${clk_name}_PHASE_PS"
			set phase_ps_sim_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
			set mult_param_name "${clk_name}_MULT"
			set div_param_name "${clk_name}_DIV"

			set_parameter_value "${freq_param_name}_CACHE" [get_parameter_value ${freq_param_name}]
			set_parameter_value "${freq_sim_str_param_name}_CACHE" [get_parameter_value ${freq_sim_str_param_name}]
			set_parameter_value "${phase_ps_param_name}_CACHE" [get_parameter_value ${phase_ps_param_name}]
			set_parameter_value "${phase_ps_sim_str_param_name}_CACHE" [get_parameter_value ${phase_ps_sim_str_param_name}]
			set_parameter_value "${mult_param_name}_CACHE" [get_parameter_value ${mult_param_name}]
			set_parameter_value "${div_param_name}_CACHE" [get_parameter_value ${div_param_name}]
		}
		
		set_parameter_value PLL_CLK_CACHE_VALID true
	}
	
	update_derived_clock_parameters_from_list $pll_clock_names

	return 1
}



proc ::alt_mem_if::gen::uniphy_pll::_init {} {
	return 1
}


proc ::alt_mem_if::gen::uniphy_pll::_derive_clock_parameters {} {

	_dprint 1 "Preparing to derive clock parametres"
	
	set_parameter_value MEM_CLK_PS [ expr {int(1000000.0 / [get_parameter_value MEM_CLK_FREQ])} ]
	set_parameter_value REF_CLK_PS [ expr {int(1000000.0 / [get_parameter_value REF_CLK_FREQ])} ]
	set_parameter_value MEM_CLK_NS [ expr { [get_parameter_value MEM_CLK_PS] / 1000.0 } ]
	set_parameter_value REF_CLK_NS [ expr { [get_parameter_value REF_CLK_PS] / 1000.0 } ]
}

proc ::alt_mem_if::gen::uniphy_pll::_create_pll_ref_cache_parameters {} {

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_CACHE_VALID boolean false
	set_parameter_property REF_CLK_FREQ_CACHE_VALID DERIVED true
	set_parameter_property REF_CLK_FREQ_CACHE_VALID VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_PARAM_VALID boolean false
	set_parameter_property REF_CLK_FREQ_PARAM_VALID VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_MIN_PARAM float 0
	set_parameter_property REF_CLK_FREQ_MIN_PARAM VISIBLE false
	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_MAX_PARAM float 0
	set_parameter_property REF_CLK_FREQ_MAX_PARAM VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_MIN_CACHE float 0
	set_parameter_property REF_CLK_FREQ_MIN_CACHE DERIVED true
	set_parameter_property REF_CLK_FREQ_MIN_CACHE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_FREQ_MAX_CACHE float 0
	set_parameter_property REF_CLK_FREQ_MAX_CACHE DERIVED true
	set_parameter_property REF_CLK_FREQ_MAX_CACHE VISIBLE false
}




proc ::alt_mem_if::gen::uniphy_pll::_create_pll_clock_cache_parameters {} {
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]

	foreach clk_name $pll_clock_names {
		set freq_param_name_cache "${clk_name}_FREQ_CACHE"
		set freq_sim_str_param_name_cache "${clk_name}_FREQ_SIM_STR_CACHE"
		set phase_ps_param_name_cache "${clk_name}_PHASE_PS_CACHE"
		set phase_ps_sim_str_param_name_cache "${clk_name}_PHASE_PS_SIM_STR_CACHE"
		set mult_param_name_cache "${clk_name}_MULT_CACHE"
		set div_param_name_cache "${clk_name}_DIV_CACHE"

		set freq_param_name_param "${clk_name}_FREQ_PARAM"
		set freq_sim_str_param_name_param "${clk_name}_FREQ_SIM_STR_PARAM"
		set phase_ps_param_name_param "${clk_name}_PHASE_PS_PARAM"
		set phase_ps_sim_str_param_name_param "${clk_name}_PHASE_PS_SIM_STR_PARAM"
		set mult_param_name_param "${clk_name}_MULT_PARAM"
		set div_param_name_param "${clk_name}_DIV_PARAM"

		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_param_name_param float 0
		set_parameter_property $freq_param_name_param VISIBLE false

		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_sim_str_param_name_param string ""
		set_parameter_property $freq_sim_str_param_name_param VISIBLE false

		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_param_name_param integer 0
		set_parameter_property $phase_ps_param_name_param VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_sim_str_param_name_param string ""
		set_parameter_property $phase_ps_sim_str_param_name_param VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter $mult_param_name_param integer 0
		set_parameter_property $mult_param_name_param VISIBLE false

		::alt_mem_if::util::hwtcl_utils::_add_parameter $div_param_name_param integer 0
		set_parameter_property $div_param_name_param VISIBLE false

		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_param_name_cache float 0
		set_parameter_property $freq_param_name_cache VISIBLE false
		set_parameter_property $freq_param_name_cache DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter $freq_sim_str_param_name_cache string ""
		set_parameter_property $freq_sim_str_param_name_cache VISIBLE false
		set_parameter_property $freq_sim_str_param_name_cache DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_param_name_cache integer 0
		set_parameter_property $phase_ps_param_name_cache VISIBLE false
		set_parameter_property $phase_ps_param_name_cache DERIVED true
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter $phase_ps_sim_str_param_name_cache string ""
		set_parameter_property $phase_ps_sim_str_param_name_cache VISIBLE false
		set_parameter_property $phase_ps_sim_str_param_name_cache DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter $mult_param_name_cache integer 0
		set_parameter_property $mult_param_name_cache VISIBLE false
		set_parameter_property $mult_param_name_cache DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter $div_param_name_cache integer 0
		set_parameter_property $div_param_name_cache VISIBLE false
		set_parameter_property $div_param_name_cache DERIVED true
	}
	
}


proc ::alt_mem_if::gen::uniphy_pll::_solve_desired_pll_clock_freq {protocol} {

	_dprint 1 "Preparing to solve desired PLL clock frequencies"

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]

	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"

		set_parameter_value $freq_param_name 0
	}


	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		_dprint 1 "Deriving quarter rate PLL frequencies for [get_parameter_value DEVICE_FAMILY]"
		
		set afi_ratio 4
		set_parameter_value PLL_AFI_CLK_FREQ 4
		set_parameter_value PLL_MEM_CLK_FREQ 1
		set_parameter_value PLL_WRITE_CLK_FREQ 1

		if {[string compare -nocase $protocol "LPDDR2"] == 0} {
			set_parameter_value PLL_ADDR_CMD_CLK_FREQ 1
		} else {
			set_parameter_value PLL_ADDR_CMD_CLK_FREQ 2
		}
		set_parameter_value PLL_AFI_HALF_CLK_FREQ 8
		
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		_dprint 1 "Deriving half rate PLL frequencies for [get_parameter_value DEVICE_FAMILY]"
		
		set afi_ratio 2
		set_parameter_value PLL_AFI_CLK_FREQ 2
		set_parameter_value PLL_MEM_CLK_FREQ 1
		set_parameter_value PLL_WRITE_CLK_FREQ 1

		if {[string compare -nocase $protocol "LPDDR2"] == 0} {
			set_parameter_value PLL_ADDR_CMD_CLK_FREQ 1
		} else {
			set_parameter_value PLL_ADDR_CMD_CLK_FREQ 2
		}
		set_parameter_value PLL_AFI_HALF_CLK_FREQ 4
		
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "MAX10FPGA"] == 0 } {
		    set_parameter_value PLL_ADDR_CMD_CLK_FREQ 1
		    set_parameter_value PLL_AFI_HALF_CLK_FREQ 1
		}

	} else {
		_dprint 1 "Deriving full rate PLL frequencies for [get_parameter_value DEVICE_FAMILY]"
		
		set afi_ratio 1
		set_parameter_value PLL_AFI_CLK_FREQ 1
		set_parameter_value PLL_MEM_CLK_FREQ 1
		set_parameter_value PLL_WRITE_CLK_FREQ 1
		set_parameter_value PLL_ADDR_CMD_CLK_FREQ 1
		set_parameter_value PLL_AFI_HALF_CLK_FREQ 2
	}

	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set_parameter_value PLL_HR_CLK_FREQ 2
	} else {
		set_parameter_value PLL_HR_CLK_FREQ 0
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
	    [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 } {
		if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			set_parameter_value PLL_AFI_PHY_CLK_FREQ [get_parameter_value PLL_HR_CLK_FREQ]
		} else {
			set_parameter_value PLL_AFI_PHY_CLK_FREQ [get_parameter_value PLL_AFI_CLK_FREQ]
		}
	}

	set mem_clk_freq [get_parameter_value MEM_CLK_FREQ]
	
	set double_rate_clk [expr {$mem_clk_freq * 2.0} ]
	set full_rate_clk $mem_clk_freq
	set half_rate_clk [expr {$mem_clk_freq / 2.0} ]
	set quad_rate_clk [expr {$half_rate_clk / 2.0} ]
	set eigth_rate_clk [expr {$quad_rate_clk / 2.0} ]

	if {[ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		set double_rate_period [expr {1000000.0 / ($mem_clk_freq * 2)}]
		set double_rate_period_int [expr {int($double_rate_period)}]
		set double_rate_period_plus1_int [expr {int($double_rate_period+1)}]
		set double_rate_sim_period $double_rate_period_int
		if {$double_rate_period_int & 1} {
			set double_rate_sim_period $double_rate_period_plus1_int
		}

		set full_rate_sim_period [expr {$double_rate_sim_period * 2}]
	

		set full_rate_div 2000000
		set double_rate_div 1000000
	
	} else {

		set full_rate_period [expr {1000000.0 / $mem_clk_freq}]
		set full_rate_period_int [expr {int($full_rate_period)}]
		set full_rate_period_plus1_int [expr {int($full_rate_period+1)}]
		set full_rate_sim_period $full_rate_period_int
		if {$full_rate_period_int & 1} {
			set full_rate_sim_period $full_rate_period_plus1_int
		}


		set full_rate_div 1000000
	}
	set half_rate_sim_period [expr {$full_rate_sim_period * 2}]
	set quad_rate_sim_period [expr {$full_rate_sim_period * 4}]
	set eigth_rate_sim_period [expr {$full_rate_sim_period * 8}]



	if {[ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			set_parameter_value PLL_P2C_READ_CLK_FREQ [get_parameter_value PLL_HR_CLK_FREQ]
			set_parameter_value PLL_C2P_WRITE_CLK_FREQ [get_parameter_value PLL_HR_CLK_FREQ] 
		} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
			set_parameter_value PLL_P2C_READ_CLK_FREQ [get_parameter_value PLL_AFI_CLK_FREQ]
			set_parameter_value PLL_C2P_WRITE_CLK_FREQ [get_parameter_value PLL_AFI_CLK_FREQ] 
		} else {
			set_parameter_value PLL_P2C_READ_CLK_FREQ [get_parameter_value PLL_AFI_CLK_FREQ]
			set_parameter_value PLL_C2P_WRITE_CLK_FREQ [get_parameter_value PLL_AFI_CLK_FREQ] 
		}
	} else {
		set_parameter_value PLL_P2C_READ_CLK_FREQ 0
		set_parameter_value PLL_C2P_WRITE_CLK_FREQ 0
	}

	if {[ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		set_parameter_value PLL_DR_CLK_FREQ 0.5
	} else {
		set_parameter_value PLL_DR_CLK_FREQ 0
	}

	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
		set div_param_name "${clk_name}_DIV"
		
		if {[get_parameter_value $freq_param_name] == 0} {
			set_parameter_value $freq_param_name 0
			set_parameter_value $freq_sim_str_param_name 0			
			set_parameter_value $div_param_name 0
		} elseif {[get_parameter_value $freq_param_name] == 0.5} {
			set_parameter_value $freq_param_name $double_rate_clk
			set_parameter_value $freq_sim_str_param_name $double_rate_sim_period
			set_parameter_value $div_param_name $double_rate_div
		} elseif {[get_parameter_value $freq_param_name] == 1} {
			set_parameter_value $freq_param_name $full_rate_clk
			set_parameter_value $freq_sim_str_param_name $full_rate_sim_period
			set_parameter_value $div_param_name $full_rate_div
		} elseif {[get_parameter_value $freq_param_name] == 2} {
			set_parameter_value $freq_param_name $half_rate_clk
			set_parameter_value $freq_sim_str_param_name $half_rate_sim_period
			set_parameter_value $div_param_name [expr {$full_rate_div * 2}]
		} elseif {[get_parameter_value $freq_param_name] == 4} {
			set_parameter_value $freq_param_name $quad_rate_clk
			set_parameter_value $freq_sim_str_param_name $quad_rate_sim_period
			set_parameter_value $div_param_name [expr {$full_rate_div * 4}]			
		} elseif {[get_parameter_value $freq_param_name] == 8} {
			set_parameter_value $freq_param_name $eigth_rate_clk
			set_parameter_value $freq_sim_str_param_name $eigth_rate_sim_period
			set_parameter_value $div_param_name [expr {$full_rate_div * 8}]			
		} else {
			_error "Fatal Error: Unknown clock rate multiple [get_parameter_value $freq_param_name]"
		}
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "MAX10FPGA"] != 0} {
	
		if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
			if {[get_parameter_value SPEED_GRADE] >= 7} {
				set sopc_afi_clk_ratio [expr {ceil([get_parameter_value PLL_AFI_CLK_FREQ] / 70.0)}]
			} else {
				set sopc_afi_clk_ratio [expr {ceil([get_parameter_value PLL_AFI_CLK_FREQ] / 80.0)}]
			}
		} else {
			if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
			    [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 } {
				if {[get_parameter_value SPEED_GRADE] >= 7} {
					set sopc_afi_clk_ratio [expr {ceil([get_parameter_value PLL_AFI_CLK_FREQ] / 70.0)}]
				} else {
					set sopc_afi_clk_ratio [expr {ceil([get_parameter_value PLL_AFI_CLK_FREQ] / 95.0)}]
				}
			} else {
				set sopc_afi_clk_ratio [expr {ceil([get_parameter_value PLL_AFI_CLK_FREQ] / 120.0)}]
			}
		}
		set sopc_clk [expr {[get_parameter_value PLL_AFI_CLK_FREQ] / $sopc_afi_clk_ratio}]
		set sopc_clk_period_ps [expr {int([get_parameter_value PLL_AFI_CLK_FREQ_SIM_STR] * $sopc_afi_clk_ratio)}]
		set sopc_clk_div [expr {$full_rate_div * $afi_ratio * $sopc_afi_clk_ratio}]

		set sopc_scc_clk_ratio [expr {ceil($sopc_clk / 25.0)}]
		set scc_clk [expr {$sopc_clk / $sopc_scc_clk_ratio}]
		set scc_clk_period_ps [expr {int($sopc_clk_period_ps * $sopc_scc_clk_ratio)}]
		set scc_clk_div [expr {$sopc_clk_div * $sopc_scc_clk_ratio}]

		set_parameter_value PLL_NIOS_CLK_FREQ $sopc_clk
		set_parameter_value PLL_CONFIG_CLK_FREQ $scc_clk
		
		set_parameter_value PLL_NIOS_CLK_FREQ_SIM_STR $sopc_clk_period_ps
		set_parameter_value PLL_CONFIG_CLK_FREQ_SIM_STR $scc_clk_period_ps
		
		set_parameter_value PLL_NIOS_CLK_DIV $sopc_clk_div
		set_parameter_value PLL_CONFIG_CLK_DIV $scc_clk_div
	} else {
		set_parameter_value PLL_NIOS_CLK_FREQ 0
		set_parameter_value PLL_CONFIG_CLK_FREQ 0
		
		set_parameter_value PLL_NIOS_CLK_FREQ_SIM_STR 0
		set_parameter_value PLL_CONFIG_CLK_FREQ_SIM_STR 0
		
		set_parameter_value PLL_NIOS_CLK_DIV 0
		set_parameter_value PLL_CONFIG_CLK_DIV 0		
	}

	foreach clk_name $pll_clock_names {	
		set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
		set value [get_parameter_value $freq_sim_str_param_name]
		set_parameter_value $freq_sim_str_param_name "$value ps"
	}
}


proc ::alt_mem_if::gen::uniphy_pll::_solve_desired_pll_phases {protocol} {

	_dprint 1 "Preparing to solve desired PLL clock phases"
	
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]	
	
	set c2p_write_clk_phase 0
	set p2c_read_clk_phase 0
	

        if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0 && 
	    [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 } {
		if {[string compare -nocase $protocol "LPDDR2"] == 0} {
			set_parameter_value PLL_NIOS_CLK_PHASE_DEG 355
		} else { 
			set_parameter_value PLL_NIOS_CLK_PHASE_DEG 10
		}
	} else {
		set_parameter_value PLL_NIOS_CLK_PHASE_DEG 0
	}
	set_parameter_value PLL_CONFIG_CLK_PHASE_DEG 0

	set_parameter_value PLL_AFI_CLK_PHASE_DEG 0
	set_parameter_value PLL_AFI_HALF_CLK_PHASE_DEG 0
	
	set_parameter_value PLL_HR_CLK_PHASE_DEG 0

	set mem_clk_phase 0
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "false" ] == 0} {
		set mem_clk_phase [get_parameter_value MEM_CK_PHASE]
	}

	if {[string compare -nocase $protocol "DDR2"] == 0 ||
		[string compare -nocase $protocol "DDR3"] == 0 ||
		[string compare -nocase $protocol "LPDDR2"] == 0 ||
		[string compare -nocase $protocol "LPDDR1"] == 0} {

		_dprint 1 "Preparing to derive DDR clocks"

		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0} {
			set family [::alt_mem_if::gui::system_info::get_device_family]
			_dprint 1 "Deriving leveling clock phases for [get_parameter_value DEVICE_FAMILY]"
			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {225 + [get_parameter_value COMMAND_PHASE]}]
			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
			} else {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
			}
		} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 } {
			set family [::alt_mem_if::gui::system_info::get_device_family]
			_dprint 1 "Deriving leveling clock phases for [get_parameter_value DEVICE_FAMILY]"
			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
                                _error "Fatal Error: Code path doesn't support quarter-rate yet."
			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				if { [string compare -nocase $protocol "DDR2"] == 0 } {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
				} else {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {247.5 + [get_parameter_value COMMAND_PHASE]}]
				}
			} else {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
			}
		} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "MAX10FPGA"] == 0 } {
			set family [::alt_mem_if::gui::system_info::get_device_family]
			_dprint 1 "Deriving leveling clock phases for [get_parameter_value DEVICE_FAMILY]"
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG 0
		} elseif {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			_dprint 1 "Deriving leveling clock phases for [get_parameter_value DEVICE_FAMILY]"
			
			set write_clk_adjustment 0
			set mem_clk_adjustment 0
			set addr_clk_adjustment 0
			if {[get_parameter_value DELAY_CHAIN_LENGTH] == 6} {
				set write_clk_adjustment [expr {$write_clk_adjustment - 22.5}]
			}
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] ==0} {
			
				if {[string compare -nocase $protocol "DDR3"] == 0} {
					if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {

						if {[get_parameter_value MEM_CLK_FREQ] > 465} {
							set write_clk_adjustment [expr {$write_clk_adjustment - 67.5}]
						} elseif {[get_parameter_value MEM_CLK_FREQ] > 405} {
							set write_clk_adjustment [expr {$write_clk_adjustment - 45}]
						}
						
						set mem_clk_adjustment [expr {$mem_clk_adjustment + 45}]
					}
				}
				
				if {[string compare -nocase $protocol "DDR2"] == 0} {
					if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
				
						set write_clk_adjustment [expr {$write_clk_adjustment + 45}]
					}
				}
				
				if {[string compare -nocase $protocol "LPDDR1"] == 0} {
					if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
				
						set write_clk_adjustment [expr {$write_clk_adjustment + 45}]
					}
				}
			}
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] != 0} {
				if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0} {
					if {[string compare -nocase [get_parameter_value SPEED_GRADE] "2"] == 0} {
						if {[get_parameter_value DELAY_CHAIN_LENGTH] == 8} {
							if {[string compare -nocase $protocol "DDR3"] == 0} {
								if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
									if {[get_parameter_value MEM_CLK_FREQ] > 465} {
										set write_clk_adjustment [expr {$write_clk_adjustment - 22.5}]
									}
								}
							}
						}
					}
				}
			}			
			if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0} {
				if {[get_parameter_value MEM_CLK_FREQ] > 500} {
					set write_clk_adjustment [expr {$write_clk_adjustment - 22.5}]
				}
			}
			set write_clk_adjustment [expr {$write_clk_adjustment - (round($write_clk_adjustment*10) % 450)/10.0}]
	
			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {0 + $mem_clk_phase}]
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG [expr {90 + $write_clk_adjustment + $mem_clk_phase}]
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + $addr_clk_adjustment + [get_parameter_value COMMAND_PHASE]}]
			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {0 + $mem_clk_adjustment + $mem_clk_phase}]
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG [expr {90 + $write_clk_adjustment + $mem_clk_phase}]
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + $addr_clk_adjustment + [get_parameter_value COMMAND_PHASE]}]
			} else {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {90 + $mem_clk_phase}]
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG [expr {180 + $write_clk_adjustment + $mem_clk_phase}]
				if {[string compare -nocase $protocol "LPDDR2"] == 0} {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {0 + $addr_clk_adjustment + [get_parameter_value COMMAND_PHASE]}]
				} else {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + $addr_clk_adjustment + [get_parameter_value COMMAND_PHASE]}]
				}
			}

		} else {
			_dprint 1 "Deriving non-leveled clock phases for [get_parameter_value DEVICE_FAMILY]"

			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				_error "Fatal Error: Non-leveled interfaces do not support running at quarter-rate."
				
			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {315 + $mem_clk_phase}]
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG [expr {225 + $mem_clk_phase}]
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
			} else {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {0 + $mem_clk_phase}]
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG [expr {270 + $mem_clk_phase}]
				if {[string compare -nocase [get_parameter_value SPEED_GRADE] "4"] == 0 &&
				    [string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "false"] == 0} {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
				} else {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {225 + [get_parameter_value COMMAND_PHASE]}]
				}
			}
		}
	} else {
		_dprint 1 "Preparing to derive RLDRAM and QDR type clocks for [get_parameter_value DEVICE_FAMILY]"

		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		    [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {

			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				_error "Fatal Error: Code path doesn't support quarter-rate yet."

			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_AFI_PHY_CLK_PHASE_DEG 0
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				if {[string compare -nocase $protocol "rldramii"] == 0} {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {225 + [get_parameter_value COMMAND_PHASE]}]
				} else {
					set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
				}
			} else {
				_error "Fatal Error: Code path doesn't support full-rate yet."
			}

		} else {

			if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				_error "Fatal Error: Code path doesn't support quarter-rate yet."

			} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {270 + [get_parameter_value COMMAND_PHASE]}]
			} else {
				set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
				set_parameter_value PLL_WRITE_CLK_PHASE_DEG 270
				set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG [expr {225 + [get_parameter_value COMMAND_PHASE]}]
			}
		}
	}

	set_parameter_value PLL_P2C_READ_CLK_PHASE_DEG 0
	set_parameter_value PLL_C2P_WRITE_CLK_PHASE_DEG 0
	set_parameter_value PLL_DR_CLK_PHASE_DEG 0
	
	foreach clk_name $pll_clock_names {	
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set phase_deg_sim_param_name "${clk_name}_PHASE_DEG_SIM"
		set value [get_parameter_value $phase_deg_param_name]
		set_parameter_value $phase_deg_sim_param_name $value
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 } {
		set_parameter_value PLL_MEM_CLK_PHASE_DEG_SIM 0
		set_parameter_value PLL_WRITE_CLK_PHASE_DEG_SIM 270
		set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG_SIM [get_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG]
	}
}

proc ::alt_mem_if::gen::uniphy_pll::_solve_desired_pll_phases_sv {protocol} {

	_dprint 1 "Preparing to solve desired PLL clock phases for SV"

	set speed_grade [get_parameter_value SPEED_GRADE]
	set is_es [expr {[string compare -nocase [get_parameter_value IS_ES_DEVICE] "true"] == 0}]
		
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]	
	
	set c2p_write_clk_phase 0
	set p2c_read_clk_phase 0
	
	set_parameter_value PLL_NIOS_CLK_PHASE_DEG 0
	set_parameter_value PLL_CONFIG_CLK_PHASE_DEG 0
	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0 &&
		( [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
		  [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 ) &&
		  [string compare -nocase $protocol "DDR3"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] <= 480} {
			set_parameter_value PLL_NIOS_CLK_PHASE_DEG 11.25
		}
	}

	set_parameter_value PLL_AFI_CLK_PHASE_DEG 0
	set_parameter_value PLL_AFI_HALF_CLK_PHASE_DEG 0
	
	set_parameter_value PLL_HR_CLK_PHASE_DEG 0

	set p2c_read_clk_phase 0
	
	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		set c2p_freq [get_parameter_value MEM_CLK_FREQ]

		set c2p_clk_skew 0
	} else {
		set c2p_freq [expr 0.5 * [get_parameter_value MEM_CLK_FREQ]]
		
		if {($speed_grade >= 4 && $c2p_freq < 333) ||
			($speed_grade == 3 && $c2p_freq < 333) ||
			($speed_grade <= 2 && $c2p_freq < 333)} {
			set c2p_clk_skew 0
		} else {
			set c2p_clk_skew -0.25
		}
	}
	
	set c2p_delay_ns [expr -1.0 * $c2p_clk_skew * pow(1.15, $speed_grade)]
	set c2p_period_ns [expr 1000.0 / $c2p_freq]
	set ideal_c2p_write_clk_phase [expr 360 * ($c2p_delay_ns / $c2p_period_ns)]
	set achieved_c2p_write_clk_phase [expr 22.5 * ceil($ideal_c2p_write_clk_phase / 22.5)]
		
	if {$achieved_c2p_write_clk_phase > 180} {
		set achieved_c2p_write_clk_phase 180
	}

	if {($speed_grade <= 2 && [get_parameter_value MEM_CLK_FREQ] > 999)} {
		set c2p_write_clk_phase [expr 67.5 + $achieved_c2p_write_clk_phase + [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE]]
	} else {
		set c2p_write_clk_phase [expr $achieved_c2p_write_clk_phase + [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE]]
	}
	
	if {($speed_grade <= 2 && [get_parameter_value MEM_CLK_FREQ] > 999)} {
		set hr_to_fr_phase -45
	} elseif {[string compare -nocase [get_parameter_value RATE] "full"] != 0} {
		if {($speed_grade >= 4 && [get_parameter_value MEM_CLK_FREQ] >= 534) ||
			($speed_grade == 3 && [get_parameter_value MEM_CLK_FREQ] >= 668) ||
			($speed_grade <= 2 && [get_parameter_value MEM_CLK_FREQ] >= 801)} {
			set hr_to_fr_phase 45
		} else {
			set hr_to_fr_phase 90
		}
	}

	_dprint 1 "Preparing to derive clocks"

	set_parameter_value PLL_ADDR_CMD_CLK_PHASE_DEG 0
	
	set_parameter_value PLL_DR_CLK_PHASE_DEG 0

	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		set write_clk_adjustment $c2p_write_clk_phase
	} else {
		set write_clk_adjustment [expr $hr_to_fr_phase + $c2p_write_clk_phase * 2] 
	}
	
	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
	
		if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
			if {[get_parameter_value MEM_CLK_FREQ] > 300} {
				set dual_clk_adjustment 90.0
			} elseif {[get_parameter_value MEM_CLK_FREQ] >= 233} {
				set dual_clk_adjustment 67.5
			} elseif {[get_parameter_value MEM_CLK_FREQ] >= 150} {
				set dual_clk_adjustment 45.0
			} else {
				set dual_clk_adjustment 22.5
			}
		} else {
			set dual_clk_adjustment 90.0
		}
	
		set write_clk_adjustment [expr $write_clk_adjustment + $dual_clk_adjustment]
	}
			
	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set_parameter_value PLL_WRITE_CLK_PHASE_DEG $write_clk_adjustment
		
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		set_parameter_value PLL_WRITE_CLK_PHASE_DEG $write_clk_adjustment
		
	} else {
		set_parameter_value PLL_WRITE_CLK_PHASE_DEG $write_clk_adjustment
	}
	
	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		set_parameter_value PLL_MEM_CLK_PHASE_DEG [expr {[get_parameter_value PLL_WRITE_CLK_PHASE_DEG] - $dual_clk_adjustment}]
	} else {
		set_parameter_value PLL_MEM_CLK_PHASE_DEG 0
	}
	
	if {[ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		if {$c2p_write_clk_phase > 359 || $c2p_write_clk_phase < -359} {
			_error "Fata Error: c2p_write_clk_phase is out of range: $c2p_write_clk_phase"
		}
		if {$p2c_read_clk_phase > 359 || $p2c_read_clk_phase < -359} {
			_error "Fata Error: p2c_read_clk_phase is out of range: $p2c_read_clk_phase"
		}		
		set_parameter_value PLL_P2C_READ_CLK_PHASE_DEG $p2c_read_clk_phase
		set_parameter_value PLL_C2P_WRITE_CLK_PHASE_DEG $c2p_write_clk_phase
	} else {
		set_parameter_value PLL_P2C_READ_CLK_PHASE_DEG 0
		set_parameter_value PLL_C2P_WRITE_CLK_PHASE_DEG 0
	}
	
	foreach clk_name $pll_clock_names {	
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set phase_deg_sim_param_name "${clk_name}_PHASE_DEG_SIM"
		set value [get_parameter_value $phase_deg_param_name]
		
		if {[string compare -nocase $clk_name "PLL_P2C_READ_CLK"] == 0} {
			set_parameter_value $phase_deg_sim_param_name 0
		} elseif {[string compare -nocase $clk_name "PLL_C2P_WRITE_CLK"] == 0} {
			set_parameter_value $phase_deg_sim_param_name 0
		} elseif {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
			if {[string compare -nocase $clk_name "PLL_WRITE_CLK"] == 0} {
				set_parameter_value $phase_deg_sim_param_name 135
			} elseif {[string compare -nocase $clk_name "PLL_MEM_CLK"] == 0} {
				set_parameter_value $phase_deg_sim_param_name 45
			} else {
				set_parameter_value $phase_deg_sim_param_name $value
			}
		} elseif {[string compare -nocase $clk_name "PLL_WRITE_CLK"] == 0} {
			set_parameter_value $phase_deg_sim_param_name 45
		} else {
			set_parameter_value $phase_deg_sim_param_name $value
		}
	}
}

proc ::alt_mem_if::gen::uniphy_pll::_derive_pll_freq {protocol} {

	_dprint 1 "Preparing to derive PLL clock frequencies"
	
	_solve_desired_pll_clock_freq $protocol
	
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]
	
	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		
		set_parameter_value $freq_param_name [format "%.6f" [get_parameter_value $freq_param_name]]
		set_parameter_value $freq_str_param_name "[get_parameter_value $freq_param_name] MHz"
	}

	_dprint 1 "Clock frequency summary"
	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		
		_dprint 1 "$freq_param_name = [get_parameter_value $freq_param_name]"
	}
	
	return 1
}

proc ::alt_mem_if::gen::uniphy_pll::_derive_pll_phase {protocol} {

	_dprint 1 "Preparing to derive PLL clock phases"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		_solve_desired_pll_phases_sv $protocol
	} else {
		_solve_desired_pll_phases $protocol
	}
	
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]
	_dprint 1 "Preparing to update $pll_clock_names"
	
	foreach clk_name $pll_clock_names {
		set phase_param_name "${clk_name}_PHASE_DEG"
		set phase_sim_param_name "${clk_name}_PHASE_DEG_SIM"
		
		set phase_val [expr {round(2.0 * [get_parameter_value $phase_param_name]) / 2.0}]
		set phase_sim_val [expr {round(2.0 * [get_parameter_value $phase_sim_param_name]) / 2.0}]
		
		set_parameter_value $phase_param_name $phase_val
		set_parameter_value $phase_sim_param_name $phase_sim_val
	}
	
	foreach clk_name $pll_clock_names {
		set clock_freq_param_name "${clk_name}_FREQ"
		
		for { set i 0 } { $i < 2 } { incr i } {
			if {$i == 0} {
				set phase_deg_param_name "${clk_name}_PHASE_DEG"
				set phase_ps_param_name "${clk_name}_PHASE_PS"
				set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
			} else {
				set phase_deg_param_name "${clk_name}_PHASE_DEG_SIM"
				set phase_ps_param_name "${clk_name}_PHASE_PS_SIM"
				set phase_ps_str_param_name "${clk_name}_PHASE_PS_SIM_STR"
			}
			
			set phase_deg [get_parameter_value $phase_deg_param_name]
			while {$phase_deg >= 360} {
				set phase_deg [expr {$phase_deg - 360.0}]
			}
			while {$phase_deg < 0} {
				set phase_deg [expr {$phase_deg + 360.0}]
			}

			set clock_period_ps [ expr {1000000.0 / [get_parameter_value $clock_freq_param_name]} ]
			set clock_phase [ expr {$clock_period_ps * ($phase_deg / 360.0)} ]

			_dprint 1 "Determined clock phase is $clock_phase ps for clock [get_parameter_value $clock_freq_param_name] MHz ($clock_period_ps ps) [get_parameter_value $phase_deg_param_name] deg"
			set phase_val [expr {int([format "%.0f" $clock_phase])}]
			
			set_parameter_value $phase_ps_param_name $phase_val
			set_parameter_value $phase_ps_str_param_name "[get_parameter_value $phase_ps_param_name] ps"
		}
	}

	_dprint 1 "Clock phase summary:"
	foreach clk_name $pll_clock_names {
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		
		set phase_deg_sim_param_name "${clk_name}_PHASE_DEG_SIM"
		set phase_ps_sim_param_name "${clk_name}_PHASE_PS_SIM"
				
		_dprint 1 "$phase_deg_param_name = [get_parameter_value $phase_deg_param_name] ([get_parameter_value $phase_ps_param_name])"
		_dprint 1 "$phase_deg_sim_param_name = [get_parameter_value $phase_deg_sim_param_name] ([get_parameter_value $phase_ps_sim_param_name])"
	}

	return 1
}

proc ::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_pll_legality {} {
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list]

	set solved_clock_params [list]

	set result [_update_pll_parameters_from_pll_legality_from_list $pll_clock_names solved_clock_params]

	set solved_pll_mult [expr {int(1.0 * [get_parameter_value "PLL_MEM_CLK_FREQ"] * [get_parameter_value "PLL_MEM_CLK_DIV"] / [get_parameter_value REF_CLK_FREQ])}]
	for {set i 0} {$i < [llength $solved_clock_params]} {incr i} {
		set clk_name [lindex $pll_clock_names $i]
		set mult_param_name "${clk_name}_MULT"
		set_parameter_value $mult_param_name $solved_pll_mult
	}
	
	return $result
}

proc ::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_pll_legality_from_list {pll_clock_names solved_clock_params_ref} {

	upvar 1 $solved_clock_params_ref solved_clock_params
	
	set pll_part [::alt_mem_if::gen::uniphy_pll::get_pll_part_name [::alt_mem_if::gui::system_info::get_device_family] [get_parameter_value SPEED_GRADE]]

	set clock_params [list]
	set solved_clock_params [list]

	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"

		
		set requested_pll_output_freq [get_parameter_value $freq_param_name]
		set requested_pll_output_phase [get_parameter_value $phase_ps_param_name]
		set requested_pll_duty_cycle "50"
		
		lappend clock_params [list $requested_pll_output_freq $requested_pll_output_phase]

		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_skip_pll_legality] == 1} {
			set solved_params [list $requested_pll_output_freq $requested_pll_output_phase  $requested_pll_duty_cycle]
			lappend solved_clock_params $solved_params
		}
	}
	
	set safe_halved_clock 0
		
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_skip_pll_legality] == 0} {
		set solved_clock_params [::quartus::advanced_pll_legality::get_advanced_pll_legality_solved_legal_pll_values $pll_part [get_parameter_value REF_CLK_FREQ] $clock_params $safe_halved_clock]
	}

	if {[llength $solved_clock_params] != [llength $pll_clock_names]} {
		_error "Fata Error: Expected [llength $pll_clock_names] solved clocks but got [llength $solved_clock_params]"
	}

	for {set i 0} {$i < [llength $solved_clock_params]} {incr i} {
		
		set clk_name [lindex $pll_clock_names $i]
		
		set clock_info [lindex $solved_clock_params $i]
		
		set solved_pll_output_freq [lindex $clock_info 0]
		set solved_pll_output_phase [lindex $clock_info 1]
		set solved_pll_output_duty_cycle [lindex $clock_info 2]
		
		set freq_param_name "${clk_name}_FREQ"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		
		set_parameter_value $freq_param_name $solved_pll_output_freq
		set_parameter_value $freq_str_param_name "$solved_pll_output_freq MHz"

		set_parameter_value $phase_ps_param_name $solved_pll_output_phase
		set_parameter_value $phase_ps_str_param_name "$solved_pll_output_phase ps"
	}
	

	return 1

}


proc ::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_computepll {} {
	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]

	return [_update_pll_parameters_from_computepll_from_list $pll_clock_names]
}


proc ::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_computepll_from_list {pll_clock_names} {

	if {[regexp -nocase {^[ ]*([0-9]+)} [get_parameter_value SPEED_GRADE] match pll_device_speed_grade] == 0} {
		_error "Could not pattern match speed grade [get_parameter_value SPEED_GRADE]"
	}
	_dprint 1 "Using formatted PLL speedgrade $pll_device_speed_grade"
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0} {
		set pll_device_family "stratix iii"
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0} {
		set pll_device_family "stratix iv"
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX"] == 0} {
		set pll_device_family "arria ii gx"
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0} {
		set pll_device_family "arria ii gz"
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "MAX10FPGA"] == 0} {
		set pll_device_family "max 10 fpga"
	} else {
		_error "Fatal Error: Unknown family [get_parameter_value DEVICE_FAMILY]"
	}


	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX"] == 0 } {
		set pll_device_speed_grade 4
		_dprint 1 "Using device speedgrade $pll_device_speed_grade for family [::alt_mem_if::gui::system_info::get_device_family]"
	}


	set requested_pll_output_freq [list]
	set requested_pll_output_phase [list]
	foreach clk_name $pll_clock_names {
		set freq_param_name "${clk_name}_FREQ"
		set phase_param_name "${clk_name}_PHASE_DEG"
		
		lappend requested_pll_output_freq [get_parameter_value $freq_param_name]
		lappend requested_pll_output_phase [get_parameter_value $phase_param_name]
	}



	global env
	set temp_dir_name "compute_pll_temp_[expr {int(100 * rand())}]"
	if {[info exists env(TMP)] && [string match "" $env(TMP)] != 1 } {
		set compute_pll_temp_dir [file join $env(TMP) $temp_dir_name]
	} elseif {[info exists env(HOME)] && [string match "" $env(HOME)] != 1 } {
		set compute_pll_temp_dir [file join $env(HOME) $temp_dir_name]
	} else {
		set compute_pll_temp_dir [file join [pwd] $temp_dir_name]
	}
	catch {file mkdir $compute_pll_temp_dir} temp_result
	_dprint 1 "Temporary directory for compute_pll is $compute_pll_temp_dir"

	set pll_params [alt_mem_if::util::iptclgen::compute_pll_params \
					"$pll_device_family" \
					$pll_device_speed_grade \
					"fast_pll" \
					[get_parameter_value REF_CLK_FREQ] \
					$requested_pll_output_freq \
					$requested_pll_output_phase \
					$compute_pll_temp_dir]
	
        catch {file delete -force $compute_pll_temp_dir} temp_result

	for {set clknum 0} {$clknum < [llength $pll_clock_names]} {incr clknum} {
		set clk_name [lindex $pll_clock_names $clknum]
		
		_dprint 1 "Calculating achievable settings for clock $clk_name"
		
		set clk_mult [lindex [lindex $pll_params $clknum] 0]
		set clk_div [lindex [lindex $pll_params $clknum] 1]
		set clk_phase [lindex [lindex $pll_params $clknum] 2]
		set clk_freq [lindex [lindex $pll_params $clknum] 3]
		
		_dprint 1 "MULT = $clk_mult"
		_dprint 1 "DIV = $clk_div"
		_dprint 1 "PHASE = $clk_phase"
		_dprint 1 "FREQ = $clk_freq"

		set freq_param_name "${clk_name}_FREQ"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"
		
		set clock_period_ps [ expr {1000000.0 / [get_parameter_value $freq_param_name]} ]
		set clock_phase_deg [ expr {$clk_phase * 360.0 / $clock_period_ps} ]
		
		set_parameter_value $freq_param_name $clk_freq
		set_parameter_value $freq_str_param_name "[get_parameter_value $freq_param_name] MHz"
		set_parameter_value $phase_ps_param_name [expr {int($clk_phase)}]
		set_parameter_value $phase_ps_str_param_name "[get_parameter_value $phase_ps_param_name] ps"
		set_parameter_value $phase_deg_param_name [expr {round(2.0 * $clock_phase_deg) / 2.0}]
		set_parameter_value $mult_param_name [expr {int($clk_mult)}]
		set_parameter_value $div_param_name [expr {int($clk_div)}]
	}

	return 1
}

proc ::alt_mem_if::gen::uniphy_pll::get_pll_part_name {family_name speed} {
	set device_part ""
	
	if {[string compare -nocase $family_name "stratixv"] == 0 ||
		[string compare -nocase $family_name "arriav"] == 0 ||
		[string compare -nocase $family_name "cyclonev"] == 0 ||
		[string compare -nocase $family_name "arriavgz"] == 0 ||
		[string compare -nocase $family_name "max10fpga"] == 0} {
		if {[string compare -nocase $family_name "stratixv"] == 0 } {
			if {$speed == "1"} {
				set device_part "5SGXEB6R1F43C1"
			} elseif {$speed == "2"} {
				set device_part "5SGXEA7H2F35C2ES"
			} elseif {$speed == "3"} {
				set device_part "5SGXEA7H2F35C3ES"
			} elseif {$speed == "4"} {
				set device_part "5SGXEA7H3F35C4ES"
			} else {
				set device_part "5SGXEA7H2F35C2ES"
				_eprint "Illegal speedgrade $speed chosen for family $family_name. Only (1/2/3/4) are valid speedgrades."
			}
		} elseif {[string compare -nocase $family_name "arriavgz"] == 0 } {
			if {$speed == "3"} {
				set device_part "5AGZME1E2H29C3"
			} elseif {$speed == "4"} {
				set device_part "5AGZME1E3H29C4"
			} else {
				set device_part "5AGZME1E2H29C3"
				_eprint "Illegal speedgrade $speed chosen for family $family_name. Only (3/4) are valid speedgrades."
			}
		} elseif {[string compare -nocase $family_name "arriav"] == 0 } {
			if {$speed == "4"} {
				set device_part "5AGXFB3H4F35C4"
			} elseif {$speed == "5"} {
				set device_part "5AGXFB3H4F35C5"
			} elseif {$speed == "6"} {
				set device_part "5AGXFB3H6F35C6"
                        } elseif {$speed == "3"} {
                                set device_part "5AGTFD7K3F40I3"
			} else {
				set device_part "5AGXFB3H4F35C4"
				_eprint "Illegal speedgrade $speed chosen for family $family_name. Only (3/4/5/6) are valid speedgrades."
			}
		} elseif {[string compare -nocase $family_name "cyclonev"] == 0 } {
			if {$speed == "6"} {
				set device_part "5CGTFD6F27C5ES"
			} elseif {$speed == "7"} {
				set device_part "5CGXBC7C6U19C7"
			} elseif {$speed == "8"} {
				set device_part "5CGXBC7C7F23C8"
			} else {
				set device_part "5CGTFD6F27C5ES"
				_eprint "Illegal speedgrade $speed chosen for family $family_name. Only (6/7/8) are valid speedgrades."
			}
		} elseif {[string compare -nocase $family_name "max10fpga"] == 0 } {
			if {$speed == "7"} {
				set device_part "10M08SCE144C7"
			} elseif {$speed == "8"} {
				set device_part "10M08SCE144C8"
			} else {
				set device_part "10M08SCE144I7"
				_eprint "Illegal speedgrade $speed chosen for family $family_name. Only (7/8) are valid speedgrades."
			}
		} else {
			_error "Fatal Error: Family $family_name is not yet supported by RBC"
		}
	} else {
		_error "Fatal Error: Family $family_name is not supported by pll legality chceking"
	}
	
	return $device_part
}

proc ::alt_mem_if::gen::uniphy_pll::_derive_pll_cache_param {} {

	if {[string compare -nocase [get_parameter_value PLL_CLK_PARAM_VALID] true] == 0} {
		set_parameter_value PLL_CLK_CACHE_VALID false
	} else {
		if {
			[string compare -nocase [get_parameter_value SPEED_GRADE] [get_parameter_value SPEED_GRADE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value IS_ES_DEVICE] [get_parameter_value IS_ES_DEVICE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value MEM_CLK_FREQ] [get_parameter_value MEM_CLK_FREQ_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value REF_CLK_FREQ] [get_parameter_value REF_CLK_FREQ_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value RATE] [get_parameter_value RATE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] [get_parameter_value HCX_COMPAT_MODE_CACHE]] == 0 &&
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] [::alt_mem_if::gui::system_info::get_device_family]] == 0 &&
			[string compare -nocase [get_parameter_value SEQUENCER_TYPE] [get_parameter_value SEQUENCER_TYPE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value COMMAND_PHASE] [get_parameter_value COMMAND_PHASE_CACHE]] == 0 && 
			[string compare -nocase [get_parameter_value MEM_CK_PHASE] [get_parameter_value MEM_CK_PHASE_CACHE]] == 0 && 
			[string compare -nocase [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE] [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value P2C_READ_CLOCK_ADD_PHASE] [get_parameter_value P2C_READ_CLOCK_ADD_PHASE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value ACV_PHY_CLK_ADD_FR_PHASE] [get_parameter_value ACV_PHY_CLK_ADD_FR_PHASE_CACHE]] == 0 &&
			[string compare -nocase [get_parameter_value USE_MEM_CLK_FREQ] [get_parameter_value USE_MEM_CLK_FREQ_CACHE]] == 0} {
				set_parameter_value PLL_CLK_CACHE_VALID true
		} else {
			set_parameter_value PLL_CLK_CACHE_VALID false

			set_parameter_value SPEED_GRADE_CACHE [get_parameter_value SPEED_GRADE]
			set_parameter_value IS_ES_DEVICE_CACHE [get_parameter_value IS_ES_DEVICE]			
			set_parameter_value MEM_CLK_FREQ_CACHE [get_parameter_value MEM_CLK_FREQ]
			set_parameter_value REF_CLK_FREQ_CACHE [get_parameter_value REF_CLK_FREQ]
			set_parameter_value RATE_CACHE [get_parameter_value RATE]
			set_parameter_value HCX_COMPAT_MODE_CACHE [get_parameter_value HCX_COMPAT_MODE]
			set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE [::alt_mem_if::gui::system_info::get_device_family]
			set_parameter_value SEQUENCER_TYPE_CACHE [get_parameter_value SEQUENCER_TYPE]
			set_parameter_value COMMAND_PHASE_CACHE [get_parameter_value COMMAND_PHASE]
			set_parameter_value MEM_CK_PHASE_CACHE [get_parameter_value MEM_CK_PHASE]
			set_parameter_value C2P_WRITE_CLOCK_ADD_PHASE_CACHE [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE]
			set_parameter_value P2C_READ_CLOCK_ADD_PHASE_CACHE [get_parameter_value P2C_READ_CLOCK_ADD_PHASE]
			set_parameter_value ACV_PHY_CLK_ADD_FR_PHASE_CACHE [get_parameter_value ACV_PHY_CLK_ADD_FR_PHASE]
			set_parameter_value USE_MEM_CLK_FREQ_CACHE [get_parameter_value USE_MEM_CLK_FREQ]
		}
	}
}

proc ::alt_mem_if::gen::uniphy_pll::_update_hps_pll_parameters {} {

	set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]
	
	_dprint 1 "HPS: clocks: $pll_clock_names"

	if {[string compare -nocase [get_parameter_value USE_MEM_CLK_FREQ] "true"] != 0} {
		set results [_solve_hps_pll_parameters [get_parameter_value REF_CLK_FREQ] [expr 2.0 * [get_parameter_value MEM_CLK_FREQ]]]
	} else {
		set results [list [expr 2.0 * [get_parameter_value MEM_CLK_FREQ]] 1 1]
	}
		
	set achieved_freq [lindex $results 0]
	set div [lindex $results 1]
	set mul [lindex $results 2]

	_dprint 1 "HPS: solve clocks: $achieved_freq $div $mul"

	foreach clk_name $pll_clock_names {
		
		_dprint 1 "HPS: Computing derived clock parameters for $clk_name"
		
		set freq_param_name "${clk_name}_FREQ"
		set freq_str_param_name "${clk_name}_FREQ_STR"
		set phase_deg_param_name "${clk_name}_PHASE_DEG"
		set phase_ps_param_name "${clk_name}_PHASE_PS"
		set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
		set mult_param_name "${clk_name}_MULT"
		set div_param_name "${clk_name}_DIV"

		if {[string compare -nocase $clk_name "PLL_DR_CLK"] == 0} {
			set freq $achieved_freq
			set total_div $div
		} else {
			set freq [expr $achieved_freq / 2.0]
			set total_div [expr $div * 2]
		}

		set phase_deg [get_parameter_value $phase_deg_param_name]
		set clock_period_ps [ expr {1000000.0 / $freq} ]
		set clock_phase_ps [ expr {$phase_deg / 360.0 * $clock_period_ps} ]

		set_parameter_value $freq_param_name [format "%.6f" $freq]
		set_parameter_value $freq_str_param_name "[get_parameter_value $freq_param_name] MHz"
		set_parameter_value $phase_ps_param_name [expr {int($clock_phase_ps)}]
		set_parameter_value $phase_ps_str_param_name "[get_parameter_value $phase_ps_param_name] ps"
		set_parameter_value $phase_deg_param_name [expr {round(2.0 * $phase_deg)/2.0}]
		set_parameter_value $mult_param_name $mul
		set_parameter_value $div_param_name $total_div
	}

	
	return 1
}

proc ::alt_mem_if::gen::uniphy_pll::_solve_hps_pll_parameters {pll_ref_clk target_clk} {

	set ratio_clk [expr double($target_clk) / double($pll_ref_clk)]

	_dprint 1 [format "HPS: ref=%5.5f target=%5.5f" $pll_ref_clk $target_clk]

	set best_div 0
	set best_mul 0
	set best_cost 9999999

	for {set div 1} {$div <= 64} {incr div} {
		for {set mul 1} {$mul <= 4096} {incr mul} {
			set ratio [expr double($mul) / double($div)]

			set achieved_clk [expr double($pll_ref_clk) / $div * $mul]
			set error [expr abs($achieved_clk - $target_clk)]

			if {$error < 10} {
				set factor [expr pow(10, $error)]
				set cost [expr $div * $factor]
			} else {
				set cost 999999999
			}

			if {$cost < $best_cost} {
				set best_cost $cost
				set best_div $div
				set best_mul $mul
			}

			if {$ratio >= $ratio_clk} {
				break;
			}
		}
	}

	set achieved_clk [expr double($pll_ref_clk) / $best_div * $best_mul]
	set error [expr abs($achieved_clk - $target_clk)]

	_dprint 1 [format "HPS: Min Cost: div=%3d mul=%3d achieved_freq=%5.5f error=%1.5f" $best_div $best_mul $achieved_clk $error]

	return [list $achieved_clk $best_div $best_mul]
}



::alt_mem_if::gen::uniphy_pll::_init
