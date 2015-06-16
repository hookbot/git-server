use 5.005;
use ExtUtils::MakeMaker;

WriteMakefile
    NAME          => 'git-server',
    VERSION_FROM  => 'git-server',
    PREREQ_PM     => {
        Cwd => 0,
    },
    AUTHOR        => 'Rob Brown <bbb@cpan.org>',
    ;
