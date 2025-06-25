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


package provide altera_phylite::ip_driver::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::enum_defs
package require altera_phylite::ip_top::exports

namespace eval ::altera_phylite::ip_driver::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*

}


proc ::altera_phylite::ip_driver::main::create_parameters {} {
   
   ::altera_phylite::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property PHYLITE_NUM_GROUPS                  HDL_PARAMETER true
   set_parameter_property PHYLITE_RATE_ENUM                   HDL_PARAMETER true
   

   return 1
}

proc ::altera_phylite::ip_driver::main::elaboration_callback {} {

   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
 
   _elaborate_core_sim_ctrl_interface
 
   add_interface core_clk_in_conduit_end conduit end
   set_interface_property core_clk_in_conduit_end ENABLED true
   add_interface_port core_clk_in_conduit_end core_clk_in core_clk Input 1
 
   add_interface core_clk_out_conduit_end conduit end
   set_interface_property core_clk_out_conduit_end ENABLED true
   add_interface_port core_clk_out_conduit_end core_clk_out core_clk Output 1
 
   add_interface start_in_conduit_end conduit end
   set_interface_property start_in_conduit_end ENABLED true
   add_interface_port start_in_conduit_end start_in pll_locked Input 1
 
   add_interface start_out_conduit_end conduit end
   set_interface_property start_out_conduit_end ENABLED true
   add_interface_port start_out_conduit_end start_out start Output 1
 
   for { set i 0 } { $i < $num_grps } {incr i } {
      _elaborate_grp_core_interface $i
   }
 
   return 1
}

proc ::altera_phylite::ip_driver::main::sim_vhdl_fileset_callback {top_level} {
  
   set rtl_only 1
   set encrypted 1   
   
   set non_encryp_simulators [::altera_emif::util::hwtcl_utils::get_simulator_attributes 1]
 
   foreach file_path [_generate_vhdl_fileset $top_level] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
 
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name] PATH $file_path $non_encryp_simulators
 
      add_fileset_file [file join mentor $file_name] [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH [file join mentor $file_path] {MENTOR_SPECIFIC}
   }   
}

proc ::altera_phylite::ip_driver::main::sim_verilog_fileset_callback {top_level} {
   
   set rtl_only 1
   set encrypted 0   
   
   foreach file_path [_generate_verilog_fileset $top_level] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }   
}

proc ::altera_phylite::ip_driver::main::quartus_synth_fileset_callback {top_level} {
   
   set rtl_only 0
   set encrypted 0
   
   foreach file_path [_generate_verilog_fileset $top_level] {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}



proc ::altera_phylite::ip_driver::main::_generate_verilog_fileset {top_level} {

   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set param_declrs  [list]
   foreach param [get_parameters] {
      if {[get_parameter_property $param HDL_PARAMETER]} {
         set type  [string tolower [get_parameter_property $param TYPE]]
         set width [get_parameter_property $param WIDTH]

         if {$type == "integer"} {
            set init_val "0"
         } elseif {$type == "float"} {
            set init_val "0.0"
         } elseif {$type == "string"} {
            set init_val "\"\""
         } elseif {$type == "std_logic_vector"} {
            set init_val "${width}'b[string repeat "0" $width]"
         } elseif {$type == "boolean"} {
            set init_val "0"
         } else {
            emif_ie "Unsupported parameter type $type [info level 0]"
         }

         lappend param_declrs "parameter [format "%-50s" $param] = $init_val"
      }
   }
 
   set port_declrs [list]
 
   foreach if [get_interfaces] {
      foreach port [get_interface_ports $if] {
         set direction  [string tolower [get_port_property $port DIRECTION]]
         set vhdl_type  [string tolower [get_port_property $port VHDL_TYPE]]
         set width_val  [get_port_property $port WIDTH_VALUE]
         set terminated [get_port_property $port TERMINATION]
 
         if {$vhdl_type == "std_logic_vector"} {
            set end   [expr {$width_val - 1}]
            set range "\[$end:0\]"
         } else {
            set range ""
         }
 
         if {$direction == "bidir"} {
            set direction   "inout"
            set type        "tri"
         } elseif {$direction == "output"} {
            set type        "logic"
         } else {
            set type        "logic"
         }
 
         lappend port_maps   ".$port ($port)"
         lappend port_declrs "[format "%-6s" $direction] [format "%-5s" $type] [format "%-10s" $range] $port"
      }
   }
 
   set filename "${top_level}.sv"
   set file     [create_temp_file $filename]
   set fh       [open $file "w"]
 
   puts $fh "module ${top_level} #("
   puts $fh "   [join $param_declrs ",\n   "]"
   puts $fh ") ("
   puts $fh "   [join $port_declrs ",\n   "]"
   puts $fh ");"
   puts $fh ""
   puts $fh "//Internal return data arrays"
   puts $fh "localparam integer RATE_MULT = (PHYLITE_RATE_ENUM == \"RATE_IN_QUARTER\") ? 4 : (PHYLITE_RATE_ENUM == \"RATE_IN_HALF\") ? 2 : 1;"
   puts $fh "wire \[48 * 2 * RATE_MULT : 0\] data_to_sim_ctrl_tmp \[0 : PHYLITE_NUM_GROUPS - 1\];"
   puts $fh "wire \[RATE_MULT - 1 : 0\] rdata_valid_to_sim_ctrl_tmp \[0 : PHYLITE_NUM_GROUPS - 1\];"
   puts $fh ""
   puts $fh "assign core_clk_out = core_clk_in;"
   puts $fh "assign start_out    = start_in;"
   puts $fh ""
   for {set i 0} {$i < $num_grps} {incr i} {
      _create_driver_group_conns $fh $i
      puts $fh ""
   }
   _create_read_to_sim_ctrl_assignments $fh
   puts $fh "endmodule"
 
   close $fh
 
 
 
   set file_list [list $file ]
 
   return $file_list
}

proc ::altera_phylite::ip_driver::main::_create_driver_group_conns {fh grp_idx} {

   set rate            [get_parameter_value "PHYLITE_RATE_ENUM"                    ]
   set pin_type        [get_parameter_value  "GROUP_${grp_idx}_PIN_TYPE"           ]
   set pin_width       [get_parameter_value  "GROUP_${grp_idx}_PIN_WIDTH"          ]
   set ddr_mode        [get_parameter_value  "GROUP_${grp_idx}_DDR_SDR_MODE"       ]
   set use_diff_strobe [get_parameter_value  "GROUP_${grp_idx}_USE_DIFF_STROBE"    ]
   set use_out_strobe  [get_parameter_value  "GROUP_${grp_idx}_USE_OUTPUT_STROBE"  ]
 
   set ddr_mult 1
   if {[string compare -nocase $ddr_mode "DDR"] == 0} {
      set ddr_mult 2
   }
   
   set num_strobes 1
   
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 && [string compare -nocase $use_out_strobe "false"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $use_diff_strobe "true"] == 0} {
      set num_strobes 2
   }
   
   set oe_width_mult 4
   set data_width_mult 4*$ddr_mult
   set strobe_width 8
   
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set data_width_mult 2*$ddr_mult
      set strobe_width 4
      set oe_width_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set data_width_mult $ddr_mult
      set strobe_width 2
      set oe_width_mult 1
   }

   set oe_width [expr ${oe_width_mult}*${pin_width}]
   set data_width [expr ${data_width_mult}*${pin_width}]
 
   puts $fh "//Group ${grp_idx} connections"
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 || [string compare -nocase $pin_type "BIDIR"] == 0} {
      puts $fh "assign group_${grp_idx}_oe_from_core   = {${oe_width}{grp_sel\[${grp_idx}\]}} & oe_from_sim_ctrl\[${oe_width} - 1 : 0\];"
      puts $fh "assign group_${grp_idx}_data_from_core = {${data_width}{grp_sel\[${grp_idx}\]}} & data_from_sim_ctrl\[${data_width} - 1 : 0\];"
 
      if {$num_strobes > 0} {
         set strobe_pattern_repeat ${strobe_width}/2
         puts $fh "assign group_${grp_idx}_output_strobe_in = {(${strobe_pattern_repeat}){2'b01}};"
         puts $fh "assign group_${grp_idx}_output_strobe_en = {${oe_width_mult}{grp_sel\[${grp_idx}\]}} & strobe_oe_from_sim_ctrl\[${oe_width_mult} - 1 : 0\];"
      }
   }
 
   if {[string compare -nocase $pin_type "INPUT"] == 0 || [string compare -nocase $pin_type "BIDIR"] == 0} {
      set upper_data_tie_off [expr 48*2*${oe_width_mult}-${data_width}]
      set upper_vld_tie_off [expr 4-${oe_width_mult}]

      puts $fh "assign data_to_sim_ctrl_tmp\[${grp_idx}\] = {{${upper_data_tie_off}{1'b0}}, group_${grp_idx}_data_to_core};"
      puts $fh "assign group_${grp_idx}_rdata_en = {${oe_width_mult}{grp_sel\[${grp_idx}\]}} & rdata_en_from_sim_ctrl\[${oe_width_mult} - 1 : 0\];"
      puts $fh "assign rdata_valid_to_sim_ctrl_tmp\[${grp_idx}\] = {{${upper_vld_tie_off}{1'b0}}, group_${grp_idx}_rdata_valid};"
   }
 
   puts $fh ""
}

proc ::altera_phylite::ip_driver::main::_create_read_to_sim_ctrl_assignments {fh} {
   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"]
 
   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }
 
   set num_hex_digits [expr (${num_grps} / 4) + 1]

   puts $fh "always @(*) begin"
   puts $fh "\tcase (grp_sel)"
   for {set i 0} {$i < $num_grps} {incr i} {
      puts $fh "\t\t${num_grps}'h[format "%0${num_hex_digits}x" [expr 1 << $i]]: begin"
      puts $fh "\t\t\trdata_valid_to_sim_ctrl = rdata_valid_to_sim_ctrl_tmp\[${i}\];"
      puts $fh "\t\t\tdata_to_sim_ctrl = data_to_sim_ctrl_tmp\[${i}\];"
      puts $fh "\t\tend"
   }
   puts $fh "\t\tdefault: begin"
   puts $fh "\t\t\trdata_valid_to_sim_ctrl = {${rate_mult}{1'b0}};"
   puts $fh "\t\t\tdata_to_sim_ctrl = {[expr 48 * 2 * $rate_mult]{1'b0}};"
   puts $fh "\t\tend"
   puts $fh "\tendcase"
   puts $fh "end"
   puts $fh ""
}

proc ::altera_phylite::ip_driver::main::_generate_vhdl_fileset {top_level} {
}

proc ::altera_phylite::ip_driver::main::_create_vhdl_driver_group_conns {fh grp_idx} {
}

proc ::altera_phylite::ip_driver::main::_create_vhdl_read_to_sim_ctrl_assignments {fh} {
}

proc ::altera_phylite::ip_driver::main::_elaborate_grp_core_interface {grp_idx} {
   set rate            [get_parameter_value  "PHYLITE_RATE_ENUM"                  ]
   set pin_type        [get_parameter_value  "GROUP_${grp_idx}_PIN_TYPE"          ]
   set pin_width       [get_parameter_value  "GROUP_${grp_idx}_PIN_WIDTH"         ]
   set ddr_mode        [get_parameter_value  "GROUP_${grp_idx}_DDR_SDR_MODE"      ]
   set use_diff_strobe [get_parameter_value  "GROUP_${grp_idx}_USE_DIFF_STROBE"   ]
   set use_out_strobe  [get_parameter_value  "GROUP_${grp_idx}_USE_OUTPUT_STROBE" ]
 
   set ddr_mult 1
   if {[string compare -nocase $ddr_mode "DDR"] == 0} {
      set ddr_mult 2
   }
   
   set num_strobes 1
   
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 && [string compare -nocase $use_out_strobe "false"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $use_diff_strobe "true"] == 0} {
      set num_strobes 2
   }
   
   set oe_width_mult 4
   set data_width_mult 4*$ddr_mult
   set strobe_width 8
   
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set data_width_mult 2*$ddr_mult
      set strobe_width 4
      set oe_width_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set data_width_mult $ddr_mult
      set strobe_width 2
      set oe_width_mult 1
   }
 
 
   set core_interface "group_${grp_idx}_core_interface_conduit_end"
   add_interface $core_interface conduit end
   set_interface_property $core_interface ENABLED true
 
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 || [string compare -nocase $pin_type "BIDIR"] == 0} {
      add_interface_port $core_interface group_${grp_idx}_oe_from_core   data_oe  Output ${oe_width_mult}*${pin_width}
      set_port_property group_${grp_idx}_oe_from_core VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_data_from_core data_out Output ${data_width_mult}*${pin_width}
      set_port_property group_${grp_idx}_data_from_core VHDL_TYPE std_logic_vector
 
      if {$num_strobes > 0} {
         add_interface_port $core_interface group_${grp_idx}_output_strobe_in strobe_out Output $strobe_width
         set_port_property group_${grp_idx}_output_strobe_in VHDL_TYPE std_logic_vector
         add_interface_port $core_interface group_${grp_idx}_output_strobe_en strobe_oe  Output $oe_width_mult
         set_port_property group_${grp_idx}_output_strobe_en VHDL_TYPE std_logic_vector
      }
   }
 
   if {[string compare -nocase $pin_type "INPUT"] == 0 || [string compare -nocase $pin_type "BIDIR"] == 0} {
      add_interface_port $core_interface group_${grp_idx}_data_to_core   data_in  Input  ${data_width_mult}*${pin_width}
      set_port_property group_${grp_idx}_data_to_core VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_rdata_en       read_en  Output $oe_width_mult
      set_port_property group_${grp_idx}_rdata_en VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_rdata_valid    data_vld Input  $oe_width_mult
      set_port_property group_${grp_idx}_rdata_valid VHDL_TYPE std_logic_vector
   }
}

proc ::altera_phylite::ip_driver::main::_elaborate_core_sim_ctrl_interface {} {

   set num_grps [get_parameter_value PHYLITE_NUM_GROUPS]
   set rate     [get_parameter_value  "PHYLITE_RATE_ENUM"]
 
   set rate_mult 4
   if {[string compare -nocase $rate "RATE_IN_HALF"] == 0} {
      set rate_mult 2
   } elseif {[string compare -nocase $rate "RATE_IN_FULL"] == 0} {
      set rate_mult 1
   }
 
   add_interface sim_ctrl_conduit_end conduit end
   add_interface_port sim_ctrl_conduit_end oe_from_sim_ctrl        oe_from_sim_ctrl        Input  48*$rate_mult
   set_port_property oe_from_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end data_from_sim_ctrl      data_from_sim_ctrl      Input  48*2*$rate_mult
   set_port_property data_from_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end data_to_sim_ctrl        data_to_sim_ctrl        Output 48*2*$rate_mult
   set_port_property data_to_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end rdata_en_from_sim_ctrl  rdata_en_from_sim_ctrl  Input  $rate_mult
   set_port_property rdata_en_from_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end rdata_valid_to_sim_ctrl rdata_valid_to_sim_ctrl Output $rate_mult
   set_port_property rdata_valid_to_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end strobe_oe_from_sim_ctrl strobe_oe_from_sim_ctrl Input  $rate_mult
   set_port_property strobe_oe_from_sim_ctrl VHDL_TYPE std_logic_vector
   add_interface_port sim_ctrl_conduit_end grp_sel                 grp_sel                 Input  $num_grps
   set_port_property grp_sel VHDL_TYPE std_logic_vector
}

proc ::altera_phylite::ip_driver::main::_init {} {
}

::altera_phylite::ip_driver::main::_init
