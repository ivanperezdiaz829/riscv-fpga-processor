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


# +----------------------------------
# | 
# | DisplayPort v12.1
# | Altera Corporation
# | 
# +-----------------------------------

package require -exact qsys 13.1
package require altera_terp

# +-----------------------------------
# | module altera_dp
# | 
set_module_property DESCRIPTION "DisplayPort"
set_module_property NAME altera_dp
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/DisplayPort"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "DisplayPort"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_displayport.pdf
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
#set_module_property VALIDATION_CALLBACK validation_callback
#set_module_property COMPOSE_CALLBACK compose_callback

set_module_property OPAQUE_ADDRESS_MAP true
set_module_property ANALYZE_HDL false
#set_module_property ICON_PATH logo.gif

# Use this to enable beta features not officially included in the
# release
set include_mst 0
set include_hdcp 0

# :::JGS::: Check if this properly disables VHDL support
#set_module_property simulation_model_in_vhdl false

# | 
# +-----------------------------------
proc debug_message { msg_type msg_string } {
	# Uncomment the next line to turn on verbose debugging info
	send_message $msg_type $msg_string
}


# +-----------------------------------
# | Register the PHY IP variants
# | 
proc register_phy_ip { family direction link_rate xcvr_width } {
	# Base name for Native PHY minus family suffix
	set phy_ip_base_name "altera_xcvr_native"

	# Common parameters for all RX variants
	# Organized as name value pairs
	set phy_ip_rx_base_param_val_list {tx_enable 0 enable_std 1 enable_simple_interface 1 cdr_reconfig_enable 1 cdr_refclk_cnt 2 enable_port_rx_pma_clkout 0 std_pcs_pma_width 20 enable_port_rx_std_bitslip 1 std_rx_polinv_enable 1 enable_port_rx_std_polinv 1}

	# Link rate specific RX parameters
	set phy_ip_rx_hbr2_param_val_list {set_data_rate 5400 cdr_refclk_select 1 set_cdr_refclk_freq {270.0 MHz}}
	set phy_ip_rx_hbr_param_val_list {set_data_rate 2700 cdr_refclk_select 1 set_cdr_refclk_freq {270.0 MHz}}
	set phy_ip_rx_rbr_param_val_list {set_data_rate 1620 cdr_refclk_select 0 set_cdr_refclk_freq {162.0 MHz}}

	# XCVR width specific RX parameters
	set phy_ip_rx_40_param_val_list {std_rx_byte_deser_enable 1}

	# Common parameters for all TX variants
	# Organized as name value pairs
	set phy_ip_tx_base_param_val_list {rx_enable 0 enable_std 1 enable_simple_interface 1 pll_reconfig_enable 1 pll_refclk_cnt 2 std_pcs_pma_width 20 std_tx_polinv_enable 1 enable_port_tx_std_polinv 1}

	# Link rate specific RX parameters
	set phy_ip_tx_hbr2_param_val_list {set_data_rate 5400 tx_pma_clk_div 1 gui_pll_reconfig_pll0_refclk_sel 1 gui_pll_reconfig_pll0_refclk_freq {270.0 MHz}}
	set phy_ip_tx_hbr_param_val_list {set_data_rate 2700 tx_pma_clk_div 2 gui_pll_reconfig_pll0_refclk_sel 1 gui_pll_reconfig_pll0_refclk_freq {270.0 MHz}}
	set phy_ip_tx_rbr_param_val_list {set_data_rate 1620 tx_pma_clk_div 1 gui_pll_reconfig_pll0_refclk_sel 0 gui_pll_reconfig_pll0_refclk_freq {162.0 MHz}}

	# XCVR width specific TX parameters
	set phy_ip_tx_40_param_val_list {std_tx_byte_ser_enable 1}

	# Define the variant name based on the PHY parameter
	set variant "altera_dp_phy_${direction}_${link_rate}_${xcvr_width}_${family}"
	set phy_ip_name "${phy_ip_base_name}_${family}"

	# Debug message to know the variant and the PHY
	debug_message INFO "Variant: $variant of $phy_ip_name being processed"
	debug_message INFO "Family: $family, Direction: $direction, Link Rate: $link_rate, XCVR Width: $xcvr_width"

	# Create master parameter list
	switch $direction {
		"rx" {
			set param_val_list $phy_ip_rx_base_param_val_list

			# Setup the link rate parameters
			switch $link_rate {
				"hbr2" {
					set param_val_list [concat $param_val_list $phy_ip_rx_hbr2_param_val_list]
				} \
				"hbr" {
					set param_val_list [concat $param_val_list $phy_ip_rx_hbr_param_val_list]
				} \
				"rbr" {
					set param_val_list [concat $param_val_list $phy_ip_rx_rbr_param_val_list]
				}
			}

			# If doing the 40-bit XCVR interface turn on the byte deser
			if {$xcvr_width == 40} {
				set param_val_list [concat $param_val_list $phy_ip_rx_40_param_val_list]
			}
		} \
		"tx" {
			set param_val_list $phy_ip_tx_base_param_val_list
			
			# Setup the link rate parameters
			switch $link_rate {
				"hbr2" {
					set param_val_list [concat $param_val_list $phy_ip_tx_hbr2_param_val_list]
				} \
				"hbr" {
					set param_val_list [concat $param_val_list $phy_ip_tx_hbr_param_val_list]
				} \
				"rbr" {
					set param_val_list [concat $param_val_list $phy_ip_tx_rbr_param_val_list]
				}
			}

			# If doing the 40-bit XCVR interface turn on the byte deser
			if {$xcvr_width == 40} {
				set param_val_list [concat $param_val_list $phy_ip_tx_40_param_val_list]
			}
		}
	}

	# AV & CV require 40-bit for HBR2
	if {($family eq "av" || $family eq "cv") && $link_rate eq "hbr2" && $xcvr_width == 20} {
		send_message error "40-bit XCVR interface required for $link_rate with $family"
	} else {
		# Register all the parameters for this PHY IP
		# variant instead of using a static MegaWizard
		# variant.
		add_hdl_instance $variant $phy_ip_name
		foreach {param val} $param_val_list {
			set_instance_parameter_value $variant $param $val
		}
	}
}

# +-----------------------------------
# | files
# | 

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH synth_proc

# # +-----------------------------------
# # | SIM_ design files
#   |
add_fileset sim_verilog SIM_VERILOG sim_proc_v

add_fileset sim_vhdl SIM_VHDL sim_proc_vhdl

proc gen_terp { outputName dest_dir verilog args } {
	# This function generates a terp'ed file with the appropriately
	# generated PHY IP matching the parameters used for the
	# add_hdl_instance in the elaboration call-back

	# Choose the appropriate PHY based on the family, link rate & xcvr_width
	set device_family [get_parameter_value device_family]
	if {$device_family == "Stratix V"} {
		set family "sv"
	} elseif {$device_family == "Arria V"} {
		set family "av"
	} elseif {$device_family == "Arria V GZ"} {
		set family "avgz"
	} elseif {$device_family == "Cyclone V"} {
		set family "cv"
	} else {
		# Unknown family
		send_message error "Current device family ($device_family) is not supported."
	}

	set tx_link_rate [get_parameter_value TX_MAX_LINK_RATE]
	set rx_link_rate [get_parameter_value RX_MAX_LINK_RATE]

	if {$tx_link_rate == 20} {
		set tx_phy_link_rate "hbr2"
	} elseif {$tx_link_rate == 10} {
		set tx_phy_link_rate "hbr"
	} else {
		set tx_phy_link_rate "rbr"
	}

	if {$rx_link_rate == 20} {
		set rx_phy_link_rate "hbr2"
	} elseif {$rx_link_rate == 10} {
		set rx_phy_link_rate "hbr"
	} else {
		set rx_phy_link_rate "rbr"
	}

	# Get the XCVR width from the symbols per clock
	# only 2 and 4 symbols are allowed
	set rx_symbols_per_clock [get_parameter_value RX_SYMBOLS_PER_CLOCK]
	set tx_symbols_per_clock [get_parameter_value TX_SYMBOLS_PER_CLOCK]
	
	if {$rx_symbols_per_clock == 2} {
		set rx_phy_xcvr_width 20
	} elseif {$rx_symbols_per_clock == 4} {
		set rx_phy_xcvr_width 40
	} else {
		send_message error "Sink: $rx_symbols_per_clock symbols per clock is not supported."
	}

	if {$tx_symbols_per_clock == 2} {
		set tx_phy_xcvr_width 20
	} elseif {$tx_symbols_per_clock == 4} {
		set tx_phy_xcvr_width 40
	} else {
		send_message error "Source: $tx_symbols_per_clock symbols per clock is not supported."
	}

	set rx_phy_name "altera_dp_phy_rx_${rx_phy_link_rate}_${rx_phy_xcvr_width}_${family}"
	set tx_phy_name "altera_dp_phy_tx_${tx_phy_link_rate}_${tx_phy_xcvr_width}_${family}"

	set params(output_name) $outputName
	set params(rx_phy_name) $rx_phy_name
	set params(tx_phy_name) $tx_phy_name
	debug_message INFO "Generating $outputName with $rx_phy_name and $tx_phy_name"


	# check for simulator tag
	set num_args [llength $args]
	if {$num_args == 1} {
		set sim_tag [lindex $args 0]
	} 

	# Warning we only support Verilog today, need to add VHDL
	# versions that match Verilog
	if {$verilog} {
		# Find all the TERP files to process
		set file_lst [glob -nocomplain -- -path "./*.v.terp"]
		foreach file ${file_lst} {
			debug_message INFO "Reading TERP file $file"
			set fd   [open $file "r"]
			set template [read $fd]
			close $fd

			set contents [altera_terp $template params]

			# Append the last terp'ed file to the same generated file
			if {$num_args == 0} {
				add_fileset_file ${dest_dir}${outputName}.v VERILOG TEXT $contents
				debug_message INFO "Adding file ${dest_dir}${outputName}.v for synth"
			} else {
				add_fileset_file ${dest_dir}${outputName}.v VERILOG TEXT $contents $sim_tag
				debug_message INFO "Adding file ${dest_dir}${outputName}.v for simlation"
			}
		}
	} else {
		debug_message WARNING "VHDL TERP file support has not been added yet creating verilog instead"

		# Find all the TERP files to process
		set file_lst [glob -nocomplain -- -path "./*.v.terp"]
		foreach file ${file_lst} {
			debug_message INFO "Reading TERP file $file"
			set fd   [open $file "r"]
			set template [read $fd]
			close $fd

			set contents [altera_terp $template params]

			# Append the last terp'ed file to the same generated file
			if {$num_args == 0} {
				add_fileset_file ${dest_dir}${outputName}.v VERILOG TEXT $contents
				debug_message INFO "Adding file ${dest_dir}${outputName}.v for synth"
			} else {
				add_fileset_file ${dest_dir}${outputName}.v VERILOG TEXT $contents $sim_tag
				debug_message INFO "Adding file ${dest_dir}${outputName}.v for simlation"
			}
		}
	}
}
																															 


# +-------------------------------
# |SYNTH PROC
# |

proc synth_proc { outputName } {
    set synth_dir_lst {"." "./bitec_dp" "./bitec_dp/common" "./bitec_dp/rx" "./bitec_dp/rx/ss" "./bitec_dp/tx" "./bitec_dp/tx/ss"}

    foreach synth_dir $synth_dir_lst {
        set file_lst [glob -nocomplain -- -path $synth_dir/*]
        foreach file ${file_lst} {   
            set     is_dir  [file isdirectory $file]
            if {$is_dir == 1} {
                debug_message INFO "Ignoring $file for synthesis"
            } else {
				set file_string [split $file /]
				set file_name [lindex $file_string end]

				# Add the file to the correct fileset based on
				# extension
				if {[regexp {.v$} $file_name]} {
					add_fileset_file "$synth_dir/$file_name" VERILOG PATH ${file} 
					debug_message INFO "Adding Verilog $file for synthesis"
				} elseif {[regexp {.sv$} $file_name]} {
					add_fileset_file "$synth_dir/$file_name" SYSTEM_VERILOG PATH ${file} 
					debug_message INFO "Adding SystemVerilog $file for synthesis"
				} elseif {[regexp {.ocp$} $file_name]} {
					add_fileset_file "$synth_dir/$file_name" OTHER PATH ${file} 
					debug_message INFO "Adding OpenCore+ $file for synthesis"
				} elseif {[regexp {.sdc$} $file_name]} {
					add_fileset_file "$synth_dir/$file_name" SDC PATH ${file} 
					debug_message INFO "Adding SDC $file for synthesis"
				} else {
					debug_message INFO "Ignoring $file for synthesis"
				}
			}
        }
    }

    gen_terp $outputName "./" 1 
}


# +-------------------------------
# |SIM PROC
# |
proc sim_proc_v {outputName} {
    sim_proc $outputName 1
}

proc sim_proc_vhdl {outputName} {
    sim_proc $outputName 0
}

# Add all the Bitec files encrypted for a specific simulator
proc sim_proc_bitec { sim_path sim_tag } {

    set sim_dir_lst {"bitec_dp/common" "bitec_dp/rx" "bitec_dp/rx/ss" "bitec_dp/tx" "bitec_dp/tx/ss"}

	foreach sim_dir $sim_dir_lst {
        set file_lst [glob -nocomplain -- -path $sim_path$sim_dir/*]
        foreach file ${file_lst} {   
            set     is_dir  [file isdirectory $file]
            if {$is_dir == 1} {
                debug_message INFO "Ignoring $file for simulation"
            } else {
				set file_string [split $file /]
				set file_name [lindex $file_string end]

				# Add the file to the correct fileset based on
				# extension
				if {[regexp {.v$} $file_name]} {
					add_fileset_file "$sim_path$sim_dir/$file_name" VERILOG PATH ${file} $sim_tag
					debug_message INFO "Adding Verilog $file for simulation"
				} elseif {[regexp {.sv$} $file_name]} {
					add_fileset_file "$sim_path$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} $sim_tag
					debug_message INFO "Adding SystemVerilog $file for simulation"
				} else {
					debug_message INFO "Ignoring $file for simulation"
				}
            }
        }
    }
}

proc sim_proc {outputName {sim_v 1} } {
    set sim_dir_lst				{"."}

    set dest_path_sy            "./synopsys/"
    set dest_path_ca            "./cadence/"
    set dest_path_me            "./mentor/"	
    set dest_path_ald           "./aldec/"			

	# Add the clear text top-level files for all simulators unless
	# doing VHDL. Then use the mentor tagged and encrypted
	foreach sim_dir $sim_dir_lst {
        set file_lst [glob -nocomplain -- -path $sim_dir/*]
        foreach file ${file_lst} {   
            set     is_dir  [file isdirectory $file]
            if {$is_dir == 1} {
                debug_message INFO "Ignoring $file for simulation"
            } else {
				set file_string [split $file /]
				set file_name [lindex $file_string end]

				# Add the file to the correct fileset based on
				# extension
				if {[regexp {.v$} $file_name]} {
					add_fileset_file "$dest_path_sy$sim_dir/$file_name" VERILOG PATH ${file} SYNOPSYS_SPECIFIC
					add_fileset_file "$dest_path_ca$sim_dir/$file_name" VERILOG PATH ${file} CADENCE_SPECIFIC
					add_fileset_file "$dest_path_ald$sim_dir/$file_name" VERILOG PATH ${file} ALDEC_SPECIFIC

					if {$sim_v} {
						add_fileset_file "$dest_path_me$sim_dir/$file_name" VERILOG PATH ${file} MENTOR_SPECIFIC
					}
					debug_message INFO "Adding Verilog $file for simulation"
				} elseif {[regexp {.sv$} $file_name]} {
					add_fileset_file "$dest_path_sy$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} SYNOPSYS_SPECIFIC
					add_fileset_file "$dest_path_ca$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} CADENCE_SPECIFIC
					add_fileset_file "$dest_path_ald$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} ALDEC_SPECIFIC

					if {$sim_v} {
						add_fileset_file "$dest_path_me$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} MENTOR_SPECIFIC
					}
					debug_message INFO "Adding SystemVerilog $file for simulation"
				} else {
					debug_message INFO "Ignoring $file for simulation"
				}
            }
        }
    }

	# Adding the Mentor encrypted for VHDL simulation models
    if {$sim_v == 0} {
        foreach sim_dir $sim_dir_lst {
            set file_lst [glob -nocomplain -- -path $dest_path_me$sim_dir/*]
            foreach file ${file_lst} {   
				set     is_dir  [file isdirectory $file]
				if {$is_dir == 1} {
					debug_message INFO "Ignoring $file for simulation"
				} else {
					set file_string [split $file /]
					set file_name [lindex $file_string end]

					# Add the file to the correct fileset based on
					# extension
					if {[regexp {.v$} $file_name]} {
						add_fileset_file "$dest_path_me$sim_dir/$file_name" VERILOG PATH ${file} MENTOR_SPECIFIC
					} elseif {[regexp {.sv$} $file_name]} {
						add_fileset_file "$dest_path_me$sim_dir/$file_name" SYSTEM_VERILOG PATH ${file} MENTOR_SPECIFIC
					} else {
						debug_message INFO "Ignoring $file for simulation"
					}
				}
            }
        }
    }

	# Add all the encrypted Bitec files for their specific simulators
	sim_proc_bitec $dest_path_sy  SYNOPSYS_SPECIFIC
	sim_proc_bitec $dest_path_ca  CADENCE_SPECIFIC
	sim_proc_bitec $dest_path_me  MENTOR_SPECIFIC
	sim_proc_bitec $dest_path_ald ALDEC_SPECIFIC

    # Add all the TERP files for all simulations
    gen_terp $outputName $dest_path_sy  $sim_v SYNOPSYS_SPECIFIC
    gen_terp $outputName $dest_path_ca  $sim_v CADENCE_SPECIFIC
    gen_terp $outputName $dest_path_me  $sim_v MENTOR_SPECIFIC
    gen_terp $outputName $dest_path_ald $sim_v ALDEC_SPECIFIC
}

# # +-----------------------------------
# # | Example files
#   |
# Disable example files for now. Potentially turn back on
#add_fileset example EXAMPLE_DESIGN proc_add_files_to_fileset_example

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

# Adding device family from system info, taken from reconfig
# controller setup, device_family must be lowercase
add_parameter device_family STRING "Stratix V"
set_parameter_property device_family DISPLAY_NAME "Device family"
set_parameter_property device_family SYSTEM_INFO device_family	;#forces family to always match Qsys
set_parameter_property device_family ALLOWED_RANGES {"Stratix V" "Arria V" "Arria V GZ" "Cyclone V"}
set_parameter_property device_family HDL_PARAMETER true 
set_parameter_property device_family DESCRIPTION "Targeted device family (Arria V, Arria V GZ, or Stratix V); matches the project's device family"
set_parameter_property device_family ENABLED false ; #Shows value, but must match family chosen

add_display_item Source   TX_SUPPORT_DP parameter
add_display_item Source   TX_VIDEO_BPS parameter

add_display_item Source "DisplayPort source" group

add_display_item "DisplayPort source"	TX_MAX_LINK_RATE	parameter
add_display_item "DisplayPort source"   TX_MAX_LANE_COUNT	parameter
add_display_item "DisplayPort source"	TX_SYMBOLS_PER_CLOCK	parameter
add_display_item "DisplayPort source"	TX_PIXELS_PER_CLOCK	parameter
add_display_item "DisplayPort source"   TX_SCRAMBLER_SEED	parameter
add_display_item "DisplayPort source"   TX_POLINV			parameter
add_display_item "DisplayPort source"   TX_SUPPORT_ANALOG_RECONFIG	parameter
add_display_item "DisplayPort source"	TX_AUX_DEBUG		parameter
add_display_item "DisplayPort source"	TX_IMPORT_MSA		parameter
add_display_item "DisplayPort source"	TX_INTERLACED_VID	parameter
add_display_item "DisplayPort source"	TX_SUPPORT_AUTOMATED_TEST parameter
if { $include_hdcp } {
  # HDCP
  add_display_item "DisplayPort Source"   TX_SUPPORT_HDCP   parameter
}
add_display_item "DisplayPort source"  TX_SUPPORT_SS parameter
add_display_item "DisplayPort source" "Source audio support" group
add_display_item "Source audio support" TX_SUPPORT_AUDIO parameter
add_display_item "Source audio support" TX_AUDIO_CHANS parameter

add_display_item "DisplayPort source" "Source color depth support" group
add_display_item "Source color depth support"   TX_SUPPORT_18BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_24BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_30BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_36BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_48BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_YCBCR422_16BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_YCBCR422_20BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_YCBCR422_24BPP parameter
add_display_item "Source color depth support"   TX_SUPPORT_YCBCR422_32BPP parameter

add_display_item Sink   RX_SUPPORT_DP parameter
add_display_item Sink   RX_VIDEO_BPS parameter

add_display_item Sink   RX_IMAGE_OUT_FORMAT parameter

add_display_item Sink  "DisplayPort sink" group

add_display_item "DisplayPort sink"  RX_MAX_LINK_RATE	parameter
add_display_item "DisplayPort sink"  RX_MAX_LANE_COUNT	parameter
add_display_item "DisplayPort sink"  RX_SYMBOLS_PER_CLOCK parameter
add_display_item "DisplayPort sink"  RX_PIXELS_PER_CLOCK parameter
add_display_item "DisplayPort sink"  RX_SCRAMBLER_SEED	parameter
add_display_item "DisplayPort sink"  RX_POLINV			parameter
add_display_item "DisplayPort sink"  RX_EXPORT_MSA		parameter
add_display_item "DisplayPort sink"  RX_IEEE_OUI		parameter      
add_display_item "DisplayPort sink"  RX_AUX_GPU			parameter
add_display_item "DisplayPort sink"  RX_AUX_DEBUG		parameter
add_display_item "DisplayPort sink"  RX_SUPPORT_AUTOMATED_TEST parameter
if { $include_hdcp } {
  # HDCP
  add_display_item "DisplayPort sink"  RX_SUPPORT_HDCP   parameter
}
add_display_item "DisplayPort sink"  RX_SUPPORT_SS parameter
add_display_item "DisplayPort sink" "Sink audio support" group
add_display_item "Sink audio support" RX_SUPPORT_AUDIO parameter
add_display_item "Sink audio support" RX_AUDIO_CHANS parameter
add_display_item "DisplayPort sink" "Sink color depth support" group
add_display_item "Sink color depth support"   RX_SUPPORT_18BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_24BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_30BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_36BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_48BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_YCBCR422_16BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_YCBCR422_20BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_YCBCR422_24BPP parameter
add_display_item "Sink color depth support"   RX_SUPPORT_YCBCR422_32BPP parameter
if { $include_mst } {
  # MST
  add_display_item "DisplayPort sink" "Support MST (multi-stream)" group
  add_display_item "Support MST (multi-stream)" RX_SUPPORT_MST		parameter
  add_display_item "Support MST (multi-stream)" RX_MAX_NUM_OF_STREAMS parameter
}

add_parameter TX_SUPPORT_SS INTEGER 0
set_parameter_property TX_SUPPORT_SS DEFAULT_VALUE 0
set_parameter_property TX_SUPPORT_SS DISPLAY_NAME "Support secondary data channel"
set_parameter_property TX_SUPPORT_SS TYPE INTEGER
set_parameter_property TX_SUPPORT_SS DISPLAY_HINT boolean
set_parameter_property TX_SUPPORT_SS UNITS None
set_parameter_property TX_SUPPORT_SS AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_SS HDL_PARAMETER true
set_parameter_property TX_SUPPORT_SS DESCRIPTION "Support secondary stream in source"
set_parameter_property TX_SUPPORT_SS VISIBLE true

# Hidden Audio support
add_parameter TX_SUPPORT_AUDIO INTEGER 0
set_parameter_property TX_SUPPORT_AUDIO DEFAULT_VALUE 0
set_parameter_property TX_SUPPORT_AUDIO DISPLAY_NAME "Support audio data channel"
set_parameter_property TX_SUPPORT_AUDIO TYPE INTEGER
set_parameter_property TX_SUPPORT_AUDIO DISPLAY_HINT boolean
set_parameter_property TX_SUPPORT_AUDIO UNITS None
set_parameter_property TX_SUPPORT_AUDIO AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_AUDIO HDL_PARAMETER true
set_parameter_property TX_SUPPORT_AUDIO DESCRIPTION "Support audio stream in source"
set_parameter_property TX_SUPPORT_AUDIO VISIBLE true

# Hidden Audio support
add_parameter TX_AUDIO_CHANS INTEGER int 2
set_parameter_property TX_AUDIO_CHANS DEFAULT_VALUE 2
set_parameter_property TX_AUDIO_CHANS ALLOWED_RANGES {2:2 4:4 6:6 8:8}
set_parameter_property TX_AUDIO_CHANS HDL_PARAMETER true
set_parameter_property TX_AUDIO_CHANS DISPLAY_NAME "Number of audio data channels"
set_parameter_property TX_AUDIO_CHANS DISPLAY_UNITS "Chans"
set_parameter_property TX_AUDIO_CHANS DESCRIPTION "Number of audio data channels"
set_parameter_property TX_AUDIO_CHANS VISIBLE true

add_parameter TX_VIDEO_BPS INTEGER int 8
set_parameter_property TX_VIDEO_BPS DEFAULT_VALUE 8
set_parameter_property TX_VIDEO_BPS ALLOWED_RANGES {6:6 8:8 10:10 12:12 16:16}
set_parameter_property TX_VIDEO_BPS HDL_PARAMETER true
set_parameter_property TX_VIDEO_BPS DISPLAY_NAME "Maximum video input color depth"
set_parameter_property TX_VIDEO_BPS DISPLAY_UNITS "bpc"
set_parameter_property TX_VIDEO_BPS DESCRIPTION "The maximum number of bits-per-color used by the video input"

add_parameter TX_MAX_LINK_RATE INTEGER 10
set_parameter_property TX_MAX_LINK_RATE DEFAULT_VALUE 10
set_parameter_property TX_MAX_LINK_RATE DISPLAY_NAME "TX maximum link rate"
set_parameter_property TX_MAX_LINK_RATE UNITS None
set_parameter_property TX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps 20:5.4Gbps}
set_parameter_property TX_MAX_LINK_RATE DESCRIPTION "Maximum link rate supported by source"
set_parameter_property TX_MAX_LINK_RATE AFFECTS_GENERATION false
set_parameter_property TX_MAX_LINK_RATE HDL_PARAMETER true

# Hide the image out setting and default to Image-Port
add_parameter RX_IMAGE_OUT_FORMAT INTEGER 1
set_parameter_property RX_IMAGE_OUT_FORMAT DEFAULT_VALUE 1
set_parameter_property RX_IMAGE_OUT_FORMAT DISPLAY_NAME "Video output port type"
set_parameter_property RX_IMAGE_OUT_FORMAT ALLOWED_RANGES {0:Avalon-ST "1:Image port"}
set_parameter_property RX_IMAGE_OUT_FORMAT HDL_PARAMETER true
set_parameter_property RX_IMAGE_OUT_FORMAT DISPLAY_HINT radio
set_parameter_property RX_IMAGE_OUT_FORMAT DESCRIPTION "Video output via avalon-st port or image port"
set_parameter_property RX_IMAGE_OUT_FORMAT VISIBLE false

add_parameter TX_MAX_LANE_COUNT INTEGER 4
set_parameter_property TX_MAX_LANE_COUNT DEFAULT_VALUE 4
set_parameter_property TX_MAX_LANE_COUNT DISPLAY_NAME "Maximum lane count"
set_parameter_property TX_MAX_LANE_COUNT ALLOWED_RANGES {1:1 2:2 4:4}
set_parameter_property TX_MAX_LANE_COUNT UNITS None
set_parameter_property TX_MAX_LANE_COUNT DESCRIPTION "Maximum lane count supported by source"
set_parameter_property TX_MAX_LANE_COUNT AFFECTS_GENERATION false
set_parameter_property TX_MAX_LANE_COUNT HDL_PARAMETER true

add_parameter TX_POLINV INTEGER 0
set_parameter_property TX_POLINV DEFAULT_VALUE 0
set_parameter_property TX_POLINV DISPLAY_NAME "Invert transceiver polarity"
set_parameter_property TX_POLINV TYPE INTEGER
set_parameter_property TX_POLINV DISPLAY_HINT boolean
set_parameter_property TX_POLINV UNITS None
set_parameter_property TX_POLINV AFFECTS_GENERATION false
set_parameter_property TX_POLINV HDL_PARAMETER true
set_parameter_property TX_POLINV DESCRIPTION "Inverts transceiver polarity"

add_parameter TX_SUPPORT_ANALOG_RECONFIG INTEGER 0
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG DEFAULT_VALUE 0
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG DISPLAY_NAME "Support analog reconfiguration"
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG TYPE INTEGER
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG DISPLAY_HINT boolean
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG UNITS None
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG HDL_PARAMETER true
set_parameter_property TX_SUPPORT_ANALOG_RECONFIG DESCRIPTION "Enable analog reconfiguration interface. Used to reconfigure Vod and pre-emphasis values"

add_parameter TX_AUX_DEBUG INTEGER 1
set_parameter_property TX_AUX_DEBUG DEFAULT_VALUE false
set_parameter_property TX_AUX_DEBUG DISPLAY_NAME "Enable AUX debug stream"
set_parameter_property TX_AUX_DEBUG WIDTH ""
set_parameter_property TX_AUX_DEBUG TYPE INTEGER
set_parameter_property TX_AUX_DEBUG UNITS None
set_parameter_property TX_AUX_DEBUG DESCRIPTION "Enable source AUX traffic output to an Avalon-ST port"
set_parameter_property TX_AUX_DEBUG AFFECTS_GENERATION false
set_parameter_property TX_AUX_DEBUG HDL_PARAMETER true
set_parameter_property TX_AUX_DEBUG DISPLAY_HINT boolean

add_parameter TX_SCRAMBLER_SEED STD_LOGIC_VECTOR 65535
set_parameter_property TX_SCRAMBLER_SEED DEFAULT_VALUE 65535
set_parameter_property TX_SCRAMBLER_SEED DISPLAY_NAME "Scrambler seed value"
set_parameter_property TX_SCRAMBLER_SEED TYPE STD_LOGIC_VECTOR
set_parameter_property TX_SCRAMBLER_SEED UNITS None
set_parameter_property TX_SCRAMBLER_SEED ALLOWED_RANGES 0:65535
set_parameter_property TX_SCRAMBLER_SEED AFFECTS_GENERATION false
set_parameter_property TX_SCRAMBLER_SEED HDL_PARAMETER true
set_parameter_property TX_SCRAMBLER_SEED Description "Scrambler seed value. Use 0xffff for DP and 0xfffe for eDP"

add_parameter TX_PIXELS_PER_CLOCK INTEGER 1
set_parameter_property TX_PIXELS_PER_CLOCK DEFAULT_VALUE 1
set_parameter_property TX_PIXELS_PER_CLOCK DISPLAY_NAME "Pixel input mode"
set_parameter_property TX_PIXELS_PER_CLOCK WIDTH ""
set_parameter_property TX_PIXELS_PER_CLOCK TYPE INTEGER
set_parameter_property TX_PIXELS_PER_CLOCK UNITS None
set_parameter_property TX_PIXELS_PER_CLOCK DESCRIPTION "Enable input of 1, 2 or 4 video pixels in parallel"
set_parameter_property TX_PIXELS_PER_CLOCK AFFECTS_GENERATION false
set_parameter_property TX_PIXELS_PER_CLOCK HDL_PARAMETER true
set_parameter_property TX_PIXELS_PER_CLOCK DISPLAY_HINT boolean
set_parameter_property TX_PIXELS_PER_CLOCK ALLOWED_RANGES {1:Single 2:Dual 4:Quad}

add_parameter TX_SYMBOLS_PER_CLOCK INTEGER 2
set_parameter_property TX_SYMBOLS_PER_CLOCK DEFAULT_VALUE 2
set_parameter_property TX_SYMBOLS_PER_CLOCK DISPLAY_NAME "Symbol output mode"
set_parameter_property TX_SYMBOLS_PER_CLOCK WIDTH ""
set_parameter_property TX_SYMBOLS_PER_CLOCK TYPE INTEGER
set_parameter_property TX_SYMBOLS_PER_CLOCK UNITS None
set_parameter_property TX_SYMBOLS_PER_CLOCK DESCRIPTION "Enable output of 2 or 4 symbols in parallel"
set_parameter_property TX_SYMBOLS_PER_CLOCK AFFECTS_GENERATION false
set_parameter_property TX_SYMBOLS_PER_CLOCK HDL_PARAMETER true
set_parameter_property TX_SYMBOLS_PER_CLOCK DISPLAY_HINT boolean
set_parameter_property TX_SYMBOLS_PER_CLOCK ALLOWED_RANGES {2:Dual 4:Quad}

add_parameter TX_IMPORT_MSA INTEGER 1
set_parameter_property TX_IMPORT_MSA DEFAULT_VALUE 0
set_parameter_property TX_IMPORT_MSA DISPLAY_NAME "Import fixed MSA"
set_parameter_property TX_IMPORT_MSA WIDTH ""
set_parameter_property TX_IMPORT_MSA TYPE INTEGER
set_parameter_property TX_IMPORT_MSA UNITS None
set_parameter_property TX_IMPORT_MSA DESCRIPTION "Enable source to accept a fixed MSA value rather than calculating one from video input data"
set_parameter_property TX_IMPORT_MSA AFFECTS_GENERATION false
set_parameter_property TX_IMPORT_MSA HDL_PARAMETER true
set_parameter_property TX_IMPORT_MSA DISPLAY_HINT boolean

add_parameter TX_INTERLACED_VID INTEGER 1
set_parameter_property TX_INTERLACED_VID DEFAULT_VALUE 0
set_parameter_property TX_INTERLACED_VID DISPLAY_NAME "Interlaced input video"
set_parameter_property TX_INTERLACED_VID WIDTH ""
set_parameter_property TX_INTERLACED_VID TYPE INTEGER
set_parameter_property TX_INTERLACED_VID UNITS None
set_parameter_property TX_INTERLACED_VID DESCRIPTION "Video input is interlaced. Turn on for interlaced, turn off for progressive"
set_parameter_property TX_INTERLACED_VID AFFECTS_GENERATION false
set_parameter_property TX_INTERLACED_VID HDL_PARAMETER true
set_parameter_property TX_INTERLACED_VID DISPLAY_HINT boolean

add_parameter TX_SUPPORT_18BPP INTEGER 1
set_parameter_property TX_SUPPORT_18BPP DEFAULT_VALUE true
set_parameter_property TX_SUPPORT_18BPP DISPLAY_NAME "6-bpc RGB or YCbCr 4:4:4 (18 bpp)"
set_parameter_property TX_SUPPORT_18BPP WIDTH ""
set_parameter_property TX_SUPPORT_18BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_18BPP UNITS None
set_parameter_property TX_SUPPORT_18BPP DESCRIPTION "Enable support for 18 bpp decoding"
set_parameter_property TX_SUPPORT_18BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_18BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_18BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_24BPP INTEGER 1
set_parameter_property TX_SUPPORT_24BPP DEFAULT_VALUE true
set_parameter_property TX_SUPPORT_24BPP DISPLAY_NAME "8-bpc RGB or YCbCr 4:4:4 (24 bpp)"
set_parameter_property TX_SUPPORT_24BPP WIDTH ""
set_parameter_property TX_SUPPORT_24BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_24BPP UNITS None
set_parameter_property TX_SUPPORT_24BPP DESCRIPTION "Enable support for 24 bpp decoding"
set_parameter_property TX_SUPPORT_24BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_24BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_24BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_30BPP INTEGER 1
set_parameter_property TX_SUPPORT_30BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_30BPP DISPLAY_NAME "10-bpc RGB or YCbCr 4:4:4 (30 bpp)"
set_parameter_property TX_SUPPORT_30BPP WIDTH ""
set_parameter_property TX_SUPPORT_30BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_30BPP UNITS None
set_parameter_property TX_SUPPORT_30BPP DESCRIPTION "Enable support for 30 bpp decoding"
set_parameter_property TX_SUPPORT_30BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_30BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_30BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_36BPP INTEGER 1
set_parameter_property TX_SUPPORT_36BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_36BPP DISPLAY_NAME "12-bpc RGB or YCbCr 4:4:4 (36 bpp)"
set_parameter_property TX_SUPPORT_36BPP WIDTH ""
set_parameter_property TX_SUPPORT_36BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_36BPP UNITS None
set_parameter_property TX_SUPPORT_36BPP DESCRIPTION "Enable support for 36 bpp decoding"
set_parameter_property TX_SUPPORT_36BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_36BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_36BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_48BPP INTEGER 1
set_parameter_property TX_SUPPORT_48BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_48BPP DISPLAY_NAME "16-bpc RGB or YCbCr 4:4:4 (48 bpp)"
set_parameter_property TX_SUPPORT_48BPP WIDTH ""
set_parameter_property TX_SUPPORT_48BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_48BPP UNITS None
set_parameter_property TX_SUPPORT_48BPP DESCRIPTION "Enable support for 48 bpp decoding"
set_parameter_property TX_SUPPORT_48BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_48BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_48BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_YCBCR422_16BPP INTEGER 1
set_parameter_property TX_SUPPORT_YCBCR422_16BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_YCBCR422_16BPP DISPLAY_NAME "8-bpc YCbCr 4:2:2 (16 bpp)"
set_parameter_property TX_SUPPORT_YCBCR422_16BPP WIDTH ""
set_parameter_property TX_SUPPORT_YCBCR422_16BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_YCBCR422_16BPP UNITS None
set_parameter_property TX_SUPPORT_YCBCR422_16BPP DESCRIPTION "Enable support for 16 bpp decoding"
set_parameter_property TX_SUPPORT_YCBCR422_16BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_YCBCR422_16BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_YCBCR422_16BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_YCBCR422_20BPP INTEGER 1
set_parameter_property TX_SUPPORT_YCBCR422_20BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_YCBCR422_20BPP DISPLAY_NAME "10-bpc YCbCr 4:2:2 (20 bpp)"
set_parameter_property TX_SUPPORT_YCBCR422_20BPP WIDTH ""
set_parameter_property TX_SUPPORT_YCBCR422_20BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_YCBCR422_20BPP UNITS None
set_parameter_property TX_SUPPORT_YCBCR422_20BPP DESCRIPTION "Enable support for 20 bpp decoding"
set_parameter_property TX_SUPPORT_YCBCR422_20BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_YCBCR422_20BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_YCBCR422_20BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_YCBCR422_24BPP INTEGER 1
set_parameter_property TX_SUPPORT_YCBCR422_24BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_YCBCR422_24BPP DISPLAY_NAME "12-bpc YCbCr 4:2:2 (24 bpp)"
set_parameter_property TX_SUPPORT_YCBCR422_24BPP WIDTH ""
set_parameter_property TX_SUPPORT_YCBCR422_24BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_YCBCR422_24BPP UNITS None
set_parameter_property TX_SUPPORT_YCBCR422_24BPP DESCRIPTION "Enable support for 24 bpp decoding"
set_parameter_property TX_SUPPORT_YCBCR422_24BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_YCBCR422_24BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_YCBCR422_24BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_YCBCR422_32BPP INTEGER 1
set_parameter_property TX_SUPPORT_YCBCR422_32BPP DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_YCBCR422_32BPP DISPLAY_NAME "16-bpc YCbCr 4:2:2 (32 bpp)"
set_parameter_property TX_SUPPORT_YCBCR422_32BPP WIDTH ""
set_parameter_property TX_SUPPORT_YCBCR422_32BPP TYPE INTEGER
set_parameter_property TX_SUPPORT_YCBCR422_32BPP UNITS None
set_parameter_property TX_SUPPORT_YCBCR422_32BPP DESCRIPTION "Enable support for 32 bpp decoding"
set_parameter_property TX_SUPPORT_YCBCR422_32BPP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_YCBCR422_32BPP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_YCBCR422_32BPP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_DP INTEGER 1
set_parameter_property TX_SUPPORT_DP DEFAULT_VALUE true
set_parameter_property TX_SUPPORT_DP DISPLAY_NAME "Support DisplayPort source"
set_parameter_property TX_SUPPORT_DP WIDTH ""
set_parameter_property TX_SUPPORT_DP TYPE INTEGER
set_parameter_property TX_SUPPORT_DP UNITS None
set_parameter_property TX_SUPPORT_DP DESCRIPTION "Enable DisplayPort source"
set_parameter_property TX_SUPPORT_DP AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_DP HDL_PARAMETER true
set_parameter_property TX_SUPPORT_DP DISPLAY_HINT boolean

add_parameter TX_SUPPORT_AUTOMATED_TEST INTEGER 1
set_parameter_property TX_SUPPORT_AUTOMATED_TEST DEFAULT_VALUE false
set_parameter_property TX_SUPPORT_AUTOMATED_TEST DISPLAY_NAME "Support CTS test automation"
set_parameter_property TX_SUPPORT_AUTOMATED_TEST WIDTH ""
set_parameter_property TX_SUPPORT_AUTOMATED_TEST TYPE INTEGER
set_parameter_property TX_SUPPORT_AUTOMATED_TEST UNITS None
set_parameter_property TX_SUPPORT_AUTOMATED_TEST DESCRIPTION "Enable CTS CRC test logic"
set_parameter_property TX_SUPPORT_AUTOMATED_TEST AFFECTS_GENERATION false
set_parameter_property TX_SUPPORT_AUTOMATED_TEST HDL_PARAMETER true
set_parameter_property TX_SUPPORT_AUTOMATED_TEST DISPLAY_HINT boolean

# Hidden parameter support for HDCP
if { $include_hdcp } {
  # HDCP
  add_parameter TX_SUPPORT_HDCP INTEGER 1
  set_parameter_property TX_SUPPORT_HDCP DEFAULT_VALUE false
  set_parameter_property TX_SUPPORT_HDCP DISPLAY_NAME "Support source HDCP"
  set_parameter_property TX_SUPPORT_HDCP WIDTH ""
  set_parameter_property TX_SUPPORT_HDCP TYPE INTEGER
  set_parameter_property TX_SUPPORT_HDCP UNITS None
  set_parameter_property TX_SUPPORT_HDCP DESCRIPTION "Enable support for HDCP encryption"
  set_parameter_property TX_SUPPORT_HDCP AFFECTS_GENERATION false
  set_parameter_property TX_SUPPORT_HDCP HDL_PARAMETER true
  set_parameter_property TX_SUPPORT_HDCP DISPLAY_HINT boolean
}

add_parameter RX_PIXELS_PER_CLOCK INTEGER 1
set_parameter_property RX_PIXELS_PER_CLOCK DEFAULT_VALUE 1
set_parameter_property RX_PIXELS_PER_CLOCK DISPLAY_NAME "Pixel output mode"
set_parameter_property RX_PIXELS_PER_CLOCK WIDTH ""
set_parameter_property RX_PIXELS_PER_CLOCK TYPE INTEGER
set_parameter_property RX_PIXELS_PER_CLOCK UNITS None
set_parameter_property RX_PIXELS_PER_CLOCK DESCRIPTION "Enable output of 1, 2 or 4 video pixels in parallel"
set_parameter_property RX_PIXELS_PER_CLOCK AFFECTS_GENERATION false
set_parameter_property RX_PIXELS_PER_CLOCK HDL_PARAMETER true
set_parameter_property RX_PIXELS_PER_CLOCK DISPLAY_HINT boolean
set_parameter_property RX_PIXELS_PER_CLOCK ALLOWED_RANGES {1:Single 2:Dual 4:Quad}

add_parameter RX_SYMBOLS_PER_CLOCK INTEGER 2
set_parameter_property RX_SYMBOLS_PER_CLOCK DEFAULT_VALUE 2
set_parameter_property RX_SYMBOLS_PER_CLOCK DISPLAY_NAME "Symbol input mode"
set_parameter_property RX_SYMBOLS_PER_CLOCK WIDTH ""
set_parameter_property RX_SYMBOLS_PER_CLOCK TYPE INTEGER
set_parameter_property RX_SYMBOLS_PER_CLOCK UNITS None
set_parameter_property RX_SYMBOLS_PER_CLOCK DESCRIPTION "Enable input of 2 or 4 symbols in parallel"
set_parameter_property RX_SYMBOLS_PER_CLOCK AFFECTS_GENERATION false
set_parameter_property RX_SYMBOLS_PER_CLOCK HDL_PARAMETER true
set_parameter_property RX_SYMBOLS_PER_CLOCK DISPLAY_HINT boolean
set_parameter_property RX_SYMBOLS_PER_CLOCK ALLOWED_RANGES {2:Dual 4:Quad}

add_parameter RX_EXPORT_MSA INTEGER 1
set_parameter_property RX_EXPORT_MSA DEFAULT_VALUE 0
set_parameter_property RX_EXPORT_MSA DISPLAY_NAME "Export MSA"
set_parameter_property RX_EXPORT_MSA WIDTH ""
set_parameter_property RX_EXPORT_MSA TYPE INTEGER
set_parameter_property RX_EXPORT_MSA UNITS None
set_parameter_property RX_EXPORT_MSA DESCRIPTION "Outputs MSA to top level port interface"
set_parameter_property RX_EXPORT_MSA AFFECTS_GENERATION false
set_parameter_property RX_EXPORT_MSA HDL_PARAMETER true
set_parameter_property RX_EXPORT_MSA DISPLAY_HINT boolean

add_parameter RX_VIDEO_BPS INTEGER int 8
set_parameter_property RX_VIDEO_BPS DEFAULT_VALUE 8
set_parameter_property RX_VIDEO_BPS ALLOWED_RANGES {6:6 8:8 10:10 12:12 16:16}
set_parameter_property RX_VIDEO_BPS HDL_PARAMETER true
set_parameter_property RX_VIDEO_BPS DISPLAY_NAME "Maximum video output color depth"
set_parameter_property RX_VIDEO_BPS DISPLAY_UNITS "bpc"
set_parameter_property RX_VIDEO_BPS DESCRIPTION "The maximum number of bits-per-color used by the video output"

add_parameter RX_SUPPORT_SS INTEGER 0
set_parameter_property RX_SUPPORT_SS DEFAULT_VALUE 0
set_parameter_property RX_SUPPORT_SS DISPLAY_NAME "Support secondary data channel"
set_parameter_property RX_SUPPORT_SS TYPE INTEGER
set_parameter_property RX_SUPPORT_SS DISPLAY_HINT boolean
set_parameter_property RX_SUPPORT_SS UNITS None
set_parameter_property RX_SUPPORT_SS AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_SS HDL_PARAMETER true
set_parameter_property RX_SUPPORT_SS DESCRIPTION "Support secondary stream in sink"
set_parameter_property RX_SUPPORT_SS VISIBLE true

add_parameter RX_SUPPORT_AUDIO INTEGER 0
set_parameter_property RX_SUPPORT_AUDIO DEFAULT_VALUE 0
set_parameter_property RX_SUPPORT_AUDIO DISPLAY_NAME "Support audio data channel"
set_parameter_property RX_SUPPORT_AUDIO TYPE INTEGER
set_parameter_property RX_SUPPORT_AUDIO DISPLAY_HINT boolean
set_parameter_property RX_SUPPORT_AUDIO UNITS None
set_parameter_property RX_SUPPORT_AUDIO AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_AUDIO HDL_PARAMETER true
set_parameter_property RX_SUPPORT_AUDIO DESCRIPTION "Support audio stream"
set_parameter_property RX_SUPPORT_AUDIO VISIBLE true

add_parameter RX_AUDIO_CHANS INTEGER int 2
set_parameter_property RX_AUDIO_CHANS DEFAULT_VALUE 2
set_parameter_property RX_AUDIO_CHANS ALLOWED_RANGES {2:2 4:4 6:6 8:8}
set_parameter_property RX_AUDIO_CHANS HDL_PARAMETER true
set_parameter_property RX_AUDIO_CHANS DISPLAY_NAME "Number of audio data channels"
set_parameter_property RX_AUDIO_CHANS DISPLAY_UNITS "Chans"
set_parameter_property RX_AUDIO_CHANS DESCRIPTION "Number of audio data channels"
set_parameter_property RX_AUDIO_CHANS VISIBLE true

add_parameter RX_MAX_LINK_RATE INTEGER 10
set_parameter_property RX_MAX_LINK_RATE DEFAULT_VALUE 10
set_parameter_property RX_MAX_LINK_RATE DISPLAY_NAME "RX maximum link rate"
set_parameter_property RX_MAX_LINK_RATE UNITS None
set_parameter_property RX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps 20:5.4Gbps}
set_parameter_property RX_MAX_LINK_RATE DESCRIPTION "Maximum link rate supported by sink"
set_parameter_property RX_MAX_LINK_RATE AFFECTS_GENERATION false
set_parameter_property RX_MAX_LINK_RATE HDL_PARAMETER true

add_parameter RX_MAX_LANE_COUNT INTEGER 4
set_parameter_property RX_MAX_LANE_COUNT DEFAULT_VALUE 4
set_parameter_property RX_MAX_LANE_COUNT DISPLAY_NAME "Maximum lane count"
set_parameter_property RX_MAX_LANE_COUNT ALLOWED_RANGES {1:1 2:2 4:4}
set_parameter_property RX_MAX_LANE_COUNT UNITS None
set_parameter_property RX_MAX_LANE_COUNT DESCRIPTION "Maximum lane count supported"
set_parameter_property RX_MAX_LANE_COUNT AFFECTS_GENERATION false
set_parameter_property RX_MAX_LANE_COUNT HDL_PARAMETER true

add_parameter RX_POLINV INTEGER 0
set_parameter_property RX_POLINV DEFAULT_VALUE 0
set_parameter_property RX_POLINV DISPLAY_NAME "Invert transceiver polarity"
set_parameter_property RX_POLINV TYPE INTEGER
set_parameter_property RX_POLINV DISPLAY_HINT boolean
set_parameter_property RX_POLINV UNITS None
set_parameter_property RX_POLINV AFFECTS_GENERATION false
set_parameter_property RX_POLINV HDL_PARAMETER true
set_parameter_property RX_POLINV DESCRIPTION "Inverts transceiver polarity"

add_parameter RX_SCRAMBLER_SEED STD_LOGIC_VECTOR 65535
set_parameter_property RX_SCRAMBLER_SEED DEFAULT_VALUE 65535
set_parameter_property RX_SCRAMBLER_SEED DISPLAY_NAME "Sink scrambler seed value"
set_parameter_property RX_SCRAMBLER_SEED TYPE STD_LOGIC_VECTOR
set_parameter_property RX_SCRAMBLER_SEED UNITS None
set_parameter_property RX_SCRAMBLER_SEED ALLOWED_RANGES 0:65535
set_parameter_property RX_SCRAMBLER_SEED AFFECTS_GENERATION false
set_parameter_property RX_SCRAMBLER_SEED HDL_PARAMETER true
set_parameter_property RX_SCRAMBLER_SEED Description "Scrambler seed value. Use 0xffff for DP and 0xfffe for eDP"

add_parameter RX_SUPPORT_AUTOMATED_TEST INTEGER 1
set_parameter_property RX_SUPPORT_AUTOMATED_TEST DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_AUTOMATED_TEST DISPLAY_NAME "Support CTS test automation"
set_parameter_property RX_SUPPORT_AUTOMATED_TEST WIDTH ""
set_parameter_property RX_SUPPORT_AUTOMATED_TEST TYPE INTEGER
set_parameter_property RX_SUPPORT_AUTOMATED_TEST UNITS None
set_parameter_property RX_SUPPORT_AUTOMATED_TEST DESCRIPTION "Enable CTS CRC test logic"
set_parameter_property RX_SUPPORT_AUTOMATED_TEST AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_AUTOMATED_TEST HDL_PARAMETER true
set_parameter_property RX_SUPPORT_AUTOMATED_TEST DISPLAY_HINT boolean

#Hidden support for HDCP
if { $include_hdcp} {
  # HDCP
  add_parameter RX_SUPPORT_HDCP INTEGER 1
  set_parameter_property RX_SUPPORT_HDCP DEFAULT_VALUE false
  set_parameter_property RX_SUPPORT_HDCP DISPLAY_NAME "Support sink HDCP"
  set_parameter_property RX_SUPPORT_HDCP WIDTH ""
  set_parameter_property RX_SUPPORT_HDCP TYPE INTEGER
  set_parameter_property RX_SUPPORT_HDCP UNITS None
  set_parameter_property RX_SUPPORT_HDCP DESCRIPTION "Enable for HDCP decryption"
  set_parameter_property RX_SUPPORT_HDCP AFFECTS_GENERATION false
  set_parameter_property RX_SUPPORT_HDCP HDL_PARAMETER true
  set_parameter_property RX_SUPPORT_HDCP DISPLAY_HINT boolean
}

add_parameter RX_SUPPORT_18BPP INTEGER 1
set_parameter_property RX_SUPPORT_18BPP DEFAULT_VALUE true
set_parameter_property RX_SUPPORT_18BPP DISPLAY_NAME "6-bpc RGB or YCbCr 4:4:4 (18 bpp)"
set_parameter_property RX_SUPPORT_18BPP WIDTH ""
set_parameter_property RX_SUPPORT_18BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_18BPP UNITS None
set_parameter_property RX_SUPPORT_18BPP DESCRIPTION "Enable support for 18 bpp decoding"
set_parameter_property RX_SUPPORT_18BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_18BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_18BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_24BPP INTEGER 1
set_parameter_property RX_SUPPORT_24BPP DEFAULT_VALUE true
set_parameter_property RX_SUPPORT_24BPP DISPLAY_NAME "8-bpc RGB or YCbCr 4:4:4 (24 bpp)"
set_parameter_property RX_SUPPORT_24BPP WIDTH ""
set_parameter_property RX_SUPPORT_24BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_24BPP UNITS None
set_parameter_property RX_SUPPORT_24BPP DESCRIPTION "Enable support for 24 bpp decoding"
set_parameter_property RX_SUPPORT_24BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_24BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_24BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_30BPP INTEGER 1
set_parameter_property RX_SUPPORT_30BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_30BPP DISPLAY_NAME "10-bpc RGB or YCbCr 4:4:4 (30 bpp)"
set_parameter_property RX_SUPPORT_30BPP WIDTH ""
set_parameter_property RX_SUPPORT_30BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_30BPP UNITS None
set_parameter_property RX_SUPPORT_30BPP DESCRIPTION "Enable support for 30 bpp decoding"
set_parameter_property RX_SUPPORT_30BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_30BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_30BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_36BPP INTEGER 1
set_parameter_property RX_SUPPORT_36BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_36BPP DISPLAY_NAME "12-bpc RGB or YCbCr 4:4:4 (36 bpp)"
set_parameter_property RX_SUPPORT_36BPP WIDTH ""
set_parameter_property RX_SUPPORT_36BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_36BPP UNITS None
set_parameter_property RX_SUPPORT_36BPP DESCRIPTION "Enable support for 36 bpp decoding"
set_parameter_property RX_SUPPORT_36BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_36BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_36BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_48BPP INTEGER 1
set_parameter_property RX_SUPPORT_48BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_48BPP DISPLAY_NAME "16-bpc RGB or YCbCr 4:4:4 (48 bpp)"
set_parameter_property RX_SUPPORT_48BPP WIDTH ""
set_parameter_property RX_SUPPORT_48BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_48BPP UNITS None
set_parameter_property RX_SUPPORT_48BPP DESCRIPTION "Enable support for 48 bpp decoding"
set_parameter_property RX_SUPPORT_48BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_48BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_48BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_YCBCR422_16BPP INTEGER 1
set_parameter_property RX_SUPPORT_YCBCR422_16BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_YCBCR422_16BPP DISPLAY_NAME "8-bpc YCbCr 4:2:2 (16 bpp)"
set_parameter_property RX_SUPPORT_YCBCR422_16BPP WIDTH ""
set_parameter_property RX_SUPPORT_YCBCR422_16BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_YCBCR422_16BPP UNITS None
set_parameter_property RX_SUPPORT_YCBCR422_16BPP DESCRIPTION "Enable support for 16 bpp decoding"
set_parameter_property RX_SUPPORT_YCBCR422_16BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_YCBCR422_16BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_YCBCR422_16BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_YCBCR422_20BPP INTEGER 1
set_parameter_property RX_SUPPORT_YCBCR422_20BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_YCBCR422_20BPP DISPLAY_NAME "10-bpc YCbCr 4:2:2 (20 bpp)"
set_parameter_property RX_SUPPORT_YCBCR422_20BPP WIDTH ""
set_parameter_property RX_SUPPORT_YCBCR422_20BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_YCBCR422_20BPP UNITS None
set_parameter_property RX_SUPPORT_YCBCR422_20BPP DESCRIPTION "Enable support for 20 bpp decoding"
set_parameter_property RX_SUPPORT_YCBCR422_20BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_YCBCR422_20BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_YCBCR422_20BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_YCBCR422_24BPP INTEGER 1
set_parameter_property RX_SUPPORT_YCBCR422_24BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_YCBCR422_24BPP DISPLAY_NAME "12-bpc YCbCr 4:2:2 (24 bpp)"
set_parameter_property RX_SUPPORT_YCBCR422_24BPP WIDTH ""
set_parameter_property RX_SUPPORT_YCBCR422_24BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_YCBCR422_24BPP UNITS None
set_parameter_property RX_SUPPORT_YCBCR422_24BPP DESCRIPTION "Enable support for 24 bpp decoding"
set_parameter_property RX_SUPPORT_YCBCR422_24BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_YCBCR422_24BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_YCBCR422_24BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_YCBCR422_32BPP INTEGER 1
set_parameter_property RX_SUPPORT_YCBCR422_32BPP DEFAULT_VALUE false
set_parameter_property RX_SUPPORT_YCBCR422_32BPP DISPLAY_NAME "16-bpc YCbCr 4:2:2 (32 bpp)"
set_parameter_property RX_SUPPORT_YCBCR422_32BPP WIDTH ""
set_parameter_property RX_SUPPORT_YCBCR422_32BPP TYPE INTEGER
set_parameter_property RX_SUPPORT_YCBCR422_32BPP UNITS None
set_parameter_property RX_SUPPORT_YCBCR422_32BPP DESCRIPTION "Enable support for 32 bpp decoding"
set_parameter_property RX_SUPPORT_YCBCR422_32BPP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_YCBCR422_32BPP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_YCBCR422_32BPP DISPLAY_HINT boolean

add_parameter RX_SUPPORT_DP INTEGER 1
set_parameter_property RX_SUPPORT_DP DEFAULT_VALUE true
set_parameter_property RX_SUPPORT_DP DISPLAY_NAME "Support DisplayPort sink"
set_parameter_property RX_SUPPORT_DP WIDTH ""
set_parameter_property RX_SUPPORT_DP TYPE INTEGER
set_parameter_property RX_SUPPORT_DP UNITS None
set_parameter_property RX_SUPPORT_DP DESCRIPTION "Enable DisplayPort sink"
set_parameter_property RX_SUPPORT_DP AFFECTS_GENERATION false
set_parameter_property RX_SUPPORT_DP HDL_PARAMETER true
set_parameter_property RX_SUPPORT_DP DISPLAY_HINT boolean

add_parameter RX_AUX_DEBUG INTEGER 1
set_parameter_property RX_AUX_DEBUG DEFAULT_VALUE false
set_parameter_property RX_AUX_DEBUG DISPLAY_NAME "Enable AUX debug stream"
set_parameter_property RX_AUX_DEBUG WIDTH ""
set_parameter_property RX_AUX_DEBUG TYPE INTEGER
set_parameter_property RX_AUX_DEBUG UNITS None
set_parameter_property RX_AUX_DEBUG DESCRIPTION "Enable AUX traffic output to an Avalon-ST port"
set_parameter_property RX_AUX_DEBUG AFFECTS_GENERATION false
set_parameter_property RX_AUX_DEBUG HDL_PARAMETER true
set_parameter_property RX_AUX_DEBUG DISPLAY_HINT boolean

add_parameter RX_IEEE_OUI STD_LOGIC_VECTOR 1
set_parameter_property RX_IEEE_OUI DEFAULT_VALUE 1
set_parameter_property RX_IEEE_OUI DISPLAY_NAME "IEEE OUI"
set_parameter_property RX_IEEE_OUI TYPE STD_LOGIC_VECTOR
set_parameter_property RX_IEEE_OUI UNITS None
set_parameter_property RX_IEEE_OUI ALLOWED_RANGES 0:16777215
set_parameter_property RX_IEEE_OUI AFFECTS_GENERATION false
set_parameter_property RX_IEEE_OUI HDL_PARAMETER true
set_parameter_property RX_IEEE_OUI DESCRIPTION "Specify an IEEE organizationally unique identifier (OUI) as part of the DPCD registers"

add_parameter RX_AUX_GPU INTEGER 1
set_parameter_property RX_AUX_GPU DEFAULT_VALUE false
set_parameter_property RX_AUX_GPU DISPLAY_NAME "Enable GPU control" 
set_parameter_property RX_AUX_GPU WIDTH ""
set_parameter_property RX_AUX_GPU TYPE INTEGER
set_parameter_property RX_AUX_GPU UNITS None
set_parameter_property RX_AUX_GPU DESCRIPTION "Use an embedded controller to control the sink"
set_parameter_property RX_AUX_GPU AFFECTS_GENERATION false
set_parameter_property RX_AUX_GPU HDL_PARAMETER true
set_parameter_property RX_AUX_GPU DISPLAY_HINT boolean



# Hidden MST support
if { $include_mst } {
  # MST
  add_parameter RX_SUPPORT_MST INTEGER 0
  set_parameter_property RX_SUPPORT_MST DEFAULT_VALUE 0
  set_parameter_property RX_SUPPORT_MST DISPLAY_NAME "Support MST (multi-stream)"
  set_parameter_property RX_SUPPORT_MST TYPE INTEGER
  set_parameter_property RX_SUPPORT_MST DISPLAY_HINT boolean
  set_parameter_property RX_SUPPORT_MST UNITS None
  set_parameter_property RX_SUPPORT_MST AFFECTS_GENERATION false
  set_parameter_property RX_SUPPORT_MST HDL_PARAMETER true
  set_parameter_property RX_SUPPORT_MST DESCRIPTION "Support MST (multi-stream)"

  add_parameter RX_MAX_NUM_OF_STREAMS INTEGER 1 "1, 2, 3 or 4"
  set_parameter_property RX_MAX_NUM_OF_STREAMS DEFAULT_VALUE 1
  set_parameter_property RX_MAX_NUM_OF_STREAMS DISPLAY_NAME "Max stream count"
  set_parameter_property RX_MAX_NUM_OF_STREAMS ALLOWED_RANGES {1:1 2:2 3:3 4:4}
  set_parameter_property RX_MAX_NUM_OF_STREAMS TYPE INTEGER
  set_parameter_property RX_MAX_NUM_OF_STREAMS UNITS None
  set_parameter_property RX_MAX_NUM_OF_STREAMS DESCRIPTION "Maximum number of streams supported by Sink"
  set_parameter_property RX_MAX_NUM_OF_STREAMS AFFECTS_GENERATION false
  set_parameter_property RX_MAX_NUM_OF_STREAMS HDL_PARAMETER true
  set_parameter_property RX_MAX_NUM_OF_STREAMS DISPLAY_HINT radio
}

# +-----------------------------------
# | 
# | INTERFACES
# | 
# +-----------------------------------

# +----------------------------------------------------------------------
# | Main clock domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk clockRate 0
add_interface_port clk clk clk Input 1

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT
add_interface_port reset reset reset Input 1

# +-----------------------------------
# | connection point tx_mgmt
# | 
add_interface tx_mgmt avalon end
set_interface_property tx_mgmt addressAlignment DYNAMIC
set_interface_property tx_mgmt addressUnits WORDS
set_interface_property tx_mgmt associatedClock clk
set_interface_property tx_mgmt associatedReset reset
set_interface_property tx_mgmt burstOnBurstBoundariesOnly false
set_interface_property tx_mgmt explicitAddressSpan 0
set_interface_property tx_mgmt holdTime 0
set_interface_property tx_mgmt isMemoryDevice false
set_interface_property tx_mgmt isNonVolatileStorage false
set_interface_property tx_mgmt linewrapBursts false
set_interface_property tx_mgmt maximumPendingReadTransactions 0
set_interface_property tx_mgmt printableDevice false
set_interface_property tx_mgmt readLatency 0
set_interface_property tx_mgmt readWaitTime 1
set_interface_property tx_mgmt setupTime 0
set_interface_property tx_mgmt timingUnits Cycles
set_interface_property tx_mgmt writeWaitTime 0

add_interface_port tx_mgmt tx_mgmt_address address Input 9
add_interface_port tx_mgmt tx_mgmt_chipselect chipselect Input 1
add_interface_port tx_mgmt tx_mgmt_read read Input 1
add_interface_port tx_mgmt tx_mgmt_write write Input 1
add_interface_port tx_mgmt tx_mgmt_writedata writedata Input 32
add_interface_port tx_mgmt tx_mgmt_readdata readdata Output 32
add_interface_port tx_mgmt tx_mgmt_waitrequest waitrequest Output 1

# +-----------------------------------
# | connection point tx_mgmt_interrupt
# | 
add_interface tx_mgmt_interrupt interrupt end
set_interface_property tx_mgmt_interrupt associatedAddressablePoint tx_mgmt
set_interface_property tx_mgmt_interrupt associatedClock clk
set_interface_property tx_mgmt_interrupt associatedReset reset
add_interface_port tx_mgmt_interrupt tx_mgmt_irq irq Output 1

# +-----------------------------------
# | connection point rx_mgmt
# | 
add_interface rx_mgmt avalon end
set_interface_property rx_mgmt addressAlignment DYNAMIC
set_interface_property rx_mgmt addressUnits WORDS
set_interface_property rx_mgmt associatedClock clk
set_interface_property rx_mgmt associatedReset reset
set_interface_property rx_mgmt burstOnBurstBoundariesOnly false
set_interface_property rx_mgmt explicitAddressSpan 0
set_interface_property rx_mgmt holdTime 0
set_interface_property rx_mgmt isMemoryDevice false
set_interface_property rx_mgmt isNonVolatileStorage false
set_interface_property rx_mgmt linewrapBursts false
set_interface_property rx_mgmt maximumPendingReadTransactions 0
set_interface_property rx_mgmt printableDevice false
set_interface_property rx_mgmt readLatency 0
set_interface_property rx_mgmt readWaitTime 1
set_interface_property rx_mgmt setupTime 0
set_interface_property rx_mgmt timingUnits Cycles
set_interface_property rx_mgmt writeWaitTime 0

add_interface_port rx_mgmt rx_mgmt_chipselect chipselect Input 1
add_interface_port rx_mgmt rx_mgmt_read read Input 1
add_interface_port rx_mgmt rx_mgmt_write write Input 1
add_interface_port rx_mgmt rx_mgmt_address address Input 9
add_interface_port rx_mgmt rx_mgmt_writedata writedata Input 32
add_interface_port rx_mgmt rx_mgmt_readdata readdata Output 32
add_interface_port rx_mgmt rx_mgmt_waitrequest waitrequest Output 1

# +-----------------------------------
# | connection point rx_mgmt_interrupt
# | 
add_interface rx_mgmt_interrupt interrupt end
set_interface_property rx_mgmt_interrupt associatedAddressablePoint rx_mgmt
set_interface_property rx_mgmt_interrupt associatedClock clk
set_interface_property rx_mgmt_interrupt associatedReset reset
add_interface_port rx_mgmt_interrupt rx_mgmt_irq irq Output 1

# +----------------------------------------------------------------------
# | XCVR Mgmt domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point xcvr_mgmt_clk
# | 
add_interface xcvr_mgmt_clk clock end
set_interface_property xcvr_mgmt_clk clockRate 100000000
add_interface_port xcvr_mgmt_clk xcvr_mgmt_clk clk Input 1

# +-----------------------------------
# | connection point xcvr_refclk_clk
# | 

# Using a conduit because clocks can't be multiple bits in Qsys
add_interface xcvr_refclk conduit end
add_interface_port xcvr_refclk xcvr_refclk export input 2

# +-----------------------------------
# | TX/RX serial pins
# | 
add_interface tx_serial_data conduit end
# tx_serial_data has variable port-width, added in elaboration

add_interface rx_serial_data conduit end
# rx_serial_data has variable port-width, added in elaboration

# +-----------------------------------
# | TX/RX reconfig conduits
# | 
add_interface tx_reconfig conduit end
add_interface_port tx_reconfig tx_link_rate export Output 2 
add_interface_port tx_reconfig tx_reconfig_req export Output 1
add_interface_port tx_reconfig tx_reconfig_ack export Input 1
add_interface_port tx_reconfig tx_reconfig_busy export Input 1

add_interface tx_analog_reconfig conduit end
# tx_vod has variable port-width, added in elaboration
# tx_emp has variable port-width, added in elaboration
add_interface_port tx_analog_reconfig tx_analog_reconfig_req export Output 1
add_interface_port tx_analog_reconfig tx_analog_reconfig_ack export Input 1
add_interface_port tx_analog_reconfig tx_analog_reconfig_busy export Input 1

add_interface rx_reconfig conduit end
add_interface_port rx_reconfig rx_link_rate export Output 2 
add_interface_port rx_reconfig rx_reconfig_req export Output 1
add_interface_port rx_reconfig rx_reconfig_ack export Input 1
add_interface_port rx_reconfig rx_reconfig_busy export Input 1


# +-----------------------------------
# | XCVR reconfig conduit
# | 
add_interface xcvr_reconfig conduit end
# reconfig_to_xcvr has variable port-width, added in elaboration
# reconfig_from_xcvr has variable port-width, added in elaboration

# +----------------------------------------------------------------------
# | Video domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point tx_vid_clk
# | 
add_interface tx_vid_clk clock end
set_interface_property tx_vid_clk clockRate 0
add_interface_port tx_vid_clk tx_vid_clk clk Input 1

# +-----------------------------------
# | connection point tx_video_in
# | 
add_interface tx_video_in conduit end
# tx_vid_data has variable port-width, added in elaboration
# tx_vid_v_sync has variable port-width, added in elaboration
# tx_vid_h_sync has variable port-width, added in elaboration
# tx_vid_f has variable port-width, added in elaboration
# tx_vid_de has variable port-width, added in elaboration

# +-----------------------------------
# | connection point rx_vid_clk
# | 
add_interface rx_vid_clk clock end
set_interface_property rx_vid_clk clockRate 0
add_interface_port rx_vid_clk rx_vid_clk clk Input 1

# +-----------------------------------
# | connection point rx_video_out
# | 
add_interface rx_video_out conduit end
# rx_vid_valid has variable port-width, added in elaboration
add_interface_port rx_video_out rx_vid_sol export Output 1
add_interface_port rx_video_out rx_vid_eol export Output 1
add_interface_port rx_video_out rx_vid_sof export Output 1
add_interface_port rx_video_out rx_vid_eof export Output 1
add_interface_port rx_video_out rx_vid_locked export Output 1
add_interface_port rx_video_out rx_vid_overflow export Output 1
# rx_vid_data has variable port-width, added in elaboration

# +-----------------------------------
# | connection point rx_vid_st_reset
# | 
add_interface rx_vid_st_reset reset end
set_interface_property rx_vid_st_reset associatedClock rx_vid_clk
set_interface_property rx_vid_st_reset synchronousEdges DEASSERT
add_interface_port rx_vid_st_reset rx_vid_st_reset reset Input 1

# +-----------------------------------
# | connection point rx_video_out_st
# | 
add_interface rx_video_out_st avalon_streaming start
set_interface_property rx_video_out_st associatedClock rx_vid_clk
set_interface_property rx_video_out_st associatedReset rx_vid_st_reset
set_interface_property rx_video_out_st errorDescriptor ""
set_interface_property rx_video_out_st maxChannel 0
set_interface_property rx_video_out_st readyLatency 1

add_interface_port rx_video_out_st rx_vid_st_ready ready Input 1
add_interface_port rx_video_out_st rx_vid_st_valid valid Output 1
# rx_vid_st_data has variable port-width, added in elaboration
add_interface_port rx_video_out_st rx_vid_st_sop startofpacket Output 1
add_interface_port rx_video_out_st rx_vid_st_eop endofpacket Output 1

# +----------------------------------------------------------------------
# | Stream 1
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point rx1_vid_clk
# | 
add_interface rx1_vid_clk clock end
set_interface_property rx1_vid_clk clockRate 0
add_interface_port rx1_vid_clk rx1_vid_clk clk Input 1

# +-----------------------------------
# | connection point rx1_video_out
# | 
add_interface rx1_video_out conduit end
# rx1_vid_valid has variable port-width, added in elaboration
add_interface_port rx1_video_out rx1_vid_sol export Output 1
add_interface_port rx1_video_out rx1_vid_eol export Output 1
add_interface_port rx1_video_out rx1_vid_sof export Output 1
add_interface_port rx1_video_out rx1_vid_eof export Output 1
add_interface_port rx1_video_out rx1_vid_locked export Output 1
add_interface_port rx1_video_out rx1_vid_overflow export Output 1

# rx1_vid_data has variable port-width, added in elaboration

# +-----------------------------------
# | connection point rx1_vid_st_reset
# | 
add_interface rx1_vid_st_reset reset end
set_interface_property rx1_vid_st_reset associatedClock rx1_vid_clk
set_interface_property rx1_vid_st_reset synchronousEdges DEASSERT
add_interface_port rx1_vid_st_reset rx1_vid_st_reset reset Input 1

# +-----------------------------------
# | connection point rx1_video_out_st
# | 
add_interface rx1_video_out_st avalon_streaming start
set_interface_property rx1_video_out_st associatedClock rx1_vid_clk
set_interface_property rx1_video_out_st associatedReset rx1_vid_st_reset
set_interface_property rx1_video_out_st errorDescriptor ""
set_interface_property rx1_video_out_st maxChannel 0
set_interface_property rx1_video_out_st readyLatency 1

add_interface_port rx1_video_out_st rx1_vid_st_ready ready Input 1
add_interface_port rx1_video_out_st rx1_vid_st_valid valid Output 1
# rx1_vid_st_data has variable port-width, added in elaboration
add_interface_port rx1_video_out_st rx1_vid_st_sop startofpacket Output 1
add_interface_port rx1_video_out_st rx1_vid_st_eop endofpacket Output 1

# +----------------------------------------------------------------------
# | Stream 2
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point rx2_vid_clk
# | 
add_interface rx2_vid_clk clock end
set_interface_property rx2_vid_clk clockRate 0
add_interface_port rx2_vid_clk rx2_vid_clk clk Input 1

# +-----------------------------------
# | connection point rx2_video_out
# | 
add_interface rx2_video_out conduit end
# rx2_vid_valid has variable port-width, added in elaboration
add_interface_port rx2_video_out rx2_vid_sol export Output 1
add_interface_port rx2_video_out rx2_vid_eol export Output 1
add_interface_port rx2_video_out rx2_vid_sof export Output 1
add_interface_port rx2_video_out rx2_vid_eof export Output 1
add_interface_port rx2_video_out rx2_vid_locked export Output 1
add_interface_port rx2_video_out rx2_vid_overflow export Output 1
# rx2_vid_data has variable port-width, added in elaboration

# +-----------------------------------
# | connection point rx2_vid_st_reset
# | 
add_interface rx2_vid_st_reset reset end
set_interface_property rx2_vid_st_reset associatedClock rx2_vid_clk
set_interface_property rx2_vid_st_reset synchronousEdges DEASSERT
add_interface_port rx2_vid_st_reset rx2_vid_st_reset reset Input 1

# +-----------------------------------
# | connection point rx2_video_out_st
# | 
add_interface rx2_video_out_st avalon_streaming start
set_interface_property rx2_video_out_st associatedClock rx2_vid_clk
set_interface_property rx2_video_out_st associatedReset rx2_vid_st_reset
set_interface_property rx2_video_out_st errorDescriptor ""
set_interface_property rx2_video_out_st maxChannel 0
set_interface_property rx2_video_out_st readyLatency 1

add_interface_port rx2_video_out_st rx2_vid_st_ready ready Input 1
add_interface_port rx2_video_out_st rx2_vid_st_valid valid Output 1
# rx2_vid_st_data has variable port-width, added in elaboration
add_interface_port rx2_video_out_st rx2_vid_st_sop startofpacket Output 1
add_interface_port rx2_video_out_st rx2_vid_st_eop endofpacket Output 1

# +----------------------------------------------------------------------
# | Stream 3
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point rx3_vid_clk
# | 
add_interface rx3_vid_clk clock end
set_interface_property rx3_vid_clk clockRate 0
add_interface_port rx3_vid_clk rx3_vid_clk clk Input 1

# +-----------------------------------
# | connection point rx3_video_out
# | 
add_interface rx3_video_out conduit end
# rx3_vid_valid has variable port-width, added in elaboration
add_interface_port rx3_video_out rx3_vid_sol export Output 1
add_interface_port rx3_video_out rx3_vid_eol export Output 1
add_interface_port rx3_video_out rx3_vid_sof export Output 1
add_interface_port rx3_video_out rx3_vid_eof export Output 1
add_interface_port rx3_video_out rx3_vid_locked export Output 1
add_interface_port rx3_video_out rx3_vid_overflow export Output 1
# rx3_vid_data has variable port-width, added in elaboration

# +-----------------------------------
# | connection point rx3_vid_st_reset
# | 
add_interface rx3_vid_st_reset reset end
set_interface_property rx3_vid_st_reset associatedClock rx3_vid_clk
set_interface_property rx3_vid_st_reset synchronousEdges DEASSERT
add_interface_port rx3_vid_st_reset rx3_vid_st_reset reset Input 1

# +-----------------------------------
# | connection point rx3_video_out_st
# | 
add_interface rx3_video_out_st avalon_streaming start
set_interface_property rx3_video_out_st associatedClock rx3_vid_clk
set_interface_property rx3_video_out_st associatedReset rx3_vid_st_reset
set_interface_property rx3_video_out_st errorDescriptor ""
set_interface_property rx3_video_out_st maxChannel 0
set_interface_property rx3_video_out_st readyLatency 1

add_interface_port rx3_video_out_st rx3_vid_st_ready ready Input 1
add_interface_port rx3_video_out_st rx3_vid_st_valid valid Output 1
# rx3_vid_st_data has variable port-width, added in elaboration
add_interface_port rx3_video_out_st rx3_vid_st_sop startofpacket Output 1
add_interface_port rx3_video_out_st rx3_vid_st_eop endofpacket Output 1

# +----------------------------------------------------------------------
# | AUX domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point aux_clk
# | 
add_interface aux_clk clock end
set_interface_property aux_clk clockRate 16000000
add_interface_port aux_clk aux_clk clk Input 1
set_interface_property aux_clk ENABLED true

# +-----------------------------------
# | connection point aux_reset
# | 
add_interface aux_reset reset end
set_interface_property aux_reset associatedClock aux_clk
add_interface_port aux_reset aux_reset reset Input 1

# +-----------------------------------
# | connection point tx_aux
# | 
add_interface tx_aux conduit end
add_interface_port tx_aux tx_aux_in export Input 1
add_interface_port tx_aux tx_aux_out export Output 1
add_interface_port tx_aux tx_aux_oe export Output 1
add_interface_port tx_aux tx_hpd export Input 1

# +-----------------------------------
# | connection point tx_aux_debug
# | 
add_interface tx_aux_debug avalon_streaming start
set_interface_property tx_aux_debug associatedClock aux_clk
set_interface_property tx_aux_debug associatedReset aux_reset
set_interface_property tx_aux_debug dataBitsPerSymbol 32
set_interface_property tx_aux_debug errorDescriptor ""
set_interface_property tx_aux_debug maxChannel 1
set_interface_property tx_aux_debug readyLatency 0

add_interface_port tx_aux_debug tx_aux_debug_data data Output 32
add_interface_port tx_aux_debug tx_aux_debug_valid valid Output 1
add_interface_port tx_aux_debug tx_aux_debug_sop startofpacket Output 1
add_interface_port tx_aux_debug tx_aux_debug_eop endofpacket Output 1
add_interface_port tx_aux_debug tx_aux_debug_err error Output 1
add_interface_port tx_aux_debug tx_aux_debug_cha channel Output 1

# +-----------------------------------
# | connection point rx_aux
# | 
add_interface rx_aux conduit end
add_interface_port rx_aux rx_aux_in export Input 1
add_interface_port rx_aux rx_aux_out export Output 1
add_interface_port rx_aux rx_aux_oe export Output 1
add_interface_port rx_aux rx_hpd export Output 1
add_interface_port rx_aux rx_cable_detect export Input 1
add_interface_port rx_aux rx_pwr_detect export Input 1

# +-----------------------------------
# | connection point rx_aux_debug
# | 
add_interface rx_aux_debug avalon_streaming start
set_interface_property rx_aux_debug associatedClock aux_clk
set_interface_property rx_aux_debug associatedReset aux_reset
set_interface_property rx_aux_debug dataBitsPerSymbol 32
set_interface_property rx_aux_debug errorDescriptor ""
set_interface_property rx_aux_debug maxChannel 1
set_interface_property rx_aux_debug readyLatency 0

add_interface_port rx_aux_debug rx_aux_debug_data data Output 32
add_interface_port rx_aux_debug rx_aux_debug_valid valid Output 1
add_interface_port rx_aux_debug rx_aux_debug_sop startofpacket Output 1
add_interface_port rx_aux_debug rx_aux_debug_eop endofpacket Output 1
add_interface_port rx_aux_debug rx_aux_debug_err error Output 1
add_interface_port rx_aux_debug rx_aux_debug_cha channel Output 1

# +-----------------------------------
# | connection point rx_edid
# | 
add_interface rx_edid avalon start
set_interface_property rx_edid addressUnits SYMBOLS
set_interface_property rx_edid associatedClock aux_clk
set_interface_property rx_edid associatedReset aux_reset
set_interface_property rx_edid burstOnBurstBoundariesOnly false
set_interface_property rx_edid doStreamReads false
set_interface_property rx_edid doStreamWrites false
set_interface_property rx_edid linewrapBursts false
set_interface_property rx_edid readLatency 0

add_interface_port rx_edid rx_edid_address address Output 8
add_interface_port rx_edid rx_edid_readdata readdata Input 8
add_interface_port rx_edid rx_edid_writedata writedata Output 8
add_interface_port rx_edid rx_edid_read read Output 1
add_interface_port rx_edid rx_edid_write write Output 1
add_interface_port rx_edid rx_edid_waitrequest waitrequest Input 1

# +----------------------------------------------------------------------
# | Debug domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point rx_params
# | 
add_interface rx_params conduit end
add_interface_port rx_params rx_lane_count export Output 5

# +-----------------------------------
# | connection point rxN_stream
# | 
add_interface rx_stream conduit end
# rx_stream_data has variable port-width, added in elaboration
# rx_stream_ctrl has variable port-width, added in elaboration
add_interface_port rx_stream rx_stream_valid export Output 1
add_interface_port rx_stream rx_stream_clk export Output 1

add_interface rx1_stream conduit end
# rx1_stream_data has variable port-width, added in elaboration
# rx1_stream_ctrl has variable port-width, added in elaboration
add_interface_port rx1_stream rx1_stream_valid export Output 1
add_interface_port rx1_stream rx1_stream_clk export Output 1

add_interface rx2_stream conduit end
# rx2_stream_data has variable port-width, added in elaboration
# rx2_stream_ctrl has variable port-width, added in elaboration
add_interface_port rx2_stream rx2_stream_valid export Output 1
add_interface_port rx2_stream rx2_stream_clk export Output 1

add_interface rx3_stream conduit end
# rx3_stream_data has variable port-width, added in elaboration
# rx3_stream_ctrl has variable port-width, added in elaboration
add_interface_port rx3_stream rx3_stream_valid export Output 1
add_interface_port rx3_stream rx3_stream_clk export Output 1

# +----------------------------------------------------------------------
# | Secondary data domain
# +----------------------------------------------------------------------

# +-----------------------------------
# | connection point tx_xcvr_clkout
# | 
add_interface tx_xcvr_clkout clock start
set_interface_property tx_xcvr_clkout clockRate 0
add_interface_port tx_xcvr_clkout tx_xcvr_clkout clk Output 1

# +-----------------------------------
# | connection point rx_xcvr_clkout
# | 
add_interface rx_xcvr_clkout clock start
set_interface_property rx_xcvr_clkout clockRate 0
add_interface_port rx_xcvr_clkout rx_xcvr_clkout clk Output 1

# +-----------------------------------
# | connection point tx_msa_conduit
# | 
add_interface tx_msa_conduit conduit end
add_interface_port tx_msa_conduit tx_msa export Input 192

# +-----------------------------------
# | connection point rxN_msa_conduit
# | 
add_interface rx_msa_conduit conduit end
add_interface_port rx_msa_conduit rx_msa export Output 217
add_interface rx1_msa_conduit conduit end
add_interface_port rx1_msa_conduit rx1_msa export Output 217
add_interface rx2_msa_conduit conduit end
add_interface_port rx2_msa_conduit rx2_msa export Output 217
add_interface rx3_msa_conduit conduit end
add_interface_port rx3_msa_conduit rx3_msa export Output 217

# +-----------------------------------
# | connection point tx_ss
# | 
add_interface tx_ss avalon_streaming end
set_interface_property tx_ss associatedClock tx_xcvr_clkout
set_interface_property tx_ss associatedReset reset
set_interface_property tx_ss dataBitsPerSymbol 128
set_interface_property tx_ss errorDescriptor ""
set_interface_property tx_ss maxChannel 0
set_interface_property tx_ss readyLatency 0

add_interface_port tx_ss tx_ss_ready ready Output 1
add_interface_port tx_ss tx_ss_valid valid Input 1
add_interface_port tx_ss tx_ss_data data Input 128
add_interface_port tx_ss tx_ss_sop startofpacket Input 1
add_interface_port tx_ss tx_ss_eop endofpacket Input 1

# +-----------------------------------
# | connection point rx_ss
# | 
add_interface rx_ss avalon_streaming start
set_interface_property rx_ss associatedClock rx_xcvr_clkout
set_interface_property rx_ss associatedReset reset
set_interface_property rx_ss dataBitsPerSymbol 160
set_interface_property rx_ss errorDescriptor ""
set_interface_property rx_ss maxChannel 0
set_interface_property rx_ss readyLatency 1

add_interface_port rx_ss rx_ss_valid valid Output 1
add_interface_port rx_ss rx_ss_data data Output 160
add_interface_port rx_ss rx_ss_sop startofpacket Output 1
add_interface_port rx_ss rx_ss_eop endofpacket Output 1  

# +-----------------------------------
# | connection point rx1_ss
# | 
add_interface rx1_ss avalon_streaming start
set_interface_property rx1_ss associatedClock rx_ss_clk
set_interface_property rx1_ss associatedReset av_clk_reset
set_interface_property rx1_ss dataBitsPerSymbol 160
set_interface_property rx1_ss errorDescriptor ""
set_interface_property rx1_ss maxChannel 0
set_interface_property rx1_ss readyLatency 1

add_interface_port rx1_ss rx1_ss_valid valid Output 1
add_interface_port rx1_ss rx1_ss_data data Output 160
add_interface_port rx1_ss rx1_ss_sop startofpacket Output 1
add_interface_port rx1_ss rx1_ss_eop endofpacket Output 1  

# +-----------------------------------
# | connection point rx2_ss
# | 
add_interface rx2_ss avalon_streaming start
set_interface_property rx2_ss associatedClock rx_ss_clk
set_interface_property rx2_ss associatedReset av_clk_reset
set_interface_property rx2_ss dataBitsPerSymbol 160
set_interface_property rx2_ss errorDescriptor ""
set_interface_property rx2_ss maxChannel 0
set_interface_property rx2_ss readyLatency 1

add_interface_port rx2_ss rx2_ss_valid valid Output 1
add_interface_port rx2_ss rx2_ss_data data Output 160
add_interface_port rx2_ss rx2_ss_sop startofpacket Output 1
add_interface_port rx2_ss rx2_ss_eop endofpacket Output 1  

# +-----------------------------------
# | connection point rx3_ss
# | 
add_interface rx3_ss avalon_streaming start
set_interface_property rx3_ss associatedClock rx_ss_clk
set_interface_property rx3_ss associatedReset av_clk_reset
set_interface_property rx3_ss dataBitsPerSymbol 160
set_interface_property rx3_ss errorDescriptor ""
set_interface_property rx3_ss maxChannel 0
set_interface_property rx3_ss readyLatency 1

add_interface_port rx3_ss rx3_ss_valid valid Output 1
add_interface_port rx3_ss rx3_ss_data data Output 160
add_interface_port rx3_ss rx3_ss_sop startofpacket Output 1
add_interface_port rx3_ss rx3_ss_eop endofpacket Output 1  

# +-----------------------------------
# | connection point tx_audio_clk
# | 
add_interface tx_audio_clk clock end
set_interface_property tx_audio_clk clockRate 0
add_interface_port tx_audio_clk tx_audio_clk export Input 1

# +-----------------------------------
# | connection point tx_audio
# | 
add_interface tx_audio conduit  end
# tx_audio_lpcm_data has variable port-width, added in elaboration
add_interface_port tx_audio tx_audio_valid export Input 1
add_interface_port tx_audio tx_audio_mute export Input 1

# +-----------------------------------
# | connection point rxN_audio
# | 
add_interface rx_audio conduit  end
# rx_audio_lpcm_data has variable port-width, added in elaboration
add_interface_port rx_audio rx_audio_valid export Output 1
add_interface_port rx_audio rx_audio_mute export Output 1
add_interface_port rx_audio rx_audio_infoframe export Output 40
  
add_interface rx1_audio conduit  end
# rx1_audio_lpcm_data has variable port-width, added in elaboration
add_interface_port rx1_audio rx1_audio_valid export Output 1
add_interface_port rx1_audio rx1_audio_mute export Output 1
add_interface_port rx1_audio rx1_audio_infoframe export Output 40

add_interface rx2_audio conduit  end
# rx2_audio_lpcm_data has variable port-width, added in elaboration
add_interface_port rx2_audio rx2_audio_valid export Output 1
add_interface_port rx2_audio rx2_audio_mute export Output 1
add_interface_port rx2_audio rx2_audio_infoframe export Output 40

add_interface rx3_audio conduit  end
# rx3_audio_lpcm_data has variable port-width, added in elaboration
add_interface_port rx3_audio rx3_audio_valid export Output 1
add_interface_port rx3_audio rx3_audio_mute export Output 1
add_interface_port rx3_audio rx3_audio_infoframe export Output 40
  
# +-----------------------------------
# | connection point tx_hdcp
# | 
# Add the HDCP interfaces even if HDCP is not included
# This allows us to tie them off properly for simulation
add_interface tx_hdcp conduit end
add_interface_port tx_hdcp tx_hdcp_akeys_dat export Input 56
add_interface_port tx_hdcp tx_hdcp_akeys_ksv export Input 40
add_interface_port tx_hdcp tx_hdcp_akeys_sel export Output 7

# +-----------------------------------
# | connection point rx_hdcp
# | 
# Add the HDCP interfaces even if HDCP is not included
# This allows us to tie them off properly for simulation
add_interface rx_hdcp conduit end
add_interface_port rx_hdcp rx_hdcp_bkeys_dat export Input 56
add_interface_port rx_hdcp rx_hdcp_bkeys_ksv export Input 40
add_interface_port rx_hdcp rx_hdcp_bkeys_sel export Output 7


# +-----------------------------------
# | ELABORATION CALLBACK
# +-----------------------------------

set_module_property ELABORATION_CALLBACK dp_elaboration_callback

proc dp_elaboration_callback {} {
	
  variable include_mst
  variable include_hdcp

	## Get the paramter values that will impact the optional ports and
	## the variable port widths
	set support_dp_tx [get_parameter_value TX_SUPPORT_DP]
	set support_dp_rx [get_parameter_value RX_SUPPORT_DP]
	set tx_lane_count [get_parameter_value TX_MAX_LANE_COUNT]
	set rx_lane_count [get_parameter_value RX_MAX_LANE_COUNT]

	## Use channels for calculating the XCVR reconfig port width and
	## andy other ports dependent on both RX and TX lane counts. 
	## Also use for generating messages about interfaces. 
	## Keep lane count even if RX or TX disabled so that terminated
	## ports have the correct width
	if { $support_dp_tx } {
		set tx_channels $tx_lane_count
	} else {
		set tx_channels 0
	}

	if { $support_dp_rx } {
		set rx_channels $rx_lane_count
	} else {
		set rx_channels 0
	}

	# Get the device family to determine legal link rates
    set device_family [get_parameter_value device_family]
	
	# Only Cyclone V does not support HBR2 support in this release
	if { ($device_family == "Cyclone V") } {
		set_parameter_property TX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps}
		set_parameter_property RX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps}
	} else {
		set_parameter_property TX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps 20:5.4Gbps}
		set_parameter_property RX_MAX_LINK_RATE ALLOWED_RANGES {6:1.62Gbps 10:2.70Gbps 20:5.4Gbps}
	}

	set rx_aux_debug [get_parameter_value RX_AUX_DEBUG]
	set tx_aux_debug [get_parameter_value TX_AUX_DEBUG]
	set rx_aux_gpu [get_parameter_value RX_AUX_GPU]
	set tx_link_rate [get_parameter_value TX_MAX_LINK_RATE]
	set rx_link_rate [get_parameter_value RX_MAX_LINK_RATE]
	set ext_transceivers 0
	set tx_import_msa [get_parameter_value TX_IMPORT_MSA]
	set rx_export_msa [get_parameter_value RX_EXPORT_MSA]
	set support_tx_ss [get_parameter_value TX_SUPPORT_SS]
	set support_rx_ss [get_parameter_value RX_SUPPORT_SS]
	set tx_support_audio [get_parameter_value TX_SUPPORT_AUDIO]	
	set tx_audio_chans   [get_parameter_value TX_AUDIO_CHANS]
	set rx_support_audio [get_parameter_value RX_SUPPORT_AUDIO]	
	set rx_audio_chans   [get_parameter_value RX_AUDIO_CHANS]
	if { $include_mst } {
		# MST
		set rx_support_mst [get_parameter_value RX_SUPPORT_MST]
		set rx_num_of_streams [get_parameter_value RX_MAX_NUM_OF_STREAMS]
	} else {
		set rx_support_mst 0
		set rx_num_of_streams 0
	}

	# +----------------------------------------------------------------------
	# | Main clock domain
	# +----------------------------------------------------------------------
	if { $support_dp_rx || $support_dp_tx } {            
		set_interface_property clk ENABLED true 
		set_interface_property reset ENABLED true
	} else { 
		set_interface_property clk ENABLED false 
		set_interface_property reset ENABLED false
	}
 
	if { $support_dp_tx } {
		set_interface_property tx_mgmt ENABLED true 
		set_interface_property tx_mgmt_interrupt ENABLED true
	} else {
		set_interface_property tx_mgmt_interrupt ENABLED false
		set_interface_property tx_mgmt ENABLED false 
	}
	
	# RX AUX management needed if using debug or GPU control
	if { $support_dp_rx && ($rx_aux_debug || $rx_aux_gpu)} {              
		set_interface_property rx_mgmt ENABLED true 
		set_interface_property rx_mgmt_interrupt ENABLED true
	} else {
		set_interface_property rx_mgmt_interrupt ENABLED false
		set_interface_property rx_mgmt ENABLED false 
	}

	# +----------------------------------------------------------------------
	# | XCVR Mgmt domain
	# +----------------------------------------------------------------------

	if { $support_dp_rx || $support_dp_tx } {            
		set_interface_property xcvr_mgmt_clk ENABLED true 
	} else { 
		set_interface_property xcvr_mgmt_clk ENABLED false 
	}

	if { $support_dp_rx || $support_dp_tx } {            
		set_interface_property xcvr_refclk ENABLED true 
	} else { 
		set_interface_property xcvr_refclk ENABLED false 
	}

	add_interface_port tx_serial_data tx_serial_data export output $tx_lane_count
	if { $support_dp_tx } {
		set_interface_property tx_serial_data ENABLED true
	} else {
		set_interface_property tx_serial_data ENABLED false
	}

	add_interface_port rx_serial_data rx_serial_data export input $rx_lane_count
	if { $support_dp_rx } {
		set_interface_property rx_serial_data ENABLED true
	} else {
		set_interface_property rx_serial_data ENABLED false
	}

	if { $support_dp_tx } {
		set_interface_property tx_reconfig ENABLED true
	} else {
		set_interface_property tx_reconfig ENABLED false
	}

	add_interface_port tx_analog_reconfig tx_vod export output [ expr ($tx_lane_count * 2)]
	add_interface_port tx_analog_reconfig tx_emp export output [ expr ($tx_lane_count * 2)]
  
	set tx_support_analog_reconfig [get_parameter_value TX_SUPPORT_ANALOG_RECONFIG]

	if { $support_dp_tx && $tx_support_analog_reconfig } {
		set_interface_property tx_analog_reconfig ENABLED true
	} else {
		set_interface_property tx_analog_reconfig ENABLED false
	}
   
	if { $support_dp_rx} {
		set_interface_property rx_reconfig ENABLED true
	} else {
		set_interface_property rx_reconfig ENABLED false
	}

	# Use channels not lane count since the channels will be 0 if the
	# RX or TX interface is disabled. 
	set width_conduit_reconfig_to_xcvr [ expr   ($rx_channels*70) + ($tx_channels*2*70) ]  
	set width_conduit_reconfig_from_xcvr [ expr   ($rx_channels*46) + ($tx_channels*2*46) ]

	add_interface_port xcvr_reconfig reconfig_to_xcvr export input $width_conduit_reconfig_to_xcvr
	add_interface_port xcvr_reconfig reconfig_from_xcvr export output $width_conduit_reconfig_from_xcvr

	if { $support_dp_rx || $support_dp_tx } {            
		set_interface_property xcvr_reconfig ENABLED true 
	} else { 
		set_interface_property xcvr_reconfig ENABLED false 
	}

	# +----------------------------------------------------------------------
	# | Video domain
	# +----------------------------------------------------------------------

	# Configure TX Image input data width            
	set tx_bps [get_parameter_value TX_VIDEO_BPS]
	set tx_pixels_per_clock [get_parameter_value TX_PIXELS_PER_CLOCK]
	set tx_data_width [expr $tx_bps * 3 * $tx_pixels_per_clock ]

	add_interface_port tx_video_in tx_vid_data export Input $tx_data_width
	add_interface_port tx_video_in tx_vid_v_sync export Input $tx_pixels_per_clock
	add_interface_port tx_video_in tx_vid_h_sync export Input $tx_pixels_per_clock
	add_interface_port tx_video_in tx_vid_f export Input $tx_pixels_per_clock
	add_interface_port tx_video_in tx_vid_de export Input $tx_pixels_per_clock

	if { $support_dp_tx } {
		set_interface_property tx_vid_clk ENABLED true 
		set_interface_property tx_video_in ENABLED true 
	} else {
		set_interface_property tx_vid_clk ENABLED false 
		set_interface_property tx_video_in ENABLED false 
	}

	# Configure RX Image stream
	set output_format [get_parameter_value RX_IMAGE_OUT_FORMAT]  
	set rx_bps [get_parameter_value RX_VIDEO_BPS]
	set rx_pixels_per_clock [get_parameter_value RX_PIXELS_PER_CLOCK]
	set rx_data_width [expr $rx_bps * 3 * $rx_pixels_per_clock ]
	set rx_valid_data_width [expr $rx_pixels_per_clock ]
  
	set_interface_property rx_video_out_st dataBitsPerSymbol [expr $rx_bps * $rx_pixels_per_clock ] 
	add_interface_port rx_video_out_st rx_vid_st_data data Output $rx_data_width
	add_interface_port rx_video_out rx_vid_data export Output $rx_data_width
	add_interface_port rx_video_out rx_vid_valid export Output $rx_valid_data_width

	set_interface_property rx1_video_out_st dataBitsPerSymbol [expr $rx_bps * $rx_pixels_per_clock ] 
	add_interface_port rx1_video_out_st rx1_vid_st_data data Output $rx_data_width
	add_interface_port rx1_video_out rx1_vid_data export Output $rx_data_width
	add_interface_port rx1_video_out rx1_vid_valid export Output $rx_valid_data_width

	set_interface_property rx2_video_out_st dataBitsPerSymbol [expr $rx_bps * $rx_pixels_per_clock ] 
	add_interface_port rx2_video_out_st rx2_vid_st_data data Output $rx_data_width
	add_interface_port rx2_video_out rx2_vid_data export Output $rx_data_width
	add_interface_port rx2_video_out rx2_vid_valid export Output $rx_valid_data_width

	set_interface_property rx3_video_out_st dataBitsPerSymbol [expr $rx_bps * $rx_pixels_per_clock ] 
	add_interface_port rx3_video_out_st rx3_vid_st_data data Output $rx_data_width
	add_interface_port rx3_video_out rx3_vid_data export Output $rx_data_width
	add_interface_port rx3_video_out rx3_vid_valid export Output $rx_valid_data_width

	# Temporary check to enable selection of Image output if using
	# depricated version
	if {[expr {$output_format} == 0]} {
		# Enable the UI to select a video mode and warn users
		# that this interface is depricated. Remove completely
		# before release.
		set_parameter_property RX_IMAGE_OUT_FORMAT VISIBLE true
		send_message warning "Video output port type Avalon-ST is deprecated. Please switch to Image Port. This interface will be removed in a future build."
	}

	# First disable all the RX clocks and resets and video streams
	set_interface_property rx_vid_clk ENABLED false
	set_interface_property rx1_vid_clk ENABLED false
	set_interface_property rx2_vid_clk ENABLED false
	set_interface_property rx3_vid_clk ENABLED false

	set_interface_property rx_video_out ENABLED false
	set_interface_property rx1_video_out ENABLED false
	set_interface_property rx2_video_out ENABLED false
	set_interface_property rx3_video_out ENABLED false

	set_interface_property rx_vid_st_reset ENABLED false
	set_interface_property rx1_vid_st_reset ENABLED false
	set_interface_property rx2_vid_st_reset ENABLED false
	set_interface_property rx3_vid_st_reset ENABLED false

	set_interface_property rx_video_out_st ENABLED false  
	set_interface_property rx1_video_out_st ENABLED false  
	set_interface_property rx2_video_out_st ENABLED false  
	set_interface_property rx3_video_out_st ENABLED false  

	# also terminate the rx_cable_detect and rx_pwr_detect ports
	# they are only used in MST mode
	set_port_property rx_cable_detect TERMINATION true
	set_port_property rx_cable_detect TERMINATION_VALUE 1
	set_port_property rx_pwr_detect TERMINATION true
	set_port_property rx_pwr_detect TERMINATION_VALUE 1

	# Now turn them on for the different stream counts

	# Just need RX for base stream
	if { $support_dp_rx } { 
		set_interface_property rx_vid_clk ENABLED true

		if {$output_format} {
			set_interface_property rx_video_out ENABLED true
		} else {
			set_interface_property rx_video_out_st ENABLED true 
			set_interface_property rx_vid_st_reset ENABLED true
		} 

		# enable cable detect and pwr detect if MST
		if {$rx_support_mst} {
			set_port_property rx_cable_detect TERMINATION false
			set_port_property rx_pwr_detect TERMINATION false
		}
	}   

	# Need MST enabled and the correct number of streams
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 1] } {
		set_interface_property rx1_vid_clk ENABLED true

		if {$output_format} {
			set_interface_property rx1_video_out ENABLED true
		} else {
			set_interface_property rx1_video_out_st ENABLED true 
			set_interface_property rx1_vid_st_reset ENABLED true
		} 
	}   

	# Need MST enabled and the correct number of streams
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 2] } {
		set_interface_property rx2_vid_clk ENABLED true

		if {$output_format} {
			set_interface_property rx2_video_out ENABLED true
		} else {
			set_interface_property rx2_video_out_st ENABLED true 
			set_interface_property rx2_vid_st_reset ENABLED true
		} 
	}   
	# Need MST enabled and the correct number of streams
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 3] } {
		set_interface_property rx3_vid_clk ENABLED true

		if {$output_format} {
			set_interface_property rx3_video_out ENABLED true
		} else {
			set_interface_property rx3_video_out_st ENABLED true 
			set_interface_property rx3_vid_st_reset ENABLED true
		} 
	}   
	# +----------------------------------------------------------------------
	# | AUX domain
	# +----------------------------------------------------------------------

	if { $support_dp_rx || $support_dp_tx } {            
		set_interface_property aux_clk ENABLED true 
		set_interface_property aux_reset ENABLED true 
	} else { 
		set_interface_property aux_clk ENABLED false 
		set_interface_property aux_reset ENABLED false 
	}

	if { $support_dp_tx } {
		set_interface_property tx_aux ENABLED true 
	} else {
		set_interface_property tx_aux ENABLED false 
	}
	
	if { $tx_aux_debug && $support_dp_tx} {
		set_interface_property tx_aux_debug ENABLED true 
    } else {
		set_interface_property tx_aux_debug ENABLED false  
	}  	
    
	if { $support_dp_rx } {
		set_interface_property rx_aux ENABLED true 
	} else {
		set_interface_property rx_aux ENABLED false 
	}

	if { $rx_aux_debug && $support_dp_rx} {
		set_interface_property rx_aux_debug ENABLED true 
    } else {
		set_interface_property rx_aux_debug ENABLED false  
	}  

	# Why is EDID support tied to the AUX GPU support
	if { $support_dp_rx & ~$rx_aux_gpu} {
		set_interface_property rx_edid ENABLED true 
	} else {
		set_interface_property rx_edid ENABLED false
	} 

	# +----------------------------------------------------------------------
	# | Debug domain
	# +----------------------------------------------------------------------

	# set the rxN_stream data & ctrl widths
	set rx_symbols_per_clock [get_parameter_value RX_SYMBOLS_PER_CLOCK]
	set tx_symbols_per_clock [get_parameter_value TX_SYMBOLS_PER_CLOCK]
	add_interface_port rx_stream rx_stream_data export Output [expr (4*8*$rx_symbols_per_clock)]
	add_interface_port rx_stream rx_stream_ctrl export Output [expr (4*1*$rx_symbols_per_clock)]
	add_interface_port rx1_stream rx1_stream_data export Output [expr (4*8*$rx_symbols_per_clock)]
	add_interface_port rx1_stream rx1_stream_ctrl export Output [expr (4*1*$rx_symbols_per_clock)]
	add_interface_port rx2_stream rx2_stream_data export Output [expr (4*8*$rx_symbols_per_clock)]
	add_interface_port rx2_stream rx2_stream_ctrl export Output [expr (4*1*$rx_symbols_per_clock)]
	add_interface_port rx3_stream rx3_stream_data export Output [expr (4*8*$rx_symbols_per_clock)]
	add_interface_port rx3_stream rx3_stream_ctrl export Output [expr (4*1*$rx_symbols_per_clock)]


	if { $support_dp_rx } {
		set_interface_property rx_params ENABLED true 
	} else {
		set_interface_property rx_params ENABLED false 
	}

	# Disable all stream outputs and then enable based on count
	set_interface_property rx_stream ENABLED false
	set_interface_property rx1_stream ENABLED false
	set_interface_property rx2_stream ENABLED false
	set_interface_property rx3_stream ENABLED false

	if { $support_dp_rx } { 
		set_interface_property rx_stream ENABLED true
	}   
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 1] } {
		set_interface_property rx1_stream ENABLED true 
	}
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 2] } {
		set_interface_property rx2_stream ENABLED true 
	} 
	if { $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 3] } {
		set_interface_property rx3_stream ENABLED true 
	}

	# +----------------------------------------------------------------------
	# | Secondary data domain
	# +----------------------------------------------------------------------


	if { $support_dp_tx && ($tx_import_msa || $support_tx_ss)} {
		set_interface_property tx_xcvr_clkout ENABLED true 
	} else {
		set_interface_property tx_xcvr_clkout ENABLED false 
	}
	
	if { $support_dp_rx && ($rx_export_msa || $support_rx_ss)} {
		set_interface_property rx_xcvr_clkout ENABLED true 
	} else {
		set_interface_property rx_xcvr_clkout ENABLED false 
	}

	if { $support_dp_tx && $tx_import_msa} {
		set_interface_property tx_msa_conduit ENABLED true 
	} else {
		set_interface_property tx_msa_conduit ENABLED false 
	}

	# Disable all RX MSA interfaces and then enable based on stream
	# count
	set_interface_property rx_msa_conduit ENABLED false
	set_interface_property rx1_msa_conduit ENABLED false
	set_interface_property rx2_msa_conduit ENABLED false
	set_interface_property rx3_msa_conduit ENABLED false

	if { $support_dp_rx && $rx_export_msa} {
		set_interface_property rx_msa_conduit ENABLED true
	}	
	if { $support_dp_rx && $rx_export_msa && $rx_support_mst && [expr {$rx_num_of_streams} > 1] } {
		set_interface_property rx1_msa_conduit ENABLED true
	}	
	if { $support_dp_rx && $rx_export_msa && $rx_support_mst && [expr {$rx_num_of_streams} > 2] } {
		set_interface_property rx2_msa_conduit ENABLED true
	}	
	if { $support_dp_rx && $rx_export_msa && $rx_support_mst && [expr {$rx_num_of_streams} > 3] } {
		set_interface_property rx3_msa_conduit ENABLED true
	}	

	if { $support_dp_tx && $support_tx_ss} {
		set_interface_property tx_ss ENABLED true 
	} else {
		set_interface_property tx_ss ENABLED false  
	}	

	# Disable all RX SS interfaces and then enable based on stream
	# count
	set_interface_property rx_ss ENABLED false  
	set_interface_property rx1_ss ENABLED false  
	set_interface_property rx2_ss ENABLED false  
	set_interface_property rx3_ss ENABLED false  

	if { $support_dp_rx && $support_rx_ss } { 
		set_interface_property rx_ss ENABLED true 
	} 
	if { $support_dp_rx && $support_rx_ss && $rx_support_mst && [expr {$rx_num_of_streams} > 1] } {
		set_interface_property rx1_ss ENABLED true 
	}
	if { $support_dp_rx && $support_rx_ss && $rx_support_mst && [expr {$rx_num_of_streams} > 2] } {
		set_interface_property rx2_ss ENABLED true 
	}
	if { $support_dp_rx && $support_rx_ss && $rx_support_mst && [expr {$rx_num_of_streams} > 3] } {
		set_interface_property rx3_ss ENABLED true 
	}

	add_interface_port  tx_audio tx_audio_lpcm_data export Input [ expr  32*$tx_audio_chans ]

	# Audio support depends on SS support
	if { $support_dp_tx && $support_tx_ss && $tx_support_audio} {
		set_interface_property tx_audio_clk ENABLED true 
		set_interface_property tx_audio ENABLED true 
	} else {
		set_interface_property tx_audio_clk ENABLED false 
		set_interface_property tx_audio ENABLED false
	}
	
	add_interface_port  rx_audio rx_audio_lpcm_data export Output [ expr  32*$rx_audio_chans ]
	add_interface_port  rx1_audio rx1_audio_lpcm_data export Output [ expr  32*$rx_audio_chans ]
	add_interface_port  rx2_audio rx2_audio_lpcm_data export Output [ expr  32*$rx_audio_chans ]
	add_interface_port  rx3_audio rx3_audio_lpcm_data export Output [ expr  32*$rx_audio_chans ]

	set_interface_property rx_audio ENABLED false
	set_interface_property rx1_audio ENABLED false
	set_interface_property rx2_audio ENABLED false
	set_interface_property rx3_audio ENABLED false

	if { $rx_support_audio && $support_rx_ss && $support_dp_rx} {
		set_interface_property rx_audio ENABLED true
	}
	if { $rx_support_audio && $support_rx_ss && $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 1] } {
		set_interface_property rx1_audio ENABLED true
	}
	if { $rx_support_audio && $support_rx_ss && $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 2] } {
		set_interface_property rx2_audio ENABLED true
	}
	if { $rx_support_audio && $support_rx_ss && $support_dp_rx && $rx_support_mst && [expr {$rx_num_of_streams} > 3] } {
		set_interface_property rx3_audio ENABLED true
	}

	# Hidden support for HDCP interfaces to allow easier Bitec support
	# in custom engangements
	if { $include_hdcp } {
		# HDCP
		set hdcp_tx_support [get_parameter_value TX_SUPPORT_HDCP]	
		if { $hdcp_tx_support && $support_dp_tx} {
			set_interface_property tx_hdcp ENABLED true
		} else {
			set_interface_property tx_hdcp ENABLED false
		}  

		set hdcp_rx_support [get_parameter_value RX_SUPPORT_HDCP]	
		if { $hdcp_rx_support && $support_dp_rx} {
			set_interface_property rx_hdcp ENABLED true
		} else {
			set_interface_property rx_hdcp ENABLED false
		}
	} else {
		# If HDCP is not included disable the interfaces to tie the
		# signals off properly for simulation
		set_interface_property tx_hdcp ENABLED false
		set_interface_property rx_hdcp ENABLED false
	}

	# +----------------------------------------------------------------------
	# | Enable or disable parameters appropriately
	# +----------------------------------------------------------------------

	if { $support_dp_tx } {
		set_parameter_property TX_MAX_LINK_RATE		ENABLED true
		set_parameter_property TX_MAX_LANE_COUNT	ENABLED true
		set_parameter_property TX_POLINV			ENABLED true
		set_parameter_property TX_SUPPORT_ANALOG_RECONFIG ENABLED true
		set_parameter_property TX_SCRAMBLER_SEED	ENABLED true
		#set_parameter_property TX_SCRAMBLER_ENABLE	ENABLED true
		set_parameter_property TX_SUPPORT_SS		ENABLED true
		set_parameter_property TX_PIXELS_PER_CLOCK  ENABLED true
		set_parameter_property TX_SYMBOLS_PER_CLOCK ENABLED true
		set_parameter_property TX_SUPPORT_18BPP		ENABLED true
		set_parameter_property TX_SUPPORT_24BPP		ENABLED true
		set_parameter_property TX_SUPPORT_30BPP		ENABLED true
		set_parameter_property TX_SUPPORT_36BPP		ENABLED true
		set_parameter_property TX_SUPPORT_48BPP		ENABLED true
		set_parameter_property TX_SUPPORT_YCBCR422_16BPP ENABLED true
		set_parameter_property TX_SUPPORT_YCBCR422_20BPP ENABLED true
		set_parameter_property TX_SUPPORT_YCBCR422_24BPP ENABLED true
		set_parameter_property TX_SUPPORT_YCBCR422_32BPP ENABLED true
		#set_parameter_property TX_ENHANCED_FRAME	ENABLED true
		if { $include_hdcp } {
			set_parameter_property TX_SUPPORT_HDCP ENABLED true 
		}
		set_parameter_property TX_VIDEO_BPS			ENABLED true
		set_parameter_property TX_IMPORT_MSA		ENABLED true
		set_parameter_property TX_INTERLACED_VID	ENABLED true
		set_parameter_property TX_SUPPORT_AUTOMATED_TEST ENABLED true 
		set_parameter_property TX_AUX_DEBUG			ENABLED true

		if { $support_tx_ss } {
			set_parameter_property TX_SUPPORT_AUDIO ENABLED true
			set_parameter_property TX_AUDIO_CHANS	ENABLED true
		} else {
			set_parameter_property TX_SUPPORT_AUDIO ENABLED false
			set_parameter_property TX_AUDIO_CHANS	ENABLED false
		}
	} else {
		set_parameter_property TX_MAX_LINK_RATE		ENABLED false
		set_parameter_property TX_MAX_LANE_COUNT	ENABLED false
		set_parameter_property TX_POLINV			ENABLED false
		set_parameter_property TX_SUPPORT_ANALOG_RECONFIG ENABLED false
		set_parameter_property TX_SCRAMBLER_SEED	ENABLED false
		#set_parameter_property TX_SCRAMBLER_ENABLE	ENABLED false
		set_parameter_property TX_SUPPORT_SS		ENABLED false
		set_parameter_property TX_PIXELS_PER_CLOCK  ENABLED false
		set_parameter_property TX_SYMBOLS_PER_CLOCK ENABLED false
		set_parameter_property TX_SUPPORT_18BPP		ENABLED false
		set_parameter_property TX_SUPPORT_24BPP		ENABLED false
		set_parameter_property TX_SUPPORT_30BPP		ENABLED false
		set_parameter_property TX_SUPPORT_36BPP		ENABLED false
		set_parameter_property TX_SUPPORT_48BPP		ENABLED false
		set_parameter_property TX_SUPPORT_YCBCR422_16BPP ENABLED false
		set_parameter_property TX_SUPPORT_YCBCR422_20BPP ENABLED false
		set_parameter_property TX_SUPPORT_YCBCR422_24BPP ENABLED false
		set_parameter_property TX_SUPPORT_YCBCR422_32BPP ENABLED false
		#set_parameter_property TX_ENHANCED_FRAME	ENABLED false
		if { $include_hdcp } {
			set_parameter_property TX_SUPPORT_HDCP ENABLED false 
		} 
		set_parameter_property TX_VIDEO_BPS			ENABLED false
		set_parameter_property TX_IMPORT_MSA		ENABLED false
		set_parameter_property TX_INTERLACED_VID	ENABLED false
		set_parameter_property TX_SUPPORT_AUTOMATED_TEST ENABLED false 
		set_parameter_property TX_AUX_DEBUG			ENABLED false
		set_parameter_property TX_SUPPORT_AUDIO		ENABLED false
		set_parameter_property TX_AUDIO_CHANS		ENABLED false
	} 

	if { $support_dp_rx } {
		set_parameter_property RX_MAX_LINK_RATE		ENABLED true
		set_parameter_property RX_MAX_LANE_COUNT	ENABLED true
		set_parameter_property RX_POLINV			ENABLED true
		set_parameter_property RX_SCRAMBLER_SEED	ENABLED true
		#set_parameter_property RX_SCRAMBLER_ENABLE	ENABLED true
		set_parameter_property RX_SUPPORT_SS		ENABLED true
		set_parameter_property RX_PIXELS_PER_CLOCK  ENABLED true
		set_parameter_property RX_SYMBOLS_PER_CLOCK ENABLED true
		set_parameter_property RX_IMAGE_OUT_FORMAT	ENABLED true
		set_parameter_property RX_SUPPORT_AUTOMATED_TEST ENABLED true
		set_parameter_property RX_SUPPORT_18BPP		ENABLED true
		set_parameter_property RX_SUPPORT_24BPP		ENABLED true
		set_parameter_property RX_SUPPORT_30BPP		ENABLED true
		set_parameter_property RX_SUPPORT_36BPP		ENABLED true
		set_parameter_property RX_SUPPORT_48BPP		ENABLED true
		set_parameter_property RX_SUPPORT_YCBCR422_16BPP ENABLED true
		set_parameter_property RX_SUPPORT_YCBCR422_20BPP ENABLED true
		set_parameter_property RX_SUPPORT_YCBCR422_24BPP ENABLED true
		set_parameter_property RX_SUPPORT_YCBCR422_32BPP ENABLED true
		#set_parameter_property RX_ENHANCED_FRAME	ENABLED true
		if { $include_hdcp } {
			set_parameter_property RX_SUPPORT_HDCP ENABLED true 
		}
		set_parameter_property RX_VIDEO_BPS			ENABLED true
		set_parameter_property RX_AUX_DEBUG			ENABLED true
		set_parameter_property RX_IEEE_OUI			ENABLED true
		set_parameter_property RX_AUX_GPU			ENABLED true 
		#set_parameter_property RX_EXTERNAL_EDID	ENABLED true 
		set_parameter_property RX_EXPORT_MSA		ENABLED true

		if { $support_rx_ss } {
			set_parameter_property RX_SUPPORT_AUDIO ENABLED true
			set_parameter_property RX_AUDIO_CHANS	ENABLED true
		} else {
			set_parameter_property RX_SUPPORT_AUDIO ENABLED false
			set_parameter_property RX_AUDIO_CHANS	ENABLED false
		}

		if { $include_mst } {
			# MST
			set_parameter_property RX_SUPPORT_MST	ENABLED true 
		
			if { $rx_support_mst } {
				set_parameter_property RX_MAX_NUM_OF_STREAMS ENABLED true
			} else {
				set_parameter_property RX_MAX_NUM_OF_STREAMS ENABLED false
			}
		}
	} else {
		set_parameter_property RX_MAX_LINK_RATE		ENABLED false
		set_parameter_property RX_MAX_LANE_COUNT	ENABLED false
		set_parameter_property RX_POLINV			ENABLED false
		set_parameter_property RX_SCRAMBLER_SEED	ENABLED false
		#set_parameter_property RX_SCRAMBLER_ENABLE	ENABLED false
		set_parameter_property RX_SUPPORT_SS		ENABLED false
		set_parameter_property RX_PIXELS_PER_CLOCK  ENABLED true
		set_parameter_property RX_SYMBOLS_PER_CLOCK ENABLED true
		set_parameter_property RX_IMAGE_OUT_FORMAT	ENABLED false
		set_parameter_property RX_SUPPORT_AUTOMATED_TEST ENABLED false
		set_parameter_property RX_SUPPORT_18BPP		ENABLED false
		set_parameter_property RX_SUPPORT_24BPP		ENABLED false
		set_parameter_property RX_SUPPORT_30BPP		ENABLED false
		set_parameter_property RX_SUPPORT_36BPP		ENABLED false
		set_parameter_property RX_SUPPORT_48BPP		ENABLED false
		set_parameter_property RX_SUPPORT_YCBCR422_16BPP ENABLED false
		set_parameter_property RX_SUPPORT_YCBCR422_20BPP ENABLED false
		set_parameter_property RX_SUPPORT_YCBCR422_24BPP ENABLED false
		set_parameter_property RX_SUPPORT_YCBCR422_32BPP ENABLED false
		#set_parameter_property RX_ENHANCED_FRAME	ENABLED false
		if { $include_hdcp } {
			set_parameter_property TX_SUPPORT_HDCP ENABLED false 
		}
		set_parameter_property RX_VIDEO_BPS			ENABLED false
		set_parameter_property RX_AUX_DEBUG			ENABLED false
		set_parameter_property RX_IEEE_OUI			ENABLED false
		set_parameter_property RX_AUX_GPU			ENABLED false
		#set_parameter_property RX_EXTERNAL_EDID	ENABLED false 
		set_parameter_property RX_EXPORT_MSA		ENABLED false
		set_parameter_property RX_SUPPORT_AUDIO		ENABLED false
		set_parameter_property RX_AUDIO_CHANS		ENABLED false
		if { $include_mst } {
			# MST
			set_parameter_property RX_SUPPORT_MST		ENABLED false
			set_parameter_property RX_MAX_NUM_OF_STREAMS ENABLED false
		}
	}

	# Publish RX and TX capabilities in "system.h"
	set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_MAX_LINK_RATE [get_parameter_value RX_MAX_LINK_RATE]
	set_module_assignment embeddedsw.CMacro.BITEC_CFG_TX_MAX_LINK_RATE [get_parameter_value TX_MAX_LINK_RATE]
	set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_MAX_LANE_COUNT [get_parameter_value RX_MAX_LANE_COUNT]
	set_module_assignment embeddedsw.CMacro.BITEC_CFG_TX_MAX_LANE_COUNT [get_parameter_value TX_MAX_LANE_COUNT]
	if { $include_mst && $rx_support_mst} {
		set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_SUPPORT_MST 1
		set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_MAX_NUM_OF_STREAMS [get_parameter_value RX_MAX_NUM_OF_STREAMS]
	} else {
		set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_SUPPORT_MST 0
		set_module_assignment embeddedsw.CMacro.BITEC_CFG_RX_MAX_NUM_OF_STREAMS 1
	}

	###
	# Display messages indicating the number of reconfig interfaces required for a given configuration
	#

    # Total
    set total [expr $rx_channels + $tx_channels*2]
    set add_s [expr {$total > 1 ? "s" : " "}]
    send_message info "altera_dp will require ${total} reconfiguration interface${add_s} for connection to the external reconfiguration controller."

    # RX Channels
    if { [expr {$rx_channels > 0} ] } {
		set max [expr $rx_channels - 1]
		set add_s [expr {$rx_channels > 1 ? "s" : " "}]
		set is_are [expr {$rx_channels > 1 ? "are" : "is"}]
		set count [expr {$rx_channels > 1 ? "0-${max}" : "0"}]
		send_message info "Reconfiguration interface offset${add_s} ${count} $is_are connected to the RX transceiver channel${add_s}."
	}

    # TX Channels
    if { [expr {$tx_channels > 0} ] } {
      set min $rx_channels
      set max [expr $min + $tx_channels - 1]
      set add_s [expr {$tx_channels > 1 ? "s" : " "}]
      set is_are [expr {$tx_channels > 1 ? "are" : "is"}]
      set count [expr {$tx_channels > 1 ? "${min}-${max}" : "${min}"}]
      send_message info "Reconfiguration interface offset${add_s} ${count} ${is_are} connected to the TX transceiver channel${add_s}."
    }

    # TX PLLS
    if { [expr {$tx_channels > 0} ] } {
      set min [expr $rx_channels + $tx_channels]
      set max [expr $min + $tx_channels - 1]
      set add_s [expr {$tx_channels > 1 ? "s" : " "}]
      set is_are [expr {$tx_channels > 1 ? "are" : "is"}]
      set count [expr {$tx_channels > 1 ? "${min}-${max}" : "${min}"}]
      send_message info "Reconfiguration interface offset${add_s} ${count} ${is_are} connected to the transmit PLL${add_s}."
    }

	###
	# Display warning messages if the color depth support request
	# exceeds the BPC range
	#
	set tx_24bpp [get_parameter_value TX_SUPPORT_24BPP]
	set tx_30bpp [get_parameter_value TX_SUPPORT_30BPP]
	set tx_36bpp [get_parameter_value TX_SUPPORT_36BPP]
	set tx_48bpp [get_parameter_value TX_SUPPORT_48BPP]
	set tx_422_16bpp [get_parameter_value TX_SUPPORT_YCBCR422_16BPP]
	set tx_422_20bpp [get_parameter_value TX_SUPPORT_YCBCR422_20BPP]
	set tx_422_24bpp [get_parameter_value TX_SUPPORT_YCBCR422_24BPP]
	set tx_422_32bpp [get_parameter_value TX_SUPPORT_YCBCR422_32BPP]

	if {$support_dp_tx} {
		if {$tx_24bpp && [expr {$tx_bps < 8}] } {
			send_message warning "Requested support for source color depth of 24 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_30bpp && [expr {$tx_bps < 10}] } {
			send_message warning "Requested support for source color depth of 30 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_36bpp && [expr {$tx_bps < 12}] } {
			send_message warning "Requested support for source color depth of 36 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_48bpp && [expr {$tx_bps < 16}] } {
			send_message warning "Requested support for source color depth of 48 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_422_16bpp && [expr {$tx_bps < 8}] } {
			send_message warning "Requested support for source color depth of 16 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_422_20bpp && [expr {$tx_bps < 10}] } {
			send_message warning "Requested support for source color depth of 20 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_422_24bpp && [expr {$tx_bps < 12}] } {
			send_message warning "Requested support for source color depth of 24 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
		if {$tx_422_32bpp && [expr {$tx_bps < 16}] } {
			send_message warning "Requested support for source color depth of 32 bpp which exceeds the maximum input color depth $tx_bps (bpc)"
		}
	}

	set rx_24bpp [get_parameter_value RX_SUPPORT_24BPP]
	set rx_30bpp [get_parameter_value RX_SUPPORT_30BPP]
	set rx_36bpp [get_parameter_value RX_SUPPORT_36BPP]
	set rx_48bpp [get_parameter_value RX_SUPPORT_48BPP]
	set rx_422_16bpp [get_parameter_value RX_SUPPORT_YCBCR422_16BPP]
	set rx_422_20bpp [get_parameter_value RX_SUPPORT_YCBCR422_20BPP]
	set rx_422_24bpp [get_parameter_value RX_SUPPORT_YCBCR422_24BPP]
	set rx_422_32bpp [get_parameter_value RX_SUPPORT_YCBCR422_32BPP]

	if {$support_dp_rx} {
		if {$rx_24bpp && [expr {$rx_bps < 8}] } {
			send_message warning "Requested support for sink color depth of 24 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_30bpp && [expr {$rx_bps < 10}] } {
			send_message warning "Requested support for sink color depth of 30 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_36bpp && [expr {$rx_bps < 12}] } {
			send_message warning "Requested support for sink color depth of 36 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_48bpp && [expr {$rx_bps < 16}] } {
			send_message warning "Requested support for sink color depth of 48 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_422_16bpp && [expr {$rx_bps < 8}] } {
			send_message warning "Requested support for sink color depth of 16 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_422_20bpp && [expr {$rx_bps < 10}] } {
			send_message warning "Requested support for sink color depth of 20 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_422_24bpp && [expr {$rx_bps < 12}] } {
			send_message warning "Requested support for sink color depth of 24 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
		if {$rx_422_32bpp && [expr {$rx_bps < 16}] } {
			send_message warning "Requested support for sink color depth of 32 bpp which exceeds the maximum output color depth $rx_bps (bpc)"
		}
	}

		# Choose the appropriate PHY based on the family, link rate &
		# xcvr_width
		if {$device_family == "Stratix V"} {
			set family "sv"
		} elseif {$device_family == "Arria V"} {
			set family "av"
		} elseif {$device_family == "Arria V GZ"} {
			set family "avgz"
		} elseif {$device_family == "Cyclone V"} {
			set family "cv"
		} else {
			# Unknown family
			send_message error "Current device family ($device_family) is not supported."
		}

		if {$tx_link_rate == 20} {
			set tx_phy_link_rate "hbr2"
		} elseif {$tx_link_rate == 10} {
			set tx_phy_link_rate "hbr"
		} else {
			set tx_phy_link_rate "rbr"
		}

		if {$rx_link_rate == 20} {
			set rx_phy_link_rate "hbr2"
		} elseif {$rx_link_rate == 10} {
			set rx_phy_link_rate "hbr"
		} else {
			set rx_phy_link_rate "rbr"
		}

		# Get the XCVR width from the symbols per clock
		# only 2 and 4 symbols are allowed
		if {$rx_symbols_per_clock == 2} {
			set rx_phy_xcvr_width 20
		} elseif {$rx_symbols_per_clock == 4} {
			set rx_phy_xcvr_width 40
		} else {
			send_message error "Sink: $rx_symbols_per_clock symbols per clock is not supported."
		}

		if {$tx_symbols_per_clock == 2} {
			set tx_phy_xcvr_width 20
		} elseif {$tx_symbols_per_clock == 4} {
			set tx_phy_xcvr_width 40
		} else {
			send_message error "Source: $tx_symbols_per_clock symbols per clock is not supported."
		}

		# Register the PHY IP variants
		register_phy_ip $family "rx" $rx_phy_link_rate $rx_phy_xcvr_width
		register_phy_ip $family "tx" $tx_phy_link_rate $tx_phy_xcvr_width
}

