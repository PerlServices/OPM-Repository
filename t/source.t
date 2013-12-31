#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use File::Spec;
use File::Basename;

use OTRS::Repository::Source;

my $xml_file = File::Spec->catfile( dirname( __FILE__ ), 'data', 'otrs.xml' );
my $xml      = do { local (@ARGV, $/) = $xml_file; <> };
my $base_url = 'http://ftp.otrs.org/pub/otrs/packages/';

my $source = OTRS::Repository::Source->new(
    url     => $base_url . 'otrs.xml',
    content => $xml,
);

my $master_slave = $source->find( name => 'OTRSMasterSlave', otrs => '3.3' );
is $master_slave, $base_url . 'OTRSMasterSlave-1.4.2.opm', 'MasterSlave for OTRS 3.3';

is $source->find( name => 'MultiSMTP', otrs => '3.0' ), undef, 'MultiSMTP not in Repository';
is $source->find( name => 'OTRSMasterSlave', otrs => '1.2' ), undef, 'OTRSMasterSlave not found for OTRS 1.2';

done_testing();
