package Neo4j;

use 5.10.0;
use strict;
use warnings;

use Try::Tiny;
use Neo4j::Types;
use Moose;

use Neo4j::Node;
use Neo4j::Relationship;

use Neo4j::REST::Client;

our $VERSION = "0.01_01";

# TODO use key property for looking up a node or an edge

has 'service_root' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has 'client' => (
    isa => 'Neo4j::REST::Client',
    is  => 'rw',
    lazy => 1,
    builder => '_build_client',
);

sub _build_client {
    my $self = shift;
    return Neo4j::REST::Client->new( { root_URL => $self->service_root, } );
}

sub add_node {
    my $self = shift;
    my $data = shift;
    my $new_node =
      Neo4j::Node->new( { client => $self->client, data => $data } );
    return $new_node;
}

sub get_node {
    my $self = shift;
    my $id   = shift;
    my $node = Neo4j::Node->new( { client => $self->client, id => $id } );
    return $node;
}

sub delete_node {
    my $self = shift;
    my $id   = shift;
    my $url =
      sprintf( '%s/%s', $self->client->root_endpoint('node'), $self->id );
    $self->client->DELETE($url);

    for ( $self->client->status ) {
        when ('204') {

            # all good
            return undef;
        }
        when ('409') {

            # throw conflict, can't delete a node in a relation'
        }
        default {

            # throw exception
        }
    }
}

sub relationship_types {
    my $self = shift;
    $self->client->GET($self->client->root_endpoint('relationship_types'));

    for ( $self->client->status ) {
        when ('200') {
            # all good
            return decode_json($self->client->content);
        }
        default {
            # throw exception
        }
    }
}

sub get_relationship {
  my $self = shift;
  my $id   = shift;

  return undef unless defined $id;

  my $relationship = Neo4j::Relationship->new( { client => $self->client, id => $id } );
  return $relationship;
}

sub add_relationship {
  my $self = shift;
  my $args = shift;

  my $start = Neo4j::Node->new({_self_endpoint => $args->{start}, client => $self->client, });
  my $end = Neo4j::Node->new({_self_endpoint => $args->{end}, client => $self->client });

  try {
    my $new_relationship = Neo4j::Relationship->new({
        start => $start,
        end => $end,
        direction => $args->{direction},
        type => $args->{type},
        data => $args->{data},
        client => $self->client,
    });
    return $new_relationship;
  } catch {
    # wow something went really wrong
  }
}

1;

__END__

=head1 NAME

Neo4j - A client for the Neo4j graph database

=head1 SYNOPSIS

    use Neo4j;

    my $n = Neo4j->new({ service_root => 'http://localhost:7474/db/data' });

    my $node = $n->get_node(3);

    $node->set_property('foo', ["bar baz", "bada bada"]);
    $node->save;

=head1 METHODS

=head2 add_node

   $neo4j->add_node({ foo => 'bar', baz => [1,2,3,...], .... })

=head2 get_node

=head2 delete_node

=head2 add_relationship

=head2 get_relationship

=head2 relationship_types

=head1 TODO

More documentation

=head1 AUTHOR

Nuba Princigalli, C<< <nuba at stastu.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-neo4j at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Neo4j>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Neo4j

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Neo4j>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Neo4j>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Neo4j>

=item * Search CPAN

L<http://search.cpan.org/dist/Neo4j/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Nuba Princigalli.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

