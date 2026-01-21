    INCLUDE "constants_h.asm"
    INCLUDE "zos_sys.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "macros_h.asm"

  SECTION TEXT

    PUBLIC pushdata
  ; @brief Push 16-bit value onto data stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
pushdata:
    push hl
    ld hl, (data_sp)
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld (data_sp), hl
    pop hl
    ret

    PUBLIC popdata
  ; @brief Pop top data stack into DE
  ;
  ; Returns:
  ; - DE  - Value popped
popdata:
    push hl
    ld hl, (data_sp)
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (data_sp), hl
    pop hl
    ret

  ; @brief Peek top data stack into DE
  ;
  ; Alters:
  ;   DE
    PUBLIC peekdata
peekdata:
    push hl
    ld hl, (data_sp)
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    ret

    PUBLIC puts
  ; @brief Print str of length BC at DE
  ;
  ; Returns:
  ; - A  - ERR_SUCCESS on success, error value else
  ; - BC - Number of bytes written
  ;
  ; Alters:
  ;   A, H, DE, BC
puts:
    S_WRITE1(DEV_STDOUT)
    ERROR_CHECK()
    ret

    PUBLIC putc
  ; @brief Print c
  ;
  ; Returns:
  ; - A   - ERR_SUCCES on success, error value else
  ; - BC  - Number of bytes written
  ;
  ; Alters:
  ;   A, H, DE, BC
putc:
    ld (_str_buffer), a
    ld de, _str_buffer
    ld bc, 1
    call puts
    ret

    PUBLIC puti
  ; @brief Print the number in DE
  ;
  ; Alters:
  ;   A, BC, DE, HL
puti:
    ; store the 16-bit value in a 32-bit memory location
    ld (_dword_num), de
    ld hl, 0
    ld (_dword_num + 2), hl

    ld hl, _dword_num
    ld de, _str_buffer
    call dword_to_ascii_dec

    ; Set both HL and DE to _str_buffer
    ld hl, _str_buffer
    ld d, h
    ld e, l
    call strlen
    call puts
    or a
    jp nz, _exit_code
    ret
