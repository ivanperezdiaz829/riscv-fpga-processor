# TCL File for Altera Avalon Packets to Master component 
#
# Has hidden parameter for exporting master signals.  Off by default, the
# component will have 2 Avalon ST interfaces, and an Avalon Master.  When the
# hidden switch is turned on, the Avalon Master signals will be pushed to the
# top level as conduits.  This allows for repackaging the entire JTAG chain as
# the altera_avalon_jtag_master component with these conduits being used as the
# Avalon Master at that level.
#
# The elaboration callback is used to accomplish this switch.
#
# Has hidden parameter for setting FIFO depths. Set to 2 by default.
# Has hidden parameter to let user decide whether to use economy/fast transaction master

package require -exact sopc 9.1

set_module_property DESCRIPTION "Avalon Packets to Transaction Converter"
set_module_property NAME altera_avalon_packets_to_master
set_module_property VERSION 13.1
set_module_property GROUP "Bridges and Adapters/Streaming"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME  "Avalon Packets to Transaction Converter"
set_module_property DATASHEET_URL "http://www.altera.com/literature/hb/nios2/qts_qii55013.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_packets_to_master.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_packets_to_master
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
set_module_property EDITABLE false 
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

add_file altera_avalon_packets_to_master.v {SYNTHESIS SIMULATION}

# Module parameters
add_parameter           EXPORT_MASTER_SIGNALS "INTEGER" "0" ""
set_parameter_property  EXPORT_MASTER_SIGNALS "VISIBLE" false
add_parameter           FAST_VER              "INTEGER" "0" ""
set_parameter_property  FAST_VER              "VISIBLE" true
set_parameter_property  FAST_VER              "HDL_PARAMETER" true
set_parameter_property  FAST_VER              "DISPLAY_NAME" "Enhanced transaction master"
set_parameter_property  FAST_VER              "DESCRIPTION"  "Increase transaction master throughput"
set_parameter_property  FAST_VER              "DISPLAY_HINT" "boolean"
set_parameter_property  FAST_VER              "STATUS" experimental
add_parameter           FIFO_DEPTHS           "INTEGER" "2" ""
set_parameter_property  FIFO_DEPTHS           "VISIBLE" true
set_parameter_property  FIFO_DEPTHS           "HDL_PARAMETER" true
set_parameter_property  FIFO_DEPTHS           "ALLOWED_RANGES" "2:8192"
set_parameter_property  FIFO_DEPTHS           "DISPLAY_NAME" "FIFO depth"
set_parameter_property  FIFO_DEPTHS           "DESCRIPTION"  "User need to tweak this to find the sweet spot"
set_parameter_property  FIFO_DEPTHS           "STATUS" experimental
add_parameter           FIFO_WIDTHU           "INTEGER" "1" ""
set_parameter_property  FIFO_WIDTHU           "DERIVED" true
set_parameter_property  FIFO_WIDTHU           "VISIBLE" false
set_parameter_property  FIFO_WIDTHU           "HDL_PARAMETER" true
#add_parameter           SHOW_HIDDEN           "BOOLEAN" false
#set_parameter_property  SHOW_HIDDEN           "VISIBLE" false

proc validate {} {
    # check fifo depths
    set fifo_depths [ get_parameter_value FIFO_DEPTHS ]
    set fast_ver    [ get_parameter_value FAST_VER ]
    #set show_hidden [ get_parameter_value SHOW_HIDDEN]
    
    #if {$show_hidden} {
    #    set_parameter_property FIFO_DEPTHS "VISIBLE" true
    #    set_parameter_property FIFO_WIDTHU "VISIBLE" true
    #    set_parameter_property FAST_VER    "VISIBLE" true
    #    set_parameter_property EXPORT_MASTER_SIGNALS "VISIBLE" true
    #} else {
    #    set_parameter_property FIFO_DEPTHS "VISIBLE" false
    #    set_parameter_property FIFO_WIDTHU "VISIBLE" false
    #    set_parameter_property FAST_VER    "VISIBLE" false
    #    set_parameter_property EXPORT_MASTER_SIGNALS "VISIBLE" false
    #}
    
    # check fifo depth
    if { "$fifo_depths" == "" } { 
        set fifo_depths 2 
        set_parameter_value FIFO_DEPTHS 2
    }
    if { "$fifo_depths" == "1" } { set fifo_depths 2 }
    set_parameter_value FIFO_WIDTHU [expr int(ceil(log($fifo_depths)/log(2)))]
    
    # check economy or fast transaction master    
    if { "$fast_ver" == "" } {
        set fast_ver 0
        set_parameter_value FAST_VER 0
    }
    
    # disable parameter
    if { "$fast_ver" == "0" } {
        set_parameter_property FIFO_DEPTHS "ENABLED" 0
        set_parameter_property FIFO_WIDTHU "ENABLED" 0
    } else {
        set_parameter_property FIFO_DEPTHS "ENABLED" 1
        set_parameter_property FIFO_WIDTHU "ENABLED" 1
    }
}

proc elaborate {} {
    set export_master [ get_parameter_value EXPORT_MASTER_SIGNALS ]
    # Interface clk
    add_interface clk clock end
    set_interface_property clk ptfSchematicName ""
    # Ports in interface clk
    add_interface_port clk clk clk Input 1
    add_interface_port clk reset_n reset_n Input 1
    
    # Interface out_stream
    add_interface out_stream avalon_streaming start
    set_interface_property out_stream maxChannel 0
    set_interface_property out_stream readyLatency 0
    set_interface_property out_stream dataBitsPerSymbol 8
    set_interface_property out_stream symbolsPerBeat 1

    set_interface_property out_stream ASSOCIATED_CLOCK clk

    # Ports in interface out_stream
    add_interface_port out_stream out_ready ready Input 1
    add_interface_port out_stream out_valid valid Output 1
    add_interface_port out_stream out_data data Output 8
    add_interface_port out_stream out_startofpacket startofpacket Output 1
    add_interface_port out_stream out_endofpacket endofpacket Output 1
    
    # Interface in_stream
    add_interface in_stream avalon_streaming end
    set_interface_property in_stream maxChannel 0
    set_interface_property in_stream readyLatency 0
    set_interface_property in_stream dataBitsPerSymbol 8
    set_interface_property in_stream symbolsPerBeat 1

    set_interface_property in_stream ASSOCIATED_CLOCK clk

   	set_interface_assignment in_stream debug.interfaceGroup {associatedT2h out_stream}

    # Ports in interface in_stream
    add_interface_port in_stream in_ready ready Output 1
    add_interface_port in_stream in_valid valid Input 1
    add_interface_port in_stream in_data data Input 8
    add_interface_port in_stream in_startofpacket startofpacket Input 1
    add_interface_port in_stream in_endofpacket endofpacket Input 1

    if {$export_master == "1"} {
        # export avalon master as conduit
        add_interface avalon_master_export conduit start
        set_interface_property avalon_master_export ASSOCIATED_CLOCK clk
        add_interface_port avalon_master_export address export Output 32
        add_interface_port avalon_master_export readdata export Input 32
        add_interface_port avalon_master_export read export Output 1 
        add_interface_port avalon_master_export write export Output 1
        add_interface_port avalon_master_export writedata export Output 32
        add_interface_port avalon_master_export waitrequest export Input 1
        add_interface_port avalon_master_export readdatavalid export Input 1
        add_interface_port avalon_master_export byteenable export Output 4
    } else {
        # Interface avalon_master
        add_interface avalon_master avalon start 
        set_interface_property avalon_master linewrapBursts false
        set_interface_property avalon_master doStreamReads false
        set_interface_property avalon_master doStreamWrites false
        set_interface_property avalon_master burstOnBurstBoundariesOnly false
       
        set_interface_property avalon_master ASSOCIATED_CLOCK clk
        # Ports in interface avalon_master
        add_interface_port avalon_master address address Output 32
        add_interface_port avalon_master readdata readdata Input 32
        add_interface_port avalon_master read read Output 1
        add_interface_port avalon_master write write Output 1
        add_interface_port avalon_master writedata writedata Output 32
        add_interface_port avalon_master waitrequest waitrequest Input 1
        add_interface_port avalon_master readdatavalid readdatavalid Input 1
        add_interface_port avalon_master byteenable byteenable Output 4

    	set_interface_assignment avalon_master debug.controlledBy in_stream
    	set_interface_assignment avalon_master debug.providesServices master
    	set_interface_assignment avalon_master debug.typeName altera_jtag_avalon_master.master
    }
}
