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


package provide altera_phylite::ip_sim_ctrl::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_phylite::ip_top::exports

namespace eval ::altera_phylite::ip_sim_ctrl::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*

}


proc ::altera_phylite::ip_sim_ctrl::main::create_parameters {} {
   
   ::altera_phylite::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property PHYLITE_NUM_GROUPS                  HDL_PARAMETER true
   set_parameter_property PHYLITE_RATE_ENUM                   HDL_PARAMETER true
   set_parameter_property PHYLITE_USE_DYNAMIC_RECONFIGURATION HDL_PARAMETER true
   
   for { set i 0 } { $i < 12 } {incr i } {
      set_parameter_property  "GROUP_${i}_PIN_TYPE"              HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_PIN_WIDTH"             HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_DDR_SDR_MODE"          HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_USE_OUTPUT_STROBE"     HDL_PARAMETER true
   }

   return 1
}

proc ::altera_phylite::ip_sim_ctrl::main::elaboration_callback {} {

   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]

   add_interface core_clk_out_conduit_end conduit end
   set_interface_property core_clk_out_conduit_end ENABLED true
   add_interface_port core_clk_out_conduit_end core_clk core_clk Input 1

   add_interface start_conduit_end conduit end
   set_interface_property start_conduit_end ENABLED true
   add_interface_port start_conduit_end start start Input 1

   _elaborate_core_interface
   _elaborate_side_interface
   _elaborate_core_cmd_interface
   _elaborate_mem_cmd_interface

   return 1
}

proc ::altera_phylite::ip_sim_ctrl::main::sim_vhdl_fileset_callback {top_level} {
  
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

proc ::altera_phylite::ip_sim_ctrl::main::sim_verilog_fileset_callback {top_level} {
   
   set rtl_only 1
   set encrypted 0   
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }   
}

proc ::altera_phylite::ip_sim_ctrl::main::quartus_synth_fileset_callback {top_level} {
   
   set rtl_only 0
   set encrypted 0
   
   foreach file_path [_generate_verilog_fileset] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}



proc ::altera_phylite::ip_sim_ctrl::main::_generate_verilog_fileset {} {

   set file_list [list \
      rtl/phylite_sim_ctrl.sv \
   ]
 
   return $file_list
}

proc ::altera_phylite::ip_sim_ctrl::main::_elaborate_core_interface {} {

   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"                  ]

   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }

   add_interface sim_ctrl_conduit_end conduit end
   add_interface_port sim_ctrl_conduit_end oe_from_sim_ctrl        oe_from_sim_ctrl        Output 48*$rate_mult
   add_interface_port sim_ctrl_conduit_end data_from_sim_ctrl      data_from_sim_ctrl      Output 48*2*$rate_mult
   add_interface_port sim_ctrl_conduit_end data_to_sim_ctrl        data_to_sim_ctrl        Input  48*2*$rate_mult
   add_interface_port sim_ctrl_conduit_end rdata_en_from_sim_ctrl  rdata_en_from_sim_ctrl  Output $rate_mult
   add_interface_port sim_ctrl_conduit_end rdata_valid_to_sim_ctrl rdata_valid_to_sim_ctrl Input  $rate_mult
   add_interface_port sim_ctrl_conduit_end strobe_oe_from_sim_ctrl strobe_oe_from_sim_ctrl Output $rate_mult
   add_interface_port sim_ctrl_conduit_end grp_sel                 grp_sel                 Output $num_grps
}

proc ::altera_phylite::ip_sim_ctrl::main::_elaborate_side_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]

   set side_interface "side_interface_conduit_end"
   add_interface $side_interface conduit end
   set_interface_property $side_interface ENABLED true

   add_interface_port $side_interface side_write          side_write           Output 1
   add_interface_port $side_interface side_read           side_read            Output 1
   add_interface_port $side_interface side_write_data     side_write_data      Output 48*2
   add_interface_port $side_interface side_read_data      side_read_data       Input  48*2
   add_interface_port $side_interface side_readdata_valid side_readdata_valid  Input  1
   add_interface_port $side_interface side_readaddr       side_readaddr        Output 3
   add_interface_port $side_interface agent_select        agent_select         Output $num_grps

}

proc ::altera_phylite::ip_sim_ctrl::main::_elaborate_core_cmd_interface {} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"]

   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }

   set cmd_interface "core_cmd_interface_conduit_end"
   add_interface $cmd_interface conduit end
   set_interface_property $cmd_interface ENABLED true
   add_interface_port $cmd_interface core_cmd_out    data_out   Output [expr $rate_mult + $rate_mult + $rate_mult + [expr $num_grps*$rate_mult]]
   add_interface_port $cmd_interface core_cmd_out_oe data_oe    Output [expr $rate_mult + $rate_mult + $rate_mult + [expr $num_grps*$rate_mult]]
   add_interface_port $cmd_interface core_cmd_clk    strobe_out Output $rate_mult*2
   add_interface_port $cmd_interface core_cmd_clk_oe strobe_oe  Output $rate_mult
}

proc ::altera_phylite::ip_sim_ctrl::main::_elaborate_mem_cmd_interface {} {
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
   add_interface_port $cmd_interface mem_cmd_in  data   Input 3+${num_grps}
   add_interface_port $cmd_interface mem_cmd_clk strobe Input 1

}

proc ::altera_phylite::ip_sim_ctrl::main::_init {} {
}

::altera_phylite::ip_sim_ctrl::main::_init
