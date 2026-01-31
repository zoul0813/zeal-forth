    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "constants_h.asm"

    EXTERN builtin_words

  SECTION TEXT

    PUBLIC dict_init
    ; Put all the words in the hashtable
dict_init:
    ; NULL marks the end of the table
    ld hl, builtin_words
@dict_loop:
    ; Load the value first, in DE
    ld e, (hl)
    inc hl
    ld d, (hl) ; DE = call address
    inc hl
    ; Check if the value is 0 (end of table)
    ld a, e
    or d
    ret z ; call address is 0, so we're done

    push de ; call address on stack

    ; Dereference the string (name)
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    push hl

    ; The value is in DE already, the string is in CA, put it in _curr_word
    ld (_curr_word), de
    call CREATE_HEADER
    pop hl ; HL = next word
    pop de ; DE = call address
    call DICT_W ; write the call address to dict_cfa


    jr @dict_loop
;

_init_str:
    DEFM "Error initializing the builtin dicitonary\n"
_init_str_end:
;

    PUBLIC dict_search
    ; Look for a word, in HL, and return its value, DE
    ;
    ; Parameters:
    ; - HL - Word (NULL-terminated string)
    ;
    ; Returns:
    ; - DE - Address of the routine to execute
    ; - A - ERR_SUCCESS if the entry was found
    ;       ERR_NO_SUCH_ENTRY if the entry was not found
dict_search:
    ld hl, (LATEST) ; HL = latest entry
@search:
    push hl ; current entry
    ld bc, dict_flags
    add hl, bc
    ld a, (hl) ; A = dict_flags (lower 5 bits = length)
    and 00011111b ; A = strlen
    inc hl ; dict_name
    ld de, (_curr_word)
@next:
    pop hl  ; current entry
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a ; HL = previous entry
    ld a, h
    or l
    ret z ; no more entries
    jr @search
@done:
    pop hl ; current entry
    ret
;

    PUBLIC DICT_C
    ; Write a byte HERE
    ;
    ; Parameters:
    ; -  A - Byte to write
DICT_C:
    push hl
    ld hl, (HERE)
    ld (hl), a
    inc hl
    ld (HERE), hl
    pop hl
    ret
;

    PUBLIC DICT_W
    ; Write a word HERE
    ;
    ; Parameters:
    ; - DE - Word to write
DICT_W:
    push hl
    ld hl, (HERE)
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (HERE), hl
    pop hl
    ret
;

    PUBLIC CREATE_HEADER
    ; Create a new dictionary entry
    ;
    ; Parameters:
    ; - None
CREATE_HEADER:
    BACKUP()

    ld hl, (HERE)
    ld de, (LATEST)
    call DICT_W ; write the current LATEST to dict_prev
    ld (LATEST), hl ; update LATEST to HERE

    ld hl, (_curr_word)
    call strlen
    ld a, c
    call DICT_C ; write LEN to dict_flags

    ld de, (HERE)
    call strcpy ; copy word to HERE
    ld hl, (HERE)
    add hl, bc
    inc hl ; add null-term
    ld (HERE), hl ; increment HERE by strlen

    RESTORE()
    ret