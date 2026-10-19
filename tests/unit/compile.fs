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

\ Native constants work without address/fetch execution.
0 constant c0
-32768 constant cmin
-1 constant cmax
: read-native-constants c0 cmin cmax ;
." [ constant ] compiled boundaries: "
read-native-constants -1 = >r -32768 = >r 0 = r> and r> and report
: make-native-constant constant ;
1234 make-native-constant made-constant
." [ constant ] custom defining word: " made-constant 1234 = report
: t-last-constant
  1023 0 do 0 loop c42 >r drop 1022 0 do drop loop r>
;
." [ constant ] last free slot: " t-last-constant 42 = report

\ Array storage is uninitialized; initialize before reading.
48 array xs
2 array ys
0 array empty-array
0 xs constant xs-base
: t-array-address 7 xs ;
." [ array ] interpreted index zero: " 0 xs xs-base = report
." [ array ] compiled index seven: " t-array-address xs-base 14 + = report
." [ array ] last index: " 47 xs xs-base 94 + = report
." [ array ] negative index: " -1 xs xs-base 2 - = report
." [ array ] index multiplication wraps: " 32768 xs xs-base = report
111 0 xs ! 222 1 xs ! 333 47 xs ! 444 0 ys !
." [ array ] adjacent elements: " 0 xs @ 111 = >r 1 xs @ 222 = r> and report
." [ array ] last element: " 47 xs @ 333 = report
." [ array ] independent storage: " 0 ys @ 444 = >r 0 xs @ 111 = r> and report
." [ array ] zero length address: " 0 empty-array 1 empty-array 2 - = report
: make-native-array array ;
3 make-native-array made-array
." [ array ] custom defining word: " 2 made-array 0 made-array 4 + = report
: t-full-array
  1023 0 do 0 loop 7 xs >r drop 1022 0 do drop loop r>
;
." [ array ] full stack lookup: " t-full-array xs-base 14 + = report

7 constant redefined-native
forget redefined-native
8 constant redefined-native
." [ constant ] forget and redefine: " redefined-native 8 = report
2 array redefined-array
forget redefined-array
3 array redefined-array
." [ array ] forget and redefine: " 2 redefined-array 0 redefined-array 4 + = report

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
