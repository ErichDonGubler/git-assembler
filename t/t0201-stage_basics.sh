#!/bin/sh
DESC="basic stage tests"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo"
git init -q
touch file_master
git add file_master
commit

verb "initialize assembly file with a stage branch"
cat <<EOF > .gitassembly
stage test master
EOF

verb "ensure stage can bootstrap the branch"
capture gas -av
assert_out_regex "creating branch test from master"
checkout test
test -f file_master

verb "stage doesn't recreate branches for no reason"
capture gas -av
assert_out_regex "already up to date"
