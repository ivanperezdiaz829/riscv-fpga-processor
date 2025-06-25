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


# $File: //acds/rel/13.1/ip/sopc/components/verification/altera_tristate_conduit_bfm/altera_tristate_conduit_bfm_hw.tcl $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
# +-----------------------------------------------------------------------------
# | 
# | altera_tristate_conduit_bfm
# | Altera Tri-state Conduit BFM
# | 
# +-----------------------------------------------------------------------------

package require -exact qsys 13.1
package require -exact altera_terp 1.0

set_module_property NAME                         altera_tristate_conduit_bfm
set_module_property DISPLAY_NAME                 "Altera Tri-State Conduit BFM"
set_module_property DESCRIPTION                  "Altera Tri-State Conduit BFM"
set_module_property VERSION                      13.1
set_module_property GROUP                        "Avalon Verification Suite"
set_module_property AUTHOR                       "Altera Corporation"
set_module_property EDITABLE                     false   
set_module_property INTERNAL                     false  
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property ANALYZE_HDL                  false
set_module_property HIDE_FROM_SOPC               true
# set_module_property VALIDATION_CALLBACK          validate

# +------------------------------------------------------------------------------
# | Files
# +------------------------------------------------------------------------------
# Define file set
add_fileset synthesis QUARTUS_SYNTH quartus_synth_proc
add_fileset verilog SIM_VERILOG simverilog
add_fileset vhdl SIM_VHDL simvhdl

# get all the signal informations and rearrage them to be use in the terp template file
proc setup_terp_signal_information {} {
   set SIGNAL_ROLES            [ get_parameter_value SIGNAL_ROLES ]
   set SIGNAL_WIDTHS           [ get_parameter_value SIGNAL_WIDTHS ]
   set SIGNAL_USE_OUTPUT       [ get_parameter_value SIGNAL_USE_OUTPUT ]
   set SIGNAL_USE_OUTPUTENABLE [ get_parameter_value SIGNAL_USE_OUTPUTENABLE ]
   set SIGNAL_USE_INPUT        [ get_parameter_value SIGNAL_USE_INPUT ]
   
   set rolemap ""
   foreach role ${SIGNAL_ROLES} width ${SIGNAL_WIDTHS} use_output ${SIGNAL_USE_OUTPUT} use_outputenable ${SIGNAL_USE_OUTPUTENABLE} use_input ${SIGNAL_USE_INPUT} {
      if {$rolemap==""} {
          set rolemap "${role}:${width}:${use_output}:${use_outputenable}:${use_input}"
      } else {
          set rolemap "${rolemap},${role}:${width}:${use_output}:${use_outputenable}:${use_input}"
      }
   }
   return $rolemap
}

# run the terp template file
proc do_terp { template_file rolemap instance_name $file_name file_type} {
   
   set this_dir      [ get_module_property MODULE_DIRECTORY ]
   set template_file [ file join $this_dir $template_file ]   
   set template      [ read [ open $template_file r ] ]
    
   set params(output_name)       $instance_name
   set params(rolemap)           $rolemap
   set params(max_mult_trans)    [get_parameter_value MAX_MULTIPLE_TRANSACTION]

   set file_ext "sv"
   if {[string equal $file_type "SYSTEM_VERILOG"]} {
      set file_ext "sv"
   } elseif {[string equal $file_type "VHDL"]} {
      set file_ext "vhd"
   }
   
   set result          [ altera_terp $template params ]
   set output_file     ${$file_name}.${file_ext}
   
   add_fileset_file $output_file $file_type TEXT $result   
}

# verilog fileset generation procedure
proc simverilog { instance_name } {
   
   set rolemap [setup_terp_signal_information]
   
   set HDL_LIB_DIR      "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/verbosity_pkg.sv
   do_terp "altera_tristate_conduit_bfm.sv.terp" $rolemap $instance_name $instance_name SYSTEM_VERILOG
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
}

proc quartus_synth_proc { instance_name } {
   
   set rolemap [setup_terp_signal_information]
   
   set HDL_LIB_DIR      "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/verbosity_pkg.sv
   do_terp "altera_tristate_conduit_bfm.sv.terp" $rolemap $instance_name $instance_name SYSTEM_VERILOG
}

# vhdl fileset generation procedure
proc simvhdl { instance_name } {
   
   set rolemap [setup_terp_signal_information]

   do_terp "altera_tristate_conduit_bfm_vhdl_pkg.vhd.terp" $rolemap $instance_name ${instance_name}_vhdl_pkg VHDL
   do_terp "altera_tristate_conduit_bfm.vhd.terp" $rolemap $instance_name $instance_name VHDL
}

# +-----------------------------------------------------------------------------
# |Parameters
# +-----------------------------------------------------------------------------
set MAX_MULTIPLE_TRANSACTION     "MAX_MULTIPLE_TRANSACTION"

add_display_item "" "Interface Signals" "group" "table"

add_parameter SIGNAL_ROLES STRING_LIST "sig"
set_parameter_property SIGNAL_ROLES DISPLAY_NAME "Role"
set_parameter_property SIGNAL_ROLES AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ROLES GROUP "Interface Signals"

add_parameter SIGNAL_WIDTHS INTEGER_LIST 1
set_parameter_property SIGNAL_WIDTHS DISPLAY_NAME "Width"
set_parameter_property SIGNAL_WIDTHS ALLOWED_RANGES 1:1024
set_parameter_property SIGNAL_WIDTHS GROUP "Interface Signals"

add_parameter SIGNAL_USE_OUTPUT INTEGER_LIST 1
set_parameter_property SIGNAL_USE_OUTPUT DISPLAY_NAME "USE_OUTPUT"
set_parameter_property SIGNAL_USE_OUTPUT DISPLAY_HINT boolean
set_parameter_property SIGNAL_USE_OUTPUT ALLOWED_RANGES {0,1}
set_parameter_property SIGNAL_USE_OUTPUT GROUP "Interface Signals"

add_parameter SIGNAL_USE_OUTPUTENABLE INTEGER_LIST 1
set_parameter_property SIGNAL_USE_OUTPUTENABLE DISPLAY_NAME "USE_OUTPUTENABLE"
set_parameter_property SIGNAL_USE_OUTPUTENABLE DISPLAY_HINT boolean
set_parameter_property SIGNAL_USE_OUTPUTENABLE ALLOWED_RANGES {0,1}
set_parameter_property SIGNAL_USE_OUTPUTENABLE GROUP "Interface Signals"

add_parameter SIGNAL_USE_INPUT INTEGER_LIST 1
set_parameter_property SIGNAL_USE_INPUT DISPLAY_NAME "USE_INPUT"
set_parameter_property SIGNAL_USE_INPUT DISPLAY_HINT boolean
set_parameter_property SIGNAL_USE_INPUT ALLOWED_RANGES {0,1}
set_parameter_property SIGNAL_USE_INPUT GROUP "Interface Signals"

add_parameter $MAX_MULTIPLE_TRANSACTION Integer 1024
set_parameter_property $MAX_MULTIPLE_TRANSACTION DISPLAY_NAME "Maximum multiple transaction"
set_parameter_property $MAX_MULTIPLE_TRANSACTION AFFECTS_ELABORATION true
set_parameter_property $MAX_MULTIPLE_TRANSACTION DESCRIPTION "Maximum multiple data to be driven out while request and grant remain asserted, please override the parameter through test bench because generated HDL with parameter is not supported."
set_parameter_property $MAX_MULTIPLE_TRANSACTION ENABLED false
# set_parameter_property $MAX_MULTIPLE_TRANSACTION HDL_PARAMETER true -- not supported
set_parameter_property $MAX_MULTIPLE_TRANSACTION GROUP "Multiple Transaction Attributes"

set PARAMETER_LIST [get_parameters]
foreach PARAMETER $PARAMETER_LIST {
   set_parameter_property $PARAMETER AFFECTS_GENERATION false
}

# +-----------------------------------------------------------------------------
# | Validation callback
# +-----------------------------------------------------------------------------
# proc validate {} {

# }

# +-----------------------------------------------------------------------------
# | Elaboration callback
# +-----------------------------------------------------------------------------
proc elaborate {} {
   
   global MAX_MULTIPLE_TRANSACTION
   
   set MAX_MULTIPLE_TRANSACTION_VALUE  [ get_parameter_value MAX_MULTIPLE_TRANSACTION ]
   set SIGNAL_ROLES                    [ get_parameter_value SIGNAL_ROLES ]
   set SIGNAL_WIDTHS                   [ get_parameter_value SIGNAL_WIDTHS ]
   set SIGNAL_USE_OUTPUT               [ get_parameter_value SIGNAL_USE_OUTPUT ]
   set SIGNAL_USE_OUTPUTENABLE         [ get_parameter_value SIGNAL_USE_OUTPUTENABLE ]
   set SIGNAL_USE_INPUT                [ get_parameter_value SIGNAL_USE_INPUT ]

   set L_SIGNAL_ROLES                  [llength $SIGNAL_ROLES]
   set L_SIGNAL_WIDTHS                 [llength $SIGNAL_WIDTHS]
   set L_SIGNAL_USE_OUTPUT             [llength $SIGNAL_USE_OUTPUT]
   set L_SIGNAL_USE_OUTPUTENABLE       [llength $SIGNAL_USE_OUTPUTENABLE]
   set L_SIGNAL_USE_INPUT              [llength $SIGNAL_USE_INPUT]
   
   # +--------------------------------------------------------------------------
   # | Clock-Reset connection point
   # +--------------------------------------------------------------------------
   add_interface clk clock end
   add_interface_port clk clk clk Input 1

   # add_interface clk_reset reset end
   # add_interface_port clk_reset reset reset Input 1
   # set_interface_property clk_reset associatedClock clk
   
   # +--------------------------------------------------------------------------
   # | Add Tri-state Conduit Interface
   # +--------------------------------------------------------------------------
   
   if { $L_SIGNAL_ROLES != $L_SIGNAL_WIDTHS || $L_SIGNAL_ROLES != $L_SIGNAL_USE_OUTPUT || 
      $L_SIGNAL_ROLES != $L_SIGNAL_USE_OUTPUTENABLE || $L_SIGNAL_ROLES != $L_SIGNAL_USE_INPUT  } {
      send_message {error} "Interface Signals not fully specified."
   } else {
      
      add_interface tristate_conduit tristate_conduit start
      set_interface_property tristate_conduit associatedClock clk
      add_interface_port tristate_conduit grant grant Input 1
      add_interface_port tristate_conduit request request Output 1
      foreach role ${SIGNAL_ROLES} width ${SIGNAL_WIDTHS} output ${SIGNAL_USE_OUTPUT} outputen ${SIGNAL_USE_OUTPUTENABLE} input ${SIGNAL_USE_INPUT} {
         if {$input == 1} {
            add_interface_port tristate_conduit ${role}_in ${role}_in Input $width
            set_port_property ${role}_in VHDL_TYPE STD_LOGIC_VECTOR
         }
         if {$output == 1} {
            add_interface_port tristate_conduit ${role}_out ${role}_out Output $width
            set_port_property ${role}_out VHDL_TYPE STD_LOGIC_VECTOR
         }
         if {$outputen == 1} {
            add_interface_port tristate_conduit ${role}_outen ${role}_outen Output 1
         }
      }
   }
   
   if { $MAX_MULTIPLE_TRANSACTION_VALUE <= 0 } {
      send_message {error} "Maximum multiple transaction must be more than 0."
   }
}

