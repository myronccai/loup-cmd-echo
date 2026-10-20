# loup-cmd-echo

GNU `echo` recreated in [Loup](https://code-craft.ai/references/loup): write
arguments to standard output, with `-n`, `-e`, `-E` and every GNU backslash
escape.

Part of the **loup-cmd** series of example applications: classic Linux and
Windows commands, and projects for each Loup execution mode, each in its own
repository under [myronccai](https://github.com/myronccai?tab=repositories&q=loup-cmd).
This one is `host.dual` Loup built as a native binary.

## Requirements

- [Loup Lite](https://github.com/code-craft-ai-company/loup-releases) 1.26.0
  or later; see [Installing Loup Lite](#installing-loup-lite).
- `make`, and `clang` 17 or later for the native build.

## Installing Loup Lite

This example is built and tested with **Loup Lite**, the free public build of
the Loup toolchain from [Code Craft AI](https://code-craft.ai), meant for
education and training. Code Craft AI publishes the official builds,
installers and signed checksums at
**<https://github.com/code-craft-ai-company/loup-releases>**, for Linux
(x86-64, arm64), macOS (Apple silicon, Intel) and Windows (x86-64).

Linux and macOS:

```sh
curl -fsSL https://github.com/code-craft-ai-company/loup-releases/releases/latest/download/loup-install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://github.com/code-craft-ai-company/loup-releases/releases/latest/download/loup-install.ps1 | iex
```

The installer picks the archive for your machine, checks it against the
release's `SHA256SUMS`, unpacks it into `~/.loup`
(`%LOCALAPPDATA%\Programs\Loup` on Windows) and puts its `bin` directory on
your `PATH`; it needs no administrator rights. You get `loup`, the Stage0
compiler `loup-bootstrap` and the Wasm runtime `loup-launcher`. Open a new
shell and check:

```sh
loup --version             # loup 1.26.0 or later
```

CI installs the exact version it tests with, 1.26.0. To do the same:

```sh
curl -fsSL https://github.com/code-craft-ai-company/loup-releases/releases/download/v1.26.0/loup-install.sh | sh -s -- --version 1.26.0
```

To install by hand, download your platform's archive from the
[releases page](https://github.com/code-craft-ai-company/loup-releases/releases),
check it against `SHA256SUMS`, unpack it anywhere and add its `bin` directory to
`PATH`. The [loup-releases README](https://github.com/code-craft-ai-company/loup-releases#verify-a-download)
explains how to verify the Sigstore signature on `SHA256SUMS`.

Loup Lite leaves out Loup's cryptography library and the full set of Loup
packages; this example needs neither. The full release is at
<https://code-craft.ai/loup/download>, and commercial use of Loup needs a
license: <https://code-craft.ai/loup/license>.

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

## License

[MIT](LICENSE), copyright 2026 Code Craft AI LLC. The Loup skill in
[`skills/loup-programmer/`](skills/loup-programmer/) is copied from the Loup
project and is not covered by this license; it keeps the Loup project's terms.
