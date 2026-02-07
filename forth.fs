\ Forth in Forth

." Loading forth.fs "

\ Defining words
: constant create , does> @ ;

\ Text words

: cr 10 emit ;
: space 32 emit ;

\ Cell Words

: cell+ 1 cells + ;
: cell- 1 cells - ;
: char+ 1 + ;

\ Stack words

: nip swap drop ;
: tuck swap over ;
: 2swap rot >r rot r> ;
: 2dup
over over ;

: 2drop drop drop ;
: 2r@ r> r> 2dup >r >r swap ;
: 2@ dup cell+ @ swap @ ;
: 2! swap over ! cell+ ! ;

\ Conditional words

: <> = invert ;
: 0= 0 = ;
: 0< 0 < ;
: 0> 0 > ;
: 0<> 0 <> ;

\ Math helpers

: 1+ 1 + ;
: 1- 1 - ;
\ next buffer

\ System ( -- n )
: free 64511 here - ;

: marker 0 ; \ forget this and drop everything below

: test-begin-until ( -- )
  0
  begin
    1 +
    dup .
    dup 5 =
  until
;
\ 
: test-begin-while-repeat ( -- )
  0
  begin
    dup 5 <
  while
    dup .
    1 +
  repeat
  drop
;

: counter ( limit start -- )
  do
    i .
  loop
;

variable seed
12345 seed !

: rand16  ( -- u )
  seed @ 25173 * 13849 + dup seed ! ;

: slash   ( -- c )
  rand16 1 and if 47 else 92 then ;        
  \ '/' or '\'

: tenprint ( -- )
  begin
    slash emit
    0 until    \ infinite loop
;


." Done." cr