\ 2D Snake for current Zeal Forth.
\ Requires forth.fs (clrscr, set-cursor, set-colors, rand16, key?).
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/snake.fs"
\   snake

240 constant MAXLEN
150 constant START-DELAY-MS
100 constant MIN-DELAY-MS
25 constant SPEEDUP-STEP-MS
5 constant SPEEDUP-EVERY-FOODS

0 constant COLOR-BG
15 constant COLOR-DEFAULT
7 constant COLOR-BORDER
10 constant COLOR-SNAKE
12 constant COLOR-FOOD
14 constant COLOR-TEXT

create snake-x MAXLEN cells allot
create snake-y MAXLEN cells allot

variable snake-len
variable dir-x
variable dir-y
variable scr-w
variable scr-h
variable play-w
variable play-h
variable food-x
variable food-y
variable snake-quit
variable snake-delay-ms
variable tmp-hit
variable scan-start
variable tmp-x
variable tmp-y
variable next-x
variable next-y
variable old-head-x
variable old-head-y
variable old-tail-x
variable old-tail-y
variable draw-x
variable draw-y
variable draw-ch
variable draw-fg
variable center-x
variable center-y

: sx-addr ( idx -- addr ) cells snake-x + ;
: sy-addr ( idx -- addr ) cells snake-y + ;
: sx@ ( idx -- n ) sx-addr @ ;
: sy@ ( idx -- n ) sy-addr @ ;
: sx! ( n idx -- ) sx-addr ! ;
: sy! ( n idx -- ) sy-addr ! ;

: head-x ( -- n ) snake-len @ 1 - sx@ ;
: head-y ( -- n ) snake-len @ 1 - sy@ ;

: draw-cell ( x y ch fg -- )
  draw-fg !
  draw-ch !
  draw-y !
  draw-x !
  COLOR-BG draw-fg @ set-colors
  draw-x @ 1+ draw-y @ 2 + set-cursor
  draw-ch @ emit
  COLOR-BG COLOR-DEFAULT set-colors
;

: draw-border ( -- )
  clrscr
  COLOR-BG COLOR-TEXT set-colors
  0 0 set-cursor ." Snake 2D: WASD move, Q quit"
  COLOR-BG COLOR-BORDER set-colors

  \ top + bottom border
  play-w @ 2 + 0 ?do
    i 1 set-cursor 35 emit
    i play-h @ 2 + set-cursor 35 emit
  loop

  \ left + right border
  play-h @ 0 ?do
    0 i 2 + set-cursor 35 emit
    play-w @ 1 + i 2 + set-cursor 35 emit
  loop

  COLOR-BG COLOR-DEFAULT set-colors
;

: draw-food ( -- )
  food-x @ food-y @ 42 COLOR-FOOD draw-cell
;

: draw-snake-all ( -- )
  snake-len @ 0 ?do
    i snake-len @ 1 - = if
      i sx@ i sy@ 64 COLOR-SNAKE draw-cell
    else
      i sx@ i sy@ 111 COLOR-SNAKE draw-cell
    then
  loop
;

: is-snake-from ( x y start -- flag )
  scan-start !
  tmp-y !
  tmp-x !
  0 tmp-hit !
  snake-len @ scan-start @ ?do
    tmp-x @ i sx@ = if
      tmp-y @ i sy@ = if
        1 tmp-hit !
      then
    then
  loop
  tmp-hit @
;

: place-food ( -- )
  begin
    rand16 play-w @ mod tmp-x !
    rand16 play-h @ mod tmp-y !
    tmp-x @ tmp-y @ 0 is-snake-from
    if
      0
    else
      tmp-y @ food-y !
      tmp-x @ food-x !
      1
    then
  until
;

: init-field ( -- )
  screen-size
  scr-h !
  scr-w !
  scr-w @ 2 - play-w !
  scr-h @ 3 - play-h !
  play-w @ 10 < if 10 play-w ! then
  play-h @ 6 < if 6 play-h ! then
;

: shift-left-2d ( -- )
  snake-len @ 1 - 0 ?do
    i 1 + sx@ i sx!
    i 1 + sy@ i sy!
  loop
;

: snake-init ( -- )
  3 snake-len !
  1 dir-x !
  0 dir-y !
  0 snake-quit !
  START-DELAY-MS snake-delay-ms !

  play-w @ 2 / center-x !
  play-h @ 2 / center-y !
  center-x @ 2 - 0 sx!   center-y @ 0 sy!
  center-x @ 1- 1 sx!    center-y @ 1 sy!
  center-x @ 2 sx!       center-y @ 2 sy!

  place-food
;

: handle-input ( -- )
  key? if
    key
    dup 97 = over 65 = or if      \ a/A
      drop
      dir-x @ 1 = if else
        0 1- dir-x !
        0 dir-y !
      then
    else
      dup 100 = over 68 = or if   \ d/D
        drop
        dir-x @ 0 1- = if else
          1 dir-x !
          0 dir-y !
        then
      else
        dup 119 = over 87 = or if \ w/W
          drop
          dir-y @ 1 = if else
            0 dir-x !
            0 1- dir-y !
          then
        else
          dup 115 = over 83 = or if \ s/S
            drop
            dir-y @ 0 1- = if else
              0 dir-x !
              1 dir-y !
            then
          else
            dup 113 = over 81 = or if \ q/Q
              drop 1 snake-quit !
            else
              drop
            then
          then
        then
      then
    then
  then
;

: step-snake ( -- alive )
  head-x old-head-x !
  head-y old-head-y !

  old-head-x @ dir-x @ + next-x !
  old-head-y @ dir-y @ + next-y !

  next-x @ 0 < if 0 else
    next-x @ play-w @ < if
      next-y @ 0 < if 0 else
        next-y @ play-h @ < if

          next-x @ food-x @ = next-y @ food-y @ = and if
            next-x @ next-y @ 0 is-snake-from if
              0
            else
              old-head-x @ old-head-y @ 111 COLOR-SNAKE draw-cell
              next-x @ snake-len @ sx!
              next-y @ snake-len @ sy!
              snake-len @ 1+ snake-len !
              next-x @ next-y @ 64 COLOR-SNAKE draw-cell
              place-food
              draw-food
              snake-len @ 3 - SPEEDUP-EVERY-FOODS mod 0= if
                snake-delay-ms @ MIN-DELAY-MS > if
                  snake-delay-ms @ SPEEDUP-STEP-MS - snake-delay-ms !
                then
              then
              1
            then
          else
            next-x @ next-y @ 1 is-snake-from if
              0
            else
              0 sx@ old-tail-x !
              0 sy@ old-tail-y !

              shift-left-2d
              next-x @ snake-len @ 1 - sx!
              next-y @ snake-len @ 1 - sy!

              old-tail-x @ old-tail-y @ 32 COLOR-DEFAULT draw-cell
              old-head-x @ old-head-y @ 111 COLOR-SNAKE draw-cell
              next-x @ next-y @ 64 COLOR-SNAKE draw-cell
              1
            then
          then

        else
          0
        then
      then
    else
      0
    then
  then
;

: delay ( -- )
  snake-delay-ms @ ms
;

: snake ( -- )
  init-field
  snake-init
  draw-border
  draw-snake-all
  draw-food
  begin
    delay
    handle-input
    snake-quit @ if 0 else step-snake then
  while
  repeat
  0 0 set-cursor
  COLOR-BG COLOR-TEXT set-colors
  ." Game over. Length: " snake-len @ .
  COLOR-BG COLOR-DEFAULT set-colors
;
