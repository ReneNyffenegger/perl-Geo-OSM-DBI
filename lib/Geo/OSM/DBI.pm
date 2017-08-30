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
use Time::HiRes qw(time);

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
#_{ Create base schema objects
sub create_base_schema_tables { #_{
#_{ POD

=head2 create_base_schema_tables

    $osm_db->create_base_schema_tables();
    $osm_db->create_base_schema_tables({schema => $schema_name);

Create the base tables C<nod>, C<nod_way>, C<rel_mem> and C<tag>.

After creating the schema, the tables should be filled with C<pbf2sqlite.v2.py>.

After filling the tables, the indexes on the tables should be created with L</create_base_schema_indexes>.


=cut

#_}
  
  my $self = shift;
  my $opts = shift;

  my ($schema, $schema_dot) = _schema_dot_from_opts($opts);
#  my $schema = delete $opts->{schema};
#  if ($schema) {
#    $schema = "$schema.";
#  }
#  else {
#    $schema = "";
#  }

# $self->{dbh}->do("
  $self->_sql_stmt("
    create table ${schema_dot}nod (
          id  integer primary key,
          lat real not null,
          lon real not null
    )",
    "create table ${schema_dot}nod"
  );


# $self->{dbh}->do("
  $self->_sql_stmt("
        create table ${schema_dot}nod_way (
          way_id         integer not null,
          nod_id         integer not null,
          order_         integer not null
    )",
  "create table ${schema_dot}nod_way");

# $self->{dbh}->do("
  $self->_sql_stmt("
        create table ${schema_dot}rel_mem (
          rel_of         integer not null,
          order_         integer not null,
          nod_id         integer,
          way_id         integer,
          rel_id         integer,
          rol            text
    )",
  "create table ${schema_dot}rel_mem");

# $self->{dbh}->do("
  $self->_sql_stmt("
        create table ${schema_dot}tag(
          nod_id      integer null,
          way_id      integer null,
          rel_id      integer null,
          key         text not null,
          val         text not null
   )",
 "create table ${schema_dot}tag");

} #_}
sub create_base_schema_indexes { #_{
#_{ POD

=head2 create_base_schema_indexes()

    $osm_db->create_base_schema_tables();

    # fill tables (as of yet with pbf2sqlite.v2.py

    $osm_db->create_base_schema_indexes();
    # or, if create_base_schema_indexes was created in another schema:
    $osm_db->create_base_schema_indexes({schema=>$schema_name);

Create the base tables C<nod>, C<nod_way>, C<rel_mem> and C<tag>.

After creating the base schema and filling the tables, the indexes should be created on the base schema tables.

=cut

  my $self = shift;
  my $opts = shift;

  my ($schema, $schema_dot) = _schema_dot_from_opts($opts);

#
# TODO: to put the schema in front of the index name rather than the table name seems
#       to be very sqlite'ish.
#
  $self->_sql_stmt("create index ${schema_dot}nod_way_ix_way_id on nod_way (way_id)"   , "index ${schema_dot}nod_way_ix_way_id");
                                                                                                                               
  $self->_sql_stmt("create index ${schema_dot}tag_ix_val        on tag     (     val)" , "index ${schema_dot}tag_ix_val"       );
  $self->_sql_stmt("create index ${schema_dot}tag_ix_key_val    on tag     (key, val)" , "index ${schema_dot}tag_ix_key_val"   );
                                                                                                                               
  $self->_sql_stmt("create index ${schema_dot}tag_ix_nod_id     on tag     (nod_id)"   , "index ${schema_dot}tag_ix_nod_id"    );
  $self->_sql_stmt("create index ${schema_dot}tag_ix_way_id     on tag     (way_id)"   , "index ${schema_dot}tag_ix_way_id"    );
  $self->_sql_stmt("create index ${schema_dot}tag_ix_rel_id     on tag     (rel_id)"   , "index ${schema_dot}tag_ix_rel_id"    );

# 2017-08-28
# $self->{dbh}->do("create index ${schema_dot}rel_mem_ix_nod_id on rel_mem (nod_id)"   );
  $self->_sql_stmt("create index ${schema_dot}rel_mem_ix_rel_of on rel_mem (rel_of)"   , "index ${schema_dot}rel_mem_ix_rel_of");

#_}
} #_}
#_}
sub create_table_municipalities { #_{
#_{ POD

=head2 create_table_municipalities

    $osm->create_table_municipalities();

Creates the table C<municipalites>.

=cut

#_}

  my $self = shift;

  $self -> _sql_stmt("
    create table municipalities (
      rel_id                   integer primary key,
      name                     text    not null,
      min_lat                  real    not null,
      min_lon                  real    not null,
      max_lat                  real    not null,
      max_lon                  real    not null,
      cnt_ways                 integer not null,
      cnt_nodes                integer not null,
      cnt_nodes_verification   integer not null
    )",
    "create table municipalities"
  );

  $self -> _sql_stmt("
    insert into municipalities
    select
       admi.rel_id rel_id,
       name.val    name,
       min  (node.lat            )   min_lat,
       min  (node.lon            )   min_lon,
       max  (node.lat            )   max_lat,
       max  (node.lon            )   max_lon,
       count(distinct relm.way_id)   cnt_ways,
       count(distinct node.id    )   cnt_nodes,
    /* cnt_nodes_verification: 
          Must/should be 0 because each way counts one node that another way already counted.
          Borders that are not 100 % in the database return -1 or so.
    */
       count(*                   ) -
       count(distinct relm.way_id) -
       count(distinct node.id    )   cnt_nodes_verification
    from
      tag     admi                                   join
      tag     name on admi.rel_id = name.rel_id      join
      rel_mem relm on admi.rel_id = relm.rel_of      join
      nod_way nodw on relm.way_id = nodw.way_id      join
      nod     node on nodw.nod_id = node.id
    where
      admi.key = 'admin_level' and
      admi.val =  8            and
      name.key = 'name'
    group by
      admi.rel_id,
      name.val
     order by
    --   relm.way_id,
    --   node.id
      cnt_nodes_verification,
      name
  ", "fill table municipalities");

#   $self -> _sql_stmt("
#     create table municipalities as
#     select
#       muni.rel_id rel_id,
#       name.val    name,
#       borw.id
#     from
#       tag     muni                                   join
#       tag     name on muni.rel_id = name.rel_id      join
#       rel_mem borr on muni.rel_id = borr.rel_of      join
#       way     borw on borr.way_id = borw.id
#     where
#       muni.key = 'admin_level' and
#       name.key = 'name'        and
#       muni.val =  8
#    ",
#    'create table municipalites');

} #_}
sub create_area_tables { #_{
#_{ POD

=head2 new

    $osm_db->create_area_tables($lat_min, $lat_max, $lon_min, $lon_max, {
      schema_name_from => 'main',
      schema_name_to   => 'area'
    });


=cut

#_}

  my $self    = shift;
  my $lat_min = shift;
  my $lat_max = shift;
  my $lon_min = shift;
  my $lon_max = shift;
  my $opts    = shift;

  my ($schema_name_to, $schema_name_to_dot) = _schema_dot_from_opts($opts, 'schema_name_to');
  croak "Must have a destination schema name" unless $schema_name_to;


  $self->create_base_schema_tables({schema=>$schema_name_to});

  #_{ nod

  # my $f = '%16.13f';
    my $f = '%s';
    
    my $stmt = sprintf("
    
      insert into ${schema_name_to_dot}nod
      select * from nod
      where 
        lat between $f and $f and
        lon between $f and $f
    
    ", $lat_min, $lat_max, $lon_min, $lon_max);
    
    $self->_sql_stmt($stmt, "${schema_name_to}nod filled");
    

  #_}
  #_{ nod_way

    $stmt = sprintf("
    
      insert into ${schema_name_to_dot}nod_way
      select * from nod_way
      where 
         nod_id in (
          select
            id
          from
            ${schema_name_to_dot}nod
      )
     ");

    $self->_sql_stmt($stmt, "${schema_name_to_dot}nod_way filled");

  #_}
  #_{ rel_mem

    $stmt = sprintf("
    
      insert into ${schema_name_to_dot}rel_mem
      select * from rel_mem
      where
        nod_id in (select              id from ${schema_name_to_dot}nod    ) or
        way_id in (select distinct way_id from ${schema_name_to_dot}nod_way) or
        rel_id in (select distinct rel_id 
                    from rel_mem where
        nod_id in (select              id from ${schema_name_to_dot}nod    ) or
        way_id in (select distinct way_id from ${schema_name_to_dot}nod_way)
        )                                                                    or
        rel_id in (select distinct rel_of 
                    from rel_mem where
        nod_id in (select              id from ${schema_name_to_dot}nod    ) or
        way_id in (select distinct way_id from ${schema_name_to_dot}nod_way)
        )
     ");

    $self->_sql_stmt($stmt, "${schema_name_to_dot}.nod_rel filled");

  #_}
  #_{ tag

    $stmt = sprintf("

      insert into ${schema_name_to_dot}tag
      select * from tag
      where 
        nod_id in (select              id from ${schema_name_to_dot}nod    ) or
        way_id in (select distinct way_id from ${schema_name_to_dot}nod_way) or
        rel_id in (select distinct rel_of from ${schema_name_to_dot}rel_mem) or
        rel_id in (select distinct rel_id from ${schema_name_to_dot}rel_mem)
     ");

    $self->_sql_stmt($stmt, "area_db.way_rel filled");

  #_}

  $self->create_base_schema_indexes({schema=>$schema_name_to});

} #_}
sub _schema_dot_from_opts { #_{
#_{ POD

=head2 _schema_dot_from_opts

    my ($schema, $schema_dot) = _schema_dot_from_opts($opts            );
    # or
    my ($schema, $schema_dot) = _schema_dot_from_opts($opts, "opt_name");

Returns C<< ('schema_name', 'schema_name.') >>  or C<< ('', '') >>.

=cut

#_}

  my $opts    = shift;
  my $name    = shift // 'schema';

  my $schema = delete $opts->{$name} // '';
  my $schema_dot = '';
  if ($schema) {
    $schema_dot = "$schema.";
  }
  return ($schema, $schema_dot);

} #_}
sub _sql_stmt { #_{
#_{ POD

=head2 _sql_stmt

    $self->_sql_stmt($sql_text, 'dientifiying text')

Internal function. executes C<$sql_text>. Prints time it took to complete

=cut

#_}

  my $self = shift;
  my $stmt = shift;
  my $desc = shift;

  my $t0 = time;
  $self->{dbh}->do($stmt) or croak ("Could not execute $stmt");
  my $t1 = time;

  printf("SQL: $desc, took %6.3f seconds\n", $t1-$t0);

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
