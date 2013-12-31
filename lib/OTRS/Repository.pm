package OTRS::Repository;

use strict;
use warnings;

use Moo;
use List::Util qw(all);
use Scalar::Util qw(blessed);
use Regexp::Common qw(URI);

use OTRS::Repository::Source;

our $VERSION = 0.01;

our $ALLOWED_SCHEME = 'HTTP';

has sources => ( is => 'ro', required => 1, isa => sub {
    die "no valid URIs" unless 
        ref $_[0] eq 'ARRAY' 
        and
        all { $_ =~ m{\A$RE{URI}{$ALLOWED_SCHEME}\z} } @{ $_[0] }
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

sub BUILDARGS {
    my ($class, @args) = @_;

    unshift @args, 'sources' if @args % 2;

    my %param = @args;

    for my $url ( @{ $param{sources} || [] } ) {
        push @{ $param{_objects} }, OTRS::Repository::Source->new( url => $url );
    }

    return \%param;
}

1;
