#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use File::Spec;
use File::Spec::Unix;
use File::Basename;

use OTRS::Repository;

my $base_url = File::Spec->rel2abs(
  File::Spec->catdir( dirname( __FILE__ ), 'data' ),
);

if ( $^O =~ m{win32}i ) {
    $base_url =~ s{\\}{/}g;
}

my $xml_file = File::Spec::Unix->catfile( $base_url, 'otrs.xml' );

$base_url = 'file://' . $base_url;

my $source = OTRS::Repository->new(
    sources => [ 'file://' . $xml_file ],
);

my @check_list_21 = qw(Calendar FAQ FileManager Support TimeAccounting WebMail);
is_deeply [ $source->list( otrs => '2.1' ) ], \@check_list_21, "list of packages for OTRS 2.1";

my @check_list_all = qw(
    Calendar FAQ FileManager MasterSlave OTRSCodePolicy OTRSMasterSlave
    Support Survey SystemMonitoring TimeAccounting WebMail iPhoneHandle
);
is_deeply [ $source->list ], \@check_list_all, "list of all packages";

done_testing();
