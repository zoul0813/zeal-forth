\ Snake-lite for current Zeal Forth.
\ Uses one-line redraw (carriage return) since cursor positioning is not available.
\
\ Requires:
\   loadfile "forth.fs"
\
\ Run:
\   loadfile "snake.fs"
\   snake

80 constant WIDTH
32 constant MAXLEN

create snake-body MAXLEN cells allot

variable snake-len
variable snake-dir
variable food-pos
variable snake-quit
variable tmp-hit
variable scan-start
variable rev-i
variable rev-j
variable rev-a
variable rev-b

: >body ( idx -- addr ) cells snake-body + ;
: body@ ( idx -- n ) >body @ ;
: body! ( n idx -- ) >body ! ;

: head-pos ( -- n ) snake-len @ 1 - body@ ;

: wrap-x ( n -- n' )
  dup 0 < if
    drop WIDTH 1 -
  else
    dup WIDTH = if drop 0 then
  then
;

: is-snake? ( x -- flag )
  0 tmp-hit !
  snake-len @ 0 ?do
    dup i body@ = if 1 tmp-hit ! then
  loop
  drop
  tmp-hit @
;

: collides-from ( pos start -- flag )
  scan-start !
  0 tmp-hit !
  snake-len @ scan-start @ ?do
    dup i body@ = if 1 tmp-hit ! then
  loop
  drop
  tmp-hit @
;

: place-food ( -- )
  begin
    rand16 WIDTH mod
    dup is-snake?
    if
      drop 0
    else
      food-pos !
      1
    then
  until
;

: snake-init ( -- )
  3 snake-len !
  1 snake-dir !
  0 snake-quit !
  10 0 body!
  11 1 body!
  12 2 body!
  place-food
;

: draw-snake ( -- )
  13 emit
  WIDTH 0 ?do
    i head-pos = if
      64 emit            \ @
    else
      i food-pos @ = if
        42 emit          \ *
      else
        i is-snake? if 111 emit else 46 emit then   \ o or .
      then
    then
  loop
;

: shift-left ( -- )
  snake-len @ 1 - 0 ?do
    i 1 + body@ i body!
  loop
;

: reverse-body ( -- )
  snake-len @ 2 / 0 ?do
    i rev-i !
    snake-len @ 1 - i - rev-j !
    rev-i @ body@ rev-a !
    rev-j @ body@ rev-b !
    rev-b @ rev-i @ body!
    rev-a @ rev-j @ body!
  loop
;

: step-snake ( -- alive-flag )
  head-pos snake-dir @ + wrap-x
  dup food-pos @ = if
    dup 0 collides-from if
      drop 0
    else
      dup snake-len @ body!
      snake-len @ 1 + snake-len !
      place-food
      drop 1
    then
  else
    dup 1 collides-from if
      drop 0
    else
      shift-left
      dup snake-len @ 1 - body!
      drop 1
    then
  then
;

: handle-input ( -- )
  key? if
    key
    dup 97 = over 65 = or if   \ a/A
      drop
      snake-dir @ 1 = if
        reverse-body
      then
      0 1- snake-dir !
    else
      dup 100 = over 68 = or if   \ d/D
        drop
        snake-dir @ 0 1- = if
          reverse-body
        then
        1 snake-dir !
      else
        dup 113 = over 81 = or if   \ q/Q
          drop 1 snake-quit !
        else
          drop
        then
      then
    then
  then
;

: delay ( -- ) 3000 0 ?do loop ;

: snake ( -- )
  snake-init
  ." Snake-lite: a=left d=right q=quit" cr
  draw-snake
  begin
    handle-input
    snake-quit @ if 0 else step-snake then
  while
    draw-snake
    delay
  repeat
  cr
  ." Game over. Length: " snake-len @ .
;
