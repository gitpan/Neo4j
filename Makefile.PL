use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Neo4j',
    AUTHOR        => q{Nuba Princigalli <nuba@stastu.com>},
    VERSION_FROM  => 'lib/Neo4j.pm',
    ABSTRACT_FROM => 'lib/Neo4j.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'      => 0,
        'Class::Accessor' => 0,
        'JSON'            => 0,
        'REST::Client'    => 0,
        'Try::Tiny'    => 0,
        'Moose'    => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Neo4j-*' },
);
