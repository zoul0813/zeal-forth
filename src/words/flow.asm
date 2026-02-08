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
    PUSH_HERE() ; push addr to return stack
    ld de, 0x0000
    call DICT_W ; write addr
    ret
ENDWORD_FLAGS "if", word_if, RESERVED | IMMEDIATE

; ( -- ) [ orig1 -- orig2 ]
WORD "else", word_else
    ; compile an unconditional branch primitive with patchable target
    DICT_CALL(branch)

    ; patch IF's address
    POP_RET()   ; DE has address of IF's addr
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
    POP_RET() ; get the address of ELSE addr
    ex de, hl ; HL has address of ELSE's addr
    PATCH_HERE() ; patched ELSE's addr
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


; ( limit start -- )
do_init:
    POP()       ; DE = start
    ex de, hl
    POP()       ; DE = limit
    PUSH_RET()  ; [ -- limit ]
    ex de, hl
    JP_PUSH_RET()  ; [ -- limit index ]
;

; ( -- flag )
;
; flag = 0 when index == limit
do_loop:
    POP_RET()   ; DE = index
    ex de, hl   ; HL = index
    POP_RET()   ; DE = limit
    push de     ; backup limit

    push hl
    or a
    sbc hl, de  ; index == limit?
    pop hl
    jr z, @done

    ld de, TRUE
    PUSH()
    jr @return
@done:
    ld de, FALSE
    PUSH()

@return:
    pop de        ; restore limit
    PUSH_RET()    ; [ -- limit ]
    ex de, hl
    JP_PUSH_RET() ; [ -- limit index ]
;

do_next:
    POP_RET()          ; DE = index
    inc de             ; index++
    PUSH_RET()         ; write back updated index
    jp do_loop
;

do_unwind:
    POP_RET()   ; index
    POP_RET()   ; limit
    ret
;

WORD "do", word_do
    DICT_CALL(do_init)  ; setup the loop state
    ld de, 0x0000
    PUSH_RET()
    PUSH_HERE()
    ret
ENDWORD_FLAGS "do", word_do, RESERVED | IMMEDIATE

WORD "?do", word_do_query
    DICT_CALL(do_init)
    DICT_CALL(do_loop)  ; zero-trip test
    DICT_CALL(branch0)  ; branch to unwind when start == limit
    PUSH_HERE()         ; orig_exit patch site
    ld de, 0x0000
    call DICT_W
    PUSH_HERE()         ; loop body start (dest)
    ret
ENDWORD_FLAGS "?do", word_do_query, RESERVED | IMMEDIATE

WORD "loop", word_loop
    POP_RET()           ; DE = dest
    push de
    POP_RET()           ; DE = orig_exit
    push de
    DICT_CALL(do_next)  ; ( -- flag )
    DICT_CALL(branch0)  ; branch to unwind when index == limit
    PUSH_HERE()         ; local exit patch site
    ld de, 0x0000
    call DICT_W

    DICT_CALL(branch)   ; otherwise continue loop body
    pop hl              ; HL = orig_exit from DO
    pop de              ; DE = dest
    call DICT_W         ; LOOP back-edge target
    ld a, h
    or l
    jr z, @skip_do_query_patch
    PATCH_HERE()        ; patch ?DO zero-trip exit to unwind path
@skip_do_query_patch:

    POP_RET()           ; HL = local loop-exit patch site
    ex de, hl
    PATCH_HERE()        ; patch LOOP's done-exit to unwind path
    DICT_CALL(do_unwind)
    ret
ENDWORD_FLAGS "loop", word_loop, RESERVED | IMMEDIATE

WORD "i", word_i
    PEEK_RET()
    JP_PUSH()
ENDWORD_FLAGS "i", word_i, RESERVED
