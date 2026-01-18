    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "math_h.asm"
    INCLUDE "words_h.asm"

    SECTION DATA
    ; Associative table that will be added to the words hashtable on boot
    PUBLIC builtin_words
builtin_words:

    SECTION TEXT
    INCLUDE "words/stack.asm"
    INCLUDE "words/math.asm"
    INCLUDE "words/compare.asm"
    INCLUDE "words/flow.asm"
    INCLUDE "words/memory.asm"
    INCLUDE "words/io.asm"
    INCLUDE "words/exec.asm"
    INCLUDE "words/system.asm"

    INCLUDE "words/debug.asm"

    SECTION DATA
    ; End of table
_buildin_words_end:
    DEFW 0


