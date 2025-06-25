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






















use cpu_utils;
use europa_all;
use strict;

sub make_nios2_oci_break
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_break",
  });

  my $oci_num_xbrk = $Opt->{oci_num_xbrk};  # shorthand
  my $oci_num_dbrk = $Opt->{oci_num_dbrk};

  my $xbrk_width  = $Opt->{cpu_i_address_width};
  my $max_latency = 1;



  $module->add_contents (

    e_signal->news (



      ["xbrk_ctrl0",          8,                        1],
      ["xbrk_ctrl1",          8,                        1],
      ["xbrk_ctrl2",          8,                        1],
      ["xbrk_ctrl3",          8,                        1],

      ["trigbrktype",           1,                      1],
    ),

    e_signal->news (
      ["jdo",           $SR_WIDTH,    0],
    ),

  );







  my $dbrk_addr_high = $Opt->{cpu_d_address_width} - 1;
  my $dbrk_data_high = 32 + ($Opt->{cpu_d_data_width} - 1);
  my $dbrk_ctrl_width = $Opt->{oci_dbrk_trace} ? 10 : 7;
  my $dbrk_ctrl_high = 64 + ($dbrk_ctrl_width - 1);







  $module->add_contents (   
    e_signal->news (    # never export these
      ["xbrk0_value",                32,    0,  1],
      ["xbrk1_value",                32,    0,  1],
      ["xbrk2_value",                32,    0,  1],
      ["xbrk3_value",                32,    0,  1],
    ),
  );











  $module->add_contents (   
    e_signal->news (
      ["break_a_wpr",($BREAK_A_WPR_MSB_POS-$BREAK_A_WPR_LSB_POS+1), 0, 1],
      ["break_b_rr", ($BREAK_B_RR_MSB_POS-$BREAK_B_RR_LSB_POS+1), 0, 1],
      ["break_c_rr", ($BREAK_C_RR_MSB_POS-$BREAK_C_RR_LSB_POS+1), 0, 1],
    ),
    e_assign->news (
      ["break_a_wpr"  => "jdo[$BREAK_A_WPR_MSB_POS:$BREAK_A_WPR_LSB_POS]",],
      ["break_a_wpr_high_bits"  => "break_a_wpr [3:2]"], 
      ["break_a_wpr_low_bits"   => "break_a_wpr [1:0]"], 
      ["break_b_rr" => "jdo[$BREAK_B_RR_MSB_POS:$BREAK_B_RR_LSB_POS]"],
      ["break_c_rr" => "jdo[$BREAK_C_RR_MSB_POS:$BREAK_C_RR_LSB_POS]"],
      ["take_action_any_break" => 
          "(take_action_break_a | take_action_break_b | take_action_break_c)"],
    ),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["xbrk_ctrl0", "xbrk_ctrl1", "xbrk_ctrl2",
      "xbrk_ctrl3", "trigbrktype"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["xbrk_ctrl0"    => "0"],
          ["xbrk_ctrl1"    => "0"],
          ["xbrk_ctrl2"    => "0"],
          ["xbrk_ctrl3"    => "0"],
          ["trigbrktype"  => "0"],
        ),
      ],
      contents  => [


        e_if->new ({
          condition => "take_action_any_break",
          then      => [ e_assign->new (["trigbrktype" => "0"]),],
          elsif   => {
            condition => "(dbrk_break)",
            then      => [ e_assign->new (["trigbrktype" => "1"]),],
          },
        }),

        e_if->new ({



            condition => "(take_action_break_b)",
            then    => [
              e_if->new ({
                condition => "(break_b_rr == 2'b00) && ($oci_num_dbrk >= 1)",
                then  => [
                ["xbrk_ctrl0[$xbrk_ctrl_brk_bit]" => "jdo[$BREAK_B_BRK_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_tout_bit]"=>"jdo[$BREAK_B_TOUT_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_toff_bit]"=>"jdo[$BREAK_B_TOFF_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_ton_bit]" => "jdo[$BREAK_B_TON_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_arm0_bit]"=>"jdo[$BREAK_B_ARM0_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_arm1_bit]"=>"jdo[$BREAK_B_ARM1_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_goto0_bit]"=>"jdo[$BREAK_B_GOTO0_POS]"],
                ["xbrk_ctrl0[$xbrk_ctrl_goto1_bit]"=>"jdo[$BREAK_B_GOTO1_POS]"],
                ],
              }),
              e_if->new ({
                condition => "(break_b_rr == 2'b01) && ($oci_num_dbrk >= 2)",
                then  => [
                ["xbrk_ctrl1[$xbrk_ctrl_brk_bit]" => "jdo[$BREAK_B_BRK_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_tout_bit]"=>"jdo[$BREAK_B_TOUT_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_toff_bit]"=>"jdo[$BREAK_B_TOFF_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_ton_bit]" => "jdo[$BREAK_B_TON_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_arm0_bit]"=>"jdo[$BREAK_B_ARM0_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_arm1_bit]"=>"jdo[$BREAK_B_ARM1_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_goto0_bit]"=>"jdo[$BREAK_B_GOTO0_POS]"],
                ["xbrk_ctrl1[$xbrk_ctrl_goto1_bit]"=>"jdo[$BREAK_B_GOTO1_POS]"],
                ],
              }),
              e_if->new ({
                condition => "(break_b_rr == 2'b10) && ($oci_num_dbrk >= 3)",
                then  => [
                ["xbrk_ctrl2[$xbrk_ctrl_brk_bit]" => "jdo[$BREAK_B_BRK_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_tout_bit]"=>"jdo[$BREAK_B_TOUT_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_toff_bit]"=>"jdo[$BREAK_B_TOFF_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_ton_bit]" => "jdo[$BREAK_B_TON_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_arm0_bit]"=>"jdo[$BREAK_B_ARM0_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_arm1_bit]"=>"jdo[$BREAK_B_ARM1_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_goto0_bit]"=>"jdo[$BREAK_B_GOTO0_POS]"],
                ["xbrk_ctrl2[$xbrk_ctrl_goto1_bit]"=>"jdo[$BREAK_B_GOTO1_POS]"],
                ],
              }),
              e_if->new ({
                condition => "(break_b_rr == 2'b11) && ($oci_num_dbrk >= 4)",
                then  => [
                ["xbrk_ctrl3[$xbrk_ctrl_brk_bit]" => "jdo[$BREAK_B_BRK_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_tout_bit]"=>"jdo[$BREAK_B_TOUT_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_toff_bit]"=>"jdo[$BREAK_B_TOFF_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_ton_bit]" => "jdo[$BREAK_B_TON_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_arm0_bit]"=>"jdo[$BREAK_B_ARM0_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_arm1_bit]"=>"jdo[$BREAK_B_ARM1_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_goto0_bit]"=>"jdo[$BREAK_B_GOTO0_POS]"],
                ["xbrk_ctrl3[$xbrk_ctrl_goto1_bit]"=>"jdo[$BREAK_B_GOTO1_POS]"],
                ],
              }),
            ],
        }), # end if (b)
      ], # end contents
    }),
  );  # end module->add_contents







  if ($oci_num_dbrk >= 1) {
    $module->add_contents (
       e_signal->news (
         ["dbrk0",               78,                       1],
       ),

       e_process->new ({
         clock     => "clk",
         user_attributes_names => ["dbrk_hit0_latch"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101)],
           },
         ],
         contents  => [
           e_if->new ({
             condition => "take_action_any_break",
             then => [ 
               e_assign->news (
                   ["dbrk_hit0_latch"  => "1'b0"],
               ),
             ], 
             else => [
               e_if->new ({
                 condition => "dbrk_hit0 & dbrk0[$dbrk_break_bit]",
                 then => [ 
                   ["dbrk_hit0_latch"  => "1'b1"],
                 ],
               }),
             ],
           }),
         ],
       }),
       e_process->new ({
         clock     => "clk",
         reset     => "jrst_n",
         user_attributes_names => ["dbrk0"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101 R101)],
           },
         ],
         asynchronous_contents => [
            e_assign->new (["dbrk0" => "0"]),
         ], 
         contents  => [
            e_if->new ({
              condition => "(take_action_break_a && break_a_wpr_low_bits == 2'b00)",
              then => [ 
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 2)",
                    then => [
                      e_assign->new ( ["dbrk0[$dbrk_addr_high : 0]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 3)",
                    then => [
                      e_assign->new (["dbrk0[$dbrk_data_high :32]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
              ],
              elsif => {
                condition => "(take_action_break_c && break_c_rr == 2'b00)",
                then => [ 
                  ["dbrk0[$dbrk_writeenb_bit]"=> "jdo[$BREAK_C_ST_POS ]"],
                  ["dbrk0[$dbrk_readenb_bit ]"=> "jdo[$BREAK_C_LD_POS ]"],
                  ["dbrk0[$dbrk_addrused_bit]"=> "jdo[$BREAK_C_AU_POS ]"],
                  ["dbrk0[$dbrk_dataused_bit]"=> "jdo[$BREAK_C_DU_POS ]"],
                  ["dbrk0[$dbrk_break_bit   ]"=> "jdo[$BREAK_C_BRK_POS]"],
                  ["dbrk0[$dbrk_trigout_bit ]"=> "jdo[$BREAK_C_TOUT_POS]"],
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_pairs})",
                    then => [ 
                      ["dbrk0[$dbrk_paired_bit  ]"=> "jdo[$BREAK_C_PAIR_POS]"],
                    ],
                  }),
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_trace})",
                    then => [ 
                      ["dbrk0[$dbrk_traceoff_bit]"=> "jdo[$BREAK_C_TOFF_POS]"],
                      ["dbrk0[$dbrk_traceon_bit ]"=> "jdo[$BREAK_C_TON_POS ]"],
                      ["dbrk0[$dbrk_traceme_bit ]"=> "jdo[$BREAK_C_TME_POS ]"],
                    ],
                  }),
                  ["dbrk0[$dbrk_arm0_bit]"=>"jdo[$BREAK_C_ARM0_POS]"],
                  ["dbrk0[$dbrk_arm1_bit]"=>"jdo[$BREAK_C_ARM1_POS]"],
                  ["dbrk0[$dbrk_goto0_bit]"=>"jdo[$BREAK_C_GOTO0_POS]"],
                  ["dbrk0[$dbrk_goto1_bit]"=>"jdo[$BREAK_C_GOTO1_POS]"],
                ], # end of then
               }, # end of elsif
              }),  #end of e_if
         ],  #end of contents
      }), #end of e_process
      e_assign->new (["dbrk0_low_value"  => "dbrk0[$dbrk_addr_high : 0]"]),
      e_assign->new (["dbrk0_high_value" => "dbrk0[$dbrk_data_high : 32]"]),
    
    ); #end module add contents for dbrk0
  } else { #end if oci_num_dbrk >= 1
    $module->add_contents (
      e_assign->new (["dbrk_hit0_latch"  => "1'b0"]),
      e_assign->new (["dbrk0_low_value"  => "0"]),
      e_assign->new (["dbrk0_high_value" => "0"]),
    );
  };

  if ($oci_num_dbrk >= 2) {
    $module->add_contents (
       e_signal->news (
         ["dbrk1",               78,                       1],
       ),

       e_process->new ({
         clock     => "clk",
         user_attributes_names => ["dbrk_hit1_latch"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101)],
           },
         ],
         contents  => [
           e_if->new ({
             condition => "take_action_any_break",
             then => [ 
               e_assign->news (
                   ["dbrk_hit1_latch"  => "1'b0"],
               ),
             ], 
             else => [
               e_if->new ({
                 condition => "dbrk_hit1 & dbrk1[$dbrk_break_bit]",
                 then => [ 
                   ["dbrk_hit1_latch"  => "1'b1"],
                 ],
               }),
             ],
           }),
         ],
       }),
       e_process->new ({
         clock     => "clk",
         reset     => "jrst_n",
         user_attributes_names => ["dbrk1"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101 R101)],
           },
         ],
         asynchronous_contents => [
            e_assign->new (["dbrk1" => "0"]),
         ], 
         contents  => [
            e_if->new ({
              condition => "(take_action_break_a && break_a_wpr_low_bits == 2'b01)",
              then => [ 
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 2)",
                    then => [
                      e_assign->new ( ["dbrk1[$dbrk_addr_high : 0]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 3)",
                    then => [
                      e_assign->new (["dbrk1[$dbrk_data_high :32]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
              ],
              elsif => {
                condition => "(take_action_break_c && break_c_rr == 2'b01)",
                then => [ 
                  ["dbrk1[$dbrk_writeenb_bit]"=> "jdo[$BREAK_C_ST_POS ]"],
                  ["dbrk1[$dbrk_readenb_bit ]"=> "jdo[$BREAK_C_LD_POS ]"],
                  ["dbrk1[$dbrk_addrused_bit]"=> "jdo[$BREAK_C_AU_POS ]"],
                  ["dbrk1[$dbrk_dataused_bit]"=> "jdo[$BREAK_C_DU_POS ]"],
                  ["dbrk1[$dbrk_break_bit   ]"=> "jdo[$BREAK_C_BRK_POS]"],
                  ["dbrk1[$dbrk_trigout_bit ]"=> "jdo[$BREAK_C_TOUT_POS]"],
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_pairs})",
                    then => [ 
                      ["dbrk1[$dbrk_paired_bit  ]"=> "jdo[$BREAK_C_PAIR_POS]"],
                    ],
                  }),
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_trace})",
                    then => [ 
                      ["dbrk1[$dbrk_traceoff_bit]"=> "jdo[$BREAK_C_TOFF_POS]"],
                      ["dbrk1[$dbrk_traceon_bit ]"=> "jdo[$BREAK_C_TON_POS ]"],
                      ["dbrk1[$dbrk_traceme_bit ]"=> "jdo[$BREAK_C_TME_POS ]"],
                    ],
                  }),
                  ["dbrk1[$dbrk_arm0_bit]"=>"jdo[$BREAK_C_ARM0_POS]"],
                  ["dbrk1[$dbrk_arm1_bit]"=>"jdo[$BREAK_C_ARM1_POS]"],
                  ["dbrk1[$dbrk_goto0_bit]"=>"jdo[$BREAK_C_GOTO0_POS]"],
                  ["dbrk1[$dbrk_goto1_bit]"=>"jdo[$BREAK_C_GOTO1_POS]"],
                ], # end of then
               }, # end of elsif
              }),  #end of e_if
         ],  #end of contents
      }), #end of e_process
      e_assign->new (["dbrk1_low_value"  => "dbrk1[$dbrk_addr_high : 0]"]),
      e_assign->new (["dbrk1_high_value" => "dbrk1[$dbrk_data_high : 32]"]),
    
    ); #end module add contents for dbrk1
  } else { #end if oci_num_dbrk >= 2
    $module->add_contents (
      e_assign->new (["dbrk_hit1_latch"  => "1'b0"]),
      e_assign->new (["dbrk1_low_value"  => "0"]),
      e_assign->new (["dbrk1_high_value" => "0"]),
    );
  };

  if ($oci_num_dbrk >= 3) {
    $module->add_contents (
       e_signal->news (
         ["dbrk2",               78,                       1],
       ),

       e_process->new ({
         clock     => "clk",
         user_attributes_names => ["dbrk_hit2_latch"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101)],
           },
         ],
         contents  => [
           e_if->new ({
             condition => "take_action_any_break",
             then => [ 
               e_assign->news (
                   ["dbrk_hit2_latch"  => "1'b0"],
               ),
             ], 
             else => [
               e_if->new ({
                 condition => "dbrk_hit2 & dbrk2[$dbrk_break_bit]",
                 then => [ 
                   ["dbrk_hit2_latch"  => "1'b1"],
                 ],
               }),
             ],
           }),
         ],
       }),
       e_process->new ({
         clock     => "clk",
         reset     => "jrst_n",
         user_attributes_names => ["dbrk2"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101 R101)],
           },
         ],
         asynchronous_contents => [
            e_assign->new (["dbrk2" => "0"]),
         ], 
         contents  => [
            e_if->new ({
              condition => "(take_action_break_a && break_a_wpr_low_bits == 2'b10)",
              then => [ 
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 2)",
                    then => [
                      e_assign->new ( ["dbrk2[$dbrk_addr_high : 0]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 3)",
                    then => [
                      e_assign->new (["dbrk2[$dbrk_data_high :32]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
              ],
              elsif => {
                condition => "(take_action_break_c && break_c_rr == 2'b10)",
                then => [ 
                  ["dbrk2[$dbrk_writeenb_bit]"=> "jdo[$BREAK_C_ST_POS ]"],
                  ["dbrk2[$dbrk_readenb_bit ]"=> "jdo[$BREAK_C_LD_POS ]"],
                  ["dbrk2[$dbrk_addrused_bit]"=> "jdo[$BREAK_C_AU_POS ]"],
                  ["dbrk2[$dbrk_dataused_bit]"=> "jdo[$BREAK_C_DU_POS ]"],
                  ["dbrk2[$dbrk_break_bit   ]"=> "jdo[$BREAK_C_BRK_POS]"],
                  ["dbrk2[$dbrk_trigout_bit ]"=> "jdo[$BREAK_C_TOUT_POS]"],
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_pairs})",
                    then => [ 
                      ["dbrk2[$dbrk_paired_bit  ]"=> "jdo[$BREAK_C_PAIR_POS]"],
                    ],
                  }),
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_trace})",
                    then => [ 
                      ["dbrk2[$dbrk_traceoff_bit]"=> "jdo[$BREAK_C_TOFF_POS]"],
                      ["dbrk2[$dbrk_traceon_bit ]"=> "jdo[$BREAK_C_TON_POS ]"],
                      ["dbrk2[$dbrk_traceme_bit ]"=> "jdo[$BREAK_C_TME_POS ]"],
                    ],
                  }),
                  ["dbrk2[$dbrk_arm0_bit]"=>"jdo[$BREAK_C_ARM0_POS]"],
                  ["dbrk2[$dbrk_arm1_bit]"=>"jdo[$BREAK_C_ARM1_POS]"],
                  ["dbrk2[$dbrk_goto0_bit]"=>"jdo[$BREAK_C_GOTO0_POS]"],
                  ["dbrk2[$dbrk_goto1_bit]"=>"jdo[$BREAK_C_GOTO1_POS]"],
                ], # end of then
               }, # end of elsif
              }),  #end of e_if
         ],  #end of contents
      }), #end of e_process
      e_assign->new (["dbrk2_low_value"  => "dbrk2[$dbrk_addr_high : 0]"]),
      e_assign->new (["dbrk2_high_value" => "dbrk2[$dbrk_data_high : 32]"]),
    
    ); #end module add contents for dbrk2
  } else { #end if oci_num_dbrk >= 3
    $module->add_contents (
      e_assign->new (["dbrk_hit2_latch"  => "1'b0"]),
      e_assign->new (["dbrk2_low_value"  => "0"]),
      e_assign->new (["dbrk2_high_value" => "0"]),
    );
  };

  if ($oci_num_dbrk >= 4) {
    $module->add_contents (
       e_signal->news (
         ["dbrk3",               78,                       1],
       ),

       e_process->new ({
         clock     => "clk",
         user_attributes_names => ["dbrk_hit3_latch"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101)],
           },
         ],
         contents  => [
           e_if->new ({
             condition => "take_action_any_break",
             then => [ 
               e_assign->news (
                   ["dbrk_hit3_latch"  => "1'b0"],
               ),
             ], 
             else => [
               e_if->new ({
                 condition => "dbrk_hit3 & dbrk3[$dbrk_break_bit]",
                 then => [ 
                   ["dbrk_hit3_latch"  => "1'b1"],
                 ],
               }),
             ],
           }),
         ],
       }),
       e_process->new ({
         clock     => "clk",
         reset     => "jrst_n",
         user_attributes_names => ["dbrk3"],
         user_attributes => [
           {
             attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
             attribute_operator => '=',
             attribute_values => [qw(D101 R101)],
           },
         ],
         asynchronous_contents => [
            e_assign->new (["dbrk3" => "0"]),
         ], 
         contents  => [
            e_if->new ({
              condition => "(take_action_break_a && break_a_wpr_low_bits == 2'b11)",
              then => [ 
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 2)",
                    then => [
                      e_assign->new ( ["dbrk3[$dbrk_addr_high : 0]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
                 e_if-> new ({
                    condition=> "(break_a_wpr_high_bits == 3)",
                    then => [
                      e_assign->new (["dbrk3[$dbrk_data_high :32]" => 
                        "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                    ],
                 }),
              ],
              elsif => {
                condition => "(take_action_break_c && break_c_rr == 2'b11)",
                then => [ 
                  ["dbrk3[$dbrk_writeenb_bit]"=> "jdo[$BREAK_C_ST_POS ]"],
                  ["dbrk3[$dbrk_readenb_bit ]"=> "jdo[$BREAK_C_LD_POS ]"],
                  ["dbrk3[$dbrk_addrused_bit]"=> "jdo[$BREAK_C_AU_POS ]"],
                  ["dbrk3[$dbrk_dataused_bit]"=> "jdo[$BREAK_C_DU_POS ]"],
                  ["dbrk3[$dbrk_break_bit   ]"=> "jdo[$BREAK_C_BRK_POS]"],
                  ["dbrk3[$dbrk_trigout_bit ]"=> "jdo[$BREAK_C_TOUT_POS]"],
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_pairs})",
                    then => [ 
                      ["dbrk3[$dbrk_paired_bit  ]"=> "jdo[$BREAK_C_PAIR_POS]"],
                    ],
                  }),
                  e_if->new ({
                    condition => "($Opt->{oci_dbrk_trace})",
                    then => [ 
                      ["dbrk3[$dbrk_traceoff_bit]"=> "jdo[$BREAK_C_TOFF_POS]"],
                      ["dbrk3[$dbrk_traceon_bit ]"=> "jdo[$BREAK_C_TON_POS ]"],
                      ["dbrk3[$dbrk_traceme_bit ]"=> "jdo[$BREAK_C_TME_POS ]"],
                    ],
                  }),
                  ["dbrk3[$dbrk_arm0_bit]"=>"jdo[$BREAK_C_ARM0_POS]"],
                  ["dbrk3[$dbrk_arm1_bit]"=>"jdo[$BREAK_C_ARM1_POS]"],
                  ["dbrk3[$dbrk_goto0_bit]"=>"jdo[$BREAK_C_GOTO0_POS]"],
                  ["dbrk3[$dbrk_goto1_bit]"=>"jdo[$BREAK_C_GOTO1_POS]"],
                ], # end of then
               }, # end of elsif
              }),  #end of e_if
         ],  #end of contents
      }), #end of e_process
      e_assign->new (["dbrk3_low_value"  => "dbrk3[$dbrk_addr_high : 0]"]),
      e_assign->new (["dbrk3_high_value" => "dbrk3[$dbrk_data_high : 32]"]),
    
    ); #end module add contents for dbrk3
  } else { #end if oci_num_dbrk >= 3
    $module->add_contents (
      e_assign->new (["dbrk_hit3_latch"  => "1'b0"]),
      e_assign->new (["dbrk3_low_value"  => "0"]),
      e_assign->new (["dbrk3_high_value" => "0"]),
    );
  };






  if ($oci_num_xbrk >= 1) {
    $module->add_contents (
       e_signal->news (
         ["xbrk0",               $xbrk_width,              1],
       ),
       e_process->new ({
          clock     => "clk",
          reset     => "jrst_n",
          user_attributes_names => ["xbrk0"],
          user_attributes => [
            {
              attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
              attribute_operator => '=',
              attribute_values => [qw(D101 R101)],
            },
          ],
          asynchronous_contents => [
            e_assign->new (["xbrk0" => "0"]),
          ],
          contents  => [
            e_if->new ({

              condition => "(take_action_break_a 
                 && (break_a_wpr_high_bits == 0) 
                 && (break_a_wpr_low_bits == 2'b00))",
              then => [ e_assign->new (
                        ["xbrk0[$xbrk_width-1 : 0]" => 
                          "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                      ],
            }),
          ],
       }), # end e_process
    
       e_assign->new (["xbrk0_value" => "xbrk0"]),

    );
  } else {
    $module->add_contents (
       e_assign->new (["xbrk0_value" => "32'b0"]),

    );
  }

  if ($oci_num_xbrk >= 2) {
    $module->add_contents (
       e_signal->news (
         ["xbrk1",               $xbrk_width,              1],
       ),
       e_process->new ({
          clock     => "clk",
          reset     => "jrst_n",
          user_attributes_names => ["xbrk1"],
          user_attributes => [
            {
              attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
              attribute_operator => '=',
              attribute_values => [qw(D101 R101)],
            },
          ],
          asynchronous_contents => [
            e_assign->new (["xbrk1" => "0"]),
          ],
          contents  => [
            e_if->new ({

              condition => "(take_action_break_a 
                 && (break_a_wpr_high_bits == 0) 
                 && (break_a_wpr_low_bits == 2'b01))",
              then => [ e_assign->new (
                        ["xbrk1[$xbrk_width-1 : 0]" => 
                          "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                      ],
            }),
          ],
       }), # end e_process
       e_assign->new (["xbrk1_value" => "xbrk1"]),
    
    );
  } else {
    $module->add_contents (
       e_assign->new (["xbrk1_value" => "32'b0"]),
    
    );
  }


  if ($oci_num_xbrk >= 3) {
    $module->add_contents (
       e_signal->news (
         ["xbrk2",               $xbrk_width,              1],
       ),
       e_process->new ({
          clock     => "clk",
          reset     => "jrst_n",
          user_attributes_names => ["xbrk2"],
          user_attributes => [
            {
              attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
              attribute_operator => '=',
              attribute_values => [qw(D101 R101)],
            },
          ],
          asynchronous_contents => [
            e_assign->new (["xbrk2" => "0"]),
          ],
          contents  => [
            e_if->new ({

              condition => "(take_action_break_a 
                 && (break_a_wpr_high_bits == 0) 
                 && (break_a_wpr_low_bits == 2'b10))",
              then => [ e_assign->new (
                        ["xbrk2[$xbrk_width-1 : 0]" => 
                          "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                      ],
            }),
          ],
       }), # end e_process
       e_assign->new (["xbrk2_value" => "xbrk2"]),
    
    );
  } else {
    $module->add_contents (
       e_assign->new (["xbrk2_value" => "32'b0"]),
    
    );
  }


  if ($oci_num_xbrk >= 4) {
    $module->add_contents (
       e_signal->news (
         ["xbrk3",               $xbrk_width,              1],
       ),
       e_process->new ({
          clock     => "clk",
          reset     => "jrst_n",
          user_attributes_names => ["xbrk3"],
          user_attributes => [
            {
              attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
              attribute_operator => '=',
              attribute_values => [qw(D101 R101)],
            },
          ],
          asynchronous_contents => [
            e_assign->new (["xbrk3" => "0"]),
          ],
          contents  => [
            e_if->new ({

              condition => "(take_action_break_a 
                 && (break_a_wpr_high_bits == 0) 
                 && (break_a_wpr_low_bits == 2'b11))",
              then => [ e_assign->new (
                        ["xbrk3[$xbrk_width-1 : 0]" => 
                          "jdo[$BREAK_A_WRDATA_MSB_POS:$BREAK_A_WRDATA_LSB_POS]"]) 
                      ],
            }),
          ],
       }), # end e_process
       e_assign->new (["xbrk3_value" => "xbrk3"]),
    
    );
  } else {
    $module->add_contents (
       e_assign->new (["xbrk3_value" => "32'b0"]),

    );
  }







  $module->add_contents (   
    e_signal->news (
      ["break_readreg",   32],
    ),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["break_readreg"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->new ([break_readreg  => "32'b0"]),
      ],
      contents  => [



        e_if->new ({
          condition => "take_action_any_break",
          then => [ 
            [break_readreg  => "jdo[31:0]"],
          ],
          elsif => {



            condition => "(take_no_action_break_a)",
            then => [ 
              e_case->new ({
                switch    => "break_a_wpr_high_bits",
                parallel  => 0,
                full      => 0,
                contents  => {

                  0 => [
                    e_case->new ({
                      switch    => "break_a_wpr_low_bits",
                      parallel  => 0,
                      full      => 1,
                      contents  => {
                        0 => [ [break_readreg => "xbrk0_value"], ],
                        1 => [ [break_readreg => "xbrk1_value"], ],
                        2 => [ [break_readreg => "xbrk2_value"], ],
                        3 => [ [break_readreg => "xbrk3_value"], ],
                      },
                    }),
                  ],


                  1 => [
                    e_assign->new ([break_readreg  => "32'b0"]),
                  ],


                  2 => [
                    e_case->new ({
                      switch    => "break_a_wpr_low_bits",
                      parallel  => 0,
                      full      => 1,
                      contents  => {
                        0 => [ [break_readreg => "dbrk0_low_value"], ],
                        1 => [ [break_readreg => "dbrk1_low_value"], ],
                        2 => [ [break_readreg => "dbrk2_low_value"], ],
                        3 => [ [break_readreg => "dbrk3_low_value"], ],
                        },
                    }),
                  ],
                  

                  3 => [
                    e_case->new ({
                      switch    => "break_a_wpr_low_bits",
                      parallel  => 0,
                      full      => 1,
                      contents  => {
                        0 => [ [break_readreg => "dbrk0_high_value"], ],
                        1 => [ [break_readreg => "dbrk1_high_value"], ],
                        2 => [ [break_readreg => "dbrk2_high_value"], ],
                        3 => [ [break_readreg => "dbrk3_high_value"], ],
                      },
                    }),
                  ],
                },
              }),
            ],
            elsif => {



              condition => "(take_no_action_break_b)",
              then    => [

                [break_readreg  => "jdo[31:0]"],
              ],
              elsif => {



                condition => "(take_no_action_break_c)",
                then    => [

                  [break_readreg  => "jdo[31:0]"],
                ], # end take action (c)
              } # end elsif (c)
            } # end elsif (b)
          }, # end elsif (a)
        }), # end if (any action)
      ], # end contents
    }),

  );








  if ($Opt->{oci_trigger_arming}) {
    $module->add_contents (   
      e_register->news (
        { out         => ["trigger_state", 1, 0, 1] ,
          sync_set    => "(trigger_state_0 & (xbrk_goto1 | dbrk_goto1))",
          sync_reset  => "(trigger_state_1 & (xbrk_goto0 | dbrk_goto0))",
          async_value => 0,
          enable      => "1",
        },
      ),
      e_assign->news (
        [["trigger_state_0", 1, 1, 0], "~trigger_state"],
        [["trigger_state_1", 1, 1 ,0], " trigger_state"],
      ),
    );
  } else {  # no trigger arming, no trigger states



    $module->get_and_set_thing_by_name({
      thing => "mux",
      lhs   => ["dummy_sink", 1, 0, 1],
      name  => "dummy sink",
      type  => "and_or",
      add_table => ["xbrk_goto1", "xbrk_goto1",
                    "xbrk_goto0", "xbrk_goto0",
                    "dbrk_goto1", "dbrk_goto1",
                    "dbrk_goto0", "dbrk_goto0",
                   ],
    });


    $module->add_contents (   
      e_assign->news (
        [["trigger_state_0", 1, 1, 0], "1'b1"],
        [["trigger_state_1", 1, 1 ,0], "1'b0"],
      ),
    );
  }

  return $module;
}



1;


