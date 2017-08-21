# Encoding and name

=encoding utf8
=head1 NAME
Geo::OSM::DBI

Store Open Street Map data with DBI.
=cut
#
package Geo::OSM::DBI;

use warnings;
use strict;

use DBI;

use utf8;

use Carp;

our $VERSION = 0.01;
#_{ Synopsis

=head1 SYNOPSIS
    use Geo::OSM::DBI;
=cut
#_}
#_{ Methods

=head1 METHODS
=cut

sub new { #_{
#_{ POD

=head2 new

    my $osm_db = Geo::OSM::DBI->new($dbh);

Create and return a C<< Geo::OSM::DBI >> object that will access the Open Street Database referenced by the C<DBI::db> object C<$dbh>).
It's unclear to me what a C<DBI::db> object actually is...

=cut

#_}

  my $class = shift;
  my $dbh   = shift;

  croak "dbh is not a DBI object ($dbh)" unless $dbh -> isa('DBI::db');

  my $self = {};
  bless $self, $class;
  croak "Wrong class $class" unless $self->isa('Geo::OSM::DBI');

  $self->{dbh} = $dbh;

  return $self;

} #_}
sub create_base_schema_tables { #_{
#_{ POD

=head2 create_base_schema_tables

    $osm_db->create_base_schema_tables();

Create the base tables C<nod>, C<nod_way>, C<rel_mem> and C<tag>.

After creating the schema, the tables should be filled with C<pbf2sqlite.v2.py>.

After filling the tables, the indexes on the tables should be created with L</create_base_schema_indexes>.


=cut

#_}
  
  my $self = shift;

  $self->{dbh}->do("
    create table nod (
          id  integer primary key,
          lat real not null,
          lon real not null
    )");

  $self->{dbh}->do("
        create table nod_way (
          way_id         integer not null,
          nod_id         integer not null,
          order_         integer not null
    )");

  $self->{dbh}->do("
        create table rel_mem (
          rel_of         integer not null,
          order_         integer not null,
          way_id         integer,
          nod_id         integer,
          rel_id         integer,
          rol            text
    )");

  $self->{dbh}->do("
        create table tag(
          nod_id      integer null,
          way_id      integer null,
          rel_id      integer null,
          key         text not null,
          val         text not null
   )");

} #_}
sub create_base_schema_indexes { #_{
#_{ POD

=head2 create_base_schema_indexes()

    $osm_db->create_base_schema_tables();

    # fill tables (as of yet with pbf2sqlite.v2.py

    $osm_db->create_base_schema_indexes();

Create the base tables C<nod>, C<nod_way>, C<rel_mem> and C<tag>.

After creating the base schema and filling the tables, the indexes should be created on the base schema tables.

=cut

  my $self = shift;

  $self->{dbh}->do('create index nod_way_ix_way_id on nod_way (way_id)'   );

  $self->{dbh}->do('create index tag_ix_val        on tag     (     val)' );
  $self->{dbh}->do('create index tag_ix_key_val    on tag     (key, val)' );

  $self->{dbh}->do('create index tag_ix_nod_id     on tag     (nod_id)'   );
  $self->{dbh}->do('create index tag_ix_way_id     on tag     (way_id)'   );
  $self->{dbh}->do('create index tag_ix_rel_id     on tag     (rel_id)'   );

#_}
} #_}

#_}
#_{ POD: Copyright

=head1 Copyright
Copyright © 2017 René Nyffenegger, Switzerland. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>
=cut

#_}
#_{ POD: Source Code

=head1 Source Code

The source code is on L<< github|https://github.com/ReneNyffenegger/perl-Geo-OSM-DBI >>. Meaningful pull requests are welcome.

=cut

#_}

'tq84';
