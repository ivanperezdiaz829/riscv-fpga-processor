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






















sub make_nios2_oci_xbrk
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_xbrk",
  });
  my $marker = e_default_module_marker->new($module);

  my $xbrk_width  = $Opt->{cpu_i_address_width};
  my $max_latency = 1;



  my $is_fast  = ($Opt->{core_type} eq "fast") ? 1 : 0;
  my $is_small = ($Opt->{core_type} eq "small") ? 1 : 0;
  my $is_tiny  = ($Opt->{core_type} eq "tiny") ? 1 : 0;
  ($is_fast ^ $is_small ^ $is_tiny) or 
    &$error ("Unable to determine CPU Implementation ".  $Opt->{core_type});




  $module->add_contents (



    e_signal->news (
      ["ir",            $IR_WIDTH,    0],
      ["jdo",           $SR_WIDTH,    0],




      ["xbrk_ctrl0",          8,                        0,  0],
      ["xbrk_ctrl1",          8,                        0,  0],
      ["xbrk_ctrl2",          8,                        0,  0],
      ["xbrk_ctrl3",          8,                        0,  0],
    ),

  );












  $module->add_contents (   
    e_signal->news (    # never export these
      ["xbrk_break_hit",       1,                        0,  1],
      ["xbrk_ton_hit",         1,                        0,  1],
      ["xbrk_toff_hit",        1,                        0,  1],
      ["xbrk_tout_hit",        1,                        0,  1],
    ),
  );
  





  my $oci_num_xbrk = $Opt->{oci_num_xbrk};  # shorthand








  e_assign->add ([["cpu_i_address", $Opt->{cpu_i_address_width}, 0, 1], 
                    "{F_pc, 2'b00}"]);

  if ($is_tiny) {
    e_assign->add ([["D_cpu_addr_en", 1, 0, 1], "D_valid"]);
    e_assign->add ([["E_cpu_addr_en", 1, 0, 1], "E_valid"]);
  } else {  # valid for both small and fast variants
    e_assign->add ([["D_cpu_addr_en", 1, 0, 1], "D_en"]);
    e_assign->add ([["E_cpu_addr_en", 1, 0, 1], "E_en"]);
  }
  


  if ($oci_num_xbrk >= 1) {
    $module->add_contents (
      e_signal->news (
        ["xbrk0",               $xbrk_width,              0,  0],
      ),
      e_register->new (
         { out       => ["xbrk_hit0"] ,
           in        => "(cpu_i_address == xbrk0[$xbrk_width-1 : 0])",
           enable    => "D_cpu_addr_en",
         },
      ),
      e_assign->news (
         ["xbrk0_break_hit" => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_brk_bit])"],
         ["xbrk0_ton_hit"   => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_ton_bit])"],
         ["xbrk0_toff_hit"  => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_toff_bit])"],
         ["xbrk0_tout_hit"  => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_tout_bit])"],
         ["xbrk0_goto0_hit" => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_goto0_bit])"],
         ["xbrk0_goto1_hit" => "(xbrk_hit0 & xbrk0_armed & xbrk_ctrl0[$xbrk_ctrl_goto1_bit])"],
      ),
    );
  } else {
    $module->add_contents (
      e_assign->news (
       ["xbrk0_break_hit" => "0"],
       ["xbrk0_ton_hit"   => "0"],
       ["xbrk0_toff_hit"  => "0"],
       ["xbrk0_tout_hit"  => "0"],
       ["xbrk0_goto0_hit" => "0"],
       ["xbrk0_goto1_hit" => "0"],
      ),
    );
  }
  

  if ($oci_num_xbrk >= 2) {
    $module->add_contents (
      e_signal->news (
        ["xbrk1",               $xbrk_width,              0,  0],
      ),
      e_register->new (
         { out       => ["xbrk_hit1"] ,
           in        => "(cpu_i_address == xbrk1[$xbrk_width-1 : 0])",
           enable    => "D_cpu_addr_en",
         },
      ),
      e_assign->news (
         ["xbrk1_break_hit" => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_brk_bit])"],
         ["xbrk1_ton_hit"   => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_ton_bit])"],
         ["xbrk1_toff_hit"  => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_toff_bit])"],
         ["xbrk1_tout_hit"  => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_tout_bit])"],
         ["xbrk1_goto0_hit" => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_goto0_bit])"],
         ["xbrk1_goto1_hit" => "(xbrk_hit1 & xbrk1_armed & xbrk_ctrl1[$xbrk_ctrl_goto1_bit])"],
      ),
    );
  } else {
    $module->add_contents (
      e_assign->news (
       ["xbrk1_break_hit" => "0"],
       ["xbrk1_ton_hit"   => "0"],
       ["xbrk1_toff_hit"  => "0"],
       ["xbrk1_tout_hit"  => "0"],
       ["xbrk1_goto0_hit" => "0"],
       ["xbrk1_goto1_hit" => "0"],
      ),
    );
  }


  if ($oci_num_xbrk >= 3) {
    $module->add_contents (
      e_signal->news (
        ["xbrk2",               $xbrk_width,              0,  0],
      ),
      e_register->new (
         { out       => ["xbrk_hit2"] ,
           in        => "(cpu_i_address == xbrk2[$xbrk_width-1 : 0])",
           enable    => "D_cpu_addr_en",
         },
      ),
      e_assign->news (
         ["xbrk2_break_hit" => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_brk_bit])"],
         ["xbrk2_ton_hit"   => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_ton_bit])"],
         ["xbrk2_toff_hit"  => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_toff_bit])"],
         ["xbrk2_tout_hit"  => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_tout_bit])"],
         ["xbrk2_goto0_hit" => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_goto0_bit])"],
         ["xbrk2_goto1_hit" => "(xbrk_hit2 & xbrk2_armed & xbrk_ctrl2[$xbrk_ctrl_goto1_bit])"],
      ),
    );
  } else {
    $module->add_contents (
      e_assign->news (
       ["xbrk2_break_hit" => "0"],
       ["xbrk2_ton_hit"   => "0"],
       ["xbrk2_toff_hit"  => "0"],
       ["xbrk2_tout_hit"  => "0"],
       ["xbrk2_goto0_hit" => "0"],
       ["xbrk2_goto1_hit" => "0"],
      ),
    );
  }


  if ($oci_num_xbrk >= 4) {
    $module->add_contents (
      e_signal->news (
        ["xbrk3",               $xbrk_width,              0,  0],
      ),
      e_register->new (
         { out       => ["xbrk_hit3"] ,
           in        => "(cpu_i_address == xbrk3[$xbrk_width-1 : 0])",
           enable    => "D_cpu_addr_en",
         },
      ),
      e_assign->news (
         ["xbrk3_break_hit" => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_brk_bit])"],
         ["xbrk3_ton_hit"   => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_ton_bit])"],
         ["xbrk3_toff_hit"  => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_toff_bit])"],
         ["xbrk3_tout_hit"  => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_tout_bit])"],
         ["xbrk3_goto0_hit" => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_goto0_bit])"],
         ["xbrk3_goto1_hit" => "(xbrk_hit3 & xbrk3_armed & xbrk_ctrl3[$xbrk_ctrl_goto1_bit])"],
      ),
    );
  } else {
    $module->add_contents (
      e_assign->news (
       ["xbrk3_break_hit" => "0"],
       ["xbrk3_ton_hit"   => "0"],
       ["xbrk3_toff_hit"  => "0"],
       ["xbrk3_tout_hit"  => "0"],
       ["xbrk3_goto0_hit" => "0"],
       ["xbrk3_goto1_hit" => "0"],
      ),
    );
  }




  e_assign->adds (
    ["xbrk_break_hit" => 
       "(xbrk0_break_hit) | (xbrk1_break_hit) | (xbrk2_break_hit) | (xbrk3_break_hit)"], 
    ["xbrk_ton_hit"   => 
       "(xbrk0_ton_hit) | (xbrk1_ton_hit) | (xbrk2_ton_hit) | (xbrk3_ton_hit)"], 
    ["xbrk_toff_hit"  => 
       "(xbrk0_toff_hit) | (xbrk1_toff_hit) | (xbrk2_toff_hit) | (xbrk3_toff_hit)"], 
    ["xbrk_tout_hit"  => 
       "(xbrk0_tout_hit) | (xbrk1_tout_hit) | (xbrk2_tout_hit) | (xbrk3_tout_hit)"], 
    ["xbrk_goto0_hit" => 
       "(xbrk0_goto0_hit) | (xbrk1_goto0_hit) | (xbrk2_goto0_hit) | (xbrk3_goto0_hit)"], 
    ["xbrk_goto1_hit" => 
       "(xbrk0_goto1_hit) | (xbrk1_goto1_hit) | (xbrk2_goto1_hit) | (xbrk3_goto1_hit)"], 
  );





















  e_register->adds (
    { out       => ["xbrk_break", 1, 1] ,
      in        => "xbrk_break_hit",
      enable    => "E_cpu_addr_en",
    },
  );






  e_register->adds (
    { out       => ["E_xbrk_traceon", 1, 0, 1] ,
      in        => "xbrk_ton_hit",
      enable    => "E_cpu_addr_en",
    },
    { out       => ["E_xbrk_traceoff", 1, 0, 1] ,
      in        => "xbrk_toff_hit",
      enable    => "E_cpu_addr_en",
    },
    { out       => ["E_xbrk_trigout", 1, 0, 1] ,
      in        => "xbrk_tout_hit",
      enable    => "E_cpu_addr_en",
    },
    { out       => ["E_xbrk_goto0", 1, 0, 1] ,
      in        => "xbrk_goto0_hit",
      enable    => "E_cpu_addr_en",
    },
    { out       => ["E_xbrk_goto1", 1, 0, 1] ,
      in        => "xbrk_goto1_hit",
      enable    => "E_cpu_addr_en",
    },
  );





  if ($is_fast) {
    e_register->adds (
      { out       => ["M_xbrk_traceon", 1, 0, 1] ,
        in        => "E_xbrk_traceon & E_valid",
        enable    => "M_en",
      },
      { out       => ["M_xbrk_traceoff", 1, 0, 1] ,
        in        => "E_xbrk_traceoff & E_valid",
        enable    => "M_en",
      },
      { out       => ["M_xbrk_trigout", 1, 0, 1] ,
        in        => "E_xbrk_trigout & E_valid",
        enable    => "M_en",
      },
      { out       => ["M_xbrk_goto0", 1, 0, 1] ,
        in        => "E_xbrk_goto0 & E_valid",
        enable    => "M_en",
      },
      { out       => ["M_xbrk_goto1", 1, 0, 1] ,
        in        => "E_xbrk_goto1 & E_valid",
        enable    => "M_en",
      },
    );
    e_assign->adds (
      [["xbrk_traceon", 1, 0]  => "M_xbrk_traceon"], 
      [["xbrk_traceoff", 1, 0] => "M_xbrk_traceoff"], 
      [["xbrk_trigout", 1, 0]  => "M_xbrk_trigout"], 
      [["xbrk_goto0", 1, 0]    => "M_xbrk_goto0"], 
      [["xbrk_goto1", 1, 0]    => "M_xbrk_goto1"], 
    );
  } elsif ($is_small) {
    e_assign->adds (
      [["xbrk_traceon", 1, 0]  => "E_xbrk_traceon & E_valid"], 
      [["xbrk_traceoff", 1, 0] => "E_xbrk_traceoff & E_valid"], 
      [["xbrk_trigout", 1, 0]  => "E_xbrk_trigout & E_valid"], 
      [["xbrk_goto0", 1, 0]    => "E_xbrk_goto0 & E_valid"], 
      [["xbrk_goto1", 1, 0]    => "E_xbrk_goto1 & E_valid"], 
    ); 
  } else {

    e_assign->adds (
      [["xbrk_traceon", 1, 0]  => "1'b0"], 
      [["xbrk_traceoff", 1, 0] => "1'b0"], 
      [["xbrk_trigout", 1, 0]  => "1'b0"], 
      [["xbrk_goto0", 1, 0]    => "1'b0"], 
      [["xbrk_goto1", 1, 0]    => "1'b0"], 
    );
  }

  e_assign->adds (
    [["xbrk0_armed", 1, 0, 1]  =>
                     "(xbrk_ctrl0[$xbrk_ctrl_arm0_bit] & trigger_state_0) ||
                      (xbrk_ctrl0[$xbrk_ctrl_arm1_bit] & trigger_state_1)",
    ], 
    [["xbrk1_armed", 1, 0, 1]  =>
                     "(xbrk_ctrl1[$xbrk_ctrl_arm0_bit] & trigger_state_0) ||
                      (xbrk_ctrl1[$xbrk_ctrl_arm1_bit] & trigger_state_1)",
    ], 
    [["xbrk2_armed", 1, 0, 1]  =>
                     "(xbrk_ctrl2[$xbrk_ctrl_arm0_bit] & trigger_state_0) ||
                      (xbrk_ctrl2[$xbrk_ctrl_arm1_bit] & trigger_state_1)",
    ], 
    [["xbrk3_armed", 1, 0, 1]  =>
                     "(xbrk_ctrl3[$xbrk_ctrl_arm0_bit] & trigger_state_0) ||
                      (xbrk_ctrl3[$xbrk_ctrl_arm1_bit] & trigger_state_1)",
    ], 
  );
  



























  return $module;
}




1;


