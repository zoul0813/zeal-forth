    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "words_h.asm"

  SECTION TEXT
    ORG 0x4000  ; put the TEXT and DATA together in forth_TEXT.bin
  SECTION DATA
  SECTION BSS
    ORG -1  ; make forth_BSS.bin and just don't merge it
  SECTION HERE

    EXTERN is_alpha ; strutils
    EXTERN is_dec_digit ; strutils
    EXTERN word_semicolon

    EXTERN __BSS_tail
    EXTERN _dict_builtin

  SECTION TEXT
main:
    MEMSET(__BSS_head, __BSS_size, 0x00)
    ; set the kb mode to block/cooked for now
    KB_MODE_COOKED()

    PUTS(_str_project_name, _str_project_name_end)

    call dict_init

@prompt:
    GET_INPUT()

    ld hl, _input_buffer
    ld (_next_word), hl
@do_next_word:
    call next_word
    jr z, @print_ok

    ; Try to parse the input as a number
    call parse_dec
    ; If A is 0, the current word is a number
    or a
    jr z, @is_number
    ; If A is 1, the value is bigger than 16-bit, so skip this word
    dec a
    jr z, @numeric_overflow
    ; Non-decimal value, fall-through

@is_word:
    ; go through built-in dictionary
    ld hl, (_curr_word)
    call dict_search
    or a
    ; If A is not 0, the word was not found
    jr nz, @word_not_found

    IF_STATE(STATE_COMP, compile_word)
    ; Word was found, simulate a call to the function pointed by DE
    ; that will return to @next_word
    ld hl, @do_next_word
    push hl
    ex de, hl
    jp (hl)

@word_not_found:
    PUTS(_str_unknown, _str_unknown_end)
    ld de, (_curr_word)
    ld bc, (_curr_len)
    call puts ; DE = buffer, BC = len, A = err, returns BC = len
    PUTS(_str_newline, _str_newline_end)
    jp @prompt ; skip remaining words
; @next_word:
    jp @do_next_word

@is_number:
    IF_STATE(STATE_COMP, compile_number)
    ; The value is in HL, next word is in DE, swap them
    ex de, hl
    PUSH()
    jp @do_next_word


@print_ok:
    PUTS(_str_ok, _str_ok_end)
    jp @prompt

@numeric_overflow:
    ld a, ERR_NUMERIC_OVERFLOW
@print_error: ; TODO: implement error lookup
    cp ERR_NUMERIC_OVERFLOW ; numeric overflow
    jr nz, @print_error_msg
    PUTS(_str_error_numeric_overflow, _str_error_numeric_overflow_end)
@print_error_msg:
    PUTS(_str_error, _str_error_end)
    jp @prompt

_str_compiling:
  DEFB "Compiling", 0
_str_compiling_end:

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

    jp main@do_next_word
@end:
    call word_semicolon
    jp main@do_next_word

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

    jp main@do_next_word

_exit_code:
    ld h, a
    EXIT()

