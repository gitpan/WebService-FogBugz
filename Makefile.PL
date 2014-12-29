#!/usr/bin/perl

use strict;
use warnings;
use 5.006;

use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Barbie <barbie@cpan.org>',
    NAME                => 'WebService::FogBugz',
    VERSION_FROM        => 'lib/WebService/FogBugz.pm',
    ABSTRACT            => 'FogBugz API for Perl',
    NO_META             => 1,
    PREREQ_PM           => {

        # prereqs
        'XML::Liberal'          => '0.16',
        'XML::LibXML'           => '1.60',

        # build/test prereqs
        'IO::File'              => '0',
        'Test::More'            => '0.70'

    }
);
