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


#|
#| altera_interlaken
#|
#+-----------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module interlaken_xcvr_8lane
# | 
set_module_property NAME altera_interlaken
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property DISPLAY_NAME "Interlaken"
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property GROUP "Interface Protocols/Interlaken"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Altera Interlaken"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_interlaken.pdf"

set_module_property COMPOSE_CALLBACK compose
set_module_property VALIDATION_CALLBACK validate

# | 
# +-----------------------------------

#+-----------------------------------
#| display tabs
#| 
add_display_item "" "General" GROUP
add_display_item "" "PCS" GROUP
add_display_item "" "Block Diagram" GROUP


#+-----------------------------------
#| parameters
#|

add_parameter DEVICE_FAMILY STRING
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device family"
set_parameter_property DEVICE_FAMILY SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"Stratix IV"}
set_parameter_property DEVICE_FAMILY HDL_PARAMETER false
set_parameter_property DEVICE_FAMILY DESCRIPTION "Possible value is Stratix IV"
set_parameter_property DEVICE_FAMILY VISIBLE false
add_display_item "General" DEVICE_FAMILY parameter

add_parameter OPERATIONAL_MODE INTEGER 0 Duplex
set_parameter_property OPERATIONAL_MODE DISPLAY_NAME "Operational mode"
set_parameter_property OPERATIONAL_MODE ALLOWED_RANGES {0:Duplex}
set_parameter_property OPERATIONAL_MODE DISPLAY_HINT "string"
set_parameter_property OPERATIONAL_MODE DESCRIPTION "Specifies the mode of operation"
set_parameter_property OPERATIONAL_MODE ENABLED false
set_parameter_property OPERATIONAL_MODE AFFECTS_ELABORATION true
set_parameter_property OPERATIONAL_MODE HDL_PARAMETER false
add_display_item "General" OPERATIONAL_MODE parameter

add_parameter LANES INTEGER 8
set_parameter_property LANES DEFAULT_VALUE 8
set_parameter_property LANES DISPLAY_NAME "Number of lanes"
set_parameter_property LANES ALLOWED_RANGES {4 8 10 12 20}
set_parameter_property LANES DISPLAY_HINT ""
set_parameter_property LANES DESCRIPTION "Specifies the number of lanes"
set_parameter_property LANES AFFECTS_ELABORATION true
set_parameter_property LANES HDL_PARAMETER false
add_display_item "General" LANES parameter

add_parameter LANE_RATE FLOAT 6250
set_parameter_property LANE_RATE DEFAULT_VALUE 6250
set_parameter_property LANE_RATE DISPLAY_NAME "Lane rate"
set_parameter_property LANE_RATE ALLOWED_RANGES {3125 6250 6375 10312.5}
set_parameter_property LANE_RATE UNITS MegabitsPerSecond
set_parameter_property LANE_RATE HDL_PARAMETER true
set_parameter_property LANE_RATE DESCRIPTION "Specifies data rate on each lane"
add_display_item "General" LANE_RATE parameter

add_parameter META_FRAME_LEN INTEGER 2048
set_parameter_property META_FRAME_LEN DEFAULT_VALUE 2048
set_parameter_property META_FRAME_LEN DISPLAY_NAME "Meta frame length in words"
set_parameter_property META_FRAME_LEN ALLOWED_RANGES 10:8192
set_parameter_property META_FRAME_LEN DISPLAY_HINT ""
set_parameter_property META_FRAME_LEN UNITS None
set_parameter_property META_FRAME_LEN HDL_PARAMETER true
set_parameter_property META_FRAME_LEN DESCRIPTION "Specifies the meta frame length; possible lengths are 10-8192 words"
add_display_item "General" META_FRAME_LEN parameter

add_parameter GUI_ENABLE_CALENDAR INTEGER 0
set_parameter_property GUI_ENABLE_CALENDAR DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_CALENDAR DISPLAY_NAME "Expose calendar ports"
set_parameter_property GUI_ENABLE_CALENDAR TYPE INTEGER
set_parameter_property GUI_ENABLE_CALENDAR DESCRIPTION "Expose tx_calendar and rx_calendar ports; when disabled, all channels are XON"
set_parameter_property GUI_ENABLE_CALENDAR UNITS None
set_parameter_property GUI_ENABLE_CALENDAR DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_CALENDAR AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_CALENDAR HDL_PARAMETER false
add_display_item "In-Band Flow Control" GUI_ENABLE_CALENDAR parameter

add_parameter CALENDAR_PAGES INTEGER 1
set_parameter_property CALENDAR_PAGES DEFAULT_VALUE 1
set_parameter_property CALENDAR_PAGES DISPLAY_NAME "Width of calendar ports, in 16-bit pages"
set_parameter_property CALENDAR_PAGES ALLOWED_RANGES {1 8 16}
set_parameter_property CALENDAR_PAGES DISPLAY_HINT ""
set_parameter_property CALENDAR_PAGES DESCRIPTION "Specifies the number of calendar pages; 16 bits per page"
set_parameter_property CALENDAR_PAGES HDL_PARAMETER true
set_parameter_property CALENDAR_PAGES AFFECTS_ELABORATION true
add_display_item "In-Band Flow Control" CALENDAR_PAGES parameter

add_parameter GUI_ENABLE_DYNAMIC_BURST INTEGER 0
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DISPLAY_NAME "Enable dynamic burst parameters"
set_parameter_property GUI_ENABLE_DYNAMIC_BURST TYPE INTEGER
set_parameter_property GUI_ENABLE_DYNAMIC_BURST UNITS None
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_DYNAMIC_BURST DESCRIPTION "Enable dynamic configuration of BurstMax and BurstShort"
set_parameter_property GUI_ENABLE_DYNAMIC_BURST AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_DYNAMIC_BURST HDL_PARAMETER false
add_display_item "Burst Parameters" GUI_ENABLE_DYNAMIC_BURST parameter

add_parameter GUI_BURST_MAX INTEGER 128 
set_parameter_property GUI_BURST_MAX DEFAULT_VALUE 128 
set_parameter_property GUI_BURST_MAX DISPLAY_NAME "BURST MAX length in bytes"
set_parameter_property GUI_BURST_MAX ALLOWED_RANGES {128 256}
set_parameter_property GUI_BURST_MAX DISPLAY_HINT ""
set_parameter_property GUI_BURST_MAX DESCRIPTION "Specifies the value of BurstMax (in bytes)"
set_parameter_property GUI_BURST_MAX UNITS None
set_parameter_property GUI_BURST_MAX HDL_PARAMETER false 
add_display_item "Burst Parameters" GUI_BURST_MAX parameter

add_parameter BURST_MAX INTEGER 2
set_parameter_property BURST_MAX DEFAULT_VALUE 2
set_parameter_property BURST_MAX DISPLAY_NAME "BURST MAX length in bytes"
set_parameter_property BURST_MAX ALLOWED_RANGES {2 4}
set_parameter_property BURST_MAX DISPLAY_HINT ""
set_parameter_property BURST_MAX UNITS None
set_parameter_property BURST_MAX HDL_PARAMETER false
set_parameter_property BURST_MAX VISIBLE false
set_parameter_property BURST_MAX DERIVED true
add_display_item "Burst Parameters" BURST_MAX parameter

add_parameter GUI_BURST_SHORT INTEGER 32
set_parameter_property GUI_BURST_SHORT DEFAULT_VALUE 32
set_parameter_property GUI_BURST_SHORT DISPLAY_NAME "BURST SHORT length in bytes"
set_parameter_property GUI_BURST_SHORT ALLOWED_RANGES {32 64}
set_parameter_property GUI_BURST_SHORT DISPLAY_HINT ""
set_parameter_property GUI_BURST_SHORT DESCRIPTION "Specifies the value of BurstShort (in bytes)"
set_parameter_property GUI_BURST_SHORT HDL_PARAMETER false
set_parameter_property GUI_BURST_SHORT AFFECTS_ELABORATION true
add_display_item "Burst Parameters" GUI_BURST_SHORT parameter

add_parameter NUM_CHANNELS INTEGER 2
set_parameter_property NUM_CHANNELS DEFAULT_VALUE 2
set_parameter_property NUM_CHANNELS ALLOWED_RANGES 2
set_parameter_property NUM_CHANNELS TYPE INTEGER
set_parameter_property NUM_CHANNELS UNITS None
set_parameter_property NUM_CHANNELS VISIBLE false
set_parameter_property NUM_CHANNELS AFFECTS_ELABORATION true
set_parameter_property NUM_CHANNELS HDL_PARAMETER false

add_parameter GUI_ENABLE_HSIO INTEGER 0
set_parameter_property GUI_ENABLE_HSIO DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_HSIO DISPLAY_NAME "Exclude transceiver"
set_parameter_property GUI_ENABLE_HSIO TYPE INTEGER
set_parameter_property GUI_ENABLE_HSIO DESCRIPTION "Excludes transceiver from being part of the design"
set_parameter_property GUI_ENABLE_HSIO UNITS None
set_parameter_property GUI_ENABLE_HSIO DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_HSIO AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_HSIO HDL_PARAMETER false
add_display_item "General" GUI_ENABLE_HSIO parameter

add_parameter GUI_ENABLE_OOB INTEGER 0
set_parameter_property GUI_ENABLE_OOB DEFAULT_VALUE 0
set_parameter_property GUI_ENABLE_OOB DISPLAY_NAME "Enable out-of-band flow control"
set_parameter_property GUI_ENABLE_OOB TYPE INTEGER
set_parameter_property GUI_ENABLE_OOB DESCRIPTION "Includes out-of-band flow control block in the design"
set_parameter_property GUI_ENABLE_OOB UNITS None
set_parameter_property GUI_ENABLE_OOB DISPLAY_HINT "Boolean"
set_parameter_property GUI_ENABLE_OOB AFFECTS_ELABORATION true
set_parameter_property GUI_ENABLE_OOB HDL_PARAMETER false
add_display_item "General" GUI_ENABLE_OOB parameter

add_parameter CAL_BITS INTEGER 16
set_parameter_property CAL_BITS DEFAULT_VALUE 16
set_parameter_property CAL_BITS DISPLAY_NAME "Number of calendar bits"
set_parameter_property CAL_BITS ALLOWED_RANGES 2:256
set_parameter_property CAL_BITS TYPE INTEGER
set_parameter_property CAL_BITS DESCRIPTION "The number of calendar bits for out-of-band flow control"
set_parameter_property CAL_BITS AFFECTS_ELABORATION true
set_parameter_property CAL_BITS HDL_PARAMETER true
add_display_item "General" CAL_BITS parameter

add_parameter SIM_FAST_RESET INTEGER 0
set_parameter_property SIM_FAST_RESET DEFAULT_VALUE 0
set_parameter_property SIM_FAST_RESET TYPE INTEGER
set_parameter_property SIM_FAST_RESET UNITS None
set_parameter_property SIM_FAST_RESET VISIBLE false
set_parameter_property SIM_FAST_RESET HDL_PARAMETER true


#+---------------------------------

#+-------------------------------
#| VALIDATE CALLBACK
#|


proc validate {} {

    set dev [get_parameter_value DEVICE_FAMILY]
}

# +-------------------------------
# |ELABORATE CALLBACK
# |



#+--------------------------------
#| COMPOSE CALLBACK
#|

proc compose {} {

 
    send_message info "Only Duplex mode is supported at this time"

    set dev_family [get_parameter_value DEVICE_FAMILY]
    set num_lanes [get_parameter_value LANES]
    set lane_rate [get_parameter_value LANE_RATE]
    set num_chan 2
   
    set agg_bwidth_tmp [expr $num_lanes * $lane_rate]




    if {$num_lanes == 8} {
	set_parameter_property LANE_RATE ALLOWED_RANGES {3125 6250 6375}
    } elseif {$num_lanes == 4} {
	set_parameter_property LANE_RATE ALLOWED_RANGES {3125 6250 6375}
    } elseif {$num_lanes == 10} {
	set_parameter_property LANE_RATE ALLOWED_RANGES {6250 6375}
    } elseif {$num_lanes == 12} {
	set_parameter_property LANE_RATE ALLOWED_RANGES {6250 6375 10312.5}
    } elseif {$num_lanes == 20} {
	set_parameter_property LANE_RATE ALLOWED_RANGES {6250 6375}	      
    } else {
	send_message error "Selected lane count and lane rate combination not supported yet"
    }
	
    if {$agg_bwidth_tmp < 40000} {
	set agg_bwidth "20g"
    } elseif {$agg_bwidth_tmp < 100000} {
	set agg_bwidth "40g"
    } else {
	set agg_bwidth "100g"
    }

    set op_mode [get_parameter_value OPERATIONAL_MODE]

    if {$lane_rate <= 3125} {
	set lrate "3g"
    } elseif {$lane_rate < 10312.5} {
	set lrate "6g"
    } else {
	set lrate "10g"
    }
    
    if {$lrate == "6g"} {
	if {($num_lanes == 4) || ($num_lanes == 8) || ($num_lanes == 12)} {
	    set hsio_inst alt_ntrlkn_hsio_bank_bpcs4
	    set num_hsio_inst [expr $num_lanes/4]
	    
	} elseif {($num_lanes == 10) || ($num_lanes == 20)} {
	    set hsio_inst alt_ntrlkn_hsio_bank_pmad5
	    set num_hsio_inst [expr $num_lanes/5]
	   
	} else {
	    send_message error "Lane counts other than 4,8,10,12 and 20 are not supported at 6G"
	}
    } elseif {$lrate == "3g"} {
	if {($num_lanes == 4) || ($num_lanes == 8)} {
	set hsio_inst alt_ntrlkn_hsio_bank_bpcs_3g
	set num_hsio_inst [expr $num_lanes/4]
	
	} else {
	    send_message error "Lane counts other than 4 and 8 are not supported at 3G"
	}	
    } elseif {$lrate == "10g"} {
	set hsio_inst alt_ntrlkn_hsio_bank_10g
	set num_hsio_inst [expr $num_lanes/4]

    } else {
	send_message error "Selected lane rate is not supported"

    }


    set_parameter_property CAL_BITS ENABLED [get_parameter_value GUI_ENABLE_OOB]

	set_parameter_property CALENDAR_PAGES ENABLED [get_parameter_value GUI_ENABLE_CALENDAR]
        set dynamic_bursts [get_parameter_value GUI_ENABLE_DYNAMIC_BURST]
	# 64-byte burst-short option only applicable to 100G variants (12L@10G and 20L@6G)
	if {($dynamic_bursts == 1) || !(($num_lanes == 20) || ($num_lanes == 12 && $lrate == "10g")) } {
		set_parameter_property GUI_BURST_SHORT ENABLED false
	} else {
		set_parameter_property GUI_BURST_SHORT ENABLED true
	}
   

    if {$dynamic_bursts == 1} {
         set_parameter_property GUI_BURST_MAX ENABLED false
    }  else {
         set_parameter_property GUI_BURST_MAX ENABLED true
    }

    #send_message info "top level dynamic_burst_max is $dynamic_burst_max"
    set num_gui_burst_max [get_parameter_value GUI_BURST_MAX]
    #send_message info "top level num_gui_burst_max is $num_gui_burst_max"

    if {$num_gui_burst_max == 128} {
                set_parameter_value BURST_MAX 2
        } elseif {$num_gui_burst_max == 256} {
                set_parameter_value BURST_MAX 4
        } else   {
                send_message error "Only 128, or 256 bytes of burst max length are supported"
        }
	
    if {$num_lanes == 4} {	
	set iwords 2
    } elseif {($num_lanes == 8) || ($num_lanes == 10) || ($num_lanes == 12)} {
	set iwords 4
    } else {
	set iwords 8	
    }

    if {$iwords == 2} {
	set log2_iwords 1
    } elseif {$iwords == 4} {
	set log2_iwords 2
    } else {
	set log2_iwords 3
    } 
    

    if {$dev_family != "Stratix IV"} {
	send_message error "The selected device family is not supported, please select Stratix IV"
    } else {
	
	if {($num_lanes == 8) || ($num_lanes == 20) || ($num_lanes == 4) || ($num_lanes == 12) || ($num_lanes == 10)} {
	    add_instance alt_ilk alt_ntrlkn_${num_lanes}l_${lrate}
	} else {
	    send_message error "Lane counts other than 4,8,10,12 and 20 are currently not supported"
	}
		
	inherit_parameter_values alt_ilk

		
	#+-------------------
	#| export clocks
	#|
	
        add_instance tx_mac_clk clock_source
        add_interface tx_mac_clk clock end
        set_interface_property tx_mac_clk export_of tx_mac_clk.clk_in

        add_instance rx_mac_clk clock_source
        add_interface rx_mac_clk clock end
        set_interface_property rx_mac_clk export_of rx_mac_clk.clk_in

        #+---------------------
        #| export reset signals
        #|

	#+---------------------
	#| export status signals
	#|


	add_interface rx_status conduit start
	set_interface_property rx_status export_of alt_ilk.rx_status

	add_interface tx_status conduit start
	set_interface_property tx_status export_of alt_ilk.tx_status

	add_interface tx_control conduit end
	set_interface_property tx_control export_of alt_ilk.tx_control



	# +--------------------------------------
	# | adding interfaces for out of band flow control
	# |

	set en_oob [get_parameter_value GUI_ENABLE_OOB]
	
	if {$en_oob} {

	    add_instance alt_ilk_oob_rx alt_ntrlkn_oob_rx
	    add_instance alt_ilk_oob_tx alt_ntrlkn_oob_tx

	    add_interface rx_oob_in conduit end
	    set_interface_property rx_oob_in export_of alt_ilk_oob_rx.rx_oob_in

	    add_interface rx_oob_out conduit start
	    set_interface_property rx_oob_out export_of alt_ilk_oob_rx.rx_oob_out

	    add_interface tx_oob_in conduit end
	    set_interface_property tx_oob_in export_of alt_ilk_oob_tx.tx_oob_in

	    add_interface tx_oob_out conduit start
	    set_interface_property tx_oob_out export_of alt_ilk_oob_tx.tx_oob_out

	    set_instance_parameter alt_ilk_oob_tx NUM_LANES [get_parameter_value LANES]
	    set_instance_parameter alt_ilk_oob_rx NUM_LANES [get_parameter_value LANES]

	    set_instance_parameter alt_ilk_oob_tx CAL_BITS [get_parameter_value CAL_BITS]
	    set_instance_parameter alt_ilk_oob_rx CAL_BITS [get_parameter_value CAL_BITS]
	    

	}
	
	# |
	# +-------------------------------------------

	# +---------------------------------------------
	# | adding hsio interfaces
	# |

	set en_hsio [get_parameter_value GUI_ENABLE_HSIO]


	if {!($en_hsio)} {

	    add_instance ref_clk clock_source
	    add_interface ref clock end
	    set_interface_property ref export_of ref_clk.clk_in

	    add_instance cal_blk_clk clock_source
	    add_interface cal_blk clock end
	    set_interface_property cal_blk export_of cal_blk_clk.clk_in
	    
	    #adding clock bridge to enable the export of the tx_coreclkout SPR:356007
	    add_instance tx_clkout_bridge altera_clock_bridge
	    set_instance_parameter tx_clkout_bridge NUM_CLOCK_OUTPUTS 4

	    #adding clock bridge to enable the export of the rx_coreclkout SPR:356007
	    add_instance rx_clkout_bridge altera_clock_bridge
	    set_instance_parameter rx_clkout_bridge NUM_CLOCK_OUTPUTS 3
  
	    for {set k 0} {$k < $num_hsio_inst} {incr k} {
		
		add_instance alt_ilk_hsio_bank_${k} $hsio_inst
	    }
            add_instance alt_rst alt_ntrlkn_reset
            set_instance_parameter alt_rst HSIO_INST_NUM $num_hsio_inst

	    # making relevant connections to and from the clock bridge
	    add_connection alt_ilk_hsio_bank_0.clk_out/tx_clkout_bridge.in_clk
	    add_connection alt_ilk.common_rx_coreclk/rx_clkout_bridge.in_clk

            add_connection rx_clkout_bridge.out_clk_2/alt_rst.common_rx_clk
            add_connection tx_clkout_bridge.out_clk_3/alt_rst.common_tx_clk


	    add_interface tx_coreclkout clock start
	    set_interface_property tx_coreclkout export_of tx_clkout_bridge.out_clk
	    set_interface_property tx_coreclkout PORT_NAME_MAP {tx_coreclkout out_clk}
	    add_connection tx_clkout_bridge.out_clk_2/alt_ilk.tx_lane_clk

	    add_interface rx_coreclkout clock start
	    set_interface_property rx_coreclkout export_of rx_clkout_bridge.out_clk
	    set_interface_property rx_coreclkout PORT_NAME_MAP {rx_coreclkout out_clk}

            add_connection alt_rst.tx_mac_arst/alt_ilk.tx_mac_arst
            add_connection alt_rst.rx_mac_arst/alt_ilk.rx_mac_arst
            add_connection alt_rst.tx_lane_arst/alt_ilk.tx_lane_arst
            add_connection cal_blk_clk.clk/alt_rst.cal_blk_clk
            add_connection tx_mac_clk.clk/alt_rst.tx_mac_clk
            add_connection rx_mac_clk.clk/alt_rst.rx_mac_clk
            add_connection tx_mac_clk.clk/alt_ilk.tx_mac_clk
            add_connection rx_mac_clk.clk/alt_ilk.rx_mac_clk

            add_interface reset conduit end
            set_interface_property reset export_of alt_rst.reset

            	    
	       
	    for {set k 0} {$k < $num_hsio_inst} {incr k} {
	    		
		add_connection ref_clk.clk/alt_ilk_hsio_bank_${k}.ref_clk
		add_connection tx_clkout_bridge.out_clk_1/alt_ilk_hsio_bank_${k}.clk_in
		add_connection cal_blk_clk.clk/alt_ilk_hsio_bank_${k}.cal_blk_clk
		add_connection rx_clkout_bridge.out_clk_1/alt_ilk_hsio_bank_${k}.common_rx_clk
		add_connection alt_ilk_hsio_bank_${k}.rx_clk/alt_ilk.rx_lane_clk${k}
		add_connection alt_ilk_hsio_bank_${k}.rx_parallel_data/alt_ilk.rx_data${k}
		add_connection alt_ilk.tx_data${k}/alt_ilk_hsio_bank_${k}.tx_parallel_data

	
		add_interface tx_serial_data${k} conduit start
		set_interface_property tx_serial_data${k} export_of alt_ilk_hsio_bank_${k}.tx_serial_data

		add_interface rx_serial_data${k} conduit end
		set_interface_property rx_serial_data${k} export_of alt_ilk_hsio_bank_${k}.rx_serial_data

                add_connection alt_rst.hs${k}_reco_busy/alt_ilk_hsio_bank_${k}.reco_busy
                add_connection alt_rst.hs${k}_rx_freqlocked_n/alt_ilk_hsio_bank_${k}.rx_freqlocked_n
                add_connection alt_rst.hs${k}_pll_locked_n/alt_ilk_hsio_bank_${k}.pll_locked_n
                add_connection alt_rst.hs${k}_pll_powerdown/alt_ilk_hsio_bank_${k}.pll_powerdown
                add_connection alt_rst.hs${k}_tx_digitalreset/alt_ilk_hsio_bank_${k}.tx_digitalreset
                add_connection alt_rst.hs${k}_rx_digitalreset/alt_ilk_hsio_bank_${k}.rx_digitalreset
                add_connection alt_rst.hs${k}_rx_analogreset/alt_ilk_hsio_bank_${k}.rx_analogreset
                add_connection alt_rst.hs${k}_tx_lane_arst_early/alt_ilk_hsio_bank_${k}.tx_lane_arst_early
                add_connection alt_rst.hs${k}_rx_lane_arst_early/alt_ilk_hsio_bank_${k}.rx_lane_arst_early

		set_instance_parameter alt_ilk_hsio_bank_${k} SIM_FAST_RESET [get_parameter_value SIM_FAST_RESET]

		if {$lrate == "6g"} {
		set_instance_parameter alt_ilk_hsio_bank_${k} GUI_LANE_RATE [get_parameter_value LANE_RATE]
		}		
	    }	    
	    	    
	   
	} else {
	    
	    for {set m 0} {$m < $num_hsio_inst} {incr m} {
		
		add_interface rx_lane_clk$m conduit end
		set_interface_property rx_lane_clk$m export_of alt_ilk.rx_lane_clk${m}

		add_interface rx_data$m conduit end
		set_interface_property rx_data$m export_of alt_ilk.rx_data${m}

		add_interface tx_data$m conduit start
		set_interface_property tx_data$m export_of alt_ilk.tx_data${m}	      
	    }
	    
	    add_interface common_rx_c clock start
	    set_interface_property common_rx_c export_of alt_ilk.common_rx_coreclk

            add_instance  tx_lane_clk clock_source
            add_interface tx_lane_clk clock end
            set_interface_property tx_lane_clk export_of tx_lane_clk.clk_in
            add_connection tx_lane_clk.clk/alt_ilk.tx_lane_clk

#    add_interface tx_lane_c clock end
#    set_interface_property tx_lane_c export_of alt_ilk.tx_lane_clk

            add_interface tx_mac_r conduit end
            set_interface_property tx_mac_r export_of alt_ilk.tx_mac_arst

            add_interface rx_mac_r conduit end
            set_interface_property rx_mac_r export_of alt_ilk.rx_mac_arst

            add_interface tx_lane_r conduit end
            set_interface_property tx_lane_r export_of alt_ilk.tx_lane_arst

            add_connection tx_mac_clk.clk/alt_ilk.tx_mac_clk
            add_connection rx_mac_clk.clk/alt_ilk.rx_mac_clk


	}
	
	for {set i 0} {$i < $num_chan} {incr i} {

	    add_interface tx_ch${i}_datain avalon_streaming end
	    set_interface_property tx_ch${i}_datain export_of alt_ilk.tx_ch${i}_datain
	    
	    add_interface rx_ch${i}_dataout avalon_streaming start
	    set_interface_property rx_ch${i}_dataout export_of alt_ilk.rx_ch${i}_dataout
	}	 
    }

    # |
    # +--------------------------------

} 


proc export_interfaces {inst_name iface_name type dir} {
    
    add_interface $iface_name $type $dir
    set_interface_property $iface_name export_of $inst_name.$iface_name
       
}



proc inherit_parameter_values {instance_name} {
    
    set_instance_parameter alt_ilk OPERATIONAL_MODE [get_parameter_value OPERATIONAL_MODE]
    set_instance_parameter alt_ilk LANES [get_parameter_value LANES]
    set_instance_parameter alt_ilk META_FRAME_LEN [get_parameter_value META_FRAME_LEN]
    set_instance_parameter alt_ilk NUM_CHANNELS [get_parameter_value NUM_CHANNELS]
    set_instance_parameter alt_ilk GUI_ENABLE_HSIO [get_parameter_value GUI_ENABLE_HSIO]
    set_instance_parameter alt_ilk BURST_MAX [get_parameter_value BURST_MAX]
    set_instance_parameter alt_ilk CALENDAR_PAGES [get_parameter_value CALENDAR_PAGES]
    set_instance_parameter alt_ilk GUI_ENABLE_CALENDAR [get_parameter_value GUI_ENABLE_CALENDAR]
    set_instance_parameter alt_ilk GUI_BURST_SHORT [get_parameter_value GUI_BURST_SHORT]
    set_instance_parameter alt_ilk GUI_ENABLE_DYNAMIC_BURST [get_parameter_value GUI_ENABLE_DYNAMIC_BURST]
}




