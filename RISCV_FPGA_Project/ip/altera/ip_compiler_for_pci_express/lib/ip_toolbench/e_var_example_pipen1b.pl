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
my $temp = $command_hash{"phy"};
if($temp ne "")
{
	$phy_selection = $temp;	
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


	$tl_selection = $temp;	
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
} elsif ($phy_selection == 6) { # S4GX, A2GX, C4GX
} elsif ($phy_selection == 7) { # S5GX
} elsif ($phy_selection == 8) { # TLBP
} elsif ($phy_selection == 9) { # A2GZ
    # re-map it back to A2GX
    $phy_selection = 6;
}


# declare top module
my $comment_str = "simple";
my $pipen1b = "pipen1b";
my $comment_hdl = "Verilog HDL";

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

my $top_mod = e_module->new ({name => "$var\_example_$pipen1b", comment => "/** This $comment_hdl file is used for simulation and synthesis in $comment_str DMA design example\n* This file provides the top level wrapper file of the core and example applications\n*/"});


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
if ($hip == 0) {
    $clk_in = "$clkfreq_in => \"$clkfreq_in\",";
    $clk_out = "$clkfreq_out => \"$clkfreq_out\",";

    $clk_ports = "e_port->new([ $clkfreq_in => 1 => \"input\"]),";
    $clk_ports .= "e_port->new([ $clkfreq_out => 1 => \"output\"]),";

} else {

    # HIP 
    $clk_ports = "e_port->new([ free_100MHz => 1 => \"input\"]),";
    $clk_in = "pclk_in => \"pclk_in\",";
    $clk_in .= "pld_clk => \"pld_clk\",";
    if ($phy_selection != 7) { # not S5GX
	$clk_in .= "fixedclk_serdes => \"fixedclk_serdes\",";
	$clk_in .= "busy_altgxb_reconfig => \"busy_altgxb_reconfig\",";
    }
    $clk_out = "core_clk_out => \"core_clk_out\",";
    $clk_out .= "clk250_out => \"clk250_out\",";
    $clk_out .= "clk500_out => \"clk500_out\",";
}

##################################################
# reset input
##################################################
my $reset_in = " ";

if (($number_of_lanes == 8) & ($hip == 0)) {
    $reset_in .= "rstn => \"srstn\",";
} else {
    if (($tl_selection != 6) & ($tl_selection != 7) & ($tl_selection != 9)) {
	$reset_in .= "rstn => \"srstn\",";
    }

    if ($phy_selection == 7) { # S5GX
	$reset_in .= "pld_clrhip_n => \"crstn\",";
	$reset_in .= "pld_clrpmapcship => \"srst\",";
	$reset_in .= "pld_clk_ready => \"1'b1\",";
    } else {
	$reset_in .= "crst => \"crst\",";
	$reset_in .= "srst => \"srst\",";
    }
}


if ($rp == 0) {
    $npor = "npor";
} else {
    $npor = "pcie_rstn";
}

if ($phy_selection == 7) { # S5GX
    $reset_in .= "perst_n => \"$npor\",";
} else {
    $reset_in .= "npor => \"$npor\",";
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

if (($tl_selection == 6) | ($tl_selection == 7)) {
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
	if ($phy_selection == 7) { # S5GX
	    $pipe_interface .= "e_port->new([rate_ext => 2 => \"output\"]),";

	}
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
$add_signals .= "e_signal->new({name => dl_ltssm, width=> 5,never_export => 1}),";
$add_signals .= "e_signal->new({name => dl_ltssm_r, width=> 5,never_export => 1}),";
$add_signals .= "e_signal->new({name => lane_act, width=> 4,never_export => 1}),";
$add_signals .= "e_signal->new({name => gnd_bus, width=> 128,never_export => 1}),";

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

if ($simple_dma == 1) {
    $app_name = "altpcierd_example_app";
} else {
    $app_name = "altpcierd_example_app_chaining";
}

my $label = " ";
my %label;


$vcs_signals .= "e_signal->new({name => ko_cpl_spc_vc0, width=> 20, never_export => 1}),";
$vcs_signals .= "e_signal->new({name => tx_stream_cred0, width=> $txcred_width, never_export => 1}),";
$vcs_signals .= "e_signal->new({name => tx_stream_cred1, width=> $txcred_width, never_export => 1}),";
$vcs_signals .= "e_signal->new({name => tx_stream_data0, width=> 75}),";
$vcs_signals .= "e_signal->new({name => rx_stream_data0, width=> 82}),";
$vcs_signals .= "e_signal->new({name => msi_stream_data0, width=> 8}),";


if ($tl_selection == 0) { # Native PLDA interface ICM 7.1
    $vcs_connect_in .= "tx_stream_valid0 => tx_stream_valid0,";
    $vcs_connect_in .= "tx_stream_data0 => tx_stream_data0,";
    $vcs_connect_in .= "msi_stream_valid0 => msi_stream_valid0,";
    $vcs_connect_in .= "msi_stream_data0 => msi_stream_data0,";
    $vcs_connect_in .= "rx_stream_ready0 => rx_stream_ready0,";
    $vcs_connect_in .= "rx_stream_mask0 => rx_mask0,";
    $vcs_connect_in .= "cpl_pending_icm => cpl_pending_icm,";


    $vcs_connect_out .= "tx_stream_ready0 => tx_stream_ready0,";
    $vcs_connect_out .= "msi_stream_ready0 => msi_stream_ready0,";
    $vcs_connect_out .= "rx_stream_valid0 => rx_stream_valid0,";
    $vcs_connect_out .= "rx_stream_data0 => rx_stream_data0,";
    $vcs_connect_out .= "tx_stream_mask0 => tx_stream_mask0,";
    $vcs_connect_out .= "tx_stream_cred0 => tx_stream_cred0,";
} elsif (($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9))  { # HIPCAB

    my $be_width = 8;
    my $data_width = 8;

    if ($tl_selection == 7) { # 128 bit mode
	$data_width = 128;
	$be_width = 16;
    } elsif ($tl_selection == 9) { # 256 bit mode unbonded
	$data_width = 256;
	$be_width = 32;
    } else {
	$data_width = 64;
	$be_width = 8;
    }
    

    if ($rp == 2) { # endpoint / root port mode
	$vcs_connect_in .= "mode => \"2'b10\",";
    }

    for ($i = 0; $i < $number_of_vcs; $i++) {
	if (($i == 0) | ($rp > 0)) {
	    $vcs_connect_in .= "rx_st_ready$i => rx_stream_ready$i,";
	    $vcs_connect_out .= "rx_st_valid$i => rx_stream_valid$i,";

	    if (($rp > 0) | ($tl_selection == 7)) {
		$vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 128}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 128}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 128}),";
		$vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 16}),";
		if ($phy_selection == 7) {
		    $vcs_connect_in  .= "tx_st_parity$i  => \"16'h0000\",";                    
		}

	    } elsif ($tl_selection == 9) { # 256 bit unbonded
		$vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 256}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 256}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 256}),";
		$vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 32}),";
		if ($phy_selection == 7) {
		    $vcs_connect_in  .= "tx_st_parity$i  => \"32'h00000000\",";                    
		}
	    } else {
		$vcs_signals .= "e_signal->new({name => rx_st_data$i, width=> 64}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i, width=> 64}),";
		$vcs_signals .= "e_signal->new({name => tx_st_data$i\_r, width=> 64}),";
		$vcs_signals .= "e_signal->new({name => rx_st_be$i, width=> 8}),";
		if ($phy_selection == 7) {
		    $vcs_connect_in  .= "tx_st_parity$i  => \"8'h00\",";                    
		}
	    }


	    if ($tl_selection == 7) { # 128 bit mode
		$vcs_connect_out .= "rx_st_empty$i => rx_st_empty$i,";
		$vcs_connect_in .= "tx_st_empty$i => tx_st_empty$i,";
		$vcs_connect_out .= "rx_st_data$i => rx_st_data$i,";
		$vcs_connect_out .= "rx_st_be$i => rx_st_be$i,";
		$vcs_connect_in .= "tx_st_data$i => tx_st_data$i,";
	    } elsif ($tl_selection == 9) { # 256 bit unbonded
		$vcs_signals .= "e_signal->new({name => rx_st_empty$i, width=> 2}),";
		$vcs_connect_out .= "rx_st_empty$i => rx_st_empty$i,";
		$vcs_signals .= "e_signal->new({name => tx_st_empty$i, width=> 2}),";
		$vcs_connect_in .= "tx_st_empty$i => tx_st_empty$i,";
		$vcs_connect_out .= "rx_st_data$i => rx_st_data$i,";
		$vcs_connect_out .= "rx_st_be$i => rx_st_be$i,";
		$vcs_connect_in .= "tx_st_data$i => tx_st_data$i,";
	    } else {
		$vcs_connect_out .= "rx_st_data$i => \"rx_st_data$i\[63:0]\",";
		$vcs_connect_out .= "rx_st_be$i => \"rx_st_be$i\[7:0]\",";
		$vcs_connect_in .= "tx_st_data$i => \"tx_st_data$i\[63:0]\",";
	    }



	    $vcs_connect_in .= "rx_st_mask$i => rx_mask$i,";
	    $vcs_signals .= "e_signal->new({name => rx_st_bardec$i, width=> 8, never_export => 1}),";
	    $vcs_connect_out .= "rx_st_bardec$i => rx_st_bardec$i,";
	    $vcs_connect_out .= "rx_st_sop$i => rx_st_sop$i,";
	    $vcs_connect_out .= "rx_st_eop$i => rx_st_eop$i,";
	    $vcs_connect_in .= "tx_st_sop$i => tx_st_sop$i,";
	    $vcs_connect_in .= "tx_st_eop$i => tx_st_eop$i,";
	    $add_signals .= "e_signal->new({name => gnd_tx_st_err$i ,  never_export => 1}),";
	    $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_st_err$i , width => 1}, rhs => \"1'b0\"}),";
	    $vcs_connect_in .= "tx_st_err$i => gnd_tx_st_err$i,";
	    $vcs_connect_in .= "tx_st_valid$i => tx_stream_valid$i,";
	    $vcs_connect_out .= "tx_st_ready$i => tx_stream_ready$i,";
	    if ($phy_selection == 7) {
	    } else { # S4GX, A2GX, C4GX
		$vcs_connect_out .= "tx_cred$i => tx_stream_cred$i,";
	    } 

	} else {
	    $add_signals .= "e_signal->new({name => gnd_rx_st_ready$i ,  never_export => 1}),";
	    $vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_st_ready$i , width => 1}, rhs => \"1'b0\"}),";
	    $vcs_connect_in .= "rx_st_ready$i => gnd_rx_st_ready$i,";

	    $add_signals .= "e_signal->new({name => open_rx_st_valid$i ,  never_export => 1}),";
	    $vcs_connect_out .= "rx_st_valid$i => open_rx_st_valid$i,";

	    if ($tl_selection == 7) { # 128 bit mode
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


	# App credit management
	if ($phy_selection == 7) {
	    
	} else {
	    $add_signals .= "e_signal->new({name => open_tx_fifo_wrptr$i ,  width => 4 , never_export => 1}),";
	    $vcs_connect_out .= "tx_fifo_wrptr$i => open_tx_fifo_wrptr$i,";
	    $add_signals .= "e_signal->new({name => open_tx_fifo_rdptr$i ,  width => 4 , never_export => 1}),";
	    $vcs_connect_out .= "tx_fifo_rdptr$i => open_tx_fifo_rdptr$i,";
	    $add_signals .= "e_signal->new({name => open_rx_fifo_full$i ,  never_export => 1}),";
	    $vcs_connect_out .= "rx_fifo_full$i => open_rx_fifo_full$i,";
	    
	    $add_signals .= "e_signal->new({name => open_rx_fifo_empty$i ,  never_export => 1}),";
	    $vcs_connect_out .= "rx_fifo_empty$i => open_rx_fifo_empty$i,";

	    $add_signals .= "e_signal->new({name => open_tx_fifo_full$i ,  never_export => 1}),";
	    $vcs_connect_out .= "tx_fifo_full$i => open_tx_fifo_full$i,";
	    
	    
	    
	    if (($rp == 0) & ($simple_dma == 1)) {
		$add_signals .= "e_signal->new({name => open_tx_fifo_empty$i ,  never_export => 1}),";
		$vcs_connect_out .= "tx_fifo_empty$i => open_tx_fifo_empty$i,";
	    } else {
		$vcs_connect_out .= "tx_fifo_empty$i => tx_fifo_empty$i,";
	    }
	}

	$add_signals .= "e_signal->new({name => open_rx_st_err$i ,  never_export => 1}),";
	$vcs_connect_out .= "rx_st_err$i => open_rx_st_err$i,";


	if (($i == 0) & ($number_of_lanes < 8) & ($hip == 0)) {

	    $add_signals .= "e_signal->new({name => gnd_err_desc_func0 ,  width => 128 , never_export => 1}),";
	    $vcs_signals .= "e_assign->new({lhs => {name => gnd_err_desc_func0 , width => 128}, rhs => \"1'b0\"}),";
	    $vcs_connect_in .= "err_desc_func0 => gnd_err_desc_func0,";

	}

	if ($hip == 1) {
	    $lmi_addr_wd = 12;

	    if ($simple_dma == 1) {
		if ($i == 0) {
		    $add_signals .= "e_signal->new({name => gnd_lmi_addr, width => $lmi_addr_wd ,never_export => 1}),";
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

		$add_signals .= "e_signal->new({name => lmi_addr_int, width => $lmi_addr_wd ,never_export => 1}),";
		$vcs_connect_in .= "lmi_addr => lmi_addr_int,";

		# lmi address bus for the driver
		$add_signals .= "e_signal->new({name => lmi_addr, width => 12 ,never_export => 1}),";
		if ($phy_selection == 7) {
		    $glue_logic  .= "e_assign->new([\"lmi_addr_int[14:12]\" => 0]),";
		}
		$glue_logic  .= "e_assign->new([\"lmi_addr_int[11:0]\" => lmi_addr]),";

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
			    rstn => "srstn",
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
	    $add_signals .= "e_signal->new({name => gnd_hpg_ctrler, width => 5 ,never_export => 1}),";
	    $vcs_connect_in .= "hpg_ctrler => gnd_hpg_ctrler,";
	    $vcs_connect_in .= "pm_auxpwr => \"1'b0\",";
	    $add_signals .= "e_signal->new({name => gnd_pm_data, width => 10 ,never_export => 1}),";
	    $vcs_connect_in .= "pm_data => gnd_pm_data,";
	    if ($rp == 0) { # root port
		$vcs_connect_in .= "pm_event => \"1'b0\",";
	    }

	    if ($i == 0) {
		$glue_logic .= "e_assign->new({lhs => {name => gnd_hpg_ctrler}, rhs => \"0\"}),";
		$glue_logic .= "e_assign->new({lhs => {name => gnd_pm_data}, rhs => \"0\"}),";
	    }

	    # HIP debug port
	    $vcs_connect_out .= "ltssm => dl_ltssm,";
	    $vcs_connect_out .= "lane_act => lane_act,";
	 



   

	}
	

    }

}

# instantiate test out port
if (($test_out_width > 0) & (($tl_selection == 6) | ($tl_selection == 7))) {
    $vcs_connect_out .= "test_out => \"test_out_int\",";
}

# test_in width
if (($hip == 1) & ($phy_selection == 6)) { # S4GX, A2GX, C4GX
    $test_in_width = 40;
} else {
    $test_in_width = 32;
}

# hotrst exit
if ($phy_selection == 7) {
    $hotrst_exit = "reset_status => \"hotrst_exit_n\",";
    $glue_logic .= "e_assign->new({lhs => {name => hotrst_exit}, rhs => \"~hotrst_exit_n\"}),";

    # invertin crst
    $glue_logic .= "e_assign->new({lhs => {name => crstn}, rhs => \"~crst\"}),";

} else {
    $hotrst_exit = "hotrst_exit => \"hotrst_exit\",";
}

##################################################
# Apps VC interface
##################################################
my $app_vcs_connect_in = " ";
my $app_vcs_connect_out = " ";
my $app_vcs_open = " ";
my $app_vcs_signals = " ";

$app_vcs_connect_in .= "ko_cpl_spc_vc0 => ko_cpl_spc_vc0,";
$app_vcs_connect_in .= "tx_stream_ready0 => tx_stream_ready0,";
$app_vcs_connect_in .= "rx_stream_valid0 => rx_stream_valid0,";
if ($simple_dma == 1) {
    $app_vcs_connect_in .= "rx_stream_data0 => rx_stream_data0,";
} else {
    $app_vcs_connect_in .= "rx_stream_data0_0 => rx_stream_data0,";
    if ((($hip == 1) | ($tl_selection == 6)) & ($phy_selection < 7)) { # SIP Avalon ST or HIP and prior to S5GX
	$app_vcs_connect_in .= "tx_stream_fifo_empty0 => tx_fifo_empty0,";
    } else {
	$app_vcs_connect_in .= "tx_stream_fifo_empty0 => \"1'b0\",";
    }
    if ($tl_selection == 7) {
	$add_signals .= "e_signal->new({name => rx_stream_data0_1, width=> 82}),";
	$app_vcs_connect_in .= "rx_stream_data0_1 => rx_stream_data0_1,";
    } else {
	$add_signals .= "e_signal->new({name => gnd_rx_stream_data0_1 ,  width => 82 , never_export => 1}),";
	$vcs_signals .= "e_assign->new({lhs => {name => gnd_rx_stream_data0_1 , width => 82}, rhs => \"1'b0\"}),";
	$app_vcs_connect_in .= "rx_stream_data0_1 => gnd_rx_stream_data0_1,";
    }
}
if ($tl_selection == 0) {
    $app_vcs_connect_in .= "tx_stream_mask0 => tx_stream_mask0,";
} else {
    $add_signals .= "e_signal->new({name => gnd_tx_stream_mask0 ,  width => 1 , never_export => 1}),";
    $vcs_signals .= "e_assign->new({lhs => {name => gnd_tx_stream_mask0 , width => 1}, rhs => \"1'b0\"}),";
    $app_vcs_connect_in .= "tx_stream_mask0 => gnd_tx_stream_mask0,";
}

$app_vcs_connect_out .= "tx_stream_valid0 => tx_stream_valid0,";
if ($simple_dma == 1) {
    $app_vcs_connect_out .= "tx_stream_data0 => tx_stream_data0,";
    $app_vcs_connect_out .= "cpl_err => cpl_err_icm,";

} else {
    $app_vcs_connect_out .= "tx_stream_data0_0 => tx_stream_data0,";
    if ($tl_selection == 7) {
	$add_signals .= "e_signal->new({name => tx_stream_data0_1, width=> 75}),";
	$app_vcs_connect_out .= "tx_stream_data0_1 => tx_stream_data0_1,";
    } else {
	$add_signals .= "e_signal->new({name => open_tx_stream_data0_1 ,  width => 75 , never_export => 1}),";
	$app_vcs_connect_out .= "tx_stream_data0_1 => open_tx_stream_data0_1,";
    }
    if ($hip == 0) { # no LMI
	$app_vcs_connect_out .= "cpl_err => cpl_err_icm,";
    } else {
	$app_vcs_connect_out .= "cpl_err => cpl_err_in,";
	$app_vcs_connect_out .= "err_desc => err_desc,";
    }


}
$app_vcs_connect_out .= "rx_stream_ready0 => rx_stream_ready0,";
$app_vcs_connect_out .= "cpl_pending => cpl_pending_icm,";
$app_vcs_connect_out .= "rx_stream_mask0 => rx_mask0,";

if ($tl_selection == 0) {
    $app_vcs_connect_in .= "msi_stream_ready0 => msi_stream_ready0,";
    $app_vcs_connect_out .= "msi_stream_valid0 => msi_stream_valid0,";
    $app_vcs_connect_out .= "msi_stream_data0 => msi_stream_data0,";
} else {
    $app_vcs_signals .= "e_assign->new({lhs => {name => gnd_msi_stream_ready0, width => 1,never_export => 1}, rhs => \"1'b0\"}),";
    $app_vcs_connect_in .= "msi_stream_ready0 => gnd_msi_stream_ready0,";

    $add_signals .= "e_signal->new({name => open_msi_stream_valid0 ,  width => 1 , never_export => 1}),";
    $app_vcs_connect_out .= "msi_stream_valid0 => open_msi_stream_valid0,";

    $add_signals .= "e_signal->new({name => open_msi_stream_data0 ,  width => 8 , never_export => 1}),";
    $app_vcs_connect_out .= "msi_stream_data0 => open_msi_stream_data0,";

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

# S2GX
if ($phy_selection == 2) {
    if ($multi_core ne "0") {
	$add_signals .= "e_signal->new({name => reconfig_togxb, width=> 3}),";
	if ($number_of_lanes < 8) {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 1, never_export => 1}),";
	} else {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 2, never_export => 1}),";
	}

    } else {
	$add_signals .= "e_signal->new({name => cal_blk_clk, width=> 1, never_export => 1}),";
	$add_signals .= "e_signal->new({name => reconfig_clk, width=> 1, never_export => 1}),";
	$add_signals .= "e_signal->new({name => reconfig_togxb, width=> 3, never_export => 1}),";

	if ($number_of_lanes < 8) {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 1, never_export => 1}),";
	    $glue_logic .= "e_assign->new ([ cal_blk_clk  => clk125_in]),";
	} else {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 2, never_export => 1}),";
	    $glue_logic .= "e_process->new({
comment => \"Div down 250Mhz clk with T-Flop\",
clock => \"clk250_in\",
reset => \"npor\", 
asynchronous_contents => [   
e_assign->new([\"cal_blk_clk\" => 0]),   
], 
user_attributes_names => [\"cal_blk_clk\"],
user_attributes => [
    {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => ['R102'],
     },
  ],
contents => [
e_assign->new([\"cal_blk_clk\" => \"~cal_blk_clk\"]),
],

}),";

	}

	$glue_logic .= "e_assign->new ([ reconfig_clk  => \"1'b0\"]),";
	$glue_logic .= "e_assign->new ([ reconfig_togxb  => \"3'b010\"]),";
    }

    $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
    $alt2gxb_in .= "reconfig_clk => reconfig_clk,";
    $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";
    $add_signals .= "e_signal->new({name => gxb_powerdown, width=> 1, never_export => 1}),";
    $glue_logic .= "e_assign->new ([ gxb_powerdown  => \"~npor\"]),";
    $alt2gxb_in .= "gxb_powerdown => gxb_powerdown,";
    $alt2gxb_out .= "reconfig_fromgxb => open_reconfig_fromgxb,";


    
}


# S4GX
if ($phy_selection == 6) {
    if ($multi_core ne "0") {
	$add_signals .= "e_signal->new({name => reconfig_togxb, width=> 4}),";
	if ($number_of_lanes < 8) {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 17, never_export => 1}),";
	} else {
	    $add_signals .= "e_signal->new({name => open_reconfig_fromgxb, width=> 34, never_export => 1}),";
	}
	$alt2gxb_out .= "reconfig_fromgxb => open_reconfig_fromgxb,";
    } else {
	$add_signals .= "e_signal->new({name => cal_blk_clk, width=> 1, never_export => 1}),";
	$add_signals .= "e_signal->new({name => reconfig_clk, width=> 1}),";
	$add_signals .= "e_signal->new({name => reconfig_togxb, width=> 4, never_export => 1}),";

	$add_signals .= "e_signal->new({name => reconfig_fromgxb, width=> 34, never_export => 1}),";

	# free running reconfig clk
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

	$add_signals .= "e_signal->new({name => offset_cancellation_reset ,  never_export => 1}),";
	$glue_logic  .= "e_assign->new ([ offset_cancellation_reset => \"~reconfig_clk_locked\"]),";
	$alt2gxb_in .= "fixedclk_serdes => fixedclk_serdes,";



	$add_signals .= "e_signal->new({name => busy_altgxb_reconfig ,  never_export => 1}),";
	$glue_logic  .= "e_assign->new({lhs => {name => busy_altgxb_reconfig}, rhs => \"(pipe_mode == 1)? 0 : busy\"}),";
	$alt2gxb_in .= 'busy_altgxb_reconfig=>"busy_altgxb_reconfig",';

	if ($hip == 0) {

	    if ($number_of_lanes < 8) {
		$glue_logic .= "e_assign->new ([ cal_blk_clk  => clk125_in]),";
	    } else {
		$glue_logic .= "e_process->new({
comment => \"Div down 250Mhz clk with T-Flop\",
clock => \"clk250_in\",
reset => \"npor\", 
asynchronous_contents => [   
e_assign->new([\"cal_blk_clk\" => 0]),   
], 
user_attributes_names => [\"cal_blk_clk\"],
user_attributes => [
    {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => ['R102'],
     },
  ],
contents => [
e_assign->new([\"cal_blk_clk\" => \"~cal_blk_clk\"]),
],

}),";

	    }
	} else {
	    if (
	    (($gen2_rate == 1) & ($number_of_lanes == 8)) ||
	    (($gen2_rate == 1) & ($number_of_lanes == 4) & ($tl_selection == 6)) ||
	    (($gen2_rate == 0) & ($number_of_lanes == 8) & ($tl_selection == 6))
		) { # divide down cal_blk_clk
		$glue_logic .= "e_process->new({
comment => \"Div down 250Mhz clk with T-Flop\",
clock => \"pld_clk\",
reset => \"npor\", 
asynchronous_contents => [   
e_assign->new([\"cal_blk_clk\" => 0]),   
], 
user_attributes_names => [\"cal_blk_clk\"],
user_attributes => [
    {
        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
        attribute_operator => '=',
        attribute_values => ['R102'],
     },
  ],
contents => [
e_assign->new([\"cal_blk_clk\" => \"~cal_blk_clk\"]),
],

}),";
	    } else {
		$glue_logic .= "e_assign->new ([ cal_blk_clk  => pld_clk]),";
	    }
	}


    if ($number_of_lanes < 8) {
	if ($c3gx == 0) {
	    $alt2gxb_out .= "reconfig_fromgxb => \"reconfig_fromgxb[16:0]\",";
	    $glue_logic .= "e_assign->new ([ \"reconfig_fromgxb[33:17]\" => \"0\"]),";
	} else {
	    $alt2gxb_out .= "reconfig_fromgxb => \"reconfig_fromgxb[4:0]\",";
	    $glue_logic .= "e_assign->new ([ \"reconfig_fromgxb[33:5]\" => \"0\"]),";
	}
    } else {
	$alt2gxb_out .= "reconfig_fromgxb => reconfig_fromgxb,";
    }

    }

    $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
    $alt2gxb_in .= "gxb_powerdown => \"1'b0\",";
    if ($hip) {
	$alt2gxb_in .= "fixedclk_serdes => cal_blk_clk,";
    }
    $alt2gxb_in .= "reconfig_clk => reconfig_clk,";

#    if ($hip == 1) { # Generate reconfig clk to mimic free 100Mhz clock for HIP
#		$glue_logic .= "e_process->new({
#comment => \"Div down refclk with T-Flop\",
#clock => \"refclk\",
#reset => \"npor\", 
#asynchronous_contents => [   
#e_assign->new([\"reconfig_clk\" => 0]),   
#], 
#user_attributes_names => [\"reconfig_clk\"],
#user_attributes => [
#    {
#        attribute_name => 'SUPPRESS_DA_RULE_INTERNAL',
#        attribute_operator => '=',
#        attribute_values => ['R102'],
#     },
#  ],
#contents => [
#e_assign->new([\"reconfig_clk\" => \"~reconfig_clk\"]),
#],
#
#}),";
#
#	    }

    $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";
    $add_signals .= "e_signal->new({name => pll_powerdown, width=> 1, never_export => 1}),";
    $glue_logic .= "e_assign->new ([ pll_powerdown  => \"~npor\"]),";
    $alt2gxb_in .= "pll_powerdown => pll_powerdown,";
    $add_signals .= "e_signal->new({name => rx_freqlocked, width=> 1, never_export => 1}),";
    
}

# external phy
if (($phy_selection == 1) || ($phy_selection == 3) ||
    ($phy_selection == 4) || ($phy_selection == 5)) {
    $alt2gxb_in .= "xphy_pll_areset => \"1'b0\",";
}

# pass down ko_signal and cfg_tcvcmap
$glue_logic .= "e_assign->new ([ \"ko_cpl_spc_vc0[7:0]\" => \"8'd$cplh_cred\"]),";
$glue_logic .= "e_assign->new ([ \"ko_cpl_spc_vc0[19:8]\" => \"12'd$cpld_cred\"]),";
$glue_logic .= "e_assign->new ([ \"gnd_cfg_tcvcmap_icm\" => \"0\"]),";

# hookup HIPCAP bus to 7.1 ICM
if (($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9)) {

    if ($rp == 0) {

	$glue_logic .= "e_assign->new ([ tx_st_sop0 => \"tx_stream_data0[73]\"]),";
	$glue_logic .= "e_assign->new ([ tx_st_err0 => \"tx_stream_data0[74]\"]),";

	if ($tl_selection == 7) {
	    $glue_logic .= "e_assign->new ([ rx_stream_data0 => \"{rx_st_be0[7:0], rx_st_sop0, rx_st_empty0, rx_st_bardec0, rx_st_data0[63:0]}\"]),";
	    $glue_logic .= "e_assign->new ([ rx_stream_data0_1 => \"{rx_st_be0[15:8], rx_st_sop0, rx_st_eop0, rx_st_bardec0, rx_st_data0[127:64:0]}\"]),";
	    $glue_logic .= "e_assign->new ([ tx_st_data0 => \"{tx_stream_data0_1[63:0],tx_stream_data0[63:0]}\"]),";
	    $glue_logic .= "e_assign->new ([ tx_st_eop0 => \"tx_stream_data0_1[72]\"]),";
	    $glue_logic .= "e_assign->new ([ tx_st_empty0 => \"tx_stream_data0[72]\"]),";
	} else {
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
    module => "altpcierd_pcie_reconfig",
    name => "altpcierd_pcie_reconfig0",
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
	pcie_reconfig_rstn => "pcie_reconfig_rstn",


	},

});

    $glue_logic .= "e_assign->new({lhs => {name => set_pcie_reconfig}, rhs => \"1'b1\"}),";
} else {
    $glue_logic .= "e_assign->new({lhs => {name => pcie_reconfig_rstn}, rhs => \"1'b1\"}),";
}



##################################################
# Instantiate user variation
##################################################
my $pci_inst;
    
 if ($tl_selection == 0) { # native PLDA 

     # tie off app_msi bus
     $add_signals .= "e_signal->new({name => gnd_app_msi_ack, width=> 1, never_export => 1}),";
     $glue_logic .= "e_assign->new ([ gnd_app_msi_ack => \"0\"]),";
     $glue_logic .= "e_assign->new ([ app_msi_ack => gnd_app_msi_ack]),";

     $add_signals .= "e_signal->new({name => app_msi_req, width=> 1, never_export => 1}),";
     $add_signals .= "e_signal->new({name => app_int_ack_icm, width=> 1, never_export => 1}),";
     $add_signals .= "e_signal->new({name => cfg_msicsr, width=> 16, never_export => 1}),";

     $pci_inst = e_blind_instance->new({
	module => "$var\_icm",
	name => "icm_epmap",
	in_port_map => {
	    refclk => "refclk",
	    eval($reset_in),

	    eval($dual_phy_in),
	    eval($alt2gxb_in),
	    $clkfreq_in => "$clkfreq_in",
	    eval($serdes_in),
	    eval($pipe_connect_in),
	    
	    test_in => "test_in",
	    cpl_err_icm => "cpl_err_icm",
	    pme_to_cr => "pme_to_sr",
	    pex_msi_num_icm => "pex_msi_num_icm",
	    app_int_sts_icm => "app_int_sts_icm",
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
	    eval($hotrst_exit),
	    dlup_exit => "dlup_exit",
	    pme_to_sr => "pme_to_sr",
	    cfg_busdev_icm => "cfg_busdev_icm",
	    cfg_devcsr_icm => "cfg_devcsr_icm",
	    cfg_linkcsr_icm => "cfg_linkcsr_icm",
	    cfg_prmcsr_icm => "cfg_prmcsr_icm",
	    cfg_msicsr_icm =>"cfg_msicsr",
	    test_out_icm => "test_out_icm",
	    app_int_sts_ack_icm => "app_int_ack_icm",
	    eval($vcs_connect_out),
	    eval($open_signals),

	},
	
    });

} elsif (($tl_selection == 6) | ($tl_selection == 7) | ($tl_selection == 9))  { # HIPCAB
    $cfg_ports = " ";

    $add_signals .= "e_signal->new({name => cfg_msicsr, width=> 16, never_export => 1}),";
    $add_signals .= "e_signal->new({name => open_cfg_pmcsr, width=> 32, never_export => 1}),";
    $add_signals .= "e_signal->new({name => open_cfg_prmcsr, width=> 32, never_export => 1}),";
    $add_signals .= "e_signal->new({name => open_cfg_tcvcmap, width=> 24, never_export => 1}),";
    $add_signals .= "e_signal->new({name => tl_cfg_add, width=> 4}),";
    $add_signals .= "e_signal->new({name => tl_cfg_ctl, width=> 32}),";
    $add_signals .= "e_signal->new({name => tl_cfg_sts, width=> 53}),";
    $add_signals .= "e_signal->new({name => app_int_ack_icm, width=> 1, never_export => 1}),";

    if ($hip == 0) {
	$open_signals .= "cfg_msicsr => cfg_msicsr,";
	$open_signals .= "cfg_pmcsr => open_cfg_pmcsr,";
	$open_signals .= "cfg_prmcsr => open_cfg_prmcsr,";
	$open_signals .= "cfg_tcvcmap => open_cfg_tcvcmap,";

	$cfg_ports .= "cfg_busdev => \"cfg_busdev_icm\",\n";
	$cfg_ports .= "cfg_devcsr => \"cfg_devcsr_icm\",\n";
	$cfg_ports .= "cfg_linkcsr => \"cfg_linkcsr_icm\",\n";
	$cfg_ports .= "cfg_prmcsr => \"cfg_prmcsr_icm\",\n";

    } else {
	$cfg_ports .= " tl_cfg_add => tl_cfg_add,\n";
	$cfg_ports .= " tl_cfg_ctl => tl_cfg_ctl,\n";
	$cfg_ports .= " tl_cfg_sts => tl_cfg_sts,\n";
	if ($phy_selection < 7) { # S4GX, A2GX, C4GX
	    $cfg_ports .= " tl_cfg_sts_wr => tl_cfg_sts_wr,\n";
	    $cfg_ports .= " tl_cfg_ctl_wr => tl_cfg_ctl_wr,\n";
	}






	if ($simple_dma) {
	# regeneration configuration bus
	    if  ($phy_selection == 7) {

$glue_logic .= "e_process->new({
comment => \"Configuration Demux logic \",
clock => \"pld_clk\",
reset => \"srstn\",
asynchronous_contents => [
e_assign->new([\"cfg_busdev_icm\" => '0']),
e_assign->new([\"cfg_devcsr_icm\" => '0']),
e_assign->new([\"cfg_linkcsr_icm\" => '0']),
e_assign->new([\"cfg_prmcsr_icm\" => '0']),

],
contents => [ 
e_if->new({
condition => \"(tl_cfg_add==4'h0)\",
then => [\"cfg_devcsr_icm[15:0]\"=> \"tl_cfg_ctl[31:16]\" ],
}),
e_if->new({
condition => \"(tl_cfg_add==4'h2)\",
then => [\"cfg_linkcsr_icm[15:0]\"=> \"tl_cfg_ctl[31:16]\" ],
}),
e_if->new({
condition => \"(tl_cfg_add==4'hF)\",
then => [\"cfg_busdev_icm\"=> \"tl_cfg_ctl[12:0]\" ],
}),
],
}),";

	    } else {
$glue_logic .= "e_process->new({
comment => \"Synchronise to pld side \",
clock => \"pld_clk\",
reset => \"srstn\",
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
reset => \"srstn\",
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

}
} else { # instantiate module for chaining DMA


    $label = "cfg_inst";
    $label{$label} = 1;;
    $$label = e_blind_instance->new({
	module => "altpcierd_tl_cfg_sample",
	name => "cfgbus",
	in_port_map => {
	    pld_clk => "$app_clk_in",
	    rstn => "srstn",
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

    }

    if ($rp == 0) {
	$pci_inst_name = "epmap";
    } else {
	$pci_inst_name = "rpmap";
    }
    
    $pci_inst = e_blind_instance->new({
	module => "$var",
	name => "$pci_inst_name",
	in_port_map => {
	    refclk => "refclk",
	    eval($reset_in),

	    eval($dual_phy_in),
	    eval($alt2gxb_in),
	    eval($clk_in),
	    eval($serdes_in),
	    eval($pipe_connect_in),
	    
	    test_in => "test_in",
	    cpl_pending => "cpl_pending_icm",
	    cpl_err => "cpl_err_icm",
	    pme_to_cr => "pme_to_sr",
	    app_int_sts => "app_int_sts_icm",
	    app_msi_req => "app_msi_req",
	    app_msi_tc => "app_msi_tc",
	    app_msi_num => "app_msi_num",
	    pex_msi_num => "pex_msi_num_icm",
	    eval($vcs_connect_in),
	},
	out_port_map => {
	    eval($clk_out),

	    eval($dual_phy_out),
	    eval($alt2gxb_out),
	    eval($serdes_out),
	    eval($pipe_connect_out),
	    
	    eval($app_clk_out),
	    l2_exit => "l2_exit",
	    eval($hotrst_exit),
	    dlup_exit => "dlup_exit",
	    pme_to_sr => "pme_to_sr",
	    app_msi_ack => "app_msi_ack",
	    app_int_ack => "app_int_ack_icm",
	    eval($cfg_ports),
	    eval($vcs_connect_out),
	    eval($open_signals),

	},
	
    });


} else {
    $pci_inst = e_blind_instance->new({
	module => "$var",
	name => "dummy",
	in_port_map => {
	    refclk => "refclk",
	},
	out_port_map => {
	    eval($clk_out),

	},
	
    });

}

# Generate Gen2 speed
if ($gen2_rate) {
    $glue_logic .= "e_assign->new({lhs => {name => gen2_speed , width => 1}, rhs => \"cfg_linkcsr_icm[17]\"}),";
}

##################################################
# Compute if application clock is 250Mhz
##################################################
$app_clk_eq_250 = 0;

if ((($phy_selection == 2) & ($number_of_lanes > 4)) || # S2GX
    (($gen2_rate == 1) & ($number_of_lanes == 8)) ||
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
	$parameter_str = "MAX_PAYLOAD_SIZE_BYTE => $max_pload, MAX_NUMTAG => $tags, TXCRED_WIDTH => $txcred_width, AVALON_WADDR => 12, TL_SELECTION => $tl_selection, ECRC_FORWARD_CHECK => $crc_fwd, ECRC_FORWARD_GENER => $crc_fwd, CHECK_RX_BUFFER_CPL => 1, CLK_250_APP => $app_clk_eq_250 ";
	
	# hookup extra ports for chaining DMA
	$app_vcs_connect_in .= "tx_stream_cred0 => tx_stream_cred0,";
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

} else {

    # drive misc ports
     $glue_logic .= "e_assign->new ([ app_int_sts_icm => \"0\"]),";
     $glue_logic .= "e_assign->new ([ app_msi_req => \"0\"]),";
     $glue_logic .= "e_assign->new ([ cpl_pending_icm => \"0\"]),";

     # open signals
     $add_signals .= "e_signal->new({name => app_msi_ack, width=> 1, never_export => 1}),";
     


    for ($i = 0; $i < $number_of_vcs; $i++) {

	$parameter_str = "VC_NUM => $i, ECRC_FORWARD_CHECK => $crc_fwd, ECRC_FORWARD_GENER => $crc_fwd";

	if ($tl_selection == 7) {
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
reset => \"any_rstn_rr\",
tag => simulation,
asynchronous_contents => [
e_assign->new([\"srstn_r\" => '0']),
e_assign->new([\"srstn_rr\" => '0']),

],
contents => [ 
e_assign->new([\"srstn_r\" => 'srstn']),
e_assign->new([\"srstn_rr\" => 'srstn_r']),
],
}),";


	# for simulation 
	$app_name = "altpcietb_bfm_vc_intf_ast";
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
		tx_cred => "tx_stream_cred$i",
		cfg_io_bas => "cfg_io_bas",
		cfg_np_bas => "cfg_np_bas",
		cfg_pr_bas => "cfg_pr_bas",
		rx_st_sop => "rx_st_sop$i",
		rx_st_eop => "rx_st_eop$i",
		rx_st_valid => "rx_stream_valid$i",
		rx_st_empty => "rx_st_empty$i",
		rx_st_data => "rx_st_data$i",
		rx_st_be => "rx_st_be$i",
		tx_st_ready => "tx_stream_ready$i",
		tx_fifo_empty => "tx_fifo_empty$i",
		
	    },
	    out_port_map => {
		rx_mask => "rx_mask$i",
		rx_st_ready => "rx_stream_ready$i",
		tx_st_sop => " tx_st_sop$i",
		tx_st_eop => " tx_st_eop$i",
		tx_st_empty => "tx_st_empty$i",
		tx_st_valid => "tx_stream_valid$i",
		tx_st_data => "tx_st_data$i",
	    },
	    
	});

	# for synthesis
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
e_assign->new({lhs => {name => rx_stream_ready$i\_r}, rhs => tx_stream_ready$i}),
e_assign->new({lhs => {name => tx_st_data$i\_r}, rhs => rx_st_data$i}),
e_assign->new({lhs => {name => tx_st_empty$i\_r}, rhs => rx_st_empty$i}),
e_assign->new({lhs => {name => tx_st_eop$i\_r}, rhs => rx_st_eop$i}),
e_assign->new({lhs => {name => tx_st_eop$i\_r}, rhs => rx_st_eop$i}),
e_assign->new({lhs => {name => tx_stream_valid$i\_r}, rhs => rx_stream_valid$i}),

],
}),";

	$glue_logic .= "e_assign->new({lhs => {name => tx_st_sop$i}, rhs => tx_st_sop$i\_r, tag => synthesis}),";
	$glue_logic .= "e_assign->new({lhs => {name => tx_st_eop$i}, rhs => tx_st_eop$i\_r, tag => synthesis}),";
	$glue_logic .= "e_assign->new({lhs => {name => tx_st_empty$i}, rhs => tx_st_empty$i\_r, tag => synthesis}),";
	$glue_logic .= "e_assign->new({lhs => {name => tx_st_data$i}, rhs => tx_st_data$i\_r, tag => synthesis}),";
	$glue_logic .= "e_assign->new({lhs => {name => rx_stream_ready$i}, rhs => rx_stream_ready$i\_r, tag => synthesis}),";
	$glue_logic .= "e_assign->new({lhs => {name => tx_stream_valid$i}, rhs => tx_stream_valid$i\_r, tag => synthesis}),";


    }

}


########################################
# reconfig for S4GX
########################################
if (($phy_selection == 6) & ($multi_core eq "0")) {

    $add_signals .= "e_signal->new({name => busy, width=> 1, never_export => 1}),";
    $add_signals .= "e_signal->new({name => data_valid, width=> 1, never_export => 1}),";
    $add_signals .= "e_signal->new({name => rx_eqctrl_out, width=> 4, never_export => 1}),";
    $add_signals .= "e_signal->new({name => rx_eqdcgain_out, width=> 3, never_export => 1}),";
    $add_signals .= "e_signal->new({name => tx_preemp_0t_out, width=> 5, never_export => 1}),";
    $add_signals .= "e_signal->new({name => tx_preemp_1t_out, width=> 5, never_export => 1}),";
    $add_signals .= "e_signal->new({name => tx_preemp_2t_out, width=> 5, never_export => 1}),";
    $add_signals .= "e_signal->new({name => tx_vodctrl_out, width=> 3, never_export => 1}),";

    if ($c3gx == 0) {

	$label = "reconfig";
	$label{$label} = 1;
	$$label = e_blind_instance->new({
	    module => "altpcie_reconfig_4sgx",
	    name => "reconfig",
	    in_port_map => {
		logical_channel_address => "3'b000",
		read => "1'b0",
		offset_cancellation_reset => "offset_cancellation_reset",
		reconfig_clk => "reconfig_clk",
		reconfig_fromgxb => "reconfig_fromgxb",
		rx_eqctrl => "4'b0000",
		rx_eqdcgain => "3'b000",
		tx_preemp_0t => "5'b00000",
		tx_preemp_1t => "5'b00000",
		tx_preemp_2t => "5'b00000",
		tx_vodctrl => "3'b000",
		write_all => "1'b0",
	    },
	    out_port_map => {
		busy => "busy",
		data_valid => "data_valid",
		rx_eqctrl_out => "rx_eqctrl_out",
		rx_eqdcgain_out => "rx_eqdcgain_out",
		tx_preemp_0t_out => "tx_preemp_0t_out",
		tx_preemp_1t_out => "tx_preemp_1t_out",
		tx_preemp_2t_out => "tx_preemp_2t_out",
		tx_vodctrl_out => "tx_vodctrl_out",
		reconfig_togxb => "reconfig_togxb",
		
	    },
	    
	});
    } else {
	$label = "reconfig";
	$label{$label} = 1;
	$$label = e_blind_instance->new({
	    module => "altpcie_reconfig_3cgx",
	    name => "reconfig",
	    in_port_map => {
		offset_cancellation_reset => "offset_cancellation_reset",
		reconfig_clk => "reconfig_clk",
		reconfig_fromgxb => "reconfig_fromgxb[4:0]",
	    },
	    out_port_map => {
		busy => "busy",
		reconfig_togxb => "reconfig_togxb",
	    },
	    
	});
    }

}






##################################################
# Add reset logic
##################################################
if ($hip == 0) {
    $glue_logic .= "e_assign->new ([rc_pll_locked => \"1'b1\"]),";
}
$glue_logic .= "e_assign->new ([npor_pll => \"pcie_rstn & local_rstn & rc_pll_locked & pcie_reconfig_rstn\"]),";
$glue_logic .= "e_assign->new ([npor => \"pcie_rstn & local_rstn\"]),";


if ($hip == 1) {
    $glue_logic .= "e_process->new({
comment => \"LTSSM pipeline\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"dl_ltssm_r\" => 0]),
],
contents => [
e_assign->new([\"dl_ltssm_r\" => dl_ltssm]),
],

}),";

    $disable_rst = "| (dl_ltssm_r == 5'h10)";
} 


    $glue_logic .= "e_process->new({
comment => \"pipe line exit conditions\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"dlup_exit_r\" => 1]),
e_assign->new([\"hotrst_exit_r\" => 1]),
e_assign->new([\"l2_exit_r\" => 1]),
e_assign->new([\"exits_r\" => 0]),
],
contents => [
e_assign->new([\"dlup_exit_r\" => \"dlup_exit\"]),
e_assign->new([\"hotrst_exit_r\" => \"hotrst_exit\"]),
e_assign->new([\"l2_exit_r\" => \"l2_exit\"]),
e_assign->new([\"exits_r\" => \"(l2_exit_r == 1'b0) | (hotrst_exit_r == 1'b0) | (dlup_exit_r == 1'b0) $disable_rst\"]),
],

}),";



    $glue_logic .= "e_process->new({
comment => \"reset Synchronizer\",
clock => \"$clkfreq_in\",
reset => \"npor_pll\",
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




$add_signals .= "e_signal->new({name => rsnt_cntn, width=> 11, never_export => 1}),";
$glue_logic .= "e_process->new({
comment => \"reset counter\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"rsnt_cntn\" => '0']),
],
contents => [ 
e_if->new({
condition => \"(local_rstn == 1'b0) | (exits_r == 1'b1)\",
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

if (($number_of_lanes == 8) & ($hip == 0)) { # x8 mode
$glue_logic .= "e_process->new({
comment => \"sync and config reset\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"srstn\" => '0']),
],
contents => [ 
e_if->new({
condition => \"(local_rstn == 1'b0) | (exits_r == 1'b1)\",
then => [\"srstn\" => 0],
else => [
  e_if->new({
    comment => \" synthesis translate_off\",
    condition => \"(test_in[0] == 1'b1) & (rsnt_cntn == 11'd32)\", 
    then => [\"srstn\" => 1],
    else => [
      e_if->new({
         comment => \" synthesis translate_on\",
         condition => \"(rsnt_cntn == 11'd1024)\", 
         then => [\"srstn\" => 1],
      }),
     ]
  }),
 ]
}),
],
}),";
} else { # x1 or x4 mode or HIP
$glue_logic .= "e_assign->new ([srstn => \"app_rstn\"]),";

if ($rp == 0) { # endpoint mode
$glue_logic .= "e_process->new({
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
condition => \"(local_rstn == 1'b0) | (exits_r == 1'b1)\",
then => [\"srst0\" => 1,\"crst0\" => 1,\"app_rstn0\" => 0],
else => [
  e_if->new({
    comment => \" synthesis translate_off\",
    condition => \"(test_in[0] == 1'b1) & (rsnt_cntn >= 11'd32)\", 
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
$glue_logic .= "e_process->new({
comment => \"sync reset\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"app_rstn0\" => '0']),
e_assign->new([\"srst0\" => '1']),

],
contents => [ 
e_if->new({
condition => \"(local_rstn == 1'b0) | (exits_r == 1'b1) \",
then => [\"srst0\" => 1,\"app_rstn0\" => 0],
else => [
  e_if->new({
    comment => \" synthesis translate_off\",
    condition => \"(test_in[0] == 1'b1) & (rsnt_cntn >= 11'd32)\", 
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

$glue_logic .= "e_process->new({
comment => \"config reset\",
clock => \"$clkfreq_in\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"crst0\" => '1'])

],
contents => [ 
e_if->new({
condition => \"(local_rstn == 1'b0) | (l2_exit_r == 1'b0) | (hotrst_exit_r == 1'b0)\",
then => [\"crst0\" => 1],
else => [
  e_if->new({
    comment => \" synthesis translate_off\",
    condition => \"(test_in[0] == 1'b1) & (rsnt_cntn >= 11'd32)\", 
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

$glue_logic .= "e_process->new({
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

}

$top_mod->add_contents
(
 my $refclk = e_port->new([ refclk => 1 => "input"]),
 my $local_rstn = e_port->new([ local_rstn => 1 => "input"]),
 my $pcie_rstn = e_port->new([ pcie_rstn => 1 => "input"]),

 eval($clk_ports),

 my $phy_sel_code = e_port->new([phy_sel_code => 4 => "output"]),
 my $ref_clk_sel_code = e_port->new([ref_clk_sel_code => 4 => "output"]),
 my $lane_width_code = e_port->new([lane_width_code => 4 => "output"]),
  
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

  $pci_inst,

);


foreach $key (sort keys %label) {
    $top_mod->add_contents($$key);
}

$top_mod->vhdl_libraries()->{altera_mf} = "all";

$proj->top($top_mod);
$proj->language($language);
$proj->output();

