#!/bin/sh
DESC="test base with self merge optimization"
. ./lib.sh

verb "initialize a new repo"
git init -q
touch file_master
git add file_master
commit

verb "initialize assembly file with base and self-merge"
cat <<EOF > .gitassembly
base test master
merge test master
EOF

verb "bootstrap checking for a repeated merge"
capture gas -av --create
echo "$OUT"
assert_out_regex "creating branch test from master"
not assert_out_regex "merging master into test"
checkout test
test -f file_master

verb "update the main branch"
checkout master
echo test > file_master
commit -a

verb "ensure merge still works with following updates"
capture gas -av
assert_out_regex "merging master into test"
