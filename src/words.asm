    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "math_h.asm"

;
; EXAMPLE:
;
;  ; bye (-- --) exit
;  WORD "bye", word_bye
;      ld a, 0
;      jp _exit_code
;  ENDWORD "bye", word_bye
;

  MACRO WORD name, label
  SECTION TEXT
label:
  ENDM

  MACRO ENDWORD name, label
@str:
    DEFM name, 0
  SECTION DATA
    DEFW label
    DEFW @str
  SECTION TEXT
  ENDM

  SECTION DATA
    ; Associative table that will be added to the words hashtable on boot
    PUBLIC builtin_words
builtin_words:

  SECTION TEXT

; bye (-- --) exit
WORD "bye", word_bye
    ld a, 0
    jp _exit_code
ENDWORD "bye", word_bye

; ( n -- ) Display n in free field format.
WORD ".", word_dot
    POPDATA()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD ".", word_dot

; ( n n -- n+n ) Add top two stack items
WORD "+", word_plus
    POPDATA()   ; DE = n1
    ex de, hl   ; HL = n1
    POPDATA()   ; DE = n2
    add hl, de
    ex de, hl

    PUSHDATA()
    ret
ENDWORD "+", word_plus

; ( n1 n2 -- n1-n2 ) Subtract top two stack items
WORD "-", word_minus
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "-", word_minus

; ( n1 n2 -- n3 )
WORD "*", word_mul
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    call __mul_hl_de
    PUSHDATA()

    ret
ENDWORD "*", word_mul

; ( n1 n2 -- n3 )
WORD "/", word_div
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    call __div_hl_de
    PUSHDATA()

    ret
ENDWORD "/", word_div

; ( n1 n2 -- n3 )
WORD "mod", word_mod
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl

    call __mod_hl_de
    PUSHDATA()

    ret
ENDWORD "mod", word_mod

; ( n -- n n ) Duplicate top stack item
WORD "dup", word_dup
    PEEKDATA()  ; DE = n
    PUSHDATA()
    ret
ENDWORD "dup", word_dup

; ( n -- ) Drop top stack item
WORD "drop", word_drop
    ; Increment the data stack twice, no need to get the data
    ld hl, (data_sp)
    inc hl
    inc hl
    ld (data_sp), hl
    ret
ENDWORD "drop", word_drop

; ( n1 n2 -- n2 n1 )
WORD "swap", word_swap
    POPDATA() ; DE = n2
    ex de, hl ; HL = n2
    POPDATA() ; DE = n1
    ex de, hl ; DE = n2, HL = n1
    PUSHDATA() ; push n2
    ex de, hl
    PUSHDATA() ; push n1
    ret
ENDWORD "swap", word_swap

; ( n1 n2 -- n1 n2 n1 )
WORD "over", word_over
    ld hl, (data_sp)
    inc hl
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    PUSHDATA()
    ret
ENDWORD "over", word_over

; ( n1 n2 n3 -- n2 n3 n1 )
WORD "rot", word_rot
    POPDATA()   ; DE = n3
    ld b, d
    ld c, e     ; BC = n3
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; HL = n1, DE = n2
    PUSHDATA()  ; push n2
    ld d, b
    ld e, c     ; DE = n3
    PUSHDATA()  ; push n3
    ex de, hl   ; HL = n3, DE = n1
    PUSHDATA()  ; push n1
    ret
ENDWORD "rot", word_rot

; ( n1 n2 -- flag )
WORD "=", word_equal
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, h
    cp d
    jr nz, @not_equal
    ld a, l
    cp e
    jr z, @equal

@not_equal:
    ld de, FALSE
    PUSHDATA()
    ret
@equal:
    ld de, TRUE
    PUSHDATA()
    ret
ENDWORD "=", word_equal

; ( n1 n2 -- flag )
WORD "<", word_lessthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr c, @true

@false:
    ld de, FALSE
    PUSHDATA()
    ret

@true:
    ld de, TRUE
    PUSHDATA()
    ret
ENDWORD "<", word_lessthan

WORD ">", word_greaterthan
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1
    ex de, hl   ; DE = n2, HL = n1

    or a
    sbc hl, de
    jr z, @false
    jr nc, @true

@false:
    ld de, FALSE
    PUSHDATA()
    ret
@true:
    ld de, TRUE
    PUSHDATA()
    ret

ENDWORD ">", word_greaterthan

; ( n1 n2 -- n3 )
WORD "and", word_and
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    and h
    ld d, a

    ld a, e
    and l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "and", word_and

; ( n1 n2 -- n3 )
WORD "or", word_or
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    or h
    ld d, a

    ld a, e
    or l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "or", word_or

WORD "xor", word_xor
    POPDATA()   ; DE = n2
    ex de, hl   ; HL = n2
    POPDATA()   ; DE = n1

    ld a, d
    xor h
    ld d, a

    ld a, e
    xor l
    ld e, a

    PUSHDATA()  ; push n3
    ret
ENDWORD "xor", word_xor

; ( n1 -- n2 )
WORD "invert", word_invert
    POPDATA()   ; DE = n1

    ld a, d
    cpl
    ld d, a

    ld a, e
    cpl
    ld e, a

    PUSHDATA()
    ret
ENDWORD "invert", word_invert

; ( n -- u ) abs(n)
WORD "abs", word_abs
    PEEKDATA()
    bit 7, d
    ret z
    jp word_negate_impl
ENDWORD "abs", word_abs

; ( n -- -n ) neg(n)
WORD "negate", word_negate
word_negate_impl:
    POPDATA()
    ; -DE = ~DE + 1
    ld a, d
    cpl
    ld d, a
    ld a, e
    cpl
    ld e, a
    inc de
    PUSHDATA()
    ret
ENDWORD "negate", word_negate

; ( a-addr -- x )
WORD "@", word_fetch
    POPDATA()

    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ex de, hl

    PUSHDATA()

    ret
ENDWORD "@", word_fetch

; (x a-addr -- )
WORD "!", word_store
    POPDATA()
    ex de, hl ; HL has address
    POPDATA() ; DE has value

    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store

; ( -- a-addr )
WORD "here", word_here
    ld hl, (here_sp)
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "here", word_here

; ( -- c-addr )
WORD "pad", word_pad
    ld hl, (here_sp)
    ld de, PAD_OFFSET
    add hl, de
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "pad", word_pad

; ( c -- )
WORD "emit", word_emit
    POPDATA()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret
ENDWORD "emit", word_emit

; TODO - implement return stack manipulation
; WORD ">r", word_return_push
;     POPDATA()
;     push de
;     ret
; ENDWORD ">r", word_return_push

; WORD "r>", word_return_pop
;     pop de
;     PUSHDATA()
;     ret
; ENDWORD "r>", word_return_pop

; TODO - Reimplement in Forth once able
; DEBUG WORDS

WORD ".s", word_dot_s
    PUTC('<')
    ; calculate number of items
    ld hl, data_stack + DATA_STACK_SIZE
    ld de, (data_sp)
    or a ; clear carry
    sbc hl, de
    srl l ; divide by two (cell size = 2)
    rr h
    ; print count
    ex de, hl
    push de
    PUTI()
    PUTC('>')
    PUTC(' ')
    pop de
    ; check if stack is empty
    ld a, d
    or e
    ret z ; stack is empty, just return

    ; print each item (bottom up)
    ld hl, data_stack + DATA_STACK_SIZE - CELL_SIZE
@next:
    push hl
    ld de, (data_sp)
    or a
    sbc hl, de
    pop hl
    jr c, @done ; HL < data_sp

    ld e, (hl)
    inc hl
    ld d, (hl)
    dec hl

    push hl
    PUTI()
    PUTC(' ')
    pop hl

    dec hl
    dec hl

    jr @next

@done:
    ret
ENDWORD ".s", word_dot_s


  SECTION DATA
    ; End of table
_buildin_words_end:
    DEFW 0



