    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "words_h.asm"

    EXTERN word_semicolon
    EXTERN word_forget@drop
    EXTERN _neg_hl

  SECTION TEXT

; @brief Parse numeric token according to BASE policy.
;
; Parameters:
; - HL - token start
;
; Returns:
; - HL - parsed value on success
; -  A - 0=success, 1=too large, 2=not-number, or ERR_UNSUPPORTED for invalid BASE
parse_by_base:
    ld a, (BASE)
    cp 16
    jr z, @hex
    cp 10
    jr z, @dec
    ld a, ERR_UNSUPPORTED
    ret
@hex:
    jp parse_hex
@dec:
    ; Keep parse_int behavior in decimal mode so explicit hex prefixes like
    ; $EA/0xEA continue to work.
    jp parse_int

; @brief Show the prompt
prompt:
    ld (_recovery_sp), sp
    KB_MODE_COOKED()
    GET_INPUT()
    KB_MODE_RAW()

    ld hl, _input_buffer
    ld (_next_word), hl

; @brief Process next word in input buffer
do_next_word:
    call next_word
    jp z, print_ok

    call dict_search
    ; If A is 0, the word was found
    or a
    jr z, @is_word ; word found, execute

    ld hl, (_curr_word)

    ; Try to parse the input as a number.
    ; Support optional leading '-' for signed decimal literals.
    ld a, (hl)
    cp '-'
    jr nz, @parse_unsigned
    inc hl
    ld a, (hl)
    or a
    jr z, @not_found          ; "-" alone is not a number
    call parse_by_base
    or a
    jr z, @is_negative_number
    dec a
    jp z, numeric_overflow
    ; jr @not_found             ; non-decimal value, fall-through to word lookup
@not_found:
    ld a, ERR_NOT_FOUND
    jr print_error

@parse_unsigned:
    call parse_by_base
    ; If A is 0, the current word is a number
    or a
    jr z, @is_number
    ; If A is 1, the value is bigger than 16-bit, so skip this word
    dec a
    jp z, numeric_overflow
    ; Non-decimal value, treat as a word.
    jr @not_found

@is_negative_number:
    ; HL = magnitude, convert to two's-complement negative in place.
    call _neg_hl
    jr @is_number

@is_word:
    ; HL = current entry
    inc hl
    inc hl  ; HL = dict_flags
    ld c, (hl) ; C = dict_flags

    ld a, (STATE)
    cp STATE_COMP
    jr z, @compile_mode ; compiling, check if immediate

    bit BIT_RESERVED, c
    jr nz, @compileonly ; this is a compile only word
    jr @imm_word ; just execute the word

@compile_mode: ; maybe the word is immediate?
    bit BIT_IMM, c
    jr z, compile_word

@imm_word:
    ; Word was found, simulate a call to the function pointed by DE
    ; that will return to @next_word
    ld hl, do_next_word
    push hl
    ex de, hl
    jp (hl)

@is_number:
    ld a, (STATE)
    cp STATE_COMP
    jr z, compile_number
    ; The value is in HL, next word is in DE, swap them
    ex de, hl
    PUSH()
    jp do_next_word

@compileonly:
    ERROR(ERR_COMPILE_ONLY)
;

compile_word:
    ; put the word into the current definition
    ld hl, (HERE)
    ld a, 0xCD ; CALL nn
    ld (hl), a
    inc hl ; here++
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (HERE), hl

    jp do_next_word
;

compile_number:
    ex de, hl ; DE has the value

    ld hl, (HERE)
    ld a, 0x11 ; LD DE,NN
    ld (hl), a
    inc hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl

    ld a, 0xCD ; CALL pushdata
    ld (hl), a
    inc hl
    ld de, pushdata
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl

    ld (HERE), hl

    jp do_next_word
;

; @brief Print "  ok"
print_ok:
    ; Suppress "ok" while processing file input chunks.
    ld a, (_file_fd)
    or a
    ret nz
    PUTS(_str_ok, _str_ok_end)
    ret
;

; @brief Set error to numeric overflow
numeric_overflow:
    ; fall thru to print_error
    ld a, ERR_NUMERIC_OVERFLOW


; @brief Print current error message
print_error: ; TODO: implement error lookup
    cp ERR_NOT_FOUND
    jr z, @not_found

    neg ; errs are negative

    ; Table handles ERR_NUMERIC_OVERFLOW..ERR_DICT_OVERFLOW (1..ERR_TABLE_LAST)
    or a
    jr z, @unknown
    cp ERR_TABLE_LAST + 1
    jr nc, @unknown

    ; index = magnitude - 1
    dec a
    add a, a              ; 2-byte pointers
    ld e, a
    ld d, 0
    ld hl, _err_string_table
    add hl, de

    ; DE = c-addr of null-terminated message
    ld e, (hl)
    inc hl
    ld d, (hl)

    ; BC = strlen(DE)
    ld h, d
    ld l, e
    call strlen

    ; puts(DE, BC)
    call puts
    jr @msg

@not_found:
    PUTC('\'')
    ld de, (_curr_word)
    ld bc, (_curr_len)
    call puts
    PUTC('\'')
    PUTC(' ')
    ld de, _str_error_not_found
    ld hl, de
    call strlen
    call puts
    jr @msg

@unknown:
    ; Optional fallback
    ld de, _err_unsupported
    ld hl, de
    call strlen
    call puts

@msg:
    PUTS(_str_error, _str_error_end)

    IF_STATE(STATE_IMM, @prompt)
    ld hl, (_compile_return_sp)
    ld (return_sp), hl
    ld hl, (LATEST) ; set HL to LATEST
    call word_forget@drop ; reset HERE to start of last word

    SET_STATE(STATE_IMM)
@prompt:
    ; Restore recovery SP after error jumps.
    ld sp, (_recovery_sp)
    jp prompt
