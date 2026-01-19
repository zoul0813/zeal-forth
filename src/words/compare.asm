    INCLUDE "words_h.asm"

de_false:
    ld de, FALSE
    JP_PUSH()
de_true:
    ld de, TRUE
    JP_PUSH()

; ( n1 n2 -- flag )
WORD "=", word_equal
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    or a
    sbc hl, de
    jr z, de_true
    jr de_false
ENDWORD "=", word_equal

; ( n1 n2 -- flag )
WORD "<", word_lessthan
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr c, de_true
    jr de_false
ENDWORD "<", word_lessthan

WORD ">", word_greaterthan
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    ; Instead of checking if n1 > n2, let's check if n2 >= n1
    or a
    sbc hl, de
    jr nc, de_false
    jr de_true

ENDWORD ">", word_greaterthan

; ( n1 n2 -- n3 )
WORD "and", word_and
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    ld a, d
    and h
    ld d, a

    ld a, e
    and l
    ld e, a

    JP_PUSH()  ; push n3
ENDWORD "and", word_and

; ( n1 n2 -- n3 )
WORD "or", word_or
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    ld a, d
    or h
    ld d, a

    ld a, e
    or l
    ld e, a

    JP_PUSH()  ; push n3
ENDWORD "or", word_or

WORD "xor", word_xor
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1

    ld a, d
    xor h
    ld d, a

    ld a, e
    xor l
    ld e, a

    JP_PUSH()  ; push n3
ENDWORD "xor", word_xor

; ( n1 -- n2 )
WORD "invert", word_invert
    POP()   ; DE = n1

    ld a, d
    cpl
    ld d, a

    ld a, e
    cpl
    ld e, a

    JP_PUSH()
ENDWORD "invert", word_invert
