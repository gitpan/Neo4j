package Neo4j::Role::Data;

use Moose::Role;

has 'data' => (
    isa     => 'Neo4jData',
    is      => 'rw',
    lazy    => 0,
    default => sub { {} },
    traits => ['Hash'],
    handles => {
      get_property => 'get',
      set_property => 'set',
    }
);

1;
