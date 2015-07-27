# INSTALL_ACL

These scripts can be used to implement granular ACLs for "readers" and "writers".
It also includes support for instant push-notification to any client with an
SSH key in the "deploy" group.

Assuming you already have a git repo setup somewhere,
this "hooks" folder corresponds to the $GIT_DIR/hooks folder.
It is easiest to just symlink the entire folder. For example:

```
su - git
git clone https://github.com/hookbot/git-server ~/git-server
cd projectz.git
mv -v hooks hooks.SAMPLES_OLD
ln -s -v ~/git-server/hooks .
```

Then just append something like the following block into
your $GIT_DIR/config file:

```
echo '
[acl]
	readers = hookbot,rob
	writers = hookbot,alice,bob
	deploy = push_notification_key1
' >> config
```

FYI: Actually, you only need "writers" and "deploy" settings
since both of these ACLs are given implicit "readers" access.

# PUSH NOTIFICATION INSTANT DEPLOY SETUP

# Create an SSH key

```
[puller@deploy-host ~]$ ssh-keygen -t dsa
Generating public/private dsa key pair.
Enter file in which to save the key (/home/puller/.ssh/id_dsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/puller/.ssh/id_dsa.
Your public key has been saved in /home/puller/.ssh/id_dsa.pub.
[puller@deploy-host ~]$ cat ~/.ssh/id_dsa.pub
ssh-dss AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host
[puller@deploy-host ~]$
```

# Install this key on the git host

Think of a name for this key, such as "push_notification_key1", and
ensure this name is in the [acl] "deploy" line of the $GIT_DIR/config.

```
[git@git-host]$ echo 'command="~/git-server/git-server KEY=push_notification_key1" ssh-dss AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host' >> ~/.ssh/authorized_keys
[git@git-host]$ grep push_notification_key1 ~/projectz.git/config
	deploy = push_notification_key1
[git@git-host]$
```

# Verify this deploy key was installed properly

```
[puller@deploy-host ~]$ git clone ssh://git@git-host/~/projectz
[puller@deploy-host ~]$ cd projectz
[puller@deploy-host projectz]$ git pull
```

Hopefully, if everything is working properly, the "git pull"
command should just block. This means it is successfully
waiting for one of the "writers" to push...

# Test push notification

Find another user with "writers" key access to perform a push:

```
[alice@dev projectz]$ git push
Tue Jun 23 07:54:45 2015: [alice] git-server: RUNNING PUSH ...
Counting objects: 4, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 387 bytes | 0 bytes/s, done.
Total 4 (delta 1), reused 0 (delta 0)
remote: Tue Jun 23 07:54:45 2015: Sending push notification to 222.222.222.222-push_notification_key1 ...
To git@git-host:projectz
   f60b258..d759447  master -> master
[alice@dev projectz]$
```

Hopefully, that other "git pull" process on deploy-host that was blocked will
immediately finish and deploy this fresh pull. Then you know everything is
configured perfectly for the "deploy" user and for the "writers" user.

# Install Deploy Cron

```
[puller@deploy-host projectz]$ echo '0 * * * * cd ~/projectz && umask 002 && git pull 2>/dev/null >/dev/null' | crontab -
[puller@deploy-host projectz]$
```

You can do this on multiple deployment systems.
If different deployment systems will appear to come from the
same IP from the git-server point of view, then you will need
to create a different deployment SSH key for each system.
