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
    STACK_REQUIRE(1)
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld (hl), a
    dec hl
    ld (hl), c
    ret
ENDWORD "@", word_fetch

; ( c-addr -- c ) Fetch a char from c-addr
WORD "c@", word_fetch_char
    STACK_REQUIRE(1)
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld (hl), 0
    dec hl
    ld (hl), a
    ret
ENDWORD "c@", word_fetch_char

    PUBLIC word_store_de_hl
; ( x a-addr -- ) Store x in cell a-addr
WORD "!", word_store
    STACK_REQUIRE(2)
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (data_sp), hl
    ld h, b
    ld l, c
word_store_de_hl:
    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store

    PUBLIC word_store_char_de_hl
; ( n c-addr -- ) Store char n in a-addr
WORD "c!", word_store_char
    STACK_REQUIRE(2)
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld e, (hl)
    inc hl
    inc hl
    ld (data_sp), hl
    ld h, b
    ld l, c
word_store_char_de_hl:
    ld (hl), e
    ret
ENDWORD "c!", word_store_char

; ( n a-addr -- ) Add n to the cell at a-addr, modulo 65536.
WORD "+!", word_plus_store
    STACK_REQUIRE(2)
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ex de, hl ; HL = increment, DE = stack pointer after consuming operands
    ld a, (bc)
    add a, l
    ld l, a
    inc bc
    ld a, (bc)
    adc a, h
    ld h, a
    ld (data_sp), de
    ld a, h
    ld (bc), a
    dec bc
    ld a, l
    ld (bc), a
    ret
ENDWORD "+!", word_plus_store

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
