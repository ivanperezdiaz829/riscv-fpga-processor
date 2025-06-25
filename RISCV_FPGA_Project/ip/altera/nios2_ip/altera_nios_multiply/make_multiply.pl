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
use e_custom_instruction_slave;
use strict;

my @arguments =  (@ARGV);
my $project = e_project->new(@arguments);


my %Options = &copy_of_hash($project->SBI("s1"));

&make_multiply (\%Options, $project);

$project->output();


sub validate_multiply
{
  my ($Opt, $project) = (@_);

  &validate_parameter ({hash    => $Opt,
                        name    => "Data_Width",
                        type    => "integer",
                        allowed => [32],
                        default => 32,
                       });
  &validate_parameter ({hash    => $Opt,
                        name    => "name",
                        type    => "string",
                        default => $project->{_target_module_name},
                       });





  if ($project->device_family =~ /stratix/i) {

    my $default_stratix_multiplier_cycles = 3;

    if (exists $project->SYS_WSA()->{dedicated_multiplier_cycles}) {
      $Opt->{ci_cycles} = $project->SYS_WSA()->{dedicated_multiplier_cycles};
    } else {
      $Opt->{ci_cycles} = $default_stratix_multiplier_cycles;
    }
  } else {
    $Opt->{ci_cycles} = $project->WSA()->{ci_cycles};
  }

  if (exists $project->WSA()->{dedicated_multiplier_circuitry}) {
    $Opt->{dedicated_multiplier_circuitry}
      = $project->WSA()->{dedicated_multiplier_circuitry};
  } 

  &validate_parameter ({hash    => $Opt,
                        name    => "ci_cycles",
                        type    => "integer",
                        default => 3,
                       });

  &validate_parameter ({hash    => $Opt,
                        name    => "dedicated_multiplier_circuitry",
                        type    => "string",
                        allowed => ["YES", "NO", "AUTO"],
                        default => "AUTO",
                        });
}

sub make_multiply 
{
  my ($Opt, $project) = (@_);

  &validate_multiply ($Opt, $project);

  my $module = $project->top();
  my $width = $Opt->{Data_Width};

  my $lpm_multiply_module = &make_lpm_multiply ($Opt, $project);
  
  $module->add_contents (
      e_port->news (
          [dataa     => $width >> 1,            "in" ],
          [datab     => $width >> 1,            "in" ],
          [result    => $width,                 "out"],
          [clock     => 1,                      "in" ],
          [clken     => 1,                      "in" ],
          [aclr      => 1,                      "in" ],
      ),
      e_custom_instruction_slave->new ({
          name     => "s1",
          type_map => {
            result => "result",
            dataa  => "dataa",
            datab  => "datab",
            clock  => "clk",
            clken  => "clk_en",
            aclr   => "reset",
          },
      }),



      e_instance->new ({module  => $lpm_multiply_module}),

  );

}


sub make_lpm_multiply
{
  my ($Opt, $project) = (@_);

  my $width = $Opt->{Data_Width};
  my $lpm_pipeline = $Opt->{ci_cycles} - 1;
   
  my $module = e_module->new ({name => $Opt->{name}."_black_box_module"});
  $module->do_black_box (1);
  $project->add_module($module);
  my $marker = e_default_module_marker->new ($module);

  e_port->adds 
      ([dataa     => $width >> 1,            "in" ],
       [datab     => $width >> 1,            "in" ],
       [result    => $width,                 "out"],
       );

  my @outputs = qw(result); 
  my @inputs = qw(dataa datab);
  if ($lpm_pipeline > 0) {
      e_port->adds
          ([clock     => 1,                      "in" ],
           [clken     => 1,                      "in" ],
           [aclr      => 1,                      "in" ],
           );
    push @inputs, qw(clock clken aclr);
  }


  my %ebi_parameter_map = (
    lpm_widtha => $width >> 1,
    lpm_widthb => $width >> 1,
    lpm_widthp => $width,
    lpm_widths => $width,
    lpm_pipeline => $lpm_pipeline,
    lpm_representation => qq("UNSIGNED"),
  );

  if ($project->device_family =~ /stratix/i) {
    my $value = $Opt->{dedicated_multiplier_circuitry};

    e_parameter->add
      ([  "lpm_hint", "DEDICATED_MULTIPLIER_CIRCUITRY=$value", "STRING"  ]);
      
    $ebi_parameter_map{lpm_hint}= (qq("DEDICATED_MULTIPLIER_CIRCUITRY=$value"));
  }
  
  e_blind_instance->add({
    tag => 'compilation',
    name => 'the_lpm_mult',
    module => 'lpm_mult',
    in_port_map => {
      map {($_, $_)} @inputs
    },
    out_port_map => {
      map {($_, $_)} @outputs
    },
    parameter_map => \%ebi_parameter_map,
  });

       

  if ($lpm_pipeline > 0) {
      e_register->add ({
          q         => e_signal->new(["result", $width]),
          d         => "dataa * datab",
          delay     => $lpm_pipeline,
          enable    => "clken",
          clock     => "clock",
          async_set => "~(aclr)",
          tag       => "simulation",
      });
  } else {
      e_assign->add ({
          lhs       => e_signal->new(["result", $width]),
          rhs       => "dataa * datab",
          tag       => "simulation",
      });
  }


















































 return $module;
}

