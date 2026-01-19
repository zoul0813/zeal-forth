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

  MACRO RELOC_END _
    DEFW 0
  ENDM


  ; @brief Store HL in @params
  ;
  ; Parameters:
  ; - store_addr - the address of the param
  ; - HL         - the address to store
  MACRO STORE_HL store_addr
      ld (store_addr), hl
  ENDM

  ; @brief Calculate template size and save in store_addr
  ;
  ; Parameters:
  ; - store_addr - address to store the size in
  ; - temp_addr  - the addr of the template
  ; - temp_end   - the end of the template
  ;
  ; Returns:
  ; - HL - The size stored
  ;
  ; Alters:
  ;   DE, HL
  MACRO CALC_SIZE temp_addr, temp_end
    ld de, template_create@end - template_create
    add hl, de          ; `HERE` after allocating the template
  ENDM

    ; @brief Apply a code template
    ;
    ; Parameters:
    ; - temp_addr  - the addr of the template
    ; - temp_end   - the end of the template
    ; - temp_param - location of params
    ;
    ; Returns:
    ; - HL - Address where the template was stored
    ;
    ; Alters:
    ;   A, BC, DE, HL
  MACRO RELOC_TEMPLATE temp_addr, temp_end, temp_param
    ld hl, temp_addr
    ld bc, temp_end - temp_addr
    ld de, temp_param
    call reloc_apply_and_store
  ENDM

    ENDIF
