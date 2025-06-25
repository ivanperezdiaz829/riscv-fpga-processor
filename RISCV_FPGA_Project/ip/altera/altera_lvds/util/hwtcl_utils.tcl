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


package provide altera_lvds::util::hwtcl_utils 0.1
package require altera_emif::util::hwtcl_utils


namespace eval ::altera_lvds::util::hwtcl_utils:: {
   namespace export add_user_param
   namespace export add_derived_param
   namespace export add_derived_hdl_param
   namespace export add_text_to_gui
   namespace export add_param_to_gui
   namespace export string_compare
   namespace export param_string_compare
   namespace export bit_rotate
   namespace export map_allowed_range 
   namespace export add_if 
   namespace export get_clock_shift_in_degrees
   namespace export strip_units
   namespace export param_strip_units
   namespace export freq_to_period 
   
   
}


proc ::altera_lvds::util::hwtcl_utils::add_user_param {\
   name \
   type \
   default_val \
   allowed_ranges \
   {unit ""} \
   {display_hint ""} \
   {affects_validation false} \
} {
   set derived false
   set visible true
   set affects_elab true
   _add_parameter $name $type $default_val $derived $visible $affects_elab false $allowed_ranges $unit $display_hint $affects_validation
}

proc ::altera_lvds::util::hwtcl_utils::add_derived_param {\
   name \
   type \
   default_val \
   visible \
   {unit ""} \
   {display_hint ""} \
} {
   set derived true
   set affects_elab true
   set allowed_ranges ""
   _add_parameter $name $type $default_val $derived $visible $affects_elab false $allowed_ranges $unit $display_hint
}

proc ::altera_lvds::util::hwtcl_utils::add_derived_hdl_param {\
   name \
   type \
   default_val \
   {width 1} \
} {
   add_parameter $name $type $default_val
   set_parameter_property $name HDL_PARAMETER true
   set_parameter_property $name DERIVED true   
   set_parameter_property $name AFFECTS_ELABORATION false
   set_parameter_property $name WIDTH $width
   
   return 1
}



proc ::altera_lvds::util::hwtcl_utils::_add_parameter {\
   name \
   type \
   default_val \
   {derived false} \
   {visible true} \
   {affects_elab true} \
   {hdl false} \
   {allowed_ranges ""} \
   {unit ""} \
   {display_hint ""} \
   {affects_validation true} \
} {
   add_parameter $name $type $default_val
   
   if {$derived} {
      set_parameter_property $name DERIVED true
   }
   
   if {[string_compare $visible false]} {
      set_parameter_property $name VISIBLE false
   }
   
   if {!$affects_elab} {
      set_parameter_property $name AFFECTS_ELABORATION false
   }
      set_parameter_property $name AFFECTS_VALIDATION $affects_validation   

   if {$hdl} {
      set_parameter_property $name HDL_PARAMETER true
   }
   
   if {$allowed_ranges != ""} {
      set_parameter_property $name ALLOWED_RANGES $allowed_ranges
   }
   
   if {$unit != ""} {
      set_parameter_property $name UNITS $unit
   }

  if {$display_hint != ""} {
      set_parameter_property $name DISPLAY_HINT $display_hint
   }
      
   set_parameter_property $name DISPLAY_NAME [get_string PARAM_${name}_NAME]
   set_parameter_property $name DESCRIPTION [get_string PARAM_${name}_DESC]

   return 1
}

proc ::altera_lvds::util::hwtcl_utils::add_text_to_gui {\
   parent \
   text_name \
} {
   add_display_item $parent $text_name text [get_string TEXT_${text_name}]
}

proc ::altera_lvds::util::hwtcl_utils::add_param_to_gui {\
   parent \
   param_name \
} {
   add_display_item $parent $param_name PARAMETER
   return 1
}



proc ::altera_lvds::util::hwtcl_utils::add_if {\
   name \
   type \
   qsys_dir \
   dir \
   {width 0} \
   {term "none"}
} {
   set if_name "${name}_${type}_${qsys_dir}"

   add_interface $if_name $type $qsys_dir
   set_interface_property $if_name ENABLED false 
   
   set_interface_assignment $if_name "ui.blockdiagram.direction" $dir

   if { $width == 0 } {
         set width 1
		 set port_vhdl_type STD_LOGIC
   } else {
         set port_vhdl_type STD_LOGIC_VECTOR
   }
   
   if { $type == "clock" } {
        add_interface_port $if_name $name clk $dir $width
   } else {
        add_interface_port $if_name $name export $dir $width
   }

   set_port_property $name VHDL_TYPE $port_vhdl_type

   if { [string_compare $term "none"] == 0 } {
        set_port_property $name TERMINATION true
        set_port_property $name TERMINATION_VALUE $term
   }     
}

proc ::altera_lvds::util::hwtcl_utils::string_compare {string_1 string_2} {
    return [expr {[string compare -nocase $string_1 $string_2] == 0}] 
}

proc ::altera_lvds::util::hwtcl_utils::param_string_compare {param str} {
   return [::altera_lvds::util::hwtcl_utils::string_compare [get_parameter_value $param] $str]
}


proc ::altera_lvds::util::hwtcl_utils::strip_units {with_units} {
    if {[regexp {([0-9.]+)} $with_units no_units]} {
        return $no_units
    } else {
    }    
 }



proc ::altera_lvds::util::hwtcl_utils::param_strip_units {param} {
    return [strip_units [get_parameter_value $param]]
}

proc ::altera_lvds::util::hwtcl_utils::bit_rotate {word width num_bits} {
    set num_bits [expr {$num_bits % $width}]
    set word [expr {$word << $num_bits}]
    return [expr {($word + $word/(1<<($width)))%(1<<($width))}]
}

proc ::altera_lvds::util::hwtcl_utils::ps_str_to_deg_str {shift_ps period {modulo 360}} {

   set shift [strip_units $shift_ps]
   set per   [strip_units $period]

   return   "[expr {round($shift*360.0/$per)%$modulo}] degrees" 
}


proc ::altera_lvds::util::hwtcl_utils::get_clock_shift_in_degrees {param} {

    set freq [param_strip_units "pll_${param}_frequency"]
    set period [freq_to_period $freq]

    set shift [get_parameter_value "pll_${param}_phase_shift"] 
    if { [regexp -lineanchor {^[0-9.]+} $shift] } {
        return [ps_str_to_deg_str $shift $period]
    } else {
        return "Not Computable"
    }    
}

proc ::altera_lvds::util::hwtcl_utils::generate_vhdl_sim {encrypted_files} {
	set rtl_only 0
	set encrypted 1   

	set non_encryp_simulators [::altera_emif::util::hwtcl_utils::get_simulator_attributes 1]

	set file_paths $encrypted_files

	foreach file_path $file_paths {
		set tmp [file split $file_path]
		set file_name [lindex $tmp end]

		add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only 0] PATH $file_path $non_encryp_simulators

		add_fileset_file [file join mentor $file_name] [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH [file join mentor $file_path] {MENTOR_SPECIFIC}
	} 
}

proc ::altera_lvds::util::hwtcl_utils::map_allowed_range { gui_param_name legal_values } {

  set current_symbol [get_parameter_value $gui_param_name]
  regsub -all {[^-A-Za-z_0-9 ]+} $current_value {.} current_value
  set sanitized_legal [list]
  foreach val $legal_values {
    regsub -all {[^-A-Za-z_0-9 ]+} $val {.} val
    lappend sanitized_legal $val
  }

  set allowed_range [list]
  set legal_value [lindex $sanitized_legal 0]
  if {[lsearch -exact $sanitized_legal $current_value ] >= 0 } {
    lappend allowed_range "$current_value"
  }

  foreach val $sanitized_legal {
    if {$val != $current_value} {
      lappend allowed_range "$val"
    }
  }
}


proc ::altera_lvds::util::hwtcl_utils::freq_to_period {freq} {

    if { [regexp {[0-9.]+} $freq] } {
        strip_units $freq 
        return [expr {entier(1000000/$freq)}]
    } else {
        return "N/A" 
    }
}


proc ::altera_lvds::util::hwtcl_utils::_init {} {
}

::altera_lvds::util::hwtcl_utils::_init
