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


package provide altera_phylite::ip_arch_nf::main 0.1

package require altera_emif::util::messaging
package require altera_emif::util::math
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_phylite::util::enum_defs
package require altera_emif::util::enum_defs_family_traits_and_features
package require altera_emif::util::device_family

package require altera_phylite::ip_top::exports

package require altera_phylite::ip_arch_nf::pll


namespace eval ::altera_phylite::ip_arch_nf::main:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*


   variable top_level_mod_name "phylite_core_20"
}


proc ::altera_phylite::ip_arch_nf::main::create_parameters {} {
   
   ::altera_phylite::ip_top::exports::inherit_top_level_parameter_defs

   set_parameter_property PHYLITE_NUM_GROUPS                  HDL_PARAMETER true
   set_parameter_property PHYLITE_RATE_ENUM                   HDL_PARAMETER true
   set_parameter_property PHYLITE_USE_DYNAMIC_RECONFIGURATION HDL_PARAMETER true
   
   for { set i 0 } { $i < 12 } {incr i } {
      set_parameter_property  "GROUP_${i}_PIN_TYPE"                      HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_PIN_WIDTH"                     HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_DDR_SDR_MODE"                  HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_USE_DIFF_STROBE"               HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_READ_LATENCY"                  HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_USE_INTERNAL_CAPTURE_STROBE"   HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_CAPTURE_PHASE_SHIFT"           HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_WRITE_LATENCY"                 HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_USE_OUTPUT_STROBE"             HDL_PARAMETER true
      set_parameter_property  "GROUP_${i}_OUTPUT_STROBE_PHASE"           HDL_PARAMETER true
   }

   
   altera_phylite::ip_arch_nf::pll::add_pll_parameters
   
   
   return 1
}

proc ::altera_phylite::ip_arch_nf::main::elaboration_callback {} {

   ::altera_emif::util::device_family::load_data

   _elaborate_interfaces
   
   set user_mem_clk_freq [get_parameter_value PHYLITE_MEM_CLK_FREQ_MHZ]
   set user_ref_clk_freq [get_parameter_value PHYLITE_REF_CLK_FREQ_MHZ]

   set rate_enum [get_parameter_value PHYLITE_RATE_ENUM]
   set user_afi_ratio [enum_data $rate_enum AFI_RATIO]
   set clk_ratios [dict create]
   dict set clk_ratios PHY_HMC $user_afi_ratio
   dict set clk_ratios C2P_P2C $user_afi_ratio 
   dict set clk_ratios USER    $user_afi_ratio
   altera_phylite::ip_arch_nf::pll::derive_pll_parameters $user_mem_clk_freq $user_ref_clk_freq $clk_ratios


   _update_qip

   issue_pending_ipgen_e_msg_and_terminate
   
   return 1
}

proc ::altera_phylite::ip_arch_nf::main::sim_vhdl_fileset_callback {top_level} {
   variable top_level_mod_name
   set rtl_only 0
   set encrypted 1   
   
   set non_encryp_simulators [::altera_emif::util::hwtcl_utils::get_simulator_attributes 1]
   
   set file_paths [_generate_verilog_fileset $top_level]

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]

      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only 0] PATH $file_path $non_encryp_simulators

      add_fileset_file [file join mentor $file_name] [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH [file join mentor $file_path] {MENTOR_SPECIFIC}
   }
   
   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_top_level_vhd_wrapper $top_level $top_level_mod_name] \
                          [_generate_common_fileset $top_level]]

   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only 0] PATH $file_path $non_encryp_simulators
   }      
}

proc ::altera_phylite::ip_arch_nf::main::sim_verilog_fileset_callback {top_level} {
   variable top_level_mod_name

   set rtl_only 0
   set encrypted 0
   
   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level $top_level_mod_name] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_common_fileset $top_level]]
   
   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  
}

proc ::altera_phylite::ip_arch_nf::main::quartus_synth_fileset_callback {top_level} {
   variable top_level_mod_name

   source altera_phylite_sdc.tcl

   set rtl_only 0
   set encrypted 0
   
   set file_paths [concat [::altera_emif::util::hwtcl_utils::generate_top_level_sv_wrapper $top_level $top_level_mod_name] \
                          [_generate_verilog_fileset $top_level] \
                          [_generate_common_fileset $top_level]]
   
   foreach file_path $file_paths {
      set tmp [file split $file_path]
      set file_name [lindex $tmp end]
      add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH $file_path
   }  

	add_fileset_file altera_phylite.sdc SDC TEXT [generate_sdc_file]
}


proc ::altera_phylite::ip_arch_nf::main::_generate_common_fileset {top_level} {

}

proc ::altera_phylite::ip_arch_nf::main::_generate_verilog_fileset {top_level} {
   set file_list [list \
      rtl/phylite_c2p_conns.sv \
      rtl/phylite_core_20.sv \
      rtl/phylite_group_tile_20.sv \
      rtl/phylite_io_bufs.sv \
      rtl/pll.sv
   ]
   return $file_list
}


proc ::altera_phylite::ip_arch_nf::main::_update_qip {} {
}

proc ::altera_phylite::ip_arch_nf::main::_elaborate_interfaces {} {
   set num_grps    [get_parameter_value PHYLITE_NUM_GROUPS]
   set use_dyn_cfg [get_parameter_value PHYLITE_USE_DYNAMIC_RECONFIGURATION]

   _elaborate_clk_rst_interface

   if {[string compare -nocase $use_dyn_cfg "true"] == 0} {
      _elaborate_avl_interface
   }

   for { set i 0 } { $i < $num_grps } {incr i } {
      _elaborate_grp_interface $i
   }
}

proc ::altera_phylite::ip_arch_nf::main::_elaborate_clk_rst_interface {} {
   add_interface ref_clk_clock_sink clock sink
   set_interface_property ref_clk_clock_sink ENABLED true
   add_interface_port ref_clk_clock_sink ref_clk clk Input 1
 
   add_interface reset_reset_sink reset sink
   set_interface_property reset_reset_sink ENABLED true
   set_interface_property reset_reset_sink synchronousEdges NONE
   add_interface_port reset_reset_sink reset_n reset_n Input 1
 
   add_interface pll_conduit_end conduit end
   set_interface_property pll_conduit_end ENABLED true
   add_interface_port pll_conduit_end pll_locked pll_locked Output 1
 
   add_interface core_clk_conduit_end conduit end
   set_interface_property core_clk_conduit_end ENABLED true
   add_interface_port core_clk_conduit_end core_clk_out core_clk Output 1
}

proc ::altera_phylite::ip_arch_nf::main::_elaborate_avl_interface {} {
   add_interface avalon_interface_conduit_end conduit end
   set_interface_property avalon_interface_conduit_end ENABLED true
   add_interface_port avalon_interface_conduit_end avl_clk       avl_clk       Input   1
   add_interface_port avalon_interface_conduit_end avl_read      avl_read      Input   1
   add_interface_port avalon_interface_conduit_end avl_write     avl_write     Input   1
   add_interface_port avalon_interface_conduit_end avl_writedata avl_writedata Input  32
   set_port_property avl_writedata VHDL_TYPE std_logic_vector
   add_interface_port avalon_interface_conduit_end avl_address   avl_address   Input  20
   set_port_property avl_address VHDL_TYPE std_logic_vector
   add_interface_port avalon_interface_conduit_end avl_readdata  avl_readdata  Output 32
   set_port_property avl_readdata VHDL_TYPE std_logic_vector
}

proc ::altera_phylite::ip_arch_nf::main::_elaborate_grp_interface {grp_idx} {
   set rate               [get_parameter_value "PHYLITE_RATE_ENUM"                           ]
   set pin_type           [get_parameter_value "GROUP_${grp_idx}_PIN_TYPE"                   ]
   set pin_width          [get_parameter_value "GROUP_${grp_idx}_PIN_WIDTH"                  ]
   set ddr_mode           [get_parameter_value "GROUP_${grp_idx}_DDR_SDR_MODE"               ]
 
   set ddr_mult 1
   if {[string compare -nocase $ddr_mode "DDR"] == 0} {
      set ddr_mult 2
   }
   
   set num_strobes [_get_num_strobes_in_grp $grp_idx]
   
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
      add_interface_port $core_interface group_${grp_idx}_oe_from_core   data_oe  Input $oe_width_mult*$pin_width
      set_port_property group_${grp_idx}_oe_from_core VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_data_from_core data_out Input $data_width_mult*$pin_width
      set_port_property group_${grp_idx}_data_from_core VHDL_TYPE std_logic_vector
 
      if {$num_strobes > 0} {
         add_interface_port $core_interface group_${grp_idx}_strobe_out_in strobe_out Input $strobe_width
         set_port_property group_${grp_idx}_strobe_out_in VHDL_TYPE std_logic_vector
         add_interface_port $core_interface group_${grp_idx}_strobe_out_en strobe_oe  Input $oe_width_mult
         set_port_property group_${grp_idx}_strobe_out_en VHDL_TYPE std_logic_vector
      }
   }
 
   if {[string compare -nocase $pin_type "INPUT"] == 0 || [string compare -nocase $pin_type "BIDIR"] == 0} {
      add_interface_port $core_interface group_${grp_idx}_data_to_core   data_in  Output $data_width_mult*$pin_width
      set_port_property group_${grp_idx}_data_to_core VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_rdata_en       read_en  Input  $oe_width_mult
      set_port_property group_${grp_idx}_rdata_en VHDL_TYPE std_logic_vector
      add_interface_port $core_interface group_${grp_idx}_rdata_valid    data_vld Output $oe_width_mult
      set_port_property group_${grp_idx}_rdata_valid VHDL_TYPE std_logic_vector
   }
 
   set io_interface "group_${grp_idx}_io_interface_conduit_end"
   add_interface $io_interface conduit end
   set_interface_property $io_interface ENABLED true
   if {[string compare -nocase $pin_type "OUTPUT"] == 0} {
      add_interface_port $io_interface group_${grp_idx}_data_out data Output $pin_width
      set_port_property group_${grp_idx}_data_out VHDL_TYPE std_logic_vector
 
      if {$num_strobes > 0} {
         add_interface_port $io_interface group_${grp_idx}_strobe_out strobe Output 1
      }
      if {$num_strobes == 2} {
         add_interface_port $io_interface group_${grp_idx}_strobe_out_n strobe_n Output 1
      }
   } elseif {[string compare -nocase $pin_type "INPUT"] == 0} {
      add_interface_port $io_interface group_${grp_idx}_data_in data Input $pin_width
      set_port_property group_${grp_idx}_data_in VHDL_TYPE std_logic_vector
 
      if {$num_strobes > 0} {
         add_interface_port $io_interface group_${grp_idx}_strobe_in strobe Input 1
      }
      if {$num_strobes == 2} {
         add_interface_port $io_interface group_${grp_idx}_strobe_in_n strobe_n Input 1
      }
   } else { 
      add_interface_port $io_interface group_${grp_idx}_data_io data Bidir $pin_width
      set_port_property group_${grp_idx}_data_io VHDL_TYPE std_logic_vector
 
      if {$num_strobes > 0} {
         add_interface_port $io_interface group_${grp_idx}_strobe_io strobe Bidir 1
      }
      if {$num_strobes == 2} {
         add_interface_port $io_interface group_${grp_idx}_strobe_io_n strobe_n Bidir 1
      }
   }
 
}

proc ::altera_phylite::ip_arch_nf::main::_get_num_strobes_in_grp {grp_idx} {

   set pin_type           [get_parameter_value "GROUP_${grp_idx}_PIN_TYPE"                   ]
   set use_diff_strobe    [get_parameter_value "GROUP_${grp_idx}_USE_DIFF_STROBE"            ]
   set use_out_strobe     [get_parameter_value "GROUP_${grp_idx}_USE_OUTPUT_STROBE"          ]
   set use_int_cap_strobe [get_parameter_value "GROUP_${grp_idx}_USE_INTERNAL_CAPTURE_STROBE"]

   set num_strobes 1
   
   if {[string compare -nocase $pin_type "OUTPUT"] == 0 && [string compare -nocase $use_out_strobe "false"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $pin_type "INPUT"] == 0 && [string compare -nocase $use_int_cap_strobe "true"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $pin_type "BIDIR"] == 0 && [string compare -nocase $use_out_strobe "false"] == 0 && [string compare -nocase $use_int_cap_strobe "true"] == 0} {
      set num_strobes 0
   } elseif {[string compare -nocase $use_diff_strobe "true"] == 0} {
      set num_strobes 2
   }

   return $num_strobes
}

proc ::altera_phylite::ip_arch_nf::main::get_legal_read_latencies {} {
   set mem_clk_freq_mhz [get_parameter_value GUI_PHYLITE_MEM_CLK_FREQ_MHZ]
   set vco_ratio [altera_phylite::ip_arch_nf::pll::get_pll_vco_to_mem_clk_freq_ratio $mem_clk_freq_mhz]

   set range "1:63"
   if { $vco_ratio == 1 } {
      set range "4:63"
   } elseif { $vco_ratio == 2 } {
      set range "2:63"
   }

   return $range
}

proc ::altera_phylite::ip_arch_nf::main::_init {} {
}

::altera_phylite::ip_arch_nf::main::_init
