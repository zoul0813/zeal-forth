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
| `negate` | `( n -- -n )` | Two's-complement negation. |
| `abs` | `( n -- u )` | Absolute value. |
| `dup` | `( n -- n n )` | Duplicate the top stack item. |
| `drop` | `( n -- )` | Drop the top stack item. |
| `@` | `( a-addr -- x )` | Fetch a 16-bit cell from memory. |
| `!` | `( x a-addr -- )` | Store a 16-bit cell to memory. |
| `here` | `( -- a-addr )` | Return the current HERE pointer. |
| `pad` | `( -- c-addr )` | Return a transient buffer at `HERE + 256`. |
| `emit` | `( c -- )` | Output the low byte of `c` as a character. |

## Stack Effect Symbols

| Symbol | Type | Description | Usage |
| --- | --- | --- | --- |
| `addr` | address | Address to memory | Used for passing addresses of unknown type |
| `a-addr` | aligned address | Address that is aligned for native cells | Used for cell-sized data (@, !) |
| `x-addr` | execution token address | Address of executable code | Used with EXECUTE |
| `c-addr` | character address | Address of characters (bytes) | Used for strings and raw byte buffers |
| `c` | 8-bit char, high byte of cell is ignored | Used for character data |

## Examples

```forth
1 2 + .
```

```forth
10 dup .s
```

```forth
1234 32768 !  32768 @ .
```

Note: numeric input is decimal only.
