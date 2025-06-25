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
use ptf_parse;
use europa_all;

sub parse_args
{
  my $arg;
  my $argVal;
  my $argc;
  my %hash;

  $argc = 0;


  while($arg = shift)
  {
    usage() if $arg eq "--help";

    if($arg =~ /^--/)
    {
      if($arg =~ /^--(.*)\=(.*)$/)
      {
        $arg = $1;
        $argVal = $2;
      }
      elsif($arg =~ /^--(.*)$/)
      {
        $arg = $1;
        $argVal = 1;
      }

      $hash{$arg} = $argVal;
    }
    else
    {
      $hash{$argc++} = $arg;
    }
  }

  $hash{_argc} = $argc;

  return \%hash;
}











my $project = e_project->new(@ARGV);



    my $switches = &parse_args (@ARGV);
    my $PTFfileName = $switches->{system_directory}."/".$switches->{system_name}.".ptf";
    my $moduleName = $switches->{target_module_name};


    my $ptf = &new_ptf_from_file ($PTFfileName);
    die ("Error: Unable to read PTF file ($PTFfileName)!") if ($ptf eq "");


    my $module = &get_child_by_path ($ptf,"SYSTEM\/MODULE $moduleName",0);
    die ("Error: No such module ($moduleName) in file $PTFfileName!") if ($module eq "");

    my $hdl_mod = &get_data_by_path ($module, "WIZARD_SCRIPT_ARGUMENTS\/Module_Name", 0);
    my $instantiate_in_system = &get_data_by_path ($module, "SYSTEM_BUILDER_INFO\/Instantiate_In_System_Module", 0);



    my $port_wiring = &get_child_by_path ($module, "SLAVE avalonS\/PORT_WIRING", 1);
    my $num_ports = &get_child_count ($port_wiring);
    my $is_enabled = &get_child_by_path ($module, 
    	"SLAVE avalonS\/SYSTEM_BUILDER_INFO\/Is_Enabled",0);

    if (($num_ports eq 0) && ($is_enabled eq 1))
    {

        my $slave_ptf = &get_child_by_path ($module, "SLAVE avalonS",0);
        die ("Error: No slave section in module ($moduleName) in file $PTFfileName!") 
            if ($slave_ptf eq "");
  
          my $sbi_ptf = &get_child_by_path ($slave_ptf,"SYSTEM_BUILDER_INFO",0);
          die ("Error: No SBI section in module ($moduleName)".
                " in file $PTFfileName!") if ($sbi_ptf eq "");
          my %sbi_info;
          $sbi_info{Address_Width}=&get_data_by_path($sbi_ptf,"Address_Width");
          $sbi_info{Data_Width} =  &get_data_by_path ($sbi_ptf, "Data_Width");
          $sbi_info{Has_IRQ} = &get_data_by_path ($sbi_ptf, "Has_IRQ");
          $sbi_info{Is_Memory_Device} = &get_data_by_path ($sbi_ptf, "Is_Memory_Device");



          $sbi_info{Uses_Tri_State_Data_Bus} = 
              (&get_data_by_path ($sbi_ptf,"Bus_Type") =~ /^avalon_tristate$/i);
          $sbi_info{Read_Wait_States} = &get_data_by_path ($sbi_ptf, "Read_Wait_States");
      
      
      

          my $port = get_child_by_path ($port_wiring, "PORT clk", 1);
          add_child_data ($port, "type", "clk");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", "1");
      
          $port = get_child_by_path ($port_wiring, "PORT reset_n", 1);
          add_child_data ($port, "type", "resetn");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", "1");
      
          $port = get_child_by_path ($port_wiring, "PORT chipselect", 1);
          add_child_data ($port, "type", "chipselect");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", "1");
      
          $port = get_child_by_path ($port_wiring, "PORT write_n", 1);
          add_child_data ($port, "type", "write_n");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", "1");
      
          $port = get_child_by_path ($port_wiring, "PORT read_n", 1);
          add_child_data ($port, "type", "read_n");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", "1");
      
          $port = get_child_by_path ($port_wiring, "PORT address", 1);
          add_child_data ($port, "type", "address");
          add_child_data ($port, "direction", "input");
          add_child_data ($port, "width", $sbi_info{Address_Width});
      
          if ($sbi_info{Has_IRQ})
          {
              $port = get_child_by_path ($port_wiring, "PORT irq", 1);
              add_child_data ($port, "type", "irq");
              add_child_data ($port, "direction", "output");
              add_child_data ($port, "width", "1");
          }
      
          if ($sbi_info{Is_Memory_Device} && $sbi_info{Data_Width} >= 16)
          {
              $port = get_child_by_path ($port_wiring, "PORT byteenable_n", 1);
              add_child_data ($port, "type", "byteenable_n");
              add_child_data ($port, "direction", "input");
              add_child_data ($port, "width", ($sbi_info{Data_Width}/8) );
          }
      
          if ($sbi_info{Uses_Tri_State_Data_Bus})
          {
              $port = get_child_by_path ($port_wiring, "PORT data", 1);
              add_child_data ($port, "type", "data");
              add_child_data ($port, "direction", "inout");
              add_child_data ($port, "width", $sbi_info{Data_Width});
              add_child_data ($port, "is_shared", "1");
              $port = get_child_by_path ($port_wiring, "PORT outputenable", 1);
              add_child_data ($port, "type", "outputenable");
              add_child_data ($port, "direction", "input");
              add_child_data ($port, "width", "1");
              $port = get_child_by_path ($port_wiring, "PORT address", 1);
              add_child_data ($port, "is_shared", "1");
          }
          else
          {
              $port = get_child_by_path ($port_wiring, "PORT readdata", 1);
              add_child_data ($port, "type", "readdata");
              add_child_data ($port, "direction", "output");
              add_child_data ($port, "width", $sbi_info{Data_Width});
              $port = get_child_by_path ($port_wiring, "PORT writedata", 1);
              add_child_data ($port, "type", "writedata");
              add_child_data ($port, "direction", "input");
              add_child_data ($port, "width", $sbi_info{Data_Width});
          }
      
          if ($sbi_info{Read_Wait_States} eq "peripheral_controled")
          {
              $port = get_child_by_path ($port_wiring, "PORT waitrequest_n", 1);
              add_child_data ($port, "type", "waitrequest_n");
              add_child_data ($port, "direction", "output");
              add_child_data ($port, "width", "1");
          }


          write_ptf_file ($ptf);
    } 
    elsif ($instantiate_in_system)
    {



       my $Mod = $project->spaceless_module_ptf();
       my $pw = $project->spaceless_module_ptf()
           ->{PORT_WIRING}{PORT};





       my @ports = map 
       {
          my $a = $pw->{$_};
          $a->{name} = $_;
          $a;
       } keys(%$pw);
       
       my $slave_ref = $project->spaceless_module_ptf()
           ->{SLAVE};
       foreach my $s (values (%$slave_ref))
       {
	 next if ($s->{SYSTEM_BUILDER_INFO}{Is_Enabled} eq '0');
          my $ptf_ports = $s->{PORT_WIRING}{PORT};

          push (@ports, 
                map 
                {
                   my $a = $ptf_ports->{$_};
                   $a->{name} = $_;
                   $a;
                } keys(%$ptf_ports)
                );
       }

       my $master_ref = $project->spaceless_module_ptf()
           ->{MASTER};
       foreach my $m (values (%$master_ref))
       {
	 next if ($m->{SYSTEM_BUILDER_INFO}{Is_Enabled} eq '0');
          my $ptf_ports = $m->{PORT_WIRING}{PORT};
          push (@ports, 
                map 
                {
                   my $a = $ptf_ports->{$_};
                   $a->{name} = $_;
                   $a;
                } keys(%$ptf_ports)
                );
       }
       
       my $simulate_this = $project->WSA()->{Simulate_Imported_HDL}; 

       my $inst = e_instance->new
           ({
              name => "wrapper",
              module=> e_module->new ({
                  name => $hdl_mod,
                  contents => 
                      [
                      map 
                      {
                          e_port->new
                              ({
                                name      => $_->{name},
                                width     => $_->{width},
                                direction => $_->{direction},
                              }),
                      } @ports,
                      ],
                  _hdl_generated => 1,
                  _explicitly_empty_module => !($simulate_this),


                  do_black_box => !($simulate_this),
              }),
              tag  => ($simulate_this ? "normal" : "synthesis"),
           })->within($project->top());
       

       $project->_verbose(1);
       $project->do_write_ptf(0);
       
       my @synth_files = ();








       push (@synth_files, 
            $project->module_ptf()->{HDL_INFO}{Imported_HDL_Files})
          if ($simulate_this); 





       push (@synth_files, $project->hdl_output_filename());
       
       $project->module_ptf()->{HDL_INFO}{Synthesis_HDL_Files} = 
           join (",", @synth_files);
       
       $project->ptf_to_file();
       $project->output();
    } else {






    }
