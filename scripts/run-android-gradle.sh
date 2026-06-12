#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CONSTANTS="$ROOT/app/src/main/java/com/foursquare/rideup/Constants.java"
EXAMPLE="$CONSTANTS.example"
generated_constants=0

cleanup() {
  if [ "$generated_constants" -eq 1 ]; then
    rm -f "$CONSTANTS"
  fi
}
trap cleanup 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if [ ! -f "$CONSTANTS" ]; then
  cp "$EXAMPLE" "$CONSTANTS"
  generated_constants=1
fi

cd "$ROOT"
exec_status=0
./gradlew --no-daemon "$@" || exec_status=$?
exit "$exec_status"
