
use strict;
use warnings;

package Rect;
  use Collision::Util ':dynamic';
  sub new { my $class = shift; return bless {@_}, $class }
  sub x   { $_[0]->{x}   = $_[1] if defined $_[1]; return $_[0]->{x} }
  sub y   { $_[0]->{y}   = $_[1] if defined $_[1]; return $_[0]->{y} }
  sub w   { $_[0]->{w}   = $_[1] if defined $_[1]; return $_[0]->{w} }
  sub h   { $_[0]->{h}   = $_[1] if defined $_[1]; return $_[0]->{h} }
  sub v_x { $_[0]->{v_x} = $_[1] if defined $_[1]; return $_[0]->{v_x} }
  sub v_y { $_[0]->{v_y} = $_[1] if defined $_[1]; return $_[0]->{v_y} }

package main;

use Test::More;

# Explanation of diagrams:
# - Integer coordinates are located at the center of each character.
#
# This is two 2x2 rectangles seperated by two units of distance:
# +-+ +-+
# | | | |
# +-+ +-+
#
# This is two 3x3 rectangles seperated by one unit of distance:
# +--++--+
# |  ||  |
# |  ||  |
# +--++--+
#
# This is two adjacent rectangles:
# +-+-+
# | | |
# +-+-+


# +-+ +-+
# |1| |2|
# +-+ +-+
my $rect1 = Rect->new( x => 1, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );
my $rect2 = Rect->new( x => 5, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect1->check_collision_dynamic($rect2, 1), [0, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 1), [0, 0]);

$rect1->v_y(1.0);
is_deeply($rect1->check_collision_dynamic($rect2, 1), [0, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 1), [0, 0]);
is_deeply($rect1->check_collision_dynamic($rect2, 4), [0, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 4), [0, 0]);

$rect1->v_y(0.0);
$rect1->v_x(3.0);
is_deeply($rect1->check_collision_dynamic($rect2, 2), [-1, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 2), [1, 0]);

$rect1->v_x(1.5);
is_deeply($rect1->check_collision_dynamic($rect2, 1), [0, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 1), [0, 0]);
is_deeply($rect1->check_collision_dynamic($rect2, 2), [-1, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 2), [1, 0]);

$rect1->v_x(3.0);
$rect1->v_y(0.1);
is_deeply($rect1->check_collision_dynamic($rect2, 1), [-1, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 1), [1, 0]);

$rect1->v_x(3.0);
$rect1->v_y(-0.1);
is_deeply($rect1->check_collision_dynamic($rect2, 1), [-1, 0]);
is_deeply($rect2->check_collision_dynamic($rect1, 1), [1, 0]);

# +-+
# |3|
# +-+
#
# +-+
# |4|
# +-+
my $rect3 = Rect->new( x => 1, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );
my $rect4 = Rect->new( x => 1, y => 4, w => 2, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 0]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, 0]);

$rect3->v_x(1.0);
is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 0]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, 0]);
is_deeply($rect3->check_collision_dynamic($rect4, 4), [0, 0]);
is_deeply($rect4->check_collision_dynamic($rect3, 4), [0, 0]);

$rect3->v_x(0.0);
$rect3->v_y(3.0);
is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 1]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, -1]);

$rect3->v_y(1.5);
is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 0]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, 0]);
is_deeply($rect3->check_collision_dynamic($rect4, 2), [0, 1]);
is_deeply($rect4->check_collision_dynamic($rect3, 2), [0, -1]);

$rect3->v_x(0.1);
$rect3->v_y(3.0);
is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 1]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, -1]);

$rect3->v_x(-0.1);
$rect3->v_y(3.0);
is_deeply($rect3->check_collision_dynamic($rect4, 1), [0, 1]);
is_deeply($rect4->check_collision_dynamic($rect3, 1), [0, -1]);

# +-+
# |5|
# +-+
#
#     +-+
#     |6|
#     +-+
my $rect5 = Rect->new( x => 1, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );
my $rect6 = Rect->new( x => 5, y => 4, w => 2, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect5->check_collision_dynamic($rect6, 1), [0, 0]);
is_deeply($rect6->check_collision_dynamic($rect5, 1), [0, 0]);

$rect5->v_x(3.0);
$rect5->v_y(3.0);
is_deeply($rect5->check_collision_dynamic($rect6, 1), [-1, 1]);
is_deeply($rect6->check_collision_dynamic($rect5, 1), [1, -1]);

$rect5->v_x(1.5);
$rect5->v_y(1.5);
is_deeply($rect5->check_collision_dynamic($rect6, 1), [0, 0]);
is_deeply($rect6->check_collision_dynamic($rect5, 1), [0, 0]);
is_deeply($rect5->check_collision_dynamic($rect6, 2), [-1, 1]);
is_deeply($rect6->check_collision_dynamic($rect5, 2), [1, -1]);

# +-+
# |7| +-+
# +-+ |8|
#     +-+
my $rect7 = Rect->new( x => 1, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );
my $rect8 = Rect->new( x => 5, y => 1, w => 2, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect7->check_collision_dynamic($rect8, 1), [0, 0]);
is_deeply($rect8->check_collision_dynamic($rect7, 1), [0, 0]);

$rect7->v_x(3.0);
is_deeply($rect7->check_collision_dynamic($rect8, 1), [-1, 0]);
is_deeply($rect8->check_collision_dynamic($rect7, 1), [1, 0]);

$rect7->v_x(1.5);
is_deeply($rect7->check_collision_dynamic($rect8, 1), [0, 0]);
is_deeply($rect8->check_collision_dynamic($rect7, 1), [0, 0]);
is_deeply($rect7->check_collision_dynamic($rect8, 2), [-1, 0]);
is_deeply($rect8->check_collision_dynamic($rect7, 2), [1, 0]);

# +-+
# |9|
# +-+
#
#  +--+
#  |10|
#  +--+
my $rect9  = Rect->new( x => 1, y => 0, w => 2, h => 2, v_x => 0, v_y => 0 );
my $rect10 = Rect->new( x => 2, y => 4, w => 3, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect9->check_collision_dynamic($rect10, 1), [0, 0]);
is_deeply($rect10->check_collision_dynamic($rect9, 1), [0, 0]);

$rect9->v_y(3.0);
is_deeply($rect9->check_collision_dynamic($rect10, 1), [0, 1]);
is_deeply($rect10->check_collision_dynamic($rect9, 1), [0, -1]);

$rect9->v_y(1.5);
is_deeply($rect9->check_collision_dynamic($rect10, 1), [0, 0]);
is_deeply($rect10->check_collision_dynamic($rect9, 1), [0, 0]);
is_deeply($rect9->check_collision_dynamic($rect10, 2), [0, 1]);
is_deeply($rect10->check_collision_dynamic($rect9, 2), [0, -1]);

#      +---+
# +--+ |12 |
# |11| |   |
# +--+ |   |
#      +---+
my $rect11 = Rect->new( x => 1, y => 1, w => 3, h => 2, v_x => 0, v_y => 0 );
my $rect12 = Rect->new( x => 6, y => 0, w => 4, h => 4, v_x => 0, v_y => 0 );

is_deeply($rect11->check_collision_dynamic($rect12, 1), [0, 0]);
is_deeply($rect12->check_collision_dynamic($rect11, 1), [0, 0]);

$rect11->v_x(3.0);
is_deeply($rect11->check_collision_dynamic($rect12, 1), [-1, 0]);
is_deeply($rect12->check_collision_dynamic($rect11, 1), [1, 0]);

$rect11->v_x(1.5);
is_deeply($rect11->check_collision_dynamic($rect12, 1), [0, 0]);
is_deeply($rect12->check_collision_dynamic($rect11, 1), [0, 0]);
is_deeply($rect11->check_collision_dynamic($rect12, 2), [-1, 0]);
is_deeply($rect12->check_collision_dynamic($rect11, 2), [1, 0]);

#  +--+
#  |13|
#  +--+
#
# +----+
# |14  |
# |    |
# |    |
# +----+
my $rect13 = Rect->new( x => 2, y => 0, w => 3, h => 2, v_x => 0, v_y => 0 );
my $rect14 = Rect->new( x => 1, y => 4, w => 5, h => 4, v_x => 0, v_y => 0 );

is_deeply($rect13->check_collision_dynamic($rect14, 1), [0, 0]);
is_deeply($rect14->check_collision_dynamic($rect13, 1), [0, 0]);

$rect13->v_y(3.0);
is_deeply($rect13->check_collision_dynamic($rect14, 1), [0, 1]);
is_deeply($rect14->check_collision_dynamic($rect13, 1), [0, -1]);

$rect13->v_y(1.5);
is_deeply($rect13->check_collision_dynamic($rect14, 1), [0, 0]);
is_deeply($rect14->check_collision_dynamic($rect13, 1), [0, 0]);
is_deeply($rect13->check_collision_dynamic($rect14, 2), [0, 1]);
is_deeply($rect14->check_collision_dynamic($rect13, 2), [0, -1]);

$rect13->v_x(-0.1);
$rect13->v_y(3.0);
is_deeply($rect13->check_collision_dynamic($rect14, 1), [0, 1]);
is_deeply($rect14->check_collision_dynamic($rect13, 1), [0, -1]);

# +----+
# |15  |
# |    |
# |    |
# +----+
#
#  +--+
#  |16|
#  +--+
my $rect15 = Rect->new( x => 1, y => 0, w => 5, h => 4, v_x => 0, v_y => 0 );
my $rect16 = Rect->new( x => 2, y => 4, w => 3, h => 2, v_x => 0, v_y => 0 );

is_deeply($rect15->check_collision_dynamic($rect16, 1), [0, 0]);
is_deeply($rect16->check_collision_dynamic($rect15, 1), [0, 0]);

$rect15->v_y(3.0);
is_deeply($rect15->check_collision_dynamic($rect16, 1), [0, 1]);
is_deeply($rect16->check_collision_dynamic($rect15, 1), [0, -1]);

done_testing;
