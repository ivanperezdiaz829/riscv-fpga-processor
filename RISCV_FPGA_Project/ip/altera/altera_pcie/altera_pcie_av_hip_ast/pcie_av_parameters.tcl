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
source ${QUARTUS_ROOTDIR}/../ip/altera/altera_pcie/altera_pcie_av_hip_ast/pcie_av_parameters_common.tcl

proc add_pcie_hip_parameters_ui_system_settings {} {
   send_message debug "proc:add_pcie_hip_parameters_ui_system_settings"

   set group_name "System Settings"

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

   # RX St BE
   add_parameter          use_rx_st_be_hwtcl integer 0
   set_parameter_property use_rx_st_be_hwtcl DISPLAY_NAME "Use deprecated RX Avalon-ST data byte enable port (rx_st_be)"
   set_parameter_property use_rx_st_be_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_rx_st_be_hwtcl GROUP $group_name
   set_parameter_property use_rx_st_be_hwtcl VISIBLE true
   set_parameter_property use_rx_st_be_hwtcl HDL_PARAMETER false
   set_parameter_property use_rx_st_be_hwtcl DESCRIPTION "Use this port only when migrating previous generation Hard IP designs."

   # CVP
   add_parameter          in_cvp_mode_hwtcl integer 0
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_NAME "Enable configuration via the PCIe link"
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_HINT boolean
   set_parameter_property in_cvp_mode_hwtcl GROUP $group_name
   set_parameter_property in_cvp_mode_hwtcl VISIBLE true
   set_parameter_property in_cvp_mode_hwtcl HDL_PARAMETER true
   set_parameter_property in_cvp_mode_hwtcl DESCRIPTION "Selects the hard IP block that includes logic to configure the FPGA  via the PCI Express link."

   add_parameter          hip_reconfig_hwtcl integer 0
   set_parameter_property hip_reconfig_hwtcl DISPLAY_NAME "Enable Hard IP reconfiguration"
   set_parameter_property hip_reconfig_hwtcl DISPLAY_HINT boolean
   set_parameter_property hip_reconfig_hwtcl GROUP $group_name
   set_parameter_property hip_reconfig_hwtcl VISIBLE true
   set_parameter_property hip_reconfig_hwtcl HDL_PARAMETER true
   set_parameter_property hip_reconfig_hwtcl DESCRIPTION "When On, enables creates an Avalon-MM slave interface which software can drive to update global configuration registers that are read-only at run time. "

   #Function
   add_parameter          num_of_func_hwtcl integer 1
   set_parameter_property num_of_func_hwtcl DISPLAY_NAME "Number of Functions"
   set_parameter_property num_of_func_hwtcl ALLOWED_RANGES {"1" "2" "3" "4" "5" "6" "7" "8"}
   set_parameter_property num_of_func_hwtcl GROUP $group_name
   set_parameter_property num_of_func_hwtcl VISIBLE true
   set_parameter_property num_of_func_hwtcl HDL_PARAMETER true
   set_parameter_property num_of_func_hwtcl DESCRIPTION "Number of Functions to supported by the device"

}

proc add_pcie_hip_param_ui_func_registers {max_func} {

   send_message debug "proc:add_pcie_hip_parametere_ui_func_registers"

   set master_group_name "Function Capabilities"
   add_display_item "" $master_group_name group

   set sub_group_name "Shared PCI Express/PCI Capabilities Across All Functions"
   add_display_item $master_group_name $sub_group_name group

   set group_tab_name "Device"
   add_display_item $sub_group_name $group_tab_name group
   set_display_item_property ${group_tab_name} display_hint tab

   add_parameter          max_payload_size_hwtcl integer 128
   set_parameter_property max_payload_size_hwtcl DISPLAY_NAME "Maximum payload size"
   set_parameter_property max_payload_size_hwtcl ALLOWED_RANGES { "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" }
   set_parameter_property max_payload_size_hwtcl GROUP $group_tab_name
   set_parameter_property max_payload_size_hwtcl VISIBLE true
   set_parameter_property max_payload_size_hwtcl HDL_PARAMETER false
   set_parameter_property max_payload_size_hwtcl DESCRIPTION "Sets the read-only value of the max payload size of the Device Capabilities register and optimizes for this payload size."

   add_parameter          extend_tag_field_hwtcl string "32"
   set_parameter_property extend_tag_field_hwtcl DISPLAY_NAME "Number of tags supported per function"
   set_parameter_property extend_tag_field_hwtcl ALLOWED_RANGES { "32" "64" }
   set_parameter_property extend_tag_field_hwtcl GROUP $group_tab_name
   set_parameter_property extend_tag_field_hwtcl VISIBLE true
   set_parameter_property extend_tag_field_hwtcl HDL_PARAMETER false
   set_parameter_property extend_tag_field_hwtcl DESCRIPTION "Sets the number of tags supported for non-posted requests transmitted by the application layer."


   add_parameter          completion_timeout_hwtcl string "ABCD"
   set_parameter_property completion_timeout_hwtcl DISPLAY_NAME "Completion timeout range"
   set_parameter_property completion_timeout_hwtcl ALLOWED_RANGES { "ABCD" "BCD" "ABC" "BC" "AB" "B" "A" "NONE"}
   set_parameter_property completion_timeout_hwtcl GROUP $group_tab_name
   set_parameter_property completion_timeout_hwtcl VISIBLE true
   set_parameter_property completion_timeout_hwtcl HDL_PARAMETER false
   set_parameter_property completion_timeout_hwtcl DESCRIPTION "Sets the completion timeout range for root ports and endpoints that issue requests on their own behalf in PCI Express, version 2.0 or higher. For additional information, refer to the PCI Express User Guide."

   add_parameter          enable_completion_timeout_disable_hwtcl integer 1
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_NAME "Implement completion timeout disable"
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_completion_timeout_disable_hwtcl GROUP $group_tab_name
   set_parameter_property enable_completion_timeout_disable_hwtcl VISIBLE true
   set_parameter_property enable_completion_timeout_disable_hwtcl HDL_PARAMETER false
   set_parameter_property enable_completion_timeout_disable_hwtcl DESCRIPTION "Turns the completion timeout mechanism On or Off for root ports in PCI Express, version 2.0 or higher. This option is forced to On for PCI Express version 2.0 and higher endpoints. It is forced Off for version 1.0a and 1.1 endpoints."

   set group_tab_name "Error Reporting"
   add_display_item $sub_group_name $group_tab_name group
   set_display_item_property ${group_tab_name} display_hint tab

   add_parameter          use_aer_hwtcl integer 0
   set_parameter_property use_aer_hwtcl DISPLAY_NAME "Advanced error reporting (AER)"
   set_parameter_property use_aer_hwtcl GROUP $group_tab_name
   set_parameter_property use_aer_hwtcl VISIBLE true
   set_parameter_property use_aer_hwtcl HDL_PARAMETER false
   set_parameter_property use_aer_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_aer_hwtcl DESCRIPTION "Enables or disables AER."

   add_parameter          ecrc_check_capable_hwtcl integer 0
   set_parameter_property ecrc_check_capable_hwtcl DISPLAY_NAME "ECRC checking"
   set_parameter_property ecrc_check_capable_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_check_capable_hwtcl GROUP $group_tab_name
   set_parameter_property ecrc_check_capable_hwtcl VISIBLE true
   set_parameter_property ecrc_check_capable_hwtcl HDL_PARAMETER false
   set_parameter_property ecrc_check_capable_hwtcl DESCRIPTION "Enables or disables ECRC checking. When enabled, AER must also be On."

   add_parameter          ecrc_gen_capable_hwtcl integer 0
   set_parameter_property ecrc_gen_capable_hwtcl DISPLAY_NAME "ECRC generation"
   set_parameter_property ecrc_gen_capable_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_gen_capable_hwtcl GROUP $group_tab_name
   set_parameter_property ecrc_gen_capable_hwtcl VISIBLE true
   set_parameter_property ecrc_gen_capable_hwtcl HDL_PARAMETER false
   set_parameter_property ecrc_gen_capable_hwtcl DESCRIPTION "Enables or disables ECRC generation."

   add_parameter          use_crc_forwarding_hwtcl integer 0
   set_parameter_property use_crc_forwarding_hwtcl DISPLAY_NAME "ECRC forwarding"
   set_parameter_property use_crc_forwarding_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_crc_forwarding_hwtcl GROUP $group_tab_name
   set_parameter_property use_crc_forwarding_hwtcl VISIBLE true
   set_parameter_property use_crc_forwarding_hwtcl HDL_PARAMETER true
   set_parameter_property use_crc_forwarding_hwtcl DESCRIPTION "Enables or disables ECRC forwarding."

   set group_tab_name "Link"
   add_display_item $sub_group_name $group_tab_name group
   set_display_item_property ${group_tab_name} display_hint tab

   add_parameter          port_link_number_hwtcl integer 1
   set_parameter_property port_link_number_hwtcl DISPLAY_NAME "Link port number"
   set_parameter_property port_link_number_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property port_link_number_hwtcl GROUP $group_tab_name
   set_parameter_property port_link_number_hwtcl VISIBLE true
   set_parameter_property port_link_number_hwtcl HDL_PARAMETER true
   set_parameter_property port_link_number_hwtcl DESCRIPTION "Sets the read-only value of the port number field in the Link Capabilities register."

   add_parameter          slotclkcfg_hwtcl integer 1
   set_parameter_property slotclkcfg_hwtcl DISPLAY_NAME "Slot clock configuration"
   set_parameter_property slotclkcfg_hwtcl DISPLAY_HINT boolean
   set_parameter_property slotclkcfg_hwtcl GROUP $group_tab_name
   set_parameter_property slotclkcfg_hwtcl VISIBLE true
   set_parameter_property slotclkcfg_hwtcl HDL_PARAMETER true
   set_parameter_property slotclkcfg_hwtcl DESCRIPTION "Set the read-only value of the slot clock configuration bit in the link status register."

   set group_tab_name "Slot"
   add_display_item $sub_group_name $group_tab_name group
   set_display_item_property ${group_tab_name} display_hint tab

   add_parameter          enable_slot_register_hwtcl integer 0
   set_parameter_property enable_slot_register_hwtcl DISPLAY_NAME "Use slot register"
   set_parameter_property enable_slot_register_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_slot_register_hwtcl GROUP $group_tab_name
   set_parameter_property enable_slot_register_hwtcl VISIBLE true
   set_parameter_property enable_slot_register_hwtcl HDL_PARAMETER true
   set_parameter_property enable_slot_register_hwtcl DESCRIPTION "Enables the slot register when Enabled. This register is required for root ports if a slot is implemented on the port. Slot status is recorded in the PCI Express Capabilities register."

   add_parameter          slot_power_scale_hwtcl integer 0
   set_parameter_property slot_power_scale_hwtcl DISPLAY_NAME "Slot power scale"
   set_parameter_property slot_power_scale_hwtcl ALLOWED_RANGES { 0:3 }
   set_parameter_property slot_power_scale_hwtcl GROUP $group_tab_name
   set_parameter_property slot_power_scale_hwtcl VISIBLE true
   set_parameter_property slot_power_scale_hwtcl HDL_PARAMETER false
   set_parameter_property slot_power_scale_hwtcl DESCRIPTION "Sets the scale used for the Slot power limit value, as follows: 0=1.0<n>, 1=0.1<n>, 2=0.01<n>, 3=0.001<n>."

   add_parameter          slot_power_limit_hwtcl integer 0
   set_parameter_property slot_power_limit_hwtcl DISPLAY_NAME "Slot power limit"
   set_parameter_property slot_power_limit_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property slot_power_limit_hwtcl GROUP $group_tab_name
   set_parameter_property slot_power_limit_hwtcl VISIBLE true
   set_parameter_property slot_power_limit_hwtcl HDL_PARAMETER false
   set_parameter_property slot_power_limit_hwtcl DESCRIPTION "Sets the upper limit (in Watts) of power supplied by the slot in conjunction with the slot power scale register. For more information, refer to the PCI Express Base Specification."

   add_parameter          slot_number_hwtcl integer 0
   set_parameter_property slot_number_hwtcl DISPLAY_NAME "Slot number"
   set_parameter_property slot_number_hwtcl ALLOWED_RANGES { 0:8191 }
   set_parameter_property slot_number_hwtcl GROUP $group_tab_name
   set_parameter_property slot_number_hwtcl VISIBLE true
   set_parameter_property slot_number_hwtcl HDL_PARAMETER false
   set_parameter_property slot_number_hwtcl DESCRIPTION "Specifies the physical slot number associated with a port."

   set group_tab_name "Power Management"
   add_display_item $sub_group_name $group_tab_name group
   set_display_item_property ${group_tab_name} display_hint tab

   add_parameter endpoint_l0_latency_hwtcl integer 0
   set_parameter_property endpoint_l0_latency_hwtcl DISPLAY_NAME "Endpoint L0s acceptable exit latency"
   set_parameter_property endpoint_l0_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 64 ns" "1:Maximum of 128 ns" "2:Maximum of 256 ns" "3:Maximum of 512 ns" "4:Maximum of 1 us" "5:Maximum of 2 us" "6:Maximum of 4 us" "7:No limit" }
   set_parameter_property endpoint_l0_latency_hwtcl GROUP $group_tab_name
   set_parameter_property endpoint_l0_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l0_latency_hwtcl HDL_PARAMETER false
   set_parameter_property endpoint_l0_latency_hwtcl DESCRIPTION "Sets the read-only value of the endpoint L0s acceptable exit latency field of the Device Capabilities register. This value should be based on the latency that the application layer can tolerate. This setting is disabled for root ports."

   add_parameter endpoint_l1_latency_hwtcl integer 0
   set_parameter_property endpoint_l1_latency_hwtcl DISPLAY_NAME "Endpoint L1 acceptable exit latency"
   set_parameter_property endpoint_l1_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 1 us" "1:Maximum of 2 us" "2:Maximum of 4 us" "3:Maximum of 8 us" "4:Maximum of 16 us" "5:Maximum of 32 us" "6:Maximum of 64 us" "7:No limit" }
   set_parameter_property endpoint_l1_latency_hwtcl GROUP $group_tab_name
   set_parameter_property endpoint_l1_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l1_latency_hwtcl HDL_PARAMETER false
   set_parameter_property endpoint_l1_latency_hwtcl DESCRIPTION "Sets the acceptable exit latency that an endpoint can withstand in the transition from the L1 to L0 state. It is an indirect measure of the endpoint internal buffering. This setting is disabled for root ports."


   for {set f 0} {$f < $max_func} {incr f} {
      add_display_item "Function Capabilities" "Func ${f}" group
      set_display_item_property "Func ${f}" display_hint tab

      set func_group_name "Func ${f}"

      if { $f == 0} {
         # Func 0

         # Function Enable/Disable
         add_parameter          func0_en_hwtcl integer 1
         set_parameter_property func0_en_hwtcl DISPLAY_NAME "Func 0 Enable"
         set_parameter_property func0_en_hwtcl DISPLAY_HINT boolean
         set_parameter_property func0_en_hwtcl GROUP $func_group_name
         set_parameter_property func0_en_hwtcl VISIBLE true
         set_parameter_property func0_en_hwtcl HDL_PARAMETER false
         set_parameter_property func0_en_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."
         set_parameter_property func0_en_hwtcl DERIVED true

         # Selects the port type
         add_parameter          porttype_func0_hwtcl string "Native endpoint"
         set_parameter_property porttype_func0_hwtcl DISPLAY_NAME "Port type"
         set_parameter_property porttype_func0_hwtcl ALLOWED_RANGES {"Root port" "Native endpoint" "Root port" "Legacy endpoint" }
         set_parameter_property porttype_func0_hwtcl GROUP $func_group_name
         set_parameter_property porttype_func0_hwtcl VISIBLE false
         set_parameter_property porttype_func0_hwtcl HDL_PARAMETER true
         set_parameter_property porttype_func0_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."
         set_parameter_property porttype_func0_hwtcl DERIVED true


       } else {
         # Func 1 to 7:

         # Function Enable/Disable
         add_parameter          func${f}_en_hwtcl integer 0
         set_parameter_property func${f}_en_hwtcl DISPLAY_NAME "Func ${f} Enable"
         set_parameter_property func${f}_en_hwtcl DISPLAY_HINT boolean
         set_parameter_property func${f}_en_hwtcl GROUP $func_group_name
         set_parameter_property func${f}_en_hwtcl VISIBLE true
         set_parameter_property func${f}_en_hwtcl HDL_PARAMETER false
         set_parameter_property func${f}_en_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."
         set_parameter_property func${f}_en_hwtcl DERIVED true

         # Selects the port type
         add_parameter          porttype_func${f}_hwtcl string "Native endpoint"
         set_parameter_property porttype_func${f}_hwtcl DISPLAY_NAME "Port type"
         set_parameter_property porttype_func${f}_hwtcl ALLOWED_RANGES {"Native endpoint" "Legacy endpoint" }
         set_parameter_property porttype_func${f}_hwtcl GROUP $func_group_name
         set_parameter_property porttype_func${f}_hwtcl VISIBLE false
         set_parameter_property porttype_func${f}_hwtcl HDL_PARAMETER true
         set_parameter_property porttype_func${f}_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."
         set_parameter_property porttype_func${f}_hwtcl DERIVED true

       }

       add_pcie_hip_parameters_ui_pci_registers "${f}"
       add_pcie_hip_parameters_ui_pcie_cap_registers "${f}"
       add_pcie_hip_hidden_rtl_parameters "${f}"
   }
}


proc add_pcie_hip_parameters_ui_pci_registers {func_num} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pci_registers for Function ${func_num}"

   set func_group_name "Func ${func_num}"
   set group_name_all "Base Address Registers for ${func_group_name}"

   #-----------------------------------------------------------------------------------------------------------------
   add_display_item ${func_group_name} $group_name_all group

   for { set i 0 } { $i < 6 } { incr i } {
       add_display_item $group_name_all "${func_group_name} BAR${i}" group
       set_display_item_property "${func_group_name} BAR${i}" display_hint tab
   }
   add_display_item $group_name_all "${func_group_name} Expansion ROM" group
   set_display_item_property "${func_group_name} Expansion ROM" display_hint tab

   set f ${func_num}

   set group_name "${func_group_name} BAR0"

   add_parameter          bar0_type_${f}_hwtcl integer 1
   set_parameter_property bar0_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar0_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar0_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar0_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar0_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar0_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar0_size_mask_${f}_hwtcl integer 28
   set_parameter_property bar0_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar0_size_mask_${f}_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar0_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar0_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar0_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar0_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar0_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar0_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar0_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar0_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar0_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar0_64bit_mem_space_${f}_hwtcl string "Enabled"
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl DERIVED true
   set_parameter_property bar0_64bit_mem_space_${f}_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 0 and 1 combine to form a single BAR."

   add_parameter          bar0_prefetchable_${f}_hwtcl string "Enabled"
   set_parameter_property bar0_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar0_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar0_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar0_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar0_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar0_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar0_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable. The 64-bit BAR is always prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} BAR1"

   add_parameter          bar1_type_${f}_hwtcl integer 0
   set_parameter_property bar1_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar1_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar1_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar1_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar1_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar1_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar1_size_mask_${f}_hwtcl integer 0
   set_parameter_property bar1_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar1_size_mask_${f}_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar1_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar1_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar1_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar1_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar1_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar1_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar1_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar1_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar1_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar1_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar1_prefetchable_${f}_hwtcl string "Disabled"
   set_parameter_property bar1_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar1_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar1_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar1_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar1_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar1_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar1_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."


   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} BAR2"

   add_parameter          bar2_type_${f}_hwtcl integer 0
   set_parameter_property bar2_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar2_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar2_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar2_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar2_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar2_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar2_size_mask_${f}_hwtcl integer 0
   set_parameter_property bar2_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar2_size_mask_${f}_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar2_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar2_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar2_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar2_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar2_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar2_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar2_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar2_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar2_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar2_64bit_mem_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl DERIVED true
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_64bit_mem_space_${f}_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 2 and 3 combine to form a single BAR."


   add_parameter          bar2_prefetchable_${f}_hwtcl string "Disabled"
   set_parameter_property bar2_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar2_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar2_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar2_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar2_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar2_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar2_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."


   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} BAR3"

   add_parameter          bar3_type_${f}_hwtcl integer 0
   set_parameter_property bar3_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar3_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar3_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar3_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar3_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar3_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar3_size_mask_${f}_hwtcl integer 0
   set_parameter_property bar3_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar3_size_mask_${f}_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar3_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar3_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar3_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar3_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar3_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar3_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar3_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar3_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar3_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar3_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."

   add_parameter          bar3_prefetchable_${f}_hwtcl string "Disabled"
   set_parameter_property bar3_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar3_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar3_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar3_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar3_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar3_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar3_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} BAR4"

   add_parameter          bar4_type_${f}_hwtcl integer 0
   set_parameter_property bar4_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar4_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar4_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar4_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar4_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar4_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar4_size_mask_${f}_hwtcl integer 0
   set_parameter_property bar4_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar4_size_mask_${f}_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar4_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar4_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar4_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."

   add_parameter          bar4_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar4_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar4_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar4_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar4_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar4_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."


   add_parameter          bar4_64bit_mem_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl DISPLAY_NAME "64-bit address"
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl DERIVED true
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_64bit_mem_space_${f}_hwtcl DESCRIPTION "Selects either a 64-or 32-bit BAR. When 64 bits, BARs 4 and 5 combine to form a single BAR"

   add_parameter          bar4_prefetchable_${f}_hwtcl string "Disabled"
   set_parameter_property bar4_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar4_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar4_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar4_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar4_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar4_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar4_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} BAR5"

   add_parameter          bar5_type_${f}_hwtcl integer 0
   set_parameter_property bar5_type_${f}_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar5_type_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar5_type_${f}_hwtcl GROUP $group_name
   set_parameter_property bar5_type_${f}_hwtcl VISIBLE true
   set_parameter_property bar5_type_${f}_hwtcl HDL_PARAMETER false
   set_parameter_property bar5_type_${f}_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar5_size_mask_${f}_hwtcl integer 0
   set_parameter_property bar5_size_mask_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar5_size_mask_${f}_hwtcl ALLOWED_RANGES {"0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar5_size_mask_${f}_hwtcl GROUP $group_name
   set_parameter_property bar5_size_mask_${f}_hwtcl VISIBLE true
   set_parameter_property bar5_size_mask_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_size_mask_${f}_hwtcl DESCRIPTION "Sets from 4-63 bits per base address register (BAR)."


   add_parameter          bar5_io_space_${f}_hwtcl string "Disabled"
   set_parameter_property bar5_io_space_${f}_hwtcl DISPLAY_NAME "I/O Space"
   set_parameter_property bar5_io_space_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar5_io_space_${f}_hwtcl GROUP $group_name
   set_parameter_property bar5_io_space_${f}_hwtcl VISIBLE false
   set_parameter_property bar5_io_space_${f}_hwtcl DERIVED true
   set_parameter_property bar5_io_space_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_io_space_${f}_hwtcl DESCRIPTION "For x1 and x4 legacy endpoints specifies an I/O space BAR sized from 16 bytes-4 KBytes. The x8 legacy endpoint supports an I/O space BAR of 4 KBytes."


   add_parameter          bar5_prefetchable_${f}_hwtcl string "Disabled"
   set_parameter_property bar5_prefetchable_${f}_hwtcl DISPLAY_NAME "Prefetchable"
   set_parameter_property bar5_prefetchable_${f}_hwtcl ALLOWED_RANGES {"Enabled" "Disabled"}
   set_parameter_property bar5_prefetchable_${f}_hwtcl GROUP $group_name
   set_parameter_property bar5_prefetchable_${f}_hwtcl VISIBLE false
   set_parameter_property bar5_prefetchable_${f}_hwtcl DERIVED true
   set_parameter_property bar5_prefetchable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property bar5_prefetchable_${f}_hwtcl DESCRIPTION "Specifies whether or not the 32-bit BAR is prefetchable."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Expansion ROM"
   add_parameter          expansion_base_address_register_${f}_hwtcl integer 0
   set_parameter_property expansion_base_address_register_${f}_hwtcl DISPLAY_NAME "Size"
   set_parameter_property expansion_base_address_register_${f}_hwtcl ALLOWED_RANGES { "0:Disabled" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits"}
   set_parameter_property expansion_base_address_register_${f}_hwtcl GROUP $group_name
   set_parameter_property expansion_base_address_register_${f}_hwtcl VISIBLE true
   set_parameter_property expansion_base_address_register_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property expansion_base_address_register_${f}_hwtcl DESCRIPTION "Specifies an expansion ROM from 4 KBytes - 16 MBytes when enabled."

   #-----------------------------------------------------------------------------------------------------------------

   if {$f == 0} {

      set group_name "Base and Limit Registers for Root Port (Available only for ${func_group_name})"
      add_display_item ${func_group_name} "Base and Limit Registers for Root Port (Available only for ${func_group_name})" group

      add_parameter          io_window_addr_width_hwtcl integer 0
      set_parameter_property io_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:16-bit I/O addressing" "2:32-bit I/O addressing "}
      set_parameter_property io_window_addr_width_hwtcl DISPLAY_NAME "Input/Output"
      set_parameter_property io_window_addr_width_hwtcl VISIBLE true
      set_parameter_property io_window_addr_width_hwtcl GROUP $group_name
      set_parameter_property io_window_addr_width_hwtcl HDL_PARAMETER true
      set_parameter_property io_window_addr_width_hwtcl DESCRIPTION "Specifies Input/Output base and limit register."

      add_parameter          prefetchable_mem_window_addr_width_hwtcl integer 0
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl DISPLAY_NAME "Prefetchable memory"
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:32-bit memory addressing" "2:64-bit memory addressing "}
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl VISIBLE true
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl HDL_PARAMETER true
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl GROUP $group_name
      set_parameter_property prefetchable_mem_window_addr_width_hwtcl DESCRIPTION "Specifies an expansion prefetchable memory base and limit register."
   }

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Device Identification Registers for ${func_group_name}"
   add_display_item ${func_group_name} "Device Identification Registers for ${func_group_name}" group

   add_parameter          vendor_id_${f}_hwtcl integer  0
   set_parameter_property vendor_id_${f}_hwtcl DISPLAY_NAME "Vendor ID"
   set_parameter_property vendor_id_${f}_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property vendor_id_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property vendor_id_${f}_hwtcl GROUP $group_name
   set_parameter_property vendor_id_${f}_hwtcl VISIBLE true
   set_parameter_property vendor_id_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property vendor_id_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Vendor ID register."

   add_parameter          device_id_${f}_hwtcl integer 1
   set_parameter_property device_id_${f}_hwtcl DISPLAY_NAME "Device ID"
   set_parameter_property device_id_${f}_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property device_id_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property device_id_${f}_hwtcl GROUP $group_name
   set_parameter_property device_id_${f}_hwtcl VISIBLE true
   set_parameter_property device_id_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property device_id_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Device ID register."

   add_parameter          revision_id_${f}_hwtcl integer 1
   set_parameter_property revision_id_${f}_hwtcl DISPLAY_NAME "Revision ID"
   set_parameter_property revision_id_${f}_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property revision_id_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property revision_id_${f}_hwtcl GROUP $group_name
   set_parameter_property revision_id_${f}_hwtcl VISIBLE true
   set_parameter_property revision_id_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property revision_id_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Revision ID register."

   add_parameter          class_code_${f}_hwtcl integer 0
   set_parameter_property class_code_${f}_hwtcl DISPLAY_NAME "Class Code"
   set_parameter_property class_code_${f}_hwtcl ALLOWED_RANGES { 0:16777215 }
   set_parameter_property class_code_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property class_code_${f}_hwtcl GROUP $group_name
   set_parameter_property class_code_${f}_hwtcl VISIBLE true
   set_parameter_property class_code_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property class_code_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Class code register."

   add_parameter          subsystem_vendor_id_${f}_hwtcl integer  0
   set_parameter_property subsystem_vendor_id_${f}_hwtcl DISPLAY_NAME "Subsystem Vendor ID"
   set_parameter_property subsystem_vendor_id_${f}_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property subsystem_vendor_id_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property subsystem_vendor_id_${f}_hwtcl GROUP $group_name
   set_parameter_property subsystem_vendor_id_${f}_hwtcl VISIBLE true
   set_parameter_property subsystem_vendor_id_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property subsystem_vendor_id_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Subsystem Vendor ID register."

   add_parameter          subsystem_device_id_${f}_hwtcl integer 0
   set_parameter_property subsystem_device_id_${f}_hwtcl DISPLAY_NAME "Subsystem Device ID"
   set_parameter_property subsystem_device_id_${f}_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property subsystem_device_id_${f}_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property subsystem_device_id_${f}_hwtcl GROUP $group_name
   set_parameter_property subsystem_device_id_${f}_hwtcl VISIBLE true
   set_parameter_property subsystem_device_id_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property subsystem_device_id_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Subsystem Device ID register."
}


proc add_pcie_hip_parameters_ui_pcie_cap_registers {func_num} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pcie_cap_registers for Function ${func_num}"
   #-----------------------------------------------------------------------------------------------------------------
   set func_group_name "Func ${func_num}"

   set master_group_name "PCI Express/PCI Capabilities for ${func_group_name}"
   add_display_item ${func_group_name} ${master_group_name} group

   set f ${func_num}

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Device"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter max_payload_size_${f}_hwtcl integer 128
   set_parameter_property max_payload_size_${f}_hwtcl DISPLAY_NAME "Maximum payload size"
   set_parameter_property max_payload_size_${f}_hwtcl ALLOWED_RANGES { "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" }
   set_parameter_property max_payload_size_${f}_hwtcl GROUP $group_name
   set_parameter_property max_payload_size_${f}_hwtcl VISIBLE false
   set_parameter_property max_payload_size_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property max_payload_size_${f}_hwtcl DESCRIPTION "Sets the read-only value of the max payload size of the Device Capabilities register and optimizes for this payload size."
   set_parameter_property max_payload_size_${f}_hwtcl DERIVED true

   add_parameter          extend_tag_field_${f}_hwtcl string "32"
   set_parameter_property extend_tag_field_${f}_hwtcl DISPLAY_NAME "Number of tags supported"
   set_parameter_property extend_tag_field_${f}_hwtcl ALLOWED_RANGES { "32" "64" }
   set_parameter_property extend_tag_field_${f}_hwtcl GROUP $group_name
   set_parameter_property extend_tag_field_${f}_hwtcl VISIBLE false
   set_parameter_property extend_tag_field_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property extend_tag_field_${f}_hwtcl DESCRIPTION "Sets the number of tags supported for non-posted requests transmitted by the application layer."
   set_parameter_property extend_tag_field_${f}_hwtcl DERIVED true

   add_parameter          completion_timeout_${f}_hwtcl string "ABCD"
   set_parameter_property completion_timeout_${f}_hwtcl DISPLAY_NAME "Completion timeout range"
   set_parameter_property completion_timeout_${f}_hwtcl ALLOWED_RANGES { "ABCD" "BCD" "ABC" "BC" "AB" "B" "A" "NONE"}
   set_parameter_property completion_timeout_${f}_hwtcl GROUP $group_name
   set_parameter_property completion_timeout_${f}_hwtcl VISIBLE false
   set_parameter_property completion_timeout_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property completion_timeout_${f}_hwtcl DESCRIPTION "Sets the completion timeout range for root ports and endpoints that issue requests on their own behalf in PCI Express, version 2.0 or higher. For additional information, refer to the PCI Express User Guide."
   set_parameter_property completion_timeout_${f}_hwtcl DERIVED true

   add_parameter enable_completion_timeout_disable_${f}_hwtcl integer 1
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl DISPLAY_NAME "Implement completion timeout disable"
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl GROUP $group_name
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl VISIBLE false
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl DESCRIPTION "Turns the completion timeout mechanism On or Off for root ports in PCI Express, version 2.0 or higher. This option is forced to On for PCI Express version 2.0 and higher endpoints. It is forced Off for version 1.0a and 1.1 endpoints."
   set_parameter_property enable_completion_timeout_disable_${f}_hwtcl DERIVED true

   add_parameter          flr_capability_${f}_hwtcl integer 0
   set_parameter_property flr_capability_${f}_hwtcl DISPLAY_NAME "Function Level Reset (FLR)"
   set_parameter_property flr_capability_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property flr_capability_${f}_hwtcl GROUP $group_name
   set_parameter_property flr_capability_${f}_hwtcl VISIBLE true
   set_parameter_property flr_capability_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property flr_capability_${f}_hwtcl DESCRIPTION "Enables or disable the PCI Function Level Reset (FLR) capability for Function ${f}"

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Error Reporting"
   #add_display_item ${master_group_name} ${group_name} group
   #set_display_item_property ${group_name} display_hint tab

   add_parameter          use_aer_${f}_hwtcl integer 0
   set_parameter_property use_aer_${f}_hwtcl DISPLAY_NAME "Advanced error reporting (AER)"
   set_parameter_property use_aer_${f}_hwtcl GROUP $group_name
   set_parameter_property use_aer_${f}_hwtcl VISIBLE false
   set_parameter_property use_aer_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property use_aer_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_aer_${f}_hwtcl DESCRIPTION "Enables or disables AER."
   set_parameter_property use_aer_${f}_hwtcl DERIVED true

   add_parameter          ecrc_check_capable_${f}_hwtcl integer 0
   set_parameter_property ecrc_check_capable_${f}_hwtcl DISPLAY_NAME "ECRC checking"
   set_parameter_property ecrc_check_capable_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_check_capable_${f}_hwtcl GROUP $group_name
   set_parameter_property ecrc_check_capable_${f}_hwtcl VISIBLE false
   set_parameter_property ecrc_check_capable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property ecrc_check_capable_${f}_hwtcl DESCRIPTION "Enables or disables ECRC checking. When enabled, AER must also be On."
   set_parameter_property ecrc_check_capable_${f}_hwtcl DERIVED true

   add_parameter          ecrc_gen_capable_${f}_hwtcl integer 0
   set_parameter_property ecrc_gen_capable_${f}_hwtcl DISPLAY_NAME "ECRC generation"
   set_parameter_property ecrc_gen_capable_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property ecrc_gen_capable_${f}_hwtcl GROUP $group_name
   set_parameter_property ecrc_gen_capable_${f}_hwtcl VISIBLE false
   set_parameter_property ecrc_gen_capable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property ecrc_gen_capable_${f}_hwtcl DESCRIPTION "Enables or disables ECRC generation."
   set_parameter_property ecrc_gen_capable_${f}_hwtcl DERIVED true

   #-----------------------------------------------------------------------------------------------------------------

  if {$f == 0} {

      set group_name "${func_group_name} Link"
      add_display_item ${master_group_name} ${group_name} group
      set_display_item_property ${group_name} display_hint tab

      add_parameter          dll_active_report_support_${f}_hwtcl integer 0
      set_parameter_property dll_active_report_support_${f}_hwtcl DISPLAY_NAME "Data link layer active reporting"
      set_parameter_property dll_active_report_support_${f}_hwtcl DISPLAY_HINT boolean
      set_parameter_property dll_active_report_support_${f}_hwtcl GROUP $group_name
      set_parameter_property dll_active_report_support_${f}_hwtcl VISIBLE true
      set_parameter_property dll_active_report_support_${f}_hwtcl HDL_PARAMETER true
      set_parameter_property dll_active_report_support_${f}_hwtcl DESCRIPTION "Enables or disables Data Link Layer (DLL)active reporting."

      add_parameter          surprise_down_error_support_${f}_hwtcl integer 0
      set_parameter_property surprise_down_error_support_${f}_hwtcl DISPLAY_NAME "Surprise down reporting"
      set_parameter_property surprise_down_error_support_${f}_hwtcl DISPLAY_HINT boolean
      set_parameter_property surprise_down_error_support_${f}_hwtcl GROUP $group_name
      set_parameter_property surprise_down_error_support_${f}_hwtcl VISIBLE true
      set_parameter_property surprise_down_error_support_${f}_hwtcl HDL_PARAMETER true
      set_parameter_property surprise_down_error_support_${f}_hwtcl DESCRIPTION "Enables or disables surprise down reporting."

  } else {

      set group_name "${func_group_name} Link"

      add_parameter          dll_active_report_support_${f}_hwtcl integer 0
      set_parameter_property dll_active_report_support_${f}_hwtcl DISPLAY_NAME "Data link layer active reporting"
      set_parameter_property dll_active_report_support_${f}_hwtcl DISPLAY_HINT boolean
      set_parameter_property dll_active_report_support_${f}_hwtcl GROUP $group_name
      set_parameter_property dll_active_report_support_${f}_hwtcl VISIBLE false
      set_parameter_property dll_active_report_support_${f}_hwtcl HDL_PARAMETER true
      set_parameter_property dll_active_report_support_${f}_hwtcl DESCRIPTION "Enables or disables Data Link Layer (DLL)active reporting."

      add_parameter          surprise_down_error_support_${f}_hwtcl integer 0
      set_parameter_property surprise_down_error_support_${f}_hwtcl DISPLAY_NAME "Surprise down reporting"
      set_parameter_property surprise_down_error_support_${f}_hwtcl DISPLAY_HINT boolean
      set_parameter_property surprise_down_error_support_${f}_hwtcl GROUP $group_name
      set_parameter_property surprise_down_error_support_${f}_hwtcl VISIBLE false
      set_parameter_property surprise_down_error_support_${f}_hwtcl HDL_PARAMETER true
      set_parameter_property surprise_down_error_support_${f}_hwtcl DESCRIPTION "Enables or disables surprise down reporting."

  }


   # TODO Add Link COmmon Clock parameters

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} MSI"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          msi_multi_message_capable_${f}_hwtcl string        "4"
   set_parameter_property msi_multi_message_capable_${f}_hwtcl DISPLAY_NAME "Number of MSI messages requested"
   set_parameter_property msi_multi_message_capable_${f}_hwtcl ALLOWED_RANGES { "1" "2" "4" "8" "16" "32"}
   set_parameter_property msi_multi_message_capable_${f}_hwtcl GROUP $group_name
   set_parameter_property msi_multi_message_capable_${f}_hwtcl VISIBLE true
   set_parameter_property msi_multi_message_capable_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msi_multi_message_capable_${f}_hwtcl DESCRIPTION "Sets the number of messages that the application can request in the multiple message capable field of the Message Control register."

   add_parameter msi_64bit_addressing_capable_${f}_hwtcl string "true"
   set_parameter_property msi_64bit_addressing_capable_${f}_hwtcl VISIBLE false
   set_parameter_property msi_64bit_addressing_capable_${f}_hwtcl HDL_PARAMETER true

   add_parameter msi_masking_capable_${f}_hwtcl string "false"
   set_parameter_property msi_masking_capable_${f}_hwtcl VISIBLE false
   set_parameter_property msi_masking_capable_${f}_hwtcl HDL_PARAMETER true

   add_parameter msi_support_${f}_hwtcl string "true"
   set_parameter_property msi_support_${f}_hwtcl VISIBLE false
   set_parameter_property msi_support_${f}_hwtcl HDL_PARAMETER true

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} MSI-X"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter enable_function_msix_support_${f}_hwtcl integer 0
   set_parameter_property enable_function_msix_support_${f}_hwtcl DISPLAY_NAME "Implement MSI-X"
   set_parameter_property enable_function_msix_support_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_function_msix_support_${f}_hwtcl GROUP $group_name
   set_parameter_property enable_function_msix_support_${f}_hwtcl VISIBLE true
   set_parameter_property enable_function_msix_support_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property enable_function_msix_support_${f}_hwtcl DESCRIPTION "Enables or disables the MSI-X capability."

   add_parameter          msix_table_size_${f}_hwtcl integer 0
   set_parameter_property msix_table_size_${f}_hwtcl DISPLAY_NAME "Table size"
   set_parameter_property msix_table_size_${f}_hwtcl ALLOWED_RANGES { 0:2047 }
   set_parameter_property msix_table_size_${f}_hwtcl GROUP $group_name
   set_parameter_property msix_table_size_${f}_hwtcl VISIBLE true
   set_parameter_property msix_table_size_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_size_${f}_hwtcl DESCRIPTION "Sets the number of entries in the MSI-X table."

   add_parameter          msix_table_offset_${f}_hwtcl long 0
   set_parameter_property msix_table_offset_${f}_hwtcl DISPLAY_NAME "Table offset"
   set_parameter_property msix_table_offset_${f}_hwtcl ALLOWED_RANGES { 0:4294967295 }
   set_parameter_property msix_table_offset_${f}_hwtcl GROUP $group_name
   set_parameter_property msix_table_offset_${f}_hwtcl VISIBLE true
   set_parameter_property msix_table_offset_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_offset_${f}_hwtcl DESCRIPTION "Sets the read-only base address of the MSI-X table. The low-order 3 bits are automatically set to 0."

   add_parameter          msix_table_bir_${f}_hwtcl integer 0
   set_parameter_property msix_table_bir_${f}_hwtcl DISPLAY_NAME "Table BAR indicator"
   set_parameter_property msix_table_bir_${f}_hwtcl ALLOWED_RANGES { 0:5 }
   set_parameter_property msix_table_bir_${f}_hwtcl GROUP $group_name
   set_parameter_property msix_table_bir_${f}_hwtcl VISIBLE true
   set_parameter_property msix_table_bir_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msix_table_bir_${f}_hwtcl DESCRIPTION "Specifies which one of a function's base address registers, located beginning at 0x10 in the Configuration Space, maps the MSI-X table into memory space. This field is read-only."

   add_parameter          msix_pba_offset_${f}_hwtcl long 0
   set_parameter_property msix_pba_offset_${f}_hwtcl DISPLAY_NAME "Pending bit array (PBA) offset"
   set_parameter_property msix_pba_offset_${f}_hwtcl ALLOWED_RANGES { 0:4294967295 }
   set_parameter_property msix_pba_offset_${f}_hwtcl GROUP $group_name
   set_parameter_property msix_pba_offset_${f}_hwtcl VISIBLE true
   set_parameter_property msix_pba_offset_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msix_pba_offset_${f}_hwtcl DESCRIPTION "Specifies the offset from the address stored in one of the function's base address registers the points to the base of the MSI-X PBA. This field is read-only."

   add_parameter          msix_pba_bir_${f}_hwtcl integer 0
   set_parameter_property msix_pba_bir_${f}_hwtcl DISPLAY_NAME "PBA BAR Indicator"
   set_parameter_property msix_pba_bir_${f}_hwtcl ALLOWED_RANGES { 0:5 }
   set_parameter_property msix_pba_bir_${f}_hwtcl GROUP $group_name
   set_parameter_property msix_pba_bir_${f}_hwtcl VISIBLE true
   set_parameter_property msix_pba_bir_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property msix_pba_bir_${f}_hwtcl DESCRIPTION "Indicates which of a function's base address registers, located beginning at 0x10 in the Configuration Space, maps the function's MSI-X PBA into memory space. This field is read-only."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Legacy Interrupt"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter interrupt_pin_${f}_hwtcl string "inta"
   set_parameter_property interrupt_pin_${f}_hwtcl DISPLAY_NAME "Legacy Interrupt (INTx)"
   set_parameter_property interrupt_pin_${f}_hwtcl ALLOWED_RANGES { "inta:INTA" "intb:INTB" "intc:INTC" "intd:INTD" "none:None" }
   set_parameter_property interrupt_pin_${f}_hwtcl GROUP $group_name
   set_parameter_property interrupt_pin_${f}_hwtcl VISIBLE true
   set_parameter_property interrupt_pin_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property interrupt_pin_${f}_hwtcl DESCRIPTION "Sets the read-only value of the Interrupt pin register for Legacy INTx interrupt"
   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Slot"
   #add_display_item ${master_group_name} ${group_name} group
   #set_display_item_property ${group_name} display_hint tab


   add_parameter          slot_power_scale_${f}_hwtcl integer 0
   set_parameter_property slot_power_scale_${f}_hwtcl DISPLAY_NAME "Slot power scale"
   set_parameter_property slot_power_scale_${f}_hwtcl ALLOWED_RANGES { 0:3 }
   set_parameter_property slot_power_scale_${f}_hwtcl GROUP $group_name
   set_parameter_property slot_power_scale_${f}_hwtcl VISIBLE false
   set_parameter_property slot_power_scale_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_scale_${f}_hwtcl DESCRIPTION "Sets the scale used for the Slot power limit value, as follows: 0=1.0<n>, 1=0.1<n>, 2=0.01<n>, 3=0.001<n>."
   set_parameter_property slot_power_scale_${f}_hwtcl DERIVED true

   add_parameter          slot_power_limit_${f}_hwtcl integer 0
   set_parameter_property slot_power_limit_${f}_hwtcl DISPLAY_NAME "Slot power limit"
   set_parameter_property slot_power_limit_${f}_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property slot_power_limit_${f}_hwtcl GROUP $group_name
   set_parameter_property slot_power_limit_${f}_hwtcl VISIBLE false
   set_parameter_property slot_power_limit_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_limit_${f}_hwtcl DESCRIPTION "Sets the upper limit (in Watts) of power supplied by the slot in conjunction with the slot power scale register. For more information, refer to the PCI Express Base Specification."
   set_parameter_property slot_power_limit_${f}_hwtcl DERIVED true

   add_parameter          slot_number_${f}_hwtcl integer 0
   set_parameter_property slot_number_${f}_hwtcl DISPLAY_NAME "Slot number"
   set_parameter_property slot_number_${f}_hwtcl ALLOWED_RANGES { 0:8191 }
   set_parameter_property slot_number_${f}_hwtcl GROUP $group_name
   set_parameter_property slot_number_${f}_hwtcl VISIBLE false
   set_parameter_property slot_number_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property slot_number_${f}_hwtcl DESCRIPTION "Specifies the physical slot number associated with a port."
   set_parameter_property slot_number_${f}_hwtcl DERIVED true

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "${func_group_name} Power Management"
   #add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter rx_ei_l0s_${f}_hwtcl integer 0
   set_parameter_property rx_ei_l0s_${f}_hwtcl DISPLAY_NAME "L0s supported"
   set_parameter_property rx_ei_l0s_${f}_hwtcl DISPLAY_HINT boolean
   set_parameter_property rx_ei_l0s_${f}_hwtcl GROUP $group_name
   set_parameter_property rx_ei_l0s_${f}_hwtcl VISIBLE false
   set_parameter_property rx_ei_l0s_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property rx_ei_l0s_${f}_hwtcl DESCRIPTION "Enables or disables entry to the L0s state."
   set_parameter_property rx_ei_l0s_${f}_hwtcl DERIVED true

   add_parameter endpoint_l0_latency_${f}_hwtcl integer 0
   set_parameter_property endpoint_l0_latency_${f}_hwtcl DISPLAY_NAME "Endpoint L0s acceptable exit latency"
   set_parameter_property endpoint_l0_latency_${f}_hwtcl ALLOWED_RANGES { "0:Maximum of 64 ns" "1:Maximum of 128 ns" "2:Maximum of 256 ns" "3:Maximum of 512 ns" "4:Maximum of 1 us" "5:Maximum of 2 us" "6:Maximum of 4 us" "7:No limit" }
   set_parameter_property endpoint_l0_latency_${f}_hwtcl GROUP $group_name
   set_parameter_property endpoint_l0_latency_${f}_hwtcl VISIBLE false
   set_parameter_property endpoint_l0_latency_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l0_latency_${f}_hwtcl DESCRIPTION "Sets the read-only value of the endpoint L0s acceptable exit latency field of the Device Capabilities register. This value should be based on the latency that the application layer can tolerate. This setting is disabled for root ports."
   set_parameter_property endpoint_l0_latency_${f}_hwtcl DERIVED true

   add_parameter endpoint_l1_latency_${f}_hwtcl integer 0
   set_parameter_property endpoint_l1_latency_${f}_hwtcl DISPLAY_NAME "Endpoint L1 acceptable exit latency"
   set_parameter_property endpoint_l1_latency_${f}_hwtcl ALLOWED_RANGES { "0:Maximum of 1 us" "1:Maximum of 2 us" "2:Maximum of 4 us" "3:Maximum of 8 us" "4:Maximum of 16 us" "5:Maximum of 32 us" "6:Maximum of 64 us" "7:No limit" }
   set_parameter_property endpoint_l1_latency_${f}_hwtcl GROUP $group_name
   set_parameter_property endpoint_l1_latency_${f}_hwtcl VISIBLE false
   set_parameter_property endpoint_l1_latency_${f}_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l1_latency_${f}_hwtcl DESCRIPTION "Sets the acceptable exit latency that an endpoint can withstand in the transition from the L1 to L0 state. It is an indirect measure of the endpoint internal buffering. This setting is disabled for root ports."
   set_parameter_property endpoint_l1_latency_${f}_hwtcl DERIVED true

}

proc add_pcie_hip_hidden_rtl_parameters {func_num} {

   send_message debug "proc:add_pcie_hip_hidden_rtl_parameters for Function ${func_num}"

   set f $func_num

   if {$f == 0} {

      add_parameter          rx_ei_l0s_hwtcl integer 0
      set_parameter_property rx_ei_l0s_hwtcl VISIBLE false
      set_parameter_property rx_ei_l0s_hwtcl DERIVED true
      set_parameter_property rx_ei_l0s_hwtcl HDL_PARAMETER false

      add_parameter          pld_clk_MHz integer 125
      set_parameter_property pld_clk_MHz VISIBLE false
      set_parameter_property pld_clk_MHz HDL_PARAMETER false
      set_parameter_property pld_clk_MHz DERIVED true

      add_parameter          reconfig_to_xcvr_width integer 10
      set_parameter_property reconfig_to_xcvr_width VISIBLE false
      set_parameter_property reconfig_to_xcvr_width HDL_PARAMETER true
      set_parameter_property reconfig_to_xcvr_width DERIVED true

      add_parameter          hip_hard_reset_hwtcl integer 0
      set_parameter_property hip_hard_reset_hwtcl VISIBLE false
      set_parameter_property hip_hard_reset_hwtcl DERIVED true
      set_parameter_property hip_hard_reset_hwtcl HDL_PARAMETER true

      add_parameter          force_hrc  integer 0
      set_parameter_property force_hrc  VISIBLE false
      set_parameter_property force_hrc  HDL_PARAMETER false

      add_parameter          force_src integer 0
      set_parameter_property force_src VISIBLE false
      set_parameter_property force_src HDL_PARAMETER false

      add_parameter          reconfig_from_xcvr_width integer 10
      set_parameter_property reconfig_from_xcvr_width VISIBLE false
      set_parameter_property reconfig_from_xcvr_width HDL_PARAMETER true
      set_parameter_property reconfig_from_xcvr_width DERIVED true

      add_parameter single_rx_detect_hwtcl integer 0
      set_parameter_property single_rx_detect_hwtcl VISIBLE false
      set_parameter_property single_rx_detect_hwtcl HDL_PARAMETER true
      set_parameter_property single_rx_detect_hwtcl DERIVED true

      add_parameter enable_l0s_aspm_hwtcl string "false"
      set_parameter_property enable_l0s_aspm_hwtcl VISIBLE false
      set_parameter_property enable_l0s_aspm_hwtcl DERIVED true
      set_parameter_property enable_l0s_aspm_hwtcl HDL_PARAMETER true

      add_parameter aspm_optionality_hwtcl string "false"
      set_parameter_property aspm_optionality_hwtcl VISIBLE false
      set_parameter_property aspm_optionality_hwtcl DERIVED true
      set_parameter_property aspm_optionality_hwtcl HDL_PARAMETER true

      add_parameter enable_adapter_half_rate_mode_hwtcl string "false"
      set_parameter_property enable_adapter_half_rate_mode_hwtcl VISIBLE false
      set_parameter_property enable_adapter_half_rate_mode_hwtcl HDL_PARAMETER true
      set_parameter_property enable_adapter_half_rate_mode_hwtcl DERIVED true

      add_parameter millisecond_cycle_count_hwtcl integer 248500
      set_parameter_property millisecond_cycle_count_hwtcl VISIBLE false
      set_parameter_property millisecond_cycle_count_hwtcl HDL_PARAMETER true
      set_parameter_property millisecond_cycle_count_hwtcl DERIVED true

      add_parameter          set_l0s_hwtcl integer 0
      set_parameter_property set_l0s_hwtcl VISIBLE false
      set_parameter_property set_l0s_hwtcl HDL_PARAMETER false

      # Testbench related parameters
      add_parameter          serial_sim_hwtcl integer 0
      set_parameter_property serial_sim_hwtcl VISIBLE false
      set_parameter_property serial_sim_hwtcl HDL_PARAMETER false

      # Internal parameter to force using direct value for credit in the command line and bypass UI
      #  default zero
      add_parameter override_rxbuffer_cred_preset integer 0
      set_parameter_property override_rxbuffer_cred_preset VISIBLE false
      set_parameter_property override_rxbuffer_cred_preset HDL_PARAMETER false

      add_parameter credit_buffer_allocation_aux_hwtcl string "balanced"
      set_parameter_property credit_buffer_allocation_aux_hwtcl VISIBLE false
      set_parameter_property credit_buffer_allocation_aux_hwtcl HDL_PARAMETER true
      set_parameter_property credit_buffer_allocation_aux_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_posted_header_hwtcl integer 50
      set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_posted_header_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_posted_data_hwtcl integer 360
      set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_posted_data_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl integer 54
      set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_nonposted_header_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl integer 0
      set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_nonposted_data_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_compl_header_hwtcl integer 112
      set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_compl_header_hwtcl DERIVED true

      add_parameter vc0_rx_flow_ctrl_compl_data_hwtcl integer 448
      set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl VISIBLE false
      set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl HDL_PARAMETER true
      set_parameter_property vc0_rx_flow_ctrl_compl_data_hwtcl DERIVED true

      add_parameter cpl_spc_header_hwtcl integer 112
      set_parameter_property cpl_spc_header_hwtcl VISIBLE false
      set_parameter_property cpl_spc_header_hwtcl HDL_PARAMETER true
      set_parameter_property cpl_spc_header_hwtcl DERIVED true

      add_parameter cpl_spc_data_hwtcl integer 448
      set_parameter_property cpl_spc_data_hwtcl VISIBLE false
      set_parameter_property cpl_spc_data_hwtcl HDL_PARAMETER true
      set_parameter_property cpl_spc_data_hwtcl DERIVED true

      add_parameter          port_width_data_hwtcl integer 64
      set_parameter_property port_width_data_hwtcl VISIBLE false
      set_parameter_property port_width_data_hwtcl DERIVED true
      set_parameter_property port_width_data_hwtcl HDL_PARAMETER true

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
      # add_parameter coreclkout_hip_phaseshift_hwtcl string "0 ps"
      # set_parameter_property coreclkout_hip_phaseshift_hwtcl VISIBLE false
      # set_parameter_property coreclkout_hip_phaseshift_hwtcl HDL_PARAMETER true
      #
      # add_parameter pldclk_hip_phase_shift_hwtcl string "0 ps"
      # set_parameter_property pldclk_hip_phase_shift_hwtcl VISIBLE false
      # set_parameter_property pldclk_hip_phase_shift_hwtcl HDL_PARAMETER true

      # add_parameter          port_width_be_hwtcl integer 8
      # set_parameter_property port_width_be_hwtcl VISIBLE false
      # set_parameter_property port_width_be_hwtcl HDL_PARAMETER true
      # set_parameter_property port_width_be_hwtcl DERIVED true

      add_pcie_hip_hidden_non_derived_rtl_parameters
   }

   add_parameter maximum_current_${f}_hwtcl integer 0
   set_parameter_property maximum_current_${f}_hwtcl VISIBLE false
   set_parameter_property maximum_current_${f}_hwtcl HDL_PARAMETER true

   add_parameter disable_snoop_packet_${f}_hwtcl string "false"
   set_parameter_property disable_snoop_packet_${f}_hwtcl VISIBLE false
   set_parameter_property disable_snoop_packet_${f}_hwtcl HDL_PARAMETER true


   add_parameter bridge_port_vga_enable_${f}_hwtcl string "false"
   set_parameter_property bridge_port_vga_enable_${f}_hwtcl VISIBLE false
   set_parameter_property bridge_port_vga_enable_${f}_hwtcl HDL_PARAMETER true

   add_parameter bridge_port_ssid_support_${f}_hwtcl string "false"
   set_parameter_property bridge_port_ssid_support_${f}_hwtcl VISIBLE false
   set_parameter_property bridge_port_ssid_support_${f}_hwtcl HDL_PARAMETER true

   add_parameter ssvid_${f}_hwtcl integer 0
   set_parameter_property ssvid_${f}_hwtcl VISIBLE false
   set_parameter_property ssvid_${f}_hwtcl HDL_PARAMETER true

   add_parameter ssid_${f}_hwtcl integer 0
   set_parameter_property ssid_${f}_hwtcl VISIBLE false
   set_parameter_property ssid_${f}_hwtcl HDL_PARAMETER true

}

proc update_param_validation_settings {max_func} {
   validation_parameter_system_setting
   #validation_parameter_reconfig_setting

   set num_of_func_hwtcl [get_parameter_value num_of_func_hwtcl]

   for {set f 0} {$f < $max_func} {incr f} {

      set porttype_func_hwtcl [get_parameter_value porttype_func_hwtcl]

      if { [ regexp Root $porttype_func_hwtcl ] } {
         set_parameter_value porttype_func0_hwtcl $porttype_func_hwtcl
      } else {
         set_parameter_value  porttype_func${f}_hwtcl [get_parameter_value porttype_func_hwtcl]
      }


      set_parameter_value max_payload_size_${f}_hwtcl [get_parameter_value max_payload_size_hwtcl]
      set_parameter_value extend_tag_field_${f}_hwtcl [get_parameter_value extend_tag_field_hwtcl]
      set_parameter_value completion_timeout_${f}_hwtcl [get_parameter_value completion_timeout_hwtcl]
      set_parameter_value enable_completion_timeout_disable_${f}_hwtcl [get_parameter_value enable_completion_timeout_disable_hwtcl]

      set_parameter_value use_aer_${f}_hwtcl [get_parameter_value use_aer_hwtcl]
      set_parameter_value ecrc_check_capable_${f}_hwtcl [get_parameter_value ecrc_check_capable_hwtcl]
      set_parameter_value ecrc_gen_capable_${f}_hwtcl [get_parameter_value ecrc_gen_capable_hwtcl]

      set_parameter_value slot_power_scale_${f}_hwtcl [get_parameter_value slot_power_scale_hwtcl]
      set_parameter_value slot_power_limit_${f}_hwtcl [get_parameter_value slot_power_limit_hwtcl]
      set_parameter_value slot_number_${f}_hwtcl [get_parameter_value slot_number_hwtcl]

      set_parameter_value rx_ei_l0s_${f}_hwtcl [get_parameter_value rx_ei_l0s_hwtcl]
      set_parameter_value endpoint_l0_latency_${f}_hwtcl [get_parameter_value endpoint_l0_latency_hwtcl]
      set_parameter_value endpoint_l1_latency_${f}_hwtcl [get_parameter_value endpoint_l1_latency_hwtcl]

      if  {$f < $num_of_func_hwtcl} {
         set_parameter_value func${f}_en_hwtcl 1
      } else {
         set_parameter_value func${f}_en_hwtcl 0
      }

      validation_parameter_bar $f
      validation_parameter_pcie_cap_reg $f
   }

   validation_parameter_base_limit_reg
   update_default_value_hidden_parameter

   # Port updates
   add_pcie_hip_port_clk
   add_pcie_hip_port_serial
   add_pcie_hip_port_ast_rx
   add_pcie_hip_port_ast_tx
   add_pcie_hip_port_pipe
   add_pcie_hip_port_rst
   add_pcie_hip_port_lmi
   add_pcie_hip_port_pw_mngt
   add_pcie_hip_port_reconfig
   add_pcie_hip_port_hip_reconfig
   add_pcie_hip_port_interrupt
   add_pcie_hip_port_tl_cfg
   add_pcie_hip_port_status

   # Parameter updates
   set_pcie_hip_flow_control_settings
   set_pcie_cvp_parameters
   set_module_assignment testbench.partner.pcie_tb.parameter.lane_mask_hwtcl              [get_parameter lane_mask_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.pll_refclk_freq_hwtcl        [get_parameter pll_refclk_freq_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.port_type_hwtcl              [get_parameter porttype_func0_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.gen123_lane_rate_mode_hwtcl  [get_parameter gen12_lane_rate_mode_hwtcl]
   set_module_assignment testbench.partner.pcie_tb.parameter.serial_sim_hwtcl             [get_parameter serial_sim_hwtcl ]

   set ast_width_hwtcl [get_parameter_value ast_width_hwtcl ]
   set vendor_id_hwtcl [get_parameter_value vendor_id_0_hwtcl ]
   set device_id_hwtcl [get_parameter_value device_id_0_hwtcl ]
   set override_tbpartner_driver_setting_hwtcl [get_parameter_value override_tbpartner_driver_setting_hwtcl ]

   if { $override_tbpartner_driver_setting_hwtcl>0 } {
     set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl  $override_tbpartner_driver_setting_hwtcl
   } elseif { $vendor_id_hwtcl == 4466 && $device_id_hwtcl == 57345 } {
   # Setting testbench driver
   # If Vendor ID == 0x1172 && Device ID == 0xE001 --> assign driver to DMA or target
   # else  assign driver to training & configuration only
   # set_parameter_property apps_type_hwtcl ALLOWED_RANGES {"1:Link training and configuration" "2:Link training, configuration and chaining DMA" "3:Link training, configuration and target"}
      set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl 2
      send_message info "When using VendorID:0x1172 and DeviceID:0xE001 the generated testbench driver will run a simulation which includes link training, configuration and chaining DMA"
   } else {
     set_module_assignment testbench.partner.pcie_tb.parameter.apps_type_hwtcl  1
   }
}

proc update_default_value_hidden_parameter {} {
   # This proc is used to update hidden parameter values of QSYS system created
   # with a previous HWTCL version and different hidden parameter value
   add_av_pcie_hip_common_hidden_parameters_update
}

proc validation_parameter_system_setting {} {
   set port_type_hwtcl             [ get_parameter_value porttype_func_hwtcl         ]
   set ast_width_hwtcl             [ get_parameter_value ast_width_hwtcl             ]
   set lane_mask_hwtcl             [ get_parameter_value lane_mask_hwtcl             ]
   set gen12_lane_rate_mode_hwtcl  [ get_parameter_value gen12_lane_rate_mode_hwtcl  ]
   set set_pld_clk_x1_625MHz_hwtcl [ get_parameter_value set_pld_clk_x1_625MHz_hwtcl ]
   set num_of_func_hwtcl           [ get_parameter_value num_of_func_hwtcl           ]
   set device_family_hwtcl         [ get_parameter_value INTENDED_DEVICE_FAMILY      ]

   send_message info "Device family is $device_family_hwtcl"

   if { [ regexp Root $port_type_hwtcl ] && $num_of_func_hwtcl > 1 } {
      send_message error "Number of Functions must me set to 1 if Port Type selected is Root Port"
   }

   if { $set_pld_clk_x1_625MHz_hwtcl == 1 } {
      if { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen1 $gen12_lane_rate_mode_hwtcl ] } {
         send_message debug "The application clock frequency (pld_clk) is 62.5 Mhz"
      } else {
         send_message error "62.5 Mhz application clock setting is only valid for Gen1 x1"
      }
   }

   if { [ regexp x1 $lane_mask_hwtcl ] } {
   # Gen1:x1
      if {$device_family_hwtcl == "Cyclone V" && [ regexp Gen2 $gen12_lane_rate_mode_hwtcl ] } {
         send_message info "Gen2x1 support available only for GT Devices"
      }
      if { [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $gen12_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         if { $set_pld_clk_x1_625MHz_hwtcl == 0 } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 62.5 Mhz"
            set_parameter_value pld_clk_MHz 625
            set_parameter_value millisecond_cycle_count_hwtcl 62125
         }
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen1 $gen12_lane_rate_mode_hwtcl ]  } {
   # Gen1:x2
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen12_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
         if { $set_pld_clk_x1_625MHz_hwtcl == 1 } {
            send_message warning "Ignoring 62.5 Mhz application clock setting as it only applies to x1"
         }
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen2 $gen12_lane_rate_mode_hwtcl ]  } {
   # Gen2:x2
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen12_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
         if { $set_pld_clk_x1_625MHz_hwtcl == 1 } {
            send_message warning "Ignoring 62.5 Mhz application clock setting as it only applies to x1"
         }
      }
   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen1 $gen12_lane_rate_mode_hwtcl ] } {
   # Gen1:x4
      if { [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $gen12_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen2 $gen12_lane_rate_mode_hwtcl ] } {
   # Gen2:x4
      if {$device_family_hwtcl == "Cyclone V" } {
         send_message info "Gen2x4 support available only for GT Devices"
      }
      if { [ regexp 128 $ast_width_hwtcl ] } {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250

         #Enable Half Rate Mode as per RBC for Gen2x4
         set_parameter_value enable_adapter_half_rate_mode_hwtcl "true"
      } else {
         send_message error "The application interface must be set to Avalon-ST 128-bit when using $gen12_lane_rate_mode_hwtcl $lane_mask_hwtcl"
      }

   } elseif { [ regexp x8 $lane_mask_hwtcl ] && [ regexp Gen1 $gen12_lane_rate_mode_hwtcl ] } {
   # Gen1:x8
      if {$device_family_hwtcl == "Cyclone V"} {
         send_message error "Gen1x8 is not supported. Supported \"Lane Rate\" and \"Number of Lanes\" combinations are: Gen1x1, Gen1x4, Gen2x1 for GT Devices & Gen1x1, Gen1x4 for GX Devices"
      } else {
         if { [ regexp 128 $ast_width_hwtcl ] } {
               send_message info "The application clock frequency (pld_clk) is 125 Mhz"
               set_parameter_value pld_clk_MHz 1250
               set_parameter_value millisecond_cycle_count_hwtcl 124250
               #Enable Half Rate Mode as per RBC for Gen1x8
               set_parameter_value enable_adapter_half_rate_mode_hwtcl "true"
         } else {
            send_message error "The application interface must be set to Avalon-ST 128-bit when using $gen12_lane_rate_mode_hwtcl $lane_mask_hwtcl"
         }
      }
   } elseif { [ regexp x8 $lane_mask_hwtcl ] && [ regexp Gen2 $gen12_lane_rate_mode_hwtcl ] } {
   # Gen2:x8
      send_message error "Gen2x8 is not supported. Supported \"Lane Rate\" and \"Number of Lanes\" combinations are: Gen1x1, Gen1x4, Gen1x8, Gen2x1, Gen2x4"
   }

   # Enabling Hard Reset Controller/Soft Reset Controller
   set fsrc             [ get_parameter_value force_src             ]
   set fhrc             [ get_parameter_value force_hrc             ]
   set in_cvp_mode_hwtcl   [ get_parameter_value in_cvp_mode_hwtcl   ]

   if { $fhrc == 1 || $in_cvp_mode_hwtcl == 1} {
        set_parameter_value hip_hard_reset_hwtcl 1
        send_message debug "Hard Reset Controller is enabled"
   } elseif {  $fsrc == 1  } {
        set_parameter_value hip_hard_reset_hwtcl 0
        send_message debug "Soft Reset Controller is enabled"
   } else {
        set_parameter_value hip_hard_reset_hwtcl 1
        send_message debug "Hard Reset Controller is enabled"
   }

   # Setting AST Port width parameters
   set dataWidth        [  expr [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [  expr [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set dataEmptyWidth   1

   set_parameter_value port_width_data_hwtcl      $dataWidth

   # Disable L0s
   set L0s [ get_parameter_value set_l0s_hwtcl ]
   if { $L0s == 1 } {
      set_parameter_value rx_ei_l0s_hwtcl 1
      set_parameter_value enable_l0s_aspm_hwtcl "true"
      set_parameter_value aspm_optionality_hwtcl "false"
      } else {
      set_parameter_value rx_ei_l0s_hwtcl 0
      set_parameter_value enable_l0s_aspm_hwtcl "false"
      set_parameter_value aspm_optionality_hwtcl "true"
   }

   # Setting Reconfig Port width parameters
   set reconfig_interfaces 11
   if  { [ regexp x1 $lane_mask_hwtcl ] } {
      set reconfig_interfaces 2
      set_parameter_value single_rx_detect_hwtcl 1
   } elseif  { [ regexp x2 $lane_mask_hwtcl ] } {
      set reconfig_interfaces 3
      set_parameter_value single_rx_detect_hwtcl 2
   } elseif { [ regexp x4 $lane_mask_hwtcl ] } {
      set reconfig_interfaces 5
      set_parameter_value single_rx_detect_hwtcl 4
   } else {
      set reconfig_interfaces 10
      set_parameter_value single_rx_detect_hwtcl 0
   }
   set_parameter_value reconfig_to_xcvr_width   [ common_get_reconfig_to_xcvr_total_width "Arria V" $reconfig_interfaces ]
   set_parameter_value reconfig_from_xcvr_width [ common_get_reconfig_from_xcvr_total_width "Arria V" $reconfig_interfaces ]
   send_message info "$reconfig_interfaces reconfiguration interfaces are required for connection to the external reconfiguration controller"

}


proc validation_parameter_bar {func_num} {

   set f $func_num

   set port_type_hwtcl [ get_parameter_value porttype_func${f}_hwtcl ]

   set  bar_size_mask_hwtcl(0) [ get_parameter_value bar0_size_mask_${f}_hwtcl ]
   set  bar_size_mask_hwtcl(1) [ get_parameter_value bar1_size_mask_${f}_hwtcl ]
   set  bar_size_mask_hwtcl(2) [ get_parameter_value bar2_size_mask_${f}_hwtcl ]
   set  bar_size_mask_hwtcl(3) [ get_parameter_value bar3_size_mask_${f}_hwtcl ]
   set  bar_size_mask_hwtcl(4) [ get_parameter_value bar4_size_mask_${f}_hwtcl ]
   set  bar_size_mask_hwtcl(5) [ get_parameter_value bar5_size_mask_${f}_hwtcl ]

   set  bar_ignore_warning_size(0) 0
   set  bar_ignore_warning_size(1) 0
   set  bar_ignore_warning_size(2) 0
   set  bar_ignore_warning_size(3) 0
   set  bar_ignore_warning_size(4) 0
   set  bar_ignore_warning_size(5) 0

   set  bar_type_hwtcl(0) [ get_parameter_value bar0_type_${f}_hwtcl ]
   set  bar_type_hwtcl(1) [ get_parameter_value bar1_type_${f}_hwtcl ]
   set  bar_type_hwtcl(2) [ get_parameter_value bar2_type_${f}_hwtcl ]
   set  bar_type_hwtcl(3) [ get_parameter_value bar3_type_${f}_hwtcl ]
   set  bar_type_hwtcl(4) [ get_parameter_value bar4_type_${f}_hwtcl ]
   set  bar_type_hwtcl(5) [ get_parameter_value bar5_type_${f}_hwtcl ]

   set enable_function_msix_support_hwtcl [ get_parameter_value enable_function_msix_support_${f}_hwtcl]

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
               set bar_type_hwtcl($ii) $DISABLE_BAR
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
      set expansion_base_address_register [ get_parameter_value expansion_base_address_register_${f}_hwtcl ]
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
      for {set i 2} {$i < 6} {incr i 1} {
         if {  $bar_type_hwtcl($i) > 0 } {
            send_message error "BAR$i: must be Disabled when using Root port"
         }
      }
   }

   # Setting derived parameter
   for {set i 0} {$i < 6} {incr i 1} {
      if { $bar_type_hwtcl($i)>0 } {
         if { $bar_size_mask_hwtcl($i)==0 && $bar_ignore_warning_size($i)==0 } {
            send_message error "The size of BAR$i is incorrectly set"
         }
      }
      if { $bar_type_hwtcl($i)== $DISABLE_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_${f}_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_${f}_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_${f}_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>0 && $bar_ignore_warning_size($i)==0 } {
            send_message error "The size of BAR$i must be set to N/A as BAR$i is disabled"
         }
      } elseif { $bar_type_hwtcl($i) == $PREFETACHBLE_64_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_${f}_hwtcl" "Enabled"
            set_parameter_value "bar${i}_prefetchable_${f}_hwtcl" "Enabled"
            set_parameter_value "bar${i}_io_space_${f}_hwtcl" "Disabled"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
            send_message error "The size of the 64-bit prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i) == $NON_PREFETCHABLE_32_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_${f}_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_${f}_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_${f}_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>31 } {
            send_message error "The size of the 32-bit non-prefetchable BAR$i must be less than 31 bits"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
            send_message error "The size of the 32-bit non-prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i)== $PREFETCHABLE_32_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_${f}_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_${f}_hwtcl" "Enabled"
         set_parameter_value "bar${i}_io_space_${f}_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>31 } {
            send_message error "The size of the 32-bit prefetchable BAR$i must be less than 31 bits"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
            send_message error "The size of the 32-bit prefetchable BAR$i must be greater than 7 bits"
         }
      } elseif { $bar_type_hwtcl($i) == $IO_SPACE_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_${f}_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_${f}_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_${f}_hwtcl" "Enabled"
         if { $bar_size_mask_hwtcl($i)>12 } {
            send_message error "The size of the I/O space BAR$i must be less than 12 bits"
         }
      }
   }
   if { [ regexp endpoint $port_type_hwtcl ] } {
      # Slot register checking
      set enable_slot_register_hwtcl [get_parameter_value enable_slot_register_hwtcl]
      if { $enable_slot_register_hwtcl == 1 } {
         send_message error "The slot register parameter can only be enabled when using Root port and must be disabled when using Endpoint"
         # Return Code: Break
         return -code 3;
      }
      set dll_active_report_support_hwtcl   [get_parameter_value dll_active_report_support_${f}_hwtcl  ]
      if { $dll_active_report_support_hwtcl == 1 } {
         send_message error "The data link layer active reporting parameter can only be enabled when using Root port and must be disabled when using Endpoint"
      }
      set surprise_down_error_support_hwtcl [get_parameter_value surprise_down_error_support_${f}_hwtcl]
      if { $surprise_down_error_support_hwtcl == 1 } {
         send_message error "The surprise down reporting parameter can only be enabled when using Root port and must be disabled when using Endpoint"
      }
      set enable_completion_timeout_disable_hwtcl [get_parameter_value enable_completion_timeout_disable_${f}_hwtcl]
      if { $enable_completion_timeout_disable_hwtcl == 0 } {
         send_message error "The implement completion timeout disable parameter can only be disabled when using Root port and must be enabled when using Endpoint"
         # Return Code: Break
         return -code 3;
      }
      if { $enable_function_msix_support_hwtcl == 1 } {
         set msix_table_bir_hwtcl [get_parameter_value msix_table_bir_${f}_hwtcl]
         if  { $bar_size_mask_hwtcl($msix_table_bir_hwtcl) == 0 || $bar_type_hwtcl($msix_table_bir_hwtcl) == 0 } {
            send_message error "The table BAR indicator value is incorrect and must correspond to an enabled BAR"
         }
         set msix_pba_bir_hwtcl [get_parameter_value msix_pba_bir_${f}_hwtcl]
         if  { $bar_size_mask_hwtcl($msix_pba_bir_hwtcl) == 0 || $bar_type_hwtcl($msix_pba_bir_hwtcl) == 0 } {
            send_message error "The pending bit array BAR indicator value is incorrect and must correspond to an enabled BAR"
         }
      }
   } else {
      if { $enable_function_msix_support_hwtcl == 1 } {
         send_message error "The implement MSI-X parameter can only be enabled when using Endpoint and must be disabled when using Root port"
      }
   }
}

proc validation_parameter_base_limit_reg {} {

   set port_type_hwtcl [ get_parameter_value porttype_func0_hwtcl ]
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

proc validation_parameter_pcie_cap_reg {func_num} {

   set f $func_num
   set interrupt_pin_hwtcl [ get_parameter_value interrupt_pin_${f}_hwtcl  ]
   set num_of_func_hwtcl   [ get_parameter_value num_of_func_hwtcl         ]

   # AER settings checks
   set use_aer_hwtcl                  [ get_parameter_value use_aer_${f}_hwtcl             ]
   set ecrc_check_capable_hwtcl       [ get_parameter_value ecrc_check_capable_${f}_hwtcl  ]
   set ecrc_gen_capable_hwtcl         [ get_parameter_value ecrc_gen_capable_${f}_hwtcl    ]
   set use_crc_forwarding_hwtcl       [ get_parameter_value use_crc_forwarding_hwtcl  ]

   if { $use_aer_hwtcl == 0 } {
      if { $ecrc_check_capable_hwtcl == 1 } {
         send_message error "Implement ECRC check cannot be set when Implement advanced error reporting is not set"
         # Return Code: Break
         return -code 3;
      }
      if { $ecrc_gen_capable_hwtcl == 1 } {
         send_message error "Implement ECRC generation cannot be set when Implement advanced error reporting is not set"
         # Return Code: Break
         return -code 3;
      }
      if { $use_crc_forwarding_hwtcl == 1 } {
         send_message error "Implement ECRC forwarding cannot be set when Implement advanced error reporting is not set"
         # Return Code: Break
         return -code 3;
      }
   }

   if {$num_of_func_hwtcl == 1} {
      if { [ regexp ((intb)|(intc)|(intd)|(none)) $interrupt_pin_hwtcl ] } {
         send_message error "INTB, INTC, INTD, None are available only when Multifunction is selected. Currently Number of Function is set to $num_of_func_hwtcl"
      }
   } else {
      if { $use_aer_hwtcl == 1 } {
         send_message error "Advance Error Reproting (AER) can only be enabled when Single Function is selected. Currently Number of Function is set to $num_of_func_hwtcl"
         # Return Code: Break
         return -code 3;
      }
   }
}
