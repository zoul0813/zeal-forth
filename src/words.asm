    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"

  SECTION TEXT

; bye (-- --) exit
word_bye:
    ld a, 0
    jp _exit_code

; ( n -- ) Display n in free field format.
word_dot:
    POPDATA()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret

word_dot_s:
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

; ( n n -- n+n ) Add top two stack items
word_plus:
    ; Pop first word in HL
    POPDATA()
    ex de, hl
    ; Pop second word in DE
    POPDATA()
    add hl, de
    ; Put result in DE and push it
    ex de, hl
    PUSHDATA()
    ret

; ( n n -- n-n ) Subtract top two stack items
word_minus:
    POPDATA()
    ex de, hl
    POPDATA()
    ; Put hte first word back in HL
    ex de, hl
    ; Clear flag
    or a
    sbc hl, de
    ex de, hl
    PUSHDATA()
    ret

; ( n -- n n ) Duplicate top stack item
word_dup:
    PEEKDATA()
    PUSHDATA()
    ret

; ( n -- ) Drop top stack item
word_drop:
    ; Increment the data stack twice, no need to get the data
    ld hl, (data_sp)
    inc hl
    inc hl
    ld (data_sp), hl
    ret

; ( n -- u ) abs(n)
word_abs:
    PEEKDATA()
    bit 7, d
    ret z
    ; Fall-through to word_negate

; ( n -- -n ) neg(n)
word_negate:
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

; ( a-addr -- x )
word_fetch:
    POPDATA()

    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ex de, hl

    PUSHDATA()

    ret

; (x a-addr -- )
word_store:
    POPDATA()
    ex de, hl ; HL has address
    POPDATA() ; DE has value

    ld (hl), e
    inc hl
    ld (hl), d

    ret

; ( -- a-addr )
word_here:
    ld hl, (here_sp)
    ex de, hl
    PUSHDATA()
    ret

; ( -- c-addr )
word_pad:
    ld hl, (here_sp)
    ld de, PAD_OFFSET
    add hl, de
    ex de, hl
    PUSHDATA()
    ret

; ( c -- )
word_emit:
    POPDATA()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret

  SECTION DATA
_bye_str:
    DEFM "bye", 0
_dot_str:
    DEFM ".", 0
_dot_s_str:
    DEFM ".s", 0
_plus_str:
    DEFM "+", 0
_minus_str:
    DEFM "-", 0
_negate_str:
    DEFM "negate", 0
_abs_str:
    DEFM "abs", 0
_dup_str:
    DEFM "dup", 0
_drop_str:
    DEFM "drop", 0
_fetch_str:
    DEFM "@", 0
_store_str:
    DEFM "!", 0
_here_str:
    DEFM "here", 0
_pad_str:
    DEFM "pad", 0
_emit_str:
    DEFM "emit", 0



    ; Associative table that will be added to the words hashtable on boot
    PUBLIC builtin_words
builtin_words:
    DEFW word_bye
    DEFW _bye_str

    DEFW word_dot
    DEFW _dot_str

    DEFW word_dot_s
    DEFW _dot_s_str

    DEFW word_plus
    DEFW _plus_str

    DEFW word_minus
    DEFW _minus_str

    DEFW word_negate
    DEFW _negate_str

    DEFW word_abs
    DEFW _abs_str

    DEFW word_dup
    DEFW _dup_str

    DEFW word_drop
    DEFW _drop_str

    DEFW word_fetch
    DEFW _fetch_str

    DEFW word_store
    DEFW _store_str

    DEFW word_here
    DEFW _here_str

    DEFW word_pad
    DEFW _pad_str

    DEFW word_emit
    DEFW _emit_str

    ; End of table
_buildin_words_end:
    DEFW 0