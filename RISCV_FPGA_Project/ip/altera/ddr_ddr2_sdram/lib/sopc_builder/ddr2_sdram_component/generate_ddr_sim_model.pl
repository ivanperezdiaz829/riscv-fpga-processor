#Copyright (C)1991-2002 Altera Corporation
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

# This model tries to leverage as many functions and GUI similarities as
# possible from Aaron Ferrucci's sdram_controller.pm.  The actual
# generated code and pin interface is quite different, but all the
# parameters and restrictions of generic SDRAM still apply...

### NB: &one_hot_encoding now in europa_utils.pm!
### NB: str2hex routine now in europa_utils.pm!

sub convert_times
{
    my ($WSA, $time_values) = @_;
    
    my $sys_clk = $WSA->{system_clock_rate};
    
    for my $k (keys %{$time_values})
    {
        $WSA->{$k} .= $time_values->{$k};
        convert_time_unit(\$WSA->{$k}, $sys_clk);
    }
} # &convert_times

# Convert stuff like
# 
# 15.625us
# 100us
# 70ns
# 120us
# 20ns
# 2clocks
# 20ns
# 17ns
# 1clock+7ns
#
# into CLOCKS (rounded up), and return in the input value.
sub convert_time_unit
{
    my ($valRef, $system_clock_rate) = @_;
    
    my $result = $$valRef;
    
    my $system_clock_period = 1 / $system_clock_rate;
    
    $result =~ s/ms/*(1e-3)/g;
    $result =~ s/us/*(1e-6)/g;
    $result =~ s/ns/*(1e-9)/g;
    $result =~ s/clock[s]?/*($system_clock_period)/g;
    
    # create result in seconds:
    $result = eval($result);  
    # convert result from seconds into clocks:
    $result = ceil ($result * $system_clock_rate);

    # print "em_sdram.pm/convert_time_unit:\t$$valRef\t=\t$result clocks\n";

    if ($@)
    {
        ribbit("failed to eval '$$valRef' in convert_time_unit(): '$@'");
    }
    
    $$valRef = $result;
} # & convert_time_unit

sub get_time_values
{
  # This table gives the units that apply to each WSA parameter.
  return (
    refresh_period        => "us",
    powerup_delay         => "us",
    t_rfc                 => "ns",
    t_mrd                 => "clocks",
    t_rp                  => "ns",
    t_rcd                 => "ns",
    t_ac                  => "ns",
    t_wr                  => "ns",
    init_nop_delay        => "us",
  );
} # &get_time_values

# replicate_bit(width, value)
#
# e.g.
# replicate(4, 0) returns "4'b0000'".
sub replicate_bit
{
  # width has to be only decimal digits, and non-zero.
  my $width = shift
      or ribbit("Usage error: no width! ".
                "(expected 'replicate_bit(width, value)')\n");
  $width =~ /^\d+$/ or die "Unexpected width: '$width'\n";
  
  # value must be 0 or 1.
  my $value = shift;
  ribbit("Usage error: bad value '$value'!\n")
    if $value !~ /^[01]$/;

  ribbit("Usage error: too many parameters! ".
         "(expected 'replicate_bit(width, value)')\n") if @_;
  
  $value =~ /^\d+$/ or die "Unexpected value: '$value'\n";
  
  return $width . "'b" . ($value x $width);
} # &replicate_bit





# Main DDR simulation model.
sub make_ddr_sim_model 
{
    # No arguments means "Ignore -- I'm being called from make".
    if (!@_)
    {
        # print "\n\tmake_sdram_controller now uses a static".
        # " external 'class.ptf'!\n\n";
        return 0; # make_class_ptf();
    }
    
    # TEW: Get SDRAM's project, Options, etc:
    my $project = e_project->new(@_);
    my %Options = %{$project->WSA()};
    my $WSA = \%Options;
    
    # Grab the module that was created during handle_args.
    my $module = $project->top();

    # Grab some args to determine how to proceed, like model_base and init_file
    $WSA->{is_blank}=($WSA->{sim_Kind} =~ /^blank/i) ? "1" : "0";
    $WSA->{is_file} =($WSA->{sim_Kind} =~ /^textfile/i) ? "1" : "0";
    
    my $textfile = $WSA->{sim_Textfile_Info};
  
    #turn bar/foo.srec relative path into an absolute one if needed
    my $system_directory = $project->_system_directory();
    $textfile =~ s/^(\w+)(\\|\/)/$system_directory$2$1$2/;
    #turn foo.srec to absolute path
    $textfile =~ s/^(\w+)$/$system_directory\/$1/;
    
    $WSA->{textfile}= $textfile;

    # Figure out where our contents are coming from:
    $WSA->{Initfile} = $project->_target_module_name() . "_contents.srec";
    
    my $do_generation = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{do_build_sim};
    
    # Only generate model if "Simulation. Create simulator..." is ticked.
    if ($do_generation == 1) {
        print "# Creating memory simulation model for use with ".$project->_target_module_name()."\n";
        
        # We only accept .mif- and .srec-files (or just blankness)
        &ribbit ("Memory-initialization files must be either .mif or .srec.\n",
                 " not '$WSA->{Initfile}'\n")
            unless $WSA->{Initfile} =~ /\.(srec|mif)$/i;
        
    
        
        
        # Figure out what language we're generating for
        my $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
        my $extension;
        my $sim_file = $project->get_top_module_name();
        my $sim_dat  = $project->_target_module_name() . ".dat";
        if ($lang =~ /vhd/i    ) { 
            $sim_file .= ".vhd";
            $extension = ".vhd";
        }
        if ($lang =~ /verilog/i) { 
            $sim_file .= ".v";
            $extension = ".v";
        }
        my @write_lines;
    
    
    
        # Add datapath and other files to simulation list        
        my $sopc_device_family = lc($project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{device_family_id});
        my $device_family = lc($WSA->{MEGACORE}{NETLIST_SECTION}{STATIC_SECTION}{PRIVATES}{NAMESPACE}{parameterization}{PRIVATE}{family}{value});
        
        #if ($sopc_device_family ne $device_family) { print "WARNING! The device selected in SOPC Builder (".$sopc_device_family.") does match the DDR SDRAM device (".$device_family.")\n";}
    
        #print "SOPC Builder device family is ".$sopc_device_family."\n";
        #print "DDR Megacore device family is ".$device_family."\n";
            
        
        my $wrapper_name = $project->_target_module_name();
        my $quartus_directory = $project->get_quartus_rootdir();
    
        #print "Quartus came from ".$quartus_directory." and device family is $device_family\n";
        #print "Wrapper file name is ".$wrapper_name.$extension."\n";
        
        
        
        #print "\nOriginal files list = ".$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files}."\n";
        
        my $magic_proj_dir = "__PROJECT_DIRECTORY__/";
        my $datapath_files = "";
    
       # SOPC Builder treats Stratix II & Stratix II GX as different families but we don't...
       if ($sopc_device_family eq "stratixiigx") {
           $sopc_device_family = "stratixii";   
       }
       # SOPC Builder now treats Stratix & Stratix GX as different families (it didn't used to!) but we don't...
       if ($sopc_device_family eq "stratixgx") {
           $sopc_device_family = "stratix";   
       }
        
       # Simulation libraries required 
       $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} = "auk_ddr_user_lib,";
       #$project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "UNUSED";
       $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "$sopc_device_family";
    
       if ($sopc_device_family eq "cycloneii") 
       { 
           $datapath_files .= $quartus_directory."/eda/sim_lib/cycloneii_atoms".$extension.",";  
           if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/cycloneii_components.vhd,"; } 
       }
       if ($sopc_device_family eq "cyclone") 
       { 
           $datapath_files .= $quartus_directory."/eda/sim_lib/cyclone_atoms".$extension.",";  
           if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/cyclone_components.vhd,"; } 
       }
       # SOPC Builder treats StratixII & StratixII GX as different so we have made the names the same for now  
       if ($sopc_device_family eq "stratixii") 
       { 
           $datapath_files .= $quartus_directory."/eda/sim_lib/stratixii_atoms".$extension.",";  
           if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/stratixii_components.vhd,"; } 
       }
       # SOPC Builder treats StratixII & StratixII GX as different so we have made the names the same for now  
       if ($sopc_device_family eq "stratix")  
       { 
           $datapath_files .= $quartus_directory."/eda/sim_lib/stratix_atoms".$extension.",";  
           if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/stratix_components.vhd,"; } 
       }
    
       # Now add the files needed for the datapath itself   
       $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_dqs_group".$extension.",";
       $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_clk_gen".$extension.",";
       $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_datapath".$extension.",";
       if ($lang =~ /vhd/i) {$datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_datapath_pack.vhd,";}
       
       $project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files} = $datapath_files.$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files};
        
        
        
        #print "Updated files list = ".$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files}."\n";
        #print "Create libraries called = ".$project->module_ptf()->{HDL_INFO}{Simulation_Library_Names}."\n";
        
        
        #--------------------------------------------------------
        # Create a shortcut to the right bit of the DDR's PTF
        my %myshortcut =  %{$WSA->{MEGACORE}{NETLIST_SECTION}{STATIC_SECTION}{PRIVATES}{NAMESPACE}{parameterization}};
        my $wizard_shortcut = \%myshortcut;
        #--------------------------------------------------------
    
        
        # Work out whether this should be DDR1 or DDR2
        my $memtype =  $wizard_shortcut->{PRIVATE}{gMEM_TYPE}{value};
        #print "This is a ".$memtype." controller\n";
    
        my $mem_pretty_name = "DDR SDRAM";
        if ($memtype eq "ddr2_sdram") {$mem_pretty_name = "DDR2 SDRAM";}
        
        my $default_pin_prefix = "ddr_";
        if ($memtype eq "ddr2_sdram") {$default_pin_prefix = "ddr2_";}
    
        my $local_burst_length =  $wizard_shortcut->{PRIVATE}{local_burst_length}{value};
        #print "Avalon burst length is $local_burst_length \n";
        
        
        # Start building up a simulation-only display string.
        @write_lines = 
            (
             "",
             "**********************************************************************",
             "This testbench includes an SOPC Builder generated Altera memory model:",
             "'$sim_file', to simulate accesses to the $mem_pretty_name memory.",
             " ",
             );
              
       # if ($local_burst_length > 1) 
       # {
         # push @write_lines,(
             # "WARNING: The Altera $mem_pretty_name Controller supports Avalon bursts,", 
             # "but this simulation model does not. If any of the masters in your",
             # "SOPC Builder system will issue Avalon bursts, then you ",
             # "should use a memory model supplied by your memory vendor.   ",
             # " ",
             # );
       # }
             
            push @write_lines,
            (
             "Initial contents are loaded from the file: ".
             "'$sim_dat'."
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
      
        # sjh WRONG - should get the clock properly!
        $WSA->{system_clock_rate} = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{clock_freq};
            
        # New style contents generation (a'la OnchipMemoryII -- thanks AaronF)
        my $Opt = {name => $project->_target_module_name()};
        $project->do_makefile_target_ptf_assignments
            (
             's1',
             ['dat', 'sym', ],
             $Opt,
             );
        
        # Reality checks:
        
        
        #my $tempclockrate = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{clock_freq};
        my $clockrate = $wizard_shortcut->{PRIVATE}{clock_speed}{value};
        #print "clockrate = $clockrate\n";
        
        my $clockperiod = 1/$clockrate*1000;
        #print "clockperiod = $clockperiod\n";
    
    
        #print "Data width = ".$wizard_shortcut->{PRIVATE}{width}{value}."\n";
        #print "Data width2 = ".$WSA->{MEGACORE}{NETLIST_SECTION}{STATIC_SECTION}{PRIVATES}{NAMESPACE}{parameterization}{PRIVATE}{width}{value}."\n";
    
        # SODIMM allows all the same data path widths as the sdram controller
        &validate_parameter({
            hash => $wizard_shortcut->{PRIVATE}{width},
            name => "value",
            type => "integer",
            allowed => [8, 16, 32, 64],
        });
        
        
        #sjh Don't check these for now
        # &validate_parameter({
            # hash => $WSA,
            # name => "sdram_bank_width",
            # type => "integer",
            # default => "2", 
            # allowed => [1, 2],
        # });
        
        #sjh Don't check these for now
        # # Having a non-integer power of 2 for number of chip selects seems wrong.
        # my $num_chipselects = $WSA->{sdram_num_chipselects};
        my $num_chipselects = $wizard_shortcut->{PRIVATE}{chipselects}{value};
        my $num_chipselect_address_bits = log2($num_chipselects);
        # &validate_parameter({
            # hash => $WSA,
            # name => "sdram_num_chipselects",
            # type => "integer",
            # allowed => [1, 2, 4, 8],
        # });
        
        my $cas_latency = $wizard_shortcut->{PRIVATE}{cas_latency}{value};
        #print "CAS latency = $cas_latency\n";
    
        # In the real world, 3 bits of the mode register are used to encode
        # cas latency, with code "3'b000" reserved.
        &validate_parameter({
            hash => $wizard_shortcut->{PRIVATE}{cas_latency},
            name => "value",
            type => "string",
            allowed => ["2.0", "2.5", "3.0", "4.0", "5.0"],
        });
    
        my $resynch_phase = $wizard_shortcut->{PRIVATE}{resync_phase}{value};
        my $resynch_cycle = $wizard_shortcut->{PRIVATE}{resynch_cycle}{value};
        #print "resynch cycle = $resynch_cycle\n";
        #print "resynch phase = $resynch_phase\n";
    
        # approximate the roundtrip delay based on resynch cycle (taking CL into account) - 1/4 cycle + whatever the resynch phase is,.
        # my $rtl_sim_delay = (($resynch_cycle + 2 - $cas_latency)*$clockperiod) + ($clockperiod * ($resynch_phase/360));
        my $clock_board_delay = $wizard_shortcut->{PRIVATE}{board_tpd_clock_trace_nom}{value};
        my $dqs_board_delay = $wizard_shortcut->{PRIVATE}{board_tpd_dqs_trace_total_nom}{value};
        my $rtl_board_delay = ($clock_board_delay + $dqs_board_delay) / 1000;

        # split total delay in 90 deg segements because we can't set modelsim to use transport delays instead of inertial!
        # my $number_of_lump_delays = floor($rtl_sim_delay / ($clockperiod / 4) + 1);
        #print "sim delay  = $rtl_sim_delay spread over $number_of_lump_delays delays.\n";
        
        
    
    
        #sjh Not needed for DDR
        # This setting is hidden from the GUI, but takes affect as a result
        # of using the 'preset's...
        # FIXME: Our model doesn't care about refresh commands, but we might want
        # to indicate via printf/write/$display that they are occuring...
        # &validate_parameter({
            # hash => $WSA,
            # name => "init_refresh_commands",
            # type => "integer",
            # allowed => [1 .. 8],
        # });
        
    
        # Compute the width of the controller's address (as seen by the Avalon
        # bus) from input parameters.  SODIMM will address a raw memory array in
        # the same way that Avalon accesses the Controller.
        # my $addr_width =
            # $num_chipselect_address_bits +
            # $WSA->{sdram_bank_width} +
            # $WSA->{sdram_col_width} +
            # $WSA->{sdram_row_width};
        my $addr_width = $wizard_shortcut->{PRIVATE}{local_address_width}{value};
        my $ba_width = $wizard_shortcut->{PRIVATE}{bankbits}{value};
        my $row_width = $wizard_shortcut->{PRIVATE}{rowbits}{value};
        my $col_width = $wizard_shortcut->{PRIVATE}{colbits}{value};
        #print "Controller has address widths, a = $addr_width, ba = $ba_width, row = $row_width, col = $col_width\n"; 
        
        # print "ctrler width = $addr_width\t ".
        # "Num CSBits = $num_chipselect_address_bits\n";
        # print "Num Banks = ".$WSA->{sdram_num_banks}.
        # " \tNum BankBits = ".$WSA->{sdram_bank_width}."\n";
        # print "Rows = ".$WSA->{sdram_row_width}.
        # " \tCols = ".$WSA->{sdram_col_width}."\n";
    
        # FIXME:?  We check NOTHING about validity of SDRAM Controller Timing or
        # Protocol -- we trust the user to set the parameters as if for a real
        # SODIMM!
        
        
        my $dq_width  = $wizard_shortcut->{PRIVATE}{width}{value};
        my $dqs_width = $wizard_shortcut->{PRIVATE}{width}{value} / 8;
        my $dm_width  = $wizard_shortcut->{PRIVATE}{width}{value} / 8;
        
        my $mem_width = $dq_width * 2;
        my $mem_mask_width = $dm_width * 2;
        
        
        #my $dm_width = $WSA->{sdram_data_width} / 8;
        # if (int($dm_width) != $dm_width)
        # {
            # ribbit
                # (
                 # "Unexpected: SDRAM data width '", $dq_width}, "', ".
                 # "leads to non-integer DQM width ($dm_width)"
                 # );
        # }
        # else
        # {
        # printf ("make_sodimm: data_width = %d\tdqm_width = %d\n",
        # $WSA->{sdram_data_width},$dm_width);
        # }
        
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
        #my $ram_file = "";
        #if ($WSA->{is_initialized}) {
        my  $ram_file = $sim_dat;
        #}
    
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
                     #wren => "write_valid_r2",
                     wren => "write_to_ram_r",
                     data => "rmw_temp",
                     q    => "read_data",
                     wrclock => "clk",
                     #wraddress=>"wr_addr_delayed",
                     wraddress=>"wr_addr_delayed_r",
                     #rdaddress=>"(write_valid) ? wr_addr_pipe_1 : read_addr_delayed",
                     rdaddress=>"rmw_address",
                 }
             }),
             );
    
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
        my $dqs;                     # variable for dq signal name, for 3-state mode
        $dq = $default_pin_prefix."dq";             # Dedicated pin-mode dq name
        $dqs = $default_pin_prefix."dqs";             # Dedicated pin-mode dq name
        
        # Dedicated pin-mode sodimm port names and assignments
        $module->add_contents
            (
             e_port->news
             (
              {name => "clk"},
              {name => $default_pin_prefix."cke",   width => $num_chipselects},
              {name => $default_pin_prefix."cs_n",  width => $num_chipselects},
              {name => $default_pin_prefix."ras_n"},
              {name => $default_pin_prefix."cas_n"},
              {name => $default_pin_prefix."we_n"},
              {name => $default_pin_prefix."dm",    width => $dm_width },
              {name => $default_pin_prefix."ba",    width => $ba_width },
              {name => $default_pin_prefix."a",     width => $row_width },
              {name => $default_pin_prefix."dq",    width => $dq_width, direction => "inout"},
              {name => $default_pin_prefix."dqs",   width => $dqs_width, direction => "inout"},
              ),
             e_signal->news
             (
              {name => "cke",  width => $num_chipselects},
              {name => "cs_n",  width => $num_chipselects},
              {name => "ras_n"},
              {name => "cas_n"},
              {name => "we_n"},
              {name => "dm",   width => $dm_width,export => 0, never_export => 1},
              {name => "ba",    width => $ba_width},
              {name => "a",     width => $row_width},
              {name => "read_dq",      width => $dq_width},
              {name => "dqs",           width => $dqs_width},
              {name => "first_half_dq", width => $dq_width,export => 0, never_export => 1},
              {name => "second_half_dq",width => $dq_width,export => 0, never_export => 1},
              {name => "dq_captured",   width=> $dq_width*2,export => 0, never_export => 1},
              {name => "dq_valid",     width=> 1,export => 0, never_export => 1},
              {name => "dqs_valid",     width=> 1,export => 0, never_export => 1},
              {name => "dqs_valid_temp",  width=> 1,export => 0, never_export => 1},
              {name => "dm_captured",   width=> $dqs_width*2,export => 0, never_export => 1},
              {name => "open_rows",     width => $row_width, depth => (2 ** ($ba_width + $num_chipselects))},
              {name => "current_row",   width => ($ba_width + $num_chipselects),export => 0, never_export => 1},
              
              {name => "dqs_temp",     width => $dqs_width},
              {name => "dq_temp",      width => $dq_width},
              
              ),
             e_assign->news
             (
              ["cke"   => $default_pin_prefix."cke"],
              ["cs_n"  => $default_pin_prefix."cs_n"],
              ["ras_n" => $default_pin_prefix."ras_n"],
              ["cas_n" => $default_pin_prefix."cas_n"],
              ["we_n"  => $default_pin_prefix."we_n"],
              ["dm"    => $default_pin_prefix."dm"],
              ["ba"    => $default_pin_prefix."ba"],
              ["a"     => $default_pin_prefix."a"],
              ),
             );
    
        # my $x;
        # if ($number_of_lump_delays > 1) {
            # for ($x=0; $x < ($number_of_lump_delays ); $x++) {            
                # #print "connecting lump delay $x out of $number_of_lump_delays\n";
                # $module->add_contents
                # (
                    # e_signal->news
                    # (
                       # {name => "dqs_out_".$x,     width => $dqs_width},
                       # {name => "dq_out_".$x,      width => $dq_width},
                    # )
                # );
            # }
        # }
    
             
             
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
        #my $arb_width = $WSA->{sdram_bank_width} + $WSA->{sdram_row_width};
        my $arb_width = $ba_width + $row_width;
    
        $arb_rhs = "{ba, a}";
        # if ($ba_width == 1)
        # {
            # # We only have 2 banks, row/addr build as {row,bank}
            # $arb_rhs = "{a, ba}";
        # }
        # elsif ($ba_width == 2)
        # {
            # # 4 banks construct address as {bank[1],row,bank[0]}
            # $arb_rhs = "{ba[1], a, ba[0]}"
        # }
    
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
        my $ac_rhs = "a[".($col_width-1).":1]";
        # if ($col_width < 11) {
            # $ac_rhs = "a[".($col_width-1).":0]";
        # } elsif ($col_width == 11) {
            # $ac_rhs = "{a[11],a[9:0]}";
        # } else {
            # $ac_rhs = "{a[".$col_width.":11],a[9:0]}";
        # }
        my $read_addr_width = $acrb_width + $col_width;
        $module->add_contents
            (
             e_signal->news
             (
              #{name => "addr_crb", width=> $acrb_width},
              {name => "addr_col", width=> $col_width - 1},
              {name => "test_addr",width=> $read_addr_width},
              # {name => "temp_addr",width=> $read_addr_width},
              ),
             e_signal->news
             (
              {name => "rd_addr_pipe_0", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_addr_pipe_1", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_addr_pipe_2", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_addr_pipe_3", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_addr_pipe_4", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_addr_pipe_5", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "read_addr_delayed", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rmw_address", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
          
              {name => "wr_addr_pipe_0", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_pipe_1", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_pipe_2", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_pipe_3", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_pipe_4", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_pipe_5", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_addr_delayed", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "wr_burst_counter", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              {name => "rd_burst_counter", width=> $read_addr_width, default_value => "0",export => 0, never_export => 1},
              ),
             e_assign->news
             (
              ["addr_col" => $ac_rhs],
              # ["test_addr"=> "{addr_crb, addr_col}"],
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
              {name => "rd_valid_pipe",   width=> 6}, # was 5?
              {name => "wr_valid_pipe",   width=> 6}, # was 5?
              #{name => "latency",         width=> 3},
              {name => "index",           width=> 3},
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
             e_assign->new(["current_row" => "{cs_n,ba}"]),
             );
    
        #sjh - No need for *read* masking with DDR
        # # Try to make life easier by defining the necessary number of byte lane
        # #field descriptors like 7:0, 15:8, etc...
        my %lanes;
        my $byte_lane;
        # # assign rmw_temp[7:0]= dqm[0] ? mem_bytes[7:0] : $dq[7:0]
        # if ($mem_mask_width > 1) {
            # for (0 .. ($mem_mask_width-1))
            # {
                # $byte_lane = $_;
                # $lanes{$byte_lane} = (($byte_lane*8)+7).":".($byte_lane*8);
                # $module->add_contents
                    # (
                     # e_assign->new
                     # (
                      # ["rmw_temp[$lanes{$byte_lane}]" =>
                       # "dm[$byte_lane] ? ".
                       # "mem_bytes[$lanes{$byte_lane}] : ".$dq."[$lanes{$byte_lane}]"]
                      # )
                     # );
            # } # for (0 to ($dm_width-1))
        # } else {
            # $module->add_contents
                # (
                 # e_assign->new(["rmw_temp" => "dm ? mem_bytes : ".$dq])
                 # );
        # }
        
        # Build the Main Process:
        $module->add_contents
            (
             e_process->new
             ({
                 comment => " Decode commands into their actions",
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
                                                  # ["rd_addr_pipe_0" => "{ba,open_rows[current_row],addr_col}"],
                                                 ),
                                                ],
                                   else      => ["read_cmd"  => "1'b0"],
                               }),
                               
                               e_if->new({
                                   comment   => " This is a write command",
                                   condition => "(cmd_code == 3'b100)",
                                   then      => [e_assign-> news
                                                 (["write_cmd" => "1'b1"],
                                                  #["wr_addr_pipe_0" => "{ba,open_rows[current_row],addr_col}"],
                                                  ),
                                                ],
                                   else      => ["write_cmd" => "1'b0"],
                               }),
                               
                               e_if->new({
                                   comment   => " This is an activate - store the chip/row/bank address in the same order as the DDR controller",
                                   condition => "(cmd_code == 3'b011)",
                                   then      => ["open_rows[current_row]" => "a"],
                               }),
                               
                               e_if->new({
                                   comment   => "Load mode register - set CAS latency, burst mode and length",
                                   condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                                   then      => 
                                    [
                                        e_assign->news
                                            (["burstmode" => "a[3]"],
                                             ["burstlength" => "a[2:0] << 1"],
                                             # ["wr_addr_pipe_0" => "0"], # otherwise if the first write is partial it breaks!
                                            ),
                                    
                                         e_if->new({
                                            comment    => "Decode CAS Latency from bits a[6..4]",
                                            condition  => "(a[6:4] == 3'b011)",
                                            then       => 
                                            [
                                                e_assign->news (["index" => "3'b010" ],)
                                            ],
                                            else       => 
                                            [
                                                 e_if->new({
                                                    comment    => "CAS Latency = 4.0 ",
                                                    condition  => "(a[6:4] == 3'b100)",
                                                    then       => 
                                                    [
                                                        e_assign->news
                                                        (["index" => "3'b011" ],)
                                                    ],
                                                    else =>
                                                    [
                                                        e_assign->news
                                                        (["index" => "3'b100" ],)
                                                    ],
                                                }),                                            
                                                ],
                                         }),
                                     ],   
                                           
                               }),
                               
                               
                               e_assign->news
                               (
                    
                    ["rd_addr_pipe_5"  => "rd_addr_pipe_4"],
                    ["rd_addr_pipe_4"  => "rd_addr_pipe_3"],
                    ["rd_addr_pipe_3"  => "rd_addr_pipe_2"],
                    ["rd_addr_pipe_2"  => "rd_addr_pipe_1"],
                    ["rd_addr_pipe_1"  => "rd_addr_pipe_0"],
    
                    ["rd_valid_pipe[5:1]" => "rd_valid_pipe[4:0]"],
                    ["rd_valid_pipe[0]" => "(cmd_code == 3'b101)"],
                    
                    ["wr_addr_pipe_5"  => "wr_addr_pipe_4"],
                    ["wr_addr_pipe_4"  => "wr_addr_pipe_3"],
                    ["wr_addr_pipe_3"  => "wr_addr_pipe_2"],
                    ["wr_addr_pipe_2"  => "wr_addr_pipe_1"],
                    ["wr_addr_pipe_1"  => "wr_addr_pipe_0"],
    
                    ["wr_valid_pipe[5:1]" => "wr_valid_pipe[4:0]"],
                    ["wr_valid_pipe[0]" => "(cmd_code == 3'b100)"],
                    
                    # ["write_valid_r"  => "write_valid"],
                    # ["write_valid_r2"  => "write_valid_r"],
                    ["wr_addr_delayed_r"  => "wr_addr_delayed"],
                               ),
                               ],
                           }),
                      ],
              }),
             );

       if ($local_burst_length > 1)
       {
           my $burstcounter_size = $local_burst_length / 2; # burst length count need to wrap within a burst length, so we need a suitable sized counter
        
        # Burst support - make the wr_addr keep counting 
        $module->add_contents
            (
             e_process->new
             ({
                 comment => " Burst support - make the wr_addr & rd_addr keep counting",
                 contents => 
                     [
                           e_if->new({ # WRITES
                               comment => " Reset write address otherwise if the first write is partial it breaks!",
                               condition => "(cmd_code == 3'b000 && ba == 2'b00)",
                               then      => 
                               [
                                    e_assign->news ( ["wr_addr_pipe_0" => "0"], 
                                                     ["wr_burst_counter" => "0"], ),
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
                                                 ["wr_burst_counter[".($read_addr_width-1).":".($burstcounter_size)."]" => "{ba,open_rows[current_row],addr_col[".($col_width-2).":".($burstcounter_size)."]}"],
                                                 ["wr_burst_counter[".($burstcounter_size-1).":0]" => "addr_col[".($burstcounter_size-1).":0] + 1"],
                                           ),
                                       ],
                                       else => 
                                       [
                                           e_if->new({
                                               # condition => "(write_cmd == 1'b1) || (write_to_ram == 1'b1)",
                                               condition => "(write_cmd || write_to_ram)",
                                               then      => 
                                               [
                                                   # e_assign-> news (["wr_addr_pipe_0" => "{ba,open_rows[current_row],addr_col}"],),
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
                                                 ["rd_addr_pipe_0"   => "{ba,open_rows[current_row],addr_col}"],
                                                 ["rd_burst_counter[".($read_addr_width-1).":".($burstcounter_size)."]" => "{ba,open_rows[current_row],addr_col[".($col_width-2).":".($burstcounter_size)."]}"],
                                                 ["rd_burst_counter[".($burstcounter_size-1).":0]" => "addr_col[".($burstcounter_size-1).":0] + 1"],
                                           ),
                                       ],
                                       else => 
                                       [
                                           e_if->new({
                                               condition => "(read_cmd || dq_valid || read_valid)",
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
       else {
            
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
       } # if local_burst_length > 1
             
             
        # Assign Outputs:
        # if ($mem_mask_width > 1) {
        #     for (0 .. ($mem_mask_width - 1)) {
        #         $module->add_contents
        #             (
        #              e_assign->new
        #              (
        #               ["read_temp[$lanes{$_}]" => "mask[$_] ? ".
        #                "8'bz : read_data[$lanes{$_}]"]
        #               ),
        #              );
        #     } # for mask-bits
        # } else {
        #     $module->add_contents
        #         (
        #          e_assign->new
        #          (
        #           ["read_temp" => "mask ? 8'bz : read_data"]
        #           ),
        #          );
        # }
        
     # process (clk)
      # begin
        # if clk'event and clk = '1' then
          # first_half_dq <= read_data(31 DOWNTO 16);
          # second_half_dq <= read_data(15 DOWNTO 0);
       # end if;
      # end process;
        
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
    
         #  dq <= A_WE_StdLogicVector((std_logic'(clk) = '0'), first_half_dq, second_half_dq);
         e_assign->new([read_dq => "clk  ? second_half_dq : first_half_dq"]),
         
          # ddr_dqs <= A_WE_StdLogicVector((std_logic'(dqs_valid) = '1'), A_REP(clk, 2), A_REP(std_logic'('Z'), 2));
          # ddr_dq <= A_WE_StdLogicVector((std_logic'(dq_valid) = '1'), read_dq, A_REP(std_logic'('Z'), 16));
          # e_assign->new([$dqs  => "dqs_valid ? {".$dqs_width."{clk}} : {".$dqs_width."{1'bz}}"]),
           #e_assign->new([$dq   => "dq_valid  ? read_dq : {".$dq_width."{1'bz}}"]),
         e_assign->new([dqs_temp   => "dqs_valid ? {".$dqs_width."{clk}} : {".$dqs_width."{1'bz}}"]),
         e_assign->new([dq_temp    => "dq_valid  ? read_dq : {".$dq_width."{1'bz}}"]),

         # model the board trace delay
           e_assign->new
           ({
               lhs => $dqs,
               rhs => "dqs_temp",
               sim_delay => $rtl_board_delay,
           }),
           e_assign->new
           ({ 
               lhs => $dq,
               rhs => "dq_temp",
               sim_delay => $rtl_board_delay,
           }),

         );

    $module->add_contents
    (        
         e_process->new
         ({
             comment => "Pipelining registers for burst counting",
             contents =>
             [
                e_assign->news 
                (
                    # ["write_valid"  => "write_cmd"],
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
         
         
    if ($local_burst_length == 4) 
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
             e_assign->new(["dq_valid" => "read_valid_r || read_valid_r2"]),
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
 
         # e_process->new
         # ({
             # comment => " ",
             # contents =>
             # [
                # e_assign->news 
            # (
                # ["dq_valid" => "read_valid"],
            # ),
             # ],
         # }), 
    
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
         
      # -- rising edge capture 
      # process (ddr_dqs(0))
      # begin
          # -- 
          # if rising_edge(ddr_dqs(0)) then 
            # dq_captured(7 DOWNTO 0) <= ddr_dq(7 DOWNTO 0);
            # dm_captured(0 DOWNTO 0) <= ddr_dm(0 DOWNTO 0);
          # end if;
      # end process;
    
         e_process->new
         ({
             comment => "capture first half of write data with rising edge of DQS, for simulation use only 1 DQS pin",
             clock   => $default_pin_prefix."dqs[0]",
             contents => 
             [
                e_assign->news
                (
                  ["dq_captured[".($dq_width-1).":0]" => $default_pin_prefix."dq[".($dq_width-1).":0]"],
                  ["dm_captured[".($dm_width-1).":0]" => $default_pin_prefix."dm[".($dm_width-1).":0]"],
                ),
             ]
         }),
    
      # -- falling edge capture 
      # process (ddr_dqs(0))
      # begin
          # -- 
          # if falling_edge(ddr_dqs(0)) then 
            # dq_captured(23 DOWNTO 16) <= ddr_dq(7 DOWNTO 0);
            # dm_captured(2 DOWNTO 2) <= ddr_dm(0 DOWNTO 0);
          # end if;
      # end process;
    
         e_process->new
         ({
             comment => "capture second half of write data with falling edge of DQS, for simulation use only 1 DQS pin",
             clock   => $default_pin_prefix."dqs[0]",
             clock_level => 0,
             contents => 
             [
                e_assign->news
                (
                  ["dq_captured[".($dq_width*2-1).":".($dq_width)."]" => $default_pin_prefix."dq[".($dq_width-1).":0]"],
                  ["dm_captured[".($dm_width*2-1).":".($dm_width)."]" => $default_pin_prefix."dm[".($dm_width-1).":0]"],
                ),
             ]
         }),
    
     );

         
    $module->add_contents
    (
       # there will always be at least DM[0]
        e_process->new
         ({
             comment => "Support for incomplete writes, do a read-modify-write with mem_bytes and the write data",
             contents => [ 
                e_if->new
                ({
                      # condition => "write_valid",
                      condition => "write_to_ram",
                      then => [e_assign->news (["rmw_temp[7:0]","dm_captured[0] ? mem_bytes[7 : 0] : dq_captured[7 : 0]"],),],
                }),
             ],
         }),
    );
    
    # now do the rest of DM pins
    if ($mem_mask_width > 1) {
        for (1 .. ($mem_mask_width-1)) 
        {
            $byte_lane = $_;
            $lanes{$byte_lane} = (($byte_lane*8)+7).":".($byte_lane*8);
            $module->add_contents
            (
                e_process->new
                 ({
                     contents => [ 
                        e_if->new
                        ({
                              # condition => "write_valid",
                              condition => "write_to_ram",
                              then => [e_assign->news (["rmw_temp[$lanes{$byte_lane}]" => "dm_captured[$byte_lane] ? "."mem_bytes[$lanes{$byte_lane}] : "."dq_captured[$lanes{$byte_lane}]"],),],
                        }),
                     ],
                 }),
            );
        } # for (0 to ($dm_width-1))
    } # if dm_width > 1
    
    # ["rmw_temp[15:8]","dm_captured[1] ? mem_bytes[15 : 8]   : dq_captured[15 : 8]"],
    # ["rmw_temp[23:16]","dm_captured[2] ? mem_bytes[23 : 16]   : dq_captured[23 : 16]"],
    # ["rmw_temp[31:24]","dm_captured[3] ? mem_bytes[31 : 24]   : dq_captured[31 : 24]"],

    $module->add_contents
    (
         # e_assign->new(["mem_bytes" => "(rmw_address == wr_addr_delayed) ? rmw_temp : read_data"]),
         e_assign->new(["mem_bytes" => "(rmw_address == wr_addr_delayed_r && write_to_ram_r) ? rmw_temp : read_data"]), # SPR 323567
         # e_assign->new(["rmw_address", "(write_valid) ? wr_addr_delayed : read_addr_delayed"]),
         e_assign->new(["rmw_address", "(write_to_ram) ? wr_addr_delayed : read_addr_delayed"]),

         e_signal->news
             (
              {name => "read_addr", width => $read_addr_width, never_export => 1},
              {name => "read_valid",width => 1,                never_export => 1},
              ),
    
             e_mux->new
             ({
                 comment=> "use index to select which pipeline stage drives addr",
                 type   => "selecto",
                 selecto=> "index",
                 lhs    => "read_addr_delayed",
                 table  => 
                 [
                      0 => "rd_addr_pipe_0",
                      1 => "rd_addr_pipe_1",
                      2 => "rd_addr_pipe_2",
                      3 => "rd_addr_pipe_3",
                      4 => "rd_addr_pipe_4",
                      5 => "rd_addr_pipe_5",
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
                      3 => "rd_valid_pipe[3]",
                      4 => "rd_valid_pipe[4]",
                      5 => "rd_valid_pipe[5]",
                      ],
             }),
    
             e_mux->new
             ({
                 comment=> "DDR2 has variable write latency too, so use index to select which pipeline stage drives valid",
                 type   => "selecto",
                 selecto=> "index",
                 lhs    => "write_valid",
                 table  => 
                     [
                      0 => "wr_valid_pipe[0]",
                      1 => "wr_valid_pipe[1]",
                      2 => "wr_valid_pipe[2]",
                      3 => "wr_valid_pipe[3]",
                      4 => "wr_valid_pipe[4]",
                      5 => "wr_valid_pipe[5]",
                      ],
             }),
             e_mux->new
             ({
                 comment=> "DDR2 has variable write latency too, so use index to select which pipeline stage drives addr",
                 type   => "selecto",
                 selecto=> "index",
                 lhs    => "wr_addr_delayed",
                 table  => 
                 [
                      0 => "wr_addr_pipe_0",
                      1 => "wr_addr_pipe_1",
                      2 => "wr_addr_pipe_2",
                      3 => "wr_addr_pipe_3",
                      4 => "wr_addr_pipe_4",
                      5 => "wr_addr_pipe_5",
                 ],
             }),         
    
    
             );
             
    
        print "# Finished creating memory model\n";
             
        # Produce some output.
        # print "\&make_sodimm: sim_model_base = $sim_model_base\n";
        # print "\&make_sodimm: about to generate output...\n";
        # $project->_verbose(1);
        $project->output();
    } else {
        print "# Skipping creation of memory model because do_generation = $do_generation\n";
        
    }
    
} # &make_sodimm

&make_ddr_sim_model(@ARGV);
