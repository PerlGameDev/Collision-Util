package Collision::Util::Quadtree;

use strict;
use warnings;

use Collision::Util::Quadtree::Node;

sub new {
    my ( $class, %options ) = @_;

    my $self = bless {}, $class;

    $options{max_depth} = 7 unless exists $options{max_depth};
    $options{max_items} = 8 unless exists $options{max_items};

    $self->{root} = Collision::Util::Quadtree::Node->new(
        %options,
        tree   => $self,
        depth  => 0,
        parent => undef
    );

    $self->{node_for_item} = {};

    foreach my $item ( @{ $options{items} } ) {
        $self->insert($item);
    }

    return $self;
}

sub insert {
    my ( $self, $item ) = @_;
    $self->{root}->insert($item);
}

sub update {
    my ( $self, $item ) = @_;
    $self->{node_for_item}->{refaddr $item}->update($item);
}

sub register_item {
    my ($self, $item, $node) = @_;
    $self->{node_for_item}->{refaddr $item} = $node;
}

sub get_collisions {
    my ( $self, $rect ) = @_;

    $rect ||= $self->{root}->rect;

    return $self->{root}->get_collisions($rect);
}

1;

__END__

=head1 NAME

Collision::Util::Quadtree - Collision detection using a quadtree

=head1 SYNOPSIS

    my $quadtree = Collision::Util::Quadtree->new(%options);
    $quadtree->insert($rect1);
    $quadtree->insert($rect2);
    $quadtree->insert($rect3);
    my $collisions = $quadtree->get_collisions();

    # After changing the position of an item that has been inserted
    # into the quadtree, update their position in the tree before
    # calculating collisions.
    $quadtree->update($rect1);
    $quadtree->update($rect2);
    $quadtree->update($rect3);
    $collisions = $quadtree->get_collisions();

=head1 DESCRIPTION

Collision::Util::Quadtree is a data structure that reduces the number of
calculations necessary to determine all of the collisions in a set of
objects.  This is accomplished by recursively partitioning a two
dimensional space into four regions, determining which region each
object is contained in, and using that information to limit which
objects need to be checked for collisions.

=head1 METHODS

=head2 new(%options)

    my $quadtree = Collision::Util::Quadtree->new(
        x         => $x,
        y         => $y,
        w         => $width,
        h         => $height,
        max_items => $max_items,
        max_depth => $max_depth,
        items     => [ $item0, $item1, $item2, ... ],
    );

Creates a new quadtree data structure.  x, y, w and h are required.
These specify the space that contains items inserted into the tree.
Any item that is inserted into the quadtree must be completely contained
by this rectangle.

Options:

=over 4

=item * x => $x

=item * y => $y

=item * w => $width

=item * h => $height

=item * max_items => $max_items

Maximum number of items that will be stored in a node of the quadtree
before an attempt is made to partition the node.

=item * max_depth => $max_depth

Maximum depth of the quadtree.

=item * items => [ $item0, $item1, $item2, ... ]

Arrayref of items to insert into the quadtree.

=back

=head2 insert($rect)

Insert an item into the quadtree.  The only items that are currently
supported are rectangles.  Any object that is inserted must implement
methods C<x>, C<y>, C<w>, C<h> and C<intersects>.  See
L<Collision::Util::Rect> for an implementation of C<intersects>.

=head2 update($rect)

Update the position of an item in the quadtree after it has moved.  The
item must have already been inserted into the quadtree before this
method is used on the item.  This method should be called after the
inserted item's position has changed and before C<get_collisions> is
called.

=head2 get_collisions()

=head2 get_collisions($rect)

Returns an arrayref containing all items in the quadtree that intersect
another item in the quadtree.  If an optional rectangle is supplied,
only items that intersect that rectangle are checked for collisions.

=head1 SEE ALSO

L<Collision::Util::Quadtree::Node>, L<Collision::Util::Rect>,
L<Algorithm::QuadTree>

=head1 AUTHORS

Jeffrey T. Palmer, C<< <jtpalmer at cpan.org> >>

=head1 BUGS

There may be some bugs.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Breno G. de Oliveira.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
