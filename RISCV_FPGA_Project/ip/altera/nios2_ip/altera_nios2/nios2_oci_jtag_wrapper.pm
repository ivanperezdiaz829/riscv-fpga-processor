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
use nios2_oci_jtag_tck;
use nios2_oci_jtag_sysclk;
use strict;





sub make_nios2_oci_jtag_wrapper
{
  my $Opt = shift;
  





  my $jtag_wrapper_module_name = $Opt->{name}."_jtag_debug_module_wrapper";
  my $jtag_wrapper_file_name = $jtag_wrapper_module_name;

  my $jtag_wrapper_module = e_module->new ({
    name  => $jtag_wrapper_module_name,
    output_file => $jtag_wrapper_file_name,
  });


  my $nios2_oci_jtag_syn_port_map = {
    "tck",    "vji_tck",
    "tdi",    "vji_tdi",
    "ir_in",  "vji_ir_in",
    "tdo",    "vji_tdo",
    "ir_out", "vji_ir_out",
    "vs_uir", "vji_uir",
    "vs_sdr", "vji_sdr",
    "vs_cdr", "vji_cdr",
    "jtag_state_rti", "vji_rti",
  };

  my $nios2_oci_jtag_sysclk_syn_port_map = {
    "ir_in",  "vji_ir_in",
    "vs_uir", "vji_uir",
    "vs_udr", "vji_udr",
  };



  my $nios2_oci_jtag_tck_module = &make_nios2_oci_jtag_tck ($Opt);
  my $nios2_oci_jtag_sysclk_module = &make_nios2_oci_jtag_sysclk ($Opt);



  unless (manditory_bool($Opt, "altium_jtag")) {

    my $jtag_module_name =  $Opt->{name}."_jtag_debug_module";
    my $virtual_jtag_instance_id = $Opt->{oci_virtual_jtag_instance_id};

    my $virtual_jtag_parameter_map = {
        sld_mfg_id => 
          $Opt->{internal_nios2} == 1 ? 110 : 70,
        sld_type_id =>
          $Opt->{internal_nios2} == 1 ? 135 : 34,
        sld_version => "3",
        sld_auto_instance_index => 
          $Opt->{oci_assign_jtag_instance_id} ? qq("NO") : qq ("YES"),
        sld_instance_index => $virtual_jtag_instance_id,
        sld_ir_width => $IR_WIDTH,
        sld_sim_action => qq(""),
        sld_sim_n_scan => 0,
        sld_sim_total_length => 0,
    };

    my $virtual_jtag_oport_map = {
        tdi    => "vji_tdi",
        tck    => "vji_tck",
        ir_in  => "vji_ir_in",
        virtual_state_uir  => "vji_uir",
        virtual_state_sdr  => "vji_sdr",
        virtual_state_cdr  => "vji_cdr",
        virtual_state_udr  => "vji_udr",
        jtag_state_rti => "vji_rti",
    };
  
    my $virtual_jtag_iport_map = {
        ir_out => "vji_ir_out",
        tdo    => "vji_tdo",
    };
  
    if (manditory_bool($Opt, "oci_export_jtag_signals")) {
      e_signal->news ( 
        ["vji_tdi",     1,  0],
        ["vji_tck",     1,  0],
        ["vji_ir_in",   1,  0],
        ["vji_uir",     1,  0],
        ["vji_sdr",     1,  0],
        ["vji_cdr",     1,  0],
        ["vji_udr",     1,  0],
        ["vji_rti",     2,  0], 
       
        ["vji_ir_out",  2,  0], 
        ["vji_tdo",     1,  0],
       );
    } else {

      e_blind_instance->new({
        tag           => 'synthesis',
        name          => $jtag_module_name."_phy",
        module        => "sld_virtual_jtag_basic",
        in_port_map   => $virtual_jtag_iport_map,
        out_port_map  => $virtual_jtag_oport_map,
        parameter_map => $virtual_jtag_parameter_map,
        within        => $jtag_wrapper_module,
      });
  
      $jtag_wrapper_module->add_contents(

        e_assign->news (
           { lhs => "vji_tck",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_tdi",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_sdr",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_cdr",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_rti",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_uir",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_udr",  
             rhs => "1'b0", 
             tag => "simulation",
           },
           { lhs => "vji_ir_in",  
             rhs => "2'b0", 
             tag => "simulation",
           },
        ),
        e_comment->new (
           { comment => "Change the sld_virtual_jtag_basic's defparams to\n \
             switch between a regular Nios II or an internally embedded Nios II.\n \
             For a regular Nios II, sld_mfg_id = 70, sld_type_id = 34.\n \
             For an internally embedded Nios II, slf_mfg_id = 110, sld_type_id = 135."
           },
        ),
      );
    }
  }

  $jtag_wrapper_module->add_contents(
    e_instance->new ({
      module  => $nios2_oci_jtag_tck_module,
      port_map  => $nios2_oci_jtag_syn_port_map,
      suppress_open_ports => 1,
    }),
 
    e_instance->new ({
      module  => $nios2_oci_jtag_sysclk_module,
      port_map  => $nios2_oci_jtag_sysclk_syn_port_map,
      suppress_open_ports => 1,
    }),
  );

  return $jtag_wrapper_module;
}


1;



