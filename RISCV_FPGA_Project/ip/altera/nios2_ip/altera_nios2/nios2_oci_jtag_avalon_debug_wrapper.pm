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





sub make_nios2_oci_jtag_avalon_debug_wrapper
{
  my $Opt = shift;

  my $AVALON_DEBUG_PORT_WIDTH = 32;

  print "\nINFO: Creating Avalon debug port OCI wrapper.\n";
  


  



  
  my $jtag_wrapper_module_name = $Opt->{name}."_jtag_debug_module_wrapper";
  my $jtag_wrapper_file_name = $jtag_wrapper_module_name;

  my $jtag_wrapper_module = e_module->new ({
    name  => $jtag_wrapper_module_name,
    output_file => $jtag_wrapper_file_name,
  });


  my $nios2_oci_jtag_syn_port_map = {

    "tck",    "clk",
    "tdi",    "open",
    "ir_in",  "ir_register",
    "tdo",    "open",
    "ir_out", "open",
    "vs_uir", "vji_uir",
    "vs_sdr", "vji_sdr",
    "vs_cdr", "vji_cdr",
    "jtag_state_rti", "vji_rti",


    "sr", "sr",
  };

  my $nios2_oci_jtag_sysclk_syn_port_map = {
    "ir_in",  "ir_register",
    "vs_uir", "vji_uir",
    "vs_udr", "vji_udr",


    "sr", "avalon_debug_port_sr",
  };
  

  my @sr_filtered_array;
  for (my $loop = 0; $loop < $SR_WIDTH ; $loop = $loop + 1) {
      push(@sr_filtered_array, ["sr_filtered[${loop}]"   => "(sr[${loop}] === 1'bx) ? 1'b0 : sr[${loop}]" ],);
  }



  my $nios2_oci_jtag_tck_module = &make_nios2_oci_jtag_tck ($Opt);
  my $nios2_oci_jtag_sysclk_module = &make_nios2_oci_jtag_sysclk ($Opt);

  $jtag_wrapper_module->add_contents (

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
      

      e_port->adds (
        ["avalon_debug_port_address",     2,   "in"],
        ["avalon_debug_port_writedata",   $AVALON_DEBUG_PORT_WIDTH,   "in"],
        ["avalon_debug_port_readdata",    $AVALON_DEBUG_PORT_WIDTH,  "out"],
        ["avalon_debug_port_write",       1,   "in"],
      ),
      e_signal->news (
        ["avalon_debug_port_sr",               $SR_WIDTH,    0,  1],
        ["sr_filtered",               $SR_WIDTH,    0,  1],
        ["state_register",           3,    0,  1],
        ["ir_register",              2,    0,  1],
      ),

      e_assign->news (
         @sr_filtered_array,
      ),

      e_process->new ({
        clock     => "clk",
        asynchronous_contents => [
          e_assign->news (
            ["avalon_debug_port_sr"         => 0],
            ["state_register"               => 0],
            ["ir_register"                  => 0],
          ),
        ],
        contents  => [

              e_if->new ({
                 condition => "avalon_debug_port_write",
                 then  => [
                   e_case->new ({
                     switch => "avalon_debug_port_address",
                     parallel  => 0,
                     full      => 0,
                     contents  => {
                       "3'd0"   => [ #write to state.
                         ["state_register" => "avalon_debug_port_writedata[2:0]"],
                       ],
                       "3'd1"   => [ #write to ir.
                         ["ir_register" => "avalon_debug_port_writedata[1:0]"],
                       ],
                       "3'd3"   => [ #write to sr_msb.
                         ["avalon_debug_port_sr[$SR_WIDTH-1:$AVALON_DEBUG_PORT_WIDTH]" => "avalon_debug_port_writedata[$SR_WIDTH-$AVALON_DEBUG_PORT_WIDTH-1:0]"],
                       ],
                       "3'd2"   => [ #write to sr_lsb.
                         ["avalon_debug_port_sr[$AVALON_DEBUG_PORT_WIDTH-1:0]" => "avalon_debug_port_writedata"],
                       ],
                    }
                   }),
                 ],
                 else => [ #read
                         e_case->new ({
                           switch => "avalon_debug_port_address",
                           parallel  => 0,
                           full      => 0,
                           contents  => {
                             "3'd0"   => [ #read from state. - do we need this?
                               ["avalon_debug_port_readdata" => "state_register | $AVALON_DEBUG_PORT_WIDTH\'b0"], 
                             ],
                             "3'd1"   => [ #read from ir - do we need this?
                               ["avalon_debug_port_readdata" => "ir_register | $AVALON_DEBUG_PORT_WIDTH\'b0"], 
                             ],
                             "3'd3"   => [ #read from sr_msb.  - TODO: only really care about SR_WIDTH - AVALON_DEBUG_PORT_WIDTH bits
                               ["avalon_debug_port_readdata" => "sr_filtered[$SR_WIDTH-1:$AVALON_DEBUG_PORT_WIDTH] | $AVALON_DEBUG_PORT_WIDTH\'b0"],
                             ],
                             "3'd2"   => [ #read from sr_lsb.
                               ["avalon_debug_port_readdata" => "sr_filtered[$AVALON_DEBUG_PORT_WIDTH-1:0]"],
                             ],
                           }, 
                         }),
                 ],
            }),
         ],
      }),


      e_process->new ({
        clock     => "clk",
        asynchronous_contents => [
          e_assign->news (
            ["vji_sdr"   => "1'b0"],  # on reset, everything is 0
            ["vji_uir"   => "1'b0"],
            ["vji_udr"   => "1'b0"],
            ["vji_cdr"   => "1'b0"],
            ["vji_rti"   => "1'b0"],
            ),
        ],
        contents  => [
          e_case->new ({
            switch => "state_register",
            parallel  => 0,
            full      => 0,
            contents  => {
              "3'd0"   => [ #null state - do nothing
                  ["vji_sdr"   => "1'b0"], 
                  ["vji_uir"  => "1'b0"],
                  ["vji_udr"  => "1'b0"],
                  ["vji_cdr" => "1'b0"],
                  ["vji_rti" => "1'b0"],
               ],
              "3'd1"   => [ #vji_uir
                  ["vji_sdr"   => "1'b0"], 
                  ["vji_uir"  => "1'b1"],
                  ["vji_udr"  => "1'b0"],
                  ["vji_cdr" => "1'b0"],
                  ["vji_rti" => "1'b0"],
               ],
              "3'd2"   => [ #vji_udr
                  ["vji_sdr"   => "1'b0"], 
                  ["vji_uir"  => "1'b0"],
                  ["vji_udr"  => "1'b1"],
                  ["vji_cdr" => "1'b0"],
                  ["vji_rti" => "1'b0"],
               ],
              "3'd3"   => [ #vji_sdr
                  ["vji_sdr"   => "1'b1"], 
                  ["vji_uir"  => "1'b0"],
                  ["vji_udr"  => "1'b0"],
                  ["vji_cdr" => "1'b0"],
                  ["vji_rti" => "1'b0"],
               ],
              "3'd4"   => [ #vji_cdr
                  ["vji_sdr"   => "1'b0"], 
                  ["vji_uir"  => "1'b0"],
                  ["vji_udr"  => "1'b0"],
                  ["vji_cdr" => "1'b1"],
                  ["vji_rti" => "1'b0"],
               ],
              "3'd5"   => [ #vji_rti
                  ["vji_sdr"   => "1'b0"], 
                  ["vji_uir"  => "1'b0"],
                  ["vji_udr"  => "1'b0"],
                  ["vji_cdr" => "1'b0"],
                  ["vji_rti" => "1'b1"],
               ],
            }
          }),
        ], # end of e_process contents
      }), # end of e_process
  );

  
  return $jtag_wrapper_module;
}


1;



