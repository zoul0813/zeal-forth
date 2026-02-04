    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"

; Compile Only
WORD "if", word_if
  ; compile
  ; call popdata
  ld a, 0xCD ; call
  call DICT_C
  ld de, popdata
  call DICT_W

  ; ld a, d
  ld a, 0x7A ; ld a, d
  call DICT_C

  ; or e
  ld a, 0xB3 ; or e
  call DICT_C

  ; jp z, 0x0000 ; jump to ELSE
  ld a, 0xCA ; jp z
  call DICT_C

  ld de, (HERE)
  PUSH_RET() ; push addr of 0x0000 to return stack

  ld de, 0x0000
  call DICT_W ; write 0x0000

  ret
ENDWORD_FLAGS "if", word_if, RESERVED | IMMEDIATE

; Compile Only
WORD "else", word_else
  ; compile
  ; jp 0x0000 ; jump to THEN
  ld a, 0xC3 ; jp
  call DICT_C

  ; patch IF's address
  POP_RET() ; DE has address of IF's 0x0000
  ex de, hl ; HL has address of IF's 0x0000
  ld de, (HERE)
  ld (hl), e
  inc hl
  ld (hl), d ; patched IF's 0x0000

  PUSH_RET() ; push addr of 0x0000 to return stack

  ld de, 0x0000
  call DICT_W

  ret
ENDWORD_FLAGS "else", word_else, RESERVED | IMMEDIATE

; Compile Only
WORD "then", word_then
  POP_RET() ; get the address of ELSE 0x0000
  ex de, hl ; HL has address of ELSE's 0x0000
  ld de, (HERE)
  ld (hl), e
  inc hl
  ld (hl), d ; patched ELSE's 0x0000

  ret
ENDWORD_FLAGS "then", word_then, RESERVED | IMMEDIATE