#!/bin/sh
DESC="smoke tests"
. ./lib.sh

# ensure the test area is pristine
test -x "$GAS"
not quiet "$GAS"

# initialize a new repo with two empty branches
git init -q
git checkout -q -b test

# read .git/assembly
echo "base test master" > .git/assembly
quiet "$GAS"
rm .git/assembly

# read .gitassembly
echo "base test master" > .gitassembly
quiet "$GAS"

# ensure .git/assembly is favored by using an empty config
touch .git/assembly
out="$(not $GAS 2>&1)"
test "$out" = "git-assembler: nothing to do"
