\ Breakout for current Zeal Forth.
\ Requires forth.fs (clrscr, set-cursor, set-colors, screen-size, ms, key?).
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/breakout.fs"
\   breakout

5 constant BRICK-ROWS
3 constant BRICK-W
7 constant PADDLE-W
30 constant MAX-BRICK-COLS
150 constant MAX-BRICKS

0 constant COLOR-BG
15 constant COLOR-DEFAULT
7 constant COLOR-BORDER
11 constant COLOR_PADDLE
12 constant COLOR_BALL
10 constant COLOR_BRICK1
14 constant COLOR_BRICK2
13 constant COLOR_BRICK3
9 constant COLOR_TEXT

create bricks MAX-BRICKS allot

variable scr-w
variable scr-h
variable brick-cols
variable bricks-left

variable paddle-x
variable old-paddle-x
variable paddle-y

variable ball-x
variable ball-y
variable old-ball-x
variable old-ball-y
variable dir-x          \ 0=left, 1=right
variable dir-y          \ 0=up, 1=down

variable lives
variable quit-flag

variable tmp-a
variable tmp-b
variable tmp-c
variable tmp-row
variable tmp-col
variable tmp-idx
variable build-row
variable next-x
variable next-y

: baddr ( idx -- c-addr ) bricks + ;
: b@ ( idx -- n ) baddr c@ ;
: b! ( n idx -- ) baddr c! ;

: brick-idx ( row col -- idx )
  swap brick-cols @ * +
;

: brick-fg ( row -- fg )
  dup 1 < if
    drop COLOR_BRICK1
  else
    dup 3 < if
      drop COLOR_BRICK2
    else
      drop COLOR_BRICK3
    then
  then
;

: plot ( x y ch fg -- )
  tmp-c !
  tmp-b !
  tmp-row !
  tmp-col !
  COLOR-BG tmp-c @ set-colors
  tmp-col @ tmp-row @ set-cursor
  tmp-b @ emit
  COLOR-BG COLOR-DEFAULT set-colors
;

: clear-bricks ( -- )
  MAX-BRICKS 0 ?do
    0 i b!
  loop
;

: draw-border ( -- )
  clrscr
  COLOR-BG COLOR_TEXT set-colors
  0 0 set-cursor ." Breakout: A/D move, Q quit"
  COLOR-BG COLOR-BORDER set-colors

  scr-w @ 0 ?do
    i 1 35 COLOR-BORDER plot
    i scr-h @ 1- 35 COLOR-BORDER plot
  loop

  scr-h @ 2 ?do
    0 i 35 COLOR-BORDER plot
    scr-w @ 1- i 35 COLOR-BORDER plot
  loop

  COLOR-BG COLOR-DEFAULT set-colors
;

: draw-paddle ( -- )
  PADDLE-W 0 ?do
    paddle-x @ i + paddle-y @ 61 COLOR_PADDLE plot
  loop
;

: erase-old-paddle ( -- )
  PADDLE-W 0 ?do
    old-paddle-x @ i + paddle-y @ 32 COLOR-DEFAULT plot
  loop
;

: draw-ball ( -- )
  ball-x @ ball-y @ 79 COLOR_BALL plot
;

: erase-old-ball ( -- )
  old-ball-x @ old-ball-y @ 32 COLOR-DEFAULT plot
;

: draw-brick ( row col -- )
  tmp-col !
  tmp-row !
  tmp-row @ brick-fg tmp-c !
  1 tmp-col @ BRICK-W * + tmp-a !
  BRICK-W 0 ?do
    tmp-a @ i + 2 tmp-row @ + 35 tmp-c @ plot
  loop
;

: erase-brick ( row col -- )
  tmp-col !
  tmp-row !
  1 tmp-col @ BRICK-W * + tmp-a !
  BRICK-W 0 ?do
    tmp-a @ i + 2 tmp-row @ + 32 COLOR-DEFAULT plot
  loop
;

: build-bricks ( -- )
  clear-bricks
  0 bricks-left !
  BRICK-ROWS 0 ?do
    i build-row !
    brick-cols @ 0 ?do
      1 build-row @ i brick-idx b!
      build-row @ i draw-brick
      bricks-left @ 1+ bricks-left !
    loop
  loop
;

: init-field ( -- )
  screen-size
  scr-h !
  scr-w !
  scr-w @ 2 - BRICK-W / brick-cols !
  brick-cols @ MAX-BRICK-COLS < if else MAX-BRICK-COLS brick-cols ! then
  3 lives !
  0 quit-flag !
;

: reset-ball ( -- )
  paddle-x @ PADDLE-W 2 / + ball-x !
  paddle-y @ 1- ball-y !
  1 dir-x !
  0 dir-y !
;

: init-objects ( -- )
  scr-h @ 2 - paddle-y !
  scr-w @ PADDLE-W - 2 / paddle-x !
  paddle-x @ old-paddle-x !
  reset-ball
  ball-x @ old-ball-x !
  ball-y @ old-ball-y !
;

: handle-input ( -- )
  key? if
    key
    dup 97 = over 65 = or if      \ a/A
      drop
      paddle-x @ 1 > if
        paddle-x @ 1- paddle-x !
      then
    else
      dup 100 = over 68 = or if   \ d/D
        drop
        paddle-x @ PADDLE-W + scr-w @ 1- < if
          paddle-x @ 1+ paddle-x !
        then
      else
        dup 113 = over 81 = or if \ q/Q
          drop 1 quit-flag !
        else
          drop
        then
      then
    then
  then
;

: maybe-redraw-paddle ( -- )
  paddle-x @ old-paddle-x @ = if
  else
    erase-old-paddle
    draw-paddle
    paddle-x @ old-paddle-x !
  then
;

: hit-brick? ( x y -- flag )
  tmp-b !   \ y
  tmp-a !   \ x

  tmp-b @ 2 < if
    0
  else
    tmp-b @ 2 + BRICK-ROWS < if
      tmp-a @ 1 < if
        0
      else
        tmp-a @ 1- BRICK-W / tmp-col !
        tmp-col @ brick-cols @ < if
          tmp-b @ 2 - tmp-row !
          tmp-row @ tmp-col @ brick-idx dup tmp-idx !
          b@ if
            0 tmp-idx @ b!
            tmp-row @ tmp-col @ erase-brick
            bricks-left @ 1- bricks-left !
            1
          else
            0
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

: bounce-x ( -- )
  dir-x @ 0 = if 1 dir-x ! else 0 dir-x ! then
;

: bounce-y ( -- )
  dir-y @ 0 = if 1 dir-y ! else 0 dir-y ! then
;

: step-ball ( -- alive )
  ball-x @ old-ball-x !
  ball-y @ old-ball-y !

  \ next-x from dir-x
  dir-x @ 1 = if
    ball-x @ 1+ next-x !
  else
    ball-x @ 1- next-x !
  then

  \ side walls
  next-x @ 0 = if
    bounce-x
    ball-x @ 1+ next-x !
  then
  next-x @ scr-w @ 1- = if
    bounce-x
    ball-x @ 1- next-x !
  then

  \ next-y from dir-y
  dir-y @ 1 = if
    ball-y @ 1+ next-y !
  else
    ball-y @ 1- next-y !
  then

  \ top wall
  next-y @ 1 = if
    bounce-y
    ball-y @ 1+ next-y !
  then

  \ paddle collision (only when moving down)
  dir-y @ 1 = if
    next-y @ paddle-y @ = if
      next-x @ paddle-x @ < if
      else
        next-x @ paddle-x @ PADDLE-W + < if
          bounce-y
          ball-y @ 1- next-y !
          next-x @ paddle-x @ - dup
          2 < if
            0 dir-x !
          else
            5 < if else 1 dir-x ! then
          then
        then
      then
    then
  then

  \ brick collision
  next-x @ next-y @ hit-brick? if
    bounce-y
    dir-y @ 1 = if
      ball-y @ 1+ next-y !
    else
      ball-y @ 1- next-y !
    then
  then

  \ bottom: lose life
  next-y @ scr-h @ 1- = if
    lives @ 1- lives !
    lives @ 0 = if
      0
    else
      erase-old-ball
      reset-ball
      draw-ball
      1
    then
  else
    erase-old-ball
    next-x @ ball-x !
    next-y @ ball-y !
    draw-ball
    1
  then
;

: delay ( -- ) 45 ms ;

: breakout ( -- )
  init-field
  draw-border
  build-bricks
  init-objects
  draw-paddle
  draw-ball

  begin
    delay
    handle-input
    maybe-redraw-paddle

    quit-flag @ if
      0
    else
      bricks-left @ 0 = if
        0
      else
        step-ball
      then
    then
  while
  repeat

  COLOR-BG COLOR_TEXT set-colors
  0 0 set-cursor
  quit-flag @ if
    ." Breakout: quit."
  else
    bricks-left @ 0 = if
      ." Breakout: you win!"
    else
      ." Breakout: game over."
    then
  then
  COLOR-BG COLOR-DEFAULT set-colors
;
