\ Compare/logic unit tests.
\ Usage:
\   loadfile "tests/unit/compare.fs"

: cr 10 emit ;

create __compare_tests_marker

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

." [ = ] 12 12 -> true: "                  12 12 = -1 = report
." [ = ] 12 13 -> false: "                 12 13 = 0 = report
." [ < ] -1 1 -> true: "                   -1 1 < -1 = report
." [ > ] -1 1 -> false: "                  -1 1 > 0 = report
." [ < ] -32768 32767 -> true: "           -32768 32767 < -1 = report
." [ > ] 32767 -32768 -> true: "           32767 -32768 > -1 = report
." [ u< ] 65535 1 -> false: "              65535 1 u< 0 = report
." [ u> ] 65535 1 -> true: "               65535 1 u> -1 = report
." [ and ] -1 6 -> 6: "                    -1 6 and 6 = report
." [ or ] 12 3 -> 15: "                    12 3 or 15 = report
." [ xor ] 10 12 -> 6: "                   10 12 xor 6 = report
." [ invert ] invert 0 -> -1: "            0 invert -1 = report
." [ <> ] 9 10 -> true: "                  9 10 <> -1 = report
." [ 0= ] 0 -> true: "                     0 0= -1 = report
." [ 0< ] -1 -> true: "                    -1 0< -1 = report
." [ 0> ] 1 -> true: "                     1 0> -1 = report
." [ 0<> ] 0 -> false: "                   0 0<> 0 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL COMPARE TESTS PASSED" cr
  else
    ." COMPARE TEST FAILURES: " fails @ .
  then
;

summary
forget __compare_tests_marker

bye
