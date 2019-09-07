#!/bin/sh
DESC="smoke tests"
. ./lib.sh

verb "ensure the test area is pristine"
test -x "$GAS"
not quiet "$GAS"

verb "initialize a new repository"
git init -q

verb "test reading .git/assembly"
echo "base test master" > .git/assembly
quiet "$GAS"
rm .git/assembly

verb "test reading .gitassembly"
echo "base test master" > .gitassembly
quiet "$GAS"

verb "ensure .git/assembly takes precedence"
touch .git/assembly
capture not "$GAS"
test "$OUT" = "git-assembler: nothing to do"
