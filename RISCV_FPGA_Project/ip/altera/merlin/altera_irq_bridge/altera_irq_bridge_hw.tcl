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


#  -----------------------------------
# | altera_irq_bridge
#  -----------------------------------

package require -exact sopc 10.0

set_module_property NAME altera_irq_bridge
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "IRQ Bridge"
set_module_property DESCRIPTION "Allows you to route interrupt wires between Qsys subsystems."
set_module_property AUTHOR "Altera Corporation"
set_module_property EDITABLE FALSE
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property TOP_LEVEL_HDL_FILE altera_irq_bridge.v
set_module_property TOP_LEVEL_HDL_MODULE altera_irq_bridge
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

# ----------------------------------
# | files
# ----------------------------------
add_file altera_irq_bridge.v {SYNTHESIS SIMULATION}

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter IRQ_WIDTH integer 32
set_parameter_property IRQ_WIDTH DISPLAY_NAME {IRQ signal width}
set_parameter_property IRQ_WIDTH ALLOWED_RANGES "1:32"
set_parameter_property IRQ_WIDTH affects_elaboration true
set_parameter_property IRQ_WIDTH HDL_PARAMETER true
set_parameter_property IRQ_WIDTH DESCRIPTION {Width of the IRQ signal}

add_parameter IRQ_N integer 0
set_parameter_property IRQ_N DISPLAY_NAME {IRQ signal polarity}
set_parameter_property IRQ_N affects_elaboration true
set_parameter_property IRQ_N ALLOWED_RANGES {"0:Active high" "1:Active low"}
#set_parameter_property IRQ_N HDL_PARAMETER true
set_parameter_property IRQ_N DESCRIPTION {Polarity of the IRQ signal}

# ----------------------------------
# | Connection points
#-----------------------------------

add_interface "clk" clock end
add_interface_port "clk" clk clk input 1

add_interface "receiver_irq" interrupt receiver
set_interface_property "receiver_irq" associatedClock "clk"

add_interface clk_reset reset end
add_interface_port clk_reset reset reset Input 1
set_interface_property clk_reset associatedClock clk

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------

proc elaborate {} {
    set irq_n [get_parameter_value IRQ_N]

	set_interface_property "receiver_irq" irqScheme individualRequests

	set irq_width [get_parameter_value IRQ_WIDTH]
	
	if { $irq_n == 1 } {
	    add_interface_port "receiver_irq" receiver_irq irq_n input $irq_width
        set_port_property receiver_irq vhdl_type std_logic_vector
	    for { set s 0 } { $s < 32 } { incr s } {
            add_interface "sender${s}_irq" interrupt sender
            add_interface_port "sender${s}_irq" sender${s}_irq irq_n output 1
	        set_interface_property "sender${s}_irq" associatedClock "clk"

			if { $s < $irq_width} {
			} else {
				#set_port_property sender${s}_irq termination 1
				set_interface_property sender${s}_irq ENABLED false
			}
	    }
	} else {
	    	add_interface_port "receiver_irq" receiver_irq irq input $irq_width
            set_port_property receiver_irq vhdl_type std_logic_vector
	        for { set s 0 } { $s < 32 } { incr s } {
        	    add_interface "sender${s}_irq" interrupt sender
	            add_interface_port "sender${s}_irq" sender${s}_irq irq output 1
		        set_interface_property "sender${s}_irq" associatedClock "clk"
	            if { $s < $irq_width} {
        	    } else {
                	#set_port_property sender${s}_irq termination 0
			        set_interface_property sender${s}_irq ENABLED false
            	    }
        	}
	}
	

}

# +-----------------------------------
# | Validation callback
# +-----------------------------------
proc validate {} {
	set irq_width [get_parameter_value IRQ_WIDTH]
	if {$irq_width < 1} {
	   send_message error "IRQ_WIDTH < 0"
	}
}
