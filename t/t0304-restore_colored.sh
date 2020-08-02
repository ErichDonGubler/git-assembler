#!/bin/sh
DESC="restore a branch which has been colored"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo with three branches"
git init -q
touch file_master
git add file_master
commit
checkout -b temp
checkout -b test
touch file_test
git add file_test
commit
checkout master
touch file_master2
git add file_master2
commit

verb "initialize assembly file"
cat <<EOF > .gitassembly
rebase temp master
rebase test temp
EOF

verb "ensure initial temp branch can be restored despite the coloring"
checkout temp
capture gas -av --color=always
test $(current_branch) = temp
