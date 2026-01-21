    INCLUDE "words_h.asm"

; TODO - Reimplement in Forth once able
; DEBUG WORDS

WORD ".s", word_dot_s
    ld hl, DATA_STACK_head
    ld de, (data_sp)
    call print_stack
    ret
ENDWORD ".s", word_dot_s


WORD ".rs", word_dot_rs
    ld hl, RETURN_STACK_head
    ld de, (return_sp)
    call print_stack
    ret
ENDWORD ".rs", word_dot_rs

; @brief Print a stack given its head and current SP
;
; Parameters:
; - HL - stack head (next free)
; - DE - stack pointer (top cell)
;
; Alters:
;   A, BC, DE, HL
print_stack:
    push hl
    push de
    PUTC('<')
    pop de
    pop hl
    ld b, d
    ld c, e
    push hl
    or a ; clear carry
    sbc hl, de
    srl l ; divide by two (cell size = 2)
    rr h
    ex de, hl
    push bc
    PUTI()
    PUTC('>')
    PUTC(' ')
    pop bc
    pop hl
    ; check if stack is empty
    ld a, h
    cp b
    jr nz, @print
    ld a, l
    cp c
    ret z

@print:
    ; print each item (bottom up)
    dec hl
    dec hl
@next:
    push hl
    or a
    sbc hl, bc
    pop hl
    jr c, @done ; HL < stack_sp

    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl

    push hl
    push bc
    PUTI()
    PUTC(' ')
    pop bc
    pop hl

    dec hl
    dec hl

    jr @next

@done:
    ret
