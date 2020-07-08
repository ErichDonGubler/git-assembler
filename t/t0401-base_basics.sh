#!/bin/sh
DESC="basic base tests"
. ./lib.sh

verb "initialize a new repo"
git init -q
touch file_master
git add file_master
commit

verb "initialize assembly file with a base branch"
cat <<EOF > .gitassembly
base test master
EOF

verb "refuse to bootstrap unless --create is provided"
capture not gas -av
assert_out_regex "branch test needs creation from master"

verb "ensure base can bootstrap the branch"
capture gas -av --create
assert_out_regex "creating branch test from master"
checkout test
test -f file_master

verb "base doesn't recreate branches for no reason"
capture gas -av
assert_out_regex "already up to date"

verb "base doesn't recreate branches with --create"
capture gas -av --create
assert_out_regex "already up to date"

verb "base can recreate branches with --recreate"
capture gas -av --recreate
assert_out_regex "erasing existing branch test"
assert_out_regex "creating branch test from master"
checkout test
test -f file_master

verb "base with --recreate implies --create"
checkout master
quiet git branch -D test
capture gas -av --recreate
not assert_out_regex "erasing existing branch test"
assert_out_regex "creating branch test from master"
checkout test
test -f file_master
