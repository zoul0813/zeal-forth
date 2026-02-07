    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "compiler_h.asm"

    ; @brief Unconditional control-flow primitive used by compiled branch words.
    ;
    ; Expects the CPU return address (on Z80 stack) to point to an inline 16-bit
    ; absolute target cell.
    ;
    ; Returns:
    ; - Execution continues at the inline target address.
    ;
    ; Alters:
    ;   A, DE, HL, Z80 stack
branch:
    pop hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    push de
    ret
;

    ; @brief Conditional control-flow primitive used by compiled branch words.
    ;
    ; Expects the CPU return address (on Z80 stack) to point to an inline 16-bit
    ; absolute target cell.
    ;
    ; Returns:
    ; - If flag == 0, execution continues at the inline target address.
    ; - If flag != 0, execution continues after the inline target cell.
    ;
    ; Alters:
    ;   A, DE, HL, Z80 stack
    ;
branch0:
    POP() ; DE = flag
    ld a, d
    or e

    pop hl ; HL = inline operand address
    jr z, @take

    ; Non-zero flag: skip inline target and continue after it.
    inc hl
    inc hl
    jp (hl)

@take:
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    jp (hl)
;


; ( flag -- ) [ -- orig ]
WORD "if", word_if
    ; compile a conditional branch primitive with patchable target
    DICT_CALL(branch0)
    PUSH_HERE() ; push addr of 0x0000 to return stack
    ld de, 0x0000
    call DICT_W ; write 0x0000
    ret
ENDWORD_FLAGS "if", word_if, RESERVED | IMMEDIATE

; ( -- ) [ orig1 -- orig2 ]
WORD "else", word_else
    ; compile an unconditional branch primitive with patchable target
    DICT_CALL(branch)

    ; patch IF's address
    POP_RET()   ; DE has address of IF's 0x0000
    push de

    PUSH_HERE()
    ld de, 0x0000
    call DICT_W

    pop hl
    PATCH_HERE()

    ret
ENDWORD_FLAGS "else", word_else, RESERVED | IMMEDIATE

; ( -- ) [ orig -- ]
WORD "then", word_then
    POP_RET() ; get the address of ELSE 0x0000
    ex de, hl ; HL has address of ELSE's 0x0000
    PATCH_HERE() ; patched ELSE's 0x0000
    ret
ENDWORD_FLAGS "then", word_then, RESERVED | IMMEDIATE

; ( -- ) [ -- dest ]
WORD "begin", word_begin
    PUSH_HERE()
    ret
ENDWORD_FLAGS "begin", word_begin, RESERVED | IMMEDIATE

; ( flag -- ) [dest -- ]
WORD "until", word_until
    POP_RET()
    push de
    DICT_CALL(branch0)
    pop de
    call DICT_W
    ret
ENDWORD_FLAGS "until", word_until, RESERVED | IMMEDIATE

; ( flag -- ) [ dest -- dest orig ]
WORD "while", word_while
    POP_RET()
    PUSH_RET() ; dup
    call word_if
    ret
ENDWORD_FLAGS "while", word_while, RESERVED | IMMEDIATE

; ( -- ) [ dest orig -- ]
WORD "repeat", word_repeat
    ; WHILE
    POP_RET() ; DE = orig
    push de

    ; BEGIN
    POP_RET() ; DE = dest
    push de

    ; go back to BEGIN
    DICT_CALL(branch)

    ; Compile inline target for branch (back-edge to BEGIN)
    pop de
    call DICT_W

    ; Patch WHILE's forward-exit placeholder to HERE
    pop hl
    PATCH_HERE()
    ret
ENDWORD_FLAGS "repeat", word_repeat, RESERVED | IMMEDIATE


