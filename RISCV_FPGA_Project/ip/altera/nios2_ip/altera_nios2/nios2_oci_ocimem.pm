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






















use cpu_utils;
use cpu_file_utils;
use nios_sp_ram;
use nios2_insts;
use nios2_control_regs;
use europa_all;
use strict;

sub make_nios2_ocimem
{
  my $Opt = shift;

  my $module = e_module->new ({
      name    => $Opt->{name}."_nios2_ocimem",
  });



  $module->add_contents (

    e_signal->news (
      ["ociram_readdata",       32,   1],
      ["MonDReg",               32,   1],
      ["waitrequest",           1,    1],
    ),

    e_signal->news (
      ["read",                  1,    0],
      ["write",                 1,    0],
      ["address",               9,    0],
      ["writedata",             32,   0],
      ["byteenable",            4,    0],
      ["ir",            $IR_WIDTH,    0],
      ["jdo",           $SR_WIDTH,    0],
      ["reset",                 1,    0],
    ),



    e_signal->news (
      ["MonAReg",               11,   0],  # low 2 bits will be optimzed out
    ),
    
  );



























   my $oci_sram_access = {
      clock     => "clk",
      reset     => "jrst_n",
      asynchronous_contents => [
        e_assign->news (
          ["jtag_rd" => "1'b0"],            # JTAG reading RAM or config ROM
          ["jtag_rd_d1" => "1'b0"],         # One cycle after reading RAM/ROM
          ["jtag_ram_wr" => "1'b0"],        # JTAG writing RAM
          ["jtag_ram_rd" => "1'b0"],        # JTAG reading RAM
          ["jtag_ram_rd_d1" => "1'b0"],     # One cycle after JTAG reading RAM
          ["jtag_ram_access" => "1'b0"],    # JTAG reading or writing RAM
          ["MonAReg" => "0"],
          ["MonDReg" => "0"],
          ["waitrequest" => "1'b1"],          # Make Avalon wait until read/write ready.




          ["avalon_ociram_readdata_ready" => "1'b0"], 
        ),
      ],
      contents  => [
        e_if->new ({ condition => "take_no_action_ocimem_a", then => [ 
            ["MonAReg[10:2]" => "MonARegAddrInc"],                  # preincrement
            ["jtag_rd" => "1'b1"],                                  # request RAM/ROM read 
            ["jtag_ram_rd" => "MonARegAddrIncAccessingRAM"],        # request RAM read
            ["jtag_ram_access" => "MonARegAddrIncAccessingRAM"],    # request RAM access
        ], else => [ e_if->new ({ condition => "take_action_ocimem_a", then => [ 
            ["MonAReg[10:2]" =>
              "{ jdo[$OCIMEM_A_ADDR_A10_POS],
                 jdo[$OCIMEM_A_ADDR_A9_POS:$OCIMEM_A_ADDR_A2_POS] }"],
            ["jtag_rd" => "1'b1"],                                  # request RAM/ROM read 
            ["jtag_ram_rd" => "~jdo[$OCIMEM_A_ADDR_A10_POS]"],      # request RAM read
            ["jtag_ram_access" => "~jdo[$OCIMEM_A_ADDR_A10_POS]"],  # request RAM access
        ], else => [ e_if->new ({ condition => "take_action_ocimem_b", then => [
            ["MonAReg[10:2]" => "MonARegAddrInc"],                 # preincrement
            ["MonDReg" => "jdo[$OCIMEM_B_WRDATA_MSB_POS:$OCIMEM_B_WRDATA_LSB_POS]"],
            ["jtag_ram_wr" => "MonARegAddrIncAccessingRAM"],        # request RAM write
            ["jtag_ram_access" => "MonARegAddrIncAccessingRAM"],    # request RAM access
        ], else => [ 
            e_assign->news (


                ["jtag_rd" => "0"],
                ["jtag_ram_wr" => "0"],
                ["jtag_ram_rd" => "0"],
                ["jtag_ram_access" => "0"],
            ),




            e_if->new ({ condition => "jtag_rd_d1", then => [ 
                e_assign->new (
                  ["MonDReg" => "jtag_ram_rd_d1 ? ociram_readdata : cfgrom_readdata"]
                ),
            ],}),
        ], # end else
        }),],  # end else if take_action_ocimem_b
        }),],  # end else if take_action_ocimem_a
        }),    # end if take_no_action_ocimem_a

        e_assign->new(["jtag_rd_d1" => "jtag_rd"]),
        e_assign->new(["jtag_ram_rd_d1" => "jtag_ram_rd"]),

        e_if->new ({ condition => "~waitrequest", then => [ 

            ["waitrequest" => "1'b1"],




            ["avalon_ociram_readdata_ready" => "1'b0"],
        ], elsif => { condition => "write", then => [ 



            ["waitrequest" => "~address[$DBG_SLAVE_ADDR_MSB] & jtag_ram_access"],
        ], elsif => { condition => "read", then => [ 


            ["avalon_ociram_readdata_ready" => "~(~address[$DBG_SLAVE_ADDR_MSB] & jtag_ram_access)"],


            ["waitrequest" => "~avalon_ociram_readdata_ready"],
        ], else => [ 




            ["waitrequest" => "1'b1"],


            ["avalon_ociram_readdata_ready" => "1'b0"],
        ], # end else
        }, # end elsif write
        }, # end elsif read
        }),# end if ~waitrequest
      ], # end sync contents
  };

  if (!manditory_bool($Opt, "export_large_RAMs")) {
    $oci_sram_access->{user_attributes_names} = 
      ["MonDReg, MonAReg, avalon_ociram_readdata_ready, jtag_ram_rd, jtag_ram_wr"];
    $oci_sram_access->{user_attributes} = [
      {
          attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
          attribute_operator => '=',
          attribute_values => [qw(D101 D103 R101)],
      }
    ];
  }

  $module->add_contents ( 
    e_process->new ($oci_sram_access ),

    e_assign->news (

      [["MonARegAddrInc", 9] => "MonAReg[10:2]+1"],


      [["MonARegAddrIncAccessingRAM", 1] => "~MonARegAddrInc[$DBG_SLAVE_ADDR_MSB]"],



      [["avalon_ram_wr", 1] => "write & ~address[$DBG_SLAVE_ADDR_MSB] & debugaccess"],




      [["ociram_addr", 8] => "jtag_ram_access ? MonAReg[9:2] : address[7:0]"],
      [["ociram_wr_data", 32] => "jtag_ram_access ? MonDReg[31:0] : writedata"],
      [["ociram_byteenable", 4] => "jtag_ram_access ? 4'b1111 : byteenable"],
      [["ociram_wr_en", 1] => "jtag_ram_access ? jtag_ram_wr : avalon_ram_wr"],
    ),
  );

  my $ram_contents_basename = $Opt->{name} . "_ociram_default_contents";
  my $ram_data_width = 32;
  my $ram_num_entries = 256;
  my $ram_addr_width = 8;
  
  if (manditory_bool($Opt, "export_large_RAMs")) {
    $module->add_contents ( 
      e_comment->new({
        comment => 
           ("Export OCI RAM ports to top level\n" .
            "because the RAM is instantiated external to CPU.\n"),
      }),
      e_assign->news (

        [["cpu_lpm_oci_ram_sp_address", 8] => "ociram_addr"],
        [["cpu_lpm_oci_ram_sp_write_data", 32] => "ociram_wr_data"],
        [["cpu_lpm_oci_ram_sp_byte_enable", 4] => "ociram_byteenable"],
        [["cpu_lpm_oci_ram_sp_write_enable", 1] => "ociram_wr_en"],
  

        ["ociram_readdata" => ["cpu_lpm_oci_ram_sp_read_data", 32]],
      ),
    );
  } else {
    $module->add_contents ( 
      nios_sp_ram->new ({
        name => $Opt->{name} . "_ociram_sp_ram",
        Opt                     => $Opt,
        data_width              => $ram_data_width,
        address_width           => $ram_addr_width,
        num_words               => $ram_num_entries, 
        contents_file           => $ram_contents_basename,
        ram_block_type          => qq("$Opt->{oci_mem_ram_type}"),
        port_map => {
          clock      => "clk",
          reset_req  => "reset_req",
          address    => "ociram_addr",
          wren       => "ociram_wr_en",
          data       => "ociram_wr_data",
          byteenable => "ociram_byteenable",
          q          => "ociram_readdata",
        },
      }),
    );
  }

  my $do_build_sim = manditory_bool($Opt, "do_build_sim");
  my $simulation_directory = 
    $do_build_sim ? not_empty_scalar($Opt, "simulation_directory") : undef;

  make_contents_file_for_ram({
    filename_no_suffix        => $ram_contents_basename,
    data_sz                   => $ram_data_width,
    num_entries               => $ram_num_entries,
    value_str                 => "random",
    clear_hdl_sim_contents    => 0,
    do_build_sim              => $do_build_sim,
    simulation_directory      => $simulation_directory,
    system_directory          => not_empty_scalar($Opt, "system_directory"),
  });



  $module->add_contents ( 
    e_mux->new ({
      lhs => ["cfgrom_readdata", 32],
      selecto => "MonAReg[4:2]",
      table => make_cfgrom_table($Opt),
    }),
  );

  return $module;
}



sub 
make_cfgrom_table
{
  my $Opt = shift;



  my %bytes = ();

  my $mmu = $Opt->{mmu_present};
  my $mpu = $Opt->{mpu_present};
  my $onchip_trace = $Opt->{oci_onchip_trace};


  $bytes{0x0} = ($Opt->{general_exception_addr} >> 0 ) & 0xff;
  $bytes{0x1} = ($Opt->{general_exception_addr} >> 8 ) & 0xff;
  $bytes{0x2} = ($Opt->{general_exception_addr} >> 16) & 0xff;
  $bytes{0x3} = ($Opt->{general_exception_addr} >> 24) & 0xff;

  $bytes{0x4} = $Opt->{i_Address_Width};          # instr master width
  $bytes{0x5} = $Opt->{d_Address_Width};          # data master width
  $bytes{0x6} = $Opt->{oci_num_dbrk};             # number of dbrks
  $bytes{0x7} = $Opt->{oci_num_xbrk};             # number of xbrks

  $bytes{0x8} = $Opt->{oci_dbrk_trace};           # dbrk start trace?
  $bytes{0x9} = $Opt->{oci_dbrk_pairs};           # dbrk support pairs?
  $bytes{0xa} = #  width --v        v--- bit offset
    (($Opt->{oci_data_trace}  & 0x01    ) << 0) | # OCI have data trace?
    (($Opt->{big_endian}                ) << 1) | # big endian processor?
    ((defined($cpuid_reg)               ) << 2) | # CPUID register present?
    (($mmu                              ) << 3) | # MMU present?
    (($mpu                              ) << 4) | # MPU present?
    (($mpu ? $Opt->{mpu_use_limit} : 0  ) << 5) | # MPU uses LIMIT (not MASK)
    (($Opt->{extra_exc_info}            ) << 6);  # EXCEPTION/BADADDR present?
  $bytes{0xb} = $Opt->{oci_offchip_trace} ;  # have offchip trace?

  $bytes{0xc} = 
    (                            
      $onchip_trace ? $Opt->{oci_trace_addr_width} :    # Log2 num bytes
                      0
    ) & 0xff;   
  $bytes{0xd} = 
    ($TRACE_VERSION_1 << 0) |  # Trace version 1
    (((
      $mpu ? ($Opt->{mpu_num_inst_regions}-1) : # 1-32 regions (coded 0-31)
             0
      ) & 0x1f ) << 3);
  $bytes{0xe} = 
    (((
      $mmu ? $Opt->{tlb_ptr_sz} :               # width of tlb addr (log2)
      $mpu ? ($Opt->{mpu_min_inst_region_size_log2}-5) : # 6-20 (coded 1-15)
             0
      ) & 0x0f ) << 0) | 
    (((
      $mmu ? count2sz($Opt->{tlb_num_ways}) :  # number of tlb ways 
      $mpu ? ($Opt->{mpu_min_data_region_size_log2}-5) : # 6-20 (coded 1-15)
             0
      ) & 0x0f ) << 4);  
  $bytes{0xf} = 
    (((
      $mpu ? ($Opt->{mpu_num_data_regions}-1) : # 1-32 region (coded 0-31)
             0
      ) & 0x1f ) << 0);
                                                      

  $bytes{0x10} = $Opt->{cache_has_icache} ?         # how much inst cache? 
                    count2sz($Opt->{cache_icache_size}) 
                     : 0;       
  $bytes{0x11} = $Opt->{cache_has_dcache} ?         # how much data cache? 
                    count2sz($Opt->{cache_dcache_size}) 
                     : 0;       
  $bytes{0x12} = $Opt->{oci_num_pm};               # how many pms
  $bytes{0x13} = $Opt->{oci_pm_width};             # width of pms


  $bytes{0x14} = ($Opt->{reset_addr} >> 0 ) & 0xff; # reset address
  $bytes{0x15} = ($Opt->{reset_addr} >> 8 ) & 0xff;
  $bytes{0x16} = ($Opt->{reset_addr} >> 16) & 0xff;
  $bytes{0x17} = ($Opt->{reset_addr} >> 24) & 0xff;


  $bytes{0x18} = ($Opt->{fast_tlb_miss_exception_addr} >> 0 ) & 0xff;
  $bytes{0x19} = ($Opt->{fast_tlb_miss_exception_addr} >> 8 ) & 0xff;
  $bytes{0x1a} = ($Opt->{fast_tlb_miss_exception_addr} >> 16) & 0xff;
  $bytes{0x1b} = ($Opt->{fast_tlb_miss_exception_addr} >> 24) & 0xff; 


  $bytes{0x1c} = 
    (manditory_int($Opt, "num_shadow_reg_sets") << 0) |
    (manditory_bool($Opt, "eic_present") << 6);


  $bytes{0x1d} = 0;
  $bytes{0x1e} = 0;
  $bytes{0x1f} = 0;


  my @cfgrom_table;
  for (my $cfgdout_waddr = 0; $cfgdout_waddr < 8; $cfgdout_waddr++) {

    my $baddr = $cfgdout_waddr * 4; 


    my $wval =
      (($bytes{$baddr+0} << 0) |
       ($bytes{$baddr+1} << 8) |
       ($bytes{$baddr+2} << 16) |
       ($bytes{$baddr+3} << 24));

    my $whex = sprintf("32'h%08x", $wval);


    push(@cfgrom_table, "3'd" . $cfgdout_waddr => $whex);
  }

  return \@cfgrom_table;
}

1;
