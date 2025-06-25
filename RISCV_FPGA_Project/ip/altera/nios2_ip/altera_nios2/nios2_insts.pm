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






















package nios2_insts;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $a_inst_field
    $b_inst_field
    $c_inst_field
    $custom_n_inst_field
    $custom_readra_inst_field
    $custom_readrb_inst_field
    $custom_writerc_inst_field
    $opx_inst_field
    $op_inst_field
    $shift_imm5_inst_field
    $trap_break_imm5_inst_field
    $imm5_inst_field
    $imm16_inst_field
    $imm26_inst_field
    $memsz_inst_field
    $control_regnum_inst_field

    $iw_a_sz $iw_a_lsb $iw_a_msb 
    $iw_b_sz $iw_b_lsb $iw_b_msb
    $iw_c_sz $iw_c_lsb $iw_c_msb 
    $iw_custom_n_sz $iw_custom_n_lsb $iw_custom_n_msb
    $iw_custom_readra_sz $iw_custom_readra_lsb $iw_custom_readra_msb
    $iw_custom_readrb_sz $iw_custom_readrb_lsb $iw_custom_readrb_msb
    $iw_custom_writerc_sz $iw_custom_writerc_lsb $iw_custom_writerc_msb
    $iw_opx_sz $iw_opx_lsb $iw_opx_msb
    $iw_op_sz $iw_op_lsb $iw_op_msb
    $iw_shift_imm5_sz $iw_shift_imm5_lsb $iw_shift_imm5_msb
    $iw_trap_break_imm5_sz $iw_trap_break_imm5_lsb $iw_trap_break_imm5_msb
    $iw_imm5_sz $iw_imm5_lsb $iw_imm5_msb
    $iw_imm16_sz $iw_imm16_lsb $iw_imm16_msb
    $iw_imm26_sz $iw_imm26_lsb $iw_imm26_msb
    $iw_memsz_sz $iw_memsz_lsb $iw_memsz_msb
    $iw_control_regnum_sz $iw_control_regnum_lsb $iw_control_regnum_msb 

    $iw_memsz_byte $iw_memsz_hword $iw_memsz_word_msb
    $logic_op_sz $logic_op_lsb $logic_op_msb
    $logic_op_nor $logic_op_and $logic_op_or $logic_op_xor
    $compare_op_sz $compare_op_lsb $compare_op_msb
    $compare_op_eq $compare_op_ge $compare_op_lt $compare_op_ne
    $jmp_callr_vs_ret_opx_bit $jmp_callr_vs_ret_is_ret
    $empty_intr_iw $empty_hbreak_iw $empty_crst_iw $empty_nop_iw $empty_ret_iw

    $call_inst
    $jmpi_inst
    $ldbu_inst
    $addi_inst
    $stb_inst
    $br_inst
    $ldb_inst
    $cmpgei_inst
    $ldhu_inst
    $andi_inst
    $sth_inst
    $bge_inst
    $ldh_inst
    $cmplti_inst
    $initda_inst
    $ori_inst
    $stw_inst
    $blt_inst
    $ldw_inst
    $cmpnei_inst
    $flushda_inst
    $xori_inst
    $stc_inst
    $bne_inst
    $ldl_inst
    $cmpeqi_inst
    $ldbuio_inst
    $muli_inst
    $stbio_inst
    $beq_inst
    $ldbio_inst
    $cmpgeui_inst
    $ldhuio_inst
    $andhi_inst
    $sthio_inst
    $bgeu_inst
    $ldhio_inst
    $cmpltui_inst
    $initd_inst
    $orhi_inst
    $stwio_inst
    $bltu_inst
    $ldwio_inst
    $rdprs_inst
    $flushd_inst
    $xorhi_inst

    $eret_inst
    $roli_inst
    $rol_inst
    $flushp_inst
    $ret_inst
    $nor_inst
    $mulxuu_inst
    $cmpge_inst
    $bret_inst
    $ror_inst
    $flushi_inst
    $jmp_inst
    $and_inst
    $cmplt_inst
    $slli_inst
    $sll_inst
    $wrprs_inst
    $or_inst
    $mulxsu_inst
    $cmpne_inst
    $srli_inst
    $srl_inst
    $nextpc_inst
    $callr_inst
    $xor_inst
    $mulxss_inst
    $cmpeq_inst
    $divu_inst
    $div_inst
    $rdctl_inst
    $mul_inst
    $cmpgeu_inst
    $initi_inst
    $trap_inst
    $wrctl_inst
    $cmpltu_inst
    $add_inst
    $break_inst
    $hbreak_inst
    $sync_inst
    $sub_inst
    $srai_inst
    $sra_inst
    $intr_inst
    $crst_inst

    $unimp_trap_ctrl
    $unimp_nop_ctrl
    $illegal_ctrl
    $reserved_ctrl
    $custom_ctrl
    $custom_combo_ctrl
    $custom_multi_ctrl
    $supervisor_only_ctrl
    $ic_index_inv_ctrl
    $invalidate_i_ctrl
    $flush_pipe_ctrl
    $jmp_indirect_non_trap_ctrl
    $jmp_indirect_ctrl
    $jmp_direct_ctrl
    $mul_lsw_ctrl
    $mulx_ctrl
    $mul_ctrl
    $div_unsigned_ctrl
    $div_signed_ctrl
    $div_ctrl
    $implicit_dst_retaddr_ctrl
    $implicit_dst_eretaddr_ctrl
    $intr_ctrl
    $exception_ctrl
    $break_ctrl
    $crst_ctrl
    $wr_ctl_reg_ctrl
    $uncond_cti_non_br_ctrl
    $retaddr_ctrl
    $shift_left_ctrl
    $shift_logical_ctrl
    $rot_left_ctrl
    $shift_rot_left_ctrl
    $shift_right_logical_ctrl
    $shift_right_arith_ctrl
    $shift_right_ctrl
    $rot_right_ctrl
    $shift_rot_right_ctrl
    $shift_rot_ctrl
    $shift_rot_imm_ctrl
    $rot_ctrl
    $logic_reg_ctrl
    $logic_hi_imm16_ctrl
    $logic_lo_imm16_ctrl
    $logic_imm16_ctrl
    $logic_ctrl
    $hi_imm16_ctrl
    $unsigned_lo_imm16_ctrl
    $arith_imm16_ctrl
    $cmp_imm16_ctrl
    $jmpi_ctrl
    $cmp_imm16_with_call_jmpi_rdprs_ctrl
    $cmp_reg_ctrl
    $src_imm5_ctrl
    $cmp_with_lt_ctrl
    $cmp_with_eq_ctrl
    $cmp_with_ge_ctrl
    $cmp_with_ne_ctrl
    $cmp_alu_signed_ctrl
    $cmp_ctrl
    $br_with_lt_ctrl
    $br_with_ge_ctrl
    $br_with_eq_ctrl
    $br_with_ne_ctrl
    $br_alu_signed_ctrl
    $br_cond_ctrl
    $br_uncond_ctrl
    $br_always_pred_taken_ctrl
    $br_ctrl
    $alu_subtract_ctrl
    $alu_signed_comparison_ctrl
    $br_cmp_ctrl
    $br_cmp_eq_ne_ctrl
    $ld8_ctrl
    $ld16_ctrl
    $ld8_ld16_ctrl
    $ld32_ctrl
    $ld_signed_ctrl
    $ld_unsigned_ctrl
    $ld_ctrl
    $dcache_management_nop_ctrl
    $ld_dcache_management_ctrl
    $ld_non_io_ctrl
    $st8_ctrl
    $st16_ctrl
    $st_non32_ctrl
    $st32_ctrl
    $st_ctrl
    $st_non_io_ctrl
    $ld_st_ctrl
    $ld_st_io_ctrl
    $ld_st_non_io_ctrl
    $ld_st_non_io_non_st32_ctrl
    $ld_st_non_st32_ctrl
    $mem_ctrl
    $mem_data_access_ctrl
    $mem8_ctrl
    $mem16_ctrl
    $mem32_ctrl
    $dc_index_nowb_inv_ctrl
    $dc_addr_nowb_inv_ctrl
    $dc_index_wb_inv_ctrl
    $dc_addr_wb_inv_ctrl
    $dc_index_inv_ctrl
    $dc_addr_inv_ctrl
    $dc_wb_inv_ctrl
    $dc_nowb_inv_ctrl
    $dcache_management_ctrl
    $ld_io_ctrl
    $st_io_ctrl
    $st_io_non_st32_ctrl
    $st_non_io_non_st32_ctrl
    $mem_io_ctrl
    $a_not_src_ctrl
    $b_not_src_ctrl
    $b_is_dst_ctrl
    $ignore_dst_ctrl
    $ignore_dst_or_ld_ctrl
    $src2_choose_imm_ctrl
    $wrctl_inst_ctrl
    $rdctl_inst_ctrl
    $rdprs_ctrl
    $mul_src1_signed_ctrl
    $mul_src2_signed_ctrl
    $mul_shift_src1_signed_ctrl
    $mul_shift_src2_signed_ctrl
    $mul_shift_rot_ctrl
    $dont_display_dst_reg_ctrl
    $dont_display_src1_reg_ctrl
    $dont_display_src2_reg_ctrl
    $src1_no_x_ctrl
    $src2_no_x_ctrl
);

use cpu_inst_field;
use cpu_inst_desc;
use cpu_inst_ctrl;
use cpu_inst_gen;
use cpu_control_reg;
use cpu_utils;
use nios2_custom_insts;
use strict;























our @possible_op_insts =

    qw(   call    jmpi    02      ldbu    addi    stb     br      ldb
          cmpgei  09      10      ldhu    andi    sth     bge     ldh
          cmplti  17      18      initda  ori     stw     blt     ldw
          cmpnei  25      26      flushda xori    stc     bne     ldl
          cmpeqi  33      34      ldbuio  muli    stbio   beq     ldbio
          cmpgeui 41      42      ldhuio  andhi   sthio   bgeu    ldhio
          cmpltui 49      custom  initd   orhi    stwio   bltu    ldwio
          rdprs   57      opx     flushd  xorhi   61      62      63
      );


our @possible_opx_insts =

    qw(   00      eret    roli    rol     flushp  ret     nor     mulxuu
          cmpge   bret    10      ror     flushi  jmp     and     15
          cmplt   17      slli    sll     wrprs   21      or      mulxsu
          cmpne   25      srli    srl     nextpc  callr   xor     mulxss
          cmpeq   33      34      35      divu    div     rdctl   mul
          cmpgeu  initi   42      43      44      trap    wrctl   47
          cmpltu  add     50      51      break   hbreak  sync    55
          56      sub     srai    sra     60      intr    crst    63
      );


our $a_inst_field;
our $b_inst_field;
our $c_inst_field;
our $custom_n_inst_field;
our $custom_readra_inst_field;
our $custom_readrb_inst_field;
our $custom_writerc_inst_field;
our $opx_inst_field;
our $op_inst_field;
our $shift_imm5_inst_field;
our $trap_break_imm5_inst_field;
our $imm5_inst_field;
our $imm16_inst_field;
our $imm26_inst_field;
our $memsz_inst_field;
our $control_regnum_inst_field;


our $iw_a_sz;
our $iw_a_lsb;
our $iw_a_msb;
our $iw_b_sz;
our $iw_b_lsb;
our $iw_b_msb;
our $iw_c_sz;
our $iw_c_lsb;
our $iw_c_msb;
our $iw_custom_n_sz;
our $iw_custom_n_lsb;
our $iw_custom_n_msb;
our $iw_custom_readra_sz;
our $iw_custom_readra_lsb;
our $iw_custom_readra_msb;
our $iw_custom_readrb_sz;
our $iw_custom_readrb_lsb;
our $iw_custom_readrb_msb;
our $iw_custom_writerc_sz;
our $iw_custom_writerc_lsb;
our $iw_custom_writerc_msb;
our $iw_opx_sz;
our $iw_opx_lsb;
our $iw_opx_msb;
our $iw_op_sz;
our $iw_op_lsb;
our $iw_op_msb;
our $iw_shift_imm5_sz;
our $iw_shift_imm5_lsb;
our $iw_shift_imm5_msb;
our $iw_trap_break_imm5_sz;
our $iw_trap_break_imm5_lsb;
our $iw_trap_break_imm5_msb;
our $iw_imm5_sz;
our $iw_imm5_lsb;
our $iw_imm5_msb;
our $iw_imm16_sz;
our $iw_imm16_lsb;
our $iw_imm16_msb;
our $iw_imm26_sz;
our $iw_imm26_lsb;
our $iw_imm26_msb;
our $iw_memsz_sz;
our $iw_memsz_lsb;
our $iw_memsz_msb;
our $iw_control_regnum_sz;
our $iw_control_regnum_lsb;
our $iw_control_regnum_msb;


our $iw_memsz_byte;
our $iw_memsz_hword;
our $iw_memsz_word_msb;
our $logic_op_sz;
our $logic_op_lsb;
our $logic_op_msb;
our $logic_op_nor;
our $logic_op_and;
our $logic_op_or ;
our $logic_op_xor;
our $compare_op_sz;
our $compare_op_lsb;
our $compare_op_msb;
our $compare_op_eq;
our $compare_op_ge;
our $compare_op_lt;
our $compare_op_ne;
our $jmp_callr_vs_ret_opx_bit;
our $jmp_callr_vs_ret_is_ret;
our $empty_intr_iw;
our $empty_hbreak_iw;
our $empty_crst_iw;
our $empty_nop_iw;
our $empty_ret_iw;



our $call_inst;
our $jmpi_inst;
our $ldbu_inst;
our $addi_inst;
our $stb_inst;
our $br_inst;
our $ldb_inst;
our $cmpgei_inst;
our $ldhu_inst;
our $andi_inst;
our $sth_inst;
our $bge_inst;
our $ldh_inst;
our $cmplti_inst;
our $initda_inst;
our $ori_inst;
our $stw_inst;
our $blt_inst;
our $ldw_inst;
our $cmpnei_inst;
our $flushda_inst;
our $xori_inst;
our $stc_inst;
our $bne_inst;
our $ldl_inst;
our $cmpeqi_inst;
our $ldbuio_inst;
our $muli_inst;
our $stbio_inst;
our $beq_inst;
our $ldbio_inst;
our $cmpgeui_inst;
our $ldhuio_inst;
our $andhi_inst;
our $sthio_inst;
our $bgeu_inst;
our $ldhio_inst;
our $cmpltui_inst;
our $initd_inst;
our $orhi_inst;
our $stwio_inst;
our $bltu_inst;
our $ldwio_inst;
our $rdprs_inst;
our $flushd_inst;
our $xorhi_inst;



our $eret_inst;
our $roli_inst;
our $rol_inst;
our $flushp_inst;
our $ret_inst;
our $nor_inst;
our $mulxuu_inst;
our $cmpge_inst;
our $bret_inst;
our $ror_inst;
our $flushi_inst;
our $jmp_inst;
our $and_inst;
our $cmplt_inst;
our $slli_inst;
our $sll_inst;
our $wrprs_inst;
our $or_inst;
our $mulxsu_inst;
our $cmpne_inst;
our $srli_inst;
our $srl_inst;
our $nextpc_inst;
our $callr_inst;
our $xor_inst;
our $mulxss_inst;
our $cmpeq_inst;
our $divu_inst;
our $div_inst;
our $rdctl_inst;
our $mul_inst;
our $cmpgeu_inst;
our $initi_inst;
our $trap_inst;
our $wrctl_inst;
our $cmpltu_inst;
our $add_inst;
our $break_inst;
our $hbreak_inst;
our $sync_inst;
our $sub_inst;
our $srai_inst;
our $sra_inst;
our $intr_inst;
our $crst_inst;



our $unimp_trap_ctrl;
our $unimp_nop_ctrl;
our $illegal_ctrl;
our $reserved_ctrl;
our $custom_ctrl;
our $custom_combo_ctrl;
our $custom_multi_ctrl;
our $supervisor_only_ctrl;
our $ic_index_inv_ctrl;
our $invalidate_i_ctrl;
our $flush_pipe_ctrl;
our $jmp_indirect_non_trap_ctrl;
our $jmp_indirect_ctrl;
our $jmp_direct_ctrl;
our $mul_lsw_ctrl;
our $mulx_ctrl;
our $mul_ctrl;
our $div_unsigned_ctrl;
our $div_signed_ctrl;
our $div_ctrl;
our $implicit_dst_retaddr_ctrl;
our $implicit_dst_eretaddr_ctrl;
our $intr_ctrl;
our $exception_ctrl;
our $break_ctrl;
our $crst_ctrl;
our $wr_ctl_reg_ctrl;
our $uncond_cti_non_br_ctrl;
our $retaddr_ctrl;
our $shift_left_ctrl;
our $shift_logical_ctrl;
our $rot_left_ctrl;
our $shift_rot_left_ctrl;
our $shift_right_logical_ctrl;
our $shift_right_arith_ctrl;
our $shift_right_ctrl;
our $rot_right_ctrl;
our $shift_rot_right_ctrl;
our $shift_rot_ctrl;
our $shift_rot_imm_ctrl;
our $rot_ctrl;
our $logic_reg_ctrl;
our $logic_hi_imm16_ctrl;
our $logic_lo_imm16_ctrl;
our $logic_imm16_ctrl;
our $logic_ctrl;
our $hi_imm16_ctrl;
our $unsigned_lo_imm16_ctrl;
our $arith_imm16_ctrl;
our $cmp_imm16_ctrl;
our $jmpi_ctrl;
our $cmp_imm16_with_call_jmpi_rdprs_ctrl;
our $cmp_reg_ctrl;
our $src_imm5_ctrl;
our $cmp_with_lt_ctrl;
our $cmp_with_eq_ctrl;
our $cmp_with_ge_ctrl;
our $cmp_with_ne_ctrl;
our $cmp_alu_signed_ctrl;
our $cmp_ctrl;
our $br_with_lt_ctrl;
our $br_with_ge_ctrl;
our $br_with_eq_ctrl;
our $br_with_ne_ctrl;
our $br_alu_signed_ctrl;
our $br_cond_ctrl;
our $br_uncond_ctrl;
our $br_always_pred_taken_ctrl;
our $br_ctrl;
our $alu_subtract_ctrl;
our $alu_signed_comparison_ctrl;
our $br_cmp_ctrl;
our $br_cmp_eq_ne_ctrl;
our $ld8_ctrl;
our $ld16_ctrl;
our $ld8_ld16_ctrl;
our $ld32_ctrl;
our $ld_signed_ctrl;
our $ld_unsigned_ctrl;
our $ld_ctrl;
our $dcache_management_nop_ctrl;
our $ld_dcache_management_ctrl;
our $ld_non_io_ctrl;
our $st8_ctrl;
our $st16_ctrl;
our $st_non32_ctrl;
our $st32_ctrl;
our $st_ctrl;
our $st_non_io_ctrl;
our $ld_st_ctrl;
our $ld_st_io_ctrl;
our $ld_st_non_io_ctrl;
our $ld_st_non_io_non_st32_ctrl;
our $ld_st_non_st32_ctrl;
our $mem_ctrl;
our $mem_data_access_ctrl;
our $mem8_ctrl;
our $mem16_ctrl;
our $mem32_ctrl;
our $dc_index_nowb_inv_ctrl;
our $dc_addr_nowb_inv_ctrl;
our $dc_index_wb_inv_ctrl;
our $dc_addr_wb_inv_ctrl;
our $dc_index_inv_ctrl;
our $dc_addr_inv_ctrl;
our $dc_wb_inv_ctrl;
our $dc_nowb_inv_ctrl;
our $dcache_management_ctrl;
our $ld_io_ctrl;
our $st_io_ctrl;
our $st_io_non_st32_ctrl;
our $st_non_io_non_st32_ctrl;
our $mem_io_ctrl;
our $a_not_src_ctrl;
our $b_not_src_ctrl;
our $b_is_dst_ctrl;
our $ignore_dst_ctrl;
our $ignore_dst_or_ld_ctrl;
our $src2_choose_imm_ctrl;
our $wrctl_inst_ctrl;
our $rdctl_inst_ctrl;
our $rdprs_ctrl;
our $mul_src1_signed_ctrl;
our $mul_src2_signed_ctrl;
our $mul_shift_src1_signed_ctrl;
our $mul_shift_src2_signed_ctrl;
our $mul_shift_rot_ctrl;
our $dont_display_dst_reg_ctrl;
our $dont_display_src1_reg_ctrl;
our $dont_display_src2_reg_ctrl;
our $src1_no_x_ctrl;
our $src2_no_x_ctrl;


our $OP_INST_TYPE = 0;
our $OPX_INST_TYPE = 1;
our $CUSTOM_INST_TYPE = 2;







sub
create_inst_args_from_infos
{
    my $nios2_isa_info = shift;
    my $misc_info = shift;
    my $custom_inst_info = shift;
    my $control_reg_info = shift;
    my $multiply_info = shift;
    my $divide_info = shift;
    my $exception_info = shift;
    my $elaborated_advanced_exc_info = shift;
    my $icache_info = shift;
    my $dcache_info = shift;
    my $elaborated_dcache_info = shift;
    my $elaborated_debug_info = shift;


    my $cpu_reset = manditory_bool($misc_info, "cpu_reset");
    my $shadow_present = (manditory_int($misc_info, "num_shadow_reg_sets") > 0);
    my $hardware_divide_present = 
      manditory_bool($divide_info, "hardware_divide_present");
    my $hardware_multiply_present = 
      manditory_bool($multiply_info, "hardware_multiply_present");
    my $hardware_multiply_omits_msw =
      $hardware_multiply_present && 
      manditory_bool($multiply_info, "hardware_multiply_omits_msw");
    my $reserved_instructions_trap =
      manditory_bool($exception_info, "reserved_instructions_trap");
    my $advanced_exc = 
      manditory_bool($elaborated_advanced_exc_info, "advanced_exc");
    my $cache_has_icache = manditory_bool($icache_info, "cache_has_icache");
    my $cache_has_dcache = manditory_bool($dcache_info, "cache_has_dcache");;
    my $dcache_supports_initda = 
      $cache_has_dcache && 
      manditory_bool($elaborated_dcache_info, "dcache_supports_initda");
    my $hbreak_present = 
      manditory_bool($elaborated_debug_info, "hbreak_present");

    my $inst_args = {
        isa_constants => manditory_hash($nios2_isa_info, "isa_constants"),
        cpu_reset => $cpu_reset,
        shadow_present => $shadow_present,
        custom_instructions => $custom_inst_info->{custom_instructions},
        control_reg_num_decode_sz => 
          get_control_reg_num_decode_sz($control_reg_info->{control_regs}),
        hardware_divide_present => $hardware_divide_present,
        hardware_multiply_present => $hardware_multiply_present,
        hardware_multiply_omits_msw => $hardware_multiply_omits_msw,
        reserved_instructions_trap => $reserved_instructions_trap,
        advanced_exc => $advanced_exc,
        cache_has_icache => $cache_has_icache,
        cache_has_dcache => $cache_has_dcache,
        dcache_supports_initda => $dcache_supports_initda,
        hbreak_present => $hbreak_present,
    };

    return $inst_args;
}




sub
create_inst_args_from_test_args
{
    my $nios2_isa_info = shift;
    my $custom_instructions = shift;
    my $test_args = shift;  # Hash to args required to setup for tests

    my $inst_args = {
        isa_constants               => 
          manditory_hash($nios2_isa_info, "isa_constants"),
        cpu_reset                   => manditory_bool($test_args, "cpu_reset"),
        shadow_present              => 
          manditory_bool($test_args, "shadow_present"),
        custom_instructions         => $custom_instructions,
        control_reg_num_decode_sz   => 5,
        hardware_divide_present     => 
          manditory_bool($test_args, "hardware_divide_present"),
        hardware_multiply_present   =>
          manditory_bool($test_args, "hardware_multiply_present"),
        hardware_multiply_omits_msw =>
          manditory_bool($test_args, "hardware_multiply_omits_msw"),
        reserved_instructions_trap  => 
          manditory_bool($test_args, "reserved_instructions_trap"),
        advanced_exc                =>
          manditory_bool($test_args, "advanced_exc"),
        cache_has_icache            =>
          manditory_bool($test_args, "cache_has_icache"),
        cache_has_dcache            =>
          manditory_bool($test_args, "cache_has_dcache"),
        dcache_supports_initda      =>
          manditory_bool($test_args, "dcache_supports_initda"),
        hbreak_present => manditory_bool($test_args, "hbreak_present"),
    };

    return $inst_args;
}



sub
get_default_test_args_configuration
{
    return {
      configuration_name          => "default",
      cpu_reset                   => 0,
      shadow_present              => 1,
      hardware_divide_present     => 1,
      hardware_multiply_present   => 1,
      hardware_multiply_omits_msw => 0,
      reserved_instructions_trap  => 0,
      advanced_exc                => 0,
      cache_has_icache            => 1,
      cache_has_dcache            => 1,
      dcache_supports_initda      => 1,
      hbreak_present              => 0,
    };
}


sub
get_test_args_configurations
{
    return [
      {
        configuration_name          => "no_mul",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 0,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "no_mulx",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 1,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "no_div",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 0,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "advanced_exc",
        cpu_reset                   => 1,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 1,
        advanced_exc                => 1,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 1,
      },
      {
        configuration_name          => "not_advanced_exc",
        cpu_reset                   => 1,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 1,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 1,
      },
      {
        configuration_name          => "no_icache",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 0,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "no_dcache",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 0,
        dcache_supports_initda      => 0,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "no_initda",
        cpu_reset                   => 0,
        shadow_present              => 0,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 0,
        hbreak_present              => 0,
      },
      {
        configuration_name          => "shadow",
        cpu_reset                   => 0,
        shadow_present              => 1,
        hardware_divide_present     => 1,
        hardware_multiply_present   => 1,
        hardware_multiply_omits_msw => 0,
        reserved_instructions_trap  => 0,
        advanced_exc                => 0,
        cache_has_icache            => 1,
        cache_has_dcache            => 1,
        dcache_supports_initda      => 1,
        hbreak_present              => 0,
      },
    ];
}




sub
create_inst_args_gen_isa_configuration
{
    my $nios2_isa_info = shift;

    return create_inst_args_from_test_args($nios2_isa_info, {},
      get_default_test_args_configuration());
}




sub
validate_and_elaborate
{
    my $inst_args = shift; # Hash reference containing all args

    my $isa_constants = manditory_hash($inst_args, "isa_constants");
    my $custom_instructions = 
      manditory_hash($inst_args, "custom_instructions");
    my $control_reg_num_decode_sz = 
      manditory_int($inst_args, "control_reg_num_decode_sz");

    my $default_inst_ctrl_allowed_modes = 
      get_default_inst_ctrl_allowed_modes($inst_args);
    my $exception_inst_ctrl_allowed_modes = 
      get_exception_inst_ctrl_allowed_modes($inst_args);
    my $inst_fields = add_inst_fields($control_reg_num_decode_sz);
    my $constants = add_inst_constants($inst_fields, $isa_constants);
    my $op_inst_descs = add_op_inst_descs($inst_args);
    my $reserved_op_inst_descs = add_reserved_op_inst_descs($op_inst_descs);
    my $opx_inst_descs = add_opx_inst_descs($inst_args);
    my $reserved_opx_inst_descs = add_reserved_opx_inst_descs($opx_inst_descs);
    my $custom_inst_descs = add_custom_inst_descs($custom_instructions);


    my $inst_descs = [
      @$op_inst_descs, 
      @$reserved_op_inst_descs, 
      @$opx_inst_descs, 
      @$reserved_opx_inst_descs, 
      @$custom_inst_descs
    ];


    my $inst_ctrls = add_inst_ctrls($inst_args, $inst_descs);

    my $inst_info = {
      default_inst_ctrl_allowed_modes => $default_inst_ctrl_allowed_modes,
      exception_inst_ctrl_allowed_modes => $exception_inst_ctrl_allowed_modes,
      inst_constants        => $constants,
      inst_field_info       => {
        inst_fields => $inst_fields,
        extra_gen_func => \&gen_extra_inst_field_signals,
        extra_gen_func_arg => undef,        # not used
      },
      inst_desc_info        => {
        inst_descs  => $inst_descs,
        extra_gen_func => \&gen_extra_inst_desc_signals,
        extra_gen_func_arg => undef,        # not used
      },
      inst_ctrls            => $inst_ctrls,
    };



    foreach my $var (keys(%$constants)) {
        eval_cmd('$' . $var . ' = "' . $constants->{$var} . '"');
    }


    foreach my $inst_field (@$inst_fields) {





        foreach my $cmd (@{get_inst_field_into_scalars($inst_field)}) {
            eval_cmd($cmd);
        }
    }

    return $inst_info;
}

sub
convert_to_c
{
    my $inst_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    convert_opcode_tables_to_c($c_lines, $h_lines) || return undef;
    convert_constants_to_c($inst_info->{inst_constants}, $c_lines, $h_lines) ||
      return undef;
    convert_inst_fields_to_c($inst_info->{inst_field_info}{inst_fields},
      $c_lines, $h_lines) || return undef;
    convert_inst_ctrls_to_c($inst_info->{inst_ctrls},
      $inst_info->{inst_desc_info}{inst_descs}, $c_lines, $h_lines) ||
        return undef;
    create_c_inst_info_shared($h_lines) || return undef;
    create_c_inst_info($c_lines, $h_lines, 0) || return undef;
    create_c_inst_info($c_lines, $h_lines, 1) || return undef;

    return 1;   # Some defined value
}




sub
additional_inst_ctrl
{
    my $Opt = shift;
    my $props = shift;

    my $inst_ctrls = manditory_array($Opt, "inst_ctrls");

    return nios2_insts::add_inst_ctrl($inst_ctrls, $props);
}







sub
get_default_inst_ctrl_allowed_modes
{
    my $inst_args = shift;

    my $reserved_instructions_trap =
      manditory_bool($inst_args, "reserved_instructions_trap"),
    my $advanced_exc = manditory_bool($inst_args, "advanced_exc");



















    my $allow_reserved_instructions = 
      (!$reserved_instructions_trap || $advanced_exc);

    my $default_allowed_modes = [$INST_DESC_NORMAL_MODE];
    if ($allow_reserved_instructions) {
        push(@$default_allowed_modes, $INST_DESC_RESERVED_MODE);
    }

    return $default_allowed_modes;
}



sub
get_exception_inst_ctrl_allowed_modes
{
    my $inst_args = shift;

    return 
      [$INST_DESC_NORMAL_MODE, 
       $INST_DESC_RESERVED_MODE, 
       $INST_DESC_UNIMP_TRAP_MODE];
}


sub
add_inst_constants
{
    my $inst_fields = shift;
    my $isa_constants = shift;

    my %constants;


    $constants{iw_memsz_byte} = "2'b00";
    $constants{iw_memsz_hword} = "2'b01";
    $constants{iw_memsz_word_msb} = "1'b1";  # top bit is enough for word


    $constants{logic_op_sz} = 2;
    $constants{logic_op_lsb} = 3;
    $constants{logic_op_msb} = 
      $constants{logic_op_lsb} + $constants{logic_op_sz} - 1;
    $constants{logic_op_nor} = "2'b00";
    $constants{logic_op_and} = "2'b01";
    $constants{logic_op_or}  = "2'b10";
    $constants{logic_op_xor} = "2'b11";
    

    $constants{compare_op_sz} = 2;
    $constants{compare_op_lsb} = 3;
    $constants{compare_op_msb} = 
      $constants{compare_op_lsb} + $constants{compare_op_sz} - 1;
    $constants{compare_op_eq} = "2'b00";
    $constants{compare_op_ge} = "2'b01";
    $constants{compare_op_lt} = "2'b10";
    $constants{compare_op_ne} = "2'b11";


    $constants{jmp_callr_vs_ret_opx_bit} = 3;
    $constants{jmp_callr_vs_ret_is_ret} = "0";


    my $retaddr_regnum_int = 
      manditory_int($isa_constants, "retaddr_regnum_int");
    my $eretaddr_regnum_int = 
      manditory_int($isa_constants, "eretaddr_regnum_int");
    my $bretaddr_regnum_int = 
      manditory_int($isa_constants, "bretaddr_regnum_int");

    $constants{empty_intr_iw} = encode_opx_inst(
      $inst_fields, get_opx_inst_code("intr"), 0, 0, $eretaddr_regnum_int);
    $constants{empty_hbreak_iw} = encode_opx_inst(
      $inst_fields, get_opx_inst_code("hbreak"), 0, 0, $bretaddr_regnum_int);
    $constants{empty_crst_iw} = encode_opx_inst(
      $inst_fields, get_opx_inst_code("crst"), 0, 0, 0);
    $constants{empty_nop_iw} = encode_opx_inst(
      $inst_fields, get_opx_inst_code("add"), 0, 0, 0);
    $constants{empty_ret_iw} = encode_opx_inst(
      $inst_fields, get_opx_inst_code("ret"), $retaddr_regnum_int, 0, 0);

    return \%constants;
}

















sub
add_inst_fields
{
    my $control_reg_num_decode_sz = shift;

    my $inst_fields = [];

    $a_inst_field = add_inst_field($inst_fields, {
      name => "a", 
      lsb  => 27,
      sz   => 5,
    });

    $b_inst_field = add_inst_field($inst_fields, {
      name => "b", 
      lsb  => 22,
      sz   => 5,
    });
    
    $c_inst_field = add_inst_field($inst_fields, {
      name => "c", 
      lsb  => 17,
      sz   => 5,
    });
    
    $custom_n_inst_field = add_inst_field($inst_fields, {
      name => "custom_n", 
      lsb  => 6,
      sz   => 8,
    });
    
    $custom_readra_inst_field = add_inst_field($inst_fields, {
      name => "custom_readra", 
      lsb  => 16,
      sz   => 1,
    });

    $custom_readrb_inst_field = add_inst_field($inst_fields, {
      name => "custom_readrb", 
      lsb  => 15,
      sz   => 1,
    });

    $custom_writerc_inst_field = add_inst_field($inst_fields, {
      name => "custom_writerc", 
      lsb  => 14,
      sz   => 1,
    });
    
    $opx_inst_field = add_inst_field($inst_fields, {
      name => "opx", 
      lsb  => 11,
      sz   => 6,
    });
    
    $op_inst_field = add_inst_field($inst_fields, {
      name => "op", 
      lsb  => 0,
      sz   => 6,
    });
    
    $shift_imm5_inst_field = add_inst_field($inst_fields, {
      name => "shift_imm5", 
      lsb  => 6,
      sz   => 5,
    });
    
    $trap_break_imm5_inst_field = add_inst_field($inst_fields, {
      name => "trap_break_imm5", 
      lsb  => 6,
      sz   => 5,
    });
    
    $imm5_inst_field = add_inst_field($inst_fields, {
      name => "imm5", 
      lsb  => 6,
      sz   => 5,
    });
    
    $imm16_inst_field = add_inst_field($inst_fields, {
      name => "imm16", 
      lsb  => 6,
      sz   => 16,
    });
    
    $imm26_inst_field = add_inst_field($inst_fields, {
      name => "imm26", 
      lsb  => 6,
      sz   => 26,
    });
    
    $memsz_inst_field = add_inst_field($inst_fields, {
      name => "memsz", 
      lsb  => 3,
      sz   => 2,
    });

    $control_regnum_inst_field = add_inst_field($inst_fields, {
      name => "control_regnum", 
      lsb  => 6,
      sz   => $control_reg_num_decode_sz,
    });

    return $inst_fields;
}



sub
add_inst_field
{
    my $inst_fields = shift;
    my $props = shift;

    my $field_name = $props->{name};

    if (defined(get_inst_field_by_name_or_undef($inst_fields, $field_name))) {
        return 
          &$error("Instruction field name '$field_name' already exists");
    }

    my $inst_field = create_inst_field($props);


    push(@$inst_fields, $inst_field);

    return $inst_field;
}


sub
gen_extra_inst_field_signals
{
    my $gen_info = shift;
    my $extra_gen_func_arg = shift;     # not used
    my $stage = shift;

    my $assignment_func = manditory_code($gen_info, "assignment_func");

    &$assignment_func({
      lhs => "${stage}_mem8",
      rhs => "${stage}_iw_memsz == $iw_memsz_byte",
      sz => 1,
      never_export => 1,
    });

    &$assignment_func({
      lhs => "${stage}_mem16",
      rhs => "${stage}_iw_memsz == $iw_memsz_hword",
      sz => 1,
      never_export => 1,
    });

    &$assignment_func({
      lhs => "${stage}_mem32",
      rhs => "${stage}_iw_memsz[1] == $iw_memsz_word_msb",
      sz => 1,
      never_export => 1,
    });
}



sub
add_op_inst_descs
{
    my $inst_args = shift;

    my $hardware_multiply_present = 
      manditory_bool($inst_args, "hardware_multiply_present");
    my $cache_has_dcache = manditory_bool($inst_args, "cache_has_dcache");
    my $dcache_supports_initda = 
      manditory_bool($inst_args, "dcache_supports_initda");
    my $shadow_present = manditory_bool($inst_args, "shadow_present");

    my $mul_lsw_mode = 
      $hardware_multiply_present ? $INST_DESC_NORMAL_MODE :
                                   $INST_DESC_UNIMP_TRAP_MODE;



    my $dcache_management_mode =
      $cache_has_dcache ? $INST_DESC_NORMAL_MODE :
                          $INST_DESC_UNIMP_NOP_MODE;








    my $initda_mode =
      $cache_has_dcache ? 
                ($dcache_supports_initda ? $INST_DESC_NORMAL_MODE : 
                                           $INST_DESC_UNIMP_TRAP_MODE) :
                $INST_DESC_UNIMP_NOP_MODE;
 

    my $rdprs_mode =
      $shadow_present ? $INST_DESC_NORMAL_MODE :
                        $INST_DESC_RESERVED_MODE;

    my $inst_descs = [];


    $call_inst = add_op_inst_desc($inst_descs, "call");
    $jmpi_inst = add_op_inst_desc($inst_descs, "jmpi");
    $ldbu_inst = add_op_inst_desc($inst_descs, "ldbu");
    $addi_inst = add_op_inst_desc($inst_descs, "addi");
    $stb_inst = add_op_inst_desc($inst_descs, "stb");
    $br_inst = add_op_inst_desc($inst_descs, "br");
    $ldb_inst = add_op_inst_desc($inst_descs, "ldb");
    $cmpgei_inst = add_op_inst_desc($inst_descs, "cmpgei");
    $ldhu_inst = add_op_inst_desc($inst_descs, "ldhu");
    $andi_inst = add_op_inst_desc($inst_descs, "andi");
    $sth_inst = add_op_inst_desc($inst_descs, "sth");
    $bge_inst = add_op_inst_desc($inst_descs, "bge");
    $ldh_inst = add_op_inst_desc($inst_descs, "ldh");
    $cmplti_inst = add_op_inst_desc($inst_descs, "cmplti");
    $initda_inst = add_op_inst_desc($inst_descs, "initda", $initda_mode);
    $ori_inst = add_op_inst_desc($inst_descs, "ori");
    $stw_inst = add_op_inst_desc($inst_descs, "stw");
    $blt_inst = add_op_inst_desc($inst_descs, "blt");
    $ldw_inst = add_op_inst_desc($inst_descs, "ldw");
    $cmpnei_inst = add_op_inst_desc($inst_descs, "cmpnei");
    $flushda_inst = add_op_inst_desc($inst_descs, "flushda",
      $dcache_management_mode);
    $xori_inst = add_op_inst_desc($inst_descs, "xori");
    $stc_inst = add_op_inst_desc($inst_descs, "stc", $INST_DESC_RESERVED_MODE);
    $bne_inst = add_op_inst_desc($inst_descs, "bne");
    $ldl_inst = add_op_inst_desc($inst_descs, "ldl", $INST_DESC_RESERVED_MODE);
    $cmpeqi_inst = add_op_inst_desc($inst_descs, "cmpeqi");
    $ldbuio_inst = add_op_inst_desc($inst_descs, "ldbuio");
    $muli_inst = add_op_inst_desc($inst_descs, "muli", $mul_lsw_mode);
    $stbio_inst = add_op_inst_desc($inst_descs, "stbio");
    $beq_inst = add_op_inst_desc($inst_descs, "beq");
    $ldbio_inst = add_op_inst_desc($inst_descs, "ldbio");
    $cmpgeui_inst = add_op_inst_desc($inst_descs, "cmpgeui");
    $ldhuio_inst = add_op_inst_desc($inst_descs, "ldhuio");
    $andhi_inst = add_op_inst_desc($inst_descs, "andhi");
    $sthio_inst = add_op_inst_desc($inst_descs, "sthio");
    $bgeu_inst = add_op_inst_desc($inst_descs, "bgeu");
    $ldhio_inst = add_op_inst_desc($inst_descs, "ldhio");
    $cmpltui_inst = add_op_inst_desc($inst_descs, "cmpltui");
    $initd_inst = add_op_inst_desc($inst_descs, "initd", 
      $dcache_management_mode);
    $orhi_inst = add_op_inst_desc($inst_descs, "orhi");
    $stwio_inst = add_op_inst_desc($inst_descs, "stwio");
    $bltu_inst = add_op_inst_desc($inst_descs, "bltu");
    $ldwio_inst = add_op_inst_desc($inst_descs, "ldwio");
    $rdprs_inst = add_op_inst_desc($inst_descs, "rdprs", $rdprs_mode);
    $flushd_inst = add_op_inst_desc($inst_descs, "flushd",
      $dcache_management_mode);
    $xorhi_inst = add_op_inst_desc($inst_descs, "xorhi");

    return $inst_descs;
}





sub
add_reserved_op_inst_descs
{
    my $op_inst_descs = shift;

    my $reserved_inst_descs = [];

    my $op_opx_code = get_op_inst_code("opx");
    if (!defined($op_opx_code)) {
        &$error("Can't find OP code for OPX instructions.");
    }

    my $op_custom_code = get_op_inst_code("custom");
    if (!defined($op_custom_code)) {
        &$error("Can't find OP code for custom instructions.");
    }


    for (my $code = 0; $code < scalar(@possible_op_insts); $code++) {

        if (($code == $op_opx_code) || ($code == $op_custom_code)) {
            next;
        }


        my $found = 0;
        foreach my $op_inst_desc (@$op_inst_descs) {
            if ($code == get_inst_desc_code($op_inst_desc)) {
                $found = 1;
            }
        }


        if ($found) {
            next;
        }

        my $props = {};
        $props->{name} = sprintf("rsv%02d", $code);
        $props->{code} = $code;
        $props->{mode} = $INST_DESC_RESERVED_MODE;
        $props->{v_decode_func} = \&v_decode_op_inst;
        $props->{c_decode_func} = \&c_decode_op_inst;
        $props->{decode_arg} = undef;   # Not used
        $props->{inst_type} = $OP_INST_TYPE;
    
        add_inst_desc($reserved_inst_descs, $props);
    }

    return $reserved_inst_descs;
}



sub
add_op_inst_desc
{
    my $inst_descs = shift;
    my $inst_name = shift;
    my $inst_mode = shift;      # Optional


    my $code = get_op_inst_code($inst_name);

    if (!defined($code)) {
      return &$error("Can't determine code for for OP instruction" .
        "'$inst_name'");
    }

    my $props = {};

    $props->{name} = $inst_name;
    $props->{code} = $code;
    $props->{mode} = $inst_mode;
    $props->{v_decode_func} = \&v_decode_op_inst;
    $props->{c_decode_func} = \&c_decode_op_inst;
    $props->{decode_arg} = undef;   # Not used
    $props->{inst_type} = $OP_INST_TYPE;

    return add_inst_desc($inst_descs, $props);
}






sub
v_decode_op_inst
{
    my $decode_arg = shift; # Not used
    my $inst_desc = shift;
    my $stage = shift;

    my $code = get_inst_desc_code($inst_desc);

    return "(${stage}_iw_op == $code)";
}







sub
c_decode_op_inst
{
    my $decode_arg = shift; # Not used
    my $inst_desc = shift;

    my $name_uc = uc(get_inst_desc_name($inst_desc));

    return "(GET_IW_OP((Iw)) == OP_${name_uc})";
}



sub
add_opx_inst_descs
{
    my $inst_args = shift;

    my $hardware_multiply_present = 
      manditory_bool($inst_args, "hardware_multiply_present");
    my $hardware_multiply_omits_msw =
      manditory_bool($inst_args, "hardware_multiply_omits_msw");
    my $hardware_divide_present = 
      manditory_bool($inst_args, "hardware_divide_present");
    my $advanced_exc = manditory_bool($inst_args, "advanced_exc");
    my $hbreak_present = manditory_bool($inst_args, "hbreak_present");
    my $cpu_reset = manditory_bool($inst_args, "cpu_reset");
    my $cache_has_icache = manditory_bool($inst_args, "cache_has_icache");
    my $shadow_present = manditory_bool($inst_args, "shadow_present");

    my $mul_lsw_mode = 
      $hardware_multiply_present ? $INST_DESC_NORMAL_MODE :
                                   $INST_DESC_UNIMP_TRAP_MODE;
    my $mul_msw_mode = 
      ($hardware_multiply_present && !$hardware_multiply_omits_msw) ? 
                                   $INST_DESC_NORMAL_MODE :
                                   $INST_DESC_UNIMP_TRAP_MODE;
    my $div_mode = 
      $hardware_divide_present ? $INST_DESC_NORMAL_MODE :
                                 $INST_DESC_UNIMP_TRAP_MODE;



    my $intr_mode =
      (!$advanced_exc) ? $INST_DESC_NORMAL_MODE :
                         $INST_DESC_RESERVED_MODE;



    my $hbreak_mode =
      ($hbreak_present && !$advanced_exc) ? $INST_DESC_NORMAL_MODE :
                                            $INST_DESC_RESERVED_MODE;



    my $crst_mode =
      ($cpu_reset && !$advanced_exc) ? $INST_DESC_NORMAL_MODE :
                                       $INST_DESC_RESERVED_MODE;



    my $icache_management_mode =
      $cache_has_icache ? $INST_DESC_NORMAL_MODE :
                          $INST_DESC_UNIMP_NOP_MODE;


    my $wrprs_mode =
      $shadow_present ? $INST_DESC_NORMAL_MODE :
                        $INST_DESC_RESERVED_MODE;

    my $inst_descs = [];


    $eret_inst = add_opx_inst_desc($inst_descs, "eret");
    $roli_inst = add_opx_inst_desc($inst_descs, "roli");
    $rol_inst = add_opx_inst_desc($inst_descs, "rol");
    $flushp_inst = add_opx_inst_desc($inst_descs, "flushp");
    $ret_inst = add_opx_inst_desc($inst_descs, "ret");
    $nor_inst = add_opx_inst_desc($inst_descs, "nor");
    $mulxuu_inst = add_opx_inst_desc($inst_descs, "mulxuu", $mul_msw_mode);
    $cmpge_inst = add_opx_inst_desc($inst_descs, "cmpge");
    $bret_inst = add_opx_inst_desc($inst_descs, "bret");
    $ror_inst = add_opx_inst_desc($inst_descs, "ror");
    $flushi_inst = add_opx_inst_desc($inst_descs, "flushi",
      $icache_management_mode);
    $jmp_inst = add_opx_inst_desc($inst_descs, "jmp");
    $and_inst = add_opx_inst_desc($inst_descs, "and");
    $cmplt_inst = add_opx_inst_desc($inst_descs, "cmplt");
    $slli_inst = add_opx_inst_desc($inst_descs, "slli");
    $sll_inst = add_opx_inst_desc($inst_descs, "sll");
    $wrprs_inst = add_opx_inst_desc($inst_descs, "wrprs", $wrprs_mode);
    $or_inst = add_opx_inst_desc($inst_descs, "or");
    $mulxsu_inst = add_opx_inst_desc($inst_descs, "mulxsu", $mul_msw_mode);
    $cmpne_inst = add_opx_inst_desc($inst_descs, "cmpne");
    $srli_inst = add_opx_inst_desc($inst_descs, "srli");
    $srl_inst = add_opx_inst_desc($inst_descs, "srl");
    $nextpc_inst = add_opx_inst_desc($inst_descs, "nextpc");
    $callr_inst = add_opx_inst_desc($inst_descs, "callr");
    $xor_inst = add_opx_inst_desc($inst_descs, "xor");
    $mulxss_inst = add_opx_inst_desc($inst_descs, "mulxss", $mul_msw_mode);
    $cmpeq_inst = add_opx_inst_desc($inst_descs, "cmpeq");
    $divu_inst = add_opx_inst_desc($inst_descs, "divu", $div_mode);
    $div_inst = add_opx_inst_desc($inst_descs, "div", $div_mode);
    $rdctl_inst = add_opx_inst_desc($inst_descs, "rdctl");
    $mul_inst = add_opx_inst_desc($inst_descs, "mul", $mul_lsw_mode);
    $cmpgeu_inst = add_opx_inst_desc($inst_descs, "cmpgeu");
    $initi_inst = add_opx_inst_desc($inst_descs, "initi",
      $icache_management_mode);
    $trap_inst = add_opx_inst_desc($inst_descs, "trap");
    $wrctl_inst = add_opx_inst_desc($inst_descs, "wrctl");
    $cmpltu_inst = add_opx_inst_desc($inst_descs, "cmpltu");
    $add_inst = add_opx_inst_desc($inst_descs, "add");
    $break_inst = add_opx_inst_desc($inst_descs, "break");
    $hbreak_inst = add_opx_inst_desc($inst_descs, "hbreak", $hbreak_mode);
    $sync_inst = add_opx_inst_desc($inst_descs, "sync");
    $sub_inst = add_opx_inst_desc($inst_descs, "sub");
    $srai_inst = add_opx_inst_desc($inst_descs, "srai");
    $sra_inst = add_opx_inst_desc($inst_descs, "sra");
    $intr_inst = add_opx_inst_desc($inst_descs, "intr", $intr_mode);
    $crst_inst = add_opx_inst_desc($inst_descs, "crst", $crst_mode);

    return $inst_descs;
}





sub
add_reserved_opx_inst_descs
{
    my $opx_inst_descs = shift;

    my $reserved_inst_descs = [];


    for (my $code = 0; $code < scalar(@possible_opx_insts); $code++) {

        my $found = 0;
        foreach my $opx_inst_desc (@$opx_inst_descs) {
            if ($code == get_inst_desc_code($opx_inst_desc)) {
                $found = 1;
            }
        }


        if ($found) {
            next;
        }

        my $props = {};
        $props->{name} = sprintf("rsvx%02d", $code);
        $props->{code} = $code;
        $props->{mode} = $INST_DESC_RESERVED_MODE;
        $props->{v_decode_func} = \&v_decode_opx_inst;
        $props->{c_decode_func} = \&c_decode_opx_inst;
        $props->{decode_arg} = undef;   # Not used
        $props->{inst_type} = $OPX_INST_TYPE;
    
        add_inst_desc($reserved_inst_descs, $props);
    }

    return $reserved_inst_descs;
}



sub
add_opx_inst_desc
{
    my $inst_descs = shift;
    my $inst_name = shift;
    my $inst_mode = shift;      # Optional


    my $code = get_opx_inst_code($inst_name);

    if (!defined($code)) {
      return &$error("Can't determine code for for OPX instruction" .
        "'$inst_name'");
    }

    my $props = {};

    $props->{name} = $inst_name;
    $props->{code} = $code;
    $props->{mode} = $inst_mode;
    $props->{v_decode_func} = \&v_decode_opx_inst;
    $props->{c_decode_func} = \&c_decode_opx_inst;
    $props->{decode_arg} = undef;   # Not used
    $props->{inst_type} = $OPX_INST_TYPE;

    return add_inst_desc($inst_descs, $props);
}







sub
v_decode_opx_inst
{
    my $decode_arg = shift; # Not used
    my $inst_desc = shift;
    my $stage = shift;

    my $code = get_inst_desc_code($inst_desc);

    return "${stage}_op_opx & (${stage}_iw_opx == $code)";
}








sub
c_decode_opx_inst
{
    my $decode_arg = shift; # Not used
    my $inst_desc = shift;

    my $name_uc = uc(get_inst_desc_name($inst_desc));

    return "(GET_IW_OPX((Iw)) == OPX_${name_uc}) && IS_OPX_INST(Iw)";
}



sub
add_custom_inst_descs
{
    my $custom_instructions = shift;

    my $inst_descs = [];

    foreach my $ci_name (sort(keys(%$custom_instructions))) {
        my $props = {};
        $props->{name} = $ci_name;
        $props->{code} = $custom_instructions->{$ci_name}{addr_base};
        $props->{v_decode_func} = \&v_decode_custom_inst;
        $props->{c_decode_func} = \&c_decode_custom_inst;
        $props->{decode_arg} = $custom_instructions;
        $props->{inst_type} = $CUSTOM_INST_TYPE;

        add_inst_desc($inst_descs, $props);
    }

    return $inst_descs;
}









sub
v_decode_custom_inst
{
    my $decode_arg = shift; # Custom instructions hash reference
    my $inst_desc = shift;
    my $stage = shift;

    my $inst_name = get_inst_desc_name($inst_desc);

    my $n_decode_expr = nios2_custom_insts::get_n_decode_expr(
      $decode_arg,
      $inst_name,
      $stage . "_iw_custom_n");

    if (!defined($n_decode_expr)) {
        return undef;
    }

    return "(${stage}_op_custom & " . $n_decode_expr . ")";
}


sub
c_decode_custom_inst
{
    return undef;
}



sub
add_inst_desc
{
    my $inst_descs = shift;
    my $props = shift;

    my $inst_name = $props->{name};

    if (defined(get_inst_desc_by_name_or_undef($inst_descs, $inst_name))) {
        return 
          &$error("Instruction description name '$inst_name' already exists");
    }

    my $inst_desc = create_inst_desc($props);


    push(@$inst_descs, $inst_desc);

    return $inst_desc;
}


sub
gen_extra_inst_desc_signals
{
    my $gen_info = shift;
    my $extra_gen_func_arg = shift;     # not used
    my $stage = shift;
    my $create_register = shift;
    my $previous_stage = shift;

    if ($create_register) {
        &$error("Don't support create_register flag");
    }

    my $assignment_func = manditory_code($gen_info, "assignment_func");

    my $op_opx_code = get_op_inst_code("opx");
    if (!defined($op_opx_code)) {
        &$error("Can't find OP code for OPX instructions.");
    }


    &$assignment_func({
      lhs => "${stage}_op_opx",
      rhs => "${stage}_iw_op == $op_opx_code",
      sz => 1,
      never_export => 1,
    });

    my $op_custom_code = get_op_inst_code("custom");
    if (!defined($op_custom_code)) {
        &$error("Can't find OP code for custom instructions.");
    }


    &$assignment_func({
      lhs => "${stage}_op_custom",
      rhs => "${stage}_iw_op == $op_custom_code",
      sz => 1,
      never_export => 1,
    });
}

















sub
add_inst_ctrls
{
    my $inst_args = shift;
    my $inst_descs = shift;

    my $custom_instructions = manditory_hash($inst_args, "custom_instructions");
    my $has_custom_insts = nios2_custom_insts::has_insts($custom_instructions);
    my $reserved_instructions_trap =
      manditory_bool($inst_args, "reserved_instructions_trap"),
    
    my $default_allowed_modes = get_default_inst_ctrl_allowed_modes($inst_args);
    my $exception_allowed_modes = 
      get_exception_inst_ctrl_allowed_modes($inst_args);
    my $shadow_present = manditory_bool($inst_args, "shadow_present");

    my $inst_ctrls = [];


    $unimp_trap_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "unimp_trap",
      insts => get_inst_desc_names_by_modes($inst_descs, 
        [$INST_DESC_UNIMP_TRAP_MODE]),
      allowed_modes => [$INST_DESC_UNIMP_TRAP_MODE],
    });


    $unimp_nop_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "unimp_nop",
      insts => get_inst_desc_names_by_modes($inst_descs, 
        [$INST_DESC_UNIMP_NOP_MODE]),
      allowed_modes => [$INST_DESC_UNIMP_NOP_MODE],
    });


    $illegal_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "illegal",
      ctrls => ($reserved_instructions_trap ? ["reserved"] : undef),
      allowed_modes => [$INST_DESC_RESERVED_MODE],
    });


    $reserved_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "reserved",
      insts => get_inst_desc_names_by_modes($inst_descs, 
        [$INST_DESC_RESERVED_MODE]),
      allowed_modes => [$INST_DESC_RESERVED_MODE],
    });


    $custom_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "custom",
      insts => nios2_custom_insts::get_ci_names($custom_instructions),
      allowed_modes => $default_allowed_modes,
    });


    $custom_combo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "custom_combo",
      insts => nios2_custom_insts::get_combo_ci_names($custom_instructions),
      allowed_modes => $default_allowed_modes,
    });


    $custom_multi_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "custom_multi",
      insts => nios2_custom_insts::get_multi_ci_names($custom_instructions),
      allowed_modes => $default_allowed_modes,
    });


    my $supervisor_only_insts = 
      ["initi", "initd", "eret", "bret", "wrctl", "rdctl"];
    if ($shadow_present) {
        push(@$supervisor_only_insts, "rdprs", "wrprs");
    }
    $supervisor_only_ctrl = add_inst_ctrl($inst_ctrls, { 
      name  => "supervisor_only",
      insts => $supervisor_only_insts,
      allowed_modes => $default_allowed_modes,
    });


    $ic_index_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_index_inv",
      insts => ["initi", "flushi"],
      allowed_modes => $default_allowed_modes,
    });


    $invalidate_i_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "invalidate_i",
      ctrls => ["ic_index_inv", "crst"],
      allowed_modes => $default_allowed_modes,
    });


    $flush_pipe_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "flush_pipe",
      insts => ["flushp","bret","wrprs"],
      ctrls => ["ic_index_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $jmp_indirect_non_trap_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp_indirect_non_trap",
      insts => ["ret","jmp","rsvx21","callr"],
      allowed_modes => $default_allowed_modes,
    });


    $jmp_indirect_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp_indirect",
      insts => ["eret","bret","rsvx17","rsvx25"],
      ctrls => ["jmp_indirect_non_trap"],
      allowed_modes => $default_allowed_modes,
    });


    $jmp_direct_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp_direct",
      insts => ["call","jmpi"],
      allowed_modes => $default_allowed_modes,
    });


    $mul_lsw_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_lsw",
      insts => ["muli","mul","rsvx47","rsvx55","rsvx63"],
      allowed_modes => $default_allowed_modes,
    });


    $mulx_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mulx",
      insts => ["mulxuu","rsvx15","mulxsu","mulxss"],
      allowed_modes => $default_allowed_modes,
    });


    $mul_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul",
      ctrls => ["mul_lsw", "mulx"],
      allowed_modes => $default_allowed_modes,
    });

    $div_unsigned_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div_unsigned",
      insts => ["divu"],
      allowed_modes => $default_allowed_modes,
    });

    $div_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div_signed",
      insts => ["div"],
      allowed_modes => $default_allowed_modes,
    });


    $div_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div",
      ctrls => ["div_unsigned", "div_signed"],
      allowed_modes => $default_allowed_modes,
    });



    $implicit_dst_retaddr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "implicit_dst_retaddr",
      insts => ["call","rsv02"],
      allowed_modes => $default_allowed_modes,
    });



    $implicit_dst_eretaddr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "implicit_dst_eretaddr",
      ctrls => ["unimp_trap", "illegal"],
      allowed_modes => $exception_allowed_modes,
    });


    $intr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "intr",
      insts => ["intr","rsvx60"],
      allowed_modes => $default_allowed_modes,
    });


    $exception_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "exception",
      insts => ["trap","rsvx44"],
      ctrls => ["unimp_trap", "illegal", "intr"],
      allowed_modes => $exception_allowed_modes,
    });


    $break_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "break",
      insts => ["break","hbreak"],
      allowed_modes => $default_allowed_modes,
    });


    $crst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "crst",
      insts => ["crst","rsvx63"],
      allowed_modes => $default_allowed_modes,
    });


    $wr_ctl_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wr_ctl_reg",
      insts => ["wrctl","bret","eret"],
      ctrls => ["exception", "break", "crst"],
      allowed_modes => $exception_allowed_modes,
    });


    $uncond_cti_non_br_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "uncond_cti_non_br",
      ctrls => ["jmp_direct", "jmp_indirect"],
      allowed_modes => $default_allowed_modes,
    });


    $retaddr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "retaddr",
      insts => ["call","rsv02","nextpc","callr"],
      ctrls => ["exception", "break"],
      allowed_modes => $exception_allowed_modes,
    });


    $shift_left_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_left",
      insts => ["slli","rsvx50","sll","rsvx51"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_logical_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_logical",
      insts => ["slli","sll","srli","srl"],
      allowed_modes => $default_allowed_modes,
    });


    $rot_left_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rot_left",
      insts => ["roli","rsvx34","rol","rsvx35"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_rot_left_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_left",
      ctrls => ["shift_left","rot_left"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_right_logical_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right_logical",
      insts => ["srli","srl"],
      allowed_modes => $default_allowed_modes,
    });
    $shift_right_arith_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right_arith",
      insts => ["srai","sra"],
      allowed_modes => $default_allowed_modes,
    });
    $shift_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right",
      ctrls => ["shift_right_logical","shift_right_arith"],
      allowed_modes => $default_allowed_modes,
    });


    $rot_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rot_right",
      insts => ["rsvx10","ror","rsvx42","rsvx43"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_rot_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_right",
      ctrls => ["shift_right","rot_right"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot",
      ctrls => ["shift_rot_left","shift_rot_right"],
      allowed_modes => $default_allowed_modes,
    });


    $shift_rot_imm_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_imm",
      insts => 
        ["roli","rsvx10","slli","srli","rsvx34","rsvx42","rsvx50","srai"],
      allowed_modes => $default_allowed_modes,
    });


    $rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rot",
      ctrls => ["rot_left","rot_right"],
      allowed_modes => $default_allowed_modes,
    });


    $logic_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_reg",
      insts => ["and","or","xor","nor"],
      allowed_modes => $default_allowed_modes,
    });


    $logic_hi_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_hi_imm16",
      insts => ["andhi","orhi","xorhi"],
      allowed_modes => $default_allowed_modes,
    });


    $logic_lo_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_lo_imm16",
      insts => ["andi","ori","xori"],
      allowed_modes => $default_allowed_modes,
    });


    $logic_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_imm16",
      ctrls => ["logic_hi_imm16","logic_lo_imm16"],
      allowed_modes => $default_allowed_modes,
    });


    $logic_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic",
      ctrls => ["logic_reg","logic_imm16"],
      allowed_modes => $default_allowed_modes,
    });


    $hi_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "hi_imm16",
      ctrls => ["logic_hi_imm16"],
      allowed_modes => $default_allowed_modes,
    });





    $unsigned_lo_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "unsigned_lo_imm16",
      insts => ["cmpgeui","cmpltui"],
      ctrls => ["logic_lo_imm16","shift_rot_imm"],
      allowed_modes => $default_allowed_modes,
    });


    $arith_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "arith_imm16",
      insts => ["addi","muli"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_imm16",
      insts => ["cmpgei","cmplti","cmpnei","cmpgeui","cmpltui","cmpeqi"],
      allowed_modes => $default_allowed_modes,
    });


    $jmpi_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmpi",
      insts => ["jmpi","rsv09","rsv17","rsv25","rsv33","rsv41","rsv49","rsv57"],
      allowed_modes => $default_allowed_modes,
    });



    $cmp_imm16_with_call_jmpi_rdprs_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_imm16_with_call_jmpi_rdprs",
      insts => ["call","rdprs"],
      ctrls => ["cmp_imm16","jmpi"],
      allowed_modes => $default_allowed_modes,
    });
    

    $cmp_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_reg",
      insts => 
        ["rsvx00","cmpge","cmplt","cmpne","cmpgeu","cmpltu","cmpeq","rsvx56"],
      allowed_modes => $default_allowed_modes,
    });


    $src_imm5_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "src_imm5",
      insts => ["trap","break"],
      ctrls => ["shift_rot_imm"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_with_lt_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_with_lt",
      insts => ["cmplti","cmpltui","cmplt","cmpltu"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_with_eq_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_with_eq",
      insts => ["cmpgei","cmpgeui","cmpeqi","cmpge","cmpgeu","cmpeq"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_with_ge_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_with_ge",
      insts => ["cmpgei","cmpgeui","cmpge","cmpgeu"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_with_ne_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_with_ne",
      insts => ["cmpnei","cmpne"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_alu_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_alu_signed",
      insts => ["cmpge","cmpgei","cmplt","cmplti"],
      allowed_modes => $default_allowed_modes,
    });


    $cmp_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp",
      ctrls => ["cmp_imm16","cmp_reg"],
      allowed_modes => $default_allowed_modes,
    });


    $br_with_lt_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_with_lt",
      insts => ["blt","bltu"],
      allowed_modes => $default_allowed_modes,
    });


    $br_with_ge_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_with_ge",
      insts => ["bge","rsv10","bgeu","rsv42"],
      allowed_modes => $default_allowed_modes,
    });


    $br_with_eq_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_with_eq",
      insts => ["bge","rsv10","bgeu","rsv42","beq","rsv34"],
      allowed_modes => $default_allowed_modes,
    });


    $br_with_ne_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_with_ne",
      insts => ["bne","rsv62"],
      allowed_modes => $default_allowed_modes,
    });


    $br_alu_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_alu_signed",
      insts => ["bge","blt"],
      allowed_modes => $default_allowed_modes,
    });


    $br_cond_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_cond",
      insts => 
        ["bge","rsv10","blt","bne","rsv62","bgeu","rsv42","bltu","beq","rsv34"],
      allowed_modes => $default_allowed_modes,
    });


    $br_uncond_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_uncond",
      insts => ["br","rsv02"],
      allowed_modes => $default_allowed_modes,
    });



    $br_always_pred_taken_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_always_pred_taken",
      allowed_modes => $default_allowed_modes,
    });


    $br_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br",
      insts => ["br","bge","blt","bne","beq","bgeu","bltu","rsv62"],
      allowed_modes => $default_allowed_modes,
    });


    $alu_subtract_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_subtract",
      insts => ["sub","rsvx25"],
      ctrls => ["cmp_with_lt","br_with_lt","cmp_with_ge","br_with_ge"],
      allowed_modes => $default_allowed_modes,
    });


    $alu_signed_comparison_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_signed_comparison",
      ctrls => ["cmp_alu_signed","br_alu_signed"],
      allowed_modes => $default_allowed_modes,
    });


    $br_cmp_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_cmp",
      ctrls => ["br", "cmp"],
      allowed_modes => $default_allowed_modes,
    });



    $br_cmp_eq_ne_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_cmp_eq_ne",
      ctrls => ["cmp_with_eq","cmp_with_ne","br_with_eq","br_with_ne"],
      allowed_modes => $default_allowed_modes,
    });


    $ld8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld8",
      insts => ["ldb","ldbu","ldbio","ldbuio"],
      allowed_modes => $default_allowed_modes,
    });


    $ld16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld16",
      insts => ["ldhu","ldh","ldhio","ldhuio"],
      allowed_modes => $default_allowed_modes,
    });


    $ld8_ld16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld8_ld16",
      ctrls => ["ld8", "ld16"],
      allowed_modes => $default_allowed_modes,
    });


    $ld32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld32",
      insts => ["ldw","ldl","ldwio","rsv63"],
      allowed_modes => $default_allowed_modes,
    });


    $ld_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_signed",
      insts => ["ldb","ldh","ldl","ldw","ldbio","ldhio","ldwio","rsv63"],
      allowed_modes => $default_allowed_modes,
    });


    $ld_unsigned_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_unsigned",
      insts => ["ldbu","ldhu","ldbuio","ldhuio"],
      allowed_modes => $default_allowed_modes,
    });


    $ld_ctrl = add_inst_ctrl($inst_ctrls, { 
      name => "ld",
      ctrls => ["ld_signed","ld_unsigned"],
      allowed_modes => $default_allowed_modes,
    });



    $dcache_management_nop_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dcache_management_nop",
      insts => ["initd","initda","flushd","flushda"],
      allowed_modes => [$INST_DESC_UNIMP_NOP_MODE],
    });


    $ld_dcache_management_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_dcache_management",
      insts => ["initd","initda","flushd","flushda"],
      ctrls => ["ld"],
      allowed_modes => $default_allowed_modes,
    });


    $ld_non_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_non_io",
      insts => ["ldbu","ldhu","ldb","ldh","ldw","ldl"],
      allowed_modes => $default_allowed_modes,
    });


    $st8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st8",
      insts => ["stb","stbio"],
      allowed_modes => $default_allowed_modes,
    });


    $st16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st16",
      insts => ["sth","rsv09","sthio","rsv41"],
      allowed_modes => $default_allowed_modes,
    });


    $st_non32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_non32",
      insts => [ "stb","stbio", "sth","sthio" ],
      allowed_modes => $default_allowed_modes,
    });


    $st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st32",
      insts => ["stw","rsv17","stc","rsv25","stwio","rsv49","rsv61","rsv57"],
      allowed_modes => $default_allowed_modes,
    });


    $st_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st",
      insts => ["stb","sth","stw","stc","stbio","sthio","stwio","rsv61"],
      allowed_modes => $default_allowed_modes,
    });


    $st_non_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_non_io",
      insts => ["stb","sth","stw","stc"],
      allowed_modes => $default_allowed_modes,
    });

    $ld_st_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st",
      ctrls => ["ld","st"],
      allowed_modes => $default_allowed_modes,
    });

    $ld_st_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st_io",
      ctrls => ["ld_io","st_io"],
      allowed_modes => $default_allowed_modes,
    });

    $ld_st_non_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st_non_io",
      ctrls => ["ld_non_io","st_non_io"],
      allowed_modes => $default_allowed_modes,
    });

    $ld_st_non_io_non_st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st_non_io_non_st32",
      insts => ["stb", "sth"],
      ctrls => ["ld_non_io"],
      allowed_modes => $default_allowed_modes,
    });

    $ld_st_non_st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st_non_st32",
      ctrls => ["ld","st8","st16"],
      allowed_modes => $default_allowed_modes,
    });


    $mem_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem",
      ctrls => ["ld_dcache_management","st"],
      allowed_modes => $default_allowed_modes,
    });


    $mem_data_access_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem_data_access",
      insts => ["flushda", "initda"],
      ctrls => ["ld","st"],
      allowed_modes => $default_allowed_modes,
    });


    $mem8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem8",
      ctrls => ["ld8","st8"],
      allowed_modes => $default_allowed_modes,
    });


    $mem16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem16",
      ctrls => ["ld16","st16"],
      allowed_modes => $default_allowed_modes,
    });


    $mem32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem32",
      ctrls => ["ld32","st32"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_index_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_nowb_inv",
      insts => ["initd","rsv49"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_addr_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_nowb_inv",
      insts => ["initda","rsv17"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_index_wb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_wb_inv",
      insts => ["flushd","rsv57"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_addr_wb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_wb_inv",
      insts => ["flushda","rsv25"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_index_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_inv",
      ctrls => ["dc_index_nowb_inv","dc_index_wb_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_addr_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_inv",
      ctrls => ["dc_addr_nowb_inv","dc_addr_wb_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_wb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_wb_inv",
      ctrls => ["dc_index_wb_inv","dc_addr_wb_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $dc_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_nowb_inv",
      ctrls => ["dc_index_nowb_inv","dc_addr_nowb_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $dcache_management_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dcache_management",
      ctrls => ["dc_index_inv","dc_addr_inv"],
      allowed_modes => $default_allowed_modes,
    });


    $ld_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_io",
      insts => ["ldbuio","ldhuio","ldbio","ldhio","ldwio","rsv63"],
      allowed_modes => $default_allowed_modes,
    });
    $st_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_io",
      insts => 
        ["stbio","rsv33","sthio","rsv41","stwio","rsv49","rsv61","rsv57"],
      allowed_modes => $default_allowed_modes,
    });
    $st_io_non_st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_io_non_st32",
      insts => ["stbio","rsv33","sthio","rsv41"],
      allowed_modes => $default_allowed_modes,
    });
    $st_non_io_non_st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_non_io_non_st32",
      insts => ["stb", "sth"],
      allowed_modes => $default_allowed_modes,
    });
    $mem_io_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem_io",
      ctrls => ["ld_io","st_io"],
      allowed_modes => $default_allowed_modes,
    });



    $a_not_src_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "a_not_src",
      ctrls => ["jmp_direct"],
      v_expr_func => $has_custom_insts ? 
          sub {


              my $stage = shift;
              return "| (${stage}_op_custom & ~${stage}_iw_custom_readra)";
          } :
          undef,
      c_expr_func => 
          sub {
              return "  || (IS_CUSTOM_INST(Iw) && !GET_IW_CUSTOM_READRA(Iw))";
          },
      allowed_modes => $default_allowed_modes,
    });



    my @b_field_allowed_modes = 
      (@$default_allowed_modes, $INST_DESC_UNIMP_NOP_MODE);







    $b_not_src_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "b_not_src",
      ctrls => ["arith_imm16","logic_imm16","cmp_imm16_with_call_jmpi_rdprs",
                "ld","dcache_management_nop"],
      v_expr_func => $has_custom_insts ? 
          sub {


              my $stage = shift;
              return "| (${stage}_op_custom & ~${stage}_iw_custom_readrb)";
          } :
          undef,
      c_expr_func => 
          sub {
              return "  || (IS_CUSTOM_INST(Iw) && !GET_IW_CUSTOM_READRB(Iw))";
          },
      allowed_modes => \@b_field_allowed_modes,
    });






    $b_is_dst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "b_is_dst",
      ctrls => ["b_not_src"],
      v_expr_func => $has_custom_insts ? 
          sub {


              my $stage = shift;
              return "& ~${stage}_op_custom";
          } :
          undef,
      allowed_modes => \@b_field_allowed_modes,
    });





    $ignore_dst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ignore_dst",
      ctrls => ["br","st","jmpi"],
      v_expr_func => $has_custom_insts ? 
          sub {


              my $stage = shift;
              return "| (${stage}_op_custom & ~${stage}_iw_custom_writerc)";
          } :
          undef,
      c_expr_func => 
          sub {
              return "  || (IS_CUSTOM_INST(Iw) && !GET_IW_CUSTOM_WRITERC(Iw))";
          },
      allowed_modes => $default_allowed_modes,
    });





    $ignore_dst_or_ld_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ignore_dst_or_ld",
      ctrls => ["ignore_dst","ld"],
      v_expr_func => $has_custom_insts ? 
          sub {


              my $stage = shift;
              return "| (${stage}_op_custom & ~${stage}_iw_custom_writerc)";
          } :
          undef,
      allowed_modes => $default_allowed_modes,
    });





    $src2_choose_imm_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "src2_choose_imm",
      ctrls => ["b_not_src","st","shift_rot_imm"],
      allowed_modes => \@b_field_allowed_modes,
    });


    $wrctl_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wrctl_inst",
      insts => ["wrctl"],
      allowed_modes => $default_allowed_modes,
    });
    $rdctl_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rdctl_inst",
      insts => ["rdctl"],
      allowed_modes => $default_allowed_modes,
    });


    $rdprs_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rdprs",
      insts => ["rdprs","rsv57"],
      allowed_modes => $default_allowed_modes,
    });


    $mul_src1_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_src1_signed",
      insts => ["mulxss","mulxsu"],
      allowed_modes => $default_allowed_modes,
    });
    $mul_src2_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_src2_signed",
      insts => ["mulxss"],
      allowed_modes => $default_allowed_modes,
    });


    $mul_shift_src1_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_src1_signed",
      ctrls => ["mul_src1_signed","shift_right_arith"],
      allowed_modes => $default_allowed_modes,
    });

    $mul_shift_src2_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_src2_signed",
      ctrls => ["mul_src2_signed"],
      allowed_modes => $default_allowed_modes,
    });

    $mul_shift_rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_rot",
      ctrls => ["mul", "shift_rot"],
      allowed_modes => $default_allowed_modes,
    });



    $dont_display_dst_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dont_display_dst_reg",
      insts => ["eret","bret","sync","callr","wrctl","initi","flushi",
                "flushp","initda","flushda","initd","flushd","jmp","ret"],
      ctrls => ["jmp_direct","exception","break","crst"],
      allowed_modes => get_all_inst_desc_modes(),
    });



    $dont_display_src1_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dont_display_src1_reg",
      insts => ["eret","bret","sync","br","ret","nextpc","rdctl","flushp"],
      ctrls => ["exception","break","crst"],
      allowed_modes => get_all_inst_desc_modes(),
    });



    $dont_display_src2_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dont_display_src2_reg",
      insts => ["jmp","ret","eret","bret","sync","br","callr","nextpc","rdctl",
                "wrctl","flushp","initi","flushi"],
      ctrls => ["exception","break","crst","shift_rot_imm"],
      allowed_modes => get_all_inst_desc_modes(),
    });




    $src1_no_x_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "src1_no_x",
      insts => ["wrctl"],
      ctrls => ["cmp","mem","mul","br","jmp_indirect"],
      allowed_modes => get_all_inst_desc_modes(),
    });




    $src2_no_x_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "src2_no_x",
      ctrls => ["cmp","mem","mul","br"],
      allowed_modes => get_all_inst_desc_modes(),
    });

    return $inst_ctrls;
}



sub
add_inst_ctrl
{
    my $inst_ctrls = shift;
    my $props = shift;

    my $ctrl_name = $props->{name};

    if (defined(get_inst_ctrl_by_name_or_undef($inst_ctrls, $ctrl_name))) {
        return 
          &$error("Instruction control name '$ctrl_name' already exists");
    }

    my $inst_ctrl = create_inst_ctrl($props);


    push(@$inst_ctrls, $inst_ctrl);

    return $inst_ctrl;
}



sub
encode_opx_inst
{
    my $inst_fields = shift;
    my $opx_code = shift;
    my $a_field_value = shift;
    my $b_field_value = shift;
    my $c_field_value = shift;

    if (!defined($opx_code)) {
        return &$error("opx_code is not defined");
    }


    if (!defined($op_inst_field)) {
        return &$error("OP instruction field global reference not defined");
    }

    my $op_opx_code = get_op_inst_code("opx");
    if (!defined($op_opx_code)) {
        &$error("Can't find OP code for OPX instructions.");
    }

    my $op_field = get_inst_field_by_name($inst_fields, "op");
    my $opx_field = get_inst_field_by_name($inst_fields, "opx");
    my $a_field = get_inst_field_by_name($inst_fields, "a");
    my $b_field = get_inst_field_by_name($inst_fields, "b");
    my $c_field = get_inst_field_by_name($inst_fields, "c");


    return 
      ($op_opx_code   << get_inst_field_lsb($op_field)) |
      ($opx_code      << get_inst_field_lsb($opx_field)) |
      ($a_field_value << get_inst_field_lsb($a_field)) |
      ($b_field_value << get_inst_field_lsb($b_field)) |
      ($c_field_value << get_inst_field_lsb($c_field));
}

sub
get_op_inst_code
{
    my $inst_name = shift;

    return get_inst_code(\@possible_op_insts, $inst_name);
}

sub
get_opx_inst_code
{
    my $inst_name = shift;

    return get_inst_code(\@possible_opx_insts, $inst_name);
}



sub
get_inst_code
{
    my $insts = shift;
    my $inst_name = shift;

    if ($inst_name eq "") { return undef; }

    for (my $i = 0; $i < scalar(@$insts); $i++) {
        if ($inst_name eq ${$insts}[$i]) {
            return $i;
        }
    }

    return undef;   # Not found
}

sub
convert_opcode_tables_to_c
{
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $index;


    push(@$c_lines, 
      "",
      "/* OP instruction opcode values (index is OP field) */",
      "const char*",
      "op_names[NUM_OP_INSTS] = {");

    push(@$h_lines, 
      "",
      "/* OP instruction opcode values (index is OP field) */",
      "#define NUM_OP_INSTS " . scalar(@possible_op_insts),
      "#ifndef ALT_ASM_SRC",
      "extern const char* op_names[NUM_OP_INSTS];",
      "#endif /* ALT_ASM_SRC */");

    push(@$h_lines, 
      "",
      "/* OP instruction values */",
    );

    $index = 0;
    foreach my $op (@possible_op_insts) {
        my $name = ($op =~ /^\d\d$/) ? "" : $op;
        my $last = ($index == $#possible_op_insts);

        push(@$c_lines, 
          "    \"$name\"" . ($last ? "" : ",") . 
            sprintf(" /* 0x%02x */", $index, $index));

        if ($name ne "") {
            push(@$h_lines, format_c_macro("OP_" . $name, $index));
        }

        $index++;
    }
    push(@$c_lines, "};");

    push(@$h_lines, 
      "",
      "/* OPX instruction opcode values (index is OPX field) */",
      "#define NUM_OPX_INSTS " . scalar(@possible_opx_insts),
      "",
      "#ifndef ALT_ASM_SRC",
      "extern const char* opx_names[NUM_OPX_INSTS];",
      "#endif /* ALT_ASM_SRC */");

    push(@$h_lines, 
      "",
      "/* OPX instruction values */",
    );

    push(@$c_lines, 
      "",
      "/* OPX instruction opcode values (index is OPX field) */",
      "const char*",
      "opx_names[NUM_OPX_INSTS] = {");

    $index = 0;
    foreach my $opx (@possible_opx_insts) {
        my $name = ($opx =~ /^\d\d$/) ? "" : $opx;
        my $last = ($index == $#possible_opx_insts);

        push(@$c_lines, 
          "    \"$name\"" . ($last ? "" : ",") . 
            sprintf(" /* 0x%02x */", $index, $index));

        if ($name ne "") {
            push(@$h_lines, format_c_macro("OPX_" . $name, $index));
        }

        $index++;
    }
    push(@$c_lines, "};");

    push(@$h_lines, 
      "",
      "/* Macros to detect sub-opcode instructions */",
      "#define IS_OPX_INST(Iw) (GET_IW_OP(Iw) == OP_OPX)",
      "#define IS_CUSTOM_INST(Iw) (GET_IW_OP(Iw) == OP_CUSTOM)");

    return 1;   # Some defined value
}

sub
convert_constants_to_c
{
    my $inst_constants = shift;
    my $c_lines = shift;
    my $h_lines = shift;

    push(@$h_lines, "");
    push(@$h_lines, "/* Instruction Constants */");
    format_hash_as_c_macros($inst_constants, $h_lines);

    return 1;   # Some defined value
}

sub
convert_inst_fields_to_c
{
    my $inst_fields = shift;
    my $c_lines = shift;
    my $h_lines = shift;

    push(@$h_lines, 
      "",
      "/*",
      " * Instruction field macros",
      " */");

    foreach my $inst_field (@$inst_fields) {
        if (!defined(
          convert_inst_field_to_c($inst_field, $c_lines, $h_lines))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}



sub
convert_inst_ctrls_to_c
{
    my $inst_ctrls = shift;
    my $all_inst_descs = shift;
    my $c_lines = shift;
    my $h_lines = shift;

    push(@$h_lines,
      "",
      "/*", 
      " * Instruction property macros",
      " */");

    foreach my $inst_ctrl (@$inst_ctrls) {


        my $expanded_inst_descs = [];
        if (!defined(cpu_inst_gen::expand_ctrl_insts($inst_ctrls, $inst_ctrl, 
          $all_inst_descs, $expanded_inst_descs))) {
            return undef;
        }


        my $filtered_inst_descs = get_inst_descs_by_modes(
          $expanded_inst_descs, [$INST_DESC_NORMAL_MODE]);

        my $ctrl_name_lc = get_inst_ctrl_name($inst_ctrl);
        my $ctrl_name_uc = uc($ctrl_name_lc);
        my $define_prefix = "#define IW_PROP_${ctrl_name_uc}(Iw) ";

        my $c_expr_func = get_inst_ctrl_c_expr_func($inst_ctrl);
        my $extra_expr = "";
        if (defined($c_expr_func)) {
            $extra_expr = &$c_expr_func();
        }

        my $num_filtered_inst_descs = scalar(@$filtered_inst_descs);



        if ($num_filtered_inst_descs == 0) {
            push(@$h_lines, $define_prefix . "(0)");
        } elsif ($num_filtered_inst_descs <= 2) {

            push(@$h_lines, 
              $define_prefix . "( \\",
              "  ( \\");

            foreach my $inst_desc (@$filtered_inst_descs) {
                my $c_decode_func = get_inst_desc_c_decode_func($inst_desc);
                my $decode_func_arg = get_inst_desc_decode_arg($inst_desc);

                my $c_decode_expr = 
                  &$c_decode_func($decode_func_arg, $inst_desc);

                my $line = "    (" . $c_decode_expr . ")";

                if ($inst_desc == 
                  $filtered_inst_descs->[$num_filtered_inst_descs-1]) {

                    push(@$h_lines, 
                      $line . " \\",
                      "  ) \\",
                      $extra_expr . " \\",
                      ")");
                } else {

                    push(@$h_lines, $line . " || \\");
                }
            }
        } else {

            push(@$h_lines, $define_prefix . "( \\");

            my $need_op = 0;
            my $need_opx = 0;
            foreach my $inst_desc (@$filtered_inst_descs) {
                my $inst_type = get_inst_desc_inst_type($inst_desc);

                if ($inst_type == $OP_INST_TYPE) {
                    $need_op = 1;
                } elsif ($inst_type == $OPX_INST_TYPE) {
                    $need_opx = 1;
                } else {
                    &$error("Unknown instruction type of '$inst_type' for" .
                      " instruction '" . get_inst_desc_name($inst_desc) . "'");
                }
            }


            my $last_line;

            if ($need_op && $need_opx) {

                push(@$h_lines,
                  "    (op_prop_${ctrl_name_lc}\[GET_IW_OP(Iw)] || \\");
                $last_line = 
                  "    (IS_OPX_INST(Iw) && " . 
                    "opx_prop_${ctrl_name_lc}\[GET_IW_OPX(Iw)]))";
            } elsif ($need_op) {

                $last_line =
                  "    (op_prop_${ctrl_name_lc}\[GET_IW_OP(Iw)])";
            } elsif ($need_opx) {


                $last_line = 
                  "    (IS_OPX_INST(Iw) && " . 
                    "opx_prop_${ctrl_name_lc}\[GET_IW_OPX(Iw)])";
            } else {
                &$error("need_op and need_opx both zero");
            }

            push(@$h_lines, $last_line . $extra_expr . ")");


            push(@$c_lines,
              "",
              "/* Table(s) for IW_PROP_${ctrl_name_uc} macro */");;

            if ($need_op) {
                my $num_op = scalar(@possible_op_insts);
                push(@$c_lines,
                  "unsigned char",
                  "op_prop_${ctrl_name_lc}\[$num_op] = {");

                for (my $op = 0; $op < $num_op; $op++) {

                    my $inst_name = $possible_op_insts[$op];


                    my $on_list = get_inst_desc_by_name_or_undef(
                      $filtered_inst_descs, $inst_name);

                    my $after_number = ($op == ($num_op-1)) ? " " : ",";
                    if ($on_list) {
                        push(@$c_lines, sprintf("    1%s /* %s */", 
                          $after_number, $inst_name));
                    } else {
                        push(@$c_lines, sprintf("    0%s", $after_number));
                    }
                }

                push(@$c_lines, "};");


                push(@$h_lines,
                  "",
                  "#ifndef ALT_ASM_SRC",
                  "extern unsigned char op_prop_${ctrl_name_lc}\[$num_op];",
                  "#endif /* ALT_ASM_SRC */");
            }

            if ($need_opx) {
                my $num_opx = scalar(@possible_opx_insts);
                push(@$c_lines,
                  "unsigned char",
                  "opx_prop_${ctrl_name_lc}\[$num_opx] = {");

                for (my $opx = 0; $opx < $num_opx; $opx++) {

                    my $inst_name = $possible_opx_insts[$opx];


                    my $on_list = get_inst_desc_by_name_or_undef(
                      $filtered_inst_descs, $inst_name);

                    my $after_number = ($opx == ($num_opx-1)) ? " " : ",";
                    if ($on_list) {
                        push(@$c_lines, sprintf("    1%s /* %s */", 
                          $after_number, $inst_name));
                    } else {
                        push(@$c_lines, sprintf("    0%s", $after_number));
                    }
                }

                push(@$c_lines, "};");


                push(@$h_lines,
                  "",
                  "#ifndef ALT_ASM_SRC",
                  "extern unsigned char opx_prop_${ctrl_name_lc}\[$num_opx];",
                  "#endif /* ALT_ASM_SRC */");
            }
        }

        push(@$h_lines, "");
    }

    return 1;   # Some defined value
}








sub
create_c_inst_info_shared
{
    my $h_lines = shift;

    push(@$h_lines,
      "",
      "/* Instruction types */",
      "#define INST_TYPE_OP  $OP_INST_TYPE",
      "#define INST_TYPE_OPX $OPX_INST_TYPE");

    return 1;   # Some defined value
}




sub
create_c_inst_info
{
    my $c_lines = shift;
    my $h_lines = shift;
    my $include_pseudo = shift;

    my $X = $include_pseudo ? "X" : "";
    my $ext = $include_pseudo ? "extended " : "";

    push(@$h_lines,
      "",
      "#ifndef ALT_ASM_SRC",
      "/* Instruction information entry */",
      "typedef struct {",
      "     const char* name;     /* Assembly-language instruction name */",
      "     int         instType; /* INST_TYPE_OP or INST_TYPE_OPX */",
      "     unsigned    opcode;   /* Value of instruction word OP/OPX field */"
    );
    if ($include_pseudo) {
        push(@$h_lines,
          "     int         instCode; /* Corresponding INST_CODE_* (not INST_XCODE_*) */",
          "     int         isPseudo; /* Boolean */",
        );
    }
    push(@$h_lines,
      "} Nios2Inst${X}Info;",
      "#endif /* ALT_ASM_SRC */",
      "",
      "/* Canonical instruction codes independent of encoding. */");

    if ($include_pseudo) {
        push(@$h_lines,
          "/* Pseudo-instructions are included. */");
    } else {
        push(@$h_lines,
          "/* Pseudo-instructions are omitted. */");
    }

    push(@$c_lines,
      "",
      "/* Instruction information array (index is ${ext}instruction code) */",
      "Nios2Inst${X}Info nios2Inst${X}Info[] = {");

    my $numInstInfoEntries = 0;
















 
    my @pseudo_insts = (
      { name => "nop",      inst_desc => $add_inst  },
      { name => "mov",      inst_desc => $add_inst  },
      { name => "movi",     inst_desc => $addi_inst },
      { name => "incspi",   inst_desc => $addi_inst },
      { name => "addspi",   inst_desc => $addi_inst },
      { name => "movui",    inst_desc => $ori_inst  },
      { name => "movhi",    inst_desc => $orhi_inst },
      { name => "beqz",     inst_desc => $beq_inst  },
      { name => "bnez",     inst_desc => $bne_inst  },
      { name => "ldwsp",    inst_desc => $ldw_inst  },
      { name => "stwsp",    inst_desc => $stw_inst  },
    );

    if ($include_pseudo) {
        for (my $index = 0; $index < scalar(@pseudo_insts); $index++) {
            my $pseudo_name = $pseudo_insts[$index]->{name};
            my $pseudoInstCodeStr = 
              sprintf("%s_INST_${X}CODE", uc($pseudo_name));
            push(@$h_lines, 
              sprintf("#define %s %d", $pseudoInstCodeStr, 
                $numInstInfoEntries));
    
            $numInstInfoEntries++;

            my $inst_desc = $pseudo_insts[$index]->{inst_desc};
            my $inst_type = get_inst_desc_inst_type($inst_desc);
            my $inst_suffix;

            if ($inst_type == $OP_INST_TYPE) {
                $inst_suffix = "OP";
            } elsif ($inst_type == $OPX_INST_TYPE) {
                $inst_suffix = "OPX";
            } else {
                return &$error("Couldn't determine instruction type for pseudo-iinstruction $pseudo_name");
            }

            my $refInstCodeStr = sprintf("%s_INST_CODE", 
               uc(get_inst_desc_name($inst_desc)));

            push(@$c_lines, 
              sprintf("    { \"%s\", INST_TYPE_%s, %d, %s, 1 },", 
                $pseudo_name, $inst_suffix, get_inst_desc_code($inst_desc),
                $refInstCodeStr));
        }
    }

    my @opToInstCodeLines;
    for (my $index = 0; $index < scalar(@possible_op_insts); $index++) {
        my $inst_name = $possible_op_insts[$index];
        my $instCodeStr = sprintf("%s_INST_${X}CODE", uc($inst_name));
        my $lastOpInst = (($index+1) == scalar(@possible_op_insts));
        my $term = ($lastOpInst ? "" : ",");

        if ($inst_name =~ /^\d+$/) {

            push(@opToInstCodeLines, "  RSV_INST_${X}CODE" . $term);
        } elsif ($inst_name ne "opx") {
            push(@opToInstCodeLines, "  " . $instCodeStr . $term);
    
            push(@$h_lines, 
              sprintf("#define %s %d", $instCodeStr, $numInstInfoEntries));
    
            $numInstInfoEntries++;

            my $refInstCodeStr = sprintf("%s_INST_CODE", uc($inst_name));
            my $extra_inst_info_args = 
              $include_pseudo ? ", $refInstCodeStr, 0" : "";

            push(@$c_lines, 
              sprintf("    { \"%s\", INST_TYPE_OP, %d%s },", 
              $inst_name, $index, $extra_inst_info_args));
        }
    }

    my $firstRsvOpxIndex = -1;

    my @opxToInstCodeLines;

    for (my $index = 0; $index < scalar(@possible_opx_insts); $index++) {
        my $inst_name = $possible_opx_insts[$index];
        my $instCodeStr = sprintf("%s_INST_${X}CODE", uc($inst_name));
        my $lastOpxInst = (($index+1) == scalar(@possible_opx_insts));
        my $term = ($lastOpxInst ? "" : ",");

        if ($inst_name =~ /^\d+$/) {

            if ($firstRsvOpxIndex == -1) {
                $firstRsvOpxIndex = $index;
            }

            push(@opxToInstCodeLines, "  RSV_INST_${X}CODE" . $term);
        } else {
            push(@opxToInstCodeLines, "  " . $instCodeStr . $term);

            push(@$h_lines, 
              sprintf("#define %s %d", $instCodeStr, $numInstInfoEntries));
    
            $numInstInfoEntries++;

            my $refInstCodeStr = sprintf("%s_INST_CODE", uc($inst_name));
            my $extra_inst_info_args = 
              $include_pseudo ? ", $refInstCodeStr, 0" : "";

            push(@$c_lines, 
              sprintf("    { \"%s\", INST_TYPE_OPX, %d%s },",
              $inst_name, $index, $extra_inst_info_args));
        }
    }

    if ($firstRsvOpxIndex == -1) {
        return &$error("Couldn't find any reserved OPX instructions");
    }



    push(@$h_lines, "#define RSV_INST_${X}CODE $numInstInfoEntries");
    $numInstInfoEntries++;
    my $rsv_extra_inst_info_args = $include_pseudo ? ", RSV_INST_CODE, 0" : "";
    push(@$c_lines,
      "    { \"rsv\", INST_TYPE_OPX, ${firstRsvOpxIndex}${rsv_extra_inst_info_args} }",
      "};");

    push(@$h_lines, 
      "#define NUM_NIOS2_INST_${X}CODES $numInstInfoEntries",
      "",
      "#ifndef ALT_ASM_SRC",
      "extern Nios2Inst${X}Info nios2Inst${X}Info[NUM_NIOS2_INST_${X}CODES];",
      "#endif /* ALT_ASM_SRC */",
      "");

    my $get_name;

    if ($include_pseudo) {
        $get_name = "get_inst_xcode()";

        push(@$h_lines, 
          "#ifndef ALT_ASM_SRC",
          "/* Returns the instruction extended code given the 32-bit instruction word */",
          "extern int get_inst_xcode(unsigned int iw);",
          "#endif /* ALT_ASM_SRC */");

        my $get_inst_xcode_str = <<'END';

int
get_inst_xcode(unsigned int iw)
{
    int         instXCode;
    const int   aField = GET_IW_A(iw);
    const int   bField = GET_IW_B(iw);
    const int   cField = GET_IW_C(iw);

    if (IS_OPX_INST(iw)) {
        instXCode = opxToInstXCode[GET_IW_OPX(iw)];

        /* Look for OPX pseudo-instructions. */
        switch (instXCode) {
        case ADD_INST_XCODE:
            if (aField == 0 && bField == 0 && cField == 0) {
                return NOP_INST_XCODE;
            } else if (bField == 0 && cField != 0) {
                return MOV_INST_XCODE;
            }
            break;
        }
    } else {
        /* Must be OP instruction. */
        instXCode = opToInstXCode[GET_IW_OP(iw)];

        /* Look for OP pseudo-instructions. */
        switch (instXCode) {
        case ADDI_INST_XCODE:
            if (aField == 0 && bField != 0) {
                return MOVI_INST_XCODE;
            }
            if (aField == 27 && bField == 27) {
                return INCSPI_INST_XCODE;
            }
            if (aField == 27) {
                return ADDSPI_INST_XCODE;
            }
            break;
        case ORI_INST_XCODE:
            if (aField == 0 && bField != 0) {
                return MOVUI_INST_XCODE;
            }
            break;
        case ORHI_INST_XCODE:
            if (aField == 0 && bField != 0) {
                return MOVHI_INST_XCODE;
            }
            break;
        case BEQ_INST_XCODE:
            if (aField != 0 && bField == 0) {
                return BEQZ_INST_XCODE;
            }
            break;
        case BNE_INST_XCODE:
            if (aField != 0 && bField == 0) {
                return BNEZ_INST_XCODE;
            }
            break;
        case LDW_INST_XCODE:
            if (aField == 27) {
                return LDWSP_INST_XCODE;
            }
            break;
        case STW_INST_XCODE:
            if (aField == 27) {
                return STWSP_INST_XCODE;
            }
            break;
        }
    }
    
    return instXCode;
}
END
        push(@$c_lines, $get_inst_xcode_str); 
    } else {
        $get_name = "GET_INST_CODE()";

        push(@$h_lines, 
          "/* Returns the instruction code given the 32-bit instruction word */",
          "#define GET_INST_${X}CODE(Iw) \\",
          "    (IS_OPX_INST(Iw) ? opxToInstCode[GET_IW_OPX(Iw)] :" .
            " opToInst${X}Code[GET_IW_OP(Iw)])");
    }

    my $opToInstCodeEntries = scalar(@possible_op_insts);
    my $opxToInstCodeEntries = scalar(@possible_opx_insts);

    push(@$c_lines,
      "",
      "/* Used by $get_name to map OP instruction to ${ext}instruction code */",
      "int opToInst${X}Code[$opToInstCodeEntries] = {",
      @opToInstCodeLines,
      "};");

    push(@$c_lines,
      "",
      "/* Used by $get_name to map OPX instruction to" .
        " ${ext}instruction code */",
      "int opxToInst${X}Code[$opxToInstCodeEntries] = {",
      @opxToInstCodeLines,
      "};");

    push(@$h_lines,
      "",
      "#ifndef ALT_ASM_SRC",
      "extern int opToInst${X}Code[$opToInstCodeEntries];",
      "extern int opxToInst${X}Code[$opxToInstCodeEntries];",
      "#endif /* ALT_ASM_SRC */");

    return 1;   # Some defined value
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios2_insts.pm: eval($cmd) returns '$@'\n");
    }
}

1;
