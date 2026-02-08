\ Stack word unit tests.
\ Usage:
\   loadfile "tests/unit/stack.fs"

: cr 10 emit ;

create __stack_tests_marker

variable fails
0 fails !

: report ( flag -- )
  if
    ." ok" cr
  else
    ." FAIL" cr
    fails @ 1 + fails !
  then
;

: t-dup ( -- n ) 7 dup + ;
: t-drop ( -- n ) 1 2 drop ;
: t-swap ( -- n ) 3 5 swap - ;
: t-over ( -- n ) 3 5 over + + ;
: t-rot ( -- n ) 1 2 3 rot nip - ;
: t-nip ( -- n ) 4 9 nip ;
: t-tuck ( -- n ) 4 9 tuck + + ;
: t-2dup ( -- n ) 3 4 2dup + + + ;
: t-2swap ( -- n ) 1 2 3 4 2swap drop drop - ;
: t-2drop ( -- n ) 5 6 7 8 2drop + ;
: t-r ( -- n ) 7 >r 3 r> + ;
: t-wipe ( -- n ) 1 2 3 wipe 7 ;

." [ dup ] 7 dup + -> 14: "      t-dup 14 = report
." [ drop ] 1 2 drop -> 1: "     t-drop 1 = report
." [ swap ] 3 5 swap - -> 2: "   t-swap 2 = report
." [ over ] 3 5 over + + -> 11: " t-over 11 = report
." [ rot ] 1 2 3 rot -> check: " t-rot 1 = report
." [ nip ] 4 9 nip -> 9: "       t-nip 9 = report
." [ tuck ] 4 9 tuck + + -> 22: " t-tuck 22 = report
." [ 2dup ] -> 14: "             t-2dup 14 = report
." [ 2swap ] -> -1: "            t-2swap -1 = report
." [ 2drop ] -> 11: "            t-2drop 11 = report
." [ >r r> ] -> 10: "            t-r 10 = report
." [ wipe ] leaves stack clean: " t-wipe 7 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL STACK TESTS PASSED" cr
  else
    ." STACK TEST FAILURES: " fails @ .
  then
;

summary
forget __stack_tests_marker
