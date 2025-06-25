# NOTE: Derived from blib/lib/Class/MethodMaker.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Class::MethodMaker;

#line 684 "blib/lib/Class/MethodMaker.pm (autosplit into blib/lib/auto/Class/MethodMaker/_make_get_set.al)"
# ----------------------------------------------------------------------


sub _make_get_set {
  my $class = shift;
  my ($slot, $template, $opts) = @_; # $opts is a hashref

  # Older subclasses might pass a boolean instead of an href,
  # expecting to set the "-static" option.
  $opts = +{ '-static' => ($opts ? 1 : 0) } unless ref($opts) eq 'HASH';

  my %methods;

  my @method_names = @$template;
  my $method_name;
  for $method_name (@method_names) {
    if ( defined $method_name ) {
      $method_name =~ s/\*/$slot/g
        or carp "Method name template must include \* character.";
    }
  }

  my $pgsetter;
  if ( $opts->{'-static'} ) {
    my $store;
    $pgsetter = sub {
      return $store if @_ == 1;
      return $store = $_[1];
    };
  } else {
    $pgsetter = sub {
      return $_[0]->{$slot} if @_ == 1;
      return $_[0]->{$slot} = $_[1];
    };
  }

  # -set_once  wrapper
  if ( defined ( my $action_sub = $opts->{'-set_once'}) ) {
      my $once_name = " __CMM__ $slot once ";
      my $inner_pgsetter = $pgsetter;

      if ( $opts->{'-static'}) {
          my $already_set;
          $pgsetter = sub {
              if ( @_ > 1 ) {
                if ( $already_set ){
                    my $class = ref($_[0]) || $_[0];
                    $action_sub->($_[0], "Attempt to set static $class\:\:$slot more than once.", @_[1..$#_]);
                    return $inner_pgsetter->($_[0]);
                }
                else{
                    $already_set = 1;
                }
              }
              # call the old pgsetter
              $inner_pgsetter->(@_);
            };
      }
      else {
          $pgsetter = sub {
              if ( @_ > 1 ) {
                if ( exists $_[0]->{$once_name} ){
                    my $class = ref($_[0]) || $_[0];
                    $action_sub->($_[0], "Attempt to set $class\:\:$slot more than once.",@_[1..$#_]);
                    return $inner_pgsetter->($_[0]);
                }else{
                    $_[0]->{$once_name} = 1;
                }
              }
              # call the old pgsetter
              $inner_pgsetter->(@_);
            };
      }
  }

  my @methods =
    (
     '$pgsetter',
     'sub { $pgsetter->($_[0], undef); return }',
     'sub { return $pgsetter->($_[0]); }',
     'sub { $pgsetter->($_[0], $_[1]); return }',
    );

  my $i;
  for ($i = 0; $i < @methods; $i++) {
    $methods{$method_names[$i]} = eval $methods[$i]
      if defined $method_names[$i];
  }

  $methods{" __CMM__ $slot"} = $pgsetter;

  return %methods;
}

# end of Class::MethodMaker::_make_get_set
1;
