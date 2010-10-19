use strict;
use warnings;

package Rect;
use Collision::Util 'check_contains_rect';
sub new { my $class = shift; return bless {@_}, $class }
sub x { $_[0]->{x} = $_[1] if defined $_[1]; return $_[0]->{x} }
sub y { $_[0]->{y} = $_[1] if defined $_[1]; return $_[0]->{y} }
sub w { $_[0]->{w} = $_[1] if defined $_[1]; return $_[0]->{w} }
sub h { $_[0]->{h} = $_[1] if defined $_[1]; return $_[0]->{h} }
sub contains { $_[0]->check_contains_rect( $_[1] ) }

package main;

use Test::More;

BEGIN { use_ok( 'Collision::Util', 'check_contains_rect' ); }

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
    ok( $rect[$id]->contains( $rect[$id] ), "rect[$id] contains itself" );
    foreach ( grep { $_ != $id } ( 1 .. 4 ) ) {
        ok( !$rect[$id]->contains( $rect[$_] ), "rect[$id] does not contains rect[$_]");
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
    ok( $rect[5]->contains( $rect[$_] ), "rect[5] contains rect[$_]" );
}

foreach my $id ( 1 .. 4, 6 .. 10 ) {
    foreach ( grep { $_ != $id } ( 1 .. 4, 6 .. 10 ) ) {
        ok( !$rect[$id]->contains( $rect[$_] ),
            "rect[$id] does not contains rect[$_]"
        );
    }
}

#    +--+
# +--+12|
# |11+--+
# +--+

$rect[11] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[12] = Rect->new( x => 4, y => 1, w => 3, h => 2 );

ok( !$rect[11]->contains( $rect[12] ), 'rect[11] does not contains rect[12]');
ok( !$rect[12]->contains( $rect[11] ), 'rect[12] does not contains rect[11]');

# +--+
# |13+--+
# +--+14|
#    +--+

$rect[13] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[14] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[13]->contains( $rect[14] ), 'rect[14] does not contains rect[13]');
ok( !$rect[14]->contains( $rect[13] ), 'rect[13] does not contains rect[14]');

# +--+--+
# |15|16|
# +--+  |
#    +--+

$rect[15] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[16] = Rect->new( x => 4, y => 1, w => 3, h => 3 );

ok( !$rect[15]->contains( $rect[16] ), 'rect[15] does not contains rect[16]');
ok( !$rect[16]->contains( $rect[15] ), 'rect[16] does not contains rect[15]');

#    +--+
# +--+18|
# |17|  |
# +--+  |
#    +--+

$rect[17] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[18] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( !$rect[17]->contains( $rect[18] ), 'rect[17] does not contains rect[18]');
ok( !$rect[18]->contains( $rect[17] ), 'rect[18] does not contains rect[17]');

#    +--+
# +--+20|
# |19|  |
# +--+--+

$rect[19] = Rect->new( x => 1, y => 2, w => 3, h => 2 );
$rect[20] = Rect->new( x => 4, y => 1, w => 3, h => 3 );

ok( !$rect[19]->contains( $rect[20] ), 'rect[19] does not contains rect[20]');
ok( !$rect[20]->contains( $rect[19] ), 'rect[20] does not contains rect[19]');

# +--+--+
# |21|22|
# |  +--+
# +--+

$rect[21] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[22] = Rect->new( x => 4, y => 1, w => 3, h => 2 );

ok( !$rect[21]->contains( $rect[22] ), 'rect[21] does not contains rect[22]');
ok( !$rect[22]->contains( $rect[21] ), 'rect[22] does not contains rect[21]');

# +--+
# |23+--+
# |  |24|
# |  +--+
# +--+

$rect[23] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[24] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[23]->contains( $rect[24] ), 'rect[23] does not contains rect[24]');
ok( !$rect[24]->contains( $rect[23] ), 'rect[24] does not contains rect[23]');

# +--+
# |25+--+
# |  |26|
# +--+--+

$rect[25] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[26] = Rect->new( x => 4, y => 2, w => 3, h => 2 );

ok( !$rect[25]->contains( $rect[26] ), 'rect[25] does not contains rect[26]');
ok( !$rect[26]->contains( $rect[25] ), 'rect[26] does not contains rect[25]');

# +--+
# |27|
# ++-++
#  |28|
#  +--+

$rect[27] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[28] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[27]->contains( $rect[28] ), 'rect[27] does not contains rect[28]');
ok( !$rect[28]->contains( $rect[27] ), 'rect[28] does not contains rect[27]');

#  +--+
#  |29|
# ++-++
# |30|
# +--+

$rect[29] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[30] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( !$rect[29]->contains( $rect[30] ), 'rect[29] does not contains rect[30]');
ok( !$rect[30]->contains( $rect[29] ), 'rect[30] does not contains rect[29]');

# +--+
# |31|
# +--++
# |32 |
# ----+

$rect[31] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[32] = Rect->new( x => 1, y => 3, w => 4, h => 2 );

ok( !$rect[31]->contains( $rect[32] ), 'rect[31] does not contains rect[32]');
ok( !$rect[32]->contains( $rect[31] ), 'rect[32] does not contains rect[31]');

#  +--+
#  |33|
# ++--++
# |34  |
# +----+

$rect[33] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[34] = Rect->new( x => 1, y => 3, w => 5, h => 2 );

ok( !$rect[33]->contains( $rect[34] ), 'rect[33] does not contains rect[34]');
ok( !$rect[34]->contains( $rect[33] ), 'rect[34] does not contains rect[33]');

#  +--+
#  |35|
# ++--+
# |36 |
# +---+

$rect[35] = Rect->new( x => 2, y => 1, w => 3, h => 2 );
$rect[36] = Rect->new( x => 1, y => 3, w => 4, h => 2 );

ok( !$rect[35]->contains( $rect[36] ), 'rect[35] does not contains rect[36]');
ok( !$rect[36]->contains( $rect[35] ), 'rect[36] does not contains rect[35]');

# +---+
# |37 |
# +--++
# |38|
# +--+

$rect[37] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[38] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( !$rect[37]->contains( $rect[38] ), 'rect[37] does not contains rect[38]');
ok( !$rect[38]->contains( $rect[37] ), 'rect[38] does not contains rect[37]');

# +----+
# |39  |
# ++--++
#  |40|
#  +--+

$rect[39] = Rect->new( x => 1, y => 1, w => 5, h => 2 );
$rect[40] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[39]->contains( $rect[40] ), 'rect[39] does not contains rect[40]');
ok( !$rect[40]->contains( $rect[39] ), 'rect[40] does not contains rect[39]');

# +---+
# |41 |
# ++--+
#  |42|
#  +--+

$rect[41] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[42] = Rect->new( x => 2, y => 3, w => 3, h => 2 );

ok( !$rect[41]->contains( $rect[42] ), 'rect[41] does not contains rect[42]');
ok( !$rect[42]->contains( $rect[41] ), 'rect[42] does not contains rect[41]');

# +---+
# |43 |
# | +-+-+
# | | | |
# +-+-+ |
#   |44 |
#   +---+

$rect[43] = Rect->new( x => 1, y => 1, w => 4, h => 4 );
$rect[44] = Rect->new( x => 3, y => 3, w => 4, h => 4 );

ok( !$rect[43]->contains( $rect[44] ), 'rect[43] does not contains rect[44]');
ok( !$rect[44]->contains( $rect[43] ), 'rect[44] does not contains rect[43]');

#   +---+
#   |45 |
# +-+-+ |
# | | | |
# | +-+-+
# |46 |
# +---+

$rect[45] = Rect->new( x => 1, y => 3, w => 4, h => 4 );
$rect[46] = Rect->new( x => 3, y => 1, w => 4, h => 4 );

ok( !$rect[45]->contains( $rect[46] ), 'rect[45] does not contains rect[46]');
ok( !$rect[46]->contains( $rect[45] ), 'rect[46] does not contains rect[45]');

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

ok( !$rect[47]->contains( $rect[48] ), 'rect[47] does not contains rect[48]');
ok( !$rect[48]->contains( $rect[47] ), 'rect[48] does not contains rect[47]');

# +--++--+
# |49||50|
# +--++  |
#    +---+

$rect[49] = Rect->new( x => 1, y => 1, w => 4, h => 2 );
$rect[50] = Rect->new( x => 4, y => 1, w => 4, h => 3 );

ok( !$rect[49]->contains( $rect[50] ), 'rect[49] does not contains rect[50]');
ok( !$rect[50]->contains( $rect[49] ), 'rect[50] does not contains rect[49]');

#    +---+
# +--++52|
# |51||  |
# +--++  |
#    +---+

$rect[51] = Rect->new( x => 1, y => 2, w => 4, h => 2 );
$rect[52] = Rect->new( x => 4, y => 1, w => 4, h => 4 );

ok( !$rect[51]->contains( $rect[52] ), 'rect[51] does not contains rect[52]');
ok( !$rect[52]->contains( $rect[51] ), 'rect[52] does not contains rect[51]');

#    +---+
# +--++54|
# |53||  |
# +--++--+

$rect[53] = Rect->new( x => 1, y => 2, w => 4, h => 2 );
$rect[54] = Rect->new( x => 4, y => 1, w => 4, h => 3 );

ok( !$rect[53]->contains( $rect[54] ), 'rect[53] does not contains rect[54]');
ok( !$rect[54]->contains( $rect[53] ), 'rect[54] does not contains rect[53]');

# +--++--+
# |55||56|
# |  ++--+
# +---+

$rect[55] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[56] = Rect->new( x => 4, y => 1, w => 4, h => 2 );

ok( !$rect[55]->contains( $rect[56] ), 'rect[55] does not contains rect[56]');
ok( !$rect[56]->contains( $rect[55] ), 'rect[56] does not contains rect[55]');

# +---+
# |57++--+
# |  ||58|
# |  ++--+
# +---+

$rect[57] = Rect->new( x => 1, y => 1, w => 4, h => 4 );
$rect[58] = Rect->new( x => 4, y => 2, w => 4, h => 2 );

ok( !$rect[57]->contains( $rect[58] ), 'rect[57] does not contains rect[58]');
ok( !$rect[58]->contains( $rect[57] ), 'rect[58] does not contains rect[57]');

# +---+
# |59++--+
# |  ||60|
# +--++--+

$rect[59] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[60] = Rect->new( x => 4, y => 2, w => 4, h => 2 );

ok( !$rect[59]->contains( $rect[60] ), 'rect[59] does not contains rect[60]');
ok( !$rect[60]->contains( $rect[59] ), 'rect[60] does not contains rect[59]');

# +--+ +--+
# |61| |61|
# +--+ |  | +--+
# +--+ +--+ |  |
# |62|      |62|
# +--+      +--+

$rect[61] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[62] = Rect->new( x => 1, y => 3, w => 3, h => 3 );

ok( !$rect[61]->contains( $rect[62] ), 'rect[61] does not contains rect[62]');
ok( !$rect[62]->contains( $rect[61] ), 'rect[62] does not contains rect[61]');

# +--+
# |63|
# +--++
# +--+|
# |64 |
# +---+

$rect[63] = Rect->new( x => 1, y => 1, w => 3, h => 3 );
$rect[64] = Rect->new( x => 1, y => 3, w => 4, h => 3 );

ok( !$rect[63]->contains( $rect[64] ), 'rect[63] does not contains rect[64]');
ok( !$rect[64]->contains( $rect[63] ), 'rect[64] does not contains rect[63]');

#  +--+
#  |65|
# ++--++
# |+--+|
# |66  |
# +----+

$rect[65] = Rect->new( x => 2, y => 1, w => 3, h => 3 );
$rect[66] = Rect->new( x => 1, y => 3, w => 5, h => 3 );

ok( !$rect[65]->contains( $rect[66] ), 'rect[65] does not contains rect[66]');
ok( !$rect[66]->contains( $rect[65] ), 'rect[66] does not contains rect[65]');

#  +--+
#  |67|
# ++--+
# |+--+
# |68 |
# +---+

$rect[67] = Rect->new( x => 2, y => 1, w => 3, h => 3 );
$rect[68] = Rect->new( x => 1, y => 3, w => 4, h => 3 );

ok( !$rect[67]->contains( $rect[68] ), 'rect[67] does not contains rect[68]');
ok( !$rect[68]->contains( $rect[67] ), 'rect[68] does not contains rect[67]');

# +---+
# |69 |
# +--+|
# +--++
# |70|
# +--+

$rect[69] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[70] = Rect->new( x => 1, y => 3, w => 3, h => 3 );

ok( !$rect[69]->contains( $rect[70] ), 'rect[69] does not contains rect[70]');
ok( !$rect[70]->contains( $rect[69] ), 'rect[70] does not contains rect[69]');

# +----+
# |71  |
# |+--+|
# ++--++
#  |72|
#  +--+

$rect[71] = Rect->new( x => 1, y => 1, w => 5, h => 3 );
$rect[72] = Rect->new( x => 2, y => 3, w => 3, h => 3 );

ok( !$rect[71]->contains( $rect[72] ), 'rect[71] does not contains rect[72]');
ok( !$rect[72]->contains( $rect[71] ), 'rect[72] does not contains rect[71]');

# +---+
# |73 |
# |+--+
# ++--+
#  |74|
#  +--+

$rect[73] = Rect->new( x => 1, y => 1, w => 4, h => 3 );
$rect[74] = Rect->new( x => 2, y => 3, w => 3, h => 3 );

ok( !$rect[73]->contains( $rect[74] ), 'rect[73] does not contains rect[74]');
ok( !$rect[74]->contains( $rect[73] ), 'rect[74] does not contains rect[73]');

# +--+--+ +--+ +-----+
# |  |75| |  | |   75|
# +--+--+ |  | +-----+
# |76|    |76|
# +--+    +--+

$rect[75] = Rect->new( x => 1, y => 1, w => 6, h => 2 );
$rect[76] = Rect->new( x => 1, y => 1, w => 3, h => 4 );

ok( !$rect[75]->contains( $rect[76] ), 'rect[75] does not contains rect[76]');
ok( !$rect[76]->contains( $rect[75] ), 'rect[76] does not contains rect[75]');

# +--+--+--+
# |77|  |  |
# +--+--+--+
#    |78|
#    +--+

$rect[77] = Rect->new( x => 1, y => 1, w => 9, h => 2 );
$rect[78] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( !$rect[77]->contains( $rect[78] ), 'rect[77] does not contains rect[78]');
ok( !$rect[78]->contains( $rect[77] ), 'rect[78] does not contains rect[77]');

# +--+--+
# |79|  |
# +--+--+
#    |80|
#    +--+

$rect[79] = Rect->new( x => 1, y => 1, w => 6, h => 2 );
$rect[80] = Rect->new( x => 4, y => 1, w => 3, h => 4 );

ok( !$rect[79]->contains( $rect[80] ), 'rect[79] does not contains rect[80]');
ok( !$rect[80]->contains( $rect[79] ), 'rect[80] does not contains rect[79]');

# +--+
# |81|
# +--+--+
# |  |82|
# +--+--+

$rect[81] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[82] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( !$rect[81]->contains( $rect[82] ), 'rect[81] does not contains rect[82]');
ok( !$rect[82]->contains( $rect[81] ), 'rect[82] does not contains rect[81]');

#    +--+
#    |83|
# +--+--+--+
# |84|  |  |
# +--+--+--+

$rect[83] = Rect->new( x => 4, y => 1, w => 3, h => 4 );
$rect[84] = Rect->new( x => 1, y => 3, w => 9, h => 2 );

ok( !$rect[83]->contains( $rect[84] ), 'rect[83] does not contains rect[84]');
ok( !$rect[84]->contains( $rect[83] ), 'rect[84] does not contains rect[83]');

#    +--+
#    |85|
# +--+--+
# |86|  |
# +--+--+

$rect[85] = Rect->new( x => 4, y => 1, w => 3, h => 4 );
$rect[86] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( !$rect[85]->contains( $rect[86] ), 'rect[85] does not contains rect[86]');
ok( !$rect[86]->contains( $rect[85] ), 'rect[86] does not contains rect[85]');

#    +--+
#    |87|
# +--+--+
# |88|  |
# +--+--+
#    |  |
#    +--+

$rect[87] = Rect->new( x => 4, y => 1, w => 3, h => 6 );
$rect[88] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( !$rect[87]->contains( $rect[88] ), 'rect[87] does not contains rect[88]');
ok( !$rect[88]->contains( $rect[87] ), 'rect[88] does not contains rect[87]');

# +--+
# |89|
# +--+--+
# |  |90|
# +--+--+
# |  |
# +--+

$rect[89] = Rect->new( x => 1, y => 1, w => 3, h => 6 );
$rect[90] = Rect->new( x => 1, y => 3, w => 6, h => 2 );

ok( !$rect[89]->contains( $rect[90] ), 'rect[89] does not contains rect[90]');
ok( !$rect[90]->contains( $rect[89] ), 'rect[90] does not contains rect[89]');

#    +--+
#    |91|
# +--+--+--+
# |92|  |  |
# +--+--+--+
#    |  |
#    +--+

$rect[91] = Rect->new( x => 4, y => 1, w => 3, h => 6 );
$rect[92] = Rect->new( x => 1, y => 3, w => 9, h => 2 );

ok( !$rect[91]->contains( $rect[92] ), 'rect[91] does not contains rect[92]');
ok( !$rect[92]->contains( $rect[91] ), 'rect[92] does not contains rect[91]');

# +--+ +--+ +--+
# |93| |  | |93|
# +--+ |  | +--+
# |94| |94|
# +--+ +--+

$rect[93] = Rect->new( x => 1, y => 1, w => 3, h => 2 );
$rect[94] = Rect->new( x => 1, y => 1, w => 3, h => 4 );

ok( !$rect[93]->contains( $rect[94] ), 'rect[93] does not contains rect[94]');
ok( $rect[94]->contains( $rect[93] ), 'rect[94] contains rect[93]');

# +--+ +--+
# |95| |95|
# +--+ |  | +--+
# |96| |  | |96|
# +--+ +--+ +--+

$rect[95] = Rect->new( x => 1, y => 1, w => 3, h => 4 );
$rect[96] = Rect->new( x => 1, y => 3, w => 3, h => 2 );

ok( $rect[95]->contains( $rect[96] ), 'rect[95] contains rect[96]');
ok( !$rect[96]->contains( $rect[95] ), 'rect[96] does not contains rect[95]');

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

ok( !$rect[97]->contains( $rect[98] ), 'rect[97] does not contains rect[98]');
ok( $rect[98]->contains( $rect[97] ), 'rect[98] contains rect[97]');

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

$rect[99] = Rect->new( x => 1, y => 1, w => 7, h => 2 );
$rect[100] = Rect->new( x => 4, y => 1, w => 4, h => 2 );

ok( $rect[99]->contains( $rect[100] ), 'rect[99] contains rect[100]');
ok( !$rect[100]->contains( $rect[99] ), 'rect[100] does not contains rect[99]');

done_testing();
