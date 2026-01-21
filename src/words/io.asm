    INCLUDE "words_h.asm"

; ( n -- ) Display n in free field format.
WORD ".", word_dot
    POP()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD ".", word_dot

; ( -- ) Print the string following the word
WORD ".\"", word_dot_quote
    ld hl, (_next_word)
@loop:
    ld a, (hl)
    cp '"'
    jr z, @done
    push hl
    call putc
    pop hl
    inc hl
    jr @loop
@done:
    inc hl
    inc hl
    ld (_next_word), hl
    ret
ENDWORD ".\"", word_dot_quote

; ( c -- )
WORD "emit", word_emit
    POP()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret
ENDWORD "emit", word_emit

; (c-addr n -- )
WORD "type", word_type
    POP()
    ld b, d
    ld c, e   ; BC = strlen
    POP()     ; DE = str pointer
    call puts
    ret
ENDWORD "type", word_type

WORD "\\", word_discard
@loop:
    call next_word
    jp nz, @loop
    ret
ENDWORD "\\", word_discard