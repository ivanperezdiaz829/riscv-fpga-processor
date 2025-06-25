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


package require -exact qsys 13.0

if {! [info exists ip_params] || ! [info exists ed_params]} {
   source "params.tcl"
}  

set num_grps    [list $ip_params(PHYLITE_NUM_GROUPS)]
set phylites    [list $ed_params(PHYLITE_NAME)]
set drivers     [list "driver_0"]
set sim_ctrls   [list "sim_ctrl_0"]
set addr_cmds   [list "addr_cmd_0"]
set mems        [list]
for { set i 0 } { $i < $num_grps } { incr i } {
   lappend mems "mem_$i"
}

create_system
set_project_property DEVICE_FAMILY $ip_params(SYS_INFO_DEVICE_FAMILY)


foreach phylite $phylites {
   add_instance $phylite altera_phylite
}

foreach inst $phylites {
   foreach param_name [array names ip_params] {
      set_instance_parameter_value $inst $param_name $ip_params($param_name)
   }
}

foreach phylite $phylites {

   add_interface ref_clk_clock_sink conduit end
   set_interface_property ref_clk_clock_sink EXPORT_OF ${phylite}.ref_clk_clock_sink
   
   add_interface reset_reset_sink conduit end
   set_interface_property reset_reset_sink EXPORT_OF ${phylite}.reset_reset_sink

   for {set i 0} {$i < $num_grps} {incr i} {
      add_interface group_${i}_io_interface_conduit_end conduit end
      set_interface_property group_${i}_io_interface_conduit_end EXPORT_OF ${phylite}.group_${i}_io_interface_conduit_end

      add_interface group_${i}_core_interface_conduit_end conduit end
      set_interface_property group_${i}_core_interface_conduit_end EXPORT_OF ${phylite}.group_${i}_core_interface_conduit_end
   }

   add_interface pll_conduit_end conduit end
   set_interface_property pll_conduit_end EXPORT_OF ${phylite}.pll_conduit_end
   
   add_interface core_clk_conduit_end conduit end
   set_interface_property core_clk_conduit_end EXPORT_OF ${phylite}.core_clk_conduit_end
   
}

save_system $ed_params(TMP_SYNTH_QSYS_PATH)


set ref_clk_freq_mhz  [get_instance_parameter_value $phylite "PHYLITE_REF_CLK_FREQ_MHZ"]

set clock_if "ref_clk_gen"
add_instance $clock_if altera_avalon_clock_source
set_instance_parameter_value $clock_if CLOCK_RATE [expr {round($ref_clk_freq_mhz * 1000000.0)}]
set_instance_parameter_value $clock_if CLOCK_UNIT 1

set reset_if "reset_gen"
add_instance $reset_if altera_avalon_reset_source
set_instance_parameter_value $reset_if ASSERT_HIGH_RESET 0
set_instance_parameter_value $reset_if INITIAL_RESET_CYCLES 5

add_connection ${clock_if}.clk   ${reset_if}.clk

foreach sim_ctrl $sim_ctrls driver $drivers phylite $phylites {

   add_instance $driver altera_phylite_driver
   add_instance $sim_ctrl altera_phylite_sim_ctrl

   foreach param_name [array names ip_params] {
      set_instance_parameter_value $sim_ctrl $param_name $ip_params($param_name)
      set_instance_parameter_value $driver $param_name $ip_params($param_name)
   }
}

foreach addr_cmd $addr_cmds {
   add_instance $addr_cmd altera_phylite

   set_instance_parameter_value $addr_cmd PHYLITE_NUM_GROUPS                1
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_PIN_TYPE_ENUM         "OUTPUT"
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_PIN_WIDTH             [expr 3 + ${num_grps}]
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_DDR_SDR_MODE_ENUM     "SDR"
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_USE_DIFF_STROBE       0
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_READ_LATENCY          4
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_CAPTURE_PHASE_SHIFT   0
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_WRITE_LATENCY         0
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_USE_OUTPUT_STROBE     1
   set_instance_parameter_value $addr_cmd GUI_GROUP_0_OUTPUT_STROBE_PHASE   0

   foreach param_name [array names ip_params] {
      if {[string first "GUI_PHYLITE_" $param_name] == 0} {
         set_instance_parameter_value $addr_cmd $param_name $ip_params($param_name)
      }
   }

}

foreach phylite $phylites driver $drivers sim_ctrl $sim_ctrls addr_cmd $addr_cmds {
   for {set i 0} {$i < $num_grps} {incr i} {
      set mem [lindex $mems $i]

      add_instance $mem altera_phylite_agent

      set_instance_parameter_value $mem AGENT_GROUP_INDEX $i
      foreach param_name [array names ip_params] {
         set_instance_parameter_value $mem $param_name $ip_params($param_name)
      }

      remove_interface group_${i}_core_interface_conduit_end
      set core_if group_${i}_core_interface_conduit_end
      add_connection ${driver}.${core_if} ${phylite}.${core_if}

      remove_interface group_${i}_io_interface_conduit_end
      
      add_connection ${phylite}.group_${i}_io_interface_conduit_end ${mem}.io_interface_conduit_end

      if {$i == 0} {
         add_connection ${sim_ctrl}.side_interface_conduit_end ${mem}.side_interface_conduit_end
      } else {
         add_connection [lindex $mems [expr $i - 1]].side_next_interface_conduit_end ${mem}.side_interface_conduit_end
      }

      if {$i == 0} {
         add_connection ${addr_cmd}.group_0_io_interface_conduit_end ${mem}.mem_cmd_interface_conduit_end
      } else {
         add_connection [lindex $mems [expr $i - 1]].mem_cmd_next_interface_conduit_end ${mem}.mem_cmd_interface_conduit_end
      }
   }

   remove_interface ref_clk_clock_sink
   remove_interface reset_reset_sink
   remove_interface pll_conduit_end
   remove_interface core_clk_conduit_end

   add_connection ${phylite}.pll_conduit_end      ${driver}.start_in_conduit_end
   add_connection ${phylite}.core_clk_conduit_end ${driver}.core_clk_in_conduit_end


   add_connection ${driver}.sim_ctrl_conduit_end     ${sim_ctrl}.sim_ctrl_conduit_end
   add_connection ${driver}.core_clk_out_conduit_end ${sim_ctrl}.core_clk_out_conduit_end
   add_connection ${driver}.start_out_conduit_end    ${sim_ctrl}.start_conduit_end

   add_connection ${sim_ctrl}.core_cmd_interface_conduit_end ${addr_cmd}.group_0_core_interface_conduit_end
   add_connection ${sim_ctrl}.mem_cmd_interface_conduit_end  [lindex $mems [expr $num_grps - 1]].mem_cmd_next_interface_conduit_end

   add_connection ${clock_if}.clk   ${phylite}.ref_clk_clock_sink
   add_connection ${reset_if}.reset ${phylite}.reset_reset_sink

   add_connection ${clock_if}.clk   ${addr_cmd}.ref_clk_clock_sink
   add_connection ${reset_if}.reset ${addr_cmd}.reset_reset_sink

}

save_system $ed_params(TMP_SIM_QSYS_PATH)


