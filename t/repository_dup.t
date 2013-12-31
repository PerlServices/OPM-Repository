#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use File::Spec;
use File::Basename;

use OTRS::Repository;

$OTRS::Repository::ALLOWED_SCHEME = 'file';
$OTRS::Repository::Source::ALLOWED_SCHEME = 'file';

{
    no warnings 'redefine';
    sub HTTP::Tiny::get {
        my ($obj, $url) = @_;

        $url =~ s{file://}{};
        my $content = do { local (@ARGV, $/) = $url; <> };
        return { content => $content };
    }
}

my $base_url = File::Spec->rel2abs(
  File::Spec->catdir( dirname( __FILE__ ), 'data' ),
);

my $xml_file = File::Spec->catfile( $base_url, 'otrs.xml' );

$base_url = 'file://' . $base_url;

my $source = OTRS::Repository->new(
    sources => [
        'file://' . $xml_file,
        'file://' . $xml_file,
    ],
);

my @master_slave = $source->find( name => 'OTRSMasterSlave', otrs => '3.3' );
is $master_slave[0], $base_url . '/OTRSMasterSlave-1.4.2.opm', 'MasterSlave for OTRS 3.3';
is scalar( @master_slave ), 2, 'Count MasterSlave for OTRS 3.3';

is_deeply [ $source->find( name => 'MultiSMTP', otrs => '3.0' ) ], [], 'MultiSMTP not in Repository';
is_deeply [ $source->find( name => 'OTRSMasterSlave', otrs => '1.2' ) ], [], 'OTRSMasterSlave not found for OTRS 1.2';

done_testing();
