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


		if (@ARGV == 0)	{
			exit(0);
		}


		my ($project, $script_mode, $altpll_ports, $module_file_name) = &generate_altpll_hdl(@ARGV);
		

		&make_avalon_pll ($project, $script_mode, $altpll_ports, $module_file_name);
        &copy_sdc_file ($project);
		
	    qq(I'm done);
	
		













    sub copy_sdc_file 
    {
        my $project = shift;
        my $component_dir = $project->{"_module_lib_dir"};
        my $project_dir = $project->{"__system_directory"};
        my $module = $project->top();
        my $module_name = $module->{"name"};
        my $src_sdc_path = $component_dir . "/" . "altera_avalon_pll.sdc";
        my $dst_sdc_path = $project_dir   . "/" . $module_name   . ".sdc";






        open(SRC_SDC_FILE, "< $src_sdc_path") or die "Error while opening source SDC file $src_sdc_path\n";
        open(DST_SDC_FILE, "> $dst_sdc_path") or die "Error while opening destination SDC file $dst_sdc_path\n";

        while (<SRC_SDC_FILE>)
        {
            print DST_SDC_FILE $_;
        }

        close(SRC_SDC_FILE);
        close(DST_SDC_FILE);
    }

	sub generate_altpll_hdl {
	
		my $project = e_project->new(@_);
		

	    my $module = $project->top();
	    my $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
	    my $module_name = $module->{"name"};
	    my $module_ptf = $project->system_ptf()->{"MODULE $module_name"};
        my $WSA = $module_ptf->{"WIZARD_SCRIPT_ARGUMENTS"};
    	my $system_directory = $project->{"__system_directory"};

		my $file_ext = ($lang =~ /verilog/i) ? "v"
				: ($lang =~ /vhdl/i) ? "vhd"
			: die "\nError in ptf file : hdl_language unrecognized.";
	

		  my $sys_clk_freq = $project->get_module_clock_frequency();
	    
	    my $device_family_ptf = $project->system_ptf()->{"WIZARD_SCRIPT_ARGUMENTS"}->{"device_family_id"};
    
    	my $device_family = do_device_family_name_mapping($device_family_ptf);

	    my %system_properties = (
	    	"sys_clk_freq" => $sys_clk_freq,
	    	"device_family" => $device_family,
    	);
    
		my $module_file_name = $system_directory."/altpll".$module_name.".".$file_ext;
		my $cnx_file_name = $system_directory."/altpll".$module_name.".cnx";
		my $cnx_backup_file_name = $system_directory."/altpll".$module_name.".cnxbak";
		
		my $cnx_info = $project->system_ptf()->{"MODULE $module_name"}->{"WIZARD_SCRIPT_ARGUMENTS"}->{"CNX_INFO"};












		
		my $module_port_wiring;
	    my $SLAVE_PORT_WIRING =$module_ptf->{"SLAVE s1"}->{PORT_WIRING};
	    my @cnx_arrays;
		my $altpll_ports;
		

		my $script_mode = $WSA->{"script_mode"};
		
		if ($script_mode == 1) {

			print "\nEntering script mode...\n";
			my $pll_params;
			

			foreach my $wsa_entry (keys %$WSA) {


				if ($wsa_entry =~ m/c[0-5]|e[0-3]/) {
					$pll_params->{"$wsa_entry"} = $WSA->{"$wsa_entry"};
				}
				


				
			}
			

			$pll_params->{"system_properties"}->{"sys_clk_freq"} = $system_properties{sys_clk_freq};
			$pll_params->{"system_properties"}->{"device_family"} = $system_properties{device_family};
			

			&create_default_hdl($module_name, $module_file_name, $lang, $file_ext, $script_mode, $pll_params);
			

			my $qmegawiz_cmd = "qmegawiz -silent $module_file_name";
			system ("$qmegawiz_cmd");
			

			open(HDL_INPUT_FILE, "< $module_file_name") or die "Error opening HDL file $module_file_name\n";
     	   	my @hdl_array = <HDL_INPUT_FILE>;
            
        	my $CNX_found = 0;
        	foreach (@hdl_array){
	        	if(/CNX file retrieval info/){
	          		$CNX_found = 1;
	           		next;
	           	}
	           	if($CNX_found==1){
		           	s/.*\/\/ Retrieval info\:\s+//;
	    	       	push @cnx_arrays, $_;
	           	}
			}
			
			
	 	my $cnx_data_hash = &parse_cnx_info($SLAVE_PORT_WIRING, @cnx_arrays, $module_name);
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
	        

	    $altpll_ports = $cnx_data_hash->{"ALTPLL_PORTS"};
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
	    

	    $WSA->{"script_mode"} = "0";
    
	    my $ptf_hash = &copy_of_hash ($project->system_ptf());
    
	}	# end of script mode
		
		else {



			


			if (-e $cnx_file_name) {
				unlink ($cnx_file_name);
			}
			my $cnx_err_file_name = $cnx_file_name . "err";
			if (-e $cnx_err_file_name) {
				unlink ($cnx_err_file_name);
			}
			my $qmegawiz_cmd = "qmegawiz -silent $module_file_name";
			&create_hdl_from_ptf($cnx_info, $sys_clk_freq, $module_name, $module_file_name, $sys_clk_freq, $file_ext);
			&check_generateok($module_name);
			my $rc = system ("$qmegawiz_cmd");









                        if ($rc == 65280) {
                          die "qmegawiz returned error code $rc. PLL generation failed.";
                        }
			
		}
		
		



	    return ($project, $script_mode, $altpll_ports, $module_file_name);
	}
	
	
	sub make_avalon_pll
        {
	  		my $project = shift;
	  		my $script_mode = shift;
	  		my $altpll_ports = shift;
	  		my $module_file_name = shift;
	  		
		    my %Options = %{$project->WSA()};
		    my $WSA = \%Options;
    

		    my $module = $project->top();
            my $module_name  = $project->{_target_module_name};
			my $module_ptf = $project->system_ptf()->{"MODULE $module_name"};
			my $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
	    

			if ($script_mode == 0) {
				$altpll_ports = $module_ptf->{"WIZARD_SCRIPT_ARGUMENTS"}->{"ALTPLL_PORTS"};
			}
			





			

			

			my ($in_port_map, $out_port_map, $slave_port_map, $locked_flag) = &wrap_altpll($module_name, $WSA, $altpll_ports);
			

			if (exists($altpll_ports->{"PORT phasecounterselect"}))
			{
				my $phasecounterselect_width = $altpll_ports->{"PORT phasecounterselect"}->{width};
				$module->add_contents(
					e_port->new({name=>"altpll_phasecounterselect", width=>$phasecounterselect_width, direction=>"in"}),
				);
			}
	    	
	    	
	    	my $selection;
			$selection->{"areset"} = $WSA->{"areset"};
			$selection->{"locked"} = $WSA->{"locked"};
			$selection->{"pfdena"} = $WSA->{"pfdena"};
			$selection->{"pllena"} = $WSA->{"pllena"};
			
			my %assign_ports;
			my %add_ports;
			my %register_list;
			my $tag;
			






























      if ($lang eq "verilog") {
        $tag = "normal";
        $module->add_contents(
          e_initial_block->new ({
              comment => "Initial block for simulation ",
              contents => [
                  e_assign->new([countup => "1'b0"]),
                  e_assign->new([count_done => "1'b0"]),
                  e_assign->new([not_areset => "1'b0"]),
              ],
          }),
      
        );			
      } else {

        $tag = "synthesis";
        $module->add_contents(
          e_mux->new({
            comment=>"mux for init value",
            tag => "simulation",
						name=>"init_mux", 
						type =>"selecto",
						selecto=>"rtmp",
						lhs=>"not_areset",
						table=>[
						0 => "0", 
						1 => "1"],  
          }),
          
          e_register->new({
            comment => "rtmp register",
            tag => "simulation",
						name => "rtmep_reg",
            in => "1'b1",
            out => "rtmp",
            enable => "1'b1",
            preserve_register => "1",
            async_value => "0",
            reset => "0",
          }),
          );
        }

			if (1 == 0) {}  # bogus line to always do this below
			else {
	    		$module->add_contents(
					


			    e_assign->new(["status_reg_in[15:1]"=>"15'b000000000000000"]),
					


	    		e_signal->new({name=>"countup", width=>6, never_export=>1}),
					e_assign->add(["resetrequest"=>"~count_done"]),

					
          e_register->new({
              comment => "Up counter that stops counting when it reaches max value",
              in => "countup + 1",
              out => "countup",
              enable => "count_done != 1'b1",
              reset => "areset_n",
          }),					
          
          e_register->new({
              comment => "Count_done signal, which is also the resetrequest_n",
              in => "1'b1",
              out => "count_done",
              enable => "countup == 6'b111111",
              reset => "areset_n",
          }),
   			


					e_register->add({
						comment =>"Creates a reset generator that will reset internal counters that are independent of global system reset",
						tag => "$tag",
						name =>"Reset_generator",
						in=>"always_one",
						out=>"not_areset",
						enable=>"1",
						async_value =>"0",	# will not get to here but we're counting on the registers booting up low
						reset=>"1'b1",	# fake reset signal 
						preserve_register => "1",
					}),










					
					e_assign->new([always_one => "1'b1"]),
	    			
	    		);
	    	}
	    

			if ($selection->{"locked"} ne "Register" ) {
			  $module->add_contents(
			    e_assign->new(["status_reg_in[0]"=>"1'b0"]),
			  );
			}
			
			
			foreach my $data_name (keys %$selection) {

				if ($selection->{"$data_name"} eq "System") {




















				}
				

				elsif ($selection->{"$data_name"} eq "Register") {


					$module->add_contents(
									e_signal->add({name=>"altpll_$data_name", never_export=>0}),
					);
					if ($data_name eq "areset") {
						$module->add_contents(
							


							





							
							e_assign->add([oneshot_areset_in=>"control_reg_in[0] && control_reg_en"]),
							e_assign->add([areset_oneshot_reg_reset_n=>"(reset_n)"]),
							

							e_process->add({
								comment=>"One shot output to areset.",
								name=>"areset_oneshot_reg",
								reset=>"areset_oneshot_reg_reset_n",
								asynchronous_contents=>[
									e_assign->add([oneshot_areset_out=>"0"]),
								],

								contents=>[
									e_comment->new({comment=>"Thing to execute every clock cycle"}),
									e_assign->new([oneshot_areset_out=>"0"]),
									e_if->new ({
										comment=>"Set areset to high",
										condition => "control_reg_en",
										then => [
											e_assign->add([oneshot_areset_out=>"oneshot_areset_in"]),
										],
									}),
								],
							}),

							e_signal->add({name =>"altpll_$data_name", never_export=>1}),
							e_assign->add(["altpll_areset"=>"areset"]),
							e_assign->new([areset=>"~not_areset | oneshot_areset_out"]),
							e_assign->new([areset_n => "~areset"]),
					
						);
					}
					elsif ($data_name eq "pllena") {
						$module->add_contents(



							
							e_signal->add({name =>"altpll_$data_name", never_export=>1}),
						);					
					}
					elsif ($data_name eq "pfdena") {
						$module->add_contents(



							e_assign->add([altpll_pfdena=>"~control_reg_out[1]"]),
							e_signal->add({name =>"altpll_$data_name", never_export=>1}),
						);					
					}
					elsif ($data_name eq "locked") {
						$module->add_contents(

							e_assign->add(["status_reg_in[0]"=>"altpll_$data_name"],),
							e_signal->add({name =>"altpll_$data_name", never_export=>1}),
						);										
					}
				}
				
				elsif ($selection->{"$data_name"} eq "Export") {
					my $direction = $altpll_ports->{"PORT $data_name"}->{"direction"};
					if ($data_name ne "areset") {
					  if ($direction eq "input"){
  						$module->add_contents(
							  e_assign->new({
							    lhs => "altpll_$data_name",
							    rhs =>"$data_name",
							  }),
						  );
					  } else {
  						$module->add_contents(
							  e_assign->add([$data_name=>"altpll_$data_name"]),
						  );
					  }
					} else {
					  $module->add_contents (
					    e_assign->new([areset_n => "~altpll_areset"]),
					    e_assign->new([altpll_areset => "areset | ~not_areset"]),
					  
					  );
					}
				}
				
				elsif ($selection->{"$data_name"} eq "None") {

					$module->add_contents(
							e_signal->add({name=>$data_name, never_export=>1}),
					);
					
					if ($data_name eq "areset") {
						$module->add_contents(
						    e_assign->add(["areset_n"=>"not_areset"]),
						);
					}
				}
				
				else {
					my $config = $selection->("$data_name");
					die "\nInternal Error : Advanced configuration data for PIN $data_name unrecognized : $config.";


				}
			}
			


			
			$module->add_contents
            (



				
				e_port->adds(
					     ["clk" => 1 => "input"],
					     ["reset_n" => 1 => "input"],

					     ["address" => 3 => "input"],
					     ["readdata" => 16 => "output"],
					     ["writedata" => 16 => "input"],
					     ["resetrequest"=>1=>"output"],
					     ["read"=>1=>"input"],
					     ["write"=>1=>"input"],
					     ["chipselect"=>1=>"input"],
					    ),
				
				
				e_assign->adds(

					       ["inclk0" => "clk"],
					      ),
				
				

				e_signal->new({name=>"status_reg_out", width=>16, never_export=>1}),
				e_signal->new({name=>"control_reg_out", width=>16, never_export=>1}),
				e_signal->new({name=>"status_reg_in", width=>16, never_export=>1}),
				e_signal->new({name=>"control_reg_in", width=>16, never_export=>1}),
				e_signal->new({name=>"control_reg_en", width=>1, never_export=>1}),
				
				
				e_mux->new({comment=>"Mux status and control registers to the readdata output using address as select",
							name=>"readdata_mux", 
							type =>"selecto",
							selecto=>"address[0]",
							lhs=>"readdata",
							table=>[
							0 => "status_reg_out", 
							1 => "({control_reg_out[15:2], ~control_reg_out[1], control_reg_out[0]} )"],  }),
				


				e_register->new({comment=>"Status register - Read-Only",
								name=>"Status_Register",
								in=>"status_reg_in",
								out=>"status_reg_out",
								enable=>"1'b1",
								}),
				



				e_register->new({comment=>"Control register - R/W",
								name=>"Control_Register",
								in=>"{control_reg_in[15:2], ~control_reg_in[1], control_reg_in[0]}",
								out=>"control_reg_out",
								enable=>"(control_reg_en)",

								}),
				e_assign->add(["control_reg_in"=>"writedata"]),
				e_assign->add(["control_reg_en"=>"(address == 3'b001) && write && chipselect"]),
				
				

				e_avalon_slave->new({name=>"s1", type_map=>$slave_port_map, }),
							
				e_blind_instance->add({

							use_sim_models => 1,
							name           => "the_pll",
							module         => "altpll".$module_name,
							in_port_map    => $in_port_map,
							out_port_map   => $out_port_map,

						}),
             
            );
           
            


            $project->output();


            $project->module_ptf()->{HDL_INFO}{Synthesis_HDL_Files} .= ", $module_file_name";


            $project->ptf_to_file();
        }   

        sub wrap_altpll
        {
            my ($module_name, $WSA, $altpll_ports) =   @_;
           	my %slave_port_map;
           	
           	my $ports;
           	
           	if ($script_mode == 0) {
				$ports = $WSA->{"ALTPLL_PORTS"}->{"PORT"};
           	}


           	else {
           		foreach my $portname (keys %$altpll_ports) {
					my @splited_portname = split(" ", $portname);
           			$ports->{"$splited_portname[1]"} = $altpll_ports->{"$portname"};
           			
           		}
           	}


			
            
            my $locked_flag = 0;
         	
            
	    	my $in_port_map = {};
            my $out_port_map = {};

            foreach my $s (keys (%$ports))
	    	{
	    	    my $port_name = $s;

				if ($ports->{"$port_name"}->{"type"} eq "out_clk") {
					$slave_port_map{$port_name} = "out_clk";
				}
                

                $slave_port_map{"readdata"} = "readdata";
                $slave_port_map{"writedata"} = "writedata";
                $slave_port_map{"write"} = "write";
                $slave_port_map{"read"} = "read";
                $slave_port_map{"resetrequest"} = "resetrequest";
                $slave_port_map{"chipselect"} = "chipselect";


                if ($port_name eq "locked") {
                	$locked_flag = 1;
                }
                


                if ($WSA->{"$port_name"} eq "None") {

                }
                elsif ($WSA->{"$port_name"} eq "Register") {
	                ($ports->{"$port_name"}->{"direction"} eq "input") ? ($in_port_map->{$port_name} = "altpll_$port_name")
                                                 : ($out_port_map->{$port_name} = "altpll_$port_name");            	
                }

                elsif($WSA->{"$port_name"} eq "Export") {
                	($ports->{"$port_name"}->{"direction"} eq "input") ? ($in_port_map->{$port_name} = "altpll_$port_name")
                                                 : ($out_port_map->{$port_name} = "altpll_$port_name");            
                }

                elsif($WSA->{"$port_name"} eq "System") {
                	($ports->{"$port_name"}->{"direction"} eq "input") ? ($in_port_map->{$port_name} = "$port_name")
                                                 : ($out_port_map->{$port_name} = "$port_name");            
                }
                


                else {  
                	($ports->{"$port_name"}->{"direction"} eq "input") ? ($in_port_map->{$port_name} = "$port_name")
                                                 : ($out_port_map->{$port_name} = "$port_name");        
                }
            } 
            
           
            
            return ($in_port_map, $out_port_map, \%slave_port_map, $locked_flag);
               
        }    
            
	
	
		
	sub create_cnx_from_ptf {
		my $cnx_info = shift;
		my $cnx_file_name = shift;
		
		my $write_buffer = &generate_cnx_from_ptf($cnx_info);
		
		open (CNXFILEWR, ">$cnx_file_name") or die "Cannot write test CNX file : $!";
		print CNXFILEWR $write_buffer;
		close (CNXFILEWR);
		
	}
	
	sub generate_cnx_from_ptf {
		my $cnx_info = shift;
		my $sys_clk_freq = shift;
		
		my $sys_clk_period = 0;
		my $sys_clk_freq_in_mhz = 0;
		


		unless ($sys_clk_freq == 0) {
			$sys_clk_period = (10**12)/($sys_clk_freq);
			$sys_clk_freq_in_mhz = $sys_clk_freq / 1000000;
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
				
				$write_buffer .="PRIVATE: $var_name $datatype \"$val\"\n";
			}
			
		}
		

		$write_buffer .= "\n";
		$write_buffer.="LIBRARY:$library  \n";
		$write_buffer .= "\n";
		

		foreach my $datatype (keys %$constants) {
			my $topkey = $constants->{"$datatype"};
			foreach my $var_name (keys %$topkey) {
				my $val = $constants->{"$datatype"}->{"$var_name"};
				


				$write_buffer .="CONSTANT: $var_name $datatype \"$val\"\n";
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
		

		foreach my $filetype (keys %$files)	{
			my $filenum = $files->{"$filetype"};
			foreach my $fileholder (keys %$filenum) {
				my $filename = $files->{"$filetype"}->{"$fileholder"}->{"name"};
				my $gen_choice = $files->{"$filetype"}->{"$fileholder"}->{"generate"};
				$write_buffer .="GEN_FILE: $filetype $filename $gen_choice FALSE\n";
			}
		}
		return $write_buffer;	
	}
	
		
	sub check_generateok {
    	my $module_name = shift;
    	

	    if ( -e "qmegawiz_errors_log.txt") {

	    	open (WIZLOGFILE, "qmegawiz_errors_log.txt") or die "\nCannot read qmegawiz_errors_log.txt : $!";
	    	

	    	my @buffer = <WIZLOGFILE>;
	    	close(WIZLOGFILE);
	    	
	    	print "\n@buffer\n";

	    	unlink("qmegawiz_errors_log.txt");
	    }
	    else {	# null
	    }
	    
	    if (-e "$module_name.cnxerr") {
	    	die "\nCNX Database error";
	    }
	}
	sub create_default_hdl
	{
		my $module_name = shift;
		my $module_file_name  = shift;
		my $lang = shift;
		my $file_ext = shift;
		my $script_mode = shift;
		my $pll_params = shift;
		

		
		my $buffer_to_write = &generate_default_hdl($module_name, $module_file_name, $lang, $file_ext, $script_mode, $pll_params);
		

		open(DEFAULT_MODULE, ">$module_file_name") or die "Unable to open file $module_file_name for writing $!\n";
		print DEFAULT_MODULE $buffer_to_write;
		close(DEFAULT_MODULE);
	}
	
	
	








	sub generate_default_hdl
	{
		my $module_name        = shift;
		my $module_file_name = shift;
		my $lang = shift;
		my $file_ext = shift;
		my $script_mode = shift;
		my $pll_params = shift;
		
		my $sys_clk_freq = $pll_params->{"system_properties"}->{"sys_clk_freq"};
		my $sys_clk_period;
		my $sys_clk_freq_in_mhz;
		


		unless ($sys_clk_freq == 0) {
			$sys_clk_period = (10**12)/($sys_clk_freq);
			$sys_clk_freq_in_mhz = $sys_clk_freq / 1000000;
		}

		my $default_hdl_buffer = "";
		
		$default_hdl_buffer.="// megafunction wizard: %ALTPLL%																                            \n";
		$default_hdl_buffer.="// GENERATION: STANDARD                                                                     \n";
		$default_hdl_buffer.="// VERSION: WM1.0                                                                           \n";
		$default_hdl_buffer.="// MODULE: altpll                                                                           \n";
		$default_hdl_buffer.="                                                                                            \n";
		$default_hdl_buffer.="// ============================================================                             \n";
		$default_hdl_buffer.="// File Name: altpll".$module_name.".".$file_ext."                                                \n";
		$default_hdl_buffer.="// Megafunction Name(s):                                                                    \n";
		$default_hdl_buffer.="// 			altpll                                                                        \n";
		$default_hdl_buffer.="// TEMPLATE FILE FOR : em_pll_configuration.pl                            \n";
		$default_hdl_buffer.="// ============================================================                             \n";
		$default_hdl_buffer.="// ************************************************************                             \n";
		$default_hdl_buffer.="// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!                                  \n";
		$default_hdl_buffer.="//                                                                                          \n";
		$default_hdl_buffer.="// 5.0 Build 147 04/20/2005 SJ Full Version                                                 \n";
		$default_hdl_buffer.="// ************************************************************                             \n";
		$default_hdl_buffer.="                                                                                            \n";
		$default_hdl_buffer.="                                                                                            \n";
		$default_hdl_buffer.="//Copyright (C) 1991-2005 Altera Corporation                                                \n";
		$default_hdl_buffer.="//Your use of Altera Corporation's design tools, logic functions                            \n";
		$default_hdl_buffer.="//and other software and tools, and its AMPP partner logic                                  \n";
		$default_hdl_buffer.="//functions, and any output files any of the foregoing                                      \n";
		$default_hdl_buffer.="//(including device programming or simulation files), and any                               \n";
		$default_hdl_buffer.="//associated documentation or information are expressly subject                             \n";
		$default_hdl_buffer.="//to the terms and conditions of the Altera Program License                                 \n";
		$default_hdl_buffer.="//Subscription Agreement, Altera MegaCore Function License                                  \n";
		$default_hdl_buffer.="//Agreement, or other applicable license agreement, including,                              \n";
		$default_hdl_buffer.="//without limitation, that your use is for the sole purpose of                              \n";
		$default_hdl_buffer.="//programming logic devices manufactured by Altera and sold by                              \n";
		$default_hdl_buffer.="//Altera or its authorized distributors.  Please refer to the                               \n";
		$default_hdl_buffer.="//applicable agreement for further details.                                                 \n";
		$default_hdl_buffer.="                                                                                            \n";
		if ($script_mode == 0) {
			$default_hdl_buffer.="                                                                                            \n";
			$default_hdl_buffer.="// ============================================================                             \n";
			$default_hdl_buffer.="// CNX file retrieval info                                                                  \n";
			$default_hdl_buffer.="// ============================================================                             \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: MIRROR_CLK0 STRING \"0\"                                        \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PHASE_SHIFT_UNIT0 STRING \"deg\"                                \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: OUTPUT_FREQ_UNIT0 STRING \"MHz\"                                \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_COMBO STRING \"MHz\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SPREAD_USE STRING \"0\"                                         \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SPREAD_FEATURE_ENABLED STRING \"1\"                             \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: GLOCKED_COUNTER_EDIT_CHANGED STRING \"1\"                       \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: GLOCK_COUNTER_EDIT NUMERIC \"1048575\"                          \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SRC_SYNCH_COMP_RADIO STRING \"0\"                               \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: DUTY_CYCLE0 STRING \"50.00000000\"                              \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PHASE_SHIFT0 STRING \"0.00000000\"                              \n"; 
			$default_hdl_buffer.="// Retrieval info: PRIVATE: MULT_FACTOR0 NUMERIC \"1\"                                      \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: OUTPUT_FREQ_MODE0 STRING \"0\"                                  \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SPREAD_PERCENT STRING \"0.500\"                                 \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LOCKED_OUTPUT_CHECK STRING \"1\"                                \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_ARESET_CHECK STRING \"1\"                                   \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: STICKY_CLK0 STRING \"1\"                                        \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH STRING \"1.000\"                                      \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_USE_CUSTOM STRING \"0\"                               \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: DEVICE_SPEED_GRADE STRING \"Any\"                               \n";
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SPREAD_FREQ STRING \"50.000\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_FEATURE_ENABLED STRING \"1\"                          \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LONG_SCAN_RADIO STRING \"1\"                                    \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_ENHPLL_CHECK NUMERIC \"0\"                                  \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE_DIRTY NUMERIC \"0\"                         \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: USE_CLK0 STRING \"1\"                                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT_CHANGED STRING \"1\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SCAN_FEATURE_ENABLED STRING \"1\"                               \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: ZERO_DELAY_RADIO STRING \"0\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_PFDENA_CHECK STRING \"0\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CREATE_CLKBAD_CHECK STRING \"0\"                                \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK1_FREQ_EDIT STRING \"100.000\"                             \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CUR_DEDICATED_CLK STRING \"c0\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_FASTPLL_CHECK NUMERIC \"0\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: ACTIVECLK_CHECK STRING \"0\"                                    \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_FREQ_UNIT STRING \"MHz\"                              \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK0_FREQ_UNIT_COMBO STRING \"MHz\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: GLOCKED_MODE_CHECK STRING \"0\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: NORMAL_MODE_RADIO STRING \"1\"                                  \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CUR_FBIN_CLK STRING \"e0\"                                      \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: DIV_FACTOR0 NUMERIC \"1\"                                       \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK1_FREQ_UNIT_CHANGED STRING \"1\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: HAS_MANUAL_SWITCHOVER STRING \"1\"                              \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: EXT_FEEDBACK_RADIO STRING \"0\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_AUTOPLL_CHECK NUMERIC \"1\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CLKLOSS_CHECK STRING \"0\"                                      \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_USE_AUTO STRING \"1\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SHORT_SCAN_RADIO STRING \"0\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LVDS_MODE_DATA_RATE STRING \"300.000\"                          \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CLKSWITCH_CHECK STRING \"0\"                                    \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SPREAD_FREQ_UNIT STRING \"KHz\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_ENA_CHECK STRING \"1\"                                      \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INCLK0_FREQ_EDIT STRING \"${sys_clk_freq_in_mhz}\"                             \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CNX_NO_COMPENSATE_RADIO STRING \"0\"                            \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: INT_FEEDBACK__MODE_RADIO STRING \"1\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: OUTPUT_FREQ0 STRING \"100.000\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PRIMARY_CLK_COMBO STRING \"inclk0\"                             \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CREATE_INCLK1_CHECK STRING \"0\"                                \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SACN_INPUTS_CHECK STRING \"0\"                                  \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: DEV_FAMILY STRING \"Stratix\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LOCK_LOSS_SWITCHOVER_CHECK STRING \"0\"                         \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SWITCHOVER_COUNT_EDIT NUMERIC \"1\"                             \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: SWITCHOVER_FEATURE_ENABLED STRING \"1\"                         \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_PRESET STRING \"Low\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: GLOCKED_FEATURE_ENABLED STRING \"0\"                            \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: USE_CLKENA0 STRING \"0\"                                        \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: LVDS_PHASE_SHIFT_UNIT0 STRING \"deg\"                           \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: CLKBAD_SWITCHOVER_CHECK STRING \"0\"                            \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: BANDWIDTH_USE_PRESET STRING \"0\"                               \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: PLL_LVDS_PLL_CHECK NUMERIC \"0\"                                \n";  
			$default_hdl_buffer.="// Retrieval info: PRIVATE: DEVICE_FAMILY NUMERIC \"9\"                                     \n";  
		}

		$default_hdl_buffer.="// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all                    \n";
		

		if ($script_mode == 0) {
			$default_hdl_buffer.="// Retrieval info: CONSTANT: CLK0_DUTY_CYCLE NUMERIC \"50\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: CONSTANT: CLK0_MULTIPLY_BY NUMERIC \"1\"                                 \n";  
			$default_hdl_buffer.="// Retrieval info: CONSTANT: CLK0_DIVIDE_BY NUMERIC \"1\"                                   \n";  
			$default_hdl_buffer.="// Retrieval info: CONSTANT: CLK0_PHASE_SHIFT STRING \"0\"                                  \n";  
		}

		else {


			
			my $clk_type;
			my $clk_index;
			
			foreach my $clock_param (keys %$pll_params) {
				my $param_data = $pll_params->{"$clock_param"};
				
				

				if ($clock_param =~ /(c[0-5]|e[0-3])/) {
					if ($clock_param =~ /c([0-5])/) {
						$clk_type = "CLK$1";
						$default_hdl_buffer.="// Retrieval info: PRIVATE: USE_CLK$1 STRING \"1\"    \n";  
						
					}
					elsif ($clock_param =~ /e([0-3])/) {
						$clk_type = "EXTCLK$1";
						$clk_index = $1 + 6;
						$default_hdl_buffer.="// Retrieval info: PRIVATE: USE_CLK$clk_index STRING \"1\"    \n";  
					}
					else {

						die "Weird error in matching algorithm.";
					}
					


					if ($clock_param =~ /_m/) {
						$default_hdl_buffer.="// Retrieval info: CONSTANT: ${clk_type}_MULTIPLY_BY NUMERIC \"$param_data\" \n";  
					}

					elsif($clock_param =~ /_n/) {
						$default_hdl_buffer.="// Retrieval info: CONSTANT: ${clk_type}_DIVIDE_BY NUMERIC \"$param_data\"   \n";  
					}

					elsif ($clock_param =~ /_ps/) {
					  $default_hdl_buffer.="// Retrieval info: PRIVATE: PHASE_SHIFT_UNIT$clk_index STRING \"deg\"   \n";  	
						$default_hdl_buffer.="// Retrieval info: PRIVATE: PHASE_SHIFT$clk_index STRING \"$param_data\"   \n";  	

					}
				}
			}
		}
		
		$default_hdl_buffer.="// Retrieval info: CONSTANT: BANDWIDTH_TYPE STRING \"AUTO\"                                 \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: LPM_TYPE STRING \"altpll\"                                     \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: INVALID_LOCK_MULTIPLIER NUMERIC \"5\"                          \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC \"${sys_clk_period}\"                       \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: PLL_TYPE STRING \"AUTO\"                                       \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: VALID_LOCK_MULTIPLIER NUMERIC \"1\"                            \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: SPREAD_FREQUENCY NUMERIC \"0\"                                 \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING \"Stratix\"                      \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: OPERATION_MODE STRING \"NORMAL\"                               \n";  
		$default_hdl_buffer.="// Retrieval info: CONSTANT: COMPENSATE_CLOCK STRING \"CLK0\"                               \n";  
		
		
		
		
		$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name.".".$file_ext." TRUE FALSE           \n";
		$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name.".inc FALSE FALSE                            \n";
		$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name.".cmp FALSE FALSE                            \n";
		$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name.".bsf FALSE FALSE                            \n";
		$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name."_inst.".$file_ext." FALSE FALSE             \n";
		if ($lang =~ /verilog/i) {	#Generate verilog black box declaration file
			$default_hdl_buffer.="// Retrieval info: GEN_FILE: TYPE_NORMAL altpll".$module_name."_bb.v TRUE FALSE                            \n";
		}
		return $default_hdl_buffer;
	}



  sub create_default_cnx
  {
    (my $module_name, my $cnx_file_name, my %system_properties, my $lang) = @_;

    

    my $cnx_buffer_to_write = &generate_default_cnx($module_name, $cnx_file_name, %system_properties, $lang);
      
      open(DEFAULT_CNX, ">$cnx_file_name") or die "Unable to open file $cnx_file_name for writing $!\n";
      print DEFAULT_CNX <<"END_OF_CNX_HEADER";
GENERATION: STANDARD
VERSION: WM1.0
MODULE: altpll 

END_OF_CNX_HEADER
      
      print DEFAULT_CNX $cnx_buffer_to_write;
      close(DEFAULT_CNX);
  }
  
    
	







  sub generate_default_cnx
  {
  	(my $module_name, my $module_file_name, my %system_properties, my $lang) = @_;
	my $file_ext = ($lang =~ /verilog/i) ? "v"
				: ($lang =~ /vhdl/i) ? "vhd"
			: die "\nError in ptf file : hdl_language unrecognized.";
	
	
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
CONSTANT: INCLK0_INPUT_FREQUENCY NUMERIC "$sys_clk_period"
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
END_OF_CNX

  if ($lang =~ /verilog/i) {  #Generate verilog black box declaration file
    $default_cnx_buffer.="GEN_FILE: TYPE_NORMAL altpll${module_name}_bb.v TRUE FALSE\n";
  }
    return $default_cnx_buffer;
  }
	
	
	
   sub regenerate_cnx {
    my $module_file_name = shift;
    

    my $regen_cmd = "mega_altclklock -silent $module_file_name";
    system ("$regen_cmd");
    1;
  }
  
  
  




  sub do_device_family_name_mapping
  {
  	my $device_name = @_[0];
  	
		my %translate_device_name = (
			"CYCLONE" => "Cyclone",
			"CYCLONEII" => "Cyclone II",
			"CYCLONEIII" => "Cyclone III",
			"TARPON" => "Cyclone III LPS",
			"STINGRAY" => "Cyclone IV GX",
			"CYCLONEIVE" => "Cyclone IV E",
			"CYCLONEV" => "Cyclone V",
			"STRATIX" => "Stratix",
			"STRATIXGX" => "Stratix GX",
			"STRATIXII" => "Stratix II",
			"STRATIXIII" => "Stratix III",
			"STRATIXIIGX" => "Stratix II GX",
			"STRATIXIV" => "Stratix IV",
			"STRATIXV" => "Stratix V",
			"ARRIAGX" => "Arria GX",
			"ARRIAII" => "Arria II",
			"ARRIAIIGZ" => "Arria II GZ",
                        "ARRIAV" => "Arria V",
			"HARDCOPYII" => "HardCopy II",
			"HARDCOPYIII" => "HardCopy III",
			"HARDCOPYIV" => "HardCopy IV",
		);
		
		my $tr_device_name = $translate_device_name{$device_name};
		
		if($tr_device_name ne ""){
			return $tr_device_name;
		}else{
			return $device_name;
		}
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
  
  
  
  sub transverse_clk_source_hash {
    my $cnx_data = shift;
    my $SLAVE_PORT_WIRING = shift;
    my $module_name = shift;
    



    my $primary_inclock = uc($cnx_data->{"CNX_INFO"}->{"CONSTANT"}->{"STRING"}->{"PRIMARY_CLOCK"});
    

    if ($primary_inclock eq "") {
      $primary_inclock = "INCLK0";
    }
    my $primary_inclock_period = $cnx_data->{"CNX_INFO"}->{"CONSTANT"}->{"NUMERIC"}->{"${primary_inclock}_INPUT_FREQUENCY"};
    my $primary_inclock_freq = 0;
    unless ($primary_inclock_period == 0) {
      $primary_inclock_freq = int((10**6)/($primary_inclock_period)) * (10**6);
    }

    


    $SLAVE_PORT_WIRING = &clear_slave_port_wiring($SLAVE_PORT_WIRING, $module_name);
    
  

    my $clock_sources = $cnx_data->{"CLOCK_SOURCES"};
    foreach my $clock_source (keys %$clock_sources) {
      

      unless ($clock_source =~ m/inclk/i) {
    

        my $divisor = $clock_sources->{"$clock_source"}->{"DIVIDE_BY"};
        my $multiplier = $clock_sources->{"$clock_source"}->{"MULTIPLY_BY"};
        my $outclock_freq = $primary_inclock_freq * ($multiplier / $divisor);
        

        $clock_sources->{"$clock_source"}->{"clock_freq"} = $outclock_freq;
        

        $clock_sources->{"$clock_source"}->{"clock_unit"} = "MHz";

    
    

        my @clock_name = split(" ", $clock_source);
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"type"} = $clock_sources->{"$clock_source"}->{"type"};
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"width"} = "1";
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"direction"} = "output";
        $SLAVE_PORT_WIRING->{"PORT $clock_name[1]"}->{"Is_Enabled"} = "1";
      

      }
      

      
    }
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
  
  
  sub parse_cnx_info
  {
    my ($SLAVE_PORT_WIRING, @cnx_arrays, $module_name) = @_;



    
    my $cnx_data = {};
    $cnx_data->{"CLOCK_INFO"}->{"RECONFIG_ENABLED"} = 0;
    $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_OUTPUT_CLOCKS"} = 0;
    $cnx_data->{"CLOCK_INFO"}->{"NUMBER_OF_INPUT_CLOCKS"} = 0;
    
    my $gen_file_count = 0;
    


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
          my @lib_data = split (":", $_);
          $cnx_data->{"CNX_INFO"}->{$lib_data[0]}= $lib_data[1];
        }
        elsif(/CONSTANT/)
        {

          if (/\s+CLK[0-5]/) {
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
    return $cnx_data;
      
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
        $pll_clock_info->{"value"} = int((10**6)/($clock_field_value[1]))*(10**6);
      }
    }
    
    return $pll_clock_info;
  }
    

  sub create_hdl_from_ptf {
    my $cnx_info = shift;
    my $sys_clk_freq = shift;
    my $module_name = shift;
    my $module_file_name = shift;
    my $sys_clk_freq = shift;
    my $file_ext = shift;
    
    my @hdl_buffer_to_write = &generate_default_hdl_config($module_name, $module_file_name, $sys_clk_freq, $file_ext);

    my $write_buffer = &generate_cnx_from_ptf($cnx_info, $sys_clk_freq);

    my @cnx_buffer_to_write = split /\n/, $write_buffer;
          
    open(DEFAULT_MODULE, ">$module_file_name") or die "Unable to open file $module_file_name for writing $!\n";
    print DEFAULT_MODULE @hdl_buffer_to_write;
    foreach my $line (@cnx_buffer_to_write){
      unless ($line =~ /^\s*$/) {
        print DEFAULT_MODULE "// Retrieval info: $line\n";
      }
    }
    close(DEFAULT_MODULE);
  }
    
    








  sub generate_default_hdl_config
  {
  	(my $module_name, my $module_file_name, my $sys_clk_freq, my $file_ext) = @_;

    
    

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
    
