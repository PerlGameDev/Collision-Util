use strict;
use warnings;

use Collision::Util::Rect;
use Test::More;

BEGIN {
    use_ok('Collision::Util::Quadtree');
}

can_ok( 'Collision::Util::Quadtree', qw(new insert update remove get_collisions) );

my @rects = map { Collision::Util::Rect->new( x => $_, y => $_, w => 10, h => 10 ) } map { $_ * 5 } ( 0 .. 18 );

my $quadtree = Collision::Util::Quadtree->new(
    x     => 0,
    y     => 0,
    w     => 100,
    h     => 100,
    items => \@rects,
);

ok( $quadtree, 'Created quadtree' );

my $collisions = $quadtree->get_collisions();
ok( $collisions, 'Got $collisions' );
isa_ok( $collisions, 'ARRAY', '$collisions' );

is( scalar @$collisions, scalar @rects, 'Same number of collisions as items' );

is_deeply( [ sort @$collisions ], [ sort @rects ], 'All items collide' );

$rects[0]->x(90);
$quadtree->update( $rects[0] );

$collisions = $quadtree->get_collisions();

is( scalar @$collisions, scalar @rects - 1, 'Correct number of collisions after moving one item' );

is_deeply(
    [ sort @$collisions ],
    [ sort @rects[ 1 .. $#rects ] ],
    'All items collide except the one that was moved'
);

$quadtree->remove( $rects[$#rects] );

$collisions = $quadtree->get_collisions();

is( scalar @$collisions, scalar @rects - 2,
    'Correct number of collisions after moving one item and removing one item' );

is_deeply(
    [ sort @$collisions ],
    [ sort @rects[ 1 .. $#rects - 1 ] ],
    'All items collide except the one that was moved and the one that was removed'
);

done_testing();
