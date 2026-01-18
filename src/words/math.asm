    INCLUDE "words_h.asm"

; ( n n -- n+n ) Add top two stack items
WORD "+", word_plus
    POPDATA()   ; DE = n1
    ex de, hl   ; HL = n1
    POPDATA()   ; DE = n2
    add hl, de
    ex de, hl

    PUSHDATA()
    ret
ENDWORD "+", word_plus

; ( n1 n2 -- n1-n2 ) Subtract top two stack items
WORD "-", word_minus
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "-", word_minus

; ( n1 n2 -- n3 )
WORD "*", word_mul
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    call __mul_hl_de
    PUSHDATA()

    ret
ENDWORD "*", word_mul

; ( n1 n2 -- n3 )
WORD "/", word_div
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    call __div_hl_de
    PUSHDATA()

    ret
ENDWORD "/", word_div

; ( n1 n2 -- n3 )
WORD "mod", word_mod
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl

    call __mod_hl_de
    PUSHDATA()

    ret
ENDWORD "mod", word_mod


; ( n -- u ) abs(n)
WORD "abs", word_abs
    PEEKDATA()
    bit 7, d
    ret z
    jp word_negate_impl
ENDWORD "abs", word_abs

; ( n -- -n ) neg(n)
WORD "negate", word_negate
word_negate_impl:
    POPDATA()
    ; -DE = ~DE + 1
    ld a, d
    cpl
    ld d, a
    ld a, e
    cpl
    ld e, a
    inc de
    PUSHDATA()
    ret
ENDWORD "negate", word_negate
