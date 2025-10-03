# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
our (@filters, $test_points);
use Test::More tests => 1 + (@filters = qw[none hooks/iotrace strace]) * ($test_points = 24);
use File::Temp ();
use POSIX qw(WNOHANG);
use IO::Handle;
use IPC::Open3 qw(open3);

# Test target close STDIN (fd 0) behavior (Run 4 seconds)
my $test_prog = q{
    $|=1;                                    #LineA
    sub p{sleep 1}                           #LineB
    sub r{$_=<STDIN>//"(undef)";chomp;$_}    #LineC
    p;r;                                     #LineD
    p;print "OUT-ONE:$_\n";                  #LineE
    p;close STDIN;                           #LineF
    p;exit 0;                                #LineG
};

eval { require Time::HiRes; };
sub t { defined(\&Time::HiRes::time) ? sprintf("%10.6f",Time::HiRes::time()) : time() }

sub bits {
    my $fh = shift;
    alarm 5;
    vec (my $bits = "", fileno($fh), 1) = 1;
    $! = 0; # Reset errno
    return $bits;
}

sub canread {
    my $fh = shift;
    my $timeout = shift || 0.01;
    my $bits = bits($fh);
    return scalar select($bits, undef, undef, $timeout);
}

sub canwrite {
    my $fh = shift;
    my $timeout = shift || 0.01;
    my $bits = bits($fh);
    return scalar select(undef, $bits, undef, $timeout);
}

my $pid = 0;
$SIG{ALRM} = sub { require Carp; $pid and Carp::cluck("TIMEOUT ALARM TRIGGERED! Aborting execution PID=[$pid]") and kill TERM => $pid and sleep 1 and kill KILL => $pid; };
my $got_piped = 0;
$SIG{PIPE} = sub { $got_piped = 1; };
alarm 5;
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );
ok("$tmp", t." tracefile[$tmp]");

SKIP: for my $try (@filters) {
    my $prog = $try =~ /(\w+)$/ && $1;
    skip "no strace", $test_points if $prog eq "strace" and !-x "/usr/bin/strace"; # Skip strace tests if doesn't exist

    # run cases where STDIN is closed by the target first

    my @run = ($^X, "-e", $test_prog);
    # Ensure behavior of $test_prog is the same with or without tracing it.
    unshift @run, $try, -e => "execve,clone,openat,close,read,write", -o => "$tmp" if $prog ne "none";

    alarm 5;
    my $line;
    # open3 needs real handles, at least for STDERR
    my $in_fh  = IO::Handle->new;
    my $out_fh = IO::Handle->new;
    my $err_fh = IO::Handle->new;
    $got_piped = 0;
    $! = 0; # Reset errno
    $pid = open3($in_fh, $out_fh, $err_fh, @run) or die "open3: FAILED! $!\n";
    ok($pid, t." $prog: spawned [pid=$pid] $!");

    # If @run started properly, then its I/O should be writeable and readable
    alarm 5;
    # Test #LineD: p; (PAUSE for a second)
    ok(canwrite($in_fh),  t." $prog: TOP: STDIN is writeable: $!");
    ok(!canread($out_fh), t." $prog: TOP: STDOUT is empty so far: $!");
    ok(!canread($err_fh), t." $prog: TOP: STDERR is empty so far: $!");

    # Test #LineD: <STDIN>
    alarm 5;
    ok((print $in_fh "uno!\n"),t." $prog: line1");

    # Test #LineE: p (PAUSE for a second)
    # STDOUT should still be empty
    alarm 5;
    ok(!canread($out_fh), t." $prog: PRE: STDOUT is still empty: $!");

    # Test #LineE: ONE
    alarm 5;
    ok(canread($out_fh,2.8), t." $prog: PRE: STDOUT ready: $!");
    alarm 5;
    chomp($line = <$out_fh>);
    ok($line, t." $prog: back1: $line");

    # Test #LineF: p (PAUSE); close STDIN;
    # STDOUT should still be empty
    alarm 5;
    ok(!canread($out_fh), t." $prog: MID: STDOUT is still empty: $!");
    # Quickly jam something into its STDIN while it's still open
    ok((print $in_fh "uno!\n"),t." $prog: line1");
    ok(!$got_piped, t." $prog: STDIN Not PIPED: $got_piped");
    ok(!canread($in_fh),  t." $prog: STDIN still sleeping: $!");

    # STDIN should be closed within a second, which should wake up its file descriptor.
    alarm 5;
    ok(canread($in_fh, 1),  t." $prog: STDIN woke up: $!");
    ok(canwrite($in_fh),  t." $prog: MID: STDIN is writeable: $!");
    # Haven't touched the woke STDIN yet, so not PIPE triggered yet.
    ok(!$got_piped, t." $prog: STDIN Still Not PIPED: $got_piped");
    ok(!(print $in_fh "PIPE CRASH!\n"), t." $prog: line2: $!");
    ok($got_piped,  t." $prog: Got PIPED: $got_piped");
    $got_piped = 0;
    ok(canwrite($in_fh),  t." $prog: STDIN is not writeable: $!");
    ok(!close($in_fh),  t." $prog: explicit close STDIN should fail after broken write: $!");
    ok(close($out_fh),  t." $prog: close STDOUT fine: $!");
    ok(close($err_fh),  t." $prog: close STDERR fine: $!");

    # Test #LineG: p;
    # If STDIN is really closed, then prog should exit in under 1 seconds...
    alarm 5;
    my $died = waitpid(-1, WNOHANG);
    ok($died<=0, t." $prog: PID[$pid] still running: $died");
    # Give plenty of time to complete exit
    select undef,undef,undef, 1.2;

    # Test #LineG: exit 0
    alarm 5;
    $died = waitpid(-1, WNOHANG);
    is($died, $pid, t." $prog: PID[$pid] DONE[$died]");
    is($?, 0, t." $prog: normal exit: $?");
}
