TODO
====

Some features we need or want, plus some neat ideas that may not be too feasible to implement.

 - Autodetect git-deploy updates to respawn

 - Add [log.verbosity] 0 or 1 or 2 feature to control level of messaging spewage to the git client.

 - Add [acl.allowip] IP Whitelist feature

 - Add [acl.allowauthor] feature to whitelist Author Email or RegExp for all commits being pushed.

 - Two-Way Git "Proxy" support for remote git server to allow for slow migration of a repo from one system to another.
   # Like the client: $ git pull --rebase foreign-repo
   # but instead of on the client, automatically merge on the server side.
   # i.e., pre-read and pre-write to attempt importing remote repo first can quickly run "git pull --rebase ; git rebase --abort" from the server side?
   # and post-write can run "git push remote BRANCH" to sync up any fresh changes out to the remote repo.
   # -OR-
   # This surely can all be done on the client side using "git merge". Provide commandline or alias to sync either way or both.
   # -OR-
   # Most, if not all of these, may also be implemented externally via callback webhooks
   # Or even provide multiple ways to accomplish the two-way sync

 - Add support for automatic rotation of log.logfile, i.e:
   * git config log.compress true (default false)
   * git config log.{daily|weekly} true (default "weekly" is true)
   * git config log.rotate 365 (default 5)

 - Set $USER_AGENT environment for post-read and post-write (Requires man-in-the-middle sniffer)

 - Provide branch, old hash, and new hash (for every branch updated by the git client) to post-read hook args (Requires man-in-the-middle sniffer)
   * If nothing is updated to the client, then there will be no arguments to post-read.
   * There will be a multiple of 3 args, each triple being branch, old hash, new hash, (depending on how many branches the client updates).
   * In order to facilitate the InterProcessCommunication to post-read, information in should be stored in $GIT_DIR/last-read-state.<git-server-pid>.txt until the post-read completes.
   * Client sends "want" and "have" so the server knows how to pack up the deltas to give to the client.

 - Determine files involved with the pull (Requires man-in-the-middle sniffer)

 - Provide branch, old hash, new hash, and common parent "fork" commit hash to pre-write hook and post-write hook args. (Requires man-in-the-middle sniffer)
   * This fork hash can be used for debugging
   * or for callback webhook.
   * In order to facilitate the InterProcessCommunication between the pre-write and post-write, information in should be stored in $GIT_DIR/last-write-state.<git-server-pid>.txt until the post-write completes.

 - Determine files involved with the push

 - Add [restrictfile.___.pushers] support to block pushes including changes to specified files, except authorized "pushers"
   * Only restrict WRITING certain files
   * Not feasible to block READ of files
   * EXAMPLE: git config restrictfile."lib/config.txt".pushers alice,bob

 - Fix git-deploy to handle split cheese case where git server uses both IPv4 and IPv6

 - Add [webhook.url] feature for callback support
   * support for multiple [webhook.url] configurations to mean POST to multiple callback URLs
   * support for protocols http and https
   * support for push
   * support for pull
   * provide the direction of operation ("read" for clone,pull,fetch) ("write" for push)
   * support for pull/clone/fetch (setup proxy sniffer to scan for "want" and "have" packets from client to determine updates downloaded to the git client)
   * Allow for WhiteList or BlackList filters to trigger webhook or ignore webhooks under certain conditions:
     : When specified branches are involved
     : When certain KEY users are involved
     : When coming from a specific IP or Network CIDR
     : When certain files are affected (tricky for pull reads)
     : When certain strings exist in any of the commit comments being pushed. (Tricky for pull reads.)
   * provide failover queue retry mechanism fibinacci backoff until remote webhook server returns 2xx or 3xx status.
   * provide Git Server Version
   * provide Git Client Version (man-in-the-middle sniff)
   * provide user KEY doing the pulling or pushing (and pubkey?)
   * provide epoch time stamp of client connection.
   * provide IPv4 or IPv6 Address of client connecting.
   * provide type of reference pushing ("tag" or "branch").
   * provide branch or tag affected by push or pull operation.
   * provide PREV commit hash for the tag or branch
   * provide whether or not FORCE was used to rewrite or destroy history
   * at least provide when FORCE push destroys branch history
     : common fork point hash
     : list of commits that were destroyed
   * for each NEW commit pushed and OLD commit destroyed back until $found_fork_commit_hash, provide:
     : commit hash
     : author name
     : author email
     : subject of commit excuse reason, i.e., (my $squish = `git show -s --format=%s 665bd34 `)=~s{\s+}{ }g; $squish =~ s/\s+$//m; $squish =~ s<^(.{80}).{3,}><$1...>s;
     : files added
     : files modified
     : files removed
   * provide files affected for each commit
