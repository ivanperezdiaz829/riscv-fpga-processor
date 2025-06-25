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






















package nevada_testbench;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nevada_make_testbench
);

use cpu_utils;
use cpu_wave_signals;
use cpu_control_reg;
use cpu_gen;
use cpu_inst_gen;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_europa;
use nios_avalon_masters;
use nios_brpred;
use nios_common;
use nios_isa;
use nevada_control_regs;

use strict;















sub
validate_and_elaborate
{
    my $control_reg_info = shift;
    
    my $all_control_regs = 
      manditory_array($control_reg_info, "all_control_regs");
    my $present_control_regs = 
      manditory_array($control_reg_info, "control_regs");







    my $check_signals = [
        { name => "hard_reset", expr => "~reset_n" },
        { name => "exception_id", 
          expr => "W_exc_any_active ? W_exc_highest_pri_id : 0" },
        { name => "exception_addr", expr => "W_pipe_fetch_pcb" },
        { name => "pcb", expr => "W_pcb" },
        { name => "pcb_phy", expr => "W_pcb_phy" },
        { name => "iw", expr => "W_iw" },
        { name => "iw_valid", expr => "~W_iw_invalid" },
        { name => "wr_dst_reg", expr => "W_wr_dst_reg" },
        { name => "dst_regnum", expr => "W_dst_regnum" },
        { name => "wr_data", expr => "W_wr_data_filtered" },
        { name => "st_data", expr => "W_st_data" },
        { name => "mem_baddr", expr => "W_mem_baddr" },
        { name => "mem_baddr_phy", expr => "W_mem_baddr_phy" },
        { name => "mem_byte_en", expr => "W_mem_byte_en" },
        { name => "passed", expr => "W_br_result" },
        { name => "target_pcb", expr => "W_target_pcb" },
        { name => "is_delay_slot", expr => "W_is_delay_slot" },
        { name => "tlbwr_index", expr => "W_tlb_rw_inst_index" },
    ];

    foreach my $control_reg (@$all_control_regs) {
        my $reg_name = get_control_reg_name($control_reg);


        my $present = 
          defined(get_control_reg_by_name_or_undef($present_control_regs, 
            $reg_name));

        push(@$check_signals,
          { 
            name => "$reg_name", 
            expr => ($present ? "W_${reg_name}_reg" : "0"),
          },
        );
    }


    my $nevada_testbench_info = {
      check_signals => $check_signals,
    };

    return $nevada_testbench_info;
}


sub
convert_to_c
{
    my $nevada_testbench_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $check_signals = 
      manditory_array($nevada_testbench_info, "check_signals");

    push(@$h_lines, "");
    push(@$h_lines, "/*");
    push(@$h_lines, " * RTL CPU Check Constants");
    push(@$h_lines, " */");

    my $check_num_signals = scalar(@$check_signals);
    push(@$h_lines, 
      format_c_macro("mips32_check_num_signals", $check_num_signals));

    push(@$c_lines, "");
    push(@$c_lines, "/* Converts MIPS32 check signal number to a name */");
    push(@$c_lines, 
      "const char* mips32CheckSigNames[MIPS32_CHECK_NUM_SIGNALS] = {");
    push(@$c_lines, '    "",');

    for (my $index = 0; $index < $check_num_signals; $index++) {
        my $check_signal = $check_signals->[$index];
        my $last = ($index == ($check_num_signals-1));
        my $name = not_empty_scalar($check_signal, "name");
        
        push(@$h_lines, format_c_macro("mips32_check_sig_" . $name, $index));
        push(@$c_lines, '    "' . $name . '"' . ($last ? "" : ","));
    }

    push(@$c_lines, "};");

    push(@$h_lines, "");
    push(@$h_lines,
      "extern const char* mips32CheckSigNames[MIPS32_CHECK_NUM_SIGNALS];");
}



sub 
nevada_make_testbench
{
    my $Opt = shift;

    my $check_signals = manditory_array($Opt, "check_signals");
    my $present_control_regs = manditory_array($Opt, "control_regs");

    &$progress("    Testbench");

    my $whoami = "testbench";

    my $submodule_name = $Opt->{name}."_test_bench";

    my $submodule = e_module->new({
      name        => $submodule_name,
      output_file => $submodule_name,
    });

    my $testbench_instance_name = "the_$submodule_name";
    my $testbench_instance = e_instance->add({
      module      => $submodule,
      name        => $testbench_instance_name,
    });

    my $marker = e_default_module_marker->new($submodule);



    cpu_inst_gen::gen_inst_decodes(manditory_hash($Opt, "gen_info"), ["W"]);






    e_assign->adds(
      [["E_src1_eq_src2", 1], "E_logic_result == 0"],
    );

    cpu_pipeline_signal(manditory_hash($Opt, "gen_info"), {
       name => "D_exc_invalidates_inst_value",
       sz => 1,
       never_export => 1,
    });




    e_assign->adds(
      ["A_iw_invalid", "A_exc_invalidates_inst_value & A_exc_allowed"],
    );

    e_register->adds(
      {out => ["W_iw_invalid", 1, 0, $force_never_export], 
       in => "A_iw_invalid",  enable => "1'b1"},
    );

    my @traceArgs;
    foreach my $check_signal (@$check_signals) {
        push(@traceArgs, not_empty_scalar($check_signal, "expr"));
    }





    e_register->adds(

      {out => ["A_target_pcb", $pcb_sz, 0, $force_never_export],
       in => "M_target_pcb",            enable => "A_en"},
      {out => ["A_mem_baddr", $mem_baddr_sz, 0, $force_never_export],
       in => "M_mem_baddr",             enable => "A_en"},


      {out => ["W_wr_data_filtered", $datapath_sz, 0, $force_never_export], 
       in => "A_wr_data_filtered",          enable => "1'b1"},
      {out => ["W_mem_baddr", $mem_baddr_sz, 0, $force_never_export],
       in => "A_mem_baddr",                 enable => "1'b1"},
      {out => ["W_st_data", $datapath_sz, 0, $force_never_export],
       in => "A_st_data",                   enable => "1'b1"},
      {out => ["W_mem_byte_en", $byte_en_sz, 0, $force_never_export],
       in => "A_mem_byte_en",               enable => "1'b1"},
      {out => ["W_br_result", 1, 0, $force_never_export],
       in => "A_br_result",                 enable => "1'b1"},
      {out => ["W_target_pcb", $pcb_sz, 0, $force_never_export],
       in => "A_target_pcb",                enable => "1'b1"},
      {out => ["W_is_delay_slot", 1, 0, $force_never_export],
       in => "A_is_delay_slot",             enable => "1'b1"},
      {out => ["W_exc_any_active", 1, 0, $force_never_export],
       in => "A_exc_any_active",            enable => "1'b1"},
      {out => ["W_exc_highest_pri_id", 32, 0, $force_never_export],
       in => "A_exc_highest_pri_id",        enable => "1'b1"},
      {out => ["W_pipe_fetch_pcb", $pcb_sz, 0, $force_never_export],
       in => "A_pipe_fetch_pcb",            enable => "1'b1"},
    );

    if ($mmu_present) {

        my $inst_baddr_width = manditory_int($Opt, "i_Address_Width");
        my $data_addr_phy_sz  = manditory_int($Opt, "d_Address_Width");


        e_register->adds(
          {out => ["D_pcb_phy", $inst_baddr_width], 
           in => "F_pcb_phy", enable => "D_en"},
          {out => ["E_pcb_phy", $inst_baddr_width], 
           in => "D_pcb_phy", enable => "E_en", ip_debug_visible => 1},
          {out => ["M_pcb_phy", $inst_baddr_width], 
           in => "E_pcb_phy", enable => "M_en"},
          {out => ["A_pcb_phy", $inst_baddr_width], 
           in => "M_pcb_phy", enable => "A_en"},
          {out => ["W_pcb_phy", $inst_baddr_width, 0, $force_never_export], 
           in => "A_pcb_phy", enable => "1'b1"},
          {out => ["W_mem_baddr_phy", $data_addr_phy_sz, 0, 
              $force_never_export], 
           in => "A_mem_baddr_phy", enable => "1'b1"},
        );
    } else {

        e_assign->adds(
          [["W_pcb_phy", $pcb_sz, 0, $force_never_export], "W_pcb"],

          [["W_mem_baddr_phy", $mem_baddr_sz, 0, $force_never_export], 
            "W_mem_baddr"],
        );
    }

    if ($tlb_present) {
        my $tlb_index_sz = get_control_reg_field_sz($cop0_index_reg_index);


        e_register->adds(
          {out => ["W_tlb_rw_inst_index", $tlb_index_sz, 0, 
            $force_never_export], 
           in => "A_tlb_rw_inst_index",         enable => "1'b1"},
        );
    } else {

        e_assign->adds(
          [["W_tlb_rw_inst_index", 1, 0, $force_never_export], "0"],
        );
    }




    $submodule->sink_signals(
      "W_pcb",
      "W_vinst",
      "W_valid",
      "W_iw",
    );

    push(@simgen_wave_signals,
        { radix => "x", signal => "$testbench_instance_name/W_pcb" },
        { radix => "a", signal => "$testbench_instance_name/W_vinst" },
        { radix => "x", signal => "$testbench_instance_name/W_valid" },
        { radix => "x", signal => "$testbench_instance_name/W_iw" },
    );

    my @x_signals = (
      { sig => "W_wr_dst_reg",                          },
      { sig => "W_dst_regnum", qual => "W_wr_dst_reg",  },
      { sig => "W_valid",                               },
      { sig => "W_pcb",        qual => "W_valid",       },
      { sig => "W_iw",         qual => "W_valid",       },
      { sig => "A_en",                                  },
      { sig => "M_valid",                               },
      { sig => "A_valid",                               },
      { sig => "A_exc_any_active",                      },
      { sig => "A_wr_data_unfiltered",    
        qual => "A_valid & A_en & A_wr_dst_reg",
        warn => 1,                                      },


      { sig => "i_read",                                },
      { sig => "i_address",    qual => "i_read",        },
      { sig => "i_readdatavalid",                       },


      { sig => "d_write",                                   },
      { sig => "d_byteenable", qual => "d_write",           },
      { sig => "d_address",    qual => "d_write | d_read",  },
      { sig => "d_read",                                    },
    );


    foreach my $control_reg (@$present_control_regs) {
        my $reg_name = get_control_reg_name($control_reg);

        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            if (is_control_reg_field_readable($field)) {
                my $field_name = get_control_reg_field_name($field);

                push(@x_signals, { sig => "W_${reg_name}_reg_${field_name}" });
            }
        }
    }

    for (my $cmi = 0; 
      $cmi < manditory_int($Opt, "num_tightly_coupled_data_masters"); $cmi++) {
        push(@x_signals,
          { sig => "dcm${cmi}_write",                                },
          { sig => "dcm${cmi}_byteenable", qual => "dcm${cmi}_write", },
          { sig => "dcm${cmi}_address",    qual => "dcm${cmi}_write", },
        );
    }

    e_signal->adds(

      {name => "A_target_pcb", width => $pcb_sz},



      {name => "A_wr_data_filtered", width => $datapath_sz, 
       export => $force_export},
    );

    my $x_filter_qual = "A_ctrl_ld_non_bypass";

    if (manditory_bool($Opt, "clear_x_bits_ld_non_bypass") && 
      !manditory_bool($Opt, "asic_enabled")) {





        create_x_filter({
          lhs       => "A_wr_data_filtered",
          rhs       => "A_wr_data_unfiltered",
          sz        => $datapath_sz, 
          qual_expr => $x_filter_qual,
        });
    } else {

        e_assign->adds({
          lhs => "A_wr_data_filtered",
          rhs => "A_wr_data_unfiltered",
          comment => "Propagating 'X' data bits",
        });
    }

    if (!$Opt->{bht_index_pc_only}) {
        e_signal->adds(


            {name => "E_add_br_to_taken_history_filtered", width => 1, 
             export => $force_export},
        );
    }

    e_signal->adds(


        {name => "M_bht_wr_en_filtered", width => 1, 
         export => $force_export},
        {name => "M_bht_wr_data_filtered", width => $bht_data_sz, 
         export => $force_export},
        {name => "M_bht_ptr_filtered", width => $bht_ptr_sz, 
         export => $force_export},
    );

    if (manditory_bool($Opt, "asic_enabled")) {

        if (!$Opt->{bht_index_pc_only}) {
            e_assign->adds({
              comment => "Propagating 'X' data bits",
              lhs => "E_add_br_to_taken_history_filtered",
              rhs => "E_add_br_to_taken_history_unfiltered",
            });
        }
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_wr_en_filtered",
          rhs => "M_bht_wr_en_unfiltered",
        });
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_wr_data_filtered",
          rhs => "M_bht_wr_data_unfiltered",
        });
        e_assign->adds({
          comment => "Propagating 'X' data bits",
          lhs => "M_bht_ptr_filtered",
          rhs => "M_bht_ptr_unfiltered",
        });
    } else {





        if (!$Opt->{bht_index_pc_only}) {
            create_x_filter({
              lhs       => "E_add_br_to_taken_history_filtered",
              rhs       => "E_add_br_to_taken_history_unfiltered",
              sz        => 1,
            });
        }
        create_x_filter({
          lhs       => "M_bht_wr_en_filtered",
          rhs       => "M_bht_wr_en_unfiltered", 
          sz        => 1,
        });
        create_x_filter({
          lhs       => "M_bht_wr_data_filtered",
          rhs       => "M_bht_wr_data_unfiltered",
          sz        => $bht_data_sz,
        });
        create_x_filter({
          lhs       => "M_bht_ptr_filtered",
          rhs       => "M_bht_ptr_unfiltered",
          sz        => $bht_ptr_sz,
        });
    }

    my $display = $NIOS_DISPLAY_INST_TRACE | $NIOS_DISPLAY_MEM_TRAFFIC;
    my $use_reg_names = "1";

    my @nevadaModelCheckArgs = (
      $display,
      $use_reg_names,
      @traceArgs
    );

    my $trace_args_ref;
    my $checker_args_ref;
    my $test_end_expr;

    if (manditory_bool($Opt, "activate_monitors")) {
        create_x_checkers(\@x_signals);
    }

    if (manditory_bool($Opt, "activate_test_end_checker")) {




        $test_end_expr = 
          "W_op_sltiu & W_rs_is_zero & W_rt_is_zero &
            ((W_iw_imm16 == 16'habc1) | (W_iw_imm16 == 16'habc2))";
    }

    if (manditory_bool($Opt, "activate_trace")) {
        $trace_args_ref = \@traceArgs;
    }

    if (manditory_bool($Opt, "activate_model_checker")) {
        $checker_args_ref = \@nevadaModelCheckArgs;
    }

    create_trace_checker_testend({
      name              => not_empty_scalar($Opt, "name"),
      inst_retire_expr  => "W_valid",
      trace_event_expr  => "W_valid || W_exc_any_active",
      test_end_expr     => $test_end_expr,
      trace_args        => $trace_args_ref,
      checker_args      => $checker_args_ref,
      num_threads       => 1,
      filename_base     => not_empty_scalar($Opt, "name"),
      language          => not_empty_scalar($Opt, "language"),
      pli_function_name => "nevadaModelCheck", 
    });

    return $submodule;
}













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
                e_if->new({ 
                  condition => $qual,
                  then      => [ 
                    e_if_x->new({ 
                      condition     => $sig, 
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
create_trace_checker_testend
{
    my $args = shift;   # Reference to hash with all arguments.

    validate_hash_keys("args", $args, [
      "name",
      "inst_retire_expr",
      "trace_event_expr",
      "test_end_expr",
      "trace_args",
      "checker_args",
      "num_threads",
      "filename_base",
      "language",
      "pli_function_name",
    ]);

    my $name = not_empty_scalar($args, "name");
    my $inst_retire_expr = not_empty_scalar($args, "inst_retire_expr");
    my $trace_event_expr = not_empty_scalar($args, "trace_event_expr");
    my $test_end_expr = optional_scalar($args, "test_end_expr");
    my $trace_args = optional_array($args, "trace_args");
    my $checker_args = optional_array($args, "checker_args");
    my $num_threads = manditory_int($args, "num_threads");
    my $filename_base = not_empty_scalar($args, "filename_base");
    my $language = not_empty_scalar($args, "language");
    my $pli_function_name = not_empty_scalar($args, "pli_function_name");

    my @process_objs;

    if ($trace_args) {



        my $header_spec = create_rtl_trace_header($name);

        my $trace_string = join(",", map {"%0h"} (@$trace_args));
    
        $trace_string .= "\\n";

        my $file_name = $filename_base . ".tr";
        my $file_handle = "trace_handle";


        e_sim_fopen->adds({
           file_name        => $file_name,
           file_handle      => $file_handle,
           contents         => [
                e_sim_write->new ({
                  spec_string => $header_spec,
                  file_handle => $file_handle,
                })
           ],
        });

        my $condition = "(~reset_n || ($trace_event_expr)) && ~test_has_ended";
    
        push(@process_objs,
          e_if->new({ 
            condition => $condition,
            then      => [ 
              e_sim_write->new ({
                spec_string => $trace_string,
                expressions => $trace_args,
                show_time   => 1,
                file_handle => $file_handle,
              })
            ],
          })
        );
    }

    if ($checker_args && ($language eq "verilog")) {

        push(@process_objs,
          e_if->new({ 
            condition => "~reset_n || ($trace_event_expr)",
            then      => [ 
              e_sim_cmd->new({ 
                function_name => $pli_function_name,
                args          => $checker_args,
              }) 
            ],
          })
        );
    }

    if ($test_end_expr) {


        e_register->adds(


          {out => ["test_ending", 1, $force_export],
           in => "($inst_retire_expr) & ($test_end_expr)",
           enable => "1'b1"},



          {out => ["test_ending_d1", 1, 0, $force_never_export],
           in => "test_ending",
           enable => "1'b1"},
          {out => ["test_ending_d2", 1, 0, $force_never_export],
           in => "test_ending_d1",
           enable => "1'b1"},




          {out => ["test_has_ended", 1, $force_export],
           in => "($inst_retire_expr) & ($test_end_expr) | test_has_ended",
           enable => "1'b1"},
        );

        push(@process_objs,



          e_if->new({ 
            condition => "test_ending_d2",
            then      => [ 
              e_sim_write->new({ 
                spec_string => "Detected end of test\\n",
                show_time   => 1,
              }),
              e_stop->new()
            ],
          })
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




















my $trace_version_0 = 0;

sub
create_rtl_trace_header
{
    my $name = shift;

    my @header_fmt_lines; # Printf-style format strings for header

    push(@header_fmt_lines, "HeaderStart");
    push(@header_fmt_lines, "Version $trace_version_0");
    push(@header_fmt_lines, "CpuCoreName MP32");
    push(@header_fmt_lines, "CpuInstanceName " . $name);
    push(@header_fmt_lines, "CpuArchName Mips32");
    push(@header_fmt_lines, "CpuArchRev R2");
    push(@header_fmt_lines, "HeaderEnd");

    my $header_fmt = join("\\n", @header_fmt_lines) . "\\n";

    return $header_fmt;
}

1;
