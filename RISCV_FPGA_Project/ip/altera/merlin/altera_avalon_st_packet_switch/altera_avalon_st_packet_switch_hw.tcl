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


# $Id: //acds/rel/13.1/ip/merlin/altera_avalon_st_packet_switch/altera_avalon_st_packet_switch_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

#+ -------------------------------------------------------
#| Avalon-ST Packet Switch
#|
#| Composes a packet switch from Avalon-ST muxes and demuxes
#+ -------------------------------------------------------

package require -exact sopc 9.1

#+ -------------------------------------------------------
#| Module Properties
#+ -------------------------------------------------------

set_module_property NAME altera_avalon_st_packet_switch
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Avalon ST Packet Switch"
set_module_property PREVIEW_COMPOSE_CALLBACK do_compose
set_module_property INTERNAL true
set_module_property ANALYZE_HDL FALSE

#+ -------------------------------------------------------
#| Parameters
#+ -------------------------------------------------------

add_parameter ST_DATA_W INTEGER 8 0
set_parameter_property ST_DATA_W DISPLAY_NAME "Data Width"
set_parameter_property ST_DATA_W ALLOWED_RANGES 1:1023
set_parameter_property ST_DATA_W DESCRIPTION 0

add_parameter ST_CHANNEL_W INTEGER 2 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME "Channel Width"
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 1:256
set_parameter_property ST_CHANNEL_W DESCRIPTION 0

add_parameter NUM_INPUTS INTEGER 2 0
set_parameter_property NUM_INPUTS DISPLAY_NAME "Number of Inputs"
set_parameter_property NUM_INPUTS ALLOWED_RANGES 1:64
set_parameter_property NUM_INPUTS DESCRIPTION 0

add_parameter NUM_OUTPUTS INTEGER 2 0
set_parameter_property NUM_OUTPUTS DISPLAY_NAME "Number of Outputs"
set_parameter_property NUM_OUTPUTS ALLOWED_RANGES 1:64
set_parameter_property NUM_OUTPUTS DESCRIPTION 0

add_parameter PIPELINE_CROSS_CONNECT INTEGER 0 0
set_parameter_property PIPELINE_CROSS_CONNECT DISPLAY_NAME "Pipeline Cross-Connect"
set_parameter_property PIPELINE_CROSS_CONNECT ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_CROSS_CONNECT DESCRIPTION 0
set_parameter_property PIPELINE_CROSS_CONNECT DISPLAY_HINT boolean

add_parameter PIPELINE_ARB INTEGER 0 0
set_parameter_property PIPELINE_ARB DISPLAY_NAME "Pipeline Arbitration"
set_parameter_property PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_ARB DESCRIPTION 0
set_parameter_property PIPELINE_ARB DISPLAY_HINT boolean

add_display_item "" "Arbitration Shares" "group" "table"
add_parameter ARBITRATION_SHARES INTEGER_LIST 1 0
set_parameter_property ARBITRATION_SHARES DISPLAY_NAME "Arbitration Shares"
set_parameter_property ARBITRATION_SHARES GROUP "Arbitration Shares"

#+ -------------------------------------------------------
#| Constant Interface
#+ -------------------------------------------------------

add_interface clk clock end
add_interface clk_reset reset end

#+ -------------------------------------------------------
#| Compose Callback
#+ -------------------------------------------------------

proc do_compose {} {

  #  -------------------------------------------------------
  # | Extract parameters into handy tcl variables
  #  -------------------------------------------------------

  set NUM_INPUTS   [ get_parameter_value NUM_INPUTS   ]
  set NUM_OUTPUTS  [ get_parameter_value NUM_OUTPUTS  ]
  set ST_DATA_W    [ get_parameter_value ST_DATA_W    ]
  set ST_CHANNEL_W [ get_parameter_value ST_CHANNEL_W ]
  set PIPELINE_CC  [ get_parameter_value PIPELINE_CROSS_CONNECT ]
  set PIPELINE_ARB [ get_parameter_value PIPELINE_ARB ]
  set NEED_MUX     [ expr $NUM_INPUTS > 1 ]
  set ARB_SHARES   [ get_parameter_value ARBITRATION_SHARES ]
  set all_shares   [ split $ARB_SHARES "," ]

  #  -------------------------------------------------------
  # | Add clock/reset interfaces & clock/reset bridges
  #  -------------------------------------------------------
  set CLOCK clk
  set RESET reset
  add_instance ${CLOCK} altera_clock_bridge
  add_instance ${RESET} altera_reset_bridge
  set_interface_property clk export_of ${CLOCK}.in_clk
  set_interface_property clk_reset export_of ${RESET}.in_reset

  add_connection ${CLOCK}.out_clk ${RESET}.clk

  #  -------------------------------------------------------
  # | Add Input Interfaces & Demultiplexers
  #  -------------------------------------------------------

  for { set i 0 } { $i < $NUM_INPUTS } { incr i } {
      
      set n "in$i"
      add_interface $n avalon_streaming end

      add_instance ${n}_demux altera_merlin_demultiplexer 
      set_instance_parameter ${n}_demux ST_DATA_W     $ST_DATA_W
      set_instance_parameter ${n}_demux ST_CHANNEL_W  $ST_CHANNEL_W
      set_instance_parameter ${n}_demux NUM_OUTPUTS   $NUM_OUTPUTS

      set_interface_property $n export_of ${n}_demux.sink
      add_connection ${CLOCK}.out_clk     ${n}_demux.clk
      add_connection ${RESET}.out_reset   ${n}_demux.clk_reset
  }

  #  -------------------------------------------------------
  # | Add Output Interfaces & Multiplexers
  #  -------------------------------------------------------

  for { set i 0 } { $i < $NUM_OUTPUTS } { incr i } {
      set n "out$i"

      if { $NEED_MUX } {
          add_instance ${n}_mux altera_merlin_multiplexer
          set_instance_parameter ${n}_mux ST_DATA_W        $ST_DATA_W
          set_instance_parameter ${n}_mux ST_CHANNEL_W     $ST_CHANNEL_W
          set_instance_parameter ${n}_mux NUM_INPUTS       $NUM_INPUTS
          set_instance_parameter ${n}_mux PIPELINE_ARB     $PIPELINE_ARB
     
          add_connection ${CLOCK}.out_clk     ${n}_mux.clk
          add_connection ${RESET}.out_reset   ${n}_mux.clk_reset

          # ------------------------------------------
          # Extract arbshares from the master list. The TCL API
          # works with strings, so there is some amount of list
          # to comma-separated string conversion voodoo here.
          # ------------------------------------------
          set start [ expr ($i * $NUM_INPUTS) ]
          set end   [ expr ($i+1) * $NUM_INPUTS - 1 ]
          set mux_shares [ lrange $all_shares $start $end ]

          set invalid [ expr [ llength $mux_shares ] == 0 ]
          if { $invalid } {
              set mux_shares 1
          }
          set csv_mux_shares [ join $mux_shares "," ]
          set_instance_parameter ${n}_mux ARBITRATION_SHARES $csv_mux_shares
      } 

      add_interface $n avalon_streaming start
      #  -------------------------------------------------------
      # | Without a mux, the output interfaces are driven from either
      # | a demux or pipeline stage
      #  -------------------------------------------------------
      if { $NEED_MUX } {
          set_interface_property $n export_of ${n}_mux.src
      } elseif { $PIPELINE_CC } {
          set_interface_property $n export_of pipe_in0_out${i}.source0
      } else {
          set_interface_property $n export_of in0_demux.src${i}
      }
  }

  #  -------------------------------------------------------
  # | Cross-Connect
  #  -------------------------------------------------------
  for { set in 0 } { $in < $NUM_INPUTS } { incr in } {
      for { set out 0 } { $out < $NUM_OUTPUTS } { incr out } {
  
          set name "in${in}_out${out}"
          set pipe_name pipe_${name}

          if { $PIPELINE_CC } {
              add_instance $pipe_name altera_avalon_st_pipeline_stage 
              set_instance_parameter $pipe_name BITS_PER_SYMBOL $ST_DATA_W
              set_instance_parameter $pipe_name CHANNEL_WIDTH   $ST_CHANNEL_W
              set_instance_parameter $pipe_name USE_PACKETS     true
  
              add_connection ${CLOCK}.out_clk   ${pipe_name}.cr0
              add_connection ${RESET}.out_reset ${pipe_name}.cr0_reset
  
              add_connection in${in}_demux.src${out} ${pipe_name}.sink0
          }

          if { $NEED_MUX } {
              #  -------------------------------------------------------
              # | Connect the glue logic inputs and outputs
              #  -------------------------------------------------------
              if { $PIPELINE_CC } {
                  add_connection ${pipe_name}.source0 out${out}_mux.sink${in}
              } else {
                  add_connection in${in}_demux.src${out} out${out}_mux.sink${in}
              }
          }
      } 
  }

}
