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






















package em_cf_qsys;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_em_cf
);

use europa_all;
use europa_utils;
use strict;

my $clock_speed;
my $debounce_count;
my $debounce_width;









sub make_em_cf
{
  my ($module,$Options) = (@_);
  

  $clock_speed = $Options->{clock_speed};
  $debounce_count = &ceil($clock_speed / 1000); 
  $debounce_width = &ceil(&log2($debounce_count));
  
  my $marker = e_default_module_marker->new($module);
  
  my @common_ports = (
    [clk                  => 1,   "in" ],
    [av_reset_n           => 1,   "in" ],
  );

  my @ctl_ports = (
    [av_ctl_address       => 2,   "in"    ],
    [av_ctl_chipselect_n  => 1,   "in"    ],
    [av_ctl_irq           => 1,   "out"   ],
    [av_ctl_read_n        => 1,   "in"    ],
    [av_ctl_readdata      => 4,   "out"   ],
    [av_ctl_write_n       => 1,   "in"    ],
    [av_ctl_writedata     => 4,   "in"    ],
  ); 

  my @ide_ports = (
    [av_ide_address       => 4,   "in"    ],
    [av_ide_chipselect_n  => 1,   "in"    ],
    [av_ide_irq           => 1,   "out"   ],
    [av_ide_read_n        => 1,   "in"    ],
    [av_ide_readdata      => 16,  "out"   ],
    [av_ide_write_n       => 1,   "in"    ],
    [av_ide_writedata     => 16,  "in"    ],
    [addr                 => 11,  "out"   ],
    [atasel_n             => 1,   "out"   ],
    [cs_n                 => 2,   "out"   ], 
    [data_cf              => 16,  "inout" ],
    [detect_n             => 1,   "in"    ],
    [intrq                => 1,   "in"    ],
    [iordy                => 1,   "in"    ],
    [iord_n               => 1,   "out"   ],
    [iowr_n               => 1,   "out"   ],
    [power                => 1,   "out"   ],
    [reset_n_cf           => 1,   "out"   ],
    [rfu                  => 1,   "out"   ],
    [we_n                 => 1,   "out"   ],
  );

  e_port->adds(@common_ports);
  e_port->adds(@ctl_ports);
  e_port->adds(@ide_ports);

  my $ctl_type_map = {
    clk                 => "clk",
    av_reset_n          => "reset_n",
    av_ctl_address      => "address",
    av_ctl_chipselect_n => "chipselect_n",
    av_ctl_irq          => "irq",
    av_ctl_read_n       => "read_n",
    av_ctl_readdata     => "readdata",
    av_ctl_write_n      => "write_n",
    av_ctl_writedata    => "writedata",
  };

  my $ide_type_map = {
    clk                 => "clk",
    av_reset_n          => "reset_n",
    av_ide_address      => "address",
    av_ide_chipselect_n => "chipselect_n",
    av_ide_irq          => "irq",
    av_ide_read_n       => "read_n",
    av_ide_readdata     => "readdata",
    av_ide_write_n      => "write_n",
    av_ide_writedata    => "writedata",
    addr                => "export",
    atasel_n            => "export",
    cs_n                => "export",
    data_cf             => "export",   
    detect              => "export",
    intrq               => "export",
    iordy               => "export",
    iord_n              => "export",
    iowr_n              => "export",
    power               => "export",
    reset_n_cf          => "export",
    rfu                 => "export",
    we_n                => "export",
  };

  e_avalon_slave->add({
      name     => "ctl",
      type_map => $ctl_type_map,
  }); 

  e_avalon_slave->add({
      name     => "ide",
      type_map => $ide_type_map,
  }); 
  



  e_assign->adds(
    ["atasel_n",        "1'b0"],
    ["we_n",            "1'b1"],
    ["rfu",             "1'b1"],
    ["addr[10:3]",      "8'h00"],
    ["addr[2:0]",       "av_ide_address[2:0]"],
    ["iord_n",          "av_ide_read_n"],
    ["iowr_n",          "av_ide_write_n"], 
  );





  e_assign->adds(
    ["cs_n[0]",
      "~av_ide_chipselect_n ? (~av_ide_address[3] ? 1'b0 : 1'b1) : 1'b1"],

    ["cs_n[1]", 
      "~av_ide_chipselect_n ? ( av_ide_address[3] ? 1'b0 : 1'b1) : 1'b1"],
  );







  e_assign->adds(
    ["av_ide_readdata", "present_reg ? data_cf : 16'hFFFF"],
    ["data_cf", "(~av_ide_write_n && present_reg) ? av_ide_writedata :16'hZZZZ"],
  );
  





  e_assign->adds(
    ["power", "(power_reg && present_reg) ? 1'b1 : 1'b0"],
  );
  












  e_assign->adds(
    ["reset_n_cf", "(reset_reg || ~av_reset_n || ~present_reg) ? 1'b0 : 1'b1"],
  );






  e_assign->adds(
    ["av_ide_irq", "(ide_irq_en_reg && present_reg) ? intrq : 1'b0"],
  );
































  e_assign->adds(
    ["ctl_lo_write_strobe", "~av_ctl_chipselect_n && ~av_ctl_write_n && 
      (av_ctl_address == 4'h0)"],
      
    ["ctl_hi_write_strobe", "~av_ctl_chipselect_n && ~av_ctl_write_n &&
      (av_ctl_address == 4'h1)"],
  );
  



  e_register->add({
    out         => e_signal->add(["ctl_irq_en_reg", 1]),
    in          => "av_ctl_writedata[3]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });
   
  e_register->add({
    out         => e_signal->add(["reset_reg", 1]),
    in          => "av_ctl_writedata[2]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });  
  
  e_register->add({
    out         => e_signal->add(["power_reg", 1]),
    in          => "av_ctl_writedata[1]",
    enable      => "ctl_lo_write_strobe",
    async_value => 0,
   });  
  
  e_register->add({
    out         => e_signal->add(["ide_irq_en_reg", 1]),
    in          => "av_ctl_writedata[0]",
    enable      => "ctl_hi_write_strobe",
    async_value => 0,
   });  
    
  




  my @ctl_reg_zero_bits = ();  
  push (@ctl_reg_zero_bits,
    "ctl_irq_en_reg", 
    "reset_reg", 
    "power_reg", 
    "present_reg",
  );
  
  my @ctl_reg_one_bits = ();
  push (@ctl_reg_one_bits,
    "3'h0",
    "ide_irq_en_reg",
  );
  

  my $ctl_read_mux;
  $ctl_read_mux = e_mux->add({
    lhs     => e_signal->add(["ctl_read_mux", 4]),
    selecto => "av_ctl_address",
    table   => [
      "2'b00" => &concatenate(@ctl_reg_zero_bits),
      "2'b01" => &concatenate(@ctl_reg_one_bits),
      "2'b10" => "4'h0",
      "2'b11" => "4'h0",
      ],
  });


  e_register->add({
    out         => "av_ctl_readdata",
    in          => "ctl_read_mux",
    async_value => 0,
    enable      => 1,
  });


























  

  e_register->add({
    out         => e_signal->add(["present_counter", $debounce_width]),
    in          => "present_counter + 1",
    enable      => 1,
    async_value => 0,
    sync_reset  => "detect_n",
  });
  

  e_register->add({
    out         => e_signal->add(["present_reg", 1]),
    sync_set    => "present_counter == $debounce_count",
    sync_reset  => "detect_n",
    async_value => 0,
    enable      => 1,
  }); 
  

  e_register->add({
    out         => e_signal->add(["d1_present_reg", 1]),
    in          => "present_reg",
    async_value => 0,
    enable      => 1,
  }); 


  e_assign->adds(
    ["ctl_lo_read_strobe", "~av_ctl_chipselect_n && ~av_ctl_read_n && 
      (av_ctl_address == 4'h0)"],
  );



  e_register->add({
    out         => "av_ctl_irq",
    sync_set    => "(d1_present_reg ^ present_reg)",
    sync_reset  => "ctl_lo_read_strobe",
    async_value => 0,
    enable      => "ctl_irq_en_reg",
  });

  e_assign->adds({
      lhs => {name => "reset_n", never_export => 1,},
      rhs => "av_reset_n",
  });
};

1;
