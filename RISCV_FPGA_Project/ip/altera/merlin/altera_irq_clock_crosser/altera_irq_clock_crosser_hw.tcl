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


# $Id: //acds/rel/13.1/ip/merlin/altera_irq_clock_crosser/altera_irq_clock_crosser_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact sopc 9.1

#  -----------------------------------
# | altera_irq_mapper
#  -----------------------------------
set_module_property NAME altera_irq_clock_crosser
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Merlin IRQ Clock Crosser"
set_module_property DESCRIPTION "Synchronizes interrupt senders and receivers that are in different clock domains."
set_module_property AUTHOR "Altera Corporation"
set_module_property EDITABLE false
set_module_property TOP_LEVEL_HDL_FILE altera_irq_clock_crosser.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_irq_clock_crosser
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

add_file altera_irq_clock_crosser.sv {SYNTHESIS SIMULATION}

#  -----------------------------------
# | Parameters
#  -----------------------------------
add_parameter IRQ_WIDTH INTEGER 1  "Width of the irq signal for both the sender and receiver interfaces."
set_parameter_property IRQ_WIDTH DISPLAY_NAME {IRQ width}
set_parameter_property IRQ_WIDTH ALLOWED_RANGES 1:64
set_parameter_property IRQ_WIDTH HDL_PARAMETER true
set_parameter_property IRQ_WIDTH DESCRIPTION {Width of the irq signal for both the sender and receiver interfaces.}

#  -----------------------------------
# | Interfaces callback
#  -----------------------------------

# Clock interfaces
add_interface receiver_clk clock end
add_interface_port receiver_clk receiver_clk clk Input 1

add_interface sender_clk clock end
add_interface_port sender_clk sender_clk clk Input 1

# Reset interfaces
add_interface receiver_clk_reset reset end
add_interface_port receiver_clk_reset receiver_reset reset Input 1
set_interface_property receiver_clk_reset associatedClock receiver_clk

add_interface sender_clk_reset reset end
add_interface_port sender_clk_reset sender_reset reset Input 1
set_interface_property sender_clk_reset associatedClock sender_clk

# Interrupt Receiver interface
add_interface "receiver" interrupt start
set_interface_property "receiver" irqScheme         INDIVIDUAL_REQUESTS
set_interface_property "receiver" ASSOCIATED_CLOCK  receiver_clk
add_interface_port "receiver" "receiver_irq" irq input 1
set_port_property receiver_irq width_expr IRQ_WIDTH

# Interrupt Sender Interface
add_interface "sender" interrupt end
set_interface_property "sender" irqScheme         INDIVIDUAL_REQUESTS
set_interface_property "sender" ASSOCIATED_CLOCK  sender_clk
add_interface_port "sender" "sender_irq" irq output 1
set_port_property sender_irq width_expr IRQ_WIDTH


