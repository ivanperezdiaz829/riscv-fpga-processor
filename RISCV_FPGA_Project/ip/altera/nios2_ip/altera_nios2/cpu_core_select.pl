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






















use europa_all;
use e_project;
use strict;
use build_debug_proj; 

my $quartus_rootdir_env_varname = "QUARTUS_ROOTDIR";
my $quartus_rootdir = $ENV{$quartus_rootdir_env_varname};
if ($quartus_rootdir eq "") {
    Progress("  The QUARTUS_ROOTDIR environment variable is empty");
    exit(1);
}

if (! -d $quartus_rootdir) {
    Progress("  QUARTUS_ROOTDIR environment variable contains" .
      " '$quartus_rootdir' but this isn't a directory");
    exit(1);
}

my $project = e_project->new(@ARGV);

our $lib_dir = $project->_module_lib_dir();

my $cpu_lib_dir = $lib_dir . "/cpu_lib";
if (! -d $cpu_lib_dir) {
    Progress("  Missing dependent directory '$cpu_lib_dir'" .
      " (found via QUARTUS_ROOTDIR environment variable which is" .
      " '$quartus_rootdir')");
    exit(1);
}
unshift(@INC, $cpu_lib_dir);

my $nios_lib_dir = $lib_dir . "/nios_lib";
if (! -d $nios_lib_dir) {
    Progress("  Missing dependent directory '$nios_lib_dir'" .
      " (found via QUARTUS_ROOTDIR environment variable which is" .
      " '$quartus_rootdir')");
    exit(1);
}
unshift(@INC, $nios_lib_dir);


our $always_encrypt = $project->WSA()->{always_encrypt};
our $encrypt;


our $perl_executable;
our $cpu_core;
our $cmd_suffix;

our $plain_cpu_core = $project->_module_lib_dir() . "/cpu_core.pl";
our $crypt_cpu_core = $project->_module_lib_dir() . "/cpu_core.epl";

if ($always_encrypt && ! -r $crypt_cpu_core) {
    Progress( 
      "  always_encrypt in PTF file is 1 but can't read $crypt_cpu_core");
    exit(1);
}

if (-r $plain_cpu_core && !$always_encrypt) {
    $perl_executable = $^X;
    $cpu_core = $plain_cpu_core;
    $encrypt = 0;
} elsif (-r $crypt_cpu_core) {
    $perl_executable = $project->_module_lib_dir() . "/eperl";
    $cpu_core = $crypt_cpu_core;
    $encrypt = 1;


    $cmd_suffix = "--bogus=1";
} else {
    Progress("  Can't read file $plain_cpu_core or $crypt_cpu_core");
    exit(1);
}

our @includes = map {"-I".$_} @INC;


our @gen_cmd = (
               $perl_executable,
               @includes,
               "--",
               $cpu_core,
               @ARGV
               );

if ($encrypt && $project->SYS_WSA()->{do_build_sim}) {

    push(@gen_cmd, "--simgen=1");

    Progress("  IP functional simulation model enabled: Uncheck System Generation Simulation box for faster generation if HDL Simulation not required.");
}

if ($cmd_suffix) {
    push(@gen_cmd, $cmd_suffix);
}

our $exit_status = launch_cmd($project, \@gen_cmd);

exit($exit_status);

sub launch_cmd
{
    my $project = shift;
    my $cmdArrayRef = shift;

    system(@$cmdArrayRef);
    my $exit_status = ($? >> 8);

    return $exit_status;
}
