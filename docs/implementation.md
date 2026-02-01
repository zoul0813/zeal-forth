# Implementation notes

This file summarizes the behavior visible in the current Zeal Forth
implementation. It is based on the assembly sources in `src/`.

## Startup and prompt

- On boot, the runtime prints `Zeal Forth` and a newline.
- A prompt of `> ` is displayed before each input line.
- After processing a full line, the interpreter prints `  ok` and a newline.

## Input parsing

- Input is line-based and read into a fixed buffer of 256 bytes.
- The trailing newline is replaced with a null terminator.
- The line is split into tokens using a single space (`0x20`) as the delimiter.
- Empty tokens are skipped.

## Numbers

- Numeric parsing accepts decimal digits only.
- Values must fit in a 16-bit cell; larger values trigger a numeric overflow
  error.
- Parsed values are pushed onto the data stack.

## Dictionary lookup

- Each non-numeric token is looked up in the built-in dictionary.
- Unknown words print `UNKNOWN: <token>` followed by a newline and are skipped.

## Data and return stacks

- Cell size is 2 bytes.
- Data stack size is 2048 bytes (1024 cells). It grows downward in memory.
- A return stack of 1024 bytes exists and is exposed via `>r`, `r>`, and `.rs`.

## Memory access

- `@` reads a 16-bit cell from the given address.
- `!` writes a 16-bit cell to the given address.
- Cells are stored little-endian (low byte first).

## HERE and PAD

- `here` returns the current HERE pointer, initialized to the start of the heap
  region (`here` in BSS).
- `pad` returns a transient buffer at `HERE + 256`.
- The PAD size is 128 bytes.

## Character output

- `emit` writes the low byte of the top stack item to standard output.

## Error messages

- Numeric overflow prints `  numeric overflow` followed by `  error`.
- Other errors currently print a generic `  error` message.
