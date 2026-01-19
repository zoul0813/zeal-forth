    INCLUDE "words_h.asm"

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

; ( x a-addr -- ) Store x in cell a-addr
WORD "!", word_store
    POP()
    ex de, hl ; HL has address
    POP() ; DE has value

    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store

; ( n c-addr -- ) Store char n in a-addr
WORD "c!", word_store_char
    POP()
    ex de, hl ; HL has address
    POP() ; DE has value
    ld (hl), e
    ret
ENDWORD "c!", word_store_char

; ( -- a-addr ) Put addr-of HERE on stack
WORD "here", word_here
    ld de, (here_sp)
    JP_PUSH()
ENDWORD "here", word_here

; ( -- c-addr ) Put addr-of PAD on stack
WORD "pad", word_pad
    ld de, (here_sp)
    ; DE += 256
    inc d
    JP_PUSH()
ENDWORD "pad", word_pad
