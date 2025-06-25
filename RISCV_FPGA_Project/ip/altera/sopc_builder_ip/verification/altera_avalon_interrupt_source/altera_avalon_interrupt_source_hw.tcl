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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_interrupt_source/altera_avalon_interrupt_source_hw.tcl $
# $Revision: #2 $
# $Date: 2013/08/15 $
# $Author: saafnan $
#------------------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                           altera_avalon_interrupt_source
set_module_property VERSION          	            13.1
set_module_property GROUP      		               "Avalon Verification Suite"
set_module_property DISPLAY_NAME 		            "Altera Avalon Interrupt Source"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL 			               false
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property ANALYZE_HDL                    false
set_module_property HIDE_FROM_SOPC                 true

# ------------------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_interrupt_source

add_fileset sim_verilog SIM_VERILOG simverilog
set_fileset_property sim_verilog top_level altera_avalon_interrupt_source

add_fileset sim_vhdl SIM_VHDL simvhdl
set_fileset_property sim_vhdl top_level altera_avalon_interrupt_source_vhdl

# SIM_VERILOG generation callback procedure
proc simverilog {altera_avalon_interrupt_source} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "$HDL_LIB_DIR/verbosity_pkg.sv"
   add_fileset_file altera_avalon_interrupt_source.sv SYSTEM_VERILOG path "altera_avalon_interrupt_source.sv"
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
}

proc quartus_synth_proc {altera_avalon_interrupt_source} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG path "$HDL_LIB_DIR/verbosity_pkg.sv"
   add_fileset_file altera_avalon_interrupt_source.sv SYSTEM_VERILOG path "altera_avalon_interrupt_source.sv"
}

# SIM_VHDL generation callback procedure
proc simvhdl {altera_avalon_interrupt_source_vhdl} {
   set HDL_LIB_DIR "../lib"
   set VHDL_DIR    "../altera_avalon_interrupt_source_vhdl"
   
   if {1} {
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT path "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_interrupt_source.sv SYSTEM_VERILOG_ENCRYPT path "mentor/altera_avalon_interrupt_source.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_interrupt_source_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT path "mentor/altera_avalon_interrupt_source_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
      
      set_fileset_file_attribute mentor/verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_verbosity_pkg
   }
   
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT path "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_interrupt_source.sv SYSTEM_VERILOG_ENCRYPT path "altera_avalon_interrupt_source.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_interrupt_source_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT path "altera_avalon_interrupt_source_vhdl_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   
   add_fileset_file altera_avalon_interrupt_source_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_avalon_interrupt_source_vhdl_pkg.vhd"
   add_fileset_file altera_avalon_interrupt_source_vhdl.vhd VHDL path "$VHDL_DIR/altera_avalon_interrupt_source_vhdl.vhd"
}

# ------------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------
set ASSERT_HIGH_IRQ           "ASSERT_HIGH_IRQ"
set ASYNCHRONOUS_INTERRUPT    "ASYNCHRONOUS_INTERRUPT"
set AV_IRQ_W                  "AV_IRQ_W"
set VHDL_ID                   "VHDL_ID"

add_parameter $ASSERT_HIGH_IRQ Integer 1
set_parameter_property $ASSERT_HIGH_IRQ DISPLAY_NAME "Assert irq high"
set_parameter_property $ASSERT_HIGH_IRQ DESCRIPTION "Irq is active high when this value is set to 1"
set_parameter_property $ASSERT_HIGH_IRQ DISPLAY_HINT boolean
set_parameter_property $ASSERT_HIGH_IRQ AFFECTS_ELABORATION true
set_parameter_property $ASSERT_HIGH_IRQ HDL_PARAMETER true
set_parameter_property $ASSERT_HIGH_IRQ GROUP "Interrupt Interface"

add_parameter $ASYNCHRONOUS_INTERRUPT Integer 0
set_parameter_property $ASYNCHRONOUS_INTERRUPT DISPLAY_NAME "Asynchronous irq"
set_parameter_property $ASYNCHRONOUS_INTERRUPT DESCRIPTION "Assert irq asynchronously to its associated clock when this value is set to 1"
set_parameter_property $ASYNCHRONOUS_INTERRUPT DISPLAY_HINT boolean
set_parameter_property $ASYNCHRONOUS_INTERRUPT AFFECTS_ELABORATION true
set_parameter_property $ASYNCHRONOUS_INTERRUPT HDL_PARAMETER true
set_parameter_property $ASYNCHRONOUS_INTERRUPT GROUP "Interrupt Mode"

add_parameter $AV_IRQ_W Integer 1
set_parameter_property $AV_IRQ_W DISPLAY_NAME "Irq width"
set_parameter_property $AV_IRQ_W DESCRIPTION "Width of irq signal"
set_parameter_property $AV_IRQ_W AFFECTS_ELABORATION true
set_parameter_property $AV_IRQ_W HDL_PARAMETER true
set_parameter_property $AV_IRQ_W ALLOWED_RANGES {1:32}
set_parameter_property $AV_IRQ_W GROUP "Interrupt Interface"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

#------------------------------------------------------------------------------
proc elaborate {} {
   global ASSERT_HIGH_IRQ
   global AV_IRQ_W
   global ASYNCHRONOUS_INTERRUPT

   set ASSERT_HIGH_IRQ_VALUE         [get_parameter $ASSERT_HIGH_IRQ]
   set AV_IRQ_W_VALUE                [get_parameter $AV_IRQ_W]
   set ASYNCHRONOUS_INTERRUPT_VALUE  [get_parameter $ASYNCHRONOUS_INTERRUPT]
   
   set CLOCK_INTERFACE  "clock_reset"
   set IRQ_INTERFACE    "irq"

   #---------------------------------------------------------------------
   # Clock Interface
   #---------------------------------------------------------------------
   add_interface $CLOCK_INTERFACE clock end
   set_interface_property $CLOCK_INTERFACE ENABLED true

   add_interface_port $CLOCK_INTERFACE clk clk Input 1
   add_interface_port $CLOCK_INTERFACE reset reset Input 1

   #---------------------------------------------------------------------
   # Interrupt Source Interface
   #---------------------------------------------------------------------
   add_interface $IRQ_INTERFACE interrupt sender
   set_interface_property $IRQ_INTERFACE associatedAddressablePoint ""

   if {$ASYNCHRONOUS_INTERRUPT_VALUE == 0} {
      set_interface_property $IRQ_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
   }
   set_interface_property $IRQ_INTERFACE ENABLED true

   if {$ASSERT_HIGH_IRQ_VALUE > 0 } {
      add_interface_port $IRQ_INTERFACE irq irq Output $AV_IRQ_W_VALUE
   } else {
      add_interface_port $IRQ_INTERFACE irq irq_n Output $AV_IRQ_W_VALUE
   }
   set_port_property $IRQ_INTERFACE VHDL_TYPE STD_LOGIC_VECTOR
}

