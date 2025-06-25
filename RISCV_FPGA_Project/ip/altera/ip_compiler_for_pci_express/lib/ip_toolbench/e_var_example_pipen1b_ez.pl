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
my $cvp = 0;
my $refclk_selection = 0;
my $tl_selection = 0;
my $lane_width = 1;
my $var = "pci_var";
my $language = "vhdl";
my $number_of_vcs = 2;
my $pipe_txclk = 0;
my $tlp_clk_req = 0;
my $multi_core = "0";
my $simple_dma = 1;
my $tags = 8;
my $max_pload = 128;
my $cplh_cred = 256;
my $cpld_cred = 256;
my $test_out_width = 9;
my $hip = 0;
my $rp = 0;
my $crc_fwd = 0;
my $enable_hip_dprio = 0;
my $gen2_rate = 0;
my $family = "Cyclone II";

# Phy Type
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
   # 7 - HIPCAB 128bit
   # 8 - TL Bypass
   # 9 - HIPCAB 256bit

# int nTl_Selection =  (MODEL().getPrivate(MVCConstants.PARAM_UNDER_SOPC_BUILDER).getValue().equalsIgnoreCase("true")
#       && MODEL().getPrivate("p_pci_master").getValue().equalsIgnoreCase("true")
#       && MODEL().getPrivate("p_pci_impl_cra_av_slave_port").getValue().equalsIgnoreCase("true")
#       )? 1 :
#    (MODEL().getPrivate(MVCConstants.PARAM_UNDER_SOPC_BUILDER).getValue().equalsIgnoreCase("true")
#     && MODEL().getPrivate("p_pci_master").getValue().equalsIgnoreCase("false")
#     && MODEL().getPrivate("p_pci_impl_cra_av_slave_port").getValue().equalsIgnoreCase("false")
#    )? 2 :
#    (MODEL().getPrivate(MVCConstants.PARAM_UNDER_SOPC_BUILDER).getValue().equalsIgnoreCase("true")
#     && MODEL().getPrivate("p_pci_master").getValue().equalsIgnoreCase("true")
#     && MODEL().getPrivate("p_pci_impl_cra_av_slave_port").getValue().equalsIgnoreCase("false")
#    )? 3 :
#    (MODEL().getPrivate(MVCConstants.PARAM_UNDER_SOPC_BUILDER).getValue().equalsIgnoreCase("true")
#     && MODEL().getPrivate("p_pci_master").getValue().equalsIgnoreCase("false")
#     && MODEL().getPrivate("p_pci_impl_cra_av_slave_port").getValue().equalsIgnoreCase("true")
#    )? 4 :
#    (MODEL().getPrivate(MVCConstants.PARAM_APP_SIGNAL_INTERFACE).getValue().equals(EAppSignalInterfaceOptions.AvalonST.name())
#    )? 6 :
#    (MODEL().getPrivate(MVCConstants.PARAM_APP_SIGNAL_INTERFACE).getValue().equals(EAppSignalInterfaceOptions.AvalonST128.name())
#    )? 7 :
#    (MODEL().getPrivate(MVCConstants.PARAM_APP_SIGNAL_INTERFACE).getValue().equals(EAppSignalInterfaceOptions.TLBypass.name())
#    )? 8 :
#    (MODEL().getPrivate(MVCConstants.PARAM_APP_SIGNAL_INTERFACE).getValue().equals(EAppSignalInterfaceOptions.AvalonST256.name())
#    )? 9 :
#    0;


   $tl_selection = $temp;
}
my $TLSEL_AST256=9;
my $TLSEL_AST128=7;
my $TLSEL_AST64 =6;
my $TLSEL_BYPASS=8;

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

my $temp = $command_hash{"multi_core"};
if($temp ne "")
{
   $multi_core = $temp;
}

my $temp = $command_hash{"simple_dma"};
if($temp ne "")
{
   $simple_dma = $temp;
}

my $temp = $command_hash{"tags"};
if($temp ne "")
{
   $tags = $temp;
}

my $temp = $command_hash{"max_pload"};
if($temp ne "")
{
   $max_pload = $temp;
}

my $temp = $command_hash{"cplh_cred"};
if($temp ne "")
{
   $cplh_cred = $temp;
}

my $temp = $command_hash{"cpld_cred"};
if($temp ne "")
{
   $cpld_cred = $temp;
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


my $temp = $command_hash{"crc_fwd"};
if($temp ne "")
{
   $crc_fwd = $temp;
}

my $temp = $command_hash{"enable_hip_dprio"};
if($temp ne "")
{
   $enable_hip_dprio = $temp;
}

my $temp = $command_hash{"family"};
if($temp ne "")
{
   $family = $temp;
}


# check for stingray
if ($family =~ /cyclone_iv/i) {
   $c3gx = 1;
}


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
}


# declare top module
my $comment_str = "simple";
my $pipen1b = "pipen1b";
my $comment_hdl = "Verilog HDL";
my $module_ez = $var . '_plus';
my $module_rs_hip = $var . '_rs_hip';

if ($rp == 0) {
   if ($simple_dma == 0) {
      $comment_str = "chained";
      $pipen1b = "chaining_pipen1b";
   }
} else {
   $comment_str = "rp";
   $pipen1b = "rp_pipen1b";
   # force to chaining DMA for RP
   $simple_dma = 0;
}
if ($language =~ /hdl/i) {
   $comment_hdl = "VHDL";
}

my $top_example_pipen1b = e_module->new ({name => "$var\_example_$pipen1b", comment => "/** This $comment_hdl file is used for simulation and synthesis in $comment_str DMA design example\n* This file provides the top level wrapper file of the core and example applications\n*/"});


#processed variables
my $pipe_width = 16;

##################################################
# clkin /out
##################################################
my $clkfreq_in = "clk125_in";
my $clkfreq_out = "clk125_out";

if ($hip == 0) {
   if ($number_of_lanes == 8) {
      $clkfreq_in = "clk250_in";
      $clkfreq_out = "clk250_out";
   }
} else {
   $clkfreq_in = "pld_clk";
}

my $clk_ports = " ";
$clk_in     = "pclk_in => \"pclk_in\",";
$clk_in     .= "pld_clk => \"pld_clk\",";
$clk_out    = "core_clk_out => \"core_clk_out\",";
$clk_out    .= "clk250_out => \"clk250_out\",";
$clk_out    .= "clk500_out => \"clk500_out\",";

##################################################
# Dual Phy support
##################################################
my $dual_phy_in = " ";
my $dual_phy_out = " ";
if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) {
   $dual_phy_in .= "phy1_pclk => phy1_pclk";

   if ($pipe_txclk) {
      $dual_phy_out .= "pipe_txclk1 => pipe_txclk1";
   }
}

##################################################
# apps Clock
##################################################
my $app_clk_out = " ";

if ($number_of_lanes == 1) {
   $app_clk_out = "app_clk => app_clk";
   $app_clk_in = "app_clk";
} else {
   $app_clk_in = $clkfreq_in;
}

##################################################
# Serdes connections
##################################################

# default connections
my $serdes_out = " ";
my $serdes_in = " ";
my $serdes_interface = " ";
my $i;

if (($phy_selection == 0) || ($phy_selection == 2) || ($phy_selection == 6) || ($phy_selection == 7)) { # needs serdes connection
   $serdes_in .= "pipe_mode => pipe_mode,";
   $serdes_interface .= "e_port->new([pipe_mode => 1 => \"input\" => '0']),";

   for ($i = 0; $i < $number_of_lanes; $i++) {
      $serdes_interface .= "e_port->new([rx_in$i => 1 => \"input\" => '0']),";
      $serdes_interface .= "e_port->new([tx_out0 => 1 => \"output\"]),";
      $serdes_out .= "tx_out$i => tx_out$i,";
      $serdes_in .= "rx_in$i => rx_in$i,";
   }
}

##################################################
# set PIPE width
##################################################
if ($hip == 1) {
   $pipe_width = 8;
} elsif (($phy_selection == 0) || ($phy_selection == 1))  { # needs serdes connection
   $pipe_width = 16;
} elsif (($phy_selection == 2) || ($phy_selection == 6)) {
   if ($number_of_lanes < 8) {
      $pipe_width = 16;
   } else {
      $pipe_width = 8;
   }
} elsif (($phy_selection == 3) || ($phy_selection == 4) || ($phy_selection == 5)) { # DDIO
   $pipe_width = 8;
}

##################################################
# set tx credit width
##################################################

if (($tl_selection == $TLSEL_AST64) | ($tl_selection == $TLSEL_AST128)) {
   $txcred_width = 36;
} else {
   if ($number_of_lanes == 8) {
      $txcred_width = 66;
   } else {
      $txcred_width = 22;
   }
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


if ($hip == 1) {
   $test_out_ltssm = "dl_ltssm";
   $test_out_lane = "lane_act";
} else {
   if ($number_of_lanes == 8) {
      $test_out_ltssm = "test_out_int[4:0]";
      $test_out_lane = "test_out_int[91:88]";
   } else {
      $test_out_ltssm = "test_out_int[324:320]";
      $test_out_lane = "test_out_int[411:408]";
   }
}


my $pipe_interface = " ";
my $pipe_connect_in = " ";
my $pipe_connect_out = " ";
my $pipe_open = " ";
my $pipe_kwidth = $pipe_width / 8;

# common phy signals
$pipe_interface .= "e_port->new([txdetectrx_ext => 1 => \"output\"]),";
$pipe_interface .= "e_port->new([powerdown_ext => 2 => \"output\"]),";
$pipe_interface .= "e_port->new([phystatus_ext => 1 => \"input\"]),";
$pipe_connect_in .= "phystatus_ext => phystatus_ext,";
$pipe_connect_out .= "txdetectrx_ext => txdetectrx_ext,";
$pipe_connect_out .= "powerdown_ext => powerdown_ext,";

if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) { # Dual phy
   $pipe_interface .= "e_port->new([phy1_powerdown_ext => 2 => \"output\"]),";
   $pipe_interface .= "e_port->new([phy1_phystatus_ext => 1 => \"input\"]),";
   $pipe_interface .= "e_port->new([phy1_txdetectrx_ext => 1 => \"output\"]),";

   $pipe_connect_in .= "phy1_phystatus_ext => phy1_phystatus_ext,";
   $pipe_connect_out .= "phy1_txdetectrx_ext => phy1_txdetectrx_ext,";
   $pipe_connect_out .= "phy1_powerdown_ext => phy1_powerdown_ext,";

}


for ($i = 0; $i < $number_of_lanes;  $i++) {
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

   $pipe_connect_in .= "rxdata$i\_ext => rxdata$i\_ext,";
   $pipe_connect_in .= "rxdatak$i\_ext => rxdatak$i\_ext,";
   $pipe_connect_in .= "rxvalid$i\_ext => rxvalid$i\_ext,";
   $pipe_connect_in .= "rxelecidle$i\_ext => rxelecidle$i\_ext,";
   $pipe_connect_in .= "rxstatus$i\_ext => rxstatus$i\_ext,";

   $pipe_connect_out .= "txdata$i\_ext => txdata$i\_ext,";
   $pipe_connect_out .= "txdatak$i\_ext => txdatak$i\_ext,";
   $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$i\_ext,";
   $pipe_connect_out .= "txcompl$i\_ext => txcompl$i\_ext,";
   $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$i\_ext,";
   if ($hip == 1) {
      $pipe_connect_out .= "rate_ext => rate_ext,";
      $pipe_connect_out .= "rc_pll_locked => rc_pll_locked,";
   }
}

##################################################
# add misc signals
##################################################

my $add_signals = " ";

# app clk
$add_signals .= "e_signal->new({name => app_clk, width=> 1, never_export => 1}),";

# app srstn
my $srstn=($phy_selection==$PHYSEL_SV)?'srstn_clk_ready':'srstn';

$add_signals .= "e_signal->new({name => srstn, width=> 1, never_export => 1}),";
$add_signals .= "e_signal->new({name => tx_fifo_empty0, width=> 1, never_export => 1}),";

# multi-bit bus
$add_signals .= "e_signal->new({name => app_msi_tc, width=> 3, never_export => 1}),";
$add_signals .= "e_signal->new({name => app_msi_num, width=> 5, never_export => 1}),";
$add_signals .= "e_signal->new({name => pex_msi_num_icm, width=> 5, never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_busdev_icm, width=> 13, never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_devcsr_icm, width=> 32,never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_linkcsr_icm, width=> 32,never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_prmcsr_icm, width=> 32,never_export => 1}),";
$add_signals .= "e_signal->new({name => gnd_cfg_tcvcmap_icm, width=> 24,never_export => 1}),";
$add_signals .= "e_signal->new({name => cpl_err_icm, width=> 7,never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_io_bas, width=> 20,never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_np_bas, width=> 12,never_export => 1}),";
$add_signals .= "e_signal->new({name => cfg_pr_bas, width=> 44,never_export => 1}),";
$add_signals .= "e_signal->new({name => lane_act, width=> 4,never_export => 1}),";
$add_signals .= "e_signal->new({name => dl_ltssm, width=> 5,never_export => 1}),";
$add_signals .= "e_signal->new({name => gnd_bus, width=> 128,never_export => 1}),";
if ($hip==1) {
   $add_signals .= ($phy_selection==$PHYSEL_SV)?"e_signal->new({name=>rate_ext , width=> 2 }),":
                                       "e_signal->new({name=>rate_ext , width=> 1 }),";
}

$add_signals   .= "e_signal->new({name => otb0,     width=> 1, never_export => 1}),";
$add_signals   .= "e_signal->new({name => otb1,      width=> 1, never_export => 1}),";

my $open_signals = " ";

# open app signals
$add_signals .= "e_signal->new({name => open_pm_data, width=> 10, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_aer_msi_num, width=> 5, never_export => 1}),";

##################################################
# Core VC interface
##################################################
my $vcs_connect_in = " ";
my $vcs_connect_out = " ";
my $vcs_open = " ";
my $vcs_signals = " ";
my $app_name;
my $glue_logic = " ";
my $pcie_hip_reconfig_connect='';

if ($simple_dma == 1) {
   $app_name = "altpcierd_example_app";
} else {
   if ($tl_selection==9) {
      $app_name = "altpcierd_ast256_downstream";
   } else {
      $app_name = "altpcierd_example_app_chaining";
   }
}

my $label = " ";
my %label;


$glue_logic  .= "e_assign->new ([ otb0=> \"1'b0\"]),";
$glue_logic  .= "e_assign->new ([ otb1 => \"1'b1\"]),";

$vcs_signals .= "e_signal->new({name => ko_cpl_spc_vc0, width=> 20, never_export => 1}),";
if ($phy_selection == $PHYSEL_SV) {
   $vcs_signals .= "e_signal->new({name => tx_cred_datafccp   , width=> 12, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_datafcnp   , width=> 12, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_datafcp    , width=> 12, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_fchipcons  , width=>  6, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_fcinfinite , width=>  6, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_hdrfccp    , width=>  8, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_hdrfcnp    , width=>  8, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_cred_hdrfcp     , width=>  8, never_export => 1}),";
   if ($tl_selection!=$TLSEL_AST256) {
      $vcs_signals .= "e_signal->new({name => tx_stream_cred0, width=> $txcred_width, never_export => 1}),";
      $vcs_signals .= "e_signal->new({name => tx_stream_cred0, width=> $txcred_width, never_export => 1}),";
      $vcs_signals .= "e_signal->new({name => tx_stream_cred1, width=> $txcred_width, never_export => 1}),";
      $vcs_signals .= "e_signal->new({name => tx_stream_data0, width=> 75}),";
      $vcs_signals .= "e_signal->new({name => rx_stream_data0, width=> 82}),";
      $vcs_signals .= "e_signal->new({name => msi_stream_data0, width=> 8}),";
   }
} else {
   $vcs_signals .= "e_signal->new({name => tx_stream_cred0, width=> $txcred_width, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_stream_cred1, width=> $txcred_width, never_export => 1}),";
   $vcs_signals .= "e_signal->new({name => tx_stream_data0, width=> 75}),";
   $vcs_signals .= "e_signal->new({name => rx_stream_data0, width=> 82}),";
   $vcs_signals .= "e_signal->new({name => msi_stream_data0, width=> 8}),";
}


if (($tl_selection == $TLSEL_AST256) | ($tl_selection == $TLSEL_AST128) | ($tl_selection == $TLSEL_AST64))  { # HIPCAB

   my $be_width = 8;
   my $data_width = 8;

   if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
      $data_width = 128;
      $be_width = 16;
   } elsif ($tl_selection == $TLSEL_AST256) { # 256 bit mode unbonded
      $data_width = 256;
      $be_width = 32;
   } else {
      $data_width = 64;
      $be_width = 8;
   }


   for ($i = 0; $i < $number_of_vcs; $i++) {
      if (($i == 0) | ($rp > 0)) {
         if ($tl_selection == $TLSEL_AST256) {
            $vcs_connect_in  .= "rx_st_ready$i => rx_st_ready$i,";
            $vcs_connect_out .= "rx_st_valid$i => rx_st_valid$i,";
         } else {
            $vcs_connect_in .= "rx_st_ready$i => rx_stream_ready$i,";
            $vcs_connect_out .= "rx_st_valid$i => rx_stream_valid$i,";
         }

         if ($tl_selection == $TLSEL_AST256) { # 256 bit unbonded
            $vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 256}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 256}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 256}),";
            $vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 32}),";
         } elsif (($rp > 0) | ($tl_selection == $TLSEL_AST128)) {
            $vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 128}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 128}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 128}),";
            $vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 16}),";
         } else {
            $vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 64}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 64}),";
            $vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 64}),";
            $vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 8}),";
         }


         if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
            $vcs_connect_out .= "rx_st_empty$i => rx_st_empty$i,";
            $vcs_connect_in .= "tx_st_empty$i => tx_st_empty$i,";
            $vcs_connect_out .= "rx_st_data$i => rx_st_data$i,";
            $vcs_connect_out .= "rx_st_be$i => rx_st_be$i,";
            $vcs_connect_in .= "tx_st_data$i => tx_st_data$i,";
            if ($phy_selection==$PHYSEL_SV) {
               $vcs_connect_in  .= "tx_st_parity$i  => \"16'h0\",";                    #TODO Add parity in application
            }
         } elsif ($tl_selection == $TLSEL_AST256) { # 256 bit unbonded
            $vcs_signals .= "e_signal->new({name => rx_st_empty$i, width=> 2}),";
            $vcs_connect_out .= "rx_st_empty$i => rx_st_empty$i,";
            $vcs_signals .= "e_signal->new({name => tx_st_empty$i, width=> 2}),";
            $vcs_connect_in .= "tx_st_empty$i => tx_st_empty$i,";
            $vcs_connect_out .= "rx_st_data$i => rx_st_data$i,";
            $vcs_connect_out .= "rx_st_be$i => rx_st_be$i,";
            $vcs_connect_in .= "tx_st_data$i => tx_st_data$i,";
            if ($phy_selection==$PHYSEL_SV) {
               $vcs_connect_in  .= "tx_st_parity$i  => \"32'h0\",";
            }
         } else {
            $vcs_connect_out .= "rx_st_data$i => \"rx_st_data$i\[63:0]\",";
            $vcs_connect_out .= "rx_st_be$i => \"rx_st_be$i\[7:0]\",";
            $vcs_connect_in .= "tx_st_data$i => \"tx_st_data$i\[63:0]\",";
            if ($phy_selection==$PHYSEL_SV) {
               $vcs_connect_in  .= "tx_st_parity$i  => \"8'h0\",";
            }
         }

         if ($tl_selection == $TLSEL_AST256) {
            $vcs_connect_in .= "rx_st_mask$i => rx_st_mask$i,";
         } else {
            $vcs_connect_in .= "rx_st_mask$i => rx_mask$i,";
         }
         $vcs_signals .= "e_signal->new({name => rx_st_bardec$i, width=> 8, never_export => 1}),";
         $vcs_connect_out .= "rx_st_bardec$i => rx_st_bardec$i,";
         if ($tl_selection == $TLSEL_AST256) {
            $vcs_signals .= "e_signal->new({name => rx_st_sop$i, width=> 1, never_export => 1}),";
            $vcs_signals .= "e_signal->new({name => rx_st_eop$i, width=> 1, never_export => 1}),";
            $vcs_signals .= "e_signal->new({name => tx_st_sop$i, width=> 1, never_export => 1}),";
            $vcs_signals .= "e_signal->new({name => tx_st_eop$i, width=> 1, never_export => 1}),";
         }

         $vcs_connect_out .= "rx_st_sop$i => rx_st_sop$i,";
         $vcs_connect_out .= "rx_st_eop$i => rx_st_eop$i,";
         $vcs_connect_in .=  "tx_st_sop$i => tx_st_sop$i,";
         $vcs_connect_in .=  "tx_st_eop$i => tx_st_eop$i,";

         if ($rp>0) {
            $add_signals .= "e_signal->new({name => gnd_tx_st_err$i ,  never_export => 1}),";
            $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_err$i , width => 1}, rhs => \"1'b0\"}),";
            $vcs_connect_in .= "tx_st_err$i => gnd_tx_st_err$i,";
         } else {
            $add_signals .= "e_signal->new({name => tx_st_err$i ,  never_export => 1}),";
            $vcs_connect_in .= "tx_st_err$i => tx_st_err$i,";
         }
         if ($phy_selection == $PHYSEL_SV) {
            $vcs_signals .= "e_signal->new({name => tx_st_valid$i, width=> 1, never_export => 1}),";
            $vcs_signals .= "e_signal->new({name => tx_st_ready$i, width=> 1, never_export => 1}),";
            $vcs_connect_in  .= "tx_st_valid$i => tx_st_valid$i,";
            $vcs_connect_out .= "tx_st_ready$i      => tx_st_ready$i,";
            $vcs_connect_out .= "tx_cred_datafccp   => tx_cred_datafccp  ,";
            $vcs_connect_out .= "tx_cred_datafcnp   => tx_cred_datafcnp  ,";
            $vcs_connect_out .= "tx_cred_datafcp    => tx_cred_datafcp   ,";
            $vcs_connect_out .= "tx_cred_fchipcons  => tx_cred_fchipcons ,";
            $vcs_connect_out .= "tx_cred_fcinfinite => tx_cred_fcinfinite,";
            $vcs_connect_out .= "tx_cred_hdrfccp    => tx_cred_hdrfccp   ,";
            $vcs_connect_out .= "tx_cred_hdrfcnp    => tx_cred_hdrfcnp   ,";
            $vcs_connect_out .= "tx_cred_hdrfcp     => tx_cred_hdrfcp    ,";
         } else {
            $vcs_connect_in .= "tx_st_valid$i => tx_stream_valid$i,";
            $vcs_connect_out .= "tx_st_ready$i => tx_stream_ready$i,";
            $vcs_connect_out .= "tx_cred$i => tx_stream_cred$i,";
         }
      } else {
         $add_signals .= "e_signal->new({name => gnd_rx_st_ready$i ,  never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_st_ready$i , width => 1}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_st_ready$i => gnd_rx_st_ready$i,";

         $add_signals .= "e_signal->new({name => open_rx_st_valid$i ,  never_export => 1}),";
         $vcs_connect_out .= "rx_st_valid$i => open_rx_st_valid$i,";

         if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
            $add_signals .= "e_signal->new({name => open_rx_st_data$i ,  width => 128 , never_export => 1}),";
            $add_signals .= "e_signal->new({name => open_rx_st_be$i ,  width => 16 , never_export => 1}),";
            $vcs_connect_in .= "tx_st_empty$i => \"1'b0\",";

         } else {
            $add_signals .= "e_signal->new({name => open_rx_st_data$i ,  width => 64 , never_export => 1}),";
            $add_signals .= "e_signal->new({name => open_rx_st_be$i ,  width => 8 , never_export => 1}),";

         }
         $vcs_connect_out .= "rx_st_data$i => open_rx_st_data$i,";
         $vcs_connect_out .= "rx_st_be$i => open_rx_st_be$i,";

         $add_signals .= "e_signal->new({name => gnd_rx_st_mask$i ,  never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_st_mask$i , width => 1}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "rx_st_mask$i => gnd_rx_st_mask$i,";

         $add_signals .= "e_signal->new({name => open_rx_st_bardec$i ,  width => 8 , never_export => 1}),";
         $vcs_connect_out .= "rx_st_bardec$i => open_rx_st_bardec$i,";



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

         $add_signals .= "e_signal->new({name => gnd_tx_st_data$i ,  width => $data_width , never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_data$i , width => $data_width}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "tx_st_data$i => gnd_tx_st_data$i,";

         $add_signals .= "e_signal->new({name => open_tx_st_ready$i ,  never_export => 1}),";
         $vcs_connect_out .= "tx_st_ready$i => open_tx_st_ready$i,";

         $add_signals .= "e_signal->new({name => open_tx_stream_cred$i , width => $txcred_width , never_export => 1}),";
         $vcs_connect_out .= "tx_cred$i => open_tx_stream_cred$i,";


      }

      if ($tl_selection==$TLSEL_AST256) {
         $vcs_connect_out .= "rx_st_err$i => rx_st_err$i,";
      } else {
         $add_signals .= "e_signal->new({name => open_rx_st_err$i ,  never_export => 1}),";
         $vcs_connect_out .= "rx_st_err$i => open_rx_st_err$i,";
      }


      if (($i == 0) & ($number_of_lanes < 8) & ($hip == 0)) {
         $add_signals .= "e_signal->new({name => gnd_err_desc_func0 ,  width => 128 , never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_err_desc_func0 , width => 128}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "err_desc_func0 => gnd_err_desc_func0,";
      }

      if ($hip == 1) {

         if ($simple_dma == 1) {
            if ($i == 0) {
               $add_signals .= "e_signal->new({name => gnd_lmi_addr, width => 12 ,never_export => 1}),";
               $vcs_connect_in .= "lmi_addr => gnd_lmi_addr,";
               $glue_logic .= "e_assign->new({lhs => {name => gnd_lmi_addr}, rhs => \"0\"}),";
               $add_signals .= "e_signal->new({name => gnd_lmi_din, width => 32 ,never_export => 1}),";
               $vcs_connect_in .= "lmi_din => gnd_lmi_din,";
               $glue_logic .= "e_assign->new({lhs => {name => gnd_lmi_din}, rhs => \"0\"}),";
               $vcs_connect_in .= "lmi_rden => \"1'b0\",";
               $vcs_connect_in .= "lmi_wren => \"1'b0\",";
               $add_signals .= "e_signal->new({name => open_lmi_dout, width => 32 ,never_export => 1}),";
               $vcs_connect_out .= "lmi_dout => open_lmi_dout,";
               $add_signals .= "e_signal->new({name => open_lmi_ack, never_export => 1}),";
               $vcs_connect_out .= "lmi_ack => open_lmi_ack,";
            }
         } else { # instantiate LMI module

            $add_signals .= "e_signal->new({name => err_desc, width => 128 ,never_export => 1}),";
            $vcs_connect_in .= "lmi_addr => lmi_addr,";

            # lmi address bus for the driver
            $add_signals .= "e_signal->new({name => lmi_addr, width => 12 ,never_export => 1}),";

            $add_signals .= "e_signal->new({name => lmi_din, width => 32 ,never_export => 1}),";
            $vcs_connect_in .= "lmi_din => lmi_din,";
            $add_signals .= "e_signal->new({name => lmi_rden, width => 1 ,never_export => 1}),";
            $vcs_connect_in .= "lmi_rden => lmi_rden,";
            $add_signals .= "e_signal->new({name => lmi_wren, width => 1 ,never_export => 1}),";
            $vcs_connect_in .= "lmi_wren => lmi_wren,";
            $add_signals .= "e_signal->new({name => lmi_dout, width => 32 ,never_export => 1}),";
            $vcs_connect_out .= "lmi_dout => lmi_dout,";
            $add_signals .= "e_signal->new({name => lmi_ack, width => 1 ,never_export => 1}),";
            $vcs_connect_out .= "lmi_ack => lmi_ack,";
            $add_signals .= "e_signal->new({name => cpl_err_in, width=> 7}),";
            $add_signals .= "e_signal->new({name => open_cplerr_lmi_busy, never_export => 1}),";

            if ($rp == 0) {
               $label = "lmi_inst";
               $label{$label} = 1;;
               $$label = e_blind_instance->new({
                     module => "altpcierd_cplerr_lmi",
                     name => "lmi_blk",
                     in_port_map => {
                        clk_in => "$app_clk_in",
                        rstn => "$srstn",
                        err_desc => "err_desc",
                        cpl_err_in => "cpl_err_in",
                        lmi_ack => "lmi_ack",

                     },
                     out_port_map => {
                        lmi_din => "lmi_din",
                        lmi_addr => "lmi_addr",
                        lmi_wren => "lmi_wren",
                        lmi_rden => "lmi_rden",
                        cpl_err_out => "cpl_err_icm",
                        cplerr_lmi_busy => "open_cplerr_lmi_busy",

                     },

                  });

            } else {
               if ($i == 0) {
                  $glue_logic .= "e_assign->new({lhs => {name => lmi_din}, rhs => \"0\"}),";
                  $glue_logic .= "e_assign->new({lhs => {name => lmi_addr}, rhs => \"0\"}),";
                  $glue_logic .= "e_assign->new({lhs => {name => lmi_wren}, rhs => \"0\"}),";
                  $glue_logic .= "e_assign->new({lhs => {name => lmi_rden}, rhs => \"0\"}),";
                  $glue_logic .= "e_assign->new({lhs => {name => cpl_err_icm}, rhs => \"0\"}),";
               }
            }
         }

         # tied off misc ports
         if (($rp > 0) & ($i == 0)) { # root port
            $add_signals .= "e_signal->new({name => gnd_aer_msi_num, width => 5 ,never_export => 1}),";
            $vcs_connect_in .= "aer_msi_num => gnd_aer_msi_num,";
            $glue_logic .= "e_assign->new({lhs => {name => gnd_aer_msi_num}, rhs => \"0\"}),";
         }
         $vcs_connect_in .= "pm_auxpwr => \"1'b0\",";
         $add_signals .= "e_signal->new({name => gnd_pm_data, width => 10 ,never_export => 1}),";
         $vcs_connect_in .= "pm_data => gnd_pm_data,";
         if ($rp == 0) { # root port
            $vcs_connect_in .= "pm_event => \"1'b0\",";
         }

         if ($i == 0) {
            $glue_logic .= "e_assign->new({lhs => {name => gnd_pm_data}, rhs => \"0\"}),";
         }

         # HIP debug port
         $vcs_connect_out .= "ltssm => dl_ltssm,";
         $vcs_connect_out .= "lane_act => lane_act,";
         $vcs_connect_out .= "tx_fifo_empty0 => tx_fifo_empty0,";
      }
   }
}

# instantiate test out port
if (($test_out_width > 0) & (($tl_selection == $TLSEL_AST64) | ($tl_selection == $TLSEL_AST128))) {
   $vcs_connect_out .= "test_out => \"test_out_int\",";
}

# test_in width
if ($phy_selection == $PHYSEL_HIP_40nm) { # S4GX, A2GX, C4GX
   $test_in_width = 40;
} else {
   $test_in_width = 32;
}

##################################################
# Apps VC interface
##################################################
my $app_vcs_connect_in = " ";
my $app_vcs_connect_out = " ";
my $app_vcs_open = " ";
my $app_vcs_signals = " ";

$app_vcs_connect_in .= "ko_cpl_spc_vc0 => ko_cpl_spc_vc0,";
$app_vcs_connect_out .= "cpl_pending => cpl_pending_icm,";

if ($simple_dma == 1) {
   $app_vcs_connect_in  .= "rx_stream_data0 => rx_stream_data0,";
   $app_vcs_connect_in  .= "tx_stream_ready0 => tx_stream_ready0,";
   $app_vcs_connect_in  .= "rx_stream_valid0 => rx_stream_valid0,";
   $app_vcs_connect_out .= "tx_stream_data0 => tx_stream_data0,";
   $app_vcs_connect_out .= "cpl_err => cpl_err_icm,";
   $app_vcs_connect_out .= "tx_stream_valid0 => tx_stream_valid0,";
   $app_vcs_connect_out .= "rx_stream_mask0 => rx_mask0,";
} else {
   if ($tl_selection == $TLSEL_AST256) {
      $app_vcs_connect_in  .= "rx_st_data0   => rx_st_data0,";
      $app_vcs_connect_in  .= "rx_st_bardec0 => rx_st_bardec0,";
      $app_vcs_connect_in  .= "rx_st_be0     => rx_st_be0,";
      $app_vcs_connect_in  .= "rx_st_sop0    => rx_st_sop0,";
      $app_vcs_connect_in  .= "rx_st_eop0    => rx_st_eop0,";
      $app_vcs_connect_in  .= "rx_st_err0    => rx_st_err0,";
      $app_vcs_connect_in  .= "rx_st_empty0  => rx_st_empty0,";
      $app_vcs_connect_in  .= "rx_st_valid0  => rx_st_valid0,";
      $app_vcs_connect_out .= "rx_st_mask0   => rx_st_mask0,";
      $app_vcs_connect_in  .= "tx_st_ready0  => tx_st_ready0,";
      $app_vcs_connect_out .= "rx_st_ready0  => rx_st_ready0,";
      $app_vcs_connect_out .= "tx_st_data0   => tx_st_data0  ,";
      $app_vcs_connect_out .= "tx_st_empty0  => tx_st_empty0 ,";
      $app_vcs_connect_out .= "tx_st_eop0    => tx_st_eop0   ,";
      $app_vcs_connect_out .= "tx_st_err0    => tx_st_err0   ,";
      $app_vcs_connect_out .= "tx_st_sop0    => tx_st_sop0   ,";
      $app_vcs_connect_out .= "tx_st_valid0  => tx_st_valid0 ,";
   } else {
      $app_vcs_connect_out .= "rx_stream_mask0 => rx_mask0,";
      if ($phy_selection==$PHYSEL_SV) {
         $app_vcs_connect_in .= "tx_stream_ready0 => tx_st_ready0,";
      } else {
         $app_vcs_connect_in .= "tx_stream_ready0 => tx_stream_ready0,";
      }
      $app_vcs_connect_in .= "rx_stream_valid0 => rx_stream_valid0,";
      $app_vcs_connect_in .= "rx_stream_data0_0 => rx_stream_data0,";
      if ((($hip == 1) | ($tl_selection == $TLSEL_AST64)) & ($phy_selection < 7)) { # SIP Avalon ST or HIP and prior to S5GX
         $app_vcs_connect_in .= "tx_stream_fifo_empty0 => tx_fifo_empty0,";
      } else {
         $app_vcs_connect_in .= "tx_stream_fifo_empty0 => \"1'b1\",";
      }
      if ($tl_selection == $TLSEL_AST128) {
         $add_signals .= "e_signal->new({name => rx_stream_data0_1, width=> 82}),";
         $app_vcs_connect_in .= "rx_stream_data0_1 => rx_stream_data0_1,";
      } else {
         $add_signals .= "e_signal->new({name => gnd_rx_stream_data0_1 ,  width => 82 , never_export => 1}),";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_stream_data0_1 , width => 82}, rhs => \"1'b0\"}),";
         $app_vcs_connect_in .= "rx_stream_data0_1 => gnd_rx_stream_data0_1,";
      }
      if ($phy_selection==$PHYSEL_SV) {
         $app_vcs_connect_out .= "tx_stream_valid0 => tx_st_valid0,";
      } else {
         $app_vcs_connect_out .= "tx_stream_valid0 => tx_stream_valid0,";
      }
      $app_vcs_connect_out .= "tx_stream_data0_0 => tx_stream_data0,";
      if ($tl_selection == $TLSEL_AST128) {
         $add_signals .= "e_signal->new({name => tx_stream_data0_1, width=> 75}),";
         $app_vcs_connect_out .= "tx_stream_data0_1 => tx_stream_data0_1,";
      } else {
         $add_signals .= "e_signal->new({name => open_tx_stream_data0_1 ,  width => 75 , never_export => 1}),";
         $app_vcs_connect_out .= "tx_stream_data0_1 => open_tx_stream_data0_1,";
      }
   }
   if ($hip == 0) { # no LMI
      $app_vcs_connect_out .= "cpl_err => cpl_err_icm,";
   } else {
      $app_vcs_connect_out .= "cpl_err => cpl_err_in,";
      $app_vcs_connect_out .= "err_desc => err_desc,";
   }
}


if ($tl_selection !=$TLSEL_AST256) {
   $app_vcs_connect_out .= "rx_stream_ready0 => rx_stream_ready0,";
   $add_signals .= "e_signal->new({name => gnd_tx_stream_mask0 ,  width => 1 , never_export => 1}),";
   $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_stream_mask0 , width => 1}, rhs => \"1'b0\"}),";
   $app_vcs_connect_in .= "tx_stream_mask0 => gnd_tx_stream_mask0,";
   $app_vcs_signals .= "e_assign->new({lhs => {name => gnd_msi_stream_ready0, width => 1,never_export => 1}, rhs => \"1'b0\"}),";
   $app_vcs_connect_in .= "msi_stream_ready0 => gnd_msi_stream_ready0,";

   $add_signals .= "e_signal->new({name => open_msi_stream_valid0 ,  width => 1 , never_export => 1}),";
   $app_vcs_connect_out .= "msi_stream_valid0 => open_msi_stream_valid0,";

   $add_signals .= "e_signal->new({name => open_msi_stream_data0 ,  width => 8 , never_export => 1}),";
   $app_vcs_connect_out .= "msi_stream_data0 => open_msi_stream_data0,";

}

##################################################
# Add pipe_txclk
##################################################

if ($pipe_txclk == 1) {
   $top_example_pipen1b->add_contents
   (
      my $txclk = e_port->new([ pipe_txclk => 1 => "output"]),
   );
   $pipe_connect_out .= "pipe_txclk => pipe_txclk,";

}


##################################################
# Alt2gxb specific signals
##################################################

# pass down ko_signal and cfg_tcvcmap
$glue_logic .= "e_assign->new ([ \"ko_cpl_spc_vc0[7:0]\" => \"8'd$cplh_cred\"]),";
$glue_logic .= "e_assign->new ([ \"ko_cpl_spc_vc0[19:8]\" => \"12'd$cpld_cred\"]),";
$glue_logic .= "e_assign->new ([ \"gnd_cfg_tcvcmap_icm\" => \"0\"]),";

if ($rp == 0) {
   if ($tl_selection == $TLSEL_AST128) {
      $glue_logic .= "e_assign->new ([ tx_st_sop0 => \"tx_stream_data0[73]\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_err0 => \"tx_stream_data0[74]\"]),";
      $glue_logic .= "e_assign->new ([ rx_stream_data0 => \"{rx_st_be0[7:0], rx_st_sop0, rx_st_empty0, rx_st_bardec0, rx_st_data0[63:0]}\"]),";
      $glue_logic .= "e_assign->new ([ rx_stream_data0_1 => \"{rx_st_be0[15:8], rx_st_sop0, rx_st_eop0, rx_st_bardec0, rx_st_data0[127:64:0]}\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_data0 => \"{tx_stream_data0_1[63:0],tx_stream_data0[63:0]}\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_eop0 => \"tx_stream_data0_1[72]\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_empty0 => \"tx_stream_data0[72]\"]),";
   } elsif ($tl_selection != $TLSEL_AST256) {
      $glue_logic .= "e_assign->new ([ tx_st_sop0 => \"tx_stream_data0[73]\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_err0 => \"tx_stream_data0[74]\"]),";
      $glue_logic .= "e_assign->new ([ rx_stream_data0 => \"{rx_st_be0, rx_st_sop0, rx_st_eop0, rx_st_bardec0, rx_st_data0}\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_data0 => \"tx_stream_data0[63:0]\"]),";
      $glue_logic .= "e_assign->new ([ tx_st_eop0 => \"tx_stream_data0[72]\"]),";
   }
}
$add_signals .= "e_signal->new({name => test_out_int, width=>  $test_out_width, never_export => 1}),";
if ($test_out_width == 9) {
   $glue_logic .= "e_assign->new({lhs => {name => test_out_icm}, rhs => \"test_out_int\"}),";
} elsif ($test_out_width > 0) { # full width
   $glue_logic .= "e_assign->new({lhs => {name => test_out_icm}, rhs => \"{$test_out_lane,$test_out_ltssm}\"}),";
} else {
   $glue_logic .= "e_assign->new({lhs => {name => test_out_icm}, rhs => \"0\"}),";
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

   $label = "pcie_hip_reconfig";
   $label{$label} = 1;;
   $$label = e_blind_instance->new({
         module => "altpcierd_pcie_reconfig_initiator",
         name => "pcie_reconfig_initiator0",
         in_port_map => {
            avs_pcie_reconfig_waitrequest => "avs_pcie_reconfig_waitrequest",
            avs_pcie_reconfig_readdata => "avs_pcie_reconfig_readdata",
            avs_pcie_reconfig_readdatavalid => "avs_pcie_reconfig_readdatavalid",
            pcie_reconfig_clk  => "reconfig_clk",
            set_pcie_reconfig  => "set_pcie_reconfig",
            pcie_rstn => "pcie_rstn",
         },
         out_port_map => {
            avs_pcie_reconfig_address => "avs_pcie_reconfig_address",
            avs_pcie_reconfig_chipselect => "avs_pcie_reconfig_chipselect",
            avs_pcie_reconfig_write => "avs_pcie_reconfig_write",
            avs_pcie_reconfig_writedata => "avs_pcie_reconfig_writedata",
            avs_pcie_reconfig_read => "avs_pcie_reconfig_read",
            avs_pcie_reconfig_clk => "avs_pcie_reconfig_clk",
            avs_pcie_reconfig_rstn => "avs_pcie_reconfig_rstn",
            pcie_reconfig_busy => "pcie_reconfig_busy",
         },
      });
   $glue_logic .= "e_assign->new({lhs => {name => set_pcie_reconfig}, rhs => \"1'b1\"}),";
   $pcie_hip_reconfig_connect = 'pcie_reconfig_busy => "pcie_reconfig_busy",';
} else {
   $glue_logic .= "e_assign->new({lhs => {name => pcie_reconfig_busy}, rhs => \"1'b1\"}),";
}


##################################################
# Add Design example PLL for HIP SERDES
##################################################

if ($phy_selection==$PHYSEL_HIP_40nm) {
   $add_signals .= "e_signal->new({name => reconfig_clk_locked, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => fixedclk_serdes, width=> 1, never_export => 1}),";
   $add_signals .= "e_signal->new({name => reconfig_clk, width=> 1, never_export => 1}),";
   $label = "altpcierd_reconfig_pll";
   $label{$label} = 1;
   $$label = e_blind_instance->new({
       module => "altpcierd_reconfig_clk_pll",
       name => "reconfig_pll",
       in_port_map => {
         inclk0 => "free_100MHz",
       },
       out_port_map => {
         c0       => "reconfig_clk",
         c1       => "fixedclk_serdes",
         locked   => "reconfig_clk_locked",
       },
   });
}

##################################################
# Instantiate user variation HIP ez
##################################################
my $var_inst_ez;

$cfg_ports = " ";

$add_signals .= "e_signal->new({name => cfg_msicsr, width=> 16, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_cfg_pmcsr, width=> 32, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_cfg_prmcsr, width=> 32, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_cfg_tcvcmap, width=> 24, never_export => 1}),";
$add_signals .= "e_signal->new({name => tl_cfg_add, width=> 4}),";
$add_signals .= "e_signal->new({name => tl_cfg_ctl, width=> 32}),";
$add_signals .= "e_signal->new({name => tl_cfg_sts, width=> 53}),";
$add_signals .= "e_signal->new({name => app_int_ack_icm, width=> 1, never_export => 1}),";

$cfg_ports .= " tl_cfg_add => tl_cfg_add,\n";
$cfg_ports .= " tl_cfg_ctl => tl_cfg_ctl,\n";
$cfg_ports .= " tl_cfg_sts => tl_cfg_sts,\n";
$cfg_ports .= " tl_cfg_sts_wr => tl_cfg_sts_wr,\n";
$cfg_ports .= " tl_cfg_ctl_wr => tl_cfg_ctl_wr,\n";

if ($simple_dma) {
   # regeneration configuration bus
   $glue_logic .= "e_process->new({
   comment => \"Synchronise to pld side \",
   clock => \"pld_clk\",
   reset => \"$srstn\",
   asynchronous_contents => [
   e_assign->new([\"tl_cfg_ctl_wr_r\" => '0']),
   e_assign->new([\"tl_cfg_ctl_wr_rr\" => '0']),
   e_assign->new([\"tl_cfg_ctl_wr_rrr\" => '0']),
   e_assign->new([\"tl_cfg_sts_wr_r\" => '0']),
   e_assign->new([\"tl_cfg_sts_wr_rr\" => '0']),
   e_assign->new([\"tl_cfg_sts_wr_rrr\" => '0']),

   ],
   contents => [
   e_assign->new([\"tl_cfg_ctl_wr_r\" => \"tl_cfg_ctl_wr\"]),
   e_assign->new([\"tl_cfg_ctl_wr_rr\" => \"tl_cfg_ctl_wr_r\"]),
   e_assign->new([\"tl_cfg_ctl_wr_rrr\" => \"tl_cfg_ctl_wr_rr\"]),
   e_assign->new([\"tl_cfg_sts_wr_r\" => \"tl_cfg_sts_wr\"]),
   e_assign->new([\"tl_cfg_sts_wr_rr\" => \"tl_cfg_sts_wr_r\"]),
   e_assign->new([\"tl_cfg_sts_wr_rrr\" => \"tl_cfg_sts_wr_rr\"]),

   ],
   }),";
   $glue_logic .= "e_process->new({
   comment => \"Configuration Demux logic \",
   clock => \"pld_clk\",
   reset => \"$srstn\",
   asynchronous_contents => [
   e_assign->new([\"cfg_busdev_icm\" => '0']),
   e_assign->new([\"cfg_devcsr_icm\" => '0']),
   e_assign->new([\"cfg_linkcsr_icm\" => '0']),
   e_assign->new([\"cfg_prmcsr_icm\" => '0']),

   ],
   contents => [
   e_if->new({
   condition => \"(tl_cfg_sts_wr_rrr != tl_cfg_sts_wr_rr)\",
   then => [\"cfg_devcsr_icm[19:16]\"=> \"tl_cfg_sts[52:49]\",\"cfg_linkcsr_icm[31:16]\"=> \"tl_cfg_sts[46:31]\" ],
   }),
   e_if->new({
   condition => \"((tl_cfg_add==4'h0) && (tl_cfg_ctl_wr_rrr != tl_cfg_ctl_wr_rr))\",
   then => [\"cfg_devcsr_icm[15:0]\"=> \"tl_cfg_ctl[31:16]\" ],
   }),
   e_if->new({
   condition => \"((tl_cfg_add==4'h2) && (tl_cfg_ctl_wr_rrr != tl_cfg_ctl_wr_rr))\",
   then => [\"cfg_linkcsr_icm[15:0]\"=> \"tl_cfg_ctl[31:16]\" ],
   }),
   e_if->new({
   condition => \"((tl_cfg_add==4'hF) && (tl_cfg_ctl_wr_rrr != tl_cfg_ctl_wr_rr))\",
   then => [\"cfg_busdev_icm\"=> \"tl_cfg_ctl[12:0]\" ],
   }),
   ],
   }),";
} else { # instantiate module for chaining DMA
   my $p_str = ($phy_selection==$PHYSEL_SV)?"HIP_SV=>1":"HIP_SV=>0";
   $label = "cfg_inst";
   $label{$label} = 1;
   $$label = e_blind_instance->new({
         module => "altpcierd_tl_cfg_sample",
         name => "cfgbus",
         parameter_map => {
            eval($p_str)
         },
         in_port_map => {
            pld_clk => "$app_clk_in",
            rstn => "$srstn",
            tl_cfg_add => "tl_cfg_add",
            tl_cfg_ctl => "tl_cfg_ctl",
            tl_cfg_ctl_wr => "tl_cfg_ctl_wr",
            tl_cfg_sts => "tl_cfg_sts",
            tl_cfg_sts_wr => "tl_cfg_sts_wr",
         },
         out_port_map => {
            cfg_busdev => "cfg_busdev_icm",
            cfg_devcsr => "cfg_devcsr_icm",
            cfg_linkcsr => "cfg_linkcsr_icm",
            cfg_prmcsr => "cfg_prmcsr_icm",
            cfg_tcvcmap => "open_cfg_tcvcmap",
            cfg_msicsr => "cfg_msicsr",
            cfg_io_bas => "cfg_io_bas",
            cfg_np_bas => "cfg_np_bas",
            cfg_pr_bas => "cfg_pr_bas",
         },
      });
}

my $inst_name_ez = ($rp == 0)?"ep_plus":"rp_plus";


my $rst_port_ez_in  = '';
my $rst_port_ez_out = '';
if ($phy_selection==$PHYSEL_SV) {
   $rst_port_ez_in  .= 'perst_n           => "perst_n",';
   $rst_port_ez_in  .= 'local_rstn        => "local_rstn",';
   $rst_port_ez_in  .= 'pld_clk_ready     => "pld_clk_ready",';
   $rst_port_ez_out .= 'pld_clk_in_use    => "pld_clk_in_use",';
   $rst_port_ez_out .= 'reset_status      => "reset_status",';
   $rst_port_ez_out .= 'srstn             => "srstn",';
   $add_signals     .= "e_signal->new({name => perst_n       , width=> 1, never_export => 1}),";
   $add_signals     .= "e_signal->new({name => pld_clk_ready , width=> 1, never_export => 1}),";
   $add_signals     .= "e_signal->new({name => pld_clk_in_use, width=> 1, never_export => 1}),";
   $add_signals     .= "e_signal->new({name => reset_status  , width=> 1, never_export => 1}),";
   $add_signals     .= "e_signal->new({name => srstn_clk_ready , width=> 1, never_export => 1}),";
   $glue_logic      .= "e_assign->new({lhs => {name => pld_clk_ready , width => 1}, rhs => \"1\"}),";
   $glue_logic      .= "e_assign->new({lhs => {name => perst_n , width => 1}, rhs => \"pcie_rstn\"}),";
   $glue_logic      .= "e_assign->new({lhs => {name => srstn_clk_ready , width => 1}, rhs => \"(pld_clk_in_use==0)?1'b0:srstn\"}),";
} else {
   $rst_port_ez_in  .= 'local_rstn  => "local_rstn",';
   $rst_port_ez_in  .= 'pcie_rstn   => "pcie_rstn",';
   $rst_port_ez_out .= 'srstn       => "srstn",';
}

my $serdes_clk_connect='';

if ($phy_selection==$PHYSEL_HIP_40nm) {
   $serdes_clk_connect .= 'fixedclk_serdes      => "fixedclk_serdes",';
   $serdes_clk_connect .= 'reconfig_clk         => "reconfig_clk",';
   $serdes_clk_connect .= 'reconfig_clk_locked  => "reconfig_clk_locked",';
}

$var_inst_ez = e_blind_instance->new({
      module   => "$module_ez",
      name     => "$inst_name_ez",
      in_port_map => {
         refclk => "refclk",
         eval($dual_phy_in),
         eval($clk_in),
         eval($rst_port_ez_in),
         eval($serdes_in),
         eval($serdes_clk_connect),
         eval($pipe_connect_in),
         eval($pcie_hip_reconfig_connect),
         test_in              => "test_in",
         cpl_pending          => "cpl_pending_icm",
         cpl_err              => "cpl_err_icm",
         pme_to_cr            => "pme_to_sr",
         app_int_sts          => "app_int_sts_icm",
         app_msi_req          => "app_msi_req",
         app_msi_tc           => "app_msi_tc",
         app_msi_num          => "app_msi_num",
         pex_msi_num          => "pex_msi_num_icm",
         eval($vcs_connect_in),
      },
      out_port_map => {
         eval($clk_out),
         eval($rst_port_ez_out),

         eval($dual_phy_out),
          #eval($alt2gxb_out_ez),
         eval($serdes_out),
         eval($pipe_connect_out),

         eval($app_clk_out),
         pme_to_sr => "pme_to_sr",
         app_msi_ack => "app_msi_ack",
         app_int_ack => "app_int_ack_icm",
         eval($cfg_ports),
         eval($vcs_connect_out),
         eval($open_signals),
      },
   });


# Generate Gen2 speed
if ($gen2_rate) {
   $glue_logic .= "e_assign->new({lhs => {name => gen2_speed , width => 1}, rhs => \"cfg_linkcsr_icm[17]\"}),";
}

##################################################
# Compute if application clock is 250Mhz
##################################################
my $app_clk_eq_250 = 0;

if (  (($gen2_rate == 1) & ($number_of_lanes == 8) & ($tl_selection != 9)) ||
      (($gen2_rate == 1) & ($number_of_lanes == 4) & ($tl_selection == 6)) ||
      (($gen2_rate == 0) & ($number_of_lanes == 8) & ($tl_selection == 6))) {
   $app_clk_eq_250 = 1;
}




##################################################
# Instantiate example application
##################################################
my $parameter_str = " ";
if ($rp == 0) {
   if ($simple_dma == 0) {
      if ($tl_selection==$TLSEL_AST256) {
         $parameter_str = "MAX_PAYLOAD_SIZE_BYTE => $max_pload, MAX_NUMTAG => $tags, AVALON_WADDR => 12, TL_SELECTION => 9, ECRC_FORWARD_CHECK => $crc_fwd, ECRC_FORWARD_GENER => $crc_fwd, CLK_250_APP => $app_clk_eq_250 ";
      } else {
         $parameter_str = "MAX_PAYLOAD_SIZE_BYTE => $max_pload, MAX_NUMTAG => $tags, TXCRED_WIDTH => $txcred_width, AVALON_WADDR => 12, TL_SELECTION => $tl_selection, ECRC_FORWARD_CHECK => $crc_fwd, ECRC_FORWARD_GENER => $crc_fwd, CHECK_RX_BUFFER_CPL => 1, CHECK_BUS_MASTER_ENA => 1, CLK_250_APP => $app_clk_eq_250 ";
      }
      # hookup extra ports for app
      if ($phy_selection==$PHYSEL_SV) {
         if ($tl_selection==$TLSEL_AST256) {
            $app_vcs_connect_in .= "tx_cred_datafccp   => tx_cred_datafccp  ,";
            $app_vcs_connect_in .= "tx_cred_datafcnp   => tx_cred_datafcnp  ,";
            $app_vcs_connect_in .= "tx_cred_datafcp    => tx_cred_datafcp   ,";
            $app_vcs_connect_in .= "tx_cred_fchipcons  => tx_cred_fchipcons ,";
            $app_vcs_connect_in .= "tx_cred_fcinfinite => tx_cred_fcinfinite,";
            $app_vcs_connect_in .= "tx_cred_hdrfccp    => tx_cred_hdrfccp   ,";
            $app_vcs_connect_in .= "tx_cred_hdrfcnp    => tx_cred_hdrfcnp   ,";
            $app_vcs_connect_in .= "tx_cred_hdrfcp     => tx_cred_hdrfcp    ,";
         } else {
            $glue_logic         .= "e_assign->new ([ tx_stream_cred0 => \"{tx_cred_datafccp[11:0], tx_cred_hdrfccp[2:0], tx_cred_datafcnp[2:0],tx_cred_hdrfcnp[2:0],tx_cred_datafcp[11:0],tx_cred_hdrfcp[2:0]}\"]),";
            $app_vcs_connect_in .= "tx_stream_cred0 => tx_stream_cred0,";
         }
      } else {
         $app_vcs_connect_in .= "tx_stream_cred0 => tx_stream_cred0,";
      }
      $app_vcs_connect_in .= "cfg_msicsr => cfg_msicsr,";
      $app_vcs_connect_in .= "cfg_prmcsr => cfg_prmcsr_icm,";
      $app_vcs_connect_in .= "app_int_ack => app_int_ack_icm,";
   } else {
      $parameter_str = "TL_SELECTION => $tl_selection";
   }
}


if ($rp == 0) {

   $add_signals .= "e_signal->new({name => app_rstn, width=> 1, never_export => 1}),";
   $label = "user_app";
   $label{$label} = 1;
   $$label = e_blind_instance->new({
         module => "$app_name",
         name => "app",
         parameter_map => {
            eval($parameter_str)
         },
         in_port_map => {
            clk_in => "$app_clk_in",
            rstn => "srstn",
            test_sim => "test_in[0]",

            cfg_busdev => "cfg_busdev_icm",
            cfg_devcsr => "cfg_devcsr_icm",
            cfg_linkcsr =>"cfg_linkcsr_icm",
            cfg_tcvcmap => "gnd_cfg_tcvcmap_icm",
            app_msi_ack => "app_msi_ack",
            eval($app_vcs_connect_in),

         },
         out_port_map => {
            pex_msi_num => "pex_msi_num_icm",
            app_int_sts => "app_int_sts_icm",
            pm_data => "open_pm_data",
            aer_msi_num => "open_aer_msi_num",
            app_msi_num => "app_msi_num",
            app_msi_req => "app_msi_req",
            app_msi_tc => "app_msi_tc",
            eval($app_vcs_connect_out),
         },

      });

} elsif ($tl_selection != $TLSEL_AST256) { # Root port with AST64 or AST128

   # drive misc ports
   $glue_logic .= "e_assign->new ([ app_int_sts_icm => \"0\"]),";
   $glue_logic .= "e_assign->new ([ app_msi_req => \"0\"]),";
   $glue_logic .= "e_assign->new ([ cpl_pending_icm => \"0\"]),";

   # open signals
   $add_signals .= "e_signal->new({name => app_msi_ack, width=> 1, never_export => 1}),";

   for ($i = 0; $i < $number_of_vcs; $i++) {
      $parameter_str = "VC_NUM => $i, ECRC_FORWARD_CHECK => $crc_fwd, ECRC_FORWARD_GENER => $crc_fwd";

      if ($tl_selection == $TLSEL_AST128) {
         $parameter_str .= ",AVALON_ST_128 => 1";
      } else {
         $parameter_str .= ",AVALON_ST_128 => 0";
         $add_signals .= "e_signal->new({name => rx_st_empty$i, width=> 1, never_export => 1}),";
         $glue_logic .= "e_assign->new ([ rx_st_empty$i => \"0\"]),";
         $add_signals .= "e_signal->new({name => tx_st_empty$i, width=> 1, never_export => 1}),";
      }

      # delay reset to solve UR issue
      $glue_logic .= "e_process->new({
comment => \"delay reset for RP\",
clock => \"$clkfreq_in\",
reset => \"srstn\",
tag => simulation,
asynchronous_contents => [
e_assign->new([\"srstn_r\" => '0']),
e_assign->new([\"srstn_rr\" => '0']),

],
contents => [
e_assign->new([\"srstn_r\" => '1']),
e_assign->new([\"srstn_rr\" => 'srstn_r']),
],
}),";

      # for simulation
      $app_name = "altpcietb_bfm_vc_intf_ast";
      my $rp_connect_in='';
      my $rp_connect_out='';

      if ($phy_selection == $PHYSEL_SV) {
         $add_signals    .= "e_signal->new({name   => tx_st_valid$i, width=> 1, never_export => 1}),";
         $add_signals    .= "e_signal->new({name   => tx_st_ready$i, width=> 1, never_export => 1}),";
         $rp_connect_out .= "tx_st_valid      => tx_st_valid$i,";
         $rp_connect_in  .= "tx_st_ready      => tx_st_ready$i,";
      } else {
         $rp_connect_out  .= "tx_st_valid     => tx_stream_valid$i,";
         $rp_connect_in   .= "tx_st_ready     => tx_stream_ready$i,";
      }

      $label = "intf_vc$i";
      $label{$label} = 1;
      $$label = e_blind_instance->new({
      module => "$app_name",
      name => "app_vc$i",
      parameter_map => {
      eval($parameter_str),
      },
      tag => simulation,
      in_port_map => {
      clk_in => "$app_clk_in",
      rstn => "srstn_rr",
      tx_cred => "36'hFFFFFFFFF",
      cfg_io_bas => "cfg_io_bas",
      cfg_np_bas => "cfg_np_bas",
      cfg_pr_bas => "cfg_pr_bas",
      rx_st_sop => "rx_st_sop$i",
      rx_st_eop => "rx_st_eop$i",
      rx_st_valid => "rx_stream_valid$i",
      rx_st_empty => "rx_st_empty$i",
      rx_st_data => "rx_st_data$i",
      rx_st_be => "rx_st_be$i",
      eval($rp_connect_in),
      tx_fifo_empty => "tx_fifo_empty$i",

      },
      out_port_map => {
      rx_mask => "rx_mask$i",
      rx_st_ready => "rx_stream_ready$i",
      tx_st_sop => " tx_st_sop$i",
      tx_st_eop => " tx_st_eop$i",
      tx_st_empty => "tx_st_empty$i",
      eval($rp_connect_out),
      tx_st_data => "tx_st_data$i",
      },

      });

      # for synthesis
      my $tx_stream = ($phy_selection==$PHYSEL_SV)?"tx_st_ready$i":"tx_stream_ready$i";
      my $tx_valid  = ($phy_selection==$PHYSEL_SV)?"tx_st_valid$i":"tx_stream_valid$i";
      $glue_logic .= "e_process->new({
            comment => \"loopback pipe\",
            clock => \"$app_clk_in\",
            tag => synthesis,
            reset => \"srstn\",
            asynchronous_contents => [
            e_assign->new([\"rx_stream_ready$i\_r\" => '0']),
            e_assign->new([\"tx_st_sop$i\_r\" => '0']),
            e_assign->new([\"tx_st_eop$i\_r\" => '0']),
            e_assign->new([\"tx_st_empty$i\_r\" => '0']),
            e_assign->new([\"tx_st_empty$i\_r\" => '0']),
            e_assign->new([\"tx_stream_valid$i\_r\" => '0']),
            e_assign->new([\"tx_st_data$i\_r\" => '0']),

            ],
            contents => [
            e_assign->new({lhs => {name => rx_stream_ready$i\_r}, rhs => $tx_stream}),
            e_assign->new({lhs => {name => tx_st_data$i\_r}, rhs => rx_st_data$i}),
            e_assign->new({lhs => {name => tx_st_empty$i\_r}, rhs => rx_st_empty$i}),
            e_assign->new({lhs => {name => tx_st_eop$i\_r}, rhs => rx_st_eop$i}),
            e_assign->new({lhs => {name => tx_st_sop$i\_r}, rhs => rx_st_sop$i}),
            e_assign->new({lhs => {name => tx_stream_valid$i\_r}, rhs => rx_stream_valid$i}),

            ],
            }),";

            $glue_logic .= "e_assign->new({lhs => {name => tx_st_sop$i}, rhs => tx_st_sop$i\_r, tag => synthesis}),";
            $glue_logic .= "e_assign->new({lhs => {name => tx_st_eop$i}, rhs => tx_st_eop$i\_r, tag => synthesis}),";
            $glue_logic .= "e_assign->new({lhs => {name => tx_st_empty$i}, rhs => tx_st_empty$i\_r, tag => synthesis}),";
            $glue_logic .= "e_assign->new({lhs => {name => tx_st_data$i}, rhs => tx_st_data$i\_r, tag => synthesis}),";
            $glue_logic .= "e_assign->new({lhs => {name => rx_stream_ready$i}, rhs => rx_stream_ready$i\_r, tag => synthesis}),";
            $glue_logic .= "e_assign->new({lhs => {name => $tx_valid}, rhs => tx_stream_valid$i\_r, tag => synthesis}),";
   }
} else { # root port with AST256

   # drive misc ports
   $glue_logic .= "e_assign->new ([ app_int_sts_icm => \"0\"]),";
   $glue_logic .= "e_assign->new ([ app_msi_req => \"0\"]),";
   $glue_logic .= "e_assign->new ([ cpl_pending_icm => \"0\"]),";

   # open signals
   $add_signals .= "e_signal->new({name => app_msi_ack, width=> 1, never_export => 1}),";

   for ($i = 0; $i < $number_of_vcs; $i++) {

      $glue_logic .= "e_process->new({
              comment => \"loopback pipe\",
              clock => \"$app_clk_in\",
              reset => \"srstn\",
              asynchronous_contents => [
              e_assign->new([\"rx_stream_ready$i\_r\" => '0']),
              e_assign->new([\"tx_st_sop$i\_r\" => '0']),
              e_assign->new([\"tx_st_eop$i\_r\" => '0']),
              e_assign->new([\"tx_st_empty$i\_r\" => '0']),
              e_assign->new([\"tx_st_empty$i\_r\" => '0']),
              e_assign->new([\"tx_stream_valid$i\_r\" => '0']),
              e_assign->new([\"tx_st_data$i\_r\" => '0']),

              ],
              contents => [
              e_assign->new({lhs => {name => rx_stream_ready$i\_r}, rhs => tx_st_ready$i}),
              e_assign->new({lhs => {name => tx_st_data$i\_r}, rhs => rx_st_data$i}),
              e_assign->new({lhs => {name => tx_st_empty$i\_r}, rhs => rx_st_empty$i}),
              e_assign->new({lhs => {name => tx_st_eop$i\_r}, rhs => rx_st_eop$i}),
              e_assign->new({lhs => {name => tx_st_sop$i\_r}, rhs => rx_st_sop$i}),
              e_assign->new({lhs => {name => tx_stream_valid$i\_r}, rhs => rx_stream_valid$i}),

              ],
              }),";
      $glue_logic .= "e_assign->new({lhs => {name => tx_st_valid$i}, rhs => tx_stream_valid$i\_r}),";
      $glue_logic .= "e_assign->new({lhs => {name => tx_st_sop$i}, rhs => tx_st_sop$i\_r}),";
      $glue_logic .= "e_assign->new({lhs => {name => tx_st_eop$i}, rhs => tx_st_eop$i\_r}),";
      $glue_logic .= "e_assign->new({lhs => {name => tx_st_empty$i}, rhs => tx_st_empty$i\_r}),";
      $glue_logic .= "e_assign->new({lhs => {name => tx_st_data$i}, rhs => tx_st_data$i\_r}),";
      $glue_logic .= "e_assign->new({lhs => {name => rx_stream_ready$i}, rhs => rx_stream_ready$i\_r}),";
   }
}


$top_example_pipen1b->add_contents
   (
   my $refclk           = e_port->new([ refclk => 1 => "input"]),
   my $local_rstn       = e_port->new([ local_rstn => 1 => "input"]),
   my $pcie_rstn        = e_port->new([ pcie_rstn => 1 => "input"]),

   eval($clk_ports),

   my $free_100MHz      = e_port->new([ free_100MHz => 1 => "input"]),
   my $phy_sel_code     = e_port->new([phy_sel_code => 4 => "output"]),
   my $ref_clk_sel_code = e_port->new([ref_clk_sel_code => 4 => "output"]),
   my $lane_width_code  = e_port->new([lane_width_code => 4 => "output"]),

   #--serdes interfaces
   eval($serdes_interface),

   #--pipe interface
   eval($pipe_interface),

   e_port->new([test_in => $test_in_width => "input"]),
   e_port->new([test_out_icm => 9 => "output"]),

   e_assign->new([ref_clk_sel_code => "$refclk_selection"]),
   e_assign->new([lane_width_code => "$lane_width"]),
   e_assign->new([phy_sel_code => "$phy_selection"]),

   eval($add_signals),
   eval($glue_logic),
   eval($vcs_signals),
   eval($app_vcs_signals),

   $var_inst_ez,

   );


foreach $key (sort keys %label) {
   $top_example_pipen1b->add_contents($$key);
}

$top_example_pipen1b->vhdl_libraries()->{altera_mf} = "all";
$proj->top($top_example_pipen1b);
$proj->language($language);
$proj->output();


#################################################################################################################################################
# pcie ez variant code ; the section of code bellow generates <variant>_plus.v|vhd
# instantiate <variant>.v|vhd
# incorporate reset circuit ($reset_logic_ez)
# variables uses the suffix _ez
#
#################################################################################################################################################

my $proj_ez       = e_project->new();
my $top_ez_mod    = e_module->new ({name => "$module_ez", comment => "/** PCIe wrapper + \n*/"});
$top_ez_mod->vhdl_libraries()->{altera_mf} = "all";
my $label_ez = " ";
my %label_ez;
my $add_signals_ez = " ";
my $add_assign_ez = " ";
my $vcs_connect_in_ez = " ";
my $vcs_connect_out_ez = " ";
my $vcs_open_ez = " ";
my $vcs_signals_ez = " ";
my $eport_misc_ez=' ';
my $eport_msg_ez=' ';
my $eport_avs_hip_reconfig_ez=' ';
my $avs_pcie_reconfig_in_ez=' ';
my $avs_pcie_reconfig_out_ez=' ';
my $eport_ast_ez='';
my $serdes_in_ez=' ';
my $serdes_out_ez=' ';
my $alt2gxb_in_ez = " ";
my $alt2gxb_out_ez = " ";

$serdes_in_ez .= "pipe_mode => pipe_mode,";
for ($i = 0; $i < $number_of_lanes; $i++) {
   $serdes_out_ez .= "tx_out$i => tx_out$i,";
   $serdes_in_ez .= "rx_in$i => rx_in$i,";
}

$add_signals_ez .= "e_signal->new({name => otb0, width=> 1, never_export => 1}),";
$add_signals_ez .= "e_signal->new({name => otb1, width=> 1, never_export => 1}),";
$add_assign_ez  .= "e_assign->new ([ otb0=> \"1'b0\"]),";
$add_assign_ez  .= "e_assign->new ([ otb1=> \"1'b1\"]),";

# reconfig block
$add_signals_ez .= "e_signal->new({name => busy_altgxb_reconfig,width=> 1, never_export => 1}),";

if (($phy_selection == $PHYSEL_SIV) & ($multi_core eq "0")) {
   $add_signals_ez .= "e_signal->new({name => data_valid,       width=> 1, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => rx_eqctrl_out,    width=> 4, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => rx_eqdcgain_out,  width=> 3, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => tx_preemp_0t_out, width=> 5, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => tx_preemp_1t_out, width=> 5, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => tx_preemp_2t_out, width=> 5, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => tx_vodctrl_out,   width=> 3, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => offset_cancellation_reset,   width=> 1, never_export => 1}),";
   $add_assign_ez  .= "e_assign->new ([ offset_cancellation_reset => \"~reconfig_clk_locked\"]),";

   $add_signals_ez .= "e_signal->new({name => reconfig_clk, width=> 1}),";
   $add_signals_ez .= "e_signal->new({name => reconfig_togxb, width=> 4, never_export => 1}),";
   $add_signals_ez .= "e_signal->new({name => reconfig_fromgxb, width=> 34, never_export => 1}),";

   if ($number_of_lanes < 8) {
      if ($c3gx == 0) {
         $add_assign_ez .= "e_assign->new ([ \"reconfig_fromgxb[33:17]\" => \"0\"]),";
      } else {
         $add_assign_ez .= "e_assign->new ([ \"reconfig_fromgxb[33:5]\" => \"0\"]),";
      }
   }

   if ($c3gx == 0) {
      $label_ez = "reconfig";
      $label_ez{$label_ez} = 1;
      $$label_ez = e_blind_instance->new({
      module => "altpcie_reconfig_4sgx",
      name => "reconfig",
      in_port_map => {
      logical_channel_address => "3'b000",
      read => "1'b0",
      reconfig_clk                  => "reconfig_clk",
      offset_cancellation_reset     => "offset_cancellation_reset",
      reconfig_fromgxb              => "reconfig_fromgxb",
      rx_eqctrl                     => "4'b0000",
      rx_eqdcgain                   => "3'b000",
      tx_preemp_0t                  => "5'b00000",
      tx_preemp_1t                  => "5'b00000",
      tx_preemp_2t                  => "5'b00000",
      tx_vodctrl                    => "3'b000",
      write_all                     => "1'b0",
      },
      out_port_map => {
      busy                          => "busy_altgxb_reconfig",
      data_valid                    => "data_valid",
      rx_eqctrl_out                 => "rx_eqctrl_out",
      rx_eqdcgain_out               => "rx_eqdcgain_out",
      tx_preemp_0t_out              => "tx_preemp_0t_out",
      tx_preemp_1t_out              => "tx_preemp_1t_out",
      tx_preemp_2t_out              => "tx_preemp_2t_out",
      tx_vodctrl_out                => "tx_vodctrl_out",
      reconfig_togxb                => "reconfig_togxb",
      },
      });
   }  else {
      $label_ez = "reconfig";
      $label_ez{$label_ez} = 1;
      $$label_ez = e_blind_instance->new({
      module => "altpcie_reconfig_3cgx",
      name => "reconfig",
      in_port_map => {
      offset_cancellation_reset     => "offset_cancellation_reset",
      reconfig_clk                  => "reconfig_clk",
      reconfig_fromgxb              => "reconfig_fromgxb[4:0]",
      },
      out_port_map                  => {
      busy                          => "busy_altgxb_reconfig",
      reconfig_togxb                => "reconfig_togxb",
      },
      });
   }
} else {
   $reset_logic_ez .= "e_assign->new ([ busy_altgxb_reconfig=> \"otb0\"]),";
}


# add misc signals
#$eport_misc_ez .= 'e_port->new([app_clk => 1 => output]),';
$eport_misc_ez .= 'e_port->new([srstn => 1 => output]),';
$eport_misc_ez .= 'e_port->new([rc_pll_locked => 1 => output]),';

# multi-bit bus
my $open_signals = " ";

##################################################
# Core VC interface
##################################################


# HIP DPRIO
if ($enable_hip_dprio == 1) {

   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_address       , width=> => 8  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_writedata     , width=> => 16 }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_chipselect    , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_write         , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_read          , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_clk           , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_rstn          , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_waitrequest   , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_readdatavalid , width=> => 1  }),";
   $eport_avs_hip_reconfig_ez .= "e_signal->new({name=>avs_pcie_reconfig_readdata      , width=> => 16 }),";

   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_address     => " . '"avs_pcie_reconfig_address"    ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_chipselect  => " . '"avs_pcie_reconfig_chipselect" ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_write       => " . '"avs_pcie_reconfig_write"      ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_writedata   => " . '"avs_pcie_reconfig_writedata"  ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_read        => " . '"avs_pcie_reconfig_read"       ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_clk         => " . '"avs_pcie_reconfig_clk"        ,';
   $avs_pcie_reconfig_in_ez.= "avs_pcie_reconfig_rstn        => " . '"avs_pcie_reconfig_rstn"       ,';

   $avs_pcie_reconfig_out_ez.= "avs_pcie_reconfig_waitrequest => avs_pcie_reconfig_waitrequest,";
   $avs_pcie_reconfig_out_ez.= "avs_pcie_reconfig_readdata => avs_pcie_reconfig_readdata,";
   $avs_pcie_reconfig_out_ez.= "avs_pcie_reconfig_readdatavalid => avs_pcie_reconfig_readdatavalid,";

}


if (($tl_selection == $TLSEL_AST256) | ($tl_selection == $TLSEL_AST128) | ($tl_selection == $TLSEL_AST64))  { # HIPCAB

      my $be_width = 8;
      my $data_width = 8;

      if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
         $data_width = 128;
         $be_width = 16;
      } elsif ($tl_selection == $TLSEL_AST256) { # 256 bit mode unbonded
         $data_width = 256;
         $be_width = 32;
      } else {
         $data_width = 64;
         $be_width = 8;
      }


      if ($rp == 2) { # endpoint / root port mode
         $vcs_connect_in_ez .= "mode => \"2'b10\",";
      }

      if ( $hip == 1 ) {
         $eport_misc_ez   .= "e_port->new([ tl_cfg_add => 4  => output]),";
         $eport_misc_ez   .= "e_port->new([ tl_cfg_ctl => 32 => output]),";
         $eport_misc_ez   .= "e_port->new([ tl_cfg_sts => 53 => output]),";
         $eport_misc_ez   .= "e_port->new([ tl_cfg_sts_wr => 1 => output]),";
         $eport_misc_ez   .= "e_port->new([ tl_cfg_ctl_wr => 1 => output]),";
         $cfg_ports_ez .= "tl_cfg_add    => tl_cfg_add,\n";
         $cfg_ports_ez .= "tl_cfg_ctl    => tl_cfg_ctl,\n";
         $cfg_ports_ez .= "tl_cfg_sts    => tl_cfg_sts,\n";

         if ($phy_selection < 7) { # S4GX, A2GX, C4GX
            $cfg_ports_ez .= " tl_cfg_sts_wr => tl_cfg_sts_wr,\n";
            $cfg_ports_ez .= " tl_cfg_ctl_wr => tl_cfg_ctl_wr,\n";
         } else {
            $add_assign_ez .= "e_assign->new({lhs => {name => tl_cfg_sts_wr , width => 1}, rhs => \"1'b0\"}),";
            $add_assign_ez .= "e_assign->new({lhs => {name => tl_cfg_ctl_wr , width => 1}, rhs => \"1'b0\"}),";
         }
      }

      for ($i = 0; $i < $number_of_vcs; $i++) {
         if (($i == 0) | ($rp > 0)) {
            $eport_misc_ez .= "e_port->new([tx_fifo_empty$i => 1 =>   output ]),";
            if ($phy_selection == 7) {
               if ($rp>0) {
                  $add_assign_ez     .= "e_assign->new({lhs => {name => tx_fifo_empty$i}, rhs => \"1'b1\"}),";
               } else {
                  $add_assign_ez     .= "e_assign->new({lhs => {name => tx_fifo_empty$i}, rhs => \"1'b0\"}),";
               }
            } else {
               $vcs_connect_out_ez .= "tx_fifo_empty$i => tx_fifo_empty$i,";
            }

            $eport_ast_ez .= "e_port->new([rx_st_ready$i => 1 =>   input ]),";
            $vcs_connect_in_ez  .= "rx_st_ready$i => rx_st_ready$i,";

            $eport_ast_ez .= "e_port->new([rx_st_valid$i => 1 => output]),";
            $vcs_connect_out_ez .= "rx_st_valid$i => rx_st_valid$i,";

            if ($tl_selection == $TLSEL_AST128) {
               $eport_ast_ez .= "e_port->new([ rx_st_data$i   => 128=> output ]),";
               $eport_ast_ez .= "e_port->new([ tx_st_data$i   => 128=> input ]),";
               $eport_ast_ez .= "e_port->new([ rx_st_be$i     => 16 => output ]),";
               if ($phy_selection==$PHYSEL_SV) {
                  $eport_ast_ez .= "e_port->new([ tx_st_parity$i   => 16=> input ]),";
               }
            } elsif ($tl_selection == $TLSEL_AST256) { # 256 bit unbonded
               $eport_ast_ez .= "e_port->new([ rx_st_data$i   => 256=> output ]),";
               $eport_ast_ez .= "e_port->new([ tx_st_data$i   => 256=> input ]),";
               $eport_ast_ez .= "e_port->new([ rx_st_be$i     => 32 => output ]),";
               if ($phy_selection==$PHYSEL_SV) {
                  $eport_ast_ez .= "e_port->new([ tx_st_parity$i   => 32=> input ]),";
               }
            } else {
               $eport_ast_ez .= "e_port->new([ rx_st_data$i   => 64 => output ]),";
               $eport_ast_ez .= "e_port->new([ tx_st_data$i   => 64 => input  ]),";
               $eport_ast_ez .= "e_port->new([ rx_st_be$i     => 8  => output ]),";
               if ($phy_selection==$PHYSEL_SV) {
                  $eport_ast_ez .= "e_port->new([ tx_st_parity$i   => 8=> input ]),";
               }
            }

            if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
               $vcs_connect_out_ez .= "rx_st_empty$i => rx_st_empty$i,";
               $vcs_connect_in_ez  .= "tx_st_empty$i => tx_st_empty$i,";
               $vcs_connect_out_ez .= "rx_st_data$i  => rx_st_data$i,";
               $vcs_connect_out_ez .= "rx_st_be$i    => rx_st_be$i,";
               $vcs_connect_in_ez  .= "tx_st_data$i  => tx_st_data$i,";
               if ($phy_selection==$PHYSEL_SV) {
                  $vcs_connect_in_ez  .= "tx_st_parity$i  => \"tx_st_parity$i\[15:0]\",";
               }
            } elsif ($tl_selection == $TLSEL_AST256) { # 256 bit unbonded
               $eport_ast_ez          .= "e_port->new([ rx_st_empty$i => 2 => output]),";
               $vcs_connect_out_ez .= "rx_st_empty$i => rx_st_empty$i,";
               $eport_ast_ez          .= "e_port->new([tx_st_empty$i => 2 => input]),";
               $vcs_connect_in_ez  .= "tx_st_empty$i => tx_st_empty$i,";
               $vcs_connect_out_ez .= "rx_st_data$i  => rx_st_data$i,";
               $vcs_connect_out_ez .= "rx_st_be$i    => rx_st_be$i,";
               $vcs_connect_in_ez  .= "tx_st_data$i  => tx_st_data$i,";
               if ($phy_selection==$PHYSEL_SV) {
                  $vcs_connect_in_ez  .= "tx_st_parity$i  => \"tx_st_parity$i\[31:0]\",";
               }
            } else {
               $vcs_connect_out_ez .= "rx_st_data$i => \"rx_st_data$i\[63:0]\",";
               $vcs_connect_out_ez .= "rx_st_be$i   => \"rx_st_be$i\[7:0]\",";
               $vcs_connect_in_ez  .= "tx_st_data$i => \"tx_st_data$i\[63:0]\",";
               if ($phy_selection==$PHYSEL_SV) {
                  $vcs_connect_in_ez  .= "tx_st_parity$i  => \"tx_st_parity$i\[7:0]\",";
               }
            }

            $eport_ast_ez           .= "e_port->new([rx_st_mask$i => 1 => input]),";
            $vcs_connect_in_ez  .= "rx_st_mask$i => rx_st_mask$i,";

            $eport_ast_ez            .= "e_port->new([rx_st_bardec$i => 8  => output]),";
            $vcs_connect_out_ez .= "rx_st_bardec$i => rx_st_bardec$i,";

            $eport_ast_ez            .= "e_port->new([ rx_st_sop$i =>  1 => output]),";
            $vcs_connect_out_ez .= "rx_st_sop$i   => rx_st_sop$i,";

            $eport_ast_ez            .= "e_port->new([ rx_st_eop$i =>  1 => output]),";
            $vcs_connect_out_ez .= "rx_st_eop$i   => rx_st_eop$i,";

            $eport_ast_ez            .= "e_port->new([ tx_st_sop$i =>  1 => input]),";
            $vcs_connect_in_ez  .= "tx_st_sop$i   => tx_st_sop$i,";

            $eport_ast_ez            .= "e_port->new([ tx_st_eop$i =>  1 => input]),";
            $vcs_connect_in_ez  .= "tx_st_eop$i   => tx_st_eop$i,";

            $eport_ast_ez            .= "e_port->new([ tx_st_err$i =>  1 => input]),";
            $vcs_connect_in_ez  .= "tx_st_err$i   => tx_st_err$i,";

            $eport_ast_ez            .= "e_port->new([tx_st_valid$i => 1 => input]),";
            $vcs_connect_in_ez  .= "tx_st_valid$i => tx_st_valid$i,";

            $eport_ast_ez            .= "e_port->new([tx_st_ready$i => 1 => output]),";
            $vcs_connect_out_ez .= "tx_st_ready$i => tx_st_ready$i,";

            if ($phy_selection == $PHYSEL_SV) {
               $eport_ast_ez .= "e_port->new([ tx_cred_datafccp   => 12 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_datafcnp   => 12 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_datafcp    => 12 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_fchipcons  =>  6 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_fcinfinite =>  6 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_hdrfccp    =>  8 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_hdrfcnp    =>  8 => output]),";
               $eport_ast_ez .= "e_port->new([ tx_cred_hdrfcp     =>  8 => output]),";

               $vcs_connect_out_ez .= "tx_cred_datafccp   => tx_cred_datafccp  ,";
               $vcs_connect_out_ez .= "tx_cred_datafcnp   => tx_cred_datafcnp  ,";
               $vcs_connect_out_ez .= "tx_cred_datafcp    => tx_cred_datafcp   ,";
               $vcs_connect_out_ez .= "tx_cred_fchipcons  => tx_cred_fchipcons ,";
               $vcs_connect_out_ez .= "tx_cred_fcinfinite => tx_cred_fcinfinite,";
               $vcs_connect_out_ez .= "tx_cred_hdrfccp    => tx_cred_hdrfccp   ,";
               $vcs_connect_out_ez .= "tx_cred_hdrfcnp    => tx_cred_hdrfcnp   ,";
               $vcs_connect_out_ez .= "tx_cred_hdrfcp     => tx_cred_hdrfcp    ,";
            } else  {
               $eport_ast_ez          .= "e_port->new([tx_cred$i => $txcred_width => output ]),";
               $vcs_connect_out_ez .= "tx_cred$i => tx_cred$i,";
            }
         } else {
            $eport_ast_ez .= "e_port->new([rx_st_ready$i => 1 =>   input ]),";
            $vcs_connect_in_ez .= "rx_st_ready$i => rx_st_ready$i,";

            $eport_ast_ez .= "e_port->new([rx_st_valid$i => 1 => output]),";
            $vcs_connect_out_ez .= "rx_st_valid$i => rx_st_valid$i,";

            if ($tl_selection == $TLSEL_AST128) { # 128 bit mode
               $eport_ast_ez .= "e_port->new([ rx_st_data$i => 128 => output]),";
               $eport_ast_ez .= "e_port->new([ rx_st_be$i   => 16  => output]),";
               $vcs_connect_in_ez .= "tx_st_empty$i => tx_st_empty$i,";
            } else {
               $eport_ast_ez .= "e_port->new([rx_st_data$i => 64 => output ]),";
               $eport_ast_ez .= "e_port->new([rx_st_be$i   => 8  => output ]),";
            }
            $vcs_connect_out_ez .= "rx_st_data$i => rx_st_data$i,";
            $vcs_connect_out_ez .= "rx_st_be$i   => rx_st_be$i,";

            $eport_ast_ez           .= "e_port->new([rx_st_mask$i => 1 => input]),";
            $vcs_connect_in_ez .= "rx_st_mask$i => rx_st_mask$i,";

            $eport_ast_ez            .= "e_port->new([rx_st_bardec$i => 8 => output]),";
            $vcs_connect_out_ez .= "rx_st_bardec$i => rx_st_bardec$i,";

            $eport_ast_ez            .= "e_port->new([rx_st_sop$i => 1 => output]),";
            $vcs_connect_out_ez .= "rx_st_sop$i => rx_st_sop$i,";

            $eport_ast_ez            .= "e_port->new([rx_st_eop$i => 1 => output]),";
            $vcs_connect_out_ez .= "rx_st_eop$i => rx_st_eop$i,";

            $eport_ast_ez           .= "e_port->new([tx_st_sop$i => 1 => input]),";
            $vcs_connect_in_ez .= "tx_st_sop$i => tx_st_sop$i,";

            $eport_ast_ez           .= "e_port->new([tx_st_eop$i =>1 => input]),";
            $vcs_connect_in_ez .= "tx_st_eop$i => tx_st_eop$i,";

            $eport_ast_ez           .= "e_port->new([tx_st_err$i => 1 => input]),";
            $vcs_connect_in_ez .= "tx_st_err$i => tx_st_err$i,";

            $eport_ast_ez           .= "e_port->new([tx_st_valid$i  => 1 => input ]),";
            $vcs_connect_in_ez .= "tx_st_valid$i => tx_st_valid$i,";

            $eport_ast_ez           .= "e_port->new([tx_st_data$i  => $data_width => input ]),";
            $vcs_connect_in_ez .= "tx_st_data$i => tx_st_data$i,";

            $eport_ast_ez            .= "e_port->new([tx_st_ready$i  => 1 => output ]),";
            $vcs_connect_out_ez .= "tx_st_ready$i => tx_st_ready$i,";

            $eport_ast_ez            .= "e_port->new([tx_cred$i => $txcred_width => output ]),";


            if ($phy_selection == $PHYSEL_SV) { # 128 bit mode
               #TODO Add support for txcredit for S5GX
            } else {
               $vcs_connect_out_ez .= "tx_cred$i => tx_cred$i,";
            }
         }


         # App credit management
         if ($phy_selection == $PHYSEL_SV) {

         } else {
            $add_signals_ez .= "e_signal->new({name => open_tx_fifo_wrptr$i ,  width => 4 , never_export => 1}),";
            $vcs_connect_out_ez .= "tx_fifo_wrptr$i => open_tx_fifo_wrptr$i,";
            $add_signals_ez .= "e_signal->new({name => open_tx_fifo_rdptr$i ,  width => 4 , never_export => 1}),";
            $vcs_connect_out_ez .= "tx_fifo_rdptr$i => open_tx_fifo_rdptr$i,";
            $add_signals_ez .= "e_signal->new({name => open_rx_fifo_full$i ,  never_export => 1}),";
            $vcs_connect_out_ez .= "rx_fifo_full$i => open_rx_fifo_full$i,";

            $add_signals_ez .= "e_signal->new({name => open_rx_fifo_empty$i ,  never_export => 1}),";
            $vcs_connect_out_ez .= "rx_fifo_empty$i => open_rx_fifo_empty$i,";

            $add_signals_ez .= "e_signal->new({name => open_tx_fifo_full$i ,  never_export => 1}),";
            $vcs_connect_out_ez .= "tx_fifo_full$i => open_tx_fifo_full$i,";
         }

         $eport_ast_ez            .= "e_port->new([rx_st_err$i => 1 => output]),";
         $vcs_connect_out_ez .= "rx_st_err$i => rx_st_err$i,";

         if (($i == 0) & ($number_of_lanes < 8) & ($hip == 0)) {
            $eport_misc_ez          .= "e_port->new([err_desc_func0  => 128 => input]),";
            $vcs_connect_in_ez .= "err_desc_func0 => err_desc_func0,";
         }

         if ($hip == 1) {

            if ($simple_dma == 1) {
               if ($i == 0) {
                  $vcs_connect_in_ez  .= "lmi_addr => lmi_addr,";
                  $vcs_connect_in_ez  .= "lmi_din  => lmi_din,";
                  $vcs_connect_in_ez  .= "lmi_rden => lmi_rden,";
                  $vcs_connect_in_ez  .= "lmi_wren => lmi_wren,";
                  $vcs_connect_out_ez .= "lmi_dout => lmi_dout,";
                  $vcs_connect_out_ez .= "lmi_ack  => lmi_ack,";
               }
            } else { # instantiate LMI module

               $eport_misc_ez .= "e_port->new([lmi_addr => 12  => input ]),";
               $eport_misc_ez .= "e_port->new([lmi_din  => 32  => input ]),";
               $eport_misc_ez .= "e_port->new([lmi_dout => 32  => output]),";
               $eport_misc_ez .= "e_port->new([lmi_rden => 1   => input ]),";
               $eport_misc_ez .= "e_port->new([lmi_wren => 1   => input ]),";
               $eport_misc_ez .= "e_port->new([lmi_ack  => 1   => output]),";

               $vcs_connect_in_ez .= "lmi_addr => lmi_addr,";

               # lmi address bus for the driver
               $vcs_connect_in_ez  .= "lmi_din  => lmi_din,";
               $vcs_connect_in_ez  .= "lmi_rden => lmi_rden,";
               $vcs_connect_in_ez  .= "lmi_wren => lmi_wren,";
               $vcs_connect_out_ez .= "lmi_dout => lmi_dout,";
               $vcs_connect_out_ez .= "lmi_ack  => lmi_ack,";
            }
            # tied off misc ports
            if (($rp > 0) & ($i == 0)) { # root port
               $eport_msg_ez .= "e_port->new([ aer_msi_num => 5 => input] ),";
               $vcs_connect_in_ez .= "aer_msi_num => aer_msi_num,";
            }
            $add_signals_ez    .= "e_signal->new({name => gnd_hpg_ctrler, width => 5 ,never_export => 1}),";
            $vcs_connect_in_ez .= "hpg_ctrler => gnd_hpg_ctrler,";
            if ($i == 0) {
               $add_assign_ez     .= "e_assign->new({lhs => {name => gnd_hpg_ctrler}, rhs => \"0\"}),";
            }
            $vcs_connect_in_ez .= "pm_auxpwr => pm_auxpwr,";
            $eport_misc_ez        .= "e_port->new([pm_data  => 10            => input ]),";
            $vcs_connect_in_ez .= "pm_data => pm_data,";
            if ($rp == 0) { # root port
               $vcs_connect_in_ez .= "pm_event => pm_event,";
            }
            # HIP debug port
            $eport_misc_ez .= "e_port->new([ltssm  => 5             => output]),";
            $vcs_connect_out_ez .= "ltssm => ltssm,";
            $eport_misc_ez .= "e_port->new([lane_act  => 4             => output]),";
            $vcs_connect_out_ez .= "lane_act => lane_act,";
         }
      }
   }

# instantiate test out port
if (($test_out_width > 0) & (($tl_selection == $TLSEL_AST128) | ($tl_selection == $TLSEL_AST64))) {
   $eport_misc_ez          .= "e_port->new([test_out  => $test_out_width => output]),";
   $vcs_connect_out_ez .= "test_out => \"test_out\",";
}

# test_in width
if (($hip == 1) & ($phy_selection == 6)) { # S4GX, A2GX, C4GX
   $test_in_width = 40;
} else {
   $test_in_width = 32;
}
$eport_misc_ez          .="e_port->new([test_in => $test_in_width => input]),";



# file generated by e_var_wrapper_pipen1b.pl
my $var_inst;

# reset IO
my $var_rst_port_in  = '';
my $var_rst_port_out = '';

if ($phy_selection==$PHYSEL_SV) {
   $var_rst_port_in  .= "perst_n            => \"perst_n\",";
   $var_rst_port_in  .= "pld_clrhip_n       => \"pld_clrhip_n\",";
   $var_rst_port_in  .= "pld_clrpmapcship   => \"pld_clrpmapcship\",";
   $var_rst_port_in  .= "pld_clk_ready      => \"pld_clk_ready\",";
   $var_rst_port_out .= "pld_clk_in_use     => \"pld_clk_in_use\",";
   $var_rst_port_out .= "reset_status       => \"reset_status\",";
} else {
   if ($rp == 0) {
      $npor = "npor";
   } else {
      $npor = "pcie_rstn";
   }
   $var_rst_port_in  .= "crst              => \"crst\",";
   $var_rst_port_in  .= "srst              => \"srst\",";
   $var_rst_port_in  .= "npor              => \"$npor\",";
   $var_rst_port_out .= "hotrst_exit       => \"hotrst_exit\",";
}


if ($phy_selection == $PHYSEL_SIV) {
   $alt2gxb_in_ez .= "cal_blk_clk => reconfig_clk,";
   $alt2gxb_in_ez .= "reconfig_clk => reconfig_clk,";
   $alt2gxb_in_ez .= "reconfig_togxb => reconfig_togxb,";
   $alt2gxb_in_ez .= "pll_powerdown => pll_powerdown,";
   if ($number_of_lanes < 8) {
      if ($c3gx == 0) {
         $alt2gxb_out_ez .= "reconfig_fromgxb => \"reconfig_fromgxb[16:0]\",";
      } else {
         $alt2gxb_out_ez .= "reconfig_fromgxb => \"reconfig_fromgxb[4:0]\",";
      }
   } else {
      $alt2gxb_out_ez .= "reconfig_fromgxb => reconfig_fromgxb,";
   }
}

my $var_inst_name = ($rp == 0)? "epmap":"rpmap";
$add_signals_ez .= ($phy_selection==$PHYSEL_SV)?"e_signal->new({name=>rate_ext , width=> 2 }),":'';

my $busy_altgxb_reconfig_map_ez   = '';
my $fixedclk_serdes_map_ez        = '';
my $gxb_powerdown                 = '';
if  ($phy_selection==$PHYSEL_HIP_40nm) {
   $add_signals_ez .= "e_signal->new({name => busy_altgxb_reconfig_altr ,  never_export => 1}),";
   $add_assign_ez  .= "e_assign->new({lhs => {name => busy_altgxb_reconfig_altr}, rhs => \"(pipe_mode==otb1)?otb0:busy_altgxb_reconfig\"}),";
   $busy_altgxb_reconfig_map_ez   = 'busy_altgxb_reconfig=>"busy_altgxb_reconfig_altr",';
   $fixedclk_serdes_map_ez        = 'fixedclk_serdes=>"fixedclk_serdes",';
   $gxb_powerdown                 = 'gxb_powerdown=>"gxb_powerdown",';
   $add_signals_ez               .= "e_signal->new({name => gxb_powerdown, width=> 1, never_export => 1}),";
   $add_assign_ez                .= "e_assign->new ([ gxb_powerdown  => \"~npor\"]),";
}


$var_inst = e_blind_instance->new({
      module => "$var",
      name => "$var_inst_name",
      in_port_map => {
         refclk => "refclk",
         eval($var_rst_port_in),
         eval($dual_phy_in),
         eval($alt2gxb_in_ez),
         eval($avs_pcie_reconfig_in_ez),
         eval($clk_in),
         eval($busy_altgxb_reconfig_map_ez),
         eval($fixedclk_serdes_map_ez),
         eval($gxb_powerdown),
         eval($serdes_in_ez),
         eval($pipe_connect_in),
         test_in => "test_in",
         cpl_pending  => "cpl_pending",
         cpl_err      => "cpl_err",
         pme_to_cr    => "pme_to_cr",
         app_int_sts  => "app_int_sts",
         app_msi_req  => "app_msi_req",
         app_msi_tc   => "app_msi_tc",
         app_msi_num  => "app_msi_num",
         pex_msi_num  => "pex_msi_num",
         eval($vcs_connect_in_ez),
      },
      out_port_map => {
         eval($clk_out),
         eval($dual_phy_out),
         eval($alt2gxb_out_ez),
         eval($serdes_out_ez),
         eval($avs_pcie_reconfig_out_ez),
         eval($pipe_connect_out),
         eval($var_rst_port_out),
         eval($app_clk_out),
         eval
         l2_exit       => "l2_exit",
         dlup_exit     => "dlup_exit",
         pme_to_sr     => "pme_to_sr",
         app_msi_ack   => "app_msi_ack",
         app_int_ack   => "app_int_ack",
         eval($cfg_ports_ez),
         eval($vcs_connect_out_ez),
      },
});

my $top_rst_port_in_ez='';
my $top_rst_port_out_ez='';

if ($phy_selection==$PHYSEL_SV) {
   $top_rst_port_in_ez  .='e_port->new([ perst_n         => 1 => "input"]),';
   $top_rst_port_in_ez  .='e_port->new([ local_rstn      => 1 => "input"]),';
   $top_rst_port_in_ez  .='e_port->new([ pld_clk_ready   => 1 => "input"]),';
   $top_rst_port_out_ez .='e_port->new([ pld_clk_in_use  => 1 => "output"]),';
   $top_rst_port_out_ez .='e_port->new([ reset_status    => 1 => "output"]),';
} else {
   $top_rst_port_in_ez .='e_port->new([ local_rstn => 1 => "input"]),';
   $top_rst_port_in_ez .='e_port->new([ pcie_rstn  => 1 => "input"]),';
}



if (($tl_selection == $TLSEL_AST256) | ($tl_selection == $TLSEL_AST128) | ($tl_selection == $TLSEL_AST64))  { # HIPCAB
   $eport_msg_ez .= "e_port->new([ cpl_pending => 1 => input] ),";
   $eport_msg_ez .= "e_port->new([ cpl_err     => 7 => input] ),";
   $eport_msg_ez .= "e_port->new([ pme_to_cr   => 1 => input] ),";
   $eport_msg_ez .= "e_port->new([ app_int_sts => 1 => input] ),";
   $eport_msg_ez .= "e_port->new([ app_msi_req => 1 => input] ),";
   $eport_msg_ez .= "e_port->new([ app_msi_tc  => 3 => input] ),";
   $eport_msg_ez .= "e_port->new([ app_msi_num => 5 => input] ),";
   $eport_msg_ez .= "e_port->new([ pex_msi_num => 5 => input] ),";
   $eport_msg_ez .= "e_port->new([ pme_to_sr   => 1 => output] ),";
   $eport_msg_ez .= "e_port->new([ app_msi_ack => 1 => output] ),";
   $eport_msg_ez .= "e_port->new([ app_int_ack => 1 => output] ),";
}

##################################################
# Add reset logic
##################################################
my $reset_logic_ez='';
$add_signals_ez .= "e_signal->new({name => hotrst_exit_altr, width=> 1,never_export => 1}),";
$add_signals_ez .= "e_signal->new({name => npor_serdes_pll_locked, width=> 1,never_export => 1}),";

if ($phy_selection == $PHYSEL_SIV) {
   $reset_logic_ez .= "e_assign->new ([ hotrst_exit_altr  => \"hotrst_exit\"]),";
   $add_signals_ez .= "e_signal->new({name => pll_powerdown, width=> 1, never_export => 1}),";
   $reset_logic_ez .= "e_assign->new ([ pll_powerdown  => \"~npor\"]),";
   $add_signals_ez .= "e_signal->new({name => rx_freqlocked, width=> 1, never_export => 1}),";
   if ($enable_hip_dprio == 1) {
      $eport_misc_ez .= 'e_port->new([pcie_reconfig_busy => 1 => input]),';
      $reset_logic_ez .= "e_assign->new ([npor_serdes_pll_locked => \"(~pcie_reconfig_busy) & pcie_rstn & local_rstn & rc_pll_locked\"]),";
   } else {
      $reset_logic_ez .= "e_assign->new ([npor_serdes_pll_locked => \"pcie_rstn & local_rstn & rc_pll_locked\"]),";
   }
   $reset_logic_ez .= "e_assign->new ([npor => \"pcie_rstn & local_rstn\"]),";

} elsif ($phy_selection==$PHYSEL_SV) {
   $reset_logic_ez .= "e_assign->new ([hotrst_exit_altr  => \"~reset_status\"]),";
   $reset_logic_ez .= "e_assign->new ([npor_serdes_pll_locked => \"perst_n & rc_pll_locked & local_rstn\"]),";
}

my $rs_hip = $var . "_rs_hip";
   $label_ez = "rs_hip";
   $label_ez{$label_ez} = 1;
   $$label_ez = e_blind_instance->new({
                     module => "$rs_hip",
                     name => "rs_hip",
                     in_port_map => {
                        pld_clk      => "pld_clk",
                        dlup_exit    => "dlup_exit",
                        l2_exit      => "l2_exit",
                        hotrst_exit  => "hotrst_exit_altr",
                        test_sim     => "test_in[0]",
                        npor         => "npor_serdes_pll_locked",
                        ltssm        => "ltssm",
                     },
                     out_port_map        => {
                        app_rstn     => "srstn",
                        crst         => "crst",
                        srst         => "srst",
                     },
   });



if ($phy_selection==$PHYSEL_SV) {
   $add_assign_ez .= "e_assign->new ([pld_clrpmapcship => \"srst\"]),";
   $add_assign_ez .= "e_assign->new ([pld_clrhip_n => \"~crst\"]),";
}


## print "\n\n\n==================+DEBUG=============================================\n\n";
## print "tl_selection                 : $tl_selection                                  \n";
## print "phy_selection                : $phy_selection                                 \n";
## print "rp                           : $rp                                            \n";
## print "enable_hip_dprio             : $enable_hip_dprio                              \n";
## print "==================++DEBUG====================================================\n\n";
## print " clk_ports                   :   $clk_ports                                    \n";
## print " serdes_interface            :   $serdes_interface                             \n";
## print " pipe_interface              :   $pipe_interface                               \n";
## print " eport_misc_ez               :   $eport_misc_ez                                \n";
## print " eport_msg_ez                :   $eport_msg_ez                                 \n";
## print " eport_ast_ez                :   $eport_ast_ez                                 \n";
## print " eport_avs_hip_reconfig_ez   :   $eport_avs_hip_reconfig_ez                    \n";
## print " avs_pcie_reconfig_in_ez     :   $avs_pcie_reconfig_in_ez                      \n";
## print " avs_pcie_reconfig_out_ez    :   $avs_pcie_reconfig_out_ez                     \n";
## print " add_assign_ez               :   $add_assign_ez                                \n";
## print " add_signals_ez              :   $add_signals_ez                               \n";
## print " reset_logic_ez              :   $reset_logic_ez                               \n";
## print " vcs_signals_ez              :   $vcs_signals_ez                               \n";
## print "=========================================++DEBUG=============================\n\n";

my $serdes_clk_port_ez='';
if ($phy_selection==$PHYSEL_SIV) {
   $serdes_clk_port_ez.='e_port->new([ fixedclk_serdes => 1 => "input"]),';
   $serdes_clk_port_ez.='e_port->new([ reconfig_clk_locked  => 1 => "input"]),';
   $serdes_clk_port_ez.='e_port->new([ reconfig_clk         => 1 => "input"]),';
}

$top_ez_mod->add_contents (

   my $refclk                  = e_port->new([ refclk => 1 => "input"]),
   eval($serdes_clk_port_ez),
   eval($clk_ports),
   eval($top_rst_port_in_ez),
   eval($top_rst_port_out_ez),

   #--serdes interfaces
   eval($serdes_interface),

   #--pipe interface
   eval($pipe_interface),

   eval($eport_misc_ez),
   eval($eport_msg_ez ),
   eval($eport_ast_ez ),
   eval($eport_avs_hip_reconfig_ez),

   eval($add_assign_ez),
   eval($add_signals_ez),
   eval($reset_logic_ez),
   eval($vcs_signals_ez),

   $var_inst,
);



foreach $key (sort keys %label_ez) {
   $top_ez_mod->add_contents($$key);
}
$proj_ez->top($top_ez_mod);
$proj_ez->language($language);
$proj_ez->output();

###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
# Reset HIP
#
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
my $proj_rs_hip       = e_project->new();
my $top_rs_hip_mod    = e_module->new ({name => "$module_rs_hip", comment => "/** Reset logic for HIP + \n*/"});
$top_rs_hip_mod->vhdl_libraries()->{altera_mf} = "all";
my $add_signals_rs_hip = " ";
my $add_assign_rs_hip='';


$add_signals_rs_hip .= "e_signal->new({name => dl_ltssm_r, width=> 5,never_export => 1}),";
$add_signals_rs_hip .= "e_signal->new({name => otb0, width=> 1, never_export => 1}),";
$add_signals_rs_hip .= "e_signal->new({name => otb1, width=> 1, never_export => 1}),";
$add_assign_rs_hip  .= "e_assign->new ([ otb0=> \"1'b0\"]),";
$add_assign_rs_hip  .= "e_assign->new ([ otb1=> \"1'b1\"]),";


$add_assign_rs_hip .= "e_process->new({
                     comment => \"pipe line exit conditions\",
                     clock => \"$clkfreq_in\",
                     reset => \"any_rstn_rr\",
                     asynchronous_contents => [
                     e_assign->new([\"dlup_exit_r\" => otb1]),
                     e_assign->new([\"hotrst_exit_r\" => otb1]),
                     e_assign->new([\"l2_exit_r\" => otb1]),
                     e_assign->new([\"exits_r\" => otb0]),
                     ],
                     contents => [
                     e_assign->new([\"dlup_exit_r\" => \"dlup_exit\"]),
                     e_assign->new([\"hotrst_exit_r\" => \"hotrst_exit\"]),
                     e_assign->new([\"l2_exit_r\" => \"l2_exit\"]),
                     e_assign->new([\"exits_r\" => \"(l2_exit_r == 1'b0) | (hotrst_exit_r == 1'b0) | (dlup_exit_r == 1'b0) | (dl_ltssm_r == 5'h10) \"]),
                     ],
                     }),";

$add_assign_rs_hip .= "e_process->new({
                     comment => \"LTSSM pipeline\",
                     clock => \"$clkfreq_in\",
                     reset => \"any_rstn_rr\",
                     asynchronous_contents => [
                     e_assign->new([\"dl_ltssm_r\" => 0]),
                     ],
                     contents => [
                     e_assign->new([\"dl_ltssm_r\" => ltssm]),
                     ],

                     }),";

$add_assign_rs_hip .= "e_process->new({
                  comment => \"reset Synchronizer\",
                  clock => \"$clkfreq_in\",
                  reset => \"npor\",
                  asynchronous_contents => [
                  e_assign->new([\"any_rstn_r\" => 0]),
                  e_assign->new([\"any_rstn_rr\" => 0]),
                  ],
                  user_attributes_names => [\"any_rstn_r\",\"any_rstn_rr\"],
                  user_attributes => [
                  {
                  attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
                  attribute_operator => '=',
                  attribute_values => ['R102'],
                  },
                  {
                  attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
                  attribute_operator => '=',
                  attribute_values => ['R101'],
                  },
                  ],
                  contents => [
                  e_assign->new([\"any_rstn_r\" => 1]),
                  e_assign->new([\"any_rstn_rr\" => \"any_rstn_r\"]),
                  ],

                  }),";

$add_signals_rs_hip .= "e_signal->new({name => rsnt_cntn, width=> 11, never_export => 1}),";

$add_assign_rs_hip .= "e_process->new({
comment => \"reset counter\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"rsnt_cntn\" => '0']),
],
contents => [
e_if->new({
condition => \"(exits_r == 1'b1)\",
then => [\"rsnt_cntn\" => \"11'h3f0\" ],
else => [
e_if->new({
condition => \"rsnt_cntn != 11'd1024\",
then => [\"rsnt_cntn\" => \"rsnt_cntn + 1\"],
}),
],
}),
],
}),";

if ($rp == 0) { # endpoint mode
   $add_assign_rs_hip .= "e_process->new({
   comment => \"sync and config reset\",
   clock => \"$clkfreq_in\",
   reset => \"any_rstn_rr\",
   asynchronous_contents => [
   e_assign->new([\"app_rstn0\" => '0']),
   e_assign->new([\"srst0\" => '1']),
   e_assign->new([\"crst0\" => '1'])

   ],
   contents => [
   e_if->new({
   condition => \"(exits_r == 1'b1)\",
   then => [\"srst0\" => 1,\"crst0\" => 1,\"app_rstn0\" => 0],
   else => [
   e_if->new({
   comment => \" synthesis translate_off\",
   condition => \"(test_sim == 1'b1) & (rsnt_cntn >= 11'd32)\",
   then => [\"srst0\" => 0,\"crst0\" => 0,\"app_rstn0\" => 1],
   else => [
   e_if->new({
   comment => \" synthesis translate_on\",
   condition => \"(rsnt_cntn == 11'd1024)\",
   then => [\"srst0\" => 0,\"crst0\" => 0,\"app_rstn0\" => 1],
   }),
   ]
   }),
   ]
   }),
   ],
   }),";
} else {  # root port mode
   $add_assign_rs_hip .= "e_process->new({
   comment => \"sync reset\",
   clock => \"$clkfreq_in\",
   reset => \"any_rstn_rr\",
   asynchronous_contents => [
   e_assign->new([\"app_rstn0\" => '0']),
   e_assign->new([\"srst0\" => '1']),

   ],
   contents => [
   e_if->new({
   condition => \"(exits_r == 1'b1) \",
   then => [\"srst0\" => 1,\"app_rstn0\" => 0],
   else => [
   e_if->new({
   comment => \" synthesis translate_off\",
   condition => \"(test_sim == 1'b1) & (rsnt_cntn >= 11'd32)\",
   then => [\"srst0\" => 0,\"app_rstn0\" => 1],
   else => [
   e_if->new({
   comment => \" synthesis translate_on\",
   condition => \"(rsnt_cntn == 11'd1024)\",
   then => [\"srst0\" => 0,\"app_rstn0\" => 1],
   }),
   ]
   }),
   ]
   }),
   ],
   }),";

   $add_assign_rs_hip .= "e_process->new({
         comment => \"config reset\",
         clock => \"$clkfreq_in\",
         reset => \"any_rstn_rr\",
         asynchronous_contents => [
         e_assign->new([\"crst0\" => '1'])

         ],
         contents => [
         e_if->new({
         condition => \"(l2_exit_r == 1'b0) | (hotrst_exit_r == 1'b0)\",
         then => [\"crst0\" => 1],
         else => [
         e_if->new({
         comment => \" synthesis translate_off\",
         condition => \"(test_sim == 1'b1) & (rsnt_cntn >= 11'd32)\",
         then => [\"crst0\" => 0],
         else => [
         e_if->new({
         comment => \" synthesis translate_on\",
         condition => \"(rsnt_cntn == 11'd1024)\",
         then => [\"crst0\" => 0],
         }),
         ]
         }),
         ]
         }),
         ],
         }),";

}

$add_assign_rs_hip .= "e_process->new({
      comment => \"sync and config reset pipeline\",
      clock => \"$clkfreq_in\",
      reset => \"any_rstn_rr\",
      asynchronous_contents => [
      e_assign->new([\"app_rstn\" => '0']),
      e_assign->new([\"srst\" => '1']),
      e_assign->new([\"crst\" => '1'])

      ],
      contents => [
      e_assign->new([\"app_rstn\" => 'app_rstn0']),
      e_assign->new([\"srst\" => 'srst0']),
      e_assign->new([\"crst\" => 'crst0'])
      ],
      }),";


$top_rs_hip_mod->add_contents (
   my $pld_clk       = e_port->new([ pld_clk       => 1 => "input"]),
   my $dlup_exit     = e_port->new([ dlup_exit     => 1 => "input"]),
   my $l2_exit       = e_port->new([ l2_exit       => 1 => "input"]),
   my $hotrst_exit   = e_port->new([ hotrst_exit   => 1 => "input"]),
   my $npor          = e_port->new([ npor          => 1 => "input"]),
   my $test_sim      = e_port->new([ test_sim      => 1 => "input"]),
   my $ltssm         = e_port->new([ ltssm         => 5 => "input"]),

   my $app_rstn      = e_port->new([ app_rstn      => 1 => "output"]),
   my $crst          = e_port->new([ crst          => 1 => "output"]),
   my $srst          = e_port->new([ srst          => 1 => "output"]),

   eval($add_signals_rs_hip),
   eval($add_assign_rs_hip),
);

$proj_rs_hip->top($top_rs_hip_mod);
$proj_rs_hip->language($language);
$proj_rs_hip->output();


# copy in virtual pin tcl
$example_sdc = $var . "_example.sdc";
open (SDC_DE,">$example_sdc") || die "Cannot open $example_sdc";
if ( ($phy_selection==$PHYSEL_SIV) | ($phy_selection==$PHYSEL_SV) ) {
   print SDC_DE "derive_pll_clocks \n";
   print SDC_DE "derive_clock_uncertainty\n";
}
if ($phy_selection==$PHYSEL_SIV) {
   print SDC_DE 'create_clock -period "100 MHz" -name {free_100MHz} {free_100MHz}' . "\n";
}
close (SDC_DE);
