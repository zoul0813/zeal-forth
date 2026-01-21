    INCLUDE "constants_h.asm"
    INCLUDE "zos_sys.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "macros_h.asm"

  SECTION TEXT

    PUBLIC puts
  ; @brief Print str of length BC at DE
  ;
  ; Parameters:
  ; - DE - Buffer to write
  ; - BC - Length of buffer
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
    call strlen

    ; skip spaces
@skip_space:
    ld a, (hl)
    cp ' '
    jr nz, @print
    inc hl
    dec bc
    jr @skip_space

@print:
    ld d, h
    ld e, l
    call puts
    or a
    jp nz, _exit_code
    ret
