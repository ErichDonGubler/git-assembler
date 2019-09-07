#!/bin/sh
DESC="smoke tests"
. ./lib.sh

verb "ensure the test area is pristine"
test -x "$GAS"
not quiet gas

verb "initialize a new repository"
git init -q

verb "test reading .git/assembly"
echo "base test master" > .git/assembly
quiet gas
rm .git/assembly

verb "test reading .gitassembly"
echo "base test master" > .gitassembly
quiet gas

verb "ensure .git/assembly takes precedence"
touch .git/assembly
capture not gas
test "$OUT" = "git-assembler: nothing to do"
