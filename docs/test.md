# Test Code

```forth
\ arithmetic + logic
10 3 + 2 * .   20 3 / .   20 3 mod .
5 10 < .   10 5 > .   7 7 = .   5 10 <  3 3 =  and .

\ defining words
: square dup * ;
7 square .

\ variables + memory
variable v
123 v !   v @ .
here 42 swap !   here @ .
pad 65 swap c!   pad c@ emit  10 emit

\ dictionary growth + cells/,
here 1 ,  2 ,  here @ .   here 1 cells + @ .

\ strings + listing
." OK"  10 emit
words
```

What you should see (in order, ignoring the ok prompts):

* Numbers: 26, 6, 2, -1, -1, -1, -1, 49, 123, 42
* A single A character, then a newline
* Numbers: 1, 2
* The string OK
* A word list dump

If any line fails, it narrows the fault:

* math/flags: + - * / mod = < > and
* stack: dup swap over rot (used implicitly in test)
* memory: here pad @ ! c@ c! , cells
* compile/define: : ; variable create
* output: . emit ." words
