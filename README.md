# loup-cmd-echo

GNU `echo` recreated in [Loup](https://code-craft.ai/references/loup): write
arguments to standard output, with `-n`, `-e`, `-E` and every GNU backslash
escape.

Part of the **loup-cmd** series of example applications: classic Linux and
Windows commands, and projects for each Loup execution mode, each in its own
repository under [myronccai](https://github.com/myronccai?tab=repositories&q=loup-cmd).
This one is `host.dual` Loup built as a native binary.

## Requirements

- Loup 1.26.0 or later:

  ```sh
  curl -fsSL https://github.com/code-craft-ai-company/loup-releases/releases/latest/download/loup-install.sh | sh
  ```

- `make`, and `clang` 17 or later for the native build.

## Usage

```sh
make build                 # native binary: build/echo
make ci                    # check, unit tests, build, end-to-end tests
make run ARGS="-e 'a\tb'"  # run from source with loup run
```

```text
$ build/echo hello   world
hello world
$ build/echo -n "no newline"; echo '<'
no newline<
$ build/echo -e 'col1\tcol2\nrow\x21'
col1	col2
row!
$ build/echo -e 'stop here\c' 'never printed'; echo '<'
stop here<
$ build/echo -- -n
-- -n
$ build/echo --version
echo (loup-cmd-echo) 0.1.0
```

Options: `-n` (no trailing newline), `-e` (interpret escapes), `-E` (do not;
the default). Options must come first and may be combined (`-ne`); `--help`
and `--version` work only as the sole argument. Escapes under `-e`:
`\\ \a \b \c \e \f \n \r \t \v \0NNN \xHH`.

Exit status: always `0`.

## Differences from GNU echo

- `\0NNN` and `\xHH` values from 0x80 to 0xFF print the Unicode character
  U+0080–U+00FF (two UTF-8 bytes) instead of one raw byte.
- `POSIXLY_CORRECT` is ignored.
- `--version` prints a single line.

## Layout

```text
source/main.loup            # entry point
source/appinfo.loup         # name, version, exit statuses
source/cli/args.loup        # GNU echo option rules
source/cli/usage.loup       # --help and --version text
source/cli/app.loup         # run(): parse, dispatch, exit status
source/commands/echo.loup   # escapes and output
tests/*_test.loup           # unit tests (make test)
tests/e2e.sh                # end-to-end tests of build/echo (make e2e)
specs/echo/                 # requirements, design, tasks
```

[AGENTS.md](AGENTS.md) has every build and test command and the conventions
for changing the code.
