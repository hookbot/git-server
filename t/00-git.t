# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;

use Test::More;
plan tests => 1;
my $try = `git --help`;
ok (!$?, "git installed");
