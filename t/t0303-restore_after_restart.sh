#!/bin/sh
DESC="initial branch should be restored when continuing"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo with a conflict"
git init -q
touch file
git add file
commit
checkout -b test
echo a > file
git add file
commit
checkout master
echo b > file
git add file
commit
checkout -b temp master
test `current_branch` = temp

verb "perform a conflicting merge"
cat <<EOF > .gitassembly
merge master test
EOF
capture not gas -a
assert_out_regex "error while merging test into master"
test `current_branch` = master

verb "fix the conflict"
echo b > file
git add file
quiet commit

verb "ensure branch switching is visible"
capture gas -a
# ensure the message is visible without -v
assert_out_regex "restoring initial branch temp"
test `current_branch` = temp
