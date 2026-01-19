    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "hashtbl_h.asm"
    INCLUDE "compiler_h.asm"

; @brief Template for "create" word
template_create:
@ldde:
    ld de, 0x0000
    jp pushdata
@end:
@params:
    PARAM(@ldde + 1, PARAM_IMM16)
    PARAM_END()

WORD "create", word_create
    ; We want to put the value of `HERE` after compiling and allocated the
    ; template, so we need to create a 2-byte big buffer containing that value.
    ld hl, (here_sp)
    OFFSET_HL(template_create, template_create@end) ; get the template size
    STORE_HL(@params) ; store the size
    ; The word we are creating will point to that value, pass the address
    APPLY_TEMPLATE(template_create, template_create@end, @params)
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
@params:
    DEFW 0  ; location of HERE after template is applied
ENDWORD "create", word_create

WORD "variable", word_variable
    call word_create
    ld hl, (here_sp)
    ld (hl), 0      ; initialize with 0
    inc hl
    ld (hl), 0      ; initialize with 0
    ld de, CELL_SIZE
    jp _word_allot_de ; Tail-call
ENDWORD "variable", word_variable

; ( n1 -- n2 )  n2 is the size in address units of n1 cells.
WORD "cells", word_cells
    ld de, CELL_SIZE
    PUSH()
    jp word_mul ; Tail-call
ENDWORD "cells", word_cells

; (n -- ) Reserve n bytes of data space (from `here`)
WORD "allot", word_allot
    POP()           ; DE = n
_word_allot_de:
    ld hl, (here_sp)
    add hl, de          ; HL = HERE + n
    ld (here_sp), hl
    ret
ENDWORD "allot", word_allot

; ( "<spaces>name" -- ) Start compiling
WORD ":", word_colon
  call next_word
  ; add this word to the dictionary, pointing to HERE
  ld hl, (_curr_word)
  ld de, (here_sp)
  call hshtbl_insert
  or a
  jr z, @change_state ; word added, change state
  PUTS(_str_error, _str_error_end)
  jr @done
@change_state:
  SET_STATE(STATE_COMP)
@done:
  ret
ENDWORD ":", word_colon

    PUBLIC word_semicolon
; ( -- ) End compiling
WORD ";", word_semicolon
    SET_STATE(STATE_IMM)
    ld hl, (here_sp)
    ld a, 0xC9 ; RET
    ld (hl), a
    inc hl ; here++
    ld (here_sp), hl
    ret
ENDWORD ";", word_semicolon

; WORD "if", word_if
; ENDWORD "if", word_if

; WORD "then", word_then
; ENDWORD "then", word_then

; TODO - implement return stack manipulation
; WORD ">r", word_return_push
;     POP()
;     push de
;     ret
; ENDWORD ">r", word_return_push

; WORD "r>", word_return_pop
;     pop de
;     PUSH()
;     ret
; ENDWORD "r>", word_return_pop