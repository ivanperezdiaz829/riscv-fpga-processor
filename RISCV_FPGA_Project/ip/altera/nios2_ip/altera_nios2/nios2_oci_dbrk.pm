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











sub make_nios2_oci_dbrk
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_dbrk",
  });
  

  my $is_fast  = ($Opt->{core_type} eq "fast") ? 1 : 0;
  my $is_small = ($Opt->{core_type} eq "small") ? 1 : 0;
  my $is_tiny  = ($Opt->{core_type} eq "tiny") ? 1 : 0;
  ($is_fast ^ $is_small ^ $is_tiny) or 
    &$error ("Unable to determine CPU core type ".  $Opt->{core_type});

  my $oci_num_dbrk = $Opt->{oci_num_dbrk};
  my $oci_dbrk_pairs = $Opt->{oci_dbrk_pairs};
  my $oci_dbrk_trace = $Opt->{oci_dbrk_trace};

  my $dbrk_ctrl_width = $Opt->{oci_dbrk_trace} ? 10 : 7;
  my $dbrk_ctrl_high = 64 + ($dbrk_ctrl_width - 1);



  $module->add_contents (

    e_signal->news (
      ["dbrk_trigout",          1,                            1],
      ["dbrk_break",            1,                            1],
      ["dbrk_traceoff",         1,                            1],
      ["dbrk_traceon",          1,                            1],
      ["dbrk_traceme",          1,                            1],
      ["dbrk_goto0",            1,                            1],
      ["dbrk_goto1",            1,                            1],




    ),

    e_signal->news (




      ["ir",                    8,                            0],
      ["jdo",                   36,                           0],
    ),

  );



  my $export = 1;   # export when trace supported 

  $module->add_contents (
    e_signal->news (
      ["cpu_d_address",       $Opt->{cpu_d_address_width},  $export, 0],
      ["cpu_d_readdata",      $Opt->{cpu_d_data_width},     $export, 0],
      ["cpu_d_read",          1,                            $export, 0],
      ["cpu_d_writedata",     $Opt->{cpu_d_data_width},     $export, 0],
      ["cpu_d_write",         1,                            $export, 0],
      ["cpu_d_wait",          1,                            $export, 0],
      ["dbrk_data",           $Opt->{cpu_d_data_width},     0, 1],
    ),
  );
























  if ($is_small) {


    $module->add_contents (
      e_assign->news (
        ["cpu_d_address",   "M_mem_baddr" ],
        ["cpu_d_readdata",  "M_wr_data_filtered" ],
        ["cpu_d_read",      "M_ctrl_ld & M_valid" ],
        ["cpu_d_writedata", "M_st_data" ],
        ["cpu_d_write",     "M_ctrl_st & M_valid" ],
        ["cpu_d_wait",      "~M_en" ],
      ),
    );
  } elsif ($is_tiny) {


    $module->add_contents (
      e_assign->news (
        ["cpu_d_address",   "d_address" ],
        ["cpu_d_readdata",  "av_ld_data_aligned_filtered" ],
        ["cpu_d_read",      "d_read" ],
        ["cpu_d_writedata", "E_st_data" ],
        ["cpu_d_write",     "d_write" ],
        ["cpu_d_wait",      "d_waitrequest" ],
      ),
    );
  } elsif ($is_fast) {


    $module->add_contents (
      e_assign->news (
        ["cpu_d_address",   "A_mem_baddr" ],
        ["cpu_d_readdata",  "A_wr_data_filtered" ],
        ["cpu_d_read",      "A_ctrl_ld & A_valid" ],
        ["cpu_d_writedata", "A_st_data" ],
        ["cpu_d_write",     "A_ctrl_st & A_valid" ],
        ["cpu_d_wait",      "~A_en" ],
      ),
    );
  } else {
    &$error ("No support for OCI with Turbo variant");
  }

  my $match_single_module = &make_match_single ($Opt);
  my $match_paired_module = &make_match_paired ($Opt);

  $module->add_contents (

    e_assign->new (
      ["dbrk_data" => "cpu_d_write ? cpu_d_writedata : cpu_d_readdata"],
    ),




    e_process->new ({
      clock     => "clk",
      reset     => "reset_n",
      asynchronous_contents => [
        e_assign->new (["dbrk_break", "0"]),
      ],
      contents  => [
        e_assign->new (["dbrk_break", 
                        "dbrk_break   ? ~debugack   
                                      : dbrk_break_pulse",
        ]),
      ],
    }),

  ); #end module->add_contents


  if ($oci_num_dbrk >= 1) {
    if (($oci_num_dbrk >= 2) && $oci_dbrk_pairs) {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit0" => "dbrk0[$dbrk_paired_bit] ?  ".
              " dbrk_hit0_match_paired : dbrk_hit0_match_single"],
          ),
       );
    } else {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit0" => "dbrk_hit0_match_single"],
          ),
       );
    }
    $module->add_contents (
       e_signal->new (
         ["dbrk_hit0",             1,                            1],
         ["dbrk0",                 78,                           0],
       ),
       e_assign->new (
         ["cpu_d_read_valid" => "cpu_d_read & ~cpu_d_wait"],
       ),
       e_instance->new ({
         name    => $Opt->{name}."_nios2_oci_dbrk_hit0_match_single",
         module  => $match_single_module,
         port_map  => {
           dbrk          => "dbrk0[$dbrk_ctrl_high:0]",
           addr          => "cpu_d_address",
           data          => "dbrk_data",
           read          => "cpu_d_read_valid",
           write         => "cpu_d_write",
           match_single  => "dbrk_hit0_match_single",
         },
       }),
       e_assign->news (
          ["dbrk0_trigout"     => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_trigout_bit])"],
          ["dbrk0_break_pulse" => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_break_bit])"],
          [["dbrk0_armed", 1, 0, 1]  =>
                      "(dbrk0[$dbrk_arm0_bit] & trigger_state_0) ||
                       (dbrk0[$dbrk_arm1_bit] & trigger_state_1)",
          ], 
       ),
    );
    if ($oci_dbrk_trace) {
       $module->add_contents (
          e_assign->news (
             ["dbrk0_traceoff" => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_traceoff_bit])"],
             ["dbrk0_traceon"  => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_traceon_bit])"],
             ["dbrk0_traceme"  => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_traceme_bit])"],
             ["dbrk0_goto0"    => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_goto0_bit])"],
             ["dbrk0_goto1"    => "(dbrk_hit0 & dbrk0_armed & dbrk0[$dbrk_goto1_bit])"],
          ),
       );
    } else { # ~oci_dbrk_trace 
       $module->add_contents (
          e_assign->news (
             ["dbrk0_traceoff" => "1'b0"],
             ["dbrk0_traceon"  => "1'b0"],
             ["dbrk0_traceme"  => "1'b0"],
             ["dbrk0_goto0"    => "1'b0"],
             ["dbrk0_goto1"    => "1'b0"],
          ),
       );
    }
  } else { #end if oci_num_dbrk >= 1
    $module->add_contents (
       e_assign->news (
          [["dbrk0_armed", 1, 0, 1]  => "1'b0"],
          ["dbrk0_trigout" => "1'b0"],
          ["dbrk0_break_pulse" => "1'b0"],
          ["dbrk0_traceoff" => "1'b0"],
          ["dbrk0_traceon"  => "1'b0"],
          ["dbrk0_traceme"  => "1'b0"],
          ["dbrk0_goto0"    => "1'b0"],
          ["dbrk0_goto1"    => "1'b0"],
       ),
    );
  } 


  if ($oci_num_dbrk >= 2) {
    $module->add_contents (
       e_signal->new (
         ["dbrk_hit1",             1,                            1],
         ["dbrk1",                 78,                           0],
       ),

       e_instance->new ({
         name    => $Opt->{name}."_nios2_oci_dbrk_hit1_match_single",
         module  => $match_single_module,
         port_map  => {
           dbrk          => "dbrk1[$dbrk_ctrl_high:0]",
           addr          => "cpu_d_address",
           data          => "dbrk_data",
           read          => "cpu_d_read_valid",
           write         => "cpu_d_write",
           match_single  => "dbrk_hit1_match_single",
         },
       }),
       e_assign->news (
          ["dbrk1_trigout"     => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_trigout_bit])"],
          ["dbrk1_break_pulse" => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_break_bit])"],
          [["dbrk1_armed", 1, 0, 1]  =>
                      "(dbrk1[$dbrk_arm0_bit] & trigger_state_0) ||
                       (dbrk1[$dbrk_arm1_bit] & trigger_state_1)",
          ], 
       ),
    );
    if ($oci_dbrk_trace) {
       $module->add_contents (
          e_assign->news (
             ["dbrk1_traceoff" => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_traceoff_bit])"],
             ["dbrk1_traceon"  => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_traceon_bit])"],
             ["dbrk1_traceme"  => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_traceme_bit])"],
             ["dbrk1_goto0"    => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_goto0_bit])"],
             ["dbrk1_goto1"    => "(dbrk_hit1 & dbrk1_armed & dbrk1[$dbrk_goto1_bit])"],
          ),
       );
    } else { # ~oci_dbrk_trace
       $module->add_contents (
          e_assign->news (
             ["dbrk1_traceoff" => "1'b0"],
             ["dbrk1_traceon"  => "1'b0"],
             ["dbrk1_traceme"  => "1'b0"],
             ["dbrk1_goto0"    => "1'b0"],
             ["dbrk1_goto1"    => "1'b0"],
          ),
       );
    }
    if ($oci_dbrk_pairs) {
       $module->add_contents (



          e_instance->new ({
            name    => $Opt->{name}."_nios2_oci_dbrk_hit0_match_paired",
            module  => $match_paired_module,
            port_map  => {
              dbrka         => "dbrk0[$dbrk_ctrl_high:0]",
              dbrkb         => "dbrk1[$dbrk_ctrl_high:0]",  
              addr          => "cpu_d_address",
              data          => "dbrk_data",
              read          => "cpu_d_read_valid",
              write         => "cpu_d_write",
              match_paired  => "dbrk_hit0_match_paired",
            },
          }),
          e_assign->new (
            ["dbrk_hit1" => "dbrk0[$dbrk_paired_bit] ? 0 : dbrk_hit1_match_single"],
          ),
       );
    } else {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit1" => "dbrk_hit1_match_single"],
          ),
       );
    }
  } else {#end if oci_num_dbrk >= 2
    $module->add_contents (
       e_assign->news (
          [["dbrk1_armed", 1, 0, 1]  => "1'b0"],
          ["dbrk1_trigout" => "1'b0"],
          ["dbrk1_break_pulse" => "1'b0"],
          ["dbrk1_traceoff" => "1'b0"],
          ["dbrk1_traceon"  => "1'b0"],
          ["dbrk1_traceme"  => "1'b0"],
          ["dbrk1_goto0"    => "1'b0"],
          ["dbrk1_goto1"    => "1'b0"],
       ),
    );
  }


  if ($oci_num_dbrk >= 3) {
    if (($oci_num_dbrk >= 4) && $oci_dbrk_pairs) {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit2" => "dbrk2[$dbrk_paired_bit] ?  ".
              " dbrk_hit2_match_paired : dbrk_hit2_match_single"],
          ),
       );
    } else {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit2" => "dbrk_hit2_match_single"],
          ),
       );
    }
    $module->add_contents (
       e_signal->new (
         ["dbrk_hit2",             1,                            1],
         ["dbrk2",                 78,                           0],
       ),
       e_instance->new ({
         name    => $Opt->{name}."_nios2_oci_dbrk_hit2_match_single",
         module  => $match_single_module,
         port_map  => {
           dbrk          => "dbrk2[$dbrk_ctrl_high:0]",
           addr          => "cpu_d_address",
           data          => "dbrk_data",
           read          => "cpu_d_read_valid",
           write         => "cpu_d_write",
           match_single  => "dbrk_hit2_match_single",
         },
       }),
       e_assign->news (
          ["dbrk2_trigout"     => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_trigout_bit])"],
          ["dbrk2_break_pulse" => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_break_bit])"],
          [["dbrk2_armed", 1, 0, 1]  =>
                      "(dbrk2[$dbrk_arm0_bit] & trigger_state_0) ||
                       (dbrk2[$dbrk_arm1_bit] & trigger_state_1)",
          ], 
       ),
    );
    if ($oci_dbrk_trace) {
       $module->add_contents (
          e_assign->news (
             ["dbrk2_traceoff" => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_traceoff_bit])"],
             ["dbrk2_traceon"  => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_traceon_bit])"],
             ["dbrk2_traceme"  => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_traceme_bit])"],
             ["dbrk2_goto0"    => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_goto0_bit])"],
             ["dbrk2_goto1"    => "(dbrk_hit2 & dbrk2_armed & dbrk2[$dbrk_goto1_bit])"],
          ),
       );
    } else { # ~oci_dbrk_trace
       $module->add_contents (
          e_assign->news (
             ["dbrk2_traceoff" => "1'b0"],
             ["dbrk2_traceon"  => "1'b0"],
             ["dbrk2_traceme"  => "1'b0"],
             ["dbrk2_goto0"    => "1'b0"],
             ["dbrk2_goto1"    => "1'b0"],
          ),
       );
    }
  } else { #end if oci_num_dbrk >= 1
    $module->add_contents (
       e_assign->news (
          [["dbrk2_armed", 1, 0, 1]  => "1'b0"],
          ["dbrk2_trigout" => "1'b0"],
          ["dbrk2_break_pulse" => "1'b0"],
          ["dbrk2_traceoff" => "1'b0"],
          ["dbrk2_traceon"  => "1'b0"],
          ["dbrk2_traceme"  => "1'b0"],
          ["dbrk2_goto0"    => "1'b0"],
          ["dbrk2_goto1"    => "1'b0"],
       ),
    );
  } 


  if ($oci_num_dbrk >= 4) {
    $module->add_contents (
       e_signal->new (
         ["dbrk_hit3",             1,                            1],
         ["dbrk3",                 78,                           0],
       ),

       e_instance->new ({
         name    => $Opt->{name}."_nios2_oci_dbrk_hit3_match_single",
         module  => $match_single_module,
         port_map  => {
           dbrk          => "dbrk3[$dbrk_ctrl_high:0]",
           addr          => "cpu_d_address",
           data          => "dbrk_data",
           read          => "cpu_d_read_valid",
           write         => "cpu_d_write",
           match_single  => "dbrk_hit3_match_single",
         },
       }),
       e_assign->news (
          ["dbrk3_trigout"     => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_trigout_bit])"],
          ["dbrk3_break_pulse" => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_break_bit])"],
          [["dbrk3_armed", 1, 0, 1]  =>
                      "(dbrk3[$dbrk_arm0_bit] & trigger_state_0) ||
                       (dbrk3[$dbrk_arm1_bit] & trigger_state_1)",
          ], 
       ),
    );
    if ($oci_dbrk_trace) {
       $module->add_contents (
          e_assign->news (
             ["dbrk3_traceoff" => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_traceoff_bit])"],
             ["dbrk3_traceon"  => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_traceon_bit])"],
             ["dbrk3_traceme"  => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_traceme_bit])"],
             ["dbrk3_goto0"    => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_goto0_bit])"],
             ["dbrk3_goto1"    => "(dbrk_hit3 & dbrk3_armed & dbrk3[$dbrk_goto1_bit])"],
          ),
       );
    } else { # ~oci_dbrk_trace
       $module->add_contents (
          e_assign->news (
             ["dbrk3_traceoff" => "1'b0"],
             ["dbrk3_traceon"  => "1'b0"],
             ["dbrk3_traceme"  => "1'b0"],
             ["dbrk3_goto0"    => "1'b0"],
             ["dbrk3_goto1"    => "1'b0"],
          ),
       );
    }
    if ($oci_dbrk_pairs) {
       $module->add_contents (


          e_instance->new ({
            name    => $Opt->{name}."_nios2_oci_dbrk_hit2_match_paired",
            module  => $match_paired_module,
            port_map  => {
              dbrka         => "dbrk2[$dbrk_ctrl_high:0]",
              dbrkb         => "dbrk3[$dbrk_ctrl_high:0]",  
              addr          => "cpu_d_address",
              data          => "dbrk_data",
              read          => "cpu_d_read_valid",
              write         => "cpu_d_write",
              match_paired  => "dbrk_hit2_match_paired",
            },
          }),
          e_assign->new (
            ["dbrk_hit3" => "dbrk2[$dbrk_paired_bit] ? 0 : dbrk_hit3_match_single"],
          ),
       );
    } else {
       $module->add_contents (
          e_assign->new (
            ["dbrk_hit3" => "dbrk_hit3_match_single"],
          ),
       );
    }
  } else {#end if oci_num_dbrk >= 4
    $module->add_contents (
       e_assign->news (
          [["dbrk3_armed", 1, 0, 1]  => "1'b0"],
          ["dbrk3_trigout" => "1'b0"],
          ["dbrk3_break_pulse" => "1'b0"],
          ["dbrk3_traceoff" => "1'b0"],
          ["dbrk3_traceon"  => "1'b0"],
          ["dbrk3_traceme"  => "1'b0"],
          ["dbrk3_goto0"    => "1'b0"],
          ["dbrk3_goto1"    => "1'b0"],
       ),
    );
  }


  $module->add_contents (












    e_process->new ({
      clock     => "clk",
      reset     => "reset_n",
      asynchronous_contents => [
        e_assign->news (
            ["dbrk_trigout"  => "0"],
            ["dbrk_break_pulse"  => "0"],
            ["dbrk_traceoff"  => "0"],
            ["dbrk_traceon"  => "0"],
            ["dbrk_traceme"  => "0"],
            ["dbrk_goto0"  => "0"],
            ["dbrk_goto1"  => "0"],
        ),
      ],
      contents  => [
        e_assign->news (
          ["dbrk_trigout" =>
              "(dbrk0_trigout | dbrk1_trigout | dbrk2_trigout | dbrk3_trigout)"],
          ["dbrk_break_pulse" =>
              "(dbrk0_break_pulse | dbrk1_break_pulse | dbrk2_break_pulse | dbrk3_break_pulse)"],
          ["dbrk_traceoff" => 
              "(dbrk0_traceoff | dbrk1_traceoff | dbrk2_traceoff | dbrk3_traceoff)"],
          ["dbrk_traceon" =>
              "(dbrk0_traceon | dbrk1_traceon | dbrk2_traceon | dbrk3_traceon)"],
          ["dbrk_traceme" =>
              "(dbrk0_traceme | dbrk1_traceme | dbrk2_traceme | dbrk3_traceme)"],
          ["dbrk_goto0" =>
              "(dbrk0_goto0 | dbrk1_goto0 | dbrk2_goto0 | dbrk3_goto0)"],
          ["dbrk_goto1" => 
              "(dbrk0_goto1 | dbrk1_goto1 | dbrk2_goto1 | dbrk3_goto1)"],
        ),
      ],
    }),


























  );

  return $module;
}



sub make_match_single
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_match_single",
  });

  my $dbrk_addr_high = $Opt->{cpu_d_address_width} - 1;
  my $dbrk_data_high = 32 + ($Opt->{cpu_d_data_width} - 1);
  my $dbrk_ctrl_width = $Opt->{oci_dbrk_trace} ? 10 : 7;
  my $dbrk_ctrl_high = 64 + ($dbrk_ctrl_width - 1);

  my $oci_num_dbrk = $Opt->{oci_num_dbrk};


  $module->add_contents (   

    e_signal->news (    
      ["dbrk",          $dbrk_ctrl_high + 1,          0],
      ["addr",          $Opt->{cpu_d_address_width},  0],
      ["data",          $Opt->{cpu_d_data_width},     0],
      ["read",          1,  0],
      ["write",         1,  0],
    ),

    e_signal->news (    
      ["match_single",  1, 1],
    ),
  );

  if (1) {
    $module->add_contents (   
      e_assign->new ({
        lhs => "match_single_combinatorial", 
        rhs => 
        "    (~dbrk[$dbrk_addrused_bit] || (addr == dbrk[$dbrk_addr_high : 0])) ".
        " && (~dbrk[$dbrk_dataused_bit] || (data == dbrk[$dbrk_data_high :32])) ".
        " && (    (dbrk[$dbrk_readenb_bit] & read) ".
        "      || (dbrk[$dbrk_writeenb_bit] & write)) ",
      }),
    );
  } else { 

    $module->add_contents (   
      e_assign->news (
        [["dbrk_addr_eq", ($Opt->{cpu_d_address_width} + 1)] => 
              "{1'b0, (addr - dbrk[$dbrk_addr_high : 0])} - ".
                ($Opt->{cpu_d_address_width}+1)."'b1"],
        [["dbrk_data_eq", ($Opt->{cpu_d_data_width} + 1)] => 
              "{1'b0, (data - dbrk[$dbrk_data_high : 32])} - ".
                ($Opt->{cpu_d_data_width}+1)."'b1"],
        ["dbrk_addr_match" => "dbrk_addr_eq[".$Opt->{cpu_d_address_width}."]"],
        ["dbrk_data_match" => "dbrk_data_eq[".$Opt->{cpu_d_data_width}."]",  ],
      ),
      e_assign->new ({
        lhs => "match_single_combinatorial", 
        rhs => 
        "    (~dbrk[$dbrk_addrused_bit] || dbrk_addr_match) ".
        " && (~dbrk[$dbrk_dataused_bit] || dbrk_data_match) ".
        " && (    (dbrk[$dbrk_readenb_bit] & read) ".
        "      || (dbrk[$dbrk_writeenb_bit] & write)) ",
      }),
    );
  }

  if (0) {

    $module->add_contents (   
      e_process->new ({
        clock     => "clk",
        contents  => [
          e_assign->new (["match_single" => "match_single_combinatorial"]),
        ],
      }),
    );
  } else {

    $module->add_contents (   
      e_assign->new (["match_single" => "match_single_combinatorial"]),
    );
  }

  return $module;
}

sub make_match_paired
{
  my ($Opt) = (@_);

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_match_paired",
  });
  
  my $dbrk_addr_high = $Opt->{cpu_d_address_width} - 1;
  my $dbrk_data_high = 32 + ($Opt->{cpu_d_data_width} - 1);
  my $dbrk_ctrl_width = $Opt->{oci_dbrk_trace} ? 10 : 7;
  my $dbrk_ctrl_high = 64 + ($dbrk_ctrl_width - 1);

  my $oci_num_dbrk = $Opt->{oci_num_dbrk};


  $module->add_contents (   

    e_signal->news (    
      ["dbrka",         $dbrk_ctrl_high + 1,          0],
      ["dbrkb",         $dbrk_ctrl_high + 1,          0],
      ["addr",          $Opt->{cpu_d_address_width},  0],
      ["data",          $Opt->{cpu_d_data_width},     0],
      ["read",          1,  0],
      ["write",         1,  0],
    ),

    e_signal->news (    
      ["match_paired",  1, 1],
    ),
  );

  $module->add_contents (   
    e_assign->new ({
      lhs => "match_paired_combinatorial", 
      rhs => 
        "   (~dbrka[$dbrk_addrused_bit] ".
        "      || ((addr >= dbrka[$dbrk_addr_high : 0]) ".
        "           && (addr <= dbrkb[$dbrk_addr_high : 0]))) ".
        "&& (~dbrka[$dbrk_dataused_bit] ".
        "      || (((data ^ dbrka[$dbrk_data_high :32])  ".
        "           & dbrkb[$dbrk_data_high :32]) == 0)) ".
        "&& ((dbrka[$dbrk_readenb_bit] & read) ".
        "      || (dbrka[$dbrk_writeenb_bit] & write))",
    }),
  );

  if (0) {

    $module->add_contents (   
      e_process->new ({
        clock     => "clk",
        contents  => [
          e_assign->new (["match_paired" => "match_paired_combinatorial"]),
        ],
      }),
    );
  } else {

    $module->add_contents (   
      e_assign->new (["match_paired" => "match_paired_combinatorial"]),
    );
  }

  return $module;
}




1;
