package WebService::FogBugz;

use warnings;
use strict;

use LWP::UserAgent;
use XML::Liberal;
use XML::LibXML;

our $VERSION = '0.0.4';

sub new {
    my $class = shift;
    my ($param) = @_;
    die 'you need to input email, password and base url.'
        unless $param->{email} and $param->{password} and $param->{base_url};
    my $self = bless {%$param}, $class;
    $self->{ua} = $param->{ua} || LWP::UserAgent->new;
    $self->{ua}->agent(__PACKAGE__.'/'.$VERSION);
    $self->{parser} = XML::Liberal->new('LibXML');
    return $self;
}

sub logon {
    my $self = shift;
    my $res = $self->{ua}->get($self->{base_url}
                               . '?cmd=logon'
                               . '&email=' . $self->{email}
                               . '&password=' . $self->{password});
    if ($self->_is_error($res->content)) {
        return;
    }
    my $doc = $self->{parser}->parse_string($res->content);
    $self->{token} = $doc->findvalue("//*[local-name()='response']/*[local-name()='token']/text()");
    return $self->{token};
}

sub logoff {
    my $self = shift;
    my $res = $self->{ua}->get($self->{base_url}
                               . '?cmd=logoff'
                               . '&token=' . $self->{token});
    if ($self->_is_error($res->content)) {
        return;
    }
    delete $self->{token};
    return;
}

sub request_method {
    my $self = shift;
    my ($cmd, $param) = @_;
    my $query = join('', map {'&' . $_ . '=' . $param->{$_}} keys(%$param));
    my $res = $self->{ua}->get($self->{base_url}
                               . '?cmd=' . $cmd
                               . '&token=' . $self->{token}
                               . $query);
    if ($self->_is_error($res->content)) {
        return;
    }
    return $res->content;
}

sub _is_error {
    my $self = shift;
    my ($content)  = @_;
    $content =~ s/<\?xml\s+.*?\?>//g;
    my $doc  = $self->{parser}->parse_string($content);
    $self->{error}{code}
        = $doc->findvalue("//*[local-name()='response']/*[local-name()='error']/\@code");
    $self->{error}{msg}
        = $doc->findvalue("//*[local-name()='response']/*[local-name()='error']/text()");
    return $self->{error}{code} ? '1' : '0';
}

1;

__END__

=head1 NAME

WebService::FogBugz - Perl interface to the FogBugz API

=head1 SYNOPSIS

    use WebService::FogBugz;

    my $fogbugz = WebService::FogBugz->new({
        email    => 'yourmail@example.com',
        password => 'yourpassword',
        base_url => 'http://yourfogbugz.example.com/api.asp',
    });

    $fogbugz->logon;

    # your request.
    my $xml = $fogbugz->request_method('search', {
        q => 'WebService',
    });

    $fogbugz->logoff;

=head1 DESCRIPTION

This module provides you Perl interface for FogBugz API.
FogBugz is a project management system.

=head1 METHODS

=head2 new([%options])
this method returns an instance of this module.
and this method allows following arguments;
- email (almost your email address for log in to FogBugz)
- password
- base_url (your fogbugz api's URL.Probably http://www.example.com/fogbugz/api.asp. For example, if the URL is http://www.example.com/fogbugz, hit http://www.example.com/fogbugz/api.xml.And see the url field of response xml.)

=head2 logon
Retrieves an API token from Fogbugz.

=head2 logoff
Log off from FogBugz.

=head2 request_method
the 1st argument is name of command.
FogBugz 6.0 supports many commands. You will find from FogBugz Online Documantation by using keyword of 'cmd'.

the 2nd argument is parameters of command of 1st argument.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-webservice-fogbugz@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::FogBugz

You can also look for information at:

=over 4

=item * FogBugz Online Documentation - API 

L<http://www.fogcreek.com/FogBugz/docs/60/topics/advanced/API.html>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-FogBugz>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-FogBugz>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-FogBugz>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-FogBugz>

=back

=head1 SEE ALSO

L<http://www.fogcreek.com/FogBugz/docs/60/topics/advanced/API.html>

=head1 AUTHOR

Takatsugu Shigeta  C<< <takatsugu.shigeta@gmail.com> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Takatsugu Shigeta C<< <takatsugu.shigeta@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
