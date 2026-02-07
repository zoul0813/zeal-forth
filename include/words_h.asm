#ifndef _WORDS_H_ASM_
#define _WORDS_H_ASM_

    EXTERN next_word
    EXTERN parse_until_quote

; Create a new word
;
; Example:
;
;  ; bye (-- --) exit
;  WORD "bye", word_bye
;      ld a, 0
;      jp _exit_code
;  ENDWORD "bye", word_bye
;
  MACRO WORD name, label
    SECTION TEXT
label:
  ENDM

  MACRO ENDWORD name, label
@str:
    DEFM name, 0
    SECTION DATA
    DEFW label
    DEFW @str
    DEFB 0
    SECTION TEXT
  ENDM

  MACRO ENDWORD_FLAGS name, label, flags
@str:
    DEFM name, 0
    SECTION DATA
    DEFW label
    DEFW @str
    DEFB flags
    SECTION TEXT
  ENDM

#endif