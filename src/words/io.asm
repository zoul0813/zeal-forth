    INCLUDE "words_h.asm"

; ( n -- ) Display n in free field format.
WORD ".", word_dot
    POP()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD ".", word_dot

; ( c -- )
WORD "emit", word_emit
    POP()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret
ENDWORD "emit", word_emit

WORD "\\", word_discard
@loop:
    call next_word
    jp nz, @loop
    ret
ENDWORD "\\", word_discard