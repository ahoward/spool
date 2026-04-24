#!/usr/bin/env sh
# Entry point. Runs every test_*.sh in this dir in alpha order.
# Each test is a standalone sh script that exits non-zero on failure.
# No deps beyond POSIX sh + git + coreutils.

set -eu

here=$(dirname "$0")
pass=0
fail=0
failed_tests=""

for t in "$here"/test_*.sh; do
    [ -f "$t" ] || continue
    name=$(basename "$t" .sh)
    printf '%s ... ' "$name"
    if sh "$t" >/tmp/spool-test-$$.log 2>&1; then
        printf 'ok\n'
        pass=$((pass + 1))
    else
        printf 'FAIL\n'
        fail=$((fail + 1))
        failed_tests="$failed_tests $name"
        sed 's/^/    /' /tmp/spool-test-$$.log
    fi
    rm -f /tmp/spool-test-$$.log
done

printf '\n%d passed, %d failed\n' "$pass" "$fail"
if [ "$fail" -gt 0 ]; then
    printf 'failed:%s\n' "$failed_tests"
    exit 1
fi
