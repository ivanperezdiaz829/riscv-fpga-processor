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






















package nios_wide_dcache;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
);

use europa_all;
use europa_utils;
use cpu_utils;
use cpu_wave_signals;
use cpu_file_utils;
use cpu_gen;
use cpu_bit_field;
use nios_sdp_ram;
use nios_utils;
use nios_avalon_masters;
use nios_common;
use nios_isa;
use strict;



















sub 
gen_dcache
{
    my $Opt = shift;

    if (!$data_master_present) {
        &$error("Data cache requires Avalon data_master to be present");
    }

    my $whoami = "wide data cache";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    my @dc_ecc_waves;
    if ($dc_ecc_present) {
        push(@dc_ecc_waves, { divider => "dcache_ecc" });
    }

    my $mmu_addr_pfn_lsb;
    if ($tlb_present) {
        $mmu_addr_pfn_lsb = manditory_int($Opt, "mmu_addr_pfn_lsb");
    }

    my $cache_dcache_victim_buf_impl = 
      not_empty_scalar($Opt, "cache_dcache_victim_buf_impl");
    my $victim_buf_ram;  # boolean
    my $victim_buf_reg;  # boolean

    if ($cache_dcache_victim_buf_impl eq "ram") {
        $victim_buf_ram = 1;
    } elsif ($cache_dcache_victim_buf_impl eq "reg") {
        $victim_buf_reg = 1;
    } else {
        &$error("Unrecognize value for cache_dcache_victim_buf_impl of '" .
          $cache_dcache_victim_buf_impl . "'");
    }















    my $dc_bytes_per_line = manditory_int($Opt, "cache_dcache_line_size");
    if ($dc_bytes_per_line < 8) {
        &$error("Number of D-Cache bytes per line must be 8 or more but is " .
           $dc_bytes_per_line . "\n");
    }

    my $dc_total_bytes = manditory_int($Opt, "cache_dcache_size");
    my $data_master_addr_sz = 
      manditory_int($Opt->{data_master}, "Address_Width");


    my $dc_words_per_line = $dc_bytes_per_line >> 2;
    my $dc_num_lines = $dc_total_bytes / $dc_bytes_per_line;




    my $line_word_cnt_max = $dc_words_per_line;
    my $line_word_cnt_sz = num2sz($line_word_cnt_max);




    my $dc_addr_byte_field_sz = 2;
    my $dc_addr_byte_field_lsb = 0;
    my $dc_addr_byte_field_msb = $dc_addr_byte_field_lsb + 
      $dc_addr_byte_field_sz - 1;

    my $dc_addr_offset_field_sz = count2sz($dc_words_per_line);
    my $dc_addr_offset_field_lsb = $dc_addr_byte_field_msb + 1;
    my $dc_addr_offset_field_msb = $dc_addr_offset_field_lsb + 
      $dc_addr_offset_field_sz - 1;

    my $dc_max_addr_offset = (1 << $dc_addr_offset_field_sz) - 1;

    my $dc_addr_line_field_sz = count2sz($dc_num_lines);
    my $dc_addr_line_field_lsb = $dc_addr_offset_field_msb + 1;
    my $dc_addr_line_field_msb = $dc_addr_line_field_lsb + 
      $dc_addr_line_field_sz - 1;


    my $dc_addr_line_offset_field_sz = 
      $dc_addr_line_field_sz + $dc_addr_offset_field_sz;





    my $dc_addr_line_field_paddr_sz = $dc_addr_line_field_sz;
    my $dc_addr_line_field_paddr_lsb = $dc_addr_line_field_lsb;
    my $dc_addr_line_field_paddr_msb = $dc_addr_line_field_msb;

    my $dc_addr_tag_field_msb = $data_master_addr_sz - 1;
    my $dc_addr_tag_field_lsb = $dc_addr_line_field_msb + 1;
    if ($tlb_present && ($dc_addr_tag_field_lsb > $mmu_addr_pfn_lsb)) {

        $dc_addr_tag_field_lsb = $mmu_addr_pfn_lsb;


        $dc_addr_line_field_paddr_msb = $mmu_addr_pfn_lsb - 1;
        $dc_addr_line_field_paddr_sz = 
          $dc_addr_line_field_paddr_msb - $dc_addr_line_field_paddr_lsb + 1;
    }
    my $dc_addr_tag_field_sz = 
      $dc_addr_tag_field_msb - $dc_addr_tag_field_lsb + 1;















    if ($dc_addr_tag_field_sz < 1) {
        &$error("D-cache is too large relative to data address size");
    }


    my $dc_tag_addr_sz = $dc_addr_line_field_sz;
    my $dc_tag_num_addrs = 0x1 << $dc_tag_addr_sz;




    my $dc_tag_entry_tag_sz = $dc_addr_tag_field_sz;
    my $dc_tag_entry_tag_lsb = 0;
    my $dc_tag_entry_tag_msb = $dc_tag_entry_tag_lsb + 
      $dc_tag_entry_tag_sz - 1;

    my $dc_tag_entry_valid_sz = 1;
    my $dc_tag_entry_valid_lsb = $dc_tag_entry_tag_msb + 1;
    my $dc_tag_entry_valid_msb = $dc_tag_entry_valid_lsb + 
      $dc_tag_entry_valid_sz - 1;

    my $dc_tag_entry_dirty_sz = 1;
    my $dc_tag_entry_dirty_lsb = $dc_tag_entry_valid_msb + 1;
    my $dc_tag_entry_dirty_msb = $dc_tag_entry_dirty_lsb + 
      $dc_tag_entry_dirty_sz - 1;


    my $dc_tag_data_sz = $dc_tag_entry_tag_sz + $dc_tag_entry_valid_sz +
      $dc_tag_entry_dirty_sz;


    my $dc_data_addr_sz = $dc_addr_line_offset_field_sz;
    my $dc_data_num_addrs = 0x1 << $dc_data_addr_sz;


    my $dc_data_data_sz = $datapath_sz;


    my $dcache_data_ram_block_type = not_empty_scalar($Opt, "cache_dcache_ram_block_type");
    my $dcache_tag_ram_block_type = not_empty_scalar($Opt, "cache_dcache_tag_ram_block_type");





    e_register->adds(

      {out => ["A_dc_rd_data", $dc_data_data_sz],
       in => "M_dc_rd_data",             enable => "A_en"},
      {out => ["A_dc_st_data", $dc_data_data_sz],
       in => "M_dc_st_data",             enable => "A_en"},
      {out => ["A_dc_actual_tag", $dc_addr_tag_field_sz], 
       in => "M_dc_actual_tag",             enable => "A_en"},
      {out => ["A_dc_hit", 1], 
       in => "M_dc_hit",                    enable => "A_en"},
      {out => ["A_dc_valid_st_cache_hit", 1],
       in => "M_dc_valid_st_cache_hit",     enable => "A_en"},
      {out => ["A_dc_valid_st_bypass_hit", 1],
       in => "M_dc_valid_st_bypass_hit",    enable => "A_en"},
      {out => ["A_dc_potential_hazard_after_st", 1],
       in => "M_dc_potential_hazard_after_st", enable => "A_en"},
      {out => ["A_valid_st_writes_mem", 1],
       in => "M_valid_st_writes_mem",       enable => "A_en"},
    );


    e_assign->adds(
      [["M_valid_st_cache", 1], "M_ctrl_st_non_bypass & M_valid & M_sel_data_master"],
      [["M_valid_ld_st_cache", 1], "M_ctrl_ld_st_non_bypass & M_valid & M_sel_data_master"],
    );






    e_assign->adds(
      [["E_mem_baddr_line_field", $dc_addr_line_field_sz, 0, 
        $force_never_export],
        "E_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],
      [["E_mem_baddr_offset_field", $dc_addr_offset_field_sz, 0,
        $force_never_export],
        "E_mem_baddr[$dc_addr_offset_field_msb:$dc_addr_offset_field_lsb]"],
      [["E_mem_baddr_line_offset_field", $dc_addr_line_offset_field_sz, 0,
        $force_never_export],
        "E_mem_baddr[$dc_addr_line_field_msb:$dc_addr_offset_field_lsb]"],
      [["E_mem_baddr_byte_field", $dc_addr_byte_field_sz, 0,
        $force_never_export],
        "E_mem_baddr[$dc_addr_byte_field_msb:$dc_addr_byte_field_lsb]"],

      [["M_mem_baddr_line_field", $dc_addr_line_field_sz, 0, 
        $force_never_export],
        "M_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],
      [["M_mem_baddr_offset_field", $dc_addr_offset_field_sz, 0,
        $force_never_export],
        "M_mem_baddr[$dc_addr_offset_field_msb:$dc_addr_offset_field_lsb]"],
      [["M_mem_baddr_line_offset_field", $dc_addr_line_offset_field_sz, 0,
        $force_never_export],
        "M_mem_baddr[$dc_addr_line_field_msb:$dc_addr_offset_field_lsb]"],
      [["M_mem_baddr_byte_field", $dc_addr_byte_field_sz, 0,
        $force_never_export],
        "M_mem_baddr[$dc_addr_byte_field_msb:$dc_addr_byte_field_lsb]"],

      [["A_mem_baddr_line_field", $dc_addr_line_field_sz, 0, 
        $force_never_export],
        "A_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],
      [["A_mem_baddr_offset_field", $dc_addr_offset_field_sz, 0,
        $force_never_export],
        "A_mem_baddr[$dc_addr_offset_field_msb:$dc_addr_offset_field_lsb]"],
      [["A_mem_baddr_line_offset_field", $dc_addr_line_offset_field_sz, 0,
        $force_never_export],
        "A_mem_baddr[$dc_addr_line_field_msb:$dc_addr_offset_field_lsb]"],
      [["A_mem_baddr_byte_field", $dc_addr_byte_field_sz, 0,
        $force_never_export],
        "A_mem_baddr[$dc_addr_byte_field_msb:$dc_addr_byte_field_lsb]"],
    );







    e_signal->adds(
      {name => "dc_tag_rd_port_data", width => $dc_tag_data_sz },
    );
    if ($dc_ecc_present) {
        e_signal->adds(
         {name => "dc_tag_rd_port_corrected_data", width => $dc_tag_data_sz },
         {name => "dc_tag_rd_port_one_bit_err", width => 1 },
         {name => "dc_tag_rd_port_two_bit_err", width => 1 },
         {name => "dc_tag_rd_port_any_ecc_err", width => 1 },
       );
    }

    e_assign->adds(




      [["M_dc_st_wr_en", 1], "M_valid_st_cache & A_en"],







      [["A_dc_tag_dcache_management_wr_en", 1], 
         "(A_ctrl_dc_index_inv | (A_ctrl_dc_addr_inv & A_dc_hit)) &
          A_valid & A_en_d1"],
    );













    my $dc_tag_wr_port_data_mux_table = [];
    my $dc_tag_wr_port_addr_mux_table = [];

    if ($dc_ecc_present) {

        push (@$dc_tag_wr_port_data_mux_table,
          "A_dc_valid_data_recoverable_flush_ecc_err" =>
            "{dc_line_dirty_off, dc_line_valid_off, A_dc_desired_tag}"
        );
    }
  
    push (@$dc_tag_wr_port_data_mux_table,
      "A_dc_fill_starting_d1" => 
        "{A_valid_st_writes_mem, dc_line_valid_on, A_dc_desired_tag}",
    );
    if (manditory_bool($Opt, "cache_dcache_allow_tag_wrt")) {

        e_assign->adds(
          [[" A_dc_dcache_management_valid",1],
            "A_op_dcache_hit_wb ? A_dc_valid : dc_line_valid_off"],
        );
        push (@$dc_tag_wr_port_data_mux_table,
          "A_dc_tag_dcache_management_wr_en" => 
            "{dc_line_dirty_off, A_dc_dcache_management_valid, A_dc_desired_tag}",
          "(A_op_dcache_st_tag & A_valid )" => 
           "{W_cop0_tag_lo_0_reg_d,
             W_cop0_tag_lo_0_reg_v,
             W_cop0_tag_lo_0_reg[$dc_addr_tag_field_msb:$dc_addr_tag_field_lsb]}",
        );
    } else {
        push (@$dc_tag_wr_port_data_mux_table,
          "A_dc_tag_dcache_management_wr_en" => 
            "{dc_line_dirty_off, dc_line_valid_off, A_dc_desired_tag}",
        );
    }
    push (@$dc_tag_wr_port_data_mux_table,
      "1'b1", => "{dc_line_dirty_on,  dc_line_valid_on,  M_dc_desired_tag}",
    );
    e_mux->adds({
      lhs => ["dc_tag_wr_port_data", $dc_tag_data_sz],
      type => "priority",
      table => $dc_tag_wr_port_data_mux_table,
    });

    if ($dc_ecc_present) {




      push (@$dc_tag_wr_port_addr_mux_table,
        "A_dc_valid_tag_recoverable_ecc_err | A_dc_valid_data_recoverable_flush_ecc_err" 
           => "A_mem_baddr_line_field",
      );
    }
    push (@$dc_tag_wr_port_addr_mux_table,
      "(A_dc_fill_starting_d1 | A_dc_tag_dcache_management_wr_en)" => 
        "A_mem_baddr_line_field",
    );
    if (manditory_bool($Opt, "cache_dcache_allow_tag_wrt")) {
      push (@$dc_tag_wr_port_addr_mux_table,
        "A_op_dcache_st_tag & A_valid" => "A_mem_baddr_line_field",
      );
    }
    push (@$dc_tag_wr_port_addr_mux_table,
      "1'b1" => "M_mem_baddr_line_field",
    );

    e_mux->adds({
      lhs => ["dc_tag_wr_port_addr", $dc_tag_addr_sz],
      type => "priority",
      table => $dc_tag_wr_port_addr_mux_table,
    });

    my @dc_tag_wr_port_en_inputs = ( 
      "A_dc_fill_starting_d1",
      "A_dc_tag_dcache_management_wr_en",
      "M_dc_st_wr_en"
    );


    if (manditory_bool($Opt, "cache_dcache_allow_tag_wrt")) {
      push(@dc_tag_wr_port_en_inputs, "(A_op_dcache_st_tag & A_valid)");
    }

    if ($dc_ecc_present) {


      push(@dc_tag_wr_port_en_inputs, 
        "A_dc_valid_tag_recoverable_ecc_err | A_dc_valid_data_recoverable_flush_ecc_err");
    }

    e_assign->adds(
      [["dc_tag_wr_port_en", 1],
          scalar(@dc_tag_wr_port_en_inputs) ? join("|",@dc_tag_wr_port_en_inputs) : "0"],


      [["dc_line_dirty_on", 1],  "1'b1"],
      [["dc_line_dirty_off", 1], "1'b0"],
      [["dc_line_valid_on", 1],  "1'b1"],
      [["dc_line_valid_off", 1], "1'b0"],
        

      [["M_dc_tag_entry", $dc_tag_data_sz], "dc_tag_rd_port_data"],


      [["M_dc_dirty_raw", 1], "M_dc_tag_entry[$dc_tag_entry_dirty_lsb]"],
      [["M_dc_valid", 1], "M_dc_tag_entry[$dc_tag_entry_valid_lsb]"],
      [["M_dc_actual_tag", $dc_addr_tag_field_sz], 
        "M_dc_tag_entry[$dc_tag_entry_tag_msb:$dc_tag_entry_tag_lsb]"],
    );

    my $dc_tag_port_map = {
      clock     => "clk",


      rdaddress => "dc_tag_rd_port_addr",
      q         => "dc_tag_rd_port_data",


      wren      => "dc_tag_wr_port_en",
      data      => "dc_tag_wr_port_data",
      wraddress => "dc_tag_wr_port_addr",
    };

    my @dc_tag_ram_ecc_waves;

    if ($dc_ecc_present) {

        $dc_tag_port_map->{corrected_data_to_encoder} = "dc_tag_wr_port_corrected_data";
        $dc_tag_port_map->{injs} = "dc_tag_wr_port_injs";
        $dc_tag_port_map->{injd} = "dc_tag_wr_port_injd";
        $dc_tag_port_map->{wrsel} = "dc_tag_wr_port_wrsel";
        if ($ecc_test_ports_present) {
            my $dc_tag_ecc_bits = calc_num_ecc_bits($dc_tag_data_sz);
            my $dc_tag_ecc_data_sz =  $dc_tag_data_sz + $dc_tag_ecc_bits;
            $dc_tag_port_map->{test_invert} = "ecc_test_dc_tag[$dc_tag_ecc_data_sz-1:0]";
        }


        $dc_tag_port_map->{corrected_data_from_decoder} = "dc_tag_rd_port_corrected_data";
        $dc_tag_port_map->{one_bit_err} = "dc_tag_rd_port_one_bit_err";
        $dc_tag_port_map->{two_bit_err} = "dc_tag_rd_port_two_bit_err";
        $dc_tag_port_map->{one_two_or_three_bit_err} = "dc_tag_rd_port_any_ecc_err";

        push(@dc_tag_ram_ecc_waves,
          { radix => "x", signal => "dc_tag_wr_port_corrected_data" },
          { radix => "x", signal => "dc_tag_wr_port_injs" },
          { radix => "x", signal => "dc_tag_wr_port_injd" },
          { radix => "x", signal => "dc_tag_wr_port_wrsel" },
          { radix => "x", signal => "dc_tag_rd_port_corrected_data" },
          { radix => "x", signal => "dc_tag_rd_port_one_bit_err" },
          { radix => "x", signal => "dc_tag_rd_port_two_bit_err" },
          { radix => "x", signal => "dc_tag_rd_port_any_ecc_err" },
        );

        push(@dc_ecc_waves,
            { radix => "x", signal => "W_dc_tag_injs" },
            { radix => "x", signal => "W_dc_tag_injd" },
            { radix => "x", signal => "M_dc_tag_raw_recoverable_ecc_err" },
            { radix => "x", signal => "M_dc_tag_raw_unrecoverable_ecc_err" },
            { radix => "x", signal => "M_dc_tag_raw_any_ecc_err" },
            { radix => "x", signal => "A_dc_valid_tag_recoverable_ecc_err" },
            { radix => "x", signal => "A_dc_valid_data_recoverable_correct_ecc_err" },
            { radix => "x", signal => "A_dc_valid_data_recoverable_flush_ecc_err" },
            { radix => "x", signal => "A_dc_tag_ecc_event_recoverable_err" },
            { radix => "x", signal => "A_dc_data_ecc_event_recoverable_err" },
        );

        e_assign->adds(

          [["dc_tag_wr_port_injs", 1], "W_dc_tag_injs"],
          [["dc_tag_wr_port_injd", 1], "W_dc_tag_injd"],





          [["M_dc_tag_raw_recoverable_ecc_err", 1], 
             "dc_tag_rd_port_one_bit_err & M_ctrl_mem_dc_tag_rd"],





          [["M_dc_tag_raw_unrecoverable_ecc_err", 1], 
             "dc_tag_rd_port_two_bit_err & M_ctrl_mem_dc_tag_rd"],




          [["M_dc_tag_raw_any_ecc_err", 1],
             "dc_tag_rd_port_any_ecc_err & M_ctrl_mem_dc_tag_rd"],



          [["dc_tag_wr_port_wrsel", 1], "A_dc_valid_tag_recoverable_ecc_err"],


          [["M_dc_tag_corrected_data", $dc_tag_data_sz], "dc_tag_rd_port_corrected_data"],
          [["dc_tag_wr_port_corrected_data", $dc_tag_data_sz], "A_dc_tag_corrected_data"],
        );

        e_register->adds(



          {out => ["A_dc_valid_tag_recoverable_ecc_err", 1], 
           in => "M_dc_tag_raw_recoverable_ecc_err & M_valid_ignoring_refetch & W_config_reg_eccen",
           enable => "A_en"},


          {out => ["A_dc_tag_ecc_event_recoverable_err", 1], 
           in => "M_dc_tag_raw_recoverable_ecc_err & M_valid_ignoring_refetch",
           enable => "A_en"},



          {out => ["A_dc_tag_raw_unrecoverable_ecc_err", 1], 
           in => "M_dc_tag_raw_unrecoverable_ecc_err", enable => "A_en"},


          {out => ["A_dc_tag_corrected_data", $dc_tag_data_sz], 
           in => "M_dc_tag_corrected_data", 
           enable => "A_en"},
        );

        if ($ecc_test_ports_present) {
            e_register->adds(
              {out => ["ecc_test_dc_tag_valid_d1", 1],    in => "ecc_test_dc_tag_valid & dc_tag_wr_port_en",
               enable => "1'b1"},
            );
            e_assign->adds(
              [["ecc_test_dc_tag_ready", 1], "~ecc_test_dc_tag_valid | ecc_test_dc_tag_valid_d1"],
           );
       }
    }










    e_assign->adds(
      [["dc_tag_rd_port_addr", $dc_tag_addr_sz], 
        "M_en                   ? E_mem_baddr_line_field : 
                                  M_mem_baddr_line_field"],
    );

    my $dc_tag_ram_fname = $Opt->{name} . "_dc_tag_ram";



   if (manditory_bool($Opt, "export_large_RAMs")) {
        e_comment->add({
          comment => 
            ("Export D cache tag RAM ports to top level\n" .
             "because the RAM is instantiated external to CPU.\n"),
        });

        e_assign->adds(

          [["dcache_g4b_tag_ram_write_data", $dc_tag_data_sz], 
            "dc_tag_wr_port_data"],
          ["dcache_g4b_tag_ram_write_enable", 
            "dc_tag_wr_port_en"],
          [["dcache_g4b_tag_ram_write_address", $dc_tag_addr_sz], 
            "dc_tag_wr_port_addr"],
          [["dcache_g4b_tag_ram_read_clk_en", 1], "1'b1"],
          [["dcache_g4b_tag_ram_read_address", $dc_tag_addr_sz], 
            "dc_tag_rd_port_addr"],


          ["dc_tag_rd_port_data", 
            ["dcache_g4b_tag_ram_read_data", $dc_tag_data_sz]],
        );
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_dc_tag",
          Opt                     => $Opt,
          data_width              => $dc_tag_data_sz,
          address_width           => $dc_tag_addr_sz,
          num_words               => $dc_tag_num_addrs,
          contents_file           => $dc_tag_ram_fname,
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
          ram_block_type          => '"' . $dcache_tag_ram_block_type . '"',
          ecc_present             => $dc_ecc_present,
          verification            => $ecc_test_ports_present,
          port_map                => $dc_tag_port_map,
        });
    }

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    make_contents_file_for_ram({
      filename_no_suffix        => $dc_tag_ram_fname,
      data_sz                   => $dc_tag_data_sz,
      ecc_present               => $dc_ecc_present,
      num_entries               => $dc_tag_num_addrs, 
      value_str                 => "random",
      clear_hdl_sim_contents    => 
        manditory_bool($Opt, "hdl_sim_caches_cleared"),
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });





    if ($mmu_present) {
        e_assign->adds(
          [["M_dc_desired_tag", $dc_addr_tag_field_sz],
            "M_mem_baddr_phy[$dc_addr_tag_field_msb:$dc_addr_tag_field_lsb]"],
        );      


        e_register->adds(
          {out => ["A_dc_desired_tag", $dc_addr_tag_field_sz], 
           in => "M_dc_desired_tag", enable => "A_en"},
        );
    } else {
        e_assign->adds(

          [["M_dc_desired_tag", $dc_addr_tag_field_sz],
            "M_mem_baddr[$dc_addr_tag_field_msb:$dc_addr_tag_field_lsb]"],
      

          [["A_dc_desired_tag", $dc_addr_tag_field_sz],
            "A_mem_baddr[$dc_addr_tag_field_msb:$dc_addr_tag_field_lsb]"],
        );
    }

    if ($tlb_present) {
        e_assign->adds(






          [["M_dc_tag_match", 1], 
            "(M_dc_desired_tag == M_dc_actual_tag) & M_mem_baddr_phy_got_pfn"],
        );      
    } else {
        e_assign->adds(

          [["M_dc_tag_match", 1], "M_dc_desired_tag == M_dc_actual_tag"],
        );
    }



    e_assign->adds(
      [["M_dc_hit", 1], "M_dc_tag_match & M_dc_valid"],






      [["M_dc_dirty", 1], 
        "M_dc_dirty_raw | (M_A_dc_line_match & A_dc_valid_st_cache_hit)"],
    );






    e_signal->adds(
      {name => "dc_data_rd_port_data", width => $dc_data_data_sz },
    );
    if ($dc_ecc_present) {
        e_signal->adds(
         {name => "dc_data_rd_port_corrected_data", width => $dc_data_data_sz },
         {name => "dc_data_rd_port_one_bit_err", width => 1 },
         {name => "dc_data_rd_port_two_bit_err", width => 1 },
         {name => "dc_data_rd_port_any_ecc_err", width => 1 },
       );
    }

    my $ecc_dc_data_wr_port_addr_expr;
    my $ecc_dc_data_wr_port_en_expr;

    if ($dc_ecc_present) {


        $ecc_dc_data_wr_port_addr_expr = 
          "A_dc_valid_data_recoverable_correct_ecc_err ? A_mem_baddr_line_offset_field :";
        $ecc_dc_data_wr_port_en_expr =
          "A_dc_valid_data_recoverable_correct_ecc_err | ";
    }

    e_assign->adds(








      [["dc_data_rd_port_line_field", $dc_addr_line_field_sz], 
        "M_en                     ? E_mem_baddr_line_field : 
         A_dc_xfer_rd_addr_active ? A_mem_baddr_line_field :
                                    M_mem_baddr_line_field"],









      [["dc_data_rd_port_offset_field", $dc_addr_offset_field_sz], 
        "M_en                      ? E_mem_baddr_offset_field : 
         A_dc_xfer_rd_addr_active  ? A_dc_xfer_rd_addr_offset :
                                     M_mem_baddr_offset_field"],
                                     

      [["dc_data_rd_port_addr", $dc_data_addr_sz], 
        "{dc_data_rd_port_line_field, dc_data_rd_port_offset_field}"],


      [["M_dc_rd_data", $dc_data_data_sz], "dc_data_rd_port_data"],





      [["A_dc_data_dcache_management_wr_en", 1], 
        $dc_ecc_present ? "A_ctrl_dc_index_nowb_inv & A_valid & A_en_d1" : "1'b0"],





      [["M_dc_st_data", $dc_data_data_sz], "{ 
         M_mem_byte_en[3] ? M_st_data[31:24] : M_dc_rd_data[31:24],
         M_mem_byte_en[2] ? M_st_data[23:16] : M_dc_rd_data[23:16],
         M_mem_byte_en[1] ? M_st_data[15:8]  : M_dc_rd_data[15:8],
         M_mem_byte_en[0] ? M_st_data[7:0]   : M_dc_rd_data[7:0]
        }"],








      [["dc_data_wr_port_data", $dc_data_data_sz], 
        "A_dc_fill_active                  ? A_dc_fill_wr_data : 
         A_dc_data_dcache_management_wr_en ? 32'b0 :
         A_dc_valid_st_bypass_hit_wr_en    ? A_dc_st_data :
                                             M_dc_st_data"],
      [["dc_data_wr_port_addr", $dc_data_addr_sz], 
        $ecc_dc_data_wr_port_addr_expr .
        "A_dc_fill_active                  ? { A_mem_baddr_line_field, A_dc_fill_dp_offset } : 
         A_dc_data_dcache_management_wr_en ? A_mem_baddr_line_offset_field :
         A_dc_valid_st_bypass_hit_wr_en    ? A_mem_baddr_line_offset_field :
                                             M_mem_baddr_line_offset_field"],
      [["dc_data_wr_port_en", 1], 
        $ecc_dc_data_wr_port_en_expr .
        "(A_dc_fill_active ? d_readdatavalid_d1 : M_dc_st_wr_en) |
         A_dc_valid_st_bypass_hit_wr_en | A_dc_data_dcache_management_wr_en"],
    );

    my $dc_data_port_map = {
        clock      => "clk",
    


        rdaddress  => "dc_data_rd_port_addr",
        q          => "dc_data_rd_port_data",
   


        wren       => "dc_data_wr_port_en",
        data       => "dc_data_wr_port_data",
        wraddress  => "dc_data_wr_port_addr",
    };

    my @dc_data_ram_ecc_waves;

    if ($dc_ecc_present) {

        $dc_data_port_map->{corrected_data_to_encoder} = "dc_data_wr_port_corrected_data";
        $dc_data_port_map->{injs} = "dc_data_wr_port_injs";
        $dc_data_port_map->{injd} = "dc_data_wr_port_injd";
        $dc_data_port_map->{wrsel} = "dc_data_wr_port_wrsel";
        if ($ecc_test_ports_present) {
            my $dc_data_ecc_bits = calc_num_ecc_bits($dc_data_data_sz);
            my $dc_data_ecc_data_sz =  $dc_data_data_sz + $dc_data_ecc_bits;
            $dc_data_port_map->{test_invert} = "ecc_test_dc_data[$dc_data_ecc_data_sz-1:0]";
        }


        $dc_data_port_map->{corrected_data_from_decoder} = "dc_data_rd_port_corrected_data";
        $dc_data_port_map->{one_bit_err} = "dc_data_rd_port_one_bit_err";
        $dc_data_port_map->{two_bit_err} = "dc_data_rd_port_two_bit_err";
        $dc_data_port_map->{one_two_or_three_bit_err} = "dc_data_rd_port_any_ecc_err";

        push(@dc_data_ram_ecc_waves,
          { radix => "x", signal => "dc_data_wr_port_corrected_data" },
          { radix => "x", signal => "dc_data_wr_port_injs" },
          { radix => "x", signal => "dc_data_wr_port_injd" },
          { radix => "x", signal => "dc_data_wr_port_wrsel" },
          { radix => "x", signal => "dc_data_rd_port_corrected_data" },
          { radix => "x", signal => "dc_data_rd_port_one_bit_err" },
          { radix => "x", signal => "dc_data_rd_port_two_bit_err" },
          { radix => "x", signal => "dc_data_rd_port_any_ecc_err" },
        );

        push(@dc_ecc_waves,
            { radix => "x", signal => "W_dc_data_injs" },
            { radix => "x", signal => "W_dc_data_injd" },
            { radix => "x", signal => "M_dc_data_raw_recoverable_flush_ecc_err" },
            { radix => "x", signal => "M_dc_data_raw_recoverable_correct_ecc_err" },
            { radix => "x", signal => "M_dc_data_raw_unrecoverable_ecc_err" },
        );

        e_assign->adds(

          [["dc_data_wr_port_injs", 1], "W_dc_data_injs"],
          [["dc_data_wr_port_injd", 1], "W_dc_data_injd"],
































          [["M_dc_data_raw_recoverable_flush_ecc_err", 1], 
             "M_ctrl_mem_dc_data_rd & ~M_dc_tag_raw_any_ecc_err & M_dc_valid &
               ~M_dc_dirty & dc_data_rd_port_any_ecc_err"],

          [["M_dc_data_raw_recoverable_correct_ecc_err", 1], 
             "M_ctrl_mem_dc_data_rd & ~M_dc_tag_raw_any_ecc_err & M_dc_valid &
               (dc_data_rd_port_one_bit_err & M_dc_dirty)"],

          [["M_dc_data_raw_unrecoverable_ecc_err", 1], 
             "M_ctrl_mem_dc_data_rd & ~M_dc_tag_raw_any_ecc_err & M_dc_valid &
               (dc_data_rd_port_two_bit_err & M_dc_dirty)"],



          [["dc_data_wr_port_wrsel", 1], "A_dc_valid_data_recoverable_correct_ecc_err"],


          [["M_dc_data_corrected_data", $dc_data_data_sz], "dc_data_rd_port_corrected_data"],
          [["dc_data_wr_port_corrected_data", $dc_data_data_sz], "A_dc_data_corrected_data"],
        );

        e_register->adds(



          {out => ["A_dc_valid_data_recoverable_flush_ecc_err", 1], 
           in => "M_dc_data_raw_recoverable_flush_ecc_err & M_valid_ignoring_refetch & W_config_reg_eccen",
           enable => "A_en"},
          {out => ["A_dc_valid_data_recoverable_correct_ecc_err", 1], 
           in => "M_dc_data_raw_recoverable_correct_ecc_err & M_valid_ignoring_refetch & W_config_reg_eccen",
           enable => "A_en"},


          {out => ["A_dc_data_ecc_event_recoverable_err", 1], 
           in => "(M_dc_data_raw_recoverable_flush_ecc_err | M_dc_data_raw_recoverable_correct_ecc_err) &
             M_valid_ignoring_refetch",
           enable => "A_en"},



          {out => ["A_dc_data_raw_unrecoverable_ecc_err", 1], 
           in => "M_dc_data_raw_unrecoverable_ecc_err", enable => "A_en"},


          {out => ["A_dc_data_corrected_data", $dc_data_data_sz], 
           in => "M_dc_data_corrected_data", enable => "A_en"},
        );

        if ($ecc_test_ports_present) {
            e_register->adds(
              {out => ["ecc_test_dc_data_valid_d1", 1],    in => "ecc_test_dc_data_valid & dc_data_wr_port_en",
               enable => "1'b1"},
            );
            e_assign->adds(
              [["ecc_test_dc_data_ready", 1], "~ecc_test_dc_data_valid | ecc_test_dc_data_valid_d1"],
           );
       }
    }



    if (manditory_bool($Opt, "export_large_RAMs")) {
        e_comment->add({
          comment => 
            ("Export D cache data RAM ports to top level\n" .
             "because the RAM is instantiated external to CPU.\n"),
        });
        e_assign->adds(

          [["dcache_g4b_data_ram_write_data", $dc_data_data_sz], 
            "dc_data_wr_port_data"],
          [["dcache_g4b_data_ram_write_enable",  1],
            "dc_data_wr_port_en"],
          [["dcache_g4b_data_ram_write_address", $dc_data_addr_sz],
            "dc_data_wr_port_addr"],
          [["dcache_g4b_data_ram_read_clk_en", 1], "1'b1"],
          [["dcache_g4b_data_ram_read_address", $dc_data_addr_sz], 
            "dc_data_rd_port_addr"],


          ["dc_data_rd_port_data", 
            ["dcache_g4b_data_ram_read_data", $dc_data_data_sz]],
        );
    } else {
        nios_sdp_ram->add({
          name => $Opt->{name} . "_dc_data",
          Opt                     => $Opt,
          data_width              => $dc_data_data_sz,
          address_width           => $dc_data_addr_sz,
          num_words               => $dc_data_num_addrs,
          read_during_write_mode_mixed_ports => qq("DONT_CARE"),
          ram_block_type          => '"' . $dcache_data_ram_block_type . '"',
          ecc_present             => $dc_ecc_present,
          verification            => $ecc_test_ports_present,
          port_map                => $dc_data_port_map, 
        });
    }


















    e_assign->adds(





      [["E_M_dc_line_offset_match", 1],
        "E_mem_baddr_line_offset_field == M_mem_baddr_line_offset_field"],
      [["M_A_dc_line_match", 1],
        "M_mem_baddr_line_field == A_mem_baddr_line_field"],


      [["M_dc_valid_st_cache_hit", 1], "M_valid_st_cache & M_dc_hit"],



      [["M_dc_valid_st_bypass_hit", 1], 
        manditory_bool($Opt, "cache_dcache_st_bypass_hit_updates_cache") ?
          "M_valid & M_ctrl_st_bypass & M_dc_hit" :
          "0"],
    );











































    e_assign->adds(


      [["M_dc_want_fill", 1], "M_valid_ld_st_cache & ~M_dc_hit "], 




      [["A_dc_fill_starting", 1], 
        "A_dc_want_fill & ~A_dc_fill_has_started & ~A_dc_wb_active"],
      


      [["A_dc_fill_has_started_nxt", 1], 
        "A_en ? 1'b0 : (A_dc_fill_starting | A_dc_fill_has_started)"],















      [["A_dc_fill_need_extra_stall_nxt", 1],
        "M_valid_mem_d1 & M_A_dc_line_match_d1 & 
         M_mem_baddr_offset_field == $dc_max_addr_offset"],



      [["A_dc_fill_done", 1], 
         "A_dc_fill_need_extra_stall ? 
            A_dc_rd_last_transfer_d1 : 
            A_dc_rd_last_transfer"],



      [["A_dc_fill_active_nxt", 1], 
        "A_dc_fill_active ? ~A_dc_fill_done : A_dc_fill_starting"],


      [["A_dc_fill_want_dmaster", 1], "A_dc_fill_starting | A_dc_fill_active"],




      [["A_dc_fill_dp_offset_nxt", $dc_addr_offset_field_sz], 
        "A_dc_fill_starting ? 0 : (A_dc_fill_dp_offset + 1)"],
      [["A_dc_fill_dp_offset_en", 1], 
        "A_dc_fill_starting | d_readdatavalid_d1"],





      [["A_dc_fill_miss_offset_is_next", 1],
        "A_dc_fill_active & (A_dc_fill_dp_offset == A_mem_baddr_offset_field)"],


      [["A_dc_fill_st_data_merged", $dc_data_data_sz], "{ 
         A_mem_byte_en[3] ? A_st_data[31:24] : d_readdata_d1[31:24],
         A_mem_byte_en[2] ? A_st_data[23:16] : d_readdata_d1[23:16],
         A_mem_byte_en[1] ? A_st_data[15:8]  : d_readdata_d1[15:8],
         A_mem_byte_en[0] ? A_st_data[7:0]   : d_readdata_d1[7:0]
        }"],






      [["A_dc_fill_wr_data", $dc_data_data_sz], 
        "(A_ctrl_st & A_dc_fill_miss_offset_is_next) ? A_dc_fill_st_data_merged : d_readdata_d1"],
    );

    e_register->adds(
      {out => ["A_dc_want_fill", 1],         
       in => "M_dc_want_fill",              enable => "A_en"},
      {out => ["A_dc_fill_has_started", 1],             
       in => "A_dc_fill_has_started_nxt",   enable => "1'b1"},
      {out => ["A_dc_fill_active", 1],             
       in => "A_dc_fill_active_nxt",        enable => "1'b1"},
      {out => ["A_dc_fill_dp_offset", $dc_addr_offset_field_sz], 
       in => "A_dc_fill_dp_offset_nxt",     enable => "A_dc_fill_dp_offset_en"},
      {out => ["A_dc_fill_starting_d1", 1],             
       in => "A_dc_fill_starting",          enable => "1'b1"},

      {out => ["M_valid_mem_d1", 1],
       in => "M_ctrl_ld_st & M_valid",        enable => "1'b1"},
      {out => ["M_A_dc_line_match_d1", 1],
       in => "M_A_dc_line_match",           enable => "1'b1"},
      {out => ["A_dc_fill_need_extra_stall", 1],
       in => "A_dc_fill_need_extra_stall_nxt", enable => "1'b1"},
      {out => ["A_dc_rd_last_transfer_d1", 1],
       in => "A_dc_rd_last_transfer",           enable => "1'b1"},
    );





    e_assign->adds(



      [["A_dc_wb_active_nxt", 1], 
        "A_dc_wb_active ? ~A_dc_wr_last_transfer : A_dc_xfer_rd_addr_starting"],
    );

    e_register->adds(
      {out => ["A_dc_wb_active", 1],         
       in => "A_dc_wb_active_nxt",          enable => "1'b1"},
    );










    if ($victim_buf_ram) {

        e_signal->adds(
          {name => "A_dc_wb_rd_data", width => $dc_data_data_sz },
        );





        if (manditory_bool($Opt, "use_designware")) {

            e_comment->add({
              comment =>
                "DesignWare BCM58 part used for the eviction buffer\n",
            });
    
            my $victim_in_port_map = {
              addr_r   => 'A_dc_wb_rd_addr_offset',
              addr_w   => 'A_dc_xfer_wr_offset',
              clk_r    => 'clk',
              clk_w    => 'clk',
              data_w   => 'A_dc_xfer_wr_data',
              en_r_n   => '~A_dc_wb_rd_en',
              en_w_n   => '~A_dc_xfer_wr_active',
              init_r_n => qq(1'b1),
              init_w_n => qq(1'b1),
              rst_r_n  => 'reset_n',
              rst_w_n  => 'reset_n'
             };
    
            my $victim_out_port_map = {
              data_r       => 'A_dc_wb_rd_data',
              data_r_a     => ''
            };
    
            my $victim_parameter_map = {
              ADDR_WIDTH => $dc_addr_offset_field_sz,
              WIDTH      => $dc_data_data_sz,
              DEPTH      => $dc_words_per_line,
              MEM_MODE   => 2,
              RST_MODE   => 0
            };
    
            e_blind_instance->add({
             name                     => $Opt->{name} . "_dc_victim",
             module                   => 'DWC_n2p_bcm58',
             use_sim_models           => 1,
             in_port_map              => $victim_in_port_map,
             out_port_map             => $victim_out_port_map,
             parameter_map            => $victim_parameter_map
          });
    
       } else {
           nios_sdp_ram->add({
             name => $Opt->{name} . "_dc_victim",
             Opt                     => $Opt,
             data_width              => $dc_data_data_sz,
             address_width           => $dc_addr_offset_field_sz,
             num_words               => $dc_words_per_line,
             read_during_write_mode_mixed_ports => qq("OLD_DATA"),
             ram_block_type          => '"' . $dcache_tag_ram_block_type . '"',
             port_map => {
               clock     => "clk",
       

               data      => "A_dc_xfer_wr_data",
               wren      => "A_dc_xfer_wr_active",
               wraddress => "A_dc_xfer_wr_offset",
       

               rden      => "A_dc_wb_rd_en",
               rdaddress => "A_dc_wb_rd_addr_offset",
               q         => "A_dc_wb_rd_data",
               },
           });
        }
    } elsif ($victim_buf_reg) {

















        e_assign->adds(

          [["A_dc_wb_rd_data", $dc_data_data_sz ], "dc_victim_0"],
        );

        for (my $w = 0; $w < $dc_words_per_line; $w++) {
            my $wp1 = $w + 1;
            my $last_entry = ($wp1 == $dc_words_per_line);

            e_register->adds(

              {out => ["dc_victim_$w", $dc_data_data_sz],         
               in => "dc_victim_${w}_nxt", enable => "dc_victim_${w}_wr_en"},
            );

            e_assign->adds(


              [["dc_victim_${w}_load_dc_data", 1], 
                "A_dc_xfer_wr_active & (A_dc_xfer_wr_offset_nxt == $w)"],




              [["dc_victim_${w}_wr_en", 1], "dc_victim_${w}_load_dc_data | A_dc_wb_rd_en"],





              [["dc_victim_${w}_nxt", $dc_data_data_sz], 
                $last_entry ?
                  "A_dc_xfer_wr_data" :
                  "dc_victim_${w}_load_dc_data ?  A_dc_xfer_wr_data : dc_victim_${wp1}"],
            );
        }
    } else {
        &$error("Unknown data cache victim buffer implementation");
    }









































    e_assign->adds(


      [["A_dc_fill_want_xfer", 1],   "A_dc_want_fill & A_dc_dirty"],
      [["A_dc_index_wb_inv_want_xfer", 1],
        "A_ctrl_dc_index_wb_inv & A_valid & A_dc_dirty"],
      [["A_dc_dc_addr_wb_inv_want_xfer", 1],
        "A_ctrl_dc_addr_wb_inv  & A_valid & A_dc_dirty & A_dc_hit"],


      [["A_dc_want_xfer", 1], 
        "A_dc_fill_want_xfer | A_dc_index_wb_inv_want_xfer | 
         A_dc_dc_addr_wb_inv_want_xfer"],




      [["A_dc_xfer_rd_addr_starting", 1], 
        "A_dc_want_xfer & ~A_dc_xfer_rd_addr_has_started & ~A_dc_wb_active"],



      [["A_dc_xfer_rd_addr_has_started_nxt", 1], 
         "A_en ? 1'b0 : 
           (A_dc_xfer_rd_addr_starting | A_dc_xfer_rd_addr_has_started)"],





      [["A_dc_xfer_rd_addr_done_nxt", 1], 
        "A_dc_xfer_rd_addr_active & 
          (A_dc_xfer_rd_addr_offset == ($dc_max_addr_offset - 1))"],



      [["A_dc_xfer_rd_addr_active_nxt", 1], 
        "A_dc_xfer_rd_addr_active ? 
           ~A_dc_xfer_rd_addr_done : 
            A_dc_xfer_rd_addr_starting"],




      [["A_dc_xfer_rd_addr_offset_nxt", $dc_addr_offset_field_sz], 
        "A_dc_xfer_rd_addr_starting ? 0 : (A_dc_xfer_rd_addr_offset + 1)"],




      [["A_dc_xfer_rd_addr_offset_match", 1],
        "A_valid_st_writes_mem & (A_dc_xfer_rd_addr_offset == A_mem_baddr_offset_field)"],




      [["A_dc_xfer_wr_offset_starting", 1],
        $victim_buf_ram ? "A_dc_xfer_wr_starting" : "A_dc_wb_rd_data_starting"],




      [["A_dc_xfer_wr_offset_nxt", $dc_addr_offset_field_sz], 
         "A_dc_xfer_wr_offset_starting          ? 0 : " .
         ($victim_buf_reg ? "A_dc_wb_rd_en ? A_dc_xfer_wr_offset : " : "") .
         "(A_dc_xfer_wr_offset + 1)"],








      [["A_dc_xfer_wr_data_nxt", $datapath_sz],
         "A_dc_xfer_rd_data_offset_match ? 
           A_dc_rd_data : " .
           ($dc_ecc_present ? "dc_data_rd_port_corrected_data" : "dc_data_rd_port_data")],
    );

    e_register->adds(
      {out => ["A_dc_dirty", 1],            
       in => "M_dc_dirty",                          enable => "A_en"},
      {out => ["A_dc_xfer_rd_addr_has_started", 1],             
       in => "A_dc_xfer_rd_addr_has_started_nxt",   enable => "1'b1"},


      {out => ["A_dc_xfer_rd_addr_active", 1],             
       in => "A_dc_xfer_rd_addr_active_nxt",        enable => "1'b1"},
      {out => ["A_dc_xfer_rd_addr_done", 1],             
       in => "A_dc_xfer_rd_addr_done_nxt",          enable => "1'b1"},
      {out => ["A_dc_xfer_rd_addr_offset", $dc_addr_offset_field_sz], 
       in => "A_dc_xfer_rd_addr_offset_nxt",        enable => "1'b1"},




      {out => ["A_dc_xfer_rd_data_starting", 1],             
       in => "A_dc_xfer_rd_addr_starting",          enable => "1'b1"},
      {out => ["A_dc_xfer_rd_data_active", 1],             
       in => "A_dc_xfer_rd_addr_active",            enable => "1'b1"},
      {out => ["A_dc_xfer_rd_data_offset_match", 1],             
       in => "A_dc_xfer_rd_addr_offset_match",      enable => "1'b1"},








      {out => ["A_dc_xfer_wr_starting", 1],
       in => "A_dc_xfer_rd_data_starting",          enable => "1'b1"},
      {out => ["A_dc_xfer_wr_active", 1],             
       in => "A_dc_xfer_rd_data_active",            enable => "1'b1"},
      {out => ["A_dc_xfer_wr_offset", $dc_addr_offset_field_sz], 
       in => "A_dc_xfer_wr_offset_nxt",             enable => "1'b1"},
      {out => ["A_dc_xfer_wr_data", $datapath_sz],
       in => "A_dc_xfer_wr_data_nxt",               enable => "1'b1"},


      {out => ["A_dc_wb_tag", $dc_addr_tag_field_sz], 
       in => "A_dc_actual_tag",                     
       enable => "A_dc_xfer_rd_data_starting"},
      {out => ["A_dc_wb_line", $dc_addr_line_field_sz], 
       in => "A_mem_baddr_line_field",                     
       enable => "A_dc_xfer_rd_data_starting"},
    );


    if (manditory_bool($Opt, "cache_dcache_allow_tag_wrt")) {
      e_register->adds(
        {out => ["A_dc_valid", 1],            
        in => "M_dc_valid",                          enable => "A_en"},

        {out => ["A_dc_dirty_raw", 1],            
        in => "M_dc_dirty_raw",                      enable => "A_en"},
      );
    }










































    e_assign->adds(














      [["A_dc_wb_rd_en", 1], 
        $victim_buf_ram ? 
          "A_dc_wb_rd_addr_starting | A_dc_wb_rd_data_starting | A_dc_wb_wr_starting | 
             av_wr_data_transfer" :
          "A_dc_wb_update_av_writedata"], 




      [["A_dc_wb_wr_starting", 1], "A_dc_wb_rd_data_first & ~d_read"],



      [["A_dc_wb_wr_active_nxt", 1], 
        "A_dc_wb_wr_active ? ~A_dc_wr_last_transfer : A_dc_wb_wr_starting"],


      [["A_dc_wb_wr_want_dmaster", 1], "A_dc_wb_wr_starting | A_dc_wb_wr_active"],




      [["A_dc_wb_rd_data_first_nxt", 1],
        "A_dc_wb_rd_data_first ? ~A_dc_wb_wr_starting : A_dc_wb_rd_data_starting"],





      [["A_dc_wb_update_av_writedata", 1], 
        "A_dc_wb_wr_starting | 
         (A_dc_wb_wr_active & ~A_dc_wr_last_driven & ~d_waitrequest)"],
    );

    if ($victim_buf_ram) {
        e_assign->adds(



          [["A_dc_wb_rd_addr_offset_nxt", $dc_addr_offset_field_sz], 
            "A_dc_wb_rd_addr_starting ? 0 : (A_dc_wb_rd_addr_offset + 1)"],
        );

        e_register->adds(


          {out => ["A_dc_wb_rd_addr_starting", 1],             
           in => "A_dc_xfer_wr_starting",               enable => "1'b1"},


          {out => ["A_dc_wb_rd_addr_offset", $dc_addr_offset_field_sz], 
           in => "A_dc_wb_rd_addr_offset_nxt",          enable => "A_dc_wb_rd_en"},

        );
    }

    e_register->adds(



      {out => ["A_dc_wb_rd_data_starting", 1],             
       in => $victim_buf_ram ? "A_dc_wb_rd_addr_starting" : "A_dc_xfer_wr_starting",
       enable => "1'b1"},



      {out => ["A_dc_wb_wr_active", 1],             
       in => "A_dc_wb_wr_active_nxt",               enable => "1'b1"},
      {out => ["A_dc_wb_rd_data_first", 1],             
       in => "A_dc_wb_rd_data_first_nxt",           enable => "1'b1"},
    );











    e_assign->adds(




      [["A_dc_index_wb_inv_done_nxt", 1], 
        "~A_dc_dirty | A_dc_xfer_rd_addr_done"],






      [["A_dc_dc_addr_wb_inv_done_nxt", 1],
        "~A_dc_dirty | A_dc_xfer_rd_addr_done | ~A_dc_hit"],
    );





    my @A_dc_dcache_management_done_nxt_inputs = ( 
      "A_valid & ~A_en &
            (A_ctrl_dc_nowb_inv |
            (A_ctrl_dc_index_wb_inv & A_dc_index_wb_inv_done_nxt) |
            ((A_ctrl_dc_addr_wb_inv ) & A_dc_dc_addr_wb_inv_done_nxt))",
    );


    if (manditory_bool($Opt, "cache_dcache_allow_tag_wrt")) {
      push(@A_dc_dcache_management_done_nxt_inputs,"(A_op_dcache_st_tag & A_valid )",);
      push(@A_dc_dcache_management_done_nxt_inputs,"(A_ctrl_ic_only_read_tag & A_valid )",);
    }
      e_assign->adds(
        [["A_dc_dcache_management_done_nxt", 1],
          scalar(@A_dc_dcache_management_done_nxt_inputs) ? 
        join("|",@A_dc_dcache_management_done_nxt_inputs) : "0"],
      );

    e_register->adds(
      {out => ["A_dc_dcache_management_done", 1],             
       in => "A_dc_dcache_management_done_nxt",  enable => "1'b1"},
    );







    e_assign->adds(




      [["M_dc_want_mem_bypass_or_dcache_management", 1], 
        "M_valid & M_ctrl_ld_st_bypass_or_dcache_management"],





      [["A_ld_bypass_done", 1], "A_dc_rd_last_transfer"],







      [["A_st_bypass_transfer_done", 1],
        "A_dc_wr_last_transfer & ~A_dc_wb_active"],
      [["A_st_bypass_done", 1], 
        "A_dc_valid_st_bypass_hit ? 
           A_st_bypass_transfer_done_d1 :
           A_st_bypass_transfer_done"],




      [["A_mem_bypass_pending", 1], "A_ctrl_ld_st_bypass & A_valid & ~A_en"],






      [["A_dc_valid_st_bypass_hit_wr_en", 1], 
        "A_dc_valid_st_bypass_hit & A_en_d1"],
    );

    e_register->adds(






      {out => ["A_ld_bypass_delayed", 1],             
       in => "M_ctrl_ld_bypass & M_valid & A_dc_wb_active",
       enable => "A_en"},
      {out => ["A_st_bypass_delayed", 1],             
       in => "M_ctrl_st_bypass & M_valid & A_dc_wb_active",
       enable => "A_en"},



      {out => ["A_ld_bypass_delayed_started", 1],             
       in => "A_en ? 0 : 
         ((A_ld_bypass_delayed & ~A_dc_wb_active) | 
           A_ld_bypass_delayed_started)",
       enable => "1'b1"},
      {out => ["A_st_bypass_delayed_started", 1],             
       in => "A_en ? 0 : 
         ((A_st_bypass_delayed & ~A_dc_wb_active) | 
           A_st_bypass_delayed_started)",
       enable => "1'b1"},

      {out => ["A_st_bypass_transfer_done_d1", 1],             
       in  => "A_st_bypass_transfer_done",
       enable => "1'b1"},
    );










    my @stall_start = (
      "M_dc_want_fill",
      "M_dc_want_mem_bypass_or_dcache_management",
      "M_dc_potential_hazard_after_st",
    );

    if ($advanced_exc && $dtcm_present) {

        push(@stall_start, "E_dtcm_M_st_caused_wrong_readdata");
    }










    my @stall_stop = (
      "(A_dc_fill_active & A_dc_fill_done)",
      "(A_dc_dcache_management_done)",
      "(A_ctrl_ld_bypass & A_ld_bypass_done)",
      "(A_ctrl_st_bypass & A_st_bypass_done)",
      "(A_dc_potential_hazard_after_st & A_dc_valid_st_cache_hit)",
    );

    if ($advanced_exc && $dtcm_present) {

        push(@stall_stop, "M_dtcm_A_st_caused_wrong_readdata");
    }

    e_assign->adds(













      [["d_address_tag_field_nxt", $dc_addr_tag_field_sz],
        "A_dc_wb_wr_want_dmaster                         ? A_dc_wb_tag : 
         (A_dc_fill_want_dmaster | A_mem_bypass_pending) ? A_dc_desired_tag :
                                                           M_dc_desired_tag"],


      [["d_address_line_field_nxt", $dc_addr_line_field_sz],
        "A_dc_wb_wr_want_dmaster                         ? 
            A_dc_wb_line : 
         (A_dc_fill_want_dmaster | A_mem_bypass_pending) ? 
            A_mem_baddr_line_field :
            M_mem_baddr_line_field"],


      [["d_address_byte_field_nxt", $dc_addr_byte_field_sz],
        "(A_dc_wb_wr_want_dmaster | A_dc_fill_want_dmaster) ? 0 : 
         A_mem_bypass_pending                      ? A_mem_baddr_byte_field :
                                                     M_mem_baddr_byte_field"],


      [["d_byteenable_nxt", $byte_en_sz], 
        "(A_dc_wb_wr_want_dmaster | A_dc_fill_want_dmaster) ? $byte_en_all_on : 
         A_mem_bypass_pending                               ? A_mem_byte_en :
                                                              M_mem_byte_en"],
 





      [["d_writedata_nxt", $datapath_sz], 
        "A_dc_wb_update_av_writedata                 ? A_dc_wb_rd_data : 
         A_dc_wb_wr_active                           ? d_writedata :
         A_mem_bypass_pending                        ? A_st_data :
                                                       M_st_data"],






      [["d_write_nxt", 1],
        "A_dc_wb_wr_starting |
         (M_ctrl_st_bypass & M_valid & A_en & ~A_dc_wb_active) | 
         (A_st_bypass_delayed & ~A_st_bypass_delayed_started & 
          ~A_dc_wb_active) |
         (d_write & (d_waitrequest | ~A_dc_wr_last_driven))"],




      [["d_address", $data_master_addr_sz],     
        "{d_address_tag_field, 
          d_address_line_field[$dc_addr_line_field_paddr_sz-1:0],
          d_address_offset_field,
          d_address_byte_field}"],





























      [["M_dc_potential_hazard_after_st_unfiltered", 1],
        "E_M_dc_line_offset_match & M_valid_st_cache & E_ctrl_mem & E_valid"],




      [["A_mem_stall_start_nxt", 1], 
        "A_en & (" . join('|', @stall_start) . ")"],



      [["A_mem_stall_stop_nxt", 1], join('|', @stall_stop)],



      [["A_mem_stall_nxt", 1], 
        "A_mem_stall ? ~A_mem_stall_stop_nxt : A_mem_stall_start_nxt"],









      [["A_dc_rd_data_cnt_nxt", $line_word_cnt_sz], 
        "d_readdatavalid_d1 ? (A_dc_rd_data_cnt + 1) :
         A_dc_fill_starting ? 1 :
         A_dc_fill_active   ? A_dc_rd_data_cnt :
                              $line_word_cnt_max"],


      [["A_dc_rd_last_transfer", 1], 
        "A_dc_rd_data_cnt[$line_word_cnt_sz-1] & d_readdatavalid_d1"],


      [["av_wr_data_transfer", 1], "d_write & ~d_waitrequest"],









      [["A_dc_wr_data_cnt_nxt", $line_word_cnt_sz], 
        "av_wr_data_transfer ? (A_dc_wr_data_cnt + 1) :
         A_dc_wb_wr_starting ? 1 :
         A_dc_wb_wr_active   ? A_dc_wr_data_cnt :
                               $line_word_cnt_max"],



      [["A_dc_wr_last_driven", 1], 
        "A_dc_wr_data_cnt[$line_word_cnt_sz-1]"],


      [["A_dc_wr_last_transfer", 1], 
        "A_dc_wr_last_driven & d_write & ~d_waitrequest"],
    );




    if (manditory_bool($Opt, "asic_enabled")) {
        e_assign->adds(
          [["M_dc_potential_hazard_after_st", 1], "M_dc_potential_hazard_after_st_unfiltered"],
        );
    } else {
        create_x_filter({
          lhs       => "M_dc_potential_hazard_after_st",
          rhs       => "M_dc_potential_hazard_after_st_unfiltered",
          sz        => 1,
        });
    }



    $perf_cnt_inc_rd_stall = "(d_read & A_mem_stall)";
    $perf_cnt_inc_wr_stall = "(d_write & A_mem_stall)";

    if ($dmaster_bursts) {



        e_assign->adds(

          [["d_burstcount_nxt", $dmaster_burstcount_sz],    
            "(A_dc_wb_wr_want_dmaster | A_dc_fill_want_dmaster) ? 
                                                     $dmaster_burstcount_max :
                                                     1"],



          [["d_address_offset_field_nxt", $dc_addr_offset_field_sz],
            "(A_dc_wb_wr_want_dmaster | A_dc_fill_want_dmaster) ? 0 : 
             A_mem_bypass_pending                  ? A_mem_baddr_offset_field :
                                                     M_mem_baddr_offset_field"],





          [["d_read_nxt", 1],
            "A_dc_fill_starting | 
             (M_ctrl_ld_bypass & M_valid & A_en & ~A_dc_wb_active) |
             (A_ld_bypass_delayed & ~A_ld_bypass_delayed_started & 
              ~A_dc_wb_active) |
             (d_read & d_waitrequest)"],
        );

        e_register->adds(
          {out => ["d_burstcount", $dmaster_burstcount_sz],    
           in => "d_burstcount_nxt",                enable => "1'b1"},
        );
    } else {


        e_assign->adds(

          [["av_addr_accepted", 1], "(d_read | d_write) & ~d_waitrequest"],




          [["d_address_offset_field_nxt", $dc_addr_offset_field_sz],
            "av_addr_accepted ? (d_address_offset_field + 1) :
             (A_dc_wb_wr_starting | A_dc_fill_starting) ? 0 :
             (A_dc_wb_wr_active | A_dc_fill_active) ? d_address_offset_field :
              A_mem_bypass_pending                ? A_mem_baddr_offset_field :
                                                    M_mem_baddr_offset_field"],






          [["d_read_nxt", 1],
            "A_dc_fill_starting |
             (M_ctrl_ld_bypass & M_valid & A_en & ~A_dc_wb_active) | 
             (A_ld_bypass_delayed & ~A_ld_bypass_delayed_started & 
              ~A_dc_wb_active) |
             (d_read & (d_waitrequest | ~A_dc_rd_last_driven))"],


          [["av_rd_addr_accepted", 1], "d_read & ~d_waitrequest"],
    








          [["A_dc_rd_addr_cnt_nxt", $line_word_cnt_sz], 
            "av_rd_addr_accepted ? (A_dc_rd_addr_cnt + 1) :
             A_dc_fill_starting  ? 1 :
             A_dc_fill_active    ? A_dc_rd_addr_cnt :
                                   $line_word_cnt_max"],
    


          [["A_dc_rd_last_driven", 1], 
            "A_dc_rd_addr_cnt[$line_word_cnt_sz-1]"],
        );

        e_register->adds(
          {out => ["A_dc_rd_addr_cnt", $line_word_cnt_sz],         
           in => "A_dc_rd_addr_cnt_nxt",            enable => "1'b1"},
        );
    }

    e_register->adds(
      {out => ["d_address_tag_field", $dc_addr_tag_field_sz],  
       in => "d_address_tag_field_nxt",         enable => "1'b1"},
      {out => ["d_address_line_field", $dc_addr_line_field_sz],  
       in => "d_address_line_field_nxt",        enable => "1'b1"},
      {out => ["d_address_offset_field", $dc_addr_offset_field_sz],  
       in => "d_address_offset_field_nxt",      enable => "1'b1"},
      {out => ["d_address_byte_field", $dc_addr_byte_field_sz],  
       in => "d_address_byte_field_nxt",        enable => "1'b1"},
      {out => ["d_byteenable", $byte_en_sz],    
       in => "d_byteenable_nxt",                enable => "1'b1"},
      {out => ["d_writedata", $datapath_sz],    
       in => "d_writedata_nxt",                 enable => "1'b1"},

      {out => ["A_mem_stall", 1],               
       in => "A_mem_stall_nxt",                 enable => "1'b1"},

      {out => ["A_dc_rd_data_cnt", $line_word_cnt_sz], 
       in => "A_dc_rd_data_cnt_nxt",            enable => "1'b1"},
      {out => ["A_dc_wr_data_cnt", $line_word_cnt_sz], 
       in => "A_dc_wr_data_cnt_nxt",            enable => "1'b1"},
    );

    my @waves;

    push(@waves, 
        { divider => "dcache_addr_fields" },
        { radix => "x", signal => "E_mem_baddr_line_field" },
        { radix => "x", signal => "E_mem_baddr_offset_field" },
        { radix => "x", signal => "M_mem_baddr_line_field" },
        { radix => "x", signal => "M_mem_baddr_offset_field" },
        { radix => "x", signal => "A_mem_baddr_line_field" },
        { radix => "x", signal => "A_mem_baddr_offset_field" },
        { divider => "dcache_tag_ram" },
        { radix => "x", signal => "M_dc_st_wr_en" },
        { radix => "x", signal => "A_dc_tag_dcache_management_wr_en" },
        { radix => "x", signal => "dc_tag_rd_port_addr" },
        { radix => "x", signal => "dc_tag_rd_port_data" },
        { radix => "x", signal => "dc_tag_wr_port_en" },
        { radix => "x", signal => "dc_tag_wr_port_data" },
        { radix => "x", signal => "dc_tag_wr_port_addr" },
        @dc_tag_ram_ecc_waves,
        { radix => "x", signal => "M_dc_dirty_raw" },
        { radix => "x", signal => "M_dc_dirty" },
        { radix => "x", signal => "M_dc_valid" },
        { radix => "x", signal => "M_dc_actual_tag" },
        { radix => "x", signal => "A_dc_fill_active" },
        { radix => "x", signal => "M_dc_desired_tag" },
        { radix => "x", signal => "M_dc_tag_match" },
        { radix => "x", signal => "A_dc_desired_tag" },
        { radix => "x", signal => "M_dc_hit" },
        { divider => "dcache_data_ram" },
        { radix => "x", signal => "A_dc_fill_active" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_active" },
        { radix => "x", signal => "A_dc_data_dcache_management_wr_en" },
        { radix => "x", signal => "dc_data_rd_port_addr" },
        { radix => "x", signal => "dc_data_rd_port_data" },
        { radix => "x", signal => "dc_data_wr_port_en" },
        { radix => "x", signal => "dc_data_wr_port_data" },
        { radix => "x", signal => "dc_data_wr_port_addr" },
        @dc_data_ram_ecc_waves,
        { radix => "x", signal => "E_M_dc_line_offset_match" },
        { radix => "x", signal => "M_A_dc_line_match" },
        { radix => "x", signal => "A_dc_valid_st_cache_hit" },
        { radix => "x", signal => "A_dc_valid_st_bypass_hit_wr_en" },
        @dc_ecc_waves,
        { divider => "dcache_fill" },
        { radix => "x", signal => "M_dc_want_fill" },
        { radix => "x", signal => "A_dc_fill_starting" },
        { radix => "x", signal => "A_dc_fill_has_started_nxt" },
        { radix => "x", signal => "A_dc_fill_need_extra_stall" },
        { radix => "x", signal => "A_dc_fill_done" },
        { radix => "x", signal => "A_dc_fill_active_nxt" },
        { radix => "x", signal => "A_dc_fill_dp_offset_nxt" },
        { radix => "x", signal => "A_dc_fill_dp_offset_en" },
        { radix => "x", signal => "A_dc_fill_miss_offset_is_next" },
        { radix => "x", signal => "A_dc_fill_wr_data" },
        { radix => "x", signal => "A_dc_want_fill" },
        { radix => "x", signal => "A_dc_fill_has_started" },
        { radix => "x", signal => "A_dc_fill_active" },
        { radix => "x", signal => "A_dc_fill_want_dmaster" },
        { radix => "x", signal => "A_dc_fill_dp_offset" },
        { radix => "x", signal => "M_valid_mem_d1" },
        { radix => "x", signal => "M_A_dc_line_match_d1" },
        { radix => "x", signal => "A_dc_fill_need_extra_stall" },
        { radix => "x", signal => "A_dc_rd_last_transfer" },
        { radix => "x", signal => "A_dc_rd_last_transfer_d1" },
        { divider => "dcache_wb" },
        { radix => "x", signal => "A_dc_wb_active_nxt" },
        { radix => "x", signal => "A_dc_wb_active" },
        { divider => "dcache_victim_buffer" },
    );

    if ($victim_buf_reg) {
        for (my $w = 0; $w < $dc_words_per_line; $w++) {
            push(@waves, 
              { radix => "x", signal => "dc_victim_${w}_load_dc_data" },
              { radix => "x", signal => "dc_victim_${w}_wr_en" },
              { radix => "x", signal => "dc_victim_${w}_nxt" },
              { radix => "x", signal => "dc_victim_${w}" },
            );
        }
    }

    push(@waves, 
        { radix => "x", signal => "A_dc_xfer_wr_data" },
        { radix => "x", signal => "A_dc_xfer_wr_active" },
        { radix => "x", signal => "A_dc_xfer_wr_offset" },
        { radix => "x", signal => "A_dc_wb_rd_en" },
        $victim_buf_ram ?  { radix => "x", signal => "A_dc_wb_rd_addr_offset" } : "",
        { radix => "x", signal => "A_dc_wb_rd_data" },
        { divider => "dcache_victim_xfer" },
        { radix => "x", signal => "A_dc_fill_want_xfer" },
        { radix => "x", signal => "A_dc_index_wb_inv_want_xfer" },
        { radix => "x", signal => "A_dc_dc_addr_wb_inv_want_xfer" },
        { radix => "x", signal => "A_dc_want_xfer" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_starting" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_has_started_nxt" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_done" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_active_nxt" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_offset_nxt" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_offset_match" },
        { radix => "x", signal => "A_dc_xfer_wr_data_nxt" },
        { radix => "x", signal => "A_dc_rd_data" },
        { radix => "x", signal => "A_dc_dirty" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_has_started" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_active" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_offset" },
        { radix => "x", signal => "A_dc_xfer_rd_data_starting" },
        { radix => "x", signal => "A_dc_xfer_rd_data_active" },
        { radix => "x", signal => "A_dc_xfer_rd_data_offset_match" },
        { radix => "x", signal => "A_dc_xfer_wr_starting" },
        { radix => "x", signal => "A_dc_xfer_wr_active" },
        { radix => "x", signal => "A_dc_xfer_wr_data" },
        { radix => "x", signal => "A_dc_xfer_wr_offset" },
        { radix => "x", signal => "A_dc_xfer_wr_offset_starting" },
        { radix => "x", signal => "A_dc_wb_tag" },
        { radix => "x", signal => "A_dc_wb_line" },
        { divider => "dcache_wb" },
        { radix => "x", signal => "A_dc_wb_rd_en" },
        $victim_buf_ram ? { radix => "x", signal => "A_dc_wb_rd_addr_offset_nxt" } : "",
        { radix => "x", signal => "A_dc_wb_wr_starting" },
        { radix => "x", signal => "A_dc_wb_wr_active_nxt" },
        { radix => "x", signal => "A_dc_wb_rd_data_first_nxt" },
        { radix => "x", signal => "A_dc_wb_update_av_writedata" },
        $victim_buf_ram ? { radix => "x", signal => "A_dc_wb_rd_addr_starting" } : "",
        $victim_buf_ram ? { radix => "x", signal => "A_dc_wb_rd_addr_offset" } : "",
        { radix => "x", signal => "A_dc_wb_rd_data_starting" },
        { radix => "x", signal => "A_dc_wb_wr_active" },
        { radix => "x", signal => "A_dc_wb_wr_want_dmaster" },
        { radix => "x", signal => "A_dc_wb_rd_data_first" },
        { divider => "dcache_bypass" },
        { radix => "x", signal => 
          "M_dc_want_mem_bypass_or_dcache_management" },
        { radix => "x", signal => "A_ld_bypass_done" },
        { radix => "x", signal => "A_st_bypass_done" },
        { radix => "x", signal => "A_dc_valid_st_bypass_hit" },
        { radix => "x", signal => "A_dc_valid_st_bypass_hit_wr_en" },
        { radix => "x", signal => "A_st_bypass_transfer_done" },
        { radix => "x", signal => "A_st_bypass_transfer_done_d1" },
        { radix => "x", signal => "A_mem_bypass_pending" },
        { radix => "x", signal => "A_ld_bypass_delayed" },
        { radix => "x", signal => "A_st_bypass_delayed" },
        { radix => "x", signal => "A_ld_bypass_delayed_started" },
        { radix => "x", signal => "A_st_bypass_delayed_started" },
        { divider => "dcache_management" },
        { radix => "x", signal => "A_dc_hit" },
        { radix => "x", signal => "A_dc_dirty" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_active" },
        { radix => "x", signal => "A_dc_xfer_rd_addr_done" },
        { radix => "x", signal => "A_ctrl_dc_index_nowb_inv" },
        { radix => "x", signal => "A_ctrl_dc_addr_nowb_inv" },
        { radix => "x", signal => "A_ctrl_dc_index_wb_inv" },
        { radix => "x", signal => "A_ctrl_dc_addr_wb_inv" },
        { radix => "x", signal => "A_dc_index_wb_inv_done_nxt" },
        { radix => "x", signal => "A_dc_dc_addr_wb_inv_done_nxt" },
        { radix => "x", signal => "A_dc_dcache_management_done_nxt" },
        { radix => "x", signal => "A_dc_dcache_management_done" },
        { divider => "dcache_dmaster" },
        { radix => "x", signal => "d_address_tag_field_nxt" },
        { radix => "x", signal => "d_address_line_field_nxt" },
        { radix => "x", signal => "d_address_offset_field_nxt" },
        { radix => "x", signal => "d_address_byte_field_nxt" },
        { radix => "x", signal => "d_byteenable_nxt" },
        $dmaster_bursts ? { radix => "x", signal => "d_burstcount_nxt" } : "",
        { radix => "x", signal => "d_writedata_nxt" },
        { radix => "x", signal => "d_write_nxt" },
        { radix => "x", signal => "d_write" },
        { radix => "x", signal => "d_read_nxt" },
        { radix => "x", signal => "d_read" },
        { radix => "x", signal => "d_waitrequest" },
        { radix => "x", signal => "d_readdatavalid_d1" },
        { radix => "x", signal => "d_readdata_d1" },
        { radix => "x", signal => "d_address" },
        { radix => "x", signal => "A_mem_stall_start_nxt" },
        { radix => "x", signal => "M_dc_want_fill" },
        { radix => "x", signal => 
          "M_dc_want_mem_bypass_or_dcache_management" },
        { radix => "x", signal => "M_dc_potential_hazard_after_st" },
        { radix => "x", signal => "A_mem_stall_stop_nxt" },
        { radix => "x", signal => "A_dc_fill_active" },
        { radix => "x", signal => "A_dc_fill_done" },
        { radix => "x", signal => "A_dc_dcache_management_done " },
        { radix => "x", signal => "A_dc_xfer_rd_addr_done" },
        { radix => "x", signal => "A_ctrl_ld_bypass" },
        { radix => "x", signal => "A_ld_bypass_done" },
        { radix => "x", signal => "A_ctrl_st_bypass" },
        { radix => "x", signal => "A_st_bypass_done" },
        { radix => "x", signal => "A_dc_potential_hazard_after_st" },
        { radix => "x", signal => "A_mem_stall_nxt" },
        { radix => "x", signal => "A_dc_rd_data_cnt_nxt" },
        { radix => "x", signal => "A_dc_rd_last_transfer" },
        { radix => "x", signal => "av_wr_data_transfer" },
        { radix => "x", signal => "A_dc_wr_data_cnt_nxt" },
        { radix => "x", signal => "A_dc_wr_last_driven" },
        { radix => "x", signal => "A_dc_wr_last_transfer" },
        { radix => "x", signal => "d_address_tag_field" },
        { radix => "x", signal => "d_address_line_field" },
        { radix => "x", signal => "d_address_offset_field" },
        { radix => "x", signal => "d_address_byte_field" },
        { radix => "x", signal => "d_byteenable" },
        $dmaster_bursts ? { radix => "x", signal => "d_burstcount" } : "",
        { radix => "x", signal => "d_writedata" },
        { radix => "x", signal => "A_mem_stall" },
        { radix => "x", signal => "A_dc_rd_data_cnt" },
        { radix => "x", signal => "A_dc_wr_data_cnt" },
        $dmaster_bursts ? "" : {radix => "x", signal => "av_rd_addr_accepted"},
        $dmaster_bursts ? "" : {radix => "x", signal => "A_dc_rd_addr_cnt_nxt"},
        $dmaster_bursts ? "" : {radix => "x", signal => "A_dc_rd_last_driven"},
        $dmaster_bursts ? "" : {radix => "x", signal => "A_dc_rd_addr_cnt"},
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @waves);
    }
}

1;
