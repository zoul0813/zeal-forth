\ Frogger (road-crossing) for current Zeal Forth.
\ Requires forth.fs (clrscr, set-cursor, set-colors, screen-size, ms, key?).
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/frogger.fs"
\   frogger

16 constant MAX-LANES
6 constant ROAD-LANES
48 constant MAX-FIELD-W
8 constant PERIOD
3 constant CAR-LEN
3 constant START-LIVES
5 constant TARGET-WINS
45 constant TICK-MS

0 constant COLOR-BG
15 constant COLOR-DEFAULT
9 constant COLOR-TEXT
7 constant COLOR-BORDER
8 constant COLOR-ROAD
12 constant COLOR-CAR
10 constant COLOR-FROG
14 constant COLOR-GOAL

create lane-off MAX-LANES cells allot
create lane-div MAX-LANES cells allot
create lane-ctr MAX-LANES cells allot
create lane-mov MAX-LANES allot

variable scr-w
variable scr-h
variable goal-y
variable lane-top
variable start-y
variable lane-count

variable frog-x
variable frog-y
variable old-frog-x
variable old-frog-y
variable lives
variable wins
variable quit-flag
variable game-over

variable tmp-a
variable tmp-b
variable tmp-c
variable tmp-x
variable tmp-lane
variable tmp-y
variable lane-y
variable lane-max-y
variable start-y-row

: lo-addr ( i -- addr ) cells lane-off + ;
: ld-addr ( i -- addr ) cells lane-div + ;
: lc-addr ( i -- addr ) cells lane-ctr + ;
: lm-addr ( i -- addr ) lane-mov + ;

: lo@ ( i -- n ) lo-addr @ ;
: ld@ ( i -- n ) ld-addr @ ;
: lc@ ( i -- n ) lc-addr @ ;
: lm@ ( i -- n ) lm-addr c@ ;

: lo! ( n i -- ) lo-addr ! ;
: ld! ( n i -- ) ld-addr ! ;
: lc! ( n i -- ) lc-addr ! ;
: lm! ( n i -- ) lm-addr c! ;

: plot ( x y ch fg -- )
  tmp-c !
  tmp-b !
  tmp-y !
  tmp-x !
  COLOR-BG tmp-c @ set-colors
  tmp-x @ tmp-y @ set-cursor
  tmp-b @ emit
  COLOR-BG COLOR-DEFAULT set-colors
;

: reset-frog ( -- )
  scr-w @ 2 / frog-x !
  start-y @ frog-y !
;

: init-field ( -- )
  screen-size
  scr-h !
  scr-w !

  \ Fallback if video area IOCTL is unsupported/invalid.
  scr-w @ 20 < if 80 scr-w ! then
  scr-h @ 12 < if 40 scr-h ! then
  scr-w @ MAX-FIELD-W > if MAX-FIELD-W scr-w ! then

  3 goal-y !
  4 lane-top !

  \ Keep a bounded lane block so every reachable row is redrawn each tick.
  ROAD-LANES lane-count !
  lane-count @ MAX-LANES > if MAX-LANES lane-count ! then

  \ Ensure lanes fit on screen (reserve row 0/1 HUD, row 2 border, bottom border row).
  scr-h @ lane-top @ - 2 - tmp-a !
  tmp-a @ 1 < if
    1 lane-count !
  else
    lane-count @ tmp-a @ > if tmp-a @ lane-count ! then
  then

  lane-top @ lane-count @ + start-y !
;

: init-lanes ( -- )
  lane-count @ 0 do
    rand16 PERIOD mod i lo!
    i 4 mod 2 + dup i ld!
    i lc!
    1 i lm!
  loop
;

: init-game ( -- )
  init-field
  init-lanes
  START-LIVES lives !
  0 wins !
  0 quit-flag !
  0 game-over !
  reset-frog
  frog-x @ old-frog-x !
  frog-y @ old-frog-y !
;

: draw-border ( -- )
  COLOR-BG COLOR-BORDER set-colors
  scr-w @ 0 do
    i 2 35 COLOR-BORDER plot
    i scr-h @ 1- 35 COLOR-BORDER plot
  loop
  scr-h @ 3 do
    0 i 35 COLOR-BORDER plot
    scr-w @ 1- i 35 COLOR-BORDER plot
  loop
;

: car-at? ( x lane -- flag )
  tmp-lane !
  tmp-x !
  tmp-lane @ 2 mod 0= if
    tmp-x @ tmp-lane @ lo@ + PERIOD mod
  else
    tmp-x @ PERIOD + tmp-lane @ lo@ - PERIOD mod
  then
  CAR-LEN <
;

: draw-lane-row ( lane -- )
  tmp-lane !
  lane-top @ tmp-lane @ + lane-y !
  scr-w @ 2 - 0 do
    i tmp-lane @ car-at? if
      i 1+ lane-y @ 61 COLOR-CAR plot
    else
      i 1+ lane-y @ 46 COLOR-ROAD plot
    then
  loop
;

: draw-road ( -- )
  lane-count @ 0 do
    i draw-lane-row
  loop
;

: draw-goal-start ( -- )
  COLOR-BG COLOR-GOAL set-colors
  scr-w @ 2 - 0 do
    i 1+ goal-y @ 94 COLOR-GOAL plot
  loop
  COLOR-BG COLOR-DEFAULT set-colors
;

: draw-start-row ( -- )
  scr-w @ 2 - 0 do
    i 1+ start-y @ 32 COLOR-DEFAULT plot
  loop
;

: restore-cell ( x y -- )
  tmp-y !
  tmp-x !
  tmp-y @ goal-y @ = if
    tmp-x @ tmp-y @ 94 COLOR-GOAL plot
  else
    tmp-y @ start-y @ = if
      tmp-x @ tmp-y @ 32 COLOR-DEFAULT plot
    else
      tmp-y @ lane-top @ < if
        tmp-x @ tmp-y @ 32 COLOR-DEFAULT plot
      else
        lane-top @ lane-count @ + 1- lane-max-y !
        tmp-y @ lane-max-y @ > if
          tmp-x @ tmp-y @ 32 COLOR-DEFAULT plot
        else
          tmp-y @ lane-top @ - tmp-lane !
          tmp-x @ 1- tmp-lane @ car-at? if
            tmp-x @ tmp-y @ 61 COLOR-CAR plot
          else
            tmp-x @ tmp-y @ 46 COLOR-ROAD plot
          then
        then
      then
    then
  then
;

: draw-frog ( -- )
  frog-x @ frog-y @ 64 COLOR-FROG plot
;

: draw-hud ( -- )
  COLOR-BG COLOR-TEXT set-colors
  0 0 set-cursor ." Frogger: WASD move, Q quit"
  0 1 set-cursor
  ." Lives: "
  lives @ 48 + emit
  ."  Wins: "
  wins @ 48 + emit
  ." /"
  TARGET-WINS 48 + emit
  COLOR-BG COLOR-DEFAULT set-colors
;

: draw-static ( -- )
  clrscr
  draw-border
;

: draw-frame ( -- )
  draw-hud
  draw-goal-start
  draw-start-row
  draw-road
  draw-frog
;

: render-delta ( -- )
  draw-hud
  lane-count @ 0 do
    i lm@ if i draw-lane-row then
  loop
  old-frog-x @ old-frog-y @ restore-cell
  draw-frog
  frog-x @ old-frog-x !
  frog-y @ old-frog-y !
;

: handle-input ( -- )
  key? if
    key
    dup 97 = over 65 = or if      \ a/A
      drop
      frog-x @ 1 > if frog-x @ 1- frog-x ! then
    else
      dup 100 = over 68 = or if   \ d/D
        drop
        frog-x @ scr-w @ 2 - < if frog-x @ 1+ frog-x ! then
      else
        dup 119 = over 87 = or if \ w/W
          drop
          frog-y @ goal-y @ > if frog-y @ 1- frog-y ! then
        else
          dup 115 = over 83 = or if \ s/S
            drop
            frog-y @ start-y @ < if frog-y @ 1+ frog-y ! then
          else
            dup 113 = over 81 = or if \ q/Q
              drop 1 quit-flag !
            else
              drop
            then
          then
        then
      then
    then
  then
;

: update-lanes ( -- )
  lane-count @ 0 do
    i lc@ 1- dup 0= if
      drop
      i ld@ i lc!
      i lo@ 1+ PERIOD mod i lo!
      1 i lm!
    else
      i lc!
      0 i lm!
    then
  loop
;

: frog-on-lane? ( -- flag )
  frog-y @ lane-top @ < if
    0
  else
    lane-top @ lane-count @ + 1- lane-max-y !
    frog-y @ lane-max-y @ > if
      0
    else
      1
    then
  then
;

: check-collision ( -- )
  frog-on-lane? if
    frog-y @ lane-top @ - tmp-lane !
    frog-x @ 1- tmp-lane @ car-at? if
      lives @ 1- lives !
      lives @ 0 = if
        1 game-over !
      else
        reset-frog
      then
    then
  then
;

: check-goal ( -- )
  frog-y @ goal-y @ = if
    wins @ 1+ wins !
    wins @ TARGET-WINS = if
      1 game-over !
    else
      reset-frog
    then
  then
;

: delay ( -- ) TICK-MS ms ;

: final-message ( -- )
  COLOR-BG COLOR-TEXT set-colors
  0 0 set-cursor
  quit-flag @ if
    ." Frogger: quit."
  else
    wins @ TARGET-WINS = if
      ." Frogger: you win!"
    else
      ." Frogger: game over."
    then
  then
  COLOR-BG COLOR-DEFAULT set-colors
;

: frogger ( -- )
  init-game
  draw-static
  draw-frame
  begin
    delay
    handle-input
    quit-flag @ if
      1 game-over !
    else
      update-lanes
      check-collision
      game-over @ 0 = if check-goal then
    then
    render-delta
    game-over @
  until
  final-message
;
