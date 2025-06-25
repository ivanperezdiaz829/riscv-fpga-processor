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
use nios_common;
use europa_all;
use strict;

sub make_nios2_oci_debug
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_debug",
  });




  my $oci_reset_sync_depth = 2; 



  $module->add_contents (

    e_signal->news (
      ["resetrequest",          1,    1],   # export past top level?
      ["resetlatch",            1,    1],
      ["debugack",              1,    1],
      ["monitor_error",         1,    1],
      ["monitor_ready",         1,    1],
      ["monitor_go",            1,    1],
    ),

    e_signal->news (
      ["ir",            $IR_WIDTH,    0],
      ["jdo",           $SR_WIDTH,    0],
      ["reset",                 1,    0],
    ),

    
  );


  if ($advanced_exc) {
    $module->add_contents (
      e_signal->news (
        ["oci_sync_hbreak_req",        1,    1],
        ["oci_async_hbreak_req",        1,    1],
      ),
    ),
  } else {
    $module->add_contents (
      e_signal->news (
        ["oci_hbreak_req",        1,    1],
      ),
    ),
  }






  my @reset_irq_dbg_mode_async = (
    ["break_on_reset"  => "1'b0"],
    ["resetrequest" => "1'b0"],
    ["jtag_break"   => "1'b0"],
  );

  if (manditory_bool($Opt, "asic_enabled")) {


    push(@reset_irq_dbg_mode_async,
      ["resetlatch"   => "1'b0"],
    );
  }

  $module->add_contents (



























    e_std_synchronizer->new({
      data_in  => "reset",
      data_out => "reset_sync",
      clock    => "clk",
      reset    => "~jrst_n",
      depth => $oci_reset_sync_depth,
    }),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => [
        "break_on_reset","resetlatch","resetrequest","jtag_break"
      ],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news ( @reset_irq_dbg_mode_async ),
      ],
      contents  => [
        e_if->new ({ condition => "take_action_ocimem_a", then => [ 
            e_assign->news (














                ["resetrequest" => "jdo[$OCIMEM_A_RSTR_POS]"],




                ["jtag_break" => 
                  "jdo[$OCIMEM_A_DRS_POS]     ? 1 
                    : jdo[$OCIMEM_A_DRC_POS]  ? 0 
                    : jtag_break"],








                ["break_on_reset" => 
                  "jdo[$OCIMEM_A_BRSTS_POS]     ? 1
                    : jdo[$OCIMEM_A_BRSTC_POS]  ? 0
                    :  break_on_reset"],


                ["resetlatch" => "jdo[$OCIMEM_A_RSTC_POS] ? 0 : resetlatch"],
            ),
        ], else => [ e_if->new ({ condition => "reset_sync", then => [ 




            ["jtag_break" => "break_on_reset"],
                 




            ["resetlatch" => "1"],
        ], else => [ e_if->new ({ condition => "debugreq & ~debugack & break_on_reset", then => [ 














            e_assign->new (["jtag_break" => "1'b1"]),
        ],
        }),   # end of if
        ],    # end of else
        }),   # end of if
        ],  # end of else
        }), # end of if
      ], # end of contents
    }), # end of process


    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["monitor_ready","monitor_error","monitor_go"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["monitor_ready"  => "1'b0"],
          ["monitor_error" => "1'b0"],
          ["monitor_go"   => "1'b0"],
        ),
      ],

      contents  => [
        e_if->new ({ condition => "take_action_ocimem_a && jdo[$OCIMEM_A_MRC_POS]", then => [ 
            e_assign->news (
                ["monitor_ready" => "1'b0"],
            ),
        ], elsif => { condition => "take_action_ocireg && ocireg_mrs", then => [
            ["monitor_ready" => "1'b1"],
        ],
        },
        }),

        e_if->new ({ condition => "take_action_ocimem_a && jdo[$OCIMEM_A_MRC_POS]", then => [ 
            e_assign->news (
                ["monitor_error" => "1'b0"],
            ),
        ], elsif => { condition => "take_action_ocireg && ocireg_ers", then => [
            ["monitor_error" => "1'b1"],
        ],
        },
        }),

        e_if->new ({ condition => "take_action_ocimem_a && jdo[$OCIMEM_A_GOS_POS]", then => [ 
            e_assign->news (
                ["monitor_go" => "1'b1"],
            ),
        ], elsif => { condition => "st_ready_test_idle", then => [
            ["monitor_go" => "1'b0"],
        ],
        },
        }),

      ], # end of contents
    }), # end of process
  );  # end of add_contents




  if ($advanced_exc) {
    $module->add_contents (
      e_assign->news (
        ["oci_async_hbreak_req" => "jtag_break | dbrk_break | debugreq"],
        ["oci_sync_hbreak_req" => "xbrk_break"],
        ["debugack"       => "~hbreak_enabled"],
      ),
    )
  } else {
    $module->add_contents (
      e_assign->news (
        ["oci_hbreak_req" => "jtag_break | dbrk_break | xbrk_break | debugreq"],
        ["debugack"       => "~hbreak_enabled"],
      ),
    ),
  };
  return $module;
}

1;


