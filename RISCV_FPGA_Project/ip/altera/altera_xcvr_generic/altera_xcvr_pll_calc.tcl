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




#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# This file has been deprecated and should no longer be used.

# +--------------------------------------------------------------------------------
# | PLL computation library
# +----------------------------------------------------------------------------------
package require quartus::advanced_hssi_legality

set alt_xcvr_packages_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages"
if { [lsearch -exact $auto_path $alt_xcvr_packages_dir] == -1 } {
  lappend auto_path $alt_xcvr_packages_dir
}
package require alt_xcvr::utils::rbc
package require alt_xcvr::utils::common

namespace import ::alt_xcvr::utils::common::get_data_rate_in_mbps
namespace import ::alt_xcvr::utils::common::get_freq_in_mhz
namespace import ::alt_xcvr::utils::rbc::validate_pcs_data_rate
namespace import ::alt_xcvr::utils::rbc::rbc_values_cleanup

#!!!!!!!!!!!!!!!!!!!!!!!!! Deprecated !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
proc validate_refclk_freq { device_family data_rate op_mode prot_mode deser_factor pcs_datapath pcs_dw_mode base_factor {data_path_type ""} } {
	
	upvar 1 atx_ref_handler refclk_list_atx
	upvar 1 cmu_ref_handler refclk_list_cmu
	
	#Select device according to family
	set device [::alt_xcvr::utils::device::get_typical_device $device_family]

	#clear all arrays
	if { [info exist [array names refclk_array_atx]] } {
		array unset refclk_array_atx
	}
	if { [info exist [array names refclk_array_cmu]] } {
		array unset refclk_array_cmu
	}
	if { [info exist [array names refclk_array]] } {
		array unset refclk_array
	}
	
	if { [info exist refclk_list_atx] } {
		set refclk_list_atx { }
	}
	
	if { [info exist refclk_list_cmu] } {
		set refclk_list_cmu { }
	}
	
	#convert data rate string to integer Mbps
	set data_int [::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate]
	#convert data rate to output clock frequency
	set output_clk_freq_int [expr $data_int / 2.0]
	
	lappend output_clk_freq $output_clk_freq_int "MHz"
	
	#get dependencies
	set pma_dw [get_pma_dw $deser_factor $base_factor $pcs_dw_mode]
	
	if {$op_mode == "Rx"} {
		set rxp_bus "CONNECTED"
		set tx_pcs ""
		set rx_pcs $pcs_datapath
	} else {
		set rxp_bus "DISCONNECTED"
		set tx_pcs $pcs_datapath
		set rx_pcs ""
	}
		
	#calling CDR PLL computation rules
#    puts " calculating atx pll return values"
#    puts " device = ${device} "
#    puts " output_clk_freq = ${output_clk_freq}"
#    puts " tx_pcs = ${tx_pcs}"
#    puts " prot_mode = ${prot_mode}"
#    puts " pma_dw = ${pma_dw}"
#    puts " prot_mode = ${prot_mode}"

    if { $data_path_type == "ATT" } {
		set return_value_atx [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG -rule_name STRATIXV_LC_PLL_REFERENCE_CLOCK_FREQUENCY -param_args [list $device $output_clk_freq "DISCONNECTED" "CONNECTED" $tx_pcs $prot_mode $pma_dw $prot_mode $prot_mode "DISABLE_PCS"]]
		set return_value_cmu "{{}}"
	} elseif { $device_family == "Stratix V" } {
		set return_value_atx [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG -rule_name STRATIXV_LC_PLL_REFERENCE_CLOCK_FREQUENCY -param_args [list $device $output_clk_freq "CONNECTED" "DISCONNECTED" $tx_pcs $prot_mode $pma_dw $prot_mode $prot_mode "DISABLE_PCS"]]
		set return_value_cmu [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG  -rule_name STRATIXV_CDR_PLL_REFERENCE_CLOCK_FREQUENCY -param_args [list $device $output_clk_freq $rxp_bus $tx_pcs $rx_pcs $prot_mode $pma_dw $prot_mode $prot_mode "DISABLE_PCS" $prot_mode $pma_dw $prot_mode $prot_mode "DISABLE_PCS"]]
	} else {
		#dummy value for ATX 
		set return_value_atx "{{}}"
		set return_value_cmu [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name ARRIAV_HSSI_CONFIG  -rule_name ARRIAV_CDR_PLL_REFERENCE_CLOCK_FREQUENCY -param_args [list $device $output_clk_freq $rxp_bus $tx_pcs $rx_pcs $prot_mode $pma_dw $prot_mode $prot_mode $pma_dw $prot_mode]]
	}
	
	#strip off {{ and }} from RBC
	set return_value_atx [rbc_values_cleanup $return_value_atx]
	set return_value_cmu [rbc_values_cleanup $return_value_cmu]
	
	#split each refclk freq returned
	set return_array_atx [split $return_value_atx |]
	set return_array_cmu [split $return_value_cmu |]
	
	#extract frequency
	array set refclk_array_atx { }
	array set refclk_array_cmu { }
	set refclk_max 710	;#max limit for refclk freq is 710 MHz
	
	foreach freq $return_array_atx {
		regexp {([0-9.]+)} $freq value_atx 
		set refclk_array_atx($value_atx) 1
	}
	
	foreach freq $return_array_cmu {
		regexp {([0-9.]+)} $freq value_cmu 
		set refclk_array_cmu($value_cmu) 1
	}
	
	#append into list
	foreach f [array names refclk_array_atx] {
		lappend refclk_list_atx $f
	}
	
	foreach f [array names refclk_array_cmu] {
		lappend refclk_list_cmu $f
	}
	
	#merge ATX and CMU RBC returned values
	array set refclk_array { }
	
	if { [info exists refclk_list_atx] && [info exists refclk_list_cmu] } {
 		set refclk_list [concat $refclk_list_atx $refclk_list_cmu]
	} elseif { [info exists refclk_list_atx] } {
		set refclk_list $refclk_list_atx
	} elseif { [info exists refclk_list_cmu] } {
		set refclk_list $refclk_list_cmu
	} else {
		set refclk_list "junk"
	}
	
	foreach refclk $refclk_list {
		set refclk_array($refclk) 1
	}
	
	#writes refclk into correct format
	foreach f [lsort -real [array names refclk_array] ] {
		if { $f <= $refclk_max } {
			lappend refclk_str "$f MHz"
		}
	}
	
	#Prompt error message when data rate is illegal and return 'N/A' as result
	if ![info exist refclk_str] {
		set refclk_str "N/A"
	}
	
	return $refclk_str
}

proc validate_usr_refclk_freq { pll_refclk_freq_str {data_path_type ""} } {

	upvar 1 atx_ref_handler legal_values_atx
	upvar 1 cmu_ref_handler legal_values_cmu
		
    #convert user refclk freq to integer
	regexp {([0-9]+\.?[0-9]*)} $pll_refclk_freq_str ref_value 
	
	#extract frequency
	array set refclk_array_atx { }
	array set refclk_array_cmu { }
	
	if [ info exists legal_values_atx ] {
		foreach freq $legal_values_atx {
			regexp {([0-9.]+)} $freq value_atx 
			set refclk_array_atx($value_atx) 1
		}
	}
	
	if [ info exists legal_values_cmu ] {
		foreach freq $legal_values_cmu {
			regexp {([0-9.]+)} $freq value_cmu
			set refclk_array_cmu($value_cmu) 1
		}
	}
	
	#compare user refclk freq with legal refclk freq list
	if { [info exists refclk_array_atx($ref_value) ] } {
		#refclk selected valid for ATX PLL
		set atx_valid "true"
	} else {
		set atx_valid "false"
	}

	if { [info exists refclk_array_cmu($ref_value) ] } {
		#refclk selected valid for CMU PLL
		set cmu_valid "true"
	} else {
		set cmu_valid "false"
	}
	
    if { $data_path_type == "ATT" } {
		send_message info "ATT channel is only supported with ATX PLL"
		send_message info "No need to explicitely change the PLL type to ATX using quartus assignment"
	} elseif { $cmu_valid == "true" && $atx_valid == "true" } {
		send_message info "The chosen data rate and reference clock frequency is legal for CMU PLL and ATX PLL"
		send_message info "To change the PLL type to ATX, update the PLL_TYPE to ATX using quartus assignment"
	} elseif { $cmu_valid == "true" } {
		send_message info "The chosen data rate and reference clock frequency is legal for CMU PLL only"
	} elseif { $atx_valid == "true" } {
		send_message info "The chosen data rate and reference clock frequency is legal for ATX PLL only"
		send_message info "To change the PLL type to ATX, update the PLL_TYPE to ATX using quartus assignment"
	} else {
		send_message error "The chosen data rate does not return valid reference clock frequency"
	}
}


proc get_pma_dw { deser_factor base_factor pcs_dw_mode } {
	if { ($deser_factor == 8 && $base_factor == 8) || ($deser_factor == 16 && $base_factor == 8 && $pcs_dw_mode == "Double") }  {
		set pma_dw "EIGHT_BIT"
	} elseif { ($deser_factor == 10 ||  ($deser_factor == 8 && $base_factor == 10)) || (($deser_factor == 20 || ($deser_factor == 16 && $base_factor == 10)) && $pcs_dw_mode == "Double") }  {
		set pma_dw "TEN_BIT"
	} elseif { ($deser_factor == 16 || $deser_factor == 32) && $base_factor == 8 } {
		set pma_dw "SIXTEEN_BIT"
	} else {
		set pma_dw "TWENTY_BIT"
	}
}
