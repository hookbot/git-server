# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 4;

# make sure iostrace is available
use_ok('File::Which');
my $tracer = which("iotrace");
ok($tracer, "iotrace found: $tracer");
my $try = `iotrace --help 2>&1`;
ok (!$!, "iotrace no Errno: $!");
$try =~ s/\s+/ /g;
ok ($try, "iotrace runs: $try");
