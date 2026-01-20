# Built-in words

The following words are built into the interpreter at boot. Stack effects
use the Forth convention `( before -- after )`.

| Word | Stack effect | Description |
| --- | --- | --- |
| `bye` | `( -- )` | Exit the interpreter. |
| `.` | `( n -- )` | Print `n` in free-field decimal format followed by a newline. |
| `.s` | `( -- )` | Print stack depth and contents (bottom to top). |
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

## Stack Effect Symbols

| Symbol | Type | Description | Usage |
| --- | --- | --- | --- |
| `addr` | address | Address to memory | Used for passing addresses of unknown type |
| `a-addr` | aligned address | Address that is aligned for native cells | Used for cell-sized data (@, !) |
| `x-addr` | execution token address | Address of executable code | Used with EXECUTE |
| `c-addr` | character address | Address of characters (bytes) | Used for strings and raw byte buffers |
| `c` | byte | 8-bit char, high byte of cell is ignored | Used for character data |
| `x` | cell | Used for cell data | Used for cell data |

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
