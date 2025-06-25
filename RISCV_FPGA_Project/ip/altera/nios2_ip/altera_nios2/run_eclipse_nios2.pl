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


$| = 1;         # set flushing on STDOUT


my $in_cmd = shift;
my ($quartus_dir, $qbin, $sopc_kit_dir, $system_dir, $system_name) = split ',',$in_cmd;

if ($sopc_kit_dir eq "")
{
    $sopc_kit_dir = $ENV{'SOPC_KIT_NIOS2'};
}


if ($^O =~ /win/i)
{
	$eclipse_nios2 = "$sopc_kit_dir" . "\\bin\\eclipse-nios2.exe";
} 
else
{
	$eclipse_nios2 = "$sopc_kit_dir" . "/bin/eclipse-nios2";
}



delete $ENV{QUARTUS_QENV};


chdir "$sopc_kit_dir" . "\\bin";
my $result = system
	$eclipse_nios2
	;

1;
