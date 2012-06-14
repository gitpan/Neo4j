package Neo4j::Relationship;

use 5.10.0;
use strict;
use warnings;

use Moose;

use Neo4j::REST::Client;
use Neo4j::Node;

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

has ['start', 'end'] => (
  isa => 'Neo4j::Node',
  is => 'rw',
  required => 0,
);

has 'direction' => (
  isa => 'Str|Undef',
  is => 'rw',
  lazy => 1,
  default => 'out',
);

has relationship_type => (
  isa => 'Str',
  is => 'rw',
  lazy => 1,
  default => 'RELATES_TO',
);

with 'Neo4j::Role::REST', 'Neo4j::Role::Data';


# with every new Neo4j::Relationship, we create it on the database
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
    my $url = sprintf( '%s/%s', $self->client->root_endpoint('relationship'), $id );
    $self->client->GET($url);

    for ( $self->client->status ) {
        when ('200') {
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->_self_endpoint( $self->_endpoints->{self} );

            $self->data( $self->_endpoints->{data} || { });

            # TODO improve naming choices, this one here really isn't helping

            $self->start( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{start},
              })
            );

            $self->end( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{end},
              })
            );

            $self->direction( $self->_endpoints->{direction} || 'out');

            $self->relationship_type( $self->_endpoints->{relationship_type} || 'RELATES_TO' );

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

    # // direction determines start and end
    # // POST /node/x/relationships {to: y etc etc }

    my $url = $self->start->endpoint('create_relationship');

    my $payload = {
      to => $self->end->endpoint('self'),
      type => $self->relationship_type,
      data => $self->data,
      dir => $self->direction
    };

    $self->client->POST($url, encode_json( $payload) );

    for ( $self->client->status ) {
        when ('201') {
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->_self_endpoint( $self->_endpoints->{self} );

            $self->data( $self->_endpoints->{data} || { });

            # TODO improve naming choices, this one here really isn't helping

            $self->start( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{start},
              })
            );

            $self->end( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{end},
              })
            );

            $self->direction( $self->_endpoints->{direction} || 'out');

            $self->relationship_type( $self->_endpoints->{relationship_type} || 'RELATES_TO' );

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

1;

sub save {
    my $self = shift;
    my $url = $self->endpoint('properties');
    p $url;

    $self->client->PUT($url, encode_json( $self->data) );

    for ( $self->client->status ) {
        when ('201') {
            $self->_endpoints( decode_json( $self->client->content ) );
            $self->_self_endpoint( $self->_endpoints->{self} );

            $self->data( $self->_endpoints->{data} || { });

            # TODO improve naming choices, this one here really isn't helping

            $self->start( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{start},
              })
            );

            $self->end( Neo4j::Node->new({
                client => $self->client,
                _self_endpoint => $self->_endpoints->{end},
              })
            );

            $self->direction( $self->_endpoints->{direction} || 'out');

            $self->relationship_type( $self->_endpoints->{relationship_type} || 'RELATES_TO' );

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

sub delete {
    my $self = shift;
    $self->client->DELETE( $self->_self_endpoint );

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

