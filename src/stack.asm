    INCLUDE "constants_h.asm"
    INCLUDE "macros_h.asm"

    SECTION TEXT
    PUBLIC pushdata
  ; @brief Push 16-bit value onto data stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
pushdata:
    push hl
    ld hl, (data_sp)
    dec hl
    dec hl
    ld a, h
    cp data_stack >> 8
    jr c, @push_overflow
    jr nz, @push_store
    ld a, l
    cp data_stack & 0xFF
    jr c, @push_overflow
@push_store:
    ld (hl), e
    inc hl
    ld (hl), d
    dec hl
    ld (data_sp), hl
    pop hl
    ret
@push_overflow:
    pop hl
    ERROR(ERR_STACK_OVERFLOW)


    PUBLIC popdata
  ; @brief Pop top data stack into DE
  ;
  ; Returns:
  ; - DE  - Value popped
popdata:
    push hl
    ld hl, (data_sp)
    ld a, h
    cp _data_stack_end >> 8
    jr c, @pop_load
    jr nz, @pop_underflow
    ld a, l
    cp _data_stack_end & 0xFF
    jr nc, @pop_underflow
    ; fall-thru
@pop_load:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (data_sp), hl
    pop hl
    ret
@pop_underflow:
    pop hl
    ERROR(ERR_STACK_UNDERFLOW)

  ; @brief Peek top data stack into DE
  ;
  ; Alters:
  ;   DE
    PUBLIC peekdata
peekdata:
    push hl
    ld hl, (data_sp)
    ld a, h
    cp _data_stack_end >> 8
    jr c, @dpeek_load
    jr nz, @dpeek_underflow
    ld a, l
    cp _data_stack_end & 0xFF
    jr nc, @dpeek_underflow
@dpeek_load:
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    ret
@dpeek_underflow:
    pop hl
    ERROR(ERR_STACK_UNDERFLOW)


    PUBLIC pushreturn
  ; @brief Push 16-bit value onto return stack
  ;
  ; Parameters:
  ; - DE - 16-bit value
pushreturn:
    push hl
    ld hl, (return_sp)
    dec hl
    dec hl
    ld a, h
    cp return_stack >> 8
    jr c, @rpush_overflow
    jr nz, @rpush_store
    ld a, l
    cp return_stack & 0xFF
    jr c, @rpush_overflow
@rpush_store:
    ld (hl), e
    inc hl
    ld (hl), d
    dec hl
    ld (return_sp), hl
    pop hl
    ret
@rpush_overflow:
    pop hl
    ERROR(ERR_STACK_OVERFLOW)


    PUBLIC popreturn
  ; @brief Pop top return stack into DE
  ;
  ; Returns:
  ; - DE  - Value popped
popreturn:
    push hl
    ld hl, (return_sp)
    ld a, h
    cp _return_stack_end >> 8
    jr c, @rpop_load
    jr nz, @rpop_underflow
    ld a, l
    cp _return_stack_end & 0xFF
    jr nc, @rpop_underflow
    ; fall-thru
@rpop_load:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (return_sp), hl
    pop hl
    ret
@rpop_underflow:
    pop hl
    ERROR(ERR_STACK_UNDERFLOW)

  ; @brief Peek top return stack into DE
  ;
  ; Alters:
  ;   DE
    PUBLIC peekreturn
peekreturn:
    push hl
    ld hl, (return_sp)
    ld a, h
    cp _return_stack_end >> 8
    jr c, @rpeek_load
    jr nz, @rpeek_underflow
    ld a, l
    cp _return_stack_end & 0xFF
    jr nc, @rpeek_underflow
@rpeek_load:
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    ret
@rpeek_underflow:
    pop hl
    ERROR(ERR_STACK_UNDERFLOW)
