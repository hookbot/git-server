use 5.005;
use ExtUtils::MakeMaker;

WriteMakefile
    NAME          => 'git-server',
    AUTHOR        => 'Rob Brown <bbb@cpan.org>',
    VERSION_FROM  => 'git-server',
    PREREQ_PM     => {
        Cwd => 0,
    },
    dist => {
        COMPRESS => "gzip -9 -vf",
    },
    EXE_FILES => [qw(
        git-server
    )],
    ;
