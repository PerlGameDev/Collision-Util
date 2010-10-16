#!/usr/bin/env perl
use strict;
use warnings;

use SDL;
use SDL::Event;
use SDLx::App;
use Collision::Util::Rect;
use Scalar::Util 'refaddr';

my ( $width, $height ) = ( 640, 480 );
my @collisions;
my @rects;

foreach ( 1 .. 100 ) {
    push @rects,
        Collision::Util::Rect->new(
        x   => rand() * $width,
        y   => rand() * $height,
        w   => rand() * 10 + 2,
        h   => rand() * 10 + 2,
        v_x => rand() * 10 - 5,
        v_y => rand() * 10 - 5,
        );
}

my $app = SDLx::App->new(
    title  => 'Collision::Util::check_containts Example',
    width  => $width,
    height => $height,
    dt     => 1,
);

$app->add_event_handler(
    sub {
        my ($event) = @_;
        $app->stop if $event->type == SDL_QUIT;
        $app->stop if $event->key_sym == SDLK_ESCAPE;
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
                $rect->x($height);
            }
        }
        @collisions = ();
        foreach my $rect (@rects) {
            foreach my $other ( grep { refaddr $rect ne refaddr $_ } @rects )
            {
                if ( $rect->intersects($other) ) {
                    push @collisions, $rect;
                }
            }
        }
    }
);

$app->add_show_handler(
    sub {
        $app->draw_rect;
        foreach my $rect (@rects) {
            my $color
                = ( grep { refaddr $rect eq refaddr $_ } @collisions )
                ? 0xFF0000FF
                : 0x888888FF;
            $app->draw_rect( [ $rect->x, $rect->y, $rect->w, $rect->h ],
                $color );
        }
        $app->update;
    }
);

$app->run();