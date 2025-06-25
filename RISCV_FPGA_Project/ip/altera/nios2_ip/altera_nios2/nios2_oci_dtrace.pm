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



















sub make_nios2_oci_dtrace
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_dtrace",
  });

  my $tm_data_width = $Opt->{oci_tm_width} - 4;    # bits in tm data field



  $module->add_contents (

    e_signal->news (
      ["atm",     $Opt->{oci_tm_width},1], # Formatted data address trace message output
      ["dtm",     $Opt->{oci_tm_width},1], # Formatted data value trace message output

    ),

    e_signal->news (
      ["cpu_d_writedata",     $Opt->{cpu_d_data_width},    0],
      ["cpu_d_readdata",      $Opt->{cpu_d_data_width},    0],
      ["cpu_d_address",       $Opt->{cpu_d_address_width}, 0],
      ["trc_ctrl",            16,                          0],
    ),

  );







  $module->add_contents (
    e_signal->news (
      ["cpu_d_writedata_0_padded", $tm_data_width, 0, 1], 
      ["cpu_d_readdata_0_padded",  $tm_data_width, 0, 1], 
      ["cpu_d_address_0_padded",   $tm_data_width, 0, 1], 
    ),
    e_assign->news (
      ["cpu_d_writedata_0_padded", 
          "cpu_d_writedata | $tm_data_width\'b0"], 
      ["cpu_d_readdata_0_padded",  
          "cpu_d_readdata | $tm_data_width\'b0"], 
      ["cpu_d_address_0_padded",   
          "cpu_d_address | $tm_data_width\'b0"], 
    ),
  );






  $module->add_contents (
    e_assign->news (

    ),
  );






  my $td_mode_module = &make_nios2_td_mode ($Opt);

  $module->add_contents (
    e_instance->new ({
      name    => $Opt->{name}."_nios2_oci_trc_ctrl_td_mode",
      module  => $td_mode_module,
      port_map  => {
        ctrl    => "trc_ctrl[8:0]",
        td_mode => "td_mode_trc_ctrl",
      },
    }),
    e_assign->news (
      ["{record_load_addr, record_store_addr,
         record_load_data, record_store_data}" => "td_mode_trc_ctrl"],
    ),

    e_process->new ({
      clock     => "clk",
      reset     => "jrst_n",
      user_attributes_names => ["atm", "dtm"],
      user_attributes => [
        {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(R101)],
        },
      ],
      asynchronous_contents => [
        e_assign->news (
          ["atm" => "0"],
          ["dtm" => "0"],
        ),
      ],
      contents  => [
        e_if->new ({
          condition => ($Opt->{oci_data_trace} ? "(1)" : "(0)"),
          then  => [
            e_if->new ({
              condition => "(cpu_d_write & ~cpu_d_wait & record_store_addr)",
              then  => [ ["atm" => "{$TM_STA, cpu_d_address_0_padded}"], ],
              elsif => {
                condition => "(cpu_d_read & ~cpu_d_wait & record_load_addr)",
                then  => [ ["atm" => "{$TM_LDA, cpu_d_address_0_padded}"], ],
                else  => [ ["atm" => "{$TM_NOP, cpu_d_address_0_padded}"], ],
              },
            }),
            e_if->new ({
              condition => "cpu_d_write & ~cpu_d_wait & record_store_data",
              then => [ ["dtm" => "{$TM_STD, cpu_d_writedata_0_padded}"] ],
              elsif => {
                condition => "cpu_d_read & ~cpu_d_wait & record_load_data",
                then => [ ["dtm" => "{$TM_LDD, cpu_d_readdata_0_padded}"],],
                else => [ ["dtm" => "{$TM_NOP, cpu_d_readdata_0_padded}"],],
              },
            }),
          ],
          else  => [
            ["atm" => "0"],
            ["dtm" => "0"],
          ],
        }),
      ],
    }),
      
  );

  return $module;
} # end module make_nios2_oci_dtrace


sub make_nios2_td_mode
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_td_mode",
  });



  $module->add_contents (

    e_signal->news (
      ["ctrl",    9, 0,], 
      ["td_mode", 4, 1,],
    ),

    e_assign->new ([["ctrl_bits_for_mux", 3, 0, 1], "ctrl[$TRC_TD_BITS]"]),

    e_process->new ({
      clock => "",
      contents  => [
        e_case->new ({
          switch  => "ctrl_bits_for_mux",
          parallel  => 0,
          full      => 0,
          contents  => {   
            "3'b000" => [td_mode => "4'b0000"],    # no data trace
            "3'b001" => [td_mode => "4'b1000"],    # la
            "3'b010" => [td_mode => "4'b0100"],    #    sa
            "3'b011" => [td_mode => "4'b1100"],    # la sa
            "3'b100" => [td_mode => "4'b0010"],    #       ld
            "3'b101" => [td_mode => "4'b1010"],    # la    ld
            "3'b110" => [td_mode => "4'b0101"],    #    sa    sd
            "3'b111" => [td_mode => "4'b1111"],    # la sa ld sd
          },
        }),
      ],
    }),
  );

  return $module;
} # end module 

1;
