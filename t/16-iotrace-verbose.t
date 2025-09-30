# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 16;
use File::Temp ();

my $run = "";
my $line = "";
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );

SKIP: for my $try (qw[hooks/iotrace strace]) {
    my $prog = $try =~ /(\w+)$/ ? $1 : $try;
    # Skip half the tests if no strace
    skip "no strace", 8 if $prog eq "strace" and !-x "/usr/bin/strace";

    # run -v case to test verbose functionality

    $run = `$try -s 9000 -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: Without verbose logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/execve.* \d+ vars /, "$prog: Without verbose execve has terse vars count: $line");
    unlike($line, qr/PATH/, "$prog: Without verbose hides ENV");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: Without verbose log cleared");

    $run = `$try -v -s 9000 -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: With verbose logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/execve.*PATH/, "$prog: With verbose execve shows ENV: $line");
    unlike($line, qr/ \d+ vars /, "$prog: Without verbose shows ENV instead of terse vars count");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: With verbose log cleared");
}
