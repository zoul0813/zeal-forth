\ Flow/control smoke tests.
\ Usage:
\   loadfile "tests/flow.fs"

: cr 10 emit ;

create __flow_tests_marker

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

\ if / else / then
: t-if-zero ( -- n ) 0 if 111 else 222 then ;
: t-if-nonzero ( -- n ) -1 if 111 else 222 then ;
." [ if ] 0 -> else branch: "          t-if-zero 222 = report
." [ if ] -1 -> then branch: "         t-if-nonzero 111 = report

\ begin / until
: t-until ( -- n ) 0 begin 1+ dup 5 = until ;
." [ begin-until ] count to 5: "       t-until 5 = report

\ begin / while / repeat
: t-repeat-down ( -- n ) 5 begin dup 0 > while 1- repeat ;
." [ begin-while-repeat ] down to 0: " t-repeat-down 0 = report

\ do / loop and i
: t-loop-sum ( -- n ) 0 5 0 do i + loop ;
." [ do-loop ] sum 0..4 -> 10: "       t-loop-sum 10 = report

: t-loop-i ( -- n ) 0 4 1 do i + loop ;
." [ i ] sum 1..3 -> 6: "              t-loop-i 6 = report

\ ?do zero-trip and normal-trip
: t-qdo-zero ( -- n ) 123 5 5 ?do i + loop ;
: t-qdo-run ( -- n ) 0 5 0 ?do i + loop ;
." [ ?do ] zero-trip preserves 123: "  t-qdo-zero 123 = report
." [ ?do ] run sum 0..4 -> 10: "       t-qdo-run 10 = report

\ +loop variable stride
: t-plusloop-up ( -- n ) 0 10 0 do i + 2 +loop ;
: t-plusloop-down ( -- n ) 0 -1 9 do i + -3 +loop ;
." [ +loop ] 10 0 step 2 sum -> 20: "  t-plusloop-up 20 = report
." [ +loop ] -1 9 step -3 sum -> 18: " t-plusloop-down 18 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL FLOW TESTS PASSED" cr
  else
    ." FLOW TEST FAILURES: " fails @ .
  then
;

summary
forget __flow_tests_marker
