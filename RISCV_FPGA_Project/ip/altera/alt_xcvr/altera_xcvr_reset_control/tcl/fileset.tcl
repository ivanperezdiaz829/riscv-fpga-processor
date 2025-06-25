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



package provide altera_xcvr_reset_control::fileset 12.0

package require alt_xcvr::utils::fileset
package require alt_xcvr::ip_tcl::ip_module 12.1

namespace eval ::altera_xcvr_reset_control::fileset:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::utils::fileset::*

  namespace export \
    declare_filesets \
    declare_files

  variable filesets

  set filesets {\
    { NAME            TYPE            CALLBACK                                                      TOP_LEVEL                 }\
    { quartus_synth   QUARTUS_SYNTH   ::altera_xcvr_reset_control::fileset::callback_quartus_synth  altera_xcvr_reset_control }\
    { sim_verilog     SIM_VERILOG     ::altera_xcvr_reset_control::fileset::callback_sim_verilog    altera_xcvr_reset_control }\
    { sim_vhdl        SIM_VHDL        ::altera_xcvr_reset_control::fileset::callback_sim_vhdl       altera_xcvr_reset_control }\
  }
}

proc ::altera_xcvr_reset_control::fileset::declare_filesets { } {
  variable filesets

  declare_files
  ip_declare_filesets $filesets
}

proc ::altera_xcvr_reset_control::fileset::declare_files { {path "./"} } {
  # Common functions
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path [::alt_xcvr::utils::fileset::get_altera_xcvr_generic_path]]
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
    altera_xcvr_functions.sv
  } {ALTERA_XCVR_RESET_CONTROL}

  # Common resync module
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "${path}/ctrl/" {
    alt_xcvr_resync.sv
  } {ALTERA_XCVR_RESET_CONTROL}

  # altera_xcvr_reset_control files
  set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
  set path "${path}/altera_xcvr_reset_control"
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
    altera_xcvr_reset_control.sv
    alt_xcvr_reset_counter.sv
  } {ALTERA_XCVR_RESET_CONTROL}


}

proc ::altera_xcvr_reset_control::fileset::callback_quartus_synth {name} {
  common_add_fileset_files {ALTERA_XCVR_RESET_CONTROL} {PLAIN QIP}
}

proc ::altera_xcvr_reset_control::fileset::callback_sim_verilog {name} {
  common_add_fileset_files {ALTERA_XCVR_RESET_CONTROL} [concat PLAIN [common_fileset_tags_all_simulators]]
}

proc ::altera_xcvr_reset_control::fileset::callback_sim_vhdl {name} {
  common_add_fileset_files {ALTERA_XCVR_RESET_CONTROL} [concat PLAIN [common_fileset_tags_all_simulators]]
}

