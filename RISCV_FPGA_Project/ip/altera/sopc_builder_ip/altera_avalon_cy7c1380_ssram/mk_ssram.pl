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
my $Opt = &copy_of_hash ($project->WSA());




my $marker = e_default_module_marker->new($module);





my $slave = $project->module_ptf()->{"SLAVE s1"};
my $slave_sbi = $slave->{SYSTEM_BUILDER_INFO};
my $data_width = $project->SBI("s1")->{Data_Width};
my $address_width = $project->SBI("s1")->{Address_Width};
my $byte_enable_width = int($data_width / 8);
my $chip_enable_width = 1;




$slave_sbi->{Read_Latency} = $Opt->{ssram_read_latency};
  





my $use_tri_state_bridge = 1;






if($use_tri_state_bridge) 
{

  my @port_list = 
     (
        e_port->new(
        {
           name      => 'address',
           width     => $address_width,
           direction => "input",
           type      => "address",
        }),
        e_port->new(
        {
           name      => 'adsc_n',
           width     => "1",
           direction => "input",
           type      => "begintransfer_n",
        }),
        e_port->new(
        {
           name      => 'bw_n',
           width     => $byte_enable_width,
           direction => "input",
           type      => "byteenable_n",
        }),
        e_port->new(
        {
           name      => 'bwe_n',
           width     => 1,
           direction => "input",
           type      => "write_n",
        }),
        e_port->new(
        {
           name      => 'chipenable1_n',
           width     => $chip_enable_width,
           direction => "input",
           type      => "chipselect_n",
        }),
        e_port->new(
        {
           name      => 'data',
           width     => $data_width,
           direction => "inout",
           type      => "data",
        }),
        e_port->new(
        {
           name      => 'outputenable_n',
           width     => 1,
           direction => "input",
           type      => "outputenable_n",
        }),




        e_port->new(
        {
           name      => 'clk',
           width     => 1,
           direction => "input",
           type      => "clk",
        }),
     );
  $module->add_contents(@port_list);
  



  if ($project->module_ptf()->{SYSTEM_BUILDER_INFO}{Make_Memory_Model}) {
      my $options = 
      { name => $project->_target_module_name(),
        make_individual_byte_lanes => 1,
        num_lanes => $byte_enable_width,
      };
      $project->do_makefile_target_ptf_assignments
          (
           's1',
           ['dat', 'sym',],
           $options,
           );
  } else { # Destroy memory model make instructions
      $project->do_makefile_target_ptf_assignments
          (
           '',
           [],
           );
  }; 



 $project->ptf_to_file(); 
} # if($future_ssram_comonent)








else {


  my @ports = (

      [av_address         => $address_width,    "in"    ],
      [av_begintransfer_n => 1,                 "in"    ],
      [av_byteenable_n    => $byte_enable_width,"in"    ],
      [av_chipselect_n    => 1,                 "in"    ], 
      [av_clk             => 1,                 "in"    ],
      [av_outputenable_n  => 1,                 "in"    ],
      [av_readdata        => $data_width,       "out"   ],
      [av_reset_n         => 1,                 "in"    ],
      [av_write_n         => 1,                 "in"    ],
      [av_writedata       => $data_width,       "in"    ],
      

      [address            => $address_width,    "out"   ],
      [adsc_n             => 1,                 "out"   ],
      [bw_n               => $byte_enable_width,"out"   ],    
      [bwe_n              => 1,                 "out"   ],
      [chipenable1_n      => 1,                 "out"   ], 
      [outputenable_n     => 1,                 "out"   ],
      [data               => $data_width,       "inout" ],
  ); 
  


  e_port->adds(@ports);
  


  my $s1_type_map = {
      av_address          => "address",
      av_begintransfer_n  => "begintransfer_n",
      av_byteenable_n     => "byteenable_n",
      av_chipselect_n     => "chipselect_n",
      av_clk              => "clk",
      av_outputenable_n   => "outputenable_n",
      av_readdata         => "readdata",
      av_reset_n          => "reset_n",
      av_write_n          => "write_n", 
      av_writedata        => "writedata",
      
      address             => "export",
      adsc_n              => "export",
      bw_n                => "export",
      bwe_n               => "export",
      chipenable1_n       => "export",
      outputenable_n      => "export",
      data                => "export",
  };
  


  e_avalon_slave->add({
      name        => "s1",
      type_map    => $s1_type_map,
  }); 
  


   e_assign->adds (["address",        "av_address"        ],
                   ["adsc_n",         "begintransfer_n"   ],
                   ["bw_n",           "av_byteenable_n"   ],
                   ["bwe_n",          "av_write_n"        ],
                   ["chipenable1_n",  "av_chipselect_n"   ],
                   ["outputenable_n", "av_outputenable_n" ],
                   );
  

   


  $project->output();
} # else ($use_tri_state_bridge)



