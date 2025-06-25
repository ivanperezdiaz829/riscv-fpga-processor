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



package provide altera_xcvr_pll_av::fileset 12.0

package require alt_xcvr::utils::fileset
package require alt_xcvr::ip_tcl::ip_module

namespace eval ::altera_xcvr_pll_av::fileset:: {
  namespace import ::alt_xcvr::ip_tcl::ip_module::*
  namespace import ::alt_xcvr::utils::fileset::*

  namespace export \
    declare_filesets \
    declare_files

  variable filesets

  set filesets {\
    { NAME            TYPE            CALLBACK                                               TOP_LEVEL    }\
    { quartus_synth   QUARTUS_SYNTH   ::altera_xcvr_pll_av::fileset::callback_quartus_synth  av_xcvr_plls }\
    { sim_verilog     SIM_VERILOG     ::altera_xcvr_pll_av::fileset::callback_sim_verilog    av_xcvr_plls }\
    { sim_vhdl        SIM_VHDL        ::altera_xcvr_pll_av::fileset::callback_sim_vhdl       av_xcvr_plls }\
  }

}

proc ::altera_xcvr_pll_av::fileset::declare_filesets { } {
  variable filesets

  declare_files
  ip_declare_filesets $filesets
}

proc ::altera_xcvr_pll_av::fileset::declare_files {} {
  # AV Core files
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path [::alt_xcvr::utils::fileset::get_altera_xcvr_generic_path]]
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "$path" {
    altera_xcvr_functions.sv
  } {ALTERA_XCVR_PLL_AV}

  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "$path/av" {
    av_xcvr_h.sv
    av_xcvr_plls.sv
	av_reconfig_bundle_to_xcvr.sv
	av_xcvr_avmm_csr.sv
  } {ALTERA_XCVR_PLL_AV}
  
  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ "$path/ctrl" {
    alt_xcvr_resync.sv
  } {ALTERA_XCVR_PLL_AV}
}

proc ::altera_xcvr_pll_av::fileset::callback_quartus_synth {name} {
  common_add_fileset_files {ALTERA_XCVR_PLL_AV} {PLAIN QIP}
}

proc ::altera_xcvr_pll_av::fileset::callback_sim_verilog {name} {
  common_add_fileset_files {ALTERA_XCVR_PLL_AV} [concat PLAIN [common_fileset_tags_all_simulators]]
}

proc ::altera_xcvr_pll_av::fileset::callback_sim_vhdl {name} {
  common_add_fileset_files {ALTERA_XCVR_PLL_AV} [concat PLAIN [common_fileset_tags_all_simulators]]
}

