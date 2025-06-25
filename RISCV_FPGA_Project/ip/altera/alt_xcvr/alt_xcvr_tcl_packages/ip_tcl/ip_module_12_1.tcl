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



package provide alt_xcvr::ip_tcl::ip_module 12.1

package require alt_xcvr::ip_tcl::messages

namespace eval ::alt_xcvr::ip_tcl::ip_module:: {
  namespace export \
    ip_set_debug \
    ip_declare_module \
    ip_declare_display_items \
    ip_declare_parameters \
    ip_declare_interfaces \
    ip_declare_filesets \
    ip_validate_parameters \
    ip_elaborate_interfaces \
    ip_upgrade \
    ip_add \
    ip_set \
    ip_get
  
  variable debug 0
  variable alist
  variable alength
  variable i_parameters
  variable i_interfaces
  variable validated_list
  variable validated_stack
  variable dynamic_elab "NOVAL"
  variable lasttime 0
  variable port_ignore_list
  variable param_ignore_list

  set port_ignore_list {NAME ROLE SPLIT SPLIT_COUNT SPLIT_WIDTH IFACE_NAME IFACE_TYPE IFACE_DIRECTION DYNAMIC ELABORATION_CALLBACK UI_DIRECTION}
  set param_ignore_list {NAME TYPE VALIDATION_CALLBACK}
}

###
# Enable debug statements
# @param val - 0-disable debug statements, 1-enable
proc ::alt_xcvr::ip_tcl::ip_module::ip_set_debug { val } {
  variable debug
  if { $val != 0 } {
    set val 1
  }

  set debug $val
}

###
# Declare a module and its properties
# @param module - A nested list of module properties
proc ::alt_xcvr::ip_tcl::ip_module::ip_declare_module { module } {
 #dprint "\[ip_declare_module\] module:${module}"
  # First sublist to contain headers
  set length [llength [lindex $module 0]]
  for {set i 0} {$i < $length} {incr i} {
    set name [lindex [lindex $module 0] $i]
    set val [lindex [lindex $module 1] $i]
   #dprint "\[ip_declare_module\] name:${name} val:${val}"
    if { $val != "NOVAL"} {
      ip_set "module.${name}" [lindex [lindex $module 1] $i]
    }
  }
}

###
# Declare a module's display items
# @param display_items - A nested list of display items
proc ::alt_xcvr::ip_tcl::ip_module::ip_declare_display_items { display_items } {
 #dprint "\[ip_declare_display_items\] display_items:${display_items}"
  # First sublist to contain headers
  set nameindex   [lsearch [lindex $display_items 0] NAME]
  set typeindex   [lsearch [lindex $display_items 0] TYPE]
  set groupindex  [lsearch [lindex $display_items 0] GROUP]
  set argindex    [lsearch [lindex $display_items 0] ARGS]
  for {set i 1} {$i < [llength $display_items]} {incr i} {
    set name [lindex [lindex $display_items $i] $nameindex]
    set type [lindex [lindex $display_items $i] $typeindex]
    set group [lindex [lindex $display_items $i] $groupindex]
    set args [lindex [lindex $display_items $i] $argindex]
    set command "ip_add \"display_item.${group}.${name}\" ${type}"
    foreach arg $args {
      set command "${command} \"${arg}\""
    }
    eval $command
  }

}

###
# Declare a module's parameters
# @param parameters - A nested list of parameters and their properties.
proc ::alt_xcvr::ip_tcl::ip_module::ip_declare_parameters { parameters } {
  variable i_parameters
  variable param_ignore_list

 #dprint "\[ip_declare_parameters\] entry"
  set i_parameters [list [index_data $parameters] $parameters]
  set prop_list [get_property_list $i_parameters]
  set item_count [get_item_count $i_parameters]
  set prop_count [get_property_count $i_parameters]

 #dprint "\[ip_declare_parameters\] item_count:${item_count} prop_count:${prop_count}"
  # Add the parameters
  for {set i 1} {$i < $item_count} {incr i} {
    # Retrieve parameter name and type
    set name [get_item_name $i_parameters $i]
    set type [get_item_property $i_parameters $name TYPE]
   #dprint "\[ip_declare_parameters\] i:${i} name:${name} type:${type}"
    # Add the parameter
    ip_add "parameter.${name}" $type
    # Retrieve and set all parameter properties from list
    for {set j 0} {$j < $prop_count} {incr j} {
      # Retrieve property type and value
      set prop [lindex $prop_list $j]
      set val [get_item_property $i_parameters $name $prop]

     #dprint "\[ip_declare_parameters\] i:${i} j:${j} prop:${prop} val:${val}"

      # Boolean properties may be associated with a parameter
      if { $prop == "ENABLED" || $prop == "VISIBLE"} {
        if { $val != "NOVAL" && [string tolower $val] != "false" && [string tolower $val] != "true" } {
          set val NOVAL
        }
      }

      # These properties do not get set
      if { [lsearch $param_ignore_list $prop] != -1 } {
        set val NOVAL
      }
      # Ignore metadata attributes
      if { [string first "M_" $prop] == 0 } {
        set val NOVAL
      }

      # Set the parameter property
      if { $val != "NOVAL" } {
        ip_set "parameter.${name}.${prop}" $val
      }
    }
  }
}


proc ::alt_xcvr::ip_tcl::ip_module::ip_declare_interfaces { interfaces } {
  variable i_interfaces
  variable dynamic_elab

  # Store the interfaces list for future use
  set i_interfaces [list [index_data $interfaces] $interfaces]
  
  set dynamic_elab false
  ip_elaborate_interfaces
  set dynamic_elab NOVAL
}

proc ::alt_xcvr::ip_tcl::ip_module::ip_declare_filesets { filesets } {
  # Get index of NAME property
  set i_filesets [list [index_data $filesets] $filesets]

  # Iterate over fileset entries
  for {set i 1} {$i < [get_item_count $i_filesets]} {incr i} {
    # We require the name, type, and callback to add the fileset
    set name      [get_item_name $i_filesets $i]
    set type      [get_item_property $i_filesets $name TYPE]
    set callback  [get_item_property $i_filesets $name CALLBACK]

    if { $name == "NOVAL" || $type == "NOVAL" || $callback == "NOVAL" } {
      ::alt_xcvr::ip_tcl::messages::internal_error "\[ip_declare_filesets\] NAME:${name} TYPE:${type} CALLBACK:${callback}"
      return
    }
    ip_add "fileset.${name}" $type $callback

    # Iterate over and set properties
    set prop_list [get_property_list $i_filesets]
    set prop_vals [get_property_values $i_filesets $name]
    for {set j 0} {$j < [llength $prop_list]} {incr j} {
      # Get property label
      set prop [lindex $prop_list $j]
      set val [lindex $prop_vals $j]
      # Ignore special cases
      if { [lsearch {NAME TYPE CALLBACK} $prop] == -1 } {
        ip_set "fileset.${name}.${prop}" $val
      }
    }
  }
}

proc ::alt_xcvr::ip_tcl::ip_module::ip_validate_parameters {} {
  variable i_parameters
  variable validated_list
  variable validated_stack
  
  set length [get_item_count $i_parameters]

  # Clear validated list
  set validated_list {}
  set validated_stack {}

  for {set i 1} {$i < $length} {incr i} {
    set name  [get_item_name $i_parameters $i]
   #dprint "\[ip_validate_parameters\] name:$name"
    if {$name == ""} {
      ::alt_xcvr::ip_tcl::messages::internal_error "\[ip_validate_parameters\] Invalid name:$name"
      return
    }
    validate_parameter $name
  }

}

proc ::alt_xcvr::ip_tcl::ip_module::ip_elaborate_interfaces {} {
  variable i_interfaces
  variable dynamic_elab

  if { $dynamic_elab == "NOVAL" } {
    set dynamic_elab true
  }

  for {set i 1} {$i < [get_item_count $i_interfaces]} {incr i} {
    set name [get_item_name $i_interfaces $i]
    elaborate_interface $name
  }
}


proc ::alt_xcvr::ip_tcl::ip_module::ip_upgrade { ip_name ip_version old_params param_map } {

  set declared_param_list [get_parameters]
  set headers       [lindex $param_map 0]
  set version_index [lsearch $headers "VERSION"]
  set parameter_index [lsearch $headers "PARAMETER"]
  set old_parameter_index [lsearch $headers "OLD_PARAMETER"]
  set val_map_index [lsearch $headers "VAL_MAP"]

  if { [expr {$version_index == -1 || $parameter_index == -1 || $old_parameter_index == -1}] } {
    ::alt_xcvr::ip_tcl::messages::internal_error "\[ip_upgrade\] invalid headers in param_map: ${param_map}"
    return
  }

  # Iterate over old parameters
  foreach {param_name param_value} $old_params {
    set param_value [string trim $param_value]
    # Default to existing parameter name and value
    set new_param_name $param_name
    set new_param_value $param_value

    # Iterate over parameter map looking for replacement
    for {set i 1 } { $i < [llength $param_map] } { incr i } {
      set data [lindex $param_map $i]
      set version [lindex $data $version_index]
      set parameter [lindex $data $parameter_index]
      set old_parameter [lindex $data $old_parameter_index]
      # Grab value map if it exists
      set val_map NOVAL
      if {[expr {$val_map_index != -1 }]} {
        set val_map [lindex $data $val_map_index] 
      }
      # Check for version match
      if {$version == $ip_version} {
        # Check for parameter match
        if {$old_parameter == $param_name} {
          # Replace old parameter name with new parameter name
          set new_param_name $parameter
          # Check for value remapping
          if { $val_map != "NOVAL" } {
            foreach {old_map_val new_map_val} $val_map {
              if {[string compare $old_map_val $param_value] == 0} {
                # Replace old parameter value with new parameter value
                set new_param_value $new_map_val
              }
            }
          }
          ::alt_xcvr::ip_tcl::messages::ip_message info "Upgrade from ${ip_name} v${ip_version} ${param_name}(${param_value}) -> ${new_param_name}(${new_param_value})."
        }
      }
    }
    # Finished iterating over parameter map
    #
    # See if the parameter still exists. If not, remove it.
    if { [lsearch $declared_param_list $new_param_name] == -1 } {
      ::alt_xcvr::ip_tcl::messages::ip_message info "Upgrade from ${ip_name} v${ip_version}. Removing parameter ${new_param_name}"
      set new_param_name NOVAL
    }
    # Set the new parameter name and value unless it was removed
    if {$new_param_name != "NOVAL"} {
      ip_set "parameter.${new_param_name}.value" $new_param_value
    }
  }
}


# Add a display_item or parameter
proc ::alt_xcvr::ip_tcl::ip_module::ip_add { attribute args} {
  variable alist
  variable alength

 #dprint "\[ip_add\] attribute:${attribute} args:${args}"
  parse_alist $attribute
  set type [get_alist_index 0]
  set name [get_alist_index 1]
  set command "" 
  if {$type == "parameter"} {
    # Parameters
    set command "add_parameter \"$name\""
  } elseif {$type == "display_item"} {
    # Display items
    # Must be of format "display_item.<group>.<display_item_name>"
    set group $name
    set name [get_alist_index 2]
    set command "add_display_item \"${group}\" \"${name}\""
  } elseif {$type == "interface"} {
    # Interfaces
    set command "add_interface \"${name}\""
  } elseif {$type == "port"} {
    # Ports
    set iface_name $name
    set name [get_alist_index 2]
    set command "add_interface_port \"${iface_name}\" \"${name}\""
  } elseif {$type == "fileset"} {
    # Filesets
    set command "add_fileset \"${name}\""
  } else {
    return
  }
  foreach arg $args {
    set command "${command} \"${arg}\""
  }
  eval $command
}

proc ::alt_xcvr::ip_tcl::ip_module::ip_set { attribute {value NOVAL} } {
  variable alist
  variable alength

 #dprint "\[ip_set\] attribute:${attribute} value:${value}"
  parse_alist $attribute

  set type [get_alist_index 0]
  set name [get_alist_index 1]
  set prop ""
  if {$alength > 2} {
    set prop [get_alist_index 2]
  }

  if {$type == "module"} {
    # Module properties
    set_module_property $name $value
  } elseif {$type == "parameter"} {
    # Parameters
    if { [string tolower $prop] == "display_item" } {
      add_display_item $value $name parameter
    } elseif { [string tolower $prop] == "value" } {
      set_parameter_value $name $value
    } else {
      set_parameter_property $name $prop $value
    }
  } elseif {$type == "display_item"} {
    set_display_item_property $name $prop $value
  } elseif {$type == "interface"} {
    # Interfaces
    if {$prop == "assignment"} {
      eval set_interface_assignment $name $value
    } else {
      set_interface_property $name $prop $value
    }
  } elseif {$type == "port"} {
    set_port_property $name $prop $value
  } elseif {$type == "fileset"} {
    set_fileset_property $name $prop $value
  }
}

proc ::alt_xcvr::ip_tcl::ip_module::ip_get { attribute } {
  variable alist
  variable alength
  parse_alist $attribute


 #dprint "\[ip_get\] attribute:${attribute}"
  parse_alist $attribute

  set type [get_alist_index 0]
  set name [get_alist_index 1]
  if {$type == "module"} {
    return get_module_property $name
  } elseif {$type == "parameter"} {
    set prop [get_alist_index 2]
    if {[string tolower $prop] == "value"} {
      return [get_parameter_value $name]
    } else {
      return [get_parameter_property $name $prop]
    }
  }
}

proc ::alt_xcvr::ip_tcl::ip_module::ip_debug_print_tree{ } {
}


##############################################################################
############################ Internal Functions ##############################
proc ::alt_xcvr::ip_tcl::ip_module::parse_alist { arg } {
  variable alist
  variable alength

 #dprint "\[parse_alist\] arg:$arg"
  set alist [split $arg "."]
  set alength [llength $alist]
 #dprint "\[parse_alist\] alist:${alist} alength:${alength}"
}

proc ::alt_xcvr::ip_tcl::ip_module::get_alist_index { index } {
  variable alist
  variable alength

  if { [expr {$alength <= $index}] } {
    ::alt_xcvr::ip_tcl::messages::internal_error "\[get_alist_index\] Invalid index:$index"
  } else {
    return [lindex $alist $index]
  }
}

# Perform validation for the parameter specified by name
# This function recursively validates any antecedent parameters
#
# @param name - The name of the parameter to validate
proc ::alt_xcvr::ip_tcl::ip_module::validate_parameter { name } {
  variable i_parameters
  variable validated_list
  variable validated_stack

  # Throw an error if the parameter is already on the stack (cyclical dependency)
  if {[lsearch $validated_stack $name] != -1} {
      ::alt_xcvr::ip_tcl::messages::internal_error "\[ip_module::validate_parameter\] Cyclical parameter dependency! Parameter stack (top->bottom): ${name} ${validated_stack}"
  } else {
      set validated_stack [linsert $validated_stack 0 $name]
  }

  set thisvalue [ip_get "parameter.${name}.value"]

  # Return current value if already validated
  if {[lsearch $validated_list $name] != -1} {
    set validated_stack [lreplace $validated_stack 0 0]
    return $thisvalue
  }

  # Mark this parameter as validated
  lappend validated_list $name

  # Special cases
  validate_prop_from_param $i_parameters $name "ENABLED" boolean 1
  validate_prop_from_param $i_parameters $name "VISIBLE" boolean 1

  # Retrieve the callback
  set callback [get_item_property $i_parameters $name VALIDATION_CALLBACK]

  # Retrieve the antecedents and call the callback
  if {$callback != "NOVAL"} {
    set antecedents [info args $callback]
    set vals {}
    foreach ant $antecedents {
      if {$ant == $name || $ant == "PROP_VALUE"} {
        lappend vals $thisvalue
      } elseif { [string first "PROP_" $ant] == 0 } {
        set prop [string replace $ant 0 4]
        # Obtain the property value from the table
        lappend vals [get_item_property $i_parameters $name $prop]
      } else {
        lappend vals [validate_parameter $ant]
      }
    }
    # Call the callback function
   #dprint "\[validate_parameter\] Calling ${callback} ${vals}"
    eval $callback $vals
    set thisvalue [ip_get "parameter.${name}.value"]
  }
  set validated_stack [lreplace $validated_stack 0 0]
  return $thisvalue
}


proc ::alt_xcvr::ip_tcl::ip_module::elaborate_interface { name } {
  variable i_interfaces
  variable dynamic_elab

  # Grab this interface properties for later use
  set iface_name      [get_item_property $i_interfaces $name IFACE_NAME]
  set iface_type      [get_item_property $i_interfaces $name IFACE_TYPE]
  set iface_direction [get_item_property $i_interfaces $name IFACE_DIRECTION]
  set callback        [get_item_property $i_interfaces $name ELABORATION_CALLBACK]
  set iface_dynamic   [get_item_property $i_interfaces $name DYNAMIC]
  set ui_direction    [get_item_property $i_interfaces $name UI_DIRECTION]
  set iface_split     false
  set iface_split_count 1
  
  # Don't elaborate a dynamic interface during static declaration
  if {$iface_dynamic == "NOVAL"} { set iface_dynamic false }
  if {$dynamic_elab == "false" && $iface_dynamic == "true"} {
    return
  }

  # Use the port name as the interface name IF there is no callback
  if {$iface_name == "NOVAL" && $callback == "NOVAL"} {
    set iface_name $name
  }
  
  set base_iface_name $iface_name
  # If the IFACE has not been specified there must be a callback
  if {$iface_name == "NOVAL" || $iface_type == "NOVAL" || $iface_direction == "NOVAL"} {
    if {$callback == "NOVAL"} {
      ::alt_xcvr::ip_tcl::messages::internal_error "\[elaborate_interface\] Invalid values IFACE_NAME:$iface_name IFACE_TYPE:$iface_type IFACE_DIRECTION:$iface_direction"
      return
    }
  } else {
    # We're here because sufficient information was provided to declare the interface

    # Determine if splitting is requested
    set iface_split       [validate_prop_from_param $i_interfaces $name SPLIT       boolean]
    set iface_split_count [validate_prop_from_param $i_interfaces $name SPLIT_COUNT integer]
    set iface_split_width [validate_prop_from_param $i_interfaces $name SPLIT_WIDTH integer]
    if {$iface_split == "true" } {
      if { $iface_split_count == "NOVAL" || $iface_split_width == "NOVAL" } {
        ::alt_xcvr::ip_tcl::messages::internal_error "\[elaborate_interface\] Invalid values IFACE_NAME:${iface_name} SPLIT:$iface_split SPLIT_COUNT:$iface_split_count SPLIT_WIDTH:$iface_split_width"
        return
      }
    } else {
      set iface_split_count 1
    }

    for {set i 0} {$i < $iface_split_count} {incr i} {
      if {$iface_split == "true"} {
        set iface_name "${base_iface_name}${i}"
      }

      # Only continue if elaboration phase matches
      if { $dynamic_elab == $iface_dynamic } {
        # Add the interface if not already declared
        # TODO - replace get_interfaces call
        if {[lsearch [get_interfaces] $iface_name] == -1} {
          ip_add "interface.${iface_name}" $iface_type $iface_direction
        }
      }
  
      # Now elaborate the port
      elaborate_port $iface_name $name $iface_split $i $iface_split_width
      if { $ui_direction != "NOVAL" } {
        ip_set "interface.${iface_name}.assignment" [list "ui.blockdiagram.direction" $ui_direction]
      }
    }
  }
  # Done adding interface
  
  # Call elaboration callback (only in dynamic phase)
  if {$callback != "NOVAL" && $dynamic_elab == "true" } {
    for {set i 0} {$i < $iface_split_count} {incr i} {
      if {$iface_split == "true"} {
        set iface_name "${base_iface_name}${i}"
      }
      execute_interface_callback $iface_name $name $callback
    }
  }
}



###
# Elaborate an interface port. The interface must already exist.
#
# @param iface
proc ::alt_xcvr::ip_tcl::ip_module::elaborate_port { iface_name name {split_port false} {split_index 0} {split_width 0}} {
  variable i_interfaces
  variable dynamic_elab
  variable port_ignore_list

  # List properties ignored by port assignment
  set boolean_props    {TERMINATION}
  set integer_props    {TERMINATION_VALUE}

  # Get the port role
  set role  [get_item_property $i_interfaces $name ROLE]
  if {$role != "NOVAL"} {
    # We're here because sufficient information was provided to declare the port
    set pname $name
    if {$split_port == "true" } {
      set pname "${pname}${split_index}"
    }
    # Add the port to the interface
    ip_add "port.${iface_name}.${pname}" $role

    # Special handling for split ports
    if {$split_port == "true" } {
      # Set the width if the port is split
      ip_set "port.${pname}.WIDTH_EXPR" $split_width

      # Set the fragment list
      set frag_base [expr {$split_index * $split_width}]
      set frag_top [expr {$split_index * $split_width + $split_width - 1}]

      for {set w 0} {$w < $split_width} {incr w} {
        lappend port_temp ${name}@[expr $frag_base + $w]
      }

      #set port_flipped [lrange $port_temp $frag_base $frag_top]

      ip_set "port.${pname}.FRAGMENT_LIST" $port_temp
    }
  
    # We can only elaborate further during elaboration (not static)
    if {$dynamic_elab == "true"} {
      # Retrieve and set all port properties from list
      set prop_list  [get_property_list $i_interfaces]
      set prop_vals  [get_property_values $i_interfaces $name]
      for {set j 0} {$j < [llength $prop_list]} {incr j} {
  
        # Retrieve property type and value
        set prop  [lindex $prop_list $j]
        set val   [lindex $prop_vals $j]
  
       #dprint "\[elaborate_port\] j:${j} prop:${prop} val:${val}"
  
        # Special property handling
        if { $split_port == "true" && $prop == "WIDTH_EXPR" } {
          set val NOVAL
        }

        if { [lsearch $port_ignore_list $prop] != -1 } {
          # These properties do not get set
          set val NOVAL
        } elseif { [string first "M_" $prop] == 0 } {
          # Ignore custom metadata attributes (prefix with "M_")
          set val NOVAL
        } elseif { [lsearch $boolean_props $prop] != -1 } {
          # Boolean properties may be associated with a parameter
          set val [validate_prop_from_param $i_interfaces $name $prop boolean]
        } elseif { [lsearch $integer_props $prop] != -1 } {
          set val [validate_prop_from_param $i_interfaces $name $prop integer]
        }
  
        # Set the port property
        if { $val != "NOVAL" } {
          ip_set "port.${pname}.${prop}" $val
        }
      }
    }
  }
  # Done adding port
}



###
# Execute an interface's callback function
proc ::alt_xcvr::ip_tcl::ip_module::execute_interface_callback { iface_name name callback } {
  variable i_interfaces

  set antecedents [info args $callback]
  set vals {}
  foreach ant $antecedents {
    # If the argument calls for a property value
    if { [string first "PROP_" $ant] == 0 } {
      set prop [string replace $ant 0 4]
      # Special properties
      if { $prop == "IFACE_NAME" } {
        # For IFACE_NAME, pass the resolved value
        lappend vals $iface_name
      } else { 
        # Obtain the property value from the table
        lappend vals [get_item_property $i_interfaces $name $prop]
      }
    } else {
      lappend vals [ip_get "parameter.${ant}.value"]
    }
  }
  # Call the callback function
 #dprint "\[elaborate_interfaces\] Calling ${callback} ${vals}"
  eval $callback $vals
}


###
# Obtain a property's value from a parameter if appropriate
#
# @param data - The data structure containing the properties and values
# @param name - The name of the element of interest.
# @param prop - The property of interest for thte element of interest
# @param type - The property type (boolean or integer)
# @param set_param - Optional - for parameters only. Set the parameter's value once obtained
proc ::alt_xcvr::ip_tcl::ip_module::validate_prop_from_param { data name prop type {set_param 0}} {

  # Get the property value
  set val [get_item_property $data $name $prop]
 #dprint "\[validate_prop_from_param\] name:${name} prop:${prop} val:${val}"
  if {$val != "NOVAL"} {

    # See if value is known
    set known [string is $type -strict [string tolower $val]]
   #dprint "\[validate_prop_from_param\] prop:${prop} val:${val} known:${known}"

    # If the value is unknown, assume parameter expression
    if { $known == 0 } {
      # get value from expression
      set val [convert_param_expr $val]
      set val [expr $val]
      if {$type == "boolean"} {
        if {$val == 0} {
          set val false
        } elseif {$val == 1} {
          set val true
        }
      }
    }
  }
  # Set the value if requested
  if {$val != "NOVAL" && $set_param == 1} {
    ip_set "parameter.${name}.${prop}" $val
  }
  return $val
}

proc ::alt_xcvr::ip_tcl::ip_module::get_property_list { data } {
  return [lindex [get_item_data $data] 0]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_property_values { data name } {
  return [lindex [get_item_data $data] [get_item_index $data $name]]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_prop_index { data prop } {
  return [lsearch [lindex [get_item_data $data] 0] $prop]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_item_index { data name } {
  return [lsearch [get_item_list $data] $name]  
}

proc ::alt_xcvr::ip_tcl::ip_module::get_item_name { data index } {
  return [lindex [get_item_list $data] $index]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_property_count { data } {
  return [llength [get_property_list $data]]
}
proc ::alt_xcvr::ip_tcl::ip_module::get_item_count { data } {
  return [llength [get_item_list $data]]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_item_list { data } {
  return [lindex $data 0]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_item_data { data } {
  return [lindex $data 1]
}

proc ::alt_xcvr::ip_tcl::ip_module::get_item_property { data name prop } {

 #dprint "\[get_item_property\] name:${name} prop:${prop}"
  set prop_index [get_prop_index $data $prop]

 #dprint "\[get_item_property\] prop_index:${prop_index} "
  if {$prop_index == -1} {
    return "NOVAL"
  }

  return [lindex [get_property_values $data $name] $prop_index]
}

proc ::alt_xcvr::ip_tcl::ip_module::add_data_prop { tgt_data_member prop } {
  variable $tgt_data_member
}

proc ::alt_xcvr::ip_tcl::ip_module::add_item_data { data tgt_data_member } {
  variable $tgt_data_member
}


# Modifies the expression passed to replace all reference to parameters with calls to validate that parameter
proc ::alt_xcvr::ip_tcl::ip_module::convert_param_expr { old_expr } {
  regsub -all {[!~|&+-]} $old_expr " " new_expr
  regsub -all {[*/%]} $new_expr " " new_expr
  set new_expr [join $new_expr " "]

  # Replace parameter references with validation calls
  # We have to watch out for args whose strings are a subexpression of another arg.
  set arglist [split $new_expr " "]
  if {[llength $arglist] > 1} {
    set arglist [lsort -decreasing $arglist]
  }

  # Replace args with tags
  set index 0
  foreach arg $arglist {
    set tag "tagtag${index}tagtag"
    regsub -all $arg $old_expr $tag old_expr
    incr index
  }

  # Replace tags with calls
  set index 0
  foreach arg $arglist {
    set tag "tagtag${index}tagtag"
    regsub -all $tag $old_expr "\[validate_parameter ${arg}\]" old_expr
    incr index
  }

  return $old_expr
}


proc ::alt_xcvr::ip_tcl::ip_module::convert_data_to_dict { data } {
  
  set this_dict

  set headers [lindex $data 0]  
  set length [llength $data]
  set nameindex [lsearch $headers NAME]
  for {set i 1} {$i < $length} {incr i} {
    set this_entry [lindex $data $i]
    set key [lindex $this_entry $nameindex]
    for {set j 0} {$j < [llength $this_entry]} {incr j} {
      dict set this_dict $key [lindex $headers $j] [lindex $this_entry $j]
    }
  }
  return $this_dict
}

proc ::alt_xcvr::ip_tcl::ip_module::index_data { data } {
  set name_index [lsearch [lindex $data 0] NAME]

  set indices {}
  for {set i 0} {$i < [llength $data]} {incr i} {
    lappend indices [lindex [lindex $data $i] $name_index]
  } 
  return $indices
}


proc ::alt_xcvr::ip_tcl::ip_module::dprint { str } {
  variable debug
  variable lasttime

  if { $debug == 1 } {
    set time [clock clicks -milliseconds]
    puts "$str : $time [expr $time - $lasttime]"
    set lasttime $time
  }
}
########################## End Internal Functions ############################
##############################################################################
