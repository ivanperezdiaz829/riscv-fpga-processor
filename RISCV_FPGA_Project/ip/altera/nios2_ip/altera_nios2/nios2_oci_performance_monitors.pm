#Copyright (C)2001-2010 Altera Corporation
#Any megafunction design, and related net list (encrypted or decrypted),
#support information, device programming or simulation file, and any other
#associated documentation or information provided by Altera or a partner
#under Altera's Megafunction Partnership Program may be used only to
#program PLD devices (but not masked PLD devices) from Altera.  Any other
#use of such megafunction design, net list, support information, device
#programming or simulation file, or any other related documentation or
#information is prohibited for any other purpose, including, but not
#limited to modification, reverse engineering, de-compiling, or use with
#any other silicon devices, unless such use is explicitly licensed under
#a separate agreement with Altera or a megafunction partner.  Title to
#the intellectual property, including patents, copyrights, trademarks,
#trade secrets, or maskworks, embodied in any such megafunction design,
#net list, support information, device programming or simulation file, or
#any other related documentation or information provided by Altera or a
#megafunction partner, remains with Altera, the megafunction partner, or
#their respective licensors.  No other licenses, including any licenses
#needed under any third party's intellectual property, are provided herein.
#Copying or modifying any file, or portion thereof, to which this notice
#is attached violates this copyright.






















use cpu_utils;
use nios_icache;
use nios_dcache;
use nios2_common;
use europa_all;
use strict;

sub make_nios2_oci_performance_monitors
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_performance_monitors",
  });



  return $module if ($Opt->{oci_num_pm} == 0);

  my $marker = e_default_module_marker->new($module);



  $module->add_contents (

    e_signal->news (
    ),

    e_signal->news (
    ),

    
  );














  my @small_performance_signals = 
  (

      ["perf_event_cycles",  "1'b1",                    3],


      ["perf_event_dispatched", "(D_valid & E_en)",     4],


      ["perf_event_retired", "(M_valid & M_en)",        5],


      ["perf_event_M_ld_stall", "(M_ld_stall)",         6],


      ["perf_event_M_st_stall", "(M_st_stall)",         7],



      ["perf_event_no_disp_pipe_flush", 
      "(D_no_disp_pipe_flush & ~E_stall)",              8],



      ["perf_event_no_disp_branch_penalty", 
      "(D_no_disp_branch_penalty & ~E_stall)",          9],



      ["perf_event_no_disp_icache_miss", 
      $icache_present ? "(D_no_disp_icache_miss & ~E_stall)" : "", 11],



      ["perf_event_br_pred_bad",  
      "(M_br_mispredict & ~M_stall)",         12],



      ["perf_event_br_pred_good", 
      "(M_ctrl_br_cond & ~M_br_mispredict & ~M_stall)", 13],
  );

  my @fast_performance_signals = 
  (

      ["perf_event_cycles", "1'b1",                     3],


      ["perf_event_dispatched", "(D_valid & E_en)",     4],


      ["perf_event_retired", "(A_valid & A_en)",        5],


      ["perf_event_A_rd_stall", $perf_cnt_inc_rd_stall, 6],


      ["perf_event_A_wr_stall", $perf_cnt_inc_wr_stall, 7],



      ["perf_event_no_disp_pipe_flush", 
       "(D_no_disp_pipe_flush & ~E_stall)",             8],



      ["perf_event_no_disp_delay_slot", 
       "(D_no_disp_delay_slot & ~E_stall)",             9],



      ["perf_event_no_disp_data_depend", 
       "(D_no_disp_data_depend & ~E_stall)",            10],



      ["perf_event_no_disp_icache_miss", 
       $icache_present ? "(D_no_disp_icache_miss & ~E_stall)" : "0", 11],



      ["perf_event_br_pred_bad", 
       "(M_br_mispredict & ~A_stall)",        12],



      ["perf_event_br_pred_good", 
       "(M_ctrl_br_cond & ~M_br_mispredict & ~A_stall)", 13],


      ["perf_event_ld_hit", 
       $dcache_present ? "(A_dc_hit_perf_cnt & A_ctrl_ld_non_bypass & 
        A_valid & A_wr_dst_reg & ~A_stall)" : "0",            14],


      ["perf_event_ld_miss", 
       $dcache_present ? "(~A_dc_hit_perf_cnt & A_ctrl_ld_non_bypass & 
        A_valid & A_wr_dst_reg & ~A_stall)" : "0",            15],


      ["perf_event_st_hit", 
       $dcache_present ? "(A_dc_hit_perf_cnt & A_ctrl_st_non_bypass & 
        A_valid & ~A_stall)" : "0",                           16],


      ["perf_event_st_miss", 
       $dcache_present ? "(~A_dc_hit_perf_cnt & A_ctrl_st_non_bypass & 
        A_valid & ~A_stall)" : "0",                           17],
  );


  my @event_signals;    # list of events according to pipeline
  if ($Opt->{core_type} eq "fast")  {
    @event_signals = @fast_performance_signals;
  } elsif ($Opt->{core_type} eq "small") {
    @event_signals = @small_performance_signals;
  } else {
    &$error ("Pipeline does not support OCI performance monitors");
  }

  my @event_mux_list;     # list of events for event mux. created below.
  foreach my $event_signal (@event_signals) {
    $module->add_contents (
      e_assign->new (
        [$event_signal->[0], $event_signal->[1]]
      ),
    );
    push @event_mux_list, (
      "32'd".$event_signal->[2] => $event_signal->[0]
    );
  };





  push @event_mux_list, (
    "32'd256"   => "dbrk_hit0",
    "32'd257"   => "dbrk_hit1",
    "32'd258"   => "dbrk_hit2",
    "32'd259"   => "dbrk_hit3",
  );
  
  my $nios2_pm_counter_module = 
    &make_nios2_oci_performance_monitor_module($Opt, \@event_mux_list);

  for (my $i=1; $i <= $Opt->{oci_num_pm}; $i++) {
    e_instance->add ({
      name    => "the_".$Opt->{name}."_nios2_performance_monitor_counter_$i",
      module  => $Opt->{name}."_nios2_performance_monitor_counter",
      port_map  => {
        pm_counter             => "pm$i\_counter",
        pm_counting            => "pm$i\_counting",
        pm_detect_falling_edge => "pm$i\_detect_falling_edge",
        pm_detect_rising_edge  => "pm$i\_detect_rising_edge",
        pm_disable             => "pm$i\_disable",
        pm_edge_off            => "pm$i\_edge_off",
        pm_edge_on             => "pm$i\_edge_on",
        pm_enable              => "pm$i\_enable",
        pm_mux_selection       => "pm$i\_mux_selection",
        pm_overflow            => "pm$i\_overflow",
        pm_started             => "pm$i\_started",
        pm_stopped             => "pm$i\_stopped",
        take_action_pm_control => "take_action_pm$i\_control",
        take_action_pm_mux_selection => "take_action_pm$i\_mux_selection",
      },
    });
  }

  return $module;
}











































sub make_nios2_oci_performance_monitor_module
{
  my ($Opt, $event_mux_list_ref) = (@_);
  my @event_mux_list = @$event_mux_list_ref;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_performance_monitor_counter",
  });

  $module->add_contents (

    e_register->new ({
      out => ["pm_counter", $Opt->{oci_pm_width}, 1],
      in  => "pm_counter + 1",
      enable  => "pm_counting",
      sync_reset   => "~pm_clear_n",
    }),


    e_assign->news (
      [["pm_counting", 1, 1], "(pm_sampled_signal | 
                          (pm_edge_detected & pm_detect_edge_global_enable)) 
                        & ~debugack & pm_global_enable"],
      ["pm_stopped", "~pm_global_enable"],
      ["pm_started", "pm_global_enable"],
      ["pm_disable", "~pm_global_enable"],
      ["pm_enable",  "pm_global_enable"],
      ["pm_clear_n", "~(writedata[2] & take_action_pm_control)"],
    ),


    e_mux->new ({
      out => ["pm_sampled_signal", 1],
      selecto => "pm_mux_selection",
      table   => [
          "32'd0"   => "1'b0",
          "32'd1"   => "1'b1",
          @event_mux_list,
      ],
      default => "1'b0",
    }),

    e_register->new ({
      out => ["pm_mux_selection", 32, 1],
      in  => "writedata",
      enable  => "take_action_pm_mux_selection",
      async_value => "32'b0",      
    }),
    e_register->new ({
      out => ["pm_global_enable", 1],
      in  => "(writedata[0] ? 1'b1 : writedata[1] ? 1'b0 : pm_global_enable)",
      enable  => "take_action_pm_control",
      async_value => "1'b0",      
    }),
    e_register->new ({
      out => ["pm_overflow", 1, 1],
      in  => "&pm_counter",
      enable  => "pm_counting",
      sync_reset   => "~pm_clear_n",
    }),





    e_register->new ({
      out => ["pm_detect_edge_global_enable", 1],
      in  => "(writedata[4] ? 1'b1 : writedata[5] ? 1'b0 : pm_detect_edge_global_enable)",
      enable  => "take_action_pm_control",
      async_value => "1'b0",      
    }),
    e_register->new ({
      out => ["pm_detect_falling_edge", 1, 1],
      in  => "writedata[7] & pm_global_enable",
      enable  => "take_action_pm_control",
      async_value => "1'b0",      
    }),
    e_register->new ({
      out => ["pm_detect_rising_edge", 1, 1],
      in  => "writedata[6] & pm_global_enable",
      enable  => "take_action_pm_control",
      async_value => "1'b0",      
    }),

    e_register->new ({
      out => ["d1_pm_sampled_signal", 1,0,1],
      in  => "pm_sampled_signal",
      enable  => "1'b1",
    }),
    e_assign->news (
      ["pm_rising_edge", "~d1_pm_sampled_signal & pm_sampled_signal"],
      ["pm_falling_edge","d1_pm_sampled_signal & ~pm_sampled_signal"],
      ["pm_edge_detected","(pm_rising_edge & pm_detect_rising_edge) & 
                            (pm_falling_edge & pm_detect_falling_edge)"],
      ["pm_edge_on",   "pm_detect_edge_global_enable"],
      ["pm_edge_off",  "~pm_detect_edge_global_enable"],
    ),
  );

  return $module;
}

1;
