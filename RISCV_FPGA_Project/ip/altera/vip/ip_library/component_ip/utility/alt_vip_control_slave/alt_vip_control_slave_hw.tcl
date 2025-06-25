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


source ../../../common_tcl/alt_vip_helper_common_hw.tcl
source ../../../common_tcl/alt_vip_files_common_hw.tcl
source ../../../common_tcl/alt_vip_parameters_common_hw.tcl
source ../../../common_tcl/alt_vip_interfaces_common_hw.tcl

# | module alt_vip_control_slave

# Common module properties for VIP components
declare_general_component_info

set_module_property NAME alt_vip_control_slave
set_module_property DISPLAY_NAME "Avalon-MM Control Slave"
set_module_property TOP_LEVEL_HDL_FILE src_hdl/alt_vip_control_slave.sv
set_module_property TOP_LEVEL_HDL_MODULE alt_vip_control_slave
set_module_property ELABORATION_CALLBACK cs_elaboration_callback
set_module_property VALIDATION_CALLBACK cs_validation_callback

# | files

add_alt_vip_common_pkg_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..
add_file src_hdl/alt_vip_control_slave.sv $add_file_attribute


# | parameters

add_parameter NUM_READ_REGISTERS INTEGER 0
set_parameter_property NUM_READ_REGISTERS DISPLAY_NAME "Number of read-only registers"
set_parameter_property NUM_READ_REGISTERS DESCRIPTION "Number of registers that may be written only by the command interface and read only by the slave interface"
set_parameter_property NUM_READ_REGISTERS ALLOWED_RANGES 0:256
set_parameter_property NUM_READ_REGISTERS AFFECTS_ELABORATION true
set_parameter_property NUM_READ_REGISTERS HDL_PARAMETER true

add_parameter NUM_TRIGGER_REGISTERS INTEGER 0
set_parameter_property NUM_TRIGGER_REGISTERS DISPLAY_NAME "Number of trigger registers"
set_parameter_property NUM_TRIGGER_REGISTERS DESCRIPTION "Number of registers that may be written and read by the slave interface. Each write generates a response"
set_parameter_property NUM_TRIGGER_REGISTERS ALLOWED_RANGES 0:256
set_parameter_property NUM_TRIGGER_REGISTERS AFFECTS_ELABORATION true
set_parameter_property NUM_TRIGGER_REGISTERS HDL_PARAMETER true

add_parameter NUM_BLOCKING_TRIGGER_REGISTERS INTEGER 0
set_parameter_property NUM_BLOCKING_TRIGGER_REGISTERS DISPLAY_NAME "Number of command trigger registers"
set_parameter_property NUM_BLOCKING_TRIGGER_REGISTERS DESCRIPTION "Number of registers that may be written and read by the slave interface. Each write generates a response and requires a command in reply"
set_parameter_property NUM_BLOCKING_TRIGGER_REGISTERS ALLOWED_RANGES 0:256
set_parameter_property NUM_BLOCKING_TRIGGER_REGISTERS AFFECTS_ELABORATION true
set_parameter_property NUM_BLOCKING_TRIGGER_REGISTERS HDL_PARAMETER true

add_parameter NUM_RW_REGISTERS INTEGER 0
set_parameter_property NUM_RW_REGISTERS DISPLAY_NAME "Number of read/write registers"
set_parameter_property NUM_RW_REGISTERS DESCRIPTION "Number of registers that may be written and read by the slave and data interfaces"
set_parameter_property NUM_RW_REGISTERS ALLOWED_RANGES 0:256
set_parameter_property NUM_RW_REGISTERS AFFECTS_ELABORATION true
set_parameter_property NUM_RW_REGISTERS HDL_PARAMETER true

add_parameter NUM_INTERRUPTS INTEGER 0
set_parameter_property NUM_INTERRUPTS DISPLAY_NAME "Number of interrupts"
set_parameter_property NUM_INTERRUPTS ALLOWED_RANGES 0:8
set_parameter_property NUM_INTERRUPTS DESCRIPTION "Number of interrupts supported"
set_parameter_property NUM_INTERRUPTS AFFECTS_ELABORATION true
set_parameter_property NUM_INTERRUPTS HDL_PARAMETER true

add_parameter MM_CONTROL_REG_BYTES INTEGER 2
set_parameter_property MM_CONTROL_REG_BYTES DISPLAY_NAME "Control register bytes"
set_parameter_property MM_CONTROL_REG_BYTES ALLOWED_RANGES 1:4
set_parameter_property MM_CONTROL_REG_BYTES DESCRIPTION "Number of (8-bit) bytes per register for the control, status and interrupt registers"
set_parameter_property MM_CONTROL_REG_BYTES AFFECTS_ELABORATION false
set_parameter_property MM_CONTROL_REG_BYTES HDL_PARAMETER true

add_parameter MM_READ_REG_BYTES INTEGER 2
set_parameter_property MM_READ_REG_BYTES DISPLAY_NAME "Read-only register bytes"
set_parameter_property MM_READ_REG_BYTES DESCRIPTION "Number of (8-bit) bytes per register for the read-only registers (ignored if there are no read-only registers)"
set_parameter_property MM_READ_REG_BYTES ALLOWED_RANGES 1:4
set_parameter_property MM_READ_REG_BYTES AFFECTS_ELABORATION false
set_parameter_property MM_READ_REG_BYTES HDL_PARAMETER true

add_parameter MM_TRIGGER_REG_BYTES INTEGER 2
set_parameter_property MM_TRIGGER_REG_BYTES DISPLAY_NAME "Trigger and command trigger register bytes"
set_parameter_property MM_TRIGGER_REG_BYTES DESCRIPTION "Number of (8-bit) bytes per register for the trigger and command trigger registers (ignored if there are no trigger or command trigger registers)"
set_parameter_property MM_TRIGGER_REG_BYTES ALLOWED_RANGES 1:4
set_parameter_property MM_TRIGGER_REG_BYTES AFFECTS_ELABORATION true
set_parameter_property MM_TRIGGER_REG_BYTES HDL_PARAMETER true

add_parameter MM_RW_REG_BYTES INTEGER 2
set_parameter_property MM_RW_REG_BYTES DISPLAY_NAME "Read/write register bytes"
set_parameter_property MM_RW_REG_BYTES DESCRIPTION "Number of (8-bit) bytes per register for the Read/write registers (ignored if there are no Read/write registers)"
set_parameter_property MM_RW_REG_BYTES ALLOWED_RANGES 1:4
set_parameter_property MM_RW_REG_BYTES AFFECTS_ELABORATION true
set_parameter_property MM_RW_REG_BYTES HDL_PARAMETER true

add_parameter MM_ADDR_WIDTH INTEGER 7
set_parameter_property MM_ADDR_WIDTH DISPLAY_NAME "Slave port address width"
set_parameter_property MM_ADDR_WIDTH DESCRIPTION "Width of address signal for the Avalon-MM slave port"
set_parameter_property MM_ADDR_WIDTH ALLOWED_RANGES 1:32
set_parameter_property MM_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property MM_ADDR_WIDTH HDL_PARAMETER true

add_parameter DATA_INPUT INTEGER 1
set_parameter_property DATA_INPUT DISPLAY_NAME "Add data input interface"
set_parameter_property DATA_INPUT DESCRIPTION "Adds a data input interface"
set_parameter_property DATA_INPUT DISPLAY_HINT boolean
set_parameter_property DATA_INPUT ALLOWED_RANGES 0:1
set_parameter_property DATA_INPUT AFFECTS_ELABORATION true
set_parameter_property DATA_INPUT HDL_PARAMETER true

add_parameter DATA_OUTPUT INTEGER 1
set_parameter_property DATA_OUTPUT DISPLAY_NAME "Add data output interface"
set_parameter_property DATA_OUTPUT DESCRIPTION "Adds a data output interface"
set_parameter_property DATA_OUTPUT DISPLAY_HINT boolean
set_parameter_property DATA_OUTPUT ALLOWED_RANGES 0:1
set_parameter_property DATA_OUTPUT AFFECTS_ELABORATION true
set_parameter_property DATA_OUTPUT HDL_PARAMETER true

add_parameter FAST_REGISTER_UPDATES INTEGER 0
set_parameter_property FAST_REGISTER_UPDATES DISPLAY_NAME "Fast register update responses"
set_parameter_property FAST_REGISTER_UPDATES DESCRIPTION "Use single argument responses for register updates"
set_parameter_property FAST_REGISTER_UPDATES DISPLAY_HINT boolean
set_parameter_property FAST_REGISTER_UPDATES ALLOWED_RANGES 0:1
set_parameter_property FAST_REGISTER_UPDATES AFFECTS_ELABORATION true
set_parameter_property FAST_REGISTER_UPDATES HDL_PARAMETER true

add_parameter USE_MEMORY INTEGER 1
set_parameter_property USE_MEMORY DISPLAY_NAME "Implement registers in memory"
set_parameter_property USE_MEMORY DESCRIPTION "Implements the control slave registers in a memory"
set_parameter_property USE_MEMORY ALLOWED_RANGES 0:1
set_parameter_property USE_MEMORY DISPLAY_HINT boolean
set_parameter_property USE_MEMORY AFFECTS_ELABORATION false
set_parameter_property USE_MEMORY HDL_PARAMETER true

add_parameter PIPELINE_READ INTEGER 1
set_parameter_property PIPELINE_READ DISPLAY_NAME "Pipeline slave read data"
set_parameter_property PIPELINE_READ ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_READ DESCRIPTION "Adds a pipeline register to the read data signal on the Avalon-MM slave"
set_parameter_property PIPELINE_READ DISPLAY_HINT boolean
set_parameter_property PIPELINE_READ AFFECTS_ELABORATION true
set_parameter_property PIPELINE_READ HDL_PARAMETER true

add_parameter PIPELINE_RESPONSE INTEGER 1
set_parameter_property PIPELINE_RESPONSE DISPLAY_NAME "Pipeline response interface"
set_parameter_property PIPELINE_RESPONSE ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_RESPONSE DESCRIPTION "Adds a pipeline register to the response interface"
set_parameter_property PIPELINE_RESPONSE DISPLAY_HINT boolean
set_parameter_property PIPELINE_RESPONSE AFFECTS_ELABORATION false
set_parameter_property PIPELINE_RESPONSE HDL_PARAMETER true

add_parameter PIPELINE_DATA INTEGER 1
set_parameter_property PIPELINE_DATA DISPLAY_NAME "Pipeline dout interface"
set_parameter_property PIPELINE_DATA ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_DATA DESCRIPTION "Adds a pipeline register to the dout interface"
set_parameter_property PIPELINE_DATA DISPLAY_HINT boolean
set_parameter_property PIPELINE_DATA AFFECTS_ELABORATION false
set_parameter_property PIPELINE_DATA HDL_PARAMETER true

add_av_st_event_parameters

add_parameter RESP_SOURCE INTEGER 1
set_parameter_property RESP_SOURCE DISPLAY_NAME "Response Source ID"
set_parameter_property RESP_SOURCE DESCRIPTION "Source ID used for the reponse interface"
set_parameter_property RESP_SOURCE ALLOWED_RANGES 0:2147483647
set_parameter_property RESP_SOURCE AFFECTS_ELABORATION true
set_parameter_property RESP_SOURCE HDL_PARAMETER true

add_parameter RESP_DEST INTEGER 1
set_parameter_property RESP_DEST DISPLAY_NAME "Response Destination ID"
set_parameter_property RESP_DEST DESCRIPTION "Destination ID used for the response interface"
set_parameter_property RESP_DEST ALLOWED_RANGES 0:2147483647
set_parameter_property RESP_DEST AFFECTS_ELABORATION false
set_parameter_property RESP_DEST HDL_PARAMETER true

add_parameter RESP_CONTEXT INTEGER 1
set_parameter_property RESP_CONTEXT DISPLAY_NAME "Response Context ID"
set_parameter_property RESP_CONTEXT DESCRIPTION "Context ID used for the response interface"
set_parameter_property RESP_CONTEXT ALLOWED_RANGES 0:2147483647
set_parameter_property RESP_CONTEXT AFFECTS_ELABORATION false
set_parameter_property RESP_CONTEXT HDL_PARAMETER true

add_parameter DOUT_SOURCE INTEGER 1
set_parameter_property DOUT_SOURCE DISPLAY_NAME "Dout source address"
set_parameter_property DOUT_SOURCE DESCRIPTION "Source address used for the dout interface"
set_parameter_property DOUT_SOURCE ALLOWED_RANGES 0:2147483647
set_parameter_property DOUT_SOURCE AFFECTS_ELABORATION true
set_parameter_property DOUT_SOURCE HDL_PARAMETER true

# | connection point main_clock

add_main_clock_port

proc cs_validation_callback {} {
   set num_reg 3
   set temp_reg [get_parameter_value NUM_RW_REGISTERS]
   set num_reg [expr $num_reg + $temp_reg]
   set temp_reg [get_parameter_value NUM_TRIGGER_REGISTERS]
   set num_reg [expr $num_reg + $temp_reg]
   set temp_reg [get_parameter_value NUM_BLOCKING_TRIGGER_REGISTERS]
   set num_reg [expr $num_reg + $temp_reg]
   set temp_reg [get_parameter_value NUM_READ_REGISTERS]
   set num_reg [expr $num_reg + $temp_reg]
   set addr_width [clogb2_pure $num_reg]
   if { $addr_width > [get_parameter_value MM_ADDR_WIDTH] } {
      send_message error "The control slave will have $num_reg internal registers so the address with for the slave port must be at least $addr_width"
   }
}

# | Dynamic ports (elaboration callback)
proc cs_elaboration_callback {} {

    # | connection point control
    set pipeline_read [get_parameter_value PIPELINE_READ]
    if { $pipeline_read > 0 } {
      set read_latency 2
    } else {
      set read_latency 1
    }

    set num_reg 3
    set temp_reg [get_parameter_value NUM_RW_REGISTERS]
    set num_reg [expr $num_reg + $temp_reg]
    set temp_reg [get_parameter_value NUM_TRIGGER_REGISTERS]
    set num_reg [expr $num_reg + $temp_reg]
    set temp_reg [get_parameter_value NUM_BLOCKING_TRIGGER_REGISTERS]
    set num_reg [expr $num_reg + $temp_reg]
    set temp_reg [get_parameter_value NUM_READ_REGISTERS]
    set num_reg [expr $num_reg + $temp_reg]
    set addr_width [get_parameter_value MM_ADDR_WIDTH]

    set use_interrupt [get_parameter_value NUM_INTERRUPTS]
    if { $use_interrupt > 0 } {
      set use_interrupt 1
    }

    add_control_slave_port   av_mm_control   $addr_width   $num_reg   $use_interrupt   $read_latency   1   1   main_clock

    if { [get_parameter_value FAST_REGISTER_UPDATES] } {
        set elements_per_beat 2
    } else {
        set elements_per_beat 1
    }

    set src_id [get_parameter_value RESP_SOURCE]

    # | connection point cmd
    set dst_width [get_parameter_value DST_WIDTH]
    set src_width [get_parameter_value SRC_WIDTH]
    set task_width [get_parameter_value TASK_WIDTH]
    set context_width [get_parameter_value CONTEXT_WIDTH]
    add_av_st_cmd_sink_port   av_st_cmd   $elements_per_beat   $dst_width   $src_width   $task_width   $context_width   main_clock   $src_id


    # | connection point rsp
    add_av_st_resp_source_port   av_st_resp   $elements_per_beat   $dst_width   $src_width   $task_width   $context_width   main_clock   $src_id

    set data_width [expr 8 * [get_parameter_value MM_RW_REG_BYTES] ]
    if  { $data_width < 1 } {
      set data_width 1
    }
    set src_id [get_parameter_value DOUT_SOURCE]

    if { [get_parameter_value DATA_INPUT] > 0 } {
      add_av_st_data_sink_port   av_st_din   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id
    }

    if { [get_parameter_value DATA_OUTPUT] > 0 } {
      add_av_st_data_source_port   av_st_dout   $data_width   1   $dst_width   $src_width   $task_width   $context_width   0    main_clock   $src_id
    }

}
