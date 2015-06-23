# INSTALL_ACL

These scripts can be used to implement granular ACLs for "readers" and "writers".
It also includes support for instant [push notification] to any client with an
SSH key in the "deploy" group.

This "hooks" folder corresponds to the $GIT_DIR/hooks folder.
You can copy each hook file into it or integrate with any current
hooks you want or just symlink the entire folder.

```
su - git
git clone http://github.com/hookbot/git-server ~/git-server
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

# PUSH NOTIFICATION INSTANT DEPLOY SETUP

To utilize the "deploy" feature, just run "git pull" from a cron regularly.

# Create an SSH key

```
[puller@deploy-host ~]$ ssh-keygen -t dsa
Generating public/private dsa key pair.
Enter file in which to save the key (/home/kim/.ssh/id_dsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/puller/.ssh/id_dsa.
Your public key has been saved in /home/puller/.ssh/id_dsa.pub.
[puller@deploy-host ~]$ cat ~/.ssh/id_dsa.pub
ssh-dss AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host
[puller@deploy-host ~]$
```

# Install this key on the git host

This of a name for this key, such as "push_notification_key1",
and ensure it is in the [acl] "deploy" line of the config.

```
[git@git-host]$ echo 'command="~/git-server/git-server KEY=push_notification_key1" ssh-dss AAAAB3NzaC1W3w1Ee4nu3f03ck4OW puller@deploy-host' >> ~/.ssh/authorized_keys
[git@git-host]$
```

# Verify this deploy key was installed properly

```
[puller@deploy-host ~]$ git clone git@git-host:projectz
[puller@deploy-host ~]$ cd projectz
[puller@deploy-host projectz]$ git pull
```

Hopefully, if everything is working properly, the "git pull" command should just block.
This means it is successfully waiting for one of the "writers" to push...

# Test push notification

Find another user with "writers" key access to perform a push:

```
[alice@dev projectz]$ git push
Tue Jun 23 07:54:45 2015: [alice] git-server: RUNNING PUSH ...
Everything up-to-date
[alice@dev projectz]$
```

Hopefully, that other "git pull" process on deploy-host that was blocked will
now instantly complete. Then you know everything is configured perfectly.

# Install Deploy Cron

```
[puller@deploy-host projectz]$ echo '0 * * * * cd ~/projectz && git pull 2>/dev/null >/dev/null' | crontab -
[puller@deploy-host projectz]$ 
```
