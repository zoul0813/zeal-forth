# Built-in words

The following words are built into the interpreter at boot. Stack effects
use the Forth convention `( before -- after )`.

| Word | Stack effect | Description |
| --- | --- | --- |
| `bye` | `( -- )` | Exit the interpreter. |
| `.` | `( n -- )` | Print `n` in free-field decimal format followed by a newline. |
| `.s` | `( -- )` | Print stack depth and contents (bottom to top). |
| `."` | `( -- )` | Print string following the word, until ending `"`. |
| `+` | `( n1 n2 -- n1+n2 )` | Add the top two stack items (16-bit wraparound). |
| `-` | `( n1 n2 -- n1-n2 )` | Subtract the top two stack items (16-bit wraparound). |
| `*` | `( n1 n2 -- n1*n2 )` | Multiply the top two stack items (16-bit wraparound). |
| `/` | `( n1 n2 -- n3 )` | Divide `n1` by `n2` (unsigned), returns the quotient. |
| `mod` | `( n1 n2 -- n3 )` | Divide `n1` by `n2` (unsigned), returns the remainder. |
| `=` | `( n1 n2 -- flag )` | True if equal. |
| `<` | `( n1 n2 -- flag )` | True if `n1 < n2` (unsigned). |
| `>` | `( n1 n2 -- flag )` | True if `n1 > n2` (unsigned). |
| `and` | `( n1 n2 -- n3 )` | Bitwise AND. |
| `or` | `( n1 n2 -- n3 )` | Bitwise OR. |
| `xor` | `( n1 n2 -- n3 )` | Bitwise XOR. |
| `invert` | `( n -- n2 )` | Bitwise NOT. |
| `negate` | `( n -- -n )` | Two's-complement negation. |
| `abs` | `( n -- u )` | Absolute value. |
| `drop` | `( n -- )` | Drop the top stack item. |
| `dup` | `( n -- n n )` | Duplicate the top stack item. |
| `swap` | `( n1 n2 -- n2 n1 )` | Swap the top two stack items. |
| `over` | `( n1 n2 -- n1 n2 n1 )` | Copy the second item to the top. |
| `rot` | `( n1 n2 n3 -- n2 n3 n1 )` | Rotate the top three items. |
| `wipe` | `( -- )` | Reset the data stack pointer. |
| `@` | `( a-addr -- x )` | Fetch a 16-bit cell from memory. |
| `c@` | `( c-addr -- c )` | Fetch a char from c-addr |
| `!` | `( x a-addr -- )` | Store a 16-bit cell to memory. |
| `c!` | `( n c-addr -- )` | Store char n in a-addr |
| `emit` | `( c -- )` | Output the low byte of `c` as a character. |
| `type` | `( c-addr n -- )` | Output the string specified in c-addr, using n for size |
| `(` | `( -- )` | Discard input until the next `)` (comment). |
| `words` | `( -- )` | Print all words in the dictionary. |
| `here` | `( -- a-addr )` | Return the current HERE pointer. |
| `pad` | `( -- c-addr )` | Return a transient buffer at `HERE + 256`. |
| `cells` | `( n1 -- n2 )` | Convert a cell count to bytes (n * cell size). |
| `allot` | `( n -- )` | Reserve `n` bytes starting at HERE. |
| `variable` | `( "name" -- )` | Define a word that pushes its storage address and allocates 1 cell. |
| `create` | `( "name" -- )` | Define a word that pushes its storage address. |
| `:` | `( "<spaces>name" -- )` | Start compiling a new word definition. Switches to compile mode. |
| `;` | `( -- )` | End the current word definition and return to immediate mode. |
| `\` | `( -- )` | Discard the remainder of the input buffer. |
| `state` | `( -- a-addr )` | a-addr is the address of a cell containing the compilation-state flag |
| `execute` | `( x-addr -- )` | c-addr is the address to begin execution of |
| `,` | `( x -- )` | store x at here, and advance here 1 cell |
| `c,` | `( c -- )` | store c at here, and advance here 1 byte |
| `forget` | `( "<spaces>name" -- )` | Forget name |
| `>r` | `( x -- )` | Move x from the data stack to the return stack. |
| `r>` | `( -- x )` | Move x from the return stack to the data stack. |
| `.rs` | `( -- )` | Print return stack depth and contents (bottom to top). |

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

Note: `forth.fs` also defines a handful of temporary/dummy words for
dictionary stress testing (e.g. `x`, `y`, `z`, `foo`, `bar`), which are
omitted here.
