\ Math smoke/regression tests for core arithmetic words.
\ Usage:
\   loadfile "tests/math.fs"

: cr 10 emit ;

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
." [ / ] 20 3 -> 6: "             20 3 / 6 = report
." [ mod ] 20 3 -> 2: "           20 3 mod 2 = report

\ /mod leaves ( rem quot )
." [ /mod ] 20 3 -> 2 6: "        20 3 /mod >r 2 = r> 6 = and report

\ Division-by-zero behavior in this implementation is defined as 0.
." [ /0 ] 123 0 -> 0: "           123 0 / 0 = report
." [ mod0 ] 123 0 -> 0: "         123 0 mod 0 = report
." [ /mod0 ] 123 0 -> 0 0: "      123 0 /mod swap 0 = swap 0 = and report

\ Extra edge checks for unsigned 16-bit behavior.
." [ / ] 65535 255 -> 257: "      65535 255 / 257 = report
." [ mod ] 65535 256 -> 255: "    65535 256 mod 255 = report

: summary ( -- )
  fails @ 0 = if
    ." ALL MATH TESTS PASSED" cr
  else
    ." MATH TEST FAILURES: " fails @ .
  then
;

summary
