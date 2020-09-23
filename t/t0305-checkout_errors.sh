#!/bin/sh
DESC="handle checkout errors without failing"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo and branch"
git init -q
commit --allow-empty
checkout -b branch
touch file
git add file
commit
checkout master
echo test > file

verb "initialize assembly file"
cat <<EOF > .git/assembly
stage test branch
EOF

verb "force a checkout conflict"
capture not gas -av --create
assert_out_regex "error while .*"

verb "ensure no additional errors are generated"
not assert_out_regex "Aborting Traceback .*"
assert_out_regex "stopping at branch master, .*"
