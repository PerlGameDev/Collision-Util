package Collision::Util::Quadtree::Node;

use strict;
use warnings;

use Scalar::Util 'refaddr';
use Collision::Util::Rect;

use base 'Collision::Util::Rect';

my %_tree;
my %_depth;
my %_parent;
my %_children;
my %_items;
my %_is_partitioned;
my %_max_items;
my %_max_depth;

sub new {
    my ( $class, %options ) = @_;

    my $self = bless $class->SUPER::new(%options), $class;

    my $id = refaddr $self;
    $_tree{$id}           = $options{tree};
    $_depth{$id}          = $options{depth};
    $_parent{$id}         = $options{parent};
    $_max_items{$id}      = $options{max_items};
    $_max_depth{$id}      = $options{max_depth};
    $_children{$id}       = [];
    $_items{$id}          = [];
    $_is_partitioned{$id} = 0;

    return $self;
}

sub DESTROY {
    my ($self) = @_;

    my $id = refaddr $self;
    delete $_tree{$id};
    delete $_depth{$id};
    delete $_parent{$id};
    delete $_children{$id};
    delete $_items{$id};
    delete $_is_partitioned{$id};
    delete $_max_items{$id};
    delete $_max_depth{$id};
}

sub insert {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    if ( !$self->_insert_in_child($item) ) {

        push @{ $_items{$id} }, $item;
        $_tree{$id}->register_item( $item, $self );

        if ( !$_is_partitioned{$id} && @{ $_items{$id} } < $_max_items{$id} )
        {
            $self->partition();
        }
    }
}

sub _insert_in_child {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    return 0 if !$_is_partitioned{$id};

    foreach my $child ( @{ $_children{$id} } ) {
        if ( $child->contains($item) ) {
            $child->insert($item);
            return 1;
        }
    }

    return 0;
}

sub partition {
    my ($self) = @_;

    my $id = refaddr $self;

    return if $_depth{$id} == $_max_depth{$id};

    my ( $w, $h ) = ( $self->w / 2, $self->h / 2 );
    my ( $x1, $y1, $x2, $y2 )
        = ( $self->x, $self->y, $self->x + $w, $self->y + $h );

    my %options = (
        tree      => $_tree{$id},
        depth     => $_depth{$id} + 1,
        parent    => $self,
        max_depth => $_max_depth{$id},
        max_items => $_max_items{$id},
        w         => $w,
        h         => $h,
    );

    $_children{$id}->[0] = __PACKAGE__->new( %options, x => $x1, y => $y1 );
    $_children{$id}->[1] = __PACKAGE__->new( %options, x => $x2, y => $y1 );
    $_children{$id}->[2] = __PACKAGE__->new( %options, x => $x1, y => $y2 );
    $_children{$id}->[3] = __PACKAGE__->new( %options, x => $x2, y => $y2 );

    $_is_partitioned{$id} = 1;

    # Copy array, because it may be modified during the loop.
    my @items = @{ $_items{$id} };
    foreach my $item (@items) {
        $self->_push_down($item);
    }
}

sub _push_down {
    my ( $self, $item ) = @_;

    if ( $self->_insert_in_child($item) ) {
        my $id = refaddr $self;
        @{ $_items{$id} }
            = grep { refaddr $_ ne refaddr $item } @{ $_items{$id} };
        return 1;
    }
    else {
        return 0;
    }
}

sub _push_up {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;
    @{ $_items{$id} }
        = grep { refaddr $_ ne refaddr $item } @{ $_items{$id} };

    my $parent = $_parent{$id};
    if ( defined $parent ) {
        $parent->insert($item);
    }
    else {
        $self->insert($item);
    }
}

sub move {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    if (!$self->_push_down($item)) {
        $self->_push_up($item);
    }
}

sub get_items {
    my ( $self, $rect ) = @_;

    if ( $self->intersects($rect) ) {
        my $id    = refaddr $self;
        my @items = @{ $_items{$id} };

        if ( !$rect->contains($self) ) {
            @items = grep { $rect->intersects($_) } @items;
        }

        if ( $_is_partitioned{$id} ) {
            foreach my $child ( @{ $_children{$id} } ) {
                push @items, @{ $child->get_items($rect) };
            }
        }

        return \@items;
    }
    else {
        return [];
    }
}

sub get_collisions {
    my ( $self, $rect ) = @_;

    my $id = refaddr $self;

    my @collisions;

    my $max = @{ $_items{$id} } - 1;
    foreach my $item_id ( 0 .. $max ) {
        my $item = $_items{$id}->[$item_id];
        if ( $item->intersects($rect) ) {
            foreach my $other_id ( $item_id + 1 .. $max ) {
                my $other = $_items{$id}->[$other_id];
                if ( $item->intersects($other) ) {
                    push @collisions, $item;
                    push @collisions, $other;
                }
            }
            if ( $_is_partitioned{$id} ) {
                foreach my $child ( @{ $_children{$id} } ) {
                    foreach my $other ( @{ $child->get_items($rect) } ) {
                        if ( $item->intersects($other) ) {
                            push @collisions, $item;
                            push @collisions, $other;
                        }
                    }
                    push @collisions, @{ $child->get_collisions($rect) };
                }
            }
        }
    }

    return \@collisions;
}

1;

__END__
