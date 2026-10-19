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

; ( x -- doubled-x ) Shift one bit left, discarding overflow.
WORD "2*", word_two_star
    POP()
    sla e
    rl d
    JP_PUSH()
ENDWORD "2*", word_two_star

; ( n -- halved-n ) Arithmetic shift right, preserving the sign bit.
WORD "2/", word_two_slash
    POP()
    sra d
    rr e
    JP_PUSH()
ENDWORD "2/", word_two_slash

; ( n1 n2 -- n3 )
WORD "/", word_div
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1
    ld a, d
    or e
    jr nz, @do_div
    ERROR(ERR_DIV_BY_ZERO)
@do_div:

    call __fdivmod_hl_de  ; HL=quot, BC=rem (floored signed)
    ex de, hl             ; DE=quot
    JP_PUSH()
ENDWORD "/", word_div

; ( n1 n2 -- n3 )
WORD "mod", word_mod
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl
    ld a, d
    or e
    jr nz, @do_mod
    ERROR(ERR_DIV_BY_ZERO)
@do_mod:

    call __fdivmod_hl_de  ; HL=quot, BC=rem (floored signed)
    ld d, b
    ld e, c               ; DE=rem
    JP_PUSH()
ENDWORD "mod", word_mod

; ( n1 n2 -- rem quot )
WORD "/mod", word_divmod
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1
    ld a, d
    or e
    jr nz, @do_divmod
    ERROR(ERR_DIV_BY_ZERO)
@do_divmod:

    call __fdivmod_hl_de  ; HL=quot, BC=rem (floored signed)

    ; push rem first, then quot
    ld d, b
    ld e, c
    PUSH()
    ex de, hl
    JP_PUSH()
ENDWORD "/mod", word_divmod

; ( u1 u2 -- u3 )
WORD "u/", word_udiv
    POP()   ; DE = u2
    ex de, hl   ; HL = u2
    POP()   ; DE = u1
    ex de, hl   ; DE = u2, HL = u1
    ld a, d
    or e
    jr nz, @do_udiv
    ERROR(ERR_DIV_BY_ZERO)
@do_udiv:
    call __udivmod_hl_de  ; HL=quot, BC=rem
    ex de, hl             ; DE=quot
    JP_PUSH()
ENDWORD "u/", word_udiv

; ( u1 u2 -- u3 )
WORD "umod", word_umod
    POP()   ; DE = u2
    ex de, hl   ; HL = u2
    POP()   ; DE = u1
    ex de, hl   ; DE = u2, HL = u1
    ld a, d
    or e
    jr nz, @do_umod
    ERROR(ERR_DIV_BY_ZERO)
@do_umod:
    call __udivmod_hl_de  ; HL=quot, BC=rem
    ld d, b
    ld e, c               ; DE=rem
    JP_PUSH()
ENDWORD "umod", word_umod

; ( u1 u2 -- urem uquot )
WORD "u/mod", word_udivmod
    POP()   ; DE = u2
    ex de, hl   ; HL = u2
    POP()   ; DE = u1
    ex de, hl   ; DE = u2, HL = u1
    ld a, d
    or e
    jr nz, @do_udivmod
    ERROR(ERR_DIV_BY_ZERO)
@do_udivmod:
    call __udivmod_hl_de  ; HL=quot, BC=rem
    ; push rem first, then quot
    ld d, b
    ld e, c
    PUSH()
    ex de, hl
    JP_PUSH()
ENDWORD "u/mod", word_udivmod


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
