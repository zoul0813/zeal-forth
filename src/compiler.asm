    INCLUDE "constants_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "compiler_h.asm"

    SECTION TEXT

;******************************************************************************
;*                            PUBLIC  ROUTINES                                *
;******************************************************************************
    ; Copy a template into HERE and apply patch table entries.
    ; Parameters:
    ;   HL - Template start
    ;   BC - Template size in bytes
    ;   DE - Patch table (entries terminated by 0)
    ; Returns:
    ;   HL - Base address of copied template
    ; Alters:
    ;   A, BC, DE, HL, IY, IX
apply_template:
    ld iy, de         ; IY = patch table
    push hl           ; preserve template start
    call load_pad_ix
    pop hl
    ld de, (here_sp)  ; DE = dest
    ld (ix + TP_BASE), e
    ld (ix + TP_BASE + 1), d
@copy_template:
    ld a, b
    or c
    jr z, @copy_done
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    dec bc
    jr @copy_template
@copy_done:
    ld l, (ix + TP_BASE)
    ld h, (ix + TP_BASE + 1)
    ld c, (ix + TP_SIZE)
    ld b, (ix + TP_SIZE + 1)
    add hl, bc
    ld (ix + TP_END), l
    ld (ix + TP_END + 1), h
    call apply_template_patches
    ld l, (ix + TP_BASE)
    ld h, (ix + TP_BASE + 1)
    ld c, (ix + TP_SIZE)
    ld b, (ix + TP_SIZE + 1)
    add hl, bc
    ld (here_sp), hl  ; update HERE
    ld l, (ix + TP_BASE)
    ld h, (ix + TP_BASE + 1)
    ret

    ; Apply patch table entries to the already-copied template.
    ; Parameters:
    ;   IY - Patch table (entries terminated by 0)
    ;   IX - PAD base (here_sp + PAD_OFFSET)
    ;   (ix + TP_BASE) contains base address of copied template
    ; Returns:
    ;   HL - last patched address (advanced during loop)
    ; Alters:
    ;   A, BC, DE, HL, IY
apply_template_patches:
@patch_loop:
    ld a, (iy+0)
    or a
    ret z
    ld l, a
    ld h, 0
    push bc
    ld c, (ix + TP_BASE)
    ld b, (ix + TP_BASE + 1)
    add hl, bc
    pop bc
    inc iy
    ld a, (iy+0)
    inc iy
    ld b, a
    and 0x7F
    ld e, a
    ld d, 0
    push hl
    push bc
    push ix
    pop hl
    add hl, de
    ex de, hl          ; DE = PAD + offset
    pop bc
    pop hl
    ld a, b
    and TP_PATCH_16
    jr z, @patch8
    ld a, (de)
    ld (hl), a
    inc de
    inc hl
@patch8:
    ld a, (de)
    ld (hl), a
    jp @patch_loop

    ; Load IX with PAD base derived from HERE.
    ; Parameters:
    ;   (here_sp) - current HERE
    ; Returns:
    ;   IX - here_sp + PAD_OFFSET
    ; Alters:
    ;   HL, DE, IX
load_pad_ix:
    ld hl, (here_sp)
    ld de, PAD_OFFSET
    add hl, de
    ld ix, hl
    ret
