\ BASE-aware numeric output regression checklist.
\ Usage:
\   loadfile "tests/unit/base.fs"
\
\ Compare text after each label with expected value. This suite has no output
\ capture or string-comparison facility, so output words are checked manually.

: cr 10 emit ;

decimal
." [ decimal 255 ] expected 255: " 255 . cr
." [ decimal -42 ] expected -42: " -42 . cr
." [ decimal 0 ] expected 0: " 0 . cr

hex
." [ hex FF ] expected FF: " ff . cr
." [ hex FFFF ] expected FFFF: " ffff . cr
." [ hex -2A ] expected FFD6: " -2a . cr
." [ hex 0 ] expected 0: " 0 . cr
." [ hex 7FFF ] expected 7FFF: " 7fff . cr
." [ hex 8000 ] expected 8000: " 8000 . cr

." [ hex .s ] expected <3> 1 FF FFFF: " 1 ff ffff .s cr
drop drop drop

." [ hex .rs ] expected <2> 1 FF: " 1 >r ff >r .rs cr
r> drop r> drop

decimal
." [ decimal restored ] expected -42: " -42 . cr

\ Run unsupported BASE separately because error recovery aborts current input:
\   8 base ! 123 .
\ Expected: unsup error, with no numeric text before error.
\ Restore afterward with: 10 base !
