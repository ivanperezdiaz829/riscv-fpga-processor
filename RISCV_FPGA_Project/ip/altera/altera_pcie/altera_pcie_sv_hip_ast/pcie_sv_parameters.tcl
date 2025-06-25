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
   add_parameter INTENDED_DEVICE_FAMILY String "STRATIX V"
   set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
   set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE

   add_parameter pcie_qsys integer 1
   set_parameter_property pcie_qsys VISIBLE false

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
   set_parameter_property gen123_lane_rate_mode_hwtcl DESCRIPTION "Selects the maximum data rate of the link.Gen1 (2.5 Gbps), Gen2 (5.0 Gbps) and Gen3 (8.0 Gbps) are supported."

   # Selects the port type
   add_parameter          port_type_hwtcl string "Native endpoint"
   set_parameter_property port_type_hwtcl DISPLAY_NAME "Port type"
   set_parameter_property port_type_hwtcl ALLOWED_RANGES {"Native endpoint" "Root port" "Legacy endpoint" }
   set_parameter_property port_type_hwtcl GROUP $group_name
   set_parameter_property port_type_hwtcl VISIBLE true
   set_parameter_property port_type_hwtcl HDL_PARAMETER true
   set_parameter_property port_type_hwtcl DESCRIPTION "Selects the port type. Native endpoints, root ports, and legacy endpoints are supported."

   # Protocol version in use
   add_parameter          pcie_spec_version_hwtcl string "2.1"
   set_parameter_property pcie_spec_version_hwtcl DISPLAY_NAME "PCI Express Base Specification version"
   set_parameter_property pcie_spec_version_hwtcl ALLOWED_RANGES {"2.1" "3.0"}
   set_parameter_property pcie_spec_version_hwtcl GROUP $group_name
   set_parameter_property pcie_spec_version_hwtcl VISIBLE true
   set_parameter_property pcie_spec_version_hwtcl HDL_PARAMETER true
   set_parameter_property pcie_spec_version_hwtcl DESCRIPTION "Selects the version of PCI Express Base Specification implemented. Versions 2.1 and 3.0 are supported."

   # Application Interface
   add_parameter          ast_width_hwtcl string "Avalon-ST 64-bit"
   set_parameter_property ast_width_hwtcl DISPLAY_NAME "Application interface"
   set_parameter_property ast_width_hwtcl ALLOWED_RANGES {"Avalon-ST 64-bit" "Avalon-ST 128-bit" "Avalon-ST 256-bit"}
   set_parameter_property ast_width_hwtcl GROUP $group_name
   set_parameter_property ast_width_hwtcl VISIBLE true
   set_parameter_property ast_width_hwtcl HDL_PARAMETER true
   set_parameter_property ast_width_hwtcl DESCRIPTION "Selects the width of the data interface between the transaction layer and the application layer implemented in the PLD fabric. The IP core supports interfaces of 64, 128, or 256 bits."

   # RX Buffer Credit Setting
   add_parameter          rxbuffer_rxreq_hwtcl string "Low"
   set_parameter_property rxbuffer_rxreq_hwtcl DISPLAY_NAME "RX buffer credit allocation - performance for received requests"
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

   # Parity
   add_parameter          use_ast_parity integer 0
   set_parameter_property use_ast_parity DISPLAY_NAME "Enable byte parity ports on Avalon-ST interface"
   set_parameter_property use_ast_parity DISPLAY_HINT boolean
   set_parameter_property use_ast_parity GROUP $group_name
   set_parameter_property use_ast_parity VISIBLE true
   set_parameter_property use_ast_parity HDL_PARAMETER true
   set_parameter_property use_ast_parity DESCRIPTION "Enables or disables parity ports on Avalon-ST interface. When enabled the application layer must provide valid byte parity on the Avalon-ST TX direction."

   add_parameter          multiple_packets_per_cycle_hwtcl integer 0
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_NAME "Enable multiple packets per cycle"
   set_parameter_property multiple_packets_per_cycle_hwtcl DISPLAY_HINT boolean
   set_parameter_property multiple_packets_per_cycle_hwtcl GROUP $group_name
   set_parameter_property multiple_packets_per_cycle_hwtcl VISIBLE true
   set_parameter_property multiple_packets_per_cycle_hwtcl HDL_PARAMETER true
   set_parameter_property multiple_packets_per_cycle_hwtcl DESCRIPTION "When On, the Avalon-ST interface supports the transmission of TLPs starting at any 64-bit address boundary, allowing support for multiple packets in a single cycle. To support multiple packets per cycle, the Avalon-ST interface includes either 2 or 4 start of packet and end of packet signals for the 128- and 256-bit Avalon-ST interfaces."

   # CVP
   add_parameter          in_cvp_mode_hwtcl integer 0
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_NAME "Enable configuration via the PCIe link"
   set_parameter_property in_cvp_mode_hwtcl DISPLAY_HINT boolean
   set_parameter_property in_cvp_mode_hwtcl GROUP $group_name
   set_parameter_property in_cvp_mode_hwtcl VISIBLE true
   set_parameter_property in_cvp_mode_hwtcl HDL_PARAMETER true
   set_parameter_property in_cvp_mode_hwtcl DESCRIPTION "Selects the hard IP block that includes logic to configure the FPGA  via the PCI Express link."

   # Credit consumed
   add_parameter          use_tx_cons_cred_sel_hwtcl integer 0
   set_parameter_property use_tx_cons_cred_sel_hwtcl DISPLAY_NAME "Use credit consumed selection port tx_cons_cred_sel"
   set_parameter_property use_tx_cons_cred_sel_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_tx_cons_cred_sel_hwtcl GROUP $group_name
   set_parameter_property use_tx_cons_cred_sel_hwtcl VISIBLE true
   set_parameter_property use_tx_cons_cred_sel_hwtcl HDL_PARAMETER false
   set_parameter_property use_tx_cons_cred_sel_hwtcl DESCRIPTION "The optional input port tx_cons_cred_sel could be used to retrieve tx credit consumed HIP counter value  "

   # PCI extended space
   add_parameter          use_pci_ext_hwtcl integer 0
   set_parameter_property use_pci_ext_hwtcl DISPLAY_NAME "Use PCI extended space"
   set_parameter_property use_pci_ext_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_pci_ext_hwtcl GROUP $group_name
   set_parameter_property use_pci_ext_hwtcl VISIBLE false
   set_parameter_property use_pci_ext_hwtcl HDL_PARAMETER true
   set_parameter_property use_pci_ext_hwtcl DESCRIPTION "When On, an addresses 0x0C8-0x0FC in the Common Configuration Space Header are reserved for PCI extensions"

   # PCI Express extended space
   add_parameter          use_pcie_ext_hwtcl integer 0
   set_parameter_property use_pcie_ext_hwtcl DISPLAY_NAME "Use PCI Express extended space"
   set_parameter_property use_pcie_ext_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_pcie_ext_hwtcl GROUP $group_name
   set_parameter_property use_pcie_ext_hwtcl VISIBLE false
   set_parameter_property use_pcie_ext_hwtcl HDL_PARAMETER true
   set_parameter_property use_pcie_ext_hwtcl DESCRIPTION "When On, an addresses 0x900-0xFFc in the PCI Express Configuration Space Header are reserved for PCI Express extensions."

   # Config Bypass
   add_parameter          use_config_bypass_hwtcl integer 0
   set_parameter_property use_config_bypass_hwtcl DISPLAY_NAME "Enable Configuration Bypass"
   set_parameter_property use_config_bypass_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_config_bypass_hwtcl GROUP $group_name
   set_parameter_property use_config_bypass_hwtcl VISIBLE true
   set_parameter_property use_config_bypass_hwtcl HDL_PARAMETER true
   set_parameter_property use_config_bypass_hwtcl DESCRIPTION "When On, the Stratix V Hard IP for PCI Express bypasses the Transaction Layer Configuration Space registers included as part of the Hard IP, allowing you to substitute a custom Configuration Space implemented in soft logic."

   add_parameter          hip_reconfig_hwtcl integer 0
   set_parameter_property hip_reconfig_hwtcl DISPLAY_NAME "Enable Hard IP reconfiguration"
   set_parameter_property hip_reconfig_hwtcl DISPLAY_HINT boolean
   set_parameter_property hip_reconfig_hwtcl GROUP $group_name
   set_parameter_property hip_reconfig_hwtcl VISIBLE true
   set_parameter_property hip_reconfig_hwtcl HDL_PARAMETER true
   set_parameter_property hip_reconfig_hwtcl DESCRIPTION "When On, enables creates an Avalon-MM slave interface which software can drive to update global configuration registers that are read-only at run time. "

   add_parameter          enable_tl_only_sim_hwtcl integer 0
   set_parameter_property enable_tl_only_sim_hwtcl DISPLAY_NAME "Enable TL-Direct simulation"
   set_parameter_property enable_tl_only_sim_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_tl_only_sim_hwtcl GROUP $group_name
   set_parameter_property enable_tl_only_sim_hwtcl VISIBLE false
   set_parameter_property enable_tl_only_sim_hwtcl HDL_PARAMETER true
   set_parameter_property enable_tl_only_sim_hwtcl DESCRIPTION "When On, enables simulation with TL BFM"

}

proc add_pcie_hip_parameters_ui_pci_registers {} {

   send_message debug "proc:add_pcie_hip_parameters_ui_pci_registers"

   set group_name_all "Base Address Registers"

   #-----------------------------------------------------------------------------------------------------------------
   add_display_item "" "Base Address Registers" group
   for { set i 0 } { $i < 6 } { incr i } {
       add_display_item "Base Address Registers" "BAR${i}" group
       set_display_item_property "BAR${i}" display_hint tab
   }
   add_display_item "Base Address Registers" "Expansion ROM" group
   set_display_item_property "Expansion ROM" display_hint tab

   set group_name "BAR0"

   add_parameter          bar0_type_hwtcl integer 1
   set_parameter_property bar0_type_hwtcl DISPLAY_NAME "Type"
   set_parameter_property bar0_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar0_type_hwtcl GROUP $group_name
   set_parameter_property bar0_type_hwtcl VISIBLE true
   set_parameter_property bar0_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar0_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar0_size_mask_hwtcl integer 28
   set_parameter_property bar0_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar0_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar0_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar0_size_mask_hwtcl VISIBLE true
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
   set_parameter_property bar1_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar1_type_hwtcl GROUP $group_name
   set_parameter_property bar1_type_hwtcl VISIBLE true
   set_parameter_property bar1_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar1_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar1_size_mask_hwtcl integer 0
   set_parameter_property bar1_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar1_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar1_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar1_size_mask_hwtcl VISIBLE true
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
   set_parameter_property bar2_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar2_type_hwtcl GROUP $group_name
   set_parameter_property bar2_type_hwtcl VISIBLE true
   set_parameter_property bar2_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar2_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar2_size_mask_hwtcl integer 0
   set_parameter_property bar2_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar2_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar2_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar2_size_mask_hwtcl VISIBLE true
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
   set_parameter_property bar3_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar3_type_hwtcl GROUP $group_name
   set_parameter_property bar3_type_hwtcl VISIBLE true
   set_parameter_property bar3_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar3_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar3_size_mask_hwtcl integer 0
   set_parameter_property bar3_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar3_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar3_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar3_size_mask_hwtcl VISIBLE true
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
   set_parameter_property bar4_type_hwtcl ALLOWED_RANGES { "0:Disabled" "1:64-bit prefetchable memory" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar4_type_hwtcl GROUP $group_name
   set_parameter_property bar4_type_hwtcl VISIBLE true
   set_parameter_property bar4_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar4_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar4_size_mask_hwtcl integer 0
   set_parameter_property bar4_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar4_size_mask_hwtcl ALLOWED_RANGES { "0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits" "32: 4 GBytes - 32 bits" "33: 8 GBytes - 33 bits" "34: 16 GBytes - 34 bits" "35: 32 GBytes - 35 bits" "36: 64 GBytes - 36 bits" "37: 128 GBytes - 37 bits" "38: 256 GBytes - 38 bits" "39: 512 GBytes - 39 bits" "40: 1 TByte - 40 bits" "41: 2 TBytes - 41 bits" "42: 4 TBytes - 42 bits" "43: 8 TBytes - 43 bits" "44: 16 TBytes - 44 bits" "45: 32 TBytes - 45 bits" "46: 64 TBytes - 46 bits" "47: 128 TBytes - 47 bits" "48: 256 TBytes - 48 bits" "49: 512 TBytes - 49 bits" "50: 1 PByte - 50 bits" "51: 2 PBytes - 51 bits" "52: 4 PBytes - 52 bits" "53: 8 PBytes - 53 bits" "54: 16 PBytes - 54 bits" "55: 32 PBytes - 55 bits" "56: 64 PBytes - 56 bits" "57: 128 PBytes - 57 bits" "58: 256 PBytes - 58 bits" "59: 512 PBytes - 59 bits" "60: 1 EByte - 60 bits" "61: 2 EBytes - 61 bits" "62: 4 EBytes - 62 bits" "63: 8 EBytes - 63 bits"}
   set_parameter_property bar4_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar4_size_mask_hwtcl VISIBLE true
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
   set_parameter_property bar5_type_hwtcl ALLOWED_RANGES { "0:Disabled" "2:32-bit non-prefetchable memory" "3:32-bit prefetchable memory" "4:I/O address space" }
   set_parameter_property bar5_type_hwtcl GROUP $group_name
   set_parameter_property bar5_type_hwtcl VISIBLE true
   set_parameter_property bar5_type_hwtcl HDL_PARAMETER false
   set_parameter_property bar5_type_hwtcl DESCRIPTION "Sets the BAR type."

   add_parameter          bar5_size_mask_hwtcl integer 0
   set_parameter_property bar5_size_mask_hwtcl DISPLAY_NAME "Size"
   set_parameter_property bar5_size_mask_hwtcl ALLOWED_RANGES {"0:N/A" "4: 16 Bytes - 4 bits" "5: 32 Bytes - 5 bits" "6: 64 Bytes - 6 bits" "7: 128 Bytes - 7 bits" "8: 256 Bytes - 8 bits" "9: 512 Bytes - 9 bits" "10: 1 KByte - 10 bits" "11: 2 KBytes - 11 bits" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits" "25: 32 MBytes - 25 bits" "26: 64 MBytes - 26 bits" "27: 128 MBytes - 27 bits" "28: 256 MBytes - 28 bits" "29: 512 MBytes - 29 bits" "30: 1 GByte - 30 bits" "31: 2 GBytes - 31 bits"}
   set_parameter_property bar5_size_mask_hwtcl GROUP $group_name
   set_parameter_property bar5_size_mask_hwtcl VISIBLE true
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

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Expansion ROM"
   add_parameter          expansion_base_address_register_hwtcl integer 0
   set_parameter_property expansion_base_address_register_hwtcl DISPLAY_NAME "Size"
   set_parameter_property expansion_base_address_register_hwtcl ALLOWED_RANGES { "0:Disabled" "12: 4 KBytes - 12 bits" "13: 8 KBytes - 13 bits" "14: 16 KBytes - 14 bits" "15: 32 KBytes - 15 bits" "16: 64 KBytes - 16 bits" "17: 128 KBytes - 17 bits" "18: 256 KBytes - 18 bits" "19: 512 KBytes - 19 bits" "20: 1 MByte - 20 bits" "21: 2 MBytes - 21 bits" "22: 4 MBytes - 22 bits" "23: 8 MBytes - 23 bits" "24: 16 MBytes - 24 bits"}
   set_parameter_property expansion_base_address_register_hwtcl GROUP $group_name
   set_parameter_property expansion_base_address_register_hwtcl VISIBLE true
   set_parameter_property expansion_base_address_register_hwtcl HDL_PARAMETER true
   set_parameter_property expansion_base_address_register_hwtcl DESCRIPTION "Specifies an expansion ROM from 4 KBytes - 16 MBytes when enabled."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Base and Limit Registers for Root Port"

   add_parameter io_window_addr_width_hwtcl integer 0
   set_parameter_property io_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:16-bit I/O addressing" "2:32-bit I/O addressing "}
   set_parameter_property io_window_addr_width_hwtcl DISPLAY_NAME "Input/Output"
   set_parameter_property io_window_addr_width_hwtcl VISIBLE true
   set_parameter_property io_window_addr_width_hwtcl GROUP $group_name
   set_parameter_property io_window_addr_width_hwtcl HDL_PARAMETER true
   set_parameter_property io_window_addr_width_hwtcl DESCRIPTION "Specifies Input/Output base and limit register."

   add_parameter prefetchable_mem_window_addr_width_hwtcl integer 0
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl DISPLAY_NAME "Prefetchable memory"
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl ALLOWED_RANGES { "0:Disabled" "1:32-bit memory addressing" "2:64-bit memory addressing "}
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl VISIBLE true
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl HDL_PARAMETER true
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl GROUP $group_name
   set_parameter_property prefetchable_mem_window_addr_width_hwtcl DESCRIPTION "Specifies an expansion prefetchable memory base and limit register."

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
   set_parameter_property max_payload_size_hwtcl ALLOWED_RANGES { "128:128 Bytes" "256:256 Bytes" "512:512 Bytes" "1024:1024 Bytes" "2048:2048 Bytes"  }
   set_parameter_property max_payload_size_hwtcl GROUP $group_name
   set_parameter_property max_payload_size_hwtcl VISIBLE true
   set_parameter_property max_payload_size_hwtcl HDL_PARAMETER true
   set_parameter_property max_payload_size_hwtcl DESCRIPTION "Sets the read-only value of the max payload size of the Device Capabilities register and optimizes for this payload size."

   add_parameter          extend_tag_field_hwtcl string "32"
   set_parameter_property extend_tag_field_hwtcl DISPLAY_NAME "Number of tags supported"
   set_parameter_property extend_tag_field_hwtcl ALLOWED_RANGES { "32" "64" }
   set_parameter_property extend_tag_field_hwtcl GROUP $group_name
   set_parameter_property extend_tag_field_hwtcl VISIBLE true
   set_parameter_property extend_tag_field_hwtcl HDL_PARAMETER true
   set_parameter_property extend_tag_field_hwtcl DESCRIPTION "Sets the number of tags supported for non-posted requests transmitted by the application layer."


   add_parameter          completion_timeout_hwtcl string "ABCD"
   set_parameter_property completion_timeout_hwtcl DISPLAY_NAME "Completion timeout range"
   set_parameter_property completion_timeout_hwtcl ALLOWED_RANGES { "ABCD" "BCD" "ABC" "BC" "AB" "B" "A" "NONE"}
   set_parameter_property completion_timeout_hwtcl GROUP $group_name
   set_parameter_property completion_timeout_hwtcl VISIBLE true
   set_parameter_property completion_timeout_hwtcl HDL_PARAMETER true
   set_parameter_property completion_timeout_hwtcl DESCRIPTION "Sets the completion timeout range for root ports and endpoints that issue requests on their own behalf in PCI Express, version 2.0 or higher. As per the spec:<br> Range A: 50 s to 10 ms<br> Range B: 10ms to 250 ms<br> Range C: 250ms to 4s<br> Range D: 4s to 64s<br><br> For additional information, refer to the PCI Express User Guide."

   add_parameter enable_completion_timeout_disable_hwtcl integer 1
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_NAME "Implement completion timeout disable"
   set_parameter_property enable_completion_timeout_disable_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_completion_timeout_disable_hwtcl GROUP $group_name
   set_parameter_property enable_completion_timeout_disable_hwtcl VISIBLE true
   set_parameter_property enable_completion_timeout_disable_hwtcl HDL_PARAMETER true
   set_parameter_property enable_completion_timeout_disable_hwtcl DESCRIPTION "Turns the completion timeout mechanism On or Off for root ports in PCI Express, version 2.0 or higher. This option is forced to On for PCI Express version 2.0 and higher endpoints. It is forced Off for version 1.0a and 1.1 endpoints."

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
   set_parameter_property use_crc_forwarding_hwtcl VISIBLE true
   set_parameter_property use_crc_forwarding_hwtcl HDL_PARAMETER true
   set_parameter_property use_crc_forwarding_hwtcl DESCRIPTION "Enables or disables ECRC forwarding."

   add_parameter          track_rxfc_cplbuf_ovf_hwtcl integer 0
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DISPLAY_NAME "Track Receive Completion Buffer Overflow"
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DISPLAY_HINT boolean
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl GROUP $group_name
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl VISIBLE true
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl HDL_PARAMETER false
   set_parameter_property track_rxfc_cplbuf_ovf_hwtcl DESCRIPTION "Brings out a signal for tracking the Rx posted completion buffer overflow status"


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
   set_parameter_property dll_active_report_support_hwtcl VISIBLE true
   set_parameter_property dll_active_report_support_hwtcl HDL_PARAMETER true
   set_parameter_property dll_active_report_support_hwtcl DESCRIPTION "Enables or disables Data Link Layer (DLL)active reporting."

   add_parameter          surprise_down_error_support_hwtcl integer 0
   set_parameter_property surprise_down_error_support_hwtcl DISPLAY_NAME "Surprise down reporting"
   set_parameter_property surprise_down_error_support_hwtcl DISPLAY_HINT boolean
   set_parameter_property surprise_down_error_support_hwtcl GROUP $group_name
   set_parameter_property surprise_down_error_support_hwtcl VISIBLE true
   set_parameter_property surprise_down_error_support_hwtcl HDL_PARAMETER true
   set_parameter_property surprise_down_error_support_hwtcl DESCRIPTION "Enables or disables surprise down reporting."

   add_parameter          slotclkcfg_hwtcl integer 1
   set_parameter_property slotclkcfg_hwtcl DISPLAY_NAME "Slot clock configuration"
   set_parameter_property slotclkcfg_hwtcl DISPLAY_HINT boolean
   set_parameter_property slotclkcfg_hwtcl GROUP $group_name
   set_parameter_property slotclkcfg_hwtcl VISIBLE true
   set_parameter_property slotclkcfg_hwtcl HDL_PARAMETER true
   set_parameter_property slotclkcfg_hwtcl DESCRIPTION "Set the read-only value of the slot clock configuration bit in the link status register."

   # TODO Add Link COmmon Clock parameters

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "MSI"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          msi_multi_message_capable_hwtcl string        "4"
   set_parameter_property msi_multi_message_capable_hwtcl DISPLAY_NAME "Number of MSI messages requested"
   set_parameter_property msi_multi_message_capable_hwtcl ALLOWED_RANGES { "1" "2" "4" "8" "16" "32"}
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
   set group_name "Slot"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          enable_slot_register_hwtcl integer 0
   set_parameter_property enable_slot_register_hwtcl DISPLAY_NAME "Use slot register"
   set_parameter_property enable_slot_register_hwtcl DISPLAY_HINT boolean
   set_parameter_property enable_slot_register_hwtcl GROUP $group_name
   set_parameter_property enable_slot_register_hwtcl VISIBLE true
   set_parameter_property enable_slot_register_hwtcl HDL_PARAMETER true
   set_parameter_property enable_slot_register_hwtcl DESCRIPTION "Enables the slot register when Enabled. This register is required for root ports if a slot is implemented on the port. Slot status is recorded in the PCI Express Capabilities register."


   add_parameter          slot_power_scale_hwtcl integer 0
   set_parameter_property slot_power_scale_hwtcl DISPLAY_NAME "Slot power scale"
   set_parameter_property slot_power_scale_hwtcl ALLOWED_RANGES { 0:3 }
   set_parameter_property slot_power_scale_hwtcl GROUP $group_name
   set_parameter_property slot_power_scale_hwtcl VISIBLE true
   set_parameter_property slot_power_scale_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_scale_hwtcl DESCRIPTION "Sets the scale used for the Slot power limit value, as follows: 0=1.0<n>, 1=0.1<n>, 2=0.01<n>, 3=0.001<n>."

   add_parameter          slot_power_limit_hwtcl integer 0
   set_parameter_property slot_power_limit_hwtcl DISPLAY_NAME "Slot power limit"
   set_parameter_property slot_power_limit_hwtcl ALLOWED_RANGES { 0:255 }
   set_parameter_property slot_power_limit_hwtcl GROUP $group_name
   set_parameter_property slot_power_limit_hwtcl VISIBLE true
   set_parameter_property slot_power_limit_hwtcl HDL_PARAMETER true
   set_parameter_property slot_power_limit_hwtcl DESCRIPTION "Sets the upper limit (in Watts) of power supplied by the slot in conjunction with the slot power scale register. For more information, refer to the PCI Express Base Specification."

   add_parameter          slot_number_hwtcl integer 0
   set_parameter_property slot_number_hwtcl DISPLAY_NAME "Slot number"
   set_parameter_property slot_number_hwtcl ALLOWED_RANGES { 0:8191 }
   set_parameter_property slot_number_hwtcl GROUP $group_name
   set_parameter_property slot_number_hwtcl VISIBLE true
   set_parameter_property slot_number_hwtcl HDL_PARAMETER true
   set_parameter_property slot_number_hwtcl DESCRIPTION "Specifies the physical slot number associated with a port."

   #-----------------------------------------------------------------------------------------------------------------
   set group_name "Power Management"
   add_display_item ${master_group_name} ${group_name} group
   set_display_item_property ${group_name} display_hint tab

   add_parameter          endpoint_l0_latency_hwtcl integer 0
   set_parameter_property endpoint_l0_latency_hwtcl DISPLAY_NAME "Endpoint L0s acceptable latency"
   set_parameter_property endpoint_l0_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 64 ns" "1:Maximum of 128 ns" "2:Maximum of 256 ns" "3:Maximum of 512 ns" "4:Maximum of 1 us" "5:Maximum of 2 us" "6:Maximum of 4 us" "7:No limit" }
   set_parameter_property endpoint_l0_latency_hwtcl GROUP $group_name
   set_parameter_property endpoint_l0_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l0_latency_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l0_latency_hwtcl DESCRIPTION "Sets the read-only value of the endpoint L0s acceptable latency field of the Device Capabilities register. This value should be based on the latency that the application layer can tolerate. This setting is disabled for root ports."

   add_parameter          endpoint_l1_latency_hwtcl integer 0
   set_parameter_property endpoint_l1_latency_hwtcl DISPLAY_NAME "Endpoint L1 acceptable latency"
   set_parameter_property endpoint_l1_latency_hwtcl ALLOWED_RANGES { "0:Maximum of 1 us" "1:Maximum of 2 us" "2:Maximum of 4 us" "3:Maximum of 8 us" "4:Maximum of 16 us" "5:Maximum of 32 us" "6:Maximum of 64 us" "7:No limit" }
   set_parameter_property endpoint_l1_latency_hwtcl GROUP $group_name
   set_parameter_property endpoint_l1_latency_hwtcl VISIBLE true
   set_parameter_property endpoint_l1_latency_hwtcl HDL_PARAMETER true
   set_parameter_property endpoint_l1_latency_hwtcl DESCRIPTION "Sets the acceptable latency that an endpoint can withstand in the transition from the L1 to L0 state. It is an indirect measure of the endpoint internal buffering. This setting is disabled for root ports."


   add_parameter          vsec_id_hwtcl integer 40960
   set_parameter_property vsec_id_hwtcl DISPLAY_NAME "Vendor Specific Extended Capability (VSEC) ID "
   set_parameter_property vsec_id_hwtcl ALLOWED_RANGES { 0:65534 }
   set_parameter_property vsec_id_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property vsec_id_hwtcl GROUP $group_name
   set_parameter_property vsec_id_hwtcl VISIBLE false
   set_parameter_property vsec_id_hwtcl HDL_PARAMETER true
   set_parameter_property vsec_id_hwtcl DESCRIPTION "Sets the read-only value of the VSEC ID register."

   add_parameter          vsec_rev_hwtcl integer 0
   set_parameter_property vsec_rev_hwtcl DISPLAY_NAME "Vendor Specific Extended Capability (VSEC) Rev "
   set_parameter_property vsec_rev_hwtcl ALLOWED_RANGES { 0:15 }
   set_parameter_property vsec_rev_hwtcl DISPLAY_HINT hexadecimal
   set_parameter_property vsec_rev_hwtcl GROUP $group_name
   set_parameter_property vsec_rev_hwtcl VISIBLE false
   set_parameter_property vsec_rev_hwtcl HDL_PARAMETER true
   set_parameter_property vsec_rev_hwtcl DESCRIPTION "Sets the value of the VSEC Rev register."


}

proc add_pcie_hip_hidden_rtl_parameters {} {

   send_message debug "proc:add_pcie_hip_hidden_rtl_parameters"

   add_parameter          pld_clk_MHz integer 125
   set_parameter_property pld_clk_MHz VISIBLE false
   set_parameter_property pld_clk_MHz HDL_PARAMETER false
   set_parameter_property pld_clk_MHz DERIVED true

   add_parameter          millisecond_cycle_count_hwtcl integer 124250
   set_parameter_property millisecond_cycle_count_hwtcl VISIBLE false
   set_parameter_property millisecond_cycle_count_hwtcl HDL_PARAMETER true
   set_parameter_property millisecond_cycle_count_hwtcl DERIVED true

   # Internal parameter to force using direct value for credit in the command line and bypass UI
   #  default zero
   add_parameter          port_width_be_hwtcl integer 8
   set_parameter_property port_width_be_hwtcl VISIBLE false
   set_parameter_property port_width_be_hwtcl HDL_PARAMETER true
   set_parameter_property port_width_be_hwtcl DERIVED true

   add_parameter          port_width_data_hwtcl integer 64
   set_parameter_property port_width_data_hwtcl VISIBLE false
   set_parameter_property port_width_data_hwtcl DERIVED true
   set_parameter_property port_width_data_hwtcl HDL_PARAMETER true

   add_parameter          gen3_dcbal_en_hwtcl integer 1
   set_parameter_property gen3_dcbal_en_hwtcl VISIBLE false
   set_parameter_property gen3_dcbal_en_hwtcl DERIVED true
   set_parameter_property gen3_dcbal_en_hwtcl HDL_PARAMETER true

   add_parameter          enable_pipe32_sim_hwtcl integer 0
   set_parameter_property enable_pipe32_sim_hwtcl VISIBLE false
   set_parameter_property enable_pipe32_sim_hwtcl HDL_PARAMETER true

   add_parameter          enable_pipe32_phyip_ser_driver_hwtcl integer 0
   set_parameter_property enable_pipe32_phyip_ser_driver_hwtcl VISIBLE false
   set_parameter_property enable_pipe32_phyip_ser_driver_hwtcl HDL_PARAMETER false

   # Reserved debug pins

   add_parameter          fixed_preset_on integer 0
   set_parameter_property fixed_preset_on VISIBLE false
   set_parameter_property fixed_preset_on HDL_PARAMETER true

}

proc add_pcie_hip_parameters_phy_characteristics {} {
   send_message debug "proc:add_pcie_hip_parameters_phy_characteristics"

   set group_name "PHY Characteristics"

   add_parameter          change_deemphasis_hwtcl integer 0
   set_parameter_property change_deemphasis_hwtcl DISPLAY_NAME "Gen2 transmit deemphasis"
   set_parameter_property change_deemphasis_hwtcl ALLOWED_RANGES { "0:6dB" "1:3.5dB" }
   set_parameter_property change_deemphasis_hwtcl GROUP $group_name
   set_parameter_property change_deemphasis_hwtcl VISIBLE true
   set_parameter_property change_deemphasis_hwtcl HDL_PARAMETER false
   set_parameter_property change_deemphasis_hwtcl DESCRIPTION "Changes the deemphasis level on Gen2 Tx. Only applies to Gen2 variants."

   add_parameter          use_atx_pll_hwtcl integer 0
   set_parameter_property use_atx_pll_hwtcl DISPLAY_NAME "Use ATX PLL"
   set_parameter_property use_atx_pll_hwtcl DISPLAY_HINT boolean
   set_parameter_property use_atx_pll_hwtcl GROUP $group_name
   set_parameter_property use_atx_pll_hwtcl VISIBLE true
   set_parameter_property use_atx_pll_hwtcl HDL_PARAMETER true
   set_parameter_property use_atx_pll_hwtcl DESCRIPTION "When On, use ATX PLL instead of CMU PLL"

   add_parameter          low_latency_mode_hwtcl integer 0
   set_parameter_property low_latency_mode_hwtcl DISPLAY_NAME "Enable Common Clock Configuration (for lower latency)"
   set_parameter_property low_latency_mode_hwtcl DISPLAY_HINT boolean
   set_parameter_property low_latency_mode_hwtcl GROUP $group_name
   set_parameter_property low_latency_mode_hwtcl VISIBLE true
   set_parameter_property low_latency_mode_hwtcl HDL_PARAMETER true
   set_parameter_property low_latency_mode_hwtcl DESCRIPTION "This indicates that this component and the component at the opposite end of the Link are operating with a common clock source"
}

proc validation_parameter_system_setting {} {

   set ast_width_hwtcl                   [ get_parameter_value ast_width_hwtcl             ]
   set lane_mask_hwtcl                   [ get_parameter_value lane_mask_hwtcl             ]
   set gen123_lane_rate_mode_hwtcl       [ get_parameter_value gen123_lane_rate_mode_hwtcl ]
   set set_pld_clk_x1_625MHz_hwtcl       [ get_parameter_value set_pld_clk_x1_625MHz_hwtcl ]
   set pcie_spec_version_hwtcl           [ get_parameter_value pcie_spec_version_hwtcl     ]
   set multiple_packets_per_cycle_hwtcl  [ get_parameter_value multiple_packets_per_cycle_hwtcl  ]
   set use_config_bypass_hwtcl           [ get_parameter_value use_config_bypass_hwtcl ]
   set use_pci_ext_hwtcl                 [ get_parameter_value use_pci_ext_hwtcl ]
   set use_pcie_ext_hwtcl                [ get_parameter_value use_pcie_ext_hwtcl  ]
   set in_cvp_mode_hwtcl                 [ get_parameter_value in_cvp_mode_hwtcl ]
   set port_type_hwtcl                   [ get_parameter_value port_type_hwtcl ]
   set change_deemphasis_hwtcl           [ get_parameter_value change_deemphasis_hwtcl ]
   set pll_refclk_freq_hwtcl             [ get_parameter_value pll_refclk_freq_hwtcl ]
   set use_atx_pll                       [ get_parameter_value use_atx_pll_hwtcl     ]

   if {$change_deemphasis_hwtcl==1} {
      set_parameter_value deemphasis_enable_hwtcl "true"
   } else {
      set_parameter_value deemphasis_enable_hwtcl "false"
   }

   if {$in_cvp_mode_hwtcl == 1 } {
      if { [ regexp Root $port_type_hwtcl ] } {
         send_message error "CVP is not supported for Root port variants."
      } else {
         # multiple packets per cycle is only compatible with Gen3 x8
         if { [regexp Gen3 $gen123_lane_rate_mode_hwtcl] || [regexp Gen2 $gen123_lane_rate_mode_hwtcl]  } {
            send_message error "CVP is not supported for Gen2 or Gen3 lanes rate"
         } else {
            send_message info "CVP support for this design is enabled."
         }
      }
   }


   if {$use_config_bypass_hwtcl == 1 } {
      if { $use_pci_ext_hwtcl==1 || $use_pcie_ext_hwtcl==1 } {
         send_message error "Config. Bypass and CSEB cannot be enabled at the same time."
      } else {
         send_message info "The Config Bypass Support for this design is enabled. The settings for the BARs, Base and Limit Registers, Device Identification Registers would not have any effect. Settings for Link, MSI, MSI-X, Slot, Power Management will also be ignored.  "
      }
   }


   if { $multiple_packets_per_cycle_hwtcl ==1 } {
      # multiple packets per cycle is only compatible with Gen3 x8
      if { [regexp Gen3 $gen123_lane_rate_mode_hwtcl] && [ regexp x8 $lane_mask_hwtcl ] } {
         send_message info "The multiple packets per cycle support is enabled."
      } else {
         send_message error "The multiple packets per cycle support is only compatible with Gen3 x8"
      }
  }


   if { [ regexp  2.1 $pcie_spec_version_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
   # spec version 2.1 with lane rate of 8.0 Gbps
     send_message error "The PCIe spec version 2.1 can only support lane rates upto 5.0 Gbps"
   }

   if { $set_pld_clk_x1_625MHz_hwtcl == 1 } {
      if { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] && [ regexp $use_atx_pll 0 ] } {
         send_message debug "The application clock frequency (pld_clk) is 62.5 Mhz"
      } else {
         send_message error "62.5 Mhz application clock setting is only valid for Gen1 x1 with CMU PLL"
      }
   }

   if { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x1
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
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
   } elseif { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen2:x1
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x1 $lane_mask_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen3:x1
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen1:x2
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen2:x2
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x2 $lane_mask_hwtcl ] && [ regexp Gen3 $gen123_lane_rate_mode_hwtcl ]  } {
   # Gen3:x2
      if { [ regexp 256 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit or 128-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 128 $ast_width_hwtcl ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
      }
   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x4
      if { [ regexp 256 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 125 Mhz"
         set_parameter_value pld_clk_MHz 1250
         set_parameter_value millisecond_cycle_count_hwtcl 124250
      }
   } elseif { [ regexp x4 $lane_mask_hwtcl ] && [ regexp Gen2 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen2:x4
      if { [ regexp 256 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit or 128-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 128 $ast_width_hwtcl ] } {
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
      if { [ regexp 64 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 128-bit or 256-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 256 $ast_width_hwtcl ] } {
            send_message info "The application clock frequency (pld_clk) is 125 Mhz"
            set_parameter_value pld_clk_MHz 1250
            set_parameter_value millisecond_cycle_count_hwtcl 124250
         } else {
            send_message info "The application clock frequency (pld_clk) is 250 Mhz"
            set_parameter_value pld_clk_MHz 2500
            set_parameter_value millisecond_cycle_count_hwtcl 248500
         }
      }
   } elseif { [ regexp x8 $lane_mask_hwtcl ] && [ regexp Gen1 $gen123_lane_rate_mode_hwtcl ] } {
   # Gen1:x8
      if { [ regexp 256 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 64-bit or 128-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 128 $ast_width_hwtcl ] } {
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
      if { [ regexp 64 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 256-bit or 128-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         if { [ regexp 256 $ast_width_hwtcl ] } {
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
   # Gen3:x8
      if { [ regexp 64 $ast_width_hwtcl ] || [ regexp 128 $ast_width_hwtcl ] } {
         send_message error "The application interface must be set to Avalon-ST 256-bit when using $lane_mask_hwtcl $gen123_lane_rate_mode_hwtcl"
      } else {
         send_message info "The application clock frequency (pld_clk) is 250 Mhz"
         set_parameter_value pld_clk_MHz 2500
         set_parameter_value millisecond_cycle_count_hwtcl 248500
      }
   }


   # Setting AST Port width parameters
   set dataWidth        [ expr [ regexp 256 $ast_width_hwtcl  ] ? 256 : [ regexp 128 $ast_width_hwtcl ] ? 128 : 64 ]
   set dataByteWidth    [ expr [ regexp 256 $ast_width_hwtcl  ] ? 32  : [ regexp 128 $ast_width_hwtcl ] ? 16 : 8 ]
   set dataEmptyWidth   [ expr [ regexp 256 $ast_width_hwtcl  ] ? 2  : 1 ]

   set_parameter_value port_width_data_hwtcl      $dataWidth
   set_parameter_value port_width_be_hwtcl        $dataByteWidth

}

proc validation_parameter_bar {} {

   set port_type_hwtcl [ get_parameter_value port_type_hwtcl ]

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
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Disabled"
         }
         set_parameter_value "bar${i}_prefetchable_hwtcl" "Disabled"
         set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         if { $bar_size_mask_hwtcl($i)>0 && $bar_ignore_warning_size($i)==0 } {
            send_message error "The size of BAR$i must be set to N/A as BAR$i is disabled"
         }
      } elseif { $bar_type_hwtcl($i) == $PREFETACHBLE_64_BAR } {
         if { $i==0 || $i==2 || $i==4 } {
            set_parameter_value "bar${i}_64bit_mem_space_hwtcl" "Enabled"
            set_parameter_value "bar${i}_prefetchable_hwtcl" "Enabled"
            set_parameter_value "bar${i}_io_space_hwtcl" "Disabled"
         }
         if { $bar_size_mask_hwtcl($i)<7 } {
            send_message error "The size of the 64-bit prefetchable BAR$i must be greater than 7 bits"
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
            send_message error "The size of the 32-bit non-prefetchable BAR$i must be greater than 7 bits"
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
            send_message error "The size of the 32-bit prefetchable BAR$i must be greater than 7 bits"
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
   if { [ regexp endpoint $port_type_hwtcl ] } {
      # Slot register checking
      set enable_slot_register_hwtcl [get_parameter_value enable_slot_register_hwtcl]

      set_parameter_value no_command_completed_hwtcl "false"
      if { $enable_slot_register_hwtcl == 1 } {
         send_message error "The slot register parameter can only be enabled when using Root port and must be disabled when using Endpoint"
      }
      set dll_active_report_support_hwtcl   [get_parameter_value dll_active_report_support_hwtcl  ]
      if { $dll_active_report_support_hwtcl == 1 } {
         send_message error "The data link layer active reporting parameter can only be enabled when using Root port and must be disabled when using Endpoint"
      }
      set surprise_down_error_support_hwtcl [get_parameter_value surprise_down_error_support_hwtcl]
      if { $surprise_down_error_support_hwtcl == 1 } {
         send_message error "The surprise down reporting parameter can only be enabled when using Root port and must be disabled when using Endpoint"
      }
      set enable_completion_timeout_disable_hwtcl [get_parameter_value enable_completion_timeout_disable_hwtcl]
      if { $enable_completion_timeout_disable_hwtcl == 0 } {
         send_message error "The implement completion timeout disable parameter can only be disabled when using Root port and must be enabled when using Endpoint"
      }
      if { $enable_function_msix_support_hwtcl == 1 } {
         set msix_table_bir_hwtcl [get_parameter_value msix_table_bir_hwtcl]
         if  { $bar_size_mask_hwtcl($msix_table_bir_hwtcl) == 0 || $bar_type_hwtcl($msix_table_bir_hwtcl) == 0 } {
            send_message error "The table BAR indicator value is incorrect and must correspond to an enabled BAR"
         }
         set msix_pba_bir_hwtcl [get_parameter_value msix_pba_bir_hwtcl]
         if  { $bar_size_mask_hwtcl($msix_pba_bir_hwtcl) == 0 || $bar_type_hwtcl($msix_pba_bir_hwtcl) == 0 } {
            send_message error "The pending bit array BAR indicator value is incorrect and must correspond to an enabled BAR"
         }
      }
   } else {
      # Slot register checking
      set enable_slot_register_hwtcl [get_parameter_value enable_slot_register_hwtcl]

      if { $enable_slot_register_hwtcl == 1 } {
         set_parameter_value no_command_completed_hwtcl "true"
      } else {
         set_parameter_value no_command_completed_hwtcl "false"
      }

      if { $enable_function_msix_support_hwtcl == 1 } {
         send_message error "The implement MSI-X parameter can only be enabled when using Endpoint and must be disabled when using Root port"
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

proc add_pcie_hip_parameters_gen3_coef {} {
   send_message debug "proc:add_pcie_hip_parameters_gen3_coef"

   add_parameter          hwtcl_override_g3rxcoef integer 0
   set_parameter_property hwtcl_override_g3rxcoef VISIBLE false
   set_parameter_property hwtcl_override_g3rxcoef HDL_PARAMETER true

   #////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   #
   # Gen3 Equalization EP flow chart
   #                                                             |
   #                                                             |
   #                                                   Monitor LTSSM to check
   #                                                      G3 link training
   #                                                             |
   #                                                             |
   #                                                             |
   #                              TX (SV HIP)--------------------+-----------------------------------------RX (SV HIP)
   #                               |                                                                        |
   #                  -------------------------                                                     -------------------
   #                  |      TX SV (Phase 3)  |                                                     | RX SV (Phase 2) |
   #                  -------------------------                                                 ----------------------------
   #                  | RP send TS1 to SV HIP |                                                 | SV HIP EP send TS1 to RP |
   #                  | for SV TX XCVR setting|                                                 | for RP TX XCVR setting   |
   #                  | RP measures BER       |                                                 | SV HIP measure BER       |
   #                  -------------------------                                                 ----------------------------
   #                  | TS1:  Preset vs Coef  |                                                 | TS1:  Preset vs Coef     |
   #                  -------------------------                                                 ----------------------------
   #                              |                                                                          |
   #                              |                                                                          |
   #                   | --------------------|                                                               |
   #                   | Locally set FS value|                                                               |
   #                   | gen3_full_swing     |                                                               |
   #                   | parameter           |                                                               |
   #                   | --------------------|                                                               |
   #                              |                                                                          |
   #                              |                                                                          |
   #                              |                                                                          |
   #            -----------------TS1------------------                                     -----------------TS1------------------
   #            |                                    |                                     |                                    |
   #        ---------                            -------                               ---------                            -------
   #        |Preset |                            |Coeff|                               |Preset |                            |Coeff|
   #  --------------------                       -------                         ------------------------                ------------------------
   #  | HIP param          |                        |                            | HIP param             |               | HIP param             |
   #  | gen3_preset_coeff  |                        |                            | Sgen3_coeff_sel=preset|               | Sgen3_coeff_sel=coeff |
   #  --------------------                    ----------------------             -------------------------               ------------------------|
   #  | SV HIP receives    |                  | SV HIP receives     |            | SV HIP send TS1 to RP |               | SV HIP send TS1 to RP |
   #  | Preset and drive   |                  | Coef and drive      |            | Preset in the order   |               | Coef                  |
   #  | PMA currentcoef bus|                  | PMA currentcoef bus |            | defined in param      |               | But need to know      |
   #  | from the parameter |                  | Check legality      |            |                       |               | RP FS value           |
   #  -----------------------                 ----------------------             -----------------------                 -------------------------
   #  | RP measure BER     |                  | RP measure BER      |            | SV HIP measures       |               | SV HIP measures       |
   #  |                    |                  |                     |            | BER up to 10-6        |               | BER up to 10-6        |
   #  -----------------------                 ----------------------             -----------------------                 -------------------------
   #                                                                                        |                                    |
   #                                                                                        |                                    |
   #                                                                                        |                                    |
   #                                                                              -----------------------                 -----------------------
   #                                                                             | Turn on ADCE          |               | Turn on ADCE          |
   #                                                                             ------------------------                -------------------------
   #
   #//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   #
   set_coef_RX 1 7 "preset_1" 0 1 "g3_coeff_1_nxtber_more" 1 "g3_coeff_1_nxtber_less" 0 2
   set_coef_RX 2 0 "preset_2" 0 0 "g3_coeff_2_nxtber_more" 0 "g3_coeff_2_nxtber_less" 0 0
   for {set i 3} {$i < 25} {incr i 1} {
      set_coef_RX $i 0 "preset_${i}" 0 0 "g3_coeff_${i}_nxtber_more" 0 "g3_coeff_${i}_nxtber_less" 0 0
   }


   add_parameter          hwtcl_override_g3txcoef integer 0
   set_parameter_property hwtcl_override_g3txcoef VISIBLE false
   set_parameter_property hwtcl_override_g3txcoef HDL_PARAMETER true

   for {set i 1} {$i < 12} {incr i 1} {
      add_parameter          gen3_preset_coeff_${i}_hwtcl integer 0
      set_parameter_property gen3_preset_coeff_${i}_hwtcl VISIBLE false
      set_parameter_property gen3_preset_coeff_${i}_hwtcl HDL_PARAMETER true
   }
   add_parameter          gen3_low_freq_hwtcl integer 0
   set_parameter_property gen3_low_freq_hwtcl VISIBLE false
   set_parameter_property gen3_low_freq_hwtcl HDL_PARAMETER true

   add_parameter          full_swing_hwtcl  integer "35"
   set_parameter_property full_swing_hwtcl  DISPLAY_NAME "Full Swing"
   set_parameter_property full_swing_hwtcl  ALLOWED_RANGES {"20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "43" "44" "45" "46" "47" "48" "49" "50" "51" "52" "53" "54" "55" "56" "57" "58" "59" "60"  }
   set_parameter_property full_swing_hwtcl  VISIBLE false
   set_parameter_property full_swing_hwtcl  HDL_PARAMETER true
   set_parameter_property full_swing_hwtcl  DESCRIPTION "Selects the full swing value"

   add_parameter          gen3_full_swing_hwtcl  integer "35"
   set_parameter_property gen3_full_swing_hwtcl  VISIBLE false
   set_parameter_property gen3_full_swing_hwtcl  HDL_PARAMETER true
}




proc set_coef_RX { c coeff sel preset_hint nxtber_more_ptr nxtber_more nxtber_less_ptr nxtber_less reqber ber_meas} {
   # BEGIN RX SV PMA Gen3 Setting  - LTSSM EQUALIZATION PHASE 2 (EP) /////////////////////////////////////////////////////////////
   #
   # During EP PHASE 2, the SV HIP request RP transmitter different setting such as
   #    if gen3_coeff*_sel = "preset_*", negotiation use preset : For instance, HIP ask RP to set the RP XCVR TX to preset 7
   #    else gen3_coeff*_sel = "coeff_*", negotiation use coef : For instance, HIP ask RP to set the RP XCVR TX to preset 7
   #
   # ____________________________________________________________________________________________________________
   # |BER Measurement |ReqBER   | Nxt Coeff(1) | Nxt Coeff(2)| Master RX Preset Hint |Preset| Slave Coefficients  |
   # |Time            |         |If <= ReqBER  |If > ReqBER  |                       |      | /Preset             |
   # |[5:0]           |[4:0]    |[3:0]         |[3:0]        |  [2:0]                | [1]  |[17:0]               |
   # |0.5ms to 24 ms  |0-31     |0-15          |0-15         |                       |      |                     |
   # ____________________________________________________________________________________________________________
   #
   # 1) BER Measurement Time : How long to measure for BER with this coefficient.
   #                           This is in millisec ranges from 0.5ns to 24 ms.
   #                           Resolution is 0.5ms
   #                           when 0 exit link list
   # 2) Required BER         : This is the BER required, to be met with in the
   #                           BER Measurement Time
   # 3) Next Coefficient (1) : This points to the next coefficient when Measured
   #                           BER is less than or Equal to  Required BER
   #                           If Next Coeff is F This is the END
   # 4) Next Coefficient (2) : This points to the next coefficient when Measured
   #                           BER is greater than Required BER
   #                           If Next Coeff is F This is the END
   # 5) Master RX Preset Hint: RX Preset Hint for Master  applied along with the
   #                           coefficients.
   #                           3'h0 0dB
   #                           3'h1 4dB
   #                           3'h2 8dB
   #                           3'h3 12dB
   #                           3'h4 16db
   #                           3'h6 The CFG Space RX Preset Hint is used
   #                           3'h7 Start hard ADCE
   # 6) Preset               : This indicates the values provided in (7)  are Preset
   #                           values else it is Coefficients
   # 7) Slave Coefficients   : Coefficients/Presets that needs to be used by the
   #                           FAREND device
   #                           Coefficients[17:0] =>{Post cursor[5:0], cursor[5:0],Pre cursor[5:0]} OR
   #                           Coefficients[17:0] =>{Nxt Coeff(1)[4],Nxt Coeff(2)[4], reserved[15:4], Preset[3:0]}
   #
   #
   # Note: if BER Measurement Time  equals "0" this means EXIT, The best
   # coefficient found so far will be Reapplied
   #-----------------------------------------------------------------------------
   # **IMPORTANT: The SUM of the following should be Less than 32 MS
   # 1) Number of Coeff Checked * (500 ns + Rnd Trip Delay)
   # 2) Total BER time allowed for each coefficient
   # 3) (500 ns + Rnd Trip Delay) for the Best Coefficient to Be updated in Far End
   #-----------------------------------------------------------------------------

   add_parameter           gen3_coeff_${c}_hwtcl                 integer $coeff
   set_parameter_property  gen3_coeff_${c}_hwtcl                 VISIBLE false
   set_parameter_property  gen3_coeff_${c}_hwtcl                 HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_sel_hwtcl             string $sel
   set_parameter_property  gen3_coeff_${c}_sel_hwtcl             VISIBLE false
   set_parameter_property  gen3_coeff_${c}_sel_hwtcl             HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_preset_hint_hwtcl     integer $preset_hint
   set_parameter_property  gen3_coeff_${c}_preset_hint_hwtcl     VISIBLE false
   set_parameter_property  gen3_coeff_${c}_preset_hint_hwtcl     HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_nxtber_more_ptr_hwtcl integer $nxtber_more_ptr
   set_parameter_property  gen3_coeff_${c}_nxtber_more_ptr_hwtcl VISIBLE false
   set_parameter_property  gen3_coeff_${c}_nxtber_more_ptr_hwtcl HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_nxtber_more_hwtcl     string $nxtber_more
   set_parameter_property  gen3_coeff_${c}_nxtber_more_hwtcl     VISIBLE false
   set_parameter_property  gen3_coeff_${c}_nxtber_more_hwtcl     HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_nxtber_less_ptr_hwtcl integer $nxtber_less_ptr
   set_parameter_property  gen3_coeff_${c}_nxtber_less_ptr_hwtcl VISIBLE false
   set_parameter_property  gen3_coeff_${c}_nxtber_less_ptr_hwtcl HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_nxtber_less_hwtcl     string  $nxtber_less
   set_parameter_property  gen3_coeff_${c}_nxtber_less_hwtcl     VISIBLE false
   set_parameter_property  gen3_coeff_${c}_nxtber_less_hwtcl     HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_reqber_hwtcl          integer $reqber
   set_parameter_property  gen3_coeff_${c}_reqber_hwtcl          VISIBLE false
   set_parameter_property  gen3_coeff_${c}_reqber_hwtcl          HDL_PARAMETER true

   add_parameter           gen3_coeff_${c}_ber_meas_hwtcl        integer $ber_meas
   set_parameter_property  gen3_coeff_${c}_ber_meas_hwtcl        VISIBLE false
   set_parameter_property  gen3_coeff_${c}_ber_meas_hwtcl        HDL_PARAMETER true

}
