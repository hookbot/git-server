# git-server

INSTALL
=======

Server Side:
------------

1. Create an unprivileged user for the git server to run as:

```
[admin@gitsrvhost ~]$ sudo useradd git
[admin@gitsrvhost ~]$ sudo su - git
[git@gitsrvhost ~]$
```

2. Download git-server for this user:

```
[git@gitsrvhost ~]$ git clone https://github.com/hookbot/git-server
[git@gitsrvhost ~]$ cd git-server/.git
[git@gitsrvhost .git]$ mv -v hooks hooks-SAMPLES
renamed 'hooks' -> 'hooks-SAMPLES'
[git@gitsrvhost .git]$ ln -s -v ../hooks
'./hooks' -> '../hooks'
[git@gitsrvhost .git]$ cd
[git@gitsrvhost ~]$
```

3. Using one of the following methods, setup a repository
for git clients to access on this server:

A. You can create a brand new naked project:

```
[git@gitsrvhost ~]$ git init --bare ProjX
Initialized empty Git repository in /home/git/ProjX/
[git@gitsrvhost ~]$
```

B. Or you can migrate an existing project git repository
from a remote server to this server:

```
[git@gitsrvhost ~]$ git clone --bare https://github.com/user/ProjX ProjX
remote[...]
Receiving[...]
[git@gitsrvhost ~]$ cd ProjX
[git@gitsrvhost ProjX]$ git remote rm origin
[git@gitsrvhost ProjX]$ git config --local --replace-all core.bare true
[git@gitsrvhost ProjX]$ cd
[git@gitsrvhost ~]$
```

C. Or if you already have the project checked out locally
on this server, then you can just copy its ".git" folder:

```
[git@gitsrvhost ~]$ cp -a /tmp/ProjX/.git ~/ProjX
[git@gitsrvhost ~]$ cd ProjX
[git@gitsrvhost ProjX]$ git remote rm origin
[git@gitsrvhost ProjX]$ git config --local --replace-all core.bare true
[git@gitsrvhost ProjX]$ cd
[git@gitsrvhost ~]$
```

You can repeat this to create unlimited git repositories
hosted by this server.

4. Authorize Git Clients

Put something like the following on a single line in ~git/.ssh/authorized_keys:

```
command="~/git-server/git-server KEY=USER1" ssh-rsa AAAA___blah_pub__ user1@workstation
```

You can add unlimited client users and SSH public keys.

5. ACL (Optional)

By default, any client in the authorized_keys file will be
allowed to do any operations to any repo on this server.
If you wish to enforce restrictions for certain users or
branches or certain repositories, then you can enable
the Access Control List hooks provided.
See hooks/INSTALL_ACL.md for setup.

Or you can create your own server hooks. Each hook will see
the ENV settings (like KEY=USER1) defined in authorized_keys.

See contrib/* for some working "hooks" examples, such as logging.

Client Side
===========

1. To utilize the git server, clone a repository:

```
[user1@devbox ~]$ git clone git@gitsrvhost:ProjX
remote[...]
Receiving[...]
[user1@devbox ~]$ cd ProjX
[user1@devbox ProjX]$ git status
[user1@devbox ProjX]$ git log
[user1@devbox ProjX]$
```

2. Optional Wrapper

To use the "git-client" wrapper for .gitconfig overrides:

```
[admin@devbox ~]$ sudo wget -N https://raw.githubusercontent.com/hookbot/git-server/master/git-client
[admin@devbox ~]$ sudo chmod 755 git-client
[admin@devbox ~]$ sudo mv -v -i git-client /usr/local/bin/git
[admin@devbox ~]$
```

3. To enable the "git deploy" capabilities on the client host:

```
[admin@devbox ~]$ wget -N -P /usr/bin https://raw.githubusercontent.com/hookbot/git-server/master/git-deploy
[admin@devbox ~]$ chmod 755 /usr/bin/git-deploy
[admin@devbox ~]$
```

4. To enable debugging, run this on any client host:

```
[user1@devbox ProjX]$ git config --global core.SshCommand 'ssh -o SendEnv=XMODIFIERS'
# -AND/OR- for super annoying SSH debugging on local repo:
[user1@devbox ProjX]$ git config --local core.SshCommand 'ssh -v -o SendEnv=XMODIFIERS'
# -AND/OR- you can use ENV if you don't want to mess with the git config:
[user1@devbox ProjX]$ export GIT_SSH_COMMAND='ssh -o SendEnv=XMODIFIERS'
[user1@devbox ProjX]$ export XMODIFIERS=DEBUG=1
[user1@devbox ProjX]$
```
