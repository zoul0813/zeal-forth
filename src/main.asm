    INCLUDE "zos_sys.asm"
    INCLUDE "zos_keyboard.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "macros.asm"

  SECTION TEXT
    ORG 0x4000  ; put the TEXT and DATA together in forth_TEXT.bin
  SECTION DATA
  SECTION BSS
    ORG -1  ; make forth_BSS.bin and just don't merge it

    EXTERN is_alpha ; strutils
    EXTERN is_dec_digit ; strutils
    EXTERN __BSS_tail
    EXTERN _dict_builtin

  SECTION TEXT
_start:
    ; set the kb mode to block/cooked for now
    KB_MODE_COOKED()

    MEMSET(data_stack, DATA_STACK_SIZE, 0x00)
    MEMSET(return_stack, DATA_STACK_SIZE, 0x00)
    MEMSET(heap, __Z80_STACK_TAIL - __BSS_tail, 0x00)

    PRINT(_str_project_name, _str_project_name_end)

@prompt:
    GET_INPUT()

    ld hl, _input_buffer
@process_word:
    ld a, ' '
    call strsep ; returns HL = str, DE = next, A = found (alters: DE, A)
    call strlen ; returns BC = len (alters: A, BC)
    ld a, b
    or c
    jp z, @print_ok

    ; Next word is in DE
    ld (_curr_word), hl
    ld (_curr_len), bc
    ld (_next_word), de

    ; Try to parse the input as a number
    call parse_dec
    ; If A is 0, the current word is a number
    or a
    jr z, @is_number
    ; If A is 1, the value is bigger than 16-bit, so skip this word
    dec a
    jr z, @next_word
    ; Non-decimal value, fall-through

@is_word:
    ; go through built-in dictionary
    ld hl, (_curr_word)
    ld de, _dict_builtin
    call strcmp
    or a
    jp z, _exit_code

    ld hl, (_curr_word)
    ld de, _dict_dot
    call strcmp
    or a
    jp nz, @word_not_found
    ld hl, @next_word
    push hl
    ld hl, (_dict_dot + 2)
    jp (hl)

@word_not_found:
    PRINT(_str_is_word, _str_is_word_end)

    ld de, (_curr_word)
    ld bc, (_curr_len)
    S_WRITE1(DEV_STDOUT) ; DE = buffer, BC = len, A = err, returns BC = len
    PRINT(_str_newline, _str_newline_end)

@next_word:
    ld hl, (_next_word)
    jp @process_word

@is_number:
    ; The value is in HL, next word is in DE, swap them as needed by PUSHDATA
    ex de, hl
    PUSHDATA()
    jp @process_word

@print_ok:
    PRINT(_str_ok, _str_ok_end)
    jp @prompt

_exit_code:
    ld h, a
    EXIT()


; @brief Checks if HL is a digit
;
; Returns:
;   carry - not a digit
;   not carry - is a digit
is_digit:
    push bc
    push hl

    call strlen ; get len in BC

    ld a, b
    or c
    jr z, @not_a_digit
@loop:
    ld a, (hl)
    call is_dec_digit ; it's not a word if it only contains digits
    jr c, @not_a_digit
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, @loop
    or a
    jr @return
    scf
@not_a_digit:
    ; Carry flag is set when
@return:
    pop hl
    pop bc
    ret

    INCLUDE "words.asm"

    INCLUDE "constants.asm"