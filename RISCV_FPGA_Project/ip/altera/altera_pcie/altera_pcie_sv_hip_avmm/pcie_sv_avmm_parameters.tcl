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


global env
set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_sv_hip_ast/pcie_sv_parameters_common.tcl

proc add_pcie_hip_parameters_ui_system_settings {} {
   send_message debug "proc:add_pcie_hip_parameters_ui_system_settings"

   set group_name "System Settings"
   # Gen1/Gen2
   add_parameter          lane_mask_hwtcl string "x4"
   set_parameter_property lane_mask_hwtcl DISPLAY_NAME "Number of lanes"
   set_parameter_property lane_mask_hwtcl ALLOWED_RANGES {"x1" "x2" "x4" "x8"}
   set_parameter_property lane_mask_hwtcl GROUP $group_name
   set_parameter_property lane_mask_hwtcl VISIBLE true
   set_parameter_property lane_mask_hwtcl HDL_PARAMETER true
   set_parameter_property lane_mask_hwtcl DESCRIPTION "Selects the maximum number of lanes supported. The IP core supports 1, 2, 4, or 8 lanes."

   # Gen1/Gen2
   add_parameter          gen123_lane_rate_mode_hwtcl string "Gen1 (2.5 Gbps)"
   set_parameter_property gen123_lane_rate_mode_hwtcl DISPLAY_NAME "Lane rate"
   set_parameter_property gen123_lane_rate_mode_hwtcl ALLOWED_RANGES {"Gen1 (2.5 Gbps)" "Gen2 (5.0 Gbps)" "Gen3 (8.0 Gbps)"}
   set_parameter_property gen123_lane_rate_mode_hwtcl GROUP $group_name
   set_parameter_property gen123_lane_rate_mode_hwtcl VISIBLE true
   set_parameter_property gen123_lane_rate_mode_hwtcl HDL_PARAMETER true
   set_parameter_property gen123_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps) and Gen2 (5.0 Gbps) are supported."

   # Selects the port type
   add_parameter          port_type_hwtcl string "Native endpoint"
   set_parameter_property port_type_hwtcl DISPLAY_NAME "Port type"
   set_parameter_property port_type_hwtcl ALLOWED_RANGES {"Native endpoint" "Root port"}
   set_parameter_property port_type_hwtcl GROUP $group_name
   set_parameter_property port_type_hwtcl VISIBLE true
   set_parameter_property port_type_hwtcl HDL_PARAMETER true
   set_parameter_property port_type_hwtcl DESCRIPTION "Selects the port type. Native Endpoints, Root Ports, and legacy Endpoints are supported."

   add_parameter          pcie_spec_version_hwtcl string "2.1"
   set_parameter_property pcie_spec_version_hwtcl DISPLAY_NAME "PCI Express Base Specification version"
   set_parameter_property pcie_spec_version_hwtcl ALLOWED_RANGES {"2.1" "3.0"}
   set_parameter_property pcie_spec_version_hwtcl GROUP $group_name
   set_parameter_property pcie_spec_version_hwtcl VISIBLE false
   set_parameter_property pcie_spec_version_hwtcl DERIVED true
   set_parameter_property pcie_spec_version_hwtcl HDL_PARAMETER true
   set_parameter_property pcie_spec_version_hwtcl DESCRIPTION "Selects the version of PCI Express Base Specification implemented. Version 2.1 is supported."


   # RX Buffer Credit Setting
   add_parameter          rxbuffer_rxreq_hwtcl string "Low"
   set_parameter_property rxbuffer_rxreq_hwtcl DISPLAY_NAME "RX buffer credit  allocation - performance for received requests"
   set_parameter_property rxbuffer_rxreq_hwtcl ALLOWED_RANGES {"Minimum" "Low" "Balanced" "High" "Maximum"}
   set_parameter_property rxbuffer_rxreq_hwtcl GROUP $group_name
   set_parameter_property rxbuffer_rxreq_hwtcl VISIBLE true
   set_parameter_property rxbuffer_rxreq_hwtcl HDL_PARAMETER false
   set_parameter_property rxbuffer_rxreq_hwtcl DESCRIPTION "Set the credits in the RX buffer for Posted, Non-Posted and Completion TLPs. The number of credits increases as the desired performance and maximum payload size increase."

   # Ref clk
   add_parameter          pll_refclk_freq_hwtcl string "100 MHz"
   set_parameter_property pll_refclk_freq_hwtcl DISPLAY_NAME "Reference clock frequency"
   set_parameter_property pll_refclk_freq_hwtcl ALLOWED_RANGES {"100 MHz" "125 MHz"}
   set_parameter_property pll_refclk_freq_hwtcl GROUP $group_name
   set_parameter_property pll_refclk_freq_hwtcl VISIBLE true
   set_parameter_property pll_refclk_freq_hwtcl HDL_PARAMETER true
   set_parameter_property pll_refclk_freq_hwtcl DESCRIPTION "Selects the reference clock frequency for the transceiver block. Both 100 Mhz and 125 MHz are supported."

   # x1 frequency
   add_parameter          set_pld_clk_x1_625MHz_hwtcl integer 0
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl DISPLAY_NAME "Use  62.5 MHz application clock"
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl DISPLAY_HINT boolean
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl GROUP $group_name
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl VISIBLE true
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl HDL_PARAMETER true
   set_parameter_property set_pld_clk_x1_625MHz_hwtcl DESCRIPTION "Only available in x1 configurations."

   # CVP
   add_parameter          in_cvp_mode_hwtcl integer 0
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_NAME "Enable configuration via the PCIe link"
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_HINT boolean
   set_parameter_property in_cvp_mode_hwtcl GROUP $group_name
   set_parameter_property in_cvp_mode_hwtcl VISIBLE true
   set_parameter_property in_cvp_mode_hwtcl HDL_PARAMETER true
   set_parameter_property in_cvp_mode_hwtcl DESCRIPTION "Selects the hard IP block that includes logic to configure the FPGA  via the PCI Express link."

   add_parameter          enable_tl_only_sim_hwtcl integer 0
   set_parameter_property enable_tl_only_sim_hwtcl DISPLAY_NAME "Enable TL-Direct simulation"
   set_parameter_property enable_tl_only_sim_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_tl_only_sim_hwtcl GROUP $group_name
   set_parameter_property enable_tl_only_sim_hwtcl VISIBLE false
   set_parameter_property enable_tl_only_sim_hwtcl HDL_PARAMETER true
   set_parameter_property enable_tl_only_sim_hwtcl DESCRIPTION "When On, enables simulation with TL BFM"


   add_parameter          use_atx_pll_hwtcl integer 0
   set_parameter_property use_atx_pll_hwtcl DISPLAY_NAME "Use ATX PLL"
   set_parameter_property use_atx_pll_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_atx_pll_hwtcl GROUP $group_name
   set_parameter_property use_atx_pll_hwtcl VISIBLE true
   set_parameter_property use_atx_pll_hwtcl HDL_PARAMETER true
   set_parameter_property use_atx_pll_hwtcl DESCRIPTION "When On, use ATX PLL instead of CMU PLL"

   #  Rxm Parameters
   set MAX_PREFETCH_MASTERS 6

 for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {


        add_parameter "SLAVE_ADDRESS_MAP_$i" integer 0
        set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_type ADDRESS_WIDTH
        set_parameter_property "SLAVE_ADDRESS_MAP_$i" system_info_arg "Rxm_BAR${i}"
        set_parameter_property "SLAVE_ADDRESS_MAP_$i" AFFECTS_ELABORATION true
        set_parameter_property "SLAVE_ADDRESS_MAP_$i" VISIBLE false

        add_parameter "CB_P2A_AVALON_ADDR_B${i}" integer "32'h00000000"
        set_parameter_property "CB_P2A_AVALON_ADDR_B${i}" "units" "Address"
        set_parameter_property  "CB_P2A_AVALON_ADDR_B${i}" VISIBLE FALSE
        set_parameter_property  "CB_P2A_AVALON_ADDR_B${i}" HDL_PARAMETER true

  }
}

proc add_pcie_hip_parameters_ui_pci_registers {} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pci_registers"
   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Device Identification Registers"

   add_parameter          vendor_id_hwtcl integer  0
   set_parameter_property vendor_id_hwtcl DISPLAY_NAME "Vendor ID"
   set_parameter_property vendor_id_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property vendor_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property vendor_id_hwtcl GROUP $group_name
   set_parameter_property vendor_id_hwtcl VISIBLE true
   set_parameter_property vendor_id_hwtcl HDL_PARAMETER true
   set_parameter_property vendor_id_hwtcl DESCRIPTION "Sets the read-only value of the Vendor ID register."

   add_parameter          device_id_hwtcl integer 1
   set_parameter_property device_id_hwtcl DISPLAY_NAME "Device ID"
   set_parameter_property device_id_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property device_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property device_id_hwtcl GROUP $group_name
   set_parameter_property device_id_hwtcl VISIBLE true
   set_parameter_property device_id_hwtcl HDL_PARAMETER true
   set_parameter_property device_id_hwtcl DESCRIPTION "Sets the read-only value of the Device ID register."

   add_parameter          revision_id_hwtcl integer 1
   set_parameter_property revision_id_hwtcl DISPLAY_NAME "Revision ID"
   set_parameter_property revision_id_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property revision_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property revision_id_hwtcl GROUP $group_name
   set_parameter_property revision_id_hwtcl VISIBLE true
   set_parameter_property revision_id_hwtcl HDL_PARAMETER true
   set_parameter_property revision_id_hwtcl DESCRIPTION "Sets the read-only value of the Revision ID register."

   add_parameter          class_code_hwtcl integer 0
   set_parameter_property class_code_hwtcl DISPLAY_NAME "Class Code"
   set_parameter_property class_code_hwtcl ALLOWED_RANGES { 0:16777215 }
   set_parameter_property class_code_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property class_code_hwtcl GROUP $group_name
   set_parameter_property class_code_hwtcl VISIBLE true
   set_parameter_property class_code_hwtcl HDL_PARAMETER true
   set_parameter_property class_code_hwtcl DESCRIPTION "Sets the read-only value of the Class code register."

   add_parameter          subsystem_vendor_id_hwtcl integer  0
   set_parameter_property subsystem_vendor_id_hwtcl DISPLAY_NAME "Subsystem Vendor ID"
   set_parameter_property subsystem_vendor_id_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property subsystem_vendor_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property subsystem_vendor_id_hwtcl GROUP $group_name
   set_parameter_property subsystem_vendor_id_hwtcl VISIBLE true
   set_parameter_property subsystem_vendor_id_hwtcl HDL_PARAMETER true
   set_parameter_property subsystem_vendor_id_hwtcl DESCRIPTION "Sets the read-only value of the Subsystem Vendor ID register."

   add_parameter          subsystem_device_id_hwtcl integer 0
   set_parameter_property subsystem_device_id_hwtcl DISPLAY_NAME "Subsystem Device ID"
   set_parameter_property subsystem_device_id_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property subsystem_device_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property subsystem_device_id_hwtcl GROUP $group_name
   set_parameter_property subsystem_device_id_hwtcl VISIBLE true
   set_parameter_property subsystem_device_id_hwtcl HDL_PARAMETER true
   set_parameter_property subsystem_device_id_hwtcl DESCRIPTION "Sets the read-only value of the Subsystem Device ID register."

}


proc add_pcie_hip_parameters_bar_avmm {} {

   set MAX_PREFETCH_MASTERS 6
   add_parameter          NUM_PREFETCH_MASTERS integer 1
   set_parameter_property NUM_PREFETCH_MASTERS DISPLAY_NAME "Number of BARs"
   set_parameter_property NUM_PREFETCH_MASTERS ALLOWED_RANGES "0:$MAX_PREFETCH_MASTERS"
   set_parameter_property NUM_PREFETCH_MASTERS AFFECTS_ELABORATION true
   set_parameter_property NUM_PREFETCH_MASTERS VISIBLE FALSE

   add_pcie_hip_parameters_ui_pci_bar_avmm

   #By default, we have one 64 bit Bar
   for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
      add_parameter "CB_P2A_AVALON_ADDR_B${i}" integer "32'h00000000"
      set_parameter_property "CB_P2A_AVALON_ADDR_B${i}" "units" "Address"
      set_parameter_property  "CB_P2A_AVALON_ADDR_B${i}" VISIBLE FALSE
   }

   add_parameter "fixed_address_mode" string 0
   set_parameter_property  "fixed_address_mode" VISIBLE FALSE

   for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
      add_parameter "CB_P2A_FIXED_AVALON_ADDR_B${i}" integer "32'h00000000"
      set_parameter_property  "CB_P2A_FIXED_AVALON_ADDR_B${i}" VISIBLE FALSE
   }
}

proc add_pcie_hip_parameters_ui_pcie_cap_registers {} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pcie_cap_registers"
   #-----------------------------------------------------------------------------------------------------------------
   set master_group_name "PCI Express/PCI Capabilities"
   add_display_item "" ${master_group_name} group

   set group_name "Device"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter max_payload_size_hwtcl integer 128
   set_parameter_property max_payload_size_hwtcl DISPLAY_NAME "Maximum payload size"
   set_parameter_property max_payload_size_hwtcl ALLOWED_RANGES { "128:128 Bytes" "256:256 Bytes"  }
   set_parameter_property max_payload_size_hwtcl GROUP $group_name
   set_parameter_property max_payload_size_hwtcl VISIBLE true
   set_parameter_property max_payload_size_hwtcl HDL_PARAMETER true
   set_parameter_property max_payload_size_hwtcl DESCRIPTION "Sets the read-only value of the max payload size of the Device Capabilities register and optimizes for this payload size."

   add_parameter          extend_tag_field_hwtcl string "32"
   set_parameter_property extend_tag_field_hwtcl DISPLAY_NAME "Number of tags supported"
   set_parameter_property extend_tag_field_hwtcl ALLOWED_RANGES { "32" }
   set_parameter_property extend_tag_field_hwtcl GROUP $group_name
   set_parameter_property extend_tag_field_hwtcl VISIBLE false
   set_parameter_property extend_tag_field_hwtcl HDL_PARAMETER true
   set_parameter_property extend_tag_field_hwtcl DESCRIPTION "Sets the number of tags supported for non-posted requests transmitted by the Application Layer."

   add_parameter          completion_timeout_hwtcl string "ABCD"
   set_parameter_property completion_timeout_hwtcl DISPLAY_NAME "Completion timeout range"
   set_parameter_property completion_timeout_hwtcl ALLOWED_RANGES { "ABCD" "BCD" "ABC" "BC" "AB" "B" "A" "NONE"}
   set_parameter_property completion_timeout_hwtcl GROUP $group_name
   set_parameter_property completion_timeout_hwtcl VISIBLE true
   set_parameter_property completion_timeout_hwtcl HDL_PARAMETER true
   set_parameter_property completion_timeout_hwtcl DESCRIPTION "Sets the completion timeout range for Root Ports and Endpoints that issue requests on their own behalf in PCI Express version 2.0 or higher. For additional information, refer to the PCI Express User Guide."

   add_parameter enable_completion_timeout_disable_hwtcl integer 1
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_NAME "Implement completion timeout disable"
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_completion_timeout_disable_hwtcl GROUP $group_name
   set_parameter_property enable_completion_timeout_disable_hwtcl VISIBLE true
   set_parameter_property enable_completion_timeout_disable_hwtcl HDL_PARAMETER true
   set_parameter_property enable_completion_timeout_disable_hwtcl DESCRIPTION "Turns the completion timeout mechanism On or Off for Root Ports in PCI Express version 2.0 or higher. This option is forced to On for PCI Express version 2.0 and higher Endpoints."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Error Reporting"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          use_aer_hwtcl integer 0
   set_parameter_property use_aer_hwtcl DISPLAY_NAME "Advanced error reporting (AER)"
   set_parameter_property use_aer_hwtcl GROUP $group_name
   set_parameter_property use_aer_hwtcl VISIBLE true
   set_parameter_property use_aer_hwtcl HDL_PARAMETER true
   set_parameter_property use_aer_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_aer_hwtcl DESCRIPTION "Enables or disables AER."

   add_parameter          ecrc_check_capable_hwtcl integer 0
   set_parameter_property ecrc_check_capable_hwtcl DISPLAY_NAME "ECRC checking"
   set_parameter_property ecrc_check_capable_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_check_capable_hwtcl GROUP $group_name
   set_parameter_property ecrc_check_capable_hwtcl VISIBLE true
   set_parameter_property ecrc_check_capable_hwtcl HDL_PARAMETER true
   set_parameter_property ecrc_check_capable_hwtcl DESCRIPTION "Enables or disables ECRC checking. When enabled, AER must also be On."

   add_parameter          ecrc_gen_capable_hwtcl integer 0
   set_parameter_property ecrc_gen_capable_hwtcl DISPLAY_NAME "ECRC generation"
   set_parameter_property ecrc_gen_capable_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_gen_capable_hwtcl GROUP $group_name
   set_parameter_property ecrc_gen_capable_hwtcl VISIBLE true
   set_parameter_property ecrc_gen_capable_hwtcl HDL_PARAMETER true
   set_parameter_property ecrc_gen_capable_hwtcl DESCRIPTION "Enables or disables ECRC generation."

   add_parameter          use_crc_forwarding_hwtcl integer 0
   set_parameter_property use_crc_forwarding_hwtcl DISPLAY_NAME "ECRC forwarding"
   set_parameter_property use_crc_forwarding_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_crc_forwarding_hwtcl GROUP $group_name
   set_parameter_property use_crc_forwarding_hwtcl VISIBLE false
   set_parameter_property use_crc_forwarding_hwtcl HDL_PARAMETER true
   set_parameter_property use_crc_forwarding_hwtcl DESCRIPTION "Enables or disables ECRC forwarding."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Link"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          port_link_number_hwtcl integer 1
   set_parameter_property port_link_number_hwtcl DISPLAY_NAME "Link port number"
   set_parameter_property port_link_number_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property port_link_number_hwtcl GROUP $group_name
   set_parameter_property port_link_number_hwtcl VISIBLE true
   set_parameter_property port_link_number_hwtcl HDL_PARAMETER true
   set_parameter_property port_link_number_hwtcl DESCRIPTION "Sets the read-only value of the port number field in the Link Capabilities register."

   add_parameter          dll_active_report_support_hwtcl integer 0
   set_parameter_property dll_active_report_support_hwtcl DISPLAY_NAME "Data link layer active reporting"
   set_parameter_property dll_active_report_support_hwtcl DISPLAY_HINT boolean
   set_parameter_property dll_active_report_support_hwtcl GROUP $group_name
   set_parameter_property dll_active_report_support_hwtcl VISIBLE false
   set_parameter_property dll_active_report_support_hwtcl HDL_PARAMETER true
   set_parameter_property dll_active_report_support_hwtcl DESCRIPTION "Enables or disables Data Link Layer (DLL) active reporting."

   add_parameter          surprise_down_error_support_hwtcl integer 0
   set_parameter_property surprise_down_error_support_hwtcl DISPLAY_NAME "Surprise down reporting"
   set_parameter_property surprise_down_error_support_hwtcl DISPLAY_HINT boolean
   set_parameter_property surprise_down_error_support_hwtcl GROUP $group_name
   set_parameter_property surprise_down_error_support_hwtcl VISIBLE false
   set_parameter_property surprise_down_error_support_hwtcl HDL_PARAMETER true
   set_parameter_property surprise_down_error_support_hwtcl DESCRIPTION "Enables or disables surprise down reporting."

   add_parameter          slotclkcfg_hwtcl integer 1
   set_parameter_property slotclkcfg_hwtcl DISPLAY_NAME "Slot clock configuration"
   set_parameter_property slotclkcfg_hwtcl DISPLAY_HINT boolean
   set_parameter_property slotclkcfg_hwtcl GROUP $group_name
   set_parameter_property slotclkcfg_hwtcl VISIBLE true
   set_parameter_property slotclkcfg_hwtcl HDL_PARAMETER true
   set_parameter_property slotclkcfg_hwtcl DESCRIPTION "Sets the read-only value of the slot clock configuration bit in the link status register."

   # TODO Add Link COmmon Clock parameters

  #-----------------------------------------------------------------------------------------------------------------
   set group_name "MSI"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          msi_multi_message_capable_hwtcl string        "4"
   set_parameter_property msi_multi_message_capable_hwtcl DISPLAY_NAME "Number of MSI messages requested"
   set_parameter_property msi_multi_message_capable_hwtcl ALLOWED_RANGES { "1" "2" "4" "8" "16"}
   set_parameter_property msi_multi_message_capable_hwtcl GROUP $group_name
   set_parameter_property msi_multi_message_capable_hwtcl VISIBLE true
   set_parameter_property msi_multi_message_capable_hwtcl HDL_PARAMETER true
   set_parameter_property msi_multi_message_capable_hwtcl DESCRIPTION "Sets the number of messages that the application can request in the multiple message capable field of the Message Control register."

   add_parameter msi_64bit_addressing_capable_hwtcl string "true"
   set_parameter_property msi_64bit_addressing_capable_hwtcl VISIBLE false
   set_parameter_property msi_64bit_addressing_capable_hwtcl HDL_PARAMETER true

   add_parameter msi_masking_capable_hwtcl string "false"
   set_parameter_property msi_masking_capable_hwtcl VISIBLE false
   set_parameter_property msi_masking_capable_hwtcl HDL_PARAMETER true
   add_parameter msi_support_hwtcl string "true"
   set_parameter_property msi_support_hwtcl VISIBLE false
   set_parameter_property msi_support_hwtcl HDL_PARAMETER true

    #-----------------------------------------------------------------------------------------------------------------
   set group_name "MSI-X"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter enable_function_msix_support_hwtcl integer 0
   set_parameter_property enable_function_msix_support_hwtcl DISPLAY_NAME "Implement MSI-X"
   set_parameter_property enable_function_msix_support_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_function_msix_support_hwtcl GROUP $group_name
   set_parameter_property enable_function_msix_support_hwtcl VISIBLE true
   set_parameter_property enable_function_msix_support_hwtcl HDL_PARAMETER true
   set_parameter_property enable_function_msix_support_hwtcl DESCRIPTION "Enables or disables the MSI-X capability."

   add_parameter          msix_table_size_hwtcl integer 0
   set_parameter_property msix_table_size_hwtcl DISPLAY_NAME "Table size"
   set_parameter_property msix_table_size_hwtcl ALLOWED_RANGES { 0:2047 }
   set_parameter_property msix_table_size_hwtcl GROUP $group_name
   set_parameter_property msix_table_size_hwtcl VISIBLE true
   set_parameter_property msix_table_size_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_size_hwtcl DESCRIPTION "Sets the number of entries in the MSI-X table."

   add_parameter          msix_table_offset_hwtcl long 0
   set_parameter_property msix_table_offset_hwtcl DISPLAY_NAME "Table offset"
   set_parameter_property msix_table_offset_hwtcl ALLOWED_RANGES { 0:4294967295 }
   set_parameter_property msix_table_offset_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property msix_table_offset_hwtcl GROUP $group_name
   set_parameter_property msix_table_offset_hwtcl VISIBLE true
   set_parameter_property msix_table_offset_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_offset_hwtcl DESCRIPTION "Sets the read-only base address of the MSI-X table. The low-order 3 bits are automatically set to 0."

   add_parameter          msix_table_bir_hwtcl integer 0
   set_parameter_property msix_table_bir_hwtcl DISPLAY_NAME "Table BAR indicator"
   set_parameter_property msix_table_bir_hwtcl ALLOWED_RANGES { 0:5 }
   set_parameter_property msix_table_bir_hwtcl GROUP $group_name
   set_parameter_property msix_table_bir_hwtcl VISIBLE true
   set_parameter_property msix_table_bir_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_bir_hwtcl DESCRIPTION "Specifies which one of a function's base address registers, located beginning at 0x10 in the Configuration Space, maps the MSI-X table into memory space. This field is read-only."

   add_parameter          msix_pba_offset_hwtcl long 0
   set_parameter_property msix_pba_offset_hwtcl DISPLAY_NAME "Pending bit array (PBA) offset"
   set_parameter_property msix_pba_offset_hwtcl ALLOWED_RANGES { 0:4294967295 }
   set_parameter_property msix_pba_offset_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property msix_pba_offset_hwtcl GROUP $group_name
   set_parameter_property msix_pba_offset_hwtcl VISIBLE true
   set_parameter_property msix_pba_offset_hwtcl HDL_PARAMETER true
   set_parameter_property msix_pba_offset_hwtcl DESCRIPTION "Specifies the offset from the address stored in one of the function's base address registers the points to the base of the MSI-X PBA. This field is read-only."

   add_parameter          msix_pba_bir_hwtcl integer 0
   set_parameter_property msix_pba_bir_hwtcl DISPLAY_NAME "PBA BAR Indicator"
   set_parameter_property msix_pba_bir_hwtcl ALLOWED_RANGES { 0:5 }
   set_parameter_property msix_pba_bir_hwtcl GROUP $group_name
   set_parameter_property msix_pba_bir_hwtcl VISIBLE true
   set_parameter_property msix_pba_bir_hwtcl HDL_PARAMETER true
   set_parameter_property msix_pba_bir_hwtcl DESCRIPTION "Indicates which of a function's base address registers, located beginning at 0x10 in the Configuration Space, maps the function's MSI-X PBA into memory space. This field is read-only."

   #-----------------------------------------------------------------------------------------------------------------
   #set group_name "Slot"
   #add_display_item ${master_group_name} ${group_name} group
   #set_display_item_property ${group_name} display_hint tab

   add_parameter          enable_slot_register_hwtcl integer 0
   set_parameter_property enable_slot_register_hwtcl DISPLAY_NAME "Use slot register"
   set_parameter_property enable_slot_register_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_slot_register_hwtcl GROUP $group_name
   set_parameter_property enable_slot_register_hwtcl VISIBLE false
   set_parameter_property enable_slot_register_hwtcl HDL_PARAMETER true
   set_parameter_property enable_slot_register_hwtcl DESCRIPTION "Enables the slot register when Enabled. This register is required for Root Ports if a slot is implemented on the port. Slot status is recorded in the PCI Express Capabilities register."


   add_parameter          slot_power_scale_hwtcl integer 0
   set_parameter_property slot_power_scale_hwtcl DISPLAY_NAME "Slot power scale"
   set_parameter_property slot_power_scale_hwtcl ALLOWED_RANGES { 0:3 }
   set_parameter_property slot_power_scale_hwtcl GROUP $group_name
   set_parameter_property slot_power_scale_hwtcl VISIBLE false
   set_parameter_property slot_power_scale_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_scale_hwtcl DESCRIPTION "Sets the scale used for the Slot power limit value, as follows: 0=1.0<n>, 1=0.1<n>, 2=0.01<n>, 3=0.001<n>."

   add_parameter          slot_power_limit_hwtcl integer 0
   set_parameter_property slot_power_limit_hwtcl DISPLAY_NAME "Slot power limit"
   set_parameter_property slot_power_limit_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property slot_power_limit_hwtcl GROUP $group_name
   set_parameter_property slot_power_limit_hwtcl VISIBLE false
   set_parameter_property slot_power_limit_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_limit_hwtcl DESCRIPTION "Sets the upper limit (in Watts) of power supplied by the slot in conjunction with the slot power scale register. For more information, refer to the PCI Express Base Specification."

   add_parameter          slot_number_hwtcl integer 0
   set_parameter_property slot_number_hwtcl DISPLAY_NAME "Slot number"
   set_parameter_property slot_number_hwtcl ALLOWED_RANGES { 0:8191 }
   set_parameter_property slot_number_hwtcl GROUP $group_name
   set_parameter_property slot_number_hwtcl VISIBLE false
   set_parameter_property slot_number_hwtcl HDL_PARAMETER true
   set_parameter_property slot_number_hwtcl DESCRIPTION "Specifies the physical slot number associated with a port."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Power Management"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab


   add_parameter endpoint_l0_latency_hwtcl integer 0
   set_parameter_property endpoint_l0_latency_hwtcl DISPLAY_NAME "Endpoint L0s acceptable latency"
   set_parameter_property endpoint_l0_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 64 ns" "1:Maximum of 128 ns" "2:Maximum of 256 ns" "3:Maximum of 512 ns" "4:Maximum of 1 us" "5:Maximum of 2 us" "6:Maximum of 4 us" "7:No limit" }
   set_parameter_property endpoint_l0_latency_hwtcl GROUP $group_name
   set_parameter_property endpoint_l0_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l0_latency_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l0_latency_hwtcl DESCRIPTION "Sets the read-only value of the Endpoint L0s acceptable latency field of the Device Capabilities register. This value should be based on the latency that the Application Layer can tolerate. This setting is disabled for Root Ports."

   add_parameter endpoint_l1_latency_hwtcl integer 0
   set_parameter_property endpoint_l1_latency_hwtcl DISPLAY_NAME "Endpoint L1 acceptable latency"
   set_parameter_property endpoint_l1_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 1 us" "1:Maximum of 2 us" "2:Maximum of 4 us" "3:Maximum of 8 us" "4:Maximum of 16 us" "5:Maximum of 32 us" "6:Maximum of 64 us" "7:No limit" }
   set_parameter_property endpoint_l1_latency_hwtcl GROUP $group_name
   set_parameter_property endpoint_l1_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l1_latency_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l1_latency_hwtcl DESCRIPTION "Sets the acceptable latency that an Endpoint can withstand in the transition from the L1 to L0 state. It is an indirect measure of the Endpoint internal buffering. This setting is disabled for Root Ports."

}

proc add_avalon_mm_parameters {} {
   # +------------------------------PAGE 6 ( Avalon )-------------------------------------------------------------
   send_message debug "proc:add_avalon_mm_parameters"

   set group_name "Avalon-MM System Settings"

   add_parameter CG_COMMON_CLOCK_MODE integer 1
   set_parameter_property  CG_COMMON_CLOCK_MODE VISIBLE false

   add_parameter          avmm_width_hwtcl integer 64
   set_parameter_property avmm_width_hwtcl DISPLAY_NAME "Avalon-MM data width"
   set_parameter_property avmm_width_hwtcl ALLOWED_RANGES {"64:64-bit" "128:128-bit"}
   set_parameter_property avmm_width_hwtcl DESCRIPTION "Select the Avalon-MM bus width"
   set_parameter_property avmm_width_hwtcl GROUP $group_name
   set_parameter_property avmm_width_hwtcl VISIBLE true
   set_parameter_property avmm_width_hwtcl HDL_PARAMETER true

   add_parameter          AVALON_ADDR_WIDTH integer 32
   set_parameter_property AVALON_ADDR_WIDTH DISPLAY_NAME "Avalon-MM  address width"
   set_parameter_property AVALON_ADDR_WIDTH ALLOWED_RANGES {"32:32-bit" "64:64-bit"}
   set_parameter_property AVALON_ADDR_WIDTH DESCRIPTION "Select the Avalon-MM address width"
   set_parameter_property AVALON_ADDR_WIDTH GROUP $group_name
   set_parameter_property AVALON_ADDR_WIDTH VISIBLE true
   set_parameter_property AVALON_ADDR_WIDTH HDL_PARAMETER true

   add_parameter          avmm_burst_width_hwtcl integer 7
   set_parameter_property avmm_burst_width_hwtcl VISIBLE false
   set_parameter_property  avmm_burst_width_hwtcl DERIVED true
   set_parameter_property avmm_burst_width_hwtcl HDL_PARAMETER true

   add_parameter          CB_PCIE_MODE integer 0
   set_parameter_property CB_PCIE_MODE DISPLAY_NAME "Peripheral mode"
   set_parameter_property CB_PCIE_MODE ALLOWED_RANGES {"0:Requester/Completer" "1:Completer-Only"}
   set_parameter_property CB_PCIE_MODE DESCRIPTION "Select the bridge operation mode for smaller area utilization where applicable."
   set_parameter_property CB_PCIE_MODE GROUP $group_name
   set_parameter_property CB_PCIE_MODE VISIBLE true
   set_parameter_property CB_PCIE_MODE HDL_PARAMETER true


   add_parameter          CB_PCIE_RX_LITE integer 0
   set_parameter_property CB_PCIE_RX_LITE DISPLAY_NAME "Single DW Completer"
   set_parameter_property CB_PCIE_RX_LITE DISPLAY_HINT boolean
   set_parameter_property CB_PCIE_RX_LITE DESCRIPTION "The core supports one DW read/write to reduce area and improve timming"
   set_parameter_property CB_PCIE_RX_LITE GROUP $group_name
   set_parameter_property CB_PCIE_RX_LITE VISIBLE true
   set_parameter_property CB_PCIE_RX_LITE HDL_PARAMETER true

   add_parameter CB_RXM_DATA_WIDTH integer 64
   set_parameter_property  CB_RXM_DATA_WIDTH VISIBLE false
   set_parameter_property  CB_RXM_DATA_WIDTH DERIVED true
   set_parameter_property  CB_RXM_DATA_WIDTH HDL_PARAMETER true

   add_parameter AST_LITE integer 0
   set_parameter_property  AST_LITE VISIBLE false

   add_parameter CG_RXM_IRQ_NUM integer 16
   set_parameter_property  CG_RXM_IRQ_NUM VISIBLE false

   add_parameter CG_AVALON_S_ADDR_WIDTH integer 20
   set_parameter_property  CG_AVALON_S_ADDR_WIDTH VISIBLE false
   set_parameter_property  CG_AVALON_S_ADDR_WIDTH DERIVED true
   set_parameter_property  CG_AVALON_S_ADDR_WIDTH HDL_PARAMETER true
   add_parameter bypass_tl string "false"
   set_parameter_property  bypass_tl VISIBLE false

   add_parameter          CG_IMPL_CRA_AV_SLAVE_PORT integer 1
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT DISPLAY_NAME "Control register access (CRA) Avalon-MM slave port"
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT DISPLAY_HINT boolean
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT GROUP $group_name
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT VISIBLE true
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT HDL_PARAMETER true
   set_parameter_property CG_IMPL_CRA_AV_SLAVE_PORT DESCRIPTION "Enable/Disable the Control Register Access port"


   add_parameter          CG_ENABLE_ADVANCED_INTERRUPT integer 0
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT DISPLAY_NAME " Enable multiple MSI/MSI-X support"
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT DISPLAY_HINT boolean
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT GROUP $group_name
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT VISIBLE true
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT HDL_PARAMETER false
   set_parameter_property CG_ENABLE_ADVANCED_INTERRUPT DESCRIPTION "Exported internal signals to support generation of multiple MSI/MSI-X"


   add_parameter          CG_ENABLE_A2P_INTERRUPT integer 0
   set_parameter_property CG_ENABLE_A2P_INTERRUPT DISPLAY_NAME " Auto enable PCIe interrupt (enabled at power-on)"
   set_parameter_property CG_ENABLE_A2P_INTERRUPT DISPLAY_HINT boolean
   set_parameter_property CG_ENABLE_A2P_INTERRUPT GROUP $group_name
   set_parameter_property CG_ENABLE_A2P_INTERRUPT VISIBLE true
   set_parameter_property CG_ENABLE_A2P_INTERRUPT HDL_PARAMETER true
   set_parameter_property CG_ENABLE_A2P_INTERRUPT DESCRIPTION "Enable/Disable the PCI Express interrupt enable register automatically at power-up "
   
   add_parameter          CG_ENABLE_HIP_STATUS integer 0                                             
   set_parameter_property CG_ENABLE_HIP_STATUS DISPLAY_NAME "Enable HIP Status Bus"                  
   set_parameter_property CG_ENABLE_HIP_STATUS DISPLAY_HINT boolean                                  
   set_parameter_property CG_ENABLE_HIP_STATUS GROUP $group_name                                     
   set_parameter_property CG_ENABLE_HIP_STATUS VISIBLE true                                          
   set_parameter_property CG_ENABLE_HIP_STATUS HDL_PARAMETER false                                   
   set_parameter_property CG_ENABLE_HIP_STATUS DESCRIPTION "Exported HP status"    


   add_parameter          CG_ENABLE_HIP_STATUS_EXTENSION integer 0
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION DISPLAY_NAME "Enable HIP Status Extension Bus"
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION DISPLAY_HINT boolean
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION GROUP $group_name
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION VISIBLE true
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION HDL_PARAMETER false
   set_parameter_property CG_ENABLE_HIP_STATUS_EXTENSION DESCRIPTION "Exported HP status and streaming bus"

    add_parameter          TX_S_ADDR_WIDTH integer 32
    set_parameter_property TX_S_ADDR_WIDTH DISPLAY_NAME "Address width of accessible PCIe memory space"
    set_parameter_property TX_S_ADDR_WIDTH ALLOWED_RANGES {20:64}
    set_parameter_property TX_S_ADDR_WIDTH DESCRIPTION "The address width of accessible memory space"
    set_parameter_property TX_S_ADDR_WIDTH GROUP $group_name
    set_parameter_property TX_S_ADDR_WIDTH VISIBLE true
    set_parameter_property TX_S_ADDR_WIDTH HDL_PARAMETER false

  set group_name_address_trans "Avalon to PCIe Address Translation Settings"

   add_parameter          CB_A2P_ADDR_MAP_IS_FIXED integer 0
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED DISPLAY_NAME "Address translation table configuration"
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED ALLOWED_RANGES {"0:Dynamic translation table" "1:Fixed translation table"}
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED DESCRIPTION "Set the address translation mode. Dynamic translation requires software to setup the table. Fixed mode translation is hardwired at generation time."
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED GROUP $group_name_address_trans
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED VISIBLE false
   set_parameter_property CB_A2P_ADDR_MAP_IS_FIXED HDL_PARAMETER true

   add_parameter          CB_A2P_ADDR_MAP_NUM_ENTRIES integer 2
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES DISPLAY_NAME "Number of address pages"
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES ALLOWED_RANGES {"2" "4" "8" "16" "32" "64" "128" "256" "512"}
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES DESCRIPTION "Set the number of in-consecutive address ranges of the PCI Express system that can be accessed "
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES GROUP $group_name_address_trans
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES VISIBLE true
   set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES HDL_PARAMETER true

   add_parameter          CB_A2P_ADDR_MAP_PASS_THRU_BITS integer 20
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS DISPLAY_NAME "Size of address pages"
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS ALLOWED_RANGES {"12:4 KByte - 12 bits" "13:8 KByte - 13 bits" "14:16 KByte - 14 bits" "15:32 KBytes - 15 bits" "16:64 KBytes - 16 bits" "17:128 KBytes - 17 bits" "18:256 KBytes - 18 bits" "19:512 KBytes - 19 bits" "20:1 MByte - 20 bits" "21:2 MByte - 21 bits" "22:4 MByte - 22 bits" "23:8 MByte - 23 bits" "24:16 MByte - 24 bits" "25:32 MBytes - 25 bits" "26:64 MBytes - 26 bits" "27:128 MBytes - 27 bits" "28:256 MBytes - 28 bits" "29:512 MBytes - 29 bits" "30:1 GByte - 30 bits" "31:2 GByte - 31 bits" "32:4 GByte - 32 bits"}
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS DESCRIPTION "Set the size of the PCI Express system pages. All pages must be the same size "
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS GROUP $group_name_address_trans
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS VISIBLE true
   set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS HDL_PARAMETER true

   add_parameter          BYPASSS_A2P_TRANSLATION integer 0
   set_parameter_property BYPASSS_A2P_TRANSLATION DISPLAY_NAME "Disable address translation"
   set_parameter_property BYPASSS_A2P_TRANSLATION DISPLAY_HINT boolean
   set_parameter_property BYPASSS_A2P_TRANSLATION GROUP $group_name_address_trans
   set_parameter_property BYPASSS_A2P_TRANSLATION VISIBLE false
   set_parameter_property BYPASSS_A2P_TRANSLATION HDL_PARAMETER true
   set_parameter_property BYPASSS_A2P_TRANSLATION DESCRIPTION "Disable address translation "

    add_parameter          CB_RP_S_ADDR_WIDTH integer 32
    set_parameter_property CB_RP_S_ADDR_WIDTH DISPLAY_NAME "Total address width of accessible memory space"
    set_parameter_property CB_RP_S_ADDR_WIDTH ALLOWED_RANGES {4:64}
    set_parameter_property CB_RP_S_ADDR_WIDTH DESCRIPTION "The address width of accessible memory space"
    set_parameter_property CB_RP_S_ADDR_WIDTH GROUP $group_name_address_trans
    set_parameter_property CB_RP_S_ADDR_WIDTH VISIBLE false
    set_parameter_property CB_RP_S_ADDR_WIDTH HDL_PARAMETER false


   ###Here are the CB_A2P_ADDR_MAP_FIXED_TABLE_i_HIGH and CB_A2P_ADDR_MAP_FIXED_TABLE_i_LOW parameters
   for { set i 0 } { $i < 16 } { incr i } {
      add_parameter "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" STD_LOGIC_VECTOR 0
      set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" WIDTH 32
      set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" VISIBLE FALSE

      add_parameter          "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" STD_LOGIC_VECTOR 0
      set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" WIDTH 32
      set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" VISIBLE FALSE
   }

   add_parameter "Address Page" string_list {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
   set_parameter_property "Address Page" DISPLAY_HINT "width:50"
   set_parameter_property "Address Page" DISPLAY_HINT FIXED_SIZE
   set_parameter_property "Address Page" DESCRIPTION "The address translation page number"
   set_parameter_property "Address Page" GROUP $group_name_address_trans
   set_parameter_property "Address Page" VISIBLE false
   set_parameter_property "Address Page" HDL_PARAMETER false

   add_parameter          "PCIe Address 63:32" string_list {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
   set_parameter_property "PCIe Address 63:32" DISPLAY_HINT "width:150"
   set_parameter_property "PCIe Address 63:32" DISPLAY_HINT hexadecimal
   set_parameter_property "PCIe Address 63:32" DESCRIPTION "Set the upper 32-bit of the address translation page"
   set_parameter_property "PCIe Address 63:32" GROUP $group_name_address_trans
   set_parameter_property "PCIe Address 63:32" VISIBLE false
   set_parameter_property "PCIe Address 63:32" HDL_PARAMETER false

   add_parameter           "PCIe Address 31:0" string_list {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
   set_parameter_property  "PCIe Address 31:0" DISPLAY_HINT "width:150"
   set_parameter_property  "PCIe Address 31:0" DISPLAY_HINT hexadecimal
   set_parameter_property  "PCIe Address 31:0" DESCRIPTION "Set the lower 32-bit of the address translation page"
   set_parameter_property  "PCIe Address 31:0" GROUP $group_name_address_trans
   set_parameter_property  "PCIe Address 31:0" VISIBLE false
   set_parameter_property  "PCIe Address 31:0" HDL_PARAMETER false

   add_parameter RXM_DATA_WIDTH integer 64
   set_parameter_property  RXM_DATA_WIDTH VISIBLE false

   add_parameter RXM_BEN_WIDTH integer 8
   set_parameter_property  RXM_BEN_WIDTH VISIBLE false

   #add_display_item "Address Translation Table Contents (Only valid for Fixed Configuration)" "the group" GROUP TABLE
   #add_display_item "the group" "Address Page" PARAMETER
   #add_display_item "the group" "PCIe Address 63:32" PARAMETER
   #add_display_item "the group" "PCIe Address 31:0" PARAMETER
   #
   #set_parameter_property "Address Page" HDL_PARAMETER false
   #set_parameter_property "PCIe Address 63:32" HDL_PARAMETER false
   #set_parameter_property "PCIe Address 31:0" HDL_PARAMETER false

  
}


proc add_pcie_hip_hidden_rtl_parameters {} {

   send_message debug "proc:add_pcie_hip_hidden_rtl_parameters"
   #-----------------------------------------------------------------------------------------------------------------
   add_parameter          ast_width_hwtcl string "Avalon-ST 64-bit"
   set_parameter_property ast_width_hwtcl ALLOWED_RANGES {"Avalon-ST 64-bit" "Avalon-ST 128-bit" "Avalon-ST 256-bit"}
   set_parameter_property ast_width_hwtcl VISIBLE false
   set_parameter_property ast_width_hwtcl DERIVED true
   set_parameter_property ast_width_hwtcl HDL_PARAMETER true

   # RX St BE
   add_parameter          use_rx_st_be_hwtcl integer 0
   set_parameter_property use_rx_st_be_hwtcl VISIBLE false
   set_parameter_property use_rx_st_be_hwtcl HDL_PARAMETER false

   # Parity
   add_parameter          use_ast_parity integer 0
   set_parameter_property use_ast_parity VISIBLE false
   set_parameter_property use_ast_parity HDL_PARAMETER true

   add_parameter          pld_clk_MHz integer 125
   set_parameter_property pld_clk_MHz VISIBLE false
   set_parameter_property pld_clk_MHz HDL_PARAMETER false
   set_parameter_property pld_clk_MHz DERIVED true

   add_parameter millisecond_cycle_count_hwtcl integer 124250
   set_parameter_property millisecond_cycle_count_hwtcl VISIBLE false
   set_parameter_property millisecond_cycle_count_hwtcl HDL_PARAMETER true
   set_parameter_property millisecond_cycle_count_hwtcl DERIVED true


   # PLL Related parameters
   #                                                                _______
   #                                 |-------pld_clk_hip----------->|      |
   #                                 |   (pldclk_hip_phase_shift)   |      |
   #                               __^_                             | HIP  |
   #                              |    |                            |      |
   #                              |PLL |                            |      |
   #   <------coreclkout<--------<|____|<------coreclkout_hip------<|______|
   #    (coreclkout_hip_phaseshift)
   #
  #add_parameter coreclkout_hip_phaseshift_hwtcl string "0 ps"
  #set_parameter_property coreclkout_hip_phaseshift_hwtcl VISIBLE false
  #set_parameter_property coreclkout_hip_phaseshift_hwtcl HDL_PARAMETER true

  #add_parameter pldclk_hip_phase_shift_hwtcl string "0 ps"
  #set_parameter_property pldclk_hip_phase_shift_hwtcl VISIBLE false
  #set_parameter_property pldclk_hip_phase_shift_hwtcl HDL_PARAMETER true

   add_parameter          port_width_be_hwtcl integer 8
   set_parameter_property port_width_be_hwtcl VISIBLE false
   set_parameter_property port_width_be_hwtcl HDL_PARAMETER true
   set_parameter_property port_width_be_hwtcl DERIVED true

   add_parameter          port_width_data_hwtcl integer 64
   set_parameter_property port_width_data_hwtcl VISIBLE false
   set_parameter_property port_width_data_hwtcl DERIVED true
   set_parameter_property port_width_data_hwtcl HDL_PARAMETER true

   # Reserved debug pins

   add_parameter          hip_reconfig_hwtcl integer 0
   set_parameter_property hip_reconfig_hwtcl VISIBLE false
   set_parameter_property hip_reconfig_hwtcl HDL_PARAMETER true

   add_parameter          vsec_id_hwtcl integer 40960
   set_parameter_property vsec_id_hwtcl VISIBLE false
   set_parameter_property vsec_id_hwtcl HDL_PARAMETER true

    add_parameter         vsec_rev_hwtcl integer 0
   set_parameter_property vsec_rev_hwtcl VISIBLE false
   set_parameter_property vsec_rev_hwtcl HDL_PARAMETER true


   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Expansion ROM"
   add_parameter          expansion_base_address_register_hwtcl integer 0
   set_parameter_property expansion_base_address_register_hwtcl DISPLAY_NAME "Size"
   set_parameter_property expansion_base_address_register_hwtcl ALLOWED_RANGES { "0:Disabled" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits"}
   set_parameter_property expansion_base_address_register_hwtcl GROUP $group_name
   set_parameter_property expansion_base_address_register_hwtcl VISIBLE false
   set_parameter_property expansion_base_address_register_hwtcl HDL_PARAMETER true
   set_parameter_property expansion_base_address_register_hwtcl DESCRIPTION "Specifies an expansion ROM from 4 KBytes - 16 MBytes when enabled."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Base and Limit Registers for Root Port"

   add_parameter io_window_addr_width_hwtcl integer 0
   set_parameter_property io_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:16-bit I/O addressing" "2:32-bit I/O addressing "}
   set_parameter_property io_window_addr_width_hwtcl DISPLAY_NAME "Input/Output"
   set_parameter_property io_window_addr_width_hwtcl VISIBLE false
   set_parameter_property io_window_addr_width_hwtcl GROUP $group_name
   set_parameter_property io_window_addr_width_hwtcl HDL_PARAMETER false
   set_parameter_property io_window_addr_width_hwtcl DESCRIPTION "Specifies Input/Output base and limit register."

   add_parameter prefetchable_mem_window_addr_width_hwtcl integer 0
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl DISPLAY_NAME "Prefetchable memory"
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:32-bit memory addressing" "2:64-bit memory addressing "}
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl VISIBLE false
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl HDL_PARAMETER true
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl GROUP $group_name
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl DESCRIPTION "Specifies an expansion prefetchable memory base and limit register."

}
proc update_default_value_hidden_avmm_parameter {} {
   # Internal Avalon-ST Width
   set avmm_width [ get_parameter_value avmm_width_hwtcl ]
   if { [ regexp 128 $avmm_width ] } {
      set_parameter_value ast_width_hwtcl  "Avalon-ST 128-bit"
   } else {
      set_parameter_value ast_width_hwtcl  "Avalon-ST 64-bit"
   }
}


proc isBarUsed { index } {
    set result 1
    # split the contents on ,
    set bar_type_list [split [ get_parameter_value "BAR Type" ] ","]
    set value_at_index [lindex $bar_type_list $index]
    if {[ string compare -nocase $value_at_index "Not used" ] == 0 } {
        set result 0
    }
    return $result
}

proc is64bitBar { index } {

    set result 0
    # split the contents on ,
    set bar_type_list [split [ get_parameter_value "BAR Type" ] ","]
    set value_at_index [lindex $bar_type_list $index]
    if {[ string compare -nocase $value_at_index "64 bit Prefetchable" ] == 0 } {
        set result 1
    }
    return $result
}

proc calculate_avalon_s_address_width {i_CB_A2P_ADDR_MAP_NUM_ENTRIES i_CG_AVALON_S_ADDR_WIDTH } {

set my_CG_AVALON_S_ADDR_WIDTH $i_CG_AVALON_S_ADDR_WIDTH
switch $i_CB_A2P_ADDR_MAP_NUM_ENTRIES {
        1 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH]}
        2 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 1]}
        4 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 2]}
        8 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 3]}
        16 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 4]}
        32 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 5]}
        64 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 6]}
        128 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 7]}
        256 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 8]}
        512 {set my_CG_AVALON_S_ADDR_WIDTH [expr $i_CG_AVALON_S_ADDR_WIDTH + 9]}
        default { }
    }
        return $my_CG_AVALON_S_ADDR_WIDTH
}

proc validation_parameter_system_setting {} {

   set avmm_width                  [ get_parameter_value avmm_width_hwtcl            ]
   set lane_mask_hwtcl             [ get_parameter_value lane_mask_hwtcl             ]
   set gen123_lane_rate_mode_hwtcl [ get_parameter_value gen123_lane_rate_mode_hwtcl ]
   set set_pld_clk_x1_625MHz_hwtcl [ get_parameter_value set_pld_clk_x1_625MHz_hwtcl ]
   set pll_refclk_freq_hwtcl       [ get_parameter_value pll_refclk_freq_hwtcl ]
   set use_atx_pll                       [ get_parameter_value use_atx_pll_hwtcl     ]

# spec version
  if { [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
   set_parameter_value pcie_spec_version_hwtcl "3.0"
  }

   if { $set_pld_clk_x1_625MHz_hwtcl == 1 } {
      if { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] && [ regexp $use_atx_pll 0 ] } {
         send_message info "The application clock frequency (pld_clk) is 62.5 Mhz"
      } else {
         send_message error "62.5 Mhz application clock setting is only valid for Gen1 x1 with CMU PLL"
      }
   }

   if { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x1
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { $set_pld_clk_x1_625MHz_hwtcl == 0 } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            set_parameter_value pld_clk_MHz 625
            set_parameter_value millisecond_cycle_count_hwtcl 62125
         }
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen1:x2
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
        
      }
   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x4
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using $gen123_lane_rate_mode_hwtcl  $lane_mask_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
       
      }
   } elseif { [ regexp x8 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x8
      if { [ regexp 256 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit or 128-bit when using  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { [ regexp 128 $avmm_width ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
        
      }


   } elseif { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen2:x1
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { $set_pld_clk_x1_625MHz_hwtcl == 0 } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } 
      }

      } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen2:x2
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
        
      }

   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen2:x4
      if { [ regexp 256 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit or 128-bit when using  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { [ regexp 128 $avmm_width ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
        
      }

    } elseif { [ regexp x8 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen2:x8
      if { [ regexp 64 $avmm_width ] } {
         send_message error "The application interface must be set to 128-bit when using  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { [ regexp 256 $avmm_width ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
        
      }

   } elseif { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen3:x1
      if { [ regexp 256 $avmm_width ] || [ regexp 128 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit when using $gen123_lane_rate_mode_hwtcl  $lane_mask_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
         
      }

   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen3:x2
      if { [ regexp 256 $avmm_width ] } {
         send_message error "The application interface must be set to 64-bit or 128-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 128 $avmm_width ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
        
      }

   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen3:x4
      if { [ regexp 64 $avmm_width ] } {
         send_message error "The application interface must be set to 128-bit when using $gen123_lane_rate_mode_hwtcl  $lane_mask_hwtcl"
      } else {
         if { [ regexp 256 $avmm_width ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
      }
    } else {
       send_message error "  $gen123_lane_rate_mode_hwtcl $lane_mask_hwtcl is not supported"
   }




   ##################################################################################################
   #
   # Setting AST Port width parameters
   set dataWidth        [ expr [ regexp 256 $avmm_width  ] ? 256 : [ regexp 128 $avmm_width ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $avmm_width  ] ? 32  : [ regexp 128 $avmm_width ] ? 16 : 8 ]
   set_parameter_value port_width_data_hwtcl      $dataWidth
   set_parameter_value port_width_be_hwtcl        $dataByteWidth


   ##################################################################################################
   #
   # Interface properties update
   set pld_clk_MHz [ get_parameter_value pld_clk_MHz ]
   set_interface_property coreclkout clockRate [expr {$pld_clk_MHz * 100000}]
   set pll_refclk_freq  [ get_parameter_value pll_refclk_freq_hwtcl]
   set refclk_hz        [ expr [ regexp 125 $pll_refclk_freq  ] ? 125000000 :  100000000 ]
   set_interface_property refclk clockRate $refclk_hz

    #########################################################################################################
   #
   # Set RXM Data With paramter
   set rx_lite_core [ get_parameter_value CB_PCIE_RX_LITE ]
   if { $rx_lite_core == 0 } {
     set_parameter_value CB_RXM_DATA_WIDTH $avmm_width
     } else {
     set_parameter_value CB_RXM_DATA_WIDTH 32
     }

}


proc validation_parameter_bar {} {

    set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]
    if { [ regexp Root $port_type_hwtcl ] } {
     set_display_item_property "Base Address Registers" VISIBLE false
   } else {
   	 set_display_item_property "Base Address Registers" VISIBLE true
  }

   set  bar_size_mask_hwtcl(0) [ get_parameter_value bar0_size_mask_hwtcl ]
   set  bar_size_mask_hwtcl(1) [ get_parameter_value bar1_size_mask_hwtcl ]
   set  bar_size_mask_hwtcl(2) [ get_parameter_value bar2_size_mask_hwtcl ]
   set  bar_size_mask_hwtcl(3) [ get_parameter_value bar3_size_mask_hwtcl ]
   set  bar_size_mask_hwtcl(4) [ get_parameter_value bar4_size_mask_hwtcl ]
   set  bar_size_mask_hwtcl(5) [ get_parameter_value bar5_size_mask_hwtcl ]

   set  bar_ignore_warning_size(0) 0
   set  bar_ignore_warning_size(1) 0
   set  bar_ignore_warning_size(2) 0
   set  bar_ignore_warning_size(3) 0
   set  bar_ignore_warning_size(4) 0
   set  bar_ignore_warning_size(5) 0

   set  bar_type_hwtcl(0) [ get_parameter_value bar0_type_hwtcl ]
   set  bar_type_hwtcl(1) [ get_parameter_value bar1_type_hwtcl ]
   set  bar_type_hwtcl(2) [ get_parameter_value bar2_type_hwtcl ]
   set  bar_type_hwtcl(3) [ get_parameter_value bar3_type_hwtcl ]
   set  bar_type_hwtcl(4) [ get_parameter_value bar4_type_hwtcl ]
   set  bar_type_hwtcl(5) [ get_parameter_value bar5_type_hwtcl ]

   set enable_function_msix_support_hwtcl [ get_parameter_value enable_function_msix_support_hwtcl]

   set DISABLE_BAR             0
   set PREFETACHBLE_64_BAR     1
   set NON_PREFETCHABLE_32_BAR 2
   set PREFETCHABLE_32_BAR     3
   set IO_SPACE_BAR            4

   if { [ regexp endpoint $port_type_hwtcl ] } {
      if { $bar_type_hwtcl(0) == $DISABLE_BAR && $bar_type_hwtcl(1) == $DISABLE_BAR && $bar_type_hwtcl(2) == $DISABLE_BAR && $bar_type_hwtcl(3) == $DISABLE_BAR && $bar_type_hwtcl(4) == $DISABLE_BAR && $bar_type_hwtcl(5) == $DISABLE_BAR } {
         send_message error "An Endpoint requires to enable a minimum of one BAR"
      }
      # 64-bit address checking
      for {set i 0} {$i < 3} {incr i 2} {
         if { $bar_type_hwtcl($i) == $PREFETACHBLE_64_BAR } {
            set ii [ expr $i+1 ]
            set bar_ignore_warning_size($ii) 1
            if { $bar_type_hwtcl($ii) > 0 } {
               set bar_type_hwtcl($ii) $DISABLE_BAR;
               send_message warning "BAR$ii is disabled as BAR$i is set to 64-bit prefetchable memory"
            }
         }
      }
      if { [ regexp Native $port_type_hwtcl ] } {
         for {set i 0} {$i < 6} {incr i 1} {
            if { $bar_type_hwtcl($i) == $PREFETCHABLE_32_BAR } {
               send_message error "BAR$i cannot be set to 32-bit prefetchable memory for Native Endpoint"
            }
            if { $bar_type_hwtcl($i) == $IO_SPACE_BAR } {
               send_message error "BAR$i cannot be set to IO Address Space for Native Endpoint"
            }
         }
      }
   } else {
      set expansion_base_address_register [ get_parameter_value expansion_base_address_register_hwtcl ]
      if { $expansion_base_address_register > 0 } {
         send_message error "Expansion ROM must be Disabled when using Root port"
      }
      if { $bar_type_hwtcl(0) == $PREFETACHBLE_64_BAR } {
         set bar_ignore_warning_size(1) 1
         if { $bar_type_hwtcl(1) > 0 } {
            set bar_type_hwtcl(1) $DISABLE_BAR
            send_message warning "BAR1 is disabled as BAR0 is set to 64-bit prefetchable memory"
         }
      }
      for {set i 0} {$i < 6} {incr i 1} {
         if {  $bar_type_hwtcl($i) > 0 } {
            send_message error "All BAR must be Disabled when using Root port"
         }
      }
   }

   # Setting derived parameter
   for {set i 0} {$i < 6} {incr i 1} {
      if { $bar_type_hwtcl($i)>0 } {
         if { $bar_size_mask_hwtcl($i)==0 && $bar_ignore_warning_size($i)==0 } {
          #  send_message error "The size of BAR$i is incorrectly set"
         }
      }
      if { $bar_type_hwtcl($i)== $DISABLE_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>0 && $bar_ignore_warning_size($i)==0 && [ regexp Native $port_type_hwtcl ] } {
            send_message error "The size of BAR$i must be set to N/A as BAR$i is disabled"
         }
      } elseif { $bar_type_hwtcl($i) == $PREFETACHBLE_64_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Enabled"
            set_parameter_value "bar${i}_prefetchable_hwtcl" "Enabled"
            set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
           # send_message error "The size of the 64-bit prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i) == $NON_PREFETCHABLE_32_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>31 } {
            send_message error "The size of the 32-bit non-prefetchable BAR$i must be less than 31 bits"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
           # send_message error "The size of the 32-bit non-prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i)== $PREFETCHABLE_32_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_hwtcl" "Enabled"
         set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>31 } {
            send_message error "The size of the 32-bit prefetchable BAR$i must be less than 31 bits"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
       #     send_message error "The size of the 32-bit prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i) == $IO_SPACE_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_hwtcl" "Enabled"
         if { $bar_size_mask_hwtcl($i)>12 } {
            send_message error "The size of the I/O space BAR$i must be less than 12 bits"
         }
      }
   }
}

proc validation_parameter_base_limit_reg {} {

   set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]
   set io_window_addr_width_hwtcl               [ get_parameter_value io_window_addr_width_hwtcl               ]
   set prefetchable_mem_window_addr_width_hwtcl [ get_parameter_value prefetchable_mem_window_addr_width_hwtcl ]
   if { [ regexp endpoint $port_type_hwtcl ] } {
      if { $io_window_addr_width_hwtcl>0 } {
         send_message error "Input/Ouput base and limit register must be disabled when using endpoint"
      }
      if { $prefetchable_mem_window_addr_width_hwtcl>0 } {
         send_message error "prefetchable memory base and limit register must be disabled when using endpoint"
      }
   }
}

proc validation_parameter_pcie_cap_reg {} {

   # AER settings checks
   set use_aer_hwtcl                  [ get_parameter_value use_aer_hwtcl             ]
   set ecrc_check_capable_hwtcl       [ get_parameter_value ecrc_check_capable_hwtcl  ]
   set ecrc_gen_capable_hwtcl         [ get_parameter_value ecrc_gen_capable_hwtcl    ]
   set use_crc_forwarding_hwtcl       [ get_parameter_value use_crc_forwarding_hwtcl  ]

   if { $use_aer_hwtcl == 0 } {
      if { $ecrc_check_capable_hwtcl == 1 } {
         send_message error "Implement ECRC check cannot be set when Implement advanced error reporting is not set"
      }
      if { $ecrc_gen_capable_hwtcl == 1 } {
         send_message error "Implement ECRC generation cannot be set when Implement advanced error reporting is not set"
      }
      if { $use_crc_forwarding_hwtcl == 1 } {
         send_message error "Implement ECRC forwarding cannot be set when Implement advanced error reporting is not set"
      }
   }
}

proc validation_parameter_prj_setting {} {
   # Check that device used is Stratix V
   set INTENDED_DEVICE_FAMILY [ get_parameter_value INTENDED_DEVICE_FAMILY ]
   send_message info "Family: $INTENDED_DEVICE_FAMILY"
   if { [string compare -nocase $INTENDED_DEVICE_FAMILY "Stratix V"] != 0 && [string compare -nocase $INTENDED_DEVICE_FAMILY "Arria V GZ"] != 0} {
      send_message error "Selected device family: $INTENDED_DEVICE_FAMILY is not supported"
   }
}

proc validation_parameter_avmm_setting {} { 
   set CB_A2P_ADDR_MAP_NUM_ENTRIES [ get_parameter_value CB_A2P_ADDR_MAP_NUM_ENTRIES ]
   set CB_A2P_ADDR_MAP_PASS_THRU_BITS [ get_parameter_value CB_A2P_ADDR_MAP_PASS_THRU_BITS]
   set CG_AVALON_S_ADDR_WIDTH [ get_parameter_value CG_AVALON_S_ADDR_WIDTH]
   set CB_A2P_ADDR_MAP_IS_FIXED [ get_parameter_value CB_A2P_ADDR_MAP_IS_FIXED]
   set CG_IMPL_CRA_AV_SLAVE_PORT [ get_parameter_value CG_IMPL_CRA_AV_SLAVE_PORT]
   set CB_PCIE_MODE [ get_parameter_value CB_PCIE_MODE]
   set avmm_width [ get_parameter_value avmm_width_hwtcl ]

   set AVALON_ADDR_WIDTH [get_parameter_value AVALON_ADDR_WIDTH]
   set TX_S_ADDR_WIDTH [get_parameter_value TX_S_ADDR_WIDTH]
   
   if { $AVALON_ADDR_WIDTH == 64 } {  # hiding address translation when 64-bit addressing enabled
   	   set_display_item_property "Avalon to PCIe Address Translation Settings" VISIBLE false
   	   set_parameter_property TX_S_ADDR_WIDTH VISIBLE true
   	 } else {
   	 	 set_display_item_property "Avalon to PCIe Address Translation Settings" VISIBLE true
   	 	 set_parameter_property TX_S_ADDR_WIDTH VISIBLE false
   	}

   if { $avmm_width == 128 } {
       set_parameter_value avmm_burst_width_hwtcl 6
      } else {
       set_parameter_value avmm_burst_width_hwtcl 7
      }

   # Set TXS address width: if 64-address enabled use the user value instead of Calculated value
   
if { $AVALON_ADDR_WIDTH == 32 } {
	   
   set_parameter_value CG_AVALON_S_ADDR_WIDTH [calculate_avalon_s_address_width $CB_A2P_ADDR_MAP_NUM_ENTRIES $CB_A2P_ADDR_MAP_PASS_THRU_BITS]
   if { $CG_AVALON_S_ADDR_WIDTH > 32 } {
      send_message error "Invalid combination of \"Number of address pages\" and \"Size of address pages\" parameters. Txs Address width must not be larger than 32 bits wide"
   }
   # Check Address Translation Table
   if { $CB_A2P_ADDR_MAP_IS_FIXED == 0  } {
      if { $CB_A2P_ADDR_MAP_NUM_ENTRIES == 1 } {
         send_message error "Number of address pages has to be more than 1 for Dynamic translation table configuration"
      }
      if { ($CG_IMPL_CRA_AV_SLAVE_PORT == 0) && ($CB_PCIE_MODE != 1) } {
         send_message error "Control Register Access (CRA) Avalon-MM slave port is required for Dynamic translation table configuration"
      }
   } else {
      if { $CB_A2P_ADDR_MAP_NUM_ENTRIES > 16 } {
         send_message error "Number of address pages cannot be more than 16 for Fixed translation table configuration"
      }
   }
   if { $CB_PCIE_MODE == 1} {
      set CB_PCIE_RX_LITE [ get_parameter_value CB_PCIE_RX_LITE]

      if { $CG_IMPL_CRA_AV_SLAVE_PORT == 1 &&  $CB_PCIE_RX_LITE == 1} {
         send_message error "\"Control Register Access (CRA) Avalon-MM slave port\" is not available in \"Completer-Only single dword mode\""
      }

       if { $avmm_width == 128 &&  $CB_PCIE_RX_LITE == 1} {
         send_message error "\"Avalon-MM 128-bit\" is not supported in \"Completer-Only single dword mode\""
      }
   }
} else {
	   set_parameter_value CG_AVALON_S_ADDR_WIDTH $TX_S_ADDR_WIDTH
     }   
   
}




proc add_pcie_hip_parameters_ui_pci_bar_avmm {} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pci_registers"

   set group_name_all "Base Address Registers"

   #-----------------------------------------------------------------------------------------------------------------
   add_display_item "" "Base Address Registers" group
   for { set i 0 } { $i < 6 } { incr i } {
       add_display_item "Base Address Registers" "BAR${i}" group
       set_display_item_property "BAR${i}" display_hint tab
   }


   set group_name "BAR0"

   add_parameter          bar0_type_hwtcl integer 0
   set_parameter_property bar0_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar0_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar0_type_hwtcl GROUP $group_name
   set_parameter_property bar0_type_hwtcl VISIBLE true
   set_parameter_property bar0_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar0_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar0_size_mask_hwtcl integer 28
   set_parameter_property bar0_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar0_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar0_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar0_size_mask_hwtcl VISIBLE true
   set_parameter_property bar0_size_mask_hwtcl DERIVED true
   set_parameter_property bar0_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar0_io_space_hwtcl string "Disabled"
   set_parameter_property bar0_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar0_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_io_space_hwtcl GROUP $group_name
   set_parameter_property bar0_io_space_hwtcl VISIBLE false
   set_parameter_property bar0_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_io_space_hwtcl DERIVED true
   set_parameter_property bar0_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar0_64bit_mem_space_hwtcl string "Enabled"
   set_parameter_property bar0_64bit_mem_space_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar0_64bit_mem_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_64bit_mem_space_hwtcl GROUP $group_name
   set_parameter_property bar0_64bit_mem_space_hwtcl VISIBLE false
   set_parameter_property bar0_64bit_mem_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_64bit_mem_space_hwtcl DERIVED true
   set_parameter_property bar0_64bit_mem_space_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 0 and 1 combine to form a single BAR."

   add_parameter          bar0_prefetchable_hwtcl string "Enabled"
   set_parameter_property bar0_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar0_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar0_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar0_prefetchable_hwtcl DERIVED true
   set_parameter_property bar0_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable. The 64-bit BAR is always prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "BAR1"

   add_parameter          bar1_type_hwtcl integer 0
   set_parameter_property bar1_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar1_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar1_type_hwtcl GROUP $group_name
   set_parameter_property bar1_type_hwtcl VISIBLE true
   set_parameter_property bar1_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar1_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar1_size_mask_hwtcl integer 0
   set_parameter_property bar1_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar1_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar1_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar1_size_mask_hwtcl VISIBLE true
   set_parameter_property bar1_size_mask_hwtcl DERIVED true
   set_parameter_property bar1_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar1_io_space_hwtcl string "Disabled"
   set_parameter_property bar1_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar1_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar1_io_space_hwtcl GROUP $group_name
   set_parameter_property bar1_io_space_hwtcl VISIBLE false
   set_parameter_property bar1_io_space_hwtcl DERIVED true
   set_parameter_property bar1_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar1_prefetchable_hwtcl string "Disabled"
   set_parameter_property bar1_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar1_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar1_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar1_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar1_prefetchable_hwtcl DERIVED true
   set_parameter_property bar1_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."


   #-----------------------------------------------------------------------------------------------------------------
   set group_name "BAR2"

   add_parameter          bar2_type_hwtcl integer 0
   set_parameter_property bar2_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar2_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar2_type_hwtcl GROUP $group_name
   set_parameter_property bar2_type_hwtcl VISIBLE true
   set_parameter_property bar2_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar2_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar2_size_mask_hwtcl integer 0
   set_parameter_property bar2_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar2_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar2_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar2_size_mask_hwtcl VISIBLE true
   set_parameter_property bar2_size_mask_hwtcl DERIVED true
   set_parameter_property bar2_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar2_io_space_hwtcl string "Disabled"
   set_parameter_property bar2_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar2_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_io_space_hwtcl GROUP $group_name
   set_parameter_property bar2_io_space_hwtcl VISIBLE false
   set_parameter_property bar2_io_space_hwtcl DERIVED true
   set_parameter_property bar2_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar2_64bit_mem_space_hwtcl string "Disabled"
   set_parameter_property bar2_64bit_mem_space_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar2_64bit_mem_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_64bit_mem_space_hwtcl GROUP $group_name
   set_parameter_property bar2_64bit_mem_space_hwtcl VISIBLE false
   set_parameter_property bar2_64bit_mem_space_hwtcl DERIVED true
   set_parameter_property bar2_64bit_mem_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_64bit_mem_space_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 2 and 3 combine to form a single BAR."


   add_parameter          bar2_prefetchable_hwtcl string "Disabled"
   set_parameter_property bar2_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar2_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar2_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar2_prefetchable_hwtcl DERIVED true
   set_parameter_property bar2_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."


   #-----------------------------------------------------------------------------------------------------------------
   set group_name "BAR3"

   add_parameter          bar3_type_hwtcl integer 0
   set_parameter_property bar3_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar3_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar3_type_hwtcl GROUP $group_name
   set_parameter_property bar3_type_hwtcl VISIBLE true
   set_parameter_property bar3_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar3_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar3_size_mask_hwtcl integer 0
   set_parameter_property bar3_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar3_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar3_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar3_size_mask_hwtcl VISIBLE true
   set_parameter_property bar3_size_mask_hwtcl DERIVED true
   set_parameter_property bar3_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar3_io_space_hwtcl string "Disabled"
   set_parameter_property bar3_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar3_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar3_io_space_hwtcl GROUP $group_name
   set_parameter_property bar3_io_space_hwtcl VISIBLE false
   set_parameter_property bar3_io_space_hwtcl DERIVED true
   set_parameter_property bar3_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar3_prefetchable_hwtcl string "Disabled"
   set_parameter_property bar3_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar3_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar3_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar3_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar3_prefetchable_hwtcl DERIVED true
   set_parameter_property bar3_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "BAR4"

   add_parameter          bar4_type_hwtcl integer 0
   set_parameter_property bar4_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar4_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar4_type_hwtcl GROUP $group_name
   set_parameter_property bar4_type_hwtcl VISIBLE true
   set_parameter_property bar4_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar4_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar4_size_mask_hwtcl integer 0
   set_parameter_property bar4_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar4_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar4_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar4_size_mask_hwtcl VISIBLE true
   set_parameter_property bar4_size_mask_hwtcl DERIVED true
   set_parameter_property bar4_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar4_io_space_hwtcl string "Disabled"
   set_parameter_property bar4_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar4_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_io_space_hwtcl GROUP $group_name
   set_parameter_property bar4_io_space_hwtcl VISIBLE false
   set_parameter_property bar4_io_space_hwtcl DERIVED true
   set_parameter_property bar4_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."


   add_parameter          bar4_64bit_mem_space_hwtcl string "Disabled"
   set_parameter_property bar4_64bit_mem_space_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar4_64bit_mem_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_64bit_mem_space_hwtcl GROUP $group_name
   set_parameter_property bar4_64bit_mem_space_hwtcl VISIBLE false
   set_parameter_property bar4_64bit_mem_space_hwtcl DERIVED true
   set_parameter_property bar4_64bit_mem_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_64bit_mem_space_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 4 and 5 combine to form a single BAR"

   add_parameter          bar4_prefetchable_hwtcl string "Disabled"
   set_parameter_property bar4_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar4_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar4_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar4_prefetchable_hwtcl DERIVED true
   set_parameter_property bar4_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "BAR5"

   add_parameter          bar5_type_hwtcl integer 0
   set_parameter_property bar5_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar5_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" }
   set_parameter_property bar5_type_hwtcl GROUP $group_name
   set_parameter_property bar5_type_hwtcl VISIBLE true
   set_parameter_property bar5_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar5_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar5_size_mask_hwtcl integer 0
   set_parameter_property bar5_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar5_size_mask_hwtcl ALLOWED_RANGES {"0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar5_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar5_size_mask_hwtcl VISIBLE true
   set_parameter_property bar5_size_mask_hwtcl DERIVED true
   set_parameter_property bar5_size_mask_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_size_mask_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar5_io_space_hwtcl string "Disabled"
   set_parameter_property bar5_io_space_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar5_io_space_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar5_io_space_hwtcl GROUP $group_name
   set_parameter_property bar5_io_space_hwtcl VISIBLE false
   set_parameter_property bar5_io_space_hwtcl DERIVED true
   set_parameter_property bar5_io_space_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_io_space_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."


   add_parameter          bar5_prefetchable_hwtcl string "Disabled"
   set_parameter_property bar5_prefetchable_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar5_prefetchable_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar5_prefetchable_hwtcl GROUP $group_name
   set_parameter_property bar5_prefetchable_hwtcl VISIBLE false
   set_parameter_property bar5_prefetchable_hwtcl DERIVED true
   set_parameter_property bar5_prefetchable_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_prefetchable_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

}

