# git-server

# DESCRIPTION

Secure Git Server with more granular hooks capabilities than default git.

This is intented to be a light-weight drop-in replacement for any
standard git server, but provides more powerful server hooks.

# USAGE

Put something like the following in ~git/.ssh/authorized_keys:

```
command="git-server KEY=USER1" ssh-rsa AAAA___blah_pub__ user1@workstation
```

If you don't already have a git server or git repo ready, then make one:

```
sudo useradd git
sudo su - git
git init --bare projectx
```

Then add whatever hooks you want:

```
vi projectx/.git/hooks/pre-read
```

Each hook can read the ENV settings defined in authorized_keys.

See contrib/* or hooks/* for some working "hooks" examples.
