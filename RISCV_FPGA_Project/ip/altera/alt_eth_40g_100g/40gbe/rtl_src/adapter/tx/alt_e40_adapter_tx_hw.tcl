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
#| alt_e40_adapter_tx
#|
#+-----------------------------

# +-----------------------------------
# | request TCL package from QSYS 13.0
# | 
package require -exact qsys 13.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module alt_e40_adapter_tx
# | 
set_module_property NAME alt_e40_adapter_tx
set_module_property VERSION 13.0
set_module_property AUTHOR "Altera Corporation"
#set_module_property INTERNAL true
set_module_property DESCRIPTION "Altera 40G Ethernet Adapter TX module"
set_module_property GROUP "Interface Protocols/High Speed"
set_module_property DISPLAY_NAME "alt_e40_adapter_tx"
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
set_fileset_property synth TOP_LEVEL alt_e40_adapter_tx
add_fileset sim_vhdl SIM_VHDL sim_proc_vhdl
set_fileset_property sim_vhdl TOP_LEVEL alt_e40_adapter_tx
add_fileset sim SIM_VERILOG sim_proc_v
set_fileset_property sim TOP_LEVEL alt_e40_adapter_tx
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
#|  define avalon-related interfaces
#|
add_interface         avalon_streaming_tx     avalon_streaming    sink
add_interface_port    avalon_streaming_tx     l4_tx_data     data   Input    256
add_interface_port    avalon_streaming_tx     l4_tx_empty    empty   Input    5
add_interface_port    avalon_streaming_tx     l4_tx_startofpacket   startofpacket   Input    1
add_interface_port    avalon_streaming_tx     l4_tx_endofpacket     endofpacket     Input    1
add_interface_port    avalon_streaming_tx     l4_tx_ready      ready     Output    1
add_interface_port    avalon_streaming_tx     l4_tx_valid      valid     Input    1
add_interface		  mac_tx_arst_sync_core	  reset     sink
add_interface_port    mac_tx_arst_sync_core	  mac_tx_arst_sync_core reset 		Input 	1
set_interface_property  mac_tx_arst_sync_core  synchronousEdges     NONE
# MAC + PCS clock, at least 312.5 MHz
add_interface         clk_txmac     clock      end
add_interface_port    clk_txmac     clk_txmac    clk  Input    1 
set_interface_property  avalon_streaming_tx     ASSOCIATED_CLOCK    clk_txmac
set_interface_property  avalon_streaming_tx     associatedReset     mac_tx_arst_sync_core
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
    set device_family   [get_parameter_value    DEVICE_FAMILY]
    # 5 lane payload
    add_interface         tx2l_d     conduit      end
    add_interface_port    tx2l_d     tx2l_d    export  Output    [expr ($words * 64)]
    add_interface         tx2l_sop     conduit      end
    add_interface_port    tx2l_sop     tx2l_sop    export  Output    [expr ($words * 1)]
    add_interface         tx2l_eop_bm     conduit      end
    add_interface_port    tx2l_eop_bm     tx2l_eop_bm    export  Output  [expr ($words * 8)]
    add_interface         tx2l_ack       conduit      end
    add_interface_port    tx2l_ack        tx2l_ack    export  Input    1

}


# +-------------------------------
# |SYNTH PROC
# |

proc synth_proc { outputName } {
	set folder_path				  "../../../../40gbe/"
	set synth_dir_lst {"rtl_src/adapter/tx"}
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
	
	set sim_dir_lst { "rtl_src/adapter/tx"}
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
        set sim_dir_lst_mentor { "rtl_src/adapter/tx"}
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









