# shared test functions
NAME="$(basename "$0" .sh)"
TDIR="$(realpath $(dirname "$0"))"
DATA="$TDIR/$name"
ROOT="$(realpath "$TDIR/..")"

# parse shared cli flags
VERBOSE=0
DEBUG=0
HELP=0

while getopts vdDr:h optname
do
  case "$optname" in
  r) ROOT="$(realpath "$optarg")" ;;
  v) VERBOSE=1 ;;
  d) DEBUG=1 ;;
  D) echo "$DESC"; exit 0 ;;
  h) HELP=1 ;;
  ?) exit 2 ;;
  esac
done

if [ "$HELP" = 1 ]
then
  echo "Usage: $0 [-dDhv] [-r ROOT]

$NAME: $DESC

  -d: turn on test debugging
  -D: describe test
  -h: this help
  -v: verbose mode
  -r ROOT: set source root"
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
  [ "$VERBOSE" = 1 ] && msg "$@"
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
