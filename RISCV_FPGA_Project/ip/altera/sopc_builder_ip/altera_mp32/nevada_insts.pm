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






















package nevada_insts;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $rs_inst_field
    $rt_inst_field
    $rd_inst_field
    $funct_inst_field
    $op_inst_field
    $sa_inst_field
    $hint_inst_field
    $imm16_inst_field
    $imm26_inst_field
    $cache_type_inst_field
    $cache_operation_inst_field
    $select_inst_field

    $iw_rs_sz $iw_rs_lsb $iw_rs_msb 
    $iw_rt_sz $iw_rt_lsb $iw_rt_msb
    $iw_rd_sz $iw_rd_lsb $iw_rd_msb 
    $iw_funct_sz $iw_funct_lsb $iw_funct_msb
    $iw_op_sz $iw_op_lsb $iw_op_msb
    $iw_sa_sz $iw_sa_lsb $iw_sa_msb
    $iw_hint_sz $iw_hint_lsb $iw_hint_msb
    $iw_imm16_sz $iw_imm16_lsb $iw_imm16_msb
    $iw_imm26_sz $iw_imm26_lsb $iw_imm26_msb
    $iw_cache_type_sz $iw_cache_type_lsb $iw_cache_type_msb
    $iw_cache_operation_sz $iw_cache_operation_lsb $iw_cache_operation_msb
    $iw_select_sz $iw_select_lsb $iw_select_msb

    $mul_signed_ctrl
    $mul_unsigned_or_dont_care_ctrl
    $mul_lsw_ctrl
    $mulx_ctrl
    $mul_ctrl
    $mul_shift_src1_signed_ctrl
    $mul_shift_src2_signed_ctrl
    $mul_shift_rot_ctrl
    $mult_accum_ctrl
    $mult_inst_ctrl
    $bit_ctrl
    $movzn_ctrl
    $clzclo_ctrl
    $div_unsigned_ctrl
    $div_signed_ctrl
    $div_ctrl
    $hilo_inst_ctrl
    $mfhilo_inst_ctrl
    $mthilo_inst_ctrl
    $wrt_hi_ctrl
    $wrt_lo_ctrl
    $rd_lo_ctrl
    $rd_hi_ctrl
    $wrt_hilo_ctrl
    $rd_hilo_ctrl
    $shift_left_ctrl
    $shift_right_logical_ctrl
    $shift_right_arith_ctrl
    $shift_right_ctrl
    $shift_logical_ctrl
    $rot_right_ctrl
    $shift_rot_left_ctrl
    $shift_rot_right_ctrl
    $shift_rot_ctrl
    $shift_rot_imm_ctrl
    $rot_ctrl
    $extins_ctrl
    $arith_imm16_ctrl
    $logic_reg_ctrl
    $logic_ctrl
    $logic_hi_imm16_ctrl
    $logic_lo_imm16_ctrl
    $logic_imm16_ctrl
    $cmp_imm16_ctrl
    $cmp_reg_ctrl
    $cmp_with_lt_ctrl
    $cmp_alu_signed_ctrl
    $cmp_ctrl
    $br_src1_eq_src2_ctrl
    $br_src1_ne_src2_ctrl
    $br_src1_lt_zero_ctrl
    $br_src1_le_zero_ctrl
    $br_src1_gt_zero_ctrl
    $br_src1_ge_zero_ctrl
    $br_likely_ctrl
    $br_always_pred_taken_ctrl
    $br_uncond_op_table_ctrl
    $br_uncond_regimm_table_ctrl
    $br_uncond_ctrl
    $br_cond_ctrl
    $br_op_table_ctrl
    $br_regimm_table_ctrl
    $br_ctrl
    $has_delay_slot_ctrl
    $jmp_indirect_ctrl
    $jmp_direct_ctrl
    $jmp_ctrl
    $arith_ctrl
    $alu_signed_comparison_ctrl
    $alu_add_operation_ctrl
    $alu_and_operation_ctrl
    $alu_or_operation_ctrl
    $alu_nor_operation_ctrl
    $ld8_ctrl
    $ld16_ctrl
    $ld8_ld16_ctrl
    $ld32_ctrl
    $lwlr_ctrl
    $swlr_ctrl
    $ld_signed_ctrl
    $ld_unsigned_ctrl
    $ld_ctrl
    $st8_ctrl
    $st16_ctrl
    $st32_ctrl
    $st_ctrl
    $sc_ctrl
    $ld_st_ctrl
    $ld_st_non_st32_ctrl
    $mem8_ctrl
    $mem16_ctrl
    $mem32_ctrl
    $mem_ctrl
    $ld_addr_ctrl
    $ld_data_access_ctrl
    $st_data_access_ctrl
    $mem_data_access_ctrl
    $dcache_management_ctrl
    $cache_management_ctrl
    $dc_index_wb_inv_ctrl
    $dc_index_store_tag_ctrl
    $dc_addr_nowb_inv_ctrl
    $dc_addr_wb_inv_ctrl
    $dc_index_nowb_inv_ctrl
    $dc_index_inv_ctrl
    $dc_addr_inv_ctrl
    $dc_nowb_inv_ctrl
    $ic_index_inv_ctrl
    $ic_addr_inv_ctrl
    $ic_hit_inv_ctrl
    $ic_tag_wdata_ctrl
    $ic_tag_wr_ctrl
    $ic_tag_rd_ctrl
    $ic_only_read_tag_ctrl
    $trap_src1_eq_src2_ctrl
    $trap_src1_ne_src2_ctrl
    $trap_src1_lt_src2_ctrl
    $trap_src1_ge_src2_ctrl
    $trap_alu_signed_ctrl
    $trap_reg_imm16_ctrl
    $trap_reg_reg_ctrl
    $trap_ctrl
    $hi_imm16_ctrl
    $unsigned_lo_imm16_ctrl
    $rs_not_src_ctrl
    $rt_is_src_or_slow_dst_ctrl
    $sel_rd_for_dst_ctrl
    $implicit_dst_retaddr_ctrl
    $ignore_dst_ctrl
    $src2_choose_imm16_ctrl
    $wrctl_inst_ctrl
    $rdctl_inst_ctrl
    $tlb_wr_inst_ctrl
    $tlb_inst_ctrl
    $reserved_ctrl
    $cop0_ctrl
    $cop1_or_cop1x_ctrl
    $cop2_ctrl
    $flush_pipe_ctrl
    $retaddr_ctrl
    $ehb_inst_ctrl

    $op_cop1
    $op_cop2
    $op_cop1x
);

use cpu_inst_field;
use cpu_inst_table;
use cpu_inst_desc;
use cpu_inst_ctrl;
use cpu_inst_gen;
use cpu_control_reg;
use cpu_utils;
use nevada_common;
use strict;













our $op_inst_table;
our $special_inst_table;
our $srl_inst_table;
our $srlv_inst_table;
our $jr_inst_table;
our $jalr_inst_table;
our $regimm_inst_table;
our $cop0_inst_table;
our $mfmc0_inst_table;
our $c0_inst_table;
our $special2_inst_table;
our $special3_inst_table;
our $bshfl_inst_table;
our $cache_inst_table;
our $icache_inst_table;
our $dcache_inst_table;


our $INST_TYPE_OP       = 0;
our $INST_TYPE_SPECIAL  = 1;
our $INST_TYPE_REGIMM   = 2;
our $INST_TYPE_COP0     = 3;
our $INST_TYPE_MFMC0    = 4;
our $INST_TYPE_C0       = 5;
our $INST_TYPE_SPECIAL2 = 6;
our $INST_TYPE_SPECIAL3 = 7;
our $INST_TYPE_BSHFL    = 8;
our $INST_TYPE_CACHE    = 9;
our @INST_TYPES = (
  { name => "INST_TYPE_OP",         value => $INST_TYPE_OP,         },
  { name => "INST_TYPE_SPECIAL",    value => $INST_TYPE_SPECIAL,    },
  { name => "INST_TYPE_REGIMM",     value => $INST_TYPE_REGIMM,     },
  { name => "INST_TYPE_COP0",       value => $INST_TYPE_COP0,       },
  { name => "INST_TYPE_MFMC0",      value => $INST_TYPE_MFMC0,      },
  { name => "INST_TYPE_C0",         value => $INST_TYPE_C0,         },
  { name => "INST_TYPE_SPECIAL2",   value => $INST_TYPE_SPECIAL2,   },
  { name => "INST_TYPE_SPECIAL3",   value => $INST_TYPE_SPECIAL3,   },
  { name => "INST_TYPE_BSHFL",      value => $INST_TYPE_BSHFL,      },
  { name => "INST_TYPE_CACHE",      value => $INST_TYPE_CACHE,      },
);


our $rs_inst_field;
our $rt_inst_field;
our $rd_inst_field;
our $funct_inst_field;
our $op_inst_field;
our $sa_inst_field;
our $hint_inst_field;
our $imm16_inst_field;
our $imm26_inst_field;
our $cache_type_inst_field;
our $cache_operation_inst_field;
our $select_inst_field;


our $iw_rs_sz;
our $iw_rs_lsb;
our $iw_rs_msb;
our $iw_rt_sz;
our $iw_rt_lsb;
our $iw_rt_msb;
our $iw_rd_sz;
our $iw_rd_lsb;
our $iw_rd_msb;
our $iw_funct_sz;
our $iw_funct_lsb;
our $iw_funct_msb;
our $iw_op_sz;
our $iw_op_lsb;
our $iw_op_msb;
our $iw_sa_sz;
our $iw_sa_lsb;
our $iw_sa_msb;
our $iw_hint_sz;
our $iw_hint_lsb;
our $iw_hint_msb;
our $iw_imm16_sz;
our $iw_imm16_lsb;
our $iw_imm16_msb;
our $iw_imm26_sz;
our $iw_imm26_lsb;
our $iw_imm26_msb;
our $iw_cache_type_sz;
our $iw_cache_type_lsb;
our $iw_cache_type_msb;
our $iw_cache_operation_sz;
our $iw_cache_operation_lsb;
our $iw_cache_operation_msb;
our $iw_select_sz;
our $iw_select_lsb;
our $iw_select_msb;



our $mul_signed_ctrl;
our $mul_unsigned_or_dont_care_ctrl;
our $mul_lsw_ctrl;
our $mulx_ctrl;
our $mul_ctrl;
our $mul_shift_src1_signed_ctrl;
our $mul_shift_src2_signed_ctrl;
our $mul_shift_rot_ctrl;
our $mult_accum_ctrl;
our $mult_inst_ctrl;
our $bit_ctrl;
our $movzn_ctrl;
our $clzclo_ctrl;
our $div_unsigned_ctrl;
our $div_signed_ctrl;
our $div_ctrl;
our $hilo_inst_ctrl;
our $mfhilo_inst_ctrl;
our $mthilo_inst_ctrl;
our $wrt_hi_ctrl;
our $wrt_lo_ctrl;
our $rd_lo_ctrl;
our $rd_hi_ctrl;
our $wrt_hilo_ctrl;
our $rd_hilo_ctrl;
our $shift_left_ctrl;
our $shift_right_logical_ctrl;
our $shift_right_arith_ctrl;
our $shift_right_ctrl;
our $shift_logical_ctrl;
our $rot_right_ctrl;
our $shift_rot_left_ctrl;
our $shift_rot_right_ctrl;
our $shift_rot_ctrl;
our $shift_rot_imm_ctrl;
our $rot_ctrl;
our $extins_ctrl;
our $arith_imm16_ctrl;
our $logic_reg_ctrl;
our $logic_ctrl;
our $logic_hi_imm16_ctrl;
our $logic_lo_imm16_ctrl;
our $logic_imm16_ctrl;
our $cmp_imm16_ctrl;
our $cmp_reg_ctrl;
our $cmp_with_lt_ctrl;
our $cmp_alu_signed_ctrl;
our $cmp_ctrl;
our $br_src1_eq_src2_ctrl;
our $br_src1_ne_src2_ctrl;
our $br_src1_lt_zero_ctrl;
our $br_src1_le_zero_ctrl;
our $br_src1_gt_zero_ctrl;
our $br_src1_ge_zero_ctrl;
our $br_likely_ctrl;
our $br_always_pred_taken_ctrl;
our $br_uncond_op_table_ctrl;
our $br_uncond_regimm_table_ctrl;
our $br_uncond_ctrl;
our $br_cond_ctrl;
our $br_op_table_ctrl;
our $br_regimm_table_ctrl;
our $br_ctrl;
our $has_delay_slot_ctrl;
our $jmp_indirect_ctrl;
our $jmp_direct_ctrl;
our $jmp_ctrl;
our $arith_ctrl;
our $alu_signed_comparison_ctrl;
our $alu_add_operation_ctrl;
our $alu_and_operation_ctrl;
our $alu_or_operation_ctrl;
our $alu_nor_operation_ctrl;
our $ld8_ctrl;
our $ld16_ctrl;
our $ld8_ld16_ctrl;
our $ld32_ctrl;
our $lwlr_ctrl;
our $swlr_ctrl;
our $ld_signed_ctrl;
our $ld_unsigned_ctrl;
our $ld_ctrl;
our $st8_ctrl;
our $st16_ctrl;
our $st32_ctrl;
our $st_ctrl;
our $sc_ctrl;
our $ld_st_ctrl;
our $ld_st_non_st32_ctrl;
our $mem8_ctrl;
our $mem16_ctrl;
our $mem32_ctrl;
our $mem_ctrl;
our $ld_addr_ctrl;
our $ld_data_access_ctrl;
our $st_data_access_ctrl;
our $mem_data_access_ctrl;
our $dcache_management_ctrl;
our $cache_management_ctrl;
our $dc_index_wb_inv_ctrl;
our $dc_index_store_tag_ctrl;
our $dc_addr_nowb_inv_ctrl;
our $dc_addr_wb_inv_ctrl;
our $dc_index_nowb_inv_ctrl;
our $dc_index_inv_ctrl;
our $dc_addr_inv_ctrl;
our $dc_nowb_inv_ctrl;
our $ic_index_inv_ctrl;
our $ic_addr_inv_ctrl;
our $ic_hit_inv_ctrl;
our $ic_tag_wdata_ctrl;
our $ic_tag_wr_ctrl;
our $ic_tag_rd_ctrl;
our $ic_only_read_tag_ctrl;
our $trap_src1_eq_src2_ctrl;
our $trap_src1_ne_src2_ctrl;
our $trap_src1_lt_src2_ctrl;
our $trap_src1_ge_src2_ctrl;
our $trap_alu_signed_ctrl;
our $trap_reg_imm16_ctrl;
our $trap_reg_reg_ctrl;
our $trap_ctrl;
our $hi_imm16_ctrl;
our $unsigned_lo_imm16_ctrl;
our $rs_not_src_ctrl;
our $rt_is_src_or_slow_dst_ctrl;
our $sel_rd_for_dst_ctrl;
our $implicit_dst_retaddr_ctrl;
our $ignore_dst_ctrl;
our $src2_choose_imm16_ctrl;
our $wrctl_inst_ctrl;
our $rdctl_inst_ctrl;
our $tlb_wr_inst_ctrl;
our $tlb_inst_ctrl;
our $reserved_ctrl;
our $cop0_ctrl;
our $cop1_or_cop1x_ctrl;
our $cop2_ctrl;
our $flush_pipe_ctrl;
our $retaddr_ctrl;
our $ehb_inst_ctrl;




our $op_cop1;
our $op_cop2;
our $op_cop1x;







sub
create_inst_args_from_infos
{
    my $misc_info = shift;
    my $mmu_info = shift;

    my $local_mmu_present = manditory_bool($mmu_info, "mmu_present");
    my $local_tlb_present = 
      $local_mmu_present && manditory_bool($mmu_info, "tlb_present");

    my $inst_args = {
        debug_port_present => manditory_bool($misc_info, "debug_port_present"),
        mmu_present => $local_mmu_present,
        tlb_present => $local_tlb_present,
    };

    return $inst_args;
}




sub
create_inst_args_from_test_args
{
    my $test_args = shift;  # Hash to args required to setup for tests

    my $inst_args = {
        debug_port_present => manditory_bool($test_args, "debug_port_present"),
        mmu_present => manditory_bool($test_args, "mmu_present"),
        tlb_present => manditory_bool($test_args, "tlb_present"),
    };

    return $inst_args;
}



sub
get_default_test_args_configuration
{
    return {
      configuration_name          => "default",
      debug_port_present          => 1,
      mmu_present                 => 1,
      tlb_present                 => 1,
    };
}


sub
get_test_args_configurations
{
    return [
      {
        configuration_name          => "no_debug_port",
        debug_port_present          => 0,
        mmu_present                 => 1,
        tlb_present                 => 1,
      },
      {
        configuration_name          => "no_mmu",
        debug_port_present          => 1,
        mmu_present                 => 0,
        tlb_present                 => 1,
      },
      {
        configuration_name          => "fmt",
        debug_port_present          => 1,
        mmu_present                 => 1,
        tlb_present                 => 0,
      },
      {
        configuration_name          => "no_debug_port_no_mmu",
        debug_port_present          => 0,
        mmu_present                 => 0,
        tlb_present                 => 1,
      },
    ];
}




sub
create_inst_args_gen_isa_configuration
{
    return create_inst_args_from_test_args(
      get_default_test_args_configuration());
}




sub
validate_and_elaborate
{
    my $inst_args = shift;



    my $default_allowed_modes = 
      [$INST_DESC_NORMAL_MODE, $INST_DESC_RESERVED_MODE];

    my $inst_fields = add_inst_fields() || return undef;
    my $inst_tables = add_inst_tables($inst_fields) || return undef;
    my $constants = add_inst_constants() || return undef;
    my $inst_descs = add_inst_descs($inst_tables, $inst_args) 
      || return undef;
    my ($inst_ctrls, $extra_inst_desc_signals) =
      add_inst_ctrls($inst_descs, $default_allowed_modes);
    if (!defined($inst_ctrls) || !defined($extra_inst_desc_signals)) {
        return undef;
    }

    my $inst_info = {
      default_inst_ctrl_allowed_modes => $default_allowed_modes,
      inst_field_info       => {
        inst_fields => $inst_fields,
        extra_gen_func => undef,    # not used
      },
      inst_tables           => $inst_tables,
      inst_constants        => $constants,
      inst_desc_info        => {
        inst_descs  => $inst_descs,
        extra_gen_func => \&gen_extra_inst_desc_signals,
        extra_gen_func_arg => {
            inst_tables             => $inst_tables,
            extra_inst_desc_signals => $extra_inst_desc_signals,
        },
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

    convert_inst_fields_to_c($inst_info->{inst_field_info}{inst_fields},
      $c_lines, $h_lines) || return undef;
    convert_inst_tables_to_c($inst_info->{inst_tables}, $c_lines, $h_lines) ||
      return undef;
    convert_constants_to_c($inst_info->{inst_constants}, $c_lines, $h_lines) ||
      return undef;

    push(@$h_lines,
      "#define MIPS32_IS_COP1_OR_COP1X_INST(Iw)" .
        " ((GET_MIPS32_IW_OP(Iw) == MIPS32_OP_COP1 ||" .
          " GET_MIPS32_IW_OP(Iw) == MIPS32_OP_COP1X))",
      "#define MIPS32_IS_COP2_INST(Iw)" .
        " (GET_MIPS32_IW_OP(Iw) == MIPS32_OP_COP2)",
    );

    convert_inst_ctrls_to_c($inst_info->{inst_ctrls},
      $inst_info->{inst_desc_info}{inst_descs}, $c_lines, $h_lines) ||
      return undef;
    create_c_inst_info($inst_info->{inst_desc_info}{inst_descs},
      $inst_info->{inst_tables}, $c_lines, $h_lines) ||
      return undef;

    return 1;   # Some defined value
}




sub
additional_inst_ctrl
{
    my $Opt = shift;
    my $props = shift;

    my $inst_ctrls = manditory_array($Opt, "inst_ctrls");

    return add_inst_ctrl($inst_ctrls, $props);
}






sub
add_inst_constants
{
    my %constants;


    $constants{op_cop1} = 17;
    $constants{op_cop2} = 18;
    $constants{op_cop1x} = 19;

    return \%constants;
}

















sub
add_inst_fields
{
    my $inst_fields = [];

    $rs_inst_field = add_inst_field($inst_fields, {
      name => "rs", 
      lsb  => 21,
      sz   => 5,
    });

    $rt_inst_field = add_inst_field($inst_fields, {
      name => "rt", 
      lsb  => 16,
      sz   => 5,
    });
    
    $rd_inst_field = add_inst_field($inst_fields, {
      name => "rd", 
      lsb  => 11,
      sz   => 5,
    });
    
    $funct_inst_field = add_inst_field($inst_fields, {
      name => "funct", 
      lsb  => 0,
      sz   => 6,
    });
    
    $op_inst_field = add_inst_field($inst_fields, {
      name => "op", 
      lsb  => 26,
      sz   => 6,
    });
    
    $sa_inst_field = add_inst_field($inst_fields, {
      name => "sa", 
      lsb  => 6,
      sz   => 5,
    });



    $hint_inst_field = add_inst_field($inst_fields, {
      name => "hint",
      lsb  => 10,
      sz   => 1,
    });
    
    $imm16_inst_field = add_inst_field($inst_fields, {
      name => "imm16", 
      lsb  => 0,
      sz   => 16,
    });
    
    $imm26_inst_field = add_inst_field($inst_fields, {
      name => "imm26", 
      lsb  => 0,
      sz   => 26,
    });


    $cache_type_inst_field = add_inst_field($inst_fields, {
      name => "cache_type", 
      lsb  => 16,
      sz   => 2,
    });
    

    $cache_operation_inst_field = add_inst_field($inst_fields, {
      name => "cache_operation", 
      lsb  => 18,
      sz   => 3,
    });


    $select_inst_field = add_inst_field($inst_fields, {
      name => "select", 
      lsb  => 0,
      sz   => 3,
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
add_inst_tables
{
    my $inst_fields = shift;

    my $inst_tables = [];

    my @op_opcodes =

      qw(   SPECIAL REGIMM  j       jal     beq     bne     blez    bgtz
            addi    addiu   slti    sltiu   andi    ori     xori    lui
            COP0    17      18      19      beql    bnel    blezl   bgtzl
            24      25      26      27      SPECIAL2 29     30      SPECIAL3
            lb      lh      lwl     lw      lbu     lhu     lwr     39
            sb      sh      swl     sw      44      45      swr     CACHE
            ll      lwc1    lwc2    pref    52      ldc1    ldc2    55
            sc      swc1    swc2    59      60      sdc1    sdc2    63
        );

    $op_inst_table = add_inst_table($inst_tables, {
      name          => "op",
      inst_field    => get_inst_field_by_name($inst_fields, "op"),
      opcodes       => \@op_opcodes,
      inst_type     => $INST_TYPE_OP,
    });
      



    my @special_opcodes =

      qw(   sll     movci   SRL     sra     sllv     5      SRLV    srav
            jr      jalr    movz    movn    syscall break   14      sync
            mfhi    mthi    mflo    mtlo    20      21      22      23
            mult    multu   div     divu    28      29      30      31
            add     addu    sub     subu    and     or      xor     nor
            40      41      slt     sltu    44      45      46      47
            tge     tgeu    tlt     tltu    teq     53      tne     55
            56      57      58      59      60      61      62      63
        );
    
    $special_inst_table = add_inst_table($inst_tables, {
      name          => "special",
      inst_field    => get_inst_field_by_name($inst_fields, "funct"),
      opcodes       => \@special_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_SPECIAL,
    });
      

    my @srl_opcodes = 

      qw(   srl     rotr     2       3       4       5       6       7
             8       9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            24      25      26      27      28      29      30      31
        );
   
    $srl_inst_table = add_inst_table($inst_tables, {
      name          => "srl",
      inst_field    => get_inst_field_by_name($inst_fields, "rs"),
      opcodes       => \@srl_opcodes,
      parent_table  => $special_inst_table,
      inst_type     => $INST_TYPE_SPECIAL,
    });
      

    my @srlv_opcodes = 

      qw(   srlv    rotrv   2       3       4       5       6       7
             8       9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            24      25      26      27      28      29      30      31
        );
    
    $srlv_inst_table = add_inst_table($inst_tables, {
      name          => "srlv",
      inst_field    => get_inst_field_by_name($inst_fields, "sa"),
      opcodes       => \@srlv_opcodes,
      parent_table  => $special_inst_table,
      inst_type     => $INST_TYPE_SPECIAL,
    });
      

    my @regimm_opcodes =

      qw(   bltz    bgez    bltzl   bgezl    4       5       6       7
            tgei    tgeiu   tlti    tltiu   teqi    13      tnei    15
            bltzal  bgezal  bltzall bgezall 20      21      22      23
            24      25      26      27      28      29      30      synci
        );
    
    $regimm_inst_table = add_inst_table($inst_tables, {
      name          => "regimm",
      inst_field    => get_inst_field_by_name($inst_fields, "rt"),
      opcodes       => \@regimm_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_REGIMM,
    });
      

    my @cop0_opcodes =

      qw(   mfc0     1       2       3      mtc0    5       6       7
             8       9      rdpgpr  MFMC0   12      13      wrpgpr  15
            C0      C0      C0      C0      C0      C0      C0      C0
            C0      C0      C0      C0      C0      C0      C0      C0
        );
  
    $cop0_inst_table = add_inst_table($inst_tables, {
      name          => "cop0",
      inst_field    => get_inst_field_by_name($inst_fields, "rs"),
      opcodes       => \@cop0_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_COP0,
    });
      

    my @mfmc0_opcodes =

      qw(   di       1       2       3       4       5       6       7
             8       9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            24      25      26      27      28      29      30      31
            ei      33      34      35      36      37      38      39
            40      41      42      43      44      45      46      47
            48      49      50      51      52      53      54      55
            56      57      58      59      60      61      62      63
        );

    $mfmc0_inst_table = add_inst_table($inst_tables, {
      name          => "mfmc0",
      inst_field    => get_inst_field_by_name($inst_fields, "funct"),
      opcodes       => \@mfmc0_opcodes,
      parent_table  => $cop0_inst_table,
      inst_type     => $INST_TYPE_MFMC0,
    });
      

    my @c0_opcodes =

      qw(    0      tlbr    tlbwi    3       4       5      tlbwr    7
            tlbp     9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            eret    25      26      27      28      29      30      deret
            wait    33      34      35      36      37      38      39
            40      41      42      43      44      45      46      47
            48      49      50      51      52      53      54      55
            56      57      58      59      60      61      62      63
        );
    
    $c0_inst_table = add_inst_table($inst_tables, {
      name          => "c0",
      inst_field    => get_inst_field_by_name($inst_fields, "funct"),
      opcodes       => \@c0_opcodes,
      parent_table  => $cop0_inst_table,
      inst_type     => $INST_TYPE_C0,
    });
      

    my @special2_opcodes =

      qw(   madd    maddu   mul      3      msub    msubu   6       7
             8       9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            24      25      26      27      28      29      30      31
            clz     clo     34      35      36      37      38      39
            40      41      42      43      44      45      46      47
            48      49      50      51      52      53      54      55
            56      57      58      59      60      61      62      sdbbp
        );
    
    $special2_inst_table = add_inst_table($inst_tables, {
      name          => "special2",
      inst_field    => get_inst_field_by_name($inst_fields, "funct"),
      opcodes       => \@special2_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_SPECIAL2,
    });
      

    my @special3_opcodes =

      qw(   ext      1       2       3      ins      5       6       7
             8       9      10      11      12      13      14      15
            16      17      18      19      20      21      22      23
            24      25      26      27      28      29      30      31
            BSHFL   33      34      35      36      37      38      39
            40      41      42      43      44      45      46      47
            48      49      50      51      52      53      54      55
            56      57      58      rdhwr   60      61      62      63
        );
    
    $special3_inst_table = add_inst_table($inst_tables, {
      name          => "special3",
      inst_field    => get_inst_field_by_name($inst_fields, "funct"),
      opcodes       => \@special3_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_SPECIAL3,
    });
      

    my @bshfl_opcodes = 

      qw(    0       1      wsbh     3       4       5       6       7
             8       9      10      11      12      13      14      15
            seb     17      18      19      20      21      22      23
            seh     25      26      27      28      29      30      31
        );

    $bshfl_inst_table = add_inst_table($inst_tables, {
      name          => "bshfl",
      inst_field    => get_inst_field_by_name($inst_fields, "sa"),
      opcodes       => \@bshfl_opcodes,
      parent_table  => $special3_inst_table,
      inst_type     => $INST_TYPE_BSHFL,
    });
      

    my @cache_opcodes =

      qw(   ICACHE  DCACHE  2       3);
    
    $cache_inst_table = add_inst_table($inst_tables, {
      name          => "cache",
      inst_field    => get_inst_field_by_name($inst_fields, "cache_type"),
      opcodes       => \@cache_opcodes,
      parent_table  => $op_inst_table,
      inst_type     => $INST_TYPE_CACHE,
    });


    my @icache_opcodes =

      qw(   icache_idx_inv  icache_ld_tag   icache_st_tag     3
            icache_hit_inv  5                 6               7);
    
    $icache_inst_table = add_inst_table($inst_tables, {
      name          => "icache",
      inst_field    => get_inst_field_by_name($inst_fields, "cache_operation"),
      opcodes       => \@icache_opcodes,
      parent_table  => $cache_inst_table,
      inst_type     => $INST_TYPE_CACHE,
    });


    my @dcache_opcodes =

      qw(   dcache_idx_wb_inv    dcache_ld_tag    dcache_st_tag     3
            dcache_hit_nowb_inv  dcache_hit_wb_inv dcache_hit_wb    7);
    
    $dcache_inst_table = add_inst_table($inst_tables, {
      name          => "dcache",
      inst_field    => get_inst_field_by_name($inst_fields, "cache_operation"),
      opcodes       => \@dcache_opcodes,
      parent_table  => $cache_inst_table,
      inst_type     => $INST_TYPE_CACHE,
    });

    return $inst_tables;
}



sub
add_inst_table
{
    my $inst_tables = shift;
    my $props = shift;

    my $table_name = $props->{name};

    if (defined(get_inst_table_by_name_or_undef($inst_tables, $table_name))) {
        return 
          &$error("Instruction table name '$table_name' already exists");
    }

    my $inst_table = create_inst_table($props);


    push(@$inst_tables, $inst_table);

    return $inst_table;
}



sub
add_inst_descs
{
    my $inst_tables = shift;
    my $inst_args = shift;

    my $inst_descs = [];



    add_inst_descs_for_inst_table($inst_descs, $inst_tables, $op_inst_table,
      $inst_args) 
        || return undef;

    return $inst_descs;
}



sub
add_inst_descs_for_inst_table
{
    my $inst_descs = shift;
    my $inst_tables = shift;
    my $inst_table = shift; 
    my $inst_args = shift;

    my @extra_reserved_insts;

    if (!manditory_bool($inst_args, "debug_port_present")) {

        push(@extra_reserved_insts, "sdbbp");
    }



    if (!manditory_bool($inst_args, "mmu_present") ||
      !manditory_bool($inst_args, "tlb_present")) {
        push(@extra_reserved_insts, "tlbwr", "tlbwi", "tlbp", "tlbr");
    }

    my $opcodes = get_inst_table_opcodes($inst_table); 
    my $inst_type = get_inst_table_inst_type($inst_table);



    for (my $code=0; $code < scalar(@$opcodes); $code++) {
        my $opcode = $opcodes->[$code];
        my $opcode_type = get_inst_table_opcode_type($opcode);

        my $name;
        my $opcode_is_reserved = 0;

        if ($opcode_type == $OPCODE_TYPE_INST_NAME) {
            $name = $opcode;

            foreach my $extra_reserved_inst (@extra_reserved_insts) {
                if ($opcode eq $extra_reserved_inst) {
                    $opcode_is_reserved = 1;
                }
            }
        } elsif ($opcode_type == $OPCODE_TYPE_RESERVED_NUM) {
            $name = 
              sprintf("%s_rsv%d", get_inst_table_name($inst_table), $code);
            $opcode_is_reserved = 1;
        } elsif ($opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME) {

            next;
        } else {
            &$error(
              "Unknown opcode_type of '$opcode_type' for opcode '$opcode'");
        }

        add_inst_desc($inst_descs, {
          name          => $name,
          code          => $code,
          mode          => ($opcode_is_reserved ? 
                              $INST_DESC_RESERVED_MODE :
                              $INST_DESC_NORMAL_MODE),
          v_decode_func => \&v_decode_inst,
          c_decode_func => \&c_decode_inst,
          decode_arg    => $inst_table,
          inst_type     => $inst_type,
          inst_table    => $inst_table,
        }) || return undef;
    }


    foreach my $child_table_info 
      (@{get_inst_table_child_table_infos($inst_tables, $inst_table)}) {
        my $child_table = manditory_hash($child_table_info, "child_table");

        add_inst_descs_for_inst_table($inst_descs, $inst_tables, $child_table,
          $inst_args)
            || return undef;
    }

    return 1;   # Some defined value
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
v_decode_inst
{
    my $decode_arg = shift;
    my $inst_desc = shift;
    my $stage = shift;


    my $inst_table = $decode_arg;

    my $inst_table_name = get_inst_table_name($inst_table);
    my $inst_field = get_inst_table_inst_field($inst_table);
    my $inst_field_name = get_inst_field_name($inst_field);

    my $code = get_inst_desc_code($inst_desc);

    my $decode_expr = "(${stage}_iw_${inst_field_name} == $code)";

    if (get_inst_table_parent_table($inst_table)) {
        $decode_expr .= " & ${stage}_is_${inst_table_name}_inst";
    }

    return $decode_expr;
}













sub
c_decode_inst
{
    my $decode_arg = shift;
    my $inst_desc = shift;


    my $inst_table = $decode_arg;

    my $inst_table_name_uc = uc(get_inst_table_name($inst_table));
    my $inst_field = get_inst_table_inst_field($inst_table);
    my $inst_field_name_uc = uc(get_inst_field_name($inst_field));

    my $inst_name_uc = uc(get_inst_desc_name($inst_desc));

    my $decode_expr = 
      "(GET_MIPS32_IW_${inst_field_name_uc}((Iw)) ==" .
      " MIPS32_${inst_table_name_uc}_${inst_name_uc})";

    if (get_inst_table_parent_table($inst_table)) {
        $decode_expr .= " && MIPS32_IS_${inst_table_name_uc}_INST(Iw)";
    }

    return $decode_expr;
}


sub
gen_extra_inst_desc_signals
{
    my $gen_info = shift;
    my $extra_gen_func_arg = shift;
    my $stage = shift;
    my $create_register = shift;
    my $previous_stage = shift;
    my $first_stage_with_register = shift;


    my $inst_tables = manditory_array($extra_gen_func_arg, "inst_tables");
    my $extra_inst_desc_signals = manditory_array($extra_gen_func_arg,
      "extra_inst_desc_signals");



    gen_extra_inst_desc_signals_for_inst_table($gen_info, $inst_tables,
      $op_inst_table, $stage, $create_register, $previous_stage,
      $first_stage_with_register);


    foreach my $extra_inst_desc_signal (@$extra_inst_desc_signals) {
        my $name = not_empty_scalar($extra_inst_desc_signal, "name");
        my $sz = manditory_int($extra_inst_desc_signal, "sz");
        my $rhs_func = manditory_code($extra_inst_desc_signal, "rhs_func");

        my $lhs = "${stage}_${name}";

        if ($create_register) {
            my $register_func = manditory_code($gen_info, "register_func");

            &$register_func({
              lhs => $lhs,
              rhs => "${previous_stage}_${name}",
              sz => $sz,
              en => $stage . "_en",
              never_export => 1,
            });
        } else {
            my $assignment_func = manditory_code($gen_info, "assignment_func");


            my $rhs = &$rhs_func($stage);

            if ($rhs eq "") {
                &$error("rhs for signal '$name' is empty");
            }

            &$assignment_func({
              lhs => $lhs,
              rhs => $rhs,
              sz => $sz,
              never_export => 1,
            });
        }
    }
}



sub
gen_extra_inst_desc_signals_for_inst_table
{
    my $gen_info = shift;
    my $inst_tables = shift;
    my $inst_table = shift;
    my $stage = shift;
    my $create_register = shift;
    my $previous_stage = shift;
    my $first_stage_with_register = shift;

    my $assignment_func = manditory_code($gen_info, "assignment_func");
    my $register_func = manditory_code($gen_info, "register_func");

    my $child_table_infos = 
      get_inst_table_child_table_infos($inst_tables, $inst_table);

    if (scalar(@$child_table_infos) > 0) {

        my $inst_table_name = get_inst_table_name($inst_table);
        my $inst_field = get_inst_table_inst_field($inst_table);
        my $inst_field_name = get_inst_field_name($inst_field);
        my $opcodes = get_inst_table_opcodes($inst_table); 

        foreach my $child_table_info (@$child_table_infos) {
            my $child_table = manditory_hash($child_table_info, "child_table");
            my $child_table_name = get_inst_table_name($child_table);
            my $lhs = "${stage}_is_${child_table_name}_inst";

            if ($create_register) {
                my $rhs;

                if (($stage eq $first_stage_with_register) &&
                  get_inst_table_parent_table($inst_table)) {


                    my $rhs = get_child_table_code_expr($child_table_info,
                      $stage, $inst_field_name) . 
                      " & ${stage}_is_${inst_table_name}_inst";

                    &$assignment_func({
                      lhs => $lhs,
                      rhs => $rhs,
                      sz => 1,
                      never_export => 1,
                    });
                } else {

                    &$register_func({
                      lhs => $lhs,
                      rhs => "${previous_stage}_is_${child_table_name}_inst",
                      sz => 1,
                      en => $stage . "_en",
                      never_export => 1,
                    });
                }
            } else {



                my $rhs = get_child_table_code_expr($child_table_info,
                  $stage, $inst_field_name);

                if (get_inst_table_parent_table($inst_table)) {
                    $rhs .= " & ${stage}_is_${inst_table_name}_inst";
                }

                &$assignment_func({
                  lhs => $lhs,
                  rhs => $rhs,
                  sz => 1,
                  never_export => 1,
                });
            }


            gen_extra_inst_desc_signals_for_inst_table($gen_info, $inst_tables,
              $child_table, $stage, $create_register, $previous_stage,
              $first_stage_with_register);
        }
    }
}

sub
get_child_table_code_expr
{
    my $child_table_info = shift;
    my $stage = shift;
    my $inst_field_name = shift;

    my $codes = manditory_array($child_table_info, "codes");
    my @code_exprs;
    foreach my $code (@$codes) {


        push(@code_exprs, "(${stage}_iw_${inst_field_name} == $code)");
    }

    return "(" . join('|', @code_exprs) . ")";
}

















sub
add_inst_ctrls
{
    my $inst_descs = shift;
    my $default_allowed_modes = shift;

    my $inst_ctrls = [];

    add_mul_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_bit_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_div_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_hilo_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_shift_rotate_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_alu_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_compare_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_branch_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_jump_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_load_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_store_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_mem_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_dcache_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_icache_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_trap_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_src_operands_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_dst_operand_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_cop0_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_tlb_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_c_model_inst_ctrls($inst_ctrls, $default_allowed_modes);
    add_misc_inst_ctrls($inst_ctrls, $default_allowed_modes, $inst_descs);



    my $extra_inst_desc_signals = [];

    push(@$extra_inst_desc_signals, 
      {
        name => "rs_is_zero",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return "${stage}_iw_rs == 0";
          },
      },
      {
        name => "rt_is_zero",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return "${stage}_iw_rt == 0";
          },
      },
      {
        name => "rd_is_zero",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return "${stage}_iw_rd == 0";
          },
      },
      {
        name => "is_special_or_special2_inst",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return 
              "${stage}_is_special_inst | ${stage}_is_special2_inst";
          },
      },
      {
        name => "is_cop1_or_cop1x_inst",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return "(${stage}_iw_op == $op_cop1 | ${stage}_iw_op == $op_cop1x)";
          },
      },
      {
        name => "is_cop2_inst",
        sz => 1,
        rhs_func => 
          sub {
            my $stage = shift;
            return "${stage}_iw_op == $op_cop2";
          },
      },
    );

    return ($inst_ctrls, $extra_inst_desc_signals);
}

sub
add_mul_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $mul_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_signed",
      insts => ["mult","madd","msub"],
      allowed_modes => $allowed_modes,
    });



    $mul_unsigned_or_dont_care_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_unsigned_or_dont_care",
      insts => ["maddu","msubu","multu","mul"],
      allowed_modes => $allowed_modes,
    });


    $mul_lsw_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_lsw",
      insts => ["mul"],
      allowed_modes => $allowed_modes,
    });



    $mulx_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mulx",
      insts => ["madd","maddu","msub","msubu","mult","multu"],
      allowed_modes => $allowed_modes,
    });


    $mul_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul",
      ctrls => ["mul_lsw", "mulx"],
      allowed_modes => $allowed_modes,
    });


    $mul_shift_src2_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_src2_signed",
      ctrls => ["mul_signed","shift_right_arith"],
      allowed_modes => $allowed_modes,
    });

    $mul_shift_src1_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_src1_signed",
      ctrls => ["mul_signed"],
      allowed_modes => $allowed_modes,
    });

    $mul_shift_rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mul_shift_rot",
      ctrls => ["mul", "shift_rot"],
      allowed_modes => $allowed_modes,
    });

    $mult_accum_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mult_accum",
      insts => ["madd","maddu", "msub","msubu"],
      allowed_modes => $allowed_modes,
    });

    $mult_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mult_inst",
      insts => ["mult","multu"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_bit_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;

    $bit_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "bit",
      insts => ["clz","clo","seb","seh","wsbh","wrpgpr","rdpgpr","movz","movn"],
      allowed_modes => $allowed_modes,
    });

    $movzn_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "movzn",
      insts => ["movz","movn"],
      allowed_modes => $allowed_modes,
    });

    $clzclo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "clzclo",
      insts => ["clz","clo"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_div_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;

    $div_unsigned_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div_unsigned",
      insts => ["divu"],
      allowed_modes => $allowed_modes,
    });

    $div_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div_signed",
      insts => ["div"],
      allowed_modes => $allowed_modes,
    });


    $div_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "div",
      ctrls => ["div_unsigned", "div_signed"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_hilo_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;

    $hilo_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "hilo_inst",
      insts => ["divu","div", "madd","maddu","msub","msubu","mtlo","mthi",
                "mflo","mfhi","mult","multu"],
      allowed_modes => $allowed_modes,
    });

    $mfhilo_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mfhilo_inst",
      insts => [ "mflo","mfhi"],
      allowed_modes => $allowed_modes,
    });

    $mthilo_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mthilo_inst",
      insts => [ "mtlo","mthi"],
      allowed_modes => $allowed_modes,
    });

    $rd_hi_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rd_hi",
      insts => [ "mfhi","madd","maddu","msub","msubu"],
      allowed_modes => $allowed_modes,
    });

    $rd_lo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rd_lo",
      insts => [ "mflo","madd","maddu","msub","msubu"],
      allowed_modes => $allowed_modes,
    });

    $wrt_lo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wrt_lo",
      insts => [ "mtlo","mult", "multu","madd","maddu","msub","msubu"],
      allowed_modes => $allowed_modes,
    });

    $wrt_hi_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wrt_hi",
      insts => [ "mthi","mult", "multu","madd","maddu","msub","msubu"],
      allowed_modes => $allowed_modes,
    });

    $wrt_hilo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wrt_hilo",
      insts => [ "mtlo","mthi","mult", "multu","madd","maddu","msub","msubu","divu","div"],
      allowed_modes => $allowed_modes,
    });

    $rd_hilo_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rd_hilo",
      insts => [ "mflo","mfhi","madd","maddu","msub","msubu"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_shift_rotate_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $shift_left_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_left",
      insts => ["sll","sllv","ins"],
      allowed_modes => $allowed_modes,
    });


    $shift_right_logical_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right_logical",
      insts => ["srl","srlv","ext"],
      allowed_modes => $allowed_modes,
    });


    $shift_right_arith_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right_arith",
      insts => ["sra","srav"],
      allowed_modes => $allowed_modes,
    });

    $shift_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_right",
      ctrls => ["shift_right_logical","shift_right_arith"],
      allowed_modes => $allowed_modes,
    });


    $shift_logical_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_logical",
      ctrls => ["shift_left", "shift_right_logical"],
      allowed_modes => $allowed_modes,
    });


    $rot_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rot_right",
      insts => ["rotr","rotrv"],
      allowed_modes => $allowed_modes,
    });




    $shift_rot_left_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_left",
      ctrls => ["shift_left"],
      allowed_modes => $allowed_modes,
    });


    $shift_rot_right_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_right",
      ctrls => ["shift_right","rot_right"],
      allowed_modes => $allowed_modes,
    });


    $shift_rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot",
      ctrls => ["shift_left","shift_rot_right"],
      allowed_modes => $allowed_modes,
    });


    $shift_rot_imm_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "shift_rot_imm",
      insts => ["rotr","sll","srl","sra","ext","ins"],
      allowed_modes => $allowed_modes,
    });


    $rot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rot",
      ctrls => ["rot_right"],
      allowed_modes => $allowed_modes,
    });


    $extins_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "extins",
      insts => ["ext","ins"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_alu_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $arith_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "arith_imm16",
      insts => ["addi","addiu"],
      allowed_modes => $allowed_modes,
    });


    $logic_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_reg",
      insts => ["and","or","xor","nor"],
      allowed_modes => $allowed_modes,
    });


    $logic_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic",
      ctrls => ["logic_reg","logic_imm16"],
      allowed_modes => $allowed_modes,
    });


    $logic_hi_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_hi_imm16",
      insts => ["lui"],
      allowed_modes => $allowed_modes,
    });


    $logic_lo_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_lo_imm16",
      insts => ["andi","ori","xori"],
      allowed_modes => $allowed_modes,
    });


    $logic_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "logic_imm16",
      ctrls => ["logic_hi_imm16","logic_lo_imm16"],
      allowed_modes => $allowed_modes,
    });


    $arith_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "arith",
      insts => ["addi","addiu","add","addu","sub","subu"],
      allowed_modes => $allowed_modes,
    });



    $alu_signed_comparison_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_signed_comparison",
      ctrls => ["cmp_alu_signed","trap_alu_signed"],
      allowed_modes => $allowed_modes,
    });


    $alu_add_operation_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_add_operation",
      insts => ["addi","addiu","add","addu","icache_idx_inv","icache_st_tag","icache_hit_inv"],
      ctrls => ["mem"],
      allowed_modes => $allowed_modes,
    });


    $alu_and_operation_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_and_operation",
      insts => ["andi","and"],
      allowed_modes => $allowed_modes,
    });


    $alu_or_operation_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_or_operation",
      insts => ["ori","or"],
      allowed_modes => $allowed_modes,
    });


    $alu_nor_operation_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "alu_nor_operation",
      insts => ["nor"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_compare_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $cmp_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_imm16",
      insts => ["slti","sltiu"],
      allowed_modes => $allowed_modes,
    });


    $cmp_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_reg",
      insts => ["slt","sltu"],
      allowed_modes => $allowed_modes,
    });


    $cmp_with_lt_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_with_lt",
      insts => ["slti","sltiu","slt","sltu"],
      allowed_modes => $allowed_modes,
    });


    $cmp_alu_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp_alu_signed",
      insts => ["slti","slt"],
      allowed_modes => $allowed_modes,
    });


    $cmp_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cmp",
      ctrls => ["cmp_imm16","cmp_reg"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_branch_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $br_src1_eq_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_eq_src2",
      insts => ["beq","beql"],
      allowed_modes => $allowed_modes,
    });


    $br_src1_ne_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_ne_src2",
      insts => ["bne","bnel"],
      allowed_modes => $allowed_modes,
    });


    $br_src1_lt_zero_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_lt_zero",
      insts => ["bltz", "bltzal", "bltzl", "bltzall"],
      allowed_modes => $allowed_modes,
    });


    $br_src1_le_zero_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_le_zero",
      insts => ["blez", "blezl"],
      allowed_modes => $allowed_modes,
    });


    $br_src1_gt_zero_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_gt_zero",
      insts => ["bgtz", "bgtzl"],
      allowed_modes => $allowed_modes,
    });


    $br_src1_ge_zero_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_src1_ge_zero",
      insts => ["bgez", "bgezal", "bgezl", "bgezall"],
      allowed_modes => $allowed_modes,
    });


    $br_likely_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_likely",
      insts => 
        ["beql","bnel","bgezall","bgezl","bgtzl","blezl","bltzall","bltzl"],
      allowed_modes => $allowed_modes,
    });


    $br_always_pred_taken_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_always_pred_taken",
      ctrls => ["br_likely"],
      allowed_modes => $allowed_modes,
    });





    $br_uncond_op_table_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_uncond_op_table",
      insts => ["beq"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return "& ${stage}_rs_is_zero & ${stage}_rt_is_zero";
        },
      c_expr_func => 
        sub {
            return "&& (GET_MIPS32_IW_RS(Iw) == 0)" .
              " && (GET_MIPS32_IW_RT(Iw) == 0)";
        },
      allowed_modes => $allowed_modes,
    });




    $br_uncond_regimm_table_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_uncond_regimm_table",
      insts => ["bgezal"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return "& ${stage}_rs_is_zero";
        },
      c_expr_func => 
        sub {
            return "&& (GET_MIPS32_IW_RS(Iw) == 0)";
        },
      allowed_modes => $allowed_modes,
    });




    $br_uncond_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_uncond",
      v_expr_func => 
        sub {
            my $stage = shift;
            return 
              "${stage}_ctrl_br_uncond_op_table" .
              " | ${stage}_ctrl_br_uncond_regimm_table";
        },
      c_expr_func => 
        sub {
            return 
              "MIPS32_IW_PROP_BR_UNCOND_OP_TABLE(Iw)" .
              " || MIPS32_IW_PROP_BR_UNCOND_REGIMM_TABLE(Iw)";
        },
      allowed_modes => $allowed_modes,
    });




    $br_cond_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_cond",
      v_expr_func => 
        sub {
            my $stage = shift;
            return "${stage}_ctrl_br & ~${stage}_ctrl_br_uncond";
        },
      c_expr_func => 
        sub {
            return "MIPS32_IW_PROP_BR(Iw) && !MIPS32_IW_PROP_BR_UNCOND(Iw)";
        },
      allowed_modes => $allowed_modes,
    });



    $br_op_table_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_op_table",
      insts => ["beq","bne","blez","bgtz",
                "beql","bnel","blezl","bgtzl"],
      allowed_modes => $allowed_modes,
    });



    $br_regimm_table_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br_regimm_table",
      insts => ["bltz","bgez","bltzl","bgezl",
                "bltzal","bgezal","bltzall","bgezall"],
      allowed_modes => $allowed_modes,
    });



    $br_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "br",
      v_expr_func => 
        sub {
            my $stage = shift;
            return "${stage}_ctrl_br_op_table | ${stage}_ctrl_br_regimm_table";
        },
      c_expr_func => 
        sub {
            return "MIPS32_IW_PROP_BR_OP_TABLE(Iw)" .
              " || MIPS32_IW_PROP_BR_REGIMM_TABLE(Iw)";
        },
      allowed_modes => $allowed_modes,
    });



    $has_delay_slot_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "has_delay_slot",
      ctrls => ["jmp"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return 
              "| ${stage}_ctrl_br_op_table | ${stage}_ctrl_br_regimm_table";
        },
      c_expr_func => 
        sub {
            return "|| MIPS32_IW_PROP_BR_OP_TABLE(Iw)" .
              " || MIPS32_IW_PROP_BR_REGIMM_TABLE(Iw)";
        },
      allowed_modes => $allowed_modes,
    });
}

sub
add_jump_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;







    $jmp_indirect_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp_indirect",
      insts => ["jr","jalr","special_rsv40","special_rsv41"],
      allowed_modes => $allowed_modes,
    });



    $jmp_direct_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp_direct",
      insts => ["j","jal"],
      allowed_modes => $allowed_modes,
    });


    $jmp_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "jmp",
      ctrls => ["jmp_direct", "jmp_indirect"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_load_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $ld8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld8",
      insts => ["lb","lbu"],
      allowed_modes => $allowed_modes,
    });


    $ld16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld16",
      insts => ["lh","lhu"],
      allowed_modes => $allowed_modes,
    });


    $ld8_ld16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld8_ld16",
      ctrls => ["ld8", "ld16"],
      allowed_modes => $allowed_modes,
    });


    $ld32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld32",
      insts => ["lw","ll"],
      allowed_modes => $allowed_modes,
    });


    $lwlr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "lwlr",
      insts => ["lwl","lwr"],
      allowed_modes => $allowed_modes,
    });


    $swlr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "swlr",
      insts => ["swl","swr"],
      allowed_modes => $allowed_modes,

    });


    $ld_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_signed",
      insts => ["lb","lh"],
      ctrls => ["ld32"],
      allowed_modes => $allowed_modes,
    });


    $ld_unsigned_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_unsigned",
      insts => ["lbu","lhu"],
      allowed_modes => $allowed_modes,
    });


    $ld_ctrl = add_inst_ctrl($inst_ctrls, { 
      name => "ld",
      insts => ["lwl","lwr"],
      ctrls => ["ld_signed","ld_unsigned"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_store_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $st8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st8",
      insts => ["sb"],
      allowed_modes => $allowed_modes,
    });


    $st16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st16",
      insts => ["sh"],
      allowed_modes => $allowed_modes,
    });


    $st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st32",
      insts => ["sw","sc"],
      allowed_modes => $allowed_modes,
    });


    $st_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st",
      insts => ["sb","sh","sw","sc","swl","swr"],
      allowed_modes => $allowed_modes,
    });


    $sc_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "sc",
      insts => ["sc"],
      allowed_modes => $allowed_modes,
    });

}

sub
add_mem_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;

    $ld_st_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st",
      ctrls => ["ld","st"],
      allowed_modes => $allowed_modes,
    });

    $ld_st_non_st32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_st_non_st32",
      ctrls => ["ld","st8","st16"],
      allowed_modes => $allowed_modes,
    });


    $mem8_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem8",
      ctrls => ["ld8","st8"],
      allowed_modes => $allowed_modes,
    });


    $mem16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem16",
      ctrls => ["ld16","st16"],
      allowed_modes => $allowed_modes,
    });


    $mem32_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem32",
      ctrls => ["ld32","st32"],
      allowed_modes => $allowed_modes,
    });


    $mem_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem",
      ctrls => ["ld","st","dcache_management"],
      allowed_modes => $allowed_modes,
    });





    $ld_addr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_addr",
      insts => ["synci"],
      ctrls => ["ld"],
      allowed_modes => $allowed_modes,
    });





    $ld_data_access_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ld_data_access",
      ctrls => ["ld_addr"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return " | ${stage}_is_cache_inst"; # OP table
        },
      c_expr_func => 
        sub {
            return " || MIPS32_IS_CACHE_INST(Iw)";
        },
      allowed_modes => $allowed_modes,
    });



    $st_data_access_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "st_data_access",
      ctrls => ["st"],
      allowed_modes => $allowed_modes,
    });



    $mem_data_access_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "mem_data_access",
      ctrls => ["ld_data_access","st_data_access"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return " | ${stage}_is_cache_inst"; # OP table
        },
      c_expr_func => 
        sub {
            return " || MIPS32_IS_CACHE_INST(Iw)";
        },
      allowed_modes => $allowed_modes,
    });
}

sub
add_dcache_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $dcache_management_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dcache_management",
      insts => ["dcache_idx_wb_inv","dcache_st_tag","dcache_hit_nowb_inv",
                "dcache_hit_wb_inv","dcache_hit_wb","synci"],
      allowed_modes => $allowed_modes,
    });


    $cache_management_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "cache_management",
      insts => ["dcache_idx_wb_inv","dcache_st_tag","dcache_hit_nowb_inv",
                "dcache_hit_wb_inv","dcache_hit_wb","synci","icache_hit_inv",
                "icache_ld_tag","icache_idx_inv","icache_st_tag"],
      allowed_modes => $allowed_modes,
    });



    $dc_index_wb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_wb_inv",
      insts => ["dcache_idx_wb_inv"],
      allowed_modes => $allowed_modes,
    });


    $dc_index_store_tag_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_store_tag",
      insts => ["dcache_st_tag"],
      allowed_modes => $allowed_modes,
    });


    $dc_addr_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_nowb_inv",
      insts => ["dcache_hit_nowb_inv"],
      allowed_modes => $allowed_modes,
    });


    $dc_addr_wb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_wb_inv",
      insts => ["dcache_hit_wb_inv","dcache_hit_wb","synci"],
      allowed_modes => $allowed_modes,
    });



    $dc_index_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_nowb_inv",
      allowed_modes => $allowed_modes,
    });


    $dc_index_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_index_inv",
      ctrls => ["dc_index_nowb_inv","dc_index_wb_inv"],
      allowed_modes => $allowed_modes,
    });


    $dc_addr_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_addr_inv",
      insts => ["synci"],
      ctrls => ["dc_addr_nowb_inv","dc_addr_wb_inv"],
      allowed_modes => $allowed_modes,
    });


    $dc_nowb_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "dc_nowb_inv",
      ctrls => ["dc_index_nowb_inv","dc_addr_nowb_inv"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_icache_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $ic_index_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_index_inv",
      insts => ["icache_idx_inv"],
      allowed_modes => $allowed_modes,
    });


    $ic_addr_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_addr_inv",
      insts => ["icache_hit_inv"],
      allowed_modes => $allowed_modes,
    });

    $ic_only_read_tag_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_only_read_tag",
      insts => ["icache_hit_inv","icache_ld_tag","icache_idx_inv","icache_st_tag"],
      allowed_modes => $allowed_modes,
    });


    $ic_hit_inv_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_hit_inv",
      insts => ["icache_hit_inv","synci"],
      allowed_modes => $allowed_modes,
    });


    $ic_tag_wdata_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_tag_wdata",
      insts => ["icache_hit_inv","synci","icache_idx_inv"],
      allowed_modes => $allowed_modes,
    });


    $ic_tag_wr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_tag_wr",
      insts => ["icache_st_tag","icache_idx_inv"],
      allowed_modes => $allowed_modes,
    });



    $ic_tag_rd_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ic_tag_rd",
      insts => ["icache_ld_tag","icache_hit_inv","synci","icache_idx_inv","icache_st_tag"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_trap_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $trap_src1_eq_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_src1_eq_src2",
      insts => ["teqi","teq"],
      allowed_modes => $allowed_modes,
    });


    $trap_src1_ne_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_src1_ne_src2",
      insts => ["tnei","tne"],
      allowed_modes => $allowed_modes,
    });


    $trap_src1_lt_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_src1_lt_src2",
      insts => ["tlti","tltiu","tlt","tltu"],
      allowed_modes => $allowed_modes,
    });


    $trap_src1_ge_src2_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_src1_ge_src2",
      insts => ["tgei","tgeiu","tge","tgeu"],
      allowed_modes => $allowed_modes,
    });


    $trap_alu_signed_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_alu_signed",
      insts => ["tlt","tlti","tge","tgei"],
      allowed_modes => $allowed_modes,
    });


    $trap_reg_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_reg_imm16",
      insts => ["tgei","tgeiu","tlti","tltiu","teqi","tnei"],
      allowed_modes => $allowed_modes,
    });


    $trap_reg_reg_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap_reg_reg",
      insts => ["tge","tgeu","tlt","tltu","teq","tne"],
      allowed_modes => $allowed_modes,
    });


    $trap_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "trap",
      ctrls => ["trap_reg_imm16","trap_reg_reg"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_src_operands_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $hi_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "hi_imm16",
      ctrls => ["logic_hi_imm16"],
      allowed_modes => $allowed_modes,
    });



    $unsigned_lo_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "unsigned_lo_imm16",
      ctrls => ["logic_lo_imm16"],
      allowed_modes => $allowed_modes,
    });













    $rs_not_src_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rs_not_src",
      ctrls => ["jmp_direct"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return " | ${stage}_is_cop0_inst";
        },
      c_expr_func => 
        sub {
            return " || MIPS32_IS_COP0_INST(Iw)";
        },
      allowed_modes => $allowed_modes,
    });























    $rt_is_src_or_slow_dst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rt_is_src_or_slow_dst",
      insts => ["beq","bne","beql","bnel"],
      ctrls => ["st","lwlr"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return 
              " | ${stage}_is_special_inst | ${stage}_is_special2_inst" .
              " | ${stage}_is_special3_inst | ${stage}_is_cop0_inst";
        },
      c_expr_func => 
        sub {
            return 
              " || MIPS32_IS_SPECIAL_INST(Iw) || MIPS32_IS_SPECIAL2_INST(Iw)" .
              " || MIPS32_IS_SPECIAL3_INST(Iw) || MIPS32_IS_COP0_INST(Iw)";
                              
        },
      allowed_modes => $allowed_modes,
    });





    $src2_choose_imm16_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "src2_choose_imm16",
      insts => [
        "pref"                                              # OP table
      ],
      ctrls => [
        "arith_imm16","logic_imm16","cmp_imm16","ld","st",  # OP table SPECIAL table
      ],
      v_expr_func => 
        sub {
            my $stage = shift;
            return " | ${stage}_is_regimm_inst | ${stage}_is_cache_inst";
        },
      c_expr_func => 
        sub {
            return " || MIPS32_IS_REGIMM_INST(Iw) || MIPS32_IS_CACHE_INST(Iw)";
        },
      allowed_modes => $allowed_modes,
    });
}

sub
add_dst_operand_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;









    $sel_rd_for_dst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "sel_rd_for_dst",
      insts => ["rdpgpr","wrpgpr"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return 
              " | ${stage}_is_special_or_special2_inst" .
              " | ${stage}_is_bshfl_inst";
        },
      c_expr_func => 
        sub {
            return 
              " || MIPS32_IS_SPECIAL_INST(Iw)" .
              " || MIPS32_IS_SPECIAL2_INST(Iw)" .
              " || MIPS32_IS_BSHFL_INST(Iw)";
                              
        },
      allowed_modes => $allowed_modes,
    });



    $implicit_dst_retaddr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "implicit_dst_retaddr",
      insts => ["jal","bgezal","bgezall","bltzal","bltzall"],
      allowed_modes => $allowed_modes,
    });





    $ignore_dst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ignore_dst",
      insts => [
        "j","pref",                             # OP table
        "syscall","break",                      # SPECIAL table
        "bltz","bgez","bltzl","bgezl","synci",  # REGIMM table
        "sdbbp",                                # SPECIAL2 table
        "mtc0",                                 # COP0 table
        "wait",                                 # C0 table
        "sb","sh","sw","swl","swr",             # all stores except for sc
      ],     
      ctrls => [
        "br_op_table",                          # OP table
        "trap_reg_reg",                         # SPECIAL table
        "trap_reg_imm16",                       # REGIMM table
      ],
      v_expr_func => 
        sub {
            my $stage = shift;
            return " | ${stage}_is_cache_inst"; # OP table
        },
      c_expr_func => 
        sub {
            return " || MIPS32_IS_CACHE_INST(Iw)";
        },
      allowed_modes => $allowed_modes,
    });
}

sub
add_cop0_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $wrctl_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "wrctl_inst",
      insts => ["mtc0"],
      allowed_modes => $allowed_modes,
    });


    $rdctl_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "rdctl_inst",
      insts => ["mfc0", "di", "ei"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_tlb_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;


    $tlb_wr_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "tlb_wr_inst",
      insts => ["tlbwr", "tlbwi"],
      allowed_modes => $allowed_modes,
    });


    $tlb_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "tlb_inst",
      insts => ["tlbp", "tlbr"],
      ctrls => ["tlb_wr_inst"],
      allowed_modes => $allowed_modes,
    });
}

sub
add_c_model_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;



    return $inst_ctrls;
}

sub
add_misc_inst_ctrls
{
    my $inst_ctrls = shift;
    my $allowed_modes = shift;
    my $inst_descs = shift;


    $reserved_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "reserved",
      insts => get_inst_desc_names_by_modes($inst_descs, 
        [$INST_DESC_RESERVED_MODE]),
      allowed_modes => [$INST_DESC_RESERVED_MODE],
    });



    $cop0_ctrl = add_inst_ctrl($inst_ctrls, { 
      name  => "cop0",
      v_expr_func => 
        sub {
            my $stage = shift;
            return "${stage}_is_cop0_inst | ${stage}_is_cache_inst";
        },
      c_expr_func => 
        sub {
            return "MIPS32_IS_COP0_INST(Iw) || MIPS32_IS_CACHE_INST(Iw)";
        },
      allowed_modes => $allowed_modes, 
    });




    $cop1_or_cop1x_ctrl = add_inst_ctrl($inst_ctrls, { 
      name  => "cop1_or_cop1x",
      insts => ["movci", "lwc1", "ldc1", "swc1", "sdc1"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return "| ${stage}_is_cop1_or_cop1x_inst";
        },
      c_expr_func => 
        sub {
            return "|| MIPS32_IS_COP1_OR_COP1X_INST(Iw)";
        },
      allowed_modes => $allowed_modes, 
    });



    $cop2_ctrl = add_inst_ctrl($inst_ctrls, { 
      name  => "cop2",
      insts => ["lwc2", "ldc2", "swc2", "sdc2"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return "| ${stage}_is_cop2_inst";
        },
      c_expr_func => 
        sub {
            return "|| MIPS32_IS_COP2_INST(Iw)";
        },
      allowed_modes => $allowed_modes, 
    });






    $flush_pipe_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "flush_pipe",
      insts => ["deret","eret"],
      allowed_modes => $allowed_modes,
    });


    $retaddr_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "retaddr",
      insts => ["jalr"],
      ctrls => ["implicit_dst_retaddr"],
      allowed_modes => $allowed_modes,
    });


    $ehb_inst_ctrl = add_inst_ctrl($inst_ctrls, {
      name => "ehb_inst",
      insts => ["sll"],
      v_expr_func => 
        sub {
            my $stage = shift;
            return 
              " & ${stage}_rt_is_zero" .
              " & ${stage}_rd_is_zero" .
              " & (${stage}_iw_sa == 3)";
        },
      c_expr_func => 
        sub {
            return 
              " && (GET_MIPS32_IW_RT(Iw) == 0)" .
              " && (GET_MIPS32_IW_RD(Iw) == 0)" .
              " && (GET_MIPS32_IW_SA(Iw) == 3)";
                              
        },
      allowed_modes => $allowed_modes,
    });
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
        if (!defined(convert_inst_field_to_c($inst_field, $c_lines, $h_lines, 
          "MIPS32_"))) {
            return undef;
        }
    }

    return 1;   # Some defined value
}

sub
convert_inst_tables_to_c
{
    my $inst_tables = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    foreach my $inst_table (@$inst_tables) {
        convert_inst_table_to_c($inst_tables, $inst_table, $global_prefix,
          $c_lines, $h_lines) || return undef;
    }

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
    format_hash_as_c_macros($inst_constants, $h_lines, $global_prefix);

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
        my $define_prefix = "#define MIPS32_IW_PROP_${ctrl_name_uc}(Iw) ";



        my $c_expr_func = get_inst_ctrl_c_expr_func($inst_ctrl);
        my $extra_expr = "";
        if (defined($c_expr_func)) {
            $extra_expr = &$c_expr_func();
        }

        my $num_filtered_inst_descs = scalar(@$filtered_inst_descs);



        if ($num_filtered_inst_descs == 0) {
            push(@$h_lines, $define_prefix . 
              (($extra_expr eq "") ? "(0)" : "($extra_expr)"));
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



            my $inst_tables = [];
            foreach my $inst_desc (@$filtered_inst_descs) {
                my $inst_table = get_inst_desc_inst_table($inst_desc);
                validate_inst_table($inst_table) || return undef;

                my $already_exists = 0;
                foreach my $existing_inst_table (@$inst_tables) {
                    if ($existing_inst_table == $inst_table) {
                        $already_exists = 1;
                    }
                }

                if (!$already_exists) {
                    push(@$inst_tables, $inst_table);
                }
            }


            my @lookup_exprs;
            foreach my $inst_table (@$inst_tables) {
                my $table_name = get_inst_table_name($inst_table);
                my $table_name_uc = uc($table_name);
                my $inst_field = get_inst_table_inst_field($inst_table);
                my $inst_field_name = get_inst_field_name($inst_field);
                my $inst_field_name_uc = uc($inst_field_name);

                my $lookup_expr =
                  "${global_prefix}${table_name}_prop_${ctrl_name_lc}" .
                  "\[GET_MIPS32_IW_${inst_field_name_uc}(Iw)]";

                if (get_inst_table_parent_table($inst_table)) {
                    $lookup_expr = 
                      "($lookup_expr && MIPS32_IS_${table_name_uc}_INST(Iw))";
                }

                if ($extra_expr ne "") {
                    $lookup_expr = "($lookup_expr $extra_expr)";
                }

                push(@lookup_exprs, $lookup_expr);
            }
            push(@$h_lines, $define_prefix . "\\");
            push(@$h_lines, "  (" . join('||', @lookup_exprs) . ")");


            push(@$c_lines,
              "",
              "/* Table(s) for MIPS32_IW_PROP_${ctrl_name_uc} macro */");;

            foreach my $inst_table (@$inst_tables) {
                my $table_name = get_inst_table_name($inst_table);
                my $opcodes = get_inst_table_opcodes($inst_table);
                my $num_opcodes = scalar(@$opcodes);
                push(@$c_lines,
                  "unsigned char",
                  "${global_prefix}${table_name}_prop_" .
                    "${ctrl_name_lc}\[$num_opcodes] = {");

                for (my $code = 0; $code < $num_opcodes; $code++) {
                    my $opcode = $opcodes->[$code];
                    my $opcode_type = get_inst_table_opcode_type($opcode);
                    my $after_number = ($code == ($num_opcodes-1)) ? " " : ",";

                    my $on_list = 0;


                    if ($opcode_type == $OPCODE_TYPE_INST_NAME) {

                        $on_list = get_inst_desc_by_name_or_undef(
                          $filtered_inst_descs, $opcode);
                    }

                    if ($on_list) {
                        push(@$c_lines, sprintf("    1%s /* %s */", 
                          $after_number, $opcode));
                    } else {
                        push(@$c_lines, sprintf("    0%s", $after_number));
                    }
                }

                push(@$c_lines, "};");


                push(@$h_lines,
                  "",
                  "#ifndef ALT_ASM_SRC",
                  "extern unsigned char" .
                    " ${global_prefix}${table_name}_prop_" .
                    "${ctrl_name_lc}\[$num_opcodes];",
                  "#endif /* ALT_ASM_SRC */");
            }
        }

        push(@$h_lines, "");
    }

    return 1;   # Some defined value
}






sub
create_c_inst_info
{
    my $inst_descs = shift;
    my $inst_tables = shift;
    my $c_lines = shift;
    my $h_lines = shift;

    push(@$h_lines,
      "",
      "/* Instruction types */",
    );

    foreach my $inst_type (@INST_TYPES) {
        my $inst_type_name = not_empty_scalar($inst_type, "name");
        my $inst_type_value = manditory_int($inst_type, "value");
        push(@$h_lines, "#define MIPS32_${inst_type_name} $inst_type_value");
    }

    push(@$h_lines,
      "",
      "/* Canonical instruction codes independent of encoding */"
    );

    push(@$c_lines,
      "",
      "/* Instruction information array (indexed by instruction code) */",
      "Mips32InstInfo mips32InstInfo[] = {");

    my $num_inst_info_entries = 0;
    my $first_reserved_inst_desc;

    foreach my $inst_desc (@$inst_descs) {
        my $mode = get_inst_desc_mode($inst_desc);

        if ($mode == $INST_DESC_RESERVED_MODE) {
            if (!defined($first_reserved_inst_desc)) {
                $first_reserved_inst_desc = $inst_desc;
            }
            next;
        }

        my $inst_code = get_inst_desc_code($inst_desc);
        my $inst_type = get_inst_desc_inst_type($inst_desc);
        my $inst_name = get_inst_desc_name($inst_desc);
        my $inst_name_uc = uc($inst_name);

        if (!defined($inst_type)) {
            &$error("Missing inst_type for instruction '$inst_name'");
        }

        my $inst_type_name = find_inst_type_name($inst_type);

        push(@$c_lines, sprintf("    { \"%s\", MIPS32_%s, %d },", 
          $inst_name, $inst_type_name, $inst_code));
        push(@$h_lines, 
          sprintf("#define MIPS32_%s_INST_CODE %d", $inst_name_uc,
            $num_inst_info_entries));

        $num_inst_info_entries++;
    }


    if (!defined($first_reserved_inst_desc)) {
        &$error("Couldn't find any reserved instructions");
    }



    push(@$h_lines, "#define MIPS32_RSV_INST_CODE $num_inst_info_entries");
    push(@$c_lines, 
      sprintf("    { \"%s\", MIPS32_%s, %d }", 
        "rsv", 
        find_inst_type_name(get_inst_desc_inst_type($first_reserved_inst_desc)),
        get_inst_desc_code($first_reserved_inst_desc)),
      "};"
    );
    $num_inst_info_entries++;

    push(@$h_lines, 
      "#define NUM_MIPS32_INST_CODES $num_inst_info_entries",
      "",
      "#ifndef ALT_ASM_SRC",
      "/* Instruction information entry */",
      "typedef struct {",
      "  const char* name;     /* Assembly-language instruction name */",
      "  int         instType; /* MIPS32_INST_TYPE_* */",
      "  unsigned    opcode;   /* Value of field used to index into table */",
      "} Mips32InstInfo;",
      "",
      "extern Mips32InstInfo mips32InstInfo[NUM_MIPS32_INST_CODES];",
      "",
      "/* Returns the instruction code given the 32-bit instruction word */",
      "#define GET_MIPS32_INST_CODE(Iw) (get_mips32_inst_code(Iw))",
      "",
      "extern int get_mips32_inst_code(unsigned int iw);",
      "#endif /* ALT_ASM_SRC */"
    );

    push(@$c_lines,
      "",
      "/* Returns the instruction code given the 32-bit instruction word */",
      "int",
      "get_mips32_inst_code(unsigned int iw)",
      "{",
    );

    create_c_inst_info_for_inst_table($inst_tables, $op_inst_table,
      "    ", $c_lines, $h_lines);
    push(@$c_lines,
      "}",
    );

    foreach my $inst_table (@$inst_tables) {
        my $table_name = get_inst_table_name($inst_table);
        my $table_name_uc = uc($table_name);
        my $opcodes = get_inst_table_opcodes($inst_table);
        my $inst_field = get_inst_table_inst_field($inst_table);
        my $inst_field_name_uc = uc(get_inst_field_name($inst_field));

        my $num_opcodes = scalar(@$opcodes);
        
        push(@$c_lines,
          "",
          "/* Used by GET_MIPS32_INST_CODE() to map $table_name_uc" .
            " instructions to instruction code */",
          "int ${global_prefix}${table_name}_to_inst_code[$num_opcodes] = {",
        );

        for (my $code=0; $code < scalar(@$opcodes); $code++) {
            my $opcode = $opcodes->[$code];
            my $opcode_type = get_inst_table_opcode_type($opcode);
            my $last = ($code == (scalar(@$opcodes) - 1));
            my $term = ($last ? "" : ",");

            if ($opcode_type == $OPCODE_TYPE_INST_NAME) {
                my $inst_name_uc = uc($opcode);

                push(@$c_lines,
                  "  MIPS32_" . $inst_name_uc . "_INST_CODE" . $term
                );
            } elsif (
              ($opcode_type == $OPCODE_TYPE_RESERVED_NUM) ||
              ($opcode_type == $OPCODE_TYPE_CHILD_TABLE_NAME)) {
                my $inst_name_uc = uc($opcode);

                push(@$c_lines,
                  "  MIPS32_RSV_INST_CODE" . $term
                );
            } else {
                &$error(
                  "Unknown opcode_type of '$opcode_type' for opcode '$opcode'");
            }
        }

        push(@$c_lines,
          "};"
        );

        push(@$h_lines,
          "",
          "#ifndef ALT_ASM_SRC",
          "extern int ${global_prefix}${table_name}" .
            "_to_inst_code[$num_opcodes];",
          "#endif /* ALT_ASM_SRC */"
        );
    }

    return 1;   # Some defined value
}



sub
create_c_inst_info_for_inst_table
{
    my $inst_tables = shift;
    my $inst_table = shift;
    my $indent = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    my $table_name = get_inst_table_name($inst_table);
    my $table_name_uc = uc($table_name);
    my $inst_field = get_inst_table_inst_field($inst_table);
    my $inst_field_name_uc = uc(get_inst_field_name($inst_field));

    my $child_table_infos = 
      get_inst_table_child_table_infos($inst_tables, $inst_table);
    my $num_children = scalar(@$child_table_infos);

    for (my $child_index = 0; $child_index < $num_children; $child_index++) {
        my $child_table_info = $child_table_infos->[$child_index];
        my $child_table = manditory_hash($child_table_info, "child_table");
        my $child_table_name = get_inst_table_name($child_table);
        my $child_table_name_uc = uc($child_table_name);
        my $last_child = ($child_index == ($num_children -1 ));

        push(@$c_lines,
          "${indent}if (MIPS32_IS_${child_table_name_uc}_INST(iw)) {");


        create_c_inst_info_for_inst_table($inst_tables, $child_table,
          $indent . "    ", $c_lines, $c_lines);

        push(@$c_lines,
          "${indent}}");
    }

    push(@$c_lines,
      "${indent}return ${global_prefix}${table_name}" .
        "_to_inst_code[GET_MIPS32_IW_${inst_field_name_uc}(iw)];");
}

sub
find_inst_type_name
{
    my $desired_inst_type = shift;

    foreach my $inst_type (@INST_TYPES) {
        my $inst_type_name = not_empty_scalar($inst_type, "name");
        my $inst_type_value = manditory_int($inst_type, "value");

        if ($inst_type_value == $desired_inst_type) {
            return $inst_type_name;
        }
    }

    &$error("Can't convert inst_type '$desired_inst_type' to a name");
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nevada_insts.pm: eval($cmd) returns '$@'\n");
    }
}

1;
