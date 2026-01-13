  SECTION TEXT

; bye (-- --) exit
word_bye:
    ld a, 0
    jp _exit_code

; ( n -- ) Display n in free field format.
word_dot:
    POPDATA()
    ; store the 16-bit value in a 32-bit memory location
    ld hl, _dword_num
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), 0

    ld hl, _dword_num
    ld de, _dword_ascii
    call dword_to_ascii_dec

    ld hl, _dword_ascii
    call strlen
    ld de, _dword_ascii
    S_WRITE1(DEV_STDOUT)

    PRINT(_str_newline, _str_newline_end)

    ret

word_plus:
    ret

word_minus:
    ret

word_dup:
    ret

word_drop:
    ret

  SECTION DATA
_dict_builtin:
_dict_bye:
    DEFB "bye", 0
    DEFW word_bye
_dict_dot:
    DEFB ".", 0
    DEFW word_dot
_dict_plus:
    DEFB "+", 0
    DEFW word_plus
_dict_minus:
    DEFB "-", 0
    DEFW word_minus
_dict_dup:
    DEFB "dup", 0
    DEFW word_dup
_dict_drop:
    DEFB "drop", 0
    DEFW word_drop

  ; a place to store dword numbers for conversion
_dword_num:
    DEFB 0, 0, 0, 0
_dword_ascii:
    DEFS 12, 0