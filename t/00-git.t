# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use Test::More tests => 1;

# git is required
my $try = `git --help`;
ok (!$?, "git installed");
