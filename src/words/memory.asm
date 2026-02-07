    INCLUDE "words_h.asm"
    INCLUDE "dict_h.asm"


word_s_quote_runtime:
    pop hl ; HL = inline <len>
    ld c, (hl)
    ld b, 0
    inc hl ; HL = start of string

    ; Push c-addr
    ld d, h
    ld e, l
    PUSH()

    ; Push u
    ld d, b
    ld e, c
    PUSH()

    ; Continue after inline string bytes
    add hl, bc
    push hl
    ret

; ( a-addr -- x ) Fetch a cell from a-addr
WORD "@", word_fetch
    POP()

    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ex de, hl

    JP_PUSH()
ENDWORD "@", word_fetch

; ( c-addr -- c ) Fetch a char from c-addr
WORD "c@", word_fetch_char
    POP()
    ld a, (de)
    ld l, a
    ld h, 0
    ex de, hl
    JP_PUSH()
ENDWORD "c@", word_fetch_char

    PUBLIC word_store_de_hl
; ( x a-addr -- ) Store x in cell a-addr
WORD "!", word_store
    POP()
    ex de, hl ; HL has address
    POP() ; DE has value
word_store_de_hl:
    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store

    PUBLIC word_store_char_de_hl
; ( n c-addr -- ) Store char n in a-addr
WORD "c!", word_store_char
    POP()
    ex de, hl ; HL has address
    POP() ; DE has value
word_store_char_de_hl:
    ld (hl), e
    ret
ENDWORD "c!", word_store_char

; ( -- a-addr ) Put addr-of HERE on stack
WORD "here", word_here
    ld de, (HERE)
    JP_PUSH()
ENDWORD "here", word_here

; ( -- c-addr ) Put addr-of PAD on stack
WORD "pad", word_pad
    ld de, (HERE)
    ; DE += 256
    inc d
    JP_PUSH()
ENDWORD "pad", word_pad

; ( "ccc<quote>" -- c-addr u ) / compile-time
WORD "s\"", word_s_quote
    ld hl, (_next_word)
    call parse_until_quote ; DE = c-addr, BC = u, HL = after quote
    IF_STATE(STATE_COMP, @compile)

    ; interpret mode: push c-addr u
    PUSH()
    ld d, b
    ld e, c
    PUSH()
    jr @return

@compile:
    push de
    push bc
    DICT_CALL(word_s_quote_runtime)
    pop bc
    ld a, c
    call DICT_C ; inline <len> (low byte)
    pop de
@copy:
    ld a, b
    or c
    jr z, @return
    ld a, (de)
    call DICT_C
    inc de
    dec bc
    jr @copy

@return:
    ld (_next_word), hl
    ret
ENDWORD_FLAGS "s\"", word_s_quote, IMMEDIATE
