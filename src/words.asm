    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"

;
; EXAMPLE:
;
;  ; bye (-- --) exit
;  WORD "bye", word_bye, word_bye_str
;      ld a, 0
;      jp _exit_code
;  ENDWORD "bye", word_bye, word_bye_str
;

  MACRO WORD name, label, str_label
  SECTION TEXT
label:
  ENDM

  MACRO ENDWORD name, label, str_label
    PUBLIC str_label
str_label:
    DEFM name, 0
  SECTION DATA
    DEFW label
    DEFW str_label
  SECTION TEXT
  ENDM

  SECTION DATA
    ; Associative table that will be added to the words hashtable on boot
    PUBLIC builtin_words
builtin_words:

  SECTION TEXT

; bye (-- --) exit
WORD "bye", word_bye, word_bye_str
    ld a, 0
    jp _exit_code
ENDWORD "bye", word_bye, word_bye_str

; ( n -- ) Display n in free field format.
WORD ".", word_dot, word_dot_str
    POPDATA()
    PUTI()
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD ".", word_dot, word_dot_str

WORD ".s", word_dot_s, word_dot_s_str
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
ENDWORD ".s", word_dot_s, word_dot_s_str

; ( n n -- n+n ) Add top two stack items
WORD "+", word_plus, word_plus_str
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
ENDWORD "+", word_plus, word_plus_str

; ( n n -- n-n ) Subtract top two stack items
WORD "-", word_minus, word_minus_str
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
ENDWORD "-", word_minus, word_minus_str

; ( n -- n n ) Duplicate top stack item
WORD "dup", word_dup, word_dup_str
    PEEKDATA()
    PUSHDATA()
    ret
ENDWORD "dup", word_dup, word_dup_str

; ( n -- ) Drop top stack item
WORD "drop", word_drop, word_drop_str
    ; Increment the data stack twice, no need to get the data
    ld hl, (data_sp)
    inc hl
    inc hl
    ld (data_sp), hl
    ret
ENDWORD "drop", word_drop, word_drop_str

; ( n -- u ) abs(n)
WORD "abs", word_abs, word_abs_str
    PEEKDATA()
    bit 7, d
    ret z
    jp word_negate_impl
ENDWORD "abs", word_abs, word_abs_str

; ( n -- -n ) neg(n)
WORD "negate", word_negate, word_negate_str
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
ENDWORD "negate", word_negate, word_negate_str

; ( a-addr -- x )
WORD "@", word_fetch, word_fetch_str
    POPDATA()

    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ex de, hl

    PUSHDATA()

    ret
ENDWORD "@", word_fetch, word_fetch_str

; (x a-addr -- )
WORD "!", word_store, word_store_str
    POPDATA()
    ex de, hl ; HL has address
    POPDATA() ; DE has value

    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store, word_store_str

; ( -- a-addr )
WORD "here", word_here, word_here_str
    ld hl, (here_sp)
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "here", word_here, word_here_str

; ( -- c-addr )
WORD "pad", word_pad, word_pad_str
    ld hl, (here_sp)
    ld de, PAD_OFFSET
    add hl, de
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "pad", word_pad, word_pad_str

; ( c -- )
WORD "emit", word_emit, word_emit_str
    POPDATA()
    ld a, e
    ld (_str_buffer), a
    PUTS(_str_buffer, _str_buffer + 1)
    ret
ENDWORD "emit", word_emit, word_emit_str

  SECTION DATA
    ; End of table
_buildin_words_end:
    DEFW 0
