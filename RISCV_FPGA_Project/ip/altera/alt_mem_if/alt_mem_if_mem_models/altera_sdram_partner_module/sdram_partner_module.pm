# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# Partner module for SDRAM controller in Qsys environment
# This Europa create memory model for simulation purpose
# of SDRAM controller during the testbench creation in Qsys
# A wrap around _hw.tcl will establish this component in IP
# library list. Memory initialization file will also be included
# into this generation.

use Getopt::Long;
use europa_all;
use strict;



# Main sodimm Builder.
sub make_sdram_sim_module
{
    # No arguments means "Ignore -- I'm being called from make".
    if (!@_)
    {
        # print "\n\tmake_sdram_controller now uses a static".
        # " external 'class.ptf'!\n\n";
        return 0; # make_class_ptf();
    }
    
	Progress("Starting SDRAM Simulation Partner Module generation");

    my $verilog;
    my $vhdl;
    my $module_name;
    my $sim_dir;
    my $config_file;
    my $bogus;
	my $quartus_dir;
	my $output_dir;
	my $language;
	my $sdram_data_width;
	my $sdram_bank_width;
	my $sdram_col_width;
	my $sdram_row_width;
	my $sdram_num_chipselects;
	my $cas_latency;
	my $module_name;

    if (!GetOptions( 
      #'verilog'         => \$verilog,
      #'vhdl'            => \$vhdl,
	  'language=s'       => \$language,
      'module_name=s'   => \$module_name,
	  'output_dir=s'    => \$output_dir,
      'quartus_dir=s'     => \$quartus_dir,
	  'sdram_data_width=s'=> \$sdram_data_width,
	  'sdram_bank_width=s'=> \$sdram_bank_width,
	  'sdram_col_width=s' => \$sdram_col_width,
	  'sdram_row_width=s' => \$sdram_row_width,
	  'sdram_num_chipselects=s' => \$sdram_num_chipselects,
#	  'module_name' => \$module_name,
	  'cas_latency=s'     => \$cas_latency,
     )) {
       	print STDERR "wrong arguments passed in !!!\n";
        exit(1);
    }

	my $top_module = e_module->new({
      name => $module_name,
      do_ptf => 0, # This avoids a warning about old-style ptf format.
	});

	my $project = e_project->new({
      top => $top_module,
	  language => $language,
      #_system_directory => $system_directory,
	  _system_directory => $output_dir,
	});


    
    # Grab the module that was created during handle_args.
    my $module = $project->top();

    
    # Let the sim model tell what it's doing...

	my $sim_file = $project->get_top_module_name();
    my $sim_dat  = $project->_target_module_name() . ".dat";
    if ($language =~ /vhd/i    ) { $sim_file .= ".vhd"; }
    if ($language =~ /verilog/i) { $sim_file .= ".v"; }
    my @write_lines;
    
 
        # Start building up a simulation-only display string.
        @write_lines = 
            (
             "",
             "************************************************************",
             "This testbench includes an SOPC Builder Generated Altera model:",
             "'$sim_file', to simulate accesses to SDRAM.",
             );
       # SRA modified so always read in memory file
       # TW prefers old code left in and commented out.
       # if ($WSA->{is_initialized}) {
            push @write_lines,
            (
             "Initial contents are loaded from the file: ".
             "'$sim_dat'."
             );
  
        push @write_lines,
        ("************************************************************");

        
    # Convert all lines to e_sim_write objects.
    map {$_ = e_sim_write->new({spec_string => $_ . '\\n'})} @write_lines;
    
    # Wrap the simulation-only display string in an e_initial_block, so we
    # only see the message once!
    if (@write_lines)
    {
        my $init = e_initial_block->new({
            contents => [ @write_lines ],
        });
        $module->add_contents($init);
    } # if (@write_lines)
    

   

# New style contents generation (a'la OnchipMemoryII -- thanks AaronF)
  #      my $Opt = {name => $project->_target_module_name()};
  #      $project->do_makefile_target_ptf_assignments
  #          (
  #           's1',
  #           ['dat', 'sym', ],
  #           $Opt,
  #           );

 
    # Having a non-integer power of 2 for number of chip selects seems wrong.
    my $num_chipselects = $sdram_num_chipselects;
    my $num_chipselect_address_bits = log2($num_chipselects);


    # Compute the width of the controller's address (as seen by the Avalon
    # bus) from input parameters.  SODIMM will address a raw memory array in
    # the same way that Avalon accesses the Controller.
    my $controller_addr_width =
        $num_chipselect_address_bits +
        $sdram_bank_width +
        $sdram_col_width +
        $sdram_row_width;
    
     
    my $dqm_width = $sdram_data_width / 8;
    if (int($dqm_width) != $dqm_width)
    {
        ribbit
            (
             "Unexpected: SDRAM data width '", $sdram_data_width, "', ".
             "leads to non-integer DQM width ($dqm_width)"
             );
    }
    
    # Let's set up the str2hex CODE variable to be "INH" or 'some active
    # code', depening upon {cs_n[x], ras_n, cas_n, we_n}

    # set up some precoded 3 character wide strings for wave display below:
    my $STR_INH = &str2hex ("INH"); # Inhibit
    my $STR_LMR = &str2hex ("LMR"); # To grab cas_latency during LoadMoadReg
    my $STR_ACT = &str2hex ("ACT"); # To grab cs/row/bank addr during Activate
    my $STR__RD = &str2hex (" RD"); # To grab col addr during Read
    my $STR__WR = &str2hex (" WR"); # To grab col addr during Write
    # Precharge, AutoRefresh and Burst are ignored by this model!
    # NB: we may choose to later add a AutoRefresh timing check...

    my  $ram_file = $sim_dat;

    my @things;
    push @things, readMemLogic(0,$ram_file);
    $module->add_contents(@things);
    
    #$module->add_contents
    #    (
    #     e_ram->new
    #     ({
    #         comment => "Synchronous write when (CODE == $STR__WR (write))",
    #         name => $project->get_top_module_name() . "_ram",
    #         Read_Latency => "0",
    #         dat_file => $ram_file,
    #         port_map =>
    #         {
    #             wren => "(CODE == $STR__WR)",
    #             data => "rmw_temp",
    #             q    => "read_data",
    #             wrclock => "clk",
    #             wraddress=>"test_addr",
    #             rdaddress=>"(CODE == $STR__WR) ? test_addr : read_addr",
    #         }
    #     }),
    #     );

    # Tho the Altera SDR SDRAM Controller's always wire their clk_en 'ON',
    # some users may wire their testbench to flick the bit...
    
    # Port Naming matches common SODIMM conventions, with some exceptions:
    # Since the controller only drives one clock, and one clock_enable, we
    # never create a bus of inputs for those signals (many sodimms have 2 or
    # more ck and cke's); we do not support any sort of Serial Presence
    # Detect, nor the associated SCL (serial-clock) and SDA (serial-data)
    # signals.
    
    # NOTE: WSA->{sdram_addr_width} is not necessarily WSA->{sdram_row_width}!
    my $dq;                     # variable for dq signal name, for 3-state mode
    $dq = "zs_dq";              # Dedicated pin-mode dq name
    # Dedicated pin-mode sodimm port names and assignments
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
          {name => "zs_ba",    width => $sdram_bank_width},
          {name => "zs_addr",  width => $sdram_row_width},
          {name => $dq,        width => $sdram_data_width,
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
          {name => "ba",    width => $sdram_bank_width},
#          {name => "a",     width => $sdram_addr_width},
		  {name => "a",     width => $sdram_row_width},
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
    
    # Now the fun begins ;-)

    $module->add_contents
        (
         # Define txt_code based on ras/cas/we
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
         # "Inhibit" if no chip_selects,
         e_signal->new({name => "CODE", width=> 8*3, never_export => 1}),
         e_assign->new(["CODE" => "(\&cs_n) ? $STR_INH : txt_code"]),
         );

    ## Row/Col Address Construction:
    # We're constructing a monolithic address into a single large array.
    # If there are multiple chip-selects, we assume they are one-hot
    # encoded (that's what our controller drives).

    # First, we'll build up row/bank. (arb == address_row_bank)
    my $arb_rhs;
    my $arb_width = $sdram_bank_width + $sdram_row_width;

    if ($sdram_bank_width == 1)
    {
        # We only have 2 banks, row/addr build as {row,bank}
        $arb_rhs = "{a, ba}";
    }
    elsif ($sdram_bank_width == 2)
    {
        # 4 banks construct address as {bank[1],row,bank[0]}
        $arb_rhs = "{ba[1], a, ba[0]}"
    }

    # then we'll tack cs_encoded bits as the top bits, if applicable
    # (acrb == addr_chip-select_row_bank)
    my $acrb_rhs;
    my $acrb_width = $arb_width;
    if ($num_chipselects < 2)
    {
        # Single chipselect does not affect address:
        $acrb_rhs  = $arb_rhs;
    }
    else
    {
        # Multiple chipselects are encoded to create high order addr bits.
        # Note that &one_hot_encoding outputs a properly ordered @list!
        my %cs_encode_hash = 
            ( default => ["cs_encode" => $num_chipselect_address_bits."'h0"] );
        my @raw_cs = &one_hot_encoding($num_chipselects);
        # print "\&make_sodimm: num_cs = $num_chipselects \t \@raw_cs = @raw_cs\n";
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

        # Create the cs_encode signal, and use a case statement to define it.
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
        # prepend the encoded bits as upper order addr bits, and remember width
        $acrb_rhs    = "{cs_encode, $arb_rhs}";
        $acrb_width += $num_chipselect_address_bits;
    }
    # define/assign final construction signals
    # (ac_rhs == addr_col), constructed to avoid A[10] for large col_width
    my $ac_rhs;
    if ($sdram_bank_width < 11) {
        $ac_rhs = "a[".($sdram_col_width-1).":0]";
    } elsif ($sdram_bank_width == 11) {
        $ac_rhs = "{a[11],a[9:0]}";
    } else {
        $ac_rhs = "{a[".$sdram_col_width.":11],a[9:0]}";
    }
    my $read_addr_width = $acrb_width + $sdram_col_width;
    $module->add_contents
        (
         e_signal->news
         (
          {name => "addr_crb", width=> $acrb_width},
          {name => "addr_col", width=> $sdram_col_width},
          {name => "test_addr",width=> $read_addr_width},
          # {name => "temp_addr",width=> $read_addr_width},
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

    ## Define some random necessary variables:
    # we only support up to a max cas_latency of 3, and just soak up that many
    #resources, and pluck off an earlier version if the cas_latency is set
    #lower during LMR...
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
    
    ## Set up ram read/wr var's and initial block to readmem our dat file:
    $module->add_contents
        (
         e_signal->news
         (
          {name => "rmw_temp", width=> $sdram_data_width},
          {name => "mem_bytes",width=> $sdram_data_width},
          {name => "read_data",width=> $sdram_data_width},
          {name => "read_temp",width=> $sdram_data_width},
          ),
         e_assign->new(["mem_bytes" => "read_data"]),
         );

    # Try to make life easier by defining the necessary number of byte lane
    #field descriptors like 7:0, 15:8, etc...
    my %lanes;
    my $byte_lane;
    # assign rmw_temp[7:0]= dqm[0] ? mem_bytes[7:0] : $dq[7:0]
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
    
    # Build the Main Process:
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
    
    # Assign Outputs:
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
    
    my $mem_array_depth = 1<<$read_addr_width;

    $module->add_contents
        (
         e_signal->news
         (
          {name => "mem_array", width =>$sdram_data_width , depth =>$mem_array_depth , never_export => 1},
          {name => "rdaddress", width => $read_addr_width, never_export => 1},
          {name => "read_address", width => $read_addr_width, never_export => 1},
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
           "read_temp : {".($sdram_data_width)."{1'bz}}"]
         ),
         );
         
    # Produce some output.
    # print "\&make_sodimm: sim_model_base = $sim_model_base\n";
    # print "\&make_sodimm: about to generate output...\n";
    # $project->_verbose(1);
    $project->output();
    # print "\&make_sodimm: done.\n";

} # &make_sdram_sim_module

sub readMemLogic
{
  my $delays = shift;
  my $ram_file = shift;
  my $STR__WR = &str2hex (" WR"); # To grab col addr during Write
  my @things = ();
  

  push @things,
    e_register->new({
      delay => $delays,
      in => "rdaddress",
      out => "read_address"
    });
  
  my $readmem =  e_readmem->new({
                          file         => 'INIT_FILE',
                          file_as_var  => 1,
                          mem_variable => "mem_array",
                          hex_output   => 1,
                       });
  
  push @things,
        e_initial_block->new({
          contents => [$readmem],
        });
  
  my @contents;
  push (@contents,
        e_if->new({
           comment => " Write data",
           condition => "wren",
           then => [
                    e_assign->new({
                       lhs => "mem_array[test_addr]",
                       rhs => "rmw_temp",
                    }),
                    ],
        })
        );

  push @things, 
    e_process->new({
      clock => "clk",
      contents => \@contents,
    });
    
  push @things,
      e_assign->news (
          ["read_data"   => "mem_array[read_address]"],
          ["rdaddress"   => "(CODE == $STR__WR) ? test_addr : read_addr"],
          ["wren"   => "(CODE == $STR__WR)"],
      );
      
      
  push @things,
    e_parameter->adds(
      {
        name => "INIT_FILE",
        default => "$ram_file",
        vhdl_type => "STRING",
      },
    );

  return @things;
}


return 1;

