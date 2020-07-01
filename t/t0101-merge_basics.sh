#!/bin/sh
DESC="basic merge tests"
. ./lib.sh

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

verb "initialize assembly file"
cat <<EOF > .gitassembly
merge master test
EOF

verb "ensure merge is run"
capture gas -av
assert_out_regex "merging test into master"
test -f file_test

verb "ensure merge is not run twice"
capture gas -av
assert_out_regex "already up to date"

verb "adding a commit to be merged"
checkout test
touch file_test2
git add file_test2
commit
checkout master
not test -f file_test2

verb "ensure merge detects new changes"
capture gas -av
assert_out_regex "merging test into master"
test -f file_test2
