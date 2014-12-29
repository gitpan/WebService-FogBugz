#!/usr/bin/perl -w
use strict;

use Test::More;
use WebService::FogBugz;

my $email    = '';
my $password = '';
my $base_url = '';

unless ($email and $password and $base_url) {
    Test::More->import(skip_all => "requires email, password and base_url, skipped.");
    exit;
}

plan tests => 3;

my $fogbugz;
eval {
    $fogbugz = WebService::FogBugz->new;
};
ok $@, 'logon error';

$fogbugz = WebService::FogBugz->new({
    email    => $email,
    password => $password,
    base_url => $base_url,
});
is ref($fogbugz), 'WebService::FogBugz', 'reference';
is $fogbugz->{ua}->agent, 'WebService::FogBugz/' . $WebService::FogBugz::VERSION, 'check agent';
