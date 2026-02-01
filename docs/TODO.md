# TODO List

Here are high‑value core words (grouped) that make a Forth feel “complete” fast. I’d start with the top block, then branch based on your goals.

## Notes

Items marked with `-` will be implemented in Forth, and not defined as built-in words.

Items marked with `f` are implemented in forth.fs

Items marked with `?` may or may not be defined

Items marked with `/` are partially implemented

## Data stack basics

* [x] dup       `( n -- n n )`
* [x] drop      `( n -- )`
* [x] swap      `( a b -- b a )`
* [x] over      `( a b -- a b a )`
* [x] rot       `( a b c -- b c a )`
* [x] wipe      `( -- )`
* [f] nip       `( a b -- b )`
* [f] tuck      `( a b -- b a b )`

## Comparisons + logic

* [x] =         `( n1 n2 -- flag )`
* [f] <>        `( n1 n2 -- flag )`
* [x] <         `( n1 n2 -- flag )`
* [x] >         `( n1 n2 -- flag )`
* [f] 0=        `( n -- flag )`
* [f] 0<        `( n -- flag )`
* [f] 0>        `( n -- flag )`
* [x] and       `( n1 n2 -- n3 )`
* [x] or        `( n1 n2 -- n3 )`
* [x] xor       `( n1 n2 -- n3 )`
* [x] invert    `( n -- n2 )`

## Control flow

* [ ] if        `( flag -- )`
* [ ] else      `( -- )`
* [ ] then      `( -- )`
* [ ] begin     `( -- )`
* [ ] until     `( flag -- )`
* [ ] while     `( flag -- )`
* [ ] repeat    `( -- )`
* [ ] do        `( limit start -- )`
* [ ] loop      `( -- )`
* [ ] +loop     `( n -- )`
* [ ] i         `( -- n )`
* [ ] j         `( -- n )` | [if you add a return stack model]

## Defining words

* [x] :         `( "<spaces>name" -- )`
* [x] ;         `( -- )`
* [x] ,         `( x -- )`
* [x] c,        `( c -- )`
* [ ] constant  `( x "<spaces>name" -- )`
* [x] variable  `( "<spaces>name" -- )`
* [x] create    `( "<spaces>name" -- )`
* [ ] does>     `( -- )`
* [x] allot     `( n -- )`
* [x] state     `( -- a-addr )` | a-addr is the address of a cell containing the compilation state flag
* [x] execute   `( x-addr -- )` | execute code at x-addr

## Memory + bytes

* [x] @         `( a-addr -- x )`
* [x] !         `( x a-addr -- )`
* [x] c@        `( c-addr -- c )`
* [x] c!        `( n c-addr -- )`
* [x] cells     `( n1 -- n2 )`
* [x] here      `( -- a-addr )`
* [x] pad       `( -- c-addr )`
* [f] cell+     `( a-addr1 -- a-addr2 )`
* [f] cell-     `( a-addr1 -- a-addr2 )`
* [f] char+     `( c-addr1 -- c-addr2 )`
* [ ] move      `( addr1 addr2 u -- )` | memcpy(addr2, addr1, u)
* [ ] fill      `( c-addr u char -- )` | memset(c-addr, char, u)
* [-] erase     `( addr u -- )` | memset(addr, 0, u)

## Math

* [x] +         `( n1 n2 -- n1+n2 )`
* [x] -         `( n1 n2 -- n1-n2 )`
* [x] *         `( n1 n2 -- n1*n2 )`
* [x] /         `( n1 n2 -- n3 )`
* [x] mod       `( n1 n2 -- n3 )`
* [x] abs       `( n -- u )`
* [x] negate    `( n -- -n )`
* [?] */        `( n1 n2 n3 -- n4 )`
* [?] */mod     `( n1 n2 n3 -- n4 n5 )`
* [ ] /mod      `( n1 n2 -- n3 n4 )`
* [ ] u<        `( u1 u2 -- flag )`
* [ ] u>        `( u1 u2 -- flag )`
* [ ] um*       `( u1 u2 -- ud )`
* [ ] um/mod    `( ud u -- u-rem u-quot )`

## I/O + text

* [x] .         `( n -- )`
* [x] emit      `( c -- )`
* [x] \         `( -- )` | discard the remainder of the input buffer
* [f] cr        `( -- )`
* [f] space     `( -- )`
* [-] spaces    `( n -- )`
* [x] ."        `( "ccc<quote>" -- )`
* [x] type      `( c-addr n -- )`
* [ ] key       `( -- c )`

## Dictionary/introspection

* [x] .s        `( -- )`
* [x] words     `( -- )`
* [ ] '         `( "<spaces>name" -- xt )` | (tick: get execution token)

## System

* [x] bye       `( -- )`
* [ ] syscall   `( n -- )` | execute syscall n, additional stack params may be required as defined by syscall
* [ ] ioctl     `( dev c de -- )` | ioctl(dev, c, de)
