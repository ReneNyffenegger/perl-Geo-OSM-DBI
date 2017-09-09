#!/usr/bin/perl
use strict;
use warnings;

use Geo::OSM::DBI;
# use Geo::OSM::DBI::Primitive::Way;
use Geo::OSM::DBI::Primitive::Relation;

use Test::Simple tests => 2;
use Test::More;

use_ok('Geo::OSM::DBI');
# use_ok('Geo::OSM::DBI::Primitive::Way');
use_ok('Geo::OSM::DBI::Primitive::Relation');
