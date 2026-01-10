    ; Include the Zeal 8-bit OS header file, containing all the syscalls macros.
    INCLUDE "zos_sys.asm"
    INCLUDE "zos_keyboard.asm"
    INCLUDE "include/strutils_h.asm"

    ORG 0x4000

    DEFC BUFFER_SIZE = 128

    MACRO GET_INPUT _
        ld h, DEV_STDIN
        ld de, _buffer
        ld bc, BUFFER_SIZE
        READ()
        or a
        jr nz, _end
    ENDM

_start:
@kb_mode_raw:
    ld h, DEV_STDIN
    ld c, KB_CMD_SET_MODE
    ld de, KB_READ_BLOCK | KB_MODE_COOKED
    IOCTL()
@kb_mode_raw_end:

    ld hl, _message
    call strtolower

    S_WRITE3(DEV_STDOUT, _message, _message_end - _message)

    GET_INPUT()
    S_WRITE2(DEV_STDOUT, _buffer)

_end:
    ld h, a
    EXIT()

_message:
    DEFM "Zeal Forth\n"
    DEFB 0

_message_end:

_buffer:
