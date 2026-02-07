\ Wordle-style game for current Zeal Forth.
\ Assumes forth.fs is loaded (for `constant`, `1+`, `1-`, `cr`, `rand16`).
\
\ Feedback:
\ - Green  letter: correct spot
\ - Yellow letter: in word, wrong spot
\ - Gray   .      : not in word
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/wordle.fs"
\   wordle

5 constant WORD-LEN
32 constant MAX-WORDS
6 constant MAX-TRIES
26 constant ALPHA-LEN
30 constant BOARD-CELLS
0 constant COLOR-BG
15 constant COLOR-DEFAULT
10 constant COLOR-GREEN
14 constant COLOR-YELLOW
8 constant COLOR-GRAY

create gbuf WORD-LEN allot
create mbuf WORD-LEN allot
create hguess BOARD-CELLS allot
create hmark BOARD-CELLS allot
create scount ALPHA-LEN allot

create WORDS MAX-WORDS WORD-LEN * allot
variable WORD-COUNT
variable srcp
variable dstp

variable secret-ptr
variable tries-used
variable tmp-flag
variable draw-row
variable row-save
variable idx-save

: cls ( -- ) clrscr ;

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

: word-ptr ( idx -- c-addr )
  WORD-LEN * WORDS +
;

: add-word ( c-addr u -- ok )
  dup WORD-LEN = if
    drop
    WORD-COUNT @ MAX-WORDS < if
      srcp !
      WORD-COUNT @ word-ptr dstp !
      WORD-LEN 0 do
        srcp @ i + c@
        dstp @ i + c!
      loop
      WORD-COUNT @ 1+ WORD-COUNT !
      1
    else
      drop
      0
    then
  else
    drop drop
    0
  then
;

0 WORD-COUNT !
s" STACK" add-word drop
s" LOOPS" add-word drop
s" WORDS" add-word drop
s" MACRO" add-word drop
s" CELLS" add-word drop
s" BASIC" add-word drop
s" BYTES" add-word drop
s" CLOCK" add-word drop
s" DEBUG" add-word drop
s" FLAGS" add-word drop
s" INDEX" add-word drop
s" INPUT" add-word drop
s" LOGIC" add-word drop
s" MICRO" add-word drop
s" MODEM" add-word drop
s" MOUSE" add-word drop
s" PIXEL" add-word drop
s" RESET" add-word drop
s" CACHE" add-word drop
s" DRIVE" add-word drop
s" TOKEN" add-word drop
s" ASCII" add-word drop
s" PATCH" add-word drop
s" CODES" add-word drop
s" ARRAY" add-word drop
s" ROBOT" add-word drop
s" TURBO" add-word drop
s" CABLE" add-word drop
s" ZILOG" add-word drop
s" CHIPS" add-word drop

: choose-secret ( -- ok )
  WORD-COUNT @ dup 0 = if
    drop
    0
  else
    rand16 swap mod
    word-ptr secret-ptr !
    1
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

: draw-board-body ( -- )
  ." WORDLE (5 letters, 6 tries)" cr
  ." Green=right, yellow=present, gray=absent" cr
  cr
  MAX-TRIES 0 do
    i draw-row !
    draw-row @ tries-used @ < if
      WORD-LEN 0 do
        draw-row @ i hidx dup idx-save !
        idx-save @ hmark@
        dup 2 = if
          drop
          COLOR-BG COLOR-GREEN set-colors
          idx-save @ hguess@ emit
        else
          dup 1 = if
            drop
            COLOR-BG COLOR-YELLOW set-colors
            idx-save @ hguess@ emit
          else
            drop
            COLOR-BG COLOR-GRAY set-colors
            46 emit
          then
        then
        32 emit
        COLOR-BG COLOR-DEFAULT set-colors
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

: draw-board ( -- )
  cls
  draw-board-body
;

: draw-board-final ( -- )
  clrscr
  draw-board-body
;

: show-secret ( -- )
  secret-ptr @ WORD-LEN type
;

: wordle ( -- )
  choose-secret if
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
          draw-board-final
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
  else
    ." No words in dictionary." cr
  then
;
