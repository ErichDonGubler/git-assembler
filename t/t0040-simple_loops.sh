#!/bin/sh
DESC="detect obvious dependency loops"
. ./lib.sh

# these would still be detected as a cycle, so ensure all checks are
# detected earlier while parsing with a better error message

verb "initialize a new repo"
git init -q

verb "do not allow self-merge"
cat <<EOF > .gitassembly
merge master master
EOF
capture not gas -a
assert_out_regex "\.gitassembly:1: refusing merge of master into itself"

verb "do not allow stage to self"
cat <<EOF > .gitassembly
stage master master
EOF
capture not gas -a
assert_out_regex "\.gitassembly:1: refusing to stage master onto itself"

verb "do not allow base to self"
cat <<EOF > .gitassembly
base master master
EOF
capture not gas -a
assert_out_regex "\.gitassembly:1: refusing to base master onto itself"

verb "do not allow rebase to self"
cat <<EOF > .gitassembly
rebase master master
EOF
capture not gas -a
assert_out_regex "\.gitassembly:1: refusing to rebase master onto itself"
