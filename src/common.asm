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
    ; Numeric output supports the same bases as the input parser.
    ld hl, (BASE)
    ld a, h
    or a
    jp nz, @unsupported
    ld a, l
    cp 16
    jr z, @hex
    cp 10
    jp nz, @unsupported

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

    jr @print_buffer

@hex:
    ; Hex output exposes the raw unsigned 16-bit cell.
    ld hl, _str_buffer
    ld b, 4
    ld c, 0               ; non-zero after first emitted digit
@hex_digit:
    ld a, d
    rrca
    rrca
    rrca
    rrca
    and 0x0F
    jr nz, @hex_emit
    ld a, c
    or a
    jr nz, @hex_zero
    ld a, b
    cp 1
    jr nz, @hex_next
@hex_zero:
    xor a
@hex_emit:
    cp 10
    jr c, @hex_numeric
    add a, 'A' - 10
    jr @hex_store
@hex_numeric:
    add a, '0'
@hex_store:
    ld (hl), a
    inc hl
    ld c, 1
@hex_next:
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    sla e
    rl d
    djnz @hex_digit
    ld (hl), 0

@print_buffer:

    ; Set both HL and DE to _str_buffer
    ld hl, _str_buffer
    call strlen

    ; skip leading spaces without consuming the first non-space digit
@skip_space:
    ld a, b
    or c
    ret z
    ld a, (hl)
    cp ' '
    jr nz, @print
    inc hl
    dec bc
    jr @skip_space
@print:
    ; puts already jumps to _exit_code on error
    ex de, hl
    jp puts

@unsupported:
    ld a, ERR_UNSUPPORTED
    jp print_error
