use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WebService::FogBugz',
    AUTHOR              => 'Takatsugu Shigeta <takatsugu.shigeta@gmail.com>',
    VERSION_FROM        => 'lib/WebService/FogBugz.pm',
    ABSTRACT_FROM       => 'lib/WebService/FogBugz.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WebService-FogBugz-*' },
);
