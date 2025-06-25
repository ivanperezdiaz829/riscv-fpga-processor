# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 3057 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/counter.al)"
# ----------------------------------


sub counter {
  my $class = shift;
  my (@names) = @_;

  my %methods;

  my $name;
  foreach $name (@names) {

    $methods{$name} =
      sub {
        my $self = shift;
        $self->{$name} = $_[0]
          if @_;
        $self->{$name} = 0
          unless exists $self->{$name};
        return $self->{$name};
      };

    $methods{"${name}_incr"} =
      sub {
        my $self = shift;
        $self->{$name} = 0
          unless exists $self->{$name};
        $self->{$name} += @_ ? $_[0] : 1;
      };

    $methods{"${name}_reset"} =
      sub {
        my $self = shift;
        $self->{$name} = 0;
      }

  }

  $class->install_methods (%methods);
}

# end of Class::MethodMaker::counter
1;
