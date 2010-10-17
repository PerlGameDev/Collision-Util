package Collision::Util::Rect;

use strict;
use warnings;

use Collision::Util qw(check_contains_rect check_collision_rect);
use Scalar::Util 'refaddr';

my %_x;
my %_y;
my %_w;
my %_h;
my %_v_x;
my %_v_y;

sub new {
    my ( $class, %options ) = @_;

    my $self = bless do { \my $anon_scalar }, $class;

    my $id = refaddr $self;
    $_x{$id}   = $options{x};
    $_y{$id}   = $options{y};
    $_w{$id}   = $options{w};
    $_h{$id}   = $options{h};
    $_v_x{$id} = exists $options{v_x} ? $options{v_x} : 0;
    $_v_y{$id} = exists $options{v_y} ? $options{v_y} : 0;

    return $self;
}

sub DESTROY {
    my ($self) = @_;

    my $id = refaddr $self;
    delete $_x{$id};
    delete $_y{$id};
    delete $_w{$id};
    delete $_h{$id};
    delete $_v_x{$id};
    delete $_v_y{$id};
}

sub x {
    my ( $self, $x ) = @_;
    my $id = refaddr $self;
    $_x{$id} = $x if defined $x;
    return $_x{$id};
}

sub y {
    my ( $self, $y ) = @_;
    my $id = refaddr $self;
    $_y{$id} = $y if defined $y;
    return $_y{$id};
}

sub w {
    my ( $self, $w ) = @_;
    my $id = refaddr $self;
    $_w{$id} = $w if defined $w;
    return $_w{$id};
}

sub h {
    my ( $self, $h ) = @_;
    my $id = refaddr $self;
    $_h{$id} = $h if defined $h;
    return $_h{$id};
}

sub v_x {
    my ( $self, $v_x ) = @_;
    my $id = refaddr $self;
    $_v_x{$id} = $v_x if defined $v_x;
    return $_v_x{$id};
}

sub v_y {
    my ( $self, $v_y ) = @_;
    my $id = refaddr $self;
    $_v_y{$id} = $v_y if defined $v_y;
    return $_v_y{$id};
}

sub intersects {
    my ( $self, $rect ) = @_;
    return $self->check_collision_rect($rect);
}

sub contains {
    my ( $self, $rect ) = @_;
    return $self->check_contains_rect($rect);
}

1;

__END__
