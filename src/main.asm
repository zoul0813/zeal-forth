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

    ; EXTERN is_alpha ; strutils
    ; EXTERN is_dec_digit ; strutils
    

    ; EXTERN __BSS_tail
    ; EXTERN _dict_builtin

  SECTION TEXT
main:
    push de
    MEMSET(__BSS_head, __BSS_size, 0x00)
    ld (_recovery_sp), sp
    call dict_init
@args:
    pop de
    ; get command args
    ld hl, 0xFFFF
    xor a ; clear carry
    sbc hl, de ; HL = 0xFFFF - DE
    ld a, h
    or l
    jr z, @repl ; no args, goto prompt
@readfile:
    call loadfile
    ; jr nz, @readfile ; refill the buffer
@repl:
    ; set the kb mode to block/cooked for now
    KB_MODE_COOKED()
    PUTS(_str_project_name, _str_project_name_end)
@prompt:
    call prompt
    jr @prompt

_exit_code:
    ld h, a
    EXIT()
