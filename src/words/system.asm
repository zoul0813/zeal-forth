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
    ld de, hshtbl_hashmap
    ld c, 0
@bucket_loop:
    ld a, (de)
    inc de
    ld h, (de)
    ld l, a
    inc de
    ld a, h
    or l
    jr z, @next_bucket

@entry_loop:
    push de
    push bc
    push hl
    ld d, h
    ld e, l
    ld b, 0
    ld c, LIST_ENTRY_KEY_SIZE
@len_loop:
    ld a, (hl)
    or a
    jr z, @len_done
    cp 0x20
    jr c, @len_done
    cp 0x7F
    jr nc, @len_done
    inc hl
    inc b
    dec c
    jr nz, @len_loop
@len_done:
    ld c, b
    ld a, b
    or a
    jr z, @skip_print
    ld b, 0
    call puts
    pop hl
    PUTC(' ')
    jr @after_print
@skip_print:
    pop hl
@after_print:
    pop bc
    pop de
    push bc
    call hshtbl_list_get_next
    pop bc
    ld a, h
    or l
    jr nz, @entry_loop

@next_bucket:
    inc c
    jr nz, @bucket_loop
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD "words", word_words
