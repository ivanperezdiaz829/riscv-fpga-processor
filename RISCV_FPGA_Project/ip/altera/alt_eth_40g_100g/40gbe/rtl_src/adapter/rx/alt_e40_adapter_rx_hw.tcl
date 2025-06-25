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
#| alt_e40_adapter_rx
#|
#+-----------------------------

# +-----------------------------------
# | request TCL package from QSYS 13.0
# | 
package require -exact qsys 13.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module alt_e40_adapter_rx
# | 
set_module_property NAME alt_e40_adapter_rx
set_module_property VERSION 13.0
set_module_property AUTHOR "Altera Corporation"
#set_module_property INTERNAL true
set_module_property DESCRIPTION "Altera 40G Ethernet Adapter RX module"
set_module_property GROUP "Interface Protocols/High Speed"
set_module_property DISPLAY_NAME "alt_e40_adapter_rx"
set_module_property EDITABLE true
set_module_property INTERNAL true
set_module_property ANALYZE_HDL true
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
# | 
# +-----------------------------------

# +-----------------------------------
# | define fileset procs
# |
add_fileset synth QUARTUS_SYNTH synth_proc
set_fileset_property synth TOP_LEVEL alt_e40_adapter_rx
add_fileset sim_vhdl SIM_VHDL sim_proc_vhdl
set_fileset_property sim_vhdl TOP_LEVEL alt_e40_adapter_rx
add_fileset sim SIM_VERILOG sim_proc_v
set_fileset_property sim TOP_LEVEL alt_e40_adapter_rx
# | 
# +-----------------------------------

#+-----------------------------------
#| display tabs
#| 
#add_display_item "" "General" GROUP


#+-----------------------------------
#| parameters
#|
add_parameter DEVICE_FAMILY STRING "Stratix V"
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device family"
set_parameter_property DEVICE_FAMILY AFFECTS_ELABORATION true
set_parameter_property DEVICE_FAMILY AFFECTS_GENERATION true
set_parameter_property DEVICE_FAMILY IS_HDL_PARAMETER true
set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
add_display_item "General Design Options" DEVICE_FAMILY PARAMETER
# | 
# +-----------------------------------


#+-----------------------------------
#|  reset signal
#|
add_interface         mac_rx_arst_sync_core   reset     sink
add_interface_port    mac_rx_arst_sync_core   mac_rx_arst_sync_core reset       Input   1
set_interface_property  mac_rx_arst_sync_core  synchronousEdges     NONE
# | 
# +-----------------------------------


#+-------------------------------
#| VALIDATE CALLBACK
#|
proc validation_callback {} {
	
}

# +-------------------------------
# |ELABORATE CALLBACK
# |
proc elaboration_callback {} {
    set words 2
    set device_family [get_parameter_value DEVICE_FAMILY]

    # define static interfaces ##
    add_interface         avalon_streaming_rx     avalon_streaming   source
    #add_interface         avalon_streaming_rx_fcs   avalon_streaming    source
    add_interface          l4_rx_fcs  conduit     end
    add_interface_port    avalon_streaming_rx     l4_rx_data     data   Output 256   
    add_interface_port    avalon_streaming_rx     l4_rx_empty    empty   Output    5
    add_interface_port    avalon_streaming_rx     l4_rx_startofpacket   startofpacket   Output    1
    add_interface_port    avalon_streaming_rx     l4_rx_endofpacket     endofpacket   Output    1
    add_interface_port    avalon_streaming_rx     l4_rx_error      error     Output    1
    add_interface_port    avalon_streaming_rx     l4_rx_valid      valid     Output    1
    add_interface_port    l4_rx_fcs     l4_rx_fcs_valid  valid     Output    1
    add_interface_port    l4_rx_fcs     l4_rx_fcs_error  error     Output    1
    # MAC + PCS clock, at least 312.5 MHz
    add_interface         clk_rxmac     clock      end
    add_interface_port    clk_rxmac     clk_rxmac    clk  Input    1  
    set_interface_property  avalon_streaming_rx     ASSOCIATED_CLOCK    clk_rxmac   
    set_interface_property  avalon_streaming_rx     associatedReset     mac_rx_arst_sync_core
    # end define static interfaces
    # 5 lane payload
    add_interface         rx2l_d     conduit      end
    add_interface_port    rx2l_d     rx2l_d    export  Input    [expr ($words * 64)]
    add_interface         rx2l_sop     conduit      end
    add_interface_port    rx2l_sop     rx2l_sop    export  Input    [expr ($words * 1)]
    add_interface         rx2l_eop_bm     conduit      end
    add_interface_port    rx2l_eop_bm     rx2l_eop_bm    export  Input  [expr ($words * 8)]
    add_interface         rx2l_valid     conduit      end
    add_interface_port    rx2l_valid   rx2l_valid    export  Input    1
    add_interface         rx2l_runt_last_data     conduit      end
    add_interface_port    rx2l_runt_last_data     rx2l_runt_last_data    export  Input    [expr ($words * 1)]
    add_interface         rx2l_payload     conduit      end
    add_interface_port    rx2l_payload     rx2l_payload    export  Input    [expr ($words * 1)]
    add_interface         rx2l_fcs_valid     conduit      end
    add_interface_port    rx2l_fcs_valid        rx2l_fcs_valid    export  Input    1
    add_interface         rx2l_fcs_error     conduit      end
    add_interface_port    rx2l_fcs_error           rx2l_fcs_error    export  Input    1
}


# +-------------------------------
# |SYNTH PROC
# |

proc synth_proc { outputName } {
	set folder_path				  "../../../../40gbe/"
	set synth_dir_lst {"rtl_src/adapter/rx"}
    set dest_path       "./"

    foreach synth_dir $synth_dir_lst {
        set file_lst [glob -nocomplain -- -path $folder_path$synth_dir/*]
        foreach file ${file_lst} {   
            set     is_dir  [file isdirectory $file]
            set     is_tcl  [regexp {tcl} $file]
            if {$is_dir == 1} {
                #send_message INFO "Ignoring $file for synth"
            } elseif {$is_tcl == 1} {
                #send_message INFO "Ignoring $file for synth"
            } else {
                set file_string [split $file /]
                set file_name [lindex $file_string end]
                add_fileset_file "$dest_path$synth_dir/$file_name" VERILOG PATH ${file} 
            }
        }
    }
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


proc sim_proc {outputName {sim_v 1} } {
	set folder_path				  "../../../../40gbe/"
	
	set sim_dir_lst { "rtl_src/adapter/rx"}
    set dest_path_sy               "./synopsys/"
    set dest_path_ca                "./cadence/"
    set dest_path_me                "./mentor/"	
    set dest_path_ald                "./aldec/"	
	foreach sim_dir $sim_dir_lst {
        set file_lst [glob -nocomplain -- -path $folder_path$sim_dir/*]
        foreach file ${file_lst} {   
            set     is_dir  [file isdirectory $file]
            set     is_tcl  [regexp {tcl} $file]
            if {$is_dir == 1} {
                #send_message INFO "Ignoring $file for synth"
            } elseif {$is_tcl == 1} {
                #send_message INFO "Ignoring $file for synth"
            } else {
                set file_string [split $file /]
                set file_name [lindex $file_string end]
                add_fileset_file "$dest_path_sy$sim_dir/$file_name" VERILOG PATH ${file} SYNOPSYS_SPECIFIC
                add_fileset_file "$dest_path_ca$sim_dir/$file_name" VERILOG PATH ${file} CADENCE_SPECIFIC
                add_fileset_file "$dest_path_ald$sim_dir/$file_name" VERILOG PATH ${file} ALDEC_SPECIFIC
                if {$sim_v} {
                    add_fileset_file "$dest_path_me$sim_dir/$file_name" VERILOG PATH ${file} MENTOR_SPECIFIC
                }
            }
        }
    }

    if {$sim_v == 0} {
        set sim_dir_lst_mentor { "rtl_src/adapter/rx"}
        set dest_path_me                "./mentor/"
        foreach sim_dir $sim_dir_lst_mentor {
            set file_lst [glob -nocomplain -- -path $folder_path$sim_dir/mentor/*]
            foreach file ${file_lst} {   
                set     is_dir  [file isdirectory $file]
                if {$is_dir == 1} {
                    #send_message INFO "Ignoring $file for synth"
                } else {
                    set file_string [split $file /]
                    set file_name [lindex $file_string end]
                    add_fileset_file "$dest_path_me$sim_dir/$file_name" VERILOG PATH ${file} MENTOR_SPECIFIC
                }
            }
        }
    }
}









