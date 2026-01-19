    INCLUDE "constants_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "compiler_h.asm"

    SECTION TEXT

;******************************************************************************
;*                            PUBLIC  ROUTINES                                *
;******************************************************************************

    ; Relocate a template and store at `HERE`.
    ;
    ; Parameters:
    ; - HL - Template address, MUST be followed by the relocation array
    ; - BC - Template size in bytes
    ; - DE - Relocation parameters, must be as big as the reloation array
    ;
    ; Returns:
    ; -  HL - Address where the template was saved
    ;
    ; Alters:
    ;   A, BC, DE, HL
    PUBLIC reloc_apply_and_store
reloc_apply_and_store:
    ; Calculate the relocation array address
    push hl
    push bc
    add hl, bc
    ; Apply the modifications to the template (in place)
    call reloc_apply
    ; Get back the size of the template and the template address
    pop bc
    ; Allocate BC bytes in `HERE`, keep the address in DE for the copy
    ld hl, (here_sp)
    ld d, h
    ld e, l
    add hl, bc
    ld (here_sp), hl
    ; Copy the relocated template (BC bytes) to the address pointed by DE
    ; Get back the template address, keep the destination on the stack to return it
    pop hl
    push de
    ldir
    pop hl
    ret


    ; Apply relocations array with the given parameters.
    ;
    ; Parameters:
    ; - HL - Relocation array, must end with RELOC_END()
    ; - DE - Relocation parameters, must be as big as the reloation array
    ;
    ; Alters:
    ;   A, BC, DE, HL
reloc_apply:
    ; Browse the relocation array, dereference the first address
    ld c, (hl)
    inc hl
    ld b, (hl)
    ; Stop when we find RELOC_END (0)
    ld a, b
    or c
    ret z
    inc hl
    ; BC contains the address to patch, HL points to the type of relocation
    ld a, (hl)
    inc hl
    cp RELOC_IMM8
    jr z, @imm8
    cp RELOC_IMM16
    jr z, @imm16
    ; TODO: add more relocations type here
    ; Unknown relocation type, ignore
    jr reloc_apply
@imm16:
    ; DE contains the 16-bit parameter we have to store in BC
    ld a, (de)
    ld (bc), a
    inc de
    inc bc
    ; Fall-thru
@imm8:
    ; DE contains the parameters
    ld a, (de)
    inc de
    ; Store it in the destination address
    ld (bc), a
    jr reloc_apply
