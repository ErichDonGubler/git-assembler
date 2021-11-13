#!/bin/sh
DESC="merge tests with conflicting fast-forward settings"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo with two branches"
git init -q
touch file_master
git add file_master
commit
checkout -b test
touch file_test
git add file_test
commit
checkout master
not test -f file_test

verb "add one extra commit to prevent fast-forward merges"
touch file2_master
git add file2_master
commit

verb "setup merge.ff=only for this repository"
git config merge.ff only

verb "initialize assembly file"
cat <<EOF > .gitassembly
merge master test
EOF

verb "ensure merge still works as expected"
capture gas -av
assert_out_regex "merging test into master"
test -f file_test
