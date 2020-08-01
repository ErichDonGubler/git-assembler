#!/bin/sh
DESC="basic cycle detection"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo"
git init -q

verb "test 2-node fully cyclic graph"
cat <<EOF > .gitassembly
base master test
base test master
EOF
assert_cycle master test

verb "test 3-node fully cyclic"
cat <<EOF > .gitassembly
base master test1
base test1 test2
base test2 master
EOF
assert_cycle master test1 test2

verb "test 3-node semi cyclic"
cat <<EOF > .gitassembly
base master test1
base test1 test2
base test2 test1
EOF
assert_cycle test1
