package require -exact sopc 9.1

# +-----------------------------------
# | module altera_avalon_st_jtag_interface
# |
set_module_property DESCRIPTION ""
set_module_property NAME altera_jtag_dc_streaming
set_module_property VERSION 13.1
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-ST JTAG Interface"
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/nios2/qts_qii55008.pdf
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_st_jtag_interface.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_st_jtag_interface
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_file altera_avalon_st_jtag_interface.v {SYNTHESIS SIMULATION}
add_file altera_jtag_dc_streaming.v {SYNTHESIS SIMULATION}
add_file altera_jtag_sld_node.v {SYNTHESIS SIMULATION}
add_file altera_jtag_streaming.v {SYNTHESIS SIMULATION}
add_file altera_pli_streaming.v {SYNTHESIS SIMULATION}
add_file ../../avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v {SYNTHESIS SIMULATION}
add_file ../../avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS SIMULATION}
add_file ../altera_avalon_st_idle_remover/altera_avalon_st_idle_remover.v {SYNTHESIS SIMULATION}
add_file ../altera_avalon_st_idle_inserter/altera_avalon_st_idle_inserter.v {SYNTHESIS SIMULATION}
add_file altera_avalon_st_jtag_interface.sdc SDC
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter PURPOSE INTEGER 0
set_parameter_property PURPOSE ALLOWED_RANGES {"0:Unknown" "1:Transacto" "2:Config ROM" "3:Packetstream" "4:Nios II MT Debugger" "5:Dual Nios II MT Debugger"}
set_parameter_property PURPOSE DISPLAY_NAME PURPOSE
set_parameter_property PURPOSE UNITS None
set_parameter_property PURPOSE VISIBLE true
set_parameter_property PURPOSE AFFECTS_ELABORATION true
set_parameter_property PURPOSE STATUS experimental
set_parameter_property PURPOSE HDL_PARAMETER true

add_parameter UPSTREAM_FIFO_SIZE INTEGER 0
set_parameter_property UPSTREAM_FIFO_SIZE ALLOWED_RANGES {"0:none" "2:2 Bytes" "4:4 Bytes" "8:8 Bytes" "16:16 Bytes" "32:32 Bytes" "64:64 Bytes" "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" "1024:1 kBytes" "2048:2 kBytes" "4096:4 kBytes" "8192:8 kBytes" "16384:16 kBytes" "32768:32 kBytes"}
set_parameter_property UPSTREAM_FIFO_SIZE DISPLAY_NAME UPSTREAM_FIFO_SIZE
set_parameter_property UPSTREAM_FIFO_SIZE VISIBLE true
set_parameter_property UPSTREAM_FIFO_SIZE AFFECTS_ELABORATION true
set_parameter_property UPSTREAM_FIFO_SIZE STATUS experimental
set_parameter_property UPSTREAM_FIFO_SIZE HDL_PARAMETER true

add_parameter DOWNSTREAM_FIFO_SIZE INTEGER 0
set_parameter_property DOWNSTREAM_FIFO_SIZE ALLOWED_RANGES {"0:none" "2:2 Bytes" "4:4 Bytes" "8:8 Bytes" "16:16 Bytes" "32:32 Bytes" "64:64 Bytes" "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" "1024:1 kBytes" "2048:2 kBytes" "4096:4 kBytes" "8192:8 kBytes" "16384:16 kBytes" "32768:32 kBytes"}
set_parameter_property DOWNSTREAM_FIFO_SIZE DISPLAY_NAME DOWNSTREAM_FIFO_SIZE
set_parameter_property DOWNSTREAM_FIFO_SIZE VISIBLE true
set_parameter_property DOWNSTREAM_FIFO_SIZE AFFECTS_ELABORATION true
set_parameter_property DOWNSTREAM_FIFO_SIZE STATUS experimental
set_parameter_property DOWNSTREAM_FIFO_SIZE HDL_PARAMETER true

add_parameter MGMT_CHANNEL_WIDTH INTEGER -1
set_parameter_property MGMT_CHANNEL_WIDTH DISPLAY_NAME "Management channel width"
set_parameter_property MGMT_CHANNEL_WIDTH ALLOWED_RANGES {-1:32}
set_parameter_property MGMT_CHANNEL_WIDTH UNITS None
set_parameter_property MGMT_CHANNEL_WIDTH VISIBLE true
set_parameter_property MGMT_CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property MGMT_CHANNEL_WIDTH HDL_PARAMETER true

add_parameter USE_PLI INTEGER 0
set_parameter_property USE_PLI DISPLAY_NAME "Use Simulation Link Mode"
set_parameter_property USE_PLI DISPLAY_HINT boolean
set_parameter_property USE_PLI UNITS None
set_parameter_property USE_PLI AFFECTS_ELABORATION true
set_parameter_property USE_PLI HDL_PARAMETER true

add_parameter PLI_PORT INTEGER 50000
set_parameter_property PLI_PORT DISPLAY_NAME "Simulation Link Server Port"
set_parameter_property PLI_PORT UNITS None
set_parameter_property PLI_PORT VISIBLE true
set_parameter_property PLI_PORT ENABLED false
set_parameter_property PLI_PORT AFFECTS_ELABORATION true
set_parameter_property PLI_PORT HDL_PARAMETER true

add_parameter USE_DOWNSTREAM_READY INTEGER 0
set_parameter_property USE_DOWNSTREAM_READY DISPLAY_NAME USE_DOWNSTREAM_READY
set_parameter_property USE_DOWNSTREAM_READY DISPLAY_HINT boolean
set_parameter_property USE_DOWNSTREAM_READY VISIBLE false
set_parameter_property USE_DOWNSTREAM_READY UNITS None
set_parameter_property USE_DOWNSTREAM_READY AFFECTS_ELABORATION true
set_parameter_property USE_DOWNSTREAM_READY STATUS experimental

add_parameter COMPONENT_CLOCK INTEGER 0
set_parameter_property COMPONENT_CLOCK SYSTEM_INFO { CLOCK_RATE clock }
set_parameter_property COMPONENT_CLOCK VISIBLE false

add_parameter FABRIC STRING "2.0"
set_parameter_property FABRIC SYSTEM_INFO AVALON_SPEC
set_parameter_property FABRIC VISIBLE false
# |
# +-----------------------------------

# +-----------------------------------
# | Elaborate
# |
proc elaborate {} {
    set use_pli [ get_parameter_value USE_PLI ]
    if {$use_pli == 1} {
      set_parameter_property PLI_PORT ENABLED true
    } else {
      set_parameter_property PLI_PORT ENABLED false
    }

    # +-----------------------------------
    # | connection point clock
    # |
    add_interface clock clock end
    add_interface_port clock clk clk Input 1

    add_interface clock_reset reset end
    add_interface_port clock reset_n reset_n Input 1
    set_interface_property clock_reset synchronousEdges deassert 
    set_interface_property clock_reset ASSOCIATED_CLOCK clock
    # |
    # +-----------------------------------

    # +-----------------------------------
    # | connection point src
    # |
    add_interface src avalon_streaming start
    set_interface_property src dataBitsPerSymbol 8
    set_interface_property src errorDescriptor ""
    set_interface_property src maxChannel 0
    set_interface_property src readyLatency 0
    set_interface_property src symbolsPerBeat 1

    set_interface_property src ASSOCIATED_CLOCK clock

    add_interface_port src source_data data Output 8
    add_interface_port src source_valid valid Output 1
    set use_downstream_ready [ get_parameter_value USE_DOWNSTREAM_READY ]
    if {$use_pli == 1 || $use_downstream_ready == 1} {
      add_interface_port src source_ready ready Input 1
    }
    # |
    # +-----------------------------------

    # +-----------------------------------
    # | connection point sink
    # |
    add_interface sink avalon_streaming end
    set_interface_property sink dataBitsPerSymbol 8
    set_interface_property sink errorDescriptor ""
    set_interface_property sink maxChannel 0
    set_interface_property sink readyLatency 0
    set_interface_property sink symbolsPerBeat 1

    set_interface_property sink ASSOCIATED_CLOCK clock

    add_interface_port sink sink_data data Input 8
    add_interface_port sink sink_valid valid Input 1
    add_interface_port sink sink_ready ready Output 1
    # |
    # +-----------------------------------

    # +-----------------------------------
    # | connection point resetrequest
    # |
    set fabric [get_parameter_value FABRIC]
    switch $fabric {
      "1.0" {
          add_interface resetrequest conduit start
          add_interface_port resetrequest resetrequest export Output 1
      }
      "2.0" {
          add_interface resetrequest reset start
          add_interface_port resetrequest resetrequest reset Output 1
          set_interface_property resetrequest associatedResetSinks none
          set_interface_property resetrequest synchronousEdges none 
          #set_interface_property resetrequest ASSOCIATED_CLOCK clock
      }
    }
    # |
    # +-----------------------------------

    # +-----------------------------------
    # | connection point resetrequest
    # |
    set mgmt_channel_width [get_parameter_value MGMT_CHANNEL_WIDTH]
    if {$mgmt_channel_width > 0} {
        add_interface debug_reset reset start
        add_interface_port debug_reset debug_reset reset Output 1
        set_interface_property debug_reset associatedResetSinks none
        set_interface_property debug_reset synchronousEdges deassert 
        set_interface_property debug_reset ASSOCIATED_CLOCK clock
        
        add_interface mgmt avalon_streaming start
        set_interface_property mgmt associatedClock clock
        set_interface_property mgmt associatedReset debug_reset
        set_interface_property mgmt dataBitsPerSymbol 1
        set_interface_property mgmt errorDescriptor ""
        set_interface_property mgmt maxChannel [expr (1<<$mgmt_channel_width) - 1]
        set_interface_property mgmt readyLatency 0
        add_interface_port mgmt mgmt_valid valid Output 1
        add_interface_port mgmt mgmt_channel channel Output $mgmt_channel_width
        add_interface_port mgmt mgmt_data data Output 1
    }
    # |
    # +-----------------------------------
}
# |
# +-----------------------------------


# +-----------------------------------
# | Validate
# |
proc validate {} {
    set my_clock_rate [ get_parameter_value COMPONENT_CLOCK ]
    # Check that the clock is connected before checking for the warning condition.
    if { $my_clock_rate != 0 } {
        if { $my_clock_rate < 20000000 } {
            send_message Warning "Clock rate is less than 20MHz.  This component may not function properly due to clock crossing constraints."
        }
    }
}
# |
# +-----------------------------------
