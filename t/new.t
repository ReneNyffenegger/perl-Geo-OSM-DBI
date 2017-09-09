#!/usr/bin/perl
use strict;
use warnings;

use Geo::OSM::DBI;
# use Geo::OSM::DBI::Primitive::Way;
use Geo::OSM::DBI::Primitive::Relation;

use Test::Simple tests => 4;
use Test::More;

my $db_test = 'test.db';

unlink $db_test if -f $db_test;

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_test") or die "Could not create $db_test";
$dbh->{AutoCommit} = 0;

my $osm_db = Geo::OSM::DBI->new($dbh);
my $rel    = Geo::OSM::DBI::Primitive::Relation->new(1, $osm_db);

isa_ok($rel, 'Geo::OSM::DBI::Primitive::Relation');
isa_ok($rel, 'Geo::OSM::DBI::Primitive');
isa_ok($rel, 'Geo::OSM::Primitive::Relation');
isa_ok($rel, 'Geo::OSM::Primitive');
