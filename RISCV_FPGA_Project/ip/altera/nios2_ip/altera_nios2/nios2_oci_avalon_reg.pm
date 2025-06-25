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
use nios2_oci_cfg;
use strict;

sub make_nios2_oci_avalon_reg
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_avalon_reg",
  });
  my $marker = e_default_module_marker->new($module);



  $module->add_contents (

    e_signal->news (
      ["oci_reg_readdata",      32,   1],
      ["take_action_ocireg",     1,   1], # needed over in oci_debug
      ["oci_single_step_mode",   1,   1],
      ["oci_ienable",           32,   1],
    ),

    e_signal->news (
      ["address",               9,    0],
      ["writedata",             32,   0],
      ["byteenable",            4,    0],
      ["jdo",           $SR_WIDTH,    0],
      ["reset",                 1,    0],
    ),

    
  );





  $module->add_contents (
    e_assign->news (
      [["oci_reg_00_addressed", 1,0,1]  => "(address == 9'h100)"],
      [["oci_reg_01_addressed", 1,0,1]  => "(address == 9'h101)"],
      [["write_strobe", 1,0,1]          => "write & debugaccess"],

      ["take_action_ocireg"   => "write_strobe & oci_reg_00_addressed"],
      ["take_action_oci_intr_mask_reg" => "write_strobe & oci_reg_01_addressed"],


      ["ocireg_ers"  => "writedata[$OCIREG_ERS_POS]"],
      ["ocireg_mrs"  => "writedata[$OCIREG_MRS_POS]"],
      ["ocireg_sstep"  => "writedata[$OCIREG_SSTEP_POS]"],
    ),
  );






  my $readdata_mux_pm_additions; 
  if ($Opt->{oci_num_pm} > 0) {
    my $pm_high_msb = $Opt->{oci_pm_width} - 1;
    my $base = 0x10;            # base address
    for (my $i=1; $i <= $Opt->{oci_num_pm}; $i++) {
      e_assign->adds (
        [["oci_reg_".sprintf("%lx",($base + (($i-1)*8)))."_addressed", 1,0,1]  
            => "(address == 9'h1".sprintf("%lx",($base + (($i-1)*8))).")"],
        [["oci_reg_".sprintf("%lx",($base+1 + (($i-1)*8)))."_addressed", 1,0,1]
            => "(address == 9'h1".sprintf("%lx",($base+1 + (($i-1)*8))).")"],
        [["oci_reg_".sprintf("%lx",($base+2 + (($i-1)*8)))."_addressed", 1,0,1]
            => "(address == 9'h1".sprintf("%lx",($base+2 + (($i-1)*8))).")"],
        [["oci_reg_".sprintf("%lx",($base+4 + (($i-1)*8)))."_addressed", 1,0,1]
            => "(address == 9'h1".sprintf("%lx",($base+4 + (($i-1)*8))).")"],
        [["oci_reg_".sprintf("%lx",($base+5 + (($i-1)*8)))."_addressed", 1,0,1]
            => "(address == 9'h1".sprintf("%lx",($base+5 + (($i-1)*8))).")"],
        ["take_action_pm$i\_control" => 
          "write_strobe & oci_reg_".sprintf("%lx",($base + (($i-1)*8)))."_addressed"],


        ["take_action_pm$i\_mux_selection", => 
          "write_strobe & oci_reg_".sprintf("%lx",($base+2 + (($i-1)*8)))."_addressed"],




      );
      $readdata_mux_pm_additions .= 
        "oci_reg_".sprintf("%lx",($base + (($i-1)*8)))."_addressed ? 
                  {24'b0, 
                    pm$i\_detect_falling_edge, pm$i\_detect_rising_edge,
                    pm$i\_edge_off, pm$i\_edge_on, 
                    1'b0, 1'b0, 
                    pm$i\_disable, pm$i\_enable} :
        oci_reg_".sprintf("%lx",($base+1 + (($i-1)*8)))."_addressed ? 
                  {28'b0,
                    pm$i\_overflow, pm$i\_counting, 
                    pm$i\_stopped, pm$i\_started} :
        oci_reg_".sprintf("%lx",($base+2 + (($i-1)*8)))."_addressed ? 
                  pm$i\_mux_selection :
        oci_reg_".sprintf("%lx",($base+4 + (($i-1)*8)))."_addressed ? 
                  pm$i\_counter[31:0] :
        oci_reg_".sprintf("%lx",($base+5 + (($i-1)*8)))."_addressed ? 
                  pm$i\_counter[$pm_high_msb\:32]  :
        ";
    }
  }


  e_assign->add (
    ["oci_reg_readdata"  =>  
      "oci_reg_00_addressed ? {28'b0, oci_single_step_mode, monitor_go,
                                monitor_ready, monitor_error} : 
      oci_reg_01_addressed ?  oci_ienable :   
      $readdata_mux_pm_additions
      32'b0"],
  );

  e_register->add ({
    out => "oci_single_step_mode",
    in  => "ocireg_sstep",
    enable  => "take_action_ocireg",
    async_value => "1'b0",      
  }),






  my $active_interrupts_mask = $eic_present ?
     "32'b1" :
     not_empty_scalar($Opt, "internal_irq_mask_bin");

  $module->add_contents (
    e_register->new ({
      out => "oci_ienable", 
      in  => "writedata | ~($active_interrupts_mask)", 
      enable  => "take_action_oci_intr_mask_reg",
      async_value => $active_interrupts_mask,
    }),
  );

  return $module;
}


1;


