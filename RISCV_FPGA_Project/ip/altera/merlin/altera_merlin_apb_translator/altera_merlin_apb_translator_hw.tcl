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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_apb_translator/altera_merlin_apb_translator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
# 
# altera_merlin_apb_translator "APB Translator"
# tgngo 2012.11.19.21:12:08
# APB translator
# 

# 
# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0


# 
# module altera_merlin_apb_translator
# 
set_module_property DESCRIPTION "APB translator: set default value for optionals signals"
set_module_property NAME altera_merlin_apb_translator
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property AUTHOR tgngo
set_module_property DISPLAY_NAME "APB Translator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_merlin_apb_translator
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_merlin_apb_translator.sv SYSTEM_VERILOG PATH altera_merlin_apb_translator.sv

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL altera_merlin_apb_translator
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_merlin_apb_translator.sv SYSTEM_VERILOG PATH altera_merlin_apb_translator.sv

add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_apb_translator

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_apb_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_apb_translator.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_apb_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_apb_translator.sv" {ALDEC_SPECIFIC}
   }
   if {1} {
      add_fileset_file cadence/altera_merlin_apb_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_apb_translator.sv" {CADENCE_SPECIFIC}
   }
   if {1} {
      add_fileset_file synopsys/altera_merlin_apb_translator.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_apb_translator.sv" {SYNOPSYS_SPECIFIC}
   }    
}

# 
# documentation links
# 
add_documentation_link DATASHEET http://www.altera.com


# 
# parameters
# 
add_parameter ADDR_WIDTH INTEGER 32 "APB Address width"
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 32
set_parameter_property ADDR_WIDTH DISPLAY_NAME "Address width"
set_parameter_property ADDR_WIDTH TYPE INTEGER
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDR_WIDTH DESCRIPTION "APB Address width"
set_parameter_property ADDR_WIDTH HDL_PARAMETER true
add_parameter DATA_WIDTH INTEGER 32 "ABP Data width"
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width"
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DATA_WIDTH DESCRIPTION "ABP Data width"
set_parameter_property DATA_WIDTH HDL_PARAMETER true
add_parameter USE_S0_PADDR31 BOOLEAN false ""
set_parameter_property USE_S0_PADDR31 DEFAULT_VALUE false
set_parameter_property USE_S0_PADDR31 DISPLAY_NAME USE_S0_PADDR31
set_parameter_property USE_S0_PADDR31 WIDTH ""
set_parameter_property USE_S0_PADDR31 TYPE BOOLEAN
set_parameter_property USE_S0_PADDR31 UNITS None
set_parameter_property USE_S0_PADDR31 DESCRIPTION "Turn On/Off paddr31 port at master side"
set_parameter_property USE_S0_PADDR31 HDL_PARAMETER true
add_parameter USE_M0_PADDR31 BOOLEAN false ""
set_parameter_property USE_M0_PADDR31 DEFAULT_VALUE false
set_parameter_property USE_M0_PADDR31 DISPLAY_NAME USE_M0_PADDR31
set_parameter_property USE_M0_PADDR31 WIDTH ""
set_parameter_property USE_M0_PADDR31 TYPE BOOLEAN
set_parameter_property USE_M0_PADDR31 UNITS None
set_parameter_property USE_M0_PADDR31 DESCRIPTION "Turn On/Off paddr31 port at slave side"
set_parameter_property USE_M0_PADDR31 HDL_PARAMETER true
add_parameter USE_M0_PSLVERR BOOLEAN false ""
set_parameter_property USE_M0_PSLVERR DEFAULT_VALUE false
set_parameter_property USE_M0_PSLVERR DISPLAY_NAME USE_M0_PSLVERR
set_parameter_property USE_M0_PSLVERR WIDTH ""
set_parameter_property USE_M0_PSLVERR TYPE BOOLEAN
set_parameter_property USE_M0_PSLVERR UNITS None
set_parameter_property USE_M0_PSLVERR DESCRIPTION "Turn On/Off slave error port at slave side"
set_parameter_property USE_M0_PSLVERR HDL_PARAMETER true

# +-----------------------------------
# | Set all parameters to AFFECTS_GENERATION false
# | 
foreach parameter [get_parameters] { 
	set_parameter_property $parameter AFFECTS_GENERATION false 
 }
# | 
# +-----------------------------------

# 
# display items
#
add_display_item "APB Parameters" ADDR_WIDTH PARAMETER ""
add_display_item "APB Parameters" DATA_WIDTH PARAMETER ""
add_display_item "Master Side Parameters" USE_S0_PADDR31 PARAMETER ""
add_display_item "Slave Side Parameters" USE_M0_PADDR31 PARAMETER ""
add_display_item "Slave Side Parameters" USE_M0_PSLVERR PARAMETER ""

# 
# connection point apb_slave
# 
add_interface s0 apb end
set_interface_property s0 associatedClock clk
set_interface_property s0 associatedReset clk_reset
set_interface_property s0 ENABLED true

add_interface_port s0 s0_paddr paddr Input 32
set_port_property s0_paddr vhdl_type std_logic_vector
add_interface_port s0 s0_psel psel Input 1
add_interface_port s0 s0_penable penable Input 1
add_interface_port s0 s0_pwrite pwrite Input 1
add_interface_port s0 s0_pwdata pwdata Input 32
set_port_property s0_pwdata vhdl_type std_logic_vector
add_interface_port s0 s0_prdata prdata Output 32
set_port_property s0_prdata vhdl_type std_logic_vector
add_interface_port s0 s0_pslverr pslverr Output 1
add_interface_port s0 s0_pready pready Output 1
add_interface_port s0 s0_paddr31 paddr31 Input 1

# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true

add_interface_port clk clk clk Input 1


# 
# connection point clk_reset
# 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset synchronousEdges DEASSERT
set_interface_property clk_reset ENABLED true

add_interface_port clk_reset reset reset Input 1


# 
# connection point apb_master
# 
add_interface m0 apb start
set_interface_property m0 associatedClock clk
set_interface_property m0 associatedReset clk_reset
set_interface_property m0 ENABLED true

add_interface_port m0 m0_paddr paddr Output 32
set_port_property m0_paddr vhdl_type std_logic_vector
add_interface_port m0 m0_psel psel Output 1
add_interface_port m0 m0_penable penable Output 1
add_interface_port m0 m0_pwrite pwrite Output 1
add_interface_port m0 m0_pwdata pwdata Output 32
set_port_property m0_pwdata vhdl_type std_logic_vector
add_interface_port m0 m0_prdata prdata Input 32
set_port_property m0_prdata vhdl_type std_logic_vector
add_interface_port m0 m0_pslverr pslverr Input 1
add_interface_port m0 m0_pready pready Input 1
add_interface_port m0 m0_paddr31 paddr31 Output 1

set_interface_assignment m0 merlin.flow.s0 s0
set_interface_assignment s0 merlin.flow.m0 m0

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {
    set data_width     [ get_parameter_value DATA_WIDTH ]
    set addr_width     [ get_parameter_value ADDR_WIDTH ]

    # +-----------------------------------
    # | Set correct width for each signals
    # +-----------------------------------    
    set_port_property m0_paddr  		WIDTH_EXPR $addr_width
    set_port_property m0_pwdata 		WIDTH_EXPR $data_width
    set_port_property m0_prdata         WIDTH_EXPR $data_width
	
	set_port_property s0_paddr  		WIDTH_EXPR $addr_width
	set_port_property s0_pwdata 		WIDTH_EXPR $data_width
    set_port_property s0_prdata         WIDTH_EXPR $data_width
	
	# +-----------------------------------
    # | Read parameters
    # +-----------------------------------
	# USE_S0_PADDR31 PARAMETER ""
	# USE_M0_PADDR31 PARAMETER ""
	# USE_M0_PSLVERR PARAMETER ""
	set use_m0_paddr31  [ get_parameter_value USE_M0_PADDR31 ]
	set use_s0_paddr31  [ get_parameter_value USE_S0_PADDR31 ]
	set use_m0_pslverr  [ get_parameter_value USE_M0_PSLVERR ]
	
	if { $use_m0_paddr31 == "false" } {
            set_port_property m0_paddr31 TERMINATION true
	}
	if { $use_s0_paddr31 == "false" } {
            set_port_property s0_paddr31 TERMINATION true
	}
	if { $use_m0_pslverr == "false" } {
            set_port_property m0_pslverr TERMINATION true
	}
	
	
}
