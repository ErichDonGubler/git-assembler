#!/bin/sh
TDIR="$(dirname "$0")"

VERBOSE=0
DESCRIBE=0
HELP=0

while getopts vDh optname
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
  echo "Usage: $0 [-Dhv]

git-assembler test runner

  -D: describe tests
  -h: this help
  -v: verbose mode"
  exit 0
fi


# test runner
find "$TDIR" -mindepth 1 -maxdepth 1 -name "t*-*.sh" -type f -perm 755 | sort | while read t
do
  printf "%-30s : " "$(basename "$t" .sh)"
  out=$("$t" "$@" 2>&1)
  v="$?"
  if [ "$v" = 0 ]
  then
    [ "$DESCRIBE" = 1 ] && echo "$out" || echo "ok"
  else
    echo "fail"
    if [ "$VERBOSE" = 1 ]
    then
	    echo "========"
	    echo "$out"
    fi
    exit "$v"
  fi
done
