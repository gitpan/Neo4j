package Neo4j::Role::REST;

use Moose::Role;

requires 'client', '_self_endpoint';

has '_endpoints' => (
    isa      => 'HashRef',
    is       => 'rw',
    lazy     => 1,
    traits   => ['Hash'],
    handles  => { endpoint => 'get' },
    required => 0,
    builder  => '_build_endpoints',
);

sub _build_endpoints {
    my $self = shift;
    # TODO should decode the content
#    $self->_endpoints(decode_json($self->client->GET($self->_self_endpoint)));
}

1;
