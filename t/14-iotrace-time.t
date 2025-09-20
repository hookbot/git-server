# Before 'make install' is performed this script should be runnable with
# 'make test'

#########################

use strict;
use warnings;
use File::Temp ();
use Test::More;
plan tests => 9;

my $try = "";
my $line = "";
my $tmp = File::Temp->new( UNLINK => 1, SUFFIX => '.trace' );
my $t1 = "hooks/iotrace";

$try = `$t1 -o $tmp $^X -e '' 2>&1`;
ok(!!-s $tmp, "$tmp: Default time logged ".(-s $tmp)." bytes");
$tmp->seek(0, 0); # SEEK_SET beginning
chomp($line = <$tmp>);
like($line, qr/^[^\d]/, "Default no timestamp: $line");
$tmp->seek(0, 0);
$tmp->truncate(0);
ok(!-s $tmp, "Default time log cleared");

$try = `$t1 -t -o $tmp $^X -e '' 2>&1`;
ok(!!-s $tmp, "$tmp: Baby time logged ".(-s $tmp)." bytes");
$tmp->seek(0, 0); # SEEK_SET beginning
chomp($line = <$tmp>);
like($line, qr/^\d\d:\d\d:\d\d /, "Baby timestamp: $line");
$tmp->seek(0, 0);
$tmp->truncate(0);
ok(!-s $tmp, "Baby time log cleared");

$try = `$t1 -tt -o $tmp $^X -e '' 2>&1`;
ok(!!-s $tmp, "$tmp: HiRes time logged ".(-s $tmp)." bytes");
$tmp->seek(0, 0); # SEEK_SET beginning
chomp($line = <$tmp>);
like($line, qr/^\d\d:\d\d:\d\d\.\d\d\d\d\d\d /, "HiRes timestamp: $line");
$tmp->seek(0, 0);
$tmp->truncate(0);
ok(!-s $tmp, "HiRes time log cleared");
