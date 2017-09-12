use warnings;
use strict;

use Geo::OSM::DBI;
use Test::More tests => 10;

my $db_test = 'test.db';
die unless -f $db_test;
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_test") or die "Could not create $db_test";
$dbh->{AutoCommit} = 0;

my $osm_db = Geo::OSM::DBI->new($dbh);

my @ways = $osm_db->ways;
is (scalar @ways, 9, '9 ways');

my @ways_sorted = sort { $a->{id} <=> $b->{id} } @ways;

is ($ways_sorted[0]->{id}, 1);
is ($ways_sorted[1]->{id}, 2);
is ($ways_sorted[2]->{id}, 3);
is ($ways_sorted[3]->{id}, 4);
is ($ways_sorted[4]->{id}, 5);
is ($ways_sorted[5]->{id}, 6);
is ($ways_sorted[6]->{id}, 7);
is ($ways_sorted[7]->{id}, 8);
is ($ways_sorted[8]->{id}, 9);

$dbh->commit;
