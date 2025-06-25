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


package require -exact qsys 13.0

#set tcl_precision 2

set_module_property NAME seriallite_iii
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"

set_module_property INTERNAL true 
set_module_property DESCRIPTION "seriallite_iii_top"
set_module_property GROUP "Interface Protocols/High Speed"
set_module_property DISPLAY_NAME "SerialLite III Streaming"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property SUPPORTED_DEVICE_FAMILIES "stratixv"
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property HIDE_FROM_QSYS true

# +-----------------------------------
# Use alt_xcvr TCL packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::utils::fileset
package require altera_xcvr_reset_control::fileset

source $env(QUARTUS_ROOTDIR)/../ip/altera/altera_xcvr_generic/alt_xcvr_common.tcl
source $env(QUARTUS_ROOTDIR)/../ip/altera/altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl
source $env(QUARTUS_ROOTDIR)/../ip/altera/altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl
#source $env(QUARTUS_ROOTDIR)/../ip/altera/altera_pll/top/pll_hw_extra.tcl

add_fileset synth QUARTUS_SYNTH synth_proc
add_fileset example EXAMPLE_DESIGN example_proc

add_fileset sim_vlog SIM_VERILOG sim_proc
add_fileset sim_vhd SIM_VHDL sim_proc
# define parameters
source params.tcl

# PLL Clocking validation routines
source pll_hw.tcl




proc validation_callback {} {
  
    set cmode [get_parameter_value gui_clocking_mode]
    set dir [get_parameter_value direction]


    # Input User clock frequency sanity checks
    set ucf_val [get_parameter_value gui_user_clock_frequency]
    set ucf_str "$ucf_val MHz"
    if { ![ validate_clock_freq_string $ucf_str ] }  {
       send_message error "User Clock Frequency is not in a recognizable format. A valid format is 138.526"
       return
    }

    # Clocking mode 
    
    if { $cmode == "true" }  {
     
    } 

    set sg [string range [get_parameter_value speedgrade] 0 1]
       set min_f 50
    if {$sg == "1" } { 
	set max_f 800
    } elseif {$sg == "2" } { 
	set max_f 800
    } elseif {$sg == "3" } { 
       set max_f 700
    } else { 
       set max_f 650
    }

    #set ucf [::alt_xcvr::utils::common::get_freq_in_mhz [get_parameter_value gui_user_clock_frequency] ]
    set ucf [get_parameter_value gui_user_clock_frequency] 
    if { $ucf < $min_f} {
	send_message error "Minimum User Clock Frequency value is 50 MHz"  
	return
    } elseif { $ucf > $max_f} {
       send_message error "Maximum User Clock Frequency value is $max_f MHz"
       return
    }


    # Evaluation of fPLL clock frequencies
    if { $cmode == "false" }  {
      set ref_clk [ find_valid_fpll_clocks ]
      set ucf [get_parameter_value gui_actual_user_clock_frequency] 
    } else {
      set ucf [get_parameter_value gui_user_clock_frequency] 
    }

    #set ucf [::alt_xcvr::utils::common::get_freq_in_mhz [get_parameter_value gui_actual_user_clock_frequency] ]
    set input_data_rate [format %f [expr {double($ucf * 64)} ] ]
    set_parameter input_data_rate_param "[format %f [expr $input_data_rate/1000]]"

    # Overhead and actual lane rate calculation
    set mfl [get_parameter_value meta_frame_length]
    set mfo [format %f [expr (4 * $input_data_rate) / ($mfl) ] ]
    send_message INFO "Meta-Frame overhead  = $mfo Mbps"
    #set pcs_input_rate [expr $input_data_rate + $mfo]
    set pcs_input_rate [format %f [expr ($input_data_rate * $mfl) / ($mfl - 4)] ]
    set pcs_output_rate [format %f [expr {double(round($pcs_input_rate * 67/64))}] ]
    send_message INFO "Encoding Overhead = [format %f [expr ($pcs_output_rate - $pcs_input_rate)] ] Mbps"
    set lnr_empirical $pcs_output_rate

    if { $cmode == "true" }  {
      set lnr $lnr_empirical
    } else {
      set lnr [format %f [expr ($ref_clk*40)] ]
      send_message INFO "Additional Overheads = [format %f [expr ($lnr - $lnr_empirical)]] Mbps"
    }
    set_parameter lane_rate_parameter "[format %f [expr $lnr/1000]]"
    set_parameter gui_aggregate_data_rate "[format %f [expr ($input_data_rate * [get_parameter_value lanes]/1024)]]"
    

    # Sanity checks for fpll reference and core clock frequenices
    if { $cmode == "false" }  {
      set rcf [get_parameter_value gui_reference_clock_frequency]
      set_parameter_value reference_clock_frequency  "$ref_clk MHz"
      set_parameter_value gui_interface_clock_frequency  "N.A."
      
      if { $rcf < $min_f} {
         send_message error "Minimum Reference Clock Frequency value is 50 MHz"    
      } elseif { $rcf > $max_f} {
         send_message error "Maximum Reference Clock Frequency value is $max_f MHz"
      }
    
      #set ccf [::alt_xcvr::utils::common::get_freq_in_mhz [get_parameter_value gui_actual_coreclkin_frequency] ]
      set ccf [get_parameter_value gui_actual_coreclkin_frequency]
      if { $ccf < $min_f} {
          send_message error "Minimum Core Clock Frequency value is 50 MHz"    
      } elseif { $ccf > $max_f} {
          send_message error "Maximum Core Clock Frequency value is $max_f MHz"
      }
    } else {
      set icf [format %f [expr "$lnr / 40.0"]]
      set_parameter_value gui_interface_clock_frequency  "$icf"
      set_parameter gui_actual_user_clock_frequency "N.A."
      set_parameter gui_actual_coreclkin_frequency "N.A."
      set_parameter_value gui_reference_clock_frequency  "N.A."
    }


    # Transceiver reference clock frequency calculation and checks
    set trans_pll_refclk [pll_validation $lnr]
    
   
    # Parameter settings
    set_parameter_value adaptation_fifo_depth 32
    #if {$dir == "Source"} {
    #  set_parameter_value adaptation_fifo_depth 32
    #} else {
    #  set_parameter_value adaptation_fifo_depth 32
    # }

    set_parameter_value pll_ref_freq      $trans_pll_refclk
    set_parameter_value data_rate         "$lnr Mbps"
    set_parameter_value pll_type          [get_parameter_value gui_pll_type]
    set_parameter_value ecc_enable        [get_parameter_value gui_ecc_enable]

    if { $cmode == "true" }  {
      #set_parameter_value interface_clock_frequency  [get_parameter_value gui_interface_clock_frequency]
      #set_parameter_property interface_clock_frequency IS_HDL_PARAMETER false
      set_parameter_property user_clock_frequency IS_HDL_PARAMETER false
      set_parameter_property coreclkin_frequency IS_HDL_PARAMETER false
      set_parameter_property reference_clock_frequency  IS_HDL_PARAMETER false

    } else {
      set_parameter_property user_clock_frequency IS_HDL_PARAMETER true
      set_parameter_value user_clock_frequency "[get_parameter_value gui_actual_user_clock_frequency] MHz"
      
      set_parameter_property coreclkin_frequency IS_HDL_PARAMETER true
      set_parameter_value coreclkin_frequency "[get_parameter_value gui_actual_coreclkin_frequency] MHz"
      
      set_parameter_property reference_clock_frequency  IS_HDL_PARAMETER true
      # this parameter is set above
      
    }

}

proc pll_validation { lnr } {

    set family "Stratix V"
    set pll_type [validate_pll_type $family]

    #### set BASE DATA RATE
    # The following statement/function shud enforce if the PLL type supports the data rate
    # but they are only partially working they do not differentiate between CMU with ATX plls (Faisal)
    set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $family $lnr $pll_type]
    if { [llength $base_data_rate_list] == 0 } {
      set base_data_rate_list {"N/A"}
      send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
    } 


    #|----------------
    # Validation for PLL
    #|---------------- 
    ## result variable returns the list of all available refclks for the current data rate
    if {$lnr != "N/A" && $lnr != "N.A"} {
      # May return "N/A"
      set result [::alt_xcvr::utils::rbc::get_valid_refclks $family $lnr $pll_type]
    } else {
      send_message info "setting result to be unavailable"
      set result "N/A"
    }
    #send_message info "result = $result"
  
    if {$result == "N/A"} {
      send_message error "No valid transceiver reference clocks available with the selection"
      return
    } else {
      send_message INFO "It is recommended to choose the highest feasible transceiver reference clock among the available drop-down options" 
    }

    ## Adding following code for backwards compatibility, till 11.0SP2
    ## Interlaken was allowing only one refclk now allowing user to choose refclk from the list, at the same time
    ## we want to open the old designs with the same refclk as before
   
    set my_pll_ref_freq [format %f [expr "$lnr / 20.0"]]
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
    return $user_pll_refclk_freq

}

proc validate_pll_type { device_family } {
  ::alt_xcvr::utils::common::map_allowed_range gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
}

proc validate_clock_freq_string { clock_freq_string } {

# Extract value and units
  regexp {([0-9.]+)} $clock_freq_string value 
  regexp -nocase {([a-z]+)} $clock_freq_string unit

  if {![info exist value] || ![info exist unit]} {
    return 0
  }

  if { [string compare -nocase $unit "MHz" ] != 0 } {
    if { [string compare -nocase $unit "GHz"] != 0 } {
      return 0
    }
  }

  return 1
}

proc elaboration_callback {} {
    
    set num_lanes [get_parameter_value lanes]
    set dir [get_parameter_value direction]
    set cmode [get_parameter_value gui_clocking_mode]
   
   
    #Adding common ports
    #Add Asynchronous reset
    add_interface core_reset reset sink
    add_interface_port core_reset core_reset reset input 1
    set_interface_property core_reset synchronousEdges NONE

    #Adding Phy Mgmt Clk and Reset
    add_interface phy_mgmt_clk clock sink
    add_interface_port phy_mgmt_clk phy_mgmt_clk clk input 1
    add_interface phy_mgmt_clk_reset reset sink
    add_interface_port phy_mgmt_clk_reset phy_mgmt_clk_reset reset Input 1
    set_interface_property phy_mgmt_clk_reset associatedClock phy_mgmt_clk
    ##Adding PHY_MGMT interface
    add_interface phy_mgmt avalon slave 
    add_interface_port phy_mgmt phy_mgmt_address address input 9
    add_interface_port phy_mgmt phy_mgmt_read read input 1
    add_interface_port phy_mgmt phy_mgmt_readdata readdata output 32
    add_interface_port phy_mgmt phy_mgmt_write write input 1
    add_interface_port phy_mgmt phy_mgmt_writedata writedata input 32
    add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest output 1
    set_interface_property phy_mgmt associatedClock phy_mgmt_clk
    set_interface_property phy_mgmt associatedReset phy_mgmt_clk_reset
    #
    #
    add_interface xcvr_pll_ref_clk clock sink
    add_interface_port xcvr_pll_ref_clk xcvr_pll_ref_clk clk input 1
    #common_existing_interface reconfig_busy clock start input 1 
    add_interface reconfig_busy clock sink
    add_interface_port reconfig_busy reconfig_busy clk input 1

    if {$dir == "Source"} { 
	set port_dir_1 "input"
	set port_dir_2 "output"
    } elseif {$dir == "Sink"} {
	set port_dir_1 "output"
	set port_dir_2 "input"
    } elseif {$dir == "Duplex"} {
        add_duplex_ports
	return
    }


    
    common_add_interface data conduit $port_dir_1 [expr $num_lanes*64] true   
    common_add_interface sync conduit $port_dir_1 4 true   
    common_add_interface valid conduit $port_dir_1 1 true   
    common_add_interface start_of_burst conduit $port_dir_1 1 true
    common_add_interface end_of_burst conduit $port_dir_1 1 true
    common_add_interface link_up conduit output 1 true
  
    # clocking mode specific ports
    if { $cmode == "true" }  {
      if { $dir == "Source" } {
        #common_existing_interface user_clock_reset reset start input 1 
        #common_existing_interface user_clock clock start input 1 
        add_interface user_clock clock sink
        add_interface_port user_clock user_clock clk Input 1
        add_interface user_clock_reset reset sink
        add_interface_port user_clock_reset user_clock_reset reset Input 1
        set_interface_property user_clock_reset associatedClock user_clock
      } elseif { $dir == "Sink" } {
       # common_existing_interface interface_clock_reset reset end output 1 
       # common_existing_interface interface_clock clock end output 1 
        add_interface interface_clock clock source
        add_interface_port interface_clock interface_clock clk output 1
        add_interface interface_clock_reset reset source
        add_interface_port interface_clock_reset interface_clock_reset reset Output 1
        set_interface_property interface_clock_reset associatedClock interface_clock
      } elseif { $dir == "Duplex" } {
        #add_interface user_clock_tx clock sink
        #add_interface_port user_clock user_clock clk Input 1
        #add_interface user_clock_reset_tx reset sink
        #add_interface_port user_clock_reset_tx user_clock_reset_tx reset Input 1
        #set_interface_property user_clock_reset_tx associatedClock user_clock_tx
        #add_interface interface_clock_rx clock source
        #add_interface_port interface_clock_rx interface_clock_rx clk output 1
        #add_interface interface_clock_reset_rx reset source
        #add_interface_port interface_clock_reset_rx interface_clock_reset_rx reset Output 1
        #set_interface_property interface_clock_reset_rx associatedClock interface_clock_rx
      }
    } else {
      #if { $dir == "Duplex" } {
      #  add_interface user_clock_tx clock source
      #  add_interface_port user_clock_tx user_clock_tx clk output 1
      #  add_interface user_clock_reset_tx reset source
      #  add_interface_port user_clock_reset_tx user_clock_reset_tx reset Output 1
      #  set_interface_property user_clock_reset_tx associatedClock user_clock_tx

      #  add_interface user_clock_rx clock source
      #  add_interface_port user_clock_rx user_clock_rx clk output 1
      #  add_interface user_clock_reset_rx reset source
      #  add_interface_port user_clock_reset_rx user_clock_reset_rx reset Output 1
      #  set_interface_property user_clock_reset_rx associatedClock user_clock_rx

      #} else {
        #common_existing_interface user_clock_reset reset end output 1 
        #common_existing_interface user_clock clock end output 1
        add_interface user_clock clock source
        add_interface_port user_clock user_clock clk output 1
        add_interface user_clock_reset reset source
        add_interface_port user_clock_reset user_clock_reset reset output 1
        set_interface_property user_clock_reset associatedClock user_clock
      #}
    }



    #Adding direction specific ports
    if {$dir == "Source"} {    
      if { $cmode == "true" }  {
        common_add_interface error conduit output 4 true
      } else {
        common_add_interface error conduit output 3 true
      }
      common_add_interface crc_error_inject conduit input 1 true
      common_add_interface tx_serial_data conduit output lanes true
      common_add_interface reconfig_to_xcvr conduit input [expr $num_lanes*140] true
      common_add_interface reconfig_from_xcvr conduit output [expr $num_lanes*92] true
      set_fileset_property synth TOP_LEVEL seriallite_iii_streaming_source
      set_fileset_property sim_vlog   TOP_LEVEL seriallite_iii_streaming_source
      set_fileset_property sim_vhd   TOP_LEVEL seriallite_iii_streaming_source

    } elseif { $dir == "Sink"} {

      common_add_interface error conduit output [expr $num_lanes + 5] true
      common_add_interface rx_serial_data conduit input lanes true
      common_add_interface reconfig_to_xcvr conduit input [expr $num_lanes*70] true
      common_add_interface reconfig_from_xcvr conduit output [expr $num_lanes*46] true
      set_fileset_property synth TOP_LEVEL seriallite_iii_streaming_sink
      set_fileset_property sim_vlog   TOP_LEVEL seriallite_iii_streaming_sink
      set_fileset_property sim_vhd   TOP_LEVEL seriallite_iii_streaming_sink

    }
}


proc add_duplex_ports { } {
   
    set num_lanes [get_parameter_value lanes]
    set cmode [get_parameter_value gui_clocking_mode]
       
    if { $cmode == "true" }  {   
        add_interface user_clock_tx clock sink
        add_interface_port user_clock_tx user_clock_tx clk Input 1
        add_interface user_clock_reset_tx reset sink
        add_interface_port user_clock_reset_tx user_clock_reset_tx reset Input 1
        set_interface_property user_clock_reset_tx associatedClock user_clock_tx
        add_interface interface_clock_rx clock source
        add_interface_port interface_clock_rx interface_clock_rx clk output 1
        add_interface interface_clock_reset_rx reset source
        add_interface_port interface_clock_reset_rx interface_clock_reset_rx reset Output 1
        set_interface_property interface_clock_reset_rx associatedClock interface_clock_rx
        
	common_add_interface error_tx conduit output 4 true
    } else {
        add_interface user_clock_tx clock source
        add_interface_port user_clock_tx user_clock_tx clk output 1
        add_interface user_clock_reset_tx reset source
        add_interface_port user_clock_reset_tx user_clock_reset_tx reset Output 1
        set_interface_property user_clock_reset_tx associatedClock user_clock_tx

        add_interface user_clock_rx clock source
        add_interface_port user_clock_rx user_clock_rx clk output 1
        add_interface user_clock_reset_rx reset source
        add_interface_port user_clock_reset_rx user_clock_reset_rx reset Output 1
        set_interface_property user_clock_reset_rx associatedClock user_clock_rx
        
	common_add_interface error_tx conduit output 3 true
    }
   
    common_add_interface crc_error_inject conduit input 1 true
    common_add_interface data_tx conduit input [expr $num_lanes*64] true   
    common_add_interface sync_tx conduit input 4 true   
    common_add_interface valid_tx conduit input 1 true   
    common_add_interface start_of_burst_tx conduit input 1 true
    common_add_interface end_of_burst_tx conduit input 1 true
    common_add_interface link_up_tx conduit output 1 true

    common_add_interface data_rx conduit output [expr $num_lanes*64] true   
    common_add_interface sync_rx conduit output 4 true   
    common_add_interface valid_rx conduit output 1 true   
    common_add_interface start_of_burst_rx conduit output 1 true
    common_add_interface end_of_burst_rx conduit output 1 true
    common_add_interface link_up_rx conduit output 1 true
    common_add_interface error_rx conduit output [expr $num_lanes + 5] true
    common_add_interface tx_serial_data conduit output lanes true
    common_add_interface rx_serial_data conduit input lanes true
    common_add_interface reconfig_to_xcvr conduit input [expr $num_lanes*140] true
    common_add_interface reconfig_from_xcvr conduit output [expr $num_lanes*92] true

    set_fileset_property synth TOP_LEVEL seriallite_iii_streaming
    set_fileset_property sim_vlog   TOP_LEVEL seriallite_iii_streaming
    set_fileset_property sim_vhd   TOP_LEVEL seriallite_iii_streaming


}


proc common_existing_interface { port_name type port_dir signal width } {
      add_interface $port_name $type $port_dir
      set_interface_assignment $port_name ui.blockdiagram.direction $signal
      add_interface_port $port_name $port_name $type $signal $width
      if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
      }
}
proc common_add_interface { port_name type port_dir width tags } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name $type $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
	#set_interface_property $port_name ENABLED $used
	common_add_interface_port $port_name $port_name export $port_dir $width $tags
	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
}

proc common_add_file {file_ {path ""} {file_name ""} } {
	set file_string [split $file_ /]
	if {$file_name == ""} {
          set file_name [lindex $file_string end]
	}
	if {[regexp {.sv} $file_name]} { 
	  add_fileset_file "$path$file_name" SYSTEM_VERILOG PATH ${file_}
          send_message INFO "Adding system verilog file $file_ as $file_name"
	} elseif {[regexp {.v} $file_name]} { 
	  add_fileset_file "$path$file_name" VERILOG PATH ${file_}
          send_message INFO "Adding verilog file $file_ as $file_name"
        } elseif {[regexp {.sdc} $file_name]} {
	  add_fileset_file $path$file_name SDC PATH ${file_}
          send_message INFO "Adding sdc file $file_ as $file_name"
        } else {
          add_fileset_file "$path$file_name" OTHER PATH ${file_} 
          send_message INFO "Adding file $file_ as $$path$file_name"
	}
}

proc synth_proc {outputName} {
   send_message INFO "Adding Synthesis files"
   set dest_path       "./"
   set cmode [get_parameter_value gui_clocking_mode]
   set dir [get_parameter_value direction]
   set df  [get_parameter_value system_family]

    #add the common files
    add_fileset_file "dp_hs_req.v" VERILOG PATH  "common/dp_hs_req.v"   
    add_fileset_file "dp_hs_resp.v" VERILOG PATH "common/dp_hs_resp.v"
    add_fileset_file "dp_sync.v" VERILOG PATH "common/dp_sync.v" 

    add_fileset_file "alt_xcvr_csr_common_h.sv" SYSTEM_VERILOG PATH  "common/header/alt_xcvr_csr_common_h.sv"   
    send_message INFO "Adding system verilog file common/header/alt_xcvr_csr_common_h.sv  as alt_xcvr_csr_common_h.sv"

    add_fileset_file "alt_xcvr_csr_pcs8g_h.sv" SYSTEM_VERILOG PATH "common/header/alt_xcvr_csr_pcs8g_h.sv"
    add_fileset_file "sv_xcvr_h.sv" SYSTEM_VERILOG PATH "common/header/sv_xcvr_h.sv"
    add_fileset_file "altera_xcvr_functions.sv" SYSTEM_VERILOG PATH "common/header/altera_xcvr_functions.sv"
    
    if {$cmode == "true"} {
      add_fileset_file "clocking.v" VERILOG PATH  "common/clocking_ac.v"
      add_fileset_file "source_absorber.v" VERILOG PATH  "common/source_absorber.v"
    } else {
      add_fileset_file "clocking.v" VERILOG PATH  "common/clocking_nc.v"
    }

    if {$dir == "Duplex"} {
        add_fileset_file "seriallite_iii_streaming.v" VERILOG PATH "common/seriallite_iii_streaming_duplex.v" 
	add_fileset_file "interlaken_phy_ip_duplex.v" VERILOG PATH  "common/interlaken_phy_ip_duplex.v"
	if {$df == "Stratix V"} {
          add_fileset_file "clkctrl.v" VERILOG PATH  "common/clkctrl_sv.v"
	} elseif {$df == "Arria V GZ"} {
          add_fileset_file "clkctrl.v" VERILOG PATH  "common/clkctrl_av.v"
	}
    } else {

      if {$cmode == "true"} {
        if {$dir == "Sink"} {
          add_fileset_file "seriallite_iii_streaming_sink.v" VERILOG PATH "common/seriallite_iii_streaming_sink_ac.v"
        } else {
          add_fileset_file "seriallite_iii_streaming_source.v" VERILOG PATH "common/seriallite_iii_streaming_source_ac.v" 
        }
      } else {
        if {$dir == "Sink"} {
          add_fileset_file "seriallite_iii_streaming_sink.v" VERILOG PATH "common/seriallite_iii_streaming_sink_nc.v"
        } else {
          add_fileset_file "seriallite_iii_streaming_source.v" VERILOG PATH "common/seriallite_iii_streaming_source_nc.v"       
        }
      }
    }
    
#    set ecc [get_parameter_value gui_ecc_enable]
#    if {$ecc == "true"} {
        add_fileset_file "aclr_filter.v"    VERILOG PATH "common/aclr_filter.v"
        add_fileset_file "dcfifo_s5m20k.v"  VERILOG PATH "common/dcfifo_s5m20k.v"
        add_fileset_file "delay_regs.v"     VERILOG PATH "common/delay_regs.v"
        add_fileset_file "eq_5_ena.v"       VERILOG PATH "common/eq_5_ena.v"
        add_fileset_file "gray_cntr_5_sl.v" VERILOG PATH "common/gray_cntr_5_sl.v"
        add_fileset_file "gray_to_bin_5.v"  VERILOG PATH "common/gray_to_bin_5.v"
        add_fileset_file "neq_5_ena.v"      VERILOG PATH "common/neq_5_ena.v"
        add_fileset_file "s5m20k_ecc_1r1w.v" VERILOG PATH "common/s5m20k_ecc_1r1w.v"
        add_fileset_file "sync_regs_aclr_m2.v" VERILOG PATH "common/sync_regs_aclr_m2.v"
        add_fileset_file "wys_lut.v"        VERILOG PATH "common/wys_lut.v"
#    }
    
    set folder_lst   {"common/phyip"}
    foreach subDir ${folder_lst} {
    send_message INFO "Processing folder: $subDir"
      set file_lst [glob -nocomplain -- -path $subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {       
        set     is_dir  [file isdirectory $file]
        set     is_tcl  [regexp {tcl} $file]
            if {$is_dir == 1} {
                send_message INFO "Ignoring $file for synth"
                #lappend SubDirList $file
            } else {
	        common_add_file $file
            }
        }
    }


   # add direction specific files
   if {$dir == "Sink" } {
     set folder_lst   {"sink"}
   } elseif {$dir == "Source" }  {
     set folder_lst   {"source"}
   } else {
     set folder_lst   {"sink" "source"}
   }
     
     
   foreach subDir ${folder_lst} {
      send_message INFO "Processing folder: $subDir"
      set file_lst [glob -nocomplain -- -path $subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {
       set file_string [split $file /]
       set file_name [lindex $file_string end]
       if {[regexp {.ocp} $file_name]} {
         add_fileset_file $file_name OTHER PATH ${file}
         send_message INFO "Adding file $file as $file_name"
       } elseif {[regexp {.sdc} $file_name]} {
         add_fileset_file $file_name SDC PATH ${file}
         send_message INFO "Adding sdc file $file as $file_name"
       } else {
         common_add_file $file
       }
     }
   }

}



proc sim_proc {outputName} {
    send_message INFO "Adding Simulation files"
    set cmode [get_parameter_value gui_clocking_mode]
    set dir [get_parameter_value direction]
    set df  [get_parameter_value system_family]

    #add the common files
    add_fileset_file "dp_hs_req.v" VERILOG PATH  "common/dp_hs_req.v"   
    add_fileset_file "dp_hs_resp.v" VERILOG PATH "common/dp_hs_resp.v"
    add_fileset_file "dp_sync.v" VERILOG PATH "common/dp_sync.v" 
    add_fileset_file "control_word_decoder.v" VERILOG PATH "common/sim/control_word_decoder.v"
    add_fileset_file "altera_xcvr_interlaken/alt_xcvr_csr_common_h.sv" SYSTEM_VERILOG PATH  "common/header/alt_xcvr_csr_common_h.sv"   
    send_message INFO "Adding system verilog file common/header/alt_xcvr_csr_common_h.sv  as alt_xcvr_csr_common_h.sv"

    add_fileset_file "altera_xcvr_interlaken/alt_xcvr_csr_pcs8g_h.sv" SYSTEM_VERILOG PATH "common/header/alt_xcvr_csr_pcs8g_h.sv"
    add_fileset_file "altera_xcvr_interlaken/sv_xcvr_h.sv" SYSTEM_VERILOG PATH "common/header/sv_xcvr_h.sv"
    add_fileset_file "altera_xcvr_interlaken/altera_xcvr_functions.sv" SYSTEM_VERILOG PATH "common/header/altera_xcvr_functions.sv"

    if {$cmode == "true"} {
      add_fileset_file "clocking.v" VERILOG PATH  "common/clocking_ac.v"
      add_fileset_file "source_absorber.v" VERILOG PATH  "common/source_absorber.v"
    } else {
      add_fileset_file "clocking.v" VERILOG PATH  "common/clocking_nc.v"
    }
    if {$dir == "Duplex"} {
        add_fileset_file "seriallite_iii_streaming.v" VERILOG PATH "common/seriallite_iii_streaming_duplex.v" 
	add_fileset_file "interlaken_phy_ip_duplex.v" VERILOG PATH  "common/interlaken_phy_ip_duplex.v"
	if {$df == "Stratix V"} {
          add_fileset_file "clkctrl.v" VERILOG PATH  "common/clkctrl_sv.v"
	} elseif {$df == "Arria V GZ"} {
          add_fileset_file "clkctrl.v" VERILOG PATH  "common/clkctrl_av.v"
	}
    } else {
      if { $cmode == "true" }  {
        if {$dir == "Sink"} {
          add_fileset_file "seriallite_iii_streaming_sink.v" VERILOG PATH "common/seriallite_iii_streaming_sink_ac.v"
        } else {
          add_fileset_file "seriallite_iii_streaming_source.v" VERILOG PATH "common/seriallite_iii_streaming_source_ac.v" 
        }
      } else {
        if {$dir == "Sink"} {
          add_fileset_file "seriallite_iii_streaming_sink.v" VERILOG PATH "common/seriallite_iii_streaming_sink_nc.v"
        } else {
          add_fileset_file "seriallite_iii_streaming_source.v" VERILOG PATH "common/seriallite_iii_streaming_source_nc.v"       
        }
      }
    }
    
        add_fileset_file "aclr_filter.v"    VERILOG PATH "common/aclr_filter.v"
        add_fileset_file "dcfifo_s5m20k.v"  VERILOG PATH "common/dcfifo_s5m20k.v"
        add_fileset_file "delay_regs.v"     VERILOG PATH "common/delay_regs.v"
        add_fileset_file "eq_5_ena.v"       VERILOG PATH "common/eq_5_ena.v"
        add_fileset_file "gray_cntr_5_sl.v" VERILOG PATH "common/gray_cntr_5_sl.v"
        add_fileset_file "gray_to_bin_5.v"  VERILOG PATH "common/gray_to_bin_5.v"
        add_fileset_file "neq_5_ena.v"      VERILOG PATH "common/neq_5_ena.v"
        add_fileset_file "s5m20k_ecc_1r1w.v" VERILOG PATH "common/s5m20k_ecc_1r1w.v"
        add_fileset_file "sync_regs_aclr_m2.v" VERILOG PATH "common/sync_regs_aclr_m2.v"
        add_fileset_file "wys_lut.v"        VERILOG PATH "common/wys_lut.v"

    set common_path "common/sim/"
    set folder_lst   {"altera_xcvr_interlaken" "alt_xcvr_reconfig/header" "alt_xcvr_reconfig" }
    foreach subDir ${folder_lst} {
    send_message INFO "Processing folder: $common_path$subDir"
      set file_lst [glob -nocomplain -- -path $common_path$subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {       
        set     is_dir  [file isdirectory $file]
        set     is_tcl  [regexp {tcl} $file]
            if {$is_dir == 1} {
                send_message INFO "Ignoring directory-$file for simulation"
            } else {
	        send_message INFO "Adding file $file for simulation"
	        common_add_file $file "$subDir/"
            }
        }
    }

   # Adding Direction & Simulator Specific Encrypted Files
   set folder_lst   {"aldec" "synopsys" "mentor" "cadence"}
   if {$dir == "Sink" } {
     set direction "sink"
   } elseif {$dir == "Source" } {
     set direction "source"
   }

   foreach subDir ${folder_lst} {
     if {$dir == "Duplex"} {
       set file_lst [glob -nocomplain -- -path $subDir/source/*]
       append file_lst " " 
       append file_lst [glob -nocomplain -- -path $subDir/sink/*]
     } else {
       set file_lst [glob -nocomplain -- -path $subDir/$direction/*]
     }
     send_message INFO "Adding Files - $file_lst"

     foreach file ${file_lst} {
       common_add_file $file "$subDir/"
     }      
   }

}

proc example_proc {outputName} {
    send_message INFO "Adding example design"
    set cmode [get_parameter_value gui_clocking_mode]
    set dir [get_parameter_value direction]
    set df  [get_parameter_value system_family]

    if { $cmode == "true" }  {
      set path "ac"
      } else {
      set path "nc"
    }

   
   add_fileset_file "demo/src/dp_hs_req.v" VERILOG PATH  "common/dp_hs_req.v"   
   add_fileset_file "demo/src/dp_hs_resp.v" VERILOG PATH "common/dp_hs_resp.v"
   add_fileset_file "demo/src/dp_sync.v" VERILOG PATH "common/dp_sync.v" 


    #Adding Source and Sink SDC files to src/ directory of the Example Design
    add_fileset_file "demo/src/seriallite_iii_streaming_source.sdc" SDC PATH "source/seriallite_iii_streaming_source.sdc" 
    add_fileset_file "demo/src/seriallite_iii_streaming_sink.sdc" SDC PATH "sink/seriallite_iii_streaming_sink.sdc" 

    #add the demo files
    if {$cmode == "true"} {
      add_fileset_file "demo/src/clocking.v" VERILOG PATH  "common/clocking_ac.v"
      add_fileset_file "demo/src/source_absorber.v" VERILOG PATH  "common/source_absorber.v"
    } else {
      add_fileset_file "demo/src/clocking.v" VERILOG PATH  "common/clocking_nc.v"
    }


    if {$dir == "Duplex"} {
        add_fileset_file "demo/src/seriallite_iii_streaming.v" VERILOG PATH "common/seriallite_iii_streaming_duplex.v" 
	add_fileset_file "demo/src/interlaken_phy_ip_duplex.v" VERILOG PATH  "common/interlaken_phy_ip_duplex.v"
        if {$df == "Stratix V"} {
          add_fileset_file "demo/src/clkctrl.v" VERILOG PATH  "common/clkctrl_sv.v"
	} elseif {$df == "Arria V GZ"} {
          add_fileset_file "demo/src/clkctrl.v" VERILOG PATH  "common/clkctrl_av.v"
	}
	# Add sdc, qsf and qpf files too
	common_add_file "../example/example_design/demo/duplex/seriallite_iii_streaming_demo.v" "demo/src/" "seriallite_iii_streaming_demo.v"
	common_add_file "../example/example_design/demo/duplex/seriallite_iii_streaming_demo.sdc" "demo/" "seriallite_iii_streaming_demo.sdc"
	common_add_file "../example/example_design/demo/duplex/seriallite_iii_streaming_demo.qpf" "demo/" "seriallite_iii_streaming_demo.qpf"
	common_add_file "../example/example_design/demo/duplex/seriallite_iii_streaming_demo.qsf" "demo/" "seriallite_iii_streaming_demo.qsf"
        #set folder_lst   {"../example/common" }
    } else {
      add_fileset_file "demo/src/seriallite_iii_streaming_sink.v" VERILOG PATH "common/seriallite_iii_streaming_sink_$path.v"
      add_fileset_file "demo/src/seriallite_iii_streaming_source.v" VERILOG PATH "common/seriallite_iii_streaming_source_$path.v"
      add_fileset_file "demo/seriallite_iii_streaming_demo.sdc" SDC PATH "../example/example_design/demo/simplex/seriallite_iii_streaming_demo.sdc" 
      add_fileset_file "demo/seriallite_iii_streaming_demo.qpf" OTHER PATH "../example/example_design/demo/simplex/seriallite_iii_streaming_demo.qpf"   
      add_fileset_file "demo/seriallite_iii_streaming_demo.qsf" OTHER PATH "../example/example_design/demo/simplex/seriallite_iii_streaming_demo_$path.qsf"  
      add_fileset_file "demo/src/seriallite_iii_streaming_demo.v" VERILOG PATH "../example/example_design/demo/simplex/seriallite_iii_streaming_demo_$path.v" 
    }

        add_fileset_file "demo/src/aclr_filter.v"    VERILOG PATH "common/aclr_filter.v"
        add_fileset_file "demo/src/dcfifo_s5m20k.v"  VERILOG PATH "common/dcfifo_s5m20k.v"
        add_fileset_file "demo/src/delay_regs.v"     VERILOG PATH "common/delay_regs.v"
        add_fileset_file "demo/src/eq_5_ena.v"       VERILOG PATH "common/eq_5_ena.v"
        add_fileset_file "demo/src/gray_cntr_5_sl.v" VERILOG PATH "common/gray_cntr_5_sl.v"
        add_fileset_file "demo/src/gray_to_bin_5.v"  VERILOG PATH "common/gray_to_bin_5.v"
        add_fileset_file "demo/src/neq_5_ena.v"      VERILOG PATH "common/neq_5_ena.v"
        add_fileset_file "demo/src/s5m20k_ecc_1r1w.v" VERILOG PATH "common/s5m20k_ecc_1r1w.v"
        add_fileset_file "demo/src/sync_regs_aclr_m2.v" VERILOG PATH "common/sync_regs_aclr_m2.v"
        add_fileset_file "demo/src/wys_lut.v"        VERILOG PATH "common/wys_lut.v"



    set folder_lst   {"common/header" "common/phyip" "source" "sink" "../example/common" }
    #add the common synthesis files
    foreach subDir ${folder_lst} {
      set file_lst [glob -nocomplain -- -path $subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {       
        set     is_dir  [file isdirectory $file]
        set     is_sdc  [regexp {sdc} $file]
          if {$is_dir == 1} {
              send_message INFO "Ignoring $file for example design"
              #lappend SubDirList $file
          } elseif {$is_sdc == 1} {
              send_message INFO "Ignoring $file for example design"
              #send_message INFO "Ignoring $file for synth"
          } else {
              set file_string [split $file /]
              set file_name [lindex $file_string end]
              common_add_file $file "demo/src/"
          }
      }
    }

    set folder_lst   {"demo_control" "demo_control/software" "demo_control/software/src"}
    foreach subDir ${folder_lst} {
      set file_lst [glob -nocomplain -- -path ../example/example_design/$subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {       
        set     is_dir  [file isdirectory $file]
            if {$is_dir == 1} {
               send_message INFO "Ignoring $file for example design"
            } else {
                set file_string [split $file /]
                set file_name [lindex $file_string end]
                common_add_file $file "$subDir/"}
        }
    }

   #add the TB files 
    set folder_lst   {"src"}

   foreach subDir ${folder_lst} {
      set file_lst [glob -nocomplain -- -path ../example/example_tb/$subDir/*]
      send_message INFO $file_lst
      foreach file ${file_lst} {       
          set file_string [split $file /]
          set file_name [lindex $file_string end]
          common_add_file $file "example_testbench/"
      }
   }    
   
   if {$dir == "Duplex"} {
     #mentor
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_duplex_vsim.do" "example_testbench/vsim/" "seriallite_src_lst_vsim.do" 
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_duplex.do" "example_testbench/vsim/" "interlaken_phy_ip_lib.do" 
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_duplex.do" "example_testbench/vsim/" "reconfig_ctrlr_lib.do"

     #aldec
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_duplex_rivr.txt" "example_testbench/aldec/" "seriallite_src_lst_rivr.txt"
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst_duplex.txt" "example_testbench/aldec/" "interlaken_phy_ip_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst_duplex.txt" "example_testbench/aldec/" "reconfig_ctrlr_lib_src_lst.txt" 
     common_add_file "../example/example_tb/scripts/$path/run_aldec_duplex.sh" "example_testbench/aldec/" "run_aldec.sh" 

     #vcs
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_duplex_vcs.txt" "example_testbench/vcs/" "seriallite_src_lst_vcs.txt"
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst_duplex.txt" "example_testbench/vcs/" "interlaken_phy_ip_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst_duplex.txt" "example_testbench/vcs/" "reconfig_ctrlr_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/$path/run_vcs_duplex.sh" "example_testbench/vcs/" "run_vcs.sh"
  
     #ncsim
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_duplex_ncsim.txt" "example_testbench/ncsim/" "seriallite_src_lst_ncsim.txt"
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst_duplex.txt" "example_testbench/ncsim/" "interlaken_phy_ip_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst_duplex.txt" "example_testbench/ncsim/" "reconfig_ctrlr_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/$path/run_ncsim_duplex.sh" "example_testbench/ncsim/" "run_ncsim.sh"
 
   } else {
   
     #mentor
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_vsim.do" "example_testbench/vsim/" 
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib.do" "example_testbench/vsim/" 
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib.do" "example_testbench/vsim/" 
      
     #aldec
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_rivr.txt" "example_testbench/aldec/" 
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst.txt" "example_testbench/aldec/" 
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst.txt" "example_testbench/aldec/" 
     common_add_file "../example/example_tb/scripts/$path/run_aldec.sh" "example_testbench/aldec/" 

     #vcs
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_vcs.txt" "example_testbench/vcs/" 
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst.txt" "example_testbench/vcs/" 
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst.txt" "example_testbench/vcs/" 
     common_add_file "../example/example_tb/scripts/$path/run_vcs.sh" "example_testbench/vcs/" 
  
     #ncsim
     common_add_file "../example/example_tb/scripts/$path/seriallite_src_lst_ncsim.txt" "example_testbench/ncsim/" "seriallite_src_lst_ncsim.txt"
     common_add_file "../example/example_tb/scripts/interlaken_phy_ip_lib_src_lst.txt" "example_testbench/ncsim/" "interlaken_phy_ip_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/reconfig_ctrlr_lib_src_lst.txt" "example_testbench/ncsim/" "reconfig_ctrlr_lib_src_lst.txt"
     common_add_file "../example/example_tb/scripts/$path/run_ncsim.sh" "example_testbench/ncsim/" "run_ncsim.sh"
   }
   

   common_add_file "../example/example_tb/scripts/$path/run_vsim.do" "example_testbench/vsim/" 
   common_add_file "../example/example_tb/scripts/vrun.do" "example_testbench/aldec/" 


}


