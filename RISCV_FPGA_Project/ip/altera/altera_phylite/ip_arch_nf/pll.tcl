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


package provide altera_phylite::ip_arch_nf::pll 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_emif::util::device_family
package require altera_emif::ip_arch_nf::util

namespace eval ::altera_phylite::ip_arch_nf::pll:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::math::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_emif::util::hwtcl_utils::*
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::ip_arch_nf::util::*

}


proc ::altera_phylite::ip_arch_nf::pll::add_pll_parameters {} {

   add_derived_hdl_param PLL_REF_CLK_FREQ_PS_STR          string           "0 ps"
   add_derived_hdl_param PLL_VCO_FREQ_PS_STR              string           "0 ps"
   add_derived_hdl_param PLL_VCO_FREQ_MHZ_INT             integer          0
   add_derived_hdl_param PLL_VCO_TO_MEM_CLK_FREQ_RATIO    integer          1
   
   add_derived_hdl_param PLL_MEM_CLK_FREQ_PS_STR          string           "0 ps"
   
   add_derived_hdl_param PLL_M_COUNTER_BYPASS_EN          string           "false"
   add_derived_hdl_param PLL_M_COUNTER_EVEN_DUTY_EN       string           "false"
   add_derived_hdl_param PLL_M_COUNTER_HIGH               integer          0
   add_derived_hdl_param PLL_M_COUNTER_LOW                integer          0
   
   add_derived_hdl_param PLL_PHYCLK_0_FREQ_PS_STR         string           "0 ps"
   add_derived_hdl_param PLL_PHYCLK_0_BYPASS_EN           string           "true"
   add_derived_hdl_param PLL_PHYCLK_0_HIGH                integer          256
   add_derived_hdl_param PLL_PHYCLK_0_LOW                 integer          256
   
   add_derived_hdl_param PLL_PHYCLK_1_FREQ_PS_STR         string           "0 ps"
   add_derived_hdl_param PLL_PHYCLK_1_BYPASS_EN           string           "true"
   add_derived_hdl_param PLL_PHYCLK_1_HIGH                integer          256
   add_derived_hdl_param PLL_PHYCLK_1_LOW                 integer          256
   
   add_derived_hdl_param PLL_PHYCLK_FB_FREQ_PS_STR        string           "0 ps"
   add_derived_hdl_param PLL_PHYCLK_FB_BYPASS_EN          string           "true"
   add_derived_hdl_param PLL_PHYCLK_FB_HIGH               integer          256
   add_derived_hdl_param PLL_PHYCLK_FB_LOW                integer          256
}

proc ::altera_phylite::ip_arch_nf::pll::get_legal_pll_ref_clk_freqs_mhz {mem_clk_freq_mhz clk_ratios max_entries} {

   set retval [list]
   
   set pfd_fmax_mhz              [get_family_trait FAMILY_TRAIT_PLL_PFD_FMAX_MHZ]
   set pfd_fmin_mhz              [get_family_trait FAMILY_TRAIT_PLL_PFD_FMIN_MHZ]
   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio $mem_clk_freq_mhz]
   
   return [_get_legal_pll_ref_clk_freqs_mhz \
      $max_entries \
      $pfd_fmax_mhz \
      $pfd_fmin_mhz \
      $mem_clk_freq_mhz \
      $clk_ratios \
      $vco_to_mem_clk_freq_ratio]
}

proc ::altera_phylite::ip_arch_nf::pll::get_pll_vco_to_mem_clk_freq_ratio {mem_clk_freq_mhz} {

   set dll_fmin_mhz [get_family_trait FAMILY_TRAIT_DLL_FMIN_MHZ]


   if {$mem_clk_freq_mhz >= $dll_fmin_mhz} {
      set ratio 1
   } elseif {[expr {$mem_clk_freq_mhz * 2}] >= $dll_fmin_mhz} {
      set ratio 2
   } elseif {[expr {$mem_clk_freq_mhz * 4}] >= $dll_fmin_mhz} {
      set ratio 4
   } else {
      emif_ie "Memory clock frequency $mem_clk_freq_mhz is too low to be supported"
   }
   return $ratio
}

proc ::altera_phylite::ip_arch_nf::pll::derive_pll_parameters {mem_clk_freq_mhz ref_clk_freq_mhz clk_ratios} {

   set has_error 0
   
   set settings [get_pll_settings $mem_clk_freq_mhz $ref_clk_freq_mhz $clk_ratios]   
   
   set param_names [list \
      PLL_REF_CLK_FREQ_PS_STR \
      PLL_VCO_FREQ_PS_STR \
      PLL_VCO_FREQ_MHZ_INT \
      PLL_VCO_TO_MEM_CLK_FREQ_RATIO \
      PLL_MEM_CLK_FREQ_PS_STR \
      PLL_M_COUNTER_BYPASS_EN \
      PLL_M_COUNTER_EVEN_DUTY_EN \
      PLL_M_COUNTER_HIGH \
      PLL_M_COUNTER_LOW \
      PLL_PHYCLK_0_FREQ_PS_STR \
      PLL_PHYCLK_0_BYPASS_EN \
      PLL_PHYCLK_0_HIGH \
      PLL_PHYCLK_0_LOW \
      PLL_PHYCLK_1_FREQ_PS_STR \
      PLL_PHYCLK_1_BYPASS_EN \
      PLL_PHYCLK_1_HIGH \
      PLL_PHYCLK_1_LOW \
      PLL_PHYCLK_FB_FREQ_PS_STR \
      PLL_PHYCLK_FB_BYPASS_EN \
      PLL_PHYCLK_FB_HIGH \
      PLL_PHYCLK_FB_LOW ]
      
   foreach param_name $param_names {
      set param_val [dict get $settings $param_name]
      set_parameter_value $param_name $param_val      
   }
}

proc ::altera_phylite::ip_arch_nf::pll::get_pll_settings {mem_clk_freq_mhz ref_clk_freq_mhz clk_ratios} {

   set vco_to_mem_clk_freq_ratio [get_pll_vco_to_mem_clk_freq_ratio $mem_clk_freq_mhz]
   
   set retval [_get_pll_settings \
      $mem_clk_freq_mhz \
      $ref_clk_freq_mhz \
      $clk_ratios \
      $vco_to_mem_clk_freq_ratio]
   
   set vco_freq_mhz [dict get $retval PLL_VCO_FREQ_MHZ]
   emif_assert {$vco_freq_mhz >= [get_family_trait FAMILY_TRAIT_DLL_FMIN_MHZ]}
   emif_assert {$vco_freq_mhz <= [get_family_trait FAMILY_TRAIT_DLL_FMAX_MHZ]}
   
   return $retval
}


proc ::altera_phylite::ip_arch_nf::pll::_get_legal_pll_ref_clk_freqs_mhz {
   max_entries \
   pfd_fmax_mhz \
   pfd_fmin_mhz \
   mem_clk_freq_mhz \
   clk_ratios \
   vco_to_mem_clk_freq_ratio
} {
   set retval [list]
   
   
   set vco_freq_mhz [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
      
   set slowest_clk_ratio [_get_mem_clk_to_slowest_clk_freq_ratio $clk_ratios]
   
   for {set i 1} {[llength $retval] < $max_entries} {incr i} {
      set divisor          [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio * $i}]
      set ref_clk_freq_mhz [expr {$vco_freq_mhz / $divisor}]
      
      if {$ref_clk_freq_mhz <= $pfd_fmin_mhz} {
         break
      } elseif {$ref_clk_freq_mhz >= $pfd_fmax_mhz} {
      } else {
         set ref_clk_freq_mhz [expr {round($ref_clk_freq_mhz * 1000.0) / 1000.0}]
         lappend retval $ref_clk_freq_mhz
      }
   }
   
   return $retval
}

proc ::altera_phylite::ip_arch_nf::pll::_get_pll_settings {\
   mem_clk_freq_mhz \
   ref_clk_freq_mhz \
   clk_ratios \
   vco_to_mem_clk_freq_ratio
} {

   set retval [dict create]

   set vco_freq_mhz      [expr {$mem_clk_freq_mhz * $vco_to_mem_clk_freq_ratio}]
   set user_clk_ratio    [dict get $clk_ratios USER]
   set c2p_p2c_clk_ratio [dict get $clk_ratios C2P_P2C]
   set phy_hmc_clk_ratio [dict get $clk_ratios PHY_HMC]
   set slowest_clk_ratio [_get_mem_clk_to_slowest_clk_freq_ratio $clk_ratios]
   
   set n_counter         1
   set phyclk_fb_counter [expr {$vco_to_mem_clk_freq_ratio * $slowest_clk_ratio}]
   set divisor           [expr { int(round($vco_freq_mhz / $ref_clk_freq_mhz)) }]
   
   emif_assert        { [expr {$divisor % $phyclk_fb_counter}] == 0 }
   set m_counter      [expr {$divisor / $phyclk_fb_counter}]

   set vco_freq_ps [expr {int(1000000.0 / $vco_freq_mhz)}]
   if {[expr {$vco_freq_ps % 2}] != 0} {
      incr vco_freq_ps
   }
   
   set mem_clk_freq_ps [expr {$vco_freq_ps * $vco_to_mem_clk_freq_ratio}]
   set ref_clk_freq_ps [expr {$vco_freq_ps * $phyclk_fb_counter * $m_counter}]
   
   dict set retval PLL_REF_CLK_FREQ_MHZ             $ref_clk_freq_mhz
   dict set retval PLL_REF_CLK_FREQ_PS              $ref_clk_freq_ps
   dict set retval PLL_REF_CLK_FREQ_PS_STR          "$ref_clk_freq_ps ps"
   dict set retval PLL_VCO_FREQ_MHZ                 $vco_freq_mhz
   dict set retval PLL_VCO_FREQ_PS                  $vco_freq_ps
   dict set retval PLL_VCO_FREQ_PS_STR              "$vco_freq_ps ps"
   dict set retval PLL_VCO_FREQ_MHZ_INT             [expr {round($vco_freq_mhz)}]
   dict set retval PLL_VCO_TO_MEM_CLK_FREQ_RATIO    $vco_to_mem_clk_freq_ratio
   dict set retval PLL_MEM_CLK_FREQ_MHZ             $mem_clk_freq_mhz
   dict set retval PLL_MEM_CLK_FREQ_PS              $mem_clk_freq_ps
   dict set retval PLL_MEM_CLK_FREQ_PS_STR          "$mem_clk_freq_ps ps"
            
   set settings [_get_counter_settings $m_counter]

   dict set retval PLL_M_COUNTER_BYPASS_EN          [dict get $settings BYPASS_EN]
   dict set retval PLL_M_COUNTER_HIGH               [dict get $settings HIGH]
   dict set retval PLL_M_COUNTER_LOW                [dict get $settings LOW]
   dict set retval PLL_M_COUNTER_EVEN_DUTY_EN       [dict get $settings EVEN_DUTY_EN]

   set phyclk_fb_freq     [expr {$vco_freq_mhz / $phyclk_fb_counter}]
   set phyclk_fb_freq_ps  [expr {$vco_freq_ps  * $phyclk_fb_counter}]
   
   set settings [_get_counter_settings $phyclk_fb_counter]

   dict set retval PLL_PHYCLK_FB_FREQ_MHZ           $phyclk_fb_freq
   dict set retval PLL_PHYCLK_FB_FREQ_PS            $phyclk_fb_freq_ps
   dict set retval PLL_PHYCLK_FB_FREQ_PS_STR        "$phyclk_fb_freq_ps ps"   
   dict set retval PLL_PHYCLK_FB_BYPASS_EN          [dict get $settings BYPASS_EN]
   dict set retval PLL_PHYCLK_FB_HIGH               [dict get $settings HIGH]
   dict set retval PLL_PHYCLK_FB_LOW                [dict get $settings LOW]
   dict set retval PLL_PHYCLK_FB_EVEN_DUTY_EN       [dict get $settings EVEN_DUTY_EN]

   set phyclk_0_counter   [expr {$vco_to_mem_clk_freq_ratio * $phy_hmc_clk_ratio}]
   set phyclk_0_freq      [expr {$vco_freq_mhz / $phyclk_0_counter}]
   set phyclk_0_freq_ps   [expr {$vco_freq_ps  * $phyclk_0_counter}]
   
   set settings [_get_counter_settings $phyclk_0_counter]
   
   dict set retval PLL_PHYCLK_0_FREQ_MHZ            $phyclk_0_freq
   dict set retval PLL_PHYCLK_0_FREQ_PS             $phyclk_0_freq_ps
   dict set retval PLL_PHYCLK_0_FREQ_PS_STR         "$phyclk_0_freq_ps ps"
   dict set retval PLL_PHYCLK_0_BYPASS_EN           [dict get $settings BYPASS_EN]
   dict set retval PLL_PHYCLK_0_HIGH                [dict get $settings HIGH]
   dict set retval PLL_PHYCLK_0_LOW                 [dict get $settings LOW]
   
   set phyclk_1_counter [expr {$vco_to_mem_clk_freq_ratio * $c2p_p2c_clk_ratio}]
   set phyclk_1_freq    [expr {$vco_freq_mhz / $phyclk_1_counter}]
   set phyclk_1_freq_ps [expr {$vco_freq_ps  * $phyclk_1_counter}]
   
   set settings [_get_counter_settings $phyclk_1_counter]
   
   dict set retval PLL_PHYCLK_1_FREQ_MHZ            $phyclk_1_freq
   dict set retval PLL_PHYCLK_1_FREQ_PS             $phyclk_1_freq_ps
   dict set retval PLL_PHYCLK_1_FREQ_PS_STR         "$phyclk_1_freq_ps ps"
   dict set retval PLL_PHYCLK_1_BYPASS_EN           [dict get $settings BYPASS_EN]
   dict set retval PLL_PHYCLK_1_HIGH                [dict get $settings HIGH]
   dict set retval PLL_PHYCLK_1_LOW                 [dict get $settings LOW]
   
   return $retval
}

proc ::altera_phylite::ip_arch_nf::pll::_get_counter_settings {counter_val} {
   set retval [dict create]

   if {$counter_val == 1} {
      dict set retval BYPASS_EN     "true" 
      dict set retval HIGH          256
      dict set retval LOW           256
      dict set retval EVEN_DUTY_EN  "false"
      
   } elseif {[expr {$counter_val % 2}] == 0} {
      dict set retval BYPASS_EN     "false" 
      dict set retval HIGH          [expr {$counter_val / 2}]
      dict set retval LOW           [dict get $retval HIGH]
      dict set retval EVEN_DUTY_EN  "false"
      
   } else {
      dict set retval BYPASS_EN     "false" 
      dict set retval HIGH          [expr {($counter_val + 1) / 2}]
      dict set retval LOW           [expr {[dict get $retval HIGH] - 1}]
      dict set retval EVEN_DUTY_EN  "true"
   }
   
   return $retval
}

proc ::altera_phylite::ip_arch_nf::pll::_get_mem_clk_to_slowest_clk_freq_ratio {clk_ratios} {
   set user_clk_ratio  [dict get $clk_ratios USER]
   
   if {$user_clk_ratio == 8} {
      set slowest_clk_ratio 8
   } else {
      set slowest_clk_ratio [expr {$user_clk_ratio * 2}]
   }
   return $slowest_clk_ratio
}

proc ::altera_phylite::ip_arch_nf::pll::_init {} {
}

::altera_phylite::ip_arch_nf::pll::_init
