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



template_create:
@ldde:
    ld de, 0x0000
    call pushdata
    ret
@end:
@patches:
    db @ldde + 1 - template_create, TEMPLATE_END
    db 0

WORD "create", word_create
    TEMPLATE_INIT
    TEMPLATE_APPLY template_create, template_create@end
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
