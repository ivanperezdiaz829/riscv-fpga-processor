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


package provide altera_phylite::ip_top::general 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::device_family
package require altera_phylite::util::enum_defs
package require altera_phylite::util::arch_expert

namespace eval ::altera_phylite::ip_top::general:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_phylite::util::enum_defs
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::util::hwtcl_utils::*

   
   variable m_param_prefix "PHYLITE"
}


proc ::altera_phylite::ip_top::general::create_parameters {} {
   variable m_param_prefix

   add_derived_param  "${m_param_prefix}_RATE_ENUM"                   string     ""       false
   add_derived_param  "${m_param_prefix}_MEM_CLK_FREQ_MHZ"            float      -1       false
   add_derived_param  "${m_param_prefix}_REF_CLK_FREQ_MHZ"            float      -1       true       "MEGAHERTZ"
   add_derived_param  "${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION" boolean    false    false
   add_derived_param  "${m_param_prefix}_INTERFACE_ID"                integer    -1       false

   add_user_param     "GUI_${m_param_prefix}_MEM_CLK_FREQ_MHZ"            float     1066.667                  {400:1333.333}                          "MEGAHERTZ"
   add_user_param     "GUI_${m_param_prefix}_DEFAULT_REF_CLK_FREQ"        boolean   true                      ""                                      ""
   add_user_param     "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ"       float     -1                        {-1}                                    "MEGAHERTZ"
   add_user_param     "GUI_${m_param_prefix}_RATE_ENUM"                   string    RATE_IN_QUARTER           [enum_dropdown_entries RATE_IN]         ""
   add_user_param     "GUI_${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION" boolean   false                     ""
   add_user_param     "GUI_${m_param_prefix}_INTERFACE_ID"                integer   0                         {0:15}                                  ""

   set_parameter_update_callback "GUI_${m_param_prefix}_DEFAULT_REF_CLK_FREQ"  ::altera_phylite::ip_top::general::_set_user_ref_clk_freq_to_default

   set_parameter_property "GUI_${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION" ENABLED false

   return 1
}

proc ::altera_phylite::ip_top::general::add_display_items {tabs} {
   variable m_param_prefix

   set general_tab [lindex $tabs 0]
   
   set clk_grp [get_string GRP_PHY_CLKS_NAME]
   set dyn_reconfig_grp [get_string GRP_PHY_DYN_RECONFIG_NAME]
   
   add_display_item $general_tab $clk_grp GROUP   
   add_display_item $general_tab $dyn_reconfig_grp GROUP
   
   add_param_to_gui $clk_grp          "GUI_${m_param_prefix}_MEM_CLK_FREQ_MHZ"
   add_param_to_gui $clk_grp          "GUI_${m_param_prefix}_DEFAULT_REF_CLK_FREQ"
   add_param_to_gui $clk_grp          "${m_param_prefix}_REF_CLK_FREQ_MHZ"
   add_param_to_gui $clk_grp          "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ"
   add_param_to_gui $clk_grp          "GUI_${m_param_prefix}_RATE_ENUM"
   add_param_to_gui $dyn_reconfig_grp "GUI_${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION"
   add_param_to_gui $dyn_reconfig_grp "GUI_${m_param_prefix}_INTERFACE_ID"

   return 1
}

proc ::altera_phylite::ip_top::general::validate {} {
   variable m_param_prefix

   set rate_enum            [get_parameter_value "GUI_${m_param_prefix}_RATE_ENUM"                  ]
   set mem_clk_freq_mhz     [get_parameter_value "GUI_${m_param_prefix}_MEM_CLK_FREQ_MHZ"           ]
   set use_dynamic_reconfig [get_parameter_value "GUI_${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION"]
   set interface_id         [get_parameter_value "GUI_${m_param_prefix}_INTERFACE_ID"               ]

   set_parameter_value "${m_param_prefix}_RATE_ENUM"                   $rate_enum           
   set_parameter_value "${m_param_prefix}_MEM_CLK_FREQ_MHZ"            $mem_clk_freq_mhz    
   set_parameter_value "${m_param_prefix}_USE_DYNAMIC_RECONFIGURATION" $use_dynamic_reconfig

   if {[string compare -nocase $use_dynamic_reconfig "true"] == 0} {
      set_parameter_property "GUI_${m_param_prefix}_INTERFACE_ID" ENABLED true
      set_parameter_value "${m_param_prefix}_INTERFACE_ID" $interface_id
   } else {
      set_parameter_property "GUI_${m_param_prefix}_INTERFACE_ID" ENABLED false
      set_parameter_value "${m_param_prefix}_INTERFACE_ID" 0
   }

   _validate_ref_clk_freq

   return 1
}


proc ::altera_phylite::ip_top::general::_validate_ref_clk_freq {} {
   variable m_param_prefix

   set default_ref_clk_freq [get_parameter_value "GUI_${m_param_prefix}_DEFAULT_REF_CLK_FREQ"]

   set mem_clk_freq_mhz [get_parameter_value "GUI_${m_param_prefix}_MEM_CLK_FREQ_MHZ"]

   set rate_enum [get_parameter_value "GUI_${m_param_prefix}_RATE_ENUM"]
   set user_afi_ratio [enum_data $rate_enum AFI_RATIO]
   set clk_ratios [dict create]
   dict set clk_ratios PHY_HMC $user_afi_ratio
   dict set clk_ratios C2P_P2C $user_afi_ratio 
   dict set clk_ratios USER    $user_afi_ratio

   if {$default_ref_clk_freq} {
      set legal_ref_freqs [altera_phylite::util::arch_expert::get_legal_pll_ref_clk_freqs_mhz $mem_clk_freq_mhz $clk_ratios 1]
      set ref_clk_freq_mhz [lindex $legal_ref_freqs 0]
   } else {
      set ref_clk_freq_mhz [get_parameter_value "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ"]
      set legal_ref_freqs  [altera_phylite::util::arch_expert::get_legal_pll_ref_clk_freqs_mhz $mem_clk_freq_mhz $clk_ratios 10]
      
      if {[lsearch -exact -real $legal_ref_freqs $ref_clk_freq_mhz] == -1} {
         lappend legal_ref_freqs $ref_clk_freq_mhz
         post_ipgen_e_msg MSG_INVALID_PLL_REF_CLK_FREQ [list $ref_clk_freq_mhz]
      }
      set_parameter_property "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ" ALLOWED_RANGES $legal_ref_freqs
   }

   set_parameter_property "${m_param_prefix}_REF_CLK_FREQ_MHZ"          VISIBLE [expr {$default_ref_clk_freq}]
   set_parameter_property "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ" VISIBLE [expr {!$default_ref_clk_freq}]   
   
   set_parameter_value "${m_param_prefix}_REF_CLK_FREQ_MHZ" $ref_clk_freq_mhz
}

proc ::altera_phylite::ip_top::general::_set_user_ref_clk_freq_to_default {arg} {
   variable m_param_prefix

   set default_ref_clk_freq [get_parameter_value "GUI_${m_param_prefix}_DEFAULT_REF_CLK_FREQ"]

   set mem_clk_freq_mhz [get_parameter_value "GUI_${m_param_prefix}_MEM_CLK_FREQ_MHZ"]

   set rate_enum [get_parameter_value "GUI_${m_param_prefix}_RATE_ENUM"]
   set user_afi_ratio [enum_data $rate_enum AFI_RATIO]
   set clk_ratios [dict create]
   dict set clk_ratios PHY_HMC $user_afi_ratio
   dict set clk_ratios C2P_P2C $user_afi_ratio 
   dict set clk_ratios USER    $user_afi_ratio
   
   if {!$default_ref_clk_freq} {
      set legal_ref_freqs [altera_phylite::util::arch_expert::get_legal_pll_ref_clk_freqs_mhz $mem_clk_freq_mhz $clk_ratios 1]
      set ref_clk_freq_mhz [lindex $legal_ref_freqs 0]
      set_parameter_value "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ" $ref_clk_freq_mhz
   } else {
      set_parameter_value "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ" -1
      set_parameter_property "GUI_${m_param_prefix}_USER_REF_CLK_FREQ_MHZ" ALLOWED_RANGES {-1}
   }
}

proc ::altera_phylite::ip_top::general::_init {} {
}

::altera_phylite::ip_top::general::_init
