#ifndef _WORDS_H_ASM_
#define _WORDS_H_ASM_

    EXTERN next_word
    EXTERN current_word

;
; EXAMPLE:
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
    SECTION TEXT
  ENDM

#endif