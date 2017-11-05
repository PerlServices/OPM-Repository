package OTRS::Repository;

# ABSTRACT: parse OTRS repositories' otrs.xml files to search for add ons

use strict;
use warnings;

use Moo;
use List::Util qw(all);
use Scalar::Util qw(blessed);
use Regexp::Common qw(URI);

use OTRS::Repository::Source;

our $VERSION = 0.07;

our $ALLOWED_SCHEME = [ 'HTTP', 'file' ];

has sources => ( is => 'ro', required => 1, isa => sub {
    die "no valid URIs" unless 
        ref $_[0] eq 'ARRAY' 
        and
        all { _check_uri( $_ ) } @{ $_[0] }
});

has _objects => ( is => 'ro', isa => sub {
    die "no valid objects" unless 
        ref $_[0] eq 'ARRAY' 
        and
        all { blessed $_ and $_->isa( 'OTRS::Repository::Source' ) } @{ $_[0] }
});

sub find {
    my ($self, %params) = @_;

    my @found;
    for my $source ( @{ $self->_objects || [] } ) {
        my $found = $source->find( %params );
        push @found, $found if $found;
    }

    return @found;
}

sub list {
    my ($self, %params) = @_;

    my %found_packages;
    for my $source ( @{ $self->_objects || [] } ) {
        my @found = $source->list( %params );
        @found_packages{@found} = (1) x @found;
    }

    return sort keys %found_packages;
}

sub BUILDARGS {
    my ($class, @args) = @_;

    unshift @args, 'sources' if @args % 2;

    my %param = @args;

    for my $url ( @{ $param{sources} || [] } ) {
        push @{ $param{_objects} }, OTRS::Repository::Source->new( url => $url );
    }

    return \%param;
}

sub _check_uri {
    my @allowed_schemes = ref $ALLOWED_SCHEME ? @{ $ALLOWED_SCHEME } : $ALLOWED_SCHEME;

    my $matches;

    SCHEME:
    for my $scheme ( @allowed_schemes ) {
        my $regex = ( lc $scheme eq 'http' ) ?
            $RE{URI}{HTTP}{-scheme => qr/https?/} :
            $RE{URI}{$scheme};

        if ( $_[0] =~ m{\A$regex\z} ) {
            $matches++;
            last SCHEME;
        }
    }

    die "No valid URI" unless $matches;
    return 1;
}

1;

=head1 SYNOPSIS

  use OTRS::Repository;
  
  my $repo = OTRS::Repository->new(
      sources => [qw!
          http://opar.perl-services.de/otrs.xml
          http://ftp.otrs.org/pub/otrs/packages/otrs.xml
          http://ftp.otrs.org/pub/otrs/itsm/packages33/otrs.xml
      !],
  );
  
  my ($url) = $repo->find(
    name => 'ITSMCore',
    otrs => '3.3',
  );
  
  print $url;

=head1 METHODS

=head2 new

C<new> has only one mandatory parameter: I<sources>. This has to be 
an array reference of URLs for repositories' otrs.xml files.

  my $repo = OTRS::Repository->new(
      sources => [qw!
          http://opar.perl-services.de/otrs.xml
          http://ftp.otrs.org/pub/otrs/packages/otrs.xml
          http://ftp.otrs.org/pub/otrs/itsm/packages33/otrs.xml
      !],
  );

=head2 find

Search for an add on for a given OTRS version in those repositories. It
returns a list of urls if the add on was found, C<undef> otherwise.

  my @urls = $repo->find(
    name => 'ITSMCore',
    otrs => '3.3',
  );

Find a specific version

  my @urls = $repo->find(
    name    => 'ITSMCore',
    otrs    => '3.3',
    version => '1.4.8',
  );

