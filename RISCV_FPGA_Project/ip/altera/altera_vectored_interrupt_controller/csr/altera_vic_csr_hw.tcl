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
# | module altera_vic_csr
# | 
set_module_property NAME altera_vic_csr
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Processor Additions"
set_module_property DISPLAY_NAME "VIC CSR Block"
set_module_property TOP_LEVEL_HDL_FILE altera_vic_csr.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_vic_csr
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_vic_csr.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUMBER_OF_INT_PORTS INTEGER 32
set_parameter_property NUMBER_OF_INT_PORTS DISPLAY_NAME NUMBER_OF_INT_PORTS
set_parameter_property NUMBER_OF_INT_PORTS UNITS None
set_parameter_property NUMBER_OF_INT_PORTS ALLOWED_RANGES 1:32
set_parameter_property NUMBER_OF_INT_PORTS DISPLAY_HINT ""
set_parameter_property NUMBER_OF_INT_PORTS AFFECTS_GENERATION false
set_parameter_property NUMBER_OF_INT_PORTS IS_HDL_PARAMETER true

add_parameter RRS_WIDTH INTEGER 6
set_parameter_property RRS_WIDTH DISPLAY_NAME RRS_WIDTH
set_parameter_property RRS_WIDTH UNITS None
set_parameter_property RRS_WIDTH ALLOWED_RANGES 1:6
set_parameter_property RRS_WIDTH DISPLAY_HINT ""
set_parameter_property RRS_WIDTH AFFECTS_GENERATION false
set_parameter_property RRS_WIDTH IS_HDL_PARAMETER true

add_parameter RIL_WIDTH INTEGER 6
set_parameter_property RIL_WIDTH DISPLAY_NAME RIL_WIDTH
set_parameter_property RIL_WIDTH UNITS None
set_parameter_property RIL_WIDTH ALLOWED_RANGES 1:6
set_parameter_property RIL_WIDTH DISPLAY_HINT ""
set_parameter_property RIL_WIDTH AFFECTS_GENERATION false
set_parameter_property RIL_WIDTH IS_HDL_PARAMETER true

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
# | connection point i1
# | 
add_interface i1 interrupt start
set_interface_property i1 irqScheme INDIVIDUAL_REQUESTS

set_interface_property i1 ASSOCIATED_CLOCK clk
# | 
# +-----------------------------------

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s1
# | 
add_interface s1 avalon end
set_interface_property s1 addressAlignment DYNAMIC
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 isMemoryDevice false
set_interface_property s1 isNonVolatileStorage false
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 printableDevice false
set_interface_property s1 readLatency 4
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 writeWaitTime 0

set_interface_property s1 ASSOCIATED_CLOCK clk

add_interface_port s1 avs_s1_read read Input 1
add_interface_port s1 avs_s1_write write Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point dc_in
# |
add_interface dc_in avalon_streaming end
set_interface_property dc_in errorDescriptor ""
set_interface_property dc_in maxChannel 0
set_interface_property dc_in readyLatency 0

set_interface_property dc_in ASSOCIATED_CLOCK clk

add_interface_port dc_in dc_in_valid valid Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point dc_out
# |
add_interface dc_out avalon_streaming start
set_interface_property dc_out errorDescriptor ""
set_interface_property dc_out maxChannel 0
set_interface_property dc_out readyLatency 0

set_interface_property dc_out ASSOCIATED_CLOCK clk

add_interface_port dc_out dc_out_valid valid Output 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection points out0 - out32
# |
for {set i 0} {$i < 33} {incr i} {
   set name "out$i"
   add_interface $name avalon_streaming start
   set_interface_property $name errorDescriptor ""
   set_interface_property $name maxChannel 0
   set_interface_property $name readyLatency 0

   set_interface_property $name ASSOCIATED_CLOCK clk

   add_interface_port $name ${name}_valid valid Output 1
}
# |
# +-----------------------------------

# +-----------------------------------
# | connection point control
# |
add_interface control avalon_streaming start
set_interface_property control errorDescriptor ""
set_interface_property control maxChannel 0
set_interface_property control readyLatency 0

set_interface_property control ASSOCIATED_CLOCK clk

add_interface_port control control_valid valid Output 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point status
# |
add_interface status avalon_streaming end
set_interface_property status errorDescriptor ""
set_interface_property status maxChannel 0
set_interface_property status readyLatency 0

set_interface_property status ASSOCIATED_CLOCK clk

add_interface_port status status_valid valid Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface clk_reset reset end
add_interface_port clk_reset reset_n reset_n Input 1
set_interface_property clk_reset associatedClock clk

# | 
# +-----------------------------------


proc elaborate {} {

   set num_ports [get_parameter_value "NUMBER_OF_INT_PORTS"]
   set dc_enable [get_parameter_value "DAISY_CHAIN_ENABLE"]

   # Set Port Widths
   # | connection point i1
   add_interface_port i1 inr_i1_irq irq Input $num_ports

   # | connection point s1
   add_interface_port s1 avs_s1_address address Input 8
   add_interface_port s1 avs_s1_writedata writedata Input 32
   add_interface_port s1 avs_s1_readdata readdata Output 32

   # | connection point dc_in
   set_interface_property dc_in symbolsPerBeat 1
   set_interface_property dc_in dataBitsPerSymbol 45
   add_interface_port dc_in dc_in_data data Input 45

   # | connection point dc_out
   set_interface_property dc_out symbolsPerBeat 1
   set_interface_property dc_out dataBitsPerSymbol 32
   add_interface_port dc_out dc_out_data data Output 32

   # | connection points out0 - out32
   for {set j 0} {$j < 33} {incr j} {
      set name "out$j"
      set_interface_property $name symbolsPerBeat 1
      set_interface_property $name dataBitsPerSymbol 19
      add_interface_port $name ${name}_data data Output 19
   }

   # | connection point control
   set_interface_property control symbolsPerBeat 1
   set_interface_property control dataBitsPerSymbol 35
   add_interface_port control control_data data Output 35

   # | connection point status
   set_interface_property status symbolsPerBeat 1
   set_interface_property status dataBitsPerSymbol 38
   add_interface_port status status_data data Input 38


   # Enable/Disable Interfaces
   # | connection point i1
   set_interface_property i1 ENABLED true

   # | connection point s1
   set_interface_property s1 ENABLED true

   # | connection point dc_in and dc_out
   if {$dc_enable == 0} {
      set_interface_property dc_in  ENABLED false
      set_interface_property dc_out ENABLED false
   } else {
      set_interface_property dc_in  ENABLED true
      set_interface_property dc_out ENABLED true
   }

   # | connection points out0 - out32
   for {set k 0} {$k < 33} {incr k} {
      set name "out$k"

      if {$k < ($num_ports + $dc_enable)} {
         set_interface_property $name ENABLED true
      } else {
         set_interface_property $name ENABLED false
      }
   }

   # | connection point control
   set_interface_property control ENABLED true

   # | connection point status
   set_interface_property status ENABLED true

   # | connection point clk
   set_interface_property clk ENABLED true
}

