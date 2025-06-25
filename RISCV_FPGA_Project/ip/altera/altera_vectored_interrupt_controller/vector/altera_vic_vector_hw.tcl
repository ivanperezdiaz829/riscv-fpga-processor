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


# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_vic_vector
# | 
set_module_property NAME altera_vic_vector
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Processor Additions"
set_module_property DISPLAY_NAME "VIC Vector Block"
set_module_property TOP_LEVEL_HDL_FILE altera_vic_vector.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_vic_vector
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_vic_vector.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DAISY_CHAIN_ENABLE INTEGER 0
set_parameter_property DAISY_CHAIN_ENABLE DISPLAY_NAME DAISY_CHAIN_ENABLE
set_parameter_property DAISY_CHAIN_ENABLE UNITS None
set_parameter_property DAISY_CHAIN_ENABLE DISPLAY_HINT boolean
set_parameter_property DAISY_CHAIN_ENABLE AFFECTS_ELABORATION true
set_parameter_property DAISY_CHAIN_ENABLE AFFECTS_GENERATION false
set_parameter_property DAISY_CHAIN_ENABLE IS_HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1

add_interface clk_reset reset end
add_interface_port clk_reset reset_n reset_n Input 1
set_interface_property clk_reset associatedClock clk

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point in
# | 
add_interface in avalon_streaming end
set_interface_property in errorDescriptor ""
set_interface_property in maxChannel 0
set_interface_property in readyLatency 0

set_interface_property in ASSOCIATED_CLOCK clk
set_interface_property in ENABLED true

add_interface_port in in_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point dc
# | 
add_interface dc avalon_streaming end
set_interface_property dc errorDescriptor ""
set_interface_property dc maxChannel 0
set_interface_property dc readyLatency 0

set_interface_property dc ASSOCIATED_CLOCK clk

add_interface_port dc dc_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point control
# | 
add_interface control avalon_streaming end
set_interface_property control errorDescriptor ""
set_interface_property control maxChannel 0
set_interface_property control readyLatency 0

set_interface_property control ASSOCIATED_CLOCK clk
set_interface_property control ENABLED true

add_interface_port control control_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point status
# | 
add_interface status avalon_streaming start
set_interface_property status errorDescriptor ""
set_interface_property status maxChannel 0
set_interface_property status readyLatency 0

set_interface_property status ASSOCIATED_CLOCK clk
set_interface_property status ENABLED true

add_interface_port status status_valid valid Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point out
# | 
add_interface out avalon_streaming start
set_interface_property out errorDescriptor ""
set_interface_property out maxChannel 0
set_interface_property out readyLatency 0

set_interface_property out ASSOCIATED_CLOCK clk
set_interface_property out ENABLED true

add_interface_port out out_valid valid Output 1
# | 
# +-----------------------------------


proc elaborate {} {

   set dc_enable [get_parameter_value "DAISY_CHAIN_ENABLE"]

   # Set Port Widths
   # | connection point in
   set_interface_property in symbolsPerBeat 1
   set_interface_property in dataBitsPerSymbol 19
   add_interface_port in in_data data Input 19

   # | connection point dc
   set_interface_property dc symbolsPerBeat 1
   set_interface_property dc dataBitsPerSymbol 32
   add_interface_port dc dc_data data Input 32

   # | connection point control
   set_interface_property control symbolsPerBeat 1
   set_interface_property control dataBitsPerSymbol 35
   add_interface_port control control_data data Input 35

   # | connection point status
   set_interface_property status symbolsPerBeat 1
   set_interface_property status dataBitsPerSymbol 38
   add_interface_port status status_data data Output 38

   # | connection point out
   set_interface_property out symbolsPerBeat 1
   set_interface_property out dataBitsPerSymbol 45
   add_interface_port out out_data data Output 45

   # Enable/Disable Interfaces
   # | connection point dc
   if {$dc_enable == 0} {
      set_interface_property dc ENABLED false
   } else {
      set_interface_property dc ENABLED true
   }
}

