# Requirements: echo

## Introduction

`echo` writes its operands to standard output, separated by single spaces and
followed by a newline. This repository recreates GNU coreutils `echo` in Loup,
including its option rules and the backslash escapes enabled by `-e`. It is
the first command in the loup-cmd series and sets the single-command layout
the others follow.

## Requirements

### Requirement 1: Output

**User Story:** As a shell user, I want my arguments printed back so that I
can write text from scripts.

#### Acceptance Criteria

1. WHEN echo is run with operands, THE program SHALL write them separated by
   one space and followed by a newline, and exit with status 0.
2. WHEN echo is run with no operands, THE program SHALL write a single newline.
3. THE program SHALL keep the spacing inside each operand unchanged.

### Requirement 2: Options

**User Story:** As a shell user, I want GNU echo's options so that existing
scripts behave the same.

#### Acceptance Criteria

1. WHEN an argument is a dash followed only by the letters `n`, `e` and `E`,
   THE program SHALL treat it as options; letters may be combined (`-ne`).
2. WHEN `-n` is given, THE program SHALL omit the trailing newline.
3. WHEN `-e` is given, THE program SHALL interpret backslash escapes; `-E`
   SHALL turn interpretation off; the last of the two wins.
4. WHEN an argument is not an option (including `--`, `-` and `-nx`), THE
   program SHALL treat it and every later argument as operands.
5. WHEN `--help` or `--version` is the only argument, THE program SHALL print
   the help text or the version line and exit with status 0; otherwise THE
   program SHALL print them as operands.

### Requirement 3: Escapes

**User Story:** As a script author, I want escape sequences so that I can
print control characters.

#### Acceptance Criteria

1. WHEN `-e` is in effect, THE program SHALL replace `\\ \a \b \e \f \n \r \t
   \v` with backslash, BEL, BS, ESC, FF, LF, CR, TAB and VT.
2. WHEN `-e` is in effect, THE program SHALL replace `\0NNN` (zero to three
   octal digits) and `\xHH` (one or two hex digits) with the character of
   that value.
3. WHEN `-e` is in effect and `\c` is reached, THE program SHALL stop all
   output, including later operands and the newline.
4. WHEN a backslash is followed by any other character, or `\x` by no hex
   digit, THE program SHALL print the backslash and the character unchanged.
