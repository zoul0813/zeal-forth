\ Wordle-style game for current Zeal Forth.
\ Assumes forth.fs is loaded (for `constant`, `1+`, `1-`, `cr`, `rand16`).
\
\ Feedback:
\ - Uppercase letter: correct spot (green)
\ - Lowercase letter: in word, wrong spot (yellow)
\ - . : not in word (gray)
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/wordle.fs"
\   wordle

5 constant WORD-LEN
6 constant MAX-TRIES
26 constant ALPHA-LEN
30 constant BOARD-CELLS

create gbuf WORD-LEN allot
create mbuf WORD-LEN allot
create hguess BOARD-CELLS allot
create hmark BOARD-CELLS allot
create scount ALPHA-LEN allot

create W1 83 c, 84 c, 65 c, 67 c, 75 c,   \ STACK
create W2 76 c, 79 c, 79 c, 80 c, 83 c,   \ LOOPS
create W3 87 c, 79 c, 82 c, 68 c, 83 c,   \ WORDS
create W4 77 c, 65 c, 67 c, 82 c, 79 c,   \ MACRO
create W5 67 c, 69 c, 76 c, 76 c, 83 c,   \ CELLS
create W6 66 c, 82 c, 65 c, 78 c, 67 c,   \ BRANC

variable secret-ptr
variable tries-used
variable tmp-flag
variable draw-row
variable row-save
variable idx-save

: cls ( -- ) 12 0 do cr loop ;

: gaddr ( idx -- c-addr ) gbuf + ;
: gbuf@ ( idx -- n ) gaddr c@ ;
: gbuf! ( n idx -- ) gaddr c! ;

: maddr ( idx -- c-addr ) mbuf + ;
: mbuf@ ( idx -- n ) maddr c@ ;
: mbuf! ( n idx -- ) maddr c! ;

: hgaddr ( idx -- c-addr ) hguess + ;
: hguess@ ( idx -- n ) hgaddr c@ ;
: hguess! ( n idx -- ) hgaddr c! ;

: hmaddr ( idx -- c-addr ) hmark + ;
: hmark@ ( idx -- n ) hmaddr c@ ;
: hmark! ( n idx -- ) hmaddr c! ;

: saddr ( idx -- c-addr ) scount + ;
: scount@ ( idx -- n ) saddr c@ ;
: scount! ( n idx -- ) saddr c! ;

: scount++ ( idx -- )
  dup scount@ 1+ swap scount!
;

: hidx ( row col -- idx )
  swap WORD-LEN * +
;

: to-upper ( c -- c' )
  dup 97 < if
  else
    dup 122 > if
    else
      32 -
    then
  then
;

: to-lower ( c -- c' )
  dup 65 < if
  else
    dup 90 > if
    else
      32 +
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
  rand16 6 mod
  dup 0 = if
    drop W1 secret-ptr !
  else
    dup 1 = if
      drop W2 secret-ptr !
    else
      dup 2 = if
        drop W3 secret-ptr !
      else
        dup 3 = if
          drop W4 secret-ptr !
        else
          dup 4 = if
            drop W5 secret-ptr !
          else
            drop W6 secret-ptr !
          then
        then
      then
    then
  then
;

: clear-counts ( -- )
  ALPHA-LEN 0 do
    0 i scount!
  loop
;

: clear-history ( -- )
  BOARD-CELLS 0 do
    0 i hguess!
    0 i hmark!
  loop
;

: read-guess ( -- valid )
  1 tmp-flag !
  ." Guess (5 letters): "
  WORD-LEN 0 do
    key to-upper dup emit
    dup alpha? if
      dup i gbuf!
    else
      drop
      0 tmp-flag !
      65 i gbuf!
    then
  loop
  cr
  tmp-flag @
;

: eval-guess ( -- )
  clear-counts

  \ pass 1: mark greens, count unmatched secret letters
  WORD-LEN 0 do
    secret-ptr @ i + c@
    i gbuf@
    2dup = if
      2drop
      2 i mbuf!
    else
      drop
      0 i mbuf!
      letter-idx scount++
    then
  loop

  \ pass 2: mark yellows using remaining counts
  WORD-LEN 0 do
    i mbuf@ 2 = if
    else
      i gbuf@ letter-idx dup
      scount@ dup 0 > if
        drop
        1 i mbuf!
        dup scount@ 1- swap scount!
      else
        drop drop
      then
    then
  loop
;

: guess-correct? ( -- flag )
  1 tmp-flag !
  WORD-LEN 0 do
    i mbuf@ 2 = if
    else
      0 tmp-flag !
    then
  loop
  tmp-flag @
;

: save-row ( row -- )
  row-save !
  WORD-LEN 0 do
    row-save @ i hidx dup idx-save !
    i gbuf@ idx-save @ hguess!
    i mbuf@ idx-save @ hmark!
  loop
;

: draw-board ( -- )
  cls
  ." WORDLE (5 letters, 6 tries)" cr
  ." Upper=right, lower=present, .=absent" cr
  cr
  MAX-TRIES 0 do
    i draw-row !
    draw-row @ tries-used @ < if
      WORD-LEN 0 do
        draw-row @ i hidx dup idx-save !
        idx-save @ hmark@
        dup 2 = if
          drop
          idx-save @ hguess@ emit
        else
          dup 1 = if
            drop
            idx-save @ hguess@ to-lower emit
          else
            drop
            46 emit
          then
        then
        32 emit
      loop
    else
      WORD-LEN 0 do
        95 emit
        32 emit
      loop
    then
    cr
  loop
  cr
;

: show-secret ( -- )
  secret-ptr @ WORD-LEN type
;

: wordle ( -- )
  choose-secret
  clear-history
  0 tries-used !
  begin
    draw-board
    tries-used @ MAX-TRIES = if
      ." You lose. Word was: " show-secret cr
      1
    else
      read-guess if
        eval-guess
        tries-used @ save-row
        tries-used @ 1+ tries-used !
        guess-correct? if
          draw-board
          ." You win!" cr
          1
        else
          0
        then
      else
        ." Invalid guess: letters A-Z only." cr
        0
      then
    then
  until
;
