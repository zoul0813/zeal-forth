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

; @brief Unsigned 16-bit divide core (shared by /, mod, /mod)
;
; Uses restoring long division with a fixed 16-iteration loop.
;
; Parameters:
;   HL - Dividend
;   DE - Divisor
;
; Returns:
;   HL - Quotient
;   BC - Remainder
;
; Division by zero:
;   HL=0, BC=0
;
; Alters:
;   AF, BC, DE, HL
    PUBLIC __udivmod_hl_de
__udivmod_hl_de:
    ld a, d
    or e
    jr nz, @start
    ld hl, 0
    ld bc, 0
    ret

@start:
    ld bc, 0          ; remainder
    ld a, 16
    ex af, af'        ; A' = loop counter, A free for compares

@loop:
    add hl, hl        ; quotient <<= 1, carry gets next dividend bit
    rl c
    rl b              ; remainder = (remainder << 1) | carry

    ; if (remainder >= divisor) { remainder -= divisor; quotient |= 1; }
    ld a, b
    cp d
    jr c, @next
    jr nz, @subtract
    ld a, c
    cp e
    jr c, @next

@subtract:
    ld a, c
    sub e
    ld c, a
    ld a, b
    sbc a, d
    ld b, a
    ; After add hl,hl the low bit is always 0, so setting it to 1 is inc l.
    inc l

@next:
    ex af, af'
    dec a
    jr z, @done
    ex af, af'
    jr @loop

@done:
    ex af, af'
    ret
