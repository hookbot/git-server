# git-server

# DESCRIPTION

Secure Git Server with more granular hooks capabilities than default git.

This is intented to be a light-weight drop-in replacement for any
standard git server, but provides more powerful server hooks.

# USAGE

If you don't already have a git server or git repo ready, then make one:

```
  sudo useradd git
  sudo su - git
  git init project
```

Then put something like the following in ~git/.ssh/authorized_keys:
command="git-server KEY=USER1" ssh-rsa AAAA___blah_pub__ user1@workstation

Then add whatever hooks you want:

```
  vi project/.git/hooks/pre-read
```

Each hook can read the ENV settings defined in authorized_keys.

See contrib/* for some working "hooks" examples.
