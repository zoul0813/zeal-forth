# TODO List

Here are high‑value core words (grouped) that make a Forth feel “complete” fast. I’d start with the top block, then branch based on your goals.

## Notes

Items marked with `🇫` are implemented in forth.fs

Items marked with `❓` may or may not be defined

## Data stack basics

* [x] dup       `( n -- n n )`
* [x] drop      `( n -- )`
* [x] swap      `( a b -- b a )`
* [x] over      `( a b -- a b a )`
* [x] rot       `( a b c -- b c a )`
* [x] wipe      `( -- )`
* [x] nip       🇫 `( a b -- b )`
* [x] tuck      🇫 `( a b -- b a b )`

## Double-cell stack

* [x] 2swap     🇫 `( a b c d -- c d a b )`
* [x] 2dup      🇫 `( a b -- a b a b )`
* [x] 2drop     🇫 `( a b -- )`
* [x] 2r@       🇫 `( -- x1 x2 )` | copy top pair from return stack
* [x] 2@        🇫 `( a-addr -- x1 x2 )`
* [x] 2!        🇫 `( x1 x2 a-addr -- )`

## Comparisons + logic

* [x] =         `( n1 n2 -- flag )`
* [x] <>        🇫 `( n1 n2 -- flag )`
* [x] <         `( n1 n2 -- flag )`
* [x] >         `( n1 n2 -- flag )`
* [x] u<        `( u1 u2 -- flag )`
* [x] u>        `( u1 u2 -- flag )`
* [x] 0=        🇫 `( n -- flag )`
* [x] 0<        🇫 `( n -- flag )`
* [x] 0>        🇫 `( n -- flag )`
* [x] and       `( n1 n2 -- n3 )`
* [x] or        `( n1 n2 -- n3 )`
* [x] xor       `( n1 n2 -- n3 )`
* [x] invert    `( n -- n2 )`

## Control flow

* [x] if        `( flag -- )`
* [x] else      `( -- )`
* [x] then      `( -- )`
* [x] begin     `( -- )`
* [x] until     `( flag -- )`
* [x] while     `( flag -- )`
* [x] repeat    `( -- )`
* [x] do        `( limit start -- )`
* [x] loop      `( -- )`
* [x] +loop     `( n -- )`
* [x] i         `( -- n )`
* [ ] j         `( -- n )` | [if you add a return stack model]

## Defining words

* [x] :         `( "<spaces>name" -- )`
* [x] ;         `( -- )`
* [x] ,         `( x -- )`
* [x] c,        `( c -- )`
* [x] constant  🇫 `( x "<spaces>name" -- )`
* [x] variable  `( "<spaces>name" -- )`
* [x] create    `( "<spaces>name" -- )`
* [x] does>     `( -- )`
* [x] allot     `( n -- )`
* [x] state     `( -- a-addr )` | a-addr is the address of a cell containing the compilation state flag
* [x] base      `( -- a-addr )` | a-addr is the address of a cell containing the current numeric input base
* [x] hex       `( -- )` | set `BASE` to 16 (immediate)
* [x] decimal   `( -- )` | set `BASE` to 10 (immediate)
* [x] execute   `( x-addr -- )` | execute code at x-addr

## Memory + bytes

* [x] @         `( a-addr -- x )`
* [x] !         `( x a-addr -- )`
* [x] c@        `( c-addr -- c )`
* [x] c!        `( n c-addr -- )`
* [x] cells     `( n1 -- n2 )`
* [x] here      `( -- a-addr )`
* [x] pad       `( -- c-addr )`
* [x] cell+     🇫 `( a-addr1 -- a-addr2 )`
* [x] cell-     🇫 `( a-addr1 -- a-addr2 )`
* [x] char+     🇫 `( c-addr1 -- c-addr2 )`
* [ ] move      `( addr1 addr2 u -- )` | memcpy(addr2, addr1, u)
* [ ] fill      `( c-addr u char -- )` | memset(c-addr, char, u)
* [ ] erase     `( addr u -- )` | memset(addr, 0, u)

## Math

* [x] +         `( n1 n2 -- n1+n2 )`
* [x] -         `( n1 n2 -- n1-n2 )`
* [x] *         `( n1 n2 -- n1*n2 )`
* [x] /         `( n1 n2 -- n3 )`
* [x] mod       `( n1 n2 -- n3 )`
* [x] abs       `( n -- u )`
* [x] negate    `( n -- -n )`
* [ ] */        ❓`( n1 n2 n3 -- n4 )`
* [ ] */mod     ❓`( n1 n2 n3 -- n4 n5 )`
* [x] /mod      `( n1 n2 -- n3 n4 )`
* [x] u/        `( u1 u2 -- u3 )`
* [x] umod      `( u1 u2 -- u3 )`
* [x] u/mod     `( u1 u2 -- u-rem u-quot )`
* [ ] um*       `( u1 u2 -- ud )`
* [ ] um/mod    `( ud u -- u-rem u-quot )`

## I/O + text

* [x] .         `( n -- )`
* [x] emit      `( c -- )`
* [x] \         `( -- )` | discard the remainder of the input buffer
* [x] cr        `( -- )`
* [x] space     🇫 `( -- )`
* [x] spaces    🇫 `( n -- )`
* [x] ."        `( "ccc<quote>" -- )`
* [x] type      `( c-addr n -- )`
* [x] key?      `( -- flag )` | non-blocking key probe, buffers one key for `key`
* [x] key       `( -- c )`

## Dictionary/introspection

* [x] .s        `( -- )`
* [x] words     `( -- )`
* [ ] '         `( "<spaces>name" -- xt )` | (tick: get execution token)

## System

* [x] bye       `( -- )`
* [x] free      🇫 `( -- n )` | remaining bytes in heap
* [x] marker    🇫 `( -- 0 )` | placeholder marker word (currently returns 0)
* [x] syscall   `( n -- )` | execute syscall n, additional stack params may be required as defined by syscall
* [x] ioctl     `( dev c de -- )` | ioctl(dev, c, de)
* [x] loadfile  `( "ccc<quote>" -- )` | Read and parse forth file
