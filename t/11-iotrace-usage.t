# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More;
plan tests => 7;

# make sure iotrace runs for a simple cases
my $t1 = "hooks/iotrace";
my $try = `$t1 2>&1`;
$try =~ s/\n+/ /g;
ok (!!$?, "Args required: $try");

$try = `$t1 /BoGuS-CommAnd 2>&1`;
chomp $try;
ok (!!$?, "Spawn missing FULL: $try");

$try = `$t1 NoSuch-ComMand 2>&1`;
chomp $try;
ok (!!$?, "Spawn missing PATH: $try");

$try = `$t1 true 2>&1`;
ok (!$?, "$t1 runs true");
like($try, qr/exited with 0/, "true case");

$try = `$t1 false 2>&1`;
ok (!!$?, "$t1 runs false");
like($try, qr/exited with [1-9]/, "false case");
