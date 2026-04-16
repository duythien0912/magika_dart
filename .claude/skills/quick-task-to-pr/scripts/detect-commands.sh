#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"

has_file() {
  local path="$1"
  [[ -e "$REPO_ROOT/$path" ]]
}

has_glob_match() {
  local pattern="$1"
  compgen -G "$REPO_ROOT/$pattern" > /dev/null
}

ANALYZE_CMD=""
UNIT_TEST_CMD=""
E2E_AC_CMD=""
E2E_ALL_CMD=""

if has_file "pubspec.yaml"; then
  if command -v flutter >/dev/null 2>&1; then
    ANALYZE_CMD="flutter analyze"
    UNIT_TEST_CMD="flutter test"
  elif command -v dart >/dev/null 2>&1; then
    ANALYZE_CMD="dart analyze"
    UNIT_TEST_CMD="dart test"
  fi
fi

if has_glob_match "integration_test/*.dart" || has_glob_match "test_driver/*"; then
  if command -v flutter >/dev/null 2>&1; then
    E2E_AC_CMD="flutter test integration_test"
    E2E_ALL_CMD="flutter test integration_test"
  fi
fi

printf 'ANALYZE_CMD=%q\n' "$ANALYZE_CMD"
printf 'UNIT_TEST_CMD=%q\n' "$UNIT_TEST_CMD"
printf 'E2E_AC_CMD=%q\n' "$E2E_AC_CMD"
printf 'E2E_ALL_CMD=%q\n' "$E2E_ALL_CMD"
