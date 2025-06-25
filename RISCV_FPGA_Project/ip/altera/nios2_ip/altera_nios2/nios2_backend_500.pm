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






















package nios2_backend_500;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &nios2_be500_make_backend
    &nios2_be500_make_testbench
);

use e_custom_instruction_master;
use cpu_utils;
use cpu_wave_signals;
use cpu_control_reg;
use cpu_control_reg_gen;
use cpu_file_utils;
use cpu_gen;
use cpu_inst_gen;
use cpu_exception_gen;
use europa_all;
use europa_utils;
use e_atlantic_slave;
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
use nios_backend_500;
use nios_icache;
use nios2_isa;
use nios2_insts;
use nios2_control_regs;
use nios2_mmu;
use nios2_mpu;
use nios2_exceptions;
use nios2_common;
use nios2_backend;
use nios2_backend_control_regs;
use nios2_mul;
use nios2_custom_insts;

use strict;











sub 
nios2_be500_make_backend
{
    my $Opt = shift;

    &$progress("    Pipeline backend");




    nios_backend_500::gen_backend_500($Opt);

    be_make_alu($Opt);
    be_make_stdata($Opt);
    be_make_control_regs($Opt);
    be_make_hbreak($Opt);
    if ($cpu_reset) {
        be_make_cpu_reset($Opt);
    }




    make_base_pipeline($Opt);
    make_fetch_npc($Opt);
    make_reg_cmp($Opt);
    make_src_operands($Opt);
    make_alu_controls($Opt);
    if ($eic_present) {
        make_external_interrupt_controller($Opt);
    } else {
        make_internal_interrupt_controller($Opt);
    }

    if ($hw_mul) {
        nios2_mul::gen_mul($Opt);
    }

    if (nios2_custom_insts::has_insts($Opt->{custom_instructions})) {
        make_custom_instruction_master($Opt);
    } else {
        my $is_hw_tcl_core = optional_bool($Opt, "hw_tcl_core");
        if ( $is_hw_tcl_core ) {
           
            my $ci_ports = { no_ci_readra      => "combo_readra", };
            e_custom_instruction_master->add ({
                name     => "custom_instruction_master",
                type_map => $ci_ports,
            });
            
            e_assign->adds([["no_ci_readra", 1], "1'b0"]);
        }
    }

    if ($dcache_present) {
        make_dcache_controls($Opt);
    }

    if ($mmu_present) {
        &$progress("      Micro-DTLB");
        make_tlb_data($Opt);
    } 
    
    if ($mpu_present) {
        &$progress("      DMPU");
        make_dmpu($Opt);
    }

    if ($imprecise_illegal_mem_exc) {
        make_imprecise_illegal_addr_detector($Opt);
    }

    if ($slave_access_error_exc) {
        make_slave_access_error_detector($Opt);
    }

    if (!manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }
}







sub 
nios2_be500_make_testbench
{
    my $Opt = shift;

    &$progress("    Testbench");

    my $whoami = "backend 500 testbench";

    my $cs = check_opt_value($Opt, "control_reg_stage", ["A", "W"], $whoami);
    my $wss = check_opt_value($Opt, "wrctl_setup_stage", ["M", "A"], $whoami);

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

    my $gen_info = manditory_hash($Opt, "gen_info");





    cpu_inst_gen::gen_inst_decodes($gen_info, $Opt->{inst_desc_info},
      ["W"]);





    e_register->adds(
      {out => ["A_target_pcb", $pcb_sz, 0, $force_never_export],
       in => "M_target_pcb",            enable => "A_en"},
      {out => ["A_mem_baddr", $mem_baddr_sz, 0, $force_never_export],
       in => "M_mem_baddr",             enable => "A_en"},
      );

    if ($cs eq "W") {

        e_register->adds(
          {out => ["W_wr_data_filtered", $datapath_sz, 0, $force_never_export], 
           in => "A_wr_data_filtered",  enable => "1'b1"},
          {out => ["W_mem_baddr", $mem_baddr_sz, 0, $force_never_export],
           in => "A_mem_baddr",         enable => "1'b1"},
          {out => ["W_st_data", $datapath_sz, 0, $force_never_export],
           in => "A_st_data",           enable => "1'b1"},
          {out => ["W_mem_byte_en", $byte_en_sz, 0, $force_never_export],
           in => "A_mem_byte_en",       enable => "1'b1"},
          {out => ["W_cmp_result", 1, 0, $force_never_export],
           in => "A_cmp_result",        enable => "1'b1"},
          {out => ["W_target_pcb", $pcb_sz, 0, $force_never_export],
           in => "A_target_pcb",        enable => "1'b1"},
        );
        if ($rf_ecc_present) {
            e_register->adds(
              {out => ["W_rf_injected_wr_data", $datapath_sz, 0, 
               $force_never_export], 
               in => "A_rf_injected_wr_data",  enable => "1'b1"},
            );
        }
    }

    if ($advanced_exc) {
        my $A_hbreak_exc_nxt = $hbreak_present ? 
          get_exc_nxt_signal_name($hbreak_exc, "A") : "0";
        my $A_cpu_reset_exc_nxt = $cpu_reset ?
          get_exc_nxt_signal_name($cpu_reset_exc, "A") : "0";
        my $A_intr_exc_nxt = get_exc_nxt_signal_name(
          ($eic_present ? $ext_intr_exc : $norm_intr_exc), "A");


        e_register->adds(
          {out => ["A_valid_hbreak", 1, 0, $force_never_export],
           in => "M_exc_allowed & $A_hbreak_exc_nxt", 
           enable => "A_en"},

          {out => ["W_valid_hbreak", 1, 0, $force_never_export],
           in => "A_valid_hbreak", 
           enable => "1'b1"},

          {out => ["A_valid_crst", 1, 0, $force_never_export],
           in => "M_exc_allowed & $A_cpu_reset_exc_nxt", 
           enable => "A_en"},

          {out => ["W_valid_crst", 1, 0, $force_never_export],
           in => "A_valid_crst", 
           enable => "1'b1"},

          {out => ["A_valid_intr", 1, 0, $force_never_export],
           in => "M_exc_allowed & $A_intr_exc_nxt", 
           enable => "A_en"},

          {out => ["W_valid_intr", 1, 0, $force_never_export],
           in => "A_valid_intr", 
           enable => "1'b1"},

          {out => ["W_exc_any_active", 1, 0, $force_never_export],
           in => "A_exc_any_active", 
           enable => "1'b1"},
        );

        if ($extra_exc_info) {
            e_register->adds(
              {out => ["W_exc_highest_pri_exc_id", 32, 0, $force_never_export],
               in => "A_exc_highest_pri_exc_id", 
               enable => "1'b1"},
            );
        }

        if ($mmu_present) {

            my $inst_baddr_width = manditory_int($Opt, "i_Address_Width");
            my $data_addr_phy_sz  = manditory_int($Opt, "d_Address_Width");
    

            e_register->adds(
              {out => ["E_pcb_phy", $inst_baddr_width, 0, $force_never_export], 
               in => "D_pcb_phy", enable => "E_en", ip_debug_visible => 1},
              {out => ["M_pcb_phy", $inst_baddr_width, 0, $force_never_export], 
               in => "E_pcb_phy", enable => "M_en"},
              {out => ["A_pcb_phy", $inst_baddr_width, 0, $force_never_export], 
               in => "M_pcb_phy", enable => "A_en"},
              {out => ["W_pcb_phy", $inst_baddr_width, 0, $force_never_export], 
               in => "A_pcb_phy", enable => "1'b1"},
              {out => ["W_exc_fast_tlb_miss", 1, 0, $force_never_export], 
               in => "A_exc_fast_tlb_miss", enable => "1'b1"},
              {out => ["W_mem_baddr_phy", $data_addr_phy_sz, 0, 
                $force_never_export], in => "A_mem_baddr_phy", 
                enable => "1'b1"},
            );
        }

        if ($eic_present) {

            e_register->adds(
              {out => ["M_tb_eic_port_data", $eic_port_sz], 
               in => "eic_port_data", 
               enable => "M_en"},
              {out => ["A_tb_eic_port_data", $eic_port_sz], 
               in => "M_tb_eic_port_data", 
               enable => "A_en"},
              {out => ["W_tb_eic_port_data", $eic_port_sz], 
               in => "A_tb_eic_port_data", 
               enable => "W_en"},
            );


            e_assign->adds(
               [["W_tb_eic_ril", $eic_port_ril_sz], 
                 "W_tb_eic_port_data[$eic_port_ril_msb:$eic_port_ril_lsb]"],
               [["W_tb_eic_rnmi", $eic_port_rnmi_sz],
                 "W_tb_eic_port_data[$eic_port_rnmi_lsb]"],
               [["W_tb_eic_rrs", $eic_port_rrs_sz],
                 "W_tb_eic_port_data[$eic_port_rrs_msb:$eic_port_rrs_lsb]"],
               [["W_tb_eic_rha", $eic_port_rha_sz],
                 "W_tb_eic_port_data[$eic_port_rha_msb:$eic_port_rha_lsb]"],
            );

            if ($shadow_present) {
                e_register->adds(
                  {out => ["W_tb_sstatus_reg", 32], 
                   in => "${cs}_sstatus_reg_nxt", 
                   enable => "W_en"},
                );
            }
        }
    }








    if (manditory_bool($Opt, "simgen")) {
        make_potential_tb_logic($Opt);
    }

    my @x_signals = (
      { sig => "W_wr_dst_reg",                             },
      { sig => "W_dst_regnum", qual => "W_wr_dst_reg",     },
      { sig => "W_valid",                                  },
      { sig => "W_pcb",        qual => "W_valid",          },
      { sig => "W_iw",         qual => "W_valid",          },
      { sig => "A_en",                                     },
    );

    if ($shadow_present) {
        push(@x_signals,
          { sig => "W_dst_regset", qual => "W_wr_dst_reg", },
        );
    }

    if ($eic_present) {
        push(@x_signals,
          { sig => "eic_port_valid", },
          { sig => "eic_port_data_ril", 
            qual => "eic_port_valid" },
          { sig => "eic_port_data_rnmi", 
            qual => "eic_port_valid & (eic_port_data_ril != 0)" },
          { sig => "eic_port_data_rha", 
            qual => "eic_port_valid & (eic_port_data_ril != 0)" },
        );

        if ($shadow_present) {
            push(@x_signals,
              { sig => "eic_port_data_rrs", 
                qual => "eic_port_valid & (eic_port_data_ril != 0)" },
            );
        }
    }

    if (!$advanced_exc) {


        push(@x_signals,
          { sig => "E_valid",                               },
        );
    }

    push(@x_signals,
      { sig => "M_valid",                                   },
      { sig => "A_valid",                                   },
      { sig => "A_wr_data_unfiltered",    
        qual => "A_valid & A_en & A_wr_dst_reg",
        warn => 1,                                          },
        { sig => "${cs}_status_reg",                        },
      { sig => "${cs}_estatus_reg",                         },
      { sig => "${cs}_bstatus_reg",                         },
    );

    if ($exception_reg) {
        push(@x_signals,
          { sig => "${cs}_exception_reg",                   },
        );
    }
    if ($extra_exc_info) {
        push(@x_signals,
          { sig => "${cs}_badaddr_reg",                     },
        );
    }

    if ($advanced_exc) {
        if ($mmu_present) {
            push(@x_signals,
              { sig => "${cs}_ienable_reg",                 },
              { sig => "${cs}_pteaddr_reg",                 },
              { sig => "${cs}_tlbacc_reg",                  },
              { sig => "${cs}_tlbmisc_reg",                 },
            );
        } elsif ($mpu_present) {
            push(@x_signals,
              { sig => "${cs}_config_reg",                  },
              { sig => "${cs}_mpubase_reg",                 },
              { sig => "${cs}_mpuacc_reg",                  },
            );
        }

        push(@x_signals,
          { sig => "A_exc_any_active",                      },
        );
    }

    if ($instruction_master_present) {
        push(@x_signals,
          { sig => "i_read",                                },
          { sig => "i_address",    qual => "i_read",        },
          { sig => "i_readdatavalid",                       },
        );
    }

    if ($data_master_present) {
        push(@x_signals,
          { sig => "d_write",                                   },
          { sig => "d_byteenable", qual => "d_write",           },
          { sig => "d_address",    qual => "d_write | d_read",  },
          { sig => "d_read",                                    },
        );
    }

    for (my $cmi = 0; 
      $cmi < manditory_int($Opt, "num_tightly_coupled_data_masters"); $cmi++) {
        push(@x_signals,
          { sig => "dcm${cmi}_write",                                },
          { sig => "dcm${cmi}_address",    qual => "dcm${cmi}_write", },
        );

        if (!$ecc_present) {
            push(@x_signals,
              { sig => "dcm${cmi}_byteenable", qual => "dcm${cmi}_write", },
            );     
        }
    }

    if ($ecc_present) {
        push(@x_signals,
          { sig => "ecc_event_bus", },
        );
    }

    e_signal->adds(

      {name => "A_target_pcb", width => $pcb_sz},



      {name => "A_wr_data_filtered", width => $datapath_sz, 
       export => $force_export},
    );

    my $x_filter_qual = 
      $dcache_present ? "A_ctrl_ld_non_bypass" : "A_ctrl_ld_non_io";

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

    if (not_empty_scalar($Opt, "branch_prediction_type") eq "Dynamic") {
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

        if ($advanced_exc && !manditory_bool($Opt, "asic_enabled")) {





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
        } else {

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
        }
    }

    my $display = $NIOS_DISPLAY_INST_TRACE | $NIOS_DISPLAY_MEM_TRAFFIC;
    my $use_reg_names = "1";

    my $test_end_expr;

    if (manditory_bool($Opt, "activate_monitors")) {
        create_x_checkers(\@x_signals);
    }

    if (manditory_bool($Opt, "activate_test_end_checker")) {
        my $inst_done_expr = $cs eq "W" ? "W_valid" : "(A_valid & A_en)";






        $test_end_expr = 
          "$inst_done_expr & (
            ${cs}_sim_reg_stop |
            (${cs}_op_cmpltui & (${cs}_iw_a == 0) & (${cs}_iw_b == 0) &
              ((${cs}_iw_imm16 == 16'habc1) | (${cs}_iw_imm16 == 16'habc2))))";
    }

    my $pc = "${cs}_pcb";
    my $dstRegVal = ($ecc_present && $rf_ecc_present) ? 
        "${cs}_rf_injected_wr_data" : 
        "${cs}_wr_data_filtered";

    my $crst_active = $advanced_exc ? 
      "${cs}_valid_crst": 
      "(${cs}_op_crst & ${cs}_valid)";

    my $reset_entry = {
        hard_reset_expr => "~reset_n",
        cpu_only_reset_expr => $cpu_reset ? $crst_active : undef,
    };

    my $crst_active = $advanced_exc ? "${cs}_valid_crst": "${cs}_op_crst";
    my $intr_active = $advanced_exc ? "${cs}_valid_intr": "${cs}_op_intr";
    my $hbreak_active = $advanced_exc ? "${cs}_valid_hbreak": "${cs}_op_hbreak";

    my $iw_valid_expr;
    if ($advanced_exc) {
        my $stages = manditory_array($gen_info, "stages");
        my $d_stage_or_later = 0;

        foreach my $stage (@$stages) {
            if ($stage eq "D") {
                $d_stage_or_later = 1;
            }

            if ($d_stage_or_later) {








                new_exc_combo_signal({
                    name                => "${stage}_exc_inst_fetch",
                    stage               => $stage,
                    invalidates_inst_value          => 1,
                });
            }
        }




        e_assign->adds(
          ["${wss}_iw_invalid", 
            "${wss}_exc_inst_fetch & ${wss}_exc_active_no_break_no_crst"],
        );

        e_register->adds(
          {out => ["${cs}_iw_invalid", 1, 0, $force_never_export], 
           in => "${wss}_iw_invalid",  enable => "1'b1"},
        );

        $iw_valid_expr = "~${cs}_iw_invalid";
    } else {



        $iw_valid_expr = "~($intr_active | $hbreak_active)";
    }

    my $dstRegEccTestPort_expr = undef;
    
    if ($rf_ecc_present && $ecc_test_ports_present) {
        e_register->adds(
          {out => ["W_ecc_test_rf", $datapath_sz, 0, $force_never_export], 
           in => "ecc_test_rf[$datapath_sz-1:0]",  enable => "1'b1"},
        );
        $dstRegEccTestPort_expr = "W_ecc_test_rf";
    }

    my $hbreak_entry = {
        condition   => $advanced_exc ?
                         "${cs}_valid_hbreak" :
                         "(${cs}_op_hbreak & ${cs}_valid)",
        pc          => $pc,
        dstRegWr    => "${cs}_wr_dst_reg",
        dstRegNum   => "${cs}_dst_regnum",
        dstRegVal   => $dstRegVal,
        dstRegSet   => $shadow_present ? "${cs}_dst_regset" : undef,
        dstRegEccTestPort => $dstRegEccTestPort_expr,
    };

    my $intr_entry = {
        condition   => $advanced_exc ? 
                         "${cs}_valid_intr": 
                         "(${cs}_op_intr & ${cs}_valid)",
        pc          => $pc,
        dstRegWr    => "${cs}_wr_dst_reg",
        dstRegNum   => "${cs}_dst_regnum",
        dstRegVal   => $dstRegVal,
        dstRegSet   => $shadow_present ? "${cs}_dst_regset" : undef,
        dstRegEccTestPort => $dstRegEccTestPort_expr,
        wrSstatus   => $eic_and_shadow ? "W_exc_wr_sstatus" : undef,
        sstatus     => $eic_and_shadow ? "W_tb_sstatus_reg" : undef,
        ril         => $eic_present ? "W_tb_eic_ril" : undef,
        rnmi        => $eic_present ? "W_tb_eic_rnmi" : undef,
        rrs         => $eic_present ? "W_tb_eic_rrs" : undef,
        rha         => $eic_present ? "W_tb_eic_rha" : undef,
    };
    
    my $inst_entry = {
        condition   => $advanced_exc ? "W_valid || W_exc_any_active" : 
                       ($cs eq "W")  ? "W_valid" :
                                       "A_valid & A_en",
        exc         => $extra_exc_info ? "W_exc_any_active ? W_exc_highest_pri_exc_id : 0" :
                       $advanced_exc   ? "W_exc_any_active" :
                       ($cs eq "W")    ? "(W_ctrl_exception | W_ctrl_break)" :
                                         "(A_ctrl_exception | A_ctrl_break)",
        excHandler  => $mmu_present ? 
                         "${cs}_exc_fast_tlb_miss ? 
                           $exc_handler_fast_tlb_miss :
                           $exc_handler_general" :
                         undef,
        pc          => $pc,
        pcPhy       => $mmu_present ? "${cs}_pcb_phy" : undef,
        ivValid     => $iw_valid_expr,
        iv          => "${cs}_iw",
        dstRegWr    => "${cs}_wr_dst_reg",
        dstRegNum   => "${cs}_dst_regnum",
        dstRegVal   => $dstRegVal,
        dstRegSet   => $shadow_present ? "${cs}_dst_regset" : undef,
        dstRegEccTestPort => $dstRegEccTestPort_expr,
        memAddr     => "${cs}_mem_baddr",
        memAddrPhy  => $mmu_present ? "${cs}_mem_baddr_phy" : undef,
        stData      => "${cs}_st_data",
        stByteEn    => "${cs}_mem_byte_en",
        pass        => "${cs}_cmp_result",
        targetPC    => "${cs}_target_pcb",
    };





    if ($pteaddr_reg) {
        set_control_reg_need_testbench_version($pteaddr_reg, 1);
    }
    if ($tlbacc_reg) {
        set_control_reg_need_testbench_version($tlbacc_reg, 1);
    }
    if ($tlbmisc_reg) {
        set_control_reg_need_testbench_version($tlbmisc_reg, 1);
    }
    if ($mpubase_reg) {
        set_control_reg_need_testbench_version($mpubase_reg, 1);
    }
    if ($mpuacc_reg) {
        set_control_reg_need_testbench_version($mpuacc_reg, 1);
    }

    my $cpu_info = {
        CpuCoreName     => "NiosII/f",
        CpuInstanceName => not_empty_scalar($Opt, "name"),
        CpuArchName     => "Nios2",
        CpuArchRev      => "R1",
    };

    create_rtl_trace_and_testend({
      activate_trace    => manditory_bool($Opt, "activate_trace"),
      filename_base     => not_empty_scalar($Opt, "name"),
      reset_entry       => $reset_entry,
      intr_entry        => $intr_entry,
      hbreak_entry      => $hbreak_entry,
      inst_entry        => $inst_entry,
      control_regs      => manditory_array($Opt, "control_regs"),
      control_reg_stage => $cs,
      extra_exc_info    => $extra_exc_info,
      cpu_info          => $cpu_info,
      test_end_expr     => $test_end_expr,
    });




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

    return $submodule;
}





sub 
make_base_pipeline
{
    my $Opt = shift;

    my $whoami = "backend 500 base pipeline";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");


    e_signal->adds({name => "D_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "E_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "M_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "A_pcb", never_export => 1, width => $pcb_sz});
    e_signal->adds({name => "W_pcb", never_export => 1, width => $pcb_sz});

    e_assign->adds(["D_pcb", "{D_pc, 2'b00}"]);
    e_register->adds(
      {out => "E_pcb",             in => "D_pcb",         enable => "E_en"},
      {out => "M_pcb",             in => "E_pcb",         enable => "M_en"},
      {out => "A_pcb",             in => "M_pcb",         enable => "A_en",
       ip_debug_visible => 1},
      {out => "W_pcb",             in => "A_pcb",         enable => "1'b1",
       ip_debug_visible => $advanced_exc},
      );

    if (manditory_bool($Opt, "export_pcb")) {

        e_signal->adds(
          {name => "pc", width => $pcb_sz, export => $force_export },
          {name => "pc_valid", width => 1, export => $force_export },
        );

        push(@{$Opt->{port_list}},
          ["pc"         => $pcb_sz, "out" ],
          ["pc_valid"   => 1,      "out" ],
        );


        e_assign->adds(
          ["pc", "W_pcb"],
          ["pc_valid", "W_valid"],
        );
    }

    my @advanced_exc_wave_signals;
    my @data_ecc_event_bus_waves;












    e_assign->adds(
      [["D_stall", 1], "D_dep_stall | D_rdprs_stall | E_stall"],
      [["D_en", 1], "~D_stall"],        


      [["D_dep_stall", 1], "D_data_depend & D_issue & ~M_pipe_flush"],

      [["D_issue_rdprs", 1], 
        $shadow_present ? "D_issue & D_ctrl_rdprs" : "0"],


      [["D_rdprs_stall_unfiltered", 1], 
        "D_issue_rdprs & ~D_rdprs_stall_done & ~M_pipe_flush"],





      [["D_rdprs_stall_done_nxt", 1], 
        "M_pipe_flush        ? 0 :
         D_rdprs_stall_done  ? E_stall :
                               D_issue_rdprs"],
      );

    if ($advanced_exc) {








        new_exc_combo_signal({
            name                    => "D_exc_invalidates_inst_value",
            stage                   => "D",
            invalidates_inst_value  => 1,
        });




        create_x_filter({
          lhs       => "D_rdprs_stall",
          rhs       => "D_rdprs_stall_unfiltered",
          sz        => 1,
          qual_expr => "D_exc_invalidates_inst_value",
        });
    } else {
        e_assign->adds(
          [["D_rdprs_stall", 1], "D_rdprs_stall_unfiltered"],
        );
    }


    e_signal->adds({name => "D_pc_plus_one", never_export => 1, 
      width => $pc_sz});

    e_register->adds(
      {out => ["D_iw", $iw_sz],                 in => "${ds}_iw",     
       enable => "D_en"},
      {out => ["D_pc", $pc_sz],                 in => "${ds}_pc", 
       enable => "D_en"},
      {out => "D_pc_plus_one",                  in => "${ds}_pc_plus_one",
       enable => "D_en"},
      {out => ["D_rdprs_stall_done", 1],        in => "D_rdprs_stall_done_nxt",
       enable => "1"},
      );





    e_assign->adds(






      [["D_valid", 1], 
        "D_issue & ~D_data_depend & ~D_rdprs_stall & ~M_pipe_flush"],
    );








    if ($pc_sz > $iw_imm26_sz) {
        e_assign->adds(
          [["D_jmp_direct_target_waddr", $pc_sz], 
            "{D_pc[$pc_sz-1:$iw_imm26_sz], D_iw[$iw_imm26_msb:$iw_imm26_lsb]}"],
        );
    } else {
        e_assign->adds(
          [["D_jmp_direct_target_waddr", $pc_sz], 
            "D_iw[$iw_imm26_msb:$iw_imm26_lsb]"],
        );
    }


    e_signal->adds({name => "D_jmp_direct_target_baddr", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["D_jmp_direct_target_baddr", 
     "{D_jmp_direct_target_waddr, 2'b00}"]);





    e_assign->adds(




      [["D_extra_pc", $pc_sz], 
        "D_br_pred_not_taken ? D_br_taken_waddr : 
                               D_pc_plus_one"],
    );


    e_signal->adds({name => "D_extra_pcb", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["D_extra_pcb", "{D_extra_pc, 2'b00}"]);







    e_assign->adds(
      [["E_stall", 1], "M_stall"],


      [["E_en", 1], "~E_stall"],        
      );


    e_signal->adds({name => "E_valid_jmp_indirect", never_export => 1, 
      width => 1});


    e_register->adds(
      {out => ["E_valid_from_D", 1],        in => "D_valid",
       enable => "E_en"},
      {out => ["E_iw", $iw_sz],             in => "D_iw", 
       enable => "E_en"},
      {out => ["E_dst_regnum", $regnum_sz], in => "D_dst_regnum", 
       enable => "E_en" },
      {out => ["E_wr_dst_reg_from_D", 1],   in => "D_wr_dst_reg", 
       enable => "E_en"},
      {out => ["E_extra_pc", $pc_sz],       in => "D_extra_pc", 
       enable => "E_en"},
      {out => ["E_pc", $pc_sz],             in => "D_pc", 
       enable => "E_en"},
      {out => "E_valid_jmp_indirect",  
       in => "D_ctrl_jmp_indirect & D_valid", enable => "E_en"},
      );

    if ($mmu_present) {
        my $E_tlb_inst_miss_exc =
          get_exc_signal_name($tlb_inst_miss_exc, "E");

        e_assign->adds(
          [["E_mem_baddr_user_region", 1],
            "E_mem_baddr[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
              == $mmu_addr_user_region"],
          [["E_mem_baddr_supervisor_region", 1], "~E_mem_baddr_user_region"],




          [["E_valid_uitlb_lru_access", 1], 
            "E_valid_from_D & ~E_pc_bypass_tlb & ~$E_tlb_inst_miss_exc"],
        );

        e_register->adds(
          {out => ["E_pc_bypass_tlb", 1],
           in => "D_pc_bypass_tlb",     enable => "E_en"},
          {out => ["E_uitlb_index", $uitlb_index_sz],
           in => "D_uitlb_index",       enable => "E_en"},
        );
    }


    e_signal->adds({name => "E_extra_pcb", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["E_extra_pcb", "{E_extra_pc, 2'b00}"]);







    
    my @E_iw_corrupt_inputs;
    if ($ic_ecc_present && $icache_present) {
        push(@E_iw_corrupt_inputs, "E_ic_ecc_err");
    }

    if ($itcm_ecc_present) {
        for (my $cmi = 0; 
          $cmi < manditory_int($Opt, "num_tightly_coupled_instruction_masters");
          $cmi++) {
            push(@E_iw_corrupt_inputs, "E_icm${cmi}_one_bit_err");
        }
    }

    e_assign->adds(
      [["E_iw_corrupt", 1], scalar(@E_iw_corrupt_inputs) ? join('|', @E_iw_corrupt_inputs) : "0"],
    );
    e_register->adds(
      {out => ["M_iw_corrupt", 1, 0, $force_never_export],
       in => "E_iw_corrupt",     enable => "M_en"},
    );

    if ($advanced_exc) {

        new_exc_signal({
            exc             => $trap_inst_exc,
            initial_stage   => "E", 
            speedup_stage   => "E",
            rhs             => "E_op_trap & !E_iw_corrupt",
        });


        new_exc_signal({
            exc             => $unimp_inst_exc,
            initial_stage   => "E", 
            speedup_stage   => "E",
            rhs             => "E_ctrl_unimp_trap & !E_iw_corrupt",
        });


        new_exc_signal({
            exc             => $break_inst_exc,
            initial_stage   => "E", 
            speedup_stage   => "E",
            rhs             => "E_op_break & !E_iw_corrupt",
        });

        push(@advanced_exc_wave_signals,
          get_exc_signal_wave($trap_inst_exc, "E"),
          get_exc_signal_wave($unimp_inst_exc, "E"),
          get_exc_signal_wave($break_inst_exc, "E"),
        );

        if (manditory_bool($Opt, "reserved_instructions_trap")) {

            new_exc_signal({
                exc             => $illegal_inst_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => "E_ctrl_illegal & !E_iw_corrupt",
            });

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($illegal_inst_exc, "E"));
        }

        if ($mmu_present || $mpu_present) {


            new_exc_signal({
                exc             => $supervisor_inst_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => 
                  "E_ctrl_supervisor_only & ${cs}_status_reg_u & !E_iw_corrupt",
            });

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($supervisor_inst_exc, "E"),
            );
        }
    
        if ($mmu_present) {


            new_exc_signal({
                exc             => $supervisor_data_addr_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => "E_ctrl_mem_data_access & !E_mem_baddr_corrupt &
                  E_mem_baddr_supervisor_region & ${cs}_status_reg_u",
            });

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($tlb_inst_miss_exc, "E"),
              get_exc_signal_wave($tlb_x_perm_exc, "E"),
              get_exc_signal_wave($supervisor_inst_addr_exc, "E"),
              get_exc_signal_wave($supervisor_data_addr_exc, "E"),
            );
        }

        if ($illegal_mem_exc) {

            new_exc_signal({
                exc             => $misaligned_data_addr_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => 
                  "!E_mem_baddr_corrupt & ((E_ctrl_mem32 & (E_mem_baddr[1:0] != 2'b00)) |
                                           (E_ctrl_mem16 & (E_mem_baddr[0]   != 1'b0)))",
            });
    

            new_exc_signal({
                exc             => $misaligned_target_pc_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => 
                  "(E_ctrl_jmp_indirect & (E_src1[1:0] != 2'b00) & !E_src1_corrupt) |
                   (E_ctrl_br & (E_iw_imm16[1:0] != 2'b00) & !E_iw_corrupt)",
            });
    
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($misaligned_data_addr_exc, "E"),
              get_exc_signal_wave($misaligned_target_pc_exc, "E"),
            );
        }

        if ($division_error_exc) {
            new_exc_signal({
                exc             => $div_error_exc,
                initial_stage   => "E", 
                speedup_stage   => "E",
                rhs             => 
                  "(E_ctrl_div & (E_src2 == 0) & !E_src2_corrupt) |
                   (E_op_div & (E_src1 == 32'h80000000) & !E_src1_corrupt &
                               (E_src2 == 32'hffffffff) & !E_src2_corrupt)",
            });

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($div_error_exc, "E"),
            );
        }
    } 





    e_assign->adds(


      [["E_valid", 1], "E_valid_from_D & ~E_cancel"],



      [["E_wr_dst_reg", 1], "E_wr_dst_reg_from_D & ~E_cancel"],
    );
    

    if (manditory_bool($Opt, "export_vectors")) {
        e_port->adds(["reset_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["exception_vector_word_addr", $pc_sz, "in"]);
        e_port->adds(["break_vector_word_addr", $pc_sz, "in"]);
        if ($mmu_present) {
            e_port->adds(["fast_tlb_miss_vector_word_addr", $pc_sz, "in"]);
        }
    }

    if ($advanced_exc) {
        e_assign->adds(


          [["E_cancel", 1], "M_pipe_flush"],





          [["M_pipe_flush_nxt", 1], "E_br_mispredict | A_pipe_flush_nxt"],

          [["M_pipe_flush_waddr_nxt", $pc_sz], "E_extra_pc"],
        );
    } else {
        e_assign->adds(


          [["E_valid_prior_to_hbreak", 1], "E_valid_from_D & ~M_pipe_flush"],



          [["E_cancel", 1], "M_pipe_flush | E_hbreak_req"],










          [["M_pipe_flush_nxt", 1], 
            "E_br_mispredict | 
             (E_valid & E_ctrl_flush_pipe_always) |
             (E_valid_prior_to_hbreak & E_hbreak_req)"],












          [["M_pipe_flush_waddr_nxt", $pc_sz],
            "E_hbreak_req        ? E_pc                       :
             E_ctrl_jmp_indirect ? E_src1[$pcb_sz-1:2]        :
             E_ctrl_crst         ? " .
                (manditory_bool($Opt, "export_vectors") ? 
                "reset_vector_word_addr" :
                manditory_int($Opt, "reset_word_addr") ).      ":
             E_ctrl_exception    ? " .
                (manditory_bool($Opt, "export_vectors") ? 
                "exception_vector_word_addr" :
                manditory_int($Opt, "general_exception_word_addr") ). ":
             E_ctrl_break        ? " .
                (manditory_bool($Opt, "export_vectors") ? 
                "break_vector_word_addr" :
                manditory_int($Opt, "break_word_addr") ).      ":
                E_extra_pc"],
        );
    }


    e_signal->adds({name => "M_pipe_flush_baddr_nxt", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["M_pipe_flush_baddr_nxt", 
      "{M_pipe_flush_waddr_nxt, 2'b00}"]);








    my $cmp_mem_baddr_sz = 
      $mmu_present ? 32 : manditory_int($Opt, "d_Address_Width");

    my $avalon_master_info = manditory_hash($Opt, "avalon_master_info");


    my @sel_signals = make_master_address_decoder({
      avalon_master_info    => $avalon_master_info,
      normal_master_name    => ($data_master_present ? "data_master" : ""), 
      tightly_coupled_master_names => manditory_array($avalon_master_info,
        "avalon_tightly_coupled_data_master_list"), 
      addr_signal           => "E_mem_baddr[$cmp_mem_baddr_sz-1:0]",
      addr_sz               => $cmp_mem_baddr_sz, 
      sel_prefix            => "E_sel_",
      mmu_present           => $mmu_present,
      master_paddr_mapper_func => \&nios2_mmu::master_paddr_mapper,
    });







    e_assign->adds(
      [["M_stall", 1], "A_stall"],


      [["M_en", 1], "~M_stall"],        
    );

    e_signal->adds(


      {name => "M_cmp_result", never_export => 1, width => 1},
      {name => "M_target_pcb", never_export => 1, width => $pcb_sz},
    );

    e_register->adds(
      {out => ["M_valid_from_E", 1],                in => "E_valid",
       enable => "M_en"},
      {out => ["M_iw",  $iw_sz],                    in => "E_iw",
       enable => "M_en"},
      {out => ["M_mem_byte_en", $byte_en_sz],       in => "E_mem_byte_en",
       enable => "M_en", },
      {out => ["M_alu_result", $datapath_sz],       in => "E_alu_result",
       enable => "M_en"},
      {out => ["M_st_data", $datapath_sz],          in => "E_st_data",
       enable => "M_en"},
      {out => ["M_dst_regnum", $regnum_sz],         in => "E_dst_regnum",
       enable => "M_en"},
      {out => "M_cmp_result",                       in => "E_cmp_result",
       enable => "M_en"},
      {out => ["M_wr_dst_reg_from_E", 1],           in => "E_wr_dst_reg",
       enable => "M_en"},
      {out => "M_target_pcb",                       in => "E_src1[$pcb_sz-1:0]",
       enable => "M_en"},



      {out => ["M_pipe_flush", 1],               in => "M_pipe_flush_nxt",
       enable => "M_en", async_value => "1'b1" },
      {out => ["M_pipe_flush_waddr", $pc_sz],    in => "M_pipe_flush_waddr_nxt",
       enable => "M_en", async_value => 
         (manditory_bool($Opt, "export_vectors") ? 
           "reset_vector_word_addr" : 
           "$reset_pc")},
      );


    foreach my $master (@{$Opt->{avalon_data_master_list}}) {
        e_register->adds(
          {out => ["M_sel_${master}", 1, 0, $force_never_export],
           in => "E_sel_${master}", enable => "M_en"},
        );
    }

    if ($advanced_exc) {
        e_register->adds(
          {out => ["M_pc", $pc_sz], in => "E_pc", enable => "M_en"},

          {out => ["M_pc_plus_one", $pc_sz],     in => "E_pc + 1",
           enable => "M_en"},
        );

        if ($hbreak_present) {


            e_register->adds(
              {out => ["M_hbreak_req", 1], in => "E_hbreak_req", 
               enable => "M_en"},
            );
        
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($hbreak_exc, "M"));
        }

        if ($cpu_reset) {





            e_register->adds(
              {out => ["M_cpu_resetrequest", 1], 
               in => ($hbreak_present ? 
                 "(cpu_resetrequest & hbreak_enabled)" : 
                 "cpu_resetrequest"),
               enable => "M_en" },
            );

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($cpu_reset_exc, "M"));
        }

        push(@advanced_exc_wave_signals,
          get_exc_signal_wave(
            $eic_present ? $ext_intr_exc : $norm_intr_exc, "M"),
          get_exc_signal_wave($break_inst_exc, "M"),
        );


        if ($mmu_present || $mpu_present) {
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($supervisor_inst_exc, "M"),
            );
        }

        if ($mmu_present) {
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($supervisor_inst_addr_exc, "M"),
              get_exc_signal_wave($tlb_inst_miss_exc, "M"),
              get_exc_signal_wave($tlb_x_perm_exc, "M"),
              get_exc_signal_wave($break_inst_exc, "E"),
            );
        }
    }


    e_signal->adds({name => "M_pipe_flush_baddr", never_export => 1, 
      width => $pcb_sz});
    e_assign->adds(["M_pipe_flush_baddr", "{M_pipe_flush_waddr, 2'b00}"]);

    e_assign->adds(


      [["M_mem_baddr", $mem_baddr_sz], "M_alu_result[$mem_baddr_sz-1:0]"],
    );




 
    if ($advanced_exc) {
        if ($hbreak_present) {



            new_exc_signal({
                exc             => $hbreak_exc,
                initial_stage   => "M", 
                rhs             => "M_hbreak_req",
            });
        }

        if ($cpu_reset) {



            new_exc_signal({
                exc             => $cpu_reset_exc,
                initial_stage   => "M", 
                rhs             => "M_cpu_resetrequest",
            });

            my $A_crst_exc_nxt =
              get_exc_nxt_signal_name($cpu_reset_exc, "A");






            e_assign->adds([["M_exc_crst", 1], "$A_crst_exc_nxt"]);

            push(@advanced_exc_wave_signals,
              { radix => "x", signal => "M_exc_crst" },
            );
        } else {
            e_assign->adds([["M_exc_crst", 1, 0, $force_never_export], "0"]);
        }

        if ($eic_present) {



            new_exc_signal({
                exc             => $ext_intr_exc,
                initial_stage   => "M", 
                rhs             => "M_ext_intr_req",
            });

            e_assign->adds(





              [["M_exc_ext_intr", 1],
                get_exc_nxt_signal_name($ext_intr_exc, "A")],
            );

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($ext_intr_exc, "M"),
              { radix => "x", signal => "M_exc_ext_intr" },
            );
        } else {



            new_exc_signal({
                exc             => $norm_intr_exc,
                initial_stage   => "M", 
                rhs             => "M_norm_intr_req",
            });

            e_assign->adds(

              [["M_exc_ext_intr", 1, 0, $force_never_export], "0"],
            );

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($norm_intr_exc, "M"),
            );
        }

        if ($ecc_present) {         
            if ($rf_ecc_present) {





                new_exc_signal({
                    exc             => $ecc_rf_error_exc,
                    initial_stage   => "M", 
                    rhs             => "W_ecc_exc_enabled & M_rf_raw_unrecoverable_ecc_err & !M_iw_corrupt",
                });

                my $A_ecc_rf_error_exc = get_exc_signal_name($ecc_rf_error_exc, "A");
               
                e_assign->adds(



                  [["A_exc_ecc_rf_error_active", 1], "A_exc_allowed & $A_ecc_rf_error_exc"],
                );



                new_exc_combo_signal({
                  name                => "A_exc_higher_pri_than_ecc_rf_error",
                  stage               => "A",
                  higher_pri_than_excs => [$ecc_rf_error_exc],
                });

                push(@data_ecc_event_bus_waves,
                  { radix => "x", signal => "A_exc_higher_pri_than_ecc_rf_error" },
                );






                e_assign->adds(










                  [["rf_ecc_event_unrecoverable_err", 1],
                    "A_exc_allowed & A_rf_raw_unrecoverable_ecc_err & 
                      ~A_exc_higher_pri_than_ecc_rf_error & A_en_d1"],



                  [["rf_ecc_event_recoverable_err", 1], "A_rf_ecc_event_recoverable_err & A_en_d1"],
                );

                push(@data_ecc_event_bus_waves,
                  { radix => "x", signal => "A_exc_allowed" },
                  { radix => "x", signal => "A_dc_tag_raw_unrecoverable_ecc_err" },
                  { radix => "x", signal => "dc_tag_ecc_event_unrecoverable_err" },
                  { radix => "x", signal => "A_dc_data_raw_unrecoverable_ecc_err" },
                  { radix => "x", signal => "dc_data_ecc_event_unrecoverable_err" },
                );
            }

            if ($dc_ecc_present || $dtcm_present) {







                new_exc_signal({
                    exc             => $ecc_data_error_exc,
                    initial_stage   => "M", 
                    rhs             => "W_ecc_exc_enabled & !M_mem_baddr_corrupt & (
                                         M_dc_tag_raw_unrecoverable_ecc_err |
                                         M_dc_data_raw_unrecoverable_ecc_err)",
                });

                my $A_ecc_data_error_exc = get_exc_signal_name($ecc_data_error_exc, "A");
               
                e_assign->adds(



                  [["A_exc_ecc_data_error_active", 1], "A_exc_allowed & $A_ecc_data_error_exc"],
                );



                new_exc_combo_signal({
                  name                => "A_exc_higher_pri_than_ecc_data_error",
                  stage               => "A",
                  higher_pri_than_excs => [$ecc_data_error_exc],
                });

                push(@data_ecc_event_bus_waves,
                  { radix => "x", signal => "A_exc_higher_pri_than_ecc_data_error" },
                );
            }

            if ($dc_ecc_present) {





                e_assign->adds(






                  [["dc_wb_ecc_event_unrecoverable_err", 1], "A_dc_xfer_two_bit_err_detected"],
                  [["dc_wb_ecc_event_recoverable_err", 1], "A_dc_xfer_one_bit_err_detected"],







                  [["dc_tag_ecc_event_unrecoverable_err", 1],
                    "A_exc_allowed & A_dc_tag_raw_unrecoverable_ecc_err & 
                      ~A_exc_higher_pri_than_ecc_data_error & A_en_d1"],
                  [["dc_data_ecc_event_unrecoverable_err", 1],
                    "A_exc_allowed & A_dc_data_raw_unrecoverable_ecc_err & 
                      ~A_exc_higher_pri_than_ecc_data_error & A_en_d1"],



                  [["dc_tag_ecc_event_recoverable_err", 1], "A_dc_tag_ecc_event_recoverable_err & A_en_d1"],
                  [["dc_data_ecc_event_recoverable_err", 1], "A_dc_data_ecc_event_recoverable_err & A_en_d1"],
                );

                push(@data_ecc_event_bus_waves,
                  { radix => "x", signal => "A_exc_allowed" },
                  { radix => "x", signal => "A_dc_tag_raw_unrecoverable_ecc_err" },
                  { radix => "x", signal => "dc_tag_ecc_event_unrecoverable_err" },
                  { radix => "x", signal => "A_dc_data_raw_unrecoverable_ecc_err" },
                  { radix => "x", signal => "dc_data_ecc_event_unrecoverable_err" },
                  { radix => "x", signal => "A_dc_tag_ecc_event_recoverable_err" },
                  { radix => "x", signal => "dc_tag_ecc_event_recoverable_err" },
                  { radix => "x", signal => "A_dc_data_ecc_event_recoverable_err" },
                  { radix => "x", signal => "dc_data_ecc_event_recoverable_err" },
                );







                new_exc_signal({
                    exc             => $ecc_dcache_async_error_exc,
                    initial_stage   => "E", 
                    rhs             => "dc_xfer_unrecoverable_ecc_err_pending & W_ecc_exc_enabled",
                });



                new_exc_combo_signal({
                    name                => "A_higher_pri_than_ecc_dcache_async_error_exc",
                    stage               => "A",
                    higher_pri_than_excs => [$ecc_dcache_async_error_exc],
                });

                my $A_ecc_dcache_async_error_exc = get_exc_signal_name($ecc_dcache_async_error_exc, "A");
               
                e_assign->adds(



                  [["A_exc_ecc_dcache_async_error_active", 1], 
                    "A_exc_allowed & $A_ecc_dcache_async_error_exc"],




                  [["A_exc_ecc_dcache_async_error_or_higher_active", 1], 
                    "A_exc_ecc_dcache_async_error_active |
                      (A_exc_allowed & A_higher_pri_than_ecc_dcache_async_error_exc)"],





                  [["A_dc_xfer_one_bit_err_detected", 1], 
                    "A_dc_xfer_rd_data_active & dc_data_rd_port_one_bit_err"], 
                  [["A_dc_xfer_two_bit_err_detected", 1], 
                    "A_dc_xfer_rd_data_active & dc_data_rd_port_two_bit_err"], 
                );

                e_register->adds(








                  {out => ["dc_xfer_unrecoverable_ecc_err_pending", 1], 
                   in => "dc_xfer_unrecoverable_ecc_err_pending ?
                            ~(A_exc_ecc_dcache_async_error_or_higher_active | ~W_ecc_exc_enabled) :
                            (A_dc_xfer_two_bit_err_detected & W_ecc_exc_enabled)",
                   enable => "1'b1"},
                );

                push(@advanced_exc_wave_signals,
                  { radix => "x", signal => "A_dc_xfer_one_bit_err_detected" }, 
                  { radix => "x", signal => "A_dc_xfer_two_bit_err_detected" }, 
                  { radix => "x", signal => "dc_xfer_unrecoverable_ecc_err_pending" },
                  get_exc_signal_wave($ecc_dcache_async_error_exc, "A"),
                  { radix => "x", signal => "A_exc_ecc_dcache_async_error_or_higher_active" },
                  { radix => "x", signal => "A_dc_xfer_rd_data_active" },
                  { radix => "x", signal => "dc_data_rd_port_two_bit_err" },
                );
            }

            if ($mmu_present && $mmu_ecc_present) {
                new_exc_signal({
                    exc             => $ecc_dtlb_error_exc,
                    initial_stage   => "M", 
                    rhs             => 
                        "M_ctrl_mem_data_access & !M_mem_baddr_corrupt &
                         (~M_mem_baddr_bypass_tlb & M_udtlb_hit & M_udtlb_two_bit_err)",
                });
                
                my $A_ecc_error_itlb_exc = get_exc_signal_name($ecc_itlb_error_exc, "A");
                my $A_ecc_error_dtlb_exc = get_exc_signal_name($ecc_dtlb_error_exc, "A");
               
                e_assign->adds(


                  [["A_exc_ecc_error_itlb_active", 1], 
                    "A_exc_allowed & $A_ecc_error_itlb_exc"],
                  [["A_exc_ecc_error_dtlb_active", 1], 
                    "A_exc_allowed & $A_ecc_error_dtlb_exc"],
                );
                
                push(@advanced_exc_wave_signals,
                  get_exc_signal_wave($ecc_dtlb_error_exc, "M"),
                  { radix => "x", signal => "$A_ecc_error_dtlb_exc" },
                  { radix => "x", signal => "$A_ecc_error_dtlb_exc" },
                  { radix => "x", signal => "A_exc_ecc_error_itlb_active" },
                  { radix => "x", signal => "A_exc_ecc_error_dtlb_active" },
                );
            }
        }




        new_exc_combo_signal({
            name            => "M_exc_any",
            stage           => "M",
        });

        my $A_hbreak_exc_nxt = $hbreak_present ? 
          get_exc_nxt_signal_name($hbreak_exc, "A") : "0";
        my $A_break_inst_exc_nxt =
          get_exc_nxt_signal_name($break_inst_exc, "A");

        e_assign->adds(





          [["M_exc_break", 1], "$A_hbreak_exc_nxt | $A_break_inst_exc_nxt"],
        );

        push(@advanced_exc_wave_signals,
          { radix => "x", signal => "M_exc_break" },
        );

        if ($mmu_present) {
            my $M_tlb_inst_miss_exc =
              get_exc_signal_name($tlb_inst_miss_exc, "M");
            my $M_tlb_x_perm_exc =
              get_exc_signal_name($tlb_x_perm_exc, "M");
            my $A_tlb_inst_miss_exc_nxt =
              get_exc_nxt_signal_name($tlb_inst_miss_exc, "A");
            my $A_tlb_data_miss_exc_nxt =
              get_exc_nxt_signal_name($tlb_data_miss_exc, "A");
    
            e_assign->adds(






              [["M_exc_fast_tlb_miss", 1], 
                "~W_exc_handler_mode & 
                   ($A_tlb_inst_miss_exc_nxt | $A_tlb_data_miss_exc_nxt)"],
    



              [["M_exc_vpn", $mmu_addr_vpn_sz], 
                "($M_tlb_inst_miss_exc | $M_tlb_x_perm_exc) ? 
                  M_pc[$mmu_addr_vpn_msb-2:$mmu_addr_vpn_lsb-2] :
                  M_mem_baddr[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"],
    



              [["M_udtlb_access", 1], 
                "M_ctrl_mem_data_access & ~M_mem_baddr_bypass_tlb"],
            );
    
            push(@advanced_exc_wave_signals,
              { radix => "x", signal => "M_exc_fast_tlb_miss" },
              { radix => "x", signal => "M_exc_vpn" },
              { radix => "x", signal => "M_udtlb_access" },
            );
        }
    } else {




        e_assign->adds(
          [["M_exc_any", 1, 0, $force_never_export], "1'b0"],
        );
    }










    my @ram_rd_data_mux_table;
    my $M_ram_rd_data_present = 0;

    if ($dcache_present) {
        push(@ram_rd_data_mux_table, "M_sel_data_master" => "M_dc_rd_data");
        $M_ram_rd_data_present = 1;
    }

    for (my $cmi = 0; 
      $cmi < manditory_int($Opt, "num_tightly_coupled_data_masters"); $cmi++) {
        my $master_name = "tightly_coupled_data_master_${cmi}";
        my $sel_name = "M_sel_" . $master_name;
        my $data_name = "dcm${cmi}_readdata";

        if ($cmi == 
          (manditory_int($Opt, "num_tightly_coupled_data_masters") - 1)) {
            push(@ram_rd_data_mux_table,
              "1'b1" => $data_name);
        } else {
            push(@ram_rd_data_mux_table,
              $sel_name => $data_name);
        }
        $M_ram_rd_data_present = 1;
    }

    if ($M_ram_rd_data_present) {
        e_mux->add ({
          lhs => ["M_ram_rd_data", $datapath_sz],
          type => "priority",
          table => \@ram_rd_data_mux_table,
          });
    }








    e_assign->adds(
      [["M_fwd_reg_data", $datapath_sz], "M_alu_result"],
      );









    my $M_inst_result_mux_table = [];

    if ($advanced_exc) {
        push(@$M_inst_result_mux_table,
          "M_exc_any" => "{ M_pc_plus_one, 2'b00 }",
        );
    }

    push(@$M_inst_result_mux_table,
      "M_ctrl_rdctl_inst" => "M_rdctl_data"
    );

    if ($M_ram_rd_data_present) {
        push(@$M_inst_result_mux_table,
          "M_ctrl_mem" => "M_ram_rd_data"
        );
    }
 
    push(@$M_inst_result_mux_table,
      "1'b1"              => "M_alu_result",
    );

    e_mux->add ({
      lhs => ["M_inst_result", $datapath_sz],
      type => "priority",
      table => $M_inst_result_mux_table,
      });



    e_assign->adds(
        [["M_valid_st_writes_mem", 1, 0, $force_never_export], 
          "M_ctrl_st & M_valid"],
    );
    





    e_assign->adds(



      [["M_ld_align_sh16", 1], 
        "(M_ctrl_ld8 | M_ctrl_ld16) & ${big_endian_tilde}M_mem_baddr[1] &
          ~M_exc_any"],





      [["M_ld_align_sh8", 1], 
        "M_ctrl_ld8 & ${big_endian_tilde}M_mem_baddr[0] &
         ~M_exc_any"],



      [["M_ld_align_byte1_fill", 1], "M_ctrl_ld8 & ~M_exc_any"],
      


      [["M_ld_align_byte2_byte3_fill", 1], 
         "M_ctrl_ld8_ld16 & ~M_exc_any"],
    );





    if ($advanced_exc) {
        e_assign->adds(





          [["M_cancel", 1], "A_pipe_flush | M_refetch | M_exc_any"],
          

          [["M_cancel_except_refetch", 1], "A_pipe_flush | M_exc_any"],






          [["M_ignore_exc", 1], 
            "A_pipe_flush | (M_udtlb_refetch & ~M_exc_higher_priority_than_tlb_data)"],




          [["M_exc_allowed", 1], "M_valid_from_E & ~M_ignore_exc"],
        );

        push(@advanced_exc_wave_signals,
          { radix => "x", signal => "M_refetch" },
          { radix => "x", signal => "M_cancel" },
          { radix => "x", signal => "M_cancel_except_refetch" },
          { radix => "x", signal => "M_ignore_exc" },
          { radix => "x", signal => "M_exc_any" },
          { radix => "x", signal => "M_exc_allowed" },
          { radix => "x", signal => "M_valid_ignoring_refetch" },
        );

        my @M_refetch_inputs;

        if ($mmu_present) {


            new_exc_combo_signal({
                name                => "M_exc_higher_priority_than_tlb_data",
                stage               => "M",
                higher_pri_than_excs => 
                  [$tlb_data_miss_exc, $tlb_r_perm_exc, $tlb_w_perm_exc],
            });
            
            e_assign->adds(











              [["M_udtlb_refetch", 1], "M_ctrl_mem_data_access & ~M_mem_baddr_phy_got_pfn"],
            );

            push(@M_refetch_inputs, "M_udtlb_refetch");

            push(@advanced_exc_wave_signals,
              { radix => "x", signal => "M_udtlb_refetch" },
            );
        } else {

            e_assign->adds(
              [["M_exc_higher_priority_than_tlb_data", 1, 0, $force_never_export], "0"],
              [["M_udtlb_refetch", 1], "0"],
            );
        }

        if ($ecc_present) {






            push(@advanced_exc_wave_signals,
              { radix => "x", signal => "W_config_reg_eccen" },
            );

            if ($rf_ecc_present) {
                push(@M_refetch_inputs, 
                  "(M_rf_raw_recoverable_ecc_err & W_config_reg_eccen)");

                push(@advanced_exc_wave_signals,
                  { radix => "x", signal => "M_rf_raw_recoverable_ecc_err" },
                );
            }

            if ($ic_ecc_present) {
                push(@M_refetch_inputs, "M_ic_ecc_err");

                push(@advanced_exc_wave_signals,
                  { radix => "x", signal => "M_ic_ecc_err" },
                );
            }

            if ($dc_ecc_present) {
                push(@M_refetch_inputs, 
                  "(M_dc_tag_raw_recoverable_ecc_err & W_config_reg_eccen)");
                push(@M_refetch_inputs, 
                  "(M_dc_data_raw_recoverable_flush_ecc_err & W_config_reg_eccen)");
                push(@M_refetch_inputs, 
                  "(M_dc_data_raw_recoverable_correct_ecc_err & W_config_reg_eccen)");

                push(@advanced_exc_wave_signals,
                  { radix => "x", signal => "M_dc_tag_raw_recoverable_ecc_err" },
                  { radix => "x", signal => "M_dc_data_raw_recoverable_flush_ecc_err" },
                  { radix => "x", signal => "M_dc_data_raw_recoverable_correct_ecc_err" },
                );
            }

            if ($itcm_ecc_present) {
                for (my $cmi = 0; 
                  $cmi < manditory_int($Opt, "num_tightly_coupled_instruction_masters");
                  $cmi++) {
                    push(@M_refetch_inputs, "M_icm${cmi}_one_bit_err");

                    push(@advanced_exc_wave_signals,
                      { radix => "x", signal => "M_icm${cmi}_one_bit_err" },
                    );
                }
            }
        }




        e_assign->adds(
          [["M_refetch", 1, 0, $force_never_export], 
            scalar(@M_refetch_inputs) ? join('|', @M_refetch_inputs) : "0"],
        );
    } else {

        e_assign->adds(

          [["M_cancel", 1], "1'b0"],
          [["M_cancel_except_refetch", 1], "1'b0"],
          [["M_refetch", 1, 0, $force_never_export], "1'b0"],
        );
    }
    
    e_assign->adds(


      [["M_valid", 1], "M_valid_from_E & ~M_cancel"],


      [["M_valid_ignoring_refetch", 1, 0, $force_never_export], 
        "M_valid_from_E & ~M_cancel_except_refetch"],






      [["M_wr_dst_reg_with_wrprs", 1], 
         "M_wr_dst_reg_from_E" . 
         ($shadow_present ? 
            "| (M_op_wrprs & M_valid_from_E & (M_alu_result == 0) &
               (${cs}_status_reg_prs != 0))" :
            "")],





      [["M_wr_dst_reg", 1], "M_wr_dst_reg_with_wrprs & ~M_cancel"],
    );

    if ($advanced_exc) {








        e_assign->adds(

          [["M_non_flushing_wrctl", 1], 
            $mpu_present ? 
              "M_ctrl_wrctl_inst & 
                ((M_iw_control_regnum == $mpubase_reg_regnum) |
                 (M_iw_control_regnum == $mpuacc_reg_regnum))" :
              "0"],

          [["A_pipe_flush_nxt", 1], 
          "((M_ctrl_flush_pipe_always & ~M_non_flushing_wrctl) |
            M_refetch | M_exc_any) & 
              M_valid_from_E & ~A_pipe_flush"],
        );



        my $pipe_flush_waddr_mux_table = [];

        push(@$pipe_flush_waddr_mux_table, 

          "M_exc_break" => 
            (manditory_bool($Opt, "export_vectors") ? 
            "break_vector_word_addr" :
            manditory_int($Opt, "break_word_addr") ),
        );

        if ($cpu_reset) {
            push(@$pipe_flush_waddr_mux_table, 

              "M_exc_crst" => 
                (manditory_bool($Opt, "export_vectors") ? 
                "reset_vector_word_addr" :
                manditory_int($Opt, "reset_word_addr")),
            );
        }

        if ($eic_present) {
            push(@$pipe_flush_waddr_mux_table, 

              "M_exc_ext_intr" => "M_eic_rha[$pcb_sz-1:2]",
            );
        }

        if ($mmu_present) {
            push(@$pipe_flush_waddr_mux_table, 

              "M_exc_fast_tlb_miss" =>
                (manditory_bool($Opt, "export_vectors") ? 
                "fast_tlb_miss_vector_word_addr" :
                manditory_int($Opt, "fast_tlb_miss_exception_word_addr") ),
            );
        }

        push(@$pipe_flush_waddr_mux_table, 

          "M_exc_any" => manditory_bool($Opt, "export_vectors") ?  
            "exception_vector_word_addr" : 
            manditory_int($Opt, "general_exception_word_addr"),


          "M_refetch" => "M_pc",


          "M_ctrl_jmp_indirect" => "M_target_pcb[$pcb_sz-1:2]",



          "1'b1" => "M_pc_plus_one",
        );

        e_mux->add ({
          lhs => ["A_pipe_flush_waddr_nxt", $pc_sz],
          type => "priority",
          table => $pipe_flush_waddr_mux_table,
        });


        e_signal->adds({name => "A_pipe_flush_baddr_nxt", never_export => 1, 
          width => $pcb_sz});
        e_assign->adds(["A_pipe_flush_baddr_nxt", 
          "{A_pipe_flush_waddr_nxt, 2'b00}"]);
    }













    my @A_stall_inputs;

    if ($data_master_present || ($advanced_exc && $dtcm_present)) {
        push(@A_stall_inputs, "A_mem_stall");
    }

    if ($hw_mul) {
        if ($hw_mul_uses_dsp_block  || $hw_mul_uses_designware) {

        } else {

            push(@A_stall_inputs, "A_mul_stall");
        }
    }

    if ($hw_div) {
        push(@A_stall_inputs, "A_div_stall");
    }

    if ($fast_shifter_uses_dsp_block  || $fast_shifter_uses_designware || $fast_shifter_uses_les) {


    } elsif ($small_shifter_uses_les) {
        push(@A_stall_inputs, "A_shift_rot_stall");
    } else {
        &$error("make_base_pipeline: unsupported shifter implementation");
    }

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        push(@A_stall_inputs, "A_ci_multi_stall");
    }

    e_assign->adds(
      [["A_stall", 1], 
        scalar(@A_stall_inputs) ? join('|', @A_stall_inputs) : "0"],


      [["A_en", 1], "~A_stall"],        
      );

    e_signal->adds(



      {name => "A_cmp_result", never_export => 1, width => 1},
      {name => "A_br_jmp_target_pcb", never_export => 1, width => $pcb_sz},
      {name => "A_mem_baddr", never_export => 1, width => $mem_baddr_sz},
      {name => "A_exc_fast_tlb_miss", never_export => 1, width => 1 },
    );

    e_register->adds(
      {out => ["A_valid", 1],                       in => "M_valid",
       enable => "A_en", ip_debug_visible => 1},
      {out => ["A_iw",  $iw_sz],                    in => "M_iw",
       enable => "A_en", ip_debug_visible => 1},
      {out => ["A_inst_result", $datapath_sz],      in => "M_inst_result",
       enable => "A_en"},
      {out => ["A_mem_byte_en", $byte_en_sz],       in => "M_mem_byte_en",
       enable => "A_en", },
      {out => ["A_st_data", $datapath_sz],          in => "M_st_data",
       enable => "A_en"},
      {out => ["A_dst_regnum_from_M", $regnum_sz],  in => "M_dst_regnum",
       enable => "A_en"},
      {out => ["A_ld_align_sh16", 1],               in => "M_ld_align_sh16",
       enable => "A_en"},
      {out => ["A_ld_align_sh8", 1],                in => "M_ld_align_sh8",
       enable => "A_en"},
      {out => ["A_ld_align_byte1_fill", 1],         
       in => "M_ld_align_byte1_fill",
       enable => "A_en"},
      {out => ["A_ld_align_byte2_byte3_fill", 1],   
       in => "M_ld_align_byte2_byte3_fill",
       enable => "A_en"},
      {out => "A_cmp_result",                       in => "M_cmp_result",  
       enable => "A_en"},
      {out => "A_mem_baddr",                        in => "M_mem_baddr",
       enable => "A_en"},
      {out => ["A_wr_dst_reg_from_M", 1],           in => "M_wr_dst_reg",
       enable => "A_en" },
      );

    if ($advanced_exc) {
        e_assign->adds(

          [["A_br_jmp_target_pcb_nxt", $pcb_sz], 
            "M_ctrl_br ? 
              ({M_pc_plus_one, 2'b00} + {{16 {M_iw_imm16[15]}}, M_iw_imm16}) :
              M_target_pcb"],
        );

        e_register->adds(
          {out => ["A_pipe_flush", 1],           in => "A_pipe_flush_nxt",
           enable => "A_en" },
          {out => ["A_pipe_flush_waddr", $pc_sz],in => "A_pipe_flush_waddr_nxt",
           enable => "A_en" },
          {out => ["A_exc_allowed", 1],          in => "M_exc_allowed", 
           enable => "A_en"},
          {out => ["A_exc_break", 1],            in => "M_exc_break",
           enable => "A_en"},
          {out => ["A_exc_crst", 1],             in => "M_exc_crst",
           enable => "A_en"},
          {out => ["A_exc_ext_intr", 1],         in => "M_exc_ext_intr",
           enable => "A_en"},
          {out => ["A_exc_any", 1],              in => "M_exc_any",
           enable => "A_en"},
          {out => ["A_br_jmp_target_pcb", $pcb_sz, 0, $force_never_export],
           in => "A_br_jmp_target_pcb_nxt",
           enable => "A_en"},
        );


        e_signal->adds({name => "A_pipe_flush_baddr", never_export => 1, 
          width => $pcb_sz});
        e_assign->adds(["A_pipe_flush_baddr", "{A_pipe_flush_waddr, 2'b00}"]);

        if ($mmu_present) {
            e_register->adds(
              {out => ["A_exc_vpn", $mmu_addr_vpn_sz],  in => "M_exc_vpn",
               enable => "A_en"},
              {out => ["A_udtlb_access", 1],            in => "M_udtlb_access",
               enable => "A_en"},
              {out => ["A_udtlb_index", $udtlb_index_sz],
               in => "M_udtlb_index",        enable => "A_en"},
              {out => ["A_exc_fast_tlb_miss", 1],
               in  => "M_exc_fast_tlb_miss", enable  => "A_en"},
            );
    
            e_assign->adds(






              [["A_valid_udtlb_lru_access", 1], "A_valid & A_udtlb_access"],
            );
        }
    } else {

        e_assign->adds(
          [["A_pipe_flush", 1], "1'b0"],
          [["A_pipe_flush_waddr", $pc_sz], "0"],
        );

        if ($cpu_reset) {
            e_register->adds(
              {out => ["A_valid_crst", 1, 0, $force_never_export], 
               in => "M_ctrl_crst & M_valid", enable => "A_en"},
            );
        } else {
            e_assign->adds(
              [["A_valid_crst", 1, 0, $force_never_export], "0"],
            );
        }
    }











    my $slow_inst_result_table = [];
    my @slow_inst_sel_list = ();
    my @slow_inst_en_list = ();

    my @slow_inst_result_mux_signals = (
        { divider => "A_slow_inst_result_mux" },
    );

    if ($eic_and_shadow) {
        push(@$slow_inst_result_table,
          "A_exc_wr_sstatus" => "${cs}_sstatus_reg_nxt",
        );
        push(@slow_inst_sel_list, "A_exc_wr_sstatus");
        push(@slow_inst_en_list,  "A_exc_wr_sstatus");

        push(@slow_inst_result_mux_signals,
          { radix => "x", signal => "A_exc_wr_sstatus" },
          { radix => "x", signal => "${cs}_sstatus_reg_nxt" },
        );
    }

    if ($hw_div) {
        push(@$slow_inst_result_table,
          "A_ctrl_div" => "A_div_quot",
        );
        push(@slow_inst_sel_list, "A_ctrl_div");
        push(@slow_inst_en_list,  "A_ctrl_div");



        e_register->adds(
          {out => ["A_div_done", 1],
           in => "A_en ? 0 : A_div_quot_ready",
           enable => "1'b1"},
        );

        push(@slow_inst_result_mux_signals,
          { radix => "x", signal => "A_ctrl_div" },
          { radix => "x", signal => "A_div_quot" },
          { radix => "x", signal => "A_div_quot_ready" },
          { radix => "x", signal => "A_div_done" },
        );
    }

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {
        push(@$slow_inst_result_table,
          "A_ctrl_custom_multi"         => "A_ci_multi_result",
        );
        push(@slow_inst_sel_list, "A_ctrl_custom_multi");
        push(@slow_inst_en_list,  "A_ctrl_custom_multi");

        push(@slow_inst_result_mux_signals,
          { radix => "x", signal => "A_ctrl_custom_multi" },
          { radix => "x", signal => "A_ci_multi_result" },
        );
    }

    if ($data_master_present) {
        if ($wide_dcache_present) {





            push(@slow_inst_sel_list, "A_ctrl_ld_bypass", "A_dc_want_fill");








            push(@slow_inst_en_list,
              "((A_dc_fill_miss_offset_is_next | A_ctrl_ld_bypass) &
                d_readdatavalid_d1)");

            push(@slow_inst_result_mux_signals,
              { radix => "x", signal => "A_slow_inst_result_en" },
              { radix => "x", signal => "A_dc_fill_miss_offset_is_next" },
              { radix => "x", signal => "A_ctrl_ld_bypass" },
              { radix => "x", signal => "d_readdatavalid_d1" },
            );
            push(@slow_inst_result_mux_signals,
              { radix => "x", signal => "A_ctrl_ld_bypass" },
              { radix => "x", signal => "A_dc_want_fill" },
            );
        } elsif ($dcache_present) {


            push(@slow_inst_sel_list, "A_dc_av_rd_req");
            push(@slow_inst_en_list,  "A_ctrl_ld");

            push(@slow_inst_result_mux_signals,
              { radix => "x", signal => "A_dc_av_rd_req" },
            );
        } else {

            push(@slow_inst_sel_list, "A_ctrl_ld");
            push(@slow_inst_en_list,  "A_ctrl_ld");

            push(@slow_inst_result_mux_signals,
              { radix => "x", signal => "A_ctrl_ld" },
              { radix => "x", signal => "A_ctrl_ld32" },
            );


            push(@$slow_inst_result_table,
              "A_ctrl_ld32"             => "d_readdata",
            );
        }

        push(@$slow_inst_result_table,
          "1'b1"                        => "A_slow_ld_data_aligned_nxt",
        );

        push(@slow_inst_result_mux_signals,
          { radix => "x", signal => "A_slow_ld_data_aligned_nxt" },
        );

    }

    if (scalar(@$slow_inst_result_table) > 0) {

        e_assign->adds(
          [["A_slow_inst_result_en", 1], join('|', @slow_inst_en_list)],
        );






        e_assign->adds(
          [["A_slow_inst_sel_nxt", 1], 
             "A_en ? 0 : " . join('|', @slow_inst_sel_list)],
        );
     
        e_mux->add({
          lhs => ["A_slow_inst_result_nxt", $datapath_sz],
          type => "priority",
          table => $slow_inst_result_table,
        });

        e_register->adds(
          {out => ["A_slow_inst_sel", 1],
           in => "A_slow_inst_sel_nxt",        
           enable => "1'b1"},

          {out => ["A_slow_inst_result", $datapath_sz], 
           in => "A_slow_inst_result_nxt",     
           enable => "A_slow_inst_result_en"},
        );

        push(@slow_inst_result_mux_signals,
          { radix => "x", signal => "A_slow_inst_sel_nxt" },
          { radix => "x", signal => "A_slow_inst_sel" },
          { radix => "x", signal => "A_slow_inst_result_en" },
          { radix => "x", signal => "A_slow_inst_result_nxt" },
          { radix => "x", signal => "A_slow_inst_result" },
        );
    }
  












    my $rf_wr_mux_table = [];

    if ($eic_and_shadow) {



        push(@$rf_wr_mux_table, 
          "W_exc_wr_sstatus"                    => "A_slow_inst_result",
        );
    }

    if ($advanced_exc) {





        push(@$rf_wr_mux_table, 
          "A_exc_any"                           => "A_inst_result_aligned",
        );
    }

    if ($hw_mul) {
        if ($hw_mul_uses_dsp_block) {
            push(@$rf_wr_mux_table,
              "A_ctrl_mul_shift_rot"             => "A_mul_shift_rot_result",
            );
        } elsif ($hw_mul_uses_embedded_mults || $hw_mul_uses_les ||
          $hw_mul_uses_designware) {
            push(@$rf_wr_mux_table,
              "A_ctrl_mul_lsw"                   => "A_mul_result",
              "A_ctrl_shift_rot"                 => "A_shift_rot_result",
            );
        } else {
            &$error("$whoami: unsupported hardware multiplier implementation");
        }
    } else {
        push(@$rf_wr_mux_table,
          "A_ctrl_shift_rot"                => "A_shift_rot_result",
        );
    }

    if (scalar(@$slow_inst_result_table) > 0) {
        push(@$rf_wr_mux_table, 
          "~A_slow_inst_sel"                => "A_inst_result_aligned",
          "1'b1"                            => "A_slow_inst_result",
        );
    } else {
        push(@$rf_wr_mux_table, 
          "1'b1"                            => "A_inst_result_aligned",
        );
    }

    e_mux->add ({
      lhs => ["A_wr_data_unfiltered", $datapath_sz],
      type => "priority",
      table => $rf_wr_mux_table,
    });


    e_assign->adds(
      [["A_fwd_reg_data", $datapath_sz], "A_wr_data_filtered"],
    );





    if ($advanced_exc) {
        e_assign->adds(


          [["A_exc_any_active", 1], "A_exc_any & A_exc_allowed"],
          [["A_exc_break_active", 1], "A_exc_break & A_exc_allowed"],
          [["A_exc_crst_active", 1], "A_exc_crst & A_exc_allowed"],
          [["A_exc_ext_intr_active", 1, 0, $force_never_export], 
            "A_exc_ext_intr & A_exc_allowed"],



          [["A_exc_shadow", 1], 
            $eic_and_shadow ? "A_exc_ext_intr & A_eic_rrs_non_zero" : "0"],
          [["A_exc_shadow_active", 1], "A_exc_shadow & A_exc_allowed"],

          [["A_exc_active_no_break", 1], 
             "A_exc_any_active & ~A_exc_break"],

          [["A_exc_active_no_crst", 1, 0, $force_never_export], 
             "A_exc_any_active & ~A_exc_crst"],
          [["A_exc_active_no_break_no_crst", 1, 0, $force_never_export], 
             "A_exc_any_active & ~(A_exc_break | A_exc_crst)"],







          [["A_exc_wr_ea_ba", 1],
            $status_reg_eh ?
              "A_exc_break_active |
                (A_exc_active_no_break_no_crst & ~W_exc_handler_mode)" :
              "A_exc_active_no_crst"],





          [["A_exc_wr_sstatus", 1], 
            "A_exc_shadow_active & ~W_exc_handler_mode"],


          [["A_dst_regnum", $regnum_sz],
            "W_exc_wr_sstatus ? $sstatus_regnum :
             A_exc_break      ? $bretaddr_regnum :
             A_exc_any        ? $eretaddr_regnum :
                                A_dst_regnum_from_M"],







          [["A_wr_dst_reg", 1], 
            "A_wr_dst_reg_from_M | 
             A_exc_wr_ea_ba |
             W_exc_wr_sstatus"],




          [["W_debug_mode_nxt", 1],
            "A_exc_break_active            ? 1'b1 :
             (A_valid & A_op_bret)         ? 1'b0 : 
                                             W_debug_mode"],
        );

        if ($shadow_present) {
            e_assign->adds(





              [["A_dst_regset", $rf_set_sz], 
                "W_exc_wr_sstatus ? ${cs}_status_reg_crs : " .
                ($eic_present ?  "A_exc_ext_intr_active ? A_eic_rrs : " : "") .
                "A_exc_any ? 0 :
                 (A_valid & A_op_wrprs) ? ${cs}_status_reg_prs : 
                              ${cs}_status_reg_crs"],
            );
        }

        e_register->adds(
          {out => ["W_exc_wr_sstatus", 1], in => "A_exc_wr_sstatus",
           enable => "W_en"},
        );

        push(@advanced_exc_wave_signals,
          { radix => "x", signal => "A_exc_allowed" },
          { radix => "x", signal => "A_exc_any " },
          { radix => "x", signal => "A_exc_break" },
          { radix => "x", signal => "A_exc_crst" },
          { radix => "x", signal => "A_exc_ext_intr" },
          { radix => "x", signal => "A_exc_any_active" },
          { radix => "x", signal => "A_exc_break_active" },
          { radix => "x", signal => "A_exc_active_no_break_no_crst" },
          { radix => "x", signal => "A_exc_active_no_break" },
          { radix => "x", signal => "A_exc_shadow_active" },
          { radix => "x", signal => "A_exc_wr_ea_ba" },
          { radix => "x", signal => "A_wr_dst_reg" },
          { radix => "x", signal => "W_debug_mode_nxt" },
        );

        if ($mmu_present) {
            my $A_supervisor_inst_addr_exc = 
              get_exc_signal_name($supervisor_inst_addr_exc, "A");
            my $A_tlb_inst_miss_exc = 
              get_exc_signal_name($tlb_inst_miss_exc, "A");
            my $A_tlb_x_perm_exc =
              get_exc_signal_name($tlb_x_perm_exc, "A");
            my $A_supervisor_data_addr_exc = 
              get_exc_signal_name($supervisor_data_addr_exc, "A");
            my $A_misaligned_data_addr_exc = 
              get_exc_signal_name($misaligned_data_addr_exc, "A");
            my $A_misaligned_target_pc_exc = 
              get_exc_signal_name($misaligned_target_pc_exc, "A");
            my $A_tlb_data_miss_exc =
              get_exc_signal_name($tlb_data_miss_exc, "A");
            my $A_tlb_r_perm_exc =
              get_exc_signal_name($tlb_r_perm_exc, "A");
            my $A_tlb_w_perm_exc =
              get_exc_signal_name($tlb_w_perm_exc, "A");
    
            my $ecc_exc_dtlb = "";
            if ($ecc_present && $mmu_ecc_present) {
                $ecc_exc_dtlb = "A_exc_ecc_error_dtlb_active |";
            }

            e_assign->adds(


              [["A_exc_tlb_inst_miss_active", 1], 
                "A_exc_allowed & $A_tlb_inst_miss_exc"],
              [["A_exc_tlb_x_perm_active", 1], 
                "A_exc_allowed & $A_tlb_x_perm_exc"],
              [["A_exc_tlb_data_miss_active", 1], 
                "A_exc_allowed & $A_tlb_data_miss_exc"],
              [["A_exc_tlb_r_perm_active", 1], 
                "A_exc_allowed & $A_tlb_r_perm_exc"],
              [["A_exc_tlb_w_perm_active", 1], 
                "A_exc_allowed & $A_tlb_w_perm_exc"],
              [["A_exc_super_data_addr_active", 1], 
                "A_exc_allowed & $A_supervisor_data_addr_exc"],
              [["A_exc_misaligned_data_addr_active", 1], 
                "A_exc_allowed & $A_misaligned_data_addr_exc"],
    


              [["A_exc_bad_virtual_addr_active", 1],
                "A_exc_allowed & 
                  ($A_supervisor_inst_addr_exc |
                   $A_supervisor_data_addr_exc |
                   $A_misaligned_data_addr_exc | 
                   $A_misaligned_target_pc_exc)"],
    

              [["A_exc_tlb_active", 1], 
                "(A_exc_tlb_inst_miss_active | A_exc_tlb_data_miss_active |
                  A_exc_tlb_x_perm_active | A_exc_tlb_r_perm_active |
                  A_exc_tlb_w_perm_active)"],
    


              [["A_exc_data", 1], 
                "$ecc_exc_dtlb
                 A_exc_tlb_data_miss_active |
                 A_exc_tlb_r_perm_active |
                 A_exc_tlb_w_perm_active |
                 A_exc_super_data_addr_active |
                 A_exc_misaligned_data_addr_active"],
            );
    
            if ($hbreak_present) {
                push(@advanced_exc_wave_signals,
                  get_exc_signal_wave($hbreak_exc, "A"));
            }
    
            if ($cpu_reset) {
                push(@advanced_exc_wave_signals,
                  get_exc_signal_wave($cpu_reset_exc, "A"));
            }
    
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave(
                $eic_present ? $ext_intr_exc : $norm_intr_exc, "A"),
              get_exc_signal_wave($break_inst_exc, "A"),
              get_exc_signal_wave($supervisor_inst_addr_exc, "A"),
              get_exc_signal_wave($tlb_inst_miss_exc, "A"),
              get_exc_signal_wave($tlb_x_perm_exc, "A"),
              get_exc_signal_wave($supervisor_data_addr_exc, "A"),
              get_exc_signal_wave($tlb_data_miss_exc, "A"),
              get_exc_signal_wave($tlb_r_perm_exc, "A"),
              get_exc_signal_wave($tlb_w_perm_exc, "A"),
    
              { radix => "x", signal => "A_exc_bad_virtual_addr_active" },
              { radix => "x", signal => "A_exc_tlb_inst_miss_active" },
              { radix => "x", signal => "A_exc_tlb_data_miss_active" },
              { radix => "x", signal => "A_exc_tlb_x_perm_active" },
              { radix => "x", signal => "A_exc_tlb_r_perm_active" },
              { radix => "x", signal => "A_exc_tlb_w_perm_active" },
              { radix => "x", signal => "A_exc_data" },
              { radix => "x", signal => "A_exc_tlb_active" },
            );
        }

        if ($slave_access_error_exc) {
            my $A_empty_slave_inst_access_error_exc = get_exc_signal_name(
              $empty_slave_inst_access_error_exc, "A");
            my $A_empty_slave_data_access_error_exc = get_exc_signal_name(
              $empty_slave_data_access_error_exc, "A");
            my $A_readonly_slave_data_access_error_exc = get_exc_signal_name(
              $readonly_slave_data_access_error_exc, "A");

            e_assign->adds(


                [["A_exc_slave_access_error_active", 1], 
                  "A_exc_allowed & 
                    ($A_empty_slave_inst_access_error_exc | 
                     $A_empty_slave_data_access_error_exc |
                     $A_readonly_slave_data_access_error_exc)"],
            );

            push(@advanced_exc_wave_signals,
              get_exc_signal_wave(
                $empty_slave_inst_access_error_exc, "A"),
              get_exc_signal_wave(
                $empty_slave_data_access_error_exc, "A"),
              get_exc_signal_wave(
                $readonly_slave_data_access_error_exc, "A"),
              { radix => "x", signal => "A_exc_slave_access_error_active" },
            );
        }

        if ($illegal_mem_exc) {
            push(@advanced_exc_wave_signals,
              get_exc_signal_wave($misaligned_data_addr_exc, "A"),
              get_exc_signal_wave($misaligned_target_pc_exc, "A"),
            );
        }
    } else {


        e_assign->adds(
          [["A_wr_dst_reg", 1], "A_wr_dst_reg_from_M"],
          [["A_dst_regnum", $regnum_sz], "A_dst_regnum_from_M"],
        );
    }






    e_assign->adds(
      [["W_en", 1, 0, $force_never_export], "1'b1"],
    );

    e_signal->adds(

      {name => "W_iw",          never_export => 1, width => $iw_sz},
      {name => "W_valid",       never_export => 1, width => 1},
      {name => "W_wr_dst_reg",  never_export => 1, width => 1},
      {name => "W_dst_regnum",  never_export => 1, width => $regnum_sz},
    );



    e_register->adds(
      {out => ["W_wr_data", $datapath_sz], in => "A_wr_data_filtered",
       enable => "1'b1"},
      




      {out => "W_iw",         in => "A_iw",           enable => "1'b1",
       ip_debug_visible => $mmu_present},
      {out => "W_valid",      in => "A_valid & A_en", enable => "1'b1"},
      {out => "W_wr_dst_reg", in => "A_wr_dst_reg & A_en", enable => "1'b1"},
      {out => "W_dst_regnum", in => "A_dst_regnum",   enable => "1'b1"},
    );

    if ($shadow_present) {
        e_signal->adds(

          {name => "W_dst_regset",  never_export => 1, width => $rf_set_sz},
        );

        e_register->adds(
          {out => "W_dst_regset", in => "A_dst_regset",   enable => "1'b1"},
        );
    }

    if ($advanced_exc) {
        e_register->adds(
          {out => ["W_debug_mode", 1],
           in => "W_debug_mode_nxt",                enable => "1'b1" },

          {out => ["W_exc_crst_active", 1, 0, $force_never_export],
           in => "A_exc_crst_active",               enable => "1'b1" },
        );

        e_assign->adds(
          [["W_exc_handler_mode", 1, 0, $force_never_export], 
            $status_reg_eh ? "${cs}_status_reg_eh" : "0"],
        );
    }





    if (scalar(@data_ecc_event_bus_waves) > 0) {
        push(@plaintext_wave_signals, { divider => "data_ecc_event_bus" });
        push(@plaintext_wave_signals, @data_ecc_event_bus_waves);
    }

    if (scalar(@advanced_exc_wave_signals) > 0) {
        push(@plaintext_wave_signals, { divider => "exceptions" });
        push(@plaintext_wave_signals, @advanced_exc_wave_signals);
    }

    if (manditory_bool($Opt, "full_waveform_signals") &&
      (scalar(@sel_signals) > 1)) {
        push(@plaintext_wave_signals, 
            { divider => "data_master_sel" },
        );

        foreach my $sel_signal (@sel_signals) {
            push(@plaintext_wave_signals, 
              { radix => "x", signal => $sel_signal },
            );
        }
    }

    my @mem_load_store_wave_signals = (
        { divider => "mem" },
        { radix => "x", signal => "E_mem_baddr" },
        { radix => "x", signal => "M_mem_baddr" },
        { divider => "load" },
        { radix => "x", signal => "M_ctrl_ld_dcache_management" },
        { radix => "x", signal => "M_ctrl_ld8" },
        { radix => "x", signal => "M_ctrl_ld16" },
        { radix => "x", signal => "M_ctrl_ld_signed" },
        $M_ram_rd_data_present ? {radix =>"x", signal => "M_ram_rd_data"} : "",
        { radix => "x", signal => "M_inst_result" },
        { radix => "x", signal => "A_inst_result" },
        { radix => "x", signal => "A_inst_result_aligned" },
        { radix => "x", signal => "A_wr_data_unfiltered" },
        { radix => "x", signal => "A_wr_data_filtered" },
        { radix => "x", signal => "A_ld_align_sh16" },
        { radix => "x", signal => "A_ld_align_sh8" },
        { radix => "x", signal => "A_ld_align_byte1_fill" },
        { radix => "x", signal => "A_ld_align_byte2_byte3_fill" },
        { divider => "store" },
        { radix => "x", signal => "E_ctrl_st" },
        { radix => "x", signal => "E_ctrl_st8" },
        { radix => "x", signal => "E_ctrl_st16" },
        { radix => "x", signal => "E_valid" },
        { radix => "x", signal => "E_st_data" },
        { radix => "x", signal => "E_mem_byte_en" },
        { radix => "x", signal => "M_st_data" },
        { radix => "x", signal => "M_mem_byte_en" },
        { radix => "x", signal => "A_st_data" },
        { radix => "x", signal => "A_mem_byte_en" },
        @slow_inst_result_mux_signals,
    );

    if (manditory_bool($Opt, "full_waveform_signals")) {
        push(@plaintext_wave_signals, @mem_load_store_wave_signals);
    }
}





sub 
make_custom_instruction_master
{
    my $Opt = shift;


    be_make_custom_instruction_master($Opt); 

    if (nios2_custom_insts::has_multi_insts($Opt->{custom_instructions})) {

        e_register->adds(

          {out => ["A_ci_multi_src1", $datapath_sz], in => "M_src1", 
           enable => "A_en"},
          {out => ["A_ci_multi_src2", $datapath_sz], in => "M_src2", 
           enable => "A_en"},




          {out => ["A_ci_multi_stall", 1], 
           in => "A_ci_multi_stall ? ~A_ci_multi_done : 
             (M_ctrl_custom_multi & M_valid & A_en)",
           enable => "1'b1"},



          {out => ["A_ci_multi_start", 1], 
           in => "A_ci_multi_start ? 1'b0 : 
             (M_ctrl_custom_multi & M_valid & A_en)",
           enable => "1'b1"},
        );




        e_assign->add([["A_ci_multi_clk_en", 1], "A_ci_multi_stall"]);
        e_assign->add([["A_ci_multi_clock", 1], "clk"]);
        e_assign->add([["A_ci_multi_reset", 1], "~reset_n"]);
        e_assign->add([["A_ci_multi_reset_req", 1], "reset_req"]);
    }
}






sub 
make_fetch_npc
{
    my $Opt = shift;

    my $fetch_npc = not_empty_scalar($Opt, "fetch_npc");
    my $fetch_npcb = not_empty_scalar($Opt, "fetch_npcb");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");























    e_mux->add ({
      lhs => [$fetch_npc, $pc_sz],
      type => "priority",
      table => [
        "A_pipe_flush"                  => "A_pipe_flush_waddr",
        "M_pipe_flush"                  => "M_pipe_flush_waddr",
        "E_valid_jmp_indirect"          => "E_src1[$pcb_sz-1:2]",
        "D_refetch",                    => "D_pc",
        "D_br_pred_taken & D_issue"     => "D_br_taken_waddr",
        "D_ctrl_jmp_direct & D_issue"   => "D_jmp_direct_target_waddr",
        "1'b1"                          => "${ds}_pc_plus_one",
        ],
      });

    my @fetch_npc = (
        { divider => "fetch_npc" },
        $advanced_exc ? { radix => "x", signal => "A_pipe_flush" } : "",
        $advanced_exc ? { radix => "x", signal => "A_pipe_flush_baddr" } : "",
        { radix => "x", signal => "M_pipe_flush" },
        { radix => "x", signal => "M_pipe_flush_baddr" },
        { radix => "x", signal => "D_refetch" },
        { radix => "x", signal => "D_pcb" },
        { radix => "x", signal => "D_br_pred_taken" },
        { radix => "x", signal => "D_br_taken_baddr" },
        { radix => "x", signal => "E_valid_jmp_indirect" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "D_ctrl_jmp_direct" },
        { radix => "x", signal => "D_jmp_direct_target_baddr" },
        { radix => "x", signal => "$fetch_npcb" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @fetch_npc);
    }
}





sub 
make_reg_cmp
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $ds = not_empty_scalar($Opt, "dispatch_stage");
    my $di = not_empty_scalar($Opt, "dispatch_raw_iw");
    









    e_assign->adds(
      [["D_regnum_a_cmp_${ds}", 1], "(${di}_a == D_dst_regnum) & D_wr_dst_reg"],
      [["E_regnum_a_cmp_${ds}", 1], "(${di}_a == E_dst_regnum) & E_wr_dst_reg"],
      [["M_regnum_a_cmp_${ds}", 1], "(${di}_a == M_dst_regnum) & M_wr_dst_reg"],
      [["A_regnum_a_cmp_${ds}", 1], "(${di}_a == A_dst_regnum) & A_wr_dst_reg"],

      [["D_regnum_b_cmp_${ds}", 1], "(${di}_b == D_dst_regnum) & D_wr_dst_reg"],
      [["E_regnum_b_cmp_${ds}", 1], "(${di}_b == E_dst_regnum) & E_wr_dst_reg"],
      [["M_regnum_b_cmp_${ds}", 1], "(${di}_b == M_dst_regnum) & M_wr_dst_reg"],
      [["A_regnum_b_cmp_${ds}", 1], "(${di}_b == A_dst_regnum) & A_wr_dst_reg"],
      );






    e_register->adds(
      {out => ["E_regnum_a_cmp_D", 1],          
       in => "D_en ? D_regnum_a_cmp_${ds} : 1'b0",             
       enable => "E_en"},
      {out => ["M_regnum_a_cmp_D", 1],          
       in => "D_en ? E_regnum_a_cmp_${ds} : E_regnum_a_cmp_D", 
       enable => "M_en"},
      {out => ["A_regnum_a_cmp_D", 1],          
       in => "D_en ? M_regnum_a_cmp_${ds} : M_regnum_a_cmp_D", 
       enable => "A_en"},
      {out => ["W_regnum_a_cmp_D", 1],          
       in => "D_en ? A_regnum_a_cmp_${ds} : A_regnum_a_cmp_D", 
       enable => "1'b1"},
      {out => ["E_regnum_b_cmp_D", 1],          
       in => "D_en ? D_regnum_b_cmp_${ds} : 1'b0",             
       enable => "E_en"},
      {out => ["M_regnum_b_cmp_D", 1],          
       in => "D_en ? E_regnum_b_cmp_${ds} : E_regnum_b_cmp_D", 
       enable => "M_en"},
      {out => ["A_regnum_b_cmp_D", 1],          
       in => "D_en ? M_regnum_b_cmp_${ds} : M_regnum_b_cmp_D", 
       enable => "A_en"},
      {out => ["W_regnum_b_cmp_D", 1],          
       in => "D_en ? A_regnum_b_cmp_${ds} : A_regnum_b_cmp_D", 
       enable => "1'b1"},



      {out => ["E_src1_from_rf", 1, 0, $force_never_export],
       in => "~(D_src1_choose_E | D_src1_choose_M | D_src1_choose_A | D_src1_choose_W)",
       enable => "E_en"},
      {out => ["E_src2_from_rf", 1, 0, $force_never_export],
       in => "~(D_src2_choose_E | D_src2_choose_M | D_src2_choose_A | D_src2_choose_W)",
       enable => "E_en"},
      );





    e_assign->adds(

      [["D_ctrl_a_is_src", 1], "~D_ctrl_a_not_src"],
      [["D_ctrl_b_is_src", 1], "~D_ctrl_b_not_src"],
      [["E_ctrl_a_is_src", 1, 0, $force_never_export], "~E_ctrl_a_not_src"],
      [["E_ctrl_b_is_src", 1, 0, $force_never_export], "~E_ctrl_b_not_src"],





      [["D_src1_hazard_E", 1], "E_regnum_a_cmp_D & D_ctrl_a_is_src"],
      [["D_src1_hazard_M", 1], "M_regnum_a_cmp_D & D_ctrl_a_is_src"],
      [["D_src1_hazard_A", 1], "A_regnum_a_cmp_D & D_ctrl_a_is_src"],
      [["D_src1_hazard_W", 1], "W_regnum_a_cmp_D & D_ctrl_a_is_src"],
    
      [["D_src2_hazard_E", 1], "E_regnum_b_cmp_D & D_ctrl_b_is_src"],
      [["D_src2_hazard_M", 1], "M_regnum_b_cmp_D & D_ctrl_b_is_src"],
      [["D_src2_hazard_A", 1], "A_regnum_b_cmp_D & D_ctrl_b_is_src"],
      [["D_src2_hazard_W", 1], "W_regnum_b_cmp_D & D_ctrl_b_is_src"],



      [["D_src1_other_rs", 1], 
        $shadow_present ?
          "D_ctrl_rdprs & (${cs}_status_reg_crs != ${cs}_status_reg_prs)" :
          "0"],








      [["D_src1_choose_E", 1], "D_src1_hazard_E & ~D_src1_other_rs"],
      [["D_src1_choose_M", 1], "D_src1_hazard_M & ~D_src1_other_rs"],
      [["D_src1_choose_A", 1], "D_src1_hazard_A & ~D_src1_other_rs"],
      [["D_src1_choose_W", 1], "D_src1_hazard_W & ~D_src1_other_rs"],
    

      [["D_src2_choose_E", 1], "D_src2_hazard_E"],
      [["D_src2_choose_M", 1], "D_src2_hazard_M"],
      [["D_src2_choose_A", 1], "D_src2_hazard_A"],
      [["D_src2_choose_W", 1], "D_src2_hazard_W"],






      [["D_data_depend", 1], 
        "((D_src1_hazard_E | D_src2_hazard_E) & E_ctrl_late_result) |
         ((D_src1_hazard_M | D_src2_hazard_M) & M_ctrl_late_result)"],










      [["D_dstfield_regnum", $regnum_sz], "D_ctrl_b_is_dst ? D_iw_b : D_iw_c"],

      [["D_dst_regnum", $regnum_sz], 
        "D_ctrl_implicit_dst_retaddr ? $retaddr_regnum : 
         D_ctrl_implicit_dst_eretaddr ? $eretaddr_regnum : 
         D_dstfield_regnum"],

      [["D_wr_dst_reg", 1], 
        "(D_dst_regnum != 0) & ~D_ctrl_ignore_dst & D_valid"],
    );

    my @reg_cmp = (
        { divider => "reg_cmp" },
        { radix => "x", signal => "E_regnum_a_cmp_D" },
        { radix => "x", signal => "M_regnum_a_cmp_D" },
        { radix => "x", signal => "A_regnum_a_cmp_D" },
        { radix => "x", signal => "W_regnum_a_cmp_D" },
        { radix => "x", signal => "E_regnum_b_cmp_D" },
        { radix => "x", signal => "M_regnum_b_cmp_D" },
        { radix => "x", signal => "A_regnum_b_cmp_D" },
        { radix => "x", signal => "W_regnum_b_cmp_D" },
        { radix => "x", signal => "D_ctrl_a_is_src" },
        { radix => "x", signal => "D_ctrl_b_is_src" },
        { radix => "x", signal => "D_ctrl_ignore_dst" },
        { radix => "x", signal => "D_ctrl_src2_choose_imm" },
        { radix => "x", signal => "D_src1_other_rs" },
        { radix => "x", signal => "D_data_depend" },
        { radix => "x", signal => "D_dstfield_regnum" },
        { radix => "x", signal => "D_dst_regnum" },
        { radix => "x", signal => "D_wr_dst_reg" },
        { radix => "x", signal => "E_ctrl_late_result" },
        { radix => "x", signal => "M_ctrl_late_result" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @reg_cmp);
    }
}




sub 
make_src_operands
{
    my $Opt = shift;


    e_assign->adds(
      [["E_fwd_reg_data", $datapath_sz], "E_alu_result"],
      );




    e_mux->add ({
      lhs => ["D_src1_reg", $datapath_sz],
      type => "priority",
      table => [
        "D_iw_a == 0"       => "32'b0",
        "D_src1_choose_E"   => "E_fwd_reg_data",
        "D_src1_choose_M"   => "M_fwd_reg_data",
        "D_src1_choose_A"   => "A_fwd_reg_data",
        "D_src1_choose_W"   => "W_wr_data",
        "1'b1"              => "D_rf_a",
        ],
      });

    e_assign->adds(
      [["D_src1", $datapath_sz], "D_src1_reg"],
      );







    e_mux->add ({
      lhs => ["D_src2_reg", $datapath_sz],
      type => "priority",
      table => [
        "D_iw_b == 0"       => "32'b0",
        "D_src2_choose_E"   => "E_fwd_reg_data",
        "D_src2_choose_M"   => "M_fwd_reg_data",
        "D_src2_choose_A"   => "A_fwd_reg_data",
        "D_src2_choose_W"   => "W_wr_data",
        "1'b1"              => "D_rf_b",
        ],
      });



    e_assign->adds(
      [["D_src2_imm_sel", 2], "{D_ctrl_hi_imm16,D_ctrl_unsigned_lo_imm16}"],
      );


    my $imm16_sex_datapath_sz = $datapath_sz - 16;    

    e_mux->add ({
      lhs => ["D_src2_imm", $datapath_sz],
      selecto => "D_src2_imm_sel",
      table => [
        "2'b00" => "{{$imm16_sex_datapath_sz {D_iw_imm16[15]}}, D_iw_imm16}",
        "2'b01" => "{{$imm16_sex_datapath_sz {1'b0}}          , D_iw_imm16}",
        "2'b10" => "{D_iw_imm16                               , 16'b0     }",
        "2'b11" => "{{$imm16_sex_datapath_sz {1'b0}}          , 16'b0     }",
        ],
      });


    e_assign->adds(
      [["D_src2", $datapath_sz],
        "D_ctrl_src2_choose_imm ? D_src2_imm : D_src2_reg"],
      );


    e_register->adds(
      {out => ["E_src1", $datapath_sz],     in => "D_src1", 
       enable => "E_en"},
      {out => ["E_src2", $datapath_sz],     in => "D_src2", 
       enable => "E_en"},
      {out => ["E_src2_reg", $datapath_sz], in => "D_src2_reg", 
       enable => "E_en"},
    );

    if (!$hw_div) {




        e_register->adds(
          {out => ["M_src1", $datapath_sz, 0, $force_never_export],
           in => "E_src1", enable => "M_en"},
          {out => ["M_src2", $datapath_sz, 0, $force_never_export], 
           in => "E_src2", enable => "M_en"},
        );
    }



    e_register->adds(
      {out => ["A_src2", $datapath_sz, 0, $force_never_export],
       in => "M_src2", enable => "A_en"},
    );

    my @src_operands = (
        { divider => "src_operands" },
        { radix => "x", signal => "D_src1_choose_E" },
        { radix => "x", signal => "D_src1_choose_M" },
        { radix => "x", signal => "D_src1_choose_A" },
        { radix => "x", signal => "D_src1_choose_W" },
        { radix => "x", signal => "D_src2_choose_E" },
        { radix => "x", signal => "D_src2_choose_M" },
        { radix => "x", signal => "D_src2_choose_A" },
        { radix => "x", signal => "D_src2_choose_W" },
        { radix => "x", signal => "D_src1_reg" },
        { radix => "x", signal => "D_src1" },
        { radix => "x", signal => "D_src2_imm" },
        { radix => "x", signal => "D_src2_reg" },
        { radix => "x", signal => "D_src2_imm_sel" },
        { radix => "x", signal => "D_src2" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "M_src1" },
        { radix => "x", signal => "M_src2" },
        { radix => "x", signal => "A_src2" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @src_operands);
    }
}




sub 
make_alu_controls
{
    my $Opt = shift;





    e_assign->adds(
      [["D_logic_op_raw", $logic_op_sz],
        "(D_op_opx ? D_iw_opx[$logic_op_msb:$logic_op_lsb] : 
          D_iw_op[$logic_op_msb:$logic_op_lsb])"],

      [["D_logic_op", $logic_op_sz],
        "D_ctrl_alu_force_xor ? $logic_op_xor : D_logic_op_raw"],

      [["D_compare_op", $compare_op_sz],
        "(D_op_opx ? D_iw_opx[$compare_op_msb:$compare_op_lsb] : 
          D_iw_op[$compare_op_msb:$compare_op_lsb])"],
      );


    e_register->adds(
      {out => ["E_logic_op", $logic_op_sz], in => "D_logic_op", 
       enable => "E_en"},
      {out => ["E_compare_op", $compare_op_sz], in => "D_compare_op", 
       enable => "E_en"},
    );
}




sub 
make_internal_interrupt_controller
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");



    if ($advanced_exc) {



        e_assign->adds(
          [["norm_intr_req", 1], 
            "${cs}_status_reg_pie & (${cs}_ipending_reg != 0)"],
        );




        e_register->adds(
          {out => ["M_norm_intr_req", 1], 
           in => "norm_intr_req", enable => "M_en" },
        );
    } else {
        e_register->adds(
          {out => ["${cs}_valid_wrctl_ienable", 1],                  
           in => ((manditory_int($Opt, "internal_irq_mask") == 0) ?
              "0" :
              "${wss}_wrctl_ienable & ${wss}_valid"), 
           enable => "${cs}_en" },
        );
        





        e_assign->adds(
          [["norm_intr_req", 1], 
            "${cs}_status_reg_pie & (${cs}_ipending_reg != 0) &
             ~${cs}_valid_wrctl_ienable"],
      );
    }
}

sub
make_external_interrupt_controller
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    if (!$advanced_exc) {
        &$error("EIC can only be used with advanced exception pipeline");
    }


    my $eic_port_name = "interrupt_controller_in";
    my $eic_signal_prefix = "eic_port_";
    my @eic_port_signals = (["data" => $eic_port_sz],
                            ["valid" => 1]);
    
    e_signal->adds(map {[$eic_signal_prefix . $_->[0] => $_->[1]]} 
                       @eic_port_signals);
    
    my $eic_port_type_map = { map {$eic_signal_prefix . $_->[0] => $_->[0]}
                                  @eic_port_signals };
    
    e_atlantic_slave->add({
        name => $eic_port_name,
        type_map => $eic_port_type_map,
    });


    e_assign->adds(
      [["eic_port_data_ril", $eic_port_ril_sz], 
       "eic_port_data[$eic_port_ril_msb:$eic_port_ril_lsb]"],
      [["eic_port_data_rnmi", 1], 
       "eic_port_data[$eic_port_rnmi_lsb]"],
      [["eic_port_data_rha", $eic_port_rha_sz], 
       "eic_port_data[$eic_port_rha_msb:$eic_port_rha_lsb]"],
      [["eic_port_data_rrs", $eic_port_rrs_sz, 0, $force_never_export], 
       "eic_port_data[$eic_port_rrs_msb:$eic_port_rrs_lsb]"],
    );



    e_register->adds(
      {out => ["eic_ril", $status_reg_il_sz], 
       in => "eic_port_data_ril",
       enable => "eic_port_valid"},
      {out => ["eic_rnmi", 1], 
       in => "eic_port_data_rnmi",
       enable => "eic_port_valid"},
      {out => ["eic_rha", $pcb_sz], 
       in => "eic_port_data_rha",
       enable => "eic_port_valid"},
    );

    if ($shadow_present) {
        e_register->adds(
          {out => ["eic_rrs", $rf_set_sz], 
           in => "eic_port_data_rrs",
           enable => "eic_port_valid"},
        );
    }

    e_assign->adds(
      [["nmi_req", 1], 
        "eic_rnmi & (eic_ril != 0) & ~${cs}_status_reg_nmi"],
      [["mi_req", 1], 
        "~eic_rnmi & (eic_ril > ${cs}_status_reg_il) & ${cs}_status_reg_pie" .
        ($shadow_present ?
          " & ((eic_rrs != ${cs}_status_reg_crs) | ${cs}_status_reg_rsie)" :
          "")],




      [["ext_intr_req", 1], "(nmi_req | mi_req) & oci_ienable[0]"],
    );



    e_register->adds(
      {out => ["M_ext_intr_req", 1], 
       in => "ext_intr_req", 
       enable => "M_en" },

      {out => ["M_eic_ril", $status_reg_il_sz], 
       in => "eic_ril", 
       enable => "M_en" },
      {out => ["M_eic_rnmi", 1], 
       in => "eic_rnmi", 
       enable => "M_en" },
      {out => ["M_eic_rha", $pcb_sz], 
       in => "eic_rha", 
       enable => "M_en" },

      {out => ["A_eic_ril", $status_reg_il_sz], 
       in => "M_eic_ril", 
       enable => "A_en" },
      {out => ["A_eic_rnmi", 1], 
       in => "M_eic_rnmi", 
       enable => "A_en" },
      {out => ["A_eic_rha", $pcb_sz, 0, $force_never_export], 
       in => "M_eic_rha", 
       enable => "A_en" },
    );

    if ($shadow_present) {
        e_register->adds(
          {out => ["M_eic_rrs", $rf_set_sz], 
           in => "eic_rrs", 
           enable => "M_en" },
          {out => ["A_eic_rrs", $rf_set_sz], 
           in => "M_eic_rrs", 
           enable => "A_en" },
          {out => ["A_eic_rrs_non_zero", 1], 
           in => "M_eic_rrs != 0", 
           enable => "A_en" },
        );
    }

    my @mem_load_store_wave_signals = (
        { divider => "EIC Port" },
        { radix => "x", signal => "eic_port_valid" },
        { radix => "x", signal => "eic_port_data_ril" },
        { radix => "x", signal => "eic_port_data_rnmi" },
        { radix => "x", signal => "eic_port_data_rha" },
        { radix => "x", signal => "eic_port_data_rrs" },
        { radix => "x", signal => "eic_ril" },
        { radix => "x", signal => "eic_rnmi" },
        { radix => "x", signal => "eic_rha" },
        $shadow_present ? { radix => "x", signal => "eic_rrs" } : "",
        { radix => "x", signal => "nmi_req" },
        { radix => "x", signal => "mi_req" },
        { radix => "x", signal => "ext_intr_req" },
    );

    if (manditory_bool($Opt, "full_waveform_signals")) {
        push(@plaintext_wave_signals, @mem_load_store_wave_signals);
    }
}




sub
make_dcache_controls
{
    my $Opt = shift;









    my $gen_info = manditory_hash($Opt, "gen_info");
    my $bypass_stages = 
      ($tlb_present || $mpu_present) ? ["M", "A"] : ["E", "M", "A"];
    my $bs = ($tlb_present || $mpu_present) ? "M" : "E";





    e_assign->adds(
      [["${bs}_ld_cache", 1], 
        "${bs}_ctrl_ld_non_io & ~${bs}_mem_bypass_non_io & ${bs}_sel_data_master"],
      [["${bs}_st_cache", 1], 
        "${bs}_ctrl_st_non_io & ~${bs}_mem_bypass_non_io & ${bs}_sel_data_master"],
      [["${bs}_ld_st_cache", 1], 
        "${bs}_ctrl_ld_st_non_io & ~${bs}_mem_bypass_non_io & ${bs}_sel_data_master"],
      [["${bs}_ld_st_cache_non_st32", 1], 
        "${bs}_ctrl_ld_st_non_io_non_st32 & ~${bs}_mem_bypass_non_io & ${bs}_sel_data_master"],

      [["${bs}_ld_bus", 1], 
        "(${bs}_ctrl_ld_io | (${bs}_ctrl_ld_non_io & ${bs}_mem_bypass_non_io)) & ${bs}_sel_data_master"],
      [["${bs}_st_bus", 1], 
        "(${bs}_ctrl_st_io | (${bs}_ctrl_st_non_io & ${bs}_mem_bypass_non_io)) & ${bs}_sel_data_master"],
      [["${bs}_st_bus_non_st32", 1], 
        "(${bs}_ctrl_st_io_non_st32 | (${bs}_ctrl_st_non_io_non_st32 & ${bs}_mem_bypass_non_io)) & ${bs}_sel_data_master"],
      [["${bs}_ld_st_bus", 1], 
        "(${bs}_ctrl_ld_st_io | (${bs}_ctrl_ld_st_non_io & ${bs}_mem_bypass_non_io)) & ${bs}_sel_data_master"],
      [["${bs}_ld_st_dcache_management_bus", 1], 
        "${bs}_ld_st_bus | ${bs}_ctrl_dcache_management"],

      [["${bs}_ld_tcm", 1], "${bs}_ctrl_ld & ~${bs}_sel_data_master"],
      [["${bs}_st_tcm", 1], "${bs}_ctrl_st & ~${bs}_sel_data_master"],
      [["${bs}_ld_st_tcm", 1], "${bs}_ctrl_ld_st & ~${bs}_sel_data_master"],
      [["${bs}_ld_st_tcm_non_st32", 1], "${bs}_ctrl_ld_st_non_st32 & ~${bs}_sel_data_master"],
    );


    cpu_pipeline_control_signal($gen_info, "ctrl_ld_bypass", $bypass_stages, "${bs}_ld_bus");
    cpu_pipeline_control_signal($gen_info, "ctrl_st_bypass", $bypass_stages, "${bs}_st_bus");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_bypass", $bypass_stages, "${bs}_ld_st_bus");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_bypass_or_dcache_management", $bypass_stages,
      "${bs}_ld_st_dcache_management_bus");


    cpu_pipeline_control_signal($gen_info, "ctrl_ld_non_bypass", $bypass_stages,
      "${bs}_ld_cache | ${bs}_ld_tcm");
    cpu_pipeline_control_signal($gen_info, "ctrl_st_non_bypass", $bypass_stages,
      "${bs}_st_cache | ${bs}_st_tcm");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_non_bypass", $bypass_stages, 
      "${bs}_ld_st_cache | ${bs}_ld_st_tcm");
    cpu_pipeline_control_signal($gen_info, "ctrl_ld_st_non_bypass_non_st32", $bypass_stages,
      "${bs}_ld_st_cache_non_st32 | ${bs}_ld_st_tcm_non_st32");






    
    if ($wide_dcache_present) {
        cpu_pipeline_control_signal($gen_info, "ctrl_mem_dc_tag_rd", $bypass_stages,
          "${bs}_ld_cache | 
           ${bs}_st_cache | 
           ${bs}_st_bus |
           ${bs}_ctrl_dc_index_wb_inv |
           ${bs}_ctrl_dc_addr_wb_inv |
           ${bs}_ctrl_dc_addr_nowb_inv");
    } else {
        cpu_pipeline_control_signal($gen_info, "ctrl_mem_dc_tag_rd", $bypass_stages,
          "${bs}_ld_cache | 
           ${bs}_st_cache | 
           ${bs}_st_bus");
    }








    cpu_pipeline_control_signal($gen_info, "ctrl_mem_dc_data_rd", $bypass_stages,
      "${bs}_ld_cache | 
       ${bs}_st_cache | 
       ${bs}_st_bus_non_st32");



    if ($mmu_present) {


        e_assign->adds(
          [["M_mem_bypass_non_io", 1],
             "M_mem_baddr_io_region | 
               (~M_mem_baddr_kernel_region & ~M_udtlb_c)"],
        );
    }
}




sub 
make_tlb_data
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    my $data_addr_phy_sz  = manditory_int($Opt, "d_Address_Width");


    my $imm16_sex_datapath_sz = $datapath_sz - 16;    

    e_assign->adds(

      [["E_mem_baddr_for_vpn", $datapath_sz], 
        "E_src1 + {{$imm16_sex_datapath_sz {E_iw_imm16[15]}}, E_iw_imm16}"],


      [["E_mem_baddr_vpn", $mmu_addr_vpn_sz], 
        "E_mem_baddr_for_vpn[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"],
 

      [["A_mem_baddr_vpn", $mmu_addr_vpn_sz], 
        "A_mem_baddr[$mmu_addr_vpn_msb:$mmu_addr_vpn_lsb]"], 


      [["M_mem_baddr_page_offset", $mmu_addr_page_offset_sz], 
        "M_mem_baddr[$mmu_addr_page_offset_msb:$mmu_addr_page_offset_lsb]"], 


      [["M_mem_baddr_kernel_region", 1],
        "M_mem_baddr[$mmu_addr_kernel_region_msb:$mmu_addr_kernel_region_lsb]
          == $mmu_addr_kernel_region"],

      [["M_mem_baddr_io_region", 1],
        "M_mem_baddr[$mmu_addr_io_region_msb:$mmu_addr_io_region_lsb] 
          == $mmu_addr_io_region"],

      [["M_mem_baddr_user_region", 1],
        "M_mem_baddr[$mmu_addr_user_region_msb:$mmu_addr_user_region_lsb]
          == $mmu_addr_user_region"],
      [["M_mem_baddr_supervisor_region", 1], "~M_mem_baddr_user_region"],


      [["M_mem_baddr_bypass_tlb", 1], 
        "M_mem_baddr_kernel_region | M_mem_baddr_io_region"],
    );


    e_register->adds(
      {out => ["M_mem_baddr_vpn", $mmu_addr_vpn_sz], 
       in => "E_mem_baddr_vpn",                     enable => "M_en"},
    );





    new_exc_signal({
        exc             => $tlb_data_miss_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_mem_data_access & !M_mem_baddr_corrupt &
           (~M_mem_baddr_bypass_tlb & M_udtlb_hit & M_udtlb_m)",
    });





    new_exc_signal({
        exc             => $tlb_r_perm_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_ld & !M_mem_baddr_corrupt & (
            (~M_mem_baddr_bypass_tlb & M_udtlb_hit & ~M_udtlb_r) |
            (M_mem_baddr_supervisor_region & ${cs}_status_reg_u)
          )",
    });





    new_exc_signal({
        exc             => $tlb_w_perm_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "M_ctrl_st & !M_mem_baddr_corrupt & (
            (~M_mem_baddr_bypass_tlb & M_udtlb_hit & ~M_udtlb_w) |
            (M_mem_baddr_supervisor_region & ${cs}_status_reg_u)
          )",
    });


    my $udtlb_wave_signals = nios2_mmu::make_utlb($Opt, 1);


    e_register->adds(
      {out => ["A_mem_baddr_phy_got_pfn", 1], 
       in => "M_mem_baddr_phy_got_pfn",             enable => "A_en"},

      {out => ["A_mem_baddr_phy", $data_addr_phy_sz, 0, $force_never_export],
       in => "M_mem_baddr_phy",                     enable => "A_en"},
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          @$udtlb_wave_signals,
          { divider => "TLB Data Exceptions" },
          get_exc_signal_wave($tlb_data_miss_exc, "M"),
          get_exc_signal_wave($tlb_r_perm_exc, "M"),
          get_exc_signal_wave($tlb_w_perm_exc, "M"),
        );
    }
}




sub 
make_dmpu
{
    my $Opt = shift;

    my $cs = not_empty_scalar($Opt, "control_reg_stage");


    my $imm16_sex_datapath_sz = $datapath_sz - 16;    

    e_assign->adds(

      [["E_mem_baddr_for_dmpu", $datapath_sz], 
        "E_src1 + {{$imm16_sex_datapath_sz {E_iw_imm16[15]}}, E_iw_imm16}"],
    );


    e_mux->add ({
      lhs => ["M_dmpu_good_perm", 1],
      selecto => "M_dmpu_perm",
      table => [
        $mpu_data_perm_super_none_user_none => 
          "0",
        $mpu_data_perm_super_rd_user_none   => 
          "~${cs}_status_reg_u & M_ctrl_ld",
        $mpu_data_perm_super_rd_user_rd     => 
          "M_ctrl_ld",
        $mpu_data_perm_super_rw_user_none   => 
          "~${cs}_status_reg_u",
        $mpu_data_perm_super_rw_user_rd     =>
          "~${cs}_status_reg_u | (${cs}_status_reg_u & M_ctrl_ld)",
        $mpu_data_perm_super_rw_user_rw     =>
          "1",
        ],
      default => "0",
    });






    my @dmpu_exc_conds = ("~M_dmpu_hit", "~M_dmpu_good_perm");

    my $unused_mem_baddr_msb = 
      manditory_bool($Opt, "bit_31_bypass_dcache") ? 30 : 31;
    my $unused_mem_baddr_lsb = manditory_int($Opt, "d_Address_Width");
    my $unused_mem_baddr_sz = $unused_mem_baddr_msb - $unused_mem_baddr_lsb + 1;

    if ($unused_mem_baddr_sz > 0) {
        push(@dmpu_exc_conds, 
          "(M_mem_baddr[$unused_mem_baddr_msb:$unused_mem_baddr_lsb] != 0)");
    }

    new_exc_signal({
        exc             => $mpu_data_region_violation_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => 
          "${cs}_config_reg_pe & ~W_debug_mode & !M_mem_baddr_corrupt & " .
          "M_ctrl_mem_data_access & (" . join('|', @dmpu_exc_conds) . ")",
    });


    my $dmpu_region_wave_signals = nios2_mpu::make_mpu_regions($Opt, 1);

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, 
          @$dmpu_region_wave_signals,
          { divider => "DMPU Exceptions" },
          get_exc_signal_wave($mpu_data_region_violation_exc, "M"),
        );
    }
}

sub
make_imprecise_illegal_addr_detector
{
    my $Opt = shift;

    my $whoami = "imprecise_illegal_addr_detector";

    if ($advanced_exc) {
        &$error("$whoami: Can't be used when advanced exception support" .
          " is present");
    }


    foreach my $just_readonly (0, 1) {
        my $data_match_suffix = "_mem_baddr_legal_" .
          ($just_readonly ? "readonly_addr" : "addr");
        my $M_stage_data_match = "M" . $data_match_suffix;

        make_address_range_detector({
          slave_infos   => $Opt->{avalon_data_slaves},
          addr_signal   => "M_mem_baddr", 
          addr_sz       => $mem_baddr_sz, 
          match_signal  => $M_stage_data_match,
          just_readonly => $just_readonly,
        });
    }


    my $inst_match_suffix = "_pcb_legal_addr";
    my $E_stage_inst_match = "E" . $inst_match_suffix;
    my $M_stage_inst_match = "M" . $inst_match_suffix;

    make_address_range_detector({
      slave_infos   => $Opt->{avalon_instruction_slaves},
      addr_signal   => "E_pcb", 
      addr_sz       => $pcb_sz, 
      match_signal  => $E_stage_inst_match,
    });

    e_assign->adds(

      [["M_illegal_mem_addr", 1], 
        "M_ctrl_mem_data_access & ~M_mem_baddr_legal_addr"],


      [["M_illegal_st_addr", 1], "M_ctrl_st & M_mem_baddr_legal_readonly_addr"],


      [["M_mem_data_addr_exception", 1],
        "M_illegal_mem_addr | M_illegal_st_addr"],


      [["M_misaligned_jmp_indirect", 1],
        "M_ctrl_jmp_indirect & (M_target_pcb[1:0] != 2'b00)"],
      [["M_misaligned_br", 1],
        "M_ctrl_br & (M_iw_imm16[1:0] != 2'b00)"],
      [["M_misaligned_ld_st", 1],
        "(M_ctrl_mem32 & (M_mem_baddr[1:0] != 2'b00)) |
         (M_ctrl_mem16 & (M_mem_baddr[0]   != 1'b0))"],


      [["M_misaligned", 1],
        "M_misaligned_jmp_indirect | M_misaligned_br | M_misaligned_ld_st"],



      [["M_mem_addr_exception", 1],
        "M_mem_data_addr_exception | ~M_pcb_legal_addr | M_misaligned"],











      [["mem_exception_pending_nxt", 1],
        "(~A_exception_reg_mee_nxt & M_en) ? 1'b0 :
         (A_valid & A_mem_addr_exception & A_exception_reg_mee) ? 1'b1 :
         mem_exception_pending"],
    );

    e_register->adds(

      {out => [$M_stage_inst_match, 1], in => $E_stage_inst_match, 
       enable => "M_en"},



      {out => ["A_mem_addr_exception", 1], in => "M_mem_addr_exception", 
       enable => "A_en"},


      {out => ["mem_exception_pending", 1],
       in => "mem_exception_pending_nxt", enable => "1'b1" },
    );

    my @wave_signals = (
      { divider => $whoami },
      { radix => "x", signal => "E_valid" },
      { radix => "x", signal => "E_pcb" },
      { radix => "x", signal => "E_pcb_legal_addr" },
      { radix => "x", signal => "M_valid" },
      { radix => "x", signal => "M_ctrl_mem" },
      { radix => "x", signal => "M_ctrl_st" },
      { radix => "x", signal => "M_mem_baddr" },
      { radix => "x", signal => "M_mem_baddr_legal_addr" },
      { radix => "x", signal => "M_mem_baddr_legal_readonly_addr" },
      { radix => "x", signal => "M_illegal_mem_addr" },
      { radix => "x", signal => "M_illegal_st_addr" },
      { radix => "x", signal => "M_pcb_legal_addr" },
      { radix => "x", signal => "M_misaligned_jmp_indirect" },
      { radix => "x", signal => "M_misaligned_br" },
      { radix => "x", signal => "M_misaligned_ld_st" },
      { radix => "x", signal => "M_misaligned" },
      { radix => "x", signal => "M_mem_addr_exception" },
      { radix => "x", signal => "A_valid" },
      { radix => "x", signal => "mem_exception_pending_nxt" },
      { radix => "x", signal => "mem_exception_pending" },
      { radix => "x", signal => "A_exception_reg_mee_nxt" },
      { radix => "x", signal => "A_exception_reg_mee" },
      { radix => "x", signal => "A_exception_reg_mea_nxt" },
      { radix => "x", signal => "A_exception_reg_mea" },
      { radix => "x", signal => "A_mem_addr_exception" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @wave_signals);
    }
}

sub
make_slave_access_error_detector
{
    my $Opt = shift;

    my $whoami = "slave_access_error_detector";

    my $cs = not_empty_scalar($Opt, "control_reg_stage");

    if ($mmu_present) {
        &$error("$whoami: Can't be used when the MMU is present");
    }







    my $cmp_mem_baddr_sz = manditory_int($Opt, "d_Address_Width");

    e_assign->adds(
      [["M_mem_baddr_saed", $cmp_mem_baddr_sz], 
        "M_mem_baddr[$cmp_mem_baddr_sz-1:0]"],
    );

    foreach my $just_readonly (0, 1) {
        my $data_match_suffix = "_mem_baddr_legal_" .
          ($just_readonly ? "readonly_addr" : "addr");
        my $M_stage_data_match = "M" . $data_match_suffix;

        make_address_range_detector({
          slave_infos   => $Opt->{avalon_data_slaves},
          addr_signal   => "M_mem_baddr_saed", 
          addr_sz       => $cmp_mem_baddr_sz, 
          match_signal  => $M_stage_data_match,
          just_readonly => $just_readonly,
        });
    }




    my $inst_match_suffix = "_pcb_legal_addr";
    my $E_stage_inst_match = "E" . $inst_match_suffix;


    my $cmp_pcb_sz = manditory_int($Opt, "i_Address_Width");

    e_assign->adds(
      [["E_pcb_saed", $cmp_pcb_sz], 
        "E_pcb[$cmp_pcb_sz-1:0]"],
    );

    make_address_range_detector({
      slave_infos   => $Opt->{avalon_instruction_slaves},
      addr_signal   => "E_pcb_saed", 
      addr_sz       => $cmp_pcb_sz, 
      match_signal  => $E_stage_inst_match,
    });

    e_assign->adds(

      [["M_illegal_mem_addr", 1], 
        "M_ctrl_mem_data_access & ~M_mem_baddr_legal_addr"],


      [["M_illegal_st_addr", 1], "M_ctrl_st & M_mem_baddr_legal_readonly_addr"],
    );


    new_exc_signal({
        exc             => $empty_slave_inst_access_error_exc,
        initial_stage   => "E", 
        speedup_stage   => "E",
        rhs             => "~E_pcb_legal_addr & ${cs}_exception_reg_mee & !E_mem_baddr_corrupt",
    });


    new_exc_signal({
        exc             => $empty_slave_data_access_error_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => "M_illegal_mem_addr & ${cs}_exception_reg_mee & !M_mem_baddr_corrupt",
    });


    new_exc_signal({
        exc             => $readonly_slave_data_access_error_exc,
        initial_stage   => "M", 
        speedup_stage   => "M",
        rhs             => "M_illegal_st_addr & ${cs}_exception_reg_mee & !M_mem_baddr_corrupt",
    });

    my @wave_signals = (
      { divider => $whoami },
      { radix => "x", signal => "E_valid" },
      { radix => "x", signal => "E_pcb" },
      { radix => "x", signal => "E_pcb_legal_addr" },
      get_exc_signal_wave($empty_slave_inst_access_error_exc, "E"),
      { radix => "x", signal => "M_valid" },
      { radix => "x", signal => "M_ctrl_mem" },
      { radix => "x", signal => "M_ctrl_st" },
      { radix => "x", signal => "M_mem_baddr" },
      { radix => "x", signal => "M_mem_baddr_legal_addr" },
      { radix => "x", signal => "M_mem_baddr_legal_readonly_addr" },
      { radix => "x", signal => "M_illegal_mem_addr" },
      { radix => "x", signal => "M_illegal_st_addr" },
      get_exc_signal_wave($empty_slave_inst_access_error_exc, "M"),
      get_exc_signal_wave($empty_slave_data_access_error_exc, "M"),
      get_exc_signal_wave($readonly_slave_data_access_error_exc, "M"),
      { radix => "x", signal => "${cs}_exception_reg_mee_nxt" },
      { radix => "x", signal => "${cs}_exception_reg_mee" },
      { radix => "x", signal => "${cs}_exception_reg_mea_nxt" },
      { radix => "x", signal => "${cs}_exception_reg_mea" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @wave_signals);
    }
}




sub 
make_potential_tb_logic
{
    my $Opt = shift;

    e_assign->adds(
      [["E_src1_eq_src2", 1], "E_logic_result == 0"],
    );
}

1;
