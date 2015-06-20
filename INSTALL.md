# git-server

INSTALL
=======

Put something like the following in ~git/.ssh/authorized_keys:

```
command="git-server KEY=USER1" ssh-rsa AAAA___blah_pub__ user1@workstation
```

This can be used with any existing git repositories
or you can create a fresh git repo:

```
sudo useradd git
sudo su - git
git init projectx
```

Then add whatever hooks you want:

```
vi projectx/.git/hooks/pre-read
```

Each hook can read the ENV settings defined in authorized_keys.

See contrib/* for some working "hooks" examples.