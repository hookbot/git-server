#!/usr/bin/perl

=pod

=head1 NAME

webhookcallback.cgi - CGI Script WebHook endpoint to catch push notifications.

=head1 SYNOPSIS

  [root@deploy-host ~]# wget -N -P /var/www/html https://raw.githubusercontent.com/hookbot/git-server/master/hooks/webhookcallback.cgi
  [root@deploy-host ~]# wget -N -P /usr/bin https://raw.githubusercontent.com/hookbot/git-server/master/git-deploy
  [root@deploy-host ~]# chmod 755 /var/www/html/webhookcallback.cgi /usr/bin/git-deploy
  [root@deploy-host ~]# crontab -l -u apache | grep deploy || \
    echo '6 */4 * * * git deploy -C /var/lib/projectz -i ~/.ssh/id_rsa_readonlydeploykey --max-delay 14400 --background </dev/null >/dev/null 2>/dev/null' | crontab -u apache -
  [root@deploy-host ~]# [ -e /etc/httpd/conf.d/webhook.conf ] || echo 'ScriptAlias /webhookcallback.cgi /var/www/html/webhookcallback.cgi' >> /etc/httpd/conf.d/webhook.conf
  [root@deploy-host ~]#   # -or- #
  [root@deploy-host ~]# grep -i -E '(AddHandler|ExecCGI)' /var/www/html/.htaccess || echo -e 'AddHandler cgi-script .cgi\nOptions +ExecCGI' >> /var/www/html/.htaccess
  [root@deploy-host ~]#

=head1 INSTALL

Configure your web server to run this script via some URL. i.e.:

  https://deploy-host.com/webhookcallback.cgi

Then test it once to make sure it runs:

  [root@deploy-host ~]# curl https://deploy-host.com/webhookcallback.cgi
  OK
  [root@deploy-host ~]#

Then configure a webhook on your git host to hit this URL
for any "push" event.  Make sure webhookcallback.cgi runs as
the same user git-deploy runs as, otherwise it might not be
able to signal the waiter. i.e., apache or www-data

=head1 DESCRIPTION

Do you have an annoying cron like this?

  0 * * * * (cd /var/lib/projectz && git pull && make) </dev/null >/dev/null 2>/dev/null

This is bad because you have to wait for the boat to swim by
before your changes will get deployed. You could increase the
frequency or put it in a tight while loop to reduce the delay,
but then you pummel the machine running "git pull" all day,
only to get "Already up to date" 99.99% of the time.
And I'm sure the git host will want to IP BLOCK you or delete
all your repos after seeing the first thousand "pull" slapped
within a minute.
You could slow the frequency of this "heartbeat" slapper to
avoid wasting as much CPU, but then you'd have to wait even
LONGER for your push to be deployed.

So that's where this comes in handy!

This is just a wrapper around "git deploy --notify", which sends a
push notification to the git-deploy process waiting for a change.
If the client has "acl.deploy" rights, then this CGI wrapper is not
needed, since the git server will release the git pull right away.
But if you wish to use "acl.readers" instead, (or if you're using a
git host that doesn't support "acl.deploy"), then you can use this.

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
