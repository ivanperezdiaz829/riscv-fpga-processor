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






















package nios2_mul;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    $hw_mul
    $hw_mul_omits_msw
    $hw_mul_uses_dsp_block
    $hw_mul_uses_embedded_mults
    $hw_mul_uses_les
    $hw_mul_uses_designware
    $hw_mul_width_b
);

use cpu_utils;
use cpu_wave_signals;
use nios_europa;
use nios_isa;
use nios_altmult_add;
use europa_all;
use europa_utils;
use strict;





our $hw_mul;
our $hw_mul_omits_msw;
our $hw_mul_uses_dsp_block;
our $hw_mul_uses_embedded_mults;
our $hw_mul_uses_les;
our $hw_mul_uses_designware;
our $hw_mul_width_b;





sub 
initialize_config_constants
{
    my $multiply_info = shift;
    my $misc_info = shift;


    $hw_mul = manditory_bool($multiply_info, "hardware_multiply_present");


    $hw_mul_omits_msw = 
      $hw_mul && manditory_bool($multiply_info, "hardware_multiply_omits_msw");

    if (manditory_bool($misc_info, "use_designware")) {
        $hw_mul_uses_designware = 1;
    } else {

        my $impl = not_empty_scalar($multiply_info, "hardware_multiply_impl");

        $hw_mul_uses_dsp_block = ($impl eq "dsp_mul");
        $hw_mul_uses_embedded_mults = ($impl eq "embedded_mul");
        $hw_mul_uses_les = ($impl eq "le_mul");
    }


    $hw_mul_width_b = $hw_mul_uses_les            ?  4 :
                      $hw_mul_uses_embedded_mults ? 16 :
                                                    32;
}



sub
gen_mul
{
    my $Opt = shift;

    if (!$hw_mul) {
        &$error("Called when hw_mul is false");
    }

    if ($hw_mul_uses_dsp_block) {
        gen_pipelined_mul_logic($Opt);
        gen_pipelined_mul_cell($Opt);
    } elsif ($hw_mul_uses_embedded_mults || $hw_mul_uses_les ) {
        gen_unpipelined_mul_logic($Opt);
        gen_unpipelined_mul_cell($Opt);
    } elsif ($hw_mul_uses_designware) {
        gen_designware_pipelined_mul_cell($Opt);
    } else {
        &$error("Unsupported hardware multiplier implementation");
    }
}








sub 
gen_pipelined_mul_logic
{
    my $Opt = shift;

    my $whoami = "pipelined multiplier logic";

    my $is = not_empty_scalar($Opt, "non_pipelined_long_latency_input_stage");
    my $os = not_empty_scalar($Opt, "long_latency_output_stage");
    my $pipelined = 
      check_opt_value($Opt, "mul_cell_pipelined", ["0", "1"], $whoami);



    my $mul_cell_result_sel_sz = 2;
    my $mul_cell_result_sel_lsw = "2'b00";
    my $mul_cell_result_sel_msw = "2'b01";
    my $mul_cell_result_sel_or  = "2'b10";













    my $col_sz = 3;
    my $col_lsb = 0;
    my $col_msb = $col_lsb + $col_sz - 1;
    my $num_cols = 1 << $col_sz;

    my $row_sz = 2;
    my $row_lsb = $col_msb + 1;
    my $row_msb = $row_lsb + $row_sz - 1;
    my $num_rows = 1 << $row_sz;

    e_assign->adds(
      [["E_shift_rot_col_zero", 1], "E_src2[$col_msb:$col_lsb] == 0"],
      );

    e_signal->adds(
      ["E_src1_mul_cell", $datapath_sz],
      ["E_src2_mul_cell", $datapath_sz],
      );

    e_signal->adds(
       ["E_sh_cnt_col", $num_cols],
       ["E_sh_cnt_row", $num_rows],
       );

    e_mux->add({
      lhs => ["E_sh_cnt_col", $num_cols],
      selecto  => 
        "{E_ctrl_shift_rot_right, E_src2[$col_msb:$col_lsb]}",
      table => [
        "4'h0" => "8'h01",
        "4'h1" => "8'h02",
        "4'h2" => "8'h04",
        "4'h3" => "8'h08",
        "4'h4" => "8'h10",
        "4'h5" => "8'h20",
        "4'h6" => "8'h40",
        "4'h7" => "8'h80",
        "4'h8" => "8'h01",
        "4'h9" => "8'h80",
        "4'ha" => "8'h40",
        "4'hb" => "8'h20",
        "4'hc" => "8'h10",
        "4'hd" => "8'h08",
        "4'he" => "8'h04",
        "4'hf" => "8'h02",
        ],
       });

    e_mux->add({
      lhs => ["E_sh_cnt_row", $num_rows],
      selecto  => 
        "{E_ctrl_shift_rot_right, E_src2[$row_msb:$row_lsb],
          E_shift_rot_col_zero}",
      table => [
        "4'h0" => "4'h1",
        "4'h1" => "4'h1",
        "4'h2" => "4'h2",
        "4'h3" => "4'h2",
        "4'h4" => "4'h4",
        "4'h5" => "4'h4",
        "4'h6" => "4'h8",
        "4'h7" => "4'h8",
        "4'h8" => "4'h8",
        "4'h9" => "4'h1",
        "4'ha" => "4'h4",
        "4'hb" => "4'h8",
        "4'hc" => "4'h2",
        "4'hd" => "4'h4",
        "4'he" => "4'h1",
        "4'hf" => "4'h2",
        ],
       });

    my $row;
    my $col;




    for ($row = 0; $row < $num_rows; $row++) {
        for ($col = 0; $col < $num_cols; $col++) {
            my $i = $row * $num_cols + $col;

            e_assign->adds(
              ["E_src2_mul_cell[$i]", 
                 "E_ctrl_shift_rot ? 
                  (E_sh_cnt_col[$col] & E_sh_cnt_row[$row]) : E_src2[$i]"],
              );
        }
    }


    e_assign->adds(
      ["E_src1_mul_cell", "E_src1"],
    );





    e_assign->adds(
      [["E_shift_rot_by_zero", 1], "E_src2[$datapath_log2_sz-1:0] == 0"],
      );

    e_register->adds(

      {out => ["M_shift_rot_by_zero", 1], in => "E_shift_rot_by_zero",
       enable => "M_en"},
      );



    e_mux->add ({
      lhs => ["M_mul_cell_result_sel", $mul_cell_result_sel_sz],
      type => "priority",
      table => [
        "M_ctrl_rot"  
            => "$mul_cell_result_sel_or",
        "(M_ctrl_shift_right & ~M_shift_rot_by_zero) | M_ctrl_mulx"  
            => "$mul_cell_result_sel_msw",
        "1'b1"  
            => "$mul_cell_result_sel_lsw",
        ],
      });





    if ($pipelined) {
        e_register->adds(
          {out => ["${os}_mul_cell_result_sel", $mul_cell_result_sel_sz], 
           in => "M_mul_cell_result_sel", enable => "${os}_en"},
          );
    }







    my $result_mux_output = $pipelined ?
      "${os}_mul_shift_rot_result" : "${os}_mul_shift_rot_result_nxt";


    e_assign->adds(
      [["${os}_mul_cell_result_lsw", $datapath_sz], 
        "${os}_mul_cell_result[$datapath_sz-1:0]"],
      [["${os}_mul_cell_result_msw", $datapath_sz], 
        "${os}_mul_cell_result[$datapath_sz*2-1:$datapath_sz]"],
      );

    e_mux->add ({
      lhs => [$result_mux_output, $datapath_sz],
      selecto => "${os}_mul_cell_result_sel",
      table => [
        "$mul_cell_result_sel_lsw" => "${os}_mul_cell_result_lsw",
        "$mul_cell_result_sel_msw" => "${os}_mul_cell_result_msw",
        "$mul_cell_result_sel_or"  => 
          "${os}_mul_cell_result_msw|${os}_mul_cell_result_lsw",
        ],
      default => "0",
      });



    if (!$pipelined) {
        e_register->adds(
          {out => ["${os}_mul_shift_rot_result", $datapath_sz], 
           in => $result_mux_output, enable => "1'b1"},
        );
    }






    if (!$pipelined) {

        e_assign->adds(
          [["${is}_valid_mul_shift_rot_entering_${os}", 1],
              "${is}_ctrl_mul_shift_rot & ${is}_valid & ${os}_en"],
    
          [["${os}_mul_shift_rot_stall_nxt", 1], 
            "${is}_valid_mul_shift_rot_entering_${os} | 
             ${os}_valid_mul_shift_rot_entered_${os}"],
          );
    
        e_register->adds(
          {out => ["${os}_mul_shift_rot_stall", 1], 
           in => "${os}_mul_shift_rot_stall_nxt", enable => "1'b1"},
          {out => ["${os}_valid_mul_shift_rot_entered_${os}", 1], 
           in => "${is}_valid_mul_shift_rot_entering_${os}", enable => "1'b1"},
          );
    }

    my @mul_shift = (
        { divider => "mul_shift" },
        { radix => "x", signal => "E_ctrl_shift_rot" },
        { radix => "x", signal => "E_ctrl_shift_rot_right" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "E_src1_mul_cell" },
        { radix => "x", signal => "E_src2_mul_cell" },
        { radix => "x", signal => "E_ctrl_mul_shift_src1_signed" },
        { radix => "x", signal => "E_ctrl_mul_shift_src2_signed" },
    );

    push(@mul_shift,
      { radix => "x", signal => "${os}_mul_cell_result_sel" },
    );

    push(@mul_shift,
      { radix => "x", signal => "${os}_mul_cell_result" },
      { radix => "x", signal => "${os}_mul_shift_rot_result" },
    );

    if (!$pipelined) {
        push(@mul_shift,
          { radix => "x", signal => "${os}_mul_shift_rot_stall" },
          { radix => "x", signal => "${os}_valid_mul_shift_rot_entered_${os}" },
        );
    }

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @mul_shift);
    }
}






sub gen_pipelined_mul_cell
{
    my $Opt = shift;

    my $whoami = "pipelined multiplier cell";

    my $os = not_empty_scalar($Opt, "long_latency_output_stage");
    my $pipelined = 
      check_opt_value($Opt, "mul_cell_pipelined", ["0", "1"], $whoami);


    my $submodule_name = $Opt->{name}."_mult_cell";
    my $submodule = e_module->new({
      name        => $submodule_name,
      output_file => $submodule_name,
      bypass_vhdl_declare_component => 1,
    });
    e_instance->add({module => $submodule});
    my $marker = e_default_module_marker->new($submodule);

    my $mul_cell_result_width = 
      $datapath_sz*2;


    e_signal->adds(
       {name => "${os}_mul_cell_result", width => $mul_cell_result_width },
       );

    e_assign->adds(
      [["mul_clr", 1], "~reset_n"],
    );












    my %mul_inputs = (
          "dataa"       => "E_src1_mul_cell",
          "datab"       => "E_src2_mul_cell",
          "signa"       => "E_ctrl_mul_shift_src1_signed",
          "signb"       => "E_ctrl_mul_shift_src2_signed",


          "clock0"      => "clk",
          "ena0"        => $pipelined ? "M_en" : "1'b1",
          "aclr0"       => "mul_clr",


          "clock1"      => "clk",
          "ena1"        => $pipelined ? "${os}_en" : "1'b1",
          "aclr1"       => "mul_clr",
        );

    my $device_family = not_empty_scalar($Opt, "device_family");

    my %mul_parameters = (
          "lpm_type"                            => qq("altera_mult_add"),
          "number_of_multipliers"               => 1,
          "dedicated_multiplier_circuitry"      => qq("YES"),
          "multiplier1_direction"               => qq("ADD"),
          "multiplier_register0"                => qq("UNREGISTERED"),

          "width_a"                             => $datapath_sz,
          "width_b"                             => $datapath_sz,
          "width_result"                        => $mul_cell_result_width,

          "input_register_a0"                   => qq("CLOCK0"),
          "input_register_b0"                   => qq("CLOCK0"),
          "input_aclr_a0"                       => qq("ACLR0"),
          "input_aclr_b0"                       => qq("ACLR0"),
          "input_source_a0"                     => qq("DATAA"),
          "input_source_b0"                     => qq("DATAB"),

          "signed_aclr_a"                       => qq("ACLR0"),
          "signed_aclr_b"                       => qq("ACLR0"),
          "signed_register_a"                   => qq("CLOCK0"),
          "signed_register_b"                   => qq("CLOCK0"),
          "signed_pipeline_register_a"          => qq("UNREGISTERED"),
          "signed_pipeline_register_b"          => qq("UNREGISTERED"),
          "port_signa"                          => qq("PORT_USED"),
          "port_signb"                          => qq("PORT_USED"),
          "port_addnsub1"                       => qq("PORT_UNUSED"),
          "port_addnsub3"                       => qq("PORT_UNUSED"),

          "addnsub_multiplier_register1"        => qq("CLOCK0"),
          "addnsub_multiplier_pipeline_aclr1"   => qq("UNUSED"),
          "addnsub_multiplier_aclr1"            => qq("UNUSED"),

          "output_register"                     => qq("CLOCK1"),
          "output_aclr"                         => qq("ACLR1"),

          "selected_device_family"              => '"' . $device_family . '"',
        );


    e_blind_instance->add({
      name              => "the_altmult_add",
      module            => "altera_mult_add",
      in_port_map       => \%mul_inputs,
      out_port_map      => { "result" => "${os}_mul_cell_result" },
      parameter_map     => \%mul_parameters,
      use_sim_models    => 1,
      });
}







sub 
gen_designware_pipelined_mul_cell
{
    my $Opt = shift;

    my $whoami = "Designware pipelined multiplier cell";
    my $os = check_opt_value($Opt, "long_latency_output_stage", ["A"], $whoami);


    my $submodule_name = $Opt->{name}."_mult_cell";
    my $submodule = e_module->new({
      name        => $submodule_name,
      output_file => $submodule_name,
      bypass_vhdl_declare_component => 1,
    });
    e_instance->add({module => $submodule});
    my $marker = e_default_module_marker->new($submodule);


    e_signal->adds(
       {name => "M_mul_result", width => $datapath_sz },
    );










    my %mul_inputs = (
        "clk"      => "clk",
        "reset_n"     => "reset_n",
        "en"          => "M_en",
        "data_a"       => "E_src1",
        "data_b"       => "E_src2",
    );

    my %mul_outputs = (
         "result" => "M_mul_result",
    );
    
    my %mul_parameters = (
        "width_a"               => $datapath_sz,
        "width_b"               => $datapath_sz,
        "width_r"               => $datapath_sz, #result width
    );

    e_comment->add({
      comment => "Designware multiplier\n",
    });

    e_blind_instance->add({
      name              => "the_designware_mult",
      module            => "DWC_n2p_mult",
      in_port_map       => \%mul_inputs,
      out_port_map      => \%mul_outputs,
      parameter_map     => \%mul_parameters,
      use_sim_models    => 1,
    });




    e_register->adds(
      {out => ["A_mul_result", $datapath_sz], 
       in => "M_mul_result", enable => "A_en"},
    );

    my @mul = (
        { divider => "Designware multiplier cell" },
        { radix => "x", signal => "E_src1" },
        { radix => "x", signal => "E_src2" },
        { radix => "x", signal => "M_mul_result" },
        { radix => "x", signal => "A_mul_result" },
      );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @mul);
    }
}




sub gen_unpipelined_mul_logic
{
    my ($Opt) = @_;

    my $whoami = "unpipelined multiplier logic";

    my $is = not_empty_scalar($Opt, "non_pipelined_long_latency_input_stage");
    my $os = not_empty_scalar($Opt, "long_latency_output_stage");

































 








 


    my $num_mul_cycles = ceil($datapath_sz / $hw_mul_width_b) + 2;


    my $mul_cnt_sz = num2sz($num_mul_cycles);

    e_assign->adds(
      [["${os}_mul_cnt_nxt", $mul_cnt_sz],
        "${os}_mul_stall ? 
           ${os}_mul_cnt-1 :
           $num_mul_cycles"],
 
      [["${os}_mul_done_nxt", 1],
        "${os}_mul_cnt_nxt == 0"],
 
      [["${os}_mul_stall_nxt", 1], 
        "~${os}_mul_done_nxt & 
         (${os}_mul_stall |
          (${is}_ctrl_mul_lsw & ${is}_valid & ${os}_en))"],
      );

    e_mux->add ({
      lhs => ["${os}_mul_src1_nxt", $datapath_sz],
      type => "priority",
      table => [


        "~${os}_mul_stall" => "${is}_src1",
 

        "1'b1" => 
          "{${os}_mul_src1[$datapath_msb-$hw_mul_width_b:0],
            ${hw_mul_width_b}'b0}",
        ],
      });

    e_mux->add ({
      lhs => ["${os}_mul_src2_nxt", $datapath_sz],
      type => "priority",
      table => [


        "~${os}_mul_stall" => "${is}_src2",
 

        "1'b1" => 
          "{${hw_mul_width_b}'b0,
            ${os}_mul_src2[$datapath_msb:$hw_mul_width_b]}",
        ],
      });

    e_assign->adds(
      [["${os}_mul_partial_prod_nxt", $datapath_sz],
        "${os}_mul_cell_result[$datapath_sz-1:0]"],
      );

    e_assign->adds(

      [["${os}_mul_result_nxt", $datapath_sz],
        "${os}_mul_stall_d3 ?
           ${os}_mul_partial_prod + ${os}_mul_result :
           ${os}_mul_partial_prod"],
      );

    e_register->adds(
      {out => ["${os}_mul_src1", $datapath_sz], 
       in => "${os}_mul_src1_nxt", enable => "1'b1"},
      {out => ["${os}_mul_src2", $datapath_sz], 
       in => "${os}_mul_src2_nxt", enable => "1'b1"},
      {out => ["${os}_mul_partial_prod", $datapath_sz], 
       in => "${os}_mul_partial_prod_nxt", enable => "1'b1"},
      {out => ["${os}_mul_result", $datapath_sz], 
       in => "${os}_mul_result_nxt", enable => "1'b1"},

      {out => ["${os}_mul_cnt", $mul_cnt_sz], 
       in => "${os}_mul_cnt_nxt", enable => "1'b1"},

      {out => ["${os}_mul_stall", 1], 
       in => "${os}_mul_stall_nxt", enable => "1'b1"},
      {out => ["${os}_mul_stall_d1", 1], 
       in => "${os}_mul_stall", enable => "1'b1"},
      {out => ["${os}_mul_stall_d2", 1], 
       in => "${os}_mul_stall_d1", enable => "1'b1"},
      {out => ["${os}_mul_stall_d3", 1], 
       in => "${os}_mul_stall_d2", enable => "1'b1"},
      );

    my @mul = (
        { divider => "mul" },
        { radix => "x", signal => "${is}_src1" },
        { radix => "x", signal => "${is}_src2" },
        { radix => "x", signal => "${is}_ctrl_mul_lsw" },
        { radix => "x", signal => "${is}_valid" },
        { radix => "x", signal => "${os}_en" },
        { radix => "x", signal => "${os}_mul_done_nxt" },
        { radix => "x", signal => "${os}_mul_stall" },
        { radix => "x", signal => "${os}_mul_stall_d1" },
        { radix => "x", signal => "${os}_mul_stall_d2" },
        { radix => "x", signal => "${os}_mul_stall_d3" },
        { radix => "x", signal => "${os}_mul_cnt_nxt" },
        { radix => "x", signal => "${os}_mul_cnt" },
        { radix => "x", signal => "${os}_mul_src1_nxt" },
        { radix => "x", signal => "${os}_mul_src1" },
        { radix => "x", signal => "${os}_mul_src2_nxt" },
        { radix => "x", signal => "${os}_mul_src2" },
        { radix => "x", signal => "${os}_mul_cell_result" },
        { radix => "x", signal => "${os}_mul_partial_prod_nxt" },
        { radix => "x", signal => "${os}_mul_partial_prod" },
        { radix => "x", signal => "${os}_mul_result_nxt" },
        { radix => "x", signal => "${os}_mul_result" },
    );

    if ($Opt->{full_waveform_signals}) {
        push(@plaintext_wave_signals, @mul);
    }
}






sub gen_unpipelined_mul_cell
{
    my ($Opt) = @_;

    my $whoami = "unpipelined multiplier cell";

    my $os = not_empty_scalar($Opt, "long_latency_output_stage");


    my $submodule_name = $Opt->{name}."_mult_cell";
    my $submodule = e_module->new({
      name        => $submodule_name,
      output_file => $submodule_name,
      bypass_vhdl_declare_component => 1,
    });
    e_instance->add({module => $submodule});
    my $marker = e_default_module_marker->new($submodule);


    e_signal->adds(
       {name => "${os}_mul_cell_result", width => $datapath_sz },
       );

    e_assign->adds(
      [["mul_clr", 1], "~reset_n"],
    );

    my $device_family = not_empty_scalar($Opt, "device_family");




    if ($hw_mul_uses_les) {
        my %mul_inputs;
        my %mul_parameters;

        %mul_inputs = (
              "dataa"       => "${os}_mul_src1",
              "datab"       => "${os}_mul_src2[$hw_mul_width_b-1:0]",
    

              "clock0"      => "clk",
              "ena0"        => "1'b1",
              "aclr3"       => "mul_clr",
            );
    
        %mul_parameters = (
              "multiplier_register0"                  => qq("CLOCK0"),
              "signed_pipeline_aclr_b"                => qq("ACLR3"),
              "addnsub_multiplier_pipeline_aclr1"     => qq("ACLR3"),
              "signed_register_a"                     => qq("UNREGISTERED"),
              "number_of_multipliers"                 => 1,
              "multiplier_aclr0"                      => qq("ACLR3"),
              "signed_register_b"                     => qq("UNREGISTERED"),
              "lpm_type"                              => qq("altera_mult_add"),
              "output_register"                       => qq("UNREGISTERED"),
              "width_result"                          => $datapath_sz,
              "representation_a"                      => qq("UNSIGNED"),
              "signed_pipeline_register_a"            => qq("CLOCK0"),
              "input_source_b0"                       => qq("DATAB"),
              "addnsub_multiplier_register1"          => qq("UNREGISTERED"),
              "representation_b"                      => qq("UNSIGNED"),
              "signed_pipeline_register_b"            => qq("CLOCK0"),
              "input_source_a0"                       => qq("DATAA"),
              "dedicated_multiplier_circuitry"        => qq("NO"),
              "port_addnsub1"                         => qq("PORT_UNUSED"),
              "port_addnsub3"                         => qq("PORT_UNUSED"),
              "port_signa"                            => qq("PORT_UNUSED"),
              "port_signb"                            => qq("PORT_UNUSED"),
              "selected_device_family"                =>
                '"' . $device_family . '"',
              "addnsub_multiplier_pipeline_register1" => qq("CLOCK0"),
              "width_a"                               => $datapath_sz,
              "input_register_b0"                     => qq("UNREGISTERED"),
              "width_b"                               => $hw_mul_width_b,
              "input_register_a0"                     => qq("UNREGISTERED"),
              "multiplier1_direction"                 => qq("ADD"),
              "signed_pipeline_aclr_a"                => qq("ACLR3"),
            );

        e_blind_instance->add({
          name              => "the_altmult_add",
          module            => "altera_mult_add",
          in_port_map       => \%mul_inputs,
          out_port_map      => { "result" => "${os}_mul_cell_result" },
          parameter_map     => \%mul_parameters,
          use_sim_models    => 1,
          });
    } elsif ($hw_mul_uses_embedded_mults) {












        my %mul_inputs_part_1;
        my %mul_parameters_part_1;
        my %mul_inputs_part_2;
        my %mul_parameters_part_2;

        e_signal->adds(
           {name => "${os}_mul_cell_result_part_1", width => $datapath_sz },
           {name => "${os}_mul_cell_result_part_2", width => $datapath_sz / 2 },
           );

        %mul_inputs_part_1 = (
              "dataa"       => "${os}_mul_src1[${datapath_sz}/2-1:0]",
              "datab"       => "${os}_mul_src2[$hw_mul_width_b-1:0]",
    

              "clock0"      => "clk",
              "ena0"        => "1'b1",
              "aclr0"       => "mul_clr",
            );
    
        %mul_parameters_part_1 = (
              "multiplier_register0"                  => qq("CLOCK0"),
              "signed_pipeline_aclr_b"                => qq("ACLR0"),
              "addnsub_multiplier_pipeline_aclr1"     => qq("ACLR0"),
              "signed_register_a"                     => qq("UNREGISTERED"),
              "number_of_multipliers"                 => 1,
              "multiplier_aclr0"                      => qq("ACLR0"),
              "signed_register_b"                     => qq("UNREGISTERED"),
              "lpm_type"                              => qq("altera_mult_add"),
              "output_register"                       => qq("UNREGISTERED"),
              "width_result"                          => $datapath_sz,
              "representation_a"                      => qq("UNSIGNED"),
              "signed_pipeline_register_a"            => qq("CLOCK0"),
              "input_source_b0"                       => qq("DATAB"),
              "addnsub_multiplier_register1"          => qq("UNREGISTERED"),
              "representation_b"                      => qq("UNSIGNED"),
              "signed_pipeline_register_b"            => qq("CLOCK0"),
              "input_source_a0"                       => qq("DATAA"),
              "dedicated_multiplier_circuitry"        => qq("YES"),
              "port_addnsub1"                         => qq("PORT_UNUSED"),
              "port_addnsub3"                         => qq("PORT_UNUSED"),
              "port_signa"                            => qq("PORT_UNUSED"),
              "port_signb"                            => qq("PORT_UNUSED"),
              "selected_device_family"                =>
                '"' . $device_family . '"',
              "addnsub_multiplier_pipeline_register1" => qq("CLOCK0"),
              "width_a"                               => $datapath_sz / 2,
              "input_register_b0"                     => qq("UNREGISTERED"),
              "width_b"                               => $hw_mul_width_b,
              "input_register_a0"                     => qq("UNREGISTERED"),
              "multiplier1_direction"                 => qq("ADD"),
              "signed_pipeline_aclr_a"                => qq("ACLR0"),
            );

        %mul_inputs_part_2 = (
              "dataa"       => 
                "${os}_mul_src1[${datapath_sz}-1:${datapath_sz}/2]",
              "datab"       => "${os}_mul_src2[$hw_mul_width_b-1:0]",
    

              "clock0"      => "clk",
              "ena0"        => "1'b1",
              "aclr0"       => "mul_clr",
            );
    
        %mul_parameters_part_2 = (
              "multiplier_register0"                  => qq("CLOCK0"),
              "signed_pipeline_aclr_b"                => qq("ACLR0"),
              "addnsub_multiplier_pipeline_aclr1"     => qq("ACLR0"),
              "signed_register_a"                     => qq("UNREGISTERED"),
              "number_of_multipliers"                 => 1,
              "multiplier_aclr0"                      => qq("ACLR0"),
              "signed_register_b"                     => qq("UNREGISTERED"),
              "lpm_type"                              => qq("altera_mult_add"),
              "output_register"                       => qq("UNREGISTERED"),
              "width_result"                          => $datapath_sz / 2,
              "representation_a"                      => qq("UNSIGNED"),
              "signed_pipeline_register_a"            => qq("CLOCK0"),
              "input_source_b0"                       => qq("DATAB"),
              "addnsub_multiplier_register1"          => qq("UNREGISTERED"),
              "representation_b"                      => qq("UNSIGNED"),
              "signed_pipeline_register_b"            => qq("CLOCK0"),
              "input_source_a0"                       => qq("DATAA"),
              "dedicated_multiplier_circuitry"        => qq("YES"),
              "port_addnsub1"                         => qq("PORT_UNUSED"),
              "port_addnsub3"                         => qq("PORT_UNUSED"),
              "port_signa"                            => qq("PORT_UNUSED"),
              "port_signb"                            => qq("PORT_UNUSED"),
              "selected_device_family"                =>
                '"' . $device_family . '"',
              "addnsub_multiplier_pipeline_register1" => qq("CLOCK0"),
              "width_a"                               => $datapath_sz / 2,
              "input_register_b0"                     => qq("UNREGISTERED"),
              "width_b"                               => $hw_mul_width_b,
              "input_register_a0"                     => qq("UNREGISTERED"),
              "multiplier1_direction"                 => qq("ADD"),
              "signed_pipeline_aclr_a"                => qq("ACLR0"),
            );

        nios_altmult_add->add({
          name              => "the_altmult_add_part_1",
          in_port_map       => \%mul_inputs_part_1,
          out_port_map      => { "result" => "${os}_mul_cell_result_part_1" },
          parameter_map     => \%mul_parameters_part_1,
          use_sim_models    => 1,
          });

        nios_altmult_add->add({
          name              => "the_altmult_add_part_2",
          in_port_map       => \%mul_inputs_part_2,
          out_port_map      => { "result" => "${os}_mul_cell_result_part_2" },
          parameter_map     => \%mul_parameters_part_2,
          use_sim_models    => 1,
          });

        e_assign->adds(
          ["${os}_mul_cell_result",
            "{${os}_mul_cell_result_part_1[${datapath_sz}-1:${datapath_sz}/2] +
                ${os}_mul_cell_result_part_2,
              ${os}_mul_cell_result_part_1[${datapath_sz}/2-1:0]}"],
          );
    } else {
        &$error("$whoami: unsupported multiplier implementation");
    }
}

1;
