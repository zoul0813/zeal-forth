\ Hangman for current Zeal Forth.
\ Assumes forth.fs is loaded (for `constant`, `1+`, `1-`, `cr`, `rand16`).
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/hangman.fs"
\   hangman

5 constant WORD-LEN
6 constant MAX-TRIES
26 constant ALPHA-LEN

create guessed ALPHA-LEN allot

: str, ( c-addr u -- )
  0 do
    dup i + c@ c,
  loop
  drop
;

create W1 s" FORTH" str,
create W2 s" STACK" str,
create W3 s" LOOPS" str,
create W4 s" WORDS" str,

variable secret-ptr
variable tries-left
variable tmp-flag
variable tmp-char
variable tmp-idx

: cls ( -- ) 12 0 do cr loop ;

: gaddr ( idx -- c-addr ) guessed + ;
: g@ ( idx -- n ) gaddr c@ ;
: g! ( n idx -- ) gaddr c! ;

: clear-guessed ( -- )
  ALPHA-LEN 0 do
    0 i g!
  loop
;

: to-upper ( c -- c' )
  dup 97 < if
    \ already not lower-case
  else
    dup 122 > if
      \ outside lower-case
    else
      32 -
    then
  then
;

: alpha? ( c -- flag )
  dup 65 < if
    drop 0
  else
    dup 90 > if drop 0 else drop 1 then
  then
;

: letter-idx ( c -- idx ) 65 - ;

: choose-secret ( -- )
  rand16 4 mod
  dup 0 = if
    drop W1 secret-ptr !
  else
    dup 1 = if
      drop W2 secret-ptr !
    else
      dup 2 = if
        drop W3 secret-ptr !
      else
        drop W4 secret-ptr !
      then
    then
  then
;

: in-secret? ( c -- flag )
  tmp-char !
  0 tmp-flag !
  WORD-LEN 0 do
    secret-ptr @ i + c@
    tmp-char @ =
    if
      1 tmp-flag !
    then
  loop
  tmp-flag @
;

: solved? ( -- flag )
  1 tmp-flag !
  WORD-LEN 0 do
    secret-ptr @ i + c@
    letter-idx g@
    0 =
    if
      0 tmp-flag !
    then
  loop
  tmp-flag @
;

: show-word ( -- )
  WORD-LEN 0 do
    secret-ptr @ i + c@
    dup letter-idx g@
    if
      emit
    else
      drop 95 emit      \ _
    then
    32 emit
  loop
  cr
;

: show-used ( -- )
  ." Used: "
  ALPHA-LEN 0 do
    i g@ if
      i 65 + emit
      32 emit
    then
  loop
  cr
;

: prompt-guess ( -- c valid quit )
  ." Guess a letter (A-Z) or q to quit: "
  key dup emit cr
  to-upper
  dup 81 = if
    drop
    0 0 1
  else
    dup alpha? if
      dup letter-idx dup tmp-idx ! g@
      if
        drop drop
        ." Already guessed." cr
        0 0 0
      else
        1 tmp-idx @ g!
        1 0
      then
    else
      drop
      ." Invalid input." cr
      0 0 0
    then
  then
;

: hangman ( -- )
  clear-guessed
  choose-secret
  MAX-TRIES tries-left !
  begin
    cls
    ." HANGMAN" cr
    ." Tries left:" cr
    tries-left @ .
    show-word
    show-used

    prompt-guess
    if                       \ quit?
      drop                   \ drop valid
      drop                   \ drop c
      ." Quit." cr
      1
    else
      if                     \ valid?
        dup in-secret? if
          ." Good guess." cr
        else
          ." Miss." cr
          tries-left @ 1- tries-left !
        then
        drop
        solved? if
          cls
          ." You win! Word: " secret-ptr @ WORD-LEN type cr
          1
        else
          tries-left @ 0 = if
            cls
            ." You lose. Word: " secret-ptr @ WORD-LEN type cr
            1
          else
            0
          then
        then
      else
        drop                 \ drop c
        0
      then
    then
  until
;
