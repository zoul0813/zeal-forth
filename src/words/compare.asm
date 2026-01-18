    INCLUDE "words_h.asm"

; ( n1 n2 -- flag )
WORD "=", word_equal
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, h
    cp d
    jr nz, @not_equal
    ld a, l
    cp e
    jr z, @equal

@not_equal:
    ld de, FALSE
    PUSHDATA()
    ret
@equal:
    ld de, TRUE
    PUSHDATA()
    ret
ENDWORD "=", word_equal

; ( n1 n2 -- flag )
WORD "<", word_lessthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr c, @true

@false:
    ld de, FALSE
    PUSHDATA()
    ret

@true:
    ld de, TRUE
    PUSHDATA()
    ret
ENDWORD "<", word_lessthan

WORD ">", word_greaterthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr z, @false
    jr nc, @true

@false:
    ld de, FALSE
    PUSHDATA()
    ret
@true:
    ld de, TRUE
    PUSHDATA()
    ret

ENDWORD ">", word_greaterthan

; ( n1 n2 -- n3 )
WORD "and", word_and
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    and h
    ld d, a

    ld a, e
    and l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "and", word_and

; ( n1 n2 -- n3 )
WORD "or", word_or
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    or h
    ld d, a

    ld a, e
    or l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "or", word_or

WORD "xor", word_xor
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    xor h
    ld d, a

    ld a, e
    xor l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "xor", word_xor

; ( n1 -- n2 )
WORD "invert", word_invert
    POPDATA()   ; DE = n1

    ld a, d
    cpl
    ld d, a

    ld a, e
    cpl
    ld e, a

    PUSHDATA()
    ret
ENDWORD "invert", word_invert
