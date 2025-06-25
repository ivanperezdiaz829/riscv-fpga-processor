package e_generate;



use europa_utils;
use e_expression;
use e_thing_that_can_go_in_a_module;

@ISA = ("e_thing_that_can_go_in_a_module");

use strict;


my %fields = (
              _order 		 => ["index","start","end","contents","label"],
	      _index		 => e_expression->new(),
              _index_sig 	 => e_signal->new(),
	      _contents  	 => [],
	      inst_name_for_vlog => "",
	      label     	 => "",
	      start 		 => 0,
	      end		 => 0,
              );
my %pointers = ();

&package_setup_fields_and_pointers(__PACKAGE__,
     \%fields, 
     \%pointers,
     );

sub index
{
   my $this = shift;
   my $index = $this->_index(@_);
   if (@_)
   {
      $index->parent($this);
      if (!$index->_has_signal())
      {
         my $index_sig = $this->_index_sig();
         $index_sig->name($index->expression());
         $index_sig->copied(1);
         $index_sig->parent($this);
      }
   }
   return $index;
}

sub contents
{
   my $this = shift;
   
   if (@_)
   {
      print "\n****************************************************\n";
      my $then = $this->_contents
          ($this->_make_updated_contents_array(@_));
      return $then;
   }
   return $this->_loop_code();
}

sub convert_to_assignments
{
   my $this = shift;
   my $condition = shift;
   my @conditions = @$condition;  # Make a local copy.

   my $updated_contents = $this->_contents();
   my @loops = %$updated_contents;
   my $index = $this->index->expression();

   foreach my $loop (@loops)
   {
      foreach my $content (reverse (@{$updated_contents}))
      {
	 $content->convert_to_assignments(\@conditions);
      }
   }


}

sub convert_to_assignment_mux
{
   my $this = shift;
   return $this->parent()->convert_to_assignment_mux(@_);
}


sub to_verilog

{

  my $this   = shift;
  my $indent = shift;
  my $vs = "";
  my $ind = $this->_index()->to_verilog();
  my $index = $this->_index()->to_verilog();
  my $start = $this->start();
  my $end = $this->end();
  my $inst_name = $this->inst_name_for_vlog();
  my @_contents = @{$this->_contents()};
  my $incremental_indent = $this->indent();
  
  #print "\n\n -> $ind\n\n";
  
  if (@_contents)
  {
	  my $thing_indent = $indent.($incremental_indent x 2);  
	  my $code_vs;
	  my $_contents_vs;
	  foreach my $t (@_contents)
	  {
		$_contents_vs .= $t->to_verilog($thing_indent);
	  }
	  
	  for ( $ind = $start; $ind < $end; $ind++)
	  {
		$code_vs = $_contents_vs;
		$code_vs =~ s/$inst_name/$inst_name$ind/g;
		$code_vs =~ s/$index/$ind/g;
		print "\n\n -> $code_vs\n\n";
		$vs .= "$code_vs";
	  };
  }
  return ($vs);

}


sub to_vhdl
{
  my $this  = shift;
  my $indent = shift;
  my $ind = $this->index($this->_index());
  my $start = $this->start();
  my $end = $this->end();
  my $label = $this->label();
  
  my $incremental_indent = $this->indent();  
  my $vs = "";

  my @_contents = @{$this->_contents()};
  if (@_contents)
  {
	  my $thing_indent = $indent.($incremental_indent x 2);  
	  my $_contents_vs;
	  my $code_vs;
	  my $match;
	  my $prev;
	  my $post;
	  $vs .= "$indent $label: for $ind in $start to $end generate\n";
	  foreach my $t (@_contents)
	  {  
		  # print "\n\n -> $t\n\n";
		  $code_vs .= "$indent$indent";
		  $code_vs .= $t->to_vhdl($indent.($incremental_indent x 1));

		  # foreach my $test ($code_vs =~ m/:/g)
		  # {
			#   $post = $';
			#   $prev = $`;
			#   $match = $&.$post;
			#   if (($prev =~ m/=>/)||($prev =~ m/<=/))
			#   {
			# 	  $match =~ s/:/downto/g;
			# 	  $match =~ s/==/=/g;
			# 	  $code_vs = $prev.$match;
			#   print "\n\n -> $prev$match\n\n";
			#   }
			 print "\n\n -> $code_vs\n\n";
		  # }
	  }
	  $vs .= "$code_vs\n$indent end generate;\n\n";
  }
  
  return ($vs);

}

##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################
##########################################################################################################################################################################

1;
