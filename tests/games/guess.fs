\ Number guessing game for current Zeal Forth.
\ Requires forth.fs (for rand16 and cr).
\
\ Usage:
\   loadfile "forth.fs"
\   loadfile "guess.fs"
\   guess-number

: digit? ( c -- flag )
  dup 48 < if
    drop 0
  else
    dup 57 > if drop 0 else drop 1 then
  then
;

: to-digit ( c -- n ) 48 - ;

: guess-number ( -- )
  rand16 10 mod                 \ secret
  ." Guess the number (0-9)." cr
  begin
    ." Enter digit: "
    key
    dup emit cr
    dup digit? if
      to-digit                  \ secret guess
      over over = if
        drop drop
        ." You win!" cr
        1
      else
        over over < if
          ." Too high."
        else
          ." Too low."
        then
        cr
        drop                    \ keep secret
        0
      then
    else
      drop
      ." Invalid input (use 0-9)." cr
      0
    then
  until
;
