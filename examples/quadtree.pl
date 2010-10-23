#!/usr/bin/env perl
use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use Collision::Util::Rect;
use Collision::Util::Quadtree;
use Scalar::Util 'refaddr';

print <<'EOT';

Press 'q' or 'b' to change the collision detection algorithm used to
Quadtree or brute force.

To exit the demo, close the window or press the escape key.

EOT

my $algorithm = 'quadtree';
my ( $width, $height ) = ( 640, 480 );

my @rects;

foreach ( 1 .. 150 ) {
    my $rect = Collision::Util::Rect->new(
        x   => rand() * $width,
        y   => rand() * $height,
        w   => rand() * 10 + 2,
        h   => rand() * 10 + 2,
        v_x => rand() * 10 - 5,
        v_y => rand() * 10 - 5,
    );
    push @rects, $rect;
}

my $quadtree = Collision::Util::Quadtree->new(
    x         => 0 - 20,
    y         => 0 - 20,
    w         => $width + 40,
    h         => $height + 40,
    max_items => 2,
    max_depth => 4,
    items     => \@rects,
);

my $app = SDLx::App->new(
    title  => 'Collision::Util::Quadtree Example',
    width  => $width,
    height => $height,
);

sub get_collisions {
    if ( $algorithm eq 'quadtree' ) {
        $quadtree->update($_) foreach @rects;
        return $quadtree->get_collisions();
    }
    elsif ( $algorithm eq 'bruteforce' ) {
        my @collisions;
        my $max = @rects - 1;
        foreach my $rect_id ( 0 .. $max ) {
            my $rect = $rects[$rect_id];
            foreach my $other_id ( $rect_id + 1 .. $max ) {
                my $other = $rects[$other_id];
                if ( $rect->intersects($other) ) {
                    push @collisions, $rect;
                    push @collisions, $other;
                }
            }
        }
        return \@collisions;
    }
}

$app->add_event_handler(
    sub {
        my ($event) = @_;
        $app->stop if $event->type == SDL_QUIT;
        $app->stop if $event->key_sym == SDLK_ESCAPE;

        if ( $event->type == SDL_KEYDOWN ) {
            my $key = SDL::Events::get_key_name( $event->key_sym );
            $algorithm = 'quadtree'   if $key eq 'q';
            $algorithm = 'bruteforce' if $key eq 'b';
            print $algorithm, "\n" if $key eq 'q' || $key eq 'b';
        }
    }
);

$app->add_move_handler(
    sub {
        my ($step) = @_;
        foreach my $rect (@rects) {
            $rect->x( $rect->x + $rect->v_x * $step );
            $rect->y( $rect->y + $rect->v_y * $step );

            if ( $rect->x > $width ) {
                $rect->x( -$rect->w );
            }
            elsif ( $rect->x < -$rect->w ) {
                $rect->x($width);
            }
            if ( $rect->y > $height ) {
                $rect->y( -$rect->h );
            }
            elsif ( $rect->y < -$rect->h ) {
                $rect->y($height);
            }
        }
    }
);

$app->add_show_handler(
    sub {
        $app->draw_rect;
        my @collisions = @{ get_collisions() };
        my %collisions;
        $collisions{ refaddr $_} = 1 foreach @collisions;
        foreach my $rect (@rects) {
            my $color
                = defined $collisions{ refaddr $rect}
                ? 0xFF0000FF
                : 0x888888FF;
            $app->draw_rect( [ $rect->x, $rect->y, $rect->w, $rect->h ],
                $color );
        }
        $app->update;
    }
);

$app->run();
