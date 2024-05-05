TODO
====

Some features we need or want, plus some neat ideas that may not be too feasible to implement.

 - Fix ID Message format to be consistent everywhere [$KEY@$IP]

 - Add IP Whitelist [restrictip] feature

 - Author email whitelist or RegExp

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

 - Provide branch, old hash, new hash, and common parent "fork" commit hash to pre-write hook and post-write hook args.  LOGS transport interprocess communications
   * This fork hash can be used for debugging
   * or for callback webhook.
   * In order to facilitate the InterProcessCommunication between the pre-write and post-write, information in should be stored in $GIT_DIR/last-write-state.txt until the post-write completes.

if old_hash found in git log new_hash,
  $found_fork_commit_hash = $prev_hash
else
  while (!$found_fork_commit_hash)
    do alternate old/new scan until match
    git rev-parse $new_next_hash~1
    git rev-parse $old_next_hash~1 (remember every one of these hashes in order to know which commits have been rolled back or destroyed)
    until find match with the other side
    $found_fork_commit_hash = HASH

Example of how to obtain the commit immediately older before another commit hash:
[hookbot@Robs-AllState-Mac git-server]$ git rev-parse ba9604a164bbc5b04f4fd06148ac00b31d48402f~0
ba9604a164bbc5b04f4fd06148ac00b31d48402f
[hookbot@Robs-AllState-Mac git-server]$ git rev-parse ba9604a164bbc5b04f4fd06148ac00b31d48402f~1
4588ee196d836edd688f3aea12f80507852dec28
[hookbot@Robs-AllState-Mac git-server]$ git rev-parse 4588ee196d836edd688f3aea12f80507852dec28~1
f0698e302c5b628b0a27748a72736a73d1387db3
[hookbot@Robs-AllState-Mac git-server]$ git rev-parse f0698e302c5b628b0a27748a72736a73d1387db3~1
a7f3cea904dca2436d3fc18310008a33f9efef80
[hookbot@Robs-AllState-Mac git-server]$

 - Add support for automatic log rotation
   * git config logrotate."logs/access_log".compress true
   * git config logrotate."*".compress true
   * git config logrotate."logs/access_log".daily true
   * git config logrotate."*".weekly true
   * git config logrotate."logs/access_log".rotate 365
   * git config logrotate."*".rotate 20

 - Determine files involved with the push

 - Add [restrictfile] support

 - Fix git-deploy to handle split cheese case where git server uses both IPv4 and IPv6

(gethostbyname)
echo -e '\nHost $GIT_HOST\n    AddressFamily inet6' >> ~/.ssh/config

 - Add webhook callback support
   * support for protos http and https
   * support for push
   * support for pull/clone (tricky to obtain client heads from pull packets - reverse engineered - proxy can read read HEADs from client then passthru after that)
   * provide failover retry mechanism in case webhook server is down
   * provide user KEY doing the pulling or pushing (and pubkey? NAH!)
   * provide epoch time stamp of client connection.
   * provide IPv4 or IPv6 Address of client connecting
   * provide type of reference pushing ("tag" or "branch")
   * provide branch or tag modified by push operation
   * provide PREV commit hash for the tag or branch
   * provide whether or not FORCE was used to rewrite or destroy history
   * at least provide when FORCE push destroys branch history
     : common fork point hash
     : list of commits that were destroyed
   * for each NEW commit pushed and OLD commit destroyed back until $found_fork_commit_hash, provide:
     : commit hash
     : author name
     : author email
     : subject of commit excuse reason, i.e., (my $squish = `git show -s --format=%s 12ABCDEF `)=~s{\s+}{ }g; $squish =~ s/\s+$//m; $squish =~ s<^(.{80}).{3,}><$1...>s;
     : files added
     : files modified
     : files removed
   * provide files affected for each commit
