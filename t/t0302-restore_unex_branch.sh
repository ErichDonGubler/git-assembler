#!/bin/sh
DESC="restoring a missing branch shouldn't fail"
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
test $(current_branch) = temp

verb "perform a conflicting merge"
cat <<EOF > .gitassembly
merge master test
EOF
capture not gas -a
assert_out_regex "error while merging test into master"
test $(current_branch) = master

verb "delete the initial branch"
quiet git branch -D temp

verb "fix the conflict"
echo b > file
git add file
quiet commit

verb "attempt to continue"
capture gas -a
assert_out_regex "cannot restore initial branch temp"
test $(current_branch) = master
