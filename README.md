# NAME

Git::Server - Secure Git Server with more granular hooks capabilities than default git.

# DESCRIPTION

This is intented to be a drop-in replacement for any standard git server,
but provides more powerful server hooks and ACLs.

# SYNOPSIS

If you do not already have a git server or git repo ready, then make one:

    [admin@git-host ~]$ sudo useradd git
    [admin@git-host ~]$ sudo su - git -c 'git init --initial-branch=main --bare projectx'
    Initialized empty Git repository in /home/git/projectx/
    [admin@git-host ~]$

Put something like the following in its ~git/.ssh/authorized\_keys:

    command="git-server KEY=user1" ssh-ed25519 AAAA_OAX+blah_pub__ user1@dev

Then the first authorized user to touch the repo should have full access:

    [user1@dev ~]$ git config --global user.name 'Mr Developer User1'
    [user1@dev ~]$ git clone ssh://git@git-host/projectx
    [user1@dev ~]$ cd projectx
    [user1@dev projectx]$ echo 'Hello world' >> README
    [user1@dev projectx]$ git add README
    [user1@dev projectx]$ git commit -m 'First commit' README
    [user1@dev projectx]$ git push --set-upstream origin master
    [user1@dev projectx]$

See INSTALL.md to setup granular read and write access and/or
a simple push-notification instant deployment configuration.
