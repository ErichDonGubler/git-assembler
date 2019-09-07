#!/bin/sh
VERBOSE=0
DESCRIBE=0
HELP=0

while getopts vDr:h optname
do
  case "$optname" in
  v) VERBOSE=1 ;;
  D) DESCRIBE=1 ;;
  h) HELP=1 ;;
  ?) exit 2 ;;
  esac
done

if [ "$HELP" = 1 ]
then
  echo "Usage: $0 [-Dhv] [-r ROOT]

git-assembler test runner

  -D: describe tests
  -h: this help
  -v: verbose mode
  -r ROOT: set source root"
  exit 0
fi


# test runner
find . -mindepth 1 -maxdepth 1 -name "t*-*.sh" -type f -perm 755 | sort | while read t
do
  echo -n "`basename "$t" .sh`: "
  out="`"$t" "$@" 2>&1`"
  v="$?"
  if [ "$v" = 0 ]
  then
    [ "$DESCRIBE" = 1 ] && echo "$out" || echo "ok"
  else
    echo "fail"
    echo "========"
    echo "$out"
    exit "$v"
  fi
done
