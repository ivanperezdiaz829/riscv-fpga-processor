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
use strict;

my $project = e_project->new(@ARGV);
my $module = $project->top();

my $SLAVE = $project->module_ptf()->{"SLAVE s1"};

my $DW = $project->SBI("s1")->{Data_Width};
my $AW = $project->SBI("s1")->{Address_Width};
my $BEW = int($DW / 8);

my $SLAVE = $project->module_ptf()->{"SLAVE s1"};

my $system_frequency = $project->get_module_clock_frequency();

my $SLAVE_SBI = $SLAVE->{SYSTEM_BUILDER_INFO};  






if ($system_frequency > 100E6)
{
   $SLAVE_SBI->{Read_Wait_States} = '20ns';
   $SLAVE_SBI->{Write_Wait_States} = '10ns';
   $SLAVE_SBI->{Hold_Time} = '10ns';
   $SLAVE_SBI->{Setup_Time} = '5ns';
}
elsif ($system_frequency > 50E6)
{
   $SLAVE_SBI->{Read_Wait_States} = 1;
   $SLAVE_SBI->{Write_Wait_States} = 1;
   $SLAVE_SBI->{Hold_Time} = 1;
   $SLAVE_SBI->{Setup_Time} = 1;
}
else
{
   $SLAVE_SBI->{Read_Wait_States} = '0ns';
   $SLAVE_SBI->{Write_Wait_States} = '0ns';
   $SLAVE_SBI->{Hold_Time} = 'half';
   $SLAVE_SBI->{Setup_Time} = 0;
}



my @port_list =
            (
               e_port->new(
               {
                  name      => 'data',
                  width     => $DW,
                  direction => "inout",
                  type      => "data",
               }),
               e_port->new(
               {
                  name      => 'address',
                  width     => $AW,
                  direction => "input",
                  type      => "address",
               }),
               e_port->new(
               {
                  name      => 'read_n',
                  width     => "1",
                  direction => "input",
                  type      => "read_n",
               }),
               e_port->new(
               {
                  name      => 'write_n',
                  width     => "1",
                  direction => "input",
                  type      => "write_n",
               }),
               e_port->new(
               {
                  name      => 'be_n',
                  width     => $BEW,
                  direction => "input",
                  type      => "byteenable_n",
               }),
               e_port->new(
               {
                  name      => 'select_n',
                  width     => "1",
                  direction => "input",
                  type      => "chipselect_n",
               }),
            );
$module->add_contents(@port_list);




if ($project->module_ptf()->{SYSTEM_BUILDER_INFO}{Make_Memory_Model}) {
    my $options = 
    { name => $project->_target_module_name(),
      make_individual_byte_lanes => 1,
      num_lanes => $BEW,
    };
    $project->do_makefile_target_ptf_assignments
        (
         's1',
         ['dat', 'sym',],
         $options,
         );
} else { # Destroy memory model make instructions
    $project->do_makefile_target_ptf_assignments
        (
         '',
         [],
         );
};

$project->ptf_to_file();
