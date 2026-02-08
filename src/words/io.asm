    INCLUDE "words_h.asm"
    INCLUDE "dict_h.asm"


; ( n -- ) Display n in free field format.
WORD ".", word_dot
    POP()
    PUTI()
    PUTC(' ')
    ret
ENDWORD ".", word_dot

word_dot_quote_runtime:
    pop hl ; HL = address of inline <len>
    ld c, (hl)
    ld b, 0
    inc hl ; HL = start of string
    ld d, h
    ld e, l ; DE = c-addr
    add hl, bc ; HL = address after string
    push hl ; make ret continue after string
    call puts
    ret

; ( -- ) Print the string following the word
WORD ".\"", word_dot_quote
    ld hl, (_next_word)
    call parse_until_quote ; DE = buffer, BC = length
    IF_STATE(STATE_COMP, @compile)
    push hl
    call puts
    pop hl
@return:
    ld (_next_word), hl
    ret

@compile:
    push de
    push bc
    DICT_CALL(word_dot_quote_runtime)
    pop bc
    ld a, c
    call DICT_C
    pop de
@copy:
    ld a, b
    or c
    jr z, @return
    ld a, (de)
    call DICT_C ; copy the byte
    inc de
    dec bc
    jr @copy

ENDWORD_FLAGS ".\"", word_dot_quote, IMMEDIATE

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

; ( -- )
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

; ( -- )
WORD "(", word_lparen
    ld hl, (_next_word)
@loop:
    ld a, (hl)
    cp ')'  ; end
    jr z, @skip
    cp 0x00 ; null-term
    jr z, @done
    inc hl
    jr @loop
@skip:
    inc hl
@done:
    ld (_next_word), hl
    ret
ENDWORD_FLAGS "(", word_lparen, IMMEDIATE

; ( "ccc<quote>" -- )
WORD "loadfile", word_loadfile
    ld hl, (_next_word)
@check_quote:
    ld a, (hl)
    cp '"'
    jr z, @quoted
    ERROR(ERR_UNTERMINATED_STR)
@quoted:
    inc hl ; skip opening quote
    call parse_until_quote ; DE=path, BC=len, HL=after closing quote
    dec hl
    ld (hl), 0 ; temporary null-terminate the quoted path
    inc hl
    ld (_next_word), hl
    jp loadfile
ENDWORD "loadfile", word_loadfile
