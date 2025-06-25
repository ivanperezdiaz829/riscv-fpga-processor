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


























package nios_testbench_utils;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &create_x_checkers
    &create_rtl_trace_and_testend
    $hard_reset_type
    $cpu_only_reset_type
    $exc_handler_general
    $exc_handler_fast_tlb_miss
);

use europa_all;
use europa_utils;
use cpu_utils;
use cpu_control_reg;
use cpu_control_reg_gen;
use nios_common;
use nios_isa;
use strict;





our $trace_file_handle = "trace_handle";














sub
create_x_checkers
{
    my ($x_signals_ref) = @_;

    foreach my $x_signal (@$x_signals_ref) {
        my $sig = $x_signal->{sig};
        my $qual = $x_signal->{qual};
        my $do_not_stop = $x_signal->{warn};

        if ($qual) {
            e_process->adds({ 
              tag      => "simulation",
              contents => [ 
                e_if->new({ condition => $qual, then => [ 
                    e_if_x->new({ condition => $sig, 
                      do_not_stop   => $do_not_stop,
                    }) 
                  ],
                })
              ],
              asynchronous_contents => 
                [e_thing_that_can_go_in_a_module->new()],
            });
        } else {
            e_process_x->adds({
              check_x     => $sig,
              do_not_stop => $do_not_stop
            });
        }
    }
}



sub
create_rtl_trace_and_testend
{
    my $args = shift;   # Reference to hash with all arguments.

    validate_hash_keys("args", $args, [
      "activate_trace",
      "filename_base",
      "reset_entry",
      "hbreak_entry",
      "intr_entry",
      "inst_entry",
      "control_regs",
      "control_reg_stage",
      "extra_exc_info",
      "cpu_info",
      "test_end_expr",
    ]);

    my $activate_trace = manditory_bool($args, "activate_trace");
    my $filename_base = not_empty_scalar($args, "filename_base");
    my $reset_entry = manditory_hash($args, "reset_entry");
    my $hbreak_entry = manditory_hash($args, "hbreak_entry");
    my $intr_entry = manditory_hash($args, "intr_entry");
    my $inst_entry = manditory_hash($args, "inst_entry");
    my $control_regs = manditory_array($args, "control_regs");
    my $control_reg_stage = not_empty_scalar($args, "control_reg_stage");
    my $extra_exc_info = optional_bool($args, "extra_exc_info");
    my $cpu_info = manditory_hash($args, "cpu_info");
    my $test_end_expr = optional_scalar($args, "test_end_expr");

    my @process_objs;

    if ($activate_trace) {
        my $filename = $filename_base . ".tr";

        push(@process_objs, 
      create_rtl_trace(
            $filename, 
            $reset_entry,
            $hbreak_entry,
            $intr_entry,
            $inst_entry,
            $control_regs,
            $control_reg_stage,
            $extra_exc_info,
            $cpu_info),
        );
    }

    if ($test_end_expr) {
        push(@process_objs, 
          create_test_end($test_end_expr)
        );
    } else {

        e_assign->add([["test_has_ended", 1, $force_export], "1'b0"]);
    }

    if (scalar(@process_objs)) {
        e_process->adds({
          tag      => "simulation",
          contents => \@process_objs,
        });
    }
}





































our $reset_entry_type = 0;      # Reset
our $hbreak_entry_type = 1;     # Hardware break (debug)
our $intr_entry_type = 2;       # Interrupt exception
our $inst_entry_type = 3;       # Instruction
our $ctrl_entry_type = 4;       # Control register value change

sub
create_rtl_trace
{
    my $filename = shift;
    my $reset_entry = shift;
    my $hbreak_entry = shift;
    my $intr_entry = shift;
    my $inst_entry = shift;
    my $control_regs = shift;
    my $control_reg_stage = shift;
    my $extra_exc_info = shift;
    my $cpu_info = shift;

    create_rtl_trace_header($filename, $extra_exc_info, $cpu_info, $control_regs);

    return
      e_if->new({ condition => "~test_has_ended", then => [ 
          create_rtl_trace_ctrl_entry($control_regs, $control_reg_stage),
          create_rtl_trace_reset_entry($reset_entry,
            create_rtl_trace_hbreak_entry($hbreak_entry,
              create_rtl_trace_intr_entry($intr_entry,
                create_rtl_trace_inst_entry($inst_entry)))),
      ],
      });
}


























my $trace_version_0 = 0;

sub
create_rtl_trace_header
{
    my $filename = shift;
    my $extra_exc_info = shift;
    my $cpu_info = shift;
    my $control_regs = shift;

    my @header_fmt_lines; # Printf-style format strings for header

    push(@header_fmt_lines, "HeaderStart");
    push(@header_fmt_lines, "Version $trace_version_0");
    push(@header_fmt_lines, "CpuCoreName " . not_empty_scalar($cpu_info, "CpuCoreName"));
    push(@header_fmt_lines, "CpuInstanceName " . not_empty_scalar($cpu_info, "CpuInstanceName"));
    push(@header_fmt_lines, "CpuArchName " . not_empty_scalar($cpu_info, "CpuArchName"));
    push(@header_fmt_lines, "CpuArchRev " . not_empty_scalar($cpu_info, "CpuArchRev"));

    foreach my $control_reg (@$control_regs) {
        if (get_control_reg_hide($control_reg)) {
            next;
        }

        push(@header_fmt_lines, 
          "CtrlRegPresent " . sprintf("%x", get_control_reg_num($control_reg)));
    }

    if ($mmu_present) {
        push(@header_fmt_lines, "MmuPresent 1");
    }
    if ($shadow_present) {
        push(@header_fmt_lines, "ShadowPresent 1");
    }
    if ($eic_present) {
        push(@header_fmt_lines, "EicPresent 1");
    }
    if ($extra_exc_info) {
        push(@header_fmt_lines, "ExcContainsId 1");
    }
    if ($rf_ecc_present && $ecc_test_ports_present) {
        push(@header_fmt_lines, "RfEccTestPortPresent 1");
    }
    push(@header_fmt_lines, "HeaderEnd");

    my $header_fmt = join("\\n", @header_fmt_lines) . "\\n";


    e_sim_fopen->adds({
      file_name        => $filename,
      file_handle      => $trace_file_handle,
      contents         => [
        e_sim_write->new ({
          spec_string => $header_fmt,
          file_handle => $trace_file_handle,
        })
      ],
    });
}











our $hard_reset_type = 0;           # Normal hard reset
our $cpu_only_reset_type = 1;       # CPU-only reset

sub
create_rtl_trace_reset_entry
{
    my $reset_entry = shift;
    my $hbreak_obj = shift;

    my $hard_reset_expr = not_empty_scalar($reset_entry, "hard_reset_expr");
    my $cpu_only_reset_expr = optional_scalar($reset_entry, "cpu_only_reset_expr");

    my $condition = $hard_reset_expr;
    if ($cpu_only_reset_expr) {
        $condition .= " | $cpu_only_reset_expr";
    }

    my $expr = [
      $reset_entry_type,
      ($cpu_only_reset_expr ?
        ("$hard_reset_expr ? $hard_reset_type : $cpu_only_reset_type") :
        $hard_reset_type),
    ];

    return e_if->new({ condition => $condition, then => [ 
        e_sim_write->new ({
          spec_string => create_e_sim_write_spec_string($expr),
          expressions => $expr,
          show_time   => 1,
          file_handle => $trace_file_handle,
        }),
      ], else => [
          $hbreak_obj,
      ],
    });
}














sub
create_rtl_trace_hbreak_entry
{
    my $hbreak_entry = shift;
    my $intr_obj = shift;

    my $condition = not_empty_scalar($hbreak_entry, "condition");

    my $expr = [
      $hbreak_entry_type, 
      not_empty_scalar($hbreak_entry, "pc"),
      not_empty_scalar($hbreak_entry, "dstRegWr"),
      not_empty_scalar($hbreak_entry, "dstRegNum"),
      not_empty_scalar($hbreak_entry, "dstRegVal"),
    ];

    if ($shadow_present) {
        push(@$expr,
          not_empty_scalar($hbreak_entry, "dstRegSet"),
        );
    }

    if ($rf_ecc_present && $ecc_test_ports_present) {
        push(@$expr,
          not_empty_scalar($hbreak_entry, "dstRegEccTestPort"),
        );
    }

    return e_if->new({ condition => $condition, then => [ 
        e_sim_write->new ({
          spec_string => create_e_sim_write_spec_string($expr),
          expressions => $expr,
          show_time   => 1,
          file_handle => $trace_file_handle,
        }),
      ], else => [
          $intr_obj,
      ],
    });
}




















sub
create_rtl_trace_intr_entry
{
    my $intr_entry = shift;
    my $inst_obj = shift;

    my $condition = not_empty_scalar($intr_entry, "condition");

    my $expr = [
      $intr_entry_type, 
      not_empty_scalar($intr_entry, "pc"),
      not_empty_scalar($intr_entry, "dstRegWr"),
      not_empty_scalar($intr_entry, "dstRegNum"),
      not_empty_scalar($intr_entry, "dstRegVal"),
    ];

    if ($shadow_present) {
        push(@$expr,
          not_empty_scalar($intr_entry, "dstRegSet"),
        );
    }
    
    if ($rf_ecc_present && $ecc_test_ports_present) {
        push(@$expr,
          not_empty_scalar($intr_entry, "dstRegEccTestPort"),
        );
    }

    if ($eic_and_shadow) {
        push(@$expr,
          not_empty_scalar($intr_entry, "wrSstatus"),
          not_empty_scalar($intr_entry, "sstatus"),
        );
    }

    if ($eic_present) {
        push(@$expr,
          not_empty_scalar($intr_entry, "ril"),
          not_empty_scalar($intr_entry, "rnmi"),
          not_empty_scalar($intr_entry, "rrs"),
          not_empty_scalar($intr_entry, "rha"),
        );
    }

    return e_if->new({ condition => $condition, then => [ 
        e_sim_write->new ({
          spec_string => create_e_sim_write_spec_string($expr),
          expressions => $expr,
          show_time   => 1,
          file_handle => $trace_file_handle,
        }),
      ], else => [
          $inst_obj,
      ],
    });
}




























































our $exc_handler_general = 0;
our $exc_handler_fast_tlb_miss = 1;

sub
create_rtl_trace_inst_entry
{
    my $inst_entry = shift;

    my $condition = not_empty_scalar($inst_entry, "condition");

    my $expr = [
      $inst_entry_type, 
      not_empty_scalar($inst_entry, "exc"),
    ];

    if ($mmu_present) {
        push(@$expr,
          not_empty_scalar($inst_entry, "excHandler"),
        );
    }

    push(@$expr,
      not_empty_scalar($inst_entry, "pc"),
    );

    if ($mmu_present) {
        push(@$expr,
          not_empty_scalar($inst_entry, "pcPhy"),
        );
    }

    push(@$expr,
      not_empty_scalar($inst_entry, "ivValid"),
      not_empty_scalar($inst_entry, "iv"),
      not_empty_scalar($inst_entry, "dstRegWr"),
      not_empty_scalar($inst_entry, "dstRegNum"),
      not_empty_scalar($inst_entry, "dstRegVal"),
    );

    if ($shadow_present) {
        push(@$expr,
          not_empty_scalar($inst_entry, "dstRegSet"),
        );
    }

    if ($rf_ecc_present && $ecc_test_ports_present) {
        push(@$expr,
          not_empty_scalar($inst_entry, "dstRegEccTestPort"),
        );
    }

    push(@$expr,
      not_empty_scalar($inst_entry, "memAddr"),
    );

    if ($mmu_present) {
        push(@$expr,
          not_empty_scalar($inst_entry, "memAddrPhy"),
        );
    }

    push(@$expr,
      not_empty_scalar($inst_entry, "stData"),
      not_empty_scalar($inst_entry, "stByteEn"),
      not_empty_scalar($inst_entry, "pass"),
      not_empty_scalar($inst_entry, "targetPC"),
    );

    return e_if->new({ condition => $condition, then => [ 
        e_sim_write->new ({
          spec_string => create_e_sim_write_spec_string($expr),
          expressions => $expr,
          show_time   => 1,
          file_handle => $trace_file_handle,
        }),
      ],
    });
}












sub
create_rtl_trace_ctrl_entry
{
    my $control_regs = shift;
    my $control_reg_stage = shift;
    my @ret;

    my $cs = $control_reg_stage;

    foreach my $control_reg (@$control_regs) {
        if (get_control_reg_hide($control_reg)) {
            next;
        }

        my $control_reg_name = get_control_reg_name($control_reg);
        my $signal = get_control_reg_need_testbench_version($control_reg) ?
            "${cs}_${control_reg_name}_reg_tb" :
            "${cs}_${control_reg_name}_reg";
        my $prev_signal = $signal . "_prev";
        my $prev_signal_is_x = $signal . "_prev_is_x";

        my $condition = "($signal != $prev_signal) || $prev_signal_is_x";
        my $expr = [
          $ctrl_entry_type, 
          get_control_reg_num($control_reg),
          $signal
        ];

        e_assign_is_x->adds(
          [[$prev_signal_is_x, 1], $prev_signal],
        );



        push(@ret,
          e_if->new({ condition => $condition, then => [ 
              e_sim_write->new ({
                spec_string => create_e_sim_write_spec_string($expr),
                expressions => $expr,
                show_time   => 1,
                file_handle => $trace_file_handle,
              }),
              e_assign->news(
                [[$prev_signal, $CONTROL_REG_SZ], $signal],
              ),
          ],
          }),
        );
    }

    return @ret;
}



sub
create_e_sim_write_spec_string
{
    my $expr = shift;

    return join(",", map {"%0h"} (@$expr)) . "\\n";
}


sub
create_test_end
{
    my $test_end_expr = shift;



    e_register->adds(


      {out => ["test_ending", 1, $force_export],
       in => "$test_end_expr",
       enable => "1'b1"},



      {out => ["test_ending_d1", 1, 0, $force_never_export],
       in => "test_ending",
       enable => "1'b1"},
      {out => ["test_ending_d2", 1, 0, $force_never_export],
       in => "test_ending_d1",
       enable => "1'b1"},




      {out => ["test_has_ended", 1, $force_export],
       in => "($test_end_expr) | test_has_ended",
       enable => "1'b1"},
    );

    return



      e_if->new({ condition => "test_ending_d2", then => [ 
          e_sim_write->new({ 
            spec_string => "Detected end of test\\n",
            show_time   => 1,
          }),
          e_stop->new()
      ],
      });
}

1;

