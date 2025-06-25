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
use europa_all;
use cpu_wave_signals;
use nios_isa;
use nios2_common;
use nios2_control_regs;
use nios2_mmu;
use strict;







sub make_nios2_oci_itrace
{
  my $Opt = shift;
  my $name = $Opt->{name};
  my $whoami = $name . "_nios2_oci_itrace";

  my $module = e_module->new ({
      name    => $whoami,
  });

  my $tm_data_width = $Opt->{oci_tm_width}-4;     # bits in tm data field
  my $dct_count_width = ($tm_data_width > 16) ? 4 : 3;  # Num bits in pending DCT counter
  my $dct_count_max = ($tm_data_width > 16) ? "4'd15" : "3'b7";
  my $cpu_i_address_width = $Opt->{cpu_i_address_width};
  my $oci_onchip_trace = $Opt->{oci_onchip_trace} ? 1 : 0;
  my $oci_offchip_trace = $Opt->{oci_offchip_trace} ? 1 : 0;


  my $is_fast  = ($Opt->{core_type} eq "fast") ? 1 : 0;
  my $is_small = ($Opt->{core_type} eq "small") ? 1 : 0;
  my $is_tiny  = ($Opt->{core_type} eq "tiny") ? 1 : 0;
  ($is_fast ^ $is_small ^ $is_tiny) or 
    &$error ("Unable to determine CPU Implementation ".  $Opt->{core_type});



  $module->add_contents (

    e_signal->news (
      ["trc_ctrl", 16, $force_export],              # trace control register
      ["trc_on", 1, $force_export],                 # trace should be collected
      ["itm", $Opt->{oci_tm_width}, $force_export], # instruction trace frame (aka message)
      ["dct_count", $dct_count_width, $force_export], # number of DCT instructions in DCT buffer
      ["dct_buffer", $tm_data_width-2, $force_export],# partially completed DCT frame
    ),
  );

  if (manditory_bool($Opt, "asic_enabled")) {


    $module->add_contents (
      e_signal->news ( 
        ["jdo",                   38,             0],
      ),
    );
  } else {
    $module->add_contents (

      e_signal->news (
        ["jdo",                   $TRACECTRL_WIDTH,             0],
      ),

    );
  }






  $module->add_contents (
    e_signal->news (
      ["pending_frametype", 4, 0, $force_never_export], # 4-bit frame type for next syncpoint frame
      ["pending_exc", 1, 0, $force_never_export],       # An exception occurred and hasn't generated its 2 EXC frames yet
      ["pending_exc_addr", $tm_data_width, 0, $force_never_export],  # PCB + 4 of instruction that took exception
      ["pending_exc_handler", $tm_data_width, 0, $force_never_export],  # PCB of exception handler
      ["pending_exc_record_handler", 1, 0, $force_never_export],  # Should exc_addr or handler be recorded?
      ["exc_addr", $tm_data_width, 0, $force_never_export], # exception address -- padded
      ["eic_addr", $tm_data_width, 0, $force_never_export], # external interrupt handler address -- padded
      ["sync_timer",   7,    0, $force_never_export], # interval timer for sync frames
      ["sync_timer_next", 7, 0, $force_never_export], # next value of sync_timer
      ["sync_interval",   7, 0, $force_never_export], # distance between sync frames
      ["sync_code",    2,    0, $force_never_export], # sync interval code from control register
      ["retired_pcb", $tm_data_width, 0, $force_never_export], # instruction address -- padded
      ["trc_ctrl_reg", 11,  0, $force_never_export],    # local storage for trace control register
      ["dct_code",     2,   0, $force_never_export],    # 2-bit DCT code
      ["not_in_debug_mode", 1, 0, $force_never_export], # to mask off trace due to OCI monitor
      ["curr_pid", $tlb_max_pid_sz, 0, $force_never_export], # current PID
      ["prev_pid", $tlb_max_pid_sz, 0, $force_never_export], # previous PID
      ["prev_pid_valid", 1, 0, $force_never_export], # previous PID contains a valid value
      ["snapped_pid", 1, 0, $force_never_export], # Snapped curr/prev PID and want to generate a PID frame
      ["snapped_curr_pid", $tlb_max_pid_sz, 0, $force_never_export], # snapshot of current PID 
      ["snapped_prev_pid", $tlb_max_pid_sz, 0, $force_never_export], # snapshot of previous PID 
      ["pending_curr_pid", $tlb_max_pid_sz, 0, $force_never_export], # Current PID used in the PID frame
      ["pending_prev_pid", $tlb_max_pid_sz, 0, $force_never_export], # Previous PID used in the PID frame
    ),
  );






  if ($is_fast) {

    my $advanced_exc = $Opt->{advanced_exc};


    my $eic_present = $Opt->{eic_present};


    $module->add_contents (
      e_assign->news (

        ["is_cond_dct",    "A_op_bge  | A_op_blt | A_op_bne | A_op_bgeu | 
                            A_op_bltu | A_op_beq"],
        ["is_uncond_dct",  "A_op_br | A_op_call | A_op_jmpi"], #  only used below
        ["is_dct",         "is_cond_dct | is_uncond_dct"],
        ["cond_dct_taken", "A_cmp_result"],
        ["dct_is_taken",   "is_uncond_dct | (is_cond_dct & cond_dct_taken)"],


        ["is_idct",         "A_op_jmp | A_op_callr | A_op_ret | A_op_eret | A_op_bret"],

        ["retired_pcb",     "A_pcb"],  













        ["not_in_debug_mode", $advanced_exc ? "~debugack" : "~d1_debugack"],


        ["instr_retired", "A_valid & A_en"],



        ["advanced_exc_occured", $advanced_exc ? "A_exc_active_no_crst" : "1'b0" ],


        ["is_exception_no_break", 
          $advanced_exc ? "A_exc_active_no_break_no_crst" : "A_ctrl_exception"],


        ["is_external_interrupt", $eic_present  ? "A_exc_ext_intr" : "1'b0"],


        ["is_fast_tlb_miss_exception", $mmu_present  ? "A_exc_fast_tlb_miss" : "1'b0"],


        ["curr_pid", $mmu_present ? "W_tlbmisc_reg_pid" : "0" ],


        ["exc_addr", "A_wr_data_filtered"],


        ["eic_addr", $eic_present ? "A_eic_rha" : "0" ],
      ),






      e_register->new ({
        user_attributes => [
          {
            attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
            attribute_operator => '=',
            attribute_values => [qw(D103)],
          },
        ],
        out => ["d1_debugack", 1, 0, $force_never_export],
        in  => "debugack",
        enable  => "instr_retired",
      }),
    );
  } elsif ($is_small) {

    $module->add_contents (
      e_assign->news (

        ["is_cond_dct",    "M_op_bge  | M_op_blt | M_op_bne | M_op_bgeu | 
                            M_op_bltu | M_op_beq"],
        ["is_uncond_dct",  "M_op_br | M_op_call | M_op_jmpi"], #  only used below
        ["is_dct",         "is_cond_dct | is_uncond_dct"],
        ["cond_dct_taken", "M_cmp_result"],
        ["dct_is_taken",   "is_uncond_dct | (is_cond_dct & cond_dct_taken)"],


        ["is_idct",  "M_op_jmp | M_op_callr | M_op_ret | M_op_eret | M_op_bret"],

        ["retired_pcb",             "M_pcb"],  
        ["not_in_debug_mode",       "~debugack"],         


        ["instr_retired", "M_valid & M_en"],


        ["advanced_exc_occured", "1'b0"],


        ["is_exception_no_break", "M_ctrl_exception"],

        ["is_external_interrupt", "1'b0"],
        ["is_fast_tlb_miss_exception", "1'b0"],
        ["curr_pid", "1'b0" ],


        ["exc_addr", "M_wr_data_filtered"],         


        ["eic_addr", "32'b0"],
      ),
    );
  } else {
    print "Trace is not supported for this pipeline variant.\n".  
          "Tying trace signals to 0.\n"
      if (($Opt->{oci_onchip_trace}) || ($Opt->{oci_offchip_trace}));
    $module->add_contents (
      e_assign->news (
        ["is_cond_dct",                 "1'b0"],
        ["is_dct",                      "1'b0"],
        ["dct_is_taken",                "1'b0"],
        ["is_idct",                     "1'b0"],
        ["retired_pcb",                 "32'b0"],  
        ["not_in_debug_mode",           "1'b0"],         
        ["instr_retired",               "1'b0"],
        ["advanced_exc_occured",       "1'b0"],
        ["is_exception_no_break",       "1'b0"],
        ["is_external_interrupt",       "1'b0"],
        ["is_fast_tlb_miss_exception",  "1'b0"],
        ["curr_pid",                    "1'b0"],
        ["exc_addr",                    "32'b0"],         
        ["eic_addr",                    "32'b0"],
      ),
    );
  }




























  $module->add_contents (
    e_assign->news (
      ["sync_code" => "trc_ctrl[$TRC_SYN_BITS]"],

      ["sync_interval" => "{ ".
          "sync_code[1] & sync_code[0], ".
          "1'b0, ".
          "sync_code[1] & ~sync_code[0], ".
          "1'b0, ".
          "~sync_code[1] & sync_code[0], ".
          "2'b00 }"],


      ["sync_timer_reached_zero" => "sync_timer == 0"],



      ["record_dct_outcome_in_sync" => "dct_is_taken & sync_timer_reached_zero"],

      ["sync_timer_next" => "sync_timer_reached_zero ? sync_timer : (sync_timer - 1)"],


      ["record_itrace" => "trc_on & trc_ctrl[$TRC_TX_BIT]"], 







      ["dct_code" =>  "{is_cond_dct, dct_is_taken}"],
    ),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      asynchronous_contents => [
        e_assign->news (
          ["trc_clear" => "0"],
        ),
      ],
      user_attributes_names => ["trc_clear"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101)],
        },
      ],
      contents => [
        e_assign->new (
          ["trc_clear" => "~trc_enb & 
                  take_action_tracectrl & jdo[$TRACECTRL_TAAR_POS]"],
        ),
      ],
    }),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["itm","dct_buffer","dct_count","sync_timer",
                                "pending_frametype","pending_exc_handler","pending_exc_record_handler",
                                "curr_pid","prev_pid","prev_pid_valid",
                                "snapped_pid","snapped_curr_pid","snapped_prev_pid",
                                "pending_curr_pid","pending_prev_pid"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["itm" => "0"],
          ["dct_buffer" => "0"],
          ["dct_count" => "0"],
          ["sync_timer" => "0"],
          ["pending_frametype" => "$TM_NOP"],
          ["pending_exc" => "0"],
          ["pending_exc_addr" => "0"],
          ["pending_exc_handler" => "0"],
          ["pending_exc_record_handler" => "0"],
          ["prev_pid" => "0"],
          ["prev_pid_valid" => "0"],
          ["snapped_pid" => "0"],
          ["snapped_curr_pid" => "0"],
          ["snapped_prev_pid" => "0"],
          ["pending_curr_pid" => "0"],
          ["pending_prev_pid" => "0"],
        ),
      ],
      contents => [
        e_if->new ({ condition => "trc_clear || (!$oci_onchip_trace && !$oci_offchip_trace)", then => [

          ["itm" => "0"],
          ["dct_buffer" => "0"],
          ["dct_count" => "0"],
          ["sync_timer" => "0"],
          ["pending_frametype" => "$TM_NOP"],
          ["pending_exc" => "0"],
          ["pending_exc_addr" => "0"],
          ["pending_exc_handler" => "0"],
          ["pending_exc_record_handler" => "0"],
          ["prev_pid" => "0"],
          ["prev_pid_valid" => "0"],
          ["snapped_pid" => "0"],
          ["snapped_curr_pid" => "0"],
          ["snapped_prev_pid" => "0"],
          ["pending_curr_pid" => "0"],
          ["pending_prev_pid" => "0"],
        ], else => [


          e_if->new ({ condition => "!prev_pid_valid", then => [
            ["prev_pid" => "curr_pid"],
            ["prev_pid_valid" => "1"],
          ],
          }),
        

          e_if->new ({ condition => 
           "(curr_pid != prev_pid) & prev_pid_valid & !snapped_pid", then => [

            ["snapped_pid" => "1"],


            ["snapped_curr_pid" => "curr_pid"],
            ["snapped_prev_pid" => "prev_pid"],


            ["prev_pid" => "curr_pid"],
            ["prev_pid_valid" => "1"],
          ],
          }),





          e_if->new ({ condition => "instr_retired | advanced_exc_occured", then => [



  










            e_if->new ({ condition => "~record_itrace", then => [



              ["pending_frametype" => "$TM_GAP"]
            ], elsif => { condition => "is_exception_no_break", then => [







              ["pending_exc" => "1"],
              ["pending_exc_addr" => "exc_addr" ],
              ["pending_exc_record_handler" => "0"],
              e_if->new ({ condition => "is_external_interrupt", then => [
                ["pending_exc_handler" => "eic_addr"]
              ], elsif => { condition => "is_fast_tlb_miss_exception", then => [
                ["pending_exc_handler" => sprintf("32'h%x", $Opt->{fast_tlb_miss_exception_addr}) ]
              ], else => [
                ["pending_exc_handler" => sprintf("32'h%x", $Opt->{general_exception_addr}) ]
              ], # else
              }, # elsif is_fast_tlb_miss_exception
              }), # if is_external_interrupt







              ["pending_frametype" => "$TM_NOP"]
            ], elsif => { condition => "is_idct", then => [
              ["pending_frametype" => "$TM_IDCT"]
            ], elsif => { condition => "record_dct_outcome_in_sync", then  => [
              ["pending_frametype" => "$TM_SYNC"]
            ], elsif => { condition => "!is_dct & snapped_pid", then  => [


              ["pending_frametype" => "$TM_PID"],
              ["pending_curr_pid" => "snapped_curr_pid"],
              ["pending_prev_pid" => "snapped_prev_pid"],
              ["snapped_pid" => "0"],
            ], else => [

              ["pending_frametype" => "$TM_NOP"]
            ], # else
            }, # elsif record_dct_outcome_in_sync
            }, # elsif is_idct
            }, # elsif !is_dct ...
            }, # elsif is_exception_no_break
            }), # if ~record_itrace
  



  
            e_if->new ({ condition => "(dct_count != 0) & 
             (~record_itrace | 
              is_exception_no_break |
              is_idct |
              record_dct_outcome_in_sync |
              (!is_dct & snapped_pid))", then => [
















                ["itm" => "{$TM_DCT, dct_buffer, 2'b00}"],
                ["dct_buffer" => "0"],
                ["dct_count" => "0"],
                ["sync_timer" => "sync_timer_next"],
              ], else => [




                e_if->new ({ condition => "record_itrace & " .
                 "(is_dct & (dct_count != $dct_count_max)) & " .
                 "~record_dct_outcome_in_sync & ~advanced_exc_occured", then  => [

                  ["dct_buffer" => "{dct_code, dct_buffer[$tm_data_width-3:2]}"],
                  ["dct_count" => "dct_count + 1"],
                ],
                }),
  

                e_if->new ({ condition => "record_itrace & (
                  (pending_frametype == $TM_SYNC) |
                  (pending_frametype == $TM_GAP) |
                  (pending_frametype == $TM_IDCT))", then => [



                  ["itm" => "{pending_frametype, retired_pcb}"],
                  ["sync_timer" => "sync_interval"], # restart sync timer
  



                  e_if->new ({ condition => "$mmu_present &
                      ((pending_frametype == $TM_SYNC) | (pending_frametype == $TM_GAP)) &
                      !snapped_pid & prev_pid_valid", then => [  
                    ["snapped_pid" => "1"],
                    ["snapped_curr_pid" => "curr_pid"],
                    ["snapped_prev_pid" => "prev_pid"],
                  ],
                  }),
                ], elsif => { condition => "record_itrace & 
                  $mmu_present & (pending_frametype == $TM_PID)", then => [

                  ["itm" => "{$TM_PID, 2'b00, pending_prev_pid, 2'b00, pending_curr_pid}"],
                ], elsif => { condition => "record_itrace & is_dct", then => [










                  e_if->new ({ condition => "(dct_count == $dct_count_max)", then => [
                     ["itm" => "{$TM_DCT, dct_code, dct_buffer}"],
                     ["dct_buffer" => "0"],
                     ["dct_count" => "0"],
                     ["sync_timer" => "sync_timer_next"],
                  ],
                  else  => [

                    ["itm" => "$TM_NOP"],
                  ],
                  }),
                ], else  => [

                  ["itm" => "{$TM_NOP, 32'b0}"],
                ], # else
                }, # elsif record_itrace & is_dct
                }, # elsif record_itrace & PID
                }), # if record_itrace & SYNC/GAP/IDCT
              ], # else not flushing DCT buffer
            }), # if create DCT frame
          ], else  => [


            e_if->new ({ condition => "record_itrace & pending_exc", then => [  
              e_if->new ({ condition => "pending_exc_record_handler", then => [


                ["itm" => "{$TM_EXC, pending_exc_handler[$tm_data_width-1:1], $PAYLOAD_EXC_HANDLER_ADDR}" ],


                ["pending_exc" => "1'b0" ],
                ["pending_exc_record_handler" => "1'b0" ],
              ], else => [


                ["itm" => "{$TM_EXC, pending_exc_addr[$tm_data_width-1:1], $PAYLOAD_EXC_EXCEPTED_ADDR}" ],
  


                ["pending_exc_record_handler" => "1'b1" ],
              ],
              }), # end if pending_exc_record_handler
            ], else => [

              ["itm" => "{$TM_NOP, 32'b0}"],
            ],
            }), # end if record_itrace & pending_exc
          ], # end else 
          }), # end if (instruction retired | advanced exception)
        ], # else not trc_clear
        }), # end if trc_clear ...
      ], # end of contents
    }), # end e_process






    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["trc_ctrl_reg"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 D103 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["trc_ctrl_reg[$TRC_ENB_BIT]" => $create_comptr ? "1'b1" : "1'b0"],
          ["trc_ctrl_reg[$TRC_ON_BIT]" => $create_comptr ? "1'b1" : "1'b0"],
          ["trc_ctrl_reg[$TRC_SYN_BITS]" => $create_comptr ? "2'b01" : "2'b00"], # Sync every 4 DCT frames
          ["trc_ctrl_reg[$TRC_TX_BIT]" => $create_comptr ? "1'b1" : "1'b0"],
          ["trc_ctrl_reg[$TRC_TD_BITS]" => 
            ($create_comptr && $Opt->{oci_data_trace}) ? "3'b111" : "3'b000"],
          ["trc_ctrl_reg[$TRC_OFC_BIT]" => $create_comptr ? "0" : "$oci_offchip_trace"],
          ["trc_ctrl_reg[$TRC_DEBUG_BIT]" => "1'b0"],
          ["trc_ctrl_reg[$TRC_FULL_BIT]" => "1'b0"],
        ),
      ],
      contents  => [
        e_if->new ({
          condition => "take_action_tracectrl",
          then  => [
            ["trc_ctrl_reg[$TRC_ENB_BIT]" => "jdo[$TRACECTRL_ENB_POS]"],
            ["trc_ctrl_reg[$TRC_ON_BIT]" => "jdo[$TRACECTRL_ON_OFF_POS]"],
            ["trc_ctrl_reg[$TRC_SYN_BITS]" => "jdo[$TRACECTRL_SYN_POS]"],
            ["trc_ctrl_reg[$TRC_TX_BIT]" => "jdo[$TRACECTRL_TX_POS]"],
            ["trc_ctrl_reg[$TRC_DEBUG_BIT]" => "jdo[$TRACECTRL_DB_POS]"],
            ["trc_ctrl_reg[$TRC_FULL_BIT]" => "jdo[$TRACECTRL_FULL_POS]"],
            e_if->new ({
              condition => ($Opt->{oci_data_trace}),
              then => [ 
                ["trc_ctrl_reg[$TRC_TD_BITS]" => "jdo[$TRACECTRL_TD_POS]"] 
              ],
            }),
            e_if->new ({
              condition => "$oci_onchip_trace & $oci_offchip_trace",
              then => [ 
                ["trc_ctrl_reg[$TRC_OFC_BIT]" => "jdo[$TRACECTRL_OFC_POS]"] ],
            }),
          ],
          else => [
            e_if->new ({
              condition => "xbrk_wrap_traceoff",
              then => [ 


                ["trc_ctrl_reg[$TRC_ON_BIT]" => "0"],   
                ["trc_ctrl_reg[$TRC_ENB_BIT]" => "0"],  
              ],
              elsif => {
                condition => "dbrk_traceoff | xbrk_traceoff",
                then => [ ["trc_ctrl_reg[$TRC_ON_BIT]" => "0"] ],
                else => [
                  e_if->new ({
                    condition => "trc_ctrl_reg[$TRC_ENB_BIT] & 
                                  (dbrk_traceon | xbrk_traceon)",
                    then => [ ["trc_ctrl_reg[$TRC_ON_BIT]" => "1"] ],
                  }),
                ],
              },
            }),
          ],
        }),
      ],  # end contents
    }), # end trace control register e_process
    e_assign->news (
      ["trc_ctrl" => 
        "($oci_onchip_trace || $oci_offchip_trace) ? " .
          "{6'b000000, trc_ctrl_reg} : " .
          "0"],


      ["trc_on" => "trc_ctrl[$TRC_ON_BIT] & (trc_ctrl[$TRC_DEBUG_BIT] | not_in_debug_mode)"],
    ),
  ); # end add_contents

  my $wpath = "the_" . $name . "_nios2_oci/the_" . $whoami . "/";

  my @wave_signals = (
    { divider => $whoami },
    { radix => "x", signal => $wpath . "cond_dct_taken" },
    { radix => "x", signal => $wpath . "curr_pid" },
    { radix => "x", signal => $wpath . "dct_buffer" },
    { radix => "x", signal => $wpath . "dct_code" },
    { radix => "x", signal => $wpath . "dct_count" },
    { radix => "x", signal => $wpath . "dct_is_taken" },
    { radix => "x", signal => $wpath . "exc_addr" },
    { radix => "x", signal => $wpath . "instr_retired" },
    { radix => "x", signal => $wpath . "advanced_exc_occured" },
    { radix => "x", signal => $wpath . "is_cond_dct" },
    { radix => "x", signal => $wpath . "is_dct" },
    { radix => "x", signal => $wpath . "is_exception_no_break" },
    { radix => "x", signal => $wpath . "is_fast_tlb_miss_exception" },
    { radix => "x", signal => $wpath . "is_idct" },
    { radix => "x", signal => $wpath . "is_uncond_dct" },
    { radix => "x", signal => $wpath . "itm" },
    { radix => "x", signal => $wpath . "not_in_debug_mode" },
    { radix => "x", signal => $wpath . "pending_curr_pid" },
    { radix => "x", signal => $wpath . "pending_exc_addr" },
    { radix => "x", signal => $wpath . "pending_exc_handler" },
    { radix => "x", signal => $wpath . "pending_exc_record_handler" },
    { radix => "x", signal => $wpath . "pending_frametype" },
    { radix => "x", signal => $wpath . "pending_prev_pid" },
    { radix => "x", signal => $wpath . "prev_pid" },
    { radix => "x", signal => $wpath . "prev_pid_valid" },
    { radix => "x", signal => $wpath . "record_dct_outcome_in_sync" },
    { radix => "x", signal => $wpath . "record_itrace" },
    { radix => "x", signal => $wpath . "retired_pcb" },
    { radix => "x", signal => $wpath . "snapped_curr_pid" },
    { radix => "x", signal => $wpath . "snapped_pid" },
    { radix => "x", signal => $wpath . "snapped_prev_pid" },
    { radix => "x", signal => $wpath . "sync_code" },
    { radix => "x", signal => $wpath . "sync_interval" },
    { radix => "x", signal => $wpath . "sync_timer_reached_zero" },
    { radix => "x", signal => $wpath . "sync_timer" },
    { radix => "x", signal => $wpath . "sync_timer_next" },
    { radix => "x", signal => $wpath . "trc_clear" },
    { radix => "x", signal => $wpath . "trc_ctrl" },
    { radix => "x", signal => $wpath . "trc_ctrl_reg" },
    { radix => "x", signal => $wpath . "trc_on" },
  );

  if ($Opt->{full_waveform_signals}) {
      push(@plaintext_wave_signals, @wave_signals);
  }

  return $module;
} # end module make_nios2_oci_itrace


"
Fabienne: Whose motorcycle is this? 
Butch: It's a chopper, baby. 
Fabienne: Whose chopper is this? 
Butch: It's Zed's. 
Fabienne: Who's Zed? 
Butch: Zed's dead, baby. Zed's dead. 
";
