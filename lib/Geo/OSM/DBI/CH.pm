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
sub gemeinden { #_{
#_{ POD

=head2 municipalities

    my @gemeinden = $osm_db_ch->gemeinden();


Return a list of municipalites (admin level = 8).

=cut

#_}
  
  my $self = shift;
  
  my $stmt = "
select
  gemeinde.rel_id  rel_id,
  name.val         name,
  bfs_nummer.val   bfs_no
from
  tag gemeinde                                          join
--tag boundary   on gemeinde.rel_id = boundary  .rel_id join
  tag name       on gemeinde.rel_id = name      .rel_id join
  tag bfs_nummer on gemeinde.rel_id = bfs_nummer.rel_id  
where
  gemeinde  .key = 'admin_level' and
  gemeinde  .val =  8            and
  name      .key = 'name'        and
  bfs_nummer.key = 'swisstopo:BFS_NUMMER'
order by
  name.val";


  my $sth = $self->{dbh}->prepare($stmt);
  $sth->execute;

  my @ret;
  while (my $r = $sth->fetchrow_hashref) {
    push @ret, $r;
  }

  return @ret;

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

