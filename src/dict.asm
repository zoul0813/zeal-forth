    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "constants_h.asm"

    EXTERN builtin_words

  SECTION TEXT

    PUBLIC dict_init
    ; @brief Initialize dictionary with built-in words
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

    ; get the flags
    ld c, (hl)
    inc hl

    push hl

    ; The value is in DE already, the string is in CA, put it in _curr_word
    ld (_curr_word), de
    call CREATE_HEADER

    ; OR flags into dict_flags
    ld hl, (LATEST)
    inc hl
    inc hl
    ld a, (hl)  ; A = strlen
    or c        ; C = flags
    ld (hl), a  ; A = flags | strlen

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
    ; @brief Look for a word, in HL, and return its value, DE
    ;
    ; Returns:
    ; - DE - Address of the routine to execute
    ; - HL - Address of the current entry
    ; -  A - 0 = found
    ;        ERR_NOT_FOUND
dict_search:
    ld hl, (LATEST) ; HL = latest entry
    push hl ; current entry
    IF_STATE(STATE_COMP, @next) ; when compiling, always skip the latest word for searches
@search:
    call dict_word_len

@check_length:
    ld bc, (_curr_len)
    cp c
    jr nz, @next ; length mismatch, can't be the word ... skip
@check_chars:
    ld de, (_curr_word)
    call strcmp
    or a
    jr z, @found

@next:
    pop hl  ; current entry
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a ; HL = previous entry
    ld a, h
    or l
    jr nz, @keep_search
    ld a, ERR_NOT_FOUND
    ret
@keep_search:
    push hl
    jr @search
@found:
    inc hl
    add hl, bc ; BC = len, HL = dict_cfa
    ld e, (hl)
    inc hl
    ld d, (hl) ; DE = CFA
    xor a ; A = 0
    pop hl ; current entry
    ld (_curr_entry), hl

    ret
;

    ; @brief Get the length of the dict word
    ;
    ; Parameters:
    ; - HL - Address of entry
    ;
    ; Returns:
    ; - HL - Address of dict_name
    ; -  A - Length of dict_name
    ;
    ; Alters:
    ;   A, HL
dict_word_len:
    ; get the dict flags, and jump over the word
    inc hl
    inc hl ; HL = dict_flags
    ld a, (hl) ; A = dict_flags (lower 5 bits = length)
    and 00011111b ; A = strlen
    inc hl ; dict_name
    ret

    PUBLIC DICT_CFA
    ; @brief Get the dictionary entries CFA
    ;
    ; Parameters:
    ; - HL - Address of entry
    ;
    ; Returns:
    ; - DE - Address of CFA
    ;
    ; Alters:
    ;   DE
DICT_CFA:
    push hl
    call dict_word_len

    ld d, 0
    ld e, a
    add hl, de ; HL = dict_cfa
    inc hl ; skip null-term
    ex de, hl
    pop hl
    ret
;

    PUBLIC DICT_BODY
    ; @brief Get the dictionary entries BODY
    ;
    ; Parameters:
    ; - HL - Address of entry
    ;
    ; Returns:
    ; - DE - Address of BODY
    ;
    ; Alters:
    ;   DE
DICT_BODY:
    call DICT_CFA
    inc de
    inc de
    ret


    PUBLIC DICT_C
    ; @brief Write a byte HERE
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
    ; @brief Write a word HERE
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
    ; @brief Create a new dictionary entry
    ;
    ; Updates HERE, LATEST
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