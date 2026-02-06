# Implementation notes

This file summarizes the behavior visible in the current Zeal Forth
implementation. It is based on the assembly sources in `src/`.

## Startup and prompt

- On boot, the runtime prints:
  - `Zeal Forth`
  - `Type \`bye\` to exit`
  - A blank line between each line above.
- A prompt of `> ` is displayed before each input line.
- After processing a full line, the interpreter prints `  ok` and a newline.

## Input parsing

- Input is line-based and read into a fixed buffer of 256 bytes.
- In the interactive prompt, the trailing newline is replaced with a null
  terminator.
- Tokens are split on spaces (`0x20`) and newlines (`0x0A`).
- Empty tokens are skipped.

## Numbers

- Numeric parsing accepts decimal digits only.
- Values must fit in a 16-bit cell; larger values trigger a numeric overflow
  error.
- Parsed values are pushed onto the data stack.

## Dictionary lookup

- Each non-numeric token is looked up in the dictionary (built-ins plus any
  definitions created with `:`/`;`, `create`, or `variable`).
- If a word is not found, the interpreter currently prints a numeric error code
  (currently `0`) followed by `  error`.

## Data and return stacks

- Cell size is 2 bytes.
- Data stack size is 2048 bytes (1024 cells). It grows downward in memory.
- A return stack of 1024 bytes exists and is exposed via `>r`, `r>`, and `.rs`.
  It is also used internally for compiler/runtime plumbing:
  - patching `if`/`else`/`then`
  - `create ... does>` handoff (the created entry and patch sites are passed via
    return stack temporaries)

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

- `.` prints a 16-bit value in free-field decimal format, then a newline.
- `emit` writes the low byte of the top stack item to standard output.
- `type` writes `n` bytes from `c-addr`.

## Error messages

- Numeric overflow prints `numeric overflow` followed by `  error`.
- Compile-only words executed in interpret mode print `  compile-only`.
- Other errors currently print a numeric error code followed by `  error`.

## Compilation model (current)

- `:` switches to compile mode and creates a new dictionary entry.
- Compiled words are emitted as `CALL` instructions to their CFA.
- Compiled numbers are emitted as `LD DE,nn` followed by a `CALL pushdata`.
- `;` ends the definition by emitting a `RET` and returning to interpret mode.
- `if`/`else`/`then` emit conditional jumps and backpatch targets using the return
  stack.
- `does>` compiles a runtime patch prologue that redirects the last `create`d
  child into the code after `does>`, and uses return-stack temporaries to carry
  patch addresses.
