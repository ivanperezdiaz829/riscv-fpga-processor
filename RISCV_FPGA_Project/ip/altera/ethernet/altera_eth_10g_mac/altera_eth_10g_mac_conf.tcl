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


add_parameter ENABLE_TIMESTAMPING INTEGER 0
set_parameter_property ENABLE_TIMESTAMPING DISPLAY_NAME "Enable time stamping"
set_parameter_property ENABLE_TIMESTAMPING DISPLAY_HINT boolean
set_parameter_property ENABLE_TIMESTAMPING DESCRIPTION "Instantiate time stamping component"
set_parameter_property ENABLE_TIMESTAMPING VISIBLE true
set_parameter_update_callback ENABLE_TIMESTAMPING update_1step

add_parameter ENABLE_PTP_1STEP INTEGER 0
set_parameter_property ENABLE_PTP_1STEP DISPLAY_NAME "Enable PTP one-step clock support"
set_parameter_property ENABLE_PTP_1STEP DISPLAY_HINT boolean
set_parameter_property ENABLE_PTP_1STEP VISIBLE true
set_parameter_property ENABLE_PTP_1STEP DESCRIPTION "Instantiate PTP 1-step clock component"
set_parameter_update_callback ENABLE_PTP_1STEP update_txcrc

add_parameter TSTAMP_FP_WIDTH INTEGER 4
set_parameter_property TSTAMP_FP_WIDTH DISPLAY_NAME "Timestamp fingerprint width"
set_parameter_property TSTAMP_FP_WIDTH allowed_ranges {1:32}
set_parameter_property TSTAMP_FP_WIDTH DESCRIPTION "Width of timestamp fingerprint"
set_parameter_property TSTAMP_FP_WIDTH VISIBLE true

add_parameter PREAMBLE_PASSTHROUGH INTEGER 0
set_parameter_property PREAMBLE_PASSTHROUGH DISPLAY_NAME "Enable preamble pass-through mode"
set_parameter_property PREAMBLE_PASSTHROUGH DISPLAY_HINT boolean
set_parameter_property PREAMBLE_PASSTHROUGH DESCRIPTION "Instantiate preamble passthrough component"

add_parameter ENABLE_PFC INTEGER 0
set_parameter_property ENABLE_PFC DISPLAY_NAME "Enable priority-based flow control (PFC)"
set_parameter_property ENABLE_PFC DISPLAY_HINT boolean
set_parameter_property ENABLE_PFC DESCRIPTION "Enable priority-based flow control feature"

add_parameter PFC_PRIORITY_NUM INTEGER 8
set_parameter_property PFC_PRIORITY_NUM DISPLAY_NAME "Number of PFC queues:"
set_parameter_property PFC_PRIORITY_NUM allowed_ranges {2:8}
set_parameter_property PFC_PRIORITY_NUM DESCRIPTION "Number of PFC priorities used"

add_parameter DATAPATH_OPTION INTEGER 3
set_parameter_property DATAPATH_OPTION DISPLAY_NAME "Datapath option"
set_parameter_property DATAPATH_OPTION allowed_ranges {"1:TX only" "2:RX only" "3:TX & RX"}
set_parameter_property DATAPATH_OPTION DESCRIPTION "Datapath option"

add_parameter ENABLE_SUPP_ADDR INTEGER 1
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_NAME "Enable supplementary address"
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_HINT boolean
set_parameter_property ENABLE_SUPP_ADDR DESCRIPTION "Enable supplementary address feature"

add_parameter INSTANTIATE_TX_CRC INTEGER 1
set_parameter_property INSTANTIATE_TX_CRC DISPLAY_NAME "Enable CRC on transmit path"
set_parameter_property INSTANTIATE_TX_CRC DISPLAY_HINT boolean
set_parameter_property INSTANTIATE_TX_CRC DESCRIPTION "Instantiate CRC component on transmit path"

add_parameter INSTANTIATE_STATISTICS INTEGER 1
set_parameter_property INSTANTIATE_STATISTICS DISPLAY_NAME "Enable statistics collection"
set_parameter_property INSTANTIATE_STATISTICS DISPLAY_HINT boolean
set_parameter_property INSTANTIATE_STATISTICS DESCRIPTION "Instantiate statistics component"

add_parameter REGISTER_BASED_STATISTICS INTEGER 0
set_parameter_property REGISTER_BASED_STATISTICS DISPLAY_NAME "Statistics counters"
set_parameter_property REGISTER_BASED_STATISTICS allowed_ranges {"0:Memory-based" "1:Register-based"}
set_parameter_property REGISTER_BASED_STATISTICS DESCRIPTION "Enable statistics implemented using register or memory"

add_parameter ENABLE_1G10G_MAC INTEGER 0
set_parameter_property ENABLE_1G10G_MAC DISPLAY_NAME "Speed"
set_parameter_property ENABLE_1G10G_MAC DISPLAY_HINT radio
set_parameter_property ENABLE_1G10G_MAC allowed_ranges {"0:10 Gbps" "1:1 GBps/10 Gbps" "2:Multi-Speed 10 Mbps-10 Gbps"}
set_parameter_property ENABLE_1G10G_MAC DESCRIPTION "Speed select for 10G MAC"
set_parameter_update_callback ENABLE_1G10G_MAC update_passthrough

add_display_item "MAC Options" ENABLE_1G10G_MAC parameter
add_display_item "MAC Options" PREAMBLE_PASSTHROUGH parameter
add_display_item "MAC Options" ENABLE_PFC parameter
add_display_item "MAC Options" PFC_PRIORITY_NUM parameter

add_display_item "Resource Optimization Options" DATAPATH_OPTION parameter
add_display_item "Resource Optimization Options" ENABLE_SUPP_ADDR parameter
add_display_item "Resource Optimization Options" INSTANTIATE_TX_CRC parameter
add_display_item "Resource Optimization Options" INSTANTIATE_STATISTICS parameter
add_display_item "Resource Optimization Options" REGISTER_BASED_STATISTICS parameter

add_display_item "Timestamp Options" ENABLE_TIMESTAMPING parameter
add_display_item "Timestamp Options" ENABLE_PTP_1STEP parameter
add_display_item "Timestamp Options" TSTAMP_FP_WIDTH parameter

proc ethernet_10g_mac_update_gui {} {
    set datapath_option [get_parameter_value DATAPATH_OPTION]
    set stat_ena [get_parameter_value INSTANTIATE_STATISTICS]
    set pfc_ena [get_parameter_value ENABLE_PFC]
    set timestamp_ena [get_parameter_value ENABLE_TIMESTAMPING]
    set ptp_1step_ena [get_parameter_value ENABLE_PTP_1STEP]
    set mac_1g10g_ena [get_parameter_value ENABLE_1G10G_MAC]

    if {$mac_1g10g_ena != 0} {
        set_parameter_property DATAPATH_OPTION allowed_ranges {"3:TX & RX"}
        
    } else {
        set_parameter_property DATAPATH_OPTION allowed_ranges {"1:TX only" "2:RX only" "3:TX & RX"}
    }
    
    
    if {$timestamp_ena == 0} {
        set_parameter_property ENABLE_PTP_1STEP ENABLED false                   
        set_parameter_property TSTAMP_FP_WIDTH ENABLED false
    } else {
        set_parameter_property ENABLE_PTP_1STEP ENABLED true
        set_parameter_property TSTAMP_FP_WIDTH ENABLED true
    }
    
    if {$pfc_ena == 0} {
        set_parameter_property PFC_PRIORITY_NUM ENABLED false
    } else {
        set_parameter_property PFC_PRIORITY_NUM ENABLED true
    }
    
    if {$stat_ena == 0} {
        set_parameter_property REGISTER_BASED_STATISTICS ENABLED false
    } else {
        set_parameter_property REGISTER_BASED_STATISTICS ENABLED true
    }
    
    if {[_get_device_type]} {
        set_parameter_property REGISTER_BASED_STATISTICS allowed_ranges {"0:Memory-based"}
    } else {
        set_parameter_property REGISTER_BASED_STATISTICS allowed_ranges {"0:Memory-based" "1:Register-based"}
    }
    
    # TX Only
    if { $datapath_option == 1 } {
        set_parameter_property ENABLE_SUPP_ADDR ENABLED false
    } else {
        set_parameter_property ENABLE_SUPP_ADDR ENABLED true
    }
    
    # RX Only
    if { $datapath_option == 2 } {
        set_parameter_property INSTANTIATE_TX_CRC ENABLED false
    } else {
        if {$ptp_1step_ena == 1} {
            set_parameter_property INSTANTIATE_TX_CRC ENABLED false    
        } else {
            set_parameter_property INSTANTIATE_TX_CRC ENABLED true
        }
    }
    
    #if 1G 10G or quad speed, preamble pass through mode does not supported
    if { $mac_1g10g_ena != 0 } {
    set_parameter_property PFC_PRIORITY_NUM ENABLED false
    set_parameter_property PREAMBLE_PASSTHROUGH ENABLED false
    set_parameter_property ENABLE_PFC ENABLED false
    
    } else {
    set_parameter_property PFC_PRIORITY_NUM ENABLED true
    set_parameter_property PREAMBLE_PASSTHROUGH ENABLED true
    set_parameter_property ENABLE_PFC ENABLED true
    
    }
}


proc update_1step {arg1} {
    set tstamp_ena [get_parameter_value $arg1]

    if {$tstamp_ena == 0} {
        set_parameter_value ENABLE_PTP_1STEP 0
    }
}

proc update_txcrc {arg2} {
    set onestep_ena [get_parameter_value $arg2]

    if {$onestep_ena == 1} {
        set_parameter_value INSTANTIATE_TX_CRC 1
    }
    
}

proc update_passthrough {arg3} {
    set ena_1g10g_mac [get_parameter_value $arg3]

    if {$ena_1g10g_mac == 1 || $ena_1g10g_mac == 2} {
        set_parameter_value PREAMBLE_PASSTHROUGH 0
    }
    
}


