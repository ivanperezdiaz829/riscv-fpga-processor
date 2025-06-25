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






















package em_mailbox;
use Exporter;
@ISA = Exporter;
@EXPORT = qw(
    &make_em_mailbox
);

use europa_all;
use europa_utils;

use strict;





























my $mutex0_addr     = 0;
my $reset_reg0_addr = 1;
my $mutex1_addr     = 2;
my $reset_reg1_addr = 3;


my $own = "31:16";
my $val = "15:0";







sub make_em_mailbox
{
    my ($Opt, $project) = (@_);



    e_register->adds(
        { out => e_signal->adds(['mutex0', 32]),
          in => 'data_from_cpu',
          enable => 'mutex_write_enable0',
          async_value => "32'b0",
        }),


    e_register->adds(
    { out => e_signal->adds(['mutex1', 32]),
      in => 'data_from_cpu',
      enable => 'mutex_write_enable1',
      async_value => "32'b0",
    }),


    e_register->adds({
        out         => "reset_reg0",
        in          => "1'b0",
        enable      => "reset_write_enable0",
        async_value => "1'b1",
    });


    e_register->adds({
        out         => "reset_reg1",
        in          => "1'b0",
        enable      => "reset_write_enable1",
        async_value => "1'b1",
    });



    e_assign->adds (["mutex_free0", "mutex0[$val] == 0"]);
    e_assign->adds (["mutex_free1", "mutex1[$val] == 0"]);



    e_assign->adds (["mutex_own0", "mutex0[$own] == data_from_cpu[$own]"]);
    e_assign->adds (["mutex_own1", "mutex1[$own] == data_from_cpu[$own]"]);



    e_assign->adds 
        (["select_mutex0",     "chipselect & (address == $mutex0_addr)"],
         ["select_mutex1",     "chipselect & (address == $mutex1_addr)"],
         ["select_reset_reg0", "chipselect & (address == $reset_reg0_addr)"],
         ["select_reset_reg1", "chipselect & (address == $reset_reg1_addr)"]);




    e_assign->adds 
        (["mutex_write_enable0",
            "(mutex_free0 | mutex_own0) & select_mutex0 & write"],
         ["mutex_write_enable1",
            "(mutex_free1 | mutex_own1) & select_mutex1 & write"],
         ["reset_write_enable0", 
            "chipselect & write & select_reset_reg0"],
         ["reset_write_enable1", 
            "chipselect & write & select_reset_reg1"]);






    e_assign->add(
        [["data_to_cpu"],
          "select_mutex0     ? mutex0 : 
           select_mutex1     ? mutex1 : 
           select_reset_reg0 ? reset_reg0 : 
                               reset_reg1"]  
        );   
};

1;
