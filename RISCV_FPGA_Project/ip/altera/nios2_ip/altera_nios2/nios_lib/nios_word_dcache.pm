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






















package nios_word_dcache;
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
use nios_tdp_ram;
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

    my $whoami = "word data cache";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    my $mmu_addr_pfn_lsb;
    if ($tlb_present) {
        $mmu_addr_pfn_lsb = manditory_int($Opt, "mmu_addr_pfn_lsb");
    }
    














    my $dc_bytes_per_line = manditory_int($Opt, "cache_dcache_line_size");
    if ($dc_bytes_per_line != 4) {
        &$error("Number of D-Cache bytes per line must be 4 but is " .
           $dc_bytes_per_line . "\n");
    }
    my $dc_total_bytes = manditory_int($Opt, "cache_dcache_size");

    my $data_master_addr_sz = 
      manditory_int($Opt->{data_master}, "Address_Width");


    my $dc_words_per_line = $dc_bytes_per_line >> 2;
    my $dc_num_lines = $dc_total_bytes / $dc_bytes_per_line;




    my $dc_addr_byte_field_sz = 2;
    my $dc_addr_byte_field_lsb = 0;
    my $dc_addr_byte_field_msb = $dc_addr_byte_field_lsb + 
      $dc_addr_byte_field_sz - 1;

    my $dc_addr_line_field_sz = count2sz($dc_num_lines);
    my $dc_addr_line_field_lsb = $dc_addr_byte_field_msb + 1;
    my $dc_addr_line_field_msb = $dc_addr_line_field_lsb + 
      $dc_addr_line_field_sz - 1;





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


    my $dc_data_addr_sz = $dc_addr_line_field_sz;
    my $dc_data_num_addrs = 0x1 << $dc_data_addr_sz;


    my $dc_data_data_sz = $datapath_sz;





    e_register->adds(

      {out => ["A_dc_victim_rd_data", $datapath_sz], 
       in => "M_dc_victim_rd_data", enable => "A_en"},
      {out => ["A_dc_victim_tag", $dc_addr_tag_field_sz], 
       in => "M_dc_victim_tag", enable => "A_en"},
    );





    e_assign->adds(



      [["M_st_dcache_management_dc_wr_en", 1], 
        "((M_ctrl_st_non_bypass & M_sel_data_master) | 
          M_ctrl_dcache_management) & M_valid"],




      [["A_dc_line", $dc_addr_line_field_sz],
        "A_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],




      [["A_dc_fill_wr_en", 1], "av_process_readdata & ~A_ctrl_ld_bypass"],


      [["A_dc_fill_wr_data", $dc_data_data_sz], "d_readdata_d1"],


      [["A_dc_fill_line", $dc_addr_line_field_sz], "A_dc_line"],







      [["A_dc_fill_byte_en", $byte_en_sz], 
        "A_ctrl_ld_dcache_management ? $byte_en_all_on : ~A_mem_byte_en"],




      [["A_dc_fill_wr_tag", $dc_tag_data_sz], 
        "{A_ctrl_st, dc_line_valid_on, A_dc_desired_tag}"],


      [["dc_data_portb_wr_data", $dc_data_data_sz], 
        "A_dc_fill_wr_en ? A_dc_fill_wr_data : M_st_data"],
      [["dc_data_portb_byte_en", $byte_en_sz], 
        "A_dc_fill_wr_en ? A_dc_fill_byte_en : M_mem_byte_en"],
      [["dc_data_portb_addr", $dc_data_addr_sz], 
        "A_dc_fill_wr_en ? A_dc_fill_line : M_dc_line"],
      [["dc_data_portb_wr_en", 1], 
        "A_en ? M_st_dcache_management_dc_wr_en : A_dc_fill_wr_en"],


      [["dc_tag_portb_data", $dc_tag_data_sz], 
        "A_dc_fill_wr_en ? A_dc_fill_wr_tag : 
         M_ctrl_st ? {dc_line_dirty_on, dc_line_valid_on, M_dc_desired_tag} :
                     {dc_line_dirty_off, dc_line_valid_off, M_dc_desired_tag}"],
      [["dc_tag_portb_addr", $dc_tag_addr_sz], 
        "A_dc_fill_wr_en ? A_dc_fill_line : M_dc_line"],
      [["dc_tag_portb_wr_en", 1], "dc_data_portb_wr_en"], 


      [["dc_data_wr_byte_0", 1], 
        "dc_data_portb_wr_en & dc_data_portb_byte_en[0]"],
      [["dc_data_wr_byte_1", 1], 
        "dc_data_portb_wr_en & dc_data_portb_byte_en[1]"],
      [["dc_data_wr_byte_2", 1], 
        "dc_data_portb_wr_en & dc_data_portb_byte_en[2]"],
      [["dc_data_wr_byte_3", 1], 
        "dc_data_portb_wr_en & dc_data_portb_byte_en[3]"],
      );

    e_register->adds(
      {out => ["A_dc_latest_data_byte_0", 8], 
       in => "dc_data_portb_wr_data[7:0]", 
       enable => "dc_data_wr_byte_0"},
      {out => ["A_dc_latest_data_byte_1", 8], 
       in => "dc_data_portb_wr_data[15:8]", 
       enable => "dc_data_wr_byte_1"},
      {out => ["A_dc_latest_data_byte_2", 8], 
       in => "dc_data_portb_wr_data[23:16]", 
       enable => "dc_data_wr_byte_2"},
      {out => ["A_dc_latest_data_byte_3", 8], 
       in => "dc_data_portb_wr_data[31:24]", 
       enable => "dc_data_wr_byte_3"},

      {out => ["A_dc_latest_data_valid_byte_0", 1], 
       in => "A_en ? dc_data_wr_byte_0
                   : (A_dc_latest_data_valid_byte_0 | dc_data_wr_byte_0)",
       enable => "1'b1"},

      {out => ["A_dc_latest_data_valid_byte_1", 1], 
       in => "A_en ? dc_data_wr_byte_1
                   : (A_dc_latest_data_valid_byte_1 | dc_data_wr_byte_1)",
       enable => "1'b1"},

      {out => ["A_dc_latest_data_valid_byte_2", 1], 
       in => "A_en ? dc_data_wr_byte_2
                   : (A_dc_latest_data_valid_byte_2 | dc_data_wr_byte_2)",
       enable => "1'b1"},

      {out => ["A_dc_latest_data_valid_byte_3", 1], 
       in => "A_en ? dc_data_wr_byte_3
                   : (A_dc_latest_data_valid_byte_3 | dc_data_wr_byte_3)",
       enable => "1'b1"},


      {out => ["A_dc_latest_data_valid", 1], 
       in => "A_en ? dc_data_portb_wr_en
                   : (A_dc_latest_data_valid | dc_data_portb_wr_en)",
       enable => "1'b1"},
      );







    e_signal->adds(
      {name => "M_dc_tag_entry", never_export => 1, width => $dc_tag_data_sz },
      {name => "M_dc_tag_entry_unused", never_export => 1, 
       width => $dc_tag_data_sz },
    );

    e_assign->adds(

      [["dc_line_dirty_on", 1],  "1'b1"],
      [["dc_line_dirty_off", 1], "1'b0"],
      [["dc_line_valid_on", 1],  "1'b1"],
      [["dc_line_valid_off", 1], "1'b0"],


      [["M_dc_dirty", 1], "M_dc_tag_entry[$dc_tag_entry_dirty_lsb]"],
      [["M_dc_valid", 1], "M_dc_tag_entry[$dc_tag_entry_valid_lsb]"],
      [["M_dc_actual_tag", $dc_addr_tag_field_sz], 
        "M_dc_tag_entry[$dc_tag_entry_tag_msb:$dc_tag_entry_tag_lsb]"],
    );

    my $dc_tag_ram_fname = $Opt->{name} . "_dc_tag_ram";



    if (manditory_bool($Opt, "export_large_RAMs")) {
        e_comment->add({
          comment => 
            ("Export dcache tag RAM ports to top level\n" .
             "because the RAM is instantiated external to CPU.\n"),
        });
        e_assign->adds(

          [["dcache_4b_tag_ram_clk_en0", 1], "M_en"],
          [["dcache_4b_tag_ram_address_a", $dc_tag_addr_sz], "E_dc_line"],

          [["dcache_4b_tag_ram_clk_en1", 1], "1'b1"],
          [["dcache_4b_tag_ram_write_enable_b", 1], "dc_tag_portb_wr_en"],
          [["dcache_4b_tag_ram_data_b", $dc_tag_data_sz], "dc_tag_portb_data"],
          [["dcache_4b_tag_ram_address_b", $dc_tag_addr_sz],
            "dc_tag_portb_addr"],


          ["M_dc_tag_entry", 
            ["dcache_4b_tag_ram_q_a_data", $dc_tag_data_sz]],
          ["M_dc_tag_entry_unused", 
            ["dcache_4b_tag_ram_q_b_data", $dc_tag_data_sz]],
        );
    } else {
        nios_tdp_ram->add({
          module => $Opt->{name} . "_dc_tag_module",
          name => $Opt->{name} . "_dc_tag",
          Opt                     => $Opt,
          a_data_width            => $dc_tag_data_sz,
          b_data_width            => $dc_tag_data_sz,
          a_address_width         => $dc_tag_addr_sz,
          b_address_width         => $dc_tag_addr_sz,
          a_num_words             => $dc_tag_num_addrs,
          b_num_words             => $dc_tag_num_addrs,
          contents_file           => $dc_tag_ram_fname,
          intended_device_family  => 
            '"' . not_empty_scalar($Opt, "device_family") . '"',
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
    
          port_map => {

            clock       => "clk",
            clocken0  => "M_en",
            address_a => "E_dc_line",
            q_a       => "M_dc_tag_entry",
    




            clocken1  => "1'b1",
            wren_b    => "dc_tag_portb_wr_en",
            data_b    => "dc_tag_portb_data",
            address_b => "dc_tag_portb_addr",
            q_b       => "M_dc_tag_entry_unused",
            },
        });
    }

    my $do_build_sim = manditory_bool($Opt, "do_build_sim");
    my $simulation_directory = $do_build_sim ? 
        not_empty_scalar($Opt, "simulation_directory") : undef;

    make_contents_file_for_ram({
      filename_no_suffix        => $dc_tag_ram_fname,
      data_sz                   => $dc_tag_data_sz,
      num_entries               => $dc_tag_num_addrs, 
      value_str                 => "random",
      clear_hdl_sim_contents    => 
        manditory_bool($Opt, "hdl_sim_caches_cleared"),
      do_build_sim              => $do_build_sim,
      simulation_directory      => $simulation_directory,
      system_directory          => not_empty_scalar($Opt, "system_directory"),
    });





    if ($mmu_present) {


        e_register->adds(
          {out => ["A_dc_desired_tag", $dc_addr_tag_field_sz], 
           in => "M_dc_desired_tag", enable => "A_en"},
        );


        e_assign->adds(
          [["M_dc_desired_tag", $dc_addr_tag_field_sz],
            "M_mem_baddr_phy[$dc_addr_tag_field_msb:$dc_addr_tag_field_lsb]"],
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



          [["M_M_dc_tag_match", 1], 
            "(M_dc_desired_tag == M_dc_actual_tag) & M_mem_baddr_phy_got_pfn"],
        );      
    } else {
        e_assign->adds(

          [["M_M_dc_tag_match", 1], "M_dc_desired_tag == M_dc_actual_tag"],
        );
    }


    e_assign->adds(

      [["M_dc_line", $dc_addr_line_field_sz],
        "M_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],


      [["M_A_dc_desired_tag_match", 1], "M_dc_desired_tag == A_dc_desired_tag"],






      [["M_A_dc_line_match", 1], "M_dc_line == A_dc_line"],






      [["M_A_dc_latest_line_match", 1], 
        "M_A_dc_line_match & A_dc_latest_data_valid"],
      );






    e_signal->adds(
      {name => "M_dc_rd_data", never_export => 1, 
       width => $dc_data_data_sz },
      {name => "A_dc_rd_data_unused", never_export => 1, 
       width => $dc_data_data_sz },
      );

    e_assign->adds(


      [["E_dc_line", $dc_addr_line_field_sz],
        "E_mem_baddr[$dc_addr_line_field_msb:$dc_addr_line_field_lsb]"],
    );



    if (manditory_bool($Opt, "export_large_RAMs")) {
        e_comment->add({
          comment => 
            ("Export dcache data RAM ports to top level\n" .
             "because the RAM is instantiated external to CPU.\n"),
        });
        e_assign->adds(

          [["dcache_4b_data_ram_clk_en0", 1], "M_en"],
          [["dcache_4b_data_ram_address_a", $dc_data_addr_sz], "E_dc_line"],

          [["dcache_4b_data_ram_clk_en1", 1], "1'b1"],
          ["dcache_4b_data_ram_write_enable_b", "dc_data_portb_wr_en"],
          [["dcache_4b_data_ram_data_b", $dc_data_data_sz], 
            "dc_data_portb_wr_data"],
          [["dcache_4b_data_ram_byteena_b", $byte_en_sz], 
            "dc_data_portb_byte_en"],
          [["dcache_4b_data_ram_address_b", $dc_data_addr_sz], 
            "dc_data_portb_addr"],


          ["M_dc_rd_data", ["dcache_4b_data_ram_q_a_data", $dc_data_data_sz]],
          ["A_dc_rd_data_unused", 
            ["dcache_4b_data_ram_q_b_data", $dc_data_data_sz]],
        );
    } else {
        nios_tdp_ram->add({
          module => $Opt->{name} . "_dc_data_module",
          name => $Opt->{name} . "_dc_data",
          Opt                     => $Opt,
          a_data_width            => $dc_data_data_sz,
          b_data_width            => $dc_data_data_sz,
          a_address_width         => $dc_data_addr_sz,
          b_address_width         => $dc_data_addr_sz,
          a_num_words             => $dc_data_num_addrs,
          b_num_words             => $dc_data_num_addrs,
          intended_device_family  => 
            '"'. not_empty_scalar($Opt, "device_family") .'"',
          read_during_write_mode_mixed_ports => qq("OLD_DATA"),
    
          port_map => {

            clock       => "clk",
            clocken0  => "M_en",
            address_a => "E_dc_line",
            q_a       => "M_dc_rd_data",
    




            clocken1  => "1'b1",
            wren_b    => "dc_data_portb_wr_en",
            data_b    => "dc_data_portb_wr_data",
            byteena_b => "dc_data_portb_byte_en",
            address_b => "dc_data_portb_addr",
            q_b       => "A_dc_rd_data_unused",
            },
        });
    }



























    e_assign->adds(
      [["M_dc_hit", 1], 
        "M_A_dc_latest_line_match ? 
           (M_A_dc_desired_tag_match & ~A_ctrl_dcache_management &
            ~M_ctrl_ld) :
           (M_M_dc_tag_match & M_dc_valid)"],
      );










    e_assign->adds(
      [["M_dc_victim_rd_data_byte_0", 8], 
         "(M_A_dc_latest_line_match & A_dc_latest_data_valid_byte_0) ?
            A_dc_latest_data_byte_0 : M_dc_rd_data[7:0]"],

      [["M_dc_victim_rd_data_byte_1", 8], 
         "(M_A_dc_latest_line_match & A_dc_latest_data_valid_byte_1) ?
            A_dc_latest_data_byte_1 : M_dc_rd_data[15:8]"],

      [["M_dc_victim_rd_data_byte_2", 8], 
         "(M_A_dc_latest_line_match & A_dc_latest_data_valid_byte_2) ?
            A_dc_latest_data_byte_2 : M_dc_rd_data[23:16]"],

      [["M_dc_victim_rd_data_byte_3", 8], 
         "(M_A_dc_latest_line_match & A_dc_latest_data_valid_byte_3) ?
            A_dc_latest_data_byte_3 : M_dc_rd_data[31:24]"],

      [["M_dc_victim_rd_data", $datapath_sz], 
        "{ M_dc_victim_rd_data_byte_3, M_dc_victim_rd_data_byte_2,
           M_dc_victim_rd_data_byte_1, M_dc_victim_rd_data_byte_0 }"],

      [["M_dc_victim_tag", $dc_addr_tag_field_sz], 
        "M_A_dc_latest_line_match ? A_dc_desired_tag : M_dc_actual_tag"],
    );









    e_assign->adds(
      [["M_dc_victim_dirty", 1], 
        "M_A_dc_latest_line_match ? A_ctrl_st : M_dc_dirty"],
      );


























    e_assign->adds(





      [["M_dc_av_wr_req", 1], 
        "M_valid & 
           ((M_sel_data_master &
             ((M_ctrl_ld_st_non_bypass & M_dc_victim_dirty & ~M_dc_hit) | 
              (M_ctrl_st_bypass))) |
            (M_ctrl_dc_wb_inv & M_dc_victim_dirty))"],
    


      [["M_dc_av_rd_req", 1], 
        "M_valid & M_sel_data_master &
         ((~M_dc_hit & M_ctrl_ld_st_non_bypass_non_st32) | M_ctrl_ld_bypass)"],




      [["dc_tag_field_nxt", $dc_addr_tag_field_sz], 
        "(A_ctrl_ld_st_bypass | d_read_nxt) ? 
           A_dc_desired_tag : 
           A_dc_victim_tag"],
   




      [["dc_line_field_nxt", $dc_addr_line_field_paddr_sz], 
        "A_dc_line[$dc_addr_line_field_paddr_sz-1:0]"],
  


      [["dc_byte_field_nxt", $dc_addr_byte_field_sz], 
        "A_ctrl_ld_st_bypass ? 
          A_mem_baddr[$dc_addr_byte_field_msb:$dc_addr_byte_field_lsb] : 
          0"],






      [["d_writedata_nxt", $datapath_sz], 
        "A_ctrl_st_bypass ? A_st_data : A_dc_victim_rd_data"],
      [["d_byteenable_nxt", $byte_en_sz], 
        "A_ctrl_ld_st_bypass ? A_mem_byte_en : $byte_en_all_on"],


      [["d_address_nxt", $data_master_addr_sz],     
        "{dc_tag_field_nxt, dc_line_field_nxt, dc_byte_field_nxt}"],
      );





    my $data_tcm_stall_expr = "";

    if ($advanced_exc && $dtcm_present) {

        e_assign->adds(
          [["A_data_tcm_stall", 1], "M_dtcm_A_st_caused_wrong_readdata"],
        );

        $data_tcm_stall_expr = "| A_data_tcm_stall";
    }

    e_assign->adds(

      [["av_wr_data_transfer", 1], "d_write & ~d_waitrequest"],



      [["av_wr_done_nxt", 1], 
        "A_en ? 0 : (av_wr_done | av_wr_data_transfer)"],



      [["d_write_nxt", 1], "A_dc_av_wr_req & ~av_wr_done & d_waitrequest"],


      [["A_wr_stall", 1], "d_write_nxt"],



      [["av_rd_data_transfer", 1], "d_read & ~d_waitrequest"],






      [["d_read_nxt", 1], 
        "A_dc_av_rd_req & d_waitrequest & ~av_process_readdata &
         ~av_rd_done & ~d_write_nxt"],


      [["A_rd_stall", 1], "A_dc_av_rd_req & ~av_rd_done"],


      [["A_mem_stall", 1], "A_wr_stall | A_rd_stall $data_tcm_stall_expr"],
    );


    $perf_cnt_inc_rd_stall = "A_rd_stall";
    $perf_cnt_inc_wr_stall = "A_wr_stall";

    e_register->adds(



      {out => ["d_writedata", $datapath_sz],    in => "d_writedata_nxt",
       enable => "A_en_d1"},
      {out => ["d_byteenable", $byte_en_sz],    in => "d_byteenable_nxt",
       enable => "A_en_d1"},







      {out => ["d_address", $data_master_addr_sz],  in => "d_address_nxt", 
       enable => "A_en_d1 | d_read_nxt"},



      {out => ["av_wr_done", 1],                in => "av_wr_done_nxt",
       enable => "1'b1"},




      {out => ["av_process_readdata", 1],       in => "av_rd_data_transfer", 
       enable => "1'b1"},


      {out => ["av_rd_done", 1],                in => "av_process_readdata",
       enable => "1'b1"},



      {out => ["A_dc_av_wr_req", 1],            in => "M_dc_av_wr_req",
       enable => "A_en"},
      {out => ["A_dc_av_rd_req", 1],            in => "M_dc_av_rd_req",
       enable => "A_en"},
    );

    my @data_cache = (
      { divider => "data_cache" },
      { radix => "x", signal => "E_dc_line" },
      { radix => "x", signal => "M_st_dcache_management_dc_wr_en" },
      { radix => "x", signal => "M_dc_line" },
      { radix => "x", signal => "M_dc_rd_data" },
      { radix => "x", signal => "M_dc_dirty" },
      { radix => "x", signal => "M_dc_valid" },
      { radix => "x", signal => "M_dc_actual_tag" },
      { radix => "x", signal => "M_dc_desired_tag" },
      { radix => "x", signal => "M_dc_hit" },
      { radix => "x", signal => "M_M_dc_tag_match" },
      { radix => "x", signal => "M_A_dc_desired_tag_match" },
      { radix => "x", signal => "M_A_dc_latest_line_match" },
      { radix => "x", signal => "M_dc_victim_dirty" },
      { radix => "x", signal => "M_dc_victim_rd_data" },
      { radix => "x", signal => "M_dc_av_wr_req" },
      { radix => "x", signal => "M_dc_av_rd_req" },
      { radix => "x", signal => "dc_data_portb_wr_data" },
      { radix => "x", signal => "dc_data_portb_wr_en" },
      { radix => "x", signal => "dc_data_portb_byte_en" },
      { radix => "x", signal => "dc_data_portb_addr" },
      { radix => "x", signal => "dc_tag_field_nxt" },
      { radix => "x", signal => "dc_line_field_nxt" },
      { radix => "x", signal => "dc_byte_field_nxt" },
      { radix => "x", signal => "dc_data_wr_byte_0" },
      { radix => "x", signal => "dc_data_wr_byte_1" },
      { radix => "x", signal => "dc_data_wr_byte_2" },
      { radix => "x", signal => "dc_data_wr_byte_3" },
      { radix => "x", signal => "A_dc_latest_data_byte_0" },
      { radix => "x", signal => "A_dc_latest_data_byte_1" },
      { radix => "x", signal => "A_dc_latest_data_byte_2" },
      { radix => "x", signal => "A_dc_latest_data_byte_3" },
      { radix => "x", signal => "A_dc_latest_data_valid_byte_0" },
      { radix => "x", signal => "A_dc_latest_data_valid_byte_1" },
      { radix => "x", signal => "A_dc_latest_data_valid_byte_2" },
      { radix => "x", signal => "A_dc_latest_data_valid_byte_3" },
      { radix => "x", signal => "A_dc_latest_data_valid" },
      { radix => "x", signal => "A_dc_line" },
      { radix => "x", signal => "A_dc_victim_rd_data" },
      { radix => "x", signal => "A_data_ram_ld_align_fill_bit" },
      { radix => "x", signal => "A_data_ram_ld16_data" },
      { radix => "x", signal => "A_rd_stall" },
      { radix => "x", signal => "A_wr_stall" },
      ($advanced_exc && $dtcm_present) ? 
        { radix => "x", signal => "A_data_tcm_stall" } : 
        "",
      ($advanced_exc && $dtcm_present) ? 
        { radix => "x", signal => "M_dtcm_A_st_caused_wrong_readdata" } :
        "",
      { divider => "data_cache_fill" },
      { radix => "x", signal => "A_en" },
      { radix => "x", signal => "A_dc_fill_wr_en" },
      { radix => "x", signal => "A_dc_fill_wr_data" },
      { radix => "x", signal => "A_dc_fill_line" },
      { radix => "x", signal => "A_dc_fill_byte_en" },
      { radix => "x", signal => "A_dc_fill_wr_tag" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @data_cache);
    }
}

1;
