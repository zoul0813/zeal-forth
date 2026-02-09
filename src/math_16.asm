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
    ; A is 0
    ld h, a
    ld l, a
    ld b, a
    ld c, a
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

; @brief Negate signed 16-bit HL in-place (two's complement).
;
; Parameters:
;   HL - value
;
; Returns:
;   HL - -value
;
; Alters:
;   A, HL
    PUBLIC _neg_hl
_neg_hl:
    ld a, h
    cpl
    ld h, a
    ld a, l
    cpl
    ld l, a
    inc hl
    ret

; @brief Floored signed 16-bit divide/mod core.
;
; Parameters:
;   HL - Dividend (n1)
;   DE - Divisor  (n2)
;
; Returns:
;   HL - Quotient (n1 / n2), floored
;   BC - Remainder (n1 mod n2), sign follows divisor
;
; Division by zero:
;   HL=0, BC=0
;
; Alters:
;   AF, BC, DE, HL
    PUBLIC __fdivmod_hl_de
__fdivmod_hl_de:
    xor a                  ; flags: bit0=quotient negative, bit1=divisor negative

    ; Normalize dividend to |dividend| and record sign.
    bit 7, h
    jr z, @dividend_abs_done
    call _neg_hl
    ld a, 1
@dividend_abs_done:

    ; Normalize divisor to |divisor|, record divisor sign, toggle quotient sign.
    bit 7, d
    jr z, @divisor_abs_done
    xor 00000001b          ; quotient sign ^= 1
    or 00000010b           ; divisor negative
    push af
    ex de, hl
    call _neg_hl
    ex de, hl
    pop af
@divisor_abs_done:

    push af
    call __udivmod_hl_de   ; HL=q0, BC=r0, DE=|divisor|
    pop af                 ; A = flags
    push af                ; keep flags on stack (DE must keep |divisor|)

    ; Floored quotient correction.
    rrca                    ; Check if A's bit 0 is 0 (nc)
    jr nc, @q_done          ; quotient non-negative
    ld a, b
    or c
    jr z, @q_exact
    call _neg_hl
    dec hl
    jr @q_done
@q_exact:
    call _neg_hl
@q_done:

    ; Remainder magnitude correction when quotient was rounded down.
    ld a, b
    or c
    jr z, @r_sign          ; remainder zero stays zero
    pop af
    push af
    ; Check lowest bit, nc if 0, c if 1
    rrca
    jr nc, @r_sign

    ; BC = |divisor| - BC
    push de                ; preserve |divisor|
    ; HL will be saved in DE
    ex de, hl
    or a
    sbc hl, bc
    ld b, h
    ld c, l
    ex de, hl
    pop de

@r_sign:
    ; Remainder sign follows divisor sign.
    pop af
    bit 1, a
    ret z
    push hl
    ld h, b
    ld l, c
    call _neg_hl
    ld b, h
    ld c, l
    pop hl
    ret
