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
_begin_named_word:
    call CREATE_HEADER
    ld hl, (HERE)
    ld d, h
    ld e, l
    inc de
    inc de ; DE = dict_body
    call DICT_W ; write the CFA as dict_body???
    ret
;

; Begin a native definition with a six-byte child stub and DE data bytes.
; Preflight the complete allocation before changing the dictionary or stack.
_begin_native_word:
    push de
    call next_word
    jp z, @missing_name
    ld hl, (_curr_len)
    ld a, h
    or a
    jp nz, @long_name
    ld a, l
    cp 32
    jp nc, @long_name
    ld bc, 12 ; prev, flags, name terminator, CFA, and six-byte stub
    add hl, bc
    pop de
    add hl, de
    jp c, @overflow
    ld de, (HERE)
    add hl, de
    jp c, @overflow
    ld de, __Z80_STACK_tail
    or a
    sbc hl, de
    jp c, _begin_named_word
    jp z, _begin_named_word
@overflow:
    ERROR(ERR_DICT_OVERFLOW)
@missing_name:
    ERROR(ERR_MISSING_NAME)
@long_name:
    ERROR(ERR_TOO_LONG)

; ( x "name" -- ) Define a child that pushes its value directly.
WORD "constant", word_constant
    STACK_REQUIRE(1)
    ld de, 0
    call _begin_native_word
    POP()
    DICT_INS(0x11) ; LD DE,value
    call DICT_W
    DICT_JP(pushdata)
    ret
ENDWORD "constant", word_constant

; ( count "name" -- ) Define an unchecked cell array with uninitialized storage.
WORD "array", word_array
    STACK_REQUIRE(1)
    ld e, (hl)
    inc hl
    ld d, (hl)
    bit 7, d ; negative counts and doubled-size overflow are invalid
    jr nz, @invalid_count
    sla e
    rl d
    call _begin_native_word
    POP()
    sla e
    rl d
    push de ; storage byte count
    ld hl, (HERE)
    ld de, 6
    add hl, de ; base follows the LD DE,base / JP runtime stub
    ex de, hl
    DICT_INS(0x11)
    call DICT_W
    DICT_JP(array_runtime)
    pop de
    jp _word_allot_de
@invalid_count:
    ERROR(ERR_NUMERIC_OVERFLOW)
ENDWORD "array", word_array

; Child runtime: DE = storage base, ( index -- base + index*2 ).
; No temporary data slot or data_sp update is needed.
array_runtime:
    STACK_REQUIRE(1)
    ld c, (hl)
    inc hl
    ld b, (hl)
    dec hl
    sla c
    rl b
    ex de, hl
    add hl, bc
    ex de, hl
    ld (hl), e
    inc hl
    ld (hl), d
    ret

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
    jp word_two_star ; Tail-call: a cell is two bytes.
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
  ld hl, (return_sp)
  ld (_compile_return_sp), hl
  ld de, 0
  PUSH_RET() ; marker: no pending DOES> patch
  SET_STATE(STATE_COMP)
  ret
ENDWORD ":", word_colon

    PUBLIC word_semicolon
; ( -- ) End compiling
WORD ";", word_semicolon
    ; There must be at least one compile-control item (the : marker/DOES> patch)
    ld hl, (return_sp)
    ld de, (_compile_return_sp)
    or a
    sbc hl, de
    jr c, @pop_marker
    ERROR(ERR_UNBALANCED_CONTROL)

@pop_marker:
    ; close pending DOES> jump if present
    POP_RET() ; DE = patch site (or 0 marker)
    ld a, d
    or e
    jr z, @check_balanced
    ex de, hl ; HL = patch site
    PATCH_HERE() ; destination is RET at end of definition

@check_balanced:
    ; After consuming ; bookkeeping, control stack must be back at baseline.
    ld hl, (return_sp)
    ld de, (_compile_return_sp)
    or a
    sbc hl, de
    jr z, @write_ret
    ERROR(ERR_UNBALANCED_CONTROL)

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

; ( -- a-addr ) Address of numeric base cell
WORD "base", word_base
    ld de, BASE
    JP_PUSH()
ENDWORD "base", word_base

WORD "hex", word_hex
    ld hl, 16
    ld (BASE), hl
    ret
ENDWORD_FLAGS "hex", word_hex, IMMEDIATE

WORD "decimal", word_decimal
    ld hl, 10
    ld (BASE), hl
    ret
ENDWORD_FLAGS "decimal", word_decimal, IMMEDIATE

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
    jr nz, @have_name
    ERROR(ERR_MISSING_NAME)
@have_name:
    ld hl, (_curr_word)
    call dict_search ; HL = address of entry found
    or a
    jr z, @drop
    ERROR(ERR_NOT_FOUND)
@drop:
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
