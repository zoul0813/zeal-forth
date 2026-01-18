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
    ld c, 16
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
    ld b, 0
    call puts
    pop hl
    PUTC(' ')
    pop bc
    pop de
    call hshtbl_list_get_next
    ld a, h
    or l
    jr nz, @entry_loop

@next_bucket:
    inc c
    jr nz, @bucket_loop
    PUTS(_str_newline, _str_newline_end)
    ret
ENDWORD "words", word_words
