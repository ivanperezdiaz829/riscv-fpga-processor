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

use strict;

my $cfi_slave_name = 's1';





sub get_instances
{
  my ($instance_string, $slave_name) = @_;
  
  my @instances = split(/,/, $instance_string);
  
  map {s|/$slave_name$||} @instances;

  printlog("instance string: '$instance_string'; get_instances: qw(" . join(' ', @instances) . ")\n");
  return @instances;
}

sub get_info
{
  my ($code, $ptf, $module_name, $cfi_instances, $slave_name, $new_refdes, $add, $edit, $board_class, $board_refdes_list) = @_;
  my $board_info;
  my $extra_info;



  $add = $add == 1.0;
  $edit = $edit == 1.0;
  






  



  my @cfi_instances = get_instances($cfi_instances, $slave_name);

  my %rd = get_used_ref_deses($ptf, @cfi_instances);
  my %brd = get_board_refdes_list($board_refdes_list);


  if (!defined $board_class || $board_class eq '')
  {
    $board_info = 'no_board';
    $extra_info = $new_refdes;
  }
  else
  {

    if ($edit)
    {
      my $this_module_rd = $new_refdes; # $rd{$module_name};
      if (!defined($brd{$this_module_rd}))
      {
        $board_info = 'error';
        $extra_info = "Reference designator <B>$this_module_rd</B> is not defined in board <B>$board_class</B>.";
      }
      else
      {
        $extra_info = $new_refdes;

        if ((keys %brd == 1) && (keys %rd == 1))
        {
          $board_info = '1_ref_des';
        }
        else
        {
          $board_info = 'some_ref_des';
        }
      }
    }
    else
    {

      

      my %available_rds = %brd;
      for (values %rd)
      {
        delete $available_rds{$_};
      }
      
      my @available_rds = keys %available_rds;
      
      if (0 == @available_rds)
      {
        $board_info = "error";
        $extra_info = "The target board has no remaining reference designators for this flash component.  ";
      }
      elsif ((keys %brd == 1) && (keys %rd == 0))
      {
        $board_info = '1_ref_des';
        $extra_info = $new_refdes;
        if ($new_refdes eq '--none--')
        {
          $extra_info = (each %brd)[0];
        }
      }
      else
      {
        $board_info = 'some_ref_des';

        for (values %rd)
        {
          delete $brd{$_};
        }

        $extra_info = $new_refdes;
        if ($new_refdes eq '--none--')
        {
          $extra_info = (sort keys %brd)[0];
        }
      }
    }
  }
  
  if ($board_info =~ /_ref_des$/ || $board_info eq 'no_board')
  {


    my @dup_mods;
    for my $mod (keys %rd)
    {
      next if $mod eq $module_name;
      
      my $this_module_rd = $rd{$mod};
      next if $this_module_rd eq '--none--';
      
      push (@dup_mods, $mod) if $this_module_rd eq $extra_info;
    }

    if (@dup_mods)
    {
      my $list = join(', ', @dup_mods);
      $board_info = 'warning';
      $extra_info = "Reference designator <B>$extra_info</B> also used by <B>$list</B>";
    }
  }
  
  printlog("board: '$board_info'; extra: '$extra_info'\n");

  if ($code eq 'board')
  {
    print $board_info;
  }
  elsif ($code eq 'extra')
  {
    print $extra_info;
  }
  else
  {
    print "internal error\n";
  }
}

sub get_used_ref_deses
{
  my $ptf = shift;
  


  my @instances = @_;




  my %rd;
  my $module;
  open(PTFFILE, $ptf) || die "Error '$ptf'";
  my $valid_module = 0;
  while (<PTFFILE>)
  {
    if (/^\s+MODULE\s+(\S+)/)
    {
      $module = $1;
      $valid_module = grep {/$module/} @instances;
      next;
    }
    

    if (/^\s*cfi_flash_refdes\s*=\s*"(.*)"/)
    {
      next if !$valid_module;
      $rd{$module} = $1;
      $rd{$module} = '--none--' if $rd{$module} eq '';
    }

    if (/^\s*flash_reference_designator\s*=\s*"(.*)"/)
    {
      next if !$valid_module;
      $rd{$module} = $1;
      $rd{$module} = '--none--' if $rd{$module} eq '';
    }
  }
  close PTFFILE;

  return %rd;
}

sub get_board_refdes_list
{
  my $board_refdes_list = shift;
  
  return () if !$board_refdes_list;
  

  my $sep = ',';
  if ($board_refdes_list !~ /[a-zA-Z0-9]/)
  {
    $sep = substr($board_refdes_list, 0, 1);
  }
  my %board_rd;
  %board_rd = map {($_, 1)} split(/$sep/, $board_refdes_list);

  return wantarray ? %board_rd : (0 + keys %board_rd);
}

sub generator_program
{
  require 'europa_all.pm';
  require 'wiz_utils.pm';
  require 'format_conversion_utils.pm';
  require 'refdes_check.pm';

  my $project = e_project->new(@_);
  

  my $error = refdes_check::check($project);
  if ($error)
  {
    print STDERR "\nERROR:\n$error\n";
    ribbit();
  }



  my $data_width = $project->SBI($cfi_slave_name)->{Data_Width};
  
  my $target_ptf_assignments = 
  {
    make_individual_byte_lanes  => ($data_width > 8) ? 1 : 0,
    num_lanes                   => ($data_width / 8),
  };

  $project->do_makefile_target_ptf_assignments(
    $cfi_slave_name,
    ['flashfiles', 'dat', 'programflash', 'sym',],
    $target_ptf_assignments,
  );
  

  $project->ptf_to_file();




}

sub printlog
{
  my $string_to_figure_out_build = '

  ';
  return if ($string_to_figure_out_build =~ /^\s+$/s);

  my $printable = join('', @_);
  my $log = 'cfi_flash.log';
  open (LOGFILE, ">>$log") || die "error: Can't open log file '$log' for append.";

  print LOGFILE $printable;
  close LOGFILE;
}





exit if (0 == @ARGV);

my ($sec, $min, $hour, $mday, $mon, $year) = localtime;

printlog sprintf("%02d:%02d:%02d %d/%d/%04d\n", $hour, $min, $sec, $mon + 1, $mday, $year + 1900);
printlog(join("; ", @ARGV), "\n");

my $cmd = shift;
{
  $cmd eq 'get_board_info' && do {get_info('board', @ARGV); last};
  $cmd eq 'get_extra_info' && do {get_info('extra', @ARGV); last};




  do {generator_program($cmd, @ARGV); last};
}

printlog("\n");

