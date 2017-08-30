#_{ Encoding and name

=encoding utf8
=head1 NAME
Geo::OSM::DBI::CH

Store Open Street Map data with DBI, especially for Switzerland
=cut

package Geo::OSM::DBI::CH;

#_}
#_{ use ...
use warnings;
use strict;

use DBI;

use utf8;
use Carp;

use Geo::OSM::DBI;
our @ISA = qw(Geo::OSM::DBI);

#_}
our $VERSION = 0.01;
#_{ Synopsis

=head1 SYNOPSIS
    use Geo::OSM::DBI;
    # or ...
    use Geo::OSM::DBI::CH;

The exact specifica are yet to be defined.
=cut
#_}
#_{ Methods

=head1 METHODS
=cut

sub new { #_{
#_{ POD

=head2 new

    my $osm_db_ch = Geo::OSM::DBI::CH->new($dbh);

Create and return a C<< Geo::OSM::DBI::CH >> object that will access the Open Street Database referenced by the C<DBI::db> object C<$dbh>).
It's unclear to me what a C<DBI::db> object actually is...

=cut

#_}

  my $class = shift;
  my $dbh   = shift;

# croak "dbh is not a DBI object ($dbh)" unless $dbh -> isa('DBI::db');

  my $self = $class->SUPER::new($dbh);

  croak "Wrong class $class" unless $self->isa('Geo::OSM::DBI::CH');

  return $self;

} #_}
sub create_table_municipalities_ch { #_{
#_{ POD

=head2 create_table_municipalities_ch

    $osm_db_ch->create_table_municipalities_ch();


First creates the table C<municipalities> by calling the
L<< parent's class|Geo::OSM::DBI >> L<< create_table_municipalities|Geo::OSM::DBI/create_table_municipalities >>.
Then, it uses the data in table C<municipalities> to create C<municipalities_ch>.
Finanlly, it creates the view C<municipalities_ch_v>.

=cut

#_}
  
  my $self = shift;

  # Call method in parent class:
  $self->create_table_municipalities();

  $self -> _sql_stmt("
  create table municipalities_ch (
     rel_id integer primary key,
     bfs_no integer not null
  )",
  "create table municipalities_ch");
  
  $self -> _sql_stmt("
    insert into municipalities_ch
    select
      mun.rel_id        rel_id,
      bfs.val           bfs_no
    from
      municipalities    mun  join
      tag               bfs  on mun.rel_id = bfs.rel_id
    where
      bfs.key = 'swisstopo:BFS_NUMMER'
  ", "fill table municipalities_ch");


  $self -> _sql_stmt("
    create view municipalities_ch_v as
    select
      rel_id,
      name,
      min_lat,
      min_lon,
      max_lat,
      max_lon,
      bfs_no
    from
      municipalities_ch join
      municipalities    using (rel_id)
  ",
  "create view municipalities_ch_v"
 );

 
#   my $sth = $self->{dbh}->prepare($stmt);
#   $sth->execute;
# 
#   my @ret;
#   while (my $r = $sth->fetchrow_hashref) {
#     push @ret, $r;
#   }
# 
#   return @ret;

} #_}
sub municipalities_ch { #_{
#_{ POD

=head2 municipalities_ch

    $osm_db_ch->create_table_municipalities_ch();
    …
    my %municipalities = $osm_db_ch->municipalities_ch();


=cut

#_}
  
  my $self = shift;
  
  my $stmt = "
    select
      rel_id,
      name,
      min_lat,
      max_lat,
      min_lon,
      max_lon,
      bfs_no
    from
      municipalities_ch_v
  ";


  my $sth = $self->{dbh}->prepare($stmt);
  $sth->execute;

  my %ret;
  while (my $r = $sth->fetchrow_hashref) {
    $ret{$r->{rel_id}} = {
      name    => $r->{name   },
      min_lat => $r->{min_lat},
      max_lat => $r->{max_lat},
      min_lon => $r->{min_lon},
      max_lon => $r->{max_lon},
      bfs_no  => $r->{bfs_no },
    };
  }

  return %ret;

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
