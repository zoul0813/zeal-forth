; 8-bit mul/div/mod

  SECTION TEXT

; @brief Multiply A by L (unsigned 8-bit multiplication)
;
; Performs unsigned multiplication using repeated addition.
; Short-circuits if either operand is zero.
;
; Parameters:
;   A - Multiplicand (8-bit unsigned)
;   L - Multiplier (8-bit unsigned)
;
; Returns:
;   A - Product (A * L, lower 8 bits only)
;
; Alters:
;   A, BC
;
    PUBLIC __mul_a_l
__mul_a_l:
    ld b, l      ; multiplier (loop counter)
    ld c, a      ; multiplicand
    ld a, b
    or c
    ret z        ; short-circuit if either operand is zero
    ld a, 0      ; result accumulator
__mul_loop:
    add a, c
    djnz __mul_loop
    ret

; @brief Divide A by L (unsigned 8-bit division)
;
; Performs unsigned division using repeated subtraction.
; Division by zero returns 0.
;
; Parameters:
;   A - Dividend (8-bit unsigned)
;   L - Divisor (8-bit unsigned)
;
; Returns:
;   A - Quotient (A / L)
;
; Alters:
;   A, BC
;
    PUBLIC __div_a_l
__div_a_l:
    ld c, a      ; dividend
    ld a, l
    or a
    ret z        ; divide by zero -> 0
    ld b, 0      ; quotient
__div_loop:
    ld a, c
    cp l
    jr c, __div_done
    sub l
    ld c, a
    inc b
    jr __div_loop
__div_done:
    ld a, b      ; result = quotient
    ret

; @brief Modulo A by L (unsigned 8-bit remainder)
;
; Performs unsigned modulo using repeated subtraction.
; Division by zero returns 0.
;
; Parameters:
;   A - Dividend (8-bit unsigned)
;   L - Divisor (8-bit unsigned)
;
; Returns:
;   A - Remainder (A % L)
;
; Alters:
;   A, BC
;
    PUBLIC __mod_a_l
__mod_a_l:
    ld b, l      ; divisor
    ld c, a      ; remainder working copy
    ld a, b
    or a
    ret z        ; divide by zero -> 0
__mod_loop:
    ld a, c
    cp b
    jr c, __mod_done
    sub b
    ld c, a
    jr __mod_loop
__mod_done:
    ld a, c
    ret
