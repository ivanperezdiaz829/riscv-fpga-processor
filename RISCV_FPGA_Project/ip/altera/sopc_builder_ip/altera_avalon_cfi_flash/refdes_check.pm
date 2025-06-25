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
use europa_all;
package refdes_check;

sub check
{
  my $project = shift;
  my $error;





  my $sys_ptf = $project->system_ptf();
  
  die("No project!") if !$sys_ptf;

  my $class = $sys_ptf->{"MODULE @{[$project->_target_module_name()]}"}->{class};
  die("No class!") if !$class;
  
  my $module_classes = $project->get_module_hash("class");
  


  my %rd;
  for my $module_name (keys %$module_classes)
  {
    my $module_ptf = $sys_ptf->{"MODULE $module_name"};
    
    next if $module_ptf->{class} ne $class;
    





    for my $module_key (keys %$module_ptf)
    {
      next if $module_key !~ /SLAVE\s*(\S+)$/;
      my $rdkey = "$module_name/$1";
      my $refdes = $module_ptf->{$module_key}->{WIZARD_SCRIPT_ARGUMENTS}->{flash_reference_designator};
      $rd{$rdkey} = $refdes;
    }
  }
  
  my %brd;

  my $board_class = $sys_ptf->{WIZARD_SCRIPT_ARGUMENTS}->{board_class};
  if ($board_class ne '')
  {
    my $board_section = $sys_ptf->{WIZARD_SCRIPT_ARGUMENTS}->{BOARD_INFO};
    if (!defined($board_section->{$class}))
    {



      $error .= "Board component '$board_class' has no reference designators for components of class '$class'\n";
    }
    else
    {
      my $rdstring = $board_section->{$class}->{reference_designators};
      %brd = get_board_refdes_list($rdstring);


      $error .= test_illegal_rd(\%rd, \%brd);
    }
  }


  $error .= test_duplicates(\%rd, \%brd);


  return $error;
}

sub test_illegal_rd
{
  my ($rdhash, $brd) = @_;
  



  my $no_board_defined = keys %$brd == 0;

  my @no_refdes;
  my @illegal_refdes;
  for my $mod (keys %$rdhash)
  {
    my $rd = $rdhash->{$mod};
    my $module_name_without_slave = $mod;
    $module_name_without_slave =~ s|/.*$||;
    
    if (!defined($rd) || $rd eq '' || $rd eq '--none--')
    {
      push @no_refdes, $module_name_without_slave;
      next;
    }
    
    if (!$no_board_defined && !defined($brd->{$rd}))
    {
      push @illegal_refdes, "$module_name_without_slave ('$rd')";
      next;
    }
  }
  
  my $error_string;
  if (@illegal_refdes)
  {
    my $plural = @illegal_refdes > 1 ? "s" : "";
    $error_string .= "Illegal reference designator$plural in module$plural ";
    $error_string .= join(", ", @illegal_refdes);
    $error_string .= ".\n";
  }
  
  if (@no_refdes)
  {
    my $plural = @no_refdes > 1 ? "s" : "";
    $error_string .= "No reference designator$plural specified for module$plural ";
    $error_string .= join(", ", @no_refdes);
    $error_string .= ".\n";
  }
  
  return $error_string;
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

sub test_duplicates
{
  my ($rdhash, $brd) = @_;
  





  my %reverse_hash;
  for my $mod (keys %$rdhash)
  {
    my $rd = $rdhash->{$mod};
    my $module_name_without_slave = $mod;
    $module_name_without_slave =~ s|/.*$||;
    



    next if ($rd eq '' || $rd eq '--none--');
    if (!defined $reverse_hash{$rd})
    {
      $reverse_hash{$rd} = [$module_name_without_slave];
    }
    else
    {
      push @{$reverse_hash{$rd}}, $module_name_without_slave;
    }
  }
  
  my @errors;
  for my $rd (keys %reverse_hash)
  {
    my @mods = @{$reverse_hash{$rd}};
    if (@mods > 1)
    {
      push @errors, "Reference designator '$rd' shared by modules " . join(", ", @mods) . ".\n";
    }
  }
  
  return join('', @errors);
}

1;
