#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 2;
use Test::More;

use_ok('Geo::OSM::DBI');
use_ok('Geo::OSM::DBI::Primitive::Relation');
