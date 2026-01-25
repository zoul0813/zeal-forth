    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "words_h.asm"

    EXTERN word_semicolon

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
    ; go through built-in dictionary
    ld hl, (_curr_word)
    call dict_search
    or a
    ; If A is not 0, the word was not found
    jp nz, print_error

    IF_STATE(STATE_COMP, compile_word)
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
    cp ERR_NO_SUCH_ENTRY
    jr z, @not_found
    cp ERR_NUMERIC_OVERFLOW ; numeric overflow
    jr z, @numeric_overflow
@code:
    ld e, a
    ld d, 0
    PUTI()
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
    ; jp prompt
    ret


compile_word:
    ; compare word to `;`
    ld hl, (_curr_word)
    ld a, (hl)
    cp ';'
    jp z, @end
    ; TODO: that was dirty, ... words in dict should have "state" (IMM | COMP)

    ; put the word into the current definition
    ld hl, (here_sp)
    ld a, 0xCD ; CALL nn
    ld (hl), a
    inc hl ; here++
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (here_sp), hl

    jp do_next_word
@end:
    call word_semicolon
    jp do_next_word

compile_number:
    ; can't be ';', so no compare
    ex de, hl ; DE has the value

    ld hl, (here_sp)
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

    ld (here_sp), hl

    jp do_next_word
