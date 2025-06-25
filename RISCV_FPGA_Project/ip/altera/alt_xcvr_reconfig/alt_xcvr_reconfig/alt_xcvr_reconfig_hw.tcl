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


# Interface definition for alt_xcvr_reconfig
#
# $Header: //acds/rel/13.1/ip/alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_hw.tcl#1 $

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact qsys 12.0
# | 
# +-----------------------------------

# +-------------------------------------
# | External functions for common blocks
# | 
lappend auto_path $::env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
package require alt_xcvr::utils::ipgen

source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source alt_xreconf_common.tcl

set_module_property ALLOW_GREYBOX_GENERATION true

# +-----------------------------------
# | module pcie
# | 
set_module_property NAME alt_xcvr_reconfig
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property DISPLAY_NAME "Transceiver Reconfiguration Controller"
set_module_property GROUP "Interface Protocols/Transceiver PHY"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Transceiver Reconfiguration Controller is used to dynamically calibrate and reconfigure features of PHY IP cores"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"
set_module_property ANALYZE_HDL false

set_module_property ELABORATION_CALLBACK elaborate


# +-----------------------------------
# | native PHY parameters
# | 
proc xreconf_add_device_parameters {} {

    # adding device_family from SYSTEM INFO
    add_parameter device_family STRING "Stratix V"
    set_parameter_property device_family DISPLAY_NAME "Device family"
    set_parameter_property device_family SYSTEM_INFO device_family  ;# forces family to always match Qsys
    set fams [list_s5_style_hssi_families]	   	
    set fams [concat $fams [list_a5_style_hssi_families] ]	   	
    set fams [concat $fams [list_c5_style_hssi_families] ]	   	
    set_parameter_property device_family ALLOWED_RANGES $fams
    set_parameter_property device_family HDL_PARAMETER true
    set_parameter_property device_family ENABLED false
    set_parameter_property device_family DESCRIPTION "The Transceiver Reconfiguration Controller is available for Stratix V and Arria V GZ devices."
}

# +-----------------------------------
# | reconfig analog parameter helper
# | 
proc xreconf_add_analog_parameter { name defValue displayName } {
    add_parameter $name INTEGER $defValue
    set_parameter_property $name DISPLAY_NAME $displayName
    set_parameter_property $name DISPLAY_HINT boolean
    set_parameter_property $name HDL_PARAMETER true
    add_display_item "Analog Features" $name parameter
}

# +-----------------------------------
# | reconfig calibration parameter helper
# | 
proc xreconf_add_calibration_parameter { name defValue displayName enabled } {
    add_parameter $name INTEGER $defValue
    set_parameter_property $name DISPLAY_NAME $displayName
    set_parameter_property $name DISPLAY_HINT boolean
    set_parameter_property $name HDL_PARAMETER true
    set_parameter_property $name ENABLED $enabled
    add_display_item "Transceiver Calibration functions" $name parameter
}

# +-----------------------------------
# | reconfig reconfiguration parameter helper
# | 
proc xreconf_add_reconfiguration_parameter { name defValue displayName is_derived is_hdl} {
    add_parameter $name INTEGER $defValue
    set_parameter_property $name DISPLAY_NAME $displayName
    set_parameter_property $name DISPLAY_HINT boolean
    if {$is_hdl == "true"} {
      set_parameter_property $name HDL_PARAMETER true
    } else {
      set_parameter_property $name HDL_PARAMETER false
    }
  
    if {$is_derived == "true"} {
      set_parameter_property $name DERIVED true
    }
    add_display_item "Reconfiguration Features" $name parameter
}

# +-----------------------------------
# | reconfig parameters
# | 
proc xreconf_add_parameters { } {
    set interfaces "Interface Bundles"

    add_parameter number_of_reconfig_interfaces INTEGER 2
    set_parameter_property number_of_reconfig_interfaces DISPLAY_NAME "Number of reconfiguration interfaces"
    set_parameter_property number_of_reconfig_interfaces ALLOWED_RANGES 1:2048
    set_parameter_property number_of_reconfig_interfaces HDL_PARAMETER true
    set_parameter_property number_of_reconfig_interfaces DESCRIPTION "Specifies the total number of reconfiguration interfaces that connect to this Transceiver Reconfiguration Controller. There is one interface for each channel and TX PLL."
    add_display_item $interfaces number_of_reconfig_interfaces parameter

    add_parameter gui_split_sizes STRING ""
    set_parameter_property gui_split_sizes DISPLAY_NAME "Optional interface grouping"
    set_parameter_property gui_split_sizes HDL_PARAMETER false
    set_parameter_property gui_split_sizes DESCRIPTION "A comma-separated list of integers in which  each integer indicates the total number of reconfiguration interfaces connected to a transceiver PHY instance. Leave blank if all interfaces are connected to one transceiver PHY instance."
    add_display_item $interfaces gui_split_sizes parameter

    add_display_item $interfaces split_sizes_text TEXT "(e.g. '2,2' or leave blank for a single bundle)"

    add_display_item "Transceiver Calibration functions" "reset_message" TEXT "NOTE - please refer to the device handbook for reset sequence requirements between the reconfiguration controller and transceiver PHY."
    xreconf_add_calibration_parameter enable_offset       1 "Enable offset cancellation" false
    xreconf_add_calibration_parameter enable_lc           1 "Enable PLL calibration" false
    xreconf_add_calibration_parameter enable_dcd          0 "Enable duty cycle calibration" true
    xreconf_add_calibration_parameter enable_dcd_power_up 1 "Calibrate duty cycle during power up" true
    xreconf_add_analog_parameter enable_analog            1 "Enable Analog controls"
    xreconf_add_analog_parameter enable_eyemon            0 "Enable EyeQ block"
    add_parameter ber_en INTEGER                          0
    add_parameter enable_ber INTEGER                      0
    add_display_item "Analog Features" ber_en parameter 
    xreconf_add_analog_parameter enable_dfe               0 "Enable decision feedback equalizer (DFE) block"
    xreconf_add_analog_parameter enable_adce              0 "Enable adaptive equalization (AEQ) block"
    xreconf_add_reconfiguration_parameter enable_mif      0 "Enable channel/PLL reconfiguration" false true
    xreconf_add_reconfiguration_parameter gui_enable_pll  0 "Enable PLL reconfiguration support block" false false
    xreconf_add_reconfiguration_parameter enable_pll      0 "Enable PLL reconfiguration support block" true true
    
    set_parameter_property enable_offset    DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the offset cancellation functionality."
    set_parameter_property enable_analog    DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the analog control block."
    set_parameter_property enable_adce      DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the adaptive equalization block."
    set_parameter_property enable_lc        DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes PLL calibration logic. PLL calibration runs automatically at startup. Refer to the device handbook for reset sequence requirements between the reconfiguration controller and transceiver channels."
    set_parameter_property enable_mif       DESCRIPTION "When enabled, full channel/PLL reconfiguration is supported."
    set_parameter_property enable_pll       DESCRIPTION "When enabled, supports PLL reconfiguration. Full PLL reconfiguration requires channel/PLL reconfiguration feature."
    set_parameter_property gui_enable_pll   DESCRIPTION "When enabled, supports PLL reconfiguration. Full PLL reconfiguration requires channel/PLL reconfiguration feature."    
    set_parameter_property enable_dcd       DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the duty cycle calibration block."
    set_parameter_property enable_dfe       DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the DFE block."
    set_parameter_property enable_eyemon    DESCRIPTION "When enabled, the Transceiver Reconfiguration Controller includes the EyeQ block."
    set_parameter_property ber_en           DESCRIPTION "When enabled, the EyeQ block includes the BER block.  Requires the EyeQ to be enabled."

    #assign the paramter properties to enable_ber.  It is non-visible parameter derived from ber_en
    set_parameter_property enable_ber DISPLAY_NAME "Enable Bit Error Rate Block"
    set_parameter_property enable_ber DISPLAY_HINT boolean
    set_parameter_property enable_ber HDL_PARAMETER true
    set_parameter_property enable_ber VISIBLE false
    set_parameter_property enable_ber DERIVED true

    #Create an option in the GUI which is NOT an HDL parameter to derive the value of enable_ber
    set_parameter_property ber_en DISPLAY_NAME "Enable Bit Error Rate Block"
    set_parameter_property ber_en DISPLAY_HINT boolean
    set_parameter_property ber_en HDL_PARAMETER false

    set_parameter_property enable_lc DERIVED true
    
    add_parameter gui_cal_status_port boolean 0
    set_parameter_property gui_cal_status_port DISPLAY_NAME "Create optional calibration status ports"
    set_parameter_property gui_cal_status_port HDL_PARAMETER false
    set_parameter_property gui_cal_status_port DESCRIPTION "When enabled, calibration status ports will be created."
    add_display_item "Transceiver Calibration functions" gui_cal_status_port parameter
    
    #disable DCD
    set_parameter_property enable_dcd       VISIBLE     false
    set_parameter_property enable_dcd_power_up      VISIBLE     false
}


# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc xreconf_add_tagged_conduit { port_name port_dir width tags {port_role "export"} } {

    array set in_out [list {output} {start} {input} {end} ]
    add_interface $port_name conduit $in_out($port_dir)
    set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
    #set_interface_property $port_name ENABLED $used
    common_add_interface_port $port_name $port_name $port_role $port_dir $width $tags
    if {$port_dir == "input"} {
        set_port_property $port_name TERMINATION_VALUE 0
    }
}
proc xreconf_add_tagged_conduit_bus { port_name port_dir width tags {port_role "export"} } {
    xreconf_add_tagged_conduit $port_name $port_dir $width $tags $port_role
    set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}
proc xreconf_add_tagged_split_conduit_bus { port_name port_dir width tags fragments {port_role "export"} } {
    xreconf_add_tagged_conduit_bus $port_name $port_dir $width $tags $port_role
    set_port_property ${port_name} FRAGMENT_LIST ${fragments}
}

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc xreconf_mgmt_interface { {addr_width 7} } {
    
    # +-----------------------------------
    # | mgmt clock and reset
    # | 
    add_interface      mgmt_clk_clk clock end
    add_interface_port mgmt_clk_clk mgmt_clk_clk clk Input 1

    add_interface          mgmt_rst_reset reset end
    add_interface_port     mgmt_rst_reset mgmt_rst_reset reset Input 1
    set_interface_property mgmt_rst_reset ASSOCIATED_CLOCK mgmt_clk_clk

    # +-----------------------------------
    # | connection point reconfig_mgmt
    # | 
    add_interface reconfig_mgmt avalon end
    set_interface_property reconfig_mgmt addressAlignment DYNAMIC
    set_interface_property reconfig_mgmt writeWaitTime 0
    set_interface_property reconfig_mgmt ASSOCIATED_CLOCK mgmt_clk_clk
    
    add_interface_port reconfig_mgmt reconfig_mgmt_address address Input $addr_width
    add_interface_port reconfig_mgmt reconfig_mgmt_read read Input 1
    add_interface_port reconfig_mgmt reconfig_mgmt_readdata readdata Output 32
    add_interface_port reconfig_mgmt reconfig_mgmt_waitrequest waitrequest Output 1
    add_interface_port reconfig_mgmt reconfig_mgmt_write write Input 1
    add_interface_port reconfig_mgmt reconfig_mgmt_writedata writedata Input 32
}

# +-----------------------------------
# | MIF interface ports
# | 
# | - 
# |
 
proc xreconf_mif_interface { {addr_width 32} } {
    
    # +-----------------------------------
    # | connection point reconfig_mif
    # | 
    add_interface reconfig_mif avalon start mgmt_clk_clk
    set_interface_property reconfig_mif ASSOCIATED_CLOCK mgmt_clk_clk
    set_interface_property reconfig_mif bitsPerSymbol 8
    set_interface_property reconfig_mif addressUnits SYMBOLS
  
    add_interface_port reconfig_mif reconfig_mif_address address Output $addr_width
    add_interface_port reconfig_mif reconfig_mif_read read Output 1
    add_interface_port reconfig_mif reconfig_mif_readdata readdata Input 16
    add_interface_port reconfig_mif reconfig_mif_waitrequest waitrequest Input 1

}

proc xreconf_make_dynamic_mif_interface { } {
  set en_mif [get_parameter_value enable_mif]

  if {$en_mif == 0} {
      set_port_property reconfig_mif_address       TERMINATION true
      set_port_property reconfig_mif_read          TERMINATION true
      set_port_property reconfig_mif_readdata      TERMINATION true
      set_port_property reconfig_mif_readdata      TERMINATION_VALUE 0
      set_port_property reconfig_mif_waitrequest   TERMINATION true
      set_port_property reconfig_mif_waitrequest   TERMINATION_VALUE 0
    }
}

# +---------------------------------------------
# | reconfig to_xcvr & from_xcvr split bus widths
# | 
# | default return is a single entry with all interfaces
proc xreconf_to_from_xcvr_bundle_groups { } {
    set gui_split_sizes [get_parameter_value gui_split_sizes]
    set nifs [get_parameter_value number_of_reconfig_interfaces]
    set bundle_groups [list]
    set nif_count 0

    # check that only these chars exist in input: "0-9, "
    if {[regexp {^[0-9, ]*$} $gui_split_sizes]} {
        set bundle_sizes [split $gui_split_sizes " ,"]
        
        # add any non-null entries into returned list
        foreach b $bundle_sizes {
            if {$b != "" && $b > 0} {
                lappend bundle_groups $b
                set nif_count [expr {$nif_count + $b}]
            }
        }
        
        # any left-over interfaces that are not in a group?
        if {$nif_count < $nifs} {
            # add unallocated interfaces to last bundle
            lappend bundle_groups [expr {$nifs - $nif_count}]
        } elseif {$nif_count > $nifs} {
            send_message warning "Interface bundle grouping contains too many interfaces.  Split bundles add up to $nif_count, but only $nifs interfaces specified"
            set bundle_groups [list $nifs]
        }
    } else {
        send_message warning "Interface bundle grouping list contains illegal characters.  Leave empty or use numbers separated by commas"
        set bundle_groups [list $nifs]
    }

    #send_message info "xreconf_to_from_xcvr_bundle_groups{} returns $bundle_groups"
    return $bundle_groups
}

# +-----------------------------------
# | reconfig to_xcvr & from_xcvr conduits
# | 
# | Dynamically creates split busses to user spec
proc xreconf_to_from_xcvr_conduits { } {

    # get parameters that affect to/from_xcvr widths
    set device_family [get_parameter_value device_family]
    set nifs [get_parameter_value number_of_reconfig_interfaces]
    set w_bundle_to_xcvr [common_get_reconfig_to_xcvr_width $device_family]
    set w_bundle_from_xcvr [common_get_reconfig_from_xcvr_width $device_family]
    
    # bundle splitting option
    set bundle_sizes [xreconf_to_from_xcvr_bundle_groups]

    #conduits for native reconfig bundles:
    set bundle_start_ch 0
    foreach b $bundle_sizes {
        # native interfaces in this bundle
        set w_to_b   [expr {$b * $w_bundle_to_xcvr}]
        set w_from_b [expr {$b * $w_bundle_from_xcvr}]
        set bundle_end_ch [expr {$bundle_start_ch + $b - 1}]
        if {$b == $nifs} {
            # special case for a single bundle containing everything
            xreconf_add_tagged_conduit_bus reconfig_to_xcvr output $w_to_b {NoTag} reconfig_to_xcvr
            xreconf_add_tagged_conduit_bus reconfig_from_xcvr input $w_from_b {NoTag} reconfig_from_xcvr

            # display width info message to user
            set native_ifs [get_parameter_value number_of_reconfig_interfaces]
            send_message info "reconfig_from_xcvr port width is $native_ifs*$w_bundle_from_xcvr bits"
            send_message info "reconfig_to_xcvr port width is $native_ifs*$w_bundle_to_xcvr bits"
        } else {
            set to_start_bit [expr {$bundle_start_ch * $w_bundle_to_xcvr}]
            set to_end_bit   [expr {($bundle_start_ch + $b) * $w_bundle_to_xcvr -1}]
            set to_fragment  "reconfig_to_xcvr@${to_end_bit}:${to_start_bit}"
            xreconf_add_tagged_split_conduit_bus "ch${bundle_start_ch}_${bundle_end_ch}_to_xcvr" output $w_to_b {NoTag} $to_fragment reconfig_to_xcvr

            set from_start_bit [expr {$bundle_start_ch * $w_bundle_from_xcvr}]
            set from_end_bit   [expr {($bundle_start_ch + $b) * $w_bundle_from_xcvr -1}]
            set from_fragment  "reconfig_from_xcvr@${from_end_bit}:${from_start_bit}"
            xreconf_add_tagged_split_conduit_bus "ch${bundle_start_ch}_${bundle_end_ch}_from_xcvr" input $w_from_b {NoTag} $from_fragment reconfig_from_xcvr
        }
        set bundle_start_ch [expr {$bundle_start_ch + $b}]
    }
}

# +-----------------------------------
# | reconfig status conduit
# | 
proc xreconf_native_conduits { } {
   
    #conduits for status output:
    xreconf_add_tagged_conduit reconfig_busy output 1 {NoTag} reconfig_busy
    
    xreconf_add_tagged_conduit tx_cal_busy output 1 {CalStatus} tx_cal_busy
    xreconf_add_tagged_conduit rx_cal_busy output 1 {CalStatus} tx_cal_busy
    xreconf_add_tagged_conduit cal_busy_in input 1 {DCD} cal_busy_in
}

# +----------------------------------
# | validate parameters
# |
proc xreconf_validate_parameters { } {
    set mif_en      [get_parameter_value enable_mif] 
    set gui_pll_en  [get_parameter_value gui_enable_pll]
    set device_family [get_parameter_value device_family]
    set enable_dcd_power_up [get_parameter_value enable_dcd]

    if { $mif_en == 1 } {
      set_parameter_property gui_enable_pll ENABLED false
      set_parameter_property gui_enable_pll VISIBLE false
      set_parameter_property enable_pll ENABLED true
      set_parameter_property enable_pll VISIBLE true
      set_parameter_value enable_pll 1
    } else {
      set_parameter_property gui_enable_pll ENABLED true
      set_parameter_property gui_enable_pll VISIBLE true
      set_parameter_property enable_pll ENABLED false 
      set_parameter_property enable_pll VISIBLE false
      set_parameter_value enable_pll [get_parameter_value gui_enable_pll]
    }

    if { [has_a5_style_hssi $device_family] } {
        set_parameter_property enable_lc VISIBLE false
        set_parameter_value    enable_lc 0
        set_parameter_property enable_eyemon VISIBLE false
        set_parameter_property ber_en VISIBLE false
        set_parameter_property enable_ber VISIBLE false
        set_parameter_property enable_dfe VISIBLE false
        set_parameter_property enable_adce VISIBLE false
		    # fix case 54957 - re-enable DCD for AV
        set_parameter_property enable_dcd  VISIBLE true
        set_parameter_property enable_dcd_power_up VISIBLE $enable_dcd_power_up
        set_parameter_property enable_dcd_power_up ENABLED  $enable_dcd_power_up
    }

    if { [has_c5_style_hssi $device_family] } {
        set_parameter_property enable_lc VISIBLE false
        set_parameter_value    enable_lc 0
        set_parameter_property enable_eyemon VISIBLE false
        set_parameter_property ber_en VISIBLE false
        set_parameter_property enable_ber VISIBLE false
        set_parameter_property enable_dfe VISIBLE false
        set_parameter_property enable_adce VISIBLE false
        set_parameter_property enable_dcd VISIBLE true
        set_parameter_property enable_dcd_power_up VISIBLE $enable_dcd_power_up
        set_parameter_property enable_dcd_power_up ENABLED $enable_dcd_power_up
    }

    if { [get_parameter_value enable_eyemon] == "1" } {
        set_parameter_property ber_en ENABLED true
        set_parameter_value enable_ber [get_parameter_value ber_en]
    }

    if { [get_parameter_value enable_eyemon] == "0" } {
        set_parameter_property ber_en ENABLED false 
        set_parameter_value enable_ber 0
    }

}

proc xreconf_set_port_termination {} {
  
  set terminate_cal_status_port "true"
  set terminate_dcd_port "true"
  set device_family [get_parameter_value device_family]
  
  if { [get_parameter_value gui_cal_status_port] } {
    set terminate_cal_status_port "false"
  } 
  
  if { [get_parameter_value enable_dcd] && [has_a5_style_hssi $device_family] } {
    set terminate_dcd_port "false"
  } 
   
  if { [get_parameter_value enable_dcd] && [has_c5_style_hssi $device_family] } {
    set terminate_dcd_port "false"
  } 

  common_set_port_group {CalStatus} TERMINATION $terminate_cal_status_port
  common_set_port_group {DCD} TERMINATION $terminate_dcd_port
}
  

# +-----------------------------------
# | add parameters & static ports
# | 
xreconf_add_device_parameters
xreconf_add_parameters
xreconf_native_conduits
xreconf_mgmt_interface
xreconf_mif_interface


# +-----------------------------------
# | Elaboration callback
# | 
proc elaborate { } {
    xreconf_validate_parameters
    xreconf_to_from_xcvr_conduits
    xreconf_make_dynamic_mif_interface
    xreconf_set_port_termination
}

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

# For missing vendor-encrypted files, choose to warn only once per vendor
common_enable_summary_sim_support_warnings 1

#
# declare all files, with appropriate implementation and tool-flow tags
#
xreconf_decl_fileset_groups ..

add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth
add_fileset sim_verilog SIM_VERILOG fileset_sim_verilog
add_fileset sim_vhdl SIM_VHDL fileset_sim_vhdl

set_fileset_property synth2 TOP_LEVEL alt_xcvr_reconfig
set_fileset_property sim_verilog TOP_LEVEL alt_xcvr_reconfig
set_fileset_property sim_vhdl TOP_LEVEL alt_xcvr_reconfig

# +------------------------------------------
# | Define fileset by family for given tools
# | Helper when using common tags:
# |  - ALL_HDL, C4, S4, S5, A5
# | 
proc xreconf_add_fileset_for_tool {tool} {

    # S4-generation family?
    set device_family [get_parameter_value device_family]
    if { [has_s4_style_hssi $device_family] } {
        common_add_fileset_files {S4 ALL_HDL ALL_RECONF} $tool
    } elseif { [has_c4_style_hssi $device_family] } {
        # C4 and derivatives
        common_add_fileset_files {C4 ALL_HDL ALL_RECONF} $tool
    } elseif { [has_s5_style_hssi $device_family] } {
        # S5 and derivatives
        set tag_list {S5_RECONF ALL_HDL ALL_RECONF}

        set enable_soc [expr {[get_parameter_value enable_lc] || [get_parameter_value enable_offset]}]
        if {$enable_soc == 1} {
          set tag_list [concat $tag_list S5_RECONF_SOC]
        }
        common_add_fileset_files $tag_list $tool

    } elseif { [has_a5_style_hssi $device_family] } {
        # A5 and derivatives
        common_add_fileset_files {A5_RECONF ALL_HDL ALL_RECONF A5_RECONF_SOC} $tool
    } elseif { [has_c5_style_hssi $device_family] } {
        # C5 and derivatives
        common_add_fileset_files {C5_RECONF ALL_HDL ALL_RECONF C5_RECONF_SOC} $tool
    } else {
        # Unknown family
        send_message error "Current device_family ($device_family) is not supported"
    }
}


# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
    xreconf_generate_qsys_soc QUARTUS_SYNTH
    xreconf_add_fileset_for_tool {PLAIN QENCRYPT QIP}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc fileset_sim_verilog {name} {
    xreconf_generate_qsys_soc SIM_VERILOG
    xreconf_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc fileset_sim_vhdl {name} {
    #xreconf_generate_qsys_soc SIM_VHDL
    xreconf_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}

