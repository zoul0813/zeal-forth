    INCLUDE "constants_h.asm"
    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"

; Compile Only
WORD "if", word_if
  PUTS(_str_unsupported, _str_unsupported_end)
  ret
ENDWORD_FLAGS "if", word_if, RESERVED | IMMEDIATE

; Compile Only
WORD "else", word_else
  PUTS(_str_unsupported, _str_unsupported_end)
  ret
ENDWORD_FLAGS "else", word_else, RESERVED | IMMEDIATE

; Compile Only
WORD "then", word_then
  PUTS(_str_unsupported, _str_unsupported_end)
  ret
ENDWORD_FLAGS "then", word_then, RESERVED | IMMEDIATE