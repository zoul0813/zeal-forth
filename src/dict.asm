    INCLUDE "macros_h.asm"
    INCLUDE "constants_h.asm"
    INCLUDE "hashtbl_h.asm"

    EXTERN builtin_words

  SECTION TEXT

; Put all the words in the hashtable
    PUBLIC dict_init
dict_init:
    ; NULL marks the end of the table
    ld hl, builtin_words
@dict_loop:
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
    jp z, @dict_loop
    ; An error occurred!
    PUTS(_init_str, _init_str_end)
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
    PUBLIC dict_search
dict_search:
    jp hshtbl_get