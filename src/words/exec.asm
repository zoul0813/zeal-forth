    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "dict_h.asm"

; @brief Template for "create" word
; template_create:
; @ldde:
;     ld de, 0x0000
;     jp pushdata
; @end:
; @params:
;     PARAM(@ldde + 1, PARAM_IMM16)
;     PARAM_END()

WORD "create", word_create
    call word_colon ; create the word in the dictionary, and set HERE to dict_body

    ; load constant
    ld a, 0x11 ; ld de, nn
    call DICT_C
    ld hl, (HERE)
    ld de, 0x0000
    call DICT_W ; ld de, (HERE)

    ; push constant to data stack
    ld a, 0xC3 ; jp nn
    call DICT_C
    ld de, pushdata ; jp pushdata
    call DICT_W

    ; patch address of constant
    ld de, (HERE)
    ld (hl), e
    inc hl
    ld (hl), d
@done:
    SET_STATE(STATE_IMM)
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
    add hl, de      ; HL = HERE + n
    ld (HERE), hl
    ret
ENDWORD "allot", word_allot

; ( "<spaces>name" -- ) Start compiling
WORD ":", word_colon
  call next_word
  jp z, print_error
  call CREATE_HEADER
  ld hl, (HERE)
  ld d, h
  ld e, l
  inc de
  inc de ; DE = dict_body
  call DICT_W ; write the CFA as dict_body???
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
ENDWORD_FLAGS ";", word_semicolon, IMMEDIATE

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

WORD "forget", word_forget
    call next_word
    ld hl, (_curr_word)
    call dict_search ; HL = address of entry found
    ld (HERE), hl
    ld e, (hl)
    inc hl
    ld d, (hl) ; DE = previous entry
    ld (LATEST), de ; set LATEST to the entry before this, forgetting everything else
    ret
ENDWORD "forget", word_forget

WORD ">r", word_return_push
    POP()
    JP_PUSH_RET()
ENDWORD ">r", word_return_push

WORD "r>", word_return_pop
    POP_RET()
    JP_PUSH()
ENDWORD "r>", word_return_pop