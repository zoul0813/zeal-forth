    INCLUDE "words_h.asm"

de_false:
    ld de, FALSE
    JP_PUSHDATA()
de_true:
    ld de, TRUE
    JP_PUSHDATA()

; ( n1 n2 -- flag )
WORD "=", word_equal
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    or a
    sbc hl, de
    jr z, de_true
    jr de_false
ENDWORD "=", word_equal

; ( n1 n2 -- flag )
WORD "<", word_lessthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr c, de_true
    jr de_false
ENDWORD "<", word_lessthan

WORD ">", word_greaterthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ; Instead of checking if n1 > n2, let's check if n2 >= n1
    or a
    sbc hl, de
    jr nc, de_false
    jr de_true

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

    JP_PUSHDATA()  ; push n3
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

    JP_PUSHDATA()  ; push n3
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

    JP_PUSHDATA()  ; push n3
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

    JP_PUSHDATA()
ENDWORD "invert", word_invert
