    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "dict_h.asm"
    INCLUDE "words_h.asm"

  SECTION TEXT
    ORG 0x4000  ; put the TEXT and DATA together in forth_TEXT.bin
  SECTION DATA
  SECTION BSS
    ORG -1  ; make forth_BSS.bin and just don't merge it
  SECTION HERE

    EXTERN is_alpha ; strutils
    EXTERN is_dec_digit ; strutils
    EXTERN word_semicolon

    EXTERN __BSS_tail
    EXTERN _dict_builtin

  SECTION TEXT
main:
    push de
    MEMSET(__BSS_head, __BSS_size, 0x00)
    ; set the kb mode to block/cooked for now
    KB_MODE_COOKED()

    PUTS(_str_project_name, _str_project_name_end)

    call dict_init

@args:
    pop de
    ; get command args
    ld hl, 0xFFFF
    xor a ; clear carry
    sbc hl, de ; HL = 0xFFFF - DE
    ld a, h
    or l
    jr z, @prompt ; no args, goto prompt
@readfile:
    call read_file
@prompt:
    call prompt
    jr @prompt



_str_compiling:
  DEFB "Compiling", 0
_str_compiling_end:

compile_word:
    ; compare word to `;`
    ld hl, (_curr_word)
    ld a, (hl)
    cp ';'
    jp z, @end
    ; TODO: that was dirty, ... words in dict should have "state" (IMM | COMP)

    ; put the word into the current definition
    ld hl, (here_sp)
    ld a, 0xCD ; CALL nn
    ld (hl), a
    inc hl ; here++
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (here_sp), hl

    jp do_next_word
@end:
    call word_semicolon
    jp do_next_word

compile_number:
    ; can't be ';', so no compare
    ex de, hl ; DE has the value

    ld hl, (here_sp)
    ld a, 0x11 ; LD DE,NN
    ld (hl), a
    inc hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl

    ld a, 0xCD ; CALL pushdata
    ld (hl), a
    inc hl
    ld de, pushdata
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl

    ld (here_sp), hl

    jp do_next_word

_exit_code:
    ld h, a
    EXIT()

