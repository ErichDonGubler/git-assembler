#!/bin/sh
DESC="test cache paths with worktrees"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo and a worktree"
git init -q master
(
    cd master
    commit --allow-empty
    git worktree add ../worktree -b test2 -q
    echo test > file
    git add file
    commit
)

verb "initialize assembly file"
cat <<EOF > master/.git/assembly
stage test1 master
stage test2 master
EOF

verb "ensure gas works in master"
(
    cd master
    quiet gas -a --recreate test1

    # switch away from master so that it can be checked out in worktree
    # even without a detached branch (to separate both failure modes)
    checkout test1
)

verb "ensure gas writes state in correct worktree directory"
(
    cd worktree

    # enforce a conflict to trigger state saving
    echo test > file
    not quiet gas -avvv --recreate test2

    # check that the state directory has been created
    test -d $(git rev-parse --git-dir)/as-cache
)
