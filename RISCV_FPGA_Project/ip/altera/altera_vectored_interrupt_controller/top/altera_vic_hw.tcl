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
# | module altera_vic
# |
set_module_property NAME altera_vic
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Processor Additions"
set_module_property DISPLAY_NAME "Vectored Interrupt Controller"
set_module_property DESCRIPTION "Vectored Interrupt Controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property VALIDATION_CALLBACK validate
set_module_property SIMULATION_MODEL_IN_VHDL true
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter NUMBER_OF_INT_PORTS INTEGER 8
set_parameter_property NUMBER_OF_INT_PORTS DISPLAY_NAME "Number of Interrupts"
set_parameter_property NUMBER_OF_INT_PORTS ALLOWED_RANGES 1:32
set_parameter_property NUMBER_OF_INT_PORTS DESCRIPTION "Number of Interrupt Inputs supported by the IRQ interface"

add_parameter RIL_WIDTH INTEGER 4
set_parameter_property RIL_WIDTH DISPLAY_NAME "Requested Interrupt Level (RIL) Width"
set_parameter_property RIL_WIDTH ALLOWED_RANGES 1:6
set_parameter_property RIL_WIDTH DESCRIPTION "Number of Bits used to represent the Requested Interrupt Level (RIL)"

add_parameter DAISY_CHAIN_ENABLE INTEGER 0
set_parameter_property DAISY_CHAIN_ENABLE DISPLAY_NAME DAISY_CHAIN_ENABLE
set_parameter_property DAISY_CHAIN_ENABLE DISPLAY_HINT boolean
set_parameter_property DAISY_CHAIN_ENABLE DESCRIPTION "Enable the Daisy-Chain input port"
# |
# +-----------------------------------

# +-----------------------------------
# | simulation files
# |
add_file "../csr/altera_vic_csr.sv" { SIMULATION }
add_file "../vector/altera_vic_vector.sv" { SIMULATION }
add_file "../priority/altera_vic_priority.sv" { SIMULATION }
add_file "../priority/altera_vic_compare2.sv" { SIMULATION }
add_file "../priority/altera_vic_compare4.sv" { SIMULATION }
# |
# +-----------------------------------


proc compose {} {

   set num_ports [get_parameter_value NUMBER_OF_INT_PORTS]
   set ril_value [get_parameter_value RIL_WIDTH]
   set dc_enable [get_parameter_value DAISY_CHAIN_ENABLE]
   set pri_ports [expr $num_ports + $dc_enable]

   if {$pri_ports >= 2} {
      set delay_clks 1;
   }

   if {$pri_ports >= 5} {
      set delay_clks 2;
   }

   if {$pri_ports >= 17} {
      set delay_clks 3;
   }


#  Clock Source 
   add_interface clk clock end
   add_instance clk altera_clock_bridge
   set_interface_property clk export_of clk.in_clk

   add_interface clk_reset reset end
   add_instance reset altera_reset_bridge
   set_interface_property clk_reset export_of reset.in_reset

   add_connection clk.out_clk reset.clk


#  CSR Block with Daisy-Chain 
   add_instance vic_csr altera_vic_csr
   set_instance_parameter vic_csr NUMBER_OF_INT_PORTS $num_ports
   set_instance_parameter vic_csr RIL_WIDTH $ril_value
   set_instance_parameter vic_csr RRS_WIDTH 6
   set_instance_parameter vic_csr DAISY_CHAIN_ENABLE $dc_enable

#  Interrupt input port
   add_interface irq_input interrupt start
   set_interface_property irq_input export_of vic_csr.i1

   add_interface csr_access avalon end
   set_interface_property csr_access export_of vic_csr.s1

   if {$dc_enable == 1} {
      add_interface interrupt_controller_in avalon_streaming end
      set_interface_property interrupt_controller_in export_of vic_csr.dc_in
      set_interface_property interrupt_controller_in ENABLED true
   }


#  Priority Block 
   add_instance vic_priority altera_vic_priority
   set_instance_parameter vic_priority NUMBER_OF_INT_PORTS $pri_ports
   set_instance_parameter vic_priority PRIORITY_WIDTH $ril_value
   set_instance_parameter vic_priority DATA_WIDTH 19


#  Avalon ST Delay 
   if {$dc_enable == 1} {
      add_instance dc_delay altera_avalon_st_delay
      set_instance_parameter dc_delay NUMBER_OF_DELAY_CLOCKS $delay_clks
      set_instance_parameter dc_delay DATA_WIDTH 32
      set_instance_parameter dc_delay BITS_PER_SYMBOL 32
      set_instance_parameter dc_delay USE_PACKETS 0
      set_instance_parameter dc_delay USE_CHANNEL 0
      set_instance_parameter dc_delay CHANNEL_WIDTH 1
      set_instance_parameter dc_delay USE_ERROR 0
      set_instance_parameter dc_delay ERROR_WIDTH 1
   }


#  Vector Block 
   add_instance vic_vector altera_vic_vector
   set_instance_parameter vic_vector DAISY_CHAIN_ENABLE $dc_enable

   add_interface interrupt_controller_out avalon_streaming start
   set_interface_property interrupt_controller_out export_of vic_vector.out


#  Connections
   add_connection clk.out_clk     vic_csr.clk
   add_connection clk.out_clk     vic_priority.clk
   add_connection clk.out_clk     vic_vector.clk

   for {set i 0} {$i < $pri_ports} {incr i} {
      add_connection vic_csr.out${i}/vic_priority.in${i}
   }

   if {$dc_enable == 1} {
      add_connection vic_csr.dc_out/dc_delay.in
      add_connection dc_delay.out/vic_vector.dc
      add_connection clk.out_clk     dc_delay.clk
      
      # EIC port identification for BSP tools
      set_interface_assignment interrupt_controller_in \
        embeddedsw.configuration.isInterruptControllerReceiver 1
      
      set_interface_assignment interrupt_controller_out \
        embeddedsw.configuration.transportsInterruptsFromReceivers \
          interrupt_controller_in
   }

   add_connection vic_priority.out/vic_vector.in

   add_connection vic_csr.control/vic_vector.control
   add_connection vic_vector.status vic_csr.status
   
   # EIC sender port identification for BSP tools
   set_interface_assignment interrupt_controller_out \
     embeddedsw.configuration.isInterruptControllerSender 1
}

# Get the VIC parameters that software cares about and export to the software
# build flow (for system.h C macros)
proc validate {} {  
   set_module_assignment embeddedsw.CMacro.NUMBER_OF_INT_PORTS \
      [get_parameter_value NUMBER_OF_INT_PORTS]
      
   set_module_assignment embeddedsw.CMacro.RIL_WIDTH \
      [get_parameter_value RIL_WIDTH]    
   
   set_module_assignment embeddedsw.CMacro.DAISY_CHAIN_ENABLE \
     [get_parameter_value DAISY_CHAIN_ENABLE] 
}

