    INCLUDE "words_h.asm"

; ( a-addr -- x )
WORD "@", word_fetch
    POPDATA()

    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ex de, hl

    PUSHDATA()

    ret
ENDWORD "@", word_fetch

; (x a-addr -- )
WORD "!", word_store
    POPDATA()
    ex de, hl ; HL has address
    POPDATA() ; DE has value

    ld (hl), e
    inc hl
    ld (hl), d

    ret
ENDWORD "!", word_store

; ( -- a-addr )
WORD "here", word_here
    ld hl, (here_sp)
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "here", word_here

; ( -- c-addr )
WORD "pad", word_pad
    ld hl, (here_sp)
    ld de, PAD_OFFSET
    add hl, de
    ex de, hl
    PUSHDATA()
    ret
ENDWORD "pad", word_pad
