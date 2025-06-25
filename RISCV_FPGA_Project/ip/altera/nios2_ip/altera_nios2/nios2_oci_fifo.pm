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
use nios2_common;
use strict;















sub 
make_nios2_oci_fifo
{
  my $Opt = shift;


  my $name = manditory_scalar($Opt, "name");
  my $oci_tm_width = manditory_int($Opt, "oci_tm_width");
  my $oci_fifo_addr_width = manditory_int($Opt, "oci_fifo_addr_width"); 
  my $oci_fifo_depth = 1 << $oci_fifo_addr_width;
  my $oci_data_trace = manditory_bool($Opt, "oci_data_trace");
  my $reset_addr = manditory_int($Opt, "reset_addr");

  my $module = e_module->new ({
      name    => $name."_nios2_oci_fifo",
  });



  $module->add_contents (

    e_signal->news (
      ["tw",  $oci_tm_width,1], # Output of FIFO - trace message at head of fifo
    ),

    e_signal->news (
      ["itm", $oci_tm_width,0], # instruction trace message written into fifo 
      ["atm", $oci_tm_width,0], # data address trace message written into fifo
      ["dtm", $oci_tm_width,0], # data value trace message written into fifo
      ["trc_ctrl", 16, 0],      # Trace control register
    ),

  );

  $module->add_contents (
    e_signal->news (
      ["fifo_head",         $oci_tm_width,             0,  1],  # output of FIFO (from fifo_read_mux)
      ["fifo_rdptr",        $oci_fifo_addr_width,      0,  1],  # read pointer
      ["fifo_wrptr",        $oci_fifo_addr_width,      0,  1],  # write pointer
      ["fifo_cnt",          $oci_fifo_addr_width + 1,  0,  1],  # number of entries in FIFO
      ["fifo_wrptr_plus1",  $oci_fifo_addr_width,      0,  1],
      ["fifo_wrptr_plus2",  $oci_fifo_addr_width,      0,  1],
      ["input_tm_cnt",      2,                         0,  1],  # 0-3 trace messages to write to FIFO
    ),
  );







  my $compute_input_tm_cnt_module = &make_nios2_compute_input_tm_cnt($name);
  my $fifo_wrptr_inc_module =       &make_nios2_fifo_wrptr_inc($name, $oci_fifo_addr_width);
  my $fifo_cnt_inc_module =    &make_nios2_fifo_cnt_inc($name, $oci_fifo_addr_width);
  my ($testbench_module, $testbench_module_name) = &make_oci_testbench($name, $oci_tm_width,
    $oci_data_trace, $reset_addr);

  $module->add_contents (

    e_assign->news (
      ["trc_this" => "trc_on ".               # trace is on
        "| (dbrk_traceon & ~dbrk_traceoff) ". # trace is about to turn on
        "| dbrk_traceme"],                    # trace one cycle

      ["itm_valid" => "|itm[".$oci_tm_width."-1 : ".$oci_tm_width."-4]"],
      ["atm_valid" => "|atm[".$oci_tm_width."-1 : ".$oci_tm_width."-4] & trc_this"],
      ["dtm_valid" => "|dtm[".$oci_tm_width."-1 : ".$oci_tm_width."-4] & trc_this"],


      ["ge2_free" => "~fifo_cnt[".$oci_fifo_addr_width."]"], 


      ["ge3_free" => "ge2_free & ~&fifo_cnt[".$oci_fifo_addr_width."-1:0]"], 

      ["empty" => "~|fifo_cnt"], # (fifo_cnt == 0)

      ["fifo_wrptr_plus1" => "fifo_wrptr + 1"],
      ["fifo_wrptr_plus2" => "fifo_wrptr + 2"],
    ),

    e_instance->new ({

      module  => $compute_input_tm_cnt_module,
      port_map  => {
        itm_valid               =>  "itm_valid",
        atm_valid               =>  "atm_valid",
        dtm_valid               =>  "dtm_valid",
        compute_input_tm_cnt    =>  "compute_input_tm_cnt",
      },
    }),
    e_assign->new ( ["input_tm_cnt" => "compute_input_tm_cnt"],),


    e_instance->new ({

      module  => $fifo_wrptr_inc_module,
      port_map  => {
        ge2_free        => "ge2_free",
        ge3_free        => "ge3_free",
        input_tm_cnt    => "input_tm_cnt",
        fifo_wrptr_inc  => "fifo_wrptr_inc",
      },
    }),
    e_instance->new ({

      module  => $fifo_cnt_inc_module,
      port_map  => {
        empty           => "empty",
        ge2_free        => "ge2_free",
        ge3_free        => "ge3_free",
        input_tm_cnt    => "input_tm_cnt",
        fifo_cnt_inc    => "fifo_cnt_inc",
      },
    }),
    e_instance->new ({

      module  => $testbench_module,
      port_map  => {
        itm_valid       =>  "itm_valid",
        itm             =>  "itm",
        atm_valid       =>  "atm_valid",
        atm             =>  "atm",
        dtm_valid       =>  "dtm_valid",
        dtm             =>  "dtm",
        trc_ctrl        =>  "trc_ctrl",
        test_ending     =>  "test_ending",
        test_has_ended  =>  "test_has_ended",
        dct_buffer      =>  "dct_buffer",
        dct_count       =>  "dct_count",
      },
    }),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["fifo_rdptr","fifo_wrptr","fifo_cnt","overflow_pending"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["fifo_rdptr" => "0"],
          ["fifo_wrptr" => "0"],
          ["fifo_cnt" => "0"],
          ["overflow_pending" => "1"],
        ),
      ],
      contents  => [
        e_assign->news (
          ["fifo_wrptr" => "fifo_wrptr + fifo_wrptr_inc"],
          ["fifo_cnt" => "fifo_cnt + fifo_cnt_inc"],
        ),
        e_if->new ({ condition => "~empty", then => [
          ["fifo_rdptr" => "fifo_rdptr + 1"]
        ],
        }),






        e_if->new ({ condition => "~trc_this || (~ge2_free & input_ge2) || (~ge3_free & input_ge3)", then => [ 
          ["overflow_pending" => "1"] 
        ], elsif => { condition => "atm_valid | dtm_valid", then => [ 

          ["overflow_pending" => "0"] 
        ],
        },
        }),
      ],
    }),

    e_assign->news (
      ["fifo_head" => "fifo_read_mux"],







      ["tw" => $oci_data_trace." ? ".
          " { (empty ? 4'h0 : fifo_head[".$oci_tm_width."-1 : ".$oci_tm_width."-4]),".
          "   fifo_head[".$oci_tm_width."-5:0]} ".
          " : itm"],
    ),












































  );  # end of add_contents





  my @fifo_registers = ();
  my @fifo_read_mux_table;
  for (my $i=0; $i < $oci_fifo_depth ; $i++) {
    my $const = $oci_fifo_addr_width . "'d" . $i;
    push (@fifo_registers, 
      e_signal->new ({
        name  => "fifo_$i",
        width => $oci_tm_width,
        never_export  => 1,
      }),
      e_signal->new ({
        name  => "fifo_$i\_enable",
        width => 1,
        never_export  => 1,
      }),
      e_assign->new ({
        lhs   => "fifo_$i\_enable",
        rhs   => "((fifo_wrptr == $const) && input_ge1)  || ".
                 "(ge2_free && (fifo_wrptr_plus1== $const) && input_ge2)  ||".
                 "(ge3_free && (fifo_wrptr_plus2== $const) && input_ge3)    ",
      }),
      e_register->new ({
        out => "fifo_$i",
        in  => "fifo_$i\_mux",
        enable  => "fifo_$i\_enable", 
        clock => "clk",
      }), 
      e_signal->new ({
        name  => "fifo_$i\_mux",
        width => $oci_tm_width,
        never_export  => 1,
      }),
      e_mux->new ({
        lhs   => "fifo_$i\_mux",
        table => [
          "(fifo_wrptr == $const) && itm_valid"     =>  "itm", 
          "(fifo_wrptr == $const) && atm_valid"     =>  "overflow_pending_atm", 
          "(fifo_wrptr == $const) && dtm_valid"     =>  "overflow_pending_dtm", 
          "(fifo_wrptr_plus1 == $const) && (ge2_free & itm_valid & atm_valid)"  => "overflow_pending_atm", 
          "(fifo_wrptr_plus1 == $const) && (ge2_free & itm_valid & dtm_valid)"  => "overflow_pending_dtm", 
          "(fifo_wrptr_plus1 == $const) && (ge2_free & atm_valid & dtm_valid)"  => "overflow_pending_dtm", 
          "(fifo_wrptr_plus2 == $const) && (ge3_free & itm_valid & atm_valid & dtm_valid)" => "overflow_pending_dtm", 
        ],





      }),
    );
    push (@fifo_read_mux_table,
      $const  => "fifo_$i",
    );
  }

  $module->add_contents (

    @fifo_registers,

    e_assign->news (
      [["input_ge1", 1, 0, 1], "|input_tm_cnt"  ], # 1, 2, or 3 messages
      [["input_ge2", 1, 0, 1], "input_tm_cnt[1]"], # 2 or 3 messages
      [["input_ge3", 1, 0, 1], "&input_tm_cnt"  ], # 3 messages

      [["overflow_pending_atm", $oci_tm_width],  "{overflow_pending, atm[".($oci_tm_width-2).":0]}"],
      [["overflow_pending_dtm", $oci_tm_width], "{overflow_pending, dtm[".($oci_tm_width-2).":0]}"],
    ),

    e_mux->new ({
      lhs     => ["fifo_read_mux", $oci_tm_width, 0, 1],
      selecto => "fifo_rdptr",
      table   => [@fifo_read_mux_table],
    }),
  );

  return $module;
} # end module make_nios2_oci_fifo




sub 
make_nios2_compute_input_tm_cnt
{
  my $name = shift;

  my $module = e_module->new ({
      name    => $name."_nios2_oci_compute_input_tm_cnt",
  });



  $module->add_contents (

    e_signal->news (
      ["itm_valid", 1, 0,], 
      ["atm_valid", 1, 0,], 
      ["dtm_valid", 1, 0,], 
      ["compute_input_tm_cnt", 2, 1,],
    ),
    e_assign->new ([
      ["switch_for_mux", 3, 0, 1], "{itm_valid, atm_valid, dtm_valid}"
    ]),
    e_process->new ({
      clock => "",
      contents  => [
        e_case->new ({
          switch  => "switch_for_mux",
          parallel  => 0,
          full      => 0,
          contents  => {   
            "3'b000" => [compute_input_tm_cnt => 0],
            "3'b001" => [compute_input_tm_cnt => 1],
            "3'b010" => [compute_input_tm_cnt => 1],
            "3'b011" => [compute_input_tm_cnt => 2],
            "3'b100" => [compute_input_tm_cnt => 1],
            "3'b101" => [compute_input_tm_cnt => 2],
            "3'b110" => [compute_input_tm_cnt => 2],
            "3'b111" => [compute_input_tm_cnt => 3],
          },
        }),
      ],
    }),
  );

  return $module;
} # end module 






sub 
make_nios2_fifo_wrptr_inc
{
  my $name = shift;
  my $oci_fifo_addr_width = shift;

  my $module = e_module->new ({
      name    => $name."_nios2_oci_fifo_wrptr_inc",
  });



  $module->add_contents (

    e_signal->news (
      ["ge2_free",     1, 0,], 
      ["ge3_free",     1, 0,], 
      ["input_tm_cnt",  2, 0,], 
      ["fifo_wrptr_inc", $oci_fifo_addr_width, 1,],
    ),
    e_process->new ({
      clock => "",
      contents  => [
        e_if->new ({ condition => "ge3_free & (input_tm_cnt == 3)", then => [ 
          ["fifo_wrptr_inc" => "3"]
        ], elsif => { condition => "ge2_free & (input_tm_cnt >= 2)", then => [
          ["fifo_wrptr_inc" => "2"] 
        ], elsif => { condition => "input_tm_cnt >= 1", then => [ 
          ["fifo_wrptr_inc" => "1"] 
        ], else => 
          ["fifo_wrptr_inc" => "0"],
        },
        },
        }),
      ],
    }),
  );
  return $module;
} # end module 









sub 
make_nios2_fifo_cnt_inc
{
  my $name = shift;
  my $oci_fifo_addr_width = shift;

  my $module = e_module->new ({
      name    => $name."_nios2_oci_fifo_cnt_inc",
  });



  $module->add_contents (

    e_signal->news (
      ["empty",     1, 0,], 
      ["ge2_free",     1, 0,], 
      ["ge3_free",     1, 0,], 
      ["input_tm_cnt",  2, 0,], 
      ["fifo_cnt_inc", $oci_fifo_addr_width + 1 , 1,],
    ),
    e_process->new ({
      clock => "",
      contents  => [
        e_if->new ({ condition => "empty", then => [ 

          ["fifo_cnt_inc" => "input_tm_cnt[1:0]"],
        ], elsif => { condition => "ge3_free & (input_tm_cnt == 3)", then => [ 

          ["fifo_cnt_inc" => "2"] 
        ], elsif => { condition => "ge2_free & (input_tm_cnt >= 2)", then => [ 
          ["fifo_cnt_inc" => "1"] 
        ], elsif => { condition => "input_tm_cnt >= 1", then => [ 
          ["fifo_cnt_inc" => "0"] 
        ], else  => 
          ["fifo_cnt_inc" => "{".($oci_fifo_addr_width+1)."{1'b1}}"],
        },
        },
        },
        }),
      ],
    }),
  );
  return $module;
}





sub 
make_oci_testbench
{
  my $name = shift;
  my $oci_tm_width = shift;
  my $oci_data_trace = shift;
  my $reset_addr = shift;

  my $module_name = $name."_oci_test_bench";



  my $module_filename = $module_name;

  my $module = e_module->new ({
      name          => $module_name,
      output_file   => $module_filename,
  });

  my $file_name = $name . ".comptr";
  my $file_handle = "comptr_handle";

  my $oci_tm_data_width = $oci_tm_width-4;     # bits in tm data field
  my $dct_count_width = ($oci_tm_data_width > 16) ? 4 : 3;  # Num bits in pending DCT counter

  $module->add_contents (

    e_signal->news (
      ["itm_valid", 1], 
      ["itm", $oci_tm_width, 0],
      ["atm_valid", 1], 
      ["atm", $oci_tm_width, 0],
      ["dtm_valid", 1], 
      ["dtm", $oci_tm_width, 0],
      ["trc_ctrl", 16],
      ["test_ending", 1],       # Asserted for one cycle when test end detected
      ["test_has_ended", 1],    # Same as test_ending but stays high
      ["dct_buffer", $oci_tm_data_width-2],  # Partially completed DCT frame
      ["dct_count", $dct_count_width],       # Number of DCT instructions in DCT buffer
    ),
  );



  $module->sink_signals(
    "test_ending",
    "test_has_ended",
    "dct_buffer",
    "dct_count",
  );

  if ($create_comptr) {
      my $tracemode_data_trace = $oci_data_trace ? 7 : 0;

      $module->add_contents (

        e_sim_fopen->new({
          file_name        => $file_name,
          file_handle      => $file_handle,
          contents         => [
            e_sim_write->new ({
               spec_string => "Version 1\\n",
               file_handle => $file_handle,
            }),
    





















            e_sim_write->new ({
               spec_string => "TraceMode 1 $tracemode_data_trace 0\\n",
               file_handle => $file_handle,
            }),
    


            e_sim_write->new ({
               spec_string => "%h%h\\n",
               expressions => ["$TM_GAP", "32'd" . $reset_addr],
               show_time   => 1,
               file_handle => $file_handle,
            }),
          ],
        }),
    
        e_process->new({
          tag      => "simulation",


          contents => [
            e_if->new({ condition => "itm_valid", then => [ 
              e_sim_write->new ({
                spec_string => "%h\\n",
                expressions => ["~test_has_ended & itm"],
                show_time   => 1,
                file_handle => $file_handle, 
              })
            ],
            }),
            e_if->new({ condition => "atm_valid", then => [ 
              e_sim_write->new ({
                spec_string => "%h\\n",
                expressions => ["~test_has_ended & atm"],
                show_time   => 1,
                file_handle => $file_handle, 
              })
            ],
            }),
            e_if->new({ condition => "dtm_valid", then => [ 
              e_sim_write->new ({
                spec_string => "%h\\n",
                expressions => ["~test_has_ended & dtm"],
                show_time   => 1,
                file_handle => $file_handle,
              })
            ],
            }),

            e_if->new({ condition => "test_ending & (dct_count != 0)", then => [
              e_sim_write->new ({
                spec_string => "%h\\n",
                expressions => ["{$TM_DCT, dct_buffer, 2'b00}"],
                show_time   => 1,
                file_handle => $file_handle,
              })
            ],
            }),
          ],
        }),
      );
  }

  return ($module, $module_name);
} # end module 

1;
