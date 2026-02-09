    INCLUDE "constants_h.asm"
    INCLUDE "zos_sys.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "macros_h.asm"

  SECTION TEXT

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
    ld de, _str_buffer
    ld (de), a
    ld bc, 1
    ; Fall-through (puts)

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

    PUBLIC puti
  ; @brief Print the number in DE
  ;
  ; Alters:
  ;   A, BC, DE, HL
puti:
    ; Signed output: print '-' and convert magnitude if value is negative.
    bit 7, d
    jr z, @convert
    push de
    ld a, '-'
    ; FIXME: putc will jump to _exit_code on error, it shouldn't in this case since `DE` is on the stack
    call putc
    pop de
    or a
    jp nz, _exit_code
    ; Carry is cleared because `or` was used above
    ld hl, 0
    sbc hl, de
    ex de, hl

@convert:
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
    ld a, ' '
@skip_space:
    cpi
    jr z, @skip_space
    ; puts already jumps to _exit_code on error
    ex de, hl
    jp puts
