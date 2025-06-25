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
my $cvp=0;
my $refclk_selection = 0;
my $lane_width = 1;
my $var = "pci_var";
my $language = "vhdl";
my $number_of_vcs = 2;
my $pipe_txclk = 0;
my $tlp_clk_req = 0;
my $multi_core = 0;
my $test_out_width = 9;
my $family = "Cyclone II";

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

my $temp = $command_hash{"multi_core"};
if($temp ne "")
{
   $multi_core = $temp;
}

my $temp = $command_hash{"test_out_width"};
if($temp ne "")
{
   $test_out_width = $temp;
}

my $temp = $command_hash{"family"};
if($temp ne "")
{
   $family = $temp;
}

my $c3gx=0;
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

if ($language =~ /hdl/i) {
   $comment_hdl = "VHDL";
}

my $top_mod = e_module->new ({name => "$var\_icm", comment => "/** This $comment_hdl file generates the Incremental Compilation Wrapper that is used for simulation and synthesis\n*/"});


#processed variables
my $pipe_width = 16;

##################################################
# clkin /out
##################################################
my $clkfreq_in = "clk125_in";
my $clkfreq_out = "clk125_out";

if ($number_of_lanes == 8) {
   $clkfreq_in = "clk250_in";
   $clkfreq_out = "clk250_out";

}

##################################################
# reset input
##################################################
my $reset_in = " ";
if ($number_of_lanes == 8) {
   $reset_in .= "rstn => \"rstn\",";
} else {
   $reset_in .= "crst => \"crst\",";
   $reset_in .= "srst => \"srst\",";
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
# Serdes connections
##################################################

# default connections
my $serdes_out = " ";
my $serdes_in = " ";
my $serdes_interface = " ";
my $i;

if (($phy_selection == 0) || ($phy_selection == 2)  || ($phy_selection == 6)) { # needs serdes connection
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

if (($phy_selection == 0) || ($phy_selection == 1))  { # needs serdes connection
   $pipe_width = 16;
} elsif (($phy_selection == 2)  || ($phy_selection == 6)) {
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


if ($number_of_lanes == 8) {
   $txcred_width = 66;

} else {
   $txcred_width = 22;
}

my $parameter_str = " ";
$parameter_str = "TXCRED_WIDTH => $txcred_width";


#lane width & test width
if ($number_of_lanes == 1) {
   $lane_width = 0;
   $test_out_ltssm = "test_out_int[324:320]";
   $test_out_lane = "test_out_int[411:408]";
} elsif ($number_of_lanes == 2) {
   $lane_width = 1;
   $test_out_ltssm = "test_out_int[324:320]";
   $test_out_lane = "test_out_int[411:408]";
} elsif ($number_of_lanes == 4) {
   $lane_width = 2;
   $test_out_ltssm = "test_out_int[324:320]";
   $test_out_lane = "test_out_int[411:408]";
} elsif ($number_of_lanes == 8) {
   $lane_width = 3;
   $test_out_ltssm = "test_out_int[4:0]";
   $test_out_lane = "test_out_int[91:88]";
} else {
   die "ERROR: Number of lanes are not supported\n";
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


}


##################################################
# add misc signals
##################################################

my $add_signals = " ";
my $glue_logic = " ";

# test out bus
$add_signals .= "e_signal->new({name => test_out_int, width=>  $test_out_width, never_export => 1}),";
$add_signals .= "e_signal->new({name => test_out_wire, width=>  9, never_export => 1}),";
if ($test_out_width == 9) {
   $glue_logic .= "e_assign->new({lhs => {name => test_out_wire}, rhs => \"test_out_int\"}),";
} elsif ($test_out_width > 0) { # full width
   $glue_logic .= "e_assign->new({lhs => {name => test_out_wire}, rhs => \"{$test_out_lane,$test_out_ltssm}\"}),";
} else {
   $glue_logic .= "e_assign->new({lhs => {name => test_out_wire}, rhs => 0}),";
}
# test_in
$add_signals .= "e_signal->new({name => test_in_int, width=>  32, never_export => 1}),";
$glue_logic .= "e_assign->new({lhs => {name => test_in_int}, rhs => \"{23'h000000,test_in[8:5],1'b0,test_in[3],2'b00,test_in[0]}\"}),";


# app_clk
if ($number_of_lanes == 1) {
   $add_signals .= "e_port->new([app_clk => 1 => \"output\"]),";
}


# multi-bit bus
$add_signals .= "e_signal->new({name => app_msi_tc, width=> 3}),";
$add_signals .= "e_signal->new({name => app_msi_num, width=> 5}),";
$add_signals .= "e_signal->new({name => pex_msi_num, width=> 5}),";
$add_signals .= "e_signal->new({name => cfg_busdev, width=> 13}),";
$add_signals .= "e_signal->new({name => cfg_msicsr, width=> 16}),";
$add_signals .= "e_signal->new({name => cfg_devcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_linkcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_prmcsr, width=> 32}),";
$add_signals .= "e_signal->new({name => cfg_tcvcmap, width=> 24}),";
$add_signals .= "e_signal->new({name => open_cfg_tcvcmap_icm, width=> 24, never_export => 1}),";
$add_signals .= "e_signal->new({name => cpl_err, width=> 7,never_export => 1}),";
$add_signals .= "e_signal->new({name => cpl_err_int, width=> 3,never_export => 1}),";
$add_signals .= "e_signal->new({name => cpl_err_icm_int, width=> 3,never_export => 1}),";

# cpl_err
$glue_logic .= "e_assign->new({lhs => {name => cpl_err}, rhs => \"{cpl_err_int,4'h0}\"}),";
$glue_logic .= "e_assign->new({lhs => {name => cpl_err_icm_int}, rhs => \"cpl_err_icm[2:0]\"}),";


my $open_signals = " ";

$add_signals .= "e_signal->new({name => open_cfg_pmcsr, width=> 32, never_export => 1}),";
$open_signals .= "cfg_pmcsr => open_cfg_pmcsr,";

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
my $app_vcs_cnt = 1;

for ($i = 0; $i < $number_of_vcs; $i++) {
   if ($i < $app_vcs_cnt) {
# multi-bit bus
      $vcs_signals .= "e_signal->new({name => tx_desc$i, width=> 128}),";
      $vcs_signals .= "e_signal->new({name => tx_data$i, width=> 64}),";
      $vcs_signals .= "e_signal->new({name => ko_cpl_spc_vc$i, width=> 20}),";
      $vcs_signals .= "e_signal->new({name => rx_desc$i, width=> 136}),";
      $vcs_signals .= "e_signal->new({name => rx_data$i, width => 64}),";
      $vcs_signals .= "e_signal->new({name => rx_be$i, width=> 8}),";
      $vcs_signals .= "e_signal->new({name => tx_cred$i\_int, width=> $txcred_width, never_export => 1}),";

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

      $vcs_signals .= "e_signal->new({name => open_ko_cpl_spc_vc$i, width => 20, never_export => 1}),";
      $vcs_connect_out .= "ko_cpl_spc_vc$i =>open_ko_cpl_spc_vc$i,";
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
      $vcs_connect_out .= "tx_cred$i => tx_cred$i\_int,";


   } else {
      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_ack$i}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "rx_ack$i => gnd_rx_ack$i,";

      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_abort$i}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "rx_abort$i => gnd_rx_abort$i,";

      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_retry$i}, rhs => \"1'b0\"}),";
      $vcs_connect_in .= "rx_retry$i => gnd_rx_retry$i,";

      $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_mask$i}, rhs => \"1'b0\"})," ;
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


      $vcs_signals .= "e_signal->new({name => open_ko_cpl_spc_vc$i, width => 20, never_export => 1}),";
      $vcs_connect_out .= "ko_cpl_spc_vc$i =>open_ko_cpl_spc_vc$i,";

      $vcs_signals .= "e_signal->new({name => open_rx_req$i, never_export => 1}),";
      $vcs_connect_out .= "rx_req$i =>open_rx_req$i,";

      $vcs_signals .= "e_signal->new({name => open_rx_desc$i, width=> 136, never_export => 1}),";
      $vcs_connect_out .= "rx_desc$i =>open_rx_desc$i,";

      $vcs_signals .= "e_signal->new({name => open_rx_data$i, width => 64, never_export => 1}),";
      $vcs_connect_out .= "rx_data$i =>open_rx_data$i,";

      if ($number_of_lanes != 8) { # x8 core does not have Byte enable
         $vcs_signals .= "e_signal->new({name => open_rx_be$i, width=> 8, never_export => 1}),";
         $vcs_connect_out .= "rx_be$i =>open_rx_be$i,";
         $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_err$i}, rhs => \"1'b0\"}),";
         $vcs_connect_in .= "tx_err$i => gnd_tx_err$i,";
      }


      $vcs_signals .= "e_signal->new({name => open_rx_dv$i, never_export => 1}),";
      $vcs_connect_out .= "rx_dv$i =>open_rx_dv$i,";

      $vcs_signals .= "e_signal->new({name => open_rx_dfr$i, never_export => 1}),";
      $vcs_connect_out .= "rx_dfr$i =>open_rx_dfr$i,";

      $vcs_signals .= "e_signal->new({name => open_tx_ack$i, never_export => 1}),";
      $vcs_connect_out .= "tx_ack$i =>open_tx_ack$i,";

      $vcs_signals .= "e_signal->new({name => open_tx_cred$i, width=> $txcred_width, never_export => 1}),";
      $vcs_connect_out .= "tx_cred$i =>open_tx_cred$i,";

      $vcs_signals .= "e_signal->new({name => open_tx_ws$i, never_export => 1}),";
      $vcs_connect_out .= "tx_ws$i =>open_tx_ws$i,";

   }
}

# instantiate test out port
if ($test_out_width > 0) {
   $vcs_connect_out .= "test_out => \"test_out_int\",";
}

##################################################
# Apps VC interface
##################################################
my $app_vcs_connect_in = " ";
my $app_vcs_connect_out = " ";
my $app_vcs_open = " ";
my $app_vcs_signals = " ";


for ($i = 0; $i < $app_vcs_cnt; $i++) {
   $app_vcs_connect_out .= "rx_ack$i => rx_ack$i,";
   $app_vcs_connect_out .= "rx_abort$i => rx_abort$i,";
   $app_vcs_connect_out .= "rx_retry$i => rx_retry$i,";
   $app_vcs_connect_out .= "rx_mask$i => rx_mask$i,";
   $app_vcs_connect_out .= "rx_ws$i => rx_ws$i,";

   $app_vcs_connect_out .= "tx_req$i => tx_req$i,";
   $app_vcs_connect_out .= "tx_desc$i => tx_desc$i,";
   $app_vcs_connect_out .= "tx_dfr$i => tx_dfr$i,";
   $app_vcs_connect_out .= "tx_data$i => tx_data$i,";
   $app_vcs_connect_out .= "tx_dv$i => tx_dv$i,";
   $app_vcs_connect_out .= "tx_stream_cred$i => tx_stream_cred$i,";

   $app_vcs_connect_in .= "rx_req$i => rx_req$i,";
   $app_vcs_connect_in .= "rx_desc$i => rx_desc$i,";
   $app_vcs_connect_in .= "rx_data$i => rx_data$i,";
   $app_vcs_connect_in .= "tx_cred$i => tx_cred$i\_int,";

   if ($number_of_lanes == 8) { # x8 core does not have Byte enable
      $app_vcs_signals .= "e_assign->new({lhs => {name => one_rx_be$i, width=> 8}, rhs => \"8'hff\"}),";
      $app_vcs_connect_in .= "rx_be$i => one_rx_be$i,";

      $app_vcs_signals .= "e_signal->new({name => open_tx_err$i, never_export => 1}),";
      $app_vcs_connect_out .= "tx_err$i =>open_tx_err$i,";

   } else {
      $app_vcs_connect_in .= "rx_be$i => rx_be$i,";
      $app_vcs_connect_out .= "tx_err$i => tx_err$i,";
   }

   $app_vcs_connect_in .= "rx_dv$i => rx_dv$i,";
   $app_vcs_connect_in .= "rx_dfr$i => rx_dfr$i,";

   $app_vcs_connect_in .= "tx_ack$i => tx_ack$i,";
   $app_vcs_connect_in .= "tx_ws$i => tx_ws$i,";
}


##################################################
# generation of phy reset
##################################################
if (($phy_selection == 1) | ($phy_selection == 3) | ($phy_selection == 4) | ($phy_selection == 5)) {
   $top_mod->add_contents
      (
       my $pipe_rstn = e_port->new([ pipe_rstn => 1 => "output"]),
      );
   $pipe_connect_out .= "pipe_rstn => pipe_rstn,";

}


##################################################
# Add pipe_txclk
##################################################

if ($pipe_txclk == 1) {
   $top_mod->add_contents
      (
       my $txclk = e_port->new([ pipe_txclk => 1 => "output"]),
      );
   $pipe_connect_out .= "pipe_txclk => pipe_txclk,";

}


##################################################
# Alt2gxb specific signals
##################################################
$alt2gxb_in = " ";
$alt2gxb_out = " ";
if ($phy_selection == 2) { #S2GX

   if ($number_of_lanes < 8) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 1}),";
   } else {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 2}),";
   }

   $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 3}),";
   $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
   $alt2gxb_in .= "reconfig_clk => reconfig_clk,";
   $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";
   $alt2gxb_in .= "gxb_powerdown => \"gxb_powerdown\",";
   $alt2gxb_out .= "reconfig_fromgxb => reconfig_fromgxb,";

} elsif ($phy_selection == 6) {

   if ($c3gx==1) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 5}),";
   }
   elsif ($number_of_lanes < 8) {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 17}),";
   } else {
      $add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 34}),";
   }
   $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 4}),";
   $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
   $alt2gxb_in .= "fixedclk_serdes => fixedclk_serdes,";
   $alt2gxb_in .= "reconfig_clk => reconfig_clk,";
   $alt2gxb_in .= "busy_altgxb_reconfig => busy_altgxb_reconfig,";
   $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";
   $alt2gxb_in .= "gxb_powerdown => \"gxb_powerdown\",";
   $alt2gxb_in .= "pll_powerdown => \"pll_powerdown\",";
   if ($c3gx==1) {
      $alt2gxb_out .= "reconfig_fromgxb => \"reconfig_fromgxb\",";
   } else {
      $alt2gxb_out .= "reconfig_fromgxb => reconfig_fromgxb,";
   }
}

# external phy
if (($phy_selection == 1) || ($phy_selection == 3) ||
      ($phy_selection == 4) || ($phy_selection == 5)) {
   $alt2gxb_in .= "xphy_pll_areset => xphy_pll_areset,";
   $alt2gxb_out .= "xphy_pll_locked => xphy_pll_locked,";
}


##################################################
# tx credit
##################################################
$add_signals .= "e_signal->new({name => tx_npcredh0, width=> 8, never_export => 1}),";
$add_signals .= "e_signal->new({name => tx_npcredd0, width=> 12, never_export => 1}),";
$add_signals .= "e_signal->new({name => tx_npcredh_inf0, width=> 1, never_export => 1}),";
$add_signals .= "e_signal->new({name => tx_npcredd_inf0, width=> 1, never_export => 1}),";

if ($number_of_lanes < 8) {
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredh0}, rhs => \"tx_cred0_int[10]\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredd0}, rhs => \"tx_cred0_int[11]\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredh_inf0}, rhs => \"1'b0\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredd_inf0}, rhs => \"1'b0\"}),";
} else {
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredh0}, rhs => \"tx_cred0_int[27:20]\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredd0}, rhs => \"tx_cred0_int[39:28]\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredh_inf0}, rhs => \"tx_cred0_int[62]\"}),";
   $vcs_signals .= "e_assign->new({lhs => {name => tx_npcredd_inf0}, rhs => \"tx_cred0_int[63]\"}),";
}



##################################################
# Instantiate user variation
##################################################

my $pci_inst = e_blind_instance->new({
      module => "$var",
      name => "epmap",
      in_port_map => {
      refclk => "refclk",
      npor => "npor",
      eval($reset_in),

      eval($dual_phy_in),
      eval($alt2gxb_in),
      $clkfreq_in => "$clkfreq_in",

      eval($serdes_in),
      eval($pipe_connect_in),

      test_in => "test_in_int",
      cpl_pending => "cpl_pending",
      cpl_err => "cpl_err",
      pme_to_cr => "pme_to_cr",
      app_int_sts => "app_int_sts",
      app_msi_req => "app_msi_req",
      app_msi_tc => "app_msi_tc",
      app_msi_num => "app_msi_num",
      pex_msi_num => "pex_msi_num",
      eval($vcs_connect_in),
      },
      out_port_map => {
         $clkfreq_out => "$clkfreq_out",

         eval($dual_phy_out),
         eval($alt2gxb_out),
         eval($serdes_out),
         eval($pipe_connect_out),

         eval($app_clk_out),
         l2_exit => "l2_exit",
         hotrst_exit => "hotrst_exit",
         dlup_exit => "dlup_exit",
         pme_to_sr => "pme_to_sr",
         app_msi_ack => "app_msi_ack",
         cfg_busdev => "cfg_busdev",
         cfg_devcsr => "cfg_devcsr",
         cfg_linkcsr =>"cfg_linkcsr",
         cfg_prmcsr =>"cfg_prmcsr",
         cfg_prmcsr =>"cfg_prmcsr",
         cfg_msicsr => "cfg_msicsr",
         cfg_tcvcmap => "cfg_tcvcmap",
         app_int_ack => "app_int_ack",
         eval($vcs_connect_out),
         eval($open_signals),

      },

});

##################################################
# Instantiate ICM
##################################################

my $icm_wrapper = e_blind_instance->new({
      module => "altpcierd_icm_top",
      name => "icm",
      parameter_map => {
      eval($parameter_str)
      },
      in_port_map => {
      clk => "$app_clk_in",
      rstn => "rstn",

      app_msi_ack => "app_msi_ack",
      cfg_busdev => "cfg_busdev",
      cfg_devcsr => "cfg_devcsr",
      cfg_linkcsr =>"cfg_linkcsr",
      cfg_prmcsr =>"cfg_prmcsr",
      cfg_msicsr =>"cfg_msicsr",
      cfg_tcvcmap => "cfg_tcvcmap",
      app_int_sts_icm => "app_int_sts_icm",
      pex_msi_num_icm => "pex_msi_num_icm",
      cpl_err_icm => "cpl_err_icm_int",
      cpl_pending_icm => "cpl_pending_icm",

# avalon interface
      tx_stream_valid0 => "tx_stream_valid0",
      tx_stream_data0 => "tx_stream_data0",
      msi_stream_valid0 => "msi_stream_valid0",
      msi_stream_data0  => "msi_stream_data0 ",
      rx_stream_ready0 => "rx_stream_ready0",
      rx_stream_mask0 => "rx_stream_mask0",
      app_int_sts_ack => "app_int_ack",

      tx_npcredh0 => "tx_npcredh0",
      tx_npcredd0 => "tx_npcredd0",
      tx_npcredh_inf0 => "tx_npcredh_inf0",
      tx_npcredd_inf0 => "tx_npcredd_inf0",
      test_out => "test_out_wire",

      eval($app_vcs_connect_in)

      },
      out_port_map => {
         cpl_pending => "cpl_pending",
         cpl_err => "cpl_err_int",
         app_int_sts => "app_int_sts",
         app_int_sts_ack_icm => "app_int_sts_ack_icm",
         app_msi_req => "app_msi_req",
         app_msi_tc => "app_msi_tc",
         app_msi_num => "app_msi_num",
         pex_msi_num => "pex_msi_num",
         cfg_busdev_icm => "cfg_busdev_icm",
         cfg_devcsr_icm => "cfg_devcsr_icm",
         cfg_linkcsr_icm =>"cfg_linkcsr_icm",
         cfg_prmcsr_icm =>"cfg_prmcsr_icm",
         cfg_msicsr_icm =>"cfg_msicsr_icm",
         cfg_tcvcmap_icm => "open_cfg_tcvcmap_icm",
         tx_stream_mask0 => "tx_stream_mask0",

# avalon inteface
         tx_stream_ready0 => "tx_stream_ready0",
         msi_stream_ready0 => "msi_stream_ready0",
         rx_stream_valid0 => "rx_stream_valid0",
         rx_stream_data0 => "rx_stream_data0",
         test_out_icm => "test_out_icm",

         eval($app_vcs_connect_out)


      },

});


$top_mod->add_contents
(
 my $refclk = e_port->new([ refclk => 1 => "input"]),
 my $clk_in = e_port->new([ $clkfreq_in => 1 => "input"]),
 my $clk_out = e_port->new([ $clkfreq_out => 1 => "output"]),

 my $phy_sel_code = e_port->new([phy_sel_code => 4 => "output"]),
 my $ref_clk_sel_code = e_port->new([ref_clk_sel_code => 4 => "output"]),
 my $lane_width_code = e_port->new([lane_width_code => 4 => "output"]),

#--serdes interfaces
 eval($serdes_interface),

#--pipe interface
 eval($pipe_interface),

# app interface
 my $tx_cred0 = e_port->new([tx_stream_cred0 => $txcred_width => "output"]),

 my $pex_msi_num = e_port->new([pex_msi_num_icm => 5 => "input"]),
 my $cpl_err = e_port->new([cpl_err_icm => 7 => "input"]),
 my $cfg_busdev = e_port->new([cfg_busdev_icm => 13 => "output"]),
 my $cfg_devcsr = e_port->new([cfg_devcsr_icm => 32 => "output"]),
 my $cfg_linkcsr = e_port->new([cfg_linkcsr_icm => 32 => "output"]),
 my $cfg_prmcsr = e_port->new([cfg_prmcsr_icm => 32 => "output"]),
 my $cfg_linkcsr = e_port->new([cfg_msicsr_icm => 16 => "output"]),

# avalon interface
 e_port->new([tx_stream_data0 => 75 => "input"]),
 e_port->new([msi_stream_data0 => 8 => "input"]),
 e_port->new([rx_stream_data0 => 82 => "output"]),

 e_port->new([test_in => 32 => "input"]),
 e_port->new([test_out_icm => 9 => "output"]),

 e_assign->new([ref_clk_sel_code => "$refclk_selection"]),
 e_assign->new([lane_width_code => "$lane_width"]),
 e_assign->new([phy_sel_code => "$phy_selection"]),

 eval($add_signals),
 eval($glue_logic),
 eval($vcs_signals),
 eval($app_vcs_signals),

 $pci_inst,
 $icm_wrapper

 );


 foreach $label (@label) {
    $top_mod->add_contents($$label);
 }

$top_mod->vhdl_libraries()->{altera_mf} = "all";

$proj->top($top_mod);
$proj->language($language);
$proj->output();

