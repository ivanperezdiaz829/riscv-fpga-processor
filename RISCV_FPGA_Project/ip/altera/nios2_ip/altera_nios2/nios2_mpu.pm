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


























package nios2_mpu;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $mpu_use_limit
    $mpu_inst_perm_sz $mpu_data_perm_sz
    $mpu_inst_perm_super_none_user_none
    $mpu_inst_perm_super_exec_user_none
    $mpu_inst_perm_super_exec_user_exec
    $mpu_data_perm_super_none_user_none
    $mpu_data_perm_super_rd_user_none
    $mpu_data_perm_super_rd_user_rd
    $mpu_data_perm_super_rw_user_none
    $mpu_data_perm_super_rw_user_rd
    $mpu_data_perm_super_rw_user_rw
    $mpu_min_regions $mpu_max_regions
    $mpu_min_region_size_log2 $mpu_max_region_size_log2
);

use cpu_utils;
use nios2_control_regs;
use strict;






our $mpu_use_limit;
our $mpu_inst_perm_sz;
our $mpu_data_perm_sz;
our $mpu_inst_perm_super_none_user_none;
our $mpu_inst_perm_super_exec_user_none;
our $mpu_inst_perm_super_exec_user_exec;
our $mpu_data_perm_super_none_user_none;
our $mpu_data_perm_super_rd_user_none;
our $mpu_data_perm_super_rd_user_rd;
our $mpu_data_perm_super_rw_user_none;
our $mpu_data_perm_super_rw_user_rd;
our $mpu_data_perm_super_rw_user_rw;
our $mpu_min_regions;
our $mpu_max_regions;
our $mpu_min_region_size_log2;
our $mpu_max_region_size_log2;







sub
create_mpu_args_from_infos
{
    my $mpu_info = shift;
    my $elaborated_avalon_master_info = shift;

    if (!manditory_bool($mpu_info, "mpu_present")) {
        &$error("Shouldn't be called if MPU isn't present");
    }

    my $mpu_args = {
      mpu_use_limit => manditory_bool($mpu_info, "mpu_use_limit"),

      mpu_min_inst_region_size_log2 => 
        manditory_int($mpu_info, "mpu_min_inst_region_size_log2"),
      mpu_min_data_region_size_log2 => 
        manditory_int($mpu_info, "mpu_min_data_region_size_log2"),
      mpu_num_inst_regions => 
        manditory_int($mpu_info, "mpu_num_inst_regions"),
      mpu_num_data_regions => 
        manditory_int($mpu_info, "mpu_num_data_regions"),

      i_Address_Width => 
        manditory_int($elaborated_avalon_master_info, "i_Address_Width"),
      d_Address_Width => 
        manditory_int($elaborated_avalon_master_info, "d_Address_Width"),
    };

    return $mpu_args;
}





sub
create_mpu_args_max_configuration
{
    my $mpu_args = {
      mpu_use_limit => 1,

      mpu_min_inst_region_size_log2 => 6,
      mpu_min_data_region_size_log2 => 6,
      mpu_num_inst_regions => 32,
      mpu_num_data_regions => 32,

      i_Address_Width => 32,
      d_Address_Width => 32,
    };

    return $mpu_args;
}




sub
validate_and_elaborate
{
    my $mpu_args = shift; # Hash reference containing all args

    my $mpu_constants = create_mpu_constants($mpu_args);


    my $elaborated_mpu_info = {
        mpu_constants => $mpu_constants,
    };



    foreach my $var (keys(%$mpu_constants)) {
        eval_cmd('$' . $var . ' = "' . $mpu_constants->{$var} . '"');
    }


    $elaborated_mpu_info->{impu_region_base_sz} = 
      $mpu_args->{i_Address_Width} - 
      $mpu_args->{mpu_min_inst_region_size_log2};
    $elaborated_mpu_info->{dmpu_region_base_sz} = 
      $mpu_args->{d_Address_Width} - 
      $mpu_args->{mpu_min_data_region_size_log2};


    $elaborated_mpu_info->{impu_region_index_sz} = 
      count2sz($mpu_args->{mpu_num_inst_regions});
    $elaborated_mpu_info->{dmpu_region_index_sz} = 
      count2sz($mpu_args->{mpu_num_data_regions});

    return $elaborated_mpu_info;
}


sub
convert_to_c
{
    my $elaborated_mpu_info = shift;
    my $c_lines = shift;        # Reference to array of lines for *.c file
    my $h_lines = shift;        # Reference to array of lines for *.h file

    push(@$h_lines, "");
    push(@$h_lines, "/* MPU Constants */");
    format_hash_as_c_macros($elaborated_mpu_info->{mpu_constants}, $h_lines);

    add_handy_macros($h_lines);

    return 1;   # Some defined value
}



sub 
make_mpu_regions
{
    my ($Opt, $d) = @_;

    if (!defined($mpu_use_limit)) {
        return &$error("MPU config constants haven't been initialized yet.");
    }

    my $whoami = $d ? "DMPU" : "IMPU";
    my $wss = not_empty_scalar($Opt, "wrctl_setup_stage");
    my $cs = not_empty_scalar($Opt, "control_reg_stage");


    my $M                   = $d ? "DMPU"                   : "IMPU";
    my $m                   = $d ? "dmpu"                   : "impu";
    my $r                   = $d ? "dmpu_region"            : "impu_region";
    my $match_cmp_stage     = $d ? "E"                      : "F";
    my $match_cmp_addr      = $d ? "E_mem_baddr_for_dmpu"   : "F_pc";
    my $mpu_match_cmp_addr  = $d ? "E_mem_baddr_dmpu"       : "F_pc_impu";
    my $match_mux_stage     = $d ? "M"                      : "F";

    my $ri;     # region index


    my $num_regions = $d ? 
      manditory_int($Opt, "mpu_num_data_regions") : 
      manditory_int($Opt, "mpu_num_inst_regions");
    my $min_region_size_log2 = $d ? 
      manditory_int($Opt, "mpu_min_data_region_size_log2") :
      manditory_int($Opt, "mpu_min_inst_region_size_log2");


    my $region_base_sz =  $d ? 
      manditory_int($Opt, "dmpu_region_base_sz") :
      manditory_int($Opt, "impu_region_base_sz");
    my $region_index_sz = $d ? 
      manditory_int($Opt, "dmpu_region_index_sz") :
      manditory_int($Opt, "impu_region_index_sz");
    my $region_perm_sz =  $d ? $mpu_data_perm_sz : $mpu_inst_perm_sz;
    my $region_mask_sz = $region_base_sz;
    my $region_limit_sz = $region_base_sz + 1;


    my $base_ctrl_sz = $region_base_sz;
    my $base_ctrl_lsb = $min_region_size_log2 - $mpubase_reg_base_lsb;
    my $base_ctrl_msb = $base_ctrl_lsb + $base_ctrl_sz - 1;

    my $index_ctrl_sz = $region_index_sz;
    my $index_ctrl_lsb = 0;
    my $index_ctrl_msb = $index_ctrl_lsb + $index_ctrl_sz - 1;

    my $mask_ctrl_sz = $region_mask_sz;
    my $mask_ctrl_lsb = $min_region_size_log2 - $mpuacc_reg_mask_lsb;
    my $mask_ctrl_msb = $mask_ctrl_lsb + $mask_ctrl_sz - 1;

    my $limit_ctrl_sz = $region_limit_sz;
    my $limit_ctrl_lsb = $min_region_size_log2 - $mpuacc_reg_limit_lsb;
    my $limit_ctrl_msb = $limit_ctrl_lsb + $limit_ctrl_sz - 1;

    my $perm_ctrl_sz = $region_perm_sz;
    my $perm_ctrl_lsb = 0;
    my $perm_ctrl_msb = $perm_ctrl_lsb + $perm_ctrl_sz - 1;




    my $addr_lsb = $d ? 
      ($min_region_size_log2) :
      ($min_region_size_log2 - 2);
    my $addr_msb = $d ? 
      (manditory_int($Opt, "d_Address_Width") - 1):
      (manditory_int($Opt, "i_Address_Width") - 3);
    my $addr_sz = $addr_msb - $addr_lsb + 1;





    my @rd_base_mux;
    my @rd_mask_mux;
    my @rd_limit_mux;
    my @rd_c_mux;
    my @rd_perm_mux;

    my @region_wave_signals = (
      { divider => "$M Regions" },
    );


    for ($ri = 0; $ri < $num_regions; $ri++) {
        my $rn = $r . $ri;      # Region name used as a prefix

        e_assign->adds(

          [["${rn}_wr_en", 1],
            "${cs}_${m}_wr_operation & " .
            "(${cs}_mpubase_reg_index[$index_ctrl_msb:$index_ctrl_lsb]
              == $ri)"],
        );

        e_register->adds(
          {out => ["${rn}_base", $region_base_sz], 
           in => "${cs}_mpubase_reg_base[$base_ctrl_msb:$base_ctrl_lsb]",
           enable => "${rn}_wr_en"},
          ($mpu_use_limit ? 
              {out => ["${rn}_limit", $region_limit_sz], 
               in => "${cs}_mpuacc_reg_limit[$limit_ctrl_msb:$limit_ctrl_lsb]",
               enable => "${rn}_wr_en"} :
              {out => ["${rn}_mask", $region_mask_sz], 
               in => "${cs}_mpuacc_reg_mask[$mask_ctrl_msb:$mask_ctrl_lsb]",
               enable => "${rn}_wr_en"}),
          $d ? {out => ["${rn}_c", 1],                  
               in => "${cs}_mpuacc_reg_c",
               enable => "${rn}_wr_en"} : (),
          {out => ["${rn}_perm", $region_perm_sz], 
           in => "${cs}_mpuacc_reg_perm[$perm_ctrl_msb:$perm_ctrl_lsb]",
           enable => "${rn}_wr_en"},
        );

        push(@rd_base_mux, $ri => "${rn}_base");
        push(@rd_mask_mux, $ri => "${rn}_mask");
        push(@rd_limit_mux, $ri => "${rn}_limit");
        push(@rd_c_mux, $ri => "${rn}_c");
        push(@rd_perm_mux, $ri => "${rn}_perm");

        push(@region_wave_signals,
          { radix => "x", signal => "${rn}_base" },
          ($mpu_use_limit ?
            { radix => "x", signal => "${rn}_limit" } :
            { radix => "x", signal => "${rn}_mask" }),
          $d ? { radix => "x", signal => "${rn}_c" } : "",
          { radix => "x", signal => "${rn}_perm" },
          { radix => "x", signal => "${rn}_wr_en" },
        );
    }

    my @region_read_wave_signals = (
      { divider => "$M Read" },
      { radix => "x", signal => "${cs}_mpubase_reg_index" },
      { radix => "x", signal => "${m}_rd_base" },
    );


    e_mux->add({
      lhs => ["${m}_rd_base_unpadded", $region_base_sz],
      selecto => "${cs}_mpubase_reg_index",
      table => \@rd_base_mux,
    });
    e_assign->adds(
      [["${m}_rd_base", $mpubase_reg_base_sz],
        ($base_ctrl_lsb > 0) ?
          "{ ${m}_rd_base_unpadded, ${base_ctrl_lsb}'b0 }" :
          "${m}_rd_base_unpadded "],
    );

    if ($mpu_use_limit) {
        e_mux->add({
          lhs => ["${m}_rd_limit_unpadded", $region_limit_sz],
          selecto => "${cs}_mpubase_reg_index",
          table => \@rd_limit_mux,
        });
        e_assign->adds(
          [["${m}_rd_limit", $mpuacc_reg_limit_sz],
            ($limit_ctrl_lsb > 0) ?
              "{ ${m}_rd_limit_unpadded, ${limit_ctrl_lsb}'b0 }" :
              "${m}_rd_limit_unpadded "],
        );
        push(@region_read_wave_signals,
          { radix => "x", signal => "${m}_rd_limit" },
        );
    } else {
        e_mux->add({
          lhs => ["${m}_rd_mask_unpadded", $region_mask_sz],
          selecto => "${cs}_mpubase_reg_index",
          table => \@rd_mask_mux,
        });
        e_assign->adds(
          [["${m}_rd_mask", $mpuacc_reg_mask_sz],
            ($mask_ctrl_lsb > 0) ?
              "{ ${m}_rd_mask_unpadded, ${mask_ctrl_lsb}'b0 }" :
              "${m}_rd_mask_unpadded "],
        );
        push(@region_read_wave_signals,
          { radix => "x", signal => "${m}_rd_mask" },
        );
    }
    if ($d) {
        e_mux->add({
          lhs => ["${m}_rd_c", 1],
          selecto => "${cs}_mpubase_reg_index",
          table => \@rd_c_mux,
        });
        push(@region_read_wave_signals,
          { radix => "x", signal => "${m}_rd_c" },
        );
    }
    e_mux->add({
      lhs => ["${m}_rd_perm", $region_perm_sz],
      selecto => "${cs}_mpubase_reg_index",
      table => \@rd_perm_mux,
    });
    push(@region_read_wave_signals,
      { radix => "x", signal => "${m}_rd_perm" },
    );





    my @region_match_mux_signals;
    my @region_match_wave_signals;
    my @region_c_mux_table;
    my @region_perm_mux_table;

    e_assign->adds(

      [[$mpu_match_cmp_addr, $addr_sz], 
        "${match_cmp_addr}[$addr_msb:$addr_lsb]"],
    );

    for ($ri = 0; $ri < $num_regions; $ri++) {
        my $rn = $r . $ri;      # Region name used as a prefix

        my $match_cmp_signal = "${match_cmp_stage}_${rn}_match";
        my $match_mux_signal = "${match_mux_stage}_${rn}_match";

        if ($mpu_use_limit) {
            e_assign->adds(

              [[$match_cmp_signal, 1], 
                "($mpu_match_cmp_addr >= ${rn}_base) & " .
                "($mpu_match_cmp_addr < ${rn}_limit)"],
            );
        } else {
            e_assign->adds(

              [[$match_cmp_signal, 1], 
                "($mpu_match_cmp_addr & ${rn}_mask) == ${rn}_base"],
            );
        }

        push(@region_match_mux_signals, $match_mux_signal);
        push(@region_match_wave_signals,
          { radix => "x", signal => $match_cmp_signal },
        );


        if ($match_cmp_stage ne $match_mux_stage) {
            e_register->adds(
              {out => [$match_mux_signal, 1],     in => $match_cmp_signal, 
               enable => "${match_mux_stage}_en"},
            );
        }


        my $sel = 
          ($ri == ($num_regions - 1)) ?
            "1'b1" : 
            "${match_mux_stage}_${rn}_match";

        push(@region_c_mux_table,     $sel => "${rn}_c");
        push(@region_perm_mux_table,  $sel => "${rn}_perm");
    }


    e_mux->adds(
      $d ? { lhs => ["${match_mux_stage}_${m}_c", 1, 0, $force_never_export],
        type => "priority", table => \@region_c_mux_table } : (),
      { lhs => ["${match_mux_stage}_${m}_perm", $region_perm_sz],
        type => "priority", table => \@region_perm_mux_table },
    );

    e_assign->adds(

      [["${match_mux_stage}_${m}_hit", 1], 
        join('|', @region_match_mux_signals)],
    );

    my @region_lookup_wave_signals = (
      { divider => "$M Lookup" },
      { radix => "x", signal => "$mpu_match_cmp_addr" },
      @region_match_wave_signals,

      $d ? { radix => "x", signal => "${match_mux_stage}_${m}_c" } : "",
      { radix => "x", signal => "${match_mux_stage}_${m}_perm" },
      { radix => "x", signal => "${match_mux_stage}_${m}_hit" },
    );

    my @wave_signals = 
      (@region_lookup_wave_signals,
       @region_wave_signals,
       @region_read_wave_signals);

    return \@wave_signals;
}





sub
create_mpu_constants
{
    my $mpu_args = shift;

    my %constants;

    $constants{mpu_use_limit} = manditory_bool($mpu_args, "mpu_use_limit");


    $constants{mpu_inst_perm_sz} = 2;
    $constants{mpu_inst_perm_super_none_user_none} = "0";
    $constants{mpu_inst_perm_super_exec_user_none} = "1";
    $constants{mpu_inst_perm_super_exec_user_exec} = "2";


    $constants{mpu_data_perm_sz} = 3;
    $constants{mpu_data_perm_super_none_user_none} = "0";
    $constants{mpu_data_perm_super_rd_user_none}   = "1";
    $constants{mpu_data_perm_super_rd_user_rd}     = "2";
    $constants{mpu_data_perm_super_rw_user_none}   = "4";
    $constants{mpu_data_perm_super_rw_user_rd}     = "5";
    $constants{mpu_data_perm_super_rw_user_rw}     = "6";

    $constants{mpu_min_regions} = 1;
    $constants{mpu_max_regions} = 32;
    $constants{mpu_min_region_size_log2} = 6;
    $constants{mpu_max_region_size_log2} = 20;

    return \%constants;
}

sub
add_handy_macros
{
    my $h_lines = shift;

    my $define = "#define";     # The build removes #define comments

    my $macros_str = <<EOM;

/*
 * The Nios II is configured with the MPU using the limit instead of
 * the mask.  Provide missing defines for the mask (same as the base).
 */
$define MPUACC_REG_MASK_LSB (MPUBASE_REG_BASE_LSB)
$define MPUACC_REG_MASK_MSB (MPUBASE_REG_BASE_MSB)
$define MPUACC_REG_MASK_SZ (MPUBASE_REG_BASE_SZ)
$define MPUACC_REG_MASK_UNSHIFTED_MASK (MPUBASE_REG_BASE_UNSHIFTED_MASK)
$define MPUACC_REG_MASK_SHIFTED_MASK (MPUBASE_REG_BASE_SHIFTED_MASK)
$define MPUACC_REG_MASK_MASK (MPUBASE_REG_BASE_MASK)
$define SET_MPUACC_REG_MASK(Reg, Val) SET_MPUBASE_REG_BASE(Reg, Val)
$define GET_MPUACC_REG_MASK(Reg) GET_MPUBASE_REG_BASE(Reg)
EOM

    push(@$h_lines, split(/\n/, $macros_str));
}

sub
eval_cmd
{
    my $cmd = shift;

    eval($cmd);
    if ($@) {
        &$error("nios2_mpu.pm: eval($cmd) returns '$@'\n");
    }
}

1;

