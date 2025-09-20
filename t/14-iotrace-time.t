# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 18;
use File::Temp ();

my $try = "";
my $line = "";
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );

SKIP: for my $prog (qw[hooks/iotrace strace]) {
    # Skip half the tests if no strace
    skip "no strace", 9 if $prog eq "strace" and !-x "/usr/bin/strace";

    # run -t and -tt cases to test timestamps formats

    $try = `$prog -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: Default time logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/^[^\d]/, "$prog: Default no timestamp: $line");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: Default time log cleared");

    $try = `$prog -t -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: Baby time logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/^\d\d:\d\d:\d\d /, "$prog: Baby timestamp: $line");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: Baby time log cleared");

    $try = `$prog -tt -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: HiRes time logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/^\d\d:\d\d:\d\d\.\d\d\d\d\d\d /, "$prog: HiRes timestamp: $line");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: HiRes time log cleared");
}
