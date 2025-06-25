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


package require -exact qsys 12.1

# 
# module altera_eth_tse_conduit_fanout
# 
set_module_property NAME altera_eth_tse_conduit_fanout
set_module_property VERSION "13.1"
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false 
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter NUM_FANOUT INTEGER 2
set_parameter_property NUM_FANOUT DISPLAY_NAME "Number of fanout interfaces"
set_parameter_property NUM_FANOUT ALLOWED_RANGES 1:64
set_parameter_property NUM_FANOUT DESCRIPTION {Number of fanout interfaces}

add_parameter PORT_LIST STRING_LIST "dummy_0,1 dummy_1,5"
set_parameter_property PORT_LIST DISPLAY_NAME "Port list: Role,Width"

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
    
   # Collect parameter values into local variables
   foreach var [ get_parameters ] {
      set $var [ get_parameter_value $var ]
   }

   set interface_port export

   # Input Interface
   add_interface "sig_input" conduit end
   foreach line $PORT_LIST {
      set port_info [split $line ","]
      set role [lindex $port_info 0]
      set width [lindex $port_info 1]
      
      add_interface_port "sig_input" $role\_in $role Input $width
   }

   # Output fanout Interfaces
   for { set s 0 } { $s < $NUM_FANOUT } { incr s } {
      add_interface "sig_fanout$s" conduit end

      foreach line $PORT_LIST {
         set port_info [split $line ","]
         set role [lindex $port_info 0]
         set width [lindex $port_info 1]
      
         add_interface_port "sig_fanout${s}" $role\_out${s} $role Output $width
         set_port_property "$role\_out${s}" DRIVEN_BY "$role\_in"
      }
   }
}
