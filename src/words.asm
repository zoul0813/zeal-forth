    SECTION TEXT

    EXTERN hshtbl_insert
    EXTERN hshtbl_get

; Put all the words in the hashtable
words_init:
    ; NULL marks the end of the table
    ld hl, builtin_words
@words_loop:
    ; Load the value first, in DE
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ; Check if the value is 0 (end of table)
    ld a, e
    or d
    ret z
    ; Dereference the string (name)
    ld a, (hl)
    inc hl
    ld c, (hl)
    inc hl
    ; Keep a pointer on the next entry
    push hl
    ; The value is in DE already, the string is in CA, put it in HL
    ld h, c
    ld l, a
    call hshtbl_insert
    pop hl
    ; A contains the error code
    or a
    jp z, @words_loop
    ; An error occurred!
    PRINT(_init_str, _init_str_end)
    ret

_init_str:
    DEFM "Error initializing the builtin dicitonary\n"
_init_str_end:

    ; Look for a word, in HL, and return its value, DE
    ; Parameters:
    ;   HL - Word (NULL-terminated string)
    ; Returns:
    ;   DE - Address of the routine to execute
    ;   A - ERR_SUCCESS if the entry was found
    ;       ERR_NO_SUCH_ENTRY if the entry was not found
words_search:
    jp hshtbl_get


; bye (-- --) exit
word_bye:
    ld a, 0
    jp _exit_code

; ( n -- ) Display n in free field format.
word_dot:
    POPDATA()
    ; store the 16-bit value in a 32-bit memory location
    ld (_dword_num), de
    ld hl, 0
    ld (_dword_num + 2), hl

    ld hl, _dword_num
    ld de, _dword_ascii
    call dword_to_ascii_dec

    ; Set both HL and DE to _dword_ascii
    ld hl, _dword_ascii
    ld d, h
    ld e, l
    call strlen
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

    ; Associative table that will be added to the words hashtable on boot
builtin_words:
    DEFW word_bye
    DEFW _bye_str

    DEFW word_dot
    DEFW _dot_str

    DEFW word_plus
    DEFW _plus_str

    DEFW word_minus
    DEFW _minus_str

    DEFW word_dup
    DEFW _dup_str

    DEFW word_drop
    DEFW _drop_str

    ; End of table
    DEFW 0

_bye_str:
    DEFM "bye", 0
_dot_str:
    DEFM ".", 0
_plus_str:
    DEFM "+", 0
_minus_str:
    DEFM "-", 0
_dup_str:
    DEFM "dup", 0
_drop_str:
    DEFM "drop", 0

  ; a place to store dword numbers for conversion
_dword_num:
    DEFB 0, 0, 0, 0
_dword_ascii:
    DEFS 12, 0