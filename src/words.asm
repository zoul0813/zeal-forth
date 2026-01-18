    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "math_h.asm"
    INCLUDE "words_h.asm"

    SECTION TEXT
; @brief Advanced the input buffer to the next word
;
; Alters:
;   HL
next_word:
    ld hl, (_next_word)
; @brief Setup the current word + next_word
;
; Paramters:
;   HL = Address of current word
;
; Alters:
;   HL, DE, A
current_word:
    ld a, ' '
    call strsep ; returns HL = str, DE = next, A = found (alters: DE, A)
    call strlen ; returns BC = len (alters: A, BC)
    ld a, b
    or c
    ret z

    ; Next word is in DE
    ld (_curr_word), hl
    ld (_curr_len), bc
    ld (_next_word), de
    ret



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
