    IFNDEF _COMPILER_H_ASM
    DEFINE _COMPILER_H_ASM

    ; Compiler relocation format
    DEFC PARAM_IMM8  = 0
    DEFC PARAM_IMM16 = 1

    EXTERN apply_template

  MACRO PARAM addr, type
    DEFW addr
    DEFB type
  ENDM

  MACRO PARAM_END _
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

  ; @brief Calculate template size, add to HL and save in store_addr
  ;
  ; Parameters:
  ; - HL         - Starting address size will be added to
  ; - temp_addr  - the addr of the template
  ; - temp_end   - the end of the template
  ;
  ; Returns:
  ; - HL - The size
  ;
  ; Alters:
  ;   DE, HL
  MACRO OFFSET_HL temp_addr, temp_end
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
  MACRO APPLY_TEMPLATE temp_addr, temp_end, temp_param
    ld hl, temp_addr
    ld bc, temp_end - temp_addr
    ld de, temp_param
    call apply_template
  ENDM

    ENDIF
