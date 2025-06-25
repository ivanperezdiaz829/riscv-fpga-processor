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


package provide altera_phylite::ip_top::group 0.1

package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_phylite::util::enum_defs
package require altera_emif::util::device_family

namespace eval ::altera_phylite::ip_top::group:: {
   
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*
   namespace import ::altera_phylite::util::enum_defs
   namespace import ::altera_emif::util::device_family::*
   namespace import ::altera_emif::util::hwtcl_utils::*

   
   variable m_param_prefix "GROUP"
}


proc ::altera_phylite::ip_top::group::create_parameters {grp_idx} {
   variable m_param_prefix

   set param_prefix "${m_param_prefix}_${grp_idx}"

   add_derived_param  "${param_prefix}_PIN_TYPE"                       string     ""       false
   add_derived_param  "${param_prefix}_PIN_WIDTH"                      integer    0        false
   add_derived_param  "${param_prefix}_DDR_SDR_MODE"                   string     ""       false
   add_derived_param  "${param_prefix}_USE_DIFF_STROBE"                boolean    false    false
   add_derived_param  "${param_prefix}_READ_LATENCY"                   integer    0        false
   add_derived_param  "${param_prefix}_CAPTURE_PHASE_SHIFT"            integer    0        false
   add_derived_param  "${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"    boolean    false    false
   add_derived_param  "${param_prefix}_WRITE_LATENCY"                  integer    0        false
   add_derived_param  "${param_prefix}_USE_OUTPUT_STROBE"              boolean    false    false
   add_derived_param  "${param_prefix}_OUTPUT_STROBE_PHASE"            integer    0        false
  
   add_user_param  "GUI_${param_prefix}_PIN_TYPE_ENUM"                  string     BIDIR    [enum_dropdown_entries PIN_TYPE]     ""      ""             ""             "GUI_${m_param_prefix}_PIN_TYPE_ENUM"    
   add_user_param  "GUI_${param_prefix}_PIN_WIDTH"                      integer    9        {0:47}                               ""      ""             ""             "GUI_${m_param_prefix}_PIN_WIDTH"        
   add_user_param  "GUI_${param_prefix}_DDR_SDR_MODE_ENUM"              string     DDR      [enum_dropdown_entries DDR_SDR_MODE] ""      ""             ""             "GUI_${m_param_prefix}_DDR_SDR_MODE_ENUM"
   add_user_param  "GUI_${param_prefix}_USE_DIFF_STROBE"                boolean    false    ""                                   ""      ""             ""             "GUI_${m_param_prefix}_USE_DIFF_STROBE"  
   add_user_param  "GUI_${param_prefix}_READ_LATENCY"                   integer    4        {1:63}                               ""      ""             ""             "GUI_${m_param_prefix}_READ_LATENCY"     
   add_user_param  "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"    boolean    false    ""                                   ""      ""             ""             "GUI_${m_param_prefix}_USE_INTERNAL_CAPTURE_STROBE"
   add_user_param  "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT"            integer    90       {0 45 90 135}                        ""      ""             ""             "GUI_${m_param_prefix}_CAPTURE_PHASE_SHIFT"
   add_user_param  "GUI_${param_prefix}_WRITE_LATENCY"                  integer    0        {0:3}                                ""      ""             ""             "GUI_${m_param_prefix}_WRITE_LATENCY"      
   add_user_param  "GUI_${param_prefix}_USE_OUTPUT_STROBE"              boolean    true     ""                                   ""      ""             ""             "GUI_${m_param_prefix}_USE_OUTPUT_STROBE"  
   add_user_param  "GUI_${param_prefix}_OUTPUT_STROBE_PHASE"            integer    90       {0 45 90 135}                        ""      ""             ""             "GUI_${m_param_prefix}_OUTPUT_STROBE_PHASE"

   set_parameter_property "GUI_${param_prefix}_READ_LATENCY"         DISPLAY_UNITS "External interface clock cycles"
   set_parameter_property "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT"  DISPLAY_UNITS "Degrees"
   set_parameter_property "GUI_${param_prefix}_WRITE_LATENCY"        DISPLAY_UNITS "External interface clock cycles"
   set_parameter_property "GUI_${param_prefix}_OUTPUT_STROBE_PHASE"  DISPLAY_UNITS "Degrees"

   return 1
}

proc ::altera_phylite::ip_top::group::add_display_items {tabs grp_idx} {
   variable m_param_prefix

   set param_prefix "${m_param_prefix}_${grp_idx}"
   set grp_tab [lindex $tabs 0]
   
   set pin_grp    [get_string "GRP_GROUP_${grp_idx}_PIN_NAME"   ]
   set input_grp  [get_string "GRP_GROUP_${grp_idx}_INPUT_NAME" ]
   set output_grp [get_string "GRP_GROUP_${grp_idx}_OUTPUT_NAME"]
   
   add_display_item $grp_tab $pin_grp    GROUP   
   add_display_item $grp_tab $input_grp  GROUP   
   add_display_item $grp_tab $output_grp GROUP      
   
   add_param_to_gui $pin_grp     "GUI_${param_prefix}_PIN_TYPE_ENUM"       
   add_param_to_gui $pin_grp     "GUI_${param_prefix}_PIN_WIDTH"           
   add_param_to_gui $pin_grp     "GUI_${param_prefix}_DDR_SDR_MODE_ENUM"   
   add_param_to_gui $pin_grp     "GUI_${param_prefix}_USE_DIFF_STROBE"     
   add_param_to_gui $input_grp   "GUI_${param_prefix}_READ_LATENCY"        
   add_param_to_gui $input_grp   "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE" 
   add_param_to_gui $input_grp   "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT" 
   add_param_to_gui $output_grp  "GUI_${param_prefix}_WRITE_LATENCY"       
   add_param_to_gui $output_grp  "GUI_${param_prefix}_USE_OUTPUT_STROBE"   
   add_param_to_gui $output_grp  "GUI_${param_prefix}_OUTPUT_STROBE_PHASE" 

   return 1
}

proc ::altera_phylite::ip_top::group::validate {grp_idx grp_used} {
   variable m_param_prefix
   set param_prefix "${m_param_prefix}_${grp_idx}"

   set pin_type         [get_parameter_value "GUI_${param_prefix}_PIN_TYPE_ENUM"              ]
   set pin_width        [get_parameter_value "GUI_${param_prefix}_PIN_WIDTH"                  ]
   set ddr_sdr_mode     [get_parameter_value "GUI_${param_prefix}_DDR_SDR_MODE_ENUM"          ]
   set use_diff_strobe  [get_parameter_value "GUI_${param_prefix}_USE_DIFF_STROBE"            ]

   set_parameter_value  "${param_prefix}_PIN_TYPE"            $pin_type       
   set_parameter_value  "${param_prefix}_PIN_WIDTH"           $pin_width      
   set_parameter_value  "${param_prefix}_DDR_SDR_MODE"        $ddr_sdr_mode   

   set use_output_strobe    [get_parameter_value "GUI_${param_prefix}_USE_OUTPUT_STROBE"          ]
   set use_internal_capture_strobe   [get_parameter_value "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"]

   if {[expr [string compare -nocase $pin_type "OUTPUT"] == 0 && [string compare -nocase $use_output_strobe "false"] == 0] || [expr [string compare -nocase $pin_type "INPUT"] == 0 && [string compare -nocase $use_internal_capture_strobe "true"] == 0]} {
      set_parameter_property "GUI_${param_prefix}_USE_DIFF_STROBE" ENABLED false
      set_parameter_value  "${param_prefix}_USE_DIFF_STROBE"  false
   } else {
      set_parameter_property "GUI_${param_prefix}_USE_DIFF_STROBE" ENABLED true
      set_parameter_value  "${param_prefix}_USE_DIFF_STROBE"     $use_diff_strobe
   }

   _validate_input_path  $param_prefix $pin_type
   _validate_output_path $param_prefix $pin_type

   return 1
}


proc ::altera_phylite::ip_top::group::_validate_input_path {param_prefix pin_type} {

   set read_latency                  [get_parameter_value "GUI_${param_prefix}_READ_LATENCY"               ]
   set use_internal_capture_strobe   [get_parameter_value "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"]
   set capture_phase_shift           [get_parameter_value "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT"        ]

   if {[string compare -nocase $pin_type "OUTPUT"] == 0} {
      set_parameter_property  "GUI_${param_prefix}_READ_LATENCY"                 ENABLED false
      set_parameter_property  "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"  ENABLED false
      set_parameter_property  "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT"          ENABLED false

   } else {
      set_parameter_property  "GUI_${param_prefix}_READ_LATENCY"                 ENABLED true
      set_parameter_property  "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"  ENABLED true
      set_parameter_property  "GUI_${param_prefix}_CAPTURE_PHASE_SHIFT"          ENABLED true

      set_parameter_value  "${param_prefix}_READ_LATENCY"                 $read_latency               
      set_parameter_value  "${param_prefix}_USE_INTERNAL_CAPTURE_STROBE"  $use_internal_capture_strobe
      set_parameter_value  "${param_prefix}_CAPTURE_PHASE_SHIFT"          $capture_phase_shift        
   }

   set rd_lat_range [altera_phylite::util::arch_expert::get_legal_read_latencies]
   set_parameter_property "GUI_${param_prefix}_READ_LATENCY" ALLOWED_RANGES ${rd_lat_range}

   set_parameter_property "GUI_${param_prefix}_USE_INTERNAL_CAPTURE_STROBE" ENABLED false

}

proc ::altera_phylite::ip_top::group::_validate_output_path {param_prefix pin_type} {

   set write_latency        [get_parameter_value "GUI_${param_prefix}_WRITE_LATENCY"              ]
   set use_output_strobe    [get_parameter_value "GUI_${param_prefix}_USE_OUTPUT_STROBE"          ]
   set output_strobe_phase  [get_parameter_value "GUI_${param_prefix}_OUTPUT_STROBE_PHASE"        ]

   if {[string compare -nocase $pin_type "INPUT"] == 0} {
      set_parameter_property  "GUI_${param_prefix}_WRITE_LATENCY"       ENABLED false
      set_parameter_property  "GUI_${param_prefix}_USE_OUTPUT_STROBE"   ENABLED false
      set_parameter_property  "GUI_${param_prefix}_OUTPUT_STROBE_PHASE" ENABLED false

   } else {
      set_parameter_property  "GUI_${param_prefix}_WRITE_LATENCY"       ENABLED true
      set_parameter_property  "GUI_${param_prefix}_USE_OUTPUT_STROBE"   ENABLED true
      set_parameter_property  "GUI_${param_prefix}_OUTPUT_STROBE_PHASE" ENABLED true

      set_parameter_value  "${param_prefix}_WRITE_LATENCY"         $write_latency      
      set_parameter_value  "${param_prefix}_USE_OUTPUT_STROBE"     $use_output_strobe  
      set_parameter_value  "${param_prefix}_OUTPUT_STROBE_PHASE"   $output_strobe_phase
   }

   set data_rate [get_parameter_value "GUI_PHYLITE_RATE_ENUM"]

   if {[string compare -nocase $data_rate "RATE_IN_QUARTER"] == 0} {
           set_parameter_property "GUI_${param_prefix}_WRITE_LATENCY" ALLOWED_RANGES 0:3
   } elseif {[string compare -nocase $data_rate "RATE_IN_HALF"] == 0} {
           set_parameter_property "GUI_${param_prefix}_WRITE_LATENCY" ALLOWED_RANGES 0:1
   } else {
           set_parameter_property "GUI_${param_prefix}_WRITE_LATENCY" ALLOWED_RANGES 0
   }

}

proc ::altera_phylite::ip_top::group::_init {} {
}

::altera_phylite::ip_top::group::_init
