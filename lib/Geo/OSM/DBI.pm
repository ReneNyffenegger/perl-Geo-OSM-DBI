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
