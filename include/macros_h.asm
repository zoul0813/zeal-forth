#ifndef _MACROS_H_ASM
#define _MACROS_H_ASM

    INCLUDE "zos_sys.asm"
    INCLUDE "zos_keyboard.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "common_h.asm"



  ; @brief Jumps to _exit_code on error
  ;
  ; Parameters:
  ; - A  - error code
  ; Returns:
  ; - A  - ERR_SUCCESS on success
  MACRO ERROR_CHECK _
    or a
    jp nz, _exit_code
  ENDM

  ; @brief Read from STDIN into _input_buffer
  ; jumps to _exit_code on error
  ;
  ; Returns:
  ; - A  - ERR_SUCCESS on success, error value else
  ; - BC - Number of bytes filled in DE.
  ; - HL - Null-term input
  ;
  ; Alters:
  ;   A, H, DE, BC
  MACRO GET_INPUT _
    PUTS(_str_prompt, _str_prompt_end)
    ld h, DEV_STDIN
    ld de, _input_buffer
    ld bc, BUFFER_SIZE
    READ()
    ERROR_CHECK()

    ; replace newline with null-term
    ld a, 0x0A
    ld l, 0x00
    call memrep
    ld hl, _input_buffer
  ENDM

  ; @brief Switch to Block/Cooked KB Mode
  ;
  ; Alters:
  ;   H, C, DE, A
  MACRO KB_MODE_COOKED _
    ld h, DEV_STDIN
    ld c, KB_CMD_SET_MODE
    ld de, KB_READ_BLOCK | KB_MODE_COOKED
    IOCTL()
    ERROR_CHECK()
  ENDM

  ; @ brief Macro for strutils memset
  ; Initialize the memory pointed by HL with the byte given in E.
  ;
  ; Parameters:
  ; - HL - Memory address to initialize
  ; - BC - Size of the memory to initialize
  ; -  E  - Byte to initialize the memory with
  MACRO MEMSET addr, size, value
    ld hl, addr
    ld bc, size
    ld e, value
    call memset
  ENDM

  ; @brief Parse string in HL into a 16-bit value and return in DE
  ;
  ; Parameters:
  ; - HL - Address of string to parse
  ;
  ; Returns:
  ; - HL - Address of string
  ; - DE - 16-bit value
  ; -  A - 0=success, 1=too large, 2=non-digit
  MACRO PARSEINT str
    push hl
    ld hl, (str)
    ;; convert ascii decimal to 16-bit
    call parse_int
    ex de, hl ; put 16-bit value in DE
    pop hl
  ENDM

  ; @brief Push 16-bit value onto data stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
  ;
  ; Alters:
  ;   HL
  MACRO PUSH _
    call pushdata
  ENDM

  MACRO JP_PUSH _
    jp pushdata
  ENDM

  ; @brief Pop top data stack into DE
  ;
  ;
  ; Returns:
  ; - DE  - Value popped
  MACRO POP _
    call popdata
  ENDM

  ; @brief Peek top data stack into DE
  ;
  ; Alters:
  ;   DE
  MACRO PEEK _
    call peekdata
  ENDM


  ; @brief Push 16-bit value onto return stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
  ;
  ; Alters:
  ;   HL
  MACRO PUSH_RET _
    call pushreturn
  ENDM

  MACRO JP_PUSH_RET _
    jp pushreturn
  ENDM

  ; @brief Pop top return stack into DE
  ;
  ;
  ; Returns:
  ; - DE  - Value popped
  MACRO POP_RET _
    call popreturn
  ENDM

  ; @brief Peek top return stack into DE
  ;
  ; Alters:
  ;   DE
  MACRO PEEK_RET _
    call peekreturn
  ENDM




  ; @brief Print str until str_end
  ;
  ; Returns:
  ; - A  - ERR_SUCCESS on success, error value else
  ; - BC - Number of bytes written
  ;
  ; Alters:
  ;   A, H, DE, BC
  MACRO PUTS str, str_end
    ld de, str
    ld bc, str_end - str
    call puts
  ENDM

  ; @brief Print c
  ;
  ; Returns:
  ; - A   - ERR_SUCCES on success, error value else
  ; - BC  - Number of bytes written
  ;
  ; Alters:
  ;   A, H, DE, BC
  MACRO PUTC chr
    ld a, chr
    call putc
  ENDM

  ; @brief Print the number in DE
  ;
  ; Alters:
  ;   A, BC, DE, HL
  MACRO PUTI _
    call puti
  ENDM

  ; @brief Set the forth state to state
  ;
  ; Parameters:
  ; - state - The state to set
  MACRO SET_STATE state
    ld a, state
    ld (_state), a
  ENDM

  ; @brief If state, `jp z, goto`
  ;
  ; Parameters:
  ; - state - The state to compare
  ; - goto  - The address to goto if state matches
  MACRO IF_STATE state, goto
    ld a, (_state)
    cp state
    jp z, goto
  ENDM

#endif
