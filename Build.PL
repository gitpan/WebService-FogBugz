use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WebService::FogBugz',
    license             => 'perl',
    dist_author         => 'Takatsugu Shigeta <takatsugu.shigeta@gmail.com>',
    dist_version_from   => 'lib/WebService/FogBugz.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
        'Test::Perl::Critic' => 0,
        'Test::Pod::Coverage' => 1.04,
        'Test::Pod' => 1.14,
        'LWP::UserAgent' => 0,
        'XML::Liberal' => 0.16,
        'XML::LibXML'  => 1.60,
    },
    add_to_cleanup      => [ 'WebService-FogBugz-*' ],
);

$builder->create_build_script();
