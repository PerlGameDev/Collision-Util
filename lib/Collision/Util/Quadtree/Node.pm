package Collision::Util::Quadtree::Node;

use strict;
use warnings;

use Scalar::Util 'refaddr';
use Collision::Util::Rect;

my %_rect;
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

    my $self = bless do { \my $anon_scalar }, $class;

    my $id = refaddr $self;
    $_rect{$id}           = Collision::Util::Rect->new(%options);
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
    delete $_rect{$id};
    delete $_tree{$id};
    delete $_depth{$id};
    delete $_parent{$id};
    delete $_children{$id};
    delete $_items{$id};
    delete $_is_partitioned{$id};
    delete $_max_items{$id};
    delete $_max_depth{$id};
}

sub rect {
    return $_rect{ refaddr $_[0] };
}

sub insert {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    if ( !$_rect{$id}->contains($item) ) {
        my $parent = $_parent{$id};
        if ( defined $parent ) {
            $parent->insert($item);
        }
        else {
            warn "Item is outside of tree\n";
        }
        return;
    }

    if ( !$self->_insert_in_child($item) ) {

        push @{ $_items{$id} }, $item;
        $_tree{$id}->register_item( $item, $self );

        if ( !$_is_partitioned{$id} && @{ $_items{$id} } > $_max_items{$id} ) {
            $self->partition();
        }
    }
}

sub _insert_in_child {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    return 0 if !$_is_partitioned{$id};

    foreach my $child ( @{ $_children{$id} } ) {
        if ( $child->rect->contains($item) ) {
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

    my $rect = $_rect{$id};
    my ( $w, $h ) = ( $rect->w / 2, $rect->h / 2 );
    my ( $x1, $y1 ) = ( $rect->x, $rect->y );
    my ( $x2, $y2 ) = ( $x1 + $w, $y1 + $h );

    my %options = (
        tree      => $_tree{$id},
        depth     => $_depth{$id} + 1,
        parent    => $self,
        max_depth => $_max_depth{$id},
        max_items => $_max_items{$id},
        w         => $w,
        h         => $h,
    );

    $_children{$id} = [
        __PACKAGE__->new( %options, x => $x1, y => $y1 ),
        __PACKAGE__->new( %options, x => $x2, y => $y1 ),
        __PACKAGE__->new( %options, x => $x1, y => $y2 ),
        __PACKAGE__->new( %options, x => $x2, y => $y2 ),
    ];

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
        $self->remove($item);
        return 1;
    }
    else {
        return 0;
    }
}

sub _push_up {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    $self->remove($item);

    $_parent{$id}->insert($item);
}

sub update {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    if ( !$self->_push_down($item) ) {
        if ( defined $_parent{$id} ) {
            $self->_push_up($item);
        }
    }
}

sub remove {
    my ( $self, $item ) = @_;

    my $id = refaddr $self;

    @{ $_items{$id} } = grep { refaddr $_ ne refaddr $item } @{ $_items{$id} };
}

sub get_items {
    my ( $self, $rect ) = @_;

    my $id = refaddr $self;
    if ( $_rect{$id}->intersects($rect) ) {
        my @items = @{ $_items{$id} };

        if ( !$rect->contains( $_rect{$id} ) ) {
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
                    if ( $item->intersects( $child->rect ) ) {
                        foreach my $other ( @{ $child->get_items($rect) } ) {
                            if ( $item->intersects($other) ) {
                                push @collisions, $item;
                                push @collisions, $other;
                            }
                        }
                    }
                }
            }
        }
    }

    if ( $_is_partitioned{$id} ) {
        foreach my $child ( @{ $_children{$id} } ) {
            push @collisions, @{ $child->get_collisions($rect) };
        }
    }

    return \@collisions;
}

1;

__END__
