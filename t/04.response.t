use Test::More;
use WebService::FogBugz;

my $email    = '';
my $password = '';
my $base_url = '';

unless ($email and $password and $base_url) {
    Test::More->import(skip_all => "requires email, password and base_url, skipped.");
    exit;
}

plan tests => 1;

my $fogbugz = WebService::FogBugz->new({
    email    => $email,
    password => $password,
    base_url => $base_url,
});
my $token = $fogbugz->logon;
my $res =  $fogbugz->request_method('search', {
    q => 'WebService',
});
chomp $res;
ok $res, "got response.";
$fogbugz->logoff;
