package Neo4j::Node;
use strict;
use warnings;

use 5.10.0;
use Moose;
use Neo4j::Relationship;

use Neo4j::REST::Client;

use Data::Printer;
use JSON;

has 'id' => (
    isa      => 'Num',
    required => 0,
    is       => 'rw',
);

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

sub get {
    my $self = shift;
    my $id = shift;

    my $url = sprintf( '%s/%s', $self->client->root_endpoint('node'), $id );

    $self->client->GET($url);

    for ( $self->client->status ) {
        when ('200') {
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->_self_endpoint( $self->_endpoints->{self} );
            $self->data( $self->_endpoints->{data} );
            return $self;
        }
        when ('404') {

            # not found
            return undef;
        }
        default {

            # ooops something's wrong!
        }
    }
}

sub create {
    my $self = shift;
    $self->client->POST( $self->client->root_endpoint('node'),
        encode_json( $self->data ) );

    for ( $self->client->status ) {
        when ('201') {

            # all good
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->_self_endpoint( $self->_endpoints->{self} );
            $self->id( ( split( '/', $self->_self_endpoint ) )[-1] );
            $self->data( $self->_endpoints->{data} );
            return $self;
        }
        default {

            # should throw exception
        }
    }
}

sub save {
    my $self = shift;
    $self->client->PUT( $self->endpoint('properties'), encode_json( $self->data ) );

    for ( $self->client->status ) {
        when (201) {

            # all good
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->data( $self->_endpoints->{data} );
            return $self;
        }
        default {

            # should throw exception
        }
    }
}

sub clear_properties {
    my $self = shift;
    $self->data({});
    return $self;
}

sub reload {
    my $self = shift;
    return $self->get($self->id);
}

sub delete {
    my $self = shift;
    $self->client->DELETE( $self->_self_endpoint );

    for ( $self->client->status ) {
        when ('204') {

            # all good
            return undef;
        }
        when ('409') {

            # should throw a conflict exception,
            # can't delete a node in a relation
        }
        default {
            # should throw exception
        }
    }
}

sub relationships {
    my $self = shift;
    my $args = shift;

    my $url;

    if(defined $args->{direction}) {
      for($args->{direction}) {
        when('all') {
          $url = $self->endpoint('all_relationships');
        }
        when('in'){
          $url = $self->endpoint('incoming_relationships');
        }
        when('out'){
          $url = $self->endpoint('outgoing_relationships');
        }
        default{
          #all
          $url = $self->endpoint('all_relationships');
        }
      }
    } else {
          $url = $self->endpoint('all_relationships');

    }

    if(defined $args->{type}) {
          $url .= '/' . join('&', $args->{type})
    }

    $self->client->GET($url);

    for ( $self->client->status ) {
        when ('200') {
            my @processed_payload = map { Neo4j::Relationship->new({ client => $self->client, _self_endpoint => $_->{self} })} @{ decode_json( $self->client->content ) };
            return [ @processed_payload ];
        }
        when ('404') {

            # not found
            return undef;
        }
        default {

            # ooops something's wrong!
        }
    }

}

sub incoming_relationships {

}

sub outgoing_relationships {

}

1;

=cut
            _endpoints   {
                all_relationships     "http://localhost:7474/db/data/node/124/relationships/all",
                all_typed_relationships   "http://localhost:7474/db/data/node/124/relationships/all/{-list|&|types}",
                create_relationship   "http://localhost:7474/db/data/node/124/relationships",
                data                  var{Zeta}{data},
                extensions            {},
                incoming_relationships   "http://localhost:7474/db/data/node/124/relationships/in",
                incoming_typed_relationships   "http://localhost:7474/db/data/node/124/relationships/in/{-list|&|types}",
                outgoing_relationships   "http://localhost:7474/db/data/node/124/relationships/out",
                outgoing_typed_relationships   "http://localhost:7474/db/data/node/124/relationships/out/{-list|&|types}",
                paged_traverse        "http://localhost:7474/db/data/node/124/paged/traverse/{returnType}{?pageSize,leaseTime}",
                properties            "http://localhost:7474/db/data/node/124/properties",
                property              "http://localhost:7474/db/data/node/124/properties/{key}",
                self                  "http://localhost:7474/db/data/node/124",
                traverse              "http://localhost:7474/db/data/node/124/traverse/{returnType}"
=cut

