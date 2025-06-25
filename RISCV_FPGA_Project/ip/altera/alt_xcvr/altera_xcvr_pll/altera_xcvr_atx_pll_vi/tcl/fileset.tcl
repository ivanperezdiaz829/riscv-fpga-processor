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


package provide altera_xcvr_atx_pll_vi::fileset 13.1

package require alt_xcvr::utils::fileset
package require alt_xcvr::utils::ipgen
package require alt_xcvr::ip_tcl::ip_module
package require altera_xcvr_atx_pll_vi::parameters
package require alt_xcvr::ip_tcl::messages
package require alt_xcvr::utils::reconfiguration_arria10
package require alt_xcvr::ip_tcl::file_utils

namespace eval ::altera_xcvr_atx_pll_vi::fileset:: {
   namespace import ::alt_xcvr::ip_tcl::ip_module::*
   namespace import ::alt_xcvr::utils::fileset::*
   namespace import ::alt_xcvr::ip_tcl::messages::*

   namespace export \
      declare_filesets \
      declare_files

   variable filesets

   set filesets {\
      { NAME            TYPE            CALLBACK                                                  TOP_LEVEL             }\
      { quartus_synth   QUARTUS_SYNTH   ::altera_xcvr_atx_pll_vi::fileset::callback_quartus_synth  altera_xcvr_atx_pll_a10 }\
      { sim_verilog     SIM_VERILOG     ::altera_xcvr_atx_pll_vi::fileset::callback_sim_verilog    altera_xcvr_atx_pll_a10 }\
      { sim_vhdl        SIM_VHDL        ::altera_xcvr_atx_pll_vi::fileset::callback_sim_vhdl       altera_xcvr_atx_pll_a10 }\
   }         
}

proc ::altera_xcvr_atx_pll_vi::fileset::declare_filesets { } {
   variable filesets
   declare_files
   ip_declare_filesets $filesets
}

proc ::altera_xcvr_atx_pll_vi::fileset::declare_files {} {
    
   #AVMM file
   set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
   set path "${path}/alt_xcvr_core/nf/"
   set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
   ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
      twentynm_xcvr_avmm.sv
   } {ALTERA_XCVR_ATX_PLL_VI}

   #alt_xcvr_resync used by AVMM wrapper
   set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
   set path "${path}/../altera_xcvr_generic/ctrl/"
   set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
   ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
      alt_xcvr_resync.sv
   } {ALTERA_XCVR_ATX_PLL_VI}
 
   # altera_xcvr_atx_pll_sv files
   set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
   set path "${path}/altera_xcvr_pll/altera_xcvr_atx_pll_vi/source/"
   set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
   ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
      altera_xcvr_atx_pll_a10.sv
      a10_xcvr_atx_pll.sv
   } {ALTERA_XCVR_ATX_PLL_VI}
}

proc ::altera_xcvr_atx_pll_vi::fileset::callback_quartus_synth {ip_name} {
   callback_generate_files $ip_name QUARTUS_SYNTH
}

proc ::altera_xcvr_atx_pll_vi::fileset::callback_sim_verilog {ip_name} {
   callback_generate_files $ip_name SIM_VERILOG
}

proc ::altera_xcvr_atx_pll_vi::fileset::callback_sim_vhdl {ip_name} {
   callback_generate_files $ip_name SIM_VHDL
}

proc ::altera_xcvr_atx_pll_vi::fileset::build_opcodes {} {
   set opcodes "atx_pll_refclk=[ip_get "parameter.refclk_index.value"]"
   return $opcodes
}

##
# Common fileset callback
proc ::altera_xcvr_atx_pll_vi::fileset::callback_generate_files { ip_name fileset } {
  set regmap_list {atx}

  # Add previously declared files to fileset
  set tags [expr {$fileset == "QUARTUS_SYNTH" ? {PLAIN QIP}
    : [concat PLAIN [common_fileset_tags_all_simulators]] }]
  common_add_fileset_files {ALTERA_XCVR_ATX_PLL_VI} $tags

  ::alt_xcvr::utils::reconfiguration_arria10::generate_config_files [build_opcodes] $regmap_list

  # Generate parameter documentation files if enabled
  if { [ip_get "parameter.generate_docs.value"] } {
    ::alt_xcvr::ip_tcl::file_utils::generate_doc_files $ip_name $fileset
  }

  # Generate the "add_hdl_instance" example file if enabled
  if {[ip_get "parameter.generate_add_hdl_instance_example.value"]} {
    ::alt_xcvr::ip_tcl::file_utils::generate_add_hdl_instance_example $ip_name $fileset
  }
}
