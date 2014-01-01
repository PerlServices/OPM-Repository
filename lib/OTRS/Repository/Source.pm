package OTRS::Repository::Source;

# ABSTRACT: Parser for a single otrs.xml file

use strict;
use warnings;

use Moo;
use HTTP::Tiny;
use XML::LibXML;
use Regexp::Common qw(URI);

our $VERSION = 0.01;

our $ALLOWED_SCHEME = 'HTTP';

has url     => ( is => 'ro', required => 1, isa     => sub { die "No valid URI" unless $_[0] =~ m{\A$RE{URI}{$ALLOWED_SCHEME}\z} } );
has content => ( is => 'ro', lazy     => 1, builder => sub { HTTP::Tiny->new->get( shift->url )->{content} });
has tree    => ( is => 'ro', lazy     => 1, builder => sub {
    my $parser = XML::LibXML->new->parse_string( shift->content );
    $parser->getDocumentElement;
});

has packages => ( is => 'rwp', default => sub { {} }, isa => sub { die "No hashref" unless ref $_[0] eq 'HASH' } );
has parsed   => ( is => 'rwp', predicate => 1 );

sub find {
    my ($self, %params) = @_;

    return if !exists $params{name};
    return if !exists $params{otrs};

    my $package = $params{name};
    my $otrs    = $params{otrs};

    my %packages = %{ $self->packages };
    if ( $self->has_parsed ) {
        return $packages{$package}->{$otrs}->{file};
    }

    return if !$self->tree;

    my @repo_packages = $self->tree->findnodes( 'Package' );
    my $base_url      = $self->url;
    $base_url         =~ s{\w+\.xml\z}{};

    REPO_PACKAGE:
    for my $repo_package ( @repo_packages ) {
        my $name       = $repo_package->findvalue( 'Name' );
        my @frameworks = $repo_package->findnodes( 'Framework' );
        my $file       = $repo_package->findvalue( 'File' );

        my $version    = $repo_package->findvalue( 'Version' );

        FRAMEWORK:
        for my $framework ( @frameworks ) {
            my $otrs_version  = $framework->textContent;
            my $short_version = join '.', (split /\./, $otrs_version, 3)[0..1];
            my $saved_version = $packages{$name}->{$short_version}->{version};

            if ( !$saved_version || $self->_version_is_newer( $version, $saved_version ) ) {
                $packages{$name}->{$short_version} = {
                    version => $version,
                    file    => sprintf "%s%s", $base_url, $file,
                };
            }
        }
    }

    $self->_set_parsed( 1 );
    $self->_set_packages( \%packages );

    return $packages{$package}->{$otrs}->{file};
}

sub _version_is_newer {
    my ($self, $new, $old) = @_;

    my @new_levels = split /\./, $new;
    my @old_levels = split /\./, $old;

    for my $i ( 0 .. ( $#new_levels > $#old_levels ? @new_levels : @old_levels ) ) {
        if ( !$old_levels[$i] || $new_levels[$i] > $old_levels[$i] ) {
            return 1;
        }
        elsif ( $new_levels[$i] < $old_levels[$i] ) {
            return 0;
        }
    }

    return 1;
}

1;
