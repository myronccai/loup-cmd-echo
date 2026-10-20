#!/usr/bin/env bash
# End-to-end tests: run the built binary and compare its standard output
# (byte for byte) and exit status with the expected ones.
#
# usage: tests/e2e.sh BINARY

set -u
BIN=$1
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
pass=0
fail=0

# check_file NAME STATUS EXPECTED_FILE [ARGS...]
# Runs BINARY ARGS... with standard input from the file named by $IN
# (default: /dev/null) and compares standard output with EXPECTED_FILE.
check_file() {
    local name=$1 want_status=$2 want_file=$3
    shift 3
    "$BIN" "$@" < "${IN:-/dev/null}" > "$TMP/out" 2> "$TMP/err"
    local status=$?
    if [ "$status" -eq "$want_status" ] && cmp -s "$want_file" "$TMP/out"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "FAIL: $name (exit $status, expected $want_status)"
        diff <(od -c "$want_file") <(od -c "$TMP/out") | sed 's/^/    /' | head -20
        sed 's/^/    stderr: /' "$TMP/err" | head -5
    fi
}

# check NAME STATUS EXPECTED_STDOUT [ARGS...]
# As check_file, with the expected output given as a string. Bash strings
# cannot hold NUL bytes; use check_file for output that contains them.
check() {
    local name=$1 want_status=$2
    printf '%s' "$3" > "$TMP/want"
    shift 3
    check_file "$name" "$want_status" "$TMP/want" "$@"
}

check "plain"              0 $'hello world\n'         hello world
check "no operands"        0 $'\n'
check "spaces kept"        0 $'a  b c\n'              'a  b' c
check "-n"                 0 'hi'                     -n hi
check "-e tab"             0 $'a\tb\n'                -e 'a\tb'
check "-E default"         0 $'a\\tb\n'               'a\tb'
check "-e then -E"         0 $'a\\tb\n'               -e -E 'a\tb'
check "combined -ne"       0 $'x\ty'                  -ne 'x\ty'
check "octal"              0 $'A\n'                   -e '\0101'
check "hex"                0 $'AB\n'                  -e '\x41\x42'
check "backslash c"        0 'stop'                   -e 'stop\cignored' more
check "unknown escape"     0 $'\\q\n'                 -e '\q'
check "option after text"  0 $'a -n\n'                a -n
check "double dash"        0 $'-- x\n'                -- x
check "lone dash"          0 $'-\n'                   -
check "invalid option"     0 $'-nx y\n'               -nx y
check "help with operand"  0 $'--help x\n'            --help x
check "version"            0 $'echo (loup-cmd-echo) 0.1.0\n' --version

printf 'a\0b\n' > "$TMP/nul"
check_file "nul byte"      0 "$TMP/nul"               -e 'a\0b'

echo "e2e: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
