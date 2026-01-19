    INCLUDE "words_h.asm"

; ( n n -- n+n ) Add top two stack items
WORD "+", word_plus
    POP()   ; DE = n1
    ex de, hl   ; HL = n1
    POP()   ; DE = n2
    add hl, de
    ex de, hl

    JP_PUSH()
ENDWORD "+", word_plus

; ( n1 n2 -- n1-n2 ) Subtract top two stack items
WORD "-", word_minus
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    ex de, hl
    JP_PUSH()
ENDWORD "-", word_minus

; ( n1 n2 -- n3 )
WORD "*", word_mul
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    call __mul_hl_de
    JP_PUSH()
ENDWORD "*", word_mul

; ( n1 n2 -- n3 )
WORD "/", word_div
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    call __div_hl_de
    JP_PUSH()
ENDWORD "/", word_div

; ( n1 n2 -- n3 )
WORD "mod", word_mod
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl

    call __mod_hl_de
    JP_PUSH()
ENDWORD "mod", word_mod


; ( n -- u ) abs(n)
WORD "abs", word_abs
    PEEK()
    bit 7, d
    ret z
    jp word_negate_impl
ENDWORD "abs", word_abs

; ( n -- -n ) neg(n)
WORD "negate", word_negate
word_negate_impl:
    POP()
    ; -DE = ~DE + 1
    ld a, d
    cpl
    ld d, a
    ld a, e
    cpl
    ld e, a
    inc de
    JP_PUSH()
ENDWORD "negate", word_negate
