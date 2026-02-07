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
    ; Parameters:
    ; - DE (via POP()) - flag
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
    push hl
    ret

@take:
    ld e, (hl)
    inc hl
    ld d, (hl)
    push de
    ret
;


; Compile Only
; ( flag -- )
WORD "if", word_if
    ; compile a conditional branch primitive with patchable target
    DICT_CALL(branch0)

    ld de, (HERE)
    PUSH_RET() ; push addr of 0x0000 to return stack

    ld de, 0x0000
    call DICT_W ; write 0x0000

    ret
ENDWORD_FLAGS "if", word_if, RESERVED | IMMEDIATE

; Compile Only
WORD "else", word_else
    ; compile an unconditional branch primitive with patchable target
    DICT_CALL(branch)

    ; patch IF's address
    POP_RET() ; DE has address of IF's 0x0000
    ex de, hl ; HL has address of IF's 0x0000
    ld de, (HERE)
    ld (hl), e
    inc hl
    ld (hl), d ; patched IF's 0x0000

    PUSH_RET() ; push addr of 0x0000 to return stack

    ld de, 0x0000
    call DICT_W

    ret
ENDWORD_FLAGS "else", word_else, RESERVED | IMMEDIATE

; Compile Only
WORD "then", word_then
    POP_RET() ; get the address of ELSE 0x0000
    ex de, hl ; HL has address of ELSE's 0x0000
    ld de, (HERE)
    ld (hl), e
    inc hl
    ld (hl), d ; patched ELSE's 0x0000

    ret
ENDWORD_FLAGS "then", word_then, RESERVED | IMMEDIATE
