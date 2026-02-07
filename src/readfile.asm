    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"
    INCLUDE "common_h.asm"

  SECTION TEXT

; @brief Prepare read chunk for parsing complete lines only.
;
; Parameters:
; - BC - current buffer length
;
; Returns:
; - A - ERR_SUCCESS on success, error code from SEEK on failure
; - HL - processed length (bytes up to the last full newline)
;
; Alters:
;   A, BC, DE, HL
_readfile_prepare_chunk:
    ; Preserve original chunk length for processed_len calculation.
    push bc

    ; carry_len in DE (bytes after last newline in full chunk)
    ld de, 0
    ld a, b
    cp 0x01
    jr nz, @finalize
    ld a, c
    cp 0x00
    jr nz, @finalize

    ; Full chunk: scan backwards for last newline.
    ld hl, _input_buffer
    add hl, bc
    dec hl
@scan_last_nl:
    ld a, (hl)
    cp '\n'
    jr z, @finalize
    inc de
    dec hl
    dec bc
    ld a, b
    or c
    jr nz, @scan_last_nl

    ; No newline in full chunk: do not carry tail to avoid stalling.
    ld de, 0
@finalize:
    ; processed_len = BC - DE
    pop hl              ; HL = original chunk length
    or a
    sbc hl, de
    push hl

    ; Null-terminate at processed_len to parse only complete lines.
    ld bc, _input_buffer
    add hl, bc
    ld (hl), 0
    pop hl

    ; If trailing data exists, seek back by -carry_len.
    ld a, d
    or e
    ret z            ; A = 0

    push hl
    ld hl, 0
    or a
    sbc hl, de          ; HL = -carry_len
    ex de, hl           ; DE = low 16-bit offset
    ld bc, 0xFFFF       ; sign-extend to 32-bit negative
    ld a, (_file_fd)
    ld h, a
    ld a, SEEK_CUR
    SEEK()
    pop hl
    ret

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

    ld a, b
    or c
    jr z, @eof
    call _readfile_prepare_chunk
    or a
    jr nz, @error

@parse:
    ld a, h
    or l
    jr z, @read         ; nothing complete in this chunk

    ld hl, _input_buffer
    ld (_next_word), hl
    call do_next_word
    jr @read

@eof:
    ld a, (_file_fd)
    ld h, a
    CLOSE()
    ;; TODO: error check
    xor a
    ld (_file_fd), a
    xor a ; clear zero flag
    ret
@error_neg:
    neg
@error:
    push af
    xor a
    ld (_file_fd), a
    pop af
    call print_error
    xor a ; clear zero flag
    ret
