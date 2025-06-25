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






















package nios_backend_500;

use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_gen;
use cpu_inst_gen;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use nios_utils;
use nios_europa;
use nios_addr_utils;
use nios_testbench_utils;
use nios_sdp_ram;
use nios_avalon_masters;
use nios_brpred;
use nios_common;
use nios_isa;
use nios_dcache;
use nios_div;
use nios_shift_rotate;

use strict;


















































sub 
gen_backend_500
{
    my $Opt = shift;



    nios_brpred::gen_backend($Opt);

    gen_register_file($Opt);

    nios_shift_rotate::gen_shift_rotate($Opt);

    if ($hw_div) {
        nios_div::gen_div($Opt);
    }

    if ($dcache_present) {
        nios_dcache::gen_dcache($Opt);
    }

    if ($data_master_present) {
        gen_data_master($Opt);
        gen_slow_ld_aligner($Opt);
    }

    if ($dtcm_present) {
        gen_data_tcm_masters($Opt);
    }

    if ($dcache_present || $dtcm_present) {
        gen_data_ram_ld_aligner($Opt);
    } else {


        e_assign->adds(
          [["A_inst_result_aligned", $datapath_sz], "A_inst_result"],
        );
    }

    e_register->adds(
      {out => ["A_en_d1", 1, 0, $force_never_export], in => "A_en",    
       enable => "1'b1"},
    );
}






sub
gen_brpred
{
    my $Opt = shift;

    my $brpred_type = not_empty_scalar($Opt, "branch_prediction_type");



    if ($brpred_type eq $STATIC_BRPRED) {
        nios_brpred::backend_gen_static_brpred($Opt);
    } elsif ($brpred_type eq $DYNAMIC_BRPRED) {
        nios_brpred::backend_gen_dynamic_brpred($Opt);

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
gen_register_file
{
    my $Opt = shift;

    my $whoami = "register file";

    my $gen_info = manditory_hash($Opt, "gen_info");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");


    my $fa = not_empty_scalar($Opt, "rf_a_field_name");
    my $fb = not_empty_scalar($Opt, "rf_b_field_name");

    my $crs = 
      $shadow_present ? not_empty_scalar($Opt, "current_register_set") : undef;
    my $prs = 
      $shadow_present ? not_empty_scalar($Opt, "previous_register_set") : undef;


    e_signal->adds(
      {name => "rf_a_rd_port_data", width => $datapath_sz },
      {name => "rf_b_rd_port_data", width => $datapath_sz },
    );
    if ($rf_ecc_present) {
        e_signal->adds(
         {name => "rf_a_rd_port_corrected_data", width => $datapath_sz },
         {name => "rf_a_rd_port_one_bit_err", width => 1 },
         {name => "rf_a_rd_port_two_bit_err", width => 1 },
         {name => "rf_a_rd_port_any_ecc_err", width => 1, never_export => 1 },

         {name => "rf_b_rd_port_corrected_data", width => $datapath_sz },
         {name => "rf_b_rd_port_one_bit_err", width => 1 },
         {name => "rf_b_rd_port_two_bit_err", width => 1 },
         {name => "rf_b_rd_port_any_ecc_err", width => 1, never_export => 1 },

         {name => "rf_wr_port_injected_data", width => $datapath_sz },
       );
    }

    my $rf_a_port_map = {
      clock     => "clk",


      rdaddress => "rf_a_rd_port_addr",
      q         => "rf_a_rd_port_data",


      wren      => "rf_wr_port_en",
      data      => "rf_wr_port_data",
      wraddress => "rf_wr_port_addr",
    };

    my $rf_b_port_map = {
      clock     => "clk",


      rdaddress => "rf_b_rd_port_addr",
      q         => "rf_b_rd_port_data",


      wren      => "rf_wr_port_en",
      data      => "rf_wr_port_data",
      wraddress => "rf_wr_port_addr",
    };

    my @ecc_waves;

    if ($rf_ecc_present) {
        my $ecc_datapath_msb = $datapath_sz + calc_num_ecc_bits($datapath_sz) - 1;

        $rf_a_port_map->{corrected_data_to_encoder} = "rf_wr_port_corrected_data";
        $rf_a_port_map->{injs} = "rf_wr_port_injs";
        $rf_a_port_map->{injd} = "rf_wr_port_injd";
        $rf_a_port_map->{wrsel} = "rf_wr_port_wrsel";
        $rf_a_port_map->{injected_data} = "rf_wr_port_injected_data";
        if ($ecc_test_ports_present) {
            $rf_a_port_map->{test_invert} = "ecc_test_rf[$ecc_datapath_msb:0]";
        }

        $rf_b_port_map->{corrected_data_to_encoder} = "rf_wr_port_corrected_data";
        $rf_b_port_map->{injs} = "rf_wr_port_injs";
        $rf_b_port_map->{injd} = "rf_wr_port_injd";
        $rf_b_port_map->{wrsel} = "rf_wr_port_wrsel";
        if ($ecc_test_ports_present) {
            $rf_b_port_map->{test_invert} = "ecc_test_rf[$ecc_datapath_msb:0]";
        }


        $rf_a_port_map->{corrected_data_from_decoder} = "rf_a_rd_port_corrected_data";
        $rf_a_port_map->{one_bit_err} = "rf_a_rd_port_one_bit_err";
        $rf_a_port_map->{two_bit_err} = "rf_a_rd_port_two_bit_err";
        $rf_a_port_map->{one_two_or_three_bit_err} = "rf_a_rd_port_any_ecc_err";

        $rf_b_port_map->{corrected_data_from_decoder} = "rf_b_rd_port_corrected_data";
        $rf_b_port_map->{one_bit_err} = "rf_b_rd_port_one_bit_err";
        $rf_b_port_map->{two_bit_err} = "rf_b_rd_port_two_bit_err";
        $rf_b_port_map->{one_two_or_three_bit_err} = "rf_b_rd_port_any_ecc_err";

        push(@ecc_waves,
          { radix => "x", signal => "rf_wr_port_corrected_data" },
          { radix => "x", signal => "rf_wr_port_injs" },
          { radix => "x", signal => "rf_wr_port_injd" },
          { radix => "x", signal => "rf_wr_port_wrsel" },
          { radix => "x", signal => "rf_a_rd_port_corrected_data" },
          { radix => "x", signal => "rf_a_rd_port_one_bit_err" },
          { radix => "x", signal => "rf_a_rd_port_two_bit_err" },
          { radix => "x", signal => "rf_a_rd_port_any_ecc_err" },
          { radix => "x", signal => "rf_b_rd_port_corrected_data" },
          { radix => "x", signal => "rf_b_rd_port_one_bit_err" },
          { radix => "x", signal => "rf_b_rd_port_two_bit_err" },
          { radix => "x", signal => "rf_b_rd_port_any_ecc_err" },
        );

        push(@ecc_waves,
            { radix => "x", signal => "W_rf_injs" },
            { radix => "x", signal => "W_rf_injd" },
        );

        e_assign->adds(

          [["rf_wr_port_injs", 1], "W_rf_injs"],
          [["rf_wr_port_injd", 1], "W_rf_injd"],






          [["E_rf_a_raw_recoverable_ecc_err", 1], 
            "E_rf_a_one_bit_err & E_ctrl_a_is_src & E_src1_from_rf & (E_iw_a != 0)"],
          [["E_rf_b_raw_recoverable_ecc_err", 1], 
            "E_rf_b_one_bit_err & E_ctrl_b_is_src & E_src2_from_rf & (E_iw_b != 0)"],






          [["E_rf_a_raw_unrecoverable_ecc_err", 1], 
            "E_rf_a_two_bit_err & E_ctrl_a_is_src & E_src1_from_rf & (E_iw_a != 0)"],
          [["E_rf_b_raw_unrecoverable_ecc_err", 1], 
            "E_rf_b_two_bit_err & E_ctrl_b_is_src & E_src2_from_rf & (E_iw_b != 0)"],



          [["rf_wr_port_wrsel", 1], "A_rf_valid_recoverable_ecc_err"],


          [["D_rf_a_corrected_data", $datapath_sz], "rf_a_rd_port_corrected_data"],
          [["D_rf_a_one_bit_err", 1], "rf_a_rd_port_one_bit_err"],
          [["D_rf_a_two_bit_err", 1], "rf_a_rd_port_two_bit_err"],
          [["D_rf_b_corrected_data", $datapath_sz], "rf_b_rd_port_corrected_data"],
          [["D_rf_b_one_bit_err", 1], "rf_b_rd_port_one_bit_err"],
          [["D_rf_b_two_bit_err", 1], "rf_b_rd_port_two_bit_err"],
          [["rf_wr_port_corrected_data", $datapath_sz], "A_rf_corrected_data"],
          [["A_rf_injected_wr_data", $datapath_sz, 0, $force_never_export], "rf_wr_port_injected_data"],
        );


        cpu_pipeline_signal($gen_info, 
          { name => "${ds}_rf_rd_addr_a", sz => $rf_total_addr_sz, never_export => 1,
            until_stage => "E"});
        cpu_pipeline_signal($gen_info, 
          { name => "${ds}_rf_rd_addr_b", sz => $rf_total_addr_sz, never_export => 1,
            until_stage => "E"});





        cpu_pipeline_signal($gen_info, 
          { name => "E_rf_rd_addr", sz => $rf_total_addr_sz, never_export => 1,
            rhs => "E_rf_a_raw_recoverable_ecc_err ? E_rf_rd_addr_a : E_rf_rd_addr_b"});

        e_register->adds(

          {out => ["E_rf_a_one_bit_err", 1], in => "D_rf_a_one_bit_err", enable => "E_en"},
          {out => ["E_rf_b_one_bit_err", 1], in => "D_rf_b_one_bit_err", enable => "E_en"},
          {out => ["E_rf_a_two_bit_err", 1], in => "D_rf_a_two_bit_err", enable => "E_en"},
          {out => ["E_rf_b_two_bit_err", 1], in => "D_rf_b_two_bit_err", enable => "E_en"},




          {out => ["M_rf_raw_recoverable_ecc_err", 1], 
           in => "E_rf_a_raw_recoverable_ecc_err | E_rf_b_raw_recoverable_ecc_err",
           enable => "M_en"},




          {out => ["M_rf_raw_unrecoverable_ecc_err", 1], 
           in => "E_rf_a_raw_unrecoverable_ecc_err | E_rf_b_raw_unrecoverable_ecc_err",
           enable => "M_en"},
          {out => ["A_rf_raw_unrecoverable_ecc_err", 1], 
           in => "M_rf_raw_unrecoverable_ecc_err", enable => "A_en"},


          {out => ["E_rf_a_corrected_data", $datapath_sz], 
           in => "D_rf_a_corrected_data", 
           enable => "E_en"},
          {out => ["E_rf_b_corrected_data", $datapath_sz], 
           in => "D_rf_b_corrected_data", 
           enable => "E_en"},
          {out => ["M_rf_corrected_data", $datapath_sz], 
           in => "E_rf_a_raw_recoverable_ecc_err ? E_rf_a_corrected_data : E_rf_b_corrected_data",
           enable => "M_en"},
          {out => ["A_rf_corrected_data", $datapath_sz], 
           in => "M_rf_corrected_data",
           enable => "A_en"},




          {out => ["A_rf_valid_recoverable_ecc_err", 1], 
           in => "M_rf_raw_recoverable_ecc_err & M_valid_ignoring_refetch & W_config_reg_eccen",
           enable => "A_en"},


          {out => ["A_rf_ecc_event_recoverable_err", 1], 
           in => "M_rf_raw_recoverable_ecc_err & M_valid_ignoring_refetch",
           enable => "A_en"},

        );

        if ($ecc_test_ports_present) {
            e_register->adds(
              {out => ["ecc_test_rf_valid_d1", 1],    in => "ecc_test_rf_valid & rf_wr_port_en",
               enable => "1'b1"},
            );
            e_assign->adds(
              [["ecc_test_rf_ready", 1], "~ecc_test_rf_valid | ecc_test_rf_valid_d1"],
            );
        }
    }













    e_assign->adds(
      [["${ds}_iw_${fa}_rf", $rf_addr_sz], 
        "D_en ? ${ds}_ram_iw_${fa} : D_iw_${fa}"],
      [["${ds}_iw_${fb}_rf", $rf_addr_sz], 
        "D_en ? ${ds}_ram_iw_${fb} : D_iw_${fb}"],
    );

    if ($shadow_present) {
        e_assign->adds(




          [["${ds}_regset_rf", $rf_set_sz], 
            "(D_ctrl_rdprs & D_stall) ? $prs : $crs"],
        );
    }

    e_assign->adds(
      [["${ds}_rf_rd_addr_a", $rf_total_addr_sz], 
        $shadow_present ?  "{ ${ds}_regset_rf, ${ds}_iw_${fa}_rf }" : "${ds}_iw_${fa}_rf"],
      [["${ds}_rf_rd_addr_b", $rf_total_addr_sz], 
        $shadow_present ?  "{ ${ds}_regset_rf, ${ds}_iw_${fb}_rf }" : "${ds}_iw_${fb}_rf"],



      [["E_src1_corrupt", 1], 
        $rf_ecc_present ? 
          "(E_rf_a_raw_recoverable_ecc_err & W_config_reg_eccen) | 
           (E_rf_a_raw_unrecoverable_ecc_err & W_ecc_exc_enabled) | 
           E_iw_corrupt" : 
          $ecc_present ? "E_iw_corrupt" : 
          "0"],
      [["E_src2_corrupt", 1], 
        $rf_ecc_present ? 
          "(E_rf_b_raw_recoverable_ecc_err & W_config_reg_eccen) | 
           (E_rf_b_raw_unrecoverable_ecc_err & W_ecc_exc_enabled) |
           E_iw_corrupt" : 
          $ecc_present ? "E_iw_corrupt" : 
          "0"],
    );

    e_register->adds(

      {out => ["M_src1_corrupt", 1, 0, $force_never_export], 
       in => "E_src1_corrupt",                      enable => "M_en"},
      {out => ["M_src2_corrupt", 1, 0, $force_never_export], 
       in => "E_src2_corrupt",                      enable => "M_en"},
    );

    my @rf_wr_port_en_inputs = "A_wr_dst_reg";
    my @rf_wr_port_addr_mux_table;

    if ($rf_ecc_present) {


      push(@rf_wr_port_addr_mux_table,
        "A_rf_valid_recoverable_ecc_err" => "A_rf_rd_addr"
      );



      push(@rf_wr_port_en_inputs, "A_rf_valid_recoverable_ecc_err");
    }
    
    push (@rf_wr_port_addr_mux_table,
      "1'b1" => ($shadow_present ? "{ A_dst_regset, A_dst_regnum }" : "A_dst_regnum")
    );

    e_mux->adds({
      lhs => ["rf_wr_port_addr", $rf_total_addr_sz],
      type => "priority",
      table => \@rf_wr_port_addr_mux_table,
    });

    e_assign->adds(

      [["rf_a_rd_port_addr", $rf_total_addr_sz], "${ds}_rf_rd_addr_a"],
      [["rf_b_rd_port_addr", $rf_total_addr_sz], "${ds}_rf_rd_addr_b"],
      [["rf_wr_port_data", $datapath_sz], "A_wr_data_filtered"],
      [["rf_wr_port_en", 1], join("|", @rf_wr_port_en_inputs)],




      [["D_rf_a", $datapath_sz], "rf_a_rd_port_data"],
      [["D_rf_b", $datapath_sz], "rf_b_rd_port_data"],
    );

    my $rf_ram_a_fname = $Opt->{name} . "_rf_ram_a";


    if (manditory_bool($Opt, "use_designware")) {
        e_comment->add({
          comment => 
            "BCM58 part used to replace register bank a\n",
        });

        e_blind_instance->add({
          name                     => $Opt->{name} . "_register_bank_a",
          module                   => "DWC_n2p_bcm58",
          use_sim_models           => 1,
          in_port_map              => {
            addr_r   => "${ds}_rf_rd_addr_a",
            addr_w   => "A_rf_wr_addr",
            clk_r    => "clk",
            clk_w    => "clk",
            data_w   => "A_wr_data_filtered",
            en_r_n   => qq(1'b0),
            en_w_n   => "~A_wr_dst_reg",
            init_r_n => qq(1'b1),
            init_w_n => qq(1'b1),
            rst_r_n  => "reset_n",
            rst_w_n  => "reset_n"
          },
          out_port_map             => {
            data_r       => "D_rf_a",
            data_r_a     => ""
          },
          parameter_map            => {
            ADDR_WIDTH => $rf_total_addr_sz,
            WIDTH      => $datapath_sz,
            DEPTH      => ($rf_num_reg * $rf_num_set),
            MEM_MODE   => 2,
            RST_MODE   => 0,
          },
        });
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_register_bank_a",
          Opt                     => $Opt,
          data_width              => $datapath_sz,
          address_width           => $rf_total_addr_sz,
          num_words               => ($rf_num_reg * $rf_num_set),
          contents_file           => $rf_ram_a_fname,
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
          ram_block_type          => qq("$Opt->{register_file_ram_type}"),
          ecc_present             => $rf_ecc_present,
          provide_injected_data   => $rf_ecc_present,
          verification            => $ecc_test_ports_present,
          port_map                => $rf_a_port_map,
        });
    }

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    my $reg_initial_value = "deadbeef";

    if ($rf_ecc_present) {
        $reg_initial_value = "7f" . $reg_initial_value;
    }

    make_contents_file_for_ram({
      filename_no_suffix        => $rf_ram_a_fname,
      data_sz                   => $datapath_sz,
      ecc_present               => $rf_ecc_present,
      num_entries               => ($rf_num_reg * $rf_num_set), 
      value_str                 => $reg_initial_value,
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });

    my $rf_ram_b_fname = $Opt->{name} . "_rf_ram_b";


    if (manditory_bool($Opt, "use_designware")) {
        e_comment->add({
          comment => 
            "BCM58 part used to replace register bank b\n",
        });

        e_blind_instance->add({
          name                     => $Opt->{name} . "_register_bank_b",
          module                   => "DWC_n2p_bcm58",
          use_sim_models           => 1, 
          in_port_map              => {
            addr_r   => "${ds}_rf_rd_addr_b",
            addr_w   => "A_rf_wr_addr",
            clk_r    => "clk",
            clk_w    => "clk",
            data_w   => "A_wr_data_filtered",
            en_r_n   => qq(1'b0),
            en_w_n   => "~A_wr_dst_reg",
            init_r_n => qq(1'b1),
            init_w_n => qq(1'b1),
            rst_r_n  => "reset_n",
            rst_w_n  => "reset_n"
          },
          out_port_map             => {
            data_r       => "D_rf_b",
            data_r_a     => ""
          },
          parameter_map            => {
            ADDR_WIDTH => $rf_total_addr_sz,
            WIDTH      => $datapath_sz,
            DEPTH      => ($rf_num_reg * $rf_num_set),
            MEM_MODE   => 2,
            RST_MODE   => 0
          },
        });
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_register_bank_b",
          Opt                     => $Opt,
          data_width              => $datapath_sz,
          address_width           => $rf_total_addr_sz,
          num_words               => ($rf_num_reg * $rf_num_set),
          contents_file           => $rf_ram_b_fname,
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
          ram_block_type          => qq("$Opt->{register_file_ram_type}"),
          ecc_present             => $rf_ecc_present,
          verification            => $ecc_test_ports_present,
          port_map                => $rf_b_port_map,
        });
    }

    make_contents_file_for_ram({
      filename_no_suffix        => $rf_ram_b_fname,
      data_sz                   => $datapath_sz,
      ecc_present               => $rf_ecc_present,
      num_entries               => ($rf_num_reg * $rf_num_set), 
      value_str                 => $reg_initial_value,
      clear_hdl_sim_contents    => 0,
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });

    my @src_operands = (
        { divider => "register_file" },
        { radix => "x", signal => "${ds}_iw_${fa}_rf" },
        { radix => "x", signal => "${ds}_iw_${fb}_rf" },
        $shadow_present ? { radix => "x", signal => "${ds}_regset_rf" } : "",
        $shadow_present ? { radix => "x", signal => "D_ctrl_rdprs" } : "",
        $shadow_present ? { radix => "x", signal => $crs } : "",
        $shadow_present ? { radix => "x", signal => $prs } : "",
        { radix => "x", signal => "D_rf_a" },
        { radix => "x", signal => "D_rf_b" },
        { radix => "x", signal => "A_wr_dst_reg" },
        { radix => "x", signal => "A_dst_regnum" },
        $shadow_present ? { radix => "x", signal => "A_dst_regset" } : "",
        { radix => "x", signal => "A_wr_data_unfiltered" },
        { radix => "x", signal => "A_wr_data_filtered" },
        { radix => "x", signal => "W_wr_data" },
        @ecc_waves,
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @src_operands);
    }
}









sub 
gen_data_master
{
    my $Opt = shift;

    my $data_master_interrupt_sz = 
      manditory_int($Opt, "data_master_interrupt_sz");




    $Opt->{data_master}{port_map} = {
      clk             => "clk",
      reset_n         => "reset_n",
      d_readdata      => "readdata",
      d_waitrequest   => "waitrequest",
      d_writedata     => "writedata",
      d_address       => "address",
      d_byteenable    => "byteenable",
      d_read          => "read",
      d_write         => "write",

      jtag_debug_module_debugaccess_to_roms  => "debugaccess",
    };

    if (!$eic_present) {
      $Opt->{data_master}{port_map}{d_irq} = "irq";
    }

    if ($wide_dcache_present) {

        $Opt->{data_master}{port_map}{d_readdatavalid} = "readdatavalid";
    }

    if ($dmaster_bursts) {
        $Opt->{data_master}{port_map}{d_burstcount} = "burstcount";
    }

    my $data_master_addr_sz = $Opt->{data_master}{Address_Width};

    push(@{$Opt->{port_list}},
      [clk              => 1,                           "in" ],
      [reset_n          => 1,                           "in" ],
      [d_readdata       => $datapath_sz,                "in" ],
      [d_waitrequest    => 1,                           "in" ],
      [d_address        => $data_master_addr_sz,        "out"],
      [d_byteenable     => $byte_en_sz,                 "out"],
      [d_read           => 1,                           "out"],
      [d_write          => 1,                           "out"],
      [d_writedata      => $datapath_sz,                "out"],
    );

    if (!$eic_present) {
        push(@{$Opt->{port_list}},
          [d_irq            => $data_master_interrupt_sz,   "in" ],
        );
    }

    if ($wide_dcache_present) {
        push(@{$Opt->{port_list}},
          [d_readdatavalid  => 1,                 "in" ],
        );
    }

    if ($dmaster_bursts) {
        push(@{$Opt->{port_list}},
          [d_burstcount     => $dmaster_burstcount_sz,  "out"],
        );
    }

    e_register->adds(

      {out => ["d_readdata_d1", $datapath_sz],      in => "d_readdata",
       enable => "1'b1"},


      {out => ["d_write", 1],                       in => "d_write_nxt",    
       enable => "1'b1"},
      {out => ["d_read", 1],                        in => "d_read_nxt",    
       enable => "1'b1"},
    );

    if ($wide_dcache_present) {
        e_register->adds(

          {out => ["d_readdatavalid_d1", 1],            in => "d_readdatavalid",
           enable => "1'b1"},
        );
    }

    if (!$dcache_present) {








        if ($mmu_present) {
            e_assign->adds(
              [["d_address", $data_master_addr_sz],
                "A_mem_baddr_phy[$data_master_addr_sz-1:0]"],
            );
        } else {
            e_assign->adds(
              [["d_address", $data_master_addr_sz],
                "A_mem_baddr[$data_master_addr_sz-1:0]"],
            );
        }

        my $E_dtcm_stall_expr = 
            ($advanced_exc && $dtcm_present) ?
              "| E_dtcm_M_st_caused_wrong_readdata" :
              "";
        my $M_dtcm_stall_expr = 
            ($advanced_exc && $dtcm_present) ?
              "| M_dtcm_A_st_caused_wrong_readdata" :
              "";

        e_assign->adds(

          [["av_start_rd", 1], 
            "M_ctrl_ld & M_valid & M_sel_data_master & A_en"],
    


          [["d_read_nxt", 1], "av_start_rd | (d_read & d_waitrequest)"],
    

          [["av_start_wr", 1], "M_valid_st_writes_mem & M_sel_data_master & A_en"],
    


          [["d_write_nxt", 1], "av_start_wr | (d_write & d_waitrequest)"],


          [["d_writedata", $datapath_sz], "A_st_data"],
          [["d_byteenable", $byte_en_sz], "A_mem_byte_en"],




          [["A_mem_stall_start_nxt", 1], 
            "A_en & ((M_ctrl_ld_st & M_valid & M_sel_data_master) 
                     $E_dtcm_stall_expr)"],
    


          [["A_st_done", 1], "~d_waitrequest"],



          [["av_rd_data_transfer", 1], "d_read & ~d_waitrequest"],





          [["A_ld_done", 1], 
            "A_ctrl_ld32 ? av_rd_data_transfer : av_ld_aligning_data"],


          [["A_mem_stall_stop_nxt", 1], 
            "(A_ctrl_st ? A_st_done : A_ld_done) $M_dtcm_stall_expr"],



          [["A_mem_stall_nxt", 1], 
            "A_mem_stall ? ~A_mem_stall_stop_nxt : A_mem_stall_start_nxt"],
        );

        e_register->adds(
          {out => ["A_mem_stall", 1],              
           in => "A_mem_stall_nxt",                 enable => "1'b1"},



          {out => ["av_ld_aligning_data", 1], in => "av_rd_data_transfer",
           enable => "1'b1"},
        );



        $perf_cnt_inc_rd_stall = "(d_read & A_mem_stall)";
        $perf_cnt_inc_wr_stall = "(d_write & A_mem_stall)";
   }

    my @data_master = (
        { divider => "data_master" },
        { radix => "x", signal => "d_address" },
        { radix => "x", signal => "d_read_nxt" },
        { radix => "x", signal => "d_read" },
        $wide_dcache_present ? { radix => "x", signal => "d_readdatavalid_d1" }
           : "",
        { radix => "x", signal => "d_readdata_d1" },
        { radix => "x", signal => "d_write_nxt" },
        { radix => "x", signal => "d_write" },
        { radix => "x", signal => "d_writedata" },
        { radix => "x", signal => "d_waitrequest" },
        { radix => "x", signal => "d_byteenable" },
        $dmaster_bursts ? { radix => "x", signal => "d_burstcount" } : "",
        { radix => "x", signal => "A_mem_stall" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @data_master);
    }
}





sub 
gen_data_tcm_masters
{
    my $Opt = shift;

    my @data_tcm_hazards;
    my @data_tcm_hazards_wave_signals;

    for (my $cmi = 0; 
      $cmi < manditory_int($Opt, "num_tightly_coupled_data_masters"); $cmi++) {
        gen_one_data_tcm_master($Opt, $cmi);

        if ($advanced_exc) {
            push(@data_tcm_hazards, 
              "E_dtcm${cmi}_M_st_caused_wrong_readdata");
            push(@data_tcm_hazards_wave_signals, 
              { radix => "x", 
                signal => "E_dtcm${cmi}_M_st_caused_wrong_readdata"} );
        }
    }

    if ($advanced_exc) {

        e_assign->adds(
          ["E_dtcm_M_st_caused_wrong_readdata", join('|', @data_tcm_hazards)],
        );





        e_register->adds(
          {out => ["M_dtcm_A_st_caused_wrong_readdata", 1],        
           in => "E_dtcm_M_st_caused_wrong_readdata & M_en",
           enable => "1'b1"},
        );


        if (!$data_master_present) {

            e_assign->adds(
              [["A_mem_stall", 1], "M_dtcm_A_st_caused_wrong_readdata"],
            );
        }

        if ($Opt->{full_waveform_signals}) {
            push(@plaintext_wave_signals, 
              { divider => "Data TCM Stall" },
              { radix => "x", 
                signal => "E_dtcm_M_st_caused_wrong_readdata"},
              { radix => "x", 
                signal => "M_dtcm_A_st_caused_wrong_readdata"},
              $data_master_present ? 
                "" :
                { radix => "x", signal => "A_mem_stall"},
              @data_tcm_hazards_wave_signals);
        }
    }
}

sub 
gen_one_data_tcm_master
{
    my $Opt = shift;
    my $cmi = shift;

    my $master_name = "tightly_coupled_data_master_${cmi}";
    my $slave_addr_width = $Opt->{$master_name}{Slave_Address_Width};
    my $avalon_addr_width = $Opt->{$master_name}{Address_Width};

    my %port_map = (
      "dcm${cmi}_readdata"       => "readdata",
      "dcm${cmi}_waitrequest"    => "waitrequest",
      "dcm${cmi}_readdatavalid"  => "readdatavalid",
      "dcm${cmi}_address"        => "address",
      "dcm${cmi}_read"           => "read",
      "dcm${cmi}_write"          => "write",
      "dcm${cmi}_clken"          => "clken",
      "dcm${cmi}_writedata"      => "writedata",
    );
    
    my @port_list = (
      ["dcm${cmi}_readdata"      => $datapath_sz,            "in" ],
      ["dcm${cmi}_waitrequest"   => 1,                       "in" ],
      ["dcm${cmi}_readdatavalid" => 1,                       "in" ],
      ["dcm${cmi}_address"       => $avalon_addr_width,      "out"],
      ["dcm${cmi}_read"          => 1,                       "out"],
      ["dcm${cmi}_write"         => 1,                       "out"],
      ["dcm${cmi}_clken"         => 1,                       "out"],
      ["dcm${cmi}_writedata"     => $datapath_sz,            "out"],
    );

    if (!$ecc_present) {
        $port_map{"dcm${cmi}_byteenable"} = "byteenable";
        push(@port_list, 
          ["dcm${cmi}_byteenable"    => $byte_en_sz,             "out"],
        );
    }

















    my $E_addr_expr;
    my $M_addr_expr;

    if ($slave_addr_width < $avalon_addr_width) {


        my $top_bits = 
          not_empty_scalar($Opt->{$master_name}, "Paddr_Base_Top_Bits");

        $E_addr_expr = "{ $top_bits, E_mem_baddr[$slave_addr_width-1:0] }";
        $M_addr_expr = "{ $top_bits, M_mem_baddr[$slave_addr_width-1:0] }";
    } else {
        $E_addr_expr = "E_mem_baddr[$avalon_addr_width-1:0]";
        $M_addr_expr = "M_mem_baddr[$avalon_addr_width-1:0]";
    }

    if ($advanced_exc) {
















        my $wr_expr = "M_valid_st_writes_mem & M_sel_${master_name}";



        my $affected_mem_expr;

        if ($ecc_present) {





























            $wr_expr .= 
              "& ~(M_ctrl_st_non32 & M_dtcm_A_st_caused_wrong_readdata)";

            $affected_mem_expr = "(E_ctrl_ld | E_ctrl_st_non32)";

            my $readdata = "dcm${cmi}_readdata";

            e_assign->adds(



              ["dcm${cmi}_writedata", "{ 
                 M_mem_byte_en[3] ? M_st_data[31:24] : ${readdata}\[31:24\],
                 M_mem_byte_en[2] ? M_st_data[23:16] : ${readdata}\[23:16\],
                 M_mem_byte_en[1] ? M_st_data[15:8]  : ${readdata}\[15:8\],
                 M_mem_byte_en[0] ? M_st_data[7:0]   : ${readdata}\[7:0\]
                }"],
            );
        } else {
            $affected_mem_expr = "E_ctrl_ld";

            e_assign->adds(
              ["dcm${cmi}_writedata", "M_st_data"],
              ["dcm${cmi}_byteenable", 
                "dcm${cmi}_sel_M ? M_mem_byte_en : E_mem_byte_en"],
            );
        }

        e_assign->adds(






          ["dcm${cmi}_sel_M", 
            "(M_valid_st_writes_mem & M_sel_${master_name}) |
              M_dtcm_A_st_caused_wrong_readdata"],

          ["dcm${cmi}_address", 
            "dcm${cmi}_sel_M ? $M_addr_expr : $E_addr_expr"],
          ["dcm${cmi}_write", $wr_expr],
          ["dcm${cmi}_read", "1'b1"],



          ["dcm${cmi}_clken", "M_en | M_dtcm_A_st_caused_wrong_readdata"],







          ["E_dtcm${cmi}_M_st_caused_wrong_readdata",
            "M_valid_st_writes_mem & M_sel_${master_name} &
             $affected_mem_expr & E_valid & E_sel_${master_name}"],
        );
    } else {


        e_assign->adds(
          ["dcm${cmi}_address", $E_addr_expr],
          ["dcm${cmi}_byteenable", "E_mem_byte_en"],
          ["dcm${cmi}_write", "E_ctrl_st & E_valid & E_sel_${master_name}"],
          ["dcm${cmi}_read", "1'b1"],
          ["dcm${cmi}_writedata", "E_st_data"],
          ["dcm${cmi}_clken", "M_en"],
        );
    }

    $Opt->{$master_name}{port_map} = \%port_map;
    $Opt->{$master_name}{sideband_signals} = [ "clken" ];
    push(@{$Opt->{port_list}}, @port_list);
}






sub 
gen_slow_ld_aligner
{
    my $Opt = shift;


    my $be8 = manditory_bool($Opt, "be8");
      e_assign->adds(
        [["A_slow_ld_data_unaligned",32], "d_readdata_d1"],
      );


    e_assign->adds(



      [["A_slow_ld_data_sign_bit_16", 2], 
        "${big_endian_tilde}A_mem_baddr[1]  ? 
          {A_slow_ld_data_unaligned[31], A_slow_ld_data_unaligned[23]} : 
          {A_slow_ld_data_unaligned[15], A_slow_ld_data_unaligned[7]}"],


      [["A_slow_ld_data_fill_bit", 1], 
        "A_slow_ld_data_sign_bit & A_ctrl_ld_signed"],
    );







    if ($be8 == 1) {
      e_assign->adds(


        [["A_slow_ld_data_sign_bit", 1],
          "((~A_mem_baddr[0]) | A_ctrl_ld16) ? 
              A_slow_ld_data_sign_bit_16[0] : A_slow_ld_data_sign_bit_16[1]"],

        [["A_slow_ld16_data", 16], "(A_ld_align_sh16 | A_ctrl_ld32) ? 
          A_slow_ld_data_unaligned[31:16] :
          A_slow_ld_data_unaligned[15:0]"],
  
        [["A_slow_ld_byte0_data_aligned_nxt", 8], "(A_ctrl_ld8 & ~A_mem_baddr[0]) ? 
          A_slow_ld16_data[7:0] :
          A_slow_ld16_data[15:8]"],

        [["A_slow_ld_byte1_data_aligned_nxt", 8], "A_ld_align_byte1_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld16_data[7:0]"],

        [["A_slow_ld_byte2_data_aligned_nxt", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld_data_unaligned[15:8]"],

        [["A_slow_ld_byte3_data_aligned_nxt", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld_data_unaligned[7:0]"],
      );
    } else {
      e_assign->adds(


        [["A_slow_ld_data_sign_bit", 1],
          "((${big_endian_tilde}A_mem_baddr[0]) | A_ctrl_ld16) ? 
              A_slow_ld_data_sign_bit_16[1] : A_slow_ld_data_sign_bit_16[0]"],

        [["A_slow_ld16_data", 16], "A_ld_align_sh16 ? 
          A_slow_ld_data_unaligned[31:16] :
          A_slow_ld_data_unaligned[15:0]"],

        [["A_slow_ld_byte0_data_aligned_nxt", 8], "A_ld_align_sh8 ? 
          A_slow_ld16_data[15:8] :
          A_slow_ld16_data[7:0]"],

        [["A_slow_ld_byte1_data_aligned_nxt", 8], "A_ld_align_byte1_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld16_data[15:8]"],

        [["A_slow_ld_byte2_data_aligned_nxt", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld_data_unaligned[23:16]"],

        [["A_slow_ld_byte3_data_aligned_nxt", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_slow_ld_data_fill_bit}} : 
          A_slow_ld_data_unaligned[31:24]"],
      );
    }

      e_assign->adds(
        [["A_slow_ld_data_aligned_nxt", $datapath_sz],
          "{A_slow_ld_byte3_data_aligned_nxt, A_slow_ld_byte2_data_aligned_nxt, 
            A_slow_ld_byte1_data_aligned_nxt, A_slow_ld_byte0_data_aligned_nxt}"],
      );


    my @slow_ld_aligner = (
      { divider => "A_slow_ld_aligner" },
      { radix => "x", signal => "A_slow_ld_data_unaligned"},
      { radix => "x", signal => "A_slow_ld_data_sign_bit" },
      { radix => "x", signal => "A_slow_ld_data_fill_bit" },
      { radix => "x", signal => "A_slow_ld16_data" },
      { radix => "x", signal => "A_slow_ld_byte0_data_aligned_nxt" },
      { radix => "x", signal => "A_slow_ld_byte1_data_aligned_nxt" },
      { radix => "x", signal => "A_slow_ld_byte2_data_aligned_nxt" },
      { radix => "x", signal => "A_slow_ld_byte3_data_aligned_nxt" },
      { radix => "x", signal => "A_slow_ld_data_aligned_nxt" },
      { radix => "x", signal => "A_slow_inst_result" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @slow_ld_aligner);
    }
}






sub 
gen_data_ram_ld_aligner
{
    my $Opt = shift;



















    my $be8 = manditory_bool($Opt, "be8");
    if ($be8 == 1) {
      e_register->adds(



        {out => ["M_data_ram_ld_align_sign_bit_16_hi", 1],        
        in => "(~E_mem_baddr[0]) | E_ctrl_ld16", 
        enable => "M_en"},
      );
    } else {
      e_register->adds(



        {out => ["M_data_ram_ld_align_sign_bit_16_hi", 1],
        in => "(${big_endian_tilde}E_mem_baddr[0]) | E_ctrl_ld16",
        enable => "M_en"},
      );
    }





    e_assign->adds(

      [["M_data_ram_ld_align_sign_bit_16", 2],
        "${big_endian_tilde}M_mem_baddr[1] ? 
          {M_ram_rd_data[31], M_ram_rd_data[23]} : 
          {M_ram_rd_data[15], M_ram_rd_data[7]}"],
    );

    if ($be8 == 1) {
      e_assign->adds(

        [["M_data_ram_ld_align_sign_bit", 1], 
          "M_data_ram_ld_align_sign_bit_16_hi ?
            M_data_ram_ld_align_sign_bit_16[0] : 
            M_data_ram_ld_align_sign_bit_16[1]"],
      );
    } else {
      e_assign->adds(

        [["M_data_ram_ld_align_sign_bit", 1], 
          "M_data_ram_ld_align_sign_bit_16_hi ?
            M_data_ram_ld_align_sign_bit_16[1] : 
            M_data_ram_ld_align_sign_bit_16[0]"],
      );
    }

    if ($wide_dcache_present) {


        e_assign->adds(

          [["A_data_ram_ld_align_fill_bit", 1], 
            "A_data_ram_ld_align_sign_bit & A_ctrl_ld_signed"],
        );


        e_register->adds(
          {out => ["A_data_ram_ld_align_sign_bit", 1],        
           in => "M_data_ram_ld_align_sign_bit", enable => "A_en"},
        );
    } else {


        e_assign->adds(

          [["M_data_ram_ld_align_fill_bit", 1], 
            "M_data_ram_ld_align_sign_bit & M_ctrl_ld_signed"],
        );


        e_register->adds(
          {out => ["A_data_ram_ld_align_fill_bit", 1],        
           in => "M_data_ram_ld_align_fill_bit", enable => "A_en"},
        );
    }
















    if ($be8 ==1) {
      e_assign->adds(
        [["A_data_ram_ld16_data", 16], "(A_ld_align_sh16 | A_ctrl_ld32) ? 
          A_inst_result[31:16] :
          A_inst_result[15:0]"],

        [["A_data_ram_ld32_data", 16], " A_ctrl_ld32 ? 
          {A_inst_result[7:0],A_inst_result[15:8]} :
          A_inst_result[31:16]"],

        [["A_data_ram_ld_byte0_data", 8], "((A_ctrl_ld8 & ~A_mem_baddr[0]) | ~A_ctrl_ld) ? 
          A_data_ram_ld16_data[7:0] :
          A_data_ram_ld16_data[15:8]"],

        [["A_data_ram_ld_byte1_data", 8], "A_ld_align_byte1_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : ~A_ctrl_ld ?
          A_data_ram_ld16_data[15:8] : A_data_ram_ld16_data[7:0]"],

        [["A_data_ram_ld_byte2_data", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : 
          A_data_ram_ld32_data[7:0]"],

        [["A_data_ram_ld_byte3_data", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : 
          A_data_ram_ld32_data[15:8]"],
      );
    } else {
      e_assign->adds(
        [["A_data_ram_ld16_data", 16], "A_ld_align_sh16 ? 
          A_inst_result[31:16] :
          A_inst_result[15:0]"],
        
        [["A_data_ram_ld_byte0_data", 8], "A_ld_align_sh8 ? 
          A_data_ram_ld16_data[15:8] :
          A_data_ram_ld16_data[7:0]"],

        [["A_data_ram_ld_byte1_data", 8], "A_ld_align_byte1_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : 
          A_data_ram_ld16_data[15:8]"],

        [["A_data_ram_ld_byte2_data", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : 
          A_inst_result[23:16]"],

        [["A_data_ram_ld_byte3_data", 8], "A_ld_align_byte2_byte3_fill ? 
          {8 {A_data_ram_ld_align_fill_bit}} : 
          A_inst_result[31:24]"],
      );
    }



    e_assign->adds(
      [["A_inst_result_aligned", $datapath_sz], 
        "{A_data_ram_ld_byte3_data, A_data_ram_ld_byte2_data, 
          A_data_ram_ld_byte1_data, A_data_ram_ld_byte0_data}"],
      );

    my @wave_signals = (
      { divider => "data_ram_ld_aligner" },
      { radix => "x", signal => "M_ctrl_ld16" },
      { radix => "x", signal => "M_mem_baddr\\[1\\]" },
      { radix => "x", signal => "M_mem_baddr\\[0\\]" },
      { radix => "x", signal => "M_data_ram_ld_align_sign_bit" },
      { radix => "x", signal => "A_data_ram_ld_align_fill_bit" },
      { radix => "x", signal => "A_data_ram_ld_byte0_data" },
      { radix => "x", signal => "A_data_ram_ld_byte1_data" },
      { radix => "x", signal => "A_data_ram_ld_byte2_data" },
      { radix => "x", signal => "A_data_ram_ld_byte3_data" },
      { radix => "x", signal => "A_inst_result_aligned" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @wave_signals);
    }
}

1;
