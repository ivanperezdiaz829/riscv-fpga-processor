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


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- General information for the packet writer component                                          --
# -- This block receives packet write commands (on the cmd interface), receives it on the Avalon  --
# -- ST sink and writes it on the Avalon-MM master interface                                      --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_file alt_vip_packet_writer.sdc SDC

# Common module properties for VIP components
declare_general_component_info


# Component specific properties
set_module_property   NAME alt_vip_packet_writer
set_module_property   DISPLAY_NAME   "Packet Writer"
set_module_property   DESCRIPTION    "Receives packet write commands (on the cmd interface), sinks the write data from the din interface and writes it on the Avalon-MM master write_master interface "
set_module_property   TOP_LEVEL_HDL_FILE src_hdl/alt_vip_packet_writer.sv
set_module_property   TOP_LEVEL_HDL_MODULE alt_vip_packet_writer

set_module_property ELABORATION_CALLBACK packet_writer_elaboration_callback
set_module_property VALIDATION_CALLBACK packet_writer_validation_callback


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files                                                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_alt_vip_common_pkg_files ../../..
add_file src_hdl/alt_vip_packet_writer.sv $add_file_attribute
add_common_pack_files ../../..
add_avalon_mm_bursting_master_component_files ../../..
add_alt_vip_common_event_packet_decode_files ../../..
add_alt_vip_common_event_packet_encode_files ../../..



# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Parameters                                                                                   --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
add_bits_per_symbol_parameters

add_channels_nb_parameters

add_parameter FIFO_DEPTH int 16
set_parameter_property   FIFO_DEPTH        AFFECTS_GENERATION              true
set_parameter_property   FIFO_DEPTH        HDL_PARAMETER                   true
set_parameter_property   FIFO_DEPTH        DISPLAY_NAME                    "FIFO depth"

add_parameter BURST_TARGET int 8
set_parameter_property   BURST_TARGET      AFFECTS_GENERATION              true
set_parameter_property   BURST_TARGET      HDL_PARAMETER                   true
set_parameter_property   BURST_TARGET      DISPLAY_NAME                    "Burst target"

add_parameter BURST_ALIGN boolean true
set_parameter_property   BURST_ALIGN       AFFECTS_GENERATION              false
set_parameter_property   BURST_ALIGN       HDL_PARAMETER                   false
set_parameter_property   BURST_ALIGN       DISPLAY_NAME                    "Bursts are aligned"

add_parameter MAX_PACKET_SIZE int 1920
set_parameter_property   MAX_PACKET_SIZE   AFFECTS_GENERATION              true
set_parameter_property   MAX_PACKET_SIZE   HDL_PARAMETER                   true
set_parameter_property   MAX_PACKET_SIZE   DISPLAY_NAME                    "Maximum packet size"

add_parameter SEPARATE_CLOCKS int 1
set_parameter_property   SEPARATE_CLOCKS   AFFECTS_GENERATION              true
set_parameter_property   SEPARATE_CLOCKS   HDL_PARAMETER                   true
set_parameter_property   SEPARATE_CLOCKS   ALLOWED_RANGES                  0:1
set_parameter_property   SEPARATE_CLOCKS   DISPLAY_HINT                    boolean
set_parameter_property   SEPARATE_CLOCKS   DISPLAY_HINT                    boolean
set_parameter_property   SEPARATE_CLOCKS   DISPLAY_NAME                    "Use separate Av-ST and Av-MM clocks"

add_parameter MM_DWIDTH int 256
set_parameter_property   MM_DWIDTH         AFFECTS_GENERATION              true
set_parameter_property   MM_DWIDTH         HDL_PARAMETER                   true
set_parameter_property   MM_DWIDTH         DISPLAY_NAME                    "Avalon-MM data width"

add_parameter MM_AWIDTH int 32
set_parameter_property   MM_AWIDTH         AFFECTS_GENERATION              true
set_parameter_property   MM_AWIDTH         HDL_PARAMETER                   true
set_parameter_property   MM_AWIDTH         VISIBLE                         false
set_parameter_property   MM_AWIDTH         DISPLAY_NAME                    "Avalon-MM address width"

add_av_st_event_parameters


# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Static ports                                                                                 --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------

# The internal clock (and associated reset)
add_main_clock_port

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Dynamic ports (elaboration callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc packet_writer_elaboration_callback {} {

    set bits_per_symbol             [get_parameter_value BITS_PER_SYMBOL]
    set are_in_parallel             [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    if { $are_in_parallel > 0 } {
       set symbols_in_par           [get_parameter_value NUMBER_OF_COLOR_PLANES]
    } else {
       set symbols_in_par 1
    }
    set data_width                  [expr $bits_per_symbol * $symbols_in_par]

    set src_width                   [get_parameter_value SRC_WIDTH]
    set dst_width                   [get_parameter_value DST_WIDTH]
    set context_width               [get_parameter_value CONTEXT_WIDTH]
    set task_width                  [get_parameter_value TASK_WIDTH]

    add_av_st_cmd_sink_port   av_st_cmd              1   $dst_width   $src_width   $task_width   $context_width        main_clock
    add_av_st_data_sink_port  av_st_din  $data_width 1   $dst_width   $src_width   $task_width   $context_width   0    main_clock

    set mem_port_width              [get_parameter_value MM_DWIDTH]
    set burst_target                [get_parameter_value BURST_TARGET]
    set burst_align                 [get_parameter_value BURST_ALIGN]

    set separate_clocks [get_parameter_value SEPARATE_CLOCKS]
    if { $separate_clocks > 0 } {
       add_clock_port av_mm_clock
       add_bursting_write_master_port  av_mm_write_master  $mem_port_width     $burst_target      $burst_align         av_mm_clock
    } else {
       add_bursting_write_master_port  av_mm_write_master  $mem_port_width     $burst_target      $burst_align         main_clock
    }

}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Checking parameters (validation callback)                                                         --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc packet_writer_validation_callback {} {

   set task_width               [get_parameter_value TASK_WIDTH]
   if { $task_width < 2 } {
      send_message error "Command Task ID width (currently $task_width) must be at least 2 bits"
   }

   set bits_per_symbol             [get_parameter_value BITS_PER_SYMBOL]
    set are_in_parallel             [get_parameter_value COLOR_PLANES_ARE_IN_PARALLEL]
    if { $are_in_parallel > 0 } {
       set symbols_in_par           [get_parameter_value NUMBER_OF_COLOR_PLANES]
    } else {
       set symbols_in_par 1
    }
   set st_data_width               [expr $symbols_in_par * $bits_per_symbol]
   set mem_port_width              [get_parameter_value MM_DWIDTH]
   if { $st_data_width > $mem_port_width } {
      send_message error "Data with for av_st_din (currently $st_data_width) must not be grater than data width for av_mm_read_master (currently $mem_port_width)"
   }

   set fifo_depth                  [get_parameter_value FIFO_DEPTH]
   set burst_target                [get_parameter_value BURST_TARGET]
   if { $fifo_depth < $burst_target } {
      send_message error "Burst target (currently $burst_target) must be less than Fifo depth (currently $fifo_depth)"
   }
}
