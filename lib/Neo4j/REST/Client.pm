package Neo4j::REST::Client;

use 5.10.0;
use Moose;
use Data::Printer;

use REST::Client;
use JSON;
use Try::Tiny;

has 'root_URL' => (
    required => 1,
    isa      => 'Str',
    is       => 'rw',
);

has '_client' => (
    isa     => 'REST::Client',
    is      => 'rw',
    lazy    => 1,
    handles => {
        GET     => 'GET',
        POST    => 'POST',
        PUT     => 'PUT',
        DELETE  => 'DELETE',
        status  => 'responseCode',
        content => 'responseContent'
    },
    builder => '_build_client'
);

sub _build_client {
    my $self   = shift;
    my $client = REST::Client->new;
    $client->addHeader( 'Accept',       'application/json' );
    $client->addHeader( 'Content-Type', 'application/json' );
    return $client;
}

has 'root_endpoints' => (
    isa     => 'HashRef',
    is      => 'rw',
    lazy    => 1,
    builder => '_build_root_endpoints',
    traits  => ['Hash'],
    handles => { root_endpoint => 'get'}
);


sub _build_root_endpoints {
  my $self = shift;

  $self->root_URL( ($self->root_URL =~ m!/$!) ? $self->root_URL : $self->root_URL . '/' );

  $self->GET($self->root_URL);
  if($self->status eq '200') {
    my $root_endpoints = decode_json($self->content);
    # FIX for missing relationships endpoint on the API
    $root_endpoints->{relationship} = $self->root_URL . 'relationship';
    return $root_endpoints;
  } else {
    die "request not OK";
  }
}

# TODO
# around [qw(GET POST PUT DELETE)] => sub {
#     try {
#         # do the actual talking with the server
#       } catch {
#         # network errors
#       };
# };

=cut
                    root_endpoints   {
                        batch       "http://localhost:7474/db/data/batch",
                        cypher      "http://localhost:7474/db/data/cypher",
                        extensions   {
                            CypherPlugin   {
                                execute_query   "http://localhost:7474/db/data/ext/CypherPlugin/graphdb/execute_query"
                            },
                            GremlinPlugin   {
                                execute_script   "http://localhost:7474/db/data/ext/GremlinPlugin/graphdb/execute_script"
                            }
                        },
                        extensions_info   "http://localhost:7474/db/data/ext",
                        neo4j_version   "1.8.M02-117-g14b66aa-dirty",
                        node        "http://localhost:7474/db/data/node",
                        node_index   "http://localhost:7474/db/data/index/node",
                        reference_node   "http://localhost:7474/db/data/node/0",
                        relationship_index   "http://localhost:7474/db/data/index/relationship",
                        relationship_types   "http://localhost:7474/db/data/relationship/types"
                    },
                    root_URL   "http://localhost:7474/db/data/"
=cut

1;
