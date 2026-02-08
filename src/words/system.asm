    INCLUDE "words_h.asm"
    INCLUDE "common_h.asm"
    INCLUDE "include/strutils_h.asm"


; bye (-- --) exit
WORD "bye", word_bye
    ld a, 0
    jp _exit_code
ENDWORD "bye", word_bye

; words (-- --) Print all dictionary words
WORD "words", word_words
    ld hl, (LATEST) ; last entry
@loop:
    ld e, (hl)
    inc hl
    ld d, (hl)    ; DE = previous entry
    inc hl        ; HL = dict_flags
    ld a, (hl)
    and 00011111b;
    ld b, 0
    ld c, a       ; BC = length
    inc hl        ; HL = dict_name
    push de       ; push the previous entry
    ex de, hl     ; DE = dict_name, HL = prev
    call puts     ; print the word
    PUTC(' ')     ; print the delim
    pop hl        ; HL = previous entry
    ld a, h
    or l
    jr nz, @loop
@done:
    ret
ENDWORD "words", word_words

; ( -- flag )
WORD "key?", word_key_query
    ld a, (_key_pending)
    or a
    jr nz, @pending ; there's already a key pending, consume it first

    S_READ3(DEV_STDIN, _key_buffer, 1)
    ; Non-block probe: BC==0 means no key available.
    or a
    jr nz, @nokey
    ld a, b
    or c
    jr z, @nokey

    ld a, (_key_buffer)
    cp KB_RELEASED
    jr z, @nokey ; ignore key releases

    ld a, 1
    ld (_key_pending), a
    ld de, TRUE ; found a key
    PUSH()

    jr @done

@nokey:
    xor a
    ld (_key_pending), a
    ld de, FALSE
    PUSH();
    jr @done
@pending:
    ld de, TRUE
    PUSH()
@done:
    ret
ENDWORD "key?", word_key_query

; ( -- char )
WORD "key", word_key
    ; Consume buffered key from key? fast path.
    ld a, (_key_pending)
    or a
    jr nz, @pending

    ; Poll in RAW non-block mode until a key press arrives.
@read_loop:
    S_READ3(DEV_STDIN, _key_buffer, 1)
    ERROR_CHECK()
    ld a, b
    or c
    jr z, @read_loop

    ld a, (_key_buffer)
    cp KB_RELEASED
    jr z, @read_loop ; ignore release marker
    jr @output

@pending:
    ld a, (_key_buffer)

@output:
    ld e, a
    ld d, 0
    PUSH()

    xor a
    ld (_key_pending), a
    ret
ENDWORD "key", word_key

; ( dev cmd param num -- status )
; Execute raw ZealOS syscall number `num` with:
;   H = dev (low byte)
;   C = cmd (low byte)
;   DE = param
;   L = syscall number (low byte)
; Returns status code from A (sign-extended to cell).
WORD "syscall", word_syscall
    POP()          ; DE = syscall number
    ld l, e
    POP()          ; DE = param
    push de        ; preserve param
    POP()          ; DE = cmd
    ld c, e
    POP()          ; DE = dev
    ld h, e
    pop de         ; restore param
    rst 0x8

    ; Return A as signed 16-bit cell
    ld e, a
    ld d, 0
    bit 7, a
    jr z, @ret
    ld d, 0xFF
@ret:
    PUSH()
    ret
ENDWORD "syscall", word_syscall

; ( dev cmd param -- status )
; Wrapper around `syscall` for syscall #7 (IOCTL).
WORD "ioctl", word_ioctl
    ld de, 7
    PUSH()
    jp word_syscall
ENDWORD "ioctl", word_ioctl
