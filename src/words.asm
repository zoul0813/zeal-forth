  SECTION TEXT

; bye (-- --) exit
word_bye:
    ld a, 0
    jp _exit_code

; ( n -- ) Display n in free field format.
word_dot:
    push hl
    ld hl, (data_sp)
    ld d, (hl)
    inc hl
    ld e, (hl)
    inc hl

    S_WRITE1(DEV_STDOUT)
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
_dict_table:
    DEFW _dict_bye, _dict_dot, _dict_plus, _dict_minus, _dict_dup, _dict_drop