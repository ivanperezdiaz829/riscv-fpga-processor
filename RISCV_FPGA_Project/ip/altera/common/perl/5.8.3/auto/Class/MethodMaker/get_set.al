# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 778 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/get_set.al)"
use constant GS_PATTERN_MAP =>
  {
   java          => [ undef, undef, 'get*', 'set*' ],
   eiffel        => [ undef, undef, '*', 'set_*' ],
   compatibility => [ '*', 'clear_*', undef, undef ],
   noclear       => [ '*', undef, undef, undef ],
  };
use constant GS_PATTERN_SPEC => join '|', keys %{GS_PATTERN_MAP()};

# Regex for -set_once. The action, if any, is in $1
use constant CMM_SET_ONCE_OPTION => qr/^-(?:set_once(?:_or_(\w+))?)/x;

sub get_set {
  my ($class, @args) = @_;
  my @methods;

  # @template is a list of pattern names for the methods.
  # Postions are perl:get/set, clear, get, set
  my $template = ${GS_PATTERN_MAP()}{'compatibility'};
  my %opts = ( '-static' => 0 );

  my $arg;
  foreach $arg (@args) {
    if ( my $ref = ref $arg ) {
      if ( $ref eq 'ARRAY' ) {
	$template = $arg;
	# Check for duplicate patterns.
	my %patterns;
	for (grep defined, @$template) {
	  croak "Duplicate pattern: $_"
	    if $patterns{$_};
	  $patterns{$_}++;
	}
      } else {
	croak "get_set does not handle this ref type: $ref";
      }
    } elsif ( substr ($arg, 0, 1) eq '-' ) {
      my $opt_name = substr ($arg, 1);
      if ( exists ${GS_PATTERN_MAP()}{$opt_name} ) {
	$template = ${GS_PATTERN_MAP()}{$opt_name};
      }
      elsif ( $opt_name eq 'static' ){
	$opts{ $arg } = 1;
      }
      elsif ( $arg =~ CMM_SET_ONCE_OPTION ){
         $class->_process_set_once($arg, \%opts);
      }
      else {
	croak "Unrecognised option: $arg to get_set";
      }
    } else {
      push @methods, $class->_make_get_set ($arg, $template, \%opts);
    }
  }

  $class->install_methods (@methods);
}

# end of Class::MethodMaker::get_set
1;
