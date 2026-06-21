#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/ride-up-root-control-XXXXXX")
ATTACKER_ROOT="$TEMP_ROOT/attacker-root"
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM
unset MAKEFILES MAKEFILE_LIST ANDROID_HOME ANDROID_SDK_ROOT

CONTROL_DIR="$TEMP_ROOT/control"
CHECKOUT="$TEMP_ROOT/Ride Up's [gate] \"quoted\" \`touch RIDE_UP_BACKTICK_MARKER\`"
COMMAND_LOG="$TEMP_ROOT/commands.log"
BAD_COMMAND_LOG="$TEMP_ROOT/bad-command.log"
FAKE_SHELL_LOG="$TEMP_ROOT/fake-shell.log"
mkdir "$CONTROL_DIR" "$CHECKOUT" "$CHECKOUT/scripts" "$CHECKOUT/bin" "$ATTACKER_ROOT"
CONTROL_DIR=$(CDPATH= cd -- "$CONTROL_DIR" && pwd -P)
CHECKOUT=$(CDPATH= cd -- "$CHECKOUT" && pwd -P)
MAKEFILE="$CHECKOUT/Makefile"
cp "$ROOT_DIR/Makefile" "$MAKEFILE"

cat >"$CHECKOUT/bin/ruby" <<'EOF'
#!/bin/sh
printf '%s|ruby|%s|%s|%s\n' "$PWD" "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$*" >> "$RIDE_UP_COMMAND_LOG"
EOF

write_logger() {
  file=$1
  cat >"$file" <<'EOF'
#!/bin/sh
printf '%s|%s|%s|%s|%s\n' "$PWD" "$0" "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$*" >> "$RIDE_UP_COMMAND_LOG"
EOF
  chmod +x "$file"
}

write_logger "$CHECKOUT/scripts/run-android-gradle.sh"
write_logger "$CHECKOUT/scripts/test-makefile-root.sh"
chmod +x "$CHECKOUT/bin/ruby"

BAD_COMMAND="$TEMP_ROOT/bad-command"
cat >"$BAD_COMMAND" <<EOF
#!/bin/sh
printf '%s\n' invoked >> '$BAD_COMMAND_LOG'
exit 91
EOF
chmod +x "$BAD_COMMAND"

FAKE_SHELL="$TEMP_ROOT/fake-shell"
cat >"$FAKE_SHELL" <<EOF
#!/bin/sh
printf '%s\n' invoked >> '$FAKE_SHELL_LOG'
exec /bin/sh "\$@"
EOF
chmod +x "$FAKE_SHELL"

assert_commands_stayed_in_checkout() {
  scenario=$1
  target=$2
  if [ "$target" = dependency ] || [ "$target" = build ]; then
    return
  fi
  if [ ! -s "$COMMAND_LOG" ]; then
    printf '%s\n' "$scenario $target executed no quality command" >&2
    exit 1
  fi
  while IFS= read -r command; do
    case "$command" in
      "$CONTROL_DIR|"*"$CHECKOUT"*) ;;
      "$CHECKOUT|"*) ;;
      *)
        printf '%s\n' "$scenario $target escaped the checkout: $command" >&2
        exit 1
        ;;
    esac
    if printf '%s' "$command" | grep -Fq "$ATTACKER_ROOT"; then
      printf '%s\n' "$scenario $target accepted attacker SDK/root data" >&2
      exit 1
    fi
  done <"$COMMAND_LOG"
}

run_case() {
  scenario=$1
  target=$2
  mode=$3
  rm -f "$COMMAND_LOG" "$BAD_COMMAND_LOG" "$FAKE_SHELL_LOG"
  output="$TEMP_ROOT/output"
  set +e
  case "$mode" in
    default)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    command-root)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "ROOT=$ATTACKER_ROOT" "$target") >"$output" 2>&1
      ;;
    environment-root)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" ROOT="$ATTACKER_ROOT" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    command-shell)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "SHELL=$FAKE_SHELL" "$target") >"$output" 2>&1
      ;;
    environment-shell)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" SHELL="$FAKE_SHELL" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    command-flags)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" '.SHELLFLAGS=-eu -c' "$target") >"$output" 2>&1
      ;;
    environment-flags)
      (cd "$CONTROL_DIR" && env '.SHELLFLAGS=-eu -c' PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    command-ruby)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "RUBY=$BAD_COMMAND" "$target") >"$output" 2>&1
      ;;
    environment-ruby)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RUBY="$BAD_COMMAND" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    command-sdk)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "ANDROID_SDK=$ATTACKER_ROOT" "$target") >"$output" 2>&1
      ;;
    environment-sdk)
      (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" ANDROID_SDK="$ATTACKER_ROOT" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" "$target") >"$output" 2>&1
      ;;
    *)
      printf '%s\n' "unknown test mode: $mode" >&2
      exit 1
      ;;
  esac
  result=$?
  set -e
  if [ "$result" -ne 0 ]; then
    printf '%s\n' "$scenario $target failed" >&2
    cat "$output" >&2
    exit 1
  fi
  assert_commands_stayed_in_checkout "$scenario" "$target"
  if [ -e "$BAD_COMMAND_LOG" ]; then
    printf '%s\n' "$scenario $target executed caller-controlled RUBY" >&2
    exit 1
  fi
  if [ -e "$FAKE_SHELL_LOG" ]; then
    printf '%s\n' "$scenario $target executed caller-controlled SHELL" >&2
    exit 1
  fi
}

for target in build check dependency lint root-test test verify; do
  run_case default "$target" default
  run_case command-root "$target" command-root
  run_case environment-root "$target" environment-root
  run_case command-shell "$target" command-shell
  run_case environment-shell "$target" environment-shell
  run_case command-flags "$target" command-flags
  run_case environment-flags "$target" environment-flags
  run_case command-ruby "$target" command-ruby
  run_case environment-ruby "$target" environment-ruby
  run_case command-sdk "$target" command-sdk
  run_case environment-sdk "$target" environment-sdk
done

if [ -e "$CONTROL_DIR/RIDE_UP_BACKTICK_MARKER" ]; then
  printf '%s\n' "checkout path executed a command substitution" >&2
  exit 1
fi

if (cd "$CONTROL_DIR" && /usr/bin/make --no-print-directory --file "$MAKEFILE" MAKEFILE_LIST=/tmp/untrusted check) >"$TEMP_ROOT/command-list.out" 2>&1; then
  printf '%s\n' "command MAKEFILE_LIST override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/command-list.out"

if (cd "$CONTROL_DIR" && MAKEFILE_LIST=/tmp/untrusted /usr/bin/make --environment-overrides --no-print-directory --file "$MAKEFILE" check) >"$TEMP_ROOT/environment-list.out" 2>&1; then
  printf '%s\n' "environment MAKEFILE_LIST override unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILE_LIST must not be overridden" "$TEMP_ROOT/environment-list.out"

PRELOADED_MAKEFILE="$TEMP_ROOT/preloaded.mk"
printf '%s\n' 'ROOT := /tmp/preloaded-attacker-root' >"$PRELOADED_MAKEFILE"
rm -f "$COMMAND_LOG"
if (cd "$CONTROL_DIR" && MAKEFILES="$PRELOADED_MAKEFILE" PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" check) >"$TEMP_ROOT/preloaded.out" 2>&1; then
  printf '%s\n' "MAKEFILES preload unexpectedly passed" >&2
  exit 1
fi
grep -Fq "MAKEFILES must be empty" "$TEMP_ROOT/preloaded.out"
if [ -e "$COMMAND_LOG" ]; then
  printf '%s\n' "MAKEFILES preload reached a quality command" >&2
  exit 1
fi

EARLIER_MAKEFILE="$TEMP_ROOT/earlier.mk"
printf '%s\n' '# Explicit caller-controlled Makefile.' >"$EARLIER_MAKEFILE"
rm -f "$COMMAND_LOG"
if (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$EARLIER_MAKEFILE" --file "$MAKEFILE" check) >"$TEMP_ROOT/earlier-multiple.out" 2>&1; then
  printf '%s\n' "earlier -f Makefile unexpectedly passed" >&2
  exit 1
fi
grep -Fq "repository Makefile path could not be resolved" "$TEMP_ROOT/earlier-multiple.out"
if [ -e "$COMMAND_LOG" ]; then
  printf '%s\n' "earlier -f Makefile reached a quality command" >&2
  exit 1
fi

LATER_MAKEFILE="$TEMP_ROOT/later.mk"
LATER_MARKER="$TEMP_ROOT/later-marker"
cat >"$LATER_MAKEFILE" <<EOF
build:
	@printf owned > "$LATER_MARKER"
EOF
rm -f "$COMMAND_LOG" "$LATER_MARKER"
if (cd "$CONTROL_DIR" && PATH="$CHECKOUT/bin:$PATH" RIDE_UP_COMMAND_LOG="$COMMAND_LOG" /usr/bin/make --no-print-directory --file "$MAKEFILE" --file "$LATER_MAKEFILE" build) >"$TEMP_ROOT/later-multiple.out" 2>&1; then
  printf '%s\n' "later -f Makefile unexpectedly passed" >&2
  exit 1
fi
grep -Fq "repository Makefile must be loaded alone" "$TEMP_ROOT/later-multiple.out"
if [ -e "$COMMAND_LOG" ] || [ -e "$LATER_MARKER" ]; then
  printf '%s\n' "later -f Makefile reached a quality or replacement command" >&2
  exit 1
fi

printf '%s\n' "Makefile root tests passed: 77 executed target/authority cases, 2 MAKEFILE_LIST rejections, 1 MAKEFILES rejection, and 2 multi-Makefile rejections"
