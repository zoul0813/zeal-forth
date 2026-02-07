    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "words_h.asm"

    EXTERN word_semicolon
    EXTERN word_forget@drop

  SECTION TEXT

; @brief Show the prompt
prompt:
    GET_INPUT()

    ld hl, _input_buffer
    ld (_next_word), hl

; @brief Process next word in input buffer
do_next_word:
    call next_word
    jr z, print_ok

    ; Try to parse the input as a number
    call parse_dec
    ; If A is 0, the current word is a number
    or a
    jr z, @is_number
    ; If A is 1, the value is bigger than 16-bit, so skip this word
    dec a
    jr z, numeric_overflow
    ; Non-decimal value, fall-through

@is_word:
    call dict_search
    ; If A is 0, the word was not found
    or a
    jp nz, print_error

    ; HL = current entry
    inc hl
    inc hl  ; HL = dict_flags
    ld c, (hl) ; C = dict_flags

    ld a, (STATE)
    cp STATE_COMP
    jr z, @compile_mode ; compiling, check if immediate

    bit BIT_RESERVED, c
    jp nz, @compileonly ; this is a compile only word
    jr @imm_word ; just execute the word

@compile_mode: ; maybe the word is immediate?
    bit BIT_IMM, c
    jp z, compile_word

@imm_word:
    ; Word was found, simulate a call to the function pointed by DE
    ; that will return to @next_word
    ld hl, do_next_word
    push hl
    ex de, hl
    jp (hl)

@is_number:
    IF_STATE(STATE_COMP, compile_number)
    ; The value is in HL, next word is in DE, swap them
    ex de, hl
    PUSH()
    jp do_next_word

@compileonly:
    PUTS(_str_compile_only, _str_compile_only_end)
    jp prompt


; @brief Print "  ok"
print_ok:
    PUTS(_str_ok, _str_ok_end)
    ; jp prompt
    ret

; @brief Set error to numeric overflow
numeric_overflow:
    ld a, ERR_NUMERIC_OVERFLOW

; @brief Print current error message
print_error: ; TODO: implement error lookup
    cp ERR_NOT_FOUND
    jr z, @not_found
    cp ERR_NUMERIC_OVERFLOW ; numeric overflow
    jr z, @numeric_overflow
    cp ERR_UNTERMINATED_STR
    jr z, @unterminated_str
@code:
    ld e, a
    ld d, 0
    PUTI()
    jr @msg
@unterminated_str:
    PUTS(_str_unterminated_str, _str_unterminated_str_end)
    jr @msg
@numeric_overflow:
    PUTS(_str_error_numeric_overflow, _str_error_numeric_overflow_end)
    jr @msg
@not_found:
    PUTC('\'')
    ld de, (_curr_word)
    ld bc, (_curr_len)
    call puts ; DE = buffer, BC = len, A = err, returns BC = len
    PUTC('\'')
    PUTS(_str_error_not_found, _str_error_not_found_end)
    ; jr @msg ; fall-thru
@msg:
    PUTS(_str_error, _str_error_end)

    IF_STATE(STATE_IMM, @prompt)
    ld hl, (LATEST) ; set HL to LATEST
    call word_forget@drop ; reset HERE to start of last word

    SET_STATE(STATE_IMM)
@prompt:
    jp prompt


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