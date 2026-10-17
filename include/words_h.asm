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
    ; Macro-local symbols remain valid across section switches.
    LOCAL word_name
word_name:
    DEFM name, 0
    SECTION DATA
    DEFW label
    DEFW word_name
    DEFB 0
    SECTION TEXT
  ENDM

  MACRO ENDWORD_FLAGS name, label, flags
    LOCAL word_name
word_name:
    DEFM name, 0
    SECTION DATA
    DEFW label
    DEFW word_name
    DEFB flags
    SECTION TEXT
  ENDM

#endif
