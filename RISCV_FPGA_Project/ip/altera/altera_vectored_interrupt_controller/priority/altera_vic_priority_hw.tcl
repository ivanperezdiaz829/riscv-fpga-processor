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
# | module altera_vic_priority
# | 
set_module_property NAME altera_vic_priority
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Processor Additions"
set_module_property DISPLAY_NAME "VIC Priority Block"
set_module_property TOP_LEVEL_HDL_FILE altera_vic_priority.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_vic_priority
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_vic_priority.sv {SYNTHESIS SIMULATION}
add_file altera_vic_compare2.sv {SYNTHESIS SIMULATION}
add_file altera_vic_compare4.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUMBER_OF_INT_PORTS INTEGER 32
set_parameter_property NUMBER_OF_INT_PORTS DISPLAY_NAME NUMBER_OF_INT_PORTS
set_parameter_property NUMBER_OF_INT_PORTS UNITS None
set_parameter_property NUMBER_OF_INT_PORTS ALLOWED_RANGES 1:33
set_parameter_property NUMBER_OF_INT_PORTS DISPLAY_HINT ""
set_parameter_property NUMBER_OF_INT_PORTS AFFECTS_GENERATION false
set_parameter_property NUMBER_OF_INT_PORTS IS_HDL_PARAMETER true

add_parameter PRIORITY_WIDTH INTEGER 6
set_parameter_property PRIORITY_WIDTH DISPLAY_NAME PRIORITY_WIDTH
set_parameter_property PRIORITY_WIDTH UNITS None
set_parameter_property PRIORITY_WIDTH ALLOWED_RANGES 1:6
set_parameter_property PRIORITY_WIDTH DISPLAY_HINT ""
set_parameter_property PRIORITY_WIDTH AFFECTS_GENERATION false
set_parameter_property PRIORITY_WIDTH IS_HDL_PARAMETER true

add_parameter DATA_WIDTH INTEGER 19
set_parameter_property DATA_WIDTH DISPLAY_NAME DATA_WIDTH
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES 1:64
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH IS_HDL_PARAMETER true
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
# | connection points in0 - in32
# |
for {set i 0} {$i < 33} {incr i} {
   set name "in$i"
   add_interface $name avalon_streaming end
   set_interface_property $name errorDescriptor ""
   set_interface_property $name maxChannel 0
   set_interface_property $name readyLatency 0

   set_interface_property $name ASSOCIATED_CLOCK clk

   add_interface_port $name ${name}_valid valid Input 1
}
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

add_interface_port out pri_valid valid Output 1
# | 
# +-----------------------------------


proc elaborate {} {

   set num_ports [get_parameter_value "NUMBER_OF_INT_PORTS"]
   set dw_value  [get_parameter_value "DATA_WIDTH"]

   # Set Port Widths
   # | connection points in0 - in32
   for {set j 0} {$j < 33} {incr j} {
      set name "in$j"
      set_interface_property $name symbolsPerBeat 1
      set_interface_property $name dataBitsPerSymbol $dw_value
      add_interface_port $name ${name}_data data Input $dw_value
   }

   # | connection point out
   set_interface_property out symbolsPerBeat 1
   set_interface_property out dataBitsPerSymbol $dw_value
   add_interface_port out pri_data data Output $dw_value


   # Enable/Disable Interfaces
   # | connection points in0 - in32
   for {set k 0} {$k < 33} {incr k} {
      set name "in$k"

      if {$k < $num_ports} {
         set_interface_property $name ENABLED true
      } else {
         set_interface_property $name ENABLED false
      }
   }

   # | connection point out
   set_interface_property out ENABLED true

   # | connection point clk
   set_interface_property clk ENABLED true
}

