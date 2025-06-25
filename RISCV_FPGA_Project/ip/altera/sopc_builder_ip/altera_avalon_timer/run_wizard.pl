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

































































$fill_in_your_class_name_here="altera_avalon_timer";


for ($i=0; $i <= $#ARGV; $i++)
{
  if (index($ARGV[$i],"--target_module_name")!=-1)
  { $modulename=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--sopc_directory")!=-1)
  { $sopcdir=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--class_name")!=-1)
  { $classname=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--class_directory")!=-1)
  { $classdir=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--system_directory")!=-1)
  { $systemdir=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--target_module_name")!=-1)
  { $target_module_name=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
  if (index($ARGV[$i],"--system_name")!=-1)
  { $system_name=substr($ARGV[$i],index($ARGV[$i],"=")+1); }
}



$classname=$fill_in_your_class_name_here if($classname eq "");



$classdir="./altera_avalon_timer/" if ($classdir eq "");



@args = ("${sopcdir}/bin/jre1.3/bin/javaw",
"-classpath ${sopcdir}/bin/sopc_common.jar",
"sopc_wizard.sopc_wizard",
"--sopc_directory=${sopcdir}",
"--class_directory=${classdir}",
"--class_name=${classname}",
"--system_directory=${systemdir}",
"--target_module_name=${target_module_name}",
"--system_name=${system_name}",
"${systemdir}${modulename}.v");

$rc = 0xffff & system @args;


$rc;
