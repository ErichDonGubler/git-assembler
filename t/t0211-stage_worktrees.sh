#!/bin/sh
DESC="ensure staging branches can be created in worktrees"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo and a worktree"
git init -q master
(
    cd master
    commit --allow-empty
    git worktree add ../worktree -b test -q
)

verb "initialize assembly file"
cat <<EOF > master/.git/assembly
stage test master
EOF

verb "ensure gas works in master"
(
    cd master
    capture gas -av master
    assert_out_regex "already up to date"
)

verb "ensure gas can bootstrap checked-out staging branch"
(
    cd worktree

    # master is already checked out in the main branch, however
    # this shouldn't cause a staging-branch recreate failure just
    # because it's being used temporarily!
    quiet gas -av --recreate
)
