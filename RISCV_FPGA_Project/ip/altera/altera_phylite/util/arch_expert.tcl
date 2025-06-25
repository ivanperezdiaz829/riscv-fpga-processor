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


# package: altera_phylite::util::arch_expert
#
# The arch_expert module provides an abstraction layer for querying 
# architecture-specific information without knowing what the current
# architecture is.
#
package provide altera_phylite::util::arch_expert 0.1

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################
package require altera_emif::util::messaging
package require altera_emif::util::qini
package require altera_emif::util::hwtcl_utils
package require altera_emif::util::enums
package require altera_phylite::util::enum_defs

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::altera_phylite::util::arch_expert:: {
   # Namespace Variables
   
   # Import functions into namespace
   namespace import ::altera_emif::util::messaging::*
   namespace import ::altera_emif::util::qini::*
   namespace import ::altera_emif::util::enums::*

   # Export functions
   
   # Package variables
}

################################################################################
###                          TCL PROCEDURES                                  ###
################################################################################

# proc: get_arch_component_qsys_name
#
# Get the QSYS IP name for the architecture component of the current family
#
proc ::altera_phylite::util::arch_expert::get_arch_component_qsys_name {} {

   set family_enum [::altera_emif::util::device_family::get_base_device_family_enum]
   
   if {$family_enum == "" || $family_enum == "FAMILY_INVALID"} {
      emif_ie "No device family info available. ::altera_phylite::util::arch_expert can only be used during IP validation, composition, or fileset generation"
   }
   return [enum_data "PHYLITE_${family_enum}" ARCH_COMPONENT]
}

# proc: get_legal_pll_ref_clk_freqs_mhz
#
# Get list of legal PLL ref clock frequencies (in MHz)
#
proc ::altera_phylite::util::arch_expert::get_legal_pll_ref_clk_freqs_mhz {mem_clk_freq_mhz clk_ratios max_entries} {
   set func_name [_get_func_name "get_legal_pll_ref_clk_freqs_mhz"]
   return [$func_name $mem_clk_freq_mhz $clk_ratios $max_entries]
}

# proc: get_legal_read_latencies
#
# Get string range of legal read latencies
#
proc ::altera_phylite::util::arch_expert::get_legal_read_latencies {} {
   set func_name [_get_func_name "get_legal_read_latencies"]
   return [$func_name]
}


################################################################################
###                       PRIVATE FUNCTIONS                                  ###
################################################################################

# proc: _get_func_name
#
# Private function to generate the name of a function that exists in a 
# protocol specific package.
#
# parameters:
#   base_name - Base function name
#
# returns:
#   A string for the function name
#
proc ::altera_phylite::util::arch_expert::_get_func_name {base_name} {

   set arch_component [get_arch_component_qsys_name]
   if {[regexp -lineanchor "^altera_phylite_(.+)\$" $arch_component matched tcl_package]} {
   
      # Generate fully resolved Tcl package name for the arch component
      set full_module "altera_phylite::ip_${tcl_package}::arch_expert_exports"
      
      # Dynamically load that package (no-op if already loaded)
      package require $full_module
      
      # Generate the function name and make sure it exists
      set func_name "::${full_module}::${base_name}"
      if {[llength [info proc $func_name]] != 1} {
         emif_ie "Function $func_name is expected to be implemented but is not!"
      }
      return $func_name      
   } else {
      emif_ie "Unable to parse tcl package name from IP component name $arch_component"
   }
}

# proc: _init
#
# Private function to initialize internal constants
#
# parameters:
#
# returns:
#
proc ::altera_phylite::util::arch_expert::_init {} {
}

################################################################################
###                   AUTO RUN CODE AT STARTUP                               ###
################################################################################
# Run the initialization
::altera_phylite::util::arch_expert::_init
