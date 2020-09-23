#!/bin/sh
DESC="parsing tests"
. "$(dirname "$0")/lib.sh"

verb "initialize a new repository"
git init -q

verb "test reading .gitassembly with no eol"
echon "base test master" > .gitassembly
capture gas
test "$OUT" = "test .. master"
