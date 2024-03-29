#!/bin/sh
DESC="default target handling"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repo"
git init -q
touch file
git add file
commit

verb "default to all targets"
cat <<EOF > .gitassembly
merge master a
merge master b
EOF
capture gas
echon "$OUT" | grep -q '^  a$'
echon "$OUT" | grep -q '^  b$'

verb "request a single target"
capture gas a
test "$OUT" = "a"

verb "target through assembly"
cat <<EOF > .gitassembly
merge master a
merge master b
target a
EOF
capture gas
test "$OUT" = "a"

verb "implicit target assembly override"
capture gas b
test "$OUT" = "b"

verb "explicit target assembly override"
capture gas --all
echon "$OUT" | grep -q '^  a$'
echon "$OUT" | grep -q '^  b$'
