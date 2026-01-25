    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "common_h.asm"

  SECTION TEXT

read_file:
    ld b, d
    ld c, e
    ld h, O_RDONLY
    OPEN()
    ;; TODO: error check
    ld h, a
    ld de, _input_buffer
    ld bc, BUFFER_SIZE
    READ()
    ;; TODO: error check
    ld hl, _input_buffer
    ld (_next_word), hl
    call do_next_word

    ld h, a
    CLOSE()
    ;; TODO: error check
    ret