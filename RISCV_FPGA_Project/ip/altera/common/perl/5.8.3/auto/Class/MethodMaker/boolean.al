# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 1542 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/boolean.al)"
sub boolean {
  my ($class, @args) = @_;
  my %methods;

  my $TargetClass = $class->find_target_class;

  my $bstore = join '__', $TargetClass, 'boolean';

  my $boolean_fields =
    $BooleanFields{$TargetClass};

  $methods{'bits'} =
    sub {
      my ($self, $new) = @_;
      defined $new and $self->{$bstore} = $new;
      $self->{$bstore};
    };

  $methods{'bit_fields'} = sub { @$boolean_fields; };

  $methods{'bit_dump'} =
    sub {
      my ($self) = @_;
      map { ($_, $self->$_()) } @$boolean_fields;
    };

  foreach (@args) {
    my $field = $_;
    my $bfp = $BooleanPos{$TargetClass}++;
        # $boolean_pos a global declared at top of file. We need to make
        # a local copy because it will be captured in the closure and if
        # we capture the global version the changes to it will effect all
        # the closures. (Note also that it's value is reset with each
        # call to import_into_class.)
    push @$boolean_fields, $field;
        # $boolean_fields is also declared up above. It is used to store a
        # list of the names of all the bit fields.

    $methods{$field} =
      sub {
        my ($self, $on_off) = @_;
        defined $self->{$bstore} or $self->{$bstore} = "";
        if (defined $on_off) {
          vec($self->{$bstore}, $bfp, 1) = $on_off ? 1 : 0;
        }
        vec($self->{$bstore}, $bfp, 1);
      };

    $methods{"set_$field"} =
      sub {
        my ($self) = @_;
        $self->$field(1);
      };

    $methods{"clear_$field"} =
      sub {
        my ($self) = @_;
        $self->$field(0);
      };
  }
  $class->install_methods(%methods);
}

# end of Class::MethodMaker::boolean
1;
