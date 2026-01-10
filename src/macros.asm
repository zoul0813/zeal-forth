  ; @brief Jumps to _exit_code on error
  ;
  ; Parameters:
  ;   A  - error code
  ; Returns:
  ;   A  - ERR_SUCCESS on success
  MACRO ERROR_CHECK _
    or a
    jp nz, _exit_code
  ENDM

  ; @brief Read from STDIN into _input_buffer
  ; jumps to _exit_code on error
  ;
  ; Returns:
  ;   A  - ERR_SUCCESS on success, error value else
  ;   BC - Number of bytes filled in DE.
  ;   HL - Null-term input
  ;
  ; Alters:
  ;   A, H, DE, BC
  MACRO GET_INPUT _
    PRINT(_str_prompt, _str_prompt_end)
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

  ; @brief Print str until str_end
  ;
  ; Returns:
  ;   A  - ERR_SUCCESS on success, error value else
  ;   BC - Number of bytes filled in DE.
  ;
  ; Alters:
  ;   A, H, DE, BC
  MACRO PRINT str, str_end
    S_WRITE3(DEV_STDOUT, str, str_end - str)
    ERROR_CHECK()
  ENDM

  ; @brief Switch to Block/Cooked KB Mode
  ;
  ; Alters:
  ;  H, C, DE, A
  MACRO KB_MODE_COOKED _
    ld h, DEV_STDIN
    ld c, KB_CMD_SET_MODE
    ld de, KB_READ_BLOCK | KB_MODE_COOKED
    IOCTL()
    ERROR_CHECK()
  ENDM