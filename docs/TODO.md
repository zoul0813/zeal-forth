# TODO List

Here are high‑value core words (grouped) that make a Forth feel “complete” fast. I’d start with the top block, then branch based on your goals.

## Notes

Items marked with `-` will be implemented in Forth, and not defined as built-in words.

Items marked with `?` may or may not be defined

## Data stack basics

* [x] swap ( a b -- b a )
* [x] over ( a b -- a b a )
* [x] rot ( a b c -- b c a )
* [-] nip ( a b -- b )
* [-] tuck ( a b -- b a b )

## Comparisons + logic

* [x] =
* [x] <>
* [x] <
* [x] >
* [-] 0=
* [-] 0<
* [-] 0>
* [x] and ( n1 n2 -- n3 )
* [x] or  ( n1 n2 -- n3 )
* [x] xor ( n1 n2 -- n3 )
* [x] invert

## Control flow

* [ ] if
* [ ] else
* [ ] then
* [ ] begin until
* [ ] begin while
* [ ] repeat
* [ ] do
* [ ] loop
* [ ] +loop
* [ ] i
* [ ] j (if you add a return stack model)

## Defining words

* [ ] :
* [ ] ;
* [ ] constant
* [x] variable
* [x] create
* [ ] does> (later; powerful but more complex)
* [x] allot

## Memory + bytes

* [ ] c@
* [ ] c! (byte fetch/store)
* [x] cells
* [-] cell+
* [-] cell-
* [-] char+
* [ ] move
* [ ] fill
* [ ] erase

## Math

* [x] * ( n n -- n)
* [x] / ( n n -- n )
* [x] mod ( n n -- n )
* [?] */
* [?] */mod
* [ ] /mod
* [ ] u<
* [ ] u>
* [ ] um*
* [ ] um/mod (unsigned)

## I/O + text

* [ ] cr
* [ ] (newline)
* [ ] space
* [ ] spaces

* [ ] .\" (print string literal), type (print buffer)
* [ ] key
* [x] emit

## Dictionary/introspection

* [x] words (list dictionary)
* [ ] ' (tick: get execution token)