    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "hashtbl_h.asm"
    INCLUDE "include/strutils_h.asm"


; bye (-- --) exit
WORD "bye", word_bye
    ld a, 0
    jp _exit_code
ENDWORD "bye", word_bye

; words (-- --) Print all dictionary words
WORD "words", word_words
    ld hl, (LATEST) ; last entry
@loop:
    ld e, (hl)
    inc hl
    ld d, (hl)    ; DE = previous entry
    inc hl        ; HL = dict_flags
    ld a, (hl)
    and 00011111b;
    ld b, 0
    ld c, a       ; BC = length
    inc hl        ; HL = dict_name
    push de       ; push the previous entry
    ex de, hl     ; DE = dict_name, HL = prev
    call puts     ; print the word
    PUTC(' ')     ; print the delim
    pop hl        ; HL = previous entry
    ld a, h
    or l
    jr nz, @loop
@done:
    ret
ENDWORD "words", word_words
