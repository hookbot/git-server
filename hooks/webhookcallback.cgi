#!/usr/bin/perl

=pod

=head1 NAME

webhookcallback.cgi - CGI Script WebHook endpoint to catch push notifications.

=head1 DESCRIPTION

Sends push notification to the git-deploy waiting for a change.

=head1 SYNOPSIS

  [root@deploy-host ~]# wget -N -P /var/www/html https://raw.githubusercontent.com/hookbot/git-server/master/hooks/webhookcallback.cgi
  [root@deploy-host ~]# chmod 755 /var/www/html/webhookcallback.cgi
  [root@deploy-host ~]# echo 'AddHandler cgi-script .cgi' >> /var/www/html/.htaccess
  [root@deploy-host ~]# echo 'Options +ExecCGI' >> /var/www/html/.htaccess
  [root@deploy-host ~]#

=head1 INSTALL

Setup the git server to hit this webhook script:

  https://deploy-host/webhookcallback.cgi

Make sure webhookcallback.cgi runs as the same user as git-deploy is running as,
otherwise webhookcallback.cgi might not be able to signal the waiter.
i.e., apache or www-data

=head1 AUTHOR

Rob Brown <bbb@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015-2026 by Rob Brown <bbb@cpan.org>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

use strict;
use warnings;

if ($ENV{GATEWAY_INTERFACE}) {
    my $pushed_repo = "";
    my $pushed_refs = [];
    if ($ENV{CONTENT_LENGTH} and read(STDIN, my $content, $ENV{CONTENT_LENGTH})) {
        my $json = {};
        if ($content =~ /\bpush/i and $content =~ /^\s*\{/ and $json = eval { require JSON; JSON->new->decode($content) } and "HASH" eq ref $json) {
            if (my $repo = $json->{repo} || $json->{repository}) {
                $repo = $repo->{name} if "HASH" eq ref $repo;
                $pushed_repo = $repo if $repo and !ref $repo;
            }
            if (my $refs = $json->{refs} || $json->{ref}) {
                $refs = [ $refs ] if !ref $refs;
                push @$pushed_refs, @$refs if "ARRAY" eq ref $refs;
            }
        }
    }
    print "\nOK\n";
    exec "git","deploy","--notify",$pushed_repo,@$pushed_refs or die "exec: $!\n";
}

chomp (my $hostname = `hostname`);
my $Script = $0 =~ m{.*/(.+)$} ? $1 : $0;
die "$Script: Run CGI through web server, i.e., https://$hostname/$Script\n";
