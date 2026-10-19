    INCLUDE "words_h.asm"

; ( n -- n n ) Duplicate top stack item
WORD "dup", word_dup
    STACK_REQUIRE(1)
    STACK_ROOM(1)
    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld (data_sp), hl
    ret
ENDWORD "dup", word_dup

; ( n -- ) Drop top stack item
WORD "drop", word_drop
    STACK_REQUIRE(1)
    inc hl
    inc hl
    ld (data_sp), hl
    ret
ENDWORD "drop", word_drop

; ( n1 n2 -- n2 n1 )
WORD "swap", word_swap
    STACK_REQUIRE(2)
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld c, (hl)
    ld (hl), e
    inc hl
    ld b, (hl)
    ld (hl), d
    dec hl
    dec hl
    ld (hl), b
    dec hl
    ld (hl), c
    ret
ENDWORD "swap", word_swap

; ( n1 n2 -- n1 n2 n1 )
WORD "over", word_over
    STACK_REQUIRE(2)
    STACK_ROOM(1)
    inc hl
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl
    dec hl
    dec hl
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld (data_sp), hl
    ret
ENDWORD "over", word_over

; ( n1 n2 n3 -- n2 n3 n1 )
WORD "rot", word_rot
    STACK_REQUIRE(3)
    ld e, (hl)
    inc hl
    ld d, (hl) ; DE = n3
    inc hl
    ld c, (hl)
    ld (hl), e
    inc hl
    ld b, (hl) ; BC = n2
    ld (hl), d
    inc hl
    ld e, (hl)
    ld (hl), c
    inc hl
    ld d, (hl) ; DE = n1
    ld (hl), b
    dec hl
    dec hl
    dec hl
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    ret
ENDWORD "rot", word_rot

WORD "wipe", word_wipe
    ld hl, DATA_STACK_head
    ld (data_sp), hl
    ret
ENDWORD "wipe", word_wipe
