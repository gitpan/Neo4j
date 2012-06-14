package Neo4j::Index;
use strict;
use warnings;

use 5.10.0;
use Moose;

use Neo4j::REST::Client;

use JSON;


has 'client' => (
    required => 1,
    isa      => 'Neo4j::REST::Client',
    is       => 'ro',
);

has '_self_endpoint' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

# TODO use Lucene::QueryParser

has 'name' => (
    isa      => 'Str',
    is       => 'rw',
);

has 'template' => (
    isa      => 'Str',
    is       => 'rw',
);

has 'provider' => (
    isa      => 'Str',
    is       => 'rw',
);


has 'index_type' => (
    isa      => 'Str',
    is       => 'rw',
);

with 'Neo4j::Role::REST', 'Neo4j::Role::Data';

# with every new Neo4j::Node, we create it on the database
sub BUILD {
    my $self = shift;
    if ( defined $self->id ) {
        # I have an ID already! I exist! just retrieve me!
        $self->get( $self->id );

    } elsif ( defined $self->_self_endpoint ) {
        $self->_self_endpoint;
        $self->get( ( split( '/', $self->_self_endpoint ) )[-1] );

    } else {
        $self->create;

        # have to create one from the provided data
    }
}

sub list_indexes {
}

sub new_index {
}

sub add_to_index {
}

sub delete_from_index {
}

sub exact_match {
}

sub query {
}

1;
