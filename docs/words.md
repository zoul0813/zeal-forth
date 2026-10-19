# Built-in words

The following words are built into the interpreter at boot. Stack effects
use the Forth convention `( before -- after )`.

## Stack

| Word | Stack effect | Description |
| --- | --- | --- |
| `dup` | `( n -- n n )` | Duplicate the top stack item. |
| `drop` | `( n -- )` | Drop the top stack item. |
| `swap` | `( n1 n2 -- n2 n1 )` | Swap the top two stack items. |
| `over` | `( n1 n2 -- n1 n2 n1 )` | Copy the second item to the top. |
| `rot` | `( n1 n2 n3 -- n2 n3 n1 )` | Rotate the top three items. |
| `wipe` | `( -- )` | Reset the data stack pointer. |

## Math

| Word | Stack effect | Description |
| --- | --- | --- |
| `+` | `( n1 n2 -- n1+n2 )` | Add the top two stack items (16-bit wraparound). |
| `-` | `( n1 n2 -- n1-n2 )` | Subtract the top two stack items (16-bit wraparound). |
| `*` | `( n1 n2 -- n1*n2 )` | Multiply the top two stack items (lower 16 bits). |
| `2*` | `( x -- doubled-x )` | Shift a 16-bit cell left one bit, discarding overflow. |
| `2/` | `( n -- halved-n )` | Arithmetic right shift by one bit, preserving the sign bit (rounds negative odd values down). |
| `/` | `( n1 n2 -- n3 )` | Signed floored division. Division by zero raises `div0 error`. |
| `mod` | `( n1 n2 -- n3 )` | Signed floored remainder (sign follows divisor). Division by zero raises `div0 error`. |
| `/mod` | `( n1 n2 -- rem quot )` | Signed floored remainder and quotient. Division by zero raises `div0 error`. |
| `u/` | `( u1 u2 -- u3 )` | Unsigned division. Division by zero raises `div0 error`. |
| `umod` | `( u1 u2 -- u3 )` | Unsigned remainder. Division by zero raises `div0 error`. |
| `u/mod` | `( u1 u2 -- urem uquot )` | Unsigned remainder and quotient. Division by zero raises `div0 error`. |
| `abs` | `( n -- u )` | Absolute value. |
| `negate` | `( n -- -n )` | Two's-complement negation. |

## Compare + Logic

| Word | Stack effect | Description |
| --- | --- | --- |
| `=` | `( n1 n2 -- flag )` | True if equal. |
| `<` | `( n1 n2 -- flag )` | True if `n1 < n2` (signed). |
| `>` | `( n1 n2 -- flag )` | True if `n1 > n2` (signed). |
| `u<` | `( u1 u2 -- flag )` | True if `u1 < u2` (unsigned). |
| `u>` | `( u1 u2 -- flag )` | True if `u1 > u2` (unsigned). |
| `and` | `( n1 n2 -- n3 )` | Bitwise AND. |
| `or` | `( n1 n2 -- n3 )` | Bitwise OR. |
| `xor` | `( n1 n2 -- n3 )` | Bitwise XOR. |
| `invert` | `( n -- n2 )` | Bitwise NOT. |

## Memory

| Word | Stack effect | Description |
| --- | --- | --- |
| `@` | `( a-addr -- x )` | Fetch a 16-bit cell from memory. |
| `c@` | `( c-addr -- c )` | Fetch a char from `c-addr`. |
| `!` | `( x a-addr -- )` | Store a 16-bit cell to memory. |
| `c!` | `( n c-addr -- )` | Store the low byte of `n` at `c-addr`. |
| `here` | `( -- a-addr )` | Return the current HERE pointer. |
| `pad` | `( -- c-addr )` | Return a transient buffer at `HERE + 256` (128 bytes). |
| `s"` | `( "ccc<quote>" -- c-addr u )` | Parse a string; in a definition, compile its bytes and runtime address/length. Immediate. |
| `cells` | `( n1 -- n2 )` | Convert a cell count to bytes using `2*` (16-bit wraparound). |
| `allot` | `( n -- )` | Reserve `n` bytes starting at HERE. |

## I/O + Text

| Word | Stack effect | Description |
| --- | --- | --- |
| `.` | `( n -- )` | Print using `BASE`, then a space: signed decimal or raw uppercase hexadecimal. |
| `."` | `( -- )` | Print characters until the next `"`, consuming the input stream. |
| `emit` | `( c -- )` | Output the low byte of `c` as a character. |
| `type` | `( c-addr n -- )` | Output `n` bytes from `c-addr`. |
| `loadfile` | `( "ccc<quote>" -- )` | Load and interpret a file from a quoted path. |
| `key?` | `( -- flag )` | Non-blocking key probe; buffers one key for `key` when true. |
| `key` | `( -- c )` | Return one key; consumes buffered key if `key?` found one. |
| `\` | `( -- )` | Discard the remainder of the input buffer. Immediate. |
| `(` | `( -- )` | Discard input until the next `)` in the current buffer. Immediate. |

## Dictionary + Compilation

| Word | Stack effect | Description |
| --- | --- | --- |
| `create` | `( "name" -- )` | Define a word that pushes its storage address. |
| `variable` | `( "name" -- )` | Define a word that pushes its storage address and allocates 1 cell. |
| `:` | `( "<spaces>name" -- )` | Start compiling a new word definition. |
| `;` | `( -- )` | End the current word definition and return to immediate mode. |
| `state` | `( -- a-addr )` | Address of the compilation-state flag. |
| `base` | `( -- a-addr )` | Address of the numeric base cell. |
| `hex` | `( -- )` | Set `BASE` to 16. Immediate. |
| `decimal` | `( -- )` | Set `BASE` to 10. Immediate. |
| `execute` | `( x-addr -- )` | Execute code at `x-addr`. |
| `,` | `( x -- )` | Store `x` at HERE, advance HERE by one cell. |
| `c,` | `( c -- )` | Store `c` at HERE, advance HERE by one byte. |
| `forget` | `( "<spaces>name" -- )` | Forget `name` and everything defined after it. |
| `words` | `( -- )` | Print all words in the dictionary (space-delimited). |

## Return Stack

| Word | Stack effect | Description |
| --- | --- | --- |
| `>r` | `( x -- )` | Move `x` from the data stack to the return stack. |
| `r>` | `( -- x )` | Move `x` from the return stack to the data stack. |

## Debug

| Word | Stack effect | Description |
| --- | --- | --- |
| `.s` | `( -- )` | Print data stack depth and contents (bottom to top) using `BASE`. |
| `.rs` | `( -- )` | Print return stack depth and contents (bottom to top) using `BASE`. |

## System

| Word | Stack effect | Description |
| --- | --- | --- |
| `bye` | `( -- )` | Exit the interpreter. |
| `syscall` | `( dev cmd param num -- status )` | Invoke ZealOS syscall `num`. Low bytes select device, command, and syscall. |
| `ioctl` | `( dev cmd param -- status )` | Invoke ZealOS syscall 7 (`IOCTL`). |
| `p@` | `( port -- byte )` | Read an unsigned byte (0–255) from a full 16-bit Z80 port address. |
| `p!` | `( byte port -- )` | Write the low byte of a cell to a full 16-bit Z80 port address. |

Port I/O accesses hardware directly, without a ZealOS call. The port address
uses all 16 bits; some Zeal devices use upper address bits when reading.
These words do not select video banks or manage interrupts. Device-specific
Forth helpers must handle those requirements and restore any hardware state
they change.

```forth
hex
00F0 p@ .       \ Read the current MMU page 0 mapping; do not change it.
decimal
```

## Reserved words

Reserved words are primarily compiler/control words (many are compile-only).

| Word | Stack effect | Description |
| --- | --- | --- |
| `if` | `( C: -- orig )` | Compile `branch0` and leave forward patch site. Immediate + compile-only. |
| `else` | `( C: orig1 -- orig2 )` | Compile `branch`, patch `if`, leave new patch site. Immediate + compile-only. |
| `then` | `( C: orig -- )` | Patch `orig` to current `here`. Immediate + compile-only. |
| `begin` | `( C: -- dest )` | Mark loop start. Immediate + compile-only. |
| `until` | `( C: dest -- )` | Compile `branch0` back to `dest`. Immediate + compile-only. |
| `while` | `( C: dest -- dest orig )` | Compile `if` inside a `begin` loop. Immediate + compile-only. |
| `repeat` | `( C: dest orig -- )` | Compile back-edge to `dest`, patch `orig`. Immediate + compile-only. |
| `do` | `( C: -- orig-exit dest )` | Compile counted-loop setup. Unlike `?do`, always enter once. Immediate + compile-only. |
| `?do` | `( C: -- orig-exit dest )` | Compile counted-loop setup with a zero-trip check. Immediate + compile-only. |
| `loop` | `( C: orig-exit dest -- )` | Compile increment/test/back-edge and loop unwind. Immediate + compile-only. |
| `+loop` | `( C: orig-exit dest -- )` | Compile variable-step counted-loop update/test/back-edge and unwind. Immediate + compile-only. Runtime consumes step `( n -- )`. |
| `i` | `( -- n )` | Push current loop index. Reserved runtime word. |
| `does>` | `( -- )` | Split a defining word so created children execute code after `does>`. Immediate + compile-only. Uses return-stack temporaries internally. |
| `;` | `( -- )` | End definition. Immediate + compile-only. |

## Internal control primitives

These are internal asm labels in `src/words/flow.asm`, not dictionary words:

| Label | Effect | Description |
| --- | --- | --- |
| `branch` | `( -- )` | Unconditional jump via inline 16-bit absolute target. |
| `branch0` | `( flag -- )` | Jump to inline target when `flag = 0`; otherwise skip inline target. |

## Stack Effect Symbols

| Symbol | Type | Description | Usage |
| --- | --- | --- | --- |
| `addr` | address | Address to memory | Used for passing addresses of unknown type |
| `a-addr` | aligned address | Address that is aligned for native cells | Used for cell-sized data (@, !) |
| `x-addr` | execution token address | Address of executable code | Used with EXECUTE |
| `c-addr` | character address | Address of characters (bytes) | Used for strings and raw byte buffers |
| `c` | byte | 8-bit char | Used for character data,  high byte of cell is ignored |
| `x` | cell | 16-bit number | Used for cell data |
| `n` | cell | 16-bit number | Undefined |
| `"<spaces>name"` | word | string | used to indicate the word consumes the next word |

## Control Stack Effect Symbols

| Symbol | Type | Description | Usage |
| --- | --- | --- | --- |
| `orig` | addr | Forward branch patch site | Address of inline target cell to patch later |
| `dest` | addr | Backward branch target | Destination address for loop back-edge |
| `orig-exit` | addr | `do` zero-trip exit patch site | Patched by `loop` to unwind path |

## Examples

```forth
\ compute (10 + 3) * 2 -> 26
10 3 + 2 * .
```

```forth
\ integer division and comparison: (20 / 3) = 6 ? true (-1)
20 3 / 6 = .
```

```forth
\ stack juggling: (1 2 3) -> (2 3 1)
1 2 3 rot .s
```

```forth
\ boolean logic on flags (true = -1, false = 0)
5 10 <  3 3 =  and .
```

```forth
\ memory round-trip using HERE and PAD
here 42 swap !  here @ .
pad 65 swap !  pad @ emit
```

```forth
\ define a new word 'square' that squares a number
: square dup * ;
5 square .  \ prints 25
```

```forth
\ define a word that computes the average of two numbers
: average + 2 / ;
10 20 average .  \ prints 15
```

```forth
\ switch numeric input mode
hex EA .      \ prints 234
decimal 234 . \ prints 234
```

## Words defined in forth.fs

These words are not present at boot. They become available only after loading
`forth.fs`, either from command line or with `loadfile "forth.fs"`.

### General-purpose library words

| Word | Stack effect | Description |
| --- | --- | --- |
| `cr` | `( -- )` | Emit a newline (LF). |
| `space` | `( -- )` | Emit a single space. |
| `spaces` | `( n -- )` | Emit `n` spaces. |
| `constant` | `( x "name" -- )` | Define `name` to return `x`. |
| `cell+` | `( a-addr1 -- a-addr2 )` | Advance by one cell. |
| `cell-` | `( a-addr1 -- a-addr2 )` | Move back by one cell. |
| `char+` | `( c-addr1 -- c-addr2 )` | Advance by one byte. |
| `nip` | `( a b -- b )` | Drop the second stack item. |
| `tuck` | `( a b -- b a b )` | Copy top item under the second item. |
| `2swap` | `( a b c d -- c d a b )` | Swap two pairs. |
| `2dup` | `( a b -- a b a b )` | Duplicate the top pair. |
| `2drop` | `( a b -- )` | Drop the top pair. |
| `2r@` | `( -- x1 x2 )` | Copy the top pair from the return stack (R: x1 x2 -- x1 x2). |
| `2@` | `( a-addr -- x1 x2 )` | Fetch two cells. |
| `2!` | `( x1 x2 a-addr -- )` | Store two cells. |
| `<>` | `( n1 n2 -- flag )` | True if not equal. |
| `0=` | `( n -- flag )` | True if zero. |
| `0<` | `( n -- flag )` | True if negative. |
| `0>` | `( n -- flag )` | True if positive. |
| `0<>` | `( n -- flag )` | True if non-zero. |
| `1+` | `( n -- n+1 )` | Increment by one. |
| `1-` | `( n -- n-1 )` | Decrement by one. |
| `free` | `( -- n )` | Remaining free bytes in the heap (`64511 here -`). |
| `seed` | `( -- a-addr )` | Address of random-number state, initialized to `12345`. |
| `rand16` | `( -- u )` | Return next 16-bit pseudorandom value and update `seed`. |
| `marker` | `( -- 0 )` | Placeholder marker word (currently returns 0). |

### ZealOS and screen words

| Word | Stack effect | Description |
| --- | --- | --- |
| `vctl` | `( cmd param -- status )` | Send an `IOCTL` command to standard output. |
| `set-cursor` | `( x y -- )` | Set text cursor coordinates. |
| `get-cursor` | `( -- x y )` | Return text cursor coordinates. |
| `set-colors` | `( bg fg -- )` | Set background and foreground colors. |
| `clrscr` | `( -- )` | Clear screen. |
| `reset-screen` | `( -- )` | Reset screen. |
| `screen-size` | `( -- w h )` | Return screen width and height. |
| `ms` | `( n -- )` | Sleep for `n` milliseconds through ZealOS syscall 18. |

`_cursor_xy` and `_area_buf` are internal storage words used by screen helpers.
They remain dictionary-visible because `forth.fs` creates them.

### Demonstration words

These examples and interactive demos also load into dictionary, but are not
general-purpose library API.

| Word | Stack effect | Description |
| --- | --- | --- |
| `test-begin-until` | `( -- )` | Print 1 through 5 using `begin`/`until`. |
| `test-begin-while-repeat` | `( -- )` | Print 0 through 4 using `begin`/`while`/`repeat`. |
| `counter` | `( limit start -- )` | Print a counted range using `do`/`loop`. |
| `slash` | `( -- c )` | Return slash or backslash at random. |
| `10print` | `( -- )` | Emit 40 rows of 80 random slash characters. |
| `10print-key` | `( -- )` | Emit random slash characters until key press. |
| `wait-key` | `( -- )` | Wait for and discard one key press. |
