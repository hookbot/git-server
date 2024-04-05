# INSTALL_ACL

Server Side:
------------

These scripts can be used to implement granular ACLs for "readers" and "writers".
It also includes support for instant push-notification to any client with an
SSH key in the "deploy" group.

Assuming you already have a git repo setup somewhere,
this "hooks" folder corresponds to the $GIT_DIR/hooks folder.
It is easiest to just symlink the entire folder. For example:

```
[admin@gitsrvhost ~]$ sudo su - git
[git@gitsrvhost ~]$ git init --bare ProjX
Initialized empty Git repository in /home/git/ProjX/
[git@gitsrvhost ~]$ cd ProjX/.git
[git@gitsrvhost .git]$ mv -v hooks hooks.SAMPLES_OLD
[git@gitsrvhost .git]$ ln -s -v ~/git-server/hooks .
[git@gitsrvhost .git]$ cd
[git@gitsrvhost ~]$
```

Configure the git server repository with whatever
ACL settings you wish. For example:

```
[admin@gitsrvhost ~]$ sudo su - git
[git@gitsrvhost ~]$ cd ~/ProjX
[git@gitsrvhost ProjX]$ git config acl.readers hookbot,rob
[git@gitsrvhost ProjX]$ git config acl.writers hookbot,alice,bob
[git@gitsrvhost ProjX]$ git config acl.deploy push_notification_key1
[git@gitsrvhost ProjX]$ git config restrictbranch.master admin
[git@gitsrvhost ProjX]$ git config restrictbranch.dev/main admin,bob
[git@gitsrvhost ProjX]$ git config log.logfile logs/access_log
[git@gitsrvhost ProjX]$ cd
[git@gitsrvhost ~]$
```

FYI: Actually, you only need "writers" and "deploy" settings
since both of these ACLs are given implicit "readers" access.
Just don't put the same user KEY in both "writers" and "deploy"
settings at the same time.


Client Side:
------------

# PUSH NOTIFICATION INSTANT DEPLOY SETUP

# Install git-deploy

```
[admin@deploy-host ~]$ sudo su -
[root@deploy-host ~]# wget -N -P /usr/bin https://raw.githubusercontent.com/hookbot/git-server/master/git-deploy
[root@deploy-host ~]# chmod 755 /usr/bin/git-deploy
[root@deploy-host ~]#
```

# Create an SSH key

```
[root@deploy-host ~]# su - puller
[puller@deploy-host ~]$ ssh-keygen -t rsa
Generating public/private dsa key pair.
Enter file in which to save the key (/home/puller/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/puller/.ssh/id_rsa.
Your public key has been saved in /home/puller/.ssh/id_rsa.pub.
[puller@deploy-host ~]$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host
[puller@deploy-host ~]$
```

Allow Client on Server:
-----------------------

# Install this key on the git server host

Think of a name for this key, such as "push_notification_key1", and
ensure this name is in the acl.deploy comma-delimited list.

```
[admin@gitsrvhost ~]$ sudo su - git
[git@gitsrvhost ~]$ echo 'command="~/git-server/git-server KEY=push_notification_key1" ssh-rsa AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host' >> ~/.ssh/authorized_keys
[git@gitsrvhost ~]$ cd ~/ProjX
[git@gitsrvhost ProjX]$ git config acl.deploy
srv7
[git@gitsrvhost ProjX]$ git config acl.deploy srv7,push_notification_key1
[git@gitsrvhost ProjX]$ git config acl.deploy
srv7,push_notification_key1
[git@gitsrvhost ProjX]$ git config --list | grep push_notification_key1
acl.deploy=srv7,push_notification_key1
[git@gitsrvhost ProjX]$ git config acl.writers alice,bobdev
[git@gitsrvhost ProjX]$
```

# Optional logfile to log all git operations on the server:

```
[git@gitsrvhost ProjX]$ git config log.logfile "logs/access_log"
[git@gitsrvhost ProjX]$
```

Verify Clients:
---------------

# Test to ensure the deploy KEY was installed properly:

```
[puller@deploy-host ~]$ git clone ssh://git@gitsrvhost/ProjX
[puller@deploy-host ~]$ cd ProjX
[puller@deploy-host ProjX]$ git deploy &
```

Hopefully, if everything is working properly, the "git deploy"
command should just block. This means it is successfully
waiting for one of the "writers" to push...

# Test push notification

Find another user with "writers" key access to perform a push:

```
[alice@dev ProjX]$ git push
Tue Jun 23 07:54:45 2015: [alice] git-server: RUNNING PUSH ...
Counting objects: 4, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 387 bytes | 0 bytes/s, done.
Total 4 (delta 1), reused 0 (delta 0)
remote: Tue Jun 23 07:54:45 2015: Sending push notification to 222.222.222.222-push_notification_key1 ...
To git@git-host:projectz
   f60b258..d759447  master -> master
[alice@dev ProjX]$
```

Hopefully, that other "git pull" process on deploy-host that was blocked will
immediately finish and deploy this fresh push. Then you know everything is
configured perfectly for the "deploy" user and for the "writers" user.
And you can append a cron to keep the deployment daemon running.

# Install Deploy Cron

```
[puller@deploy-host ProjX]$ (crontab -l 2>/dev/null ; echo ; echo "0 * * * * cd ~/ProjX && git deploy >/dev/null 2>/dev/null") | crontab -
[puller@deploy-host ProjX]$
```

You can do this on multiple deployment systems.
If different deployment systems will appear to come from the
same IP from the gitsrvhost point of view (such as machines
behind a NAT), then that will infinite grind the gitsrvhost.
To avoid this problem, make sure each machine coming from
this same IP that is in the acl.deploy list has a distinct
deployment SSH pubkey and KEY setting in authorized_keys.
