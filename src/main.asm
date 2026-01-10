    INCLUDE "zos_sys.asm"
    INCLUDE "zos_keyboard.asm"
    INCLUDE "include/strutils_h.asm"
    INCLUDE "constants.asm"
    INCLUDE "macros.asm"

  SECTION TEXT
    ORG 0x4000  ; put the TEXT and DATA together in forth_TEXT.bin
  SECTION DATA
  SECTION BSS
    ORG -1  ; make forth_BSS.bin and just don't merge it

    DEFC BUFFER_SIZE = 256

  SECTION TEXT
_start:
    ; set the kb mode to block/cooked for now
    KB_MODE_COOKED()

    PRINT(_str_project_name, _str_project_name_end)

@prompt:
    GET_INPUT()

    ld hl, _input_buffer
@next_word:
    ld a, ' '
    call strsep ; returns HL = str, DE = next, A = found (alters: DE, A)
    call strlen ; returns BC = len (alters: A, BC)
    ld a, b
    or c
    jp z, @prompt
    push de ; next string

    push de
    ld de, _dict_bye
    call strcmp
    or a
    pop de
    jp z, _exit_code

    call is_word
    jr c, @is_number

@is_word:
    ex de, hl
    exx ; backup the registers
    PRINT(_str_is_word, _str_is_word_end)
    exx ; restore the registers
    jr @print_input

@is_number:
    ex de, hl
    exx ; backup the registers
    PRINT(_str_is_number, _str_is_number_end)
    exx ; restore the registers

    ; jr @print_input ;;; implied fall thru

@print_input:
    S_WRITE1(DEV_STDOUT) ; DE = buffer, BC = len, A = err, returns BC = len
    PRINT(_str_newline, _str_newline_end)
    pop hl ; next string
    jr @next_word

_empty_string:
    ld a, 0 ; this is not an error
_exit_code:
    ld h, a
    EXIT()


; @brief Checks if HL is a word
;
; Returns:
;   carry - not a word
;   not carry - is a word
is_word:
    push bc
    push hl

    call strlen ; get len in BC

@loop:
    ld a, b
    or c
    jr z, @not_a_word
    ld a, (hl)
    call is_alpha ; it's a word if it contains a single alpha
    jr nc, @return
    inc hl
    dec bc
    jr @loop
@not_a_word:
    scf
@return:
    pop hl
    pop bc
    ret

  SECTION DATA
_str_project_name:
    DEFB "Zeal Forth\n", 0
_str_project_name_end:
_str_newline:
    DEFB 0x0A, 0x00
_str_newline_end:

_str_prompt:
    DEFB "> ", 0
_str_prompt_end:

_str_is_word:
    DEFB "WORD: ", 0
_str_is_word_end:

_str_is_number:
    DEFB "NUMBER: ", 0
_str_is_number_end:

_dict_bye:
    DEFB "bye", 0

  SECTION BSS
_input_buffer:
    DEFS BUFFER_SIZE