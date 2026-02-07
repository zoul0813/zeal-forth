\ Tic-Tac-Toe for current Zeal Forth.
\ Assumes forth.fs is loaded (for `constant`, `1+`, `1-`, `cr`).
\
\ Run:
\   loadfile "forth.fs"
\   loadfile "tests/ttt.fs"
\   ttt

9 constant BOARD-SZ

create board BOARD-SZ cells allot

variable turn
variable game-over
variable key-idx
variable key-valid
variable key-quit
variable full-flag
variable chk-a
variable chk-b
variable chk-c
variable chk-p
variable game-mode
variable ai-start
variable ai-done
variable ai-pick
variable seek-player
variable p-count
variable e-count
variable e-idx
variable found-flag

: cell-addr ( idx -- a-addr ) cells board + ;
: cell@ ( idx -- n ) cell-addr @ ;
: cell! ( n idx -- ) cell-addr ! ;

: cls ( -- ) 12 0 do cr loop ;

: board-clear ( -- )
  BOARD-SZ 0 do
    0 i cell!
  loop
;

: print-cell ( idx -- )
  dup cell@
  dup 1 = if
    drop drop 88 emit     \ X
  else
    dup 2 = if
      drop drop 79 emit   \ O
    else
      drop
      1+ 48 + emit        \ show cell number 1..9
    then
  then
;

: draw-board ( -- )
  cls
  ." Tic-Tac-Toe (q to quit)" cr
  cr
  0 print-cell ." |" 1 print-cell ." |" 2 print-cell cr
  ." -+-+-" cr
  3 print-cell ." |" 4 print-cell ." |" 5 print-cell cr
  ." -+-+-" cr
  6 print-cell ." |" 7 print-cell ." |" 8 print-cell cr
  cr
;

: line-win? ( a b c p -- flag )
  chk-p !
  chk-c !
  chk-b !
  chk-a !
  chk-a @ cell@ chk-p @ =
  chk-b @ cell@ chk-p @ = and
  chk-c @ cell@ chk-p @ = and
;

: has-win? ( p -- flag )
  chk-p !
  0 1 2 chk-p @ line-win?
  3 4 5 chk-p @ line-win? or
  6 7 8 chk-p @ line-win? or
  0 3 6 chk-p @ line-win? or
  1 4 7 chk-p @ line-win? or
  2 5 8 chk-p @ line-win? or
  0 4 8 chk-p @ line-win? or
  2 4 6 chk-p @ line-win? or
;

: board-full? ( -- flag )
  1 full-flag !
  BOARD-SZ 0 do
    i cell@ 0 = if
      0 full-flag !
    then
  loop
  full-flag @
;

: switch-turn ( -- )
  turn @ 1 = if
    2 turn !
  else
    1 turn !
  then
;

: decode-key ( c -- )
  0 key-valid !
  0 key-quit !
  dup 113 = over 81 = or if      \ q/Q
    drop
    1 key-quit !
  else
    dup 49 < if                  \ < '1'
      drop
    else
      dup 57 > if                \ > '9'
        drop
      else
        49 - key-idx !           \ index 0..8
        1 key-valid !
      then
    then
  then
;

: choose-mode ( -- )
  begin
    ." Mode: 1=vs computer, 2=two-player, q=quit: "
    key dup emit cr
    dup 113 = over 81 = or if
      drop
      0 game-mode !
      1
    else
      dup 49 = if
        drop
        1 game-mode !
        1
      else
        dup 50 = if
          drop
          2 game-mode !
          1
        else
          drop
          ." Invalid mode." cr
          0
        then
      then
    then
  until
;

: scan-pos ( idx -- )
  dup cell@
  dup seek-player @ = if
    drop drop
    p-count @ 1+ p-count !
  else
    0 = if
      e-count @ 1+ e-count !
      e-idx !
    else
      drop
    then
  then
;

: line-move ( a b c -- )
  found-flag @ 0 = if
    0 p-count !
    0 e-count !
    scan-pos
    scan-pos
    scan-pos
    p-count @ 2 = if
      e-count @ 1 = if
        e-idx @ ai-pick !
        1 found-flag !
      then
    then
  else
    drop drop drop
  then
;

: find-win-move ( p -- flag )
  seek-player !
  0 found-flag !
  0 1- ai-pick !
  0 1 2 line-move
  3 4 5 line-move
  6 7 8 line-move
  0 3 6 line-move
  1 4 7 line-move
  2 5 8 line-move
  0 4 8 line-move
  2 4 6 line-move
  found-flag @
;

: try-place ( idx -- flag )
  dup cell@ 0 = if
    2 over cell!
    drop
    1
  else
    drop
    0
  then
;

: place-ai-pick ( -- )
  2 ai-pick @ cell!
  1 ai-done !
;

: ai-move ( -- )
  0 ai-done !

  2 find-win-move if
    place-ai-pick
  else
    1 find-win-move if
      place-ai-pick
    else
      4 try-place if
        1 ai-done !
      else
        0 try-place if
          1 ai-done !
        else
          2 try-place if
            1 ai-done !
          else
            6 try-place if
              1 ai-done !
            else
              8 try-place if
                1 ai-done !
              else
                1 try-place if
                  1 ai-done !
                else
                  3 try-place if
                    1 ai-done !
                  else
                    5 try-place if
                      1 ai-done !
                    else
                      7 try-place if
                        1 ai-done !
                      else
                        \ no move possible
                      then
                    then
                  then
                then
              then
            then
          then
        then
      then
    then
  then
;

: ttt ( -- )
  choose-mode
  game-mode @ 0 = if
    ." Quit." cr
    1 game-over !
  else
    0 game-over !
  then

  board-clear
  1 turn !
  begin
    game-over @ 0 = if
      draw-board
      game-mode @ 1 = turn @ 2 = and if
        ." O (computer) move..." cr
        ai-move
        turn @ has-win? if
          draw-board
          ." O wins!" cr
          1 game-over !
        else
          board-full? if
            draw-board
            ." Draw." cr
            1 game-over !
          else
            switch-turn
          then
        then
      else
        turn @ 1 = if ." X turn (1-9/q): " else ." O turn (1-9/q): " then
        key dup emit cr
        decode-key

        key-quit @ if
          ." Quit." cr
          1 game-over !
        else
          key-valid @ if
            key-idx @ cell@ 0 = if
              turn @ key-idx @ cell!
              turn @ has-win? if
                draw-board
                turn @ 1 = if ." X wins!" else ." O wins!" then
                cr
                1 game-over !
              else
                board-full? if
                  draw-board
                  ." Draw." cr
                  1 game-over !
                else
                  switch-turn
                then
              then
            else
              ." Cell occupied." cr
            then
          else
            ." Invalid key." cr
          then
        then
      then
    else
      \ keep stack flow stable when game is already over
    then
    game-over @
  until
;
