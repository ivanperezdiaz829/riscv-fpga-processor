#Copyright (C)1991-2002 Altera Corporation
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
use strict;

#-------------------------------------------------------------------------------
# Common procecure for embedded IP component generation
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# usage()
#
# help message
#
# return:
#   null
#
sub 
usage
{
    my $PN = "generate_rtl.pl";
    
    print STDERR "Usage: $PN [<options>]*\n";
    print STDERR "  --help            Show usage message\n";
    print STDERR "  --verilog         Generate Verilog output (default)\n";
    print STDERR "  --vhdl            Generate VHDL output\n";
    print STDERR "  --name=<name>     Module name (required)\n";
    print STDERR "  --dir=<dir>       Output RTL directory (default is \".\")\n";
    print STDERR "  --quartus_dir=<dir> Quartus installation directory\n";
    print STDERR "  --do_build_sim=<1 or 0>   Create simulation files (default is \"0\" )\n";
    print STDERR "  --sim_dir=<dir>   Output RTL simulation directory\n";
    print STDERR "  --config=<f_name> Input file for component configuration\n";
}

#-------------------------------------------------------------------------------
# process_args()
#
# process command-line arguements
#
# return:
#   project info hash
#
sub
process_args
{
    my $infos;
    my $help;
    my $verilog;
    my $vhdl;
    my $name;
    my $dir;
    my $quartus_directory;
    my $do_build_sim;
    my $sim_dir;
    my $config_file;

    if (!GetOptions( 
      'help|h'          => \$help,
      'verilog'         => \$verilog,
      'vhdl'            => \$vhdl,
      'name=s'          => \$name,
      'dir=s'           => \$dir,
      'quartus_dir=s'   => \$quartus_directory,
      'do_build_sim=s' => \$do_build_sim,
      'sim_dir=s'       => \$sim_dir,
      'config=s'        => \$config_file,
    )) {
        usage();
        exit(1);
    }

    if ($help) {
        usage();
        exit(0);
    }

    ribbit("Missing module name for generation") 
      if ($name eq "");

    ribbit("Missing path to Quartus installation directory") 
      if ($quartus_directory eq "");

    ribbit("Quartus installation directory '$quartus_directory' isn't a directory") 
      if (! -d $quartus_directory);

    ribbit("Can't find config file '$config_file'") if (! -f $config_file);

    # validate the parameter before add to infos hash
    $infos = do($config_file);
    if ($@) {
        ribbit("Failure compiling '$config_file' - $@");
    } elsif (! defined($infos)) {
        ribbit("Failure reading '$config_file' - $!");
    } elsif (! $infos) {
        ribbit("Failure processing '$config_file'");
    }

    # Put settings into project_info hash and have them overwrite what
    # might be already there.
    if ($name) {
        $infos->{project_info}{name} = $name;
    }

    if ($vhdl) {
        $infos->{project_info}{language} = "vhdl";
    } else {
        $infos->{project_info}{language} = "verilog";
    }

    if ($dir) {
        $infos->{project_info}{system_directory} = $dir;
    } else {
        $infos->{project_info}{system_directory} = ".";
    }

    if ($do_build_sim) {
        $infos->{project_info}{simulation_directory} = $sim_dir;
        $infos->{project_info}{do_build_sim} = 1;
    } else {
        $infos->{project_info}{simulation_directory} = "";
        $infos->{project_info}{do_build_sim} = 0;
    }
    
    return $infos;
}

#-------------------------------------------------------------------------------
# prepare_project($infos)
#
# prepare project directory
#
# return:
#   e_project object
#
sub
prepare_project
{
    my $infos = shift;
    my $module_name;            # Module instance name
    my $language;               # Verilog or VHDLs
    my $system_directory;
    my $do_build_sim;
    my $simulation_directory;
    
    # prepare generation information
    $module_name = $infos->{project_info}{name};
    $language = $infos->{project_info}{language};
    
    $system_directory = $infos->{project_info}{system_directory};
    $do_build_sim = $infos->{project_info}{do_build_sim};
    $simulation_directory = $do_build_sim ?
        $infos->{project_info}{simulation_directory} :
        undef;
    
    # prepare simulation directory
    ensure_dir($system_directory);
    if ($do_build_sim) {
        ensure_dir($simulation_directory);
    }
    
    # start component generation
    my $top_module = e_module->new({
        name => $module_name,
        do_ptf => 0, # This avoids a warning about old-style ptf format.
    });
    
    my $project = e_project->new({
      top => $top_module,
      language => $language,
      _system_directory => $system_directory,
    });
    
    return $project;
}

#-------------------------------------------------------------------------------
# ensure_dir($path)
#
# create directory
#
# return:
#   null
#
sub
ensure_dir
{
    my $path = shift;

    if (! -d $path) {
        mkdir($path) || ribbit("Can't make directory '$path'");
    }
}

1;