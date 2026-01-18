    INCLUDE "words_h.asm"

; TODO - Reimplement in Forth once able
; DEBUG WORDS

WORD ".s", word_dot_s
    PUTC('<')
    ; calculate number of items
    ld hl, DATA_STACK_head
    ld de, (data_sp)
    or a ; clear carry
    sbc hl, de
    srl l ; divide by two (cell size = 2)
    rr h
    ; print count
    ex de, hl
    push de
    PUTI()
    PUTC('>')
    PUTC(' ')
    pop de
    ; check if stack is empty
    ld a, d
    or e
    ret z ; stack is empty, just return

    ; print each item (bottom up)
    ld hl, DATA_STACK_head - CELL_SIZE
@next:
    push hl
    ld de, (data_sp)
    or a
    sbc hl, de
    pop hl
    jr c, @done ; HL < data_sp

    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl

    push hl
    PUTI()
    PUTC(' ')
    pop hl

    dec hl
    dec hl

    jr @next

@done:
    ret
ENDWORD ".s", word_dot_s

