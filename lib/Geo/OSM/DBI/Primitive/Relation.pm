# Encoding and name #_{

=encoding utf8
=head1 NAME

Geo::OSM::DBI::Primitive::Relation - Derivation of L<< Geo::OSM::Primitive::Relation >> to be used with L<< Geo::OSM::DBI >>.

=cut
package Geo::OSM::DBI::Primitive::Relation;
#_}
#_{ use …
use warnings;
use strict;

use utf8;
use Carp;

use Geo::OSM::Primitive::Relation;
our @ISA=qw(Geo::OSM::Primitive::Relation);

#_}
our $VERSION = 0.01;
#_{ Synopsis

=head1 SYNOPSIS

    …

=cut
#_}
#_{ Overview

=head1 OVERVIEW

…

=cut

#_}
#_{ Methods

=head1 METHODS
=cut

sub new { #_{
#_{ POD

=head2 new

    my $osm_dbi = Geo::OSM::DBI->new(…);

    new($osm_relation_id, $osm_dbi);

=cut

#_}

  my $class   = shift;
  my $id      = shift;
  my $osm_dbi = shift;

  my $self = $class->SUPER::new($id);

  croak "not a Geo::OSM::DBI::Primitive::Relation" unless $self -> isa('Geo::OSM::DBI::Primitive::Relation');
  croak "Need Geo::OSM::DBI" unless $osm_dbi->isa('Geo::OSM::DBI');

  $self->{osm_dbi} = $osm_dbi;

  return $self;

} #_}
sub name { #_{
#_{ POD

=head2 name

    my $name = $rel->name;

Returns the name of the object;

=cut

#_}

  my $self  = shift;

  my $sth = $self->{osm_dbi}->_sth_prepare_name('rel');
  $sth->execute($self->{id}) or die;

  my ($name) = $sth->fetchrow_array;

  return $name;

} #_}
#_}
#_{ POD: Copyright and license

=head1 COPYRIGHT and LICENSE

Copyright © 2017 René Nyffenegger, Switzerland. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at: L<http://www.perlfoundation.org/artistic_license_2_0>

=cut

#_}
#_{ POD: Source Code

=head1 SOURCE CODE

The source code is on L<< github|https://github.com/ReneNyffenegger/perl-Geo-OSM-DBI >>. Meaningful pull requests are welcome.

=cut

#_}
