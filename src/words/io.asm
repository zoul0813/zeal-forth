    INCLUDE "words_h.asm"

; ( n -- ) Display n in free field format.
WORD ".", word_dot
    POPDATA()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD ".", word_dot

; ( c -- )
WORD "emit", word_emit
    POPDATA()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret
ENDWORD "emit", word_emit
