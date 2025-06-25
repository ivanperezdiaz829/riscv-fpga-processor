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




set ::display_all_massage 0





add_parameter LOCAL_IF_CLK_MHZ Integer 0
set_parameter_property LOCAL_IF_CLK_MHZ DISPLAY_NAME "Local interface clock frequency"
set_parameter_property LOCAL_IF_CLK_MHZ DESCRIPTION "Clock frequency on the Avalon-MM interface"
set_parameter_property LOCAL_IF_CLK_MHZ DERIVED true
set_parameter_property LOCAL_IF_CLK_MHZ UNITS Megahertz
set_parameter_property LOCAL_IF_CLK_MHZ VISIBLE true
set_parameter_property LOCAL_IF_CLK_MHZ ENABLED false

add_parameter LOCAL_ADDR_WIDTH Integer 0
set_parameter_property LOCAL_ADDR_WIDTH DISPLAY_NAME "Local interface address width"
set_parameter_property LOCAL_ADDR_WIDTH DESCRIPTION "Address width on the Avalon-MM interface"
set_parameter_property LOCAL_ADDR_WIDTH DERIVED true
set_parameter_property LOCAL_ADDR_WIDTH UNITS Bits
set_parameter_property LOCAL_ADDR_WIDTH VISIBLE true
set_parameter_property LOCAL_ADDR_WIDTH ENABLED false

add_parameter LOCAL_DATA_WIDTH Integer 0
set_parameter_property LOCAL_DATA_WIDTH DISPLAY_NAME "Local interface data width"
set_parameter_property LOCAL_DATA_WIDTH DESCRIPTION "Data width on the Avalon-MM interface"
set_parameter_property LOCAL_DATA_WIDTH VISIBLE true
set_parameter_property LOCAL_DATA_WIDTH DERIVED true
set_parameter_property LOCAL_DATA_WIDTH UNITS Bits
set_parameter_property LOCAL_DATA_WIDTH ENABLED false



add_parameter CTL_SELF_REFRESH_EN Boolean false
set_parameter_property CTL_SELF_REFRESH_EN DISPLAY_NAME "Enable Self-Refresh Controls"
set_parameter_property CTL_SELF_REFRESH_EN DESCRIPTION "Select this option to enable the self-refresh signals on the controller top level. These controls allow you to control when the memory is placed into self-refresh mode."
set_parameter_property CTL_SELF_REFRESH_EN VISIBLE true
set_parameter_property CTL_SELF_REFRESH_EN DISPLAY_HINT boolean

add_parameter AUTO_POWERDN_EN Boolean false
set_parameter_property AUTO_POWERDN_EN DISPLAY_NAME "Enable Auto Power Down"
set_parameter_property AUTO_POWERDN_EN DESCRIPTION "Select this option to allow the controller to automatically place the memory into power down mode after a specified number of idle cycles. You can specify the number of idle cycles after which the controller powers down the memory in the Auto Power Down Cycles box below."
set_parameter_property AUTO_POWERDN_EN VISIBLE true
set_parameter_property AUTO_POWERDN_EN DISPLAY_HINT boolean

add_parameter MEM_AUTO_PD_CYCLES Integer 0
set_parameter_property MEM_AUTO_PD_CYCLES DISPLAY_NAME "Auto Power Down Cycles"
set_parameter_property MEM_AUTO_PD_CYCLES DESCRIPTION "The number of idle controller clock cycles after which the controller automatically powers down the memory. The legal range is from 1 to 65,535 controller clock cycles."
set_parameter_property MEM_AUTO_PD_CYCLES VISIBLE true
set_parameter_property MEM_AUTO_PD_CYCLES DISPLAY_HINT columns:10
set_parameter_property MEM_AUTO_PD_CYCLES UNITS Cycles
set_parameter_property MEM_AUTO_PD_CYCLES ALLOWED_RANGES {0:65535}

add_parameter CTL_USR_REFRESH_EN Boolean false
set_parameter_property CTL_USR_REFRESH_EN DISPLAY_NAME "Enable User Auto-Refresh Controls"
set_parameter_property CTL_USR_REFRESH_EN DESCRIPTION "Select this option to enable the user auto-refresh control signals on the controller top level. These controller signals allow you to control when the controller issues memory auto-refresh commands."
set_parameter_property CTL_USR_REFRESH_EN VISIBLE true
set_parameter_property CTL_USR_REFRESH_EN DISPLAY_HINT boolean

add_parameter CTL_AUTOPCH_EN Boolean false
set_parameter_property CTL_AUTOPCH_EN DISPLAY_NAME "Enable Auto-Precharge Control"
set_parameter_property CTL_AUTOPCH_EN DESCRIPTION "Select this option to enable the auto-precharge control on the controller top level. Asserting the auto-precharge control signal while requesting a read or write burst allows you to specify whether or not the controller should close (auto-precharge) the currently open page at the end of the read or write burst."
set_parameter_property CTL_AUTOPCH_EN VISIBLE true
set_parameter_property CTL_AUTOPCH_EN DISPLAY_HINT boolean

add_parameter ADDR_ORDER Integer 0
set_parameter_property ADDR_ORDER DISPLAY_NAME "Local-to-Memory Address Mapping"
set_parameter_property ADDR_ORDER DESCRIPTION "This option allows you to control the mapping between the address bits on the Avalon interface and the chip, row, bank and column bits on the memory."
set_parameter_property ADDR_ORDER VISIBLE true

add_parameter CTL_LOOK_AHEAD_DEPTH Integer 4
set_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME "Command Queue Look-Ahead Depth"
set_parameter_property CTL_LOOK_AHEAD_DEPTH DESCRIPTION "Select a look-ahead depth value to control how many read or writes requests the look-ahead bank management logic examines. Larger numbers are likely to increase the efficiency of the bank management, but at the cost of higher resource usage. Smaller values may be less efficient, but also use fewer resources."
set_parameter_property CTL_LOOK_AHEAD_DEPTH VISIBLE true

add_parameter CONTROLLER_LATENCY String 5
set_parameter_property CONTROLLER_LATENCY DISPLAY_NAME "Reduce Controller Latency By"
set_parameter_property CONTROLLER_LATENCY DESCRIPTION "Select the number of controller latency to be reduce in controller clock cycles for better latency or fmax. Lower latency controller would not be able to run as fast as the default frequency. Refer to the External Memory Interface handbook for supported latency and maximum frequency combination."
set_parameter_property CONTROLLER_LATENCY DISPLAY_HINT columns:10
set_parameter_property CONTROLLER_LATENCY ALLOWED_RANGES {"4:1" "5:0"}

add_parameter CFG_REORDER_DATA Boolean false
set_parameter_property CFG_REORDER_DATA DISPLAY_NAME "Enable Reodering"
set_parameter_property CFG_REORDER_DATA DESCRIPTION "Select this option to allow the controller to perform Command and Data Reordering to achieve the highest possible efficiency"
set_parameter_property CFG_REORDER_DATA DISPLAY_HINT columns:10

add_parameter CFG_STARVE_LIMIT Integer 4
set_parameter_property CFG_STARVE_LIMIT DISPLAY_NAME "Starvation limit for each command"
set_parameter_property CFG_STARVE_LIMIT DESCRIPTION "Specify the number of commands that can be served before a starved command"
set_parameter_property CFG_STARVE_LIMIT DISPLAY_HINT columns:10
set_parameter_property CFG_STARVE_LIMIT ALLOWED_RANGES {1:63}
set_parameter_property CFG_STARVE_LIMIT DISPLAY_UNITS "commands"

add_parameter CTL_CSR_ENABLED Boolean false
set_parameter_property CTL_CSR_ENABLED DISPLAY_NAME "Enable Configuration and Status Register Interface"
set_parameter_property CTL_CSR_ENABLED DESCRIPTION "Select this option to enable run-time configuration and status of the memory controller. Enabling this option adds an additional Avalon Memory-Mapped slave port to the memory controller top level. Using this slave port, you can change or read out the memory timing parameters, memory address sizes, mode register settings and controller status. If Error Detection and Correction Logic are enabled, the same slave port also allows you to control and retrieve the status of this logic."
set_parameter_property CTL_CSR_ENABLED VISIBLE true
set_parameter_property CTL_CSR_ENABLED DISPLAY_HINT boolean

add_parameter CTL_CSR_CONNECTION STRING "INTERNAL_JTAG"
set_parameter_property CTL_CSR_CONNECTION DISPLAY_NAME "CSR port host interface"
set_parameter_property CTL_CSR_CONNECTION DESCRIPTION "Specifies the connection type to CSR port. The port can be exported, internally connected to a JTAG Avalon Master, or both"
set_parameter_property CTL_CSR_CONNECTION UNITS None
set_parameter_property CTL_CSR_CONNECTION ALLOWED_RANGES {"INTERNAL_JTAG:Internal (JTAG)" "EXPORT:Avalon-MM Slave"}

add_parameter CTL_ECC_ENABLED Boolean false
set_parameter_property CTL_ECC_ENABLED DISPLAY_NAME "Enable Error Detection and Correction Logic"
set_parameter_property CTL_ECC_ENABLED DESCRIPTION "Select this option to enable Error Correcting Code (ECC) for single-bit error correction and double-bit error detection. Your memory interface must be a multiple of 40 or 72 bits wide in order to be able to use ECC."
set_parameter_property CTL_ECC_ENABLED VISIBLE true
set_parameter_property CTL_ECC_ENABLED DISPLAY_HINT boolean

add_parameter CTL_ECC_AUTO_CORRECTION_ENABLED Boolean false
set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME "Enable Auto Error Correction"
set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DESCRIPTION "Select this option to allow the controller to perform auto correction when a single-bit error has been detected by the ECC logic."
set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_HINT boolean

add_parameter MULTICAST_EN Boolean false
set_parameter_property MULTICAST_EN DISPLAY_NAME "Enable Multi-cast Write Control"
set_parameter_property MULTICAST_EN DESCRIPTION "Select this option to enable the multi-cast write control on the controller top level. Multi-cast write is not supported if the ECC logic is enabled or for registered DIMM interfaces."
set_parameter_property MULTICAST_EN DISPLAY_HINT boolean

add_parameter CTL_DYNAMIC_BANK_ALLOCATION Boolean false
set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME "Enable reduced bank tracking for area optimization"
set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DESCRIPTION "Select this option to reduce the number of bank and timer blocks in the controller. Specify the number of banks to track in the \"Number of banks to track\" box below."
set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_HINT boolean

add_parameter CTL_DYNAMIC_BANK_NUM Integer 4
set_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME "Number of banks to track"
set_parameter_property CTL_DYNAMIC_BANK_NUM DESCRIPTION "Specify the number of banks to track when \"Enable reduced bank tracking for area optimization\" is enabled. The legal range is from 1 or the value of Command Queue Look-Ahead depth (whichever is greater) to 16."
set_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_HINT columns:10


add_parameter DEBUG_MODE Boolean false
set_parameter_property DEBUG_MODE DISPLAY_NAME "Enable internal debug parameter"
set_parameter_property DEBUG_MODE VISIBLE false

add_parameter CTL_HRB_ENABLED Boolean false
set_parameter_property CTL_HRB_ENABLED DISPLAY_NAME "Enable half rate bridge"
set_parameter_property CTL_HRB_ENABLED VISIBLE false

add_parameter ENABLE_BURST_MERGE Boolean false
set_parameter_property ENABLE_BURST_MERGE DISPLAY_NAME "Enable burst merging"
set_parameter_property ENABLE_BURST_MERGE VISIBLE false

add_parameter NEXTGEN Boolean true
set_parameter_property NEXTGEN DISPLAY_NAME "Next Gen Controller"
set_parameter_property NEXTGEN VISIBLE false

add_parameter LOCAL_ID_WIDTH Integer 8
set_parameter_property LOCAL_ID_WIDTH DISPLAY_NAME "Local ID width"
set_parameter_property LOCAL_ID_WIDTH VISIBLE false

add_parameter RDBUFFER_ADDR_WIDTH Integer 12
set_parameter_property RDBUFFER_ADDR_WIDTH DISPLAY_NAME "Read buffer address width"
set_parameter_property RDBUFFER_ADDR_WIDTH VISIBLE false

add_parameter WRBUFFER_ADDR_WIDTH Integer 12
set_parameter_property WRBUFFER_ADDR_WIDTH DISPLAY_NAME "Write buffer address width"
set_parameter_property WRBUFFER_ADDR_WIDTH VISIBLE false

add_parameter USE_MM_ADAPTOR Boolean true
set_parameter_property USE_MM_ADAPTOR DISPLAY_NAME "Use Avalon MM Adaptor"
set_parameter_property USE_MM_ADAPTOR VISIBLE false

add_parameter USE_AXI_ADAPTOR Boolean false
set_parameter_property USE_AXI_ADAPTOR DISPLAY_NAME "Use AXI Adaptor"
set_parameter_property USE_AXI_ADAPTOR VISIBLE false


add_parameter MEM_TRAS String 0
set_parameter_property MEM_TRAS DISPLAY_NAME "Active to precharge time (tCK)"
set_parameter_property MEM_TRAS DERIVED true
set_parameter_property MEM_TRAS VISIBLE false

add_parameter MEM_TRCD Integer 0
set_parameter_property MEM_TRCD DISPLAY_NAME "Active to read/write time (tCK)"
set_parameter_property MEM_TRCD DERIVED true
set_parameter_property MEM_TRCD VISIBLE false

add_parameter MEM_TRP Integer 0
set_parameter_property MEM_TRP DISPLAY_NAME "Precharge command period (tCK)"
set_parameter_property MEM_TRP DERIVED true
set_parameter_property MEM_TRP VISIBLE false

add_parameter MEM_TREFI Integer 0
set_parameter_property MEM_TREFI DISPLAY_NAME "Refresh command interval (tCK)"
set_parameter_property MEM_TREFI DERIVED true
set_parameter_property MEM_TREFI VISIBLE false

add_parameter MEM_TRFC Integer 0
set_parameter_property MEM_TRFC DISPLAY_NAME "Auto-refresh command interval (tCK)"
set_parameter_property MEM_TRFC DERIVED true
set_parameter_property MEM_TRFC VISIBLE false

add_parameter MEM_TWR Integer 0
set_parameter_property MEM_TWR DISPLAY_NAME "Write recovery time (tCK)"
set_parameter_property MEM_TWR DERIVED true
set_parameter_property MEM_TWR VISIBLE false

add_parameter MEM_TFAW Integer 0
set_parameter_property MEM_TFAW DISPLAY_NAME "Four active window time (tCK)"
set_parameter_property MEM_TFAW DERIVED true
set_parameter_property MEM_TFAW VISIBLE false

add_parameter MEM_TRRD Integer 0
set_parameter_property MEM_TRRD DISPLAY_NAME "RAS to RAS delay time (tCK)"
set_parameter_property MEM_TRRD VISIBLE false
set_parameter_property MEM_TRRD DERIVED true

add_parameter MEM_TRTP Integer 0
set_parameter_property MEM_TRTP DISPLAY_NAME "Read to precharge time (tCK)"
set_parameter_property MEM_TRTP DERIVED true
set_parameter_property MEM_TRTP VISIBLE false

add_parameter CTL_ECC_CSR_ENABLED Boolean false
set_parameter_property CTL_ECC_CSR_ENABLED VISIBLE false
set_parameter_property CTL_ECC_CSR_ENABLED DERIVED true

add_parameter MEM_IF_CHIP_BITS Integer 0
set_parameter_property MEM_IF_CHIP_BITS VISIBLE false
set_parameter_property MEM_IF_CHIP_BITS DERIVED true

add_parameter MEM_IF_DQS_WIDTH Integer 0
set_parameter_property MEM_IF_DQS_WIDTH VISIBLE false
set_parameter_property MEM_IF_DQS_WIDTH DERIVED true

add_parameter DWIDTH_RATIO Integer 4
set_parameter_property DWIDTH_RATIO VISIBLE false
set_parameter_property DWIDTH_RATIO DERIVED true

add_parameter CTL_ODT_ENABLED Boolean false
set_parameter_property CTL_ODT_ENABLED VISIBLE false
set_parameter_property CTL_ODT_ENABLED DERIVED true

add_parameter CTL_OUTPUT_REGD Boolean false
set_parameter_property CTL_OUTPUT_REGD VISIBLE false
set_parameter_property CTL_OUTPUT_REGD DERIVED true

add_parameter MEM_TRC Integer 0
set_parameter_property MEM_TRC VISIBLE false
set_parameter_property MEM_TRC DERIVED true

add_parameter MEM_IF_RD_TO_WR_TURNAROUND_OCT Integer 0
set_parameter_property MEM_IF_RD_TO_WR_TURNAROUND_OCT VISIBLE false
set_parameter_property MEM_IF_RD_TO_WR_TURNAROUND_OCT DERIVED true

add_parameter MEM_IF_WR_TO_RD_TURNAROUND_OCT Integer 0
set_parameter_property MEM_IF_WR_TO_RD_TURNAROUND_OCT VISIBLE false
set_parameter_property MEM_IF_WR_TO_RD_TURNAROUND_OCT DERIVED true

add_parameter CTL_ECC_MULTIPLES_40_72 Integer 0
set_parameter_property CTL_ECC_MULTIPLES_40_72 VISIBLE false
set_parameter_property CTL_ECC_MULTIPLES_40_72 DERIVED true

add_parameter CTL_REGDIMM_ENABLED Boolean false
set_parameter_property CTL_REGDIMM_ENABLED VISIBLE false
set_parameter_property CTL_REGDIMM_ENABLED DERIVED true

add_parameter MEM_IF_NUM_RANKS Integer 0
set_parameter_property MEM_IF_NUM_RANKS VISIBLE false
set_parameter_property MEM_IF_NUM_RANKS DERIVED true

add_parameter LOW_LATENCY Boolean false
set_parameter_property LOW_LATENCY VISIBLE false
set_parameter_property LOW_LATENCY DERIVED true

add_parameter CONTROLLER_TYPE String "nextgen_v110"
set_parameter_property CONTROLLER_TYPE VISIBLE false
set_parameter_property CONTROLLER_TYPE DERIVED true

add_parameter CTL_TBP_NUM Integer 4
set_parameter_property CTL_TBP_NUM VISIBLE false
set_parameter_property CTL_TBP_NUM DERIVED true


add_display_item "" "Controller Settings" GROUP TAB
add_display_item "Controller Settings" "Avalon Interface" GROUP
add_display_item "Controller Settings" "Low Power Mode" GROUP
add_display_item "Controller Settings" "Efficiency" GROUP
add_display_item "Controller Settings" "Configuration, Status and Error Handling" GROUP
add_display_item "Controller Settings" "Advanced Controller Features" GROUP

add_display_item "Clocks" LOCAL_IF_CLK_MHZ parameter
add_display_item "Clocks" LOCAL_ADDR_WIDTH parameter
add_display_item "Clocks" LOCAL_DATA_WIDTH parameter

add_display_item "Low Power Mode" CTL_SELF_REFRESH_EN parameter
add_display_item "Low Power Mode" AUTO_POWERDN_EN parameter
add_display_item "Low Power Mode" MEM_AUTO_PD_CYCLES parameter

add_display_item "Efficiency" CTL_USR_REFRESH_EN parameter
add_display_item "Efficiency" CTL_AUTOPCH_EN parameter
add_display_item "Efficiency" ADDR_ORDER parameter
add_display_item "Efficiency" CTL_LOOK_AHEAD_DEPTH parameter
add_display_item "Efficiency" CONTROLLER_LATENCY parameter
add_display_item "Efficiency" CTL_TBP_NUM parameter
add_display_item "Efficiency" CFG_REORDER_DATA parameter
add_display_item "Efficiency" CFG_STARVE_LIMIT parameter

add_display_item "Configuration, Status and Error Handling" CTL_CSR_ENABLED parameter
add_display_item "Configuration, Status and Error Handling" CTL_CSR_CONNECTION parameter
add_display_item "Configuration, Status and Error Handling" CTL_ECC_ENABLED parameter
add_display_item "Configuration, Status and Error Handling" CTL_ECC_AUTO_CORRECTION_ENABLED parameter

add_display_item "Advanced Controller Features" MULTICAST_EN parameter
add_display_item "Advanced Controller Features" CTL_DYNAMIC_BANK_ALLOCATION parameter
add_display_item "Advanced Controller Features" CTL_DYNAMIC_BANK_NUM parameter


proc ns_to_tck {ns_value clk_period_ns} {
    return [expr int(ceil([expr $ns_value / $clk_period_ns]))]
}

proc log2 {n} {
    return [expr log($n) / log(2)]
}

proc within {n min max} {
    if {$n < $min}  {
        return $min
    } elseif {$n > $max} {
        return $max
    }
    return $n
}

proc tck_to_ns {tck_value clk_freq_mhz n_dec} {
    set clk_period_ns [expr 1.0 / $clk_freq_mhz * 1000.0]
    set ns_value [expr $tck_value * $clk_period_ns]

    for {set i 0} {$i < $n_dec} {incr i 1} {
        set ns_value [expr $ns_value * 10.0]
    }

    set ns_value [expr ceil($ns_value)]

    for {set i 0} {$i < $n_dec} {incr i 1} {
        set ns_value [expr $ns_value / 10.0]
    }

    return $ns_value
}


proc validate_controller {} {

    set_parameter_value MODULE_VALID true


    set mem_clk_ns [expr round(1000000.0 / [get_parameter_value MEM_CLK_FREQ]) / 1000.0]

    if {[string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0} {
        set mem_wtcl [get_parameter_value MEM_WTCL]
    } else {
        set mem_wtcl 0
    }

    set hrb_factor [expr {([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0) ? 2 : 1}]

    set max_freq_for_reduce_latency 400

    set min_dynamic_bank_num 1
    set max_dynamic_bank_num 16
    if {[get_parameter_value CTL_LOOK_AHEAD_DEPTH] > 1} {
        set min_dynamic_bank_num [get_parameter_value CTL_LOOK_AHEAD_DEPTH]
    }

    set warn_msg ""
    set error_msg ""



    if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
        set local_clk_mhz [expr [get_parameter_value MEM_CLK_FREQ] / 4 / $hrb_factor]
        set dwidth_ratio 8
    } elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
        set local_clk_mhz [expr [get_parameter_value MEM_CLK_FREQ] / 2 / $hrb_factor]
        set dwidth_ratio 4
    } else {
        set local_clk_mhz [expr [get_parameter_value MEM_CLK_FREQ] / 1 / $hrb_factor]
        set dwidth_ratio 2
    }
    set_parameter_value LOCAL_IF_CLK_MHZ $local_clk_mhz
    set_parameter_value DWIDTH_RATIO $dwidth_ratio



    if {[get_parameter_value MEM_CS_WIDTH] > 1} {
        set chip_bits [log2 [get_parameter_value MEM_CS_WIDTH]]
    } else {
        set chip_bits 1
    }
    set_parameter_value MEM_IF_CHIP_BITS $chip_bits



    set dqs_width [expr [get_parameter_value MEM_DQ_WIDTH] / [get_parameter_value MEM_DQ_PER_DQS]]
    set_parameter_value MEM_IF_DQS_WIDTH $dqs_width



    set mem_if_num_ranks [expr [get_parameter_value MEM_CS_WIDTH] / [get_parameter_value MEM_CS_PER_RANK]]
    set_parameter_value MEM_IF_NUM_RANKS $mem_if_num_ranks



    if {([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0) && ($dwidth_ratio == 2)} {
        set minus_col_bit 2
    } elseif {([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0) && ($dwidth_ratio == 4)} {
        set minus_col_bit 3
    } else {
        set minus_col_bit [expr $dwidth_ratio / 2]
    }

    if {([string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0) && ([string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] ==0)} {
        set local_addr_width [expr [log2 $mem_if_num_ranks] + [get_parameter_value MEM_ROW_ADDR_WIDTH] + [get_parameter_value MEM_BANKADDR_WIDTH] + [get_parameter_value MEM_COL_ADDR_WIDTH] - $minus_col_bit]
    } else {
        set local_addr_width [expr [log2 [get_parameter_value MEM_CS_WIDTH]] + [get_parameter_value MEM_ROW_ADDR_WIDTH] + [get_parameter_value MEM_BANKADDR_WIDTH] + [get_parameter_value MEM_COL_ADDR_WIDTH] - $minus_col_bit]
    }
    set_parameter_value LOCAL_ADDR_WIDTH $local_addr_width



    set local_data_width 0
    set multiples_16_24_40_72 0
    set invalid_interface_width 0
    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0} {
        if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
            set local_data_width [expr 2 * [get_parameter_value MEM_DQ_WIDTH] * $dwidth_ratio]
        } else {
            set local_data_width [expr [get_parameter_value MEM_DQ_WIDTH] * $dwidth_ratio]
        }
    } else {

        set div_16 [expr [get_parameter_value MEM_DQ_WIDTH] % 16]
        set div_24 [expr [get_parameter_value MEM_DQ_WIDTH] % 24]
        set div_40 [expr [get_parameter_value MEM_DQ_WIDTH] % 40]
        set div_72 [expr [get_parameter_value MEM_DQ_WIDTH] % 72]
        if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ($div_16 == 0)} {
            set local_data_width [expr ([get_parameter_value MEM_DQ_WIDTH] - (8 * [get_parameter_value MEM_DQ_WIDTH] / 16)) * $dwidth_ratio * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_DQ_WIDTH] / 16]
        } elseif {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ($div_24 == 0)} {
            set local_data_width [expr ([get_parameter_value MEM_DQ_WIDTH] - (8 * [get_parameter_value MEM_DQ_WIDTH] / 24)) * $dwidth_ratio * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_DQ_WIDTH] / 24]
        } elseif {$div_40 == 0} {
            set local_data_width [expr ([get_parameter_value MEM_DQ_WIDTH] - (8 * [get_parameter_value MEM_DQ_WIDTH] / 40)) * $dwidth_ratio * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_DQ_WIDTH] / 40]
        } elseif {$div_72 == 0} {
            set local_data_width [expr ([get_parameter_value MEM_DQ_WIDTH] - (8 * [get_parameter_value MEM_DQ_WIDTH] / 72)) * $dwidth_ratio * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_DQ_WIDTH] / 72]
        } else {
            set invalid_interface_width 1
        }
    }

    set_parameter_value LOCAL_DATA_WIDTH $local_data_width
    set_parameter_value CTL_ECC_MULTIPLES_40_72 $multiples_16_24_40_72



    set odt_en 0
    if {(([string compare -nocase [get_parameter_value MEM_TYPE] "ddr2 sdram"] == 0) && ([string compare -nocase [get_parameter_value MEM_RTT_NOM] "disabled"] != 0)) || (([string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0) && ([string compare -nocase [get_parameter_value MEM_RTT_NOM] "odt disabled"] != 0))} {
        set odt_en 1
    }
    set_parameter_value CTL_ODT_ENABLED $odt_en



    set mem_al 0
    if {[string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0} {
        if {[string compare -nocase [get_parameter_value MEM_ATCL] "disabled"] == 0} {
            set mem_al 0
        } elseif {[string compare -nocase [get_parameter_value MEM_ATCL] "cl-1"] == 0} {
            set mem_al [expr [get_parameter_value MEM_TCL] - 1]
        } elseif {[string compare -nocase [get_parameter_value MEM_ATCL] "cl-2"] == 0} {
            set mem_al [expr [get_parameter_value MEM_TCL] - 2]
        } else {
            lappend error_msg 000
        }
    } else {
        set mem_al [get_parameter_value MEM_ATCL]
    }

    set mem_twl 0
    if {[string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0} {
        set mem_twl [expr $mem_wtcl + $mem_al]
    } else {
        set mem_twl [expr [get_parameter_value MEM_TCL] - 1 + $mem_al]
    }

    if {[string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0} {
        set mem_twl [expr $mem_twl + 1]
    }

    if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
        set mem_twl [expr $mem_twl - 1]
    }

    if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
        set afi_wlat [expr $mem_twl / ($dwidth_ratio / 4)]
    } elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
        set afi_wlat [expr $mem_twl / ($dwidth_ratio / 2)]
    } else {
        set afi_wlat [expr $mem_twl - 1]
    }

    if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 && ($afi_wlat > 1 || ($afi_wlat == 1 && [string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0))} {
        incr afi_wlat -1
    }

    if {(([string compare -nocase [get_parameter_value MEM_TYPE] "ddr2 sdram"] == 0) && ([get_parameter_value MEM_TCL] == 3) && ([string compare -nocase [get_parameter_value MEM_RTT_NOM] "disabled"] != 0)) || ($afi_wlat == 0) || (($afi_wlat == 1) && ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0))} {
        set_parameter_value CTL_OUTPUT_REGD true
    } else {
        set_parameter_value CTL_OUTPUT_REGD false
    }



    if {[string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0} {
        set_parameter_value CTL_REGDIMM_ENABLED true
    } else {
        set_parameter_value CTL_REGDIMM_ENABLED false
    }



    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
        set_parameter_value CTL_ECC_CSR_ENABLED true
    } else {
        set_parameter_value CTL_ECC_CSR_ENABLED false
    }



    if {[get_parameter_value CONTROLLER_LATENCY] < 5} {
        set_parameter_value LOW_LATENCY true
    } else {
        set_parameter_value LOW_LATENCY false
    }


    if {[string compare -nocase [get_parameter_value MEM_TYPE] "ddr2 sdram"] == 0} {
        set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 3
    } else {
        set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 2
    }



    set_parameter_value CTL_TBP_NUM [get_parameter_value CTL_LOOK_AHEAD_DEPTH]



    if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
        set_parameter_value CONTROLLER_TYPE "nextgen_v110"
    } else {
        set_parameter_value CONTROLLER_TYPE "ddrx"
    }



    set mem_trc_ns [expr [get_parameter_value MEM_TRAS_NS] + [get_parameter_value MEM_TRP_NS]]
    set mem_trc_ck [ns_to_tck $mem_trc_ns $mem_clk_ns]
    set_parameter_value MEM_TRC [within $mem_trc_ck 8 40]



    set mem_tras_ck_min 4
    set mem_tras_ck_max 29
    set mem_tras_ns_min [tck_to_ns $mem_tras_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tras_ns_max [tck_to_ns $mem_tras_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tras_ck [ns_to_tck [get_parameter_value MEM_TRAS_NS] $mem_clk_ns]
    if {$mem_tras_ck < $mem_tras_ck_min} { lappend warn_msg 000 }
    if {$mem_tras_ck > $mem_tras_ck_max} { lappend error_msg 001}
    set_parameter_value MEM_TRAS [within $mem_tras_ck $mem_tras_ck_min $mem_tras_ck_max]



    set mem_trcd_ck_min 2
    set mem_trcd_ck_max 11
    set mem_trcd_ns_min [tck_to_ns $mem_trcd_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trcd_ns_max [tck_to_ns $mem_trcd_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trcd_ck [ns_to_tck [get_parameter_value MEM_TRCD_NS] $mem_clk_ns]
    if {$mem_trcd_ck < $mem_trcd_ck_min} { lappend warn_msg 001 }
    if {$mem_trcd_ck > $mem_trcd_ck_max} { lappend error_msg 002 }
    set_parameter_value MEM_TRCD [within $mem_trcd_ck $mem_trcd_ck_min $mem_trcd_ck_max]



    set mem_trp_ck_min 2
    set mem_trp_ck_max 11
    set mem_trp_ns_min [tck_to_ns $mem_trp_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trp_ns_max [tck_to_ns $mem_trp_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trp_ck [ns_to_tck [get_parameter_value MEM_TRP_NS] $mem_clk_ns]
    if {$mem_trp_ck < $mem_trp_ck_min} { lappend warn_msg 002 }
    if {$mem_trp_ck > $mem_trp_ck_max} { lappend error_msg 003 }
    set_parameter_value MEM_TRP [within $mem_trp_ck $mem_trp_ck_min $mem_trp_ck_max]



    set mem_trefi_ck_min 780
    set mem_trefi_ck_max 6240
    set mem_trefi_us_min [expr [tck_to_ns $mem_trefi_ck_min [get_parameter_value MEM_CLK_FREQ] 5] / 1000.0]
    set mem_trefi_us_max [expr [tck_to_ns $mem_trefi_ck_max [get_parameter_value MEM_CLK_FREQ] 5] / 1000.0]
    set mem_trefi_ck [ns_to_tck [expr [get_parameter_value MEM_TREFI_US] * 1000.0] $mem_clk_ns]
    if {$mem_trefi_ck < $mem_trefi_ck_min} { lappend error_msg 004 }
    if {$mem_trefi_ck > $mem_trefi_ck_max} { lappend warn_msg 003 }
    set_parameter_value MEM_TREFI [within $mem_trefi_ck $mem_trefi_ck_min $mem_trefi_ck_max]



    set mem_trfc_ck_min 12
    set mem_trfc_ck_max 255
    set mem_trfc_ns_min [tck_to_ns $mem_trfc_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trfc_ns_max [tck_to_ns $mem_trfc_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trfc_ck [ns_to_tck [get_parameter_value MEM_TRFC_NS] $mem_clk_ns]
    if {$mem_trfc_ck < $mem_trfc_ck_min} { lappend warn_msg 004 }
    if {$mem_trfc_ck > $mem_trfc_ck_max} { lappend error_msg 005 }
    set_parameter_value MEM_TRFC [within $mem_trfc_ck $mem_trfc_ck_min $mem_trfc_ck_max]



    set mem_twr_ck_min 2
    set mem_twr_ck_max 12
    set mem_twr_ns_min [tck_to_ns $mem_twr_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_twr_ns_max [tck_to_ns $mem_twr_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_twr_ck [ns_to_tck [get_parameter_value MEM_TWR_NS] $mem_clk_ns]
    if {$mem_twr_ck < $mem_twr_ck_min} { lappend warn_msg 005 }
    if {$mem_twr_ck > $mem_twr_ck_max} { lappend error_msg 006 }
    set_parameter_value MEM_TWR [within $mem_twr_ck $mem_twr_ck_min $mem_twr_ck_max]



    set mem_tfaw_ck_min 5
    set mem_tfaw_ck_max 32
    set mem_tfaw_ns_min [tck_to_ns $mem_tfaw_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tfaw_ns_max [tck_to_ns $mem_tfaw_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tfaw_ck [ns_to_tck [get_parameter_value MEM_TFAW_NS] $mem_clk_ns]
    if {$mem_tfaw_ck < $mem_tfaw_ck_min} { lappend warn_msg 006 }
    if {$mem_tfaw_ck > $mem_tfaw_ck_max} { lappend error_msg 007 }
    set_parameter_value MEM_TFAW [within $mem_tfaw_ck $mem_tfaw_ck_min $mem_tfaw_ck_max]



    set mem_trrd_ck_min 2
    set mem_trrd_ck_max 8
    set mem_trrd_ns_min [tck_to_ns $mem_trrd_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trrd_ns_max [tck_to_ns $mem_trrd_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trrd_ck [ns_to_tck [get_parameter_value MEM_TRRD_NS] $mem_clk_ns]
    if {$mem_trrd_ck < $mem_trrd_ck_min} { lappend warn_msg 007 }
    if {$mem_trrd_ck > $mem_trrd_ck_max} { lappend error_msg 008 }
    set_parameter_value MEM_TRRD [within $mem_trrd_ck $mem_trrd_ck_min $mem_trrd_ck_max]



    set mem_trtp_ck_min 2
    set mem_trtp_ck_max 8
    set mem_trtp_ns_min [tck_to_ns $mem_trtp_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trtp_ns_max [tck_to_ns $mem_trtp_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trtp_ck [ns_to_tck [get_parameter_value MEM_TRTP_NS] $mem_clk_ns]
    if {$mem_trtp_ck < $mem_trtp_ck_min} { lappend warn_msg 008 }
    if {$mem_trtp_ck > $mem_trtp_ck_max} { lappend error_msg 009 }
    set_parameter_value MEM_TRTP [within $mem_trtp_ck $mem_trtp_ck_min $mem_trtp_ck_max]




    if {([string compare -nocase [get_parameter_value RATE] "full"] == 0) && ([string compare -nocase [get_parameter_value MEM_TYPE] "ddr3 sdram"] == 0) && ([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0)} {
        lappend error_msg 010
    }

    if {([string compare -nocase [get_parameter_value RATE] "full"] != 0) && ([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0)} {
        lappend error_msg 011
    }

    if {([string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "false"] == 0) && ([get_parameter_value MEM_AUTO_PD_CYCLES] != [get_parameter_property MEM_AUTO_PD_CYCLES DEFAULT_VALUE])} {
        lappend error_msg 012
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([get_parameter_value ADDR_ORDER] == 2)} {
        lappend error_msg 013
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([get_parameter_value CTL_LOOK_AHEAD_DEPTH] > [get_parameter_property CTL_LOOK_AHEAD_DEPTH DEFAULT_VALUE])} {
        lappend warn_msg 009
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE])} {
        lappend error_msg 014
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]) && ([get_parameter_value MEM_CLK_FREQ] > $max_freq_for_reduce_latency)} {
            lappend error_msg 015
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]) && ([get_parameter_value MEM_CLK_FREQ] <= $max_freq_for_reduce_latency)} {
            lappend warn_msg 010
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0)} {
        lappend error_msg 016
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0) && ([get_parameter_value CFG_STARVE_LIMIT] > [get_parameter_property CFG_STARVE_LIMIT DEFAULT_VALUE])} {
        lappend warn_msg 011
    }

    if {([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "false"] == 0) && ([get_parameter_value CFG_STARVE_LIMIT] != [get_parameter_property CFG_STARVE_LIMIT DEFAULT_VALUE])} {
        lappend error_msg 017
    }

    if {([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "false"] == 0) && ([string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] [get_parameter_property CTL_CSR_CONNECTION DEFAULT_VALUE]] != 0)} {
        lappend error_msg 018
    }

    if {([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0) && ([string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "export"] == 0)} {
        lappend warn_msg 012
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) && ($invalid_interface_width == 1)} {
        lappend error_msg 019
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) && ($invalid_interface_width == 1)} {
        lappend error_msg 020
    }

    if {([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) && ([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "false"] == 0)} {
        lappend error_msg 021
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) && ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE])} {
        lappend error_msg 022
    }

    if {([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0) && ([string compare -nocase [get_parameter_value CTL_ECC_AUTO_CORRECTION_ENABLED] "true"] == 0)} {
        lappend error_msg 023
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0)} {
        lappend error_msg 024
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0) && ([get_parameter_value MEM_CS_WIDTH] == 1) && ([string compare -nocase [get_parameter_value MEM_FORMAT] "discrete"] == 0)} {
        lappend error_msg 025
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) && ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0) && ([get_parameter_value MEM_CS_WIDTH] == 1) && ([string compare -nocase [get_parameter_value MEM_FORMAT] "discrete"] != 0)} {
        lappend error_msg 026
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "true"] == 0)} {
        lappend error_msg 027
    }

    if {([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "false"] == 0) && ([get_parameter_value CTL_DYNAMIC_BANK_NUM] != [get_parameter_property CTL_DYNAMIC_BANK_NUM DEFAULT_VALUE])} {
        lappend error_msg 028
    }

    if {([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "true"] == 0) && (([get_parameter_value CTL_DYNAMIC_BANK_NUM] < $min_dynamic_bank_num) || ([get_parameter_value CTL_DYNAMIC_BANK_NUM] > $max_dynamic_bank_num))} {
        lappend error_msg 029
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0)} {
        lappend warn_msg 013
    }

    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        if {([string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "true"] == 0) && ([string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "true"] == 0)} {
            lappend error_msg 030
        } elseif {([string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "false"] == 0) && ([string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "false"] == 0)} {
            lappend warn_msg 014
        } elseif {[string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "true"] ==0} {
            lappend error_msg 031
        }
    }

    if {$::display_all_massage} {
        for {set id 0} {$id < 35} {incr id} {
            lappend warn_msg [format "%03d" $id]
            lappend error_msg [format "%03d" $id]
        }
    }



    if { [lsearch $warn_msg 000] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRAS_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRAS_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_tras_ns_min ns."
    }

    if { [lsearch $warn_msg 001] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRCD_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRCD_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trcd_ns_min ns."
    }

    if { [lsearch $warn_msg 002] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRP_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRP_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trp_ns_min ns."
    }

    if { [lsearch $warn_msg 003] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TREFI_US DISPLAY_NAME]' requirement of [get_parameter_value MEM_TREFI_US] us. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trefi_us_max us."
    }

    if { [lsearch $warn_msg 004] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRFC_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRFC_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trfc_ns_min ns."
    }

    if { [lsearch $warn_msg 005] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TWR_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_twr_ns_min ns."
    }

    if { [lsearch $warn_msg 006] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TFAW_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TFAW_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_tfaw_ns_min ns."
    }

    if { [lsearch $warn_msg 007] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRRD_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRRD_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trrd_ns_min ns."
    }

    if { [lsearch $warn_msg 008] != -1 } {
        send_message WARNING "Cannot meet '[get_parameter_property MEM_TRTP_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRTP_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trtp_ns_min ns."
    }

    if { [lsearch $warn_msg 012] != -1 } {
        send_message WARNING "CSR port can only be connected to debug GUI when using a CSR port connection with an internally connected JTAG Avalon Master."
    }

    if { [lsearch $warn_msg 014] != -1 } {
        send_message WARNING "Current example driver only support Avalon-MM interface."
    }

    if { [lsearch $warn_msg 010] != -1 } {
        send_message WARNING "Timing closure may not be achievable at maximum frequency for '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value greater than [string map {5 0 4 1} [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]]."
    }

    if { [lsearch $warn_msg 009] != -1 } {
        send_message WARNING "Timing closure may not be achievable at maximum frequency for '[get_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME]' value greater than [get_parameter_property CTL_LOOK_AHEAD_DEPTH DEFAULT_VALUE]."
    }

    if { [lsearch $warn_msg 011] != -1 } {
        send_message WARNING "Timing closure may not be achievable at maximum frequency for '[get_parameter_property CFG_STARVE_LIMIT DISPLAY_NAME]' value that is greater than [get_parameter_property CFG_STARVE_LIMIT DEFAULT_VALUE]."
    }

    if { [lsearch $warn_msg 013] != -1 } {
        send_message WARNING "This design uses the previous memory controller architecture of [get_module_property DISPLAY_NAME]. Altera recommends you to create a new variation of [get_module_property DISPLAY_NAME] to get the new memory controller architecture."
    }



    if { [lsearch $error_msg 000] != -1 } {
        send_message ERROR "Unknown '[get_parameter_property MEM_ATCL DISPLAY_NAME]' value of [get_parameter_value MEM_ATCL]"
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 001] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRAS_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRAS_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_tras_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 002] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRCD_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRCD_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trcd_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 003] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRP_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRP_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trp_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 004] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TREFI_US DISPLAY_NAME]' requirement of [get_parameter_value MEM_TREFI_US] us. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the minimum is $mem_trefi_us_min us."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 005] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRFC_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRFC_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trfc_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 006] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TWR_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_twr_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 007] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TFAW_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TFAW_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_tfaw_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 008] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRRD_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRRD_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trrd_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 009] != -1 } {
        send_message ERROR "Cannot meet '[get_parameter_property MEM_TRTP_NS DISPLAY_NAME]' requirement of [get_parameter_value MEM_TRTP_NS] ns. For a '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' of [get_parameter_value MEM_CLK_FREQ] MHz, the maximum is $mem_trtp_ns_max ns."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 010] != -1 } {
        send_message ERROR "DDR3 SDRAM is not supported at full rate by [get_parameter_value DEVICE_FAMILY] devices."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 011] != -1 } {
        send_message ERROR "The '[get_parameter_property CTL_HRB_ENABLED DISPLAY_NAME]' checkbox is only applicable for full rate."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 012] != -1 } {
        send_message ERROR "The value for '[get_parameter_property MEM_AUTO_PD_CYCLES DISPLAY_NAME]' is only valid when '[get_parameter_property AUTO_POWERDN_EN DISPLAY_NAME]' checkbox is checked."
    }

    if { [lsearch $error_msg 013] != -1 } {
        send_message ERROR "The '[get_parameter_property ADDR_ORDER DISPLAY_NAME]' value of [string map {0 CHIP-ROW-BANK-COL 1 CHIP-BANK-ROW-COL 2 ROW-CHIP-BANK-COL} [get_parameter_value ADDR_ORDER]] is only supported in the new memory controller architecture."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 014] != -1 } {
        send_message ERROR "The value for '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' is only valid in the previous memory controller architecture."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 015] != -1 } {
        send_message ERROR "The '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value of [string map {5 0 4 1} [get_parameter_value CONTROLLER_LATENCY]] is only supported for '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' that is less than $max_freq_for_reduce_latency MHz."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 016] != -1 } {
        send_message ERROR "The '[get_parameter_property CFG_REORDER_DATA DISPLAY_NAME]' checkbox is only applicable in the new memory controller architecture."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 017] != -1 } {
        send_message ERROR "The value for '[get_parameter_property CFG_STARVE_LIMIT DISPLAY_NAME]' is only valid when '[get_parameter_property CFG_REORDER_DATA DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 018] != -1 } {
        send_message ERROR "The value for '[get_parameter_property CTL_CSR_CONNECTION DISPLAY_NAME]' is only valid when '[get_parameter_property CTL_CSR_ENABLED DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 019] != -1 } {
        send_message ERROR "The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value that is a multiple of 16, 24, 40 or 72 bits is required when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 020] != -1 } {
        send_message ERROR "The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value that is a multiple of 40 or 72 bits is required when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 021] != -1 } {
        send_message ERROR "The '[get_parameter_property CTL_CSR_ENABLED DISPLAY_NAME]' checkbox must be checked to access ECC status bits."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 022] != -1 } {
        send_message ERROR "The '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value of [string map {5 0 4 1} [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]] is required when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 023] != -1 } {
        send_message ERROR "The '[get_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME]' checkbox is only applicable when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 024] != -1 } {
        send_message ERROR "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable in the previous memory controller architecture."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 025] != -1 } {
        send_message ERROR "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable when there is more than 1 memory chip selects. To change the number of memory chip selects, modify the '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' value."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 026] != -1 } {
        send_message ERROR "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable when there is more than 1 memory chip selects. To change the number of memory chip selects, modify the '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' value."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 027] != -1 } {
        send_message ERROR "The '[get_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME]' checkbox is only applicable in the previous memory controller architecture."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 028] != -1 } {
        send_message ERROR "The value for '[get_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME]' is only valid when '[get_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME]' checkbox is checked."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 029] != -1 } {
        send_message ERROR "The '[get_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME]' value of [get_parameter_value CTL_DYNAMIC_BANK_NUM] is not supported. For a '[get_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME]' of [get_parameter_value CTL_LOOK_AHEAD_DEPTH], the minimum is $min_dynamic_bank_num and maximum is $max_dynamic_bank_num."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 030] != -1 } {
        send_message ERROR "Only 1 type of adaptor can be instantiate."
        set_parameter_value MODULE_VALID false
    }

    if { [lsearch $error_msg 031] != -1 } {
        send_message ERROR "Current example driver only support Avalon-MM interface."
        set_parameter_value MODULE_VALID false
    }

}


proc elaborate_controller {} {



    if {([string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "false"] == 0)} {
        set_parameter_property MEM_AUTO_PD_CYCLES Enabled false
    } else {
        set_parameter_property MEM_AUTO_PD_CYCLES Enabled true
    }

    if {[string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "false"] == 0} {
        set_parameter_property CTL_DYNAMIC_BANK_NUM Enabled false
    } else {
        set_parameter_property CTL_DYNAMIC_BANK_NUM Enabled true
    }

    if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "false"] == 0} {
        set_parameter_property CTL_CSR_CONNECTION Enabled false
    } else {
        set_parameter_property CTL_CSR_CONNECTION Enabled true
    }

    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0} {
        set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED Enabled false
    } else {
        set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED Enabled true
    }

    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        set_parameter_property CONTROLLER_LATENCY Enabled false
        set_parameter_property MULTICAST_EN Enabled false
        set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION Enabled false
        set_parameter_property CFG_REORDER_DATA Enabled true
    } else {
        set_parameter_property CONTROLLER_LATENCY Enabled true
        set_parameter_property MULTICAST_EN Enabled true
        set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION Enabled true
        set_parameter_property CFG_REORDER_DATA Enabled false
    }

    if {[string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0} {
        set_parameter_property CFG_STARVE_LIMIT Enabled true
    } else {
        set_parameter_property CFG_STARVE_LIMIT Enabled false
    }


    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        set_parameter_property ADDR_ORDER ALLOWED_RANGES {0:CHIP-ROW-BANK-COL 1:CHIP-BANK-ROW-COL 2:ROW-CHIP-BANK-COL}
        set_parameter_property CTL_LOOK_AHEAD_DEPTH ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
    } else {
        set_parameter_property ADDR_ORDER ALLOWED_RANGES {0:CHIP-ROW-BANK-COL 1:CHIP-BANK-ROW-COL}
        set_parameter_property CTL_LOOK_AHEAD_DEPTH ALLOWED_RANGES {0 2 4 6 8}
    }
}


proc generate_controller { outputname } {
    if {[string compare -nocase [get_parameter_value MODULE_VALID] "false"] == 0} {
        send_message ERROR "Contains invalid parameter values. Cannot generate HDL."
    } else {

        set debug 0
        if {[get_parameter_value DEBUG_MODE]} {set debug 1}

        regsub \ SDRAM [get_parameter_value MEM_TYPE] {} memtype_short


        set param_str "MEM_TYPE=${memtype_short}"

        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
            append param_str ",CTL_ECC_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
            append param_str ",CTL_HRB_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_ECC_AUTO_CORRECTION_ENABLED] "true"] == 0} {
            append param_str ",CTL_ECC_AUTO_CORRECTION_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_ECC_CSR_ENABLED] "true"] == 0} {
            append param_str ",CTL_CSR_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
            append param_str ",CTL_CSR_ENABLED"
            if {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "export"] == 0} {
                append param_str ",EXPORT_CSR_PORT"
            }
        }

        if {[string compare -nocase [get_parameter_value CTL_ODT_ENABLED] "true"] == 0} {
            append param_str ",CTL_ODT_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_REGDIMM_ENABLED] "true"] == 0} {
            append param_str ",CTL_REGDIMM_ENABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_OUTPUT_REGD] "true"] == 0} {
            append param_str ",CTL_OUTPUT_REGD"
        }

        if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
            append param_str ",CTL_USR_REFRESH_EN"
        }

        if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
            append param_str ",CTL_AUTOPCH_EN"
        }

        if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
            set ctl_self_refresh_en 1
            append param_str ",CTL_SELF_REFRESH_EN"
        }

        if {[string compare -nocase [get_parameter_value LOW_LATENCY] "true"] == 0} {
            append param_str ",LOW_LATENCY"
        }

        if {[string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "true"] == 0} {
            append param_str ",CTL_DYNAMIC_BANK_ALLOCATION"
        }

        if {[string compare -nocase [get_parameter_value ENABLE_BURST_MERGE] "true"] == 0} {
            append param_str ",ENABLE_BURST_MERGE"
        }

        if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
            append param_str ",MULTICAST_EN"
        }

        if {[string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0} {
            append param_str ",CFG_REORDER_DATA"
        }

        if {[get_parameter_value MEM_ADDR_WIDTH] < 16 } {
            append param_str ",MEM_ADDRESS_LESS_THAN_16"
        }

        if {[get_parameter_value MEM_CS_PER_DIMM] / [get_parameter_value MEM_CS_PER_RANK] == 1} {
            append param_str ",RANK_PER_SLOT_1"
        }

        if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
            append param_str ",NEXTGEN"
        }

        if {[string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "true"] == 0} {
            append param_str ",USE_MM_INTERFACE"
        }


        append param_str ",MOD_NAME=${outputname}"
        append param_str ",LOCAL_ADDR_WIDTH=[get_parameter_value LOCAL_ADDR_WIDTH]"
        append param_str ",LOCAL_DATA_WIDTH=[get_parameter_value LOCAL_DATA_WIDTH]"
        append param_str ",MEM_IF_CS_WIDTH=[get_parameter_value MEM_CS_WIDTH]"
        append param_str ",MEM_IF_CHIP_BITS=[get_parameter_value MEM_IF_CHIP_BITS]"
        append param_str ",MEM_IF_ADDR_WIDTH=[get_parameter_value MEM_ADDR_WIDTH]"
        append param_str ",MEM_IF_ROW_WIDTH=[get_parameter_value MEM_ROW_ADDR_WIDTH]"
        append param_str ",MEM_IF_COL_WIDTH=[get_parameter_value MEM_COL_ADDR_WIDTH]"
        append param_str ",MEM_IF_BA_WIDTH=[get_parameter_value MEM_BANKADDR_WIDTH]"
        append param_str ",MEM_IF_DQS_WIDTH=[get_parameter_value MEM_IF_DQS_WIDTH]"
        append param_str ",MEM_IF_DQ_WIDTH=[get_parameter_value MEM_DQ_WIDTH]"
        append param_str ",MEM_IF_DM_WIDTH=[get_parameter_value MEM_DM_WIDTH]"
        append param_str ",MEM_IF_CLK_PAIR_COUNT=[get_parameter_value MEM_CK_WIDTH]"
        append param_str ",MEM_IF_CS_PER_DIMM=[get_parameter_value MEM_CS_PER_DIMM]"
        append param_str ",DWIDTH_RATIO=[get_parameter_value DWIDTH_RATIO]"
        append param_str ",CTL_LOOK_AHEAD_DEPTH=[get_parameter_value CTL_LOOK_AHEAD_DEPTH]"
        append param_str ",CTL_ECC_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_ECC_ENABLED]]"
        append param_str ",CTL_HRB_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_HRB_ENABLED]]"
        append param_str ",CTL_ECC_AUTO_CORRECTION_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_ECC_AUTO_CORRECTION_ENABLED]]"
        append param_str ",CTL_ECC_CSR_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_ECC_CSR_ENABLED]]"
        append param_str ",CTL_ECC_MULTIPLES_40_72=[get_parameter_value CTL_ECC_MULTIPLES_40_72]"
        append param_str ",CTL_CSR_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_CSR_ENABLED]]"
        append param_str ",CTL_CSR_READ_ONLY=1"
        append param_str ",CTL_ODT_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_ODT_ENABLED]]"
        append param_str ",CTL_REGDIMM_ENABLED=[string map -nocase {false 0 true 1} [get_parameter_value CTL_REGDIMM_ENABLED]]"
        append param_str ",CTL_OUTPUT_REGD=[string map -nocase {false 0 true 1} [get_parameter_value CTL_OUTPUT_REGD]]"
        append param_str ",CTL_USR_REFRESH_EN=[string map -nocase {false 0 true 1} [get_parameter_value CTL_USR_REFRESH_EN]]"
        append param_str ",MEM_TRRD=[get_parameter_value MEM_TRRD]"
        append param_str ",MEM_TFAW=[get_parameter_value MEM_TFAW]"
        append param_str ",MEM_TRFC=[get_parameter_value MEM_TRFC]"
        append param_str ",MEM_TREFI=[get_parameter_value MEM_TREFI]"
        append param_str ",MEM_TRP=[get_parameter_value MEM_TRP]"
        append param_str ",MEM_TWR=[get_parameter_value MEM_TWR]"
        append param_str ",MEM_TRTP=[get_parameter_value MEM_TRTP]"
        append param_str ",MEM_TRAS=[get_parameter_value MEM_TRAS]"
        append param_str ",MEM_TRC=[get_parameter_value MEM_TRC]"
        append param_str ",MEM_CK_TRCD=[get_parameter_value MEM_TRCD]"
        append param_str ",MEM_AUTO_PD_CYCLES=[get_parameter_value MEM_AUTO_PD_CYCLES]"
        append param_str ",MEM_IF_RD_TO_WR_TURNAROUND_OCT=[get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]"
        append param_str ",ADDR_ORDER=[get_parameter_value ADDR_ORDER]"
        append param_str ",MEM_IF_DQSN_EN=0"
        append param_str ",CTL_AUTOPCH_EN=[string map -nocase {false 0 true 1} [get_parameter_value CTL_AUTOPCH_EN]]"
        append param_str ",CTL_SELF_REFRESH_EN=[string map -nocase {false 0 true 1} [get_parameter_value CTL_SELF_REFRESH_EN]]"
        append param_str ",MEM_IF_CS_PER_RANK=[get_parameter_value MEM_CS_PER_RANK]"
        append param_str ",PLL_REF_CLK_MHZ=[get_parameter_value REF_CLK_FREQ]"
        append param_str ",MEM_CLK_MHZ=[get_parameter_value MEM_CLK_FREQ]"
        append param_str ",MEM_IF_DQ_PER_DQS=[get_parameter_value MEM_DQ_PER_DQS]"
        append param_str ",LOW_LATENCY=[string map -nocase {false 0 true 1} [get_parameter_value LOW_LATENCY]]"
        append param_str ",CTL_DYNAMIC_BANK_ALLOCATION=[string map -nocase {false 0 true 1} [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION]]"
        append param_str ",CTL_DYNAMIC_BANK_NUM=[get_parameter_value CTL_DYNAMIC_BANK_NUM]"
        append param_str ",ENABLE_BURST_MERGE=[string map -nocase {false 0 true 1} [get_parameter_value ENABLE_BURST_MERGE]]"
        append param_str ",MULTICAST_EN=[string map -nocase {false 0 true 1} [get_parameter_value MULTICAST_EN]]"
        append param_str ",LOCAL_ID_WIDTH=[get_parameter_value LOCAL_ID_WIDTH]"
        append param_str ",CTL_TBP_NUM=[get_parameter_value CTL_TBP_NUM]"
        append param_str ",RDBUFFER_ADDR_WIDTH=[get_parameter_value RDBUFFER_ADDR_WIDTH]"
        append param_str ",WRBUFFER_ADDR_WIDTH=[get_parameter_value WRBUFFER_ADDR_WIDTH]"
        append param_str ",CFG_REORDER_DATA=[string map -nocase {false 0 true 1} [get_parameter_value CFG_REORDER_DATA]]"
        append param_str ",CFG_STARVE_LIMIT=[get_parameter_value CFG_STARVE_LIMIT]"

        return $param_str

    }
}




