# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 3013 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/abstract.al)"
# ----------------------------------------------------------------------


sub abstract {
  my ($class, @args) = @_;
  my %methods;

  my $TargetClass = $class->find_target_class;

  foreach (@args) {
    my $field = $_;
    $methods{$field} = sub {
      my ($self) = @_;
      my $calling_class = ref $self;
      die
        qq#Can't locate abstract method "$field" declared in #.
        qq#"$TargetClass", called from "$calling_class".\n#;
    };
  }
  $class->install_methods(%methods);
}

# end of Class::MethodMaker::abstract
1;
