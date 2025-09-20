# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 26;
use File::Temp ();

my $try = "";
my $line = "";
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );

SKIP: for my $prog (qw[hooks/iotrace strace]) {
    # Skip half the tests if no strace
    skip "no strace", 13 if $prog eq "strace" and !-x "/usr/bin/strace";

    # run simple cases and test option: -o <output_log>

    ($try = `$prog 2>&1`) =~ s/\n+/ /g;
    ok (!!$?, "$prog: Args required: $try");

    $try = `$prog /BoGuS-CommAnd 2>&1`;
    chomp $try;
    ok (!!$?, "$prog: Spawn missing FULL: $try");

    $try = `$prog NoSuch-ComMand 2>&1`;
    chomp $try;
    ok (!!$?, "$prog: Spawn missing PATH: $try");

    $try = `$prog true 2>&1`;
    ok (!$?, "$prog: Runs true");
    like($try, qr/exited with 0/, "$prog: true case to stderr");

    $try = `$prog false 2>&1`;
    ok (!!$?, "$prog: Runs false");
    like($try, qr/exited with [1-9]/, "$prog: false case to stderr");

    # test option: -o <file>
    $try = `$prog -o $tmp true 2>&1`;
    ok (!$?, "$prog: Runs true with -o");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp ($line = join "", <$tmp>);
    like($line, qr/exited with 0/, "$prog: true case with -o");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: true case using -o log cleared");

    $try = `$prog -o $tmp false 2>&1`;
    ok (!!$?, "$prog: Runs false with -o");
    chomp ($line = join "", <$tmp>);
    like($line, qr/exited with [1-9]/, "$prog: false case with -o");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: false case using -o log cleared");
}
