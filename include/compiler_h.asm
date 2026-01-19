    IFNDEF _COMPILER_H_ASM
    DEFINE _COMPILER_H_ASM

    ; Compiler relocation format
    DEFC RELOC_IMM8  = 0
    DEFC RELOC_IMM16 = 1

    EXTERN reloc_apply_and_store

    MACRO RELOC addr, type
    DEFW addr
    DEFB type
    ENDM

    MACRO RELOC_TEMPLATE temp_addr, temp_end, temp_param
    ld hl, temp_addr
    ld bc, temp_end - temp_addr
    ld de, temp_param
    call reloc_apply_and_store
    ENDM

    MACRO RELOC_END _
    DEFW 0
    ENDM

    ENDIF
