    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "math_h.asm"
    INCLUDE "words_h.asm"

    SECTION TEXT

    PUBLIC next_word
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
    ld d, h ; DE scans forward
    ld e, l
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
    xor a
    ld (de), a  ; terminate current word
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

    PUBLIC parse_until_quote
; @brief Parse bytes from HL until the next '"'.
;
; Parameters:
; - HL - start of text (first byte after opening quote, or immediate text for .")
;
; Returns:
; - DE - start address of text
; - BC - text length
; - HL - address just after closing quote
;
; On unterminated input, prints ERR_UNTERMINATED_STR and does not return.
parse_until_quote:
    ld d, h
    ld e, l
    ld bc, 0
@count:
    ld a, (hl)
    inc hl
    cp '"' ; end
    ret z
    or a ; null-term
    jr nz, @not_null
    ERROR(ERR_UNTERMINATED_STR)
@not_null:
    inc bc
    jr @count


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
