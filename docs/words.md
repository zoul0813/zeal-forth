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
| `/` | `( n1 n2 -- n3 )` | Unsigned division. Division by zero returns 0. |
| `mod` | `( n1 n2 -- n3 )` | Unsigned remainder. Division by zero returns 0. |
| `abs` | `( n -- u )` | Absolute value. |
| `negate` | `( n -- -n )` | Two's-complement negation. |

## Compare + Logic

| Word | Stack effect | Description |
| --- | --- | --- |
| `=` | `( n1 n2 -- flag )` | True if equal. |
| `<` | `( n1 n2 -- flag )` | True if `n1 < n2` (unsigned). |
| `>` | `( n1 n2 -- flag )` | True if `n1 > n2` (unsigned). |
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
| `cells` | `( n1 -- n2 )` | Convert a cell count to bytes (`n * 2`). |
| `allot` | `( n -- )` | Reserve `n` bytes starting at HERE. |

## I/O + Text

| Word | Stack effect | Description |
| --- | --- | --- |
| `.` | `( n -- )` | Print `n` in decimal, then a newline. |
| `."` | `( -- )` | Print characters until the next `"`, consuming the input stream. |
| `emit` | `( c -- )` | Output the low byte of `c` as a character. |
| `type` | `( c-addr n -- )` | Output `n` bytes from `c-addr`. |
| `\` | `( -- )` | Discard the remainder of the input buffer. Immediate. |
| `(` | `( -- )` | Discard input until the next `)` (comment). Immediate. |

## Dictionary + Compilation

| Word | Stack effect | Description |
| --- | --- | --- |
| `create` | `( "name" -- )` | Define a word that pushes its storage address. |
| `variable` | `( "name" -- )` | Define a word that pushes its storage address and allocates 1 cell. |
| `:` | `( "<spaces>name" -- )` | Start compiling a new word definition. |
| `;` | `( -- )` | End the current word definition and return to immediate mode. |
| `state` | `( -- a-addr )` | Address of the compilation-state flag. |
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
| `.s` | `( -- )` | Print data stack depth and contents (bottom to top). |
| `.rs` | `( -- )` | Print return stack depth and contents (bottom to top). |

## System

| Word | Stack effect | Description |
| --- | --- | --- |
| `bye` | `( -- )` | Exit the interpreter. |

## Reserved words

Reserved words are compile-only, which includes branching and other compile time words

| Word | Stack effect | Description |
| --- | --- | --- |
| `if` | `( flag -- )` | Compile-time conditional branch. Immediate + compile-only. |
| `else` | `( -- )` | Compile-time branch target for `if`. Immediate + compile-only. |
| `then` | `( -- )` | Close the `if`/`else` block. Immediate + compile-only. |
| `does>` | `( -- )` | Split a defining word so created children execute code after `does>`. Immediate + compile-only. Uses return-stack temporaries internally. |

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

Note: numeric input is decimal only.

## Words defined in forth.fs (when loaded)

The following words are defined in `forth.fs`. They are not built in, but
become available after loading that file.

| Word | Stack effect | Description |
| --- | --- | --- |
| `cr` | `( -- )` | Emit a newline (LF). |
| `space` | `( -- )` | Emit a single space. |
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
| `marker` | `( -- 0 )` | Placeholder marker word (currently returns 0). |

Note: `forth.fs` also defines a handful of temporary/dummy words for
dictionary stress testing (e.g. `x`, `y`, `z`, `foo`, `bar`). These are repeated
many times in the file and are omitted here.
