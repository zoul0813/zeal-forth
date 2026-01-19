    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "hashtbl_h.asm"
    INCLUDE "compiler_h.asm"

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


; 2244 bytes BEFORE

load_imm_temp:
@ldde:
    ld de, 0x0000
    jp pushdata
@end:
@reloc:
    RELOC(@ldde + 1, RELOC_IMM16)
    RELOC_END()

WORD "create", word_create
    ; We want to put the value of `HERE` after compiling and allocated the
    ; template, so we need to create a 2-byte big buffer containing that value.
    ld hl, (here_sp)
    ld de, load_imm_temp@end - load_imm_temp
    add hl, de          ; `HERE` after allocating the template
    ld (@word_buf), hl
    ; The word we are creating will point to that value, pass the address
    RELOC_TEMPLATE(load_imm_temp, load_imm_temp@end, @word_buf)
    ; Returns the address where the word is stored
    push hl           ; save base for dictionary insert

    ; advance the input buffer, consume the next word
    call next_word    ; _current_word == "varName"

    ld hl, (_curr_word)
    pop de            ; HERE (base)
    call hshtbl_insert
    or a
    jr z, @done
    ; print an error ... something bad happened?
    PUTS(_str_error, _str_error_end)
@done:
    ret
@word_buf:
    DEFW 0
ENDWORD "create", word_create

WORD "variable", word_variable
    call word_create
    ld hl, (here_sp)
    ld (hl), 0      ; initialize with 0
    inc hl
    ld (hl), 0      ; initialize with 0
    ld de, CELL_SIZE
    ; Tail-call
    jp _word_allot_de
ENDWORD "variable", word_variable

; ( n1 -- n2 )  n2 is the size in address units of n1 cells.
WORD "cells", word_cells
    ld de, CELL_SIZE
    call pushdata
    ; Tail-call
    jp word_mul
ENDWORD "cells", word_cells

; (n -- ) Reserve n bytes of data space (from `here`)
WORD "allot", word_allot
    POPDATA()           ; DE = n
_word_allot_de:
    ld hl, (here_sp)
    add hl, de          ; HL = HERE + n
    ld (here_sp), hl
    ret
ENDWORD "allot", word_allot
