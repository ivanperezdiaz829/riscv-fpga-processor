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


# Common files for Interlaken PCS components
#
# $Header: //acds/rel/13.1/ip/alt_interlaken/alt_interlaken_pcs/sv_xcvr_interlaken_common.tcl#1 $

set common_composed_mode 0

# +-----------------------------------
# | initialize the exported interface data to an empty set
# | 
# | Set composed mode, affects common_add* interface methods
# | 
proc common_initialize { composed } {
	global common_composed_mode
	set common_composed_mode $composed
}

# +-----------------------------------
# | files

proc common_decl_files_for_sv_xcvr { sv_root } {

    common_fileset_group_plain ./ $sv_root/ {
	alt_xcvr_interlaken_amm_slave.v
	alt_xcvr_interlaken_soft_pbip.sv
	sv_xcvr_interlaken_native.sv
	sv_xcvr_interlaken_nr.sv
    } {ALL_HDL}
    common_fileset_group_plain ./ $sv_root/ ilk_mux.v {ALL_SIM}  ;# for sim only
}


proc common_decl_files_for_sv_top { sv_ilkroot } {

    common_fileset_group_plain ./ $sv_ilkroot/ altera_xcvr_interlaken.sv {ALL_HDL}
    common_fileset_group ./ $sv_ilkroot/ OTHER altera_xcvr_interlaken.sdc {S5} {SDC}

}



# +-----------------------------------
# | parameters
# | 
proc common_add_parameters_for_native_phy { } {

    add_parameter device_family STRING
    set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
    set_parameter_property device_family DISPLAY_NAME "Device family"
    set_parameter_property device_family DISPLAY_HINT "Device family"
    set_parameter_property device_family AFFECTS_ELABORATION true
    set_parameter_property device_family AFFECTS_GENERATION true
    set_parameter_property device_family IS_HDL_PARAMETER false
    add_display_item "General Options" device_family PARAMETER
    set_parameter_property device_family DESCRIPTION "Only Stratix V or Arria V GZ devices are supported"

    add_parameter PLEX STRING "DUPLEX"
    set_parameter_property PLEX DISPLAY_NAME "Datapath mode"
    set_parameter_property PLEX DISPLAY_HINT ""
    set_parameter_property PLEX ALLOWED_RANGES {"RX" "TX" "DUPLEX"}
    set_parameter_property PLEX AFFECTS_ELABORATION true
    set_parameter_property PLEX AFFECTS_GENERATION true
    set_parameter_property PLEX IS_HDL_PARAMETER true
    add_display_item "General Options" PLEX PARAMETER
    set_parameter_property PLEX DESCRIPTION "Select datapath mode, TX only, RX only or Duplex"
    
    add_parameter LANERATE STRING "6250 Mbps"
    set_parameter_property LANERATE DISPLAY_NAME "Lane rate"
    set_parameter_property LANERATE UNITS None
#    set_parameter_property LANERATE ALLOWED_RANGES {"3125 Mbps" "5000 Mbps" "6250 Mbps" "6375 Mbps" "10312.5 Mbps"}
#    set_parameter_property LANERATE DISPLAY_HINT ""
    set_parameter_property LANERATE IS_HDL_PARAMETER false
    set_parameter_property LANERATE AFFECTS_GENERATION true
    add_display_item "General Options" LANERATE PARAMETER
#    set_parameter_property LANERATE DESCRIPTION "Select lane rate from the following supported values - 3125 Mbps, 5000 Mbps, 6250 Mbps, 6375 Mbps and 10312.5 Mbps"
    set_parameter_property LANERATE DESCRIPTION "Specifies the data rate in Mbps"
    
    
    add_parameter LINKWIDTH INTEGER 4
    set_parameter_property LINKWIDTH DISPLAY_NAME "Number of lanes"
    set_parameter_property LINKWIDTH ALLOWED_RANGES 1:24
    set_parameter_property LINKWIDTH DISPLAY_HINT ""
    set_parameter_property PLEX AFFECTS_ELABORATION true
    set_parameter_property LINKWIDTH AFFECTS_GENERATION true
    set_parameter_property LINKWIDTH IS_HDL_PARAMETER true
    add_display_item "General Options" LINKWIDTH PARAMETER
    set_parameter_property LINKWIDTH DESCRIPTION "Select the number of lanes, supported range 1 to 24"
    

    add_parameter METALEN INTEGER 2048
    set_parameter_property METALEN DISPLAY_NAME "Meta frame length in words"
    set_parameter_property METALEN ALLOWED_RANGES 5:8191
    set_parameter_property METALEN DISPLAY_HINT ""
    set_parameter_property METALEN AFFECTS_GENERATION true
    set_parameter_property METALEN IS_HDL_PARAMETER true
    add_display_item "General Options" METALEN PARAMETER
    set_parameter_property METALEN DESCRIPTION "Select the Meta frame Length, supported range 5 to 8191 words"
    
    
    add_parameter EXTRA_SIGS INTEGER 1
    set_parameter_property EXTRA_SIGS DISPLAY_NAME "Enable RX status signals (word lock, sync lock, crc32 error) as a part of rx_parallel_data"
    set_parameter_property EXTRA_SIGS ALLOWED_RANGES 0:1
    set_parameter_property EXTRA_SIGS DISPLAY_HINT "BOOLEAN"
    set_parameter_property EXTRA_SIGS AFFECTS_GENERATION true
    set_parameter_property EXTRA_SIGS IS_HDL_PARAMETER true
    add_display_item "Advanced Options" EXTRA_SIGS PARAMETER
    set_parameter_property EXTRA_SIGS DESCRIPTION "When Selected, word_lock, sync_lock and CRC32 error signals are added as a part of rx_parallel_data bus"
    

    ### PLLs

    # add pll_refclk_cnt parameter
    add_parameter PLL_REFCLK_CNT INTEGER
    set_parameter_property PLL_REFCLK_CNT VISIBLE false
    set_parameter_property PLL_REFCLK_CNT DEFAULT_VALUE 1
    set_parameter_property PLL_REFCLK_CNT HDL_PARAMETER true
    set_parameter_property PLL_REFCLK_CNT DERIVED true
    set_parameter_property PLL_REFCLK_CNT ENABLED true

    # adding pll input clock aka pll_ref_freq parameter - GUI param is symbolic only
    add_parameter gui_pll_ref_freq STRING "312.5 MHz"
    set_parameter_property gui_pll_ref_freq DEFAULT_VALUE "PARAM_UNMAPPED"
    set_parameter_property gui_pll_ref_freq DISPLAY_NAME "Input clock frequency"
    set_parameter_property gui_pll_ref_freq UNITS None
    set_parameter_property gui_pll_ref_freq DISPLAY_HINT "include frequency or period unit"
    set_parameter_property gui_pll_ref_freq HDL_PARAMETER false
    set_parameter_property gui_pll_ref_freq DESCRIPTION "Specifies the input clock frequency"
    add_display_item "General Options" gui_pll_ref_freq parameter
  

## Do not need this in 11.1 as sv_xcvr_plls calculate thsi based on base_data_rate
#    add_parameter PLL_OUT_FREQ STRING "3125 MHz"
#    set_parameter_property PLL_OUT_FREQ DERIVED true
#    set_parameter_property PLL_OUT_FREQ VISIBLE false
#    set_parameter_property PLL_OUT_FREQ IS_HDL_PARAMETER true
#    add_display_item "General Options" PLL_OUT_FREQ PARAMETER


    add_parameter PLL_REF_FREQ STRING "PARAM_UNMAPPED"
    set_parameter_property PLL_REF_FREQ DERIVED true
    set_parameter_property PLL_REF_FREQ VISIBLE false
    set_parameter_property PLL_REF_FREQ IS_HDL_PARAMETER true
    set_parameter_property PLL_REF_FREQ DERIVED true
    add_display_item "General Options" PLL_REF_FREQ PARAMETER

    # add pll_refclk_select parameter
    add_parameter PLL_REFCLK_SELECT STRING "0"
    set_parameter_property PLL_REFCLK_SELECT DEFAULT_VALUE "0"
    set_parameter_property PLL_REFCLK_SELECT VISIBLE false
    set_parameter_property PLL_REFCLK_SELECT DERIVED true
    set_parameter_property PLL_REFCLK_SELECT HDL_PARAMETER true

    
    # add plls parameter
    add_parameter PLLS INTEGER
    set_parameter_property PLLS VISIBLE false
    set_parameter_property PLLS DEFAULT_VALUE 1
    set_parameter_property PLLS HDL_PARAMETER true
    set_parameter_property PLLS ENABLED true
    set_parameter_property PLLS DERIVED true

    add_parameter PLL_TYPE STRING
    set_parameter_property PLL_TYPE VISIBLE false
    set_parameter_property PLL_TYPE DEFAULT_VALUE "AUTO"
    set_parameter_property PLL_TYPE HDL_PARAMETER true
    set_parameter_property PLL_TYPE ENABLED true
    set_parameter_property PLL_TYPE DERIVED true

    # adding pll type parameter - GUI param is symbolic only
    add_parameter gui_pll_type STRING "CMU"
    set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
    set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
    set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
    set_parameter_property gui_pll_type UNITS None
    set_parameter_property gui_pll_type ENABLED true
    set_parameter_property gui_pll_type VISIBLE true
    set_parameter_property gui_pll_type DISPLAY_HINT ""
    set_parameter_property gui_pll_type HDL_PARAMETER false
    set_parameter_property gui_pll_type DESCRIPTION "Specifies the PLL type"
    add_display_item "General Options" gui_pll_type parameter


    
    add_parameter PLL_SELECT INTEGER
    set_parameter_property PLL_SELECT VISIBLE false
    set_parameter_property PLL_SELECT DEFAULT_VALUE 0
    set_parameter_property PLL_SELECT HDL_PARAMETER true
    set_parameter_property PLL_SELECT ENABLED true
    set_parameter_property PLL_SELECT DERIVED true
    
    
    add_parameter DATA_RATE STRING "6250 Mbps"
    set_parameter_property DATA_RATE DERIVED true
    set_parameter_property DATA_RATE VISIBLE false
    set_parameter_property DATA_RATE IS_HDL_PARAMETER true
    add_display_item "General Options" DATA_RATE PARAMETER

    # adding base_data_rate parameter
    add_parameter GUI_BASE_DATA_RATE STRING "3125 Mbps"
    set_parameter_property GUI_BASE_DATA_RATE DEFAULT_VALUE "3125 Mbps"
    set_parameter_property GUI_BASE_DATA_RATE DISPLAY_NAME "Base data rate"
    set_parameter_property GUI_BASE_DATA_RATE HDL_PARAMETER false
    set_parameter_property GUI_BASE_DATA_RATE DESCRIPTION "Specifies the base data rate for the TX PLL. Channels that require TX PLL merging must share the same base data rate."
    add_display_item "General Options" GUI_BASE_DATA_RATE parameter

    add_parameter BASE_DATA_RATE STRING "3125 Mbps"
    set_parameter_property BASE_DATA_RATE DEFAULT_VALUE "3125 Mbps"
    set_parameter_property BASE_DATA_RATE HDL_PARAMETER true
    set_parameter_property BASE_DATA_RATE DERIVED true
    set_parameter_property BASE_DATA_RATE VISIBLE false

    add_parameter TX_USE_CORECLK INTEGER 1
    set_parameter_property TX_USE_CORECLK DISPLAY_NAME "Create tx_coreclkin port"
    set_parameter_property TX_USE_CORECLK DISPLAY_HINT "BOOLEAN"
    set_parameter_property TX_USE_CORECLK ALLOWED_RANGES 0:1
    set_parameter_property TX_USE_CORECLK AFFECTS_GENERATION true
    set_parameter_property TX_USE_CORECLK IS_HDL_PARAMETER true
    add_display_item "Advanced Options" TX_USE_CORECLK PARAMETER
    set_parameter_property TX_USE_CORECLK DESCRIPTION "When selected tx_coreclkin drives the write side of TX FIFO"
    
    add_parameter RX_USE_CORECLK INTEGER 1
    set_parameter_property RX_USE_CORECLK DISPLAY_NAME "Create rx_coreclkin port"
    set_parameter_property RX_USE_CORECLK ALLOWED_RANGES 0:1
    set_parameter_property RX_USE_CORECLK DISPLAY_HINT "BOOLEAN"
    set_parameter_property RX_USE_CORECLK AFFECTS_GENERATION true
    set_parameter_property RX_USE_CORECLK IS_HDL_PARAMETER true
    add_display_item "Advanced Options" RX_USE_CORECLK PARAMETER
    set_parameter_property RX_USE_CORECLK DESCRIPTION "When selected rx_coreclkin drives the read side of RX FIFO"
    

    
    add_parameter sys_clk_in_hz INTEGER 150000000
    set_parameter_property sys_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
    set_parameter_property sys_clk_in_hz VISIBLE false
    set_parameter_property sys_clk_in_hz AFFECTS_GENERATION true
    set_parameter_property sys_clk_in_hz IS_HDL_PARAMETER false
    add_display_item "Advanced Options" sys_clk_in_hz parameter


    add_parameter sys_clk_in_mhz INTEGER 150
    set_parameter_property sys_clk_in_mhz VISIBLE false 
    set_parameter_property sys_clk_in_mhz DERIVED true
    set_parameter_property sys_clk_in_mhz IS_HDL_PARAMETER true


    add_parameter BONDED_GROUP_SIZE INTEGER 1
    set_parameter_property BONDED_GROUP_SIZE DERIVED true
#    set_parameter_property BONDED_GROUP_SIZE ALLOWED_RANGES 1:6
    set_parameter_property BONDED_GROUP_SIZE DEFAULT_VALUE 1
    set_parameter_property BONDED_GROUP_SIZE VISIBLE false
    set_parameter_property BONDED_GROUP_SIZE IS_HDL_PARAMETER true

    add_parameter GUI_BONDED_GROUP_SIZE INTEGER 1
    set_parameter_property GUI_BONDED_GROUP_SIZE DISPLAY_NAME "Bonded group size"
#    set_parameter_property GUI_BONDED_GROUP_SIZE ALLOWED_RANGES 5:6
    set_parameter_property GUI_BONDED_GROUP_SIZE DEFAULT_VALUE 1
    add_display_item "General Options" GUI_BONDED_GROUP_SIZE PARAMETER
    set_parameter_property GUI_BONDED_GROUP_SIZE DESCRIPTION "Supported Values are 5, 6, when 5, bonds 5 lanes/PLL (valid for CMU and ATX PLL), when 6, bonds 6 lanes/PLL,(valid for ATX PLL only)"
   

}    
 
#source parameter_manager.tcl
#add_pma_parameters_raw

##proc alt_interlaken_pcs_validate 
proc common_parameter_validation {} {
    set family [get_parameter_value device_family]
    set lw [get_parameter_value LINKWIDTH]
    set mode [get_parameter_value PLEX]
    set_parameter_property device_family ENABLED false
    set_parameter_property device_family VISIBLE true
    
    #### Set BONDED_GROUP_SIZE
    
    if { [expr {$family == "Stratix V"}] || [expr {$family == "StratixV"}] || [expr {$family == "Arria V GZ"}]} {
	set_parameter_property LINKWIDTH ALLOWED_RANGES 1:24
#	set_parameter_property LANERATE ALLOWED_RANGES {"3125 Mbps" "5000 Mbps" "6250 Mbps" "6375 Mbps" "10312.5 Mbps"}
#	set_parameter_property reconfig_interfaces VISIBLE false
    } else {
	send_message error "Wrong selection of device family."
    }


    if { [expr {$mode != "RX"}] } {
	if { $lw > 5 } {
	    set_parameter_property GUI_BONDED_GROUP_SIZE VISIBLE false
#	    set blanes [get_parameter_value GUI_BONDED_GROUP_SIZE]
	    set blanes 1
	    set_parameter_value BONDED_GROUP_SIZE $blanes
	    if {$blanes == 6} {
		send_message info "Bonded group size is 6, make sure to assign ATX PLL"
	    }
	} else {
	    set_parameter_property GUI_BONDED_GROUP_SIZE VISIBLE false
	    set_parameter_value BONDED_GROUP_SIZE 1
	}
    } else {
	set_parameter_property GUI_BONDED_GROUP_SIZE VISIBLE false
#	set_parameter_value BONDED_GROUP_SIZE 5
	set_parameter_value BONDED_GROUP_SIZE 1
    }



    if { [expr {$mode == "TX"}] } {
	set_parameter_property EXTRA_SIGS ENABLED false
	set_parameter_property RX_USE_CORECLK ENABLED false
    } else {
	set_parameter_property EXTRA_SIGS ENABLED true
	set_parameter_property RX_USE_CORECLK ENABLED true
    }
    
    if { [expr {$mode == "RX"}] } {
	set_parameter_property TX_USE_CORECLK ENABLED false
    } else {
	set_parameter_property TX_USE_CORECLK ENABLED true
    }
    
    set lr [get_parameter_value LANERATE]
    # In 12.0 supprot data_rate range instead few data rates,so validate the data rate
  # Data rate validation
  if { ![::alt_xcvr::utils::common::validate_data_rate_string $lr] } {
    ::alt_xcvr::gui::messages::data_rate_format_error
  }

    set space_idx [string first " " $lr 0]
    set ilr [string range $lr 0 [expr $space_idx-1]]

    # in 11.1 now supporting different refclks, so no need to calculate this, 
    # also now for sv_xcvr_plls no need for pll_out_freq parameter
    # I am just keeping this for backwards compatibility
#    send_message info [format "The input clock frequency should be %f MHz" [expr "$ilr / 20.0"]]
#    set_parameter_value PLL_REF_FREQ [format "%f Mhz" [expr "$ilr / 20.0"]]
#    set_parameter_value PLL_OUT_FREQ [format "%f Mhz" [expr "$ilr / 2.0"]]
#    set_parameter_value PLL_REF_FREQ [get_parameter_value gui_pll_]

    #### set DATA_RATE
    set_parameter_value DATA_RATE $lr
    set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $lr ]

    
    #### set sys_clk_in_mhz
    set sys_clk_tmp [get_parameter_value sys_clk_in_hz]
    set_parameter_value sys_clk_in_mhz [expr $sys_clk_tmp / 1000000]

## New
    #### set PLL_TYPE parameter
    set pll_type [validate_pll_type $family]
#    send_message info "pll_type = $pll_type"

    #### set BASE DATA RATE
  
  set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $family $lr $pll_type]
  if { [llength $base_data_rate_list] == 0 } {
    set base_data_rate_list {"N/A"}
    send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
  }
  ::alt_xcvr::utils::common::map_allowed_range GUI_BASE_DATA_RATE $base_data_rate_list
  set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_BASE_DATA_RATE]
#    send_message info "base data rate value is $data_rate_str"


  #|----------------
  # Validation for PLL
  #|---------------- 
    ## result variable returns the list of all available refclks for the current data rate
  if {$data_rate_str != "N/A" && $data_rate_str != "N.A"} {
    # May return "N/A"
    set result [::alt_xcvr::utils::rbc::get_valid_refclks $family $data_rate_str $pll_type]
  } else {
    set result "N/A"
  }

    ## Adding following code for backwards compatibility, till 11.0SP2
    ## Interlaken was allowing only one refclk now allowing user to choose refclk from the list, at the same time
    ## we want to open the old designs with the same refclk as before

   
    set my_pll_ref_freq [format %f [expr "$ilr / 20.0"]]
    set find_default_f "false"

    foreach val $result {
	regexp {([0-9.]+)} $val myval
	set newval [format %f $myval]
	if {$newval == $my_pll_ref_freq} { 
	    set default_pll_ref_freq $val
	    set find_default_f "true"
	} 
    }

    if {$find_default_f == "true"} {
	::alt_xcvr::utils::common::map_allowed_range gui_pll_ref_freq $result $default_pll_ref_freq	
    } else {
	::alt_xcvr::utils::common::map_allowed_range gui_pll_ref_freq $result
    }
    set user_pll_refclk_freq [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_ref_freq]

### Do not enable pll_reconfig for 11.1

#  if [::alt_xcvr::utils::device::has_s5_style_hssi $family] {
#    ::alt_xcvr::gui::pll_reconfig::set_config $family 1 1 [::alt_xcvr::utils::device::get_hssi_pll_types $family]; # 2 PLLs, 2 refclks
#  } else {
#    ::alt_xcvr::gui::pll_reconfig::set_config $family 1 1 [::alt_xcvr::utils::device::get_hssi_pll_types $family]; # 1 PLL, 1 refclk
#  }

#  ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings $user_pll_refclk_freq $data_rate_str $pll_type
#  ::alt_xcvr::gui::pll_reconfig::validate

#  set_parameter_value PLL_REF_FREQ   [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
#  set_parameter_value PLL_TYPE          [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
#  set_parameter_value BASE_DATA_RATE    [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
#  set_parameter_value PLL_REFCLK_SELECT [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string]
#  set_parameter_value PLL_SELECT        [::alt_xcvr::gui::pll_reconfig::get_main_pll_index]
#  set_parameter_value PLL_REFCLK_CNT    [::alt_xcvr::gui::pll_reconfig::get_refclk_count]  
#  set_parameter_value PLLS              [::alt_xcvr::gui::pll_reconfig::get_pll_count]

    set_parameter_value PLL_TYPE          $pll_type
    set_parameter_value BASE_DATA_RATE    $data_rate_str
    set_parameter_value PLL_REF_FREQ      $user_pll_refclk_freq
    
    set_parameter_value PLL_REFCLK_SELECT "0" 
    set_parameter_value PLL_SELECT 0    
    set_parameter_value PLL_REFCLK_CNT 1
    set_parameter_value PLLS 1



}



# Validate reconfig parameters for PHY IP in manual bonding mode
proc validate_reconfiguration_parameters { device_family } {
        #|----------------
	#| Reconfiguration
	#|----------------

    set lanes [get_parameter_value LINKWIDTH]
    set op_mode [get_parameter_value PLEX]
#    set nblanes [get_parameter_value GUI_BONDED_GROUP_SIZE]
    set nblanes 1
    set_parameter_value BONDED_GROUP_SIZE $nblanes
    # if BONDED_GROUP_SIZE=5 then bond 5 lanes /1 PLL 
    set num_txbonded [expr $lanes/$nblanes]
    set num_txremain [expr $lanes % $nblanes]
    if { $op_mode == "RX" } {
	set tx_plls 0
    } else {
	if { $num_txremain > 0 } {
	    set tx_plls [expr $num_txbonded + 1]
	} else {
	    set tx_plls [expr $num_txbonded]
	}
    }
    common_display_reconfig_interface_message $device_family $lanes $tx_plls
}


proc common_add_tagged_conduit { port_name port_dir width tags } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
	#set_interface_property $port_name ENABLED $used
	common_add_interface_port $port_name $port_name export $port_dir $width $tags
	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
}

proc common_add_tagged_conduit_bus { port_name port_dir width tags } {
	common_add_tagged_conduit $port_name $port_dir $width $tags 
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}


# +-----------------------------------
# | native PHY conduit ports
# | 
proc common_add_dynamic_reconfig_conduits { device_family } {

    set lanes [get_parameter_value LINKWIDTH]
    set op_mode [get_parameter_value PLEX]
#    set nblanes [get_parameter_value GUI_BONDED_GROUP_SIZE]
    set nblanes 1
    set_parameter_value BONDED_GROUP_SIZE $nblanes
    # if BONDED_GROUP_SIZE=5 then bond 5 lanes /1 PLL 
    # if BONDED_GROUP_SIZE=6 then bond 6 lanes /1 PLL 
    set num_txbonded [expr $lanes/$nblanes]
    set num_txremain [expr $lanes % $nblanes]
    if { $op_mode == "RX" } {
	set tx_plls 0
    } else {
	if { $num_txremain > 0 } {
	    set tx_plls [expr $num_txbonded + 1]
	} else {
	    set tx_plls [expr $num_txbonded]
	}
    }

    
    set reconfig_interfaces [common_get_reconfig_interface_count $device_family $lanes $tx_plls]

    #conduits for native reconfig bundles:
    common_add_tagged_conduit_bus reconfig_to_xcvr input [common_get_reconfig_to_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg}
    common_add_tagged_conduit_bus reconfig_from_xcvr output [common_get_reconfig_from_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg}
}



# +-----------------------------------
# | interfaces and ports common to all PHY components
# | 
proc common_clock_interfaces { } {
    global common_composed_mode
    
    set lw [get_parameter_value LINKWIDTH]
    ##    set num_reconfig_interfaces [get_parameter_value reconfig_interfaces]
    set txcoreclk [get_parameter_value TX_USE_CORECLK]
    set rxcoreclk [get_parameter_value RX_USE_CORECLK]
    set mode [get_parameter_value PLEX]
    
    common_add_clock	pll_ref_clk		input    1
    
    if { [expr {$mode != "RX"}] } {
	if { $txcoreclk == 1} {
	    common_add_clock	tx_coreclkin		input    1
	    common_add_clock	tx_clkout		output   $lw
	    ## Terminate the unused output clock port tx_user_clockout
	    common_add_clock        tx_user_clkout          output  1
	    set_port_property tx_user_clkout TERMINATION true

	} else {
	    if { $lw > 1 } {
		send_message error "tx_coreclkin must be used when number of lanes are more than 1"
	    } else {
		common_add_clock        tx_user_clkout          output  1
		## Terminate the unused input and output clocks
		common_add_clock	tx_coreclkin		input    1
		set_port_property tx_coreclkin TERMINATION true
		set_port_property tx_coreclkin TERMINATION_VALUE 0
		common_add_clock	tx_clkout		output   $lw
		set_port_property tx_clkout TERMINATION true
	    }

	}
    }
    
    if { [expr {$mode != "TX"}] } {
	if { $rxcoreclk == 1} {
	    common_add_clock	rx_coreclkin		input      1
	    common_add_clock	rx_clkout		output     $lw
	    ## Terminate the unused output clock port rx_user_clockout
	    common_add_clock        rx_user_clkout          output  1
	    set_port_property rx_user_clkout TERMINATION true

	} else {
	    common_add_clock        rx_user_clkout          output  1
	    ## Terminate the unused input and output clocks
	    common_add_clock	rx_coreclkin		input    1
	    set_port_property rx_coreclkin TERMINATION true
	    set_port_property rx_coreclkin TERMINATION_VALUE 0
	    common_add_clock	rx_clkout		output   $lw
	    set_port_property rx_clkout TERMINATION true

	}
    }
    

}

proc common_clock_interfaces_composed { } {
    global common_composed_mode
    set lw [get_parameter_value LINKWIDTH]
    set num_reconfig_interfaces [get_parameter_value reconfig_interfaces]
    set txcoreclk [get_parameter_value TX_USE_CORECLK]
    set rxcoreclk [get_parameter_value RX_USE_CORECLK]
    
    set family [get_parameter_value device_family]
    if { [expr {$family == "Stratix V"}] || [expr {$family == "StratixV"}] || [expr {$family == "Arria V GZ"}]} {
	set fshort "sv"
    } else {
	set fshort "sv"
    }
    
    add_interface pll_ref_clk clock end
    add_interface_port pll_ref_clk pll_ref_clk clk Input 1
    set_interface_property pll_ref_clk ENABLED true
    add_connection pll_ref_clk.clk/interlaken_pcs.pll_ref_clk

    set mode [get_parameter_value PLEX]
    if { [expr {$mode != "RX"}] } {
	if { $txcoreclk == 1} {
	    add_interface tx_clkout clock start
	    set_interface_property tx_clkout EXPORT_OF interlaken_pcs.tx_clkout
	    add_instance tx_coreclkin clock_source
	    add_interface tx_coreclkin clock end
	    set_interface_property tx_coreclkin export_of tx_coreclkin.clk_in
	    add_connection tx_coreclkin.clk/interlaken_pcs.tx_coreclkin


	} else {
	    add_interface tx_user_clkout clock start
	    set_interface_property tx_user_clkout EXPORT_OF interlaken_pcs.tx_user_clkout

	}
    }
    
    if { [expr {$mode != "TX"}] } {
	if { $rxcoreclk == 1 }  {
	    add_interface rx_clkout clock start
	    set_interface_property rx_clkout EXPORT_OF interlaken_pcs.rx_clkout
	    
	    add_instance rx_coreclkin clock_source
	    add_interface rx_coreclkin clock end
	    set_interface_property rx_coreclkin export_of rx_coreclkin.clk_in
	    add_connection rx_coreclkin.clk/interlaken_pcs.rx_coreclkin

	    
	} else {
	    add_interface rx_user_clkout clock start
	    set_interface_property rx_user_clkout EXPORT_OF interlaken_pcs.rx_user_clkout
	}
    }

}

# +-----------------------------------
# | native PHY ports
# | 
proc common_interlaken_interface_ports {shared} {
    set family [get_parameter_value device_family]
    set lw [get_parameter_value LINKWIDTH]
    set txcoreclk [get_parameter_value TX_USE_CORECLK]
    set rxcoreclk [get_parameter_value RX_USE_CORECLK]
    set mode [get_parameter_value PLEX]
    set num_reconfig_interfaces [expr ceil ([expr $lw/4.0])]

    
    if { [expr {$mode != "RX"}] } {
	# clock interfaces
	# reset outputs
	common_add_tagged_conduit tx_ready output 1 true

	# pll_locked output
	common_add_tagged_conduit pll_locked output 1 true
#	common_add_tagged_conduit pll_locked output $lw true

	# tx_sync_done output
	common_add_tagged_conduit tx_sync_done output 1 true

	# serial data IOs
	common_add_tagged_conduit_bus tx_serial_data output $lw true

	# data interfaces
	add_interface tx_parallel_data avalon_streaming end
	set_interface_property tx_parallel_data errorDescriptor ""
	set_interface_property tx_parallel_data maxChannel 0
	set_interface_property tx_parallel_data readyLatency 0
	set_interface_property tx_parallel_data symbolsPerBeat 1

	if { $txcoreclk == 1} {
	    set_interface_property tx_parallel_data ASSOCIATED_CLOCK tx_coreclkin
	    set_interface_property tx_parallel_data ENABLED true
	} else {
	    set_interface_property tx_parallel_data ASSOCIATED_CLOCK tx_user_clkout
	    set_interface_property tx_parallel_data ENABLED true
	}
	
	set tx_width [expr 66 * $lw]
	set_interface_property tx_parallel_data dataBitsPerSymbol $tx_width
	add_interface_port tx_parallel_data tx_parallel_data data Input $tx_width
	set tx_fragments { }
	for { set ch 0 } { $ch < $lw } { incr ch } {
	    set tx_fragments [concat tx_datavalid($ch) tx_ctrlin($ch) tx_parallel_data([expr $ch * 64 + 63]:[expr $ch * 64]) $tx_fragments ]
	}
	set_port_property tx_parallel_data FRAGMENT_LIST $tx_fragments
	
	add_interface tx_datain_bp avalon_streaming start
	set_interface_property tx_datain_bp dataBitsPerSymbol $lw
	set_interface_property tx_datain_bp errorDescriptor ""
	set_interface_property tx_datain_bp maxChannel 0
	set_interface_property tx_datain_bp readyLatency 0
	set_interface_property tx_datain_bp symbolsPerBeat 1
	if { $txcoreclk == 1} {
	    set_interface_property tx_datain_bp ASSOCIATED_CLOCK tx_coreclkin
	    set_interface_property tx_datain_bp ENABLED true
	} else {
	    set_interface_property tx_datain_bp ASSOCIATED_CLOCK tx_user_clkout
	    set_interface_property tx_datain_bp ENABLED true
	}
	add_interface_port tx_datain_bp tx_datain_bp data Output $lw
	
	## Terminate the remaining ports which are not exposed
	common_add_tagged_conduit_bus tx_fifofull output $lw true		
	common_add_tagged_conduit_bus tx_fifopfull output $lw true		
	set_port_property tx_fifofull TERMINATION true
	set_port_property tx_fifopfull TERMINATION true
    }

    if { [expr {$mode != "TX"}] } {
	
	# reset outputs
	common_add_tagged_conduit rx_ready output 1 true

		# serial data IOs
	common_add_tagged_conduit_bus rx_serial_data input $lw true

	# data interfaces
	set xtras [get_parameter_value EXTRA_SIGS]
	set rx_width 69
	if { $xtras == 1} {
	    set rx_width 72
	}
	set rx_width [expr $rx_width * $lw]
	add_interface rx_parallel_data avalon_streaming start
	set_interface_property rx_parallel_data errorDescriptor ""
	set_interface_property rx_parallel_data maxChannel 0
	set_interface_property rx_parallel_data readyLatency 0
	set_interface_property rx_parallel_data symbolsPerBeat 1
	
	if { $rxcoreclk == 1} {
	    set_interface_property rx_parallel_data ASSOCIATED_CLOCK rx_coreclkin
	    set_interface_property rx_parallel_data ENABLED true
	} else {
	    set_interface_property rx_parallel_data ASSOCIATED_CLOCK rx_user_clkout
	    set_interface_property rx_parallel_data ENABLED true
	}
	
	
	set_interface_property rx_parallel_data dataBitsPerSymbol $rx_width
	add_interface_port rx_parallel_data rx_parallel_data data Output $rx_width
	set rx_fragments { }
	for { set ch 0 } { $ch < $lw } { incr ch } {
	    if { $xtras == 1 } {
		set rx_fragments [concat rx_crc32err($ch) rx_frame_lock($ch) rx_align_val($ch) rx_fifopempty($ch) rx_fifofull($ch) rx_block_frame_lock($ch) rx_ctrlout($ch) rx_datavalid($ch) rx_parallel_data([expr $ch * 64 + 63]:[expr $ch * 64]) $rx_fragments ]
	    } else {
		set rx_fragments [concat rx_fifopempty($ch) rx_fifofull($ch) rx_block_frame_lock($ch) rx_ctrlout($ch) rx_datavalid($ch) rx_parallel_data([expr $ch * 64 + 63]:[expr $ch * 64]) $rx_fragments ]
		
	    }
	}

	## Terminate the ports which are not used when EXTRA_SIGS is not selected
	    if { $xtras != 1 } {
		common_add_tagged_conduit_bus rx_crc32err output $lw true		
		set_port_property rx_crc32err TERMINATION true

		common_add_tagged_conduit_bus rx_frame_lock output $lw true	    
		set_port_property rx_frame_lock TERMINATION true

		common_add_tagged_conduit_bus rx_align_val output $lw true		
		set_port_property rx_align_val TERMINATION true
	    }

	
	set_port_property rx_parallel_data FRAGMENT_LIST $rx_fragments
	
	add_interface rx_dataout_bp avalon_streaming end
	set_interface_property rx_dataout_bp dataBitsPerSymbol $lw
	set_interface_property rx_dataout_bp errorDescriptor ""
	set_interface_property rx_dataout_bp maxChannel 0
	set_interface_property rx_dataout_bp readyLatency 0
	set_interface_property rx_dataout_bp symbolsPerBeat 1
	
	if { $rxcoreclk == 1} {
	    set_interface_property rx_dataout_bp ASSOCIATED_CLOCK rx_coreclkin
	    set_interface_property rx_dataout_bp ENABLED true
	} else {
	    set_interface_property rx_dataout_bp ASSOCIATED_CLOCK rx_user_clkout
	    set_interface_property rx_dataout_bp ENABLED true
	}
	add_interface_port rx_dataout_bp rx_dataout_bp data Input $lw
	
	common_add_tagged_conduit_bus rx_fifo_clr input $lw true

	## Terminate the remaining ports which are not exposed
	common_add_tagged_conduit_bus rx_fifopfull output $lw true		
	set_port_property rx_fifopfull TERMINATION true
    }



}

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc common_mgmt_interface { addr_width {readLatency 1} } {
	global common_composed_mode
	
	# +-----------------------------------
	# | soft logic status conduits
	# | 
##	common_add_optional_conduit tx_ready output 1 true
##	common_add_optional_conduit rx_ready output 1 true
	
	# +-----------------------------------
	# | connection point mgmt_clk
	# | 
	common_add_clock  phy_mgmt_clk  input  1
	if {$common_composed_mode == 0} {
	    add_interface phy_mgmt_clk_reset reset end
	    add_interface_port phy_mgmt_clk_reset phy_mgmt_clk_reset reset Input 1
	    set_interface_property phy_mgmt_clk_reset ASSOCIATED_CLOCK phy_mgmt_clk
	} else {
		add_interface phy_mgmt_clk_rst reset end
		set_interface_property phy_mgmt_clk_rst export_of phy_mgmt_clk.clk_in_reset
	}

	# +-----------------------------------
	# | connection point phy_mgmt
	# | 
	add_interface phy_mgmt avalon end
	if {$common_composed_mode == 0} {
		set_interface_property phy_mgmt addressAlignment DYNAMIC
		set_interface_property phy_mgmt burstOnBurstBoundariesOnly false
		set_interface_property phy_mgmt explicitAddressSpan 0
		set_interface_property phy_mgmt holdTime 0
		set_interface_property phy_mgmt isMemoryDevice false
		set_interface_property phy_mgmt isNonVolatileStorage false
		set_interface_property phy_mgmt linewrapBursts false
		set_interface_property phy_mgmt maximumPendingReadTransactions 0
		set_interface_property phy_mgmt printableDevice false
		set_interface_property phy_mgmt readLatency $readLatency
		set_interface_property phy_mgmt readWaitStates 0
		set_interface_property phy_mgmt readWaitTime 0
		set_interface_property phy_mgmt setupTime 0
		set_interface_property phy_mgmt timingUnits Cycles
		set_interface_property phy_mgmt writeWaitTime 0
		set_interface_property phy_mgmt ASSOCIATED_CLOCK phy_mgmt_clk
		set_interface_property phy_mgmt ENABLED true
		
		add_interface_port phy_mgmt phy_mgmt_address address Input $addr_width
		add_interface_port phy_mgmt phy_mgmt_read read Input 1
		add_interface_port phy_mgmt phy_mgmt_readdata readdata Output 32
		add_interface_port phy_mgmt phy_mgmt_write write Input 1
		add_interface_port phy_mgmt phy_mgmt_writedata writedata Input 32
		add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest Output 1
	}
}

# +-----------------------------------
# | top-PHY extra parameters
# | 
proc add_extra_parameters_for_top_phy { } {

	add_parameter mgmt_clk_in_hz LONG 150000000
	set_parameter_property mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
	set_parameter_property mgmt_clk_in_hz VISIBLE false
	set_parameter_property mgmt_clk_in_hz AFFECTS_GENERATION true
	set_parameter_property mgmt_clk_in_hz HDL_PARAMETER false

	add_parameter mgmt_clk_in_mhz INTEGER 150 
	set_parameter_property mgmt_clk_in_mhz DERIVED true
	set_parameter_property mgmt_clk_in_mhz VISIBLE false
	set_parameter_property mgmt_clk_in_mhz AFFECTS_GENERATION true
	set_parameter_property mgmt_clk_in_mhz HDL_PARAMETER true
}



# +-----------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_optional_conduit { port_name port_dir width used } {

	global common_composed_mode
	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	if {$common_composed_mode == 0} {
		set_interface_property $port_name ENABLED $used
		add_interface_port $port_name $port_name export $port_dir $width
	}
}

proc common_add_optional_conduit_bus { port_name port_dir width used } {
  common_add_optional_conduit $port_name $port_dir $width $used 
  set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}



# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with pipe_pclk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_stream { port_name port_dir width used clk_name} {

	global common_composed_mode
	array set in_out [list {output} {start} {input} {end} ]
	# create interface details
	add_interface $port_name avalon_streaming $in_out($port_dir)
	if {$common_composed_mode == 0} {
	    set_interface_property $port_name dataBitsPerSymbol $width
	    set_interface_property $port_name maxChannel 0
	    set_interface_property $port_name readyLatency 0
	    set_interface_property $port_name symbolsPerBeat 1
	    set_interface_property $port_name ENABLED $used
	    set_interface_property $port_name ASSOCIATED_CLOCK $clk_name
	    add_interface_port $port_name $port_name data $port_dir $width
	    
	}
    }


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock { port_name port_dir port_width } {

	global common_composed_mode
	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name clock $in_out($port_dir)
	if {$common_composed_mode == 0} {
		set_interface_property $port_name ENABLED true
		add_interface_port $port_name $port_name clk $port_dir $port_width
	} else {
		# create clock source instance for composed mode
		add_instance $port_name clock_source
		set_interface_property $port_name export_of $port_name.clk_in
	}
	
    }


proc validate_pll_type { device_family } {
  ::alt_xcvr::utils::common::map_allowed_range gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
}


proc add_pll_reconfig_parameters {group} {
  set max_plls 2
  set max_refclks 2

  if { [::alt_xcvr::gui::pll_reconfig::initialize $group $max_plls $max_refclks] == 0} {
    puts "Error, could not initialize pll_reconfig package"
  }
}
