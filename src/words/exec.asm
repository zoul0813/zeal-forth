    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "hashtbl_h.asm"

; TODO - implement return stack manipulation
; WORD ">r", word_return_push
;     POPDATA()
;     push de
;     ret
; ENDWORD ">r", word_return_push

; WORD "r>", word_return_pop
;     pop de
;     PUSHDATA()
;     ret
; ENDWORD "r>", word_return_pop


WORD "variable", word_variable
    ld bc, (here_sp)  ; BC = HERE
    ld hl, 7
    or a
    adc hl, bc        ; HL = HERE + 7 (size of this definition)
    ld b, h
    ld c, l           ; BC = HERE + 7
    ld hl, (here_sp)  ; HL = HERE

    ; LD DE, HERE+7
    ld a, 0x11          ; LD DE, CB
    ld (hl), a
    inc hl
    ld a, c          ; C
    ld (hl), a
    inc hl
    ld a, b          ; B
    ld (hl), a
    inc hl

    ; CALL pushdata
    ld a, 0xCD          ; CALL ED
    ld (hl), a
    inc hl
    ld de, pushdata   ; BC = addr of pushdata
    ld a, e          ; C
    ld (hl), a
    inc hl
    ld a, d          ; B
    ld (hl), a
    inc hl

    ; RET
    ld a, 0xC9        ; RET
    ld (hl), a
    inc hl

    ld (here_sp), hl  ; update HERE


    ; advance the input buffer, consume the next word
    call next_word    ; _current_word == "varName"

    ld hl, (_curr_word)
    ld de, bc
    call hshtbl_insert
    or a
    jr z, @done
    ; print an error ... something bad happened?
    PUTS(_str_error, _str_error_end)
@done:

    ret
ENDWORD "variable", word_variable

; ( n1 -- n2 )  n2 is the size in address units of n1 cells.
WORD "cells", word_cells
    ld de, CELL_SIZE
    call pushdata
    call word_mul
    ret
ENDWORD "cells", word_cells

; (n -- ) Reserve n bytes of data space (from `here`)
WORD "allot", word_allot
    POPDATA()           ; DE = n
    ld hl, (here_sp)
    or a
    adc hl, de          ; HL = HERE + n
    ld (here_sp), hl
    ret
ENDWORD "allot", word_allot