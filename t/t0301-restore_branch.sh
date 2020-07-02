#!/bin/sh
DESC="the starting branch should be restored"
. ./lib.sh

verb "initialize a new repo"
git init -q
touch file
git add file
commit
git checkout -b test
touch file2
git add file2
commit
git checkout master
touch file3
git add file3
commit

verb "perform a merge"
cat <<EOF > .gitassembly
merge master test
EOF
gas -a
test `current_branch` = master

verb "perform a rebase"
cat <<EOF > .gitassembly
rebase test master
EOF
gas -a
test `current_branch` = master
