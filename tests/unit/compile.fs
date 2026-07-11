\ Dictionary/compile unit tests.
\ Usage:
\   loadfile "tests/unit/compile.fs"

: cr 10 emit ;

create __compile_tests_marker

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

\ : ; compilation
: sq dup * ;
." [ : ; ] sq 7 -> 49: "                 7 sq 49 = report

\ constants and variables
42 constant c42
." [ constant ] c42 -> 42: "             c42 42 = report

variable vv
123 vv !
." [ variable ] vv @ -> 123: "           vv @ 123 = report

\ create defaults to pushing body address
create cbuf 2 allot
321 cbuf !
." [ create ] cbuf @ -> 321: "           cbuf @ 321 = report

\ does>
: mkconst create , does> @ ;
77 mkconst k77
." [ does> ] k77 -> 77: "                k77 77 = report

\ forget and redefine
: tmpforget 10 ;
." [ forget ] pre value -> 10: "         tmpforget 10 = report
forget tmpforget
: tmpforget 22 ;
." [ forget ] redefine -> 22: "          tmpforget 22 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL COMPILE TESTS PASSED" cr
  else
    ." COMPILE TEST FAILURES: " fails @ .
  then
;

summary
forget __compile_tests_marker

bye
