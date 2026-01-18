    INCLUDE "words_h.asm"

; bye (-- --) exit
WORD "bye", word_bye
    ld a, 0
    jp _exit_code
ENDWORD "bye", word_bye