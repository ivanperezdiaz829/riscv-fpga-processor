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


package provide alt_xcvr::utils::params_and_ports 11.1

namespace eval ::alt_xcvr::utils::params_and_ports:: {
  namespace export \
    common_set_parameter_tag \
    common_add_parameter \
    common_set_parameter_group \
    common_set_port_tag \
    common_add_interface_port \
    common_set_port_group \
    common_get_tagged_property_state

  # record parameters and conditional markings
  # e.g. S4-only parameters could be param_tags(pll_lock_speed) = "S4"
  variable param_tags
  array set param_tags {}

  # record ports and conditional markings
  # e.g. ports relevent only with 8B10B enabled could be common_port_tags(tx_datak) = "ENA8B10B"
  variable port_tags
  array set port_tags {}

  # record the last state of each marking as true or false
  # e.g. S4 tag, VISIBLE property marking, last state would be:
  # tagged_property_state("S4/VISIBLE") = false
  variable tagged_property_state
  array set tagged_property_state {}
}

############################################
# +-----------------------------------------
# | Parameter & port management via tagging
# +-----------------------------------------
############################################


# +--------------------------------------------------------------------------------
# | Mark a parameter with a tag list
# |
proc ::alt_xcvr::utils::params_and_ports::common_set_parameter_tag {param tags} {
  variable param_tags
  set param_tags($param) $tags
}

# +--------------------------------------------------------------------------------
# | 'add_parameter' wrapper that also tags a parameter for later property updates
# |
proc ::alt_xcvr::utils::params_and_ports::common_add_parameter {param pType pDefVal tags} {
  add_parameter $param $pType $pDefVal
  if { [string length $pDefVal ] > 0 } {
    set_parameter_property $param DEFAULT_VALUE $pDefVal
  }
  common_set_parameter_tag $param $tags
}

# +------------------------------------------------------------------------------------
# | Set property to given state for all parameters marked with given tags
# | 
proc ::alt_xcvr::utils::params_and_ports::common_set_parameter_group { tags pProperty state } {
  variable param_tags
  variable tagged_property_state

  foreach tag $tags {
    if {![info exists tagged_property_state("$tag/$pProperty") ] ||
       $tagged_property_state("$tag/$pProperty") != $state} {
      
      # update given property of each parameter marked with given label
      foreach {p pTags} [array get param_tags ] {
        if { [lsearch -exact $pTags $tag ] > -1 } {
          set_parameter_property $p $pProperty $state
        }
      }
      
      # mark new state for this tag & property
      set tagged_property_state("$tag/$pProperty") $state
    }
  }
}


# +--------------------------------------------------------------------------------
# | Mark a port with a tag list
# |
proc ::alt_xcvr::utils::params_and_ports::common_set_port_tag {pName tags} {
  variable port_tags
  set port_tags($pName) $tags
}

# +--------------------------------------------------------------------------------
# | 'add_interface_port' wrapper that also tags a port for later property updates
# |
proc ::alt_xcvr::utils::params_and_ports::common_add_interface_port {interfaceName pName pRole pDir pWidth tags} {
  add_interface_port $interfaceName $pName $pRole $pDir $pWidth
  common_set_port_tag $pName $tags
}

# +------------------------------------------------------------------------------------
# | Set property to given state for all ports marked with given tags
# | 
proc ::alt_xcvr::utils::params_and_ports::common_set_port_group { tags pProperty state } {
  variable port_tags
  variable tagged_property_state

  foreach tag $tags {
#   if {![info exists tagged_property_state("$tag/$pProperty") ] ||
#      $tagged_property_state("$tag/$pProperty") != $state} {
      
      # update given property of each port marked with given label
      foreach {p pTags} [array get port_tags ] {
        if { [lsearch -exact $pTags $tag ] > -1 } {
          set_port_property $p $pProperty $state
        }
      }
      
      # mark new state for this tag & property
      set tagged_property_state("$tag/$pProperty") $state
#   }
  }
}

# +--------------------------------------------
# | Get tag state for a given tag and property
# | 
proc ::alt_xcvr::utils::params_and_ports::common_get_tagged_property_state { tag pProperty {stateDef 0} } {
  variable tagged_property_state

  set state $stateDef
  if {[info exists tagged_property_state("$tag/$pProperty") ] } {
    # get last set state for this tag & property
    set state $tagged_property_state("$tag/$pProperty")
  }
  return $state
}

