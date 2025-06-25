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





sub make_nios2_oci_jtag_tck
{
  my $Opt = shift;

  my $jtag_module_name =  $Opt->{name}."_jtag_debug_module_tck";
  my $jtag_file_name =  $jtag_module_name;



  my $oci_tck_sync_depth = 2; 

  my $module = e_module->new ({
      name    => $jtag_module_name,
      output_file => $jtag_file_name,
  });


  $module->add_contents (

    e_signal->news (

      ["jrst_n",    1,    1],
    ),
  );


  $module->add_contents (
    e_port->news (
      ["tck",     1,  "in"],
      ["tdi",     1,  "in"],
      ["tdo",     1,  "out"],
      ["vs_uir",     1,  "in"],
      ["vs_cdr",     1,  "in"],
      ["vs_sdr",     1,  "in"],
      ["ir_in",       $IR_WIDTH,    "in"],
      ["ir_out",      $IR_WIDTH,    "out"],
      ["sr",          $SR_WIDTH,    "out"],
      ["jtag_state_rti",     1,  "in"],
    ),
  );

  $module->add_contents (

    e_signal->news (
      ["DRsize",                3,    0,  1],
    ),
  );







  










  my $state_process = e_process->new ({
    clock     => "tck",
    user_attributes_names => ["sr", "DRSize"],
    user_attributes => [
      {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => [qw(D101 D103 R101)],
      },
    ],
    contents  => [




      e_if->new ({ 
          condition => "(vs_cdr)",
          then    => [
            e_case->new ({
              switch => "ir_in",
              parallel  => 0,
              full      => 0,
              contents  => {
                $IRC_OCIMEM   => [
                  ["sr[$OCIMEM_DA_POS]" => "debugack_sync"],
                  ["sr[$OCIMEM_ER_POS]" => "monitor_error"],
                  ["sr[$OCIMEM_RST_POS]" => "resetlatch"],
                  ["sr[$OCIMEM_RDDATA_MSB_POS:$OCIMEM_RDDATA_LSB_POS]" 
                      => "MonDReg"],
                  ["sr[$OCIMEM_MR_POS]" => "monitor_ready_sync"],
                ],
                $IRC_TRACEMEM => [
                  ["sr[$TRACEMEM_RDDATA_MSB_POS:$TRACEMEM_RDDATA_LSB_POS]" 
                      => "tracemem_trcdata"],
                  ["sr[$TRACEMEM_TW_POS]" => "tracemem_tw"],
                  ["sr[$TRACEMEM_ON_POS]" => "tracemem_on"],
                ],
                $IRC_BREAK    => [
                  ["sr[$BREAK_TS_POS]" => "trigger_state_1"], 
                  ["sr[$BREAK_W3_POS]" => "dbrk_hit3_latch"],
                  ["sr[$BREAK_W2_POS]" => "dbrk_hit2_latch"],
                  ["sr[$BREAK_W1_POS]" => "dbrk_hit1_latch"],
                  ["sr[$BREAK_W0_POS]" => "dbrk_hit0_latch"],
                  ["sr[$BREAK_RDDATA_MSB_POS:$BREAK_RDDATA_LSB_POS]" 
                      => "break_readreg"],
                  ["sr[$BREAK_TB_POS]" => "trigbrktype"],
                ],
                $IRC_TRACECTRL  => [
                  ["sr[$TRACECTRL_TRCACQADDR_BITS]" => "trc_im_addr"], 
                  ["sr[$TRACECTRL_TW_POS]" => "trc_wrap"], 
                  ["sr[$TRACECTRL_ON_POS]" => "trc_on"], 
                ],
              },
            }), # end of case
          ],  # end of then
        }),  # end of e_if


      e_if->new ({ 
          condition => "(vs_sdr)",   # ST_SHIFTDR
          then    => [
            e_case->new ({
              switch => "DRsize",
              parallel  => 0,
              full      => 0,
              contents => {
                $SZ_1 =>  ["sr" => "{tdi, sr[$SR_MSB: 2], tdi}"],
                $SZ_8 =>  ["sr" => "{tdi, sr[$SR_MSB: 9], tdi, sr[ 7:1]}"],
                $SZ_16 => ["sr" => "{tdi, sr[$SR_MSB:17], tdi, sr[15:1]}"],
                $SZ_32 => ["sr" => "{tdi, sr[$SR_MSB:33], tdi, sr[31:1]}"],
                $SZ_36 => ["sr" => "{tdi, sr[37],         tdi, sr[35:1]}"],
                $SZ_38 => ["sr" => "{tdi, sr[$SR_MSB: 1]}"],
                default =>["sr" => "{tdi, sr[$SR_MSB: 2], tdi}"],
              },
            }),
          ],  # end of then
        }),  # end of e_if for sdr


      e_if->new ({ 
         condition => "(vs_uir)",   # ST_UPDATEIR
         then    => [
           e_case->new ({
             switch    => "ir_in",
             parallel  => 0,
             full      => 0,
             contents  => {
               $IRC_OCIMEM     => ["DRsize" => "$SZ_OCIMEM"],
               $IRC_TRACEMEM   => ["DRsize" => "$SZ_TRACEMEM"],
               $IRC_BREAK      => ["DRsize" => "$SZ_BREAK"],
               $IRC_TRACECTRL  => ["DRsize" => "$SZ_TRACECTRL"],
             },
           }),
         ],
      }), #end of e_if for uir

    ], # end of e_process contents
  }); # end of e_process


  if (manditory_bool($Opt, "asic_enabled")) {
    $state_process->set({
      reset     => "jrst_n",
      asynchronous_contents => [
        e_assign->news (
          ["sr" => "0"],
          ["DRsize" => "0"],
        ),
      ],
    });
  }

  my @europa_objects;

  push(@europa_objects,








    $state_process,


    e_assign->new (["tdo" => "sr[0]"]),



    e_assign->new (["st_ready_test_idle" => "jtag_state_rti"]),
            





   

    e_std_synchronizer->new({
      data_in  => "debugack",
      data_out => "debugack_sync",
      clock    => "tck",
      reset    => "~jrst_n",
      depth => $oci_tck_sync_depth, # default 2, larger if desired.
    }),
    e_std_synchronizer->new({
      data_in  => "monitor_ready",
      data_out => "monitor_ready_sync",
      clock    => "tck",
      reset    => "~jrst_n",
      depth => $oci_tck_sync_depth, # default 2, larger if desired.
    }),

    e_process->new ({
      clock     => "tck",
      reset     => "jrst_n",
      asynchronous_contents => [
        e_assign->news (
          ["ir_out" => "2'b0"],
        ),
      ],
      contents  => [
        e_assign->news (
          ["ir_out" => "{debugack_sync, monitor_ready_sync}"],
        ),
      ],
    }),

  ); #end of push

  if (manditory_bool($Opt, "asic_enabled")) {
    push(@europa_objects,
      e_assign->new ({
        lhs => "jrst_n",
        rhs => "clrn",
        tag => "synthesis",
      }),
    );
  } else {
    push(@europa_objects,
      e_assign->new ({
        lhs => "jrst_n",
        rhs => "1",      # setting it to 1.  Used to be jtag clrn which was never asserted
        tag => "synthesis",
      }),
    );
  }



  push(@europa_objects,
    e_assign->new ({
      lhs => "jrst_n",
      rhs => "reset_n",
      tag => "simulation",
    }),
  );

  $module->add_contents (@europa_objects);

  return $module;
}

1;



