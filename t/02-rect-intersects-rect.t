use strict;
use warnings;

package Rect;
use Collision::Util 'check_collision_rect';
sub new { my $class = shift; return bless {@_}, $class }
sub x { $_[0]->{x} = $_[1] if defined $_[1]; return $_[0]->{x} }
sub y { $_[0]->{y} = $_[1] if defined $_[1]; return $_[0]->{y} }
sub w { $_[0]->{w} = $_[1] if defined $_[1]; return $_[0]->{w} }
sub h { $_[0]->{h} = $_[1] if defined $_[1]; return $_[0]->{h} }
sub intersects { $_[0]->check_collision_rect( $_[1] ) }

package main;

use Test::More;

BEGIN { use_ok( 'Collision::Util', 'check_collision_rect' ); }

my @rect;

# +-+-+
# |1|2|
# +-+-+
# |3|4|
# +-+-+

$rect[1] = Rect->new( x => 1, y => 1, w => 2, h => 2 );
$rect[2] = Rect->new( x => 3, y => 1, w => 2, h => 2 );
$rect[3] = Rect->new( x => 1, y => 3, w => 2, h => 2 );
$rect[4] = Rect->new( x => 3, y => 3, w => 2, h => 2 );

foreach my $id ( 1 .. 4 ) {
    ok( $rect[$id]->intersects( $rect[$id] ), "rect[$id] intersects itself" );
    foreach ( grep { $_ != $id } ( 1 .. 4 ) ) {
        ok( !$rect[$id]->intersects( $rect[$_] ), "rect[$id] does not intersect rect[$_]" );
    }
}

# +---+--+
# |5  |6 |
# |   +--+
# |   |7 |
# +-+-+--+
# |8|9|10|
# +-+-+--+

$rect[5]  = Rect->new( x => 1, y => 1, w => 7, h => 6 );
$rect[6]  = Rect->new( x => 5, y => 1, w => 3, h => 2 );
$rect[7]  = Rect->new( x => 5, y => 3, w => 3, h => 2 );
$rect[8]  = Rect->new( x => 1, y => 5, w => 2, h => 2 );
$rect[9]  = Rect->new( x => 3, y => 5, w => 2, h => 2 );
$rect[10] = Rect->new( x => 5, y => 5, w => 3, h => 2 );

foreach ( 1 .. 10 ) {
    ok( $rect[5]->intersects( $rect[$_] ), "rect[5] intersects rect[$_]" );
}

foreach my $id ( 1 .. 4, 6 .. 10 ) {
    foreach ( grep { $_ != $id } ( 1 .. 4, 6 .. 10 ) ) {
        ok( !$rect[$id]->intersects( $rect[$_] ), "rect[$id] does not intersect rect[$_]" );
    }
}

#    +--+
# +--+12|
# |11+--+
# +--+

$rect[11] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[12] = Rect->new( x => 4, y => 1, w => 3, h => 2 );

ok( !$rect[11]->intersects( $rect[12] ), 'rect[11] does not intersect rect[12]' );
ok( !$rect[12]->intersects( $rect[11] ), 'rect[12] does not intersect rect[11]' );

# +--+
# |13+--+
# +--+14|
#    +--+

$rect[13] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[14] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[13]->intersects( $rect[14] ), 'rect[14] does not intersect rect[13]' );
ok( !$rect[14]->intersects( $rect[13] ), 'rect[13] does not intersect rect[14]' );

# +--+--+
# |15|16|
# +--+  |
#    +--+

$rect[15] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[16] = Rect->new( x => 4, y => 1, w => 3, h => 3 );

ok( !$rect[15]->intersects( $rect[16] ), 'rect[15] does not intersect rect[16]' );
ok( !$rect[16]->intersects( $rect[15] ), 'rect[16] does not intersect rect[15]' );

#    +--+
# +--+18|
# |17|  |
# +--+  |
#    +--+

$rect[17] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[18] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( !$rect[17]->intersects( $rect[18] ), 'rect[17] does not intersect rect[18]' );
ok( !$rect[18]->intersects( $rect[17] ), 'rect[18] does not intersect rect[17]' );

#    +--+
# +--+20|
# |19|  |
# +--+--+

$rect[19] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[20] = Rect->new( x => 4, y => 1, w => 3, h => 3 );

ok( !$rect[19]->intersects( $rect[20] ), 'rect[19] does not intersect rect[20]' );
ok( !$rect[20]->intersects( $rect[19] ), 'rect[20] does not intersect rect[19]' );

# +--+--+
# |21|22|
# |  +--+
# +--+

$rect[21] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[22] = Rect->new( x => 4, y => 1, w => 3, h => 2 );

ok( !$rect[21]->intersects( $rect[22] ), 'rect[21] does not intersect rect[22]' );
ok( !$rect[22]->intersects( $rect[21] ), 'rect[22] does not intersect rect[21]' );

# +--+
# |23+--+
# |  |24|
# |  +--+
# +--+

$rect[23] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[24] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[23]->intersects( $rect[24] ), 'rect[23] does not intersect rect[24]' );
ok( !$rect[24]->intersects( $rect[23] ), 'rect[24] does not intersect rect[23]' );

# +--+
# |25+--+
# |  |26|
# +--+--+

$rect[25] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[26] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[25]->intersects( $rect[26] ), 'rect[25] does not intersect rect[26]' );
ok( !$rect[26]->intersects( $rect[25] ), 'rect[26] does not intersect rect[25]' );

# +--+
# |27|
# ++-++
#  |28|
#  +--+

$rect[27] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[28] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[27]->intersects( $rect[28] ), 'rect[27] does not intersect rect[28]' );
ok( !$rect[28]->intersects( $rect[27] ), 'rect[28] does not intersect rect[27]' );

#  +--+
#  |29|
# ++-++
# |30|
# +--+

$rect[29] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[30] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( !$rect[29]->intersects( $rect[30] ), 'rect[29] does not intersect rect[30]' );
ok( !$rect[30]->intersects( $rect[29] ), 'rect[30] does not intersect rect[29]' );

# +--+
# |31|
# +--++
# |32 |
# ----+

$rect[31] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[32] = Rect->new( x => 1, y => 3, w => 4, h => 2 );

ok( !$rect[31]->intersects( $rect[32] ), 'rect[31] does not intersect rect[32]' );
ok( !$rect[32]->intersects( $rect[31] ), 'rect[32] does not intersect rect[31]' );

#  +--+
#  |33|
# ++--++
# |34  |
# +----+

$rect[33] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[34] = Rect->new( x => 1, y => 3, w => 5, h => 2 );

ok( !$rect[33]->intersects( $rect[34] ), 'rect[33] does not intersect rect[34]' );
ok( !$rect[34]->intersects( $rect[33] ), 'rect[34] does not intersect rect[33]' );

#  +--+
#  |35|
# ++--+
# |36 |
# +---+

$rect[35] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[36] = Rect->new( x => 1, y => 3, w => 4, h => 2 );

ok( !$rect[35]->intersects( $rect[36] ), 'rect[35] does not intersect rect[36]' );
ok( !$rect[36]->intersects( $rect[35] ), 'rect[36] does not intersect rect[35]' );

# +---+
# |37 |
# +--++
# |38|
# +--+

$rect[37] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[38] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( !$rect[37]->intersects( $rect[38] ), 'rect[37] does not intersect rect[38]' );
ok( !$rect[38]->intersects( $rect[37] ), 'rect[38] does not intersect rect[37]' );

# +----+
# |39  |
# ++--++
#  |40|
#  +--+

$rect[39] = Rect->new( x => 1, y => 1, w => 5, h => 2 );
$rect[40] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[39]->intersects( $rect[40] ), 'rect[39] does not intersect rect[40]' );
ok( !$rect[40]->intersects( $rect[39] ), 'rect[40] does not intersect rect[39]' );

# +---+
# |41 |
# ++--+
#  |42|
#  +--+

$rect[41] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[42] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[41]->intersects( $rect[42] ), 'rect[41] does not intersect rect[42]' );
ok( !$rect[42]->intersects( $rect[41] ), 'rect[42] does not intersect rect[41]' );

# +---+
# |43 |
# | +-+-+
# | | | |
# +-+-+ |
#   |44 |
#   +---+

$rect[43] = Rect->new( x => 1, y => 1, w => 4, h => 4 );
$rect[44] = Rect->new( x => 3, y => 3, w => 4, h => 4 );

ok( $rect[43]->intersects( $rect[44] ), 'rect[43] intersects rect[44]' );
ok( $rect[44]->intersects( $rect[43] ), 'rect[44] intersects rect[43]' );

#   +---+
#   |45 |
# +-+-+ |
# | | | |
# | +-+-+
# |46 |
# +---+

$rect[45] = Rect->new( x => 1, y => 3, w => 4, h => 4 );
$rect[46] = Rect->new( x => 3, y => 1, w => 4, h => 4 );

ok( $rect[45]->intersects( $rect[46] ), 'rect[45] intersects rect[46]' );
ok( $rect[46]->intersects( $rect[45] ), 'rect[46] intersects rect[45]' );

# +--++--+
# |47||48|
# +--++--+
# +---+
# |47 |
# +---+
#    +---+
#    | 48|
#    +---+

$rect[47] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[48] = Rect->new( x => 4, y => 1, w => 4, h => 2 );

ok( $rect[47]->intersects( $rect[48] ), 'rect[47] intersects rect[48]' );
ok( $rect[48]->intersects( $rect[47] ), 'rect[48] intersects rect[47]' );

# +--++--+
# |49||50|
# +--++  |
#    +---+

$rect[49] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[50] = Rect->new( x => 4, y => 1, w => 4, h => 3 );

ok( $rect[49]->intersects( $rect[50] ), 'rect[49] intersects rect[50]' );
ok( $rect[50]->intersects( $rect[49] ), 'rect[50] intersects rect[49]' );

#    +---+
# +--++52|
# |51||  |
# +--++  |
#    +---+

$rect[51] = Rect->new( x => 1, y => 2, w => 4, h => 2 );
$rect[52] = Rect->new( x => 4, y => 1, w => 4, h => 4 );

ok( $rect[51]->intersects( $rect[52] ), 'rect[51] intersects rect[52]' );
ok( $rect[52]->intersects( $rect[51] ), 'rect[52] intersects rect[51]' );

#    +---+
# +--++54|
# |53||  |
# +--++--+

$rect[53] = Rect->new( x => 1, y => 2, w => 4, h => 2 );
$rect[54] = Rect->new( x => 4, y => 1, w => 4, h => 3 );

ok( $rect[53]->intersects( $rect[54] ), 'rect[53] intersects rect[54]' );
ok( $rect[54]->intersects( $rect[53] ), 'rect[54] intersects rect[53]' );

# +--++--+
# |55||56|
# |  ++--+
# +---+

$rect[55] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[56] = Rect->new( x => 4, y => 1, w => 4, h => 2 );

ok( $rect[55]->intersects( $rect[56] ), 'rect[55] intersects rect[56]' );
ok( $rect[56]->intersects( $rect[55] ), 'rect[56] intersects rect[55]' );

# +---+
# |57++--+
# |  ||58|
# |  ++--+
# +---+

$rect[57] = Rect->new( x => 1, y => 1, w => 4, h => 4 );
$rect[58] = Rect->new( x => 4, y => 2, w => 4, h => 2 );

ok( $rect[57]->intersects( $rect[58] ), 'rect[57] intersects rect[58]' );
ok( $rect[58]->intersects( $rect[57] ), 'rect[58] intersects rect[57]' );

# +---+
# |59++--+
# |  ||60|
# +--++--+

$rect[59] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[60] = Rect->new( x => 4, y => 2, w => 4, h => 2 );

ok( $rect[59]->intersects( $rect[60] ), 'rect[59] intersects rect[60]' );
ok( $rect[60]->intersects( $rect[59] ), 'rect[60] intersects rect[59]' );

# +--+ +--+
# |61| |61|
# +--+ |  | +--+
# +--+ +--+ |  |
# |62|      |62|
# +--+      +--+

$rect[61] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[62] = Rect->new( x => 1, y => 3, w => 3, h => 3 );

ok( $rect[61]->intersects( $rect[62] ), 'rect[61] intersects rect[62]' );
ok( $rect[62]->intersects( $rect[61] ), 'rect[62] intersects rect[61]' );

# +--+
# |63|
# +--++
# +--+|
# |64 |
# +---+

$rect[63] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[64] = Rect->new( x => 1, y => 3, w => 4, h => 3 );

ok( $rect[63]->intersects( $rect[64] ), 'rect[63] intersects rect[64]' );
ok( $rect[64]->intersects( $rect[63] ), 'rect[64] intersects rect[63]' );

#  +--+
#  |65|
# ++--++
# |+--+|
# |66  |
# +----+

$rect[65] = Rect->new( x => 2, y => 1, w => 3, h => 3 );
$rect[66] = Rect->new( x => 1, y => 3, w => 5, h => 3 );

ok( $rect[65]->intersects( $rect[66] ), 'rect[65] intersects rect[66]' );
ok( $rect[66]->intersects( $rect[65] ), 'rect[66] intersects rect[65]' );

#  +--+
#  |67|
# ++--+
# |+--+
# |68 |
# +---+

$rect[67] = Rect->new( x => 2, y => 1, w => 3, h => 3 );
$rect[68] = Rect->new( x => 1, y => 3, w => 4, h => 3 );

ok( $rect[67]->intersects( $rect[68] ), 'rect[67] intersects rect[68]' );
ok( $rect[68]->intersects( $rect[67] ), 'rect[68] intersects rect[67]' );

# +---+
# |69 |
# +--+|
# +--++
# |70|
# +--+

$rect[69] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[70] = Rect->new( x => 1, y => 3, w => 3, h => 3 );

ok( $rect[69]->intersects( $rect[70] ), 'rect[69] intersects rect[70]' );
ok( $rect[70]->intersects( $rect[69] ), 'rect[70] intersects rect[69]' );

# +----+
# |71  |
# |+--+|
# ++--++
#  |72|
#  +--+

$rect[71] = Rect->new( x => 1, y => 1, w => 5, h => 3 );
$rect[72] = Rect->new( x => 2, y => 3, w => 3, h => 3 );

ok( $rect[71]->intersects( $rect[72] ), 'rect[71] intersects rect[72]' );
ok( $rect[72]->intersects( $rect[71] ), 'rect[72] intersects rect[71]' );

# +---+
# |73 |
# |+--+
# ++--+
#  |74|
#  +--+

$rect[73] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[74] = Rect->new( x => 2, y => 3, w => 3, h => 3 );

ok( $rect[73]->intersects( $rect[74] ), 'rect[73] intersects rect[74]' );
ok( $rect[74]->intersects( $rect[73] ), 'rect[74] intersects rect[73]' );

# +--+--+ +--+ +-----+
# |  |75| |  | |   75|
# +--+--+ |  | +-----+
# |76|    |76|
# +--+    +--+

$rect[75] = Rect->new( x => 1, y => 1, w => 6, h => 2 );
$rect[76] = Rect->new( x => 1, y => 1, w => 3, h => 4 );

ok( $rect[75]->intersects( $rect[76] ), 'rect[75] intersects rect[76]' );
ok( $rect[76]->intersects( $rect[75] ), 'rect[76] intersects rect[75]' );

# +--+--+--+
# |77|  |  |
# +--+--+--+
#    |78|
#    +--+

$rect[77] = Rect->new( x => 1, y => 1, w => 9, h => 2 );
$rect[78] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( $rect[77]->intersects( $rect[78] ), 'rect[77] intersects rect[78]' );
ok( $rect[78]->intersects( $rect[77] ), 'rect[78] intersects rect[77]' );

# +--+--+
# |79|  |
# +--+--+
#    |80|
#    +--+

$rect[79] = Rect->new( x => 1, y => 1, w => 6, h => 2 );
$rect[80] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( $rect[79]->intersects( $rect[80] ), 'rect[79] intersects rect[80]' );
ok( $rect[80]->intersects( $rect[79] ), 'rect[80] intersects rect[79]' );

# +--+
# |81|
# +--+--+
# |  |82|
# +--+--+

$rect[81] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[82] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( $rect[81]->intersects( $rect[82] ), 'rect[81] intersects rect[82]' );
ok( $rect[82]->intersects( $rect[81] ), 'rect[82] intersects rect[81]' );

#    +--+
#    |83|
# +--+--+--+
# |84|  |  |
# +--+--+--+

$rect[83] = Rect->new( x => 4, y => 1, w => 3, h => 4 );
$rect[84] = Rect->new( x => 1, y => 3, w => 9, h => 2 );

ok( $rect[83]->intersects( $rect[84] ), 'rect[83] intersects rect[84]' );
ok( $rect[84]->intersects( $rect[83] ), 'rect[84] intersects rect[83]' );

#    +--+
#    |85|
# +--+--+
# |86|  |
# +--+--+

$rect[85] = Rect->new( x => 4, y => 1, w => 3, h => 4 );
$rect[86] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( $rect[85]->intersects( $rect[86] ), 'rect[85] intersects rect[86]' );
ok( $rect[86]->intersects( $rect[85] ), 'rect[86] intersects rect[85]' );

#    +--+
#    |87|
# +--+--+
# |88|  |
# +--+--+
#    |  |
#    +--+

$rect[87] = Rect->new( x => 4, y => 1, w => 3, h => 6 );
$rect[88] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( $rect[87]->intersects( $rect[88] ), 'rect[87] intersects rect[88]' );
ok( $rect[88]->intersects( $rect[87] ), 'rect[88] intersects rect[87]' );

# +--+
# |89|
# +--+--+
# |  |90|
# +--+--+
# |  |
# +--+

$rect[89] = Rect->new( x => 1, y => 1, w => 3, h => 6 );
$rect[90] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( $rect[89]->intersects( $rect[90] ), 'rect[89] intersects rect[90]' );
ok( $rect[90]->intersects( $rect[89] ), 'rect[90] intersects rect[89]' );

#    +--+
#    |91|
# +--+--+--+
# |92|  |  |
# +--+--+--+
#    |  |
#    +--+

$rect[91] = Rect->new( x => 4, y => 1, w => 3, h => 6 );
$rect[92] = Rect->new( x => 1, y => 3, w => 9, h => 2 );

ok( $rect[91]->intersects( $rect[92] ), 'rect[91] intersects rect[92]' );
ok( $rect[92]->intersects( $rect[91] ), 'rect[92] intersects rect[91]' );

# +--+ +--+ +--+
# |93| |  | |93|
# +--+ |  | +--+
# |94| |94|
# +--+ +--+

$rect[93] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[94] = Rect->new( x => 1, y => 1, w => 3, h => 4 );

ok( $rect[93]->intersects( $rect[94] ), 'rect[93] intersects rect[94]' );
ok( $rect[94]->intersects( $rect[93] ), 'rect[94] intersects rect[93]' );

# +--+ +--+
# |95| |95|
# +--+ |  | +--+
# |96| |  | |96|
# +--+ +--+ +--+

$rect[95] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[96] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( $rect[95]->intersects( $rect[96] ), 'rect[95] intersects rect[96]' );
ok( $rect[96]->intersects( $rect[95] ), 'rect[96] intersects rect[95]' );

# +--+--+
# |97|98|
# +--+--+
#
# +-----+
# |   98|
# +-----+
#
# +--+
# |97|
# +--+

$rect[97] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[98] = Rect->new( x => 1, y => 1, w => 6, h => 2 );

ok( $rect[97]->intersects( $rect[98] ), 'rect[97] intersects rect[98]' );
ok( $rect[98]->intersects( $rect[97] ), 'rect[98] intersects rect[97]' );

# +--+---+
# |99|100|
# +--+---+
#
# +------+
# |99    |
# +------+
#
#    +---+
#    |100|
#    +---+

$rect[99]  = Rect->new( x => 1, y => 1, w => 7, h => 2 );
$rect[100] = Rect->new( x => 4, y => 1, w => 4, h => 2 );

ok( $rect[99]->intersects( $rect[100] ), 'rect[99] intersects rect[100]' );
ok( $rect[100]->intersects( $rect[99] ), 'rect[100] intersects rect[99]' );

# +---+---+---+
# |101|102|   |
# +---+---+---+
#
# +-----------+
# |101        |
# +-----------+
#
#     +---+
#     |102|
#     +---+

$rect[101] = Rect->new( x => 1, y => 1, w => 12, h => 2 );
$rect[102] = Rect->new( x => 5, y => 1, w => 4,  h => 2 );

ok( $rect[101]->intersects( $rect[102] ), 'rect[101] intersects rect[102]' );
ok( $rect[102]->intersects( $rect[101] ), 'rect[102] intersects rect[101]' );

# +---+ +---+
# |103| |103|
# +---+ |   | +---+
# |104| |   | |104|
# +---+ |   | +---+
# |   | |   |
# +---+ +---+

$rect[103] = Rect->new( x => 1, y => 1, w => 4, h => 6 );
$rect[104] = Rect->new( x => 1, y => 3, w => 4, h => 2 );

ok( $rect[103]->intersects( $rect[104] ), 'rect[103] intersects rect[104]' );
ok( $rect[104]->intersects( $rect[103] ), 'rect[104] intersects rect[103]' );

done_testing();
