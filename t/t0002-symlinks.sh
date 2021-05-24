#!/bin/sh
DESC="ensure versioned .gitassembler symlinks are ignored"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repository"
git init -q

verb "test reading normal .gitassembly"
echo "base test master" > .gitassembly
quiet gas

verb "test reading symlinked .gitassembly"
ln -sf gitassembly .gitassembly
not quiet gas
