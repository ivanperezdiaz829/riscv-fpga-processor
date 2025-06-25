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






















use europa_all;
use strict;
use e_efifo;




















my $sdram_data_width;
my $sdram_bank_width;
my $sdram_num_chipselects;
my $sdram_col_width;
my $sdram_row_width;
my $cas_latency;
my $init_refresh_commands;
my $controller_addr_width;
my $trp;
my $trfc;
my $tmrd;
my $trcd;
my $twr;
my $dqm_width;
my $num_chipselects;
my $num_chipselect_address_bits;





sub Validate_Sdram_Options
{
    my ($Options) = (@_);
      

    



    &validate_parameter({
        hash => $Options,
        name => "sdram_data_width",
        type => "integer",
        allowed => [8, 16, 32, 64],
    });
    


    &validate_parameter({
        hash => $Options,
        name => "sdram_bank_width",
        type => "integer",
        allowed => [1, 2],
    });
    
    &validate_parameter({
        hash => $Options,
        name => "sdram_num_chipselects",
        type => "integer",
        allowed => [1, 2, 4, 8],
    });
    


    &validate_parameter({
        hash => $Options,
        name => "cas_latency",
        type => "integer",
        allowed => [0 .. 7],
    });



    &validate_parameter({
        hash => $Options,
        name => "init_refresh_commands",
        type => "integer",
        allowed => [1 .. 8],
    });
    


    ($Options->{cas_latency} < 1 or $Options->{cas_latency} > 3) and 
        goldfish("weird CAS latency: '", $Options->{cas_latency}, "'");


    my %time_values = get_time_values();
    

    convert_times($Options, \%time_values);
    


    $trp     = $Options->{t_rp}  - 1;
    $trfc    = $Options->{t_rfc} - 1;
    $tmrd    = $Options->{t_mrd};
    $trcd    = $Options->{t_rcd};
    $twr     = $Options->{t_wr}; # This FSM does not do auto_precharge
    
    if (0 == $twr)
    {
        ribbit("T_WR = 0.  Need to update ptf file?\n");
    }
    
    $dqm_width = $Options->{sdram_data_width} / 8;
    if (int($dqm_width) != $dqm_width)
    {
        ribbit
            (
             "Unexpected: SDRAM data width '", $Options->{sdram_data_width}, "', ".
             "leads to non-integer DQM width ($dqm_width)"
             );
    }
    
    $sdram_data_width       = $Options->{sdram_data_width};
    $sdram_bank_width       = $Options->{sdram_bank_width};
    $sdram_num_chipselects  = $Options->{sdram_num_chipselects};
    $sdram_col_width        = $Options->{sdram_col_width};
    $sdram_row_width        = $Options->{sdram_row_width};
    $cas_latency            = $Options->{cas_latency};
    $init_refresh_commands  = $Options->{init_refresh_commands};



    $num_chipselects = $sdram_num_chipselects;
    $num_chipselect_address_bits = log2($num_chipselects);
    


    $controller_addr_width =
        $num_chipselect_address_bits +
        $sdram_bank_width +
        $sdram_col_width +
        $sdram_row_width;
    






}

sub convert_times
{
    my ($Options, $time_values) = @_;
    
    my $sys_clk = $Options->{system_clock_rate};

    for my $k (keys %{$time_values})
    {
        $Options->{$k} .= $time_values->{$k};
        convert_time_unit(\$Options->{$k}, $sys_clk);
    }
} # &convert_times














sub convert_time_unit
{
    my ($valRef, $system_clock_rate) = @_;
    
    my $result = $$valRef;

    my $system_clock_period = 1 / $system_clock_rate;

    $result =~ s/ms/*(1e-3)/g;
    $result =~ s/us/*(1e-6)/g;
    $result =~ s/ns/*(1e-9)/g;
    $result =~ s/cycle[s]?/*($system_clock_period)/g;
    

    $result = eval($result);  

    $result = ceil ($result * $system_clock_rate);



    if ($@)
    {
        ribbit("failed to eval '$$valRef' in convert_time_unit(): '$@'");
    }
    
    $$valRef = $result;
} # & convert_time_unit

sub get_time_values
{

  return (
    refresh_period        => "us",
    powerup_delay         => "us",
    t_rfc                 => "ns",
    t_mrd                 => "cycles",
    t_rp                  => "ns",
    t_rcd                 => "ns",
    t_ac                  => "ns",
    t_wr                  => "ns",
    init_nop_delay        => "us",
  );
} # &get_time_values





sub replicate_bit
{

  my $width = shift
      or ribbit("Usage error: no width! ".
                "(expected 'replicate_bit(width, value)')\n");
  $width =~ /^\d+$/ or die "Unexpected width: '$width'\n";
  

  my $value = shift;
  ribbit("Usage error: bad value '$value'!\n")
    if $value !~ /^[01]$/;

  ribbit("Usage error: too many parameters! ".
         "(expected 'replicate_bit(width, value)')\n") if @_;
  
  $value =~ /^\d+$/ or die "Unexpected value: '$value'\n";
  
  return $width . "'b" . ($value x $width);
} # &replicate_bit


sub make_sdram_controller
{
    my ($module, $Options) = (@_);

    if (!@_)
    {


        return 0; # make_class_ptf();
    }
    



    



    my $lang = $Options->{project_info}{language};
    


    my $sim_model_base = $Options->{sim_model_base};
    if (!$sim_model_base)
    {

        my @write_lines = 
            (
             "",
             "This reference design requires a vendor simulation model.",
             "To simulate accesses to SDRAM, you must:",
             "\t - Download the vendor model",
             "\t - Install the model in the system_sim directory",
             );


        if ($lang =~ /vhd/i)
        {
            push @write_lines,
            (
             "\t - Add the vendor file to the list of files passed to 'vcom' in setup_sim.do"
             );
        }
        elsif ($lang =~ /verilog/i)
        {
            push @write_lines,
            (
             "\t - `include the vendor model in the the top-level system file,",
             );
        }
        push @write_lines,
        (
         "\t - Instantiate sdram simulation models and wire them to testbench signals",
         "\t - Be aware that you may have to disable some timing checks in the vendor model",
         "\t\t   (because this simulation is zero-delay based)",
         ""
         );
        

        map {$_ = e_sim_write->new({spec_string => $_ . '\\n'})} @write_lines;
        


        if (@write_lines)
        {
            my $init = e_initial_block->new({
                tag => "simulation",
                contents => [
                             @write_lines,
                             ],
                });
            $module->add_contents($init);
        }












    } # we have a non altera-sodimm sim_model_base...













    

    Validate_Sdram_Options($Options);
  


    $module->add_contents
        (
         e_assign->new({
             lhs => e_signal->new({name => "clk_en", never_export => 1}),
             rhs => 1,
         })
         );
    














    my @port_list = 
        (
         e_port->new({name => "clk",                 type => "clk",}),
         e_port->new({name => "reset_n",             type => "reset_n",}),
         e_port->new({name => "az_cs",               type => "chipselect",}),
         e_port->new({name => "az_rd_n",             type => "read_n",}),
         e_port->new({name => "az_wr_n",             type => "write_n",}),
         e_port->new({name => "az_be_n",             type => "byteenable_n",
                      width => $dqm_width}),
         e_port->new({name => "az_addr",             type => "address",
                      width => $controller_addr_width,}),
         e_port->new({name => "az_data",             type => "writedata",
                      width => $Options->{sdram_data_width}}),
         e_port->new({name => "za_data",             type => "readdata",
                      width=>$Options->{sdram_data_width},direction => "output"}),
         e_port->new({name => "za_valid",            type => "readdatavalid",
                      direction => "output"}),
         e_port->new({name => "za_waitrequest",      type => "waitrequest",
                      direction => "output"}),
         );

    my $tpm_addr_width = $Options->{sdram_addr_width};
    my $tristate_bridge_mode = $Options->{shared_data};
    my $starvation_int = $Options->{starvation_interrupt};





    if ($tristate_bridge_mode == 1)
    {

        push @port_list,
        (
         e_port->new({name      => "tz_waitrequest"}),
         e_port->new({name      => "tz_data", 
                      width     => $Options->{sdram_data_width}}),
         e_port->new({name      => "zt_data", 
                      width     => $Options->{sdram_data_width},
                      direction => "output"}),
         e_port->new({name      => "zt_dqm",
                      width     => $dqm_width,
                      direction => "output"}),
         e_port->new({name      => "zt_addr",
                      width=>$Options->{sdram_addr_width},
                      direction => "output"}),
         e_port->new({name => "zt_ba",
                      width=>$Options->{sdram_bank_width},
                      direction => "output"}),
         e_port->new({name => "zt_oe",             
                      direction => "output"}),
         e_port->new({name => "zt_cke",
                      direction => "output"}),
         e_port->new({name => "zt_we_n",
                      direction => "output"}),
         e_port->new({name => "zt_cas_n",
                      direction => "output"}),
         e_port->new({name => "zt_ras_n",
                      direction => "output"}),
         e_port->new({name => "zt_cs_n", 
                      width => $num_chipselects,
                      direction => "output"}),


         e_port->new({name => "zt_lock_n",
                      direction => "output"}),
         e_port->new({name => "tz_readdatavalid"}),
         );
        if ($starvation_int == 1)
        {
            push @port_list,
            (
             e_port->new({name => "za_cannotrefresh", # type => "irq",
                          direction => "output"}),
             );
        }
        
        my @sideband_signals = qw (sdram_bank 
                                   sdram_ras_n
                                   sdram_cas_n
                                   sdram_we_n
                                   sdram_cs_n
                                   sdram_clockenable);


        $module->add_contents(
                              e_avalon_master->new({
                                 name => 'tristate_master',
                                 sideband_signals => \@sideband_signals,
                                 SBI_section => {
                                     Address_Width => $tpm_addr_width,
                                     Data_Width => $Options->{sdram_data_width},
                                     Is_Enabled => 1,
                                     Is_Visible => 0,
                                 },                        
                                 type_map => {
                                    tz_readdatavalid => 'readdatavalid',
                                    tz_waitrequest   => 'waitrequest',
                                    tz_data          => 'readdata',
                                    zt_data          => 'writedata',
                                    zt_dqm           => 'byteenable_n',
                                    zt_addr          => 'address',
                                    zt_cke           => 'sdram_clockenable',
                                    zt_ba            => 'sdram_bank',
                                    zt_we_n          => 'sdram_we_n',
                                    zt_cas_n         => 'sdram_cas_n',
                                    zt_ras_n         => 'sdram_ras_n',
                                    zt_oe            => 'write',
                                    zt_cs_n          => 'sdram_cs_n',

                                    zt_lock_n        => 'arbiterlock_n',
                                    zt_chipselect    => 'chipselect',
                                 },
                              }));



    }
    else
    {


        push @port_list,
        (
         e_port->new({name => "zs_dq",              type => undef,
                      width => $Options->{sdram_data_width},
                      direction => "inout"}),
         e_port->new({name => "zs_dqm",             type => undef,
                      width => $dqm_width,          direction => "output"}),
         e_port->new({name => "zs_ba",              type => undef,
                      width=>$Options->{sdram_bank_width},direction => "output"}),
         e_port->new({name => "zs_addr",            type => undef,
                      width => $tpm_addr_width,     direction => "output"}),
         e_port->new({name => "zs_cke",             type => undef,
                      direction => "output"}),
         e_port->new({name => "zs_ras_n",           type => undef,
                      direction => "output"}),
         e_port->new({name => "zs_cas_n",           type => undef,
                      direction => "output"}),
         e_port->new({name => "zs_we_n",            type => undef,
                      direction => "output"}),
         e_port->new({name => "zs_cs_n",            type => undef,
                      width => $num_chipselects,    direction => "output"}),
         );
    }
    
    $module->add_contents(@port_list);

    my %type_map = ();
    my $temp_name;
    for (@port_list)
    {
        if (defined ($_->type()))
        {
            $temp_name = $_->name();

            if ($_->type() !~ /^tpm_/)
            {
                $type_map{$temp_name} = $_->type();

            }
        }
    }





    $module->add_contents(
                          e_avalon_slave->new({
                              name => "s1", #$module->name()."_s1",
                              type_map => \%type_map,
                          })
                          );
    
    if ($tristate_bridge_mode == 1)
    {





        my %shared_type_map = ();
        for (@port_list)
        {
            if (defined ($_->type()))
            {
                $temp_name = $_->{name};

                if ($_->type() =~ /^tpm_/)
                {
                    $shared_type_map{$temp_name} = $_->{type};

                }
            }
        }

        if ($num_chipselects == 1)
        {
            $module->add_contents
                (
                 e_assign->news
                 (
                  ["m_csn" => "init_done ? m_cmd[3] : i_cmd[3]"],
                  ["m_qualified_csn" => "m_csn | tz_waitrequest"],
                  ),
                 );
        }
        else # more than 1 chipselect...
        {
            $module->add_contents
                (
                 e_signal->new(["m_csn" => $num_chipselects]),
                 e_signal->new(["m_qualified_csn" => $num_chipselects]),
                 e_assign->news
                 (
                  ["m_csn" => "init_done".
                              " ? m_cmd[".(2+$num_chipselects).":3]".
                              " : i_cmd[".(2+$num_chipselects).":3]"],
                  ["m_qualified_csn" 
                   => "m_csn | {".$num_chipselects."{tz_waitrequest}}"],
                  ),
                 );
        }


        $module->add_contents
            (






             e_assign->news
             (
              ["zt_addr"   => "init_done ? m_addr : i_addr"],
              ["zt_cke"    => "clk_en"],
              ["zt_data"   => "m_data"],
              ["zt_dqm"    => "m_dqm"],
              ["zt_ba"     => "m_bank"],
              ["zt_oe"     => "oe"],
              ["zt_we_n"   => "init_done ? m_cmd[0] : i_cmd[0]"],
              ["zt_cas_n"  => "init_done ? m_cmd[1] : i_cmd[1]"],
              ["zt_ras_n"  => "init_done ? m_cmd[2] : i_cmd[2]"],
              ["zt_cs_n"   => "m_qualified_csn"],

              ["zt_lock_n" => "&m_csn"],
              ["zt_chipselect" => "~zt_lock_n"],
              ),
             );

    }
    else
    {

        $module->add_contents
            (
             e_assign->news
             (
              ["{zs_cs_n, zs_ras_n, zs_cas_n, zs_we_n}" => "m_cmd"],
              ["zs_addr" => "m_addr"],
              ["zs_cke"  => "clk_en"],
              ["zs_dq"   => "oe?m_data:{".$Options->{sdram_data_width}."{1'bz}}"],
              ["zs_dqm"  => "m_dqm"],
              ["zs_ba"   => "m_bank"],
              ),
             );



















    }
    

    my ($top_bank_addr, $bottom_bank_addr, $top_row_addr,
        $bottom_row_addr, $top_col_addr, $bottom_col_addr);

    if ($Options->{sdram_bank_width} == 1)
    {
        $top_bank_addr   = $controller_addr_width;  # NOT USED!
        $bottom_bank_addr= $Options->{sdram_col_width};
        
        $top_row_addr    =
            $controller_addr_width - ($num_chipselect_address_bits + 1);
        $bottom_row_addr = $Options->{sdram_col_width} + 1;

        
        $top_col_addr    = $Options->{sdram_col_width} - 1;
        $bottom_col_addr = 0;
    }
    else
    {
        $top_bank_addr   =
            $controller_addr_width - 1 - $num_chipselect_address_bits;
        $bottom_bank_addr=
            $Options->{sdram_col_width};
        
        $top_row_addr    =
            $controller_addr_width - 2 - $num_chipselect_address_bits;
        $bottom_row_addr =
            $top_row_addr - $Options->{sdram_addr_width} + 1;
        
        $top_col_addr    =
            $Options->{sdram_col_width} - 1;
        $bottom_col_addr = 0;
    }

    $module->add_contents
        (
         e_signal->new(["f_select"]),
         e_assign->new(["f_select" => "f_pop & pending"]),
         );
    
    my $csn_for_refresh;
    if ($num_chipselect_address_bits > 0)
    {   # for multiple chipselects, set up real compare/decode





        $module->add_contents
            (
             e_signal->news
             (
              {name => "f_cs_n",       width => $num_chipselect_address_bits},
              {name => "active_cs_n",  width => $num_chipselect_address_bits},
              {name => "cs_n",         width => $num_chipselect_address_bits},
              {name => "csn_decode",   width => $num_chipselects},
              ),
             e_assign->news({lhs => "{f_rnw, f_cs_n, f_addr, f_dqm, f_data}",
                            rhs => "fifo_read_data"}),
             e_assign->new(["cs_n" => "f_select ? f_cs_n : active_cs_n"]),
             );
        foreach my $select (0 .. ($num_chipselects - 1))
        {
            $module->add_contents
                (
                 e_assign->new
                 (
                  {lhs =>"csn_decode[".$select."]",
                   rhs =>"cs_n != ".$num_chipselect_address_bits."'h".$select},
                  ),
                 );
        }
        $csn_for_refresh = "{".$num_chipselect_address_bits."{1'b1}}";
    }
    else
    {   # for 1 chipselect (no address bits), compare/decode is trivial:
        $module->add_contents
            (
             e_assign->news
             (
              ["f_cs_n"     => "1'b0"],
              ["cs_n"       => "f_select ? f_cs_n : active_cs_n"],
              ["csn_decode" => "cs_n"],
              ),
             e_assign->new({lhs => "{f_rnw, f_addr, f_dqm, f_data}",
                            rhs => "fifo_read_data"}),
             );
        $csn_for_refresh = "1'b1";
    }


    $module->add_contents
        (
         e_signal->news
         (
          {name => "f_addr",
           width => $controller_addr_width - $num_chipselect_address_bits, },
          {name => "active_addr",
           width => $controller_addr_width - $num_chipselect_address_bits, },
          {name => "f_data",           width => $Options->{sdram_data_width}},
          {name => "active_data",      width => $Options->{sdram_data_width}},
          {name => "f_dqm",            width => $dqm_width},
          {name => "active_dqm",       width => $dqm_width},
          {name => "f_bank",           width => $Options->{sdram_bank_width}},
          {name => "active_bank",      width => $Options->{sdram_bank_width}},
          {name => "fifo_read_data",   
           width => 
         ($controller_addr_width + $dqm_width + $Options->{sdram_data_width} + 1)},
          ),
         e_instance->new
         ({ # let this auto-name the instance:

             _module_name =>
                 e_efifo->new
                 ({
                     name_stub  => $module->name()."_input",
                     data_width =>
            1 + $controller_addr_width + $dqm_width + $Options->{sdram_data_width},
                     depth      => 2,
                 }),
             port_map  => {
                 "wr"          => "(~az_wr_n | ~az_rd_n) & !za_waitrequest",
                 "rd"          => "f_select",
                 "wr_data"     => "{az_wr_n, az_addr, az_wr_n ? ${dqm_width}'b0 : az_be_n, az_data}",
                 "rd_data"     => "fifo_read_data",
                 "empty"       => "f_empty",
                 "full"        => "za_waitrequest",
             },   
         }),

         e_signal->news
         (
          {name => "almost_full",      never_export => 1},
          {name => "almost_empty",     never_export => 1},
          ),
         );
    

    if ($Options->{sdram_bank_width} == 1)
    {
        $module->add_contents
            (
             e_assign->new
             (["f_bank" => "f_addr[$bottom_bank_addr]"]),
             );
    }
    else
    {
        $module->add_contents
            (
             e_assign->new
             (["f_bank"=>"{f_addr[$top_bank_addr],f_addr[$bottom_bank_addr]}"]),
             );
    }

























    










    











    
    my $refresh_counter_reload_value = $Options->{refresh_period} - 1;

    



    my $init_countdown_value = $Options->{powerup_delay} + $Options->{init_nop_delay};



    my $refresh_counter_width =
     Bits_To_Encode(max($refresh_counter_reload_value, $init_countdown_value));
    
    $module->add_contents
        (
         e_signal->new({
             name => "refresh_counter",
             width => $refresh_counter_width,
         }),
         e_process->new
         ({
             comment => " Refresh/init counter.",
             contents => 
                 [
                  e_if->new({
                      condition => "(refresh_counter == 0)",
                      then => [e_assign->new({
                          lhs => "refresh_counter",
                          rhs => $refresh_counter_reload_value,
                      })],
                      else => [e_assign->new({
                          lhs => "refresh_counter",
                          rhs => "refresh_counter - 1'b1",
                      })],
                  }),
                  ],
             asynchronous_contents => 
                 [
                  e_assign->new({
                      lhs => "refresh_counter",
                      rhs => $init_countdown_value
                      }),
                  ],
          }),
         );
    

    $module->add_contents
        (
         e_register->new({
             comment   => " Refresh request signal.",
             in        => "((refresh_counter == 0) | refresh_request)".
                 " & ~ack_refresh_request & init_done",
             out       => e_signal->new({name => "refresh_request"}),
             enable    => undef,
         })
         );


    $module->add_contents
        (
         e_register->new({
             comment   =>
 " Generate an Interrupt if two ref_reqs occur before one ack_refresh_request",
             in        => "(refresh_counter == 0) & refresh_request",

             out       => e_signal->new({name => "za_cannotrefresh",
                                         never_export => 1}),
             enable    => undef,
             })
         );


    my @signals = ("i_cmd", "m_cmd");
    foreach my $signal (@signals)
    {
        $module->add_contents
            (e_signal->new({name => "$signal",
                            width => 3 + $num_chipselects }));
    }
    @signals = ("i_addr", "m_addr");
    foreach my $signal (@signals)
    {
        $module->add_contents
            (e_signal->new({name => "$signal",
                            width => $Options->{sdram_addr_width}}));
    }
    








    my ( $I_RESET, $I_PRECH, $I_WAIT,  $I_ARF,   $I_LMR,   $I_INIT) =
        ("3'b000", "3'b001", "3'b011", "3'b010", "3'b111", "3'b101");








    $module->add_contents(
                          e_signal->new({
                              name => "init_done",
                          }),
                          e_register->new({
                              comment => " Initialization-done flag.",
                              in => "init_done | (i_state == $I_INIT)",
                              out => "init_done",
                              enable => undef,
                          })
                          );


    my ($LMR,$REFRESH,$PRECHARGE,$ACTIVE,$WRITE,$READ,$BURST,$NOP,$INHIBIT) =
       ("3'h0","3'h1","3'h2",   "3'h3", "3'h4","3'h5","3'h6","3'h7","3'h7");



    my $ALL = "{".$num_chipselects."{1'b0}}";
    my $NONE= "{".$num_chipselects."{1'b1}}";
    



    my $none_and_inhibit = replicate_bit(3 + $num_chipselects, 1);








    my $MRD = "{{".($Options->{sdram_addr_width} - 10).
        "{1'b0}},1'b0,2'b00,3'h".$Options->{cas_latency}.",4'h0}";

    @signals = ("i_state", "i_next");
    foreach my $signal (@signals)
    {
        $module->add_contents
            (e_signal->new({name => "$signal", width => 3}));
    }
    
    my $initfsm_counter_width =
        Bits_To_Encode(max($trp, $trfc, $tmrd, $trcd, $twr));
    

    $module->add_contents
        (e_signal->news
         (
          {name => "i_count", width => $initfsm_counter_width},
          {name => "i_refs",  width => 3},
          )
         );


    


    my %i_contents_hash =
        (
         $I_RESET => [
                      e_assign->news
                      (
                       ["i_cmd"  => $none_and_inhibit],
                       ["i_refs" => "3'b0"],
                       ),
                      e_if->new
                      ({
                          comment => "Wait for refresh count-down after reset",
                          condition => "refresh_counter == 0",
                          then => ["i_state" => $I_PRECH],
                      }),
                      ],
         $I_PRECH => [
                      e_assign->news
                      (
                       ["i_state"=>$I_WAIT],
                       ["i_cmd"  =>"{".$ALL.",".$PRECHARGE."}"],
                       ["i_count"=>$trp],
                       ["i_next" =>$I_ARF],
                       ),
                      ],
         $I_ARF   => [
                      e_assign->news
                      (
                       ["i_cmd"  => "{".$ALL.",".$REFRESH."}"],
                       ["i_refs" => "i_refs + 1'b1"],
                       ["i_state"=> $I_WAIT],
                       ["i_count"=> $trfc],
                       ),
                      e_if->new
                      ({
                          comment => " Count up init_refresh_commands",
                          condition => "i_refs == 3'h".
                              ($Options->{init_refresh_commands} - 1),
                          then => ["i_next" => $I_LMR],
                          else => ["i_next" => $I_ARF],
                      }),
                      ],
         $I_LMR   => [
                      e_assign->news
                      (
                       ["i_state"  => $I_WAIT],
                       ["i_cmd"    => "{".$ALL.",".$LMR."}"],
                       ["i_addr"   => $MRD],
                       ["i_count"  => $tmrd],
                       ["i_next"   => $I_INIT],
                       ),
                      ],

         $I_INIT  => [i_state => $I_INIT],
         default  => [i_state => $I_RESET],
         );


    my $i_next_waitlist = [];
    
    if ($tristate_bridge_mode == 0)
    {
        $i_next_waitlist = 
            [
             e_assign->new(["i_cmd" => "{".$ALL.",".$NOP."}"]),
             e_if->new
             ({
                 comment => "WAIT til safe to Proceed...",
                 condition => "i_count > 1",
                 then => ["i_count", "i_count - 1'b1"],
                 else => ["i_state", "i_next"],
             }),
             ],
    }
    else
    {
        $i_next_waitlist =
            [
             e_if->new
             ({
                 comment => " wait for tz_waitrequest",
                 condition => "!tz_waitrequest",
                 then =>
                     [
                      e_assign->new(["i_cmd" => "{".$ALL.",".$NOP."}"]),
                      e_if->new
                      ({
                          comment => "WAIT til safe to Proceed...",
                          condition => "i_count > 1",
                          then => ["i_count", "i_count - 1'b1"],
                          else => ["i_state", "i_next"],
                      }),
                      ],
             }),
             ];
    }
    
    $i_contents_hash{$I_WAIT} = $i_next_waitlist;



    $module->add_contents
        (
         e_process->new
         ({
             comment => " **** Init FSM ****",
             asynchronous_contents => 
                 [
                  e_assign->news
                  (
                   ["i_state"  => $I_RESET],
                   ["i_next"   => $I_RESET],
                   ["i_cmd"    => $none_and_inhibit],
                   ["i_addr"   => "{".$Options->{sdram_addr_width}."{1'b1}}"],
                   ["i_count"  => "{".$initfsm_counter_width."{1'b0}}"],
                   ),
                  ], # end async_contents
             contents =>
                 [
                  e_assign->news
                  (
                   ["i_addr"    => "{".$Options->{sdram_addr_width}."{1'b1}}"],
                   ),
                  e_case->new
                  ({
                      switch => "i_state",
                      parallel => 1,
                      full => 1,
                      contents => {%i_contents_hash},
                  }),
                  ],            # end contents
         }),                    # end process
         );                     # end add_contents















    my $num_main_fsm_states;
    my ($M_IDLE, $M_RAS, $M_WAIT,$M_RD, $M_WR, $M_REC, $M_PRE, $M_REF,$M_OPEN);

    if ($tristate_bridge_mode == 1)
    {
        $num_main_fsm_states = 8;
        ($M_IDLE, $M_RAS, $M_WAIT, $M_RD, $M_WR, $M_REC, $M_PRE, $M_REF) =
            &one_hot_encoding($num_main_fsm_states);
    }
    else
    {
        $num_main_fsm_states = 9;
        ($M_IDLE,$M_RAS,$M_WAIT,$M_RD,$M_WR,$M_REC,$M_PRE,$M_REF,$M_OPEN)=
            &one_hot_encoding($num_main_fsm_states);
    }

    @signals = ("m_state", "m_next");
    foreach my $signal (@signals)
    {
        $module->add_contents
            (e_signal->new({name => "$signal",
                       width => Bits_To_Encode((2**$num_main_fsm_states)-1)}));
    }

    $module->add_contents       # uses same values as initfsm_counter_width
        (e_signal->new({name => "m_count", width => $initfsm_counter_width}));
    






    




    if ($Options->{sdram_bank_width} == 1)
    {
        $module->add_contents
            (
             e_assign->new
             (["active_bank"=> "active_addr[$bottom_bank_addr]"]),
             );
    }
    else
    {
        $module->add_contents
            (
             e_assign->new
             (["active_bank"=> 
               "{active_addr[$top_bank_addr],active_addr[$bottom_bank_addr]}"]),
             );
    }

    $module->add_contents
        (
         e_assign->news
         (
          ["csn_match"  => "active_cs_n == f_cs_n"],
          ["rnw_match"  => "active_rnw == f_rnw"],
          ["bank_match" => "active_bank == f_bank"],
          ["row_match"  =>
           "{active_addr[$top_row_addr:$bottom_row_addr]} == ".
           "{f_addr[$top_row_addr:$bottom_row_addr]}"],
          ),
         e_assign->new
         (
          ["pending" =>
           "csn_match && rnw_match && bank_match && row_match && !f_empty"],
          ),
         );


    my $cas_pad = $Options->{sdram_addr_width} - ($Options->{sdram_col_width} + 1);
    my $cas_pad_expression;
    if ($cas_pad == 1)
    {
      $cas_pad_expression = "1'b0,";
    }
    elsif ($cas_pad > 0)
    {
      $cas_pad_expression = "{$cas_pad\{1'b0}},";
    }
    else
    {
      $cas_pad_expression = "";
    }
    
    if ($Options->{sdram_col_width} > 11)
    {
        $module->add_contents
            (

             e_signal->new({name => "cas_addr",
                            width => $Options->{sdram_col_width} + 1}),
             e_assign->new
             (
              {
                  lhs => "cas_addr",
                  rhs => "f_select ? {$cas_pad_expression f_addr[$top_col_addr:10],1'b0,f_addr[9:$bottom_col_addr] } : ".
                                 "{$cas_pad_expression active_addr[$top_col_addr:10],1'b0,active_addr[9:$bottom_col_addr] }"
              }
              )
             );
    }
    elsif ($Options->{sdram_col_width} == 11)
    {
        $module->add_contents
            (

             e_signal->new({name => "cas_addr",
                            width => $Options->{sdram_col_width} + 1}),
             e_assign->new
             (
              {
                  lhs => "cas_addr",
                  rhs => "f_select ? {$cas_pad_expression f_addr[$top_col_addr],1'b0,f_addr[9:$bottom_col_addr] } : ".
                                 "{$cas_pad_expression active_addr[$top_col_addr],1'b0,active_addr[9:$bottom_col_addr] }"
              }
              )
             );
    }
    else
    {


        $cas_pad = $Options->{sdram_addr_width} - $Options->{sdram_col_width};
        $module->add_contents
            (
             e_signal->new({name => "cas_addr",
                            width => $Options->{sdram_col_width} }),
             e_assign->new
             (
              {
                  lhs => "cas_addr",
                  rhs => "f_select ? { {".($cas_pad)."{1'b0}},f_addr[$top_col_addr:$bottom_col_addr] } : ".
                                 "{ {".($cas_pad)."{1'b0}},active_addr[$top_col_addr:$bottom_col_addr] }" }
              )
             );
    }







    my %m_contents_hash = 
        (
         $M_IDLE      =>
         [ # Note that the default IDLE cmd is INHIBIT (cs_ not asserted)
           e_if->new
           ({
               comment => "Wait for init-fsm to be done...",
               condition => "init_done",
               then => [
                        e_if->new
                        ({
                            comment=>"Hold bus if another cycle ended to arf.",
                            condition => "refresh_request",
                            then =>
                                [
                                 e_assign->new
                                 (["m_cmd" => "{".$ALL.",".$NOP."}"]),
                                 ],
                            else =>
                                [
                                 e_assign->new
                                 (["m_cmd" => $none_and_inhibit]),
                                 ],
                            }),
                        e_assign->new(["ack_refresh_request" => "1'b0"]),
                        e_if->new
                        ({
                            comment => "Wait for a read/write request.",
                            condition => "refresh_request",

                            then => 
                                [ 
                                  e_assign->news
                                  (
                                   ["m_state" => $M_PRE],
                                   ["m_next"  => $M_REF],
                                   ["m_count" => $trp],
                                   ["active_cs_n" => $csn_for_refresh], # for tristate...
                                   ),
                                  ], # end then
                            elsif => {
                                condition => "!f_empty",
                                then =>
                                    [
                                     e_assign->news
                                     (
                                      ["f_pop"  => "1'b1"],
                                      ["active_cs_n"    => "f_cs_n"],
                                      ["active_rnw"     => "f_rnw"],
                                      ["active_addr"    => "f_addr"],
                                      ["active_data"    => "f_data"],
                                      ["active_dqm"     => "f_dqm"],
                                      ["m_state"        => $M_RAS]
                                      ),
                                     ], # end then
                            }, # end elsif
                        }),   # end if
                        ],    # end init_done
               else => # !init_done
                   [
                    e_assign->new(["m_addr"     => "i_addr"]),
                    e_assign->new(["m_state"    => $M_IDLE]),
                    e_assign->new(["m_next"     => $M_IDLE]),
                    e_assign->new(["m_cmd"      => "i_cmd"]),
                    ], # end !init_done
               }),
           ], # end IDLE
         $M_RAS       =>  # Activate a row
         [
          e_assign->news
          (
           ["m_state"   => $M_WAIT],
           ["m_cmd"     => "{csn_decode,".$ACTIVE."}"],
           ["m_bank"    => "active_bank"],
           ["m_addr"    => "active_addr[$top_row_addr:$bottom_row_addr]"],
           ["m_data"    => "active_data"],
           ["m_dqm"     => "active_dqm"],
           ["m_count"   => $trcd],
           ["m_next"    => "active_rnw ? ".$M_RD." : ".$M_WR],
           ),
          ], # end RAS
         $M_REC       => # Recover from RD or WR before going to PRECHARGE.
         [       # In essence, a special type of M_WAIT state


                 e_assign->new(["m_cmd" => "{csn_decode,".$NOP."}"]),
                 e_if->new
                 ({
                     comment   => "Count down til safe to Proceed...",
                     condition => "m_count > 1",
                     then       => ["m_count" => "m_count - 1'b1"],
                     else      =>
                         [
                          e_assign->new(["m_state"      => $M_PRE]),
                          e_assign->new(["m_count"      => $trp]),
                          ],
                     }),
                 ], # end WAIT
         $M_PRE       => # You must assign m_next/m_count before entering this
         [
          e_assign->news
          (
           ["m_state" => $M_WAIT],
           ["m_addr"  => "{".$Options->{sdram_addr_width}."{1'b1}}"]
           ),
          e_if->new
          ({
              comment   => " precharge all if arf, else precharge csn_decode",
              condition => "refresh_request",
              then      => ["m_cmd" => "{".$ALL.",".$PRECHARGE."}"],
              else      => ["m_cmd" => "{csn_decode,".$PRECHARGE."}"],
          }),
          ], # end PREcharge
         $M_REF       =>
         [
          e_assign->new(["ack_refresh_request"  => "1'b1"]),
          e_assign->new(["m_state"      => $M_WAIT]),
          e_assign->new(["m_cmd"        => "{".$ALL.",".$REFRESH."}"]),
          e_assign->new(["m_count"      => $trfc]),
          e_assign->new(["m_next"       => $M_IDLE]),
          ], # end REFresh
         default  =>
         [
          e_assign->new(["m_state"      => "m_state"]),
          e_assign->new(["m_cmd"        => $none_and_inhibit]),
          e_assign->new(["f_pop"        => "1'b0"]),
          e_assign->new(["oe"           => "1'b0"]),
          ],
         );
    
    my $m_open_recovery_list = [];
    my $m_refresh_recovery_list = [];
    my $m_max_recovery_time  = (&max ( ($twr - 1), ($cas_latency - 2), 0 ));
    if ($m_max_recovery_time > 0)
    {
        $m_open_recovery_list = [ 
                                  e_assign->news
                                  (
                                   ["m_state"   => $M_REC],
                                   ["m_next"    => $M_IDLE],
                                   ["m_count"   => $m_max_recovery_time],
                                   ),
                                  ];
        $m_refresh_recovery_list=[
                                  e_assign->news
                                  (
                                   ["m_state"   => $M_WAIT],
                                   ["m_next"    => $M_IDLE],
                                   ["m_count"   => $m_max_recovery_time],
                                   ),
                                  ];
    }
    else
    {
        $m_open_recovery_list = [ 
                                  e_assign->news
                                  (
                                   ["m_state"   => $M_PRE],
                                   ["m_next"    => $M_IDLE],
                                   ["m_count"   => $trp],
                                   ),
                                  ];
        $m_refresh_recovery_list=[
                                  e_assign->news
                                  (
                                   ["m_state"   => $M_IDLE],
                                   ),
                                  ];
    }

    if ($tristate_bridge_mode == 1) {
        $m_contents_hash{$M_WAIT} =
            [




             e_if->new
             ({
                 comment => " wait for tristate bridge",
                 condition => "!tz_waitrequest",
                 then => [
                          e_if->new
                          ({
                              comment   => " arf ? prechrg all : prechrg csn",
                              condition => "(m_next == $M_REF)",
                              then      => ["m_cmd"=>"{".$ALL.",".$NOP."}"],
                              else      => ["m_cmd"=>"{csn_decode,".$NOP."}"],
                          }),
                          e_if->new
                          ({
                              comment => " Count down til safe to Proceed...",
                              condition => "m_count > 1",
                              then => ["m_count" => "m_count - 1'b1"],
                              else => ["m_state" => "m_next"],
                          }),
                          ],
             }),
             ]; # end WAIT
        $m_contents_hash{$M_RD} = # Read: this is the exciting state 

            [ 



              e_assign->news
              (
               ["m_cmd"  => "{csn_decode,".$READ."}"],
               ["m_bank" => "f_select ? f_bank : active_bank"],
               ["m_dqm"  => "f_select ? f_dqm  : active_dqm"],
               ["m_addr" => "cas_addr"],
               ),
              e_if->new
              ({
                  comment => "Do we have a transaction pending?",
                  condition => "pending",
                  then =>
                      [
                       e_if->new
                       ({
                           comment => "if we need to arf, bail out, else spin",
                           condition => "refresh_request",
                           then => 
                               [
                                e_assign->news
                                (

                                 ["m_state"     => $M_WAIT],
                                 ["m_next"      => $M_IDLE],
                                 ["m_count"     => ($cas_latency - 1)],
                                 ),
                                ], # end refresh_req
                           else => # !refresh_req
                               [ # pop fifo, stay in same state!
                                 e_assign->news
                                 (
                                  ["f_pop"      => "1'b1"],
                                  ["active_cs_n"        => "f_cs_n"],
                                  ["active_rnw" => "f_rnw"],
                                  ["active_addr"        => "f_addr"],
                                  ["active_data"        => "f_data"],
                                  ["active_dqm" => "f_dqm"],
                                  ),
                                 ], # end !refresh_req
                             }), # end if refresh_req
                       ], # end pending
                  else => # !pending
                      [
                       e_if->new
                       ({
                           comment => "correctly end RD spin cycle if fifo mt",
                           condition => "~pending & f_pop",
                           then => ["m_cmd" => "{csn_decode,".$NOP."}"],
                       }),
                       e_assign->news
                       (
                        ["m_state"      => $M_REC],
                        ["m_next"       => $M_IDLE],
                        ["m_count"      => ($cas_latency - 1)],
                        ),
                       ], # end !pending
                   }), # end if pending
              ]; # end RD
        $m_contents_hash{$M_WR} = # Write: this is the exciting state where

            [ 



              e_assign->news
              (
               ["m_cmd"  => "{csn_decode,".$WRITE."}"],
               ["oe"     => "1'b1"],
               ["m_data" => "f_select ? f_data : active_data"],
               ["m_dqm"  => "f_select ? f_dqm  : active_dqm"],
               ["m_bank" => "f_select ? f_bank : active_bank"],
               ["m_addr" => "cas_addr"],
               ),
              e_if->new
              ({
                  comment => "Do we have a transaction pending?",
                  condition => "pending",
                  then =>
                      [
                       e_if->new
                       ({
                           comment => "if we need to ARF, bail out, else spin",
                           condition => "refresh_request",
                           then => 
                               [
                                e_assign->news
                                (

                                 ["m_state"     => $M_WAIT],
                                 ["m_next"      => $M_IDLE],
                                 ["m_count"     => $twr],
                                 ),
                                ], # end refresh_req
                           else => # !refresh_req
                               [ # pop fifo, stay in same state!
                                 e_assign->news
                                 (
                                  ["f_pop"      => "1'b1"],
                                  ["active_cs_n"        => "f_cs_n"],
                                  ["active_rnw" => "f_rnw"],
                                  ["active_addr"        => "f_addr"],
                                  ["active_data"        => "f_data"],
                                  ["active_dqm" => "f_dqm"],
                                  ),
                                 ], # end !refresh_req
                             }), # end if refresh_req
                       ], # end pending
                  else =>
                  [
                   e_if->new
                   ({
                       comment => "correctly end WR spin cycle if fifo empty",
                       condition => "~pending & f_pop",
                       then =>
                           [
                            e_assign->news
                            (
                             ["m_cmd"   => "{csn_decode,".$NOP."}"],
                             ["oe"      => "1'b0"],
                             ),
                            ],
                        }),
                   e_assign->news
                   (
                    ["m_state"  => $M_REC],
                    ["m_next"   => $M_IDLE],
                    ["m_count"  => $twr],
                    ),
                   ], # end !pending
               }), # end if pending
              ]; # end WR
    }
    else # optimize for direct control of sdram pins (no tri-state sharing)
    {
        $m_contents_hash{$M_WAIT} =
            [


             e_if->new
             ({
                 comment   => " precharge all if arf, else precharge csn_decode",
                 condition => "(m_next == $M_REF)",
                 then      => ["m_cmd" => "{".$ALL.",".$NOP."}"],
                 else      => ["m_cmd" => "{csn_decode,".$NOP."}"],
             }),
             e_if->new
             ({
                 comment => "Count down til safe to Proceed...",
                 condition => "m_count > 1",
                 then => ["m_count" => "m_count - 1'b1"],
                 else => ["m_state" => "m_next"],
             }),
             ]; # end WAIT
        $m_contents_hash{$M_RD} = # Read: this is the exciting state where all

            [ 



              e_assign->news
              (
               ["m_cmd"  => "{csn_decode,".$READ."}"],
               ["m_bank" => "f_select ? f_bank : active_bank"],
               ["m_dqm"  => "f_select ? f_dqm  : active_dqm"],
               ["m_addr" => "cas_addr"],
               ),
              e_if->new
              ({
                  comment => "Do we have a transaction pending?",
                  condition => "pending",
                  then =>
                      [
                       e_if->new
                       ({
                           comment => "if we need to ARF, bail, else spin",
                           condition => "refresh_request",
                           then => 
                               [
                                e_assign->news
                                (

                                 ["m_state"     => $M_WAIT],
                                 ["m_next"      => $M_IDLE],
                                 ["m_count"     => ($cas_latency - 1)],
                                 ),
                                ], # end refresh_req
                           else => # !refresh_req
                               [ # pop fifo, stay in same state!
                                 e_assign->news
                                 (
                                  ["f_pop"       => "1'b1"],
                                  ["active_cs_n" => "f_cs_n"],
                                  ["active_rnw"  => "f_rnw"],
                                  ["active_addr" => "f_addr"],
                                  ["active_data" => "f_data"],
                                  ["active_dqm"  => "f_dqm"],
                                  ),
                                 ], # end !refresh_req
                             }), # end if refresh_req
                       ], # end pending
                  else => # !pending
                      [
                       e_if->new
                       ({
                           comment => "correctly end RD spin cycle if fifo mt",
                           condition => "~pending & f_pop",
                           then => ["m_cmd" => "{csn_decode,".$NOP."}"],
                       }),

                       e_assign->new(["m_state" => $M_OPEN]),
                       ], # end !pending
                   }), # end if pending
              ]; # end RD
        $m_contents_hash{$M_WR} = # Write: this is the exciting state where

            [ 



              e_assign->news
              (
               ["m_cmd"  => "{csn_decode,".$WRITE."}"],
               ["oe"     => "1'b1"],
               ["m_data" => "f_select ? f_data : active_data"],
               ["m_dqm"  => "f_select ? f_dqm  : active_dqm"],
               ["m_bank" => "f_select ? f_bank : active_bank"],
               ["m_addr" => "cas_addr"],
               ),
              e_if->new
              ({
                  comment => "Do we have a transaction pending?",
                  condition => "pending",
                  then =>
                      [
                       e_if->new
                       ({
                           comment => "if we need to ARF, bail, else spin",
                           condition => "refresh_request",
                           then => 
                               [
                                e_assign->news
                                (

                                 ["m_state"     => $M_WAIT],
                                 ["m_next"      => $M_IDLE],
                                 ["m_count"     => $twr],
                                 ),
                                ], # end refresh_req
                           else => # !refresh_req
                               [ # pop fifo, stay in same state!
                                 e_assign->news
                                 (
                                  ["f_pop"       => "1'b1"],
                                  ["active_cs_n" => "f_cs_n"],
                                  ["active_rnw"  => "f_rnw"],
                                  ["active_addr" => "f_addr"],
                                  ["active_data" => "f_data"],
                                  ["active_dqm"  => "f_dqm"],
                                  ),
                                 ], # end !refresh_req
                             }), # end if refresh_req
                       ], # end pending
                  else =>
                  [
                   e_if->new
                   ({
                       comment => "correctly end WR spin cycle if fifo empty",
                       condition => "~pending & f_pop",
                       then =>
                           [
                            e_assign->news
                            (
                             ["m_cmd"   => "{csn_decode,".$NOP."}"],
                             ["oe"      => "1'b0"],
                             ),
                            ],
                        }),
                   e_assign->news(["m_state"    => $M_OPEN]),
                   ], # end !pending
               }), # end if pending
              ]; # end WR
        $m_contents_hash{$M_OPEN} =

            [
             e_assign->new(["m_cmd"     => "{csn_decode,".$NOP."}"]),
             e_if->new
             ({
                 comment => "if we need to ARF, bail, else spin",
                 condition => "refresh_request",
                 then => $m_refresh_recovery_list, # end refresh_req
                 else => # !refresh_req
                     [ # determine one of 3 basic outcomes:




                       e_if->new
                       ({
                           comment => "wait for fifo to have contents",
                           condition => "!f_empty",
                           then =>
                               [
                                e_if->new
                                ({
                                    comment  => "Are we 'pending' yet?",
              condition => "csn_match && rnw_match && bank_match && row_match",
                                    then => # go back where you came from:
                                        [
                                         e_assign->news
                                         (
                                          {lhs => "m_state",
                                          rhs => "f_rnw ? ".$M_RD." : ".$M_WR},
                                          ["f_pop"      => "1'b1"],
                                          {lhs => "active_cs_n",
                                           rhs => "f_cs_n"},
                                          {lhs => "active_rnw",
                                           rhs => "f_rnw"},
                                          {lhs => "active_addr",
                                           rhs => "f_addr"},
                                          {lhs => "active_data",
                                           rhs => "f_data"},
                                          {lhs => "active_dqm",
                                           rhs => "f_dqm"},
                                          ),
                                         ],
                                    else => $m_open_recovery_list, # close row
                                }),
                                ],
                        }), # end ~fifo_empty
                       ], # end !refresh_req
               }), # end if refresh_req
             ]; # end state M_OPEN
    } # end optimize for direct control of SDRAM pins

    my $i_am_verilog;
    if ($lang =~ /verilog/i)
    {
        $i_am_verilog = 1;
    }
    else
    {
        $i_am_verilog = 0;
    }


    $module->add_contents
        (
         e_signal->news
         (
          {name => "m_bank",    width => $Options->{sdram_bank_width}},
          {name => "m_addr",    width => $Options->{sdram_addr_width}},
          {name => "m_data",    width => $Options->{sdram_data_width}},
          {name => "m_dqm",     width => $dqm_width},
          ),
         e_process->new
         ({
             comment => " **** Main FSM ****",
             output_as_muxes_and_registers => (1 - $tristate_bridge_mode),
             fast_output_names => 
               ["m_cmd", "m_bank", "m_addr", "m_data", "m_dqm"],
             fast_enable_names => ["oe","m_data"],
             asynchronous_contents =>
                 [
                  e_assign->news
                  (
                   ["m_state" => $M_IDLE],
                   ["m_next"  => $M_IDLE],
                   ["m_cmd"   => $none_and_inhibit],
                   ["m_bank"  => replicate_bit($Options->{sdram_bank_width}, 0)],
                   ["m_addr"  => replicate_bit($Options->{sdram_addr_width}, 0)],
                   ["m_data"  => replicate_bit($Options->{sdram_data_width}, 0)],
                   ["m_dqm"   => replicate_bit($dqm_width, 0)],
                   ["m_count" => replicate_bit($initfsm_counter_width, 0)],
                   ["ack_refresh_request" => "1'b0"],
                   ["f_pop"   => "1'b0"],
                   ["oe"      => "1'b0"],
                   ),
                  ], # end async_contents
             contents =>
                 [

                  e_assign->news
                  (
                   ["f_pop"     => "1'b0"],
                   ["oe"        => "1'b0"],
                   ),


                  e_case->new
                  ({
                      switch   => "m_state",
                      parallel => 1,
                      full     => 1,
                      default_sim => $i_am_verilog,
                      contents => {%m_contents_hash},
                  }),           # end case
                  ],            # end process-contents
         }),                    # end process
         );                     # end add_contents
    


    my $latency = $cas_latency;









 
    $module->add_contents
        (
         e_signal->new({name => "rd_valid",
                        width => $latency}),
         e_assign->new(["rd_strobe" => "m_cmd[2:0] == $READ"]),
         );


    my $rd_strobe = "";
    if ($latency > 1)
    {
        $rd_strobe = "{ {".($latency - 1)."{1'b0}}, rd_strobe }";

        $module->add_contents
            (
             e_process->new
             ({
                 comment => "Track RD Req's based on cas_latency w/shift reg",
                 asynchronous_contents =>
                     [
                      e_assign->new({lhs => "rd_valid",
                                     rhs => "{".$latency."{1'b0}}"}),
                      ], # end async_contents
                     contents =>
                     [
                      e_assign->new({lhs => "rd_valid",
                                     rhs => "(rd_valid << 1) | ".$rd_strobe}),
                      ],
                 }),
             );
     
    }
    else
    {

        $module->add_contents
            (
             e_process->new
             ({
                 comment => "Track RD Req's based on cas_latency w/shift reg",
                 asynchronous_contents =>
                     [
                      e_assign->new({lhs => "rd_valid",
                                     rhs => "1'b0"}),
                      ], # end async_contents
                     contents =>
                     [
                      e_assign->new({lhs => "rd_valid",
                                     rhs => "rd_strobe"}),
                      ],
                 }),
             );

    }
    
    if ($Options->{register_data_in})
    {
        if ($tristate_bridge_mode == 1)
        {
            $module->add_contents(
                                  e_register->new({
                                      comment => " Register dq data.",
                                      in => "tz_data",
                                      out => "za_data",
                                      fast_in => 1,
                                      enable => 1,
                                  }),
                                  e_register->new({
                       comment => " Delay za_valid to match registered data.",
                                      in => "rd_valid[".($latency - 1)."]",
                                      out => "za_valid",
                                      enable => undef,
                                  }),
                                  );
        }
        else
        {
            $module->add_contents(
                                  e_register->new({
                                      comment => " Register dq data.",
                                      in => "zs_dq",
                                      out => "za_data",
                                      fast_in => 1,
                                      enable => 1,
                                  }),
                                  e_register->new({
                        comment => " Delay za_valid to match registered data.",
                                      in => "rd_valid[".($latency - 1)."]",
                                      out => "za_valid",
                                      enable => undef,
                                  }),
                                  );
        }
    }
    else
    {
        if ($tristate_bridge_mode == 1)
        {
        $module->add_contents
            (
             e_assign->news
             (
              ["za_valid" => "rd_valid[".($latency -1)."]"],
              ["za_data"  => "tz_data"],
              ),
             );
        }
        else
        {
        $module->add_contents
            (
             e_assign->news
             (
              ["za_valid" => "rd_valid[".($latency - 1)."]"],
              ["za_data"  => "zs_dq"],
              ),
             );
        }
    }


    my $STR_INH = &str2hex ("INH");

    if ($tristate_bridge_mode == 0)
    {
        $module->add_contents(e_assign->new(["cmd_code" => "m_cmd[2:0]"]),);
        $module->add_contents
            (
             e_signal->new({name  => "cmd_all",
                            width => ($num_chipselects + 3)}),
             e_assign->new(["cmd_all"  => "m_cmd"]),
             );
    }
    else
    {
        $module->add_contents
            (
             e_signal->new({name  => "cmd_all",
                            width => ($num_chipselects + 3)}),
             e_assign->news
             (["cmd_code" => "init_done ? m_cmd[2:0] : i_cmd[2:0]"],
              ["cmd_all"  => "init_done".
                             " ? {m_qualified_csn,m_cmd[2:0]}".
                             " : {m_qualified_csn,i_cmd[2:0]}"]),
             );
    }

    $module->add_contents
        ( # Simulation only process to set text code of cs/ras/cas/we
          e_signal->new
          ({
              name => "CODE",
              never_export => 1,
              width => 8*3,
          }), # 3 ascii characters wide
          e_signal->new
          ({
              name => "cmd_code",
              never_export => 1,
              width => 3,
          }),
          e_sim_wave_text->new
          ({
              out     => "txt_code",
              selecto => "cmd_code",
              table   =>
                  [
                   "3'h0" => "LMR",
                   "3'h1" => "ARF",
                   "3'h2" => "PRE",
                   "3'h3" => "ACT",
                   "3'h4" => " WR",
                   "3'h5" => " RD",
                   "3'h6" => "BST",
                   "3'h7" => "NOP",
                   ],
              default => "BAD",
          }),

          e_assign->new
          ({
              tag => "simulation",
              lhs => "CODE",
              rhs => 
                  "&(cmd_all|".(3+$Options->{sdram_num_chipselects})."'h7)".
                  " ? $STR_INH : txt_code",
          }),
          );
    



} # &make_sdram_controller



sub recursive_copy
{
    my $this = shift;
    if  (ref $this eq "HASH")
    {
      +{map { $_ => &recursive_copy($this->{$_}) } keys %$this};
    }
    elsif (ref $this eq "ARRAY")
    {
      [map &recursive_copy($_), @$this];
    }
    else
    {
        $this;
    }
} # &recursive_copy























































































































































sub make_sodimm
{
    my ( $module, $Options) = (@_);







    




    

      
























    

    my $sim_model_base = $Options->{sim_model_base};
    my $lang = $Options->{project_info}{language};
    my $sim_file = $Options->{get_top_module_name};
        my $sim_dat  = $Options->{_target_module_name} . ".dat";
    if ($lang =~ /vhd/i    ) { $sim_file .= ".vhd"; }
    if ($lang =~ /verilog/i) { $sim_file .= ".v"; }
    my @write_lines;
    


    if ($sim_model_base)
    {

        @write_lines = 
            (
             "",
             "************************************************************",
             "This testbench includes an SOPC Builder Generated Altera model:",
             "'$sim_file', to simulate accesses to SDRAM.",
             );



            push @write_lines,
            (
             "Initial contents are loaded from the file: ".
             "'$sim_dat'."
             );

        push @write_lines,
        ("************************************************************");

    } # sim_model_base == altera
    else
    {




        return 0;
    }
        

    map {$_ = e_sim_write->new({spec_string => $_ . '\\n'})} @write_lines;
    


    if (@write_lines)
    {
        my $init = e_initial_block->new({
            contents => [ @write_lines ],
        });
        $module->add_contents($init);
    } # if (@write_lines)
    

    

    Validate_Sdram_Options($Options);
    










    





    




    my $STR_INH = &str2hex ("INH"); # Inhibit
    my $STR_LMR = &str2hex ("LMR"); # To grab cas_latency during LoadMoadReg
    my $STR_ACT = &str2hex ("ACT"); # To grab cs/row/bank addr during Activate
    my $STR__RD = &str2hex (" RD"); # To grab col addr during Read
    my $STR__WR = &str2hex (" WR"); # To grab col addr during Write






    my  $ram_file = $sim_dat;


    $module->add_contents
        (
         e_ram->new
         ({
             comment => "Synchronous write when (CODE == $STR__WR (write))",
          name => $Options->{get_top_module_name} . "_ram",
             Read_Latency => "0",
             dat_file => $ram_file,
             port_map =>
             {
                 wren => "(CODE == $STR__WR)",
                 data => "rmw_temp",
                 q    => "read_data",
                 wrclock => "clk",
                 wraddress=>"test_addr",
                 rdaddress=>"(CODE == $STR__WR) ? test_addr : read_addr",
             }
         }),
         );



    






    

    my $dq;                     # variable for dq signal name, for 3-state mode
    $dq = "zs_dq";              # Dedicated pin-mode dq name

    $module->add_contents
        (
         e_port->news
         (
          {name => "clk"},
          {name => "zs_cke"},
          {name => "zs_cs_n",  width => $num_chipselects},
          {name => "zs_ras_n"},
          {name => "zs_cas_n"},
          {name => "zs_we_n"},
          {name => "zs_dqm",   width => $dqm_width},
          {name => "zs_ba",    width => $Options->{sdram_bank_width}},
          {name => "zs_addr",  width => $Options->{sdram_addr_width}},
          {name => $dq,        width => $Options->{sdram_data_width},
           direction => "inout"},
          ),
         e_signal->news
         (
          {name => "cke"},
          {name => "cs_n",  width => $num_chipselects},
          {name => "ras_n"},
          {name => "cas_n"},
          {name => "we_n"},
          {name => "dqm",   width => $dqm_width},
          {name => "ba",    width => $Options->{sdram_bank_width}},
          {name => "a",     width => $Options->{sdram_addr_width}},
          ),
         e_assign->news
         (
          ["cke"   => "zs_cke"],
          ["cs_n"  => "zs_cs_n"],
          ["ras_n" => "zs_ras_n"],
          ["cas_n" => "zs_cas_n"],
          ["we_n"  => "zs_we_n"],
          ["dqm"   => "zs_dqm"],
          ["ba"    => "zs_ba"],
          ["a"     => "zs_addr"],
          ),
         );
    


    $module->add_contents
        (

         e_assign->new
         ({
             lhs => e_signal->new({name => "cmd_code", width => 3}),
             rhs => "{ras_n, cas_n, we_n}",
         }),
         e_sim_wave_text->new
         ({
             out     => "txt_code",
             selecto => "cmd_code",
             table   =>
                 [
                  "3'h0" => "LMR",
                  "3'h1" => "ARF",
                  "3'h2" => "PRE",
                  "3'h3" => "ACT",
                  "3'h4" => " WR",
                  "3'h5" => " RD",
                  "3'h6" => "BST",
                  "3'h7" => "NOP",
                  ],
                 default => "BAD",
             }),

         e_signal->new({name => "CODE", width=> 8*3, never_export => 1}),
         e_assign->new(["CODE" => "(\&cs_n) ? $STR_INH : txt_code"]),
         );







    my $arb_rhs;
    my $arb_width = $Options->{sdram_bank_width} + $Options->{sdram_row_width};

    if ($Options->{sdram_bank_width} == 1)
    {

        $arb_rhs = "{a, ba}";
    }
    elsif ($Options->{sdram_bank_width} == 2)
    {

        $arb_rhs = "{ba[1], a, ba[0]}"
    }



    my $acrb_rhs;
    my $acrb_width = $arb_width;
    if ($num_chipselects < 2)
    {

        $acrb_rhs  = $arb_rhs;
    }
    else
    {


        my %cs_encode_hash = 
            ( default => ["cs_encode" => $num_chipselect_address_bits."'h0"] );
        my @raw_cs = &one_hot_encoding($num_chipselects);

        my $cs_count = 0;
        foreach my $chip_select (@raw_cs) {
            $cs_encode_hash{$chip_select} =
                [
                 e_assign->new
                 (
                  ["cs_encode" => $num_chipselect_address_bits."'h".$cs_count],
                  )
                 ];
            $cs_count++;
        } # foreach (@raw_cs)


        $module->add_contents
            (
             e_signal->news
             (
              {name => "cs",        width=> $num_chipselects},
              {name => "cs_encode", width=> $num_chipselect_address_bits},
              ),
             e_assign->new(["cs" => "~cs_n"]), # invert cs_n for encoding
             e_process->new({
                 clock   => "",
                 comment =>
                     "Encode 1-hot ChipSelects into high order address bit(s)",
                 contents=>
                     [
                      e_case->new({
                          switch => "cs",
                          parallel => 1,
                          contents => {%cs_encode_hash},
                      }),
                      ],
             }),
             );

        $acrb_rhs    = "{cs_encode, $arb_rhs}";
        $acrb_width += $num_chipselect_address_bits;
    }


    my $ac_rhs;
    if ($Options->{sdram_bank_width} < 11) {
        $ac_rhs = "a[".($Options->{sdram_col_width}-1).":0]";
    } elsif ($Options->{sdram_bank_width} == 11) {
        $ac_rhs = "{a[11],a[9:0]}";
    } else {
        $ac_rhs = "{a[".$Options->{sdram_col_width}.":11],a[9:0]}";
    }
    my $read_addr_width = $acrb_width + $Options->{sdram_col_width};
    $module->add_contents
        (
         e_signal->news
         (
          {name => "addr_crb", width=> $acrb_width},
          {name => "addr_col", width=> $Options->{sdram_col_width}},
          {name => "test_addr",width=> $read_addr_width},

          ),
         e_signal->news
         (
          {name => "rd_addr_pipe_0", width=> $read_addr_width},
          {name => "rd_addr_pipe_1", width=> $read_addr_width},
          {name => "rd_addr_pipe_2", width=> $read_addr_width},
          ),
         e_assign->news
         (
          ["addr_col" => $ac_rhs],
          ["test_addr"=> "{addr_crb, addr_col}"],
          ),
         );





    $module->add_contents
        (
         e_signal->news
         (
          {name => "rd_valid_pipe",   width=> 3},
          {name => "mask",            width=> $dqm_width},
          {name => "latency",         width=> 3},
          {name => "index",           width=> 3},
          {name => "rd_mask_pipe_0",  width=> $dqm_width},
          {name => "rd_mask_pipe_1",  width=> $dqm_width},
          {name => "rd_mask_pipe_2",  width=> $dqm_width},
          ),
         );
    

    $module->add_contents
        (
         e_signal->news
         (
          {name => "rmw_temp", width=> $Options->{sdram_data_width}},
          {name => "mem_bytes",width=> $Options->{sdram_data_width}},
          {name => "read_data",width=> $Options->{sdram_data_width}},
          {name => "read_temp",width=> $Options->{sdram_data_width}},
          ),
         e_assign->new(["mem_bytes" => "read_data"]),
         );



    my %lanes;
    my $byte_lane;

    if ($dqm_width > 1) {
        for (0 .. ($dqm_width-1))
        {
            $byte_lane = $_;
            $lanes{$byte_lane} = (($byte_lane*8)+7).":".($byte_lane*8);
            $module->add_contents
                (
                 e_assign->new
                 (
                  ["rmw_temp[$lanes{$byte_lane}]" =>
                   "dqm[$byte_lane] ? ".
                   "mem_bytes[$lanes{$byte_lane}] : ".$dq."[$lanes{$byte_lane}]"]
                  )
                 );
        } # for (0 to ($dqm_width-1))
    } else {
        $module->add_contents
            (
             e_assign->new(["rmw_temp" => "dqm ? mem_bytes : ".$dq])
             );
    }
    

    $module->add_contents
        (
         e_process->new
         ({
             comment => " Handle Input.",
             contents => 
                 [
                  e_if->new({
                      comment => " No Activity of Clock Disabled",
                      condition => "cke",
                      then => 
                          [
                           e_if->new({
                               comment   => " LMR: Get CAS_Latency.",
                               condition => "(CODE == $STR_LMR)",
                               then      => ["latency" => "a[6:4]"],
                           }),
                           e_if->new({
                               comment   => " ACT: Get Row/Bank Address.",
                               condition => "(CODE == $STR_ACT)",
                               then      => ["addr_crb" => $acrb_rhs],
                           }),
                           e_assign->news
                           (
                            ["rd_valid_pipe[2]" => "rd_valid_pipe[1]"],
                            ["rd_valid_pipe[1]" => "rd_valid_pipe[0]"],
                            ["rd_valid_pipe[0]" => "(CODE == $STR__RD)"],
                            ["rd_addr_pipe_2"  => "rd_addr_pipe_1"],
                            ["rd_addr_pipe_1"  => "rd_addr_pipe_0"],
                            ["rd_addr_pipe_0"  => "test_addr"],
                            ["rd_mask_pipe_2"  => "rd_mask_pipe_1"],
                            ["rd_mask_pipe_1"  => "rd_mask_pipe_0"],
                            ["rd_mask_pipe_0"  => "dqm"],
                           ),
                           ],
                       }),
                  ],
          }),
         );
    

    if ($dqm_width > 1) {
        for (0 .. ($dqm_width - 1)) {
            $module->add_contents
                (
                 e_assign->new
                 (
                  ["read_temp[$lanes{$_}]" => "mask[$_] ? ".
                   "8'bz : read_data[$lanes{$_}]"]
                  ),
                 );
        } # for mask-bits
    } else {
        $module->add_contents
            (
             e_assign->new
             (
              ["read_temp" => "mask ? 8'bz : read_data"]
              ),
             );
    }

    $module->add_contents
        (
         e_signal->news
         (
          {name => "read_addr", width => $read_addr_width, never_export => 1},
          {name => "read_mask", width => $dqm_width,       never_export => 1},
          {name => "read_valid",width => 1,                never_export => 1},
          ),
         e_mux->new
         ({
             comment=> "use index to select which pipeline stage drives addr",
             type   => "selecto",
             selecto=> "index",
             lhs    => "read_addr",
             table  => 
                 [
                  0 => "rd_addr_pipe_0",
                  1 => "rd_addr_pipe_1",
                  2 => "rd_addr_pipe_2",
                  ],
         }),
         e_mux->new
         ({
             comment=> "use index to select which pipeline stage drives mask",
             type   => "selecto",
             selecto=> "index",
             lhs    => "read_mask",
             table  => 
                 [
                  0 => "rd_mask_pipe_0",
                  1 => "rd_mask_pipe_1",
                  2 => "rd_mask_pipe_2",
                  ],
         }),
         e_mux->new
         ({
             comment=> "use index to select which pipeline stage drives valid",
             type   => "selecto",
             selecto=> "index",
             lhs    => "read_valid",
             table  => 
                 [
                  0 => "rd_valid_pipe[0]",
                  1 => "rd_valid_pipe[1]",
                  2 => "rd_valid_pipe[2]",
                  ],
         }),
         e_assign->news
         (
          ["index"     => "latency - 1'b1"],
          ["mask"      => "read_mask"],
          [$dq         => "read_valid ? ".
           "read_temp : {".($Options->{sdram_data_width})."{1'bz}}"]
         ),
         );
         






} # &make_sodimm



qq{
Do you know how to let the 
mountain stream cleanse your mind?
Every thought is pulled out along the smooth,
polished stones, disappearing
downstream in the frothy current.
The mind keeps on making more thoughts
until it sees that they are 
all being carried away downstream; 
until it realizes that they 
are all vanishing,
dissolving into an unseen point.
Then it won’t bother for awhile. 
 - Ji Aoi Isshi
};
