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
use e_std_synchronizer;
use strict;





sub make_nios2_oci_jtag_sysclk
{
  my $Opt = shift;

  my $sysclk_module_name =  $Opt->{name}."_jtag_debug_module_sysclk";
  my $jtag_file_name =  $sysclk_module_name;

  my $oci_sync_depth = $Opt->{oci_sync_depth};

  my $sysclk_module = e_module->new ({
      name    => $sysclk_module_name,
      output_file => $jtag_file_name,
  });


  $sysclk_module->add_contents (

    e_signal->news (

      ["jdo",       $SR_WIDTH,    1],
    ),

    e_signal->news (
      ["MonDReg",       32,   0],
      ["tracemem_trcdata",   $Opt->{oci_tm_width},         0,], 
    ),
  );

  $sysclk_module->add_contents (

    e_signal->news (
      ["ir",            $IR_WIDTH,    0,  1],
      ["dummy_sink",            1,    0,  1],
    ),
  );


  my $strobes = e_process->new ({
    clock     => "clk",
    user_attributes_names => ["sync2_udr","sync2_uir"],
    user_attributes => [
      {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => [qw(D101 D103)],
      },
    ],
    contents  => [
      e_assign->news (

        ["sync2_udr"  => "sync_udr"], 
        ["update_jdo_strobe" => "sync_udr & ~sync2_udr"], 
        ["enable_action_strobe" => "update_jdo_strobe"], 
        ["sync2_uir"  => "sync_uir"], 
        ["jxuir" => "sync_uir & ~sync2_uir"], 
      ),
    ],
  });

  if (manditory_bool($Opt, "asic_enabled")) {
    $strobes->set ({
      reset     => "jrst_n",
      asynchronous_contents => [
        e_assign->news (
          ["sync2_udr"            => "0"],
          ["sync2_uir"            => "0"],
          ["update_jdo_strobe"    => "0"],
          ["enable_action_strobe" => "0"],
          ["jxuir"                => "0"],
        ),
      ],
    });
  }

  my @sysclk_europa_objects = (








    e_std_synchronizer->new({
      data_in  => "vs_udr",
      data_out => "sync_udr",
      clock    => "clk",
      reset    => "0",
      depth => $oci_sync_depth, # default 2, larger if desired.
    }),
    e_std_synchronizer->new({
      data_in  => "vs_uir",
      data_out => "sync_uir",
      clock    => "clk",
      reset    => "0",
      depth => $oci_sync_depth, # default 2, larger if desired.
    }),


	$strobes,



    e_assign->news (
      ["take_action_ocimem_a" => 
          "enable_action_strobe && (ir == $IRC_OCIMEM) && 
            ~jdo[$OCIMEM_A_OR_B_POS] && jdo[$OCIMEM_A_ACT_POS]"],
      ["take_no_action_ocimem_a" => 
          "enable_action_strobe && (ir == $IRC_OCIMEM) && 
            ~jdo[$OCIMEM_A_OR_B_POS] && ~jdo[$OCIMEM_A_ACT_POS]"],
      ["take_action_ocimem_b" => 
          "enable_action_strobe && (ir == $IRC_OCIMEM) && 
              jdo[$OCIMEM_A_OR_B_POS]"],

      ["take_action_tracemem_a" => 
          "enable_action_strobe && (ir == $IRC_TRACEMEM) &&
            ~jdo[$TRACEMEM_A_OR_B_POS] && 
            jdo[$TRACEMEM_A_ACT_POS] "], 
      ["take_no_action_tracemem_a" => 
          "enable_action_strobe && (ir == $IRC_TRACEMEM) &&
            ~jdo[$TRACEMEM_A_OR_B_POS] && 
            ~jdo[$TRACEMEM_A_ACT_POS] "], 
      ["take_action_tracemem_b" => 
          "enable_action_strobe && (ir == $IRC_TRACEMEM) &&
            jdo[$TRACEMEM_A_OR_B_POS] "], 

      ["take_action_break_a" => 
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            ~jdo[$BREAK_A_OR_B_C_POS] && 
            jdo[$BREAK_W_POS]"],
      ["take_no_action_break_a" =>           # nothing depends on this?
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            ~jdo[$BREAK_A_OR_B_C_POS] && 
            ~jdo[$BREAK_W_POS]"],
      ["take_action_break_b" => 
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            jdo[$BREAK_A_OR_B_C_POS] && ~jdo[$BREAK_B_OR_C_POS] &&
            jdo[$BREAK_W_POS]"],
      ["take_no_action_break_b" => 
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            jdo[$BREAK_A_OR_B_C_POS] && ~jdo[$BREAK_B_OR_C_POS] &&
            ~jdo[$BREAK_W_POS]"],
      ["take_action_break_c" => 
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            jdo[$BREAK_A_OR_B_C_POS] &&  jdo[$BREAK_B_OR_C_POS] &&
            jdo[$BREAK_W_POS]"],
      ["take_no_action_break_c" => 
          "enable_action_strobe && (ir == $IRC_BREAK) && 
            jdo[$BREAK_A_OR_B_C_POS] &&  jdo[$BREAK_B_OR_C_POS] &&
            ~jdo[$BREAK_W_POS]"],

      ["take_action_tracectrl" => 
          "enable_action_strobe && (ir == $IRC_TRACECTRL) &&  
            jdo[$TRACECTRL_ACT_POS]"], 



    ),
  );

  if (manditory_bool($Opt, "asic_enabled")) {
    push(@sysclk_europa_objects,


      e_assign->new ({
        lhs => "jrst_n",
        rhs => "clrn",
        tag => "synthesis",
      }),
      e_assign->new ({
        lhs => "jrst_n",
        rhs => "reset_n",
        tag => "simulation",
      }),
    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["ir"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["ir"  => "0"],
        ),
      ],
      contents  => [
        e_if->new ({
          condition => "(jxuir)",   # ST_UPDATEDR
          then    => [
            e_assign->new (["ir"    => "ir_in"]),
          ],
        }),
       ],
    }), #end of clk process
    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["jdo"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["jdo"  => "0"],
        ),
      ],
      contents  => [
        e_if->new ({
          condition => "(update_jdo_strobe)",   # ST_UPDATEDR
          then    => [
            e_assign->new (["jdo"    => "sr"]),
          ],
        }),
       ],
    }), #end of clk process
   );
  } else {


  push(@sysclk_europa_objects,

    e_process->new ({
      clock     => "clk",
      reset     => "reset_n",
      user_attributes_names => ["jdo"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      contents  => [
        e_if->new ({ 
          condition => "(jxuir)",   # ST_UPDATEDR
          then    => [
            e_assign->new (["ir"    => "ir_in"]),
          ],
        }),
        e_if->new ({ 
          condition => "(update_jdo_strobe)",   # ST_UPDATEDR
          then    => [
            e_assign->new (["jdo"    => "sr"]),
          ],
        }),
       ],
    }), #end of clk process
  ), #end of push
 }

  $sysclk_module->add_contents (@sysclk_europa_objects);
  
  return $sysclk_module;
}


1;



