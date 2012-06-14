#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Neo4j' ) || print "Bail out!\n";
}

diag( "Testing Neo4j $Neo4j::VERSION, Perl $], $^X" );
