package e_testbench;



use europa_utils;

use e_thing_that_can_go_in_a_module;

@ISA = ("e_thing_that_can_go_in_a_module");

use strict;



my %fields = (
		display	=>"",
		severity_level => "",
              );

my %pointers = ();

&package_setup_fields_and_pointers(__PACKAGE__,
     \%fields, 
     \%pointers,
     );



sub to_verilog

{

  my $this   = shift;
  my $indent = shift;
  my $text_stuff = "";

  $text_stuff = $this->display();
  
  my $return_string = "\n$indent begin\n";
  $return_string .= qq[$indent\$display(\"$text_stuff\");\n];
  $return_string .= qq[$indent\$finish(2);\n];
  $return_string .= "\n$indent end \n";
  
  return ($return_string);

}



sub to_vhdl

{

  my $this  = shift;
  my $indent = shift;
  my $text_stuff = "";
  my $report_type = "";
  
  
  $text_stuff = $this->display();
  $report_type = $this->severity_level();
  
  if($report_type eq "")
  { $report_type = "severity Error"; }
  else{ $report_type = "severity ".$this->severity_level(); }
  
  my $return_string = qq[$indent report \"$text_stuff\" $report_type;\n];

  return ($return_string);

}

1;



