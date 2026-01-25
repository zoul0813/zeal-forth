    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "common_h.asm"

  SECTION TEXT

read_file:
    ld b, d
    ld c, e
    ld h, O_RDONLY
    OPEN()
    ; error check
    bit 7, a
    jr nz, @error_neg
    ld (_file_fd), a

@read:
    ld a, (_file_fd)
    ld h, a
    ld de, _input_buffer
    ld bc, BUFFER_SIZE
    READ()
    ; error check
    or a
    jr nz, @error

    ;; TODO: error check
    ld a, b
    or c
    jr z, @eof
    ld hl, _input_buffer
    add hl, bc
    ld (hl), 0 ; null-term input buffer at count


    ld hl, _input_buffer
    ld (_next_word), hl
    call do_next_word
    jr @read

@eof:
    ld a, (_file_fd)
    ld h, a
    CLOSE()
    ;; TODO: error check
    ret
@error_neg:
    neg
@error:
    call print_error
    ret