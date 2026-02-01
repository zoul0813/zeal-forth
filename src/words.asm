    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "math_h.asm"
    INCLUDE "words_h.asm"

    SECTION TEXT
; @brief Advanced the input buffer to the next word
;
; Paramters:
; - HL = Address of input_buffer
;
; Returns:
; -  Z = set when no word
;
; Alters:
;   HL, DE, A
next_word:
    ld hl, (_next_word)
@loop:
    ld a, (hl)
    cp ' '
    jr z, @nextchar
    cp '\n'
    jr z, @nextchar
    jr @process
@nextchar:
    inc hl
    jr @loop

@process:
    ld de, hl ; DE scans forward
@scan:
    ld a, (de)
    or a
    jr z, @found_end ; null-term
    cp ' '
    jr z, @found_delim ; space
    cp '\n'
    jr z, @found_delim ; newline
    inc de
    jr @scan

@found_delim:
    ld (de), 0  ; terminate current word
    inc de      ; next word starts after delimiter
@found_end:
    call strlen ; returns BC = len (alters: A, BC)
    ld a, b
    or c
    ret z

    ; Next word is in DE
    ld (_curr_word), hl
    ld (_curr_len), bc
    ld (_next_word), de
    ret
;


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
