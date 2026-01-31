    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "dict_h.asm"
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
    call next_word ; consume the next word
    jp z, print_error

    call CREATE_HEADER

    ; We want to put the value of `HERE` after compiling and allocated the
    ; template, so we need to create a 2-byte big buffer containing that value.
    ld hl, (HERE)
    OFFSET_HL(template_create, template_create@end) ; get the template size
    STORE_HL(@params) ; store the size
    ; The word we are creating will point to that value, pass the address
    APPLY_TEMPLATE(template_create, template_create@end, @params)
@done:
    ret
@params:
    DEFW 0  ; location of HERE after template is applied
ENDWORD "create", word_create

WORD "variable", word_variable
    call word_create
    ld hl, (HERE)
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
    ld hl, (HERE)
    add hl, de          ; HL = HERE + n
    ld (HERE), hl
    ret
ENDWORD "allot", word_allot

; ( "<spaces>name" -- ) Start compiling
WORD ":", word_colon
  call next_word
  jp z, print_error
  call CREATE_HEADER
  SET_STATE(STATE_COMP)
  ret
ENDWORD ":", word_colon

    PUBLIC word_semicolon
; ( -- ) End compiling
WORD ";", word_semicolon
    SET_STATE(STATE_IMM)
    ld hl, (HERE)
    ld a, 0xC9 ; RET
    ld (hl), a
    inc hl ; here++
    ld (HERE), hl
    ret
ENDWORD ";", word_semicolon

; ( -- a-addr ) Address of compilation-state flag
WORD "state", word_state
    ld de, STATE
    JP_PUSH()
ENDWORD "state", word_state

; ( x-addr -- ) Execute code at x-addr, stack effects are defined by the code being executed
WORD "execute", word_execute
    POP() ; DE = execution address
    ex de, hl
    jp (hl)
ENDWORD "execute", word_execute

WORD ",", word_comma
    POP()
    ld hl, (HERE)
    call word_store_de_hl
    inc hl
    inc hl
    ld (HERE), hl
    ret
ENDWORD ",", word_comma

WORD "c,", word_comma_char
    POP()
    ld hl, (HERE)
    call word_store_char_de_hl
    inc hl
    ld (HERE), hl
    ret
ENDWORD "c,", word_comma_char

; WORD "if", word_if
; ENDWORD "if", word_if

; WORD "then", word_then
; ENDWORD "then", word_then

WORD ">r", word_return_push
    POP()
    JP_PUSH_RET()
ENDWORD ">r", word_return_push

WORD "r>", word_return_pop
    POP_RET()
    JP_PUSH()
ENDWORD "r>", word_return_pop