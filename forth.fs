\ Forth in Forth

." Loading forth.fs "

\ Text words

: cr 10 emit ;
: space 32 emit ;

." . "

\ Cell Words

: cell+ 1 cells + ;
: cell- 1 cells - ;
: char+ 1 + ;

." . "

\ Stack words

: nip swap drop ;
: tuck swap over ;
: 2swap rot >r rot r> ;
: 2dup over over ;
: 2drop drop drop ;
: 2r@ r> r> 2dup >r >r swap ;
: 2@ dup cell+ @ swap @ ;
: 2! swap over ! cell+ ! ;


." . "

\ Conditional words

: <> = invert ;
: 0= 0 = ;
: 0< 0 < ;
: 0> 0 > ;
: 0<> 0 <> ;

." . "

\ Math helpers

: 1+ 1 + ;
: 1- 1 - ;

." . "

." Done." cr