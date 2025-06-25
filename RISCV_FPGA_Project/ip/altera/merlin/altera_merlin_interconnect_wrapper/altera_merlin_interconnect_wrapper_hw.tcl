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


#+-------------------------------------------------------
#| Altera Merlin Interconnect Wrapper
#+-------------------------------------------------------
package require qsys 13.1

#+-------------------------------------------------------
#| Module Properties
#+-------------------------------------------------------

set_module_property NAME altera_merlin_interconnect_wrapper
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Interconnect Wrapper"
set_module_property DESCRIPTION "Interconnect Wrapper"
set_module_property AUTHOR "Altera Corporation"
set_module_property HIDE_FROM_SOPC true
set_module_property COMPOSITION_CALLBACK compose
set_module_property INTERNAL true

set_module_property ANALYZE_HDL FALSE

add_parameter COMPOSE_CONTENTS STRING ""
set_parameter_property COMPOSE_CONTENTS DISPLAY_NAME "Composed callback contents"
set_parameter_property COMPOSE_CONTENTS UNITS None
set_parameter_property COMPOSE_CONTENTS AFFECTS_ELABORATION true

proc compose { } {

    set compose_contents [ get_parameter_value COMPOSE_CONTENTS ]
    eval $compose_contents

}

