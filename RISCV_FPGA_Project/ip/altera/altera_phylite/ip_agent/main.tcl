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


package provide altera_phylite::ip_agent::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_phylite::ip_top::exports

namespace eval ::altera_phylite::ip_agent::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*

}


proc ::altera_phylite::ip_agent::main::create_parameters {} {
   
   ::altera_phylite::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property PHYLITE_NUM_GROUPS                  HDL_PARAMETER true
   

   add_user_param     AGENT_GROUP_INDEX                     integer   0                    {0:11}

   add_derived_param  "AGENT_INDEX"                   integer    0        false
   add_derived_param  "AGENT_PIN_TYPE"                string     ""       false
   add_derived_param  "AGENT_PIN_WIDTH"               integer    0        false
   add_derived_param  "AGENT_DDR_SDR_MODE"            string     ""       false
   add_derived_param  "AGENT_USE_DIFF_STROBE"         boolean    false    false
   add_derived_param  "AGENT_READ_LATENCY"            integer    0        false
   add_derived_param  "AGENT_CAPTURE_PHASE_SHIFT"     integer    0        false
   add_derived_param  "AGENT_WRITE_LATENCY"           integer    0        false
   add_derived_param  "AGENT_USE_OUTPUT_STROBE"       boolean    false    false
   add_derived_param  "AGENT_OUTPUT_STROBE_PHASE"     integer    0        false

   set_parameter_property "AGENT_INDEX"                HDL_PARAMETER true
   set_parameter_property "AGENT_PIN_TYPE"             HDL_PARAMETER true
   set_parameter_property "AGENT_PIN_WIDTH"            HDL_PARAMETER true
   set_parameter_property "AGENT_DDR_SDR_MODE"         HDL_PARAMETER true
   set_parameter_property "AGENT_USE_DIFF_STROBE"      HDL_PARAMETER true
   set_parameter_property "AGENT_READ_LATENCY"         HDL_PARAMETER true
   set_parameter_property "AGENT_CAPTURE_PHASE_SHIFT"  HDL_PARAMETER true
   set_parameter_property "AGENT_WRITE_LATENCY"        HDL_PARAMETER true
   set_parameter_property "AGENT_USE_OUTPUT_STROBE"    HDL_PARAMETER true
   set_parameter_property "AGENT_OUTPUT_STROBE_PHASE"  HDL_PARAMETER true

   return 1
}

proc ::altera_phylite::ip_agent::main::elaboration_callback {} {

   set agent_idx [get_parameter_value AGENT_GROUP_INDEX]

   _elaborate_mem_cmd_interface
   _elaborate_mem_cmd_next_interface
   _elaborate_io_interface
   _elaborate_side_interface
   _elaborate_side_next_interface

   set_parameter_value "AGENT_INDEX"                 $agent_idx
   set_parameter_value "AGENT_PIN_TYPE"              [get_parameter_value "GROUP_${agent_idx}_PIN_TYPE"           ]
   set_parameter_value "AGENT_PIN_WIDTH"             [get_parameter_value "GROUP_${agent_idx}_PIN_WIDTH"          ]
   set_parameter_value "AGENT_DDR_SDR_MODE"          [get_parameter_value "GROUP_${agent_idx}_DDR_SDR_MODE"       ]
   set_parameter_value "AGENT_USE_DIFF_STROBE"       [get_parameter_value "GROUP_${agent_idx}_USE_DIFF_STROBE"    ]
   set_parameter_value "AGENT_READ_LATENCY"          [get_parameter_value "GROUP_${agent_idx}_READ_LATENCY"       ]
   set_parameter_value "AGENT_CAPTURE_PHASE_SHIFT"   [get_parameter_value "GROUP_${agent_idx}_CAPTURE_PHASE_SHIFT"]
   set_parameter_value "AGENT_WRITE_LATENCY"         [get_parameter_value "GROUP_${agent_idx}_WRITE_LATENCY"      ]
   set_parameter_value "AGENT_USE_OUTPUT_STROBE"     [get_parameter_value "GROUP_${agent_idx}_USE_OUTPUT_STROBE"  ]
   set_parameter_value "AGENT_OUTPUT_STROBE_PHASE"   [get_parameter_value "GROUP_${agent_idx}_OUTPUT_STROBE_PHASE"]

   return 1
}

proc ::altera_phylite::ip_agent::main::sim_vhdl_fileset_callback {top_level} {
  
   set rtl_only 1
   set encrypted 1   
   
   set non_encryp_simulators [::altera_emif::util::hwtcl_utils::get_simulator_attributes 1]

   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]

      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name] PATH $file_path $non_encryp_simulators

      add_fileset_file [file join mentor $file_name] [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH [file join mentor $file_path] {MENTOR_SPECIFIC}
   }   
}

proc ::altera_phylite::ip_agent::main::sim_verilog_fileset_callback {top_level} {
   
   set rtl_only 1
   set encrypted 0   
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }   
}

proc ::altera_phylite::ip_agent::main::quartus_synth_fileset_callback {top_level} {
   
   set rtl_only 0
   set encrypted 0
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}



proc ::altera_phylite::ip_agent::main::_generate_verilog_fileset {} {

   set file_list [list \
      rtl/phylite_agent.sv \
   ]
 
   return $file_list
}

proc ::altera_phylite::ip_agent::main::_elaborate_io_interface {} {
   set grp_idx [get_parameter_value AGENT_GROUP_INDEX]

   set pin_type        [get_parameter_value  "GROUP_${grp_idx}_PIN_TYPE"          ]
   set pin_width       [get_parameter_value  "GROUP_${grp_idx}_PIN_WIDTH"         ]
   set use_diff_strobe [get_parameter_value  "GROUP_${grp_idx}_USE_DIFF_STROBE"   ]
   set use_out_strobe  [get_parameter_value  "GROUP_${grp_idx}_USE_OUTPUT_STROBE" ]

   set num_strobes 1
   
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 && [string compare -nocase $use_out_strobe "false"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $use_diff_strobe "true"] == 0} {
      set num_strobes 2
   }

   set io_interface "io_interface_conduit_end"
   add_interface $io_interface conduit end
   set_interface_property $io_interface ENABLED true
   if {[string compare -nocase $pin_type "OUTPUT"] == 0} {
      add_interface_port $io_interface data_in data Input $pin_width
 
      if {$num_strobes > 0} {
         add_interface_port $io_interface strobe_in strobe Input 1
      }
      if {$num_strobes == 2} {
         add_interface_port $io_interface strobe_in_n strobe_n Input 1
      }
   } elseif {[string compare -nocase $pin_type "INPUT"] == 0} {
      add_interface_port $io_interface data_out data Output $pin_width
 
      add_interface_port $io_interface strobe_out strobe Output 1
      if {$num_strobes == 2} {
         add_interface_port $io_interface strobe_out_n strobe_n Output 1
      }
   } else { 
      add_interface_port $io_interface data_io data Bidir $pin_width
 
      add_interface_port $io_interface strobe_io strobe Bidir 1
      if {$num_strobes == 2} {
         add_interface_port $io_interface strobe_io_n strobe_n Bidir 1
      }
   }
}

proc ::altera_phylite::ip_agent::main::_elaborate_side_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]

   set side_interface "side_interface_conduit_end"
   add_interface $side_interface conduit end
   set_interface_property $side_interface ENABLED true

   add_interface_port $side_interface side_write_in           side_write          Input  1
   add_interface_port $side_interface side_read_in            side_read           Input  1
   add_interface_port $side_interface side_write_data_in      side_write_data     Input  48*2
   add_interface_port $side_interface side_read_data_out      side_read_data      Output 48*2
   add_interface_port $side_interface side_readdata_valid_out side_readdata_valid Output 1
   add_interface_port $side_interface side_readaddr_in        side_readaddr       Input  3
   add_interface_port $side_interface agent_select_in         agent_select        Input  $num_grps
}

proc ::altera_phylite::ip_agent::main::_elaborate_side_next_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]

   set side_interface "side_next_interface_conduit_end"
   add_interface $side_interface conduit end
   set_interface_property $side_interface ENABLED true

   add_interface_port $side_interface side_write_out          side_write          Output  1
   add_interface_port $side_interface side_read_out           side_read           Output  1
   add_interface_port $side_interface side_write_data_out     side_write_data     Output  48*2
   add_interface_port $side_interface side_read_data_in       side_read_data      Input 48*2
   add_interface_port $side_interface side_readdata_valid_in  side_readdata_valid Input 1
   add_interface_port $side_interface side_readaddr_out       side_readaddr       Output  3
   add_interface_port $side_interface agent_select_out        agent_select        Output  $num_grps
}

proc ::altera_phylite::ip_agent::main::_elaborate_mem_cmd_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"]

   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }

   set cmd_interface "mem_cmd_interface_conduit_end"
   add_interface $cmd_interface conduit end
   set_interface_property $cmd_interface ENABLED true
   add_interface_port $cmd_interface mem_cmd_in     data   Input 3+${num_grps}
   add_interface_port $cmd_interface mem_cmd_clk_in strobe Input 1

}

proc ::altera_phylite::ip_agent::main::_elaborate_mem_cmd_next_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"]

   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }

   set cmd_interface "mem_cmd_next_interface_conduit_end"
   add_interface $cmd_interface conduit end
   set_interface_property $cmd_interface ENABLED true
   add_interface_port $cmd_interface mem_cmd_out     data   Output 3+${num_grps}
   add_interface_port $cmd_interface mem_cmd_clk_out strobe Output 1

}

proc ::altera_phylite::ip_agent::main::_init {} {
}

::altera_phylite::ip_agent::main::_init
