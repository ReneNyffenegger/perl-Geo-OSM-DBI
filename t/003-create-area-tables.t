#!/usr/bin/perl
#
#  See inkscape created file t/002-data.svg for what's being
#  loaded with this script.
#


use strict;
use warnings;

use Test::Simple tests => 1;
use DBI;

use Geo::OSM::DBI;

my $area_schema = 'area_test';
my $db_area_schema = "${area_schema}.db";
my $db_test = 'test.db';
unlink $db_area_schema if -f $db_area_schema;

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_test") or die "Could not create $db_test";
$dbh->do("attach database '$db_area_schema' as $area_schema");
$dbh->{AutoCommit} = 0;

my $osm_db = Geo::OSM::DBI->new($dbh);

$osm_db -> create_area_tables(47, 48, 7, 9,
    {schema_name_to => $area_schema});

$dbh->commit;



ok(1);
