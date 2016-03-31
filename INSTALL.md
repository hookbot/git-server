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

See contrib/* for some working "hooks" examples, such as logging.

See hooks/INSTALL_ACL.md for how to setup repo read/write/deploy ACLs.

To use the "git-client" convenience wrapper for .gitconfig overrides:

```
wget https://raw.githubusercontent.com/hookbot/git-server/master/git-client
chmod 755 git-client
mv -i git-client /usr/local/bin/git
```

To enable the "git deploy" capabilities on the client host:

```
wget https://raw.githubusercontent.com/hookbot/git-server/master/git-deploy
chmod 755 git-deploy
mv -i git-deploy /usr/local/bin/.
```
