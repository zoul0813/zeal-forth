; 16-bit mul/div/mod
    INCLUDE "math_h.asm"

  SECTION TEXT

; @brief Multiply HL by DE (unsigned 16-bit multiplication)
;
; Performs unsigned multiplication using a shift-and-add algorithm.
;
; Parameters:
;   HL - Multiplicand (16-bit unsigned)
;   DE - Multiplier (16-bit unsigned)
;
; Returns:
;   DE - Product (HL * DE, lower 16 bits only)
;
; Alters:
;   A, BC, DE, HL
;
    PUBLIC __mul_hl_de
__mul_hl_de:
    ld b, h
    ld c, l
    ld hl, 0
    ld a, 16
__mul_hl_de_l:
    bit 0, e
    jr z, __mul_hl_de_s
    add hl, bc
__mul_hl_de_s:
    sla c
    rl b
    srl d
    rr e
    dec a
    jr nz, __mul_hl_de_l
    ex de, hl
    ret

; @brief Divide HL by DE (unsigned 16-bit division)
;
; Performs unsigned division using repeated subtraction.
; Division by zero returns 0.
;
; Parameters:
;   HL - Dividend (16-bit unsigned)
;   DE - Divisor (16-bit unsigned)
;
; Returns:
;   DE - Quotient (HL / DE)
;
; Alters:
;   A, BC, DE, HL
;
    PUBLIC __div_hl_de
__div_hl_de:
    ld a, d
    or e
    jr nz, __div_hl_de_l
    ld de, 0
    ret
__div_hl_de_l:
    ld bc, 0
__div_hl_de_i:
    or a
    sbc hl, de
    jr c, __div_hl_de_d
    inc bc
    jr __div_hl_de_i
__div_hl_de_d:
    add hl, de
    ld h, b
    ld l, c
    ex de, hl
    ret

; @brief Modulo HL by DE (unsigned 16-bit remainder)
;
; Performs unsigned modulo using repeated subtraction.
; Division by zero returns 0.
;
; Parameters:
;   HL - Dividend (16-bit unsigned)
;   DE - Divisor (16-bit unsigned)
;
; Returns:
;   DE - Remainder (HL % DE)
;
; Alters:
;   A, DE, HL
;
    PUBLIC __mod_hl_de
__mod_hl_de:
    ld a, d
    or e
    jr nz, __mod_hl_de_l
    ld de, 0
    ret
__mod_hl_de_l:
    or a
    sbc hl, de
    jr c, __mod_hl_de_d
    jr __mod_hl_de_l
__mod_hl_de_d:
    add hl, de
    ex de, hl
    ret
