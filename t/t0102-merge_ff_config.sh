#!/bin/sh
DESC="ensure that git config assembler.mergeff works as expected"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo with two branches"
git init -q
touch file_master
git add file_master
commit
checkout -b test

verb "initialize assembly file"
cat <<EOF > .gitassembly
merge master test
EOF

_BASE_HEAD="$(git rev-parse HEAD)"

_reset() {
    checkout master
    git reset --hard -q "$_BASE_HEAD"
    checkout test
    git reset --hard -q master
    touch file_test
    git add file_test
    commit
    _TEST_HEAD="$(git rev-parse HEAD)"
    checkout master
    not test -f file_test
}

verb "testing without config"
_reset
capture gas -av
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD"

verb "testing with git config assembler.mergeff true"
_reset
git config assembler.mergeff true
capture gas -av
git config --unset assembler.mergeff
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD"

verb "testing with git config assembler.mergeff false"
_reset
git config assembler.mergeff false
capture gas -av
git config --unset assembler.mergeff
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD $_TEST_HEAD"

verb "testing with git config GIT_ASSEMBLER_MERGEFF=true"
_reset
GIT_ASSEMBLER_MERGEFF=true capture gas -av
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD"

verb "testing with git config GIT_ASSEMBLER_MERGEFF=true overriding config"
_reset
git config assembler.mergeff false
GIT_ASSEMBLER_MERGEFF=true capture gas -av
git config --unset assembler.mergeff
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD"

verb "testing with git config GIT_ASSEMBLER_MERGEFF=false"
_reset
GIT_ASSEMBLER_MERGEFF=false capture gas -av
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD $_TEST_HEAD"

verb "testing with git config GIT_ASSEMBLER_MERGEFF=false overriding config"
_reset
git config assembler.mergeff true
GIT_ASSEMBLER_MERGEFF=false capture gas -av
git config --unset assembler.mergeff
assert_out_regex "merging test into master"
capture git rev-list -n1 --parents HEAD
test "$OUT" = "$(git rev-parse HEAD) $_BASE_HEAD $_TEST_HEAD"
