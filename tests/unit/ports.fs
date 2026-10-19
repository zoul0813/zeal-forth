\ Port I/O tests for the Zeal video board and MMU, including Zeal Native.
\ MMU mappings are read only. The video bank and cursor blink time are restored
\ before printing results, since console output can change the selected bank.
decimal
: cr 10 emit ;
variable fails
0 fails !
: report ( flag -- )
  if ." ok" cr else 1 fails @ + fails ! ." FAIL" cr then
;

variable saved-bank
variable saved-blink
variable read-result
variable low-result
variable high-result
variable stack-result
variable restored-result

hex
: t-ports
  8E p@ saved-bank !
  0 8E p!                  \ select text-controller bank
  A6 p@ saved-blink !

  80 A6 p! A6 p@ read-result !
  1AB A6 p! A6 p@ low-result !
  -1 A6 p! A6 p@ high-result !

  \ Sentinels must survive both words with no extra stack cells.
  1234 5678 A6 p@ drop
  5678 = swap 1234 = and stack-result !
  1234 5678 2A A6 p!
  5678 = swap 1234 = and stack-result @ and stack-result !

  saved-blink @ A6 p!
  A6 p@ saved-blink @ = restored-result !
  saved-bank @ 8E p!
  8E p@ saved-bank @ = restored-result @ and restored-result !
;
t-ports

." [ p@ ] zero-extends 80: " read-result @ 80 = report
." [ p! ] truncates 1AB to AB: " low-result @ AB = report
." [ p! ] truncates -1 to FF: " high-result @ FF = report
." [ p@ p! ] preserve deeper stack cells: " stack-result @ report
." [ p@ p! ] restore hardware state: " restored-result @ report

\ On Zeal, upper port bits choose which MMU mapping is read.
\ Page 1 contains Forth, so its mapping must differ from kernel page 0.
." [ p@ ] full 16-bit port address: " 00F0 p@ 40F0 p@ = invert report
decimal
: summary
  fails @ 0 = if
    ." ALL PORTS TESTS PASSED" cr
  else
    ." PORTS TEST FAILURES: " fails @ . cr
  then
;
summary
bye
