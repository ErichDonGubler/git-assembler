#!/bin/sh
DESC="test .git/assembly when using worktrees"
. ./lib.sh

verb "ensure the test area is pristine"
test -x "$GAS"
not quiet gas

verb "initialize a new repository with two worktrees"
mkdir x y
cd x
mkdir z
git init -q
touch file
git add file
commit
git worktree add -q z
git worktree add -q ../y

verb "reading .git/assembly from root"
echo "base test master" > .git/assembly
quiet gas

verb "reading .git/assembly from worktree subdirectory"
( cd z && quiet gas; )

verb "reading .git/assembly from worktree directory"
( cd ../y && quiet gas; )
