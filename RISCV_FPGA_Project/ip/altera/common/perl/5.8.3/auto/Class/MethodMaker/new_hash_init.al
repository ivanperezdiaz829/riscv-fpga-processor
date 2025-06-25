# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 319 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/new_hash_init.al)"
# ----------------------------------------------------------------------


sub new_hash_init {
  my ($class, @args) = @_;
  my %methods;
  foreach (@args) {
    $methods{$_} = sub {
      my $class = shift;
      my $self = ref ($class) ? $class : bless {}, $class;

      # Accept key-value attr list, or reference to unblessed hash of
      # attr
      my %args =
        (scalar @_ == 1 and ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_;

      foreach (keys %args) {
        if ( my $setter = $class->can(" __CMM__ $_") ) {
          $setter->($self, $args{$_});
        } else {
          $self->$_($args{$_});
        }
      }
      $self;
    };
  }
  $class->install_methods(%methods);
}

# end of Class::MethodMaker::new_hash_init
1;
