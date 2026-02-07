#ifndef _COMPILER_H_ASM
#define _COMPILER_H_ASM

    ; @brief compiles: call nn
    ;
    ; Returns:
    ; - DE - nn
    ;
    ; Alters: A, DE
    MACRO DICT_CALL nn
      ld a, 0xCD  ; call nn
      call DICT_C
      ld de, nn
      call DICT_W
    ENDM

    ; @brief compiles: jp nn
    ;
    ; Returns:
    ; - DE - nn
    ; -  A - 0xC3 (jp nn)
    ;
    ; Alters: A, DE
    MACRO DICT_JP nn
      ld a, 0xC3 ; jp nn
      call DICT_C
      ld de, nn
      call DICT_W
    ENDM

    ; @brief compiles: n
    ;
    ; Returns:
    ; -  A - n
    ;
    ; Alters: A
    MACRO DICT_INS n
      ld a, n
      call DICT_C
    ENDM

    ; @brief Push HERE onto return stack
    ;
    ; ld de, (HERE)
    ;
    ; PUSH_RET()
    ;
    MACRO PUSH_HERE _
      ld de, (HERE)
      PUSH_RET()
    ENDM

    ; @brief Patch HL with HERE
    ;
    ; Parameters:
    ; - HL - The address to patch
    ;
    ; Alters: DE, HL
    MACRO PATCH_HERE _
      ld de, (HERE)
      ld (hl), e
      inc hl
      ld (hl), d
    ENDM

#endif