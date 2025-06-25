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




my $project = e_project->new(@ARGV);
my $module = $project->top();
my %Options = %{$project->WSA()};
my $WSA = \%Options;




my $marker = e_default_module_marker->new($module);





my $slave = $project->module_ptf()->{"SLAVE s1"};
my $data_width = $project->SBI("s1")->{Data_Width};
my $address_width = $project->SBI("s1")->{Address_Width};
my $byte_enable_width = int($data_width / 8);
my $chip_enable_width = 3;



if (!$project->module_ptf()->{SYSTEM_BUILDER_INFO}{Make_Memory_Model}) 
{
  return 0;
}
else
{


  &validate_parameter({
    hash => $WSA,
    name => "ssram_data_width",
    type => "integer",
    allowed => [16, 32],
  });
    

    

  my $lang = $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
  my $sim_file = $project->get_top_module_name();
  my $sim_dat  = $project->_target_module_name() . ".dat";
  if ($lang =~ /vhd/i    ) { $sim_file .= ".vhd"; }
  if ($lang =~ /verilog/i) { $sim_file .= ".v"; }
  
  $module->add_contents
  (
    e_ram->new
    ({
      comment => "Synchronous write when (CODE == $STR__WR (write))",
      name => $project->get_top_module_name() . "_ram",
      Read_Latency => "2",
      dat_file => $sim_dat,
      port_map =>
      {
        wren => "~bwe_n",
        data => "",
        q    => "",
        wrclock => "",
        wraddress=>"",
        rdaddress=>"",
      }
    }),
  );

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
          {name => "zs_ba",    width => $WSA->{sdram_bank_width}},
          {name => "zs_addr",  width => $WSA->{sdram_addr_width}},
          {name => $dq,        width => $WSA->{sdram_data_width},
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
          {name => "ba",    width => $WSA->{sdram_bank_width}},
          {name => "a",     width => $WSA->{sdram_addr_width}},
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
    

  
  


  $project->output();
} # else Make_Memory_Model
    

