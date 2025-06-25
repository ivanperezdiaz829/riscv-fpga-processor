# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 246 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/new_with_init.al)"
# ----------------------------------------------------------------------


sub new_with_init {
  my ($class, @args) = @_;
  my %methods;
  foreach (@args) {
    my $field = $_;
    $methods{$field} = sub {
      my $class = shift;
      $class = ref $class || $class;
      my $self = {};
      bless $self, $class;
      $self->init (@_);
      $self;
    };
  }
  $class->install_methods(%methods);
}

# end of Class::MethodMaker::new_with_init
1;
