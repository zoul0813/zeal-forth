\ Memory/allocation unit tests.
\ Usage:
\   loadfile "tests/unit/memory.fs"

: cr 10 emit ;

create __memory_tests_marker

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

variable vm
create cm 1 allot
create buf 4 allot

: t-store-fetch ( -- n ) 1234 vm ! vm @ ;
: t-cstore-cfetch ( -- n ) 65 cm c! cm c@ ;
: t-here-comma ( -- n ) here dup >r 4321 , r> @ ;
: t-here-ccomma ( -- n ) here dup >r 66 c, r> c@ ;
: t-allot-delta ( -- n ) here 4 allot here swap - ;
: t-cells ( -- n ) 3 cells ;
: t-full-cells ( -- n )
  1023 0 do 0 loop
  1 cells >r
  drop 1022 0 do drop loop
  r>
;
: t-cell+ ( -- n ) 100 cell+ ;
: t-cell- ( -- n ) 100 cell- ;
: t-char+ ( -- n ) 100 char+ ;
: t-pad-rel ( -- n ) pad here - ;
: t-create-fetch ( -- n ) 777 buf ! buf @ ;

." [ cells ] full stack 1 -> 2: "        t-full-cells 2 = report

." [ ! @ ] variable roundtrip: "         t-store-fetch 1234 = report
." [ c! c@ ] byte roundtrip: "           t-cstore-cfetch 65 = report
." [ , ] stores cell at HERE: "          t-here-comma 4321 = report
." [ c, ] stores byte at HERE: "         t-here-ccomma 66 = report
." [ allot ] here delta 4: "             t-allot-delta 4 = report
." [ cells ] 3 cells -> 6: "             t-cells 6 = report
." [ cells ] 0 -> 0: "                   0 cells 0 = report
." [ cells ] 255 -> 510: "               255 cells 510 = report
." [ cells ] 32768 -> 0: "               32768 cells 0 = report
." [ cells ] -1 -> -2: "                 -1 cells -2 = report
." [ cell+ ] 100 -> 102: "               t-cell+ 102 = report
." [ cell- ] 100 -> 98: "                t-cell- 98 = report
." [ char+ ] 100 -> 101: "               t-char+ 101 = report
." [ pad ] pad-here -> 256: "            t-pad-rel 256 = report
." [ create ] body addr fetch: "         t-create-fetch 777 = report

\ Independent byte layout checks avoid masking matching store/fetch mistakes.
: t-layout
  1234 43981 buf !
  buf c@ 205 = >r buf 1 + c@ 171 = >r 1234 = r> and r> and
;
: t-byte
  1234 511 buf c! buf c@ 255 = >r
  buf 1 + c@ 171 = >r 1234 = r> and r> and
;
: t-fetch-sentinel 1234 buf @ 44031 = >r 1234 = r> and ;
." [ ! ] byte order and sentinel: " t-layout report
." [ c! c@ ] truncate, zero extend, preserve neighbor: " t-byte report
." [ @ ] both bytes and sentinel: " t-fetch-sentinel report
: t-full-fetch
  wipe
  1023 0 do 0 loop
  buf @ >r drop 1022 0 do drop loop r>
;
: t-full-cfetch
  wipe
  1023 0 do 0 loop
  buf c@ >r drop 1022 0 do drop loop r>
;
." [ @ ] full stack: " t-full-fetch 44031 = report
." [ c@ ] full stack: " t-full-cfetch 255 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL MEMORY TESTS PASSED" cr
  else
    ." MEMORY TEST FAILURES: " fails @ .
  then
;

summary
forget __memory_tests_marker

bye
