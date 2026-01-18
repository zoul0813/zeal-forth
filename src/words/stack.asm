    INCLUDE "words_h.asm"

; ( n -- n n ) Duplicate top stack item
WORD "dup", word_dup
    PEEKDATA()  ; DE = n
    PUSHDATA()
    ret
ENDWORD "dup", word_dup

; ( n -- ) Drop top stack item
WORD "drop", word_drop
    ; Increment the data stack twice, no need to get the data
    ld hl, (data_sp)
    inc hl
    inc hl
    ld (data_sp), hl
    ret
ENDWORD "drop", word_drop

; ( n1 n2 -- n2 n1 )
WORD "swap", word_swap
    POPDATA() ; DE = n2
    ex de, hl ; HL = n2
    POPDATA() ; DE = n1
    ex de, hl ; DE = n2, HL = n1
    PUSHDATA() ; push n2
    ex de, hl
    PUSHDATA() ; push n1
    ret
ENDWORD "swap", word_swap

; ( n1 n2 -- n1 n2 n1 )
WORD "over", word_over
    ld hl, (data_sp)
    inc hl
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    PUSHDATA()
    ret
ENDWORD "over", word_over

; ( n1 n2 n3 -- n2 n3 n1 )
WORD "rot", word_rot
    POPDATA()   ; DE = n3
    ld b, d
    ld c, e     ; BC = n3
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; HL = n1, DE = n2
    PUSHDATA()  ; push n2
    ld d, b
    ld e, c     ; DE = n3
    PUSHDATA()  ; push n3
    ex de, hl   ; HL = n3, DE = n1
    PUSHDATA()  ; push n1
    ret
ENDWORD "rot", word_rot

WORD "wipe", word_wipe
    ld hl, DATA_STACK_head
    ld (data_sp), hl
    ret
ENDWORD "wipe", word_wipe