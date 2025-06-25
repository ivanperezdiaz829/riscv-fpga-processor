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


#########################################
### request TCL package from ACDS
#########################################
package require -exact qsys 12.0
package require altera_tcl_testlib 1.0
package require -exact altera_terp 1.0
 
#######################################################################
# Source TCL file from PHY IP to determine the reconfig_* ports width
####################################################################### 
global env
set qdir $env(QUARTUS_ROOTDIR)
source $qdir/../ip/altera/altera_xcvr_generic/alt_xcvr_common.tcl 

####### Required for PHY IP tcl command #######
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_native_phy/av
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_native_phy/avgz
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_native_phy/sv
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_native_phy/cv
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require altera_xcvr_native_av::module;
package require altera_xcvr_native_sv::module;
package require altera_xcvr_native_avgz::module;
package require altera_xcvr_native_cv::module;
package require altera_xcvr_reset_control::module;
###########################################################

# Clarification required for PHY IP

##########################
# module altera_rapidio2
##########################
set_module_property NAME altera_rapidio2
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "RapidIO II MegaCore Function"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/RapidIO"
set_module_property DISPLAY_NAME "RapidIO II (IDLE2 up to 6.25 Gbaud)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property HIDE_FROM_SOPC true
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_rapidio2.pdf"

########################
# Declare the callbacks
########################
set_module_property VALIDATION_CALLBACK my_validation_callback   
set_module_property ELABORATION_CALLBACK my_elaboration_callback   
#################################################################
add_fileset synth2 quartus_synth synthproc
add_fileset sim_verilog sim_verilog verilogsimproc
add_fileset sim_vhdl sim_vhdl vhdlsimproc
set_fileset_property synth2 TOP_LEVEL altera_rapidio2_top
set_fileset_property sim_verilog TOP_LEVEL altera_rapidio2_top
set_fileset_property sim_vhdl TOP_LEVEL altera_rapidio2_top

#------------------------------------------------------------------------
# 1. GUI parameters
#------------------------------------------------------------------------

    ######################################################
    #         Physical Layer GUI Configurations
    ######################################################

    add_display_item "Altera RapidIO II Configuration" "Physical Layer" GROUP "tab"
    add_display_item "Physical Layer" "Device Options" GROUP

    add_parameter "DEVICE_FAMILY" string "Stratix V"
    set_parameter_property "DEVICE_FAMILY" HDL_PARAMETER true
    set_parameter_property "DEVICE_FAMILY" DISPLAY_NAME "Device family"
    set_parameter_property "DEVICE_FAMILY" ALLOWED_RANGES { "Stratix V" "Arria V" "Arria V GZ" "Cyclone V" }
    set_parameter_property "DEVICE_FAMILY" DESCRIPTION "Displays the device family"
    set_parameter_property "DEVICE_FAMILY" AFFECTS_GENERATION true
    set_parameter_property "DEVICE_FAMILY" ENABLED 0
    add_display_item "Device Options" "DEVICE_FAMILY" PARAMETER 
    set_parameter_property "DEVICE_FAMILY" SYSTEM_INFO {DEVICE_FAMILY}

    add_display_item "Physical Layer" "Mode Selection" GROUP

    add_parameter "SUPPORTED_MODES" string "4x,2x,1x"
    set_parameter_property "SUPPORTED_MODES" DISPLAY_NAME "Supported modes"
    set_parameter_property "SUPPORTED_MODES" ALLOWED_RANGES { "4x,2x,1x" "4x,1x" "2x,1x" "1x" }
    add_display_item "Mode Selection" "SUPPORTED_MODES" PARAMETER

    #Use SUPPORTED_MODES to derive SUPPORT_4X and SUPPORT_2X value. 
    add_parameter "SUPPORT_4X" boolean false
    set_parameter_property "SUPPORT_4X" HDL_PARAMETER true
    set_parameter_property "SUPPORT_4X" VISIBLE false 
    set_parameter_property "SUPPORT_4X" DERIVED true

    add_parameter "SUPPORT_2X" boolean false
    set_parameter_property "SUPPORT_2X" HDL_PARAMETER true
    set_parameter_property "SUPPORT_2X" VISIBLE false 
    set_parameter_property "SUPPORT_2X" DERIVED true

    add_parameter "SUPPORT_1X" boolean true
    set_parameter_property "SUPPORT_1X" VISIBLE false 
    set_parameter_property "SUPPORT_1X" DERIVED true


    add_parameter "LSIZE" integer 4
    set_parameter_property "LSIZE" VISIBLE false
    set_parameter_property "LSIZE" DERIVED true
 
    add_display_item "Physical Layer" "Data Settings" GROUP

    add_parameter "MAX_BAUD_RATE" integer 3125
    set_parameter_property "MAX_BAUD_RATE" HDL_PARAMETER true
    set_parameter_property "MAX_BAUD_RATE" DISPLAY_NAME "Maximum baud rate"
    set_parameter_property "MAX_BAUD_RATE" ALLOWED_RANGES { 1250 2500 3125 5000 6250 }
    set_parameter_property "MAX_BAUD_RATE" DISPLAY_UNITS "Mbaud"
    set_parameter_property "MAX_BAUD_RATE" DESCRIPTION "Specifies the RapidIO II maximum link baud rate in Mbaud"
    add_display_item "Data Settings" "MAX_BAUD_RATE" PARAMETER

    add_parameter "REF_CLK_FREQ" string "156.25"
    set_parameter_property "REF_CLK_FREQ" DISPLAY_NAME "Reference clock frequency"
    set_parameter_property "REF_CLK_FREQ" ALLOWED_RANGES { "62.5" "78.125" "125" "156.25" "250" "312.5" "500" "625" }
    #Note: removed PLL ref frequencies that are not common for all data rate: 50, 100, 195.3125, 200, 390.625, 400. 
    set_parameter_property "REF_CLK_FREQ" UNITS MegaHertz 
    set_parameter_property "REF_CLK_FREQ" DESCRIPTION "Specifies the reference clock frequency for the transceiver block in MHz"
    add_display_item "Data Settings" "REF_CLK_FREQ" PARAMETER 

    ######################################################
    #         Transport Layer GUI Configurations
    ######################################################

    add_display_item "Altera RapidIO II Configuration" "Transport Layer" GROUP "tab" 
    add_display_item "Transport Layer" "Transport Layer Configuration" GROUP

    add_parameter "ENABLE_TRANSPORT_LAYER" boolean true 
    set_parameter_property "ENABLE_TRANSPORT_LAYER" HDL_PARAMETER true 
    set_parameter_property "ENABLE_TRANSPORT_LAYER" DISPLAY_NAME "Enable Transport layer"
    set_parameter_property "ENABLE_TRANSPORT_LAYER" VISIBLE true 
    add_display_item "Transport Layer Configuration" "ENABLE_TRANSPORT_LAYER" PARAMETER
    # Transport Layer must be enabled and not configurable in ACDS 12.1. 
    set_parameter_property ENABLE_TRANSPORT_LAYER ENABLED 0

    add_parameter "TRANSPORT_LARGE" boolean false
    set_parameter_property "TRANSPORT_LARGE" HDL_PARAMETER true 
    set_parameter_property "TRANSPORT_LARGE" DISPLAY_NAME "Enable 16-bit device ID width"
    set_parameter_property "TRANSPORT_LARGE" DESCRIPTION "Specifies 8-bit or 16-bit device ID width"
    add_display_item "Transport Layer Configuration" "TRANSPORT_LARGE" PARAMETER 

    add_parameter "PASS_THROUGH" boolean true
    set_parameter_property "PASS_THROUGH" HDL_PARAMETER true 
    set_parameter_property "PASS_THROUGH" DISPLAY_NAME "Enable Avalon-ST pass-through interface"
    set_parameter_property "PASS_THROUGH" DESCRIPTION "Specifies that the IP core includes an Avalon-ST pass-through interface"
    add_display_item "Transport Layer Configuration" "PASS_THROUGH" PARAMETER 

    add_parameter "PROMISCUOUS" boolean false
    set_parameter_property "PROMISCUOUS" HDL_PARAMETER true 
    set_parameter_property "PROMISCUOUS" DISPLAY_NAME "Disable destination ID checking by default"
    set_parameter_property "PROMISCUOUS" DESCRIPTION "Specifies whether the IP core is initially enabled to process a request packet with a supported ftype but a destination ID not assigned to this endpoint"
    add_display_item "Transport Layer Configuration" "PROMISCUOUS" PARAMETER 
    
    ######################################################
    #     Logical Layer Configurations
    ######################################################

    #----------------------------------------------#
    #--------------- MAINTENANCE ------------------#
    #----------------------------------------------#
    add_display_item "Altera RapidIO II Configuration" "Logical Layer" GROUP "tab" 
       
    add_display_item "Logical Layer" "Maintenance Configuration" GROUP 

    add_parameter "MAINTENANCE_GUI" boolean true
    set_parameter_property "MAINTENANCE_GUI" DISPLAY_NAME "Enable Maintenance module"
    set_parameter_property "MAINTENANCE_GUI" DESCRIPTION "Enables Maintenance Logical Layer module"
    add_display_item "Maintenance Configuration" "MAINTENANCE_GUI" PARAMETER

    #Case:77381 number of mapping windows is fixed to 2 in this release.
    #add_parameter "MAINTENANCE_WINDOWS" integer 2
    #set_parameter_property "MAINTENANCE_WINDOWS" HDL_PARAMETER true 
    #set_parameter_property "MAINTENANCE_WINDOWS" DISPLAY_NAME "Number of transmit address translation windows"
    #set_parameter_property "MAINTENANCE_WINDOWS" DESCRIPTION "Specifies the number of transmit address translation windows available to the Maintenance Logical layer slave port"
    #set_parameter_property "MAINTENANCE_WINDOWS" ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
    #add_display_item "Maintenance Configuration" "MAINTENANCE_WINDOWS" PARAMETER 

    add_parameter "MAINTENANCE_ADDRESS_WIDTH" integer 26
    set_parameter_property "MAINTENANCE_ADDRESS_WIDTH" HDL_PARAMETER true 
    set_parameter_property "MAINTENANCE_ADDRESS_WIDTH" DISPLAY_NAME "Maintenance address bus width"
    set_parameter_property "MAINTENANCE_ADDRESS_WIDTH" DESCRIPTION "Specifies the number of bits in the Maintenance address bus."
    #set_parameter_property "MAINTENANCE_ADDRESS_WIDTH" ALLOWED_RANGES {26 27 28 29 30 31 32}
    #Fixed at 26-bit word addressing in this release because only two Maintenance windows in used. 
    set_parameter_property "MAINTENANCE_ADDRESS_WIDTH" ALLOWED_RANGES {26}
    add_display_item "Maintenance Configuration" "MAINTENANCE_ADDRESS_WIDTH" PARAMETER 

    add_parameter "PORT_WRITE_TX_GUI" boolean true
    set_parameter_property "PORT_WRITE_TX_GUI" DISPLAY_NAME "Port write Tx enable"
    set_parameter_property "PORT_WRITE_TX_GUI" DESCRIPTION "Enables the Maintenance Logical layer module to transmit port-write requests"
    add_display_item "Maintenance Configuration" "PORT_WRITE_TX_GUI" PARAMETER
 
    add_parameter "PORT_WRITE_RX_GUI" boolean true
    set_parameter_property "PORT_WRITE_RX_GUI" DISPLAY_NAME "Port write Rx enable"
    set_parameter_property "PORT_WRITE_RX_GUI" DESCRIPTION "Enables the Maintenance Logical layer module to receive port-write requests"
    add_display_item "Maintenance Configuration" "PORT_WRITE_RX_GUI" PARAMETER

    #----------------------------------------------#
    #----------------- DOORBELL -------------------#
    #----------------------------------------------#
    add_display_item "Logical Layer" "Doorbell Configuration" GROUP
   
    add_parameter "DOORBELL_GUI" boolean true
    #set_parameter_property "DOORBELL_GUI" HDL_PARAMETER true 
    set_parameter_property "DOORBELL_GUI" DISPLAY_NAME "Enable Doorbell support"
    set_parameter_property "DOORBELL_GUI" DESCRIPTION "Enables the RapidIO IP core to DOORBELL messages on the RapidIO link"
    add_display_item "Doorbell Configuration" "DOORBELL_GUI" PARAMETER

    add_parameter "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI" boolean false
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI" HDL_PARAMETER false 
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI" DISPLAY_NAME "Prevent doorbell messages from passing write transactions"
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI" DESCRIPTION "Enforces transaction order preservation between DOORBELL messages and I/O write request transactions"
    add_display_item "Doorbell Configuration" "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI" PARAMETER

    #----------------------------------------------#
    #----------------- IO MASTER ------------------#
    #----------------------------------------------#
    add_display_item "Logical Layer" "I/O Master Configuration" GROUP

    add_parameter "IO_MASTER_GUI" boolean true
    #set_parameter_property "IO_MASTER" HDL_PARAMETER true 
    set_parameter_property "IO_MASTER_GUI" DISPLAY_NAME "Enable I/O Logical layer Master module"
    set_parameter_property "IO_MASTER_GUI" DESCRIPTION "Enables the I/O Logical layer Master module"
    add_display_item "I/O Master Configuration" "IO_MASTER_GUI" PARAMETER

    add_parameter "IO_MASTER_WINDOWS" integer 1
    set_parameter_property "IO_MASTER_WINDOWS" HDL_PARAMETER true 
    set_parameter_property "IO_MASTER_WINDOWS" DISPLAY_NAME "Number of Rx address translation windows"
    set_parameter_property "IO_MASTER_WINDOWS" DESCRIPTION "Specifies the number of receive address translation windows available to the Avalon-MM Logical layer master port"
    set_parameter_property "IO_MASTER_WINDOWS" ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
    add_display_item "I/O Master Configuration" "IO_MASTER_WINDOWS" PARAMETER

    #----------------------------------------------#
    #----------------- IO SLAVE -------------------#
    #----------------------------------------------#
    add_display_item "Logical Layer" "I/O Slave Configuration" GROUP

    add_parameter "IO_SLAVE_GUI" boolean true
    set_parameter_property "IO_SLAVE_GUI" DISPLAY_NAME "Enable I/O Logical layer Slave module"
    set_parameter_property "IO_SLAVE_GUI" DESCRIPTION "Enables the I/O Logical layer Slave module"
    add_display_item "I/O Slave Configuration" "IO_SLAVE_GUI" PARAMETER

    add_parameter "IO_SLAVE_WINDOWS" integer 1
    set_parameter_property "IO_SLAVE_WINDOWS" HDL_PARAMETER true 
    set_parameter_property "IO_SLAVE_WINDOWS" DISPLAY_NAME "Number of Tx address translation windows"
    set_parameter_property "IO_SLAVE_WINDOWS" DESCRIPTION "Specifies the number of transmit address translation windows available to the Avalon-MM Logical layer slave port"
    set_parameter_property "IO_SLAVE_WINDOWS" ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
    add_display_item "I/O Slave Configuration" "IO_SLAVE_WINDOWS" PARAMETER 

    add_parameter "IO_SLAVE_ADDRESS_WIDTH" integer 32
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" HDL_PARAMETER true
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" VISIBLE true
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" DISPLAY_NAME "I/O Slave address bus width"
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" DESCRIPTION "Specifies the number of bits in the IO Slave Avalon-MM address bus. Legal range is 10 to 32-bit"
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" ALLOWED_RANGES {10:32}
    set_parameter_property "IO_SLAVE_ADDRESS_WIDTH" UNITS bits
    add_display_item "I/O Slave Configuration" "IO_SLAVE_ADDRESS_WIDTH" PARAMETER 

    #######################################################
    #          Capability Registers
    #######################################################
    add_display_item "Altera RapidIO II Configuration" "Capability Registers" GROUP "tab"
    add_display_item "Capability Registers" "Device Identity CAR" GROUP
    
    add_parameter "CAR_DEVICE_ID" integer 0x0000
    set_parameter_property "CAR_DEVICE_ID" DISPLAY_NAME "Device ID"
    set_parameter_property "CAR_DEVICE_ID" DESCRIPTION "Specifies the value in the DEVICE_ID field of the Device Identity register, which uniquely identifies the type of device from the vendor"
    set_parameter_property "CAR_DEVICE_ID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_DEVICE_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Device Identity CAR" "CAR_DEVICE_ID" PARAMETER

    add_parameter "CAR_DEVICE_VENDOR_ID" integer 0x0000
    set_parameter_property "CAR_DEVICE_VENDOR_ID" DISPLAY_NAME "Vendor ID"
    set_parameter_property "CAR_DEVICE_VENDOR_ID" DESCRIPTION "Specifies the value in the VENDOR_ID field of the Device Identity register; use this parameter to uniquely identify the vendor"
    set_parameter_property "CAR_DEVICE_VENDOR_ID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_DEVICE_VENDOR_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Device Identity CAR" "CAR_DEVICE_VENDOR_ID" PARAMETER

    add_display_item "Capability Registers" "Device Information CAR" GROUP

    add_parameter "CAR_DEVICE_REVISION_ID" long 0x00000000
    #Note: This is 32-bit register
    set_parameter_property "CAR_DEVICE_REVISION_ID" DISPLAY_NAME "Revision ID"
    set_parameter_property "CAR_DEVICE_REVISION_ID" DESCRIPTION "Specifies the value in the Device Identity CAR"
    set_parameter_property "CAR_DEVICE_REVISION_ID" ALLOWED_RANGES {0x00000000:0xFFFFFFFF}
    set_parameter_property "CAR_DEVICE_REVISION_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Device Information CAR" "CAR_DEVICE_REVISION_ID" PARAMETER

    add_display_item "Capability Registers" "Assembly Identity CAR" GROUP

    add_parameter "CAR_ASSEY_ID" integer 0x0000
    set_parameter_property "CAR_ASSEY_ID" DISPLAY_NAME "Assembly ID"
    set_parameter_property "CAR_ASSEY_ID" DESCRIPTION "Specifies the value in the Assembly ID field of the Assembly Identity CAR"
    set_parameter_property "CAR_ASSEY_ID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_ASSEY_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Assembly Identity CAR" "CAR_ASSEY_ID" PARAMETER

    add_parameter "CAR_ASSEY_VENDOR_ID" integer 0x0000
    set_parameter_property "CAR_ASSEY_VENDOR_ID" HDL_PARAMETER false
    set_parameter_property "CAR_ASSEY_VENDOR_ID" DISPLAY_NAME "Assembly Vendor ID"
    set_parameter_property "CAR_ASSEY_VENDOR_ID" DESCRIPTION "Specifies the value in the Assembly Vendor ID field of the Assembly Identity CAR"
    set_parameter_property "CAR_ASSEY_VENDOR_ID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_ASSEY_VENDOR_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Assembly Identity CAR" "CAR_ASSEY_VENDOR_ID" PARAMETER

    add_display_item "Capability Registers" "Assembly Information CAR" GROUP

    add_parameter "CAR_REVISION_ID" integer 0x0000
    set_parameter_property "CAR_REVISION_ID" DISPLAY_NAME "Revision ID"
    set_parameter_property "CAR_REVISION_ID" DESCRIPTION "Specifies the value in the Revision ID field of the Assembly Identity CAR"
    set_parameter_property "CAR_REVISION_ID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_REVISION_ID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Assembly Information CAR" "CAR_REVISION_ID" PARAMETER

    add_display_item "Capability Registers" "Processing Element Features CAR" GROUP

    add_parameter "CAR_BRIDGE" boolean false
    set_parameter_property "CAR_BRIDGE" DISPLAY_NAME "Bridge support"
    set_parameter_property "CAR_BRIDGE" DESCRIPTION "Specifies the value in the BRIDGE bit of the Processing Element Features CAR; indicates whether the RapidIO II IP core can bridge to another interface"
    add_display_item "Processing Element Features CAR" "CAR_BRIDGE" PARAMETER 

    add_parameter "CAR_MEMORY" boolean false
    set_parameter_property "CAR_MEMORY" DISPLAY_NAME "Memory access"
    set_parameter_property "CAR_MEMORY" DESCRIPTION "Specifies the value in the MEMORY bit of the Processing Element Features CAR; indicates whether the RapidIO II IP core connects locally (not through the RapidIO II link) to local address space"
    add_display_item "Processing Element Features CAR" "CAR_MEMORY" PARAMETER 

    add_parameter "CAR_PROCESSOR" boolean false
    set_parameter_property "CAR_PROCESSOR" DISPLAY_NAME "Processor present"
    set_parameter_property "CAR_PROCESSOR" DESCRIPTION "Specifies the value in the PROCESSOR bit of the Processing Element Features CAR; indicates whether the RapidIO II IP core connects locally (not through the RapidIO II link) to a processor"
    add_display_item "Processing Element Features CAR" "CAR_PROCESSOR" PARAMETER 

    add_parameter "CAR_FLOW_ARBITRATION" boolean false
    set_parameter_property "CAR_FLOW_ARBITRATION" DISPLAY_NAME "Enable flow arbitration support"
    set_parameter_property "CAR_FLOW_ARBITRATION" DESCRIPTION "Specifies the value of Flow Arbitration Support of the Processing Element Features CAR"
    add_display_item "Processing Element Features CAR" "CAR_FLOW_ARBITRATION" PARAMETER 

    add_parameter "CAR_STANDARD_ROUTE_TABLE" boolean false
    set_parameter_property "CAR_STANDARD_ROUTE_TABLE" DISPLAY_NAME "Enable standard route table configuration support"
    set_parameter_property "CAR_STANDARD_ROUTE_TABLE" DESCRIPTION "To enable Switch PE support of the standard route table configuration mechanism"
    add_display_item "Processing Element Features CAR" "CAR_STANDARD_ROUTE_TABLE" PARAMETER 

    add_parameter "CAR_EXTENDED_ROUTE_TABLE_GUI" boolean false
    set_parameter_property "CAR_EXTENDED_ROUTE_TABLE_GUI" DISPLAY_NAME "Enable extended route table configuration support"
    set_parameter_property "CAR_EXTENDED_ROUTE_TABLE_GUI" DESCRIPTION "To enable Switch PE support of the extended route table configuration mechanism, can only be set if standard route table configuration support is set"
    add_display_item "Processing Element Features CAR" "CAR_EXTENDED_ROUTE_TABLE_GUI" PARAMETER 

    add_parameter "CAR_FLOW_CONTROL" boolean false
    set_parameter_property "CAR_FLOW_CONTROL" DISPLAY_NAME "Enable flow control support"
    set_parameter_property "CAR_FLOW_CONTROL" DESCRIPTION "To enable support of flow control extensions"
    add_display_item "Processing Element Features CAR" "CAR_FLOW_CONTROL" PARAMETER 

    add_parameter "CAR_SWITCH" boolean false
    set_parameter_property "CAR_SWITCH" DISPLAY_NAME "Enable switch support"
    set_parameter_property "CAR_SWITCH" DESCRIPTION "Specifies the value in the SWITCH bit of the Processing Element Features CAR"
    add_display_item "Processing Element Features CAR" "CAR_SWITCH" PARAMETER 

    add_display_item "Capability Registers" "Switch Port Information CAR" GROUP

    add_parameter "CAR_NUM_OF_PORTS" integer 1
    set_parameter_property "CAR_NUM_OF_PORTS" DISPLAY_NAME "Number of ports"
    set_parameter_property "CAR_NUM_OF_PORTS" DESCRIPTION "Specifies number of ports of the Switch Port Information CAR"
    set_parameter_property "CAR_NUM_OF_PORTS" ALLOWED_RANGES {0:255}
    add_display_item "Switch Port Information CAR" "CAR_NUM_OF_PORTS" PARAMETER 

    add_parameter "CAR_PORT_NUM" integer 0x00
    set_parameter_property "CAR_PORT_NUM" DISPLAY_NAME "Port number"
    set_parameter_property "CAR_PORT_NUM" DESCRIPTION "Specifies the number of the port from which the Maintenance read operation accesses the Switch Port Information CAR; this value is stored in the PORT_NUMBER field of the Switch Port Information CAR"
    set_parameter_property "CAR_PORT_NUM" ALLOWED_RANGES {0x0000:0x00FF}
    set_parameter_property "CAR_PORT_NUM" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Switch Port Information CAR" "CAR_PORT_NUM" PARAMETER 

    add_display_item "Capability Registers" "Switch Route Table Destination ID Limit CAR" GROUP

    add_parameter "CAR_MAX_DESTID" integer 0x00FF
    set_parameter_property "CAR_MAX_DESTID" DISPLAY_NAME "Switch route table destination ID limit"
    set_parameter_property "CAR_MAX_DESTID" DESCRIPTION "Specifies the maximum configurable destination ID of Switch Route Table destination ID limit CAR"
    set_parameter_property "CAR_MAX_DESTID" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_MAX_DESTID" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Switch Route Table Destination ID Limit CAR" "CAR_MAX_DESTID" PARAMETER 

    add_display_item "Capability Registers" "Data Streaming Information CAR" GROUP

    add_parameter "CAR_MAX_PDU_SIZE" integer 0x0000
    set_parameter_property "CAR_MAX_PDU_SIZE" DISPLAY_NAME "Maximum PDU"
    set_parameter_property "CAR_MAX_PDU_SIZE" DESCRIPTION "Specifies the maximum PDU size in bytes supported by the destination end point"
    set_parameter_property "CAR_MAX_PDU_SIZE" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_MAX_PDU_SIZE" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Data Streaming Information CAR" "CAR_MAX_PDU_SIZE" PARAMETER 

    add_parameter "CAR_SEGMENTATION_CONTEXTS" integer 0x0000
    set_parameter_property "CAR_SEGMENTATION_CONTEXTS" DISPLAY_NAME "Number of segmentation contexts"
    set_parameter_property "CAR_SEGMENTATION_CONTEXTS" DESCRIPTION "Specifies the number of segmentation contexts supported by the destination end point"
    set_parameter_property "CAR_SEGMENTATION_CONTEXTS" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "CAR_SEGMENTATION_CONTEXTS" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Data Streaming Information CAR" "CAR_SEGMENTATION_CONTEXTS" PARAMETER 

    add_display_item "Capability Registers" "Source Operations CAR" GROUP

    add_parameter "CAR_SOURCE_OPERATIONS" long 0x00000000
    #Note: This is 32-bit register
    set_parameter_property "CAR_SOURCE_OPERATIONS" DISPLAY_NAME "Source operations CAR override"
    set_parameter_property "CAR_SOURCE_OPERATIONS" DESCRIPTION "Override the reset value of the Source Operations CAR by writing 1 to the particular bit field(s)"
    set_parameter_property "CAR_SOURCE_OPERATIONS" ALLOWED_RANGES {0x00000000:0xFFFFFFFF}
    set_parameter_property "CAR_SOURCE_OPERATIONS" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Source Operations CAR" "CAR_SOURCE_OPERATIONS" PARAMETER

    add_display_item "Capability Registers" "Destination Operations CAR" GROUP

    add_parameter "CAR_DESTINATION_OPERATIONS" long 0x00000000
    #Note: This is 32-bit register
    set_parameter_property "CAR_DESTINATION_OPERATIONS" DISPLAY_NAME "Destination operations CAR override"
    set_parameter_property "CAR_DESTINATION_OPERATIONS" DESCRIPTION "Override the reset value of the Destination Operations CAR by writing 1 to the particular bit field(s)"
    set_parameter_property "CAR_DESTINATION_OPERATIONS" ALLOWED_RANGES {0x00000000:0xFFFFFFFF}
    set_parameter_property "CAR_DESTINATION_OPERATIONS" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Destination Operations CAR" "CAR_DESTINATION_OPERATIONS" PARAMETER

    #######################################################
    #          Command and Status Registers
    #######################################################
    add_display_item "Altera RapidIO II Configuration" "Command and Status Registers" GROUP "tab"

    # Data Streaming Logical Layer Control CSR
    add_display_item "Command and Status Registers" "Data Streaming Logical Layer Control CSR" GROUP

    add_parameter "CSR_TM_TYPES_RESET_VALUE" integer 14
    set_parameter_property "CSR_TM_TYPES_RESET_VALUE" DISPLAY_NAME "Supported traffic management types reset value"
    set_parameter_property "CSR_TM_TYPES_RESET_VALUE" DESCRIPTION "Sets the reset value of the TM Types Supported field of the Data Streaming Control CSR. Description: Bit3:Basic Type supported, Bit2:Rate Type supported, Bit1:Credit Type supported, Bit0:Reserved"
    set_parameter_property "CSR_TM_TYPES_RESET_VALUE" ALLOWED_RANGES {"8: Basic type supported"  "12: Basic type, rate type supported"  "10: Basic type, credit type supported"  "14: Basic type, rate type, credit type supported"}
    add_display_item "Data Streaming Logical Layer Control CSR" "CSR_TM_TYPES_RESET_VALUE" PARAMETER 

    add_parameter "CSR_TM_MODE_RESET_VALUE" integer 0x1
    set_parameter_property "CSR_TM_MODE_RESET_VALUE" DISPLAY_NAME "Traffic management mode reset value"
    set_parameter_property "CSR_TM_MODE_RESET_VALUE" DESCRIPTION "Sets the reset value and current value of the TM Mode field of the Data Streaming Control CSR"
    set_parameter_property "CSR_TM_MODE_RESET_VALUE" ALLOWED_RANGES {0x0:0xF}
    set_parameter_property "CSR_TM_MODE_RESET_VALUE" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Data Streaming Logical Layer Control CSR" "CSR_TM_MODE_RESET_VALUE" PARAMETER 

    add_parameter "CSR_MTU_RESET_VALUE" integer 0x40
    set_parameter_property "CSR_MTU_RESET_VALUE" DISPLAY_NAME "Maximum transmission unit reset value"
    set_parameter_property "CSR_MTU_RESET_VALUE" DESCRIPTION "Sets the reset value and current value of the MTU field of the Data Streaming Control CSR"
    set_parameter_property "CSR_MTU_RESET_VALUE" ALLOWED_RANGES {0x00:0xFF}
    set_parameter_property "CSR_MTU_RESET_VALUE" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Data Streaming Logical Layer Control CSR" "CSR_MTU_RESET_VALUE" PARAMETER 

    # Port General Control CSR
    add_display_item "Command and Status Registers" "Port General Control CSR" GROUP

    add_parameter "HOST_RESET_VALUE" integer 1
    set_parameter_property "HOST_RESET_VALUE" DISPLAY_NAME "Host reset value"
    set_parameter_property "HOST_RESET_VALUE" DESCRIPTION "Specifies reset value of Host field of Port General Control CSR"
    set_parameter_property "HOST_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port General Control CSR" "HOST_RESET_VALUE" PARAMETER 

    add_parameter "MASTER_ENABLE_RESET_VALUE" integer 1
    set_parameter_property "MASTER_ENABLE_RESET_VALUE" DISPLAY_NAME "Master enable reset value"
    set_parameter_property "MASTER_ENABLE_RESET_VALUE" DESCRIPTION "Specifies reset value of Master Enable field of Port General Control CSR"
    set_parameter_property "MASTER_ENABLE_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port General Control CSR" "MASTER_ENABLE_RESET_VALUE" PARAMETER 

    add_parameter "DISCOVERED_RESET_VALUE" integer 1
    set_parameter_property "DISCOVERED_RESET_VALUE" DISPLAY_NAME "Discovered reset value"
    set_parameter_property "DISCOVERED_RESET_VALUE" DESCRIPTION "Specifies reset value of Discovered field of Port General Control CSR"
    set_parameter_property "DISCOVERED_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port General Control CSR" "DISCOVERED_RESET_VALUE" PARAMETER 

    # Port 0 Control CSRs
    add_display_item "Command and Status Registers" "Port 0 Control CSR" GROUP

    add_parameter "FLOW_CONTROL_PARTICIPANT_RESET_VALUE" integer 1
    set_parameter_property "FLOW_CONTROL_PARTICIPANT_RESET_VALUE" DISPLAY_NAME "Flow control participant reset value"
    set_parameter_property "FLOW_CONTROL_PARTICIPANT_RESET_VALUE" DESCRIPTION "Specifies reset value of flow control participant field of Port 0 Control CSR"
    set_parameter_property "FLOW_CONTROL_PARTICIPANT_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port 0 Control CSR" "FLOW_CONTROL_PARTICIPANT_RESET_VALUE" PARAMETER 

    add_parameter "ENUMERATION_BOUNDARY_RESET_VALUE" integer 1
    set_parameter_property "ENUMERATION_BOUNDARY_RESET_VALUE" DISPLAY_NAME "Enumeration boundary reset value"
    set_parameter_property "ENUMERATION_BOUNDARY_RESET_VALUE" DESCRIPTION "Specifies reset value of enumeration boundary field of Port 0 Control CSR"
    set_parameter_property "ENUMERATION_BOUNDARY_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port 0 Control CSR" "ENUMERATION_BOUNDARY_RESET_VALUE" PARAMETER 

    add_parameter "FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE" integer 1
    set_parameter_property "FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE" DISPLAY_NAME "Flow arbitration participant reset value"
    set_parameter_property "FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE" DESCRIPTION "Specifies reset value of flow arbitration participant field of Port 0 Control CSR"
    set_parameter_property "FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE" ALLOWED_RANGES {0 1}
    add_display_item "Port 0 Control CSR" "FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE" PARAMETER 

    # Lane n Status 0 CSRs
    add_display_item "Command and Status Registers" "Lane n Status 0 CSR" GROUP

    add_parameter "TRANSMITTER_TYPE_RESET_VALUE" integer 1
    set_parameter_property "TRANSMITTER_TYPE_RESET_VALUE" DISPLAY_NAME "Transmitter type reset value"
    set_parameter_property "TRANSMITTER_TYPE_RESET_VALUE" DESCRIPTION "Specifies reset value of transmitter type field of Lane n Status 0 CSR"
    set_parameter_property "TRANSMITTER_TYPE_RESET_VALUE" ALLOWED_RANGES {"0:Short run" "1:Long run"}
    add_display_item "Lane n Status 0 CSR" "TRANSMITTER_TYPE_RESET_VALUE" PARAMETER 

    add_parameter "RECEIVER_TYPE_RESET_VALUE" integer 2
    set_parameter_property "RECEIVER_TYPE_RESET_VALUE" DISPLAY_NAME "Receiver type reset value"
    set_parameter_property "RECEIVER_TYPE_RESET_VALUE" DESCRIPTION "Specifies reset value of receiver type field of Lane n Status 0 CSR"
    set_parameter_property "RECEIVER_TYPE_RESET_VALUE" ALLOWED_RANGES {"0:Short run" "1:Medium run" "2:Long run"}
    add_display_item "Lane n Status 0 CSR" "RECEIVER_TYPE_RESET_VALUE" PARAMETER 

    add_display_item "Command and Status Registers" "Extended features pointer CSR" GROUP

    add_parameter "EF_PTR_RESET_VALUE" integer 0x0000
    set_parameter_property "EF_PTR_RESET_VALUE" DISPLAY_NAME "Extended features pointer"
    set_parameter_property "EF_PTR_RESET_VALUE" DESCRIPTION "Address of the first Extended Feature Block implemented in user logic. Set to 0x0000 if none are present"
    set_parameter_property "EF_PTR_RESET_VALUE" ALLOWED_RANGES {0x0000:0xFFFF}
    set_parameter_property "EF_PTR_RESET_VALUE" DISPLAY_HINT "HEXADECIMAL"
    add_display_item "Extended features pointer CSR" "EF_PTR_RESET_VALUE" PARAMETER

    #######################################################
    #          Error Management Registers
    #######################################################
    add_display_item "Altera RapidIO II Configuration" "Error Management Registers" GROUP "tab"
    add_display_item "Error Management Registers" "Error Management Configuration" GROUP
    
    add_parameter "ERROR_MANAGEMENT_EXTENSION" boolean true
    set_parameter_property "ERROR_MANAGEMENT_EXTENSION" HDL_PARAMETER true
    set_parameter_property "ERROR_MANAGEMENT_EXTENSION" DISPLAY_NAME " Enable error management extension registers"
    set_parameter_property "ERROR_MANAGEMENT_EXTENSION" DESCRIPTION " Specifies whether the IP Core supports an Error Management Block or Not"
    add_display_item "Error Management Configuration" "ERROR_MANAGEMENT_EXTENSION" PARAMETER

    #######################################################
    #     Reset Controller MegaFunction instantiation
    #######################################################
    #NOTE: Not configurable in this release, Transceiver Reset Controller is NOT instantiated. 
    #In demo tb, altera_rapidio2_top_with_reset_ctrl.sv will be used to instantiate the altera_rapidio2_top and the Transceiver Reset Controller MegaFunction. So, the reset controller fileset will be added through this hw.tcl. 

    #add_display_item "Altera RapidIO II Configuration" "Transceiver Reset Controller" GROUP "tab"
    #add_display_item "Transceiver Reset Controller" "Transceiver Reset Controller Instantiation" GROUP
    add_parameter "XCVR_RESET_CTRL" boolean false
    set_parameter_property "XCVR_RESET_CTRL" VISIBLE false
    #set_parameter_property "XCVR_RESET_CTRL" DISPLAY_NAME "Instantiate Transceiver Reset Controller"
    #set_parameter_property "XCVR_RESET_CTRL" DESCRIPTION "Specifies whether to instantiate the Transceiver Reset Controller MegaFunction"
    #add_display_item "Transceiver Reset Controller Instantiation" "XCVR_RESET_CTRL" PARAMETER

    #######################################################
    #          HDL Parameters
    #######################################################
    add_parameter "SYS_CLK_FREQ" string "156.25"
    #SYS_CLK_FREQ is derived based on baud rate. 
    set_parameter_property "SYS_CLK_FREQ" VISIBLE false 
    set_parameter_property "SYS_CLK_FREQ" DERIVED true
    set_parameter_property "SYS_CLK_FREQ" HDL_PARAMETER true
    
    add_parameter "SYS_CLK_PERIOD" integer 6400
    #SYS_CLK_PERIOD is derived based on SYS_CLK_FREQ. 
    set_parameter_property "SYS_CLK_PERIOD" VISIBLE false 
    set_parameter_property "SYS_CLK_PERIOD" DERIVED true
    set_parameter_property "SYS_CLK_PERIOD" HDL_PARAMETER true

    add_parameter "REF_CLK_PERIOD" integer 6400
    #REF_CLK_PERIOD is derived based on REF_CLK_FREQ. 
    set_parameter_property "REF_CLK_PERIOD" VISIBLE false 
    set_parameter_property "REF_CLK_PERIOD" DERIVED true
    set_parameter_property "REF_CLK_PERIOD" HDL_PARAMETER true

    # IO_MASTER_ADDRESS_WIDTH HDL parameter derived from number of IO Master address mapping windows. 
    add_parameter "IO_MASTER_ADDRESS_WIDTH" integer 32
    set_parameter_property "IO_MASTER_ADDRESS_WIDTH" VISIBLE false 
    set_parameter_property "IO_MASTER_ADDRESS_WIDTH" HDL_PARAMETER true 
    set_parameter_property "IO_MASTER_ADDRESS_WIDTH" DERIVED true

    #Use MAINTENANCE parameter to derive HDL parameters, and passed to HDL top level
    add_parameter "MAINTENANCE" boolean false
    set_parameter_property "MAINTENANCE" VISIBLE false 
    set_parameter_property "MAINTENANCE" DERIVED true

    add_parameter "MAINTENANCE_MASTER" boolean false
    set_parameter_property "MAINTENANCE_MASTER" VISIBLE false 
    set_parameter_property "MAINTENANCE_MASTER" DERIVED true
    set_parameter_property "MAINTENANCE_MASTER" HDL_PARAMETER true

    add_parameter "MAINTENANCE_SLAVE" boolean false
    set_parameter_property "MAINTENANCE_SLAVE" VISIBLE false 
    set_parameter_property "MAINTENANCE_SLAVE" DERIVED true
    set_parameter_property "MAINTENANCE_SLAVE" HDL_PARAMETER true

    #Actual HDL parameters derived from GUI parameters, reset to FALSE if greyed out
    add_parameter "PORT_WRITE_TX" boolean false
    set_parameter_property "PORT_WRITE_TX" VISIBLE false 
    set_parameter_property "PORT_WRITE_TX" DERIVED true
    set_parameter_property "PORT_WRITE_TX" HDL_PARAMETER true

    add_parameter "PORT_WRITE_RX" boolean false
    set_parameter_property "PORT_WRITE_RX" VISIBLE false 
    set_parameter_property "PORT_WRITE_RX" DERIVED true
    set_parameter_property "PORT_WRITE_RX" HDL_PARAMETER true

    add_parameter "DOORBELL" boolean false
    set_parameter_property "DOORBELL" VISIBLE false 
    set_parameter_property "DOORBELL" DERIVED true
    set_parameter_property "DOORBELL" HDL_PARAMETER true

    add_parameter "DOORBELL_TX_ENABLE" boolean false
    set_parameter_property "DOORBELL_TX_ENABLE" VISIBLE false 
    set_parameter_property "DOORBELL_TX_ENABLE" DERIVED true
    set_parameter_property "DOORBELL_TX_ENABLE" HDL_PARAMETER true

    add_parameter "DOORBELL_RX_ENABLE" boolean false
    set_parameter_property "DOORBELL_RX_ENABLE" VISIBLE false 
    set_parameter_property "DOORBELL_RX_ENABLE" DERIVED true
    set_parameter_property "DOORBELL_RX_ENABLE" HDL_PARAMETER true

    add_parameter "IO_MASTER" boolean false
    set_parameter_property "IO_MASTER" VISIBLE false 
    set_parameter_property "IO_MASTER" DERIVED true
    set_parameter_property "IO_MASTER" HDL_PARAMETER true

    add_parameter "IO_SLAVE" boolean false
    set_parameter_property "IO_SLAVE" VISIBLE false 
    set_parameter_property "IO_SLAVE" DERIVED true
    set_parameter_property "IO_SLAVE" HDL_PARAMETER true

    add_parameter "CAR_EXTENDED_ROUTE_TABLE" boolean false
    set_parameter_property "CAR_EXTENDED_ROUTE_TABLE" VISIBLE false 
    set_parameter_property "CAR_EXTENDED_ROUTE_TABLE" DERIVED true
    set_parameter_property "CAR_EXTENDED_ROUTE_TABLE" HDL_PARAMETER false

    add_parameter "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" boolean false
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" VISIBLE false 
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" DERIVED true
    set_parameter_property "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" HDL_PARAMETER true

    #For Native PHY IP - derived from REF_CLK_FREQ and MAX_BAUD_RATE
    add_parameter "REF_CLK_FREQ_WITH_UNIT" string "156.25 MHz"
    set_parameter_property "REF_CLK_FREQ_WITH_UNIT" VISIBLE false 
    set_parameter_property "REF_CLK_FREQ_WITH_UNIT" DERIVED true
    set_parameter_property "REF_CLK_FREQ_WITH_UNIT" HDL_PARAMETER true

    add_parameter "MAX_BAUD_RATE_WITH_UNIT" string "6250 Mbps"
    set_parameter_property "MAX_BAUD_RATE_WITH_UNIT" VISIBLE false 
    set_parameter_property "MAX_BAUD_RATE_WITH_UNIT" DERIVED true
    set_parameter_property "MAX_BAUD_RATE_WITH_UNIT" HDL_PARAMETER true

##############################################################
##            Processing the Matched Parameters
##############################################################
proc param_matches {param value} {
    if {[string compare -nocase [get_parameter_value $param] $value] == 0} {
	return 1
    }
    return 0
}

proc param_is_true {param} {
    return [param_matches $param "true"]
}

proc param_is_false {param} {
    return [param_matches $param "false"]
}

proc param_enable {param} {
    set_parameter_property $param ENABLED 1
}

proc param_disable {param} {
    set_parameter_property $param ENABLED 0
}

proc check_freq {baud freq legal_freq} {
    foreach testfreq $legal_freq {
	if {[string compare $freq $testfreq] == 0 } {
	    return 
	}
    }
    send_message error  "Legal frequency at $baud Mbaud: $legal_freq MHz (current value is $freq MHz)"
}

proc log2 x {
    expr int(log($x) / log(2))
}

proc common_add_tagged_conduit { port_name port_dir width port_role } {
	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
    add_interface_port $port_name $port_name $port_role $port_dir $width 

	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}

#############################################################
#                  Validation Callback
#############################################################
proc my_validation_callback {} {
    #Supported baud rate for Cyclone V 
    if {[param_matches DEVICE_FAMILY "Cyclone V" ] } {
    set_parameter_property "MAX_BAUD_RATE" ALLOWED_RANGES { 1250 2500 3125 5000}
       if {[param_matches MAX_BAUD_RATE "5000"] } {
       send_message warning  "Baud Rate : Only Cyclone V GT devices support up to 5Gbaud, other Cyclone V devices support up to 3.125Gbaud"
       }
    }
    if {[param_is_true ENABLE_TRANSPORT_LAYER]} {
		param_enable "TRANSPORT_LARGE" 
		param_enable "PASS_THROUGH"
		param_enable "PROMISCUOUS"
                param_enable "MAINTENANCE_GUI"
                param_enable "DOORBELL_GUI"
                param_enable "IO_MASTER_GUI"
                param_enable "IO_SLAVE_GUI"
    } else {
		param_disable "TRANSPORT_LARGE" 
		param_disable "PASS_THROUGH"
		param_disable "PROMISCUOUS"
                param_disable "MAINTENANCE_GUI"
                param_disable "DOORBELL_GUI"
                param_disable "IO_MASTER_GUI"
                param_disable "IO_SLAVE_GUI"
    }

    set baud [get_parameter_value MAX_BAUD_RATE]
    set freq [get_parameter_value REF_CLK_FREQ]

    if { [expr $baud == 1250] } {
    	check_freq $baud $freq [list "62.5" "78.125" "125" "156.25" "250" "312.5" "500" "625"]
    } elseif { [expr $baud == 2500] } {
    	check_freq $baud $freq [list "50" "62.5" "78.125" "100" "125" "156.25" "200" "250" "312.5" "400" "500" "625"]
    } elseif { [expr $baud == 3125] } {
    	check_freq $baud $freq [list "62.5" "78.125" "125" "156.25" "195.3125" "250" "312.5" "390.625" "500" "625"]
    } elseif { [expr $baud == 5000] } {
    	check_freq $baud $freq [list "50" "62.5" "78.125" "100" "125" "156.25" "200" "250" "312.5" "400" "500" "625"]
    } elseif { [expr $baud == 6250] } {
    	check_freq $baud $freq [list "62.5" "78.125" "125" "156.25" "195.3125" "250" "312.5" "390.625" "500" "625"]
    #TODO: PHY IP uses rules and call tcl to set the legal clock freq. 
    }

    #Case:77381 number of address mapping windows and support for port-write tx and rx are fixed in this release. 
    param_disable "PORT_WRITE_TX_GUI"
    param_disable "PORT_WRITE_RX_GUI"

    if {[param_is_true MAINTENANCE_GUI] && [param_is_true ENABLE_TRANSPORT_LAYER]} {
       param_enable "MAINTENANCE_ADDRESS_WIDTH"
    } else {
       param_disable "MAINTENANCE_ADDRESS_WIDTH"
    }

    if {[param_is_true IO_SLAVE_GUI] && [param_is_true ENABLE_TRANSPORT_LAYER]} {
  	param_enable "IO_SLAVE_ADDRESS_WIDTH"
	param_enable "IO_SLAVE_WINDOWS"
	if {[param_is_true DOORBELL]} {
            param_enable "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI"
	} else {
	    param_disable "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI"	
	}
    } else {
        param_disable "IO_SLAVE_ADDRESS_WIDTH"
        param_disable "IO_SLAVE_WINDOWS"
        param_disable "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI"
    } 
 	
    if {[param_is_true IO_MASTER_GUI] && [param_is_true ENABLE_TRANSPORT_LAYER]} {
        param_enable "IO_MASTER_WINDOWS"
    } else {
	param_disable "IO_MASTER_WINDOWS"
    } 

    #Capability Registers
    if {[param_is_true CAR_SWITCH]} {
		param_enable "CAR_NUM_OF_PORTS" 
		param_enable "CAR_PORT_NUM"
    } else {
		param_disable "CAR_NUM_OF_PORTS" 
		param_disable "CAR_PORT_NUM"
    }

    if {[param_is_true CAR_STANDARD_ROUTE_TABLE]} {
		param_enable "CAR_EXTENDED_ROUTE_TABLE_GUI" 
    } else {
		param_disable "CAR_EXTENDED_ROUTE_TABLE_GUI" 
    }

}

#############################################################
#                  Elaboration Callback
#############################################################
proc my_elaboration_callback {} {


    #Derive IO Master address bus width from the number of IO Master address mapping window: 
    #34-bit for 0 windows, 32-bit for more than 0 windows. 
    if { [param_matches IO_MASTER_WINDOWS 0] } {
       set_parameter_value "IO_MASTER_ADDRESS_WIDTH" 34
    } else {
       set_parameter_value "IO_MASTER_ADDRESS_WIDTH" 32
    }

    #Derive the actual parameter value, resetting the parameter value to FALSE when greyed out
    if { [param_is_true DOORBELL_GUI ] && [param_is_true ENABLE_TRANSPORT_LAYER] } {
       set_parameter_value "DOORBELL" true
       set_parameter_value "DOORBELL_TX_ENABLE" true
       set_parameter_value "DOORBELL_RX_ENABLE" true
    } else {
       set_parameter_value "DOORBELL" false
       set_parameter_value "DOORBELL_TX_ENABLE" false
       set_parameter_value "DOORBELL_RX_ENABLE" false
    }

    if { [param_is_true IO_MASTER_GUI ] && [param_is_true ENABLE_TRANSPORT_LAYER] } {
       set_parameter_value "IO_MASTER" true
    } else {
       set_parameter_value "IO_MASTER" false
    }

    if { [param_is_true IO_SLAVE_GUI ] && [param_is_true ENABLE_TRANSPORT_LAYER] } {
       set_parameter_value "IO_SLAVE" true
    } else {
       set_parameter_value "IO_SLAVE" false
    }

    if { [param_is_true MAINTENANCE_GUI ] && [param_is_true ENABLE_TRANSPORT_LAYER] } {
       set_parameter_value "MAINTENANCE" true
       if {[param_is_true PORT_WRITE_TX_GUI]} {
           set_parameter_value "PORT_WRITE_TX" true
       }
       if {[param_is_true PORT_WRITE_RX_GUI]} {
           set_parameter_value "PORT_WRITE_RX" true
       }
    } else {
       set_parameter_value "MAINTENANCE" false
       set_parameter_value "PORT_WRITE_TX" false
       set_parameter_value "PORT_WRITE_RX" false
       # Send message on resetting parameter value when greyed out
       if {[param_is_true PORT_WRITE_TX_GUI]} {

           send_message info  "Transport and Maintenance: Port write Tx capability is turned off because the Maintenance Logical layer module has no slave port"
       }
       if {[param_is_true PORT_WRITE_RX_GUI]} {
           send_message info  "Transport and Maintenance: Port write Rx capability is turned off because the Maintenance Logical layer module has no slave port"
       }
    }

    # Send message on resetting parameter value when greyed out
    if { [param_is_false ENABLE_TRANSPORT_LAYER] } {
        send_message info  "Maintenance layer and Input/Output layer are disabled because Transport layer is disabled"
    }

    if { [param_is_false IO_SLAVE] || [param_is_false DOORBELL] } {
        set_parameter_value "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" false
    } elseif {[param_is_true IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI]} {
        set_parameter_value "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" true
    } else {
        set_parameter_value "IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION" false
    }

    if { [param_is_true IO_SLAVE] } {
        if {[param_is_false DOORBELL] && [param_is_true IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI]} {
            send_message info  "IO Slave and Doorbell: The Prevent doorbell messages from passing write transactions option is disabled because the Doorbell Tx capability is turned off"
        }
    } else {
        if {[param_is_true IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION_GUI]} {
            send_message info  "IO Slave and Doorbell: The Prevent doorbell messages from passing write transactions option is disabled because no I/O Logical layer Slave module is present"
        }
    }

    set_parameter_value "SUPPORT_1X" true
    if { [param_matches SUPPORTED_MODES "4x,2x,1x"] } {
       set_parameter_value "SUPPORT_4X" true
       set_parameter_value "SUPPORT_2X" true
       set_parameter_value LSIZE 4
    } elseif { [param_matches SUPPORTED_MODES "4x,1x"] } {
       set_parameter_value "SUPPORT_4X" true
       set_parameter_value "SUPPORT_2X" false
       set_parameter_value LSIZE 4
    } elseif { [param_matches SUPPORTED_MODES "2x,1x"] } {
       set_parameter_value "SUPPORT_4X" false
       set_parameter_value "SUPPORT_2X" true
       set_parameter_value LSIZE 2
    } else {
       set_parameter_value "SUPPORT_4X" false
       set_parameter_value "SUPPORT_2X" false
       set_parameter_value LSIZE 1
    }

    #Case:77126 Info messages on number of reconfig interfaces are needed for bonded_mode (theh default mode generated from RapidIO II GUI). 
    if { [param_is_true SUPPORT_4X ] } {
        send_message info  "Native PHY IP with 4 channels bonded mode (default) will require 5 reconfiguration interfaces for connection to the external reconfiguration controller"
        send_message info  "Reconfiguration interface offsets 0-3 are connected to the transceiver channels"
        send_message info  "Reconfiguration interface offset 4 is connected to the transmit PLL"
    } elseif { [param_is_true SUPPORT_2X ] } {
        send_message info  "Native PHY IP with 2 channels bonded mode (default) will require 3 reconfiguration interfaces for connection to the external reconfiguration controller"
        send_message info  "Reconfiguration interface offsets 0-1 are connected to the transceiver channels"
        send_message info  "Reconfiguration interface offset 2 is connected to the transmit PLL"
    } else {
        send_message info  "Native PHY IP with 1 channel (default) will require 2 reconfiguration interfaces for connection to the external reconfiguration controller"
        send_message info  "Reconfiguration interface offset 0 is connected to the transceiver channel"
        send_message info  "Reconfiguration interface offset 1 is connected to the transmit PLL"
    }

    ####################################
    # Derive parameter value for HDL
    ####################################
    if { [param_is_true MAINTENANCE ] } {
       set_parameter_value "MAINTENANCE_MASTER" true
       set_parameter_value "MAINTENANCE_SLAVE" true
    } else {
       set_parameter_value "MAINTENANCE_MASTER" false
       set_parameter_value "MAINTENANCE_SLAVE" false
    }

    #SYS_CLK_FREQ is MAX_BAUD_RATE/40 
    #SYS_CLK_PERIOD in ps. 
    if { [param_matches MAX_BAUD_RATE 1250] } {
       set_parameter_value "MAX_BAUD_RATE_WITH_UNIT" "1250 Mbps"
       set_parameter_value "SYS_CLK_FREQ" "31.25" 
       set_parameter_value "SYS_CLK_PERIOD" 32000
    } elseif { [param_matches MAX_BAUD_RATE 2500] } {
       set_parameter_value "MAX_BAUD_RATE_WITH_UNIT" "2500 Mbps"
       set_parameter_value "SYS_CLK_FREQ" "62.5" 
       set_parameter_value "SYS_CLK_PERIOD" 16000
    } elseif { [param_matches MAX_BAUD_RATE 3125] } { 
       set_parameter_value "MAX_BAUD_RATE_WITH_UNIT" "3125 Mbps"
       set_parameter_value "SYS_CLK_FREQ" "78.125" 
       set_parameter_value "SYS_CLK_PERIOD" 12800
    } elseif { [param_matches MAX_BAUD_RATE 5000] } { 
       set_parameter_value "MAX_BAUD_RATE_WITH_UNIT" "5000 Mbps"
       set_parameter_value "SYS_CLK_FREQ" "125" 
       set_parameter_value "SYS_CLK_PERIOD" 8000
    } elseif { [param_matches MAX_BAUD_RATE 6250] } { 
       set_parameter_value "MAX_BAUD_RATE_WITH_UNIT" "6250 Mbps"
       set_parameter_value "SYS_CLK_FREQ" "156.25" 
       set_parameter_value "SYS_CLK_PERIOD" 6400
    }

    #REF_CLK_PERIOD in ps. 
    if { [param_matches REF_CLK_FREQ "50"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "50 MHz"
       set_parameter_value "REF_CLK_PERIOD" 20000 
    } elseif { [param_matches REF_CLK_FREQ "62.5"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "62.5 MHz"
       set_parameter_value "REF_CLK_PERIOD" 16000 
    } elseif { [param_matches REF_CLK_FREQ "78.125"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "78.125 MHz"
       set_parameter_value "REF_CLK_PERIOD" 12800 
    } elseif { [param_matches REF_CLK_FREQ "100"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "100 MHz"
       set_parameter_value "REF_CLK_PERIOD" 10000 
    } elseif { [param_matches REF_CLK_FREQ "125"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "125 MHz"
       set_parameter_value "REF_CLK_PERIOD" 8000 
    } elseif { [param_matches REF_CLK_FREQ "156.25"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "156.25 MHz"
       set_parameter_value "REF_CLK_PERIOD" 6400 
    } elseif { [param_matches REF_CLK_FREQ "195.3125"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "195.3125 MHz"
       set_parameter_value "REF_CLK_PERIOD" 5120 
    } elseif { [param_matches REF_CLK_FREQ "200"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "200 MHz"
       set_parameter_value "REF_CLK_PERIOD" 5000 
    } elseif { [param_matches REF_CLK_FREQ "250"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "250 MHz"
       set_parameter_value "REF_CLK_PERIOD" 4000 
    } elseif { [param_matches REF_CLK_FREQ "312.5"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "312.5 MHz"
       set_parameter_value "REF_CLK_PERIOD" 3200 
    } elseif { [param_matches REF_CLK_FREQ "390.625"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "390.625 MHz"
       set_parameter_value "REF_CLK_PERIOD" 2560 
    } elseif { [param_matches REF_CLK_FREQ "400"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "400 MHz"
       set_parameter_value "REF_CLK_PERIOD" 2500 
    } elseif { [param_matches REF_CLK_FREQ "500"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "500 MHz"
       set_parameter_value "REF_CLK_PERIOD" 2000 
    } elseif { [param_matches REF_CLK_FREQ "625"] } {
       set_parameter_value "REF_CLK_FREQ_WITH_UNIT" "625 MHz"
       set_parameter_value "REF_CLK_PERIOD" 1600 
    }

    #Capability Registers
    #Derive the actual parameter value, resetting the parameter value to FALSE when greyed out
    if { [param_is_true CAR_EXTENDED_ROUTE_TABLE_GUI] && [param_is_true CAR_STANDARD_ROUTE_TABLE] } {
       set_parameter_value "CAR_EXTENDED_ROUTE_TABLE" true
    } else {
       set_parameter_value "CAR_EXTENDED_ROUTE_TABLE" false
    }

    #Case:77344 RTL should have Avalon word addresses for slaves and byte addresses for masters as required by Avalon Specs.
    set io_slave_addr_width [expr [get_parameter_value IO_SLAVE_ADDRESS_WIDTH] - 4]
    set mnt_addr_width [expr [get_parameter_value MAINTENANCE_ADDRESS_WIDTH] - 2]

#------------------------------------------------------------------------
# 2. Interface/Port
#------------------------------------------------------------------------

    #------------------------------------------------------------------------
    # Clocks and reset interface
    #------------------------------------------------------------------------
    if {[param_is_true XCVR_RESET_CTRL] } {
        add_interface pll_ref_clk clock sink
        add_interface_port pll_ref_clk pll_ref_clk clk input 1
    } else {
    #Clock source for Native PHY IP
    add_interface tx_pll_refclk clock sink
    add_interface_port tx_pll_refclk tx_pll_refclk clk input 1
    #add_interface rx_cdr_refclk clock sink
    #add_interface_port rx_cdr_refclk rx_cdr_refclk clk input 1 
    }

    #Clock source for RapidIO II
    add_interface sys_clk clock sink
    add_interface_port sys_clk sys_clk clk input 1
    add_interface_port sys_clk rst_n reset_n input 1

    #Transceiver clkout from Native PHY IP
    add_interface rx_clkout clock source
    add_interface_port rx_clkout rx_clkout clk output 1
    add_interface tx_clkout clock source
    add_interface_port tx_clkout tx_clkout clk output 1

    #------------------------------------------------------------------------
    # Avalon-MM interfaces with corresponding interrupts
    #------------------------------------------------------------------------
    #Note: mnt_s_readerror, iom_rd_wr_readresponse and ios_rd_wr_readresponse added as conduit signals, until readerror signal type is added to Avalon-MM slaves and masters. Case:12508.
    # System Maintenance Avalon-MM Master Interface
    add_interface mnt_master avalon master sys_clk
    add_interface_port mnt_master usr_mnt_waitrequest   waitrequest   input 1
    add_interface_port mnt_master usr_mnt_readdata      readdata      input 32
    add_interface_port mnt_master usr_mnt_readdatavalid readdatavalid input 1
    add_interface_port mnt_master usr_mnt_address       address       output 32
    add_interface_port mnt_master usr_mnt_write         write         output 1
    add_interface_port mnt_master usr_mnt_read          read          output 1
    add_interface_port mnt_master usr_mnt_writedata     writedata     output 32

    # Maintenance User Visible Interface
    if {[string compare -nocase [get_parameter_value MAINTENANCE] true] == 0 } { 
        add_interface mnt_slave avalon slave sys_clk
        set_interface_property mnt_slave maximumPendingReadTransactions 1
        add_interface_port mnt_slave mnt_s_address       address       input $mnt_addr_width
        add_interface_port mnt_slave mnt_s_write         write         input 1      
        add_interface_port mnt_slave mnt_s_writedata     writedata     input 32
        add_interface_port mnt_slave mnt_s_read          read          input 1
        add_interface_port mnt_slave mnt_s_waitrequest   waitrequest   output 1
        add_interface_port mnt_slave mnt_s_readdatavalid readdatavalid output 1
        add_interface_port mnt_slave mnt_s_readdata      readdata      output 32   
   #TODO     add_interface_port mnt_slave mnt_s_readerror    readerror output 1 
        add_interface mnt_slave_readerror conduit end
        add_interface_port mnt_slave_readerror mnt_s_readerror     export output 1

        # Interrupt signal
        add_interface mnt_mnt_s_irq interrupt sender
        set_interface_property mnt_mnt_s_irq ASSOCIATED_CLOCK sys_clk
        add_interface_port mnt_mnt_s_irq mnt_mnt_s_irq irq output 1
    }

    # Doorbell Avalon-MM Slave User Visible Interface
    if {[string compare -nocase [get_parameter_value DOORBELL] true] == 0 } {
        add_interface drbell_slave avalon slave sys_clk
        add_interface_port drbell_slave drbell_s_read        read        input 1
        add_interface_port drbell_slave drbell_s_write       write       input 1
        add_interface_port drbell_slave drbell_s_address     address     input 4
        add_interface_port drbell_slave drbell_s_writedata   writedata   input 32
        add_interface_port drbell_slave drbell_s_waitrequest waitrequest output 1
        add_interface_port drbell_slave drbell_s_readdata    readdata    output 32

        #Interrupt signal
        add_interface drbell_s_irq interrupt sender
        set_interface_property drbell_s_irq ASSOCIATED_CLOCK sys_clk
	add_interface_port drbell_s_irq drbell_s_irq irq output 1
    }


    if {[string compare -nocase [get_parameter_value IO_SLAVE] true] == 0 } { 
        add_interface io_slave avalon slave sys_clk
        set_interface_property io_slave maximumPendingReadTransactions 8
        #maximumPendingReadTransactions based on IO_SLAVE_OUTSTANDING_NREADS and the supported value can be 8 to 128. Default is 8. 
        add_interface_port io_slave ios_rd_wr_address       address input $io_slave_addr_width      
        add_interface_port io_slave ios_rd_wr_write         write input 1      
        add_interface_port io_slave ios_rd_wr_read          read input 1        
        add_interface_port io_slave ios_rd_wr_writedata     writedata input 128  
        add_interface_port io_slave ios_rd_wr_burstcount    burstcount input 5 
        add_interface_port io_slave ios_rd_wr_byteenable    byteenable input 16 
        add_interface_port io_slave ios_rd_wr_waitrequest   waitrequest output 1
        add_interface_port io_slave ios_rd_wr_readdata      readdata output 128   
        add_interface_port io_slave ios_rd_wr_readdatavalid readdatavalid output 1
      #TODO  add_interface_port io_slave ios_rd_wr_readresponse  readerror output 1
        add_interface io_slave_readerror conduit end
        add_interface_port io_slave_readerror ios_rd_wr_readresponse  export output 1

        #Interrupt signal
        add_interface io_s_mnt_irq interrupt sender
        set_interface_property io_s_mnt_irq ASSOCIATED_CLOCK sys_clk
        add_interface_port io_s_mnt_irq io_s_mnt_irq irq output 1

        # No read only or write only configuration, so these ports are redundant. Set to zero. 
        add_interface_port io_slave ios_wr_address export input $io_slave_addr_width
        add_interface_port io_slave ios_wr_write export input 1    
        add_interface_port io_slave ios_wr_writedata export input 128
        add_interface_port io_slave ios_wr_byteenable export input 16
        add_interface_port io_slave ios_wr_burstcount export input 5
        #add_interface_port io_slave ios_wr_waitrequest export output 1

        set_port_property ios_wr_address TERMINATION TRUE
        set_port_property ios_wr_address TERMINATION_VALUE 0
        set_port_property ios_wr_write TERMINATION TRUE
        set_port_property ios_wr_write TERMINATION_VALUE 0
        set_port_property ios_wr_writedata TERMINATION TRUE
        set_port_property ios_wr_writedata TERMINATION_VALUE 0
        set_port_property ios_wr_byteenable TERMINATION TRUE
        set_port_property ios_wr_byteenable TERMINATION_VALUE 0
        set_port_property ios_wr_burstcount TERMINATION TRUE
        set_port_property ios_wr_burstcount TERMINATION_VALUE 0

        add_interface_port io_slave ios_rd_address export input $io_slave_addr_width
        add_interface_port io_slave ios_rd_read export input 1        
        add_interface_port io_slave ios_rd_burstcount export input 5 
        add_interface_port io_slave ios_rd_byteenable export input 16 
        #add_interface_port io_slave ios_rd_waitrequest export output 1
        #add_interface_port io_slave ios_rd_readdata export output 128   
        #add_interface_port io_slave ios_rd_readresponse export output 1  
        #add_interface_port io_slave ios_rd_readdatavalid export output 1

        set_port_property ios_rd_address TERMINATION TRUE
        set_port_property ios_rd_address TERMINATION_VALUE 0
        set_port_property ios_rd_read TERMINATION TRUE
        set_port_property ios_rd_read TERMINATION_VALUE 0
        set_port_property ios_rd_burstcount TERMINATION TRUE
        set_port_property ios_rd_burstcount TERMINATION_VALUE 0
        set_port_property ios_rd_byteenable TERMINATION TRUE
        set_port_property ios_rd_byteenable TERMINATION_VALUE 0

    }

    # Maintenance Bridge External Avalon-MM Slave User Visible Interface
    add_interface register_slave avalon slave sys_clk
    set_interface_property register_slave maximumPendingReadTransactions 1
    #Case:79138 ext_mnt_address 24 LSBits (byte address) exposed to user and 8 MSBits tied to low internally.
    #Qsys uses word address for Avalon-MM Slave, so ext_mnt_address with 32-bit readdata is 24-2=22-bit word address.
    add_interface_port register_slave ext_mnt_address       address input 22
    add_interface_port register_slave ext_mnt_write         write input 1
    add_interface_port register_slave ext_mnt_read          read input 1
    add_interface_port register_slave ext_mnt_writedata     writedata input 32
    add_interface_port register_slave ext_mnt_waitrequest   waitrequest output 1 
    add_interface_port register_slave ext_mnt_readdata      readdata output 32
    add_interface_port register_slave ext_mnt_readdatavalid readdatavalid output 1
    add_interface register_slave_readerror conduit end
    add_interface_port register_slave_readerror ext_mnt_readresponse  export output 1
    #Case:80128 writeresponse type is not supported in Qsys and this signal has little value for Register Access interface.
    #add_interface_port register_slave_readerror ext_mnt_writeresponse export output 1

    #Interrupt signal
    add_interface io_m_mnt_irq interrupt sender
    set_interface_property io_m_mnt_irq ASSOCIATED_CLOCK sys_clk
    add_interface_port io_m_mnt_irq io_m_mnt_irq irq output 1

    # I/O Master User Visible Interface
    if {[string compare -nocase [get_parameter_value IO_MASTER] true] == 0 } {
        add_interface io_master avalon master sys_clk
        add_interface_port io_master iom_rd_wr_readdatavalid readdatavalid input 1
        add_interface_port io_master iom_rd_wr_readdata      readdata      input 128
        add_interface_port io_master iom_rd_wr_waitrequest   waitrequest   input 1
        add_interface_port io_master iom_rd_wr_read          read       output 1    
        add_interface_port io_master iom_rd_wr_write         write      output 1    
        add_interface_port io_master iom_rd_wr_writedata     writedata  output 128  
        add_interface_port io_master iom_rd_wr_burstcount    burstcount output 5
        add_interface_port io_master iom_rd_wr_byteenable    byteenable output 16
        add_interface_port io_master iom_rd_wr_address       address    output IO_MASTER_ADDRESS_WIDTH
      #TODO  add_interface_port io_master iom_rd_wr_readresponse  readerror input 1  
        add_interface io_master_readerror conduit end
        add_interface_port io_master_readerror iom_rd_wr_readresponse  export input 1  
        #NOTE: IO Master interrupt signal io_m_mnt_irq associated with 'register_slave' Avalon MM Slave interface.
    }

    #------------------------------------------------------------------------
    # Avalon-ST interfaces
    #------------------------------------------------------------------------
    if {[string compare -nocase [get_parameter_value PASS_THROUGH] true] == 0 } {
        # Pass-through Avalon-ST Payload & Header User Visible Interface 
        add_interface gen_rx_pd avalon_streaming source sys_clk
        add_interface_port gen_rx_pd gen_rx_pd_ready         ready         input 1
        add_interface_port gen_rx_pd gen_rx_pd_data          data          output 128
        add_interface_port gen_rx_pd gen_rx_pd_valid         valid         output 1
        add_interface_port gen_rx_pd gen_rx_pd_startofpacket startofpacket output 1
        add_interface_port gen_rx_pd gen_rx_pd_endofpacket   endofpacket   output 1
        add_interface_port gen_rx_pd gen_rx_pd_empty         empty         output 4

        add_interface gen_rx_hd avalon_streaming source sys_clk
        add_interface_port gen_rx_hd gen_rx_hd_ready ready input 1
        add_interface_port gen_rx_hd gen_rx_hd_data  data  output 115
        add_interface_port gen_rx_hd gen_rx_hd_valid valid output 1
        set_interface_property gen_rx_hd dataBitsPerSymbol 115

        # Transmit Side of Avalon-ST Pass-Through User Visible Interface
        add_interface gen_tx avalon_streaming sink sys_clk
        add_interface_port gen_tx gen_tx_data          data input 128 
        add_interface_port gen_tx gen_tx_valid         valid input 1
        add_interface_port gen_tx gen_tx_startofpacket startofpacket input 1
        add_interface_port gen_tx gen_tx_endofpacket   endofpacket input 1
        add_interface_port gen_tx gen_tx_empty         empty input 4
        add_interface_port gen_tx gen_tx_ready         ready output 1
        #Note: gen_tx_packet_size bus is added to the a different Avalon-ST interface until Avalon-ST adds a size signal.
        add_interface gen_tx_packet_size avalon_streaming sink sys_clk
        add_interface_port gen_tx_packet_size gen_tx_packet_size data input 9
        set_port_property gen_tx_packet_size fragment_list "ext_tx_packet_size(8:0)"
        set_interface_property gen_tx_packet_size dataBitsPerSymbol 9
    }


    if {[param_is_true ENABLE_TRANSPORT_LAYER]} {
        #Note: 1. If Avalon-ST pass-through interface is not enabled in the variation, drops unregcognized received packets. 
        #      2. If you turned off Enable 16-bit device ID width option, drops packets with a 16-bit device ID. 
        add_interface transport_rx_packet_dropped conduit end
        add_interface_port transport_rx_packet_dropped transport_rx_packet_dropped export output 1
    }

    #------------------------------------------------------------------------
    # Conduit interfaces
    #------------------------------------------------------------------------

    ####################################
    # Base Device ID
    ####################################
    add_interface base_device_id conduit end
    add_interface_port base_device_id base_device_id export output 8
    add_interface_port base_device_id large_base_device_id export output 16

    ####################################
    # CAR Interface
    ####################################
    add_interface car_csr_intf conduit end

    add_interface_port car_csr_intf car_device_id export input 16
    set_port_property car_device_id TERMINATION TRUE
    set_port_property car_device_id TERMINATION_VALUE [get_parameter_value CAR_DEVICE_ID]

    add_interface_port car_csr_intf car_device_vendor_id export input 16
    set_port_property car_device_vendor_id TERMINATION TRUE
    set_port_property car_device_vendor_id TERMINATION_VALUE [get_parameter_value CAR_DEVICE_VENDOR_ID]

    add_interface_port car_csr_intf car_device_revision_id export input 32
    set_port_property car_device_revision_id TERMINATION TRUE
    set_port_property car_device_revision_id TERMINATION_VALUE [get_parameter_value CAR_DEVICE_REVISION_ID]

    add_interface_port car_csr_intf car_assey_id export input 16
    set_port_property car_assey_id TERMINATION TRUE
    set_port_property car_assey_id TERMINATION_VALUE [get_parameter_value CAR_ASSEY_ID]

    add_interface_port car_csr_intf car_assey_vendor_id export input 16
    set_port_property car_assey_vendor_id TERMINATION TRUE
    set_port_property car_assey_vendor_id TERMINATION_VALUE [get_parameter_value CAR_ASSEY_VENDOR_ID]

    add_interface_port car_csr_intf car_revision_id export input 16
    set_port_property car_revision_id TERMINATION TRUE
    set_port_property car_revision_id TERMINATION_VALUE [get_parameter_value CAR_REVISION_ID]

    add_interface_port car_csr_intf car_bridge export input 1
    set_port_property car_bridge TERMINATION TRUE
    set_port_property car_bridge TERMINATION_VALUE [param_matches CAR_BRIDGE true]

    add_interface_port car_csr_intf car_memory export input 1
    set_port_property car_memory TERMINATION TRUE
    set_port_property car_memory TERMINATION_VALUE [param_matches CAR_MEMORY true]

    add_interface_port car_csr_intf car_processor export input 1
    set_port_property car_processor TERMINATION TRUE
    set_port_property car_processor TERMINATION_VALUE [param_matches CAR_PROCESSOR true]

    add_interface_port car_csr_intf car_switch export input 1
    set_port_property car_switch TERMINATION TRUE
    set_port_property car_switch TERMINATION_VALUE [param_matches CAR_SWITCH true]

    add_interface_port car_csr_intf car_num_of_ports export input 8
    set_port_property car_num_of_ports TERMINATION TRUE
    set_port_property car_num_of_ports TERMINATION_VALUE [get_parameter_value CAR_NUM_OF_PORTS]

    add_interface_port car_csr_intf car_port_num export input 8
    set_port_property car_port_num TERMINATION TRUE
    set_port_property car_port_num TERMINATION_VALUE [get_parameter_value CAR_PORT_NUM]

    add_interface_port car_csr_intf car_extended_route_table export input 1
    set_port_property car_extended_route_table TERMINATION TRUE
    set_port_property car_extended_route_table TERMINATION_VALUE [param_matches CAR_EXTENDED_ROUTE_TABLE true]

    add_interface_port car_csr_intf car_standard_route_table export input 1
    set_port_property car_standard_route_table TERMINATION TRUE
    set_port_property car_standard_route_table TERMINATION_VALUE [param_matches CAR_STANDARD_ROUTE_TABLE true]

    add_interface_port car_csr_intf car_flow_arbitration export input 1
    set_port_property car_flow_arbitration TERMINATION TRUE
    set_port_property car_flow_arbitration TERMINATION_VALUE [param_matches CAR_FLOW_ARBITRATION true]

    add_interface_port car_csr_intf car_flow_control export input 1
    set_port_property car_flow_control TERMINATION TRUE
    set_port_property car_flow_control TERMINATION_VALUE [param_matches CAR_FLOW_CONTROL true]

    add_interface_port car_csr_intf car_max_pdu_size export input 16
    set_port_property car_max_pdu_size TERMINATION TRUE
    set_port_property car_max_pdu_size TERMINATION_VALUE [get_parameter_value CAR_MAX_PDU_SIZE]

    add_interface_port car_csr_intf car_segmentation_contexts export input 16
    set_port_property car_segmentation_contexts TERMINATION TRUE
    set_port_property car_segmentation_contexts TERMINATION_VALUE [get_parameter_value CAR_SEGMENTATION_CONTEXTS]

    add_interface_port car_csr_intf car_max_destid export input 16
    set_port_property car_max_destid TERMINATION TRUE
    set_port_property car_max_destid TERMINATION_VALUE [get_parameter_value CAR_MAX_DESTID]

    add_interface_port car_csr_intf car_source_operations export input 32
    set_port_property car_source_operations TERMINATION TRUE
    set_port_property car_source_operations TERMINATION_VALUE [get_parameter_value CAR_SOURCE_OPERATIONS]

    add_interface_port car_csr_intf car_destination_operations export input 32
    set_port_property car_destination_operations TERMINATION TRUE
    set_port_property car_destination_operations TERMINATION_VALUE [get_parameter_value CAR_DESTINATION_OPERATIONS]

    ####################################
    # CSR Interface
    ####################################
    add_interface_port car_csr_intf ef_ptr_reset_value export input 16
    set_port_property ef_ptr_reset_value TERMINATION TRUE
    set_port_property ef_ptr_reset_value TERMINATION_VALUE [get_parameter_value EF_PTR_RESET_VALUE]

    add_interface_port car_csr_intf csr_tm_types_reset_value export input 4 
    set_port_property csr_tm_types_reset_value TERMINATION TRUE
    set_port_property csr_tm_types_reset_value TERMINATION_VALUE [get_parameter_value CSR_TM_TYPES_RESET_VALUE]

    add_interface_port car_csr_intf csr_tm_mode_reset_value export input 4  
    set_port_property csr_tm_mode_reset_value TERMINATION TRUE
    set_port_property csr_tm_mode_reset_value TERMINATION_VALUE [get_parameter_value CSR_TM_MODE_RESET_VALUE]

    add_interface_port car_csr_intf csr_mtu_reset_value export input 8  
    set_port_property csr_mtu_reset_value TERMINATION TRUE
    set_port_property csr_mtu_reset_value TERMINATION_VALUE [get_parameter_value CSR_MTU_RESET_VALUE]

    #Note: use fragment_list to change port name of generated top level, without changing name in RTL. 
    add_interface_port car_csr_intf tm_mode_wr export input 1 
    set_port_property tm_mode_wr fragment_list "csr_external_tm_mode_wr"
 
    add_interface_port car_csr_intf mtu_wr export input 1   
    set_port_property mtu_wr fragment_list "csr_external_mtu_wr"

    add_interface_port car_csr_intf tm_mode_in export input 4  
    set_port_property tm_mode_in fragment_list "csr_external_tm_mode_in(3:0)"

    add_interface_port car_csr_intf mtu_in export input 8
    set_port_property mtu_in fragment_list "csr_external_mtu_in(7:0)"

    add_interface_port car_csr_intf tm_types export output 4
    add_interface_port car_csr_intf tm_mode export output 4
    add_interface_port car_csr_intf mtu export output 8
    if {[string compare -nocase [get_parameter_value ERROR_MANAGEMENT_EXTENSION] true] == 0 } {  
        add_interface error_management conduit end
        add_interface_port error_management message_error_response_set export input 1
        add_interface_port error_management gsm_error_response_set export input 1 
        add_interface_port error_management message_format_error_response_set export input 1  

        add_interface_port error_management illegal_transaction_decode_set export input 1   
        set_port_property illegal_transaction_decode_set fragment_list "external_illegal_transaction_decode_set"

        add_interface_port error_management message_request_timeout_set export input 1    
        set_port_property message_request_timeout_set fragment_list "external_message_request_timeout_set"

        add_interface_port error_management slave_packet_response_timeout_set export input 1   
        set_port_property slave_packet_response_timeout_set fragment_list "external_slave_packet_response_timeout_set"

        add_interface_port error_management unsolicited_response_set export input 1  
        set_port_property unsolicited_response_set fragment_list "external_unsolicited_response_set"

        add_interface_port error_management unsupported_transaction_set export input 1  
        set_port_property unsupported_transaction_set fragment_list "external_unsupported_transaction_set"

        add_interface_port error_management illegal_transaction_target_error_set export input 1    
        set_port_property illegal_transaction_target_error_set fragment_list "external_illegal_transaction_target_error_set"

        add_interface_port error_management missing_data_streaming_context_set export input 1   
        set_port_property missing_data_streaming_context_set fragment_list "external_missing_data_streaming_context_set"

        add_interface_port error_management open_existing_data_streaming_context_set export input 1   
        set_port_property open_existing_data_streaming_context_set fragment_list "external_open_existing_data_streaming_context_set"

        add_interface_port error_management long_data_streaming_segment_set export input 1   
        set_port_property long_data_streaming_segment_set fragment_list "external_long_data_streaming_segment_set"

        add_interface_port error_management short_data_streaming_segment_set export input 1   
        set_port_property short_data_streaming_segment_set fragment_list "external_short_data_streaming_segment_set"

        add_interface_port error_management data_streaming_pdu_length_error_set export input 1  
        set_port_property data_streaming_pdu_length_error_set fragment_list "external_data_streaming_pdu_length_error_set"

        add_interface_port error_management external_capture_destinationID_wr export input 1   
        #add_interface_port error_management capture_destinationID_wr export input 1   
        #set_port_property capture_destinationID_wr fragment_list "external_capture_destinationID_wr"

        add_interface_port error_management external_capture_destinationID_in export input 16  
        #add_interface_port error_management capture_destinationID_in export input 16   
        #set_port_property capture_destinationID_in fragment_list "external_capture_destinationID_in(15:0)"

        add_interface_port error_management external_capture_sourceID_wr export input 1   
        #add_interface_port error_management capture_sourceID_wr export input 1    
        #set_port_property capture_sourceID_wr fragment_list "external_capture_sourceID_wr"

        add_interface_port error_management external_capture_sourceID_in export input 16   
        #add_interface_port error_management capture_sourceID_in export input 16   
        #set_port_property capture_sourceID_in fragment_list "external_capture_sourceID_in(15:0)"

        add_interface_port error_management capture_ftype_wr export input 1   
        set_port_property capture_ftype_wr fragment_list "external_capture_ftype_wr"

        add_interface_port error_management capture_ftype_in export input 4  
        set_port_property capture_ftype_in fragment_list "external_capture_ftype_in(3:0)"

        add_interface_port error_management capture_ttype_wr export input 1   
        set_port_property capture_ttype_wr fragment_list "external_capture_ttype_wr"

        add_interface_port error_management capture_ttype_in export input 4   
        set_port_property capture_ttype_in fragment_list "external_capture_ttype_in(3:0)"

        add_interface_port error_management letter_wr export input 1    
        set_port_property letter_wr fragment_list "external_letter_wr"

        add_interface_port error_management letter_in export input 2   
        set_port_property letter_in fragment_list "external_letter_in(1:0)"

        add_interface_port error_management mbox_wr export input 1
        set_port_property mbox_wr fragment_list "external_mbox_wr"

        add_interface_port error_management mbox_in export input 2
        set_port_property mbox_in fragment_list "external_mbox_in(1:0)"

        add_interface_port error_management msgseg_wr export input 1
        set_port_property msgseg_wr fragment_list "external_msgseg_wr"

        add_interface_port error_management msgseg_in export input 4
        set_port_property msgseg_in fragment_list "external_msgseg_in(3:0)"

        add_interface_port error_management xmbox_wr export input 1
        set_port_property xmbox_wr fragment_list "external_xmbox_wr"

        add_interface_port error_management xmbox_in export input 4
        set_port_property xmbox_in fragment_list "external_xmbox_in(3:0)"


        add_interface_port error_management port_degraded export output 1 
        add_interface_port error_management port_failed export output 1
        add_interface_port error_management logical_transport_error export output 1
        add_interface_port error_management time_to_live export output 16

    }

    # Register access interface interrupt signal  
    add_interface std_reg_mnt_irq interrupt sender
    set_interface_property std_reg_mnt_irq ASSOCIATED_CLOCK sys_clk
    add_interface_port std_reg_mnt_irq std_reg_mnt_irq irq output 1

    ####################################
    # Physical Layer Register Interface
    ####################################
    add_interface phy_register_in conduit end

    add_interface_port phy_register_in host_reset_value export input 1 
    set_port_property host_reset_value TERMINATION TRUE
    set_port_property host_reset_value TERMINATION_VALUE [get_parameter_value HOST_RESET_VALUE]

    add_interface_port phy_register_in master_enable_reset_value export input 1
    set_port_property master_enable_reset_value TERMINATION TRUE
    set_port_property master_enable_reset_value TERMINATION_VALUE [get_parameter_value MASTER_ENABLE_RESET_VALUE]

    add_interface_port phy_register_in discovered_reset_value export input 1
    set_port_property discovered_reset_value TERMINATION TRUE
    set_port_property discovered_reset_value TERMINATION_VALUE [get_parameter_value DISCOVERED_RESET_VALUE]

    add_interface_port phy_register_in flow_control_participant_reset_value export input 1
    set_port_property flow_control_participant_reset_value TERMINATION TRUE
    set_port_property flow_control_participant_reset_value TERMINATION_VALUE [get_parameter_value FLOW_CONTROL_PARTICIPANT_RESET_VALUE]

    add_interface_port phy_register_in enumeration_boundary_reset_value export input 1
    set_port_property enumeration_boundary_reset_value TERMINATION TRUE
    set_port_property enumeration_boundary_reset_value TERMINATION_VALUE [get_parameter_value ENUMERATION_BOUNDARY_RESET_VALUE]

    add_interface_port phy_register_in flow_arbitration_participant_reset_value export input 1
    set_port_property flow_arbitration_participant_reset_value TERMINATION TRUE
    set_port_property flow_arbitration_participant_reset_value TERMINATION_VALUE [get_parameter_value FLOW_ARBITRATION_PARTICIPANT_RESET_VALUE]

    add_interface_port phy_register_in transmitter_type_reset_value export input 1
    set_port_property transmitter_type_reset_value TERMINATION TRUE
    set_port_property transmitter_type_reset_value TERMINATION_VALUE [get_parameter_value TRANSMITTER_TYPE_RESET_VALUE]

    add_interface_port phy_register_in receiver_type_reset_value export input 2
    set_port_property receiver_type_reset_value TERMINATION TRUE
    set_port_property receiver_type_reset_value TERMINATION_VALUE [get_parameter_value RECEIVER_TYPE_RESET_VALUE]

    add_interface_port phy_register_in disable_destination_id_checking_reset_value export input 1
    set_port_property disable_destination_id_checking_reset_value TERMINATION TRUE
    set_port_property disable_destination_id_checking_reset_value TERMINATION_VALUE [param_matches PROMISCUOUS true]

    # Physical Layer User Visible Interfaces
    add_interface control_symbol_rx_tx conduit end
    add_interface_port control_symbol_rx_tx send_multicast_event export input 1
    add_interface_port control_symbol_rx_tx send_link_request_reset_device export input 1
    add_interface_port control_symbol_rx_tx sent_link_request_reset_device export output 1
    add_interface_port control_symbol_rx_tx multicast_event_rx export output 1 
    add_interface_port control_symbol_rx_tx link_req_reset_device_received export output 1 
    add_interface_port control_symbol_rx_tx sent_multicast_event export output 1

    add_interface physical_layer_status conduit end
    add_interface_port physical_layer_status port_initialized export output 1              
    add_interface_port physical_layer_status link_initialized export output 1   
    add_interface_port physical_layer_status port_ok export output 1                   
    add_interface_port physical_layer_status port_error export output 1                    
    add_interface_port physical_layer_status packet_transmitted export output 1            
    add_interface_port physical_layer_status packet_cancelled export output 1             
    add_interface_port physical_layer_status packet_accepted_cs_sent export output 1        
    add_interface_port physical_layer_status packet_retry_cs_sent export output 1          
    add_interface_port physical_layer_status packet_not_accepted_cs_sent export output 1  
    add_interface_port physical_layer_status packet_accepted_cs_received export output 1  
    add_interface_port physical_layer_status packet_retry_cs_received export output 1      
    add_interface_port physical_layer_status packet_not_accepted_cs_received export output 1 
    add_interface_port physical_layer_status packet_crc_error export output 1   
    add_interface_port physical_layer_status control_symbol_error export output 1
     # Master enable signal
    add_interface_port physical_layer_status master_enable export output 1 
    if {[param_is_false XCVR_RESET_CTRL] } {
       #export these signals only when external reset controller is used.
       if {[param_is_true SUPPORT_4X] } {
          add_interface_port physical_layer_status four_lanes_aligned export output 1 
       }
       if {[param_is_true SUPPORT_2X] } {
          add_interface_port physical_layer_status two_lanes_aligned export output 1 
       }
    }

    ####################################
    # Native PHY signals
    ####################################
    add_interface serial_data conduit end
    add_interface_port serial_data rd export input LSIZE
    add_interface_port serial_data td export output LSIZE
    if {[param_is_true SUPPORT_4X] } {
        set_port_property rd fragment_list "rx_serial_data(3:0)"
        set_port_property td fragment_list "tx_serial_data(3:0)"
    } elseif {[param_is_true SUPPORT_2X] } {
        set_port_property rd fragment_list "rx_serial_data(1:0)"
        set_port_property td fragment_list "tx_serial_data(1:0)"
    } else {
        set_port_property rd fragment_list "rx_serial_data(0)"
        set_port_property td fragment_list "tx_serial_data(0)"
    }

    add_interface transceiver conduit end
    add_interface_port transceiver pll_locked export output 1 
    add_interface_port transceiver rx_is_lockedtoref export output LSIZE
    add_interface_port transceiver rx_is_lockedtodata export output LSIZE
    add_interface_port transceiver rx_syncstatus export output LSIZE
    add_interface_port transceiver rx_signaldetect export output LSIZE
    if {[param_is_false XCVR_RESET_CTRL] } {
       #export these signals only when external reset controller is used.
       add_interface_port transceiver tx_cal_busy export output LSIZE
       add_interface_port transceiver rx_cal_busy export output LSIZE
    }


    ####################################
    # Reconfig Controller Ports
    ####################################
    #Note: Alternative - by calling altera_xcvr_functions to determine the width of the reconfig ports. 
    #set width_reconfig_to_xcvr [altera_xcvr_functions::get_reconfig_to_width(DEVICE_FAMILY,number_of_reconfig_interfaces)]
    # The following reconfig port width valid for Stratix V and Arria V. 
    #add_interface tx_pll conduit end
    add_interface reconfig_to_xcvr conduit end
    add_interface reconfig_from_xcvr conduit end
    if { [param_matches SUPPORT_4X true]} {
        add_interface_port reconfig_to_xcvr reconfig_to_xcvr export input 350
        add_interface_port reconfig_from_xcvr reconfig_from_xcvr export output 230
    } elseif {[param_matches SUPPORT_2X true]} {
        add_interface_port reconfig_to_xcvr reconfig_to_xcvr export input 210
        add_interface_port reconfig_from_xcvr reconfig_from_xcvr export output 138
    } else {
        add_interface_port reconfig_to_xcvr reconfig_to_xcvr export input 140
        add_interface_port reconfig_from_xcvr reconfig_from_xcvr export output 92
    }

    ####################################
    # Transceiver Reset Controller signals
    ####################################
    if {[param_is_true XCVR_RESET_CTRL] } {
    add_interface xcvr_rst_ctrl conduit end
    add_interface_port xcvr_rst_ctrl tx_ready export output LSIZE
    add_interface_port xcvr_rst_ctrl rx_ready export output LSIZE
    } else {
    # External
    add_interface xcvr_rst_ctrl conduit end
    add_interface_port xcvr_rst_ctrl tx_ready export input LSIZE
    add_interface_port xcvr_rst_ctrl rx_ready export input LSIZE
    add_interface_port xcvr_rst_ctrl pll_powerdown export input 1
    add_interface_port xcvr_rst_ctrl tx_analogreset export input LSIZE
    add_interface_port xcvr_rst_ctrl tx_digitalreset export input LSIZE
    add_interface_port xcvr_rst_ctrl rx_analogreset export input LSIZE
    add_interface_port xcvr_rst_ctrl rx_digitalreset export input LSIZE
    }
}

#------------------------------------------------------------------------
# 3. Fileset
#------------------------------------------------------------------------

proc common_fileset {name language gensim simulator} {
    global env
    set qdir $env(QUARTUS_ROOTDIR)
	
    set libdir "${qdir}/../ip/altera/altera_rapidio2"
    set tmpdir "."

   if {[string compare -nocase ${simulator} synopsys] == 0} {
       set filekind "VERILOG_ENCRYPT"
       set filekind_systemverilog "SYSTEM_VERILOG_ENCRYPT"
       set simulator_path "synopsys"
       set simulator_specific "SYNOPSYS_SPECIFIC"
   } elseif {[string compare -nocase ${simulator} mentor] == 0} {
       set filekind "VERILOG_ENCRYPT"
       set filekind_systemverilog "SYSTEM_VERILOG_ENCRYPT"
       #set filekind "VERILOG"
       #set filekind_systemverilog "SYSTEMVERILOG"
       set simulator_path "mentor"
       set simulator_specific "MENTOR_SPECIFIC"
   } elseif {[string compare -nocase ${simulator} cadence] == 0} {
       set filekind "VERILOG_ENCRYPT"
       set filekind_systemverilog "SYSTEM_VERILOG_ENCRYPT"
       set simulator_path "cadence"
       set simulator_specific "CADENCE_SPECIFIC"
   } elseif {[string compare -nocase ${simulator} aldec] == 0} {
       set filekind "VERILOG_ENCRYPT"
       set filekind_systemverilog "SYSTEM_VERILOG_ENCRYPT"
       set simulator_path "aldec"
       set simulator_specific "ALDEC_SPECIFIC"
   } else { 
       #for synthesis
       set filekind "VERILOG"
       set filekind_systemverilog "SYSTEMVERILOG"
       set simulator_path "."
       set simulator_specific "SYNTHESIS"
   }

    # Top level - System Verilog files
    add_fileset_file ${simulator}/${name}_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_top.sv $simulator_specific     

    # MegaFunction Top level wrapper - Verilog files
    ## Native PHY IP top level wrapper		
    if { [param_matches SUPPORT_4X true]} {
        if {[param_matches DEVICE_FAMILY "Stratix V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_stratixv/native_phy_4x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav/native_phy_4x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav_gz/native_phy_4x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_cyclonev/native_phy_4x/altera_rapidio2_native_phy.v $simulator_specific
        }
			
    } elseif {[param_matches SUPPORT_2X true]} {
        if {[param_matches DEVICE_FAMILY "Stratix V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_stratixv/native_phy_2x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav/native_phy_2x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav_gz/native_phy_2x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_cyclonev/native_phy_2x/altera_rapidio2_native_phy.v $simulator_specific
        }
    } else {		
        if {[param_matches DEVICE_FAMILY "Stratix V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_stratixv/native_phy_1x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav/native_phy_1x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_arriav_gz/native_phy_1x/altera_rapidio2_native_phy.v $simulator_specific
        } elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
            add_fileset_file ${simulator}/altera_rapidio2_native_phy.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/native_phy_cyclonev/native_phy_1x/altera_rapidio2_native_phy.v $simulator_specific
        }
    }



    # Common - System Verilog files
    add_fileset_file ${simulator}/${name}_atlantic_if.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_atlantic_if.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_avalon_mm_if.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_avalon_mm_if.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_avalon_st_if.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_avalon_st_if.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_std_reg_interfaces.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_std_reg_interfaces.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_megacore_top.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_megacore_top.sv $simulator_specific 
    add_fileset_file ${simulator}/${name}_std_reg_top.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_std_reg_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_car_csr_control.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_car_csr_control.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_error_management_control.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_error_management_control.sv $simulator_specific
		
    add_fileset_file ${simulator}/${name}_maintenance_bridge_top.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_maintenance_bridge_top.sv $simulator_specific	
    add_fileset_file ${simulator}/${name}_arbiter_mnt.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_arbiter_mnt.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_address_decoder.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_address_decoder.sv $simulator_specific 
    add_fileset_file ${simulator}/${name}_crm.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_crm.sv $simulator_specific
		
    #if {[param_is_true DOORBELL] } {
    #Have to include these files eventhough the DOORBELL is false due to declaration in megacore_top.
    #Anyway, these modules will not be instantiated and not utilize any resource. 
        add_fileset_file ${simulator}/${name}_drbell_adp_top.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_drbell_adp_top.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_drbell_adp_rx.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_drbell_adp_rx.sv $simulator_specific 
        add_fileset_file ${simulator}/${name}_drbell_adp_tx.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_drbell_adp_tx.sv $simulator_specific 
    #}


        add_fileset_file ${simulator}/${name}_mnt_adp_top.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_mnt_adp_top.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_mnt_adp_rx_queue.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_mnt_adp_rx_queue.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_mnt_adp_tx_queue.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_mnt_adp_tx_queue.sv $simulator_specific
    if {[param_is_true MAINTENANCE] } {
    # Logical Layer - Verilog files
        if { [param_matches TRANSPORT_LARGE true] } {
            add_fileset_file ${simulator}/${name}_maintenance.v $filekind PATH ${tmpdir}/${simulator_path}/logical/maintenance/altera_rapidio2_dev16_maintenance.v $simulator_specific
        } else {
            add_fileset_file ${simulator}/${name}_maintenance.v $filekind PATH ${tmpdir}/${simulator_path}/logical/maintenance/altera_rapidio2_dev8_maintenance.v $simulator_specific
        }
    }

    if {[param_is_true DOORBELL] && [param_matches TRANSPORT_LARGE true] } {
        add_fileset_file ${simulator}/${name}_drbell.v $filekind PATH ${tmpdir}/${simulator_path}/logical/doorbell/altera_rapidio2_dev16_drbell.v $simulator_specific
    }
    if {[param_is_true DOORBELL] && [param_matches TRANSPORT_LARGE false] } {
        add_fileset_file ${simulator}/${name}_drbell.v $filekind PATH ${tmpdir}/${simulator_path}/logical/doorbell/altera_rapidio2_dev8_drbell.v $simulator_specific
    }

    # Logical Layer - System Verilog files
    #if { [param_is_true IO_MASTER] } {
    #Have to include these files eventhough the IO_MASTER is false due to declaration in megacore_top.
        add_fileset_file ${simulator}/${name}_io_master.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_128_io_master.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_tx.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_128_io_m_tx.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_rx.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_128_io_m_rx.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_read_write.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_io_m_read_write.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_addr_map.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_io_m_addr_map.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_pending_req_queue.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_io_m_pending_req_queue.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_m_response_q.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_master/128/altera_rapidio2_io_m_response_q.sv $simulator_specific		
    #}

    #if { [param_is_true IO_SLAVE] } {
    #Have to include these files eventhough the IO_SLAVE is false due to declaration in megacore_top.
        add_fileset_file ${simulator}/${name}_io_slave.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_128_io_slave.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_req_processor_glue_in.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_req_processor_glue_in.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_request_processor.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_request_processor.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_io_transmitter.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_io_transmitter.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_response_handling.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_response_handling.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_ios_register.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_ios_register.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_mapping_glue_in.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_mapping_glue_in.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_mapping_module.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_mapping_module.sv $simulator_specific
		
        add_fileset_file ${simulator}/${name}_glue_out.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_glue_out.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_pending_request_queue.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_pending_request_queue.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_show_ahead_memory.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_show_ahead_memory.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_tid_queue.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_tid_queue.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_transmitter_glue1.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_transmitter_glue1.sv $simulator_specific
        add_fileset_file ${simulator}/${name}_transmitter_glue2.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/logical/io_slave/128/altera_rapidio2_transmitter_glue2.sv $simulator_specific
    #}

    # Physical Layer - Verilog files
    add_fileset_file ${simulator}/${name}_phy_pkg.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_phy_pkg.sv $simulator_specific
    ##PHY2
     add_fileset_file ${simulator}/${name}_control_symbol_fifo.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_control_symbol_fifo.v $simulator_specific

    ##PHY3
    add_fileset_file ${simulator}/${name}_dpram_ackid_prio_mem.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_dpram_ackid_prio_mem.v $simulator_specific
    add_fileset_file ${simulator}/${name}_dpram_free_queue.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_dpram_free_queue.v $simulator_specific
    add_fileset_file ${simulator}/${name}_dpram_prio_queue.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_dpram_prio_queue.v $simulator_specific
    add_fileset_file ${simulator}/${name}_dpram_shared_mem.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_dpram_shared_mem.v $simulator_specific
    add_fileset_file ${simulator}/${name}_dpram_size_fifo.v $filekind PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_dpram_size_fifo.v $simulator_specific
		
    # Physical Layer - System Verilog files
    add_fileset_file ${simulator}/${name}_phy_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_phy_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_physical_layer.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_physical_layer.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_phy_register_control.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_phy_register_control.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_lpserial_control.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_lpserial_control.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_lpserial_lane_control.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_lpserial_lane_control.sv $simulator_specific

    add_fileset_file ${simulator}/${name}_xcvr_ctrl.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/altera_rapidio2_xcvr_ctrl.sv $simulator_specific
	
    ##PHY1
    add_fileset_file ${simulator}/${name}_phy1.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_phy1.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_1x2x_detect_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_1x2x_detect_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_dcfifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_dcfifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_descrambler.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_descrambler.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_destriper.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_destriper.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_port_initialization_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_port_initialization_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_dcfifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_rx_dcfifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_phy1.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_rx_phy1.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_scrambler.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_scrambler.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_striper.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_striper.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_dcfifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_tx_dcfifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_phy1.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy1/altera_rapidio2_tx_phy1.sv $simulator_specific
	    			
    ##PHY2
    add_fileset_file ${simulator}/${name}_phy2.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_phy2.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_align32_processor.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_align32_processor.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_boto.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_boto.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_crc13.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_crc13.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_csa.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_csa.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_csp.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_csp.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_input_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_input_sm.sv $simulator_specific	
    add_fileset_file ${simulator}/${name}_isg.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_isg.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_link_init_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_link_init_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_output_error_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_output_error_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_output_protocol.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_output_protocol.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_output_retry_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_output_retry_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_output_sm.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_output_sm.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_packer_crc_interface.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_packer_crc_interface.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_packet_crc_checker.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_packet_crc_checker.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_align32.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_rx_align32.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_align32_precalc.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_rx_align32_precalc.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_packer.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_rx_packer.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_phy2.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_rx_phy2.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_sop_detector.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_sop_detector.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_stg1_csp.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_stg1_csp.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_stg2_pd_cs_detect.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_stg2_pd_cs_detect.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tsa.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_tsa.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_controller.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_tx_controller.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_phy2.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy2/altera_rapidio2_tx_phy2.sv $simulator_specific
	
    ##PHY3
    add_fileset_file ${simulator}/${name}_phy3.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_phy3.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_free_queue_fifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_free_queue_fifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_pkt_crc_gen.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_pkt_crc_gen.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_pkt_crc_insertion.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_pkt_crc_insertion.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_prio_queue_fifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_prio_queue_fifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_prio_size_fifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_prio_size_fifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_size_fifo.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_size_fifo.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_trq_mem_block.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_trq_mem_block.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_trq_read_controller.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_trq_read_controller.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_trq_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_trq_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_trq_write_controller.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/physical/phy3/altera_rapidio2_trq_write_controller.sv $simulator_specific
		
    # Transport Layer - System Verilog files
    add_fileset_file ${simulator}/${name}_transport_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_transport_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_functions_inc.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_functions_inc.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_trans_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_tx_trans_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_transport_rx_top.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_transport_rx_top.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_buffer.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_rx_buffer.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_hd_pd_separator.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_rx_hd_pd_separator.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_ll_pkt_router.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_rx_ll_pkt_router.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_pkt_vld_chkr.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_rx_pkt_vld_chkr.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_rx_prio_thrshld_lvl_trkr.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_rx_prio_thrshld_lvl_trkr.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_simple_dpram.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_simple_dpram.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_tx_scheduler.sv  $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/transport/altera_rapidio2_tx_scheduler.sv $simulator_specific
	
    # RapidIO II PHY IP Soft logic - Verilog files
    add_fileset_file ${simulator}/${name}_native_phy_ip_fifo.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/altera_fifo.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_dskw_fifo.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/dskw_fifo.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_dskw_sm.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/dskw_sm.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_dskw_top.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/dskw_top.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_lane_sync_sm.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/lane_sync_sm.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_rate_match_deletion_lane_n.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/rate_match_deletion_lane_n.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_rate_match_insertion_lane_n.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/rate_match_insertion_lane_n.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_rate_match_lane_n_top.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/rate_match_lane_n_top.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_rate_match_top.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/rate_match_top.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_soft_logic_top.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/soft_logic_top.v $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_sync_two_clk_domains.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/sync_two_clk_domains.v $simulator_specific

    # RapidIO II PHY IP Soft logic - System Verilog files
    add_fileset_file ${simulator}/${name}_av_tx_data_map.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/altera_rapidio2_av_tx_data_map.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_soft_pcs.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/altera_rapidio2_soft_pcs.sv $simulator_specific
    add_fileset_file ${simulator}/${name}_native_phy_ip_bus_synchronizer.sv $filekind_systemverilog PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/soft_logic/altera_rapidio2_bus_synchronizer.sv $simulator_specific

    ## Transceiver Reset Controller 
    # Top level wrapper of Reset Controller
    #if { [param_matches XCVR_RESET_CTRL true] } {
    #Note: For Customer Demo Testbench convenience, generate the Transceiver Reset controller fileset no matter what.
        if { [param_matches SUPPORT_4X true]} {
            add_fileset_file ${simulator}/xcvr_rst_ctrl.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/xcvr_rst_ctrl/xcvr_rst_ctrl_4x/xcvr_rst_ctrl.v $simulator_specific
        } elseif {[param_matches SUPPORT_2X true]} {
            add_fileset_file ${simulator}/xcvr_rst_ctrl.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/xcvr_rst_ctrl/xcvr_rst_ctrl_2x/xcvr_rst_ctrl.v $simulator_specific
        } else {	
            add_fileset_file ${simulator}/xcvr_rst_ctrl.v $filekind PATH ${tmpdir}/${simulator_path}/altera_rapidio2_native_phy_ip/xcvr_rst_ctrl/xcvr_rst_ctrl_1x/xcvr_rst_ctrl.v $simulator_specific
        }
        # Submodules of Reset Controller
        # Workaround for Case:71346
        if {[string compare -nocase ${simulator} mentor] == 0} {
           add_fileset_file ${simulator}/altera_xcvr_reset_control.sv $filekind_systemverilog PATH ${qdir}/../ip/altera/alt_xcvr/altera_xcvr_reset_control/mentor/altera_xcvr_reset_control.sv $simulator_specific
           add_fileset_file ${simulator}/alt_xcvr_reset_counter.sv $filekind_systemverilog PATH ${qdir}/../ip/altera/alt_xcvr/altera_xcvr_reset_control/mentor/alt_xcvr_reset_counter.sv $simulator_specific
        } else {
          #use non-encrypted files for other simulators
           add_fileset_file ${simulator}/altera_xcvr_reset_control.sv $filekind_systemverilog PATH ${qdir}/../ip/altera/alt_xcvr/altera_xcvr_reset_control/altera_xcvr_reset_control.sv $simulator_specific
           add_fileset_file ${simulator}/alt_xcvr_reset_counter.sv $filekind_systemverilog PATH ${qdir}/../ip/altera/alt_xcvr/altera_xcvr_reset_control/alt_xcvr_reset_counter.sv $simulator_specific
        }
    #}

    # Add SDC and OCP files for Synthesis
    #-----------------------------------
    # Terp for SDC file
    #-----------------------------------
    #Set up Terp Variables
    set DEVICE_FAMILY   [ get_parameter_value DEVICE_FAMILY ]
    set MAX_BAUD_RATE   [ get_parameter_value MAX_BAUD_RATE ]
    set REF_CLK_PERIOD  [ get_parameter_value REF_CLK_PERIOD ]
    set SUPPORT_4X      [ get_parameter_value SUPPORT_4X ]
    set SUPPORT_2X      [ get_parameter_value SUPPORT_2X ]

    #Do Terp
    set template_file [ file join $tmpdir "altera_rapidio2.sdc.terp" ]  
    set template   [ read [ open $template_file r ] ]  
    set params(device_family) $DEVICE_FAMILY
    set params(ref_clk_period_ns) $REF_CLK_PERIOD
    set params(support_4x) $SUPPORT_4X
    set params(support_2x) $SUPPORT_2X

    #Derive sys_clk frequency = MAX_BAUD_RATE/40
    if { [param_matches MAX_BAUD_RATE 1250] } {
        set params(sys_clk_period) 32
    } elseif { [param_matches MAX_BAUD_RATE 2500] } {
        set params(sys_clk_period) 16
    } elseif { [param_matches MAX_BAUD_RATE 3125] } { 
        set params(sys_clk_period) 12.8
    } elseif { [param_matches MAX_BAUD_RATE 5000] } { 
        set params(sys_clk_period) 8
    } elseif { [param_matches MAX_BAUD_RATE 6250] } { 
        set params(sys_clk_period) 6.4
    }
   
    #Derive PLL refclk frequency in nano-second. 
    if { [param_matches REF_CLK_FREQ "50"] } {
       set params(ref_clk_period_ns) 20
    } elseif { [param_matches REF_CLK_FREQ "62.5"] } {
       set params(ref_clk_period_ns) 16
    } elseif { [param_matches REF_CLK_FREQ "78.125"] } {
       set params(ref_clk_period_ns) 12.8
    } elseif { [param_matches REF_CLK_FREQ "100"] } {
       set params(ref_clk_period_ns) 10
    } elseif { [param_matches REF_CLK_FREQ "125"] } {
       set params(ref_clk_period_ns) 8
    } elseif { [param_matches REF_CLK_FREQ "156.25"] } {
       set params(ref_clk_period_ns) 6.4
    } elseif { [param_matches REF_CLK_FREQ "195.3125"] } {
       set params(ref_clk_period_ns) 5.12
    } elseif { [param_matches REF_CLK_FREQ "200"] } {
       set params(ref_clk_period_ns) 5
    } elseif { [param_matches REF_CLK_FREQ "250"] } {
       set params(ref_clk_period_ns) 4
    } elseif { [param_matches REF_CLK_FREQ "312.5"] } {
       set params(ref_clk_period_ns) 3.2
    } elseif { [param_matches REF_CLK_FREQ "390.625"] } {
       set params(ref_clk_period_ns) 2.56
    } elseif { [param_matches REF_CLK_FREQ "400"] } {
       set params(ref_clk_period_ns) 2.5
    } elseif { [param_matches REF_CLK_FREQ "500"] } {
       set params(ref_clk_period_ns) 2
    } elseif { [param_matches REF_CLK_FREQ "625"] } {
       set params(ref_clk_period_ns) 1.6
    }

    set result          [ altera_terp $template params ]

    if {[string compare -nocase ${simulator} synthesis] == 0} {
        add_fileset_file altera_rapidio2.sdc SDC TEXT $result $simulator_specific 
        add_fileset_file ${simulator}/altera_rapidio2_physical_layer.ocp OTHER PATH ${tmpdir}/altera_rapidio2_physical_layer.ocp $simulator_specific
    } 
    #Note: Top with reset controller requires a different SDC with different clock input. 

}


#------------------------------------------------------------------------
# 4. Customer Demo Testbench
#------------------------------------------------------------------------

proc cust_demo_tb {name language gensim} {
	global env
	set qdir $env(QUARTUS_ROOTDIR)
   	set tmpdir "."
    set demo_tb_lib  "${tmpdir}/../demo_tb"
	
    if { [expr $gensim == 1] } {
     
       send_message info "Testbench customizing started"
     
    # Create package to store parameterization for IP variant

      set output_file     [ create_temp_file altera_rapidio2_tb_var_functions.sv ]
      set out   [ open $output_file w ]

      puts $out "\/\/ Package Declaration"
      puts $out "package altera_rapidio2_tb_var_functions\;"
      	
         
      foreach param [get_parameters] {
	    set type [ get_parameter_property $param TYPE ] 
	    set value [ get_parameter_value $param ]  
	    if { [ string compare -nocase $type BOOLEAN ] == 0 } { 
		    if { [ string compare -nocase $value true ] == 0 } {
		        set argument "-parameterization.$param:1"
		        puts $out "parameter ${param}    = 1\'b1\;"
 		    } else {
		        set argument "-parameterization.$param:0"
		        puts $out "parameter ${param}    =1\'b0 \;"
		    }
	    } elseif { [ string compare -nocase $type INTEGER ] == 0 } {  
    	        set argument "-parameterization.$param:$value"
		        puts $out "parameter ${param}    =${value}\;"
		       
    	} else {
		        puts $out "parameter ${param}    =\"${value}\"\;"
		        
        }
     }

	  puts $out "endpackage"  
      close $out
        
       add_fileset_file tb/verbosity_pkg.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/lib/verbosity_pkg.sv
       add_fileset_file tb/avalon_utilities_pkg.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/lib/avalon_utilities_pkg.sv
       add_fileset_file tb/avalon_mm_pkg.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/lib/avalon_mm_pkg.sv
       add_fileset_file tb/altera_avalon_mm_master_bfm.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv
       add_fileset_file tb/altera_avalon_mm_slave_bfm.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/altera_avalon_mm_slave_bfm/altera_avalon_mm_slave_bfm.sv
       add_fileset_file tb/altera_avalon_st_source_bfm.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm.sv
       add_fileset_file tb/altera_avalon_st_sink_bfm.sv SYSTEM_VERILOG PATH ${qdir}/../ip/altera/sopc_builder_ip/verification/altera_avalon_st_sink_bfm/altera_avalon_st_sink_bfm.sv              
       add_fileset_file tb/tb_hutil.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/tb_hutil.sv
       add_fileset_file tb/avalon_mm_master_bfm_wrp.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/avalon_mm_master_bfm_wrp.sv
       add_fileset_file tb/avalon_mm_slave_bfm_wrp.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/avalon_mm_slave_bfm_wrp.sv
       add_fileset_file tb/avalon_st_snk_bfm_wrp.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/avalon_st_snk_bfm_wrp.sv
       add_fileset_file tb/avalon_st_src_bfm_wrp.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/avalon_st_src_bfm_wrp.sv
       add_fileset_file tb/altera_rapidio2_tb_var_functions.sv SYSTEM_VERILOG PATH ${output_file}
       add_fileset_file tb/altera_rapidio2_top_with_reset_ctrl.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/altera_rapidio2_top_with_reset_ctrl.sv
       add_fileset_file tb/tb_rio.sv SYSTEM_VERILOG PATH ${demo_tb_lib}/tb_rio.sv
                  
      
    }
	
    
	send_message info "Finish customizing testbench"


 
}

#------------------------------------------------------------------------
# 6. Add fileset for synthesis and simulators
#------------------------------------------------------------------------

proc synthproc {name} {
        #To generate (copy) necessary files for Altera Transceiver Reset Controller MegaFunction
	#::altera_xcvr_reset_control::fileset::declare_files
	#::altera_xcvr_reset_control::fileset::callback_quartus_synth ""
    #Case:71346. Use the above workaround to call the files directly from Quartus source.

        #To generate (copy) necessary files for Altera Transceiver Native PHY IP 
	if {[param_matches DEVICE_FAMILY "Stratix V"]} {
	::altera_xcvr_native_sv::fileset::declare_files
	::altera_xcvr_native_sv::fileset::callback_quartus_synth ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
	::altera_xcvr_native_av::fileset::declare_files
	::altera_xcvr_native_av::fileset::callback_quartus_synth ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
	#Native phy fileset of Stratix V is sharing with Arria V GZ
	::altera_xcvr_native_sv::fileset::declare_files
	::altera_xcvr_native_sv::fileset::callback_quartus_synth ""	
	} elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
	::altera_xcvr_native_cv::fileset::declare_files
	::altera_xcvr_native_cv::fileset::callback_quartus_synth ""
	}

    common_fileset altera_rapidio2 verilog 0 synthesis
    #Note: the first argument of common_fileset 'altera_rapidio2' is the prefix $name of the submodules, can be any names. 
}

proc verilogsimproc {name} {
        #To generate (copy) necessary files for Altera Transceiver Reset Controller MegaFunction
	#::altera_xcvr_reset_control::fileset::declare_files
	#::altera_xcvr_reset_control::fileset::callback_quartus_synth ""
    #case:71346

        #To generate (copy) necessary files for Altera Transceiver Native PHY IP 
	if {[param_matches DEVICE_FAMILY "Stratix V"]} {
	   ::altera_xcvr_native_sv::fileset::declare_files
	   ::altera_xcvr_native_sv::fileset::callback_sim_verilog ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
	   ::altera_xcvr_native_av::fileset::declare_files
	   ::altera_xcvr_native_av::fileset::callback_sim_verilog ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
	#Native phy fileset of Stratix V is sharing with Arria V GZ
	    ::altera_xcvr_native_sv::fileset::declare_files
	   ::altera_xcvr_native_sv::fileset::callback_sim_verilog ""
	} elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
	   ::altera_xcvr_native_cv::fileset::declare_files
	   ::altera_xcvr_native_cv::fileset::callback_sim_verilog ""
	}

    if {1} {
    common_fileset altera_rapidio2 "verilog" 1 mentor
    }
    if {0} {
    common_fileset altera_rapidio2 "verilog" 1 synopsys
    }
    if {0} {
    common_fileset altera_rapidio2 "verilog" 1 cadence
    }
    if {1} {
    common_fileset altera_rapidio2 "verilog" 1 aldec
    }
    
    cust_demo_tb $name "verilog" 1

}

proc vhdlsimproc {name} {
        #To generate (copy) necessary files for Altera Transceiver Native PHY IP 
	if {[param_matches DEVICE_FAMILY "Stratix V"]} {
	::altera_xcvr_native_sv::fileset::declare_files
	::altera_xcvr_native_sv::fileset::callback_sim_vhdl ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V"]} {
	::altera_xcvr_native_av::fileset::declare_files
	::altera_xcvr_native_av::fileset::callback_sim_vhdl ""
	} elseif {[param_matches DEVICE_FAMILY "Arria V GZ"]} {
	#Native phy fileset of Stratix V is sharing with Arria V GZ
	::altera_xcvr_native_sv::fileset::declare_files
	::altera_xcvr_native_sv::fileset::callback_sim_vhdl ""
	} elseif {[param_matches DEVICE_FAMILY "Cyclone V"]} {
	::altera_xcvr_native_cv::fileset::declare_files
	::altera_xcvr_native_cv::fileset::callback_sim_vhdl ""
	} 

    if {1} {
    common_fileset altera_rapidio2 "vhdl" 1 mentor
    }
    if {0} {
    common_fileset altera_rapidio2 "vhdl" 1 synopsys
    }
    if {0} {
    common_fileset altera_rapidio2 "vhdl" 1 cadence
    }
    if {1} {
    common_fileset altera_rapidio2 "vhdl" 1 aldec
    }

    cust_demo_tb $name "vhdl" 1
} 
