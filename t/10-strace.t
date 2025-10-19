# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 5;

# make sure strace is available
use_ok('File::Which');
SKIP: {
    my $tracer = which("strace") or skip "strace can work on Linux but not found here [$^O]", 4;
    ok($tracer, "strace found: $tracer");
    my $try = `strace --help 2>&1`;
    ok (!$?, "strace installed");
    ok (!$!, "strace no Errno: $!");
    $try =~ s/\s+/ /g;
    ok ($try, "strace runs: $try");
}
