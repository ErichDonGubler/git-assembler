#!/bin/sh
DESC="basic rebase tests"
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

verb "initialize assembly file"
cat <<EOF > .gitassembly
rebase test master
EOF

verb "ensure rebase is not run without new commits"
capture gas -av
assert_out_regex "already up to date"

verb "adding a commit to base branch"
touch file_master2
git add file_master2
commit

verb "ensure rebase is run with newer base"
capture gas -av
assert_out_regex "rebasing test onto master"
test -f file_master
test -f file_master2
not test -f file_test

verb "ensure test commit has not been lost"
checkout test
test -f file_master
test -f file_master2
test -f file_test

verb "ensure rebase is not run with newer tip"
touch file_test2
git add file_test2
commit
capture gas -av
assert_out_regex "already up to date"
