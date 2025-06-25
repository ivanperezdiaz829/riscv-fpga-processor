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





















  
  
  use strict;
  use europa_all;
  


  

  if (!@ARGV) {
    exit 1;
  }
  
  my $script_mode = 0;
  my $loopback_test_mode = 0;
  my @europa_args;
  my $clock_source = "";
  
  my $wizard_cmd_line=2; # 1 for mega_altclklock, 2 for qmegawiz
  



  foreach my $argv (@ARGV) {
    my @nvp = split("=", $argv);
    
    if ($nvp[0] eq "--script_mode") {
      if ($nvp[1] == 1) {
        $script_mode = 1;
        print "\nEntering script mode... \n";
      }
    }
    elsif ($nvp[0] eq "--test_mode"){
      if ($nvp[1] == 1) {
        $loopback_test_mode = 1;
      }
    }
    


    elsif ($nvp[0] eq "--clock_source"){
      if($nvp[1]=~/^[A-Za-z]\w*$/){
        $clock_source=$nvp[1];
      }
    }

    else {
      push (@europa_args, "$argv");
    }
  }
  


  



 	my $project = e_project->new(@europa_args);
    my %Options = %{$project->WSA()};
    my $WSA = \%Options;
	    

    my $module = $project->top();
    my $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};

    my $module_name = $module->{"name"};
    my $system_directory = $project->{"__system_directory"};
    


  my $file_ext = ($lang =~ /verilog/i) ? "v"
        : ($lang =~ /vhdl/i) ? "vhd"
      : die "\nError in ptf file : hdl_language unrecognized.";
  

  my $module_file_name = $system_directory."/altpll".$module_name.".".$file_ext;
  my $cnx_file_name = $system_directory."/altpll".$module_name.".cnx";
  my $cnx_backup_file_name = $system_directory."/altpll".$module_name.".cnxbak";
  


  if ($loopback_test_mode == 1 ) {
    
    unless (-e $cnx_file_name) {
      die "\nTemplate CNX file does not exist, could not execute loopback test.";
    }
    

    &regenerate_cnx($module_file_name); 
    

    my $cnx_copy_file_name = &make_cnx_copy($cnx_file_name, $system_directory);
    


    &do_altpll_processing($project, $system_directory, $module_name, $loopback_test_mode);
    

    if (&compare_cnx_files($cnx_file_name, $cnx_copy_file_name, $system_directory)) {
      print "\nLoopback test : OK!!!";
    }
    else {
      print "\nLoopback test : FAILED!!!";
    }
    

    exit();
  }
  



  exit unless (&do_run_altpll($project, $module_file_name, $module_name, $clock_source, $lang));


  &do_altpll_processing($project, $system_directory, $module_name, $loopback_test_mode);
    

  unlink("$cnx_file_name");
  
  &do_housekeeping;
  

  print "Em_pll_configuration Done.\n";
    
  sub do_housekeeping
  {

    my $all_modules = $project->system_ptf();
  
    opendir PROJDIR, $system_directory;
    foreach my $file (readdir PROJDIR)
    {
      next if $file =~ /^\./;
      
      if ($file =~ m/^altpll(.*).v$/)
      {
        my $module_name_from_file = $1;
        $file = "$system_directory/$file";
        
        unlink ($file) unless
          defined($project->system_ptf()->{"MODULE $module_name_from_file"})
          and -f $file and -r $file; # only readable files
      }      
    }
  }
    

  sub do_run_altpll
  {
    my $project = shift;
    my $module_file_name = shift;
    my $module_name = shift;
    my $clock_source = shift;
    my $lang = shift;
 
    my $module_ptf = $project->system_ptf()->{"MODULE $module_name"};
    my $WSA = $module_ptf->{"WIZARD_SCRIPT_ARGUMENTS"};
    my $cnx_info = $WSA->{"CNX_INFO"};


    my $mod_clk_source = $module_ptf->{"SYSTEM_BUILDER_INFO"}->{"Clock_Source"};
    
    if($clock_source ne ""){


      $mod_clk_source = $clock_source;
    }

    my $sys_clk_freq = $project->get_clock_frequency($mod_clk_source);
    
    my $device_family = get_device_family();
    my %system_properties = (
    	"sys_clk_freq" => $sys_clk_freq,
    	"device_family" => $device_family,
    );
    
    if($wizard_cmd_line == 1){


      if (! -e $cnx_file_name) {
        if ($cnx_info ne "") {
          &create_cnx_from_ptf($WSA->{"CNX_INFO"}, $sys_clk_freq);
        }else{
          &create_default_cnx($module_name, $cnx_file_name, %system_properties);
        }
      } else {




        &edit_generated_cnx($module_name, $cnx_file_name, %system_properties);
      }
    } elsif($wizard_cmd_line == 2){


      if (! -e $module_file_name) {
        if ($cnx_info ne "") {
          &create_hdl_from_ptf($WSA->{"CNX_INFO"}, $WSA->{"ALTPLL_PORTS"}, $sys_clk_freq);
        }else{
          &create_default_hdl($module_name, $module_file_name, %system_properties);
        }
      }else{
        &edit_generated_hdl($module_name, $module_file_name, $lang, %system_properties);
      }
     }else{
    	print "unknown wizard_cmd_line\n";
    	exit 1;
     }
    


    

    if ($script_mode == 0) {

      
        my $open_ui_cmd;
		if($wizard_cmd_line == 1){
          $open_ui_cmd = "mega_altclklock -wizard_name:ALTPLL %f ".$module_file_name;
        }
        elsif($wizard_cmd_line == 2){
          $open_ui_cmd = "qmegawiz ".$module_file_name;
		}
		else{
			print "unknown wizard_cmd_line\n";
       		exit 1;
    	}
    	my $system_rc=system($open_ui_cmd);
    
        if($system_rc != 0){
                print "wizard exit with error: rc=$system_rc\n";
            exit $system_rc;
        }


    	if($wizard_cmd_line == 1){
			unless (-e $cnx_file_name){
       			return 0;
	    	}
    	}
    	elsif($wizard_cmd_line == 2){
          unless (-e $module_file_name){
            return 0;
	  }
	}else{
          return 1;
        }
      }
    
    
    1;
  }
  

  
  





  sub do_altpll_processing
  {
    (my $project, my $proj_dir, my $module_name, my $loopback_test_mode)=@_;


    my $module_ptf = $project->system_ptf()->{"MODULE $module_name"};

    
    my $WSA = $module_ptf->{"WIZARD_SCRIPT_ARGUMENTS"};
    my $module_port_wiring;
    my $SLAVE_PORT_WIRING =$module_ptf->{"SLAVE s1"}->{PORT_WIRING};
    my @cnx_arrays;

            


      if($wizard_cmd_line == 1){
		open(CNX_INPUT_FILE, "< $cnx_file_name") or die "Error opening CNX file $cnx_file_name\n";
        @cnx_arrays = <CNX_INPUT_FILE>;
	  }
	  elsif(($wizard_cmd_line == 2)||($script_mode == 1)){
      	open(HDL_INPUT_FILE, "< $module_file_name") or die "Error opening HDL file $module_file_name\n";
        my @hdl_array = <HDL_INPUT_FILE>;
            
        my $CNX_found = 0;
        foreach (@hdl_array){
        	if(/CNX file retrieval info/){
          		$CNX_found = 1;
           		next;
           	}
           	if($CNX_found==1){
	           	s/^[\/-]* Retrieval info\:\s+//; # HDL uses -- as comment
    	       	push @cnx_arrays, $_;
           	}
		}
            
      }
      else{
		print "unknown CNX info\n";
        exit 1;
      }

      my $cnx_data_hash = &parse_cnx_info($SLAVE_PORT_WIRING, $module_name, @cnx_arrays);
      my $cnx_clockinfo = $cnx_data_hash->{"CLOCK_INFO"};
      my $cnx_clocksource = $cnx_data_hash->{"CLOCK_SOURCES"};
    


    &transverse_clk_source_hash($cnx_data_hash, $SLAVE_PORT_WIRING, $module_name);
    
    $module_port_wiring = &transverse_altpll_ports($cnx_data_hash->{"ALTPLL_PORTS"}, $module_name, $module_port_wiring);
    

    if ($module_port_wiring eq "") {

    }
    else {
    	$module_ptf->{"PORT_WIRING"} = $module_port_wiring;
    }
    

    $WSA->{"CLOCK_SOURCES"} = $cnx_clocksource;
    $WSA->{"CLOCK_INFO"} = $cnx_clockinfo;
    


    $WSA->{"ALTPLL_PORTS"}= $cnx_data_hash->{"ALTPLL_PORTS"};
        

    my $altpll_ports = $cnx_data_hash->{"ALTPLL_PORTS"};
    my $ui_control = $WSA->{"UI_CONTROL"};
    my @default_port_list = qw(areset pllena pfdena locked);
    
    foreach my $default_port (@default_port_list) {
      if ($altpll_ports->{"PORT $default_port"}) {
        $ui_control->{"${default_port}_port_exist"} = "1";
      }
      else {
        $ui_control->{"${default_port}_port_exist"} = "0";
      }
    }

    $WSA->{"UI_CONTROL"} = $ui_control;
    
    

    $WSA->{"CNX_INFO"} = $cnx_data_hash->{"CNX_INFO"};
    

    $WSA->{"Config_Done"} = "1";
    
    my $ptf_hash = &copy_of_hash ($project->system_ptf());
    

    $project->ptf_to_file();
    
    if ($loopback_test_mode == 1) {

      print "\nLoopback test mode : creating CNX from PTF";
      &create_cnx_from_ptf($WSA->{"CNX_INFO"});
    }
  }
  
  sub get_device_family
  {
    my $device_family_ptf = $project->system_ptf()->{"WIZARD_SCRIPT_ARGUMENTS"}->{"device_family_id"};
    my $device_family = do_device_family_name_mapping($device_family_ptf);
    
    return $device_family;
  }
  
  sub get_clock_constant {
    my $searchstring = shift;
    my $clktype = shift;
    my $pll_clock_info;
    

    my @clock_data = split ($clktype, $searchstring);
    

    my @info_of_interest = split (" ", $clock_data[1]);
    

    if ($info_of_interest[0] =~ m/(\d+)_(.+)/) {
      $pll_clock_info->{"clk_index"} = $1;
      $pll_clock_info->{"field"} = $2;
      


      if ($clktype =~ m/INCLK/) {
        $pll_clock_info->{"field"} = "clock_freq";
      }
      
    }
    else {
      print "Error in processing : $searchstring\n";
    }
    

    my @clock_field_value = split ("\"", $info_of_interest[2]);
    $pll_clock_info->{"value"} = $clock_field_value[1];
    

    if ($clktype =~ m/INCLK/) {

      unless ($clock_field_value[1] == 0 ) {




        $pll_clock_info->{"value"} = convert_cnx_period_to_freq ($clock_field_value[1]);
      }
    }
    
    return $pll_clock_info;
  }
    
  sub parse_cnx_info
  {
    my ($SLAVE_PORT_WIRING, $module_name, @cnx_arrays) = @_;

    my $FREQ_EDIT = "";



    
    my $cnx_data = {};
    $cnx_data->{"CLOCK_INFO"}->{"RECONFIG_ENABLED"} = 0;
    $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_OUTPUT_CLOCKS"} = 0;
    $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_INPUT_CLOCKS"} = 0;
    
    my $gen_file_count = 0;
    
    my $inclk_found = 0; # to check for any inclk. qmegawiz will not create CONSTANT inclk if cancel
    my $clock_info_for_advanced = {};
    


    foreach (@cnx_arrays)
    {
      chomp;
      if(/PRIVATE/)
      {


        


        my @splitvalue = split ("\"", $_);
        my @private_data = split (" ", $splitvalue[0]);


        $cnx_data->{"CNX_INFO"}->{"PRIVATE"}->{$private_data[2]}->{$private_data[1]} = $splitvalue[1];

      }
      elsif (/LIBRARY/) {
        m/(LIBRARY).*:\s(.*)/;
        $cnx_data->{"CNX_INFO"}->{$1}= $2;
      }
      elsif(/CONSTANT/)
      {

        if (/\s+CLK[0-9]/) {
          my $pll_clock_info =  &get_clock_constant($_, "CLK");
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK c".$pll_clock_info->{"clk_index"}}->{"clk_index"} = $pll_clock_info->{"clk_index"};
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK c".$pll_clock_info->{"clk_index"}}->{$pll_clock_info->{"field"}} = $pll_clock_info->{"value"};
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK c".$pll_clock_info->{"clk_index"}}->{"type"} = "out_clk";


          
        }

        elsif (/\s+EXTCLK[0-3]/) {
          my $pll_clock_info =  &get_clock_constant($_, "EXTCLK");
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK e".$pll_clock_info->{"clk_index"}}->{"clk_index"} = $pll_clock_info->{"clk_index"} + 6;
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK e".$pll_clock_info->{"clk_index"}}->{$pll_clock_info->{"field"}} = $pll_clock_info->{"value"};
          $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK e".$pll_clock_info->{"clk_index"}}->{"type"} = "out_clk";


          
        }

        elsif (/\s+INCLK[0-1]/) {
          my $pll_clock_info =  &get_clock_constant($_, "INCLK");
          $cnx_data->{"CLOCK_INFO"}->{"CLOCK inclk".$pll_clock_info->{"clk_index"}}->{$pll_clock_info->{"field"}} = $pll_clock_info->{"value"};
          $cnx_data->{"CLOCK_INFO"}->{"CLOCK inclk".$pll_clock_info->{"clk_index"}}->{"type"} = "in_clk";
          $cnx_data->{"CLOCK_INFO"}->{"CLOCK inclk".$pll_clock_info->{"clk_index"}}->{"clock_unit"} = "MHz";  # Evilll!!
          $inclk_found = 1;


        }
        


        my @splitvalue = split ("\"", $_);
        my @constant_data = split (" ", $splitvalue[0]);


        $cnx_data->{"CNX_INFO"}->{"CONSTANT"}->{$constant_data[2]}->{$constant_data[1]} = $splitvalue[1];
      }
      elsif(/USED_PORT/)
      {


        
        if(!/@/)
        {
          my @p_names = split("\"", $_);
          $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"direction"} = /OUTPUT/ ? "output" : "input";
          $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"width"} = "1";
          $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"Is_Enabled"} = "1";
          
      

          if ($p_names[1] =~ m/_ena/) {
            $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"type"} = "clken";
          }
          
          

          my $port_info = $cnx_data->{"CLOCK_SOURCES"}->{"CLOCK ".$p_names[1]};
          

          if($port_info->{"type"} eq "out_clk")
          {
            my $cindex = $port_info->{"clk_index"};
            $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_OUTPUT_CLOCKS"}++;
            $cnx_data->{"CLOCK_INFO"}->{"USED_OUTPUT_CLOCKS"}->{"INDEX_".$cindex} = $cindex;

            $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"type"} = $port_info->{"type"};
          }
          
          $port_info = $cnx_data->{"CLOCK_INFO"}->{"CLOCK ".$p_names[1]};
          if($port_info->{"type"} eq "in_clk")
          {
            $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_INPUT_CLOCKS"}++;

            $cnx_data->{"ALTPLL_PORTS"}->{"PORT ".$p_names[1]}->{"type"} = $port_info->{"type"};
          }
          

          if($p_names[1]=~/scan/)
          {
            $cnx_data->{"CLOCK_INFO"}->{"RECONFIG_ENABLED"} = 1;
          } 

          if(m/.*USED_PORT:\s([ce]\d+)\s(.*)\s\".*\"/)
          {
            my $port_name = $1;
            my $port_settings = $2;
            my @values = split(" ",$port_settings);
            

            my $value_index=0;
            foreach (@values)
            {
              $cnx_data->{"CNX_INFO"}->{"USED_PORT"}->{$port_name}->{"VALUE_".$value_index} = $_;
              $value_index = $value_index + 1;
            }
          }
        }
      }
      elsif(/GEN_FILE/)
      {
        my @gen_file_data = split (" ", $_);
        

        my $gen_file_info;
        if ($gen_file_data[2] =~ m/^(altpll$module_name)(.*)$/i) {
              $gen_file_info = $2;
        }
        
        $cnx_data->{"CNX_INFO"}->{"GEN_FILE"}->{$gen_file_data[1]}->{"$gen_file_data[3]"}->{"name$gen_file_count"}= $gen_file_info;
        



        
        $gen_file_count++;
      }
    }
    


    exit unless $inclk_found;



    my $clock_infos = $cnx_data->{"CLOCK_INFO"};
    my $no_inclk_found = 1;
    foreach my $clock_info (keys %$clock_infos)
    {
      if($clock_info =~ /^CLOCK /)
      {
        $no_inclk_found = 0;
        my @inclkn = split ' ',$clock_info;
        my $freq_unit = $cnx_data->{"CNX_INFO"}->{"PRIVATE"}->{"STRING"}->{uc $inclkn[1]."_FREQ_UNIT_COMBO"};
        if ( $freq_unit eq "MHz" )
        {
          $cnx_data->{"CLOCK_INFO"}->{"CLOCK ".$inclkn[1]}->{"clock_freq"}
                    = get_frequency_from_cnx_private_in_Hz($cnx_data,$inclkn[1]);
        }
      }
    }

    return $cnx_data;
      
  }
  
  sub get_frequency_from_cnx_private_in_Hz
  {
    my $cnx_data = shift;
    my $inclkn = shift;
    my $frequency_in_MHz =  $cnx_data->{"CNX_INFO"}->{"PRIVATE"}->{"STRING"}->{uc $inclkn."_FREQ_EDIT"};
    my $frequency_in_Hz = $frequency_in_MHz * 1e6;
    return $frequency_in_Hz;
  }
  

  sub create_default_hdl
  {
    (my $module_name, my $module_file_name, my %system_properties) = @_;




    my $hdl_buffer_to_write = &generate_default_hdl($module_name, $module_file_name, %system_properties);
    my $cnx_buffer_to_write = &generate_default_cnx($module_name, $module_file_name, %system_properties);
    
    my @cnx_buffer_to_write = split /\n/, $cnx_buffer_to_write;
          
      open(DEFAULT_MODULE, ">$module_file_name") or die "Unable to open file $module_file_name for writing $!\n";
      print DEFAULT_MODULE $hdl_buffer_to_write;
      foreach my $line (@cnx_buffer_to_write){
        print DEFAULT_MODULE "// Retrieval info: $line \n";
      }
      close(DEFAULT_MODULE);
  }
  

  sub create_default_cnx
  {
    (my $module_name, my $cnx_file_name, my %system_properties) = @_;

    

    my $cnx_buffer_to_write = &generate_default_cnx($module_name, $cnx_file_name, %system_properties);
      
      open(DEFAULT_CNX, ">$cnx_file_name") or die "Unable to open file $cnx_file_name for writing $!\n";
      print DEFAULT_CNX <<"END_OF_CNX_HEADER";
GENERATION: STANDARD
VERSION: WM1.0
MODULE: altpll 

END_OF_CNX_HEADER
      
      print DEFAULT_CNX $cnx_buffer_to_write;
      close(DEFAULT_CNX);
  }
  






sub edit_generated_cnx {
	( my $module_name, my $module_file_name, my %system_properties ) = @_;

	my $sys_clk_freq  = $system_properties{sys_clk_freq};
	my $device_family = $system_properties{device_family};

	( my $sys_clk_period, my $sys_clk_freq_in_mhz ) =
	  do_calculate_freq_and_period($sys_clk_freq);

    my @edited_module_file_buffer;
    open(MODULE_FILE,"$module_file_name");
    while(<MODULE_FILE>){
	if(/PRIVATE: INCLK0_FREQ_EDIT STRING/){
	    	my $newline = << "END_OF_LINE";
PRIVATE: INCLK0_FREQ_EDIT STRING "$sys_clk_freq_in_mhz"
END_OF_LINE
			push @edited_module_file_buffer, $newline;
        }elsif(/PRIVATE: INCLK0_FREQ_UNIT_COMBO/){
	    	my $newline = << "END_OF_LINE";
PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
END_OF_LINE
			push @edited_module_file_buffer, $newline;
        }elsif(/PRIVATE: DEV_FAMILY STRING/){
	    	my $newline = << "END_OF_LINE";
PRIVATE: DEV_FAMILY STRING "$device_family"
END_OF_LINE
			push @edited_module_file_buffer, $newline;
        }elsif(/CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC/){







        }elsif(/CONSTANT: INTENDED_DEVICE_FAMILY STRING/){
	    	my $newline = << "END_OF_LINE";
CONSTANT: INTENDED_DEVICE_FAMILY STRING "$device_family"
END_OF_LINE
			push @edited_module_file_buffer, $newline;
        }else{
        	push @edited_module_file_buffer,$_;
        }
    }
    close(MODULE_FILE);
	
	open( EDITED_CNX, ">$module_file_name" )
	  or die "Unable to open file $module_file_name for writing $!\n";
	print EDITED_CNX @edited_module_file_buffer;
	close(EDITED_CNX);
}    

sub edit_generated_hdl {
	( my $module_name, my $module_file_name, my $lang, my %system_properties ) = @_;

	my $sys_clk_freq  = $system_properties{sys_clk_freq};
	my $device_family = $system_properties{device_family};

	( my $sys_clk_period, my $sys_clk_freq_in_mhz ) =
	  do_calculate_freq_and_period($sys_clk_freq);

    my @edited_module_file_buffer;
    open(MODULE_FILE,"$module_file_name");
    while(<MODULE_FILE>){
	    if(/PRIVATE: INCLK0_FREQ_EDIT STRING/){
              my $newline;
              if ($lang =~ /verilog/) {
	    	$newline = << "END_OF_LINE";
// Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING "$sys_clk_freq_in_mhz"
END_OF_LINE
              } else {
	    	$newline = << "END_OF_LINE";
-- Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING "$sys_clk_freq_in_mhz"
END_OF_LINE
              } 
			push @edited_module_file_buffer, $newline;
        }elsif(/PRIVATE: INCLK0_FREQ_UNIT_COMBO/){
              my $newline;
              if ($lang =~ /verilog/) {
	    	$newline = << "END_OF_LINE";
// Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
END_OF_LINE
              } else {
	    	$newline = << "END_OF_LINE";
-- Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
END_OF_LINE
              }
			push @edited_module_file_buffer, $newline;
        }elsif(/PRIVATE: DEV_FAMILY STRING/){
              my $newline;
              if ($lang =~ /verilog/) {
	    	$newline = << "END_OF_LINE";
// Retrieval info: PRIVATE: DEV_FAMILY STRING "$device_family"
END_OF_LINE
              } else {
	    	$newline = << "END_OF_LINE";
-- Retrieval info: PRIVATE: DEV_FAMILY STRING "$device_family"
END_OF_LINE
              }
			push @edited_module_file_buffer, $newline;
        }elsif(/CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC/){







        }elsif(/CONSTANT: INTENDED_DEVICE_FAMILY STRING/){
              my $newline;
              if ($lang =~ /verilog/) {
	    	$newline = << "END_OF_LINE";
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "$device_family"
END_OF_LINE
              } else {
	    	$newline = << "END_OF_LINE";
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "$device_family"
END_OF_LINE
              }
			push @edited_module_file_buffer, $newline;
        }else{
        	push @edited_module_file_buffer,$_;
        }
    }
    close(MODULE_FILE);
	
	open( EDITED_CNX, ">$module_file_name" )
	  or die "Unable to open file $module_file_name for writing $!\n";
	print EDITED_CNX @edited_module_file_buffer;
	close(EDITED_CNX);
}






  sub do_calculate_freq_and_period
  {
    my $sys_clk_freq = shift;
    


    my $sys_clk_period = 10000;
    my $sys_clk_freq_in_mhz = $sys_clk_freq / (1e6);
    unless ($sys_clk_freq == 0) {
      $sys_clk_period = (1e12)/$sys_clk_freq;
    }



    $sys_clk_freq_in_mhz =~ s/([0-9]*.[0-9]{3})(.*)/\1/;
    
    return ($sys_clk_period, $sys_clk_freq_in_mhz);
  } 





  sub do_device_family_name_mapping
  {
  	my $device_name = @_[0];
  	
		my %translate_device_name = (
			"CYCLONE" => "Cyclone",
			"CYCLONEII" => "Cyclone II",
			"CYCLONEIII" => "Cyclone III",
			"STRATIX" => "Stratix",
			"STRATIXGX" => "Stratix GX",
			"STRATIXII" => "Stratix II",
			"STRATIXIII" => "Stratix III",
			"STRATIXIIGX" => "Stratix II GX",
			"STRATIXIV" => "Stratix IV",
			"ARRIAGX" => "Arria GX",
			"ARRIAII" => "Arria II",
			"TARPON" => "Tarpon",
		);
		
		my $tr_device_name = $translate_device_name{$device_name};
		
		if($tr_device_name ne ""){
			return $tr_device_name;
		}else{
			return $device_name;
		}
  } 








  sub generate_default_cnx
  {
  	(my $module_name, my $module_file_name, my %system_properties) = @_;

    my $sys_clk_freq = $system_properties{sys_clk_freq};
 		my $device_family = $system_properties{device_family};

    (my $sys_clk_period, my $sys_clk_freq_in_mhz) = do_calculate_freq_and_period($sys_clk_freq);
    
    my $default_cnx_buffer = <<"END_OF_CNX";
PRIVATE: MIRROR_CLK0 STRING "0"
PRIVATE: PHASE_SHIFT_UNIT0 STRING "deg"
PRIVATE: OUTPUT_FREQ_UNIT0 STRING "MHz"
PRIVATE: INCLK1_FREQ_UNIT_COMBO STRING "MHz"
PRIVATE: SPREAD_USE STRING "0"
PRIVATE: SPREAD_FEATURE_ENABLED STRING "1"
PRIVATE: GLOCKED_COUNTER_EDIT_CHANGED STRING "1"
PRIVATE: GLOCK_COUNTER_EDIT NUMERIC "1048575"
PRIVATE: SRC_SYNCH_COMP_RADIO STRING "0"
PRIVATE: DUTY_CYCLE0 STRING "50.00000000"
PRIVATE: PHASE_SHIFT0 STRING "0.00000000"
PRIVATE: MULT_FACTOR0 NUMERIC "1"
PRIVATE: OUTPUT_FREQ_MODE0 STRING "0"
PRIVATE: SPREAD_PERCENT STRING "0.500"
PRIVATE: LOCKED_OUTPUT_CHECK STRING "0"
PRIVATE: PLL_ARESET_CHECK STRING "0"
PRIVATE: STICKY_CLK0 STRING "1"
PRIVATE: BANDWIDTH STRING "1.000"
PRIVATE: BANDWIDTH_USE_CUSTOM STRING "0"
PRIVATE: DEVICE_SPEED_GRADE STRING "Any"
PRIVATE: SPREAD_FREQ STRING "50.000"
PRIVATE: BANDWIDTH_FEATURE_ENABLED STRING "1"
PRIVATE: LONG_SCAN_RADIO STRING "1"
PRIVATE: PLL_ENHPLL_CHECK NUMERIC "0"
PRIVATE: LVDS_MODE_DATA_RATE_DIRTY NUMERIC "0"
PRIVATE: USE_CLK0 STRING "1"
PRIVATE: INCLK1_FREQ_EDIT_CHANGED STRING "1"
PRIVATE: SCAN_FEATURE_ENABLED STRING "1"
PRIVATE: ZERO_DELAY_RADIO STRING "0"
PRIVATE: PLL_PFDENA_CHECK STRING "0"
PRIVATE: CREATE_CLKBAD_CHECK STRING "0"
PRIVATE: INCLK1_FREQ_EDIT STRING "100.000"
PRIVATE: CUR_DEDICATED_CLK STRING "c0"
PRIVATE: PLL_FASTPLL_CHECK NUMERIC "0"
PRIVATE: ACTIVECLK_CHECK STRING "0"
PRIVATE: BANDWIDTH_FREQ_UNIT STRING "MHz"
PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING "MHz"
PRIVATE: GLOCKED_MODE_CHECK STRING "0"
PRIVATE: NORMAL_MODE_RADIO STRING "1"
PRIVATE: CUR_FBIN_CLK STRING "e0"
PRIVATE: DIV_FACTOR0 NUMERIC "1"
PRIVATE: INCLK1_FREQ_UNIT_CHANGED STRING "1"
PRIVATE: HAS_MANUAL_SWITCHOVER STRING "1"
PRIVATE: EXT_FEEDBACK_RADIO STRING "0"
PRIVATE: PLL_AUTOPLL_CHECK NUMERIC "1"
PRIVATE: CLKLOSS_CHECK STRING "0"
PRIVATE: BANDWIDTH_USE_AUTO STRING "1"
PRIVATE: SHORT_SCAN_RADIO STRING "0"
PRIVATE: LVDS_MODE_DATA_RATE STRING "300.000"
PRIVATE: CLKSWITCH_CHECK STRING "0"
PRIVATE: SPREAD_FREQ_UNIT STRING "KHz"
PRIVATE: PLL_ENA_CHECK STRING "0"
PRIVATE: INCLK0_FREQ_EDIT STRING "$sys_clk_freq_in_mhz"
PRIVATE: CNX_NO_COMPENSATE_RADIO STRING "0"
PRIVATE: INT_FEEDBACK__MODE_RADIO STRING "1"
PRIVATE: OUTPUT_FREQ0 STRING "100.000"
PRIVATE: PRIMARY_CLK_COMBO STRING "inclk0"
PRIVATE: CREATE_INCLK1_CHECK STRING "0"
PRIVATE: SACN_INPUTS_CHECK STRING "0"
PRIVATE: DEV_FAMILY STRING "$device_family"
PRIVATE: LOCK_LOSS_SWITCHOVER_CHECK STRING "0"
PRIVATE: SWITCHOVER_COUNT_EDIT NUMERIC "1"
PRIVATE: SWITCHOVER_FEATURE_ENABLED STRING "1"
PRIVATE: BANDWIDTH_PRESET STRING "Low"
PRIVATE: GLOCKED_FEATURE_ENABLED STRING "0"
PRIVATE: USE_CLKENA0 STRING "0"
PRIVATE: LVDS_PHASE_SHIFT_UNIT0 STRING "deg"
PRIVATE: CLKBAD_SWITCHOVER_CHECK STRING "0"
PRIVATE: BANDWIDTH_USE_PRESET STRING "0"
PRIVATE: PLL_LVDS_PLL_CHECK NUMERIC "0"
PRIVATE: DEVICE_FAMILY NUMERIC "9"
LIBRARY: altera_mf altera_mf.altera_mf_components.all
CONSTANT: BANDWIDTH_TYPE STRING "AUTO"
CONSTANT: CLK0_DUTY_CYCLE NUMERIC "50"
CONSTANT: LPM_TYPE STRING "altpll"
CONSTANT: CLK0_MULTIPLY_BY NUMERIC "1"
CONSTANT: INVALID_LOCK_MULTIPLIER NUMERIC "5"
CONSTANT: CLK0_DIVIDE_BY NUMERIC "1"
CONSTANT: PLL_TYPE STRING "AUTO"
CONSTANT: VALID_LOCK_MULTIPLIER NUMERIC "1"
CONSTANT: SPREAD_FREQUENCY NUMERIC "0"
CONSTANT: INTENDED_DEVICE_FAMILY STRING "$device_family"
CONSTANT: OPERATION_MODE STRING "NORMAL"
CONSTANT: COMPENSATE_CLOCK STRING "CLK0"
CONSTANT: CLK0_PHASE_SHIFT STRING "0"
USED_PORT: c0 0 0 0 0 OUTPUT VCC "c0"
USED_PORT: \@clk 0 0 6 0 OUTPUT VCC "\@clk[5..0]"
USED_PORT: inclk0 0 0 0 0 INPUT GND "inclk0"
USED_PORT: \@extclk 0 0 4 0 OUTPUT VCC "\@extclk[3..0]"
CONNECT: \@inclk 0 0 1 0 inclk0 0 0 0 0
CONNECT: c0 0 0 0 0 \@clk 0 0 1 0
CONNECT: \@inclk 0 0 1 1 GND 0 0 0 0
GEN_FILE: TYPE_NORMAL altpll$module_name.$file_ext TRUE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name.inc FALSE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name.cmp FALSE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name.bsf FALSE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name\_inst.$file_ext FALSE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name\_waveforms.html FALSE FALSE
GEN_FILE: TYPE_NORMAL altpll$module_name\_wave*.jpg FALSE FALSE
END_OF_CNX

  if ($lang =~ /verilog/i) {  #Generate verilog black box declaration file
    $default_cnx_buffer.="GEN_FILE: TYPE_NORMAL altpll${module_name}_bb.v FALSE FALSE\n";
  }
    return $default_cnx_buffer;
  }









  sub generate_default_hdl
  {
  	(my $module_name, my $module_file_name, my %system_properties) = @_;

    my $sys_clk_freq = $system_properties{sys_clk_freq};
 		my $device_family = $system_properties{device_family};
    


    my $file_ext = $file_ext;
    

    my $default_hdl_buffer = (<<"END_OF_DEFAULT_HDL");
// megafunction wizard: %ALTPLL%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altpll 

// ============================================================
// File Name: altpll$module_name.$file_ext
// Megafunction Name(s):
// 			altpll
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
// ************************************************************


//Copyright (C) 1991-2005 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.

// ============================================================
// CNX file retrieval info
// ============================================================
//
END_OF_DEFAULT_HDL

    return $default_hdl_buffer;
  }

  sub create_hdl_from_ptf {
    my $cnx_info = shift;
    my $altpll_ports = shift;
    my $sys_clk_freq = shift;
    
    my @hdl_buffer_to_write = &generate_default_hdl($module_name, $module_file_name, $sys_clk_freq);

    my $write_buffer = &generate_cnx_from_ptf($cnx_info, $altpll_ports, $sys_clk_freq);

    my @cnx_buffer_to_write = split /\n/, $write_buffer;
          
    open(DEFAULT_MODULE, ">$module_file_name") or die "Unable to open file $module_file_name for writing $!\n";
    print DEFAULT_MODULE @hdl_buffer_to_write;
    foreach my $line (@cnx_buffer_to_write){
      print DEFAULT_MODULE "// Retrieval info: $line\n";
    }
    close(DEFAULT_MODULE);
  }
  
  sub create_cnx_from_ptf {
    my $cnx_info = shift;
    my $sys_clk_freq = shift;
    
    my $write_buffer = &generate_cnx_from_ptf($cnx_info, $sys_clk_freq);
    
    open (CNXFILEWR, ">$cnx_file_name") or die "Cannot write test CNX file : $!";
    print CNXFILEWR $write_buffer;
    close (CNXFILEWR);
  }
  
  sub generate_cnx_from_ptf {
    my $cnx_info = shift;
    my $altpll_ports = shift;
    my $sys_clk_freq = shift;
    
    my $sys_clk_period = 0;
    my $sys_clk_freq_in_mhz = 0;
    


    unless ($sys_clk_freq == 0) {
      ($sys_clk_period,$sys_clk_freq_in_mhz)=do_calculate_freq_and_period($sys_clk_freq);
    }
    

    my $privates = $cnx_info->{"PRIVATE"};
    my $library = $cnx_info->{"LIBRARY"};
    my $constants = $cnx_info->{"CONSTANT"};
    my $used_port = $cnx_info->{"USED_PORT"};
    my $files = $cnx_info->{"GEN_FILE"};
    
    my $write_buffer;
    

    $write_buffer.="GENERATION: STANDARD\n";
    $write_buffer.="VERSION: WM1.0\n";
    $write_buffer.="MODULE: altpll\n";
    $write_buffer.="\n";
  

    foreach my $datatype (keys %$privates) {
      my $topkey = $privates->{"$datatype"};
      foreach my $var_name (keys %$topkey) {
        my $val = $privates->{"$datatype"}->{"$var_name"};
        


        if (($datatype eq "STRING") && ($var_name eq "INCLK0_FREQ_EDIT") ) {
          if ($sys_clk_freq == 0) {
            $write_buffer .="PRIVATE: $var_name $datatype \"$val\"\n";
          }
          else{
            $write_buffer .="PRIVATE: $var_name $datatype \"$sys_clk_freq_in_mhz\"\n";  
          }
        }

        elsif (($datatype eq "STRING") && ($var_name eq "INCLK0_FREQ_UNIT_COMBO") ) {
          if ($sys_clk_freq == 0) {
            $write_buffer .="PRIVATE: $var_name $datatype \"$val\"\n";
          }
          else {
            $write_buffer .="PRIVATE: $var_name $datatype \"MHz\"\n"; 
          }
        }
        else {
          $write_buffer .="PRIVATE: $var_name $datatype \"$val\"\n";
        }
      }
      
    }
    

    $write_buffer .= "\n";
    $write_buffer.="LIBRARY:$library  \n";
    $write_buffer .= "\n";
    

    foreach my $datatype (keys %$constants) {
      my $topkey = $constants->{"$datatype"};
      foreach my $var_name (keys %$topkey) {
        my $val = $constants->{"$datatype"}->{"$var_name"};
        


        if (($datatype eq "NUMERIC") && ($var_name eq "INCLK0_INPUT_FREQUENCY") ) {
          unless ($sys_clk_freq == 0) {
            $write_buffer .="CONSTANT: $var_name $datatype \"$sys_clk_period\"\n";  
          }
        }
        else {        
          $write_buffer .="CONSTANT: $var_name $datatype \"$val\"\n";
        }
      }
      
    }
    $write_buffer .= "\n";
    

    foreach my $port_name (keys %$used_port){
      my $cnx_string .= $port_name;
      my $port = $used_port->{"$port_name"};
      foreach my $keys (sort keys %$port){
        $cnx_string .= " ".$port->{"$keys"};
      }
      $write_buffer .="USED_PORT: $cnx_string \"$port_name\"\n";
    }
    $write_buffer .= "\n";
    

    

    foreach my $filetype (keys %$files) {

      my $true_false = $files->{"$filetype"};
      
      foreach my $gen_choice (keys %$true_false) {
      	my $fileholder = $files->{"$filetype"}->{"$gen_choice"};
      	foreach my $name (keys %$fileholder) {
      		my $filename = $files->{"$filetype"}->{"$gen_choice"}->{"$name"};
	        $write_buffer .="GEN_FILE: $filetype altpll${module_name}$filename $gen_choice FALSE\n";
      	}
      }
    }
    return $write_buffer; 
  }
  
  sub convert_cnx_period_to_freq{
    my $primary_inclock_period = shift;
    my $primary_inclock_freq = 0;
    unless ($primary_inclock_period == 0 ) {





      my $rounded = 1e6/$primary_inclock_period;
      $rounded =~ s/([0-9]*.[0-9]{6})(.*)/\1/;
      $primary_inclock_freq = $rounded * 1e6;
    }
    return $primary_inclock_freq;
  }
  
  sub transverse_clk_source_hash {
    my $cnx_data = shift;
    my $SLAVE_PORT_WIRING = shift;
    my $module_name = shift;
    


    $SLAVE_PORT_WIRING = &clear_slave_port_wiring($SLAVE_PORT_WIRING, $module_name);
  

    &do_populate_clock($cnx_data);
    my $clock_sources = $cnx_data->{"CLOCK_SOURCES"};
    foreach my $clock_source (keys %$clock_sources) {
      

      unless ($clock_source =~ m/inclk/i) {


        my @clock_name = split(" ", $clock_source);
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"type"} = $clock_sources->{"$clock_source"}->{"type"};
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"width"} = "1";
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"direction"} = "output";
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"Is_Enabled"} = "1";
      

      }
      

      
    }
  }
  
  sub do_populate_clock
  {
    my $cnx_data = shift;

    my $clock_sources = $cnx_data->{"CLOCK_SOURCES"};
    my $cnx_info_private_string = $cnx_data->{"CNX_INFO"}->{"PRIVATE"}->{"STRING"};
    my $cnx_info_private_numeric = $cnx_data->{"CNX_INFO"}->{"PRIVATE"}->{"NUMERIC"};

    my $advanced_param = 0; # advanced parameter check, 1=true, 0=false;

    if( defined($cnx_info_private_string->{"PLL_ADVANCED_PARAM_CHECK"})
       and $cnx_info_private_string->{"PLL_ADVANCED_PARAM_CHECK"} eq "1")
    {

      $advanced_param = 1;
    }
    
    my $used_ports = $cnx_data->{"ALTPLL_PORTS"};
    my $all_use_clk = find_child($used_ports,"PORT [ce][0-9]+");
    foreach my $k (sort keys %$all_use_clk)
    {
      my $clk_index;
      my $clk_prefix;
      my $clock_source;
      if($k =~ m/^PORT ([ce])(\d+)/)
      {
        $clk_prefix=$1;
        $clk_index=$2;
        $clock_source = "CLOCK ".$clk_prefix.$clk_index;
      }    

      $clk_index = $clk_index + 6 if($clk_prefix eq "e"); # e0 = CLK6
      

      my $frequency = 0.0; 
      my $frequency_unit = "MHz";
      

      my $device_family = get_device_family();
      if ( $advanced_param == 0
          and $device_family eq "Cyclone"
          and $clk_prefix eq "e")
      {

        my $multiplier = 1;
        my $divisor = 1;

        my $cnx_info_constant_numeric = $cnx_data->{"CNX_INFO"}->{"CONSTANT"}->{"NUMERIC"};
        my $clk_name_suffix = $clk_index - 6;
        
        $multiplier = $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_MULTIPLY_BY"}
            if( $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_MULTIPLY_BY"} ne ''
               and $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_MULTIPLY_BY"} > 1);

        $divisor = $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_DIVIDE_BY"}
            if( $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_DIVIDE_BY"} ne ''
               and $cnx_info_constant_numeric->{"EXTCLK".$clk_name_suffix."_DIVIDE_BY"} > 1);
         
        $clock_sources->{"$clock_source"}->{"MULTIPLY_BY"} = $multiplier;          
        $clock_sources->{"$clock_source"}->{"DIVIDE_BY"} = $divisor;
        
        my $primary_inclock = lc get_primary_inclk($cnx_data);
        my $primary_inclock_freq = $cnx_data->{"CLOCK_INFO"}->{"CLOCK $primary_inclock"}->{"clock_freq"};

        $frequency = $primary_inclock_freq * ($multiplier / $divisor);

        $frequency_unit = $cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}
            if( defined($cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}))        
      }      


      elsif( defined($cnx_info_private_string->{"OUTPUT_FREQ_MODE".$clk_index})
         and $cnx_info_private_string->{"OUTPUT_FREQ_MODE".$clk_index} eq "1")
      {

        $frequency = $cnx_info_private_string->{"OUTPUT_FREQ".$clk_index}
            if( defined($cnx_info_private_string->{"OUTPUT_FREQ".$clk_index}));
            
        $frequency_unit = $cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}
            if( defined($cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}));
            

        if ($frequency_unit =~ /MHz/i)
        {
          $frequency = $frequency * 1e6;
        }elsif ($frequency_unit =~ /ns/i)
        {
          $frequency = 1e9/$frequency;
          $frequency_unit = "Mhz";
        }elsif ($frequency_unit =~ /ps/i)
        {
          $frequency = 1e12/$frequency;
          $frequency_unit = "Mhz";
        }        
            
      }else
      {

        my $multiplier = 1;
        my $divisor = 1;
        
        $multiplier = $cnx_info_private_numeric->{"MULT_FACTOR".$clk_index}
            if( defined($cnx_info_private_numeric->{"MULT_FACTOR".$clk_index})
               and $cnx_info_private_numeric->{"MULT_FACTOR".$clk_index} > 1);

        $divisor = $cnx_info_private_numeric->{"DIV_FACTOR".$clk_index}
            if( defined($cnx_info_private_numeric->{"DIV_FACTOR".$clk_index})
               and $cnx_info_private_numeric->{"DIV_FACTOR".$clk_index} > 1);
         
        $clock_sources->{"$clock_source"}->{"MULTIPLY_BY"} = $multiplier;          
        $clock_sources->{"$clock_source"}->{"DIVIDE_BY"} = $divisor;
        
        my $primary_inclock = lc get_primary_inclk($cnx_data);
        my $primary_inclock_freq = $cnx_data->{"CLOCK_INFO"}->{"CLOCK $primary_inclock"}->{"clock_freq"};

        $frequency = $primary_inclock_freq * ($multiplier / $divisor);

        $frequency_unit = $cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}
            if( defined($cnx_info_private_string->{"OUTPUT_FREQ_UNIT".$clk_index}))
      }
      

      $clock_sources->{"$clock_source"}->{"clk_index"} = $clk_index;
      $clock_sources->{"$clock_source"}->{"type"} = "out_clk";
      $clock_sources->{"$clock_source"}->{"clock_freq"} = $frequency;
      $clock_sources->{"$clock_source"}->{"clock_unit"} = $frequency_unit;          
    }
  }
  
  sub get_primary_inclk
  {
    my $cnx_data = shift;
    
    my $primary_inclock = uc($cnx_data->{"CNX_INFO"}->{"CONSTANT"}->{"STRING"}->{"PRIMARY_CLOCK"});
    

    if ($primary_inclock eq "") {
      $primary_inclock = "inclk0";
    }
    
    return $primary_inclock;
  }
  









  sub find_child
  {
    my $hash_branch = shift;
    my $key = shift;
    my $return_hash = {};
    
    while ((my $k, my $v) = each %$hash_branch)
    {
      if($k =~ /$key/)
      {
        $return_hash->{"$k"} = $v;
      }
    }
    return $return_hash;
  }
  
  sub clear_slave_port_wiring {
    my $SLAVE_PORT_WIRING = shift;
    my $module_name = shift;
    
    foreach  my $key (keys %$SLAVE_PORT_WIRING){

      if ($key =~ /PORT ${module_name}_/) {
        $SLAVE_PORT_WIRING->{"$key"}->{"Is_Enabled"} = "0";
      }
    }
    return $SLAVE_PORT_WIRING;
  }
  
  sub transverse_altpll_ports {
    my $ALTPLL_PORTS = shift;
    my $module_name = shift;
    my $module_port_wiring = shift;
    
    
    

    foreach my $port (keys %$ALTPLL_PORTS) {
      
      my @portname = split(" ", $port);
      

      my $wiring_naming_convention = "PORT $portname[1]";
      

      

      if (($ALTPLL_PORTS->{"$port"}->{"type"} eq "clken") ||

       ("PORT ".$ALTPLL_PORTS->{"$port"}->{"type"} eq $port)){
       	

        $module_port_wiring->{$wiring_naming_convention} = $ALTPLL_PORTS->{"$port"};
        $module_port_wiring->{$wiring_naming_convention}->{"type"} = "";
        
      }
    }
    return $module_port_wiring;
  }
  
   sub regenerate_cnx {
    my $module_file_name = shift;
    

    my $regen_cmd = "mega_altclklock -silent $module_file_name";
    system ("$regen_cmd");
    1;
  }
  
  
  sub make_cnx_copy {
    my $cnx_file_name = shift;
    my $system_directory = shift;
    
    my $cnx_copy_file_name = $cnx_file_name.".cpy";
    my $copy_cmd = "cp $cnx_file_name $cnx_copy_file_name";
    system ("$copy_cmd");
    return $cnx_copy_file_name;
  }
  
  
  sub compare_cnx_files {
    my $cnx_file_name = shift;
    my $cnx_copy_file_name = shift;
    my $system_directory = shift;
    
    open (CNXCOPY, "$cnx_copy_file_name") or die "\nCannot open $cnx_copy_file_name for read : $!";
    my $errorflag = 0;
    while (<CNXCOPY>) {
      chomp;
      open (CNXFILE, "$cnx_file_name") or die "\nCannot open $cnx_file_name for read : $!";

      if (/PRIVATE|CONSTANT|GEN_FILE/) {
        my $cnx_line = $_;
        my $searchflag = 0;
        
        while (!eof (CNXFILE)) {
          my $cnxfile_temp = <CNXFILE>;
          chomp $cnxfile_temp;
          
          my @firstdata = split ("\"", $cnx_line);
          my @seconddata = split ("\"", $cnxfile_temp);
          

          if ($firstdata[0] eq $seconddata[0]) {

            if (($firstdata[1] =~ m/^\d+\.\d+$/)||($seconddata[1] =~ m/^\d+\.\d+$/)) {

              if ($firstdata[1] == $seconddata[1]) {

                $searchflag = 1;
              }
            }
            else {

              if ($firstdata[1] eq $seconddata[1]) {

                $searchflag = 1;
              }
            }
          }
          else {} # keep searching
        }

        if ($searchflag == 0) {
          print "\nMissing line : $cnx_line";
          $errorflag = 1;
        }
      }
      else {} # We do not keep the rest of the data categories in PTF, so ignore them

      close (CNXFILE);
    }
    
    

    unless ($errorflag == 0) {
      print "\nError(s) found in CNX loopback test";
      return 0;
    }
    close( CNXCOPY);
    return 1; 
  }

	sub check_mod_freq_in_cnx {
		my $cnx_file_name = shift;
		my $sys_clk_freq = shift;
		
		my ($sys_clk_period, $sys_clk_freq_in_mhz) = &do_calculate_freq_and_period($sys_clk_freq);
    
		open (READCNX, "$cnx_file_name") or die "\nCannot read inclk freq from CNX file : $!";
		while (<READCNX>) {
			if (/INCLK0_INPUT_FREQUENCY/) {

				my @cnx_clk_freq = split ("\"", $_);
				if ($cnx_clk_freq[1] == $sys_clk_period ) {
					return 1;
				}
			}
		}
		
		close (READCNX);
		return 0;
	}
