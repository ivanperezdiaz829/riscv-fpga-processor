#Copyright (C)2005 Altera Corporation
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
use e_parameter_assign;

#pass the command line argument to the project
my $proj = e_project->new();

my %command_hash;
my $key;
my $value;
foreach my $command (@ARGV)
{
   next unless ($command =~ /\-\-(\w+)\=(.*)/);

   $key = $1;
   $value = $2;

   $value =~ s/\\|\/$//; # crush directory structures which end with
   print ("Europa module processing argument \"$key=$value\"\n");
   $command_hash{$key} = $value;
};




#command line arguments
my $number_of_lanes = 4;
my $phy_selection = 0;
my $cvp=0;
my $refclk_selection = 0;
my $tl_selection = 0;
my $CG_AVALON_S_ADDR_WIDTH = 21;
my $lane_width = 1;
my $var = "pci_var";
my $language = "vhdl";
my $number_of_vcs = 2;
my $pipe_txclk = 0;
my $tlp_clk_freq = 0;
my $chk_io = 0;
my $common_clk = 0;
my $test_out_width = 9;
my $family = "Cyclone II";
my $ppx = "PCIExpressProtocolPlanner.ppx";
my $vpin = "vpin.tcl";
my $hip = 0;
my $rp = 0;
my $gen2_rate = 0;
my $ko_cpl_spc_vc = "ABCD";
my $enable_hip_dprio = 0;
my $s4gxes = 0;
my $c3gx = 0;
my $ast_lite = 0;
my $temp = $command_hash{"phy"};

my $aiigz=0;
if($temp ne "")
{
#  phy_selection =
#   MVCConstants.ARRIAII_GZ.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                   ? 9 :
#   MVCConstants.STRATIX_V_GX_CVP.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                             ? 8 :
#   MVCConstants.STRATIX_V_GX.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                 ? 7 :
#   (MODEL().getPrivate(MVCConstants.PARAM_ENABLE_HIP).getValue().equalsIgnoreCase("1"))                                    ? 6 :
#   MVCConstants.PIRANHA.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                      ? 6 :
#   MVCConstants.STINGRAY.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                     ? 6 :
#   MVCConstants.HCXIV.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                        ? 6 :
#   MVCConstants.STRATIX_IV_GX.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                ? 6 :
#   MVCConstants.STRATIX_IV_GX_ES.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                             ? 6 :
#   MVCConstants.STRATIX_GX.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())                                   ? 0 :
#   (MVCConstants.STRATIX_II_GX.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())
#    ||MVCConstants.STRATIX_II_GX_LITE.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY).getValue())       )                ? 2:
#   (MVCConstants.INTERFACE_8b_DDR.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY_INTERFACE).getValue())
#    ||MVCConstants.INTERFACE_8b_DDR_TX_CLK.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY_INTERFACE).getValue()) )       ? 3:
#   (MVCConstants.INTERFACE_8b_SDR.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY_INTERFACE).getValue())
#    ||MVCConstants.INTERFACE_8b_SDR_TX_CLK.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY_INTERFACE).getValue()) )       ?4:
#   MVCConstants.INTERFACE_8b_DDR_SDR_TX_CLK.equals(MODEL().getPrivate(MVCConstants.PARAM_PHY_INTERFACE).getValue())        ?5 :1;
   $phy_selection = $temp;
   if ($phy_selection ==8 ) { #Stratix 5 CVP
      $phy_selection = 7;
      $cvp=1;
   } elsif ($phy_selection ==9) {
      $phy_selection = 6;
      $aiigz=1;
   }
}

my $PHYSEL_SV   = 7;
my $PHYSEL_HIP_40nm  = 6;
my $PHYSEL_SIV  = 6;
my $PHYSEL_CIV  = 6;
my $PHYSEL_A2GZ = 9;

my $temp = $command_hash{"tlp_clk_freq"};
if($temp ne "")
{
   $tlp_clk_freq = $temp;
}

my $temp = $command_hash{"txclk"};
if($temp ne "")
{
   $pipe_txclk = $temp;
}

my $temp = $command_hash{"lanes"};
if($temp ne "")
{
   $number_of_lanes = $temp;
}

my $temp = $command_hash{"refclk"};
if($temp ne "")
{
   $refclk_selection = $temp;
}

my $temp = $command_hash{"vc"};
if($temp ne "")
{
   $number_of_vcs = $temp;
}

my $temp = $command_hash{"language"};
if($temp ne "")
{
   $language = $temp;
}

my $temp = $command_hash{"variation"};
if($temp ne "")
{
   $var = $temp;
}

my $temp = $command_hash{"chk_io"};
if($temp ne "")
{
   $chk_io = $temp;
}

my $temp = $command_hash{"family"};
if($temp ne "")
{
   $family = $temp;
}

my $temp = $command_hash{"tl_selection"};
if($temp ne "")
{
   # 0 - PLDA native
   # 1 - Full Avalon interface (CRA,TXS,RXM)
   # 2 - Partial Avalon interface (RXM)
   # 3 - Partial Avalon interface (TXS,RXM)
   # 4 - Partial Avalon interface (CRA,RXM)
   # 5 - Full Avalon interface (CRA,TXS,RXM - reserve for DMA)
   # 6 - HIPCAB
   # 7 - HIPCAB (128bit)
   # 8 - TL Bypass
   # 9 - 256 Bit unbonded mode


   $tl_selection = $temp;
}
my $TLSEL_AST256=9;
my $TLSEL_AST128=7;
my $TLSEL_AST64 =6;
my $TLSEL_BYPASS=8;

my $temp = $command_hash{"CG_AVALON_S_ADDR_WIDTH"};
if($temp ne "")
{
   $CG_AVALON_S_ADDR_WIDTH = $temp;
}

my $temp = $command_hash{"common_clk_mode"};
if($temp ne "")
{
   $common_clk = $temp;
}

my $temp = $command_hash{"test_out_width"};
if($temp ne "")
{
   $test_out_width = $temp;
}

my $temp = $command_hash{"hip"};
if($temp ne "")
{
   $hip = $temp;
}

my $temp = $command_hash{"rp"};
if($temp ne "")
{
   $rp = $temp;
}

my $temp = $command_hash{"gen2_rate"};
if($temp ne "")
{
   $gen2_rate = $temp;
}

my $temp = $command_hash{"ko_cpl_spc_vc"};
if($temp ne "")
{
   $ko_cpl_spc_vc = $temp;
}

my $temp = $command_hash{"enable_hip_dprio"};
if($temp ne "")
{
   $enable_hip_dprio = $temp;
}

my $temp = $command_hash{"s4gxes"};
if($temp ne "")
{
   $s4gxes = $temp;
}

my $temp = $command_hash{"ast_lite"};
if($temp ne "")
{
   $ast_lite = $temp;
}

# remove all quotes (windows do not have quotes, unix has quotes
$family =~ s/\"//g;
$family = "\"".$family."\"";
# To work around spaces in the argument
$family =~ s/_/ /g;
$family =~ s/_es//g; # remove S4GX ES suffix


##################################################
# sanity check
##################################################
if ($phy_selection == 0) { # Stratix GX
   if ($number_of_lanes > 4) {
      die "ERROR: Stratix GX PHY only supports x1 or x4\n";
   }
} elsif ($phy_selection == 1) { # PIPE 16 bits
   if ($number_of_lanes > 4) {
      die "ERROR: PIPE 16bits SDR  only supports x1 or x4\n";
   }
} elsif ($phy_selection == 2) { # Stratix II GX
} elsif ($phy_selection == 3) { # PIPE 8 bits DDR
} elsif ($phy_selection == 4) { # PIPE 8 bits SDR 250Mhz
} elsif ($phy_selection == 5) { # PIPE 8 bits DDR data/SDR ctrl
} elsif ($phy_selection == 6) { # Stratix 4, A2GX, C4GX
} elsif ($phy_selection == 7) { # Stratix 5
}


# check for stingray
if ($family =~ /cyclone iv/i) {
   $c3gx = 1;
}


# Add some comments
my $top_comment = "\$Revision: #1 $\\n";
if ($phy_selection == 0) {
   $top_comment .= "\nPhy type: Stratix GX";
} elsif ($phy_selection == 1) {
   $top_comment .= "\nPhy type: 16 Bit SDR 125Mhz PIPE";
} elsif ($phy_selection == 2) {
   $top_comment .= "\nPhy type: Stratix II GX";
} elsif ($phy_selection == 3) {
   $top_comment .= "\nPhy type: 8 Bit DDR 125Mhz PIPE";
} elsif ($phy_selection == 4) {
   $top_comment .= "\nPhy type: 8 Bit SDR 250Mhz PIPE";
} elsif ($phy_selection == 5) {
   $top_comment .= "\nPhy type: 8 Bit DDR 125Mhz PIPE (SDR Control)";
} elsif ($phy_selection == 6) {
   if ($c3gx == 0) {
      $top_comment .= "\nPhy type: Stratix IV GX";
   } else {
      $top_comment .= "\nPhy type: Cyclone IV GX";
   }
} elsif ($phy_selection == 7) {
   $top_comment .= "\nPhy type: Stratix V GX";
}

if ($hip == 0) {
   $top_comment .= " Soft IP ";
} else {
   $top_comment .= " Hard IP ";
}

$top_comment .= "\nNumber of Lanes: $number_of_lanes";

if ($refclk_selection == 0) {
   $top_comment .= "\nRef Clk Freq: 100Mhz";
} elsif ($refclk_selection == 1) {
   $top_comment .= "\nRef Clk Freq: 125Mhz";
} elsif ($refclk_selection == 2) {
   $top_comment .= "\nRef Clk Freq: 156.25Mhz";
}

$top_comment .= "\nNumber of VCs: $number_of_vcs";
if ($pipe_txclk) {
   $top_comment .= "\nProvides TX pipe clk";
}

if (($tlp_clk_freq) & ($number_of_lanes == 1)) {
   $top_comment .= "\nTransaction Layer runs at 62.5Mhz";
}



# declare top module
my $top_mod = e_module->new ({name => "$var", comment => "$top_comment"});

#processed variables
my $pipe_width = 16;
my $int_pipe_width = 16;
my $rxddio_width = 13;

##################################################
# clkin /out
##################################################
my $clkfreq_in = "clk125_in";
my $clkfreq_out = "clk125_out";


if ($hip == 1) {
   $clkfreq_in = "pld_clk";
} elsif ($number_of_lanes == 8) {
   $clkfreq_in = "clk250_in";
   $clkfreq_out = "clk250_out";
} else {
   $clkfreq_in = "clk125_in";
   $clkfreq_out = "clk125_out";
}

if (($tl_selection > 0) & ($tl_selection < 6)) { # SOPC mode, loop clk125_out back to clk125_in
   $add_signals .= "e_signal->new({name => $clkfreq_in, width=> 1, never_export => 1}),";
   if ($hip == 0) { # SIP
      if (($common_clk) & (($tl_selection > 0) & ($tl_selection < 6)) & ($tlp_clk_freq == 0)) {
         $glue_logic .= "e_assign->new ([$clkfreq_in => AvlClk_i]),";
      } else {
         $glue_logic .= "e_assign->new ([$clkfreq_in => $clkfreq_out]),";
      }
   } else {
      $add_signals .= "e_port->new([ clk125_out => 1 => \"output\"]),";
      $glue_logic .= "e_assign->new ([$clkfreq_out => core_clk_out]),";
      if (($common_clk) & (($tl_selection > 0) & ($tl_selection < 6)) & ($tlp_clk_freq == 0)) {
         $glue_logic .= "e_assign->new ([$clkfreq_in => AvlClk_i]),";
      } else {
         $glue_logic .= "e_assign->new ([$clkfreq_in => core_clk_out]),";
      }
   }

   # common clock mode, produce output clock and loop back AvlClk_i
   if ($common_clk) {
      $glue_logic .= "e_port->new([ pcie_core_clk => 1 => \"output\"]),";
      if ($number_of_lanes == 1) {
         $glue_logic .= "e_assign->new ([pcie_core_clk => app_clk]),";
      } else {
         $glue_logic .= "e_assign->new ([pcie_core_clk => $clkfreq_out]),";
      }



   }


}


##################################################
# clkin /out
##################################################
my $refclk = "1'b0";
my $clkfreq_out_q = "clkout_open";
$add_signals .= "e_signal->new({name => clkout_open, width=> 1, never_export => 1}),";

if ($phy_selection == 0) { # stratix GX
   if ($refclk_selection == 1) {
      $glue_logic .= "e_assign->new ([$clkfreq_out => refclk]),";
   } elsif ($refclk_selection == 2) {
      $refclk = "refclk";
      $clkfreq_out_q = "$clkfreq_out";
   }
} elsif ($phy_selection == 1) { # 16bit SDR mode
   if (!(($pipe_txclk == 0) | ($tlp_clk_freq != 0)))  { # 125Mhz SDR not needing PLL
      $glue_logic .= "e_assign->new ([$clkfreq_out => refclk]),";
   }
} elsif (($phy_selection == 4) & ($number_of_lanes > 4)) { # Dual phy 8bit SDR
   $glue_logic .= "e_assign->new ([$clkfreq_out => refclk]),";
} elsif ($hip == 1) { # Stratix IV GX + HIP
   $refclk = "refclk";
   $clkfreq_out_q = "$clkfreq_out";
}



##################################################
# reset input
##################################################
my $reset_in = " ";


if ($hip == 1) {
   $reset_in .= "srst => \"srst\",";
   $disable_rst = "| (ltssm == 5'h10)";
   if ($tl_selection != 8) { # not TL bypass
      $reset_in .= "crst => \"crst\",";
   } else {
      $reset_in .= "crst => \"1'b1\",";
   }
} elsif ($number_of_lanes == 8) {
   $reset_in .= "rstn => \"rstn\",";
} else {
   $reset_in .= "crst => \"crst\",";
   $reset_in .= "srst => \"srst\",";
}

my $reset_ports='';

if (($hip == 1)&&($phy_selection==$PHYSEL_SV)) {
   $reset_ports .= "e_port->new([perst_n            => 1 => \"input\"]),";
   $reset_ports .= "e_port->new([pld_clrhip_n       => 1 => \"input\"]),";
   $reset_ports .= "e_port->new([pld_clrpmapcship   => 1 => \"input\"]),";
   $reset_ports .= "e_port->new([pld_clk_ready      => 1 => \"input\"]),";
   $reset_ports .= "e_port->new([pld_clk_in_use     => 1 => \"output\"]),";
   $reset_ports .= "e_port->new([reset_status       => 1 => \"output\"]),";
   $reset_ports .= "e_port->new([dlup_exit          => 1 => \"output\"]),";
   $reset_ports .= "e_port->new([l2_exit            => 1 => \"output\"]),";
   $add_signals .= "e_signal->new({name => crst, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => npor, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => srst, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => hotrst_exit, width=> 1, never_export => 1}),";
   $glue_logic  .= "e_assign->new([npor => perst_n]),";
   $glue_logic  .= "e_assign->new([crst => \"~pld_clrhip_n\"]),";
   $glue_logic  .= "e_assign->new([srst => pld_clrpmapcship]),";
   $glue_logic  .= "e_assign->new({lhs  => \"reset_status\"  , rhs =>\"(hotrst_exit == 1'b0)  ? 1'b1 : 1'b0\"}),";
   $glue_logic  .= "e_assign->new({lhs  => \"pld_clk_in_use\", rhs =>\"(pld_clk_ready == 1'b1)? 1'b1 : 1'b0\"}),";
   if ($cvp==1) {
      $reset_in .= "hiphardreset => \"perst_n\",";
   }
}

##################################################
# test out plumbing
##################################################
my $test_out_int_width = 512;

if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm)) { # S4GX, A2GX, C4GX
   $test_out_int_width = 64;
} elsif (($hip == 1) & ($phy_selection == $PHYSEL_SV)) { # S5GX
   $test_out_int_width = 128;
} elsif ($number_of_lanes < 8) {
   $test_out_int_width = 512;
} else {
   $test_out_int_width = 128;
}

$add_signals .= "e_signal->new({name => test_out_int, width=>  $test_out_int_width, never_export => 1}),";
if ($test_out_width == 9) { # route out only LTSSM and width
   if ($hip == 1) {
      $test_out_ltssm = "ltssm";
      $test_out_lane = "lane_act";
      $glue_logic .= "e_port->new([ lane_act => 4 => \"output\"]),";
   } elsif ($number_of_lanes < 8) {
      $test_out_ltssm = "test_out_int[324:320]";
      $test_out_lane = "test_out_int[411:408]";
   } else {
      $test_out_ltssm = "test_out_int[4:0]";
      $test_out_lane = "test_out_int[91:88]";
   }
   $glue_logic .= "e_assign->new({lhs => {name => test_out}, rhs => \"{$test_out_lane,$test_out_ltssm}\"}),";

} elsif ($test_out_width > 0) { # full width
   $glue_logic .= "e_assign->new ([test_out  => test_out_int]),";
}

if ($hip == 1) { # always generate LTSSM port for HIP
   $glue_logic .= "e_port->new([ ltssm => 5 => \"output\"]),";
}


##################################################
# TLP Clock frequency selection
# 0 - 125Mhz
# 1 - 62.5Mhz
# 2 - 31.25Mhz
##################################################
my $tlp_clk_in = " ";

$tlp_clk_suffix = "62p5";

if ($number_of_lanes == 1) {
   if (($tl_selection == 0) | ($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) {
      $glue_logic .= "e_port->new([ app_clk => 1 => \"output\"]),";
   } else {
      $add_signals .= "e_signal->new({name => app_clk, width=> 1, never_export => 1}),";
   }

   if ($hip == 1) {
      if (($tl_selection > 0) & ($tl_selection < 6)) {
         $glue_logic .= "e_assign->new ([app_clk  => core_clk_out]),";
      } else {
         $glue_logic .= "e_assign->new ([app_clk  => pld_clk]),";
      }
   } elsif ($tlp_clk_freq == 0) { # 125Mhz
      if (($common_clk) & (($tl_selection > 0) & ($tl_selection < 6))) {
         $tlp_clk_in .= "tlp_clk => AvlClk_i,";
         $glue_logic .= "e_assign->new ([app_clk  => $clkfreq_out]),";
      } else {
         $tlp_clk_in .= "tlp_clk => $clkfreq_in,";
         $glue_logic .= "e_assign->new ([app_clk  => $clkfreq_in]),";
      }


   } else { # slow clock
      if (($common_clk) & (($tl_selection > 0) & ($tl_selection < 6))) {
         $tlp_clk_in .= "tlp_clk => AvlClk_i,";
      } else {
         $tlp_clk_in .= "tlp_clk => \"tlp_clk_$tlp_clk_suffix\",";
      }
      $glue_logic .= "e_assign->new ([app_clk  => tlp_clk_$tlp_clk_suffix]),";

   }
}
##################################################
# Serdes connections
##################################################

# default connections
my $serdes_out = " ";
my $serdes_in = " ";
my $serdes_interface = " ";
my $i;

if (($phy_selection == 0) || ($phy_selection == 7)) { # needs serdes connection

   $serdes_in .= "pipe_mode => pipe_mode,";
   $serdes_interface .= "e_port->new([pipe_mode => 1 => \"input\" => '0']),";

   for ($i = 0; $i < $number_of_lanes; $i++) {
      $serdes_interface .= "e_port->new([rx_in$i => 1 => \"input\" => '0']),";
      $serdes_interface .= "e_port->new([tx_out$i => 1 => \"output\"]),";
      $serdes_out .= "tx_out$i => tx_out$i,";
      $serdes_in .= "rx_in$i => rx_in$i,";
   }
}


##################################################
# S4GX PCIe DPRIO
##################################################
if ($enable_hip_dprio == 1) {

   $add_signals .= "e_signal->new({name => avs_pcie_reconfig_address, width=> 8}),";
   $add_signals .= "e_signal->new({name => avs_pcie_reconfig_writedata, width=> 16}),";
   $add_signals .= "e_signal->new({name => avs_pcie_reconfig_readdata, width=> 16}),";

   $serdes_in .= "avs_pcie_reconfig_address => avs_pcie_reconfig_address,";
   $serdes_in .= "avs_pcie_reconfig_chipselect => avs_pcie_reconfig_chipselect,";
   $serdes_in .= "avs_pcie_reconfig_write => avs_pcie_reconfig_write,";
   $serdes_in .= "avs_pcie_reconfig_writedata => avs_pcie_reconfig_writedata,";
   $serdes_in .= "avs_pcie_reconfig_read => avs_pcie_reconfig_read,";
   $serdes_in .= "avs_pcie_reconfig_clk => avs_pcie_reconfig_clk,";
   $serdes_in .= "avs_pcie_reconfig_rstn => avs_pcie_reconfig_rstn,";

   $serdes_out .= "avs_pcie_reconfig_waitrequest => avs_pcie_reconfig_waitrequest,";
   $serdes_out .= "avs_pcie_reconfig_readdata => avs_pcie_reconfig_readdata,";
   $serdes_out .= "avs_pcie_reconfig_readdatavalid => avs_pcie_reconfig_readdatavalid,";

}


##################################################
# set PIPE width
##################################################
if ($hip == 1) {
   $pipe_width = 8;
   $int_pipe_width = 8;
} elsif (($phy_selection == 0) || ($phy_selection == 1))  { # needs serdes connection
   $pipe_width = 16;
   $int_pipe_width = 16;
} elsif ($phy_selection == 2) {
   if ($number_of_lanes < 8) {
      $pipe_width = 16;
      $int_pipe_width = 16;
   } else {
      $pipe_width = 8;
      $int_pipe_width = 8;
   }
} elsif (($phy_selection == 3) || ($phy_selection == 4) || ($phy_selection == 5))  { # DDIO or SDR 8bit 250Mhz
   $pipe_width = 8;
   if ($number_of_lanes < 8) {
      $int_pipe_width = 16;
   } else {
      $int_pipe_width = 8;
   }
}

##################################################
# RXDDIO width
##################################################
if ($phy_selection == 5) {
   $rxddio_width = 9;
}

##################################################
# set tx credit width
##################################################

if (($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 8)) {
   $txcred_width = 36;
} else {
   if ($number_of_lanes == 8) {
      $txcred_width = 66;
   } else {
      $txcred_width = 22;
   }
}

if ($hip == 1) {
   $txcred_core_width = 36;
} elsif ($number_of_lanes == 8) {
   $txcred_core_width = 66;
} else {
   $txcred_core_width = 36;
}


#lane width & test width
if ($number_of_lanes == 1) {
   $lane_width = 0;
} elsif ($number_of_lanes == 2) {
   $lane_width = 1;
} elsif ($number_of_lanes == 4) {
   $lane_width = 2;
} elsif ($number_of_lanes == 8) {
   $lane_width = 3;
} else {
   die "ERROR: Number of lanes are not supported\n";
}


my $pipe_interface = " ";
my $pipe_connect_in = " ";
my $pipe_connect_out = " ";
my $pipe_open = " ";
my $pipe_kwidth = $pipe_width / 8;
my $int_pipe_kwidth = $int_pipe_width / 8;

# common phy signals
$pipe_interface .= "e_port->new([powerdown_ext => 2 => \"output\"]),";
$pipe_interface .= "e_port->new([phystatus_ext => 1 => \"input\"]),";
$pipe_interface .= "e_port->new([txdetectrx_ext => 1 => \"output\"]),";

$glue_logic .= "e_assign->new ([txdetectrx_ext => txdetectrx0_ext]),";
$glue_logic .= "e_assign->new ([powerdown_ext => powerdown0_ext]),";

if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) { # Dual phy
   $pipe_interface .= "e_port->new([phy1_powerdown_ext => 2 => \"output\"]),";
   $pipe_interface .= "e_port->new([phy1_phystatus_ext => 1 => \"input\"]),";
   $pipe_interface .= "e_port->new([phy1_txdetectrx_ext => 1 => \"output\"]),";

   $glue_logic .= "e_assign->new ([phy1_txdetectrx_ext => txdetectrx4_ext]),";
   $glue_logic .= "e_assign->new ([phy1_powerdown_ext => powerdown4_ext]),";
}

for ($i = 0; $i < $number_of_lanes;  $i++) {

   $add_signals .= "e_signal->new({name => txdetectrx$i\_ext, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => powerdown$i\_ext, width=> 2, never_export => 1}),";

   $pipe_interface .= "e_port->new([txdata$i\_ext => $pipe_width => \"output\"]),";
   $pipe_interface .= "e_port->new([txdatak$i\_ext => $pipe_kwidth => \"output\"]),";
   $pipe_interface .= "e_port->new([txelecidle$i\_ext => 1 => \"output\"]),";
   $pipe_interface .= "e_port->new([txcompl$i\_ext => 1 => \"output\"]),";
   $pipe_interface .= "e_port->new([rxpolarity$i\_ext => 1 => \"output\"]),";
   $pipe_interface .= "e_port->new([rxdata$i\_ext => $pipe_width => \"input\"]),";
   $pipe_interface .= "e_port->new([rxdatak$i\_ext => $pipe_kwidth => \"input\"]),";
   $pipe_interface .= "e_port->new([rxvalid$i\_ext => 1 => \"input\"]),";
   $pipe_interface .= "e_port->new([rxelecidle$i\_ext => 1 => \"input\"]),";
   $pipe_interface .= "e_port->new([rxstatus$i\_ext => 3 => \"input\"]),";

   if ($chk_io) {
      $glue_logic .= "e_assign->new ([txdata$i\_d => rxdata$i\_q]),";
      $glue_logic .= "e_assign->new ([txdatak$i\_d => rxdatak$i\_q]),";
      $glue_logic .= "e_assign->new ([txelecidle$i\_d => phystatus$i\_q]),";
      $glue_logic .= "e_assign->new ([txcompl$i\_d => rxelecidle$i\_q]),";
      $glue_logic .= "e_assign->new ([rxpolarity$i\_d, => \"|{rxstatus$i\_q,rxvalid$i\_q}\"]),";
   } else {

      if ($phy_selection == $PHYSEL_SV) { # S5GX

         # gen3 signals
         $add_signals .= "e_signal->new({name => open_txsynchd$i\_ext, width => 2, never_export => 1}),";
         $add_signals .= "e_signal->new({name => open_txblkst$i\_ext, width => 1, never_export => 1}),";

         $pipe_connect_in .= "rxdata$i\_ext => rxdata$i\_ext,";
         $pipe_connect_in .= "rxdatak$i\_ext => rxdatak$i\_ext,";
         $pipe_connect_in .= "rxvalid$i\_ext => rxvalid$i\_ext,";
         $pipe_connect_in .= "phystatus$i\_ext => phystatus_ext,";
         $pipe_connect_in .= "rxelecidle$i\_ext => rxelecidle$i\_ext,";
         $pipe_connect_in .= "rxstatus$i\_ext => rxstatus$i\_ext,";
         $pipe_connect_in .= "rxdataskip$i\_ext => \"1'b0\",";
         $pipe_connect_in .= "rxblkst$i\_ext =>  \"1'b0\","; # Gen3 signals
         $pipe_connect_in .= "rxsynchd$i\_ext => \"2'b00\","; # Gen3 signals
         if ($phy_selection==$PHYSEL_SV) {
            $pipe_connect_in .= "rxfreqlocked$i\_ext => \"1'b0\","; # Gen3 signals
         }

         $pipe_connect_out .= "txdata$i\_ext => txdata$i\_ext,";
         $pipe_connect_out .= "txdatak$i\_ext => txdatak$i\_ext,";
         $pipe_connect_out .= "txdetectrx$i\_ext => txdetectrx$i\_ext,";
         $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$i\_ext,";
         $pipe_connect_out .= "txcompl$i\_ext => txcompl$i\_ext,";
         $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$i\_ext,";
         $pipe_connect_out .= "powerdown$i\_ext => powerdown$i\_ext,";
         $pipe_connect_out .= "txblkst$i\_ext => open_txblkst$i\_ext,";
         $pipe_connect_out .= "txsynchd$i\_ext => open_txsynchd$i\_ext,";
         $pipe_connect_out .= "txdatavalid$i\_ext => txdatavalid$i\_ext,";

         if ($i == 0) {
            $add_signals .= "e_signal->new({name => rate\_ext, width=> 2}),";
            $pipe_connect_out .= "rate => rate_ext,";
            $clk_in .= "pclk_in => pclk_in,";
            $clk_in .= "pld_clk => pld_clk,";
            $clk_in .= "refclk => refclk,";
            $clk_out .= "clk250_out => clk250_out,";
            $clk_out .= "clk500_out => clk500_out,";
            $clk_out .= "coreclkout => core_clk_out,";
            $clk_out .= "rc_pll_locked => rc_pll_locked,";

         }
      } elsif (($phy_selection != 2) & ($phy_selection != $PHYSEL_HIP_40nm)) { # external phy and SGX
         $pipe_connect_in  .= "rxdata$i\_ext => rxdata$i\_q,";
         $pipe_connect_in  .= "rxdatak$i\_ext => rxdatak$i\_q,";
         $pipe_connect_in  .= "rxvalid$i\_ext => rxvalid$i\_q,";
         $pipe_connect_in  .= "phystatus$i\_ext => phystatus$i\_q,";
         $pipe_connect_in  .= "rxelecidle$i\_ext => rxelecidle$i\_q,";
         $pipe_connect_in  .= "rxstatus$i\_ext => rxstatus$i\_q,";
         $pipe_connect_out .= "txdata$i\_ext => txdata$i\_d,";
         $pipe_connect_out .= "txdatak$i\_ext => txdatak$i\_d,";
         $pipe_connect_out .= "txdetectrx$i\_ext => txdetectrx$i\_d,";
         $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$i\_d,";
         $pipe_connect_out .= "txcompl$i\_ext => txcompl$i\_d,";
         $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$i\_d,";
         $pipe_connect_out .= "powerdown$i\_ext => powerdown$i\_d,";
      } else { # S2GX and S4GX

         $add_signals .= "e_signal->new({name => rxdata, width=> $pipe_width * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxdata_pcs, width=> $pipe_width * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxdatak, width=> $pipe_kwidth * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxdatak_pcs, width=> $pipe_kwidth * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxstatus, width=> 3 * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxstatus_pcs, width=> 3 *   $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => phystatus, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => phystatus_pcs, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxelecidle, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxelecidle_pcs, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxvalid, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxvalid_pcs, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => txdata, width=> $pipe_width * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => powerdown, width=> 2 * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rxpolarity, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => txcompl, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => txdatak, width=> $pipe_kwidth * $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => txdetectrx, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => txelecidle, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => tx_out, width=> $number_of_lanes, never_export => 1}),";
         $add_signals .= "e_signal->new({name => rx_in, width=> $number_of_lanes, never_export => 1}),";

         my $hi,$lo;
         if ($hip == 1) { # HIP
            $lo = $i * $pipe_width;
            $hi = $lo + $pipe_width - 1;
            $glue_logic .= "e_assign->new({lhs => \"rxdata[$hi\:$lo]\", rhs =>\"pipe_mode_int ? rxdata$i\_ext : rxdata_pcs[$hi\:$lo]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"phystatus[$i]\", rhs =>\"pipe_mode_int ? phystatus_ext : phystatus_pcs[$i]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"rxelecidle[$i]\", rhs =>\"pipe_mode_int ? rxelecidle$i\_ext : rxelecidle_pcs[$i]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"rxvalid[$i]\", rhs =>\"pipe_mode_int ? rxvalid$i\_ext : rxvalid_pcs[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"txdata$i\_int\", lhs =>\"txdata[$hi\:$lo]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"rxdatak[$i]\", rhs =>\"pipe_mode_int ? rxdatak$i\_ext : rxdatak_pcs[$i]\"}),";
            $pipe_connect_in .= "rxdatak$i\_ext => \"rxdatak[$i]\",";

            $lo = $i * 3;
            $hi = $lo + 2;
            $glue_logic .= "e_assign->new({lhs => \"rxstatus[$hi\:$lo]\", rhs =>\"pipe_mode_int ? rxstatus$i\_ext : rxstatus_pcs[$hi\:$lo]\"}),";
            $lo = $i * 2;
            $hi = $lo + 1;
            $glue_logic .= "e_assign->new({rhs => \"powerdown$i\_int\", lhs =>\"powerdown[$hi\:$lo]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"rxpolarity$i\_int\", lhs =>\"rxpolarity[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"txcompl$i\_int\", lhs =>\"txcompl[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"txdatak$i\_int\", lhs =>\"txdatak[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs =>\"txdetectrx$i\_int\",lhs => \"txdetectrx[$i]\", }),";
            $glue_logic .= "e_assign->new({rhs => \"txelecidle$i\_int\", lhs =>\"txelecidle[$i]\"}),";

            $pipe_connect_out .= "rate_ext => rate_int,";
            $pipe_connect_out .= "reset_status => reset_status,";

         } else { # soft IP

            $add_signals .= "e_signal->new({name => rxdata_pcs_q, width=> $pipe_width * $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rxdatak_pcs_q, width=> $pipe_kwidth * $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rxstatus_pcs_q, width=> 3 *   $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => phystatus_pcs_q, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rxelecidle_pcs_q, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rxvalid_pcs_q, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => txdata_d, width=> $pipe_width * $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => powerdown_d, width=> 2 * $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rxpolarity_d, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => txcompl_d, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => txdatak_d, width=> $pipe_kwidth * $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => txdetectrx_d, width=> $number_of_lanes, never_export => 1}),";
            $add_signals .= "e_signal->new({name => txelecidle_d, width=> $number_of_lanes, never_export => 1}),";

            $lo = $i * $pipe_width;
            $hi = $lo + $pipe_width - 1;
            $glue_logic .= "e_assign->new({lhs => \"rxdata[$hi\:$lo]\", rhs =>\"pipe_mode_int ? rxdata$i\_ext : rxdata_pcs_q[$hi\:$lo]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"phystatus[$i]\", rhs =>\"pipe_mode_int ? phystatus_ext : phystatus_pcs_q[$i]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"rxelecidle[$i]\", rhs =>\"pipe_mode_int ? rxelecidle$i\_ext : rxelecidle_pcs_q[$i]\"}),";
            $glue_logic .= "e_assign->new({lhs => \"rxvalid[$i]\", rhs =>\"pipe_mode_int ? rxvalid$i\_ext : rxvalid_pcs_q[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"txdata$i\_int\", lhs =>\"txdata_d[$hi\:$lo]\"}),";

            $lo = $i * $pipe_kwidth;
            $hi = $lo + $pipe_kwidth - 1;
            $glue_logic .= "e_assign->new({lhs => \"rxdatak[$hi\:$lo]\", rhs =>\"pipe_mode_int ? rxdatak$i\_ext : rxdatak_pcs_q[$hi\:$lo]\"}),";
            $pipe_connect_in .= "rxdatak$i\_ext => \"rxdatak[$hi\:$lo]\",";
            $glue_logic .= "e_assign->new({rhs => \"txdatak$i\_int\", lhs =>\"txdatak_d[$hi\:$lo]\"}),";


            $lo = $i * 2;
            $hi = $lo + 1;
            $glue_logic .= "e_assign->new({rhs => \"powerdown$i\_int\", lhs =>\"powerdown_d[$hi\:$lo]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"rxpolarity$i\_int\", lhs =>\"rxpolarity_d[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs => \"txcompl$i\_int\", lhs =>\"txcompl_d[$i]\"}),";
            $glue_logic .= "e_assign->new({rhs =>\"txdetectrx$i\_int\",lhs => \"txdetectrx_d[$i]\", }),";
            $glue_logic .= "e_assign->new({rhs => \"txelecidle$i\_int\", lhs =>\"txelecidle_d[$i]\"}),";

            $lo = $i * 3;
            $hi = $lo + 2;
            $glue_logic .= "e_assign->new({lhs => \"rxstatus[$hi\:$lo]\", rhs =>\"pipe_mode_int ? rxstatus$i\_ext : rxstatus_pcs_q[$hi\:$lo]\"}),";



         }
         $lo = $i * $pipe_width;
         $hi = $lo + $pipe_width - 1;
         $pipe_connect_in .= "rxdata$i\_ext => \"rxdata[$hi\:$lo]\",";
         $pipe_connect_in .= "phystatus$i\_ext => \"phystatus[$i]\",";
         $pipe_connect_in .= "rxelecidle$i\_ext => \"rxelecidle[$i]\",";
         $pipe_connect_in .= "rxvalid$i\_ext => \"rxvalid[$i]\",";

         $lo = $i * 3;
         $hi = $lo + 2;
         $pipe_connect_in .= "rxstatus$i\_ext =>  \"rxstatus[$hi\:$lo]\",";

         $pipe_connect_out .= "txdata$i\_ext => txdata$i\_int,";
         $add_signals .= "e_signal->new({name => txdata$i\_int, width=> $pipe_width , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"txdata$i\_ext\", rhs =>\"pipe_mode_int ? txdata$i\_int : 0\"}),";

         $pipe_connect_out .= "txdatak$i\_ext => txdatak$i\_int,";
         $add_signals .= "e_signal->new({name => txdatak$i\_int, width=> $pipe_kwidth , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"txdatak$i\_ext\", rhs =>\"pipe_mode_int ? txdatak$i\_int : 0\"}),";

         $pipe_connect_out .= "txdetectrx$i\_ext => txdetectrx$i\_int,";
         $glue_logic .= "e_assign->new({lhs => \"txdetectrx$i\_ext\", rhs =>\"pipe_mode_int ? txdetectrx$i\_int : 0\"}),";

         $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$i\_int,";
         $glue_logic .= "e_assign->new({lhs => \"txelecidle$i\_ext\", rhs =>\"pipe_mode_int ? txelecidle$i\_int : 0\"}),";

         $pipe_connect_out .= "txcompl$i\_ext => txcompl$i\_int,";
         $glue_logic .= "e_assign->new({lhs => \"txcompl$i\_ext\", rhs =>\"pipe_mode_int ? txcompl$i\_int : 0\"}),";

         $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$i\_int,";
         $glue_logic .= "e_assign->new({lhs => \"rxpolarity$i\_ext\", rhs =>\"pipe_mode_int ? rxpolarity$i\_int : 0\"}),";

         $pipe_connect_out .= "powerdown$i\_ext => powerdown$i\_int,";
         $add_signals .= "e_signal->new({name => powerdown$i\_int, width=> 2 , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"powerdown$i\_ext\", rhs =>\"pipe_mode_int ? powerdown$i\_int : 0\"}),";

         # reset controller ports
         $pipe_connect_in .= "rc_inclk_eq_125mhz => rc_inclk_eq_125mhz,";
         $pipe_connect_in .= "rc_areset => rc_areset,";
         $pipe_connect_in .= "rc_pll_locked => rc_pll_locked,";
         $pipe_connect_in .= "rc_rx_pll_locked_one => rc_rx_pll_locked_one,";
         $add_signals .= "e_signal->new({name => open_gxb_powerdown, never_export => 1}),";
         $pipe_connect_out .= "rc_gxb_powerdown => open_gxb_powerdown,";
         if ($phy_selection==6) {
            $add_signals .= "e_signal->new({name => open_rc_tx_digitalreset, never_export => 1}),";
            $pipe_connect_out .= "rc_tx_digitalreset => open_rc_tx_digitalreset,";
         } else {
            $pipe_connect_out .= "rc_tx_digitalreset => rc_tx_digitalreset,";
         }

	 if ($phy_selection==$PHYSEL_HIP_40nm) {
	     $add_signals .= "e_signal->new({name => open_rc_rx_analogreset, never_export => 1}),";
	     $pipe_connect_out .= "rc_rx_analogreset => open_rc_rx_analogreset,";
	 } else {
	     $pipe_connect_out .= "rc_rx_analogreset => rc_rx_analogreset,";
	 }
         $pipe_connect_out .= "rc_rx_digitalreset => rc_rx_digitalreset,";
      }
   }
}




##################################################
# add misc signals
##################################################

# multi-bit bus
$add_signals .= "e_signal->new({name => app_msi_tc, width=> 3}),";
$add_signals .= "e_signal->new({name => app_msi_num, width=> 5}),";
$add_signals .= "e_signal->new({name => pex_msi_num, width=> 5}),";
$add_signals .= "e_signal->new({name => cfg_busdev, width=> 13}),";
$add_signals .= "e_signal->new({name => cfg_devcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_linkcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_tcvcmap, width=> 24}),";
$add_signals .= "e_signal->new({name => tl_cfg_add, width=> 4}),";
$add_signals .= "e_signal->new({name => tl_cfg_ctl, width=> 32}),";
$add_signals .= "e_signal->new({name => tl_cfg_sts, width=> 53}),";
$add_signals .= "e_signal->new({name => cpl_err, width=> 7}),";
$add_signals .= "e_signal->new({name => cfg_msicsr, width=> 16}),";
$add_signals .= "e_signal->new({name => cfg_pmcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_prmcsr, width=> 32}),";

##################################################
# Core VC interface
##################################################
my $vcs_connect_in = " ";
my $vcs_connect_out = " ";
my $vcs_open = " ";
my $vcs_signals = " ";
my $sv_connect_in_gnd='';

# multi-bit bus
if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm)) { # S4GX, A2GX, C4GX
   $vcs_signals .= "e_port->new([test_in => 40 => \"input\"]),";
} else {
   $vcs_signals .= "e_port->new([test_in => 32 => \"input\"]),";
}
if ($test_out_width > 0) {
   $vcs_signals .= "e_port->new([test_out => $test_out_width => \"output\"]),";
}

if ($rp == 2) { # endpoint / root port mode
   $add_signals .= "e_signal->new({name => mode, width=> 2}),";
   $vcs_connect_in .= "mode => mode,";
}

# Loop thru two VCs for TL bypass
if ($tl_selection == 8) {
   $number_of_vcs = 2;
}


# Family before S5GX where there are multiple VCs
for ($i = 0; (($i < $number_of_vcs) & ($phy_selection < 7)); $i++) {

   if ($hip == 0) { # Only Soft IP has legacy mode
      if ($tl_selection == 0) { # native PLDA
         $vcs_signals .= "e_port->new([ko_cpl_spc_vc$i => 20 => \"output\"]),";
         $vcs_signals .= "e_port->new([tx_desc$i => 128 => \"input\"]),";
         $vcs_signals .= "e_port->new([tx_data$i => 64 => \"input\"]),";
         $vcs_signals .= "e_port->new([rx_desc$i => 136 => \"output\"]),";
         $vcs_signals .= "e_port->new([rx_data$i => 64 => \"output\"]),";
         if ($number_of_lanes != 8) { # x8 core does not have Byte enable
            $vcs_signals .= "e_port->new([rx_be$i => 8 => \"output\"]),";
         }
         $vcs_connect_in .= "rx_ack$i => rx_ack$i,";
         $vcs_connect_in .= "rx_abort$i => rx_abort$i,";
         $vcs_connect_in .= "rx_retry$i => rx_retry$i,";
         $vcs_connect_in .= "rx_mask$i => rx_mask$i,";
         $vcs_connect_in .= "rx_ws$i => rx_ws$i,";

         $vcs_connect_in .= "tx_req$i => tx_req$i,";
         $vcs_connect_in .= "tx_desc$i => tx_desc$i,";
         $vcs_connect_in .= "tx_dfr$i => tx_dfr$i,";
         $vcs_connect_in .= "tx_data$i => tx_data$i,";
         $vcs_connect_in .= "tx_dv$i => tx_dv$i,";

         $vcs_connect_out .= "ko_cpl_spc_vc$i => ko_cpl_spc_vc$i,";
         $vcs_connect_out .= "rx_req$i => rx_req$i,";
         $vcs_connect_out .= "rx_desc$i => rx_desc$i,";
         $vcs_connect_out .= "rx_data$i => rx_data$i,";
         if ($number_of_lanes != 8) { # x8 core does not have Byte enable
            $vcs_connect_in .= "tx_err$i => tx_err$i,";
            $vcs_connect_out .= "rx_be$i => rx_be$i,";
         }
         $vcs_connect_out .= "rx_dv$i => rx_dv$i,";
         $vcs_connect_out .= "rx_dfr$i => rx_dfr$i,";

         $vcs_connect_out .= "tx_ack$i => tx_ack$i,";
         $vcs_connect_out .= "tx_ws$i => tx_ws$i,";

         $vcs_signals .= "e_port->new([tx_cred$i => $txcred_width => \"output\"]),";
         $add_signals .= "e_signal->new({name => tx_cred$i\_int, width=> $txcred_core_width, never_export => 1}),";
         if ($txcred_width == $txcred_core_width) {
            $vcs_connect_out .= "tx_cred$i => tx_cred$i,";
         } else {
            $vcs_connect_out .= "tx_cred$i => tx_cred$i\_int,";
            $glue_logic .= "e_assign->new ([tx_cred$i, => \"tx_cred$i\_int[$txcred_width-1:0]\"]),";

         }


      } else { # tie off PLDA mode in other TL modes

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_ack$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_ack$i => gnd_rx_ack$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_abort$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_abort$i => gnd_rx_abort$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_retry$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_retry$i => gnd_rx_retry$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_mask$i}, rhs => \"1'b0\"}),"   ;
         $vcs_connect_in .= "rx_mask$i => gnd_rx_mask$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_ws$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_ws$i => gnd_rx_ws$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_req$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "tx_req$i => gnd_tx_req$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_desc$i, width=> 128}, rhs => \"0\"}),";
         $vcs_connect_in .= "tx_desc$i => gnd_tx_desc$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_dfr$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "tx_dfr$i => gnd_tx_dfr$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_data$i, width => 64}, rhs => \"0\"}),";
         $vcs_connect_in .= "tx_data$i => gnd_tx_data$i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_dv$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "tx_dv$i => gnd_tx_dv$i,";

         if ($number_of_lanes != 8) { # x8 core does not tx_err
            $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_err$i}, rhs => \"1'b0\"}),";
            $vcs_connect_in .= "tx_err$i => gnd_tx_err$i,";
         }

         $vcs_signals .= "e_signal->new({name => open_ko_cpl_spc_vc$i, width => 20, never_export => 1}),";
         $vcs_connect_out .= "ko_cpl_spc_vc$i =>open_ko_cpl_spc_vc$i,";

         $vcs_signals .= "e_signal->new({name => open_rx_req$i, never_export => 1}),";
         $vcs_connect_out .= "rx_req$i =>open_rx_req$i,";


         if ($number_of_lanes != 8) { # x8 core does not have Byte enable
            $vcs_signals .= "e_signal->new({name => open_rx_be$i, width=> 8, never_export => 1}),";
            $vcs_connect_out .= "rx_be$i =>open_rx_be$i,";
         }

         $vcs_signals .= "e_signal->new({name => open_rx_desc$i, width=> 136, never_export => 1}),";
         $vcs_connect_out .= "rx_desc$i =>open_rx_desc$i,";

         $vcs_signals .= "e_signal->new({name => open_rx_data$i, width => 64, never_export => 1}),";
         $vcs_connect_out .= "rx_data$i =>open_rx_data$i,";

         $vcs_signals .= "e_signal->new({name => open_rx_dv$i, never_export => 1}),";
         $vcs_connect_out .= "rx_dv$i =>open_rx_dv$i,";

         $vcs_signals .= "e_signal->new({name => open_rx_dfr$i, never_export => 1}),";
         $vcs_connect_out .= "rx_dfr$i =>open_rx_dfr$i,";

         $vcs_signals .= "e_signal->new({name => open_tx_ack$i, never_export => 1}),";
         $vcs_connect_out .= "tx_ack$i =>open_tx_ack$i,";

         if (($tl_selection != 6) & ($tl_selection != 7)){
            $vcs_signals .= "e_signal->new({name => open_tx_cred$i, width=> $txcred_core_width, never_export => 1}),";
            $vcs_connect_out .= "tx_cred$i =>open_tx_cred$i,";
         }

         $vcs_signals .= "e_signal->new({name => open_tx_ws$i, never_export => 1}),";
         $vcs_connect_out .= "tx_ws$i =>open_tx_ws$i,";

      }
   }

   if (($tl_selection >= 1) & ($tl_selection <= 5)) { # Avalon MM mode

      # hookup Avalon interface
      # RX master
      $vcs_connect_in .= "AvlClk_i => AvlClk_i,";
      $vcs_connect_in .= "Rstn_i => reset_n,";
      $vcs_signals .= "e_port->new([RxmAddress_o => 32 => \"output\"]),";


      if (($tl_selection == 2) & ($ast_lite == 1)) {
     $vcs_signals .= "e_port->new([RxmWriteData_o => 32 => \"output\"]),";
     $vcs_signals .= "e_port->new([RxmReadData_i => 32 => \"input\"]),";
     $vcs_signals .= "e_port->new([RxmByteEnable_o => 4 => \"output\"]),";
     $add_signals .= "e_signal->new({name => open_RxmBurstCount_o, width=> 10, never_export => 1}),";
     $vcs_connect_out .= "RxmBurstCount_o => open_RxmBurstCount_o,";

     if ($i == 0) {
         $glue_logic .= "e_assign->new ([RxmWriteData_o => \"RxmWriteData_int[31:0]\"]),";
         $glue_logic .= "e_assign->new ([RxmReadData_int => \"{32'h00000000,RxmReadData_i}\"]),";
         $glue_logic .= "e_assign->new ([RxmByteEnable_o => \"RxmByteEnable_int[3:0]\"]),";
     }
      } else {
     $vcs_signals .= "e_port->new([RxmWriteData_o => 64 => \"output\"]),";
     $vcs_signals .= "e_port->new([RxmReadData_i => 64 => \"input\"]),";
     $vcs_signals .= "e_port->new([RxmByteEnable_o => 8 => \"output\"]),";
     $vcs_signals .= "e_port->new([RxmBurstCount_o => 10 => \"output\"]),";
     $vcs_connect_out .= "RxmBurstCount_o => RxmBurstCount_o,";

     if ($i == 0) {
         $glue_logic .= "e_assign->new ([RxmWriteData_o => \"RxmWriteData_int\"]),";
         $glue_logic .= "e_assign->new ([RxmReadData_int => \"RxmReadData_i\"]),";
         $glue_logic .= "e_assign->new ([RxmByteEnable_o => \"RxmByteEnable_int\"]),";
     }
      }

      $vcs_connect_out .= "RxmWrite_o => RxmWrite_o,";
      $vcs_connect_out .= "RxmAddress_o => RxmAddress_o,";

      $add_signals .= "e_signal->new({name => RxmByteEnable_int, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => RxmWriteData_int, width=> 64, never_export => 1}),";
      $add_signals .= "e_signal->new({name => RxmReadData_int, width=> 64, never_export => 1}),";
      $vcs_connect_in .= "RxmReadData_i => RxmReadData_int,";
      $vcs_connect_out .= "RxmWriteData_o => RxmWriteData_int,";
      $vcs_connect_out .= "RxmByteEnable_o => RxmByteEnable_int,";

      $vcs_connect_in .= "RxmWaitRequest_i => RxmWaitRequest_i,";
      $vcs_connect_out .= "RxmRead_o => RxmRead_o,";

      $vcs_connect_in .= "RxmReadDataValid_i => RxmReadDataValid_i,";

      # TX Slave
      if ($tl_selection == 1 || $tl_selection == 3) {
         $vcs_signals .= "e_port->new([TxsWriteData_i => 64 => \"input\"]),";
         $vcs_signals .= "e_port->new([TxsBurstCount_i => 10 => \"input\"]),";
         $vcs_signals .= "e_port->new([TxsAddress_i => $CG_AVALON_S_ADDR_WIDTH => \"input\"]),";
         $vcs_signals .= "e_port->new([TxsByteEnable_i => 8 => \"input\"]),";
         $vcs_signals .= "e_port->new([TxsReadData_o => 64 => \"output\"]),";
         $vcs_connect_in .= "TxsChipSelect_i => TxsChipSelect_i,";
         $vcs_connect_in .= "TxsRead_i => TxsRead_i,";
         $vcs_connect_in .= "TxsWrite_i => TxsWrite_i,";
         $vcs_connect_in .= "TxsWriteData_i => TxsWriteData_i,";
         $vcs_connect_in .= "TxsBurstCount_i => TxsBurstCount_i,";
         $vcs_connect_in .= "TxsAddress_i => TxsAddress_i,";
         $vcs_connect_in .= "TxsByteEnable_i => TxsByteEnable_i,";
         $vcs_connect_out .= "TxsReadDataValid_o => TxsReadDataValid_o,";
         $vcs_connect_out .= "TxsReadData_o => TxsReadData_o,";
         $vcs_connect_out .= "TxsWaitRequest_o => TxsWaitRequest_o,";
      } else {
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsWriteData_i, width=> 64}, rhs => \"0\"}),";
         $vcs_connect_in .= "TxsWriteData_i => gnd_TxsWriteData_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsBurstCount_i, width=> 10}, rhs => \"0\"}),";
         $vcs_connect_in .= "TxsBurstCount_i => gnd_TxsBurstCount_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsAddress_i, width=> $CG_AVALON_S_ADDR_WIDTH}, rhs => \"0\"}),";
         $vcs_connect_in .= "TxsAddress_i => gnd_TxsAddress_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsByteEnable_i, width=> 8}, rhs => \"0\"}),";
         $vcs_connect_in .= "TxsByteEnable_i => gnd_TxsByteEnable_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsChipSelect_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsChipSelect_i => gnd_TxsChipSelect_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsRead_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsRead_i => gnd_TxsRead_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsWrite_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsWrite_i => gnd_TxsWrite_i,";

         $add_signals .= "e_signal->new({name => open_TxsReadData_o, width=> 64, never_export => 1}),";
         $add_signals .= "e_signal->new({name => open_TxsReadDataValid_o, width=> 1, never_export => 1}),";
         $add_signals .= "e_signal->new({name => open_TxsWaitRequest_o, width=> 1, never_export => 1}),";
         $vcs_connect_out .= "TxsReadDataValid_o => open_TxsReadDataValid_o,";
         $vcs_connect_out .= "TxsReadData_o => open_TxsReadData_o,";
         $vcs_connect_out .= "TxsWaitRequest_o => open_TxsWaitRequest_o,";

      }

      # CRA
      if ($tl_selection == 1 || $tl_selection == 4) {
         $vcs_signals .= "e_port->new([CraWriteData_i => 32 => \"input\"]),";
         $vcs_signals .= "e_port->new([CraAddress_i => 12 => \"input\"]),";
         $vcs_signals .= "e_port->new([CraByteEnable_i => 4 => \"input\"]),";
         $vcs_signals .= "e_port->new([CraReadData_o => 32 => \"output\"]),";
         $vcs_signals .= "e_port->new([RxmIrqNum_i => 6 => \"input\"]),";
         $vcs_connect_in .= "CraChipSelect_i => CraChipSelect_i,";
         $vcs_connect_in .= "CraRead => CraRead,";
         $vcs_connect_in .= "CraWrite => CraWrite,";
         $vcs_connect_in .= "CraWriteData_i => CraWriteData_i,";
         $vcs_connect_in .= "CraAddress_i => CraAddress_i,";
         $vcs_connect_in .= "CraByteEnable_i => CraByteEnable_i,";
         $vcs_connect_out .= "CraReadData_o => CraReadData_o,";
         $vcs_connect_out .= "CraWaitRequest_o => CraWaitRequest_o,";
         $vcs_connect_out .= "CraIrq_o => CraIrq_o,";
         $vcs_connect_in .= "RxmIrq_i => RxmIrq_i,";
         $vcs_connect_in .= "RxmIrqNum_i => RxmIrqNum_i,";

      } else {
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraWriteData_i, width=> 32}, rhs => \"0\"}),";
         $vcs_connect_in .= "CraWriteData_i => gnd_CraWriteData_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraAddress_i, width=> 12}, rhs => \"0\"}),";
         $vcs_connect_in .= "CraAddress_i => gnd_CraAddress_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraByteEnable_i, width=> 4}, rhs => \"0\"}),";
         $vcs_connect_in .= "CraByteEnable_i => gnd_CraByteEnable_i,";

         $add_signals .= "e_signal->new({name => open_CraReadData_o, width=> 32, never_export => 1}),";
         $vcs_connect_out .= "CraReadData_o => open_CraReadData_o,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraChipSelect_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraChipSelect_i => gnd_CraChipSelect_i,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraRead }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraRead => gnd_CraRead,";

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraWrite }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraWrite => gnd_CraWrite,";


    if (($tl_selection == 2) & ($ast_lite == 1)) {
        $vcs_connect_in .= "RxmIrq_i => RxmIrq_i,";
    } else {
        $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmIrq_i }, rhs => \"1'b0\"}),";
        $vcs_connect_in .= "RxmIrq_i => gnd_RxmIrq_i,";
    }

         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmIrqNum_i, width=> 6}, rhs => \"0\"}),";
         $vcs_connect_in .= "RxmIrqNum_i => gnd_RxmIrqNum_i,";

         $add_signals .= "e_signal->new({name => open_CraWaitRequest_o, width=> 1, never_export => 1}),";
         $vcs_connect_out .= "CraWaitRequest_o => open_CraWaitRequest_o,";

         $add_signals .= "e_signal->new({name => open_CraIrq_o, width=> 1, never_export => 1}),";
         $vcs_connect_out .= "CraIrq_o => open_CraIrq_o,";

      }


      # extra ports to tie off for HIP
      if ($hip == 1) {
         $vcs_connect_in .= "aer_msi_num => \"5'b00000\",";
         $vcs_connect_in .= "hpg_ctrler => \"5'b00000\",";
         $vcs_connect_in .= "lmi_addr => \"12'h000\",";
         $vcs_connect_in .= "lmi_din => \"32'h00000000\",";
         $vcs_connect_in .= "lmi_rden => \"1'b0\",";
         $vcs_connect_in .= "lmi_wren => \"1'b0\",";
         $vcs_connect_in .= "pm_auxpwr => \"1'b0\",";
         $vcs_connect_in .= "pm_event => \"1'b0\",";
         $vcs_connect_in .= "pm_data => \"10'b0000000000\",";
         $vcs_connect_in .= "tx_st_data$i\_p1 => \"64'h0\",";
         $vcs_connect_in .= "tx_st_sop$i\_p1 => \"1'b0\",";
         $vcs_connect_in .= "tx_st_eop$i\_p1 => \"1'b0\",";

         # add LTSSM port for debugging
         $add_signals .= "e_signal->new({name => ltssm, width => 5}),";
         $vcs_connect_out .= "dl_ltssm => ltssm,";
         $add_signals .= "e_signal->new({name => lane_act, width => 4}),";
         $vcs_connect_out .= "lane_act => lane_act,";


      }
   } else { # tie off Avalon signals
      if (($number_of_lanes != 8) || ($hip == 1)) { # SIP or HIP S4GX/A2GX/C4GX
         $add_signals .= "e_signal->new({name => gnd_AvlClk_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_AvlClk_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "AvlClk_i => gnd_AvlClk_i,";

         $add_signals .= "e_signal->new({name => gnd_Rstn_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_Rstn_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "Rstn_i => gnd_Rstn_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsChipSelect_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsChipSelect_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsChipSelect_i => gnd_TxsChipSelect_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsRead_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsRead_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsRead_i => gnd_TxsRead_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsWrite_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsWrite_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsWrite_i => gnd_TxsWrite_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsWriteData_i , width => 64 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsWriteData_i , width => 64}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsWriteData_i => gnd_TxsWriteData_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsBurstCount_i , width => 10 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsBurstCount_i , width => 10}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsBurstCount_i => gnd_TxsBurstCount_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsAddress_i , width => $CG_AVALON_S_ADDR_WIDTH ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsAddress_i , width => $CG_AVALON_S_ADDR_WIDTH}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsAddress_i => gnd_TxsAddress_i,";

         $add_signals .= "e_signal->new({name => gnd_TxsByteEnable_i , width => 8 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_TxsByteEnable_i , width => 8}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "TxsByteEnable_i => gnd_TxsByteEnable_i,";

         $add_signals .= "e_signal->new({name => open_TxsReadDataValid_o  ,never_export => 1}),";
         $vcs_connect_out .= "TxsReadDataValid_o => open_TxsReadDataValid_o,";

         $add_signals .= "e_signal->new({name => open_TxsReadData_o , width => 64 ,never_export => 1}),";
         $vcs_connect_out .= "TxsReadData_o => open_TxsReadData_o,";

         $add_signals .= "e_signal->new({name => open_TxsWaitRequest_o  ,never_export => 1}),";
         $vcs_connect_out .= "TxsWaitRequest_o => open_TxsWaitRequest_o,";

         $add_signals .= "e_signal->new({name => open_RxmWrite_o  ,never_export => 1}),";
         $vcs_connect_out .= "RxmWrite_o => open_RxmWrite_o,";

         $add_signals .= "e_signal->new({name => open_RxmAddress_o , width => 32 ,never_export => 1}),";
         $vcs_connect_out .= "RxmAddress_o => open_RxmAddress_o,";

         $add_signals .= "e_signal->new({name => open_RxmWriteData_o , width => 64 ,never_export => 1}),";
         $vcs_connect_out .= "RxmWriteData_o => open_RxmWriteData_o,";

         $add_signals .= "e_signal->new({name => open_RxmByteEnable_o , width => 8 ,never_export => 1}),";
         $vcs_connect_out .= "RxmByteEnable_o => open_RxmByteEnable_o,";

         $add_signals .= "e_signal->new({name => open_RxmBurstCount_o , width => 10 ,never_export => 1}),";
         $vcs_connect_out .= "RxmBurstCount_o => open_RxmBurstCount_o,";

         $add_signals .= "e_signal->new({name => gnd_RxmWaitRequest_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmWaitRequest_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "RxmWaitRequest_i => gnd_RxmWaitRequest_i,";

         $add_signals .= "e_signal->new({name => open_RxmRead_o  ,never_export => 1}),";
         $vcs_connect_out .= "RxmRead_o => open_RxmRead_o,";

         $add_signals .= "e_signal->new({name => gnd_RxmReadData_i , width => 64 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmReadData_i , width => 64}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "RxmReadData_i => gnd_RxmReadData_i,";

         $add_signals .= "e_signal->new({name => gnd_RxmReadDataValid_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmReadDataValid_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "RxmReadDataValid_i => gnd_RxmReadDataValid_i,";

         $add_signals .= "e_signal->new({name => gnd_RxmIrq_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmIrq_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "RxmIrq_i => gnd_RxmIrq_i,";

         $add_signals .= "e_signal->new({name => gnd_RxmIrqNum_i , width => 6 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_RxmIrqNum_i , width => 6}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "RxmIrqNum_i => gnd_RxmIrqNum_i,";

         $add_signals .= "e_signal->new({name => gnd_CraChipSelect_i  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraChipSelect_i }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraChipSelect_i => gnd_CraChipSelect_i,";

         $add_signals .= "e_signal->new({name => gnd_CraRead  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraRead }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraRead => gnd_CraRead,";

         $add_signals .= "e_signal->new({name => gnd_CraWrite  ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraWrite }, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraWrite => gnd_CraWrite,";

         $add_signals .= "e_signal->new({name => gnd_CraWriteData_i , width => 32 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraWriteData_i , width => 32}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraWriteData_i => gnd_CraWriteData_i,";

         $add_signals .= "e_signal->new({name => gnd_CraAddress_i , width => 12 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraAddress_i , width => 12}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraAddress_i => gnd_CraAddress_i,";

         $add_signals .= "e_signal->new({name => gnd_CraByteEnable_i , width => 4 ,never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_CraByteEnable_i , width => 4}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "CraByteEnable_i => gnd_CraByteEnable_i,";

         $add_signals .= "e_signal->new({name => open_CraReadData_o , width => 32 ,never_export => 1}),";
         $vcs_connect_out .= "CraReadData_o => open_CraReadData_o,";

         $add_signals .= "e_signal->new({name => open_CraWaitRequest_o  ,never_export => 1}),";
         $vcs_connect_out .= "CraWaitRequest_o => open_CraWaitRequest_o,";

         $add_signals .= "e_signal->new({name => open_CraIrq_o  ,never_export => 1}),";
         $vcs_connect_out .= "CraIrq_o => open_CraIrq_o,";
      }
   }

   if (($tl_selection == 6) || ($tl_selection == 7) || ($tl_selection == 8)) { # HIPCAB mode or Hard IP or TL bypass
      $vcs_connect_in .= "rx_st_ready$i => rx_st_ready$i,";

      $vcs_connect_out .= "rx_st_valid$i => rx_st_valid$i,";


      if (($tl_selection == 7) || ($tl_selection == 8)) { # 128 bit mode or TL bypass
         $vcs_signals .= "e_port->new([rx_st_data$i => 128 => \"output\"]),";
         $vcs_connect_out .= "rx_st_data$i => \"rx_st_data$i\[63:0]\",";
         $vcs_connect_out .= "rx_st_data$i\_p1 => \"rx_st_data$i\[127:64]\",";

         $vcs_signals .= "e_port->new([rx_st_be$i => 16 => \"output\"]),";
         $vcs_connect_out .= "rx_st_be$i => \"rx_st_be$i\[7:0]\",";
         $vcs_connect_out .= "rx_st_be$i\_p1 => \"rx_st_be$i\[15:8]\",";
         $vcs_connect_out .= "rx_st_eop$i => rx_st_empty$i,";
         $vcs_connect_out .= "rx_st_eop$i\_p1 => rx_st_eop$i,";
         $vcs_connect_in .= "tx_st_eop$i => tx_st_empty$i,";
         $vcs_connect_in .= "tx_st_eop$i\_p1 => tx_st_eop$i,";
         $vcs_signals .= "e_port->new([tx_st_data$i => 128 => \"input\"]),";
         $vcs_connect_in .= "tx_st_data$i => \"tx_st_data$i\[63:0]\",";
         $vcs_connect_in .= "tx_st_data$i\_p1 => \"tx_st_data$i\[127:64]\",";


      } else {
         $vcs_signals .= "e_port->new([rx_st_data$i => 64 => \"output\"]),";
         $vcs_connect_out .= "rx_st_data$i => rx_st_data$i,";

         if ($hip == 1) {
            $add_signals .= "e_signal->new({name => open_rx_st_data$i\_p1, width => 64 ,never_export => 1}),";
            $vcs_connect_out .= "rx_st_data$i\_p1 => open_rx_st_data$i\_p1,";
            $add_signals .= "e_signal->new({name => open_rx_st_be$i\_p1, width => 8 ,never_export => 1}),";
            $vcs_connect_out .= "rx_st_be$i\_p1 => open_rx_st_be$i\_p1,";
            $add_signals .= "e_signal->new({name => open_rx_st_eop$i\_p1, width => 1 ,never_export => 1}),";
            $vcs_connect_out .= "rx_st_eop$i\_p1 => open_rx_st_eop$i\_p1,";
            $vcs_connect_in .= "tx_st_eop$i\_p1 => \"1'b0\",";
            $vcs_connect_in .= "tx_st_data$i\_p1 => \"64'h0\",";



         }

         $vcs_signals .= "e_port->new([rx_st_be$i => 8 => \"output\"]),";
         $vcs_connect_out .= "rx_st_be$i => rx_st_be$i,";
         $vcs_connect_out .= "rx_st_eop$i => rx_st_eop$i,";
         $vcs_connect_in .= "tx_st_eop$i => tx_st_eop$i,";
         $vcs_signals .= "e_port->new([tx_st_data$i => 64 => \"input\"]),";
         $vcs_connect_in .= "tx_st_data$i => tx_st_data$i,";

      }

      $vcs_connect_in .= "rx_st_mask$i => rx_st_mask$i,";
      $vcs_signals .= "e_port->new([rx_st_bardec$i => 8 => \"output\"]),";
      $vcs_connect_out .= "rx_st_bardec$i => rx_st_bardec$i,";

      $vcs_connect_out .= "rx_st_err$i => rx_st_err$i,";
      $vcs_connect_out .= "rx_st_sop$i => rx_st_sop$i,";


      if ($hip == 1) {
         $add_signals .= "e_signal->new({name => open_rx_st_sop$i\_p1, width => 1 ,never_export => 1}),";
         $vcs_connect_out .= "rx_st_sop$i\_p1 => open_rx_st_sop$i\_p1,";
         $vcs_connect_in .= "tx_st_sop$i\_p1 => \"1'b0\",";

         # add LTSSM port for debugging
         $add_signals .= "e_signal->new({name => ltssm, width => 5}),";
         $vcs_connect_out .= "dl_ltssm => ltssm,";
         $add_signals .= "e_signal->new({name => lane_act, width => 4}),";
         $vcs_connect_out .= "lane_act => lane_act,";

         # tx credit patch
         if ($c3gx == 0) {
            $vcs_connect_out .= "npd_alloc_1cred_vc$i => npd_alloc_1cred_vc$i,";
            $vcs_connect_out .= "nph_alloc_1cred_vc$i => nph_alloc_1cred_vc$i,";
            $vcs_connect_out .= "nph_cred_vio_vc$i => nph_cred_vio_vc$i,";
            $vcs_connect_out .= "npd_cred_vio_vc$i => npd_cred_vio_vc$i,";
         }

         # r2c error
         $vcs_connect_out .= "r2c_err$i => r2c_err$i,";

         if ($tl_selection != 8) { # Avalon ST (64/128)
            $add_signals .= "e_signal->new({name => ko_cpl_spc_vc$i, width => 20}),";
            $glue_logic .= "e_assign->new({lhs => {name => ko_cpl_spc_vc$i}, rhs => \"20'h$ko_cpl_spc_vc\"}),";

            # add misc ports
            $add_signals .= "e_signal->new({name => aer_msi_num, width => 5}),";
            if ($rp > 0) { # root port
               $vcs_connect_in .= "aer_msi_num => aer_msi_num,";
            } else {
               $vcs_connect_in .= "aer_msi_num => \"5'b00000\",";
            }

            # int_status for rp only
            if ($rp>0) {
               $vcs_connect_out .= "int_status => int_status,";
               $vcs_signals    .= "e_port->new([int_status => 4 => \"output\"]),";
            }

            $add_signals .= "e_signal->new({name => hpg_ctrler, width => 5}),";
            $vcs_connect_in .= "hpg_ctrler => hpg_ctrler,";
            $vcs_connect_in .= "pm_auxpwr => pm_auxpwr,";
            if ($rp > 0) { # root port
               $vcs_connect_in .= "pm_event => \"1'b0\",";
            } else {
               $vcs_connect_in .= "pm_event => pm_event,";
            }
            $add_signals .= "e_signal->new({name => pm_data, width => 10}),";
            $vcs_connect_in .= "pm_data => pm_data,";


            # Add LMI bus
            $add_signals .= "e_signal->new({name => lmi_addr, width => 12}),";
            $vcs_connect_in .= "lmi_addr => lmi_addr,";
            $add_signals .= "e_signal->new({name => lmi_din, width => 32}),";
            $vcs_connect_in .= "lmi_din => lmi_din,";
            $vcs_connect_in .= "lmi_rden => lmi_rden,";
            $vcs_connect_in .= "lmi_wren => lmi_wren,";
            $add_signals .= "e_signal->new({name => lmi_dout, width => 32}),";
            $vcs_connect_out .= "lmi_dout => lmi_dout,";
            $vcs_connect_out .= "lmi_ack => lmi_ack,";

            # ECC signals
            $vcs_connect_out .= "derr_cor_ext_rcv$i => derr_cor_ext_rcv$i,";
            $vcs_connect_out .= "derr_cor_ext_rpl => derr_cor_ext_rpl,";
            $vcs_connect_out .= "derr_rpl => derr_rpl,";
            if ($rp > 0) {
               $vcs_connect_out .= "serr_out => serr_out,";
            }


         } else { # TL bypass

            $vcs_connect_in .= "aer_msi_num => \"5'b00000\",";
            $vcs_connect_in .= "hpg_ctrler => \"5'b00000\",";
            $vcs_connect_in .= "lmi_addr => \"12'h000\",";
            $vcs_connect_in .= "lmi_din => \"32'h00000000\",";
            $vcs_connect_in .= "lmi_rden => \"1'b0\",";
            $vcs_connect_in .= "lmi_wren => \"1'b0\",";
            $vcs_connect_in .= "pm_auxpwr => \"1'b0\",";
            $vcs_connect_in .= "pm_event => \"1'b0\",";
            $vcs_connect_in .= "pm_data => \"10'b0000000000\",";

         }
      } else { # SIP
         if ($number_of_lanes < 8) {
            $vcs_signals .= "e_port->new([err_desc_func0 => 128 => \"input\"]),";
            $vcs_connect_in .= "err_desc_func0 => err_desc_func0,";
         }
      }



      $vcs_connect_in .= "tx_st_sop$i => tx_st_sop$i,";
      $vcs_connect_in .= "tx_st_err$i => tx_st_err$i,";
      $vcs_connect_in .= "tx_st_valid$i => tx_st_valid$i,";

      $vcs_signals .= "e_port->new([tx_fifo_wrptr$i => 4 => \"output\"]),";
      $vcs_connect_out .= "tx_fifo_wrptr$i => tx_fifo_wrptr$i,";
      $vcs_signals .= "e_port->new([tx_fifo_rdptr$i => 4 => \"output\"]),";
      $vcs_connect_out .= "tx_fifo_rdptr$i => tx_fifo_rdptr$i,";
      $vcs_connect_out .= "tx_st_ready$i => tx_st_ready$i,";
      $vcs_connect_out .= "tx_fifo_full$i => tx_fifo_full$i,";
      $vcs_connect_out .= "tx_fifo_empty$i => tx_fifo_empty$i,";
      $vcs_connect_out .= "rx_fifo_full$i => rx_fifo_full$i,";
      $vcs_connect_out .= "rx_fifo_empty$i => rx_fifo_empty$i,";
      $vcs_signals .= "e_port->new([tx_cred$i => $txcred_width => \"output\"]),";
      $add_signals .= "e_signal->new({name => tx_cred$i\_int, width=> $txcred_core_width, never_export => 1}),";
      if ($txcred_width == $txcred_core_width) {
         $vcs_connect_out .= "tx_cred$i => tx_cred$i,";
      } else {
         $vcs_connect_out .= "tx_cred$i => tx_cred$i\_int,";
         $glue_logic .= "e_assign->new ([tx_cred$i, => \"tx_cred$i\_int[$txcred_width-1:0]\"]),";

      }



   } else {
      # tie down HIPCAB interface
      $add_signals .= "e_signal->new({name => gnd_rx_st_ready$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_st_ready$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "rx_st_ready$i => gnd_rx_st_ready$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_valid$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_st_valid$i => open_rx_st_valid$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_data$i ,  width => 64 , never_export => 1}),";
      $vcs_connect_out .= "rx_st_data$i => open_rx_st_data$i,";

      $add_signals .= "e_signal->new({name => gnd_rx_st_mask$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_st_mask$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "rx_st_mask$i => gnd_rx_st_mask$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_bardec$i ,  width => 8 , never_export => 1}),";
      $vcs_connect_out .= "rx_st_bardec$i => open_rx_st_bardec$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_be$i ,  width => 8 , never_export => 1}),";
      $vcs_connect_out .= "rx_st_be$i => open_rx_st_be$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_err$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_st_err$i => open_rx_st_err$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_sop$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_st_sop$i => open_rx_st_sop$i,";

      $add_signals .= "e_signal->new({name => open_rx_st_eop$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_st_eop$i => open_rx_st_eop$i,";

      $add_signals .= "e_signal->new({name => gnd_tx_st_sop$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_sop$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "tx_st_sop$i => gnd_tx_st_sop$i,";

      $add_signals .= "e_signal->new({name => gnd_tx_st_eop$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_eop$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "tx_st_eop$i => gnd_tx_st_eop$i,";

      $add_signals .= "e_signal->new({name => gnd_tx_st_err$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_err$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "tx_st_err$i => gnd_tx_st_err$i,";

      $add_signals .= "e_signal->new({name => gnd_tx_st_valid$i ,  never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_valid$i , width => 1}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "tx_st_valid$i => gnd_tx_st_valid$i,";

      $add_signals .= "e_signal->new({name => gnd_tx_st_data$i ,  width => 64 , never_export => 1}),";
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_data$i , width => 64}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "tx_st_data$i => gnd_tx_st_data$i,";

      $add_signals .= "e_signal->new({name => open_tx_st_ready$i ,  never_export => 1}),";
      $vcs_connect_out .= "tx_st_ready$i => open_tx_st_ready$i,";

      $add_signals .= "e_signal->new({name => open_tx_fifo_full$i ,  never_export => 1}),";
      $vcs_connect_out .= "tx_fifo_full$i => open_tx_fifo_full$i,";

      $add_signals .= "e_signal->new({name => open_tx_fifo_empty$i ,  never_export => 1}),";
      $vcs_connect_out .= "tx_fifo_empty$i => open_tx_fifo_empty$i,";


      $add_signals .= "e_signal->new({name => open_rx_fifo_full$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_fifo_full$i => open_rx_fifo_full$i,";

      $add_signals .= "e_signal->new({name => open_rx_fifo_empty$i ,  never_export => 1}),";
      $vcs_connect_out .= "rx_fifo_empty$i => open_rx_fifo_empty$i,";

      $add_signals .= "e_signal->new({name => open_tx_fifo_wrptr$i ,  width => 4 , never_export => 1}),";
      $vcs_connect_out .= "tx_fifo_wrptr$i => open_tx_fifo_wrptr$i,";
      $add_signals .= "e_signal->new({name => open_tx_fifo_rdptr$i ,  width => 4 , never_export => 1}),";
      $vcs_connect_out .= "tx_fifo_rdptr$i => open_tx_fifo_rdptr$i,";

      if (($i == 0) & ($number_of_lanes < 8) & ($hip == 0)) {
         $add_signals .= "e_signal->new({name => gnd_err_desc_func0 ,  width => 128 , never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_err_desc_func0 , width => 128}, rhs => \"0\"}),";
         $vcs_connect_in .= "err_desc_func0 => gnd_err_desc_func0,";
      }

   }

   # TL bypass mode
   if ($tl_selection == 8) {

      # input
      $add_signals .= "e_signal->new({name => tlbp_dl_aspm_cr0, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_aspm_cr0 => tlbp_dl_aspm_cr0,";
      $add_signals .= "e_signal->new({name => tlbp_dl_comclk_reg, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_comclk_reg => tlbp_dl_comclk_reg,";
      $add_signals .= "e_signal->new({name => tlbp_dl_ctrl_link2, width=> 13}),";
      $vcs_connect_in .= "tlbp_dl_ctrl_link2 => tlbp_dl_ctrl_link2,";
      $add_signals .= "e_signal->new({name => tlbp_dl_data_upfc, width=> 12}),";
      $vcs_connect_in .= "tlbp_dl_data_upfc => tlbp_dl_data_upfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_hdr_upfc, width=> 8}),";
      $vcs_connect_in .= "tlbp_dl_hdr_upfc => tlbp_dl_hdr_upfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_inh_dllp, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_inh_dllp => tlbp_dl_inh_dllp,";
      $add_signals .= "e_signal->new({name => tlbp_dl_maxpload_dcr, width=> 3}),";
      $vcs_connect_in .= "tlbp_dl_maxpload_dcr => tlbp_dl_maxpload_dcr,";
      $add_signals .= "e_signal->new({name => tlbp_dl_req_phycfg, width=> 4}),";
      $vcs_connect_in .= "tlbp_dl_req_phycfg => tlbp_dl_req_phycfg,";
      $add_signals .= "e_signal->new({name => tlbp_dl_req_phypm, width=> 4}),";
      $vcs_connect_in .= "tlbp_dl_req_phypm => tlbp_dl_req_phypm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_req_upfc, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_req_upfc => tlbp_dl_req_upfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_req_wake, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_req_wake => tlbp_dl_req_wake,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rx_ecrcchk, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_rx_ecrcchk => tlbp_dl_rx_ecrcchk,";
      $add_signals .= "e_signal->new({name => tlbp_dl_snd_upfc, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_snd_upfc => tlbp_dl_snd_upfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_tx_reqpm, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_tx_reqpm => tlbp_dl_tx_reqpm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_tx_typpm, width=> 3}),";
      $vcs_connect_in .= "tlbp_dl_tx_typpm => tlbp_dl_tx_typpm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_txcfg_extsy, width=> 1}),";
      $vcs_connect_in .= "tlbp_dl_txcfg_extsy => tlbp_dl_txcfg_extsy,";
      $add_signals .= "e_signal->new({name => tlbp_dl_typ_upfc, width=> 2}),";
      $vcs_connect_in .= "tlbp_dl_typ_upfc => tlbp_dl_typ_upfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_vc_ctrl, width=> 8}),";
      $vcs_connect_in .= "tlbp_dl_vc_ctrl => tlbp_dl_vc_ctrl,";
      $add_signals .= "e_signal->new({name => tlbp_dl_vcid_map, width=> 24}),";
      $vcs_connect_in .= "tlbp_dl_vcid_map => tlbp_dl_vcid_map,";
      $add_signals .= "e_signal->new({name => tlbp_dl_vcid_upfc, width=> 3}),";
      $vcs_connect_in .= "tlbp_dl_vcid_upfc => tlbp_dl_vcid_upfc,";

      # outputs
      $add_signals .= "e_signal->new({name => tlbp_dl_ack_phypm, width=> 2}),";
      $vcs_connect_out .= "tlbp_dl_ack_phypm => tlbp_dl_ack_phypm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_ack_requpfc, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_ack_requpfc => tlbp_dl_ack_requpfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_ack_sndupfc, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_ack_sndupfc => tlbp_dl_ack_sndupfc,";
      $add_signals .= "e_signal->new({name => tlbp_dl_current_deemp, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_current_deemp => tlbp_dl_current_deemp,";
      $add_signals .= "e_signal->new({name => tlbp_dl_currentspeed, width=> 2}),";
      $vcs_connect_out .= "tlbp_dl_currentspeed => tlbp_dl_currentspeed,";
      $add_signals .= "e_signal->new({name => tlbp_dl_dll_req, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_dll_req => tlbp_dl_dll_req,";
      $add_signals .= "e_signal->new({name => tlbp_dl_err_dll, width=> 5}),";
      $vcs_connect_out .= "tlbp_dl_err_dll => tlbp_dl_err_dll,";
      $add_signals .= "e_signal->new({name => tlbp_dl_errphy, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_errphy => tlbp_dl_errphy,";
      $add_signals .= "e_signal->new({name => tlbp_dl_link_autobdw_status, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_link_autobdw_status => tlbp_dl_link_autobdw_status,";
      $add_signals .= "e_signal->new({name => tlbp_dl_link_bdwmng_status, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_link_bdwmng_status => tlbp_dl_link_bdwmng_status,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rpbuf_emp, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_rpbuf_emp => tlbp_dl_rpbuf_emp,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rst_enter_comp_bit, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_rst_enter_comp_bit => tlbp_dl_rst_enter_comp_bit,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rst_tx_margin_field, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_rst_tx_margin_field => tlbp_dl_rst_tx_margin_field,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rx_typ_pm, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_rx_typ_pm => tlbp_dl_rx_typ_pm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_rx_valpm, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_rx_valpm => tlbp_dl_rx_valpm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_tx_ackpm, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_tx_ackpm => tlbp_dl_tx_ackpm,";
      $add_signals .= "e_signal->new({name => tlbp_dl_up, width=> 1}),";
      $vcs_connect_out .= "tlbp_dl_up => tlbp_dl_up,";
      $add_signals .= "e_signal->new({name => tlbp_dl_vc_status, width=> 8}),";
      $vcs_connect_out .= "tlbp_dl_vc_status => tlbp_dl_vc_status,";
      $add_signals .= "e_signal->new({name => tlbp_link_up, width=> 1}),";
      $vcs_connect_out .= "tlbp_link_up => tlbp_link_up,";


   }

}


# S5GX 256 bit Unbonded
if ($phy_selection == $PHYSEL_SV) {

   # declare wire

   $add_signals .= "e_signal->new({name => rx_st_data_int, width=> 256, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_sop_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_eop_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_err_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_valid_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_bardec0, width=> 8}),";
   $add_signals .= "e_signal->new({name => rx_st_bardec1, width=> 8, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_be_int, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_parity_int, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_st_empty_int, width=> 2, never_export => 1}),";

   $add_signals .= "e_signal->new({name => tx_st_parity_int, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => tx_st_data_int, width=> 256, never_export => 1}),";
   $add_signals .= "e_signal->new({name => tx_st_empty_int, width=> 2, never_export => 1}),";
   $add_signals .= "e_signal->new({name => tx_st_sop_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => tx_st_eop_int, width=> 4, never_export => 1}),";
   $add_signals .= "e_signal->new({name => tx_st_err_int, width=> 4, never_export => 1}),";

   # connect internally all data paths
   $vcs_connect_in .= "tx_st_data   => tx_st_data_int,";
   $vcs_connect_in .= "tx_st_parity => tx_st_parity_int,";
   $vcs_connect_in .= "tx_st_empty  => tx_st_empty_int,";
   $vcs_connect_in .= "tx_st_sop    => tx_st_sop_int,";
   $vcs_connect_in .= "tx_st_eop    => tx_st_eop_int,";
   $vcs_connect_in .= "tx_st_err    => tx_st_err_int,";

   $vcs_connect_out .= "rx_st_bardec1 => rx_st_bardec0,";
   $vcs_connect_out .= "rx_st_be => rx_st_be_int,";
   $vcs_connect_out .= "rx_st_data => rx_st_data_int,";
   $vcs_connect_out .= "rx_st_parity => rx_st_parity_int,";
   $vcs_connect_out .= "rx_st_empty => rx_st_empty_int,";
   $vcs_connect_out .= "rx_st_sop => rx_st_sop_int,";
   $vcs_connect_out .= "rx_st_eop => rx_st_eop_int,";
   $vcs_connect_out .= "rx_st_err => rx_st_err_int,";
   $vcs_connect_out .= "rx_st_valid => rx_st_valid_int,";

   $vcs_connect_in .= "rx_st_mask => rx_st_mask0,";
   $vcs_connect_in .= "rx_st_ready => rx_st_ready0,";
   $vcs_connect_in .= "tx_st_valid => tx_st_valid0,";
   $vcs_connect_out .= "tx_st_ready => tx_st_ready0,";


   if ($tl_selection == 9) { # 256bit unbonded
      $data_wd = 256;
      $ctrl_wd = 1;
      $mty_wd = 2;
   } elsif ($tl_selection == 7) { # 128 bit unbonded
      $data_wd = 128;
      $ctrl_wd = 1;
      $mty_wd = 1;
   } elsif ($tl_selection == 6) { # 64 bit
      $data_wd = 64;
      $ctrl_wd = 1;
      $mty_wd = 0;
   }


   # output connections
   $vc = 0;
   $add_signals .= "e_signal->new({name => rx_st_data$vc, width=> $data_wd}),";
   $glue_logic .= "e_assign->new({lhs => {name => rx_st_data$vc}, rhs => \"rx_st_data_int[$data_wd - 1 :0]\"}),";

   foreach $sig ("sop","eop","err","valid") {
      $add_signals .= "e_signal->new({name => rx_st_$sig$vc, width=> $ctrl_wd}),";
      $glue_logic .= "e_assign->new({lhs => {name => rx_st_$sig$vc}, rhs => \"rx_st_$sig\_int[$ctrl_wd - 1 :0]\"}),";
   }


   # empty bus
   if ($mty_wd > 0) {
      $add_signals .= "e_signal->new({name => rx_st_empty$vc, width=> $mty_wd}),";
      $glue_logic .= "e_assign->new({lhs => {name => rx_st_empty$vc}, rhs => \"rx_st_empty\_int[$mty_wd - 1 :0]\"}),";
   }



   if ($ctrl_wd > 1) {
      $vcs_connect_out .= "rx_st_bardec2 => rx_st_bardec1,";
   }

   foreach $sig ("be","parity") {
      $add_signals .= "e_signal->new({name => rx_st_$sig$vc, width=> $data_wd/8}),";
      $glue_logic .= "e_assign->new({lhs => {name => rx_st_$sig$vc}, rhs => \"rx_st_$sig\_int[$data_wd/8 - 1 :0]\"}),";
   }

   # input connections
   $add_signals .= "e_signal->new({name => tx_st_data$vc, width=> $data_wd}),";
   $glue_logic .= "e_assign->new ([\"tx_st_data_int[$data_wd - 1 :0]\", => \"tx_st_data$vc\"]),";
   if ($data_wd < 256) {
      $glue_logic .= "e_assign->new ([\"tx_st_data_int[255 : $data_wd]\", => \"0\"]),";
   }

   foreach $sig ("sop","eop","err") {
      $add_signals .= "e_signal->new({name => tx_st_$sig$vc, width=> $ctrl_wd}),";
      $glue_logic .= "e_assign->new ([\"tx_st_$sig\_int[$ctrl_wd - 1 :0]\", => \"tx_st_$sig$vc\"]),";
      if ($ctrl_wd < 4) {
         $glue_logic .= "e_assign->new ([\"tx_st_$sig\_int[3: $ctrl_wd]\", => \"0\"]),";
      }
   }

   if ($mty_wd > 0) {
      $add_signals .= "e_signal->new({name => tx_st_empty$vc, width=> $mty_wd}),";
      $glue_logic .= "e_assign->new ([\"tx_st_empty_int[$mty_wd - 1 :0]\", => \"tx_st_empty$vc\"]),";
      if ($mty_wd < 2) {
         $glue_logic .= "e_assign->new ([\"tx_st_empty\_int[1: $mty_wd]\", => \"0\"]),";
      }
   } else {
      $glue_logic .= "e_assign->new ([\"tx_st_empty_int\", => \"0\"]),";
   }


   $add_signals .= "e_signal->new({name => tx_st_parity$vc, width=> $data_wd / 8}),";
   $glue_logic .= "e_assign->new ([\"tx_st_parity_int[$data_wd / 8 - 1 :0]\", => \"tx_st_parity$vc\"]),";
   if ($data_wd < 256) {
      $glue_logic .= "e_assign->new ([\"tx_st_parity_int[31 : $data_wd / 8]\", => \"0\"]),";
   }


   # add misc ports
   $add_signals .= "e_signal->new({name => aer_msi_num, width => 5}),";
   if ($rp > 0) { # root port
      $vcs_connect_in .= "aer_msi_num => aer_msi_num,";
   } else {
      $vcs_connect_in .= "aer_msi_num => \"5'b00000\",";
   }

   # power management signals
   $add_signals .= "e_signal->new({name => hpg_ctrler, width => 5}),";
   $vcs_connect_in .= "hpg_ctrler => hpg_ctrler,";
   if ($rp > 0) { # root port
      $vcs_connect_in .= "pm_event => \"1'b0\",";
   } else {
      $vcs_connect_in .= "pm_event => pm_event,";
   }
   $add_signals .= "e_signal->new({name => pm_data, width => 10}),";
   $vcs_connect_in .= "pm_data => pm_data,";


   $add_signals .= "e_signal->new({name => lane_act, width => 4}),";
   $vcs_connect_out .= "lane_act => lane_act,";
   $add_signals .= "e_signal->new({name => ltssm, width => 5}),";
   $vcs_connect_out .= "ltssmstate => ltssm,";
   $vcs_connect_in .= "pm_auxpwr => pm_auxpwr,";

   # Add LMI bus
   $add_signals .= "e_signal->new({name => lmi_addr, width => 12}),";
   $vcs_connect_in .= "lmi_addr => lmi_addr,";
   $add_signals .= "e_signal->new({name => lmi_din, width => 32}),";
   $vcs_connect_in .= "lmi_din => lmi_din,";
   $vcs_connect_in .= "lmi_rden => lmi_rden,";
   $vcs_connect_in .= "lmi_wren => lmi_wren,";
   $add_signals .= "e_signal->new({name => lmi_dout, width => 32}),";
   $vcs_connect_out .= "lmi_dout => lmi_dout,";
   $vcs_connect_out .= "lmi_ack => lmi_ack,";

   # Credit bus
   foreach $sig ("cp","np","p") {
      $add_signals .= "e_signal->new({name => tx_cred_datafc$sig, width => 12}),";
      $vcs_connect_out .= "tx_cred_datafc$sig => tx_cred_datafc$sig,";
      $add_signals .= "e_signal->new({name => tx_cred_hdrfc$sig, width => 8}),";
      $vcs_connect_out .= "tx_cred_hdrfc$sig => tx_cred_hdrfc$sig,";
   }

   foreach $sig ("hipcons","infinite") {
      $add_signals .= "e_signal->new({name => tx_cred_fc$sig, width => 6}),";
      $vcs_connect_out .= "tx_cred_fc$sig => tx_cred_fc$sig,";
   }



}

# tie off interrupt and misc signals
if (($tl_selection == 0) | ($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) { # native PLDA
   $gnd_ = "";
   $open_ = "";
} else {
   $gnd_ = "gnd_";
   $open_ = "open_";

   $add_signals .= "e_signal->new({name => open_cfg_busdev, width=> 13, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_devcsr, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_linkcsr, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_tcvcmap, width=> 24, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_msicsr, width=> 16, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_pmcsr, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_cfg_prmcsr, width=> 32, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_app_msi_ack, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_pme_to_sr, never_export => 1}),";
   $add_signals .= "e_signal->new({name => open_app_int_ack, never_export => 1}),";

   $add_signals .= "e_signal->new({name => gnd_cpl_pending, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_cpl_err, width=> 7, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_pme_to_cr, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_app_int_sts, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_app_msi_req, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_app_msi_tc, width=> 3, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_app_msi_num, width=> 5, never_export => 1}),";
   $add_signals .= "e_signal->new({name => gnd_pex_msi_num, width=> 5, never_export => 1}),";

   $glue_logic .= "e_assign->new({lhs => {name => gnd_cpl_pending}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_cpl_err, width=> 7}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_pme_to_cr}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_app_int_sts}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_app_msi_req}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_app_msi_tc, width=> 3}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_app_msi_num, width=> 5}, rhs => \"0\"}),";
   $glue_logic .= "e_assign->new({lhs => {name => gnd_pex_msi_num, width=> 5}, rhs => \"0\"}),";


}
##################################################
# Alt2gxb specific signals
##################################################
$alt2gxb_in = " ";
$alt2gxb_out = " ";

if ($phy_selection == 2)   { # S2GX

   $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 3}),";
   $glue_logic .= "e_port->new([ reconfig_togxb => 3 => \"input\"]),";
   if ($number_of_lanes < 8) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 1}),";
   } else {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 2}),";
   }

   $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
   $alt2gxb_in .= "reconfig_clk => reconfig_clk,";

   $alt2gxb_out .= "reconfig_fromgxb => reconfig_fromgxb,";
   $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";

}

if ($phy_selection == $PHYSEL_HIP_40nm)   { # S4GX

   $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 4}),";
   $glue_logic .= "e_port->new([ reconfig_togxb => 4 => \"input\"]),";


   if ($c3gx == 1) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 5}),";
   } elsif ($number_of_lanes < 8) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 17}),";
   } else {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 34}),";
   }

   $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";

   $alt2gxb_in .= "reconfig_clk => reconfig_clk,";
   $alt2gxb_out .= "reconfig_fromgxb => reconfig_fromgxb,";
   $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";

}


##################################################
# add reset logic for SOPC mode
##################################################

if (($tl_selection >= 1) & ($tl_selection <= 5)) { # Avalon MM mode

   # reset logic
   $add_signals .= "e_signal->new({name => rsnt_cntn, width=> 11, never_export => 1}),";
   $glue_logic .= "e_assign->new ([npor => \"pcie_rstn\"]),";

   $glue_logic .= "e_process->new({
   comment => \"reset Synchronizer to PCIe clock\",
   clock => \"$clkfreq_in\",
   reset => \"npor\",
   asynchronous_contents => [
   e_assign->new([\"npor_r\" => 0]),
   e_assign->new([\"npor_rr\" => 0]),
   ],
   user_attributes_names => [\"npor_r\",\"npor_rr\"],
   user_attributes => [
   {
   attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
   attribute_operator => '=',
   attribute_values => ['R102'],
   },
   ],
   contents => [
   e_assign->new([\"npor_r\" => 1]),
   e_assign->new([\"npor_rr\" => \"npor_r\"]),
   ],
   }),";

   $glue_logic .= "e_process->new({
   comment => \"generate system reset request\",
   clock => \"$clkfreq_in\",
   contents => [
   e_if->new({
   condition => \"(reset_n_rr == 1'b0)\",
   then => [\"RxmResetRequest_o\" => 0],
   else => [
   e_if->new({
   condition => \"(npor_rr == 1'b0) | (l2_exit == 1'b0) | (hotrst_exit == 1'b0) | (dlup_exit == 1'b0) $disable_rst $freqlk\",
   then => [\"RxmResetRequest_o\" => 1]
   }),
   ],
   }),
   ],
   }),";


   $glue_logic .= "e_process->new({
   comment => \"reset Synchronizer to PCIe clock\",
   clock => \"$clkfreq_in\",
   reset => \"reset_n\",
   asynchronous_contents => [
   e_assign->new([\"reset_n_r\" => 0]),
   e_assign->new([\"reset_n_rr\" => 0]),
   ],
   user_attributes_names => [\"reset_n_r\",\"reset_n_rr\"],
   user_attributes => [
   {
   attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
   attribute_operator => '=',
   attribute_values => ['R105'],
   },
   ],
   contents => [
   e_assign->new([\"reset_n_r\" => 1]),
   e_assign->new([\"reset_n_rr\" => \"reset_n_r\"]),
   ],
   }),";

   $glue_logic .= "e_process->new({
   comment => \"reset counter\",
   clock => \"$clkfreq_in\",
   reset => \"reset_n_rr\",
   asynchronous_contents => [
   e_assign->new([\"rsnt_cntn\" => '0']),
   ],
   contents => [
   e_if->new({
   condition => \"rsnt_cntn != 4'hf\",
   then => [\"rsnt_cntn\" => \"rsnt_cntn + 1\"],
   }),
   ],
   }),";


   $glue_logic .= "e_process->new({
   comment => \"sync and config reset\",
   clock => \"$clkfreq_in\",
   reset => \"reset_n_rr\",
   asynchronous_contents => [
   e_assign->new([\"srst\" => '1']),
   e_assign->new([\"crst\" => '1'])
   ],
   contents => [
   e_if->new({
   condition => \"(rsnt_cntn == 4'hf)\",
   then => [\"srst\" => 0,\"crst\" => 0],
   }),
   ],
   }),";

}


##################################################
# Instantiate user variation
##################################################

my $label = " ";
my @label;



##################################################
# instantiation of internal phy
##################################################
$alt4gxb_in = " ";
$alt4gxb_out = " ";

if (($phy_selection == $PHYSEL_HIP_40nm) || ($phy_selection == 2)) { # S4GX or S2GX

   for ($i = 0; $i < $number_of_lanes; $i++) {
      $glue_logic .= "e_assign->new({lhs => \"rx_in[$i]\", rhs =>\"rx_in$i\"}),";
      $glue_logic .= "e_assign->new({lhs => \"tx_out$i\", rhs =>\"tx_out[$i]\"}),";
   }


   if ($hip == 1) {
      if (
         (($gen2_rate == 1) & ($number_of_lanes == 8)) ||
         (($gen2_rate == 1) & ($number_of_lanes == 4) & ($tl_selection == 6)) ||
         (($gen2_rate == 0) & ($number_of_lanes == 8) & ($tl_selection == 6))
      ) { # divide down clock
         $glue_logic .= "e_assign->new({lhs => \"rc_inclk_eq_125mhz\", rhs =>\"0\"}),";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"rc_inclk_eq_125mhz\", rhs =>\"1\"}),";
      }

   } else { # soft IP
      if ($number_of_lanes < 8) {
         $glue_logic .= "e_assign->new({lhs => \"fixedclk\", rhs =>\"clk125_in\"}),";
      } else {
         $glue_logic .= "e_process->new({
         comment => \"Div down pld_clk with T-Flop to drive fixedclk\",
         clock => \"clk250_in\",
         reset => \"npor\",
         asynchronous_contents => [
         e_assign->new([\"fixedclk\" => 0]),
         ],
         user_attributes_names => [\"fixedclk\"],
         user_attributes => [
         {
         attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
         attribute_operator => '=',
         attribute_values => ['R102'],
         },
         ],
         contents => [
         e_assign->new([\"fixedclk\" => \"~fixedclk\"]),
         ],

         }),";

      }
      $glue_logic .= "e_assign->new({lhs => \"rc_inclk_eq_125mhz\", rhs =>\"1\"}),";
   }
   # serdes clocking
   if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm)) { # S4GX, A2GX, C4GX
      if ($number_of_lanes > 1) { # x4 or x8
         $add_signals .= "e_signal->new({name => hip_tx_clkout, width=> $number_of_lanes, never_export => 1}),";
         $alt4gxb_out .= "hip_tx_clkout => \"hip_tx_clkout\",\n";
         $glue_logic .= "e_assign->new({lhs => \"pclk_central_serdes\", rhs =>\"hip_tx_clkout[0]\"}),";
         $glue_logic .= "e_assign->new({lhs => \"pclk_ch0_serdes\", rhs =>\"pclk_central_serdes\"}),";



      } else {
         $alt4gxb_out = "hip_tx_clkout => \"pclk_ch0_serdes\",\n";
         $glue_logic .= "e_assign->new({lhs => \"pclk_central_serdes\", rhs =>\"0\"}),";
      }

      $hi = $number_of_lanes - 1;
      if ($c3gx == 0) {
         $alt4gxb_in .= "tx_pipedeemph => \"tx_deemph[$hi : 0]\",";
      }

      $hi = ($number_of_lanes * 3) - 1;
      $alt4gxb_in .= "rx_elecidleinfersel => \"eidle_infer_sel[$hi : 0]\",";
      if ($c3gx == 0) {
         $alt4gxb_in .= "tx_pipemargin => \"tx_margin[$hi : 0]\",";
      }


      if ($number_of_lanes > 4) {
         $add_signals .= "e_signal->new({name => rateswitchbaseclock, width=> 2 , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"pll_fixed_clk_serdes\", rhs =>\"rateswitchbaseclock[0]\"}),";
      } else {
         $add_signals .= "e_signal->new({name => rateswitchbaseclock, width=> 1 , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"pll_fixed_clk_serdes\", rhs =>\"rateswitchbaseclock\"}),";
      }

      if ($c3gx == 0) { # S4GX A2GX
         $alt4gxb_out .= "rateswitchbaseclock => \"rateswitchbaseclock\",";
         $alt4gxb_out .=  "rx_signaldetect => \"rx_signaldetect\",";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"rateswitchbaseclock\", rhs =>\"pclk_ch0_serdes\"}),";
     }


      # pll_powerdown signals

      if (($number_of_lanes == 8) & ($gen2_rate == 1) & ($s4gxes == 1)) {
         $add_signals .= "e_signal->new({name => pll_powerdown_i, width=> 2 , never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"pll_powerdown_i\", rhs =>\"{2{pll_powerdown_int}}\"}),";
         $alt4gxb_in .= "pll_powerdown => \"pll_powerdown_i\",";
      } elsif ($c3gx==0) {
         $alt4gxb_in .= "pll_powerdown => \"pll_powerdown_int\",";
      } elsif ($c3gx==1) {
         $alt4gxb_in .= "pll_areset => \"pll_powerdown_int\",";
      }



      if (($number_of_lanes == 8) & ($gen2_rate == 1) & ($s4gxes == 1)) {
         $add_signals .= "e_signal->new({name => pll_locked, width=> 2, never_export => 1}),";
         $add_signals .= "e_signal->new({name => ratesw, width=> 2, never_export => 1}),";
         $glue_logic .= "e_assign->new({lhs => \"ratesw\", rhs =>\"{rateswitch[0],rateswitch[0]}\"}),";
         $alt4gxb_in .=  "rateswitch => \"ratesw\",";

      } else {
         $add_signals .= "e_signal->new({name => pll_locked, width=> 1, never_export => 1}),";
         if ($c3gx == 0) {
            $alt4gxb_in .=  "rateswitch => \"rateswitch[0]\",";
         }

      }
   } else {
      if ($number_of_lanes == 1) {
         $alt2gxb_out .= "tx_clkout => \"clk125_serdes\",\n";
      } elsif ($number_of_lanes == 4) {
         $alt2gxb_out .= "coreclkout => \"clk125_serdes\",\n";
      } else {
         $add_signals .= "e_signal->new({name => coreclkout, width=> 2 , never_export => 1}),";
         $alt2gxb_out .= "coreclkout => \"coreclkout\",\n";
         $glue_logic .= "e_assign->new({lhs => \"clk250_serdes\", rhs =>\"coreclkout[0]\"}),";
      }

      if ($number_of_lanes < 8) {
         $add_signals .= "e_signal->new({name => pll_locked, width=> 1, never_export => 1}),";
      } else {
         $add_signals .= "e_signal->new({name => pll_locked, width=> 2, never_export => 1}),";
      }

      if ($phy_selection == $PHYSEL_HIP_40nm) {
         if ($c3gx==0) {
            $alt4gxb_in .= "pll_powerdown => \"pll_powerdown_int\",";
         } else {
            $alt4gxb_in .= "pll_areset => \"pll_powerdown_int\",";
         }
      }
   }



   $glue_logic .= "e_assign->new({lhs => \"rc_pll_locked\", rhs =>\"(pipe_mode_int == 1'b1) ? 1'b1 : &pll_locked\"}),";
   $glue_logic .= "e_port->new([ rc_pll_locked => 1 => \"output\"]),";
   $glue_logic .= "e_port->new([ gxb_powerdown => 1 => \"input\"]),";

   $glue_logic .= "e_assign->new({lhs => \"gxb_powerdown_int\", rhs =>\"(pipe_mode_int == 1'b1) ? 1'b1 : gxb_powerdown\"}),";

   # add PLL powerdown for S4GX
   if ($phy_selection == $PHYSEL_HIP_40nm){
      $glue_logic .= "e_assign->new({lhs => \"pll_powerdown_int\", rhs =>\"(pipe_mode_int == 1'b1) ? 1'b1 : pll_powerdown\"}),";
   }

   # special hack for S4GX ES Gen2 x8
   if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm) & ($number_of_lanes == 8) & ($gen2_rate == 1) & ($s4gxes == 1)) {
      $add_signals .= "e_signal->new({name => coreclkout, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => cmu_rateswitchin_int, width=> 2, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"cmu_rateswitchin_int\", rhs =>\"{pcie_sw_out,pcie_sw_out}\"}),";
      $alt4gxb_in .=  "cmu_rateswitchin => \"cmu_rateswitchin_int\",";
      $alt4gxb_out .=  "pcie_sw => \"pcie_sw\",";
      $alt4gxb_out .=  "coreclkout => \"coreclkout\",";
      $alt4gxb_in .=  "pll_inclk_slave => \"refclk_sq\",";
   } else {
   }


   # C3GX has some missing ports
   if ($c3gx == 0) {
      $alt4gxb_in  .= "rx_cruclk => \"rx_cruclk\",";
      $alt4gxb_out .= "rx_pll_locked => \"rx_pll_locked\",";
   } else {
      $glue_logic .= "e_assign->new({lhs => \"rx_pll_locked\", rhs =>\"{$number_of_lanes\{1'b1}}\"}),";
      $tovector = "'pll_inclk'";
   }
   my $fixedclk_serdes_port_map= ($phy_selection==$PHYSEL_HIP_40nm) ?'fixedclk => "fixedclk_serdes",':'fixedclk => "fixedclk",';
   $label = "alt4gxb";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         module => "$var\_serdes",
         name => "serdes",
         in_port_map => {
            tx_digitalreset => "rc_tx_digitalreset",
            rx_analogreset => "rc_rx_analogreset",
            rx_digitalreset => "rx_digitalreset_serdes",
            gxb_powerdown => "gxb_powerdown_int",
            rx_datain => "rx_in",
            tx_datain => "txdata",
            tx_ctrlenable => "txdatak",
            tx_detectrxloop => "txdetectrx",
            tx_forceelecidle => "txelecidle",
            tx_forcedispcompliance => "txcompl",
            pipe8b10binvpolarity => "rxpolarity",
            powerdn => "powerdown",

            pll_inclk => "refclk",

            eval($fixedclk_serdes_port_map),
            eval($alt2gxb_in),
            eval($alt4gxb_in),


         },
         out_port_map => {
            eval($alt2gxb_out),
            eval($alt4gxb_out),
            pll_locked => "pll_locked",
            tx_dataout => "tx_out",
            rx_dataout => "rxdata_pcs",
            rx_ctrldetect => "rxdatak_pcs",
            pipedatavalid => "rxvalid_pcs",
            pipephydonestatus => "phystatus_pcs",
            pipeelecidle => "rxelecidle_pcs",
            pipestatus => "rxstatus_pcs",
            rx_freqlocked => "rx_freqlocked",

         },
         std_logic_vector_signals => [
         'gxb_powerdown',
         'pll_powerdown',
         'tx_digitalreset',
         'rx_digitalreset',
         'rx_analogreset',
         'rx_signaldetect',
         'tx_ctrlenable',
         'pipe8b10binvpolarity',
         'rateswitch',
         'coreclkout',
         'reconfig_fromgxb',
         'rx_cruclk',
         'rx_datain',
         'tx_detectrxloop',
         'tx_forcedispcompliance',
         'tx_pipedeemph',
         'hip_tx_clkout',
         'pipedatavalid',
         'pipeelecidle',
         'pipephydonestatus',
         'pll_locked',
         'rateswitchbaseclock',
         'pcie_sw',
    eval($tovector),
    'pll_areset',
         'rx_ctrldetect',
         'rx_freqlocked',
         'rx_pll_locked',
         'tx_dataout',
         'tx_forceelecidle',
         'tx_invpolarity',
         'tx_clkout'
         ],

      });


   # S4GX ES silicon workaround
   if (($phy_selection == $PHYSEL_HIP_40nm) & ($number_of_lanes == 8) & ($gen2_rate == 1) & ($s4gxes == 1)) {
      $add_signals .= "e_signal->new({name => open_c0, never_export => 1}),";
      $add_signals .= "e_signal->new({name => user_offset, width=> 8, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"user_offset\", rhs =>\"8'h15\", comment => \"User can use this parameter to compensate for the skew between the master and slave coreclkout\"}),";
      $add_signals .= "e_signal->new({name => onestep, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"onestep\", rhs =>\"0\", comment => \"Force the aligner to do one step phase shift\"}),";
      $add_signals .= "e_signal->new({name => onestepdir, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"onestepdir\", rhs =>\"0\", comment => \"Determines the direction of phase shift when onestep is asserted\"}),";
      $add_signals .= "e_signal->new({name => alignlock, never_export => 1}),";
      $add_signals .= "e_signal->new({name => align_rst, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"align_rst\", rhs =>\"~rc_pll_locked | ~npor | ~gpll_locked\"}),";
      $add_signals .= "e_signal->new({name => pcie_sw, never_export => 1}),";
      $add_signals .= "e_signal->new({name => pcie_sw_out, never_export => 1}),";
      $add_signals .= "e_signal->new({name => refclk_sq, never_export => 1}),";

      $label = "gpll";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            module => "altpcie_pclk_pll",
            name => "gpll",
            in_port_map => {
               inclk0 => "refclk",
               phasecounterselect => "4'h0",
               phasestep => "phasestep",
               phaseupdown => "phasedown",
               scanclk => "reconfig_clk",

            },
            out_port_map => {
               c0 => "open_c0",
               c1 => "refclk_sq",
               locked => "gpll_locked",
               phasedone => "phasedone",

            },

         });


      $label = "align";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            module => "altpcie_pclk_align",
            name => "align",
            in_port_map => {
               rst => "align_rst",
               clock => "refclk",
               offset => "user_offset",
               onestep => "onestep",
               onestep_dir => "onestepdir",
               PCLK_Master => "coreclkout[0]",
               PCLK_Slave => "coreclkout[1]",
               PhaseDone => "phasedone",
               pcie_sw_in => "pcie_sw",

            },
            out_port_map => {
               PhaseStep => "phasestep",
               PhaseUpDown => "phasedown",
               AlignLock => "alignlock",
               pcie_sw_out => "pcie_sw_out",

            },

         });


   }

   # simulation PLLs
   if ($hip == 1) {

      if ($refclk_selection == 0) { #100 Mhz
         $label = "sim_pll";
         @label = (@label,$label);
         $$label = e_blind_instance->new({
               module => "altpcie_pll_100_250",
               name => "refclk_to_250mhz",
               tag => "simulation",
               in_port_map => {
                  areset => "1'b0",
                  inclk0 => "refclk",
               },
               out_port_map => {
                  c0 => "clk250_out",
               },

            });
      } elsif ($refclk_selection == 1) { #125 Mhz
         $label = "sim_pll";
         @label = (@label,$label);
         $$label = e_blind_instance->new({
               module => "altpcie_pll_125_250",
               name => "refclk_to_250mhz",
               tag => "simulation",
               in_port_map => {
                  areset => "1'b0",
                  inclk0 => "refclk",
               },
               out_port_map => {
                  c0 => "clk250_out",
               },

            });
      } else {
         die "Not supported refclk mode:$refclk_selection\n";
      }

      $label = "sim_pll_x2";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            module => "altpcie_pll_125_250",
            name => "pll_250mhz_to_500mhz",
            tag => "simulation",
            in_port_map => {
               areset => "1'b0",
               inclk0 => "clk250_out",
            },
            out_port_map => {
               c0 => "clk500_out",
            },

         });
   } else { # soft IP


      if ($refclk_selection == 0) { # 100 Mhz
         if ($number_of_lanes < 8) {
            $label = "sim_pll";
            @label = (@label,$label);
            $$label = e_blind_instance->new({
                  module => "altpcie_pll_100_125",
                  name => "refclk_to_125mhz",
                  tag => "simulation",
                  in_port_map => {
                     areset => "1'b0",
                     inclk0 => "refclk",
                  },
                  out_port_map => {
                     c0 => "clk125_pll",
                  },

               });

         } else {

            $label = "sim_pll";
            @label = (@label,$label);
            $$label = e_blind_instance->new({
                  module => "altpcie_pll_100_250",
                  name => "refclk_to_250mhz",
                  tag => "simulation",
                  in_port_map => {
                     areset => "1'b0",
                     inclk0 => "refclk",
                  },
                  out_port_map => {
                     c0 => "clk250_pll",
                  },

               });
         }
      } elsif ($refclk_selection == 1) { # 125Mhz only x1 and x4
         $glue_logic .= "e_assign->new({lhs => \"clk125_pll\", rhs =>\"refclk\"}),";
      } else {
         die "Not supported refclk mode:$refclk_selection\n";
      }
   }

   # tied pipe_mode_int to ground for synthesis
   if (($phy_selection == 2) || ($phy_selection == $PHYSEL_HIP_40nm)) {
      $glue_logic .= "e_assign->new({lhs => \"pipe_mode_int\", rhs =>\"pipe_mode\", tag => simulation}),";
      $glue_logic .= "e_assign->new({lhs => \"pipe_mode_int\", rhs =>\"0\", tag => synthesis}),";
   }


   $add_signals .= "e_signal->new({name => rx_cruclk, width=> $number_of_lanes, never_export => 1}),";
   $glue_logic .= "e_assign->new({lhs => \"rx_cruclk\", rhs =>\"{$number_of_lanes\{refclk}}\"}),";

   if ($phy_selection == $PHYSEL_HIP_40nm) {
       $glue_logic .= "e_assign->new({lhs => \"rc_areset\", rhs =>\"pipe_mode_int | ~npor | busy_altgxb_reconfig\"}),";
   } else {
       $glue_logic .= "e_assign->new({lhs => \"rc_areset\", rhs =>\"pipe_mode_int | ~npor\"}),";
   }

   if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm)) {
      $glue_logic .= "e_assign->new({lhs => \"pclk_central\", rhs =>\"(pipe_mode_int == 1'b1) ? pclk_in : pclk_central_serdes \"}),";
      $glue_logic .= "e_assign->new({lhs => \"pclk_ch0\", rhs =>\"(pipe_mode_int == 1'b1) ? pclk_in : pclk_ch0_serdes \"}),";
      $add_signals .= "e_signal->new({name => rateswitch, width=> $number_of_lanes, never_export => 1}),";
      $glue_logic .= "e_assign->new({lhs => \"rateswitch\", rhs =>\"{$number_of_lanes\{rate_int}}\"}),";
      $glue_logic .= "e_assign->new({lhs => \"rate_ext\", rhs =>\"pipe_mode_int ? rate_int : 0\"}),";
      $add_signals .= "e_signal->new({name => tx_margin, width=> 24, never_export => 1}),";
      $pipe_connect_out .= "tx_margin => \"tx_margin\",";
      $add_signals .= "e_signal->new({name => tx_deemph, width=> 8, never_export => 1}),";
      $pipe_connect_out .= "tx_deemph => \"tx_deemph\",";
      $add_signals .= "e_signal->new({name => eidle_infer_sel, width=> 24, never_export => 1}),";
      $pipe_connect_out .= "eidle_infer_sel => \"eidle_infer_sel\",";

      if ($gen2_rate == 1) {
         $glue_logic .= "e_assign->new({lhs => \"pll_fixed_clk\", rhs =>\"(pipe_mode_int == 1'b1) ? clk500_out : pll_fixed_clk_serdes \"}),";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"pll_fixed_clk\", rhs =>\"(pipe_mode_int == 1'b1) ? clk250_out : pll_fixed_clk_serdes \"}),";
      }


      # SOPC mode HIP
      if (($tl_selection >= 1) & ($tl_selection <= 5)) {
         $glue_logic .= "e_assign->new({lhs => \"pclk_in\", rhs =>\"(rate_ext == 1'b1) ? clk500_out : clk250_out\"}),";
      } else {
         $add_signals .= "e_port->new([ core_clk_out => 1 => \"output\"]),";
      }
      $add_signals .= "e_port->new([ clk250_out => 1 => \"output\"]),";
      $add_signals .= "e_port->new([ clk500_out => 1 => \"output\"]),";
      $add_signals .= "e_port->new([ rate_ext => 1 => \"output\"]),";


   } else {
      if ($number_of_lanes < 8) {
         $glue_logic .= "e_assign->new({lhs => \"clk125_out\", rhs =>\"(pipe_mode_int == 1'b1) ? clk125_pll : clk125_serdes \"}),";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"clk250_out\", rhs =>\"(pipe_mode_int == 1'b1) ? clk250_pll : clk250_serdes \"}),";
      }
   }

   $add_signals .= "e_signal->new({name => rx_freqlocked, width=> $number_of_lanes, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_signaldetect, width=> $number_of_lanes, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rx_pll_locked, width=> $number_of_lanes, never_export => 1}),";




   if (($phy_selection == $PHYSEL_HIP_40nm) & ($hip == 1)) { # For S4GX, A2GX
      # For backward compatilbility
      $glue_logic .= "e_assign->new({lhs => \"rc_rx_pll_locked_one\", rhs =>\"&(rx_pll_locked | rx_freqlocked)\"}),";
      $add_signals .= "e_signal->new({name => use_rst_sd_mon, width=> 1, never_export => 1}),";
      if ($c3gx==1) {
         $glue_logic .= "e_assign->new({lhs => \"use_c4gx_serdes\", rhs =>\"1'b1\"}),";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"use_c4gx_serdes\", rhs =>\"1'b0\"}),";
      }
      $add_signals .= "e_signal->new({name => fifo_err, width=> 1, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"fifo_err\", rhs =>\"1'b0\"}),";

      $add_signals .= "e_signal->new({name => rx_freqlocked_byte, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_pll_locked_byte, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_signaldetect_byte, width=> 8, never_export => 1}),";

      if ($number_of_lanes==1) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[0]\", rhs =>\"rx_freqlocked[0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[7:1]\", rhs =>\"7'h7F\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[0]\", rhs =>\"rx_pll_locked[0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[7:1]\", rhs =>\"7'h7F\"}),";
      } elsif ($number_of_lanes==2) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[1:0]\", rhs =>\"rx_freqlocked[1:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[7:2]\", rhs =>\"6'h3F\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[1:0]\", rhs =>\"rx_pll_locked[1:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[7:2]\", rhs =>\"6'h3F\"}),";
      } elsif ($number_of_lanes==4) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[3:0]\", rhs =>\"rx_freqlocked[3:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[7:4]\", rhs =>\"4'hF\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[3:0]\", rhs =>\"rx_pll_locked[3:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[7:4]\", rhs =>\"4'hF\"}),";
      } else {
         $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[7:0]\", rhs =>\"rx_freqlocked[7:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[7:0]\", rhs =>\"rx_pll_locked[7:0]\"}),";
      }

      if ($c3gx==1) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[7:0]\", rhs =>\"8'hFF\"}),";
      } elsif ($number_of_lanes==1) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[0]\", rhs =>\"rx_signaldetect[0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[7:1]\", rhs =>\"7'h0\"}),";
      } elsif ($number_of_lanes==2) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[1:0]\", rhs =>\"rx_signaldetect[1:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[7:2]\", rhs =>\"6'h0\"}),";
      } elsif ($number_of_lanes==4) {
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[3:0]\", rhs =>\"rx_signaldetect[3:0]\"}),";
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[7:4]\", rhs =>\"4'h0\"}),";
      } else {
         $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[7:0]\", rhs =>\"rx_signaldetect[7:0]\"}),";
      }

      # add altpcie_rs_serdes

      $add_signals .= "e_signal->new({name => detect_mask_rxdrst, width=> 1, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"detect_mask_rxdrst\", rhs =>\"1'b0\"}),";

      $label = "rs_serdes";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
      module => "altpcie_rs_serdes",
      name => "rs_serdes",
      in_port_map => {
         test_in              => "test_in",
         ltssm                => "ltssm",
         npor                 => "npor",
         pld_clk              => "pld_clk",
         pll_locked           => "rc_pll_locked",
         use_c4gx_serdes      => "use_c4gx_serdes",
         detect_mask_rxdrst   => "detect_mask_rxdrst",
         busy_altgxb_reconfig => "busy_altgxb_reconfig",
         rx_pll_locked        => "rx_pll_locked_byte",
         rx_freqlocked        => "rx_freqlocked_byte",
         rx_signaldetect      => "rx_signaldetect_byte",
         fifo_err             => "fifo_err",
         rc_inclk_eq_125mhz   => "rc_inclk_eq_125mhz",
      },
      out_port_map => {
         txdigitalreset       =>"rc_tx_digitalreset",
         rxanalogreset        =>"rc_rx_analogreset",
         rxdigitalreset       =>"rx_digitalreset_serdes",
      },

      });

      } elsif (($phy_selection == $PHYSEL_HIP_40nm) & ($hip == 0)) { # For S4GX, A2GX SIP
      $glue_logic .= "e_assign->new({lhs => \"rc_rx_pll_locked_one\", rhs =>\"1'b0\"}),";
      $add_signals .= "e_signal->new({name => use_rst_sd_mon, width=> 1, never_export => 1}),";
      if ($c3gx==1) {
         $glue_logic .= "e_assign->new({lhs => \"use_c4gx_serdes\", rhs =>\"1'b1\"}),";
      } else {
         $glue_logic .= "e_assign->new({lhs => \"use_c4gx_serdes\", rhs =>\"1'b0\"}),";
      }
      $add_signals .= "e_signal->new({name => fifo_err, width=> 1, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"fifo_err\", rhs =>\"1'b0\"}),";

      $add_signals .= "e_signal->new({name => rx_freqlocked_byte, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_pll_locked_byte, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_signaldetect_byte, width=> 8, never_export => 1}),";

      for ($i = 0; $i < 8; $i++) {
	  if ($i < $number_of_lanes) {
	      $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[$i]\", rhs =>\"rx_freqlocked[$i]\"}),";
	      $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[$i]\", rhs =>\"rx_pll_locked[$i]\"}),";
	      $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[$i]\", rhs =>\"rxvalid_pcs[$i] | rx_digitalreset_serdes\"}),";

	  } else {
	      $glue_logic  .= "e_assign->new({lhs => \"rx_freqlocked_byte[$i]\", rhs =>\"1'b1\"}),";
	      $glue_logic  .= "e_assign->new({lhs => \"rx_pll_locked_byte[$i]\", rhs =>\"1'b1\"}), ";
	      $glue_logic  .= "e_assign->new({lhs => \"rx_signaldetect_byte[$i]\", rhs =>\"1'b1\"}),";
	  }
      }

      # add altpcie_rs_serdes

      $add_signals .= "e_signal->new({name => detect_mask_rxdrst, width=> 1, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"detect_mask_rxdrst\", rhs =>\"1'b0\"}),";

      $add_signals .= "e_signal->new({name => ltssm, width=> 5, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"ltssm\", rhs =>\"test_out_int[324:320]\"}),";

      $add_signals .= "e_signal->new({name => test_in_rs, width=> 40, never_export => 1}),";
      $glue_logic  .= "e_assign->new({lhs => \"test_in_rs\", rhs =>\"{8'h00,test_in}\"}),";

      $add_signals .= "e_signal->new({name => rc_tx_digitalreset, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rc_rx_analogreset, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rc_rx_digitalreset, width=> 1, never_export => 1}),";


      $label = "rs_serdes";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
      module => "altpcie_rs_serdes",
      name => "rs_serdes",
      in_port_map => {
         test_in              => "test_in_rs",
         ltssm                => "ltssm",
         npor                 => "npor",
         pld_clk              => "clk125_in",
         pll_locked           => "rc_pll_locked",
         use_c4gx_serdes      => "use_c4gx_serdes",
         detect_mask_rxdrst   => "detect_mask_rxdrst",
         busy_altgxb_reconfig => "busy_altgxb_reconfig",
         rx_pll_locked        => "rx_pll_locked_byte",
         rx_freqlocked        => "rx_freqlocked_byte",
         rx_signaldetect      => "rx_signaldetect_byte",
         fifo_err             => "fifo_err",
         rc_inclk_eq_125mhz   => "rc_inclk_eq_125mhz",
      },
      out_port_map => {
         txdigitalreset       =>"rc_tx_digitalreset",
         rxanalogreset        =>"rc_rx_analogreset",
         rxdigitalreset       =>"rx_digitalreset_serdes",
      },

      });

   } elsif (($phy_selection == $PHYSEL_HIP_40nm) & ($c3gx == 0) & ($gen2_rate == 1)) { # S4GX Gen2 x1
      $glue_logic .= "e_assign->new({lhs => \"rc_rx_pll_locked_one\", rhs =>\"1'b1\"}),";
      $glue_logic .= "e_assign->new({lhs => \"rx_digitalreset_serdes\", rhs =>\"rc_rx_digitalreset\"}),";
   } else {
      $glue_logic .= "e_assign->new({lhs => \"rc_rx_pll_locked_one\", rhs =>\"&(rx_pll_locked | rx_freqlocked)\"}),";
      $glue_logic .= "e_assign->new({lhs => \"rx_digitalreset_serdes\", rhs =>\"rc_rx_digitalreset\"}),";
   }


}



########################################
# Variation clocking in/out
########################################
my $clk_ports = " ";
if ($hip == 0) { # soft IP clocking
   if ($chk_io) {
      $clk_in = "$clkfreq_in => \"1'b0\",";
   } else {
      if (($common_clk) & (($tl_selection > 0) & ($tl_selection < 6)) & ($tlp_clk_freq == 0)) {
         $clk_in = "$clkfreq_in => \"AvlClk_i\",";
      } else {
         $clk_in = "$clkfreq_in => \"$clkfreq_in\",";
      }
   }

   $clk_out = "$clkfreq_out => \"$clkfreq_out_q\"";

   $clk_ports = "e_port->new([ $clkfreq_in => 1 => \"input\"]),";
   $clk_ports .= "e_port->new([ $clkfreq_out => 1 => \"output\"]),";
   $clk_in .= "refclk => \"$refclk\",";


} elsif ($phy_selection == $PHYSEL_HIP_40nm) { # HIP clocking for S4GX, A2GX, C4GX
   $clk_in .= "pld_clk => \"pld_clk\",";
   $clk_in .= "pll_fixed_clk => \"pll_fixed_clk\",";
   $clk_in .= "pclk_ch0 => \"pclk_ch0\",";
   $clk_in .= "pclk_central => \"pclk_central\",";
   $glue_logic .= "e_assign->new({lhs => \"core_clk_in\", rhs =>\"1'b0\"}),";
   $clk_in .= "core_clk_in => \"core_clk_in\",";
   $clk_out = "core_clk_out => \"core_clk_out\",";
   $clk_ports .= "e_port->new([ fixedclk_serdes => 1 => \"input\"]),";
   $clk_ports .= "e_port->new([ busy_altgxb_reconfig => 1 => \"input\"]),";

}

########################################
# extra port for HIP
########################################
$hip_extra = " ";
if (($hip == 1) & ($phy_selection == $PHYSEL_HIP_40nm)) {
   $hip_extra .= "suc_spd_neg => suc_spd_neg,\n";
   $add_signals .= "e_signal->new({name => hip_extraclkout, width=> 2, never_export => 1}),";
   $hip_extra .= "hip_extraclkout => hip_extraclkout,\n";

}


########################################
# Configuration port
########################################
$cfg_ports = " ";
if ($hip == 0) {
   $cfg_ports .= "cfg_busdev => $open_"."cfg_busdev,\n";
   $cfg_ports .= "cfg_devcsr => $open_"."cfg_devcsr,\n";
   $cfg_ports .= "cfg_linkcsr => $open_"."cfg_linkcsr,\n";
   $cfg_ports .= "cfg_tcvcmap => $open_"."cfg_tcvcmap,\n";
   $cfg_ports .= "cfg_msicsr => $open_"."cfg_msicsr,\n";
   $cfg_ports .= "cfg_pmcsr => $open_"."cfg_pmcsr,\n";
   $cfg_ports .= "cfg_prmcsr => $open_"."cfg_prmcsr,\n";
   if ($number_of_lanes < 8) {
      $cfg_ports .= "app_int_sts_ack => $open_"."app_int_ack,\n",
   } else {
      if ($open_ eq "") {
         $glue_logic .= "e_assign->new ([ app_int_ack => \"1'b0\"]),";
      }
   }

} elsif ($tl_selection != 8) { # HIP and not TL bypass
   $cfg_ports .= " tl_cfg_add => tl_cfg_add,\n";
   $cfg_ports .= " tl_cfg_ctl => tl_cfg_ctl,\n";
   $cfg_ports .= " tl_cfg_sts => tl_cfg_sts,\n";
   if ($phy_selection < 7) { #S4GX, A2GX, C4GX
      $cfg_ports .= " tl_cfg_sts_wr => tl_cfg_sts_wr,\n";
      $cfg_ports .= " tl_cfg_ctl_wr => tl_cfg_ctl_wr,\n";
   }
   $cfg_ports .= " app_int_ack => $open_"."app_int_ack,\n",

}

if ($phy_selection==7) {
   $sv_connect_in_gnd .= "simu_mode        => \"1'b0\",";
   $sv_connect_in_gnd .= "cal_blk_clk      => \"1'b0\",";
   $sv_connect_in_gnd .= "swctmod          => \"2'b00\",";
   $sv_connect_in_gnd .= "swdn_in          => \"3'b000\",";
   $sv_connect_in_gnd .= "swup_in          => \"7'h00\",";
   $sv_connect_in_gnd .= "swup_in          => \"7'h00\",";
   $sv_connect_in_gnd .= "cfglink2csrpld   => \"13'h00\",";
   $sv_connect_in_gnd .= "entest           => \"1'b0\",";
   $sv_connect_in_gnd .= "frzlogic         => \"1'b0\",";
   $sv_connect_in_gnd .= "frzreg           => \"1'b0\",";
   $sv_connect_in_gnd .= "idrcv            => \"8'h00\",";
   $sv_connect_in_gnd .= "idrpl            => \"8'h00\",";
   $sv_connect_in_gnd .= "bistenrcv        => \"1'b0\",";
   $sv_connect_in_gnd .= "bistenrpl        => \"1'b0\",";
   $sv_connect_in_gnd .= "bistscanen       => \"1'b0\",";
   $sv_connect_in_gnd .= "bistscanin       => \"1'b0\",";
   $sv_connect_in_gnd .= "bisttesten       => \"1'b0\",";
   $sv_connect_in_gnd .= "memhiptestenable => \"1'b0\",";
   $sv_connect_in_gnd .= "memredenscan     => \"1'b0\",";
   $sv_connect_in_gnd .= "memredscen       => \"1'b0\",";
   $sv_connect_in_gnd .= "memredscin       => \"1'b0\",";
   $sv_connect_in_gnd .= "memredsclk       => \"1'b0\",";
   $sv_connect_in_gnd .= "memredscrst      => \"1'b0\",";
   $sv_connect_in_gnd .= "memredscsel      => \"1'b0\",";
   $sv_connect_in_gnd .= "memregscanen     => \"1'b1\",";
   $sv_connect_in_gnd .= "memregscanin     => \"1'b1\",";
   $sv_connect_in_gnd .= "scanmoden        => \"1'b1\",";
   $sv_connect_in_gnd .= "usermode         => \"1'b1\",";
   $sv_connect_in_gnd .= "scanshiftn       => \"1'b1\",";
   $sv_connect_in_gnd .= "nfrzdrv          => \"1'b0\",";
   $sv_connect_in_gnd .= "plniotri         => \"1'b0\",";
   $sv_connect_in_gnd .= "csebrddata       => \"32'h0\",";
   $sv_connect_in_gnd .= "csebrddataparity => \"4'h0\",";
   $sv_connect_in_gnd .= "csebrdresponse   => \"3'h0\",";
   $sv_connect_in_gnd .= "csebwaitrequest  => \"1'b0\",";
   $sv_connect_in_gnd .= "csebwrresponse   => \"3'h0\",";
   $sv_connect_in_gnd .= "csebwrrespvalid  => \"1'b0\",";
   $sv_connect_in_gnd .= "dbgpipex1rx      => \"44'h0\",";
}

$label = "pci_inst";
@label = (@label,$label);
$$label = e_blind_instance->new({
      module => "$var\_core",
      name => "wrapper",
      in_port_map => {
         npor => "npor",
         eval($reset_in),
         eval($clk_in),
         eval($tlp_clk_in),
         eval($serdes_in),
         eval($pipe_connect_in),
         eval($sv_connect_in_gnd),

         test_in => "test_in",
         cpl_pending => $gnd_."cpl_pending",
         cpl_err => $gnd_."cpl_err",
         pme_to_cr => $gnd_."pme_to_cr",
         app_int_sts => $gnd_."app_int_sts",
         app_msi_req => $gnd_."app_msi_req",
         app_msi_tc => $gnd_."app_msi_tc",
         app_msi_num => $gnd_."app_msi_num",
         pex_msi_num => $gnd_."pex_msi_num",
         eval($vcs_connect_in),
      },
      out_port_map => {
         eval($clk_out),
         eval($serdes_out),
         eval($pipe_connect_out),
         test_out => "test_out_int",
         l2_exit => "l2_exit",
         hotrst_exit => "hotrst_exit",
         dlup_exit => "dlup_exit",
         pme_to_sr => $open_."pme_to_sr",
         app_msi_ack => $open_."app_msi_ack",

         eval($cfg_ports),
         eval($vcs_connect_out),
         eval($hip_extra)
      },

   });

##################################################
# Add pipelining for PIPE signals to meet IO timing
##################################################
my $clk_tx_path = $clkfreq_in;
for ($i = 0; $i < $number_of_lanes;  $i++) {

   $add_signals .= "e_signal->new({name => rxdata$i\_q, width=> $int_pipe_width, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxdatak$i\_q, width=> $int_pipe_kwidth, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxelecidle$i\_q, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxstatus$i\_q, width=> 3, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxvalid$i\_q, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => phystatus$i\_q, width=> 1, never_export => 1}),";

   $add_signals .= "e_signal->new({name => rxelecidle$i\_q2, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxstatus$i\_q2, width=> 3, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxvalid$i\_q2, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => phystatus$i\_q2, width=> 1, never_export => 1}),";

   $add_signals .= "e_signal->new({name => txdata$i\_d, width=> $int_pipe_width, never_export => 1}),";
   $add_signals .= "e_signal->new({name => txdatak$i\_d, width=> $int_pipe_kwidth, never_export => 1}),";
   $add_signals .= "e_signal->new({name => powerdown$i\_d, width=> 2, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rxpolarity$i\_d, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => txcompl$i\_d, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => txdetectrx$i\_d, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => txelecidle$i\_d, width=> 1, never_export => 1}),";

   $add_signals .= "e_signal->new({name => txddio$i\_o, width=> 10}),";
   $add_signals .= "e_signal->new({name => txddio$i\_h, width=> 10}),";
   $add_signals .= "e_signal->new({name => txddio$i\_l, width=> 10}),";

   $add_signals .= "e_signal->new({name => rxddio$i\_i, width=> $rxddio_width}),";
   $add_signals .= "e_signal->new({name => rxddio$i\_h, width=> $rxddio_width}),";
   $add_signals .= "e_signal->new({name => rxddio$i\_l, width=> $rxddio_width}),";
   $add_signals .= "e_signal->new({name => clk125_zero, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk125_early, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk125_div2, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk125_div2_r, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk125_sync, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk250_zero, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk250_early, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => clk250_early1, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => tlp_clk_31p25, width=> 1, never_export => 1 }),";
   $add_signals .= "e_signal->new({name => tlp_clk_62p5, width=> 1, never_export => 1 }),";


   if (($pipe_txclk == 0) | ($tlp_clk_freq != 0)) {
      $clk_tx_path = "clk125_early";
   } else {
      $clk_tx_path = "clk125_zero";
   }

   if ($phy_selection == 0)  { # GX

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxstatus$i\_q\" => \"rxstatus$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q\" => \"rxvalid$i\_ext\"]),
      e_assign->new([\"phystatus$i\_q\" => \"phystatus_ext\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR datapath pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q\" => \"rxdata$i\_ext\"]),
      e_assign->new([\"rxdatak$i\_q\" => \"rxdatak$i\_ext\"]),

      e_assign->new([\"txdata$i\_ext\" => \"txdata$i\_d\"]),
      e_assign->new([\"txdatak$i\_ext\" => \"txdatak$i\_d\"]),
      ]}),";


      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d\"]),

      ]}),";
   } elsif (($phy_selection == 2) || (($phy_selection == 6) & ($hip == 0))) { # GX

      if ($i == 0) {
         $glue_logic .= "e_process->new({
         comment => \"SDR control input path pipeline\",
         clock => \"$clkfreq_in\",
         reset => undef,
         contents => [
         e_assign->new([\"rxelecidle_pcs_q\" => \"rxelecidle_pcs\"]),
         e_assign->new([\"rxstatus_pcs_q\" => \"rxstatus_pcs\"]),
         e_assign->new([\"rxvalid_pcs_q\" => \"rxvalid_pcs\"]),
         e_assign->new([\"phystatus_pcs_q\" => \"phystatus_pcs\"]),

         ]}),";

         $glue_logic .= "e_process->new({
         comment => \"SDR datapath pipeline\",
         clock => \"$clkfreq_in\",
         reset => undef,
         contents => [
         e_assign->new([\"rxdata_pcs_q\" => \"rxdata_pcs\"]),
         e_assign->new([\"rxdatak_pcs_q\" => \"rxdatak_pcs\"]),

         e_assign->new([\"txdata\" => \"txdata_d\"]),
         e_assign->new([\"txdatak\" => \"txdatak_d\"]),
         ]}),";


         $glue_logic .= "e_process->new({
         comment => \"SDR control output path pipeline\",
         clock => \"$clkfreq_in\",
         reset => undef,
         contents => [
         e_assign->new([\"powerdown\" => \"powerdown_d\"]),
         e_assign->new([\"rxpolarity\" => \"rxpolarity_d\"]),
         e_assign->new([\"txcompl\" => \"txcompl_d\"]),
         e_assign->new([\"txdetectrx\" => \"txdetectrx_d\"]),
         e_assign->new([\"txelecidle\" => \"txelecidle_d\"]),

         ]}),";
      }

   } elsif ($phy_selection == 1)  { # SDR PIPE

      $add_signals .= "e_signal->new({name => rxdata$i\_q2, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxdatak$i\_q2, width=> $int_pipe_kwidth, never_export => 1}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path pipeline lane$i stage 1\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q2\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxstatus$i\_q2\" => \"rxstatus$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q2\" => \"rxvalid$i\_ext\"]),
      e_assign->new([\"phystatus$i\_q2\" => \"phystatus_ext\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath pipeline lane$i stage 1\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q2\" => \"rxdata$i\_ext\"]),
      e_assign->new([\"rxdatak$i\_q2\" => \"rxdatak$i\_ext\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path pipeline lane$i stage 2\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q\" => \"rxelecidle$i\_q2\"]),
      e_assign->new([\"rxstatus$i\_q\" => \"rxstatus$i\_q2\"]),
      e_assign->new([\"rxvalid$i\_q\" => \"rxvalid$i\_q2\"]),
      e_assign->new([\"phystatus$i\_q\" => \"phystatus$i\_q2\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath pipeline lane$i stage 2\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q\" => \"rxdata$i\_q2\"]),
      e_assign->new([\"rxdatak$i\_q\" => \"rxdatak$i\_q2\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR TX datapath pipeline lane$i\",
      clock => \"clk125_early\",
      reset => undef,
      contents => [
      e_assign->new([\"txdata$i\_ext\" => \"txdata$i\_d\"]),
      e_assign->new([\"txdatak$i\_ext\" => \"txdatak$i\_d\"]),
      ]}),";


      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i\",
      clock => \"clk125_early\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d\"]),

      ]}),";

   } elsif (($phy_selection == 3)  & ($number_of_lanes < 8))  { # DDR PIPE x1 or x4

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path pipeline lane$i\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q\" => \"rxvalid$i\_ext\"]),

      ]}),";

      $add_signals .= "e_signal->new({name => txdata$i\_d2, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdatak$i\_d2, width=> $int_pipe_kwidth, never_export => 1}),";
      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i\",
      clock => \"clk250_early\",
      reset => undef,
      user_attributes_names => [\"powerdown$i\_d2\",\"rxpolarity$i\_d2\",\"txcompl$i\_d2\",\"powerdown$i\_ext\",\"rxpolarity$i\_ext\",\"txcompl$i\_ext\"],
      user_attributes => [
      {
      attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
      attribute_operator => '=',
      attribute_values => ['C106'],
      },
      ],
      contents => [
      e_assign->new([\"powerdown$i\_d2\" => \"powerdown$i\_d\"]),
      e_assign->new([\"rxpolarity$i\_d2\" => \"rxpolarity$i\_d\"]),
      e_assign->new([\"txcompl$i\_d2\" =>  \"txddio$i\_o[9:9]\"]),
      e_assign->new([\"txdetectrx$i\_d2\" => \"txdetectrx$i\_d\"]),
      e_assign->new([\"txelecidle$i\_d2\" => \"txelecidle$i\_d\"]),
      e_assign->new([txdatak$i\_d2 => \"txddio$i\_o[8:8]\"]),
      e_assign->new([txdata$i\_d2 => \"txddio$i\_o[7:0]\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i stage 2\",
      clock => \"clk250_early\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d2\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d2\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d2\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d2\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d2\"]),
      e_assign->new([txdatak$i\_ext => \"txdatak$i\_d2\"]),
      e_assign->new([txdata$i\_ext => \"txdata$i\_d2\"]),

      ]}),";


      $glue_logic .= "e_assign->new ([txddio$i\_l  => \"{txcompl$i\_d,txdatak$i\_d[0],txdata$i\_d[7:0]}\"]),";
      $glue_logic .= "e_assign->new ([txddio$i\_h  => \"{1'b0,txdatak$i\_d[1],txdata$i\_d[15:8]}\"]),";
      $glue_logic .= "e_assign->new({comment => \"DDR output mux\",lhs => \"txddio$i\_o\",
      rhs =>\"clk125_sync ? txddio$i\_h : txddio$i\_l\"}),";

      $glue_logic .= "e_assign->new ([rxddio$i\_i => \"{rxstatus$i\_ext\,phystatus_ext\,rxdatak$i\_ext,rxdata$i\_ext}\"]),";
      $glue_logic .= "e_assign->new ([\"phystatus$i\_q\" => \"rxddio0\_h[9] | rxddio0\_l[9]\"]),";
      $glue_logic .= "e_assign->new ([\"rxstatus$i\_q\" => \"rxddio$i\_h[12] ? rxddio$i\_h[12:10] : rxddio$i\_l[12] ? rxddio$i\_l[12:10] : rxddio$i\_h[12:10] | rxddio$i\_l[12:10]\"]),";


      $glue_logic .= "e_assign->new ([\"rxdatak$i\_q[1]\"  => \"rxddio$i\_h[8]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdatak$i\_q[0]\"  => \"rxddio$i\_l[8]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdata$i\_q[15:8]\"  => \"rxddio$i\_h[7:0]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdata$i\_q[7:0]\"  => \"rxddio$i\_l[7:0]\"]),";

      $label = "rx_ddio$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "8 bit DDR RX datapath",
            module => "altddio_in",
            parameter_map => {
               width => 13,
               intended_device_family => $family
            },
            in_port_map => {
               inclock => "clk125_in",
               datain => "rxddio$i\_i",
               aclr => "1'b0",
               inclocken => "1'b1",
               aset => "1'b0",

            },
            out_port_map => {
               dataout_h => "rxddio$i\_h",
               dataout_l => "rxddio$i\_l",

            },

         });


   } elsif ($phy_selection == 5)  { # DDR PIPE x1 or x4 SDR control (TI phy)

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path pipeline lane$i\",
      clock => \"clk125_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q\" => \"rxvalid$i\_ext\"]),
      e_assign->new([\"phystatus$i\_q\" => \"phystatus_ext\"]),
      e_assign->new([\"rxstatus$i\_q\" => \"rxstatus$i\_ext\"]),

      ]}),";

      $add_signals .= "e_signal->new({name => txdata$i\_d2, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdatak$i\_d2, width=> $int_pipe_kwidth, never_export => 1}),";
      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i\",
      clock => \"clk250_early\",
      reset => undef,
      user_attributes_names => [\"powerdown$i\_d2\",\"rxpolarity$i\_d2\",\"txcompl$i\_d2\",\"powerdown$i\_ext\",\"rxpolarity$i\_ext\",\"txcompl$i\_ext\"],
      user_attributes => [
      {
      attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
      attribute_operator => '=',
      attribute_values => ['C106'],
      },
      ],
      contents => [
      e_assign->new([\"powerdown$i\_d2\" => \"powerdown$i\_d\"]),
      e_assign->new([\"rxpolarity$i\_d2\" => \"rxpolarity$i\_d\"]),
      e_assign->new([\"txcompl$i\_d2\" => \"txddio$i\_o[9:9]\"]),
      e_assign->new([\"txdetectrx$i\_d2\" => \"txdetectrx$i\_d\"]),
      e_assign->new([\"txelecidle$i\_d2\" => \"txelecidle$i\_d\"]),
      e_assign->new([txdatak$i\_d2 => \"txddio$i\_o[8:8]\"]),
      e_assign->new([txdata$i\_d2 => \"txddio$i\_o[7:0]\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i stage 2\",
      clock => \"clk250_early\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d2\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d2\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d2\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d2\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d2\"]),
      e_assign->new([txdatak$i\_ext => \"txdatak$i\_d2\"]),
      e_assign->new([txdata$i\_ext => \"txdata$i\_d2\"]),

      ]}),";


      $glue_logic .= "e_assign->new ([txddio$i\_l  => \"{txcompl$i\_d,txdatak$i\_d[0],txdata$i\_d[7:0]}\"]),";
      $glue_logic .= "e_assign->new ([txddio$i\_h  => \"{1'b0,txdatak$i\_d[1],txdata$i\_d[15:8]}\"]),";
      $glue_logic .= "e_assign->new({comment => \"DDR output mux\",lhs => \"txddio$i\_o\",
      rhs =>\"clk125_sync ? txddio$i\_h : txddio$i\_l\"}),";

      $glue_logic .= "e_assign->new ([rxddio$i\_i => \"{rxdatak$i\_ext,rxdata$i\_ext}\"]),";


      $glue_logic .= "e_assign->new ([\"rxdatak$i\_q[1]\"  => \"rxddio$i\_h[8]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdatak$i\_q[0]\"  => \"rxddio$i\_l[8]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdata$i\_q[15:8]\"  => \"rxddio$i\_h[7:0]\"]),";
      $glue_logic .= "e_assign->new ([\"rxdata$i\_q[7:0]\"  => \"rxddio$i\_l[7:0]\"]),";

      $label = "rx_ddio$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "8 bit DDR RX datapath",
            module => "altddio_in",
            parameter_map => {
               width => 9,
               intended_device_family => $family
            },
            in_port_map => {
               inclock => "clk125_in",
               datain => "rxddio$i\_i",
               aclr => "1'b0",
               inclocken => "1'b1",
               aset => "1'b0",

            },
            out_port_map => {
               dataout_h => "rxddio$i\_h",
               dataout_l => "rxddio$i\_l",

            },

         });


   } elsif ($phy_selection == 3)  { # DDR PIPE x8
      $add_signals .= "e_signal->new({name => rx_phasefifo$i\_d, width=> 30, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_phasefifo$i\_q, width=> 30, never_export => 1}),";

      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxddio$i\_hi, width=> 15}),";
      $add_signals .= "e_signal->new({name => rxddio$i\_lo, width=> 15}),";
      $add_signals .= "e_signal->new({name => rxddio$i\_int, width=> 15}),";

      $add_signals .= "e_signal->new({name => tx_phasefifo$i\_d, width=> 30, never_export => 1}),";
      $add_signals .= "e_signal->new({name => tx_phasefifo$i\_q, width=> 30, never_export => 1}),";

      $add_signals .= "e_signal->new({name => txdata$i\_d2, width=> 8, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdatak$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";

      if ($i < 4) {
         $rx_pclk = "refclk";
         $rx_rclk = "clk250_in";
         $tx_wclk = "clk250_in";
         $tx_txclk = "clk250_in";
      } else {
         $rx_pclk = "phy1_pclk";
         $rx_rclk = "clk250_in";
         $tx_wclk = "clk250_in";
         $tx_txclk = "clk250_early1";
      }


      # The following back is a result of the following:
      # 1) we need to use DDIO to detect phystatus properly
      # 2) Europa cannot instantiate the same object twice with different width, i.e. all lanes have to
      # instantiate the same width of DDIO
      # 4) although we "instantiate" DDIO for phystatus on all lanes but there is only 1 phystatus
      # hooked up per Quad (phy).
      # 5) There is a problem with QII B209 that they cannot merge the DDIO at a higher level
      # Europa cannot instantiate

      if ($i == 0)  {
         $glue_logic .= "e_assign->new ([rxddio$i\_int  => \"{phystatus_ext,rxvalid$i\_ext,rxstatus$i\_ext,rxelecidle$i\_ext,rxdatak$i\_ext,rxdata$i\_ext}\"]),";
      } elsif ($i == 4) {
         $glue_logic .= "e_assign->new ([rxddio$i\_int  => \"{phy1_phystatus_ext,rxvalid$i\_ext,rxstatus$i\_ext,rxelecidle$i\_ext,rxdatak$i\_ext,rxdata$i\_ext}\"]),";
      } else {
         $glue_logic .= "e_assign->new ({comment => \"To work around tool problem\",lhs => \"rxddio$i\_int\",rhs => \"{1'b0,rxvalid$i\_ext,rxstatus$i\_ext,rxelecidle$i\_ext,rxdatak$i\_ext,rxdata$i\_ext}\"}),";
      }


      $label = "rx_ddio$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "DDIO RX pipeline",
            module => "altddio_in",
            parameter_map => {
               width => 15,
               intended_device_family => $family
            },
            in_port_map => {
               inclock => "$rx_pclk",
               datain => "rxddio$i\_int",
               aclr => "1'b0",
               inclocken => "1'b1",
               aset => "1'b0",

            },
            out_port_map => {
               dataout_h => "rxddio$i\_hi",
               dataout_l => "rxddio$i\_lo",

            },

         });

      if ($i < 4) {
         $glue_logic .= "e_assign->new([rx_phasefifo$i\_d  => \"{rxddio0_hi[14],rxddio$i\_hi[13:0],rxddio0_lo[14],rxddio$i\_lo[13:0]}\"]),";
      } else {
         $glue_logic .= "e_assign->new([rx_phasefifo$i\_d  => \"{rxddio4_hi[14],rxddio$i\_hi[13:0],rxddio4_lo[14],rxddio$i\_lo[13:0]}\"]),";
      }


      $label = "rx_phasefifo$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "RX Path Phase Compensation FIFO",
            module => "altpcie_phasefifo",
            parameter_map => {DATA_SIZE => 30,DDR_MODE => 1},
            in_port_map => {
               npor => "npor",
               wclk => "$rx_pclk",
               rclk => "$rx_rclk",
               wdata => "rx_phasefifo$i\_d",
            },
            out_port_map => {
               rdata => "rx_phasefifo$i\_q",

            },

         });

      $glue_logic .= "e_assign->new([\"rxdata$i\_q\" => \"rx_phasefifo$i\_q[7:0]\"]),";
      $glue_logic .= "e_assign->new([\"rxdatak$i\_q\" => \"rx_phasefifo$i\_q[8]\"]),";
      $glue_logic .= "e_assign->new([\"rxelecidle$i\_q\" => \"rx_phasefifo$i\_q[9]\"]),";
      $glue_logic .= "e_assign->new([\"rxstatus$i\_q\" =>\"rx_phasefifo$i\_q[12:10]\"]),";
      $glue_logic .= "e_assign->new([\"rxvalid$i\_q\" => \"rx_phasefifo$i\_q[13]\"]),";
      $glue_logic .= "e_assign->new([\"phystatus$i\_q\" => \"rx_phasefifo$i\_q[14]\"]),";


      $glue_logic .= "e_assign->new([\"tx_phasefifo$i\_d[14:0]\" => \"{powerdown$i\_d,rxpolarity$i\_d,txcompl$i\_d,txdetectrx$i\_d,txelecidle$i\_d,txdatak$i\_d,txdata$i\_d}\"]),";
      $glue_logic .= "e_assign->new([\"txdata$i\_d2\" => \"tx_phasefifo$i\_q[7:0]\"]),";
      $glue_logic .= "e_assign->new([\"txdatak$i\_d2\" => \"tx_phasefifo$i\_q[8]\"]),";
      $glue_logic .= "e_assign->new([\"txelecidle$i\_d2\" => \"tx_phasefifo$i\_q[9]\"]),";
      $glue_logic .= "e_assign->new([\"txdetectrx$i\_d2\" => \"tx_phasefifo$i\_q[10]\"]),";
      $glue_logic .= "e_assign->new([\"txcompl$i\_d2\" => \"tx_phasefifo$i\_q[11]\"]),";
      $glue_logic .= "e_assign->new([\"rxpolarity$i\_d2\" => \"tx_phasefifo$i\_q[12]\"]),";
      $glue_logic .= "e_assign->new([\"powerdown$i\_d2\" => \"tx_phasefifo$i\_q[14:13]\"]),";

      $glue_logic .= "e_process->new({
      comment => \"SDR output path pipeline lane$i\",
      clock => \"$tx_txclk\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d2\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d2\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d2\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d2\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d2\"]),
      e_assign->new([txdatak$i\_ext => \"txdatak$i\_d2\"]),
      e_assign->new([txdata$i\_ext => \"txdata$i\_d2\"]),

      ]}),";


      $label = "tx_phasefifo$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "TX Path Phase Compensation FIFO",
            module => "altpcie_phasefifo",
            parameter_map => {DATA_SIZE => 30,DDR_MODE => 0},
            in_port_map => {
               npor => "npor",
               wclk => "$tx_wclk",
               rclk => "$tx_txclk",
               wdata => "tx_phasefifo$i\_d",
            },
            out_port_map => {
               rdata => "tx_phasefifo$i\_q",

            },

         });





   } elsif (($phy_selection == 4) & ($number_of_lanes < 8))  { # SDR PIPE 8 bit 250Mhz x1 or x4

      $add_signals .= "e_signal->new({name => rxdata$i\_q2, width => $int_pipe_width/2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxdatak$i\_q2, width => 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxelecidle$i\_q2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxstatus$i\_q2, width=> 3, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxvalid$i\_q2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => phystatus$i\_q2, width=> 1, never_export => 1}),";

      $add_signals .= "e_signal->new({name => rxdata$i\_q1, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxdatak$i\_q1, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxelecidle$i\_q1, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxstatus$i\_h_q1, width=> 3, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxstatus$i\_l_q1, width=> 3, never_export => 1}),";
      $add_signals .= "e_signal->new({name => phystatus$i\_h_q1, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => phystatus$i\_l_q1, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxvalid$i\_q1, width=> 1, never_export => 1}),";


      $add_signals .= "e_signal->new({name => txdata$i\_d2, width=> $int_pipe_width/2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdatak$i\_d2, width=> $int_pipe_kwidth/2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";


      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath stage 1 pipeline lane$i\",
      clock => \"refclk\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q2\" => \"rxdata$i\_ext\"]),
      e_assign->new([\"rxdatak$i\_q2\" => \"rxdatak$i\_ext\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath stage 2 lower pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q1[7:0]\" => \"rxdata$i\_q2\"]),
      e_assign->new([\"rxdatak$i\_q1[0]\" => \"rxdatak$i\_q2\"]),
      e_assign->new([\"rxstatus$i\_l_q1\" => \"rxstatus$i\_q2\"]),
      e_assign->new([\"phystatus$i\_l_q1\" => \"phystatus$i\_q2\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath stage 2 upper pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      clock_level => 0,
      user_attributes_names => [\"rxdata$i\_q1\",\"rxdatak$i\_q1\",\"rxstatus$i\_h_q1\",\"rxstatus$i\_l_q1\",\"phystatus$i\_h_q1\"],
      user_attributes => [
      {
      attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
      attribute_operator => '=',
      attribute_values => ['C106'],
      },
      ],
      contents => [
      e_assign->new([\"rxdata$i\_q1[15:8]\" => \"rxdata$i\_q2\"]),
      e_assign->new([\"rxdatak$i\_q1[1]\" => \"rxdatak$i\_q2\"]),
      e_assign->new([\"rxstatus$i\_h_q1\" => \"rxstatus$i\_q2\"]),
      e_assign->new([\"phystatus$i\_h_q1\" => \"phystatus$i\_q2\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR RX datapath stage 3 pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q\" => \"rxdata$i\_q1\"]),
      e_assign->new([\"rxdatak$i\_q\" => \"rxdatak$i\_q1\"]),

      ]}),";


      $glue_logic .= "e_process->new({
      comment => \"SDR control input path Stage 1 pipeline lane$i\",
      clock => \"refclk\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q2\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxstatus$i\_q2\" => \"rxstatus$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q2\" => \"rxvalid$i\_ext\"]),
      e_assign->new([\"phystatus$i\_q2\" => \"phystatus_ext\"]),

      ]}),";


      $glue_logic .= "e_process->new({
      comment => \"SDR control input path Stage 2 pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q1\" => \"rxelecidle$i\_q2\"]),
      e_assign->new([\"rxvalid$i\_q1\" => \"rxvalid$i\_q2\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control input path Stage 3 pipeline lane$i\",
      clock => \"$clkfreq_in\",
      reset => undef,
      contents => [
      e_assign->new([\"rxelecidle$i\_q\" => \"rxelecidle$i\_q1\"]),
      e_assign->new([\"rxstatus$i\_q\" => \"rxstatus$i\_l_q1[2] ? rxstatus$i\_l_q1 : rxstatus$i\_h_q1[2] ? rxstatus$i\_h_q1 : rxstatus$i\_h_q1 | rxstatus$i\_l_q1\"]),
      e_assign->new([\"rxvalid$i\_q\" => \"rxvalid$i\_q1\"]),
      e_assign->new([\"phystatus$i\_q\" => \"phystatus$i\_l_q1 | phystatus$i\_h_q1\"]),

      ]}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i stage 1\",
      clock => \"clk250_early\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_d2\" => \"powerdown$i\_d\"]),
      e_assign->new([\"rxpolarity$i\_d2\" => \"rxpolarity$i\_d\"]),
      e_assign->new([\"txcompl$i\_d2\" =>  \"txddio$i\_o[9:9]\"]),
      e_assign->new([\"txdetectrx$i\_d2\" => \"txdetectrx$i\_d\"]),
      e_assign->new([\"txelecidle$i\_d2\" => \"txelecidle$i\_d\"]),
      e_assign->new([txdatak$i\_d2 => \"txddio$i\_o[8:8]\"]),
      e_assign->new([txdata$i\_d2 => \"txddio$i\_o[7:0]\"]),

      ]}),";


      $glue_logic .= "e_assign->new ([txddio$i\_l  => \"{txcompl$i\_d,txdatak$i\_d[0],txdata$i\_d[7:0]}\"]),";
      $glue_logic .= "e_assign->new ([txddio$i\_h  => \"{1'b0,txdatak$i\_d[1],txdata$i\_d[15:8]}\"]),";
      $glue_logic .= "e_assign->new({comment => \"DDR output mux\",lhs => \"txddio$i\_o\",
      rhs =>\"clk125_sync ? txddio$i\_h : txddio$i\_l\"}),";

      $glue_logic .= "e_process->new({
      comment => \"SDR control output path pipeline lane$i stage 2\",
      clock => \"clk250_early\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d2\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d2\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d2\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d2\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d2\"]),
      e_assign->new([txdatak$i\_ext => \"txdatak$i\_d2\"]),
      e_assign->new([txdata$i\_ext => \"txdata$i\_d2\"]),

      ]}),";


   } elsif ($phy_selection == 4)  { # SDR PIPE 8 bit 250Mhz x8

      $add_signals .= "e_signal->new({name => rxdata$i\_q2, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxdatak$i\_q2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxelecidle$i\_q2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxstatus$i\_q2, width=> 3, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxvalid$i\_q2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => phystatus$i\_q2, width=> 1, never_export => 1}),";

      $add_signals .= "e_signal->new({name => rx_phasefifo$i\_d, width=> 15, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rx_phasefifo$i\_q, width=> 15, never_export => 1}),";

      $add_signals .= "e_signal->new({name => txdata$i\_d2, width=> $int_pipe_width, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdatak$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => powerdown$i\_d2, width=> 2, never_export => 1}),";
      $add_signals .= "e_signal->new({name => rxpolarity$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txcompl$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txdetectrx$i\_d2, width=> 1, never_export => 1}),";
      $add_signals .= "e_signal->new({name => txelecidle$i\_d2, width=> 1, never_export => 1}),";

      $add_signals .= "e_signal->new({name => tx_phasefifo$i\_d, width=> 15, never_export => 1}),";
      $add_signals .= "e_signal->new({name => tx_phasefifo$i\_q, width=> 15, never_export => 1}),";

      if ($i < 4) {
         $rx_pclk = "clk250_in";
         $rx_rclk = "clk250_in";
         $tx_wclk = "clk250_in";
         $tx_txclk = "clk250_in";
         if ($pipe_txclk) {
         } else {
            $tx_txclk = "clk250_early";
         }
         $physts = "phystatus_ext";
         $pwrdn = "powerdown_ext";
         $rdet = "txdetectrx_ext";
      } else {
         $rx_pclk = "phy1_pclk";
         $rx_rclk = "clk250_in";
         $tx_wclk = "clk250_in";
         if ($pipe_txclk) {
            $tx_txclk = "phy1_pclk";
         } else {
            $tx_txclk = "clk250_early1";
         }
         $physts = "phy1_phystatus_ext";
         $pwrdn = "phy1_powerdown_ext";
         $rdet = "phy1_txdetectrx_ext";

      }

      $glue_logic .= "e_process->new({
      comment => \"SDR RX pipeline lane$i\",
      clock => \"$rx_pclk\",
      reset => undef,
      contents => [
      e_assign->new([\"rxdata$i\_q2\" => \"rxdata$i\_ext\"]),
      e_assign->new([\"rxdatak$i\_q2\" => \"rxdatak$i\_ext\"]),
      e_assign->new([\"rxelecidle$i\_q2\" => \"rxelecidle$i\_ext\"]),
      e_assign->new([\"rxstatus$i\_q2\" => \"rxstatus$i\_ext\"]),
      e_assign->new([\"rxvalid$i\_q2\" => \"rxvalid$i\_ext\"]),
      e_assign->new([\"phystatus$i\_q2\" => \"$physts\"]),

      ]}),";

      $glue_logic .= "e_assign->new([\"rx_phasefifo$i\_d\" => \"{phystatus$i\_q2,rxvalid$i\_q2,rxstatus$i\_q2,rxelecidle$i\_q2,rxdatak$i\_q2,rxdata$i\_q2}\"]),";
      $glue_logic .= "e_assign->new([\"rxdata$i\_q\" => \"rx_phasefifo$i\_q[7:0]\"]),";
      $glue_logic .= "e_assign->new([\"rxdatak$i\_q\" => \"rx_phasefifo$i\_q[8]\"]),";
      $glue_logic .= "e_assign->new([\"rxelecidle$i\_q\" => \"rx_phasefifo$i\_q[9]\"]),";
      $glue_logic .= "e_assign->new([\"rxstatus$i\_q\" =>\"rx_phasefifo$i\_q[12:10]\"]),";
      $glue_logic .= "e_assign->new([\"rxvalid$i\_q\" => \"rx_phasefifo$i\_q[13]\"]),";
      $glue_logic .= "e_assign->new([\"phystatus$i\_q\" => \"rx_phasefifo$i\_q[14]\"]),";

      $label = "rx_phasefifo$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "RX Path Phase Compensation FIFO",
            module => "altpcie_phasefifo",
            parameter_map => {DATA_SIZE => 15,DDR_MODE => 0},
            in_port_map => {
               npor => "npor",
               wclk => "$rx_pclk",
               rclk => "$rx_rclk",
               wdata => "rx_phasefifo$i\_d",
            },
            out_port_map => {
               rdata => "rx_phasefifo$i\_q",

            },

         });

      $glue_logic .= "e_assign->new([\"tx_phasefifo$i\_d\" => \"{powerdown$i\_d,rxpolarity$i\_d,txcompl$i\_d,txdetectrx$i\_d,txelecidle$i\_d,txdatak$i\_d,txdata$i\_d}\"]),";
      $glue_logic .= "e_assign->new([\"txdata$i\_d2\" => \"tx_phasefifo$i\_q[7:0]\"]),";
      $glue_logic .= "e_assign->new([\"txdatak$i\_d2\" => \"tx_phasefifo$i\_q[8]\"]),";
      $glue_logic .= "e_assign->new([\"txelecidle$i\_d2\" => \"tx_phasefifo$i\_q[9]\"]),";
      $glue_logic .= "e_assign->new([\"txdetectrx$i\_d2\" => \"tx_phasefifo$i\_q[10]\"]),";
      $glue_logic .= "e_assign->new([\"txcompl$i\_d2\" => \"tx_phasefifo$i\_q[11]\"]),";
      $glue_logic .= "e_assign->new([\"rxpolarity$i\_d2\" => \"tx_phasefifo$i\_q[12]\"]),";
      $glue_logic .= "e_assign->new([\"powerdown$i\_d2\" => \"tx_phasefifo$i\_q[14:13]\"]),";

      $glue_logic .= "e_process->new({
      comment => \"SDR output path pipeline lane$i\",
      clock => \"$tx_txclk\",
      reset => undef,
      contents => [
      e_assign->new([\"powerdown$i\_ext\" => \"powerdown$i\_d2\"]),
      e_assign->new([\"rxpolarity$i\_ext\" => \"rxpolarity$i\_d2\"]),
      e_assign->new([\"txcompl$i\_ext\" => \"txcompl$i\_d2\"]),
      e_assign->new([\"txdetectrx$i\_ext\" => \"txdetectrx$i\_d2\"]),
      e_assign->new([\"txelecidle$i\_ext\" => \"txelecidle$i\_d2\"]),
      e_assign->new([txdatak$i\_ext => \"txdatak$i\_d2\"]),
      e_assign->new([txdata$i\_ext => \"txdata$i\_d2\"]),

      ]}),";


      $label = "tx_phasefifo$i";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            comment => "TX Path Phase Compensation FIFO",
            module => "altpcie_phasefifo",
            parameter_map => {DATA_SIZE => 15,DDR_MODE => 0},
            in_port_map => {
               npor => "npor",
               wclk => "$tx_wclk",
               rclk => "$tx_txclk",
               wdata => "tx_phasefifo$i\_d",
            },
            out_port_map => {
               rdata => "tx_phasefifo$i\_q",

            },

         });


   }

}

##################################################
# Instantiation of PLL for meeting IO timing
# install PLL for DDR mode or when no txclk
##################################################
if ((($phy_selection == 3) | ($phy_selection == 5)) & ($number_of_lanes < 8)) { #DDR mode x1 or x4

   # DIY DDR logic

   $glue_logic .= "e_process->new({
   comment => \"Div down 125Mhz clk with T-Flop\",
   clock => \"clk125_in\",
   reset => \"npor\",
   asynchronous_contents => [
   e_assign->new([\"clk125_div2\" => 0]),
   ],
   user_attributes_names => [\"clk125_div2\"],
   user_attributes => [
   {
   attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
   attribute_operator => '=',
   attribute_values => ['R102'],
   },
   ],
   contents => [
   e_assign->new([\"clk125_div2\" => \"~clk125_div2\"]),
   ],

   }),";

   $glue_logic .= "e_process->new({
   comment => \"Edge detect on the clk125_div2 to re-gen clk125 for driving DDR mux\",
   clock => \"clk250_early\",
   reset => undef,
   user_attributes_names => [\"clk125_div2_r\",\"clk125_sync\"],
   user_attributes => [
   {
   attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
   attribute_operator => '=',
   attribute_values => ['C106'],
   },
   ],
   contents => [
   e_assign->new([\"clk125_div2_r\" => \"clk125_div2\"]),
   e_if->new({
   condition => \"clk125_div2_r != clk125_div2\",
   then => [\"clk125_sync\" => 1],
   else => [\"clk125_sync\" => 0],
   }),
   ],

   }),";


   $label = "phy$phy_selection\_txclk_pll";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy$phy_selection\_$tlp_clk_suffix",
         in_port_map => {
            inclk0 => "refclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c0 => "clk125_out",
            c1 => "clk250_early",
            c2 => "tlp_clk_$tlp_clk_suffix",
            locked => "xphy_pll_locked",

         },

      });
} elsif (($phy_selection == 4) & ($number_of_lanes < 8)) { # 250Mhz SDR 8 bit x1 or x4

   # DIY DDR logic

   $glue_logic .= "e_process->new({
   comment => \"Div down 125Mhz clk with T-Flop\",
   clock => \"$clkfreq_in\",
   reset => \"npor\",
   asynchronous_contents => [
   e_assign->new([\"clk125_div2\" => 0]),
   ],
   user_attributes_names => [\"clk125_div2\"],
   user_attributes => [
   {
   attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
   attribute_operator => '=',
   attribute_values => ['R102'],
   },
   ],
   contents => [
   e_assign->new([\"clk125_div2\" => \"~clk125_div2\"]),
   ],

   }),";

   $glue_logic .= "e_process->new({
   comment => \"Edge detect on the clk125_div2 to re-gen clk125 for driving DDR mux\",
   clock => \"clk250_early\",
   reset => undef,
   contents => [
   e_assign->new([\"clk125_div2_r\" => \"clk125_div2\"]),
   e_if->new({
   condition => \"clk125_div2_r != clk125_div2\",
   then => [\"clk125_sync\" => 1],
   else => [\"clk125_sync\" => 0],
   }),
   ],

   }),";


   $label = "phy$phy_selection\_txclk_pll";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy4_$tlp_clk_suffix",
         in_port_map => {
            inclk0 => "refclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c0 => "clk125_out",
            c1 => "clk250_early",
            c2 => "tlp_clk_$tlp_clk_suffix",
            locked => "xphy_pll_locked",

         },

      });
} elsif ((($phy_selection == 4) & ($pipe_txclk == 0)) | ($phy_selection == 3) | ($phy_selection == 5)) { # x8 8 bit SDR or DDR mode
   if (($phy_selection == 3) | ($phy_selection == 5))  {
      $pll_out = "clk250_out";
   } else {
      $pll_out = "clk250_early";
   }

   $label = "phy$phy_selection\_txclk_pll0";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy$phy_selection\_$tlp_clk_suffix",
         in_port_map => {
            inclk0 => "refclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c1 => "$pll_out",
            locked => "xphy_pll_locked",

         },

      });

   $label = "phy$phy_selection\_txclk_pll1";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy$phy_selection\_$tlp_clk_suffix",
         in_port_map => {
            inclk0 => "phy1_pclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c1 => "clk250_early1",
            locked => "xphy_pll_locked",

         },

      });


} elsif (($phy_selection == 1) & # phy 1 with PLL
   (($pipe_txclk == 0) | ($tlp_clk_freq != 0)) ) {
   # instantiate PLL if no txclk or slow tlp clk

   $label = "tlp_clk_pll";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy1_$tlp_clk_suffix",
         in_port_map => {
            inclk0 => "refclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c0 => "clk125_out",
            c1 => "clk125_early",
            c2 => "tlp_clk_$tlp_clk_suffix",
            locked => "xphy_pll_locked",

         },

      });
} elsif ($phy_selection == 1) { # phy 1 without PLL
   $glue_logic .= "e_assign->new([\"clk125_early\" => \"clk125_in\"]),";
   $glue_logic .= "e_assign->new([\"clk125_zero\" => \"clk125_in\"]),";

   # make fake port
   $add_signals .= "e_port->new([ xphy_pll_areset => 1 => \"input\"]),";
   $add_signals .= "e_port->new([ xphy_pll_locked => 1 => \"output\"]),";

} elsif (($phy_selection == 0) & ($refclk_selection == 0)) { # GX with 100Mhz refclk

   # tied pll reset off to 0
   $glue_logic .= "e_assign->new ([xphy_pll_areset => 0]),";
   $label = "phy$phy_selection\_tlp_clk_pll";
   @label = (@label,$label);
   $$label = e_blind_instance->new({
         name => "$label",
         module => "altpcie_pll_phy$phy_selection",
         in_port_map => {
            inclk0 => "refclk",
            areset => "xphy_pll_areset",
         },
         out_port_map => {
            c0 => "clk125_out",
            c1 => "tlp_clk_31p25",
            c2 => "tlp_clk_62p5",
            locked => "xphy_pll_locked",
         },

      });
} else {
}


##################################################
# generation of phy reset
##################################################
if (($phy_selection == 1) | ($phy_selection == 3) | ($phy_selection == 4) |  ($phy_selection == 5)) {
   $top_mod->add_contents
   (
      my $pipe_rstn = e_port->new([ pipe_rstn => 1 => "output"]),
   );

   $glue_logic .= "e_assign->new ([pipe_rstn  => \"npor\"]),";
}


##################################################
# generation of txclk
##################################################
if ($pipe_txclk == 1) { # source synchronous
   $top_mod->add_contents
   (
      my $txclk = e_port->new([ pipe_txclk => 1 => "output"]),
      my $pipe_rstn = e_port->new([ pipe_rstn => 1 => "output"]),
   );
   $glue_logic .= "e_assign->new ([pipe_txclk  => \"pipe_txclk_int\"]),";

   if ($phy_selection == 1) { # SDR 125Mhz

      $add_signals .= "e_signal->new({name => pipe_txclk_q, width=> 2}),";
      $glue_logic .= "e_assign->new({comment => \"TXCLK output \",lhs => \"pipe_txclk_int\", rhs =>\"pipe_txclk_q[0]\"}),";

      $label = "txclk_ddio";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            module => "altddio_out",
            parameter_map => {
               width => 2,
               intended_device_family => $family
            },
            in_port_map => {
               outclock => "clk125_early",
               datain_h => "2'b00",
               datain_l => "2'b11",
               aclr => "1'b0",
               outclocken => "1'b1",
               aset => "1'b0",
               aclr => "1'b0",
               oe => "1'b1",


            },
            out_port_map => {
               dataout => "pipe_txclk_q",
            },

         });
   } elsif (($phy_selection == 3) || ($phy_selection == 5))  { # DDR mode


      $glue_logic .= "e_process->new({
      comment => \"DDR output clk\",
      clock => \"clk250_early\",
      reset => \"npor\",
      clock_level => 0,
      asynchronous_contents => [
      e_assign->new([\"pipe_txclk_int\" => 1]),
      ],
      user_attributes_names => [\"pipe_txclk_int\"],
      user_attributes => [
      {
      attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
      attribute_operator => '=',
      attribute_values => ['C106'],
      },
      {
      attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
      attribute_operator => '=',
      attribute_values => ['R102'],
      },
      ],

      contents => [
      e_assign->new([\"pipe_txclk_int\" => \"~pipe_txclk_int\"]),
      ],

      }),";


      if ($number_of_lanes == 8) {

         $top_mod->add_contents
         (
            my $txclk1 = e_port->new([ pipe_txclk1 => 1 => "output"]),
         );

         $glue_logic .= "e_assign->new ([pipe_txclk1  => \"pipe_txclk_int1\"]),";
         $glue_logic .= "e_process->new({
         comment => \"DDR output clk for PHY1\",
         clock => \"clk250_early1\",
         reset => \"npor\",
         clock_level => 0,
         asynchronous_contents => [
         e_assign->new([\"pipe_txclk_int1\" => 0]),
         ],
         user_attributes_names => [\"pipe_txclk_int1\"],
         user_attributes => [
         {
         attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
         attribute_operator => '=',
         attribute_values => ['C106'],
         },
         {
         attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
         attribute_operator => '=',
         attribute_values => ['R102'],
         },
         ],
         contents => [
         e_assign->new([\"pipe_txclk_int1\" => \"~pipe_txclk_int1\"]),
         ],

         }),";
      }



   } elsif (($phy_selection == 4) & ($number_of_lanes < 8)) { # 250Mhz 8 bit SDR mode x1 or x4
      $add_signals .= "e_signal->new({name => pipe_txclk_q, width=> 2}),";
      $glue_logic .= "e_assign->new({comment => \"TXCLK output \",lhs => \"pipe_txclk_int\", rhs =>\"pipe_txclk_q[0]\"}),";

      $label = "txclk_ddio";
      @label = (@label,$label);
      $$label = e_blind_instance->new({
            name => "$label",
            module => "altddio_out",
            parameter_map => {
               width => 2,
               intended_device_family => $family
            },
            in_port_map => {
               outclock => "clk250_early",
               datain_h => "2'b00",
               datain_l => "2'b11",
               aclr => "1'b0",
               outclocken => "1'b1",
               aset => "1'b0",
               aclr => "1'b0",
               oe => "1'b1",


            },
            out_port_map => {
               dataout => "pipe_txclk_q",
            },

         });
   } elsif ($phy_selection == 4) { # 250Mhz 8 bit SDR mode x8

      $glue_logic .= "e_assign->new({comment => \"TXCLK Phy0 output \",lhs => \"pipe_txclk_int\", rhs =>\"~clk250_in\"}),";
      $glue_logic .= "e_assign->new ([pipe_txclk1  => \"pipe_txclk_int1\"]),";
      $glue_logic .= "e_assign->new({comment => \"TXCLK Phy1 output \",lhs => \"pipe_txclk_int1\", rhs =>\"~phy1_pclk\"}),";    }
}


$top_mod->add_contents
(

# clock ports
   eval($clk_ports),
# reset ports
   eval($reset_ports),
#--serdes interfaces
   eval($serdes_interface),

#--pipe interface
   eval($pipe_interface),


   eval($add_signals),
   eval($glue_logic),
   eval($vcs_signals),

);


foreach $label (@label) {
   $top_mod->add_contents($$label);
}

$top_mod->vhdl_libraries()->{altera_mf}{all};

$proj->top($top_mod);
$proj->language($language);
$proj->output();

##################################################
# Generate Port list
##################################################
if (1) {
   open(PORT,">$ppx") || die "Cannot open Pin Planner file";
   print PORT "<?xml version=\"1.0\" ?>\n";
   print PORT "<pinplan specifies=\"all_ports\" >\n";
   print PORT "<global>\n</global>\n";
   print PORT "<block name=\"pcie_block\">\n";

   @input_signals = $top_mod->get_input_names();
   foreach $input_signals (@input_signals) {
      $width = $top_mod->_get_signal_width($input_signals);
      if ($width == 1) {
         $out = &pin_entry($input_signals,"input");
         print PORT $out;
      } else {
         for ($i = 0; $i < $width; $i++) {
            $bus_signal = $input_signals."\[$i]";
            $out = &pin_entry($bus_signal,"input");
            print PORT $out;
         }
         $width--;
         $bus_signal = $input_signals."\[$width..0\]";
         $out = &pin_entry($bus_signal,"input");
         print PORT $out;
      }
   }

   @output_signals = $top_mod->get_output_names();
   foreach $output_signals (@output_signals) {
      $width = $top_mod->_get_signal_width($output_signals);
      if ($width == 1) {
         $out = &pin_entry($output_signals,"output");
         print PORT $out;
      } else {
         for ($i = 0; $i < $width; $i++) {
            $bus_signal = $output_signals."\[$i]";
            $out = &pin_entry($bus_signal,"output");
            print PORT $out;
         }
         $width--;
         $bus_signal = $output_signals."\[$width..0\]";
         $out = &pin_entry($bus_signal,"output");
         print PORT $out;
      }
   }


   print PORT "</block>\n";
   print PORT "</pinplan>\n";
   close(PORT);


}

##################################################
# virutual pin list
##################################################
if (1) {
   $external = 0;
   open(VPIN,">$vpin") || die "Cannot open Virtual Pin file";
   @all_pin = ($top_mod->get_input_names(), $top_mod->get_output_names());
   foreach $pin (@all_pin) {

      if ($pin =~ /(x_in)|(x_out)|(pipe_)|(refclk)|(npor)|(phy1_pclk)/) {
      } elsif (($pin =~ /_ext/) & ($phy_selection != 0) & ($phy_selection != 2) & ($phy_selection != 6)) {
      } else {
         print VPIN "set_instance_assignment -name VIRTUAL_PIN ON -to $pin\n";
      }
   }
   close(VPIN);
}

sub pin_entry {

   my $pin;
   my $dir;
   my $out;
   ($pin,$dir) = @_;
   $out = "<";
   $out .= "pin name=\"$pin\" ";
   $out .= "direction=\"$dir\" ";

   # define external
   my $external_pin = 0;
   if (($phy_selection == 0) | ($phy_selection == 2) | ($phy_selection == 6)){ # serial interface
      if ($pin =~ /(x_in)|(x_out)/) {
         $external_pin = 1;
      }
   } else {
      if ($pin =~ /(_ext)|(pipe_)/) {
         $external_pin = 1;
      }
   }

   if ($pin =~ /(refclk)|(npor)/) {
      $external_pin = 1;
   }


   if ($external_pin) {
      $out .= "scope=\"external\" ";
   } else {
      $out .= "scope=\"internal\" ";
   }

   # logic to set IO standard
   %IO_STD = ( 0 => "",
      1 => "LVTTL",
      2 => "LVDS",
      3 => "1.5-V PCML",
      4 => "SSTL-2 CLASS I",
      5 => "LVCMOS",
      6 => "2.5V",
      7 => "1.2-V PCML",
      8 => "HCSL",
   );
   $set_io = 0;
   if ($pin =~ /pcie_rstn/) {
      $set_io = 1;
   } elsif ($pin =~ /(rx_in)|(tx_out)/) {
      if ($phy_selection == 2) {
         $set_io = 7;
      } elsif ($phy_selection == 6) { # do not set IO because S4GX conflicts with A2GX
         $set_io = 0;
      } else {
         $set_io = 3;
      }
   } elsif ($pin =~ /refclk/) {
      if (($phy_selection == 2) | ($phy_selection == 6))  {
         $set_io = 8;
      } elsif ($phy_selection == 0) {
         $set_io = 2;
      }
   } elsif ($phy_selection == 5) { # all ti phy is set to LVCMOS
      $set_io = 5;
   }

   if (($set_io > 0) & ($external_pin == 1)) {
      $out .= "io_standard=\"$IO_STD{$set_io}\" ";
   }

   $out .= "/>\n";
   return $out;

}
