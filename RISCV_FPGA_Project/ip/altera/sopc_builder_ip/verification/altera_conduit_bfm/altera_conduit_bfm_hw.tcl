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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_conduit_bfm/altera_conduit_bfm_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------------------------------------------------
# | 
# | altera_conduit_bfm
# | Altera Conduit BFM
# | 
# +-----------------------------------------------------------------------------
package require -exact qsys 13.1
package require -exact altera_terp 1.0

# +-----------------------------------------------------------------------------
# | Basic Declarations
# +-----------------------------------------------------------------------------
set_module_property NAME                                             altera_conduit_bfm
set_module_property VERSION                                          13.1
set_module_property GROUP                                            "Avalon Verification Suite"
set_module_property DISPLAY_NAME                                     "Altera Conduit BFM"
set_module_property DESCRIPTION                                      "Altera Conduit BFM"
set_module_property AUTHOR                                           "Altera Corporation"
set_module_property EDITABLE                                         false
set_module_property ELABORATION_CALLBACK                             validate_and_elaborate
set_module_property INTERNAL                                         false
set_module_property ANALYZE_HDL                                      false
set_module_property HIDE_FROM_SOPC                                   true

# +-----------------------------------------------------------------------------
# | Files
# +-----------------------------------------------------------------------------
# Define file set
add_fileset synthesis QUARTUS_SYNTH quartus_synth_proc
add_fileset verilog SIM_VERILOG simverilog
add_fileset vhdl SIM_VHDL simvhdl

proc setup_terp_signal_information {} {
   
   set CLOCKED_SIGNAL      [get_parameter_value CLOCKED_SIGNAL]
   set ENABLE_RESET        [get_parameter_value ENABLE_RESET]
   set SIGNAL_ROLES        [get_parameter_value SIGNAL_ROLES]
   set SIGNAL_WIDTHS       [get_parameter_value SIGNAL_WIDTHS]
   set SIGNAL_DIRECTIONS   [get_parameter_value SIGNAL_DIRECTIONS]
   
   set L_SIGNAL_ROLES      [llength $SIGNAL_ROLES]
   set L_SIGNAL_WIDTHS     [llength $SIGNAL_WIDTHS]
   set L_SIGNAL_DIRECTIONS [llength $SIGNAL_DIRECTIONS]

   set rolemap ""
   foreach role ${SIGNAL_ROLES} width ${SIGNAL_WIDTHS} direction ${SIGNAL_DIRECTIONS}  {
      if {$rolemap==""} {
         set rolemap "${role}:${width}:${direction}"
      } else {
         set rolemap "${rolemap},${role}:${width}:${direction}"
      }
   }
   return $rolemap
}

# run the terp template file
proc do_terp { template_file rolemap instance_name $file_name file_type} {
   
   set this_dir      [ get_module_property MODULE_DIRECTORY ]
   set template_file [ file join $this_dir $template_file ]   
   set template      [ read [ open $template_file r ] ]
    
   if {[string equal [get_parameter_value CLOCKED_SIGNAL] true]} {
      set CLOCKED_SIGNAL_VALUE 1
   } else {
      set CLOCKED_SIGNAL_VALUE 0
   }
    
   set params(output_name)       $instance_name
   set params(rolemap)           $rolemap
   set params(clocked)           $CLOCKED_SIGNAL_VALUE

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

proc simverilog { instance_name } {
   set rolemap [setup_terp_signal_information]
   
   set HDL_LIB_DIR      "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/verbosity_pkg.sv
   do_terp "altera_conduit_bfm.v.terp" $rolemap $instance_name $instance_name SYSTEM_VERILOG
   
   set_fileset_file_attribute verbosity_pkg.sv  COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
}

proc quartus_synth_proc { instance_name } {
   set rolemap [setup_terp_signal_information]
   
   set HDL_LIB_DIR      "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH $HDL_LIB_DIR/verbosity_pkg.sv
   do_terp "altera_conduit_bfm.v.terp" $rolemap $instance_name $instance_name SYSTEM_VERILOG
}

proc simvhdl { instance_name } {
   set rolemap [setup_terp_signal_information]

   do_terp "altera_conduit_bfm_vhdl_pkg.vhd.terp" $rolemap $instance_name ${instance_name}_vhdl_pkg VHDL
   do_terp "altera_conduit_bfm.vhd.terp" $rolemap $instance_name $instance_name VHDL
}

# +-----------------------------------------------------------------------------
# | Parameters
# +-----------------------------------------------------------------------------

add_parameter CLOCKED_SIGNAL BOOLEAN 0
set_parameter_property CLOCKED_SIGNAL DISPLAY_NAME "Clocked conduit signal"
set_parameter_property CLOCKED_SIGNAL GROUP "Signals"
set_parameter_property CLOCKED_SIGNAL AFFECTS_ELABORATION true
set_parameter_property CLOCKED_SIGNAL VISIBLE false

add_parameter ENABLE_RESET BOOLEAN 0
set_parameter_property ENABLE_RESET DISPLAY_NAME "Enable active high reset"
set_parameter_property ENABLE_RESET GROUP "Signals"
set_parameter_property ENABLE_RESET AFFECTS_ELABORATION true
set_parameter_property ENABLE_RESET VISIBLE false

add_display_item "" "Interface Signals" "group" "table"

add_parameter SIGNAL_ROLES STRING_LIST "sig"
set_parameter_property SIGNAL_ROLES DISPLAY_NAME "Role"
set_parameter_property SIGNAL_ROLES AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ROLES GROUP "Interface Signals"

add_parameter SIGNAL_WIDTHS INTEGER_LIST 1
set_parameter_property SIGNAL_WIDTHS DISPLAY_NAME "Width"
set_parameter_property SIGNAL_WIDTHS ALLOWED_RANGES 1:1024
set_parameter_property SIGNAL_WIDTHS GROUP "Interface Signals"

add_parameter SIGNAL_DIRECTIONS STRING_LIST "input"
set_parameter_property SIGNAL_DIRECTIONS DISPLAY_NAME "Direction"
set_parameter_property SIGNAL_DIRECTIONS AFFECTS_ELABORATION true
set_parameter_property SIGNAL_DIRECTIONS GROUP "Interface Signals"
set_parameter_property SIGNAL_DIRECTIONS ALLOWED_RANGES {"input" "output" "bidir"}


# +-----------------------------------------------------------------------------
# | Validation & Elaboration
# +-----------------------------------------------------------------------------
proc validate_and_elaborate {} {

   set CLOCKED_SIGNAL   [ get_parameter_value CLOCKED_SIGNAL ]
   set ENABLE_RESET     [ get_parameter_value ENABLE_RESET ]
   set SIGNAL_ROLES     [ get_parameter_value SIGNAL_ROLES ]
   set SIGNAL_WIDTHS    [ get_parameter_value SIGNAL_WIDTHS ]
   set SIGNAL_DIRECTIONS [ get_parameter_value SIGNAL_DIRECTIONS ]

   set L_SIGNAL_ROLES     [llength $SIGNAL_ROLES     ]
   set L_SIGNAL_WIDTHS    [llength $SIGNAL_WIDTHS    ]
   set L_SIGNAL_DIRECTIONS [llength $SIGNAL_DIRECTIONS ]
   
   # add clock and reset interface if it is clocked conduit
   if {$CLOCKED_SIGNAL} {
      set_parameter_property ENABLE_RESET ENABLED true
     
      add_interface clk clock end
      set_interface_property clk ENABLED true
      add_interface_port clk clk clk input 1
      
      add_interface reset reset end
      set_interface_property reset ENABLED true
      set_interface_property reset associatedClock clk
      add_interface_port reset reset reset input 1
      
      # terminate reset port if reset not enabled
      if {$ENABLE_RESET} {
         set_port_property reset TERMINATION 0
      } else {
         set_port_property reset TERMINATION       1
         set_port_property reset TERMINATION_VALUE 0      
      }
   } else {
      set_parameter_property ENABLE_RESET ENABLED false
   }

   if { $L_SIGNAL_ROLES != $L_SIGNAL_WIDTHS || $L_SIGNAL_ROLES != $L_SIGNAL_DIRECTIONS  } {
      send_message {error} "Interface Signals not fully specified."
   } else {

      #  -----------------------------------
      # | Add Conduit Interface
      #   -----------------------------------
      add_interface conduit conduit end      
      if {$CLOCKED_SIGNAL} {
         set_interface_property conduit associatedClock clk
      }
      if {$ENABLE_RESET && $CLOCKED_SIGNAL} {
         set_interface_property conduit associatedReset reset
      }
      foreach role ${SIGNAL_ROLES} width ${SIGNAL_WIDTHS} direction ${SIGNAL_DIRECTIONS}  {
         set dir "output"
         if {$direction == "input"} {
            set dir "input"
         } elseif {$direction == "bidir"} {
            set dir "bidir" 
         }
         add_interface_port conduit sig_$role $role $dir $width
         set_port_property sig_$role VHDL_TYPE STD_LOGIC_VECTOR
      }
   }
}
