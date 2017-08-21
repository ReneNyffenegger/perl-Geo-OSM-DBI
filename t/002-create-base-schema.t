use strict;
use warnings;

use Test::Simple tests => 1;
use DBI;

use Geo::OSM::DBI;

my $db_test = 'test.db';

unlink $db_test if -f $db_test;

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_test") or die "Could not create $db_test";
$dbh->{AutoCommit} = 0;

my $osm_db = Geo::OSM::DBI->new($dbh);
 
$osm_db->create_base_schema_tables();
 
open (my $sql, '<', 't/002-fill-base-schema.sql') or die "Could not open t/002-fill-base-schema.sql";

while (my $stmt = <$sql>) {
  chomp $stmt;
  $stmt =~ s/--.*//;
  next unless $stmt =~ /\S/;
  print "$stmt\n";
  $osm_db->{dbh}->do($stmt) or die "Could not execute $stmt";
}


close $sql;
 
$osm_db->create_base_schema_indexes();

$dbh->commit;
ok(1);
