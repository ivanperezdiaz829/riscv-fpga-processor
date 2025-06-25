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


package require -exact sopc 10.1
sopc::preview_add_transform name preview_avalon_mm_transform

# +-----------------------------------
# | module PCI Express
# |
set_module_property NAME altera_pcie_descriptor_controller
set_module_property DESCRIPTION "Manages the DMA reads and writes operations on the 'Avalon-MM 256-bit Hard IP for PCI Express' (not compatible with other DMAs)"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_s5_pcie.pdf"
set_module_property GROUP "Interface Protocols/PCI"
set_module_property AUTHOR Altera
set_module_property DISPLAY_NAME "Altera PCIe Descriptor Controller"
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL false
set_module_property EDITABLE false
set_module_property ANALYZE_HDL FALSE
set_module_property TOP_LEVEL_HDL_FILE altpcieav_desc_control.sv
set_module_property TOP_LEVEL_HDL_MODULE altpcieav_desc_control
set_module_property STATIC_TOP_LEVEL_MODULE_NAME altpcieav_desc_control
set_module_property instantiateInSystemModule "true"
set_module_property ELABORATION_CALLBACK elaboration_callback

# # +-----------------------------------
# # | QUARTUS_SYNTH design RTL files
#   |
add_fileset synth QUARTUS_SYNTH proc_quartus_synth
add_fileset sim_vhdl SIM_VHDL proc_sim_vhdl
add_fileset sim_verilog SIM_VERILOG proc_sim_verilog

# +-----------------------------------
# | parameters
# |
add_parameter INTENDED_DEVICE_FAMILY String "STRATIX V"
set_parameter_property INTENDED_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
set_parameter_property INTENDED_DEVICE_FAMILY VISIBLE FALSE

# +-----------------------------------
# | Static IO
# |

add_interface clock clock end
add_interface_port clock Clk_i clk Input 1

add_interface reset_n reset end clock
add_interface_port reset_n Rstn_i reset_n input 1
set_interface_property reset_n synchronousEdges both


#   set TX_S_ADDR_WIDTH     [ get_parameter_value TX_S_ADDR_WIDTH ]
#   send_message info "TXS ADDRESS WIDHT is $TX_S_ADDR_WIDTH"
add_interface          DCM avalon master clock
set_interface_property DCM interleaveBursts false
set_interface_property DCM readLatency 0
set_interface_property DCM writeWaitTime 1
set_interface_property DCM readWaitTime 1
set_interface_property DCM addressUnits SYMBOLS
set_interface_property DCM maximumPendingReadTransactions 8
add_interface_port     DCM DCMAddress_o address output 64
add_interface_port     DCM DCMByteEnable_o byteenable output 4
add_interface_port     DCM DCMReadData_i readdata input 32
add_interface_port     DCM DCMWriteData_o writedata output 32
add_interface_port     DCM DCMRead_o read output 1
add_interface_port     DCM DCMWrite_o write output 1
add_interface_port     DCM DCMReadDataValid_i readdatavalid input 1
add_interface_port     DCM DCMWaitRequest_i waitrequest input 1



add_interface          DCS avalon slave clock
set_interface_property DCS interleaveBursts false
set_interface_property DCS readLatency 0
set_interface_property DCS writeWaitTime 1
set_interface_property DCS readWaitTime 1
set_interface_property DCS addressUnits SYMBOLS
set_interface_property DCS maximumPendingReadTransactions 0
add_interface_port     DCS DCSAddress_i address input 12
add_interface_port     DCS DCSChipSelect_i chipselect input 1
add_interface_port     DCS DCSByteEnable_i byteenable input 4
add_interface_port     DCS DCSReadData_o readdata output 32
add_interface_port     DCS DCSWriteData_i writedata input 32
add_interface_port     DCS DCSRead_i read input 1
add_interface_port     DCS DCSWrite_i write input 1
add_interface_port     DCS DCSWaitRequest_o waitrequest output 1


#set  rd_size_mask_hwtcl [ get_parameter_value rd_dma_size_mask_hwtcl ]
#set rd_data_width 256
add_interface          DTM avalon master clock
set_interface_property DTM interleaveBursts false
set_interface_property DTM doStreamReads false
set_interface_property DTM doStreamWrites false
set_interface_property DTM maxAddressWidth 64
set_interface_property DTM addressGroup 0
# Ports in interface $master_name
#send_message info " Read DMA size mask is $rd_size_mask_hwtcl"
#add_interface_port     DTM "RdDmaAddress_o" "address" "output" $rd_size_mask_hwtcl
add_interface_port     DTM DTMAddress_o address output 64
add_interface_port     DTM DTMRead_o read output 1
add_interface_port     DTM DTMReadData_i readdata input 256
add_interface_port     DTM DTMWaitRequest_i waitrequest input 1
add_interface_port     DTM DTMReadDataValid_i readdatavalid input 1


## Rd-AST
add_interface rd_ast_tx avalon_streaming start
set_interface_property rd_ast_tx associatedClock clock
set_interface_property rd_ast_tx associatedReset reset_n
set_interface_property rd_ast_tx dataBitsPerSymbol 160
set_interface_property rd_ast_tx firstSymbolInHighOrderBits true
set_interface_property rd_ast_tx maxChannel 0
set_interface_property rd_ast_tx readyLatency 0
set_interface_property rd_ast_tx ENABLED true
add_interface_port rd_ast_tx RdDdmaTxValid_o valid Output 1
add_interface_port rd_ast_tx RdDdmaTxData_o data Output 160
add_interface_port rd_ast_tx RdDdmaTxReady_i ready Input 1
##Rd-AST
add_interface rd_ast_rx avalon_streaming end
set_interface_property rd_ast_rx associatedClock clock
set_interface_property rd_ast_rx associatedReset reset_n
set_interface_property rd_ast_rx dataBitsPerSymbol 32
set_interface_property rd_ast_rx firstSymbolInHighOrderBits true
set_interface_property rd_ast_rx maxChannel 0
set_interface_property rd_ast_rx readyLatency 0
set_interface_property rd_ast_rx ENABLED true
add_interface_port rd_ast_rx RdDdmaRxData_i data Input 32
add_interface_port rd_ast_rx RdDdmaRxValid_i valid Input 1


## Wr-AST Tx
add_interface wr_ast_tx avalon_streaming start
set_interface_property wr_ast_tx associatedClock clock
set_interface_property wr_ast_tx associatedReset reset_n
set_interface_property wr_ast_tx dataBitsPerSymbol 160
set_interface_property wr_ast_tx firstSymbolInHighOrderBits true
set_interface_property wr_ast_tx maxChannel 0
set_interface_property wr_ast_tx readyLatency 0
set_interface_property wr_ast_tx ENABLED true
add_interface_port wr_ast_tx WrDdmaTxValid_o valid Output 1
add_interface_port wr_ast_tx WrDdmaTxData_o data Output 160
add_interface_port wr_ast_tx WrDdmaTxReady_i ready Input 1
##Wr-AST Rx
add_interface wr_ast_rx avalon_streaming end
set_interface_property wr_ast_rx associatedClock clock
set_interface_property wr_ast_rx associatedReset reset_n
set_interface_property wr_ast_rx dataBitsPerSymbol 32
set_interface_property wr_ast_rx firstSymbolInHighOrderBits true
set_interface_property wr_ast_rx maxChannel 0
set_interface_property wr_ast_rx readyLatency 0
set_interface_property wr_ast_rx ENABLED true
add_interface_port wr_ast_rx WrDdmaRxData_i data Input 32
add_interface_port wr_ast_rx WrDdmaRxValid_i valid Input 1


add_interface MSI_Interface      conduit end
add_interface_port MSI_Interface    MsiIntfc_i msi_intfc    Input 82
set_interface_assignment MSI_Interface "ui.blockdiagram.direction" "Input"


# ************** Global Variables ***************
set not_init "default"
# **************** Parameters *******************

proc elaboration_callback { } {
   validation_parameter_prj_setting
}

proc validation_parameter_prj_setting {} {
   # Check that device used is Stratix V
   set INTENDED_DEVICE_FAMILY [ get_parameter_value INTENDED_DEVICE_FAMILY ]
   send_message info "Family: $INTENDED_DEVICE_FAMILY"
#   if { [string compare -nocase $INTENDED_DEVICE_FAMILY "Stratix V"] != 0 && [string compare -nocase $INTENDED_DEVICE_FAMILY "Arria V GZ"] != 0} {
#      send_message error "Selected device family: $INTENDED_DEVICE_FAMILY is not supported"
#   }
}


proc proc_quartus_synth {name} {

   add_fileset_file altpcieav_desc_control.sv          SYSTEMVERILOG PATH altpcieav_desc_control.sv
}

proc proc_sim_vhdl {name} {

   add_fileset_file altpcieav_desc_control.sv          SYSTEMVERILOG PATH altpcieav_desc_control.sv

}

proc proc_sim_verilog {name} {

   add_fileset_file altpcieav_desc_control.sv          SYSTEMVERILOG PATH altpcieav_desc_control.sv

}


