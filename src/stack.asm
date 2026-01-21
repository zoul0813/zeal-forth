    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"

    MACRO STACK_PUSH stack_sp
    push hl
    ld hl, (stack_sp)
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld (stack_sp), hl
    pop hl
    ENDM

    MACRO STACK_POP stack_sp
    push hl
    ld hl, (stack_sp)
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (stack_sp), hl
    pop hl
    ENDM

    MACRO STACK_PEEK stack_sp
    push hl
    ld hl, (stack_sp)
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    ENDM


    SECTION TEXT

    PUBLIC pushdata
  ; @brief Push 16-bit value onto data stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
pushdata:
    STACK_PUSH(data_sp)
    ret


    PUBLIC popdata
  ; @brief Pop top data stack into DE
  ;
  ; Returns:
  ; - DE  - Value popped
popdata:
    STACK_POP(data_sp)
    ret

  ; @brief Peek top data stack into DE
  ;
  ; Alters:
  ;   DE
    PUBLIC peekdata
peekdata:
    STACK_PEEK(data_sp)
    ret


    PUBLIC pushreturn
  ; @brief Push 16-bit value onto return stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
pushreturn:
    STACK_PUSH(return_sp)
    ret


    PUBLIC popreturn
  ; @brief Pop top return stack into DE
  ;
  ; Returns:
  ; - DE  - Value popped
popreturn:
    STACK_POP(return_sp)
    ret

  ; @brief Peek top return stack into DE
  ;
  ; Alters:
  ;   DE
    PUBLIC peekreturn
peekreturn:
    STACK_PEEK(return_sp)
    ret


