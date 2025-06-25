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
# This europa file generates what used to be variation_example_top
# It instantiates
# 1) Reference design
# 2) LEDs
#####################################################################

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
my $refclk_selection = 1;
my $var = "pci_var";
my $language = "vhdl";
my $pipe_txclk = 0;
my $multi_core = "0";
my $simple_dma = 1;
my $hip = 0;
my $rp = 0;
my $gen2_rate = 0;

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


my $temp = $command_hash{"language"};
if($temp ne "")
{
   $language = $temp;
}

my $temp = $command_hash{"gen2_rate"};
if($temp ne "")
{
   $gen2_rate = $temp;
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



# declare top module
my $top_name = "top";
my $pipen1b = "pipen1b";
my $comment_str = "simple";
my $comment_hdl = "Verilog HDL";
if ($rp == 0) {
    if ($simple_dma == 0) {
   $comment_str = "chaining";
   $top_name = "chaining_top";
   $pipen1b = "chaining_pipen1b";
    }
} else {
    $comment_str = "rp";
    $top_name = "rp_top";
    $pipen1b = "rp_pipen1b";
}
    if ($language =~ /hdl/i) {
   $comment_hdl = "VHDL";
    }

my $top_mod = e_module->new ({name => "$var\_example_$top_name", comment => "/** This $comment_hdl file is used for synthesis in $comment_str DMA design example\n*\n* This file provides the top level for synthesis\n*/"});

#processed variables
my $test_out_width;
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
    $clkfreq_out = "core_clk_out";
}

# test_in width
if (($hip == 1) & ($phy_selection == 6)) { # S4GX, A2GX, C4GX
    $test_in_width = 40;
} else {
    $test_in_width = 32;
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
# Alt2gxb specific signals
##################################################
$alt2gxb_in = " ";
my $add_signals = " ";

if ($hip==0) {
   if (($phy_selection == 2) || ($phy_selection == 6)) {
       if ($multi_core ne "0") {
      if ($phy_selection == 2) {
          $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 3}),";
      } else {
          $add_signals .= "e_signal->new({name => reconfig_togxb, width=> 4}),";
      }
      $alt2gxb_in .= "reconfig_clk => reconfig_clk,";
      $alt2gxb_in .= "cal_blk_clk => cal_blk_clk,";
      $alt2gxb_in .= "reconfig_togxb => reconfig_togxb,";

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
# Reference design Serdes connections
##################################################

# default connections
my $serdes_out = " ";
my $serdes_in = " ";
my $i;
my $never_export = " ";


if (($phy_selection == 0) || ($phy_selection == 2) || ($phy_selection == 6) || ($phy_selection == 7)) { # needs serdes connection
    $serdes_in .= "pipe_mode => \"1'b0\",";
    for ($i = 0; $i < $number_of_lanes; $i++) {
   $serdes_out .= "tx_out$i => tx_out$i,";
   $serdes_in .= "rx_in$i => rx_in$i,";
    }
    $never_export =  ", never_export => 1";

}

#lane width & test width
$alive_cnt_width = 25;
if ($number_of_lanes == 1) {
    $test_out_width = 512;
} elsif ($number_of_lanes == 2) {
} elsif ($number_of_lanes == 4) {
    $test_out_width = 512;
} elsif ($number_of_lanes == 8) {
    $test_out_width = 128;
    $alive_cnt_width = 26;
} else {
    die "ERROR: Number of lanes are not supported\n";
}

$alive_cnt_msb = $alive_cnt_width-1;


##################################################
# add misc signals
##################################################

# multi-bit bus
$add_signals .= "e_signal->new({name => test_out_icm, width=> 9, never_export => 1}),";
$add_signals .= "e_signal->new({name => test_in , width=>  $test_in_width , never_export => 1}),";
$add_signals .= "e_signal->new({name => alive_cnt , width=> $alive_cnt_width, never_export => 1}),";
$add_signals .= "e_signal->new({name => lane_active_led , width=> 4}),";
$add_signals .= "e_signal->new({name => usr_sw , width=> 8}),";
$add_signals .= "e_signal->new({name => open_phy_sel_code, width=> 4, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_ref_clk_sel_code, width=> 4, never_export => 1}),";
$add_signals .= "e_signal->new({name => open_lane_width_code , width=> 4, never_export => 1}),";
$add_signals .= "e_signal->new({name => local_rstn , width=> 1, never_export => 1}),";
$add_signals .= "e_signal->new({name => safe_mode , width=> 1, never_export => 1}),";


##################################################
# referecne design PIPE signals
##################################################

my $pipe_connect_in = " ";
my $pipe_connect_out = " ";
my $pipe_open = " ";
my $pipe_kwidth = $pipe_width / 8;


# share PIPE signals

$add_signals .= "e_signal->new({name => phystatus_ext, width=> 1 $never_export}),";
$add_signals .= "e_signal->new({name => txdetectrx_ext, width=> 1 $never_export}),";
$add_signals .= "e_signal->new({name => powerdown_ext, width=> 2 $never_export}),";
$pipe_connect_in .= "phystatus_ext => phystatus_ext,";
$pipe_connect_out .= "powerdown_ext => powerdown_ext,";
$pipe_connect_out .= "txdetectrx_ext => txdetectrx_ext,";

if ((($phy_selection == 4) | ($phy_selection == 3)) & ($number_of_lanes == 8)) { # Dual phy
    $add_signals .= "e_signal->new({name => phy1_phystatus_ext, width=> 1 $never_export}),";
    $add_signals .= "e_signal->new({name => phy1_txdetectrx_ext, width=> 1 $never_export}),";
    $add_signals .= "e_signal->new({name => phy1_powerdown_ext, width=> 2 $never_export}),";

    $pipe_connect_in .= "phy1_phystatus_ext => phy1_phystatus_ext,";
    $pipe_connect_out .= "phy1_powerdown_ext => phy1_powerdown_ext,";
    $pipe_connect_out .= "phy1_txdetectrx_ext => phy1_txdetectrx_ext,";
}

for ($i = 0; $i < $number_of_lanes;  $i++) {

    $pipe_connect_in .= "rxdata$i\_ext => rxdata$i\_ext,";
    $pipe_connect_in .= "rxdatak$i\_ext => rxdatak$i\_ext,";
    $pipe_connect_in .= "rxvalid$i\_ext => rxvalid$i\_ext,";
    $pipe_connect_in .= "rxelecidle$i\_ext => rxelecidle$i\_ext,";
    $pipe_connect_in .= "rxstatus$i\_ext => rxstatus$i\_ext,";


    $add_signals .= "e_signal->new({name => rxdata$i\_ext, width=> $pipe_width $never_export}),";
    $add_signals .= "e_signal->new({name => rxdatak$i\_ext, width=> $pipe_kwidth $never_export}),";
    $add_signals .= "e_signal->new({name => rxstatus$i\_ext, width=> 3 $never_export}),";
    $add_signals .= "e_signal->new({name => rxvalid$i\_ext, width=> 1 $never_export}),";
    $add_signals .= "e_signal->new({name => rxelecidle$i\_ext, width=> 1 $never_export}),";

    $pipe_connect_out .= "txdata$i\_ext => txdata$i\_ext,";
    $pipe_connect_out .= "txdatak$i\_ext => txdatak$i\_ext,";
    $pipe_connect_out .= "txelecidle$i\_ext => txelecidle$i\_ext,";
    $pipe_connect_out .= "txcompl$i\_ext => txcompl$i\_ext,";
    $pipe_connect_out .= "rxpolarity$i\_ext => rxpolarity$i\_ext,";


    $add_signals .= "e_signal->new({name => txdata$i\_ext, width=> $pipe_width $never_export}),";
    $add_signals .= "e_signal->new({name => txdatak$i\_ext, width=> $pipe_kwidth $never_export}),";
    $add_signals .= "e_signal->new({name => txcompl$i\_ext, width=> 1 $never_export}),";
    $add_signals .= "e_signal->new({name => rxpolarity$i\_ext, width=> 1 $never_export}),";
    $add_signals .= "e_signal->new({name => txelecidle$i\_ext, width=> 1 $never_export}),";

}

##################################################
# generation of phy reset
##################################################
if (($phy_selection == 1) | ($phy_selection == 3) | ($phy_selection == 4) | ($phy_selection == 5)) {
    $pipe_connect_out .= "pipe_rstn => pipe_rstn,";

}

# hook up pipe_txclk
if ($pipe_txclk == 1) {
    $pipe_connect_out .= "pipe_txclk => pipe_txclk,";
}

##################################################
# Gen2 speed test signal
##################################################
if ($gen2_rate) {
    $pipe_connect_out .= "gen2_speed => gen2_speed,";
}

##################################################
# Instantiate reference design
##################################################
my $free_100MHz = (($hip==1) | ($phy_selection == 6))?'free_100MHz => "free_100MHz",':'';
my $core_inst = e_blind_instance->new({
    name => "core",
    module => "$var\_example_$pipen1b",
    in_port_map => {
   refclk => "refclk",
   local_rstn => "local_rstn",
   pcie_rstn => "pcie_rstn",
   eval($dual_phy_in),
   eval($free_100MHz),
   $clkfreq_in => "clk_out_buf",
   test_in => "test_in",

   eval($serdes_in),
   eval($pipe_connect_in),
   eval($alt2gxb_in),

    },
    out_port_map => {
   $clkfreq_out => "clk_out_buf",
   phy_sel_code => "open_phy_sel_code",
   ref_clk_sel_code => "open_ref_clk_sel_code",
   lane_width_code => "open_lane_width_code",

   eval($dual_phy_out),
   eval($serdes_out),
   eval($pipe_connect_out),

   test_out_icm => "test_out_icm",

    },

});

my $altpcierd_compliance_test = e_blind_instance->new({
      name => "pcie_compliance_test_enable",
      module => "altpcierd_compliance_test",
      in_port_map => {
        refclk                       => "refclk",
        local_rstn                   => "local_rstn_ext",
        pcie_rstn                    => "pcie_rstn",
        req_compliance_push_button_n => "req_compliance_push_button_n",
        req_compliance_soft_ctrl     => "req_compliance_soft_ctrl ",
        set_compliance_mode          => "set_compliance_mode ",
      },
      out_port_map => {
        test_in_5_hip                => "test_in_5_hip",
        test_in_32_hip               => "test_in_32_hip",
      },

   });

$glue_logic .= "e_port->new([ local_rstn_ext => 1 => \"input\"]),";
$glue_logic  .= "e_assign->new([\"safe_mode\" => 1]),";
$glue_logic  .= "e_assign->new([\"local_rstn\" => \"safe_mode | local_rstn_ext\"]),";
$glue_logic  .= "e_assign->new([\"any_rstn\" => \"pcie_rstn & local_rstn\"]),";

if ($hip == 1) {
   $glue_logic  .= "e_port->new([ free_100MHz => 1 => \"input\"]),";
}

if (($hip == 1)&&($phy_selection==6)) { # S4GX, A2GX, C4GX
   $glue_logic  .= "e_assign->new([\"test_in[39:33]\" => 0]),";
   if (($rp==0)&&($simple_dma==0)) {
      $add_signals .= "e_signal->new({name => test_in_5_hip, width=> 1 $never_export}),";
      $add_signals .= "e_signal->new({name => test_in_32_hip, width=> 1 $never_export}),";
      $add_signals .= "e_signal->new({name => req_compliance_soft_ctrl, width=> 1 $never_export}),";
      $add_signals .= "e_signal->new({name => set_compliance_mode, width=> 1 $never_export}),";

      $glue_logic  .= "e_port->new([ req_compliance_push_button_n => 1 => \"input\"]),";
      $glue_logic  .= "e_assign->new([\"set_compliance_mode\" => \"usr_sw[0]\"]),";
      $glue_logic  .= "e_assign->new([\"req_compliance_soft_ctrl\" => 0]),";
      $glue_logic  .= "e_assign->new([\"test_in[32]\" => \"test_in_32_hip\"]),";

   } else {
      $glue_logic  .= "e_assign->new([\"test_in[32]\" => 0]),";
   }
}

$glue_logic  .= "e_assign->new([\"test_in[31:9]\" => 0]),";
$glue_logic  .= "e_assign->new([\"test_in[8:6]\" => \"safe_mode ? 4'b010 : usr_sw[3:1]\"]),";

if (($hip == 1) & ($phy_selection == 6)) { # S4GX, A2GX, C4GX
   $glue_logic  .= "e_assign->new([\"test_in[5]\"   => \"test_in_5_hip\"]),";
} else {
   $glue_logic  .= "e_assign->new([\"test_in[5]\"   => \"safe_mode ? 1 : test_in_5_hip\"]),";
}

$glue_logic  .= "e_assign->new([\"test_in[4:0]\" => \"5'b01000\"]),";


    $glue_logic .= "e_process->new({
comment => \"reset Synchronizer\",
clock => \"clk_out_buf\",
reset => \"any_rstn\",
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
  ],
contents => [
e_assign->new([\"any_rstn_r\" => 1]),
e_assign->new([\"any_rstn_rr\" => \"any_rstn_r\"]),
],

}),";



    $glue_logic .= "e_process->new({
comment => \"LED logic\",
clock => \"clk_out_buf\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"alive_cnt\" => 0]),
e_assign->new([\"alive_led\" => 0]),
e_assign->new([\"comp_led\" => 0]),
e_assign->new([\"L0_led\" => 0]),
e_assign->new([\"lane_active_led\" => 0]),
],
contents => [
e_assign->new([\"alive_cnt\" => \"alive_cnt +1\"]),
e_assign->new([\"alive_led\" => \"alive_cnt[$alive_cnt_msb]\"]),
e_assign->new([\"comp_led\" => \"~(test_out_icm[4:0] == 5'b00011)\"]) ,
e_assign->new([\"L0_led\" => \"~(test_out_icm[4:0] == 5'b01111)\"]) ,
e_assign->new([\"lane_active_led[3:0]\" => \"~(test_out_icm[8:5])\"]),
],

}),";

if ($gen2_rate) {
    $glue_logic .= "e_process->new({
comment => \"Gen2 LED logic\",
clock => \"clk_out_buf\",
reset => \"any_rstn_rr\",
asynchronous_contents => [
e_assign->new([\"gen2_led\" => 0]),
],
contents => [
e_assign->new([\"gen2_led\" => \"~gen2_speed\"]),
],

}),";

}

if (($hip==1)&&($phy_selection ==6)&&($rp==0)&&($simple_dma==0)){
   $top_mod->add_contents
   (
    eval($add_signals),
    eval($glue_logic),
    $altpcierd_compliance_test,
    $core_inst,
   );
} else {
   $top_mod->add_contents
   (
    eval($add_signals),
    eval($glue_logic),
    $core_inst,
   );
}



$proj->top($top_mod);
$proj->language($language);
$proj->output();

