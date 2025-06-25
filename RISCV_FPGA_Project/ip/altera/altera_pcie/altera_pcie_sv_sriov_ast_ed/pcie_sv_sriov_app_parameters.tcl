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



proc add_ed_sriov_parameters_ui {} {

   send_message debug "proc:add_ed_sriov_parameters_ui"

   set group_name "Design example parameters"

   add_parameter           device_family_hwtcl  string "Stratix V"
   set_parameter_property  device_family_hwtcl  DISPLAY_NAME "Targeted Device Family"
   set_parameter_property  device_family_hwtcl  ALLOWED_RANGES {"Stratix V" "Arria V" "Cyclone V"}
   set_parameter_property  device_family_hwtcl  GROUP $group_name
   set_parameter_property  device_family_hwtcl  VISIBLE true
   set_parameter_property  device_family_hwtcl  HDL_PARAMETER true
   set_parameter_property  device_family_hwtcl  DESCRIPTION "Selects the targeted device family for device specific parameterization"

   # Gen1/Gen2
   add_parameter          lane_mask_hwtcl string "x4"
   set_parameter_property lane_mask_hwtcl DISPLAY_NAME "Lanes"
   set_parameter_property lane_mask_hwtcl ALLOWED_RANGES {"x1" "x2" "x4" "x8"}
   set_parameter_property lane_mask_hwtcl GROUP $group_name
   set_parameter_property lane_mask_hwtcl VISIBLE true
   set_parameter_property lane_mask_hwtcl HDL_PARAMETER true
   set_parameter_property lane_mask_hwtcl DESCRIPTION "Selects the maximum number of lanes supported. The IP core supports 1, 2, 4, or 8 lanes."

   # Gen1/Gen2
   add_parameter          gen123_lane_rate_mode_hwtcl string "Gen1 (2.5 Gbps)"
   set_parameter_property gen123_lane_rate_mode_hwtcl DISPLAY_NAME "Lane Rate"
   set_parameter_property gen123_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)" "Gen3 (8.0 Gbps)"}
   set_parameter_property gen123_lane_rate_mode_hwtcl GROUP $group_name
   set_parameter_property gen123_lane_rate_mode_hwtcl VISIBLE true
   set_parameter_property gen123_lane_rate_mode_hwtcl HDL_PARAMETER true
   set_parameter_property gen123_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link. Gen1 (2.5 Gbps), Gen2 (5.0 Gbps) and Gen3 (8.0 Gbps) are supported."

   # PLD clock rate
   add_parameter          pld_clockrate_hwtcl integer 125000000
   set_parameter_property pld_clockrate_hwtcl DISPLAY_NAME "Application Clock Rate"
   set_parameter_property pld_clockrate_hwtcl ALLOWED_RANGES { "62500000:62.5 MHz" "125000000:125 MHz" "250000000:250 MHz" }
   set_parameter_property pld_clockrate_hwtcl GROUP $group_name
   set_parameter_property pld_clockrate_hwtcl VISIBLE true
   set_parameter_property pld_clockrate_hwtcl HDL_PARAMETER true
   set_parameter_property pld_clockrate_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps) and Gen2 (5.0 Gbps) are supported."
   # Port Type
   add_parameter          port_type_hwtcl string "Native endpoint"
   set_parameter_property port_type_hwtcl DISPLAY_NAME "Port type"
   set_parameter_property port_type_hwtcl ALLOWED_RANGES {"Native endpoint" "Root port"}
   set_parameter_property port_type_hwtcl GROUP $group_name
   set_parameter_property port_type_hwtcl VISIBLE true
   set_parameter_property port_type_hwtcl HDL_PARAMETER true
   set_parameter_property port_type_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports are supported."

   # Application Interface
   add_parameter          ast_width_hwtcl string "Avalon-ST 64-bit"
   set_parameter_property ast_width_hwtcl DISPLAY_NAME "Application interface"
   set_parameter_property ast_width_hwtcl ALLOWED_RANGES {"Avalon-ST 64-bit" "Avalon-ST 128-bit" "Avalon-ST 256-bit"}
   set_parameter_property ast_width_hwtcl GROUP $group_name
   set_parameter_property ast_width_hwtcl VISIBLE true
   set_parameter_property ast_width_hwtcl HDL_PARAMETER true
   set_parameter_property ast_width_hwtcl DESCRIPTION "Selects the width of the data interface between the transaction layer and the application layer implemented in the PLD fabric. The IP core supports interfaces of 64, 128, or 256 bits."

   add_parameter          extend_tag_field_hwtcl integer 32
   set_parameter_property extend_tag_field_hwtcl DISPLAY_NAME "Tag supported"
   set_parameter_property extend_tag_field_hwtcl ALLOWED_RANGES { 32 64 }
   set_parameter_property extend_tag_field_hwtcl GROUP $group_name
   set_parameter_property extend_tag_field_hwtcl VISIBLE true
   set_parameter_property extend_tag_field_hwtcl HDL_PARAMETER true
   set_parameter_property extend_tag_field_hwtcl DESCRIPTION "Sets the number of tags supported for non-posted requests transmitted by the application layer."

   add_parameter max_payload_size_hwtcl integer 128
   set_parameter_property max_payload_size_hwtcl DISPLAY_NAME "Maximum payload size"
   set_parameter_property max_payload_size_hwtcl ALLOWED_RANGES { "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" "1024:1024 Bytes" "2048:2048 Bytes"  }
   set_parameter_property max_payload_size_hwtcl GROUP $group_name
   set_parameter_property max_payload_size_hwtcl VISIBLE true
   set_parameter_property max_payload_size_hwtcl HDL_PARAMETER true
   set_parameter_property max_payload_size_hwtcl DESCRIPTION "Sets the max payload size and optimizes for this payload size."

   #Function
   add_parameter          num_of_func_hwtcl integer 1
   set_parameter_property num_of_func_hwtcl DISPLAY_NAME "Number of Functions"
   set_parameter_property num_of_func_hwtcl ALLOWED_RANGES {1:256}
   set_parameter_property num_of_func_hwtcl GROUP $group_name
   set_parameter_property num_of_func_hwtcl VISIBLE true
   set_parameter_property num_of_func_hwtcl HDL_PARAMETER true
   set_parameter_property num_of_func_hwtcl DESCRIPTION "Number of Functions to supported by the device"

   add_parameter          multiple_packets_per_cycle_hwtcl integer 0
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_NAME "Enable multiple packets per cycle"
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_HINT boolean
   set_parameter_property multiple_packets_per_cycle_hwtcl GROUP $group_name
   set_parameter_property multiple_packets_per_cycle_hwtcl VISIBLE true
   set_parameter_property multiple_packets_per_cycle_hwtcl HDL_PARAMETER true
   set_parameter_property multiple_packets_per_cycle_hwtcl DESCRIPTION "When On, the Avalon-ST interface supports the transmission of TLPs starting at any 128-bit address boundary, allowing support for multiple packets in a single cycle. To support multiple packets per cycle, the Avalon-ST interface includes 2 start of packet and end of packet signals for the 256-bit Avalon-ST interfaces."

   add_parameter          track_rxfc_cplbuf_ovf_hwtcl integer 0
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DISPLAY_NAME "Track Receive Completion Buffer Overflow"
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DISPLAY_HINT boolean
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl GROUP $group_name
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl VISIBLE true
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl HDL_PARAMETER false
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DESCRIPTION "Brings in a signal for tracking the Rx posted completion buffer overflow status"

   # VF Count
   add_parameter          VF_COUNT integer 32
   set_parameter_property VF_COUNT DISPLAY_NAME "VF Count"
   set_parameter_property VF_COUNT ALLOWED_RANGES {0:32}
   set_parameter_property VF_COUNT GROUP $group_name
   set_parameter_property VF_COUNT VISIBLE true
   set_parameter_property VF_COUNT HDL_PARAMETER true
   set_parameter_property VF_COUNT DESCRIPTION "Selects the number of Virtual Function supported per Physical Function"

}

proc validation_parameter_func {} {
   set device_family_hwtcl [ get_parameter_value device_family_hwtcl]
   set track_rxfc_cplbuf_ovf_hwtcl [ get_parameter_value track_rxfc_cplbuf_ovf_hwtcl]

   if {$device_family_hwtcl == "Arria V" || $device_family_hwtcl == "Cyclone V"} {
      set func_range   {"1" "2" "3" "4" "5" "6" "7" "8"}
   } else {
      set func_range {"1"}
   }
   set_parameter_property num_of_func_hwtcl ALLOWED_RANGES $func_range

   if {$device_family_hwtcl == "Arria V" || $device_family_hwtcl == "Cyclone V"} {
      if { $track_rxfc_cplbuf_ovf_hwtcl == 1} {
         send_message error "This option applies to only Stratix V and Arria V GZ devices "
      }
   }

}

proc add_ed_sriov_parameters_hidden {} {

   send_message debug "proc:add_ed_sriov_parameters_hidden"

   add_parameter          port_width_be_hwtcl integer 8
   set_parameter_property port_width_be_hwtcl VISIBLE false
   set_parameter_property port_width_be_hwtcl HDL_PARAMETER true
   set_parameter_property port_width_be_hwtcl DERIVED true

   add_parameter          port_width_data_hwtcl integer 64
   set_parameter_property port_width_data_hwtcl VISIBLE false
   set_parameter_property port_width_data_hwtcl DERIVED true
   set_parameter_property port_width_data_hwtcl HDL_PARAMETER true

   add_parameter avalon_waddr_hwltcl integer 12
   set_parameter_property avalon_waddr_hwltcl VISIBLE false
   set_parameter_property avalon_waddr_hwltcl HDL_PARAMETER true

   add_parameter check_bus_master_ena_hwtcl integer 1
   set_parameter_property check_bus_master_ena_hwtcl VISIBLE false
   set_parameter_property check_bus_master_ena_hwtcl HDL_PARAMETER true

   add_parameter check_rx_buffer_cpl_hwtcl integer 1
   set_parameter_property check_rx_buffer_cpl_hwtcl VISIBLE false
   set_parameter_property check_rx_buffer_cpl_hwtcl HDL_PARAMETER true

   add_parameter          use_crc_forwarding_hwtcl integer 0
   set_parameter_property use_crc_forwarding_hwtcl VISIBLE false
   set_parameter_property use_crc_forwarding_hwtcl HDL_PARAMETER true

   add_parameter          use_ep_simple_downstream_apps_hwtcl integer 0
   set_parameter_property use_ep_simple_downstream_apps_hwtcl VISIBLE false
   set_parameter_property use_ep_simple_downstream_apps_hwtcl HDL_PARAMETER false

}

proc rdpcie_hip_parameters_valid {} {
   set lane_mask_hwtcl             [ get_parameter_value lane_mask_hwtcl ]
   set dev_family [get_parameter_value device_family_hwtcl ]
   set gen123_lane_rate_mode_hwtcl [ get_parameter_value gen123_lane_rate_mode_hwtcl ]
   set multiple_packets_per_cycle_hwtcl  [ get_parameter_value multiple_packets_per_cycle_hwtcl ]


#  set number_of_reconfig_interfaces 5
#
#  if  { [ regexp x1 $lane_mask_hwtcl ] } {
#     if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
#        set number_of_reconfig_interfaces 3
#     } else {
#        set number_of_reconfig_interfaces 2
#     }
#  } elseif { [ regexp x2 $lane_mask_hwtcl ] } {
#     if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
#        set number_of_reconfig_interfaces 4
#     } else {
#        set number_of_reconfig_interfaces 3
#     }
#  } elseif { [ regexp x4 $lane_mask_hwtcl ] } {
#     if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
#        set number_of_reconfig_interfaces 6
#     } else {
#        set number_of_reconfig_interfaces 5
#     }
#  } else {
#     if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
#        set number_of_reconfig_interfaces 11
#     } else {
#        set number_of_reconfig_interfaces 10
#     }
#  }

#   set_parameter_value reconfig_to_xcvr_width   [ common_get_reconfig_to_xcvr_total_width $dev_family $number_of_reconfig_interfaces ]
#   set_parameter_value reconfig_from_xcvr_width [ common_get_reconfig_from_xcvr_total_width $dev_family $number_of_reconfig_interfaces ]
#   set_parameter_value number_of_reconfig_interfaces $number_of_reconfig_interfaces

   if { $multiple_packets_per_cycle_hwtcl ==1 } {
      # multiple packets per cycle is only compatible with Gen3 x8
      if { [regexp Gen3 $gen123_lane_rate_mode_hwtcl] && [ regexp x8 $lane_mask_hwtcl ] } {
         send_message info "The multiple packets per cycle support is enabled."
      } else {
         send_message error "The multiple packets per cycle support is only compatible with Gen3 x8"
      }
  }

   # Setting AST Port width parameters
   set ast_width_hwtcl  [ get_parameter_value ast_width_hwtcl ]
   set dataWidth        [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set_parameter_value port_width_data_hwtcl      $dataWidth
   set_parameter_value port_width_be_hwtcl        $dataByteWidth

}
