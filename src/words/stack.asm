    INCLUDE "words_h.asm"

; ( n -- n n ) Duplicate top stack item
WORD "dup", word_dup
    PEEK()  ; DE = n
    JP_PUSH()
ENDWORD "dup", word_dup

; ( n -- ) Drop top stack item
WORD "drop", word_drop
    JP_POP()
ENDWORD "drop", word_drop

; ( n1 n2 -- n2 n1 )
WORD "swap", word_swap
    POP() ; DE = n2
    ex de, hl ; HL = n2
    POP() ; DE = n1
    ex de, hl ; DE = n2, HL = n1
    PUSH() ; push n2
    ex de, hl
    JP_PUSH() ; push n1
ENDWORD "swap", word_swap

; ( n1 n2 -- n1 n2 n1 )
WORD "over", word_over
    POP()       ; DE = n2, stack still contains n1
    ld b, d
    ld c, e     ; BC = n2
    PEEK()      ; DE = n1
    ex de, hl   ; HL = n1
    ld d, b
    ld e, c     ; DE = n2
    PUSH()      ; restore n2
    ex de, hl   ; DE = n1
    JP_PUSH()   ; copy n1
ENDWORD "over", word_over

; ( n1 n2 n3 -- n2 n3 n1 )
WORD "rot", word_rot
    POP()   ; DE = n3
    ld b, d
    ld c, e     ; BC = n3
    POP()   ; DE = n2
    ex de, hl   ; HL = n2
    POP()   ; DE = n1
    ex de, hl   ; HL = n1, DE = n2
    PUSH()  ; push n2
    ld d, b
    ld e, c     ; DE = n3
    PUSH()  ; push n3
    ex de, hl   ; HL = n3, DE = n1
    JP_PUSH()  ; push n1
ENDWORD "rot", word_rot

WORD "wipe", word_wipe
    ld hl, DATA_STACK_head
    ld (data_sp), hl
    ret
ENDWORD "wipe", word_wipe
