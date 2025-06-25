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






















package nios2_third_party_debugger_gasket;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_nios2_third_party_debugger_gasket
);

use cpu_utils;
use nios2_insts;
use europa_all;
use europa_utils;   # for validate_parameter
use strict;

sub make_nios2_third_party_debugger_gasket
{
  my ($Opt, $top_module) = @_;

  my $gasket_module_name = $Opt->{name}."_third_party_debugger_gasket";
  my $module = e_module->new({name => $gasket_module_name}) ;
  my $marker = e_default_module_marker->new($module);

  &validate_nios2_third_party_debug_parameters ($Opt);
 



  my @basic_contents = (
    e_assign->news (


      [["debug_debugack", 1, 1],        "~hbreak_enabled"],

      [["oci_hbreak_req", 1, 1],        "debug_debugreq"],
      [["oci_ienable", 32, 1],          "debug_ienable"],
      [["oci_single_step_mode", 1, 1],  "debug_single_step_mode"],
    ),
  );
  $module->add_contents (@basic_contents);

  $module->add_contents (
    &make_nios2_third_party_debugger_advanced_ports ($Opt, $top_module)) 
      if ($Opt->{include_third_party_debug_port_advanced});


  $top_module->add_contents (
    e_instance->new ({


      module => $module,
      port_map  => {
      },
    }), 
  );

  return $module;
}

sub make_nios2_third_party_debugger_advanced_ports
{
  my ($Opt, $top_module) = @_;





  my $tm_data_width = $Opt->{oci_tm_width} - 4;    # bits in tm data field

  my @advanced; 

  my $is_fast  = ($Opt->{core_type} eq "fast") ? 1 : 0;
  my $is_small = ($Opt->{core_type} eq "small") ? 1 : 0;
  my $is_tiny  = ($Opt->{core_type} eq "tiny") ? 1 : 0;
  ($is_fast ^ $is_small ^ $is_tiny) or 
    &$error ("Unable to determine CPU Implementation ".  $Opt->{core_type});
  



  push @advanced, (
    e_assign->news (
      [["debug_hw_break_address", $Opt->{cpu_i_address_width}, 1], 
                                      "{F_pc, 2'b00}"],
    ),
  );

  if ($is_tiny) {
    push @advanced, (
      e_assign->add ([["debug_hw_break_address_valid", 1, 1], "D_valid"]),
    );
  } else {  # valid for both small and fast
    push @advanced, (
      e_assign->add ([["debug_hw_break_address_valid", 1, 1], "D_en"]),
    );
  }





  push @advanced, (
    e_signal->news (
        ["debug_instr_trace_address",    $Opt->{cpu_i_data_width}, 1],
        ["debug_instr_trace_next_instr", $Opt->{cpu_i_data_width}, 1], 
    ),
  );
  if ($is_fast) {

    my $advanced_exc = $Opt->{advanced_exc};

    push @advanced, (
      e_assign->news (

        ["debug_instr_trace_cond_branch",  
              "A_op_bge | A_op_blt | A_op_bne | A_op_bgeu | 
               A_op_bltu | A_op_beq"],
        ["debug_instr_trace_uncond_branch", "A_op_br | A_op_call"], 
        ["debug_instr_trace_branch_taken",  "A_cmp_result"],

        ["debug_instr_trace_jump", 
              "A_op_jmp | A_op_callr | A_op_ret | A_op_eret | A_op_bret"],
        ["debug_instr_trace_interrupt","A_ctrl_exception"],
        ["debug_instr_trace_address",     "A_pcb"],  
        ["debug_instr_trace_next_instr","d1_A_wr_data"],         
        ["debug_instr_trace_debug_mode", 
          $advanced_exc ? "debug_debugack" : "d1_debugack"],         


        [["debug_instr_trace_valid", 1, 1], "A_valid & A_en"],
      ),





      e_register->new ({
        out => ["d1_debugack", 1, 0, 1],
        in  => "debug_debugack",
        enable  => "debug_instr_trace_valid",
      }),
      e_register->new ({
        out => ["d1_A_wr_data", $tm_data_width, 0, 1],
        in  => "A_wr_data_filtered",
        enable  => "debug_instr_trace_valid",
      }),
    );
  } elsif ($is_small) {
    push @advanced, (
      e_assign->news (

        ["debug_instr_trace_cond_branch",  
              "M_op_bge  | M_op_blt | M_op_bne | M_op_bgeu | 
               M_op_bltu | M_op_beq"],
        ["debug_instr_trace_uncond_branch", "M_op_br | M_op_call"], 
        ["debug_instr_trace_branch_taken",  "M_cmp_result"],

        ["debug_instr_trace_jump",       
              "M_op_jmp | M_op_callr | M_op_ret | M_op_eret | M_op_bret"],
        ["debug_instr_trace_interrupt","M_ctrl_exception"],
        ["debug_instr_trace_address",    "M_pcb"],  
        ["debug_instr_trace_next_instr", "M_wr_data_filtered"],         
        ["debug_instr_trace_debug_mode", "d1_debugack"],         


        [["debug_instr_trace_valid", 1, 1], "M_valid & M_en"],
      ),



      e_register->new ({
        out => ["d1_debugack", 1, 0, 1],
        in  => "debug_debugack",
        enable  => "debug_instr_trace_valid",
      }),
    );
  } elsif ($is_tiny) {
    print "Trace is not supported in tiny.  Tying off trace signals to 0.\n"
      if (($Opt->{oci_onchip_trace}) || ($Opt->{oci_offchip_trace}));
    push @advanced, (
      e_assign->news (
        ["debug_instr_trace_cond_branch",   "1'b0"],  
        ["debug_instr_trace_uncond_branch", "1'b0"], 
        ["debug_instr_trace_branch_taken",  "1'b0"],
        ["debug_instr_trace_jump",          "1'b0"],
        ["debug_instr_trace_interrupt",     "1'b0"],
        ["debug_instr_trace_address",       "1'b0"],  
        ["debug_instr_trace_next_instr",    "1'b0"],         
        ["debug_instr_trace_debug_mode",    "1'b0"],         


        [["debug_instr_trace_valid", 1, 1], "1'b0"],
      ),
    );
  }





  push @advanced, (
    e_signal->news (
      ["debug_data_trace_writedata",     $Opt->{cpu_d_data_width},    1],
      ["debug_data_trace_readdata",      $Opt->{cpu_d_data_width},    1],
      ["debug_data_trace_address",       $Opt->{cpu_d_address_width}, 1],
    ),
  );
  if ($is_fast) {


    push @advanced, (
      e_assign->news (
        ["debug_data_trace_address",   "A_mem_baddr" ],
        ["debug_data_trace_readdata",  "A_wr_data_filtered" ],
        ["debug_data_trace_read",      "A_ctrl_ld & A_valid" ],
        ["debug_data_trace_writedata", "A_st_data" ],
        ["debug_data_trace_write",     "A_ctrl_st & A_valid" ],
        ["debug_data_trace_wait",      "~A_en" ],
      ),
    );
  } elsif ($is_small) {


    push @advanced, (
      e_assign->news (
        ["debug_data_trace_address",   "M_mem_baddr" ],
        ["debug_data_trace_readdata",  "M_wr_data_filtered" ],
        ["debug_data_trace_read",      "M_ctrl_ld & M_valid" ],
        ["debug_data_trace_writedata", "M_st_data" ],
        ["debug_data_trace_write",     "M_ctrl_st & M_valid" ],
        ["debug_data_trace_wait",      "~M_en" ],
      ),
    );
  } elsif ($is_tiny) {


    push @advanced, (
      e_assign->news (
        ["debug_data_trace_address",   "d_address" ],
        ["debug_data_trace_readdata",  "av_ld_data_aligned_filtered" ],
        ["debug_data_trace_read",      "d_read" ],
        ["debug_data_trace_writedata", "E_st_data" ],
        ["debug_data_trace_write",     "d_write" ],
        ["debug_data_trace_wait",      "d_waitrequest" ],
      ),
    );
  } else {

    &$error ("No third-party debug support with Turbo variant");
  }

  return @advanced;
}


sub validate_nios2_third_party_debug_parameters 
{
  my $Opt = shift;

  &validate_parameter ({  # width of cpu inst addr bus
    hash    => $Opt,
    name    => "cpu_i_address_width",
    type    => "integer",
    default => $Opt->{i_Address_Width},
  });
  &validate_parameter ({  # width of cpu inst data bus
    hash    => $Opt,
    name    => "cpu_i_data_width",
    type    => "integer",
    default => 32,
  });
  &validate_parameter ({  # width of cpu data addr bus
    hash    => $Opt,
    name    => "cpu_d_address_width",
    type    => "integer",
    default => $Opt->{d_Address_Width},
  });
  &validate_parameter ({  # width of cpu data data bus
    hash    => $Opt,
    name    => "cpu_d_data_width",
    type    => "integer",
    default => 32,
  });

  &validate_parameter ({  # support advanced port?
    hash    => $Opt,
    name    => "include_third_party_debug_port_advanced",
    type    => "boolean",
    default => 1,
  });
}


1;

