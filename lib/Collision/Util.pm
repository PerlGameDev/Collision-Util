package Collision::Util;

use warnings;
use strict;

BEGIN {
    require Exporter;
    our @ISA = qw(Exporter);
    our @EXPORT_OK = qw( 
            check_contains check_contains_rect 
            check_collision check_collision_rect
            check_collision_interval check_collision_axis
			check_collision_plain
    );
    our %EXPORT_TAGS = (
        all => \@EXPORT_OK,
        std => [qw( check_contains check_collision check_collision_plain)],
        axis => [qw( check_collision_axis )],
        interval => [qw( check_collision_interval )], 
    );
}

use Carp ();

our $VERSION = '0.01';


sub check_contains {
    my ($self, $target) = (@_);
    
    Carp::croak "must receive a target"
        unless $target;
    
    my @ret = ();
    my $ref = ref $target;
    if ( $ref eq 'ARRAY' ) {
        my $id = 0;
        foreach ( @{$target} ) {
            $id++;
            if (check_contains_rect($self, $_) ) {
                push @ret, $id;
                last unless wantarray;
            }
        }
    }
    elsif ( $ref eq 'HASH' ) {
        foreach ( keys %{$target} ) {
            if (check_contains_rect($self, $target->{$_}) ) {
                push @ret, $_;
                last unless wantarray;
            }
        }
    }
    else {
        return check_contains_rect($self, $target);
    }
    return wantarray ? @ret : $ret[0];
}

sub check_contains_rect {
    Carp::croak "must receive a target"
        unless $_[1];

    my $contains;
    eval {
        $contains = ($_[0]->x <= $_[1]->x) 
            && ($_[0]->y <= $_[1]->y) 
            && ($_[0]->x + $_[0]->w >= $_[1]->x + $_[1]->w) 
            && ($_[0]->y + $_[0]->h >= $_[1]->y + $_[1]->h) 
            && ($_[0]->x + $_[0]->w > $_[1]->x) 
            && ($_[0]->y + $_[0]->h > $_[1]->y)
            ;
    };
    Carp::croak "elements should have x, y, w, h accessors" if $@;
    return $contains;
}

sub check_collision {
    my ($self, $target) = (@_);
    
    Carp::croak "must receive a target"
        unless $target;
    
    my @ret = ();
    my $ref = ref $target;
    if ( $ref eq 'ARRAY' ) {
        my $id = 0;
        foreach ( @{$target} ) {
            $id++;
            if (check_collision_rect($self, $_) ) {
                push @ret, $id;
                last unless wantarray;
            }
        }
    }
    elsif ( $ref eq 'HASH' ) {
        foreach ( keys %{$target} ) {
            if (check_collision_rect($self, $target->{$_}) ) {
                push @ret, $_;
                last unless wantarray;
            }
        }
    }
    else {
        return check_collision_rect($self, $target);
    }
    return wantarray ? @ret : $ret[0];
}

sub check_collision_interval {
    my ($self, $target, $interval) = @_;

    Carp::croak "must receive a target"
        unless $target;
    Carp::croak "must receive interval"
        unless $interval;

    my @ret = ();
    my $ref = ref $target;
    if ($ref eq 'ARRAY') {
        my $id = 0;
        foreach (@$target) {
            my $axis = _check_collision_interval($self, $_, $interval);
            if ($axis->[0] != 0 || $axis->[1] != 0) {
                push(@ret, [$id, $axis]);
                last unless wantarray;
            }
            $id++;
        }
    } elsif ($ref eq 'HASH') {
        foreach (keys(%$target)) {
            my $axis = _check_collision_interval($self, $target->{$_}, $interval);
            if ($axis->[0] != 0 || $axis->[1] != 0) {
                push(@ret, [$_, $axis]);
                last unless wantarray;
            }
        }
    } else {
        return _check_collision_interval($self, $target, $interval);
    }
    if ($#ret < 0) {
        push(@ret, [-1, [0, 0]]);
    }
    return wantarray ? @ret : $ret[0];
}

sub _check_collision_interval {
    my ($self, $target, $interval) = @_;
    
    Carp::croak "must receive a target"
        unless $target;
    Carp::croak "must receive interval"
        unless $interval;

    my $axis = [0, 0];
    eval {
        # store original positions
        my ($x1, $y1, $x2, $y2);
        $x1 = $self->x;
        $y1 = $self->y;
        $x2 = $target->x;
        $y2 = $target->y;
        for (1..$interval) {
            # move to next position
            $self->x($self->x + $self->v_x);
            $self->y($self->y + $self->v_y);
            $target->x($target->x + $target->v_x);
            $target->y($target->y + $target->v_y);
            $axis = check_collision_axis_rect($self, $target);
            if ($axis->[0] != 0 or $axis->[1] != 0) {
                last;
            } else {
                # do this debugging for now. TODO: remove later :)
                my $c = check_collision_rect($self, $target);
                if ($c) {
                    print "axis collision not detected, but rects collide!?\n";
                    print "size of target: ", $target->w, "x", $target->h,"\n";
                    printf "self: (%d : %d, %d : %d) target: (%d : %d, %d : %d)\n",
                        $self->x, $self->x+$self->w, $self->y, $self->y+$self->h,
                        $target->x, $target->x+$target->w, $target->y, $target->y+$target->h;
                }
            }
        }
        # restore
        $self->x($x1);
        $self->y($y1);
        $target->x($x2);
        $target->y($y2);
    };
    Carp::croak "elements should have x, y, w, h, v_x and v_y accessors: $@" if $@;
    return $axis;
}

sub check_collision_axis {
    my ($self, $target) = @_;

    Carp::croak "must receive a target"
        unless $target;
    
    my @ret = ();
    my $ref = ref $target;
    if ($ref eq 'ARRAY') {
        my $id = 0;
        foreach (@$target) {
            my $axis = check_collision_axis_rect($self, $_);
            if ($axis->[0] != 0 || $axis->[1] != 0) {
                push(@ret, [$id, $axis]);
                last unless wantarray;
            }
            $id++;
        }
    } elsif ($ref eq 'HASH') {
        foreach (keys(%$target)) {
            my $axis = check_collision_axis_rect($self, $target->{$_});
            if ($axis->[0] != 0 || $axis->[1] != 0) {
                push(@ret, [$_, $axis]);
                last unless wantarray;
            }
        }
    } else {
        return _check_collision_interval($self, $target);
    }
    if ($#ret < 0) {
        push(@ret, [-1, [0, 0]]);
    }
    return wantarray ? @ret : $ret[0];

}

sub check_collision_axis_rect {
    my ($self, $target) = @_;

    Carp::croak "must receive a target"
        unless $target;

    my $axis = [0, 0];
    eval {
        # x-axis left
        # x <= x2+w2 <= x+w/2
        # y <  y2+h2
        # y2<  y+h
        if (($self->x + $self->w >= $target->x) &&
            ($self->x + $self->w <= $target->x + $target->w / 2) &&
            ($self->y + $self->h >=  $target->y) &&
            ($self->y <= $target->y + $target->h)) {
            $axis->[0] = -1;
        }
        # x-axis right
        # x+w/2 <= x2 <= x+w
        # y     <  y2+h2
        # y2    <  y+h
        elsif (($self->x >= $target->x + $target->w / 2) &&
            ($self->x <= $target->x + $target->w) &&
            ($self->y + $self->h >=  $target->y) &&
            ($self->y <=  $target->y + $target->h)) {
            $axis->[0] = 1;
        }
        # y-axis top
        # y <= y2+h2 <= y+h/2
        # x <  x2+w2
        # x2<  x+w
        if (($self->y + $self->h >= $target->y) &&
            ($self->y + $self->h <= $target->y + $target->h / 2) &&
            ($self->x + $self->w >=  $target->x) &&
            ($self->x <= $target->x + $target->w)) {
            $axis->[1] = 1;
        }
        # y-axis bottom
        # y+h <= y2 <= y+h/2
        # x   <  x2+w2
        # x2  <  x+w
        elsif (($self->y >= $target->y + $target->h / 2) &&
            ($self->y <= $target->y + $target->h) &&
            ($self->x + $self->w >= $target->x) &&
            ($self->x <= $target->x + $target->w)) {
            $axis->[1] = -1;
        }
    };
    Carp::croak "elements should have x, y, w, h, v_x and v_y accessors" if $@;
    return $axis;
}

sub check_collision_rect {
    Carp::croak "must receive a target"
        unless $_[1];

    my $collide;
    eval {
        $collide = (
               ($_[0]->x >= $_[1]->x && $_[0]->x < $_[1]->x + $_[1]->w)  
            || ($_[1]->x >= $_[0]->x && $_[1]->x < $_[0]->x + $_[0]->w)
           ) 
           &&
           (
               ($_[0]->y >= $_[1]->y && $_[0]->y < $_[1]->y + $_[1]->h)
            || ($_[1]->y >= $_[0]->y && $_[1]->y < $_[0]->y + $_[0]->h)
           )
           ;
    };
    Carp::croak "elements should have x, y, w, h accessors" if $@;
    return $collide;
}


sub check_collision_plain {
    my ( $x1, $y1, $w1, $h1, $x2, $y2, $w2, $h2 ) = @_;

    my ( $l1, $l2, $r1, $r2, $t1, $t2, $b1, $b2 );

    $l1 = $x1;
    $l2 = $x2;
    $r1 = $x1 + $w1;
    $r2 = $x2 + $w2;
    $t1 = $y1;
    $t2 = $y2;
    $b1 = $y1 + $h1, $b2 = $y2 + $h2;

    return 0 if ( $b1 < $t2 );
    return 0 if ( $t1 > $b2 );
    return 0 if ( $r1 < $l2 );
    return 0 if ( $l1 > $r2 );
    return 1;

}

42;
__END__
=head1 NAME

Collision::Util - A selection of general collision detection utilities

=head1 SYNOPSIS

Say you have a class with C<< ->x() >>, C<< ->y() >>, C<< ->w() >>, and 
C<< ->h() >> accessors, like L<< SDL::Rect >> or the one below:

  package Block;
  use Class::XSAccessor {
      constructor => 'new',
      accessors   => [ 'x', 'y', 'w', 'h' ],
  };
  
let's go for a procedural approach:
  
  use Collision::Util ':std';
  
  my $rect1 = Block->new( x =>  1, y =>  1, w => 10, h => 10 );
  my $rect2 = Block->new( x =>  5, y =>  9, w =>  6, h =>  4 );
  my $rect3 = Block->new( x => 16, y => 12, w =>  3, h =>  3 );
  
  check_collision($rect1, $rect2);  # true
  check_collision($rect3, $rect1);  # false
  
  # you can also check them all in a single run:
  check_collision($rect1, [$rect2, $rect3] );
  
As you might have already realized, you can just as easily bundle collision 
detection into your objects:

  package CollisionBlock;
  use Class::XSAccessor {
      constructor => 'new',
      accessors   => [ 'x', 'y', 'w', 'h' ],
      # use ['x', 'y', 'w', 'h', 'v_x', 'v_y'] for interval collisions
  };
  
  # if your class has the (x, y, w, h) accessors,
  # imported functions will behave just like methods!
  use Collision::Util ':std';
  
Then, further in your code:

  my $rect1 = CollisionBlock->new( x =>  1, y =>  1, w => 10, h => 10 );
  my $rect2 = CollisionBlock->new( x =>  5, y =>  9, w =>  6, h =>  4 );
  my $rect3 = CollisionBlock->new( x => 16, y => 12, w =>  3, h =>  3 );
  
  $rect1->check_collision( $rect2 );  # true
  $rect3->check_collision( $rect1 );  # false
  
  # you can also check if them all in a single run:
  $rect1->check_collision( [$rect2, $rect3] );

And something else, with intervals:

  my $player = CollisionBlock->new(x => 100, y => 50, w => 25, h => 25, v_x => 0, v_y => 10);
  my $wall   = [
      CollisionBlock->new(x => 100, y => 100, w => 30, h => 30, v_x => 0, v_y => 0),
      CollisionBlock->new(x => 130, y => 100, w => 30, h => 30, v_x => 0, v_y => 0),
      CollisionBlock->new(x => 160, y => 100, w => 30, h => 30, v_x => 0, v_y => 0),
  ];

  print "collision in 4 steps on y-axis\n";
  print Dumper $player->check_collision_interval($wall,  4);

  # set another position
  $player->x(67);
  $player->y(102);
  $player->v_y(2);
  $player->v_x(9);
  print "collision at next step on x-axis\n";
  print Dumper $player->check_collision_interval($wall, 1);

  # set another position
  $player->x(213);
  $player->y(180);
  $player->v_x(-2.5);
  $player->v_y(-5.8);
  print "collision over some time on x-axis at (188,122)\n";
  my $coll = $player->check_collision_interval($wall, 11);
  print Dumper $coll;

=head1 DESCRIPTION

Collision::Util contains sets of several functions to help you detect 
collisions in your programs. While it focuses primarily on games, you can use 
it for any application that requires collision detection.

=head1 EXPORTABLE SETS

Collision::Util doesn't export anything by default. You have to explicitly 
define function names or one of the available helper sets below:

=head2 :std

exports C<< check_collision() >> and C<< check_contains() >>.

=head2 :rect

exports C<< check_collision_rect() >> and C<< check_contains_rect() >>.

=head2 :interval

exports C<< check_collision_interval() >>.

=head2 :axis

exports C<< check_collision_axis() >>.

=head2 :circ

TODO

=head2 :dot

TODO

=head2 :all

exports all functions.

=head1 MAIN UTILITIES

=head2 check_contains ($source, $target)

=head2 check_contains ($source, [$target1, $target2, $target3, ...])

=head2 check_contains ($source, { key1 => $target1, key2 => $target2, ...})


  if ( check_contains($ball, $goal) ) {
      # SCORE !!
  }
  
  die if check_contains($hero, \@bullets);

Returns the index (starting from 1, so you always get a 'true' value) of the 
first target item completely inside $source. Otherwise returns undef.

  my @visible = check_contains($area, \@enemies);

If your code context wants it to return a list, C<< inside >> will return a 
list of all indices (again, 1-based) completely inside $source. If no 
elements are found, an empty list is returned. 

  my @names = check_contains($track, \%horses);

Similarly, you can also check which (if any) elements of a hash are inside 
your element, which is useful if you group your objects like that instead of 
in a list.

=head2 check_collision ($source, $target)

=head2 check_collision ($source, [$target1, $target2, $target3, ...])

=head2 check_collision ($source, { key1 => $target1, key2 => $target2, ...})

  if ( check_collision($player, $wall) ) {
      # ouch
  }

  die if check_collision($hero, \@lava_pits);

Returns the index (starting from 1, so you always get a 'true' value) of the 
first target item that collides with $source. Otherwise returns undef.

  my @hits = check_collision($planet, \@asteroids);

If your code context wants it to return a list, C<< inside >> will return a 
list of all indices (again, 1-based) that collide with $source. If no 
elements are found, an empty list is returned.

  my @keys = check_collision($foo, \%bar);

Similarly, you can also check which (if any) elements of a hash are colliding
with your element, which is useful if you group your objects like that instead 
of in a list.

=head2 check_collision_axis ($source, $target)

=head2 check_collision_axis ($source, [$target1, $target2, $target3, ...])

=head2 check_collision_axis ($source, { key1 => $target1, key2 => $target2, ...})

  my $axis = check_collision_axis($player, $stone);
  if ($axis->[0] != 0) {
      # x-axis collision
  }
  if ($axis->[1] != 0) {
      # y-axis collision
      if ($axis->[1] == -1) {
          # from above
      } elsif ($axis->[1] == 1) {
          # from below
      }
  }

Always returns collisions as array references representing the collision axis' ([x, y],
values -1, 0 or 1).

  my @hits = check_collision_axis($planet, \@asteroids);

  foreach my $hit (@hits) {
        if ($hit->[0] != 0) {
            # x-axis collision
        }
  }

If your code context wants it to return a list, C<< inside >> will return a
list of all indices that collide with $source. If no elements are found, an
empty list is returned with the index value set to -1.

  my @keys = check_collision_axis($foo, \%bar);

Similarly, you can also check which (if any) elements of a hash are colliding
with your element, which is useful if you group your objects like that instead 
of in a list.

=head2 check_collision_interval ($source, $target)

=head2 check_collision_interval ($source, [$target1, $target2, $target3, ...])

=head2 check_collision_interval ($source, { key1 => $target1, key2 => $target2, ...})

  my $collision = check_collision_interval($player, $stone, 1);
  if ($collision->[0] != 0) {
      # x-axis collision
  }
  if ($collision->[1] != 0) {
      # y-axis collision
      if ($collision->[1] == -1) {
          # from above
      } elsif ($collision->[1] == 1) {
          # from below
      }
  }

Always returns collisions as array references representing the collision axis' ([x, y],
values -1, 0 or 1).

  my @hits = check_collision_interval($planet, \@asteroids, 10);

  foreach my $hit (@hits) {
        if ($hit->[0] != 0) {
            # x-axis collision
        }
  }

If your code context wants it to return a list, C<< inside >> will return a
list of all indices that collide with $source. If no elements are found, an
empty list is returned with the index value set to -1.

  my @keys = check_collision_interval($foo, \%bar, 2);

Similarly, you can also check which (if any) elements of a hash are colliding
with your element, which is useful if you group your objects like that instead 
of in a list.

=head1 USING IT IN YOUR OBJECTS

TODO (but SYNOPSIS should give you a hint)

=head1 DIAGNOSTICS

=over 4

=item * I<< "must receive a target" >>

You tried calling the function without a target. Remember, syntax is
always C<< foo($source, $target) >>, or, if you're not using it 
directly and the collision is a method inside object C<$source>, then 
it's L<< $source->foo($target) >>. Here of course you should replace 
I<foo> with the name of the C<< Collision::Util >> function you want.

=item * I<< "elements should have x, y, w, h accessors" >>

Both C<$source> and C<$target> must be objects with accessors for C<x> 
(I<< left coordinate >> ), C<y> (I<< top coordinate >> ), C<w> 
(I<< object's width >> ), and C<h> (I<< object's height >> ).

=back


=head1 AUTHORS

Breno G. de Oliveira, C<< <garu at cpan.org> >>
Heikki MehtE<195>nen, C<< <heikki at mehtanen.fi> >>


=head1 ACKNOWLEDGEMENTS

Many thanks to Kartik Thakore for his help and insights.


=head1 BUGS

Please report any bugs or feature requests to C<bug-collision-util at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Collision-Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Collision::Util


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Collision-Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Collision-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Collision-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/Collision-Util/>

=back



=head1 LICENSE AND COPYRIGHT

Copyright 2010 Breno G. de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

