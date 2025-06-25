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


package require -exact sopc 10.0

set isInternalDevelopment "0"
set isVipRefDesign "__VIP_REF_DESIGN__"

if {$isInternalDevelopment == 0} {
    set add_file_attribute {SYNTHESIS}
} else {
    if {$isVipRefDesign == 0} {
        set add_file_attribute {SYNTHESIS}
    } else {
        set add_file_attribute {SYNTHESIS SIMULATION}
    }
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Files to be added to the SOPC component when reusing the modules defined in common_hdl       --
# -- (legacy stuff)                                                                               --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_common_pack_files {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_avalon_mm_bursting_master_fifo
    add_file  $path/alt_vip_common_package.vhd                            $add_file_attribute
}

proc add_common_dc_mixed_widths_fifo_files {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_dc_mixed_widths_fifo/src_hdl
    add_file  $path/alt_vip_common_dc_mixed_widths_fifo.sv                $add_file_attribute
}

proc add_avalon_mm_bursting_master_component_files {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_avalon_mm_bursting_master_fifo
    add_file  $path/alt_vip_common_avalon_mm_bursting_master_fifo.vhd     $add_file_attribute
    add_file  $path/alt_vip_common_pulling_width_adapter.vhd              $add_file_attribute
    add_file  $path/alt_vip_common_general_fifo.vhd                       $add_file_attribute
    add_file  $path/alt_vip_common_fifo_usedw_calculator.vhd              $add_file_attribute
    add_file  $path/alt_vip_common_gray_clock_crosser.vhd                 $add_file_attribute
    add_file  $path/alt_vip_common_std_logic_vector_delay.vhd             $add_file_attribute
    add_file  $path/alt_vip_common_one_bit_delay.vhd                      $add_file_attribute
    add_file  $path/alt_vip_common_logic_fifo.vhd                         $add_file_attribute
    add_file  $path/alt_vip_common_ram_fifo.vhd                           $add_file_attribute
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The common System Verilog packages                                                           --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_alt_vip_common_pkg_files {{rel_path "../.."}} {
    global    add_file_attribute
    add_file  $rel_path/common_hdl/common/alt_vip_common_pkg.sv               $add_file_attribute
}

proc add_alt_vip_common_buf_pkg_files {{rel_path "../.."}} {
    global    add_file_attribute
    add_file  $rel_path/common_hdl/common/alt_vip_common_buf_pkg.sv               $add_file_attribute
}

proc add_alt_vip_common_debug_pkg_files {{rel_path "../.."}} {
    global    add_file_attribute
    add_file  $rel_path/common_hdl/common/alt_vip_common_debug_pkg.sv         $add_file_attribute
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- The common modules                                                                           --
# -- Convention: use add_$modulename_files                                                        --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc add_alt_vip_common_event_packet_decode_files {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_event_packet_decode/src_hdl
    add_file  $path/alt_vip_common_event_packet_decode.sv                 $add_file_attribute
}

proc add_alt_vip_common_mult_add_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_mult_add/src_hdl
   add_file  $path/alt_vip_common_mult_add.sv                             $add_file_attribute
}

proc add_alt_vip_common_round_sat_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_round_sat/src_hdl
   add_file  $path/alt_vip_common_round_sat.sv                             $add_file_attribute
}

proc add_alt_vip_common_hpel_filter_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_hpel_filter/src_hdl
   add_file  $path/alt_vip_common_hpel_filter.sv                             $add_file_attribute
}

proc add_alt_vip_common_qpel_filter_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_qpel_filter/src_hdl
   add_file  $path/alt_vip_common_qpel_filter.sv                             $add_file_attribute
}

proc add_alt_vip_common_sad_tree_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_sad_tree/src_hdl
   add_file  $path/alt_vip_common_sad_tree.sv                             $add_file_attribute
}

proc add_alt_vip_common_mirror_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_mirror/src_hdl
   add_file  $path/alt_vip_common_mirror.sv                               $add_file_attribute
}

proc add_alt_vip_common_edge_detect_chain_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_edge_detect_chain/src_hdl
   add_file  $path/alt_vip_common_edge_detect_chain.sv                    $add_file_attribute
}

proc add_alt_vip_common_h_kernel_files {{rel_path "../.."}} {
   global    add_file_attribute
   set       path          $rel_path/common_hdl/modules/alt_vip_common_h_kernel/src_hdl
   add_file  $path/alt_vip_common_h_kernel.sv                             $add_file_attribute
}

proc add_alt_vip_common_event_packet_encode_files {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_event_packet_encode/src_hdl
    add_file  $path/alt_vip_common_event_packet_encode.sv                 $add_file_attribute
}

proc add_alt_vip_common_video_packet_decode {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_video_packet_decode/src_hdl
    add_file  $path/alt_vip_common_latency_1_to_latency_0.sv              $add_file_attribute
    add_file  $path/alt_vip_common_video_packet_decode.sv                 $add_file_attribute
}

proc add_alt_vip_common_video_packet_encode {{rel_path "../.."}} {
    global    add_file_attribute
    set       path          $rel_path/common_hdl/modules/alt_vip_common_video_packet_encode/src_hdl
    add_file  $path/alt_vip_common_latency_0_to_latency_1.sv              $add_file_attribute
    add_file  $path/alt_vip_common_video_packet_encode.sv                 $add_file_attribute
}

proc add_alt_vip_common_fifo2_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_fifo2/src_hdl
    add_file $path/alt_vip_common_fifo2.sv                                $add_file_attribute
}

proc add_alt_vip_common_clock_crossing_bridge_grey_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_clock_crossing_bridge_grey/src_hdl/
    add_file $path/alt_vip_common_clock_crossing_bridge_grey.sv           $add_file_attribute
}

proc add_alt_vip_common_delay_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_delay/src_hdl/
    add_file $path/alt_vip_common_delay.sv          					  $add_file_attribute
}

proc add_alt_vip_common_qpel_buffer_control_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_qpel_buffer_control/src_hdl/
    add_file $path/alt_vip_common_qpel_buffer_control.sv          					  $add_file_attribute
}

proc add_alt_vip_common_message_pipeline_stage_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_message_pipeline_stage/src_hdl/
    add_file $path/alt_vip_common_message_pipeline_stage.sv          					  $add_file_attribute
}

proc add_alt_vip_common_rotate_mux_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_rotate_mux/src_hdl/
    add_file $path/alt_vip_common_rotate_mux.sv          					  $add_file_attribute
}

proc add_alt_vip_common_onehot_to_binary_files {{rel_path "../.."}} {
    global   add_file_attribute
    set      path          $rel_path/common_hdl/modules/alt_vip_common_onehot_to_binary/src_hdl/
    add_file $path/alt_vip_common_onehot_to_binary.sv          					  $add_file_attribute
}
