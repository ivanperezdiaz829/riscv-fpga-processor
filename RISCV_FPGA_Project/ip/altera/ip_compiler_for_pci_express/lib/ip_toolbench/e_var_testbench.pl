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

#####################################################################
# This europa file generates what used to be altpcietb_top_x4_pipen1b
# It instantiates
# 1) Reference design
# 2) root port BFM
# 3) BFM driver
# 4) PIPE_PHYs (PIPE BFM that mimics the phy)
#####################################################################

use europa_all;
use e_parameter_assign;

#pass the command line argument to the project
#my @dummy = ("--system_name=dummy","--system_directory=..");
my @dummy = ();
my $proj = e_project->new(@dummy);

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
my $refclk_selection = 1;
my $pipe_txclk = 0;
my $var = "pci_var";
my $lanerev = 0;
my $language = "vhdl";
my $tl_selection = 1;
my $RP_LANES = 8;
my $RP_PIPE_WIDTH = 8;
my $RP_KPIPE_WIDTH = $RP_PIPE_WIDTH / 8;
my $simple_dma = 1;
my $test_out_width = 9;
my $family = "Cyclone II";
my $hip = 0;
my $rp = 0;

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

my $temp = $command_hash{"txclk"};
if($temp ne "")
{
   $pipe_txclk = $temp;
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

my $temp = $command_hash{"lanerev"};
if($temp ne "")
{
   $lanerev = $temp;
}

my $temp = $command_hash{"simple_dma"};
if($temp ne "")
{
   $simple_dma = $temp;
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

   $tl_selection = $temp;
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

my $temp = $command_hash{"family"};
if($temp ne "")
{
   $family = $temp;
}




# declare top module
my $pipen1b = "pipen1b";
my $testbench = "testbench";
my $driver = "driver";
my $comment_str = "simple";
my $comment_hdl = "Verilog HDL";
if ($rp == 0) {
    if ($simple_dma == 0) {
       if ($tl_selection ==9 ) {
         $comment_str   = "downstream";
         $pipen1b       = "chaining_pipen1b";
         $testbench     = "chaining_testbench";
         $driver        = "driver_downstream";
       } else {
         $comment_str   = "chaining";
         $pipen1b       = "chaining_pipen1b";
         $testbench     = "chaining_testbench";
         $driver        = "driver_chaining";
       }
    }
} else {
    $simple_dma = 0;
    $comment_str = "chaining";
    $pipen1b = "rp_pipen1b";
    $testbench = "rp_testbench";
    $driver = "driver_rp";
}


if ($language =~ /hdl/i) {
    $comment_hdl = "VHDL";
}

my $top_mod = e_module->new ({name => "$var\_$testbench", comment => "/** This $comment_hdl file is used for simulation in $comment_str DMA design example\n*\n* This file is the top level of the testbench\n*/"});

#processed variables
my $pipe_width = 16;

# check for stingray
if ($family =~ /cyclone_iv/i) {
    $c3gx = 1;
}

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
# Gen2 Clocking scheme
##################################################
my $rp_clk250_in = "clk250_out";
my $rp_clk500_in = "1'b0";
my $ep_rate = "1'b0";

if ($rp == 0) {
    if ($hip == 0) { # soft IP clocking
   $clk_in = "$clkfreq_in => \"ep_clk_in\",";
   $clk_out = "$clkfreq_out => \"ep_clk_out\",";
   $rp_clk250_in = "clk250_out";
   $rp_clk500_in = "1'b0";
    } else {
   $clk_in = "pclk_in => \"ep_pclk_in\",";
   $clk_in .= "pld_clk => \"ep_pld_clk\",";
   $clk_out = "core_clk_out => \"ep_core_clk_out\",";
   $clk_out .= "clk250_out => \"ep_clk250_out\",";
   $clk_out .= "clk500_out => \"ep_clk500_out\",";
   $rp_clk250_in = "ep_clk250_out";
   $rp_clk500_in = "ep_clk500_out";
   $ep_rate = "rate_ext";
    }
} else {
    $clk_in = "pclk_in => \"ep_pclk_in\",";
    $clk_in .= "pld_clk => \"ep_pld_clk\",";
    $clk_out = "core_clk_out => \"ep_core_clk_out\",";
    $clk_out .= "clk250_out => \"ep_clk250_out\",";
    $clk_out .= "clk500_out => \"ep_clk500_out\",";
    $ep_rate = "rate_ext";

    # root port side
    $rp_clk_in = "pclk_in => \"rp_pclk\",";
    $rp_clk_in .= "pld_clk => \"rp_pld_clk\",";
    $rp_clk_out = "core_clk_out => \"rp_core_clk_out\",";
    $rp_clk_out .= "clk250_out => \"rp_clk250_out\",";
    $rp_clk_out .= "clk500_out => \"rp_clk500_out\",";
    $rp_ep_rate = "rate_ext";


}


##################################################
# Reference design Serdes connections
##################################################

# default connections
my $serdes_out = " ";
my $serdes_in = " ";
my $i;
my $j;
my $add_signals = " ";

if (($phy_selection == 0) || ($phy_selection == 2) || ($phy_selection == 6) || ($phy_selection == 7)) { # needs serdes connection
    $serdes_in .= "pipe_mode => pipe_mode,";
    for ($i = 0; $i < $number_of_lanes; $i++) {
   $serdes_out .= "tx_out$i => tx_out$i,";
   $serdes_in .= "rx_in$i => rx_in$i,";
    }

    if ($rp > 0) {
   for ($i = $number_of_lanes; $i < 8; $i++) {
       $add_signals .= "e_signal->new({name => open_rp_tx_out$i, never_export => 1}),";
       $serdes_out .= "tx_out$i => open_rp_tx_out$i,";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_rx_in$i }, rhs => \"1'b0\"}),";
       $serdes_in .= "rx_in$i =>  gnd_rp_rx_in$i,";
   }
    }

}


##################################################
# set PIPE width
##################################################

if ($hip == 1) {
    $pipe_width = 8;
} elsif (($phy_selection == 0) || ($phy_selection == 1))  { # needs serdes connection
    $pipe_width = 16;
} elsif (($phy_selection == 2) || ($phy_selection == 6))  {
    if ($number_of_lanes < 8) {
   $pipe_width = 16;
    } else {
   $pipe_width = 8;
    }
} else {
    $pipe_width = 8;
}


#lane width & test width
$test_out = "test_out";

if (($tl_selection == 0) | ($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) { # icm mode
    $test_out = "test_out_icm";
}

##################################################
# add misc signals
##################################################

# multi-bit bus
if (($tl_selection == 0) || ($tl_selection == 6) || ($tl_selection == 7) || ($tl_selection == 9)) {
    $add_signals .= "e_signal->new({name => test_out, width=> 9}),";
} else {
    $add_signals .= "e_signal->new({name => test_out, width=> $test_out_width}),";
}
if ($hip == 1) {
     if ($phy_selection<7) {
         $add_signals .= "e_signal->new({name => test_in , width=> 40}),";
     } else {
         $add_signals .= "e_signal->new({name => test_in , width=> 32}),";
     }
} else {
    $add_signals .= "e_signal->new({name => test_in , width=> 32}),";
}
$add_signals .= "e_signal->new({name => phy_sel_code, width=> 4}),";
$add_signals .= "e_signal->new({name => ref_clk_sel_code, width=> 4}),";
$add_signals .= "e_signal->new({name => ref_clk_sel_code_ep, width=> 4,never_export => 1}),";
$add_signals .= "e_signal->new({name => lane_width_code, width=> 4, never_export => 1}),";
$add_signals .= "e_signal->new({name => connected_lanes , width=> 4, never_export => 1}),";
$add_signals .= "e_signal->new({name => connected_bits , width=> 8, never_export => 1}),";

if ($rp == 0) {
    $add_signals .= "e_signal->new({name => rp_test_out, width=> 512, never_export => 1}),";
    $add_signals .= "e_signal->new({name => rp_test_in , width=> 32, never_export => 1}),";
} else {
    $add_signals .= "e_signal->new({name => rp_test_out, width=> 9, never_export => 1}),";
    if ($phy_selection<7) {
      $add_signals .= "e_signal->new({name => rp_test_in , width=> 40, never_export => 1}),";
    } else {
      $add_signals .= "e_signal->new({name => rp_test_in , width=> 32, never_export => 1}),";
    }
}


$add_signals .= "e_signal->new({name => local_rstn}),";
$add_signals .= "e_signal->new({name => pcie_rstn}),";
$add_signals .= "e_signal->new({name => rp_rstn, never_export => 1}),";
$add_signals .= "e_signal->new({name => pipe_mode}),";
$add_signals .= "e_signal->new({name => pipe_mode_sig2, never_export => 1}),";
$add_signals .= "e_signal->new({name => refclk}),";

# work around a europa bug
$add_signals .= "e_signal->new({name => dummy_out, never_export => 1}),";
##################################################
# referecne design PIPE signals
##################################################

my $pipe_connect_in = " ";
my $pipe_connect_out = " ";
my $pipe_open = " ";
my $pipe_kwidth = $pipe_width / 8;
my $glue_logic = " ";

$pipe_connect_in .= "phystatus_ext => phystatus0_ext,";
$pipe_connect_out .= "txdetectrx_ext => txdetectrx0_ext,";
$pipe_connect_out .= "powerdown_ext => powerdown0_ext,";
if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) { # Dual phy
    $pipe_connect_out .= "phy1_txdetectrx_ext => txdetectrx4_ext,";
    $pipe_connect_out .= "phy1_powerdown_ext => powerdown4_ext,";
}

if ($rp == 0) {
    $EP_LANE = $number_of_lanes;
} else {
    $EP_LANE = 8;
}

for ($i = 0; $i < $EP_LANE;  $i++) {

    if ($lanerev == 1) {
   $j = $EP_LANE - 1 - $i;
    } else {
   $j = $i;
    }

    $pipe_connect_in .= "rxdata$i\_ext => rxdata$j\_ext,";
    $pipe_connect_in .= "rxdatak$i\_ext => rxdatak$j\_ext,";
    $pipe_connect_in .= "rxvalid$i\_ext => rxvalid$j\_ext,";
    $pipe_connect_in .= "rxelecidle$i\_ext => rxelecidle$j\_ext,";
    $pipe_connect_in .= "rxstatus$i\_ext => rxstatus$j\_ext,";

    $add_signals .= "e_signal->new({name => rxdata$i\_ext, width=> $pipe_width}),";
    $add_signals .= "e_signal->new({name => rxdatak$i\_ext, width=> $pipe_kwidth}),";
    $add_signals .= "e_signal->new({name => rxstatus$i\_ext, width=> 3}),";
    $add_signals .= "e_signal->new({name => rxvalid$i\_ext}),";
    if ($i == 0) {
   $add_signals .= "e_signal->new({name => phystatus$i\_ext}),";
    } else {
   $add_signals .= "e_signal->new({name => phystatus$i\_ext, never_export => 1}),";
    }
    $add_signals .= "e_signal->new({name => rxelecidle$i\_ext}),";
    $add_signals .= "e_signal->new({name => rx_in$i}),";
    $add_signals .= "e_signal->new({name => tx_out$i}),";

    $pipe_connect_out .= "txdata$i\_ext => txdata$j\_ext,";
    $pipe_connect_out .= "txdatak$i\_ext => txdatak$j\_ext,";
    $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$j\_ext,";
    $pipe_connect_out .= "txcompl$i\_ext => txcompl$j\_ext,";
    $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$j\_ext,";

    if ($hip == 1) {
       if ($phy_selection<7) {
         $pipe_connect_out .= "rate_ext => rate_ext,";
       } else {
         if ($i==0) {
            $add_signals .= "e_signal->new({name => rate_g3_ext, width => 2, never_export => 1}),";
            $add_signals .= "e_signal->new({name => rate_ext, width => 1, never_export => 1}),";
            $glue_logic  .= "e_assign->new([\"rate_ext\" => \"rate_g3_ext[0]\"]),";
            $pipe_connect_out .= "rate_ext => rate_g3_ext,";
         }
       }
    }
        # hook up the pipe_phys
    if (($i < 4) & ($i > 0)) {
   $glue_logic .= "e_assign->new([txdetectrx$i\_ext  => txdetectrx0_ext]),";
   $glue_logic .= "e_assign->new([powerdown$i\_ext  => powerdown0_ext]),";
    } elsif ($i >= 4 ) {
   if (($phy_selection == 4) | ($phy_selection == 3)) { # Dual phy
       if ($i != 4) {
      $glue_logic .= "e_assign->new([txdetectrx$i\_ext  => txdetectrx4_ext]),";
      $glue_logic .= "e_assign->new([powerdown$i\_ext  => powerdown4_ext]),";
       }
   } else { # stratix II GX
       $glue_logic .= "e_assign->new([txdetectrx$i\_ext  => txdetectrx0_ext]),";
       $glue_logic .= "e_assign->new([powerdown$i\_ext  => powerdown0_ext]),";
   }
    }



    $add_signals .= "e_signal->new({name => txdata$i\_ext, width=> $pipe_width}),";
    $add_signals .= "e_signal->new({name => txdatak$i\_ext, width=> $pipe_kwidth}),";
    $add_signals .= "e_signal->new({name => powerdown$i\_ext, width=> 2}),";
    $add_signals .= "e_signal->new({name => txdetectrx$i\_ext}),";
    $add_signals .= "e_signal->new({name => txcompl$i\_ext}),";
    $add_signals .= "e_signal->new({name => rxpolarity$i\_ext}),";
    $add_signals .= "e_signal->new({name => txelecidle$i\_ext}),";


}


##################################################
# Root Port  Serdes connections
##################################################

# default connections
my $rp_serdes_out = " ";
my $rp_serdes_in = "pipe_mode => pipe_mode,";
my $i;


if ($rp == 0) {
    $RP_LANES = 8;
} else {
    $RP_LANES = $number_of_lanes;
}

for ($i = 0; $i < $RP_LANES; $i++) {
    if (($phy_selection == 0) || ($phy_selection == 2)  || ($phy_selection == 6) || ($phy_selection == 7)) { # needs serdes connection
   if ($i >= $number_of_lanes) {
       $add_signals .= "e_signal->new({name => open_rp_tx_out$i, never_export => 1}),";
       $rp_serdes_out .= "tx_out$i => open_rp_tx_out$i,";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_rx_in$i }, rhs => \"1\"}),";
       $rp_serdes_in .= "rx_in$i =>  gnd_rp_rx_in$i,";
   } else {
       $rp_serdes_out .= "tx_out$i => rp_tx_out$i,";
       $rp_serdes_in .= "rx_in$i => rp_rx_in$i,";
   }
    } elsif ($phy_selection == 1) { # 16 bit pipe mode
   $add_signals .= "e_signal->new({name => open_rp_tx_out$i, never_export => 1}),";
   $rp_serdes_out .= "tx_out$i => open_rp_tx_out$i,";
   $add_signals .= "e_assign->new({lhs => {name => gnd_rp_rx_in$i }, rhs => \"1'b0\"}),";
   $rp_serdes_in .= "rx_in$i =>  gnd_rp_rx_in$i,";
    } elsif (($phy_selection == 3) || ($phy_selection == 4))  { # 8 bit pipe mode
   $add_signals .= "e_signal->new({name => open_rp_tx_out$i, never_export => 1}),";
   $rp_serdes_out .= "tx_out$i => open_rp_tx_out$i,";
   $add_signals .= "e_assign->new({lhs => {name => gnd_rp_rx_in$i }, rhs => \"1'b0\"}),";
   $rp_serdes_in .= "rx_in$i =>  gnd_rp_rx_in$i,";
    }
}

##################################################
# Root Port PIPE signals
# connect everything to PIPE_PHY
##################################################

my $rp_pipe_connect_in = " ";
my $rp_pipe_connect_out = " ";
my $rp_pipe_open = " ";


for ($i = 0; $i < $RP_LANES;  $i++) {

   $rp_pipe_connect_in .= "rxdata$i\_ext => rp_rxdata$i\_ext,";
   $rp_pipe_connect_in .= "rxdatak$i\_ext => rp_rxdatak$i\_ext,";
   $rp_pipe_connect_in .= "rxvalid$i\_ext => rp_rxvalid$i\_ext,";

   if ($rp == 0) { # RP BFM
       $rp_pipe_connect_in .= "phystatus$i\_ext => rp_phystatus$i\_ext,";
       $rp_pipe_connect_out .= "txdetectrx$i\_ext => rp_txdetectrx$i\_ext,";
       $rp_pipe_connect_out .= "powerdown$i\_ext => rp_powerdown$i\_ext,";
   } else { # real RP
       $rp_pipe_connect_in .= "phystatus_ext => rp_phystatus0_ext,";
       $rp_pipe_connect_out .= "txdetectrx_ext => rp_txdetectrx0_ext,";
       $rp_pipe_connect_out .= "powerdown_ext => rp_powerdown0_ext,";
       if ($i != 0) {
      $glue_logic .= "e_assign->new([rp_txdetectrx$i\_ext  => rp_txdetectrx0_ext]),";
      $glue_logic .= "e_assign->new([rp_powerdown$i\_ext  => rp_powerdown0_ext]),";
       }


   }


   $rp_pipe_connect_in .= "rxelecidle$i\_ext => rp_rxelecidle$i\_ext,";
   $rp_pipe_connect_in .= "rxstatus$i\_ext => rp_rxstatus$i\_ext,";

   $add_signals .= "e_signal->new({name => rp_rxdata$i\_ext, width=> $RP_PIPE_WIDTH, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_rxdatak$i\_ext, width=> $RP_KPIPE_WIDTH, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_rxstatus$i\_ext, width=> 3, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_rxvalid$i\_ext,never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_phystatus$i\_ext,never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_rxelecidle$i\_ext,never_export => 1}),";

   $rp_pipe_connect_out .= "txdata$i\_ext => rp_txdata$i\_ext,";
   $rp_pipe_connect_out .= "txdatak$i\_ext => rp_txdatak$i\_ext,";
   $rp_pipe_connect_out .= "txelecidle$i\_ext => rp_txelecidle$i\_ext,";
   $rp_pipe_connect_out .= "txcompl$i\_ext => rp_txcompl$i\_ext,";
   $rp_pipe_connect_out .= "rxpolarity$i\_ext => rp_rxpolarity$i\_ext,";

   $add_signals .= "e_signal->new({name => rp_txdata$i\_ext, width=> $RP_PIPE_WIDTH, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_txdatak$i\_ext, width=>  $RP_KPIPE_WIDTH, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_powerdown$i\_ext, width=> 2, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_txdetectrx$i\_ext, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_txcompl$i\_ext, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_rxpolarity$i\_ext, never_export => 1}),";
   $add_signals .= "e_signal->new({name => rp_txelecidle$i\_ext, never_export => 1}),";


}


if ($rp > 0) {
    $rp_pipe_connect_out .= "rate_ext => rp_rate,";
}


##################################################
# hookup phy reset
##################################################
if (($phy_selection == 1) | ($phy_selection == 3) | ($phy_selection == 4)) {
    $serdes_out .= "pipe_rstn => open_pipe_rstn,";
    $add_signals .= "e_signal->new({name => open_pipe_rstn,never_export => 1}),";

}


##################################################
# hook up txclk
##################################################

if ($pipe_txclk) {
    if ($number_of_lanes == 8) {
   $serdes_out .= "pipe_txclk1 => open_pipe_txclk1,";
   $add_signals .= "e_signal->new({name => open_pipe_txclk1,never_export => 1}),";
    }
    $serdes_out .= "pipe_txclk => open_pipe_txclk,";
    $add_signals .= "e_signal->new({name => open_pipe_txclk,never_export => 1}),";
}

##################################################
# Dual Phy support
##################################################
my $dual_phy_in = " ";
if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) {
    $dual_phy_in .= "phy1_pclk => refclk,";
    $dual_phy_in .= "phy1_phystatus_ext  => phystatus4_ext,";
}


##################################################
# drive reconfig_clk
##################################################
my $sopc_builder = (($tl_selection >= 1) && ($tl_selection <= 5))?1:0;

if (($phy_selection == 6) && ($sopc_builder==1)) {

    $glue_logic .= "e_process->new({
comment => \"Div down 100Mhz refclk with T-Flop\",
clock => \"refclk\",
reset => \"pcie_rstn\",
asynchronous_contents => [
e_assign->new([\"reconfig_clk\" => 0]),
],
user_attributes_names => [\"reconfig_clk\"],
user_attributes => [
    {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => ['R102'],
     },
  ],
contents => [
e_assign->new([\"reconfig_clk\" => \"~reconfig_clk\"]),
],

}),";

    $serdes_in .= "reconfig_clk => \"reconfig_clk\",";
}



##################################################
# Instantiate reference design
##################################################
my $ep_inst;
my $label = " ";

if (($tl_selection == 0) | ($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) {
   if ($rp == 0) {
      my $free_100MHz=(($hip==1) | ($phy_selection == 6))?  'free_100MHz => "refclk",':'';
      $ep_inst = e_blind_instance->new({
         name => "ep",
         module => "$var\_example_$pipen1b",
         in_port_map => {
            refclk => "refclk",
            local_rstn => "local_rstn",
            pcie_rstn => "pcie_rstn",
            eval($clk_in),
            eval($free_100MHz),
            test_in => "test_in",
            eval($serdes_in),
            eval($pipe_connect_in),
            eval($dual_phy_in),
         },
         out_port_map => {
            eval($clk_out),
            phy_sel_code => "phy_sel_code",
            ref_clk_sel_code => "ref_clk_sel_code",
            lane_width_code => "lane_width_code",

            eval($serdes_out),
            eval($pipe_connect_out),

            $test_out => "test_out",
         },
      });
   } else {
      my $free_100MHz=($hip==1)?  'free_100MHz => "refclk_ep",':'';
      $rp_inst = e_blind_instance->new({
               name => "rp",
               module => "$var\_example_$pipen1b",
               in_port_map => {
                  refclk => "refclk_ep",
                  eval($free_100MHz),
                  local_rstn => "local_rstn",
                  pcie_rstn => "rp_rstn",
                  eval($rp_clk_in),
                  test_in => "rp_test_in",
                  eval($rp_serdes_in),
                  eval($rp_pipe_connect_in),
                },
               out_port_map => {
                  eval($rp_clk_out),
                  phy_sel_code => "phy_sel_code",
                  ref_clk_sel_code => "ref_clk_sel_code_ep",
                  lane_width_code => "lane_width_code",
                  eval($rp_serdes_out),
                  eval($rp_pipe_connect_out),
                  $test_out => "rp_test_out",
               },
      });

      if ($refclk_selection == 0) { # 100Mhz
          $glue_logic .= "e_assign->new([refclk_ep => refclk]),";
      } else { # 125Mhz
          $label = "rp_pll";
          @inst_list = (@inst_list,$label);
          $$label = e_blind_instance->new({
            module => "altpcie_pll_100_125",
            name => "refclk_to_125mhz",
            in_port_map => {
                areset => "1'b0",
                inclk0 => "refclk",
            },
            out_port_map => {
                c0 => "refclk_ep",
            },
         });
      }

   }
} else { # SOPC mode
    $glue_logic .= "e_port->new([ clk125_out => 1 => \"input\"]),";
    $glue_logic .= "e_port->new([ clk125_in => 1 => \"output\"]),";
    $glue_logic .= "e_assign->new([clk125_in => ep_clk_in]),";
    $add_signals .= "e_signal->new({name => local_rstn, never_export => 1}),";
    $add_signals .= "e_signal->new({name => pcie_rstn}),";
    $glue_logic .= "e_port->new([ pipe_mode => 1 => \"output\"]),";
    $glue_logic .= "e_assign->new([ref_clk_sel_code => $refclk_selection]),";
    $glue_logic .= "e_assign->new([phy_sel_code => $phy_selection ]),";
    # tailor inout ports
    $glue_logic .= "e_port->new([ pcie_rstn => 1 => \"output\"]),";
    $glue_logic .= "e_port->new([ powerdown_ext => 2 => \"input\"]),";
    $glue_logic .= "e_port->new([ phystatus_ext => 1 => \"output\"]),";
    $glue_logic .= "e_port->new([ txdetectrx_ext => 1 => \"input\"]),";
    $glue_logic .= "e_assign->new([powerdown0_ext => powerdown_ext]),";
    $glue_logic .= "e_assign->new([txdetectrx0_ext  => txdetectrx_ext]),";
    $glue_logic .= "e_assign->new([phystatus_ext => phystatus0_ext]),";

   if ($sopc_builder==1) {
      $glue_logic .= "e_port->new([ busy_altgxb_reconfig => 1 => \"output\"]),";
      $glue_logic .= "e_assign->new({lhs => \"busy_altgxb_reconfig\", rhs => \"0\"}),";
      $glue_logic .= "e_port->new([ fixedclk_serdes => 1 => \"output\"]),";
      $glue_logic .= "e_assign->new([fixedclk_serdes => ep_clk_in]),";
   }

    if ($phy_selection == 2) {
   $glue_logic .= "e_assign->new([cal_blk_clk => ep_clk_out]),";
   $glue_logic .= "e_assign->new([reconfig_clk => \"1'b0\"]),";
   $glue_logic .= "e_port->new([ reconfig_togxb => 3 => \"output\"]),";
   $glue_logic .= "e_assign->new([reconfig_togxb => \"3'b010\"]),";
   $glue_logic .= "e_port->new([ reconfig_fromgxb => 1 => \"input\"]),";
   $glue_logic .= "e_port->new([ gxb_powerdown => 1 => \"output\"]),";
   $glue_logic .= "e_assign->new({lhs => \"gxb_powerdown\", rhs => \"~pcie_rstn\"}),";
    } elsif ($phy_selection == 6) {
   $glue_logic .= "e_assign->new([cal_blk_clk => ep_clk_out]),";
   $glue_logic .= "e_port->new([ reconfig_togxb => 4 => \"output\"]),";
   $glue_logic .= "e_port->new([ reconfig_clk => 1 => \"output\"]),";
   $glue_logic .= "e_port->new([ refclk => 1 => \"output\"]),";
   $glue_logic .= "e_assign->new([reconfig_togxb => \"4'b0010\"]),";
   if ($c3gx == 1) {
       $glue_logic .= "e_port->new([ reconfig_fromgxb => 5 => \"input\"]),";
   } else {
       $glue_logic .= "e_port->new([ reconfig_fromgxb => 17 => \"input\"]),";
   }
   $glue_logic .= "e_port->new([ gxb_powerdown => 1 => \"output\"]),";
   $glue_logic .= "e_assign->new({lhs => \"gxb_powerdown\", rhs => \"~pcie_rstn\"}),";
   $glue_logic .= "e_port->new([ pll_powerdown => 1 => \"output\"]),";
   $glue_logic .= "e_assign->new({lhs => \"pll_powerdown\", rhs => \"~pcie_rstn\"}),";
   if ($hip == 1) {
       $glue_logic .= "e_assign->new([ep_clk250_out => clk250_out]),";
       $glue_logic .= "e_assign->new([ep_clk500_out => clk500_out]),";
   }
    } elsif ($phy_selection != 0) {
   if ($pipe_txclk) {
       $glue_logic .= "e_port->new([ pipe_txclk => 1 => \"input\"]),";
   }
   $glue_logic .= "e_port->new([ pipe_rstn => 1 => \"input\"]),";
   $glue_logic .= "e_port->new([ xphy_pll_arest => 1 => \"output\"]),";
   $glue_logic .= "e_assign->new({lhs => \"xphy_pll_areset\", rhs => \"0\"}),";
    }

}

if ($hip == 0) { # SIP
    $glue_logic .= "e_assign->new([ ep_clk_in  => ep_clk_out]),";
    $glue_logic .= "e_assign->new([ rp_pclk  => clk250_out]),";

    if (($tl_selection >= 1) & ($tl_selection <= 5)) { # SOPC mode
   $glue_logic .= "e_assign->new([ep_clk_out => clk125_out]),";
    }

} else { # HIP

    if (($tl_selection >= 1) & ($tl_selection <= 5)) { # SOPC mode
   $glue_logic .= "e_assign->new([ ep_core_clk_out => 0 ]),";
   $glue_logic .= "e_assign->new([ ep_clk_in  => clk125_out]),";
   $glue_logic  .= "e_assign->new({lhs => \"rp_pclk\", rhs =>\"(rp_rate == 1) ?  ep_clk500_out : ep_clk250_out\"}),";
   $glue_logic  .= "e_assign->new({lhs => \"ep_clk_out\", rhs =>\"(rate_ext == 1) ?  ep_clk500_out : ep_clk250_out\"}),";

















    } else {
   $glue_logic .= "e_assign->new([ ep_pld_clk  => ep_core_clk_out]),";
   $glue_logic .= "e_assign->new([ ep_clk_out  => ep_pclk_in]),";
   if ($rp == 0) {
       $glue_logic  .= "e_assign->new({lhs => \"ep_pclk_in\", rhs =>\"(rate_ext == 1) ?  ep_clk500_out : ep_clk250_out\"}),";
       $glue_logic  .= "e_assign->new({lhs => \"rp_pclk\", rhs =>\"(rp_rate == 1) ?  ep_clk500_out : ep_clk250_out\"}),";
   } else {
       $glue_logic  .= "e_assign->new({lhs => \"ep_pclk_in\", rhs =>\"(rate_ext == 1) ?  rp_clk500_out : rp_clk250_out\"}),";
       $glue_logic  .= "e_assign->new({lhs => \"rp_pclk\", rhs =>\"(rp_rate == 1) ?  rp_clk500_out : rp_clk250_out\"}),";
       $glue_logic .= "e_assign->new([ rp_pld_clk  => rp_core_clk_out]),";
       $add_signals .= "e_signal->new({name => ep_clk250_out, never_export => 1}),";
       $add_signals .= "e_signal->new({name => ep_clk500_out, never_export => 1}),";
   }
    }
}

##################################################
# Instantiate Root Port  application
##################################################
$add_signals .= "e_signal->new({name => swdn_out, width=> 6, never_export => 1}),";

if ($rp == 0) {
    $rp_inst = e_blind_instance->new({
   name => "rp",
   module => "altpcietb_bfm_rp_top_x8_pipen1b",
   in_port_map => {
       local_rstn => "local_rstn",
       pcie_rstn => "rp_rstn",

       clk250_in => "$rp_clk250_in",
       clk500_in => "$rp_clk500_in",
       test_in => "rp_test_in",


       eval($rp_serdes_in),
       eval($rp_pipe_connect_in),

   },
   out_port_map => {
       eval($rp_serdes_out),
       eval($rp_pipe_connect_out),

       swdn_out => "swdn_out",
       test_out => "rp_test_out",
       rate_ext => "rp_rate",
   },

    });
} else {
    $ep_inst = e_blind_instance->new({
   name => "ep",
   module => "altpcietb_bfm_ep_example_chaining_pipen1b",
       in_port_map => {
      refclk => "refclk",
      local_rstn => "local_rstn",
      pcie_rstn => "pcie_rstn",

      eval($clk_in),
      test_in => "test_in",

      eval($serdes_in),
      eval($pipe_connect_in),

       },
       out_port_map => {
      eval($clk_out),
      ref_clk_sel_code => "ref_clk_sel_code",
      lane_width_code => "lane_width_code",

      eval($serdes_out),
      eval($pipe_connect_out),

      $test_out => "test_out",
       },


    });
}


##################################################
# Instantiate BFM driver
##################################################
my $drv_inst = e_blind_instance->new({
    name => "drvr",
    module => "altpcietb_bfm_$driver",
    in_port_map => {
         clk_in => "rp_pclk",
         rstn => "pcie_rstn",
         INTA => "swdn_out[0]",
         INTB => "swdn_out[1]",
         INTC => "swdn_out[2]",
         INTD => "swdn_out[3]",
    },
    out_port_map => {
        dummy_out => "dummy_out",
    },
    parameter_map => {
         TEST_LEVEL => 1, # fix me
    },

});

##################################################
# Instantiate common modules for verilog
##################################################
@common_list = ("bfm_log_common","bfm_req_intf_common","bfm_shmem_common");

foreach $common (@common_list) {
    @inst_list = (@inst_list,$common);
    $add_signals .= "e_signal->new({name => $common\_dummy_out, never_export => 1}),";
    $$common = e_blind_instance->new({
   name => $common,
   module => "altpcietb_$common",
   out_port_map => {
       dummy_out => "$common\_dummy_out",
   },

    });
}

##################################################
# Instantiate LTSSM monitor
##################################################

$add_signals .= "e_signal->new({name => ltssm_dummy_out, never_export => 1}),";
$add_signals .= "e_signal->new({name => ep_ltssm, width=> 5, never_export => 1}),";
$add_signals .= "e_signal->new({name => rp_ltssm, width=> 5, never_export => 1}),";
if (($number_of_lanes < 8) & ($tl_selection > 0) & ($tl_selection < 6)) { # SOPC mode
    if ($test_out_width == 512 ) {
   $add_signals .= "e_assign->new({lhs => {name =>  ep_ltssm }, rhs => \"test_out[324:320]\"}),";
    } elsif ($test_out_width == 9) {
   $add_signals .= "e_assign->new({lhs => {name =>  ep_ltssm }, rhs => \"test_out[4:0]\"}),";
    } elsif ($test_out_width == 64) { # HIP mode
   $add_signals .= "e_assign->new({lhs => {name =>  ep_ltssm }, rhs => \"test_out[63:59]\"}),";
    } else {
   $add_signals .= "e_assign->new({lhs => {name =>  ep_ltssm }, rhs => \"0\"}),";
    }
} else {
    $add_signals .= "e_assign->new({lhs => {name =>  ep_ltssm }, rhs => \"test_out[4:0]\"}),";
}


if ($rp == 0) {
    $add_signals .= "e_assign->new({lhs => {name =>  rp_ltssm }, rhs => \"rp_test_out[324:320]\"}),";
} else {
    $add_signals .= "e_assign->new({lhs => {name =>  rp_ltssm }, rhs => \"rp_test_out[4:0]\"}),";
}

$ltssm_inst = e_blind_instance->new({
    name => ltssm_mon,
    module => "altpcietb_ltssm_mon",
    in_port_map => {
   rp_clk => "rp_pclk",
   rstn => "pcie_rstn",
   rp_ltssm => "rp_ltssm",
   ep_ltssm => "ep_ltssm",
    },

    out_port_map => {
   dummy_out => "ltssm_dummy_out",
    },

});



##################################################
# glue logic
##################################################
for ($i = 0; $i < 8; $i++) {
    $label = "lane$i";
    @inst_list = (@inst_list,$label);
    if ($i < $number_of_lanes) {
   if (($phy_selection == 0) || ($phy_selection == 2) || ($phy_selection == 6)  || ($phy_selection == 7)) {
       $glue_logic  .= "e_assign->new({lhs => \"rx_in$i\", rhs =>\"(connected_bits[$i] == 1'b1) ?  rp_tx_out$i : 1\"}),";
       $glue_logic .= "e_assign->new([ rp_rx_in$i  => tx_out$i]),";
   }


   $$label = e_blind_instance->new({
       name => "$label",
       module => "altpcietb_pipe_phy",
       parameter_map => {APIPE_WIDTH => $pipe_width, BPIPE_WIDTH => $RP_PIPE_WIDTH, LANE_NUM => $i},
       in_port_map => {
      pclk_a => "ep_clk_out",
      pclk_b => "rp_pclk",
      resetn => "pcie_rstn",
      pipe_mode => "pipe_mode",
      A_lane_conn => "connected_bits[$i]",
      B_lane_conn => "1'b1",

      A_txdata => "txdata$i\_ext",
      A_txdatak => "txdatak$i\_ext",
      A_txdetectrx => "txdetectrx$i\_ext",
      A_txelecidle => "txelecidle$i\_ext",
      A_txcompl => "txcompl$i\_ext",
      A_rxpolarity => "rxpolarity$i\_ext",
      A_powerdown => "powerdown$i\_ext",
      A_rate => "$ep_rate",

      B_txdata => "rp_txdata$i\_ext",
      B_txdatak => "rp_txdatak$i\_ext",
      B_txdetectrx => "rp_txdetectrx$i\_ext",
      B_txelecidle => "rp_txelecidle$i\_ext",
      B_txcompl => "rp_txcompl$i\_ext",
      B_rxpolarity => "rp_rxpolarity$i\_ext",
      B_powerdown => "rp_powerdown$i\_ext",
      B_rate => "rp_rate",


       },
       out_port_map => {


      A_rxdata => "rxdata$i\_ext",
      A_rxdatak => "rxdatak$i\_ext",
      A_rxvalid => "rxvalid$i\_ext",
      A_phystatus => "phystatus$i\_ext",
      A_rxelecidle => "rxelecidle$i\_ext",
      A_rxstatus => "rxstatus$i\_ext",

      B_rxdata => "rp_rxdata$i\_ext",
      B_rxdatak => "rp_rxdatak$i\_ext",
      B_rxvalid => "rp_rxvalid$i\_ext",
      B_phystatus => "rp_phystatus$i\_ext",
      B_rxelecidle => "rp_rxelecidle$i\_ext",
      B_rxstatus => "rp_rxstatus$i\_ext",

       },
       std_logic_vector_signals => ['A_rxdatak', 'A_txdatak', 'B_rxdatak', 'B_txdatak'],
   });
    } else {

   if ($rp == 0) {
       $add_signals .= "e_signal->new({name => open_rxdata$i\_ext, width => $pipe_width, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rxdatak$i\_ext, width => $pipe_kwidth, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rxvalid$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_phystatus$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rxelecidle$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rxstatus$i\_ext, width => 3, never_export => 1}),";


       $add_signals .= "e_assign->new({lhs => {name => gnd_txdata$i\_ext, width=> $pipe_width}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_txdatak$i\_ext, width=> $pipe_kwidth}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_txdetectrx$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_txelecidle$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rxpolarity$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_txcompl$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_powerdown$i\_ext, width=> 2}, rhs => \"0\"}),";

   $$label = e_blind_instance->new({
       name => "$label",
       module => "altpcietb_pipe_phy",
       parameter_map => {APIPE_WIDTH => $pipe_width, BPIPE_WIDTH => $RP_PIPE_WIDTH, LANE_NUM => $i},
       in_port_map => {
      pclk_a => "ep_clk_out",
      pclk_b => "rp_pclk",
      resetn => "pcie_rstn",
      pipe_mode => "pipe_mode",
      A_lane_conn => "1'b0",
      B_lane_conn => "1'b1",


      A_txdata => "gnd_txdata$i\_ext",
      A_txdatak => "gnd_txdatak$i\_ext",
      A_txdetectrx => "gnd_txdetectrx$i\_ext",
      A_txelecidle => "gnd_txelecidle$i\_ext",
      A_txcompl => "gnd_txcompl$i\_ext",
      A_rxpolarity => "gnd_rxpolarity$i\_ext",
      A_powerdown => "gnd_powerdown$i\_ext",
      A_rate => "$ep_rate",

      B_txdata => "rp_txdata$i\_ext",
      B_txdatak => "rp_txdatak$i\_ext",
      B_txdetectrx => "rp_txdetectrx$i\_ext",
      B_txelecidle => "rp_txelecidle$i\_ext",
      B_txcompl => "rp_txcompl$i\_ext",
      B_rxpolarity => "rp_rxpolarity$i\_ext",
      B_powerdown => "rp_powerdown$i\_ext",
      B_rate => "rp_rate",



       },
       out_port_map => {


      A_rxdata => "open_rxdata$i\_ext",
      A_rxdatak => "open_rxdatak$i\_ext",
      A_rxvalid => "open_rxvalid$i\_ext",
      A_phystatus => "open_phystatus$i\_ext",
      A_rxelecidle => "open_rxelecidle$i\_ext",
      A_rxstatus => "open_rxstatus$i\_ext",

      B_rxdata => "rp_rxdata$i\_ext",
      B_rxdatak => "rp_rxdatak$i\_ext",
      B_rxvalid => "rp_rxvalid$i\_ext",
      B_phystatus => "rp_phystatus$i\_ext",
      B_rxelecidle => "rp_rxelecidle$i\_ext",
      B_rxstatus => "rp_rxstatus$i\_ext",

       },
       std_logic_vector_signals => ['A_rxdatak', 'A_txdatak', 'B_rxdatak', 'B_txdatak'],
   });


   } else {

       $add_signals .= "e_signal->new({name => open_rp_rxdata$i\_ext, width => $pipe_width, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rp_rxdatak$i\_ext, width => $pipe_kwidth, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rp_rxvalid$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rp_phystatus$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rp_rxelecidle$i\_ext, never_export => 1}),";
       $add_signals .= "e_signal->new({name => open_rp_rxstatus$i\_ext, width => 3, never_export => 1}),";


       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_txdata$i\_ext, width=> $pipe_width}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_txdatak$i\_ext, width=> $pipe_kwidth}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_txdetectrx$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_txelecidle$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_rxpolarity$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_txcompl$i\_ext}, rhs => \"0\"}),";
       $add_signals .= "e_assign->new({lhs => {name => gnd_rp_powerdown$i\_ext, width=> 2}, rhs => \"2\"}),";

       $$label = e_blind_instance->new({
      name => "$label",
      module => "altpcietb_pipe_phy",
      parameter_map => {APIPE_WIDTH => $pipe_width, BPIPE_WIDTH => $RP_PIPE_WIDTH, LANE_NUM => $i},
      in_port_map => {
          pclk_a => "ep_clk_out",
          pclk_b => "rp_pclk",
          resetn => "pcie_rstn",
          pipe_mode => "pipe_mode",
          A_lane_conn => "1'b1",
          B_lane_conn => "1'b0",


          A_txdata => "txdata$i\_ext",
          A_txdatak => "txdatak$i\_ext",
          A_txdetectrx => "txdetectrx$i\_ext",
          A_txelecidle => "txelecidle$i\_ext",
          A_txcompl => "txcompl$i\_ext",
          A_rxpolarity => "rxpolarity$i\_ext",
          A_powerdown => "powerdown$i\_ext",
          A_rate => "$ep_rate",

          B_txdata => "gnd_rp_txdata$i\_ext",
          B_txdatak => "gnd_rp_txdatak$i\_ext",
          B_txdetectrx => "gnd_rp_txdetectrx$i\_ext",
          B_txelecidle => "gnd_rp_txelecidle$i\_ext",
          B_txcompl => "gnd_rp_txcompl$i\_ext",
          B_rxpolarity => "gnd_rp_rxpolarity$i\_ext",
          B_powerdown => "gnd_rp_powerdown$i\_ext",
          B_rate => "rp_rate",



      },
      out_port_map => {


          A_rxdata => "rxdata$i\_ext",
          A_rxdatak => "rxdatak$i\_ext",
          A_rxvalid => "rxvalid$i\_ext",
          A_phystatus => "phystatus$i\_ext",
          A_rxelecidle => "rxelecidle$i\_ext",
          A_rxstatus => "rxstatus$i\_ext",

          B_rxdata => "open_rp_rxdata$i\_ext",
          B_rxdatak => "open_rp_rxdatak$i\_ext",
          B_rxvalid => "open_rp_rxvalid$i\_ext",
          B_phystatus => "open_rp_phystatus$i\_ext",
          B_rxelecidle => "open_rp_rxelecidle$i\_ext",
          B_rxstatus => "open_rp_rxstatus$i\_ext",

      },
      std_logic_vector_signals => ['A_rxdatak', 'A_txdatak', 'B_rxdatak', 'B_txdatak'],
       });


   }



    }

}

$glue_logic  .= "e_assign->new([\"local_rstn\" => 1]),";
if ($hip == 1) {
    $glue_logic  .= "e_assign->new([\"test_in[2:1]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"test_in[8:4]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"test_in[9]\" => 1]),";
    if ($phy_selection<7) {
      $glue_logic  .= "e_assign->new([\"test_in[39:10]\" => 0]),";
    } else {
      $glue_logic  .= "e_assign->new([\"test_in[31:10]\" => 0]),";
    }
} else {
    $glue_logic  .= "e_assign->new([\"test_in[2:1]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"test_in[31:4]\" => 0]),";
}

if ($phy_selection == 6) {
    $glue_logic  .= "e_assign->new({lhs => \"test_in[3]\", rhs => \"~pipe_mode\",
comment => \"Bit 3: Work around simulation Reciever Detect issue for Stratix IV GX\"}),";
} else {
    $glue_logic  .= "e_assign->new([\"test_in[3]\" => 0]),";
}

$glue_logic  .= "e_parameter_assign->new({lhs => \"test_in[0]\",
 rhs =>\"FAST_COUNTERS\",vhdl_conversion => std_logic,
comment => \"Bit 0: Speed up the simulation but making counters faster than normal\"}),";
$glue_logic  .= "e_parameter_assign->new({lhs => \"connected_lanes\",
 rhs =>\"NUM_CONNECTED_LANES\",vhdl_conversion => std_logic_vector,
comment => \"Compute number of lanes to hookup\"}),";
$glue_logic  .= "e_assign->new({lhs => \"connected_bits\",
 rhs =>\"connected_lanes[3] ? 8'hFF : connected_lanes[2] ? 8'h0F : connected_lanes[1] ? 8'h03 : 8'h01\"}),";
if ($rp == 0) {
    $glue_logic  .= "e_assign->new([\"rp_test_in[31:8]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[6]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[4]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[2:1]\" => 0]),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[0]\",
 rhs =>\"1\", comment => \"Bit 0: Speed up the simulation but making counters faster than normal\"}),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[3]\", rhs => \"~pipe_mode\",
comment => \"Bit 3: Forces all lanes to detect the receiver\n
For Stratix GX we must force but can use Rx Detect for\n
the generic PIPE interface\"}),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[5]\",
 rhs =>\"1\", comment => \"Bit 5: Disable polling.compliance\"}),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[7]\", rhs  => \"~pipe_mode\",
comment => \"Bit 7: Disable any entrance to low power link states (for Stratix GX)\n
For Stratix GX we must disable but can use Low Power for\n
the generic PIPE interface\"}),";
} else {

    $glue_logic  .= "e_assign->new([\"rp_test_in[2:1]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[4]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[8:6]\" => 0]),";
    $glue_logic  .= "e_assign->new([\"rp_test_in[9]\" => 1]),";
    if ($phy_selection<7) {
      $glue_logic  .= "e_assign->new([\"rp_test_in[39:10]\" => 0]),";
    } else {
      $glue_logic  .= "e_assign->new([\"rp_test_in[31:10]\" => 0]),";
    }

    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[0]\",
 rhs =>\"1\", comment => \"Bit 0: Speed up the simulation but making counters faster than normal\"}),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[3]\", rhs => \"~pipe_mode\",
comment => \"Bit 3: Forces all lanes to detect the receiver\n
For Stratix GX we must force but can use Rx Detect for\n
the generic PIPE interface\"}),";
    $glue_logic  .= "e_assign->new({lhs => \"rp_test_in[5]\",
 rhs =>\"1\", comment => \"Bit 5: Disable polling.compliance\"}),";
}

$glue_logic  .= "e_parameter_assign->new({lhs => \"pipe_mode_sig2\",
 rhs =>\"PIPE_MODE_SIM\",vhdl_conversion => std_logic,
comment => \"When the phy is Stratix GX we can allow the pipe_mode to be disabled \n
otherwise we need to force pipe_mode on\"}),";
$glue_logic  .= "e_assign->new({lhs => \"pipe_mode\",
 rhs =>\"((phy_sel_code == 4'h0) || (phy_sel_code == 4'h2) || (phy_sel_code == 4'h6) || (phy_sel_code == 4'h7)) ? pipe_mode_sig2 : 1'b1\"}),";



##################################################
# Instantiate step Up PLL
##################################################

if ($hip == 0) {
    if ($number_of_lanes != 8) {
   $label = "pll_inst";
   @inst_list = (@inst_list,$label);
   $$label = e_blind_instance->new({
       name => "stepup_pll",
       module => "altpcie_pll_125_250",
       in_port_map => {
      inclk0 => "ep_clk_out",
      areset => "1'b0",
       },
       out_port_map => {
      c0 => "clk250_out",
       },
   });
    } else {
   $glue_logic .= "e_assign->new([ clk250_out => ep_clk_out]),";
    }
} else { # HIP SOPC mode
    if (0) {
    if (($tl_selection >= 1) & ($tl_selection <= 5)) { # SOPC mode
   $label = "sim_pll";
   @inst_list = (@inst_list,$label);
   $$label = e_blind_instance->new({
       module => "altpcie_pll_125_250",
       name => "pll_125mhz_to_250mhz",
       tag => "simulation",
       in_port_map => {
      areset => "1'b0",
      inclk0 => "clk125_out",
       },
       out_port_map => {
      c0 => "ep_clk250_out",
       },

   });

   $label = "sim_pll_x2";
   @inst_list = (@inst_list,$label);
   $$label = e_blind_instance->new({
       module => "altpcie_pll_125_250",
       name => "pll_250mhz_to_500mhz",
       tag => "simulation",
       in_port_map => {
      areset => "1'b0",
      inclk0 => "ep_clk250_out",
       },
       out_port_map => {
      c0 => "ep_clk500_out",
       },

   });

   # SOPC Builder


    }
}
}


##################################################
# Instantiate Clock generator and Reset
##################################################
if ($hip == 1) {
    $ep_core_clk_out = "ep_core_clk_out";
} else {
    $ep_core_clk_out = "ep_clk_out";
}

$label = "rst_clk_inst";
@inst_list = (@inst_list,$label);
$$label = e_blind_instance->new({
    name => "rst_clk_gen",
    module => "altpcietb_rst_clk",
    in_port_map => {
      ref_clk_sel_code => "ref_clk_sel_code",
      ep_core_clk_out => "$ep_core_clk_out",
    },
    out_port_map => {
      ref_clk_out => "refclk",
      pcie_rstn => "pcie_rstn",
      rp_rstn => "rp_rstn",
    },
});

$top_mod->add_contents
(
 my $pipe_mode = e_parameter->new({name => "PIPE_MODE_SIM", default => "1'b1", vhdl_default => "\'1\'", vhdl_type => "std_logic"}),
 my $fast_counters = e_parameter->new({name => "FAST_COUNTERS", default => "1'b1", vhdl_default => "\'1\'", vhdl_type => "std_logic"}),
 my $num_connected_lanes = e_parameter->new({name => "NUM_CONNECTED_LANES", default => "8", vhdl_default => "\"1000\"", vhdl_type => "std_logic_vector"}),
 my $test_level = e_parameter->new({name => "TEST_LEVEL", default => "1", vhdl_type => "natural"}),



 eval($add_signals),
 eval($glue_logic),
 $rp_inst,
 $drv_inst,
 $ltssm_inst,



);

if (($tl_selection == 0) | ($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) {
    $top_mod->add_contents($ep_inst);
}

foreach $inst (@inst_list) {
    $top_mod->add_contents($$inst);
}


$proj->top($top_mod);
$proj->language($language);
$proj->output();

