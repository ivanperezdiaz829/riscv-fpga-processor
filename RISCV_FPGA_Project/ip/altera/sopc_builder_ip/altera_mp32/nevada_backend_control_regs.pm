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






















package nevada_backend_control_regs;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &be_set_control_reg_pipeline_desc
    &be_make_control_regs
);

use cpu_utils;
use cpu_wave_signals;
use cpu_control_reg;
use cpu_control_reg_gen;
use cpu_exception_gen;
use nios_europa;
use nios_common;
use nios_isa;
use nevada_common;
use nevada_isa;
use nevada_insts;
use nevada_control_regs;
use nevada_exceptions;
use europa_all;
use europa_utils;
use strict;





sub
be_set_control_reg_pipeline_desc
{
    my $Opt = shift;

    my $pipeline_desc = {
        stages => manditory_array($Opt, "stages"),
        control_reg_stage => not_empty_scalar($Opt, "control_reg_stage"),
        rdctl_stage => not_empty_scalar($Opt, "rdctl_stage"),
        wrctl_setup_stage => not_empty_scalar($Opt, "wrctl_setup_stage"),
        wrctl_data => not_empty_scalar($Opt, "wrctl_data"),
        regnum_field => $rd_inst_field,
        select_field => $select_inst_field,
    };

    if (!defined(set_control_reg_pipeline_desc($pipeline_desc))) {
        &$error("set_control_reg_pipeline_desc() failed");
    }
}





sub 
be_make_control_regs
{
    my $Opt = shift;

    my $control_regs = manditory_array($Opt, "control_regs");
    my $timer_ip_num = manditory_int($Opt, "timer_ip_num");

    if ($tlb_present) {
        my $tlb_num_entries = manditory_int($Opt, "tlb_num_entries"); 





        set_control_reg_field_pri_mux_table($cop0_index_reg_index, [
            "A_tlbp_done" => "tlb_match ? tlb_match_tlb_index : 0",
        ]);
        set_control_reg_field_pri_mux_table($cop0_index_reg_p, [
            "A_tlbp_done" => "~tlb_match",
        ]);
    













        my $lfsr_sz = 12;

        e_register->adds(
          {out    => ["A_random_reg_lfsr", $lfsr_sz],
           in     => "{ 
             A_random_reg_lfsr[$lfsr_sz-2:0],
             (A_random_reg_lfsr[11] ^ A_random_reg_lfsr[10] ^
              A_random_reg_lfsr[9] ^ A_random_reg_lfsr[3])
            }",
           enable => "(A_valid | A_exc_any_active) & A_en",
           async_value => ((0x1 << $lfsr_sz) - 1),
           },
        );
        







        set_control_reg_field_pri_mux_table($cop0_random_reg_random, [
            "A_wrctl_cop0_wired & A_valid" => 
              ($tlb_num_entries - 1),
            "(A_valid | A_exc_any_active) & A_en & " .
              "A_random_reg_lfsr[$lfsr_sz-1] & ~W_debug_mode" => 
                  "(W_cop0_random_reg_random == ($tlb_num_entries - 1)) ?
                      W_cop0_wired_reg_wired :
                      (W_cop0_random_reg_random + 1)",
        ]);
        




        set_control_reg_field_pri_mux_table($cop0_entry_lo_0_reg_g, [
            "A_tlbr_tag_addr_d1" => "tlb_rd_g",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_0_reg_v, [
            "A_tlbr_even_addr_d1" => "tlb_rd_v",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_0_reg_d, [
            "A_tlbr_even_addr_d1" => "tlb_rd_d",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_0_reg_c, [
            "A_tlbr_even_addr_d1" => 
              "tlb_rd_c ? $coherency_cached : $coherency_uncached",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_0_reg_pfn, [
            "A_tlbr_even_addr_d1" => "tlb_rd_pfn",
        ]);
    




        set_control_reg_field_pri_mux_table($cop0_entry_lo_1_reg_g, [
            "A_tlbr_tag_addr_d1" => "tlb_rd_g",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_1_reg_v, [
            "A_tlbr_odd_addr_d1" => "tlb_rd_v",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_1_reg_d, [
            "A_tlbr_odd_addr_d1" => "tlb_rd_d",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_1_reg_c, [
            "A_tlbr_odd_addr_d1" => 
              "tlb_rd_c ? $coherency_cached : $coherency_uncached",
        ]);
        set_control_reg_field_pri_mux_table($cop0_entry_lo_1_reg_pfn, [
            "A_tlbr_odd_addr_d1" => "tlb_rd_pfn",
        ]);
    




        set_control_reg_field_pri_mux_table($cop0_context_reg_bad_vpn2, [
            "A_exc_tlb_active & ~W_debug_mode" => "A_exc_vpn2",
        ]);
    




        set_control_reg_field_pri_mux_table($cop0_page_mask_reg_mask, [
            "A_tlbr_tag_addr_d1" => "tlb_rd_page_mask",
        ]);
    





        set_control_reg_field_pri_mux_table($cop0_entry_hi_reg_asid, [
            "A_tlbr_tag_addr_d1" => "tlb_rd_asid",
        ]);


        set_control_reg_field_pri_mux_table($cop0_entry_hi_reg_vpn2, [
            "A_tlbr_tag_addr_d1" => "tlb_rd_vpn2",
            "A_exc_tlb_active & ~W_debug_mode" => "A_exc_vpn2",
        ]);
    }




    set_control_reg_field_pri_mux_table($cop0_bad_vaddr_reg_bad_vaddr, [
        "A_exc_record_baddr & ~W_debug_mode"  => "A_exc_highest_pri_baddr",
    ]);






    set_control_reg_field_pri_mux_table($cop0_count_reg_count, [
        "wrctl"                                => "",
        "~W_cop0_cause_reg_dc & ~W_debug_mode" => "W_cop0_count_reg_count + 1",
    ]);

    e_register->adds(

      {out    => ["W_valid_wrctl_cop0_compare", 1], 
       in     => "A_wrctl_cop0_compare & A_valid",
       enable => "W_en" },



      {out    => ["timer_irq_pending", 1], 
       in     => 
         "timer_irq_pending ?
           ~W_valid_wrctl_cop0_compare :
           (W_cop0_count_reg_count == W_cop0_compare_reg_compare)",
       enable => "1" },
    );




    set_control_reg_field_pri_mux_table($cop0_status_reg_ie, [
        "A_op_di & A_valid" => "0",
        "A_op_ei & A_valid" => "1",
    ]);




    set_control_reg_field_pri_mux_table($cop0_status_reg_exl, [
        "A_exc_active_no_debug_no_err & ~W_debug_mode" => "1",
        "A_op_eret & A_valid & ~W_cop0_status_reg_erl" => "0",
    ]);



    set_control_reg_field_pri_mux_table($cop0_status_reg_erl, [
        "A_exc_err_active & ~W_debug_mode" => "1",
        "A_op_eret & A_valid & W_cop0_status_reg_erl" => "0",
    ]);

    if ($nmi_present) {


    }

    if ($soft_reset_present) {


    }

    if ($eic_present) {





    }




    set_control_reg_field_pri_mux_table($cop0_cause_reg_exc_code, [
      "A_exc_active_no_debug_no_err & ~W_debug_mode" => 
        "A_exc_highest_pri_cause_code",
    ]);










    e_signal->adds({ name => "timer_irq", width => $interrupt_sz});
    for (my $irq = 0; $irq < $interrupt_sz; $irq++) {
        e_assign->adds(["timer_irq\[$irq]",
          ($irq == ($timer_ip_num - 2)) ? "timer_irq_pending" : "0"]);
    }

    set_control_reg_field_input_expr($cop0_cause_reg_ip_7_2,
      "d_irq[$interrupt_sz-1:0] | timer_irq");

    my $A_cop0_unusable_exc = get_exc_signal_name($cop0_unusable_exc, "A");
    my $A_cop1_unusable_exc = get_exc_signal_name($cop1_unusable_exc, "A");
    my $A_cop2_unusable_exc = get_exc_signal_name($cop2_unusable_exc, "A");

    set_control_reg_field_pri_mux_table($cop0_cause_reg_ce, [
      "A_exc_active_no_debug_no_err & ~W_debug_mode & $A_cop0_unusable_exc" =>
        "0",
      "A_exc_active_no_debug_no_err & ~W_debug_mode & $A_cop1_unusable_exc" => 
        "1",
      "A_exc_active_no_debug_no_err & ~W_debug_mode & $A_cop2_unusable_exc" =>
        "2",
    ]);

    set_control_reg_field_input_expr($cop0_cause_reg_ti, "timer_irq_pending");

    set_control_reg_field_pri_mux_table($cop0_cause_reg_bd, [
      "A_exc_active_no_debug_no_err & ~W_debug_mode & ~W_cop0_status_reg_exl" =>
        "A_is_delay_slot",
    ]);




    set_control_reg_field_pri_mux_table($cop0_epc_reg_epc, [
      "A_exc_active_no_debug_no_err & ~W_debug_mode & ~W_cop0_status_reg_exl" =>
        "A_is_delay_slot ? A_previous_pcb : A_pcb",
    ]);

    if ($debug_port_present) {



        set_control_reg_field_pri_mux_table($cop0_debug_reg_dss, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => 
            "A_exc_debug_single_step_active & ~W_debug_mode",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dbp, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => 
            "A_exc_sdbpp_inst_active & ~W_debug_mode",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dint, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => 
            "A_exc_debug_interrupt_active & ~W_debug_mode",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dib, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => 
            "A_exc_debug_hwbp_active & ~W_debug_mode",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dexc_code, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => 
            "W_debug_mode ? A_exc_highest_pri_cause_code : 0",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dm, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode) " => "1",
          "A_valid & A_op_deret"    => "0",
        ]);
        set_control_reg_field_pri_mux_table($cop0_debug_reg_dbd, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode)" => 
            "A_is_delay_slot",
        ]);




        set_control_reg_field_pri_mux_table($cop0_depc_reg_depc, [
          "A_exc_debug_active | (A_exc_any_active & W_debug_mode)"  => 
            "A_is_delay_slot ? A_previous_pcb : A_pcb",
        ]);
    }




    my $cache_icache_size = manditory_int($Opt, "cache_icache_size");
    my $cache_dcache_size = manditory_int($Opt, "cache_dcache_size");
    my $tag_pa_icache_pad = count2sz($cache_icache_size) - 8;
    my $tag_pa_dcache_pad = count2sz($cache_dcache_size) - 8;
    if ($tlb_present && ($tag_pa_dcache_pad > 4)) {
       $tag_pa_dcache_pad = 4;
    }
    if ($tlb_present && ($tag_pa_icache_pad > 4)) {
       $tag_pa_icache_pad = 4;
    }
    

    e_assign->adds(

      [["A_dc_actual_tag_pad", 24], "{A_dc_actual_tag, {$tag_pa_dcache_pad {1'b0}}}"],
      [["F_ic_tag_field_pad", 24], "{F_ic_tag_field, {$tag_pa_icache_pad {1'b0}}}"],
    );


    set_control_reg_field_pri_mux_table($cop0_tag_lo_0_reg_d, [
      "A_op_dcache_ld_tag & A_valid"  => "A_dc_dirty_raw",
      "A_op_icache_ld_tag & A_valid"  => "0",
    ]);
    set_control_reg_field_pri_mux_table($cop0_tag_lo_0_reg_v, [
      "A_op_dcache_ld_tag & A_valid"  => "A_dc_valid",
      "A_op_icache_ld_tag & A_valid & A_ic_op_start_d1"  => "A_ic_valid",
    ]);
    set_control_reg_field_pri_mux_table($cop0_tag_lo_0_reg_pa, [
      "A_op_dcache_ld_tag & A_valid"  => "A_dc_actual_tag_pad",
      "A_op_icache_ld_tag & A_valid & A_ic_op_start_d1"  => "F_ic_tag_field_pad",
    ]);




    set_control_reg_field_pri_mux_table($cop0_error_epc_reg_error_epc, [
      "A_exc_err_active & ~W_debug_mode"  => 
        "A_is_delay_slot ? A_previous_pcb : A_pcb",
    ]);







    foreach my $control_reg (@$control_regs) {
        my $reg_name = get_control_reg_name($control_reg);

        foreach my $field (@{get_control_reg_fields($control_reg)}) {
            my $field_name = get_control_reg_field_name($field);

            if (is_control_reg_field_readable($field)) {


                if (get_control_reg_field_input_expr($field) eq "") {
                    set_control_reg_field_auto_input($field, 1);
                }



                if (get_control_reg_field_wr_en_expr($field) eq "") {
                    set_control_reg_field_wr_en_expr($field, "1");
                }
            }
        }
    }


    my %rdctl_info = (




      "E" => [
        $cop0_hwr_ena_reg,
        $cop0_bad_vaddr_reg,
        $cop0_count_reg,
        $cop0_compare_reg,
        $cop0_status_reg, 
        $cop0_int_ctl_reg, 
        $cop0_srs_ctl_reg, 
        $cop0_cause_reg, 
        $cop0_epc_reg, 
      ],


      "M" => "remaining",


      default => "0",
    );


    if (!defined(gen_control_regs($control_regs, 
      \&nios_europa_assignment, \&nios_europa_register, 
      \&nios_europa_binary_mux, \%rdctl_info))) {
        &$error("gen_control_regs() failed");
    }

    my @wrctl_wave_signals;

    foreach my $control_reg (@{get_control_regs_sorted($control_regs)}) {
        if (get_control_reg_has_writeable_fields($control_reg)) {
            my $control_reg_num = get_control_reg_num($control_reg);
            my $control_reg_name = get_control_reg_name($control_reg);
    
            push(@wrctl_wave_signals,
              { radix => "x", signal => "A_wrctl_${control_reg_name}" },
            );
        }
    }

    my @control_registers = (
        { divider => "control_registers" },
        { radix => "x", signal => "M_ctrl_rdctl_inst" },
        { radix => "x", signal => "M_valid" },
        { radix => "x", signal => "M_iw_rd" },
        { radix => "x", signal => "M_iw_select" },
        { radix => "x", signal => "M_rdctl_data" },
        { radix => "x", signal => "A_ctrl_wrctl_inst" },
        { radix => "x", signal => "A_valid" },
        { radix => "x", signal => "A_iw_rd" },
        { radix => "x", signal => "A_iw_select" },
        $tlb_present ? { radix => "x", signal => "A_random_reg_lfsr" } : "",
        { radix => "x", signal => "timer_irq" },
        @wrctl_wave_signals,
        @{get_control_regs_for_waves($control_regs)},
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @control_registers);
    }
}

1;
