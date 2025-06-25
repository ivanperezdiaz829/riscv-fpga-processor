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


set LIST_NAME " "
set PCIE_HIP_PARAMETERS " "
set ALL_PCIE_HIP_PARAMETERS " "
set ALTGX_PARAMETERS " " 
set RESET_CONTROLLER_PARAMETERS " "
set PIPE_INTERFACE_PARAMETERS " "
set MAX_PREFETCH_MASTERS 6

proc add_parameter_and_store { name type value {description ""} } {
    global LIST_NAME
    global "${LIST_NAME}"

    lappend ${LIST_NAME} ${name}
    lappend ALL_PCIE_HIP_PARAMETERS ${name}
    add_parameter ${name} ${type} ${value} ${description}
}

proc add_pcie_hip_parameters {} {
    global LIST_NAME
    global PCIE_HIP_PARAMETERS
    global ALL_PCIE_HIP_PARAMETERS
    global MAX_PREFETCH_MASTERS

    set LIST_NAME PCIE_HIP_PARAMETERS

    # +------------------------------PAGE 1 ( System Settings )------------------------------------------------------
    add_parameter INTENDED_DEVICE_FAMILY String "Stratix IV"
    set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
    set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE
    
    add_parameter pcie_qsys integer 1
    set_parameter_property pcie_qsys VISIBLE false
    
    
    add_parameter_and_store p_pcie_hip_type string "0"      
    set_parameter_property "p_pcie_hip_type" DISPLAY_NAME "Device Family"
    set_parameter_property "p_pcie_hip_type" ALLOWED_RANGES {"1:Arria II GX" "2:Cyclone IV GX" "0:Stratix IV GX" "3:HardCopy IV GX" "4:Arria II GZ"  }
    set_parameter_property "p_pcie_hip_type" DESCRIPTION "The selected device family"
    
    # TODO: lane mask is calculated from max_link_width
    add_parameter lane_mask STD_LOGIC_VECTOR 0
    set_parameter_property lane_mask WIDTH 8
    set_parameter_property lane_mask DERIVED true
    set_parameter_property lane_mask VISIBLE false
    
    
    add_parameter_and_store my_gen2_lane_rate_mode boolean "false"
    set_parameter_property "my_gen2_lane_rate_mode" DISPLAY_NAME "Gen2 lane rate mode"
    set_parameter_property "my_gen2_lane_rate_mode" DESCRIPTION "Selects the maximum data rate of the link."
    
    add_parameter_and_store max_link_width integer 4		
    set_parameter_property "max_link_width" DISPLAY_NAME "Number of lanes"
    set_parameter_property "max_link_width" ALLOWED_RANGES {"1:x1" "2:x2" "4:x4" "8:x8"}
    set_parameter_property "max_link_width" DESCRIPTION "Selects the maximum number of lanes supported. The IP core supports 1, 2, 4, or 8 lanes. To specify 2 lanes, downtrain from 4 or 8 lanes."
    #set_parameter_property max_link_width GROUP "System Settings"
    
    #TODO:This is a ALTGX parameter
    add_parameter_and_store p_pcie_txrx_clock string "100 MHz"    
    set_parameter_property "p_pcie_txrx_clock" DISPLAY_NAME "Reference clock frequency"
    set_parameter_property "p_pcie_txrx_clock" ALLOWED_RANGES {"100 MHz" "125 MHz"}
    set_parameter_property "p_pcie_txrx_clock" DESCRIPTION "Set PCI Express system reference clock"
    #set_parameter_property p_pcie_txrx_clock GROUP "System Settings"
    
     add_parameter_and_store p_pcie_app_clk integer 0
    set_parameter_property "p_pcie_app_clk" DISPLAY_NAME "Use  62.5 MHz application clock"
    set_parameter_property "p_pcie_app_clk" DISPLAY_HINT boolean
    set_parameter_property "p_pcie_app_clk" DESCRIPTION "Only available in x1 configurations in Cyclone IV GX."

    
    add_parameter_and_store millisecond_cycle_count string "125000"  
    set_parameter_property millisecond_cycle_count VISIBLE false
    
   add_parameter          core_clk_freq integer 1250
   set_parameter_property core_clk_freq VISIBLE false
   set_parameter_property core_clk_freq HDL_PARAMETER false
   set_parameter_property core_clk_freq DERIVED true
    
    #TODO:Europa needs this
    add_parameter_and_store p_pcie_test_out_width string "9bits"	
    set_parameter_property "p_pcie_test_out_width" DISPLAY_NAME "Test out width"
    set_parameter_property "p_pcie_test_out_width" ALLOWED_RANGES {"None" "9bits" "64bits"}
   set_parameter_property "p_pcie_test_out_width" DESCRIPTION "Set the Test-out bus width of the PCI Express Hard IP"
    #set_parameter_property p_pcie_test_out_width GROUP "System Settings"
    
    
    #Used to be version 
    add_parameter_and_store enable_gen2_core string "false"  
    set_parameter_property enable_gen2_core VISIBLE false
    
    
    
    
    
    add_parameter_and_store gen2_lane_rate_mode string "false"
    set_parameter_property gen2_lane_rate_mode VISIBLE false
    
    
    #no_soft_reset not user visible
    add_parameter_and_store no_soft_reset string "false"
    set_parameter_property no_soft_reset VISIBLE false
    
    add_parameter_and_store p_pcie_version string "2.0"	
    set_parameter_property "p_pcie_version" DISPLAY_NAME "PCI Express version"
    set_parameter_property "p_pcie_version" ALLOWED_RANGES {"1.1" "2.0"}
    set_parameter_property "p_pcie_version" VISIBLE false
    set_parameter_property "p_pcie_version" DESCRIPTION "Selects the version of PCI Express Base Specification implemented."
    

    add_parameter_and_store core_clk_divider integer 2
    set_parameter_property core_clk_divider VISIBLE false
    
    add_parameter_and_store enable_ch0_pclk_out string "false"
    set_parameter_property enable_ch0_pclk_out VISIBLE false
    
    add_parameter_and_store core_clk_source string "false"
    set_parameter_property core_clk_source VISIBLE false
    
    
    foreach param $PCIE_HIP_PARAMETERS {
        set_parameter_property $param GROUP "System Settings"  
           set_parameter_property $param HDL_PARAMETER true
           lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    #p_pcie_version not HDL parameter
    set_parameter_property p_pcie_version HDL_PARAMETER false
    set_parameter_property my_gen2_lane_rate_mode HDL_PARAMETER false
    
    
    # +------------------------------PAGE 2 (PCI Registers)------------------------------------------------------
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store NUM_PREFETCH_MASTERS integer 1
    set_parameter_property "NUM_PREFETCH_MASTERS" DISPLAY_NAME "Number of BARs"
    set_parameter_property NUM_PREFETCH_MASTERS ALLOWED_RANGES "0:$MAX_PREFETCH_MASTERS"
    set_parameter_property NUM_PREFETCH_MASTERS AFFECTS_ELABORATION true
    set_parameter_property NUM_PREFETCH_MASTERS VISIBLE FALSE
    
     #By default, we have one 64 bit Bar
    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {

	add_parameter_and_store "CB_P2A_AVALON_ADDR_B${i}" integer "32'h00000000"
	set_parameter_property "CB_P2A_AVALON_ADDR_B${i}" "units" "Address"
	set_parameter_property  "CB_P2A_AVALON_ADDR_B${i}" VISIBLE FALSE

	add_parameter_and_store "bar${i}_size_mask" integer 0
	set_parameter_property  "bar${i}_size_mask" VISIBLE FALSE
	add_parameter_and_store "bar${i}_io_space" string "false"
	set_parameter_property  "bar${i}_io_space" VISIBLE FALSE
	if { $i == 0 || $i == 1} {
	add_parameter_and_store "bar${i}_64bit_mem_space" string "true"
	set_parameter_property  "bar${i}_64bit_mem_space" VISIBLE FALSE
	} else {
		add_parameter_and_store "bar${i}_64bit_mem_space" string "false"
		set_parameter_property  "bar${i}_64bit_mem_space" VISIBLE FALSE
	}
	
	if { $i == 0 } {
	add_parameter_and_store "bar${i}_prefetchable" string "true"
		set_parameter_property  "bar${i}_prefetchable" VISIBLE FALSE
	} else {
		add_parameter_and_store "bar${i}_prefetchable" string "false"
		set_parameter_property  "bar${i}_prefetchable" VISIBLE FALSE
    }
	
	
	
    }
   
    add_parameter_and_store "fixed_address_mode" string 0 
    set_parameter_property  "fixed_address_mode" VISIBLE FALSE
    
    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
    	add_parameter_and_store "CB_P2A_FIXED_AVALON_ADDR_B${i}" integer "32'h00000000"
	set_parameter_property  "CB_P2A_FIXED_AVALON_ADDR_B${i}" VISIBLE FALSE
    }
   
    add_parameter_and_store "BAR" string_list {0,1,2,3,4,5} 
    set_parameter_property BAR DISPLAY_HINT "width:50"
    set_parameter_property  BAR DISPLAY_HINT FIXED_SIZE 
    set_parameter_property  BAR DESCRIPTION "Base Address Register number."
    
    add_parameter_and_store "BAR Type" string_list {64 bit Prefetchable,Not used,Not used,Not used,Not used,Not used} "power of twos"
    set_parameter_property "BAR Type" ALLOWED_RANGES { "64 bit Prefetchable" "32 bit Non-Prefetchable" "Not used"}
    set_parameter_property "BAR Type" DISPLAY_HINT "width:135"
    set_parameter_property  "BAR Type" DESCRIPTION "Select the BAR width and types"
    
    add_parameter_and_store "BAR Size" integer_list {0,0,0,0,0,0}
    set_parameter_property "BAR Size" DISPLAY_HINT "width:135"
    set_parameter_property  "BAR Size" DESCRIPTION "Automatically calculated size of the BAR based on component connections and address assignments"
    
    
    add_parameter_and_store "Avalon Base Address" integer_list {0,0,0,0,0,0}
    set_parameter_property "Avalon Base Address" DISPLAY_HINT hexadecimal   
    set_parameter_property "Avalon Base Address" DESCRIPTION "Avalon-MM base address assigned to the BAR"
    #set_parameter_property "Avalon Base Address" DISPLAY_HINT "width:135"
  
   
    
    foreach param $PCIE_HIP_PARAMETERS {
                   set_parameter_property $param GROUP "PCI Base Address Registers (Type 0 Configuration Space)" 
                   set_parameter_property $param HDL_PARAMETER true
                   lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    add_display_item "PCI Base Address Registers \(Type 0 Configuration Space\)" "my group" GROUP TABLE
    add_display_item "my group" "BAR" PARAMETER
    add_display_item "my group" "BAR Type" PARAMETER
    add_display_item "my group" "BAR Size" PARAMETER
    add_display_item "my group" "Avalon Base Address" PARAMETER
    
    
    
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store vendor_id integer  4466
    set_parameter_property vendor_id DISPLAY_NAME "Vendor ID"
    set_parameter_property vendor_id ALLOWED_RANGES { 0:65534 }
    set_parameter_property "vendor_id" DISPLAY_HINT hexadecimal
    set_parameter_property "vendor_id" DESCRIPTION "Sets the read-only value of the Vendor ID register."
        
    add_parameter_and_store device_id integer 4
    set_parameter_property "device_id" DISPLAY_HINT hexadecimal
    set_parameter_property device_id DISPLAY_NAME "Device ID"
    set_parameter_property device_id DESCRIPTION "Sets the read-only value of the Device ID register."
     
    add_parameter_and_store revision_id integer 1
    set_parameter_property "revision_id" DISPLAY_HINT hexadecimal
    set_parameter_property revision_id DISPLAY_NAME "Revision ID"
    set_parameter_property revision_id DESCRIPTION "Sets the read-only value of the Revision ID register."
    
    add_parameter_and_store class_code integer 0
    set_parameter_property class_code ALLOWED_RANGES { 0:16777215 }
    set_parameter_property "class_code" DISPLAY_HINT hexadecimal
    set_parameter_property class_code DISPLAY_NAME "Class code"
    set_parameter_property class_code DESCRIPTION "Sets the read-only value of the Class code register."
    
    add_parameter_and_store subsystem_vendor_id integer 4466
    set_parameter_property subsystem_vendor_id ALLOWED_RANGES { 0:65534 }
    set_parameter_property "subsystem_vendor_id" DISPLAY_HINT hexadecimal
    set_parameter_property subsystem_vendor_id DISPLAY_NAME "Subsystem vendor ID"
    set_parameter_property subsystem_vendor_id DESCRIPTION "Sets the read-only value of the Subsystem Vendor ID register."
     
    add_parameter_and_store subsystem_device_id integer 4
    set_parameter_property "subsystem_device_id" DISPLAY_HINT hexadecimal
    set_parameter_property subsystem_device_id DISPLAY_NAME "Subsystem ID" 
    set_parameter_property subsystem_device_id DESCRIPTION "Sets the read-only value of the Subsystem Device ID register."
    
    foreach param $PCIE_HIP_PARAMETERS {
               set_parameter_property $param GROUP "Device Identification Registers" 
               set_parameter_property $param HDL_PARAMETER true
               lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    set_parameter_property NUM_PREFETCH_MASTERS HDL_PARAMETER false
    set_parameter_property BAR HDL_PARAMETER false
    set_parameter_property "BAR Type" HDL_PARAMETER false
    set_parameter_property "BAR Size" HDL_PARAMETER false
    set_parameter_property "Avalon Base Address" HDL_PARAMETER false
    
    for { set i 0 } { $i < $MAX_PREFETCH_MASTERS } { incr i } {
    	set_parameter_property  "CB_P2A_FIXED_AVALON_ADDR_B${i}" HDL_PARAMETER FALSE
    }
     set_parameter_property  "fixed_address_mode" HDL_PARAMETER FALSE
    
    
    # +------------------------------PAGE 3 (Capabilities)------------------------------------------------------
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store port_link_number integer 1
    set_parameter_property port_link_number DISPLAY_NAME "Link port number"
    set_parameter_property port_link_number DESCRIPTION "Sets the read-only value of the port number field in the Link Capabilities register."
    
    add_parameter_and_store msi_function_count integer 0
    set_parameter_property msi_function_count VISIBLE FALSE
    add_parameter_and_store enable_msi_64bit_addressing string  "true"
    set_parameter_property enable_msi_64bit_addressing VISIBLE FALSE
    
    add_parameter_and_store enable_function_msix_support string "false"
    set_parameter_property enable_function_msix_support VISIBLE FALSE
    add_parameter_and_store eie_before_nfts_count integer 4
    set_parameter_property eie_before_nfts_count VISIBLE FALSE
    add_parameter_and_store enable_completion_timeout_disable string "false"
    set_parameter_property enable_completion_timeout_disable VISIBLE FALSE
    add_parameter_and_store completion_timeout string "NONE"
    set_parameter_property completion_timeout VISIBLE FALSE
    add_parameter_and_store enable_adapter_half_rate_mode string "false"
    set_parameter_property enable_adapter_half_rate_mode VISIBLE FALSE
    add_parameter_and_store msix_pba_bir integer 0
    set_parameter_property msix_pba_bir VISIBLE FALSE
    add_parameter_and_store msix_pba_offset integer 0
    set_parameter_property msix_pba_offset VISIBLE FALSE
    add_parameter_and_store msix_table_bir integer 0
    set_parameter_property msix_table_bir VISIBLE FALSE
    add_parameter_and_store msix_table_offset integer 0
    set_parameter_property msix_table_offset VISIBLE FALSE
    add_parameter_and_store msix_table_size integer 0
    set_parameter_property msix_table_size VISIBLE FALSE
    add_parameter_and_store use_crc_forwarding string "false"
    set_parameter_property use_crc_forwarding VISIBLE FALSE
    add_parameter_and_store surprise_down_error_support string "false"
    set_parameter_property surprise_down_error_support VISIBLE FALSE
    add_parameter_and_store dll_active_report_support string "false"
    set_parameter_property dll_active_report_support VISIBLE FALSE
    add_parameter_and_store bar_io_window_size string "32BIT"
    set_parameter_property bar_io_window_size VISIBLE FALSE
    add_parameter_and_store bar_prefetchable integer 32
    set_parameter_property bar_prefetchable VISIBLE FALSE
    add_parameter_and_store hot_plug_support STD_LOGIC_VECTOR 7'b0000000
    set_parameter_property hot_plug_support WIDTH 7
    set_parameter_property hot_plug_support VISIBLE FALSE
    add_parameter_and_store no_command_completed string "true"
    set_parameter_property no_command_completed VISIBLE FALSE
    add_parameter_and_store slot_power_limit integer 0
    set_parameter_property slot_power_limit VISIBLE FALSE
    add_parameter_and_store slot_power_scale integer 0
    set_parameter_property slot_power_scale VISIBLE FALSE
    add_parameter_and_store slot_number integer 0
    set_parameter_property slot_number VISIBLE FALSE
    add_parameter_and_store enable_slot_register string "false"
    set_parameter_property enable_slot_register VISIBLE FALSE
    
    
     foreach param $PCIE_HIP_PARAMETERS {
                   set_parameter_property $param GROUP "Link Capabilities" 
                   set_parameter_property $param HDL_PARAMETER true
                   lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    # Link Common Clock
    
    
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store link_common_clock integer 1
    set_parameter_property link_common_clock DISPLAY_NAME "Link Common Clock"
    set_parameter_property link_common_clock DISPLAY_HINT boolean
    set_parameter_property link_common_clock DESCRIPTION "Sets the Link Slot Clock Register"
    
     foreach param $PCIE_HIP_PARAMETERS {
                   set_parameter_property $param GROUP "Link Capabilities" 
                   set_parameter_property $param HDL_PARAMETER false
                   lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    set PCIE_HIP_PARAMETERS " "
    ########### The three parameters below are type string but we want to represent them a scheckboxes on teh UI #############
    ##### The only way to accomplish this is to crate shadow parameters of boolen type and set these params during validation based on the
    ##### the values of the shadow booleans
    
    add_parameter_and_store advanced_errors string "false"
    set_parameter_property advanced_errors VISIBLE FALSE
    add_parameter_and_store enable_ecrc_check string "false"
    set_parameter_property enable_ecrc_check VISIBLE FALSE
    add_parameter_and_store enable_ecrc_gen string "false"
    set_parameter_property enable_ecrc_gen VISIBLE FALSE
    
    add_parameter_and_store my_advanced_errors boolean "false"
    set_parameter_property my_advanced_errors DISPLAY_NAME "Implement advance error reporting"
    set_parameter_property my_advanced_errors DESCRIPTION "Enables or disables AER."
    
    add_parameter_and_store my_enable_ecrc_check boolean "false"
    set_parameter_property my_enable_ecrc_check DISPLAY_NAME "Implement ECRC check"
    set_parameter_property my_enable_ecrc_check DESCRIPTION "Enables or disables ECRC checking. When enabled, AER must also be On."
    
    add_parameter_and_store my_enable_ecrc_gen boolean "false"
    set_parameter_property my_enable_ecrc_gen DISPLAY_NAME "Implement ECRC generation"
    set_parameter_property my_enable_ecrc_gen DESCRIPTION "Enables or disables ECRC generation."
    
    
     foreach param $PCIE_HIP_PARAMETERS {
                   set_parameter_property $param GROUP "Error Reporting" 
                   set_parameter_property $param HDL_PARAMETER true
                   lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    set_parameter_property my_advanced_errors HDL_PARAMETER false
    set_parameter_property my_enable_ecrc_check HDL_PARAMETER false
    set_parameter_property my_enable_ecrc_gen HDL_PARAMETER false
    # +------------------------------PAGE 4 (Buffer setup)------------------------------------------------------
    
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store max_payload_size integer 0
    set_parameter_property "max_payload_size" ALLOWED_RANGES {"0:128 Bytes" "1:256 Bytes"}
    set_parameter_property "max_payload_size" DISPLAY_NAME "Maximum payload size"
    set_parameter_property max_payload_size DESCRIPTION "Sets the read-only value of the max payload size of the Device Capabilities register and optimizes for this payload size."
    
    
    #user parameter
    add_parameter_and_store p_pcie_target_performance_preset string "Maximum"
    set_parameter_property "p_pcie_target_performance_preset" DISPLAY_NAME "RX buffer credit allocation - performance for received requests"
    set_parameter_property p_pcie_target_performance_preset ALLOWED_RANGES {"Maximum" "High" "Medium" "Low"}
    set_parameter_property p_pcie_target_performance_preset DESCRIPTION "Set the credits in the RX buffer for Posted, Non-Posted and Completion TLPs. The number of credits increases as the desired performance and maximum payload size increase."
    
    add_parameter_and_store retry_buffer_last_active_address integer 2047
    set_parameter_property retry_buffer_last_active_address VISIBLE false
    add_parameter_and_store credit_buffer_allocation_aux string  "ABSOLUTE"
    set_parameter_property "credit_buffer_allocation_aux" ALLOWED_RANGES {"ABSOLUTE" "BALANCED"}
    set_parameter_property credit_buffer_allocation_aux VISIBLE false
    
    add_parameter_and_store vc0_rx_flow_ctrl_posted_header integer 17
    set_parameter_property "vc0_rx_flow_ctrl_posted_header" DISPLAY_NAME "Posted header credit"
    set_parameter_property vc0_rx_flow_ctrl_posted_header DESCRIPTION "Credit Information."
    
    add_parameter_and_store vc0_rx_flow_ctrl_posted_data integer 91
    set_parameter_property "vc0_rx_flow_ctrl_posted_data" DISPLAY_NAME "Posted data credit"
    set_parameter_property vc0_rx_flow_ctrl_posted_data DESCRIPTION "Credit Information."
    
    add_parameter_and_store vc0_rx_flow_ctrl_nonposted_header integer 20
    set_parameter_property "vc0_rx_flow_ctrl_nonposted_header" DISPLAY_NAME "Non-posted header credit"
    set_parameter_property vc0_rx_flow_ctrl_nonposted_header DESCRIPTION "Credit Information."
    
    add_parameter_and_store vc0_rx_flow_ctrl_nonposted_data integer 0
    set_parameter_property vc0_rx_flow_ctrl_nonposted_data VISIBLE false
    set_parameter_property vc0_rx_flow_ctrl_nonposted_data DESCRIPTION "Credit Information."
    
    add_parameter_and_store vc0_rx_flow_ctrl_compl_header integer 0
    set_parameter_property "vc0_rx_flow_ctrl_compl_header" DISPLAY_NAME "Completion header credit"
    set_parameter_property vc0_rx_flow_ctrl_compl_header DESCRIPTION "Credit Information."
    
    add_parameter_and_store vc0_rx_flow_ctrl_compl_data integer 0
    set_parameter_property "vc0_rx_flow_ctrl_compl_data" DISPLAY_NAME "Completion data credit"
    set_parameter_property vc0_rx_flow_ctrl_compl_data DESCRIPTION "Credit Information."
    
    add_parameter_and_store RX_BUF integer 9
    set_parameter_property RX_BUF VISIBLE false
    add_parameter_and_store RH_NUM integer 7
    set_parameter_property RH_NUM VISIBLE false
    add_parameter_and_store G_TAG_NUM0 integer 32
    set_parameter_property G_TAG_NUM0 VISIBLE false
    
    
    foreach param $PCIE_HIP_PARAMETERS {
	       set_parameter_property $param GROUP "Buffer Configuration" 
	       set_parameter_property $param HDL_PARAMETER true
	       lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    #user parameter only
    set_parameter_property p_pcie_target_performance_preset HDL_PARAMETER false
    
    
    # +------------------------------PAGE 5 (Power Management)------------------------------------------------------
    
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store endpoint_l0_latency integer 0
    set_parameter_property endpoint_l0_latency VISIBLE false
    add_parameter_and_store endpoint_l1_latency integer 0
    set_parameter_property endpoint_l1_latency VISIBLE false
    add_parameter_and_store enable_l1_aspm string "false"
    set_parameter_property enable_l1_aspm VISIBLE false
    add_parameter_and_store l01_entry_latency integer 31
    set_parameter_property l01_entry_latency VISIBLE false
    
    add_parameter_and_store diffclock_nfts_count integer 255
    set_parameter_property diffclock_nfts_count VISIBLE false
    
    add_parameter_and_store sameclock_nfts_count integer 255
    set_parameter_property sameclock_nfts_count VISIBLE false
    add_parameter_and_store l1_exit_latency_sameclock integer 7
    set_parameter_property l1_exit_latency_sameclock VISIBLE false
    add_parameter_and_store l1_exit_latency_diffclock integer 7
    set_parameter_property l1_exit_latency_diffclock VISIBLE false
    add_parameter_and_store l0_exit_latency_sameclock integer 7
    set_parameter_property l0_exit_latency_sameclock VISIBLE false
    add_parameter_and_store l0_exit_latency_diffclock integer 7
    set_parameter_property l0_exit_latency_diffclock VISIBLE false
    
    add_parameter_and_store gen2_diffclock_nfts_count integer 255
    set_parameter_property gen2_diffclock_nfts_count VISIBLE false
    add_parameter_and_store gen2_sameclock_nfts_count integer 255
    set_parameter_property gen2_sameclock_nfts_count VISIBLE false
    
    foreach param $PCIE_HIP_PARAMETERS {
		   set_parameter_property $param GROUP " PCIe Bridge Mode" 
		   set_parameter_property $param HDL_PARAMETER true
		   lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    # +------------------------------PAGE 6 ( Avalon )-------------------------------------------------------------
    
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store CG_COMMON_CLOCK_MODE int 1 
    set_parameter_property  CG_COMMON_CLOCK_MODE VISIBLE false
   
     add_parameter_and_store CB_PCIE_MODE int 0
    set_parameter_property "CB_PCIE_MODE" DISPLAY_NAME "Peripheral mode"
    set_parameter_property "CB_PCIE_MODE" ALLOWED_RANGES {"0:Requester/Completer" "1:Completer-Only"}
    set_parameter_property "CB_PCIE_MODE" DESCRIPTION "Select the bridge operation mode for smaller area utilization where applicable."
    
    add_parameter_and_store AST_LITE int 0 
    set_parameter_property  AST_LITE VISIBLE false
    
    add_parameter_and_store CB_PCIE_RX_LITE int 0
    set_parameter_property CB_PCIE_RX_LITE DISPLAY_NAME "Single DW Completer"
    set_parameter_property CB_PCIE_RX_LITE DISPLAY_HINT boolean
    set_parameter_property CB_PCIE_RX_LITE VISIBLE true
    set_parameter_property CB_PCIE_RX_LITE HDL_PARAMETER true
    set_parameter_property CB_PCIE_RX_LITE DESCRIPTION "The core supports one DW read/write to reduce area and improve timming"
    

    add_parameter_and_store CG_RXM_IRQ_NUM int 16
    set_parameter_property  CG_RXM_IRQ_NUM VISIBLE false
    #set_parameter_property "CG_RXM_IRQ_NUM" DISPLAY_NAME "Number of Interrupt Inputs"
    #set_parameter_property "CG_RXM_IRQ_NUM" ALLOWED_RANGES {1:16}
    
    
    add_parameter_and_store CG_AVALON_S_ADDR_WIDTH int 20
    set_parameter_property  CG_AVALON_S_ADDR_WIDTH VISIBLE false
    add_parameter_and_store bypass_tl string "false"
    set_parameter_property  bypass_tl VISIBLE false
    
    
    add_parameter_and_store CG_IMPL_CRA_AV_SLAVE_PORT integer 1
    set_parameter_property "CG_IMPL_CRA_AV_SLAVE_PORT" DISPLAY_NAME "Control register access (CRA) Avalon slave port"
    set_parameter_property "CG_IMPL_CRA_AV_SLAVE_PORT" DISPLAY_HINT boolean
    set_parameter_property "CG_IMPL_CRA_AV_SLAVE_PORT" DESCRIPTION "Enable/Disable the Control Register Access port"
    
    add_parameter_and_store CG_NO_CPL_REORDERING integer 0
    set_parameter_property "CG_NO_CPL_REORDERING" DISPLAY_NAME "Disable Auto Reordering for Rx Completion TLP's"
    set_parameter_property "CG_NO_CPL_REORDERING" DISPLAY_HINT boolean
    set_parameter_property "CG_NO_CPL_REORDERING" DESCRIPTION "Disable Rx completion reordering for better latency and less memory utilization"
    
    
    add_parameter_and_store CG_ENABLE_A2P_INTERRUPT integer 0
    set_parameter_property "CG_ENABLE_A2P_INTERRUPT" DISPLAY_NAME " Auto-enable PCIe interrupt (enabled at power-on)"
    set_parameter_property "CG_ENABLE_A2P_INTERRUPT" DISPLAY_HINT boolean
    set_parameter_property "CG_ENABLE_A2P_INTERRUPT" DESCRIPTION "Enable/Disable the PCI Express interrupt enable register automatically at power-up"
    
    add_parameter_and_store p_user_msi_enable integer 0
    set_parameter_property "p_user_msi_enable" DISPLAY_NAME " Enable Exporting User MSI Interface"
    set_parameter_property "p_user_msi_enable" DISPLAY_HINT boolean
    set_parameter_property "p_user_msi_enable" DESCRIPTION "Enable/Disable Exporting PCI Express MSI Interrupt"
    
    add_parameter_and_store CG_IRQ_BIT_ENA integer 65535
    set_parameter_property CG_IRQ_BIT_ENA DISPLAY_NAME "PCIe interrupt enable register bits"
    set_parameter_property CG_IRQ_BIT_ENA ALLOWED_RANGES { 0:65535 }
    set_parameter_property CG_IRQ_BIT_ENA DISPLAY_HINT hexadecimal
    set_parameter_property CG_IRQ_BIT_ENA DESCRIPTION "Specify which PCI Express interrupt enable register bits to enable/disable automatically at power-up"
  
    foreach param $PCIE_HIP_PARAMETERS {
    	       set_parameter_property $param GROUP "Avalon-MM Settings" 
    	       set_parameter_property $param HDL_PARAMETER true
    	       lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    set PCIE_HIP_PARAMETERS " "
    
    add_parameter_and_store CB_A2P_ADDR_MAP_IS_FIXED int 1
    set_parameter_property "CB_A2P_ADDR_MAP_IS_FIXED" DISPLAY_NAME "Address translation table configuration"
    set_parameter_property "CB_A2P_ADDR_MAP_IS_FIXED" ALLOWED_RANGES {"0:Dynamic translation table" "1:Fixed translation table"}
    set_parameter_property "CB_A2P_ADDR_MAP_IS_FIXED" DESCRIPTION "Set the address translation mode. Dynamic translation requires software to setup the table. Fixed mode translation is hardwired at generation time."
    
    
    add_parameter_and_store CB_A2P_ADDR_MAP_NUM_ENTRIES int 1
    set_parameter_property "CB_A2P_ADDR_MAP_NUM_ENTRIES" DISPLAY_NAME "Number of address pages"
    set_parameter_property CB_A2P_ADDR_MAP_NUM_ENTRIES ALLOWED_RANGES {"1" "2" "4" "8" "16" "32" "64" "128" "256" "512"}
    set_parameter_property "CB_A2P_ADDR_MAP_NUM_ENTRIES" DESCRIPTION "Set the number of in-consecutive address ranges of the PCI Express system that can be accessed "
    
     
    add_parameter_and_store CB_A2P_ADDR_MAP_PASS_THRU_BITS int 20
    set_parameter_property "CB_A2P_ADDR_MAP_PASS_THRU_BITS" DISPLAY_NAME "Size of address pages"
    set_parameter_property CB_A2P_ADDR_MAP_PASS_THRU_BITS ALLOWED_RANGES {"12:4 KByte - 12 bits" "13:8 KByte - 13 bits" "14:16 KByte - 14 bits" "15:32 KBytes - 15 bits" "16:64 KBytes - 16 bits" "17:128 KBytes - 17 bits" "18:256 KBytes - 18 bits" "19:512 KBytes - 19 bits" "20:1 MByte - 20 bits" "21:2 MByte - 21 bits" "22:4 MByte - 22 bits" "23:8 MByte - 23 bits" "24:16 MByte - 24 bits" "25:32 MBytes - 25 bits" "26:64 MBytes - 26 bits" "27:128 MBytes - 27 bits" "28:256 MBytes - 28 bits" "29:512 MBytes - 29 bits" "30:1 GByte - 30 bits" "31:2 GByte - 31 bits" "32:4 GByte - 32 bits"}
    set_parameter_property "CB_A2P_ADDR_MAP_PASS_THRU_BITS" DESCRIPTION "Set the size of the PCI Express system pages. All pages must be the same size "
  
    
    foreach param $PCIE_HIP_PARAMETERS {
        	       set_parameter_property $param GROUP "Address Translation"
        	       set_parameter_property $param HDL_PARAMETER true
        	       lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    set PCIE_HIP_PARAMETERS " "
    
    ###Here are the CB_A2P_ADDR_MAP_FIXED_TABLE_i_HIGH and CB_A2P_ADDR_MAP_FIXED_TABLE_i_LOW parameters   
    for { set i 0 } { $i < 16 } { incr i } {
    
    	add_parameter_and_store "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" STD_LOGIC_VECTOR 0
    	set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" WIDTH 32
    	set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_HIGH" VISIBLE FALSE
    
    	add_parameter_and_store "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" STD_LOGIC_VECTOR 0
    	set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" WIDTH 32
    	set_parameter_property  "CB_A2P_ADDR_MAP_FIXED_TABLE_${i}_LOW" VISIBLE FALSE
    
     }
    
    
    add_parameter_and_store "Address Page" string_list {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15} 
    set_parameter_property "Address Page"  DISPLAY_HINT "width:50"
    set_parameter_property  "Address Page"  DISPLAY_HINT FIXED_SIZE 
    set_parameter_property "Address Page" DESCRIPTION "The address translation page number"
    
    add_parameter_and_store "PCIe Address 63:32" string_list {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
    set_parameter_property  "PCIe Address 63:32" DISPLAY_HINT "width:150"
    set_parameter_property  "PCIe Address 63:32" DISPLAY_HINT hexadecimal 
    set_parameter_property "PCIe Address 63:32" DESCRIPTION "Set the upper 32-bit of the address translation page"
    
    add_parameter_and_store "PCIe Address 31:0" string_list {0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000}
    set_parameter_property  "PCIe Address 31:0"  DISPLAY_HINT "width:150"
    set_parameter_property  "PCIe Address 31:0" DISPLAY_HINT hexadecimal 
     set_parameter_property "PCIe Address 31:0" DESCRIPTION "Set the lower 32-bit of the address translation page"
    
    
    
    add_parameter_and_store RXM_DATA_WIDTH int 64
    set_parameter_property  RXM_DATA_WIDTH VISIBLE false
    
    add_parameter_and_store RXM_BEN_WIDTH int 8
    set_parameter_property  RXM_BEN_WIDTH VISIBLE false

    
    foreach param $PCIE_HIP_PARAMETERS {
            	       set_parameter_property $param GROUP "Address Translation Table Contents (only valid for fixed configuration)"
	       set_parameter_property $param HDL_PARAMETER true
	       lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    
    add_display_item "Address Translation Table Contents (only valid for fixed configuration)" "the group" GROUP TABLE
    add_display_item "the group" "Address Page" PARAMETER
    add_display_item "the group" "PCIe Address 63:32" PARAMETER
    add_display_item "the group" "PCIe Address 31:0" PARAMETER
     
    set_parameter_property "Address Page" HDL_PARAMETER false
    set_parameter_property "PCIe Address 63:32" HDL_PARAMETER false
    set_parameter_property "PCIe Address 31:0" HDL_PARAMETER false
    
    add_parameter_and_store CB_TXS_ADDRESS_WIDTH int 7
    set_parameter_property  CB_TXS_ADDRESS_WIDTH VISIBLE false
    set_parameter_property "CB_TXS_ADDRESS_WIDTH" HDL_PARAMETER false
    
    # +------------------------- ( Misc )-------------------------------------------------------------
    set PCIE_HIP_PARAMETERS " "
    add_parameter_and_store TL_SELECTION  integer  1
    set_parameter_property TL_SELECTION VISIBLE false
    
    add_parameter_and_store pcie_mode string "SHARED_MODE"
    set_parameter_property pcie_mode VISIBLE false
    
    add_parameter_and_store single_rx_detect integer 4
    set_parameter_property single_rx_detect VISIBLE false
    
    add_parameter_and_store enable_coreclk_out_half_rate string "false"
    set_parameter_property enable_coreclk_out_half_rate VISIBLE false
    
    add_parameter_and_store low_priority_vc integer 0
    set_parameter_property low_priority_vc VISIBLE false
    
 
   foreach param $PCIE_HIP_PARAMETERS {
       set_parameter_property $param HDL_PARAMETER true
		  lappend ALL_PCIE_HIP_PARAMETERS ${param}
    }
    
    #Manual Parameter HDL Param Override
    set_parameter_property p_pcie_txrx_clock HDL_PARAMETER false
    set_parameter_property p_pcie_test_out_width HDL_PARAMETER false
    set_parameter_property p_pcie_app_clk HDL_PARAMETER false

    for {set i 0} { $i < 16 } { incr i } {
	#set_parameter_property "CB_A2P_ADDR_MAP_FIXED_TABLE_$i" HDL_PARAMETER false
    }

  
    set_parameter_property INTENDED_DEVICE_FAMILY HDL_PARAMETER true
    set_parameter_property lane_mask HDL_PARAMETER true
    set_parameter_property hot_plug_support HDL_PARAMETER true
    
}

proc add_altera_pcie_internal_altgx_parameters { display_item_name } {
    global LIST_NAME
    global ALTGX_PARAMETERS

    set LIST_NAME ALTGX_PARAMETERS

    add_parameter "deviceFamily" string "Stratix IV"
    set_parameter_property "deviceFamily" DISPLAY_NAME "Device family"
    set_parameter_property "deviceFamily" SYSTEM_INFO DEVICE_FAMILY
    set_parameter_property "deviceFamily" ALLOWED_RANGES {"Arria II GX" "Cyclone IV GX" "Stratix IV" "HardCopy IV" "Arria II GZ"}
    set_parameter_property "deviceFamily" HDL_PARAMETER false
    set_parameter_property "deviceFamily" AFFECTS_GENERATION true
    set_parameter_property "deviceFamily" ENABLED 0
    set_parameter_property "deviceFamily" VISIBLE false
    
    # add_parameter_and_store effective_data_rate string "2000 Mbps"
    # set_parameter_property effective_data_rate DEFAULT_VALUE "2000 Mbps"
    # set_parameter_property effective_data_rate DISPLAY_NAME "Effective Data Rate"
    # set_parameter_property effective_data_rate DISPLAY_HINT ""
    # set_parameter_property effective_data_rate AFFECTS_GENERATION true
    # set_parameter_property effective_data_rate AFFECTS_ELABORATION true
    # set_parameter_property effective_data_rate HDL_PARAMETER false
    # set_parameter_property effective_data_rate DESCRIPTION ""
    # set_parameter_property effective_data_rate VISIBLE false
    # 
    # add_display_item "General" number_of_channels parameter 
    # 
    # add_parameter_and_store intended_device_variant string "GX" 
    # set_parameter_property intended_device_variant DISPLAY_NAME "Device Variant"
    # set_parameter_property intended_device_variant ALLOWED_RANGES {"GX" "GT"}
    # set_parameter_property intended_device_variant GROUP "General"
    # 
    # add_parameter_and_store intended_device_speed_grade string "2" 
    # set_parameter_property intended_device_speed_grade DISPLAY_NAME "Speed Grade"
    # set_parameter_property intended_device_speed_grade ALLOWED_RANGES {"1" "2" "2x" "3" "4"}
    # set_parameter_property intended_device_speed_grade GROUP "General"
    # 
    # add_parameter_and_store wiz_protocol string "PCI Express (PIPE)" 
    # set_parameter_property wiz_protocol DISPLAY_NAME "Protocol"
    # set_parameter_property wiz_protocol ALLOWED_RANGES {"Basic" "Basic (PMA Direct)" "Deterministic # # # # Latency" "(OIF) CEI Phy Interface" "PCI Express (PIPE)" "SDI" "Serial RapidIO" "SONET/SDH" "XAUI"}
    # set_parameter_property wiz_protocol GROUP "General"
    # 
    add_parameter_and_store wiz_subprotocol string "Gen 1-x4" 
    set_parameter_property wiz_subprotocol DISPLAY_NAME "Subprotocol"
    set_parameter_property wiz_subprotocol ALLOWED_RANGES {"Gen 1-x1" "Gen 1-x2" "Gen 1-x4" "Gen 1-x8" "Gen 2-x1" "Gen 2-x2" "Gen 2-x4" "Gen 2-x8"}
    set_parameter_property wiz_subprotocol VISIBLE false
    
    # set_parameter_property wiz_subprotocol GROUP "General"
    # 
    # add_parameter_and_store WIZ_FORCE_DEFAULT_SETTINGS string "0"
    # set_parameter_property WIZ_FORCE_DEFAULT_SETTINGS DISPLAY_NAME "Enforce default settings for this # # # protocol"
    # set_parameter_property WIZ_FORCE_DEFAULT_SETTINGS ALLOWED_RANGES {"0" "1"}
    # set_parameter_property WIZ_FORCE_DEFAULT_SETTINGS GROUP "General"
    # 
    # add_parameter_and_store operation_mode string "duplex" 
    # set_parameter_property operation_mode DISPLAY_NAME "Operation Mode"
    # set_parameter_property operation_mode ALLOWED_RANGES {"duplex" "tx" "rx"}
    # set_parameter_property operation_mode GROUP "General"
    # set_parameter_property operation_mode VISIBLE false
    # 
    # add_parameter_and_store number_of_channels integer 4
    # set_parameter_property number_of_channels DISPLAY_NAME "Number of Channels"
    # set_parameter_property number_of_channels ALLOWED_RANGES  {1:32}
    # set_parameter_property number_of_channels GROUP "General"
    # 
    # # Affects RX_USE_ALIGN_STATE_MACHINE, RX_USE_DESERIALIZER_DOUBLE_DATA_MODE, RX_USE_DOUBLE_DATA_MODE,
    # # TX_USE_DOUBLE_DATA_MODE , TX_USE_SERIALIZER_DOUBLE_DATA_MODE , rx_word_aligner_num_byte 
    # add_parameter_and_store Wiz_block_width String "single"
    # set_parameter_property Wiz_block_width DISPLAY_NAME "Deserializer Block Width"
    # set_parameter_property Wiz_block_width ALLOWED_RANGES {"single" "double"}
    # set_parameter_property Wiz_block_width GROUP "General"
    # 
    # # Affects rx_align_pattern, rx_align_pattern_length, rx_channel_width, rx_dwidth_factor, # # # # # # # rx_use_double_data_mode, tx_channel_width, tx_dwidth_factor, tx_use_double_data_mode
    # add_parameter_and_store channel_width integer 16
    # set_parameter_property channel_width DISPLAY_NAME "Channel Width"
    # set_parameter_property channel_width ALLOWED_RANGES {8 10 16 20}
    # set_parameter_property channel_width GROUP "General"
    # 
    # add_parameter_and_store RX_USE_DOUBLE_DATA_MODE boolean true
    # set_parameter_property RX_USE_DOUBLE_DATA_MODE DISPLAY_NAME "RX_USE_DOUBLE_DATA_MODE"
    # set_parameter_property RX_USE_DOUBLE_DATA_MODE GROUP "General"
    # 
    # add_parameter_and_store TX_USE_DOUBLE_DATA_MODE boolean true
    # set_parameter_property TX_USE_DOUBLE_DATA_MODE DISPLAY_NAME "TX_USE_DOUBLE_DATA_MODE"
    # set_parameter_property TX_USE_DOUBLE_DATA_MODE GROUP "General"
    # 
    # add_parameter_and_store enable_lc_tx_pll BOOLEAN false
    # add_parameter_and_store equalizer_ctrl_a_setting integer 0 
    # add_parameter_and_store equalizer_ctrl_b_setting integer 0 
    # add_parameter_and_store equalizer_ctrl_c_setting integer 0 
    # add_parameter_and_store equalizer_ctrl_d_setting integer 0 
    # add_parameter_and_store equalizer_ctrl_v_setting integer 0 
    # add_parameter_and_store equalizer_dcgain_setting integer 0
    # add_parameter_and_store gen_reconfig_pll boolean false
    # add_parameter_and_store gx_channel_type string "auto" 
    # add_parameter_and_store gxb_analog_power string "AUTO" 
    # add_parameter_and_store gxb_powerdown_width integer 1 
    # add_parameter_and_store input_clock_frequency string "250.0 MHz" 
    # add_parameter_and_store loopback_mode string "none" 
    
    # add_parameter_and_store number_of_quads integer 1 
    # add_parameter_and_store operation_mode string "duplex" 
    # add_parameter_and_store pll_control_width integer 1 
    # add_parameter_and_store pll_pfd_fb_mode string "internal" 
    # add_parameter_and_store preemphasis_ctrl_1stposttap_setting integer 0 
    # add_parameter_and_store preemphasis_ctrl_2ndposttap_inv_setting boolean false
    # add_parameter_and_store preemphasis_ctrl_2ndposttap_setting integer 0 
    # add_parameter_and_store preemphasis_ctrl_pretap_inv_setting boolean false
    # add_parameter_and_store preemphasis_ctrl_pretap_setting integer 0
    # add_parameter_and_store protocol string "basic" 
    # add_parameter_and_store receiver_termination string "OCT_100_OHMS" 
    # add_parameter_and_store reconfig_calibration string "true" 
    # add_parameter_and_store reconfig_dprio_mode integer 0 
    # add_parameter_and_store reconfig_fromgxb_port_width integer 17 
    # add_parameter_and_store reconfig_togxb_port_width integer 4 
    # add_parameter_and_store rx_8b_10b_mode string "normal" 
    # add_parameter_and_store rx_align_loss_sync_error_num integer 1 
    # add_parameter_and_store rx_align_pattern string "0101111100" 
    # add_parameter_and_store rx_align_pattern_length integer 10
    # add_parameter_and_store rx_allow_align_polarity_inversion boolean false 
    # add_parameter_and_store rx_allow_pipe_polarity_inversion boolean false 
    # add_parameter_and_store rx_bitslip_enable boolean false 
    # add_parameter_and_store rx_byte_ordering_mode string "none" 
    # add_parameter_and_store rx_channel_width integer 16 
    # add_parameter_and_store rx_common_mode string "0.82v" 
    # add_parameter_and_store rx_cru_bandwidth_type string "auto" 
    # add_parameter_and_store rx_cru_inclock0_period integer 4000 
    # add_parameter_and_store rx_cru_m_divider integer 4 
    # add_parameter_and_store rx_cru_n_divider integer 1
    # add_parameter_and_store rx_cru_vco_post_scale_divider integer 4
    # add_parameter_and_store rx_data_rate integer 2000
    # add_parameter_and_store rx_data_rate_remainder integer 0
    # add_parameter_and_store rx_datapath_low_latency_mode boolean false
    # add_parameter_and_store rx_datapath_protocol string "basic"
    # add_parameter_and_store rx_digitalreset_port_width integer 1 
    # add_parameter_and_store rx_dwidth_factor integer 2 
    # add_parameter_and_store rx_enable_bit_reversal boolean false 
    # add_parameter_and_store rx_enable_deep_align_byte_swap boolean false 
    # add_parameter_and_store rx_enable_lock_to_data_sig boolean false 
    # add_parameter_and_store rx_enable_lock_to_refclk_sig boolean false 
    # add_parameter_and_store rx_enable_self_test_mode boolean false 
    # add_parameter_and_store rx_flip_rx_out boolean false 
    # add_parameter_and_store rx_force_signal_detect boolean true
    # add_parameter_and_store rx_num_align_cons_good_data integer 1
    # add_parameter_and_store rx_num_align_cons_pat integer 1
    # add_parameter_and_store rx_phfiforegmode boolean false
    # add_parameter_and_store rx_ppmselect integer 32
    # add_parameter_and_store rx_rate_match_fifo_mode string "none"
    # add_parameter_and_store rx_run_length integer 40
    # add_parameter_and_store rx_run_length_enable boolean true
    # add_parameter_and_store rx_signal_detect_loss_threshold integer 9
    # add_parameter_and_store rx_signal_detect_threshold integer 2
    # add_parameter_and_store rx_signal_detect_valid_threshold integer 14
    # add_parameter_and_store rx_use_align_state_machine boolean true
    # add_parameter_and_store rx_use_clkout boolean true
    # add_parameter_and_store rx_use_coreclk boolean false
    # add_parameter_and_store rx_use_cruclk boolean true
    # add_parameter_and_store rx_use_deserializer_double_data_mode boolean false
    # add_parameter_and_store rx_use_deskew_fifo boolean false
    # add_parameter_and_store rx_use_double_data_mode boolean true
    # add_parameter_and_store rx_use_external_termination boolean false
    # add_parameter_and_store rx_word_aligner_num_byte integer 1
    
#    add_parameter_and_store starting_channel_number integer 0
#    set_parameter_property starting_channel_number HDL_PARAMETER true
#    set_parameter_property starting_channel_number VISIBLE FALSE
    
    
    # add_parameter_and_store transmitter_termination string "OCT_100_OHMS"
    # add_parameter_and_store tx_8b_10b_mode string "normal"
    # add_parameter_and_store tx_allow_polarity_inversion boolean false
    # add_parameter_and_store tx_analog_power string "1.5v"
    # add_parameter_and_store tx_channel_width integer 16
    # add_parameter_and_store tx_clkout_width integer 1
    # add_parameter_and_store tx_common_mode string "0.65v"
    # add_parameter_and_store tx_data_rate integer 2000
    # add_parameter_and_store tx_data_rate_remainder integer 0
    # add_parameter_and_store tx_datapath_low_latency_mode boolean false
    # add_parameter_and_store tx_digitalreset_port_width integer 1
    # add_parameter_and_store tx_dwidth_factor integer 2
    # add_parameter_and_store tx_enable_bit_reversal boolean false
    # add_parameter_and_store tx_enable_self_test_mode boolean false
    # add_parameter_and_store tx_flip_tx_in boolean false
    # add_parameter_and_store tx_force_disparity_mode boolean false
    # add_parameter_and_store tx_pll_bandwidth_type string "auto"
    # add_parameter_and_store tx_pll_clock_post_divider integer 1
    # add_parameter_and_store tx_pll_inclk0_period integer 4000
    # add_parameter_and_store tx_pll_m_divider integer 4
    # add_parameter_and_store tx_pll_n_divider integer 1
    # add_parameter_and_store tx_pll_type string "CMU"
    # add_parameter_and_store tx_pll_vco_post_scale_divider integer 4
    # add_parameter_and_store tx_slew_rate string "off"
    # add_parameter_and_store tx_transmit_protocol string "basic"
    # add_parameter_and_store tx_use_coreclk boolean false
    # add_parameter_and_store tx_use_double_data_mode boolean true
    # add_parameter_and_store tx_use_external_termination boolean false
    # add_parameter_and_store tx_use_serializer_double_data_mode boolean false
    # add_parameter_and_store use_calibration_block boolean true
    # add_parameter_and_store vod_ctrl_setting integer 3

    foreach param $ALTGX_PARAMETERS {
	set_parameter_property $param GROUP $display_item_name
    }
}

proc add_altera_pcie_internal_reset_controller_parameters { display_item_name } {
    global LIST_NAME
    global RESET_CONTROLLER_PARAMETERS
    set LIST_NAME RESET_CONTROLLER_PARAMETERS

    # Duplicated from pcie_hip parameters
    # lane mask is derived from max_link_width
    add_parameter_and_store link_width integer 4
    set_parameter_property link_width HDL_PARAMETER true		
    set_parameter_property "link_width" ALLOWED_RANGES {1,2,4,8}
    set_parameter_property link_width VISIBLE false
    
    add_parameter_and_store cyclone4 integer 1
    set_parameter_property cyclone4 VISIBLE false
    set_parameter_property cyclone4 HDL_PARAMETER true
    
    add_parameter_and_store INTENDED_DEVICE_FAMILY string "Stratix IV"
    set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE false
    set_parameter_property INTENDED_DEVICE_FAMILY HDL_PARAMETER false
    
    

    add_parameter_and_store enable_gen2_core boolean "false"

    foreach param $RESET_CONTROLLER_PARAMETERS { 
	set_parameter_property $param GROUP $display_item_name
    }

}

proc add_altera_pcie_internal_pipe_interface_parameters { display_item_name } {
    global LIST_NAME
    global PIPE_INTERFACE_PARAMETERS

    set LIST_NAME PIPE_INTERFACE_PARAMETERS

    # Duplicated from pcie_hip parameters
    # lane mask is derived from max_link_width
    add_parameter_and_store link_width integer 4		
    set_parameter_property "link_width" ALLOWED_RANGES {1,2,4,8}

    add_parameter_and_store enable_gen2_core boolean "false"

    foreach param $PIPE_INTERFACE_PARAMETERS { 
	set_parameter_property $param GROUP $display_item_name
    }

    add_parameter_and_store max_link_width integer 1
    set_parameter_property max_link_width HDL_PARAMETER true
    
    add_parameter_and_store gen2_lane_rate_mode string "false"
    set_parameter_property gen2_lane_rate_mode HDL_PARAMETER true
    
    add_parameter_and_store p_pcie_hip_type string 0
    set_parameter_property p_pcie_hip_type HDL_PARAMETER true
}



proc add_altera_pcie_bfm_parameters { display_item_name } {
    global LIST_NAME
    global PCIE_BFM_PARAMETERS
    set LIST_NAME PCIE_BFM_PARAMETERS

    # Duplicated from pcie_hip parameters
    # lane mask is derived from max_link_width
    add_parameter_and_store link_width integer 4
    #set_parameter_property link_width HDL_PARAMETER true		
    set_parameter_property "link_width" ALLOWED_RANGES {1,2,4,8}
    set_parameter_property link_width VISIBLE false

    #add_parameter_and_store enable_gen2_core boolean "false"

    foreach param $PCIE_BFM_PARAMETERS { 
	set_parameter_property $param GROUP $display_item_name
    }

}
