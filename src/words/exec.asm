    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "compiler_h.asm"

    DEFC CREATE_JP_TARGET_OFFSET = 7

_begin_new_word:
    call next_word
    jp nz, @has_name
    ERROR(ERR_MISSING_NAME)
@has_name:
    call CREATE_HEADER
    ld hl, (HERE)
    ld d, h
    ld e, l
    inc de
    inc de ; DE = dict_body
    call DICT_W ; write the CFA as dict_body???
    ret
;

; Runtime helper for DOES>; patches the child entry from return stack
; Input: DE = does>-code address
_does_patch_created_entry:
    push de
    POP_RET() ; DE = created dictionary entry
    ex de, hl ; HL = entry
    call DICT_BODY
    ex de, hl ; HL = child body
    ld bc, CREATE_JP_TARGET_OFFSET
    add hl, bc ; HL = immediate operand of JP target
    pop de
    ld (hl), e
    inc hl
    ld (hl), d
    ret
;

; ( "<spaces>name" -- ) Create a variable
WORD "create", word_create
    call _begin_new_word ; create the word in the dictionary, and set HERE to dict_body

    ; load constant
    DICT_INS(0x11)      ; ld de, nn

    ld hl, (HERE)
    ld de, 0x0000
    call DICT_W ; ld de, (HERE)

    ; push constant to data stack
    DICT_CALL(pushdata) ; call pushdata

    ; default behavior is CREATE semantics: return
    DICT_JP(@create_ret)

    PATCH_HERE() ; patch address of constant
@create_ret:
    ret
ENDWORD "create", word_create

; ( "<spaces>name" -- ) Create a variable, and allocate 1 cell of memory
WORD "variable", word_variable
    call word_create
    ld de, 0
    call DICT_W
    ld de, CELL_SIZE
    jp _word_allot_de ; Tail-call
ENDWORD "variable", word_variable

; ( -- ) Start DOES>-part of a defining word
WORD "does>", word_does
    ; Emit runtime patch sequence:
    ;   LD DE,(LATEST)
    ;   CALL pushreturn
    ;   LD DE, <does-code>
    ;   CALL _does_patch_created_entry
    ;   JP <end-of-definition>

    ld de, 0x5BED ; LD DE,(nn) (little-endian)
    call DICT_W

    ld de, LATEST
    call DICT_W

    DICT_CALL(pushreturn)

    DICT_INS(0x11) ; ld de, nn
    ld hl, (HERE)
    push hl ; patch site for does-code address
    ld de, 0x0000
    call DICT_W

    DICT_CALL(_does_patch_created_entry)

    DICT_INS(0xC3) ; jp nn

    POP_RET()  ; pop previous 0 marker
    PUSH_HERE();

    ld de, 0x0000
    call DICT_W

    ; patch the does-code address now that HERE points right after the prologue
    pop hl
    PATCH_HERE()

    ret
ENDWORD_FLAGS "does>", word_does, RESERVED | IMMEDIATE

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
  call _begin_new_word
  ld de, 0
  PUSH_RET() ; marker: no pending DOES> patch
  SET_STATE(STATE_COMP)
  ret
ENDWORD ":", word_colon

    PUBLIC word_semicolon
; ( -- ) End compiling
WORD ";", word_semicolon
    ; close pending DOES> jump if present
    POP_RET() ; DE = patch site (or 0 marker)
    ld a, d
    or e
    jr z, @write_ret
    ex de, hl ; HL = patch site
    PATCH_HERE() ; destination is RET at end of definition
@write_ret:
    SET_STATE(STATE_IMM)
    ld hl, (HERE)
    ld a, 0xC9 ; RET
    ld (hl), a
    inc hl ; here++
    ld (HERE), hl
    ret
ENDWORD_FLAGS ";", word_semicolon, RESERVED | IMMEDIATE

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

    PUBLIC word_forget@drop
WORD "forget", word_forget
    call next_word
    ld hl, (_curr_word)
    call dict_search ; HL = address of entry found
    or a
    jr nz, @end
@drop:
    ld (HERE), hl
    ld e, (hl)
    inc hl
    ld d, (hl) ; DE = previous entry
    ld (LATEST), de ; set LATEST to the entry before this, forgetting everything else
@end:
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
