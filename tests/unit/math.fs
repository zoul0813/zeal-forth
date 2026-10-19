\ Math smoke/regression tests for core arithmetic words.
\ Usage:
\   loadfile "tests/unit/math.fs"

: cr 10 emit ;

create __math_tests_marker

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

." [ + ] 2 3 -> 5: "              2 3 + 5 = report
." [ - ] 9 4 -> 5: "              9 4 - 5 = report
." [ * ] 7 6 -> 42: "             7 6 * 42 = report

\ One-bit shift, including carry between bytes and discarded overflow.
." [ 2* ] 0 -> 0: "              0 2* 0 = report
." [ 2* ] 1 -> 2: "              1 2* 2 = report
." [ 2* ] 255 -> 510: "          255 2* 510 = report
." [ 2* ] 32767 -> -2: "         32767 2* -2 = report
." [ 2* ] 32768 -> 0: "          32768 2* 0 = report
." [ 2* ] 65535 -> -2: "         65535 2* -2 = report
." [ 2* ] -2 -> -4: "            -2 2* -4 = report
." [ 2* ] preserves lower item: " 123 21 2* 42 = swap 123 = and report

: t-two-star ( x -- doubled-x ) 2* ;
." [ 2* ] compiled 21 -> 42: "    21 t-two-star 42 = report

\ The 2048-byte data stack holds 1024 cells; unary shifts need no extra slot.
: t-full-two-star ( -- x )
  1023 0 do 0 loop
  1 2* >r
  drop 1022 0 do drop loop
  r>
;
." [ 2* ] full stack 1 -> 2: "    t-full-two-star 2 = report

\ Arithmetic right shift preserves the sign and rounds odd negatives down.
." [ 2/ ] 0 -> 0: "              0 2/ 0 = report
." [ 2/ ] 1 -> 0: "              1 2/ 0 = report
." [ 2/ ] 3 -> 1: "              3 2/ 1 = report
." [ 2/ ] 5 -> 2: "              5 2/ 2 = report
." [ 2/ ] -5 -> -3: "            -5 2/ -3 = report
." [ 2/ ] 256 -> 128: "          256 2/ 128 = report
." [ 2/ ] 32767 -> 16383: "      32767 2/ 16383 = report
." [ 2/ ] -32768 -> -16384: "    -32768 2/ -16384 = report
." [ 2/ ] -1 -> -1: "            -1 2/ -1 = report
." [ 2/ ] -2 -> -1: "            -2 2/ -1 = report
." [ 2/ ] -3 -> -2: "            -3 2/ -2 = report
." [ 2/ ] preserves lower item: " 123 42 2/ 21 = swap 123 = and report

: t-two-slash ( n -- halved-n ) 2/ ;
." [ 2/ ] compiled 42 -> 21: "    42 t-two-slash 21 = report

: t-full-two-slash ( -- x )
  1023 0 do 0 loop
  -3 2/ >r
  drop 1022 0 do drop loop
  r>
;
." [ 2/ ] full stack -3 -> -2: "  t-full-two-slash -2 = report

." [ / ] 20 3 -> 6: "             20 3 / 6 = report
." [ mod ] 20 3 -> 2: "           20 3 mod 2 = report

\ /mod leaves ( rem quot )
." [ /mod ] 20 3 -> 2 6: "        20 3 /mod >r 2 = r> 6 = and report

\ Floored signed division/modulo.
." [ / ] -20 3 -> -7: "           -20 3 / -7 = report
." [ mod ] -20 3 -> 1: "          -20 3 mod 1 = report
." [ / ] 20 -3 -> -7: "           20 -3 / -7 = report
." [ mod ] 20 -3 -> -1: "         20 -3 mod -1 = report
." [ / ] -20 -3 -> 6: "           -20 -3 / 6 = report
." [ mod ] -20 -3 -> -2: "        -20 -3 mod -2 = report

\ Unsigned variants.
." [ u/ ] 65535 255 -> 257: "      65535 255 u/ 257 = report
." [ umod ] 65535 256 -> 255: "    65535 256 umod 255 = report
." [ u/mod ] 20 3 -> 2 6: "        20 3 u/mod >r 2 = r> 6 = and report
." [ u< ] 65535 1 -> 0: "          65535 1 u< 0 = report
." [ u> ] 65535 1 -> -1: "         65535 1 u> -1 = report

\ Extra edge checks for unsigned 16-bit behavior.
." [ / ] 65535 255 -> -1: "       65535 255 / -1 = report
." [ mod ] 65535 256 -> 255: "    65535 256 mod 255 = report

\ Carry, borrow, wraparound, operand order, and deeper cells in compiled code.
: t-add-boundary 1234 65535 1 + 0 = >r 1234 = r> and ;
: t-sub-boundary 1234 0 1 - -1 = >r 1234 = r> and ;
: t-add-carry 255 1 + ;
: t-sub-borrow 256 1 - ;
: t-add-signed 32767 1 + ;
: t-sub-signed -32768 1 - ;
." [ + ] wrap and sentinel: " t-add-boundary report
." [ - ] wrap and sentinel: " t-sub-boundary report
." [ + ] byte carry: " t-add-carry 256 = report
." [ - ] byte borrow: " t-sub-borrow 255 = report
." [ + ] signed boundary: " t-add-signed -32768 = report
." [ - ] signed boundary: " t-sub-signed 32767 = report

\ Native increment/decrement need no spare data slot.
: t-inc 1+ ;
: t-dec 1- ;
." [ 1+ ] interpreted carry: " 255 1+ 256 = report
." [ 1- ] interpreted borrow: " 256 1- 255 = report
." [ 1+ ] wrap: " -1 t-inc 0 = report
." [ 1- ] wrap: " 0 t-dec -1 = report
." [ 1+ ] signed boundary: " 32767 t-inc -32768 = report
." [ 1- ] signed boundary: " -32768 t-dec 32767 = report
." [ 1+ ] deeper sentinel: " 1234 255 t-inc 256 = >r 1234 = r> and report
." [ 1- ] deeper sentinel: " 1234 256 t-dec 255 = >r 1234 = r> and report
: t-full-inc
  1023 0 do 0 loop -1 1+ >r drop 1022 0 do drop loop r>
;
: t-full-dec
  1023 0 do 0 loop 0 1- >r drop 1022 0 do drop loop r>
;
." [ 1+ ] full stack: " t-full-inc 0 = report
." [ 1- ] full stack: " t-full-dec -1 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL MATH TESTS PASSED" cr
  else
    ." MATH TEST FAILURES: " fails @ .
  then
;

summary
forget __math_tests_marker

bye
