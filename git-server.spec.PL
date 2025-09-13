#!perl

# Copyright (C) 2025 Rob Brown (bbb@cpan.org)
# SPEC file generator.

use strict;

my @cmd = (
    "cpan2rpm",
    (eval "require File::Temp; 1;" ? () : ("--tempdir","/tmp/git-server-build") ),
    "--force",
    "--requires", "strace",
    "--no-fixin",
    "--spec-only",
    "--spec", "./git-server.spec",
    "."
    );

exec(@cmd);
warn "cpan2rpm: Broken [@cmd]\n";
exec "touch", "git-server.spec";
