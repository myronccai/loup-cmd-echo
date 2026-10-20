# Design: echo

## Overview

`main()` passes `runtime.args()` to `cli.app.run`, which parses the
arguments into `Options`, handles `--help` and `--version`, and calls
`commands.echo.run_echo`. All behaviour lives in pure functions that return
strings, so the tests check output without capturing standard output.

## Modules

| Module | Contents |
|---|---|
| `source/main.loup` | entry point: `run(runtime.args())` |
| `source/appinfo.loup` | name, version, summary, exit statuses |
| `source/cli/args.loup` | `Options`, `is_echo_option`, `parse_args` (echo's GNU option rules) |
| `source/cli/usage.loup` | `usage()` help text, `version_line()` |
| `source/cli/app.loup` | `run()`: parse, help/version, run the command, map exceptions to status 1 |
| `source/commands/echo.loup` | `expand_escapes` (returns `Expanded{text, stop}`), `render`, `run_echo` |

`expand_escapes` walks the operand one character at a time. `\c` returns
early with `stop = true`, and `render` then returns what it has built without
the remaining operands or the newline.

## Differences from GNU echo

- `\0NNN` and `\xHH` values from 0x80 to 0xFF produce the Unicode character
  U+0080–U+00FF (two bytes in UTF-8), not a single raw byte: Loup strings are
  Unicode text.
- `POSIXLY_CORRECT` is not consulted.
- `--version` prints one line (`echo (loup-cmd-echo) 0.1.0`).

## Error handling

echo cannot fail on its input. An unexpected exception is reported on
standard error and gives exit status 1.

## Testing

- `tests/args_test.loup`: option recognition, combination and ordering.
- `tests/echo_test.loup`: joining, `-n`, every escape, `\c`.
- `tests/app_test.loup`: exit statuses through `run()`.
- `tests/e2e.sh`: runs the native binary and compares output byte for byte,
  including a NUL byte and `\c`.
