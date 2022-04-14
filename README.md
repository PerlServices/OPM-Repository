[![Kwalitee status](https://cpants.cpanauthors.org/dist/OPM-Repository.png)](https://cpants.cpanauthors.org/dist/OPM-Repository)
[![GitHub issues](https://img.shields.io/github/issues/perlservices/OPM-Repository.svg)](https://github.com/perlservices/OPM-Repository/issues)
[![CPAN Cover Status](https://cpancoverbadge.perl-services.de/OPM-Repository-1.0.0)](https://cpancoverbadge.perl-services.de/OPM-Repository-1.0.0)
[![Cpan license](https://img.shields.io/cpan/l/OPM-Repository.svg)](https://metacpan.org/release/OPM-Repository)

# NAME

OPM::Repository - parse OPM repositories' framework.xml files to search for add ons

# VERSION

version 1.0.0

# SYNOPSIS

```perl
use OPM::Repository;

my $repo = OPM::Repository->new(
    sources => [qw!
        https://opar.perl-services.de/framework.xml
        https://download.znuny.org/releases/packages/framework.xml
        https://download.znuny.org/releases/itsm/packages6/framework.xml
    !],
);

my ($url) = $repo->find(
  name      => 'ITSMCore',
  framework => '3.3',
);

print $url;
```

## BUILDARGS

# ATTRIBUTES

- sources

# METHODS

## new

`new` has only one mandatory parameter: _sources_. This has to be 
an array reference of URLs for repositories' framework.xml files.

```perl
my $repo = OPM::Repository->new(
    sources => [qw!
        http://opar.perl-services.de/framework.xml
        http://ftp.framework.org/pub/framework/packages/framework.xml
        http://ftp.framework.org/pub/framework/itsm/packages33/framework.xml
    !],
);
```

## find

Search for an add on for a given OPM version in those repositories. It
returns a list of urls if the add on was found, `undef` otherwise.

```perl
my @urls = $repo->find(
  name      => 'ITSMCore',
  framework => '3.3',
);
```

Find a specific version

```perl
my @urls = $repo->find(
  name      => 'ITSMCore',
  framework => '3.3',
  version   => '1.4.8',
);
```

## list

List all addons found in the repositories

```perl
my @addons = $repo->list;
say $_ for @addons;
```

You can also define the OPM version

```perl
my @addons = $repo->list( framework => '5.0.x' );
say $_ for @addons;
```

Both snippets print a simple list of addon names. If you want to
to create a list with more information, you can use

```perl
my @addons = $repo->list(
    framework => '5.0.x',
    details   => 1,
);
say sprintf "%s (%s) on %s\n", $_->{name}, $_->{version}, $_->{url} for @addons;
```



# Development

The distribution is contained in a Git repository, so simply clone the
repository

```
$ git clone git://github.com/perlservices/OPM-Repository.git
```

and change into the newly-created directory.

```
$ cd OPM-Repository
```

The project uses [`Dist::Zilla`](https://metacpan.org/pod/Dist::Zilla) to
build the distribution, hence this will need to be installed before
continuing:

```
$ cpanm Dist::Zilla
```

To install the required prequisite packages, run the following set of
commands:

```
$ dzil authordeps --missing | cpanm
$ dzil listdeps --author --missing | cpanm
```

The distribution can be tested like so:

```
$ dzil test
```

To run the full set of tests (including author and release-process tests),
add the `--author` and `--release` options:

```
$ dzil test --author --release
```

# AUTHOR

Renee Baecker <reneeb@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Renee Baecker.

This is free software, licensed under:

```
The Artistic License 2.0 (GPL Compatible)
```
