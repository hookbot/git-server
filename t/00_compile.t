# Before 'make install' is performed this script should be runnable with
# 'make test'.

#########################

use strict;
use warnings;

use Test::More tests => 3;
my $try = `git --help`;
ok (!$?, "git installed");
use_ok("Git::Server");
$try = `$^X -c git-server 2>&1`;
chomp $try;
ok (($try =~ /syntax OK/i), "compile: $try");
