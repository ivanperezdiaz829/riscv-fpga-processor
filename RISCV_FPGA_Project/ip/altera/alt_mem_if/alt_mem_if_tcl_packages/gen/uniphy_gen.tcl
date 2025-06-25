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


package provide alt_mem_if::gen::uniphy_gen 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::list_array
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::seq_mem_size
package require quartus::advanced_pll_legality
package require alt_mem_if::gen::uniphy_pll

namespace eval ::alt_mem_if::gen::uniphy_gen:: {
	
	variable seq_version 13.1
	
}



proc ::alt_mem_if::gen::uniphy_gen::get_ifdef_parameters {} {
	
	set params_list [split [get_parameters]]
	
	set spaces "\[ \t\n\]"
	set notspaces "\[^ \t\n\]"
	
	set ifdef_list [list]
	
	foreach param $params_list {
		if { [regexp -- "^${spaces}*IFDEF_${notspaces}+${spaces}*$" $param] == 1 } {
			set ifdef_list [concat $ifdef_list $param]
			_dprint 1 "Found ifdef $param"
		}
	}
	
	return $ifdef_list
}


proc ::alt_mem_if::gen::uniphy_gen::unset_ifdef_parameters {} {
	
	_dprint 1 "Preparing to unset ifdef parameters"
	
	set ifdef_list [alt_mem_if::gen::uniphy_gen::get_ifdef_parameters]

	foreach ifdef $ifdef_list {
		set_parameter_value $ifdef false
		_dprint 1 "Set $ifdef to [get_parameter_value $ifdef]"
	}
}


proc ::alt_mem_if::gen::uniphy_gen::generate_clock_pair_generator {prepend_str tmpdir} {
	
	_iprint "Generating clock pair generator" 1
	
	set params_list [list "CBX_FILE=${prepend_str}clock_pair_generator.v" \
					      "CBX_OUTPUT_DIRECTORY=$tmpdir" \
						  "CBX_AUTO_BLACKBOX=ALL" \
						  "CBX_SINGLE_OUTPUT_FILE=ON" \
						  "DEVICE_FAMILY=[get_parameter_value DEVICE_FAMILY]" \
						  "ENABLE_BUS_HOLD=FALSE" \
						  "NUMBER_OF_CHANNELS=1" \
						  "OPEN_DRAIN_OUTPUT=FALSE" \
						  "PSEUDO_DIFFERENTIAL_MODE=TRUE" \
						  "USE_DIFFERENTIAL_MODE=TRUE" \
						  "USE_OE=FALSE" \
						  "USE_TERMINATION_CONTROL=FALSE" \
						  "USE_OUT_DYNAMIC_DELAY_CHAIN1=FALSE" \
						  "USE_OUT_DYNAMIC_DELAY_CHAIN2=FALSE" \
						  datain dataout dataout_b]
	alt_mem_if::util::iptclgen::generate_ip_clearbox altiobuf_out $params_list
	
	return [list [file join $tmpdir ${prepend_str}clock_pair_generator.v]]
	
}


proc ::alt_mem_if::gen::uniphy_gen::generate_altdq_dqs2 {prepend_str protocol tmpdir fileset} {

	_dprint 1 "Generating altdq_dqs2"
	
	set return_files [list]

	set device_family [::alt_mem_if::gui::system_info::get_device_family]
	
	if {[string compare -nocase $fileset "QUARTUS_SYNTH"] == 0} {
		set need_abstract 0
		set need_real 1
	} elseif {[string compare -nocase $fileset "VERILOG_ABSTRACT"] == 0} {
		set need_abstract 1
		set need_real 0
	} elseif {[string compare -nocase $fileset "VERILOG_REAL"] == 0} {
		set need_abstract 0
		set need_real 1
	} else {
		if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
			set need_abstract 0
		} else {
			set need_abstract 1
		}
		set need_real 1
	}


	set altdq_ifdef_list [list $device_family]
	if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
		lappend altdq_ifdef_list "FAMILY_HAS_NO_DYNCONF"
	}
	if {[string compare -nocase $device_family "STRATIXIII"] == 0 || [string compare -nocase $device_family "STRATIXIV"] == 0 ||
	    [string compare -nocase $device_family "ARRIAIIGX"] == 0 || [string compare -nocase $device_family "ARRIAIIGZ"] == 0} {
		lappend altdq_ifdef_list "DDIO_3REG"
	}
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		lappend altdq_ifdef_list "USE_OFFSET_CTRL"
	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase $protocol "QDRII"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 } {
			lappend altdq_ifdef_list "USE_OFFSET_CTRL"
		}
	}

	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend altdq_ifdef_list "CONNECT_TO_HARD_PHY"
	}
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			lappend altdq_ifdef_list "QUARTER_RATE_MODE"
		}
	}
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend altdq_ifdef_list "USE_SHADOW_REGS"
	}
	if {[string compare -nocase $protocol "LPDDR2"] == 0} {
		lappend altdq_ifdef_list "LPDDR2"
	}

	set read_dq_group_width [expr {[get_parameter_value MEM_IF_DQ_WIDTH]/[get_parameter_value MEM_IF_READ_DQS_WIDTH]}]
	set write_dq_group_width [expr {[get_parameter_value MEM_IF_DQ_WIDTH]/[get_parameter_value MEM_IF_WRITE_DQS_WIDTH]}]

	set param_list [list]
	
	if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
		set system_info_param "--system-info=DEVICE_FAMILY=Arria II GX"
	} else {
		set system_info_param "--system-info=DEVICE_FAMILY=$device_family"
	}

	if {[string compare -nocase $protocol "QDRII"] == 0} {
		lappend param_list "PIN_WIDTH=$write_dq_group_width"
	} else {
		lappend param_list "PIN_WIDTH=$read_dq_group_width"
	}

	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
			lappend param_list "EXTRA_OUTPUT_WIDTH=1"
		} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0} {
			lappend param_list "EXTRA_OUTPUT_WIDTH=1"
		} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
			lappend param_list "EXTRA_OUTPUT_WIDTH=1"
		} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
			set dm_width_per_device [ expr {[get_parameter_value MEM_IF_DM_WIDTH] / [get_parameter_value DEVICE_WIDTH]} ]
			lappend param_list "EXTRA_OUTPUT_WIDTH=$dm_width_per_device"
		} elseif {[string compare -nocase $protocol "DDRIISRAM"] == 0} {
			set dm_width_per_device [ expr {[get_parameter_value MEM_IF_DM_WIDTH] / [get_parameter_value DEVICE_WIDTH]} ]
			lappend param_list "EXTRA_OUTPUT_WIDTH=$dm_width_per_device"
		}
	} else {
		lappend param_list "EXTRA_OUTPUT_WIDTH=0"
	}

	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
			lappend param_list "HALF_RATE_OUTPUT=true"
		} else {
			lappend param_list "HALF_RATE_OUTPUT=false"
		}
		lappend param_list "DQS_ENABLE_PHASE_SETTING=3"
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0 || [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		lappend param_list "HALF_RATE_OUTPUT=true"
		if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			lappend param_list "DQS_ENABLE_PHASE_SETTING=0"
		} else {
			lappend param_list "DQS_ENABLE_PHASE_SETTING=3"
		}
	}

	lappend param_list "HALF_RATE_INPUT=false"

	lappend param_list "USE_INPUT_PHASE_ALIGNMENT=false"

	if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0 && [string compare -nocase $device_family "ARRIAV"] != 0 && [string compare -nocase $device_family "CYCLONEV"]!= 0} {
		lappend param_list "USE_OUTPUT_PHASE_ALIGNMENT=true"
	} else {
		lappend param_list "USE_OUTPUT_PHASE_ALIGNMENT=false"
	}

	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
		lappend param_list "USE_2X_FF=true"
	} else {
		lappend param_list "USE_2X_FF=false"
	}

	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		lappend param_list "DUAL_WRITE_CLOCK=true"
	} else {
		lappend param_list "DUAL_WRITE_CLOCK=false"
	}
	
	if {[string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true"] == 0} {
		lappend param_list "DLL_USE_2X_CLK=true"
	} else {
		lappend param_list "DLL_USE_2X_CLK=false"
	}

	if {[string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true"] == 0} {
		lappend param_list "USE_LDC_AS_LOW_SKEW_CLOCK=true"
		
		set phase_setting_0_degree 0
		
		set phase_setting_180_degree 4
		
		set phase_setting_90_degree [get_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING]
		
		if {[string compare -nocase $protocol "QDRII"] == 0 && [get_parameter_value MEM_BURST_LENGTH] == 2} {
			lappend param_list "OUTPUT_DQS_PHASE_SETTING=$phase_setting_90_degree"
			lappend param_list "OUTPUT_DQ_PHASE_SETTING=$phase_setting_0_degree"
		} else {
			lappend param_list "OUTPUT_DQS_PHASE_SETTING=$phase_setting_180_degree"
			lappend param_list "OUTPUT_DQ_PHASE_SETTING=$phase_setting_90_degree"
		}		
	} else {
		lappend param_list "USE_LDC_AS_LOW_SKEW_CLOCK=false"
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		lappend param_list "USE_DYNAMIC_CONFIG=true"
	} else {
		lappend param_list "USE_DYNAMIC_CONFIG=false"
	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase $protocol "QDRII"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 } {
			lappend param_list "USE_DYNAMIC_CONFIG=true"
		} 
	}

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
		lappend param_list "PIN_TYPE=bidir"
		lappend param_list "INVERT_CAPTURE_STROBE=true"
		lappend param_list "SWAP_CAPTURE_STROBE_POLARITY=false"
		lappend param_list "EXTRA_OUTPUTS_USE_SEPARATE_GROUP=false"
		lappend param_list "USE_BIDIR_STROBE=true"
		lappend param_list "USE_DQS_ENABLE=true"
		if {[string compare -nocase [get_parameter_value "MEM_IF_DQSN_EN"] "true"] == 0} {
			lappend param_list "CAPTURE_STROBE_TYPE=Differential"
		} else {
			lappend param_list "CAPTURE_STROBE_TYPE=Single"
		}
		lappend param_list "OCT_SOURCE=2"
		lappend param_list "USE_OUTPUT_STROBE_RESET=false"
		if { [string compare -nocase [get_parameter_value RATE] "HALF"] == 0 || [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0 } {
			if { [string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
				lappend param_list "USE_HALF_RATE_DQS_ENABLE=true"
			}
		}
		lappend param_list "SEPERATE_LDC_FOR_WRITE_STROBE=false"
	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
		lappend param_list "PIN_TYPE=bidir"
		lappend param_list "USE_BIDIR_STROBE=false"
		lappend param_list "USE_DQS_ENABLE=false"
		lappend param_list "CAPTURE_STROBE_TYPE=Differential"
		lappend param_list "OCT_SOURCE=2"
		lappend param_list "USE_OUTPUT_STROBE_RESET=false"
		if {([string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0)} {
			
			if {[string compare -nocase $protocol "RLDRAMII"] == 0} {
				if {[string compare -nocase [get_parameter_value RLDRAMII_AV_EMIF_INVERT_CAPTURE_STROBE] "true"] == 0} {
					lappend param_list "INVERT_CAPTURE_STROBE=true"
				} else {
					lappend param_list "INVERT_CAPTURE_STROBE=false"
				}
			} else {
				lappend param_list "INVERT_CAPTURE_STROBE=false"
			}

			lappend param_list "SWAP_CAPTURE_STROBE_POLARITY=true"
			
			if {[get_parameter_value MEM_IF_DQ_WIDTH] <= 18} {
			lappend param_list "SEPERATE_LDC_FOR_WRITE_STROBE=true"
		} else {
			lappend param_list "SEPERATE_LDC_FOR_WRITE_STROBE=false"
		}
		} else {
			lappend param_list "INVERT_CAPTURE_STROBE=true"
			lappend param_list "SWAP_CAPTURE_STROBE_POLARITY=false"
			lappend param_list "SEPERATE_LDC_FOR_WRITE_STROBE=false"
		}
		
		if {[string compare -nocase $protocol "RLDRAM3"] == 0} {
			lappend param_list "EXTRA_OUTPUTS_USE_SEPARATE_GROUP=true"
		} else {
			lappend param_list "EXTRA_OUTPUTS_USE_SEPARATE_GROUP=false"
		}
	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
		lappend param_list "PIN_TYPE=output"
		lappend param_list "INVERT_CAPTURE_STROBE=false"
		lappend param_list "SWAP_CAPTURE_STROBE_POLARITY=false"
		lappend param_list "EXTRA_OUTPUTS_USE_SEPARATE_GROUP=false"
		lappend param_list "USE_BIDIR_STROBE=false"
		lappend param_list "USE_DQS_ENABLE=false"
		if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
			lappend param_list "CAPTURE_STROBE_TYPE=Single"
		} else {
			lappend param_list "CAPTURE_STROBE_TYPE=Complimentary"
		}

		lappend param_list "OCT_SOURCE=1"
		
		lappend param_list "USE_OUTPUT_STROBE_RESET=true"
	} elseif {[string compare -nocase $protocol "DDRIISRAM"] == 0} {
		lappend param_list "PIN_TYPE=bidir"
		lappend param_list "INVERT_CAPTURE_STROBE=true"
		lappend param_list "SWAP_CAPTURE_STROBE_POLARITY=false"
		lappend param_list "EXTRA_OUTPUTS_USE_SEPARATE_GROUP=false"
		lappend param_list "USE_BIDIR_STROBE=false"
		lappend param_list "USE_DQS_ENABLE=false"
		lappend param_list "CAPTURE_STROBE_TYPE=Differential"
		lappend param_list "OCT_SOURCE=2"		
		lappend param_list "USE_OUTPUT_STROBE_RESET=false"
	}

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
		lappend param_list "PREAMBLE_TYPE=low"
		if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				lappend param_list "EMIF_UNALIGNED_PREAMBLE_SUPPORT=false"
			} else {
				lappend param_list "EMIF_UNALIGNED_PREAMBLE_SUPPORT=true"
			}
		} else {
			lappend param_list "EMIF_UNALIGNED_PREAMBLE_SUPPORT=true"
		}
	} elseif {[string compare -nocase $protocol "DDR3"] == 0} {
		lappend param_list "PREAMBLE_TYPE=high"
	}
	
	lappend param_list "USE_OUTPUT_STROBE=true"
	if {[string compare -nocase [get_parameter_value "MEM_IF_DQSN_EN"] "true"] == 0} {
		lappend param_list "DIFFERENTIAL_OUTPUT_STROBE=true"
	} else {
		lappend param_list "DIFFERENTIAL_OUTPUT_STROBE=false"
	}

	if {[string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true"] == 0} {
		lappend param_list "INPUT_FREQ=[expr [get_parameter_value MEM_CLK_FREQ]*2]"
	} else {
		lappend param_list "INPUT_FREQ=[get_parameter_value MEM_CLK_FREQ]"
	}
	lappend param_list "DELAY_CHAIN_BUFFER_MODE=[get_parameter_value DELAY_BUFFER_MODE]"
	lappend param_list "DQS_PHASE_SETTING=[get_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING]"
	lappend param_list "FORCE_DQS_PHASE_SHIFT=[get_parameter_value DQS_PHASE_SHIFT]"
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		lappend param_list "USE_OFFSET_CTRL=true"
	} else {
		lappend param_list "USE_OFFSET_CTRL=false"
	}
	
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase $protocol "QDRII"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 } {
			lappend param_list "USE_OFFSET_CTRL=true"
		}
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		lappend param_list "USE_DQS_TRACKING=true"
	} else {
		lappend param_list "USE_DQS_TRACKING=false"
	}
	
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend param_list "USE_SHADOW_REGS=true"
	} else {
		lappend param_list "USE_SHADOW_REGS=false"
	}
	
	if {[string compare -nocase $protocol "LPDDR2"] == 0} {
		lappend param_list "LPDDR2=true"
	} else {
		lappend param_list "LPDDR2=false"
	}
		
	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] == 0} {
		lappend param_list "CALIBRATION_SUPPORT=true"
	} else {
		lappend param_list "CALIBRATION_SUPPORT=false"
	}
	
	lappend param_list "REGULAR_WRITE_BUS_ORDERING=true"

	if {$need_real} {
		lappend param_list "USE_REAL_RTL=true"
	} else {
		lappend param_list "USE_REAL_RTL=false"
	}

	if {$need_abstract} {
		lappend param_list "USE_ABSTRACT_RTL=true"
	} else {
		lappend param_list "USE_ABSTRACT_RTL=false"
	}
	
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		lappend param_list "USE_HARD_FIFOS=true"
		if {[string compare -nocase $protocol "QDRII"] == 0 || [string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
			lappend param_list "USE_DQSIN_FOR_VFIFO_READ=true"
		} else {
			lappend param_list "USE_DQSIN_FOR_VFIFO_READ=false"
		}
	} else {
		lappend param_list "USE_HARD_FIFOS=false"
		lappend param_list "USE_DQSIN_FOR_VFIFO_READ=false"
	}
	
	if {([string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0) &&
		[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend param_list "NATURAL_ALIGNMENT=true"
	} else {
		lappend param_list "NATURAL_ALIGNMENT=false"
	}

	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend param_list "CONNECT_TO_HARD_PHY=true"
	}

	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			lappend param_list "QUARTER_RATE_MODE=true"
		}
	}

	lappend param_list "HHP_HPS=[get_parameter_value HHP_HPS]"
	
	set base_param_list $param_list
	
	set arg_list [list]
	foreach param $param_list {
		lappend arg_list "--component-param=$param"
	}

	set basename "altdq_dqs2.sv"
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		set basename "altdq_dqs2_acv.sv"
	}
	
	set altdq_dqs2_filename [file tail [alt_mem_if::util::iptclgen::generate_outfile_name $basename $altdq_ifdef_list]]
	
	set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=${prepend_str}altdqdqs" "--output-dir=$tmpdir" $system_info_param] $arg_list]
	_iprint "Generating ${prepend_str}altdqdqs" 1

	alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altdq_dqs2 $arg_list $tmpdir "generate_altdqdqs.tcl"

	if {[string compare -nocase "SIM_VHDL" $fileset] == 0} {
		lappend return_files [file join $tmpdir ${prepend_str}altdqdqs.vhd]
		lappend return_files [file join $tmpdir mentor ${altdq_dqs2_filename}]
		if {$need_abstract} {
			lappend return_files [file join $tmpdir mentor altdq_dqs2_abstract.sv]
			lappend return_files [file join $tmpdir mentor altdq_dqs2_cal_delays.sv]
		}
		if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
			lappend return_files [file join $tmpdir mentor soft_hr_ddio_out.v]
		}
	} else {
		lappend return_files [file join $tmpdir ${prepend_str}altdqdqs.v]
	}

	lappend return_files [file join $tmpdir ${altdq_dqs2_filename}]
	if {$need_abstract} {
		lappend return_files [file join $tmpdir altdq_dqs2_abstract.sv]
		lappend return_files [file join $tmpdir altdq_dqs2_cal_delays.sv]
	}

	if {[string compare -nocase $device_family "ARRIAIIGX"] == 0} {
		lappend return_files [file join $tmpdir soft_hr_ddio_out.v]
	}

	if {[string compare -nocase $protocol "QDRII"] == 0} {

		set param_list $base_param_list

		alt_mem_if::util::list_array::update_or_append param_list "PIN_WIDTH=$read_dq_group_width"
		alt_mem_if::util::list_array::update_or_append param_list "PIN_TYPE=input"

		alt_mem_if::util::list_array::update_or_append param_list "EXTRA_OUTPUT_WIDTH=0"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE_RESET=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_TERMINATION_CONTROL=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_PHASE_ALIGNMENT=false"
		alt_mem_if::util::list_array::update_or_append param_list "DIFFERENTIAL_OUTPUT_STROBE=false"
		
		set arg_list [list]
		foreach param $param_list {
			lappend arg_list "--component-param=$param"
		}

		set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=${prepend_str}altdqdqs_in" "--output-dir=$tmpdir" $system_info_param] $arg_list]
		_iprint "Generating ${prepend_str}altdqdqs_in" 1
		alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altdq_dqs2 $arg_list $tmpdir "generate_altdqdqs_in.tcl"

		if {[string compare -nocase "SIM_VHDL" $fileset] == 0} {
			lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_in.vhd]
		} else {
			lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_in.v]
		}

	}

	if {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
		set dq_width_per_device [expr {[get_parameter_value MEM_IF_DQ_WIDTH]/[get_parameter_value DEVICE_WIDTH]}]
		if {$dq_width_per_device == 18 || $dq_width_per_device == 36} {

			set param_list $base_param_list

			alt_mem_if::util::list_array::update_or_append param_list "EXTRA_OUTPUT_WIDTH=0"
	
			if {[string compare -nocase $protocol "RLDRAMII"] == 0 && $dq_width_per_device == 36} {
				alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE=true"
				alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE_RESET=false"
				alt_mem_if::util::list_array::update_or_append param_list "DIFFERENTIAL_OUTPUT_STROBE=true"
			} else {
				alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE=false"
				alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE_RESET=false"
				alt_mem_if::util::list_array::update_or_append param_list "DIFFERENTIAL_OUTPUT_STROBE=false"
			}

			if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0 || [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
				alt_mem_if::util::list_array::update_or_append param_list "DQS_ENABLE_PHASE_SETTING=0"
			}
			
			set arg_list [list]
			foreach param $param_list {
				lappend arg_list "--component-param=$param"
			}

			set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=${prepend_str}altdqdqs_r" "--output-dir=$tmpdir" $system_info_param] $arg_list]
			_iprint "Generating ${prepend_str}altdqdqs_r" 1
			alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altdq_dqs2 $arg_list $tmpdir "generate_altdqdqs_r.tcl"

			if {[string compare -nocase "SIM_VHDL" $fileset] == 0} {
				lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_r.vhd]
			} else {
				lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_r.v]
			}

		}
	}

	if {[string compare -nocase $protocol "DDRIISRAM"] == 0} {

		set param_list $base_param_list

		alt_mem_if::util::list_array::update_or_append param_list "PIN_WIDTH=$read_dq_group_width"
		alt_mem_if::util::list_array::update_or_append param_list "PIN_TYPE=input"

		alt_mem_if::util::list_array::update_or_append param_list "EXTRA_OUTPUT_WIDTH=0"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_STROBE_RESET=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_TERMINATION_CONTROL=false"
		alt_mem_if::util::list_array::update_or_append param_list "USE_OUTPUT_PHASE_ALIGNMENT=false"
		alt_mem_if::util::list_array::update_or_append param_list "DIFFERENTIAL_OUTPUT_STROBE=false"
		
		set arg_list [list]
		foreach param $param_list {
			lappend arg_list "--component-param=$param"
		}

		set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=${prepend_str}altdqdqs_in" "--output-dir=$tmpdir" $system_info_param] $arg_list]
		_iprint "Generating ${prepend_str}altdqdqs_in" 1
		alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altdq_dqs2 $arg_list $tmpdir "generate_altdqdqs_in.tcl"

		if {[string compare -nocase "SIM_VHDL" $fileset] == 0} {
			lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_in.vhd]
		} else {
			lappend return_files [file join $tmpdir ${prepend_str}altdqdqs_in.v]
		}

	}
	
	return $return_files
}

proc ::alt_mem_if::gen::uniphy_gen::generate_altgpio {tmpdir fileset} {

	_dprint 1 "Generating altgpio"
	
	set return_files [list]

	set device_family [::alt_mem_if::gui::system_info::get_device_family]

	set system_info_param "--system-info=DEVICE_FAMILY=$device_family"

	set arg_list [list]

	set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=altgpio" "--output-dir=$tmpdir" $system_info_param] $arg_list]
	_iprint "Generating altgpio" 1

	alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altgpio_zb $arg_list $tmpdir "generate_altgpio.tcl"

	lappend return_files [file join $tmpdir altgpio_max10fpga.sv]

	return $return_files
}

proc ::alt_mem_if::gen::uniphy_gen::derive_delay_params {protocol} {

	set speed_grade [get_parameter_value SPEED_GRADE]
	if {[string compare -nocase $protocol "DDR2"] == 0 ||
		[string compare -nocase $protocol "DDR3"] == 0 ||
		[string compare -nocase $protocol "LPDDR2"] == 0 ||
		[string compare -nocase $protocol "LPDDR1"] == 0} {
		set is_ddrx_protocol 1
	} else {
		set is_ddrx_protocol 0
	}

	if {[string compare -nocase $protocol "LPDDR2"] == 0 ||
		[string compare -nocase $protocol "LPDDR1"] == 0} {
		set is_lpddrx_protocol 1
	} else {
		set is_lpddrx_protocol 0
	}

	set hps_mode [expr [string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0]
	
	if {$is_ddrx_protocol == 1} {
		if {[string compare -nocase $speed_grade "2X"] == 0} {
			set speed_grade 2
		}
	}

	set mem_clk_frequency [get_parameter_value MEM_CLK_FREQ]
	set mem_clk_period [ expr {1000000.0 / $mem_clk_frequency} ]
	set mem_clk_ps [ expr {round($mem_clk_period)} ]
	set speed_grade [get_parameter_value SPEED_GRADE]

	if {$is_ddrx_protocol == 1 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0} {
		if { $hps_mode } {
			if {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		} elseif {($is_lpddrx_protocol == 1)} {
			if {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		} else {
			if {$mem_clk_frequency < 250} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} elseif {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		}
	} elseif {$is_ddrx_protocol == 1 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {
		if { $hps_mode } {
			if {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		} elseif {($is_lpddrx_protocol == 1)} {
			if {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		} else {
			if {$mem_clk_frequency < 250} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} elseif {$mem_clk_frequency <= 400} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			} elseif {$mem_clk_frequency < 450} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
				set_parameter_value DQS_PHASE_SHIFT 0
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			}
		}
	}


	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		if {[string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true"] == 0} {
			if {[get_parameter_value MEM_CLK_FREQ] >= 233 || [string compare -nocase [get_parameter_value RATE] "full"] != 0} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
				set_parameter_value DQS_PHASE_SHIFT 13500
			} elseif {[get_parameter_value MEM_CLK_FREQ] >= 150} {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			} else {
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 1
				set_parameter_value DQS_PHASE_SHIFT 4500
			}
		} elseif {($is_ddrx_protocol == 1) && ($speed_grade >= 3) && ($mem_clk_ps >= 4484) } {
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
			set_parameter_value DQS_PHASE_SHIFT 0
		} elseif {($is_ddrx_protocol == 1) && ($speed_grade <= 2) && ($mem_clk_ps >= 4166)} {
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 0
			set_parameter_value DQS_PHASE_SHIFT 0
		} else {
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		set_parameter_value DELAY_CHAIN_LENGTH 8
	}

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] <= 740} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 6
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 12000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 560} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			if { $speed_grade == 2 } {
				set_parameter_value DELAY_CHAIN_LENGTH 8
				set_parameter_value DQS_PHASE_SHIFT 9000
			} else {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 12000
			}
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 ||
				[lsearch [split [get_parameters]] "FORCE_HCX_DLL_LENGTH"] != -1} {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 6000
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 1
			}
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 530} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			if { $speed_grade == 2 || $speed_grade == 3 } {
				set_parameter_value DELAY_CHAIN_LENGTH 8
				set_parameter_value DQS_PHASE_SHIFT 9000
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			} else {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 6000
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 1
			}
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 ||
				[lsearch [split [get_parameters]] "FORCE_HCX_DLL_LENGTH"] != -1} {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 6000
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 1
			}
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 460} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 8
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 420} {
			if {$is_ddrx_protocol == 1} {
				set_parameter_value DELAY_BUFFER_MODE HIGH
				set_parameter_value DELAY_CHAIN_LENGTH 8
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 9000
			} else {
				set_parameter_value DELAY_BUFFER_MODE HIGH
				set_parameter_value DELAY_CHAIN_LENGTH 10
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
				set_parameter_value DQS_PHASE_SHIFT 7200
			}
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 360} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 310} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 240} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 8
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 200} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 170} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 120} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 16
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 4
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
	}


	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] <= 740} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 6
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 12000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 540} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			if { $speed_grade == 2 } {
				set_parameter_value DELAY_CHAIN_LENGTH 8
				set_parameter_value DQS_PHASE_SHIFT 9000
			} else {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 12000
			}
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 ||
				[lsearch [split [get_parameters]] "FORCE_HCX_DLL_LENGTH"] != -1} {
				set_parameter_value DELAY_CHAIN_LENGTH 6
				set_parameter_value DQS_PHASE_SHIFT 6000
				set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 1
			}
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 450} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 8
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 360} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 290} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 240} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 8
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 200} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 160} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 120} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 16
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 4
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
	}

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] <= 410} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 270} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 220} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 8
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 180} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 10
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 2
			set_parameter_value DQS_PHASE_SHIFT 7200
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 150} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 12
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 3
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
		if {[get_parameter_value MEM_CLK_FREQ] <= 110} {
			set_parameter_value DELAY_BUFFER_MODE LOW
			set_parameter_value DELAY_CHAIN_LENGTH 16
			set_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING 4
			set_parameter_value DQS_PHASE_SHIFT 9000
		}
	}


	if {$is_ddrx_protocol == 1} {
		if {[get_parameter_value MEM_CLK_FREQ] <= 240} {
			set_parameter_value DELAY_BUFFER_MODE HIGH
		}
	}
	

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		set_parameter_value DELAY_CHAIN_LENGTH 8
		
		set dqs_out_reserve [expr floor(200000 / ([get_parameter_value MEM_CLK_FREQ] * 12.5))]
			
		set dqs_in_reserve [expr floor(50000 / ([get_parameter_value MEM_CLK_FREQ] * 12.5))]
		
		if {$dqs_out_reserve > 30} {
			set_parameter_value IO_DQS_OUT_RESERVE 30
		} else {
			set_parameter_value IO_DQS_OUT_RESERVE $dqs_out_reserve
		}
		if {$dqs_in_reserve > 15} {
			set_parameter_value IO_DQS_IN_RESERVE 15
		} else {
			set_parameter_value IO_DQS_IN_RESERVE $dqs_in_reserve
		}
		
		if {$is_ddrx_protocol == 1} {
			set_parameter_value IO_DQS_EN_PHASE_MAX 7
			set_parameter_value IO_DQDQS_OUT_PHASE_MAX 21
		} else {
			set_parameter_value IO_DQS_EN_PHASE_MAX 0
			set_parameter_value IO_DQDQS_OUT_PHASE_MAX 0
		}

	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		  [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {

		set_parameter_value DELAY_CHAIN_LENGTH 8
		
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 &&
			[string compare -nocase $protocol "DDR3"] == 0} {
			set_parameter_value IO_DQS_OUT_RESERVE 6
			set_parameter_value IO_DQS_IN_RESERVE 4
      } elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0 &&
			[string compare -nocase $protocol "DDR2"] == 0} {
			set_parameter_value IO_DQS_OUT_RESERVE 6
			set_parameter_value IO_DQS_IN_RESERVE 4
      } elseif {[string compare -nocase $protocol "QDRII"] == 0} {
			set_parameter_value IO_DQS_OUT_RESERVE 12
			set_parameter_value IO_DQS_IN_RESERVE 0
		} else {
			set_parameter_value IO_DQS_OUT_RESERVE 4
			set_parameter_value IO_DQS_IN_RESERVE 4
		}
		
		if {$is_ddrx_protocol == 1} {
			set_parameter_value IO_DQS_EN_PHASE_MAX 7
		} else {
			set_parameter_value IO_DQS_EN_PHASE_MAX 0
		}
		set_parameter_value IO_DQDQS_OUT_PHASE_MAX 0

	} else {
		if {$is_ddrx_protocol == 1} {
			if {[get_parameter_value DELAY_CHAIN_LENGTH] == 6} {
				set_parameter_value IO_DQS_OUT_RESERVE 5
				set_parameter_value IO_DQS_EN_PHASE_MAX 5
				set_parameter_value IO_DQDQS_OUT_PHASE_MAX 10
			} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 8} {
				set_parameter_value IO_DQS_OUT_RESERVE 3
				set_parameter_value IO_DQS_EN_PHASE_MAX 7
				set_parameter_value IO_DQDQS_OUT_PHASE_MAX 14
			} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 10} {
				set_parameter_value IO_DQS_OUT_RESERVE 3
				set_parameter_value IO_DQS_EN_PHASE_MAX 9
				set_parameter_value IO_DQDQS_OUT_PHASE_MAX 17
			} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 12} {
				set_parameter_value IO_DQS_OUT_RESERVE 6
				set_parameter_value IO_DQS_EN_PHASE_MAX 11
				set_parameter_value IO_DQDQS_OUT_PHASE_MAX 21
			} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 16} {
				set_parameter_value IO_DQS_OUT_RESERVE 3
				set_parameter_value IO_DQS_EN_PHASE_MAX 15
				set_parameter_value IO_DQDQS_OUT_PHASE_MAX 28
			}
		} else {
			if {[string compare -nocase $protocol "QDRII"] == 0} {
				set_parameter_value IO_DQS_OUT_RESERVE 4
			} else {
				set_parameter_value IO_DQS_OUT_RESERVE 3
			}
			set_parameter_value IO_DQDQS_OUT_PHASE_MAX 0
			set_parameter_value IO_DQS_EN_PHASE_MAX 0
		}
		
		if {[get_parameter_value DELAY_CHAIN_LENGTH] == 6} {
			set_parameter_value IO_DQS_IN_RESERVE 6
		} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 8} {
			set_parameter_value IO_DQS_IN_RESERVE 3
		} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 10} {
			set_parameter_value IO_DQS_IN_RESERVE 3
		} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 12} {
			set_parameter_value IO_DQS_IN_RESERVE 6
		} elseif {[get_parameter_value DELAY_CHAIN_LENGTH] == 16} {
			set_parameter_value IO_DQS_IN_RESERVE 3
		}
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {

		set io_out1_delay_max 63
		set freq [get_parameter_value MEM_CLK_FREQ]
		if {$freq > 800} {
			set period [expr 1000000.0 / $freq]
			set num_steps [expr ($period / 15.0) - 15] 
			if {$num_steps < $io_out1_delay_max} {
				set io_out1_delay_max $num_steps
			}
		}

		set_parameter_value DQS_EN_DELAY_MAX 127
		set_parameter_value DQS_IN_DELAY_MAX 63
		set_parameter_value IO_IN_DELAY_MAX 63
		set_parameter_value IO_OUT1_DELAY_MAX $io_out1_delay_max
		set_parameter_value IO_OUT2_DELAY_MAX 63
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		  [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] >= 450} {
			set_parameter_value DQS_EN_DELAY_MAX 15
		} else {
			set_parameter_value DQS_EN_DELAY_MAX 31
		}
		set_parameter_value DQS_IN_DELAY_MAX 31
		set_parameter_value IO_IN_DELAY_MAX 31
		set_parameter_value IO_OUT1_DELAY_MAX 31
		set_parameter_value IO_OUT2_DELAY_MAX 0	
	} else {
		set_parameter_value DQS_EN_DELAY_MAX 7
		set_parameter_value DQS_IN_DELAY_MAX 15
		set_parameter_value IO_IN_DELAY_MAX 15
		set_parameter_value IO_OUT1_DELAY_MAX 15
		set_parameter_value IO_OUT2_DELAY_MAX 7		
	}
	
	set_parameter_value IO_DQ_OUT_RESERVE 0
	set_parameter_value IO_DM_OUT_RESERVE 0

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		set_parameter_value IO_DQS_EN_DELAY_OFFSET 128
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		  [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] >= 450} {
			set_parameter_value IO_DQS_EN_DELAY_OFFSET 16
		} else {
			set_parameter_value IO_DQS_EN_DELAY_OFFSET 0
		}
	} else {
		set_parameter_value IO_DQS_EN_DELAY_OFFSET 0
	}

}


proc  ::alt_mem_if::gen::uniphy_gen::generate_parameters_txt_file { core_name protocol tmpdir } {

	set return_file_list [list]

	set params_file_name [file join $tmpdir "${core_name}parameters.txt"]

	set FH [open $params_file_name w]
	_dprint 1 "Writing parameters to $params_file_name"
	puts $FH "HPS_PROTOCOL : [string toupper $protocol]"
	foreach param_name [get_parameters] {
		puts $FH "$param_name : [get_parameter_value $param_name]"
	}
	close $FH
	lappend return_file_list $params_file_name

	return $return_file_list

}


proc  ::alt_mem_if::gen::uniphy_gen::generate_sdc_file { core_name protocol intcl_dir tmpdir } {

	set file_list "memphy.sdc"

	set core_params [ list "IPTCL_FAKE" ]

	if { [ string compare $protocol "QDRII" ] == 0 } {
		set read_latency [get_parameter_value MEM_T_RL]
		if { $read_latency == 2 } {
			lappend core_params "IPTCL_RL2"
		}
	}

	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_FULL_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
		lappend core_params "IPTCL_HALF_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0 } {
		lappend core_params "IPTCL_QUARTER_RATE"
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		lappend core_params "IPTCL_NIOS_SEQUENCER"
	}

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			lappend core_params "IPTCL_AC_PARITY"
		}
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "HARDCOPYIII"] == 0} {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH"
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
		lappend core_params "IPTCL_PRINT_MACRO_TIMING"
	} else {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
	}

	if { [ string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0 } {
		lappend core_params "IPTCL_MEM_LEVELING"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV" ] == 0 } {
		if { [ string compare -nocase $protocol "QDRII" ] == 0 } {
			lappend core_params "IPTCL_REMOVE_WRITE_PESSIMISM"
		}
	}

	if { [get_parameter_value MEM_BURST_LENGTH] == 2 } {
		lappend core_params "IPTCL_BURST_2"
	}

	lappend core_params "USE_ALTDQ_DQS2"

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
		if {[string compare -nocase [get_parameter_value VFIFO_AS_SHIFT_REG] "true"] == 0} {
			lappend core_params "IPTCL_VFIFO_AS_SHIFT_REG"
		}
		if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
			lappend core_params "IPTCL_NEXTGEN"
	}
	}

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		lappend core_params "IPTCL_USE_HARD_READ_FIFO"
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 || [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0} {
			lappend core_params "IPTCL_USE_IO_CLOCK_DIVIDER"
		}
	} else {
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
			lappend core_params "IPTCL_READ_FIFO_HALF_RATE"
		}
	}
	
	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0} {
		lappend core_params "IPTCL_STRATIXV"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_ARRIAVGZ"
	}
	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV" ] == 0} {
		lappend core_params "IPTCL_ARRIAV"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV" ] == 0} {
		lappend core_params "IPTCL_CYCLONEV"
	}

	if { [ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_CORE_PERIPHERY_DUAL_CLOCK"
	}

	if { [ string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_FOR_ADDR_CMD"

		if { [ string compare -nocase [get_parameter_value ENABLE_LDC_MEM_CK_ADJUSTMENT] "true" ] == 0} {
			lappend core_params "IPTCL_ENABLE_LDC_MEM_CK_ADJUSTMENT"
			if { [ string compare -nocase [get_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT] "true" ] == 0} {
				lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
			}
		} else {
			lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
		}
	}

	if { [string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0} {
		if { [ string compare -nocase [get_parameter_value NON_LDC_ADDR_CMD_MEM_CK_INVERT] "true" ] == 0} {
			lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
		}
	}
	
	if { [ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_DR_CLK"
	}
	
	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
		lappend core_params "IPTCL_USE_2X_FF"
	}

	if { [ string compare -nocase [get_parameter_value PHY_CLKBUF] "true" ] == 0} {
		lappend core_params "IPTCL_PHY_CLKBUF"
	}
	
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend core_params "IPTCL_USE_SHADOW_REGS"
	}

	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		lappend core_params "HCX_COMPAT_MODE"
	}
	
	if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
		lappend core_params "IPTCL_MEM_IF_DQSN_EN"
	}	

	if {[string compare -nocase [get_parameter_value PHY_CSR_ENABLED] "true"] == 0} {
		lappend core_params "IPTCL_PHY_CSR_ENABLED"
	}
    if {[string compare -nocase [get_parameter_value EXPORT_AFI_HALF_CLK] "true"] == 0} {
		lappend core_params "IPTCL_EXPORT_AFI_HALF_CLK"
	}
	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		lappend core_params "IPTCL_DUAL_WRITE_CLOCK"
	}
	
	set device_family [::alt_mem_if::gui::system_info::get_device_family]
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		lappend core_params "IPTCL_MAKE_FIFOS_IN_ALTDQDQS"
		lappend core_params "IPTCL_ACV_FAMILY"
	}

	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend core_params "IPTCL_HARD_PHY"
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		lappend core_params "IPTCL_HHP_HPS"
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		lappend core_params "IPTCL_USE_DQS_TRACKING"
	}
	
	if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
		lappend core_params "IPTCL_PHY_ONLY"
}

	return [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $intcl_dir $tmpdir [list $file_list] $core_params]


}


proc ::alt_mem_if::gen::uniphy_gen::generate_timing_file { core_name intcl_dir tmpdir } {

	set file_list "memphy_timing.tcl"

	set core_params [ list "IPTCL_FAKE" ]

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0} {
		lappend core_params "IPTCL_STRATIXV"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_ARRIAVGZ"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_FULL_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
		lappend core_params "IPTCL_HALF_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0 } {
		lappend core_params "IPTCL_QUARTER_RATE"
	}

	set parsed_file_list [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $intcl_dir $tmpdir [list $file_list] $core_params]
	
	foreach pfile $parsed_file_list {
		alt_mem_if::util::iptclgen::sub_strings_params $pfile $pfile

		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "HARDCOPYIII"] == 0} {
	
			set FH [open $pfile a]
			puts $FH ""
			puts $FH "# Global variable to switch between MACRO/Micro models"
			puts $FH "# The value of this variable should NOT be modified unless"
			puts $FH "# the user is sure about the implications of this choice"
			if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII" ] == 0 } {
				puts $FH "set ::GLOBAL_${core_name}_phy_use_micro_timing 0"
				puts $FH "if \{ \[ string match -nocase \"HARDCOPY III*\" \[ get_family_string \] \] \} \{"
				puts $FH "\t# HardCopy IV only supports the micro timing model"
				puts $FH "\tset ::GLOBAL_${core_name}_phy_use_micro_timing 1"
				puts $FH "\}"
			} else {
				puts $FH "set ::GLOBAL_${core_name}_phy_use_micro_timing 1"
				puts $FH "if \{ \[ string match -nocase \"STRATIX III*\" \[ get_family_string \] \] \} \{"
				puts $FH "\t# Stratix IV only supports the high performance timing model"
				puts $FH "\tset ::GLOBAL_${core_name}_phy_use_micro_timing 0"
				puts $FH "\}"
			}
			close $FH
		}
	}
	
	return $parsed_file_list
}

proc ::alt_mem_if::gen::uniphy_gen::generate_report_timing_files { core_name protocol intcl_dir tmpdir } {

	set file_list [list "memphy_report_timing.tcl" "memphy_report_timing_core.tcl"]


	set core_params [ list "IPTCL_FAKE" ]

	if { [ string compare $protocol "QDRII" ] == 0 } {
		set read_latency [get_parameter_value MEM_T_RL]
		if { $read_latency == 2 } {
			lappend core_params "IPTCL_RL2"
		}

		if { [string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0 } {
			lappend core_params "IPTCL_EMULATED_MODE"
		}
	}

	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_FULL_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
		lappend core_params "IPTCL_HALF_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0 } {
		lappend core_params "IPTCL_QUARTER_RATE"
	}

	if {[ string compare -nocase [get_parameter_value ENABLE_EXTRA_REPORTING] "true"] == 0} {
		lappend core_params "IPTCL_ENABLE_EXTRA_REPORTING"
	}
	
	if {[ string compare -nocase [get_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS] "-1"] == 0} {
		lappend core_params "IPTCL_NUM_WRITE_FR_CYCLE_SHIFTS"
	}

	lappend core_params "IPTCL_[string toupper [::alt_mem_if::gui::system_info::get_device_family]]"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "HARDCOPYIII"] == 0} {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH"
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
		lappend core_params "IPTCL_PRINT_MACRO_TIMING"
	} else {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
	}

	lappend core_params "USE_ALTDQ_DQS2"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		lappend core_params "IPTCL_USE_HARD_READ_FIFO"
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 || [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0} {
			lappend core_params "IPTCL_USE_IO_CLOCK_DIVIDER"
		}
	} else {
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
			lappend core_params "IPTCL_READ_FIFO_HALF_RATE"
		}
	}
	
	set device_family [::alt_mem_if::gui::system_info::get_device_family]
	if { [ string compare -nocase $device_family "STRATIXV" ] == 0} {
		lappend core_params "IPTCL_STRATIXV"
	}

	if { [ string compare -nocase $device_family "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_ARRIAVGZ"
	}
	
	if {[string compare -nocase $device_family "ARRIAV"] == 0 || [string compare -nocase $device_family "CYCLONEV"] == 0} {
		lappend core_params "IPTCL_MAKE_FIFOS_IN_ALTDQDQS"
		lappend core_params "IPTCL_ACV_FAMILY"
	}

	if { [ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_CORE_PERIPHERY_DUAL_CLOCK"
	}

	if { [ string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_FOR_ADDR_CMD"
	}
		
	if { [ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_DR_CLK"
	}
	
	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
		lappend core_params "IPTCL_USE_2X_FF"
	}	
	
	if { [ string compare -nocase [get_parameter_value PHY_CLKBUF] "true" ] == 0} {
		lappend core_params "IPTCL_PHY_CLKBUF"
	}
	
	if { [string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0 } {
		lappend core_params "IPTCL_MEM_LEVELING"
	}

	if {[string compare -nocase [get_parameter_value PACKAGE_DESKEW] "true"] == 0} {
		lappend core_params "IPTCL_PACKAGE_DESKEW"
	}
	
	if {[string compare -nocase [get_parameter_value AC_PACKAGE_DESKEW] "true"] == 0} {
		lappend core_params "IPTCL_AC_PACKAGE_DESKEW"
	}

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
		lappend core_params "IPTCL_PHY_ONLY"
	}

	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		lappend core_params "IPTCL_DUAL_WRITE_CLOCK"
	}
	
	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend core_params "IPTCL_HARD_PHY"
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		lappend core_params "IPTCL_HHP_HPS"
	}

	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0} {
		lappend core_params "IPTCL_PLL_SHARING"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_FOR_ADDR_CMD"

		if { [ string compare -nocase [get_parameter_value ENABLE_LDC_MEM_CK_ADJUSTMENT] "true" ] == 0} {
			lappend core_params "IPTCL_ENABLE_LDC_MEM_CK_ADJUSTMENT"
			if { [ string compare -nocase [get_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT] "true" ] == 0} {
				lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
			}
		} else {
			lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
		}
	}

	if { [string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0} {
		if { [ string compare -nocase [get_parameter_value NON_LDC_ADDR_CMD_MEM_CK_INVERT] "true" ] == 0} {
			lappend core_params "IPTCL_ADDR_CMD_MEM_CK_INVERT"
		}
	}

	return [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $intcl_dir $tmpdir $file_list $core_params]
	
}

proc ::alt_mem_if::gen::uniphy_gen::generate_pin_map_file { core_name protocol common_file protocol_file tmpdir } {

	set file_list "memphy_pin_map.tcl"

	set core_params [ list "IPTCL_FAKE" ]
	
	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_FULL_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
		lappend core_params "IPTCL_HALF_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0 } {
		lappend core_params "IPTCL_QUARTER_RATE"
	}

	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_NO_DQ_DQS_BLOCK"
	}
	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX" ] == 0 } {
		lappend core_params "IPTCL_NO_DQ_DQS_BLOCK"
	}

	if { [ string compare $protocol "QDRII" ] == 0 } {
		set read_latency [get_parameter_value MEM_T_RL]
		if { $read_latency == 2 } {
			lappend core_params "IPTCL_RL2"
		}

		if { [string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0 } {
			lappend core_params "IPTCL_EMULATED_MODE"
		}
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		lappend core_params "IPTCL_NIOS_SEQUENCER"
	}

	if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
		lappend core_params "IPTCL_MEM_IF_DQSN_EN"
	}
	
	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		lappend core_params "IPTCL_MEM_IF_DM_PINS_EN"
	}

	if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
		lappend core_params "IPTCL_MEM_LEVELING"
	}

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			lappend core_params "IPTCL_AC_PARITY"
		}
	}
	
	lappend core_params "USE_ALTDQ_DQS2"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		lappend core_params "IPTCL_USE_HARD_READ_FIFO"
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 || [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0} {
			lappend core_params "IPTCL_USE_IO_CLOCK_DIVIDER"
		}
	} else {
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
			lappend core_params "IPTCL_READ_FIFO_HALF_RATE"
		}
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		lappend core_params "IPTCL_MAKE_FIFOS_IN_ALTDQDQS"
		lappend core_params "IPTCL_SINGLE_CAPTURE_STROBE"
		lappend core_params "IPTCL_ACV_FAMILY"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0} {
		lappend core_params "IPTCL_STRATIXV"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_ARRIAVGZ"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0 ||
		[ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV" ] == 0 ||
		[ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV" ] == 0 ||
		[ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_FRACTIONAL_PLL"
	}
	
	if { [ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_CORE_PERIPHERY_DUAL_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_FOR_ADDR_CMD"
	}
		
	if { [ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_DR_CLK"
	}
	
	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
		lappend core_params "IPTCL_USE_2X_FF"
	}
	
	if { [ string compare -nocase [get_parameter_value PHY_CLKBUF] "true" ] == 0} {
		lappend core_params "IPTCL_PHY_CLKBUF"
	}
	
	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		lappend core_params "IPTCL_DUAL_WRITE_CLOCK"
	}
    if {[string compare -nocase [get_parameter_value EXPORT_AFI_HALF_CLK] "true"] == 0} {
		lappend core_params "IPTCL_EXPORT_AFI_HALF_CLK"
	}	
	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		lappend core_params "IPTCL_NIOS_SEQUENCER"
		if {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
			if {[string compare -nocase [get_parameter_value RESERVED_PINS_FOR_DK_GROUP] "true"] == 0} {
				lappend core_params "IPTCL_RESERVED_PINS_FOR_DK_GROUP"
			}
		}
	}
	
	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend core_params "IPTCL_HARD_PHY"
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		lappend core_params "IPTCL_HHP_HPS"
	}

	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		lappend core_params "IPTCL_USE_DQS_TRACKING"
	}

	set common_file_fh [open $common_file r]
	set protocol_file_fh [open $protocol_file r]
	set dest_file_fh [open [file join $tmpdir $file_list] w]
	
	while {[gets $common_file_fh line] != -1} {
		puts $dest_file_fh $line
	}
	while {[gets $protocol_file_fh line] != -1} {
		puts $dest_file_fh $line
	}
	
	
	close $common_file_fh
	close $protocol_file_fh
	close $dest_file_fh
	
	return [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $tmpdir $tmpdir [list $file_list] $core_params]
}

proc ::alt_mem_if::gen::uniphy_gen::generate_fake_pin_assignments_file { core_name protocol intcl_dir tmpdir } {

	set base_file_name "${core_name}_pin_assignments.tcl"
	set file_name [file join $tmpdir $base_file_name]
	set FH [open "$file_name" w]

	puts $FH "# This file is intentionally empty"

	close $FH
	return [list $file_name]


}

proc ::alt_mem_if::gen::uniphy_gen::generate_pin_assignments_qip {protocol} {

    for {set i 0} {$i < [get_parameter_value MEM_IF_DQ_WIDTH] } {incr i} {
		set dq_pin "mem_dq\[$i\]"
		_iprint "Assing assignment: set_instance_assignment -name IO_STANDARD \"[get_parameter_value IO_STANDARD] CLASS I\" -to $dq_pin -entity %entityName%"
		set_qip_strings "set_instance_assignment -name IO_STANDARD \"[get_parameter_value IO_STANDARD] CLASS I\" -to $dq_pin -entity %entityName%"
	}
}

proc ::alt_mem_if::gen::uniphy_gen::generate_pin_assignments_file { core_name protocol intcl_dir tmpdir } {

	set file_list "memphy_pin_assignments.tcl"

	set core_params [ list "IPTCL_FAKE" ]

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX" ] == 0 } {
		lappend core_params "IPTCL_NO_PARALLEL_TERMINATION"
	}

	if { [ string compare $protocol "LPDDR2" ] == 0 } {
		lappend core_params "IPTCL_NO_PARALLEL_TERMINATION"
	}

	if { [ string compare $protocol "QDRII" ] == 0 } {
		set read_latency [get_parameter_value MEM_T_RL]
		if { $read_latency == 2 } {
			lappend core_params "IPTCL_RL2"
		}

		if { [string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0 } {
			lappend core_params "IPTCL_EMULATED_MODE"
		}

	}

	if { [ string compare -nocase [get_parameter_value RATE] "FULL" ] == 0 } {
		lappend core_params "IPTCL_FULL_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
		lappend core_params "IPTCL_HALF_RATE"
	} elseif { [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0 } {
		lappend core_params "IPTCL_QUARTER_RATE"
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		lappend core_params "IPTCL_NIOS_SEQUENCER"
		if {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
			if {[string compare -nocase [get_parameter_value RESERVED_PINS_FOR_DK_GROUP] "true"] == 0} {
				lappend core_params "IPTCL_RESERVED_PINS_FOR_DK_GROUP"
			}
		}
	}	


	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "HARDCOPYIII"] == 0} {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_MACRO_SWITCH"
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
		lappend core_params "IPTCL_PRINT_MACRO_TIMING"
	} else {
		lappend core_params "IPTCL_PRINT_FLEXIBLE_TIMING"
	}



	lappend core_params "USE_ALTDQ_DQS2"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		lappend core_params "IPTCL_USE_HARD_READ_FIFO"
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 || [ string compare -nocase [get_parameter_value RATE] "QUARTER" ] == 0} {
			lappend core_params "IPTCL_USE_IO_CLOCK_DIVIDER"
		}
	} else {
		if { [ string compare -nocase [get_parameter_value RATE] "HALF" ] == 0 } {
			lappend core_params "IPTCL_READ_FIFO_HALF_RATE"
		}
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0} {
		lappend core_params "IPTCL_STRATIXV"
	}

	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		lappend core_params "IPTCL_ARRIAVGZ"
	}

	if { [ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_CORE_PERIPHERY_DUAL_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_AS_LOW_SKEW_CLOCK"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		lappend core_params "IPTCL_USE_LDC_FOR_ADDR_CMD"
	}
	
	if { [ string compare -nocase [get_parameter_value USE_DR_CLK] "true" ] == 0} {
		lappend core_params "IPTCL_USE_DR_CLK"
	}
	
	if {[string compare -nocase [get_parameter_value USE_2X_FF] "true"] == 0} {
		lappend core_params "IPTCL_USE_2X_FF"
	}	
	
	if { [ string compare -nocase [get_parameter_value PHY_CLKBUF] "true" ] == 0} {
		lappend core_params "IPTCL_PHY_CLKBUF"
	}

	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0} {
		lappend core_params "IPTCL_PLL_SHARING"
	}

	if { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] != 0} {
		lappend core_params "IPTCL_OCT_MASTER"
	}

	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		lappend core_params "HCX_COMPAT_MODE"
	}

	if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
		lappend core_params "IPTCL_MEM_LEVELING"
	}
	
	if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
		lappend core_params "IPTCL_MEM_IF_DQSN_EN"
	}
	
	if {[string compare -nocase [get_parameter_value PACKAGE_DESKEW] "true"] == 0} {
		lappend core_params "IPTCL_PACKAGE_DESKEW"
	}

	if {[string compare -nocase [get_parameter_value AC_PACKAGE_DESKEW] "true"] == 0} {
		lappend core_params "IPTCL_AC_PACKAGE_DESKEW"
	}	

	if {[string compare -nocase [get_parameter_value DUAL_WRITE_CLOCK] "true"] == 0} {
		lappend core_params "IPTCL_DUAL_WRITE_CLOCK"
	}                              
	
	if {[string compare -nocase [get_parameter_value PHY_CSR_ENABLED] "true"] == 0} {
		lappend core_params "IPTCL_PHY_CSR_ENABLED"
	}

	if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		lappend core_params "IPTCL_HARD_PHY"
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		lappend core_params "IPTCL_HHP_HPS"
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {
		lappend core_params "IPTCL_SKIP_DQ_GROUP_ASSIGNMENTS"
		lappend core_params "IPTCL_SINGLE_CAPTURE_STROBE"
	}

	if {[string compare -nocase $protocol "QDRII"] == 0 || [string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
			lappend core_params "IPTCL_SKIP_DQ_GROUP_ASSIGNMENTS"
		}
	}

	if {[string compare -nocase $protocol "QDRII"] == 0} {
		if { [get_parameter_value MEM_BURST_LENGTH] == 2 } {
			lappend core_params "IPTCL_BURST_2"
		}
	}


	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0} {
		if {[string compare -nocase $protocol "QDRII"] == 0} {
			set dq_width_per_device [ expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value DEVICE_WIDTH]} ]
			if {$dq_width_per_device == 36} {
				lappend core_params "IPTCL_AIIGZ_QDRII_x36"
			}
		}
	}
	
	set parsed_file_list [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $intcl_dir $tmpdir [list $file_list] $core_params]
	
	foreach pfile $parsed_file_list {
		alt_mem_if::util::iptclgen::sub_strings_params $pfile $pfile
	}
	
	return $parsed_file_list
	
}

proc ::alt_mem_if::gen::uniphy_gen::generate_parameters_file { core_name protocol intcl_dir tmpdir } {

	set file_name [file join $tmpdir ${core_name}_parameters.tcl]

	set FH [open "$file_name" w]

	puts $FH "#"
	puts $FH "# AUTO-GENERATED FILE: Do not edit ! ! ! "
	puts $FH "#"
	puts $FH ""
	puts $FH "set ::GLOBAL_${core_name}_corename \"${core_name}\""


	puts $FH "set ::GLOBAL_${core_name}_io_standard \"[get_parameter_value IO_STANDARD]\""
	set io_standard_differential ""
	if { [ string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15" ] == 0 } {
		set io_standard_differential "1.5-V SSTL"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-18" ] == 0 } {
		set io_standard_differential "1.8-V SSTL"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135" ] == 0 } {
		set io_standard_differential "1.35-V SSTL"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSUL" ] == 0 } {
		set io_standard_differential "1.2-V HSUL"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-12" ] == 0 } {
		set io_standard_differential "1.2-V SSTL"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSTL Class I" ] == 0 } {
		set io_standard_differential "1.2-V HSTL Class I"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSTL Class II" ] == 0 } {
		set io_standard_differential "1.2-V HSTL Class II"
	}
	
	set io_standard_cmos ""
	if { [ string compare [get_parameter_value IO_STANDARD] "SSTL-15" ] == 0 } {
		set io_standard_cmos "1.5V"
	} elseif { [ string compare [get_parameter_value IO_STANDARD] "SSTL-18" ] == 0 } {
		set io_standard_cmos "1.8V"
	} elseif { [ string compare [get_parameter_value IO_STANDARD] "SSTL-135" ] == 0 } {
		set io_standard_cmos "1.35V"
	} elseif { [ string compare [get_parameter_value IO_STANDARD] "1.2-V HSUL" ] == 0 } {
		set io_standard_cmos "1.2V"
	} elseif { [ string compare [get_parameter_value IO_STANDARD] "SSTL-12" ] == 0 } {
		set io_standard_cmos "1.2V"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSTL Class I" ] == 0 } {
		set io_standard_cmos "1.2V"
	} elseif { [ string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSTL Class II" ] == 0 } {
		set io_standard_cmos "1.2V"
	}
	
	puts $FH "set ::GLOBAL_${core_name}_io_interface_type \"HPAD\""
	if { [ string compare $protocol "RLDRAMII" ] == 0 || [ string compare $protocol "RLDRAM3" ] == 0} {
		if { [ string compare $protocol "RLDRAM3" ] == 0} {
			puts $FH "set ::GLOBAL_${core_name}_io_standard_cmos \"$io_standard_cmos\""
			puts $FH "set ::GLOBAL_${core_name}_io_standard_differential \"$io_standard_differential\""
		}
		puts $FH "set ::GLOBAL_${core_name}_device_width [get_parameter_value DEVICE_WIDTH]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_d_groups [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_q_groups [get_parameter_value MEM_IF_READ_DQS_WIDTH]"
		set dq_group_size [ expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]} ]
		set d_group_size [ expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]} ]
		puts $FH "set ::GLOBAL_${core_name}_dq_group_size $dq_group_size"
		puts $FH "set ::GLOBAL_${core_name}_d_group_size $d_group_size"
		if { [ string compare [get_parameter_value MEM_IF_DM_PINS_EN] "true" ] == 0} {
		puts $FH "set ::GLOBAL_${core_name}_number_of_dm_pins [get_parameter_value MEM_IF_DM_WIDTH]"
		} else {
			puts $FH "set ::GLOBAL_${core_name}_number_of_dm_pins 0"
		}
	} elseif { [ string compare $protocol "QDRII" ] == 0 } {
		puts $FH "set ::GLOBAL_${core_name}_device_width [get_parameter_value DEVICE_WIDTH]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_d_groups [get_parameter_value MEM_IF_WRITE_GROUPS]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_q_groups [get_parameter_value MEM_IF_READ_DQS_WIDTH]"
		set write_group_size [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_WRITE_GROUPS]}]
		puts $FH "set ::GLOBAL_${core_name}_d_group_size $write_group_size"
		set dq_per_dqs [expr { [get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH] } ]
		puts $FH "set ::GLOBAL_${core_name}_q_group_size $dq_per_dqs"
		puts $FH "set ::GLOBAL_${core_name}_number_of_k_pins [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]"
	} elseif { [ string compare $protocol "DDRIISRAM" ] == 0 } {
	} elseif { [ string compare $protocol "DDR2" ] == 0 || [ string compare $protocol "LPDDR2" ] == 0 || [ string compare $protocol "LPDDR1" ] == 0 } {
		puts $FH "set ::GLOBAL_${core_name}_io_standard_differential \"$io_standard_differential\""
		puts $FH "set ::GLOBAL_${core_name}_number_of_dqs_groups [get_parameter_value MEM_IF_DQS_WIDTH]"
		set dqs_group_size [ expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_DQS_WIDTH]} ]
		puts $FH "set ::GLOBAL_${core_name}_dqs_group_size $dqs_group_size"
		puts $FH "set ::GLOBAL_${core_name}_number_of_ck_pins [get_parameter_value MEM_IF_CK_WIDTH]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_dm_pins [get_parameter_value MEM_IF_DM_WIDTH]"
	} elseif { [ string compare $protocol "DDR3" ] == 0 } {
		puts $FH "set ::GLOBAL_${core_name}_io_standard_differential \"$io_standard_differential\""
		puts $FH "set ::GLOBAL_${core_name}_io_standard_cmos \"$io_standard_cmos\""
		puts $FH "set ::GLOBAL_${core_name}_number_of_dqs_groups [get_parameter_value MEM_IF_DQS_WIDTH]"
		set dqs_group_size [ expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_DQS_WIDTH]} ]
		puts $FH "set ::GLOBAL_${core_name}_dqs_group_size $dqs_group_size"
		puts $FH "set ::GLOBAL_${core_name}_number_of_ck_pins [get_parameter_value MEM_IF_CK_WIDTH]"
		puts $FH "set ::GLOBAL_${core_name}_number_of_dm_pins [get_parameter_value MEM_IF_DM_WIDTH]"
	} else {
		_error "Unknown protocol: $protocol"
	} 

	puts $FH "set ::GLOBAL_${core_name}_dqs_delay_chain_length [get_parameter_value DQS_DELAY_CHAIN_PHASE_SETTING]"

	set uniphy_temp_ver_code [alt_mem_if::util::iptclgen::compute_temp_ver_code [::alt_mem_if::gui::system_info::get_device_family]]
	puts $FH "set ::GLOBAL_${core_name}_uniphy_temp_ver_code $uniphy_temp_ver_code"


	set pll_clocks_list [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]
	set number_of_clocks [ llength $pll_clocks_list ]
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || 
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set number_of_clocks [expr {$number_of_clocks - 1}]
	}
	puts $FH "# PLL Parameters"
	puts $FH ""
	puts $FH "#USER W A R N I N G !"
	puts $FH "#USER The PLL parameters are statically defined in this"
	puts $FH "#USER file at generation time!"
	puts $FH "#USER To ensure timing constraints and timing reports are correct, when you make "
	puts $FH "#USER any changes to the PLL component using the MegaWizard Plug-In,"
	puts $FH "#USER apply those changes to the PLL parameters in this file"
	puts $FH ""
	puts $FH "set ::GLOBAL_${core_name}_num_pll_clock $number_of_clocks"
	for { set i 0 } { $i < $number_of_clocks } { incr i } {
		set clk_name [lindex $pll_clocks_list $i]
		set clk_mult [get_parameter_value "${clk_name}_MULT"]
		set clk_div [get_parameter_value "${clk_name}_DIV"]
		set clk_phase [get_parameter_value "${clk_name}_PHASE_DEG"]

		puts $FH "set ::GLOBAL_${core_name}_pll_mult(${i}) $clk_mult"
		puts $FH "set ::GLOBAL_${core_name}_pll_div(${i}) $clk_div"
		puts $FH "set ::GLOBAL_${core_name}_pll_phase(${i}) $clk_phase"
		
		puts $FH "set ::GLOBAL_${core_name}_pll_mult(${clk_name}) $clk_mult"
		puts $FH "set ::GLOBAL_${core_name}_pll_div(${clk_name}) $clk_div"
		puts $FH "set ::GLOBAL_${core_name}_pll_phase(${clk_name}) $clk_phase"		
	}

	if {[string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true"] == 0} {
	} else {
		set dll_clock_factor 1.0
		set leveling_capture_phase_taps 2.0
	set leveling_capture_phase [ expr {$leveling_capture_phase_taps / $dll_clock_factor / [get_parameter_value DELAY_CHAIN_LENGTH] * 360.0} ]
	puts $FH ""
	puts $FH "set ::GLOBAL_${core_name}_leveling_capture_phase $leveling_capture_phase"
	puts $FH ""
	}

	puts $FH "##############################################################"
	puts $FH "## IP options"
	puts $FH "##############################################################"
	puts $FH ""
	puts $FH "set IP(write_dcc) \"static\""
	puts $FH "set IP(write_deskew_range) [get_parameter_value IO_OUT1_DELAY_MAX]"
	puts $FH "set IP(read_deskew_range) [get_parameter_value IO_IN_DELAY_MAX]"
	puts $FH "set IP(write_deskew_range_setup) [get_parameter_value IO_DQS_OUT_RESERVE]"
	puts $FH "set IP(write_deskew_range_hold) [get_parameter_value IO_OUT1_DELAY_MAX]"
	puts $FH "set IP(read_deskew_range_setup) [get_parameter_value IO_IN_DELAY_MAX]"
	puts $FH "set IP(read_deskew_range_hold) [get_parameter_value IO_IN_DELAY_MAX]"
	
	if { [ string compare $protocol "RLDRAMII" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"rldram2\""
	} elseif { [ string compare $protocol "RLDRAM3" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"rldram3\""
	} elseif { [ string compare $protocol "QDRII" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"qdr2\""
	} elseif { [ string compare $protocol "DDRIISRAM" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"ddrii\""
	} elseif { [ string compare $protocol "DDR2" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"ddr2\""
	} elseif { [ string compare $protocol "DDR3" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"ddr3\""
	} elseif { [ string compare $protocol "LPDDR2" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"lpddr2\""
	} elseif { [ string compare $protocol "LPDDR1" ] == 0 } {
		puts $FH "set IP(mem_if_memtype) \"lpddr1\""
	} else {
		_error "Unknown protocol: $protocol"
	}

	if { [ string compare $protocol "DDR2" ] == 0 || [ string compare $protocol "DDR3" ] == 0 } {
		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
			puts $FH "set IP(RDIMM) 1"
		} else {
			puts $FH "set IP(RDIMM) 0"
		}
	} elseif { [ string compare $protocol "LPDDR2" ] == 0 || [ string compare $protocol "LPDDR1" ] == 0 } {
		puts $FH "set IP(RDIMM) 0"
	}

	if { [ string compare $protocol "DDR3" ] == 0 } {
		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
			puts $FH "set IP(LRDIMM) 1"
		} else {
			puts $FH "set IP(LRDIMM) 0"
		}
	} else {
		puts $FH "set IP(LRDIMM) 0"
	}

	if { [ string compare $protocol "DDR2" ] == 0 || [ string compare $protocol "DDR3" ] == 0 || [ string compare $protocol "LPDDR2" ] == 0 || [ string compare $protocol "LPDDR1" ] == 0 } {
		puts $FH "set IP(mp_calibration) 1"
	} else {
		puts $FH "set IP(mp_calibration) 1"
	}


	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII" ] == 0 } {
		puts $FH "set IP(quantization_T9) 0.050"
		puts $FH "set IP(quantization_T1) 0.050"
		puts $FH "set IP(quantization_DCC) 0.050"
		puts $FH "set IP(quantization_T7) 0.050"
		puts $FH "set IP(quantization_WL) 0.050"
		puts $FH "set IP(eol_reduction_factor_addr) 1.0"
		puts $FH "set IP(eol_reduction_factor_read) 1.0"
		puts $FH "set IP(eol_reduction_factor_write) 1.0"
	} elseif { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV" ] == 0 } {
		puts $FH "set IP(quantization_T9) 0.050"
		puts $FH "set IP(quantization_T1) 0.050"
		puts $FH "set IP(quantization_DCC) 0.050"
		puts $FH "set IP(quantization_T7) 0.050"
		puts $FH "set IP(quantization_WL) 0.050"
		puts $FH "set IP(eol_reduction_factor_addr) 1.0"
		puts $FH "set IP(eol_reduction_factor_read) 1.0"
		puts $FH "set IP(eol_reduction_factor_write) 1.0"
	} elseif { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0 ||
		   [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
		puts $FH "set IP(quantization_T9) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_T1) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_DCC) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_T7) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_WL) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_T11) [expr [get_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP]/1000.0]"
		
		puts $FH "set IP(eol_reduction_factor_addr) 2.0"
		
		puts $FH "set IP(eol_reduction_factor_read) 2.1"
		
		puts $FH "set IP(eol_reduction_factor_write) 2.35"
	} elseif { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV" ] == 0 ||
	           [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV" ] == 0} {
		puts $FH "set IP(quantization_T9) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_T1) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_DCC) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_T7) [expr [get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0]"
		puts $FH "set IP(quantization_WL) [expr {0.5*[get_parameter_value DELAY_PER_DCHAIN_TAP]/1000.0}]"
		puts $FH "set IP(quantization_T11) [expr [get_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP]/1000.0]"
		
		puts $FH "set IP(eol_reduction_factor_addr) 2.0"
		
		puts $FH "set IP(eol_reduction_factor_read) 2.1"
		
		puts $FH "set IP(eol_reduction_factor_write) 2.35"
	} elseif { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ" ] == 0 } {
		puts $FH "set IP(quantization_T9) 0.050"
		puts $FH "set IP(quantization_T1) 0.050"
		puts $FH "set IP(quantization_DCC) 0.050"
		puts $FH "set IP(quantization_T7) 0.050"
		puts $FH "set IP(quantization_WL) 0.050"
		puts $FH "set IP(eol_reduction_factor_addr) 1.0"
		puts $FH "set IP(eol_reduction_factor_read) 1.0"
		puts $FH "set IP(eol_reduction_factor_write) 1.0"
	} else {
		puts $FH "set IP(quantization_T9) 0.0"
		puts $FH "set IP(quantization_T1) 0.0"
		puts $FH "set IP(quantization_DCC) 0.0"
		puts $FH "set IP(quantization_T7) 0.0"
		puts $FH "set IP(quantization_WL) 0.0"
		puts $FH "set IP(eol_reduction_factor_addr) 1.0"
		puts $FH "set IP(eol_reduction_factor_read) 1.0"
		puts $FH "set IP(eol_reduction_factor_write) 1.0"
	}

	if { [ string compare $protocol "RLDRAMII" ] == 0 || [ string compare $protocol "RLDRAM3" ] == 0} {
		if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII" ] == 0 ||
	         [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV" ] == 0} {
			puts $FH "set IP(num_WL) 7"

		} elseif { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV" ] == 0 || [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ" ] == 0} {
			puts $FH "set IP(num_WL) 63"

		} else {
			puts $FH "set IP(num_WL) 0"
		}
	}

	if { [ string compare $protocol "DDR2" ] == 0 || [ string compare $protocol "DDR3" ] == 0 || [ string compare $protocol "LPDDR2" ] == 0 || [ string compare $protocol "LPDDR1" ] == 0 } {
		puts $FH "# Can be either dynamic or static"
		puts $FH "set IP(write_deskew_mode) \"dynamic\""
		puts $FH "set IP(read_deskew_mode) \"dynamic\""

		if { [string compare -nocase [get_parameter_value FLY_BY] "true"] == 0 } {
			puts $FH "set IP(discrete_device) 0"
		} else {
			puts $FH "set IP(discrete_device) 1"
		}
		puts $FH "set IP(num_ranks) [get_parameter_value MEM_IF_NUMBER_OF_RANKS]"
		if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
			puts $FH "set IP(num_shadow_registers) 2"
		} else {
			puts $FH "set IP(num_shadow_registers) 1"
		}
		if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
			puts $FH "set IP(tracking_enabled) 1"
	} else {
			puts $FH "set IP(tracking_enabled) 0"
		}
	} else {
		puts $FH "# Can be either dynamic or static"
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			puts $FH "set IP(write_deskew_mode) \"dynamic\""
			puts $FH "set IP(read_deskew_mode) \"dynamic\""
		} else {
			puts $FH "set IP(write_deskew_mode) \"static\""
			puts $FH "set IP(read_deskew_mode) \"static\""
		}
		puts $FH "set IP(discrete_device) 1"
		if { [ string compare $protocol "RLDRAM3" ] == 0 } {
			puts $FH "set IP(num_ranks) [get_parameter_value MEM_IF_NUMBER_OF_RANKS]"
		} else {
			puts $FH "set IP(num_ranks) 1"
		}
		puts $FH "set IP(num_shadow_registers) 1"
		puts $FH "set IP(device_width) [get_parameter_value DEVICE_WIDTH]"
	}
	puts $FH ""
	puts $FH "set IP(num_report_paths) [get_parameter_value NUM_EXTRA_REPORT_PATH]"
	
	if { [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV" ] == 0 ||
      [ string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV" ] == 0} {
		puts $FH "set IP(epr) 0.058"
		puts $FH "set IP(epw) 0.076"
	} else {
		puts $FH "set IP(epr) 0.0"
		puts $FH "set IP(epw) 0.0"
	}

	close $FH
	
	return [list $file_name]
}



proc ::alt_mem_if::gen::uniphy_gen::_init {} {
	return 1
}


proc ::alt_mem_if::gen::uniphy_gen::generate_qsys_sequencer {prepend_str protocol tmpdir fileset inhdl_dir} {
	variable seq_version
	
	
	_dprint 1 "Generating Qsys Sequencer"

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 } {
		if {[string compare -nocase [get_parameter_value RDIMM] "true"] == 0} {
			set rdimm 1
			set lrdimm 0
			set afi_clk_en_width [get_parameter_value AFI_CLK_EN_WIDTH]
			set afi_odt_width [get_parameter_value AFI_ODT_WIDTH]
		} elseif {[string compare -nocase [get_parameter_value LRDIMM] "true"] == 0} {
			set rdimm 0
			set lrdimm 1
			set afi_clk_en_width [get_parameter_value AFI_CLK_EN_WIDTH]
			set afi_odt_width [get_parameter_value AFI_ODT_WIDTH]
		} else {
			set rdimm 0
			set lrdimm 0
			set afi_clk_en_width [get_parameter_value AFI_CS_WIDTH]  
			set afi_odt_width [get_parameter_value AFI_ODT_WIDTH]
		}
		set afi_clk_en_width [get_parameter_value AFI_CS_WIDTH]
		set mr3_mpr_aa [get_parameter_value MR3_MPR_AA]
		set afi_odt_width [get_parameter_value AFI_ODT_WIDTH]
	} elseif {[string compare -nocase $protocol "LPDDR2"] == 0} {
		set rdimm 0
		set lrdimm 0
		set afi_clk_en_width [get_parameter_value AFI_CS_WIDTH]
		set mr3_mpr_aa -1
		set afi_odt_width -1
	} elseif {[string compare -nocase $protocol "LPDDR1"] == 0} {
		set rdimm 0
		set lrdimm 0
		set afi_clk_en_width [get_parameter_value AFI_CS_WIDTH]
		set mr3_mpr_aa -1
		set afi_odt_width -1
	} else {
		set rdimm 0
		set lrdimm 0
		set afi_clk_en_width -1
		set afi_odt_width -1
		set mr3_mpr_aa -1
	}

	set param_list [list]
	lappend param_list "HPS_PROTOCOL=${protocol}"
	lappend param_list "RATE=[get_parameter_value RATE]"
	lappend param_list "DLL_USE_DR_CLK=[get_parameter_value DLL_USE_DR_CLK]"
	lappend param_list "MEM_IF_READ_DQS_WIDTH=[get_parameter_value MEM_IF_READ_DQS_WIDTH]"
	lappend param_list "DUAL_WRITE_CLOCK=[get_parameter_value DUAL_WRITE_CLOCK]"
	lappend param_list "MEM_IF_DQ_WIDTH=[get_parameter_value MEM_IF_DQ_WIDTH]"
	lappend param_list "MEM_IF_DM_WIDTH=[get_parameter_value MEM_IF_DM_WIDTH]"
	lappend param_list "MEM_BURST_LENGTH=[get_parameter_value MEM_BURST_LENGTH]"
	lappend param_list "DLL_DELAY_CHAIN_LENGTH=[get_parameter_value DELAY_CHAIN_LENGTH]"
	lappend param_list "DELAY_PER_OPA_TAP=[get_parameter_value DELAY_PER_OPA_TAP]"
	lappend param_list "DELAY_PER_DCHAIN_TAP=[get_parameter_value DELAY_PER_DCHAIN_TAP]"
	lappend param_list "MAX_LATENCY_COUNT_WIDTH=[get_parameter_value MAX_LATENCY_COUNT_WIDTH]"
	lappend param_list "CALIB_VFIFO_OFFSET=[get_parameter_value CALIB_VFIFO_OFFSET]" 
	lappend param_list "CALIB_LFIFO_OFFSET=[get_parameter_value CALIB_LFIFO_OFFSET]"
	lappend param_list "CALIB_REG_WIDTH=[get_parameter_value CALIB_REG_WIDTH]"
	lappend param_list "READ_VALID_FIFO_SIZE=[get_parameter_value READ_VALID_FIFO_SIZE]"
	lappend param_list "MEM_T_WL=[get_parameter_value MEM_T_WL]"
	lappend param_list "MEM_T_RL=[get_parameter_value MEM_T_RL]"
	lappend param_list "AFI_ADDRESS_WIDTH=[get_parameter_value AFI_ADDR_WIDTH]"
	lappend param_list "AFI_CONTROL_WIDTH=[get_parameter_value AFI_CONTROL_WIDTH]"
	lappend param_list "AFI_DATA_WIDTH=[get_parameter_value AFI_DQ_WIDTH]"
	lappend param_list "AFI_DATA_MASK_WIDTH=[get_parameter_value AFI_DM_WIDTH]"
	lappend param_list "AFI_DQS_WIDTH=[get_parameter_value AFI_WRITE_DQS_WIDTH]"
	lappend param_list "MEM_IF_WRITE_DQS_WIDTH=[get_parameter_value MEM_IF_WRITE_DQS_WIDTH]"
	lappend param_list "AFI_BANK_WIDTH=[get_parameter_value AFI_BANKADDR_WIDTH]"
	lappend param_list "AFI_CHIP_SELECT_WIDTH=[get_parameter_value AFI_CS_WIDTH]"
	lappend param_list "AFI_MAX_WRITE_LATENCY_COUNT_WIDTH=[get_parameter_value AFI_WLAT_WIDTH]"
	lappend param_list "AFI_MAX_READ_LATENCY_COUNT_WIDTH=[get_parameter_value AFI_RLAT_WIDTH]"
	lappend param_list "IO_DQS_EN_DELAY_OFFSET=[get_parameter_value IO_DQS_EN_DELAY_OFFSET]"
	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {
		lappend param_list "MEM_TINIT_CK=[get_parameter_value MEM_TINIT_CK]"
		lappend param_list "MEM_TMRD_CK=[get_parameter_value MEM_TMRD_CK]"
		if {[lsearch [split [get_parameters]] "CTL_REGDIMM_ENABLED"] != -1} {
			lappend param_list "CTL_REGDIMM_ENABLED=[get_parameter_value CTL_REGDIMM_ENABLED]"
		} else {
		}
		lappend param_list "AFI_DEBUG_INFO_WIDTH=[get_parameter_value AFI_DEBUG_INFO_WIDTH]"
		lappend param_list "AFI_CLK_EN_WIDTH=$afi_clk_en_width"
		lappend param_list "AFI_ODT_WIDTH=$afi_odt_width"
		if {[string compare -nocase $protocol "LPDDR2"] == 0} {
			lappend param_list "MR1_BL=[get_parameter_value MR1_BL]"
			lappend param_list "MR1_BT=[get_parameter_value MR1_BT]"
			lappend param_list "MR1_WC=[get_parameter_value MR1_WC]"
			lappend param_list "MR1_WR=[get_parameter_value MR1_WR]"
			lappend param_list "MR2_RLWL=[get_parameter_value MR2_RLWL]"
			lappend param_list "MR3_DS=[get_parameter_value MR3_DS]"
		} elseif {[string compare -nocase $protocol "LPDDR1"] == 0} {
			lappend param_list "MR0_BL=[get_parameter_value MR0_BL]"
			lappend param_list "MR0_BT=[get_parameter_value MR0_BT]"
			lappend param_list "MR0_CAS_LATENCY=[get_parameter_value MR0_CAS_LATENCY]"
			lappend param_list "MR1_DS=[get_parameter_value MR1_DS]"
			lappend param_list "MR1_PASR=[get_parameter_value MR1_PASR]"
		} else {
			lappend param_list "MR0_BL=[get_parameter_value MR0_BL]"
			lappend param_list "MR0_BT=[get_parameter_value MR0_BT]"
			lappend param_list "MR0_CAS_LATENCY=[get_parameter_value MR0_CAS_LATENCY]"
			lappend param_list "MR0_WR=[get_parameter_value MR0_WR]"
			lappend param_list "MR0_PD=[get_parameter_value MR0_PD]"
			lappend param_list "MR1_DLL=[get_parameter_value MR1_DLL]"
			lappend param_list "MR1_ODS=[get_parameter_value MR1_ODS]"
			lappend param_list "MR1_RTT=[get_parameter_value MR1_RTT]"
			lappend param_list "MR1_AL=[get_parameter_value MR1_AL]"
			lappend param_list "MR1_QOFF=[get_parameter_value MR1_QOFF]"
			lappend param_list "RDIMM=$rdimm"
			lappend param_list "LRDIMM=$lrdimm"
			lappend param_list "MR0_DLL=[get_parameter_value MR0_DLL]"
			lappend param_list "MR1_WL=[get_parameter_value MR1_WL]"
			lappend param_list "MR1_TDQS=[get_parameter_value MR1_TDQS]"
			lappend param_list "MR2_CWL=[get_parameter_value MR2_CWL]"
			lappend param_list "MR2_ASR=[get_parameter_value MR2_ASR]"
			lappend param_list "MR2_SRT=[get_parameter_value MR2_SRT]"
			lappend param_list "MR2_RTT_WR=[get_parameter_value MR2_RTT_WR]"
			lappend param_list "MR3_MPR_RF=[get_parameter_value MR3_MPR_RF]"
			lappend param_list "MR3_MPR=$mr3_mpr_aa"
			if {[string compare -nocase $protocol "DDR3"] == 0} {
				lappend param_list "RDIMM_CONFIG=[get_parameter_value RDIMM_CONFIG]"
				lappend param_list "LRDIMM_EXTENDED_CONFIG=[get_parameter_value LRDIMM_EXTENDED_CONFIG]"
			}
		}
		lappend param_list "MEM_NUMBER_OF_RANKS=[get_parameter_value MEM_IF_NUMBER_OF_RANKS]"
		lappend param_list "MEM_CLK_EN_WIDTH=[get_parameter_value MEM_IF_CLK_EN_WIDTH]"
		lappend param_list "MEM_ODT_WIDTH=[get_parameter_value MEM_IF_ODT_WIDTH]"
		lappend param_list "MEM_BANK_WIDTH=[get_parameter_value MEM_BANKADDR_WIDTH]"
	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
		lappend param_list "MEM_NUMBER_OF_RANKS=[get_parameter_value DEVICE_DEPTH]"
		lappend param_list "MEM_ODT_WIDTH=1"
	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {
		if { [string compare -nocase $protocol "RLDRAMII"] == 0 } {
			lappend param_list "MEM_NUMBER_OF_RANKS=[get_parameter_value DEVICE_DEPTH]"
		}
		if { [string compare -nocase $protocol "RLDRAM3"] == 0 } {
			lappend param_list "MEM_NUMBER_OF_RANKS=[get_parameter_value MEM_IF_NUMBER_OF_RANKS]"
		}
		lappend param_list "MEM_BANK_WIDTH=[get_parameter_value MEM_BANKADDR_WIDTH]"
		lappend param_list "MEM_ODT_WIDTH=1"
	}
	lappend param_list "MEM_ADDRESS_WIDTH=[get_parameter_value MEM_IF_ADDR_WIDTH]"
	lappend param_list "MEM_CONTROL_WIDTH=[get_parameter_value MEM_IF_CONTROL_WIDTH]"
	lappend param_list "MEM_CHIP_SELECT_WIDTH=[get_parameter_value MEM_IF_CS_WIDTH]"
	lappend param_list "USE_DQS_TRACKING=[get_parameter_value USE_DQS_TRACKING]"
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend param_list "USE_SHADOW_REGS=true"
	} else {
		lappend param_list "USE_SHADOW_REGS=false"	
	}

	lappend param_list "HCX_COMPAT_MODE=[get_parameter_value HCX_COMPAT_MODE]"
	
	lappend param_list "NUM_WRITE_FR_CYCLE_SHIFTS=[get_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS]"
	
	lappend param_list "SEQUENCER_VERSION=$seq_version"

	lappend param_list "ENABLE_NON_DESTRUCTIVE_CALIB=[get_parameter_value ENABLE_NON_DESTRUCTIVE_CALIB]"

	lappend param_list "ENABLE_NIOS_OCI=[get_parameter_value ENABLE_NIOS_OCI]"
	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EMIT_JTAG_MASTER] "true"] == 0} {
		lappend param_list "ENABLE_DEBUG_BRIDGE=true"
	} else {
		lappend param_list "ENABLE_DEBUG_BRIDGE=false"
	}
	lappend param_list "MAKE_INTERNAL_NIOS_VISIBLE=[get_parameter_value MAKE_INTERNAL_NIOS_VISIBLE]"
	lappend param_list "ENABLE_NIOS_JTAG_UART=[get_parameter_value ENABLE_NIOS_JTAG_UART]"
	lappend param_list "ENABLE_LARGE_RW_MGR_DI_BUFFER=[get_parameter_value ENABLE_LARGE_RW_MGR_DI_BUFFER]"
	
	set nios_hex_file_name "${prepend_str}_sequencer_mem.hex"
	set ac_rom_init_file_name "${prepend_str}_AC_ROM.hex"
	set inst_rom_init_file_name "${prepend_str}_inst_ROM.hex"
	lappend param_list "SEQ_ROM=${nios_hex_file_name}"
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_sequencer_mem_use_mlab] == 1} {
		lappend param_list "RAM_BLOCK_TYPE=MLAB"
	} else {
		lappend param_list "RAM_BLOCK_TYPE=AUTO"
	}

	lappend param_list "AC_ROM_INIT_FILE_NAME=$ac_rom_init_file_name"
	lappend param_list "INST_ROM_INIT_FILE_NAME=$inst_rom_init_file_name"

	lappend param_list "HARD_PHY=[get_parameter_value HARD_PHY]"

	lappend param_list "USE_SEQUENCER_BFM=[get_parameter_value USE_SEQUENCER_BFM]"
	lappend param_list "HHP_HPS=[get_parameter_value HHP_HPS]"
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || 
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		lappend param_list "HARD_VFIFO=1"
	} else {
		lappend param_list "HARD_VFIFO=0"
	}


	set pre_compile_dir [file join $tmpdir "qsys_pre_compile"]
	catch {file mkdir $pre_compile_dir} temp_result
	
	if {[::alt_mem_if::util::qini::qini_value alt_mem_if_seq_size_request 0] > 0} {
		set seq_mem_size [::alt_mem_if::util::qini::qini_value alt_mem_if_seq_size_request 0]
		_iprint "Using specified sequencer memory size of $seq_mem_size" 1
		set mem_size_aligned [align_size $seq_mem_size 1024 0]
	} elseif {[string compare -nocase [get_parameter_value ENABLE_MAX_SIZE_SEQ_MEM] "true"] == 0} {
		set seq_mem_size 65536
		_iprint "Using max sequencer memory size of $seq_mem_size" 1
		set mem_size_aligned [align_size $seq_mem_size 1024 0]
	} else {
		set seq_mem_size_list [generate_qsys_sequencer_sw $prepend_str $protocol $pre_compile_dir $fileset $inhdl_dir $rdimm $lrdimm 0 0 \
					   $nios_hex_file_name $ac_rom_init_file_name $inst_rom_init_file_name]
		set seq_mem_size [lindex $seq_mem_size_list 0]
		set mem_size_aligned [lindex $seq_mem_size_list 1]
	}
	
	_dprint 1 "Qsys sequencer mem size: real=$seq_mem_size aligned=$mem_size_aligned"
	
	lappend param_list "SEQUENCER_MEM_SIZE=$mem_size_aligned"
	lappend param_list "SEQUENCER_MEM_ADDRESS_WIDTH=[get_parameter_value NIOS_ROM_ADDRESS_WIDTH]"
	lappend param_list "TRK_PARALLEL_SCC_LOAD=[get_parameter_value TRK_PARALLEL_SCC_LOAD]"
	lappend param_list "SCC_DATA_WIDTH=[get_parameter_value SCC_DATA_WIDTH]"

	if {[string compare -nocase [get_parameter_value USER_DEBUG_LEVEL] "4"] == 0 ||
	    [string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		lappend param_list "ENABLE_INST_ROM_WRITE=TRUE"
	}
		

	set param_str ""
	foreach param $param_list {
		append param_str " --component-param=$param"
	}

	set family [::alt_mem_if::gui::system_info::get_device_family]
	
	set curdir $tmpdir
	cd $curdir
	_iprint "CWD: $curdir"
	set qsysdir [file join $curdir "qsys"]
	catch {file mkdir $qsysdir} temp_result
	cd $qsysdir

	set qdir $::env(QUARTUS_ROOTDIR)
	set make_qsys_seq_tcl_filename "${prepend_str}_make_qsys_seq.tcl"
	set make_qsys_seq_report_filename "${prepend_str}_seq_ipd_report.txt"
	set make_qsys_seq_sopcinfo_filename "${prepend_str}.sopcinfo"

	set arg_list [list]
	foreach param $param_list {
		lappend arg_list "--component-param=$param"
	}
	lappend arg_list "--output-name=${prepend_str}"
	lappend arg_list "--system-info=DEVICE_FAMILY=$family"
	lappend arg_list "--report-file=sopcinfo:${make_qsys_seq_sopcinfo_filename}"
	lappend arg_list "--report-file=txt:${make_qsys_seq_report_filename}"

	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] == 0} {
		lappend arg_list "--file-set=SIM_VERILOG"
	} else {
		lappend arg_list "--file-set=$fileset"
	}

	_iprint "Generating Qsys sequencer system" 1
	alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh qsys_sequencer_110 $arg_list $tmpdir $make_qsys_seq_tcl_filename "qsys"
	
	set num_error_found 0
	if {[file exists $make_qsys_seq_report_filename]} {
		set ipd_fh [open $make_qsys_seq_report_filename "r"]

		while {[gets $ipd_fh line] != -1} {
			if {[regexp -nocase {\[Error\][ ]*(.*)[ ]*$|[ ]+error[ ]*:[ ]*(.*)[ ]*$|^[ ]*error[ ]*:[ ]*(.*)[ ]*$} $line match error_msg] == 1} {
				_eprint $error_msg 1
				incr num_error_found
			}
		}
		close $ipd_fh


	} else {
		_eprint "No sopcinfo report generated for QSYS sequencer deployment" 1
		incr num_error_found
	}

	if {$num_error_found == 0} {
		_iprint "QSYS sequencer system generated successfully" 1
	}

	if { ![::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_nios_cpu]} {
		if {[file exists $make_qsys_seq_sopcinfo_filename]} {
			set sopcinfo_fh [open $make_qsys_seq_sopcinfo_filename r]
			set sopcinfo_lines [split [read $sopcinfo_fh] "\n"]
			close $sopcinfo_fh
			set sopcinfo_fh [open $make_qsys_seq_sopcinfo_filename w]
			foreach sopcinfo_line $sopcinfo_lines {
				if { [regexp -- {altera_mem_if_sequencer_cpu} $sopcinfo_line] == 1 } {
					regsub {altera_mem_if_sequencer_cpu} $sopcinfo_line "altera_nios2_qsys" sopcinfo_line
				}
				puts $sopcinfo_fh $sopcinfo_line
			}
			close $sopcinfo_fh
		}
	}

	if {[::alt_mem_if::util::qini::qini_value "debug_msg_level"] == 0 ||
	    [::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_verilog_altdq_dqs2] == 0} {
		catch {[file delete -- $make_qsys_seq_report_filename]} temp_result
	}
	
	set dirs [list $qsysdir]
	set dircursor 0
	set files [list]
	while {$dircursor < [llength $dirs]} {
		set curdir [lindex $dirs $dircursor]
		incr dircursor
		foreach curfile [glob -nocomplain "[file join $curdir "*"]"] {
			if {[file isfile $curfile] == 1} {
				if {[string compare -nocase [file tail $curfile] $make_qsys_seq_sopcinfo_filename] == 0 &&
				    [string compare -nocase [get_parameter_value ADVERTIZE_SEQUENCER_SW_BUILD_FILES] "false"] == 0 &&
				    [string compare -nocase [get_parameter_value DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG] "false"] == 0 &&
					[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_return_software_build_files] == 0} {
				} else {
					set files [linsert $files end $curfile]
				}
			} elseif {[file isdirectory $curfile] == 1 && [string compare $curfile "."] != 0 && [string compare $curfile ".."] != 0} {
				set dirs [linsert $dirs end $curfile]
			}
		}
	}
	set return_files [list]
	foreach curfile $files {
		lappend return_files $curfile
	}
	cd $curdir

	set filtered_list [list]
	foreach file_name $return_files {
		if {[regexp -nocase {^[ ]*\.do[ ]*$} [file extension $file_name] match] == 0 &&
		    [regexp -nocase {sequencer_mem\.hex[ ]*$} $file_name match] == 0} {
			if {[string compare -nocase [get_parameter_value USER_DEBUG_LEVEL] "0"] != 0 &&
			    ([regexp -nocase {^[ ]*altera_merlin_master_translator\.sv[ ]*$} [file tail $file_name] match] ||
			     [regexp -nocase {^[ ]*altera_avalon_st_pipeline_base\.v[ ]*$} [file tail $file_name] match] ||
			     [regexp -nocase {^[ ]*altera_avalon_sc_fifo\.v[ ]*$} [file tail $file_name] match] ||
			     [regexp -nocase {^[ ]*altera_reset_controller\.v[ ]*$} [file tail $file_name] match] ||
			     [regexp -nocase {^[ ]*altera_reset_synchronizer\.v[ ]*$} [file tail $file_name] match] ||
			     [regexp -nocase {^[ ]*altera_merlin_slave_translator\.sv[ ]*$} [file tail $file_name] match])} {
			} else {
				lappend filtered_list $file_name
			}
		}
	}

	set return_files_sw [generate_qsys_sequencer_sw $prepend_str $protocol $qsysdir $fileset $inhdl_dir $rdimm $lrdimm $seq_mem_size $mem_size_aligned \
			     $nios_hex_file_name $ac_rom_init_file_name $inst_rom_init_file_name]

	set return_files [concat $filtered_list $return_files_sw]
	
	return $return_files

}

proc ::alt_mem_if::gen::uniphy_gen::align_size { size alignment margin } {
	set size_aligned [expr ($size + ($alignment-1)) & ~($alignment-1)]
	if {[expr $size_aligned < ($size + $margin)]} {
		set size_aligned [expr ($size + $margin + ($alignment-1)) & ~($alignment-1)]
	}
	return $size_aligned
}

proc ::alt_mem_if::gen::uniphy_gen::generate_qsys_sequencer_sw {prepend_str protocol tmpdir fileset inhdl_dir rdimm lrdimm requested_mem_size mem_size_aligned
								nios_hex_file_name ac_rom_init_file_name inst_rom_init_file_name {do_only_rw_mgr_mc 0}} {
	
	variable seq_version

	_dprint 1 "Generating Qsys Sequencer Software"


	set alignment 1024
	set base_addr 0x10000
	set mem_size_margin 128


	set qdir $::env(QUARTUS_ROOTDIR)
	set qbindir [alt_mem_if::util::iptclgen::get_quartus_bindir]
	set curdir [pwd]

	set pre_compile [expr $requested_mem_size == 0]
	set bfm_mode [expr [string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] == 0]
	set hps_mode [expr [string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0]
	set hps_verification_mode [expr [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] == 0]
	set hps_simulation_mode [expr [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] == 0]
	set hps_synthesis_mode [expr $hps_mode && !$hps_verification_mode && !$hps_simulation_mode]
	
	if {$pre_compile && ($bfm_mode || $hps_mode)} {
		return [list 32768 32768]
	}

	set mc_supported_param_list [list]
	set simple_param_list [list]
	set boolean_param_list [list]
	array set param_array [list]


	lappend simple_param_list \
	    IO_DM_OUT_RESERVE \
	    IO_DQS_IN_RESERVE \
	    IO_DQS_OUT_RESERVE \
	    IO_DQ_OUT_RESERVE \
	    IO_DQS_EN_DELAY_OFFSET \
	    IO_DQS_EN_PHASE_MAX \
	    IO_DQDQS_OUT_PHASE_MAX \
	    READ_VALID_FIFO_SIZE \
	    MAX_LATENCY_COUNT_WIDTH \
	    CALIB_VFIFO_OFFSET \
	    CALIB_LFIFO_OFFSET
	

	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 } {
		set ac_rom_list [list \
		    AC_ROM_MR0 \
		    AC_ROM_MR0_CALIB \
		    AC_ROM_MR0_DLL_RESET \
		    AC_ROM_MR1 \
		    AC_ROM_MR1_OCD_ENABLE \
		    AC_ROM_MR2 \
		    AC_ROM_MR3 \
		    AC_ROM_MR0_MIRR \
		    AC_ROM_MR0_DLL_RESET_MIRR \
		    AC_ROM_MR1_MIRR \
		    AC_ROM_MR2_MIRR \
		    AC_ROM_MR3_MIRR \
		]
	} elseif {[string compare -nocase $protocol "LPDDR2"] == 0} {
		set ac_rom_list [list \
		    AC_ROM_MR1_CALIB \
		    AC_ROM_MR1 \
		    AC_ROM_MR2 \
		    AC_ROM_MR3
		]
	} elseif {[string compare -nocase $protocol "LPDDR1"] == 0} {
		set ac_rom_list [list \
		    AC_ROM_MR0 \
		    AC_ROM_MR0_CALIB \
		    AC_ROM_MR1
		]
	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0} {
		set ac_rom_list [list \
		    AC_ROM_MR0 \
		    AC_ROM_MR0_CALIB_DLL_OFF \
		    AC_ROM_MR0_CALIB_DLL_ON
		]
	} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
		set ac_rom_list [list \
			AC_ROM_MR0 \
			AC_ROM_MR0_QUAD_RANK \
			AC_ROM_MR1 \
			AC_ROM_MR1_CALIB \
			AC_ROM_MR2 \
			AC_ROM_MR2_CALIB
		]
	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
		set ac_rom_list [list]
	}

	set simple_param_list [concat $simple_param_list $ac_rom_list]
	set mc_supported_param_list [concat $mc_supported_param_list $ac_rom_list]


	set DDR2    0
	set DDR3    0
	set DDRX    0
	set LPDDR2   0
	set LPDDR1   0
	set QDRII    0
	set RLDRAMX  0
	set RLDRAMII 0
	set RLDRAM3  0
	if {[string compare -nocase $protocol "DDR2"]==0} {
		set DDR2 1
		set DDRX 1
	} elseif {[string compare -nocase $protocol "DDR3"]==0} {
		set DDR3 1
		set DDRX 1
	} elseif {[string compare -nocase $protocol "DDRX"]==0} {
		set DDRX 1
	} elseif {[string compare -nocase $protocol "LPDDR2"]==0} {
		set LPDDR2 1
		set DDRX 1
	} elseif {[string compare -nocase $protocol "LPDDR1"]==0} {
		set LPDDR1 1
		set DDRX 1
	} elseif {[string compare -nocase $protocol "QDRII"]==0} {
		set QDRII 1
	} elseif {[string compare -nocase $protocol "RLDRAMII"]==0} {
		set RLDRAMII 1
		set RLDRAMX 1
	} elseif {[string compare -nocase $protocol "RLDRAM3"]==0} {
		set RLDRAM3 1
		set RLDRAMX 1
	}
	array set param_array [list DDR2 $DDR2 DDR3 $DDR3 DDRX $DDRX LPDDR1 $LPDDR1 LPDDR2 $LPDDR2 \
				    QDRII $QDRII RLDRAMX $RLDRAMX RLDRAMII $RLDRAMII RLDRAM3 $RLDRAM3]

	set QUARTER_RATE 0
	set HALF_RATE    0
	set FULL_RATE    0
	if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		set HALF_RATE 1
	} elseif {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set FULL_RATE 1
	} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set QUARTER_RATE 1
	}
	array set param_array [list QUARTER_RATE $QUARTER_RATE HALF_RATE $HALF_RATE FULL_RATE $FULL_RATE]
	lappend mc_supported_param_list \
	    QUARTER_RATE \
	    HALF_RATE \
	    FULL_RATE

	set BURST2 0
	if {$FULL_RATE && [get_parameter_value MEM_BURST_LENGTH] == 2} {
		set BURST2 1
	}
	array set param_array [list BURST2 $BURST2]

	array set param_array [list ENABLE_DQS_OUT_CENTERING 0]
	array set param_array [list SKEW_CALIBRATION 0]

	lappend boolean_param_list USE_DQS_TRACKING

	if {[::alt_mem_if::util::hwtcl_utils::param_is_on USE_SHADOW_REGS]} {		
		array set param_array [list USE_SHADOW_REGS 1]
		if {[::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "STRATIXV"] || [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "ARRIAVGZ"] } {
			array set param_array [list NUM_SHADOW_REGS 2]
		} else {			
			array set param_array [list NUM_SHADOW_REGS 1]
		}		
	} else {
		array set param_array [list USE_SHADOW_REGS 0]
		array set param_array [list NUM_SHADOW_REGS 1]
	}

	lappend boolean_param_list IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS
	lappend boolean_param_list HR_DDIO_OUT_HAS_THREE_REGS

	array set param_array [list STRATIXV [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "STRATIXV"]]
	array set param_array [list ARRIAV [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "ARRIAV"]]
	array set param_array [list CYCLONEV [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "CYCLONEV"]]
	array set param_array [list ARRIAVGZ [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "ARRIAVGZ"]]

	lappend boolean_param_list HHP_HPS
	lappend boolean_param_list HHP_HPS_VERIFICATION
	lappend boolean_param_list HHP_HPS_SIMULATION

	array set param_array [list HPS_HW $hps_synthesis_mode]

	if {[::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "ARRIAV"] ||
	    [::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "CYCLONEV"]} {
		array set param_array [list HARD_VFIFO 1]
	} else {
		array set param_array [list HARD_VFIFO 0]
	}

	if {$DDRX} {
		set dq_per_read_dqs [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]}]
		set dq_per_write_dqs [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]}]

		array set param_array [list \
					   RW_MGR_MEM_NUMBER_OF_RANKS [get_parameter_value MEM_IF_NUMBER_OF_RANKS] \
					   RW_MGR_MEM_NUMBER_OF_CS_PER_DIMM [get_parameter_value MEM_IF_CS_PER_DIMM] \
					   RW_MGR_MEM_DQ_PER_READ_DQS [get_parameter_value MEM_DQ_PER_DQS] \
					   RW_MGR_MEM_DQ_PER_WRITE_DQS [get_parameter_value MEM_DQ_PER_DQS] \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_READ_DQS 1 \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_WRITE_DQS 1 \
					   RW_MGR_MEM_ADDRESS_MIRRORING [get_parameter_value MEM_MIRROR_ADDRESSING_DEC] \
					  ]

		array set param_array [list \
					   RW_MGR_MEM_ADDRESS_WIDTH [get_parameter_value MEM_IF_ADDR_WIDTH] \
					   RW_MGR_MEM_BANK_WIDTH [get_parameter_value MEM_IF_BANKADDR_WIDTH] \
					   RW_MGR_MEM_CONTROL_WIDTH [get_parameter_value MEM_IF_CONTROL_WIDTH ] \
					   RW_MGR_MEM_CHIP_SELECT_WIDTH [get_parameter_value MEM_IF_CS_WIDTH] \
					   RW_MGR_MEM_CLK_EN_WIDTH [get_parameter_value MEM_IF_CLK_EN_WIDTH] \
					   RW_MGR_MEM_ODT_WIDTH [get_parameter_value MEM_IF_ODT_WIDTH] \
					  ]
		if {[::alt_mem_if::util::hwtcl_utils::param_is_on MEM_IF_DM_PINS_EN]} {
			array set param_array [list \
						   DM_PINS_ENABLED 1 \
						   RW_MGR_TRUE_MEM_DATA_MASK_WIDTH [get_parameter_value MEM_IF_DM_WIDTH] \
						  ]
		} else {
			array set param_array [list \
						   RW_MGR_TRUE_MEM_DATA_MASK_WIDTH 0 \
						  ]
		}
		
		if {$LPDDR2} {
			array set param_array [list \
						   RW_MGR_MR0_BL 0 \
						   RW_MGR_MR0_CAS_LATENCY [get_parameter_value MR2_RLWL] \
                           MEM_BURST_LEN [get_parameter_value MEM_BURST_LENGTH] \
						  ]
		} else {
			array set param_array [list \
						   RW_MGR_MR0_BL [get_parameter_value MR0_BL] \
						   RW_MGR_MR0_CAS_LATENCY [get_parameter_value MR0_CAS_LATENCY] \
						  ]
		}

		set write_to_debug_read_ratio [expr { ($dq_per_read_dqs * 2 * [get_parameter_value AFI_RATE_RATIO] / 32.0)}]
		if {$write_to_debug_read_ratio < 1} {
			set write_to_debug_read_ratio 0
		} else {
			set write_to_debug_read_ratio [expr {ceil ( [::alt_mem_if::util::hwtcl_utils::log2 $write_to_debug_read_ratio] ) } ]
		}
		set write_to_debug_read_ratio [expr {pow(2, $write_to_debug_read_ratio)}]
		array set param_array [list RW_MGR_WRITE_TO_DEBUG_READ $write_to_debug_read_ratio]
		
		
	} else {
		set dq_per_read_dqs [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]}]
		set dq_per_write_dqs [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]}]
		
		if {$RLDRAM3} { 
			array set param_array [list \
					   RW_MGR_MEM_NUMBER_OF_RANKS [get_parameter_value MEM_IF_NUMBER_OF_RANKS] \
					   RW_MGR_MEM_DQ_PER_READ_DQS $dq_per_read_dqs \
					   RW_MGR_MEM_DQ_PER_WRITE_DQS $dq_per_write_dqs \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_READ_DQS [expr $dq_per_read_dqs/9] \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_WRITE_DQS [expr $dq_per_write_dqs/9] \
					   RW_MGR_MEM_ADDRESS_MIRRORING 0 \
					  ]
		} else {
			array set param_array [list \
					   RW_MGR_MEM_NUMBER_OF_RANKS 1 \
					   RW_MGR_MEM_DQ_PER_READ_DQS $dq_per_read_dqs \
					   RW_MGR_MEM_DQ_PER_WRITE_DQS $dq_per_write_dqs \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_READ_DQS [expr $dq_per_read_dqs/9] \
					   RW_MGR_MEM_VIRTUAL_GROUPS_PER_WRITE_DQS [expr $dq_per_write_dqs/9] \
					   RW_MGR_MEM_ADDRESS_MIRRORING 0 \
					  ]
		}
		if {[::alt_mem_if::util::hwtcl_utils::param_is_on MEM_IF_DM_PINS_EN]} {
			array set param_array [list \
						   DM_PINS_ENABLED 1 \
						   RW_MGR_TRUE_MEM_DATA_MASK_WIDTH [get_parameter_value MEM_IF_DM_WIDTH] \
						  ]
		} else {
			array set param_array [list RW_MGR_TRUE_MEM_DATA_MASK_WIDTH 0]
		}

		array set param_array [list \
					   RW_MGR_MEM_ADDRESS_WIDTH [get_parameter_value MEM_IF_ADDR_WIDTH] \
					   RW_MGR_MEM_CONTROL_WIDTH [get_parameter_value MEM_IF_CONTROL_WIDTH] \
					   RW_MGR_MEM_CLK_EN_WIDTH 0 \
					   RW_MGR_MEM_ODT_WIDTH 0 \
					   RW_MGR_MR0_BL 0 \
					   RW_MGR_MR0_CAS_LATENCY 0 \
					   MEM_BURST_LEN [get_parameter_value MEM_BURST_LENGTH] \
					  ]
		if {[string first "RLDRAM" $protocol] >= 0} {
			array set param_array [list \
						   RW_MGR_MEM_BANK_WIDTH [get_parameter_value MEM_IF_BANKADDR_WIDTH] \
						   RW_MGR_MEM_CHIP_SELECT_WIDTH [get_parameter_value MEM_IF_CS_WIDTH] \
						  ]
		} else {
			array set param_array [list \
						   RW_MGR_MEM_BANK_WIDTH 0 \
						   RW_MGR_MEM_CHIP_SELECT_WIDTH 1 \
						  ]
		}

		set write_to_debug_read_ratio [expr { ($dq_per_read_dqs * 2 * [get_parameter_value AFI_RATE_RATIO] / 32.0)}]
		if {$write_to_debug_read_ratio < 1} {
			set write_to_debug_read_ratio 0
		} else {
			set write_to_debug_read_ratio [expr {ceil ( [::alt_mem_if::util::hwtcl_utils::log2 $write_to_debug_read_ratio] ) } ]
		}
		set write_to_debug_read_ratio [expr {pow(2, $write_to_debug_read_ratio)}]
		array set param_array [list RW_MGR_WRITE_TO_DEBUG_READ $write_to_debug_read_ratio]

	}

	array set param_array [list \
				   BFM_MODE $bfm_mode \
				   ENABLE_ASSERT $bfm_mode \
				  ]

	array set param_array [list GUARANTEED_READ_BRINGUP_TEST 0]
	lappend mc_supported_param_list GUARANTEED_READ_BRINGUP_TEST
	array set param_array [list ENABLE_BRINGUP_DEBUGGING 0]

	if {$DDR3 && ($rdimm || $lrdimm)} {
		set rdimm_config_str [ get_parameter_value RDIMM_CONFIG ]
		set rdimm_config_str [ string map {0x ""} $rdimm_config_str]
		set rdimm_config_low "0x[ string range $rdimm_config_str end-7 end ]"

		if {([string length $rdimm_config_str] > 8)} {
			set rdimm_config_high "0x[ string range $rdimm_config_str end-15 end-8 ]"
		} else {
			set rdimm_config_high "0x0"
		}

		array set param_array [list \
					   RDIMM_CONFIG_WORD_LOW $rdimm_config_low \
					   RDIMM_CONFIG_WORD_HIGH $rdimm_config_high \
					  ]

		if {$lrdimm} {

			set lrdimm_ext_config_str [get_parameter_value LRDIMM_EXTENDED_CONFIG]
			set lrdimm_ext_config_str [ string map {0x ""} $lrdimm_ext_config_str]
			set lrdimm_extended_init_array ""
			for {set idx 0} {$idx < 9} {incr idx} {
				set ch_idx [expr {$idx * 2}]
				set ch0 [string index $lrdimm_ext_config_str end-$ch_idx]
				incr ch_idx
				set ch1 [string index $lrdimm_ext_config_str end-$ch_idx]

				if {([string length $ch0] != 1)} {
					set ch0 "0"
				}
				if {([string length $ch1] != 1)} {
					set ch1 "0"
				}

				scan "$ch1 $ch0" "%x %x" ch1_num ch0_num
				set ch_b76 [expr {($ch1_num >> 2) & 0x3}]
				set ch_b54 [expr {($ch1_num     ) & 0x3}]
				set ch_b32 [expr {($ch0_num >> 2) & 0x3}]
				set ch_b10 [expr {($ch0_num     ) & 0x3}]

				switch -exact $idx {
					0 { set str "\{ 1, 11, 0x$ch1\}, \{ 1,  8, 0x$ch0\}, "}
					1 { set str "\{ 1, 13, 0x$ch1\}, \{ 1, 12, 0x$ch0\}, "}
					2 { set str "\{ 1, 15, 0x$ch1\}, \{ 1, 14, 0x$ch0\}, "}
					3 { set str "\{ 3,  9, 0x$ch1\}, \{ 3,  8, 0x$ch0\}, "}
					4 { set str "\{ 4, 11, $ch_b76\}, \{ 3, 11, $ch_b54\}, \{ 4, 10, $ch_b32\}, \{ 3, 10, $ch_b10\}, "}
					5 { set str "\{ 6, 11, $ch_b76\}, \{ 5, 11, $ch_b54\}, \{ 6, 10, $ch_b32\}, \{ 5, 10, $ch_b10\}, "}
					6 { set str "\{ 8, 11, $ch_b76\}, \{ 7, 11, $ch_b54\}, \{ 8, 10, $ch_b32\}, \{ 7, 10, $ch_b10\}, "}
					7 { set str "\{10, 11, $ch_b76\}, \{ 9, 11, $ch_b54\}, \{10, 10, $ch_b32\}, \{ 9, 10, $ch_b10\}, "}
					8 {					}
				}

				set lrdimm_extended_init_array "$lrdimm_extended_init_array $str"
			}
			
			set rtt_nom  [get_parameter_value MEM_RTT_NOM]
			switch -exact $rtt_nom {
				"ODT Disabled" { set rtt_nom_str "\{3, 0, 0\}, "}
				"RZQ/4"        { set rtt_nom_str "\{3, 0, 1\}, "}
				"RZQ/2"        { set rtt_nom_str "\{3, 0, 2\}, "}
				"RZQ/6"        { set rtt_nom_str "\{3, 0, 3\}, "}
			}
			set lrdimm_extended_init_array "$lrdimm_extended_init_array $rtt_nom_str"

			set rtt_wr  [get_parameter_value MEM_RTT_WR]
			switch -exact $rtt_wr {
				"Dynamic ODT off" { set rtt_wr_str "\{3, 1, 0\}, "}
				"RZQ/4"           { set rtt_wr_str "\{3, 1, 1\}, "}
				"RZQ/2"           { set rtt_wr_str "\{3, 1, 2\}, "}
			}
			set lrdimm_extended_init_array "$lrdimm_extended_init_array $rtt_wr_str"

			set rtt_drv  [get_parameter_value MEM_DRV_STR]
			switch -exact $rtt_drv {
				"RZQ/6"           { set rtt_drv_str "\{3, 2, 0\}, "}
				"RZQ/7"           { set rtt_drv_str "\{3, 2, 1\}, "}
			}
			set lrdimm_extended_init_array "$lrdimm_extended_init_array $rtt_drv_str"

			set lrdimm_extended_init_array "\{$lrdimm_extended_init_array\}"

			array set param_array [ list \
						LRDIMM_EXT_CONFIG_ARRAY $lrdimm_extended_init_array \
						]
			_dprint 1 "LRDIMM extended parameter array = ${lrdimm_extended_init_array}"

			set lrdimm_spd_mr  "0x[ string range $lrdimm_ext_config_str end-17 end-16 ]"
			array set param_array [ list \
						LRDIMM_SPD_MR $lrdimm_spd_mr \
						]

			set lrdimm_rank_multiplication_factor [get_parameter_value MEM_RANK_MULTIPLICATION_FACTOR]
			array set param_array [ list\
						LRDIMM_RANK_MULTIPLICATION_FACTOR $lrdimm_rank_multiplication_factor \
						]
		}

	}
	array set param_array [list \
				   LRDIMM $lrdimm \
				   RDIMM $rdimm \
				   RW_MGR_MEM_IF_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH] \
				   RW_MGR_MEM_IF_WRITE_DQS_WIDTH [get_parameter_value MEM_IF_WRITE_DQS_WIDTH] \
				   RW_MGR_MEM_DATA_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH] \
				   RW_MGR_MEM_DATA_MASK_WIDTH [get_parameter_value MEM_IF_DM_WIDTH] \
				  ]
	if {$DDR2} {
		array set param_array [list MEM_ADDR_WIDTH 13]
	} elseif {$DDR3} {
		array set param_array [list MEM_ADDR_WIDTH 13]
	} elseif {$LPDDR2} {
		array set param_array [list MEM_ADDR_WIDTH 10]
		array set param_array [list MEM_IF_COL_ADDR_WIDTH [get_parameter_value MEM_IF_COL_ADDR_WIDTH]]
		array set param_array [list MEM_IF_ROW_ADDR_WIDTH [get_parameter_value MEM_IF_ROW_ADDR_WIDTH]]
	} elseif {$QDRII} {
		array set param_array [list MEM_ADDR_WIDTH 22]
	} elseif {$RLDRAMII} {
		array set param_array [list MEM_ADDR_WIDTH 22]
	} elseif {$RLDRAM3} {
		array set param_array [list MEM_ADDR_WIDTH 21]
	} elseif {$LPDDR1} {
		array set param_array [list MEM_ADDR_WIDTH 13]
	}

	lappend mc_supported_param_list MEM_ADDR_WIDTH

	array set param_array [list \
				   IO_DELAY_PER_OPA_TAP [get_parameter_value DELAY_PER_OPA_TAP] \
				   IO_DELAY_PER_DCHAIN_TAP [get_parameter_value DELAY_PER_DCHAIN_TAP] \
				   IO_DELAY_PER_DQS_EN_DCHAIN_TAP [get_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP]    \
				   IO_DQS_EN_DELAY_MAX [get_parameter_value DQS_EN_DELAY_MAX] \
				   IO_DQS_IN_DELAY_MAX [get_parameter_value DQS_IN_DELAY_MAX] \
				   IO_IO_IN_DELAY_MAX [get_parameter_value IO_IN_DELAY_MAX] \
				   IO_IO_OUT1_DELAY_MAX [get_parameter_value IO_OUT1_DELAY_MAX] \
				   IO_IO_OUT2_DELAY_MAX [get_parameter_value IO_OUT2_DELAY_MAX] \
				   IO_DLL_CHAIN_LENGTH [get_parameter_value DELAY_CHAIN_LENGTH] \
				  ]

	set tcl_debug 0
	if {[string compare -nocase $fileset "QUARTUS_SYNTH"] == 0} {
		array set param_array [list \
					   STATIC_SIM_FILESET 0 \
					   STATIC_SKIP_MEM_INIT 0 \
					   STATIC_FULL_CALIBRATION 1 \
					   ENABLE_SUPER_QUICK_CALIBRATION 0 \
					  ]
		if {[::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_EMIT_JTAG_MASTER] && !$hps_mode} {
			set tcl_debug 1
		}
	} else {
		array set param_array [list STATIC_SIM_FILESET 1]
		array set param_array [list STATIC_SKIP_MEM_INIT [::alt_mem_if::util::hwtcl_utils::param_is_on SKIP_MEM_INIT]]
		if {[::alt_mem_if::util::hwtcl_utils::param_compare CALIBRATION_MODE "FULL"]} {
			array set param_array [list STATIC_FULL_CALIBRATION 1]
			array set param_array [list ENABLE_SUPER_QUICK_CALIBRATION 0]
			if {([::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_EMIT_JTAG_MASTER] && !($bfm_mode || $hps_mode)) ||
			    [::alt_mem_if::util::hwtcl_utils::param_is_on FORCE_SEQUENCER_TCL_DEBUG_MODE]} {
				set tcl_debug 1
			}
		} elseif {[::alt_mem_if::util::hwtcl_utils::param_compare CALIBRATION_MODE "QUICK"]} {
			array set param_array [list STATIC_QUICK_CALIBRATION 1]
			array set param_array [list ENABLE_SUPER_QUICK_CALIBRATION 1]
			if {[::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_EMIT_BFM_MASTER]} {
				set tcl_debug 1
			}
		} else {
			array set param_array [list STATIC_SKIP_CALIBRATION 1]
			array set param_array [list ENABLE_SUPER_QUICK_CALIBRATION 0]
			if {[::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_EMIT_BFM_MASTER]} {
				set tcl_debug 1
			}
		}
	}
	
	set core_debug_bridge 0
	if { ! $do_only_rw_mgr_mc} {
		if {[::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_EXPORT_SEQ_DEBUG_BRIDGE]} {
 			set tcl_debug 1
 			set core_debug_bridge 1
		}
		lappend boolean_param_list ENABLE_EXPORT_SEQ_DEBUG_BRIDGE
 	}

	_dprint 1 "tcl_debug: $tcl_debug"
	array set param_array [list ENABLE_TCL_DEBUG $tcl_debug]
	
	lappend boolean_param_list HCX_COMPAT_MODE
	
	if {[get_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS] == -1} {
		array set param_array [list CALIBRATE_BIT_SLIPS 1]
	} else {
		array set param_array [list CALIBRATE_BIT_SLIPS 0]
	}	
	
	if {[string compare -nocase [get_parameter_value PERFORM_READ_AFTER_WRITE_CALIBRATION] "true"] == 0} {
		array set param_array [list READ_AFTER_WRITE_CALIBRATION 1]
	} else {
		array set param_array [list READ_AFTER_WRITE_CALIBRATION 0]
	}
	
	if { ! $do_only_rw_mgr_mc} {
		if {[get_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH] > 6} {
			array set param_array [list MULTIPLE_AFI_WLAT 1]
		} else {
			array set param_array [list MULTIPLE_AFI_WLAT 0]
		}
	}

	if {[::alt_mem_if::util::hwtcl_utils::param_compare USER_DEBUG_LEVEL "4"] ||
	    $hps_verification_mode || $hps_synthesis_mode} {
		array set param_array [list ENABLE_INST_ROM_WRITE 1]
	} else {
		array set param_array [list ENABLE_INST_ROM_WRITE 0]
	}
	
	if {[::alt_mem_if::util::hwtcl_utils::param_is_on  ENABLE_SEQUENCER_MARGINING_ON_BY_DEFAULT]} {
		array set param_array [list ENABLE_MARGIN_REPORT_GEN 1]
	} else {
		array set param_array [list ENABLE_MARGIN_REPORT_GEN 0]
	}

	if {[::alt_mem_if::util::hwtcl_utils::param_compare TRACKING_ERROR_TEST "TRUE"]} { 
		array set param_array [list TRACKING_ERROR_TEST 1]
	} else {
		array set param_array [list TRACKING_ERROR_TEST 0]
	}

	if {[::alt_mem_if::util::hwtcl_utils::param_compare TRACKING_WATCH_TEST "TRUE"]} { 
		array set param_array [list TRACKING_WATCH_TEST 1]
	} else {
		array set param_array [list TRACKING_WATCH_TEST 0]
	}

	if {[::alt_mem_if::util::hwtcl_utils::param_compare MARGIN_VARIATION_TEST "TRUE"]} { 
		array set param_array [list MARGIN_VARIATION_TEST 1]
	} else {
		array set param_array [list MARGIN_VARIATION_TEST 0]
	}

	set seq_version_str [expr {$seq_version * 10}]
	set seq_version_int [expr {int($seq_version_str) & 0x000000FF}]
	
	if {$seq_version_int != $seq_version_str } {
		_error "Fatal Error: Could not format sequencer version ($seq_version => $seq_version_str : $seq_version_int"
	}

	set seq_schema_version 4

	set seq_schemaver_ipver [expr {($seq_schema_version << 8) | $seq_version_int}]
	set seq_schemaver_ipver [expr {$seq_schemaver_ipver & 0x0000FFFF}]

	set seq_signature [expr {0x55550000 | $seq_schemaver_ipver}]
	set seq_signature_hex [format "0x%x" $seq_signature]
	array set param_array [list REG_FILE_INIT_SEQ_SIGNATURE ${seq_signature_hex}]

	if {[::alt_mem_if::util::hwtcl_utils::param_is_on ENABLE_NIOS_PRINTF_OUTPUT] && !($bfm_mode || $hps_mode)} {
		array set param_array [list ENABLE_PRINTF_LOG 1]
	}
	
	array set param_array [list RUNTIME_CAL_REPORT 0]
	
	array set param_array [list ENABLE_DQS_IN_CENTERING 1]

	array set param_array [list AFI_CLK_FREQ [expr int([get_parameter_value PLL_AFI_CLK_FREQ] + 1)]]

	lappend simple_param_list AFI_RATE_RATIO

	array set param_array [list AVL_CLK_FREQ [expr int([get_parameter_value PLL_NIOS_CLK_FREQ] + 1)]]

	lappend boolean_param_list HARD_PHY
	lappend mc_supported_param_list HARD_PHY

	lappend boolean_param_list ENABLE_NON_DESTRUCTIVE_CALIB


	if {$hps_simulation_mode} {
		lappend simple_param_list \
		    MEM_BURST_LENGTH \
		    ADDR_ORDER \
		    MEM_WTCL_INT \
		    MEM_ATCL_INT \
		    MEM_TCL \
		    MEM_TRRD \
		    MEM_TFAW \
		    MEM_TRFC \
		    MEM_TREFI \
		    MEM_TRCD \
		    MEM_TRP \
		    MEM_TWTR \
		    MEM_TWR \
		    MEM_TRTP \
		    MEM_TRAS \
		    MEM_TRC \
		    MEM_TMRD_CK \
		    CFG_TCCD \
		    INTG_EXTRA_CTL_CLK_ACT_TO_RDWR \
		    INTG_EXTRA_CTL_CLK_RD_TO_PCH \
		    INTG_EXTRA_CTL_CLK_ACT_TO_ACT \
		    INTG_EXTRA_CTL_CLK_RD_TO_RD \
		    INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP \
		    INTG_EXTRA_CTL_CLK_RD_TO_WR \
		    INTG_EXTRA_CTL_CLK_RD_TO_WR_BC \
		    INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP \
		    INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID \
		    INTG_EXTRA_CTL_CLK_WR_TO_WR \
		    INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP \
		    INTG_EXTRA_CTL_CLK_WR_TO_RD \
		    INTG_EXTRA_CTL_CLK_WR_TO_RD_BC \
		    INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP \
		    INTG_EXTRA_CTL_CLK_WR_TO_PCH \
		    INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID \
		    INTG_EXTRA_CTL_CLK_PCH_TO_VALID \
		    INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID \
		    INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK \
		    INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT \
		    INTG_EXTRA_CTL_CLK_ARF_TO_VALID \
		    INTG_EXTRA_CTL_CLK_PDN_TO_VALID \
		    INTG_EXTRA_CTL_CLK_SRF_TO_VALID \
		    INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL \
		    INTG_EXTRA_CTL_CLK_ARF_PERIOD \
		    INTG_EXTRA_CTL_CLK_PDN_PERIOD \
		    MEM_IF_COL_ADDR_WIDTH \
		    MEM_IF_ROW_ADDR_WIDTH \
		    MEM_IF_BANKADDR_WIDTH \
		    MEM_IF_CS_WIDTH \
		    MEM_IF_CHIP_BITS
		    
	}

	foreach param $simple_param_list {
		array set param_array [list $param [get_parameter_value $param]]
	}
	foreach param $boolean_param_list {
		array set param_array [list $param [::alt_mem_if::util::hwtcl_utils::param_is_on $param]]
	}

	set mc_macros ""
	foreach param $mc_supported_param_list {
		if {[info exists param_array($param)]} {
			append mc_macros " -D$param=$param_array($param)"
		}
	}
	

	set mc_suffix [string tolower $protocol]

	set bsp_files [list settings.bsp]
	if {[::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "MAX10FPGA"]} {
	    set app_files [list sequencer_m10.c sequencer_m10.h]
	} else {
	    set app_files [list sequencer.c sequencer.h tclrpt.c tclrpt.h]
	}
	set mc_src_files [list ac_rom_${mc_suffix}.s inst_rom_${mc_suffix}.s]
	set mc_files [list ac_rom.s inst_rom.s]
	if {$bfm_mode} {
		set bfm_files [list alt_types.h io.h system.h]
	} elseif {$hps_synthesis_mode} {
		set bfm_files [list alt_types.h system.h]
		set hps_files [list sdram_io.h]
	}
	if {$hps_simulation_mode} {
		set bfm_files [list]
		set hps_files [list io.h hps_controller.h]
	}

	set sw_rel_dir [file join "${prepend_str}_software"]
	set sw_dir [file join $tmpdir $sw_rel_dir]
	set bsp_dir [file join $sw_dir sequencer_bsp]
	set app_dir [file join $sw_dir sequencer]
	set mc_dir [file join $sw_dir sequencer_mc]
	if {$bfm_mode} {
		set bfm_dir [file join $sw_dir sequencer_bfm]
	}

	catch {file mkdir $sw_dir} temp_result
	catch {file mkdir $bsp_dir} temp_result
	catch {file mkdir $app_dir} temp_result
	catch {file mkdir $mc_dir} temp_result
	if {$bfm_mode} {
		catch {file mkdir $bfm_dir} temp_result
	}

	set sw_src_dir "$qdir/../ip/altera/alt_mem_if/altera_mem_if_qseq/software_110"


	if {$pre_compile || $hps_simulation_mode} {
		if {$hps_simulation_mode} {
			set target_filename "hps.sopcinfo"
		} else {
			set target_filename "pre_compile.sopcinfo"
		}
		file copy -force [file join $sw_src_dir "sequencer_pre_compile" "pre_compile.sopcinfo.bsp"] [file join "$tmpdir" "$target_filename"]
	}

	if {$hps_simulation_mode || $hps_synthesis_mode} {
		foreach f $hps_files {
			file copy -force [file join $sw_src_dir sequencer_hps $f] [file join $app_dir $f]
		}
		foreach f $bfm_files {
			file copy -force [file join $sw_src_dir sequencer_bfm $f] [file join $app_dir $f]
		}
	}

	foreach f $bsp_files {
		file copy -force [file join $sw_src_dir sequencer_bsp $f] $bsp_dir
	}
	foreach f $app_files {
		file copy -force [file join $sw_src_dir sequencer_c $f] [file join $app_dir $f]
	}
	foreach f $mc_src_files g $mc_files {
		file copy -force [file join $sw_src_dir sequencer_mc $f] [file join $mc_dir $g]
	}
	if {$bfm_mode} {
		foreach f $bfm_files {
			file copy -force [file join $sw_src_dir sequencer_bfm $f] [file join $bfm_dir $f]
		}
	}

	set defines_h "sequencer_defines.h"
	set fh [open [file join $app_dir $defines_h] w]
	puts $fh "#ifndef _SEQUENCER_DEFINES_H_"
	puts $fh "#define _SEQUENCER_DEFINES_H_"
	puts $fh ""
	foreach key [lsort -dictionary [array names param_array]] {
		puts $fh "#define $key $param_array($key)"
	}
	puts $fh ""
	puts $fh "#endif /* _SEQUENCER_DEFINES_H_ */"
	close $fh
	

	set windows_nios2_cmd_shell "$qdir/../nios2eds/Nios II Command Shell.bat"
	set linux_nios2_cmd_shell "$qdir/../nios2eds/nios2_command_shell.sh"
	set OS_WIN 0

	if {[file exists $windows_nios2_cmd_shell]} {
			set OS_WIN 1
	}




	set optimization_flag "-Os"
	if {[string compare -nocase [get_parameter_value USER_DEBUG_LEVEL] "4"] == 0} {
		set optimization_flag "-O0"
	}

	if {$pre_compile} {
		set mem_size_aligned 0x100000
	}
	
	set base_addr_fmt [format "0x%x" $base_addr]
	set end_addr_fmt [format "0x%x" [expr $base_addr + $mem_size_aligned - 1]]

	set stack_pointer_fmt [format "0x%x" [expr $base_addr + $mem_size_aligned - 16]]

	set mem_size_filename "size.out"


	set hal_src_files [list \
		alt_main.c \
		alt_load.c \
	]

	set hal_driver_files [list \
		altera_nios2_qsys_irq.c \
		alt_icache_flush_all.c \
		alt_dcache_flush_all.c \
	]

	set hal_srcs ""
	set option_modifier ""
	foreach src $hal_src_files {
		append hal_srcs " hal_C_LIB_SRCS${option_modifier}=HAL/src/${src}"
		set option_modifier "+"
	}
		
	set hal_drivers ""
	set option_modifier ""
	foreach src $hal_driver_files {
		append hal_drivers " altera_nios2_qsys_hal_driver_C_LIB_SRCS${option_modifier}=HAL/src/${src}"
		set option_modifier "+"
	}
	

	cd $sw_dir
	set fh [open "Makefile" w]
	puts $fh "MC_MACROS := $mc_macros"
	puts $fh ""
	puts $fh ".PHONY : all"
	if {$bfm_mode} {
		puts $fh "all : bfm"
	} elseif {$hps_synthesis_mode} {
		puts $fh "all : hps"
	} else {
		puts $fh "all : hex"
	}
	puts $fh ""
	puts $fh ".PHONY : hex"
	puts $fh "hex : elf"
	puts $fh "\t$qdir/../nios2eds/bin/elf2hex --base=$base_addr_fmt --end=$end_addr_fmt --create-lanes=0 --width=32 --record=4 --input=sequencer/sequencer.elf --output=../$nios_hex_file_name"
	puts $fh ""
	puts $fh ".PHONY : elf"
	puts $fh "elf : setup"
	puts $fh "\t\$(MAKE) -C sequencer_bsp clean altera_nios2_qsys_hal_driver_ASM_LIB_SRCS=HAL/src/crt0.S ${hal_srcs} ${hal_drivers}"
	puts $fh "\t\$(MAKE) -C sequencer clean all altera_nios2_qsys_hal_driver_ASM_LIB_SRCS=HAL/src/crt0.S ${hal_srcs} ${hal_drivers}"
	puts $fh ""
	puts $fh ".PHONY : setup"
	puts $fh "setup : mc"
	puts $fh "ifeq (\$(wildcard sequencer_bsp/Makefile),)"
	puts $fh "\t$qdir/../nios2eds/sdk2/bin/nios2-bsp hal sequencer_bsp .. --default_sections_mapping sequencer_mem --use_bootloader DONT_CHANGE"
	puts $fh "endif"
	puts $fh "ifeq (\$(wildcard sequencer/Makefile),)"
	if { $OS_WIN == 1} {
		puts $fh "\t$qdir/../nios2eds/sdk2/bin/nios2-app-generate-makefile --bsp-dir sequencer_bsp --app-dir sequencer --elf-name sequencer.elf --set OBJDUMP_INCLUDE_SOURCE 1 --set APP_CFLAGS_DEFINED_SYMBOLS -DSTACK_POINTER=${stack_pointer_fmt} --set APP_CFLAGS_OPTIMIZATION \\\"${optimization_flag} --param max-inline-insns-single=1000 -fno-zero-initialized-in-bss\\\" --set APP_CFLAGS_WARNINGS \\\"-Winline -Wall\\\" --src-files $app_files sequencer_auto_ac_init.c sequencer_auto_inst_init.c"
	} else {
		puts $fh "\t$qdir/../nios2eds/sdk2/bin/nios2-app-generate-makefile --bsp-dir sequencer_bsp --app-dir sequencer --elf-name sequencer.elf --set OBJDUMP_INCLUDE_SOURCE 1 --set APP_CFLAGS_DEFINED_SYMBOLS -DSTACK_POINTER=${stack_pointer_fmt} --set APP_CFLAGS_OPTIMIZATION \"${optimization_flag} --param max-inline-insns-single=1000 -fno-zero-initialized-in-bss\" --set APP_CFLAGS_WARNINGS \"-Winline -Wall\" --src-files $app_files sequencer_auto_ac_init.c sequencer_auto_inst_init.c"
	}	
	puts $fh "endif"
	puts $fh ""
	puts $fh ".PHONY : mc"
	puts $fh "mc :"
	puts $fh "ifeq (\$(wildcard sequencer_mc),sequencer_mc)"
	puts $fh "\t$qdir/bin/uniphy_mcc -ac_code sequencer_mc/ac_rom.s -inst_code sequencer_mc/inst_rom.s -ac_rom ../$ac_rom_init_file_name -inst_rom ../$inst_rom_init_file_name -header sequencer/sequencer_auto.h -vheader ../sequencer_auto_h.sv -ac_rom_init sequencer/sequencer_auto_ac_init.c -inst_rom_init sequencer/sequencer_auto_inst_init.c \$(MC_MACROS)"
	puts $fh "endif"
	puts $fh ""
	puts $fh ".PHONY : gui"
	puts $fh "gui : setup"
	puts $fh "\teclipse-nios2"
	puts $fh ""
	if {$bfm_mode} {
		puts $fh ""
		puts $fh "ifeq (\$(findstring 64, \${VCS_TARGET_ARCH}),64)"
		puts $fh "GCC_OPT=-m64"
		puts $fh "else"
		puts $fh "GCC_OPT=-m32"
		puts $fh "endif"
		puts $fh ""
		puts $fh ".PHONY : bfm"
		puts $fh "bfm : mc"
		puts $fh "\tcd sequencer_bfm && gcc -g -w \${GCC_OPT} -c -fprofile-arcs -ftest-coverage \$(BFM_MACROS) -I. -I../sequencer ../sequencer/sequencer*.c ../sequencer/tclrpt.c && ar r ../../sequencer.a *.o"
		puts $fh ""
	} elseif {$hps_synthesis_mode} {
		puts $fh ".PHONY : hps"
		puts $fh "hps : mc"
		puts $fh ""
	}
	close $fh


	if {$pre_compile} {
	} elseif {$hps_synthesis_mode} {
	} elseif {[string compare -nocase [get_parameter_value ADVERTIZE_SEQUENCER_SW_BUILD_FILES] "true"] == 0 ||
			[string compare -nocase [get_parameter_value DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG] "true"] == 0 ||
			[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_return_software_build_files] == 1} {
		alt_mem_if::util::iptclgen::advertize_directory {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} $sw_rel_dir $tmpdir {} $fileset
	} else {
		if {[::alt_mem_if::util::hwtcl_utils::param_compare PARSE_FRIENDLY_DEVICE_FAMILY "MAX10FPGA"]} {
		    alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} sequencer_m10.c $app_dir $sw_rel_dir $fileset
		    alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} sequencer_m10.h $app_dir $sw_rel_dir $fileset
		} else {
		    alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} sequencer.c $app_dir $sw_rel_dir $fileset
		    alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} sequencer.h $app_dir $sw_rel_dir $fileset
		}
		alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,EXAMPLE_DESIGN} sequencer_defines.h $app_dir $sw_rel_dir $fileset
	}

	
	set all_target "all"
	if {$do_only_rw_mgr_mc} {
		set all_target "mc"
	}
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_build_software_from_tclsh]} {

		set sw_script_file_name "make_seq_software.tcl"
		set fh [open $sw_script_file_name w]
		
		if {$bfm_mode} {
		} elseif {[file exists $windows_nios2_cmd_shell]} {
			puts $fh "set cmd \[list exec \"$windows_nios2_cmd_shell\" make $all_target\]"
		} elseif {[file exists $linux_nios2_cmd_shell]} {
			puts $fh "set cmd \[list exec \"$linux_nios2_cmd_shell\" make $all_target\]"
		} else {
			_error "Cannot locate the Nios II Command Shell.  Nios II SBT must be installed to generate UniPHY IP cores."
		}
		
		puts $fh "catch \{ eval \$cmd \} temp"
		puts $fh "puts \$temp"
		close $fh
		
		if {$pre_compile} {
			_dprint 1 "Determining sequencer memory size"
		} else {
			_dprint 1 "Building sequencer software"
		}
		set quartus_output [alt_mem_if::util::iptclgen::run_tclsh_script $sw_script_file_name]

	} else {
		if {[file exists $windows_nios2_cmd_shell]} {
			set cmd [list "${windows_nios2_cmd_shell}" "make" "$all_target" "2>>" "stderr.txt"]
		} elseif {[file exists $linux_nios2_cmd_shell]} {
			set cmd [list "${linux_nios2_cmd_shell}" "make" "$all_target" "2>>" "stderr.txt"]
		} else {
			_error "Cannot locate the Nios II Command Shell.  Nios II SBT must be installed to generate UniPHY IP cores."
		}
		if {$bfm_mode} {
		} else {
			set result [alt_mem_if::util::iptclgen::exec_cmd $cmd]
		}
	}

	

	set dirname "/tmp/qsys_software"
	catch {file mkdir $dirname} temp_result
	set status [catch {exec -- cp -r $tmpdir $dirname} temp_result]

	if {$hps_synthesis_mode} {
		set emif_xml "emif.xml"
		set fh [open [file join $app_dir $emif_xml] w]
		puts $fh "<emif>"
		puts $fh "    <sequencer>"
		foreach key [lsort -dictionary [array names param_array]] {
			puts $fh "        <define name=\"$key\" value=\"$param_array($key)\"/>"
		}
		puts $fh "    </sequencer>"

		puts $fh "    <pll>"
		foreach param [list PLL_MEM_CLK_MULT PLL_MEM_CLK_DIV PLL_MEM_CLK_PHASE_DEG PLL_WRITE_CLK_MULT PLL_WRITE_CLK_DIV PLL_WRITE_CLK_PHASE_DEG] {
			if {[string match {*PHASE*} $param]} {
				set phase_unit 22.5
            set phase [expr {int(fmod((360-[get_parameter_value $param]), 360) / $phase_unit)}]
				puts $fh "        <define name=\"$param\" value=\"$phase\"/>"
			} else {
				if {[string match {*DIV*} $param]} {
					set val [expr [get_parameter_value $param]/2 - 1]
				} else {
					set val [expr [get_parameter_value $param] - 1]
				}
				puts $fh "        <define name=\"$param\" value=\"$val\"/>"
			}
		}
		puts $fh "    </pll>"
		
		puts $fh "    <controller>"
		set controller_list [list \
			PLL_MEM_CLK_FREQ \
			MEM_DQ_WIDTH \
			MEM_IF_DQS_WIDTH \
			DEVICE_DEPTH \
			MEM_CK_WIDTH \
			MEM_IF_ROW_ADDR_WIDTH \
			MEM_IF_COL_ADDR_WIDTH \
			MEM_IF_BANKADDR_WIDTH \
			MEM_IF_DM_PINS_EN \
			MEM_IF_DQSN_EN \
			MEM_MIRROR_ADDRESSING \
			AC_PARITY \
			MEM_BURST_LENGTH \
			ADDR_ORDER \
			USE_HPS_DQS_TRACKING \
			MEM_BT \
			MEM_PD \
			MEM_DRV_STR \
			MEM_RTT_NOM \
			MEM_ASR \
			MEM_SRT \
			MEM_RTT_WR \
			MEM_WTCL_INT \
			MEM_ATCL_INT \
			MEM_TCL \
			MEM_TRRD \
			MEM_TFAW \
			MEM_TRFC \
			MEM_TREFI \
			MEM_TRCD \
			MEM_TRP \
			MEM_TWTR \
			MEM_TWR \
			MEM_TRTP \
			MEM_TRAS \
			MEM_TRC \
			MEM_TMRD_CK \
			CFG_TCCD \
			CFG_WRITE_ODT_CHIP \
			CFG_READ_ODT_CHIP \
		]

		set all_params [get_parameters]
		::alt_mem_if::util::list_array::intersect3 $controller_list $all_params in_list1 in_list2 in_both

		foreach param $in_both {
			puts $fh "        <define name=\"$param\" value=\"[get_parameter_value $param]\"/>"
		}
		puts $fh "    </controller>"
		
		puts $fh "</emif>"
		close $fh

		alt_mem_if::util::iptclgen::advertize_directory {QUARTUS_SYNTH} "sequencer" $sw_dir {} $fileset ".pre" "HPS_ISW"
	}
	
	if { !$do_only_rw_mgr_mc && !($bfm_mode || $hps_mode)} {
		set calc_mem_size [alt_mem_if::util::seq_mem_size::get_max_memory_usage [file join "sequencer" "sequencer.elf"]]

		set mem_size_aligned [align_size $calc_mem_size $alignment $mem_size_margin]

		if {$pre_compile} {
			_dprint 1 "Sequencer software: Returning computed size $calc_mem_size / $mem_size_aligned"
			cd $curdir
			return [list $calc_mem_size $mem_size_aligned]
		} else {
			if { $requested_mem_size != $calc_mem_size } {
				_wprint "Requested mem_size($requested_mem_size) != calc mem_size($calc_mem_size)"
				if { ! [::alt_mem_if::util::qini::cfg_is_on alt_mem_if_ignore_seq_size_mismatch] &&
					[string compare -nocase [get_parameter_value ENABLE_MAX_SIZE_SEQ_MEM] "false"] == 0} {
					_error "Sequencer software: Requested mem_size($requested_mem_size) != calc mem_size($calc_mem_size)"
				} elseif { $requested_mem_size < $calc_mem_size } {
					_error "Sequencer software: requested mem_size($requested_mem_size) < calc mem_size($calc_mem_size)"
				}

			} else {
				_dprint 1 "Sequencer software: Requested/calc mem_size match ($calc_mem_size)"
			}
		}
	}
	
	if { !$do_only_rw_mgr_mc && [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {

		_dprint 1 "Generating header file for core debug data access"
		set objdump_file [file join "sequencer" "sequencer.objdump"] 
		if {[file exists $objdump_file]} {
			_dprint 1 "Parsing $objdump_file"
			
			set found_debug_data_addr 0
			set debug_base_addr 0
			set debug_size 0
			set found_gbl_addr 0
			set gbl_addr 0
			set fp [open $objdump_file r]
			set objdump_lines [split [read $fp] "\n"]
			close $fp
			foreach objdump_line $objdump_lines {
				if {[regexp -nocase -- "^(\[0-9a-f\]+).*\[ \t\]+(\[0-9a-f\]+)\[ \t\]+my_debug_data$" $objdump_line match debug_base_addr debug_size]} {
					_dprint 1 "Core debug data line: $objdump_line"
					_dprint 1 "Base: $debug_base_addr Size: $debug_size"
					if {$found_debug_data_addr} {
						_error "Found multiple addresses for sequencer core debug data structure"
					} else {
						set found_debug_data_addr 1
					}
				}
				if {[regexp -nocase -- "^(\[0-9a-f\]+).*\[ \t\]+\[0-9a-f\]+\[ \t\]+gbl$" $objdump_line match gbl_addr]} {
					_dprint 1 "gbl line: $objdump_line"
					_dprint 1 "gbl_addr: $gbl_addr"
					if {$found_gbl_addr} {
						_error "Found multiple addresses for gbl"
					} else {
						set found_gbl_addr 1
					}
				}
			}
			if {$found_debug_data_addr == 0} {
				_error "Couldn't find address of sequencer core debug data structure"
			}
			if {$found_gbl_addr == 0} {
				_error "Couldn't find address of gbl"
			}
			
			set c_header_defs_file_name "core_debug_defines.h"
			set c_header_file_name "core_debug.h"
			
			set fh [open $c_header_defs_file_name w]
			puts $fh "#ifndef _CORE_DEBUG_DEFINES_H_"
			puts $fh "#define _CORE_DEBUG_DEFINES_H_"
			puts $fh ""
			puts $fh "#define SEQ_CORE_DEBUG_BASE 0x$debug_base_addr"
			foreach key [lsort -dictionary [array names param_array]] {
				puts $fh "#define $key $param_array($key)"
			}
			puts $fh ""
			puts $fh "#include \"$c_header_file_name\""
			puts $fh "#endif /* _CORE_DEBUG_DEFINES_H_ */"
			close $fh

			set tclrpt_header_file [file join "sequencer" "tclrpt.h"]
			if {[catch {file copy -force $tclrpt_header_file $c_header_file_name} err]} {
				_error "Error copying $tclrpt_header_file to $c_header_file_name: $err"
			}

			set cmd_space_size "16" 

			set v_header_file_name "core_debug.sv"
			set fp [open $v_header_file_name w]
			
			puts $fp "package ${prepend_str}_seq_core_debug_pkg;"
			puts $fp "\tparameter SEQ_CORE_DEBUG_BASE = 'h$debug_base_addr;"
			puts $fp "\tparameter SEQ_CORE_DEBUG_SIZE = 'h$debug_size;"
			puts $fp "\tparameter SEQ_CORE_CMD_SIZE = 'h$cmd_space_size;"
			puts $fp "\tparameter SEQ_CORE_CMD_BASE = (SEQ_CORE_DEBUG_BASE + 'h8);"
			puts $fp "\tparameter SEQ_CORE_REQ_CMD = (SEQ_CORE_CMD_BASE + 'h0);"
			puts $fp "\tparameter SEQ_CORE_CMD_STATUS = (SEQ_CORE_CMD_BASE + 'h4);"
			puts $fp "\tparameter SEQ_CORE_CMD_PARAMS = (SEQ_CORE_CMD_BASE + 'h8);"
			puts $fp "\tparameter GBL_ADDR = 'h$gbl_addr;"
			puts $fp "endpackage"
			
			close $fp
			
			alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,SIM_VHDL,EXAMPLE_DESIGN} $c_header_file_name $sw_dir $sw_rel_dir $fileset
			alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,SIM_VHDL,EXAMPLE_DESIGN} $c_header_defs_file_name $sw_dir $sw_rel_dir $fileset
			alt_mem_if::util::iptclgen::advertize_file {QUARTUS_SYNTH,SIM_VERILOG,SIM_VHDL,EXAMPLE_DESIGN} $v_header_file_name $sw_dir $sw_rel_dir $fileset
			
			} else {
				_error "Couldn't find $objdump_file"
			}
	}


	set return_files [list]

	if {!$bfm_mode && !$hps_synthesis_mode} {
		if {!$do_only_rw_mgr_mc} {
			lappend return_files [file join $tmpdir $nios_hex_file_name]
		}
		lappend return_files [file join $tmpdir $ac_rom_init_file_name]
		lappend return_files [file join $tmpdir $inst_rom_init_file_name]
		if {$hps_simulation_mode} {
			lappend return_files [file join $tmpdir "hps.sopcinfo"]
		}
	}

	_wprint "returned files: $return_files"
	
	cd $curdir

	return $return_files
}


proc ::alt_mem_if::gen::uniphy_gen::set_bits { bit_vector index num_bits new_bits } {
	set mask       [expr ((1 << $num_bits) - 1) << $index]
	set new_bits   [expr ($new_bits << $index) & $mask]
	set bit_vector [expr $bit_vector & ~$mask]
	set bit_vector [expr $bit_vector | $new_bits]
	return $bit_vector
}

proc ::alt_mem_if::gen::uniphy_gen::to_binary_string { num num_bits } {
	set binary_str ""
	for {set i 0 } {$i < $num_bits} {incr i} {
		set binary_str "[expr $num & 1]$binary_str"
		set num [expr $num >> 1]
	}
	return $binary_str
}


proc ::alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh {component_name arg_list tmpdir filename {subdir {}}} {

	set cwd [pwd]

	cd [file join $tmpdir $subdir]

	set qdir $::env(QUARTUS_ROOTDIR)
	set cmd "${qdir}/sopc_builder/bin/ip-generate"

	set fh [open $filename w]

	puts $fh "set arg_list \[list\]"
	foreach item $arg_list {
		puts $fh "lappend arg_list \"$item\""
	}

	puts $fh "catch \{ eval \[concat \[list exec \"$cmd\" --component-name=$component_name\] \$arg_list\] \} temp"
	puts $fh "puts \$temp"
	close $fh

	set quartus_output [alt_mem_if::util::iptclgen::run_tclsh_script $filename]
        _dprint 1 "Sequencer make output: $quartus_output"

	if {[::alt_mem_if::util::qini::qini_value "debug_msg_level"] == 0} {
		catch {file delete -force -- $filename} temp_result
	}

	cd $cwd

	return $quartus_output
}


proc ::alt_mem_if::gen::uniphy_gen::generate_example_design_fileset {protocol name} {

	if {[string compare -nocase $protocol "DDR3"] == 0} {
		set component_name_prefix "alt_mem_if_ddr3"
	} elseif {[string compare -nocase $protocol "DDR2"] == 0} {
		set component_name_prefix "alt_mem_if_ddr2"
	} elseif {[string compare -nocase $protocol "LPDDR2"] == 0} {
		set component_name_prefix "alt_mem_if_lpddr2"
	} elseif {[string compare -nocase $protocol "LPDDR1"] == 0} {
		set component_name_prefix "alt_mem_if_lpddr"
	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
		set component_name_prefix "alt_mem_if_qdrii"
	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0} {
		set component_name_prefix "alt_mem_if_rldramii"
	} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
		set component_name_prefix "alt_mem_if_rldram3"
	} elseif {[string compare -nocase $protocol "DDRIISRAM"] == 0} {
		set component_name_prefix "alt_mem_if_ddrii_sram"
	} elseif {[string compare -nocase $protocol "HPS"] == 0} {
		set component_name_prefix "alt_mem_if_hps"
		set protocol [get_parameter_value HPS_PROTOCOL]
	} else {
		_error "Invalid protocol specification"
	}

	set variant_name $name

	set example_sim_name "${variant_name}_example_sim"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"

	_iprint "Generating simulation example design"
	cd $tmpdir
	set simdir_name "simulation"
	file mkdir $simdir_name
	set simdir [file join $tmpdir $simdir_name]
	cd $simdir
	

	set arg_list [list]
	lappend arg_list "--system-info=DEVICE_FAMILY=[string toupper [::alt_mem_if::gui::system_info::get_device_family]]"
	lappend arg_list "--output-name=\$\{variant_name\}"
	lappend arg_list "--output-dir=\$\{hdl_language\}"
	lappend arg_list "--report-file=spd:\[file join \$\{hdl_language\} \$\{variant_name\}.spd\]"
	lappend arg_list "--component-param=TG_NUM_DRIVER_LOOP=1"

	foreach param [lsort [get_parameters]] {
		set param_value [get_parameter_value $param]
		if {[string compare -nocase [get_parameter_property $param TYPE] "string_list"] == 0 || 
			[string compare -nocase [get_parameter_property $param TYPE] "integer_list"] == 0 } {
			regsub -all { } $param_value {,} param_value
		}
		if {[get_parameter_property $param DERIVED] == 0} {
			lappend arg_list "--component-param=$param=$param_value"
		}
	}

	set generate_eds_verilog_script_filename "generate_sim_verilog_example_design.tcl"
	set generate_eds_vhdl_script_filename "generate_sim_vhdl_example_design.tcl"
	foreach lang [list verilog vhdl] {
		if {[string compare -nocase $lang "VHDL"] == 0} {
			set generate_eds_script_filename $generate_eds_vhdl_script_filename
		} else {
			set generate_eds_script_filename $generate_eds_verilog_script_filename
		}
		set fh [open $generate_eds_script_filename w]
		puts $fh "if \{\[is_project_open\]\} \{"
		puts $fh "\tset project_name \$::quartus(project)"
		puts $fh "\tif \{\[string compare \$project_name \"generate_sim_example_design\"\] != 0\} \{"
		puts $fh "\t\tpost_message -type error \"Invalid project \\\"\$project_name\\\"\""
		puts $fh "\t\tpost_message -type error \"In order to generate the simulation example design,\""
		puts $fh "\t\tpost_message -type error \"please close the current project \\\"\$project_name\\\"\""
		puts $fh "\t\tpost_message -type error \"and open the project \\\"generate_sim_example_design\\\"\""
		puts $fh "\t\tpost_message -type error \"in the directory ${variant_name}_example_design/simulation/\""
		puts $fh "\t\treturn 1"
		puts $fh "\t\}"
		puts $fh "\}"
		puts $fh "set variant_name ${example_sim_name}"
		puts $fh "set arg_list \[list\]"
		if {[string compare -nocase $lang "VHDL"] == 0} {
			puts $fh "puts \"Generating VHDL example design\""
			puts $fh "set hdl_language vhdl"
			puts $fh "set hdl_ext vhd"
			puts $fh "lappend arg_list \"--file-set=SIM_VHDL\""
		} else {
			puts $fh "puts \"Generating Verilog example design\""
			puts $fh "set hdl_language verilog"
			puts $fh "set hdl_ext v"
			puts $fh "lappend arg_list \"--file-set=SIM_VERILOG\""
		}

		foreach item $arg_list {
			puts $fh "lappend arg_list \"$item\""
		}
		set qdir $::env(QUARTUS_ROOTDIR)
		
		puts $fh "set qdir \$::env\(QUARTUS_ROOTDIR\)"
		puts $fh "catch \{eval \[concat \[list exec \"[file join \$qdir\/ sopc_builder bin ip-generate]\" --component-name=${component_name_prefix}_tg_eds\] \$arg_list\]\} temp"
		puts $fh "puts \$temp"
		puts $fh ""
		puts $fh "set spd_filename \[file join \$hdl_language \$\{variant_name\}.spd\]"
		puts $fh "catch \{eval \[list exec \"[file join \$qdir\/ sopc_builder bin ip-make-simscript]\" --spd=\$\{spd_filename\} --compile-to-work --output-directory=\$\{hdl_language\}\]\} temp"
		puts $fh "puts \$temp"
		puts $fh ""
		puts $fh "set scripts \[list \[file join \$hdl_language synopsys vcs vcs_setup.sh\] \[file join \$hdl_language synopsys vcsmx vcsmx_setup.sh\] \[file join \$hdl_language cadence ncsim_setup.sh\]\]"
		puts $fh "foreach scriptname \$scripts \{"
		puts $fh "\tif \{\[catch \{set fh \[open \$scriptname r\]\} temp\]\} \{"
		puts $fh "\t\} else \{"
		puts $fh "\t\tset lines \[split \[read \$fh\] \"\\n\"\]"
		puts $fh "\t\tclose \$fh"
		puts $fh "\t\tif \{\[catch \{set fh \[open \$scriptname w\]\} temp\]\} \{"
		puts $fh "\t\t\tpost_message -type warning \"\$temp\""
		puts $fh "\t\t\} else \{"
		puts $fh "\t\t\tforeach line \$lines \{"
		puts $fh "\t\t\t\tif \{\[regexp -- \{USER_DEFINED_SIM_OPTIONS\\s*=.*\\+vcs\\+finish\\+100\} \$line\]\} \{"
		puts $fh "\t\t\t\t\tregsub -- \{\\+vcs\\+finish\\+100\} \$line \{\} line"
		puts $fh "\t\t\t\t\} elseif \{\[regexp -- \{USER_DEFINED_SIM_OPTIONS\\s*=.*-input \\\\\\\"@run 100; exit\\\\\\\"\} \$line\]\} \{"
		puts $fh "\t\t\t\t\tregsub -- \{-input \\\\\\\"@run 100; exit\\\\\\\"\} \$line \{\} line"
		puts $fh "\t\t\t\t\}"
		puts $fh "\t\t\t\tputs \$fh \$line"
		puts $fh "\t\t\t\}"
		puts $fh "\t\t\tclose \$fh"
		puts $fh "\t\t\}"
		puts $fh "\t\}"
		puts $fh "\}"

		if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
			if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
				puts $fh "set eds_top_filename \[file join \$hdl_language \"\$\{variant_name\}.\$\{hdl_ext\}\"\]"
				puts $fh "set eds_top_fh \[open \"\$eds_top_filename\" r\]"
				puts $fh "set eds_top_lines \[split \[read \$eds_top_fh\] \"\\n\"\]"
				puts $fh "close \$eds_top_fh"
				puts $fh "set eds_top_fh \[open \"\$eds_top_filename\" w\]"
				puts $fh "foreach eds_top_line \$eds_top_lines \{"
				puts $fh "\tif \{\[regexp -- \{INIT_FILE.*dut_e0_if._s0_sequencer_mem\} \$eds_top_line\] == 1\} \{"
				puts $fh "\t\tregsub \{dut_e0_if\} \$eds_top_line \"\$\{variant_name\}_e0_if\" eds_top_line"
				puts $fh "\t\}"
				puts $fh "\tputs \$eds_top_fh \$eds_top_line"
				puts $fh "\}"
				puts $fh "close \$eds_top_fh"
			}
		}
		close $fh
	}

	catch {file mkdir [file join verilog mentor]} temp_result
	catch {file mkdir [file join vhdl mentor]} temp_result
	set fh [open [file join verilog mentor "run.do"] w]
	puts $fh "if \{\[file exists msim_setup.tcl\]\} \{"
	puts $fh "\tsource msim_setup.tcl"
	puts $fh "\tdev_com"
	puts $fh "\tcom"
	puts $fh "\t\043 the \"elab_debug\" macro avoids optimizations which preserves signals so that they may be added to the wave viewer"
	puts $fh "\telab_debug"
	puts $fh "\tadd wave \"${example_sim_name}/*\""
	puts $fh "\trun -all"
	puts $fh "\} else \{"
	puts $fh "\terror \"The msim_setup.tcl script does not exist. Please generate the example design RTL and simulation scripts. See ../../README.txt for help.\""
	puts $fh "\}"
	close $fh
	file copy -force [file join verilog mentor "run.do"] [file join vhdl mentor "run.do"]

	set create_project_script_name [file join [pwd] "generate_sim_example_design.tcl"]
	set fh [open $create_project_script_name w]
	set project_name "generate_sim_example_design"
	puts $fh "project_new -overwrite -family [::alt_mem_if::gui::system_info::get_device_family] $project_name"
	puts $fh "project_open $project_name"
	puts $fh "set_global_assignment -name TCL_SCRIPT_FILE $generate_eds_verilog_script_filename"
	puts $fh "set_global_assignment -name TCL_SCRIPT_FILE $generate_eds_vhdl_script_filename"
	puts $fh "export_assignments"
	puts $fh "project_close"
	close $fh
	alt_mem_if::util::iptclgen::run_quartus_tcl_script $create_project_script_name
	catch {file delete -force "db"} temp_result
	catch {file delete -force -- $create_project_script_name} temp_result

	set fh [open "README.txt" w]
	puts $fh ""
	puts $fh ""
	puts $fh "The simulation example design is available for both Verilog and VHDL."
	puts $fh ""
	puts $fh ""
	puts $fh ""
	puts $fh "To generate the Verilog example design, open the Quartus project \"${project_name}.qpf\" and"
	puts $fh "select Tools -> Tcl Scripts... -> ${generate_eds_verilog_script_filename} and click \"Run\"."
	puts $fh "Alternatively, you can run \"quartus_sh -t ${generate_eds_verilog_script_filename}\""
	puts $fh "at a Windows or Linux command prompt."
	puts $fh ""
	puts $fh "The generated files will be found in the subdirectory \"verilog\"."
	puts $fh ""
	puts $fh ""
	puts $fh ""
	puts $fh "To generate the VHDL example design, open the Quartus project \"${project_name}.qpf\" and"
	puts $fh "select Tools -> Tcl Scripts... -> ${generate_eds_vhdl_script_filename} and click \"Run\"."
	puts $fh "Alternatively, you can run \"quartus_sh -t ${generate_eds_vhdl_script_filename}\""
	puts $fh "at a Windows or Linux command prompt."
	puts $fh ""
	puts $fh "The generated files will be found in the subdirectory \"vhdl\"."
	puts $fh ""
	puts $fh ""
	puts $fh ""
	puts $fh "To simulate the example design using Modelsim AE/SE:"
	puts $fh ""
	puts $fh "1) Move into the directory ./verilog/mentor or ./vhdl/mentor"
	puts $fh "2) Start Modelsim and run the \"run.do\" script: in Modelsim, enter \"do run.do\"."
	puts $fh ""
	close $fh

	_iprint "Generating synthesizable example design"

	set example_name "${variant_name}_example"

	cd $tmpdir
	set synthdir_name "example_project"
	file mkdir $synthdir_name
	set synthdir [file join $tmpdir $synthdir_name]
	cd $synthdir


	set arg_list [list]
	lappend arg_list "--system-info=DEVICE_FAMILY=[string toupper [::alt_mem_if::gui::system_info::get_device_family]]"
	lappend arg_list "--file-set=QUARTUS_SYNTH"
	lappend arg_list "--report-file=csv:${example_name}.csv"
	lappend arg_list "--report-file=qip:${example_name}.qip"
	lappend arg_list "--output-name=${example_name}"
	lappend arg_list "--component-param=TG_NUM_DRIVER_LOOP=1"

	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		lappend arg_list "--component-param=EXPORT_AFI_CLK_RESET=true"
	}

	foreach param [lsort [get_parameters]] {
		set param_value [get_parameter_value $param]
		if {[string compare -nocase [get_parameter_property $param TYPE] "string_list"] == 0 || 
			[string compare -nocase [get_parameter_property $param TYPE] "integer_list"] == 0 } {
			regsub -all { } $param_value {,} param_value
		}
		if {[get_parameter_property $param DERIVED] == 0} {
			lappend arg_list "--component-param=$param=$param_value"
		}
	}

	set component_name "${component_name_prefix}_tg_ed"
	alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh $component_name $arg_list [pwd] "generate_ed.tcl"


	if {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0} {
		if {[string compare -nocase $protocol "QDRII"] == 0 ||
		    [string compare -nocase $protocol "RLDRAMII"] == 0 ||
		    [string compare -nocase $protocol "RLDRAM3"] == 0 ||
		    [string compare -nocase $protocol "DDRIISRAM"] == 0} {

			if {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "master"] == 0} {
				set oct_master_corename "${example_name}_if0"
				set oct_slave_corename "${example_name}_if1"
			} elseif {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] == 0} {
				set oct_master_corename "${example_name}_if1"
				set oct_slave_corename "${example_name}_if0"
			}

			set slave_pin_filename [file join $example_name submodules "${oct_slave_corename}_p0_pin_assignments.tcl"]
			set slave_pin_fh [open $slave_pin_filename r]
			set slave_pin_lines [split [read $slave_pin_fh] "\n"]
			close $slave_pin_fh

			set slave_pin_fh [open $slave_pin_filename w]
			foreach slave_pin_line $slave_pin_lines {
				if {[regexp -- {set ::master_corename} $slave_pin_line] == 1} {
					_dprint 1 "Substituting OCT master core name for _MASTER_CORE_"
					regsub {_MASTER_CORE_} $slave_pin_line "$oct_master_corename" slave_pin_line
				}
				puts $slave_pin_fh $slave_pin_line
			}
			close $slave_pin_fh

		}
	}


	::alt_mem_if::gen::uniphy_gen::generate_example_quartus_project $example_name $example_name [list] [list]

	cd $tmpdir
	alt_mem_if::util::iptclgen::advertize_directory EXAMPLE_DESIGN {} $tmpdir {} EXAMPLE_DESIGN

}


proc ::alt_mem_if::gen::uniphy_gen::generate_example_quartus_project {name top_level_name sim_tb_files_list design_files_list} {
	
	set project_name "${name}"
	set create_project_script_name [file join [pwd] "create_project.tcl"]
	set FH [open $create_project_script_name w]
	puts $FH "project_new -overwrite -family [::alt_mem_if::gui::system_info::get_device_family] $project_name"
	puts $FH "project_open $project_name"

	set example_part "AUTO"
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX"] == 0} {
		set example_part "EP2AGX45DF29C4"
	}
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0} {
		set example_part "EP4SGX70HF35C2"
	}
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0} {
		set example_part "EP3SE50F780C2"
	}
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0} {
		set example_part "EP2AGZ225FF35C3"
	}

	puts $FH "set_global_assignment -name DEVICE $example_part"

	puts $FH "set_global_assignment -name TOP_LEVEL_ENTITY $top_level_name"

	puts $FH "set_global_assignment -name TEXT_FILE ../params.txt"

	if {[llength $sim_tb_files_list] == 0} {

		puts $FH "set_global_assignment -name QIP_FILE ${name}.qip"

	} else {

		foreach design_file_item $design_files_list {
			set design_file [lindex $design_file_item 0]
			if {[regexp -- {.*\.sv[ ]*$} $design_file]} {
				set hdl_type "SYSTEMVERILOG_FILE"
				puts $FH "set_global_assignment -name $hdl_type $design_file"
			} elseif {[regexp -- {.*\.v[ ]*$} $design_file]} {
				set hdl_type "VERILOG_FILE"
				puts $FH "set_global_assignment -name $hdl_type $design_file"
			} elseif {[regexp -- {.*\.hex[ ]*$} $design_file]} {
				set hdl_type "SOURCE_FILE"
				puts $FH "set_global_assignment -name $hdl_type $design_file"
			} elseif {[regexp -- {.*\.mif[ ]*$} $design_file]} {
				set hdl_type "SOURCE_FILE"
				puts $FH "set_global_assignment -name $hdl_type $design_file"
			}
		}

		foreach tb_file_item $sim_tb_files_list {
			set tb_file [lindex $tb_file_item 0]
			set tb_file_type [lindex $tb_file_item 1]
			puts $FH "set_global_assignment -name EDA_TEST_BENCH_FILE $tb_file -section_id  uniphy_rtl_simulation -hdl_version SystemVerilog_2005"
		}
	}

	if {[string compare -nocase [alt_mem_if::util::iptclgen::get_synthesis_language] "VERILOG"] == 0} {
		puts $FH "set_global_assignment -name EDA_SIMULATION_TOOL \"ModelSim-Altera (Verilog)\""
		puts $FH "set_global_assignment -name EDA_TIME_SCALE \"1 ps\" -section_id eda_simulation"
		puts $FH "set_global_assignment -name EDA_OUTPUT_DATA_FORMAT \"VERILOG HDL\" -section_id eda_simulation"
	} else {
		puts $FH "set_global_assignment -name EDA_SIMULATION_TOOL \"ModelSim-Altera (VHDL)\""
		puts $FH "set_global_assignment -name EDA_TIME_SCALE \"1 ps\" -section_id eda_simulation"
		puts $FH "set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation"
	}

	puts $FH "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation"
	puts $FH "set_global_assignment -name EDA_TEST_BENCH_NAME uniphy_rtl_simulation -section_id eda_simulation"
	puts $FH "set_global_assignment -name EDA_DESIGN_INSTANCE_NAME dut -section_id uniphy_rtl_simulation"
	puts $FH "set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME ${name}_tb -section_id uniphy_rtl_simulation"

	puts $FH "set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH uniphy_rtl_simulation -section_id eda_simulation"

	puts $FH "set_global_assignment -name EDA_MAP_ILLEGAL_CHARACTERS ON -section_id eda_simulation"
	puts $FH "set_global_assignment -name EDA_ENABLE_GLITCH_FILTERING ON -section_id eda_simulation"
	puts $FH "set_global_assignment -name EDA_WRITE_NODES_FOR_POWER_ESTIMATION ALL_NODES -section_id eda_simulation"

	puts $FH "export_assignments"
	puts $FH "project_close"
	close $FH
	_iprint "Creating Quartus project"
	alt_mem_if::util::iptclgen::run_quartus_tcl_script $create_project_script_name
	catch {file delete -force "db"} temp_result
	catch {file delete -force -- $create_project_script_name} temp_result

	set FH [open ${project_name}.qsf r]
	set FH_NEW [open ${project_name}_temp.qsf w]
	while {![eof $FH]} {
    	puts $FH_NEW [gets $FH]
	}
	close $FH
	puts $FH_NEW "\043 Enable the following line when using Modelsim in order to add some useful UniPHY signals to the wave viewer automatically"
	puts $FH_NEW "\043set_global_assignment -name EDA_NATIVELINK_SIMULATION_SETUP_SCRIPT ${name}_wave.do -section_id eda_simulation"
	close $FH_NEW
	catch {file rename -force -- ${project_name}_temp.qsf ${project_name}.qsf} temp_result

}


proc ::alt_mem_if::gen::uniphy_gen::generate_sequencer_files {name protocol tmpdir fileset} {

	set qsys_sequencer_files_list [alt_mem_if::gen::uniphy_gen::generate_qsys_sequencer "${name}" $protocol $tmpdir $fileset {}]

	set file_list [list]
	foreach file_name $qsys_sequencer_files_list {
		if {[regexp -nocase {altera_pli_streaming} $file_name match] == 0} {
			lappend file_list [file join $tmpdir $file_name]
		}
	}
	
	return $file_list
	
}


proc ::alt_mem_if::gen::uniphy_gen::print_generation_done_message {name protocol} {
	_iprint "" 1
	_iprint "*****************************" 1
	_iprint "" 1
	_iprint "Remember to run the ${name}_pin_assignments.tcl" 1
	_iprint "script after running Synthesis and before Fitting." 1
	_iprint "" 1
	_iprint "*****************************" 1
	_iprint "" 1
}

proc ::alt_mem_if::gen::uniphy_gen::instantiate_abstract_ram { CONTROLLER exported_avl_if afi_clk_source afi_reset_source {rename_interfaces 1}} {
	set mem_init_filename [get_parameter_value ABS_RAM_MEM_INIT_FILENAME]
	
	if {[string compare $exported_avl_if "avl"] == 0} {
		set ABSTRACT_RAM r0
	} else {
		set ABSTRACT_RAM "r_${CONTROLLER}"
	}

	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		set av_address_width [expr [get_parameter_value AVL_ADDR_WIDTH] - 1]
		set av_data_width [expr [get_parameter_value AVL_DATA_WIDTH] / 2]
	} else {
		set av_address_width [get_parameter_value AVL_ADDR_WIDTH]
		set av_data_width [get_parameter_value AVL_DATA_WIDTH]
	}

	add_instance $ABSTRACT_RAM altera_mem_if_avalon_dram_model
	
	set_instance_parameter $ABSTRACT_RAM AV_BURSTCOUNT_W [get_parameter_value AVL_SIZE_WIDTH]
	set_instance_parameter $ABSTRACT_RAM AV_DATA_W $av_data_width
	set_instance_parameter $ABSTRACT_RAM AV_ADDRESS_W $av_address_width
	set_instance_parameter $ABSTRACT_RAM AV_SYMBOL_W [get_parameter_value AVL_SYMBOL_WIDTH]
	set_instance_parameter $ABSTRACT_RAM USE_BYTE_ENABLE [get_parameter_value BYTE_ENABLE]
	set_instance_parameter $ABSTRACT_RAM USE_BURST_BEGIN true
	set_instance_parameter $ABSTRACT_RAM MEM_INIT_FILE "${mem_init_filename}.dat"
	set_instance_parameter $ABSTRACT_RAM MAX_READ_TRANSACTIONS [get_instance_interface_property ${CONTROLLER} avl maximumPendingReadTransactions]

	set_module_assignment postgeneration.simulation.init_file.param_name "ABS_RAM_MEM_INIT_FILENAME"
	set_module_assignment postgeneration.simulation.init_file.type "MEM_INIT"
	set_module_assignment embeddedsw.memoryInfo.GENERATE_DAT_SYM 1
	set_module_assignment embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR SIM_DIR
	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_FILENAME [ get_parameter_value ABS_RAM_MEM_INIT_FILENAME ]

	add_connection "${afi_clk_source}/${ABSTRACT_RAM}.avl_clock"
	add_connection "${afi_reset_source}/${ABSTRACT_RAM}.avl_reset"

	add_connection "${ABSTRACT_RAM}.avl_m/${CONTROLLER}.avl"
	
	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {

		set_interface_property $exported_avl_if export_of "${ABSTRACT_RAM}.avl_s"
		set port_map [list \
						  ${exported_avl_if}_ready avs_waitrequest_n \
						  ${exported_avl_if}_read_req avs_read \
						  ${exported_avl_if}_write_req avs_write \
						  ${exported_avl_if}_addr avs_address \
						  ${exported_avl_if}_wdata avs_writedata \
						  ${exported_avl_if}_size avs_burstcount \
						  ${exported_avl_if}_rdata avs_readdata \
						  ${exported_avl_if}_rdata_valid avs_readdatavalid \
						  ${exported_avl_if}_burstbegin avs_burstbegin \
						  ${exported_avl_if}_be avs_byteenable \
						 ]
		set_interface_property ${exported_avl_if} PORT_NAME_MAP $port_map
	}
}

proc ::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor {CONTROLLER exported_avl_if afi_clk_source afi_reset_source {rename_interfaces 1}} {

	if {[string compare $exported_avl_if "avl"] == 0} {
		set EFF_MON e0
		set BRIDGE b0
	} else {
		set EFF_MON "eff_${exported_avl_if}"
		set BRIDGE "b_${exported_avl_if}"
	}

	add_instance $EFF_MON altera_avalon_em_pc
	
	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		set av_address_width [expr [get_parameter_value AVL_ADDR_WIDTH] - 1]
		set av_data_width [expr [get_parameter_value AVL_DATA_WIDTH] / 2]
	} else {
		set av_address_width [get_parameter_value AVL_ADDR_WIDTH]
		set av_data_width [get_parameter_value AVL_DATA_WIDTH]
	}
	set av_symbol_width [get_parameter_value AVL_SYMBOL_WIDTH]

	set av_num_symbols [expr {$av_data_width / $av_symbol_width}]
	set av_pow2_num_symbols [expr {pow(2, int(ceil(log($av_num_symbols) / log(2))))}]
	set av_pow2_data_width [expr {$av_symbol_width * $av_pow2_num_symbols}]

	set_instance_parameter $EFF_MON EMPC_AV_BURSTCOUNT_WIDTH [get_parameter_value AVL_SIZE_WIDTH]
	set_instance_parameter $EFF_MON EMPC_AV_DATA_WIDTH $av_data_width
	set_instance_parameter $EFF_MON EMPC_AV_ADDRESS_WIDTH $av_address_width
	set_instance_parameter $EFF_MON EMPC_AV_SYMBOL_WIDTH $av_symbol_width
	set_instance_parameter $EFF_MON EMPC_AV_POW2_DATA_WIDTH $av_pow2_data_width
	set_instance_parameter $EFF_MON EMPC_CSR_CONNECTION "INTERNAL_JTAG"
	set_instance_parameter $EFF_MON EMPC_MAX_READ_TRANSACTIONS [get_instance_interface_property ${CONTROLLER} $exported_avl_if maximumPendingReadTransactions]
	
	add_instance $BRIDGE altera_mem_if_simple_avalon_mm_bridge
	
	if {$av_data_width != $av_pow2_data_width} {
		set_instance_parameter $BRIDGE SLAVE_DATA_WIDTH $av_data_width
		set_instance_parameter $BRIDGE MASTER_DATA_WIDTH $av_pow2_data_width
	} else {
		set_instance_parameter $BRIDGE DATA_WIDTH $av_data_width
	}
	set_instance_parameter $BRIDGE SYMBOL_WIDTH $av_symbol_width
	set_instance_parameter $BRIDGE ADDRESS_WIDTH $av_address_width 
	set_instance_parameter $BRIDGE SLAVE_USE_WAITREQUEST_N 1
	set_instance_parameter $BRIDGE USE_BURSTBEGIN 1
	set_instance_parameter $BRIDGE USE_BURSTCOUNT 1
	set_instance_parameter $BRIDGE USE_BYTEENABLE 1
	set_instance_parameter $BRIDGE USE_READDATAVALID 1
    set_instance_parameter $BRIDGE ADDRESS_UNITS "WORDS"
	set_instance_parameter $BRIDGE BURSTCOUNT_WIDTH [get_parameter_value AVL_SIZE_WIDTH]
	set_instance_parameter $BRIDGE MAX_PENDING_READ_TRANSACTIONS [get_instance_interface_property ${CONTROLLER} $exported_avl_if maximumPendingReadTransactions]

	add_connection "${afi_clk_source}/${EFF_MON}.avl_clk"
	add_connection "${afi_reset_source}/${EFF_MON}.avl_reset_n"

	add_connection "${afi_clk_source}/${BRIDGE}.clk"
	add_connection "${afi_reset_source}/${BRIDGE}.reset"

	add_connection "${BRIDGE}.m0/${EFF_MON}.avl_in"
	add_connection "${EFF_MON}.avl_out/${CONTROLLER}.${exported_avl_if}"
	
	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
		set_interface_property $exported_avl_if export_of "${BRIDGE}.s0"
		set port_map [list \
						  ${exported_avl_if}_ready s0_waitrequest_n \
						  ${exported_avl_if}_read_req s0_read \
						  ${exported_avl_if}_write_req s0_write \
						  ${exported_avl_if}_addr s0_address \
						  ${exported_avl_if}_wdata s0_writedata \
						  ${exported_avl_if}_size s0_burstcount \
						  ${exported_avl_if}_rdata s0_readdata \
						  ${exported_avl_if}_rdata_valid s0_readdatavalid \
						  ${exported_avl_if}_be s0_byteenable \
						  ${exported_avl_if}_burstbegin s0_beginbursttransfer \
						 ]
		set_interface_property $exported_avl_if PORT_NAME_MAP $port_map
		set_interface_property $exported_avl_if addressUnits "WORDS"
	}
}

proc ::alt_mem_if::gen::uniphy_gen::instantiate_qdrii_controller {CONTROLLER afi_clk_source afi_reset_source {rename_interfaces 1}} {

	add_instance $CONTROLLER altera_mem_if_qdrii_controller
	foreach param_name [get_instance_parameters $CONTROLLER] {
		set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $CONTROLLER

	set_instance_parameter $CONTROLLER DISABLE_CHILD_MESSAGING true

	add_connection "${afi_clk_source}/${CONTROLLER}.afi_clk"
	add_connection "${afi_reset_source}/${CONTROLLER}.afi_reset"

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl_w avalon end
			add_interface avl_r avalon end
		} else {
			add_interface avl_w conduit end
			add_interface avl_r conduit end
		}
	
		set_interface_property avl_w export_of "${CONTROLLER}.avl_w"
		set_interface_property avl_r export_of "${CONTROLLER}.avl_r"
		if {$rename_interfaces} {
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl_w avl_w
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl_r avl_r
		}
	}

}


proc ::alt_mem_if::gen::uniphy_gen::instantiate_ddrii_sram_controller {CONTROLLER afi_clk_source afi_reset_source {rename_interfaces 1}} {

	add_instance $CONTROLLER altera_mem_if_ddrii_sram_controller
	foreach param_name [get_instance_parameters $CONTROLLER] {
		set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $CONTROLLER

	set_instance_parameter $CONTROLLER DISABLE_CHILD_MESSAGING true

	add_connection "${afi_clk_source}/${CONTROLLER}.afi_clk"
	add_connection "${afi_reset_source}/${CONTROLLER}.afi_reset"

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl avalon end
		} else {
			add_interface avl conduit end
		}
	
		set_interface_property avl export_of "${CONTROLLER}.avl"
		if {$rename_interfaces} {
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl avl
		}
	}

}


proc ::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller {protocol CONTROLLER afi_clk_source afi_reset_source {rename_interfaces 1}} {

	if {[string compare -nocase $protocol "RLDRAMII"] == 0} {
	add_instance $CONTROLLER altera_mem_if_rldramii_controller
	} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
		add_instance $CONTROLLER altera_mem_if_rldram3_afi_driver
	}
		
	foreach param_name [get_instance_parameters $CONTROLLER] {
		set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $CONTROLLER

	set_instance_parameter $CONTROLLER DISABLE_CHILD_MESSAGING true

	add_connection "${afi_clk_source}/${CONTROLLER}.afi_clk"
	add_connection "${afi_reset_source}/${CONTROLLER}.afi_reset"

	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
		if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
			add_interface avl avalon end
		} else {
			add_interface avl conduit end
		}
	}
	
	if {[string compare -nocase $protocol "RLDRAMII"] == 0 && [string compare -nocase [get_parameter_value ENABLE_ABSTRACT_RAM] "true"] == 0} {
		::alt_mem_if::gen::uniphy_gen::instantiate_abstract_ram $CONTROLLER avl $afi_clk_source $afi_reset_source $rename_interfaces
		
	} else {

		if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0} {

			::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor $CONTROLLER avl $afi_clk_source $afi_reset_source $rename_interfaces

		} else {

			if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
				set_interface_property avl export_of "${CONTROLLER}.avl"
				if {$rename_interfaces} {
					alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl avl
				}
			}

		}

	}

}


proc ::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller {protocol CONTROLLER afi_clk_source afi_half_clk_source afi_reset_source {rename_interfaces 1} {hard_emif 0}} {

	set use_hard_emif 0
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0 || $hard_emif} {
		set use_hard_emif 1
	}

	if {[string compare -nocase [get_parameter_value NEXTGEN] "false"] == 0} {
		add_instance $CONTROLLER altera_mem_if_${protocol}_controller
	} else {
		if {$use_hard_emif} {
			add_instance $CONTROLLER altera_mem_if_${protocol}_hard_memory_controller
		} else {
			add_instance $CONTROLLER altera_mem_if_nextgen_${protocol}_controller
		}
	}
	foreach param_name [get_instance_parameters $CONTROLLER] {
		set_instance_parameter $CONTROLLER $param_name [get_parameter_value $param_name]
	}
	
	if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
		set_instance_parameter $CONTROLLER PINGPONGPHY_EN false

		set_instance_parameter $CONTROLLER FORCE_DQS_TRACKING "DISABLED"
	} 
	
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $CONTROLLER
	
	set_instance_parameter $CONTROLLER DISABLE_CHILD_MESSAGING true

	set_instance_parameter $CONTROLLER HARD_EMIF $use_hard_emif

	add_connection "${afi_clk_source}/${CONTROLLER}.afi_clk"
	add_connection "${afi_half_clk_source}/${CONTROLLER}.afi_half_clk"
	add_connection "${afi_reset_source}/${CONTROLLER}.afi_reset"

	set_module_assignment embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH [get_parameter_value AVL_DATA_WIDTH]

	set exported_avl_if avl
	if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
		set exported_avl_if "avl_${CONTROLLER}"
	}

	if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0 &&
		[string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "false"] == 0} {

		add_interface native_st conduit end
		set_interface_property native_st export_of "${CONTROLLER}.native_st"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER native_st native_st
		}

	} else {

		if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
			if {$use_hard_emif} {
				for {set port_id 0} {$port_id != [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} {
					if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
						add_interface avl_${port_id} avalon end
					} else {
						add_interface avl_${port_id} conduit end
					}
				}
			} else {
				if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
					if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
						add_interface avl_${CONTROLLER} avalon end
						if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0} {
							::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor $CONTROLLER "avl_${CONTROLLER}" $afi_clk_source $afi_reset_source $rename_interfaces
						}
					} else { 
						add_interface avl avalon end
						if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0} {
							::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor $CONTROLLER avl $afi_clk_source $afi_reset_source $rename_interfaces
						}
					}
				} else {
					if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
						add_interface avl_${CONTROLLER} conduit end
						if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0} {
							::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor $CONTROLLER "avl_${CONTROLLER}" $afi_clk_source $afi_reset_source $rename_interfaces
						}
					} else { 
						add_interface avl conduit end
						if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0} {
							::alt_mem_if::gen::uniphy_gen::instantiate_efficiency_monitor $CONTROLLER avl $afi_clk_source $afi_reset_source $rename_interfaces
					}
				}
			}
		}
		}

		if {[string compare -nocase [get_parameter_value ENABLE_ABSTRACT_RAM] "true"] == 0} {

			::alt_mem_if::gen::uniphy_gen::instantiate_abstract_ram $CONTROLLER $exported_avl_if $afi_clk_source $afi_reset_source $rename_interfaces
			
		} else {
			if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "false"] == 0} {
				if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
					if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0 &&
					    [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] != 0 &&
					    [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] != 0} {
					} elseif {$use_hard_emif} {
							for {set port_id 0} {$port_id != [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} {
							if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
								set modified_port_id [get_parameter_value AV_PORT_${port_id}_CONNECT_TO_CV_PORT]
								set_interface_property avl_${port_id} export_of "${CONTROLLER}.avl_${modified_port_id}"
								if {$rename_interfaces} {
									::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl_${modified_port_id} avl_${port_id} $modified_port_id $port_id
								}
							} else {
								set_interface_property avl_${port_id} export_of "${CONTROLLER}.avl_${port_id}"
								if {$rename_interfaces} {
									::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl_${port_id} avl_${port_id}
								}
							}
						}
					} else {
						set exported_avl_if avl
						if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
							set_interface_property avl_${CONTROLLER} export_of "${CONTROLLER}.avl"
							set exported_avl_if "avl_${CONTROLLER}"

							set port_map [list \
											  ${exported_avl_if}_ready avl_ready \
											  ${exported_avl_if}_read_req avl_read_req \
											  ${exported_avl_if}_write_req avl_write_req \
											  ${exported_avl_if}_addr avl_addr \
											  ${exported_avl_if}_wdata avl_wdata \
											  ${exported_avl_if}_size avl_size \
											  ${exported_avl_if}_rdata avl_rdata \
											  ${exported_avl_if}_rdata_valid avl_rdata_valid \
											  ${exported_avl_if}_burstbegin avl_burstbegin \
											  ${exported_avl_if}_be avl_be \
											 ]
							set_interface_property $exported_avl_if PORT_NAME_MAP $port_map
						} else {
							set_interface_property avl export_of "${CONTROLLER}.avl"
						}
						if {$rename_interfaces} {
							::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $CONTROLLER avl $exported_avl_if
						}
					}
				}
			}
		}
	}
}


::alt_mem_if::gen::uniphy_gen::_init
