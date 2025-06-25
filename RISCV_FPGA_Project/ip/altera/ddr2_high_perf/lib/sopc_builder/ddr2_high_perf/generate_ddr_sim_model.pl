#Copyright (C)2007 Altera Corporation

# This script parses the system.ptf file, finds the DDR, DDR2 or DDR3 settings and generates a memory model to match.
# This script supports DDR, DDR2 or DDR3 SDRAM.


use europa_all;
####use strict;
use generate_ddr_model;

# Main DDR simulation model.
sub make_ddr_sim_model 
{
    # No arguments means "Ignore -- I'm being called from make".
    if (!@_)
    {
        return 0; # make_class_ptf();
    }
    
    # TEW: Get SDRAM's project, Options, etc:
    $project = e_project->new(@_);
    my %Options = %{$project->WSA()};
    my $WSA = \%Options;
    
    # Grab the module that was created during handle_args.
    $module = $project->top();

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
    
    # Should we generate a model at all?
    my $do_generation = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{do_build_sim};
    
    # Only generate model if "Simulation. Create simulator..." is ticked.
    if ($do_generation == 1) {
        print"# Creating memory simulation model for use with ".$project->_target_module_name()."\n";
        
        # We only accept .mif- and .srec-files (or just blankness)
        &ribbit ("Memory-initialization files must be either .mif or .srec.\n",
                 " not '$WSA->{Initfile}'\n")
            unless $WSA->{Initfile} =~ /\.(srec|mif)$/i;
        
    
            
        ## HDL language 
        ## ---------------------------------------
        # Figure out what language we're generating for
        $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
        my $extension;
        my $ipfs_model_ext;
        my $phy_ext;
        my $sim_file = $project->get_top_module_name();
        $sim_dat  = $project->_target_module_name() . ".dat";
        if ($lang =~ /vhd/i    ) { 
            $sim_file .= ".vhd";
            $extension = ".vhd";
            $ipfs_model_ext = ".vho";
            $phy_ext = ".vho";
        }
        if ($lang =~ /verilog/i) { 
            $sim_file .= ".v";
            $extension = ".v";
            $ipfs_model_ext = ".vo";
            $phy_ext = ".v";
        }
        
        # print "# Making a $lang model\n";
    
        
        ## Device family and necessary lib files
        ## --------------------------------------- 
        # Add datapath and other files to simulation list        
        
        # What does SOPCB think we're targeting?
        my $sopc_device_family = lc($project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{device_family_id});
        # What does DDR thing we're targeting?
        my $device_family = lc($project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{device_family});

        my $phy_type_is_afi = lc($project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{phy_if_type_afi});
        
        $DDRx =  lc($project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{ddrx});
        $NGv110 =  lc($project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{ngv110});
        
        # if ($sopc_device_family ne $device_family) { print "WARNING! The device selected in SOPC Builder (".$sopc_device_family.") does match the DDR SDRAM device (".$device_family.")\n";}
    
        my $wrapper_name = $project->_target_module_name();
        my $quartus_directory = $project->get_quartus_rootdir();
    
        # print "# Quartus came from ".$quartus_directory." and device family is $sopc_device_family\n";
        # print "# Wrapper file name is ".$wrapper_name.$extension."\n";
        
        
        
        # print "\n# Original files list = ".$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files}."\n";
        
        $project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files} = ""; # get rid of ddr_high_perf_black_box_module.v
        
        my $magic_proj_dir = "__PROJECT_DIRECTORY__/";
        my $datapath_files = "";
    
       if ($sopc_device_family eq "stratixiigxlite") {
           $sopc_device_family = "arriagx";   
       }
       
       if ($sopc_device_family eq "tarpon") {
           $sopc_device_family = "cycloneiiils";   
       }
       
       if ($sopc_device_family eq "stingray") {
           $sopc_device_family = "cycloneiv";   
       }
       
       # Simulation libraries required 
       if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/altera_primitives_components.vhd,"; }
       $datapath_files .= $quartus_directory."/eda/sim_lib/altera_primitives".$extension.",";  
       
       $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} = "$sopc_device_family".",";
       $datapath_files .= $quartus_directory."/eda/sim_lib/".$sopc_device_family."_atoms".$extension.",";  
       if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/".$sopc_device_family."_components.vhd,"; }

       ## Memory type
       ## ---------------------------------------
       # Work out whether this should be DDR, DDR2 or DDR3
       # my $memtype =  $wizard_shortcut->{PRIVATE}{gMEM_TYPE}{value};
       $memtype = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{memtype};
       # print "# This is a ".$memtype." controller\n";
       
       
       # Add PHY specific files for Cyclone III, Cyclone III LS, Cyclone IV
       if ($sopc_device_family eq "cycloneiii" || $sopc_device_family eq "cycloneiiils" || $sopc_device_family eq "cycloneiv" || $sopc_device_family eq "cycloneive") 
       { 
           # Also need Cyclone III libs for LS, Cyclone IV
           if ($sopc_device_family eq "cycloneiiils" || $sopc_device_family eq "cycloneiv" || $sopc_device_family eq "cycloneive") {
               $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "cycloneiii".",";
               $datapath_files .= $quartus_directory."/eda/sim_lib/cycloneiii_atoms".$extension.",";  
               if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/cycloneiii_components.vhd,"; }
           }
       }

       # Add PHY specific files for Stratix II, Stratix II GX, Arria GX
       if ($sopc_device_family eq "stratixii" || $sopc_device_family eq "stratixiigx" || $sopc_device_family eq "arriagx")   
       { 
           # Also need Stratix II and Arria GX libs for all these devices
           if ($sopc_device_family eq "stratixiigx" || $sopc_device_family eq "arriagx") {
               $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "stratixii".",";
               $datapath_files .= $quartus_directory."/eda/sim_lib/stratixii_atoms".$extension.",";  
               if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/stratixii_components.vhd,"; }
	       
	        $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "arriagx".",";
               $datapath_files .= $quartus_directory."/eda/sim_lib/arriagx_atoms".$extension.",";  
               if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/arriagx_components.vhd,"; }
           }
           
           # device specific phy files
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_reconfig".$extension.",";  # PLL reconfig (s2 only)
           
           # prepare simulation folder to copy mif file into
           #print $project->simulation_directory(), "\n";
           if (!(-e $project->simulation_directory())){
           mkdir $project->simulation_directory(), 0755 or warn "Cannot make simulation_directory: $!";
           }
           
           # copy mif file into simulation folder
           open(EI_IN, "< ".${wrapper_name}."_phy_alt_mem_phy_pll.mif") or warn "Couldn't open ".$wrapper_name."_phy_alt_mem_phy_pll.mif $!";
           open(EI_OUT, "> ".$project->simulation_directory()."/".${wrapper_name}."_phy_alt_mem_phy_pll.mif") or warn "Couldn't open ".$wrapper_name."_phy_alt_mem_phy_pll.mif $!";
           while ($_ = <EI_IN>) {
               print EI_OUT $_;
           };
       
       }
       
	   # Add PHY specific files for Stratix III and Stratix IV
       if ($sopc_device_family eq "stratixiii" || $sopc_device_family eq "stratixiv") 
       {
           # Also need Stratix III libs for Stratix IV
           if ($sopc_device_family eq "stratixiv") {
               $project->module_ptf()->{HDL_INFO}{Simulation_Library_Names} .= "stratixiii".",";
               $datapath_files .= $quartus_directory."/eda/sim_lib/stratixiii_atoms".$extension.",";  
               if ($lang =~ /vhd/i) {$datapath_files .= $quartus_directory."/eda/sim_lib/stratixiii_components.vhd,"; }
           }
           
           if ($lang =~ /vhd/i){
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_delay.vhd,";
           }
       }
       
       # Add PHY specific files for Arria II
       if ($sopc_device_family eq "arriaii") 
       {
           # device specific phy files
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_dq_dqs".$extension.",";
       }
	   
	   # Find out if ECC is enabled in order to rename the controller wrapper file
       my $ecc_enabled = "";
       if (exists($project->module_ptf()->{"SLAVE ecc_slave"})) 
       {
            $ecc_enabled = "_ecc"   
       }

       # Now add the files needed for all device families    
       if ($phy_type_is_afi eq "true"){
           if ($NGv110 eq "true"){
               if ($lang =~ /vhd/i ) {
                   $datapath_files .= $magic_proj_dir.$wrapper_name."_alt_mem_ddrx_controller_top.vho,";
               } else {
                   $datapath_files .= $magic_proj_dir.$wrapper_name."_alt_mem_ddrx_controller_top.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_addr_cmd.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_addr_cmd_wrap.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_controller.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_controller_st_top.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ddr2_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ddr3_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_lpddr2_addr_cmd.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_rdwr_data_tmg.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_arbiter.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_burst_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_cmd_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_csr.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_buffer.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_buffer_manager.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_burst_tracking.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_dataid_manager.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_fifo.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_list.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_rdata_path.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_wdata_path.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_define.iv,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_decoder.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_decoder_32_syn.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_decoder_64_syn.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_encoder.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_encoder_32_syn.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_encoder_64_syn.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_ecc_encoder_decoder_wrapper.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_input_if.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_mm_st_converter.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_rank_timer.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_sideband.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_tbp.v,";
                   $datapath_files .= $magic_proj_dir."alt_mem_ddrx_timing_param.v,";
               }
           } elsif ($DDRx eq "true"){
               if ($lang =~ /vhd/i ) {
                   $datapath_files .= $magic_proj_dir.$wrapper_name."_alt_ddrx_controller_wrapper.vho,";
               } else {
                   $datapath_files .= $magic_proj_dir.$wrapper_name."_alt_ddrx_controller_wrapper.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_controller.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_input_if.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_state_machine.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_addr_cmd.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_afi_block.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_ecc.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_csr.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_avalon_if.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_cmd_queue.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_wdata_fifo.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_ddr2_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_ddr3_odt_gen.v,";
                   $datapath_files .= $magic_proj_dir."altera_avalon_half_rate_bridge.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_decoder.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_decoder_40.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_decoder_72.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_encoder.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_encoder_40.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_encoder_72.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_clock_and_reset.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_cmd_gen.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_bank_timer_wrapper.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_bank_timer.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_bank_timer_info.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_bypass.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_cache.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_timing_param.v,";
                   $datapath_files .= $magic_proj_dir."alt_ddrx_rank_monitor.v,";
               }
           } else {
               if ($memtype eq "DDR3 SDRAM"){
	               $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr3_hp_controller".$ecc_enabled."_wrapper".$ipfs_model_ext.",";
               } else {
                   $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_hp_controller".$ecc_enabled."_wrapper".$ipfs_model_ext.",";
               }
           }
           $datapath_files .= $magic_proj_dir.$wrapper_name."_controller_phy".$extension.",";  # Controller + PHY wrapper 
           $datapath_files .= $magic_proj_dir.$wrapper_name.$extension.",";         # altmemddr.v
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_pll".$extension.",";
           if ($lang =~ /vhd/i    ) {
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy.vho,";
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_seq_wrapper.vho,";
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_seq.vhd,";
           }
           if ($lang =~ /verilog/i) {
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy.v,";
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy.v,";
               $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_seq_wrapper.vo,";
           }
       } else {
           $datapath_files .= $magic_proj_dir.$wrapper_name."_auk_ddr_hp_controller".$ecc_enabled."_wrapper".$ipfs_model_ext.",";      # Controller ipfs model  
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_sequencer_wrapper".$ipfs_model_ext.",";  # Sequencer ipfs model  
           $datapath_files .= $magic_proj_dir.$wrapper_name."_controller_phy".$extension.",";                           # Controller + PHY wrapper 
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy".$phy_ext.",";  # altmemddr_phy.v 
           $datapath_files .= $magic_proj_dir.$wrapper_name.$extension.",";         # altmemddr.v
           $datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy_pll".$extension.",";
           if ($lang =~ /verilog/i){$datapath_files .= $magic_proj_dir.$wrapper_name."_phy_alt_mem_phy".$extension.",";}
       }
       
       $project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files} = $datapath_files.$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files};
        
        
        
        # print "# Updated files list = ".$project->module_ptf()->{HDL_INFO}{Simulation_HDL_Files}."\n";
        # print "# Create libraries called = ".$project->module_ptf()->{HDL_INFO}{Simulation_Library_Names}."\n";
        
        
        # data_width_ratio = 4 for halfrate, 2 for full rate
        my $data_width_ratio = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{data_width_ratio};
        $local_burst_length =  $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{local_burst_length};
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
             "This testbench includes an SOPC Builder generated Altera memory model:",
             "'$sim_file', to simulate accesses to the $memtype memory.",
             " ",
             );
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
      
       
        
        # New style contents generation (a'la OnchipMemoryII -- thanks AaronF)
        # - added Data_Width to cope with the fact that DDR is narrower than Avalon (especially in halfrate).
        my $Opt = {
                name => $project->_target_module_name(),
                Data_Width => $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{datawidth} * 2,  
        };
        $project->do_makefile_target_ptf_assignments
            (
             's1',
             ['dat', 'sym', ],
             $Opt,
             );
        

        
        ## Clock frequency
        ## ---------------------------------------
        # Find out what the clock source of the module is        
        my $clock_source = $project->module_ptf()->{"SLAVE s1"}{SYSTEM_BUILDER_INFO}{Clock_Source};
        # print "# Clock_source = $clock_source\n";

        my $clockfreq = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{CLOCKS}{"CLOCK $clock_source"}{frequency}; 
         # print "# SOPCB clock rate is $clockfreq\n";  # returns MHz
        $clockperiod = floor(1/$clockfreq * 1e9); # convert to ns
         # print "# SOPCB clock period of $clock_source is $clockperiod ns\n";
        
        # my $mem_clockperiod = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{clockspeed}; 
        # knowing the ddr clock rate and the data_width_ratio, derive the supposed local clock rate
        # my $local_clockperiod = $mem_clockperiod * $data_width_ratio / 2;
        # print "# DDR thinks the local clock period is $local_clockperiod ps\n";
        
        
   
        ## Cas latency
        ## ---------------------------------------
        my $cas_latency = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{cas_latency};
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
        $prefix = "mem_";

        ## Data and address widths
        ## ---------------------------------------
        
        # Work ou the number of chip selects
        $num_chipselects = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{num_chipselects};
        $num_chipselect_address_bits = log2($num_chipselects);

        # Compute the width of the controller's address (as seen by the Avalon
        # bus) from input parameters.  
        $addr_width =  $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{addr_width};
        $ba_width   =  $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{ba_width};
        $row_width  =  $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{row_width};
        $col_width  =  $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{col_width};
        
        $dq_width  = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{datawidth};
        $gMEM_DQ_PER_DQS = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{dq_per_dqs};
        $dqs_width = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{datawidth} / $gMEM_DQ_PER_DQS;
        $dm_width  = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{datawidth} / $gMEM_DQ_PER_DQS;
        
        $mem_width = $dq_width * 2;
        $mem_mask_width = $dm_width * 2;
        
        $gREG_DIMM = $project->module_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{reg_dimm};
	
        &gen_ddr_model();
    } else {
        
        # print "Not making a model because generate_sim is off... \n";
    }
        
} # &make_sodimm

&make_ddr_sim_model(@ARGV);
