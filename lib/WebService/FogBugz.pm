package WebService::FogBugz;

use warnings;
use strict;

use LWP::UserAgent;
use XML::Liberal;
use XML::LibXML;

our $VERSION = '0.1.0';

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
    my $res = $self->{ua}->get(
        $self->{base_url}
        . '?cmd=logon'
        . '&email=' . $self->{email}
        . '&password=' . $self->{password});

    return  if ($self->_is_error($res->content));
    
    my $doc = $self->{parser}->parse_string($res->content);
    $self->{token} = $doc->findvalue("//*[local-name()='response']/*[local-name()='token']/text()");
    return $self->{token};
}

sub logoff {
    my $self = shift;
    my $res = $self->{ua}->get(
        $self->{base_url}
        . '?cmd=logoff'
        . '&token=' . $self->{token});

    return  if ($self->_is_error($res->content));

    delete $self->{token};
    return;
}

sub request_method {
    my $self = shift;
    my ($cmd, $param) = @_;
    my $query = join('', map {'&' . $_ . '=' . $param->{$_}} keys(%$param));
    my $res = $self->{ua}->get(
        $self->{base_url}
        . '?cmd=' . $cmd
        . '&token=' . $self->{token}
        . $query);

    return  if ($self->_is_error($res->content));

    return $res->content;
}

sub _is_error {
    my $self = shift;
    my ($content)  = @_;
    $content =~ s/<\?xml\s+.*?\?>//g;
    my $doc  = $self->{parser}->parse_string($content);
    $self->{error}{code} = $doc->findvalue("//*[local-name()='response']/*[local-name()='error']/\@code");
    $self->{error}{msg}  = $doc->findvalue("//*[local-name()='response']/*[local-name()='error']/text()");
    return $self->{error}{code} ? '1' : '0';
}

1;

__END__

=head1 NAME

WebService::FogBugz - FogBugz API for Perl

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

This module provides a Perl interface for the FogBugz API. FogBugz is a 
project management system.

=head1 METHODS

=head2 new([%options])

This method returns an instance of this module. 

The arguments hash must provide the following parameters:

=over

=item * email

Your login email address used for logging in to FogBugz.

=item * password

=item * base_url

Your FogBugz API's URL. This may be a hosted instance 
(e.g. https://example.fogbugz.com/api.asp?) or a local installation
(e.g. http://www.example.com/fogbugz/api.asp).

If you're unsure about your base_url, check the url field of an XML request.
For example, if using a local installation, such as 
http://www.example.com/fogbugz, check the URL as 
http://www.example.com/fogbugz/api.xml. If you have a FogBugz On Demand account
the link will be https://example.fogbugz.com/api.xml, where example is your 
account name.

=back

=head2 logon

Retrieves an API token from Fogbugz.

=head2 logoff

Log off from FogBugz.

=head2 request_method($command,$hash)

The 1st argument is name of command, the 2nd argument is the hash of parameters
for the specified command.

FogBugz supports many commands. You will find from FogBugz Online Documantation
by using keyword of 'cmd'.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-webservice-fogbugz@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::FogBugz

You can also look for information at:

=over 4

=item * FogBugz Online Documentation

L<http://help.fogcreek.com/fogbugz>

=item * FogBugz Online Documentation - API

L<http://help.fogcreek.com/8202/xml-api>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-FogBugz>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-FogBugz>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-FogBugz>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-FogBugz>

=back

=head1 AUTHORS

Original Author: Takatsugu Shigeta  C<< <shigeta@cpan.org> >>

Current Maintainer: Barbie  C<< <barbie@cpan.org> >>

=head1 LICENCE AND COPYRIGHT

  Copyright (c) 2007-2014, Takatsugu Shigeta C<< <shigeta@cpan.org> >>.
  Copyright (c) 2014-2015, Barbie for Miss Barbell Productions. 
  All rights reserved.

This distribution is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
