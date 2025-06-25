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






















package nios_brpred;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $DYNAMIC_BRPRED
    $STATIC_BRPRED

    $bht_data_sz
    $bht_ptr_sz
    $bht_num_entries
    $bht_pred_offset
    $bht_strength_offset
    $bht_taken
    $bht_not_taken
    $bht_weak
    $bht_strong
    $bht_wt
    $bht_st
    $bht_wnt
    $bht_snt
    $bht_br_cond_taken_history_sz
);

use europa_all;
use europa_utils;
use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use nios_sdp_ram;
use strict;











our $DYNAMIC_BRPRED = "Dynamic";
our $STATIC_BRPRED = "Static";

our $bht_data_sz;
our $bht_ptr_sz;
our $bht_num_entries;
our $bht_pred_offset;
our $bht_strength_offset;
our $bht_taken;
our $bht_not_taken;
our $bht_weak;
our $bht_strong;
our $bht_wt;
our $bht_st;
our $bht_wnt;
our $bht_snt;
our $bht_br_cond_taken_history_sz;





sub
initialize_config_constants
{
    my $Opt = shift;


    $bht_data_sz = 2;
    $bht_ptr_sz = manditory_int($Opt, "bht_ptr_sz");
    $bht_num_entries = 0x1 << $bht_ptr_sz; 



    $bht_pred_offset = 1;
    $bht_strength_offset = 0;


    $bht_taken = 0;
    $bht_not_taken = 1;


    $bht_weak = 0;
    $bht_strong = 1;



    $bht_wt = "2'd" . 
      (($bht_weak << $bht_strength_offset) |
       ($bht_taken << $bht_pred_offset));
    $bht_st = "2'd" . 
      (($bht_strong << $bht_strength_offset) | 
       ($bht_taken << $bht_pred_offset));
    $bht_wnt = "2'd" . 
      (($bht_weak << $bht_strength_offset) |
       ($bht_not_taken << $bht_pred_offset));
    $bht_snt = "2'd" . 
      (($bht_strong << $bht_strength_offset) |
       ($bht_not_taken << $bht_pred_offset));



    $bht_br_cond_taken_history_sz = $bht_ptr_sz;
}

sub
gen_frontend
{
    my $Opt = shift;

    my $brpred_type = not_empty_scalar($Opt, "branch_prediction_type");



    if ($brpred_type eq $STATIC_BRPRED) {
        gen_static_brpred_frontend($Opt);
    } elsif ($brpred_type eq $DYNAMIC_BRPRED) {
        gen_dynamic_brpred_frontend($Opt);
    } else {
        &$error("Unsupported branch_predition_type of '$brpred_type'");
    }
}

sub
gen_backend
{
    my $Opt = shift;

    my $brpred_type = not_empty_scalar($Opt, "branch_prediction_type");



    if ($brpred_type eq $STATIC_BRPRED) {
        gen_static_brpred_backend($Opt);
    } elsif ($brpred_type eq $DYNAMIC_BRPRED) {
        gen_dynamic_brpred_backend($Opt);

        if (!manditory_bool($Opt, "bht_index_pc_only")) {
            e_assign->adds(
              [["E_add_br_to_taken_history_unfiltered", 1], 
                "(E_ctrl_br_cond & E_valid)"],
            );
        }
    } else {
        &$error("Unsupported branch_predition_type of '$brpred_type'");
    }
}





sub 
gen_dynamic_brpred_frontend
{
    my $Opt = shift;

    my $whoami = "Dynamic branch prediction (frontend)";

    my $fetch_npc = not_empty_scalar($Opt, "fetch_npc");
    my $bht_wr_data = not_empty_scalar($Opt, "bht_wr_data");
    my $bht_wr_en = not_empty_scalar($Opt, "bht_wr_en");
    my $bht_wr_addr = not_empty_scalar($Opt, "bht_wr_addr");
    my $bht_br_cond_taken_history = 
      not_empty_scalar($Opt, "bht_br_cond_taken_history");
    my $ps = not_empty_scalar($Opt, "brpred_prediction_stage");

    check_opt_value($Opt, "dispatch_stage", "F", $whoami);
    check_opt_value($Opt, "brpred_table_output_stage", "F", $whoami);






    e_signal->adds(
      ["F_bht_data", $bht_data_sz],
      );




    if (manditory_bool($Opt, "bht_index_pc_only")) {
        e_assign->adds(
          [["F_bht_ptr_nxt", $bht_ptr_sz], 
            $fetch_npc . "[$bht_ptr_sz-1:0]"],
          );
    } else {
        e_assign->adds(
          [["F_bht_ptr_nxt", $bht_ptr_sz], 
            "${fetch_npc}\[$bht_ptr_sz-1:0] ^ 
             ${bht_br_cond_taken_history}\[$bht_ptr_sz-1:0]"],
          );
    }

    my $bht_ram_fname = $Opt->{name} . "_bht_ram";

    if (manditory_bool($Opt, "use_designware")) {


        my $bht_in_port_map = {
           addr_r   => 'F_bht_ptr_nxt',
           addr_w   => 'M_bht_ptr_filtered',
           clk_r    => 'clk',
           clk_w    => 'clk',
           data_w   => 'M_bht_wr_data_filtered',
           en_r_n   => '~F_en',
           en_w_n   => '~M_bht_wr_en_filtered',
           init_r_n => qq(1'b1),
           init_w_n => qq(1'b1),
           rst_r_n  => 'reset_n',
           rst_w_n  => 'reset_n'
         };
    
        my $bht_out_port_map = {
           data_r       => 'F_bht_data',
           data_r_a     => ''
          };
    
        my $bht_parameter_map = {
           ADDR_WIDTH => $bht_ptr_sz,
           DEPTH      => $bht_num_entries,
           WIDTH      => $bht_data_sz,
           MEM_MODE   => 2,
           RST_MODE   => 0
          };
    

        e_comment->add({
          comment => "BCM58 part used to replace BHT Ram\n",
        });

        e_blind_instance->add({
          name                    => $Opt->{name} . "_bht",
          module                  => 'DWC_n2p_bcm58',
          use_sim_models          => 1,
          in_port_map             => $bht_in_port_map,
          out_port_map            => $bht_out_port_map,
          parameter_map           => $bht_parameter_map
        });
    } else {
        nios_sdp_ram->add({
          name                    => $Opt->{name} . "_bht",
          Opt                     => $Opt,
          data_width              => $bht_data_sz,
          address_width           => $bht_ptr_sz,
          num_words               => $bht_num_entries,
          contents_file           => $bht_ram_fname,
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
          ram_block_type          => qq("$Opt->{bht_ram_type}"),
          port_map => {
            clock     => "clk",
    

            data      => $bht_wr_data,
            wren      => $bht_wr_en,
            wraddress => $bht_wr_addr,
    

            rden      => "F_en",
            rdaddress => "F_bht_ptr_nxt",
            q         => "F_bht_data",
            },
        });
    }

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    make_contents_file_for_ram({
      filename_no_suffix        => $bht_ram_fname,
      data_sz                   => $bht_data_sz,
      num_entries               => $bht_num_entries, 
      value_str                 => "random",
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });






    e_register->adds(
      {out => ["${ps}_bht_data", $bht_data_sz],     in => "F_bht_data",
       enable => "${ps}_en"},
      );

    e_assign->adds(

      [["${ps}_br_cond_pred_taken", 1], 
        "(${ps}_bht_data[$bht_pred_offset] == $bht_taken) |
          ${ps}_ctrl_br_always_pred_taken"],


      [["${ps}_br_pred_taken", 1],
        "${ps}_ctrl_br & (${ps}_ctrl_br_uncond | ${ps}_br_cond_pred_taken)"],
      [["${ps}_br_pred_not_taken", 1, 0, $force_never_export], 
        "${ps}_ctrl_br_cond & !${ps}_br_cond_pred_taken"],
      );

    my @dynamic_brpred = (
        { divider => "dynamic_brpred_(frontend)" },
        { radix => "x", signal => "F_bht_ptr_nxt" },
        { radix => "x", signal => "F_iw" },
        { radix => "x", signal => "F_bht_data" },
        { radix => "x", signal => "F_pcb" },
        { radix => "x", signal => "${ps}_iw" },
        { radix => "a", signal => "${ps}_vinst" },
        { radix => "x", signal => "${ps}_pcb" },
        { radix => "x", signal => "${ps}_bht_data" },
        { radix => "x", signal => "${ps}_br_cond_pred_taken" },
        { radix => "x", signal => "${ps}_br_pred_taken" },
        { radix => "x", signal => "${ps}_ctrl_br" },
        { radix => "x", signal => "${ps}_ctrl_br_uncond" },
        { radix => "x", signal => "${ps}_ctrl_br_always_pred_taken" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @dynamic_brpred);
    }
}

sub 
gen_dynamic_brpred_backend
{
    my $Opt = shift;

    my $whoami = "Dynamic branch prediction (backend)";

    my $table_stage = not_empty_scalar($Opt, "brpred_table_output_stage");
    my $add_br_to_taken_history = 
      not_empty_scalar($Opt, "add_br_to_taken_history");


    my $brpred_mispredict_reset = 
      manditory_int($Opt, "brpred_mispredict_reset");

    check_opt_value($Opt, "brpred_resolution_stage", "E", $whoami);
    check_opt_value($Opt, "brpred_mispredict_stage", "M", $whoami);





    e_register->adds(

      {out => ["${table_stage}_bht_ptr", $bht_ptr_sz],       
       in => "${table_stage}_bht_ptr_nxt", enable => "${table_stage}_en"},


      {out => ["D_bht_ptr", $bht_ptr_sz],       in => "${table_stage}_bht_ptr",
       enable => "D_en"},


      {out => ["E_bht_data", $bht_data_sz],     in => "D_bht_data",
       enable => "E_en"},
      {out => ["E_bht_ptr", $bht_ptr_sz],       in => "D_bht_ptr",
       enable => "E_en"},


      {out => ["M_bht_data", $bht_data_sz],     in => "E_bht_data",
       enable => "M_en"},
      {out => ["M_bht_ptr_unfiltered", $bht_ptr_sz],
       in => "E_bht_ptr",
       enable => "M_en"},
      );





    e_assign->adds(


      [["E_br_cond_pred_taken", 1], 
        "(E_bht_data[$bht_pred_offset] == $bht_taken) | 
          E_ctrl_br_always_pred_taken"],


      [["E_br_actually_taken", 1], "E_br_result"],




      [["E_br_mispredict", 1],
        "E_ctrl_br_cond & E_valid" .
          " & (E_br_cond_pred_taken != E_br_actually_taken)"],
    );

    e_register->adds(
      {out => ["M_br_actually_taken", 1, 0, $force_never_export],
       in => "E_br_actually_taken", enable => "M_en"},
      {out => ["M_br_mispredict", 1, 0, $force_never_export],
       in => "E_br_mispredict", enable => "M_en",
       async_value => $brpred_mispredict_reset},
    );





    if (!manditory_bool($Opt, "bht_index_pc_only")) {
        e_assign->adds(


          [["E_br_cond_taken_history", $bht_br_cond_taken_history_sz],
             "$add_br_to_taken_history ? 
                { M_br_cond_taken_history[$bht_br_cond_taken_history_sz-2:0], 
                  E_br_actually_taken } :
                M_br_cond_taken_history"],
          );


        e_register->adds(
          {out => ["M_br_cond_taken_history", $bht_br_cond_taken_history_sz], 
           in => "E_br_cond_taken_history", enable => "M_en"},
        );
    }












    e_mux->add ({
      lhs => ["M_bht_wr_data_unfiltered", $bht_data_sz],
      selecto => "{M_bht_data, M_br_mispredict}",
      table => [
        "{$bht_wt, 1'b0}"  => $bht_st,
        "{$bht_wt, 1'b1}"  => $bht_wnt,
        
        "{$bht_st, 1'b0}"  => $bht_st,
        "{$bht_st, 1'b1}"  => $bht_wt,

        "{$bht_wnt, 1'b0}" => $bht_snt,
        "{$bht_wnt, 1'b1}" => $bht_wt,

        "{$bht_snt, 1'b0}" => $bht_snt,
        "{$bht_snt, 1'b1}" => $bht_wnt,
        ],
      });




    e_assign->adds(
      [["M_bht_wr_en_unfiltered", 1], 
        "M_ctrl_br_cond & ~M_ctrl_br_always_pred_taken & M_valid_from_E"],
    );

    my $br_cond_taken_history_wave = 
      manditory_bool($Opt, "bht_index_pc_only") ? 
        "" :
        { radix => "x", signal => "M_br_cond_taken_history" };

    my @dynamic_brpred = (
        { divider => "dynamic_brpred_(backend)" },
        { radix => "x", signal => "E_br_cond_pred_taken" },
        { radix => "x", signal => "E_br_actually_taken" },
        { radix => "x", signal => "E_br_mispredict" },
        { radix => "x", signal => "M_br_mispredict" },
        $br_cond_taken_history_wave,
        { radix => "x", signal => "M_bht_wr_data_unfiltered" },
        { radix => "x", signal => "M_bht_wr_data_filtered" },
        { radix => "x", signal => "M_bht_wr_en_unfiltered" },
        { radix => "x", signal => "M_bht_wr_en_filtered" },
        { radix => "x", signal => "M_bht_ptr_unfiltered" },
        { radix => "x", signal => "M_bht_ptr_filtered" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @dynamic_brpred);
    }
}

sub 
gen_static_brpred_frontend
{
    my $Opt = shift;

    my $whoami = "Static branch prediction (frontend)";

    my $ps = not_empty_scalar($Opt, "brpred_prediction_stage");

    e_assign->adds(



      [["${ps}_br_cond_pred_taken", 1], 
        "${ps}_iw_imm16[15] | ${ps}_ctrl_br_always_pred_taken"],


      [["${ps}_br_pred_taken", 1],
        "${ps}_ctrl_br & (${ps}_ctrl_br_uncond | ${ps}_br_cond_pred_taken)"],
      [["${ps}_br_pred_not_taken", 1, 0, $force_never_export], 
        "${ps}_ctrl_br_cond & !${ps}_br_cond_pred_taken"],
    );

    my @static_brpred = (
        { divider => "static_brpred_(frontend)" },
        { radix => "x", signal => "${ps}_iw" },
        { radix => "a", signal => "${ps}_vinst" },
        { radix => "x", signal => "${ps}_pcb" },
        { radix => "x", signal => "${ps}_br_cond_pred_taken" },
        { radix => "x", signal => "${ps}_br_pred_taken" },
        { radix => "x", signal => "${ps}_ctrl_br" },
        { radix => "x", signal => "${ps}_ctrl_br_uncond" },
        { radix => "x", signal => "${ps}_ctrl_br_always_pred_taken" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @static_brpred);
    }
}

sub 
gen_static_brpred_backend
{
    my $Opt = shift;

    my $whoami = "Static branch prediction (backend)";

    my $table_stage = not_empty_scalar($Opt, "brpred_table_output_stage");

    check_opt_value($Opt, "brpred_resolution_stage", "E", $whoami);
    check_opt_value($Opt, "brpred_mispredict_stage", "M", $whoami);


    my $brpred_mispredict_reset = 
      manditory_int($Opt, "brpred_mispredict_reset");





    e_assign->adds(



      [["E_br_cond_pred_taken", 1], 
        "E_iw_imm16[15] | E_ctrl_br_always_pred_taken"],



      [["E_br_actually_taken", 1], "E_br_result"],



      [["E_br_mispredict", 1],
        "E_ctrl_br_cond & E_valid" .
          " & (E_br_cond_pred_taken != E_br_actually_taken)"],
    );

    e_register->adds(
      {out => ["M_br_actually_taken", 1, 0, $force_never_export],
       in => "E_br_actually_taken", enable => "M_en"},
      {out => ["M_br_mispredict", 1, 0, $force_never_export],
       in => "E_br_mispredict", enable => "M_en",
       async_value => $brpred_mispredict_reset},
    );

    my @static_brpred = (
        { divider => "static_brpred_(backend)" },
        { radix => "x", signal => "E_br_cond_pred_taken" },
        { radix => "x", signal => "E_br_actually_taken" },
        { radix => "x", signal => "E_br_mispredict" },
        { radix => "x", signal => "M_br_mispredict" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @static_brpred);
    }
}

1;
