# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 18;
use File::Temp ();

my $run = "";
my $line = "";
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );

SKIP: for my $try (qw[hooks/iotrace strace]) {
    my $prog = $try =~ /(\w+)$/ ? $1 : $try;
    # Skip half the tests if no strace
    skip "no strace", 9 if $prog eq "strace" and !-x "/usr/bin/strace";

    # run -f and -ff cases to test fake fork options

    $run = `$try -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: Default fork logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/^execve/, "$prog: Default no fork without pid: $line");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: Default fork log cleared");

    $run = `$try -f -o $tmp $^X -e '' 2>&1`;
    ok(!!-s $tmp, "$prog: $tmp: Baby fork logged ".(-s $tmp)." bytes");
    $tmp->seek(0, 0); # SEEK_SET beginning
    chomp($line = <$tmp>);
    like($line, qr/^\d+ execve/, "$prog: Baby fork: $line");
    $tmp->seek(0, 0);
    $tmp->truncate(0);
    ok(!-s $tmp, "$prog: Baby fork log cleared");

    $run = `$try -ff -o $tmp $^X -e '' 2>&1`;
    my ($super_fork_log) = glob "$tmp.*";
    ok(-s $super_fork_log, "$prog: $super_fork_log: Super fork logged ".(-s $super_fork_log)." bytes");
    open my $super_fh, "<", $super_fork_log;
    chomp($line = <$super_fh>);
    like($line, qr/^execve/, "$prog: Super fork: $line");
    ok(unlink($super_fork_log), "$prog: Super fork log cleared: $super_fork_log");
}
