    INCLUDE "words_h.asm"
    INCLUDE "dict_h.asm"

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

; discard the remaining chars in the "line"
WORD "\\", word_discard
    ld hl, (_next_word)
@loop:
    ld a, (hl)
    or a
    jr z, @done
    cp '\n'
    jr z, @skip_newline
    inc hl
    jp nz, @loop
@skip_newline:
    inc hl ; skip the \n
@done:
    ld (_next_word), hl
    ret
ENDWORD_FLAGS "\\", word_discard, IMMEDIATE

WORD "(", word_lparen
  ld hl, (_next_word)
@loop:
  ld a, (hl)
  cp ')'
  inc hl
  jr z, @done
  jr @loop
@done:
  ld (_next_word), hl
  ret
ENDWORD_FLAGS "(", word_lparen, IMMEDIATE