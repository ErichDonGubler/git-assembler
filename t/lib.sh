# shared test functions
NAME="$(basename "$0" .sh)"
TDIR="$(realpath $(dirname "$0"))"
DATA="$TDIR/$name"
ROOT="$(realpath "$TDIR/..")"

# parse shared cli flags
VERBOSE=0
DEBUG=0
HELP=0

while getopts vdDh optname
do
  case "$optname" in
  v) VERBOSE=1 ;;
  d) DEBUG=1 ;;
  D) echo "$DESC"; exit 0 ;;
  h) HELP=1 ;;
  ?) exit 2 ;;
  esac
done

if [ "$HELP" = 1 ]
then
  echo "Usage: $0 [-dDhv]

$NAME: $DESC

  -d: turn on test debugging
  -D: describe test
  -h: this help
  -v: verbose mode"
  exit 0
fi


# setup the test environmnent
GAS="$ROOT/git-assembler"

cd $(mktemp -d) || exit $?
if [ "$DEBUG" = 0 ]; then
  trap "cd \"$TDIR\" && rm -r \"$PWD\"" EXIT
else
  trap "echo \"test working directory: $PWD\"" EXIT
fi

set -e


# helper functions
msg()
{
  echo "$NAME: $@"
}

verb()
{
  if [ "$VERBOSE" = 1 ]
  then
    msg "$@"
  fi
}

out()
{
  if [ "$VERBOSE" = 1 ]
  then
    echo "$@"
  fi
}

fail()
{
  msg "error: $@"
  exit 1
}

success()
{
  exit 0
}

quiet()
{
  if [ "$VERBOSE" = 1 ]
  then
    "$@"
  else
    "$@" 2>/dev/null >&2
  fi
}

not()
{
  "$@" && false || true
}

capture()
{
  local flags="$-"
  set +x
  OUT="$("$@" 2>&1)"
  set -"$flags"
}

gas()
{
  "$GAS" "$@"
}

assert_cycle()
{
  capture not gas
  out "$OUT"
  local ret=1
  for branch in "$@"
  do
    if [ "$OUT" = "git-assembler: dependency cycle detected for branch $branch" ]
    then
      ret=0
      break
    fi
  done
  return "$ret"
}