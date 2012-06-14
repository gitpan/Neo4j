package Neo4j::Types;

use Moose::Util::TypeConstraints;

subtype 'Neo4jData', as 'HashRef[ArrayRef[Str]|Str]';

coerce 'Neo4jData', from 'Undef', via { {} };

subtype 'URL', as 'Str', where { m!^https?://! };


1;
