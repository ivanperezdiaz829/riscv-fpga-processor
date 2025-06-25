#Copyright (C)2007 Altera Corporation

# This module is called by europa_stub.pm, finds the DDR, DDR2 or DDR3 settings and generates a memory model to match.
# This script supports DDR, DDR2 and DDR3 SDRAM.


use europa_all;
use europa_utils;
use e_small_ram;
##use strict;

sub generate_mem_model
{
    $use_efficient_model = 1;
    my $temp_name = $gWRAPPER_NAME;
    &rename_and_generate();
    $use_efficient_model = 0;
    $gWRAPPER_NAME .= "_full";
    &rename_and_generate();
    $gWRAPPER_NAME = $temp_name;
}

sub rename_and_generate
{
    my $top = e_module->new({name => $gWRAPPER_NAME."_mem_model"});
    $project = e_project->new({top => $top, language => $language,__system_directory =>$output_directory});
    $module = $project->top();
    
    ## HDL language 
    ## ---------------------------------------
    # Figure out what language we're generating for
    $lang = $language;
    my $extension;
    my $ipfs_model_ext;
    my $sim_file = $gWRAPPER_NAME;
    if ($lang =~ /vhd/i    ) { 
        $sim_file .= "_mem_model.vhd";
        $extension = ".vhd";
        $ipfs_model_ext = ".vho";
    }
    if ($lang =~ /verilog/i) { 
        $sim_file .= "_mem_model.v";
        $extension = ".v";
        $ipfs_model_ext = ".vo";
    }
    
    # What does SOPCB think we're targeting?
    my $sopc_device_family = $gFAMILY;
    # What does DDR thing we're targeting?
    my $device_family = $gFAMILY;
    
    # if ($sopc_device_family ne $device_family) { print "WARNING! The device selected in SOPC Builder (".$sopc_device_family.") does match the DDR SDRAM device (".$device_family.")\n";}
    
    my $wrapper_name = $gWRAPPER_NAME;
    
    my $datapath_files = "";
    
    if ($sopc_device_family eq "stratixiigxlite") {
        $sopc_device_family = "arriagx";   
    }
     
    my $ecc_enabled = $ENABLE_ECC;
    if($ecc_enabled eq "true")
    {
        $ecc_enabled = "_ecc";
    }
    elsif ($ecc_enabled eq "false")
    {
        $ecc_enabled = "";
    }
    
    ## Memory type
    ## ---------------------------------------
    # Work out whether this should be DDR, DDR2 or DDR3
    # my $memtype =  $wizard_shortcut->{PRIVATE}{gMEM_TYPE}{value};
    $memtype = $gMEM_TYPE;
    # print "# This is a ".$memtype." controller\n";
    
    #string change because generate_ddr_sim_model.pl call gen_ddr_model module too
    if($memtype eq "ddr_sdram"){
    	$memtype = "DDR SDRAM";
    }
    if($memtype eq "ddr2_sdram"){
    	$memtype = "DDR2 SDRAM";
    }
    if($memtype eq "ddr3_sdram"){
    	$memtype = "DDR3 SDRAM";
    }
    
    # data_width_ratio = 4 for halfrate, 2 for full rate
    my $data_width_ratio = $DWIDTH_RATIO;
    $local_burst_length =  $gLOCAL_BURST_LEN;
    # print "# This is burst length $local_burst_length and data_width_ratio $data_width_ratio\n";
    
    if ($data_width_ratio == 4) 
    {
        $local_burst_length = $local_burst_length * 2;
    };
    
    my @write_lines;
    # Start building up a simulation-only display string.
    @write_lines = 
        (
         "",
         "**********************************************************************",
         "This testbench includes a generated Altera memory model:",
         "'$sim_file', to simulate accesses to the $memtype memory.",
         " ",
         );
        push @write_lines,
        (
         );
    push @write_lines,
    ("**********************************************************************");
    
    
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
    
    
    ## Clock frequency
    ## ---------------------------------------
    # Find out what the clock source of the module is        
    $clockperiod = floor($gCLOCK_PERIOD_IN_PS/2); # convert to ns
    # print "# SOPCB clock period of $clock_source is $clockperiod ns\n";
    
    ## Cas latency
    ## ---------------------------------------
    my $cas_latency = $gCASLATENCY;
    # print "# CAS latency = $cas_latency\n";
    # CAS 2.5 doesn't have any extra handling so we need to act like CAS2 but add a 1/2 cycle output delay
    $number_of_lump_delays = 0;
    if ($cas_latency eq "2.5") 
    {
        # split total delay in 90 deg segements because we can't set modelsim to use transport delays instead of inertial!
        $number_of_lump_delays = 2; # 2 lots of $clockperiod / 4 = 180 deg delay
    }
    # print "sim delay  = cas_latency = $cas_latency, $number_of_lump_delays delays.\n";
    
    
    ## Default pin prefix 
    ## ---------------------------------------
    $prefix = $gDDR_PREFIX_NAME;
    
    ## Data and address widths
    ## ---------------------------------------
    
    # Work on the number of chip selects
    $num_chipselects = $gMEM_CHIPSELS / $gMEM_CS_PER_RANK;
    $num_chipselect_address_bits = log2($num_chipselects);
    
    # Compute the width of the controller's address (as seen by the Avalon
    # bus) from input parameters.  
    $addr_width =  $gMEM_ADDR_BITS;
    $ba_width   =  $gMEM_BANK_BITS;
    $row_width  =  $gMEM_ROW_BITS;
    $col_width  =  $gMEM_COL_BITS;
    # print "# Controller has address widths, a = $addr_width, ba = $ba_width, row = $row_width, col = $col_width\n"; 
    
    $dq_width  = $MEM_IF_DWIDTH;
    $dqs_width = $dq_width / $gMEM_DQ_PER_DQS;
    $dm_width  = $dq_width / $gMEM_DQ_PER_DQS;
    
    $mem_width = $dq_width * 2; #is the actual memory in the model
    $mem_mask_width = $dm_width * 2;
    
	&gen_ddr_model();
    
}

# Main DDR simulation model.
sub gen_ddr_model
{
	## ASCII codes for the commands
    ## ---------------------------------------
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
    
    # SRA modified so always read in file
    my  $ram_file = $sim_dat;
    
    if ($use_efficient_model == 1)
    {
        $module->add_contents
        (
            e_small_ram->new
            ({
                comment => "Synchronous write when (CODE == $STR__WR (write))",
                name => $project->get_top_module_name() . "_ram",
                addr_width  => $ba_width + $row_width + $col_width + $num_chipselect_address_bits - 1,
                data_width  => $mem_width,
                port_map =>
                {
                    wren => "write_to_ram_r",
                    data => "rmw_temp",
                    q    => "read_data",
                    wrclock => "clk",
                    wraddress=>"wr_addr_delayed_r", # ddr or ddr2
                    rdaddress=>"rmw_address",
                }
            }),
        );
    }
    else
    {
        $module->add_contents
        (
            e_ram->new
            ({
                comment => "Synchronous write when (CODE == $STR__WR (write))",
                name => $project->get_top_module_name() . "_ram",
                Read_Latency => "0",
                dat_file => $ram_file,
                port_map =>
                {
                    wren => "write_to_ram_r",
                    data => "rmw_temp",
                    q    => "read_data",
                    wrclock => "clk",
                    wraddress=>"wr_addr_delayed_r", # ddr or ddr2
                    rdaddress=>"rmw_address",
                }
            }),
        );
    }
    
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
    my $dqs;                     # variable for dqs signal name, for 3-state mode
    my $dqs_n;                    # variable for dqs_n signal name, mandatory for DDR3, optional on DDR2
    $dq = $prefix."dq";            # Dedicated pin-mode dq name
    $dqs = $prefix."dqs";           # Dedicated pin-mode dqs name
    $dqs_n = $prefix."dqs_n";        # Dedicated pin-mode dqs_n name
	
	my $chip_width = log2($num_chipselects);
    
    # Dedicated pin-mode sodimm port names and assignments
    $module->add_contents
    (
        e_port->news
        (
            {name => $prefix."clk"},
            {name => $prefix."cke",   width => $num_chipselects},
            {name => $prefix."cs_n",  width => $num_chipselects},
            {name => $prefix."ras_n"},
            {name => $prefix."cas_n"},
            {name => $prefix."we_n"},
            {name => $prefix."dm",    width => $dm_width },#declare_one_bit_as_std_logic_vector => 1},
            {name => $prefix."ba",    width => $ba_width },
            {name => $prefix."addr",  width => $addr_width },
            {name => $prefix."dq",    width => $dq_width, direction => "inout" },
            {name => $prefix."dqs",   width => $dqs_width, direction => "inout" },#declare_one_bit_as_std_logic_vector => 1},
            {name => $prefix."clk_n",     width=> 1,direction => "input"},
        ),
        e_signal->news
        (
            {name => "cke",  width => $num_chipselects},
            {name => "cs_n",  width => $num_chipselects},
            {name => "ras_n"},
            {name => "cas_n"},
            {name => "we_n"},
            {name => "global_reset_n"},
            {name => "dm",   width => $dm_width,export => 0, never_export => 1},
            {name => "ba",    width => $ba_width},
            {name => "a",     width => $addr_width},
            {name => "read_dq",      width => $dq_width},
            {name => "dqs",           width => $dqs_width},
            {name => "first_half_dq", width => $dq_width,export => 0, never_export => 1},
            {name => "second_half_dq",width => $dq_width,export => 0, never_export => 1},
            {name => "dq_captured",   width=> $dq_width*2,export => 0, never_export => 1},
            {name => "dq_valid",     width=> 1,export => 0, never_export => 1},
            {name => "dqs_valid",     width=> 1,export => 0, never_export => 1},
            {name => "dqs_valid_temp",  width=> 1,export => 0, never_export => 1},
            {name => "dm_captured",   width=> $dqs_width*2,export => 0, never_export => 1},
            {name => "open_rows",     width => $row_width, depth => (2 ** ($ba_width + $chip_width))},
            {name => "current_row",   width => ($ba_width + $chip_width),export => 0, never_export => 1},
            
            {name => "dqs_temp",     width => $dqs_width},
            {name => "dq_temp",      width => $dq_width},
            {name => "dqs_out_0",     width => $dqs_width},
            {name => "dq_out_0",      width => $dq_width},
        ),
        e_assign->news
        (
            ["clk"   => $prefix."clk"],
            ["dm"    => $prefix."dm"],
        ),
    );
    
    if ($gREG_DIMM eq "true")  {
        $module->add_contents
        (
            e_process->new
            ({
                contents =>
                [
                    e_assign->news
                    (
                        ["cke"   => $prefix."cke"],
                        ["cs_n"  => $prefix."cs_n"],
                        ["ras_n" => $prefix."ras_n"],
                        ["cas_n" => $prefix."cas_n"],
                        ["we_n"  => $prefix."we_n"],
                        ["ba"    => $prefix."ba"],
                        ["a"     => $prefix."addr"],
                    ),
                ],
            })
        )
    }
    else
    {
        $module->add_contents
        (
            e_assign->news
            (
                ["cke"   => $prefix."cke"],
                ["cs_n"  => $prefix."cs_n"],
                ["ras_n" => $prefix."ras_n"],
                ["cas_n" => $prefix."cas_n"],
                ["we_n"  => $prefix."we_n"],
                ["ba"    => $prefix."ba"],
                ["a"     => $prefix."addr"],
            ),
        );
    }
    
	if ($memtype ne "DDR SDRAM")  { # no odt port for ddr sdram mem model 
        $module->add_contents
        (
            e_port->new({name => $prefix."odt",     width=> 1,direction => "input"}),
            e_port->new({name => $prefix."dqs_n",   width => $dqs_width, direction => "inout" }),
        );
	} 
        
	if ($memtype eq "DDR3 SDRAM")  { # reset and dqs_n in ddr3 model
        $module->add_contents
        (
            e_port->new({name => $prefix."rst_n",     width=> 1,direction => "input"}),
            e_signal->new({name => "dqs_n_temp",     width => $dqs_width}),
            e_signal->new({name => "write_burst_length",     width => 1}),
        );
	}
    
	if (($memtype eq "DDR2 SDRAM") && ($mem_if_dqsn_en eq "true"))  { # optional dqs_n in ddr2 model
        $module->add_contents
        (
            e_signal->new({name => "dqs_n_temp",     width => $dqs_width}),
        );
	}
	
	if ($lang =~ /vhd/i    ) { #this pull down is needed for cyclone vhdl simulation
	    for ($count = 0; $count < $dq_width; $count++) {
	        $module->add_contents
            (
                e_pull->new({signal => "dq_temp($count)",	pull_type => 'pulldown',}),
            );
	    }
	}
	
    # Now the fun begins ;-)
    
    $module->add_contents
    (
         e_assign->new ({lhs => "global_reset_n", rhs => "reset_n", comment => "generate a fake reset inside the memory model",}),
         e_reset_gen->new ({reset_active => "0", ns_period => "100", }),
     
     );
    
    $module->add_contents
    (
        # Define txt_code based on ras/cas/we
        
        #assign cmd_code = (cs_n) ? 3'b111 : {ras_n, cas_n, we_n};
        e_signal->new({name => "cmd_code", width => 3}),
        e_assign->new(["cmd_code" => "(\&cs_n) ? 3'b111 : {ras_n, cas_n, we_n}"]),
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
    my $arb_width = $ba_width + $row_width;
    
    $arb_rhs = "{ba, a}";
    my $cs_encode = "cs_encode,";
    my $acrb_rhs;
    my $acrb_width = $arb_width;
    if ($num_chipselects < 2)
    {
        # Single chipselect does not affect address:
        $acrb_rhs  = $arb_rhs;
        $cs_encode = "";
    }
    else
    {
        # Multiple chipselects are encoded to create high order addr bits.
        # Note that &one_hot_encoding outputs a properly ordered @list!
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
                comment => "Encode 1-hot ChipSelects into high order address bit(s)",
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
    my $pch_bit = 10;
    my $onthefly_bit;
    if ($memtype eq "DDR3 SDRAM") {
        $onthefly_bit = 12;
    } else {
        $onthefly_bit = 0; #no onthefly bit for DDR and DDR2 so pick an address that always exists
    }
    
    # define/assign final construction signals
    # (ac_rhs == addr_col), constructed to avoid A[10] for large col_width
    my $ac_rhs;
    if ($memtype eq "DDR3 SDRAM")
    {
        if ($col_width-1 < $pch_bit)
        {
            $ac_rhs = "a[".($col_width-1).":1]";
        }
        else
        {
            if ($col_width < $onthefly_bit)
            {
                $ac_rhs = "{a[".($col_width).":".($pch_bit+1)."],a[".($pch_bit-1).":1]}";
            }
            else
            {
                $ac_rhs = "{a[".($col_width+1).":".($onthefly_bit+1)."],a[".($onthefly_bit-1).":".($pch_bit+1)."],a[".($pch_bit-1).":1]}";
            }
        }
    }
    else
    {
        if ($col_width-1 < $pch_bit)
        {
            $ac_rhs = "a[".($col_width-1).":1]";
        }
        else
        {
            $ac_rhs = "{a[".($col_width).":".($pch_bit+1)."],a[".($pch_bit-1).":1]}";
        }
    }
    
    my $read_addr_width = $acrb_width + $col_width -1; #used to be without minus 1
    $module->add_contents
    (
        e_signal->news
        (
            {name => "addr_col", width=> $col_width - 1},
            {name => "test_addr",width=> $read_addr_width},
        ),
        e_signal->news
        (
            {name => "rd_addr_pipe_0", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_1", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_2", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_3", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_4", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_5", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_6", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_7", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_8", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_9", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_10", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_11", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_12", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_13", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_14", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_15", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_16", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_17", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_18", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_19", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_20", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_addr_pipe_21", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "read_addr_delayed", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rmw_address", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "rd_burst_counter", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            
            {name => "wr_addr_pipe_0", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_1", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_2", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_3", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_4", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_5", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_6", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_7", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_8", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_9", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_10", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_11", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_12", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_13", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_14", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_15", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_16", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_17", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_pipe_18", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_delayed", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_addr_delayed_r", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            {name => "wr_burst_counter", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
            
            {name => "write_cmd", width=> 1, default_value => "0",export => 0, never_export => 1},
            {name => "write_cmd_echo", width=> 1, default_value => "0",export => 0, never_export => 1},
            {name => "read_cmd_echo", width=> 1, default_value => "0",export => 0, never_export => 1},
        ),
        e_assign->news
        (
            ["addr_col" => $ac_rhs],
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
            {name => "rd_valid_pipe",   width=> 26},
            {name => "wr_valid_pipe",   width=> 26},
            {name => "write_burst_length_pipe",   width=> 26}, # for ddr3
            {name => "additive_latency",          width=> 4},
            {name => "tcl",             width=> 4},
            {name => "read_latency",    width=> 5},
            {name => "wtcl",            width=> 4},
            {name => "write_latency",   width=> 5},
        ),
    );
    
    ## Set up ram read/wr var's and initial block to readmem our dat file:
    $module->add_contents
    (
        e_signal->news
        (
            {name => "rmw_temp", width=> $mem_width},
            {name => "mem_bytes",width=> $mem_width},
            {name => "read_data",width=> $mem_width},
            {name => "read_temp",width=> $mem_width,export => 0, never_export => 1},
            {name => "read_valid",width=> 1,export => 0, never_export => 1},
            {name => "read_cmd",width=> 1,export => 0, never_export => 1},
            {name => "write_valid_r" , width => 1, export => 0, never_export => 1},
            {name => "read_valid_r"  , width => 1, export => 0, never_export => 1},
            {name => "write_valid_r2", width => 1, export => 0, never_export => 1},
            {name => "write_valid_r3", width => 1, export => 0, never_export => 1},
            {name => "write_to_ram_r", width => 1, export => 0, never_export => 1},
            {name => "read_valid_r2" , width => 1, export => 0, never_export => 1},
            {name => "read_valid_r3" , width => 1, export => 0, never_export => 1},
            {name => "read_valid_r4" , width => 1, export => 0, never_export => 1},             
            
            {name => "burstmode",width=> 1,export => 0, never_export => 1},
            {name => "burstlength",width=> 3,export => 0, never_export => 1},
        ),
        e_assign->new(["current_row" => "{${cs_encode}ba}"]),
    );
    
    #sjh - No need for *read* masking with DDR
    # # Try to make life easier by defining the necessary number of byte lane
    # #field descriptors like 7:0, 15:8, etc...
    my %lanes;
    my $byte_lane;
    
	if ($memtype ne "DDR3 SDRAM" && $DDRx eq "false" && $NGv110 eq "false")
    {
        # Build the Main Process for DDR2:
        $module->add_contents
        (
            e_process->new
            ({
                clock			=>	"clk",
                reset			=>	"reset_n",
                comment => " Decode commands into their actions",
                _asynchronous_contents	=>
                [
                    e_assign->new(["write_cmd_echo" => "0"]),
                    e_assign->new(["read_cmd_echo" => "0"]),
                ],
                contents => 
                [
                    e_if->new({
                        comment => " No Activity if the clock is",
                        condition => "cke",
                        then => 
                        [
                            e_if->new({
                                comment   => " This is a read command",
                                condition => "(cmd_code == 3'b101)",
                                then      => [e_assign->news 
                                              (["read_cmd" => "1'b1"],
                                              ),
                                             ],
                                else      => ["read_cmd"  => "1'b0"],
                            }),
                            
                            e_if->new({
                                comment   => " This is a write command",
                                condition => "(cmd_code == 3'b100)",
                                then      => [e_assign-> news
                                              (["write_cmd" => "1'b1"],
                                               ),
                                             ],
                                else      => ["write_cmd" => "1'b0"],
                            }),
                            
                            e_if->new({
                                comment   => " This is to terminate a burst",
                                condition => "(cmd_code == 3'b110)",
                                then      => [e_assign->news 
                                              (
                                              ["burst_term_cmd" => "1'b1"],
                                              ),
                                             ],
                                else      => ["burst_term_cmd"  => "1'b0"],
                            }),
                            
                            e_if->new({
                                comment   => " This is an activate - store the chip/row/bank address in the same order as the DDR controller",
                                condition => "(cmd_code == 3'b011)",
                                then      => ["open_rows[current_row]" => "a"],
                            }),
                        ],
                    }),
                ],
             }),
             e_signal->new({name => "burst_term_cmd", width=> 1, default_value => "0",export => 0, never_export => 1}),
        );
	}
    else 
    {
        # Build the Main Process for DDR3:
        $module->add_contents
        (
            e_process->new
            ({
                clock			=>	"clk",
                reset			=>	"reset_n",
                comment => " Decode commands into their actions",
                _asynchronous_contents	=>
                [
                    e_assign->new(["write_cmd_echo" => "0"]),
                    e_assign->new(["read_cmd_echo" => "0"]),
                ],
                contents => 
                [
                    e_if->new({
                        comment => " No Activity if the clock is",
                        condition => "cke",
                        then => 
                        [
                            e_if->new({
                                comment   => " Checks whether to echo read cmd",
                                condition => "(read_cmd_echo && !read_cmd)",
                                then      => [e_assign->news 
                                              (["read_cmd" => "1'b1"],
                                              ["read_cmd_echo" => "1'b0"],
                                               ),
                                              ],
                                else      => [
                                e_if->new({
	                                comment   => " This is a read command",
	                                condition => "(cmd_code == 3'b101)",
	                                then      => [e_assign->news 
	                                              (["read_cmd" => "1'b1"],
	                                               ["read_cmd_echo" => "1'b1"],
	                                              ),
	                                             ],
	                                else      => ["read_cmd"  => "1'b0"],
                                }),
                                ],
                            }),
                            
                            e_if->new({
                                  comment   => " Checks whether to echo write cmd",
                                  condition => "(write_cmd_echo && !write_cmd)",
                                  then      => [e_assign->news 
                                                (["write_cmd" => "1'b1"],
                                                 ["write_cmd_echo" => "1'b0"],
                                                ),
                                               ],
                                  else      => [
                                  e_if->new({
                                      comment   => " This is a write command",
                                      condition => "(cmd_code == 3'b100)",
                                      then      => [e_assign-> news
                                                    (["write_cmd" => "1'b1"],
                                                     ["write_cmd_echo" => "1'b1"],
                                                     ["write_burst_length_pipe[0]" => "a[".$onthefly_bit."]"],
                                                     ),
                                                   ],
                                      else      => ["write_cmd" => "1'b0"],
                                  }),
                              ],
                            }),
                            
                            e_if->new({
                                comment   => " This is an activate - store the chip/row/bank address in the same order as the DDR controller",
                                condition => "(cmd_code == 3'b011)",
                                then      => ["open_rows[current_row]" => "a"],
                            }),                              
                        ],
                    }),
                ],
            }),
        );
	}

    $module->add_contents
    (
        e_process->new
        ({
        clock			=>	"clk",
        reset			=>	"reset_n",
        comment => " Pipes are flushed here",
        _asynchronous_contents	=>
        [
            e_assign->new(["wr_addr_pipe_1" => "0"]),
            e_assign->new(["wr_addr_pipe_2" => "0"]),
            e_assign->new(["wr_addr_pipe_3" => "0"]),
            e_assign->new(["wr_addr_pipe_4" => "0"]),
            e_assign->new(["wr_addr_pipe_5" => "0"]),
            e_assign->new(["wr_addr_pipe_6" => "0"]),
            e_assign->new(["wr_addr_pipe_7" => "0"]),
            e_assign->new(["wr_addr_pipe_8" => "0"]),
            e_assign->new(["wr_addr_pipe_9" => "0"]),
            e_assign->new(["wr_addr_pipe_10" => "0"]),
            e_assign->new(["wr_addr_pipe_11" => "0"]),
            e_assign->new(["wr_addr_pipe_12" => "0"]),
            e_assign->new(["wr_addr_pipe_13" => "0"]),
            e_assign->new(["wr_addr_pipe_14" => "0"]),
            e_assign->new(["wr_addr_pipe_15" => "0"]),
            e_assign->new(["wr_addr_pipe_16" => "0"]),
            e_assign->new(["wr_addr_pipe_17" => "0"]),
            e_assign->new(["wr_addr_pipe_18" => "0"]),
            e_assign->new(["rd_addr_pipe_1" => "0"]),
            e_assign->new(["rd_addr_pipe_2" => "0"]),
            e_assign->new(["rd_addr_pipe_3" => "0"]),
            e_assign->new(["rd_addr_pipe_4" => "0"]),
            e_assign->new(["rd_addr_pipe_5" => "0"]),
            e_assign->new(["rd_addr_pipe_6" => "0"]),
            e_assign->new(["rd_addr_pipe_7" => "0"]),
            e_assign->new(["rd_addr_pipe_8" => "0"]),
            e_assign->new(["rd_addr_pipe_9" => "0"]),
            e_assign->new(["rd_addr_pipe_10" => "0"]),
            e_assign->new(["rd_addr_pipe_11" => "0"]),
            e_assign->new(["rd_addr_pipe_12" => "0"]),
            e_assign->new(["rd_addr_pipe_13" => "0"]),
            e_assign->new(["rd_addr_pipe_14" => "0"]),
            e_assign->new(["rd_addr_pipe_15" => "0"]),
            e_assign->new(["rd_addr_pipe_16" => "0"]),
            e_assign->new(["rd_addr_pipe_17" => "0"]),
            e_assign->new(["rd_addr_pipe_18" => "0"]),
            e_assign->new(["rd_addr_pipe_19" => "0"]),
            e_assign->new(["rd_addr_pipe_20" => "0"]),
            e_assign->new(["rd_addr_pipe_21" => "0"]),
        ],
        contents => 
        [
            e_if->new({
                comment => " No Activity if the clock is",
                condition => "cke",
                then => 
                [
                    e_assign->news
                    (
                        ["rd_addr_pipe_21"  => "rd_addr_pipe_20"],
                        ["rd_addr_pipe_20"  => "rd_addr_pipe_19"],
                        ["rd_addr_pipe_19"  => "rd_addr_pipe_18"],
                        ["rd_addr_pipe_18"  => "rd_addr_pipe_17"],
                        ["rd_addr_pipe_17"  => "rd_addr_pipe_16"],
                        ["rd_addr_pipe_16"  => "rd_addr_pipe_15"],
                        ["rd_addr_pipe_15"  => "rd_addr_pipe_14"],
                        ["rd_addr_pipe_14"  => "rd_addr_pipe_13"],
                        ["rd_addr_pipe_13"  => "rd_addr_pipe_12"],
                        ["rd_addr_pipe_12"  => "rd_addr_pipe_11"],
                        ["rd_addr_pipe_11"  => "rd_addr_pipe_10"],
                        ["rd_addr_pipe_10"  => "rd_addr_pipe_9"],
                        ["rd_addr_pipe_9"  => "rd_addr_pipe_8"],
                        ["rd_addr_pipe_8"  => "rd_addr_pipe_7"],
                        ["rd_addr_pipe_7"  => "rd_addr_pipe_6"],
                        ["rd_addr_pipe_6"  => "rd_addr_pipe_5"],
                        ["rd_addr_pipe_5"  => "rd_addr_pipe_4"],
                        ["rd_addr_pipe_4"  => "rd_addr_pipe_3"],
                        ["rd_addr_pipe_3"  => "rd_addr_pipe_2"],
                        ["rd_addr_pipe_2"  => "rd_addr_pipe_1"],
                        ["rd_addr_pipe_1"  => "rd_addr_pipe_0"],
                        
                        ["rd_valid_pipe[25:1]" => "rd_valid_pipe[24:0]"],
                        ["rd_valid_pipe[0]" => "(cmd_code == 3'b101)"],
                        
                        ["wr_addr_pipe_18"  => "wr_addr_pipe_17"],
                        ["wr_addr_pipe_17"  => "wr_addr_pipe_16"],
                        ["wr_addr_pipe_16"  => "wr_addr_pipe_15"],
                        ["wr_addr_pipe_15"  => "wr_addr_pipe_14"],
                        ["wr_addr_pipe_14"  => "wr_addr_pipe_13"],
                        ["wr_addr_pipe_13"  => "wr_addr_pipe_12"],
                        ["wr_addr_pipe_12"  => "wr_addr_pipe_11"],
                        ["wr_addr_pipe_11"  => "wr_addr_pipe_10"],
                        ["wr_addr_pipe_10"  => "wr_addr_pipe_9"],
                        ["wr_addr_pipe_9"  => "wr_addr_pipe_8"],
                        ["wr_addr_pipe_8"  => "wr_addr_pipe_7"],
                        ["wr_addr_pipe_7"  => "wr_addr_pipe_6"],
                        ["wr_addr_pipe_6"  => "wr_addr_pipe_5"],
                        ["wr_addr_pipe_5"  => "wr_addr_pipe_4"],
                        ["wr_addr_pipe_4"  => "wr_addr_pipe_3"],
                        ["wr_addr_pipe_3"  => "wr_addr_pipe_2"],
                        ["wr_addr_pipe_2"  => "wr_addr_pipe_1"],
                        ["wr_addr_pipe_1"  => "wr_addr_pipe_0"],
                        
                        ["wr_valid_pipe[25:1]" => "wr_valid_pipe[24:0]"],
                        ["wr_valid_pipe[0]" => "(cmd_code == 3'b100)"],
                        
                        ["wr_addr_delayed_r"  => "wr_addr_delayed"],
                        
                        ["write_burst_length_pipe[25:1]" => "write_burst_length_pipe[24:0]"],
                    ),
                ],
            }),
        ],
        }),
    );
    
	if ($memtype eq "DDR SDRAM")
    {
	    $module->add_contents
        (
            e_process->new
            ({
                comment => " Decode CAS Latency from bits a[6:4]",
                contents => 
                [
                    e_if->new({
                        comment => " No Activity if the clock is disabled",
                        condition => "cke",
                        then => 
                        [
                            e_if->new({
                                comment   => "Load mode register - set CAS latency, burst mode and length",
                                condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                                then      => 
                                [
                                    e_assign->news
                                    (
                                        ["burstmode" => "a[3]"],
                                        ["burstlength" => "a[2:0] << 1"],
                                    ),
                                    e_if->new({
                                       comment    => "CAS Latency = 2.0",
                                       condition  => "(a[6:4] == 3'b010)",
                                       then       => [ e_assign->news(["tcl" => "4'b0001" ]) ],
                                       elsif => {
                                           condition => "(a[6:4] == 3'b110)",
                                           comment => "CAS Latency = 2.5",
                                           then => [ e_assign->news (["tcl" => "4'b0001" ]) ],                                            
                                       elsif => {
                                           condition => "(a[6:4] == 3'b011)",
                                           comment => "CAS Latency = 3.0",
                                           then => [ e_assign->news (["tcl" => "4'b0010" ]) ],                                            
                                       elsif => {
                                           condition => "(a[6:4] == 3'b100)",
                                           comment => "CAS Latency = 4.0",
                                           then => [ e_assign->news (["tcl" => "4'b0011" ]) ],                                            
                                       else       => 
                                           [ e_assign->news (["tcl" => "4'b0100" ]) ],
                                       }}}
                                    }),
                                ],
                            }),
                        ],
                    }),
			    ],
            }),
            
            e_process->new
            ({
                comment => "No additive latency in DDR",
                clock   => "",
                contents => 
                [
                    e_assign->news(["read_latency" => "tcl" ])
			    ],
            }),
        );
	}
    elsif ($memtype eq "DDR2 SDRAM")
    {
	    $module->add_contents
        (
            e_process->new
            ({
                comment => " Decode CAS Latency from bits a[6:4]",
                contents => 
                [
                    e_if->new({
                        comment => " No Activity if the clock is disabled",
                        condition => "cke",
                        then => 
                        [
                            e_if->new({
                                comment   => "Load mode register - set CAS latency, burst mode and length",
                                condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                                then      => 
                                [
                                    e_assign->news
                                    (
                                        ["burstmode" => "a[3]"],
                                        ["burstlength" => "a[2:0] << 1"],
                                    ),
                                    e_if->new({
                                       comment    => "CAS Latency = 3.0",
                                       condition  => "(a[6:4] == 3'b011)",
                                       then       => [ e_assign->news(["tcl" => "4'b0010" ]) ],
                                       elsif => {
                                           comment => "CAS Latency = 4.0",
                                           condition => "(a[6:4] == 3'b100)",
                                           then => [ e_assign->news (["tcl" => "4'b0011" ]) ],                                            
                                       elsif => {
                                           comment => "CAS Latency = 5.0",
                                           condition => "(a[6:4] == 3'b101)",
                                           then => [ e_assign->news (["tcl" => "4'b0100" ]) ],                                            
                                       elsif => {
                                           comment => "CAS Latency = 6.0",
                                           condition => "(a[6:4] == 3'b110)",
                                           then => [ e_assign->news (["tcl" => "4'b0101" ]) ],                                            
                                       else       => 
                                           [ e_assign->news (["tcl" => "4'b0110" ]) ],
                                       }}}
                                    }),
                                ],
                                elsif => {
                                    condition => "(cmd_code == 3'b000 && ba == 2'b01)",
                                    comment => "Get additive latency",
                                    then => [ e_assign->news (["additive_latency" => "{1'b0,a[5 : 3]}" ]) ],
                                }
                            }),
                        ],
                    }),
                ],
            }),
            
            e_process->new
            ({
                comment => "Calculate actual write and read latency",
                clock   => "",
                contents => 
                [
                    e_assign->news(["read_latency" => "tcl + additive_latency" ]),
                    e_assign->news(["write_latency" => "tcl + additive_latency" ])
			    ],
            }),
        );
    }
    else #DDR3
    {
        $module->add_contents
        (
            e_process->new
            ({
                comment => " Decode CAS Latency from bits a[6:4]",
                contents => 
                [
                    e_if->new({
                        comment => " No Activity if the clock is disabled",
                        condition => "cke",
                        then => 
                        [
                            e_if->new({
                                comment   => "Load mode register - set CAS latency, burst mode and length",
                                condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                                then      => 
                                [
                                    e_assign->news
                                    (
                                        ["burstmode" => "a[3]"],
                                        ["burstlength" => "a[2:0] << 1"],
                                    ),
                                    e_if->new({
                                       comment    => "CAS Latency = 5",
                                       condition  => "(a[6:4] == 3'b001)",
                                       then       => [ e_assign->news(["tcl" => "4'b0100" ]) ],
                                       elsif => {
                                           condition => "(a[6:4] == 3'b010)",
                                           comment => "CAS Latency = 6",
                                           then => [ e_assign->news (["tcl" => "4'b0101" ]) ],                                            
                                       elsif => {
                                           condition => "(a[6:4] == 3'b011)",
                                           comment => "CAS Latency = 7",
                                           then => [ e_assign->news (["tcl" => "4'b0110" ]) ],                                            
                                       elsif => {
                                           condition => "(a[6:4] == 3'b100)",
                                           comment => "CAS Latency = 8",
                                           then => [ e_assign->news (["tcl" => "4'b0111" ]) ],                                            
                                       elsif => {
                                           condition => "(a[6:4] == 3'b101)",
                                           comment => "CAS Latency = 9",
                                           then => [ e_assign->news (["tcl" => "4'b1000" ]) ],                                            
                                       else       => 
                                           [ e_assign->news (["tcl" => "4'b1001" ]) ],
                                       }}}}
                                    }),
                                ],
                                elsif => {
                                    condition => "(cmd_code == 3'b000 && ba == 2'b01)",
                                    comment => "Get additive latency",
                                    then => [ e_assign->news (["additive_latency" => "{2'b00,a[4 : 3]}" ]) ],
                                elsif => {
                                    condition => "(cmd_code == 3'b000 && ba == 2'b10)",
                                    comment => "Get write latency",
                                    then => [
                                        e_if->new({
                                           comment    => "CWL = 5",
                                           condition  => "(a[5:3] == 3'b000)",
                                           then       => [ e_assign->news(["wtcl" => "4'b0101" ]) ],
                                           elsif => {
                                               condition => "(a[5:3] == 3'b001)",
                                               comment => "CWL = 6",
                                               then => [ e_assign->news (["wtcl" => "4'b0110" ]) ],                                            
                                           elsif => {
                                               condition => "(a[5:3] == 3'b010)",
                                               comment => "CWL = 7",
                                               then => [ e_assign->news (["wtcl" => "4'b0111" ]) ],                                            
                                           elsif => {
                                               condition => "(a[5:3] == 3'b011)",
                                               comment => "CWL = 8",
                                               then => [ e_assign->news (["wtcl" => "4'b1000" ]) ],                                            
                                           }}}
                                        }),
                                    ],
                                }}
                            }),
                        ],
                    }),
			    ],
            }),
            
            e_process->new
            ({
                comment => "Calculate actual write and read latency",
                clock   => "",
                ##sensitivity_list => 
                contents => 
                [
                    e_if->new({
                       comment    => "no additive latency",
                       condition  => "(additive_latency == 4'd0)",
                       then       => [
                            e_assign->news(["read_latency" => "tcl" ]),
                            e_assign->news(["write_latency" => "wtcl" ])
                       ],
                       elsif => {
                           condition => "(additive_latency == 4'd1)",
                           comment => "CL - 1",
                           then => [
                                e_assign->news(["read_latency" => "tcl + (tcl + 1) - 1" ]),
                                e_assign->news(["write_latency" => "wtcl + (tcl + 1) - 1" ])
                           ],                                            
                       else       => 
                            [
                            e_assign->news(["read_latency" => "tcl + (tcl + 1) - 2" ]),
                            e_assign->news(["write_latency" => "wtcl + (tcl + 1) - 2" ])
                            ],
                       }
                    }),
			    ],
            }),
        );
    }


    if ($local_burst_length > 1 || $DDRx eq "true" || $NGv110 eq "true") # SPR 322284
    {
        my $burstcounter_size = $local_burst_length / 2; # burst length count need to wrap within a burst length, so we need a suitable sized counter
        
        if ($DDRx eq "true" || $NGv110 eq "true") {
            $burstcounter_size = 2;
        }
        
        # Burst support - make the wr_addr keep counting 
        $module->add_contents
        (
            e_process->new
            ({
                comment => " Burst support - make the wr_addr & rd_addr keep counting",
                _asynchronous_contents	=>
                [
                    e_assign->new(["wr_addr_pipe_0" => "0"]),
	                e_assign->new(["rd_addr_pipe_0" => "0"]),
                ],
                contents => 
                [
                    e_if->new({ # WRITES
                        comment => " Reset write address otherwise if the first write is partial it breaks!",
                        condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                        then      => 
                        [
                            e_assign->news
                            ( 
                                ["wr_addr_pipe_0" => "0"],
                                ["wr_burst_counter" => "0"],
                            ),
                        ],
                        else => 
                        [
                            e_if->new({
                                condition => "(cmd_code == 3'b100)",
                                then      => 
                                [
                                    e_assign-> news 
                                    (
                                        ["wr_addr_pipe_0"   => "{${cs_encode}ba,open_rows[current_row],addr_col}"],
                                        ["wr_burst_counter[".($read_addr_width-1).":".($burstcounter_size)."]" => "{${cs_encode}ba,open_rows[current_row],addr_col[".($col_width-2).":".($burstcounter_size)."]}"],
                                        ["wr_burst_counter[".($burstcounter_size-1).":0]" => "addr_col[".($burstcounter_size-1).":0] + 1"],
                                    ),
                                ],
                                else => 
                                [
                                    e_if->new({
                                        condition => "(write_cmd || write_to_ram || write_cmd_echo)",
                                        then      => 
                                        [
                                            e_assign-> news (["wr_addr_pipe_0" => "wr_burst_counter"],),
                                            e_assign-> news (["wr_burst_counter[".($burstcounter_size-1).":0]" => "wr_burst_counter[".($burstcounter_size-1).":0] + 1"],),
                                        ],
                                        else      => 
                                        [
                                             e_assign-> news (["wr_addr_pipe_0" => "0"],),
                                        ],
                                    }),
                                
                                ],
                            }),
                                
                        ],
                    }),
                    
                    e_if->new({  # READS
                        comment => " Reset read address otherwise if the first write is partial it breaks!",
                        condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                        then      => 
                        [
                            e_assign->news ( ["rd_addr_pipe_0" => "0"], ),
                        ],
                        else => 
                        [
                            e_if->new({
                                condition => "(cmd_code == 3'b101)",
                                then      => 
                                [
                                    e_assign-> news 
                                    (
                                        ["rd_addr_pipe_0"   => "{${cs_encode}ba,open_rows[current_row],addr_col}"],
                                        ["rd_burst_counter[".($read_addr_width-1).":".($burstcounter_size)."]" => "{${cs_encode}ba,open_rows[current_row],addr_col[".($col_width-2).":".($burstcounter_size)."]}"],
                                        ["rd_burst_counter[".($burstcounter_size-1).":0]" => "addr_col[".($burstcounter_size-1).":0] + 1"],
                                    ),
                                ],
                                else => 
                                [
                                    e_if->new({
                                        condition => "(read_cmd || dq_valid || read_valid || read_cmd_echo)",
                                        then      => 
                                        [
                                            e_assign-> news (["rd_addr_pipe_0" => "rd_burst_counter"],),
                                            e_assign-> news (["rd_burst_counter[".($burstcounter_size-1).":0]" => "rd_burst_counter[".($burstcounter_size-1).":0] + 1"],),
                                        ],
                                        else      => 
                                        [
                                            e_assign-> news (["rd_addr_pipe_0" => "0"],),
                                        ],
                                    }),
                                ],
                            }),
                        ],
                    }), # end of READS
                ], # end of contents
            }),
        );
    } 
    else
    {
        $module->add_contents # no Burst support
        (
            e_process->new
            ({
                contents => 
                [
                    e_if->new({
                        comment => " Reset write address otherwise if the first write is partial it breaks!",
                        condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                        then      => 
                        [
                            e_assign->news ( ["wr_addr_pipe_0" => "0"],), 
                        ],
                        else => 
                        [
                            e_if->new({
                                condition => "(cmd_code == 3'b100)",
                                then      => 
                                [
                                    e_assign-> news 
                                    (
                                        ["wr_addr_pipe_0"   => "{ba,open_rows[current_row],addr_col}"],
                                    ),
                                ],
                            }),
                        ],
                    }),
                    e_if->new({
                        comment => "Read request so store the read address",
                        condition => "(cmd_code == 3'b101)",
                        then      => 
                        [
                            e_assign-> news 
                            (
                                ["rd_addr_pipe_0"   => "{ba,open_rows[current_row],addr_col}"],
                            ),
                        ],
                    }),
                ],
            }),
        );
    }
    
    $module->add_contents
    (
        e_process->new
        ({
            comment => " read data transition from single to double clock rate",
            contents =>
            [
                e_assign->news 
                (
                    ["first_half_dq" => "read_data[".($dq_width*2-1).":".$dq_width."]"],
                    ["second_half_dq" => "read_data[".($dq_width-1).":0]"],
                ),
            ],
        }),
    );
	
    $module->add_contents
    (
        e_assign->new([read_dq => "clk  ? second_half_dq : first_half_dq"]),
        e_assign->new([dq_temp    => "dq_valid  ? read_dq : {".$dq_width."{1'bz}}"]),
        e_assign->new([dqs_temp   => "dqs_valid ? {".$dqs_width."{clk}} : {".$dqs_width."{1'bz}}"]),
    );

    if (($memtype eq "DDR3 SDRAM") || (($memtype eq "DDR2 SDRAM") && ($mem_if_dqsn_en eq "true")))  {
        $module->add_contents
        (
            e_assign->new([dqs_n_temp   => "dqs_valid ? {".$dqs_width."{~clk}} : {".$dqs_width."{1'bz}}"]),
        );
    }
	 
    if ($number_of_lump_delays > 0) {
        $module->add_contents
        (
            # model the effect of cas2.5 as two 90 deg delays
            e_assign->new ({lhs => "dqs_out_0", rhs => "dqs_temp", sim_delay => floor($clockperiod / 4), }),
            e_assign->new ({lhs => "dq_out_0",  rhs => "dq_temp",  sim_delay => floor($clockperiod / 4), }),
            e_assign->new ({lhs => $dqs, rhs => "dqs_out_0", sim_delay => floor($clockperiod / 4), }),
            e_assign->new ({lhs => $dq,  rhs => "dq_out_0",  sim_delay => floor($clockperiod / 4), }),
        );
    } else  
    {
        $module->add_contents
        (
            e_assign->new ({lhs => $dqs, rhs => "dqs_temp", }),
            e_assign->new ({lhs => $dq,  rhs => "dq_temp", }),
        );
        if (($memtype eq "DDR3 SDRAM") || (($memtype eq "DDR2 SDRAM") && ($mem_if_dqsn_en eq "true"))){
        	$module->add_contents
        	(
           		e_assign->new ({lhs => $dqs_n, rhs => "dqs_n_temp", }),
        	);
        }
    }

    $module->add_contents
    (
        e_process->new
        ({
            comment => "Pipelining registers for burst counting",
            contents =>
            [
                e_assign->news 
                (
                    ["write_valid_r"  => "write_valid"],
                    ["read_valid_r" => "read_valid"],
                    ["write_valid_r2" => "write_valid_r"],
                    ["write_valid_r3" => "write_valid_r2"],
                    ["write_to_ram_r" => "write_to_ram"],
                    ["read_valid_r2" => "read_valid_r"],
                    ["read_valid_r3" => "read_valid_r2"],
                    ["read_valid_r4" => "read_valid_r3"],
                ),
            ],
        }), 
    );
    
    if ($memtype eq "DDR3 SDRAM")
    {
	$module->add_contents
        (
            e_assign->new(["write_to_ram" => "write_burst_length ? write_valid || write_valid_r || write_valid_r2 || write_valid_r3 : write_valid || write_valid_r"]),
            e_assign->new(["dq_valid" => "read_valid_r || read_valid_r2 || read_valid_r3 || read_valid_r4"]),
        );
    }
    elsif ($DDRx eq "true" || $NGv110 eq "true") ##for DDR and DDR2 in DDRx, proper burst
    {
        $module->add_contents
        (
            e_assign->new(["write_to_ram" => "burstlength[1] ? write_valid || write_valid_r || write_valid_r2 || write_valid_r3 : write_valid || write_valid_r"]),
            e_assign->new(["dq_valid" => "burstlength[1] ? read_valid_r || read_valid_r2 || read_valid_r3 || read_valid_r4 : read_valid_r || read_valid_r2"]),
        );
    }
    elsif ($local_burst_length == 4)
    {
        # Memory BL8, local bl4 support
        $module->add_contents
        (
            e_assign->new(["write_to_ram" => "write_valid || write_valid_r || write_valid_r2 || write_valid_r3"]),
            e_assign->new(["dq_valid" => "read_valid_r || read_valid_r2 || read_valid_r3 || read_valid_r4"]),
        );
    }
    elsif ($local_burst_length == 2) {
        # Memory BL4, local bl2 support
        $module->add_contents
        (
            e_assign->new(["write_to_ram" => "write_valid || write_valid_r"]),
            e_assign->new(["dq_valid" => "read_valid_r || read_valid_r2 && burst_term"]),
        );
    } 
    else { 
        # No burst support
        $module->add_contents
        (
            e_assign->new(["write_to_ram" => "write_valid"]),
            e_assign->new(["dq_valid" => "read_valid_r"]),
        );
    };
    
    $module->add_contents
    (
        e_assign->new(["dqs_valid" => "dq_valid || dqs_valid_temp"]),
        
        e_process->new
        ({
            comment => " ",
            clock_level => "0",
            contents =>
            [
                e_assign->news 
                (
                    ["dqs_valid_temp" => "read_valid"],
                ),
            ],
        }),
        
        e_process->new
        ({
            comment => "capture first half of write data with rising edge of DQS, for simulation use only 1 DQS pin",
            clock   => $prefix."dqs[0]",
            contents => 
            [
                e_assign->new ({lhs => "dq_captured[".($dq_width-1).":0]", rhs => $prefix."dq[".($dq_width-1).":0]", sim_delay => 0.1}),
                e_assign->new ({lhs => "dm_captured[".($dm_width-1).":0]", rhs => $prefix."dm[".($dm_width-1).":0]", sim_delay => 0.1}),
            ]
        }),
        
        e_process->new
        ({
            comment => "capture second half of write data with falling edge of DQS, for simulation use only 1 DQS pin",
            clock   => $prefix."dqs[0]",
            clock_level => 0,
            contents => 
            [
                e_assign->new ({lhs => "dq_captured[".($dq_width*2-1).":".($dq_width)."]", rhs => $prefix."dq[".($dq_width-1).":0]", sim_delay => 0.1}),
                e_assign->new ({lhs => "dm_captured[".($dm_width*2-1).":".($dm_width)."]", rhs => $prefix."dm[".($dm_width-1).":0]", sim_delay => 0.1}),
            ]
        }),
    ); #   end of add_contents() 

         
    $module->add_contents
    (
        # there will always be at least DM[0]
        e_process->new
        ({
            comment => "Support for incomplete writes, do a read-modify-write with mem_bytes and the write data",
            contents => 
            [ 
                e_if->new
                ({
                    condition => "write_to_ram",
                    then => [e_assign->news (["rmw_temp[$gMEM_DQ_PER_DQS-1:0]","dm_captured[0] ? mem_bytes[$gMEM_DQ_PER_DQS-1 : 0] : dq_captured[$gMEM_DQ_PER_DQS-1 : 0]"],),],
                }),
            ],
        }),
    );
    
    # now do the rest of DM pins
    if ($mem_mask_width > 1) {
        for (1 .. ($mem_mask_width-1)) 
        {
            $byte_lane = $_;
            $lanes{$byte_lane} = (($byte_lane*$gMEM_DQ_PER_DQS)+($gMEM_DQ_PER_DQS-1)).":".($byte_lane*$gMEM_DQ_PER_DQS);
            $module->add_contents
            (
                e_process->new
                ({
                    contents =>
                    [
                        e_if->new
                        ({
                            condition => "write_to_ram",
                            then => [e_assign->news (["rmw_temp[$lanes{$byte_lane}]" => "dm_captured[$byte_lane] ? "."mem_bytes[$lanes{$byte_lane}] : "."dq_captured[$lanes{$byte_lane}]"],),],
                        }),
                    ],
                }),
            );
        } # for (0 to ($dm_width-1))
    } 
    
    # Generate the delayed write and read addresses
    if ($memtype eq "DDR SDRAM")  {
        
        $module->add_contents
        (
            e_assign->new(["write_valid","wr_valid_pipe[1]"]),
            e_assign->new(["wr_addr_delayed","wr_addr_pipe_1"]), # fixed write latency on DDR1
        );
    } 
    else # DDR2 SDRAM and DDR3
    {
        $module->add_contents
        (
            e_mux->new
            ({
                comment=> "DDR2 has variable write latency too, so use write_latency to select which pipeline stage drives valid",
                type   => "selecto",
                selecto=> "write_latency",
                lhs    => "write_valid",
                table  => 
                [
                    0 => "wr_valid_pipe[0]",
                    1 => "wr_valid_pipe[1]",
                    2 => "wr_valid_pipe[2]",
                    3 => "wr_valid_pipe[3]",
                    4 => "wr_valid_pipe[4]",
                    5 => "wr_valid_pipe[5]",
                    6 => "wr_valid_pipe[6]",
                    7 => "wr_valid_pipe[7]",
                    8 => "wr_valid_pipe[8]",
                    9 => "wr_valid_pipe[9]",
                    10 => "wr_valid_pipe[10]",
                    11 => "wr_valid_pipe[11]",
                    12 => "wr_valid_pipe[12]",
                    13 => "wr_valid_pipe[13]",
                    14 => "wr_valid_pipe[14]",
                    15 => "wr_valid_pipe[15]",
                    16 => "wr_valid_pipe[16]",
                    17 => "wr_valid_pipe[17]",
                    18 => "wr_valid_pipe[18]",
                ],
            }),
            e_mux->new
            ({
                comment=> "DDR2 has variable write latency too, so use write_latency to select which pipeline stage drives addr",
                type   => "selecto",
                selecto=> "write_latency",
                lhs    => "wr_addr_delayed",
                table  => 
                [
                    0 => "wr_addr_pipe_0",
                    1 => "wr_addr_pipe_1",
                    2 => "wr_addr_pipe_2",
                    3 => "wr_addr_pipe_3",
                    4 => "wr_addr_pipe_4",
                    5 => "wr_addr_pipe_5",
                    6 => "wr_addr_pipe_6",
                    7 => "wr_addr_pipe_7",
                    8 => "wr_addr_pipe_8",
                    9 => "wr_addr_pipe_9",
                    10 => "wr_addr_pipe_10",
                    11 => "wr_addr_pipe_11",
                    12 => "wr_addr_pipe_12",
                    13 => "wr_addr_pipe_13",
                    14 => "wr_addr_pipe_14",
                    15 => "wr_addr_pipe_15",
                    16 => "wr_addr_pipe_16",
                    17 => "wr_addr_pipe_17",
                    18 => "wr_addr_pipe_18",
                ],
            }),         
        );
        
        if ($memtype eq "DDR3 SDRAM")
        {
            $module->add_contents
            (
                e_mux->new
                ({
                    comment=> "DDR3 has on the fly mode",
                    type   => "selecto",
                    selecto=> "write_latency",
                    lhs    => "write_burst_length",
                    table  => 
                    [
                        0 => "write_burst_length_pipe[0]",
                        1 => "write_burst_length_pipe[1]",
                        2 => "write_burst_length_pipe[2]",
                        3 => "write_burst_length_pipe[3]",
                        4 => "write_burst_length_pipe[4]",
                        5 => "write_burst_length_pipe[5]",
                        6 => "write_burst_length_pipe[6]",
                        7 => "write_burst_length_pipe[7]",
                        8 => "write_burst_length_pipe[8]",
                        9 => "write_burst_length_pipe[9]",
                        10 => "write_burst_length_pipe[10]",
                        11 => "write_burst_length_pipe[11]",
                        12 => "write_burst_length_pipe[12]",
                        13 => "write_burst_length_pipe[13]",
                        14 => "write_burst_length_pipe[14]",
                        15 => "write_burst_length_pipe[15]",
                        16 => "write_burst_length_pipe[16]",
                        17 => "write_burst_length_pipe[17]",
                        18 => "write_burst_length_pipe[18]",
                    ],
                }),
            );
        }
        
    } # if not DDR SDRAM
    
    #add burst terminate support for DDR_HP, SPR 266058
    if ($memtype eq "DDR SDRAM" && $DDRx eq "false" && $NGv110 eq "false")  {
        
        $module->add_contents
        (
            e_signal->news
            (
                {name => "burst_term_pipe",   width=> 11},
            ),
            
            e_process->new
            ({
                comment => "Registering burst term command",
                contents => [
                    e_assign->news (
                    ["burst_term_pipe[0]"  => "~burst_term_cmd"],
                    ["burst_term_pipe[10:1]" => "burst_term_pipe[9:0]"],
                    ),
                ],
            }), 
            
            e_mux->new
            ({
                comment=> "burst terminate piped along cas latency",
                type   => "selecto",
                selecto=> "read_latency",
                lhs    => "burst_term",
                table  => 
                [
                    0 => "burst_term_pipe[0]",
                    1 => "burst_term_pipe[1]",
                    2 => "burst_term_pipe[2]",
                    3 => "burst_term_pipe[3]",
                    4 => "burst_term_pipe[4]",
                    5 => "burst_term_pipe[5]",
                    6 => "burst_term_pipe[6]",
                    7 => "burst_term_pipe[7]",
                    8 => "burst_term_pipe[8]",
                    9 => "burst_term_pipe[9]",
                    10 => "burst_term_pipe[10]",
                ],
            }),
        );
    }
    elsif ($local_burst_length == 2) { #not DDR but local_burst_length=2
        $module->add_contents
        (
             e_assign->new(["burst_term" => "1'b1"]),
         );
    } 
    
    $module->add_contents
    (
        e_assign->new(["mem_bytes" => "(rmw_address == wr_addr_delayed_r && write_to_ram_r) ? rmw_temp : read_data"]), #SPR 322284 
        e_assign->new(["rmw_address", "(write_to_ram) ? wr_addr_delayed : read_addr_delayed"]),
    ); 
    
    $module->add_contents
    (
        e_signal->news
        (
            {name => "read_addr", width => $read_addr_width, never_export => 1},
            {name => "read_valid",width => 1,                never_export => 1},
        ),        
        e_mux->new
        ({
            comment=> "use read_latency to select which pipeline stage drives addr",
            type   => "selecto",
            selecto=> "read_latency",
            lhs    => "read_addr_delayed",
            table  => 
            [
                0 => "rd_addr_pipe_0",
                1 => "rd_addr_pipe_1",
                2 => "rd_addr_pipe_2",
                3 => "rd_addr_pipe_3",
                4 => "rd_addr_pipe_4",
                5 => "rd_addr_pipe_5",
                6 => "rd_addr_pipe_6",
                7 => "rd_addr_pipe_7",
                8 => "rd_addr_pipe_8",
                9 => "rd_addr_pipe_9",
                10 => "rd_addr_pipe_10",
                11 => "rd_addr_pipe_11",
                12 => "rd_addr_pipe_12",
                13 => "rd_addr_pipe_13",
                14 => "rd_addr_pipe_14",
                15 => "rd_addr_pipe_15",
                16 => "rd_addr_pipe_16",
                17 => "rd_addr_pipe_17",
                18 => "rd_addr_pipe_18",
                19 => "rd_addr_pipe_19",
                20 => "rd_addr_pipe_20",
                21 => "rd_addr_pipe_21",
            ],
        }),        
        e_mux->new
        ({
            comment=> "use read_latency to select which pipeline stage drives valid",
            type   => "selecto",
            selecto=> "read_latency",
            lhs    => "read_valid",
            table  => 
            [
                0 => "rd_valid_pipe[0]",
                1 => "rd_valid_pipe[1]",
                2 => "rd_valid_pipe[2]",
                3 => "rd_valid_pipe[3]",
                4 => "rd_valid_pipe[4]",
                5 => "rd_valid_pipe[5]",
                6 => "rd_valid_pipe[6]",
                7 => "rd_valid_pipe[7]",
                8 => "rd_valid_pipe[8]",
                9 => "rd_valid_pipe[9]",
                10 => "rd_valid_pipe[10]",
                11 => "rd_valid_pipe[11]",
                12 => "rd_valid_pipe[12]",
                13 => "rd_valid_pipe[13]",
                14 => "rd_valid_pipe[14]",
                15 => "rd_valid_pipe[15]",
                16 => "rd_valid_pipe[16]",
                17 => "rd_valid_pipe[17]",
                18 => "rd_valid_pipe[18]",
                19 => "rd_valid_pipe[19]",
                20 => "rd_valid_pipe[20]",
                21 => "rd_valid_pipe[21]",
            ],
        }),
    );
    
    print "# Finished creating memory model\n";
         
    $project->output();
}

1;
