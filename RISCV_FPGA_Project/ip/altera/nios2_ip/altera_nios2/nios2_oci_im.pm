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
use nios_tdp_ram;
use europa_all;
use strict;











sub make_nios2_oci_im
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_oci_im",
  });

  my $ext_a_data_width    = $Opt->{oci_tm_width}; # (36)
  my $ext_a_address_width = $Opt->{oci_trace_addr_width};
  my $ext_b_data_width    = $Opt->{oci_tm_width}; # (36)
  my $ext_b_address_width = $Opt->{oci_trace_addr_width};




  $module->add_contents (

    e_signal->news (
      ["tracemem_trcdata",   $Opt->{oci_tm_width}, 1],
      ["tracemem_tw",        1,                    1],
      ["tracemem_on",        1,                    1],
      ["trc_im_addr",        $Opt->{oci_trace_addr_width},  1],
      ["trc_wrap",           1,                    1], # used in itrace, jtag
      ["trc_enb",            1,                    1], # used in itrace
      ["xbrk_wrap_traceoff", 1,                    1], # used in itrace
    ),

    e_signal->news (
      ["jdo",       $TRACEMEM_WIDTH,      0],
      ["tw",        $Opt->{oci_tm_width}, 0],
    ),

  );





  $module->add_contents (

    e_signal->news (
      ["trc_im_data",    $Opt->{oci_tm_width},          0, 1],
      ["trc_on_chip",    1,                             0, 1], # local signal
    ),
    e_assign->new (["trc_im_data", "tw"]),
  );







  my $process_hash = {
    clock     => "clk",
    reset     => "jrst_n",
    asynchronous_contents => [
      e_assign->news (
        ["trc_im_addr" => "0"],
        ["trc_wrap" => "0"],
      ),
    ],
    contents => [
      e_if->new ({
        condition => "!".($Opt->{oci_onchip_trace} ? "1" : "0"),
        then  => [
          ["trc_im_addr" => "0"],
          ["trc_wrap" => "0"],
        ],
        elsif  => {
          condition => "take_action_tracectrl && 
                      (jdo[$TRACECTRL_TAAR_POS] | jdo[$TRACECTRL_TWR_POS])", 
          then => [
            e_if->new ({
              condition => "jdo[$TRACECTRL_TAAR_POS]",
              then => [ ["trc_im_addr" => "0"] ],
            }),
            e_if->new ({
              condition => "jdo[$TRACECTRL_TWR_POS]",
              then => [ ["trc_wrap" => "0"] ],
            }),
          ],
          elsif  => {
            condition => 
              "(trc_enb & trc_on_chip & tw_valid)",     # recording
            then  => [
              ["trc_im_addr" => "trc_im_addr+1"],
              e_if->new ({
                condition => "&trc_im_addr",
                then => [ 
                  e_assign->news (
                    ["trc_wrap" => "1"], 
                  ),
                ],
              }),
            ],
          } # end elsif
        } # end elsif
      }),
    ],
  };

  my $register_hash = {
    out => ["trc_jtag_addr",  $TRACEMEM_A_TRCADDR_MSB_POS -
                              $TRACEMEM_A_TRCADDR_LSB_POS + 1, 
                              0, 1],
    in  => "take_action_tracemem_a ? 
          jdo[$TRACEMEM_A_TRCADDR_MSB_POS : $TRACEMEM_A_TRCADDR_LSB_POS] : 
          trc_jtag_addr + 1",
    enable  => "take_action_tracemem_a ||
                take_no_action_tracemem_a || 
                take_action_tracemem_b", # anytime TRACEMEM is accessed.
  };

  if (!manditory_bool($Opt, "asic_enabled")) {
    $process_hash->{user_attributes_names} = ["trc_im_addr","trc_wrap"];
    $process_hash->{user_attributes} = [
      {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => [qw(D101 D103 R101)],
      },
    ];

    $register_hash->{user_attributes} = [
      {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => [qw(D101)],
      },
    ];
  }

  $module->add_contents (
    e_process->new($process_hash),
    e_register->new($register_hash),
    e_assign->news ( 
      ["trc_enb" => "trc_ctrl[$TRC_ENB_BIT]"],
      ["trc_on_chip" => "~trc_ctrl[$TRC_OFC_BIT]"],
      ["tw_valid" => 
        "|trc_im_data[" . $Opt->{oci_tm_width} . "-1 : " . 
        $Opt->{oci_tm_width} .  "-4]"],
      ["xbrk_wrap_traceoff" => "trc_ctrl[$TRC_FULL_BIT] & trc_wrap"],
    ),
    e_assign->news ( 
      ["tracemem_tw" => "trc_wrap"],
      ["tracemem_on" => "trc_enb"],
    ),
  );



    if (manditory_bool($Opt, "oci_onchip_trace")) {
      $module->add_contents (        
        e_assign->news ( 
          ["tracemem_trcdata" => "trc_jtag_data"],
        ),
      );
    } else {
      $module->add_contents (    
        e_assign->news ( 
          ["tracemem_trcdata" => "0"],
        ),
      );
    }


  if (manditory_bool($Opt, "oci_onchip_trace")) {
    if (manditory_bool($Opt, "export_large_RAMs")) {
      $module->add_contents(
        e_comment->new ({
          comment => 
             ("Export trace RAM ports to top level\n" .
              "because the RAM is instantiated external to CPU.\n"),
        }),
    


        e_signal->new({name => "trc_jtag_data", width => $Opt->{oci_tm_width}}),
        e_signal->new({name => "unused_bdpram_port_q_a", never_export => 1, width => $Opt->{oci_tm_width}}),
    
        e_assign->news (

          [["cpu_lpm_trace_ram_bdp_address_a", $ext_a_address_width] => 
            "trc_im_addr"],
          [["cpu_lpm_trace_ram_bdp_address_b", $ext_b_address_width] => 
            "trc_jtag_addr[$ext_b_address_width-1: 0]"],
          ["cpu_lpm_trace_ram_bdp_clk_en_0" => "1'b1"],
          ["cpu_lpm_trace_ram_bdp_clk_en_1" => "1'b1"],
          [["cpu_lpm_trace_ram_bdp_write_data_a", $ext_a_data_width] => 
            "trc_im_data"],
          [["cpu_lpm_trace_ram_bdp_write_data_b", $ext_b_data_width] => 
            "jdo[36 : 1]"],
          ["cpu_lpm_trace_ram_bdp_write_enable_a" => "tw_valid & trc_enb"],
          ["cpu_lpm_trace_ram_bdp_write_enable_b" => "take_action_tracemem_b"],
    

          ["unused_bdpram_port_q_a" => 
            ["cpu_lpm_trace_ram_bdp_read_data_a", $ext_a_data_width]],
          ["trc_jtag_data" => 
            ["cpu_lpm_trace_ram_bdp_read_data_b", $ext_b_data_width]],
        ),
      );
    } else {
      $module->add_contents(
        e_signal->new({
          name => "unused_bdpram_port_q_a", never_export => 1, 
          width => $Opt->{oci_tm_width}
        }),
        nios_tdp_ram->new ({
          name => $Opt->{name} . "_traceram_lpm_dram_bdp_component",
          Opt                     => $Opt,
          read_latency            => 1,
          a_data_width            => $Opt->{oci_tm_width}, # (36)
          a_address_width         => $Opt->{oci_trace_addr_width},
          b_data_width            => $Opt->{oci_tm_width}, # (36)
          b_address_width         => $Opt->{oci_trace_addr_width},
          implement_as_esb        => 1,
          write_pass_through      => 0,
          intended_device_family  => '"'. $Opt->{device_family} .'"',
      
          port_map => {

            clock       => "clk",
            clocken0  => "1'b1",
            wren_a    => "tw_valid & trc_enb",
            address_a => "trc_im_addr",
            data_a    => "trc_im_data",
            q_a       => "unused_bdpram_port_q_a",
      

            clocken1  => "1'b1",
            wren_b    => "take_action_tracemem_b",
            address_b => "trc_jtag_addr",
            data_b    => "jdo[$TRACEMEM_B_TRCDATA_BITS]",
            q_b       => "trc_jtag_data",
          },
        }),
      );
    }
  }

  return $module;
}


1;

